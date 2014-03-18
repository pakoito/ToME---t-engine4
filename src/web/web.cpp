/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways, awesomium is not gpl so we cant link directly
*/

#include <map>

extern "C" {
#include "tSDL.h"
#include "tgl.h"
#include "web-external.h"
#include <stdio.h>
}
#include "web.h"
#include "web-internal.h"

#ifndef GL_BGRA
#define GL_BGRA 0x80E1
#endif
#ifndef GL_TEXTURE_MAX_ANISOTROPY_EXT
#define GL_TEXTURE_MAX_ANISOTROPY_EXT 0x84FE
#endif
#ifndef GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT
#define GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT 0x84FF
#endif

void *(*web_mutex_create)();
void (*web_mutex_destroy)(void *mutex);
void (*web_mutex_lock)(void *mutex);
void (*web_mutex_unlock)(void *mutex);
static unsigned int (*web_make_texture)(int w, int h);
static void (*web_texture_update)(unsigned int tex, int w, int h, const void* buffer);

static bool web_core = false;

static const char *cstring_to_c(const CefString &cstr) {
	std::string str = cstr.ToString();
	return (const char*)str.c_str();
}

class RenderHandler : public CefRenderHandler
{
public:
	GLuint tex;
	int w, h;
	CefRefPtr<CefBrowserHost> host;

	RenderHandler(int w, int h) {
		this->w = w;
		this->h = h;

		tex = web_make_texture(w, h);
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
		web_texture_update(tex, width, height, buffer);
	}

	// CefBase interface
public:
	IMPLEMENT_REFCOUNTING(RenderHandler);
};

class CurrentDownload {
public:
	CurrentDownload() { accept_cb = NULL; cancel_cb = NULL; }
	CefRefPtr<CefBeforeDownloadCallback> accept_cb;
	CefRefPtr<CefDownloadItemCallback> cancel_cb;
};

