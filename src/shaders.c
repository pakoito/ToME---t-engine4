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
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "music.h"
#include "script.h"
#include "tSDL.h"
#include "tgl.h"
#include "shaders.h"

bool shaders_active = TRUE;

static GLuint loadShader(const char* code, GLuint type)
{
	GLuint v = glCreateShaderObjectARB(type);
	glShaderSourceARB(v, 1, &code, 0);
	glCompileShaderARB(v);
	CHECKGLSLCOMPILE(v, "inline");
	printf("New GL Shader %d of type %d\n", v, type);
	return v;
}
static int program_new(lua_State *L)
{
	if (!shaders_active) return 0;
	const char *vert = lua_isstring(L, 1) ? lua_tostring(L, 1) : NULL;
	const char *frag = lua_isstring(L, 2) ? lua_tostring(L, 2) : NULL;

	GLuint *s = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{shader}", -1);

	*s = glCreateProgramObjectARB();

	if (vert) glAttachObjectARB(*s, loadShader(vert, GL_VERTEX_SHADER));
	if (frag) glAttachObjectARB(*s, loadShader(frag, GL_FRAGMENT_SHADER));

	glLinkProgramARB(*s);
	CHECKGLSLLINK(*s);

	printf("New GL Shader program %d\n", *s);

	return 1;
}

static int program_free(lua_State *L)
{
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{shader}", 1);
/*
	if(VertShader)
	{
		glDetachObjectARB(Program,VertShader);
		glDeleteObjectARB(VertShader);
	}
	if(FragShader)
	{
		glDetachObjectARB(Program,FragShader);
		glDeleteObjectARB(FragShader);
	}
*/
	glDeleteObjectARB(*s);

	lua_pushnumber(L, 1);
	return 1;
}

static const struct luaL_reg shaderlib[] =
{
	{"newProgram", program_new},
	{NULL, NULL},
};

static const struct luaL_reg shader_reg[] =
{
	{"__gc", program_free},
	{NULL, NULL},
};

int luaopen_shaders(lua_State *L)
{
	auxiliar_newclass(L, "gl{shader}", shader_reg);
	luaL_openlib(L, "core.shader", shaderlib, 0);
	return 1;
}
