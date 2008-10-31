//
//  StopQuery-CSV.m
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopQuery.h"
#import "BusStop.h"
#import "General.h"

#define CSV_COL_STOP_ID		0
#define CSV_COL_STOP_NAME	1
#define CSV_COL_STOP_LAT	3
#define CSV_COL_STOP_LON	4
#define CSV_COL_STOP_POS	9
#define CSV_COL_STOP_DIR	10

@implementation StopQuery

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

- (void) dealloc
{
	sqlite3_close(database);
	[super dealloc];
}

#pragma mark File Open/Close
- (BOOL) openStopFile: (NSString *)stopFile
{
    if (sqlite3_open([stopFile UTF8String], &database) == SQLITE_OK) 
		return YES;
	
	NSLog(@"Error: %s", sqlite3_errmsg(database));
	return NO;
}

#pragma mark Query operations

- (BusStop *) getRandomStop
{
	BusStop *aStop = nil;
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops ORDER BY random()	LIMIT 1"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			[aStop autorelease];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return aStop;
}

- (BusStop *) stopOfId: (NSString *) anId
{
	BusStop *aStop = nil;
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops WHERE stop_id=\"%@\"", anId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return [aStop autorelease];
}

- (NSArray *) queryStopWithPosition:(CGPoint) pos within:(double)distInKm
{
	NSMutableArray *results = [NSMutableArray array];
	float deltaLatForTheDist = deltaLat(pos.y, pos.x, distInKm);
	float deltaLonForTheDist = deltaLon(pos.y, pos.x, distInKm);
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops WHERE stop_lon>%f AND stop_lon<%f AND stop_lat>%f AND stop_lat<%f", 
					pos.x-deltaLatForTheDist, pos.x+deltaLatForTheDist,  pos.y-deltaLonForTheDist, pos.y+deltaLonForTheDist];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusStop *aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			
			if (distance(aStop.latitude, aStop.longtitude,  pos.y,  pos.x) < distInKm)
				[results addObject:aStop];
			[aStop release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	
	UserDefinedLatitudeForComparison = pos.y;
	UserDefinedLongitudeForComparison = pos.x;
	[results sortUsingSelector:@selector(compareByDistance:)];
	return results;
}

- (NSArray *) queryStopWithName:(NSString *) stopName
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops WHERE stop_name LIKE \"%c%@%c\"", '%', stopName, '%'];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusStop *aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			
			[results addObject:aStop];
			[aStop release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return results;
}

- (NSArray *) queryStopWithNames:(NSArray *) stopNames
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *queryString = @"";
	for (NSString *aKey in stopNames)
	{
		if ([queryString isEqualToString:@""])
			queryString = [NSString stringWithFormat:@"stop_name LIKE \"%c%@%c\" ", '%', aKey, '%'];
		else
			queryString = [NSString stringWithFormat:@"%@ AND stop_name LIKE \"%c%@%c\" ", queryString, '%', aKey, '%'];
	}
	
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops WHERE %@", queryString];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusStop *aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			
			[results addObject:aStop];
			[aStop release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return results;
}

- (NSArray *) queryStopWithIds:(NSArray *) stopIds
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *queryString = @"";
	for (NSString *aKey in stopIds)
	{
		if ([queryString isEqualToString:@""])
			queryString = [NSString stringWithFormat:@"stop_id=\"%@\" ", aKey];
		else
			queryString = [NSString stringWithFormat:@"%@ OR stop_id=\"%@\" ", queryString, aKey];
	}
	
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lon, stop_lat, stop_desc FROM stops WHERE %@", queryString];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusStop *aStop = [[BusStop alloc] init];
			aStop.stopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aStop.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aStop.longtitude = sqlite3_column_double(statement, 2);
			aStop.latitude = sqlite3_column_double(statement, 3);
			aStop.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
				
			[results addObject:aStop];
			[aStop release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return results;
}

@end
