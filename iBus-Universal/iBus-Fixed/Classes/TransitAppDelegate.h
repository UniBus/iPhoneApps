//
//  iBus_UniversalAppDelegate.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright Zhenwang Yao. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UINavigationController *configController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

- (void) citySelected:(id)sender;
- (void) favoriteDidChange:(id)sender;
//- (void) onlineUpdateRequested:(id)sender;

@end
