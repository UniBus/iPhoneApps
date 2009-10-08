//
//  TransitApp.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "TransitApp.h"
#import "TransitAppDelegate.h"
#import "StopsViewController.h"
#import "RouteScheduleViewController.h"
#import "RouteTripsViewController.h"
#import "TripStopsViewController.h"
#import "CitySelectViewController.h"
#import "CityUpdateViewController.h"
#import "StopQuery.h"
#import "Upgrade.h"
#import "General.h"

NSString * const UserSavedTimeFormat = @"UserSavedTimeFormat";
NSString * const UserSavedDistanceUnit = @"UserSavedDistanceUnit";
NSString * const UserSavedTabBarSequence = @"UserSavedTabBarSequence";
NSString * const UserSavedSearchRange = @"UserSavedSearchRange";
NSString * const UserSavedSearchResultsNum = @"UserSavedSearchResultsNum";
NSString * const UserSavedSelectedPage = @"UserSavedSelectedPage";
NSString * const UserApplicationTitle = @"iBus-Universal";

NSString * const UserCurrentCityId = @"UserSavedCurrentCityId";
NSString * const UserCurrentCity = @"UserSavedCurrentCity";
NSString * const USerCurrentDatabase = @"UserSavedCurrentDatabase";
NSString * const UserCurrentWebPrefix = @"UserSaveCurrentWebPrefix";

NSString * const UserSavedAutoSwitchOffline = @"UserSavedAutoSwitchOffline";
NSString * const UserSavedAlwayOffline = @"UserSavedAlwayOffline";

NSString * const gtfsInfoDatabase = @"gtfs_info.sqlite";

extern int currentTimeFormat;
extern int currentUnit;
extern float searchRange;
extern int numberOfResults;
extern BOOL autoSwitchToOffline;
extern BOOL alwaysOffline;
extern BOOL cityUpdateAvailable;

@interface TransitApp ()
- (void) initializeGTFSInfoDatabase;
- (void) initializeDatabase;
- (void) initializeWebService;
- (void) queryArrivalTaskEntry: (id) queryingObj;
- (void) queryStopTaskEntry: (id) queryingObj;
- (void) queryTripsOnRoueTaskEntry: (id) queryingObj;
- (void) queryStopsOnTripTaskEntry: (id) queryingObj;
- (void) registerUserDefaults;
- (void) userAlert: (NSString *) msg;
@end


@implementation TransitApp

@synthesize stopQueryAvailable, arrivalQueryAvailable, routeQueryAvailable;

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
	[routeQuery release];
	[routeStops release];
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
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:UserSavedAutoSwitchOffline];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:UserSavedAlwayOffline];
	[defaultValues setObject:[NSMutableArray array] forKey:UserSavedTabBarSequence];
	[defaultValues setObject:[NSNumber numberWithInt:UNIT_KM] forKey:UserSavedDistanceUnit];
	[defaultValues setObject:[NSNumber numberWithInt:TIME_24H] forKey:UserSavedTimeFormat];
	[defaults registerDefaults:defaultValues];
}

- (void) userAlert: (NSString *) msg
{
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:msg
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];		
}

#pragma mark Database operation
//Notes: There are citySelected: in both TransitApp and TransitAppDelegate.
//   and the difference, please refer to [TransitAppDelegate citySelected]:
//
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

/*
- (void) onlineUpdateRequested:(id)sender
{
	@try {
		[self.delegate performSelector:@selector(onlineUpdateRequested:) withObject:sender];
	}
	@catch (NSException * e) {
	}	
}
*/

/* To make current city look like hasn't been updated for a while.
 */
