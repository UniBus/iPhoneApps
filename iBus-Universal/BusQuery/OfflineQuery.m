//
//  OfflineQuery.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

/*! \class OfflineQuery
 *
 * \brief Offline query for arrivals and trips. 
 *	
 *	The ArrivalQuery class query arrivals, and TripQuery class query
 *		trips, both in an online fashion.
 *	To support offline browsing, this class replace ArrivalQuery/TripQuery,
 *		when network is not available or user manually switch to offline browing.
 *	
 * \todo Now that I have all these queries in one single class, I am thinking
 *		should I merge online arrivals/trips queries into one single class.
 *
 * \ingroup gtfsquery
 */ 

#import "OfflineQuery.h"
#import "TransitApp.h"
#import "BusArrival.h"
#import "BusTrip.h"

#define MAX_QUERY_PERIOD		12
#define MAX_RECORD_FORAROUTE	2
@implementation OfflineQuery

@synthesize available;

- (NSString *)offlineDbName
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	NSString *offlineDbName = [NSString stringWithFormat:@"ol-%@", [myApplication currentDatabase]];
	return [[myApplication localDatabaseDir] stringByAppendingPathComponent:offlineDbName];
}

- (BOOL) available
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[self offlineDbName]])
		return YES;
	return NO;
}

- (NSArray *) findServiceIds:(sqlite3 *)database ofDate:(NSString *)queryDate onDay:(NSString *)queryDay
{
	//Check if there is any feasible service id in calendar
	//Outcomes of this query are a list of service_ids.
	NSMutableArray *feasibleServiceIds = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat: @"SELECT DISTINCT service_id FROM calendar WHERE %@=1", queryDay];
	NSLog(@"findServiceIds: SQL: %@", sql);
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			[feasibleServiceIds addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
		}
	}
	sqlite3_finalize(statement);
		
	//Then, check if the day has been particularly added or removed from some services
	//Outcomes of this query are a list of service_ids with exceptions.
	NSMutableArray *exceptionalServiceIds = [NSMutableArray array];
	NSMutableArray *additionalServiceIds = [NSMutableArray array];
	sql = [NSString stringWithFormat: @"SELECT service_id, exception_type FROM calendar_dates WHERE date=%@", queryDate];
	NSLog(@"findServiceIds: exception: SQL: %@", sql);
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BOOL exception_type;
			exception_type = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] intValue];
			if (exception_type == 1)
				[additionalServiceIds addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
			else if (exception_type == 2)
				[exceptionalServiceIds addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
			else
				NSLog(@"Unknown exception type found in current calendar_dates table!!");
		}
	}
	sqlite3_finalize(statement);
	
	for(NSString *exceptionalId in exceptionalServiceIds)
	{
		if ([feasibleServiceIds containsObject:exceptionalId])
			[feasibleServiceIds removeObject:exceptionalId];
	}
	
	for(NSString *additionalId in additionalServiceIds)
	{
		if (![feasibleServiceIds containsObject:additionalId])
			[feasibleServiceIds addObject:additionalId];
	}

	return feasibleServiceIds;
}

-(NSDictionary*) findRoutesAtStop:(sqlite3 *)database withStopId:(NSString *)stopId
{
	NSMutableDictionary *allRoutes = [NSMutableDictionary dictionary];
	NSString *sql = [NSString stringWithFormat:
					 @"SELECT DISTINCT routes.route_id, routes.route_short_name, routes.route_long_name, trips.trip_headsign, trips.direction_id "
					 "FROM local.routes as routes, trips, stop_times "
					 "WHERE routes.route_id=trips.route_id AND "
					 "      stop_times.trip_id=trips.trip_id AND "
					 "      stop_times.stop_id='%@' "
					 "GROUP BY routes.route_id, direction_id "
					 "ORDER BY route_short_name, routes.route_id, direction_id", stopId];
	NSLog(@"findRoutesAtStop: SQL: %@", sql);
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			NSMutableDictionary *dictForARoute = [NSMutableDictionary dictionary];
			NSString *currentRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *currentDirectionId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			[dictForARoute setObject:currentRouteId forKey:@"route_id"];
			[dictForARoute setObject:currentDirectionId forKey:@"direction_id"];
			[dictForARoute setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] forKey:@"route_short_name"];
			[dictForARoute setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] forKey:@"route_long_name"];
			[dictForARoute setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)] forKey:@"trip_headsign"];
			
			NSString *currentKey = [NSString stringWithFormat:@"%@_dir_%@", currentRouteId, currentDirectionId];			
			[allRoutes setObject:dictForARoute forKey:currentKey];
		}
	}
	sqlite3_finalize(statement);

	return allRoutes;
}

