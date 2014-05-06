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

#ifndef __TE4WEB_INTERNAL_H__
#define __TE4WEB_INTERNAL_H__

#ifndef UINT_MAX
	#define UINT_MAX 65535
#endif
#include <cef_app.h>
#include <cef_client.h>
#include <cef_display_handler.h>
#include <cef_render_handler.h>
#include <cef_request_handler.h>
#include <cef_download_handler.h>
#include <cef_render_process_handler.h>
#include <cef_v8.h>

extern FILE *logfile;

extern void te4_web_init_utils();

extern void push_order(WebEvent *event);
extern WebEvent *pop_order();
extern void push_event(WebEvent *event);
extern WebEvent *pop_event();

extern void *(*web_mutex_create)();
extern void (*web_mutex_destroy)(void *mutex);
extern void (*web_mutex_lock)(void *mutex);
extern void (*web_mutex_unlock)(void *mutex);

#endif