- (void) antiqueCurrentCity
{
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
		/* This portion is for older version.
		NSError *error;
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentDatabase];
		if (![fileManager copyItemAtPath:srcPath toPath:destPath error:&error])
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		else
			NSLog(@"Database file copy to %@", destPath);
		 */
		[self userAlert: @"Database missed or corrupted! Please download new city database for the city from Settings."];
	}
	else
	{
		if (upgradeNeeded(destPath))
		{
			NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentDatabase];
			if (upgrade(destPath, srcPath) == NO)
				[self userAlert: @"Upgrading database incompleted! Please download new data for the city from Settings."];
			else
			{
				[self userAlert: @"Database upgraded!"];				
				antiqueCity(currentCityId);
				cityUpdateAvailable = YES;
				//The following line was for updating from V1.0 to V1.1
				//[self userAlert: @"Database upgraded! You may find some extra routes in your list, please check."];
			}
		}
	}
	
	NSLog(@"Open database: %@", destPath);
	[stopQuery release];
	stopQuery = [StopQuery initWithFile:destPath];	
	[routeQuery release];
	routeQuery = [RouteQuery initWithFile:destPath];	
	[routeStops release];
	routeStops = [RouteStops initWithFile:destPath];	
	[offlineQuery release];
	offlineQuery = [[OfflineQuery alloc] init];
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
		
		//This is only for the update from v1.0 to v1.1 only, should be removed later
		NSString *selectedCity = [[NSUserDefaults standardUserDefaults] objectForKey:UserCurrentCity];
		if (![selectedCity isEqualToString:@""])
			resetCurrentCity(destPath);
	}
	else
	{
		if (upgradeNeeded(destPath))
		{
			NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gtfsInfoDatabase];
			upgradeGTFS(destPath, srcPath);
			resetCurrentCity(destPath);
		}
	}
	
	NSLog(@"Open GTFS_info database: %@", destPath);
}

- (void) initializeWebService
{
	NSAssert((currentWebPrefix != nil), @"Web service is not set properly!!");
	NSLog(@"Current Webservice: %@", currentWebPrefix);

	[arrivalQuery release];
	arrivalQuery = [[ArrivalQuery alloc] init];
	if (arrivalQuery)
	{
		arrivalQuery.webServicePrefix = currentWebPrefix;
		arrivalQueryAvailable = YES;
	}	
	
	[tripQuery release];
	tripQuery = [[TripQuery alloc] init];
	if (tripQuery)
	{
		tripQuery.webServicePrefix = currentWebPrefix;
		tripQueryAvailable = YES;
	}	
}

