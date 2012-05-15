/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini

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

static profile_type *main_profile = NULL;

int push_order(lua_State *L)
{
	size_t len;
	const char *code = luaL_checklstring(L, 1, &len);
//	printf("[profile order] %s\n", code);

	profile_queue *q = malloc(sizeof(profile_queue));
	char *d = calloc(len, sizeof(char));
	memcpy(d, code, len);
	q->payload = d;
	q->payload_len = len;

	SDL_mutexP(main_profile->lock_iqueue);
	if (!(main_profile->iqueue_tail)) main_profile->iqueue_head = q;
	else main_profile->iqueue_tail->next = q;
	q->next = NULL;
	main_profile->iqueue_tail = q;
	SDL_mutexV(main_profile->lock_iqueue);

	return 0;
}

int pop_order(lua_State *L)
{
	profile_queue *q = NULL;
	SDL_mutexP(main_profile->lock_iqueue);
	if (main_profile->iqueue_head)
	{
		q = main_profile->iqueue_head;
		if (q) main_profile->iqueue_head = q->next;
		if (!main_profile->iqueue_head) main_profile->iqueue_tail = NULL;
	}
	SDL_mutexV(main_profile->lock_iqueue);

	if (q)
	{
		lua_pushlstring(L, q->payload, q->payload_len);
//		printf("[profile order POP] %s\n", lua_tostring(L,-1));
		free(q->payload);
		free(q);
	}
	else
		lua_pushnil(L);

	return 1;
}

int push_event(lua_State *L)
{
	size_t len;
	const char *code = luaL_checklstring(L, 1, &len);
//	printf("[profile event] %s\n", code);

	profile_queue *q = malloc(sizeof(profile_queue));
	char *d = calloc(len, sizeof(char));
	memcpy(d, code, len);
	q->payload = d;
	q->payload_len = len;

	SDL_mutexP(main_profile->lock_oqueue);
	if (!(main_profile->oqueue_tail)) main_profile->oqueue_head = q;
	else main_profile->oqueue_tail->next = q;
	q->next = NULL;
	main_profile->oqueue_tail = q;
	SDL_mutexV(main_profile->lock_oqueue);

	return 0;
}

int pop_event(lua_State *L)
{
	profile_queue *q = NULL;
	SDL_mutexP(main_profile->lock_oqueue);
	if (main_profile->oqueue_head)
	{
		q = main_profile->oqueue_head;
		if (q) main_profile->oqueue_head = q->next;
		if (!main_profile->oqueue_head) main_profile->oqueue_tail = NULL;
	}
	SDL_mutexV(main_profile->lock_oqueue);

	if (q)
	{
//		printf("[profile event] POP %s\n", q->payload);
		lua_pushlstring(L, q->payload, q->payload_len);
		free(q->payload);
		free(q);
	}
	else
		lua_pushnil(L);

	return 1;
}

static const struct luaL_reg threadlib[] =
{
	{"popOrder", pop_order},
	{"pushEvent", push_event},
	{NULL, NULL},
};

int thread_profile(void *data)
{
	profile_type *profile = (profile_type*)data;
	lua_State *L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaopen_socket_core(L);
	luaopen_mime_core(L);
	luaopen_zlib(L);
	luaL_openlib(L, "cprofile", threadlib, 0); lua_pop(L, 1);

	// Override "print" if requested
	if (no_debug)
	{
		lua_pushcfunction(L, noprint);
		lua_setglobal(L, "print");
	}

	profile->L = L;

	// And run the lua engine pre init scripts
	if (!luaL_loadfile(L, "/loader/pre-init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	// Load the profile connector
	if (!luaL_loadfile(L, "/profile-thread/init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	while (profile->running)
	{
		if (!profile->running) break;

		lua_getglobal(L, "step_profile");
		docall(L, 0, 0);
	}

	// Cleanup
	lua_close(L);
	printf("Cleaned up profile thread\n");

	return(0);
}

// Runs on main thread
void free_profile_thread()
{
	if (!main_profile) return;
	profile_type *profile = main_profile;
	profile->running = FALSE;

	int status;
	SDL_WaitThread(profile->thread, &status);

	SDL_DestroyMutex(profile->lock_iqueue);
	SDL_DestroySemaphore(profile->wait_iqueue);
	SDL_DestroyMutex(profile->lock_oqueue);
	SDL_DestroySemaphore(profile->wait_oqueue);
}

// Runs on main thread
int create_profile_thread(lua_State *L)
{
	if (main_profile) return 0;

	SDL_Thread *thread;
	profile_type *profile = calloc(1, sizeof(profile_type));
	main_profile = profile;

	profile->running = TRUE;
	profile->iqueue_head = profile->iqueue_tail = profile->oqueue_head = profile->oqueue_tail = NULL;
	profile->lock_iqueue = SDL_CreateMutex();
	profile->wait_iqueue = SDL_CreateSemaphore(0);
	profile->lock_oqueue = SDL_CreateMutex();
	profile->wait_oqueue = SDL_CreateSemaphore(0);

	thread = SDL_CreateThread(thread_profile, "profile", profile);
	if (thread == NULL) {
		printf("Unable to create profile thread: %s\n", SDL_GetError());
		return -1;
	}
	profile->thread = thread;

	printf("Creating profile thread\n");
	return 0;
}

static const struct luaL_reg mainlib[] =
{
	{"createThread", create_profile_thread},
	{"pushOrder", push_order},
	{"popEvent", pop_event},
	{NULL, NULL},
};

int luaopen_profile(lua_State *L)
{
	luaL_openlib(L, "core.profile", mainlib, 0);
	lua_pop(L, 1);
	return 1;
}

