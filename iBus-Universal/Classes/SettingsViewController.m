//
//  SettingsAppDelegate.m
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright Zhenwang Yao. 2008. All rights reserved.
//

#import "SettingsViewController.h"
#import "CitySelectViewController.h"
#import "CityUpdateViewController.h"
#import "OfflineViewController.h"
#import "TagManagerViewController.h"
#import "InfoViewController.h"
#import "AboutViewController.h"
#import "TransitApp.h"
#import "StopsViewController.h"
#import "General.h"

#define	RANGE_MAX	5.0
#define	RANGE_MIN	0.1
#define NUMBER_MAX	25
#define NUMBER_MIN	1

extern float searchRange;
extern int   numberOfResults;
extern BOOL  globalTestMode;
extern int   currentUnit;
extern int   currentTimeFormat;

extern BOOL  cityUpdateAvaiable;
extern BOOL  offlineUpdateAvailable;
extern BOOL  offlineDownloaded;

char *UnitName(int unit);

enum SettingTableSections
{
	kUICity_Section = 0,
	kUISearch_Section,
	kUIGeneral_Section,
	//kUIAbout_Section,
	kUISetting_Section_Num
};

@implementation SettingsViewController

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	searchRange = [defaults floatForKey:UserSavedSearchRange];
	numberOfResults = [defaults integerForKey:UserSavedSearchResultsNum];
	currentUnit = [defaults integerForKey:UserSavedDistanceUnit];
	currentTimeFormat = [defaults integerForKey:UserSavedTimeFormat];
	
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
	//[cellToUpdate editAction];
	cellToUpdate.textLabel.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
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
	//[cellToUpdate editAction];
	cellToUpdate.textLabel.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
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
	if (![sender isKindOfClass:[UISwitch class]])
	{
		NSAssert(NO, @"Getting an message from a non-UISwitch object!");
		return;
	}
	
	UISwitch *theSwitch = (UISwitch *)sender;
	if (theSwitch.on)
		currentUnit = UNIT_MI;
	else
		currentUnit = UNIT_KM;
	
	UITableViewCell *cellToUpdate = [settingView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 3 inSection:kUISearch_Section]];
	//[cellToUpdate editAction];
	cellToUpdate.textLabel.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setInteger:currentUnit forKey:UserSavedDistanceUnit];
}

