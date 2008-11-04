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

int columnRouteId = -1;
int columnRouteShortName = -1;
int columnRouteLongName = -1;

void getRoutesColumIndexes(NSArray *header);
int saveRoutesToSqlite(NSArray *routes, NSString *dbName);

int convertRoutesToSQLite(NSString *routeFile, NSString *dbName)
{
	NSMutableArray *routesInCSV;
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:routeFile] == NO)
	{
		NSLog(@"Faile to open file: %@", routeFile);
		[parser release];
		return -1;
	}

	routesInCSV = [[parser parseFile] retain];
	
	getRoutesColumIndexes([routesInCSV objectAtIndex:0]);
	[routesInCSV removeObjectAtIndex:0];
	saveRoutesToSqlite(routesInCSV, dbName);
	
	[parser closeFile];	
	[parser release];
	
	return [routesInCSV count] - 1;
}


void getRoutesColumIndexes(NSArray *header)
{
	for (int i=0; i<[header count]; i++)
	{
		NSString *column = [[header objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([column isEqualToString:@"route_id"])
			columnRouteId = i;
		else if ([column isEqualToString:@"route_short_name"])
			columnRouteShortName = i;
		else if ([column isEqualToString:@"route_long_name"])
			columnRouteLongName = i;
	}
	
	if (columnRouteId==-1)
		NSLog(@"Couldn't get Route ID column");	
	if (columnRouteShortName==-1)
		NSLog(@"Couldn't get Route short name column");
	if (columnRouteLongName==-1)
		NSLog(@"Couldn't get Route long name column");
}

int saveRoutesToSqlite(NSArray *routes, NSString *dbName)
{
	sqlite3 *database;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) 
	{
		NSString *sql = @"DROP TABLE IF EXISTS routes";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", 
			   @"CREATE TABLE routes (",
			   @"route_id CHAR(16) PRIMARY KEY, ",
			   @"route_short_name CHAR(64), ",
			   @"route_long_name CHAR(128)",
			   @")"];
		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
        for (NSArray *aRoute in routes)
		{
			sql =[NSString stringWithFormat:@"INSERT INTO routes (route_id, route_short_name, route_long_name) VALUES (\"%@\", \"%@\", \"%@\")",
				  [aRoute objectAtIndex:columnRouteId], [aRoute objectAtIndex:columnRouteShortName], [aRoute objectAtIndex:columnRouteLongName]];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
				NSLog(@"Error: %s", sqlite3_errmsg(database));
			// "Finalize" the statement - releases the resources associated with the statement.
			
			//NSLog(@"%@", sql);
		}
	} 
	
	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);
	
	return YES;
}
