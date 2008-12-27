//
//  RouteViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteActionViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	NSString *stopName;
	NSString *stopID;
	NSString *routeName;
	NSString *routeID;
	NSInteger routeType;
	NSString *busSign;
	NSString *direction;
	NSDate   *otherDate;
	UITableView *routeTableView;
}

- (void) setStopId: (NSString *) sname stopId: (NSString *)sid;
- (void) setRoute: (NSString *) rname routeId: (NSString *)rid direction:(NSString *)dir;
- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid direction:(NSString *)dir atStop:(NSString *)sname stopId:(NSString *)sid withSign:(NSString *)sign;

@end