- (void) resetCurrentCity
{
	[self initializeDatabase];	

	@try {
		[self.delegate performSelector:@selector(cityDidChange)];
	}
	@catch (NSException * e) {
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

#pragma mark Route Querying Functions
- (BusRoute *) routeOfId:(NSString *) routeId
{
	if (routeQuery == nil)
	{
		return nil;
	}	
	return [routeQuery routeOfId:routeId];
}

- (NSInteger) typeOfRoute:(NSString *) routeId
{
	if (routeQuery == nil)
	{
		return -1;
	}	
	return [routeQuery typeOfRoute:routeId];
}

- (NSArray *) queryRouteWithName:(NSString *) routeName
{
	if (routeQuery == nil)
		return [NSMutableArray array];
	
	return [routeQuery queryRouteWithName:routeName];
}

- (NSArray *) queryRouteWithNames:(NSArray *) routeNames
{
	if (routeQuery == nil)
		return [NSMutableArray array];
	
	return [routeQuery queryRouteWithNames:routeNames];
}

- (NSArray *) queryRouteWithIds:(NSArray *) routeIds
{
	if (routeQuery == nil)
		return [NSMutableArray array];
	
	return [routeQuery queryRouteWithIds:routeIds];
}

#pragma mark Stop Querying Functions
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

- (NSArray *) allRoutesAtStop:(NSString *) sid
{
	if (routeStops == nil)
	{
		return [NSMutableArray array];
	}
	return [routeStops allRoutesAtStop:sid];
}

- (BOOL) isStop:(NSString *)stop_id hasRoutes:(NSArray *)routes;
{
	if (routeStops == nil)
		return YES;

	return [routeStops isStop:stop_id hasRoutes:routes];
}

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm
{
	if (stopQuery == nil)
	{
		return [NSMutableArray array];
	}
	return [stopQuery queryStopWithPosition:pos within:distInKm*UnitToKm(currentUnit)];
}

#pragma mark Trip Querying Functions
/*
- (NSArray *) queryTripsOnRoute:(NSString *) routeId
{
	if (tripQuery == nil)
	{
		return [NSMutableArray array];
	}
	
	self.networkActivityIndicatorVisible = YES;
	NSArray *results = [tripQuery queryTripsOnRoute:routeId];
	self.networkActivityIndicatorVisible = NO;
	
	return results;
}
*/

- (NSArray *) queryTripsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId
{
	if (tripQuery == nil)
	{
		return [NSMutableArray array];
	}
	
	self.networkActivityIndicatorVisible = YES;
	NSArray *results = [tripQuery queryTripsOnRoute:routeId inDirection:dirId];
	self.networkActivityIndicatorVisible = NO;
	
	return results;
}

- (NSArray *) queryStopsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId withHeadsign:(NSString *)headSign returnedTrip:(BusTrip *)aTrip;
{
	if (tripQuery == nil)
	{
		return [NSMutableArray array];
	}
	
	self.networkActivityIndicatorVisible = YES;
	NSArray *results = [tripQuery queryStopsOnRoute:routeId inDirection:dirId withHeadsign:headSign returnedTrip:aTrip];
	self.networkActivityIndicatorVisible = NO;
	
	return results;
}

- (NSArray *) queryStopsOnTrip:(NSString *) tripId returnedTrip:(BusTrip *)aTrip;
{
	if (tripQuery == nil)
	{
		return [NSMutableArray array];
	}
	
	self.networkActivityIndicatorVisible = YES;
	NSArray *results = [tripQuery queryStopsOnTrip:tripId returnedTrip:aTrip];
	self.networkActivityIndicatorVisible = NO;
	
	return results;
}

#pragma mark Arrival Query Functions
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

#pragma mark Asynchronous query through internet
- (void) scheduleAtStopsAsync: (id)stopView  //This is in local database, though
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryStopTaskEntry:) object:stopView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
	[theOp release];
}

- (void) arrivalsAtStopsAsync: (id)stopView
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryArrivalTaskEntry:) object:stopView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
	[theOp release];
}	

- (void) tripsOnRouteAtStopsAsync: (id)routeTripView
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryTripsOnRoueTaskEntry:) object:routeTripView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
	[theOp release];
}	

- (void) stopsOnTripAtStopsAsync: (id)tripStopView
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryStopsOnTripTaskEntry:) object:tripStopView];
	[theOp setQueuePriority:NSOperationQueuePriorityNormal];
	[opQueue addOperation:theOp];
	[theOp release];
}	

- (void) queryTaskExit: (NSInvocation *) invocation 
{
	[invocation invoke];
}

