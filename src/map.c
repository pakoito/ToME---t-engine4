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
#include <math.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "map.h"
#include "script.h"
#include "tSDL.h"
//#include "shaders.h"

extern void useShader(GLuint p, int x, int y, float a);

// Minimap defines
#define MM_FLOOR 1
#define MM_BLOCK 2
#define MM_OBJECT 4
#define MM_TRAP 8
#define MM_FRIEND 16
#define MM_NEUTRAL 32
#define MM_HOSTILE 64
#define MM_LEVEL_CHANGE 128

static int map_new(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	int mx = luaL_checknumber(L, 3);
	int my = luaL_checknumber(L, 4);
	int mwidth = luaL_checknumber(L, 5);
	int mheight = luaL_checknumber(L, 6);
	int tile_w = luaL_checknumber(L, 7);
	int tile_h = luaL_checknumber(L, 8);
	bool multidisplay = lua_toboolean(L, 9);

	map_type *map = (map_type*)lua_newuserdata(L, sizeof(map_type));
	auxiliar_setclass(L, "core{map}", -1);

	map->obscure_r = map->obscure_g = map->obscure_b = 0.6f;
	map->obscure_a = 1;
	map->shown_r = map->shown_g = map->shown_b = 1;
	map->shown_a = 1;

	map->mm_floor = map->mm_block = map->mm_object = map->mm_trap = map->mm_friend = map->mm_neutral = map->mm_hostile = map->mm_level_change = 0;
	map->minimap_gridsize = 4;

	map->multidisplay = multidisplay;
	map->w = w;
	map->h = h;
	map->tile_w = tile_w;
	map->tile_h = tile_h;
	map->mx = mx;
	map->my = my;
	map->mwidth = mwidth;
	map->mheight = mheight;
	map->grids_terrain = calloc(w, sizeof(map_texture*));
	map->grids_actor = calloc(w, sizeof(map_texture*));
	map->grids_trap = calloc(w, sizeof(map_texture*));
	map->grids_object = calloc(w, sizeof(map_texture*));
	map->grids_seens = calloc(w, sizeof(float*));
	map->grids_remembers = calloc(w, sizeof(bool*));
	map->grids_lites = calloc(w, sizeof(bool*));
	map->minimap = calloc(w, sizeof(unsigned char*));
	printf("C Map size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	int i;
	for (i = 0; i < w; i++)
	{
		map->grids_terrain[i] = calloc(h, sizeof(map_texture));
		map->grids_actor[i] = calloc(h, sizeof(map_texture));
		map->grids_object[i] = calloc(h, sizeof(map_texture));
		map->grids_trap[i] = calloc(h, sizeof(map_texture));
		map->grids_seens[i] = calloc(h, sizeof(float));
		map->grids_remembers[i] = calloc(h, sizeof(bool));
		map->grids_lites[i] = calloc(h, sizeof(bool));
		map->minimap[i] = calloc(h, sizeof(unsigned char));
	}


	/* New compiled box display list */
	/*
	map->dlist = glGenLists(1);
	glNewList(map->dlist, GL_COMPILE);
		glBegin(GL_QUADS);
		glTexCoord2f(0,0); glVertex2f(0  , 0  );
		glTexCoord2f(0,1); glVertex2f(0  , 16 );
		glTexCoord2f(1,1); glVertex2f(16 , 16 );
		glTexCoord2f(1,0); glVertex2f(16 , 0  );
		glEnd();
	glEndList();
	*/

	return 1;
}

static int map_free(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i;

	for (i = 0; i < map->w; i++)
	{
		free(map->grids_terrain[i]);
		free(map->grids_actor[i]);
		free(map->grids_trap[i]);
		free(map->grids_object[i]);
		free(map->grids_seens[i]);
		free(map->grids_remembers[i]);
		free(map->grids_lites[i]);
		free(map->minimap[i]);
	}
	free(map->grids_terrain);
	free(map->grids_actor);
	free(map->grids_object);
	free(map->grids_trap);
	free(map->grids_seens);
	free(map->grids_remembers);
	free(map->grids_lites);
	free(map->minimap);

	lua_pushnumber(L, 1);
	return 1;
}

static int map_set_obscure(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	float r = luaL_checknumber(L, 2);
	float g = luaL_checknumber(L, 3);
	float b = luaL_checknumber(L, 4);
	float a = luaL_checknumber(L, 5);
	map->obscure_r = r;
	map->obscure_g = g;
	map->obscure_b = b;
	map->obscure_a = a;
	return 0;
}

static int map_set_shown(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	float r = luaL_checknumber(L, 2);
	float g = luaL_checknumber(L, 3);
	float b = luaL_checknumber(L, 4);
	float a = luaL_checknumber(L, 5);
	map->shown_r = r;
	map->shown_g = g;
	map->shown_b = b;
	map->shown_a = a;
	return 0;
}

static int map_set_minimap_gridsize(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	float s = luaL_checknumber(L, 2);
	map->minimap_gridsize = s;
	return 0;
}

static int map_set_minimap(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	GLuint *floor  = lua_isnil(L, 2) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 2);
	GLuint *block  = lua_isnil(L, 3) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 3);
	GLuint *object = lua_isnil(L, 4) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 4);
	GLuint *trap   = lua_isnil(L, 5) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 5);
	GLuint *frien  = lua_isnil(L, 6) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 6);
	GLuint *neutral =lua_isnil(L, 7) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 7);
	GLuint *hostile =lua_isnil(L, 8) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 8);
	GLuint *lev     =lua_isnil(L, 9) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 9);

	map->mm_floor = *floor;
	map->mm_block = *block;
	map->mm_object = *object;
	map->mm_trap = *trap;
	map->mm_friend = *frien;
	map->mm_neutral = *neutral;
	map->mm_hostile = *hostile;
	map->mm_level_change = *lev;
	return 0;
}

