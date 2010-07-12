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
#include "fov/fov.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "script.h"
#include "display.h"
#include "physfs.h"
#include "physfsrwops.h"
#include "SFMT.h"
#include "mzip.h"
#include "main.h"
#include "useshader.h"
#include <math.h>
#include <time.h>

/******************************************************************
 ******************************************************************
 *                              FOV                               *
 ******************************************************************
 ******************************************************************/
struct lua_fovcache
{
	bool *cache;
	int w, h;
};

struct lua_fov
{
	fov_settings_type fov_settings;
	int apply_ref;
	int opaque_ref;
	int cache_ref;
	struct lua_fovcache *cache;
};

static void map_seen(void *m, int x, int y, int dx, int dy, int radius, void *src)
{
	struct lua_fov *fov = (struct lua_fov *)m;
	radius--;
	if (dx*dx + dy*dy <= radius*radius + 1)
	{
		// circular view - can be changed if you like
		lua_rawgeti(L, LUA_REGISTRYINDEX, fov->apply_ref);
		if (fov->cache) lua_rawgeti(L, LUA_REGISTRYINDEX, fov->cache_ref);
		else lua_pushnil(L);
		lua_pushnumber(L, x);
		lua_pushnumber(L, y);
		lua_pushnumber(L, dx);
		lua_pushnumber(L, dy);
		lua_pushnumber(L, dx*dx + dy*dy);
		lua_call(L, 6, 0);
	}
}

static bool map_opaque(void *m, int x, int y)
{
	struct lua_fov *fov = (struct lua_fov *)m;

	if (fov->cache)
	{
		if (x < 0 || y < 0 || x >= fov->cache->w || y >= fov->cache->h) return TRUE;
		return fov->cache->cache[x + y * fov->cache->w];
	}
	else
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, fov->opaque_ref);
		if (fov->cache) lua_rawgeti(L, LUA_REGISTRYINDEX, fov->cache_ref);
		else lua_pushnil(L);
		lua_pushnumber(L, x);
		lua_pushnumber(L, y);
		lua_call(L, 3, 1);
		bool res = lua_toboolean(L, -1);
		lua_pop(L, 1);
		return res;
	}
}

static int lua_new_fov(lua_State *L)
{
	struct lua_fovcache* cache;
	int cache_ref;
	if (lua_isuserdata(L, 1))
	{
		cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 1);
		cache_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		cache_ref = LUA_NOREF;
		cache = NULL;
	}
	int apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	struct lua_fov *fov = (struct lua_fov*)lua_newuserdata(L, sizeof(struct lua_fov));
	auxiliar_setclass(L, "fov{core}", -1);
	fov->apply_ref = apply_ref;
	fov->opaque_ref = opaque_ref;
	fov->cache_ref = cache_ref;
	fov->cache = cache;
	fov_settings_init(&(fov->fov_settings));
	fov_settings_set_opacity_test_function(&(fov->fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov->fov_settings), map_seen);

	return 1;
}

static int lua_free_fov(lua_State *L)
{
	struct lua_fov *fov = (struct lua_fov*)auxiliar_checkclass(L, "fov{core}", 1);
	fov_settings_free(&(fov->fov_settings));
	luaL_unref(L, LUA_REGISTRYINDEX, fov->apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov->opaque_ref);
	if (fov->cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov->cache_ref);
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_fov(lua_State *L)
{
	struct lua_fov *fov = (struct lua_fov*)auxiliar_checkclass(L, "fov{core}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int radius = luaL_checknumber(L, 4);

	fov_circle(&(fov->fov_settings), fov, NULL, x, y, radius+1);
	map_seen(fov, x, y, 0, 0, radius, NULL);
	return 0;
}

static int lua_fov_calc_circle(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int radius = luaL_checknumber(L, 3);
	struct lua_fov fov;
	if (lua_isuserdata(L, 6))
	{
		fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 6);
		fov.cache_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		lua_pop(L, 1);
		fov.cache_ref = LUA_NOREF;
		fov.cache = NULL;
	}
	fov.apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
//	int i= SDL_GetTicks();
	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_seen);
	fov_circle(&(fov.fov_settings), &fov, NULL, x, y, radius+1);
	map_seen(&fov, x, y, 0, 0, radius, NULL);
	fov_settings_free(&(fov.fov_settings));
//	printf("map display ticks %d\n",SDL_GetTicks()-i);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.opaque_ref);
	if (fov.cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov.cache_ref);

	return 0;
}

static int lua_fov_calc_beam(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int radius = luaL_checknumber(L, 3);
	int direction = luaL_checknumber(L, 4);
	float angle = luaL_checknumber(L, 5);
	struct lua_fov fov;
	if (lua_isuserdata(L, 8))
	{
		fov.cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 8);
		fov.cache_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		lua_pop(L, 1);
		fov.cache_ref = LUA_NOREF;
		fov.cache = NULL;
	}
	fov.apply_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.opaque_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	fov.cache = NULL;
	int dir = 0;

	switch (direction)
	{
	case 1: dir = FOV_SOUTHWEST; break;
	case 2: dir = FOV_SOUTH; break;
	case 3: dir = FOV_SOUTHEAST; break;
	case 4: dir = FOV_WEST; break;
	case 6: dir = FOV_EAST; break;
	case 7: dir = FOV_NORTHWEST; break;
	case 8: dir = FOV_NORTH; break;
	case 9: dir = FOV_NORTHEAST; break;
	}

	fov_settings_init(&(fov.fov_settings));
	fov_settings_set_opacity_test_function(&(fov.fov_settings), map_opaque);
	fov_settings_set_apply_lighting_function(&(fov.fov_settings), map_seen);
	fov_beam(&(fov.fov_settings), &fov, NULL, x, y, radius+1, dir, angle);
	map_seen(&fov, x, y, 0, 0, radius, NULL);
	fov_settings_free(&(fov.fov_settings));

	luaL_unref(L, LUA_REGISTRYINDEX, fov.apply_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, fov.opaque_ref);
	if (fov.cache_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, fov.cache_ref);

	return 0;
}

static int lua_distance(lua_State *L)
{
	double x1 = luaL_checknumber(L, 1);
	double y1 = luaL_checknumber(L, 2);
	double x2 = luaL_checknumber(L, 3);
	double y2 = luaL_checknumber(L, 4);

	lua_pushnumber(L, sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)));
	return 1;
}

