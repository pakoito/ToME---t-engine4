/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010 Nicolas Casalini

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

static int dump_function(lua_State *L, const void* p, size_t sz, void* ud)
{
	serial_type *s = (serial_type*)ud;
//	fwrite(p, sz, 1, stdout);
	zipWriteInFileInZip(s->zf, p, sz);
}

static void dump_string(serial_type *s, const char *str, size_t l)
{
	writeZipFixed(s, "\"", 1);
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
	writeZipFixed(s, "\"", 1);
}

static bool basic_serialize(lua_State *L, serial_type *s, int type, int idx)
{
	if (type == LUA_TBOOLEAN) {
		if (lua_toboolean(L, idx)) { writeZip(s, "true"); }
		else { writeZip(s, "false"); }
	} else if (type == LUA_TNUMBER) {
		lua_pushvalue(L, idx);
		const char *n = lua_tostring(L, -1);
		writeZip(s, n);
		lua_pop(L, 1);
	} else if (type == LUA_TSTRING) {
		size_t len;
		const char *str = lua_tolstring(L, idx, &len);
		dump_string(s, str, len);
	} else if (type == LUA_TFUNCTION) {
		writeZip(s, "loadstring[[");
		lua_dump(L, dump_function, s);
		writeZip(s, "]]");
	} else if (type == LUA_TTABLE) {
		lua_pushstring(L, "__CLASSNAME");
		lua_rawget(L, idx - 1);
		// This is an object, register for saving later
		if (!lua_isnil(L, -1))
		{
			lua_pop(L, 1);
			writeZip(s, "loadObject('");
			writeZip(s, get_name(L, s, idx));
			writeZip(s, "')");
			add_process(L, s, idx);
		}
		// This is just a table, save it
		else
		{
			lua_pop(L, 1);
			int ktype, etype;

			writeZip(s, "{");
			/* table is in the stack at index 't' */
			lua_pushnil(L);  /* first key */

			while (lua_next(L, idx - 1) != 0)
			{
				ktype = lua_type(L, -2);
				etype = lua_type(L, -1);
				writeZip(s, "[");
				basic_serialize(L, s, ktype, -2);
				writeZip(s, "]=");
				basic_serialize(L, s, etype, -1);
				writeZip(s, ",\n");

				/* removes 'value'; keeps 'key' for next iteration */
				lua_pop(L, 1);
			}
			writeZip(s, "}\n");
		}
	} else {
		printf("*WARNING* can not save value of type %s\n", lua_typename(L, type));
	}
}

static int serial_table(lua_State *L)
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

	writeZip(s, "d={}\n");
	writeZip(s, "setLoaded('");
	writeZip(s, get_name(L, s, -2));
	writeZip(s, "', d)\n");
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
			writeZip(s, "d[");
			basic_serialize(L, s, ktype, -2);
			writeZip(s, "]=");
			basic_serialize(L, s, etype, -1);
			writeZip(s, "\n");
		}

		/* removes 'value'; keeps 'key' for next iteration */
		lua_pop(L, 1);
	}
	writeZip(s, "\nreturn d");

	zipCloseFileInZip(s->zf);

	lua_pushboolean(L, TRUE);
	return 1;
}

static const struct luaL_reg seriallib[] =
{
	{"new", serial_new},
	{NULL, NULL},
};

static const struct luaL_reg serial_reg[] =
{
	{"__gc", serial_free},
	{"table", serial_table},
	{NULL, NULL},
};

int luaopen_serial(lua_State *L)
{
	auxiliar_newclass(L, "core{serial}", serial_reg);
	luaL_openlib(L, "core.serial", seriallib, 0);
	return 1;
}