- (void) queryArrivalTaskEntry: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[StopsViewController class]])
		return;
	
	StopsViewController *stopsViewCtrl = (StopsViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		NSArray *results = nil;
		NSAssert(arrivalQuery != nil, @"Something is wrong, haven't initialized properly!");

		if (autoSwitchToOffline)
		{
			if ([arrivalQuery available])
			{
				self.networkActivityIndicatorVisible = YES;
				results = [arrivalQuery queryForStops:stopsViewCtrl.stopsOfInterest];
				self.networkActivityIndicatorVisible = NO;
			}
			else if ([offlineQuery available])
			{
				results = [offlineQuery queryForStops:stopsViewCtrl.stopsOfInterest];
			}
			else
			{
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed, and offline data not available!" waitUntilDone:NO];
			}
		}
		else if (alwaysOffline)
		{
			if ([offlineQuery available])
				results = [offlineQuery queryForStops:stopsViewCtrl.stopsOfInterest];
			else
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Offline data not available!" waitUntilDone:NO];
		}
		else
		{
			self.networkActivityIndicatorVisible = YES;
			results = [arrivalQuery queryForStops:stopsViewCtrl.stopsOfInterest];
			self.networkActivityIndicatorVisible = NO;
		}

		if (results == nil)
			results = [NSMutableArray array];

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

- (void) queryStopTaskEntry: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[RouteScheduleViewController class]])
		return;
	
	RouteScheduleViewController *routeScheduleViewCtrl = (RouteScheduleViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		NSArray *results = nil;		
		NSAssert(arrivalQuery != nil, @"Something is wrong, haven't initialized properly!");

		if (autoSwitchToOffline)
		{
			if ([arrivalQuery available])
			{
				self.networkActivityIndicatorVisible = YES;
				results = [arrivalQuery queryForRoute:routeScheduleViewCtrl.routeID inDirection:routeScheduleViewCtrl.direction atStop:routeScheduleViewCtrl.stopID onDay:routeScheduleViewCtrl.dayID];
				self.networkActivityIndicatorVisible = NO;
			}
			else if ([offlineQuery available])
			{
				results = [offlineQuery queryForRoute:routeScheduleViewCtrl.routeID inDirection:routeScheduleViewCtrl.direction atStop:routeScheduleViewCtrl.stopID onDay:routeScheduleViewCtrl.dayID];
			}
			else
			{
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed, and offline data not available!" waitUntilDone:NO];
			}
		}
		else if (alwaysOffline)
		{
			if  ([offlineQuery available])
				results = [offlineQuery queryForRoute:routeScheduleViewCtrl.routeID inDirection:routeScheduleViewCtrl.direction atStop:routeScheduleViewCtrl.stopID onDay:routeScheduleViewCtrl.dayID];
			else
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Offline data not available!" waitUntilDone:NO];
		}
		else
		{
			self.networkActivityIndicatorVisible = YES;
			results = [arrivalQuery queryForRoute:routeScheduleViewCtrl.routeID inDirection:routeScheduleViewCtrl.direction atStop:routeScheduleViewCtrl.stopID onDay:routeScheduleViewCtrl.dayID];
			self.networkActivityIndicatorVisible = NO;
		}			
				
		if (results == nil)
			results = [NSMutableArray array];
		
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

- (void) queryTripsOnRoueTaskEntry: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[RouteTripsViewController class]])
	{
		NSLog(@"Wrong class is querying TripsOnRoute!!");
		return;
	}
	
	RouteTripsViewController *routeTripsViewCtrl = (RouteTripsViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		NSArray *results = nil;
		NSAssert(tripQuery != nil, @"Something is wrong, haven't initialized properly!");

		if (autoSwitchToOffline)
		{
			if ([tripQuery available])
			{
				self.networkActivityIndicatorVisible = YES;
				results = [tripQuery queryTripsOnRoute:[routeTripsViewCtrl routeID] inDirection:[routeTripsViewCtrl dirID]];
				self.networkActivityIndicatorVisible = NO;
			}
			else if ([offlineQuery available])
			{
				results = [offlineQuery queryTripsOnRoute:[routeTripsViewCtrl routeID] inDirection:[routeTripsViewCtrl dirID]];
			}
			else
			{
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed, and offline data not available!" waitUntilDone:NO];
			}
		}
		else if (alwaysOffline)
		{
			if  ([offlineQuery available])
				results = [offlineQuery queryTripsOnRoute:[routeTripsViewCtrl routeID] inDirection:[routeTripsViewCtrl dirID]];
			else
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Offline data not available!" waitUntilDone:NO];
		}
		else
		{
			self.networkActivityIndicatorVisible = YES;
			results = [tripQuery queryTripsOnRoute:[routeTripsViewCtrl routeID] inDirection:[routeTripsViewCtrl dirID]];
			self.networkActivityIndicatorVisible = NO;
		}	
		if (results == nil)
			results = [NSMutableArray array];

		NSMethodSignature * sig = [[queryingObj class] instanceMethodSignatureForSelector: @selector(tripsUpdated:)];
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setTarget: queryingObj];
		[invocation setSelector: @selector(tripsUpdated:)];	
		[invocation setArgument:&results atIndex:2];
		[invocation retainArguments];
			
		//[queryingObj arrivalsUpdated: results];
		[self performSelectorOnMainThread:@selector(queryTaskExit:) withObject:invocation waitUntilDone:NO];
	}
}

