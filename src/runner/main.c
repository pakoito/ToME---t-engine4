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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef SELFEXE_WINDOWS
#include <windows.h>
#else
#include <dlfcn.h>
#endif

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "physfs.h"
#include "core.h"
#include "getself.h"

// Update core to run
void define_core(core_boot_type *core_def, const char *coretype, int id, const char *reboot_engine, const char *reboot_engine_version, const char *reboot_module, const char *reboot_name, int reboot_new, const char *reboot_einfo)
{
	if (core_def->coretype) free(core_def->coretype);
	if (core_def->reboot_engine) free(core_def->reboot_engine);
	if (core_def->reboot_engine_version) free(core_def->reboot_engine_version);
	if (core_def->reboot_module) free(core_def->reboot_module);
	if (core_def->reboot_name) free(core_def->reboot_name);
	if (core_def->reboot_einfo) free(core_def->reboot_einfo);

	core_def->corenum = id;
	core_def->coretype = coretype ? strdup(coretype) : NULL;
	core_def->reboot_engine = reboot_engine ? strdup(reboot_engine) : NULL;
	core_def->reboot_engine_version = reboot_engine_version ? strdup(reboot_engine_version) : NULL;
	core_def->reboot_module = reboot_module ? strdup(reboot_module) : NULL;
	core_def->reboot_name = reboot_name ? strdup(reboot_name) : NULL;
	core_def->reboot_einfo = reboot_einfo ? strdup(reboot_einfo) : NULL;
	core_def->reboot_new = reboot_new;
}

// Load the shared lib containing the core and calls te4main inside it, passing control to that core
void run_core(core_boot_type *core_def, int argc, char **argv)
{
	int (*te4main)(int, char**, core_boot_type*);

	/******************************************************************
	 ** Find a core file
	 ******************************************************************/
	PHYSFS_init(argv[0]);

	const char *selfexe = get_self_executable(argc, argv);
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
	lua_pushboolean(L, TRUE);
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

	lua_close(L);
	PHYSFS_deinit();

	if (!core) {
		printf("No core found!");
		exit(1);
	}

	/***********************************************************************
	 ** Windows DLL loading code
	 ***********************************************************************/
#ifdef SELFEXE_WINDOWS

	HINSTANCE handle = LoadLibrary(core);
	if (!handle) {
		fprintf(stderr, "Error loading core %d (%s): %d\n", core_def->corenum, core, GetLastError());
		exit(EXIT_FAILURE);
	}

	*(void **) (&te4main) = GetProcAddress(handle, "te4main");
	if (te4main == NULL)  {
		fprintf(stderr, "Error binding to core %d (%s): %d\n", core_def->corenum, core, GetLastError());
		exit(EXIT_FAILURE);
	}

	// Run the core
	te4main(argc, argv, core_def);

	FreeLibrary(handle);

	/***********************************************************************
	 ** POSIX so loading code
	 ***********************************************************************/
#else
	char *error;

	void *handle = dlopen(core, RTLD_LAZY);
	if (!handle) {
		fprintf(stderr, "Error loading core %d (%s): %s\n", core_def->corenum, core, dlerror());
		exit(EXIT_FAILURE);
	}

	dlerror();    /* Clear any existing error */

	/* Writing: cosine = (double (*)(double)) dlsym(handle, "cos");
	 would seem more natural, but the C99 standard leaves
	 casting from "void *" to a function pointer undefined.
	 The assignment used below is the POSIX.1-2003 (Technical
	 Corrigendum 1) workaround; see the Rationale for the
	 POSIX specification of dlsym(). */

	*(void **) (&te4main) = dlsym(handle, "te4main");

	if ((error = dlerror()) != NULL)  {
		fprintf(stderr, "Error binding to core %d (%s): %s\n", core_def->corenum, core, error);
		exit(EXIT_FAILURE);
	}

	// Run the core
	te4main(argc, argv, core_def);

	dlclose(handle);
#endif

	free(core);
}

// Let some platforms use a different entry point
#ifdef USE_TENGINE_MAIN
#ifdef main
#undef main
#endif
#define main tengine_main
#endif

int main(int argc, char **argv)
{
	core_boot_type *core_def = calloc(1, sizeof(core_boot_type));

	core_def->define = &define_core;
	core_def->define(core_def, "te4core", -1, NULL, NULL, NULL, NULL, 0, NULL);

	// Parse arguments
	int i;
	for (i = 1; i < argc; i++)
	{
		char *arg = argv[i];
		if (!strncmp(arg, "-M", 2)) core_def->reboot_module = strdup(arg+2);
		if (!strncmp(arg, "-u", 2)) core_def->reboot_name = strdup(arg+2);
		if (!strncmp(arg, "-E", 2)) core_def->reboot_einfo = strdup(arg+2);
		if (!strncmp(arg, "-n", 2)) core_def->reboot_new = 1;
		if (!strncmp(arg, "--flush-stdout", 14)) setvbuf(stdout, (char *) NULL, _IOLBF, 0);;
	}

	// Run the requested cores until we want no more
	while (core_def->corenum) run_core(core_def, argc, argv);

	exit(EXIT_SUCCESS);
}
