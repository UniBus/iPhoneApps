//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#import <sqlite3.h>
//#import "FavoriteViewController.h"
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
	
	NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT favorites2.stop_id, stops.stop_name, rowindex "
					 "FROM favorites2, stops "
					 "WHERE favorites2.stop_id=stops.stop_id AND route_id='' "
					 "ORDER BY favorites2.rowindex ASC"];
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
	
	NSString *sql = [NSString stringWithFormat:@""
					 "SELECT DISTINCT favorites2.route_id, routes.route_short_name, favorites2.bus_sign, favorites2.direction_id, rowindex "
					 "FROM favorites2, routes "
					 "WHERE stop_id='' AND routes.route_id=favorites2.route_id "
					 "ORDER BY favorites2.rowindex ASC"];
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
	//Currently only one route in one direction can be bookmarked.
	if (![dirId isEqualToString:@""])
	{
		sql = [NSString stringWithFormat:@""
			   "DELETE from favorites2 "
			   "WHERE stop_id='' AND route_id='%@' AND direction_id='' ", 
			   routeId];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
		{
			result = YES;
		}
		else
			NSLog(@"Error: %s", sqlite3_errmsg(database));				
	}
	
	sql = [NSString stringWithFormat:@""
		   "INSERT INTO favorites(stop_id, route_id, route_name, bus_sign, direction_id) "
		   "VALUES ('', '%@', '%@', '%@', '%@')",
		   routeId, routeName, (headSign? headSign:@""), dirId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL removeRouteFromFavorite(NSString *routeId, NSString *dirId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
		
	sql = [NSString stringWithFormat:@""
		   "DELETE from favorites2 "
		   "WHERE stop_id='' AND route_id='%@' AND direction_id='%@' ", 
		   routeId, dirId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL setRouteIndexInFavorite(NSString *routeId, NSString *dirId, NSInteger index)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
	sql = [NSString stringWithFormat:@""
		   "UPDATE OR IGNORE favorites2 "
		   "SET rowindex=%d "
		   "WHERE stop_id='' AND route_id='%@' AND direction_id='%@' ", 
		   index, routeId, dirId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL isRouteInFavorite(NSString *routeId, NSString *dirId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@""
					 "SELECT route_id FROM favorites2 "
					 "WHERE stop_id='' AND route_id='%@' AND direction_id='%@' ",
					 routeId, dirId];
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

BOOL saveStopToFavorite(NSString *stopId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;

	/* Make sure it has been checked that there is no such record in the table!
	 */
	sql = [NSString stringWithFormat:@""
		   "INSERT INTO favorites(stop_id, route_id, route_name, bus_sign, direction_id) "
		   "VALUES ('%@', '', '', '', '')", stopId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL removeStopFromFavorite(NSString *stopId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
	sql = [NSString stringWithFormat:@""
		   "DELETE from favorites2 "
		   "WHERE stop_id='%@' AND route_id='' AND direction_id='' AND bus_sign='' ", 
		   stopId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL setStopIndexInFavorite(NSString *stopId, NSInteger index)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = nil;
	
	sql = [NSString stringWithFormat:@""
		   "UPDATE OR IGNORE favorites2 "
		   "SET rowindex=%d "
		   "WHERE stop_id='%@' AND route_id='' AND direction_id='' AND bus_sign='' ", 
		   index, stopId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK)
	{
		result = YES;
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));			
	
	sqlite3_close(database);
	return result;
}

BOOL isStopInFavorite(NSString *stopId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL result = NO;
	NSString *sql = [NSString stringWithFormat:@""
					 "SELECT stop_id FROM favorites2 "
					 "WHERE stop_id='%@' AND route_id='' AND direction_id='' AND bus_sign='' ",
					 stopId];
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
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
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
	
	/* Here it assumes arrays returned from
	 *    - readFavoriteStops()
	 *    - readFavoriteRoutes()
	 *  are mutable array.
	 */
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
    [favoriteTableView setEditing:editing animated:YES];
}

-(void) reorderFavoriteStops
{
	for(int index=0; index<[favoriteStops count]; index++)
	{
		NSDictionary *astop = [favoriteStops objectAtIndex:index];
		setStopIndexInFavorite([astop objectForKey:@"stop:info:id"], index);		
	}
}

-(void) reorderFavoriteRoutes
{
	for(int index=0; index<[favoriteRoutes count]; index++)
	{
		NSDictionary *aroute = [favoriteRoutes objectAtIndex:index];
		setRouteIndexInFavorite([aroute objectForKey:@"route:info:id"], [aroute objectForKey:@"route:info:dir"], index);		
	}
}

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
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    // If row is deleted, remove it from the list.
    if (editingStyle != UITableViewCellEditingStyleDelete)
		return;
	
	if (indexPath.section == 0) //deleting a stop
	{
		NSDictionary *astop = [favoriteStops objectAtIndex:indexPath.row];
		removeStopFromFavorite([astop objectForKey:@"stop:info:id"]);
		[favoriteStops removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];			
	}		
	else if (indexPath.section == 1) //deleting a route 
	{
		NSDictionary *aroute = [favoriteRoutes objectAtIndex:indexPath.row];
		removeRouteFromFavorite([aroute objectForKey:@"route:info:id"], [aroute objectForKey:@"route:info:dir"]);
		[favoriteRoutes removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];			
	}
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	if (fromIndexPath.section != toIndexPath.section)
	{
		NSLog(@"Something wrong, this is not supposed to happen!!");
		return;
	}
	
	if (fromIndexPath.section == 0) //deleting a stop
	{
		NSDictionary *astop = [[favoriteStops objectAtIndex:fromIndexPath.row] retain];
		[favoriteStops removeObjectAtIndex:fromIndexPath.row];
		[favoriteStops insertObject:astop atIndex:toIndexPath.row];			
		[astop release];
		[self reorderFavoriteStops];
	}		
	else if (fromIndexPath.section == 1) //deleting a route 
	{
		NSDictionary *aroute = [[favoriteRoutes objectAtIndex:fromIndexPath.row] retain];
		[favoriteRoutes removeObjectAtIndex:fromIndexPath.row];
		[favoriteRoutes insertObject:aroute atIndex:toIndexPath.row];
		[aroute release];
		[self reorderFavoriteRoutes];
	}	
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (sourceIndexPath.section != proposedDestinationIndexPath.section)
		return sourceIndexPath;
	else
		return proposedDestinationIndexPath;
}

@end

