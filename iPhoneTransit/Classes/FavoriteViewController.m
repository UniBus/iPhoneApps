//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"
#import "TransitApp.h"
#import "BusArrival.h"

@implementation FavoriteViewController

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[super loadView];
	self.stopViewType = kStopViewTypeToDelete;
	self.navigationItem.title = @"Favorite Stops";
}

- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}

- (void) alertOnEmptyStopsOfInterest
{
}

- (void) needsReload
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	if (!myApplication.arrivalQueryAvailable)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [defaults objectForKey:UserSavedFavoriteStopsAndBuses];
	
	NSMutableArray *newStops = [NSMutableArray array];
	NSMutableArray *newBuses = [NSMutableArray array];

	for (NSData *anItemData in favoriteArray)
	{
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		BusStop *aStop = [myApplication stopOfId:anItem.stop.stopId];
		
		if (aStop == nil)
		{
			//which means the data is not ready yet!!
			[newStops addObject:anItem.stop];
			[newBuses addObject:anItem.buses];
		}
		else
		{		
			[newStops addObject:aStop];
			[newBuses addObject:anItem.buses];
		}
	}
	
	stopsOfInterest = [newStops retain];
	
	[busesOfInterest release]; //should I use autorelease here?
	busesOfInterest = [newBuses retain];
	
	[self reload];
}


- (BOOL) isInFavoriteList: (BusArrival*) anArrival
{
	BOOL found = NO;
	for (int i=0; i<[stopsOfInterest count]; i++)
	{
		BusStop *aStop = [stopsOfInterest objectAtIndex:i];
		if (aStop.stopId == anArrival.stopId)
		{
			NSMutableArray *allBueses = [busesOfInterest objectAtIndex:i];
			for (BusArrival *aBusArrival in allBueses)
			{
				if ([[aBusArrival busSign] isEqualToString:anArrival.busSign])
				{
					found = YES;
					break;
				}
			}
			break;
		}
	}
	return found;
}

- (void) filterData
{
	//I assumed if there is an arrival for a stop, there should be problem finding the stop!
	for (NSMutableArray *arrivalsForOneStop in arrivalsForStops)
	{
		NSMutableIndexSet *indexSetToDelete = [NSMutableIndexSet indexSet];
		for (int i=0; i<[arrivalsForOneStop count]; i++)
		{
			BusArrival *anArrival = [arrivalsForOneStop objectAtIndex:i];
			if (![self isInFavoriteList:anArrival])
				[indexSetToDelete addIndex:i];				
		}
		if ([indexSetToDelete count])
			[arrivalsForOneStop removeObjectsAtIndexes:indexSetToDelete];
	}
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
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

#pragma mark TableView Delegate Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (busesOfInterest == nil)
		return 0;
	
	if ([busesOfInterest count] == 0)
		return 0;
	
	NSMutableArray *arrivalsForOneStop = [busesOfInterest objectAtIndex:section];
	if (arrivalsForOneStop == nil)
		return 0;
	
	return [arrivalsForOneStop count]+1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (stopsOfInterest == nil)
		return @"";
	
	if ([stopsOfInterest count] == 0)
		return @"Empty favorite list!";
	
	BusStop *aStop = [stopsOfInterest objectAtIndex:section];
	if (aStop == nil)
		return @"Empty favorite list!";
	
	return [NSString stringWithFormat:@"%@", aStop.name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	static NSString *MyIdentifier2 = @"MyIdentifier2";
	
	if ([indexPath row] >= 1)
	{
		ArrivalCell *cell = (ArrivalCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) 
		{
			cell = [[[ArrivalCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier viewType:stopViewType owner:self] autorelease];
		}
		
		NSMutableArray *arrivalsAtOneStop = [arrivalsForStops objectAtIndex:[indexPath section]];
		NSArray *arrivalsAtOneStopForOneBus = [self arrivalsOfOneBus:arrivalsAtOneStop ofIndex:[indexPath row]-1];
		
		if ([arrivalsAtOneStopForOneBus count] == 0)
		{
			BusArrival *aFakedArrival = [[BusArrival alloc] init];
			aFakedArrival.stopId = [[stopsOfInterest objectAtIndex:[indexPath section]] stopId];
			BusArrival *theDesiredArrival = [busesOfInterest objectAtIndex:[indexPath section]];
			[aFakedArrival setBusSign:[theDesiredArrival busSign]];
			aFakedArrival.flag = YES;		
			
			//NSString *fakeBusSign = [allBuses objectAtIndex:[indexPath row]-1];
			//[aFakedArrival setBusSign:fakeBusSign];
			
			arrivalsAtOneStop = [NSArray arrayWithObject: aFakedArrival];
		}
		
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

@end