static int lua_new_fovcache(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int i, j;

	struct lua_fovcache *cache = (struct lua_fovcache*)lua_newuserdata(L, sizeof(struct lua_fovcache));
	auxiliar_setclass(L, "fov{cache}", -1);
	cache->w = x;
	cache->h = y;
	cache->cache = calloc(x * y, sizeof(bool));
	for (i = 0; i < x; i++)
		for (j = 0; j < y; j++)
			cache->cache[i + j * x] = FALSE;

	return 1;
}

static int lua_fovcache_set(lua_State *L)
{
	struct lua_fovcache *cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool opaque = lua_toboolean(L, 4);

	if (x < 0 || y < 0 || x >= cache->w || y >= cache->h) return 0;
	cache->cache[x + y * cache->w] = opaque;

	return 0;
}

static int lua_fovcache_get(lua_State *L)
{
	struct lua_fovcache *cache = (struct lua_fovcache*)auxiliar_checkclass(L, "fov{cache}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	lua_pushboolean(L, cache->cache[x + y * cache->w]);
	return 1;
}

static const struct luaL_reg fovlib[] =
{
	{"new", lua_new_fov},
	{"newCache", lua_new_fovcache},
	{"distance", lua_distance},
	{"calc_circle", lua_fov_calc_circle},
	{"calc_beam", lua_fov_calc_beam},
	{NULL, NULL},
};

static const struct luaL_reg fov_reg[] =
{
	{"__gc", lua_free_fov},
	{"close", lua_free_fov},
	{"__call", lua_fov},
	{NULL, NULL},
};

static const struct luaL_reg fovcache_reg[] =
{
	{"set", lua_fovcache_set},
	{"get", lua_fovcache_get},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                             Mouse                              *
 ******************************************************************
 ******************************************************************/
static int lua_get_mouse(lua_State *L)
{
	int x = 0, y = 0;
	(void)SDL_GetMouseState(&x, &y);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);

	return 2;
}
extern int current_mousehandler;
static int lua_set_current_mousehandler(lua_State *L)
{
	if (current_mousehandler != LUA_NOREF)
		luaL_unref(L, LUA_REGISTRYINDEX, current_mousehandler);

	if (lua_isnil(L, 1))
		current_mousehandler = LUA_NOREF;
	else
		current_mousehandler = luaL_ref(L, LUA_REGISTRYINDEX);

	return 0;
}
static const struct luaL_reg mouselib[] =
{
	{"get", lua_get_mouse},
	{"set_current_handler", lua_set_current_mousehandler},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                              Keys                              *
 ******************************************************************
 ******************************************************************/
extern int current_keyhandler;
static int lua_set_current_keyhandler(lua_State *L)
{
	if (current_keyhandler != LUA_NOREF)
		luaL_unref(L, LUA_REGISTRYINDEX, current_keyhandler);

	if (lua_isnil(L, 1))
		current_keyhandler = LUA_NOREF;
	else
		current_keyhandler = luaL_ref(L, LUA_REGISTRYINDEX);

	return 0;
}
static int lua_get_mod_state(lua_State *L)
{
	const char *mod = luaL_checkstring(L, 1);
	SDLMod smod = SDL_GetModState();

	if (!strcmp(mod, "shift")) lua_pushboolean(L, smod & KMOD_SHIFT);
	else if (!strcmp(mod, "ctrl")) lua_pushboolean(L, smod & KMOD_CTRL);
	else if (!strcmp(mod, "alt")) lua_pushboolean(L, smod & KMOD_ALT);
	else if (!strcmp(mod, "meta")) lua_pushboolean(L, smod & KMOD_META);
	else lua_pushnil(L);

	return 1;
}
static const struct luaL_reg keylib[] =
{
	{"set_current_handler", lua_set_current_keyhandler},
	{"modState", lua_get_mod_state},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                              Game                              *
 ******************************************************************
 ******************************************************************/
extern int current_game;
static int lua_set_current_game(lua_State *L)
{
	if (current_game != LUA_NOREF)
		luaL_unref(L, LUA_REGISTRYINDEX, current_game);

	if (lua_isnil(L, 1))
		current_game = LUA_NOREF;
	else
		current_game = luaL_ref(L, LUA_REGISTRYINDEX);

	return 0;
}
extern bool exit_engine;
static int lua_exit_engine(lua_State *L)
{
	exit_engine = TRUE;
	return 0;
}
extern bool reboot_lua;
static int lua_reboot_lua(lua_State *L)
{
	reboot_lua = TRUE;
	return 0;
}
static const struct luaL_reg gamelib[] =
{
	{"reboot", lua_reboot_lua},
	{"set_current_game", lua_set_current_game},
	{"exit_engine", lua_exit_engine},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                           Display                              *
 ******************************************************************
 ******************************************************************/

static int sdl_fullscreen(lua_State *L)
{
	SDL_WM_ToggleFullScreen(screen);
	return 0;
}

static int sdl_screen_size(lua_State *L)
{
	lua_pushnumber(L, screen->w);
	lua_pushnumber(L, screen->h);
	return 2;
}

static int sdl_new_font(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);
	int size = luaL_checknumber(L, 2);

	TTF_Font **f = (TTF_Font**)lua_newuserdata(L, sizeof(TTF_Font*));
	auxiliar_setclass(L, "sdl{font}", -1);

	*f = TTF_OpenFontRW(PHYSFSRWOPS_openRead(name), TRUE, size);

	return 1;
}

static int sdl_free_font(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	TTF_CloseFont(*f);
	lua_pushnumber(L, 1);
	return 1;
}

static int sdl_font_size(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	const char *str = luaL_checkstring(L, 2);
	int w, h;

	if (!TTF_SizeUTF8(*f, str, &w, &h))
	{
		lua_pushnumber(L, w);
		lua_pushnumber(L, h);
		return 2;
	}
	return 0;
}

static int sdl_font_height(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	lua_pushnumber(L, TTF_FontHeight(*f));
	return 1;
}

static int sdl_font_lineskip(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	lua_pushnumber(L, TTF_FontLineSkip(*f));
	return 1;
}

static int sdl_surface_drawstring(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 2);
	const char *str = luaL_checkstring(L, 3);
	int x = luaL_checknumber(L, 4);
	int y = luaL_checknumber(L, 5);
	int r = luaL_checknumber(L, 6);
	int g = luaL_checknumber(L, 7);
	int b = luaL_checknumber(L, 8);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Solid(*f, str, color);
	if (txt)
	{
		sdlDrawImage(*s, txt, x, y);
		SDL_FreeSurface(txt);
	}

	return 0;
}

static int sdl_surface_drawstring_aa(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 2);
	const char *str = luaL_checkstring(L, 3);
	int x = luaL_checknumber(L, 4);
	int y = luaL_checknumber(L, 5);
	int r = luaL_checknumber(L, 6);
	int g = luaL_checknumber(L, 7);
	int b = luaL_checknumber(L, 8);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Blended(*f, str, color);
	if (txt)
	{
		sdlDrawImage(*s, txt, x, y);
		SDL_FreeSurface(txt);
	}

	return 0;
}

static int sdl_surface_drawstring_newsurface(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	const char *str = luaL_checkstring(L, 2);
	int r = luaL_checknumber(L, 3);
	int g = luaL_checknumber(L, 4);
	int b = luaL_checknumber(L, 5);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Solid(*f, str, color);
	if (txt)
	{
		SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
		auxiliar_setclass(L, "sdl{surface}", -1);
		*s = SDL_DisplayFormatAlpha(txt);
		SDL_FreeSurface(txt);
		return 1;
	}

	lua_pushnil(L);
	return 1;
}


static int sdl_surface_drawstring_newsurface_aa(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	const char *str = luaL_checkstring(L, 2);
	int r = luaL_checknumber(L, 3);
	int g = luaL_checknumber(L, 4);
	int b = luaL_checknumber(L, 5);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Blended(*f, str, color);
	if (txt)
	{
		SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
		auxiliar_setclass(L, "sdl{surface}", -1);
		*s = SDL_DisplayFormatAlpha(txt);
		SDL_FreeSurface(txt);
		return 1;
	}

	lua_pushnil(L);
	return 1;
}



static int sdl_new_tile(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 3);
	const char *str = luaL_checkstring(L, 4);
	int x = luaL_checknumber(L, 5);
	int y = luaL_checknumber(L, 6);
	int r = luaL_checknumber(L, 7);
	int g = luaL_checknumber(L, 8);
	int b = luaL_checknumber(L, 9);
	int br = luaL_checknumber(L, 10);
	int bg = luaL_checknumber(L, 11);
	int bb = luaL_checknumber(L, 12);
	int alpha = luaL_checknumber(L, 13);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Blended(*f, str, color);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	Uint32 rmask, gmask, bmask, amask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
	rmask = 0xff000000;
	gmask = 0x00ff0000;
	bmask = 0x0000ff00;
	amask = 0x000000ff;
#else
	rmask = 0x000000ff;
	gmask = 0x0000ff00;
	bmask = 0x00ff0000;
	amask = 0xff000000;
#endif

	*s = SDL_CreateRGBSurface(
		SDL_SWSURFACE | SDL_SRCALPHA,
		w,
		h,
		32,
		rmask, gmask, bmask, amask
		);

	SDL_FillRect(*s, NULL, SDL_MapRGBA((*s)->format, br, bg, bb, alpha));

	if (txt)
	{
		if (!alpha) SDL_SetAlpha(txt, 0, 0);
		sdlDrawImage(*s, txt, x, y);
		SDL_FreeSurface(txt);
	}

	return 1;
}

