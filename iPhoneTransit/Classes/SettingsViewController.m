//
//  SettingsAppDelegate.m
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SettingsViewController.h"


enum SettingTableSections
{
	kUIRange_Section = 0,
	kUIRecent_Section,
	kUIAbout_Section,
	kUISetting_Section_Num
};

@implementation SettingsViewController

@synthesize searchRange, numberOfRecentStops;


// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
	searchRange = 0.1;
	numberOfRecentStops = 2;
	
	[super loadView];

	NSMutableString *content =[NSMutableString  stringWithString: @"<html> Author: Zhenwang Yao <br><br>"];
	[content appendString:@"This is an application based on Google Transit Feed data. Web service is provided by "];
	[content appendString:@"<a href=\"http://developer.trimet.org/\">Trimet</a>. </html>"];
	[aboutWebCell loadHTMLString:content baseURL:nil];
}

/*
// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark Response to User Input

- (IBAction) rangeChanged:(id) sender
{
	searchRange = [rangeSlider value]; 
	
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 1 inSection:kUIRange_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"Search closest stops within %.1f (Km).", searchRange];
}

- (IBAction) recentChanged:(id) sender
{
	numberOfRecentStops = [recentSlider value];
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 1 inSection:kUIRecent_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"You may see at most %d stop(s) in recent list", numberOfRecentStops];
}

#pragma mark UITableView Delegate Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kUISetting_Section_Num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 2;//2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		CGRect cellBound;
		if ( indexPath.section == kUIRange_Section )
		{
			cellBound = [rangeCell bounds];
			return cellBound.size.height;
		}
		else if ( indexPath.section == kUIRecent_Section )
		{
			cellBound = [recentCell bounds];
			return cellBound.size.height;
		}
		else
		{
			cellBound = [aboutCell bounds];
			return cellBound.size.height;
		}
	}
	
	else
		return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title;
	switch (section) {
		case kUIRange_Section:
			title = @"Search Range";
			break;
		case kUIRecent_Section:
			title = @"Recent Stops";
			break;
		case kUIAbout_Section:
			title = @"About";
			break;
		default:
			break;
	}
	return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	
	if (row == 0)
	{
		if ( indexPath.section == kUIRange_Section )
			return rangeCell;
		else if ( indexPath.section == kUIRecent_Section )
			return recentCell;
		else
			return aboutCell;
	}
	else if (row == 1)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell"];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingViewCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//[cell setSeparatorStyle: UITableViewCellSeparatorStyleNone];
			cell.font = [UIFont systemFontOfSize:12];
		}
		if ( indexPath.section == kUIRange_Section )
		{
			cell.text = [NSString stringWithFormat: @"Search closest stops within %.1f (Km).", searchRange];
		}
		else if ( indexPath.section == kUIRecent_Section)
		{
			cell.text = [NSString stringWithFormat: @"You may see at most %d stop(s) in recent list", numberOfRecentStops];					
		}
		else
		{			
			cell.text = @"Copyright @ 2008 Zhenwang Yao";
		}
		return cell;
	}
	else
		return nil;
}

#pragma mark WebView Delegate Functions

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}	
	else 
		return YES;
}

@end


