//
//  BusTrip.h
//  TripQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>
//#import <Cocoa/Cocoa.h>

//There should be better option than defining such global variables

double UserDefinedLongitudeForComparison;
double UserDefinedLatitudeForComparison;

@interface BusTrip : NSObject {
	NSString		*tripId;
	NSString		*headsign;
	NSInteger		direction;
	NSMutableArray	*stops;
} BusTrip;

@property (retain) NSString *tripId;
@property (retain) NSString *headsign;
@property (retain) NSMutableArray *stops;
@property NSInteger direction;

@end