static int sdl_new_surface(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	Uint32 rmask, gmask, bmask, amask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
	rmask = 0xff000000;
	gmask = 0x00ff0000;
	bmask = 0x0000ff00;
	amask = 0x000000ff;
#else
	rmask = 0x000000ff;
	gmask = 0x0000ff00;
	bmask = 0x00ff0000;
	amask = 0xff000000;
#endif

	*s = SDL_CreateRGBSurface(
		SDL_SWSURFACE | SDL_SRCALPHA,
		w,
		h,
		32,
		rmask, gmask, bmask, amask
		);

        if (s == NULL)
          printf("ERROR : SDL_CreateRGBSurface : %s\n",SDL_GetError());

	return 1;
}

static int sdl_load_image(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	*s = IMG_Load_RW(PHYSFSRWOPS_openRead(name), TRUE);
	if (!*s) return 0;

	return 1;
}

static int sdl_free_surface(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	SDL_FreeSurface(*s);
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_display_char(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	const char *c = luaL_checkstring(L, 2);
	int x = luaL_checknumber(L, 3);
	int y = luaL_checknumber(L, 4);
	int r = luaL_checknumber(L, 5);
	int g = luaL_checknumber(L, 6);
	int b = luaL_checknumber(L, 7);

	display_put_char(*s, c[0], x, y, r, g, b);

	return 0;
}

static int sdl_surface_erase(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	int r = lua_tonumber(L, 2);
	int g = lua_tonumber(L, 3);
	int b = lua_tonumber(L, 4);
	int a = lua_isnumber(L, 5) ? lua_tonumber(L, 5) : 255;
	if (lua_isnumber(L, 6))
	{
		SDL_Rect rect;
		rect.x = lua_tonumber(L, 6);
		rect.y = lua_tonumber(L, 7);
		rect.w = lua_tonumber(L, 8);
		rect.h = lua_tonumber(L, 9);
		SDL_FillRect(*s, &rect, SDL_MapRGBA((*s)->format, r, g, b, a));
	}
	else
		SDL_FillRect(*s, NULL, SDL_MapRGBA((*s)->format, r, g, b, a));
	return 0;
}

static int sdl_surface_get_size(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	lua_pushnumber(L, (*s)->w);
	lua_pushnumber(L, (*s)->h);
	return 2;
}


static void draw_textured_quad(int x, int y, int w, int h) {
	// In case we can't support NPOT textures, the tex coords will be different
	// it might be more elegant to store the actual texture width/height somewhere.
	// it's possible to ask opengl for it but I have a suspicion that is slow.
	int realw=1;
	int realh=1;

	while (realw < w) realw *= 2;
	while (realh < h) realh *= 2;

	GLfloat texw = (GLfloat)w/realw;
	GLfloat texh = (GLfloat)h/realh;

	glBegin( GL_QUADS );
	glTexCoord2f(0,0); glVertex2f(0  + x, 0  + y);
	glTexCoord2f(0,texh); glVertex2f(0  + x, h + y);
	glTexCoord2f(texw,texh); glVertex2f(w + x, h + y);
	glTexCoord2f(texw,0); glVertex2f(w + x, 0  + y);
	glEnd( );
}

static GLenum sdl_gl_texture_format(SDL_Surface *s) {
	// get the number of channels in the SDL surface
	GLint nOfColors = s->format->BytesPerPixel;
	GLenum texture_format;
	if (nOfColors == 4)     // contains an alpha channel
	{
		if (s->format->Rmask == 0x000000ff)
			texture_format = GL_RGBA;
		else
			texture_format = GL_BGRA;
	} else if (nOfColors == 3)     // no alpha channel
	{
		if (s->format->Rmask == 0x000000ff)
			texture_format = GL_RGB;
		else
			texture_format = GL_BGR;
	} else {
		printf("warning: the image is not truecolor..  this will probably break %d\n", nOfColors);
		// this error should not go unhandled
	}

	return texture_format;
}

// allocate memory for a texture without copying pixels in
// caller binds texture
static void make_texture_for_surface(SDL_Surface *s) {
	// Paramétrage de la texture.
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	// get the number of channels in the SDL surface
	GLint nOfColors = s->format->BytesPerPixel;
	GLenum texture_format = sdl_gl_texture_format(s);

	// In case we can't support NPOT textures round up to nearest POT
	int realw=1;
	int realh=1;

	while (realw < s->w) realw *= 2;
	while (realh < s->h) realh *= 2;

	//printf("request size (%d,%d), producing size (%d,%d)\n",s->w,s->h,realw,realh);

	glTexImage2D(GL_TEXTURE_2D, 0, nOfColors, realw, realh, 0, texture_format, GL_UNSIGNED_BYTE, NULL);

	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("make_texture_for_surface: glTexImage2D : %s\n",gluErrorString(err));
	}
}

