//
//  BeatView.h
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeatView : UIView {
	NSInteger totalBeat;
	NSInteger currentBeat;
	NSMutableArray *leds;
	UIImage *upbeatImage;
	UIImage *downbeatImage;
	BOOL playing;
}

@property NSInteger totalBeat;
@property NSInteger currentBeat;
@property BOOL playing;

- (void) setUpbeatImage:(UIImage *) up;
- (void) setDownbeatImage:(UIImage *) down;

@end
