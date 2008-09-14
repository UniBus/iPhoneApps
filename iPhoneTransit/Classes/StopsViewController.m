//
//  StopsViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopsViewController.h"
#import "BusArrival.h"
#import "BusStop.h"
#import "BusArrival.h"
#import "TransitApp.h"
#import "MapViewController.h"

#define kUIStop_Section_Height    70
#define kUIArrival_Section_Height 70

UIImage *mapIconImage = nil;
UIImage *favoriteIconImage = nil;

#pragma mark UserDefaults for Recent-List and Favorite-List

void addStopAndBusToUserDefaultList(BusStop *aStop, BusArrival *anArrival, NSString *UserDefaults)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [NSMutableArray arrayWithArray:[defaults objectForKey:UserDefaults]];
	
	BOOL found = NO;
	SavedItem *theSavedItem = nil;
	int targetIndex = -1;
	for (int i=0; i<[favoriteArray count]; i++)
	{
		NSData *anItemData = [favoriteArray objectAtIndex:i];
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		if (anItem.stop.stopId == aStop.stopId)
		{
			theSavedItem = anItem;
			targetIndex = i;
			break;
		}
	}
	
	if (theSavedItem == nil)
	{
		theSavedItem = [[SavedItem alloc] init];
		theSavedItem.stop = aStop;
		[theSavedItem.buses addObject:anArrival];
		NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
		[favoriteArray addObject:theItemData];
		[theSavedItem autorelease];
	}
	else
	{
		for (BusArrival *anBusArrival in theSavedItem.buses)
		{
			if ([[anBusArrival busSign] isEqualToString:[anArrival busSign]])
			{
				found = YES;
				break;
			}
		}
		if (found == NO)
		{
			[theSavedItem.buses addObject:anArrival];
			NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
			[favoriteArray replaceObjectAtIndex:targetIndex withObject:theItemData];
		}
	}
	
	if (found == NO)
	{
		[defaults setObject:favoriteArray forKey:UserSavedFavoriteStopsAndBuses];
	}
}

void removeStopAndBusFromUserDefaultList(int aStopId, NSString *aBusSign, NSString *UserDefaults)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSMutableArray *favoriteArray = [NSMutableArray arrayWithArray:[defaults objectForKey:UserDefaults]];
	
	BOOL found = NO;
	SavedItem *theSavedItem = nil;
	int index = 0;
	for (; index < [favoriteArray count]; index++)
	{
		NSData *anItemData = [favoriteArray objectAtIndex:index];
		SavedItem *anItem = [NSKeyedUnarchiver unarchiveObjectWithData:anItemData];
		if (anItem.stop.stopId == aStopId)
		{
			theSavedItem = anItem;
			int busIndexAtStop = 0;
			for (;busIndexAtStop<[theSavedItem.buses count];busIndexAtStop++)
			{
				BusArrival *anArrival = [theSavedItem.buses objectAtIndex:busIndexAtStop];
				if ([[anArrival busSign] isEqualToString:aBusSign])
				{
					found = YES;
					[theSavedItem.buses removeObjectAtIndex:busIndexAtStop];
					break;
				}
			}
			if (found) 
			{
				if ([theSavedItem.buses count]==0)
					[favoriteArray removeObjectAtIndex:index];
				else
				{
					NSData *theItemData = [NSKeyedArchiver archivedDataWithRootObject:theSavedItem];
					[favoriteArray replaceObjectAtIndex:index withObject:theItemData];					
				}
			}
			break; 
		}
	}
		
	if (found)
	{
		[defaults setObject:favoriteArray forKey:UserSavedFavoriteStopsAndBuses];
	}
}

@implementation SavedItem
@synthesize stop, buses;
-(id) init
{
	[super init];
	buses = [[NSMutableArray alloc] init]; //it starts with an empty list
	return self;
}

- (void) dealloc
{
	[stop release];
	[buses release];
	[super dealloc];
}

- (id) initWithCoder: (NSCoder *) coder
{
	[super init];
	[stop release];
	[buses release];
	stop = [[coder decodeObjectForKey:@"Stop"] retain];
	buses = [[coder decodeObjectForKey:@"Buses"] retain];
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:stop forKey:@"Stop"];
	[coder encodeObject:buses forKey:@"Buses"];
}

@end

@implementation StopCell

- (IBAction) mapButtonClicked:(id)sender
{
	if (theStop.flag)
		return;

	if (ownerView)
	{
		if ([ownerView isKindOfClass:[StopsViewController class]])
		{
			[(StopsViewController *)ownerView showMapOfAStop:theStop];
		}
	}
	
	/*
	 NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f+%f+(Stop-%d)&ll=%f,%f", 	
	 theStop.latitude, theStop.longtitude, theStop.stopId, theStop.latitude, theStop.longtitude];	
	 NSURL *url = [NSURL URLWithString:urlString];
	 [[UIApplication sharedApplication] openURL: url];	
	 */
}

