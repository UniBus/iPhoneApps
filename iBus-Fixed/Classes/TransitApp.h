//
//  TransitApp.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrivalQuery.h"
#import "StopQuery.h"
#import "RouteQuery.h"
#import "TripQuery.h"
#import "RouteStops.h"
#import "OfflineQuery.h"

extern NSString * const UserSavedTimeFormat;
extern NSString * const UserSavedDistanceUnit;
extern NSString * const UserSavedTabBarSequence;
extern NSString * const UserSavedSearchRange;
extern NSString * const UserSavedSearchResultsNum;
extern NSString * const UserSavedSelectedPage;

extern NSString * const UserCurrentCityId;
extern NSString * const UserCurrentCity;
extern NSString * const USerCurrentDatabase;
extern NSString * const UserCurrentWebPrefix;

extern NSString * const UserSavedAutoSwitchOffline;
extern NSString * const UserSavedAlwayOffline;

extern NSString * const ApplicationPresetFixedVersion;
extern NSString * const ApplicationPresetTitle;
extern NSString * const ApplicationPresetGTFSInfo;
extern NSString * const ApplicationPresetAboutFile;

extern NSString * applicationTitle;
extern NSString * gtfsInfoDatabase;
extern NSInteger  iBusFixedVersion;


@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	RouteQuery   *routeQuery;
	TripQuery	 *tripQuery;
	OfflineQuery *offlineQuery;
	RouteStops   *routeStops;
	NSString     *dataFile;
	
	NSString	 *currentCity;
	NSString	 *currentCityId;
	NSString	 *currentDatabase;
	NSString	 *currentWebPrefix;
	
	BOOL         stopQueryAvailable;
	BOOL         routeQueryAvailable;
	BOOL         arrivalQueryAvailable;
	BOOL         tripQueryAvailable;
	int          cityId;
	NSOperationQueue  *opQueue;
}

@property BOOL arrivalQueryAvailable;
@property BOOL stopQueryAvailable;
@property BOOL routeQueryAvailable;

- (BusRoute *) routeOfId:(NSString *) routeId;
- (NSInteger) typeOfRoute:(NSString *) routeId;
- (NSArray *) queryRouteWithName:(NSString *) routeName;
- (NSArray *) queryRouteWithNames:(NSArray *) routeNames;
- (NSArray *) queryRouteWithIds:(NSArray *) routeIds;

//- (NSArray *) queryTripsOnRoute:(NSString *) routeId;
- (NSArray *) queryTripsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId;
- (NSArray *) queryStopsOnTrip:(NSString *) tripId returnedTrip:(BusTrip *)aTrip;
- (NSArray *) queryStopsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId withHeadsign:(NSString *)headSign returnedTrip:(BusTrip *)aTrip;

- (BusStop *) getRandomStop;
- (BusStop *) stopOfId:(NSString *) stopId;
- (NSArray *) queryStopWithPosition:(CGPoint) pos;
- (NSArray *) queryStopWithName:(NSString *) stopName;
- (NSArray *) queryStopWithNames:(NSArray *) stopNames;
- (NSArray *) queryStopWithIds:(NSArray *) stopIds;

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) allRoutesAtStop:(NSString *) sid;
- (BOOL) isStop:(NSString *)stop_id hasRoutes:(NSArray *)routes;

- (NSArray *) arrivalsAtStops: (NSArray*) stops;
- (void) arrivalsAtStopsAsync: (id)stopView;
- (void) scheduleAtStopsAsync: (id)stopView;
- (void) stopsOnTripAtStopsAsync: (id)tripStopView;
- (void) tripsOnRouteAtStopsAsync: (id)routeTripView;
//- (void) tripsOnRouteDirAtStopsAsync: (id)routeDirTripView;

- (void) setCurrentCity:(NSString *)city cityId:(NSString *)cid database:(NSString *)db webPrefix:(NSString *)prefix;
- (NSString *) currentCity;
- (NSString *) currentCityId;
- (NSString *) currentDatabase;
- (NSString *) currentWebServicePrefix;
- (NSString *) currentDatabaseWithFullPath;
- (NSString *) localDatabaseDir;
- (NSString *) gtfsInfoDatabase;
- (void) citySelected:(id)sender;
- (void) resetCurrentCity;
//- (void) onlineUpdateRequested:(id)sender;

@end
