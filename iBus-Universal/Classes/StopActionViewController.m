//
//  StopActionViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 05/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import "StopActionViewController.h"
#import "StopRouteViewHeader.h"
#import "StopMapViewController.h"
#import "FavoriteViewController.h"
#import "NearbyViewController.h"
#import "TransitApp.h"

@implementation StopActionViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	stopActionTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[stopActionTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopActionTableView.dataSource = self;
	stopActionTableView.delegate = self;
	
	StopRouteViewHeader *header = [[StopRouteViewHeader alloc] initWithFrame:CGRectZero];
	[header setIcon:kTransitIconTypeStop];
	[header setTitleInfo:theStop.name];
	[header setDetailInfo:theStop.description];
	
	stopActionTableView.tableHeaderView = header;
	[header release];
	
	self.view = stopActionTableView; 
	self.navigationItem.title = @"Selected Stop";
}

/*
 // Implement viewDidLoad to do additional setup after loading the view.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[theStop release];
	[stopActionTableView release]; 	
    [super dealloc];
}

- (void) notifyApplicationFavoriteChanged
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	@try {
		[myApplication.delegate performSelector:@selector(favoriteDidChange:) withObject:self];
	}
	@catch (NSException * e) {
		NSLog(@"didSelectRowAtIndexPath: Caught %@: %@", [e name], [e reason]);
	}
}

- (void) showStopOnMap
{
	if ( (theStop.latitude == 0) || (theStop.longtitude == 0) )
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"The location of the stop is not available!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return;
	}
	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		StopMapViewController *mapViewController = [[StopMapViewController alloc] initWithNibName:nil bundle:nil];
		[navigController pushViewController:mapViewController animated:YES];
		[mapViewController mapWithLatitude:theStop.latitude Longitude:theStop.longtitude];
		[mapViewController autorelease];
	}	
}

- (void) showNearbyStops
{
	if ( (theStop.latitude == 0) || (theStop.longtitude == 0) )
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"The location of the stop is not available!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return;
	}
	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		NearbyViewController *nearbyViewController = [[NearbyViewController alloc] initWithNibName:nil bundle:nil];
		[nearbyViewController setExplictLocation:CGPointMake(theStop.longtitude, theStop.latitude)];
		[navigController pushViewController:nearbyViewController animated:YES];
		[nearbyViewController autorelease];
	}	
}

#pragma mark Property Setter/Getter
- (void) setStop: (BusStop *) aStop
{
	[theStop release];
	theStop = [aStop retain];
	//self.navigationItem.title = [NSString stringWithFormat:@"Route:%@", routeName];
	
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//if (indexPath.section == 0)
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(theStop.stopId, @"", @""))
			removeFromFavorite2(theStop.stopId,  @"", @"");
		else
			saveToFavorite2(theStop.stopId, @"", @"", @"", @"");
		[tableView reloadData];
		
		[self notifyApplicationFavoriteChanged];
	}
	else
	{
		if (indexPath.row == 0)
			[self showStopOnMap];
		else
			[self showNearbyStops];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
		return 1;
	else if (section == 1)
		return 2;
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Bookmark?";
	else if (section == 1)
		return @"Related";
	return @"";
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (indexPath.section == 0)
 return CELL_LABEL_TOTAL_HEIGHT;
 else
 return CELL_REGULAR_HEIGHT;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtRouteView"];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CellIdentifierAtRouteView"] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(theStop.stopId, @"", @""))
			cell.textLabel.text = @"Remove from favorite";
		else
			cell.textLabel.text = @"Add to favorite";
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == 1)
	{
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Show on map";
		}
		else if (indexPath.row == 1)
		{
			cell.textLabel.text = @"Show nearby stops";
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

@end
