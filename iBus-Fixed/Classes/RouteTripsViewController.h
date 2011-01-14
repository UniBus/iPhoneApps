//
//  TripViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusRoute.h"

@interface RouteTripsViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	NSString        *routeID;
	NSString        *dirID;
	NSMutableArray	*tripsOnRoute;
	UITableView		*tripsTableView;
}

@property (retain) NSString *routeID;
@property (retain) NSString *dirID;

@end
