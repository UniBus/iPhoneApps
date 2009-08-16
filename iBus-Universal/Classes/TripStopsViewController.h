//
//  TripViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusTrip.h"

@interface TripStopsViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	//NSMutableArray	*stopsOnTrip;
	//BusTrip			*theTrip;
	NSMutableArray	*stopIdsOnTrip;
	NSString        *routeId;
	NSString        *dirId;
	NSString        *headSign;
	NSString        *tripId;
	bool            queryByRouteId;
	UITableView		*stopsTableView;
}

@property (retain) NSString *routeId;
@property (retain) NSString *dirId;
@property (retain) NSString *headSign;
@property (retain) NSString *tripId;
@property bool queryByRouteId;

@end
