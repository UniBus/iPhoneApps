//
//  TransitApp.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransitApp.h"
#import "TransitAppDelegate.h"
#import "StopsViewController.h"
#import "RouteScheduleViewController.h"
#import "StopQuery.h"

enum _supported_city 
{
	kCity_Portland,
	kCity_Num,	
};

NSString *cityPath[]=
{
	@"portland",
};

NSString *cityTitles[]=
{
	@"Portland, OR",
};

	
NSString * const UserSavedRecentStopsAndBuses = @"UserSavedRecentStopsAndBuses";
NSString * const UserSavedFavoriteStopsAndBuses = @"UserSavedFavoriteStopsAndBuses";
NSString * const UserSavedSearchRange = @"UserSavedSearchRange";
NSString * const UserSavedSearchResultsNum = @"UserSavedSearchResultsNum";
NSString * const UserSavedSelectedPage = @"UserSavedSelectedPage";
NSString * const UserApplicationTitle = @"iBus";

extern float searchRange;
extern int numberOfResults;

@interface TransitApp ()
- (void) dataTaskEntry: (id) data;
- (void) queryTaskEntry: (id) queryingObj;
@end


@implementation TransitApp

@synthesize stopQueryAvailable, arrivalQueryAvailable;

- (NSString *) currentDatabase
{
	NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
	//NSString *filename = [NSString stringWithFormat:@"%@_stops", cityPath[cityId]];
	NSString *filename = @"stops.sqlite";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	return path;
}

- (NSString *) currentWebServicePrefix
{
	return nil;
}

- (id) init
{
	[super init];
	
	cityId = kCity_Portland;
    // The stop data is stored in the application bundle. 
    //NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
	//NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
	//NSString *filename = [NSString stringWithFormat:@"%@_stops", cityPath[cityId]];
	//NSString *filename = @"stops.sqlite";
    //NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	NSString *path = [self currentDatabase];
	NSLog(@"Opening file: %@", path);
	dataFile = [path retain];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	NSMutableArray *emptyArray = [NSMutableArray array];
	[defaultValues setObject:emptyArray forKey:UserSavedRecentStopsAndBuses];
	[defaultValues setObject:emptyArray forKey:UserSavedFavoriteStopsAndBuses];
	[defaultValues setObject:[NSNumber numberWithFloat:searchRange] forKey:UserSavedSearchRange];
	[defaultValues setObject:[NSNumber numberWithInt:numberOfResults] forKey:UserSavedSearchResultsNum];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:UserSavedSelectedPage];
	[defaults registerDefaults:defaultValues];
	
	arrivalQuery = [[ArrivalQuery alloc] init];
	if (arrivalQuery)
	{
		arrivalQuery.webServicePrefix = @"http://192.168.1.100/portland";
		arrivalQueryAvailable = YES;
	}
	opQueue = [[NSOperationQueue alloc] init];
	stopQuery = [StopQuery initWithFile:path];
	//[self loadDataInBackground];
	
	return self;
}

- (void) dealloc
{
	[opQueue cancelAllOperations];
	[opQueue autorelease];
	[arrivalQuery release];
	[stopQuery release];
	[super dealloc];
}

- (BusStop *) stopOfId:(NSString *) anId
{
	if (stopQuery == nil)
	{
		return nil;
	}	
	return [stopQuery stopOfId:anId];
}

- (NSArray *) queryStopWithPosition:(CGPoint) pos
{
	if (stopQuery == nil)
		return [NSMutableArray array];
	
	return [stopQuery queryStopWithPosition:pos within:searchRange];
}

- (NSArray *) queryStopWithName:(NSString *) stopName
{
	if (stopQuery == nil)
		return [NSMutableArray array];
	
	return [stopQuery queryStopWithName:stopName];
}

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm
{
	if (stopQuery == nil)
	{
		return [NSMutableArray array];
	}
	return [stopQuery queryStopWithPosition:pos within:distInKm];
}

