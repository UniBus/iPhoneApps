//
//  ClosestViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#include <stdlib.h>
#import "NearbyViewController.h"
#import "StopsViewController.h"
#import "TransitApp.h"
#import "StopCell.h"
#import "General.h"
#import "MiscCells.h"

#define MAPWEBVIEW_HEIGHT		160
#define MAPWEBVIEW_WIDTH		320
#define MAPWEBVIEWCELL_HEIGHT	140
#define MAPWEBVIEWCELL_WIDTH	260
#define MAPWEBVIEWCEL_LEFT		20
#define MAPWEBVIEWCELL_TOP		20

//#define MAPVIEW_ENABLED
#define DEFAULT_SHOW_MAP        0

float searchRange = 0.1;
int   numberOfResults = 5;
BOOL  globalTestMode = NO;
int   currentUnit = UNIT_KM;

char *UnitName(int unit);

@interface NearbyViewController (private)
- (void) needsReload;
- (void) positionUpdated;
@end


@implementation NearbyViewController

@synthesize explicitLocation;

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
	[view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	self.view = view; 
	[view release];
	
	routeSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	routeSearchBar.delegate = self;
	routeSearchBar.barStyle = UIBarStyleBlackOpaque;
	routeSearchBar.prompt = @"Filter by Routes";
	[self.view addSubview:routeSearchBar];
	
	
#ifdef MAPVIEW_ENABLED	
	CGRect tableFrame = self.view.bounds;
	tableFrame.origin.y = routeSearchBar.bounds.size.height;
	tableFrame.size.height = MAPWEBVIEW_HEIGHT;
	mapTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	mapTableView.dataSource = self;
	mapTableView.delegate = self;
	mapTableView.userInteractionEnabled = NO;
	mapTableView.multipleTouchEnabled = NO;
	[self.view addSubview: mapTableView];	
	
	mapWeb = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, MAPWEBVIEW_WIDTH, MAPWEBVIEW_HEIGHT-10)];
	mapWeb.delegate = self;
	mapWeb.userInteractionEnabled = NO;
	mapWeb.multipleTouchEnabled = NO;
	mapWeb.backgroundColor = [UIColor yellowColor];
	mapWeb.clearsContextBeforeDrawing = YES;

	if (DEFAULT_SHOW_MAP)
	{
		mapTableView.tableHeaderView = mapWeb;		
		tableFrame = self.view.bounds;
		tableFrame.origin.y = routeSearchBar.bounds.size.height + mapTableView.bounds.size.height;
		tableFrame.size.height = self.view.bounds.size.height - (routeSearchBar.bounds.size.height + mapTableView.bounds.size.height);
	}
	else {
		tableFrame = self.view.bounds;
		tableFrame.origin.y = routeSearchBar.bounds.size.height;
		tableFrame.size.height = self.view.bounds.size.height - (routeSearchBar.bounds.size.height);
	}

#else
	CGRect tableFrame = self.view.bounds;
	tableFrame.origin.y = routeSearchBar.bounds.size.height;
	tableFrame.size.height = self.view.bounds.size.height - (routeSearchBar.bounds.size.height);
#endif
	
	stopsTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain]; 
	//stopsTableView = [[UITableView alloc] initWithFrame:halfFrame style:UITableViewStyleGrouped]; 
	[stopsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	stopsTableView.dataSource = self;
	stopsTableView.delegate = self;
	[self.view addSubview: stopsTableView];
	//self.view = stopsTableView;

	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Nearby Stops";
	UIBarButtonItem *refreshButton=[[UIBarButtonItem alloc] initWithTitle:@"Refresh"
																	style:UIBarButtonItemStylePlain 
																   target:self
																   action:@selector(refreshClicked:)]; 
	self.navigationItem.rightBarButtonItem=refreshButton; 	

#ifdef MAPVIEW_ENABLED
	UIBarButtonItem *mapButton=[[UIBarButtonItem alloc] initWithTitle:@"Map"
																style:UIBarButtonItemStyleBordered 
																target:self
																action:@selector(mapClicked:)]; 
	self.navigationItem.leftBarButtonItem=mapButton; 	
#endif	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	searchRange = [defaults floatForKey:UserSavedSearchRange];
	numberOfResults = [defaults integerForKey:UserSavedSearchResultsNum];
	currentUnit = [defaults integerForKey:UserSavedDistanceUnit];
	
	if (!explicitLocation)
	{
		location = [[CLLocationManager alloc] init];
		location.delegate = self;
	}
	
	stopsFoundFiltered = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];	
	[self needsReload];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (needReset)
		[self needsReload];

	needReset = NO;
}

