//
//  StopRouteViewHeader.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 05/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import "StopRouteViewHeader.h"

#define HEADER_TOTAL_WIDTH		320
#define HEADER_TOTAL_HEIGHT		90

#define HEADER_ICON_LEFT		0   //230
#define HEADER_ICON_TOP			5
#define HEADER_ICON_WIDTH		80
#define HEADER_ICON_HEIGHT		80

#define HEADER_TITLE_LEFT		85
#define HEADER_TITLE_TOP		0
#define HEADER_TITLE_WIDTH		230
#define HEADER_TITLE_HEIGHT		45

#define HEADER_DETAIL_LEFT		85
#define HEADER_DETAIL_TOP		45
#define HEADER_DETAIL_WIDTH		230
#define HEADER_DETAIL_HEIGHT	45

@implementation StopRouteViewHeader

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: CGRectMake(0, 0, HEADER_TOTAL_WIDTH, HEADER_TOTAL_HEIGHT)];	
	if (!self) return nil;
	
	CGRect ctrlFrame = CGRectMake(HEADER_ICON_LEFT, HEADER_ICON_TOP, HEADER_ICON_WIDTH, HEADER_ICON_HEIGHT);
	icon = [[UIImageView alloc] initWithFrame:ctrlFrame];	
	
	ctrlFrame.origin.x = HEADER_TITLE_LEFT;
	ctrlFrame.origin.y = HEADER_TITLE_TOP;
	ctrlFrame.size.height = HEADER_TITLE_HEIGHT;
	ctrlFrame.size.width = HEADER_TITLE_WIDTH;
	labelTitle = [[UITextView alloc] initWithFrame:ctrlFrame];
	labelTitle.textColor = [UIColor blackColor];
	labelTitle.backgroundColor = [UIColor clearColor];
	labelTitle.font = [UIFont boldSystemFontOfSize:14];
	labelTitle.textAlignment = UITextAlignmentLeft;
	labelTitle.userInteractionEnabled = NO;
	labelTitle.multipleTouchEnabled = NO;
	labelTitle.text = @"";
	
	ctrlFrame.origin.x = HEADER_DETAIL_LEFT;
	ctrlFrame.origin.y = HEADER_DETAIL_TOP;
	ctrlFrame.size.height = HEADER_DETAIL_HEIGHT;
	ctrlFrame.size.width = HEADER_DETAIL_WIDTH;
	labelDetail = [[UITextView alloc] initWithFrame:ctrlFrame];
	labelDetail.textColor = [UIColor blackColor];
	labelDetail.backgroundColor = [UIColor clearColor];
	labelDetail.font = [UIFont systemFontOfSize:14];
	labelDetail.textAlignment = UITextAlignmentLeft;
	labelDetail.userInteractionEnabled = NO;
	labelDetail.multipleTouchEnabled = NO;
	labelDetail.text = @"";
	
	[self addSubview:icon];
	[self addSubview:labelTitle];
	[self addSubview:labelDetail];
	
	return self;
}

- (void) setIcon:(int)iconType
{
	//icon.text = action;
	switch (iconType) {
		case kTransitIconTypeBus:
			icon.image = [UIImage imageNamed:@"typebusicon.png"];
			break;
			
		case kTransitIconTypeFerry:
			icon.image = [UIImage imageNamed:@"typeferryicon.png"];
			break;
			
		case kTransitIconTypeSubway:
		case kTransitIconTypeRail:
			icon.image = [UIImage imageNamed:@"typetrainicon.png"];
			break;
			
		case kTransitIconTypeTram:
		case kTransitIconTypeCableCar:
		case kTransitIconTypeGondola:
		case kTransitIconTypeFunicular:			
			icon.image = [UIImage imageNamed:@"typetramicon.png"];
			break;
			
		case kTransitIconTypeStop:			
			icon.image = [UIImage imageNamed:@"typestopicon.png"];
			break;
			
		default:
			icon.image = [UIImage imageNamed:@"typebusicon.png"];
			break;
	}
}

- (void) setDetailInfo:(NSString *)detailInfo
{
	labelDetail.text = [NSString stringWithFormat:@"%@", detailInfo];
}

- (void) setTitleInfo:(NSString *)titleInfo
{
	labelTitle.text = [NSString stringWithFormat:@"%@", titleInfo];
}

- (void) dealloc
{
	[labelTitle release];
	[labelDetail release];
	[icon release];
	[super dealloc];
}

@end
