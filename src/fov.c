/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini

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

#define SQRT_3       1.73205080756887729353
#define INV_SQRT_3   0.577350269189625764509
#define SQRT_3_2     0.866025403784438646764
#define INV_SQRT_3_2 1.15470053837925152902

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

typedef struct
{
	struct lua_fov fov;
	fov_line_data line;
} lua_fov_line;

typedef struct
{
	struct lua_fov fov;
	hex_fov_line_data line;
} lua_hex_fov_line;

static int lua_fov_set_permissiveness(lua_State *L)
{
	float val = luaL_checknumber(L, 1);
	if (val < 0.0f) val = 0.0f;
	else if (val > 0.5f) val = 0.5f;
	val = 0.5f - val;
	fov_set_permissiveness(val);
	return 0;
}

static int lua_fov_set_actor_vision_size(lua_State *L)
{
	float val = luaL_checknumber(L, 1);
	if (val < 0.0f) val = 0.0f;
	else if (val > 0.5f) val = 0.5f;
	fov_set_actor_vision_size(val);
	return 0;
}

static int lua_fov_set_vision_shape(lua_State *L)
{
	fov_shape_type val = luaL_checknumber(L, 1);
	fov_set_vision_shape(val);
	return 0;
}

static int lua_fov_set_algorithm(lua_State *L)
{
	fov_algo_type val = luaL_checknumber(L, 1);
	fov_set_algorithm(val);
	return 0;
}

// this is kinda ugly, so I may come back to it and make it purty
static int lua_fov_get_distance(lua_State *L, double x1, double y1, double x2, double y2, bool ret_float)
{
	fov_shape_type shape = fov_get_vision_shape();
	if (shape == FOV_SHAPE_HEX) {
		int dx1 = (x1 < 0.0f) ? -(int)(0.5f - x1) : (int)(0.5f + x1);
		int dy1 = (y1 < 0.0f) ? -(int)(0.5f - y1) : (int)(0.5f + y1);
		int dx2 = (x2 < 0.0f) ? -(int)(0.5f - x2) : (int)(0.5f + x2);
		int dy2 = (y2 < 0.0f) ? -(int)(0.5f - y2) : (int)(0.5f + y2);

		// there may be a better way to do this
		int dist = abs(dx2 - dx1);
		int dy = dy2 - dy1;
		int ady = abs(dy);
		ady -= (dist + (((dx1 & 1) + (dy < 0)) & 1))/2;
		if (ady > 0) {
			dist += ady;
		}
		lua_pushnumber(L, dist);
		return 1;
	} else {
		double dx = fabs(x2 - x1);
		double dy = fabs(y2 - y1);
		double dist;

		switch(shape) {
		case FOV_SHAPE_CIRCLE_ROUND :
			dist = sqrt(dx*dx + dy*dy) + 0.5;
			break;
		case FOV_SHAPE_CIRCLE_FLOOR :
			dist = sqrt(dx*dx + dy*dy);
			break;
		case FOV_SHAPE_CIRCLE_CEIL :
			if (ret_float)
				dist = sqrt(dx*dx + dy*dy);
			else
				dist = ceil(sqrt(dx*dx + dy*dy));
			break;
		case FOV_SHAPE_CIRCLE_PLUS1 :
			dist = sqrt(dx*dx + dy*dy);
			if (dist > 0.5) dist = dist + 1 - 1.0/dist;
			break;
		case FOV_SHAPE_OCTAGON :
			dist = (dx > dy) ? (dx + 0.5*dy) : (dy + 0.5*dx);
			break;
		case FOV_SHAPE_DIAMOND :
			dist = dx + dy;
			break;
		case FOV_SHAPE_SQUARE :
			dist = (dx > dy) ? dx : dy;
			break;
		default :
			dist = sqrt(dx*dx + dy*dy) + 0.5;
			break;
		}

		if (ret_float)
			lua_pushnumber(L, dist);
		else
			lua_pushnumber(L, (int)dist);
		return 1;
	}
}

