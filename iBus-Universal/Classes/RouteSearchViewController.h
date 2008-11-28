//
//  StopSearchViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
	UISearchBar *routeSearchBar;
	UITableView *routesTableView;
	NSArray *routesFound;
}

- (void) reset;

@end
