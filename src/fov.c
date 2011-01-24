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
#include "display.h"
#include "fov/fov.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "script.h"
#include "display.h"
#include "physfs.h"
#include "physfsrwops.h"
#include "SFMT.h"
#include "mzip.h"
#include "main.h"
#include "useshader.h"
#include <math.h>
#include <time.h>

/******************************************************************
 ******************************************************************
 *                              FOV                               *
 ******************************************************************
 ******************************************************************/
struct lua_fovcache
{
	bool *cache;
	int w, h;
};

struct lua_fov
{
	lua_State *L;
	fov_settings_type fov_settings;
	int w, h;
	int apply_ref;
	int opaque_ref;
	int cache_ref;
	struct lua_fovcache *cache;
};

static void map_seen(void *m, int x, int y, int dx, int dy, int radius, void *src)
{
	struct lua_fov *fov = (struct lua_fov *)m;
	radius--;
	if (x < 0 || y < 0 || x >= fov->w || y >= fov->h) return;
	if (dx*dx + dy*dy <= radius*radius + 1)
	{
		// circular view - can be changed if you like
		lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->apply_ref);
		if (fov->cache) lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->cache_ref);
		else lua_pushnil(fov->L);
		lua_pushnumber(fov->L, x);
		lua_pushnumber(fov->L, y);
		lua_pushnumber(fov->L, dx);
		lua_pushnumber(fov->L, dy);
		lua_pushnumber(fov->L, dx*dx + dy*dy);
		lua_call(fov->L, 6, 0);
	}
}

static bool map_opaque(void *m, int x, int y)
{
	struct lua_fov *fov = (struct lua_fov *)m;
	if (x < 0 || y < 0 || x >= fov->w || y >= fov->h) return TRUE;

	if (fov->cache)
	{
		return fov->cache->cache[x + y * fov->cache->w];
	}
	else
	{
		lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->opaque_ref);
		if (fov->cache) lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->cache_ref);
		else lua_pushnil(fov->L);
		lua_pushnumber(fov->L, x);
		lua_pushnumber(fov->L, y);
		lua_call(fov->L, 3, 1);
		bool res = lua_toboolean(fov->L, -1);
		lua_pop(fov->L, 1);
		return res;
	}
}

static int lua_fov_calc_circle(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	int radius = luaL_checknumber(L, 5);
	struct lua_fov fov;
	if (lua_isuserdata(L, 8))
	{
		fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 8);
		fov.cache_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		lua_pop(L, 1);
		fov.cache_ref = LUA_NOREF;
		fov.cache = NULL;
	}
	fov.L = L;
	fov.apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.w = w;
	fov.h = h;

	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_seen);
	fov_circle(&(fov.fov_settings), &fov, NULL, x, y, radius+1);
	map_seen(&fov, x, y, 0, 0, radius, NULL);
	fov_settings_free(&(fov.fov_settings));

	luaL_unref(L, LUA_REGISTRYINDEX, fov.apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.opaque_ref);
	if (fov.cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov.cache_ref);

	return 0;
}

static int lua_fov_calc_beam(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	int radius = luaL_checknumber(L, 5);
	int direction = luaL_checknumber(L, 6);
	float angle = luaL_checknumber(L, 7);
	struct lua_fov fov;
	if (lua_isuserdata(L, 10))
	{
		fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 10);
		fov.cache_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		lua_pop(L, 1);
		fov.cache_ref = LUA_NOREF;
		fov.cache = NULL;
	}
	fov.L = L;
	fov.apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.cache = NULL;
	fov.w = w;
	fov.h = h;
	int dir = 0;

	switch (direction)
	{
	case 1: dir = FOV_SOUTHWEST; break;
	case 2: dir = FOV_SOUTH; break;
	case 3: dir = FOV_SOUTHEAST; break;
	case 4: dir = FOV_WEST; break;
	case 6: dir = FOV_EAST; break;
	case 7: dir = FOV_NORTHWEST; break;
	case 8: dir = FOV_NORTH; break;
	case 9: dir = FOV_NORTHEAST; break;
	}

	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_seen);
	fov_beam(&(fov.fov_settings), &fov, NULL, x, y, radius+1, dir, angle);
	map_seen(&fov, x, y, 0, 0, radius, NULL);
	fov_settings_free(&(fov.fov_settings));

	luaL_unref(L, LUA_REGISTRYINDEX, fov.apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.opaque_ref);
	if (fov.cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov.cache_ref);

	return 0;
}