static void map_seen(void *m, int x, int y, int dx, int dy, int radius, void *src)
{
	struct lua_fov *fov = (struct lua_fov *)m;
	if (x < 0 || y < 0 || x >= fov->w || y >= fov->h) return;
	lua_fov_get_distance(L, (float)(x-dx), (float)(y-dy), (float)x, (float)y, false);
	int sqdist = luaL_checknumber(L, -1);
	sqdist = sqdist*sqdist;

	// circular view - can be changed if you like
	lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->apply_ref);
	if (fov->cache) lua_rawgeti(fov->L, LUA_REGISTRYINDEX, fov->cache_ref);
	else lua_pushnil(fov->L);
	lua_pushnumber(fov->L, x);
	lua_pushnumber(fov->L, y);
	lua_pushnumber(fov->L, dx);
	lua_pushnumber(fov->L, dy);
	lua_pushnumber(fov->L, sqdist);
	lua_call(fov->L, 6, 0);
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

	fov_circle(&(fov.fov_settings), &fov, NULL, x, y, radius);
	map_seen(&fov, x, y, 0, 0, radius, NULL);

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

	fov_beam(&(fov.fov_settings), &fov, NULL, x, y, radius, dir, angle);
	map_seen(&fov, x, y, 0, 0, radius, NULL);

	luaL_unref(L, LUA_REGISTRYINDEX, fov.apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.opaque_ref);
	if (fov.cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov.cache_ref);

	return 0;
}

static int lua_fov_calc_beam_any_angle(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	int radius = luaL_checknumber(L, 5);
	float beam_angle = luaL_checknumber(L, 6);
	int sx = luaL_checknumber(L, 7);
	int sy = luaL_checknumber(L, 8);
	float dx = luaL_checknumber(L, 9);
	float dy = luaL_checknumber(L, 10);
	struct lua_fov fov;
	if (lua_isuserdata(L, 13))
	{
		fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 12);
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

	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_seen);

	fov_beam_any_angle(&(fov.fov_settings), &fov, NULL, x, y, radius, sx, sy, dx, dy, beam_angle);
	map_seen(&fov, x, y, 0, 0, radius, NULL);

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
	bool ret_float = lua_toboolean(L, 5);

	lua_fov_get_distance(L, x1, y1, x2, y2, ret_float);
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
	if (x < 0 || y < 0 || x >= fov->w || y >= fov->h) return;

	lua_fov_get_distance(L, (float)(x-dx), (float)(y-dy), (float)x, (float)y, false);
	int dist = luaL_checknumber(L, -1);
	int sqdist = dist*dist;

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

	fov_circle(&(fov.fov_settings), &fov, &def, x, y, radius);
	map_default_seen(&fov, x, y, 0, 0, radius, &def);

//	printf(">TOP %d\n", lua_gettop(L));

	return 0;
}

/****************************************************************
 ** FOV line
 ****************************************************************/

static int lua_fov_line_init(lua_State *L)
{
	int source_x = luaL_checknumber(L, 1);
	int source_y = luaL_checknumber(L, 2);
	int dest_x = luaL_checknumber(L, 3);
	int dest_y = luaL_checknumber(L, 4);
	int w = luaL_checknumber(L, 5);
	int h = luaL_checknumber(L, 6);
	bool start_at_end = lua_toboolean(L, 7);
	int opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	lua_fov_line *lua_line = (lua_fov_line*)lua_newuserdata(L, sizeof(lua_fov_line));
	fov_line_data *line = &(lua_line->line);
	struct lua_fov *fov = &(lua_line->fov);
	fov->cache_ref = LUA_NOREF;
	fov->cache = NULL;
	fov->L = L;
	fov->opaque_ref = opaque_ref;
	fov->w = w;
	fov->h = h;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);

	fov_create_los_line(&(fov->fov_settings), fov, NULL, line, source_x, source_y, dest_x, dest_y, start_at_end);
	luaL_unref(L, LUA_REGISTRYINDEX, fov->opaque_ref);

	auxiliar_setclass(L, "core{fovline}", -1);
	return 1;
}

