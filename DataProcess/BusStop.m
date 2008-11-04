//
//  BusRoute.m
//  DataProcess
//
//  Created by Zhenwang Yao on 28/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "BusRoute.h"
#import "parseCSV.h"
#import <sqlite3.h>

int columnStopId = -1;
int columnStopName = -1;
int columnStopLat = -1;
int columnStopLon = -1;
int columnStopPos = -1;
int columnStopDir = -1;
int columnStopDesc = -1;

void getStopsColumIndexes(NSArray *header);
int saveStopsToSqlite(NSArray *routes, NSString *dbName);

int convertStopsToSQLite(NSString *stopFile, NSString *dbName)
{
	NSMutableArray *stopsInCSV;
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:stopFile] == NO)
	{
		NSLog(@"Faile to open file: %@", stopFile);
		[parser release];
		return -1;
	}

	stopsInCSV = [[parser parseFile] retain];
	getStopsColumIndexes([stopsInCSV objectAtIndex:0]);
	[stopsInCSV removeObjectAtIndex:0];
	saveStopsToSqlite(stopsInCSV, dbName);
		
	[parser closeFile];	
	[parser release];
	
	return [stopsInCSV count] - 1;
}


void getStopsColumIndexes(NSArray *header)
{
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
	
	if (columnStopId == -1)
		NSLog(@"Couldn't get Stop ID column");
	if (columnStopName == -1)
		NSLog( @"Couldn't get Stop Name column");
	if (columnStopLon == -1)
		NSLog(@"Couldn't get Stop Lon column");
	if (columnStopLat == -1)
		NSLog(@"Couldn't get Stop Lat column");
}

int saveStopsToSqlite(NSArray *routes, NSString *dbName)
{
	sqlite3 *database;
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
		
        for (NSArray *stopString in routes)
		{
			NSString *stop_description;
			if (columnStopDesc != -1)
				stop_description = [stopString objectAtIndex:columnStopDesc];
			else if ((columnStopPos != -1) && (columnStopDir != -1))
				stop_description = [NSString stringWithFormat:@"%@, %@",
									 [stopString objectAtIndex:columnStopPos],
									 [stopString objectAtIndex:columnStopDir]];
			else
				stop_description = @"";
			
			if ([[stop_description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) 
				stop_description = [stopString objectAtIndex:columnStopName];
			
			sql =[NSString stringWithFormat:@"INSERT INTO stops (stop_id, stop_name, stop_lat, stop_lon, stop_desc) VALUES (\"%@\", \"%@\", %f, %f, \"%@\")",				
				  [stopString objectAtIndex:columnStopId], 
				  [stopString objectAtIndex:columnStopName], 
				  [[stopString objectAtIndex:columnStopLat] doubleValue], 
				  [[stopString objectAtIndex:columnStopLon] doubleValue],
				  stop_description];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
				NSLog(@"Error: %s", sqlite3_errmsg(database));
			// "Finalize" the statement - releases the resources associated with the statement.

		}
	} 
	
	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);
	
	return YES;
}
