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
#include <stdlib.h>
#include "libtcod.h"
#include "noise.h"
#include "tgl.h"

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
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_fbm_simplex(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_simplex(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

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
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_fbm_perlin(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_perlin(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

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
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_fbm_wavelet(n->noise, p, octave));
	return 1;
}

static int noise_turbulence_wavelet(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	float p[4];
	int i;
	for (i = 0; i < n->ndim; i++) p[i] = luaL_checknumber(L, 2 + i);
	float octave = luaL_checknumber(L, 2 + i);

	lua_pushnumber(L, TCOD_noise_turbulence_wavelet(n->noise, p, octave));
	return 1;
}

#define BYTES_PER_TEXEL 3
#define LAYER(r)	(w * h * r * BYTES_PER_TEXEL)
// 2->1 dimension mapping function
#define TEXEL2(s, t)	(BYTES_PER_TEXEL * (s * w + t))
// 3->1 dimension mapping function
#define TEXEL3(s, t, r)	(TEXEL2(s, t) + LAYER(r))

static int noise_texture2d(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	const char *type = luaL_checkstring(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	float zoom = luaL_checknumber(L, 5);
	float x = luaL_checknumber(L, 6);
	float y = luaL_checknumber(L, 7);
	float octave = lua_tonumber(L, 8);
	GLubyte *map = malloc(w * h * 3 * sizeof(GLubyte));

	float p[2];
	int i, j;
	for (i = 0; i < w; i++)
	{
		for (j = 0; j < h; j++)
		{
			p[0] = zoom * ((float)(i+x)) / w;
			p[1] = zoom * ((float)(j+y)) / h;
			float v = ((TCOD_noise_simplex(n->noise, p) + 1) / 2) * 255;
			map[TEXEL2(i, j)] = (GLubyte)v;
			map[TEXEL2(i, j)+1] = (GLubyte)v;
			map[TEXEL2(i, j)+2] = (GLubyte)v;
		}
	}

	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);

	glGenTextures(1, t);
	glBindTexture(GL_TEXTURE_2D, *t);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, map);

	free(map);

	return 1;
}

static int noise_texture3d(lua_State *L)
{
	noise_t *n = (noise_t*)auxiliar_checkclass(L, "noise{core}", 1);
	const char *type = luaL_checkstring(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	int d = luaL_checknumber(L, 5);
	float zoom = luaL_checknumber(L, 6);
	float x = luaL_checknumber(L, 7);
	float y = luaL_checknumber(L, 8);
	float z = luaL_checknumber(L, 9);
	float octave = lua_tonumber(L, 10);
	GLubyte *map = malloc(w * h * d * 3 * sizeof(GLubyte));

	float p[3];
	int i, j, k;
	for (i = 0; i < w; i++)
	{
		for (j = 0; j < h; j++)
		{
			for (k = 0; k < d; k++)
			{
				p[0] = zoom * ((float)(i+x)) / w;
				p[1] = zoom * ((float)(j+y)) / h;
				p[2] = zoom * ((float)(k+z)) / d;
				float v = ((TCOD_noise_simplex(n->noise, p) + 1) / 2) * 255;
				map[TEXEL3(i, j, k)] = (GLubyte)v;
				map[TEXEL3(i, j, k)+1] = (GLubyte)v;
				map[TEXEL3(i, j, k)+2] = (GLubyte)v;
			}
		}
	}

	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);

	glGenTextures(1, t);
	glBindTexture(GL_TEXTURE_3D, *t);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage3D(GL_TEXTURE_3D, 0, GL_RGB8, w, h, d, 0, GL_RGB, GL_UNSIGNED_BYTE, map);

	free(map);

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
	{"makeTexture2D", noise_texture2d},
	{"makeTexture3D", noise_texture3d},
	{NULL, NULL},
};

int luaopen_noise(lua_State *L)
{
	auxiliar_newclass(L, "noise{core}", noise_reg);
	luaL_openlib(L, "core.noise", noiselib, 0);
	return 1;
}
