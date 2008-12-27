//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
/*! \class PhpXmlQuery
 *
 * \brief XML query base class. 
 *
 * This class is designed to be inherited, as there is no actual parsing of XML data.
 * To sub class from PhpXmlQuery, the only thing you need to do to have XML handing capability 
 *   is to override the delegate function.
 *      - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName ....
 *
 */

#import <SystemConfiguration/SCNetworkReachability.h>
#import "PhpXmlQuery.h"
#import "TransitApp.h"

@implementation PhpXmlQuery

@synthesize webServicePrefix;

/*!
 * \brief Check if the network is available.
 *
 * \return 
 *		- YES, if available.
 *		- NO, otherwise.
 * \todo The [PhpXmlQuery available] should be moved to TransitApp.
 */
- (BOOL) available
{
	NSURL *targetingUrl = [NSURL URLWithString:webServicePrefix];
	SCNetworkReachabilityFlags        flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [[targetingUrl host] UTF8String]);
    BOOL gotFlags = SCNetworkReachabilityGetFlags(reachability, &flags);    
	CFRelease(reachability);
	if (!gotFlags) 
        return NO;
	
    if ( !(flags & kSCNetworkReachabilityFlagsReachable))
		return NO;
	
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) 
		return NO;
    
	return YES;
    //return flags & kSCNetworkReachabilityFlagsReachable;
}

/*!
 * \brief Initiate a XML query by requesting a URL
 *
 * \param[in] url The given URL.
 * \return 
 *		- YES, if the url has been successfully requested.
 *		- NO, otherwise.
 *
 * \note After the url has been request, other asynchronous functions will be called.
 *		which is defined as XML delegate callback functions.
 */
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
