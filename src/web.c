/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2014 Nicolas Casalini

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
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "physfs.h"
#include "core_lua.h"
#include "types.h"
#include "main.h"
#include "getself.h"
#include "te4web.h"
#include "web-external.h"
#include "lua_externs.h"

/*
 * Grab web browser methods -- availabe only here
 */
static bool webcore = FALSE;
static void (*te4_web_setup)(
	int, char**, char*,
	void*(*)(), void(*)(void*), void(*)(void*), void(*)(void*),
	void* (*)(int, int), void (*)(void*), void (*)(void*, int, int, const void*),
	void (*)(bool*, bool*, bool*, bool*),
	void (*)(int handlers, const char *fct, int nb_args, WebJsValue *args, WebJsValue *ret)
);
static void (*te4_web_initialize)(const char *locales, const char *pak);
static void (*te4_web_shutdown)();
static void (*te4_web_do_update)(void (*cb)(WebEvent*));
static void (*te4_web_new)(web_view_type *view, int w, int h);
static bool (*te4_web_close)(web_view_type *view);
static void* (*te4_web_toscreen)(web_view_type *view, int *w, int *h);
static bool (*te4_web_loading)(web_view_type *view);
static void (*te4_web_focus)(web_view_type *view, bool focus);
static void (*te4_web_inject_mouse_move)(web_view_type *view, int x, int y);
static void (*te4_web_inject_mouse_wheel)(web_view_type *view, int x, int y);
static void (*te4_web_inject_mouse_button)(web_view_type *view, int kind, bool up);
static void (*te4_web_inject_key)(web_view_type *view, int scancode, int asymb, const char *uni, int unilen, bool up);
static void (*te4_web_download_action)(web_view_type *view, long id, const char *path);
static void (*te4_web_reply_local)(int id, const char *mime, const char *result, size_t len);
static void (*te4_web_load_url)(web_view_type *view, const char *url);
static void (*te4_web_set_js_call)(web_view_type *view, const char *name);

static int lua_web_new(lua_State *L) {
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);

	web_view_type *view = (web_view_type*)lua_newuserdata(L, sizeof(web_view_type));
	auxiliar_setclass(L, "web{view}", -1);

	lua_pushvalue(L, 3);
	view->handlers = luaL_ref(L, LUA_REGISTRYINDEX);

	te4_web_new(view, w, h);

	return 1;
}

static int lua_web_close(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (!te4_web_close(view)) {
		luaL_unref(L, LUA_REGISTRYINDEX, view->handlers);
	}
	return 0;
}

static int lua_web_load_url(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	const char* url = luaL_checkstring(L, 2);
	te4_web_load_url(view, url);
	return 0;
}

static int lua_web_usable(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int w = -1, h = -1;
	GLuint *tex = (GLuint*)te4_web_toscreen(view, &w, &h);
	lua_pushboolean(L, tex ? TRUE : FALSE);
	return 1;
}

static int lua_web_toscreen(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	int w = -1;
	int h = -1;
	if (lua_isnumber(L, 4)) w = lua_tonumber(L, 4);
	if (lua_isnumber(L, 5)) h = lua_tonumber(L, 5);
	GLuint *tex = (GLuint*)te4_web_toscreen(view, &w, &h);

	if (tex) {
		float r = 1, g = 1, b = 1, a = 1;

		glBindTexture(GL_TEXTURE_2D, *tex);

		GLfloat texcoords[2*4] = {
			0, 0,
			0, 1,
			1, 1,
			1, 0,
		};
		GLfloat colors[4*4] = {
			r, g, b, a,
			r, g, b, a,
			r, g, b, a,
			r, g, b, a,
		};
		glColorPointer(4, GL_FLOAT, 0, colors);
		glTexCoordPointer(2, GL_FLOAT, 0, texcoords);

		GLfloat vertices[2*4] = {
			x, y,
			x, y + h,
			x + w, y + h,
			x + w, y,
		};
		glVertexPointer(2, GL_FLOAT, 0, vertices);

		glDrawArrays(GL_QUADS, 0, 4);
	}
	return 0;
}

static int lua_web_loading(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);

	lua_pushboolean(L, te4_web_loading(view));
	return 1;
}

static int lua_web_focus(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	te4_web_focus(view, lua_toboolean(L, 2));
	return 0;
}

