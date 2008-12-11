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

@interface StopsViewHeader : UIView
{
	UIImageView	*icon;
	UILabel		*labelStop;
	UILabel		*labelRoute;
}

- (void) setType:(int)type;
- (void) setStopInfo:(NSString *)stopInfo;
- (void) setRouteInfo:(NSString *)routeInfo;

@end

#define HEADER_TOTAL_WIDTH	300
#define HEADER_TOTAL_HEIGHT	90

#define HEADER_ICON_LEFT	5
#define HEADER_ICON_TOP		5
#define HEADER_ICON_WIDTH	80
#define HEADER_ICON_HEIGHT	80

#define HEADER_ROUTE_LEFT	90
#define HEADER_ROUTE_TOP	0
#define HEADER_ROUTE_WIDTH	220
#define HEADER_ROUTE_HEIGHT	45

#define HEADER_STOP_LEFT	90
#define HEADER_STOP_TOP		45
#define HEADER_STOP_WIDTH	220
#define HEADER_STOP_HEIGHT	45

enum TransitRouteType {
	kTransitRouteTypeTram = 0,
	kTransitRouteTypeSubway,
	kTransitRouteTypeRail,
	kTransitRouteTypeBus,
	kTransitRouteTypeFerry,
	kTransitRouteTypeCableCar,
	kTransitRouteTypeGondola,
	kTransitRouteTypeFunicular,	
};

@implementation StopsViewHeader

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame];	
	if (!self) return nil;
	
	CGRect ctrlFrame = CGRectMake(HEADER_ICON_LEFT, HEADER_ICON_TOP, HEADER_ICON_WIDTH, HEADER_ICON_HEIGHT);
	icon = [[UIImageView alloc] initWithFrame:ctrlFrame];	
	
	ctrlFrame.origin.x = HEADER_ROUTE_LEFT;
	ctrlFrame.origin.y = HEADER_ROUTE_TOP;
	ctrlFrame.size.height = HEADER_ROUTE_HEIGHT;
	ctrlFrame.size.width = HEADER_ROUTE_WIDTH;
	labelRoute = [[UITextView alloc] initWithFrame:ctrlFrame];
	labelRoute.textColor = [UIColor blackColor];
	labelRoute.backgroundColor = [UIColor clearColor];
	labelRoute.font = [UIFont boldSystemFontOfSize:14];
	labelRoute.textAlignment = UITextAlignmentLeft;
	labelRoute.userInteractionEnabled = NO;
	labelRoute.multipleTouchEnabled = NO;
	labelRoute.text = @"";
		
	ctrlFrame.origin.x = HEADER_STOP_LEFT;
	ctrlFrame.origin.y = HEADER_STOP_TOP;
	ctrlFrame.size.height = HEADER_STOP_HEIGHT;
	ctrlFrame.size.width = HEADER_STOP_WIDTH;
	labelStop = [[UITextView alloc] initWithFrame:ctrlFrame];
	labelStop.textColor = [UIColor blackColor];
	labelStop.backgroundColor = [UIColor clearColor];
	labelStop.font = [UIFont systemFontOfSize:14];
	labelStop.textAlignment = UITextAlignmentLeft;
	labelStop.userInteractionEnabled = NO;
	labelStop.multipleTouchEnabled = NO;
	labelStop.text = @"";
	
	[self addSubview:icon];
	[self addSubview:labelStop];
	[self addSubview:labelRoute];
	
	return self;
}

- (void) setType:(int)type
{
	//icon.text = action;
	switch (type) {
		case kTransitRouteTypeBus:
			icon.image = [UIImage imageNamed:@"typebusicon.png"];
			break;

		case kTransitRouteTypeFerry:
			icon.image = [UIImage imageNamed:@"typeferryicon.png"];
			break;

		case kTransitRouteTypeSubway:
		case kTransitRouteTypeRail:
			icon.image = [UIImage imageNamed:@"typetrainicon.png"];
			break;
			
		case kTransitRouteTypeTram:
		case kTransitRouteTypeCableCar:
		case kTransitRouteTypeGondola:
		case kTransitRouteTypeFunicular:			
			icon.image = [UIImage imageNamed:@"typetramicon.png"];
			break;
			
		default:
			icon.image = [UIImage imageNamed:@"typebusicon.png"];
			break;
	}
}

- (void) setStopInfo:(NSString *)stopInfo
{
	labelStop.text = [NSString stringWithFormat:@"%@", stopInfo];
}

- (void) setRouteInfo:(NSString *)routeInfo
{
	labelRoute.text = [NSString stringWithFormat:@"%@", routeInfo];
}

- (void) dealloc
{
	[labelStop release];
	[labelRoute release];
	[icon release];
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
	
	StopsViewHeader *header = [[StopsViewHeader alloc] initWithFrame:CGRectMake(0, 0, HEADER_TOTAL_WIDTH, HEADER_TOTAL_HEIGHT)];
	[header setType:routeType];
	[header setStopInfo:stopName];
	[header setRouteInfo:[NSString stringWithFormat:@"%@ (%@)", routeName, busSign]];

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
		if (isInFavorite2(stopID, routeID, direction))
			removeFromFavorite2(stopID, routeID, direction);
		else
			saveToFavorite2(stopID, routeID, routeName, busSign, direction);
		[tableView reloadData];
		
		[self notifyApplicationFavoriteChanged];
		return;
	}
	
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
		cell.textAlignment = UITextAlignmentCenter;
	}
	
	if (indexPath.section == 0)
	{
		if (isInFavorite2(stopID, routeID, direction))
			cell.text = @"Remove from favorite";
		else
			cell.text = @"Add to favorite";
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == 1)
	{
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"EEEE"];
				
		if (indexPath.row == 0)
		{
			cell.text = [NSString stringWithFormat:@"Today (%@)", [formatter stringFromDate:[NSDate date]]];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if (indexPath.row == 1)
		{
			cell.text = [NSString stringWithFormat:@"Tomorrow (%@)", [formatter stringFromDate:[[NSDate date] addTimeInterval:24*60*60]]];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else
		{
			//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
			//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			//[dateFormatter setTimeStyle:NSDateFormatterNoStyle];	
			[formatter setDateFormat:@"yyyy-MMM-dd '('EEEE')'"];
			cell.text = [formatter stringFromDate:otherDate];//@"Monday";
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.accessoryAction = @selector(pickTheOtherDate:);
			cell.target = self;
		}
		[formatter release];
	}
	
	return cell;
}

@end
