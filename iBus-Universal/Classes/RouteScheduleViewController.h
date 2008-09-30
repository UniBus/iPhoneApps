//
//  RouteAtStopViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSString *stopID;
	NSString *routeID;
	NSString *dayID;
	NSMutableArray *arrivals;
	UITableView *routeTableView;
}

@property (retain) NSString * stopID;
@property (retain) NSString * routeID;
@property (retain) NSString * dayID;

- (void) arrivalsUpdated: (NSArray *)results;

@end
