/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

#ifndef __TE4WEB_INTERNAL_H__
#define __TE4WEB_INTERNAL_H__

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
