//
//  Upgrade.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

BOOL upgradeNeeded(NSString *currengDb);
BOOL upgradeFavorites(NSString *currentDb, NSString *newDb);
BOOL copyDatabase(NSString *currentDb, NSString *newDb);
BOOL upgrade(NSString *currentDb, NSString *newDb);
void resetCurrentCity(NSString *newDb);
