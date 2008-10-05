//
//  StopSearchViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopSearchViewController.h"
#import "StopsViewController.h"
#import "TransitApp.h"

@implementation StopSearchViewController


// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	self.navigationItem.title = @"Search for Stops";
}

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
	[view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	self.view = view; 
	[view release];
	
	stopSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	stopSearchBar.delegate = self;
	[self.view addSubview:stopSearchBar];
	
	CGRect tabRect = self.view.bounds;
	tabRect = CGRectMake(0, 50, tabRect.size.width, tabRect.size.height-50);
	stopsTableView = [[UITableView alloc] initWithFrame:tabRect style:UITableViewStyleGrouped]; 
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopsTableView.dataSource = self;
	stopsTableView.delegate = self;
	[self.view addSubview:stopsTableView];
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
	[stopsTableView release];
	[stopsFound release];
	[stopSearchBar release];
    [super dealloc];
}

#pragma mark UISearchBarDelegate

- (void) reset
{
	stopSearchBar.text = @"";
	[stopsFound release];
	stopsFound = nil;
	[stopsTableView reloadData];
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
	[searchBar resignFirstResponder];	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	[stopsFound release];
	
	BOOL useStopNum = NO;
	NSArray *keywordItems = [searchBar.text componentsSeparatedByString:@" "];
	NSString *firstKeyWord = [[keywordItems objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([firstKeyWord characterAtIndex:0] == '#')
		useStopNum = YES;
		
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
		
	if (!useStopNum)
		stopsFound = [[myApplication queryStopWithNames:effectiveKeys] retain];
	else
		stopsFound = [[myApplication queryStopWithIds:effectiveKeys] retain];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (stopsFound == nil)
		return 0;
	return [stopsFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentLeft;
		cell.font = [UIFont systemFontOfSize:14];
		cell.textColor = [UIColor blueColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	BusStop *aStop = [stopsFound objectAtIndex:indexPath.row];
	cell.text = [NSString stringWithFormat:@"[%@] - %@", aStop.stopId, aStop.name];
	return cell;
}

@end
