//
//  MetronomeAppDelegate.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright @ 2008 Zhenwang Yao. All rights reserved.
//

#import "MetronomeViewController.h"
#import "RootViewController.h"
#import "BeatPlayer.h"
#import "BeatView.h"

NSString * const MUSDefaultRythm = @"UserDefaultRythm";
NSString * const MUSDefaultBPM = @"UserDefaultBPM";
NSString * const MUSDefaultUpbeat = @"UserDefaultUpbeat";
NSString * const MUSDefaultDownbeat = @"UserDefaultDownbeat";
NSString * const MUSDefaultVolume = @"UserDefaultVolume";

@interface MetronomeViewController ()
- (void) initializeArrays;
- (void) getCurrentTempo;
- (NSInteger) findTempoIndexByBPM:(NSInteger) bpm;
@end

#pragma mark Predefined Data for Picker
struct TempoTerm {
	NSString *name;
	NSInteger min;
	NSInteger max;
};

#define COL_RYTHM			0
#define COL_TEMPO			1
#define COL_BPM 			2

#define BPM_MIN				40
#define BPM_MAX				250
#define NUM_OF_TEMPO_TERM	10
#define NUM_OF_RYTHM_TERM	6

int _rythm_name_[] = {
	1, 4, //"1/4"
	2, 4, //"2/4"
	3, 4,
	4, 4,
	3, 8,
	6, 8,
};

char *_tempo_name_[] = {
	"Largo",
	"Lento",
	"Adagio",
	"Andante",
	"Moderato",
	"Allegretto",
	"Allegro",
	"Vivace",
	"Presto",
	"Prestissimo",
};

int _tempo_range_[] = {
	40,  59,
	60,  69,
	70,  79,
	80,  107,
	108, 127,
	128, 147,
	148, 169,
	170, 189,
	190, 209,
	210, 250,
};

const int globalNumberOfSounds = 12;

NSString *beatSounds[] =
{
	@"ding",
	@"dong",
	//@"daa",
	@"tradit1",
	@"tradit2",
	@"tamborine",
	@"clap",
	@"snap",
	@"stick",
	@"hihat",
	@"bassdrum",
	@"deepkick",
	@"heavykick",
};

NSString *beatSoundNames[] =
{
	@"Classic sound 1",
	@"Classic sound 2",
	//@"Classic sound 3",
	@"Cowbell 1",
	@"Cowbell 2",
	@"Tamborine",
	@"Hand clap",
	@"Finger Snap",
	@"Drum Stick",
	@"High Hat",
	@"Bass Drum",
	@"Deep Kick",
	@"Heavy Kick",
};

@implementation MetronomeViewController

@synthesize selectedBPM, selectedRythm;
@synthesize rootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void) loadUserConfigurationAndBeatPlayer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	selectedBPM = [defaults integerForKey:MUSDefaultBPM];
	selectedRythm = [defaults integerForKey:MUSDefaultRythm];
	downbeatSound = [defaults integerForKey:MUSDefaultDownbeat];
	upbeatSound = [defaults integerForKey:MUSDefaultUpbeat];
	rythmUpper = _rythm_name_[2*selectedRythm];
	rythmLower = _rythm_name_[2*selectedRythm + 1];
	
	NSAssert((downbeatSound>=0) && (downbeatSound<globalNumberOfSounds), @"Downbeat audio index error!");
	NSAssert((upbeatSound>=0) && (upbeatSound<globalNumberOfSounds), @"Upbeat audio index error!");

	if (beatPlayer == nil)
		beatPlayer = [[BeatPlayer alloc] init];
	
	float currentVolume = [defaults floatForKey:MUSDefaultVolume];
	beatPlayer.volume = currentVolume;
	[beatPlayer setBeatSoundDown:beatSounds[downbeatSound] andUp:beatSounds[upbeatSound]];
	
	myBeat.totalBeat = rythmUpper;	
	[myBeat setUpbeatImage:[UIImage imageNamed:@"upbeat.png"]];
	[myBeat setDownbeatImage:[UIImage imageNamed:@"downbeat.png"]];
	
	[myPicker selectRow:(selectedBPM-BPM_MIN) inComponent:COL_BPM animated:NO];
	[myPicker selectRow:selectedRythm inComponent:COL_RYTHM animated:NO];
	[myPicker selectRow:[self findTempoIndexByBPM:selectedBPM] inComponent:COL_TEMPO animated:NO];		
}

// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	powerOn = NO;
	[super viewDidLoad];
	[self initializeArrays];
	//[mySwitch2 setImage:[UIImage imageNamed:@"poweroff.png"] forState:UIControlStateNormal];
	//[mySwitch2 setImage:[UIImage imageNamed:@"poweroff.png"] forState:UIControlStateSelected];
	myTitle.font = [UIFont fontWithName:@"Zapfino" size:20.0];
	[self loadUserConfigurationAndBeatPlayer];
	[self getCurrentTempo];
}

// Implement loadView if you want to create a view hierarchy programmatically
- (void)viewDidAppear:(BOOL)animated
{
	[self loadUserConfigurationAndBeatPlayer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[myTimer release];
	[arrayRythm release];
	[arrayTempo release];
	[beatPlayer release];
	[super dealloc];
}

#pragma mark UISwitch Functions

- (void)beatingTimeOut:(NSTimer *)aTimer
{
	beatCount = beatCount % rythmUpper;

	myBeat.currentBeat = beatCount;
	if (beatCount)
		[beatPlayer playUpBeat];
	else
		[beatPlayer playDownBeat];
	
	beatCount++;
}

- (void) reset
{
	if (myTimer)
	{
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;
		beatCount = 0;	
		myBeat.playing = NO;
	}
	
	if ( powerOn )
	{
		NSTimeInterval interval = 60./selectedBPM;
		myBeat.playing = YES;
		myTimer = [[NSTimer scheduledTimerWithTimeInterval:interval 
													target:self 
												  selector:@selector(beatingTimeOut:)
												  userInfo:nil 
												   repeats:YES] retain];
		[myTimer fire];
	}		
}

- (IBAction) switchOnOff:(id)sender
{
	powerOn = !powerOn;

	if (powerOn)
	{
		[mySwitch setImage:[UIImage imageNamed:@"poweron.png"] forState: UIControlStateNormal];
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
	else
	{
		[mySwitch setImage:[UIImage imageNamed:@"poweroff.png"] forState: UIControlStateNormal];
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	
	[self reset];
}

- (IBAction) settingClicked: (id)sender
{
	if (powerOn)
		[self switchOnOff:mySwitch];
	
	[rootViewController toggleView:self];
}

- (IBAction) volumeChanged:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		beatPlayer.volume = volumeSlider.value;	
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setFloat:volumeSlider.value forKey:MUSDefaultVolume];
	}
}

- (IBAction) volumeClicked:(id)sender
{	
	//UISlider *volumeSlider = [[UISlider alloc] initWithFrame: CGRectMake(196, 90, 160, 40)];(10, 300, 300, 20)
	if (volumeSlider == nil)
	{
		[myVolume setImage:[UIImage imageNamed:@"volumeon.png"] forState: UIControlStateNormal];
		volumeSlider = [[UISlider alloc] initWithFrame: CGRectMake(198, 85, 140, 40)]; 
		[volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventTouchUpInside];
		volumeSlider.maximumValue = 1.5;
		volumeSlider.minimumValue = 0;
		volumeSlider.value = beatPlayer.volume;
		CGAffineTransform rotation = CGAffineTransformMakeRotation(-1.57079633);
		[volumeSlider setTransform:rotation];	
		[self.view addSubview:volumeSlider];
	}
	else
	{
		[myVolume setImage:[UIImage imageNamed:@"volumeoff.png"] forState: UIControlStateNormal];
		[volumeSlider removeFromSuperview];
		[volumeSlider release];
		volumeSlider = nil;
	}
	
}

#pragma mark UIPickerView Functions
- (NSInteger) getSelectedBPM
{
	return [myPicker selectedRowInComponent:COL_BPM] + BPM_MIN;
}

- (NSInteger) getSelectedRythm
{
	return [myPicker selectedRowInComponent:COL_RYTHM];	
}

