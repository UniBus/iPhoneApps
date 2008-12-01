//
//  SettingsAppDelegate.m
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SettingsViewController.h"
#import "CitySelectViewController.h"
#import "TransitApp.h"

#define	RANGE_MAX	2.0
#define	RANGE_MIN	0.1
#define NUMBER_MAX	25
#define NUMBER_MIN	1

#define REGULARCELL_HEIGHT	44
#define REGULARCELL_WIDTH	314

#define SLIDERCELL_HEIGHT	62
#define WEBVIEWCELL_HEIGHT	340

#define SLIDER_WIDTH		270
#define SLIDER_HEIGHT		22
#define WEBVIEW_WIDTH		260
#define WEBVIEW_HEIGHT		300

extern float searchRange;
extern int   numberOfResults;
extern BOOL  globalTestMode;

enum SettingTableSections
{
	kUICity_Section = 0,
	kUIRange_Section,
	kUIRecent_Section,
	kUIAbout_Section,
	kUISetting_Section_Num
};

@implementation SliderCell
@synthesize slider;
- (void) dealloc
{
	[slider release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	slider = [[UISlider alloc] initWithFrame:CGRectMake(14, 20, SLIDER_WIDTH, SLIDER_HEIGHT)];
	[self.contentView addSubview:slider];
	return self;
}

@end


@implementation WebViewCell
@synthesize webView;
- (void) dealloc
{
	[webView release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 20, WEBVIEW_WIDTH, WEBVIEW_HEIGHT)];
	webView.userInteractionEnabled = YES;
	webView.multipleTouchEnabled = NO;
	[self.contentView addSubview:webView];
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	static int numOfTouches = 1;
	numOfTouches ++;
	
	numOfTouches = numOfTouches % 10;
	if (numOfTouches == 0)
	{
		globalTestMode = !globalTestMode;
		if (globalTestMode)
			NSLog(@"Switch to Test mode!!");
		else
			NSLog(@"Switch out of Test mode!!");
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end

@implementation SettingsViewController

//@synthesize searchRange, numberOfRecentStops;
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		// Initialization code
	}
	return self;
}
*/

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView
{
	settingView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[settingView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	settingView.dataSource = self;
	settingView.delegate = self;
	self.view = settingView; 
}
 
- (void)viewDidAppear:(BOOL)animated
{
	[settingView reloadData];
}

// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad
{
	//searchRange = 0.1;
	//numberOfRecentStops = 2;
	[super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationItem.title = @"Settings";
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	searchRange = [defaults floatForKey:UserSavedSearchRange];
	numberOfResults = [defaults integerForKey:UserSavedSearchResultsNum];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	//[super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc 
{
	[super dealloc];
}

#pragma mark Response to User Input

- (IBAction) rangeChanged:(id) sender
{
	if (![sender isKindOfClass:[UISlider class]])
	{
		NSAssert(NO, @"Getting an message from a non-slider object!");
		return;
	}
	
	UISlider *slider = (UISlider *)sender;	
	searchRange = [slider value]; 
	
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 1 inSection:kUIRange_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"Search closest stops within %.1f (Km).", searchRange];
}

- (IBAction) resultNumChanged:(id) sender
{
	if (![sender isKindOfClass:[UISlider class]])
	{
		NSAssert(NO, @"Getting an message from a non-slider object!");
		return;
	}
	UISlider *slider = (UISlider *)sender;
	numberOfResults = [slider value];
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 1 inSection:kUIRecent_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"You may see at most %d stop(s) in results", numberOfResults];
}

- (IBAction) rangeChangedFinial:(id) sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setFloat:searchRange forKey:UserSavedSearchRange];
}

- (IBAction) resultNumChangedFinal:(id) sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setInteger:numberOfResults forKey:UserSavedSearchResultsNum];
}

/*
- (void) startCacheCurrentCity
{
	if (downloader == nil)
	{
		NSString *currentDbName = [(TransitApp *)[UIApplication sharedApplication] currentDatabase];
		NSString *urlString = [NSString stringWithFormat:@"%@ol-%@", OfflineURL, currentDbName];
		downloader = [[DownloadManager alloc] init];
		downloader.delegate = self;
		downloader.hostView = self.view;
		[downloader downloadURL:urlString asFile:currentDbName];
	}
	CityUpdateViewController *updateVC = [[CityUpdateViewController alloc] initWithNibName:nil bundle:nil];
	[[self navigationController] pushViewController:updateVC animated:YES];
}
*/

