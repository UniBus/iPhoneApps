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
	NSString *routeID;
	NSDate   *otherDate;
	UITableView *routeTableView;
}

- (void) setStopId: (NSString *) stop;
- (void) setRouteId: (NSString *) route;
- (void) showInfoOfRoute: (NSString*)route atStop:(NSString *)stop;

@end
