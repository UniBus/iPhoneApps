//
//  InfoViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "TransitApp.h"

@implementation InfoViewController

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	
	infoWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[infoWebView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	infoWebView.delegate = self;
	self.view = infoWebView;
	self.navigationItem.title = @"Information";	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidAppear:(BOOL)animated
{
	NSString *urlString = [NSString stringWithFormat:@"%@/info.html", [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix]];
	if (urlString)
	{
		NSURL *url = [NSURL URLWithString:urlString];	
		[infoWebView loadRequest:[NSURLRequest requestWithURL:url]];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[infoWebView release];
    [super dealloc];
}


@end
