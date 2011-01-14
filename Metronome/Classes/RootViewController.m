//
//  RootViewController.m
//  Metronome
//
//  Created by Zhenwang Yao on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SettingViewController.h"
#import "MetronomeViewController.h"

@implementation RootViewController

@synthesize metronomeViewController;
@synthesize settingViewController;


- (void)viewDidLoad {
    MetronomeViewController *viewController = [[MetronomeViewController alloc] initWithNibName:@"MetronomeView" bundle:nil];
    viewController.rootViewController = self;
    self.metronomeViewController = viewController;
    [viewController release];
	
	assert(self.metronomeViewController && self.metronomeViewController.view);
    [self.view addSubview:self.metronomeViewController.view];
}


- (void)loadFlipsideViewController {
    SettingViewController *viewController = [[SettingViewController alloc] initWithNibName:@"SettingView" bundle:nil];
    viewController.rootViewController = self;
    self.settingViewController = viewController;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navigationController.view.frame = CGRectMake(0, 0, 320, 480);
    [viewController release];
}


- (IBAction)toggleView:(id)sender {	
    // This method is called when the info or Done button is pressed.
    // It flips the displayed view from the main view to the flipside view and vice-versa.
	
	if (settingViewController == nil) {
		[self loadFlipsideViewController];
	}
	
	UIView *mainView = metronomeViewController.view;
	UIView *flipsideView = settingViewController.navigationController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ([mainView superview] != nil) {
		[settingViewController.navigationController viewWillAppear:YES];
		[metronomeViewController viewWillDisappear:YES];
		[mainView removeFromSuperview];
		[self.view addSubview:flipsideView];
		[metronomeViewController viewDidDisappear:YES];
		[settingViewController.navigationController viewDidAppear:YES];
		
	} else {
		[metronomeViewController viewWillAppear:YES];
		[settingViewController.navigationController viewWillDisappear:YES];
		[flipsideView removeFromSuperview];
		[self.view addSubview:mainView];
		[settingViewController.navigationController viewDidDisappear:YES];
		[metronomeViewController viewDidAppear:YES];
	}
	[UIView commitAnimations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [metronomeViewController release];
    [settingViewController release];
    [super dealloc];
}

@end
