//
//  BusStop.h
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

//There should be better option than defining such global variables
double UserDefinedLongitudeForComparison;
double UserDefinedLatitudeForComparison;

/**
 * \defgroup gtfsdata GTFS data
 *
 * These classes defines different tansit class that conform to GTFS feed specification.
 */

/*! \brief Bus stop 
 *
 * \ingroup gtfsdata
 */
@interface BusStop : NSObject {
	NSString *stopId;		/*!<Stop id */
	double longtitude;		/*!<Stop longitude */
	double latitude;		/*!<Stop latitude */
	NSString *name;			/*!<Stop name*/
	NSString *description;	/*!<Stop description */
	BOOL     flag;			/*!<flag=YES, a fake stop */
} BusStop;

/** @name Comparison functions for sorting.
 *
 *  These functions compare self with anohter given stop.
 */
//@{
- (NSComparisonResult) compareByLon: (BusStop *)aStop;
- (NSComparisonResult) compareByLat: (BusStop *)aStop;
- (NSComparisonResult) compareById: (BusStop *)aStop;
- (NSComparisonResult) compareByDistance: (BusStop *)aStop;
//@}

@property (retain) NSString *stopId;
@property double longtitude;
@property double latitude;
@property (retain) NSString *name;
@property (retain) NSString *description;
@property BOOL flag;

@end

