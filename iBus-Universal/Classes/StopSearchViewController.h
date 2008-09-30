//
//  StopSearchViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 21/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
	//IBOutlet UISearchBar *stopSearchBar;
	UITableView *stopsTableView;
	NSArray *stopsFound;
}

@end
