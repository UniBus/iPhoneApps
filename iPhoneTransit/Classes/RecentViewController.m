//
//  RecentViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RecentViewController.h"
#import "TransitApp.h"
#import "BusArrival.h"


@implementation RecentViewController

// Implement loadView if you want to create a view hierarchy programmatically
/*
- (void)loadView 
{
}
*/

- (void) viewDidLoad
{
	[super viewDidLoad];
	self.stopViewType = kStopViewTypeToDelete;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}

- (void) needsReload
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *recentArray = [defaults objectForKey:UserSavedRecentStopsAndBuses];
	
	NSMutableArray *newStops = [NSMutableArray array];
	NSMutableArray *newBuses = [NSMutableArray array];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	for (NSData *anItemData in recentArray)
	{
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData]; //Didn't forgot the release
																					//It just that I assume the object has been autoreleased in unarchiveObjectWithData
		BusStop *aStop = [myApplication stopOfId:anItem.stop.stopId];
		[newStops addObject:aStop];
		[newBuses addObject:anItem.buses];
	}
	
	self.stopsOfInterest = newStops;
	
	[busesOfInterest release]; //should I use autorelease here?
	busesOfInterest = [newBuses retain];
	
	[self reload];
}


- (BOOL) isInRecentList: (BusArrival*) anArrival
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
			if (![self isInRecentList:anArrival])
				[indexSetToDelete addIndex:i];				
		}
		if ([indexSetToDelete count])
			[arrivalsForOneStop removeObjectsAtIndexes:indexSetToDelete];
	}
}


@end
