//
//  FavoriteViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"
#import "TransitApp.h"

@implementation FavoriteViewController

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[super loadView];
	self.stopViewType = kStopViewTypeToDelete;
}

- (void)viewDidAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [defaults objectForKey:UserSavedFavoriteStopsAndBuses];
	
	NSMutableArray *newStops = [NSMutableArray array];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	for (NSData *anItemData in favoriteArray)
	{
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		BusStop *aStop = [myApplication stopOfId:anItem.stopId];
		[newStops addObject:aStop];
	}
	
	stopsOfInterest = [newStops retain];
	
	[self reload];
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
