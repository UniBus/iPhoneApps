//
//  InfoViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
#import <SystemConfiguration/SCNetworkReachability.h>
#import "InfoViewController.h"
#import "TransitApp.h"
#import "NoNetworkView.h"

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

- (BOOL) available:(NSURL *)targetingUrl
{
	SCNetworkReachabilityFlags        flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [[targetingUrl host] UTF8String]);
    BOOL gotFlags = SCNetworkReachabilityGetFlags(reachability, &flags);    
	CFRelease(reachability);
	if (!gotFlags) 
        return NO;
	
    if ( !(flags & kSCNetworkReachabilityFlagsReachable))
		return NO;
	
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) 
		return NO;
    
	return YES;
}

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{	
	infoWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[infoWebView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	infoWebView.delegate = self;
	infoWebView.opaque = NO;
	infoWebView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.view = infoWebView;
	self.navigationItem.title = @"Information";	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	NSString *urlString = [NSString stringWithFormat:@"%@/localinfo.php", [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix]];
	if (urlString)
	{
		NSURL *url = [NSURL URLWithString:urlString];
		if([self available:url])
			[infoWebView loadRequest:[NSURLRequest requestWithURL:url]];
		else
		{
			UIView *noNetworkView = [[NoNetworkView alloc] initWithFrame:[UIScreen mainScreen].bounds]; 
			[noNetworkView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
			noNetworkView.multipleTouchEnabled = NO;
			[self.view addSubview:noNetworkView]; 
			[noNetworkView release];			
		}
	}	
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
	NSString *urlString = [NSString stringWithFormat:@"%@/localinfo.php", [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix]];
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
