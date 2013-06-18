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
#include "display.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "serial.h"
#include "script.h"
#include "physfs.h"
#include "physfsrwops.h"

/********************************************************************
 ** Save thread
 * This simply takes a list of buffers & zip files to save and do it
 ********************************************************************/
struct s_save_queue_type {
	zipFile *zf;
	char *zfname;
	char *filename;
	char *payload;
	size_t payload_len;
	struct s_save_queue_type *next;
};
typedef struct s_save_queue_type save_queue;

typedef struct {
	SDL_Thread *thread;
	bool running;

	save_queue *iqueue_head, *iqueue_tail;
	SDL_mutex *lock_iqueue;
	SDL_sem *wait_iqueue;

	save_queue *oqueue_head, *oqueue_tail;
	SDL_mutex *lock_oqueue;
} save_type;

static save_type *main_save = NULL;
static char *last_zipname = NULL;
static zipFile *last_zf = NULL;

static void push_save(zipFile *zf, const char *zfname, const char *filename, char *payload, size_t payload_len)
{
	save_queue *q = malloc(sizeof(save_queue));
	q->zf = zf;
	q->zfname = strdup(zfname);
	q->filename = strdup(filename);
	q->payload = payload;
	q->payload_len = payload_len;

	SDL_mutexP(main_save->lock_iqueue);
	if (!(main_save->iqueue_tail)) main_save->iqueue_head = q;
	else main_save->iqueue_tail->next = q;
	q->next = NULL;
	main_save->iqueue_tail = q;
	SDL_mutexV(main_save->lock_iqueue);

	return;
}

static save_queue *pop_save()
{
	save_queue *q = NULL;
	SDL_mutexP(main_save->lock_iqueue);
	if (main_save->iqueue_head)
	{
		q = main_save->iqueue_head;
		if (q) main_save->iqueue_head = q->next;
		if (!main_save->iqueue_head) main_save->iqueue_tail = NULL;
	}
	SDL_mutexV(main_save->lock_iqueue);

	return q;
}

static void push_save_return(const char *zipname)
{
	save_queue *q = malloc(sizeof(save_queue));
	q->zfname = strdup(zipname);

	SDL_mutexP(main_save->lock_oqueue);
	if (!(main_save->oqueue_tail)) main_save->oqueue_head = q;
	else main_save->oqueue_tail->next = q;
	q->next = NULL;
	main_save->oqueue_tail = q;
	SDL_mutexV(main_save->lock_oqueue);
}

static int pop_save_return(lua_State *L)
{
	save_queue *q = NULL;
	SDL_mutexP(main_save->lock_oqueue);
	if (main_save->oqueue_head)
	{
		q = main_save->oqueue_head;
		if (q) main_save->oqueue_head = q->next;
		if (!main_save->oqueue_head) main_save->oqueue_tail = NULL;
	}
	SDL_mutexV(main_save->lock_oqueue);

	if (q)
	{
		lua_pushstring(L, q->zfname);
		free(q->zfname);
		free(q);
	}
	else
		lua_pushnil(L);

	return 1;
}


void finish_zip(const char *zipname) 
{
	int len = strlen(zipname);
	if (zipname[len-4] == '.' || zipname[len-3] == 't' || zipname[len-2] == 'm' || zipname[len-1] == 'p') {
		char *newname = strdup(zipname);
		newname[len - 4] = '\0';
		PHYSFS_delete(newname);
		PHYSFS_rename(zipname, newname);
		push_save_return(newname);
		free(newname);
	}
	else 
	{
		push_save_return(zipname);
	}
}

