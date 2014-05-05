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

extern "C" {
#include "tSDL.h"
#include "tgl.h"
#include "web-external.h"
#include <stdio.h>
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
static void *lock_iqueue = NULL;
static void *lock_oqueue = NULL;

void te4_web_init_utils() {
	if (!lock_iqueue) lock_iqueue = web_mutex_create();
	if (!lock_oqueue) lock_oqueue = web_mutex_create();
}

void push_order(WebEvent *event)
{
	if (!lock_iqueue) return;
	web_mutex_lock(lock_iqueue);
	iqueue->push_back(event);
	web_mutex_unlock(lock_iqueue);
}

WebEvent *pop_order()
{
	if (!lock_iqueue) return NULL;
	WebEvent *event = NULL;

	web_mutex_lock(lock_iqueue);
	if (!iqueue->empty()) {
		event = iqueue->back();
		iqueue->pop_back();
	}
	web_mutex_unlock(lock_iqueue);

	return event;
}

void push_event(WebEvent *event)
{
	if (!lock_oqueue) return;

//	fprintf(logfile, "[WEBCORE] <Event push %d\n", event->kind);
	web_mutex_lock(lock_oqueue);
	oqueue->push_back(event);
	web_mutex_unlock(lock_oqueue);
//	fprintf(logfile, "[WEBCORE] >Event push %d\n", event->kind);
}

WebEvent *pop_event()
{
	if (!lock_oqueue) return NULL;
	WebEvent *event = NULL;

//	fprintf(logfile, "[WEBCORE] <Event pop\n");
	web_mutex_lock(lock_oqueue);
	if (!oqueue->empty()) {
		event = oqueue->back();
		oqueue->pop_back();
	}
	web_mutex_unlock(lock_oqueue);
//	fprintf(logfile, "[WEBCORE] >Event pop\n");

	return event;
}

