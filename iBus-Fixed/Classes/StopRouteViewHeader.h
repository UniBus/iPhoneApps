//
//  StopRouteViewHeader.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 05/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TransitIconType {
	kTransitIconTypeTram = 0,
	kTransitIconTypeSubway,
	kTransitIconTypeRail,
	kTransitIconTypeBus,
	kTransitIconTypeFerry,
	kTransitIconTypeCableCar,
	kTransitIconTypeGondola,
	kTransitIconTypeFunicular,	
	kTransitIconTypeStop,
};

@interface StopRouteViewHeader : UIView
{
	UIImageView	*icon;
	UILabel		*labelTitle;
	UILabel		*labelDetail;
}

- (void) setIcon:(int)iconType;
- (void) setTitleInfo:(NSString *)titleInfo;
- (void) setDetailInfo:(NSString *)detailInfo;

@end
