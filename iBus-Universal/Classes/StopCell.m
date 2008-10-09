//
//  StopCell.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopCell.h"
#import "StopsViewController.h"
#import "BusStop.h"

UIImage *mapIconImage = nil;

#define POS_ICON_SIZE		50
#define POS_ICON_LEFT		10
#define POS_ICON_TOP		10
#define POS_TEXT_HEIGHT		20
#define POS_TEXT_WIDTH		200
#define POS_TEXT_LEFT		70
#define POS_TEXT_TOP		10

@implementation StopCell

+ (NSInteger) height
{
	return 70;	
}

//This function is not really useful, since in current implementation,
//    user actually select the whole cell to view the map.
- (IBAction) mapButtonClicked:(id)sender
{
	//theStop.flag = YES <===> this is a fake stop
	if (theStop.flag)
		return;
	
	if (ownerView)
	{
		if ([ownerView isKindOfClass:[StopsViewController class]])
		{
			[(StopsViewController *)ownerView showMapOfAStop:theStop];
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void) dealloc
{
	[stopName release];
	[stopDesc release];
	//[mapButton release];
	[theStop release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	if (!self) return nil;
	
	CGRect ctrlFrame = CGRectMake(POS_TEXT_LEFT, POS_TEXT_TOP, POS_TEXT_WIDTH, POS_TEXT_HEIGHT);
	stopName = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopName.backgroundColor = [UIColor clearColor];
	stopName.opaque = NO;
	stopName.textAlignment = UITextAlignmentLeft;
	stopName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	//stopName.textColor = [UIColor grayColor];
	//stopName.highlightedTextColor = [UIColor blackColor];
	stopName.font = [UIFont systemFontOfSize:12];
	

	ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	UILabel *stopDescLabel = [[[UILabel alloc] initWithFrame:ctrlFrame] autorelease];	
	stopDescLabel.backgroundColor = [UIColor clearColor];
	stopDescLabel.opaque = NO;
	stopDescLabel.lineBreakMode = UILineBreakModeWordWrap;
	stopDescLabel.textAlignment = UITextAlignmentLeft;
	stopDescLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	stopDescLabel.font = [UIFont systemFontOfSize:12];
	stopDescLabel.text = @"Descript:";

	//ctrlFrame.origin.y = ctrlFrame.origin.y + ctrlFrame.size.height;
	ctrlFrame.origin.y -= 5;
	ctrlFrame.origin.x = POS_TEXT_LEFT + 44;
	ctrlFrame.size.height = 2 * POS_TEXT_HEIGHT;
	ctrlFrame.size.width = ctrlFrame.size.width - 44;
	/*
	stopDesc = [[UILabel alloc] initWithFrame:ctrlFrame];	
	stopDesc.backgroundColor = [UIColor clearColor];
	stopDesc.opaque = NO;
	stopDesc.lineBreakMode = UILineBreakModeWordWrap;
	stopDesc.textAlignment = UITextAlignmentLeft;
	stopDesc.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	stopDesc.font = [UIFont systemFontOfSize:12];
	*/
	stopDesc = [[UITextView alloc] initWithFrame:ctrlFrame];	
	stopDesc.backgroundColor = [UIColor clearColor];
	stopDesc.editable = NO;
	stopDesc.opaque = NO;
	stopDesc.userInteractionEnabled = NO;
	stopDesc.multipleTouchEnabled = NO;
	stopDesc.textAlignment = UITextAlignmentLeft;
	stopDesc.font = [UIFont systemFontOfSize:12];
	
	
	ctrlFrame = CGRectMake(POS_ICON_LEFT, POS_TEXT_TOP, POS_ICON_SIZE, POS_ICON_SIZE);
	UIButton *mapButton = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:ctrlFrame];
	if (mapIconImage == nil)
	{
		NSString *iconPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapicon.png"];
		mapIconImage = [[UIImage imageWithContentsOfFile:iconPath] retain];
	}
	[mapButton setBackgroundImage:mapIconImage forState:UIControlStateNormal];
	[mapButton addTarget:self action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	self.opaque = NO;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[self.contentView addSubview:stopDescLabel];
	[self.contentView addSubview:stopName];
	[self.contentView addSubview:stopDesc];
	[self.contentView addSubview:mapButton];
	
	//[stopName release];
	//[stopDesc release];
	//[mapButton release];
	
	return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier owner:(UIViewController *)owner
{
	[self initWithFrame:frame reuseIdentifier:reuseIdentifier];
	ownerView = owner;
	return self;
}

- (BusStop *) stop
{
	return theStop;
}

- (void) setStop:(id) aStop
{
	if (![aStop isKindOfClass:[BusStop class]])
	{
		NSLog(@"Programming Error, should have pass in a BusStop!");
		return;
	}
	
	[theStop autorelease];
	theStop = [aStop retain];
	[stopName setText:[NSString stringWithFormat:@"Stop ID  :%@", theStop.stopId]];
	[stopDesc setText:[NSString stringWithFormat:@"%@", theStop.description]];
}

@end
