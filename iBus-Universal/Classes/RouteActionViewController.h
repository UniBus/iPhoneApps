//
//  RouteViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteActionViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	NSString *stopID;
	NSString *route;
	NSString *routeID;
	NSString *busSign;
	NSDate   *otherDate;
	UITableView *routeTableView;
}

- (void) setStopId: (NSString *) stop;
- (void) setRoute: (NSString *) rname routeId: (NSString *)rid;
- (void) showInfoOfRoute: (NSString*)rname routeId:(NSString *)rid atStop:(NSString *)stop withSign:(NSString *)sign;

@end
