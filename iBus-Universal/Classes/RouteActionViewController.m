//
//  RouteViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RouteActionViewController.h"
#import "RouteScheduleViewController.h"
#import "DatePickViewController.h"
#import "TransitApp.h"
#import "FavoriteViewController.h"

@implementation RouteActionViewController

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
	self.view = routeTableView; 
	
	//[self showInfoOfRoute:@"33" atStop:@"10324"];
	otherDate = [[[NSDate date] addTimeInterval:2*24*60*60] retain];
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
	[otherDate release];
	[stopID release];
	[routeID release];
	[routeTableView release]; 	
    [super dealloc];
}

#pragma mark Property Setter/Getter
- (void) setStopId: (NSString *)stop
{
	[stopID release];
	stopID = [stop retain];
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@ @Stop:%@", routeID, stopID];	
}

- (void) setRouteId: (NSString *)route
{
	[routeID release];
	routeID = [route retain];
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@ @Stop:%@", routeID, stopID];
}

- (void) showInfoOfRoute: (NSString*)route atStop:(NSString *)stop  withSign:(NSString *)sign
{
	if (route) 
	{
		[routeID release];
		routeID = [route retain];
	}
	if (stop)
	{
		[stopID release];
		stopID = [stop retain];
	}
	
	if (sign)
	{
		[busSign release];
		busSign = [sign retain];
	}
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@ @Stop:%@", routeID, stopID];
		
}

- (void) theOtherDatePicked: (NSDate *)datePicked
{
	[otherDate release];
	otherDate = [datePicked retain];
	[routeTableView reloadData];
}

- (void) pickTheOtherDate: (id) sender
{
	DatePickViewController *datePickVC = [[DatePickViewController alloc] initWithNibName:@"DatePickView" bundle:nil];
	datePickVC.target = self;
	datePickVC.callback = @selector(theOtherDatePicked:);
	datePickVC.date = otherDate;
	[[self navigationController] pushViewController:datePickVC animated:YES];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(stopID, routeID))
			removeFromFavorite2(stopID, routeID);
		else
			saveToFavorite2(stopID, routeID, busSign);
		[tableView reloadData];
		return;
	}
	
	//section == 1;
	RouteScheduleViewController *routeScheduleVC = [[RouteScheduleViewController alloc] initWithNibName:nil bundle:nil];
	routeScheduleVC.stopID = stopID;
	routeScheduleVC.routeID = routeID;	
	[[self navigationController] pushViewController:routeScheduleVC animated:YES];
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
	{
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
		return;
	}
	
	NSCalendar *current = [NSCalendar currentCalendar];
	NSInteger calendarUint = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
	if ((indexPath.section == 1) && (indexPath.row == 2))
	{
		NSDateComponents *components = [current components:calendarUint fromDate:otherDate];
		routeScheduleVC.dayID = [NSString stringWithFormat:@"%d%02d%02d", [components year], [components month], [components day]];
	}
	else if ((indexPath.section == 1) && (indexPath.row == 1))
	{
		NSDate *currentTime = [[NSDate date] addTimeInterval:24*60*60];
		NSDateComponents *components = [current components:calendarUint fromDate:currentTime];
		routeScheduleVC.dayID = [NSString stringWithFormat:@"%d%02d%02d", [components year], [components month], [components day]];
	}
	else if((indexPath.section == 1) && (indexPath.row == 0)) 
	{
		NSDate *currentTime = [NSDate date];
		NSDateComponents *components = [current components:calendarUint fromDate:currentTime];
		routeScheduleVC.dayID = [NSString stringWithFormat:@"%d%02d%02d", [components year], [components month], [components day]];
	}
		
	[myApplication scheduleAtStopsAsync:routeScheduleVC];	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
		return 1;
	else if (section == 1)
		return 3;
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Bookmark?";
	else if (section == 1)
		return @"Check whole day schedule?";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtRouteView";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentCenter;
		//cell.font = [UIFont systemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(stopID, routeID))
			cell.text = [NSString stringWithFormat:@"Remove from favorite"];
		else
			cell.text = [NSString stringWithFormat:@"Add to favorite"];
	}
	else if (indexPath.section == 1)
	{
		if (indexPath.row == 0)
		{
			cell.text = @"Today";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if (indexPath.row == 1)
		{
			cell.text = @"Tomorrow";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];	
			
			cell.text = [dateFormatter stringFromDate:otherDate];//@"Monday";
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.accessoryAction = @selector(pickTheOtherDate:);
			cell.target = self;
		}
	}
	
	return cell;
}

@end
