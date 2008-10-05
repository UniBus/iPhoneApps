//
//  CitySelectAppDelegate.m
//  CitySelect
//
//  Created by Zhenwang Yao on 19/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "CitySelectViewController.h"
#import "parseCSV.h"
@interface CitySelectViewController()
- (void) retrieveSupportedCities;
@end


@implementation CitySelectViewController

@synthesize delegate, currentCity, currentURL, currentDatabase;

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{
	[self retrieveSupportedCities];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
														  style:UITableViewStyleGrouped]; 
	[tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	tableView.delegate = self;
	tableView.dataSource = self;
	self.view = tableView; 
	[tableView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[supportedCities release];
	[super dealloc];
}

#pragma mark Operation on "supportedcities.lst"
//Format of the file:
// city,		state,	country,	url									dir
// Portland,	OR,		USA,		http://192.168.1.100/portland/,		portland

#define CITY_LIST_COL_CITY		0
#define CITY_LIST_COL_STATE		1
#define CITY_LIST_COL_COUNTRY	2
#define CITY_LIST_COL_URL		3
#define CITY_LIST_COL_DIR		4

- (void) retrieveSupportedCities
{
	NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
    NSString *listFilePath = [documentsDirectory stringByAppendingPathComponent:@"supportedcities.lst"];
    //NSString *listFilePath = @"http://192.168.1.100:5144/supportedcities.lst";
	
	CSVParser *parser = [[CSVParser alloc] init];
	if ([parser openFile:listFilePath] == YES)
	{
		[supportedCities release];
		supportedCities = [[parser parseFile] retain];
		[parser closeFile];	
	}
	
	[parser release];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//select row: indexPath.row
	NSArray *selectedCity = [supportedCities objectAtIndex:indexPath.row];
	currentCity = [NSString stringWithFormat:@"%@, %@, %@", 
				   [[selectedCity objectAtIndex:CITY_LIST_COL_CITY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
				   [[selectedCity objectAtIndex:CITY_LIST_COL_STATE] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
				   [[selectedCity objectAtIndex:CITY_LIST_COL_COUNTRY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
				   ];
	currentURL = [[selectedCity objectAtIndex:CITY_LIST_COL_URL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	currentDatabase = [[selectedCity objectAtIndex:CITY_LIST_COL_DIR] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//NSLog(@"City: %@", currentCity);
	//NSLog(@"URL : %@", currentURL);
	//NSLog(@"Path: %@", currentDir);
	@try
	{
		if (delegate)
			[delegate performSelector:@selector(citySelected:) withObject:self];
	}
	@catch (NSException *exception)
	{
		NSLog(@"didSelectRowAtIndexPath: Caught %@: %@", [exception name], [exception  reason]);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (supportedCities == nil)
		return 0;
	
	return [supportedCities count];	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"What City?";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil]; 
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
	NSArray *selectedCity = [supportedCities objectAtIndex:indexPath.row];
	cell.textAlignment = UITextAlignmentCenter;
	cell.text = [NSString stringWithFormat:@"%@, %@, %@", 
				   [[selectedCity objectAtIndex:CITY_LIST_COL_CITY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
				   [[selectedCity objectAtIndex:CITY_LIST_COL_STATE] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
				   [[selectedCity objectAtIndex:CITY_LIST_COL_COUNTRY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
				];
	return [cell autorelease];
}

@end