- (NSArray *) findArrivalsAtStop:(NSString *)stop
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm:SS"];
	NSString *queryBeginTimeStr = [formatter stringFromDate:[NSDate date]];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *queryBeginDateStr = [formatter stringFromDate:[NSDate date]];
	[formatter setDateFormat:@"EEEE"];
	NSString *queryBeginDayStr = [formatter stringFromDate:[NSDate date]];
	[formatter release];
	
	//NSString *queryBeginTimeStr = @"090000";//date('H:i:s', $beginTime);
	//NSString *queryBeginDateStr = @"20081129";//date('Ymd', $beginTime);
	//NSString *queryBeginDayStr = @"Saturday";//date('l', $beginTime);
	NSMutableArray *allArrivals = [NSMutableArray array];
	sqlite3 *database;
    if (sqlite3_open([[self offlineDbName] UTF8String], &database) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));	
		return allArrivals;
	}	
	
	TransitApp *myApplication = (TransitApp *)[UIApplication sharedApplication];
	NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS local", [myApplication currentDatabaseWithFullPath]];
	NSLog(@"findArrivalsAtStop: attach: SQL: %@", sql);
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));	
		sqlite3_close(database);	
		return allArrivals;
	}	

	//Set up the empty structure of arrivals
	NSMutableDictionary *arrivalsByRoutes = [NSMutableDictionary dictionary];		
	NSDictionary *allRoutesAtStop = [self findRoutesAtStop:database withStopId:stop];
	for (id routeKey in allRoutesAtStop)
	{
		[arrivalsByRoutes setObject:[NSMutableArray array] forKey:[allRoutesAtStop objectForKey:routeKey]];
	}
	
	//Get a set of feasible service IDs
	NSArray *serviceIds = [self findServiceIds:database ofDate:queryBeginDateStr onDay:queryBeginDayStr];
	if ([serviceIds count] > 0)
	{
		//reindex the array
		NSString *calendarPhase = [NSString stringWithFormat:@"trips.service_id IN ('%@'", [serviceIds objectAtIndex:0]];
		for (int i = 1; i < [serviceIds count]; i++) 
		{
			calendarPhase = [calendarPhase stringByAppendingFormat:@",'%@'", [serviceIds objectAtIndex:i]];
		}
		calendarPhase = calendarPhase = [calendarPhase stringByAppendingString:@")"];
		
		//Query for arrivals
		//Notes about DISTINCT:
		//	Add Nov-11-2008, there are some duplication in Milwaukee data.
		//  IMO, data should be fixed, instead of the code.
		sql = [NSString stringWithFormat:
						 @"SELECT DISTINCT routes.route_id, stop_times.stop_headsign, trips.trip_headsign, stop_times.arrival_time, trips.direction_id "
						 "FROM stop_times, trips, local.routes as routes "
						 "WHERE stop_id='%@' AND "
						 "stop_times.trip_id=trips.trip_id AND trips.route_id=routes.route_id AND "
						 "%@ AND stop_times.arrival_time>='%@' "
						 "ORDER BY arrival_time", stop, calendarPhase, queryBeginTimeStr];
		
		NSLog(@"findArrivalsAtStop: SQL: %@", sql);
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				NSString *currentRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				NSString *currentDirectionId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
				NSString *currentKey = [NSString stringWithFormat:@"%@_dir_%@", currentRouteId, currentDirectionId];
				NSDictionary *currentRoute = [allRoutesAtStop objectForKey:currentKey];			
				if ([[arrivalsByRoutes objectForKey:currentRoute] count] >= MAX_RECORD_FORAROUTE)
					continue;
					
				BusArrival *arrival = [[BusArrival alloc] init];
				
				//Stop-info
				[arrival setStopId: stop];
				
				//Route-info
				[arrival setRouteId:currentRouteId];
				[arrival setDirection:currentDirectionId];
				if (![[currentRoute objectForKey:@"route_short_name"] isEqualToString:@""])
					[arrival setRoute:[currentRoute objectForKey:@"route_short_name"]];
				else
					[arrival setRoute:[currentRoute objectForKey:@"route_long_name"]];
					
				if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] isEqualToString:@""])
					[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
				else if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] isEqualToString:@""])
					[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
				else
					[arrival setBusSign:[currentRoute objectForKey:@"route_long_name"]];
							
				[arrival setArrivalTime:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
				
				[[arrivalsByRoutes objectForKey:currentRoute] addObject:arrival];
				[arrival release];		
			}
		}
		else
		{
			NSLog(@"Error: %s", sqlite3_errmsg(database));	
		}	
		
		sqlite3_finalize(statement);
	}
	
	NSDate *queryEndTime = [[NSDate date] addTimeInterval:MAX_QUERY_PERIOD*60*60];
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *queryEndDateStr = [formatter stringFromDate:queryEndTime];
	if (![queryEndDateStr isEqualToString:queryBeginDateStr])
	{
		[formatter setDateFormat:@"HH:mm:SS"];
		NSString *queryEndTimeStr = [formatter stringFromDate:queryEndTime];
		[formatter setDateFormat:@"EEEE"];
		NSString *queryEndDayStr = [formatter stringFromDate:queryEndTime];
		
		serviceIds = [self findServiceIds:database ofDate:queryEndDateStr onDay:queryEndDayStr];
		if ([serviceIds count] > 0)
		{
			//reindex the array
			NSString *calendarPhase = [NSString stringWithFormat:@"trips.service_id IN ('%@'", [serviceIds objectAtIndex:0]];
			for (int i = 1; i < [serviceIds count]; i++) 
			{
				calendarPhase = [calendarPhase stringByAppendingFormat:@",'%@'", [serviceIds objectAtIndex:i]];
			}
			calendarPhase = calendarPhase = [calendarPhase stringByAppendingString:@")"];
			
			//Query for arrivals
			//Notes about DISTINCT:
			//	Add Nov-11-2008, there are some duplication in Milwaukee data.
			//  IMO, data should be fixed, instead of the code.
			sql = [NSString stringWithFormat:
				   @"SELECT DISTINCT routes.route_id, stop_times.stop_headsign, trips.trip_headsign, stop_times.arrival_time, trips.direction_id "
				   "FROM stop_times, trips, local.routes as routes "
				   "WHERE stop_id='%@' AND "
				   "stop_times.trip_id=trips.trip_id AND trips.route_id=routes.route_id AND "
				   "%@ AND stop_times.arrival_time<='%@' "
				   "ORDER BY arrival_time", stop, calendarPhase, queryEndTimeStr];
			
			NSLog(@"findArrivalsAtStop: SQL: %@", sql);
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
			{
				while (sqlite3_step(statement) == SQLITE_ROW)
				{
					NSString *currentRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					NSString *currentDirectionId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
					NSString *currentKey = [NSString stringWithFormat:@"%@_dir_%@", currentRouteId, currentDirectionId];
					NSDictionary *currentRoute = [allRoutesAtStop objectForKey:currentKey];			
					if ([[arrivalsByRoutes objectForKey:currentRoute] count] >= MAX_RECORD_FORAROUTE)
						continue;
					
					BusArrival *arrival = [[BusArrival alloc] init];
					
					//Stop-info
					[arrival setStopId: stop];
					
					//Route-info
					[arrival setRouteId:currentRouteId];
					[arrival setDirection:currentDirectionId];
					if (![[currentRoute objectForKey:@"route_short_name"] isEqualToString:@""])
						[arrival setRoute:[currentRoute objectForKey:@"route_short_name"]];
					else
						[arrival setRoute:[currentRoute objectForKey:@"route_long_name"]];
					
					if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] isEqualToString:@""])
						[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
					else if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] isEqualToString:@""])
						[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
					else
						[arrival setBusSign:[currentRoute objectForKey:@"route_long_name"]];
					
					[arrival setArrivalTime:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
					
					[[arrivalsByRoutes objectForKey:currentRoute] addObject:arrival];
					[arrival release];		
				}
			}
			else
			{
				NSLog(@"Error: %s", sqlite3_errmsg(database));	
			}	
			
			sqlite3_finalize(statement);
		}		
		
	}
	[formatter release];
	
	
	for (id routeKey in allRoutesAtStop)
	{
		NSDictionary *aRoute = [allRoutesAtStop objectForKey:routeKey];
		NSArray *arrivalForTheRoute = [arrivalsByRoutes objectForKey:aRoute];
		if ([arrivalForTheRoute count] != 0)
		{
			[allArrivals addObjectsFromArray:arrivalForTheRoute];
		}
		else
		{
			BusArrival *arrival = [[BusArrival alloc] init];
			[arrival setStopId:stop];
			[arrival setRouteId:[aRoute objectForKey:@"route_id"]];
			if (![[aRoute objectForKey:@"route_short_name"] isEqualToString:@""])
				[arrival setRoute:[aRoute objectForKey:@"route_short_name"]];
			else
				[arrival setRoute:[aRoute objectForKey:@"route_long_name"]];
			if (![[aRoute objectForKey:@"trip_headsign"] isEqualToString:@""])
				[arrival setBusSign:[aRoute objectForKey:@"trip_headsign"]];
			else
				[arrival setBusSign:[aRoute objectForKey:@"route_long_name"]];
			[arrival setArrivalTime:@"-- -- --"];
			[arrival setDirection:[aRoute objectForKey:@"direction_id"]];
						
			[allArrivals addObject:arrival];
			[arrival release];		
		}
	}
		
	sqlite3_close(database);	
	return allArrivals;
}

