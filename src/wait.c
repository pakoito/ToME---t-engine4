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
extern SDL_Surface *screen;
extern SDL_GLContext maincontext; /* Our opengl context handle */
SDL_GLContext waitcontext; /* Our opengl context handle */
static SDL_Thread *wait_thread = NULL;
static SDL_sem *start_sem, *end_sem;
static char* payload = NULL;
static bool enabled = FALSE;

static GLuint bkg_t;
static GLubyte *bkg_image = NULL;
static int bkg_realw=1;
static int bkg_realh=1;

extern int resizeWindow(int width, int height);
extern void on_redraw();

static int draw_last_frame(lua_State *L)
{
	int w, h;
	SDL_GetWindowSize(window, &w, &h);

	GLfloat btexcoords[2*4] = {
		0, (float)h/(float)bkg_realh,
		(float)w/(float)bkg_realw, (float)h/(float)bkg_realh,
		(float)w/(float)bkg_realw, 0,
		0, 0
	};
	GLfloat bcolors[4*4] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
	GLfloat bvertices[2*4] = {
		0, 0,
		w, 0,
		w, h,
		0, h,
	};
	glTexCoordPointer(2, GL_FLOAT, 0, btexcoords);
	glColorPointer(4, GL_FLOAT, 0, bcolors);
	tglBindTexture(GL_TEXTURE_2D, bkg_t);
	glVertexPointer(2, GL_FLOAT, 0, bvertices);
	glDrawArrays(GL_QUADS, 0, 4);
	return 0;
}

static const struct luaL_reg waitlib[] =
{
	{"drawLastFrame", draw_last_frame},
	{NULL, NULL},
};

static int thread_wait(void *data)
{
	lua_State *L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaL_openlib(L, "wait", waitlib, 0);
	lua_pop(L, 1);

	// And run the lua engine pre init scripts
	if (!luaL_loadfile(L, "/loader/pre-init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	int rot = 1;
	while (TRUE)
	{
		if (!enabled) SDL_SemWait(start_sem);

		if (enabled > 0)
		{
			if (enabled == 2)
			{
				int w, h;
				SDL_GetWindowSize(window, &w, &h);

				enabled = 1;

				if (!waitcontext)
				{
					waitcontext = SDL_GL_CreateContext(window);
					resizeWindow(w, h);
					glGenTextures(1, &bkg_t);
				}
				SDL_GL_MakeCurrent(window, waitcontext);

				// Bind the texture to read
				if (bkg_image)
				{
					tglBindTexture(GL_TEXTURE_2D, bkg_t);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
					// In case we can't support NPOT textures round up to nearest POT
					bkg_realw=1;
					bkg_realh=1;
					while (bkg_realw < w) bkg_realw *= 2;
					while (bkg_realh < h) bkg_realh *= 2;
					glTexImage2D(GL_TEXTURE_2D, 0, 3, bkg_realw, bkg_realh, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
					glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, bkg_image);
					printf("Make wait background texture %d : %dx%d (%d, %d)\n", bkg_t, w, h, bkg_realw, bkg_realh);
				}

				if (payload)
				{
					luaL_loadstring(L, payload);
					lua_call(L, 0, 0);
				}
			}
			SDL_Delay(50);

			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();

			lua_getglobal(L, "waitDisplay");
			if (lua_isnil(L, -1)) lua_pop(L, 1);
			else
			{
				if (lua_pcall(L, 0, 0, 0))
				{
					printf("Wait thread error: %s\n", lua_tostring(L, -1));
					lua_pop(L, 1);
				}
			}

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
				-100, -100,
				-100, 100,
				100, 100,
				100, -100,
			};
			glVertexPointer(2, GL_FLOAT, 0, vertices);
			glTranslatef(500, 500, 0);
			glRotatef(rot, 0, 0, 1);
			glDrawArrays(GL_QUADS, 0, 4);
			glRotatef(-rot, 0, 0, 1);
			glTranslatef(-500, -500, 0);
			rot++;

			SDL_GL_SwapWindow(window);
		}
		else if (enabled == -1)
		{
			SDL_SemPost(end_sem);
			enabled = 0;
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

	if (payload) { free(payload); payload = NULL; }

	if (lua_isstring(L, 1))
	{
		payload = strdup(lua_tostring(L, 1));
	}

	// Grab currently displayed stuff
	glPixelStorei(GL_PACK_ALIGNMENT, 1);
	if (bkg_image) free(bkg_image);
	bkg_image = (GLubyte*)malloc(screen->w * screen->h * 4 * sizeof(GLubyte));
	glReadPixels(0, 0, screen->w, screen->h, GL_RGBA, GL_UNSIGNED_BYTE, bkg_image);

	SDL_GL_MakeCurrent(window, NULL);
	enabled = 2;
	SDL_SemPost(start_sem);
	return 0;
}

// Runs on main thread
static int disable(lua_State *L)
{
	if (!wait_thread) return 0;
	enabled = -1;
	SDL_SemWait(end_sem);
	SDL_GL_MakeCurrent(window, maincontext);
	on_redraw();
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

