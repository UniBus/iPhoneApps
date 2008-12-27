//
//  StopSearchViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
	UISearchBar *stopSearchBar;
	UITableView *stopsTableView;
	NSArray *stopsFound;
}

- (void) reset;

@end