#pragma mark Querying functions interface
- (NSArray *) queryForStops: (NSArray *) stops
{
	if ([stops count] == 0)
		return nil;
	
	NSMutableArray *arrivalsForStops = [NSMutableArray array];
	for (BusStop *aStop in stops)
	{
		NSArray *arrivalAtTheStop = [self findArrivalsAtStop:[aStop stopId]];
		[arrivalsForStops addObjectsFromArray:arrivalAtTheStop];
	}
	
	return arrivalsForStops;
}

//- (NSArray *) queryRoutesAtAStop:(sqlite3 *)database ofDate:(NSString *)queryDate onDay:(NSString *)queryDay
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop onDay:(NSString *)day
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:[[day substringWithRange:NSMakeRange(0, 4)] intValue]];
	[comps setMonth:[[day substringWithRange:NSMakeRange(4, 2)] intValue]];
	[comps setDay:[[day substringWithRange:NSMakeRange(6, 2)] intValue]];	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *dateOfQuery = [gregorian dateFromComponents:comps];
	[gregorian release];
	[comps release];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *queryBeginDateStr = [formatter stringFromDate:dateOfQuery];
	[formatter setDateFormat:@"EEEE"];
	NSString *queryBeginDayStr = [formatter stringFromDate:dateOfQuery];
	[formatter release];
		
	//NSString *queryBeginTimeStr = @"090000";//date('H:i:s', $beginTime);
	//NSString *queryBeginDateStr = @"20081129";//date('Ymd', $beginTime);
	//NSString *queryBeginDayStr = @"Saturday";//date('l', $beginTime);
	
	NSMutableArray *allArrivals = [NSMutableArray array];		
	sqlite3 *database;
    if (sqlite3_open([[self offlineDbName] UTF8String], &database) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));
		return allArrivals;
	}
	
	TransitApp *myApplication = (TransitApp *)[UIApplication sharedApplication];
	NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS local", [myApplication currentDatabaseWithFullPath]];
	NSLog(@"SQL: %@", sql);
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));
		return allArrivals;
	}	
	
	//Get a set of feasible service IDs
	NSArray *serviceIds = [self findServiceIds:database ofDate:queryBeginDateStr onDay:queryBeginDayStr];
	if ([serviceIds count] == 0)
	{
		sqlite3_close(database);	
		return allArrivals;
	}
	
	//Set up the empty structure of arrivals
	NSMutableDictionary *arrivalsByRoutes = [NSMutableDictionary dictionary];		
	NSDictionary *allRoutesAtStop = [self findRoutesAtStop:database withStopId:stop];
	for (id routeKey in allRoutesAtStop)
	{
		[arrivalsByRoutes setObject:[NSMutableArray array] forKey:[allRoutesAtStop objectForKey:routeKey]];
	}
	
	//reindex the array
	NSString *calendarPhase = [NSString stringWithFormat:@"trips.service_id IN ('%@', ", [serviceIds objectAtIndex:0]];
	for (int i = 1; i < [serviceIds count]; i++) 
	{
		calendarPhase = [calendarPhase stringByAppendingFormat:@", '%@'", [serviceIds objectAtIndex:i]];
	}
	calendarPhase = calendarPhase = [calendarPhase stringByAppendingString:@")"];
	
	//Query for arrivals
	//Notes about DISTINCT:
	//	Add Nov-11-2008, there are some duplication in Milwaukee data.
	//  IMO, data should be fixed, instead of the code.	
	sql = [NSString stringWithFormat:
		   @"SELECT DISTINCT stop_times.stop_headsign, trips.trip_headsign, stop_times.arrival_time, routes.route_short_name, routes.route_long_name, trips.direction_id "
		   "FROM stop_times, trips, local.routes as routes "
		   "WHERE stop_id='%@' AND routes.route_id='%@' AND "
		   "(trips.direction_id='%@' OR trips.direction_id='') AND "
		   "stop_times.trip_id=trips.trip_id AND trips.route_id=routes.route_id AND %@ "
		   "ORDER BY arrival_time", stop, route, dir, calendarPhase];
	
	NSLog(@"SQL: %@", sql);
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusArrival *arrival = [[BusArrival alloc] init];
			
			//Stop-info
			[arrival setStopId: stop];
			
			//Route-info
			[arrival setRouteId:route];
			if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)] isEqualToString:@""])
				[arrival setRoute:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
			else
				[arrival setRoute:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
			
			if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] isEqualToString:@""])
				[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
			else if (![[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)] isEqualToString:@""])
				[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
			else
				[arrival setBusSign:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
			
			[arrival setArrivalTime:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
			arrival.direction = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			
			[allArrivals addObject:arrival];
			[arrival release];		
		}
	}
	sqlite3_finalize(statement);
	
	sqlite3_close(database);	
	return allArrivals;
}

- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *queryBeginDateStr = [formatter stringFromDate:[NSDate date]];
	
	return [self queryForRoute:route inDirection:dir atStop:stop onDay:queryBeginDateStr];
}

- (NSArray *) queryTripsOnRoute:(NSString *) routeId
{
	NSMutableArray *allTrips = [NSMutableArray array];		
	sqlite3 *database;
    if (sqlite3_open([[self offlineDbName] UTF8String], &database) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));
		return allTrips;
	}
	
	//Check if there is any feasible service id in calendar
	//Outcomes of this query are a list of service_ids.
	NSString *sql = [NSString stringWithFormat: @"SELECT trip_id, direction_id, trip_headsign FROM trips "
					 "WHERE route_id='%@' "
					 "GROUP BY direction_id, trip_headsign",
					 routeId];
	NSLog(@"queryTripsOnRoute: SQL: %@", sql);
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			BusTrip *aTrip = [[BusTrip alloc] init];
			aTrip.tripId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			aTrip.direction = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			aTrip.headsign = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			[allTrips addObject:aTrip];
		}
	}
	sqlite3_finalize(statement);
	
	sqlite3_close(database);	
	return allTrips;
}

- (NSArray *) queryStopsOnTrip:(NSString *) tripId
{
	NSMutableArray *allStops = [NSMutableArray array];		
	sqlite3 *database;
    if (sqlite3_open([[self offlineDbName] UTF8String], &database) != SQLITE_OK) 
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));
		return allStops;
	}
	
	//Check if there is any feasible service id in calendar
	//Outcomes of this query are a list of service_ids.
	NSString *sql = [NSString stringWithFormat: @"SELECT stop_id FROM stop_times WHERE trip_id='%@' ", tripId];
	NSLog(@"queryTripsOnRoute: SQL: %@", sql);
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			[allStops addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
		}
	}
	sqlite3_finalize(statement);
	
	sqlite3_close(database);	
	return allStops;
}

@end
