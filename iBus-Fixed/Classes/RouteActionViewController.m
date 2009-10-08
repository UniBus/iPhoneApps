//
//  RouteViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "RouteActionViewController.h"
#import "RouteScheduleViewController.h"
#import "DatePickViewController.h"
#import "FavoriteViewController2.h"
#import "StopRouteViewHeader.h"
#import "TransitApp.h"

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
	
	StopRouteViewHeader *header = [[StopRouteViewHeader alloc] initWithFrame:CGRectZero];
	[header setIcon:routeType];
	[header setTitleInfo:[NSString stringWithFormat:@"%@ (%@)", routeName, busSign]];
	[header setDetailInfo:stopName];

	routeTableView.tableHeaderView = header;
	[header release];

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
	[stopName release];
	[stopID release];
	[routeID release];
	[routeTableView release]; 	
    [super dealloc];
}

#pragma mark Property Setter/Getter
- (void) setStopId: (NSString *) sname stopId: (NSString *)sid;
{
	[stopName release];
	stopName = [sname retain];
	
	[stopID release];
	stopID = [sid retain];
	
	//self.navigationItem.title = [NSString stringWithFormat:@"Route:%@", routeName];	
}

//- (void) setRoute: (NSString *) rname routeId: (NSString *)rid;
- (void) setRoute: (NSString *) rname routeId: (NSString *)rid direction:(NSString *) dir;
{
	[routeName release];
	[routeID release];
	[direction release];
	routeName = [rname retain];
	routeID = [rid retain];
	direction = dir;
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	routeType = [myApplication typeOfRoute:rid];
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@", routeName];
}

//- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid atStop:(NSString *)stop  withSign:(NSString *)sign
- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid direction:(NSString *) dir atStop:(NSString *)sname stopId:(NSString *)sid withSign:(NSString *)sign
{
	if (rid) 
	{
		[routeName release];
		[routeID release];
		routeName = [rname retain];
		routeID = [rid retain];
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
		routeType = [myApplication typeOfRoute:routeID];
	}
	if (dir)
	{
		[direction release];
		direction = [dir retain];
	}
	if (sid)
	{
		[stopName release];
		[stopID release];
		stopName = [sname retain];
		stopID = [sid retain];
	}
	if (sign)
	{
		[busSign release];
		busSign = [sign retain];
	}
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@", routeName];
		
}

- (void) theOtherDatePicked: (NSDate *)datePicked
{
	[otherDate release];
	otherDate = [datePicked retain];
	[routeTableView reloadData];
}

/*
- (void) pickTheOtherDate: (id) sender
{
	DatePickViewController *datePickVC = [[DatePickViewController alloc] initWithNibName:@"DatePickView" bundle:nil];
	datePickVC.target = self;
	datePickVC.callback = @selector(theOtherDatePicked:);
	datePickVC.date = otherDate;
	[[self navigationController] pushViewController:datePickVC animated:YES];
}
*/
 
- (void) notifyApplicationFavoriteChanged
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	@try {
		[myApplication.delegate performSelector:@selector(favoriteDidChange:) withObject:self];
	}
	@catch (NSException * e) {
		NSLog(@"didSelectRowAtIndexPath: Caught %@: %@", [e name], [e reason]);
	}
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//if (indexPath.section == 0)
	
	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			if (isStopInFavorite(stopID))
				removeStopFromFavorite(stopID);
			else
				saveStopToFavorite(stopID);
		}
		else
		{
			if (isRouteInFavorite(routeID, direction))
				removeRouteFromFavorite(routeID, direction);
			else
				saveRouteToFavorite(routeID, direction, busSign, routeName);
		}
		
		[tableView reloadData];
		
		[self notifyApplicationFavoriteChanged];
	}
	else
	{	
		//section == 1;
		RouteScheduleViewController *routeScheduleVC = [[RouteScheduleViewController alloc] initWithNibName:nil bundle:nil];
		routeScheduleVC.stopID = stopID;
		routeScheduleVC.routeID = routeID;	
		routeScheduleVC.direction = direction;
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
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
		return 2;
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

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
		return CELL_LABEL_TOTAL_HEIGHT;
	else
		return CELL_REGULAR_HEIGHT;
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtRouteView"];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CellIdentifierAtRouteView"] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	
	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			if (isStopInFavorite(stopID))
				cell.textLabel.text = @"Unbookmark the stop";
			else
				cell.textLabel.text = @"Bookmark the stop";
		}
		else
		{
			if (isRouteInFavorite(routeID, direction))
				cell.textLabel.text = @"Unbookmark the route";
			else
				cell.textLabel.text = @"Bookmark the route";
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == 1)
	{
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"EEEE"];
				
		if (indexPath.row == 0)
		{
			cell.textLabel.text = [NSString stringWithFormat:@"Today (%@)", [formatter stringFromDate:[NSDate date]]];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if (indexPath.row == 1)
		{
			cell.textLabel.text = [NSString stringWithFormat:@"Tomorrow (%@)", [formatter stringFromDate:[[NSDate date] addTimeInterval:24*60*60]]];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else
		{
			//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
			//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			//[dateFormatter setTimeStyle:NSDateFormatterNoStyle];	
			[formatter setDateFormat:@"yyyy-MMM-dd '('EEEE')'"];
			cell.textLabel.text = [formatter stringFromDate:otherDate];//@"Monday";
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			//cell.accessoryAction = @selector(pickTheOtherDate:);
			//cell.target = self;
		}
		[formatter release];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	/* There is only one cell with accessory button.
	 */
	DatePickViewController *datePickVC = [[DatePickViewController alloc] initWithNibName:@"DatePickView" bundle:nil];
	datePickVC.target = self;
	datePickVC.callback = @selector(theOtherDatePicked:);
	datePickVC.date = otherDate;
	[[self navigationController] pushViewController:datePickVC animated:YES];
	
}

@end
