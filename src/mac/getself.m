#import <Cocoa/Cocoa.h>

const char *get_self_executable(int argc, char **argv)
{
	static char *cstr = 0;

	if(!cstr)
	{
		const char *utf8 = [[[NSBundle mainBundle] resourcePath] UTF8String];
		cstr = malloc(strlen(utf8) + 1);
		strcpy(cstr, utf8);
	}

	return cstr;
}
