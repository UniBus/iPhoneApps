//
//  RouteQuery.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "BusRoute.h"
#import "PhpXmlQuery.h"

@interface TripQuery : PhpXmlQuery{
	NSMutableArray	*tripsOnRoute;
	NSMutableArray	*stopsOnTrip;
	NSInteger		currentQuery;
	
	//The following two are simply for debugging purpose!!
	NSString		*queryingRoute;
	NSString		*queryingTrip;
}

- (NSArray *) queryTripsOnRoute:(NSString *) routeId;
- (NSArray *) queryStopsOnTrip:(NSString *) tripId;

@end