// copy pixels into previous allocated surface
static void copy_surface_to_texture(SDL_Surface *s) {
	GLenum texture_format = sdl_gl_texture_format(s);

	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, s->w, s->h, texture_format, GL_UNSIGNED_BYTE, s->pixels);

	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("copy_surface_to_texture : glTexSubImage2D : %s\n",gluErrorString(err));
	}
}

static int sdl_surface_toscreen(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	if (lua_isnumber(L, 4))
	{
		float r = luaL_checknumber(L, 4);
		float g = luaL_checknumber(L, 5);
		float b = luaL_checknumber(L, 6);
		float a = luaL_checknumber(L, 7);
		glColor4f(r, g, b, a);
	}

	GLuint t;
	glGenTextures(1, &t);
	glBindTexture(GL_TEXTURE_2D, t);

	make_texture_for_surface(*s);
	copy_surface_to_texture(*s);
	draw_textured_quad(x,y,(*s)->w,(*s)->h);

	glDeleteTextures(1, &t);

	if (lua_isnumber(L, 4)) glColor4f(1, 1, 1, 1);

	return 0;
}

static int sdl_surface_toscreen_with_texture(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 2);
	int x = luaL_checknumber(L, 3);
	int y = luaL_checknumber(L, 4);
	if (lua_isnumber(L, 5))
	{
		float r = luaL_checknumber(L, 5);
		float g = luaL_checknumber(L, 6);
		float b = luaL_checknumber(L, 7);
		float a = luaL_checknumber(L, 8);
		glColor4f(r, g, b, a);
	}

	glBindTexture(GL_TEXTURE_2D, *t);

	copy_surface_to_texture(*s);
	draw_textured_quad(x,y,(*s)->w,(*s)->h);

	if (lua_isnumber(L, 5)) glColor4f(1, 1, 1, 1);

	return 0;
}

static int sdl_surface_to_texture(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);

	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);

	glGenTextures(1, t);
	glBindTexture(GL_TEXTURE_2D, *t);

	make_texture_for_surface(*s);
	copy_surface_to_texture(*s);

	return 1;
}

static int sdl_surface_merge(lua_State *L)
{
	SDL_Surface **dst = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	SDL_Surface **src = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 2);
	int x = luaL_checknumber(L, 3);
	int y = luaL_checknumber(L, 4);
	if (dst && *dst && src && *src)
	{
		sdlDrawImage(*dst, *src, x, y);
	}
	return 0;
}

static int sdl_surface_alpha(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	int a = luaL_checknumber(L, 2);
	SDL_SetAlpha(*s, SDL_SRCALPHA | SDL_RLEACCEL, (a < 0) ? 0 : (a > 255) ? 255 : a);
	return 0;
}

static int sdl_free_texture(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	glDeleteTextures(1, t);
	lua_pushnumber(L, 1);
	return 1;
}

static int sdl_texture_toscreen(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	if (lua_isnumber(L, 6))
	{
		float r = luaL_checknumber(L, 6);
		float g = luaL_checknumber(L, 7);
		float b = luaL_checknumber(L, 8);
		float a = luaL_checknumber(L, 9);
		glColor4f(r, g, b, a);
	}

	glBindTexture(GL_TEXTURE_2D, *t);
	glBegin( GL_QUADS );                 /* Draw A Quad              */
	glTexCoord2f(0,0); glVertex2f(0  + x, 0  + y);
	glTexCoord2f(0,1); glVertex2f(0  + x, h + y);
	glTexCoord2f(1,1); glVertex2f(w + x, h + y);
	glTexCoord2f(1,0); glVertex2f(w + x, 0  + y);
	glEnd( );                            /* Done Drawing The Quad    */

	if (lua_isnumber(L, 6)) glColor4f(1, 1, 1, 1);
	return 0;
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

static int sdl_texture_outline(lua_State *L)
{
	if (!fbo_active) return 0;

	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	float r = luaL_checknumber(L, 6);
	float g = luaL_checknumber(L, 7);
	float b = luaL_checknumber(L, 8);
	float a = luaL_checknumber(L, 9);

	// Setup our FBO
	// WARNING: this is a static, only one FBO is ever made, and never deleted, for some reasons
	// deleting it makes the game crash when doing a chain lightning spell under luajit1 ... (yeah I know .. weird)
	static GLuint fbo = 0;
	if (!fbo) CHECKGL(glGenFramebuffersEXT(1, &fbo));
	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo));

	// Now setup a texture to render to
	GLuint *img = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);
	CHECKGL(glGenTextures(1, img));
	CHECKGL(glBindTexture(GL_TEXTURE_2D, *img));
	CHECKGL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
	CHECKGL(glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, *img, 0));

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

	/* Render to buffer */
	CHECKGL(glBindTexture(GL_TEXTURE_2D, *t));
	CHECKGL(glColor4f(r, g, b, a));
	glBegin(GL_QUADS);
	glTexCoord2f(0,0); glVertex3f(0+x, 0+y, -1);
	glTexCoord2f(1,0); glVertex3f(w+x, 0+y, -1);
	glTexCoord2f(1,1); glVertex3f(w+x, h+y, -1);
	glTexCoord2f(0,1); glVertex3f(0+x, h+y, -1);
	glEnd();

	CHECKGL(glColor4f(1, 1, 1, 1));
	glBegin(GL_QUADS);
	glTexCoord2f(0,0); glVertex3f(0, 0, 0);
	glTexCoord2f(1,0); glVertex3f(w, 0, 0);
	glTexCoord2f(1,1); glVertex3f(w, h, 0);
	glTexCoord2f(0,1); glVertex3f(0, h, 0);
	glEnd();

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

	return 1;
}

