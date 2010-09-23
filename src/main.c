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
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luasocket.h"
#include "luasocket/mime.h"
#include "SFMT.h"

#include "types.h"
#include "script.h"
#include "physfs.h"
#include "physfsrwops.h"
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
bool reboot_lua = FALSE;
bool exit_engine = FALSE;
bool no_sound = FALSE;
bool isActive = TRUE;
bool tickPaused = FALSE;
SDL_TimerID realtime_timer_id = NULL;

/* OpenGL capabilities */
extern bool shaders_active;
bool fbo_active;
bool multitexture_active;

/* Some lua stuff that's external but has no headers */
int luaopen_mime_core(lua_State *L);
int luaopen_profiler(lua_State *L);
int luaopen_lpeg(lua_State *L);
int luaopen_map(lua_State *L);
int luaopen_particles(lua_State *L);
int luaopen_sound(lua_State *L);
int luaopen_lanes(lua_State *L);
int luaopen_shaders(lua_State *L);
int luaopen_noise(lua_State *L);
int luaopen_lxp(lua_State *L);

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
	case SDL_KEYUP:
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
			lua_pushboolean(L, (event->type == SDL_KEYUP) ? TRUE : FALSE);
			docall(L, 8, 0);
		}
		break;
	case SDL_MOUSEBUTTONDOWN:
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
			default:
				lua_pushstring(L, "button");
				lua_pushnumber(L, event->button.button);
				lua_concat(L, 2);
				break;
			}
			lua_pushnumber(L, event->button.x);
			lua_pushnumber(L, event->button.y);
			lua_pushboolean(L, (event->type == SDL_MOUSEBUTTONUP) ? TRUE : FALSE);
			docall(L, 5, 0);
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
		docall(L, 1, 1);
		tickPaused = lua_toboolean(L, -1);
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

void call_draw()
{
	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "display");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		docall(L, 1, 0);
	}
}

void on_redraw()
{
	static int Frames = 0;
	static int T0     = 0;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	call_draw();

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

void gl_selall(GLint hits, GLuint *buff)
{
	GLuint *p;
	int i;

	call_draw();

	p = buff;
	for (i = 0; i < 6 * 4; i++)
	{
		printf("Slot %d: - Value: %d\n", i, p[i]);
	}

	printf("Buff size: %x\n", (GLbyte)buff[0]);
}

void list_hits(GLint hits, GLuint *names)
{
	int i;

	/*
	 For each hit in the buffer are allocated 4 bytes:
	 1. Number of hits selected (always one,
	 beacuse when we draw each object
	 we use glLoadName, so we replace the
	 prevous name in the stack)
	 2. Min Z
	 3. Max Z
	 4. Name of the hit (glLoadName)
	 */

	printf("%d hits:\n", hits);

	for (i = 0; i < hits; i++)
		printf(	"Number: %d\n"
			"Min Z: %d\n"
			"Max Z: %d\n"
			"Name on stack: %d\n",
			(GLubyte)names[i * 4],
			(GLubyte)names[i * 4 + 1],
			(GLubyte)names[i * 4 + 2],
			(GLubyte)names[i * 4 + 3]
			);

	printf("\n");

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "onPickUI");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_newtable(L);

		for (i = 0; i < hits; i++)
		{
			lua_pushnumber(L, i+1);
			lua_pushnumber(L, names[i * 4 + 3]);
			lua_settable(L, -3);
		}
		docall(L, 2, 0);
	}

}

void gl_select(int x, int y)
{
	GLuint buff[64] = {0};
	GLint hits, view[4];
	int id;

	/*
	 This choose the buffer where store the values for the selection data
	 */
	glSelectBuffer(64, buff);

	/*
	 This retrieve info about the viewport
	 */
	glGetIntegerv(GL_VIEWPORT, view);

	/*
	 Switching in selecton mode
	 */
	glRenderMode(GL_SELECT);

	/*
	 Clearing the name's stack
	 This stack contains all the info about the objects
	 */
	glInitNames();

	/*
	 Now fill the stack with one element (or glLoadName will generate an error)
	 */
	glPushName(0);

	/*
	 Now modify the vieving volume, restricting selection area around the cursor
	 */
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();

	/*
	 restrict the draw to an area around the cursor
	 */
	gluPickMatrix(x, y, 5.0, 5.0, view);
	printf("view %d %d %d %d\n", view[0], view[1], view[2], view[3]);
	printf("pick %d %d\n", x,y);
//	gluPerspective(60, 1.0, 0.0001, 1000.0);
	glOrtho(0, screen->w, screen->h, 0, -101, 101);

	/*
	 Draw the objects onto the screen
	 */
	glMatrixMode(GL_MODELVIEW);

	/*
	 draw only the names in the stack, and fill the array
	 */
	call_draw();
//	SDL_GL_SwapBuffers();

	/*
	 Do you remeber? We do pushMatrix in PROJECTION mode
	 */
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();

	/*
	 get number of objects drawed in that area
	 and return to render mode
	 */
	hits = glRenderMode(GL_RENDER);

	/*
	 Print a list of the objects
	 */
	list_hits(hits, buff);

	/*
	 uncomment this to show the whole buffer
	 * /
	 gl_selall(hits, buff);
	 */

	glMatrixMode(GL_MODELVIEW);
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

	if (!redraw_pending && isActive) {
		SDL_PushEvent(&event);
		redraw_pending = 1;
	}
	return(interval);
}

