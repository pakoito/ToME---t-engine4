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

static int map_object_new(lua_State *L)
{
	long uid = luaL_checknumber(L, 1);
	int nb_textures = luaL_checknumber(L, 2);
	int i;

	map_object *obj = (map_object*)lua_newuserdata(L, sizeof(map_object));
	auxiliar_setclass(L, "core{mapobj}", -1);
	obj->textures = calloc(nb_textures, sizeof(GLuint));
	obj->textures_ref = calloc(nb_textures, sizeof(int));
	obj->textures_is3d = calloc(nb_textures, sizeof(bool));
	obj->nb_textures = nb_textures;
	obj->uid = uid;

	obj->on_seen = lua_toboolean(L, 3);
	obj->on_remember = lua_toboolean(L, 4);
	obj->on_unknown = lua_toboolean(L, 5);

	obj->move_max = 0;

	obj->mm_r = -1;
	obj->mm_g = -1;
	obj->mm_b = -1;

	obj->valid = TRUE;
	obj->dx = luaL_checknumber(L, 6);
	obj->dy = luaL_checknumber(L, 7);
	obj->dw = luaL_checknumber(L, 8);
	obj->dh = luaL_checknumber(L, 9);
	obj->scale = luaL_checknumber(L, 10);
	obj->shader = NULL;
	obj->tint_r = obj->tint_g = obj->tint_b = 1;
	for (i = 0; i < nb_textures; i++)
	{
		obj->textures[i] = 0;
		obj->textures_is3d[i] = FALSE;
		obj->textures_ref[i] = LUA_NOREF;
	}

	obj->next = NULL;

	return 1;
}

static int map_object_free(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	int i;

	for (i = 0; i < obj->nb_textures; i++)
		if (obj->textures_ref[i] != LUA_NOREF)
			luaL_unref(L, LUA_REGISTRYINDEX, obj->textures_ref[i]);

	free(obj->textures);
	free(obj->textures_ref);
	free(obj->textures_is3d);

	if (obj->next)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, obj->next_ref);
		obj->next = NULL;
	}

	lua_pushnumber(L, 1);
	return 1;
}

static int map_object_chain(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	map_object *obj2 = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 2);
	if (obj->next) return 0;
	obj->next = obj2;
	obj->next_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	return 0;
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

	if (obj->textures_ref[i] != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, obj->textures_ref[i]);

	lua_pushvalue(L, 3); // Get the texture
	obj->textures_ref[i] = luaL_ref(L, LUA_REGISTRYINDEX); // Ref the texture
//	printf("C Map Object setting texture %d = %d (ref %x)\n", i, *t, obj->textures_ref[i]);
	obj->textures[i] = *t;
	obj->textures_is3d[i] = is3d;
	return 0;
}

