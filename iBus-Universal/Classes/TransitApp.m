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
#import "CitySelectViewController.h"
#import "StopQuery.h"
#import "Upgrade.h"

NSString * const UserSavedSearchRange = @"UserSavedSearchRange";
NSString * const UserSavedSearchResultsNum = @"UserSavedSearchResultsNum";
NSString * const UserSavedSelectedPage = @"UserSavedSelectedPage";
NSString * const UserApplicationTitle = @"iBus-Universal";

NSString * const UserCurrentCityId = @"UserSavedCurrentCityId";
NSString * const UserCurrentCity = @"UserSavedCurrentCity";
NSString * const USerCurrentDatabase = @"UserSavedCurrentDatabase";
NSString * const UserCurrentWebPrefix = @"UserSaveCurrentWebPrefix";

NSString * const gtfsInfoDatabase = @"gtfs_info.sqlite";

extern float searchRange;
extern int numberOfResults;

@interface TransitApp ()
- (void) initializeGTFSInfoDatabase;
- (void) initializeDatabase;
- (void) initializeWebService;
- (void) queryTaskEntry: (id) queryingObj;
- (void) registerUserDefaults;
- (void) userAlert: (NSString *) msg;
@end


@implementation TransitApp

@synthesize stopQueryAvailable, arrivalQueryAvailable;

- (id) init
{
	[super init];
	
	[self registerUserDefaults];
	[self initializeGTFSInfoDatabase];
	
	opQueue = [[NSOperationQueue alloc] init];
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

//!
//! Register user saved default data
//!
- (void) registerUserDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithFloat:searchRange] forKey:UserSavedSearchRange];
	[defaultValues setObject:[NSNumber numberWithInt:numberOfResults] forKey:UserSavedSearchResultsNum];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:UserSavedSelectedPage];
	[defaultValues setObject:@"" forKey:UserCurrentCity];
	[defaultValues setObject:@"" forKey:USerCurrentDatabase];
	[defaultValues setObject:@"" forKey:UserCurrentWebPrefix];
	[defaults registerDefaults:defaultValues];
}

#pragma mark Database operation
- (void) citySelected:(id)sender
{
	NSAssert([sender isKindOfClass:[CitySelectViewController class]], @"Received citySelect: from an unknow object!");
	
	CitySelectViewController *cityVC = (CitySelectViewController *)sender;
	NSAssert (![cityVC.currentCity isEqualToString:@""] && ![cityVC.currentDatabase isEqualToString:@""] && 
			  ![cityVC.currentURL isEqualToString:@""], @"Selected city info is not set properly!!");
	
	NSLog(@"City selected: %@\nDatabase: %@\nWebPrefix: %@", cityVC.currentCity, cityVC.currentDatabase, cityVC.currentURL);
	
	[self setCurrentCity:cityVC.currentCity 
				  cityId:cityVC.currentCityId 
				database:cityVC.currentDatabase 
			   webPrefix:cityVC.currentURL];	
	
	@try {
		[self.delegate performSelector:@selector(cityDidChange)];
	}
	@catch (NSException * e) {
	}	
}

- (void) initializeDatabase
{
	NSAssert((currentDatabase != nil), @"Database is not set properly!!");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:currentDatabase];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:destPath])
	{
		NSError *error;
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentDatabase];
		if (![fileManager copyItemAtPath:srcPath toPath:destPath error:&error])
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		else
			NSLog(@"Database file copy to %@", destPath);
	}
	else
	{
		if (upgradeNeeded(destPath))
		{
			NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentDatabase];
			if (upgrade(destPath, srcPath) == NO)
				[self userAlert: @"Upgade Database error! If the error persists, try online update."];
			else
				[self userAlert: @"Database upgraded! You may find some extra routes in your list, please check."];
		}
	}
	
	NSLog(@"Open database: %@", destPath);
	[stopQuery release];
	stopQuery = [StopQuery initWithFile:destPath];	
}

- (void) initializeGTFSInfoDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:gtfsInfoDatabase];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:destPath])
	{
		NSError *error;
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gtfsInfoDatabase];
		if (![fileManager copyItemAtPath:srcPath toPath:destPath error:&error])
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		else
			NSLog(@"Database file copy to %@", destPath);
	}
	else
	{
		if (upgradeNeeded(destPath))
		{
			NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gtfsInfoDatabase];
			copyDatabase(destPath, srcPath);
			resetCurrentCity(destPath);
		}
	}
	
	NSLog(@"Open GTFS_info database: %@", destPath);
}

- (void) initializeWebService
{
	NSAssert((currentWebPrefix != nil), @"Web service is not set properly!!");

	[arrivalQuery release];
	arrivalQuery = [[ArrivalQuery alloc] init];
	if (arrivalQuery)
	{
		arrivalQuery.webServicePrefix = currentWebPrefix;
		arrivalQueryAvailable = YES;
	}	
}

- (void) setCurrentCity:(NSString *)city cityId:(NSString *)cid database:(NSString *)db webPrefix:(NSString *)prefix
{
	currentCity = [city copy];
	currentCityId = [cid copy];
	currentDatabase = [db copy];
	currentWebPrefix = [prefix copy];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:currentCity forKey:UserCurrentCity];
	[defaults setObject:currentCityId forKey:UserCurrentCityId];
	[defaults setObject:currentDatabase forKey:USerCurrentDatabase];
	[defaults setObject:currentWebPrefix forKey:UserCurrentWebPrefix];
	
	[self initializeDatabase];
	[self initializeWebService];	
}

- (NSString *) currentCity
{
	return currentCity;
}

- (NSString *) currentCityId
{
	return currentCityId;
}

- (NSString *) currentDatabase
{
	return currentDatabase;
	/*
	 NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
	 //NSString *filename = [NSString stringWithFormat:@"%@_stops", cityPath[cityId]];
	 NSString *filename = @"stops.sqlite";
	 NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	 */
	
	
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *destPath = [documentsDirectory stringByAppendingPathComponent:@"stops.sqlite"];
	//return destPath;
}

- (NSString *) currentDatabaseWithFullPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:currentDatabase];
	return destPath;
}

- (NSString *) localDatabaseDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);   
	return [paths objectAtIndex:0];
}

- (NSString *) gtfsInfoDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:gtfsInfoDatabase];
	return destPath;
}

- (NSString *) currentWebServicePrefix
{
	return currentWebPrefix;
}

- (BusStop *) getRandomStop
{
	if (stopQuery == nil)
	{
		return nil;
	}	
	return [stopQuery getRandomStop];
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

- (NSArray *) queryStopWithIds:(NSArray *) stopIds
{
	if (stopQuery == nil)
		return [NSMutableArray array];
	
	return [stopQuery queryStopWithIds:stopIds];
}

- (NSArray *) queryStopWithNames:(NSArray *) stopNames
{
	if (stopQuery == nil)
		return [NSMutableArray array];
	
	return [stopQuery queryStopWithNames:stopNames];
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
	[theOp release];
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

@end
