/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

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
#include "zlib.h"
#include "main.h"
#include "useshader.h"
#include "core_lua.h"
#include <math.h>
#include <time.h>

#ifdef __APPLE__
#include <libpng/png.h>
#else
#include <png.h>
#endif

extern SDL_Window *window;

#define SDL_SRCALPHA        0x00010000
int SDL_SetAlpha(SDL_Surface * surface, Uint32 flag, Uint8 value)
{
    if (flag & SDL_SRCALPHA) {
        /* According to the docs, value is ignored for alpha surfaces */
        if (surface->format->Amask) {
            value = 0xFF;
        }
        SDL_SetSurfaceAlphaMod(surface, value);
        SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_BLEND);
    } else {
        SDL_SetSurfaceAlphaMod(surface, 0xFF);
        SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_NONE);
    }
    SDL_SetSurfaceRLE(surface, (flag & SDL_RLEACCEL));

    return 0;
}

SDL_Surface *SDL_DisplayFormatAlpha(SDL_Surface *surface)
{
	SDL_Surface *image;
	SDL_Rect area;
	Uint8  saved_alpha;
	SDL_BlendMode saved_mode;

	image = SDL_CreateRGBSurface(
			SDL_SWSURFACE,
			surface->w, surface->h,
			32,
#if SDL_BYTEORDER == SDL_LIL_ENDIAN /* OpenGL RGBA masks */
			0x000000FF,
			0x0000FF00,
			0x00FF0000,
			0xFF000000
#else
			0xFF000000,
			0x00FF0000,
			0x0000FF00,
			0x000000FF
#endif
			);
	if ( image == NULL ) {
		return 0;
	}

	/* Save the alpha blending attributes */
	SDL_GetSurfaceAlphaMod(surface, &saved_alpha);
	SDL_SetSurfaceAlphaMod(surface, 0xFF);
	SDL_GetSurfaceBlendMode(surface, &saved_mode);
	SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_NONE);

	/* Copy the surface into the GL texture image */
	area.x = 0;
	area.y = 0;
	area.w = surface->w;
	area.h = surface->h;
	SDL_BlitSurface(surface, &area, image, &area);

	/* Restore the alpha blending attributes */
	SDL_SetSurfaceAlphaMod(surface, saved_alpha);
	SDL_SetSurfaceBlendMode(surface, saved_mode);

	return image;
}

typedef struct SDL_VideoInfo
{
    Uint32 hw_available:1;
    Uint32 wm_available:1;
    Uint32 UnusedBits1:6;
    Uint32 UnusedBits2:1;
    Uint32 blit_hw:1;
    Uint32 blit_hw_CC:1;
    Uint32 blit_hw_A:1;
    Uint32 blit_sw:1;
    Uint32 blit_sw_CC:1;
    Uint32 blit_sw_A:1;
    Uint32 blit_fill:1;
    Uint32 UnusedBits3:16;
    Uint32 video_mem;

    SDL_PixelFormat *vfmt;

    int current_w;
    int current_h;
} SDL_VideoInfo;

static int
GetVideoDisplay()
{
    const char *variable = SDL_getenv("SDL_VIDEO_FULLSCREEN_DISPLAY");
    if ( !variable ) {
        variable = SDL_getenv("SDL_VIDEO_FULLSCREEN_HEAD");
    }
    if ( variable ) {
        return SDL_atoi(variable);
    } else {
        return 0;
    }
}

const SDL_VideoInfo *SDL_GetVideoInfo(void)
{
    static SDL_VideoInfo info;
    SDL_DisplayMode mode;

    /* Memory leak, compatibility code, who cares? */
    if (!info.vfmt && SDL_GetDesktopDisplayMode(GetVideoDisplay(), &mode) == 0) {
        info.vfmt = SDL_AllocFormat(mode.format);
        info.current_w = mode.w;
        info.current_h = mode.h;
    }
    return &info;
}

SDL_Rect **
SDL_ListModes(const SDL_PixelFormat * format, Uint32 flags)
{
    int i, nmodes;
    SDL_Rect **modes;

/*    if (!SDL_GetVideoDevice()) {
        return NULL;
    }
  */
/*    if (!(flags & SDL_FULLSCREEN)) {
        return (SDL_Rect **) (-1);
    }
*/
    if (!format) {
        format = SDL_GetVideoInfo()->vfmt;
    }

    /* Memory leak, but this is a compatibility function, who cares? */
    nmodes = 0;
    modes = NULL;
    for (i = 0; i < SDL_GetNumDisplayModes(GetVideoDisplay()); ++i) {
        SDL_DisplayMode mode;
        int bpp;

        SDL_GetDisplayMode(GetVideoDisplay(), i, &mode);
        if (!mode.w || !mode.h) {
            return (SDL_Rect **) (-1);
        }

        /* Copied from src/video/SDL_pixels.c:SDL_PixelFormatEnumToMasks */
        if (SDL_BYTESPERPIXEL(mode.format) <= 2) {
            bpp = SDL_BITSPERPIXEL(mode.format);
        } else {
            bpp = SDL_BYTESPERPIXEL(mode.format) * 8;
        }

        if (bpp != format->BitsPerPixel) {
            continue;
        }
        if (nmodes > 0 && modes[nmodes - 1]->w == mode.w
            && modes[nmodes - 1]->h == mode.h) {
            continue;
        }

        modes = SDL_realloc(modes, (nmodes + 2) * sizeof(*modes));
        if (!modes) {
            return NULL;
        }
        modes[nmodes] = (SDL_Rect *) SDL_malloc(sizeof(SDL_Rect));
        if (!modes[nmodes]) {
            return NULL;
        }
        modes[nmodes]->x = 0;
        modes[nmodes]->y = 0;
        modes[nmodes]->w = mode.w;
        modes[nmodes]->h = mode.h;
        ++nmodes;
    }
    if (modes) {
        modes[nmodes] = NULL;
    }
    return modes;
}


/***** Helpers *****/
static GLenum sdl_gl_texture_format(SDL_Surface *s) {
	// get the number of channels in the SDL surface
	GLint nOfColors = s->format->BytesPerPixel;
	GLenum texture_format;
	if (nOfColors == 4)	 // contains an alpha channel
	{
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
		if (s->format->Rmask == 0xff000000)
#else
		if (s->format->Rmask == 0x000000ff)
#endif
			texture_format = GL_RGBA;
		else
			texture_format = GL_BGRA;
	} else if (nOfColors == 3)	 // no alpha channel
	{
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
		if (s->format->Rmask == 0x00ff0000)
#else
		if (s->format->Rmask == 0x000000ff)
#endif
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
static char *largest_black = NULL;
static int largest_size = 0;
void make_texture_for_surface(SDL_Surface *s, int *fw, int *fh, bool clamp) {
	// Paramétrage de la texture.
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, clamp ? GL_CLAMP_TO_BORDER : GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, clamp ? GL_CLAMP_TO_BORDER : GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	// get the number of channels in the SDL surface
	GLint nOfColors = s->format->BytesPerPixel;
	GLenum texture_format = sdl_gl_texture_format(s);

	// In case we can't support NPOT textures round up to nearest POT
	int realw=1;
	int realh=1;

	while (realw < s->w) realw *= 2;
	while (realh < s->h) realh *= 2;

	if (fw) *fw = realw;
	if (fh) *fh = realh;
	//printf("request size (%d,%d), producing size (%d,%d)\n",s->w,s->h,realw,realh);

	if (!largest_black || largest_size < realw * realh * 4) {
		if (largest_black) free(largest_black);
		largest_black = calloc(realh*realw*4, sizeof(char));
		largest_size = realh*realw*4;
		printf("Upgrading black texture to size %d\n", largest_size);
	}
	glTexImage2D(GL_TEXTURE_2D, 0, nOfColors, realw, realh, 0, texture_format, GL_UNSIGNED_BYTE, largest_black);

#ifdef _DEBUG
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("make_texture_for_surface: glTexImage2D : %s\n",gluErrorString(err));
	}
#endif
}

// copy pixels into previous allocated surface
void copy_surface_to_texture(SDL_Surface *s) {
	GLenum texture_format = sdl_gl_texture_format(s);

	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, s->w, s->h, texture_format, GL_UNSIGNED_BYTE, s->pixels);

#ifdef _DEBUG
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("copy_surface_to_texture : glTexSubImage2D : %s\n",gluErrorString(err));
	}
#endif
}


/******************************************************************
 ******************************************************************
 *                             Mouse                              *
 ******************************************************************
 ******************************************************************/
