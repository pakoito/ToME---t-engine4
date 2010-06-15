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
#include <math.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "map.h"
#include "script.h"
//#include "shaders.h"

extern void useShader(GLuint p, int x, int y, float a);

static int map_object_new(lua_State *L)
{
	int nb_textures = luaL_checknumber(L, 1);
	int i;

	map_object *obj = (map_object*)lua_newuserdata(L, sizeof(map_object));
	auxiliar_setclass(L, "core{mapobj}", -1);
	obj->textures = calloc(nb_textures, sizeof(GLuint));
	obj->textures_is3d = calloc(nb_textures, sizeof(bool));
	obj->nb_textures = nb_textures;

	obj->valid = TRUE;
	obj->shader = 0;
	obj->tint_r = obj->tint_g = obj->tint_b = 1;
	for (i = 0; i < nb_textures; i++)
	{
		obj->textures[i] = 0;
		obj->textures_is3d[i] = FALSE;
	}

	return 1;
}

static int map_object_free(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	int i;

	free(obj->textures);
	free(obj->textures_is3d);

	lua_pushnumber(L, 1);
	return 1;
}

static int map_object_texture(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	int i = luaL_checknumber(L, 2);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 3);
	bool is3d = lua_toboolean(L, 4);
	if (i < 0 || i >= obj->nb_textures) return 0;

//	printf("C Map Object setting texture %d = %d\n", i, *t);
	obj->textures[i] = *t;
	obj->textures_is3d[i] = is3d;
	return 0;
}

static int map_object_shader(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{program}", 2);
	obj->shader = *s;
	return 0;
}

static int map_object_tint(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	float r = luaL_checknumber(L, 2);
	float g = luaL_checknumber(L, 3);
	float b = luaL_checknumber(L, 4);
	obj->tint_r = r;
	obj->tint_g = g;
	obj->tint_b = b;
	return 0;
}

static int map_object_invalid(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	obj->valid = FALSE;
	return 0;
}

