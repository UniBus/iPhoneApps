//
//  iPhoneTransitAppDelegate.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPhoneTransitAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	//IBOutlet UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

- (void)dataDidFinishLoading:(id)data;
//- (void)queryDidFinishLoading:(id)queryingObj;

@end