static int lua_web_inject_mouse_move(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	te4_web_inject_mouse_move(view, x, y);
	return 0;
}

static int lua_web_inject_mouse_wheel(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	te4_web_inject_mouse_wheel(view, x, y);
	return 0;
}

static int lua_web_inject_mouse_button(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	bool up = lua_toboolean(L, 2);
	int kind = luaL_checknumber(L, 3);

	te4_web_inject_mouse_button(view, kind, up);
	return 0;
}

static int lua_web_inject_key(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	bool up = lua_toboolean(L, 2);
	int scancode = lua_tonumber(L, 3);
	int asymb = lua_tonumber(L, 4);
	const char *uni = NULL;
	size_t unilen = 0;
	if (lua_isstring(L, 5)) uni = lua_tolstring(L, 5, &unilen);

	te4_web_inject_key(view, scancode, asymb, uni, unilen, up);
	return 0;
}

static int lua_web_download_action(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	long id = lua_tonumber(L, 2);
	if (lua_isstring(L, 3)) te4_web_download_action(view, id, lua_tostring(L, 3));
	else te4_web_download_action(view, id, NULL);
	return 0;
}

static int lua_web_set_method(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	const char *name = luaL_checkstring(L, 2);
	te4_web_set_js_call(view, name);
	return 0;
}

static int lua_web_local_reply_file(lua_State *L) {
	int id = lua_tonumber(L, 1);
	const char *mime = luaL_checkstring(L, 2);
	const char *file = luaL_checkstring(L, 3);

	PHYSFS_file *f = PHYSFS_openRead(file);
	if (!f) {
		te4_web_reply_local(id, mime, NULL, 0);
		return 0;
	}

	size_t len = PHYSFS_fileLength(f);
	char *data = malloc(len * sizeof(char));
	size_t read = 0;
	while (read < len) {
		size_t rl = PHYSFS_read(f, data + read, sizeof(char), len - read);
		if (rl <= 0) break;
		read += rl;
	}
	PHYSFS_close(f);

	te4_web_reply_local(id, mime, data, read);
	return 0;
}

static int lua_web_local_reply_data(lua_State *L) {
	int id = lua_tonumber(L, 1);
	const char *mime = luaL_checkstring(L, 2);
	size_t len;
	const char *data = luaL_checklstring(L, 3, &len);

	te4_web_reply_local(id, mime, data, len);
	return 0;
}

static const struct luaL_Reg view_reg[] =
{
	{"__gc", lua_web_close},
	{"usable", lua_web_usable},
	{"downloadAction", lua_web_download_action},
	{"loadURL", lua_web_load_url},
	{"toScreen", lua_web_toscreen},
	{"focus", lua_web_focus},
	{"loading", lua_web_loading},
	{"injectMouseMove", lua_web_inject_mouse_move},
	{"injectMouseWheel", lua_web_inject_mouse_wheel},
	{"injectMouseButton", lua_web_inject_mouse_button},
	{"injectKey", lua_web_inject_key},
	{"setMethod", lua_web_set_method},
	{NULL, NULL},
};

static const struct luaL_Reg weblib[] =
{
	{"new", lua_web_new},
	{"localReplyData", lua_web_local_reply_data},
	{"localReplyFile", lua_web_local_reply_file},
	{NULL, NULL},
};