class BrowserClient :
	public CefClient,
	public CefRequestHandler,
	public CefDisplayHandler,
	public CefLifeSpanHandler,
	public CefDownloadHandler
{
	std::map<int32, CurrentDownload*> downloads;
	CefRefPtr<CefRenderHandler> m_renderHandler;
	int handlers;

public:
	bool first_load;
	BrowserClient(RenderHandler *renderHandler, int handlers) : m_renderHandler(renderHandler) {
		this->handlers = handlers;
		this->first_load = true;
	}
	~BrowserClient() {
		for (std::map<int32, CurrentDownload*>::iterator it=downloads.begin(); it != downloads.end(); ++it) {
			delete it->second;
		}
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
	virtual CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() OVERRIDE {
		return this;
	}
	virtual CefRefPtr<CefDownloadHandler> GetDownloadHandler() OVERRIDE {
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

	virtual bool OnBeforeResourceLoad(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame, CefRefPtr<CefRequest> request) OVERRIDE {
		return false;
	}

	virtual bool OnBeforePopup(CefRefPtr<CefBrowser> browser,
	                             CefRefPtr<CefFrame> frame,
	                             const CefString& target_url,
	                             const CefString& target_frame_name,
	                             const CefPopupFeatures& popupFeatures,
	                             CefWindowInfo& windowInfo,
	                             CefRefPtr<CefClient>& client,
	                             CefBrowserSettings& settings,
	                             bool* no_javascript_access) OVERRIDE {
		char *url = strdup(cstring_to_c(target_url));

		WebEvent *event = new WebEvent();
		event->kind = TE4_WEB_EVENT_REQUEST_POPUP_URL;
		event->handlers = handlers;
		event->data.popup.url = url;
		event->data.popup.w = popupFeatures.widthSet ? popupFeatures.width : -1;
		event->data.popup.h = popupFeatures.heightSet ? popupFeatures.height : -1;
		push_event(event);

		printf("[WEB] stopped popup to %s (%dx%d), pushing event...\n", url, event->data.popup.w, event->data.popup.h);

		return true;
	}

	virtual void OnBeforeDownload(CefRefPtr<CefBrowser> browser, CefRefPtr<CefDownloadItem> download_item, const CefString& suggested_name, CefRefPtr<CefBeforeDownloadCallback> callback) OVERRIDE {
		int32 id = download_item->GetId();
		CurrentDownload *cd = new CurrentDownload();
		cd->accept_cb = callback;
		this->downloads[id] = cd;

		const char *mime = strdup(cstring_to_c(download_item->GetMimeType()));
		const char *url = strdup(cstring_to_c(download_item->GetURL()));
		const char *name = strdup(cstring_to_c(suggested_name));
		printf("[WEB] Download request [name: %s] [mime: %s] [url: %s]\n", name, mime, url);

		WebEvent *event = new WebEvent();
		event->kind = TE4_WEB_EVENT_DOWNLOAD_REQUEST;
		event->handlers = handlers;
		event->data.download_request.url = url;
		event->data.download_request.name = name;
		event->data.download_request.mime = mime;
		event->data.download_request.id = id;
		push_event(event);
	}

	virtual void OnDownloadUpdated(CefRefPtr<CefBrowser> browser, CefRefPtr<CefDownloadItem> download_item, CefRefPtr<CefDownloadItemCallback> callback) OVERRIDE {
		int32 id = download_item->GetId();
		CurrentDownload *cd = this->downloads[id];
		if (!cd) { return; }
		cd->cancel_cb = callback;

		WebEvent *event = new WebEvent();
		event->kind = TE4_WEB_EVENT_DOWNLOAD_UPDATE;
		event->handlers = handlers;
		event->data.download_update.id = id;
		event->data.download_update.got = download_item->GetReceivedBytes();
		event->data.download_update.total = download_item->GetTotalBytes();
		event->data.download_update.percent = download_item->GetPercentComplete();
		event->data.download_update.speed = download_item->GetCurrentSpeed();
		push_event(event);
	}

	void downloadAction(int32 id, const char *path) {
		CurrentDownload *cd = this->downloads[id];
		if (!cd) return;

		if (!path) {
			// Cancel
			if (cd->cancel_cb) cd->cancel_cb->Cancel();
			delete cd;
			downloads.erase(id);
			printf("[WEB] Cancel download(%d)\n", id);
		} else {
			// Accept
			CefString fullpath(path);
			cd->accept_cb->Continue(fullpath, false);
			printf("[WEB] Accepting download(%d) to %s\n", id, path);
		}
	}

	IMPLEMENT_REFCOUNTING(BrowserClient);
};

class ClientApp :
	public CefApp,
	public CefRenderProcessHandler
{
public:
	virtual CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() OVERRIDE {
		return this;
	}

	virtual bool OnBeforeNavigation(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame, CefRefPtr<CefRequest> request, NavigationType navigation_type, bool is_redirect) OVERRIDE { 
		return false;
	}

	IMPLEMENT_REFCOUNTING(ClientApp);
};


class WebViewOpaque {
public:
	RenderHandler *render;
	CefBrowser *browser;
	BrowserClient *view;
};

void te4_web_new(web_view_type *view, const char *url, int w, int h) {
	size_t urllen = strlen(url);
	
	WebViewOpaque *opaque = new WebViewOpaque();
	view->opaque = (void*)opaque;

	CefWindowInfo window_info;
	CefBrowserSettings browserSettings;
	window_info.SetAsOffScreen(NULL);
	window_info.SetTransparentPainting(true);
	opaque->render = new RenderHandler(w, h);
	opaque->view = new BrowserClient(opaque->render, view->handlers);
	CefString curl(url);
	opaque->browser = CefBrowserHost::CreateBrowserSync(window_info, opaque->view, url, browserSettings);

	view->w = w;
	view->h = h;
	view->closed = false;
	printf("Created webview: %s\n", url);
}

bool te4_web_close(web_view_type *view) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (!view->closed) {
		view->closed = true;
		opaque->render->host->CloseBrowser(true);
		opaque->render = NULL;
		opaque->view = NULL;
		opaque->browser = NULL;
		printf("Destroyed webview\n");
		return true;
	}
	return false;
}

void te4_web_toscreen(web_view_type *view, int x, int y, int w, int h) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;

	const RenderHandler* surface = opaque->render;

	if (surface) {
		w = (w < 0) ? surface->w : w;
		h = (h < 0) ? surface->h : h;
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
}

bool te4_web_loading(web_view_type *view) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return false;

	return opaque->browser->IsLoading();
}

void te4_web_focus(web_view_type *view, bool focus) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	opaque->render->host->SendFocusEvent(focus);
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

