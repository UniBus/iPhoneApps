//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#import <sqlite3.h>
#import "FavoriteViewController.h"
#import "TransitApp.h"
#import "BusArrival.h"
#import "StopCell.h"
#import "ArrivalCell.h"

//Return Values: a Dictionary
// - [stop:$sid1]
//       - [stop:info:info]
//       - [stop:info:route:%rid1:dir_:id]
//       - [stop:info:route:%rid1:dir_:name]
//       - [stop:info:route:%rid1:dir_:bussign]
//       - [stop:info:route:%rid1:dir_:]
//              - an empty array
// - repeat
//
NSMutableDictionary * readFavorite()
{
	NSMutableDictionary *favorites =[[NSMutableDictionary alloc] init];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return favorites;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id, route_name, bus_sign, direction_id FROM favorites ORDER BY stop_id, route_id"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{			
			NSString *savedStopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *savedRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *savedRouteName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *savedBusSign = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			NSString *savedRouteDirectId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			
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
					[favoriteStop release];
				}
				
				//Add route name
				NSString *routeInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:id", savedRouteId, savedRouteDirectId];				
				[favoriteStop setObject:savedRouteId forKey:routeInfoKey];
				
				//Add route name
				routeInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:name", savedRouteId, savedRouteDirectId];				
				[favoriteStop setObject:savedRouteName forKey:routeInfoKey];

				//Add bus sign
				routeInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:bussign", savedRouteId, savedRouteDirectId];				
				[favoriteStop setObject:savedBusSign forKey:routeInfoKey];
				
				//
				NSString *routeKey = [NSString stringWithFormat:@"route:%@:dir_%@", savedRouteId, savedRouteDirectId];
				NSMutableArray *favoriteRoute = [favoriteStop objectForKey:routeKey];
				if (favoriteRoute == nil)
				{
					favoriteRoute = [[NSMutableArray alloc] init];
					[favoriteStop setObject:favoriteRoute forKey:routeKey]; 
					[favoriteRoute release];
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

BOOL saveToFavorite2(NSString *stopId, NSString *routeId, NSString *routeName, NSString *busSign, NSString *dir)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
	//Delete those favorite with ambiguious direction.
	if (![dir isEqualToString:@""])
	{
		sql = [NSString stringWithFormat:@"DELETE from favorites WHERE stop_id='%@' AND route_id='%@' AND direction_id=''", stopId, routeId];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
		{
			result = YES;
		}
		else
			NSLog(@"Error: %s", sqlite3_errmsg(database));				
	}
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorites(stop_id, route_id, route_name, bus_sign, direction_id) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
		   stopId, routeId, routeName, (busSign? busSign:@""), dir];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
		
	sqlite3_close(database);
	return result;
}

BOOL removeFromFavorite2(NSString *stopId, NSString *routeId, NSString *dir)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
#ifdef DEBUGFULL
	sqlite3_stmt *statement;
	sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorites WHERE stop_id='%@' AND route_id='%@' AND direction_id='%@'", stopId, routeId, dir];
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
	
	sql = [NSString stringWithFormat:@"DELETE from favorites WHERE stop_id='%@' AND route_id='%@' AND direction_id='%@'", stopId, routeId, dir];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL removeAStopFromFavorite(NSString *stopId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
		
	sql = [NSString stringWithFormat:@"DELETE from favorites WHERE stop_id='%@'", stopId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL isInFavorite2(NSString *stopId, NSString *routeId, NSString *dir)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id FROM favorites where stop_id='%@' AND route_id='%@' AND (direction_id='%@' OR direction_id='') ",
					 stopId, routeId, dir];
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
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Favorites";	
}

- (void)viewDidAppear:(BOOL)animated
{
	if (needReset)
		[self needsReload];

	needReset = NO;
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

- (void) refreshClicked:(id)sender
{
	[self needsReload];
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
		
		//NSArray *allKeys = [aStopInDictionary allKeys];
		NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[aStopInDictionary allKeys]];
		[allKeys sortUsingSelector:@selector(compare:)];
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
	//instead to avoid stopsDictionary being updated, manipulate stopOfInterest Directlry
	[stopsOfInterest release];
	stopsOfInterest = [newStops retain];
	
	[self reload];
}

