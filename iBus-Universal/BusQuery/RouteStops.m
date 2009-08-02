//
//  RouteStops.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 01/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import "RouteStops.h"


@implementation RouteStops

+ (id) initWithFile:(NSString *) routeStopsFile
{
	RouteStops *newObj;
	newObj = [[RouteStops alloc] init];
	if (newObj == nil)
		return nil;
	
	if ([newObj openRouteStopsFile:routeStopsFile])
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
- (BOOL) openRouteStopsFile: (NSString *)routeStopsFile
{
    if (sqlite3_open([routeStopsFile UTF8String], &database) == SQLITE_OK) 
		return YES;
	
	NSLog(@"Error: %s", sqlite3_errmsg(database));
	return NO;
}

#pragma mark Query operations

- (BOOL) isStop:(NSString *)stop_id hasRoutes:(NSArray *)routes
{
	if ([routes count] == 0)
		return YES;
	
	BOOL found = NO;
	NSString *routeListString = [NSString stringWithFormat:@"\"%@\"", [routes objectAtIndex:0]];
	for (int i=1; i<[routes count]; i++)
		routeListString = [routeListString stringByAppendingFormat:@",\"%@\"", [routes objectAtIndex:i]];
		
	NSString *sql = [NSString stringWithFormat:@"SELECT route_stops.stop_id FROM route_stops, routes "
												"WHERE route_stops.stop_id=\"%@\" AND "
												"routes.route_id = route_stops.route_id AND "
												"routes.route_short_name in (%@) "
												"LIMIT 1",
									stop_id, routeListString];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			found = YES;
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	return found;
}

@end