int browsers_count = 0;
static lua_State *he_L;
static void handle_event(WebEvent *event) {
	switch (event->kind) {
		case TE4_WEB_EVENT_TITLE_CHANGE:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_title");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushstring(he_L, event->data.title);
				docall(he_L, 1, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_REQUEST_POPUP_URL:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_popup");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushstring(he_L, event->data.popup.url);
				lua_pushnumber(he_L, event->data.popup.w);
				lua_pushnumber(he_L, event->data.popup.h);
				docall(he_L, 3, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_DOWNLOAD_REQUEST:
			printf("[WEBCORE] download request %ld = %s :: %s :: %s\n", event->data.download_request.id, event->data.download_request.url, event->data.download_request.name, event->data.download_request.mime);
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_download_request");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushnumber(he_L, event->data.download_request.id);
				lua_pushstring(he_L, event->data.download_request.url);
				lua_pushstring(he_L, event->data.download_request.name);
				lua_pushstring(he_L, event->data.download_request.mime);
				docall(he_L, 4, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_DOWNLOAD_UPDATE:
			printf("[WEBCORE] download update %ld = %ld :: %ld :: %d :: %ld\n", event->data.download_update.id, event->data.download_update.got, event->data.download_update.total, event->data.download_update.percent, event->data.download_update.speed);
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_download_update");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushnumber(he_L, event->data.download_update.id);
				lua_pushnumber(he_L, event->data.download_update.got);
				lua_pushnumber(he_L, event->data.download_update.total);
				lua_pushnumber(he_L, event->data.download_update.percent);
				lua_pushnumber(he_L, event->data.download_update.speed);
				docall(he_L, 5, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_DOWNLOAD_FINISH:
			printf("[WEBCORE] download finish %ld\n", event->data.download_finish.id);
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_download_finish");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushnumber(he_L, event->data.download_finish.id);
				docall(he_L, 1, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_LOADING:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_loading");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushstring(he_L, event->data.loading.url);
				lua_pushnumber(he_L, event->data.loading.status);
				docall(he_L, 2, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_END_BROWSER:
			lua_rawgeti(he_L, LUA_REGISTRYINDEX, event->handlers);
			lua_pushstring(he_L, "on_crash");
			lua_gettable(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				docall(he_L, 0, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_LOCAL_REQUEST:
			lua_getglobal(he_L, "core");
			lua_getfield(he_L, -1, "webview");
			lua_getfield(he_L, -1, "responder");
			lua_remove(he_L, -2);
			lua_remove(he_L, -2);
			if (!lua_isnil(he_L, -1)) {
				lua_pushnumber(he_L, event->data.local_request.id);
				lua_pushstring(he_L, event->data.local_request.path);
				docall(he_L, 2, 0);
			} else lua_pop(he_L, 1);
			break;

		case TE4_WEB_EVENT_RUN_LUA:
			if (!luaL_loadstring(he_L, event->data.run_lua.code)) {
				docall(he_L, 0, 0);
			} else {
				printf("[WEBCORE] Failed to run lua code:\n%s\n ==>> Error: %s\n", event->data.run_lua.code, lua_tostring(he_L, -1));
				lua_pop(he_L, 1);
			}
			break;
		case TE4_WEB_EVENT_DELETE_TEXTURE:
			break;
		case TE4_WEB_EVENT_BROWSER_COUNT:
			browsers_count = event->data.count;
			printf("[WEBCORE] Browser count %d\n", browsers_count);
			break;
	}
}

void te4_web_update(lua_State *L) {
	if (webcore) {
		he_L = L;
		te4_web_do_update(handle_event);		
	}
}

void te4_web_init(lua_State *L) {
	if (!webcore) return;

	char *locales = PHYSFS_getDependentPath("/cef3/locales/");
	char *pak = PHYSFS_getDependentPath("/cef3/");
	te4_web_initialize(locales, pak);
	free(locales);
	free(pak);

	auxiliar_newclass(L, "web{view}", view_reg);
	luaL_openlib(L, "core.webview", weblib, 0);
	lua_pushstring(L, "kind");
	lua_pushstring(L, "cef3");
	lua_settable(L, -3);
	lua_settop(L, 0);
}

static void *web_mutex_create() {
	return (void*)SDL_CreateMutex();
}
static void web_mutex_destroy(void *mutex) {
	SDL_DestroyMutex((SDL_mutex*)mutex);
}
static void web_mutex_lock(void *mutex) {
	SDL_mutexP((SDL_mutex*)mutex);
}
static void web_mutex_unlock(void *mutex) {
	SDL_mutexV((SDL_mutex*)mutex);
}

static void *web_make_texture(int w, int h) {
	GLuint *tex = malloc(sizeof(GLuint));
	glGenTextures(1, tex);
	glBindTexture(GL_TEXTURE_2D, *tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	GLfloat largest_supported_anisotropy;
	glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &largest_supported_anisotropy);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, largest_supported_anisotropy);
	unsigned char *buffer = calloc(w * h * 4, sizeof(unsigned char));
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
	free(buffer);

	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("[WEBCORE] failing making a %dx%d texture, status %d\n", w, h, err);
		glDeleteTextures(1, tex);
		free(tex);
		return NULL;
	}
	return tex;
}
static void web_del_texture(void *tex) {
	if (!tex) return;
	GLuint t = *((GLuint*)tex);
	glDeleteTextures(1, &t);
	free(tex);
}
static void web_texture_update(void *tex, int w, int h, const void* buffer) {
	if (!tex) return;
	GLuint t = *((GLuint*)tex);
	tglBindTexture(GL_TEXTURE_2D, t);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
}

static void web_key_mods(bool *shift, bool *ctrl, bool *alt, bool *meta) {
	SDL_Keymod smod = SDL_GetModState();

	*shift = *ctrl = *alt = *meta = FALSE;
	if (smod & KMOD_SHIFT) *shift = TRUE;
	if (smod & KMOD_CTRL) *ctrl = TRUE;
	if (smod & KMOD_ALT) *alt = TRUE;
	if (smod & KMOD_GUI) *meta = TRUE;
}

static void web_instant_js(int handlers, const char *fct, int nb_args, WebJsValue *args, WebJsValue *ret) {
	lua_rawgeti(he_L, LUA_REGISTRYINDEX, handlers);
	lua_pushstring(he_L, fct);
	lua_gettable(he_L, -2);
	lua_remove(he_L, -2);
	if (!lua_isnil(he_L, -1)) {
		int i;
		for (i = 0; i < nb_args; i++) {
			if (args[i].kind == TE4_WEB_JS_NULL) lua_pushnil(he_L);
			else if (args[i].kind == TE4_WEB_JS_BOOLEAN) lua_pushboolean(he_L, args[i].data.b);
			else if (args[i].kind == TE4_WEB_JS_NUMBER) lua_pushnumber(he_L, args[i].data.n);
			else if (args[i].kind == TE4_WEB_JS_STRING) lua_pushstring(he_L, args[i].data.s);
		}
		if (!docall(he_L, nb_args, 1)) {
			if (lua_isnumber(he_L, -1)) {
				ret->kind = TE4_WEB_JS_NUMBER;
				ret->data.n = lua_tonumber(he_L, -1);
			} else if (lua_isstring(he_L, -1)) {
				ret->kind = TE4_WEB_JS_STRING;
				ret->data.s = lua_tostring(he_L, -1);
			} else if (lua_isboolean(he_L, -1)) {
				ret->kind = TE4_WEB_JS_BOOLEAN;
				ret->data.b = lua_toboolean(he_L, -1);
			} else {
				ret->kind = TE4_WEB_JS_NULL;
			}
			lua_pop(he_L, 1);
		} else {
			ret->kind = TE4_WEB_JS_NULL;
		}
	} else {
		ret->kind = TE4_WEB_JS_NULL;
		lua_pop(he_L, 1);
	}
}

void te4_web_load() {
	char *spawnname = NULL;
	char *libname = NULL;
	const char *self = get_self_executable(g_argc, g_argv);
#if defined(SELFEXE_LINUX) || defined(SELFEXE_BSD)
#if defined(TE4_RELPATH64)
	const char *spawnbname = "cef3spawn64";
	spawnname = malloc(strlen(self) + strlen(spawnbname) + 1);
	strcpy(spawnname, self);
	strcpy(strrchr(spawnname, '/') + 1, spawnbname);
	const char *name = "lib64/libte4-web.so";
	char *lib = malloc(strlen(self) + strlen(name) + 1);
	strcpy(lib, self);
	strcpy(strrchr(lib, '/') + 1, name);
	libname = lib;
	void *web = SDL_LoadObject(lib);
#elif defined(TE4_RELPATH32)
	const char *spawnbname = "cef3spawn32";
	spawnname = malloc(strlen(self) + strlen(spawnbname) + 1);
	strcpy(spawnname, self);
	strcpy(strrchr(spawnname, '/') + 1, spawnbname);
	const char *name = "lib/libte4-web.so";
	char *lib = malloc(strlen(self) + strlen(name) + 1);
	strcpy(lib, self);
	strcpy(strrchr(lib, '/') + 1, name);
	libname = lib;
	void *web = SDL_LoadObject(lib);
#else
	const char *spawnbname = "cef3spawn";
	spawnname = malloc(strlen(self) + strlen(spawnbname) + 1);
	strcpy(spawnname, self);
	strcpy(strrchr(spawnname, '/') + 1, spawnbname);
	const char *name = "libte4-web.so";
	char *lib = malloc(strlen(self) + strlen(name) + 1);
	strcpy(lib, self);
	strcpy(strrchr(lib, '/') + 1, name);
	libname = lib;
	void *web = SDL_LoadObject(lib);
#endif
#elif defined(SELFEXE_WINDOWS)
	const char *spawnbname = "cef3spawn.exe";
	spawnname = malloc(strlen(self) + strlen(spawnbname) + 1);
	strcpy(spawnname, self);
	strcpy(strrchr(spawnname, '\\') + 1, spawnbname);
	const char *name = "te4-web.dll";
	char *lib = malloc(strlen(self) + strlen(name) + 1);
	strcpy(lib, self);
	strcpy(strrchr(lib, '\\') + 1, name);
	libname = lib;
	void *web = SDL_LoadObject(lib);
#elif defined(SELFEXE_MACOSX)
	spawnname = NULL;
	const char *name = "libte4-web.dylib";
	char *lib = malloc(strlen(self) + strlen(name) + 1);
	strcpy(lib, self);
	strcpy(lib+strlen(self), name);
	libname = lib;
	void *web = SDL_LoadObject(lib);
#else
	void *web = NULL;
#endif
	printf("WebCore config: library(%s) spawn(%s)\n", libname ? libname : "--", spawnname ? spawnname : "--");
	printf("Loading WebCore: %s\n", web ? "loaded!" : SDL_GetError());

	if (web) {
		webcore = TRUE;
		te4_web_setup = (void (*)(
			int, char**, char*,
			void*(*)(), void(*)(void*), void(*)(void*), void(*)(void*),
			void* (*)(int, int), void (*)(void*), void (*)(void*, int, int, const void*),
			void (*)(bool*, bool*, bool*, bool*),
			void (*)(int handlers, const char *fct, int nb_args, WebJsValue *args, WebJsValue *ret)
		)) SDL_LoadFunction(web, "te4_web_setup");
		te4_web_initialize = (void (*)(const char *locales, const char *pak)) SDL_LoadFunction(web, "te4_web_initialize");
		te4_web_shutdown = (void (*)()) SDL_LoadFunction(web, "te4_web_shutdown");
		te4_web_do_update = (void (*)(void (*cb)(WebEvent*))) SDL_LoadFunction(web, "te4_web_do_update");
		te4_web_new = (void (*)(web_view_type *view, int w, int h)) SDL_LoadFunction(web, "te4_web_new");
		te4_web_close = (bool (*)(web_view_type *view)) SDL_LoadFunction(web, "te4_web_close");
		te4_web_toscreen = (void* (*)(web_view_type *view, int *w, int *h)) SDL_LoadFunction(web, "te4_web_toscreen");
		te4_web_loading = (bool (*)(web_view_type *view)) SDL_LoadFunction(web, "te4_web_loading");
		te4_web_focus = (void (*)(web_view_type *view, bool focus)) SDL_LoadFunction(web, "te4_web_focus");
		te4_web_inject_mouse_move = (void (*)(web_view_type *view, int x, int y)) SDL_LoadFunction(web, "te4_web_inject_mouse_move");
		te4_web_inject_mouse_wheel = (void (*)(web_view_type *view, int x, int y)) SDL_LoadFunction(web, "te4_web_inject_mouse_wheel");
		te4_web_inject_mouse_button = (void (*)(web_view_type *view, int kind, bool up)) SDL_LoadFunction(web, "te4_web_inject_mouse_button");
		te4_web_inject_key = (void (*)(web_view_type *view, int scancode, int asymb, const char *uni, int unilen, bool up)) SDL_LoadFunction(web, "te4_web_inject_key");
		te4_web_download_action = (void (*)(web_view_type *view, long id, const char *path)) SDL_LoadFunction(web, "te4_web_download_action");
		te4_web_reply_local = (void (*)(int id, const char *mime, const char *result, size_t len)) SDL_LoadFunction(web, "te4_web_reply_local");
		te4_web_load_url = (void (*)(web_view_type *view, const char *url)) SDL_LoadFunction(web, "te4_web_load_url");
		te4_web_set_js_call = (void (*)(web_view_type *view, const char *name)) SDL_LoadFunction(web, "te4_web_set_js_call");

		te4_web_setup(
			g_argc, g_argv, spawnname,
			web_mutex_create, web_mutex_destroy, web_mutex_lock, web_mutex_unlock,
			web_make_texture, web_del_texture, web_texture_update,
			web_key_mods,
			web_instant_js
			);
	}
}

void te4_web_terminate() {
	if (!webcore) return;
	te4_web_shutdown();
}
