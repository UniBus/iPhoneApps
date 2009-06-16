//
//  RouteSearchViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "RouteSearchViewController.h"
#import "RoutetripsViewController.h"
#import "StopsViewController.h"
#import "TransitApp.h"

@implementation RouteSearchViewController


// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Search for Routes";
}

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
	[view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	self.view = view; 
	[view release];
	
	routeSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	routeSearchBar.delegate = self;
	routeSearchBar.barStyle = UIBarStyleBlackOpaque;
	routeSearchBar.prompt = @"keywords";
	[self.view addSubview:routeSearchBar];
	
	CGRect tabRect = self.view.bounds;
	tabRect = CGRectMake(0, 44, tabRect.size.width, tabRect.size.height-44);
	routesTableView = [[UITableView alloc] initWithFrame:tabRect style:UITableViewStyleGrouped]; 
	[routesTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	routesTableView.dataSource = self;
	routesTableView.delegate = self;
	[self.view addSubview:routesTableView];
	
	//[routeSearchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[routesTableView release];
	[routesFound release];
	[routeSearchBar release];
    [super dealloc];
}

#pragma mark UISearchBarDelegate

- (void) reset
{
	routeSearchBar.text = @"";
	[routesFound release];
	routesFound = nil;
	[routesTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar's cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	
	searchBar.prompt = @"";	
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
	
	searchBar.prompt = @"keywords";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	[routesFound release];
	
	BOOL useRouteNum = NO;
	NSArray *keywordItems = [searchBar.text componentsSeparatedByString:@" "];
	NSString *firstKeyWord = [[keywordItems objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([firstKeyWord characterAtIndex:0] == '#')
		useRouteNum = YES;
		
	NSMutableArray *effectiveKeys = [NSMutableArray array];
	for (NSString *aKeyWord in keywordItems)
	{
		if ([[aKeyWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"#"])
			continue;
		else if ([[aKeyWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
			continue;
		if ([[aKeyWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] characterAtIndex:0]=='#')
			aKeyWord = [aKeyWord substringFromIndex:1];
		[effectiveKeys addObject:aKeyWord];
	}
		
	if (!useRouteNum)
		routesFound = [[myApplication queryRouteWithNames:effectiveKeys] retain];
	else
		routesFound = [[myApplication queryRouteWithIds:effectiveKeys] retain];
	[routesTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RouteTripsViewController *routeTripsVC = [[RouteTripsViewController alloc] initWithNibName:nil bundle:nil];
	routeTripsVC.theRoute = [routesFound objectAtIndex:indexPath.row];
	[[self navigationController] pushViewController:routeTripsVC animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (routesFound == nil)
		return 0;
	return [routesFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentLeft;
		cell.font = [UIFont boldSystemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	BusRoute *aRoute = [routesFound objectAtIndex:indexPath.row];
	cell.text = [NSString stringWithFormat:@"%@ - %@", aRoute.name, aRoute.description];
	return cell;
}

@end
