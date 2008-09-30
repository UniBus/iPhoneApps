//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <sqlite3.h>
#import "FavoriteViewController.h"
#import "TransitApp.h"
#import "BusArrival.h"
#import "StopCell.h"
#import "ArrivalCell.h"

NSMutableDictionary * readFavorite()
{
	NSMutableDictionary *favorites =[[NSMutableDictionary alloc] init];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return favorites;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id, bus_sign FROM favorite"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{			
			NSString *savedStopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *savedRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *savedBusSign = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
			BusStop *aStop = [myApplication stopOfId:savedStopId];
			if (aStop)
			{
				NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [aStop stopId]];
				NSMutableDictionary *favoriteStop = [favorites objectForKey:stopKey];
				if (favoriteStop == nil)
				{
					favoriteStop = [[NSMutableDictionary alloc] init];
					[favoriteStop setObject:aStop forKey:@"stop:info:info"];
					[favorites setObject:favoriteStop forKey:stopKey];
				}
				
				//Add bus sign
				NSString *routeInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:bussign", savedRouteId];				
				[favoriteStop setObject:savedBusSign forKey:routeInfoKey];
				
				//
				NSString *routeKey = [NSString stringWithFormat:@"route:%@", savedRouteId];
				NSMutableArray *favoriteRoute = [favoriteStop objectForKey:routeKey];
				if (favoriteRoute == nil)
				{
					favoriteRoute = [[NSMutableArray alloc] init];
					[favoriteStop setObject:favoriteRoute forKey:routeKey]; 
				}				
			}
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
	return [favorites autorelease];
}

BOOL saveToFavorite(BusArrival *anArrival)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
		
#ifdef DEBUGFULL
	sqlite3_stmt *statement;
	sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorite WHERE stop_id=\"%@\" AND route_id=\"%@\"",
						anArrival.stopId, anArrival.route];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			result = YES;
			NSLog(@"Try to insert an existing entry!");
			assert(result==NO);
		}
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	sqlite3_finalize(statement);
	
#endif
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorite(stop_id, route_id, bus_sign) VALUES (\"%@\", \"%@\", \"%@\")",
		   anArrival.stopId, anArrival.route, anArrival.busSign];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL saveToFavorite2(NSString *stopId, NSString *routeId, NSString *busSign)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
#ifdef DEBUGFULL
	sqlite3_stmt *statement;
	sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorite WHERE stop_id=\"%@\" AND route_id=\"%@\"", stopId, routeId];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			result = YES;
			NSLog(@"Try to insert an existing entry!");
			assert(result==NO);
		}
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	sqlite3_finalize(statement);
	
#endif
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorite(stop_id, route_id, bus_sign) VALUES (\"%@\", \"%@\", \"%@\")", stopId, routeId, (busSign? busSign:@"")];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
		
	sqlite3_close(database);
	return result;
}

BOOL removeFromFavorite2(NSString *stopId, NSString *routeId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
#ifdef DEBUGFULL
	sqlite3_stmt *statement;
	sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorite WHERE stop_id=\"%@\" AND route_id=\"%@\"", stopId, routeId];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			result = YES;
		}
		else
		{
			NSLog(@"Try to remove a non-existing entry!");
			assert(NO);
		}
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	sqlite3_finalize(statement);	
#endif
	
	sql = [NSString stringWithFormat:@"DELETE from favorite WHERE stop_id=\"%@\" AND route_id=\"%@\"", stopId, routeId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL isInFavorite(BusArrival *anArrival)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorite where stop_id=\"%@\" AND route_id=\"%@\"",
					 anArrival.stopId, anArrival.route];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return result;
}

BOOL isInFavorite2(NSString *stopId, NSString *routeId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorite where stop_id=\"%@\" AND route_id=\"%@\"",
					 stopId, routeId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return result;
}

@implementation FavoriteViewController

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		// Initialization code
	}
	return self;
}
*/

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[super loadView];
	self.navigationItem.title = @"Favorite Stops";	
}

- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}
 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc 
{
	[stopsDictionary release];
	[super dealloc];
}

- (void) alertOnEmptyStopsOfInterest
{
}