static int map_object_shader(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	shader_type *s = (shader_type*)auxiliar_checkclass(L, "gl{program}", 2);
	obj->shader = s;
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

static int map_object_minimap(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	float r = luaL_checknumber(L, 2);
	float g = luaL_checknumber(L, 3);
	float b = luaL_checknumber(L, 4);
	obj->mm_r = r / 255;
	obj->mm_g = g / 255;
	obj->mm_b = b / 255;
	return 0;
}

static int map_object_print(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	printf("Map object texture 0: %d\n", obj->textures[0]);
	return 0;
}

static int map_object_invalid(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	obj->valid = FALSE;
	return 0;
}

static int map_object_reset_move_anim(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	obj->move_max = 0;
	return 0;
}

static int map_object_set_move_anim(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	// If at rest use satrting point
	if (!obj->move_max)
	{
		obj->oldx = luaL_checknumber(L, 2);
		obj->oldy = luaL_checknumber(L, 3);
	}
	// If already moving, compute starting point
	else
	{
		float nx = luaL_checknumber(L, 4);
		float ny = luaL_checknumber(L, 5);
		float adx = nx - obj->oldx;
		float ady = ny - obj->oldy;
		obj->oldx = adx * obj->move_step / (float)obj->move_max + obj->oldx;
		obj->oldy = ady * obj->move_step / (float)obj->move_max + obj->oldy;
	}
	obj->move_step = 0;
	obj->move_max = luaL_checknumber(L, 6);
	obj->move_blur = lua_tonumber(L, 7); // defaults to 0
	return 0;
}


static int map_object_get_move_anim(lua_State *L)
{
	map_object *obj = (map_object*)auxiliar_checkclass(L, "core{mapobj}", 1);
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 2);
	int i = luaL_checknumber(L, 3);
	int j = luaL_checknumber(L, 4);

	float mapdx = 0, mapdy = 0;
	if (map->move_max)
	{
		float adx = (float)map->mx - map->oldmx;
		float ady = (float)map->my - map->oldmy;
		mapdx = -(adx * map->move_step / (float)map->move_max - adx);
		mapdy = -(ady * map->move_step / (float)map->move_max - ady);
	}

	if (!obj->move_max || obj->display_last == DL_NONE)
	{
		lua_pushnumber(L, mapdx);
		lua_pushnumber(L, mapdy);
	}
	else
	{
		float adx = (float)i - obj->oldx;
		float ady = (float)j - obj->oldy;
		lua_pushnumber(L, mapdx + (adx * obj->move_step / (float)obj->move_max - adx));
		lua_pushnumber(L, mapdy + (ady * obj->move_step / (float)obj->move_max - ady));
	}
	return 2;
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
static int map_objects_toscreen(lua_State *L)
{
	if (!fbo_active) return 0;

	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);

	GLfloat vertices[3*4];
	GLfloat texcoords[2*4] = {
		0, 0,
		1, 0,
		1, 1,
		0, 1,
	};
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};

	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(3, GL_FLOAT, 0, vertices);

	/***************************************************
	 * Render
	 ***************************************************/
	int moid = 5;
	while (lua_isuserdata(L, moid))
	{
		map_object *m = (map_object*)auxiliar_checkclass(L, "core{mapobj}", moid);

		int z;
		if (m->shader) useShader(m->shader, 1, 1, 1, 1, 1, 1, 1, 1);
		for (z = (!shaders_active) ? 0 : (m->nb_textures - 1); z >= 0; z--)
		{
			if (multitexture_active && shaders_active) tglActiveTexture(GL_TEXTURE0+z);
			tglBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
		}

		int dx = x, dy = y;
		int dz = moid;
		vertices[0] = dx; vertices[1] = dy; vertices[2] = dz;
		vertices[3] = w + dx; vertices[4] = dy; vertices[5] = dz;
		vertices[6] = w + dx; vertices[7] = h + dy; vertices[8] = dz;
		vertices[9] = dx; vertices[10] = h + dy; vertices[11] = dz;
		glDrawArrays(GL_QUADS, 0, 4);

		if (m->shader) glUseProgramObjectARB(0);

		moid++;
	}
	/***************************************************
	 ***************************************************/

	return 0;
}

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
	tglBindTexture(GL_TEXTURE_2D, img);
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

	tglClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	CHECKGL(glClear(GL_COLOR_BUFFER_BIT));
	CHECKGL(glLoadIdentity());

	GLfloat vertices[3*4];
	GLfloat texcoords[2*4] = {
		0, 0,
		1, 0,
		1, 1,
		0, 1,
	};
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};

	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(3, GL_FLOAT, 0, vertices);

	/***************************************************
	 * Render to buffer
	 ***************************************************/
	int moid = 3;
	while (lua_isuserdata(L, moid))
	{
		map_object *m = (map_object*)auxiliar_checkclass(L, "core{mapobj}", moid);

		int z;
		if (m->shader) useShader(m->shader, 1, 1, 1, 1, 1, 1, 1, 1);
		for (z = (!shaders_active) ? 0 : (m->nb_textures - 1); z >= 0; z--)
		{
			if (multitexture_active && shaders_active) tglActiveTexture(GL_TEXTURE0+z);
			tglBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
		}

		int dx = 0, dy = 0;
		int dz = moid;
		vertices[0] = dx; vertices[1] = dy; vertices[3] = dz;
		vertices[3] = w + dx; vertices[4] = dy; vertices[5] = dz;
		vertices[6] = w + dx; vertices[7] = h + dy; vertices[8] = dz;
		vertices[9] = dx; vertices[10] = h + dy; vertices[11] = dz;
		glDrawArrays(GL_QUADS, 0, 4);

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

	tglClearColor( 0.0f, 0.0f, 0.0f, 1.0f );


	// Now register the texture to lua
	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);
	*t = img;

	return 1;
}