static int sdl_set_window_title(lua_State *L)
{
	const char *title = luaL_checkstring(L, 1);
	SDL_WM_SetCaption(title, NULL);
	return 0;
}

static int sdl_set_window_size(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	bool fullscreen = lua_toboolean(L, 3);

	do_resize(w, h, fullscreen);

	lua_pushboolean(L, TRUE);
	return 1;
}

extern void on_redraw();
static int sdl_redraw_screen(lua_State *L)
{
	on_redraw();
	return 0;
}


/**************************************************************
 * Framebuffer Objects
 **************************************************************/
typedef struct
{
	GLuint fbo;
	GLuint texture;
	int w, h;
} lua_fbo;


static int gl_new_fbo(lua_State *L)
{
	if (!fbo_active) return 0;

	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	lua_fbo *fbo = (lua_fbo*)lua_newuserdata(L, sizeof(lua_fbo));
	auxiliar_setclass(L, "gl{fbo}", -1);
	fbo->w = w;
	fbo->h = h;

	CHECKGL(glGenFramebuffersEXT(1, &(fbo->fbo)));
	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo));

	// Now setup a texture to render to
	CHECKGL(glGenTextures(1, &(fbo->texture)));
	CHECKGL(glBindTexture(GL_TEXTURE_2D, fbo->texture));
	CHECKGL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT));
	CHECKGL(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
	CHECKGL(glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, fbo->texture, 0));

	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT) return 0;

	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0));

	return 1;
}

static int gl_free_fbo(lua_State *L)
{
	lua_fbo *fbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 1);

	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo));
	CHECKGL(glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0));
	CHECKGL(glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0));

	CHECKGL(glDeleteTextures(1, &(fbo->texture)));
	CHECKGL(glDeleteFramebuffersEXT(1, &(fbo->fbo)));

	lua_pushnumber(L, 1);
	return 1;
}

static int gl_fbo_use(lua_State *L)
{
	lua_fbo *fbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 1);
	bool active = lua_toboolean(L, 2);

	if (active)
	{
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo);

		// Set the viewport and save the old one
		glPushAttrib(GL_VIEWPORT_BIT);

		glViewport(0, 0, fbo->w, fbo->h);
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		glOrtho(0, fbo->w, fbo->h, 0, -101, 101);
		glMatrixMode(GL_MODELVIEW);

		// Reset The View
		glLoadIdentity();

		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
	}
	else
	{
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);

		// Restore viewport
		glPopAttrib();

		// Unbind texture from FBO and then unbind FBO
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

	}
	return 0;
}

static int gl_fbo_toscreen(lua_State *L)
{
	lua_fbo *fbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	float r = 1, g = 1, b = 1, a = 1;
	if (lua_isnumber(L, 7))
	{
		r = luaL_checknumber(L, 7);
		g = luaL_checknumber(L, 8);
		b = luaL_checknumber(L, 9);
		a = luaL_checknumber(L, 10);
		glColor4f(r, g, b, a);
	}
	if (lua_isuserdata(L, 6))
	{
		GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{program}", 6);
		useShader(*s, 0, 0, w, h, r, g, b, a);
	}

	glDisable(GL_BLEND);
	glBindTexture(GL_TEXTURE_2D, fbo->texture);
	glBegin( GL_QUADS );                 /* Draw A Quad              */
	glTexCoord2f(0,1); glVertex2f(0  + x, 0  + y);
	glTexCoord2f(0,0); glVertex2f(0  + x, h + y);
	glTexCoord2f(1,0); glVertex2f(w + x, h + y);
	glTexCoord2f(1,1); glVertex2f(w + x, 0  + y);
	glEnd( );                            /* Done Drawing The Quad    */

	if (lua_isuserdata(L, 6)) glUseProgramObjectARB(0);
	if (lua_isnumber(L, 7)) glColor4f(1, 1, 1, 1);
	glEnable(GL_BLEND);
	return 0;
}


static const struct luaL_reg displaylib[] =
{
	{"forceRedraw", sdl_redraw_screen},
	{"fullscreen", sdl_fullscreen},
	{"size", sdl_screen_size},
	{"newFont", sdl_new_font},
	{"newSurface", sdl_new_surface},
	{"newTile", sdl_new_tile},
	{"newFBO", gl_new_fbo},
	{"drawStringNewSurface", sdl_surface_drawstring_newsurface},
	{"drawStringBlendedNewSurface", sdl_surface_drawstring_newsurface_aa},
	{"loadImage", sdl_load_image},
	{"setWindowTitle", sdl_set_window_title},
	{"setWindowSize", sdl_set_window_size},
	{NULL, NULL},
};

static const struct luaL_reg sdl_surface_reg[] =
{
	{"__gc", sdl_free_surface},
	{"close", sdl_free_surface},
	{"erase", sdl_surface_erase},
	{"getSize", sdl_surface_get_size},
	{"merge", sdl_surface_merge},
	{"toScreen", sdl_surface_toscreen},
	{"toScreenWithTexture", sdl_surface_toscreen_with_texture},
	{"putChar", lua_display_char},
	{"drawString", sdl_surface_drawstring},
	{"drawStringBlended", sdl_surface_drawstring_aa},
	{"alpha", sdl_surface_alpha},
	{"glTexture", sdl_surface_to_texture},
	{NULL, NULL},
};

static const struct luaL_reg sdl_texture_reg[] =
{
	{"__gc", sdl_free_texture},
	{"close", sdl_free_texture},
	{"toScreen", sdl_texture_toscreen},
	{"makeOutline", sdl_texture_outline},
	{NULL, NULL},
};

