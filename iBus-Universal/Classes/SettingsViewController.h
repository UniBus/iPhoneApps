//
//  SettingsViewController.h
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright Zhenwang Yao. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"

@interface SearchRangeCell : UITableViewCell
{
}
@end

@interface SliderCell : UITableViewCell
{
	UISlider *slider;
}
@property(assign) UISlider *slider;
@end

@interface SegmentCell : UITableViewCell
{
	UISegmentedControl *segment;
}
@property(assign) UISegmentedControl *segment;
@end

@interface WebViewCell : UITableViewCell
{
	UIWebView *webView;
}
@property(assign) UIWebView *webView;
@end

@interface SettingsViewController : UIViewController <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView	 *settingView;
	IBOutlet SliderCell		 *rangeCell;
	IBOutlet SliderCell		 *resultCell;
	IBOutlet WebViewCell	 *aboutCell;
	IBOutlet SegmentCell	 *unitCell;
	IBOutlet SegmentCell     *timeCell;
	//IBOutlet UIWebView       *aboutWebCell;
	//IBOutlet UISlider        *rangeSlider;
	//IBOutlet UISlider        *recentSlider;
	
	//float searchRange;
	//int   numberOfRecentStops;
	DownloadManager			*downloader;
}

//@property float searchRange;
//@property int numberOfRecentStops;
- (IBAction) rangeChanged:(id) sender;
- (IBAction) resultNumChanged:(id) sender;

- (IBAction) rangeChangedFinial:(id) sender;
- (IBAction) resultNumChangedFinal:(id) sender;

- (IBAction) unitChanged:(id) sender;
- (IBAction) timeFormatChanged:(id) sender;

@end