static int map_set_grid(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	GLuint *g = lua_isnil(L, 4) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 4);
	GLuint *shad_g = lua_isnil(L, 5) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{program}", 5);
	float g_r = lua_tonumber(L, 6);
	float g_g = lua_tonumber(L, 7);
	float g_b = lua_tonumber(L, 8);

	GLuint *t = lua_isnil(L, 9) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 9);
	GLuint *shad_t = lua_isnil(L, 10) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{program}", 10);
	float t_r = lua_tonumber(L, 11);
	float t_g = lua_tonumber(L, 12);
	float t_b = lua_tonumber(L, 13);

	GLuint *o = lua_isnil(L, 14) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 14);
	GLuint *shad_o = lua_isnil(L, 15) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{program}", 15);
	float o_r = lua_tonumber(L, 16);
	float o_g = lua_tonumber(L, 17);
	float o_b = lua_tonumber(L, 18);

	GLuint *a = lua_isnil(L, 19) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 19);
	GLuint *shad_a = lua_isnil(L, 20) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{program}", 20);
	float a_r = lua_tonumber(L, 21);
	float a_g = lua_tonumber(L, 22);
	float a_b = lua_tonumber(L, 23);

	unsigned char mm = lua_tonumber(L, 24);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;

	map->grids_terrain[x][y].texture = g ? *g : 0;
	map->grids_terrain[x][y].shader = shad_g ? *shad_g : 0;
	map->grids_terrain[x][y].tint_r = g_r;
	map->grids_terrain[x][y].tint_g = g_g;
	map->grids_terrain[x][y].tint_b = g_b;

	map->grids_trap[x][y].texture = t ? *t : 0;
	map->grids_trap[x][y].tint_r = t_r;
	map->grids_trap[x][y].tint_g = t_g;
	map->grids_trap[x][y].tint_b = t_b;

	map->grids_actor[x][y].texture = a ? *a : 0;
	map->grids_actor[x][y].tint_r = a_r;
	map->grids_actor[x][y].tint_g = a_g;
	map->grids_actor[x][y].tint_b = a_b;

	map->grids_object[x][y].texture = o ? *o : 0;
	map->grids_object[x][y].tint_r = o_r;
	map->grids_object[x][y].tint_g = o_g;
	map->grids_object[x][y].tint_b = o_b;

	map->minimap[x][y] = mm;
	return 0;
}

