//
//  TripViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusTrip.h"

@interface TripStopsViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	NSMutableArray	*stopIdsOnTrip;
	//NSMutableArray	*stopsOnTrip;
	BusTrip			*theTrip;
	UITableView		*stopsTableView;
}

@property (retain) BusTrip *theTrip;

- (NSString *) tripID;

@end
