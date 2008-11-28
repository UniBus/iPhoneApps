//
//  RouteQuery-CSV.m
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RouteQuery.h"
#import "BusRoute.h"
#import "General.h"

#define CSV_COL_STOP_ID		0
#define CSV_COL_STOP_NAME	1
#define CSV_COL_STOP_LAT	3
#define CSV_COL_STOP_LON	4
#define CSV_COL_STOP_POS	9
#define CSV_COL_STOP_DIR	10

@implementation RouteQuery

+ (id) initWithFile:(NSString *) routeFile
{
	RouteQuery *newObj;
	newObj = [[RouteQuery alloc] init];
	if (newObj == nil)
		return nil;
	
	if ([newObj openRouteFile:routeFile])
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
- (BOOL) openRouteFile: (NSString *)routeFile
{
    if (sqlite3_open([routeFile UTF8String], &database) == SQLITE_OK) 
		return YES;
	
	NSLog(@"Error: %s", sqlite3_errmsg(database));
	return NO;
}

#pragma mark Query operations

- (BusRoute *) routeOfId: (NSString *) anId
{
	BusRoute *aRoute = nil;
	NSString *sql = [NSString stringWithFormat:@"SELECT route_id, route_short_name, route_long_name FROM routes WHERE route_id=\"%@\"", anId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			aRoute = [[BusRoute alloc] init];
			aRoute.routeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aRoute.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aRoute.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return [aRoute autorelease];
}

- (NSArray *) queryRouteWithName:(NSString *) routeName
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"SELECT route_id, route_short_name, route_long_name FROM routes WHERE route_short_name LIKE \"%c%@%c\" OR route_long_name LIKE \"%c%@%c\" ", '%', routeName, '%', '%', routeName, '%'];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusRoute *aRoute = [[BusRoute alloc] init];
			aRoute.routeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aRoute.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aRoute.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			[results addObject:aRoute];
			[aRoute release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return results;
}

- (NSArray *) queryRouteWithNames:(NSArray *) routeNames
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *queryString = @"";
	for (NSString *aKey in routeNames)
	{
		if ([queryString isEqualToString:@""])
			queryString = [NSString stringWithFormat:@"(route_short_name LIKE \"%c%@%c\" OR route_long_name LIKE \"%c%@%c\") ", '%', aKey, '%', '%', aKey, '%'];
		else
			queryString = [NSString stringWithFormat:@"%@ AND (route_short_name LIKE \"%c%@%c\"  OR route_long_name LIKE \"%c%@%c\") ", queryString, '%', aKey, '%', '%', aKey, '%'];
	}
	
	NSString *sql = [NSString stringWithFormat:@"SELECT route_id, route_short_name, route_long_name FROM routes WHERE %@", queryString];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusRoute *aRoute = [[BusRoute alloc] init];
			aRoute.routeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aRoute.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aRoute.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			[results addObject:aRoute];
			[aRoute release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return results;
}

- (NSArray *) queryRouteWithIds:(NSArray *) routeIds
{
	NSMutableArray *results = [NSMutableArray array];
	NSString *queryString = @"";
	for (NSString *aKey in routeIds)
	{
		if ([queryString isEqualToString:@""])
			queryString = [NSString stringWithFormat:@"route_id=\"%@\" ", aKey];
		else
			queryString = [NSString stringWithFormat:@"%@ OR route_id=\"%@\" ", queryString, aKey];
	}
	
	NSString *sql = [NSString stringWithFormat:@"SELECT route_id, route_short_name, route_long_name FROM routes WHERE %@", queryString];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusRoute *aRoute = [[BusRoute alloc] init];
			aRoute.routeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aRoute.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aRoute.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				
			[results addObject:aRoute];
			[aRoute release];
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
