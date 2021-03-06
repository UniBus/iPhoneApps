//
//  BusRoute.h
//  RouteQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

///Bus route
/*!
 * \ingroup gtfsdata 
 */
@interface BusRoute : NSObject {
	NSString *routeId;
	NSString *name;
	NSString *description;
	NSInteger type;
	BOOL     flag;
} BusRoute;

@property (retain) NSString *routeId;
@property (retain) NSString *name;
@property (retain) NSString *description;
@property NSInteger type;
@property BOOL flag;

@end

