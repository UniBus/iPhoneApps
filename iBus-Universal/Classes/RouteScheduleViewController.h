//
//  RouteAtStopViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSString *stopID;
	NSString *routeID;
	NSString *dayID;
	NSString *direction;
	NSMutableArray *arrivals;
	UITableView *routeTableView;
}

@property (retain) NSString * stopID;
@property (retain) NSString * routeID;
@property (retain) NSString * dayID;
@property (retain) NSString * direction;

- (void) arrivalsUpdated: (NSArray *)results;

@end
