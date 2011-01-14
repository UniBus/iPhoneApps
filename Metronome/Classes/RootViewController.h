//
//  RootViewController.h
//  Metronome
//
//  Created by Zhenwang Yao on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MetronomeViewController;
@class SettingViewController;

@interface RootViewController : UIViewController {
    MetronomeViewController *metronomeViewController;
    SettingViewController	*settingViewController;
}

@property (nonatomic, retain) MetronomeViewController *metronomeViewController;
@property (nonatomic, retain) SettingViewController *settingViewController;

- (IBAction)toggleView:(id)sender;

@end
