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
#include "main.h"
#include "profile.h"
#include "lua_externs.h"

static profile_type *main_profile;

int thread_profile(void *data)
{
	profile_type *profile = (profile_type*)data;
	lua_State *L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaopen_socket_core(L);
	luaopen_mime_core(L);
	profile->L = L;

	profile->s_req = zmq_socket(Z, ZMQ_SUB);
	zmq_connect(profile->s_req, "tcp://te4.org:2257");

	// And run the lua engine pre init scripts
	if (!luaL_loadfile(L, "/loader/pre-init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	// Load the profile connector
	if (!luaL_loadfile(L, "/profile-thread/init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	int request_nbr=0;
	while (profile->running)
	{
		if (!profile->running) break;

		zmq_msg_t reply;
		zmq_msg_init(&reply);
		zmq_recv(profile->s_req, &reply, 0);
		printf("Received reply %d: [%s]\n", request_nbr,
			(char *) zmq_msg_data (&reply));
		zmq_msg_close(&reply);

		request_nbr++;


//		lua_getglobal(L, "step_profile");
//		docall(L, 0, 0);
	}

	// Cleanup
	lua_close(L);
	printf("Cleaned up profile thread\n");

	return(0);
}

// Runs on main thread
void create_profile_thread()
{
	SDL_Thread *thread;
	profile_type *profile = calloc(1, sizeof(profile_type));
	main_profile = profile;

	profile->running = TRUE;

	thread = SDL_CreateThread(thread_profile, profile);
	if (thread == NULL) {
		printf("Unable to create profile thread: %s\n", SDL_GetError());
		return;
	}
	profile->thread = thread;

	printf("Creating profile thread\n");
}
