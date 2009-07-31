//
//  MiscCells.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "MiscCells.h"

@implementation SliderCell
@synthesize slider, label;
- (void) dealloc
{
	[slider release];
	[label release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 120.0, 43.0)];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	//label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	[self.contentView addSubview:label];
	
	slider = [[UISlider alloc] initWithFrame:CGRectMake(SLIDER_LEFT, SLIDER_TOP, SLIDER_WIDTH, SLIDER_HEIGHT)];
	[self.contentView addSubview:slider];
	return self;
}

@end

@implementation SegmentCell
@synthesize segment, label;
- (void) dealloc
{
	[segment release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: CGRectZero reuseIdentifier:reuseIdentifier];	

	label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 120.0, 43.0)];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	//label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	[self.contentView addSubview:label];
		
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
	//webView = [[UIWebView alloc] initWithFrame:CGRectMake(WEBVIEW_LEFT, WEBVIEW_TOP, WEBVIEW_WIDTH, WEBVIEW_HEIGHT)];
	webView = [[UIWebView alloc] initWithFrame:self.bounds];
	webView.userInteractionEnabled = YES;
	webView.multipleTouchEnabled = NO;
	webView.backgroundColor = [UIColor yellowColor];
	[self.contentView addSubview:webView];
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end


@implementation CellWithSwitch

#define POS_SWITCH_TOP		8
#define POS_SWITCH_LEFT		190

@dynamic switchOn;
@synthesize userSwitch, label;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	if (!self) return nil;
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 160.0, 43.0)];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	//label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	[self.contentView addSubview:label];
		
	userSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	CGRect ctrlFrame = userSwitch.frame;
	ctrlFrame.origin.x = POS_SWITCH_LEFT;
	ctrlFrame.origin.y = POS_SWITCH_TOP;
	userSwitch.frame = ctrlFrame;
	
	[self.contentView addSubview:userSwitch];
	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[userSwitch release];
    [super dealloc];
}

- (BOOL) isSwitchOn
{
	return userSwitch.on;
}

- (void) setSwitchOn:(BOOL)on
{
	[userSwitch setOn:on];
}

@end