void te4_web_inject_mouse_move(web_view_type *view, int x, int y) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	view->last_mouse_x = x;
	view->last_mouse_y = y;
	CefMouseEvent mouse_event;
	mouse_event.x = x;
	mouse_event.y = y;
	mouse_event.modifiers = get_cef_state_modifiers();

	opaque->render->host->SendMouseMoveEvent(mouse_event, false);
}

void te4_web_inject_mouse_wheel(web_view_type *view, int x, int y) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	CefMouseEvent mouse_event;
	mouse_event.x = view->last_mouse_x;
	mouse_event.y = view->last_mouse_y;
	mouse_event.modifiers = get_cef_state_modifiers();
	opaque->render->host->SendMouseWheelEvent(mouse_event, -x, -y);
}

void te4_web_inject_mouse_button(web_view_type *view, int kind, bool up) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	CefBrowserHost::MouseButtonType button_type = MBT_LEFT;
	if (kind == 2) button_type = MBT_MIDDLE;
	else if (kind == 3) button_type = MBT_RIGHT;

	CefMouseEvent mouse_event;
	mouse_event.x = view->last_mouse_x;
	mouse_event.y = view->last_mouse_y;
	mouse_event.modifiers = get_cef_state_modifiers();

	opaque->render->host->SendMouseClickEvent(mouse_event, button_type, up, 1);
}

#if defined(OS_MACOSX)
#include <Carbon/Carbon.h>

// A convenient array for getting symbol characters on the number keys.
static const char kShiftCharsForNumberKeys[] = ")!@#$%^&*(";

// Convert an ANSI character to a Mac key code.
static int GetMacKeyCodeFromChar(int key_code) {
	switch (key_code) {
		case ' ': return kVK_Space;

		case '0': case ')': return kVK_ANSI_0;
		case '1': case '!': return kVK_ANSI_1;
		case '2': case '@': return kVK_ANSI_2;
		case '3': case '#': return kVK_ANSI_3;
		case '4': case '$': return kVK_ANSI_4;
		case '5': case '%': return kVK_ANSI_5;
		case '6': case '^': return kVK_ANSI_6;
		case '7': case '&': return kVK_ANSI_7;
		case '8': case '*': return kVK_ANSI_8;
		case '9': case '(': return kVK_ANSI_9;

		case 'a': case 'A': return kVK_ANSI_A;
		case 'b': case 'B': return kVK_ANSI_B;
		case 'c': case 'C': return kVK_ANSI_C;
		case 'd': case 'D': return kVK_ANSI_D;
		case 'e': case 'E': return kVK_ANSI_E;
		case 'f': case 'F': return kVK_ANSI_F;
		case 'g': case 'G': return kVK_ANSI_G;
		case 'h': case 'H': return kVK_ANSI_H;
		case 'i': case 'I': return kVK_ANSI_I;
		case 'j': case 'J': return kVK_ANSI_J;
		case 'k': case 'K': return kVK_ANSI_K;
		case 'l': case 'L': return kVK_ANSI_L;
		case 'm': case 'M': return kVK_ANSI_M;
		case 'n': case 'N': return kVK_ANSI_N;
		case 'o': case 'O': return kVK_ANSI_O;
		case 'p': case 'P': return kVK_ANSI_P;
		case 'q': case 'Q': return kVK_ANSI_Q;
		case 'r': case 'R': return kVK_ANSI_R;
		case 's': case 'S': return kVK_ANSI_S;
		case 't': case 'T': return kVK_ANSI_T;
		case 'u': case 'U': return kVK_ANSI_U;
		case 'v': case 'V': return kVK_ANSI_V;
		case 'w': case 'W': return kVK_ANSI_W;
		case 'x': case 'X': return kVK_ANSI_X;
		case 'y': case 'Y': return kVK_ANSI_Y;
		case 'z': case 'Z': return kVK_ANSI_Z;

		// U.S. Specific mappings.  Mileage may vary.
		case ';': case ':': return kVK_ANSI_Semicolon;
		case '=': case '+': return kVK_ANSI_Equal;
		case ',': case '<': return kVK_ANSI_Comma;
		case '-': case '_': return kVK_ANSI_Minus;
		case '.': case '>': return kVK_ANSI_Period;
		case '/': case '?': return kVK_ANSI_Slash;
		case '`': case '~': return kVK_ANSI_Grave;
		case '[': case '{': return kVK_ANSI_LeftBracket;
		case '\\': case '|': return kVK_ANSI_Backslash;
		case ']': case '}': return kVK_ANSI_RightBracket;
		case '\'': case '"': return kVK_ANSI_Quote;
	}
	
	return -1;
}
#endif  // defined(OS_MACOSX)