static int lua_fov_line_step(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
		lua_getfield(L, 1, "block");
		lua_line->fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_line->fov.L = L;
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
		lua_line->fov.opaque_ref = LUA_NOREF;
	}

	fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);
	if (!dont_stop_at_end && line->dest_t == line->t || line->dest_t == 0) return 0;

	// If there is a tie, then choose the tile closer to a cardinal direction.
	// If we weren't careful, this would be the most likely place to have floating precision
	// errors that would be inconsistent with FoV.  Therefore, let's be extra cautious!
	float fx = (float)line->t * line->step_x + line->eps_x;
	float fy = (float)line->t * line->step_y + line->eps_y;
	float x0 = line->start_x;
	float y0 = line->start_y;
	int x_prev = (fx < 0.0f) ? -(int)(x0 - fx) : (int)(x0 + fx);
	int y_prev = (fy < 0.0f) ? -(int)(y0 - fy) : (int)(y0 + fy);
	fx += line->step_x;
	fy += line->step_y;
	int x = (fx < 0.0f) ? -(int)(x0 - fx) : (int)(x0 + fx);
	int y = (fy < 0.0f) ? -(int)(y0 - fy) : (int)(y0 + fy);

	// check if line is blocked by a corner of an adjacent tile
	bool is_corner_blocked = false;
	int corner_x, corner_y;
	if (x != x_prev && y != y_prev && lua_line->fov.opaque_ref != LUA_NOREF) {
		fx = (float)line->t * line->step_x;
		fy = (float)line->t * line->step_y;
		float dx = (line->step_x < 0.0f) ? ((float)x - fx + x0) / line->step_x : ((float)x - fx - x0) / line->step_x;
		float dy = (line->step_y < 0.0f) ? ((float)y - fy + y0) / line->step_y : ((float)y - fy - y0) / line->step_y;

		if (dx > dy) {
			corner_x = line->source_x + x_prev;
			corner_y = line->source_y + y;
			// XXX Note to future self: this checks the value of the line to the edge of the tile.  It needs to
			// extend past the edge of the tile by an amount "0.5 - permissiveness".  Smallest and largest values
			// of permissiveness will still work fine, but intermediate values will allow some trick shots.
			fx += line->eps_x;
			float val = (line->step_x < 0.0f) ? fx - (float)x_prev + dy*line->step_x : -fx + (float)x_prev - dy*line->step_x;
			if (val + 0.5f + lua_line->fov.fov_settings.permissiveness - x0 > GRID_EPSILON &&
				lua_line->fov.fov_settings.opaque(&(lua_line->fov), corner_x, corner_y)
			) {
				is_corner_blocked = true;
			}
		} else {
			corner_x = line->source_x + x;
			corner_y = line->source_y + y_prev;
			// XXX Note to future self: see above note.
			fy += line->eps_y;
			float val = (line->step_y < 0.0f) ? fy - (float)y_prev + dx*line->step_y : -fy + (float)y_prev - dx*line->step_y;
			if (val + 0.5f + lua_line->fov.fov_settings.permissiveness - y0 > GRID_EPSILON &&
				lua_line->fov.fov_settings.opaque(&(lua_line->fov), corner_x, corner_y)
			) {
				is_corner_blocked = true;
			}
		}
	}
	line->t += 1;

	luaL_unref(L, LUA_REGISTRYINDEX, lua_line->fov.opaque_ref);

	lua_pushnumber(L, line->source_x + x);
	lua_pushnumber(L, line->source_y + y);
	if (is_corner_blocked) {
		lua_pushnumber(L, corner_x);
		lua_pushnumber(L, corner_y);
	} else {
		lua_pushnil(L);
		lua_pushnil(L);
	}
	return 4;
}

// Hmm, this function was just added and may change in the near-future.  We probably want
// to create a line at a specific angle, so let's simply make a function that does just that.
static int lua_fov_line_change_step(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}
	fov_line_data *line = &(lua_line->line);
	float step_x = lua_tonumber(L, 2);
	float step_y = lua_tonumber(L, 3);

	line->step_x = step_x;
	line->step_y = step_y;
	return 0;
}

