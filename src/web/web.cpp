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
#include "web-internal.h"
#include "web-code-aux.h"

static bool web_core = false;

static const char *cstring_to_c(const CefString &cstr) {
	std::string str = cstr.ToString();
	return (const char*)str.c_str();
}

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
	CefRefPtr<CefBrowserHost> host;

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
		host = browser->GetHost();
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

class BrowserClient : public CefClient, public CefRequestHandler, public CefDisplayHandler, public CefRenderProcessHandler
{
	CefRefPtr<CefRenderHandler> m_renderHandler;
	int handlers;

public:
	BrowserClient(RenderHandler *renderHandler, int handlers) : m_renderHandler(renderHandler) {
		this->handlers = handlers;
	}

	virtual CefRefPtr<CefRenderHandler> GetRenderHandler() {
		return m_renderHandler;
	}

	virtual CefRefPtr<CefDisplayHandler> GetDisplayHandler() OVERRIDE {
		return this;
	}

	virtual CefRefPtr<CefRequestHandler> GetRequestHandler() OVERRIDE {
		return this;
	}

	virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() OVERRIDE {
		return this;
	}

	virtual void OnTitleChange(CefRefPtr<CefBrowser> browser, const CefString& title) OVERRIDE {
		char *cur_title = strdup(cstring_to_c(title));
		WebEvent *event = new WebEvent();
		event->kind = TE4_WEB_EVENT_TITLE_CHANGE;
		event->handlers = handlers;
		event->data.title = cur_title;
		push_event(event);
	}

	virtual bool OnBeforeNavigation(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame, CefRefPtr<CefRequest> request, NavigationType navigation_type, bool is_redirect) OVERRIDE { 
		printf("===RERUSINF URL %s\n", cstring_to_c(request->GetURL()));
		return true;
	}

	virtual bool OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame, CefRefPtr<CefRequest> request) OVERRIDE {
		return false;
	}

	IMPLEMENT_REFCOUNTING(BrowserClient);
};


typedef struct {
	RenderHandler *render;
	CefBrowser *browser;
	BrowserClient *view;
	int w, h;
	int last_mouse_x, last_mouse_y;
	int handlers;
	bool closed;
} web_view_type;

static int lua_web_new(lua_State *L) {
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	size_t urllen;
	const char* url = luaL_checklstring(L, 3, &urllen);

	web_view_type *view = (web_view_type*)lua_newuserdata(L, sizeof(web_view_type));
	auxiliar_setclass(L, "web{view}", -1);

	lua_pushvalue(L, 4);
	view->handlers = luaL_ref(L, LUA_REGISTRYINDEX);

	CefWindowInfo window_info;
	CefBrowserSettings browserSettings;
	window_info.SetAsOffScreen(NULL);
	window_info.SetTransparentPainting(true);
	view->render = new RenderHandler(w, h);
	view->view = new BrowserClient(view->render, view->handlers);
	CefString curl(url);
	view->browser = CefBrowserHost::CreateBrowserSync(window_info, view->view, url, browserSettings);

	view->w = w;
	view->h = h;
	view->closed = false;
	printf("Created webview: %s\n", url);

	return 1;
}

static int lua_web_close(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (!view->closed) {
		view->closed = true;
		view->render->host->CloseBrowser(true);
		view->render = NULL;
		view->view = NULL;
		view->browser = NULL;
		luaL_unref(L, LUA_REGISTRYINDEX, view->handlers);
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

	lua_pushboolean(L, view->browser->IsLoading());
	return 1;
}

static int lua_web_focus(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	if (!view->render->host) return 0;

	view->render->host->SendFocusEvent(lua_toboolean(L, 2));
	return 0;
}

static int get_cef_state_modifiers() {
	SDL_Keymod smod = SDL_GetModState();

	int modifiers = 0;

	if (smod & KMOD_SHIFT)
		modifiers |= EVENTFLAG_SHIFT_DOWN;
	else if (smod & KMOD_CTRL)
		modifiers |= EVENTFLAG_CONTROL_DOWN;
	else if (smod & KMOD_ALT)
		modifiers |= EVENTFLAG_ALT_DOWN;
	else if (smod & KMOD_GUI)

	return modifiers;
}


static int lua_web_inject_mouse_move(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	if (!view->render->host) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	view->last_mouse_x = x;
	view->last_mouse_y = y;
	CefMouseEvent mouse_event;
	mouse_event.x = x;
	mouse_event.y = y;
	mouse_event.modifiers = get_cef_state_modifiers();

	view->render->host->SendMouseMoveEvent(mouse_event, false);
	return 0;
}

static int lua_web_inject_mouse_wheel(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	if (!view->render->host) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);

	CefMouseEvent mouse_event;
	mouse_event.x = view->last_mouse_x;
	mouse_event.y = view->last_mouse_y;
	mouse_event.modifiers = get_cef_state_modifiers();
	view->render->host->SendMouseWheelEvent(mouse_event, -x, -y);

	return 0;
}

