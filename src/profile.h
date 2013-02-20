/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

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
#ifndef _TE4_PROFILE_H_
#define _TE4_PROFILE_H_

struct s_profile_queue_type {
	char *payload;
	size_t payload_len;
	struct s_profile_queue_type *next;
};
typedef struct s_profile_queue_type profile_queue;

typedef struct {
	lua_State *L;
	SDL_Thread *thread;
	int sock;
	bool running;

	profile_queue *iqueue_head, *iqueue_tail;
	SDL_mutex *lock_iqueue;
	SDL_sem *wait_iqueue;

	profile_queue *oqueue_head, *oqueue_tail;
	SDL_mutex *lock_oqueue;
	SDL_sem *wait_oqueue;
} profile_type;

extern int luaopen_profile(lua_State *L);

#endif

