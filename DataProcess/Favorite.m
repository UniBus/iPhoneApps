//
//  Favorite.m
//  DataProcess
//
//  Created by Zhenwang Yao on 28/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"
#import <sqlite3.h>

BOOL addFavoriteTable(NSString *dbName)
{
	sqlite3 *database;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) 
	{
		NSString *sql = @"DROP TABLE IF EXISTS favorites";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", 
			   @"CREATE TABLE favorites (",
			   @"stop_id CHAR(16), ",
			   @"route_id CHAR(32), ",
			   @"route_name CHAR(32), ",
			   @"bus_sign CHAR(128)",
			   @")"];		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));		
    } 
	
	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);
	
	return YES;
}