static int map_object_is_valid(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	lua_pushboolean(L, obj->valid);
	return 1;
}


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
	map->grids_terrain = calloc(w, sizeof(map_object**));
	map->grids_actor = calloc(w, sizeof(map_object**));
	map->grids_trap = calloc(w, sizeof(map_object**));
	map->grids_object = calloc(w, sizeof(map_object**));
	map->grids_seens = calloc(w, sizeof(float*));
	map->grids_remembers = calloc(w, sizeof(bool*));
	map->grids_lites = calloc(w, sizeof(bool*));
	map->minimap = calloc(w, sizeof(unsigned char*));
	printf("C Map size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	int i;
	for (i = 0; i < w; i++)
	{
		map->grids_terrain[i] = calloc(h, sizeof(map_object*));
		map->grids_actor[i] = calloc(h, sizeof(map_object*));
		map->grids_object[i] = calloc(h, sizeof(map_object*));
		map->grids_trap[i] = calloc(h, sizeof(map_object*));
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

	map_object *g = lua_isnil(L, 4) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", 4);
	map_object *t = lua_isnil(L, 5) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", 5);
	map_object *o = lua_isnil(L, 6) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", 6);
	map_object *a = lua_isnil(L, 7) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", 7);
	unsigned char mm = lua_tonumber(L, 8);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;

	map->grids_terrain[x][y] = g ? g : 0;
	map->grids_trap[x][y] = t ? t : 0;
	map->grids_actor[x][y] = a ? a : 0;
	map->grids_object[x][y] = o ? o : 0;

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

inline void display_map_quad(map_type *map, int dx, int dy, map_object *m, int i, int j, float a, bool obscure)
{
	if (!obscure)
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
			glColor4f((map->shown_r + m->tint_r)/2, (map->shown_g + m->tint_g)/2, (map->shown_b + m->tint_b)/2, a);
		else
			glColor4f(map->shown_r, map->shown_g, map->shown_b, a);
	}
	else
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
			glColor4f((map->obscure_r + m->tint_r)/2, (map->obscure_g + m->tint_g)/2, (map->obscure_b + m->tint_b)/2, a);
		else
			glColor4f(map->obscure_r, map->obscure_g, map->obscure_b, a);
	}
	int z;
	if (m->shader) useShader(m->shader, i, j, a);
	for (z = m->nb_textures - 1; z >= 0; z--)
	{
		glActiveTexture(GL_TEXTURE0+z);
		glBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
	}
	glBegin(GL_QUADS);
	glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
	glTexCoord2f(1,0); glVertex3f(map->tile_w +dx, 0  +dy,-99);
	glTexCoord2f(1,1); glVertex3f(map->tile_w +dx, map->tile_h +dy,-99);
	glTexCoord2f(0,1); glVertex3f(0  +dx, map->tile_h +dy,-99);
	glEnd();
	if (m->shader) glUseProgramObjectARB(0);
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
						if (map->grids_terrain[i][j]) display_map_quad(map, dx, dy, map->grids_terrain[i][j], i, j, a, FALSE);
						if (map->grids_trap[i][j]) display_map_quad(map, dx, dy, map->grids_trap[i][j], i, j, a, FALSE);
						if (map->grids_object[i][j]) display_map_quad(map, dx, dy, map->grids_object[i][j], i, j, a, FALSE);
						if (map->grids_actor[i][j]) display_map_quad(map, dx, dy, map->grids_actor[i][j], i, j, a, FALSE);
					}
					else
					{
						if (map->grids_actor[i][j]) display_map_quad(map, dx, dy, map->grids_actor[i][j], i, j, a, FALSE);
						else if (map->grids_object[i][j]) display_map_quad(map, dx, dy, map->grids_object[i][j], i, j, a, FALSE);
						else if (map->grids_trap[i][j]) display_map_quad(map, dx, dy, map->grids_trap[i][j], i, j, a, FALSE);
						else if (map->grids_terrain[i][j]) display_map_quad(map, dx, dy, map->grids_terrain[i][j], i, j, a, FALSE);
					}
				}
				else
				{
					a = map->obscure_a;
					if (map->grids_terrain[i][j]) display_map_quad(map, dx, dy, map->grids_terrain[i][j], i, j, a, TRUE);
					/*
					a = map->obscure_a;
					if (map->multidisplay)
					{
						if (map->grids_terrain[i][j]) display_map_quad(map, dx, dy, map->grids_terrain[i][j], i, j, a, TRUE);
						if (map->grids_trap[i][j]) display_map_quad(map, dx, dy, map->grids_trap[i][j], i, j, a, TRUE);
						if (map->grids_object[i][j]) display_map_quad(map, dx, dy, map->grids_object[i][j], i, j, a, TRUE);
					}
					else
					{
						if (map->grids_object[i][j]) display_map_quad(map, dx, dy, map->grids_object[i][j], i, j, a, TRUE);
						else if (map->grids_trap[i][j]) display_map_quad(map, dx, dy, map->grids_trap[i][j], i, j, a, TRUE);
						else if (map->grids_terrain[i][j]) display_map_quad(map, dx, dy, map->grids_terrain[i][j], i, j, a, TRUE);
					}*/
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
	{"newObject", map_object_new},
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

static const struct luaL_reg map_object_reg[] =
{
	{"__gc", map_object_free},
	{"texture", map_object_texture},
	{"tint", map_object_tint},
	{"shader", map_object_shader},
	{"invalidate", map_object_invalid},
	{"isValid", map_object_is_valid},
	{NULL, NULL},
};

int luaopen_map(lua_State *L)
{
	auxiliar_newclass(L, "core{map}", map_reg);
	auxiliar_newclass(L, "core{mapobj}", map_object_reg);
	luaL_openlib(L, "core.map", maplib, 0);
	return 1;
}