- (void) dealloc
{
#ifdef MAPVIEW_ENABLED
	[mapTableView release];
	[mapWeb release];
#endif
	[stopsTableView release];
	[stopsFound release];
	[stopsFoundFiltered release];
	[location release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning 
{
	if (indicator)
		if (![indicator isAnimating])
		{
			//there shouldn't be any superview related to it.
			[indicator release];
			indicator = nil;
		}
	[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void) alertOnEmptyStopsOfInterest
{
	/*
	// open an alert with just an OK button
	NSString *message = [NSString stringWithFormat:@"Could't find any stops within %.1f %s", searchRange, UnitName(currentUnit)];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:applicationTitle message:message
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	//Show some info to user here!	
	 */
}

- (CGPoint) getARandomCoordinate
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	
	BusStop *aStop = [myApplication getRandomStop];
	if (aStop)
	{
		NSLog(@"Choose stop, with id=%@, long=%lf, latit=%lf", aStop.stopId, aStop.longtitude, aStop.latitude);
		return CGPointMake(aStop.longtitude, aStop.latitude);
	}
	else
	{
		double testLon = -122.60389;
		double testLat = 45.379719;
		NSLog(@"Choose a spot, long=%lf, latit=%lf", testLon, testLat);
		return CGPointMake(testLon, testLat);
	}	
}

- (void) filterStopsFound
{
	[stopsFoundFiltered removeAllObjects];
	if (routesOfInterest == nil)
	{
		[stopsFoundFiltered addObjectsFromArray:stopsFound];
	}
	else
	{
		for (BusStop *aStop in stopsFound)
		{
			TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
			if ([myApplication isStop:aStop.stopId hasRoutes:routesOfInterest])
			{
				[stopsFoundFiltered addObject:aStop];
				if ([stopsFoundFiltered count] >= numberOfResults)
					break;
			}				
		}
	}
}

- (void) reset
{
	routeSearchBar.text = @"";
	needReset = YES;
}

- (void) refreshClicked:(id)sender
{
	[self needsReload];
}

#ifdef MAPVIEW_ENABLED
- (void) mapClicked:(id)sender
{
	if (mapTableView.tableHeaderView == nil)
	{
		mapTableView.tableHeaderView = mapWeb;
		CGRect tableFrame = self.view.bounds;
		tableFrame.origin.y = routeSearchBar.bounds.size.height + mapTableView.bounds.size.height;
		tableFrame.size.height = self.view.bounds.size.height - (routeSearchBar.bounds.size.height + mapTableView.bounds.size.height);
		stopsTableView.frame = tableFrame;
		[mapTableView reloadData];
	}
	else
	{
		mapTableView.tableHeaderView = nil;
		CGRect tableFrame = self.view.bounds;
		tableFrame.origin.y = routeSearchBar.bounds.size.height;
		tableFrame.size.height -= routeSearchBar.bounds.size.height;
		stopsTableView.frame = tableFrame;
		[mapTableView reloadData];
	}
	
}
#endif

- (void) needsReload
{
	if (globalTestMode)
	{
		currentPosition = [self getARandomCoordinate];
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:currentPosition within:searchRange*UnitToKm(currentUnit)] ];
		/*
		if ([querryResults count] > numberOfResults)
		{
			//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
			NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
			[querryResults removeObjectsAtIndexes:rangeToDelete];
		}
		 */
		[stopsFound release];
		stopsFound = [querryResults retain];
		[self filterStopsFound];
		
		[stopsTableView reloadData];
	}
	else
	{
		if (!explicitLocation)
		{
			if (indicator == nil)
			{
				indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				CGRect screenBound = [UIScreen mainScreen].bounds;
				CGPoint centerPos = CGPointMake(screenBound.size.width/2, screenBound.size.height/2-60);
				indicator.center = centerPos;
			}
			[indicator startAnimating];
			[self.view addSubview:indicator];

			[location startUpdatingLocation];
		}
		else
			[self positionUpdated];
	}
}