//FavoriteViewController override this function of StopsViewController
// - In StopsViewController,
//     * all arrivals associated with a stop will be deleted
//     * after this function all arrival/route info will be deleted from dictionary.
// - In FavoriteViewController,
//     * only arrival arrays are delete, and route info [stop:route:$first_route:dir_$dir] is kept.
//
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
	//NSMutableArray *routeKeysToDelete = [NSMutableArray array];
	//NSMutableArray *stopKeysToDelete = [NSMutableArray array];
	//NSLog(@"Favrite: arrivalsUpdated....");

	for (BusArrival *anArrival in results)
	{
		//NSLog(@"Favrite: listing results....");
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", anArrival.stopId];
		NSString *routeKey = [NSString stringWithFormat:@"route:%@:dir_%@", anArrival.routeId, anArrival.direction];
		
		NSMutableArray *arrivals = [[stopsDictionary objectForKey:stopKey] objectForKey:routeKey];
		if (arrivals)
			[arrivals addObject:anArrival];
		else if (![anArrival.direction isEqualToString:@""])
		{
			//The following is for a couple of reasons:
			//  - Some cities current do not have direction information, in the future
			//    when this changes, stops should be able to show up.
			//  - Upgrading from Ver1.1 to Ver1.2 and higher.
			//    Ver1.1 did not consider direction!
			routeKey = [NSString stringWithFormat:@"route:%@:dir_", anArrival.routeId];
			arrivals = [[stopsDictionary objectForKey:stopKey] objectForKey:routeKey];
			if (arrivals)
			{
				//Prepare for deletion later:
				//[stopKeysToDelete addObject:stopKey];
				//[routeKeysToDelete addObject:routeKey];
				
				//Add the new direction into stopsDictionary
				NSMutableDictionary *favoriteStop = [stopsDictionary objectForKey:stopKey];
				NSString *newRouteInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:id", anArrival.routeId, anArrival.direction];				
				[favoriteStop setObject:anArrival.routeId forKey:newRouteInfoKey];
				newRouteInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:name", anArrival.routeId, anArrival.direction];				
				[favoriteStop setObject:anArrival.route forKey:newRouteInfoKey];
				newRouteInfoKey = [NSString stringWithFormat:@"stop:info:route:%@:dir_%@:bussign", anArrival.routeId, anArrival.direction];				
				[favoriteStop setObject:anArrival.busSign forKey:newRouteInfoKey];
				NSString *newRouteKey = [NSString stringWithFormat:@"route:%@:dir_%@", anArrival.routeId, anArrival.direction];
				NSMutableArray *favoriteRoute = [NSMutableArray arrayWithObject:anArrival];
				[favoriteStop setObject:favoriteRoute forKey:newRouteKey]; 
					
				//Need to update routesOfInterest
				int index = [stopsOfInterest indexOfObject:[favoriteStop objectForKey:@"stop:info:info"]];
				[[routesOfInterest objectAtIndex:index] addObject:newRouteKey];
				
				//Update Favorites table in database;
				//Notes that by saving a route with direction, the function will automatic delete the corresponding saved route without direction.
				saveToFavorite2(anArrival.stopId, anArrival.routeId, anArrival.route, anArrival.busSign, anArrival.direction);
			}
		}
	}
	
	//Notes: This is delete for simplicity.
	//	I was thinking of updating favorite list right away, but it seems tedious.
	//  So instead, I just clean up favorite list by calling savetoFavorite2 as above,
	//  and then as user refresh the list, it get clean up.
	/*
	if ([stopKeysToDelete count])
	{
		//deleting should be done here, instead of inside the loop, because
		// in some case same route in two directions may pass the same stop!
		for (int i=0; i<[stopKeysToDelete count]; i++)
		{
			NSMutableDictionary *stopToDelete = [stopsDictionary objectForKey:[stopKeysToDelete objectAtIndex:i]];
			//A key may be deleted twice, but that's ok. it does nothing for the second deletion.
			[stopToDelete removeObjectForKey:[routeKeysToDelete objectAtIndex:i]];
			//Notes: This is simplified way:
			//	I didn't delete other entries associated with the route, [stop:info:route:name/bussign].
			//  But I don't think that is a problem, by deleting the routeKey, those entries will never been accessed,
			//  and after refresh, they will all been cleaned up.
			
			int index = [stopsOfInterest indexOfObject:[stopToDelete objectForKey:@"stop:info:info"]];
			[[routesOfInterest objectAtIndex:index] removeObjectIdenticalTo:[routeKeysToDelete objectAtIndex:i]];
		}
	}*/
	
	//UITableView *tableView = (UITableView *) self.view;
	//NSLog(@"Favrite: reloadData....");
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
}


