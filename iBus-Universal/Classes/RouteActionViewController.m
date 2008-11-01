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

@interface RouteAtStopCell : UITableViewCell
{
	UILabel *actionLabel;
	UILabel *stopInfoLabel;
	UILabel *routeInfoLabel;
}

- (void) setAction:(NSString *)action;
- (void) setStopInfo:(NSString *)stopInfo;
- (void) setRouteInfo:(NSString *)routeInfo;

@end

#define CELL_LABEL_LEFT		20
#define CELL_LABEL_TOP		0
#define CELL_LABEL_WIDTH	260
#define CELL_LABEL_HEIGHT	44
#define CELL_LABEL_HEIGHT2	22

@implementation RouteAtStopCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	if (!self) return nil;
	
	CGRect ctrlFrame = CGRectMake(CELL_LABEL_LEFT, CELL_LABEL_TOP, CELL_LABEL_WIDTH, CELL_LABEL_HEIGHT);
	actionLabel = [[UILabel alloc] initWithFrame:ctrlFrame];	
	actionLabel.text = @"";
	actionLabel.font = [UIFont boldSystemFontOfSize:16];
	actionLabel.textAlignment = UITextAlignmentCenter;
	actionLabel.userInteractionEnabled = NO;
	actionLabel.multipleTouchEnabled = NO;
	actionLabel.opaque = NO;
	
	ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	ctrlFrame.size.height = CELL_LABEL_HEIGHT2;
	routeInfoLabel = [[UILabel alloc] initWithFrame:ctrlFrame];	
	routeInfoLabel.text = @"";
	routeInfoLabel.textColor = [UIColor blueColor];
	routeInfoLabel.font = [UIFont systemFontOfSize:12];
	routeInfoLabel.textAlignment = UITextAlignmentCenter;
	routeInfoLabel.userInteractionEnabled = NO;
	stopInfoLabel.multipleTouchEnabled = NO;
	routeInfoLabel.opaque = NO;
	
	ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	stopInfoLabel = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopInfoLabel.text = @"";
	stopInfoLabel.textColor = [UIColor blueColor];
	stopInfoLabel.font = [UIFont systemFontOfSize:12];
	stopInfoLabel.textAlignment = UITextAlignmentCenter;
	stopInfoLabel.userInteractionEnabled = NO;
	stopInfoLabel.multipleTouchEnabled = NO;
	stopInfoLabel.opaque = NO;
	
	[self.contentView addSubview:actionLabel];
	[self.contentView addSubview:stopInfoLabel];
	[self.contentView addSubview:routeInfoLabel];
	
	return self;
}

- (void) setAction:(NSString *)action
{
	actionLabel.text = action;
}

- (void) setStopInfo:(NSString *)stopInfo
{
	stopInfoLabel.text = [NSString stringWithFormat:@"Stop: %@", stopInfo];
}

- (void) setRouteInfo:(NSString *)routeInfo
{
	routeInfoLabel.text = [NSString stringWithFormat:@"Route: %@ at", routeInfo];
}

- (void) dealloc
{
	[actionLabel release];
	[stopInfoLabel release];
	[routeInfoLabel release];
	[super dealloc];
}

@end


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
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@ @Stop:%@", routeID, stopID];	
}

- (void) setRoute: (NSString *) rname routeId: (NSString *)rid;
{
	[routeName release];
	[routeID release];
	routeName = [rname retain];
	routeID = [rid retain];
	
	self.navigationItem.title = [NSString stringWithFormat:@"Route:%@ @Stop:%@", routeID, stopID];
}

//- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid atStop:(NSString *)stop  withSign:(NSString *)sign
- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid atStop:(NSString *)sname stopId:(NSString *)sid withSign:(NSString *)sign
{
	if (rid) 
	{
		[routeName release];
		[routeID release];
		routeName = [rname retain];
		routeID = [rid retain];
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
	if (indexPath.section == 0)
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(stopID, routeID))
			removeFromFavorite2(stopID, routeID);
		else
			saveToFavorite2(stopID, routeID, routeName, busSign);
		[tableView reloadData];
		
		[self notifyApplicationFavoriteChanged];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
		return 100;
	else
		return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	UITableViewCell *cell;
	if (indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"RouteAtStopCell"];
		if (cell == nil) 
		{
			cell = [[[RouteAtStopCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"RouteAtStopCell"] autorelease];
			cell.text = @"";
		}
		NSAssert([cell isKindOfClass:[RouteAtStopCell class]], @"TableViewCell type mismatched!");
		
		[(RouteAtStopCell *)cell setStopInfo:stopName];
		[(RouteAtStopCell *)cell setRouteInfo:routeName];
		if (isInFavorite2(stopID, routeID))
			[(RouteAtStopCell *)cell setAction:[NSString stringWithFormat:@"Remove from favorite"]];
		else
			[(RouteAtStopCell *)cell setAction:[NSString stringWithFormat:@"Add to favorite"]];
	}
	else if (indexPath.section == 1)
	{
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtRouteView"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CellIdentifierAtRouteView"] autorelease];
			cell.textAlignment = UITextAlignmentCenter;
		}
		
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
