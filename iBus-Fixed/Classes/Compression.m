//
//  Compression.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/09/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import <zlib.h>

#define CHUNK 16384	//16K

BOOL UnzipFile(NSString *sourcePath, NSString *destPath)
{
	gzFile file = gzopen([sourcePath UTF8String], "rb");
	FILE *dest = fopen([destPath UTF8String], "w");
	if ( (file == NULL) || (dest == NULL) )
		return NO;

	unsigned char buffer[CHUNK];
	int uncompressedLength;
	while (uncompressedLength = gzread(file, buffer, CHUNK) ) {
		// got data out of our file
		if(fwrite(buffer, 1, uncompressedLength, dest) != uncompressedLength || ferror(dest)) {
			NSLog(@"Error unzipping data");
			return NO;
		}
	}

	fclose(dest);
	gzclose(file);
	return YES;
}


