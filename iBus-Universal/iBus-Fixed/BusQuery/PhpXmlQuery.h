//
//  RouteQuery.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

@interface PhpXmlQuery : NSObject{
	NSString *webServicePrefix;
}

@property (retain) NSString * webServicePrefix;

- (BOOL) available;
- (BOOL) queryByURL: (NSURL *) url;

@end
