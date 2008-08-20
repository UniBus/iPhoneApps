//
//  StopsView.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopsView.h"
#import "BusArrival.h"
#import "BusStop.h"
#import "BusArrival.h"
#import "TransitApp.h"

#define kUIStop_Section_Height    70
#define kUIArrival_Section_Height 70

UIImage *mapIconImage = nil;
UIImage *favoriteIconImage = nil;

@implementation StopCell

- (IBAction) mapButtonClicked:(id)sender
{
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f+%f+(Stop-%d)&ll=%f,%f", 	
						   theStop.latitude, theStop.longtitude, theStop.stopId, theStop.latitude, theStop.longtitude];	
	NSURL *url = [NSURL URLWithString:urlString];
	[[UIApplication sharedApplication] openURL: url];	
}

- (void) dealloc
{
	[stopName release];
	[stopPos release];
	[stopDir release];
	[mapButton release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	
	CGRect ctrlFrame = CGRectMake(70, 10, 200, 18);
	stopName = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopName.backgroundColor = [UIColor clearColor];
	stopName.opaque = NO;
	stopName.textAlignment = UITextAlignmentLeft;
	stopName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	//stopName.textColor = [UIColor grayColor];
	//stopName.highlightedTextColor = [UIColor blackColor];
	stopName.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	stopPos = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopPos.backgroundColor = [UIColor clearColor];
	stopPos.opaque = NO;
	stopPos.textAlignment = UITextAlignmentLeft;
	stopName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	stopPos.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame.origin.y = ctrlFrame.origin.y +  + ctrlFrame.size.height;
	stopDir = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopDir.backgroundColor = [UIColor clearColor];
	stopDir.opaque = NO;
	stopDir.textAlignment = UITextAlignmentLeft;
	stopName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	stopDir.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame = CGRectMake(10, 10, 50, 50);
	mapButton = [[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain] initWithFrame:ctrlFrame];
	//mapButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
	//mapButton.clipsToBounds = YES;
	//mapButton.autoresizesSubviews = YES;
	//mapButton.showsTouchWhenHighlighted = YES;
	//mapButton.backgroundColor = [UIColor clearColor];
	if (mapIconImage == nil)
	{
		NSString *iconPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapicon.png"];
		mapIconImage = [UIImage imageWithContentsOfFile:iconPath];
	}
	//[buttonImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:12.0];
	//[mapButton setImage:buttonImage forState:UIControlStateNormal];
	[mapButton setBackgroundImage:mapIconImage forState:UIControlStateNormal];
	//[mapButton setBackgroundImage:[mapIconImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[mapButton addTarget:self action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	self.opaque = NO;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	//UIView *bkView = self.backgroundView;
	//[bkView setBackgroundColor:[UIColor blackColor]];
	//[bkView release];
	//[self.backgroundColor = [UIColor blackColor];

	[self.contentView addSubview:stopName];
	[self.contentView addSubview:stopPos];
	[self.contentView addSubview:stopDir];
	[self.contentView addSubview:mapButton];

	return self;
}

- (void) setStop:(id) aStop
{
	if (![aStop isKindOfClass:[BusStop class]])
	{
		NSLog(@"Programming Error, should have pass in a BusStop!");
		return;
	}
	
	[theStop autorelease];
	theStop = [aStop retain];
	[stopName setText:[NSString stringWithFormat:@"Stop ID:%d", theStop.stopId]];
	[stopPos setText:[NSString stringWithFormat:@"Position:%@", theStop.position]];
	[stopDir setText:[NSString stringWithFormat:@"Direction:%@", theStop.direction]];
}

/*
- (id)copyWithZone:(NSZone *)zone {
	StopCell *copy = [[StopCell alloc] init];
	
	(copy->stopName).frame = stopName.frame;
	(copy->stopName).backgroundColor = stopName.backgroundColor;
	(copy->stopName).opaque = stopName.opaque;
	(copy->stopName).textAlignment = stopName.textAlignment;
	(copy->stopName).baselineAdjustment = stopName.baselineAdjustment;
	(copy->stopName).font = stopName.font;
	
	(copy->stopPos).frame = stopPos.frame;
	(copy->stopPos).backgroundColor = stopPos.backgroundColor;
	(copy->stopPos).opaque = stopPos.opaque;
	(copy->stopPos).textAlignment = stopPos.textAlignment;
	(copy->stopPos).baselineAdjustment = stopPos.baselineAdjustment;
	(copy->stopPos).font = stopPos.font;

	(copy->stopDir).frame = stopDir.frame;
	(copy->stopDir).backgroundColor = stopDir.backgroundColor;
	(copy->stopDir).opaque = stopDir.opaque;
	(copy->stopDir).textAlignment = stopDir.textAlignment;
	(copy->stopDir).baselineAdjustment = stopDir.baselineAdjustment;
	(copy->stopDir).font = stopDir.font;
	
	(copy->mapButton).frame = mapButton.frame;
	[copy->mapButton setBackgroundImage:mapButton.currentBackgroundImage forState:UIControlStateNormal];
	[copy->mapButton addTarget:copy action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	copy.selectionStyle = self.selectionStyle;
	[copy setI
	
	[copy.contentView addSubview:copy->stopName];
	[copy.contentView addSubview:copy->stopPos];
	[copy.contentView addSubview:copy->stopDir];
	[copy.contentView addSubview:copy->mapButton];
	
	return copy;
}
*/

@end;

@implementation ArrivalCell

- (IBAction) favoriteButtonClicked:(id)sender
{
	BusArrival *anArrival = [theArrivals objectAtIndex:0];
	NSString *message = [NSString stringWithFormat:@"Bus <%@> at Stop <%d> added to favorite!", [anArrival busSign], [anArrival stopId]];
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPhone-Transit" message:message
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void) dealloc
{
	[busSign release];
	[arrivalTime1 release];
	[arrivalTime2 release];
	[favoriteButton release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	
	CGRect ctrlFrame = CGRectMake(70, 10, 160, 18);
	busSign = [[UILabel alloc] initWithFrame:ctrlFrame];	
	busSign.backgroundColor = [UIColor clearColor];
	busSign.opaque = NO;
	busSign.textAlignment = UITextAlignmentCenter;
	busSign.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	busSign.textColor = [UIColor blueColor];
	//stopName.highlightedTextColor = [UIColor blackColor];
	busSign.font = [UIFont systemFontOfSize:14];
	
	ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	arrivalTime1 = [[UILabel alloc] initWithFrame:ctrlFrame];	
	arrivalTime1.backgroundColor = [UIColor clearColor];
	arrivalTime1.opaque = NO;
	arrivalTime1.textColor = [UIColor redColor];
	arrivalTime1.textAlignment = UITextAlignmentRight;
	arrivalTime1.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	arrivalTime1.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame.origin.y = ctrlFrame.origin.y +  + ctrlFrame.size.height;
	arrivalTime2 = [[UILabel alloc] initWithFrame:ctrlFrame];	
	arrivalTime2.backgroundColor = [UIColor clearColor];
	arrivalTime2.opaque = NO;
	arrivalTime2.textAlignment = UITextAlignmentRight;
	arrivalTime2.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	arrivalTime2.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame = CGRectMake(240, 10, 50, 50);
	favoriteButton = [[[UIButton buttonWithType:UIButtonTypeContactAdd] retain] initWithFrame:ctrlFrame];
	/*
	if (favoriteIconImage == nil)
	{
		NSString *iconPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"favorite.png"];
		favoriteIconImage = [UIImage imageWithContentsOfFile:iconPath];
	}
	[favoriteButton setBackgroundImage:favoriteIconImage forState:UIControlStateNormal];
	 */
	[favoriteButton addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	self.opaque = NO;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	//UIView *bkView = self.backgroundView;
	//[bkView setBackgroundColor:[UIColor blackColor]];
	//[bkView release];
	//[self.backgroundColor = [UIColor blackColor];
	
	[self.contentView addSubview:busSign];
	[self.contentView addSubview:arrivalTime1];
	[self.contentView addSubview:arrivalTime2];
	[self.contentView addSubview:favoriteButton];
	
	return self;
}

- (void) setArrivals: (id) arrivals
{
	[theArrivals autorelease];
	theArrivals = [arrivals retain];
	BusArrival *anArrival = [arrivals objectAtIndex:0];

	[busSign setText:[NSString stringWithFormat:@"%@", [anArrival busSign]]];
	if (anArrival.departed)
		[arrivalTime1 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"(departed) %H:%M:%S" timeZone:nil locale:nil]];
	else
		[arrivalTime1 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil]];
	
	if ([arrivals count] >= 2)
	{
		anArrival = [arrivals objectAtIndex:1];
		if (anArrival.departed)
			[arrivalTime2 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"(departed) %H:%M:%S" timeZone:nil locale:nil]];
		else
			[arrivalTime2 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil]];
	}
	else
	{
		[arrivalTime2 setText:@"-- -- --"];
	}
}

