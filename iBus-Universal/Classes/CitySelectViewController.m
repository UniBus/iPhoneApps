//
//  CitySelectAppDelegate.m
//  CitySelect
//
//  Created by Zhenwang Yao on 19/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "CitySelectViewController.h"
#import "TransitApp.h"
#import "GTFSCity.h"
//#import "parseCSV.h"

@interface CitySelectViewController()
- (void) retrieveSupportedCities;
@end


@implementation CitySelectViewController

@synthesize delegate, currentCity, currentCityId, currentURL, currentDatabase;

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[self retrieveSupportedCities];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
														  style:UITableViewStyleGrouped]; 
	[tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	tableView.delegate = self;
	tableView.dataSource = self;
	self.view = tableView; 
	[tableView release];
	
	self.navigationItem.title = @"Select a City";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[localCities release];
	[onlineCities release];
	[super dealloc];
}

#pragma mark Operation on "gtfs_info.sqlite"
- (void) retrieveSupportedCities
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		NSLog(NO, @"Open database Error!");

	if (localCities == nil)
		localCities = [[NSMutableArray alloc] init];
	if (onlineCities == nil)
		onlineCities = [[NSMutableArray alloc] init];
	[localCities removeAllObjects];	
	[onlineCities removeAllObjects];	
	// (id, name, state, country, website, dbname, lastupdate, local)
	NSString *sql = [NSString stringWithFormat:@"SELECT id, name, state, country, website, dbname, lastupdate, local FROM cities ORDER BY country, state, name"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			GTFS_City *city = [[GTFS_City alloc] init];

			// All properties are (retain)
			city.cid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			city.cname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			city.cstate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			city.country = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			city.website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			city.dbname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			city.lastupdate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			city.local = sqlite3_column_int(statement, 7);
			if (city.local == 1)
				[localCities addObject:city];
			else
				[onlineCities addObject:city];
			[city release];
		}
	}
	else
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
}
 
 
#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"Use Online Update to Download!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];		
		return;
	}
	
	//select row: indexPath.row
	GTFS_City *selectedCity = [localCities objectAtIndex:indexPath.row];
	currentCityId = selectedCity.cid;
	currentCity = [[NSString stringWithFormat:@"%@, %@, %@", selectedCity.cname, selectedCity.cstate, selectedCity.country] retain];
	currentURL = selectedCity.website;
	currentDatabase = selectedCity.dbname;
	
	//NSLog(@"City: %@", currentCity);
	//NSLog(@"URL : %@", currentURL);
	//NSLog(@"Path: %@", currentDir);
	@try
	{
		if (delegate)
			[delegate performSelector:@selector(citySelected:) withObject:self];
	}
	@catch (NSException *exception)
	{
		NSLog(@"didSelectRowAtIndexPath: Caught %@: %@", [exception name], [exception  reason]);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
	{
		if ([localCities count] == 0)
			return 1;
		else
			return [localCities count];	
	}
	else
	{
		if ([onlineCities count] == 0)
			return 1;
		else
			return [onlineCities count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Cities on your device";
	else
		return @"More cities on-line";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSMutableArray *currentArray = nil;
	if (indexPath.section == 0)
		currentArray = localCities;
	else
		currentArray = onlineCities;
		
	
	NSString *MyIdentifier = @"CellIdentifierAtCitySelectionView";	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentCenter;
	}
	
	if ([currentArray count] ==0)
	{
		cell.text = @"Check out Online update for more!";
	}
	else
	{	
		GTFS_City *selectedCity = [currentArray objectAtIndex:indexPath.row];
		cell.text = [NSString stringWithFormat:@"%@, %@, %@", selectedCity.cname, selectedCity.cstate, selectedCity.country];
	}

	return cell;
}

@end
