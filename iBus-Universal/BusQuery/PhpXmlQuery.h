//
//  RouteQuery.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface PhpXmlQuery : NSObject{
	NSString *webServicePrefix;
}

@property (retain) NSString * webServicePrefix;

- (BOOL) queryByURL: (NSURL *) url;

@end
