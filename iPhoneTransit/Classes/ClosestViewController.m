//
//  ClosestViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#import "ClosestViewController.h"
#import "TransitApp.h"

float searchRange = 0.1;
int   numberOfResults = 5;
BOOL  globalTestMode = NO;

@implementation ClosestViewController

- (void)loadView 
{
	[super loadView];

	location = [[CLLocationManager alloc] init];
	location.delegate = self;
	
	stopViewType = kStopViewTypeToAdd;	
}

- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}

- (void) alertOnEmptyStopsOfInterest
{
	// open an alert with just an OK button
	NSString *message = [NSString stringWithFormat:@"Could't find any stops within %f Km", searchRange];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPhone-Transit" message:message
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	//Show some info to user here!	
}

- (CGPoint) getARandomCoordinate
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	

	int maxIndex = [myApplication numberOfStops];
	if (maxIndex)
	{
		srand(time(NULL));
		BusStop *aStop = [myApplication stopOfId:(random() % maxIndex)];
		return CGPointMake(aStop.longtitude, aStop.latitude);
	}
	else
	{
		double testLon = -122.60389;
		double testLat = 45.379719;
		return CGPointMake(testLon, testLat);
	}	
}

- (void) needsReload
{
	if (globalTestMode)
	{
		CGPoint queryPos = [self getARandomCoordinate];
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:queryPos within:searchRange] ];
		if ([querryResults count] > numberOfResults)
		{
			//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
			NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
			[querryResults removeObjectsAtIndexes:rangeToDelete];
		}
		stopsOfInterest = [querryResults retain];
	
		[self reload];
	}
	else
	{
		[location startUpdatingLocation];
	}
}

#pragma mark Location Update

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPhone-Transit" message:@"Couldn't update current location"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	
	[location stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	CGPoint queryPos = CGPointMake(newLocation.coordinate.longitude , newLocation.coordinate.latitude);
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:queryPos within:searchRange] ];
	if ([querryResults count] > numberOfResults)
	{
		//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
		NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
		[querryResults removeObjectsAtIndexes:rangeToDelete];
	}
	stopsOfInterest = [querryResults retain];
	
	[location stopUpdatingLocation];
	[self reload];	
}

@end

