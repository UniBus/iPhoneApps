//
//  iBus_UniversalAppDelegate.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "TransitAppDelegate.h"
#import "TransitApp.h"
#import "StopsViewController.h"
#import "StopSearchViewController.h"
#import "CitySelectViewController.h"
#import "FavoriteViewController.h"
#import "SettingsViewController.h"
#import "CityUpdateViewController.h"

@implementation TransitAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// Add the tab bar controller's current view as a subview of the window
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *selectedCityId = [defaults objectForKey:UserCurrentCityId];
	NSString *selectedCity = [defaults objectForKey:UserCurrentCity];
	NSString *selectedDatabase = [defaults objectForKey:USerCurrentDatabase];
	NSString *selectedWebPrefix = [defaults objectForKey:UserCurrentWebPrefix];
	
	// This is the first time it run the App.
	if ([selectedCity isEqualToString:@""] || [selectedDatabase isEqualToString:@""] || [selectedWebPrefix isEqualToString:@""])
	{
		
		CitySelectViewController *selectionVC = [[CitySelectViewController alloc] initWithNibName:nil bundle:nil];
		selectionVC.delegate = self;

		configController = [[UINavigationController alloc] initWithRootViewController:selectionVC];	
		configController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
		[window makeKeyWindow];
		[window addSubview:configController.view];
	}
	else
	{
		TransitApp *myApp = (TransitApp *)[UIApplication sharedApplication];
		NSAssert([myApp isKindOfClass:[TransitApp class]], @"Mismatched UIApplication type!!");
		
		[myApp setCurrentCity:selectedCity cityId:selectedCityId database:selectedDatabase webPrefix:selectedWebPrefix];
		int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
		if (selectedPage < [tabBarController.viewControllers count])
			tabBarController.selectedIndex = selectedPage;
	
		[window makeKeyAndVisible];	
		[window addSubview:tabBarController.view];
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
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

- (void) citySelected:(id)sender
{
	TransitApp *myApp = (TransitApp *)[UIApplication sharedApplication];
	NSAssert([myApp isKindOfClass:[TransitApp class]], @"Mismatched UIApplication type!!");
	[myApp citySelected:sender];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
	if (selectedPage < [tabBarController.viewControllers count])
		tabBarController.selectedIndex = selectedPage;
	
	[configController.view removeFromSuperview];
	[window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];	
	[configController release];
	configController = nil;
}

- (void) cityDidChange
{
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			[(UINavigationController *)vc popToRootViewControllerAnimated:NO];
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[StopsViewController class]])
				[(StopsViewController  *)subVC reset];
			else if ([subVC isKindOfClass:[StopSearchViewController class]])
				[(StopSearchViewController  *)subVC reset];
		}
	}	
}

- (void) favoriteDidChange:(id)sender
{
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[FavoriteViewController class]])
				[(FavoriteViewController  *)subVC reset];
		}
	}
}

- (void) onlineUpdateRequested:(id)sender
{
	if (configController)
	{
		[configController popToRootViewControllerAnimated:NO];
		CityUpdateViewController *updateVC = [[CityUpdateViewController alloc] initWithNibName:nil bundle:nil];
		[configController pushViewController:updateVC animated:YES];
		return;
	}
	
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[SettingsViewController class]])
			{
				[(UINavigationController *)vc popToRootViewControllerAnimated:NO];
				[(SettingsViewController *)subVC startOnlineUpdate];
			}
		}
	}
}

@end

