/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways, awesomium is not gpl so we cant link directly
*/

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "tSDL.h"
#include "physfs.h"
#include "tgl.h"
}
#include "web.h"

#include <cef_app.h>
#include <cef_client.h>
#include <cef_render_handler.h>

/**********************************************************************
 ******************** Duplicated since we are independant *************
 **********************************************************************/
static void auxiliar_newclass(lua_State *L, const char *classname, const luaL_Reg *func);
static void auxiliar_add2group(lua_State *L, const char *classname, const char *group);
static void auxiliar_setclass(lua_State *L, const char *classname, int objidx);
static void *auxiliar_checkclass(lua_State *L, const char *classname, int objidx);
static void *auxiliar_checkgroup(lua_State *L, const char *groupname, int objidx);
static void *auxiliar_getclassudata(lua_State *L, const char *groupname, int objidx);
static void *auxiliar_getgroupudata(lua_State *L, const char *groupname, int objidx);
static int auxiliar_checkboolean(lua_State *L, int objidx);
static int auxiliar_tostring(lua_State *L);

/*-------------------------------------------------------------------------*\
* Creates a new class with given methods
* Methods whose names start with __ are passed directly to the metatable.
\*-------------------------------------------------------------------------*/
static void auxiliar_newclass(lua_State *L, const char *classname, const luaL_Reg *func) {
    luaL_newmetatable(L, classname); /* mt */
    /* create __index table to place methods */
    lua_pushstring(L, "__index");    /* mt,"__index" */
    lua_newtable(L);                 /* mt,"__index",it */
    /* put class name into class metatable */
    lua_pushstring(L, "class");      /* mt,"__index",it,"class" */
    lua_pushstring(L, classname);    /* mt,"__index",it,"class",classname */
    lua_rawset(L, -3);               /* mt,"__index",it */
    /* pass all methods that start with _ to the metatable, and all others
     * to the index table */
    for (; func->name; func++) {     /* mt,"__index",it */
        lua_pushstring(L, func->name);
        lua_pushcfunction(L, func->func);
        lua_rawset(L, func->name[0] == '_' ? -5: -3);
    }
    lua_rawset(L, -3);               /* mt */
    lua_pop(L, 1);
}

/*-------------------------------------------------------------------------*\
* Prints the value of a class in a nice way
\*-------------------------------------------------------------------------*/
static int auxiliar_tostring(lua_State *L) {
    char buf[32];
    if (!lua_getmetatable(L, 1)) goto error;
    lua_pushstring(L, "__index");
    lua_gettable(L, -2);
    if (!lua_istable(L, -1)) goto error;
    lua_pushstring(L, "class");
    lua_gettable(L, -2);
    if (!lua_isstring(L, -1)) goto error;
    sprintf(buf, "%p", lua_touserdata(L, 1));
    lua_pushfstring(L, "%s: %s", lua_tostring(L, -1), buf);
    return 1;
error:
    lua_pushstring(L, "invalid object passed to 'auxiliar.c:__tostring'");
    lua_error(L);
    return 1;
}

/*-------------------------------------------------------------------------*\
* Insert class into group
\*-------------------------------------------------------------------------*/
static void auxiliar_add2group(lua_State *L, const char *classname, const char *groupname) {
    luaL_getmetatable(L, classname);
    lua_pushstring(L, groupname);
    lua_pushboolean(L, 1);
    lua_rawset(L, -3);
    lua_pop(L, 1);
}

/*-------------------------------------------------------------------------*\
* Make sure argument is a boolean
\*-------------------------------------------------------------------------*/
static int auxiliar_checkboolean(lua_State *L, int objidx) {
    if (!lua_isboolean(L, objidx))
        luaL_typerror(L, objidx, lua_typename(L, LUA_TBOOLEAN));
    return lua_toboolean(L, objidx);
}

/*-------------------------------------------------------------------------*\
* Return userdata pointer if object belongs to a given class, abort with
* error otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_checkclass(lua_State *L, const char *classname, int objidx) {
    void *data = auxiliar_getclassudata(L, classname, objidx);
    if (!data) {
        char msg[45];
        sprintf(msg, "%.35s expected", classname);
        luaL_argerror(L, objidx, msg);
    }
    return data;
}

/*-------------------------------------------------------------------------*\
* Return userdata pointer if object belongs to a given group, abort with
* error otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_checkgroup(lua_State *L, const char *groupname, int objidx) {
    void *data = auxiliar_getgroupudata(L, groupname, objidx);
    if (!data) {
        char msg[45];
        sprintf(msg, "%.35s expected", groupname);
        luaL_argerror(L, objidx, msg);
    }
    return data;
}

/*-------------------------------------------------------------------------*\
* Set object class
\*-------------------------------------------------------------------------*/
static void auxiliar_setclass(lua_State *L, const char *classname, int objidx) {
    luaL_getmetatable(L, classname);
    if (objidx < 0) objidx--;
    lua_setmetatable(L, objidx);
}