static int map_set_seen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	float v = lua_tonumber(L, 4);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	map->grids_seens[x][y] = v;
	return 0;
}

static int map_set_remember(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool v = lua_toboolean(L, 4);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	map->grids_remembers[x][y] = v;
	return 0;
}

static int map_set_lite(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool v = lua_toboolean(L, 4);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	map->grids_lites[x][y] = v;
	return 0;
}

static int map_clean_seen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_seens[i][j] = 0;
	return 0;
}

static int map_clean_remember(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_remembers[i][j] = FALSE;
	return 0;
}

static int map_clean_lite(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_lites[i][j] = FALSE;
	return 0;
}

static int map_set_scroll(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	map->mx = x;
	map->my = y;
	return 0;
}

GLuint pfftex;
#include "libtcod.h"
#define BYTES_PER_TEXEL 3
#define LAYER(r)	(w * h * r * BYTES_PER_TEXEL)
// 2->1 dimension mapping function
#define TEXEL2(s, t)	(BYTES_PER_TEXEL * (s * w + t))
// 3->1 dimension mapping function
#define TEXEL3(s, t, r)	(TEXEL2(s, t) + LAYER(r))
void doit()
{
	TCOD_noise_t *noise = TCOD_noise_new(3, TCOD_NOISE_DEFAULT_HURST, TCOD_NOISE_DEFAULT_LACUNARITY);
	int w = 128, h = 128, d=128, zoom = 4;
	int x=0, y=0, z=0;
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
				float v = ((TCOD_noise_simplex(noise, p) + 1) / 2) * 255;
				map[TEXEL3(i, j, k)] = (GLubyte)v;
				map[TEXEL3(i, j, k)+1] = (GLubyte)v;
				map[TEXEL3(i, j, k)+2] = (GLubyte)v;
			}
		}
	}

	glGenTextures(1, &pfftex);
	glBindTexture(GL_TEXTURE_3D, pfftex);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage3D(GL_TEXTURE_3D, 0, GL_RGB8, w, h, d, 0, GL_RGB, GL_UNSIGNED_BYTE, map);

	free(map);
}

