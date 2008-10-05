//
//  SettingViewController.h
//  Metronome
//
//  Created by Zhenwang Yao on 25/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface SettingViewController : UIViewController {
	IBOutlet UITableView	*myTableView;
	RootViewController		*rootViewController;
	NSInteger selectedUpBeat;
	NSInteger selectedDownBeat;	
	NSInteger currentSoundSection;
}

@property (nonatomic, assign)  RootViewController *rootViewController;
- (IBAction)toggleView:(id)sender;
- (void) currentSoundChanged:(NSInteger)newSound;

@end