#ifdef MAPVIEW_ENABLED
- (void) showStopOnMap:(BusStop *) aStop
{

	NSString *currentWebSite = [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix];
	NSString *urlString = [NSString stringWithFormat:@"%@stopmap.php?lat=%f&long=%f&height=%f", 
						   currentWebSite, aStop.latitude, aStop.longtitude, mapWeb.bounds.size.height];
	
	
	//NSURL *url = [NSURL URLWithString:@"http://zhenwang.yao.googlepages.com/maplet.html"];
	NSURL *url= [NSURL URLWithString:urlString];
	
	[super mapWithURL:url];
	//NSURLRequest *request = [NSURLRequest requestWithURL:url 
	//										 cachePolicy:NSURLRequestUseProtocolCachePolicy
	//									 timeoutInterval:20];  // 20 sec;
	//[mapWeb loadRequest:request];
	
}
#endif

- (void) setExplictLocation:(CGPoint)exPos
{
	currentPosition = exPos;
	explicitLocation = YES;
}

- (void) positionUpdated
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	NSMutableArray *querryResults = [NSMutableArray arrayWithArray:[myApplication closestStopsFrom:currentPosition within:searchRange*UnitToKm(currentUnit)] ];
	//Agagin, here I assume [NSMutableArray arrayWithArray] auto release the return array.
	if ([querryResults count] > numberOfResults)
	{
		//NSRange *range = NSMakeRange(numberOfResults-1, [querryResults count]-numberOfResults)];
		NSIndexSet *rangeToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfResults, [querryResults count]-numberOfResults)];
		[querryResults removeObjectsAtIndexes:rangeToDelete];
	}
	[stopsFound release];
	stopsFound = [querryResults retain];
	[self filterStopsFound];
	
	if ([stopsFound count] == 0)
		[self alertOnEmptyStopsOfInterest];
	
	[stopsTableView reloadData];	
}	

