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

static int serial_new(lua_State *L)
{
	zipFile *zf = (zipFile*)auxiliar_checkclass(L, "physfs{zip}", 1);
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

	s->zf = *zf;
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

#define writeZip(s, data) { /*printf("%s", data);*/ zipWriteInFileInZip(s->zf, data, strlen(data)); }
#define writeZipFixed(s, data, len) { /*printf("%s", data);*/ zipWriteInFileInZip(s->zf, data, len); }

static void dump_string(serial_type *s, const char *str, size_t l)
{
	while (l--) {
		switch (*str) {
		case '"': case '\\': case '\n': {
			writeZipFixed(s, "\\", 1);
			writeZipFixed(s, str, 1);
			break;
		}
		case '\r': {
			writeZipFixed(s, "\\r", 2);
			break;
		}
		case '\0': {
			writeZipFixed(s, "\\000", 4);
			break;
		}
		default: {
			writeZipFixed(s, str, 1);
			break;
		}
		}
		str++;
	}
}

static int dump_function(lua_State *L, const void* p, size_t sz, void* ud)
{
	serial_type *s = (serial_type*)ud;
//	fwrite(p, sz, 1, stdout);
//	zipWriteInFileInZip(s->zf, p, sz);
	dump_string(s, p, sz);
	return 0;
}

static void basic_serialize(lua_State *L, serial_type *s, int type, int idx)
{
	if (type == LUA_TBOOLEAN) {
		if (lua_toboolean(L, idx)) { writeZipFixed(s, "true", 4); }
		else { writeZipFixed(s, "false", 5); }
	} else if (type == LUA_TNUMBER) {
		lua_pushvalue(L, idx);
		size_t len;
		const char *n = lua_tolstring(L, -1, &len);
		writeZipFixed(s, n, len);
		lua_pop(L, 1);
	} else if (type == LUA_TSTRING) {
		size_t len;
		const char *str = lua_tolstring(L, idx, &len);
		writeZipFixed(s, "\"", 1);
		dump_string(s, str, len);
		writeZipFixed(s, "\"", 1);
	} else if (type == LUA_TFUNCTION) {
		writeZipFixed(s, "loadstring(\"", 12);
		lua_dump(L, dump_function, s);
		writeZipFixed(s, "\")", 2);
	} else if (type == LUA_TTABLE) {
		lua_pushstring(L, "__CLASSNAME");
		lua_rawget(L, idx - 1);
		// This is an object, register for saving later
		if (!lua_isnil(L, -1))
		{
			lua_pop(L, 1);
			writeZipFixed(s, "loadObject('", 12);
			writeZip(s, get_name(L, s, idx));
			writeZipFixed(s, "')", 2);
			add_process(L, s, idx);
		}
		// This is just a table, save it
		else
		{
			lua_pop(L, 1);
			int ktype, etype;

			writeZipFixed(s, "{", 1);
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
					writeZipFixed(s, "[", 1);
					basic_serialize(L, s, ktype, -2);
					writeZipFixed(s, "]=", 2);
					basic_serialize(L, s, etype, -1);
					writeZipFixed(s, ",\n", 2);
				}

				/* removes 'value'; keeps 'key' for next iteration */
				lua_pop(L, 1);
			}
			writeZipFixed(s, "}\n", 2);
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
	err = zipOpenNewFileInZip3(s->zf, get_name(L, s, -2), &zi,
		NULL,0,NULL,0,NULL /* comment*/,
		(opt_compress_level != 0) ? Z_DEFLATED : 0,
		opt_compress_level,0,
		-MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
		NULL,crcFile);
	if (err != ZIP_OK)
	{
		lua_pushnil(L);
		lua_pushstring(L, "could not add file to zip");
		return 2;
	}

	writeZipFixed(s, "d={}\n", 5);
	writeZipFixed(s, "setLoaded('", 11);
	writeZip(s, get_name(L, s, -2));
	writeZipFixed(s, "', d)\n", 6);
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
			writeZipFixed(s, "d[", 2);
			basic_serialize(L, s, ktype, -2);
			writeZipFixed(s, "]=", 2);
			basic_serialize(L, s, etype, -1);
			writeZipFixed(s, "\n", 1);
		}

		/* removes 'value'; keeps 'key' for next iteration */
		lua_pop(L, 1);
	}
	writeZipFixed(s, "\nreturn d", 9);

	zipCloseFileInZip(s->zf);

	lua_pushboolean(L, TRUE);
	return 1;
}

