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
#include "main.h"
#include "script.h"
//#include "shaders.h"
#include "useshader.h"

#define DO_QUAD(dx, dy, dz, zoom) {\
		glBegin(GL_QUADS); \
		glTexCoord2f(0,0); glVertex3f((dx), (dy),				(dz)); \
		glTexCoord2f(1,0); glVertex3f(map->tile_w * (zoom) + (dx), (dy),			(dz)); \
		glTexCoord2f(1,1); glVertex3f(map->tile_w * (zoom) + (dx), map->tile_h * (zoom) + (dy),	(dz)); \
		glTexCoord2f(0,1); glVertex3f((dx), map->tile_h * (zoom) + (dy),			(dz)); \
		glEnd(); }

static int map_object_new(lua_State *L)
{
	long uid = luaL_checknumber(L, 1);
	int nb_textures = luaL_checknumber(L, 2);
	int i;

	map_object *obj = (map_object*)lua_newuserdata(L, sizeof(map_object));
	auxiliar_setclass(L, "core{mapobj}", -1);
	obj->textures = calloc(nb_textures, sizeof(GLuint));
	obj->textures_is3d = calloc(nb_textures, sizeof(bool));
	obj->nb_textures = nb_textures;
	obj->uid = uid;

	obj->on_seen = lua_toboolean(L, 3);
	obj->on_remember = lua_toboolean(L, 4);
	obj->on_unknown = lua_toboolean(L, 5);

	obj->valid = TRUE;
	obj->dx = luaL_checknumber(L, 6);
	obj->dy = luaL_checknumber(L, 7);
	obj->scale = luaL_checknumber(L, 8);
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

	free(obj->textures);
	free(obj->textures_is3d);

	lua_pushnumber(L, 1);
	return 1;
}

static int map_object_on_seen(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	if (lua_isboolean(L, 2))
	{
		obj->on_seen = lua_toboolean(L, 2);
	}
	lua_pushboolean(L, obj->on_seen);
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

static bool _CheckGL_Error(const char* GLcall, const char* file, const int line)
{
    GLenum errCode;
    if((errCode = glGetError())!=GL_NO_ERROR)
    {
		printf("OPENGL ERROR #%i: (%s) in file %s on line %i\n",errCode,gluErrorString(errCode), file, line);
        printf("OPENGL Call: %s\n",GLcall);
        return FALSE;
    }
    return TRUE;
}

//#define _DEBUG
#ifdef _DEBUG
#define CHECKGL( GLcall )                               		\
    GLcall;                                             		\
    if(!_CheckGL_Error( #GLcall, __FILE__, __LINE__))     		\
    exit(-1);
#else
#define CHECKGL( GLcall)        \
    GLcall;
#endif
static int map_objects_display(lua_State *L)
{
	if (!fbo_active) return 0;

	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	// Setup our FBO
	// WARNING: this is a static, only one FBO is ever made, and never deleted, for some reasons
	// deleting it makes the game crash when doing a chain lightning spell under luajit1 ... (yeah I know .. weird)
	static GLuint fbo = 0;
	if (!fbo) CHECKGL(glGenFramebuffersEXT(1, &fbo));
	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo));

	// Now setup a texture to render to
	GLuint img;
	CHECKGL(glGenTextures(1, &img));
	CHECKGL(glBindTexture(GL_TEXTURE_2D, img));
	CHECKGL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
	CHECKGL(glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, img, 0));

	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT) return 0;

	// Set the viewport and save the old one
	CHECKGL(glPushAttrib(GL_VIEWPORT_BIT));

	CHECKGL(glViewport(0, 0, w, h));
	glMatrixMode(GL_PROJECTION);
	CHECKGL(glPushMatrix());
	glLoadIdentity();
	glOrtho(0, w, 0, h, -101, 101);
	glMatrixMode( GL_MODELVIEW );

	/* Reset The View */
	glLoadIdentity( );

	glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	CHECKGL(glClear(GL_COLOR_BUFFER_BIT));
	CHECKGL(glLoadIdentity());

	/***************************************************
	 * Render to buffer
	 ***************************************************/
	int moid = 3;
	while (lua_isuserdata(L, moid))
	{
		map_object *m = (map_object*)auxiliar_checkclass(L, "core{mapobj}", moid);

		glColor4f(1, 1, 1, 1);

		int z;
		if (m->shader) useShader(m->shader, 1, 1, 1, 1, 1, 1, 1, 1);
		for (z = (!shaders_active) ? 0 : (m->nb_textures - 1); z >= 0; z--)
		{
			if (multitexture_active && shaders_active) glActiveTexture(GL_TEXTURE0+z);
			glBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
		}

		int dx = 0, dy = 0;
		int dz = moid;
		glBegin(GL_QUADS);
		glTexCoord2f(0,0); glVertex3f((dx), (dy),				(dz));
		glTexCoord2f(1,0); glVertex3f(w + (dx), (dy),			(dz));
		glTexCoord2f(1,1); glVertex3f(w + (dx), h + (dy),	(dz));
		glTexCoord2f(0,1); glVertex3f((dx), h + (dy),			(dz));
		glEnd();

		if (m->shader) glUseProgramObjectARB(0);

		moid++;
	}
	/***************************************************
	 ***************************************************/


	// Unbind texture from FBO and then unbind FBO
	CHECKGL(glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0));
	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0));
	// Restore viewport
	CHECKGL(glPopAttrib());

	// Cleanup
	// No, dot not it's a static, see upwards
