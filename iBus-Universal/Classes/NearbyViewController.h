//
//  ClosestViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> //</CLLocationManager.h>
#import "MapViewController.h"
//#import "StopsViewController.h"

@interface NearbyViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	CLLocationManager		*location;
	UIActivityIndicatorView *indicator;
	CGPoint					currentPosition;
	
	UISearchBar             *routeSearchBar;
	//UIWebView               *mapWebView;
	UITableView             *mapTableView;
	UITableView				*stopsTableView;
	NSArray					*stopsFound;
	NSMutableArray			*stopsFoundFiltered;
	NSMutableArray			*routesOfInterest;
	BOOL					needReset;
	BOOL                    explicitLocation;
}

- (void) reset;
- (void) setExplictLocation:(CGPoint)exPos;

@property BOOL explicitLocation;

@end