#define CLONETABLE 2
#define CLONETABLE_LIST 3

static int serial_clonefull_recurs(lua_State *L, int idx)
{
	int ktype, etype;
	int nb = 0;
	// We are called with the newtable on top of the stack

	lua_pushnil(L);  /* first key */
	while (lua_next(L, idx - 2) != 0)
	{
		ktype = lua_type(L, -2);
		etype = lua_type(L, -1);

		// Forbid cloning of fields named __threads
		if (ktype == LUA_TSTRING)
		{
			const char *s = lua_tostring(L, -2);
			if (!strcmp(s, "__threads"))
			{
				lua_pop(L, 1);
				continue;
			}
		}

		if (ktype == LUA_TTABLE)
		{
			// Check clonetable first
			lua_pushvalue(L, -2);
			lua_rawget(L, CLONETABLE);
			if (lua_isnil(L, -1))
			{
				// If not found, clone it
				lua_pop(L, 1);
				lua_newtable(L);

				// Store in the clonetable
				lua_pushvalue(L, -3);
				lua_pushvalue(L, -2);
				lua_rawset(L, CLONETABLE);
				lua_pushvalue(L, -3);
				lua_pushvalue(L, -2);
				lua_rawset(L, CLONETABLE_LIST);
			}
		}
		else
		{
			lua_pushvalue(L, -2);
		}

		if (etype == LUA_TTABLE)
		{
			// Check clonetable first
			lua_pushvalue(L, -2);
			lua_rawget(L, CLONETABLE);
			if (lua_isnil(L, -1))
			{
				// If not found, clone it
				lua_pop(L, 1);
				lua_newtable(L);

				// Store in the clonetable
				lua_pushvalue(L, -3);
				lua_pushvalue(L, -2);
				lua_rawset(L, CLONETABLE);
				lua_pushvalue(L, -3);
				lua_pushvalue(L, -2);
				lua_rawset(L, CLONETABLE_LIST);
			}
		}
		else
		{
			lua_pushvalue(L, -2);
		}

		// Now set in the new table
		lua_rawset(L, -5);

		/* removes 'value'; keeps 'key' for next iteration */
		lua_pop(L, 1);
	}

	// Setup metatable
	if (lua_getmetatable(L, idx - 1))
	{
		lua_setmetatable(L, -2); // -2 because -1 was the newtable before we push the metatable
	}

	// Check for class
	lua_pushstring(L, "__CLASSNAME");
	lua_rawget(L, -2);
	if (lua_isstring(L, -1))
	{
		lua_pop(L, 1);
		nb++;

		lua_getfield(L, -1, "cloned");
		if (lua_isfunction(L, -1))
		{
			lua_pushvalue(L, -2);
			lua_pushvalue(L, idx-2);
			lua_call(L, 2, 0);
		}
		else lua_pop(L, 1);
	}
	else lua_pop(L, 1);

	return nb;
}

static int serial_clonefull(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_newtable(L); // idx 2 == clonetable_all
	lua_newtable(L); // idx 3 == clonetable

	// Store in the clonetable
	lua_pushvalue(L, 1);
	lua_newtable(L);
	lua_rawset(L, CLONETABLE);
	lua_pushvalue(L, 1);
	lua_newtable(L);
	lua_rawset(L, CLONETABLE_LIST);

	int nb = 0;
	lua_pushnil(L);  /* first key */
	while (lua_next(L, CLONETABLE_LIST) != 0)
	{
//		printf("<TOP %d\n", lua_gettop(L));
		nb += serial_clonefull_recurs(L, -1);
//		printf(">TOP %d // %d\n", lua_gettop(L), nb);

		// Remove from list
		lua_pop(L, 1); // remove value
		lua_pushnil(L); // set to nil
		lua_rawset(L, CLONETABLE_LIST);

		// Reset the next()
		lua_pushnil(L);
	}

	lua_pushnumber(L, nb);
	return 2;
}

static const struct luaL_reg seriallib[] =
{
	{"new", serial_new},
	{"cloneFull", serial_clonefull},
	{NULL, NULL},
};

static const struct luaL_reg serial_reg[] =
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
	return 1;
}
