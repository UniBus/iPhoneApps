//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "PhpXmlQuery.h"

@implementation PhpXmlQuery

@synthesize webServicePrefix;

- (BOOL) queryByURL: (NSURL *) url
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError) {
		NSLog(@"Error: %@", parseError);
    }
    
    [parser release];

	if (parser)
		return NO;
	return YES;
}

#pragma mark XML Delegate Callback Functions
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[parser abortParsing];
	//NSLog(@"Error: %@", parseError);
	//Errors will be logged in [self queryByURL] function.
	
	[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed!" waitUntilDone:NO];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	return;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	//Sub-class needs to implement this one.
	return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	return;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	return;
}

@end
