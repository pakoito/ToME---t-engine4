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
#include "map.h"
#include "physfs.h"

#define FOVRADIUS	100

lua_State *L = NULL;
fov_settings_type fov_settings;
map current_map = NULL;
int px = 1, py = 1;

/**
 * Redraw the screen. Called in a loop to create the output.
 */
void redraw(void) {
	display_clear();

	if (current_map)
	{
		fov_circle(&fov_settings, current_map, NULL, px, py, 20);
		map_display(current_map);
	}

	display_put_char('@', px, py, 0x00, 0xFF, 0x00);
	display_refresh();
}

/**
 * Clean up and exit.
 */
void normal_exit(void) {
	display_exit();
	fov_settings_free(&fov_settings);
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

void map_seen(void *m, int x, int y, int dx, int dy, void *src)
{
	if ((x < 0) || (y < 0) || (x >= ((map)m)->w) || (y >= ((map)m)->h)) return;
	((map)m)->seens[x + y * ((map)m)->w] = TRUE;
	((map)m)->remembers[x + y * ((map)m)->w] = TRUE;
}

bool map_opaque(void *mm, int x, int y)
{
	int i = 1;
	map m = (map)mm;
	bool block = FALSE;

	if (!m) return FALSE;
	if ((x < 0) || (y < 0) || (x >= m->w) || (y >= m->h)) return FALSE;
	grid g = m->grids[x + y * m->w];
	while (g)
	{
		lua_getglobal(L, "__uids");
		lua_pushnumber(L, g->uid);
		lua_gettable(L, -2);
		lua_pushstring(L, "block_sight");
		lua_gettable(L, -2);
		if (lua_isnil(L, 4))
		{
//			printf("block %d:%d => nil\n");
		}
		else if (lua_isboolean(L, 4))
		{
//			printf("block %d:%d [%d] => %d\n", x, y, i, lua_toboolean(L, 4));
			block = TRUE;
		}
		else
		{
//			printf("block %d:%d [%d] => ??? %s\n", x, y, i, lua_tostring(L, 4));
		}
//		printf("lua top %d\n", lua_gettop(L));
		lua_pop(L, 3);

		if (block) return TRUE;

		g = g->next;
		i++;
	}
	return FALSE;
}


extern int luaopen_core(lua_State *L);

static int traceback (lua_State *L) {
#if 0
	if (!lua_isstring(L, 1))  /* 'message' not a string? */
		return 1;  /* keep it intact */
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return 1;
	}
	lua_getfield(L, -1, "traceback");
	if (!lua_isfunction(L, -1)) {
		lua_pop(L, 2);
		return 1;
	}
	lua_pushvalue(L, 1);  /* pass error message */
	lua_pushinteger(L, 2);  /* skip this function and traceback */
	lua_call(L, 2, 1);  /* call debug.traceback */
	return 1;
#endif
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

	TTF_Init();

	fov_settings_init(&fov_settings);
	fov_settings_set_opacity_test_function(&fov_settings, map_opaque);
	fov_settings_set_apply_lighting_function(&fov_settings, map_seen);

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
