//
//  TagAddingViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 07/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagAddingViewController : UIViewController 
{
	IBOutlet	UITextField	*tagInput;
	IBOutlet	UIButton	*addButton;
}

- (IBAction) tagAdded:(id) sender;

@end