// use to "wiggle" away from boundary cases
static int lua_fov_line_wiggle(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}
	fov_line_data *line = &(lua_line->line);
	bool wiggle_me_gently = lua_toboolean(L, 2);

	if (fabs(line->step_x) < fabs(line->step_y)) {
		if (wiggle_me_gently) {
			line->step_y += 0.001f;
		} else {
			line->step_y -= 0.001f;
		}
	} else {
		if (wiggle_me_gently) {
			line->step_x += 0.001f;
		} else {
			line->step_x -= 0.001f;
		}
	}

	return 0;
}

// The next three functions aren't used anywhere and can probably be deleted
static int lua_fov_line_blocked_xy(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}

	fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);

	if (!line->is_blocked) return 0;
	float val = (float)line->block_t * line->step_x + line->eps_x;
	int x = (val < 0.0f) ? -(int)(line->start_x - val) : (int)(line->start_x + val);
	val = (float)line->block_t * line->step_y + line->eps_y;
	int y = (val < 0.0f) ? -(int)(line->start_y - val) : (int)(line->start_y + val);
	lua_pushnumber(L, line->source_x + x);
	lua_pushnumber(L, line->source_y + y);
	return 2;
}

static int lua_fov_line_last_open_xy(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}

	fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);
	int x, y;
	float val;

	if (line->is_blocked) {
		val = (float)(line->block_t - 1) * line->step_x + line->eps_x;
		x = (val < 0.0f) ? -(int)(line->start_x - val) : (int)(line->start_x + val);
		val = (float)(line->block_t - 1) * line->step_y + line->eps_y;
		y = (val < 0.0f) ? -(int)(line->start_y - val) : (int)(line->start_y + val);
	}
	else {
		val = (float)line->dest_t * line->step_x + line->eps_x;
		x = (val < 0.0f) ? -(int)(line->start_x - val) : (int)(line->start_x + val);
		val = (float)line->dest_t * line->step_y + line->eps_y;
		y = (val < 0.0f) ? -(int)(line->start_y - val) : (int)(line->start_y + val);
	}
	lua_pushnumber(L, line->source_x + x);
	lua_pushnumber(L, line->source_y + y);
	return 2;
}

static int lua_fov_line_is_blocked(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}

	lua_pushboolean(L, lua_line->line.is_blocked);
	return 1;
}

static int lua_fov_line_reset(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}

	fov_line_data *line = &(lua_line->line);
	if (line->start_at_end) {
		if (line->is_blocked) {
			line->t = line->block_t;
		} else {
			line->t = line->dest_t;
		}
	} else {
		line->t = 0;
	}
	return 0;
}

// export data so we may save it in lua
static int lua_fov_line_export(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}
	fov_line_data *line = &(lua_line->line);
	lua_pushnumber(L, line->source_x);
	lua_pushnumber(L, line->source_y);
	lua_pushnumber(L, line->t);
	lua_pushnumber(L, line->block_t);
	lua_pushnumber(L, line->dest_t);
	lua_pushnumber(L, line->start_x);
	lua_pushnumber(L, line->start_y);
	lua_pushnumber(L, line->step_x);
	lua_pushnumber(L, line->step_y);
	lua_pushnumber(L, line->eps_x);
	lua_pushnumber(L, line->eps_y);
	lua_pushboolean(L, line->is_blocked);
	lua_pushboolean(L, line->start_at_end);

	return 13;
}

