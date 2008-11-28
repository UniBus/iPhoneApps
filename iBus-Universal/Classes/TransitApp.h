//
//  TransitApp.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrivalQuery.h"
#import "StopQuery.h"
#import "RouteQuery.h"
#import "TripQuery.h"

extern NSString * const UserSavedSearchRange;
extern NSString * const UserSavedSearchResultsNum;
extern NSString * const UserApplicationTitle;
extern NSString * const UserSavedSelectedPage;

extern NSString * const UserCurrentCityId;
extern NSString * const UserCurrentCity;
extern NSString * const USerCurrentDatabase;
extern NSString * const UserCurrentWebPrefix;

@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	RouteQuery   *routeQuery;
	TripQuery	 *tripQuery;
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
- (NSArray *) queryRouteWithName:(NSString *) routeName;
- (NSArray *) queryRouteWithNames:(NSArray *) routeNames;
- (NSArray *) queryRouteWithIds:(NSArray *) routeIds;

- (NSArray *) queryTripsOnRoute:(NSString *) routeId;
- (NSArray *) queryStopsOnTrip:(NSString *) tripId;

- (BusStop *) getRandomStop;
- (BusStop *) stopOfId:(NSString *) stopId;
- (NSArray *) queryStopWithPosition:(CGPoint) pos;
- (NSArray *) queryStopWithName:(NSString *) stopName;
- (NSArray *) queryStopWithNames:(NSArray *) stopNames;
- (NSArray *) queryStopWithIds:(NSArray *) stopIds;

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) arrivalsAtStops: (NSArray*) stops;
- (void) arrivalsAtStopsAsync: (id)stopView;
- (void) scheduleAtStopsAsync: (id)stopView;
- (void) stopsOnTripAtStopsAsync: (id)tripStopView;
- (void) tripsOnRouteAtStopsAsync: (id)routeTripView;

- (void) setCurrentCity:(NSString *)city cityId:(NSString *)cid database:(NSString *)db webPrefix:(NSString *)prefix;
- (NSString *) currentCity;
- (NSString *) currentCityId;
- (NSString *) currentDatabase;
- (NSString *) currentWebServicePrefix;
- (NSString *) currentDatabaseWithFullPath;
- (NSString *) localDatabaseDir;
- (NSString *) gtfsInfoDatabase;
- (void) citySelected:(id)sender;
- (void) onlineUpdateRequested:(id)sender;

@end
