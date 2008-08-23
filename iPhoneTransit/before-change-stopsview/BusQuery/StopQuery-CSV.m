//
//  StopQuery-CSV.m
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopQuery-CSV.h"
#import "parseCSV.h"
#import "BusStop.h"

#define CSV_COL_STOP_ID		0
#define CSV_COL_STOP_NAME	1
#define CSV_COL_STOP_LAT	3
#define CSV_COL_STOP_LON	4
#define CSV_COL_STOP_POS	9
#define CSV_COL_STOP_DIR	10

@implementation StopQuery_CSV

+ (id) initWithFile:(NSString *) stopFile
{
	StopQuery_CSV *newObj;
	newObj = [[StopQuery_CSV alloc] init];
	if (newObj == nil)
		return nil;
	
	if ([newObj openStopFile:stopFile])
		return newObj;
	
	[newObj release];
	NSLog(@"%d", errno);
	return nil;
}

#pragma mark CSV file parseing function
- (BusStop *) getARawStop: (int) index
{
	BusStop *aStop = [[BusStop alloc] init];
	NSMutableArray *stopString = [rawStops objectAtIndex:index];
	
	aStop.stopId = [[stopString objectAtIndex:CSV_COL_STOP_ID] intValue];
	aStop.longtitude = [[stopString objectAtIndex:CSV_COL_STOP_LON] doubleValue];
	aStop.latitude = [[stopString objectAtIndex:CSV_COL_STOP_LAT] doubleValue];
	aStop.name = [stopString objectAtIndex:CSV_COL_STOP_NAME]; // I didn't retain it here!!	
	aStop.position = [stopString objectAtIndex:CSV_COL_STOP_POS];
	aStop.direction = [stopString objectAtIndex:CSV_COL_STOP_DIR]; 
	
	[aStop autorelease];
	return aStop;
}

- (void) preprocess
{
	if ([rawStops count] < 2)
		return;
	
	BusStop *aStop = [self getARawStop:1];
	[sortedStops addObject:aStop];
	
	for (int i=2; i<[rawStops count]; i++)
	{
		aStop = [self getARawStop:i];
		[sortedStops addObject:aStop];
		//[self registerStop:&(aStop)];
	}
	
	[rawStops removeAllObjects];
	[rawStops release];
	rawStops = nil;
	[sortedStops sortUsingSelector:@selector(compareById:)];
}

#pragma mark File Open/Close
- (BOOL) openStopFile: (NSString *)stopFile
{
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:stopFile] == YES)
	{
		[rawStops release]; 
		rawStops = [[parser parseFile] retain];
		[self preprocess];
		[parser closeFile];	
		[parser release];
		return YES;
	}

	[parser release];
	return NO;
}

- (BOOL) saveStopFile: (NSString *)stopFile
{
	return [NSKeyedArchiver archiveRootObject:sortedStops toFile:stopFile];

/*
	NSOutputStream *oStream=[[NSOutputStream alloc] outputStreamToFileAtPath:stopFile append:NO]; 
	[oStream open]; 
	for (BusStop *aStop in sortedStops)
	{
		//
	}
	[oStream close];
	[oStream release];
*/	
}


































@end
