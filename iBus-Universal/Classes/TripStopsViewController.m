//
//  TripViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TripStopsViewController.h"
#import "TripMapViewController.h"
#import "RouteScheduleViewController.h"
#import "DatePickViewController.h"
#import "TransitApp.h"
#import "FavoriteViewController.h"

enum _TripStopsTableViewSection {
	kSection_ShowInMap = 0,
	kSection_StopsList,
	kSection_Count
};

@implementation TripStopsViewController
@synthesize theTrip;

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	stopIdsOnTrip = [[NSMutableArray alloc] init];
	stopsTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopsTableView.dataSource = self;
	stopsTableView.delegate = self;
	self.view = stopsTableView; 
	self.navigationItem.title = @"Stops";
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
	
	[myApplication stopsOnTripAtStopsAsync:self];
	
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
	[stopIdsOnTrip release];
	//[stopsOnTrip release];
	[theTrip release];
	[stopsTableView release]; 	
    [super dealloc];
}

- (NSString *) tripID
{
	return theTrip.tripId;
}

#pragma mark Callback Function for tripsOnRoute query
- (void) stopsUpdated: (NSArray *)results
{
	[stopIdsOnTrip removeAllObjects];
	
	for (NSString *aStopId in results)
	{
		[stopIdsOnTrip addObject:aStopId];
	}
	
	[stopsTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		TripMapViewController *mapViewController = [[TripMapViewController alloc] initWithNibName:nil bundle:nil];
		
		UINavigationController *navigController = [self navigationController];
		if (navigController)
		{
			[navigController pushViewController:mapViewController animated:YES];
			[mapViewController mapWithTrip:self.theTrip.tripId];
			[mapViewController autorelease];
		}	
	}
	else
	{
		StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:nil bundle:nil];
		NSMutableArray *stopsSelected = [NSMutableArray array];
		NSString *selectedStopId = [stopIdsOnTrip objectAtIndex:indexPath.row];
		[stopsSelected addObject:[(TransitApp *) [UIApplication sharedApplication] stopOfId:selectedStopId]];
		
		stopsVC.stopsOfInterest = stopsSelected;
		[stopsVC reload];
		
		[[self navigationController] pushViewController:stopsVC animated:YES];	
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kSection_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == kSection_ShowInMap)
		return 1;
	else if (section == kSection_StopsList)
		return [stopIdsOnTrip count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kSection_ShowInMap)
		return @"Show on map";
	else if (section == kSection_StopsList)
		return @"All stops on the route?";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	UITableViewCell *cell;
	if (indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"StopsOnTripCell-Map"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"StopsOnTripCell-Map"] autorelease];
		}		
		cell.text = @"Show the route on map!";
	}
	else if (indexPath.section == 1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"StopsOnTripCell-Stop"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"StopsOnTripCell-Stop"] autorelease];
		}
		
		NSString *aStopId = [stopIdsOnTrip objectAtIndex:indexPath.row];
		
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 		
		BusStop *aStop = [myApplication stopOfId:aStopId];
		cell.text = aStop.name;
	}
	
	return cell;
}

@end