static int lua_get_mouse(lua_State *L)
{
	int x = 0, y = 0;
	int buttons = SDL_GetMouseState(&x, &y);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_pushnumber(L, SDL_BUTTON(buttons));

	return 3;
}
static int lua_set_mouse(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	SDL_WarpMouseInWindow(window, x, y);
	return 0;
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
static const struct luaL_Reg mouselib[] =
{
	{"get", lua_get_mouse},
	{"set", lua_set_mouse},
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
	SDL_Keymod smod = SDL_GetModState();

	if (!strcmp(mod, "shift")) lua_pushboolean(L, smod & KMOD_SHIFT);
	else if (!strcmp(mod, "ctrl")) lua_pushboolean(L, smod & KMOD_CTRL);
	else if (!strcmp(mod, "alt")) lua_pushboolean(L, smod & KMOD_ALT);
	else if (!strcmp(mod, "meta")) lua_pushboolean(L, smod & KMOD_GUI);
	else if (!strcmp(mod, "caps")) lua_pushboolean(L, smod & KMOD_CAPS);
	else lua_pushnil(L);

	return 1;
}
static int lua_get_scancode_name(lua_State *L)
{
	SDL_Scancode code = luaL_checknumber(L, 1);
	lua_pushstring(L, SDL_GetScancodeName(code));

	return 1;
}
static int lua_flush_key_events(lua_State *L)
{
	SDL_FlushEvents(SDL_KEYDOWN, SDL_TEXTINPUT);
	return 0;
}

static int lua_key_unicode(lua_State *L)
{
	if (lua_isboolean(L, 1)) SDL_StartTextInput();
	else SDL_StopTextInput();
	return 0;
}

static int lua_key_set_clipboard(lua_State *L)
{
	char *str = luaL_checkstring(L, 1);
	SDL_SetClipboardText(str);
	return 0;
}

static int lua_key_get_clipboard(lua_State *L)
{
	if (SDL_HasClipboardText())
	{
		char *str = SDL_GetClipboardText();
		if (str)
		{
			lua_pushstring(L, str);
			free(str);
		}
		else
			lua_pushnil(L);
	}
	else
		lua_pushnil(L);
	return 1;
}

static const struct luaL_Reg keylib[] =
{
	{"set_current_handler", lua_set_current_keyhandler},
	{"modState", lua_get_mod_state},
	{"symName", lua_get_scancode_name},
	{"flush", lua_flush_key_events},
	{"unicodeInput", lua_key_unicode},
	{"getClipboard", lua_key_get_clipboard},
	{"setClipboard", lua_key_set_clipboard},
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
static int lua_reboot_lua(lua_State *L)
{
	core_def->define(
		core_def,
		luaL_checkstring(L, 1),
		luaL_checknumber(L, 2),
		luaL_checkstring(L, 3),
		luaL_checkstring(L, 4),
		luaL_checkstring(L, 5),
		luaL_checkstring(L, 6),
		lua_toboolean(L, 7),
		luaL_checkstring(L, 8)
		);

	// By default reboot the same core -- this skips some initializations
	if (core_def->corenum == -1) core_def->corenum = TE4CORE_VERSION;

	return 0;
}
static int lua_get_time(lua_State *L)
{
	lua_pushnumber(L, SDL_GetTicks());
	return 1;
}
static int lua_set_realtime(lua_State *L)
{
	float freq = luaL_checknumber(L, 1);
	setupRealtime(freq);
	return 0;
}
static int lua_set_fps(lua_State *L)
{
	float freq = luaL_checknumber(L, 1);
	setupDisplayTimer(freq);
	return 0;
}
static int lua_sleep(lua_State *L)
{
	int ms = luaL_checknumber(L, 1);
	SDL_Delay(ms);
	return 0;
}

static int lua_check_error(lua_State *L)
{
	if (!last_lua_error_head) return 0;

	int n = 1;
	lua_newtable(L);
	lua_err_type *cur = last_lua_error_head;
	while (cur)
	{
		if (cur->err_msg) lua_pushfstring(L, "Lua Error: %s", cur->err_msg);
		else lua_pushfstring(L, "  At %s:%d %s", cur->file, cur->line, cur->func);
		lua_rawseti(L, -2, n++);
		cur = cur->next;
	}

	del_lua_error();
	return 1;
}

static const struct luaL_Reg gamelib[] =
{
	{"reboot", lua_reboot_lua},
	{"set_current_game", lua_set_current_game},
	{"exit_engine", lua_exit_engine},
	{"getTime", lua_get_time},
	{"sleep", lua_sleep},
	{"setRealtime", lua_set_realtime},
	{"setFPS", lua_set_fps},
	{"checkError", lua_check_error},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                           Display                              *
 ******************************************************************
 ******************************************************************/
static bool no_text_aa = FALSE;

extern bool is_fullscreen;
static int sdl_screen_size(lua_State *L)
{
	lua_pushnumber(L, screen->w);
	lua_pushnumber(L, screen->h);
	lua_pushboolean(L, is_fullscreen);
	return 3;
}

static int sdl_new_font(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);
	int size = luaL_checknumber(L, 2);

	TTF_Font **f = (TTF_Font**)lua_newuserdata(L, sizeof(TTF_Font*));
	auxiliar_setclass(L, "sdl{font}", -1);

	SDL_RWops *src = PHYSFSRWOPS_openRead(name);
	if (!src)
	{
		return luaL_error(L, "could not load font: %s (%d)", name, size);
	}

	*f = TTF_OpenFontRW(src, TRUE, size);

	if (!*f)
	{
		return luaL_error(L, "could not load font: %s (%d)", name, size);
	}

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

static int sdl_font_style_get(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	int style = TTF_GetFontStyle(*f);

	if (style & TTF_STYLE_BOLD) lua_pushliteral(L, "bold");
	else if (style & TTF_STYLE_ITALIC) lua_pushliteral(L, "italic");
	else if (style & TTF_STYLE_UNDERLINE) lua_pushliteral(L, "underline");
	else lua_pushliteral(L, "normal");

	return 1;
}

static int sdl_font_style(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	const char *style = luaL_checkstring(L, 2);

	if (!strcmp(style, "normal")) TTF_SetFontStyle(*f, 0);
	else if (!strcmp(style, "bold")) TTF_SetFontStyle(*f, TTF_STYLE_BOLD);
	else if (!strcmp(style, "italic")) TTF_SetFontStyle(*f, TTF_STYLE_ITALIC);
	else if (!strcmp(style, "underline")) TTF_SetFontStyle(*f, TTF_STYLE_UNDERLINE);
	return 0;
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
	bool alpha_from_texture = lua_toboolean(L, 9);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Blended(*f, str, color);
	if (txt)
	{
		if (alpha_from_texture) SDL_SetAlpha(txt, 0, 0);
		sdlDrawImage(*s, txt, x, y);
		SDL_FreeSurface(txt);
	}

	return 0;
}

static int sdl_surface_drawstring_aa(lua_State *L)
{
	if (no_text_aa) return sdl_surface_drawstring(L);
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 2);
	const char *str = luaL_checkstring(L, 3);
	int x = luaL_checknumber(L, 4);
	int y = luaL_checknumber(L, 5);
	int r = luaL_checknumber(L, 6);
	int g = luaL_checknumber(L, 7);
	int b = luaL_checknumber(L, 8);
	bool alpha_from_texture = lua_toboolean(L, 9);

	SDL_Color color = {r,g,b};
	SDL_Surface *txt = TTF_RenderUTF8_Blended(*f, str, color);
	if (txt)
	{
		if (alpha_from_texture) SDL_SetAlpha(txt, 0, 0);
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


static int sdl_surface_drawstring_newsurface_aa(lua_State *L)
{
	if (no_text_aa) return sdl_surface_drawstring_newsurface(L);
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

static font_make_texture_line(lua_State *L, SDL_Surface *s, int id, bool is_separator, int id_real_line, char *line_data, int line_data_size, bool direct_uid_draw)
{
	lua_createtable(L, 0, 9);

	if (direct_uid_draw)
	{
		lua_pushliteral(L, "_dduids");
		lua_pushvalue(L, -4);
		lua_rawset(L, -3);

		// Replace dduids by a new one
		lua_newtable(L);
		lua_replace(L, -4);
	}

	lua_pushliteral(L, "_tex");
	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);
	lua_rawset(L, -3);

	glGenTextures(1, t);
	tfglBindTexture(GL_TEXTURE_2D, *t);
	int fw, fh;
	make_texture_for_surface(s, &fw, &fh, true);
	copy_surface_to_texture(s);

	lua_pushliteral(L, "_tex_w");
	lua_pushnumber(L, fw);
	lua_rawset(L, -3);
	lua_pushliteral(L, "_tex_h");
	lua_pushnumber(L, fh);
	lua_rawset(L, -3);

	lua_pushliteral(L, "w");
	lua_pushnumber(L, s->w);
	lua_rawset(L, -3);
	lua_pushliteral(L, "h");
	lua_pushnumber(L, s->h);
	lua_rawset(L, -3);

	lua_pushliteral(L, "line");
	lua_pushnumber(L, id_real_line);
	lua_rawset(L, -3);

	if (line_data)
	{
		lua_pushliteral(L, "line_extra");
		lua_pushlstring(L, line_data, line_data_size);
		lua_rawset(L, -3);
	}

	if (is_separator)
	{
		lua_pushliteral(L, "is_separator");
		lua_pushboolean(L, TRUE);
		lua_rawset(L, -3);
	}

	lua_rawseti(L, -2, id);
}

extern GLint max_texture_size;
static int sdl_font_draw(lua_State *L)
{
	TTF_Font **f = (TTF_Font**)auxiliar_checkclass(L, "sdl{font}", 1);
	const char *str = luaL_checkstring(L, 2);
	int max_width = luaL_checknumber(L, 3);
	int r = luaL_checknumber(L, 4);
	int g = luaL_checknumber(L, 5);
	int b = luaL_checknumber(L, 6);
	bool no_linefeed = lua_toboolean(L, 7);
	bool direct_uid_draw = lua_toboolean(L, 8);
	int h = TTF_FontLineSkip(*f);
	SDL_Color color = {r,g,b};

	int fullmax = max_texture_size / 2;
	if (fullmax < 1024) fullmax = 1024;
	if (max_width >= fullmax) max_width = fullmax;

	Uint32 rmask, gmask, bmask, amask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
	rmask = 0xff000000; gmask = 0x00ff0000; bmask = 0x0000ff00; amask = 0x000000ff;
#else
	rmask = 0x000000ff; gmask = 0x0000ff00; bmask = 0x00ff0000; amask = 0xff000000;
#endif
	SDL_Surface *s = SDL_CreateRGBSurface(SDL_SWSURFACE, max_width, h, 32, rmask, gmask, bmask, amask);
	SDL_FillRect(s, NULL, SDL_MapRGBA(s->format, 0, 0, 0, 0));

	int id_dduid = 1;
	if (direct_uid_draw)
	{
		lua_newtable(L);
	}

	lua_newtable(L);

	int nb_lines = 1;
	int id_real_line = 1;
	char *line_data = NULL;
	int line_data_size = 0;
	char *start = (char*)str, *stop = (char*)str, *next = (char*)str;
	int max_size = 0;
	int size = 0;
	bool is_separator = FALSE;
	int i;
	bool force_nl = FALSE;
	SDL_Surface *txt = NULL;
	while (TRUE)
	{
		if ((*next == '\n') || (*next == ' ') || (*next == '\0') || (*next == '#'))
		{
			bool inced = FALSE;
			if (*next == ' ' && *(next+1))
			{
				inced = TRUE;
				stop = next;
				next++;
			}
			else stop = next - 1;

			// Make a surface for the word
			char old = *next;
			*next = '\0';
			if (txt) SDL_FreeSurface(txt);
			if (no_text_aa) txt = TTF_RenderUTF8_Blended(*f, start, color);
			else txt = TTF_RenderUTF8_Blended(*f, start, color);

			// If we must do a newline, flush the previous word and the start the new line
			if (!no_linefeed && (force_nl || (txt && (size + txt->w > max_width))))
			{
				// Push it & reset the surface
				font_make_texture_line(L, s, nb_lines, is_separator, id_real_line, line_data, line_data_size, direct_uid_draw);
				id_dduid = 1;
				is_separator = FALSE;
				SDL_FillRect(s, NULL, SDL_MapRGBA(s->format, 0, 0, 0, 0));
//				printf("Ending previous line at size %d\n", size);
				if (size > max_size) max_size = size;
				size = 0;
				nb_lines++;
				if (force_nl)
				{
					id_real_line++;
					if (line_data) { line_data = NULL; }
				}
				force_nl = FALSE;
			}

			if (txt)
			{
				// Detect separators
				if ((*start == '-') && (*(start+1) == '-') && (*(start+2) == '-') && !(*(start+3))) is_separator = TRUE;

//				printf("Drawing word '%s'\n", start);
				SDL_SetAlpha(txt, 0, 0);
				sdlDrawImage(s, txt, size, 0);
				size += txt->w;
			}
			*next = old;
			if (inced) next--;
			start = next + 1;

			// Force a linefeed
			if (*next == '\n') force_nl = TRUE;

			// Handle special codes
			else if (*next == '#')
			{
				char *codestop = next + 1;
				while (*codestop && *codestop != '#') codestop++;
				// Font style
				if (*(next+1) == '{') {
					if (*(next+2) == 'n') TTF_SetFontStyle(*f, 0);
					else if (*(next+2) == 'b') TTF_SetFontStyle(*f, TTF_STYLE_BOLD);
					else if (*(next+2) == 'i') TTF_SetFontStyle(*f, TTF_STYLE_ITALIC);
					else if (*(next+2) == 'u') TTF_SetFontStyle(*f, TTF_STYLE_UNDERLINE);
				}
				// Entity UID
				else if ((codestop - (next+1) > 4) && (*(next+1) == 'U') && (*(next+2) == 'I') && (*(next+3) == 'D') && (*(next+4) == ':')) {
					if (!direct_uid_draw)
					{
						lua_getglobal(L, "__get_uid_surface");
						char *colon = next + 5;
						while (*colon && *colon != ':') colon++;
						lua_pushlstring(L, next+5, colon - (next+5));
//						printf("Drawing UID %s\n", lua_tostring(L,-1));
						lua_pushnumber(L, h);
						lua_pushnumber(L, h);
						lua_call(L, 3, 1);
						if (lua_isuserdata(L, -1))
						{
							SDL_Surface **img = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", -1);
							sdlDrawImage(s, *img, size, 0);
							size += (*img)->w;
						}
						lua_pop(L, 1);
					}
					else
					{
						lua_getglobal(L, "__get_uid_entity");
						char *colon = next + 5;
						while (*colon && *colon != ':') colon++;
						lua_pushlstring(L, next+5, colon - (next+5));
						lua_call(L, 1, 1);
						if (lua_istable(L, -1))
						{
//							printf("DirectDrawUID in font:draw %d : %d\n", size, h);
							lua_createtable(L, 0, 4);

							lua_pushliteral(L, "e");
							lua_pushvalue(L, -3);
							lua_rawset(L, -3);

							lua_pushliteral(L, "x");
							lua_pushnumber(L, size);
							lua_rawset(L, -3);

							lua_pushliteral(L, "w");
							lua_pushnumber(L, h);
							lua_rawset(L, -3);

							lua_rawseti(L, -4, id_dduid++); // __dduids

							size += h;
						}
						lua_pop(L, 1);
					}
				}
				// Extra data
				else if ((*(next+1) == '&')) {
					line_data = next + 2;
					line_data_size = codestop - (next+2);
				}
				// Color
				else {
					if ((codestop - (next+1) == 4) && (*(next+1) == 'L') && (*(next+2) == 'A') && (*(next+3) == 'S') && (*(next+4) == 'T'))
					{
						color.r = r;
						color.g = g;
						color.b = b;
					}

					lua_getglobal(L, "colors");
					lua_pushlstring(L, next+1, codestop - (next+1));
					lua_rawget(L, -2);
					if (lua_istable(L, -1)) {
						r = color.r;
						g = color.g;
						b = color.b;

						lua_pushliteral(L, "r");
						lua_rawget(L, -2);
						color.r = lua_tonumber(L, -1);
						lua_pushliteral(L, "g");
						lua_rawget(L, -3);
						color.g = lua_tonumber(L, -1);
						lua_pushliteral(L, "b");
						lua_rawget(L, -4);
						color.b = lua_tonumber(L, -1);
						lua_pop(L, 3);
					}
					// Hexacolor
					else if (codestop - (next+1) == 6)
					{
						r = color.r;
						g = color.g;
						b = color.b;

						int rh = 0, gh = 0, bh = 0;

						if ((*(next+1) >= '0') && (*(next+1) <= '9')) rh += 16 * (*(next+1) - '0');
						else if ((*(next+1) >= 'a') && (*(next+1) <= 'f')) rh += 16 * (10 + *(next+1) - 'a');
						else if ((*(next+1) >= 'A') && (*(next+1) <= 'F')) rh += 16 * (10 + *(next+1) - 'A');
						if ((*(next+2) >= '0') && (*(next+2) <= '9')) rh += (*(next+2) - '0');
						else if ((*(next+2) >= 'a') && (*(next+2) <= 'f')) rh += (10 + *(next+2) - 'a');
						else if ((*(next+2) >= 'A') && (*(next+2) <= 'F')) rh += (10 + *(next+2) - 'A');

						if ((*(next+3) >= '0') && (*(next+3) <= '9')) gh += 16 * (*(next+3) - '0');
						else if ((*(next+3) >= 'a') && (*(next+3) <= 'f')) gh += 16 * (10 + *(next+3) - 'a');
						else if ((*(next+3) >= 'A') && (*(next+3) <= 'F')) gh += 16 * (10 + *(next+3) - 'A');
						if ((*(next+4) >= '0') && (*(next+4) <= '9')) gh += (*(next+4) - '0');
						else if ((*(next+4) >= 'a') && (*(next+4) <= 'f')) gh += (10 + *(next+4) - 'a');
						else if ((*(next+4) >= 'A') && (*(next+4) <= 'F')) gh += (10 + *(next+4) - 'A');

						if ((*(next+5) >= '0') && (*(next+5) <= '9')) bh += 16 * (*(next+5) - '0');
						else if ((*(next+5) >= 'a') && (*(next+5) <= 'f')) bh += 16 * (10 + *(next+5) - 'a');
						else if ((*(next+5) >= 'A') && (*(next+5) <= 'F')) bh += 16 * (10 + *(next+5) - 'A');
						if ((*(next+6) >= '0') && (*(next+6) <= '9')) bh += (*(next+6) - '0');
						else if ((*(next+6) >= 'a') && (*(next+6) <= 'f')) bh += (10 + *(next+6) - 'a');
						else if ((*(next+6) >= 'A') && (*(next+6) <= 'F')) bh += (10 + *(next+6) - 'A');

						color.r = rh;
						color.g = gh;
						color.b = bh;
					}
					lua_pop(L, 2);
				}

				char old = *codestop;
				*codestop = '\0';
//				printf("Found code: %s\n", next+1);
				*codestop = old;

				start = codestop + 1;
				next = codestop; // The while will increment it, so we dont so it here
			}
		}
		if (*next == '\0') break;
		next++;
	}

	font_make_texture_line(L, s, nb_lines, is_separator, id_real_line, line_data, line_data_size, direct_uid_draw);
	id_dduid = 1;
	if (size > max_size) max_size = size;

	if (txt) SDL_FreeSurface(txt);
	SDL_FreeSurface(s);

	lua_pushnumber(L, nb_lines);
	lua_pushnumber(L, max_size);

	if (direct_uid_draw) lua_remove(L, -4);

	return 3;
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
		SDL_SWSURFACE,
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
		SDL_SWSURFACE,
		w,
		h,
		32,
		rmask, gmask, bmask, amask
		);

	if (s == NULL)
		printf("ERROR : SDL_CreateRGBSurface : %s\n",SDL_GetError());

	return 1;
}

static int gl_texture_to_sdl(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	// Bind the texture to read
	tglBindTexture(GL_TEXTURE_2D, *t);

	// Get texture size
	GLint w, h;
	glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &w);
	glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &h);
//	printf("Making surface from texture %dx%d\n", w, h);
	// Get texture data
	GLubyte *tmp = calloc(w*h*4, sizeof(GLubyte));
	glGetTexImage(GL_TEXTURE_2D, 0, GL_BGRA, GL_UNSIGNED_BYTE, tmp);

	// Make sdl surface from it
	*s = SDL_CreateRGBSurfaceFrom(tmp, w, h, 32, w*4, 0,0,0,0);

	return 1;
}

static int gl_tex_white = 0;
int init_blank_surface()
{
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
	SDL_Surface *s = SDL_CreateRGBSurface(
		SDL_SWSURFACE,
		4,
		4,
		32,
		rmask, gmask, bmask, amask
		);
	SDL_FillRect(s, NULL, SDL_MapRGBA(s->format, 255, 255, 255, 255));

	glGenTextures(1, &gl_tex_white);
	tfglBindTexture(GL_TEXTURE_2D, gl_tex_white);
	int fw, fh;
	make_texture_for_surface(s, &fw, &fh, false);
	copy_surface_to_texture(s);
	return gl_tex_white;
}

static int gl_draw_quad(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	float r = luaL_checknumber(L, 5) / 255;
	float g = luaL_checknumber(L, 6) / 255;
	float b = luaL_checknumber(L, 7) / 255;
	float a = luaL_checknumber(L, 8) / 255;

	if (lua_isuserdata(L, 9))
	{
		GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 9);
		tglBindTexture(GL_TEXTURE_2D, *t);
	}
	else if (lua_toboolean(L, 9))
	{
		// Do nothing, we keep the currently bound texture
	}
	else
	{
		tfglBindTexture(GL_TEXTURE_2D, gl_tex_white);
	}

	GLfloat texcoords[2*4] = {
		0, 0,
		0, 1,
		1, 1,
		1, 0,
	};
	GLfloat colors[4*4] = {
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
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

static int gl_draw_quad_part(lua_State *L)
{
	int x = luaL_checknumber(L, 1);
	int y = luaL_checknumber(L, 2);
	int w = luaL_checknumber(L, 3);
	int h = luaL_checknumber(L, 4);
	float angle = luaL_checknumber(L, 5);
	float r = luaL_checknumber(L, 6) / 255;
	float g = luaL_checknumber(L, 7) / 255;
	float b = luaL_checknumber(L, 8) / 255;
	float a = luaL_checknumber(L, 9) / 255;

	int xw = w + x;
	int yh = h + y;
	int midx = x + w / 2, midy = y + h / 2;

	if (lua_isuserdata(L, 10))
	{
		GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 10);
		tglBindTexture(GL_TEXTURE_2D, *t);
	}
	else if (lua_toboolean(L, 10))
	{
		// Do nothing, we keep the currently bound texture
	}
	else
	{
		tfglBindTexture(GL_TEXTURE_2D, gl_tex_white);
	}

	if (angle < 0) angle = 0;
	else if (angle > 360) angle = 360;

	// Shortcut
	if (angle == 360)
	{
		return 0;
	}

	GLfloat texcoords[2*10] = {
		0, 0,
		0, 1,
		1, 1,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
	};
	GLfloat colors[4*10] = {
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
	};
	GLfloat vertices[2*10] = {
		midx, midy,
		midx, y,
	};

	int i = 4;
	float quadrant = angle / 45;
	float rad = (angle - (45 * (int)quadrant)) * M_PI / 180;
	float s = sin(rad) / 2;

	if (quadrant >= 7)                 { vertices[i++] = x + w * s; vertices[i++] = y; }
	else if (quadrant < 7)             { vertices[i++] = x; vertices[i++] = y; }
	if (quadrant >= 6 && quadrant < 7) { vertices[i++] = x; vertices[i++] = midy - h * s; }
	else if (quadrant < 6)             { vertices[i++] = x; vertices[i++] = midy; }
	if (quadrant >= 5 && quadrant < 6) { vertices[i++] = x; vertices[i++] = yh - h * s; }
	else if (quadrant < 5)             { vertices[i++] = x; vertices[i++] = yh; }
	if (quadrant >= 4 && quadrant < 5) { vertices[i++] = midx - w * s; vertices[i++] = yh; }
	else if (quadrant < 4)             { vertices[i++] = midx; vertices[i++] = yh; }
	if (quadrant >= 3 && quadrant < 4) { vertices[i++] = xw - w * s; vertices[i++] = yh; }
	else if (quadrant < 3)             { vertices[i++] = xw; vertices[i++] = yh; }
	if (quadrant >= 2 && quadrant < 3) { vertices[i++] = xw; vertices[i++] = midy + h * s; }
	else if (quadrant < 2)             { vertices[i++] = xw; vertices[i++] = midy; }
	if (quadrant >= 1 && quadrant < 2) { vertices[i++] = xw; vertices[i++] = y + h * s; }
	else if (quadrant < 1)             { vertices[i++] = xw; vertices[i++] = y; }
	if (quadrant >= 0 && quadrant < 1) { vertices[i++] = midx + w * s; vertices[i++] = y; }

	glColorPointer(4, GL_FLOAT, 0, colors);
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glVertexPointer(2, GL_FLOAT, 0, vertices);

	glDrawArrays(GL_TRIANGLE_FAN, 0, i / 2);
	return 0;
}


static int sdl_load_image(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	*s = IMG_Load_RW(PHYSFSRWOPS_openRead(name), TRUE);
	if (!*s) return 0;

	lua_pushnumber(L, (*s)->w);
	lua_pushnumber(L, (*s)->h);

	return 3;
}

static int sdl_load_image_mem(lua_State *L)
{
	size_t len;
	const char *data = luaL_checklstring(L, 1, &len);

	SDL_Surface **s = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
	auxiliar_setclass(L, "sdl{surface}", -1);

	*s = IMG_Load_RW(SDL_RWFromConstMem(data, len), TRUE);
	if (!*s) return 0;

	lua_pushnumber(L, (*s)->w);
	lua_pushnumber(L, (*s)->h);

	return 3;
}

static int sdl_free_surface(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	if (*s)
	{
		if ((*s)->flags & SDL_PREALLOC) free((*s)->pixels);
		SDL_FreeSurface(*s);
	}
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

	GLfloat texcoords[2*4] = {
		0, 0,
		0, texh,
		texw, texh,
		texw, 0,
	};

	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	GLfloat vertices[2*4] = {
		x, y,
		x, y + h,
		x + w, y + h,
		x + w, y,
	};
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_QUADS, 0, 4);
}