//	CHECKGL(glDeleteFramebuffersEXT(1, &fbo));

	glMatrixMode(GL_PROJECTION);
	CHECKGL(glPopMatrix());
	glMatrixMode( GL_MODELVIEW );

	glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );


	// Now register the texture to lua
	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);
	*t = img;

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
	int zdepth = luaL_checknumber(L, 9);

	map_type *map = (map_type*)lua_newuserdata(L, sizeof(map_type));
	auxiliar_setclass(L, "core{map}", -1);

	map->obscure_r = map->obscure_g = map->obscure_b = 0.6f;
	map->obscure_a = 1;
	map->shown_r = map->shown_g = map->shown_b = 1;
	map->shown_a = 1;

	map->mm_floor = map->mm_block = map->mm_object = map->mm_trap = map->mm_friend = map->mm_neutral = map->mm_hostile = map->mm_level_change = 0;
	map->minimap_gridsize = 4;

	map->w = w;
	map->h = h;
	map->zdepth = zdepth;
	map->tile_w = tile_w;
	map->tile_h = tile_h;
	map->mx = mx;
	map->my = my;
	map->mwidth = mwidth;
	map->mheight = mheight;
	map->grids= calloc(w, sizeof(map_object***));
	map->grids_seens = calloc(w, sizeof(float*));
	map->grids_remembers = calloc(w, sizeof(bool*));
	map->grids_lites = calloc(w, sizeof(bool*));
	map->minimap = calloc(w, sizeof(unsigned char*));
	printf("C Map size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	int i, j;
	for (i = 0; i < w; i++)
	{
		map->grids[i] = calloc(h, sizeof(map_object**));
		for (j = 0; j < h; j++) map->grids[i][j] = calloc(zdepth, sizeof(map_object*));
		map->grids_seens[i] = calloc(h, sizeof(float));
		map->grids_remembers[i] = calloc(h, sizeof(bool));
		map->grids_lites[i] = calloc(h, sizeof(bool));
		map->minimap[i] = calloc(h, sizeof(unsigned char));
	}

	return 1;
}

static int map_free(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
	{
		for (j = 0; j < map->h; j++) free(map->grids[i][j]);
		free(map->grids[i]);
		free(map->grids_seens[i]);
		free(map->grids_remembers[i]);
		free(map->grids_lites[i]);
		free(map->minimap[i]);
	}
	free(map->grids);
	free(map->grids_seens);
	free(map->grids_remembers);
	free(map->grids_lites);
	free(map->minimap);

	lua_pushnumber(L, 1);
	return 1;
}

