//
//  TripViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#import "RouteTripsViewController.h"
#import "TripStopsViewController.h"
#import "DatePickViewController.h"
#import "TransitApp.h"
//#import "FavoriteViewController.h"

enum _RouteTripsTableViewSection {
	kSection_Direction_0 = 0,
	kSection_Direction_1,
	kSection_Count
};

@implementation RouteTripsViewController

@synthesize routeID, dirID;

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	tripsOnRoute = [[NSMutableArray alloc] init];
	//[tripsOnRoute addObject:[NSMutableArray array]]; //for one direction
	//[tripsOnRoute addObject:[NSMutableArray array]]; //for the other direction
	
	tripsTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[tripsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	tripsTableView.dataSource = self;
	tripsTableView.delegate = self;
	self.view = tripsTableView;
	self.navigationItem.title = @"Directions";
	self.navigationItem.prompt = @"Updating...";
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
	
	[myApplication tripsOnRouteAtStopsAsync:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[tripsOnRoute release];
	[routeID release];
	[dirID release];
	[tripsTableView release]; 	
    [super dealloc];
}

#pragma mark Callback Function for tripsOnRoute query
- (void) tripsUpdated: (NSArray *)results
{
	[tripsOnRoute removeAllObjects];
	[tripsOnRoute addObject:[NSMutableArray array]]; //for one direction
	//[[tripsOnRoute objectAtIndex:0] removeAllObjects];
	//[[tripsOnRoute objectAtIndex:1] removeAllObjects];
	if ([results count])
	{
		BusTrip *testingTrip = [results objectAtIndex:0];
		if (![testingTrip.direction isEqualToString:@""])
			[tripsOnRoute addObject:[NSMutableArray array]]; //for one direction
	}
	
	for (BusTrip *aTrip in results)
	{
		NSLog(@"id=%@, headsign=%@", aTrip.tripId, aTrip.headsign);
		if ([aTrip.direction isEqualToString:@"1"])
			[[tripsOnRoute objectAtIndex:1] addObject:aTrip];
		else
			[[tripsOnRoute objectAtIndex:0] addObject:aTrip];			
	}
	
	[tripsTableView reloadData];
	self.navigationItem.prompt = nil;
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TripStopsViewController *tripStopsVC = [[TripStopsViewController alloc] initWithNibName:nil bundle:nil];
	BusTrip *theTrip = [[tripsOnRoute objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	tripStopsVC.tripId = theTrip.tripId;
	tripStopsVC.queryByRouteId = NO;
	[[self navigationController] pushViewController:tripStopsVC animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if ( [tripsOnRoute count] == 0 )
		return 1;
	else
	{
		NSAssert1([tripsOnRoute count]<=2, @"Something wrong with tripOnRoute, should have at most 2 elements, but it has %d instead!!", [tripsOnRoute count]);
		return [tripsOnRoute count];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (tripsOnRoute)
	{
		if ([tripsOnRoute count] == 0)
			return 0;
		NSArray *tripsInTheDirection = [tripsOnRoute objectAtIndex:section];
		if (tripsInTheDirection)
			return [tripsInTheDirection count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:@"TripsOfRouteCell"];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TripsOfRouteCell"] autorelease];
	}		
	BusTrip *aTrip = [[tripsOnRoute objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if (![aTrip.headsign isEqualToString:@""])
		cell.textLabel.text = aTrip.headsign;
	else
	{
		if ([aTrip.direction isEqualToString:@"0"])
			cell.textLabel.text = @"Outbound";
		else if ([aTrip.direction isEqualToString:@"1"])
			cell.textLabel.text = @"Inbound";
		else
			cell.textLabel.text = @"Unknown";
			
	}
	return cell;
}

@end
