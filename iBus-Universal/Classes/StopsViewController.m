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
	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [NSMutableArray arrayWithArray:[defaults objectForKey:UserDefaults]];
	
	BOOL found = NO;
	SavedItem *theSavedItem = nil;
	int targetIndex = -1;
	for (int i=0; i<[favoriteArray count]; i++)
	{
		NSData *anItemData = [favoriteArray objectAtIndex:i];
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		if (anItem.stop.stopId == aStop.stopId)
		{
			theSavedItem = anItem;
			targetIndex = i;
			break;
		}
	}
	
	if (theSavedItem == nil)
	{
		theSavedItem = [[SavedItem alloc] init];
		theSavedItem.stop = aStop;
		[theSavedItem.buses addObject:anArrival];
		NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
		[favoriteArray addObject:theItemData];
		[theSavedItem autorelease];
	}
	else
	{
		for (BusArrival *anBusArrival in theSavedItem.buses)
		{
			if ([[anBusArrival busSign] isEqualToString:[anArrival busSign]])
			{
				found = YES;
				break;
			}
		}
		if (found == NO)
		{
			[theSavedItem.buses addObject:anArrival];
			NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
			[favoriteArray replaceObjectAtIndex:targetIndex withObject:theItemData];
		}
	}
	
	if (found == NO)
	{
		[defaults setObject:favoriteArray forKey:UserSavedFavoriteStopsAndBuses];
	}
	 */
}

void removeStopAndBusFromUserDefaultList(int aStopId, NSString *aBusSign, NSString *UserDefaults)
{
	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [NSMutableArray arrayWithArray:[defaults objectForKey:UserDefaults]];
	
	BOOL found = NO;
	SavedItem *theSavedItem = nil;
	int index = 0;
	for (; index < [favoriteArray count]; index++)
	{
		NSData *anItemData = [favoriteArray objectAtIndex:index];
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		if (anItem.stop.stopId == aStopId)
		{
			theSavedItem = anItem;
			int busIndexAtStop = 0;
			for (;busIndexAtStop<[theSavedItem.buses count];busIndexAtStop++)
			{
				BusArrival *anArrival = [theSavedItem.buses objectAtIndex:busIndexAtStop];
				if ([[anArrival busSign] isEqualToString:aBusSign])
				{
					found = YES;
					[theSavedItem.buses removeObjectAtIndex:busIndexAtStop];
					break;
				}
			}
			if (found) 
			{
				if ([theSavedItem.buses count]==0)
					[favoriteArray removeObjectAtIndex:index];
				else
				{
					NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
					[favoriteArray replaceObjectAtIndex:index withObject:theItemData];					
				}
			}
			break; 
		}
	}
		
	if (found)
	{
		[defaults setObject:favoriteArray forKey:UserSavedFavoriteStopsAndBuses];
	}
	 */
}

@implementation SavedItem
@synthesize stop, buses;
-(id) init
{
	[super init];
	buses = [[NSMutableArray alloc] init]; //it starts with an empty list
	return self;
}

- (void) dealloc
{
	[stop release];
	[buses release];
	[super dealloc];
}

- (id) initWithCoder: (NSCoder *) coder
{
	[super init];
	[stop release];
	[buses release];
	stop = [[coder decodeObjectForKey:@"Stop"] retain];
	buses = [[coder decodeObjectForKey:@"Buses"] retain];
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:stop forKey:@"Stop"];
	[coder encodeObject:buses forKey:@"Buses"];
}

@end

@implementation StopsViewController

@synthesize stopViewType;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		//self.navigationItem.prompt=@"Justacolor..."; 
	}
	
	return self;
}
*/
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
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
 - (void)viewDidLoad {
 }
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	//[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[arrivalsForStops release];
	[stopsOfInterest release];
	[super dealloc];
}

- (void) filterData
{
	//To be implemented in subclass;
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

- (void) clearArrivals
{
	NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
	NSString *key;
	while ((key = [enumerator nextObject])) 
	{
		NSMutableDictionary *routeAtStop = [stopsDictionary objectForKey:key];
		
		NSArray *allKeys = [routeAtStop allKeys];
		for (NSString *aRouteKey in allKeys)
		{
			if ([aRouteKey isEqualToString:@"stop:info:info"])
				continue;
			[routeAtStop removeObjectForKey:aRouteKey];
		}		
	}		
}

- (void) reload
{
	if (arrivalsForStops == nil)
		arrivalsForStops = [[NSMutableArray alloc] init];
	
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
		NSString *routeKey = [NSString stringWithFormat:@"route:%@", anArrival.route];

		NSMutableDictionary *aStopOfInterest = [stopsDictionary objectForKey:stopKey];	
		NSMutableArray *arrivalsOfRouteAtStop = [aStopOfInterest objectForKey:routeKey];
		if (arrivalsOfRouteAtStop == nil)
		{
			arrivalsOfRouteAtStop = [[NSMutableArray alloc] init];
			[aStopOfInterest setObject:arrivalsOfRouteAtStop forKey:routeKey];
		}
		[arrivalsOfRouteAtStop addObject:anArrival];
	}
	//[self filterData];

	if (routesOfInterest == nil) {
		routesOfInterest = [[NSMutableArray alloc] init];	
	}
	else {
		[routesOfInterest removeAllObjects];
	}

	NSEnumerator *enumerator = [stopsDictionary keyEnumerator];
	NSString *key;
	while ((key = [enumerator nextObject])) {
		NSDictionary *aStopInDictionary = [stopsDictionary objectForKey:key];
		
		NSArray *allKeys = [aStopInDictionary allKeys];
		NSMutableArray *routesAtAStop = [NSMutableArray array];
		for (NSString *aRouteKey in allKeys)
		{
			if ([aRouteKey isEqualToString:@"stop:info:info"])
				continue;
			[routesAtAStop addObject:aRouteKey];
		}
		[routesOfInterest addObject:routesAtAStop];
		
	}

	//UITableView *tableView = (UITableView *) self.view;
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
}

