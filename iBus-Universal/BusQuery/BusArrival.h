//
//  BusArrival.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
//#import <UIKit/UIKit.h>

///Bus arrival
/*! 
 * \todo The setup of this class should be similar to BusStop, use properties instead of functions.
 *
 * \ingroup gtfsdata 
 */
@interface BusArrival : NSObject {
	NSString	*stopId;		/*!<stop id*/
	NSString	*arrivalTime;	/*!< arrival time*/
	NSString	*busSign;		/*!<bus sign*/
	NSString	*route;			/*!<route short name*/
	NSString	*routeId;		/*!<route id*/
	NSString	*direction;		/*!<route long name*/
	BOOL		departed;		/*!<if departed or not*/
	BOOL		flag;			/*!<flag=YES, a fake arrival*/
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

- (NSString *) direction;
- (void) setDirection: (NSString *) dir;

- (NSString *) routeId;
- (void) setRouteId: (NSString *) route_id;

- (NSString *) stopId;
- (void) setStopId: (NSString *) stop;

@end
