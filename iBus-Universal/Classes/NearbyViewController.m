//
//  ClosestViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#import "NearbyViewController.h"
#import "StopsViewController.h"
#import "TransitApp.h"
#import "StopCell.h"
#import "General.h"

float searchRange = 0.1;
int   numberOfResults = 5;
BOOL  globalTestMode = NO;

@interface NearbyViewController (private)
- (void) needsReload;
@end


@implementation NearbyViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	stopsTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopsTableView.dataSource = self;
	stopsTableView.delegate = self;
	self.view = stopsTableView;

	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Nearby Stops";
	UIBarButtonItem*refreshButton=[[UIBarButtonItem alloc] initWithTitle:@"Refresh"
																   style:UIBarButtonItemStylePlain 
																  target:self
																  action:@selector(refreshClicked:)]; 
	self.navigationItem.rightBarButtonItem=refreshButton; 	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	searchRange = [defaults floatForKey:UserSavedSearchRange];
	numberOfResults = [defaults integerForKey:UserSavedSearchResultsNum];
	
	location = [[CLLocationManager alloc] init];
	location.delegate = self;	
}

- (void)viewDidLoad 
{
	[super viewDidLoad];	
	[self needsReload];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (needReset)
		[self needsReload];

	needReset = NO;
}

- (void) dealloc
{
	[stopsTableView release];
	[stopsFound release];
	[location release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning 
{
	if (indicator)
		if (![indicator isAnimating])
		{
			//there shouldn't be any superview related to it.
			[indicator release];
			indicator = nil;
		}
	[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void) alertOnEmptyStopsOfInterest
{
	// open an alert with just an OK button
	NSString *message = [NSString stringWithFormat:@"Could't find any stops within %f Km", searchRange];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:message
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	//Show some info to user here!	
}

- (CGPoint) getARandomCoordinate
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	
	BusStop *aStop = [myApplication getRandomStop];
	if (aStop)
	{
		NSLog(@"Choose stop, with id=%@, long=%lf, latit=%lf", aStop.stopId, aStop.longtitude, aStop.latitude);
		return CGPointMake(aStop.longtitude, aStop.latitude);
	}
	else
	{
		double testLon = -122.60389;
		double testLat = 45.379719;
		NSLog(@"Choose a spot, long=%lf, latit=%lf", testLon, testLat);
		return CGPointMake(testLon, testLat);
	}	
}

- (void) reset
{
	needReset = YES;
}

- (void) refreshClicked:(id)sender
{
	[self needsReload];
}

- (void) needsReload
{
	if (globalTestMode)
	{
		currentPosition = [self getARandomCoordinate];
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:currentPosition within:searchRange] ];
		if ([querryResults count] > numberOfResults)
		{
			//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
			NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
			[querryResults removeObjectsAtIndexes:rangeToDelete];
		}
		stopsFound = [querryResults retain];
		
		[stopsTableView reloadData];
	}
	else
	{
		if (indicator == nil)
		{
			indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			CGRect screenBound = [UIScreen mainScreen].bounds;
			CGPoint centerPos = CGPointMake(screenBound.size.width/2, screenBound.size.height/2-60);
			indicator.center = centerPos;
		}
		[indicator startAnimating];
		[self.view addSubview:indicator];
		[location startUpdatingLocation];
	}
}

#pragma mark Location Update

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[location stopUpdatingLocation];
	if (indicator)
	{
		[indicator removeFromSuperview];
		[indicator stopAnimating];
	}
	
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"Couldn't update current location"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[location stopUpdatingLocation];
	if (indicator)
	{
		[indicator removeFromSuperview];
		[indicator stopAnimating];
	}
	
	currentPosition = CGPointMake(newLocation.coordinate.longitude , newLocation.coordinate.latitude);
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:currentPosition within:searchRange] ];
	//Agagin, here I assume [NSMutableArray arrayWithArray] auto release the return array.
	if ([querryResults count] > numberOfResults)
	{
		//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
		NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
		[querryResults removeObjectsAtIndexes:rangeToDelete];
	}
	stopsFound = [querryResults retain];
	
	if ([stopsFound count] == 0)
		[self alertOnEmptyStopsOfInterest];

	[stopsTableView reloadData];	
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:nil bundle:nil];
	NSMutableArray *stopSelected = [NSMutableArray array];
	[stopSelected addObject:[stopsFound objectAtIndex:indexPath.row]];
	stopsVC.stopsOfInterest = stopSelected;
	[stopsVC reload];
	
	[[self navigationController] pushViewController:stopsVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [CellWithNote height];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"Stops within ~ %.1f Km", searchRange];	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (stopsFound == nil)
		return 0;
	return [stopsFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifierCellWithNote";
	
	CellWithNote *cell = (CellWithNote *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[CellWithNote alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentLeft;
		cell.font = [UIFont systemFontOfSize:14];
		cell.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	BusStop *aStop = [stopsFound objectAtIndex:indexPath.row];
	cell.text = [NSString stringWithFormat:@"[%@] - %@", aStop.stopId, aStop.name];
	[cell setNote:[NSString stringWithFormat:@"%.1fkm", 
				   distance(aStop.latitude, aStop.longtitude, currentPosition.y, currentPosition.x)]];
	return cell;
}

@end

