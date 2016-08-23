/*
 *  httpFlattening.h
 *  CocoaPOST
 */
#include <Foundation/Foundation.h>

//NSString

@interface NSString (httpFlattening)
- (NSString *) escapedForQueryURL;
@end

//NSDictionary

@interface NSDictionary (httpFlattening)
- (NSString *) webFormEncoded;
@end