- (IBAction) timeFormatChanged:(id) sender
{
	if (![sender isKindOfClass:[UISwitch class]])
	{
		NSAssert(NO, @"Getting an message from a non-UISwitch object!");
		return;
	}
	
	UISwitch *theSwitch = (UISwitch *)sender;
	if (theSwitch.on)
		currentTimeFormat = TIME_24H;
	else
		currentTimeFormat = TIME_12H;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setInteger:currentTimeFormat forKey:UserSavedTimeFormat];
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
	else if (section == kUIGeneral_Section)
		return 2;
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
		case kUIGeneral_Section:
			return REGULARCELL_HEIGHT;				
			break;
		case kUISearch_Section:
			if ( (indexPath.row == 0) || (indexPath.row == 1) )
				return REGULARCELL_HEIGHT;
			else if (indexPath.row == 2)
				return REGULARCELL_HEIGHT;
			else 
				return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
			break;
		/*
		case kUIAbout_Section:
			if (indexPath.row == 0)
				return WEBVIEWCELL_HEIGHT;
			else
				return [[UIFont fontWithName:@"HelveticaBold" size:12] capHeight] + 32;
			break;
		*/
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
		case kUIGeneral_Section:
			title = @"General";
			break;
		case kUISearch_Section:
			title = @"Nearby Search";
			break;
		/*
		case kUIAbout_Section:
			title = @"About & Disclaimer";
			break;
		*/
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
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//cell.accessoryView.
		}
		cell.textLabel.textColor = [UIColor blackColor];
		if (indexPath.row == 0)
		{
			cell.textLabel.text = [(TransitApp *)[UIApplication sharedApplication] currentCity];
		}
		else if (indexPath.row == 1)
		{
			if (cityUpdateAvaiable)
			{
				cell.textLabel.textColor = [UIColor redColor];
				cell.textLabel.text = @"New update available";
			}
			else
				cell.textLabel.text = @"Already up to date";
		}
		else if (indexPath.row == 2)
		{
			if (!offlineDownloaded)
				cell.textLabel.text = @"Offline viewing available";
			else if (offlineUpdateAvailable)
			{
				cell.textLabel.textColor = [UIColor redColor];
				cell.textLabel.text = @"New offline data available";
			}
			else
				cell.textLabel.text = @"Offline data up to date";
		}			
		else if (indexPath.row == 3)
		{
			cell.textLabel.text = @"Information";
		}
		else
		{
			cell.textLabel.text = @"Tags Management";
		}
	}
	else if ( indexPath.section == kUIGeneral_Section )
	{
		if (indexPath.row == 0)
		{
			if (timeCell == nil)
			{
				timeCell = [[CellWithSwitch alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"timeCell"];
				timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
				timeCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				timeCell.label.text = @"24-Hour Time";
				timeCell.switchOn = (currentTimeFormat == TIME_24H);
				[timeCell.userSwitch addTarget:self action:@selector(timeFormatChanged:) forControlEvents:UIControlEventValueChanged];
			}
			cell = timeCell;
		}
		else if (indexPath.row == 1)
		{
			//NSAssert(indexPath.row==0, @"Unhandled row in kUICity_Section");
			cell = [tableView dequeueReusableCellWithIdentifier:@"SettingAboutCell"];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingAboutCell"] autorelease]; 
				cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				cell.textLabel.textAlignment = UITextAlignmentLeft;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				//cell.accessoryView.
			}
			cell.textLabel.textColor = [UIColor blackColor];
			cell.textLabel.text = @"About UniBus";
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
				resultCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				resultCell.label.text = @"Maximum stops";
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
				rangeCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				rangeCell.label.text = @"Search range ";
			}
			cell = rangeCell;
		}
		else if ( indexPath.row == 2 )
		{
			if (unitCell == nil)
			{
				unitCell = [[CellWithSwitch alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"unitCell"];
				//[unitCell.segment insertSegmentWithTitle:@"Km" atIndex:0 animated:NO];
				//[unitCell.segment insertSegmentWithTitle:@"Mi" atIndex:1 animated:NO];				
				//unitCell.segment.selectedSegmentIndex =currentUnit;
				unitCell.selectionStyle = UITableViewCellSelectionStyleNone;
				unitCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
				unitCell.label.text = @"Mile as unit";
				[unitCell.userSwitch addTarget:self action:@selector(unitChanged:) forControlEvents:UIControlEventValueChanged];
				unitCell.switchOn = (currentUnit == UNIT_MI);
			}
			cell = unitCell;
		}
		else
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingViewCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//[cell setSeparatorStyle: UITableViewCellSeparatorStyleNone];
			cell.textLabel.font = [UIFont systemFontOfSize:12];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.text = [NSString stringWithFormat: @"Show no more than %d stops within %.1f %s", numberOfResults, searchRange, UnitName(currentUnit)];
		}
	}
	else
	{
		NSAssert(FALSE, @"Unhandled section");
		/*
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
		*/
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	static int numOfTouches = 1;
	if ((indexPath.section == kUISearch_Section) && (indexPath.row==3))
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
	
	if ((indexPath.section == kUIGeneral_Section) && (indexPath.row == 1))
	{
		AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:nil bundle:nil];
		//aboutVC.delegate = [UIApplication sharedApplication];
		[[self navigationController] pushViewController:aboutVC animated:YES];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
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
	else if (indexPath.row == 3)
	{
		InfoViewController *infoVC = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
		[[self navigationController] pushViewController:infoVC animated:YES];
	}
	else
	{
		TagManagerViewController *tagVC = [[TagManagerViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[[self navigationController] pushViewController:tagVC animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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