void te4_web_inject_key(web_view_type *view, int key_code, bool up) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	CefKeyEvent key_event;

	// OMFG ... CEF3 is very very nice, except for key handling	
#if defined(SELFEXE_LINUX)
	if (key_code == SDLK_BACKSPACE)
		key_event.native_key_code = 0xff08;
	else if (key_code == SDLK_DELETE)
		key_event.native_key_code = 0xffff;
	else if (key_code == SDLK_DOWN)
		key_event.native_key_code = 0xff54;
	else if (key_code == SDLK_RETURN)
		key_event.native_key_code = 0xff0d;
	else if (key_code == SDLK_ESCAPE)
		key_event.native_key_code = 0xff1b;
	else if (key_code == SDLK_LEFT)
		key_event.native_key_code = 0xff51;
	else if (key_code == SDLK_RIGHT)
		key_event.native_key_code = 0xff53;
	else if (key_code == SDLK_TAB)
		key_event.native_key_code = 0xff09;
	else if (key_code == SDLK_UP)
		key_event.native_key_code = 0xff52;
	else
		key_event.native_key_code = key_code;
#elif defined(SELFEXE_WINDOWS)
	// This has been fully untested and most certainly isnt working
	BYTE VkCode = LOBYTE(VkKeyScanA(key_code));
	UINT scanCode = MapVirtualKey(VkCode, MAPVK_VK_TO_VSC);
	cef_event.native_key_code = (scanCode << 16) |  // key scan code
#elif defined(SELFEXE_MACOSX)
	if (key_code == SDLK_BACKSPACE) {
		cef_event.native_key_code = kVK_Delete;
		cef_event.unmodified_character = kBackspaceCharCode;
	} else if (key_code == SDLK_DELETE) {
		cef_event.native_key_code = kVK_ForwardDelete;
		cef_event.unmodified_character = kDeleteCharCode;
	} else if (key_code == SDLK_DOWN) {
		cef_event.native_key_code = kVK_DownArrow;
		cef_event.unmodified_character = /* NSDownArrowFunctionKey */ 0xF701;
	} else if (key_code == SDLK_RETURN) {
		cef_event.native_key_code = kVK_Return;
		cef_event.unmodified_character = kReturnCharCode;
	} else if (key_code == SDLK_ESCAPE) {
		cef_event.native_key_code = kVK_Escape;
		cef_event.unmodified_character = kEscapeCharCode;
	} else if (key_code == SDLK_LEFT) {
		cef_event.native_key_code = kVK_LeftArrow;
		cef_event.unmodified_character = /* NSLeftArrowFunctionKey */ 0xF702;
	} else if (key_code == SDLK_RIGHT) {
		cef_event.native_key_code = kVK_RightArrow;
		cef_event.unmodified_character = /* NSRightArrowFunctionKey */ 0xF703;
	} else if (key_code == SDLK_TAB) {
		cef_event.native_key_code = kVK_Tab;
		cef_event.unmodified_character = kTabCharCode;
	} else if (key_code == SDLK_UP) {
		cef_event.native_key_code = kVK_UpArrow;
		cef_event.unmodified_character = /* NSUpArrowFunctionKey */ 0xF700;
	} else {
		cef_event.native_key_code = GetMacKeyCodeFromChar(key_code);
		if (cef_event.native_key_code == -1)
			return;
		
		cef_event.unmodified_character = key_code;
	}

	cef_event.character = cef_event.unmodified_character;

	// Fill in |character| according to flags.
	if (cef_event.modifiers & EVENTFLAG_SHIFT_DOWN) {
		if (key_code >= '0' && key_code <= '9') {
			cef_event.character = kShiftCharsForNumberKeys[key_code - '0'];
		} else if (key_code >= 'A' && key_code <= 'Z') {
			cef_event.character = 'A' + (key_code - 'A');
		} else {
			switch (cef_event.native_key_code) {
				case kVK_ANSI_Grave:
					cef_event.character = '~';
					break;
				case kVK_ANSI_Minus:
					cef_event.character = '_';
					break;
				case kVK_ANSI_Equal:
					cef_event.character = '+';
					break;
				case kVK_ANSI_LeftBracket:
					cef_event.character = '{';
					break;
				case kVK_ANSI_RightBracket:
					cef_event.character = '}';
					break;
				case kVK_ANSI_Backslash:
					cef_event.character = '|';
					break;
				case kVK_ANSI_Semicolon:
					cef_event.character = ':';
					break;
				case kVK_ANSI_Quote:
					cef_event.character = '\"';
					break;
				case kVK_ANSI_Comma:
					cef_event.character = '<';
					break;
				case kVK_ANSI_Period:
					cef_event.character = '>';
					break;
				case kVK_ANSI_Slash:
					cef_event.character = '?';
					break;
				default:
					break;
			}
		}
	}

	// Control characters.
	if (cef_event.modifiers & EVENTFLAG_CONTROL_DOWN) {
		if (key_code >= 'A' && key_code <= 'Z')
			cef_event.character = 1 + key_code - 'A';
		else if (cef_event.native_key_code == kVK_ANSI_LeftBracket)
			cef_event.character = 27;
		else if (cef_event.native_key_code == kVK_ANSI_Backslash)
			cef_event.character = 28;
		else if (cef_event.native_key_code == kVK_ANSI_RightBracket)
			cef_event.character = 29;
	}
