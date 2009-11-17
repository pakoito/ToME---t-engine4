#include "fov/fov.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "script.h"
#include "display.h"

struct lua_fov
{
	fov_settings_type fov_settings;
	int apply_ref;
	int opaque_ref;
	int map_ref;
};

static void map_seen(void *m, int x, int y, int dx, int dy, void *src)
{
	struct lua_fov *fov = (struct lua_fov *)m;

	lua_rawgeti(L, LUA_REGISTRYINDEX, fov->apply_ref);
	lua_rawgeti(L, LUA_REGISTRYINDEX, fov->map_ref);
	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_call(L, 3, 0);
}

static bool map_opaque(void *m, int x, int y)
{
	struct lua_fov *fov = (struct lua_fov *)m;

	lua_rawgeti(L, LUA_REGISTRYINDEX, fov->opaque_ref);
	lua_rawgeti(L, LUA_REGISTRYINDEX, fov->map_ref);
	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_call(L, 3, 1);
	bool res = lua_toboolean(L, -1);
	lua_pop(L, 1);
	return res;
}

static int lua_new_fov(lua_State *L)
{
/*	printf("1\n");
	luaL_checktype(L, LUA_TFUNCTION, 1);
	printf("2\n");
	luaL_checktype(L, LUA_TFUNCTION, 2);
	printf("3\n");
	luaL_checktype(L, LUA_TTABLE, 3);
	printf("4\n");*/
	int map_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	struct lua_fov *fov = (struct lua_fov*)lua_newuserdata(L, sizeof(struct lua_fov));
	auxiliar_setclass(L, "fov{core}", -1);
	fov->apply_ref = apply_ref;
	fov->opaque_ref = opaque_ref;
	fov->map_ref = map_ref;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov->fov_settings), map_seen);

	return 1;
}

static int lua_free_fov(lua_State *L)
{
	struct lua_fov *fov = (struct lua_fov*)auxiliar_checkclass(L, "fov{core}", 1);
	fov_settings_free(&(fov->fov_settings));
	luaL_unref(L, LUA_REGISTRYINDEX, fov->apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov->opaque_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov->map_ref);
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_fov(lua_State *L)
{
	struct lua_fov *fov = (struct lua_fov*)auxiliar_checkclass(L, "fov{core}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int radius = luaL_checknumber(L, 4);

	fov_circle(&(fov->fov_settings), fov, NULL, x, y, radius);
	return 0;
}

static const struct luaL_reg fovlib[] =
{
	{"new", lua_new_fov},
	{NULL, NULL},
};

static const struct luaL_reg fov_reg[] =
{
	{"__gc", lua_free_fov},
	{"close", lua_free_fov},
	{"__call", lua_fov},
	{NULL, NULL},
};

extern int current_map;

static int lua_set_current_map(lua_State *L)
{
	if (lua_isnil(L, 1))
		current_map = LUA_NOREF;
	else
		current_map = luaL_ref(L, LUA_REGISTRYINDEX);

	return 0;
}

static int lua_display_char(lua_State *L)
{
	const char *c = luaL_checkstring(L, 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int r = luaL_checknumber(L, 4);
	int g = luaL_checknumber(L, 5);
	int b = luaL_checknumber(L, 6);

	display_put_char(c[0], x, y, r, g, b);

	return 0;
}

static const struct luaL_reg displaylib[] =
{
	{"char", lua_display_char},
	{"set_current_map", lua_set_current_map},
	{NULL, NULL},
};

int luaopen_core(lua_State *L)
{
	auxiliar_newclass(L, "fov{core}", fov_reg);
	luaL_openlib(L, "engine.fov", fovlib, 0);
	luaL_openlib(L, "engine.display", displaylib, 0);
	return 1;
}
