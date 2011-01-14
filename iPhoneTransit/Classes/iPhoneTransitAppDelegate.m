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
#import "TransitApp.h"

extern NSString * const UserSavedSelectedPage;

@implementation iPhoneTransitAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)dataDidFinishLoading:(id)data
{
	if (window == nil)
		return;
	
	if ([window isHidden])
		return;
	
	UIViewController *selectedViewController = [tabBarController selectedViewController];
	if ([selectedViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navigController = (UINavigationController *)selectedViewController;
		if ([navigController.visibleViewController isKindOfClass:[StopsViewController class]])
			[(StopsViewController *)(navigController.visibleViewController) needsReload];
	}
	
#ifdef _ENABLE_INDICATOR_	
	(UIApplication *)application = [UIApplication sharedApplication];	

	if ([application isKindOfClass:[TransitApp class]])
	{
		TransitApp *myApp = (TransitApp *)application;
		if (myApp.arrivalQueryAvailable && myApp.stopQueryAvailable)
		{
			[indicator stopAnimating];
			[indicator removeFromSuperview];
		}
	}
	else
	{
		if ([indicator isAnimating])
		{
			[indicator stopAnimating];
			[indicator removeFromSuperview];
		}
	}
#endif
	
}

//- (void)queryDidFinishLoading:(id)queryingObj
//{
//	
//}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Add the tab bar controller's current view as a subview of the window
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
	if (selectedPage < [tabBarController.viewControllers count])
		tabBarController.selectedIndex = selectedPage;

    [window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];

#ifdef _ENABLE_INDICATOR_	
	//[window addSubview:indicator];
	//[indicator startAnimating];
#endif	
	if ([application isKindOfClass:[TransitApp class]])
	{
		[(TransitApp *)application loadStopDataInBackground];
	}
}



// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)theTabBar didSelectViewController:(UIViewController *)viewController 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults integerForKey:UserSavedSelectedPage] != tabBarController.selectedIndex)
		[defaults setInteger:tabBarController.selectedIndex forKey:UserSavedSelectedPage];
}


/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)theTabBar didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