static int map_set_zoom(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int tile_w = luaL_checknumber(L, 2);
	int tile_h = luaL_checknumber(L, 3);
	int mwidth = luaL_checknumber(L, 4);
	int mheight = luaL_checknumber(L, 5);
	map->tile_w = tile_w;
	map->tile_h = tile_h;
	map->mwidth = mwidth;
	map->mheight = mheight;
	return 0;
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
	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	unsigned char mm = lua_tonumber(L, 4);

	int i;
	for (i = 0; i < map->zdepth; i++)
	{
		lua_pushnumber(L, i + 1);
		lua_gettable(L, -2);
		map->grids[x][y][i] = lua_isnoneornil(L, -1) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", -1);
		lua_pop(L, 1);
	}

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


inline void display_map_quad(map_type *map, int dx, int dy, float dz, map_object *m, int i, int j, float a, bool obscure) ALWAYS_INLINE;
void display_map_quad(map_type *map, int dx, int dy, float dz, map_object *m, int i, int j, float a, bool obscure)
{
	float r, g, b;
	if (!obscure)
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
		{
			r = (map->shown_r + m->tint_r)/2; g = (map->shown_g + m->tint_g)/2; b = (map->shown_b + m->tint_b)/2;
		}
		else
		{
			r = map->shown_r; g = map->shown_g; b = map->shown_b;
		}
	}
	else
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
		{
			r = (map->obscure_r + m->tint_r)/2; g = (map->obscure_g + m->tint_g)/2; b = (map->obscure_b + m->tint_b)/2;
		}
		else
		{
			r = map->obscure_r; g = map->obscure_g; b = map->obscure_b;
		}
	}

	glLoadName(m->uid);

	glColor4f(r, g, b, (a > 1) ? 1 : ((a < 0) ? 0 : a));

	int z;
	if (m->shader) useShader(m->shader, i, j, map->tile_w, map->tile_h, r, g, b, a);
	for (z = (!shaders_active) ? 0 : (m->nb_textures - 1); z >= 0; z--)
	{
		if (multitexture_active && shaders_active) glActiveTexture(GL_TEXTURE0+z);
		glBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
	}
	DO_QUAD(dx + m->dx, dy + m->dy, z, m->scale);

	if (m->shader) glUseProgramObjectARB(0);

//	glLoadName(0);
}

static int map_to_screen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int i = 0, j = 0, z = 0;

	/* Enables Depth Testing */
	glEnable(GL_DEPTH_TEST);

	for (z = 0; z < map->zdepth; z++)
	{
		for (i = map->mx; i < map->mx + map->mwidth; i++)
		{
			for (j = map->my; j < map->my + map->mheight; j++)
			{
				if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h)) continue;

				int dx = x + (i - map->mx) * map->tile_w;
				int dy = y + (j - map->my) * map->tile_h;
				map_object *mo = map->grids[i][j][z];
				if (!mo) continue;

				if ((mo->on_seen && map->grids_seens[i][j]) || (mo->on_remember && map->grids_remembers[i][j]) || mo->on_unknown)
				{
					if (map->grids_seens[i][j])
					{
						display_map_quad(map, dx, dy, z, mo, i, j, map->shown_a * map->grids_seens[i][j], FALSE);
					}
					else
					{
						display_map_quad(map, dx, dy, z, mo, i, j, map->obscure_a, TRUE);
					}
				}
			}
		}
	}

	// Restore normal display
	glColor4f(1, 1, 1, 1);

	/* Disables Depth Testing, we do not need it for the rest of the display */
	glDisable(GL_DEPTH_TEST);

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
	{"mapObjectsToTexture", map_objects_display},
	{NULL, NULL},
};

static const struct luaL_reg map_reg[] =
{
	{"__gc", map_free},
	{"close", map_free},
	{"setZoom", map_set_zoom},
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
	{"onSeen", map_object_on_seen},
	{NULL, NULL},
};

int luaopen_map(lua_State *L)
{
	auxiliar_newclass(L, "core{map}", map_reg);
	auxiliar_newclass(L, "core{mapobj}", map_object_reg);
	luaL_openlib(L, "core.map", maplib, 0);
	return 1;
}