#define QUADS_PER_BATCH 500

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
	int i, j;

	map_type *map = (map_type*)lua_newuserdata(L, sizeof(map_type));
	auxiliar_setclass(L, "core{map}", -1);

	map->obscure_r = map->obscure_g = map->obscure_b = 0.6f;
	map->obscure_a = 1;
	map->shown_r = map->shown_g = map->shown_b = 1;
	map->shown_a = 1;

	map->minimap_gridsize = 4;

	map->vertices = calloc(2*4*QUADS_PER_BATCH, sizeof(GLfloat)); // 2 coords, 4 vertices per particles
	map->colors = calloc(4*4*QUADS_PER_BATCH, sizeof(GLfloat)); // 4 color data, 4 vertices per particles
	map->texcoords = calloc(2*4*QUADS_PER_BATCH, sizeof(GLfloat));

	map->w = w;
	map->h = h;
	map->zdepth = zdepth;
	map->tile_w = tile_w;
	map->tile_h = tile_h;
	map->move_max = 0;

	// Make up the map objects list, thus we can iterate them later
	lua_newtable(L);
	map->mo_list_ref = luaL_ref(L, LUA_REGISTRYINDEX); // Ref the table

	// In case we can't support NPOT textures round up to nearest POT
	for (i = 1; i <= 3; i++)
	{
		int tw = tile_w * i;
		int realw=1;
		while (realw < tw) realw *= 2;
		map->tex_tile_w[i-1] = (GLfloat)tw / realw;

		int th = tile_h * i;
		int realh=1;
		while (realh < th) realh *= 2;
		map->tex_tile_h[i-1] = (GLfloat)th / realh;
	}

	map->mx = mx;
	map->my = my;
	map->mwidth = mwidth;
	map->mheight = mheight;
	map->grids = calloc(w, sizeof(map_object***));
	map->grids_seens = calloc(w * h, sizeof(float));
	map->grids_remembers = calloc(w, sizeof(bool*));
	map->grids_lites = calloc(w, sizeof(bool*));
	map->minimap = calloc(w, sizeof(unsigned char*));
	printf("C Map size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	glGenTextures(1, &(map->seens_texture));
	tglBindTexture(GL_TEXTURE_2D, map->seens_texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, map->mwidth + 7, map->mheight + 7, 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
	map->seens_map = calloc((map->mwidth + 7)*(map->mheight + 7)*4, sizeof(GLubyte));
	map->seen_changed = TRUE;

	for (i = 0; i < w; i++)
	{
		map->grids[i] = calloc(h, sizeof(map_object**));
		for (j = 0; j < h; j++) map->grids[i][j] = calloc(zdepth, sizeof(map_object*));
//		map->grids_seens[i] = calloc(h, sizeof(float));
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
//		free(map->grids_seens[i]);
		free(map->grids_remembers[i]);
		free(map->grids_lites[i]);
		free(map->minimap[i]);
	}
	free(map->grids);
	free(map->grids_seens);
	free(map->grids_remembers);
	free(map->grids_lites);
	free(map->minimap);

	free(map->colors);
	free(map->texcoords);
	free(map->vertices);

	luaL_unref(L, LUA_REGISTRYINDEX, map->mo_list_ref);

	glDeleteTextures(1, &map->seens_texture);
	free(map->seens_map);

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
	map->seen_changed = TRUE;
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
	map->seen_changed = TRUE;
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
	map->seen_changed = TRUE;
	return 0;
}

static int map_set_minimap_gridsize(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	float s = luaL_checknumber(L, 2);
	map->minimap_gridsize = s;
	return 0;
}

static int map_set_grid(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;

	// Get the mo list
	lua_rawgeti(L, LUA_REGISTRYINDEX, map->mo_list_ref);

	int i;
	for (i = 0; i < map->zdepth; i++)
	{
		// Remove the old object if any from the mo list
		// We use the pointer value directly as an index
		if (map->grids[x][y][i])
		{
#if defined(__PTRDIFF_TYPE__)
			if(sizeof(__PTRDIFF_TYPE__) == sizeof(long int))
				lua_pushnumber(L, (unsigned long int)map->grids[x][y][i]);
			else if(sizeof(__PTRDIFF_TYPE__) == sizeof(long long))
				lua_pushnumber(L, (long long)map->grids[x][y][i]);
			else
				lua_pushnumber(L, (int)map->grids[x][y][i]);
#else
			lua_pushnumber(L, (long long)map->grids[x][y][i]);
#endif
			lua_pushnil(L);
			lua_settable(L, 5); // Access the list of all mos for the map
		}

		lua_pushnumber(L, i + 1);
		lua_gettable(L, 4); // Access the table of mos for this spot
		map->grids[x][y][i] = lua_isnoneornil(L, -1) ? NULL : (map_object*)auxiliar_checkclass(L, "core{mapobj}", -1);

		// Set the object in the mo list
		// We use the pointer value directly as an index
		lua_pushnumber(L, (long)map->grids[x][y][i]);
		lua_pushvalue(L, -2);
		lua_settable(L, 5); // Access the list of all mos for the map

		// Remove the mo and get the next
		lua_pop(L, 1);
	}

	// Pop the mo list
	lua_pop(L, 1);
	return 0;
}

static int map_set_seen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	float v = lua_tonumber(L, 4);

	if (x < 0 || y < 0 || x >= map->w || y >= map->h) return 0;
	map->grids_seens[y*map->w+x] = v;
	map->seen_changed = TRUE;
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
	map->seen_changed = TRUE;
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
	map->seen_changed = TRUE;
	return 0;
}

