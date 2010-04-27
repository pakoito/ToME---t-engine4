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
#include "map.h"
#include "script.h"
#include <SDL.h>
#include <SDL_ttf.h>

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

	map->multidisplay = multidisplay;
	map->w = w;
	map->h = h;
	map->tile_w = tile_w;
	map->tile_h = tile_h;
	map->mx = mx;
	map->my = my;
	map->mwidth = mwidth;
	map->mheight = mheight;
	map->grids_terrain = calloc(w, sizeof(GLuint*));
	map->grids_actor = calloc(w, sizeof(GLuint*));
	map->grids_trap = calloc(w, sizeof(GLuint*));
	map->grids_object = calloc(w, sizeof(GLuint*));
	map->grids_seens = calloc(w, sizeof(bool*));
	map->grids_remembers = calloc(w, sizeof(bool*));
	map->grids_lites = calloc(w, sizeof(bool*));
	printf("size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	int i;
	for (i = 0; i < w; i++)
	{
		map->grids_terrain[i] = calloc(h, sizeof(GLuint));
		map->grids_actor[i] = calloc(h, sizeof(GLuint));
		map->grids_object[i] = calloc(h, sizeof(GLuint));
		map->grids_trap[i] = calloc(h, sizeof(GLuint));
		map->grids_seens[i] = calloc(h, sizeof(bool));
		map->grids_remembers[i] = calloc(h, sizeof(bool));
		map->grids_lites[i] = calloc(h, sizeof(bool));
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
	}
	free(map->grids_terrain);
	free(map->grids_actor);
	free(map->grids_object);
	free(map->grids_trap);
	free(map->grids_seens);
	free(map->grids_remembers);
	free(map->grids_lites);

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

static int map_set_grid(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	GLuint *g = lua_isnil(L, 4) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 4);
	GLuint *t = lua_isnil(L, 5) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 5);
	GLuint *o = lua_isnil(L, 6) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 6);
	GLuint *a = lua_isnil(L, 7) ? NULL : (GLuint*)auxiliar_checkclass(L, "gl{texture}", 7);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	map->grids_terrain[x][y] = g ? *g : 0;
	map->grids_trap[x][y] = t ? *t : 0;
	map->grids_actor[x][y] = a ? *a : 0;
	map->grids_object[x][y] = o ? *o : 0;
	return 0;
}

static int map_set_seen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool v = lua_toboolean(L, 4);

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
			map->grids_seens[i][j] = FALSE;
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

static int map_to_screen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int i = 0, j = 0;

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
					glColor4f(map->shown_r, map->shown_g, map->shown_b, map->shown_a);

					if (map->multidisplay)
					{
						if (map->grids_terrain[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						if (map->grids_trap[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_trap[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						if (map->grids_object[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_object[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						if (map->grids_actor[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_actor[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
					}
					else
					{
						if (map->grids_actor[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_actor[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						else if (map->grids_object[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_object[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						else if (map->grids_trap[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_trap[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
						else if (map->grids_terrain[i][j])
						{
							glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j]);
							glBegin(GL_QUADS);
							glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
							glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
							glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
							glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
							glEnd();
						}
					}
				}
				else
				{
					glColor4f(map->obscure_r, map->obscure_g, map->obscure_b, map->obscure_a);
					if (map->grids_terrain[i][j])
					{
						glBindTexture(GL_TEXTURE_2D, map->grids_terrain[i][j]);
						glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
						glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
						glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
						glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
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
	{NULL, NULL},
};

int luaopen_map(lua_State *L)
{
	auxiliar_newclass(L, "core{map}", map_reg);
//	auxiliar_newclass(L, "core{level}", level_reg);
	luaL_openlib(L, "core.map", maplib, 0);
	return 1;
}