#pragma mark Setter/Getter of stopsOfInterest

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
	for (BusStop *aStop in stopsOfInterest)
	{
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [aStop stopId]];
		NSMutableDictionary *aStopInDictionary = [stopsDictionary objectForKey:stopKey];
		if (aStopInDictionary == nil)
		{
			aStopInDictionary = [[NSMutableDictionary alloc] init];
			[aStopInDictionary setObject:aStop forKey:@"stop:info:info"];
			[stopsDictionary setObject:aStopInDictionary forKey:stopKey];
		}
	}
}

#pragma mark Stop/Arrival Data

- (void) busArrivalBookmarked: (BusArrival *)theArrival
{
	//To be finished
}

- (void) showMapOfAStop: (BusStop *)theStop
{
	MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		[navigController pushViewController:mapViewController animated:YES];
		[mapViewController mapWithLatitude:theStop.latitude Longitude:theStop.longtitude];
	}	
}

- (NSArray *) arrivalsOfOneBus: (NSArray*) arrivals ofIndex: (int)index
{
	/*Find out how many buses arrive at this stop*/
	NSMutableArray *result = [[NSMutableArray alloc] init];
	if ([arrivals count] )
	{
		BusArrival *anArrival = [arrivals objectAtIndex:0];
		NSString *theBusSign = [anArrival busSign];
		int currentIndex = 0;
		
		if (index == currentIndex)
			[result addObject:anArrival];
		
		for (int i=1; i<[arrivals count]; i++)
		{
			anArrival = [arrivals objectAtIndex:i];
			
			if (![theBusSign isEqualToString:[anArrival busSign]])
			{
				theBusSign = [[arrivals objectAtIndex:i] busSign];
				currentIndex ++;
			}
			
			if (index == currentIndex)
				[result addObject:anArrival];
			else if (currentIndex > index)
				break;		
		}		
	}
	
	return [result autorelease];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		UITableViewCell *stopCell = [tableView cellForRowAtIndexPath:indexPath];
		if ([stopCell isKindOfClass:[StopCell class]])
		{
			[(StopCell *)stopCell mapButtonClicked:self];
		}			
	}
	else
	{
		
		NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [[stopsOfInterest objectAtIndex:indexPath.section] stopId]];
		NSDictionary *aStopInDictionary = [stopsDictionary objectForKey:stopKey];
		NSArray *allRouteKeysAtAStop = [routesOfInterest objectAtIndex:indexPath.section];
		NSString *routeKey = [allRouteKeysAtAStop objectAtIndex:(indexPath.row-1)];
		NSArray *arrivalsAtOneStopForOneBus = [aStopInDictionary objectForKey:routeKey];
		
		BusArrival *anArrival = nil;
		if (arrivalsAtOneStopForOneBus)
			if ([arrivalsAtOneStopForOneBus count] > 0)
				anArrival = [arrivalsAtOneStopForOneBus objectAtIndex:0];
		RouteActionViewController *routeActionVC = [[RouteActionViewController alloc] initWithNibName:nil bundle:nil];
		
		UINavigationController *navigController = [self navigationController];
		if (navigController)
		{
			[routeActionVC  showInfoOfRoute:anArrival.route atStop:anArrival.stopId];	
			[navigController pushViewController:routeActionVC animated:YES];
		}	
		
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
	if ([stopsDictionary count] == 0)
		return 0;
	
	NSString *stopKey = [NSString stringWithFormat:@"stop:%@", [[stopsOfInterest objectAtIndex:section] stopId]];
	NSDictionary *favoriteStop =  [stopsDictionary  objectForKey:stopKey];
	return [favoriteStop count];
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
	static NSString *MyIdentifier = @"MyIdentifier";
	static NSString *MyIdentifier2 = @"MyIdentifier2";
	
	if ([indexPath row] >= 1)
	{
		ArrivalCell *cell = (ArrivalCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
											//Assume in dequeResableCellWithIdentifier, autorelease has been called
		if (cell == nil) 
		{
			cell = [[[ArrivalCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier viewType:stopViewType owner:self] autorelease];
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
	
	// Configure the cell
	//return cell;
}


/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 }
 */
/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 }
 if (editingStyle == UITableViewCellEditingStyleInsert) {
 }
 }
 */
/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */
/*
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */
/*
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

#pragma mark Test Functions

- (void) testFunction
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	BusStop *aStop = [myApplication stopOfId:@"10324"];
	NSMutableArray *stops = [[NSMutableArray alloc] init];
	if (aStop)
	{
		[stops addObject:aStop];
	}
	
	self.stopsOfInterest = stops;
	[self reload];
}

@end

