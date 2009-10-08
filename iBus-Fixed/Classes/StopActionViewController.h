//
//  StopActionViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 05/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "BusStop.h"

@interface StopActionViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> 
{
	BusStop *theStop;
	UITableView *stopActionTableView;	
}

- (void) setStop: (BusStop *) aStop;
- (void) showStopOnMap;
- (void) showNearbyStops;

@end
