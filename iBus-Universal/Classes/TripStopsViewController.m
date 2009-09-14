//
//  TripViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "TripStopsViewController.h"
#import "TripMapViewController.h"
#import "RouteScheduleViewController.h"
#import "DatePickViewController.h"
#import "TransitApp.h"
#import "FavoriteViewController2.h"
#import "RouteTripsViewController.h"

enum _TripStopsTableViewSection {
	kSection_RouteAction = 0,
	kSection_StopsList,
	kSection_Count
};

@implementation TripStopsViewController
@synthesize tripId, routeId, dirId, headSign, queryByRouteId;

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
	self.navigationItem.prompt = @"Updating...";
	
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
	[tripId release];
	[routeId release];
	[dirId release];
	[headSign release];
	[stopsTableView release]; 	
    [super dealloc];
}

#pragma mark Callback Function for tripsOnRoute query
- (void) stopsUpdated: (NSArray *)results returnedTrip: (BusTrip *) aTrip
{
	[stopIdsOnTrip removeAllObjects];
	
	for (NSString *aStopId in results)
	{
		[stopIdsOnTrip addObject:aStopId];
	}
	
	if (aTrip)
	{
		self.tripId =  [aTrip.tripId retain];
		self.routeId = [aTrip.routeId retain];
		self.dirId = [aTrip.direction retain];
		self.headSign = [aTrip.headsign retain];
	}
	
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
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

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		switch (indexPath.row) {
			case 0:
			{
				TripMapViewController *mapViewController = [[TripMapViewController alloc] initWithNibName:nil bundle:nil];
				
				UINavigationController *navigController = [self navigationController];
				if (navigController)
				{
					[navigController pushViewController:mapViewController animated:YES];
					[mapViewController mapWithTrip:self.tripId];
					[mapViewController autorelease];
				}	
				break;
			}
				
			case 1:
			{
				if (isRouteInFavorite(routeId, dirId))
					removeRouteFromFavorite(routeId, dirId);
				else
					saveRouteToFavorite(routeId, dirId, headSign, @"");
					//saveRouteToFavorite(routeId, dirId, headSign);
				
				[tableView reloadData];
				
				[self notifyApplicationFavoriteChanged];
				
				break;
			}
				
			case 2:
			{
				RouteTripsViewController *routeTripsVC = [[RouteTripsViewController alloc] initWithNibName:nil bundle:nil];
				routeTripsVC.routeID =  self.routeId;
				routeTripsVC.dirID = @"";
				[[self navigationController] pushViewController:routeTripsVC animated:YES];
				break;
			}
			
			default:
				break;
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kSection_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == kSection_RouteAction)
	{
		UIViewController *parentViewCtrl = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count]-2)];
		if ([parentViewCtrl isKindOfClass:[RouteTripsViewController class]])
			return 2;
		else
			return 3;
	}
	else if (section == kSection_StopsList)
		return [stopIdsOnTrip count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kSection_RouteAction)
		return @"";
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
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}		
		if (indexPath.row == 0)
			cell.textLabel.text = @"Show it on map!";
		else if (indexPath.row == 1)
		{
			if (isRouteInFavorite(routeId, dirId))
				cell.textLabel.text = @"Unbookmark the route";
			else
				cell.textLabel.text = @"Bookmark the route";
		}
		else if (indexPath.row == 2)
			cell.textLabel.text = @"All destinations of the route!";
	}
	else if (indexPath.section == 1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"StopsOnTripCell-Stop"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StopsOnTripCell-Stop"] autorelease];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		}
		
		NSString *aStopId = [stopIdsOnTrip objectAtIndex:indexPath.row];
		
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 		
		BusStop *aStop = [myApplication stopOfId:aStopId];
		cell.textLabel.text = aStop.name;
		
		NSArray *allRoutes = [myApplication allRoutesAtStop:aStopId];
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

@end
