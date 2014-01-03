/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Nicolas Casalini "DarkGod"
    darkgod@te4.org
*/
#include "getself.h"

#if defined(SELFEXE_LINUX)
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>

const char *get_self_executable(int argc, char **argv)
{
	static char res[PATH_MAX];
	// On linux systems /proc/self/exe is always a symlink to the real executable, so we jsut resolve it
	realpath("/proc/self/exe", res);
	return res;
}

int get_number_cpus()
{
	return sysconf(_SC_NPROCESSORS_ONLN);
//	return 1;
}

#elif defined(SELFEXE_BSD)
#include <limits.h>
#include <stdlib.h>
const char *get_self_executable(int argc, char **argv)
{
	static char res[PATH_MAX];
	// Like linux, but /proc is not always mounted
	//  return 0 if it's not
	if (realpath("/proc/curproc/file", res)) return NULL;
	return res;
}

#import <sys/sysctl.h>

int get_number_cpus()
{
	int count;
	size_t size=sizeof(count);
	
	if (sysctlbyname("hw.ncpu",&count,&size,NULL,0)) return 1;
	return count;
}

#elif defined(SELFEXE_WINDOWS)
#include <stdlib.h>
#include <windows.h>

const char *get_self_executable(int argc, char **argv)
{
	static TCHAR szEXEPath[MAX_PATH];
	GetModuleFileName(NULL,szEXEPath,MAX_PATH);
	return szEXEPath;
}

int get_number_cpus()
{
	SYSTEM_INFO sysinfo;
	GetSystemInfo(&sysinfo);

	return sysinfo.dwNumberOfProcessors;
}

#elif defined(SELFEXE_MACOSX)
#include <mach-o/dyld.h>
#include <string.h>
#include <unistd.h>

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

#import <sys/sysctl.h>

int get_number_cpus()
{
	int count ;
	size_t size=sizeof(count) ;

	if (sysctlbyname("hw.ncpu",&count,&size,NULL,0)) return 1;
	return count;
}

#else
const char *get_self_executable(int argc, char **argv)
{
	return NULL;
}

int get_number_cpus()
{
	return 1;
}

#endif