int thread_save(void *data)
{
	while (1)
	{
		SDL_SemWait(main_save->wait_iqueue);

		zipFile *zf = NULL;
		const char *zipname = NULL;

		while (1) {
			save_queue *q = pop_save();
			if (!q) {
				if (last_zipname) free(last_zipname);
				last_zipname = NULL; last_zf = NULL;
				break;
			}
			
			if (!zipname || strcmp(zipname, q->zfname)) {
				if (zf) {
					zipClose(zf, NULL);
					printf("Saved zipname %s\n", zipname);
					finish_zip(zipname);
					free((char*)zipname);
				} else {
					printf("Saving zipname %s\n", q->zfname);
				}
				zipname = strdup(q->zfname);
				zf = q->zf;
			}

//			printf("* %s<%s> : %ld\n", q->zfname, q->filename, q->payload_len);

			/* Init the zip entry */
			int err=0;
			int opt_compress_level = 4;
			zip_fileinfo zi;
			unsigned long crcFile=0;
			zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
			zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
			zi.dosDate = 0;
			zi.internal_fa = 0;
			zi.external_fa = 0;
			err = zipOpenNewFileInZip3(zf, q->filename, &zi,
				NULL,0,NULL,0,NULL /* comment*/,
				(opt_compress_level != 0) ? Z_DEFLATED : 0,
				opt_compress_level,0,
				-MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
				NULL,crcFile);
			if (err == ZIP_OK)
			{
				zipWriteInFileInZip(zf, q->payload, q->payload_len);
				zipCloseFileInZip(zf);
			}

			free(q->payload);
			free(q->zfname);
			free(q->filename);
		}

		if (zf) {
			zipClose(zf, NULL);
			printf("Saved zipname %s\n", zipname);
			finish_zip(zipname);
			free((char*)zipname);
		}
	}
	return(0);
}

// Runs on main thread
void create_save_thread()
{
	if (main_save) return;

	SDL_Thread *thread;
	save_type *save = calloc(1, sizeof(save_type));
	main_save = save;

	save->running = TRUE;
	save->iqueue_head = save->iqueue_tail = NULL;
	save->lock_iqueue = SDL_CreateMutex();
	save->wait_iqueue = SDL_CreateSemaphore(0);
	save->lock_oqueue = SDL_CreateMutex();

	thread = SDL_CreateThread(thread_save, "save", save);
	if (thread == NULL) {
		printf("Unable to create save thread: %s\n", SDL_GetError());
		return;
	}
	save->thread = thread;

	printf("Creating save thread\n");
	return;
}


/********************************************************************
 ** Main thread
 * Takes a table, serialiaze it to memory and register it in the save thread
 ********************************************************************/
static int serial_new(lua_State *L)
{
	const char *zfname = lua_tostring(L, 1);
	luaL_checktype(L, 2, LUA_TFUNCTION);
	luaL_checktype(L, 3, LUA_TFUNCTION);
	if (!lua_isnil(L, 4) && !lua_istable(L, 4)) { lua_pushstring(L, "argument 4 is not nil or table"); lua_error(L); }
	if (!lua_isnil(L, 5) && !lua_istable(L, 5)) { lua_pushstring(L, "argument 5 is not nil or table"); lua_error(L); }
	if (!lua_isnil(L, 6) && !lua_istable(L, 6)) { lua_pushstring(L, "argument 6 is not nil or table"); lua_error(L); }

	int d2_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int d_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int a_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int fadd_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int fname_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	serial_type *s = (serial_type*)lua_newuserdata(L, sizeof(serial_type));
	auxiliar_setclass(L, "core{serial}", -1);

	zipFile *zf = NULL;
	if (!last_zipname || strcmp(last_zipname, zfname)) {
		zf = zipOpen(zfname, APPEND_STATUS_CREATE);
		last_zf = zf;
		if (last_zipname) free(last_zipname);
		last_zipname = strdup(zfname);
	} else {
		zf = last_zf;
	}

	s->zf = zf;
	s->zfname = zfname;
	s->fname = fname_ref;
	s->fadd = fadd_ref;
	s->allow = a_ref;
	s->disallow = d_ref;
	s->disallow2 = d2_ref;

	return 1;
}

static int serial_free(lua_State *L)
{
	serial_type *s = (serial_type*)auxiliar_checkclass(L, "core{serial}", 1);
	luaL_unref(L, LUA_REGISTRYINDEX, s->fname);
	luaL_unref(L, LUA_REGISTRYINDEX, s->fadd);
	lua_pushnumber(L, 1);
	return 1;
}