/*-------------------------------------------------------------------------*\
* Get a userdata pointer if object belongs to a given group. Return NULL
* otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_getgroupudata(lua_State *L, const char *groupname, int objidx) {
    if (!lua_getmetatable(L, objidx))
        return NULL;
    lua_pushstring(L, groupname);
    lua_rawget(L, -2);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 2);
        return NULL;
    } else {
        lua_pop(L, 2);
        return lua_touserdata(L, objidx);
    }
}

/*-------------------------------------------------------------------------*\
* Get a userdata pointer if object belongs to a given class. Return NULL
* otherwise
\*-------------------------------------------------------------------------*/
static void *auxiliar_getclassudata(lua_State *L, const char *classname, int objidx) {
    lua_checkstack(L, 2);
    return luaL_checkudata(L, objidx, classname);
}

/**********************************************************************
 **********************************************************************
 **********************************************************************/

static bool web_core = false;

class ClientApp : public CefApp {
public:
	virtual CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler()
	{ return NULL; }
	virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler()
	{ return NULL; }

	IMPLEMENT_REFCOUNTING(ClientApp);
};

class RenderHandler : public CefRenderHandler
{
public:
	GLuint tex;
	int w, h;

	RenderHandler(int w, int h) {
		this->w = w;
		this->h = h;

		glGenTextures(1, &tex);
		glBindTexture(GL_TEXTURE_2D, tex);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		GLfloat largest_supported_anisotropy;
		glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &largest_supported_anisotropy);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, largest_supported_anisotropy);
		unsigned char *buffer = new unsigned char[w * h * 4];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
		delete[] buffer;
	}

	~RenderHandler() {
		glDeleteTextures(1, &tex);
	}

	// CefRenderHandler interface
public:
	bool GetViewRect(CefRefPtr<CefBrowser> browser, CefRect &rect)
	{
		rect = CefRect(0, 0, w, h);
		return true;
	}
	void OnPaint(CefRefPtr<CefBrowser> browser, PaintElementType type, const RectList &dirtyRects, const void *buffer, int width, int height)
	{
		glBindTexture(GL_TEXTURE_2D, tex);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
	}

	// CefBase interface
public:
	IMPLEMENT_REFCOUNTING(RenderHandler);
};

class BrowserClient : public CefClient
{
	CefRefPtr<CefRenderHandler> m_renderHandler;

public:
	BrowserClient(RenderHandler *renderHandler) : m_renderHandler(renderHandler)
	{;}

	virtual CefRefPtr<CefRenderHandler> GetRenderHandler() {
		return m_renderHandler;
	}

	IMPLEMENT_REFCOUNTING(BrowserClient);
};

typedef struct {
	BrowserClient *view;
	RenderHandler *render;
	int w, h;
	bool closed;
} web_view_type;

static int lua_web_new(lua_State *L) {
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	size_t urllen;
	const char* url = luaL_checklstring(L, 3, &urllen);

	web_view_type *view = (web_view_type*)lua_newuserdata(L, sizeof(web_view_type));
	auxiliar_setclass(L, "web{view}", -1);

	view->w = w;
	view->h = h;
	view->closed = false;


	return 1;
}

static int lua_web_close(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (!view->closed) {
		view->closed = true;
		printf("Destroyed webview\n");
	}
	return 0;
}