#else
	// Try a fallback..
	key_event.native_key_code = key_code;
#endif

	key_event.unmodified_character = key_code;
	key_event.character = key_event.unmodified_character;
	key_event.modifiers = get_cef_state_modifiers();

	if (!up) {
		key_event.type = KEYEVENT_KEYDOWN;
		opaque->render->host->SendKeyEvent(key_event);
	} else {
		// Need to send both KEYUP and CHAR events.
		key_event.type = KEYEVENT_KEYUP;
		opaque->render->host->SendKeyEvent(key_event);
		key_event.type = KEYEVENT_CHAR;
		opaque->render->host->SendKeyEvent(key_event);
	}
}

void te4_web_download_action(web_view_type *view, long id, const char *path) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;

	opaque->view->downloadAction(id, path);
}

void te4_web_do_update(void (*cb)(WebEvent*)) {
	if (web_core) { 
		CefDoMessageLoopWork();

		WebEvent *event;
		while (event = pop_event()) {
			cb(event);

			switch (event->kind) {
				case TE4_WEB_EVENT_TITLE_CHANGE:
					free((void*)event->data.title);
					break;
				case TE4_WEB_EVENT_REQUEST_POPUP_URL:
					free((void*)event->data.popup.url);
					break;
				case TE4_WEB_EVENT_DOWNLOAD_REQUEST:
					free((void*)event->data.download_request.url);
					free((void*)event->data.download_request.name);
					free((void*)event->data.download_request.mime);
					break;
			}

			delete event;
		}
	}
}

void te4_web_setup(
	int argc, char **gargv,
	void*(*mutex_create)(), void(*mutex_destroy)(void*), void(*mutex_lock)(void*), void(*mutex_unlock)(void*),
	unsigned int (*make_texture)(int, int), void (*texture_update)(unsigned int, int, int, const void*)
	) {

	web_mutex_create = mutex_create;
	web_mutex_destroy = mutex_destroy;
	web_mutex_lock = mutex_lock;
	web_mutex_unlock = mutex_unlock;
	web_make_texture = make_texture;
	web_texture_update = texture_update;

	if (!web_core) {
		CefRefPtr<ClientApp> app(new ClientApp);

#ifdef _WIN32
		CefMainArgs args(GetModuleHandle(NULL));
#else
		char **cargv = (char**)calloc(argc, sizeof(char*));
		for (int i = 0; i < argc; i++) cargv[i] = strdup(gargv[i]);
		CefMainArgs args(argc, cargv);
#endif
		int result = CefExecuteProcess((const CefMainArgs&)args, app.get());
		if (result >= 0) {
			exit(result);  // child proccess has endend, so exit.
		} else if (result == -1) {
			// we are here in the father proccess.
		}

		CefSettings settings;
		settings.multi_threaded_message_loop = false;
		// CefString locales("game/thirdparty/cef3/locales/");
		// CefString(&settings.locales_dir_path) = locales;
		// CefString resources("game/thirdparty/cef3/");
		// CefString(&settings.resources_dir_path) = resources;
		bool resulti = CefInitialize((const CefMainArgs&)args, settings, app.get());
		web_core = true;
	}
}

void te4_web_initialize() {
	te4_web_init_utils();
}