static const char *get_name(lua_State *L, serial_type *s, int idx)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, s->fname);
	lua_pushvalue(L, idx - 1);
	lua_call(L, 1, 1);
	const char *name = lua_tostring(L, -1);
	lua_pop(L, 1);
	return name;
}

static void add_process(lua_State *L, serial_type *s, int idx)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, s->fadd);
	lua_pushvalue(L, idx - 1);
	lua_call(L, 1, 0);
}

static void writeTblFixed(serial_type *s, const char *data, long len) {
	if (len + s->bufpos >= s->buflen) {
		char *newbuf = malloc(s->buflen * 2);
		memcpy(newbuf, s->buf, s->buflen);
		free(s->buf);
		s->buf = newbuf;
		s->buflen = s->buflen * 2;
	}
	memcpy(s->buf + s->bufpos, data, len);
	s->bufpos += len;
}
#define writeTbl(s, data) { writeTblFixed(s, data, strlen(data)); }

static void tbl_dump_string(serial_type *s, const char *str, size_t l)
{
	while (l--) {
		switch (*str) {
		case '"': case '\\': case '\n': {
			writeTblFixed(s, "\\", 1);
			writeTblFixed(s, str, 1);
			break;
		}
		case '\r': {
			writeTblFixed(s, "\\r", 2);
			break;
		}
		case '\0': {
			writeTblFixed(s, "\\000", 4);
			break;
		}
		default: {
			writeTblFixed(s, str, 1);
			break;
		}
		}
		str++;
	}
}

static int tbl_dump_function(lua_State *L, const void* p, size_t sz, void* ud)
{
	serial_type *s = (serial_type*)ud;
//	fwrite(p, sz, 1, stdout);
//	zipWriteInFileInZip(s->zf, p, sz);
	tbl_dump_string(s, p, sz);
	return 0;
}

static void tbl_basic_serialize(lua_State *L, serial_type *s, int type, int idx)
{
	if (type == LUA_TBOOLEAN) {
		if (lua_toboolean(L, idx)) { writeTblFixed(s, "true", 4); }
		else { writeTblFixed(s, "false", 5); }
	} else if (type == LUA_TNUMBER) {
		lua_pushvalue(L, idx);
		size_t len;
		const char *n = lua_tolstring(L, -1, &len);
		writeTblFixed(s, n, len);
		lua_pop(L, 1);
	} else if (type == LUA_TSTRING) {
		size_t len;
		const char *str = lua_tolstring(L, idx, &len);
		writeTblFixed(s, "\"", 1);
		tbl_dump_string(s, str, len);
		writeTblFixed(s, "\"", 1);
	} else if (type == LUA_TFUNCTION) {
		writeTblFixed(s, "loadstring(\"", 12);
		lua_dump(L, tbl_dump_function, s);
		writeTblFixed(s, "\")", 2);
	} else if (type == LUA_TTABLE) {
		lua_pushstring(L, "__CLASSNAME");
		lua_rawget(L, idx - 1);
		// This is an object, register for saving later
		if (!lua_isnil(L, -1))
		{
			lua_pop(L, 1);
			writeTblFixed(s, "loadObject('", 12);
			writeTbl(s, get_name(L, s, idx));
			writeTblFixed(s, "')", 2);
			add_process(L, s, idx);
		}
		// This is just a table, save it
		else
		{
			lua_pop(L, 1);
			int ktype, etype;

			writeTblFixed(s, "{", 1);
			/* table is in the stack at index 't' */
			lua_pushnil(L);  /* first key */

			while (lua_next(L, idx - 1) != 0)
			{
				ktype = lua_type(L, -2);
				etype = lua_type(L, -1);

				// Only save allowed types
				if (
					((ktype == LUA_TBOOLEAN) || (ktype == LUA_TNUMBER) || (ktype == LUA_TSTRING) || (ktype == LUA_TFUNCTION) || (ktype == LUA_TTABLE)) &&
					((etype == LUA_TBOOLEAN) || (etype == LUA_TNUMBER) || (etype == LUA_TSTRING) || (etype == LUA_TFUNCTION) || (etype == LUA_TTABLE))
					)
				{
					writeTblFixed(s, "[", 1);
					tbl_basic_serialize(L, s, ktype, -2);
					writeTblFixed(s, "]=", 2);
					tbl_basic_serialize(L, s, etype, -1);
					writeTblFixed(s, ",\n", 2);
				}

				/* removes 'value'; keeps 'key' for next iteration */
				lua_pop(L, 1);
			}
			writeTblFixed(s, "}\n", 2);
		}
	} else {
		printf("*WARNING* can not save value of type %s\n", lua_typename(L, type));
	}
}

