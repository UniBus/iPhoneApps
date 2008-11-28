//
//  BusRoute.h
//  RouteQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

//There should be better option than defining such global variables

double UserDefinedLongitudeForComparison;
double UserDefinedLatitudeForComparison;

@interface BusRoute : NSObject {
	NSString *routeId;
	NSString *name;
	NSString *description;
	BOOL     flag;
} BusRoute;

@property (retain) NSString *routeId;
@property (retain) NSString *name;
@property (retain) NSString *description;
@property BOOL flag;

@end

