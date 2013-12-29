/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "tSDL.h"
}
#include "web.h"

#include <Awesomium/WebCore.h>
#include <Awesomium/BitmapSurface.h>
#include <Awesomium/STLHelpers.h>
#include "gl_texture_surface.h"

using namespace Awesomium;
static WebCore *web_core = NULL;

typedef struct {
	WebView *view;
	int w, h;
	bool closed;
} web_view_type;

class WebDownloader;

typedef struct {
	WebDownloader *d;
	lua_State *L;
	int on_request_ref;
	int on_update_ref;
	int on_finish_ref;
	bool closed;
} web_downloader_type;

static char *webstring_to_buf(WebString *wstr, size_t *flen) {
	char *buf;
	unsigned int len = 0;
	len = wstr->ToUTF8(NULL, 0);
	buf = (char*)malloc(len);
	wstr->ToUTF8(buf, len);	
	*flen = (size_t)len;
	return buf;
}

class WebDownloader : public WebViewListener::Download {
public:
	web_downloader_type *d;
	WebDownloader() {}
	void OnRequestDownload(WebView* caller, int download_id, const WebURL& url, const WebString& suggested_filename, const WebString& mime_type) {
		web_downloader_type *d = this->d;
		if (d->closed) return;

		size_t slen; char *sbuf = webstring_to_buf((WebString*)&suggested_filename, &slen);
		size_t mlen; char *mbuf = webstring_to_buf((WebString*)&mime_type, &mlen);
		WebString rurl = url.spec();
		size_t ulen; char *ubuf = webstring_to_buf((WebString*)&rurl, &ulen);

		lua_rawgeti(d->L, LUA_REGISTRYINDEX, d->on_request_ref);
		lua_pushnumber(d->L, download_id);
		lua_pushlstring(d->L, ubuf, ulen);
		lua_pushlstring(d->L, sbuf, slen);
		lua_pushlstring(d->L, mbuf, mlen);
		lua_pcall(d->L, 4, 0, 0);
		free(sbuf);
		free(mbuf);
		free(ubuf);
	}
	void OnUpdateDownload(WebView* caller, int download_id, int64 total_bytes, int64 received_bytes, int64 current_speed) {
		web_downloader_type *d = this->d;
		if (d->closed) return;

		lua_rawgeti(d->L, LUA_REGISTRYINDEX, d->on_update_ref);
		lua_pushnumber(d->L, received_bytes);
		lua_pushnumber(d->L, total_bytes);
		lua_pushnumber(d->L, current_speed);
		lua_pcall(d->L, 3, 0, 0);
	}
	void OnFinishDownload(WebView* caller, int download_id, const WebURL& url, const WebString& saved_path) {
		web_downloader_type *d = this->d;
		if (d->closed) return;

		WebString rurl = url.spec();
		size_t ulen; char *ubuf = webstring_to_buf((WebString*)&rurl, &ulen);
		size_t plen; char *pbuf = webstring_to_buf((WebString*)&saved_path, &plen);

		lua_rawgeti(d->L, LUA_REGISTRYINDEX, d->on_finish_ref);
		lua_pushlstring(d->L, ubuf, ulen);
		lua_pushlstring(d->L, pbuf, plen);
		lua_pcall(d->L, 2, 0, 0);
	}
};


static int lua_web_new(lua_State *L) {
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
	size_t urllen;
	const char* url = luaL_checklstring(L, 3, &urllen);

	web_view_type *view = (web_view_type*)lua_newuserdata(L, sizeof(web_view_type));
	auxiliar_setclass(L, "web{view}", -1);
	view->view = web_core->CreateWebView(w, h, 0, kWebViewType_Offscreen);
	view->w = w;
	view->h = h;
	view->closed = false;

	WebURL lurl(WebString::CreateFromUTF8(url, urllen));
	view->view->LoadURL(lurl);
	view->view->SetTransparent(true);

	return 1;
}

static int lua_web_close(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (!view->closed) {
		view->view->Destroy();
		view->closed = true;
		printf("Destroyed webview\n");
	}
	return 0;
}

