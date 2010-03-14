#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "music.h"
#include "script.h"
#include <SDL.h>
#include <SDL_mixer.h>

static int music_new(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);

	Mix_Music **m = (Mix_Music**)lua_newuserdata(L, sizeof(Mix_Music*));
	auxiliar_setclass(L, "core{music}", -1);

	SDL_RWops *rops = PHYSFSRWOPS_openRead(name);
	if (!rops)
	{
		return 0;
	}
	*m = Mix_LoadMUS_RW(rops);
	if (!*m) return 0;

	return 1;
}

static int music_free(lua_State *L)
{
	Mix_Music **m = (Mix_Music**)auxiliar_checkclass(L, "core{music}", 1);
	Mix_FreeMusic(*m);
	lua_pushnumber(L, 1);
	return 1;
}

static int music_play(lua_State *L)
{
	Mix_Music **m = (Mix_Music**)auxiliar_checkclass(L, "core{music}", 1);
	int loop = lua_isnumber(L, 2) ? lua_tonumber(L, 2) : 1;
	int fadein = lua_isnumber(L, 3) ? lua_tonumber(L, 3) : 0;

	lua_pushboolean(L, (Mix_FadeInMusic(*m, loop, fadein) == -1) ? FALSE : TRUE);
	return 1;
}

static int music_stop(lua_State *L)
{
	Mix_Music **m = (Mix_Music**)auxiliar_checkclass(L, "core{music}", 1);
	int fadeout = lua_isnumber(L, 2) ? lua_tonumber(L, 2) : 0;
	Mix_FadeOutMusic(fadeout);
	return 0;
}

static const struct luaL_reg soundlib[] =
{
	{"newMusic", music_new},
	{NULL, NULL},
};

static const struct luaL_reg music_reg[] =
{
	{"__gc", music_free},
	{"play", music_play},
	{"stop", music_stop},
	{NULL, NULL},
};

int luaopen_sound(lua_State *L)
{
	auxiliar_newclass(L, "core{music}", music_reg);
	luaL_openlib(L, "core.sound", soundlib, 0);
	return 1;
}
