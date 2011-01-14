//
//  SoundViewController.h
//  Metronome
//
//  Created by Zhenwang Yao on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingViewController;

@interface SoundViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	//UITableView *soundTableView;
	NSInteger	selectedSound;
	SettingViewController *ownerViewCtrl;
}

@property NSInteger selectedSound;
@property (nonatomic, retain) SettingViewController *ownerViewCtrl;

@end
