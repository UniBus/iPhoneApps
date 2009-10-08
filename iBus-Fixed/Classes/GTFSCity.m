//
//  GTFSCity.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 25/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "GTFSCity.h"
#import "TransitApp.h"

int totalNumberOfCitiesInGTFS()
{
	int number = 0;
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		NSLog(NO, @"Open database Error!");
	
	NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM cities"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			number = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	sqlite3_finalize(statement);
	sqlite3_close(database);	
	
	return number;
}

BOOL cityDbUpdateAvailable(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL available = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT lastupdate, lastupdatelocal FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			char *pLocaltime, *pServertime;
			pServertime = (char *)sqlite3_column_text(statement, 0);
			pLocaltime = (char *)sqlite3_column_text(statement, 1);
			if ((pServertime != NULL) && (pLocaltime != NULL))
				if (strcmp(pServertime, pLocaltime) > 0)
					available = YES;
		}
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return available;
}

BOOL offlineDbUpdateAvailable(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL available = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT oldbtime, oldbtimelocal FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			char *pLocaltime, *pServertime;
			pServertime = (char *)sqlite3_column_text(statement, 0);
			pLocaltime = (char *)sqlite3_column_text(statement, 1);
			if ((pServertime != NULL) && (pLocaltime != NULL))
				if (strcmp(pServertime, pLocaltime) > 0)
					available = YES;
		}
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return available;
}

void updateOfflineDbInfoInGTFS(NSString *cityId, int downloaded, NSString *downloadTime)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	NSString *sql = [NSString stringWithFormat:@"UPDATE cities SET oldbdownloaded=%d, oldbtime='%@' WHERE id='%@'",
					 downloaded, (downloadTime)?downloadTime:@"", cityId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

BOOL offlineDbDownloaded(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL downloaded = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT oldbdownloaded FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			downloaded = (sqlite3_column_int(statement, 0) == 1);
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return downloaded;
}

NSString *offlineDbDownloadTime(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return @"";
	
	NSString *downloadTime = @"";
	NSString *sql = [NSString stringWithFormat:@"SELECT oldbtime FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			if (sqlite3_column_text(statement, 0))
				downloadTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return downloadTime;
}

@implementation GTFS_City
@synthesize cid, cname, cstate, country, website, dbname, lastupdate, lastupdatelocal, oldbtime, oldbtimelocal, local, oldbdownloaded;

- (void)dealloc 
{
	[cid release];
	[cname release];
	[cstate release];
	[country release];
	[website release];
	[dbname release];
	[lastupdate release];
	[lastupdatelocal release];
	[oldbtime release];
	[oldbtimelocal release];
	[super dealloc];
}

- (BOOL) isSameCity: (GTFS_City *)city
{
	if ([cid isEqualToString:city.cid])
		return YES;
	else
		return NO;
}

- (BOOL) isEqualTo: (GTFS_City *)city
{
	if (![cid isEqualToString:city.cid])
		return NO;
	if (![cname isEqualToString:city.cname])
		return NO;
	if (![cstate isEqualToString:city.cstate])
		return NO;
	if (![country isEqualToString:city.country])
		return NO;
	if (![website isEqualToString:city.website])
		return NO;
	if (![dbname isEqualToString:city.dbname])
		return NO;
	if (![lastupdate isEqualToString:city.lastupdate])
		return NO;
	if (![oldbtime isEqualToString:city.oldbtime])
		return NO;
	
	return YES;
}

@end

