/*
 * Copyright (C) 2006, Greg McIntyre
 * All rights reserved. See the file named COPYING in the distribution
 * for more details.
 */

#include "display.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "fov/fov.h"

#include "types.h"
#include "script.h"
#include "physfs.h"

lua_State *L = NULL;
int current_map = LUA_NOREF;
int px = 1, py = 1;

void display_utime()
{
	struct timeval tv;
	struct timezone tz;
	struct tm *tm;
	gettimeofday(&tv, &tz);
	tm=localtime(&tv.tv_sec);
	printf(" %d:%02d:%02d %d \n", tm->tm_hour, tm->tm_min, tm->tm_sec, tv.tv_usec);
}

/**
 * Redraw the screen. Called in a loop to create the output.
 */
void redraw(void) {
	display_clear();

//	display_utime();

	if (current_map != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_map);
		lua_pushstring(L, "display");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_map);
		lua_call(L, 1, 0);
	}
//	display_utime();

	display_put_char('@', px, py, 0x00, 0xFF, 0x00);
	display_refresh();
}

/**
 * Clean up and exit.
 */
void normal_exit(void) {
	display_exit();
	exit(0);
}


/**
 * Handle a keypress. Callback used by display_event_loop.
 */
void keypressed(int key, int shift) {
	switch (key) {
	case KEY_UP:
	case KEY_KP8:
		py--;
		break;
	case KEY_KP2:
	case KEY_DOWN:
		py++;
		break;
	case KEY_KP4:
	case KEY_LEFT:
		px--;
		break;
	case KEY_KP6:
	case KEY_RIGHT:
		px++;
		break;
	case KEY_KP7:
		break;
	case KEY_KP9:
		break;
	case KEY_KP1:
		break;
	case KEY_KP3:
		break;
	case KEY_q:
	case KEY_ESCAPE:
		normal_exit();
		break;
	default:
		break;
	}
	redraw();
}

extern int luaopen_core(lua_State *L);

static int traceback (lua_State *L) {
	printf("Lua Error: %s\n", lua_tostring(L, 1));
}


static int docall (lua_State *L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

/**
 * Program entry point.
 */
int main (int argc, char *argv[])
{
	PHYSFS_init(argv[0]);
	PHYSFS_mount("game/", "/", 1);
	PHYSFS_mount("game/modules/tome", "/tome", 1);

	TTF_Init();

	L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);

	lua_newtable(L);
	lua_setglobal(L, "__uids");

	luaL_loadfile(L, "/engine/init.lua");
	docall(L, 0, LUA_MULTRET);

	display_init();
	redraw();
	display_event_loop(keypressed);
	normal_exit();
	return 0;
}