static int lua_web_toscreen(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	const GLTextureSurface* surface = static_cast<const GLTextureSurface*> (view->view->surface());

	if (surface) {
		int x = luaL_checknumber(L, 2);
		int y = luaL_checknumber(L, 3);
		int w = surface->width();
		int h = surface->height();
		if (lua_isnumber(L, 4)) w = lua_tonumber(L, 4);
		if (lua_isnumber(L, 5)) h = lua_tonumber(L, 5);
		float r = 1, g = 1, b = 1, a = 1;

		tglBindTexture(GL_TEXTURE_2D, surface->GetTexture());

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

	lua_pushboolean(L, view->view->IsLoading());
	return 1;
}

static int lua_web_title(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	WebString wstr = view->view->title();
	size_t len;
	char *buf = webstring_to_buf(&wstr, &len);

	lua_pushlstring(L, buf, len);
	free(buf);
	return 1;
}

static int lua_web_focus(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	if (lua_toboolean(L, 2)) view->view->Focus();
	else view->view->Unfocus();
	return 0;
}

static int lua_web_inject_mouse_move(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	view->view->InjectMouseMove(x, y);
	return 0;
}

static int lua_web_inject_mouse_wheel(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	view->view->InjectMouseWheel(-y, -x);
	return 0;
}

static int lua_web_inject_mouse_button(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	bool up = lua_toboolean(L, 2);
	int kind = luaL_checknumber(L, 3);
	MouseButton b = kMouseButton_Left;
	if (kind == 2) b = kMouseButton_Middle;
	else if (kind == 3) b = kMouseButton_Right;

	if (up) view->view->InjectMouseUp(b);
	else view->view->InjectMouseDown(b);
	return 0;
}

static int lua_web_inject_key(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;

	bool up = lua_toboolean(L, 2);
	int scancode = lua_toboolean(L, 3);
	int asymb = lua_toboolean(L, 4);
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
	return 0;
}

static int lua_web_set_downloader(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	web_downloader_type *listener = (web_downloader_type*)auxiliar_checkclass(L, "web{downloader}", 2);
	if (view->closed) return 0;

	view->view->set_download_listener(listener->d);
	return 0;
}


static int lua_downloader_new(lua_State *L) {
	web_downloader_type *listener = (web_downloader_type*)lua_newuserdata(L, sizeof(web_downloader_type));
	auxiliar_setclass(L, "web{downloader}", -1);

	listener->d = new WebDownloader();
	listener->d->d = listener;
	listener->L = L;
	listener->closed = false;

	lua_pushvalue(L, 1);
	listener->on_request_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	lua_pushvalue(L, 2);
	listener->on_update_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	lua_pushvalue(L, 3);
	listener->on_finish_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	return 1;
}

static int lua_downloader_close(lua_State *L) {
	web_downloader_type *listener = (web_downloader_type*)auxiliar_checkclass(L, "web{downloader}", 1);
	if (!listener->closed) {
		luaL_unref(L, LUA_REGISTRYINDEX, listener->on_request_ref);
		luaL_unref(L, LUA_REGISTRYINDEX, listener->on_update_ref);
		luaL_unref(L, LUA_REGISTRYINDEX, listener->on_finish_ref);
		delete listener->d;
		listener->closed = true;
	}
	return 0;
}

static int lua_web_download_action(lua_State *L) {
	web_view_type *view = (web_view_type*)auxiliar_checkclass(L, "web{view}", 1);
	if (view->closed) return 0;
	int download_id = luaL_checknumber(L, 2);

	if (lua_isstring(L, 3)) {
		size_t len;
		const char *buf = lua_tolstring(L, 3, &len);
		WebString wpath = WebString::CreateFromUTF8(buf, len);
		view->view->DidChooseDownloadPath(download_id, wpath);
	} else view->view->DidCancelDownload(download_id);
	return 0;
}

static const struct luaL_Reg view_reg[] =
{
	{"__gc", lua_web_close},
	{"downloader", lua_web_set_downloader},
	{"downloadAction", lua_web_download_action},
	{"toScreen", lua_web_toscreen},
	{"focus", lua_web_focus},
	{"loading", lua_web_loading},
	{"title", lua_web_title},
	{"injectMouseMove", lua_web_inject_mouse_move},
	{"injectMouseWheel", lua_web_inject_mouse_wheel},
	{"injectMouseButton", lua_web_inject_mouse_button},
	{"injectKey", lua_web_inject_key},
	{NULL, NULL},
};

static const struct luaL_Reg downloader_reg[] =
{
	{"__gc", lua_downloader_close},
	{NULL, NULL},
};

static const struct luaL_Reg weblib[] =
{
	{"new", lua_web_new},
	{"downloader", lua_downloader_new},
	{NULL, NULL},
};

void te4_web_update() {
	if (web_core) web_core->Update();
}

void te4_web_init(lua_State *L) {
	if (!web_core) {
		web_core = WebCore::Initialize(WebConfig());
		web_core->set_surface_factory(new GLTextureSurfaceFactory());
	}

	auxiliar_newclass(L, "web{view}", view_reg);
	auxiliar_newclass(L, "web{downloader}", downloader_reg);
	luaL_openlib(L, "core.webview", weblib, 0);
	lua_settop(L, 0);
}

