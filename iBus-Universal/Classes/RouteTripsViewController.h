//
//  TripViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusRoute.h"

@interface RouteTripsViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	BusRoute		*theRoute;
	NSMutableArray	*tripsOnRoute;
	UITableView		*tripsTableView;
}

@property (retain) BusRoute *theRoute;

- (NSString *) routeID;

@end
