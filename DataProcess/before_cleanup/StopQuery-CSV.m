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
#import <sqlite3.h>

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
	
	/*
	aStop.stopId = [[stopString objectAtIndex:CSV_COL_STOP_ID] intValue];
	aStop.longtitude = [[stopString objectAtIndex:CSV_COL_STOP_LON] doubleValue];
	aStop.latitude = [[stopString objectAtIndex:CSV_COL_STOP_LAT] doubleValue];
	aStop.name = [stopString objectAtIndex:CSV_COL_STOP_NAME]; // I didn't retain it here!!	
	aStop.description = [NSString stringWithFormat:@"%@, %@",
						[stopString objectAtIndex:CSV_COL_STOP_POS],
						[stopString objectAtIndex:CSV_COL_STOP_DIR]]; 
	*/
	
	aStop.stopId = [stopString objectAtIndex:columnStopId];
	aStop.longtitude = [[stopString objectAtIndex:columnStopLon] doubleValue];
	aStop.latitude = [[stopString objectAtIndex:columnStopLat] doubleValue];
	aStop.name = [stopString objectAtIndex:columnStopName]; // I didn't retain it here!!	
	if (columnStopDesc != -1)
		aStop.description = [stopString objectAtIndex:columnStopDesc];
	else if ((columnStopPos != -1) && (columnStopDir != -1))
		aStop.description = [NSString stringWithFormat:@"%@, %@",
						 [stopString objectAtIndex:columnStopPos],
						 [stopString objectAtIndex:columnStopDir]];
	else
		aStop.description = @"";
	
	[aStop autorelease];
	return aStop;
}

- (void) getColumIndexes
{
	NSArray *header = [rawStops objectAtIndex:0];
	for (int i=0; i<[header count]; i++)
	{
		NSString *column = [[header objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([column isEqualToString:@"stop_id"])
			columnStopId = i;
		else if ([column isEqualToString:@"stop_name"])
			columnStopName = i;
		else if ([column isEqualToString:@"stop_desc"])
			columnStopDesc = i;
		else if ([column isEqualToString:@"stop_lon"])
			columnStopLon = i;
		else if ([column isEqualToString:@"stop_lat"])
			columnStopLat = i;
		else if ([column isEqualToString:@"position"])
			columnStopPos = i;
		else if ([column isEqualToString:@"direction"])
			columnStopDir = i;
	}
	
	NSAssert(columnStopId != -1, @"Couldn't get Stop ID column");
	NSAssert(columnStopName != -1, @"Couldn't get Stop ID column");
	NSAssert(columnStopLon != -1, @"Couldn't get Stop ID column");
	NSAssert(columnStopLat != -1, @"Couldn't get Stop ID column");
}
			
- (void) preprocess
{
	if ([rawStops count] < 2)
		return;
	
	//BusStop *aStop = [self getARawStop:1];
	//[sortedStops addObject:aStop];
	
	[self getColumIndexes];
	
	for (int i=1; i<[rawStops count]; i++)
	{
		BusStop *aStop = [self getARawStop:i];
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
	columnStopId = -1;
	columnStopName = -1;
	columnStopLat = -1;
	columnStopLon = -1;
	columnStopPos = -1;
	columnStopDir = -1;
	columnStopDesc = -1;
	
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

#pragma mark SQLite Database

- (BOOL) saveToSQLiteDatabase: (NSString *)dbName
{
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) 
	{
		NSString *sql = @"DROP TABLE IF EXISTS stops";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));

		sql = @"DROP INDEX IF EXISTS stopsIndex";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));

		sql = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", 
			   @"CREATE TABLE stops (",
			   @"stop_id CHAR(16) PRIMARY KEY, ",
			   @"stop_name CHAR(64), ",
			   @"stop_lat DOUBLE, ",
			   @"stop_lon DOUBLE, ",
			   @"stop_desc CHAR(128) ",
			   @")"];
		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
        for (BusStop *aStop in sortedStops)
		{
			sql =[NSString stringWithFormat:@"INSERT INTO stops (stop_id, stop_name, stop_lat, stop_lon, stop_desc) VALUES (\"%@\", \"%@\", %f, %f, \"%@\")",
							aStop.stopId, aStop.name, aStop.latitude, aStop.longtitude, aStop.description];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
				NSLog(@"Error: %s", sqlite3_errmsg(database));
				// "Finalize" the statement - releases the resources associated with the statement.

			//NSLog(@"%@", sql);
		}

		//NSLog(@"%@", sql);
		sql = @"CREATE INDEX IF NOT EXISTS stopsIndex ON stops (stop_id, stop_lat, stop_lon)";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		
		sql = @"DROP TABLE IF EXISTS favorites";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", 
			   @"CREATE TABLE favorites (",
			   @"stop_id CHAR(16), ",
			   @"route_id CHAR(32), ",
			   @"bus_sign CHAR(128)",
			   @")"];		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));		
    } 
	
	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);

	return YES;
}


































@end
