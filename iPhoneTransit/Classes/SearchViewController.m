//
//  SearchViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "TransitApp.h"
#import "BusStop.h"

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		// Initialization code
	}
	return self;
}

// Implement loadView if you want to create a view hierarchy programmatically
/*
- (void)loadView 
{
	[super loadView];	
}
*/

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	self.navigationItem.title = @"Search for Stops";
	stopViewType = kStopViewTypeToAdd;	
	mySearchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	mySearchBar.prompt = @"Stop ID";
	delimiterSet = [[NSCharacterSet characterSetWithCharactersInString:@",; "] retain];
 }
 
- (void)viewDidAppear:(BOOL)animated
{
	[self needsReload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[delimiterSet release];
	[super dealloc];
}

- (void) alertOnEmptyStopsOfInterest
{
	// open an alert with just an OK button
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"Couldn't find the stop(s)"
	//											   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	//[alert show];	
	//[alert release];
}

- (void) needsReload
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	if (!myApplication.arrivalQueryAvailable)
		return;
		
	for (BusStop *aStop in stopsOfInterest)
	{
		if (aStop.flag == NO)
			continue;
		
		BusStop *aStopInDataBase = [myApplication stopOfId: aStop.stopId];
		
		if (aStopInDataBase)
		{
			aStop.latitude = aStopInDataBase.latitude;
			aStop.longtitude = aStopInDataBase.longtitude;
			aStop.name = aStopInDataBase.name;
			aStop.position = aStopInDataBase.position;
			aStop.direction = aStopInDataBase.direction;
		}
	}
		
	[self reload];
}

#pragma mark UISearchBarDelegate

//Returns
//  - empty array when there is something wrong
//  - an array with BusStop objects, normally
- (NSMutableArray *) retrieveStopsFromText:(NSString *)text
{
	NSArray *stopIDs = [text componentsSeparatedByCharactersInSet:delimiterSet];	
	if ([stopIDs count] == 0)
		return [NSArray array];
		
	NSMutableArray *results = [[NSMutableArray alloc] init];
	for (NSString *aStopIdStr in stopIDs)
	{
		int idOfStop = [aStopIdStr intValue];
		
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		BusStop *aStop = [myApplication stopOfId:idOfStop];
		if (aStop)
		{
			[results addObject:aStop];
		}
		else
		{
			BusStop *aFakeStop = [[BusStop alloc] init];
			aFakeStop.stopId = idOfStop;
			aFakeStop.flag = YES;
			aFakeStop.latitude = aFakeStop.longtitude = 0.0;
			aFakeStop.name = [[NSString stringWithString:@"Unknown"] retain];
			aFakeStop.direction = [[NSString stringWithString:@"Unknown"] retain];
			aFakeStop.position = [[NSString stringWithString:@"Unknown"] retain];
			[results addObject:aFakeStop];
			[aFakeStop autorelease];
		}
	}
	
	return [results autorelease];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar's cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	
	// flush and save the current list content in case the user cancels the search later
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	//I don't want dynamic search...
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	//If cancelled, then do nothing.
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSMutableArray *stops = [self retrieveStopsFromText:searchBar.text];
	if ([stops count] != 0)
	{
		[arrivalsForStops removeAllObjects];
		self.stopsOfInterest = stops;
		[self reload];
		[searchBar resignFirstResponder];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"Error! check your stop IDs"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}


@end
