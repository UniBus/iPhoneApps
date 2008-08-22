//
//  MetronomeViewController.h
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MUSDefaultRythm;
extern NSString * const MUSDefaultBPM;

@class BeatPlayer;
@class BeatView;

@interface MetronomeViewController : UIViewController <UIPickerViewDelegate> {
	IBOutlet UISwitch	  *mySwitch;
	IBOutlet BeatView	  *myBeat;
	IBOutlet UIPickerView *myPicker;
	IBOutlet UILabel	  *myTitle;
	
	NSMutableArray *arrayRythm;
	NSMutableArray *arrayTempo;
	
	NSTimer *myTimer;
	
	NSInteger selectedBPM;
	NSInteger selectedRythm;
	NSInteger rythmLower;
	NSInteger rythmUpper;
	NSInteger beatCount;
	
	BeatPlayer *beatPlayer;
}

@property NSInteger selectedBPM;
@property NSInteger selectedRythm;

- (IBAction) switchOnOff:(id)sender;

@end

