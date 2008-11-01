//
//  StopsViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopsViewController.h"
#import "StopCell.h"
#import "ArrivalCell.h"
#import "BusArrival.h"
#import "BusStop.h"
#import "BusArrival.h"
#import "TransitApp.h"
#import "MapViewController.h"
#import "RouteActionViewController.h"

#define kUIStop_Section_Height		([StopCell height])
#define kUIArrival_Section_Height	([ArrivalCell height])

#pragma mark UserDefaults for Recent-List and Favorite-List

void addStopAndBusToUserDefaultList(BusStop *aStop, BusArrival *anArrival, NSString *UserDefaults)
{
}

void removeStopAndBusFromUserDefaultList(int aStopId, NSString *aBusSign, NSString *UserDefaults)
{
}

@implementation StopsViewController

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[stopsTableView release];
	stopsTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
												  style:UITableViewStyleGrouped]; 
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopsTableView.delegate = self;
	stopsTableView.dataSource = self;
	self.view = stopsTableView; 
	//[stopsTableView release]; Since I will use this all the time.
	self.navigationItem.title = @"Stop Info";
	
	UIBarButtonItem*refreshButton=[[UIBarButtonItem alloc] initWithTitle:@"Refresh"
																   style:UIBarButtonItemStylePlain 
																  target:self
																  action:@selector(refreshClicked:)]; 
	self.navigationItem.rightBarButtonItem=refreshButton; 	
}

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad 
{
 	[self needsReload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[stopsDictionary removeAllObjects];
	[stopsDictionary release];
	[stopsOfInterest release];
	[routesOfInterest release];
	[stopsTableView release];
	[super dealloc];
}

- (void) refreshClicked:(id)sender
{
	[routesOfInterest removeAllObjects];
	[self reload];
}

- (void) needsReload
{
	//To be implemented in subclasses;
}

- (void) alertOnEmptyStopsOfInterest
{
	//To be implemented in subclasses
	
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"There is no stops"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	//Show some info to user here!
}

#pragma mark Stops/Arrivals data manipulation.

- (void) reset
{
	needReset = YES;
}

- (void) clearArrivals
{
	@try{
		NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
		NSString *key;
		while ((key = [enumerator nextObject])) 
		{
			NSMutableDictionary *routeAtStop = [stopsDictionary objectForKey:key];
			
			NSArray *allKeys = [routeAtStop allKeys];
			for (NSString *aRouteKey in allKeys)
			{
				if ([aRouteKey rangeOfString:@"stop:info"].length)
					continue;
				[routeAtStop removeObjectForKey:aRouteKey];
			}		
		}
	}
	@catch (NSException *err) {
		NSLog(@"Exception catch in clearArrivals function");
	}
}

- (void) reload
{
	if ([stopsOfInterest count] == 0)
	{
		[self arrivalsUpdated: [NSMutableArray array]];		
		[self alertOnEmptyStopsOfInterest];
		return;
	}
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
	
	self.navigationItem.prompt = @"Updating...";
	[myApplication arrivalsAtStopsAsync:self];
	
	[stopsTableView reloadData];
}

- (void) arrivalsUpdated: (NSArray *)results
{
	[self clearArrivals];
	
	for (BusArrival *anArrival in results)
	{
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", anArrival.stopId];
		NSString *routeKey = [NSString stringWithFormat:@"route:%@", anArrival.routeId];
		
		NSMutableDictionary *aStopOfInterest = [stopsDictionary objectForKey:stopKey];	
		NSMutableArray *arrivalsOfRouteAtStop = [aStopOfInterest objectForKey:routeKey];
		if (arrivalsOfRouteAtStop == nil)
		{
			arrivalsOfRouteAtStop = [[NSMutableArray alloc] init];
			[aStopOfInterest setObject:arrivalsOfRouteAtStop forKey:routeKey];
			[arrivalsOfRouteAtStop release];
		}
		[arrivalsOfRouteAtStop addObject:anArrival];
	}
	//[self filterData];
		
	for (int i=0; i<[stopsOfInterest count]; i++)
	{
		BusStop *aStop = [stopsOfInterest objectAtIndex:i];
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [aStop stopId]];
		NSMutableDictionary *aStopInDictionary = [stopsDictionary objectForKey:stopKey];

		NSAssert(aStopInDictionary != nil, @"Having a NIL stop in stopsDictionary");
		NSArray *allKeys = [aStopInDictionary allKeys];
		NSMutableArray *routesAtAStop = [NSMutableArray array];
		for (NSString *aRouteKey in allKeys)
		{
			if ([aRouteKey rangeOfString:@"stop:info"].length)
				continue;
			[routesAtAStop addObject:aRouteKey];
		}
		[routesOfInterest addObject:routesAtAStop];		
		
	}	
	
	/*
	NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
	NSString *key;
	while ((key = [enumerator nextObject])) {
		NSDictionary *aStopInDictionary = [stopsDictionary objectForKey:key];
		
		NSArray *allKeys = [aStopInDictionary allKeys];
		NSMutableArray *routesAtAStop = [NSMutableArray array];
		for (NSString *aRouteKey in allKeys)
		{
			if ([aRouteKey rangeOfString:@"stop:info"].length)
				continue;
			[routesAtAStop addObject:aRouteKey];
		}
		[routesOfInterest addObject:routesAtAStop];		
	}
	 */
	
	//UITableView *tableView = (UITableView *) self.view;
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
}

