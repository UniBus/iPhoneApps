//
//  TagManagerViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 07/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import <sqlite3.h>
#import "TransitApp.h"
#import "BusArrival.h"
#import "TagManagerViewController.h"
#import "TagAddingViewController.h"

NSMutableDictionary * readTags()
{
	NSMutableDictionary *favorites =[[NSMutableDictionary alloc] init];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	sqlite3 *database;
    if (sqlite3_open([[myApplication currentDatabaseWithFullPath] UTF8String], &database) != SQLITE_OK) 
		return favorites;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT stop_id, route_id, route_name, bus_sign, direction_id, tag FROM taggeds ORDER BY tag, stop_id, route_id"];
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

BOOL saveToTaggeds(NSString *stopId, NSString *routeId, NSString *routeName, NSString *busSign, NSString *dir)
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

BOOL removeFromTaggeds(NSString *stopId, NSString *routeId, NSString *dir)
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

BOOL removeAStopFromTaggeds(NSString *stopId)
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

BOOL isTagged(NSString *stopId, NSString *routeId, NSString *dir)
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


@implementation TagManagerViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTag)];
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


- (void) addTag
{	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		TagAddingViewController *tagAddingVC = [[TagAddingViewController alloc] initWithNibName:nil bundle:nil];
		//[navigController pushViewController:tagAddingVC animated:YES];
		[navigController presentModalViewController:tagAddingVC animated:YES];

		/*
		UIView *mainView = navigController.view;
		UIView *flipsideView = tagAddingVC.view;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1];
		[UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:navigController.view cache:YES];
		
		[tagAddingVC viewWillAppear:YES];
		//[navigController viewWillDisappear:YES];
		//[navigController.view removeFromSuperview];
		[navigController.view addSubview:tagAddingVC.view];
		//[navigController viewDidDisappear:YES];
		[tagAddingVC viewDidAppear:YES];
			
		[UIView commitAnimations];
		*/
		
	}	
}

/*
- (IBAction)toggleView:(id)sender {	
    // This method is called when the info or Done button is pressed.
    // It flips the displayed view from the main view to the flipside view and vice-versa.
	
	if (settingViewController == nil) {
		[self loadFlipsideViewController];
	}
	
	UIView *mainView = metronomeViewController.view;
	UIView *flipsideView = settingViewController.navigationController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ([mainView superview] != nil) {
		[settingViewController.navigationController viewWillAppear:YES];
		[metronomeViewController viewWillDisappear:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:flipsideView];
		[metronomeViewController viewDidDisappear:YES];
		[settingViewController.navigationController viewDidAppear:YES];
		
	} else {
		[metronomeViewController viewWillAppear:YES];
		[settingViewController.navigationController viewWillDisappear:YES];
		[flipsideView removeFromSuperview];
		[self.view addSubview:mainView];
		[settingViewController.navigationController viewDidDisappear:YES];
		[metronomeViewController viewDidAppear:YES];
	}
	[UIView commitAnimations];
}
*/
	
#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"All Tags";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtCitySelectionView";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	}

	cell.textLabel.text = @"Test Tag";
	
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