int realtime_pending = 0;

Uint32 realtime_timer(Uint32 interval, void *param)
{
	SDL_Event event;
	SDL_UserEvent userevent;

	/* In this example, our callback pushes an SDL_USEREVENT event
	 into the queue, and causes ourself to be called again at the
	 same interval: */

	userevent.type = SDL_USEREVENT;
	userevent.code = 2;
	userevent.data1 = NULL;
	userevent.data2 = NULL;

	event.type = SDL_USEREVENT;
	event.user = userevent;

	if (!realtime_pending && isActive) {
		SDL_PushEvent(&event);
//		realtime_pending = 1;
	}
	return(interval);
}

// Calls the lua music callback
void on_music_stop()
{
	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "onMusicStop");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		if (lua_isfunction(L, -1))
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
			docall(L, 1, 0);
		}
		else
			lua_pop(L, 1);
	}
}

// Setup realtime
void setupRealtime(float freq)
{
	if (!freq)
	{
		if (realtime_timer_id) SDL_RemoveTimer(realtime_timer_id);
		printf("[ENGINE] Switching to turn based\n");
	}
	else
	{
		float interval = 1000 / freq;
		realtime_timer_id = SDL_AddTimer((int)interval, realtime_timer, NULL);
		printf("[ENGINE] Switching to realtime, interval %d ms\n", (int)interval);
	}
}

void create_mode_list()
{
	SDL_PixelFormat format;
	SDL_Rect **modes;
	int loops = 0;
	int bpp = 0;
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
		modes = SDL_ListModes(&format, SDL_FULLSCREEN);
		if (modes)
		{
			int i;
			for(i=0; modes[i]; ++i)
			{
				printf("Available resolutions: %dx%dx%d\n", modes[i]->w, modes[i]->h, bpp/*format.BitsPerPixel*/);
			}
		}
	}while(++loops != 3);
//	return mode_list;
}

/* general OpenGL initialization function */
int initGL()
{
	/* Enable smooth shading */
//	glShadeModel( GL_SMOOTH );

	/* Set the background black */
	glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );

	/* Depth buffer setup */
	glClearDepth( 1.0f );

	/* The Type Of Depth Test To Do */
	glDepthFunc(GL_LEQUAL);
//	glDepthFunc(GL_LESS);

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

//	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);

	/* Setup our viewport. */
	glViewport( 0, 0, ( GLsizei )width, ( GLsizei )height );

	/* change to the projection matrix and set our viewing volume. */
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	/* Set our perspective */
	//gluPerspective( 45.0f, ratio, 0.1f, 100.0f );
	glOrtho(0, width, height, 0, -101, 101);

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
	int flags = SDL_OPENGL | SDL_RESIZABLE;

	if (fullscreen) flags = SDL_OPENGL | SDL_FULLSCREEN;

	screen = SDL_SetVideoMode(w, h, 32, flags);
	if (screen==NULL) {
		printf("error opening screen: %s\n", SDL_GetError());
		return;
	}
	glewInit();

	resizeWindow(screen->w, screen->h);
}

