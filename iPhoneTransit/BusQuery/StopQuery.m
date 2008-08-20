//
//  StopQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopQuery.h"
#import "parseCSV.h"
#import "General.h"

#define COL_STOP_ID		0
#define COL_STOP_NAME	1
#define COL_STOP_LAT	3
#define COL_STOP_LON	4
#define COL_STOP_POS	9
#define COL_STOP_DIR	10

@interface StopQuery () 
- (void) preprocess;
@end

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

#pragma mark Property Setters and Getters

- (void) setStops:(NSMutableArray *)newStops
{
	[rawStops release];
	rawStops = [newStops retain];
	[self preprocess];
}

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

#pragma mark Stops Parsing
- (BOOL) openStopFile: (NSString *)stopFile
{
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:stopFile] == YES)
	{
		[self setStops:[parser parseFile]];
		[parser closeFile];	
		[parser release];
		return YES;
	}
	[parser release];
	return NO;
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

- (BusStop *) getARawStop: (int) index
{
	BusStop *aStop = [[BusStop alloc] init];
	NSMutableArray *stopString = [rawStops objectAtIndex:index];
	
	aStop.stopId = [[stopString objectAtIndex:COL_STOP_ID] intValue];
	aStop.longtitude = [[stopString objectAtIndex:COL_STOP_LON] floatValue];
	aStop.latitude = [[stopString objectAtIndex:COL_STOP_LAT] floatValue];
	aStop.name = [stopString objectAtIndex:COL_STOP_NAME]; // I didn't retain it here!!	
	aStop.position = [stopString objectAtIndex:COL_STOP_POS]; // I didn't retain it here!!	
	aStop.direction = [stopString objectAtIndex:COL_STOP_DIR]; // I didn't retain it here!!	
	
	[aStop autorelease];
	return aStop;
}

- (void) preprocess
{
	if ([rawStops count] < 2)
		return;
	
	BusStop *aStop = [self getARawStop:1];
	[self registerMinMax:aStop];
	[sortedStops addObject:aStop];
	
	for (int i=2; i<[rawStops count]; i++)
	{
		aStop = [self getARawStop:i];
		[self registerMinMax:aStop];
		[sortedStops addObject:aStop];
		//[self registerStop:&(aStop)];
	}
	
	[rawStops removeAllObjects];
	[rawStops release];
	rawStops = nil;
	[sortedStops sortUsingSelector:@selector(compareByLon:)];
}

#pragma mark Stops Querying

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
	
	/*
	//The sortedStops have been sorted by Lon, (by default)
	int lowerIndex_l = 0; 
	int lowerIndex_u = ([sortedStops count] - 1)/2;
	int upperIndex_l = lowerIndex_u; 
	int upperIndex_u = [sortedStops count] - 1;
	
	int lowerIndex = (lowerIndex_l + lowerIndex_u)/2;
	int upperIndex = (upperIndex_l + upperIndex_u)/2;
	
	BusStop *aStop;
	double distanceInBetween;
	while (lowerIndex != lowerIndex_l)
	{
		aStop = [self stopAtIndex:lowerIndex];
		distanceInBetween = distance(userLat, userLon, userLat, [aStop longtitude]); //pay attention here!
						// I am comparing (userLat, userLon) and (userLat, [aStop longitude])
		if (distanceInBetween < distanceThreshold)
			lowerIndex_u = lowerIndex;
		else
			lowerIndex_l = lowerIndex;
		
		lowerIndex = (lowerIndex_l + lowerIndex_u) / 2;
	};

	while (upperIndex != upperIndex_u)
	{
		aStop = [self stopAtIndex:upperIndex];
		distanceInBetween = distance(userLat, userLon, userLat, [aStop longtitude]); //pay attention here!
		// I am comparing (userLat, userLon) and (userLat, [aStop longitude])
		if (distanceInBetween < distanceThreshold)
			upperIndex_l = upperIndex;
		else
			upperIndex_u = upperIndex;
		
		upperIndex = (upperIndex_l + upperIndex_u) / 2;
	};
	
	NSMutableArray *stopInRightLonRange = [[NSMutableArray alloc] init];
	[stopInRightLonRange setArray: [sortedStops objectsAtIndexes:
										   [NSIndexSet indexSetWithIndexesInRange:
											NSMakeRange(lowerIndex, upperIndex-lowerIndex+1)]]];
	[stopInRightLonRange sortUsingSelector:@selector(compareByLat:)];
	
	
	
	//The sortedStops have been sorted by Lon, (by default)
	lowerIndex_l = 0; 
	lowerIndex_u = ([stopInRightLonRange count] - 1)/2;
	upperIndex_l = lowerIndex_u; 
	upperIndex_u = [stopInRightLonRange count] - 1;
	
	lowerIndex = (lowerIndex_l + lowerIndex_u)/2;
	upperIndex = (upperIndex_l + upperIndex_u)/2;
	
	while (lowerIndex != lowerIndex_l)
	{
		aStop = [stopInRightLonRange objectAtIndex:lowerIndex];
		distanceInBetween = distance(userLat, userLon, [aStop latitude], userLon); //pay attention here!
		// I am comparing (userLat, userLon) and ([aStop latitude], userLon)
		if (distanceInBetween < distanceThreshold)
			lowerIndex_u = lowerIndex;
		else
			lowerIndex_l = lowerIndex;
		
		lowerIndex = (lowerIndex_l + lowerIndex_u) / 2;
	};
	
	while (upperIndex != upperIndex_u)
	{
		aStop = [stopInRightLonRange objectAtIndex:upperIndex];
		distanceInBetween = distance(userLat, userLon, [aStop latitude], userLon); //pay attention here!
		// I am comparing (userLat, userLon) and ([aStop latitude], userLon)
		if (distanceInBetween < distanceThreshold)
			upperIndex_l = upperIndex;
		else
			upperIndex_u = upperIndex;
		
		upperIndex = (upperIndex_l + upperIndex_u) / 2;
	};
	
	NSMutableArray *stopInRange = [[NSMutableArray alloc] init];
	[stopInRange setArray: [stopInRightLonRange objectsAtIndexes:
									[NSIndexSet indexSetWithIndexesInRange:
									 NSMakeRange(lowerIndex, upperIndex-lowerIndex+1)]]];
	[stopInRightLonRange release];
	UserDefinedLatitudeForComparison = userLat;
	UserDefinedLongitudeForComparison = userLon;
	[stopInRange sortUsingSelector:@selector(compareByDistance:)];
	
	//By now 
	//The sortedStops have been sorted by Lon, (by default)
	upperIndex_l = 0; 
	upperIndex_u = [stopInRange count] - 1;
	upperIndex = (upperIndex_l + upperIndex_u)/2;	
	while (upperIndex != upperIndex_u)
	{
		aStop = [stopInRange objectAtIndex:upperIndex];
		distanceInBetween = distance(userLat, userLon, [aStop latitude], userLon); //pay attention here!
		// I am comparing (userLat, userLon) and ([aStop latitude], userLon)
		if (distanceInBetween < distanceThreshold)
			upperIndex_l = upperIndex;
		else
			upperIndex_u = upperIndex;
		
		upperIndex = (upperIndex_l + upperIndex_u) / 2;
	};
	[stopInRange removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(upperIndex+1, [stopInRange count]-upperIndex-1)]];
	
	return stopInRange;
	 */
}


@end