static const struct luaL_reg sdl_font_reg[] =
{
	{"__gc", sdl_free_font},
	{"close", sdl_free_font},
	{"size", sdl_font_size},
	{"height", sdl_font_height},
	{"lineSkip", sdl_font_lineskip},
	{NULL, NULL},
};

static const struct luaL_reg gl_fbo_reg[] =
{
	{"__gc", gl_free_fbo},
	{"toScreen", gl_fbo_toscreen},
	{"use", gl_fbo_use},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                              RNG                               *
 ******************************************************************
 ******************************************************************/

static int rng_float(lua_State *L)
{
	float min = luaL_checknumber(L, 1);
	float max = luaL_checknumber(L, 2);
	lua_pushnumber(L, genrand_real(min, max));
	return 1;
}

static int rng_dice(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int i, res = 0;
	for (i = 0; i < x; i++)
		res += 1 + rand_div(y);
	lua_pushnumber(L, res);
	return 1;
}

static int rng_range(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int res = x + rand_div(1 + y - x);
	lua_pushnumber(L, res);
	return 1;
}

static int rng_avg(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int nb = 2;
	double res = 0;
	int i;
	if (lua_isnumber(L, 3)) nb = luaL_checknumber(L, 3);
	for (i = 0; i < nb; i++)
	{
		int r = x + rand_div(1 + y - x);
		res += r;
	}
	lua_pushnumber(L, res / (double)nb);
	return 1;
}

static int rng_call(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	if (lua_isnumber(L, 2))
	{
		int y = luaL_checknumber(L, 2);
		int res = x + rand_div(1 + y - x);
		lua_pushnumber(L, res);
	}
	else
	{
		lua_pushnumber(L, rand_div(x));
	}
	return 1;
}

static int rng_seed(lua_State *L)
{
	int seed = luaL_checknumber(L, 1);
	if (seed>=0)
		init_gen_rand(seed);
	else
		init_gen_rand(time(NULL));
	return 0;
}

static int rng_chance(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	lua_pushboolean(L, rand_div(x) == 0);
	return 1;
}

static int rng_percent(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	lua_pushboolean(L, rand_div(100) < x);
	return 1;
}

/*
 * The number of entries in the "randnor_table"
 */
#define RANDNOR_NUM	256

/*
 * The standard deviation of the "randnor_table"
 */
#define RANDNOR_STD	64

/*
 * The normal distribution table for the "randnor()" function (below)
 */
static int randnor_table[RANDNOR_NUM] =
{
	206, 613, 1022, 1430, 1838, 2245, 2652, 3058,
	3463, 3867, 4271, 4673, 5075, 5475, 5874, 6271,
	6667, 7061, 7454, 7845, 8234, 8621, 9006, 9389,
	9770, 10148, 10524, 10898, 11269, 11638, 12004, 12367,
	12727, 13085, 13440, 13792, 14140, 14486, 14828, 15168,
	15504, 15836, 16166, 16492, 16814, 17133, 17449, 17761,
	18069, 18374, 18675, 18972, 19266, 19556, 19842, 20124,
	20403, 20678, 20949, 21216, 21479, 21738, 21994, 22245,

	22493, 22737, 22977, 23213, 23446, 23674, 23899, 24120,
	24336, 24550, 24759, 24965, 25166, 25365, 25559, 25750,
	25937, 26120, 26300, 26476, 26649, 26818, 26983, 27146,
	27304, 27460, 27612, 27760, 27906, 28048, 28187, 28323,
	28455, 28585, 28711, 28835, 28955, 29073, 29188, 29299,
	29409, 29515, 29619, 29720, 29818, 29914, 30007, 30098,
	30186, 30272, 30356, 30437, 30516, 30593, 30668, 30740,
	30810, 30879, 30945, 31010, 31072, 31133, 31192, 31249,

	31304, 31358, 31410, 31460, 31509, 31556, 31601, 31646,
	31688, 31730, 31770, 31808, 31846, 31882, 31917, 31950,
	31983, 32014, 32044, 32074, 32102, 32129, 32155, 32180,
	32205, 32228, 32251, 32273, 32294, 32314, 32333, 32352,
	32370, 32387, 32404, 32420, 32435, 32450, 32464, 32477,
	32490, 32503, 32515, 32526, 32537, 32548, 32558, 32568,
	32577, 32586, 32595, 32603, 32611, 32618, 32625, 32632,
	32639, 32645, 32651, 32657, 32662, 32667, 32672, 32677,

	32682, 32686, 32690, 32694, 32698, 32702, 32705, 32708,
	32711, 32714, 32717, 32720, 32722, 32725, 32727, 32729,
	32731, 32733, 32735, 32737, 32739, 32740, 32742, 32743,
	32745, 32746, 32747, 32748, 32749, 32750, 32751, 32752,
	32753, 32754, 32755, 32756, 32757, 32757, 32758, 32758,
	32759, 32760, 32760, 32761, 32761, 32761, 32762, 32762,
	32763, 32763, 32763, 32764, 32764, 32764, 32764, 32765,
	32765, 32765, 32765, 32766, 32766, 32766, 32766, 32767,
};


/*
 * Generate a random integer number of NORMAL distribution
 *
 * The table above is used to generate a psuedo-normal distribution,
 * in a manner which is much faster than calling a transcendental
 * function to calculate a true normal distribution.
 *
 * Basically, entry 64*N in the table above represents the number of
 * times out of 32767 that a random variable with normal distribution
 * will fall within N standard deviations of the mean.  That is, about
 * 68 percent of the time for N=1 and 95 percent of the time for N=2.
 *
 * The table above contains a "faked" final entry which allows us to
 * pretend that all values in a normal distribution are strictly less
 * than four standard deviations away from the mean.  This results in
 * "conservative" distribution of approximately 1/32768 values.
 *
 * Note that the binary search takes up to 16 quick iterations.
 */
static int rng_normal(lua_State *L)
{
	int mean = luaL_checknumber(L, 1);
	int stand = luaL_checknumber(L, 2);
	int tmp;
	int offset;

	int low = 0;
	int high = RANDNOR_NUM;

	/* Paranoia */
	if (stand < 1)
	{
		lua_pushnumber(L, mean);
		return 1;
	}

	/* Roll for probability */
	tmp = (int)rand_div(32768);

	/* Binary Search */
	while (low < high)
	{
		long mid = (low + high) >> 1;

		/* Move right if forced */
		if (randnor_table[mid] < tmp)
		{
			low = mid + 1;
		}

		/* Move left otherwise */
		else
		{
			high = mid;
		}
	}

	/* Convert the index into an offset */
	offset = (long)stand * (long)low / RANDNOR_STD;

	/* One half should be negative */
	if (rand_div(100) < 50)
	{
		lua_pushnumber(L, mean - offset);
		return 1;
	}

	/* One half should be positive */
	lua_pushnumber(L, mean + offset);
	return 1;
}

static const struct luaL_reg rnglib[] =
{
	{"__call", rng_call},
	{"range", rng_range},
	{"avg", rng_avg},
	{"dice", rng_dice},
	{"seed", rng_seed},
	{"chance", rng_chance},
	{"percent", rng_percent},
	{"normal", rng_normal},
	{"float", rng_float},
	{NULL, NULL},
};


/******************************************************************
 ******************************************************************
 *                             Line                               *
 ******************************************************************
 ******************************************************************/
typedef struct {
	int stepx;
	int stepy;
	int e;
	int deltax;
	int deltay;
	int origx;
	int origy;
	int destx;
	int desty;
} line_data;

/* ********** bresenham line drawing ********** */
static int lua_line_init(lua_State *L)
{
	int xFrom = luaL_checknumber(L, 1);
	int yFrom = luaL_checknumber(L, 2);
	int xTo = luaL_checknumber(L, 3);
	int yTo = luaL_checknumber(L, 4);
	bool start_at_end = lua_toboolean(L, 5);

	line_data *data = (line_data*)lua_newuserdata(L, sizeof(line_data));
	auxiliar_setclass(L, "line{core}", -1);

	data->origx=xFrom;
	data->origy=yFrom;
	data->destx=xTo;
	data->desty=yTo;
	data->deltax=xTo - xFrom;
	data->deltay=yTo - yFrom;
	if ( data->deltax > 0 ) {
		data->stepx=1;
	} else if ( data->deltax < 0 ){
		data->stepx=-1;
	} else data->stepx=0;
	if ( data->deltay > 0 ) {
		data->stepy=1;
	} else if ( data->deltay < 0 ){
		data->stepy=-1;
	} else data->stepy = 0;
	if ( data->stepx*data->deltax > data->stepy*data->deltay ) {
		data->e = data->stepx*data->deltax;
		data->deltax *= 2;
		data->deltay *= 2;
	} else {
		data->e = data->stepy*data->deltay;
		data->deltax *= 2;
		data->deltay *= 2;
	}

	if (start_at_end)
	{
		data->origx=xTo;
		data->origy=yTo;
	}

	return 1;
}

static int lua_line_step(lua_State *L)
{
	line_data *data = (line_data*)auxiliar_checkclass(L, "line{core}", 1);
	bool dont_stop_at_end = lua_toboolean(L, 2);

	if ( data->stepx*data->deltax > data->stepy*data->deltay ) {
		if (!dont_stop_at_end && data->origx == data->destx ) return 0;
		data->origx+=data->stepx;
		data->e -= data->stepy*data->deltay;
		if ( data->e < 0) {
			data->origy+=data->stepy;
			data->e+=data->stepx*data->deltax;
		}
	} else {
		if (!dont_stop_at_end && data->origy == data->desty ) return 0;
		data->origy+=data->stepy;
		data->e -= data->stepx*data->deltax;
		if ( data->e < 0) {
			data->origx+=data->stepx;
			data->e+=data->stepy*data->deltay;
		}
	}
	lua_pushnumber(L, data->origx);
	lua_pushnumber(L, data->origy);
	return 2;
}

static int lua_free_line(lua_State *L)
{
	(void)auxiliar_checkclass(L, "line{core}", 1);
	lua_pushnumber(L, 1);
	return 1;
}

static const struct luaL_reg linelib[] =
{
	{"new", lua_line_init},
	{NULL, NULL},
};

static const struct luaL_reg line_reg[] =
{
	{"__gc", lua_free_line},
	{"__call", lua_line_step},
	{NULL, NULL},
};


/******************************************************************
 ******************************************************************
 *                             FS                                 *
 ******************************************************************
 ******************************************************************/

static int lua_fs_exists(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	lua_pushboolean(L, PHYSFS_exists(file));

	return 1;
}

static int lua_fs_mkdir(lua_State *L)
{
	const char *dir = luaL_checkstring(L, 1);

	PHYSFS_mkdir(dir);

	return 0;
}

static int lua_fs_delete(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	PHYSFS_delete(file);

	return 0;
}

static int lua_fs_list(lua_State* L)
{
	const char *dir = luaL_checkstring(L, 1);
	bool only_dir = lua_toboolean(L, 2);

	char **rc = PHYSFS_enumerateFiles(dir);
	char **i;
	int nb = 1;
	char buf[2048];

	lua_newtable(L);
	for (i = rc; *i != NULL; i++)
	{
		strcpy(buf, dir);
		strcat(buf, "/");
		strcat(buf, *i);
		if (only_dir && (!PHYSFS_isDirectory(buf)))
			continue;

		lua_pushnumber(L, nb);
		lua_pushstring(L, *i);
		lua_settable(L, -3);
		nb++;
	}

	PHYSFS_freeList(rc);

	return 1;
}


static int lua_fs_open(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);
	const char *mode = luaL_checkstring(L, 2);

	PHYSFS_file **f = (PHYSFS_file **)lua_newuserdata(L, sizeof(PHYSFS_file *));
	auxiliar_setclass(L, "physfs{file}", -1);

	if (strchr(mode, 'w'))
		*f = PHYSFS_openWrite(file);
	else if (strchr(mode, 'a'))
		*f = PHYSFS_openAppend(file);
	else
		*f = PHYSFS_openRead(file);
	if (!*f)
	{
		lua_pop(L, 1);
		lua_pushnil(L);
	}
	return 1;
}

