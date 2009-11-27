#include "display.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "SFMT.h"

#include "types.h"
#include "script.h"
#include "physfs.h"
#include "core_lua.h"

lua_State *L = NULL;
int current_mousehandler = LUA_NOREF;
int current_keyhandler = LUA_NOREF;
int current_game = LUA_NOREF;
int px = 1, py = 1;

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
void on_redraw()
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

	sdlLock(screen);
	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0x00, 0x00, 0x00));

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "display");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		docall(L, 1, 0);
	}

	sdlUnlock(screen);

	// finally display the screen
	SDL_Flip(screen);

	/* Gather our frames per second */
	Frames++;
	{
		int t = SDL_GetTicks();
		if (t - T0 >= 1000) {
			float seconds = (t - T0) / 1000.0;
			float fps = Frames / seconds;
			printf("%d frames in %g seconds = %g FPS\n", Frames, seconds, fps);
			T0 = t;
			Frames = 0;
		}
	}
}

/**
 * Program entry point.
 */
int main(int argc, char *argv[])
{
	// RNG init
	init_gen_rand(time(NULL));

	/***************** Physfs Init *****************/
	PHYSFS_init(argv[0]);
	PHYSFS_mount("game/thirdparty", "/", 1);
	PHYSFS_mount("game/", "/", 1);
	PHYSFS_mount("game/modules/tome", "/mod", 1);
	PHYSFS_mount("game/modules/tome/data", "/data", 1);
	PHYSFS_mount("/home/dg/.tengine/4.0/tome/", "/", 1);
	PHYSFS_setWriteDir("/home/dg/.tengine/4.0/tome/");

	/***************** Lua Init *****************/
	L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaopen_socket_core(L);
	luaopen_mime_core(L);
	luaopen_struct(L);

	// Make the uids repository
	lua_newtable(L);
	lua_setglobal(L, "__uids");

	// initialize engine and set up resolution and depth
	Uint32 flags=SDL_INIT_VIDEO | SDL_INIT_TIMER;
	if (SDL_Init (flags) < 0) {
		printf("cannot initialize SDL: %s\n", SDL_GetError ());
		return;
	}
	screen = SDL_SetVideoMode(800, 600, 32, _DEFAULT_VIDEOMODE_FLAGS_);
	if (screen==NULL) {
		printf("error opening screen: %s\n", SDL_GetError());
		return;
	}
	SDL_WM_SetCaption("T4Engine", NULL);
	SDL_EnableUNICODE(TRUE);
	SDL_EnableKeyRepeat(300, 10);
	TTF_Init();

	// And run the lua engine scripts
	luaL_loadfile(L, "/engine/init.lua");
	docall(L, 0, 0);

	// Filter events, to catch the quit event
	SDL_SetEventFilter(event_filter);

	bool done = FALSE;
	SDL_Event event;
	while ( !done )
	{
		/* handle the events in the queue */
		while (SDL_PollEvent(&event))
		{
			switch(event.type)
			{
			case SDL_MOUSEMOTION:
			case SDL_MOUSEBUTTONUP:
			case SDL_KEYDOWN:
				/* handle key presses */
				on_event(&event);
				break;
			case SDL_QUIT:
				/* handle quit requests */
				done = TRUE;
				break;
			default:
				break;
			}
		}

		/* draw the scene */
		on_redraw();
	}

	return 0;
}