void boot_lua(int state, bool rebooting, int argc, char *argv[])
{
	reboot_lua = FALSE;

	if (state == 1)
	{
		const char *selfexe;

		/* When rebooting we destroy the lua state to free memory and we reset physfs */
		if (rebooting)
		{
			lua_close(L);
			PHYSFS_deinit();
		}

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
		luaopen_lpeg(L);
		luaopen_lxp(L);
		luaopen_map(L);
		luaopen_particles(L);
		luaopen_sound(L);
		luaopen_noise(L);
		luaopen_shaders(L);

		// Make the uids repository
		lua_newtable(L);
		lua_setglobal(L, "__uids");

		// Tell the boostrapping code the selfexe path
		if (selfexe)
			lua_pushstring(L, selfexe);
		else
			lua_pushnil(L);
		lua_setglobal(L, "__SELFEXE");

		// Will be useful
#ifdef __APPLE__
		lua_pushboolean(L, TRUE);
		lua_setglobal(L, "__APPLE__");
#endif

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
		luaL_loadfile(L, "/loader/pre-init.lua");
		docall(L, 0, 0);
	}
	else if (state == 2)
	{
		SDL_WM_SetCaption("T4Engine", NULL);

		// Now we can open lua lanes, the physfs paths are set and it can load it's lanes-keeper.lua file
		luaopen_lanes(L);

		// And run the lua engine scripts
		luaL_loadfile(L, "/loader/init.lua");
		docall(L, 0, 0);
	}
}

/**
 * Program entry point.
 */

// Let some platforms use a different entry point
#ifdef USE_TENGINE_MAIN
#ifdef main
#undef main
#endif
#define main tengine_main
#endif

int main(int argc, char *argv[])
{
	// RNG init
	init_gen_rand(time(NULL));

	// Change to line buffering
	setvbuf(stdout, (char *) NULL, _IOLBF, 0);

	boot_lua(1, FALSE, argc, argv);

	// initialize engine and set up resolution and depth
	Uint32 flags=SDL_INIT_VIDEO | SDL_INIT_TIMER;
	if (SDL_Init (flags) < 0) {
		printf("cannot initialize SDL: %s\n", SDL_GetError ());
		return -1;
	}

	create_mode_list();

	SDL_WM_SetIcon(IMG_Load_RW(PHYSFSRWOPS_openRead("/engines/default/data/gfx/te4-icon.png"), TRUE), NULL);

//	screen = SDL_SetVideoMode(WIDTH, HEIGHT, 32, SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_HWSURFACE | SDL_RESIZABLE);
//	glewInit();
	do_resize(WIDTH, HEIGHT, FALSE);
	if (screen==NULL) {
		printf("error opening screen: %s\n", SDL_GetError());
		return -1;
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

	// Get OpenGL capabilities
	multitexture_active = GLEW_ARB_multitexture;
	shaders_active = GLEW_ARB_shader_objects;
	fbo_active = GLEW_EXT_framebuffer_object || GLEW_ARB_framebuffer_object;
	if (!multitexture_active) shaders_active = FALSE;
	if (!GLEW_VERSION_2_1)
	{
		multitexture_active = FALSE;
		shaders_active = FALSE;
		fbo_active = FALSE;
	}

	boot_lua(2, FALSE, argc, argv);

	pass_command_args(argc, argv);

	// Filter events, to catch the quit event
	SDL_SetEventFilter(event_filter);

	SDL_AddTimer(30, redraw_timer, NULL);

	SDL_Event event;
	while (!exit_engine)
	{
		if (!isActive || tickPaused) SDL_WaitEvent(NULL);

		/* handle the events in the queue */
		while (SDL_PollEvent(&event))
		{
			switch(event.type)
			{
			case SDL_ACTIVEEVENT:
/*				if ((event.active.state & SDL_APPACTIVE) || (event.active.state & SDL_APPINPUTFOCUS))
				{
					if (event.active.gain == 0)
						isActive = FALSE;
					else
						isActive = TRUE;
				}
				printf("SDL Activity %d\n", isActive);
*/				break;

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

			case SDL_MOUSEBUTTONUP:
//				gl_select(event.button.x, event.button.y);
			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEMOTION:
			case SDL_KEYDOWN:
			case SDL_KEYUP:
				/* handle key presses */
				on_event(&event);
				tickPaused = FALSE;
				break;
			case SDL_QUIT:
				/* handle quit requests */
				exit_engine = TRUE;
				break;
			case SDL_USEREVENT:
				if (event.user.code == 0 && isActive) {
					on_redraw();
					redraw_pending = 0;
				}
				else if (event.user.code == 2 && isActive) {
					on_tick();
					realtime_pending = 0;
				}
				else if (event.user.code == 1) {
					on_music_stop();
				}
				break;
			default:
				break;
			}
		}

		/* draw the scene */
		if (!realtime_timer_id && isActive && !tickPaused) on_tick();

		/* Reboot the lua engine */
		if (reboot_lua)
		{
			boot_lua(1, TRUE, argc, argv);
			boot_lua(2, TRUE, argc, argv);
		}
	}

	SDL_Quit();

	return 0;
}
