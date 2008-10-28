#import <Foundation/Foundation.h>
#import "BusStop.h"
#import "BusRoute.h"
#import "Favorite.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	printf("\nGoogle Transit Feed data convertor.\n");
	printf("Covert GTFS data from csv format to sqlite format.\n");
	printf("Copyright @ Zhenwang.Yao 2008\n");
	
	BOOL parameterError = NO;
	if (argc >= 2)
	{	
		NSString *action = [NSString stringWithUTF8String:argv[1]];		
		if ([action compare:@"-addroute" options:NSCaseInsensitiveSearch]==NSOrderedSame)
		{
			if (argc == 4)
			{				
				printf("\n Converting routes %s to %s\n\n", argv[2], argv[3]);
				NSString *srcFile = [NSString stringWithUTF8String:argv[2]];
				NSString *sqlFile = [NSString stringWithUTF8String:argv[3]];
	
				convertRoutesToSQLite(srcFile, sqlFile);
			}
			else
				parameterError = YES;
		}		
		else if ([action compare:@"-addstop" options:NSCaseInsensitiveSearch]==NSOrderedSame)
		{		
			if (argc == 4)
			{				
				printf("\n Converting stops %s to %s\n\n", argv[2], argv[3]);
				NSString *srcFile = [NSString stringWithUTF8String:argv[2]];
				NSString *sqlFile = [NSString stringWithUTF8String:argv[3]];
			
				convertStopsToSQLite(srcFile, sqlFile);
			}
			else 
				parameterError = YES;
		}		
		else if ([action compare:@"-addfavorite" options:NSCaseInsensitiveSearch]==NSOrderedSame)
		{		
			if (argc == 3)
			{
				printf("\n Add favorite table into %s\n\n", argv[2]);			
				NSString *sqlFile = [NSString stringWithUTF8String:argv[2]];
				addFavoriteTable(sqlFile);
			}
			else 
				parameterError = YES;
		}
		else
			parameterError = YES;
	}

	if (parameterError)
	{
		printf("Usage:\n");
		printf("\t DataProcess -[action] [src.csv db.sqlite]\n\n");
	}
	
	
    [pool drain];
    return 0;
}
