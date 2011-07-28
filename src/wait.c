/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011 Nicolas Casalini

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
#include "tgl.h"
#include "types.h"
#include "main.h"
#include "lua_externs.h"

extern SDL_Window *window;
extern SDL_GLContext maincontext; /* Our opengl context handle */
SDL_GLContext waitcontext; /* Our opengl context handle */
static SDL_Thread *wait_thread = NULL;
static SDL_sem *start_sem, *end_sem;
static bool enabled = FALSE;

extern int resizeWindow(int width, int height);
static int thread_wait(void *data)
{
	lua_State *L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);

	// And run the lua engine pre init scripts
	if (!luaL_loadfile(L, "/loader/pre-init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);


	while (TRUE)
	{
//		SDL_SemWait(start_sem);
		if (enabled)
		{
			if (enabled == 2)
			{
				enabled = 1;
				if (!waitcontext)
				{
					waitcontext = SDL_GL_CreateContext(window);
					int w, h;
					SDL_GetWindowSize(window, &w, &h);
					resizeWindow(w, h);
				}
				SDL_GL_MakeCurrent(window, waitcontext);
			}
			SDL_Delay(50);

			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();

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

			tglBindTexture(GL_TEXTURE_2D, 0);

			GLfloat vertices[2*4] = {
				100, 100,
				100, 200,
				200, 200,
				200, 100,
			};
			glVertexPointer(2, GL_FLOAT, 0, vertices);
			glDrawArrays(GL_QUADS, 0, 4);

			SDL_GL_SwapWindow(window);
			printf("WAIT!\n");
		}
		else
		{
//			SDL_GL_MakeCurrent(window, NULL);
			SDL_SemPost(end_sem);
		}
	}

	// Cleanup
	lua_close(L);
	printf("Cleaned up wait thread\n");

	return(0);
}

// Runs on main thread
static void free_profile_thread()
{
	int status;
	SDL_WaitThread(wait_thread, &status);
/*
	SDL_DestroyMutex(profile->lock_iqueue);
	SDL_DestroySemaphore(profile->wait_iqueue);
	SDL_DestroyMutex(profile->lock_oqueue);
	SDL_DestroySemaphore(profile->wait_oqueue);
*/
}

// Runs on main thread
static int create_wait_thread(lua_State *L)
{
	start_sem = SDL_CreateSemaphore(0);
	end_sem = SDL_CreateSemaphore(0);

	wait_thread = SDL_CreateThread(thread_wait, NULL);
	if (wait_thread == NULL) {
		printf("Unable to create wait thread: %s\n", SDL_GetError());
		return -1;
	}

	printf("Creating wait thread\n");
	return 0;
}

// Runs on main thread
static int enable(lua_State *L)
{
	if (!wait_thread) return 0;
//	SDL_GL_MakeCurrent(window, NULL);
	enabled = 2;
//	SDL_SemPost(start_sem);
	return 0;
}

// Runs on main thread
static int disable(lua_State *L)
{
	if (!wait_thread) return 0;
	enabled = 0;
	SDL_SemWait(end_sem);
	SDL_GL_MakeCurrent(window, maincontext);
	int w, h;
	SDL_GetWindowSize(window, &w, &h);
	resizeWindow(w, h);
	return 0;
}

static const struct luaL_reg mainlib[] =
{
	{"createThread", create_wait_thread},
	{"enable", enable},
	{"disable", disable},
	{NULL, NULL},
};

int luaopen_wait(lua_State *L)
{
	luaL_openlib(L, "core.wait", mainlib, 0);
	lua_pop(L, 1);
	return 1;
}