- (void) queryStopsOnTripTaskEntry: (id) queryingObj
{
	if (! [queryingObj isKindOfClass:[TripStopsViewController class]])
	{
		NSLog(@"Wrong class is querying StopsOnTrip!!");
		return;
	}
	
	TripStopsViewController *tripStopsViewCtrl = (TripStopsViewController *)queryingObj;
	
	//Only allow one single query at a time
	@synchronized (self)
	{
		NSArray *results = nil;
		BusTrip *lastTrip = [[BusTrip alloc] init];
		NSAssert(tripQuery != nil, @"Something is wrong, haven't initialized properly!");

		if (autoSwitchToOffline)
		{
			if ([tripQuery available])
			{
				self.networkActivityIndicatorVisible = YES;
				if (tripStopsViewCtrl.queryByRouteId)
				{
					results = [tripQuery queryStopsOnRoute:tripStopsViewCtrl.routeId
											   inDirection:tripStopsViewCtrl.dirId
											  withHeadsign:tripStopsViewCtrl.headSign  
											  returnedTrip:lastTrip];
				}
				else
				{
					results = [tripQuery queryStopsOnTrip:tripStopsViewCtrl.tripId returnedTrip:lastTrip];
				}
				self.networkActivityIndicatorVisible = NO;
			}
			else if ([offlineQuery available])
			{
				if (tripStopsViewCtrl.queryByRouteId)
				{
					results = [offlineQuery queryStopsOnRoute:tripStopsViewCtrl.routeId
												  inDirection:tripStopsViewCtrl.dirId
												 withHeadsign:tripStopsViewCtrl.headSign
												 returnedTrip:lastTrip];
				}
				else
				{
					results = [offlineQuery queryStopsOnTrip:tripStopsViewCtrl.tripId returnedTrip:lastTrip];
				}
			}
			else
			{
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed, and offline data not available!" waitUntilDone:NO];
			}
		}
		else if (alwaysOffline)
		{
			if  ([offlineQuery available])
			{
				//results = [offlineQuery queryStopsOnTrip:[tripStopsViewCtrl tripID]];
				if (tripStopsViewCtrl.queryByRouteId)
				{
					results = [offlineQuery queryStopsOnRoute:tripStopsViewCtrl.routeId
												  inDirection:tripStopsViewCtrl.dirId
												 withHeadsign:tripStopsViewCtrl.headSign
												 returnedTrip:lastTrip];
				}
				else
				{
					results = [offlineQuery queryStopsOnTrip:tripStopsViewCtrl.tripId returnedTrip:lastTrip];
				}
			}
			else
				[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Offline data not available!" waitUntilDone:NO];
		}
		else
		{
			self.networkActivityIndicatorVisible = YES;
			//results = [tripQuery queryStopsOnTrip:[tripStopsViewCtrl tripID]];
			if (tripStopsViewCtrl.queryByRouteId)
			{
				results = [tripQuery queryStopsOnRoute:tripStopsViewCtrl.routeId
										   inDirection:tripStopsViewCtrl.dirId
										  withHeadsign:tripStopsViewCtrl.headSign  
										  returnedTrip:lastTrip];
			}
			else
			{
				results = [tripQuery queryStopsOnTrip:tripStopsViewCtrl.tripId returnedTrip:lastTrip];
			}
			self.networkActivityIndicatorVisible = NO;
		}
		if (results == nil)
			results = [NSMutableArray array];
		
		NSMethodSignature * sig = [[queryingObj class] instanceMethodSignatureForSelector: @selector(stopsUpdated: returnedTrip:)];
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature: sig];
		[invocation setTarget: queryingObj];
		[invocation setSelector: @selector(stopsUpdated: returnedTrip:)];	
		[invocation setArgument:&results atIndex:2];
		[invocation setArgument:&lastTrip atIndex:3];
		[invocation retainArguments];
		
		//[queryingObj arrivalsUpdated: results];
		[self performSelectorOnMainThread:@selector(queryTaskExit:) withObject:invocation waitUntilDone:NO];
		[lastTrip autorelease];
	}
}

@end
