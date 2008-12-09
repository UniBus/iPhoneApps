//
//  RouteAtStopViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RouteScheduleViewController.h"
#import "BusArrival.h"

@implementation RouteScheduleViewController

@synthesize stopID, routeID, dayID, direction;

/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	routeTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[routeTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	routeTableView.dataSource = self;
	routeTableView.delegate = self;
	routeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view = routeTableView; 
	//[routeTableView release]; 	
	self.navigationItem.title = @"Whole-day Schedule";
}

/*
 // Implement viewDidLoad to do additional setup after loading the view.
 - (void)viewDidLoad {
 [super viewDidLoad];
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
	[arrivals release];
	[routeTableView release];
	[stopID release];
	[routeID release];
    [super dealloc];
}

- (void) arrivalsUpdated: (NSArray *)results
{
	[arrivals release];
	arrivals = [results retain];

	self.navigationItem.prompt = nil;
	[routeTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (arrivals == nil)
		return 0;
	
	return [arrivals count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:[[dayID substringWithRange:NSMakeRange(0, 4)] intValue]];
	[comps setMonth:[[dayID substringWithRange:NSMakeRange(4, 2)] intValue]];
	[comps setDay:[[dayID substringWithRange:NSMakeRange(6, 2)] intValue]];	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *dateOfQuery = [gregorian dateFromComponents:comps];
	[gregorian release];
	[comps release];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MMM-dd '('EEEE')'"];
	NSString *newDateString = [formatter stringFromDate:dateOfQuery];
	[formatter release];

	return [NSString stringWithFormat:@"Schedule On %@", newDateString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}	

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtRouteView";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentLeft;
		cell.font = [UIFont systemFontOfSize:12];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.contentView.backgroundColor = [UIColor blueColor];
		//cell.indentationLevel = 1;
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	BusArrival *anArrival = [arrivals objectAtIndex:indexPath.row];
	if (indexPath.row % 2)
		cell.backgroundView.backgroundColor = [UIColor redColor];
	cell.text = [NSString stringWithFormat:@"[%@] - %@", [anArrival arrivalTime], [anArrival busSign]];
	
	return cell;
}

@end
