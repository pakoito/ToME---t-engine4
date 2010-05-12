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
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <SDL_mixer.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "SFMT.h"

#include "types.h"
#include "script.h"
#include "physfs.h"
#include "core_lua.h"
#include "getself.h"
#include "music.h"
#include "main.h"

#define WIDTH 800
#define HEIGHT 600

lua_State *L = NULL;
int current_mousehandler = LUA_NOREF;
int current_keyhandler = LUA_NOREF;
int current_game = LUA_NOREF;
bool exit_engine = FALSE;
bool no_sound = FALSE;

static int traceback (lua_State *L) {
	lua_Debug ar;
	int n;
	n = 0;
	printf("Lua Error: %s\n", lua_tostring(L, 1));
	while(lua_getstack(L, n++, &ar)) {
		lua_getinfo(L, "nSl", &ar);
		printf("\tAt %s:%d %s\n", ar.short_src, ar.currentline, ar.name?ar.name:"");
	}
	return 1;
}

static int docall (lua_State *L, int narg, int nret)
{
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	status = lua_pcall(L, narg, nret, base);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

void display_utime()
{
	struct timeval tv;
	struct timezone tz;
	struct tm *tm;
	gettimeofday(&tv, &tz);
	tm=localtime(&tv.tv_sec);
	printf(" %d:%02d:%02d %d \n", tm->tm_hour, tm->tm_min, tm->tm_sec, tv.tv_usec);
}

// define our data that is passed to our redraw function
typedef struct {
	Uint32 color;
} MainStateData;

int event_filter(const SDL_Event *event)
{
	// Do not allow the user to close without asking the game to know about it
	if (event->type == SDL_QUIT && (current_game != LUA_NOREF))
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "onQuit");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		docall(L, 1, 0);

		return 0;
	}
	return 1;
}

void on_event(SDL_Event *event)
{
	switch (event->type) {
	case SDL_KEYDOWN:
		if (current_keyhandler != LUA_NOREF)
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_keyhandler);
			lua_pushstring(L, "receiveKey");
			lua_gettable(L, -2);
			lua_remove(L, -2);
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_keyhandler);
			lua_pushnumber(L, event->key.keysym.sym);
			lua_pushboolean(L, (event->key.keysym.mod & KMOD_CTRL) ? TRUE : FALSE);
			lua_pushboolean(L, (event->key.keysym.mod & KMOD_SHIFT) ? TRUE : FALSE);
			lua_pushboolean(L, (event->key.keysym.mod & KMOD_ALT) ? TRUE : FALSE);
			lua_pushboolean(L, (event->key.keysym.mod & KMOD_META) ? TRUE : FALSE);
			/* Convert unicode UCS-2 to UTF8 string */
			if (event->key.keysym.unicode)
			{
				wchar_t wc = event->key.keysym.unicode;

				char buf[4] = {0,0,0,0};
				if (wc < 0x80)
				{
					buf[0] = wc;
				}
				else if (wc < 0x800)
				{
					buf[0] = (0xC0 | wc>>6);
					buf[1] = (0x80 | wc & 0x3F);
				}
				else
				{
					buf[0] = (0xE0 | wc>>12);
					buf[1] = (0x80 | wc>>6 & 0x3F);
					buf[2] = (0x80 | wc & 0x3F);
				}

				lua_pushstring(L, buf);
			}
			else
				lua_pushnil(L);
			docall(L, 7, 0);
		}
		break;
	case SDL_MOUSEBUTTONUP:
		if (current_mousehandler != LUA_NOREF)
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_mousehandler);
			lua_pushstring(L, "receiveMouse");
			lua_gettable(L, -2);
			lua_remove(L, -2);
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_mousehandler);
			switch (event->button.button)
			{
			case SDL_BUTTON_LEFT:
				lua_pushstring(L, "left");
				break;
			case SDL_BUTTON_MIDDLE:
				lua_pushstring(L, "middle");
				break;
			case SDL_BUTTON_RIGHT:
				lua_pushstring(L, "right");
				break;
			case SDL_BUTTON_WHEELUP:
				lua_pushstring(L, "wheelup");
				break;
			case SDL_BUTTON_WHEELDOWN:
				lua_pushstring(L, "wheeldown");
				break;
			}
			lua_pushnumber(L, event->button.x);
			lua_pushnumber(L, event->button.y);
			docall(L, 4, 0);
		}
		break;
	case SDL_MOUSEMOTION:
		if (current_mousehandler != LUA_NOREF)
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_mousehandler);
			lua_pushstring(L, "receiveMouseMotion");
			lua_gettable(L, -2);
			lua_remove(L, -2);
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_mousehandler);
			if (event->motion.state & SDL_BUTTON(1)) lua_pushstring(L, "left");
			else if (event->motion.state & SDL_BUTTON(2)) lua_pushstring(L, "middle");
			else if (event->motion.state & SDL_BUTTON(3)) lua_pushstring(L, "right");
			else if (event->motion.state & SDL_BUTTON(4)) lua_pushstring(L, "wheelup");
			else if (event->motion.state & SDL_BUTTON(5)) lua_pushstring(L, "wheeldown");
			else lua_pushstring(L, "none");
			lua_pushnumber(L, event->motion.x);
			lua_pushnumber(L, event->motion.y);
			lua_pushnumber(L, event->motion.xrel);
			lua_pushnumber(L, event->motion.yrel);
			docall(L, 6, 0);
		}
		break;
	}
}

