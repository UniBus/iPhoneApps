//
//  BeatPlayer.h
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

@interface BeatPlayer : NSObject {
	SystemSoundID soundUpBeat;
	SystemSoundID soundDownBeat;
}

- (void) playUpBeat;
- (void) playDownBeat;

@end
