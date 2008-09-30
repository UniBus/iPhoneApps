//
//  BusStop.h
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

//There should be better option than defining such global variables

double UserDefinedLongitudeForComparison;
double UserDefinedLatitudeForComparison;

@interface BusStop : NSObject {
	NSString *stopId;
	double longtitude;
	double latitude;
	NSString *name;
	NSString *description;
	BOOL     flag;
} BusStop;

- (NSComparisonResult) compareByLon: (BusStop *)aStop;
- (NSComparisonResult) compareByLat: (BusStop *)aStop;
- (NSComparisonResult) compareById: (BusStop *)aStop;
- (NSComparisonResult) compareByDistance: (BusStop *)aStop;

@property (retain) NSString *stopId;
@property double longtitude;
@property double latitude;
@property (retain) NSString *name;
@property (retain) NSString *description;
@property BOOL flag;

@end

