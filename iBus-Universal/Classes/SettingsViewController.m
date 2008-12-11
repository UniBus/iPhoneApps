//
//  SettingsAppDelegate.m
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SettingsViewController.h"
#import "CitySelectViewController.h"
#import "CityUpdateViewController.h"
#import "OfflineViewController.h"
#import "InfoViewController.h"
#import "TransitApp.h"

#define	RANGE_MAX	5.0
#define	RANGE_MIN	0.1
#define NUMBER_MAX	25
#define NUMBER_MIN	1

#define REGULARCELL_HEIGHT	44
#define REGULARCELL_WIDTH	314

#define SLIDERCELL_HEIGHT	62
#define SLIDER_WIDTH		180
#define SLIDER_HEIGHT		22
#define SLIDER_LEFT			100
#define SLIDER_TOP			20

#define SEGMENTCELL_HEIGHT	62
#define SEGMENT_WIDTH		100
#define SEGMENT_HEIGHT		44
#define SEGMENT_LEFT		180
#define SEGMENT_TOP			10

#define WEBVIEWCELL_HEIGHT	340
#define WEBVIEW_WIDTH		260
#define WEBVIEW_HEIGHT		300
#define WEBVIEW_LEFT		20
#define WEBVIEW_TOP			20

extern float searchRange;
extern int   numberOfResults;
extern BOOL  globalTestMode;
extern int   currentUnit;

extern BOOL  cityUpdateAvaiable;
extern BOOL  offlineUpdateAvailable;
extern BOOL  offlineDownloaded;

char *UnitName(int unit);

enum SettingTableSections
{
	kUICity_Section = 0,
	kUISearch_Section,
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
	slider = [[UISlider alloc] initWithFrame:CGRectMake(SLIDER_LEFT, SLIDER_TOP, SLIDER_WIDTH, SLIDER_HEIGHT)];
	[self.contentView addSubview:slider];
	return self;
}

@end

@implementation SegmentCell
@synthesize segment;
- (void) dealloc
{
	[segment release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: CGRectZero reuseIdentifier:reuseIdentifier];	
	segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(SEGMENT_LEFT, SEGMENT_TOP, SEGMENT_WIDTH, SEGMENT_HEIGHT)];
	[self.contentView addSubview:segment];
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
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(WEBVIEW_LEFT, WEBVIEW_TOP, WEBVIEW_WIDTH, WEBVIEW_HEIGHT)];
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
	currentUnit = [defaults integerForKey:UserSavedDistanceUnit];
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
	
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 3 inSection:kUISearch_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
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
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 3 inSection:kUISearch_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
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

- (IBAction) unitChanged:(id) sender
{
	if (![sender isKindOfClass:[UISegmentedControl class]])
	{
		NSAssert(NO, @"Getting an message from a non-UISegmentedController object!");
		return;
	}
	
	UISegmentedControl *segment = (UISegmentedControl *)sender;	
	currentUnit = segment.selectedSegmentIndex;
	
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 3 inSection:kUISearch_Section]];
	[cellToUpdate editAction];
	cellToUpdate.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setFloat:currentUnit forKey:UserSavedDistanceUnit];
}