static int sdl_surface_toscreen(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};
	if (lua_isnumber(L, 4))
	{
		float r = luaL_checknumber(L, 4);
		float g = luaL_checknumber(L, 5);
		float b = luaL_checknumber(L, 6);
		float a = luaL_checknumber(L, 7);
		int i;
		for (i = 0; i < 4; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	GLuint t;
	glGenTextures(1, &t);
	tfglBindTexture(GL_TEXTURE_2D, t);

	make_texture_for_surface(*s, NULL, NULL, false);
	copy_surface_to_texture(*s);
	draw_textured_quad(x,y,(*s)->w,(*s)->h);

	glDeleteTextures(1, &t);

	return 0;
}

static int sdl_surface_toscreen_with_texture(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 2);
	int x = luaL_checknumber(L, 3);
	int y = luaL_checknumber(L, 4);
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};
	if (lua_isnumber(L, 5))
	{
		float r = luaL_checknumber(L, 5);
		float g = luaL_checknumber(L, 6);
		float b = luaL_checknumber(L, 7);
		float a = luaL_checknumber(L, 8);
		int i;
		for (i = 0; i < 4; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, *t);

	copy_surface_to_texture(*s);
	draw_textured_quad(x,y,(*s)->w,(*s)->h);

	return 0;
}