static int map_clean_seen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_seens[j*map->w+i] = 0;
	map->seen_changed = TRUE;
	return 0;
}

static int map_clean_remember(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_remembers[i][j] = FALSE;
	map->seen_changed = TRUE;
	return 0;
}

static int map_clean_lite(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i, j;

	for (i = 0; i < map->w; i++)
		for (j = 0; j < map->h; j++)
			map->grids_lites[i][j] = FALSE;
	map->seen_changed = TRUE;
	return 0;
}

static int map_get_seensinfo(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	lua_pushnumber(L, map->tile_w);
	lua_pushnumber(L, map->tile_h);
	lua_pushnumber(L, map->seensinfo_w);
	lua_pushnumber(L, map->seensinfo_h);
	return 4;
}

#define SMOOTH_SCROLL()  \
	float animdx = 0, animdy = 0; \
	if (map->move_max) \
	{ \
		map->move_step += nb_keyframes; \
		if (map->move_step >= map->move_max) \
		{ \
			map->move_max = 0; \
			map->oldmx = map->mx; \
			map->oldmy = map->my; \
		} \
 \
		if (map->move_max) \
		{ \
			float adx = (float)map->mx - map->oldmx; \
			float ady = (float)map->my - map->oldmy; \
			animdx = map->tile_w * (adx * map->move_step / (float)map->move_max - adx); \
			animdy = map->tile_h * (ady * map->move_step / (float)map->move_max - ady); \
			mx = map->mx + (int)(adx * map->move_step / (float)map->move_max - adx); \
			my = map->my + (int)(ady * map->move_step / (float)map->move_max - ady); \
		} \
	}


static void map_update_seen_texture(map_type *map)
{
	tglBindTexture(GL_TEXTURE_2D, map->seens_texture);

	int mx = map->used_mx;
	int my = map->used_my;
	GLubyte *seens = map->seens_map;
	int ptr = 0;
	int ii, jj;
	map->seensinfo_w = map->mwidth + 7;
	map->seensinfo_h = map->mheight + 7;

	for (jj = 0; jj < map->mheight + 7; jj++)
	{
		for (ii = 0; ii < map->mwidth + 7; ii++)
		{
			int i = mx - 3 + ii, j = my - 3 + jj;
			if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h))
			{
				seens[ptr] = 0;
				seens[ptr+1] = 0;
				seens[ptr+2] = 0;
				seens[ptr+3] = 255;
				ptr += 4;
				continue;
			}
			float v = map->grids_seens[j*map->w+i] * 255;
			if (v)
			{
				if (v > 255) v = 255;
				if (v < 0) v = 0;
				seens[ptr] = (GLubyte)0;
				seens[ptr+1] = (GLubyte)0;
				seens[ptr+2] = (GLubyte)0;
				seens[ptr+3] = (GLubyte)255-v;
			}
			else if (map->grids_remembers[i][j])
			{
				seens[ptr] = 0;
				seens[ptr+1] = 0;
				seens[ptr+2] = 0;
				seens[ptr+3] = 255 - map->obscure_a * 255;
			}
			else
			{
				seens[ptr] = 0;
				seens[ptr+1] = 0;
				seens[ptr+2] = 0;
				seens[ptr+3] = 255;
			}
			ptr += 4;
		}
	}
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, map->mwidth + 7, map->mheight + 7, GL_BGRA, GL_UNSIGNED_BYTE, seens);
}

static int map_draw_seen_texture(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = lua_tonumber(L, 2);
	int y = lua_tonumber(L, 3);
	int nb_keyframes = 0;
	x += -map->tile_w * 3;
	y += -map->tile_h * 3;
	int w = (map->mwidth + 7) * map->tile_w;
	int h = (map->mheight + 7) * map->tile_h;

	int mx = map->mx;
	int my = map->my;
	SMOOTH_SCROLL();
	x -= animdx;
	y -= animdy;
//	printf("SEEN %3dx%3d :: %fx%f\n",x,y,animdx,animdy);

	tglBindTexture(GL_TEXTURE_2D, map->seens_texture);

	GLfloat texcoords[2*4] = {
		0, 0,
		0, 1,
		1, 1,
		1, 0,
	};
	GLfloat colors[4*4] = {
		1,1,1,1,
		1,1,1,1,
		1,1,1,1,
		1,1,1,1,
	};
	glColorPointer(4, GL_FLOAT, 0, colors);
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);

	GLfloat vertices[2*4] = {
		x, y,
		x, y + h,
		x + w, y + h,
		x + w, y,
	};
	glVertexPointer(2, GL_FLOAT, 0, vertices);

	glDrawArrays(GL_QUADS, 0, 4);
	return 0;
}

