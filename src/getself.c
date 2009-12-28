#include "getself.h"

#if defined(SELFEXE_LINUX)
#include <limits.h>
#include <stdlib.h>

const char *get_self_executable(int argc, char **argv)
{
	char res[PATH_MAX];
	// On linux systems /proc/self/exe is always a symlink to the real executable, so we jsut resolve it
	realpath("/proc/self/exe", res);
	return res;
}

#elif defined(SELFEXE_WINDOWS)
#include <windows.h>

const char *get_self_executable(int argc, char **argv)
{
	TCHAR szEXEPath[MAX_PATH];
	GetModuleFileName(NULL,szEXEPath,MAX_PATH);
	return szEXEPath;
}

#elif defined(SELFEXE_MACOSX)
#include <mach-o/dyld.h>
#include <string.h>

const char *get_self_executable(int argc, char **argv)
{
	size_t sz = 0;
	char *buf;
	char *sl;

	_NSGetExecutablePath(NULL, &sz);
	buf = (char*) malloc(++sz);
	_NSGetExecutablePath(buf, &sz);

	sl = strrchr(buf, '/');
	*(sl + 1) = '\0';
	return buf;
}

#else
const char *get_self_executable(int argc, char **argv)
{
	return NULL;
}

#endif
