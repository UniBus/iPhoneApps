//
//  MetronomeAppDelegate.h
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MetronomeViewController;

@interface MetronomeAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet MetronomeViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MetronomeViewController *viewController;

@end