static int sdl_surface_update_texture(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 2);

	tglBindTexture(GL_TEXTURE_2D, *t);
	copy_surface_to_texture(*s);

	return 0;
}

static int sdl_surface_to_texture(lua_State *L)
{
	SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 1);

	GLuint *t = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);

	glGenTextures(1, t);
	tfglBindTexture(GL_TEXTURE_2D, *t);

	int fw, fh;
	make_texture_for_surface(*s, &fw, &fh, false);
	copy_surface_to_texture(*s);

	lua_pushnumber(L, fw);
	lua_pushnumber(L, fh);
	lua_pushnumber(L, (double)fw / (*s)->w);
	lua_pushnumber(L, (double)fh / (*s)->h);
	lua_pushnumber(L, (*s)->w);
	lua_pushnumber(L, (*s)->h);

	return 7;
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
	if (lua_isnumber(L, 2))
	{
		int a = luaL_checknumber(L, 2);
		SDL_SetAlpha(*s, /*SDL_SRCALPHA | */SDL_RLEACCEL, (a < 0) ? 0 : (a > 255) ? 255 : a);
	}
	else
	{
		SDL_SetAlpha(*s, 0, 0);
	}
	return 0;
}

static int sdl_free_texture(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	glDeleteTextures(1, t);
	lua_pushnumber(L, 1);
//	printf("freeing texture %d\n", *t);
	return 1;
}

