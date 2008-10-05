//
//  SettingViewController.m
//  Metronome
//
//  Created by Zhenwang Yao on 25/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "RootViewController.h"
#import "SoundViewController.h"

#define kSectionDownbeat	0
#define kSectionUpbeat		1

extern NSString * const MUSDefaultDownbeat;
extern NSString * const MUSDefaultUpbeat;
extern const int globalNumberOfSounds;

extern NSString *beatSounds[];
extern NSString *beatSoundNames[];

@implementation SettingViewController

@synthesize rootViewController;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		//
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = @"Setting";
    UIBarButtonItem *doneItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleView:)];    
    [self.navigationItem setRightBarButtonItem:doneItemButton animated:NO];
    [doneItemButton release];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	selectedDownBeat = [defaults integerForKey:MUSDefaultDownbeat];
	selectedUpBeat = [defaults integerForKey:MUSDefaultUpbeat];	
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
    [super dealloc];
}

- (IBAction)toggleView:(id)sender {
    [rootViewController toggleView:self];
}

- (void) currentSoundChanged:(NSInteger)newSound
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (currentSoundSection == kSectionUpbeat)
	{
		selectedUpBeat = newSound;
		[defaults setInteger:selectedUpBeat forKey:MUSDefaultUpbeat];	
	}
	else if  (currentSoundSection == kSectionDownbeat)
	{
		selectedDownBeat = newSound;
		[defaults setInteger:selectedDownBeat forKey:MUSDefaultDownbeat];			
	}
	else
		NSAssert(NO, @"Invalid currentSoundSection");
	
	[myTableView reloadData];
}

#pragma mark TableView Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	currentSoundSection = indexPath.section;
	
	SoundViewController *soundVC = [[SoundViewController alloc] initWithNibName:nil bundle:nil];
	soundVC.ownerViewCtrl = self;
	if (indexPath.section == kSectionUpbeat)
		soundVC.selectedSound = selectedUpBeat;
	else if (indexPath.section == kSectionDownbeat)
		soundVC.selectedSound = selectedDownBeat;
	else
		NSAssert(NO, @"Invalid indexPath");
	
	NSAssert(self.navigationController != nil, @"Couldn't find navigation controller.");
	[[self navigationController] pushViewController:soundVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case kSectionDownbeat:
		case kSectionUpbeat:
			return 1;
		default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kSectionDownbeat:
			return @"Downbeat Sound";
		case kSectionUpbeat:
			return @"Upbeat Sound";
		default:
			break;
	}
	return @"";
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
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSString *displayText;
	switch (indexPath.section) {
		case kSectionUpbeat:
			displayText = beatSoundNames[selectedUpBeat];
			break;
		case kSectionDownbeat:
			displayText = beatSoundNames[selectedDownBeat];
			break;
		default:
			break;
	}
	
	cell.text = displayText;
	
	return cell;
}

@end
