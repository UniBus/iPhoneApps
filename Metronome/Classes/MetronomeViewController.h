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
extern NSString * const MUSDefaultDownbeat;
extern NSString * const MUSDefaultUpbeat;
extern NSString * const MUSDefaultVolume;

@class BeatPlayer;
@class BeatView;
@class RootViewController;

@interface MetronomeViewController : UIViewController <UIPickerViewDelegate> {
	IBOutlet UIButton	  *mySwitch;
	IBOutlet UIButton	  *myVolume;
	IBOutlet BeatView	  *myBeat;
	IBOutlet UIPickerView *myPicker;
	IBOutlet UILabel	  *myTitle;
	IBOutlet UISegmentedControl *mySegmentCtrl;
	RootViewController			*rootViewController;
	
	NSMutableArray *arrayRythm;
	NSMutableArray *arrayTempo;
	
	NSTimer *myTimer;
	
	NSInteger selectedBPM;
	NSInteger selectedRythm;
	NSInteger rythmLower;
	NSInteger rythmUpper;
	NSInteger beatCount;
	NSInteger upbeatSound;
	NSInteger downbeatSound;
	BOOL	  powerOn;
	
	BeatPlayer *beatPlayer;
	UISlider*volumeSlider;
}

@property NSInteger selectedBPM;
@property NSInteger selectedRythm;
@property (nonatomic, assign)  RootViewController			*rootViewController;

- (IBAction) switchOnOff:(id)sender;
- (IBAction) settingClicked: (id)sender;
- (IBAction) volumeClicked:(id)sender;

@end

