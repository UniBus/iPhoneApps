//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#import <sqlite3.h>
#import "FavoriteViewController.h"
#import "FavoriteViewController2.h"
#import "TripStopsViewController.h"
#import "TransitApp.h"
#import "BusArrival.h"
#import "StopCell.h"
#import "ArrivalCell.h"

//
//Return Values for stops: a Dictionary
// - [stop:$sid1]
//       - [stop:info:id]
//       - [stop:info:name]
// - repeat
//

//
//Return Values for routes: a Dictionary
// - [route:$rid1:dir_]
//       - [route:info:id]
//       - [route:info:name]
//       - [route:info:bussign]
//       - [route:info:dir]
// - repeat
//

NSArray *readFavoriteStops()
{
	NSMutableArray *favorites =[NSMutableArray array];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return favorites;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT favorites.stop_id, stops.stop_name "
					 "FROM favorites, stops "
					 "WHERE favorites.stop_id=stops.stop_id AND route_id='' "
					 "ORDER BY favorites.stop_id"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{			
			NSString *savedStopId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *savedStopName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			
			NSMutableDictionary *favoriteStop = [[NSMutableDictionary alloc] init];
			[favoriteStop setObject:savedStopId forKey:@"stop:info:id"];
			[favoriteStop setObject:savedStopName forKey:@"stop:info:name"];
			[favorites addObject:favoriteStop];
			[favoriteStop release];			
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
	return favorites;
}

NSArray * readFavoriteRoutes()
{
	NSMutableArray *favorites =[NSMutableArray array];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return favorites;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT favorites.route_id, routes.route_short_name, favorites.bus_sign, favorites.direction_id "
					 "FROM favorites, routes "
					 "WHERE stop_id='' AND routes.route_id=favorites.route_id "
					 "ORDER BY routes.route_id "];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{			
			NSString *savedRouteId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *savedRouteName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *savedRouteSign = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *savedRouteDir = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];

			NSMutableDictionary *favoriteRoute = [[NSMutableDictionary alloc] init];
			[favoriteRoute setObject:savedRouteId forKey:@"route:info:id"];
			[favoriteRoute setObject:savedRouteName forKey:@"route:info:name"];
			[favoriteRoute setObject:savedRouteSign forKey:@"route:info:bussign"];
			[favoriteRoute setObject:savedRouteDir forKey:@"route:info:dir"];
			[favorites addObject:favoriteRoute];
			[favoriteRoute release];
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
	return favorites;
}

BOOL saveRouteToFavorite(NSString *routeId, NSString *dirId, NSString *headSign, NSString *routeName)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
	//Delete those favorite with ambiguious direction.
	if (![dirId isEqualToString:@""])
	{
		sql = [NSString stringWithFormat:@"DELETE from favorites "
			   "WHERE stop_id='%@' AND route_id='%@' AND "
			   "direction_id='%@' AND route_name='%@' AND "
			   "bus_sign='%@'", 
			   @"", routeId, dirId, routeName, headSign];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
		{
			result = YES;
		}
		else
			NSLog(@"Error: %s", sqlite3_errmsg(database));				
	}
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorites(stop_id, route_id, route_name, bus_sign, direction_id) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
		   @"", routeId, routeName, (headSign? headSign:@""), dirId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL removeRouteFromFavorite(NSString *routeId, NSString *dirId, NSString *headSign)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
#ifdef DEBUGFULL
	sqlite3_stmt *statement;
	sql = [NSString stringWithFormat:@""
					 "SELECT stop_id, route_id FROM favorites "
					 "WHERE stop_id='%@' AND route_id='%@' AND direction_id='%@' AND head_sign='') ",
					 stopId, routeId, dirId, headSign];
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
	
	sql = [NSString stringWithFormat:@"DELETE from favorites "
		   "WHERE stop_id='%@' AND route_id='%@' AND "
		   "      direction_id='%@' AND head_sign='%@' ", 
		   @"", routeId, dirId, headSign];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL isRouteInFavorite(NSString *stopId, NSString *routeId, NSString *dirId, NSString *headSign)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@""
					 "SELECT stop_id, route_id FROM favorites "
					 "WHERE stop_id='%@' AND route_id='%@' AND direction_id='%@' AND bus_sign='%@' ",
					 stopId, routeId, dirId, headSign];
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

@implementation FavoriteViewController2

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	favoriteTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain]; 
	[favoriteTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	favoriteTableView.dataSource = self;
	favoriteTableView.delegate = self;
	self.view = favoriteTableView;
	
	//[stopSearchBar becomeFirstResponder];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Favorites";
	
	[self reset];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void) reset
{
	[favoriteStops release];
	[favoriteRoutes release];
	favoriteStops = [readFavoriteStops() retain];
	favoriteRoutes = [readFavoriteRoutes() retain];
	[favoriteTableView reloadData];
}

/*
- (void) needsReload
{
	[favoriteStops release];
	[favoriteRoutes release];
	favoriteStops = [readFavoriteStops() retain];
	favoriteRoutes = [readFavoriteRoutes() retain];
	[favoriteTableView reloadData];
}
 */


#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		TripStopsViewController *tripStopsVC = [[TripStopsViewController alloc] initWithNibName:nil bundle:nil];
		
		NSDictionary *aroute = [favoriteRoutes objectAtIndex:indexPath.row];
		tripStopsVC.routeId = [aroute objectForKey:@"route:info:id"];
		tripStopsVC.dirId = [aroute objectForKey:@"route:info:dir"];
		tripStopsVC.headSign = [aroute objectForKey:@"route:info:bussign"];
		tripStopsVC.queryByRouteId = YES;
		
		[[self navigationController] pushViewController:tripStopsVC animated:YES];
	}
	else if (indexPath.section == 0)
	{
		StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:nil bundle:nil];
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
		BusStop *aStop = [myApplication stopOfId:[[favoriteStops objectAtIndex:indexPath.row] objectForKey:@"stop:info:id"]];
		NSMutableArray *stopSelected = [NSMutableArray array];
		[stopSelected addObject:aStop];
		stopsVC.stopsOfInterest = stopSelected;
		[stopsVC reload];
		
		[[self navigationController] pushViewController:stopsVC animated:YES];
	}	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 1)
		return [favoriteRoutes count];
	else if (section == 0)
		return [favoriteStops count];
	else
		return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Stops";
	else if (section == 1)
		return @"Routes";
	else
		return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtCitySelectionView";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	}
	
	if (indexPath.section == 1)
	{
		NSDictionary *aroute = [favoriteRoutes objectAtIndex:indexPath.row];
		cell.textLabel.text = [aroute objectForKey:@"route:info:name"];
		cell.detailTextLabel.text =  [aroute objectForKey:@"route:info:bussign"];
	}
	else if (indexPath.section == 0)
	{
		NSDictionary *astop = [favoriteStops objectAtIndex:indexPath.row];
		cell.textLabel.text = [astop objectForKey:@"stop:info:name"];
		
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		NSArray *allRoutes = [myApplication allRoutesAtStop:[astop objectForKey:@"stop:info:id"]];
		NSString *routeString=@"";
		for (NSString *routeName in allRoutes)
		{
			if ([routeString isEqualToString:@""])
				routeString = routeName;
			else
				routeString = [routeString stringByAppendingFormat:@", %@", routeName];
		}
		//cell.textLabel.text = [NSString stringWithFormat:@"%@", aStop.description];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", routeString];	
	}
	
	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		// Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}   
	else if (editingStyle == UITableViewCellEditingStyleInsert) 
	{
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// Return NO if you do not want the item to be re-orderable.
	return NO;
}

@end