static int sdl_texture_toscreen(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};
	if (lua_isnumber(L, 6))
	{
		float r = luaL_checknumber(L, 6);
		float g = luaL_checknumber(L, 7);
		float b = luaL_checknumber(L, 8);
		float a = luaL_checknumber(L, 9);
		int i;
		for (i = 0; i < 4; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, *t);

	GLfloat texcoords[2*4] = {
		0, 0,
		0, 1,
		1, 1,
		1, 0,
	};

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

static int sdl_texture_toscreen_highlight_hex(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);

	// A very slight gradient to give some definition to the texture
	GLfloat colors[4*8] = {
		0.9, 0.9, 0.9, 1,
		0.9, 0.9, 0.9, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		0.9, 0.9, 0.9, 1,
		0.8, 0.8, 0.8, 1,
		0.8, 0.8, 0.8, 1,
		0.9, 0.9, 0.9, 1,
	};
	if (lua_isnumber(L, 6))
	{
		float r = luaL_checknumber(L, 6);
		float g = luaL_checknumber(L, 7);
		float b = luaL_checknumber(L, 8);
		float a = luaL_checknumber(L, 9);
		int i;
		for (i = 0; i < 8; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, *t);

	GLfloat texcoords[2*8] = {
		0, 0,
		0, 1,
		1, 1,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
		1, 0,
	};

	float f = x - w/6.0;
	float v = 4.0*w/3.0;
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	GLfloat vertices[2*8] = {
		x + 0.5*v,  y + 0.5*h,
		f + 0.25*v, y,
		f,          y + 0.5*h,
		f + 0.25*v, y + h,
		f + 0.75*v, y + h,
		f + v,      y + 0.5*h,
		f + 0.75*v, y,
		f + 0.25*v, y,
	};
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 8);
	return 0;
}

static int sdl_texture_toscreen_full(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	int rw = luaL_checknumber(L, 6);
	int rh = luaL_checknumber(L, 7);
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};
	if (lua_isnumber(L, 8))
	{
		float r = luaL_checknumber(L, 8);
		float g = luaL_checknumber(L, 9);
		float b = luaL_checknumber(L, 10);
		float a = luaL_checknumber(L, 11);
		int i;
		for (i = 0; i < 4; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, *t);
	GLfloat texw = (GLfloat)w/rw;
	GLfloat texh = (GLfloat)h/rh;

	GLfloat texcoords[2*4] = {
		0, 0,
		0, texh,
		texw, texh,
		texw, 0,
	};

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

static int sdl_texture_toscreen_precise(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	GLfloat x1 = luaL_checknumber(L, 6);
	GLfloat x2 = luaL_checknumber(L, 7);
	GLfloat y1 = luaL_checknumber(L, 8);
	GLfloat y2 = luaL_checknumber(L, 9);
	GLfloat colors[4*4] = {
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
		1, 1, 1, 1,
	};
	if (lua_isnumber(L, 10))
	{
		float r = luaL_checknumber(L, 10);
		float g = luaL_checknumber(L, 11);
		float b = luaL_checknumber(L, 12);
		float a = luaL_checknumber(L, 13);
		int i;
		for (i = 0; i < 4; i++) {
			colors[(4*i)+0] = r;
			colors[(4*i)+1] = g;
			colors[(4*i)+2] = b;
			colors[(4*i)+3] = a;
		}
	}
	glColorPointer(4, GL_FLOAT, 0, colors);

	tglBindTexture(GL_TEXTURE_2D, *t);

	GLfloat texcoords[2*4] = {
		x1, y1,
		x1, y2,
		x2, y2,
		x2, y1,
	};

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

static int gl_scale(lua_State *L)
{
	if (lua_isnumber(L, 1))
	{
		glPushMatrix();
		glScalef(lua_tonumber(L, 1), lua_tonumber(L, 2), lua_tonumber(L, 3));
	}
	else
		glPopMatrix();
	return 0;
}

static int gl_translate(lua_State *L)
{
	glTranslatef(lua_tonumber(L, 1), lua_tonumber(L, 2), lua_tonumber(L, 3));
	return 0;
}

static int gl_rotate(lua_State *L)
{
	glRotatef(lua_tonumber(L, 1), lua_tonumber(L, 2), lua_tonumber(L, 3), lua_tonumber(L, 4));
	return 0;
}

static int gl_push(lua_State *L)
{
	glPushMatrix();
	return 0;
}

static int gl_pop(lua_State *L)
{
	glPopMatrix();
	return 0;
}

static int gl_identity(lua_State *L)
{
	glLoadIdentity();
	return 0;
}

static int gl_matrix(lua_State *L)
{
	if (lua_toboolean(L, 1)) glPushMatrix();
	else glPopMatrix();
	return 0;
}

static int gl_depth_test(lua_State *L)
{
	if (lua_toboolean(L, 1)) glEnable(GL_DEPTH_TEST);
	else glDisable(GL_DEPTH_TEST);
	return 0;
}

static int gl_scissor(lua_State *L)
{
	if (lua_toboolean(L, 1)) {
		glEnable(GL_SCISSOR_TEST);
		glScissor(luaL_checknumber(L, 2), screen->h - luaL_checknumber(L, 3) - luaL_checknumber(L, 5), luaL_checknumber(L, 4), luaL_checknumber(L, 5));
	} else glDisable(GL_SCISSOR_TEST);
	return 0;
}

static int gl_color(lua_State *L)
{
	tglColor4f(luaL_checknumber(L, 1), luaL_checknumber(L, 2), luaL_checknumber(L, 3), luaL_checknumber(L, 4));
	return 0;
}

static int sdl_texture_bind(lua_State *L)
{
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
	int i = luaL_checknumber(L, 2);
	bool is3d = lua_toboolean(L, 3);

	if (i > 0)
	{
		if (multitexture_active && shaders_active)
		{
			tglActiveTexture(GL_TEXTURE0+i);
			tglBindTexture(is3d ? GL_TEXTURE_3D : GL_TEXTURE_2D, *t);
			tglActiveTexture(GL_TEXTURE0);
		}
	}
	else
	{
		tglBindTexture(is3d ? GL_TEXTURE_3D : GL_TEXTURE_2D, *t);
	}

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
	float x = luaL_checknumber(L, 2);
	float y = luaL_checknumber(L, 3);
	int w = luaL_checknumber(L, 4);
	int h = luaL_checknumber(L, 5);
	float r = luaL_checknumber(L, 6);
	float g = luaL_checknumber(L, 7);
	float b = luaL_checknumber(L, 8);
	float a = luaL_checknumber(L, 9);
	int i;

	// Setup our FBO
	// WARNING: this is a static, only one FBO is ever made, and never deleted, for some reasons
	// deleting it makes the game crash when doing a chain lightning spell under luajit1 ... (yeah I know .. weird)
	static GLuint fbo = 0;
	if (!fbo) glGenFramebuffersEXT(1, &fbo);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo);

	// Now setup a texture to render to
	GLuint *img = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{texture}", -1);
	glGenTextures(1, img);
	tfglBindTexture(GL_TEXTURE_2D, *img);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, *img, 0);

	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT) return 0;

	// Set the viewport and save the old one
	glPushAttrib(GL_VIEWPORT_BIT);

	glViewport(0, 0, w, h);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, w, 0, h, -101, 101);
	glMatrixMode( GL_MODELVIEW );

	/* Reset The View */
	glLoadIdentity( );

	tglClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();

	/* Render to buffer: shadow */
	glBindTexture(GL_TEXTURE_2D, *t);

	GLfloat texcoords[2*4] = {
		0, 0,
		1, 0,
		1, 1,
		0, 1,
	};
	GLfloat vertices[2*4] = {
		x,   y,
		w+x, y,
		w+x, h+y,
		x,   h+y,
	};
	GLfloat colors[4*4] = {
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
		r, g, b, a,
	};
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);

	glDrawArrays(GL_QUADS, 0, 4);

	/* Render to buffer: original */
	for (i = 0; i < 4*4; i++) colors[i] = 1;
	vertices[0] = 0; vertices[1] = 0;
	vertices[2] = w; vertices[3] = 0;
	vertices[4] = w; vertices[5] = h;
	vertices[6] = 0; vertices[7] = h;
	glDrawArrays(GL_QUADS, 0, 4);

	// Unbind texture from FBO and then unbind FBO
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, gl_c_fbo);
	// Restore viewport
	glPopAttrib();

	// Cleanup
	// No, dot not it's a static, see upwards
