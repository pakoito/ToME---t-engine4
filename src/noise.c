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
#include "script.h"
#include <math.h>
#include "libtcod.h"
#include "noise.h"

typedef struct
{
	TCOD_noise_t noise;
	int ndim;
} noise_t;

static int noise_new(lua_State *L)
{
	int ndim = luaL_checknumber(L, 1);
	float hurst = lua_isnumber(L, 2) ? luaL_checknumber(L, 2) : TCOD_NOISE_DEFAULT_HURST;
	float lacunarity = lua_isnumber(L, 3) ? luaL_checknumber(L, 3) : TCOD_NOISE_DEFAULT_LACUNARITY;

	noise_t *n = (noise_t*)lua_newuserdata(L, sizeof(noise_t));
	auxiliar_setclass(L, "noise{core}", -1);

	n->noise = TCOD_noise_new(ndim, hurst, lacunarity);
	n->ndim = ndim;

	return 1;
}

static int noise_free(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);

	TCOD_noise_delete(n->noise);

	lua_pushnumber(L, 1);
	return 1;
}

static int noise_simplex(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_simplex(n->noise, p));
	return 1;
}

static int noise_fbm_simplex(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_fbm_simplex(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_simplex(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_turbulence_simplex(n->noise, p, octave));
	return 1;
}

static int noise_perlin(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_perlin(n->noise, p));
	return 1;
}

static int noise_fbm_perlin(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_fbm_perlin(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_perlin(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_turbulence_perlin(n->noise, p, octave));
	return 1;
}

static int noise_wavelet(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_wavelet(n->noise, p));
	return 1;
}

static int noise_fbm_wavelet(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_fbm_wavelet(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_wavelet(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float octave = luaL_checknumber(L, 2);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 3 + i);

	lua_pushnumber(L, TCOD_noise_turbulence_wavelet(n->noise, p, octave));
	return 1;
}

static const struct luaL_reg noiselib[] =
{
	{"new", noise_new},
	{NULL, NULL},
};

static const struct luaL_reg noise_reg[] =
{
	{"__gc", noise_free},
	{"simplex", noise_simplex},
	{"fbm_simplex", noise_fbm_simplex},
	{"turbulence_simplex", noise_turbulence_simplex},
	{"perlin", noise_perlin},
	{"fbm_perlin", noise_fbm_perlin},
	{"turbulence_perlin", noise_turbulence_perlin},
	{"wavelet", noise_wavelet},
	{"fbm_wavelet", noise_fbm_wavelet},
	{"turbulence_wavelet", noise_turbulence_wavelet},
	{NULL, NULL},
};

int luaopen_noise(lua_State *L)
{
	auxiliar_newclass(L, "noise{core}", noise_reg);
	luaL_openlib(L, "core.noise", noiselib, 0);
	return 1;
}
