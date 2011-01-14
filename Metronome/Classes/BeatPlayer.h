//
//  BeatPlayer.h
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

@class AudioPlayer;
@interface BeatPlayer : NSObject {
	AudioPlayer *upbeatPlayer;
	AudioPlayer *downbeatPlayer;
	
	NSURL *downbeatURL;
	NSURL *upbeatURL;
	
	float volume;
}

- (void) setBeatSoundDown:(NSString *)downName andUp:(NSString *)upName;
- (void) playUpBeat;
- (void) playDownBeat;

@property float volume;

@end
