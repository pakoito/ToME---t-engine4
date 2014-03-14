/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways, awesomium is not gpl so we cant link directly
*/

extern "C" {
#include "tSDL.h"
#include "tgl.h"
#include "web-external.h"
}

#include "web.h"
#include "web-internal.h"

#include <cef_app.h>
#include <cef_app.h>
#include <cef_client.h>
#include <cef_display_handler.h>
#include <cef_render_handler.h>
#include <cef_request_handler.h>
#include <cef_render_process_handler.h>
#include <vector>

static std::vector<WebEvent*> *iqueue = new std::vector<WebEvent*>;
static std::vector<WebEvent*> *oqueue = new std::vector<WebEvent*>;
static SDL_mutex *lock_iqueue = NULL;
static SDL_mutex *lock_oqueue = NULL;

void te4_web_init_utils() {
	if (!lock_iqueue) lock_iqueue = SDL_CreateMutex();
	if (!lock_oqueue) lock_oqueue = SDL_CreateMutex();
}

void push_order(WebEvent *event)
{
	if (!lock_iqueue) return;
	SDL_mutexP(lock_iqueue);
	iqueue->push_back(event);
	SDL_mutexV(lock_iqueue);
}

WebEvent *pop_order()
{
	if (!lock_iqueue) return NULL;
	WebEvent *event = NULL;

	SDL_mutexP(lock_iqueue);
	if (!iqueue->empty()) {
		event = iqueue->back();
		iqueue->pop_back();
	}
	SDL_mutexV(lock_iqueue);

	return event;
}

void push_event(WebEvent *event)
{
	if (!lock_oqueue) return;
	SDL_mutexP(lock_oqueue);
	oqueue->push_back(event);
	SDL_mutexV(lock_oqueue);
}

WebEvent *pop_event()
{
	if (!lock_oqueue) return NULL;
	WebEvent *event = NULL;

	SDL_mutexP(lock_oqueue);
	if (!oqueue->empty()) {
		event = oqueue->back();
		oqueue->pop_back();
	}
	SDL_mutexV(lock_oqueue);

	return event;
}