#pragma mark TableView Delegate Functions

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"MyIdentifier";
	NSString *MyIdentifier2 = @"MyIdentifier2";
	
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
			//NSRange searchResult = [routeKey rangeOfString: @"route:"];
			//NSAssert(searchResult.length != 0 && searchResult.location == 0, @"Wrong data in stopsDictionary");
			//aFakeArrival.routeId = [routeKey substringFromIndex:(searchResult.location+searchResult.length)];
			NSString *routeIdKey = [NSString stringWithFormat:@"stop:info:%@:id", routeKey];
			aFakeArrival.routeId = [aStopInDictionary objectForKey:routeIdKey];
			
			//get route name key
			NSString *routeNameKey = [NSString stringWithFormat:@"stop:info:%@:name", routeKey];
			NSAssert([aStopInDictionary objectForKey:routeNameKey], @"Couldn't find route name, wrong data in stopsDictionary.");
			aFakeArrival.route = [aStopInDictionary objectForKey:routeNameKey];

			//get bus sign
			NSString *busSignKey = [NSString stringWithFormat:@"stop:info:%@:bussign", routeKey];			
			NSAssert([aStopInDictionary objectForKey:busSignKey], @"Couldn't find bus sign, wrong data in stopsDictionary.");
			aFakeArrival.busSign = [aStopInDictionary objectForKey:busSignKey];
			
			aFakeArrival.direction = @"";
			[arrivalsAtOneStopForOneBus addObject:aFakeArrival];
			[aFakeArrival release];
		}
		
		[cell setArrivals:arrivalsAtOneStopForOneBus];
		return cell;
	}
	else
	{
		StopCell *cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2 owner:self] autorelease];
		/* 
		//Notes: Due to what I believe to be a bug of UITextView,
		//       if I use the following code, the textView may not be updated properly.
		StopCell *cell = (StopCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
		if (cell == nil) 
		{
			cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2 owner:self] autorelease];
		}
		 */
		[cell setStop:[stopsOfInterest objectAtIndex:[indexPath section]]];
		return cell;
	}
	
	// Configure the cell
	//return cell;
}


-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath 
{
	return YES;
} 

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle != UITableViewCellEditingStyleDelete)
		return;
	
	if (indexPath.row == 0) //deleting a stop
	{
		//delete stopsDictionary, stopsOfInteger, and routesOfInterest
		BusStop *stopToDelete = [stopsOfInterest objectAtIndex:indexPath.section];
		removeAStopFromFavorite(stopToDelete.stopId);

		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [stopToDelete stopId]];
		[stopsDictionary removeObjectForKey:stopKey];
		[stopsOfInterest removeObjectAtIndex:indexPath.section];
		[routesOfInterest removeObjectAtIndex:indexPath.section];		
		[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];			
	}		
	else
	{
		//delete stopsDictionary, stopsOfInteger, and routesOfInterest
		BusStop *stopToDelete = [stopsOfInterest objectAtIndex:indexPath.section];
		NSMutableArray *routesToDelete = [routesOfInterest objectAtIndex:indexPath.section]; 
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [stopToDelete stopId]];
		if ([routesToDelete count] == 1)
		{
			removeAStopFromFavorite(stopToDelete.stopId);
			[stopsDictionary removeObjectForKey:stopKey];
			[stopsOfInterest removeObjectAtIndex:indexPath.section];
			[routesOfInterest removeObjectAtIndex:indexPath.section];			
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];			
		}
		else
		{			
			//Notes: the way it works in favorite gurantee there is alway something in there,
			//   even if it is a fake one.
			NSString *routeKeyToDelete = [routesToDelete objectAtIndex:(indexPath.row -1)];
			NSArray *arrivalsToDelete = [[stopsDictionary objectForKey:stopKey] objectForKey:routeKeyToDelete];
			BusArrival *theArrivalToDelete = [arrivalsToDelete objectAtIndex:0];
			removeFromFavorite2(stopToDelete.stopId, theArrivalToDelete.routeId, theArrivalToDelete.direction);
			[routesToDelete removeObjectAtIndex:(indexPath.row-1)];			

			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];			
		}
	}
	
	if ([stopsDictionary count] == 0)
		[tableView reloadData];
}


@end
