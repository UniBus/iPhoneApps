//
//  Upgrade.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TransitApp.h"
#import "Upgrade.h"
#import "GTFSCity.h"

NSString * const desiredDbVersion = @"1.2";

BOOL upgradeNeeded(NSString *currengDb)
{
	sqlite3 *database;
    if (sqlite3_open([currengDb UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	NSString *currentDbVersion = @"1.0";
	NSString *sql = @"SELECT parameter, value FROM dbinfo WHERE parameter='db_version'";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			currentDbVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		}
	}
	else
		NSLog(@"There must be no dbinfo, use default verion, which is v1.0");			
	sqlite3_finalize(statement);
	
	sqlite3_close(database);

	return (![currentDbVersion isEqualToString:desiredDbVersion]);
}

void resetCurrentCity(NSString *newDb)
{
	sqlite3 *database;
	if (sqlite3_open([newDb UTF8String], &database) != SQLITE_OK) 
		NSLog(NO, @"Open database Error!");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSString *selectedCity = [defaults objectForKey:UserCurrentCity];
	NSArray *cityNameComps = [selectedCity componentsSeparatedByString:@", "];
	assert([cityNameComps count] == 3);
	
	// (id, name, state, country, website, dbname, lastupdate, local)
	NSString *sql = [NSString stringWithFormat:@"SELECT id, name, state, country, website, dbname FROM cities WHERE name='%@' AND state='%@' AND country='%@'", 
					 [cityNameComps objectAtIndex:0],
					 [cityNameComps objectAtIndex:1],
					 [cityNameComps objectAtIndex:2]
					 ];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			GTFS_City *city = [[GTFS_City alloc] init];
			
			// All properties are (retain)
			city.cid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			city.cname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			city.cstate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			city.country = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			city.website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			city.dbname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			
			[defaults setObject:[NSString stringWithFormat:@"%@, %@, %@", city.cname, city.cstate, city.country] forKey:UserCurrentCity];
			[defaults setObject:city.cid forKey:UserCurrentCityId];
			[defaults setObject:city.website forKey:UserCurrentWebPrefix];
			[defaults setObject:city.dbname forKey:USerCurrentDatabase];
		}
		else
			NSLog(@"For some reason, couldn't find the city");
	}
	else
		NSLog(@"Error in resetCurrentCity: %s", sqlite3_errmsg(database));		
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
}

#pragma mark Upgrade $(city).sqlite database
BOOL upgradeFavorites(NSString *currentDb, NSString *newDb)
{
	sqlite3 *destDb;
	if (sqlite3_open([newDb UTF8String], &destDb) != SQLITE_OK) 
		return NO;
	
	BOOL result = YES;
	NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS src", currentDb];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorites "
				"SELECT favorites.stop_id, routes.route_id, routes.route_short_name as route_name, routes.route_long_name as bus_sign "
				"FROM routes, src.favorites "
				"WHERE routes.route_short_name=src.favorites.route_id"
			];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	
	sqlite3_close(destDb);	
	return result;	
}

BOOL copyDatabase(NSString *currentDb, NSString *newDb)
{
	//Copy database file to local directory.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	
	//NSAssert1([fileManager fileExistsAtPath:currengDb], @"Database do not exist")

	if ([fileManager fileExistsAtPath:currentDb])
	{
		if (![fileManager removeItemAtPath:currentDb error:&error])
		{
			NSLog(@"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
			return NO;
		}
		NSLog(@"Delete file: %@", currentDb);
	}
	
	if (![fileManager copyItemAtPath:newDb toPath:currentDb error:&error])	
	{
		NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return NO;
	}	
	NSLog(@"Copy database to %@", currentDb);
	
	return YES;
}

//For upgrade(currentDb, newDb), 3 steps:
//   (1) copyDatabase(tmpDbPathForUpgrade, newDb)
//                  copy newDb(=db in bundle) to a upgrade directory
//   (2) upgrade(currentDb, tmpDbPathForUpgrade)
//                  upgrade (db in upgrade dir) to reflect changes in currentDb (=db in use);
//   (3) copyDatabase(currentDb, tmpDbPathForUpgrade)
//                  copy (db in upgrade dir) to replace currentDb
//
BOOL upgrade(NSString *currentDb, NSString *newDb)
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *homeDirectory = [paths objectAtIndex:0];

	//Create $HOME/Upgrade if the directory does not exist.
	NSString *upgradePath = [homeDirectory stringByAppendingPathComponent:@"Upgrade"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:upgradePath])
	{
		if ([fileManager createDirectoryAtPath:upgradePath attributes:nil])
			NSLog(@"Create path: %@", upgradePath);
		else
			NSLog(@"Failed to create path: %@", upgradePath);
	}

	NSArray *dbPathComponets = [newDb pathComponents];
	NSString *dbName = [dbPathComponets objectAtIndex:[dbPathComponets count]-1];
	NSString *tmpDbPathForUpgrade = [upgradePath stringByAppendingPathComponent:dbName];
	copyDatabase(tmpDbPathForUpgrade, newDb);

	if (upgradeFavorites(currentDb, tmpDbPathForUpgrade) == NO)
		return NO;
	
	return copyDatabase(currentDb, tmpDbPathForUpgrade);
}

#pragma mark Upgrade GTFS_info database
BOOL upgradeCities(NSString *currentDb, NSString *newDb)
{
	sqlite3 *destDb;
	if (sqlite3_open([newDb UTF8String], &destDb) != SQLITE_OK) 
		return NO;
	
	BOOL result = YES;
	NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS src", currentDb];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	
	//This is only valid for updating from V1.1 to V1.2
	sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO "
		   "cities(id, name, state, country, website, dbname, lastupdate, local) "
		   "SELECT * FROM src.cities "
		   ];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	sql = [NSString stringWithFormat:@"UPDATE cities SET oldbdownloaded=0"];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	
	sqlite3_close(destDb);	
	return result;	
}

BOOL upgradeGTFS(NSString *currentDb, NSString *newDb)
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *homeDirectory = [paths objectAtIndex:0];
	
	//Create $HOME/Upgrade if the directory does not exist.
	NSString *upgradePath = [homeDirectory stringByAppendingPathComponent:@"Upgrade"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:upgradePath])
	{
		if ([fileManager createDirectoryAtPath:upgradePath attributes:nil])
			NSLog(@"Create path: %@", upgradePath);
		else
			NSLog(@"Failed to create path: %@", upgradePath);
	}
	
	NSArray *dbPathComponets = [newDb pathComponents];
	NSString *dbName = [dbPathComponets objectAtIndex:[dbPathComponets count]-1];
	NSString *tmpDbPathForUpgrade = [upgradePath stringByAppendingPathComponent:dbName];
	copyDatabase(tmpDbPathForUpgrade, newDb);
	
	if (upgradeCities(currentDb, tmpDbPathForUpgrade) == NO)
		return NO;
	
	return copyDatabase(currentDb, tmpDbPathForUpgrade);	
}




