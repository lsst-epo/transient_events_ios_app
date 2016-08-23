//
/*
 *  httpFlattening.m
 *  CocoaPOST
 */
#import "httpFlattening.h"
@implementation NSString (httpFlattening)
//InitializePassthrough
//
//Fill a table of BOOLs with YES wherever the corresponding character code is legal for inclusion in a 
//query URL.

static void
InitializePassthrough(BOOL * table)
{
	int      i;
	for (i = '0'; i <= '9'; i++) {
		table[i] = YES;
	}
	for (i = '@'; i <= 'Z'; i++) {
		table[i] = YES;
	}
	for (i = 'a'; i <= 'z'; i++) {
		table[i] = YES;
	}
	table['*'] = YES;
	table['-'] = YES;
	table['.'] = YES;
	table['_'] = YES;
}
//- [NSString escapedForQueryURL]

//Return the target string, encoded in UTF-8, with spaces replaced with +, and with characters outside 
//the set [-@*._0-9A-Za-z] encoded as % and the hexadecimal byte code. This is the standard encoding for
//query parameters in a URL or a  POST query.

- (NSString *) escapedForQueryURL
{
	NSData *                  utfData = [self 
										 dataUsingEncoding: 
										 NSUTF8StringEncoding];
	unsigned char *      source = [utfData bytes];
	unsigned char *      cursor = source;
	unsigned char *      limit = source + [utfData length];
	unsigned char *      startOfRun;
	NSMutableString *   workingString = [NSMutableString
										 stringWithCapacity: 
										 2*[self length]];
	static BOOL            passThrough[256] = { NO };
	if (! passThrough['A']) {
		//   First time through, initialize the pass-through table.
		InitializePassthrough(passThrough);
	}
	startOfRun = source;
	while (YES) {
		//   Ordinarily, do nothing in this loop but advance the cursor pointer.
		if (cursor == limit || ! passThrough[*cursor]) {
			//   Do something special at end-of-data or at a special character:
			NSString *   escape;
			int            passThruLength = cursor - startOfRun;
			//   First, append the accumulated characters that just pass through.
			if (passThruLength > 0) {
				[workingString appendString:
				 [NSString stringWithCString: startOfRun
									  length: passThruLength]];
			}
			//   Then respond to the end of data...
			if (cursor == limit)
				break;
			//   ... by stopping
			//   ... or to a special character...
			if (*cursor == ' ')
				escape = @"+";
			//   ... by replacing with '+'
			else
				escape = [NSString stringWithFormat:
						  @"%%%02x", *cursor];
			//   ... or by %-escaping
			[workingString appendString: escape];
			startOfRun = cursor+1;
		}
		cursor++;
	}
	return workingString;
}
@end
@implementation NSDictionary (httpFlattening)
// - [NSDictionary webFormEncoded]

//Return the key-value pairs in the dictionary, with the keys and values encoded as query parameters, 
//paired by =, and delimited with &. This is the format for a full set of named parameters in a 
//URL-coded query.

- (NSString *) webFormEncoded
{
	NSEnumerator *      keys = [self keyEnumerator];
	NSString *            currKey;
	NSString *            currObject;
	NSMutableString *   retval = [NSMutableString
								  stringWithCapacity: 256];
	BOOL                     started = NO;
	while ((currKey = [keys nextObject]) != nil) {
		//   Chain the key-value pairs, properly escaped, in one string.
		if (started)
			[retval appendString: @"&"];
		else
			started = YES;
		currObject = [[self objectForKey: currKey]
					  escapedForQueryURL];
		currKey = [currKey escapedForQueryURL];
		[retval appendString: [NSString stringWithFormat:
							   @"%@=%@", currKey, currObject]];
	}
	return retval;
}
@end