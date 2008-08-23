//
//  BusStop.m
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BusStop.h"
#import "General.h"

double UserDefinedLongitudeForComparison = 0.;
double UserDefinedLatitudeForComparison = 0.;

@implementation BusStop
@synthesize stopId, latitude, longtitude, name, position, direction;

- (NSComparisonResult) compareById: (BusStop *) aStop
{
	if (stopId < aStop->stopId)
		return NSOrderedAscending;
	else if (stopId > aStop->stopId)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (NSComparisonResult) compareByLat: (BusStop *) aStop
{
	if (latitude < aStop->latitude)
		return NSOrderedAscending;
	else if (latitude > aStop->latitude)
		return NSOrderedDescending;
	else
	{
		if (longtitude < aStop->longtitude)
			return NSOrderedAscending;
		else if (longtitude > aStop->longtitude)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}
}

- (NSComparisonResult) compareByLon: (BusStop *) aStop
{
	if (longtitude < aStop->longtitude)
		return NSOrderedAscending;
	else if (longtitude > aStop->longtitude)
		return NSOrderedDescending;
	else
	{
		if (latitude < aStop->latitude)
			return NSOrderedAscending;
		else if (latitude > aStop->latitude)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}
}

- (NSComparisonResult) compareByDistance: (BusStop *) aStop
{
	double ownDistance = distance(UserDefinedLatitudeForComparison, UserDefinedLongitudeForComparison, latitude, longtitude);
	double stopDistance = distance(UserDefinedLatitudeForComparison, UserDefinedLongitudeForComparison, [aStop latitude], [aStop longtitude]);
	
	if (ownDistance < stopDistance)
		return NSOrderedAscending;
	else if (ownDistance > stopDistance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

@end