#pragma mark UITableView Delegate Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kUISetting_Section_Num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == kUICity_Section)
		return 1;
	else
		return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		if (indexPath.section == kUICity_Section)
		{
			return REGULARCELL_HEIGHT;
		}
		else if ( indexPath.section == kUIRange_Section )
		{
			return SLIDERCELL_HEIGHT;
		}
		else if ( indexPath.section == kUIRecent_Section )
		{
			return SLIDERCELL_HEIGHT;
		}
		else
		{
			return WEBVIEWCELL_HEIGHT;
		}
	}
	
	else
	{
		if (indexPath.section == kUICity_Section)
			return REGULARCELL_HEIGHT;
		else
			return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title;
	switch (section) {
		case kUICity_Section:
			title = @"Current City";
			break;
		case kUIRange_Section:
			title = @"Search Range";
			break;
		case kUIRecent_Section:
			title = @"Search Results";
			break;
		case kUIAbout_Section:
			title = @"About & Disclaimer";
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
		if (indexPath.section == kUICity_Section)
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CitySelectionCell"];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CitySelectionCell"] autorelease]; 
				cell.font = [UIFont systemFontOfSize:14];
				cell.textAlignment = UITextAlignmentCenter;
			}
			NSAssert([[UIApplication sharedApplication] isKindOfClass:[TransitApp class]], @"Application mismatch!");
			cell.text = [(TransitApp *)[UIApplication sharedApplication] currentCity];
			return cell;
		}
		else if ( indexPath.section == kUIRange_Section )
		{
			if (rangeCell == nil)
			{
				rangeCell = [[SliderCell alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"rangeCell"];
				[rangeCell.slider addTarget:self action:@selector(rangeChanged:) forControlEvents:UIControlEventValueChanged];
				[rangeCell.slider addTarget:self action:@selector(rangeChangedFinial:) forControlEvents:UIControlEventTouchUpInside];
				[rangeCell.slider addTarget:self action:@selector(rangeChangedFinial:) forControlEvents:UIControlEventTouchUpOutside];
				rangeCell.selectionStyle = UITableViewCellSelectionStyleNone;
				rangeCell.slider.maximumValue = RANGE_MAX;
				rangeCell.slider.minimumValue = RANGE_MIN;
				rangeCell.slider.value = searchRange;
			}
			return rangeCell;
		}
		else if ( indexPath.section == kUIRecent_Section )
		{
			if (resultCell == nil)
			{
				resultCell = [[SliderCell alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"resultCell"];
				[resultCell.slider addTarget:self action:@selector(resultNumChanged:) forControlEvents:UIControlEventValueChanged];
				[resultCell.slider addTarget:self action:@selector(resultNumChangedFinal:) forControlEvents:UIControlEventTouchUpInside];
				[resultCell.slider addTarget:self action:@selector(resultNumChangedFinal:) forControlEvents:UIControlEventTouchUpOutside];
				resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
				resultCell.slider.maximumValue = NUMBER_MAX;
				resultCell.slider.minimumValue = NUMBER_MIN;
				resultCell.slider.value = numberOfResults;
			}
			return resultCell;
		}
		else
		{
			if (aboutCell == nil)
			{
				aboutCell = [[WebViewCell alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, WEBVIEWCELL_HEIGHT) reuseIdentifier:@"aboutCell"];
				aboutCell.webView.delegate = self;
				NSString *pathToHTML = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
				NSURL *url = [NSURL fileURLWithPath:pathToHTML];	
				[aboutCell.webView loadRequest:[NSURLRequest requestWithURL:url]];
				aboutCell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			return aboutCell;
		}
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
			cell.textAlignment = UITextAlignmentCenter;
		}
		if ( indexPath.section == kUIRange_Section )
		{
			cell.text = [NSString stringWithFormat: @"Search closest stops within %.1f (Km).", searchRange];
		}
		else if ( indexPath.section == kUIRecent_Section)
		{
			cell.text = [NSString stringWithFormat: @"You may see at most %d stop(s) in results", numberOfResults];					
		}
		else
		{		
			cell.text = @"Copyright @ 2008 Zhenwang Yao";
		}
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	static int numOfTouches = 1;
	if ((indexPath.section == kUIAbout_Section) && (indexPath.row==1))
	{
		numOfTouches ++;		
		numOfTouches = numOfTouches % 10;
		if (numOfTouches == 0)
		{
			globalTestMode = !globalTestMode;
			if (globalTestMode)
				NSLog(@"Switch to Test mode!!");
			else
				NSLog(@"Switch out of Test mode!!");
		}
	}
	
	if (indexPath.section != kUICity_Section)
		return;
	
	if (indexPath.row == 0)
	{
		CitySelectViewController *selectionVC = [[CitySelectViewController alloc] initWithNibName:nil bundle:nil];
		selectionVC.delegate = [UIApplication sharedApplication];
		[[self navigationController] pushViewController:selectionVC animated:YES];
	}
	
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

@implementation SearchRangeCell

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end