//	CHECKGL(glDeleteFramebuffersEXT(1, &fbo));

	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode( GL_MODELVIEW );

	tglClearColor( 0.0f, 0.0f, 0.0f, 1.0f );

	return 1;
}

static int sdl_set_window_title(lua_State *L)
{
	const char *title = luaL_checkstring(L, 1);
	SDL_SetWindowTitle(window, title);
	return 0;
}

static int sdl_set_window_size(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	bool fullscreen = lua_toboolean(L, 3);

	printf("Setting resolution to %dx%d (%s)\n", w, h, fullscreen ? "fullscreen" : "windowed");
	do_resize(w, h, fullscreen);

	lua_pushboolean(L, TRUE);
	return 1;
}

static int sdl_set_window_pos(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	SDL_SetWindowPosition(window, w, h);

	lua_pushboolean(L, TRUE);
	return 1;
}

extern void on_redraw();
static int sdl_redraw_screen(lua_State *L)
{
	on_redraw();
	return 0;
}

int mouse_cursor_s_ref = LUA_NOREF;
int mouse_cursor_down_s_ref = LUA_NOREF;
SDL_Surface *mouse_cursor_s = NULL;
SDL_Surface *mouse_cursor_down_s = NULL;
SDL_Cursor *mouse_cursor = NULL;
SDL_Cursor *mouse_cursor_down = NULL;
extern int mouse_cursor_ox, mouse_cursor_oy;
static int sdl_set_mouse_cursor(lua_State *L)
{
	mouse_cursor_ox = luaL_checknumber(L, 1);
	mouse_cursor_oy = luaL_checknumber(L, 2);

	/* Down */
	if (mouse_cursor_down_s_ref != LUA_NOREF)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, mouse_cursor_down_s_ref);
		mouse_cursor_down_s_ref = LUA_NOREF;
	}

	if (!lua_isnil(L, 4))
	{
		SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 4);
		mouse_cursor_down_s = *s;
		mouse_cursor_down_s_ref = luaL_ref(L, LUA_REGISTRYINDEX);

		if (mouse_cursor_down) { SDL_FreeCursor(mouse_cursor_down); mouse_cursor_down = NULL; }
		mouse_cursor_down = SDL_CreateColorCursor(mouse_cursor_down_s, -mouse_cursor_ox, -mouse_cursor_oy);
		if (mouse_cursor_down) SDL_SetCursor(mouse_cursor_down);
	}

	/* Default */
	if (mouse_cursor_s_ref != LUA_NOREF)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, mouse_cursor_s_ref);
		mouse_cursor_s_ref = LUA_NOREF;
	}

	if (!lua_isnil(L, 3))
	{
		SDL_Surface **s = (SDL_Surface**)auxiliar_checkclass(L, "sdl{surface}", 3);
		mouse_cursor_s = *s;
		mouse_cursor_s_ref = luaL_ref(L, LUA_REGISTRYINDEX);

		if (mouse_cursor) { SDL_FreeCursor(mouse_cursor); mouse_cursor = NULL; }
		mouse_cursor = SDL_CreateColorCursor(mouse_cursor_s, -mouse_cursor_ox, -mouse_cursor_oy);
		if (mouse_cursor) SDL_SetCursor(mouse_cursor);
	}
	return 0;
}

extern int mouse_drag_tex, mouse_drag_tex_ref;
extern int mouse_drag_w, mouse_drag_h;
static int sdl_set_mouse_cursor_drag(lua_State *L)
{
	mouse_drag_w = luaL_checknumber(L, 2);
	mouse_drag_h = luaL_checknumber(L, 3);

	/* Default */
	if (mouse_drag_tex_ref != LUA_NOREF)
	{
		luaL_unref(L, LUA_REGISTRYINDEX, mouse_drag_tex_ref);
		mouse_drag_tex_ref = LUA_NOREF;
	}

	if (lua_isnil(L, 1))
	{
		mouse_drag_tex = 0;
	}
	else
	{
		GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 1);
		mouse_drag_tex = *t;
		mouse_drag_tex_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	return 0;
}


/**************************************************************
 * Quadratic Objects
 **************************************************************/
static int gl_new_quadratic(lua_State *L)
{
	GLUquadricObj **quadratic = (GLUquadricObj**)lua_newuserdata(L, sizeof(GLUquadricObj*));
	auxiliar_setclass(L, "gl{quadratic}", -1);

	*quadratic = gluNewQuadric( );
	gluQuadricNormals(*quadratic, GLU_SMOOTH);
	gluQuadricTexture(*quadratic, GL_TRUE);

	return 1;
}

static int gl_free_quadratic(lua_State *L)
{
	GLUquadricObj **quadratic = (GLUquadricObj**)auxiliar_checkclass(L, "gl{quadratic}", 1);

	gluDeleteQuadric(*quadratic);

	lua_pushnumber(L, 1);
	return 1;
}

static int gl_quadratic_sphere(lua_State *L)
{
	GLUquadricObj **quadratic = (GLUquadricObj**)auxiliar_checkclass(L, "gl{quadratic}", 1);
	float rad = luaL_checknumber(L, 2);

	gluSphere(*quadratic, rad, 64, 64);

	return 0;
}

/**************************************************************
 * Framebuffer Objects
 **************************************************************/

static int gl_new_fbo(lua_State *L)
{
	if (!fbo_active) return 0;

	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	lua_fbo *fbo = (lua_fbo*)lua_newuserdata(L, sizeof(lua_fbo));
	auxiliar_setclass(L, "gl{fbo}", -1);
	fbo->w = w;
	fbo->h = h;

	glGenFramebuffersEXT(1, &(fbo->fbo));
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo);

	// Now setup a texture to render to
	glGenTextures(1, &(fbo->texture));
	tfglBindTexture(GL_TEXTURE_2D, fbo->texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,  w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, fbo->texture, 0);

	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT) return 0;

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

	return 1;
}