static int map_bind_seen_texture(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int unit = luaL_checknumber(L, 2);
	if (unit > 0 && !multitexture_active) return 0;

	if (unit > 0) tglActiveTexture(GL_TEXTURE0+unit);
	glBindTexture(GL_TEXTURE_2D, map->seens_texture);
	if (unit > 0) tglActiveTexture(GL_TEXTURE0);

	return 0;
}

static int map_set_scroll(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int smooth = luaL_checknumber(L, 4);

	if (smooth)
	{
		// Not moving, use starting point
		if (!map->move_max)
		{
			map->oldmx = map->mx;
			map->oldmy = map->my;
		}
		// Already moving, compute starting point
		else
		{
			float adx = map->mx - map->oldmx;
			float ady = map->my - map->oldmy;
			map->oldmx = -adx * map->move_step / (float)map->move_max + map->mx;
			map->oldmy = -ady * map->move_step / (float)map->move_max + map->my;
		}
		map->move_step = 0;
		map->move_max = smooth;
	}

	map->mx = x;
	map->my = y;
	map->seen_changed = TRUE;
	return 0;
}

static int map_get_scroll(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int nb_keyframes = 0;
	int mx = map->mx;
	int my = map->my;
	SMOOTH_SCROLL();
	lua_pushnumber(L, -animdx);
	lua_pushnumber(L, -animdy);
	return 2;
}


#define DO_QUAD(dx, dy, dw, dh, zoom, r, g, b, a, force) {\
	vertices[(*vert_idx)] = (dx); vertices[(*vert_idx)+1] = (dy); \
	vertices[(*vert_idx)+2] = map->tile_w * (dw) * (zoom) + (dx); vertices[(*vert_idx)+3] = (dy); \
	vertices[(*vert_idx)+4] = map->tile_w * (dw) * (zoom) + (dx); vertices[(*vert_idx)+5] = map->tile_h * (dh) * (zoom) + (dy); \
	vertices[(*vert_idx)+6] = (dx); vertices[(*vert_idx)+7] = map->tile_h * (dh) * (zoom) + (dy); \
	\
	texcoords[(*vert_idx)] = 0; texcoords[(*vert_idx)+1] = 0; \
	texcoords[(*vert_idx)+2] = map->tex_tile_w[dw-1]; texcoords[(*vert_idx)+3] = 0; \
	texcoords[(*vert_idx)+4] = map->tex_tile_w[dw-1]; texcoords[(*vert_idx)+5] = map->tex_tile_h[dh-1]; \
	texcoords[(*vert_idx)+6] = 0; texcoords[(*vert_idx)+7] = map->tex_tile_h[dh-1]; \
	\
	colors[(*col_idx)] = r; colors[(*col_idx)+1] = g; colors[(*col_idx)+2] = b; colors[(*col_idx)+3] = (a); \
	colors[(*col_idx)+4] = r; colors[(*col_idx)+5] = g; colors[(*col_idx)+6] = b; colors[(*col_idx)+7] = (a); \
	colors[(*col_idx)+8] = r; colors[(*col_idx)+9] = g; colors[(*col_idx)+10] = b; colors[(*col_idx)+11] = (a); \
	colors[(*col_idx)+12] = r; colors[(*col_idx)+13] = g; colors[(*col_idx)+14] = b; colors[(*col_idx)+15] = (a); \
	\
	(*vert_idx) += 8; \
	(*col_idx) += 16; \
	if ((*vert_idx) >= 8*QUADS_PER_BATCH || force) {\
		glDrawArrays(GL_QUADS, 0, (*vert_idx) / 2); \
		(*vert_idx) = 0; \
		(*col_idx) = 0; \
	} \
}