// load previously exported data (or create a specific line of your choice)
static int lua_fov_line_import(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	int source_x = luaL_checknumber(L, 3);
	int source_y = luaL_checknumber(L, 4);
	int t = luaL_checknumber(L, 5);
	int block_t = luaL_checknumber(L, 6);
	int dest_t = luaL_checknumber(L, 7);
	float start_x = luaL_checknumber(L, 8);
	float start_y = luaL_checknumber(L, 9);
	float step_x = luaL_checknumber(L, 10);
	float step_y = luaL_checknumber(L, 11);
	float eps_x = luaL_checknumber(L, 12);
	float eps_y = luaL_checknumber(L, 13);
	bool is_blocked = lua_toboolean(L, 14);
	bool start_at_end = lua_toboolean(L, 15);

	lua_fov_line *lua_line = (lua_fov_line*)lua_newuserdata(L, sizeof(lua_fov_line));
	fov_line_data *line = &(lua_line->line);
	line->source_x = source_x;
	line->source_y = source_y;
	line->t = t;
	line->block_t = block_t;
	line->dest_t = dest_t;
	line->start_x = start_x;
	line->start_y = start_y;
	line->step_x = step_x;
	line->step_y = step_y;
	line->eps_x = eps_x;
	line->eps_y = eps_y;
	line->is_blocked = is_blocked;
	line->start_at_end = start_at_end;

	struct lua_fov *fov = &(lua_line->fov);
	fov->cache_ref = LUA_NOREF;
	fov->cache = NULL;
	fov->L = L;
	fov->opaque_ref = LUA_NOREF;
	fov->w = w;
	fov->h = h;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);

	auxiliar_setclass(L, "core{fovline}", -1);
	return 1;
}

static int lua_free_fov_line(lua_State *L)
{
	lua_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_fov_line*)auxiliar_checkclass(L, "core{fovline}", 1);
	}

	lua_pushnumber(L, 1);
	return 1;
}

/****************************************************************
 ** HEX_FOV line
 ****************************************************************/

static int lua_hex_fov_line_init(lua_State *L)
{
	int source_x = luaL_checknumber(L, 1);
	int source_y = luaL_checknumber(L, 2);
	int dest_x = luaL_checknumber(L, 3);
	int dest_y = luaL_checknumber(L, 4);
	int w = luaL_checknumber(L, 5);
	int h = luaL_checknumber(L, 6);
	bool start_at_end = lua_toboolean(L, 7);
	int opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	lua_hex_fov_line *lua_line = (lua_hex_fov_line*)lua_newuserdata(L, sizeof(lua_hex_fov_line));
	hex_fov_line_data *line = &(lua_line->line);
	struct lua_fov *fov = &(lua_line->fov);
	fov->cache_ref = LUA_NOREF;
	fov->cache = NULL;
	fov->L = L;
	fov->opaque_ref = opaque_ref;
	fov->w = w;
	fov->h = h;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);

	hex_fov_create_los_line(&(fov->fov_settings), fov, NULL, line, source_x, source_y, dest_x, dest_y, start_at_end);
	luaL_unref(L, LUA_REGISTRYINDEX, fov->opaque_ref);

	auxiliar_setclass(L, "core{hexfovline}", -1);
	return 1;
}

static int lua_hex_fov_line_step(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
		lua_getfield(L, 1, "block");
		lua_line->fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_line->fov.L = L;
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
		lua_line->fov.opaque_ref = LUA_NOREF;
	}

	hex_fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);
	if (!dont_stop_at_end && line->dest_t == line->t || line->dest_t == 0) return 0;

	line->t += 1;
	float fx = INV_SQRT_3_2 * (line->source_x + (float)line->t * line->step_x + line->eps_x);
	int x = (int)fx - (fx < 0.0f);
	float fy = line->source_y + (float)line->t * line->step_y + line->eps_y - 0.5f*(x & 1);
	int y = (int)fy - (fy < 0.0f);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_pushnil(L);
	lua_pushnil(L);
	return 4;
}

// Hmm, this function was just added and may change in the near-future.  We probably want
// to create a line at a specific angle, so let's simply make a function that does just that.
static int lua_hex_fov_line_change_step(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}
	hex_fov_line_data *line = &(lua_line->line);
	float step_x = lua_tonumber(L, 2);
	float step_y = lua_tonumber(L, 3);
	float ax = fabs(step_x);
	float ay = fabs(step_y);

	// lines are a little weird in hex, so lets enforce unit step sizes
	if (SQRT_3*ay < ax) {
		line->step_x = SQRT_3_2 * step_x / ax;
		line->step_y = SQRT_3_2 * step_y / ax;
	} else {
		line->step_x = step_x / (INV_SQRT_3*ax + ay);
		line->step_y = step_y / (INV_SQRT_3*ax + ay);
	}

	return 0;
}