- (void) needsReload
{
	[stopsDictionary release];
	stopsDictionary = [readFavorite() retain];
	
	NSMutableArray *newStops = [NSMutableArray array]; //Notes, as documents say, [NSMutableArray array] will autorelease

	//Update routesOfInterest;
	[routesOfInterest release];
	routesOfInterest = [[NSMutableArray alloc] init];	
	
	NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
	NSString *key;
	while ((key = [enumerator nextObject])) {
		NSDictionary *aStopInDictionary = [stopsDictionary objectForKey:key];

		BusStop *aStop = [aStopInDictionary objectForKey:@"stop:info:info"];		
		if (aStop )
		{
			//which means the data is not ready yet!!
			[newStops addObject:aStop];
		}		
		
		NSArray *allKeys = [aStopInDictionary allKeys];
		NSMutableArray *routesAtAStop = [NSMutableArray array];
		for (NSString *aRouteKey in allKeys)
		{
			if ([aRouteKey rangeOfString:@"stop:info"].length)
				continue;
			[routesAtAStop addObject:aRouteKey];
		}
		[routesOfInterest addObject:routesAtAStop];		
	}
	
	//Here is something critcal, don't use
	//	self.stopsOfInterest = newStops;	
	//instead to avoid stopsDictionary being updated, manipulator stopOfInterest Directlry
	[stopsOfInterest release];
	stopsOfInterest = [newStops retain];
	
	[self reload];
}

- (void) clearArrivals
{
	NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
	NSString *key;
	while ((key = [enumerator nextObject])) 
	{
		NSMutableDictionary *aStopInDictionary = [stopsDictionary objectForKey:key];	
		NSArray *allKeys = [aStopInDictionary allKeys];
	
		for (NSString *aKey in allKeys)
		{
			if ([aKey rangeOfString:@"stop:info:"].length != 0)
				continue;
			NSMutableArray *arrivals = [aStopInDictionary objectForKey:aKey];
			[arrivals removeAllObjects];
		}
	}
}

- (void) arrivalsUpdated: (NSArray *)results
{
	[self clearArrivals];
	for (BusArrival *anArrival in results)
	{
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", anArrival.stopId];
		NSString *routeKey = [NSString stringWithFormat:@"route:%@", anArrival.route];
		
		NSMutableArray *arrivals = [[stopsDictionary objectForKey:stopKey] objectForKey:routeKey];
		if (arrivals)
			[arrivals addObject:anArrival];
	}
	
	//UITableView *tableView = (UITableView *) self.view;
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
}


#pragma mark TableView Delegate Functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	static NSString *MyIdentifier2 = @"MyIdentifier2";
	
	if ([indexPath row] >= 1)
	{
		ArrivalCell *cell = (ArrivalCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		//Assume in dequeResableCellWithIdentifier, autorelease has been called
		if (cell == nil) 
		{
			cell = [[[ArrivalCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier owner:self] autorelease];
		}
		
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [[stopsOfInterest objectAtIndex:indexPath.section] stopId]];
		NSDictionary *aStopInDictionary = [stopsDictionary objectForKey:stopKey];
		NSArray *allRouteKeysAtAStop = [routesOfInterest objectAtIndex:indexPath.section];
		NSString *routeKey = [allRouteKeysAtAStop objectAtIndex:(indexPath.row-1)];
		NSMutableArray *arrivalsAtOneStopForOneBus = [aStopInDictionary objectForKey:routeKey];
		if ([arrivalsAtOneStopForOneBus count] == 0)
		{
			BusArrival *aFakeArrival = [[BusArrival alloc] init];
			aFakeArrival.flag = YES;
			aFakeArrival.stopId = [[stopsOfInterest objectAtIndex:indexPath.section] stopId];
			
			//get route
			NSRange searchResult = [routeKey rangeOfString: @"route:"];
			NSAssert(searchResult.length != 0 && searchResult.location == 0, @"Wrong data in stopsDictionary");
			aFakeArrival.route = [routeKey substringFromIndex:(searchResult.location+searchResult.length)];
			
			//get bus sign
			NSString *busSignKey = [NSString stringWithFormat:@"stop:info:%@:bussign", routeKey];
			
			NSAssert([aStopInDictionary objectForKey:busSignKey], @"Couldn't find bus sign, wrong data in stopsDictionary.");
			aFakeArrival.busSign = [aStopInDictionary objectForKey:busSignKey];
			[arrivalsAtOneStopForOneBus addObject:aFakeArrival];
			[aFakeArrival release];
		}
		
		[cell setArrivals:arrivalsAtOneStopForOneBus];
		return cell;
	}
	else
	{
		StopCell *cell = (StopCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
		if (cell == nil) 
		{
			cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2 owner:self] autorelease];
		}
		[cell setStop:[stopsOfInterest objectAtIndex:[indexPath section]]];
		return cell;
	}
	
	// Configure the cell
	//return cell;
}


@end
