/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini

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
#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "physfs.h"
#include "mzip.h"
#include "zlib.h"
#include "types.h"
#include "main.h"

/******************************************************************
 ******************************************************************
 *                             FS                                 *
 ******************************************************************
 ******************************************************************/

static int lua_fs_exists(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	lua_pushboolean(L, PHYSFS_exists(file));

	return 1;
}

static int lua_fs_isdir(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	lua_pushboolean(L, PHYSFS_isDirectory(file));

	return 1;
}

static int lua_fs_mkdir(lua_State *L)
{
	const char *dir = luaL_checkstring(L, 1);

	PHYSFS_mkdir(dir);

	return 0;
}

static int lua_fs_delete(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	PHYSFS_delete(file);

	return 0;
}

static int lua_fs_list(lua_State* L)
{
	const char *dir = luaL_checkstring(L, 1);
	bool only_dir = lua_toboolean(L, 2);

	char **rc = PHYSFS_enumerateFiles(dir);
	char **i;
	int nb = 1;
	char buf[2048];

	lua_newtable(L);
	for (i = rc; *i != NULL; i++)
	{
		strcpy(buf, dir);
		strcat(buf, "/");
		strcat(buf, *i);
		if (only_dir && (!PHYSFS_isDirectory(buf)))
			continue;

		lua_pushnumber(L, nb);
		lua_pushstring(L, *i);
		lua_settable(L, -3);
		nb++;
	}

	PHYSFS_freeList(rc);

	return 1;
}


static int lua_fs_open(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);
	const char *mode = luaL_checkstring(L, 2);

	PHYSFS_file **f = (PHYSFS_file **)lua_newuserdata(L, sizeof(PHYSFS_file *));
	auxiliar_setclass(L, "physfs{file}", -1);

	if (strchr(mode, 'w'))
		*f = PHYSFS_openWrite(file);
	else if (strchr(mode, 'a'))
		*f = PHYSFS_openAppend(file);
	else
		*f = PHYSFS_openRead(file);
	if (!*f)
	{
		lua_pop(L, 1);
		lua_pushnil(L);
		const char *error = PHYSFS_getLastError();
		lua_pushstring(L, error);
		return 2;
	}
	return 1;
}

static int lua_file_read(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	long n = luaL_optlong(L, 2, ~((size_t)0));

	size_t rlen;  /* how much to read */
	size_t nr;  /* number of chars actually read */
	luaL_Buffer b;
	luaL_buffinit(L, &b);
	rlen = LUAL_BUFFERSIZE;  /* try to read that much each time */
	do {
		char *p = luaL_prepbuffer(&b);
		if (rlen > n) rlen = n;  /* cannot read more than asked */
		nr = PHYSFS_read(*f, p, sizeof(char), rlen);
		luaL_addsize(&b, nr);
		n -= nr;  /* still have to read `n' chars */
	} while (n > 0 && nr == rlen);  /* until end of count or eof */
	luaL_pushresult(&b);  /* close buffer */
	return (n == 0 || lua_objlen(L, -1) > 0);
	return 1;
}

// This will return empty lines if you've got DOS-style "\r\n" endlines!
//  extra credit for handling buffer overflows and EOF more gracefully.
static int lua_file_readline(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	char buf[102400];
	char *ptr = buf;
	int bufsize = 102400;
	int total = 0;

	if (PHYSFS_eof(*f)) return 0;

	bufsize--;  /* allow for null terminating char */
	while ((total < bufsize) && (PHYSFS_read(*f, ptr, 1, 1) == 1))
	{
		if ((*ptr == '\r') || (*ptr == '\n'))
			break;
		ptr++;
		total++;
	}

	*ptr = '\0';  // null terminate it.
	lua_pushstring(L, buf);
	return 1;
}


static int lua_file_write(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	size_t len;
	const char *data = lua_tolstring(L, 2, &len);

	PHYSFS_write(*f, data, sizeof(char), len);

	return 0;
}

static int lua_close_file(lua_State *L)
{
	PHYSFS_file **f = (PHYSFS_file**)auxiliar_checkclass(L, "physfs{file}", 1);
	if (*f)
	{
		PHYSFS_close(*f);
		*f = NULL;
	}
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_fs_zipopen(lua_State *L)
{
	const char *file = luaL_checkstring(L, 1);

	zipFile *zf = (zipFile*)lua_newuserdata(L, sizeof(zipFile*));
	auxiliar_setclass(L, "physfs{zip}", -1);

	*zf = zipOpen(file, APPEND_STATUS_CREATE);
	if (!*zf)
	{
		lua_pop(L, 1);
		lua_pushnil(L);
	}
	return 1;
}

static int lua_close_zip(lua_State *L)
{
	zipFile *zf = (zipFile*)auxiliar_checkclass(L, "physfs{zip}", 1);
	if (*zf)
	{
		zipClose(*zf, NULL);
		*zf = NULL;
	}
	lua_pushnumber(L, 1);
	return 1;
}

static int lua_zip_add(lua_State *L)
{
	zipFile *zf = (zipFile*)auxiliar_checkclass(L, "physfs{zip}", 1);
	const char *filenameinzip = luaL_checkstring(L, 2);
	size_t datalen;
	const char *data = lua_tolstring(L, 3, &datalen);
	int opt_compress_level = luaL_optnumber(L, 4, 4);

	int err=0;
	zip_fileinfo zi;
	unsigned long crcFile=0;

	zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
	zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
	zi.dosDate = 0;
	zi.internal_fa = 0;
	zi.external_fa = 0;

	err = zipOpenNewFileInZip3(*zf,filenameinzip,&zi,
		NULL,0,NULL,0,NULL /* comment*/,
		(opt_compress_level != 0) ? Z_DEFLATED : 0,
		opt_compress_level,0,
		/* -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, */
		-MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
		NULL,crcFile);

	if (err != ZIP_OK)
	{
		lua_pushnil(L);
		lua_pushstring(L, "could not add file to zip");
		return 2;
	}
	else
	{
		err = zipWriteInFileInZip(*zf, data, datalen);
	}

	zipCloseFileInZip(*zf);

	lua_pushboolean(L, 1);
	return 1;
}

static int lua_fs_mount(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	const char *dest = luaL_checkstring(L, 2);
	bool append = lua_toboolean(L, 3);

	int err = PHYSFS_mount(src, dest, append);
	if (err == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, PHYSFS_getLastError());
		return 2;
	}
	lua_pushboolean(L, TRUE);

	return 1;
}

