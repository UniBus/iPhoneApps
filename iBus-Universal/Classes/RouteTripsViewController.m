//
//  TripViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "RouteTripsViewController.h"
#import "TripStopsViewController.h"
#import "DatePickViewController.h"
#import "TransitApp.h"
#import "FavoriteViewController.h"

enum _RouteTripsTableViewSection {
	kSection_Direction_0 = 0,
	kSection_Direction_1,
	kSection_Count
};

@implementation RouteTripsViewController

@synthesize theRoute;
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	tripsOnRoute = [[NSMutableArray alloc] init];
	[tripsOnRoute addObject:[NSMutableArray array]]; //for one direction
	[tripsOnRoute addObject:[NSMutableArray array]]; //for the other direction
	
	tripsTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[tripsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	tripsTableView.dataSource = self;
	tripsTableView.delegate = self;
	self.view = tripsTableView;
	self.navigationItem.title = @"Directions";
	
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
	[theRoute release];
	[tripsTableView release]; 	
    [super dealloc];
}

- (NSString *) routeID
{
	return theRoute.routeId;
}

#pragma mark Callback Function for tripsOnRoute query
- (void) tripsUpdated: (NSArray *)results
{
	[[tripsOnRoute objectAtIndex:0] removeAllObjects];
	[[tripsOnRoute objectAtIndex:1] removeAllObjects];
	
	for (BusTrip *aTrip in results)
	{
		NSLog(@"id=%@, headsign=%@", aTrip.tripId, aTrip.headsign);
		if (aTrip.direction == 0)
			[[tripsOnRoute objectAtIndex:0] addObject:aTrip];
		else
			[[tripsOnRoute objectAtIndex:1] addObject:aTrip];			
	}
	
	[tripsTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TripStopsViewController *tripStopsVC = [[TripStopsViewController alloc] initWithNibName:nil bundle:nil];
	tripStopsVC.theTrip = [[tripsOnRoute objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[[self navigationController] pushViewController:tripStopsVC animated:YES];	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if ( [tripsOnRoute count] == 0 )
		return 1;
	else
	{
		NSAssert1([tripsOnRoute count]==2, @"Something wrong with tripOnRoute, should have 2 elements, but it has %d instead!!", [tripsOnRoute count]);
		return [tripsOnRoute count];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (tripsOnRoute)
	{
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
	cell.text = aTrip.headsign;
	return cell;
}

@end
