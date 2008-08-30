//
//  TransitApp.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransitApp.h"
#import "iPhoneTransitAppDelegate.h"
#import "StopQuery-CSV.h"
#import "StopQuery-ARV.h"

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

typedef StopQuery_ARV StopQuery_Used;
//typedef StopQuery_CSV StopQuery_Used;
	
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
@end


@implementation TransitApp

@synthesize stopQueryAvailable, arrivalQueryAvailable;

- (id) init
{
	[super init];
	
	cityId = kCity_Portland;
    // The stop data is stored in the application bundle. 
    //NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
	NSString *filename = [NSString stringWithFormat:@"%@_stops", cityPath[cityId]];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
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
		arrivalQueryAvailable = YES;
	opQueue = [[NSOperationQueue alloc] init];
	//stopQuery = [StopQuery initWithFile:path];
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

- (int) numberOfStops
{
	if (stopQuery == nil)
		return 0;
	else
		return [stopQuery numberOfStops];
}

- (BusStop *) stopOfId:(int) anId
{
	if (stopQuery == nil)
	{
		return nil;
	}	
	return [stopQuery stopOfId:anId];
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
	return [arrivalQuery queryForStops:stops];
}

#pragma mark A Task to load in data files
- (void) loadStopDataInBackground
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(dataTaskEntry:) object:nil];
	[theOp setQueuePriority:NSOperationQueuePriorityLow];
	[opQueue addOperation:theOp];
}

- (void) dataTaskEntry: (id) data
{
	iPhoneTransitAppDelegate *transitDelegate = (iPhoneTransitAppDelegate *)[self delegate];
	if (![transitDelegate isKindOfClass:[iPhoneTransitAppDelegate class]])
	{
		NSLog(@"For some reason, the App delegate is not a iPhoneTransitAppDelegate");
	}

	//[NSThread sleepForTimeInterval:30];
	stopQuery = [StopQuery_Used initWithFile:dataFile];
	if (stopQuery)
	{
		stopQueryAvailable = YES;
		[transitDelegate dataDidFinishLoading:self];
	}
}

@end
