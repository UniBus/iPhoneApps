//
//  SoundViewController.m
//  Metronome
//
//  Created by Zhenwang Yao on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "SoundViewController.h"
#import "SettingViewController.h"

extern const int globalNumberOfSounds;

extern NSString *beatSounds[];
extern NSString *beatSoundNames[];

@implementation SoundViewController

@synthesize selectedSound, ownerViewCtrl;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	UITableView *soundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 480-45) style:UITableViewStyleGrouped]; 
	[soundTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	soundTableView.dataSource = self;
	soundTableView.delegate = self;
	self.view = soundTableView; 
	[soundTableView release];
	self.navigationItem.title = @"Beat Sounds";
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

- (void) playSound:(NSNumber *) index
{
	NSAutoreleasePool *autoreleasepool= [[NSAutoreleasePool alloc] init];
	SystemSoundID soundTest;
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	NSURL *beatURL = [[NSURL alloc] initFileURLWithPath:[mainBundle pathForResource:beatSounds[[index intValue]] ofType:@"wav"] isDirectory:NO];
	if ( AudioServicesCreateSystemSoundID((CFURLRef)beatURL, &soundTest) != kAudioServicesNoError )
	{
		NSLog(@"Couldn't open downbeat audio file");
	}
	[beatURL release];
	
	AudioServicesPlaySystemSound(soundTest);
	[NSThread sleepForTimeInterval:1];
	
	AudioServicesDisposeSystemSoundID(soundTest);	
	[autoreleasepool release];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	selectedSound = indexPath.row;

	//UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:lastSelected];
	//selectedCell.accessoryType = UITableViewCellAccessoryNone;
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	[self performSelectorInBackground:@selector(playSound:) withObject:[NSNumber numberWithInt:indexPath.row]];
	[tableView reloadData];
	
	[ownerViewCtrl currentSoundChanged:selectedSound];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return globalNumberOfSounds;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Available Sounds";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellSettingCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		//cell.textAlignment = UITextAlignmentLeft;
		//cell.font = [UIFont systemFontOfSize:12];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.indentationLevel = 1;
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSString *displayText;
	if (indexPath.row == selectedSound)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	displayText = beatSoundNames[indexPath.row];
	cell.text = displayText;
	
	return cell;
}

@end