static int serial_tozip(lua_State *L)
{
	serial_type *s = (serial_type*)auxiliar_checkclass(L, "core{serial}", 1);

	int ktype, etype;
	bool skip;

	/* Allows & disallows */
	lua_rawgeti(L, LUA_REGISTRYINDEX, s->allow);     // -5
	lua_rawgeti(L, LUA_REGISTRYINDEX, s->disallow);  // -4
	lua_rawgeti(L, LUA_REGISTRYINDEX, s->disallow2); // -3

	/* table is in the stack at index 't' */
	lua_pushvalue(L, 2);  /* table */
	lua_pushnil(L);  /* first key */

	const char *filename = get_name(L, s, -2);

	/* Init the buffer */
	s->buf = malloc(2 * 1024);
	s->buflen = 2 * 1024;
	s->bufpos = 0;

	writeTblFixed(s, "d={}\n", 5);
	writeTblFixed(s, "setLoaded('", 11);
	writeTbl(s, get_name(L, s, -2));
	writeTblFixed(s, "', d)\n", 6);
	while (lua_next(L, -2) != 0)
	{
		skip = FALSE;
		ktype = lua_type(L, -2);
		etype = lua_type(L, -1);

		if (s->allow != LUA_REFNIL)
		{
			lua_pushvalue(L, -2); lua_rawget(L, -7);
			skip = lua_isnil(L, -1); lua_pop(L, 1);
		}
		else if (s->disallow != LUA_REFNIL)
		{
			lua_pushvalue(L, -2); lua_rawget(L, -6);
			skip = !lua_isnil(L, -1); lua_pop(L, 1);
		}
		if (s->disallow2 != LUA_REFNIL)
		{
			lua_pushvalue(L, -2); lua_rawget(L, -5);
			skip = !lua_isnil(L, -1); lua_pop(L, 1);
		}

		if (!skip)
		{
			writeTblFixed(s, "d[", 2);
			tbl_basic_serialize(L, s, ktype, -2);
			writeTblFixed(s, "]=", 2);
			tbl_basic_serialize(L, s, etype, -1);
			writeTblFixed(s, "\n", 1);
		}

		/* removes 'value'; keeps 'key' for next iteration */
		lua_pop(L, 1);
	}
	writeTblFixed(s, "\nreturn d", 9);

	push_save(s->zf, s->zfname, filename, s->buf, s->bufpos);

	lua_pushboolean(L, TRUE);
	return 1;
}

static int serial_order_realsave(lua_State *L) 
{
	SDL_SemPost(main_save->wait_iqueue);
	return 0;	
}


static const struct luaL_Reg seriallib[] =
{
	{"new", serial_new},
	{"threadSave", serial_order_realsave},
	{"popSaveReturn", pop_save_return},
	{NULL, NULL},
};

static const struct luaL_Reg serial_reg[] =
{
	{"__gc", serial_free},
	{"toZip", serial_tozip},
	{NULL, NULL},
};

int luaopen_serial(lua_State *L)
{
	auxiliar_newclass(L, "core{serial}", serial_reg);
	luaL_openlib(L, "core.serial", seriallib, 0);
	lua_pop(L, 1);

	create_save_thread();

	return 1;
}