inline void display_map_quad(GLuint *cur_tex, int *vert_idx, int *col_idx, map_type *map, int dx, int dy, float dz, map_object *m, int i, int j, float a, float seen, int nb_keyframes, bool always_show) ALWAYS_INLINE;
void display_map_quad(GLuint *cur_tex, int *vert_idx, int *col_idx, map_type *map, int dx, int dy, float dz, map_object *m, int i, int j, float a, float seen, int nb_keyframes, bool always_show)
{
	map_object *dm;
	float r, g, b;
	GLfloat *vertices = map->vertices;
	GLfloat *colors = map->colors;
	GLfloat *texcoords = map->texcoords;

	/********************************************************
	 ** Select the color to use
	 ********************************************************/
	if (always_show)
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
		{
			r = (map->shown_r + m->tint_r)/2; g = (map->shown_g + m->tint_g)/2; b = (map->shown_b + m->tint_b)/2;
		}
		else
		{
			r = map->shown_r; g = map->shown_g; b = map->shown_b;
		}
		a = 1;
	}
	else if (seen)
	{
		if (m->tint_r < 1 || m->tint_g < 1 || m->tint_b < 1)
		{
			r = (map->shown_r + m->tint_r)/2; g = (map->shown_g + m->tint_g)/2; b = (map->shown_b + m->tint_b)/2;
		}
		else
		{
			r = map->shown_r; g = map->shown_g; b = map->shown_b;
		}
		r *= seen;
		g *= seen;
		b *= seen;
		a = seen;
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
		a = map->obscure_r;
	}

	/* Reset vertices&all buffers, we are changing texture/shader */
	if ((*cur_tex != m->textures[0]) || m->shader || (m->nb_textures > 1))
	{
		/* Draw remaining ones */
		if (vert_idx) glDrawArrays(GL_QUADS, 0, (*vert_idx) / 2);
		/* Reset */
		(*vert_idx) = 0;
		(*col_idx) = 0;
	}
	if (*cur_tex != m->textures[0])
	{
		glBindTexture(GL_TEXTURE_2D, m->textures[0]);
		*cur_tex = m->textures[0];
	}

	/********************************************************
	 ** Setup all textures we need
	 ********************************************************/
	a = (a > 1) ? 1 : ((a < 0) ? 0 : a);
	int z;
	if (m->shader) useShader(m->shader, i, j, map->tile_w, map->tile_h, r, g, b, a);
	for (z = (!shaders_active) ? 0 : (m->nb_textures - 1); z > 0; z--)
	{
		if (multitexture_active && shaders_active) tglActiveTexture(GL_TEXTURE0+z);
		tglBindTexture(m->textures_is3d[z] ? GL_TEXTURE_3D : GL_TEXTURE_2D, m->textures[z]);
	}
	if (m->nb_textures && multitexture_active && shaders_active) tglActiveTexture(GL_TEXTURE0); // Switch back to default texture unit

	/********************************************************
	 ** Compute/display movement and motion blur
	 ********************************************************/
	float animdx = 0, animdy = 0;
	if (m->display_last == DL_NONE) m->move_max = 0;
	if (m->move_max)
	{
		m->move_step += nb_keyframes;
		if (m->move_step >= m->move_max) m->move_max = 0; // Reset once in place
		if (m->display_last == DL_NONE) m->display_last = DL_TRUE;

		if (m->move_max)
		{
			float adx = (float)i - m->oldx;
			float ady = (float)j - m->oldy;

			// Motion bluuuurr!
			if (m->move_blur)
			{
				int step;
				for (z = 1; z <= m->move_blur; z++)
				{
					step = m->move_step - z;
					if (step >= 0)
					{
						animdx = map->tile_w * (adx * step / (float)m->move_max - adx);
						animdy = map->tile_h * (ady * step / (float)m->move_max - ady);
						dm = m;
						while (dm)
						{
							tglBindTexture(GL_TEXTURE_2D, dm->textures[0]);
							DO_QUAD(dx + dm->dx * map->tile_w + animdx, dy + dm->dy * map->tile_h + animdy, dm->dw, dm->dh, dm->scale, r, g, b, a * 2 / (3 + z), m->next);
							dm = dm->next;
						}
					}
				}
			}

			// Final step
			animdx = map->tile_w * (adx * m->move_step / (float)m->move_max - adx);
			animdy = map->tile_h * (ady * m->move_step / (float)m->move_max - ady);
		}
	}

	/********************************************************
	 ** Display the entity
	 ********************************************************/
	dm = m;
	while (dm)
	{
		tglBindTexture(GL_TEXTURE_2D, dm->textures[0]);
		DO_QUAD(dx + dm->dx * map->tile_w + animdx, dy + dm->dy * map->tile_h + animdy, dm->dw, dm->dh, dm->scale, r, g, b, a, m->next);
		dm = dm->next;
	}

	/********************************************************
	 ** Cleanup
	 ********************************************************/
	if (m->shader || m->nb_textures || m->next)
	{
		/* Draw remaining ones */
		if (vert_idx) glDrawArrays(GL_QUADS, 0, (*vert_idx) / 2);
		/* Reset */
		(*vert_idx) = 0;
		(*col_idx) = 0;
		*cur_tex = 0;
	}
	if (m->shader) glUseProgramObjectARB(0);
	m->display_last = DL_TRUE;
}

