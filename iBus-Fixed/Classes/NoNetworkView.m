//
//  NotNetwork.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 17/12/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "NoNetworkView.h"


@implementation NoNetworkView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 48, 250, 150)];
		imageView.image = [UIImage imageNamed:@"wireless.png"];
		self.backgroundColor = [UIColor blackColor] ;
		
		UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 280, 80)];
		promptLabel.text = @"You need to connect to a network for this operation!";
		promptLabel.textAlignment = UITextAlignmentCenter;
		promptLabel.lineBreakMode = UILineBreakModeWordWrap;
		promptLabel.numberOfLines = 2;
		promptLabel.font = [UIFont systemFontOfSize: 20];
		promptLabel.backgroundColor = [UIColor blackColor];
		promptLabel.textColor = [UIColor grayColor];
		
		[self addSubview:imageView];
		[self addSubview:promptLabel];
		[imageView release];
		[promptLabel release];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