static int gl_free_fbo(lua_State *L)
{
	lua_fbo *fbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 1);

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

	glDeleteTextures(1, &(fbo->texture));
	glDeleteFramebuffersEXT(1, &(fbo->fbo));

	lua_pushnumber(L, 1);
	return 1;
}

static int gl_fbo_use(lua_State *L)
{
	lua_fbo *fbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 1);
	bool active = lua_toboolean(L, 2);

	if (active)
	{
		tglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo->fbo);

		// Set the viewport and save the old one
		glPushAttrib(GL_VIEWPORT_BIT);

		glViewport(0, 0, fbo->w, fbo->h);
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		glOrtho(0, fbo->w, fbo->h, 0, -1001, 1001);
		glMatrixMode(GL_MODELVIEW);

		// Reset The View
		glLoadIdentity();

		tglClearColor(0.0f, 0.0f, 0.0f, 1.0f);
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
		if (!lua_isuserdata(L, 3)) { tglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0); }
		else
		{
			lua_fbo *pfbo = (lua_fbo*)auxiliar_checkclass(L, "gl{fbo}", 3);
			tglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, pfbo->fbo);
		}


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
		GLfloat colors[4*4] = {
			r, g, b, a,
			r, g, b, a,
			r, g, b, a,
			r, g, b, a,
		};
		glColorPointer(4, GL_FLOAT, 0, colors);
	}
	else
	{
		GLfloat colors[4*4] = {
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
		};
		glColorPointer(4, GL_FLOAT, 0, colors);
	}
	if (lua_isuserdata(L, 6))
	{
		shader_type *s = (shader_type*)auxiliar_checkclass(L, "gl{program}", 6);
		useShader(s, fbo->w, fbo->h, w, h, r, g, b, a);
	}

	glDisable(GL_BLEND);
	tglBindTexture(GL_TEXTURE_2D, fbo->texture);


	GLfloat texcoords[2*4] = {
		0, 1,
		0, 0,
		1, 0,
		1, 1,
	};

	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	GLfloat vertices[2*4] = {
		x, y,
		x, y + h,
		x + w, y + h,
		x + w, y,
	};
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_QUADS, 0, 4);

	if (lua_isuserdata(L, 6)) glUseProgramObjectARB(0);
	glEnable(GL_BLEND);
	return 0;
}

static int gl_fbo_is_active(lua_State *L)
{
	lua_pushboolean(L, fbo_active);
	return 1;
}

static int gl_fbo_disable(lua_State *L)
{
	fbo_active = FALSE;
	return 0;
}

static int set_text_aa(lua_State *L)
{
	bool active = !lua_toboolean(L, 1);
	no_text_aa = active;
	return 0;
}

static int get_text_aa(lua_State *L)
{
	lua_pushboolean(L, !no_text_aa);
	return 1;
}

static int is_safe_mode(lua_State *L)
{
	lua_pushboolean(L, safe_mode);
	return 1;
}

static int sdl_get_modes_list(lua_State *L)
{
	SDL_PixelFormat format;
	SDL_Rect **modes = NULL;
	int loops = 0;
	int bpp = 0;
	int nb = 1;
	lua_newtable(L);
	do
	{
		//format.BitsPerPixel seems to get zeroed out on my windows box
		switch(loops)
		{
			case 0://32 bpp
				format.BitsPerPixel = 32;
				bpp = 32;
				break;
			case 1://24 bpp
				format.BitsPerPixel = 24;
				bpp = 24;
				break;
			case 2://16 bpp
				format.BitsPerPixel = 16;
				bpp = 16;
				break;
		}

		//get available fullscreen/hardware modes
		modes = SDL_ListModes(&format, 0);
		if (modes)
		{
			int i;
			for(i=0; modes[i]; ++i)
			{
				printf("Available resolutions: %dx%dx%d\n", modes[i]->w, modes[i]->h, bpp/*format.BitsPerPixel*/);
				lua_pushnumber(L, nb++);
				lua_newtable(L);

				lua_pushliteral(L, "w");
				lua_pushnumber(L, modes[i]->w);
				lua_settable(L, -3);

				lua_pushliteral(L, "h");
				lua_pushnumber(L, modes[i]->h);
				lua_settable(L, -3);

				lua_settable(L, -3);
			}
		}
	}while(++loops != 3);
	return 1;
}

extern float gamma_correction;
static int sdl_set_gamma(lua_State *L)
{
	if (lua_isnumber(L, 1))
	{
		gamma_correction = lua_tonumber(L, 1);

		Uint16 red_ramp[256];
		Uint16 green_ramp[256];
		Uint16 blue_ramp[256];

		SDL_CalculateGammaRamp(gamma_correction, red_ramp);
		SDL_memcpy(green_ramp, red_ramp, sizeof(red_ramp));
		SDL_memcpy(blue_ramp, red_ramp, sizeof(red_ramp));
		SDL_SetWindowGammaRamp(window, red_ramp, green_ramp, blue_ramp);
	}
	lua_pushnumber(L, gamma_correction);
	return 1;
}

static void png_write_data_fn(png_structp png_ptr, png_bytep data, png_size_t length)
{
	luaL_Buffer *B = (luaL_Buffer*)png_get_io_ptr(png_ptr);
	luaL_addlstring(B, data, length);
}
static void png_output_flush_fn(png_structp png_ptr)
{
}

#ifndef png_infopp_NULL
#define png_infopp_NULL (png_infopp)NULL
#endif
static int sdl_get_png_screenshot(lua_State *L)
{
	unsigned int x = luaL_checknumber(L, 1);
	unsigned int y = luaL_checknumber(L, 2);
	unsigned long width = luaL_checknumber(L, 3);
	unsigned long height = luaL_checknumber(L, 4);
	unsigned long i;
	png_structp png_ptr;
	png_infop info_ptr;
	png_colorp palette;
	png_byte *image;
	png_bytep *row_pointers;

	png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

	if (png_ptr == NULL)
	{
		return 0;
	}

	info_ptr = png_create_info_struct(png_ptr);
	if (info_ptr == NULL)
	{
		png_destroy_write_struct(&png_ptr, png_infopp_NULL);
		return 0;
	}

	if (setjmp(png_jmpbuf(png_ptr)))
	{
		png_destroy_write_struct(&png_ptr, &info_ptr);
		return 0;
	}

	luaL_Buffer B;
	luaL_buffinit(L, &B);
	png_set_write_fn(png_ptr, &B, png_write_data_fn, png_output_flush_fn);

	png_set_IHDR(png_ptr, info_ptr, width, height, 8, PNG_COLOR_TYPE_RGB,
		PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

	image = (png_byte *)malloc(width * height * 3 * sizeof(png_byte));
	if(image == NULL)
	{
		png_destroy_write_struct(&png_ptr, &info_ptr);
		luaL_pushresult(&B); lua_pop(L, 1);
		return 0;
	}

	row_pointers = (png_bytep *)malloc(height * sizeof(png_bytep));
	if(row_pointers == NULL)
	{
		png_destroy_write_struct(&png_ptr, &info_ptr);
		free(image);
		image = NULL;
		luaL_pushresult(&B); lua_pop(L, 1);
		return 0;
	}

	glPixelStorei(GL_PACK_ALIGNMENT, 1);
	glReadPixels(x, y, width, height, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid *)image);

	for (i = 0; i < height; i++)
	{
		row_pointers[i] = (png_bytep)image + (height - 1 - i) * width * 3;
	}

	png_set_rows(png_ptr, info_ptr, row_pointers);
	png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

	png_destroy_write_struct(&png_ptr, &info_ptr);

	free(row_pointers);
	row_pointers = NULL;

	free(image);
	image = NULL;

	luaL_pushresult(&B);

	return 1;
}

static const struct luaL_Reg displaylib[] =
{
	{"setTextBlended", set_text_aa},
	{"getTextBlended", get_text_aa},
	{"forceRedraw", sdl_redraw_screen},
	{"size", sdl_screen_size},
	{"newFont", sdl_new_font},
	{"newSurface", sdl_new_surface},
	{"newTile", sdl_new_tile},
	{"newFBO", gl_new_fbo},
	{"newQuadratic", gl_new_quadratic},
	{"drawQuad", gl_draw_quad},
	{"drawQuadPart", gl_draw_quad_part},
	{"FBOActive", gl_fbo_is_active},
	{"safeMode", is_safe_mode},
	{"disableFBO", gl_fbo_disable},
	{"drawStringNewSurface", sdl_surface_drawstring_newsurface},
	{"drawStringBlendedNewSurface", sdl_surface_drawstring_newsurface_aa},
	{"loadImage", sdl_load_image},
	{"loadImageMemory", sdl_load_image_mem},
	{"setWindowTitle", sdl_set_window_title},
	{"setWindowSize", sdl_set_window_size},
	{"setWindowPos", sdl_set_window_pos},
	{"getModesList", sdl_get_modes_list},
	{"setMouseCursor", sdl_set_mouse_cursor},
	{"setMouseDrag", sdl_set_mouse_cursor_drag},
	{"setGamma", sdl_set_gamma},
	{"glTranslate", gl_translate},
	{"glScale", gl_scale},
	{"glRotate", gl_rotate},
	{"glPush", gl_push},
	{"glPop", gl_pop},
	{"glIdentity", gl_identity},
	{"glColor", gl_color},
	{"glMatrix", gl_matrix},
	{"glDepthTest", gl_depth_test},
	{"glScissor", gl_scissor},
	{"getScreenshot", sdl_get_png_screenshot},
	{NULL, NULL},
};