#define MIN(a,b) ((a < b) ? a : b)

static int map_to_screen(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int nb_keyframes = luaL_checknumber(L, 4);
	bool always_show = lua_toboolean(L, 5);
	int i = 0, j = 0, z = 0;
	int vert_idx = 0;
	int col_idx = 0;
	GLuint cur_tex = 0;
	int mx = map->mx;
	int my = map->my;

	/* Enables Depth Testing */
	glEnable(GL_DEPTH_TEST);

	GLfloat *vertices = map->vertices;
	GLfloat *colors = map->colors;
	GLfloat *texcoords = map->texcoords;
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);

	// Smooth scrolling
	// If we use shaders for FOV display it means we must uses fbos for smooth scroll too
	SMOOTH_SCROLL();
	x -= animdx;
	y -= animdy;
//	printf("MAP_ %3dx%3d :: %fx%f\n",x,y,animdx,animdy);

	map->used_mx = mx;
	map->used_my = my;

	// Always display some more of the map to make sure we always see it all
	for (z = 0; z < map->zdepth; z++)
	{
		for (j = my - 1; j < my + map->mheight + 2; j++)
		{
			for (i = mx - 1; i < mx + map->mwidth + 2; i++)
			{
				if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h)) continue;

				int dx = x + (i - map->mx) * map->tile_w;
				int dy = y + (j - map->my) * map->tile_h;
				map_object *mo = map->grids[i][j][z];
				if (!mo) continue;

				if ((mo->on_seen && map->grids_seens[j*map->w+i]) || (mo->on_remember && (always_show || map->grids_remembers[i][j])) || mo->on_unknown)
				{
					if (map->grids_seens[j*map->w+i])
					{
						display_map_quad(&cur_tex, &vert_idx, &col_idx, map, dx, dy, z, mo, i, j, 1, map->grids_seens[j*map->w+i], nb_keyframes, always_show);
					}
					else
					{
						display_map_quad(&cur_tex, &vert_idx, &col_idx, map, dx, dy, z, mo, i, j, 1, 0, nb_keyframes, always_show);
					}
				}
			}
		}
	}

	/* Display any leftovers */
	if (vert_idx) glDrawArrays(GL_QUADS, 0, vert_idx / 2);

	// "Decay" displayed status for all mos
	lua_rawgeti(L, LUA_REGISTRYINDEX, map->mo_list_ref);
	lua_pushnil(L);
	while (lua_next(L, -2) != 0)
	{
		map_object *mo = (map_object*)auxiliar_checkclass(L, "core{mapobj}", -1);
		if (mo->display_last == DL_TRUE) mo->display_last = DL_TRUE_LAST;
		else if (mo->display_last == DL_TRUE_LAST) mo->display_last = DL_NONE;
		lua_pop(L, 1); // Remove value, keep key for next iteration
	}

	/* Disables Depth Testing, we do not need it for the rest of the display */
	glDisable(GL_DEPTH_TEST);