@end;

@implementation StopsView

@synthesize stopsOfInterest;

- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:style]) 
	{
	}
	return self;
}

- (void)dealloc 
{
	[arrivalsForStops release];
	[stopsOfInterest release];
	[super dealloc];
}


- (void)viewDidLoad 
{
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void) reload
{
	if ([stopsOfInterest count] == 0)
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iPhone-Transit" message:@"There is no stops"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		//Show some info to user here!
	}
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
	
	if (arrivalsForStops == nil)
		arrivalsForStops = [[NSMutableArray alloc] init];
	
	[arrivalsForStops removeAllObjects];
	
	NSArray *results = [myApplication arrivalsAtStops:stopsOfInterest];
	for (BusStop *aStop in stopsOfInterest)
	{
		NSMutableArray *arrivalsForOneStop = [[NSMutableArray alloc] init];
		for (BusArrival *anArrival in results)
		{
			if (anArrival.stopId == aStop.stopId)
				[arrivalsForOneStop addObject:anArrival];
		}
		[arrivalsForStops addObject:arrivalsForOneStop];
		[arrivalsForOneStop autorelease];
	}
	
	UITableView *tableView = (UITableView *) self.view;
	[tableView reloadData];
}

#pragma mark TableView Delegate Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (stopsOfInterest == nil)
		return 1;
	
	if ([stopsOfInterest count] == 0)
		return 1;
	
	return [stopsOfInterest count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSMutableArray *arrivalsForOneStop = [arrivalsForStops objectAtIndex:section];
	
	/*Find out how many buses arrive at this stop*/
	BusArrival *anArrival = [arrivalsForOneStop objectAtIndex:0];
	NSString *theBusSign = [anArrival busSign];
	int numberOfDifferentBus = 1;
	for (int i=1; i<[arrivalsForOneStop count]; i++)
	{
		if (![theBusSign isEqualToString:[[arrivalsForOneStop objectAtIndex:i] busSign]])
		{
			theBusSign = [[arrivalsForOneStop objectAtIndex:i] busSign];
			numberOfDifferentBus ++;
		}
	}
		
	//return [arrivalsForOneStop count] + 1;
	return numberOfDifferentBus + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	BusStop *aStop = [stopsOfInterest objectAtIndex:section];
	return [NSString stringWithFormat:@"%@", aStop.name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
		return kUIStop_Section_Height;
	else
		return kUIArrival_Section_Height;
}

- (NSArray *) arrivalsOfOneBus: (NSArray*) arrivals ofIndex: (int)index
{
	/*Find out how many buses arrive at this stop*/
	NSMutableArray *result = [[NSMutableArray alloc] init];
	BusArrival *anArrival = [arrivals objectAtIndex:0];
	NSString *theBusSign = [anArrival busSign];
	int currentIndex = 0;

	if (index == currentIndex)
		[result addObject:anArrival];
	
	for (int i=1; i<[arrivals count]; i++)
	{
		anArrival = [arrivals objectAtIndex:i];
		
		if (![theBusSign isEqualToString:[anArrival busSign]])
		{
			theBusSign = [[arrivals objectAtIndex:i] busSign];
			currentIndex ++;
		}
		
		if (index == currentIndex)
			[result addObject:anArrival];
		else if (currentIndex > index)
			break;		
	}	
	
	return [result autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	static NSString *MyIdentifier2 = @"MyIdentifier2";
	
	if ([indexPath row] >= 1)
	{
		ArrivalCell *cell = (ArrivalCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) 
		{
			cell = [[[ArrivalCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		}
		
		NSMutableArray *arrivalsAtOneStop = [arrivalsForStops objectAtIndex:[indexPath section]];
		NSArray *arrivalsAtOneStopForOneBus = [self arrivalsOfOneBus:arrivalsAtOneStop ofIndex:[indexPath row]-1];
		
		[cell setArrivals:arrivalsAtOneStopForOneBus];
		return cell;
		/*
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		}

		NSMutableArray *arrivalsAtOneStop = [arrivalsForStops objectAtIndex:[indexPath section]];
		BusArrival *anArrival = [arrivalsAtOneStop objectAtIndex:[indexPath row]-1];
		cell.text = [[anArrival arrivalTime] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil];
		return cell;
		 */
	}
	else
	{
		StopCell *cell = (StopCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
		if (cell == nil) 
		{
			cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2] autorelease];
		}
		[cell setStop:[stopsOfInterest objectAtIndex:[indexPath section]]];
		return cell;
	}
	
	// Configure the cell
	//return cell;
}


/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 }
 */
/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 }
 if (editingStyle == UITableViewCellEditingStyleInsert) {
 }
 }
 */
/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */
/*
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */
/*
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

@end

