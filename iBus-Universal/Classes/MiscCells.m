//
//  MiscCells.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "MiscCells.h"


@implementation CellWithSwitch

#define POS_SWITCH_TOP		8
#define POS_SWITCH_LEFT		190

@dynamic switchOn;
@synthesize userSwitch;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame: frame reuseIdentifier:reuseIdentifier];	
	if (!self) return nil;
	
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