//	if (always_show && map->seen_changed)
	if (always_show)
	{
		map_update_seen_texture(map);
		map->seen_changed = FALSE;
	}

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
	int z = 0, i = 0, j = 0;
	int vert_idx = 0;
	int col_idx = 0;
	GLfloat r, g, b, a;

	GLfloat *vertices = map->vertices;
	GLfloat *colors = map->colors;
	GLfloat *texcoords = map->texcoords;
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, 0);

	// Always display some more of the map to make sure we always see it all
	for (z = 0; z < map->zdepth; z++)
	{
		for (i = mdx; i < mdx + mdw; i++)
		{
			for (j = mdy; j < mdy + mdh; j++)
			{
				if ((i < 0) || (j < 0) || (i >= map->w) || (j >= map->h)) continue;

				int dx = x + (i - mdx) * map->minimap_gridsize;
				int dy = y + (j - mdy) * map->minimap_gridsize;
				map_object *mo = map->grids[i][j][z];
				if (!mo || mo->mm_r < 0) continue;

				if ((mo->on_seen && map->grids_seens[j*map->w+i]) || (mo->on_remember && map->grids_remembers[i][j]) || mo->on_unknown)
				{
					if (map->grids_seens[j*map->w+i])
					{
						r = mo->mm_r; g = mo->mm_g; b = mo->mm_b; a = transp;
						colors[col_idx] = r; colors[col_idx+1] = g; colors[col_idx+2] = b; colors[col_idx+3] = (a);
						colors[col_idx+4] = r; colors[col_idx+5] = g; colors[col_idx+6] = b; colors[col_idx+7] = (a);
						colors[col_idx+8] = r; colors[col_idx+9] = g; colors[col_idx+10] = b; colors[col_idx+11] = (a);
						colors[col_idx+12] = r; colors[col_idx+13] = g; colors[col_idx+14] = b; colors[col_idx+15] = (a);
					}
					else
					{
						r = mo->mm_r * 0.6; g = mo->mm_g * 0.6; b = mo->mm_b * 0.6; a = transp * 0.6;
						colors[col_idx] = r; colors[col_idx+1] = g; colors[col_idx+2] = b; colors[col_idx+3] = (a);
						colors[col_idx+4] = r; colors[col_idx+5] = g; colors[col_idx+6] = b; colors[col_idx+7] = (a);
						colors[col_idx+8] = r; colors[col_idx+9] = g; colors[col_idx+10] = b; colors[col_idx+11] = (a);
						colors[col_idx+12] = r; colors[col_idx+13] = g; colors[col_idx+14] = b; colors[col_idx+15] = (a);
					}

					vertices[vert_idx] = (dx); vertices[vert_idx+1] = (dy);
					vertices[vert_idx+2] = map->minimap_gridsize + (dx); vertices[vert_idx+3] = (dy);
					vertices[vert_idx+4] = map->minimap_gridsize + (dx); vertices[vert_idx+5] = map->minimap_gridsize + (dy);
					vertices[vert_idx+6] = (dx); vertices[vert_idx+7] = map->minimap_gridsize + (dy);

					texcoords[vert_idx] = 0; texcoords[vert_idx+1] = 0;
					texcoords[vert_idx+2] = 1; texcoords[vert_idx+3] = 0;
					texcoords[vert_idx+4] = 1; texcoords[vert_idx+5] = 1;
					texcoords[vert_idx+6] = 0; texcoords[vert_idx+7] = 1;

					vert_idx += 8;
					col_idx += 16;
					if (vert_idx >= 8*QUADS_PER_BATCH) {
						glDrawArrays(GL_QUADS, 0, vert_idx / 2);
						vert_idx = 0;
						col_idx = 0;
					}
				}
			}
		}
	}
	if (vert_idx) glDrawArrays(GL_QUADS, 0, vert_idx / 2);

	return 0;
}

static const struct luaL_reg maplib[] =
{
	{"newMap", map_new},
	{"newObject", map_object_new},
	{"mapObjectsToTexture", map_objects_display},
	{"mapObjectsToScreen", map_objects_toscreen},
	{NULL, NULL},
};

static const struct luaL_reg map_reg[] =
{
	{"__gc", map_free},
	{"close", map_free},
//	{"updateSeensTexture", map_update_seen_texture},
	{"bindSeensTexture", map_bind_seen_texture},
	{"drawSeensTexture", map_draw_seen_texture},
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
	{"getSeensInfo", map_get_seensinfo},
	{"setScroll", map_set_scroll},
	{"getScroll", map_get_scroll},
	{"toScreen", map_to_screen},
	{"toScreenMiniMap", minimap_to_screen},
	{"setupMiniMapGridSize", map_set_minimap_gridsize},
	{NULL, NULL},
};

static const struct luaL_reg map_object_reg[] =
{
	{"__gc", map_object_free},
	{"texture", map_object_texture},
	{"chain", map_object_chain},
	{"tint", map_object_tint},
	{"shader", map_object_shader},
	{"print", map_object_print},
	{"invalidate", map_object_invalid},
	{"isValid", map_object_is_valid},
	{"onSeen", map_object_on_seen},
	{"minimap", map_object_minimap},
	{"resetMoveAnim", map_object_reset_move_anim},
	{"setMoveAnim", map_object_set_move_anim},
	{"getMoveAnim", map_object_get_move_anim},
	{NULL, NULL},
};

int luaopen_map(lua_State *L)
{
	auxiliar_newclass(L, "core{map}", map_reg);
	auxiliar_newclass(L, "core{mapobj}", map_object_reg);
	luaL_openlib(L, "core.map", maplib, 0);
	lua_pop(L, 1);
	return 1;
}
