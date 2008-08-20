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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

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


#pragma mark UISearchBarDelegate

- (NSArray *) retrieveStopsFromText:(NSString *)text
{
	int idOfStop = [text intValue];

	NSMutableArray *results = [[NSMutableArray alloc] init];
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	BusStop *aStop = [myApplication stopOfId:idOfStop];
	if (aStop)
	{
		[results addObject:aStop];
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
	NSArray *stops = [self retrieveStopsFromText:searchBar.text];
	if ([stops count] != 0)
	{
		self.stopsOfInterest = [stops retain];
		[self reload];
		[searchBar resignFirstResponder];
	}
	else
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPhone-Transit" message:@"Couldn't find the stop(s)"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		//Show some info to user here!
	}
}


@end
