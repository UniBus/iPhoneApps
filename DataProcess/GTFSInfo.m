//
//  GTFSInfo.m
//  DataProcess
//
//  Created by Zhenwang Yao on 29/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "GTFSInfo.h"
#import "parseCSV.h"
#import <sqlite3.h>

int columnCityId		= 0;
int columnCityName		= 1;
int columnCityState		= 2;
int columnCityCountry	= 3;
int columnCityWebsite	= 4;
int columnCityDbName	= 5;
int columnCityUpdate	= 6;
int columnCityLocal		= 7;

int saveCitiesToSqlite(NSArray *citiess, NSString *dbName);

int convertCitiesToSQLite(NSString *cityFile, NSString *dbName)
{
	NSMutableArray *citiesInCSV;
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:cityFile] == NO)
	{
		NSLog(@"Faile to open file: %@", cityFile);
		[parser release];
		return -1;
	}
	
	citiesInCSV = [[parser parseFile] retain];
	[citiesInCSV removeObjectAtIndex:0];
	saveCitiesToSqlite(citiesInCSV, dbName);
	
	[parser closeFile];	
	[parser release];
	
	return [citiesInCSV count] - 1;
}

int saveCitiesToSqlite(NSArray *cities, NSString *dbName)
{
	sqlite3 *database;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) 
	{
		NSString *sql = @"DROP TABLE IF EXISTS cities";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@", 
			   @"CREATE TABLE IF NOT EXISTS cities (",
			   @"id CHAR(32) PRIMARY KEY, ",
			   @"name CHAR(32), ",
			   @"state CHAR(32), ",
			   @"country CHAR(32), ",
			   @"website CHAR(128), ",
			   @"dbname CHAR(128), ",
			   @"lastupdate CHAR(16), ",
			   @"local INTEGER",
			   @")"];
		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
        for (NSArray *aCity in cities)
		{
			sql =[NSString stringWithFormat:@"INSERT INTO cities (id, name, state, country, website, dbname, lastupdate, local) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d)",
				  [[aCity objectAtIndex:columnCityId] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], 
				  [[aCity objectAtIndex:columnCityName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], 
				  [[aCity objectAtIndex:columnCityState] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
				  [[aCity objectAtIndex:columnCityCountry] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
				  [[aCity objectAtIndex:columnCityWebsite] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
				  [[aCity objectAtIndex:columnCityDbName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
				  [[aCity objectAtIndex:columnCityUpdate] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
				  [[aCity objectAtIndex:columnCityLocal] intValue]
				];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
				NSLog(@"Error: %s", sqlite3_errmsg(database));
			// "Finalize" the statement - releases the resources associated with the statement.			
		}
		
		NSLog(@"Insert %d cities into database", [cities count]);
	} 
	
	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);
	
	return YES;
}