- (void) dealloc
{
	[stopName release];
	[stopPos release];
	[stopDir release];
	[mapButton release];
	[theStop release];
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
		mapIconImage = [[UIImage imageWithContentsOfFile:iconPath] retain];
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
	
	[stopName release];
	[stopPos release];
	[stopDir release];
	[mapButton release];

	return self;
}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier owner:(UIViewController *)owner
{
	[self initWithFrame:frame reuseIdentifier:reuseIdentifier];
	ownerView = owner;
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

@end;

@implementation ArrivalCell

-(void) addToFavorite: (BusArrival *)anArrival
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	BusStop *aStop = [myApplication stopOfId:anArrival.stopId];	
	if (aStop)
	{
		addStopAndBusToUserDefaultList(aStop, anArrival, UserSavedFavoriteStopsAndBuses);
	}
}

-(void) removeFromFavorite: (int)aStopId busSign:(NSString *)aBusSign
{
	removeStopAndBusFromUserDefaultList(aStopId, aBusSign, UserSavedFavoriteStopsAndBuses);
	if (ownerView)
		if ([ownerView isKindOfClass:[StopsViewController class]])
		{
			[(StopsViewController *)ownerView needsReload];
		}
}

- (IBAction) favoriteButtonClicked:(id)sender
{	
	BusArrival *anArrival = [theArrivals objectAtIndex:0];

	NSString *message;
	if (viewType == kStopViewTypeToDelete)
	{
		[self removeFromFavorite:anArrival.stopId busSign:[anArrival busSign]];
		message = [NSString stringWithFormat:@"Bus <%@> at Stop <%d> removed from the list!", [anArrival busSign], [anArrival stopId]];
	}
	else
	{
		[self addToFavorite:anArrival];
		message = [NSString stringWithFormat:@"Bus <%@> at Stop <%d> added to favorite!", [anArrival busSign], [anArrival stopId]];
	}
		
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:message
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

//- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier viewType:(int)type owner:(UIViewController *)owner
{
	[super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	
	ownerView = owner;
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
	viewType = type;
	if (type == kStopViewTypeToDelete)
	{
		favoriteButton = [[[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain] initWithFrame:ctrlFrame];
		if (favoriteIconImage == nil)
		{
			NSString *iconPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"delete.png"];
			favoriteIconImage = [[UIImage imageWithContentsOfFile:iconPath] retain];
		}		
		[favoriteButton setImage:favoriteIconImage forState:UIControlStateNormal];
	}
	else if (type == kStopViewTypeToAdd)
		favoriteButton = [[[UIButton buttonWithType:UIButtonTypeContactAdd] retain] initWithFrame:ctrlFrame];

	self.opaque = NO;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[self.contentView addSubview:busSign];
	[self.contentView addSubview:arrivalTime1];
	[self.contentView addSubview:arrivalTime2];

	[busSign release];
	[arrivalTime1 release];
	[arrivalTime2 release];

	if (favoriteButton)
	{
		[favoriteButton addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:favoriteButton];
		[favoriteButton release];
	}
		
	return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	return [self initWithFrame:frame reuseIdentifier:reuseIdentifier viewType:kStopViewTypeToAdd owner:nil];
}

- (void) setArrivals: (id) arrivals
{
	[theArrivals autorelease];
	theArrivals = [arrivals retain];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];	

	BusArrival *anArrival = nil;
	if ([arrivals count])
	{
		anArrival = [arrivals objectAtIndex:0];
		[busSign setText:[NSString stringWithFormat:@"%@", [anArrival busSign]]];		
	}
	else
	{
		[busSign setText:@"Unknown"];		
	}
	
	if (anArrival == nil)
	{
		[arrivalTime1 setText:@"-- -- --"];
		[arrivalTime2 setText:@"-- -- --"];
		return;
	}
	
	if (anArrival.flag)
	{
		[arrivalTime1 setText:@"-- -- --"];
		[arrivalTime2 setText:@"-- -- --"];
	}
	else if (anArrival.departed)
		[arrivalTime1 setText:[NSString stringWithFormat: @"(departed) %@",[dateFormatter stringFromDate:[anArrival arrivalTime]]]];
		//[arrivalTime1 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"(departed) %H:%M:%S" timeZone:nil locale:nil]];
	else
		[arrivalTime1 setText:[dateFormatter stringFromDate:[anArrival arrivalTime]]];
		//[arrivalTime1 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil]];
	
	if ([arrivals count] >= 2)
	{
		anArrival = [arrivals objectAtIndex:1];
		if (anArrival.departed)
			[arrivalTime2 setText:[dateFormatter stringFromDate:[anArrival arrivalTime]]];
			//[arrivalTime2 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"(departed) %H:%M:%S" timeZone:nil locale:nil]];
		else
			[arrivalTime2 setText:[dateFormatter stringFromDate:[anArrival arrivalTime]]];
			//[arrivalTime2 setText:[[anArrival arrivalTime] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil]];
	}
	else
	{
		[arrivalTime2 setText:@"-- -- --"];
	}
}

@end;

@implementation StopsViewController

@synthesize stopsOfInterest, stopViewType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		//self.navigationItem.prompt=@"Justacolor..."; 
	}
	
	return self;
}