// redraw the screen and update game logics, if any
void on_tick()
{
	static int Frames = 0;
	static int T0     = 0;

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "tick");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		docall(L, 1, 0);
	}

	/* Gather our frames per second */
	Frames++;
	{
		int t = SDL_GetTicks();
		if (t - T0 >= 10000) {
			float seconds = (t - T0) / 1000.0;
			float fps = Frames / seconds;
			printf("%d ticks  in %g seconds = %g TPS\n", Frames, seconds, fps);
			T0 = t;
			Frames = 0;
		}
	}
}

void on_redraw()
{
	static int Frames = 0;
	static int T0     = 0;

	glClear( GL_COLOR_BUFFER_BIT);
	glLoadIdentity();

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "display");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		docall(L, 1, 0);
	}

	SDL_GL_SwapBuffers();

	/* Gather our frames per second */
	Frames++;
	{
		int t = SDL_GetTicks();
		if (t - T0 >= 10000) {
			float seconds = (t - T0) / 1000.0;
			float fps = Frames / seconds;
			printf("%d frames in %g seconds = %g FPS\n", Frames, seconds, fps);
			T0 = t;
			Frames = 0;
		}
	}
}

void pass_command_args(int argc, char *argv[])
{
	int i;

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "commandLineArgs");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_newtable(L);

		for (i = 1; i <= argc; i++)
		{
			lua_pushnumber(L, i);
			lua_pushstring(L, argv[i]);
			lua_settable(L, -3);
		}
		docall(L, 2, 0);
	}
}

int redraw_pending = 0;

Uint32 redraw_timer(Uint32 interval, void *param)
{
	SDL_Event event;
	SDL_UserEvent userevent;

	/* In this example, our callback pushes an SDL_USEREVENT event
	 into the queue, and causes ourself to be called again at the
	 same interval: */

	userevent.type = SDL_USEREVENT;
	userevent.code = 0;
	userevent.data1 = NULL;
	userevent.data2 = NULL;

	event.type = SDL_USEREVENT;
	event.user = userevent;

	if (!redraw_pending) {
		SDL_PushEvent(&event);
		redraw_pending = 1;
	}
	return(interval);
}

/* general OpenGL initialization function */
int initGL()
{
	/* Enable smooth shading */
//	glShadeModel( GL_SMOOTH );

	/* Set the background black */
	glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );

	/* Depth buffer setup */
//	glClearDepth( 1.0f );

	/* Enables Depth Testing */
//	glEnable( GL_DEPTH_TEST );

	/* The Type Of Depth Test To Do */
//	glDepthFunc( GL_LEQUAL );

	/* Really Nice Perspective Calculations */
	//	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
//	glDisable(GL_DEPTH_TEST);
	glColor4f(1.0f,1.0f,1.0f,1.0f);
//	glAlphaFunc(GL_GREATER,0.1f);

	return( TRUE );
}

int resizeWindow(int width, int height)
{
	/* Height / width ration */
	GLfloat ratio;

	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	initGL();

	/* Protect against a divide by zero */
	if ( height == 0 )
		height = 1;

	ratio = ( GLfloat )width / ( GLfloat )height;

	glEnable( GL_TEXTURE_2D );

	/* Setup our viewport. */
	glViewport( 0, 0, ( GLsizei )width, ( GLsizei )height );

	/* change to the projection matrix and set our viewing volume. */
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	/* Set our perspective */
	//gluPerspective( 45.0f, ratio, 0.1f, 100.0f );
	glOrtho(0, width, height, 0, -100, 100);

	/* Make sure we're chaning the model view and not the projection */
	glMatrixMode( GL_MODELVIEW );

	/* Reset The View */
	glLoadIdentity( );

//	glEnable(GL_ALPHA_TEST);
//	glColor4f(1.0f,1.0f,1.0f,1.0f);

	return( TRUE );
}

void do_resize(int w, int h, bool fullscreen)
{
	int flags = SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_HWSURFACE | SDL_RESIZABLE;

	if (fullscreen) flags = SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_HWSURFACE | SDL_FULLSCREEN;

	screen = SDL_SetVideoMode(w, h, 32, flags);
	if (screen==NULL) {
		printf("error opening screen: %s\n", SDL_GetError());
		return 0;
	}

	resizeWindow(screen->w, screen->h);
}

