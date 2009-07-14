//
//  MiscCells.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REGULARCELL_HEIGHT	44
#define REGULARCELL_WIDTH	314

#define SLIDERCELL_HEIGHT	44
#define SLIDER_WIDTH		150
#define SLIDER_HEIGHT		22
#define SLIDER_LEFT			130
#define SLIDER_TOP			10

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

@interface SliderCell : UITableViewCell
{
	UILabel  *label;
	UISlider *slider;
}
@property(assign) UISlider *slider;
@property(assign) UILabel *label;
@end

@interface SegmentCell : UITableViewCell
{
	UILabel  *label;
	UISegmentedControl *segment;
}
@property(assign) UILabel *label;
@property(assign) UISegmentedControl *segment;
@end

@interface WebViewCell : UITableViewCell
{
	UIWebView *webView;
}
@property(assign) UIWebView *webView;
@end

@interface CellWithSwitch : UITableViewCell {
	UILabel  *label;
	UISwitch	*userSwitch;
}
@property(assign) UILabel *label;
@property (assign) UISwitch * userSwitch;
@property (getter=isSwitchOn) BOOL switchOn;

@end
