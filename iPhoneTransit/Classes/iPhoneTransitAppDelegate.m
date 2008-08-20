//
//  iPhoneTransitAppDelegate.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "iPhoneTransitAppDelegate.h"
#import "ClosestViewController.h"
#import "RecentViewController.h"
#import "FavoriteViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"


@implementation iPhoneTransitAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Add the tab bar controller's current view as a subview of the window
	
	for (UIViewController *viewController in tabBarController.viewControllers)
	{
		if ([viewController isKindOfClass:[ClosestViewController class]])
			viewController.tabBarItem.image = [UIImage imageNamed:@"closest.png"];
		else if ([viewController isKindOfClass:[SettingsViewController class]])
			viewController.tabBarItem.image = [UIImage imageNamed:@"setting.png"];
		else if ([viewController isKindOfClass:[RecentViewController class]])
			viewController.tabBarItem.image = [UIImage imageNamed:@"recent.png"];
		else if ([viewController isKindOfClass:[SearchViewController class]])
			viewController.tabBarItem.image = [UIImage imageNamed:@"search.png"];
		else if ([viewController isKindOfClass:[FavoriteViewController class]])
			viewController.tabBarItem.image = [UIImage imageNamed:@"favorite.png"];
	}
	
	
	[window addSubview:tabBarController.view];
}


/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