/**
 * Program entry point.
 */

// Let some platforms use a different entry point
#ifdef USE_TENGINE_MAIN
#define main tengine_main
#endif

int main(int argc, char *argv[])
{
	const char *selfexe;

	// RNG init
	init_gen_rand(time(NULL));

	/***************** Physfs Init *****************/
	PHYSFS_init(argv[0]);

	selfexe = get_self_executable(argc, argv);
	if (selfexe)
	{
		PHYSFS_mount(selfexe, "/", 1);
	}
	else
	{
		printf("NO SELFEXE: bootstrapping from CWD\n");
		PHYSFS_mount("bootstrap", "/bootstrap", 1);
	}

	/***************** Lua Init *****************/
	L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaopen_socket_core(L);
	luaopen_mime_core(L);
	luaopen_struct(L);
	luaopen_profiler(L);
	luaopen_lanes(L);
	luaopen_lpeg(L);
	luaopen_map(L);
	luaopen_particles(L);
	luaopen_sound(L);

	// Make the uids repository
	lua_newtable(L);
	lua_setglobal(L, "__uids");

	// Tell the boostrapping code the selfexe path
	if (selfexe)
		lua_pushstring(L, selfexe);
	else
		lua_pushnil(L);
	lua_setglobal(L, "__SELFEXE");

	// Run bootstrapping
	if (!luaL_loadfile(L, "/bootstrap/boot.lua"))
	{
		docall(L, 0, 0);
	}
	// Could not load bootstrap! Try to mount the engine from working directory as last resort
	else
	{
		printf("WARNING: No bootstrap code found, defaulting to working directory for engine code!\n");
		PHYSFS_mount("game/thirdparty", "/", 1);
		PHYSFS_mount("game/", "/", 1);
	}

	// And run the lua engine pre init scripts
	luaL_loadfile(L, "/engine/pre-init.lua");
	docall(L, 0, 0);

	// initialize engine and set up resolution and depth
	Uint32 flags=SDL_INIT_VIDEO | SDL_INIT_TIMER;
	if (SDL_Init (flags) < 0) {
		printf("cannot initialize SDL: %s\n", SDL_GetError ());
		return;
	}

	SDL_WM_SetIcon(IMG_Load_RW(PHYSFSRWOPS_openRead("/data/gfx/te4-icon.png"), TRUE), NULL);

//	screen = SDL_SetVideoMode(WIDTH, HEIGHT, 32, SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_HWSURFACE | SDL_RESIZABLE);
	do_resize(WIDTH, HEIGHT, FALSE);
	if (screen==NULL) {
		printf("error opening screen: %s\n", SDL_GetError());
		return;
	}
	SDL_WM_SetCaption("T4Engine", NULL);
	SDL_EnableUNICODE(TRUE);
	SDL_EnableKeyRepeat(300, 10);
	TTF_Init();
	if (Mix_OpenAudio(22050, AUDIO_S16, 2, 2048) == -1)
	{
		no_sound = TRUE;
	}
	else
	{
		Mix_VolumeMusic(SDL_MIX_MAXVOLUME);
		Mix_Volume(-1, SDL_MIX_MAXVOLUME);
		Mix_AllocateChannels(16);
	}

	/* Sets up OpenGL double buffering */
	resizeWindow(WIDTH, HEIGHT);

	// And run the lua engine scripts
	luaL_loadfile(L, "/engine/init.lua");
	docall(L, 0, 0);

	pass_command_args(argc, argv);

	// Filter events, to catch the quit event
	SDL_SetEventFilter(event_filter);

	SDL_AddTimer(30, redraw_timer, NULL);

	SDL_Event event;
	while (!exit_engine)
	{
		/* handle the events in the queue */
		while (SDL_PollEvent(&event))
		{
			switch(event.type)
			{
			case SDL_VIDEORESIZE:
				printf("resize %d x %d\n", event.resize.w, event.resize.h);
				do_resize(event.resize.w, event.resize.h, FALSE);

				if (current_game != LUA_NOREF)
				{
					lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
					lua_pushstring(L, "onResolutionChange");
					lua_gettable(L, -2);
					lua_remove(L, -2);
					lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
					docall(L, 1, 0);
				}

				break;

			case SDL_MOUSEMOTION:
			case SDL_MOUSEBUTTONUP:
			case SDL_KEYDOWN:
				/* handle key presses */
				on_event(&event);
				break;
			case SDL_QUIT:
				/* handle quit requests */
				exit_engine = TRUE;
				break;
			case SDL_USEREVENT:
				if (event.user.code == 0) {
					on_redraw();
					redraw_pending = 0;
				}
				break;
			default:
				break;
			}
		}

		/* draw the scene */
		on_tick();
	}

	SDL_Quit();

	return 0;
}