#pragma mark Location Update

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[location stopUpdatingLocation];
	if (indicator)
	{
		[indicator removeFromSuperview];
		[indicator stopAnimating];
	}
	
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:applicationTitle message:@"Couldn't update current location"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//[location stopUpdatingLocation];
	if (indicator)
	{
		[indicator removeFromSuperview];
		[indicator stopAnimating];
	}
	
	currentPosition = CGPointMake(newLocation.coordinate.longitude , newLocation.coordinate.latitude);
	NSLog(@"[%f, %f]", currentPosition.x, currentPosition.y);
	
	[self positionUpdated];
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar's cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	
	searchBar.prompt = @"";	
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
	
	searchBar.prompt = @"Filter by Routes";
	
	
	// Compute routesOfInterest
	[routesOfInterest release];
	routesOfInterest = nil;
	
	//Filter found stops
	if ([stopsFound count])
		[self filterStopsFound];
	
	[stopsTableView reloadData];	
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];

	// Compute routesOfInterest
	[routesOfInterest release];
	routesOfInterest = nil;
	if (![searchBar.text isEqualToString:@""])
	{
		routesOfInterest = [[searchBar.text componentsSeparatedByString:@" "] copy];
	}

	//Filter found stops
	if ([stopsFound count])
		[self filterStopsFound];

	[stopsTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef MAPVIEW_ENABLED
	if (mapTableView.tableHeaderView == NULL)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	BusStop *aStop = [stopsFoundFiltered objectAtIndex:indexPath.row];
	[self showStopOnMap:aStop];
#else
	StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:nil bundle:nil];
	NSMutableArray *stopSelected = [NSMutableArray array];
	[stopSelected addObject:[stopsFoundFiltered objectAtIndex:indexPath.row]];
	stopsVC.stopsOfInterest = stopSelected;
	[stopsVC reload];
	
	[[self navigationController] pushViewController:stopsVC animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
#endif	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
#ifdef MAPVIEW_ENABLED
	StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:nil bundle:nil];
	NSMutableArray *stopSelected = [NSMutableArray array];
	[stopSelected addObject:[stopsFoundFiltered objectAtIndex:indexPath.row]];
	stopsVC.stopsOfInterest = stopSelected;
	[stopsVC reload];
	
	[[self navigationController] pushViewController:stopsVC animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
#endif	
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == mapTableView)
	{
		return MAPWEBVIEWCELL_HEIGHT;
	}
	else
	{
		return 44;
	}
}
*/
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//return [NSString stringWithFormat:@"Stops within ~ %.1f %s", searchRange, UnitName(currentUnit)];	
	return @"Nearby Stops";
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	/*
	if (tableView == mapTableView)
	{
		return 0;
	}
	else
	{
	 */
		if (stopsFoundFiltered == nil)
			return 0;
		return [stopsFoundFiltered count];
	//}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	/*
	if (tableView == mapTableView)
	{
		NSString *MyIdentifier = @"MyIdentifierMapCell";
		
		UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, MAPWEBVIEWCELL_WIDTH, MAPWEBVIEWCELL_HEIGHT) reuseIdentifier:MyIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			//mapWebView = ((WebViewCell *)cell).webView;
			mapWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAPWEBVIEWCELL_WIDTH, MAPWEBVIEWCELL_HEIGHT)];
			mapWebView.userInteractionEnabled = YES;
			mapWebView.multipleTouchEnabled = NO;
			mapWebView.backgroundColor = [UIColor yellowColor];
			mapWebView.clearsContextBeforeDrawing = YES;
			//[cell.contentView addSubview:mapWebView];
			//cell.backgroundView = mapWebView;
			//mapWebView.delegate = nil;
	
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://zyao.servehttp.com:5144/ver1.2/vancouver/stopmap.php?lat=49.338188&long=-123.146257"] 
													 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:20];  // 20 sec;
			[mapWebView loadRequest:request];
			
			//tableFrame.size.width -= 20;
			//mapWebView = [[UIWebView alloc] initWithFrame:tableFrame];
			//[mapWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleWidth];
			//mapWebView.userInteractionEnabled = NO;
			//mapWebView.multipleTouchEnabled = NO;
			//mapWebView.clearsContextBeforeDrawing = YES;
			//mapWebView.delegate = self;
			//[self.view addSubview: mapWebView];	
			//stopsTableView.tableHeaderView = mapWebView;
			
		}
		return cell;
	}
	else
	{
	 */
		NSString *MyIdentifier = @"MyIdentifierCellWithNote";
		
		UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		
		if (cell == nil) 
		{
			//cell = [[[CellWithNote alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
			//cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.adjustsFontSizeToFitWidth = YES;
			//cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
			[cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth]; 
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			//cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
			//cell.textColor = [UIColor blueColor];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
		BusStop *aStop = [stopsFoundFiltered objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@", aStop.name];
		/* \TODO In Vancouver area, showing description is better than the name,
		 *       but I don't want to take the chance here. Maybe other cities have
		 *       empty description field.
		 */
	
		TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
		NSArray *allRoutes = [myApplication allRoutesAtStop:aStop.stopId];
		NSString *routeString=@"";
		for (NSString *routeName in allRoutes)
		{
			//routeString = [routeString stringByAppendingFormat:@" %@", routeName];
			if ([routeString isEqualToString:@""])
				routeString = routeName;
			else
				routeString = [routeString stringByAppendingFormat:@", %@", routeName];			
		}
		//cell.textLabel.text = [NSString stringWithFormat:@"%@", aStop.description];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"[%.1f%s]   %@", 
									 distance(aStop.latitude, aStop.longtitude, currentPosition.y, currentPosition.x), 
									 UnitName(currentUnit), 
									 routeString];
	
		//[cell setNote:[NSString stringWithFormat:@"%.1f%s", 
		//			   distance(aStop.latitude, aStop.longtitude, currentPosition.y, currentPosition.x), UnitName(currentUnit)]];
		return cell;
	//}
}

/*
#pragma mark UIWebView Delegate Protocol

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:applicationTitle message:@"Map load-in failed!"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];	
}
*/

@end

