//
//  AboutViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 13/07/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
	
	aboutWebView.delegate = self;
	NSString *pathToHTML = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:pathToHTML];	
	[aboutWebView loadRequest:[NSURLRequest requestWithURL:url]];
    return self;
}
//*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	aboutWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[aboutWebView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	aboutWebView.delegate = self;
	aboutWebView.opaque = NO;
	aboutWebView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	aboutWebView.userInteractionEnabled = NO;
	aboutWebView.multipleTouchEnabled = NO;
	//aboutWebView.background
	self.view = aboutWebView;
	self.navigationItem.title = @"About UniBus";	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	aboutWebView.delegate = self;
	NSString *pathToHTML = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:pathToHTML];	
	[aboutWebView loadRequest:[NSURLRequest requestWithURL:url]];	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
