//
//  MiscCells.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellWithSwitch : UITableViewCell {
	UISwitch	*userSwitch;
}

@property (assign) UISwitch * userSwitch;
@property (getter=isSwitchOn) BOOL switchOn;

@end