// use to "wiggle" away from boundary cases
// Will this ever be needed for hexes?
static int lua_hex_fov_line_wiggle(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}
	hex_fov_line_data *line = &(lua_line->line);
	bool wiggle_me_gently = lua_toboolean(L, 2);

	if (fabs(line->step_x) < fabs(line->step_y)) {
		if (wiggle_me_gently) {
			line->step_y += 0.001f;
		} else {
			line->step_y -= 0.001f;
		}
	} else {
		if (wiggle_me_gently) {
			line->step_x += 0.001f;
		} else {
			line->step_x -= 0.001f;
		}
	}

	return 0;
}

// The next three functions aren't used anywhere and can probably be deleted
static int lua_hex_fov_line_blocked_xy(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}

	hex_fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);

	if (!line->is_blocked) return 0;

	float fx = INV_SQRT_3_2 * (line->source_x + (float)line->block_t * line->step_x + line->eps_x);
	int x = (int)fx - (fx < 0.0f);
	float fy = line->source_y + (float)line->block_t * line->step_y + line->eps_y - 0.5f*(x & 1);
	int y = (int)fy - (fy < 0.0f);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);

	return 2;
}

static int lua_hex_fov_line_last_open_xy(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}

	hex_fov_line_data *line = &(lua_line->line);
	bool dont_stop_at_end = lua_toboolean(L, 2);
	int x, y;
	float fx, fy;

	if (line->is_blocked) {
		fx = INV_SQRT_3_2 * (line->source_x + (float)(line->block_t - 1) * line->step_x + line->eps_x);
		x = (int)fx - (fx < 0.0f);
		fy = line->source_y + (float)(line->block_t - 1) * line->step_y + line->eps_y - 0.5f*(x & 1);
		y = (int)fy - (fy < 0.0f);
	}
	else {
		fx = INV_SQRT_3_2 * (line->source_x + (float)line->dest_t * line->step_x + line->eps_x);
		x = (int)fx - (fx < 0.0f);
		fy = line->source_y + (float)line->dest_t * line->step_y + line->eps_y - 0.5f*(x & 1);
		y = (int)fy - (fy < 0.0f);
	}
	lua_pushnumber(L, line->source_x + x);
	lua_pushnumber(L, line->source_y + y);
	return 2;
}

static int lua_hex_fov_line_is_blocked(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}

	lua_pushboolean(L, lua_line->line.is_blocked);
	return 1;
}

static int lua_hex_fov_line_reset(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}

	hex_fov_line_data *line = &(lua_line->line);
	if (line->start_at_end) {
		if (line->is_blocked) {
			line->t = line->block_t;
		} else {
			line->t = line->dest_t;
		}
	} else {
		line->t = 0;
	}
	return 0;
}

// export data so we may save it in lua
static int lua_hex_fov_line_export(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}
	hex_fov_line_data *line = &(lua_line->line);
	lua_pushnumber(L, line->source_x);
	lua_pushnumber(L, line->source_y);
	lua_pushnumber(L, line->t);
	lua_pushnumber(L, line->block_t);
	lua_pushnumber(L, line->dest_t);
	lua_pushnumber(L, line->step_x);
	lua_pushnumber(L, line->step_y);
	lua_pushnumber(L, line->eps_x);
	lua_pushnumber(L, line->eps_y);
	lua_pushboolean(L, line->is_blocked);
	lua_pushboolean(L, line->start_at_end);

	return 11;
}