static int lua_web_inject_mouse_button(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	if (!view->render->host) return 0;

	bool up = lua_toboolean(L, 2);
	int kind = luaL_checknumber(L, 3);

	CefBrowserHost::MouseButtonType button_type = MBT_LEFT;
	if (kind == 2) button_type = MBT_MIDDLE;
	else if (kind == 3) button_type = MBT_RIGHT;

	CefMouseEvent mouse_event;
	mouse_event.x = view->last_mouse_x;
	mouse_event.y = view->last_mouse_y;
	mouse_event.modifiers = get_cef_state_modifiers();

	view->render->host->SendMouseClickEvent(mouse_event, button_type, up, 1);

	return 0;
}

static int lua_web_inject_key(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	if (!view->render->host) return 0;

	bool up = lua_toboolean(L, 2);
	int scancode = lua_tonumber(L, 3);

	CefKeyEvent key_event;
	key_event.native_key_code = scancode;
	key_event.modifiers = get_cef_state_modifiers();

	if (!up) {
		key_event.type = KEYEVENT_RAWKEYDOWN;
		view->render->host->SendKeyEvent(key_event);
	} else {
		// Need to send both KEYUP and CHAR events.
		key_event.type = KEYEVENT_KEYUP;
		view->render->host->SendKeyEvent(key_event);
		key_event.type = KEYEVENT_CHAR;
		view->render->host->SendKeyEvent(key_event);
	}

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

static int traceback (lua_State *L) {
	lua_Debug ar;
	int n = 0;
	printf("Lua Error: %s\n", lua_tostring(L, 1));
	while(lua_getstack(L, n++, &ar)) {
		lua_getinfo(L, "nSl", &ar);
		printf("\tAt %s:%d %s\n", ar.short_src, ar.currentline, ar.name?ar.name:"");
	}
	return 1;
}

static void stackDump (lua_State *L) {
	int i=lua_gettop(L);
	printf(" ----------------  Stack Dump ----------------\n" );
	while(  i   ) {
		int t = lua_type(L, i);
		switch (t) {
		case LUA_TSTRING:
			printf("%d:`%s'\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			printf("%d: %s\n",i,lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			printf("%d: %g\n",  i, lua_tonumber(L, i));
			break;
		default:
			printf("%d: %s // --\n", i, lua_typename(L, t));
			break;
		}
		i--;
	}
	printf("--------------- Stack Dump Finished ---------------\n" );
	fflush(stdout);
}
static int docall(lua_State *L, int narg, int nret)
{
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	status = lua_pcall(L, narg, nret, base);
	lua_remove(L, base);  /* remove traceback function */
	if (status != 0) { lua_pop(L, 1); lua_gc(L, LUA_GCCOLLECT, 0); }
	if (lua_gettop(L) != nret + (base - 1))
	{
		stackDump(L);
		lua_settop(L, base);
	}
	return status;
}

void te4_web_update(lua_State *L) {
	if (web_core) { 
		CefDoMessageLoopWork();

		WebEvent *event;
		while (event = pop_event()) {
			switch (event->kind) {
				case TE4_WEB_EVENT_TITLE_CHANGE:
				lua_rawgeti(L, LUA_REGISTRYINDEX, event->handlers);
				lua_pushstring(L, "on_title");
				lua_gettable(L, -2);
				lua_remove(L, -2);
				if (!lua_isnil(L, -1)) {
					lua_rawgeti(L, LUA_REGISTRYINDEX, event->handlers);
					lua_pushstring(L, event->data.title);
					docall(L, 2, 0);
				} else lua_pop(L, 1);
				
				free((void*)event->data.title);
				break;
			}
			delete event;
		}
	}
}

void te4_web_setup(int argc, char **gargv) {
	if (!web_core) {
		char **cargv = (char**)calloc(argc, sizeof(char*));
		for (int i = 0; i < argc; i++) cargv[i] = strdup(gargv[i]);
		CefMainArgs args(argc, cargv);
		int result = CefExecuteProcess(args, NULL);
		if (result >= 0) {
			exit(result);  // child proccess has endend, so exit.
		} else if (result == -1) {
			// we are here in the father proccess.
		}

		CefSettings settings;
		settings.multi_threaded_message_loop = false;
		bool resulti = CefInitialize(args, settings, NULL);
		web_core = true;
	}
}

void te4_web_init(lua_State *L) {
	te4_web_init_utils();

	auxiliar_newclass(L, "web{view}", view_reg);
//	auxiliar_newclass(L, "web{downloader}", downloader_reg);
	luaL_openlib(L, "core.webview", weblib, 0);
	lua_settop(L, 0);
}