static int lua_distance(lua_State *L)
{
	double x1 = luaL_checknumber(L, 1);
	double y1 = luaL_checknumber(L, 2);
	double x2 = luaL_checknumber(L, 3);
	double y2 = luaL_checknumber(L, 4);

	lua_pushnumber(L, sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)));
	return 1;
}

static int lua_new_fovcache(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int i, j;

	struct lua_fovcache *cache = (struct lua_fovcache*)lua_newuserdata(L, sizeof(struct lua_fovcache));
	auxiliar_setclass(L, "fov{cache}", -1);
	cache->w = x;
	cache->h = y;
	cache->cache = calloc(x * y, sizeof(bool));
	for (i = 0; i < x; i++)
		for (j = 0; j < y; j++)
			cache->cache[i + j * x] = FALSE;

	return 1;
}

static int lua_fovcache_set(lua_State *L)
{
	struct lua_fovcache *cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool opaque = lua_toboolean(L, 4);

	if (x < 0 || y < 0 || x >= cache->w || y >= cache->h) return 0;
	cache->cache[x + y * cache->w] = opaque;

	return 0;
}

static int lua_fovcache_get(lua_State *L)
{
	struct lua_fovcache *cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	lua_pushboolean(L, cache->cache[x + y * cache->w]);
	return 1;
}


/****************************************************************
 ** Default FOV
 ****************************************************************/
#define STACK_X 1
#define STACK_Y 2
#define STACK_RAD 3
#define STACK_BLOCK 4
#define STACK_FOV 5
#define STACK_ACTOR 6
#define STACK_DIST 7
#define STACK_MAP 8
#define STACK_MAP_W 9
#define STACK_MAP_H 10
#define STACK_ENTITY 11
#define STACK_DMAP 12
#define STACK_TURN 13
#define STACK_SELF 14
#define STACK_APPLY 15

typedef struct {
	int dist_idx;
	int w, h;
	int entity;
	float turn;
	bool do_dmap;
	bool do_apply;
} default_fov;

static void map_default_seen(void *m, int x, int y, int dx, int dy, int radius, void *src)
{
	default_fov *def = (default_fov*)src;
	struct lua_fov *fov = (struct lua_fov *)m;
	radius--;
	float sqdist = dx*dx + dy*dy;
	float dist = sqrtf(sqdist);
	if (sqdist <= radius*radius + 1)
	{
		// Distance Map
		if (def->do_dmap)
		{
			lua_pushnumber(fov->L, x + y * def->w);
			lua_pushnumber(fov->L, def->turn + radius - dist);
			lua_rawset(fov->L, STACK_DMAP);
		}

		// Apply
		if (def->do_apply)
		{
			lua_pushvalue(fov->L, STACK_APPLY);
			lua_pushnumber(fov->L, x);
			lua_pushnumber(fov->L, y);
			lua_pushnumber(fov->L, dx);
			lua_pushnumber(fov->L, dy);
			lua_pushnumber(fov->L, sqdist);
			lua_call(fov->L, 5, 0);
		}

		// Get entity
		lua_pushnumber(fov->L, x + y * def->w);
		lua_rawget(fov->L, STACK_MAP);
		if (!lua_istable(fov->L, -1)) { lua_pop(fov->L, 1); return; }
		lua_pushnumber(fov->L, def->entity);
		lua_rawget(fov->L, -2);
		if (!lua_istable(fov->L, -1)) { lua_pop(fov->L, 2); return; }

		// Check if dead
		lua_pushstring(fov->L, "dead");
		lua_gettable(fov->L, -2);
		if (lua_toboolean(fov->L, -1)) { lua_pop(fov->L, 3); return; }
		lua_pop(fov->L, 1);

		// Set sqdist in the actor for faster sorting
		lua_pushstring(fov->L, "__sqdist");
		lua_pushnumber(fov->L, sqdist);
		lua_rawset(fov->L, -3);

		// Make a table to hold data
		lua_newtable(fov->L);
		lua_pushstring(fov->L, "x");
		lua_pushnumber(fov->L, x);
		lua_rawset(fov->L, -3);
		lua_pushstring(fov->L, "y");
		lua_pushnumber(fov->L, y);
		lua_rawset(fov->L, -3);
		lua_pushstring(fov->L, "dx");
		lua_pushnumber(fov->L, dx);
		lua_rawset(fov->L, -3);
		lua_pushstring(fov->L, "dy");
		lua_pushnumber(fov->L, dy);
		lua_rawset(fov->L, -3);
		lua_pushstring(fov->L, "sqdist");
		lua_pushnumber(fov->L, sqdist);
		lua_rawset(fov->L, -3);

		// Set the actor table
		lua_pushvalue(fov->L, -2);
		lua_pushvalue(fov->L, -2);
		lua_rawset(fov->L, STACK_ACTOR);

		// Set the dist table
		def->dist_idx++;
		lua_pushnumber(fov->L, def->dist_idx);
		lua_pushvalue(fov->L, -3);
		lua_rawset(fov->L, STACK_DIST);

		// Call seen_by, if possible
		lua_pushstring(fov->L, "updateFOV");
		lua_gettable(fov->L, -3);
		lua_pushvalue(fov->L, -3);
		lua_pushvalue(fov->L, STACK_SELF);
		lua_pushnumber(fov->L, sqdist);
		lua_call(fov->L, 3, 0);

		// Call seen_by, if possible
		lua_pushstring(fov->L, "seen_by");
		lua_gettable(fov->L, -3);
		if (lua_isfunction(fov->L, -1))
		{
			lua_pushvalue(fov->L, -3);
			lua_pushvalue(fov->L, STACK_SELF);
			lua_call(fov->L, 2, 0);
		}
		else lua_pop(fov->L, 1);

		lua_pop(fov->L, 3);
	}
}

