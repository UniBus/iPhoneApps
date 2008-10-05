//
//  StopQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopQuery.h"
#import "General.h"

@implementation StopQuery

@synthesize distanceThreshold;

#pragma mark Initialization and Cleanup

+ (id) initWithFile:(NSString *) stopFile
{
	StopQuery *newObj;
	newObj = [[StopQuery alloc] init];
	if (newObj == nil)
		return nil;

	if ([newObj openStopFile:stopFile])
		return newObj;

	[newObj release];
	NSLog(@"%d", errno);
	return nil;
}

- (id) init
{
	[super init];
	
	sortedStops = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	[sortedStops release];
	[super dealloc];
}

#pragma mark Open and Close stop-files
- (BOOL) openStopFile: (NSString *)stopFile
{
	//Need sub-class to implement
	return NO;
}

- (BOOL) saveStopFile: (NSString *)stopFile
{
	return NO;
}

- (BOOL) saveToSQLiteDatabase: (NSString *)dbName
{
	return NO;
}

#pragma mark Property Setters and Getters

- (BusStop *) stopAtIndex: (NSInteger) index
{
	return [sortedStops objectAtIndex:index];
}

- (NSInteger) numberOfStops
{
	return [sortedStops count];
}

- (NSMutableArray *) stops
{
	return sortedStops;
}

- (void) registerMinMax: (BusStop *)aStop
{
	if (aStop.latitude > maxLatitude)
		maxLatitude = aStop.latitude;
	if ((aStop.latitude) < minLatitude)
		minLatitude = aStop.latitude;
	if ((aStop.longtitude) > maxLongtitude)
		maxLongtitude = aStop.longtitude;
	if ((aStop.longtitude) < minLongtitude)
		minLongtitude = aStop.longtitude;
}

#pragma mark Stops Querying

- (BusStop *) stopOfId: (NSString *) anId
{
	[sortedStops sortUsingSelector:@selector(compareById:)];
	
	//By now 
	int upperIndex_l = -1; 
	int upperIndex_u = [sortedStops count] - 1;
	int upperIndex = upperIndex_u/2;	
	BusStop *aStop;
	while (upperIndex != upperIndex_u)
	{
		aStop = [sortedStops objectAtIndex:upperIndex];
		if (aStop.stopId < anId)
			upperIndex_l = upperIndex;
		else
			upperIndex_u = upperIndex;
		
		upperIndex = (upperIndex_l + upperIndex_u + 1) / 2;
	};
	
	if (upperIndex_l == -1)
		return nil;
	else
	{
		BusStop *aStop = [sortedStops objectAtIndex:upperIndex];
		if ([aStop.stopId isEqualToString:anId])
			return aStop;
		
		return nil;
	}
}

- (NSArray *) queryStopWithPosition:(CGPoint) pos within:(double)distInKm
{
	double oldDistanceThreshold = distanceThreshold;
	distanceThreshold = distInKm;
	
	NSArray *result = [self queryStopWithPosition: pos];
	
	distanceThreshold = oldDistanceThreshold;
	return result;
}

- (NSArray *) queryStopWithPosition:(CGPoint) pos
{
	float userLon = pos.x;
	float userLat = pos.y;

	UserDefinedLatitudeForComparison = userLat;
	UserDefinedLongitudeForComparison = userLon;
	[sortedStops sortUsingSelector:@selector(compareByDistance:)];
	
	//By now 
	int upperIndex_l = -1; 
	int upperIndex_u = [sortedStops count] - 1;
	int upperIndex = upperIndex_u/2;	
	BusStop *aStop;
	double distanceInBetween;
	while (upperIndex != upperIndex_u)
	{
		aStop = [sortedStops objectAtIndex:upperIndex];
		distanceInBetween = distance(userLat, userLon, [aStop latitude], [aStop longtitude]); 
		if (distanceInBetween < distanceThreshold)
			upperIndex_l = upperIndex;
		else
			upperIndex_u = upperIndex;
		
		upperIndex = (upperIndex_l + upperIndex_u + 1) / 2;
	};

	if (upperIndex_l == -1)
		return [NSArray array];
	else
		return [sortedStops objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, upperIndex)]];	
}


@end

