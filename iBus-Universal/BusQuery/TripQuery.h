//
//  RouteQuery.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "BusRoute.h"
#import "BusTrip.h"
#import "PhpXmlQuery.h"

@interface TripQuery : PhpXmlQuery{
	NSMutableArray	*tripsOnRoute;
	NSMutableArray	*stopsOnTrip;
	NSInteger		currentQuery;
	
	//The following two are simply for debugging purpose!!
	NSString		*queryingTrip;
	NSString		*queryingRoute;
	//NSString		*queryingDir;
	//NSString		*queryingHeadSign;
	
	BusTrip         *lastTrip;
}

- (NSArray *) queryTripsOnRoute:(NSString *) routeId;
- (NSArray *) queryTripsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId;
- (NSArray *) queryStopsOnTrip:(NSString *) tripId returnedTrip:(BusTrip *)aTrip;
- (NSArray *) queryStopsOnRoute:(NSString *) routeId inDirection:(NSString *) dirId withHeadsign:(NSString *)heasdSign returnedTrip:(BusTrip *)aTrip;

@property (retain) NSString *queryingTrip;
@property (retain) NSString *queryingRoute;
//@property (retain) NSString *queryingDir;
//@property (retain) NSString *queryingHeadSign;

@property (retain) BusTrip *lastTrip;

@end
