#import <Foundation/Foundation.h>
#import "StopQuery.h"
#import "StopQuery-CSV.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	printf("\nGoogle Transit Feed data convertor.\n");
	printf("Covert stops.txt from csv format to sqlite format.\n");
	printf("Copyright @ Zhenwang.Yao 2008\n");
	
	if (argc != 3)
	{
		printf("Usage:\n");
		printf("\t DataProcess [stops.csv stops.sqlite]\n\n");
	}
	else
	{	
		printf("\n Converting %s to %sn", argv[1], argv[2]);
		NSString *srcFile = [NSString stringWithUTF8String:argv[1]];
		NSString *sqlFile = [NSString stringWithUTF8String:argv[2]];
	
		StopQuery_CSV *stopQuery = [StopQuery_CSV initWithFile:srcFile];
		if (stopQuery)
		{
			[stopQuery saveToSQLiteDatabase:sqlFile];
		}
		[stopQuery release];
	}
	
    [pool drain];
    return 0;
}
