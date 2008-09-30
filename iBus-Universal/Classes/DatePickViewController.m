//
//  DatePickViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatePickViewController.h"


@implementation DatePickViewController

@synthesize target, callback;
@dynamic date;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

- (void)viewDidAppear:(BOOL)animated
{
	[picker setDate:date animated:NO];
    [super viewDidAppear:animated];
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
	[date release];
    [super dealloc];
}

- (IBAction) datePicked:(id) sender
{
	if ((target) && (callback))
	{
		@try {
			[target performSelector:callback withObject: picker.date];
		}
		@catch (NSException * e) {
		}
	}
	[quickPickView deselectRowAtIndexPath:[quickPickView indexPathForSelectedRow] animated:NO];
}

- (NSDate *)date
{
	return [picker date];
}

- (void) setDate: (NSDate *)theDate
{
	[date release];
	date = [theDate retain];
	picker.date = date;
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDate *currentTime = [NSDate date];
	NSCalendar *current = [NSCalendar currentCalendar];
	NSInteger calendarUint = NSWeekdayCalendarUnit;
	NSDateComponents *todaysComponents = [current components:calendarUint fromDate:currentTime];
	NSInteger currentWeekday = [todaysComponents weekday];
	
	NSTimeInterval secondsPerDay = 24 * 60 * 60;
	switch (indexPath.row) {
		case 0:
			picker.date = [currentTime addTimeInterval:(7-currentWeekday)*secondsPerDay];
			break;
		case 1:
			picker.date = [currentTime addTimeInterval:((8-currentWeekday) % 7)*secondsPerDay];
			break;
		case 2:
			picker.date = [currentTime addTimeInterval:((9-currentWeekday) % 7)*secondsPerDay];
			break;
		default:
			picker.date = currentTime;
			break;
	}
	[self datePicked:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}	

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtRouteView";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentCenter;
		//cell.font = [UIFont systemFontOfSize:16];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.indentationLevel = 1;
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.row) {
		case 0:
			cell.text = @"Coming Saturday";
			break;
		case 1:
			cell.text = @"Coming Sunday";
			break;
		case 2:
			cell.text = @"Coming Monday";
			break;
		default:
			cell.text = @"";
			break;
	}
	
	return cell;
}

@end