static int lua_file_read(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	long n = luaL_optlong(L, 2, ~((size_t)0));

	size_t rlen;  /* how much to read */
	size_t nr;  /* number of chars actually read */
	luaL_Buffer b;
	luaL_buffinit(L, &b);
	rlen = LUAL_BUFFERSIZE;  /* try to read that much each time */
	do {
		char *p = luaL_prepbuffer(&b);
		if (rlen > n) rlen = n;  /* cannot read more than asked */
		nr = PHYSFS_read(*f, p, sizeof(char), rlen);
		luaL_addsize(&b, nr);
		n -= nr;  /* still have to read `n' chars */
	} while (n > 0 && nr == rlen);  /* until end of count or eof */
	luaL_pushresult(&b);  /* close buffer */
	return (n == 0 || lua_objlen(L, -1) > 0);
	return 1;
}

static int lua_file_write(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	size_t len;
	const char *data = lua_tolstring(L, 2, &len);

	PHYSFS_write(*f, data, sizeof(char), len);

	return 0;
}

static int lua_close_file(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	if (*f)
	{
		PHYSFS_close(*f);
		*f = NULL;
	}
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_fs_zipopen(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	zipFile *zf = (zipFile*)lua_newuserdata(L, sizeof(zipFile*));
	auxiliar_setclass(L, "physfs{zip}", -1);

	*zf = zipOpen(file, APPEND_STATUS_CREATE);
	if (!*zf)
	{
		lua_pop(L, 1);
		lua_pushnil(L);
	}
	return 1;
}

static int lua_close_zip(lua_State *L)
{
	zipFile *zf = (zipFile*)auxiliar_checkclass(L, "physfs{zip}", 1);
	if (*zf)
	{
		zipClose(*zf, NULL);
		*zf = NULL;
	}
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_zip_add(lua_State *L)
{
	zipFile *zf = (zipFile*)auxiliar_checkclass(L, "physfs{zip}", 1);
	const char *filenameinzip = luaL_checkstring(L, 2);
	size_t datalen;
	const char *data = lua_tolstring(L, 3, &datalen);
	int opt_compress_level = luaL_optnumber(L, 4, 4);

	int err=0;
	zip_fileinfo zi;
	unsigned long crcFile=0;

	zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
	zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
	zi.dosDate = 0;
	zi.internal_fa = 0;
	zi.external_fa = 0;

	err = zipOpenNewFileInZip3(*zf,filenameinzip,&zi,
		NULL,0,NULL,0,NULL /* comment*/,
		(opt_compress_level != 0) ? Z_DEFLATED : 0,
		opt_compress_level,0,
		/* -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, */
		-MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
		NULL,crcFile);

	if (err != ZIP_OK)
	{
		lua_pushnil(L);
		lua_pushstring(L, "could not add file to zip");
		return 2;
	}
	else
	{
		err = zipWriteInFileInZip(*zf, data, datalen);
	}

	zipCloseFileInZip(*zf);

	lua_pushboolean(L, 1);
	return 1;
}

static int lua_fs_mount(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	const char *dest = luaL_checkstring(L, 2);
	bool append = lua_toboolean(L, 3);

	int err = PHYSFS_mount(src, dest, append);
	if (err == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, PHYSFS_getLastError());
		return 2;
	}
	lua_pushboolean(L, TRUE);

	return 1;
}

static int lua_fs_umount(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);

	PHYSFS_removeFromSearchPath(src);
	return 0;
}

