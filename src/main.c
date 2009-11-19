#include "display.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "fov/fov.h"
#include "sge.h"

#include "types.h"
#include "script.h"
#include "physfs.h"
#include "core_lua.h"

lua_State *L = NULL;
int current_keyhandler = LUA_NOREF;
int current_game = LUA_NOREF;
int px = 1, py = 1;

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

void on_event(SGEGAMESTATE *state, SDL_Event *event)
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
			lua_pushnumber(L, event->key.keysym.unicode);
			lua_call(L, 7, 0);
		}
		break;
	}
}

// redraw the screen and update game logics, if any
void on_redraw(SGEGAMESTATE *state)
{
	// prepare event and data variable form the gamestat passed to that
	// function
	SGEEVENTSTATE es = state->manager->event_state;
	MainStateData *data = (MainStateData*)state->data;

	// has the user closed the window?
	if (es.start.released) {
		sgeGameStateManagerQuit(state->manager);
		return;
	}

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "tick");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_call(L, 1, 0);
	}

	sgeLock(screen);
	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0x00, 0x00, 0x00));

	if (current_game != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_pushstring(L, "display");
		lua_gettable(L, -2);
		lua_remove(L, -2);
		lua_rawgeti(L, LUA_REGISTRYINDEX, current_game);
		lua_call(L, 1, 0);
	}

	sgeUnlock(screen);

	// finally display the screen
	sgeFlip();
}

static int traceback (lua_State *L) {
	printf("Lua Error: %s\n", lua_tostring(L, 1));
}

static int docall (lua_State *L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

/**
 * Program entry point.
 */
int run(int argc, char *argv[])
{
	/***************** Physfs Init *****************/
	PHYSFS_init(argv[0]);
	PHYSFS_mount("game/", "/", 1);
	PHYSFS_mount("game/modules/tome", "/tome", 1);

	/***************** Lua Init *****************/
	L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);

	// Make the uids repository
	lua_newtable(L);
	lua_setglobal(L, "__uids");

	/***************** SDL/SGE2D Init *****************/
	SGEGAMESTATEMANAGER *manager;
	SGEGAMESTATE *mainstate;
	MainStateData data;

	// initialize engine and set up resolution and depth
	sgeInit(NOAUDIO, NOJOYSTICK);
	sgeOpenScreen("T-Engine", 800, 600, 32, NOFULLSCREEN);
	SDL_EnableUNICODE(TRUE);
	SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
	TTF_Init();

	// add a new gamestate. you will usually have to add different gamestates
	// like 'main menu', 'game loop', 'load screen', etc.
	mainstate = sgeGameStateNew();
	mainstate->onRedraw = on_redraw;
	mainstate->onEvent = on_event;
	mainstate->data = &data;

	// now finally create the gamestate manager and change to the only state
	// we defined, which is the on_redraw function
	manager = sgeGameStateManagerNew();
	sgeGameStateManagerChange(manager, mainstate);

	// And run the lua engine scripts
	luaL_loadfile(L, "/engine/init.lua");
	docall(L, 0, LUA_MULTRET);

	// start the game running with 25 frames per seconds
	sgeGameStateManagerRun(manager, 25);

	// close the screen and quit
	sgeCloseScreen();
	return 0;
}
