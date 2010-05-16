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
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "music.h"
#include "script.h"
#include "tSDL.h"
#include "physfs.h"
#include "physfsrwops.h"

bool sound_active = TRUE;

static int music_new(lua_State *L)
{
	if (no_sound) return 0;
	const char *name = luaL_checkstring(L, 1);

	Mix_Music **m = (Mix_Music**)lua_newuserdata(L, sizeof(Mix_Music*));
	auxiliar_setclass(L, "core{music}", -1);

	SDL_RWops *rops = PHYSFSRWOPS_openRead(name);
	if (!rops)
	{
		*m = NULL;
		return 0;
	}
	*m = Mix_LoadMUS_RW(rops);
	if (!*m) return 0;

	return 1;
}

static int music_free(lua_State *L)
{
	Mix_Music **m = (Mix_Music**)auxiliar_checkclass(L, "core{music}", 1);
	if (*m) Mix_FreeMusic(*m);
	lua_pushnumber(L, 1);
	return 1;
}

static int music_play(lua_State *L)
{
	if (!sound_active) return 0;
	Mix_Music **m = (Mix_Music**)auxiliar_checkclass(L, "core{music}", 1);
	int loop = lua_isnumber(L, 2) ? lua_tonumber(L, 2) : 1;
	int fadein = lua_isnumber(L, 3) ? lua_tonumber(L, 3) : 0;

	printf("play music %x %d %d\n", (unsigned int)(*m), loop, fadein);
	lua_pushboolean(L, (Mix_FadeInMusic(*m, loop, fadein) == -1) ? FALSE : TRUE);
	return 1;
}

static int music_stop(lua_State *L)
{
	if (no_sound) return 0;
	int fadeout = lua_isnumber(L, 1) ? lua_tonumber(L, 1) : 0;
	Mix_FadeOutMusic(fadeout);
	return 0;
}

static int music_volume(lua_State *L)
{
	if (no_sound) return 0;
	int vol = lua_isnumber(L, 1) ? lua_tonumber(L, 1) : 100;

	Mix_VolumeMusic(SDL_MIX_MAXVOLUME * vol / 100);
	return 0;
}

static int sound_new(lua_State *L)
{
	if (no_sound) return 0;
	const char *name = luaL_checkstring(L, 1);

	Mix_Chunk **m = (Mix_Chunk**)lua_newuserdata(L, sizeof(Mix_Chunk*));
	auxiliar_setclass(L, "core{sound}", -1);

	SDL_RWops *rops = PHYSFSRWOPS_openRead(name);
	if (!rops)
	{
		*m = NULL;
		return 0;
	}
	*m = Mix_LoadWAV_RW(rops, 1);
	if (!*m) return 0;
	Mix_VolumeChunk(*m, SDL_MIX_MAXVOLUME);

	return 1;
}

static int sound_free(lua_State *L)
{
	Mix_Chunk **m = (Mix_Chunk**)auxiliar_checkclass(L, "core{sound}", 1);
	if (*m) Mix_FreeChunk(*m);
	lua_pushnumber(L, 1);
	return 1;
}

static int sound_play(lua_State *L)
{
	if (!sound_active) return 0;
	Mix_Chunk **m = (Mix_Chunk**)auxiliar_checkclass(L, "core{sound}", 1);
	int loop = lua_isnumber(L, 2) ? lua_tonumber(L, 2) : 0;
	int ms = lua_isnumber(L, 3) ? lua_tonumber(L, 3) : 0;
	int chan;
	if (!ms)
		chan = Mix_PlayChannel(-1, *m, loop);
	else
		chan = Mix_PlayChannelTimed(-1, *m, loop , ms);
	if (chan == -1) lua_pushnil(L);
	else lua_pushnumber(L, chan);
	return 1;
}

static int sound_volume(lua_State *L)
{
	Mix_Chunk **m = (Mix_Chunk**)auxiliar_checkclass(L, "core{sound}", 1);
	int vol = lua_isnumber(L, 2) ? lua_tonumber(L, 2) : 100;
	Mix_VolumeChunk(*m, SDL_MIX_MAXVOLUME * vol / 100);
	return 0;
}

static int channel_fadeout(lua_State *L)
{
	if (no_sound) return 0;
	int chan = luaL_checknumber(L, 1);
	int ms = luaL_checknumber(L, 2);

	Mix_FadeOutChannel(chan, ms);
	return 0;
}

static int sound_status(lua_State *L)
{
	if (lua_isboolean(L, 1))
	{
		int act = lua_toboolean(L, 1);
		sound_active = act;
		return 0;
	}
	else
	{
		lua_pushboolean(L, sound_active);
		return 1;
	}
}

static const struct luaL_reg soundlib[] =
{
	{"soundSystemStatus", sound_status},
	{"newMusic", music_new},
	{"newSound", sound_new},
	{"musicStop", music_stop},
	{"musicVolume", music_volume},
	{"channelFadeOut", channel_fadeout},
	{NULL, NULL},
};

static const struct luaL_reg music_reg[] =
{
	{"__gc", music_free},
	{"play", music_play},
	{NULL, NULL},
};

static const struct luaL_reg sound_reg[] =
{
	{"__gc", sound_free},
	{"play", sound_play},
	{"setVolume", sound_volume},
	{NULL, NULL},
};

int luaopen_sound(lua_State *L)
{
	auxiliar_newclass(L, "core{music}", music_reg);
	auxiliar_newclass(L, "core{sound}", sound_reg);
	luaL_openlib(L, "core.sound", soundlib, 0);
	return 1;
}