static int lua_fs_get_real_path(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	lua_pushstring(L, PHYSFS_getDependentPath(src));
	return 1;
}

static int lua_fs_set_write_dir(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	PHYSFS_setWriteDir(src);
	return 0;
}

static int lua_fs_get_write_dir(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getWriteDir());
	return 1;
}

static int lua_fs_get_home_path(lua_State *L)
{
	lua_pushstring(L, TENGINE_HOME_PATH);
	return 1;
}

static int lua_fs_get_user_path(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getUserDir());
	return 1;
}

static int lua_fs_get_path_separator(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getDirSeparator());
	return 1;
}

static int lua_fs_get_search_path(lua_State *L)
{
	char **rc = PHYSFS_getSearchPath();

	char **i;
	int nb = 1;

	lua_newtable(L);
	for (i = rc; *i != NULL; i++)
	{
		lua_pushnumber(L, nb);
		lua_pushstring(L, *i);
		lua_settable(L, -3);
		nb++;
	}

	PHYSFS_freeList(rc);
	return 1;
}

static const struct luaL_reg fslib[] =
{
	{"open", lua_fs_open},
	{"zipOpen", lua_fs_zipopen},
	{"exists", lua_fs_exists},
	{"mkdir", lua_fs_mkdir},
	{"delete", lua_fs_delete},
	{"list", lua_fs_list},
	{"setWritePath", lua_fs_set_write_dir},
	{"getWritePath", lua_fs_get_write_dir},
	{"getPathSeparator", lua_fs_get_path_separator},
	{"getRealPath", lua_fs_get_real_path},
	{"getUserPath", lua_fs_get_user_path},
	{"getHomePath", lua_fs_get_home_path},
	{"getSearchPath", lua_fs_get_search_path},
	{"mount", lua_fs_mount},
	{"umount", lua_fs_umount},
	{NULL, NULL},
};

static const struct luaL_reg fsfile_reg[] =
{
	{"__gc", lua_close_file},
	{"close", lua_close_file},
	{"read", lua_file_read},
	{"write", lua_file_write},
	{NULL, NULL},
};

static const struct luaL_reg fszipfile_reg[] =
{
	{"__gc", lua_close_zip},
	{"close", lua_close_zip},
	{"add", lua_zip_add},
	{NULL, NULL},
};

int luaopen_core(lua_State *L)
{
	auxiliar_newclass(L, "physfs{file}", fsfile_reg);
	auxiliar_newclass(L, "physfs{zip}", fszipfile_reg);
	auxiliar_newclass(L, "line{core}", line_reg);
	auxiliar_newclass(L, "fov{core}", fov_reg);
	auxiliar_newclass(L, "fov{cache}", fovcache_reg);
	auxiliar_newclass(L, "gl{texture}", sdl_texture_reg);
	auxiliar_newclass(L, "gl{fbo}", gl_fbo_reg);
	auxiliar_newclass(L, "sdl{surface}", sdl_surface_reg);
	auxiliar_newclass(L, "sdl{font}", sdl_font_reg);
	luaL_openlib(L, "core.fov", fovlib, 0);
	luaL_openlib(L, "core.display", displaylib, 0);
	luaL_openlib(L, "core.mouse", mouselib, 0);
	luaL_openlib(L, "core.key", keylib, 0);
	luaL_openlib(L, "core.game", gamelib, 0);
	luaL_openlib(L, "rng", rnglib, 0);
	luaL_openlib(L, "line", linelib, 0);
	luaL_openlib(L, "fs", fslib, 0);
	return 1;
}
