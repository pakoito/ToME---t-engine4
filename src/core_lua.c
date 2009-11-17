#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"

#include "map.h"

#define REG_CORELUA	"core"

extern map current_map;

typedef struct lua_map lua_map;
struct lua_map
{
	map m;
};

static int lua_new_map(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	lua_map *m = (lua_map*)lua_newuserdata(L, sizeof(struct lua_map));
	auxiliar_setclass(L, "map{core}", -1);
	m->m = new_map(w, h);
	return 1;
}

static int lua_free_map(lua_State *L)
{
	lua_map *m = (lua_map*)auxiliar_checkclass(L, "map{core}", 1);
	free_map(m->m);
	if (current_map == m->m) current_map = NULL;
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_set_current_map(lua_State *L)
{
	lua_map *m = (lua_map*)auxiliar_checkclass(L, "map{core}", 1);
	current_map = m->m;
	return 0;
}

static int lua_grid(lua_State *L)
{
	lua_map *m = (lua_map*)auxiliar_checkclass(L, "map{core}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int pos = lua_tonumber(L, 4);
	long uid = luaL_optlong(L, 5, -1);

	if (uid == -1)
	{
		uid = map_get_grid(m->m, x, y, pos);
		if (!uid)
			lua_pushnil(L);
		else
			lua_pushnumber(L, uid);
		return 1;
	}
	else
	{
		map_insert_grid(m->m, x, y, pos, uid);
		return 0;
	}
}

static const struct luaL_reg corelib[] =
{
	{"new_map", lua_new_map},
	{"setCurrent", lua_set_current_map},
	{NULL, NULL},
};

static const struct luaL_reg map_reg[] =
{
	{"__gc", lua_free_map},
	{"__call", lua_grid},
	{"setCurrent", lua_set_current_map},
	{NULL, NULL},
};

int luaopen_core(lua_State *L)
{
	auxiliar_newclass(L, "map{core}", map_reg);
	luaL_openlib(L, "core", corelib, 0);
	return 1;
}