#pragma mark UITableView Delegate Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kUISetting_Section_Num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == kUICity_Section)
		return 4;
	else if (section == kUISearch_Section)
		return 4;
	else
		return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kUICity_Section:
			return REGULARCELL_HEIGHT;				
			break;
		case kUISearch_Section:
			if ( (indexPath.row == 0) || (indexPath.row == 1) )
				return SLIDERCELL_HEIGHT;
			else if (indexPath.row == 2)
				return SEGMENTCELL_HEIGHT;
			else 
				return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
			break;
		case kUIAbout_Section:
			if (indexPath.row == 0)
				return WEBVIEWCELL_HEIGHT;
			else
				return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
			break;
		default:
			break;
	}
	
	NSAssert(NO, @"Unhandled section!");
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title;
	switch (section) {
		case kUICity_Section:
			title = @"Current City";
			break;
		case kUISearch_Section:
			title = @"Search Parameters";
			break;
		case kUIAbout_Section:
			title = @"About & Disclaimer";
			break;
		default:
			title = @"";
			break;
	}
	return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;

	if (indexPath.section == kUICity_Section)
	{
		//NSAssert(indexPath.row==0, @"Unhandled row in kUICity_Section");
		cell = [tableView dequeueReusableCellWithIdentifier:@"CitySelectionCell"];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CitySelectionCell"] autorelease]; 
			cell.font = [UIFont boldSystemFontOfSize:14];
			cell.textAlignment = UITextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textColor = [UIColor blackColor];
		if (indexPath.row == 0)
		{
			cell.text = [(TransitApp *)[UIApplication sharedApplication] currentCity];
		}
		else if (indexPath.row == 1)
		{
			if (cityUpdateAvaiable)
			{
				cell.textColor = [UIColor redColor];
				cell.text = @"New update available";
			}
			else
				cell.text = @"Already up to date";
		}
		else if (indexPath.row == 2)
		{
			if (!offlineDownloaded)
				cell.text = @"Offline viewing available";
			else if (offlineUpdateAvailable)
			{
				cell.textColor = [UIColor redColor];
				cell.text = @"New offline data available";
			}
			else
				cell.text = @"Offline data up to date";
		}			
		else
		{
			cell.text = @"Information";
		}
	}
	else if ( indexPath.section == kUISearch_Section )
	{
		if ( indexPath.row == 0 )
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
				resultCell.font = [UIFont boldSystemFontOfSize:16];
				resultCell.text = @"Maximum ";
			}
			cell = resultCell;
		}
		else if ( indexPath.row == 1 )
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
				rangeCell.font = [UIFont boldSystemFontOfSize:16];
				rangeCell.text = @"Range ";
			}
			cell = rangeCell;
		}
		else if ( indexPath.row == 2 )
		{
			if (unitCell == nil)
			{
				unitCell = [[SegmentCell alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"unitCell"];
				[unitCell.segment insertSegmentWithTitle:@"Km" atIndex:0 animated:NO];
				[unitCell.segment insertSegmentWithTitle:@"Mi" atIndex:1 animated:NO];				
				[unitCell.segment addTarget:self action:@selector(unitChanged:) forControlEvents:UIControlEventValueChanged];
				unitCell.segment.selectedSegmentIndex =currentUnit;
				unitCell.selectionStyle = UITableViewCellSelectionStyleNone;
				unitCell.font = [UIFont boldSystemFontOfSize:16];
				unitCell.text = @"Distance Unit ";
			}
			cell = unitCell;
		}
		else
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingViewCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//[cell setSeparatorStyle: UITableViewCellSeparatorStyleNone];
			cell.font = [UIFont systemFontOfSize:12];
			cell.textAlignment = UITextAlignmentCenter;
			cell.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
		}
	}
	else
	{
		NSAssert(indexPath.section == kUIAbout_Section, @"Unhandled section");
		if (indexPath.row == 0)
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
			cell = aboutCell;		
		}
		else
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingViewCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//[cell setSeparatorStyle: UITableViewCellSeparatorStyleNone];
			cell.font = [UIFont systemFontOfSize:12];
			cell.textAlignment = UITextAlignmentCenter;
			cell.text = @"Copyright @ 2008 Zhenwang Yao";
		}
	}
	return cell;
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
	else if (indexPath.row == 1)
	{
		CityUpdateViewController *updateVC = [[CityUpdateViewController alloc] initWithNibName:nil bundle:nil];
		[[self navigationController] pushViewController:updateVC animated:YES];
	}
	else if (indexPath.row == 2)
	{
		OfflineViewController *offlineVC = [[OfflineViewController alloc] initWithNibName:nil bundle:nil];
		[[self navigationController] pushViewController:offlineVC animated:YES];
	}
	else
	{
		InfoViewController *infoVC = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
		[[self navigationController] pushViewController:infoVC animated:YES];
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