/*// Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView 
{
	[super loadView];
}
*/ 

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
 - (void)viewDidLoad {
 }
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	//[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[arrivalsForStops release];
	[stopsOfInterest release];
	[super dealloc];
}

- (void) filterData
{
	//To be implemented in subclass;
}

- (void) needsReload
{
	//To be implemented in subclasses;
}

- (void) alertOnEmptyStopsOfInterest
{
	//To be implemented in subclasses
	
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UserApplicationTitle message:@"There is no stops"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	//Show some info to user here!
}

- (void) reload
{
	if (arrivalsForStops == nil)
		arrivalsForStops = [[NSMutableArray alloc] init];
	
	if ([stopsOfInterest count] == 0)
	{
		[self arrivalsUpdated: [NSMutableArray array]];		
		[self alertOnEmptyStopsOfInterest];
		return;
	}
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication]; 
	if (![myApplication isKindOfClass:[TransitApp class]])
		NSLog(@"Something wrong, Need to set the application to be TransitApp!!");
		
	self.navigationItem.prompt = @"Updating...";
	[myApplication arrivalsAtStopsAsync:self];

	[stopsTableView reloadData];
}

- (void) arrivalsUpdated: (NSArray *)results
{
	[arrivalsForStops removeAllObjects];
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
	
	[self filterData];
	
	//UITableView *tableView = (UITableView *) self.view;
	[stopsTableView reloadData];
	self.navigationItem.prompt = nil;
}

#pragma mark Stop/Arrival Data

- (void) showMapOfAStop: (BusStop *)theStop
{
	static MapViewController *staticMapViewController;
	
	if (staticMapViewController == nil)
	{
		staticMapViewController = [[MapViewController alloc] init];
	}
	
	UINavigationController *navigController = [self navigationController];
	if (navigController)
	{
		[navigController pushViewController:staticMapViewController animated:YES];
		//NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f+%f+(Stop-%d)&ll=%f,%f&output=html", 	
		//					   theStop.latitude, theStop.longtitude, theStop.stopId, theStop.latitude, theStop.longtitude];	
		//NSURL *url = [NSURL URLWithString:urlString];
		//[staticMapViewController mapWithURL:url];
		[staticMapViewController mapWithLatitude:theStop.latitude Longitude:theStop.longtitude];
	}	
}

- (NSArray *) arrivalsOfOneBus: (NSArray*) arrivals ofIndex: (int)index
{
	/*Find out how many buses arrive at this stop*/
	NSMutableArray *result = [[NSMutableArray alloc] init];
	if ([arrivals count] )
	{
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
	}
	
	return [result autorelease];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		UITableViewCell *stopCell = [tableView cellForRowAtIndexPath:indexPath];
		if ([stopCell isKindOfClass:[StopCell class]])
		{
			[(StopCell *)stopCell mapButtonClicked:self];
		}			
	}
}
		
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
	if (stopsOfInterest == nil)
		return 0;
	
	if ([stopsOfInterest count] == 0)
		return 0;
	
	if (arrivalsForStops == nil)
		return 1;
	
	if ([arrivalsForStops count] == 0)
		return 1;
	
	NSMutableArray *arrivalsForOneStop = nil;
	if ([arrivalsForStops count] > section)
		arrivalsForOneStop = [arrivalsForStops objectAtIndex:section];
	if (arrivalsForOneStop == nil)
		return 1;
	
	if ([arrivalsForOneStop count] == 0)
		return 1; // Still need to list the stop info.
	
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
	if (stopsOfInterest == nil)
		return @"";
	
	if ([stopsOfInterest count] == 0)
		return @"No stops!";
		
	BusStop *aStop = [stopsOfInterest objectAtIndex:section];
	if (aStop == nil)
		return @"No stops!";

	return [NSString stringWithFormat:@"%@", aStop.name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
		return kUIStop_Section_Height;
	else
		return kUIArrival_Section_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	static NSString *MyIdentifier2 = @"MyIdentifier2";
	
	if ([indexPath row] >= 1)
	{
		ArrivalCell *cell = (ArrivalCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
											//Assume in dequeResableCellWithIdentifier, autorelease has been called
		if (cell == nil) 
		{
			cell = [[[ArrivalCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier viewType:stopViewType owner:self] autorelease];
		}
		
		NSMutableArray *arrivalsAtOneStop = [arrivalsForStops objectAtIndex:[indexPath section]];
		NSArray *arrivalsAtOneStopForOneBus = [self arrivalsOfOneBus:arrivalsAtOneStop ofIndex:[indexPath row]-1];
		
		[cell setArrivals:arrivalsAtOneStopForOneBus];
		return cell;
	}
	else
	{
		StopCell *cell = (StopCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
		if (cell == nil) 
		{
			cell = [[[StopCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier2 owner:self] autorelease];
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