- (void) setSelectedBPM:(NSInteger) bmp
{
	[myPicker selectRow: (bmp-BPM_MIN) inComponent:COL_BPM animated:NO];
}

- (void) setSelectedRythm:(NSInteger)rym
{
	[myPicker selectRow: rym inComponent:COL_RYTHM animated:NO];
}

- (void) getCurrentTempo
{
	selectedBPM = [myPicker selectedRowInComponent:COL_BPM] + BPM_MIN;
	selectedRythm = [myPicker selectedRowInComponent:COL_RYTHM];
	rythmUpper = _rythm_name_[2*selectedRythm];
	rythmLower = _rythm_name_[2*selectedRythm + 1];
	myBeat.totalBeat = rythmUpper;
}

- (void) initializeArrays
{
	arrayTempo = [[NSMutableArray alloc] init];
	arrayRythm = [[NSMutableArray alloc] init];	
	
	for (int i=0; i< NUM_OF_RYTHM_TERM; i++)
	{
		[arrayRythm addObject:[[NSString stringWithFormat:@"%d/%d", _rythm_name_[2*i], _rythm_name_[2*i+1]] retain]];
	}
	
	struct TempoTerm tempo;
	NSData *data;
	
	for (int i=0; i< NUM_OF_TEMPO_TERM; i++)
	{
		tempo.name = [[NSString stringWithCString:_tempo_name_[i]] retain];
		tempo.min = _tempo_range_[2*i];
		tempo.max = _tempo_range_[2*i+1];
		
		data = [[NSData dataWithBytes:&tempo length:sizeof(tempo)] retain];
		[arrayTempo addObject:data];
	}
	
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == COL_TEMPO)
		return [arrayTempo count];
	else if (component == COL_BPM) 
		return (BPM_MAX - BPM_MIN + 1);
	else
		return [arrayRythm count];
}

// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component == COL_TEMPO)
		return 150;
	else if (component == COL_BPM)
		return 80;
	else
		return 80;
}

// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse. 
// If you return back a different object, the old one will be released. the view will be centered in the row rect  
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == COL_TEMPO)
	{
		NSData *data = [arrayTempo objectAtIndex:row];
		struct TempoTerm *tempo = (struct TempoTerm *) [data bytes]; 
		return tempo->name;
	}
	else if (component == COL_BPM) {
		return [NSString stringWithFormat:@"%d", row+BPM_MIN];
	}
	else
	{
		return [arrayRythm objectAtIndex:row];
	}

}

- (NSInteger) findTempoIndexByBPM:(NSInteger) bpm
{
	for (int i= 0; i<NUM_OF_TEMPO_TERM; i++)
	{
		if ( (bpm >= _tempo_range_[2*i]) && (bpm <= _tempo_range_[2*i+1]) )
			return i;
	}
	
	return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == COL_TEMPO)
	{
		NSData *data = [arrayTempo objectAtIndex:row];
		struct TempoTerm *tempo = (struct TempoTerm *) [data bytes];
		NSInteger tempoMax = tempo->max;
		NSInteger tempoMin = tempo->min;
		selectedBPM = [pickerView selectedRowInComponent:COL_BPM] + BPM_MIN;
		
		if ( (selectedBPM >= tempoMin) && (selectedBPM <= tempoMax) )
			return;
		
		[pickerView selectRow:(tempoMin-BPM_MIN) inComponent:COL_BPM animated:YES];
		selectedBPM = tempoMin;
	}
	else if (component == COL_BPM)
	{
		selectedBPM = [pickerView selectedRowInComponent:COL_BPM] + BPM_MIN;
		NSInteger index = [self findTempoIndexByBPM:selectedBPM];
		[pickerView selectRow:index inComponent:COL_TEMPO animated:YES];
	}
	else
	{
		selectedRythm = [pickerView selectedRowInComponent:COL_RYTHM];
		rythmUpper = _rythm_name_[2*selectedRythm];
		rythmLower = _rythm_name_[2*selectedRythm + 1];
		myBeat.totalBeat = rythmUpper;
	}
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:selectedBPM forKey:MUSDefaultBPM];
	[defaults setInteger:selectedRythm forKey:MUSDefaultRythm];
	
	[self reset];
}

@end
