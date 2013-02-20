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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "physfs.h"
#include "core.h"

#if defined(SELFEXE_LINUX)
#define _te4_export
#elif defined(SELFEXE_WINDOWS)
#define _te4_export __declspec(dllexport)
#elif defined(SELFEXE_MACOSX)
#define _te4_export
#else
#define _te4_export
#endif

// Load the shared lib containing the core and calls te4main inside it, passing control to that core
_te4_export char* find_te4_core(core_boot_type *core_def, const char *selfexe)
{
	/******************************************************************
	 ** Find a core file
	 ******************************************************************/
	PHYSFS_init(selfexe);

	if (selfexe && PHYSFS_mount(selfexe, "/", 1)) {} else
	{
		printf("NO SELFEXE: bootstrapping from CWD\n");
		PHYSFS_mount("bootstrap", "/bootstrap", 1);
	}

	lua_State *L = lua_open();
	luaL_openlibs(L);
	luaopen_physfs(L);

	// Tell the boostrapping code the selfexe path
	if (selfexe) lua_pushstring(L, selfexe);
	else lua_pushnil(L);
	lua_setglobal(L, "__SELFEXE");

	// Will be useful
#ifdef __APPLE__
	lua_pushboolean(L, 1);
	lua_setglobal(L, "__APPLE__");
#endif

	// Run bootstrapping
	if (!luaL_loadfile(L, "/bootstrap/boot.lua")) { lua_call(L, 0, 0); }
	// Could not load bootstrap! Try to mount the engine from working directory as last resort
	else
	{
		printf("Could not find bootstrapping code! Aborting!\n");
		exit(1);
	}

	// Get the core
	lua_getglobal(L, "get_core");
	if (core_def->coretype) lua_pushstring(L, core_def->coretype); else lua_pushnil(L);
	lua_pushnumber(L, core_def->corenum);
	lua_call(L, 2, 1);
	char *core = strdup((char*)lua_tostring(L, -1));
	printf("Runner booting core: %s\n", core);

	lua_close(L);
	PHYSFS_deinit();

	if (!core) {
		printf("No core found!");
		exit(1);
	}

	return core;
}
