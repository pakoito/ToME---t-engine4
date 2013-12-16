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
#ifndef _MAIN_H_
#define _MAIN_H_

#include "runner/core.h"

#if defined(SELFEXE_LINUX)
#define _te4_export
#elif defined(SELFEXE_WINDOWS)
#define _te4_export __declspec(dllexport)
#elif defined(SELFEXE_MACOSX)
#define _te4_export
#else
#define _te4_export
#endif

extern int resizeWindow(int width, int height);
extern void do_resize(int w, int h, bool fullscreen, bool borderless);
extern void setupRealtime(float freq);
extern void setupDisplayTimer(int fps);
extern int docall (lua_State *L, int narg, int nret);
extern bool no_steam;
extern bool safe_mode;
extern bool fbo_active;
extern bool multitexture_active;
extern long total_keyframes;
extern int cur_frame_tick;
extern int g_argc;
extern char **g_argv;
extern char *override_home;

/* Error handling */
struct lua_err_type_s {
	char *err_msg;
	char *file;
	int line;
	char *func;
	struct lua_err_type_s *next;
};
typedef struct lua_err_type_s lua_err_type;
extern lua_err_type *last_lua_error_head, *last_lua_error_tail;
extern void del_lua_error();
extern core_boot_type *core_def;

#ifdef STEAM_TE4
#include "steam-te4.h"
#endif

#endif