- (NSArray *) arrivalsAtStops: (NSArray*) stops
{
	if (arrivalQuery == nil)
	{
		return [NSMutableArray array];
	}
	
	self.networkActivityIndicatorVisible = YES;
	NSArray *results = [arrivalQuery queryForStops:stops];
	self.networkActivityIndicatorVisible = NO;
	
	return results;
}

- (void) scheduleAtStopsAsync: (id)stopView
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryTaskEntry2:) object:stopView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
}

- (void) arrivalsAtStopsAsync: (id)stopView
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryTaskEntry:) object:stopView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
}	

- (void) userAlert: (NSString *) msg
{
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];		
}
	
#pragma mark Arrivals query through internet
- (void) queryTaskExit: (NSInvocation *) invocation 
{
	[invocation invoke];
}

- (void) queryTaskEntry: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[StopsViewController class]])
		return;
	
	StopsViewController *stopsViewCtrl = (StopsViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		if (arrivalQuery == nil)
		{
			[queryingObj arrivalsUpdated: [NSMutableArray array]];
		}
	
		self.networkActivityIndicatorVisible = YES;
		NSArray *results = [arrivalQuery queryForStops:stopsViewCtrl.stopsOfInterest];
		//[NSThread sleepForTimeInterval:3];
		self.networkActivityIndicatorVisible = NO;

		NSMethodSignature * sig = [[queryingObj class] instanceMethodSignatureForSelector: @selector(arrivalsUpdated:)];
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setTarget: queryingObj];
		[invocation setSelector: @selector(arrivalsUpdated:)];	
		[invocation setArgument:&results atIndex:2];
		[invocation retainArguments];
		
		//[queryingObj arrivalsUpdated: results];
		[self performSelectorOnMainThread:@selector(queryTaskExit:) withObject:invocation waitUntilDone:NO];
	}
}

- (void) queryTaskEntry2: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[RouteScheduleViewController class]])
		return;
	
	RouteScheduleViewController *routeScheduleViewCtrl = (RouteScheduleViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		if (arrivalQuery == nil)
		{
			[queryingObj arrivalsUpdated: [NSMutableArray array]];
		}
		
		self.networkActivityIndicatorVisible = YES;
		NSArray *results = [arrivalQuery queryForRoute:routeScheduleViewCtrl.routeID atStop:routeScheduleViewCtrl.stopID onDay:routeScheduleViewCtrl.dayID];
		self.networkActivityIndicatorVisible = NO;
		
		NSMethodSignature * sig = [[queryingObj class] instanceMethodSignatureForSelector: @selector(arrivalsUpdated:)];
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setTarget: queryingObj];
		[invocation setSelector: @selector(arrivalsUpdated:)];	
		[invocation setArgument:&results atIndex:2];
		[invocation retainArguments];
		
		//[queryingObj arrivalsUpdated: results];
		[self performSelectorOnMainThread:@selector(queryTaskExit:) withObject:invocation waitUntilDone:NO];
	}
}

#pragma mark A Task to load in data files
- (void) loadStopDataInBackground
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(dataTaskEntry:) object:nil];
	[theOp setQueuePriority:NSOperationQueuePriorityLow];
	[opQueue addOperation:theOp];
}

- (void) dataTaskExit: (id) data
{
	TransitAppDelegate *transitDelegate = (TransitAppDelegate *)[self delegate];
	if (![transitDelegate isKindOfClass:[TransitAppDelegate class]])
	{
		NSLog(@"For some reason, the App delegate is not a iPhoneTransitAppDelegate");
	}

	[transitDelegate dataDidFinishLoading:self];
}

- (void) dataTaskEntry: (id) data
{
	//[NSThread sleepForTimeInterval:5];
	stopQuery = [StopQuery initWithFile:dataFile];
	if (stopQuery)
	{
		stopQueryAvailable = YES;
		[self performSelectorOnMainThread:@selector(dataTaskExit:) withObject:nil waitUntilDone:NO];
		//[transitDelegate dataDidFinishLoading:self];
	}
}

@end
