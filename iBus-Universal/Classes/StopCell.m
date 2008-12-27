//
//  StopCell.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "StopCell.h"
#import "StopsViewController.h"
#import "BusStop.h"

UIImage *mapIconImage = nil;

#define POS_ICON_SIZE		50
#define POS_ICON_LEFT		240
#define POS_ICON_TOP		10
#define POS_TEXT_HEIGHT		50
#define POS_TEXT_WIDTH		220
#define POS_TEXT_LEFT		10
#define POS_TEXT_TOP		5

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
	//[stopName release];
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
	stopDesc = [[UITextView alloc] initWithFrame:ctrlFrame];	
	stopDesc.backgroundColor = [UIColor clearColor];
	stopDesc.editable = NO;
	stopDesc.scrollEnabled = NO;
	stopDesc.opaque = NO;
	stopDesc.userInteractionEnabled = NO;
	stopDesc.multipleTouchEnabled = NO;
	stopDesc.textAlignment = UITextAlignmentLeft;
	stopDesc.font = [UIFont systemFontOfSize:12];
	
	ctrlFrame = CGRectMake(POS_ICON_LEFT, POS_ICON_TOP, POS_ICON_SIZE, POS_ICON_SIZE);
	UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mapButton.frame = ctrlFrame;
	if (mapIconImage == nil)
	{
		NSString *iconPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapicon.png"];
		mapIconImage = [[UIImage imageWithContentsOfFile:iconPath] retain];
	}
	[mapButton setBackgroundImage:mapIconImage forState:UIControlStateNormal];
	[mapButton addTarget:self action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	self.opaque = NO;
	//self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[self.contentView addSubview:stopDesc];
	[self.contentView addSubview:mapButton];
	
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

//Historical notes:
//	- Why "UITextView" instead of "UITextField"
//    UITextField only support one line of text!!
//  - Why text in UITextView dispear!!
//	  [stopDesc scrollRangeToVisible:NSMakeRange(0, 1)]; need to be called
//
- (void) setStop:(id) aStop
{
	if (![aStop isKindOfClass:[BusStop class]])
	{
		NSLog(@"Programming Error, should have pass in a BusStop!");
		return;
	}
	
	[theStop autorelease];
	theStop = [aStop retain];
	stopDesc.text = [NSString stringWithFormat:@"%@", theStop.description];
	[stopDesc scrollRangeToVisible:NSMakeRange(0, 1)];
	//NSLog(@"Set stop text for stop_id=%@: %@", theStop.stopId, theStop.description);
}

@end


#define POS_NOTE_HEIGHT		20
#define POS_NOTE_WIDTH		296
#define POS_NOTE_LEFT		0
#define POS_NOTE_TOP		0
#define NOTE_CELL_HEIGHT	50

@implementation CellWithNote
+ (NSInteger) height
{
	return NOTE_CELL_HEIGHT;
}

- (void) dealloc
{
	[noteLabel release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	if (!self) return nil;

	CGRect ctrlFrame = CGRectMake(POS_NOTE_LEFT, POS_NOTE_TOP, POS_NOTE_WIDTH, POS_NOTE_HEIGHT);
	noteLabel = [[UILabel alloc] initWithFrame:ctrlFrame];	
	noteLabel.backgroundColor = [UIColor clearColor];
	noteLabel.opaque = NO;
	noteLabel.textAlignment = UITextAlignmentRight;
	noteLabel.textColor = [UIColor redColor];
	noteLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	noteLabel.font = [UIFont systemFontOfSize:11];
	
	[self.contentView addSubview:noteLabel];
	
	return self;
}

- (void) setNote: (NSString *)note
{
	noteLabel.text = note;
}

@end

