/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010 Nicolas Casalini

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
