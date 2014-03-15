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
}
#include "web.h"
#include "web-internal.h"

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

void te4_web_inject_key(web_view_type *view, int scancode, bool up) {
	WebViewOpaque *opaque = (WebViewOpaque*)view->opaque;
	if (view->closed) return;
	if (!opaque->render->host) return;

	CefKeyEvent key_event;
	key_event.native_key_code = scancode;
	key_event.modifiers = get_cef_state_modifiers();

	if (!up) {
		key_event.type = KEYEVENT_RAWKEYDOWN;
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
			delete event;
		}
	}
}

void te4_web_setup(int argc, char **gargv) {
	if (!web_core) {
		CefRefPtr<ClientApp> app(new ClientApp);

		char **cargv = (char**)calloc(argc, sizeof(char*));
		for (int i = 0; i < argc; i++) cargv[i] = strdup(gargv[i]);
		CefMainArgs args(argc, cargv);
		int result = CefExecuteProcess(args, app.get());
		if (result >= 0) {
			exit(result);  // child proccess has endend, so exit.
		} else if (result == -1) {
			// we are here in the father proccess.
		}

		CefSettings settings;
		settings.multi_threaded_message_loop = false;
		bool resulti = CefInitialize(args, settings, app.get());
		web_core = true;
	}
}

void te4_web_initialize() {
	te4_web_init_utils();
}
