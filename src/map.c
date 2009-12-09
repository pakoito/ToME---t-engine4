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

	map_type *map = (map_type*)lua_newuserdata(L, sizeof(map_type));
	auxiliar_setclass(L, "core{map}", -1);

	map->w = w;
	map->h = h;
	map->mx = mx;
	map->my = my;
	map->mwidth = mwidth;
	map->mheight = mheight;
	map->grids = calloc(w, sizeof(GLuint*));
	printf("size %d:%d :: %d\n", mwidth, mheight,mwidth * mheight);

	int i;
	for (i = 0; i < w; i++)
	{
		map->grids[i] = calloc(h, sizeof(GLuint));
	}

	map->dlist = glGenLists(1);

	/* New compiled box display list */
	glNewList(map->dlist, GL_COMPILE);
		glBegin(GL_QUADS);
		glTexCoord2f(0,0); glVertex2f(0  , 0  );
		glTexCoord2f(0,1); glVertex2f(0  , 16 );
		glTexCoord2f(1,1); glVertex2f(16 , 16 );
		glTexCoord2f(1,0); glVertex2f(16 , 0  );
		glEnd();
	glEndList( );

	return 1;
}

static int map_free(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int i;

	for (i = 0; i < map->w; i++)
	{
		free(map->grids[i]);
	}
	free(map->grids);

	lua_pushnumber(L, 1);
	return 1;
}

static int map_set_grid(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 4);

	map->grids[x][y] = *t;
}

static int map_set_scroll(lua_State *L)
{
	map_type *map = (map_type*)auxiliar_checkclass(L, "core{map}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	map->mx = x;
	map->my = y;
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
			if ((i >= map->w) || (j >= map->h) || (!map->grids[i][j])) continue;

			int dx = x + (i - map->mx) * 16;
			int dy = y + (j - map->my) * 16;

			glBindTexture(GL_TEXTURE_2D, map->grids[i][j]);
			glBegin(GL_QUADS);
			glTexCoord2f(0,0); glVertex3f(0  +dx, 0  +dy,-99);
			glTexCoord2f(1,0); glVertex3f(16 +dx, 0  +dy,-99);
			glTexCoord2f(1,1); glVertex3f(16 +dx, 16 +dy,-99);
			glTexCoord2f(0,1); glVertex3f(0  +dx, 16 +dy,-99);
			glEnd();
		}
	}
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
	{"setGrid", map_set_grid},
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
