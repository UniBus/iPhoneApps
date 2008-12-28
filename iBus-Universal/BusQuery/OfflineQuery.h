//
//  OfflineQuery.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineQuery : NSObject {
	BOOL         available;
}

@property BOOL available;
- (BOOL) available;
- (NSString *) offlineDbName;

/** @name Search/query for arrivals and trips
 *
 *  These functions query routes and related information, and their names are pretty self-explainatory.
 */
//@{
///Search for whole-day schedule of a given day for the given [route, direction] at the given stop.
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop onDay:(NSString *)day;

///Search for TODAY's whole-day schedule for the given [route, direction] at the given stop.
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop;

///Search for all arrivals at the given stops.
- (NSArray *) queryForStops: (NSArray *) stops;

///Search for all possible trips for a given route.
- (NSArray *) queryTripsOnRoute:(NSString *) routeId;

///Search for all stops in a given trip.
- (NSArray *) queryStopsOnTrip:(NSString *) tripId;
//@}

@end
