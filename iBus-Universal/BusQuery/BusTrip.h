//
//  BusTrip.h
//  TripQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

/// Bus trip
/*!
 * \ingroup gtfsdata 
 */
@interface BusTrip : NSObject {
	NSString		*tripId;		/*!< trip id */
	NSString        *routeId;		/*!< route id */
	NSString		*headsign;		/*!< head sign */
	NSString		*direction;		/*!< direction */
	NSMutableArray	*stops;			/*!< stops along the trip */
} BusTrip;

@property (retain) NSString *tripId;
@property (retain) NSString *routeId;
@property (retain) NSString *headsign;
@property (retain) NSMutableArray *stops;
@property (retain) NSString *direction;

@end

