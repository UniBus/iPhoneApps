//
//  SettingsViewController.h
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController {
	IBOutlet UITableView *settingView;
	IBOutlet UITableViewCell *rangeCell;
	IBOutlet UITableViewCell *recentCell;
	IBOutlet UITableViewCell *aboutCell;
	IBOutlet UIWebView       *aboutWebCell;
	IBOutlet UISlider        *rangeSlider;
	IBOutlet UISlider        *recentSlider;
	
	float searchRange;
	int   numberOfRecentStops;
}

@property float searchRange;
@property int numberOfRecentStops;

- (IBAction) rangeChanged:(id) sender;
- (IBAction) recentChanged:(id) sender;

@end

