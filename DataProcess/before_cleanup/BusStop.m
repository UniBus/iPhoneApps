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

#define  Stop_Key_ID     @"ID"
#define  Stop_Key_LON    @"LON"
#define  Stop_Key_LAT    @"LAT"
#define  Stop_Key_NAME   @"NAME"
#define  Stop_Key_DES    @"Description"

@implementation BusStop
@synthesize stopId, latitude, longtitude, name, description, flag;

#pragma mark Comparison Tools

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

- (void) dealloc
{
	[name release];
	[description release];
	[super dealloc];
}

#pragma mark Archiver/UnArchiver Functions

- (id) initWithCoder: (NSCoder *) coder
{
	[super init];
	[name autorelease];
	[description autorelease];
	
	stopId = [[coder decodeObjectForKey:Stop_Key_ID] retain];
	longtitude = [coder decodeDoubleForKey:Stop_Key_LON];
	latitude = [coder decodeDoubleForKey:Stop_Key_LAT];
	name = [[coder decodeObjectForKey:Stop_Key_NAME] retain];
	description = [[coder decodeObjectForKey:Stop_Key_DES] retain];
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:stopId forKey:Stop_Key_ID];
	[coder encodeDouble:longtitude forKey:Stop_Key_LON];
	[coder encodeDouble:latitude forKey:Stop_Key_LAT];
	[coder encodeObject:name forKey:Stop_Key_NAME];
	[coder encodeObject:description forKey:Stop_Key_DES];
}

@end