static const struct luaL_Reg sdl_surface_reg[] =
{
	{"__gc", sdl_free_surface},
	{"close", sdl_free_surface},
	{"erase", sdl_surface_erase},
	{"getSize", sdl_surface_get_size},
	{"merge", sdl_surface_merge},
	{"toScreen", sdl_surface_toscreen},
	{"toScreenWithTexture", sdl_surface_toscreen_with_texture},
	{"updateTexture", sdl_surface_update_texture},
	{"putChar", lua_display_char},
	{"drawString", sdl_surface_drawstring},
	{"drawStringBlended", sdl_surface_drawstring_aa},
	{"alpha", sdl_surface_alpha},
	{"glTexture", sdl_surface_to_texture},
	{NULL, NULL},
};

static const struct luaL_Reg sdl_texture_reg[] =
{
	{"__gc", sdl_free_texture},
	{"close", sdl_free_texture},
	{"toScreen", sdl_texture_toscreen},
	{"toScreenFull", sdl_texture_toscreen_full},
	{"toScreenPrecise", sdl_texture_toscreen_precise},
	{"toScreenHighlightHex", sdl_texture_toscreen_highlight_hex},
	{"makeOutline", sdl_texture_outline},
	{"toSurface", gl_texture_to_sdl},
	{"bind", sdl_texture_bind},
	{NULL, NULL},
};

static const struct luaL_Reg sdl_font_reg[] =
{
	{"__gc", sdl_free_font},
	{"close", sdl_free_font},
	{"size", sdl_font_size},
	{"height", sdl_font_height},
	{"lineSkip", sdl_font_lineskip},
	{"setStyle", sdl_font_style},
	{"getStyle", sdl_font_style_get},
	{"draw", sdl_font_draw},
	{NULL, NULL},
};

static const struct luaL_Reg gl_fbo_reg[] =
{
	{"__gc", gl_free_fbo},
	{"toScreen", gl_fbo_toscreen},
	{"use", gl_fbo_use},
	{NULL, NULL},
};

static const struct luaL_Reg gl_quadratic_reg[] =
{
	{"__gc", gl_free_quadratic},
	{"sphere", gl_quadratic_sphere},
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
	if (min < max)
		lua_pushnumber(L, genrand_real(min, max));
	else
		lua_pushnumber(L, genrand_real(max, min));
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
	if (x < y)
	{
		int res = x + rand_div(1 + y - x);
		lua_pushnumber(L, res);
	}
	else
	{
		int res = y + rand_div(1 + x - y);
		lua_pushnumber(L, res);
	}
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
		if (x < y)
		{
			int res = x + rand_div(1 + y - x);
			lua_pushnumber(L, res);
		}
		else
		{
			int res = y + rand_div(1 + x - y);
			lua_pushnumber(L, res);
		}
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
	int res = rand_div(100);
	lua_pushboolean(L, res < x);
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

/*
 * Generate a random floating-point number of NORMAL distribution
 *
 * Uses the Box-Muller transform.
 *
 */
static int rng_normal_float(lua_State *L)
{
	static const double TWOPI = 6.2831853071795862;
	static bool stored = FALSE;
	static double z0;
	static double z1;
	double mean = luaL_checknumber(L, 1);
	double std = luaL_checknumber(L, 2);
	double u1;
	double u2;
	if (stored == FALSE)
	{
		u1 = genrand_real1();
		u2 = genrand_real1();
		u1 = sqrt(-2 * log(u1));
		z0 = u1 * cos(TWOPI * u2);
		z1 = u1 * sin(TWOPI * u2);
		lua_pushnumber(L, (z0*std)+mean);
		stored = TRUE;
	}
	else
	{
		lua_pushnumber(L, (z1*std)+mean);
		stored = FALSE;
	}
	return 1;
}

static const struct luaL_Reg rnglib[] =
{
	{"__call", rng_call},
	{"range", rng_range},
	{"avg", rng_avg},
	{"dice", rng_dice},
	{"seed", rng_seed},
	{"chance", rng_chance},
	{"percent", rng_percent},
	{"normal", rng_normal},
	{"normalFloat", rng_normal_float},
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
	auxiliar_setclass(L, "core{line}", -1);

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
	line_data *data = (line_data*)auxiliar_checkclass(L, "core{line}", 1);
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
	(void)auxiliar_checkclass(L, "core{line}", 1);
	lua_pushnumber(L, 1);
	return 1;
}

static const struct luaL_Reg linelib[] =
{
	{"new", lua_line_init},
	{NULL, NULL},
};

static const struct luaL_Reg line_reg[] =
{
	{"__gc", lua_free_line},
	{"__call", lua_line_step},
	{NULL, NULL},
};

/******************************************************************
 ******************************************************************
 *                            ZLIB                                *
 ******************************************************************
 ******************************************************************/

static int lua_zlib_compress(lua_State *L)
{
	uLongf len;
	const char *data = luaL_checklstring(L, 1, (size_t*)&len);
	uLongf reslen = len * 1.1 + 12;
#ifdef __APPLE__
	unsigned
#endif
	char *res = malloc(reslen);
	z_stream zi;

	zi.next_in = (
#ifdef __APPLE__
	unsigned
#endif
	char *)data;
	zi.avail_in = len;
	zi.total_in = 0;

	zi.total_out = 0;

	zi.zalloc = NULL;
	zi.zfree = NULL;
	zi.opaque = NULL;

	deflateInit2(&zi, Z_BEST_COMPRESSION, Z_DEFLATED, 15 + 16, 8, Z_DEFAULT_STRATEGY);

	int deflateStatus;
	do {
		zi.next_out = res + zi.total_out;

		// Calculate the amount of remaining free space in the output buffer
		// by subtracting the number of bytes that have been written so far
		// from the buffer's total capacity
		zi.avail_out = reslen - zi.total_out;

		/* deflate() compresses as much data as possible, and stops/returns when
		 the input buffer becomes empty or the output buffer becomes full. If
		 deflate() returns Z_OK, it means that there are more bytes left to
		 compress in the input buffer but the output buffer is full; the output
		 buffer should be expanded and deflate should be called again (i.e., the
		 loop should continue to rune). If deflate() returns Z_STREAM_END, the
		 end of the input stream was reached (i.e.g, all of the data has been
		 compressed) and the loop should stop. */
		deflateStatus = deflate(&zi, Z_FINISH);
	}
	while (deflateStatus == Z_OK);

	if (deflateStatus == Z_STREAM_END)
	{
		lua_pushlstring(L, (char *)res, zi.total_out);
		free(res);
		return 1;
	}
	else
	{
		free(res);
		return 0;
	}
}


static const struct luaL_Reg zliblib[] =
{
	{"compress", lua_zlib_compress},
	{NULL, NULL},
};

int luaopen_core(lua_State *L)
{
	auxiliar_newclass(L, "core{line}", line_reg);
	auxiliar_newclass(L, "gl{texture}", sdl_texture_reg);
	auxiliar_newclass(L, "gl{fbo}", gl_fbo_reg);
	auxiliar_newclass(L, "gl{quadratic}", gl_quadratic_reg);
	auxiliar_newclass(L, "sdl{surface}", sdl_surface_reg);
	auxiliar_newclass(L, "sdl{font}", sdl_font_reg);
	luaL_openlib(L, "core.display", displaylib, 0);
	luaL_openlib(L, "core.mouse", mouselib, 0);
	luaL_openlib(L, "core.key", keylib, 0);
	luaL_openlib(L, "core.zlib", zliblib, 0);

	luaL_openlib(L, "core.game", gamelib, 0);
	lua_pushliteral(L, "VERSION");
	lua_pushnumber(L, TE4CORE_VERSION);
	lua_settable(L, -3);

	luaL_openlib(L, "rng", rnglib, 0);
	luaL_openlib(L, "bresenham", linelib, 0);

	lua_settop(L, 0);
	return 1;
}

