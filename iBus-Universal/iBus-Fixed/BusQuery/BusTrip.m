//
//  BusTrip.m
//  TripQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "BusTrip.h"
#import "General.h"

@implementation BusTrip
@synthesize tripId, headsign, stops, direction, routeId;

#pragma mark Comparison Tools

- (void) dealloc
{
	[tripId release];
	[headsign release];
	[stops release];
	[direction release];
	[routeId release];
	[super dealloc];
}

@end