static int map_to_screen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int i = 0, j = 0;
	float a;

	for (i = map->mx; i < map->mx + map->mwidth; i++)
	{
		for (j = map->my; j < map->my + map->mheight; j++)
		{
			if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h)) continue;

			int dx = x + (i - map->mx) * map->tile_w;
			int dy = y + (j - map->my) * map->tile_h;

			if (map->grids_seens[i][j] || map->grids_remembers[i][j])
			{
				if (map->grids_seens[i][j])
				{
					a = map->shown_a * map->grids_seens[i][j];
					if (map->multidisplay)
					{
						if (map->grids_terrain[i][j].texture)
						{
							map_texture *m = &(map->grids_terrain[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
//glActiveTexture(GL_TEXTURE1);
//glBindTexture(GL_TEXTURE_3D, pfftex);
//glActiveTexture(GL_TEXTURE0);
							glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j].texture);
							if (m->shader) useShader(m->shader, i, j, a);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						if (map->grids_trap[i][j].texture)
						{
							map_texture *m = &(map->grids_trap[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_trap[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						if (map->grids_object[i][j].texture)
						{
							map_texture *m = &(map->grids_object[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_object[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						if (map->grids_actor[i][j].texture)
						{
							map_texture *m = &(map->grids_actor[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_actor[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
					}
					else
					{
						if (map->grids_actor[i][j].texture)
						{
							map_texture *m = &(map->grids_actor[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_actor[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						else if (map->grids_object[i][j].texture)
						{
							map_texture *m = &(map->grids_object[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_object[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						else if (map->grids_trap[i][j].texture)
						{
							map_texture *m = &(map->grids_trap[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_trap[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
						else if (map->grids_terrain[i][j].texture)
						{
							map_texture *m = &(map->grids_terrain[i][j]);
							if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
								glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
							else
								glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
							if (m->shader) useShader(m->shader, i, j, a);
							glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j].texture);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
							if (m->shader) glUseProgramObjectARB(0);
						}
					}
				}
				else
				{
					if (map->grids_terrain[i][j].texture)
					{
						map_texture *m = &(map->grids_terrain[i][j]);
						if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
							glColor4f((map->obscure_r + m->tint_r)/2, (map->obscure_g + m->tint_g)/2, (map->obscure_b + m->tint_b)/2, map->obscure_a);
						else
							glColor4f(map->obscure_r, map->obscure_g, map->obscure_b, map->obscure_a);
						if (m->shader) useShader(m->shader, i, j, a);
						glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j].texture);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
						glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
						glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
						glEnd();
						if (m->shader) glUseProgramObjectARB(0);
					}
				}
			}
		}
	}

	// Restore normal display
	glColor4f(1, 1, 1, 1);
	return 0;
}

static int minimap_to_screen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int mdx = luaL_checknumber(L, 4);
	int mdy = luaL_checknumber(L, 5);
	int mdw = luaL_checknumber(L, 6);
	int mdh = luaL_checknumber(L, 7);
	float transp = luaL_checknumber(L, 8);
	int i = 0, j = 0;

	for (i = mdx; i < mdx + mdw; i++)
	{
		for (j = mdy; j < mdy + mdh; j++)
		{
			if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h)) continue;

			int dx = x + (i - mdx) * map->minimap_gridsize;
			int dy = y + (j - mdy) * map->minimap_gridsize;

			if (map->grids_seens[i][j] || map->grids_remembers[i][j])
			{
				if (map->grids_seens[i][j])
				{
					glColor4f(map->shown_r, map->shown_g, map->shown_b, map->shown_a * transp);
					if ((map->minimap[i][j] & MM_LEVEL_CHANGE) && map->mm_level_change)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_level_change);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_HOSTILE) && map->mm_hostile)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_hostile);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_NEUTRAL) && map->mm_neutral)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_neutral);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_FRIEND) && map->mm_friend)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_friend);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_TRAP) && map->mm_trap)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_trap);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_OBJECT) && map->mm_object)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_object);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_BLOCK) && map->mm_block)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_block);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_FLOOR) && map->mm_floor)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_floor);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
				}
				else
				{
					glColor4f(map->obscure_r, map->obscure_g, map->obscure_b, map->obscure_a * transp);
					if ((map->minimap[i][j] & MM_LEVEL_CHANGE) && map->mm_level_change)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_level_change);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_BLOCK) && map->mm_block)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_block);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
					else if ((map->minimap[i][j] & MM_FLOOR) && map->mm_floor)
					{
						glBindTexture(GL_TEXTURE_2D, map->mm_floor);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-96);
						glTexCoord2f(1,0); glVertex3f(map->minimap_gridsize +dx, 0  +dy,-96);
						glTexCoord2f(1,1); glVertex3f(map->minimap_gridsize +dx, map->minimap_gridsize +dy,-96);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->minimap_gridsize +dy,-96);
						glEnd();
					}
				}
			}
		}
	}

	// Restore normal display
	glColor4f(1, 1, 1, 1);
	return 0;
}

static const struct luaL_reg maplib[] =
{
	{"newMap", map_new},
	{NULL, NULL},
};

static const struct luaL_reg map_reg[] =
{
	{"__gc", map_free},
	{"close", map_free},
	{"setShown", map_set_shown},
	{"setObscure", map_set_obscure},
	{"setGrid", map_set_grid},
	{"cleanSeen", map_clean_seen},
	{"cleanRemember", map_clean_remember},
	{"cleanLite", map_clean_lite},
	{"setSeen", map_set_seen},
	{"setRemember", map_set_remember},
	{"setLite", map_set_lite},
	{"setScroll", map_set_scroll},
	{"toScreen", map_to_screen},
	{"toScreenMiniMap", minimap_to_screen},
	{"setupMiniMap", map_set_minimap},
	{"setupMiniMapGridSize", map_set_minimap_gridsize},
	{NULL, NULL},
};

int luaopen_map(lua_State *L)
{
	auxiliar_newclass(L, "core{map}", map_reg);
//	auxiliar_newclass(L, "core{level}", level_reg);
	luaL_openlib(L, "core.map", maplib, 0);
	return 1;
}
