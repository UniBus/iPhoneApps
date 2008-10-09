//
//  SettingsViewController.h
//  Settings
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

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
	//IBOutlet UIWebView       *aboutWebCell;
	//IBOutlet UISlider        *rangeSlider;
	//IBOutlet UISlider        *recentSlider;
	
	//float searchRange;
	//int   numberOfRecentStops;
}

//@property float searchRange;
//@property int numberOfRecentStops;
- (IBAction) rangeChanged:(id) sender;
- (IBAction) resultNumChanged:(id) sender;

- (IBAction) rangeChangedFinial:(id) sender;
- (IBAction) resultNumChangedFinal:(id) sender;

@end

