/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

#ifndef __TE4WEB_EXTERNAL_H__
#define __TE4WEB_EXTERNAL_H__

enum web_event_kind {
	// Internal stuff
	TE4_WEB_EVENT_DELETE_TEXTURE,

	// Eternal stuff
	TE4_WEB_EVENT_TITLE_CHANGE,
	TE4_WEB_EVENT_REQUEST_POPUP_URL,
	TE4_WEB_EVENT_DOWNLOAD_REQUEST,
	TE4_WEB_EVENT_DOWNLOAD_UPDATE,
	TE4_WEB_EVENT_DOWNLOAD_FINISH,
	TE4_WEB_EVENT_LOADING,
	TE4_WEB_EVENT_LOCAL_REQUEST,
	TE4_WEB_EVENT_RUN_LUA,
};

typedef struct {
	enum web_event_kind kind;
	int handlers;
	union {
		const char *title;
		struct {
			const char *url;
			int w, h;
		} popup;
		struct {
			long id;
			const char *url;
			const char *mime;
			const char *name;
		} download_request;
		struct {
			long id;
			long total, got, speed;
			int percent;
		} download_update;
		struct {
			long id;
		} download_finish;
		struct {
			const char *url;
			signed char status;
		} loading;
		struct {
			int id;
			const char *path;
		} local_request;
		struct {
			const char *code;
		} run_lua;
		void *texture;
	} data;
} WebEvent;

enum web_js_kind {
	TE4_WEB_JS_NULL,
	TE4_WEB_JS_BOOLEAN,
	TE4_WEB_JS_NUMBER,
	TE4_WEB_JS_STRING,
};

typedef struct {
	enum web_js_kind kind;
	union {
		bool b;
		double n;
		const char *s;
	} data;
} WebJsValue;

typedef struct {
	void *opaque;
	int w, h;
	int last_mouse_x, last_mouse_y;
	int handlers;
	bool closed;
} web_view_type;

#endif
