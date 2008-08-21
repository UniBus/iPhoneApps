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
}

- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}

- (void) needsReload
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [defaults objectForKey:UserSavedFavoriteStopsAndBuses];
	
	NSMutableArray *newStops = [NSMutableArray array];
	NSMutableArray *newBuses = [NSMutableArray array];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	for (NSData *anItemData in favoriteArray)
	{
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		BusStop *aStop = [myApplication stopOfId:anItem.stopId];
		[newStops addObject:aStop];
		[newBuses addObject:anItem.buses];
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
			for (NSString *busSign in allBueses)
			{
				if ([busSign isEqualToString:anArrival.busSign])
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


@end
