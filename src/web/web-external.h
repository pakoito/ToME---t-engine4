/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

#ifndef __TE4WEB_EXTERNAL_H__
#define __TE4WEB_EXTERNAL_H__

enum web_event_kind {
	TE4_WEB_EVENT_TITLE_CHANGE,
};

typedef struct {
	enum web_event_kind kind;
	int handlers;
	union {
		const char *title;		
	} data;
} WebEvent;

typedef struct {
	void *opaque;
	int w, h;
	int last_mouse_x, last_mouse_y;
	int handlers;
	bool closed;
} web_view_type;

#endif
