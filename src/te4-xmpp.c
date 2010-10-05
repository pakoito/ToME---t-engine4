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
#include "core_lua.h"
#include "tSDL.h"
#include "types.h"
#include "te4-xmpp.h"
#include "lua_externs.h"

extern int docall (lua_State *L, int narg, int nret);

static SDL_Thread *thread = NULL;
lua_State *L_xmpp = NULL;

static int xmpp_thread(void *unused)
{
	L_xmpp = lua_open();
	luaL_openlibs(L_xmpp);
	luaopen_core(L_xmpp);
	luaopen_socket_core(L_xmpp);
	luaopen_mime_core(L_xmpp);
	luaopen_struct(L_xmpp);
	luaopen_profiler(L_xmpp);
	luaopen_lpeg(L_xmpp);
	luaopen_lxp(L_xmpp);

	luaL_loadfile(L_xmpp, "/xmpp/init.lua");
	docall(L_xmpp, 0, 0);
	return 0;
}

void start_xmpp_thread()
{
	thread = SDL_CreateThread(xmpp_thread, NULL);
}
