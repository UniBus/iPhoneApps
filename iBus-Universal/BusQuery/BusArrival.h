//
//  BusArrival.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>

@interface BusArrival : NSObject {
	NSString *stopId;
	NSString *arrivalTime;
	NSString *busSign;
	NSString *route;
	NSString *routeId;
	BOOL departed;
	BOOL flag; 
}

@property BOOL flag;
@property BOOL departed;

- (NSComparisonResult) compare: (BusArrival *)avl;

- (NSString *) arrivalTime;
- (void) setArrivalTime: (NSString *) arrivalAt;
- (void) setArrivalTimeWithInterval: (NSTimeInterval) arrivalAt;

- (NSString *) busSign;
- (void) setBusSign: (NSString *) sign;

- (NSString *) route;
- (void) setRoute: (NSString *) route_name;

- (NSString *) routeId;
- (void) setRouteId: (NSString *) route_id;

- (NSString *) stopId;
- (void) setStopId: (NSString *) stop;

@end
