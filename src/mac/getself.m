#import <Cocoa/Cocoa.h>

const char *get_self_executable(int argc, char **argv)
{
	static char *cstr = 0;

	if(!cstr)
	{
		NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
		resourcePath = [NSString stringWithFormat:@"%@/", resourcePath];
		const char *utf8 = [resourcePath UTF8String];

		cstr = malloc(strlen(utf8) + 1);
		strcpy(cstr, utf8);
	}

	return cstr;
}