- (NSArray *) stopsOfInterest
{
	return stopsOfInterest;
}

- (void) setStopsOfInterest: (NSArray *)stops
{
	[stopsOfInterest release];
	stopsOfInterest = [stops retain];
	
	if (stopsDictionary == nil)	{
		stopsDictionary = [[NSMutableDictionary alloc] init];
	}
	else {
		[stopsDictionary removeAllObjects];
	}
	
	[stopsDictionary removeAllObjects];	
	for (int i=0; i<[stopsOfInterest count]; i++)
	{
		BusStop *aStop = [stopsOfInterest objectAtIndex:i];
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [aStop stopId]];
		NSMutableDictionary *aStopInDictionary = [stopsDictionary objectForKey:stopKey];
		if (aStopInDictionary == nil)
		{
			aStopInDictionary = [[NSMutableDictionary alloc] init];
			[aStopInDictionary setObject:aStop forKey:@"stop:info:info"];
			[stopsDictionary setObject:aStopInDictionary forKey:stopKey];
			[aStopInDictionary release];
		}
	}
	
	if (routesOfInterest == nil) {
		routesOfInterest = [[NSMutableArray alloc] init];	
	}
	else {
		[routesOfInterest removeAllObjects];
	}	
}

- (void) showMapOfAStop: (BusStop *)theStop
{
	MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		[navigController pushViewController:mapViewController animated:YES];
		[mapViewController mapWithLatitude:theStop.latitude Longitude:theStop.longtitude];
		[mapViewController autorelease];
	}	
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		StopCell *stopCell = (StopCell *)[tableView cellForRowAtIndexPath:indexPath];
		NSAssert([stopCell isKindOfClass:[StopCell class]], @"Stop cell type mismatched!!");
		[self showMapOfAStop:[stopCell stop]];
	}
	else
	{
		ArrivalCell *arrivalCell = (ArrivalCell *)[tableView cellForRowAtIndexPath:indexPath];
		NSAssert([arrivalCell isKindOfClass:[ArrivalCell class]], @"Arrival cell type mismatched!!");
		BusArrival *anArrival = [arrivalCell firstArrival];
		
		if (anArrival)
		{
			RouteActionViewController *routeActionVC = [[RouteActionViewController alloc] initWithNibName:nil bundle:nil];
			
			UINavigationController *navigController = [self navigationController];
			if (navigController)
			{
				BusStop *associatedStop = [stopsOfInterest objectAtIndex:indexPath.section];
				[routeActionVC  showInfoOfRoute:anArrival.route 
										routeId:anArrival.routeId 
										 atStop:associatedStop.name 
										 stopId:anArrival.stopId 
									   withSign:anArrival.busSign];	
				[navigController pushViewController:routeActionVC animated:YES];
			}
		}
		else
			NSLog(@"Get an empty set of arrival!");
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (stopsOfInterest == nil)
		return 1;
	
	if ([stopsOfInterest count] == 0)
		return 1;
	
	return [stopsOfInterest count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	@try {
		if ([stopsDictionary count] == 0)
			return 0;
		
		//This basically mean the arrivals data haven't been updated yet!
		if ([routesOfInterest count] == 0) 
			return 1;
		
		NSArray *routesAtAStop = [routesOfInterest objectAtIndex:section];
		return [routesAtAStop count] + 1;
	}
	@catch (NSException * e) {
		NSLog(@"Exception catch in clearArrivals numberOfRowsInSection");
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (stopsOfInterest == nil)
		return @"";
	
	if ([stopsOfInterest count] == 0)
		return @"No stops!";
	
	BusStop *aStop = [stopsOfInterest objectAtIndex:section];
	if (aStop == nil)
		return @"No stops!";
	
	return [NSString stringWithFormat:@"%@", aStop.name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
		return kUIStop_Section_Height;
	else
		return kUIArrival_Section_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	@try {
		static NSString *MyIdentifier = @"MyIdentifier";
		static NSString *MyIdentifier2 = @"MyIdentifier2";
		
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
			//if ([arrivalsAtOneStopForOneBus count] == 0)
			//{
			//	BusArrival *aFakeArrival
			//	[arrivalsAtOneStopForOneBus addObject:aFakeArrival];
			//}
			
			[cell setArrivals:arrivalsAtOneStopForOneBus];
			return cell;
		}
		else
		{
			StopCell *cell = (StopCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
			if (cell == nil) 
			{
				cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2 owner:self] autorelease];
			}
			[cell setStop:[stopsOfInterest objectAtIndex:[indexPath section]]];
			return cell;
		}
	}
	@catch (NSException * e) {
		NSLog(@"Exception catch in clearArrivals cellForRowAtIndexPath");
	}
	return 0;
}

@end

