//
//  DatePickViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatePickViewController : UIViewController 
{
	id	target;
	SEL callback;
	IBOutlet UIDatePicker *picker;
	IBOutlet UITableView  *quickPickView;
	NSDate *date;
}

@property (assign) id target;
@property SEL callback;
@property (assign) NSDate *date;

- (IBAction) datePicked:(id) sender;
- (NSDate *) date;
- (void) setDate: (NSDate *)theDate;

@end