static int lua_fs_umount(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);

	int err = PHYSFS_removeFromSearchPath(src);
	if (err == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, PHYSFS_getLastError());
		return 2;
	}
	lua_pushboolean(L, TRUE);

	return 1;
}

static int lua_fs_get_real_path(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	char *path = PHYSFS_getDependentPath(src);
	lua_pushstring(L, path);
	free(path);
	return 1;
}

static int lua_fs_set_write_dir(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	const int error = PHYSFS_setWriteDir(src);
	if (error == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, PHYSFS_getLastError());
		return 2;
	}
	lua_pushboolean(L, TRUE);
	return 1;
}

static int lua_fs_rename(lua_State *L)
{
	const char *src = luaL_checkstring(L, 1);
	const char *dst = luaL_checkstring(L, 2);
	PHYSFS_rename(src, dst);
	return 0;
}

static int lua_fs_get_write_dir(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getWriteDir());
	return 1;
}

static int lua_fs_get_home_path(lua_State *L)
{
	lua_pushstring(L, TENGINE_HOME_PATH);
	return 1;
}

static int lua_fs_get_user_path(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getUserDir());
	return 1;
}

static int lua_fs_get_path_separator(lua_State *L)
{
	lua_pushstring(L, PHYSFS_getDirSeparator());
	return 1;
}

static void fs_list_path_double(void *data, const char *path, const char *mount)
{
	lua_State *L = (lua_State*)data;

	int nb = lua_objlen(L, -1);
	lua_pushnumber(L, nb + 1);
	lua_newtable(L);

	lua_pushliteral(L, "path");
	lua_pushstring(L, path);
	lua_settable(L, -3);

	lua_pushliteral(L, "mount");
	lua_pushstring(L, mount);
	lua_settable(L, -3);

	lua_settable(L, -3);
}

static int lua_fs_get_search_path(lua_State *L)
{
	if (!lua_toboolean(L, 1))
	{
		char **rc = PHYSFS_getSearchPath();

		char **i;
		int nb = 1;

		lua_newtable(L);
		for (i = rc; *i != NULL; i++)
		{
			lua_pushnumber(L, nb);
			lua_pushstring(L, *i);
			lua_settable(L, -3);
			nb++;
		}

		PHYSFS_freeList(rc);
	}
	else
	{
		lua_newtable(L);
		PHYSFS_getSearchPathCallbackWithMount(fs_list_path_double, L);
	}
	return 1;
}

static int lua_patch_file(lua_State *L)
{
	char *infile = PHYSFS_getDependentPath(luaL_checkstring(L, 1));
	char *outfile = PHYSFS_getDependentPath(luaL_checkstring(L, 2));
	char *patchfile = PHYSFS_getDependentPath(luaL_checkstring(L, 3));

	printf("BSPATCH: %s + %s => %s\n", infile, patchfile, outfile);

	int ret = bspatch(infile, outfile, patchfile);

	free(infile);
	free(outfile);
	free(patchfile);

	if (!ret)
	{
		lua_pushboolean(L, TRUE);
		return 1;
	}
	else
	{
		lua_pushnil(L);
		return 1;
	}
}

static const struct luaL_reg fslib[] =
{
	{"patchFile", lua_patch_file},
	{"open", lua_fs_open},
	{"zipOpen", lua_fs_zipopen},
	{"exists", lua_fs_exists},
	{"rename", lua_fs_rename},
	{"mkdir", lua_fs_mkdir},
	{"isdir", lua_fs_isdir},
	{"delete", lua_fs_delete},
	{"list", lua_fs_list},
	{"setWritePath", lua_fs_set_write_dir},
	{"getWritePath", lua_fs_get_write_dir},
	{"getPathSeparator", lua_fs_get_path_separator},
	{"getRealPath", lua_fs_get_real_path},
	{"getUserPath", lua_fs_get_user_path},
	{"getHomePath", lua_fs_get_home_path},
	{"getSearchPath", lua_fs_get_search_path},
	{"mount", lua_fs_mount},
	{"umount", lua_fs_umount},
	{NULL, NULL},
};

static const struct luaL_reg fsfile_reg[] =
{
	{"__gc", lua_close_file},
	{"close", lua_close_file},
	{"read", lua_file_read},
	{"readLine", lua_file_readline},
	{"write", lua_file_write},
	{NULL, NULL},
};

static const struct luaL_reg fszipfile_reg[] =
{
	{"__gc", lua_close_zip},
	{"close", lua_close_zip},
	{"add", lua_zip_add},
	{NULL, NULL},
};

int luaopen_physfs(lua_State *L)
{
	auxiliar_newclass(L, "physfs{file}", fsfile_reg);
	auxiliar_newclass(L, "physfs{zip}", fszipfile_reg);
	luaL_openlib(L, "fs", fslib, 0);

	lua_settop(L, 0);
	return 1;
}
