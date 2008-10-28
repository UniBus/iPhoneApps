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
	BOOL departed;
	BOOL flag; 
}

@property BOOL flag;
@property BOOL departed;
@property (assign) NSString* stopId;

- (NSComparisonResult) compare: (BusArrival *)avl;

- (NSString *) arrivalTime;
- (void) setArrivalTime: (NSString *) arrivalAt;
- (void) setArrivalTimeWithInterval: (NSTimeInterval) arrivalAt;

- (NSString *) busSign;
- (void) setBusSign: (NSString *) sign;

- (NSString *) route;
- (void) setRoute: (NSString *) route_name;

@end