static int lua_web_toscreen(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	const RenderHandler* surface = view->render;

	if (surface) {
		int x = luaL_checknumber(L, 2);
		int y = luaL_checknumber(L, 3);
		int w = surface->w;
		int h = surface->h;
		if (lua_isnumber(L, 4)) w = lua_tonumber(L, 4);
		if (lua_isnumber(L, 5)) h = lua_tonumber(L, 5);
		float r = 1, g = 1, b = 1, a = 1;

		glBindTexture(GL_TEXTURE_2D, surface->tex);

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
	if (view->closed) return 0;

	lua_pushboolean(L, true);
	return 1;
}

static int lua_web_title(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	lua_pushstring(L, "test");
	return 1;
}

static int lua_web_focus(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

//	if (lua_toboolean(L, 2)) view->view->Focus();
//	else view->view->Unfocus();
	return 0;
}

static int lua_web_inject_mouse_move(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
//	view->view->InjectMouseMove(x, y);
	return 0;
}

static int lua_web_inject_mouse_wheel(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
//	view->view->InjectMouseWheel(-y, -x);
	return 0;
}

static int lua_web_inject_mouse_button(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
/*
	bool up = lua_toboolean(L, 2);
	int kind = luaL_checknumber(L, 3);
	MouseButton b = kMouseButton_Left;
	if (kind == 2) b = kMouseButton_Middle;
	else if (kind == 3) b = kMouseButton_Right;

	if (up) view->view->InjectMouseUp(b);
	else view->view->InjectMouseDown(b);
*/
	return 0;
}

static int lua_web_inject_key(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
/*
	bool up = lua_toboolean(L, 2);
	int scancode = lua_tonumber(L, 3);
	int asymb = lua_tonumber(L, 4);
	const char *uni = NULL;
	size_t unilen = 0;
	if (lua_isstring(L, 5)) uni = lua_tolstring(L, 5, &unilen);

	WebKeyboardEvent keyEvent;
	keyEvent.type = !up ? WebKeyboardEvent::kTypeKeyDown : WebKeyboardEvent::kTypeKeyUp;

	char buf[20];
	keyEvent.virtual_key_code = asymb;
	GetKeyIdentifierFromVirtualKeyCode(keyEvent.virtual_key_code, (char**)&buf);
	strcpy(keyEvent.key_identifier, buf);

	SDL_Keymod smod = SDL_GetModState();

	keyEvent.modifiers = 0;

	if (smod & KMOD_SHIFT) keyEvent.modifiers |= WebKeyboardEvent::kModShiftKey;
	else if (smod & KMOD_CTRL) keyEvent.modifiers |= WebKeyboardEvent::kModControlKey;
	else if (smod & KMOD_ALT) keyEvent.modifiers |= WebKeyboardEvent::kModAltKey;
	else if (smod & KMOD_GUI) keyEvent.modifiers |= WebKeyboardEvent::kModMetaKey;

	keyEvent.native_key_code = scancode;

	if (up) {
		view->view->InjectKeyboardEvent(keyEvent);
	} else {
		if (uni) {
			WebString wstr = WebString::CreateFromUTF8(uni, unilen);
			memcpy(keyEvent.text, wstr.data(), wstr.length() * sizeof(wchar16));
			memcpy(keyEvent.unmodified_text, wstr.data(), wstr.length() * sizeof(wchar16));
		}

		view->view->InjectKeyboardEvent(keyEvent);
		if (uni) {
			keyEvent.type = WebKeyboardEvent::kTypeChar;
			keyEvent.virtual_key_code = keyEvent.text[0];
			keyEvent.native_key_code = keyEvent.text[0];
			view->view->InjectKeyboardEvent(keyEvent);
		}
	}
*/
	return 0;
}

static int lua_web_set_downloader(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
//	web_downloader_type *listener = (web_downloader_type*)auxiliar_checkclass(L, "web{downloader}", 2);
	if (view->closed) return 0;

//	view->view->set_download_listener(listener->d);
	return 0;
}

static const struct luaL_Reg view_reg[] =
{
	{"__gc", lua_web_close},
//	{"downloader", lua_web_set_downloader},
//	{"downloadAction", lua_web_download_action},
	{"toScreen", lua_web_toscreen},
	{"focus", lua_web_focus},
	{"loading", lua_web_loading},
	{"title", lua_web_title},
	{"injectMouseMove", lua_web_inject_mouse_move},
	{"injectMouseWheel", lua_web_inject_mouse_wheel},
	{"injectMouseButton", lua_web_inject_mouse_button},
	{"injectKey", lua_web_inject_key},
//	{"setMethod", lua_web_set_method},
	{NULL, NULL},
};

static const struct luaL_Reg weblib[] =
{
	{"new", lua_web_new},
	{NULL, NULL},
};

void te4_web_update() {
//	if (web_core) web_core->Update();
}

void te4_web_init(lua_State *L) {
	if (!web_core) {
		const char *argv[1] = {"cef3"};
		int argc = 1;
		CefMainArgs args(argc, (char**)argv);
		CefRefPtr<ClientApp> app(new ClientApp());
		int result = CefExecuteProcess(args, app.get());
		if (result >= 0) {
			exit(result);  // child proccess has endend, so exit.
		} else if (result == -1) {
			// we are here in the father proccess.
		}

		CefSettings settings;
		bool resulti = CefInitialize(args, settings, app.get());
		web_core = true;
	}

	auxiliar_newclass(L, "web{view}", view_reg);
//	auxiliar_newclass(L, "web{downloader}", downloader_reg);
	luaL_openlib(L, "core.webview", weblib, 0);
	lua_settop(L, 0);
}
