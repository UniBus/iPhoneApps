//
//  DBInfo.m
//  DataProcess
//
//  Created by Zhenwang Yao on 28/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"
#import <sqlite3.h>

BOOL addDBInfo(NSString *dbName)
{
	sqlite3 *database;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) 
	{
		NSString *sql = @"DROP TABLE IF EXISTS dbinfo";
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"%@ %@ %@ %@", 
			   @"CREATE TABLE dbinfo (",
			   @"parameter CHAR(32), ",
			   @"value CHAR(32)",
			   @")"];		
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));		
		
		
		sql =[NSString stringWithFormat:@"INSERT INTO dbinfo (parameter, value) VALUES (\"%@\", \"%@\")", @"db_version", @"1.1"];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));		
    } 

	// Even though the open failed, call close to properly clean up resources.
	sqlite3_close(database);
	
	return YES;
}

