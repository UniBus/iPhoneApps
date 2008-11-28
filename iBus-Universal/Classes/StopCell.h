//
//  StopCell.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusStop;

@interface StopCell : UITableViewCell
{
	UITextView   *stopDesc;
	BusStop      *theStop;
	UIViewController *ownerView;
}

+ (NSInteger) height;
- (BusStop *) stop;
- (void) setStop:(id) aStop;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier owner:(UIViewController *)owner;
- (IBAction) mapButtonClicked:(id)sender;

@end


@interface CellWithNote : UITableViewCell
{
	UILabel      *noteLabel;
}

+ (NSInteger) height;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setNote: (NSString *)note;

@end