// load previously exported data (or create a specific line of your choice)
static int lua_hex_fov_line_import(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	float source_x = luaL_checknumber(L, 3);
	float source_y = luaL_checknumber(L, 4);
	int t = luaL_checknumber(L, 5);
	int block_t = luaL_checknumber(L, 6);
	int dest_t = luaL_checknumber(L, 7);
	float step_x = luaL_checknumber(L, 8);
	float step_y = luaL_checknumber(L, 9);
	float eps_x = luaL_checknumber(L, 10);
	float eps_y = luaL_checknumber(L, 11);
	bool is_blocked = lua_toboolean(L, 12);
	bool start_at_end = lua_toboolean(L, 13);

	lua_hex_fov_line *lua_line = (lua_hex_fov_line*)lua_newuserdata(L, sizeof(lua_hex_fov_line));
	hex_fov_line_data *line = &(lua_line->line);
	line->source_x = source_x;
	line->source_y = source_y;
	line->t = t;
	line->block_t = block_t;
	line->dest_t = dest_t;
	line->step_x = step_x;
	line->step_y = step_y;
	line->eps_x = eps_x;
	line->eps_y = eps_y;
	line->is_blocked = is_blocked;
	line->start_at_end = start_at_end;

	struct lua_fov *fov = &(lua_line->fov);
	fov->cache_ref = LUA_NOREF;
	fov->cache = NULL;
	fov->L = L;
	fov->opaque_ref = LUA_NOREF;
	fov->w = w;
	fov->h = h;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);

	auxiliar_setclass(L, "core{hexfovline}", -1);
	return 1;
}

static int lua_free_hex_fov_line(lua_State *L)
{
	lua_hex_fov_line *lua_line;
	if (lua_istable(L, 1)) {
		lua_getfield(L, 1, "line");
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", -1);
		lua_pop(L, 1);
	} else {
		lua_line = (lua_hex_fov_line*)auxiliar_checkclass(L, "core{hexfovline}", 1);
	}

	lua_pushnumber(L, 1);
	return 1;
}

static const struct luaL_reg fovlib[] =
{
	{"newCache", lua_new_fovcache},
	{"distance", lua_distance},
	{"calc_default_fov", lua_fov_calc_default_fov},
	{"calc_circle", lua_fov_calc_circle},
	{"calc_beam", lua_fov_calc_beam},
	{"calc_beam_any_angle", lua_fov_calc_beam_any_angle},
	{"line_base", lua_fov_line_init},
	{"hex_line_base", lua_hex_fov_line_init},
	{"line_import", lua_fov_line_import},
	{"hex_line_import", lua_hex_fov_line_import},
	{"set_permissiveness_base", lua_fov_set_permissiveness},
	{"set_actor_vision_size_base", lua_fov_set_actor_vision_size},
	{"set_vision_shape_base", lua_fov_set_vision_shape},
	{"set_algorithm_base", lua_fov_set_algorithm},
	{NULL, NULL},
};

static const struct luaL_reg fovcache_reg[] =
{
	{"set", lua_fovcache_set},
	{"get", lua_fovcache_get},
	{NULL, NULL},
};

static const struct luaL_reg fovline_reg[] =
{
	{"__gc", lua_free_fov_line},
	{"__call", lua_fov_line_step},
	{"step", lua_fov_line_step},
	{"change_step", lua_fov_line_change_step},
	{"wiggle", lua_fov_line_wiggle},
	{"is_blocked", lua_fov_line_is_blocked},
	{"blocked_xy", lua_fov_line_blocked_xy},
	{"last_open_xy", lua_fov_line_last_open_xy},
	{"reset", lua_fov_line_reset},
	{"export", lua_fov_line_export},
	{NULL, NULL},
};

static const struct luaL_reg hexfovline_reg[] =
{
	{"__gc", lua_free_hex_fov_line},
	{"__call", lua_hex_fov_line_step},
	{"step", lua_hex_fov_line_step},
	{"change_step", lua_hex_fov_line_change_step},
	{"wiggle", lua_hex_fov_line_wiggle},
	{"is_blocked", lua_hex_fov_line_is_blocked},
	{"blocked_xy", lua_hex_fov_line_blocked_xy},
	{"last_open_xy", lua_hex_fov_line_last_open_xy},
	{"reset", lua_hex_fov_line_reset},
	{"export", lua_hex_fov_line_export},
	{NULL, NULL},
};

int luaopen_fov(lua_State *L)
{
	auxiliar_newclass(L, "fov{cache}", fovcache_reg);
	auxiliar_newclass(L, "core{fovline}", fovline_reg);
	auxiliar_newclass(L, "core{hexfovline}", hexfovline_reg);
	luaL_openlib(L, "core.fov", fovlib, 0);
	lua_pop(L, 1);
	return 1;
}