static bool map_default_opaque(void *m, int x, int y)
{
	struct lua_fov *fov = (struct lua_fov *)m;

	if (x < 0 || y < 0 || x >= fov->cache->w || y >= fov->cache->h) return TRUE;
	return fov->cache->cache[x + y * fov->cache->w];
}

static int lua_fov_calc_default_fov(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int radius = luaL_checknumber(L, 3);
	// 4 Block
	struct lua_fov fov;
	fov.L = L;
	fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 5);
	// 6, 7 = actor, actor_dist
	// 8 map
	// 9 map.w
	// 10 map.h
	// 11 Map.ENTITY
	// 12 DMAP
	// 13 game.turn
	// 14 self
	// 15 apply

	default_fov def;
	def.w = lua_tonumber(L, STACK_MAP_W);
	def.h = lua_tonumber(L, STACK_MAP_H);
	def.turn = lua_tonumber(L, STACK_TURN);
	def.entity = lua_tonumber(L, STACK_ENTITY);
	def.do_dmap = lua_istable(L, STACK_DMAP);
	def.do_apply = lua_isfunction(L, STACK_APPLY);
	def.dist_idx = 0;
	fov.w = def.w;
	fov.h = def.h;

//	printf("<TOP %d\n", lua_gettop(L));

	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_default_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_default_seen);
	fov_circle(&(fov.fov_settings), &fov, &def, x, y, radius+1);
	map_default_seen(&fov, x, y, 0, 0, radius, &def);
	fov_settings_free(&(fov.fov_settings));

//	printf(">TOP %d\n", lua_gettop(L));

	return 0;
}


static const struct luaL_reg fovlib[] =
{
	{"newCache", lua_new_fovcache},
	{"distance", lua_distance},
	{"calc_default_fov", lua_fov_calc_default_fov},
	{"calc_circle", lua_fov_calc_circle},
	{"calc_beam", lua_fov_calc_beam},
	{NULL, NULL},
};

static const struct luaL_reg fovcache_reg[] =
{
	{"set", lua_fovcache_set},
	{"get", lua_fovcache_get},
	{NULL, NULL},
};

int luaopen_fov(lua_State *L)
{
	auxiliar_newclass(L, "fov{cache}", fovcache_reg);
	luaL_openlib(L, "core.fov", fovlib, 0);
	lua_pop(L, 1);
	return 1;
}
