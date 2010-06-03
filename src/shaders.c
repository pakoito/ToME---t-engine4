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
#include "libtcod.h"

bool shaders_active = TRUE;

void useShader(GLuint p, int x, int y, float a)
{
	CHECKGL(glUseProgramObjectARB(p));
	GLfloat t = SDL_GetTicks();
	CHECKGL(glUniform1fvARB(glGetUniformLocationARB(p, "tick"), 1, &t));
	t = a; CHECKGL(glUniform1fvARB(glGetUniformLocationARB(p, "alpha"), 1, &t));

	GLfloat c[2];
	c[0] = x;
	c[1] = y;
	CHECKGL(glUniform2fvARB(glGetUniformLocationARB(p, "mapCoord"), 1, c));
}

static GLuint loadShader(const char* code, GLuint type)
{
	GLuint v = glCreateShaderObjectARB(type);
	glShaderSourceARB(v, 1, &code, 0);
	glCompileShaderARB(v);
	CHECKGLSLCOMPILE(v, "inline");
	printf("New GL Shader %d of type %d\n", v, type);
	return v;
}

static int shader_new(lua_State *L)
{
	if (!shaders_active) return 0;
	const char *code = luaL_checkstring(L, 1);
	bool vertex = lua_toboolean(L, 2);

	GLuint *s = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{shader}", -1);

	*s = loadShader(code, vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER);

	return 1;
}

static int shader_free(lua_State *L)
{
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{shader}", 1);

	glDeleteObjectARB(*s);

	lua_pushnumber(L, 1);
	return 1;
}

static int program_new(lua_State *L)
{
	if (!shaders_active) return 0;

	GLuint *s = (GLuint*)lua_newuserdata(L, sizeof(GLuint));
	auxiliar_setclass(L, "gl{program}", -1);

	*s = glCreateProgramObjectARB();

	printf("New GL Shader program %d\n", *s);

	return 1;
}

static int program_free(lua_State *L)
{
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);

	glDeleteObjectARB(*s);

	lua_pushnumber(L, 1);
	return 1;
}

static int program_compile(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);

	glLinkProgramARB(*p);
	CHECKGLSLLINK(*p);

	CHECKGLSLVALID(*p);

#if 1
	char buffer[256];
	int count;
	int dummysize;
	int length;
	GLenum dummytype;

	glGetObjectParameterivARB(*p, GL_ACTIVE_UNIFORMS, &count);
	int i;
	for(i = 0; i<count;++i)
	{
		GLint uniLoc;
		glGetActiveUniformARB(*p, i, 256, &length, &dummysize, &dummytype, buffer);
		uniLoc = glGetUniformLocationARB(*p, buffer);
		if(uniLoc>=0)	// Test for valid uniform location
		{
			printf("*p %i: Uniform: %i: %X %s\n", *p,uniLoc, dummytype, buffer);
		}
	}
#endif
	return 0;
}

static int program_attach(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{shader}", 2);

	glAttachObjectARB(*p, *s);

	return 0;
}

static int program_detach(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	GLuint *s = (GLuint*)auxiliar_checkclass(L, "gl{shader}", 2);

	glDetachObjectARB(*p, *s);

	return 0;
}

static int program_set_uniform_number(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	const char *var = luaL_checkstring(L, 2);
	GLfloat i = luaL_checknumber(L, 3);

	CHECKGL(glUseProgramObjectARB(*p));
	CHECKGL(glUniform1fvARB(glGetUniformLocationARB(*p, var), 1, &i));
	CHECKGL(glUseProgramObjectARB(0));
	return 0;
}

static int program_set_uniform_number2(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	const char *var = luaL_checkstring(L, 2);
	GLfloat i[2];
	i[0] = luaL_checknumber(L, 3);
	i[1] = luaL_checknumber(L, 4);

	CHECKGL(glUseProgramObjectARB(*p));
	CHECKGL(glUniform2fvARB(glGetUniformLocationARB(*p, var), 2, i));
	CHECKGL(glUseProgramObjectARB(0));
	return 0;
}

static int program_set_uniform_number3(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	const char *var = luaL_checkstring(L, 2);
	GLfloat i[3];
	i[0] = luaL_checknumber(L, 3);
	i[1] = luaL_checknumber(L, 4);
	i[2] = luaL_checknumber(L, 5);

	CHECKGL(glUseProgramObjectARB(*p));
	CHECKGL(glUniform3fvARB(glGetUniformLocationARB(*p, var), 3, i));
	CHECKGL(glUseProgramObjectARB(0));
	return 0;
}

static int program_set_uniform_number4(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	const char *var = luaL_checkstring(L, 2);
	GLfloat i[4];
	i[0] = luaL_checknumber(L, 3);
	i[1] = luaL_checknumber(L, 4);
	i[2] = luaL_checknumber(L, 5);
	i[3] = luaL_checknumber(L, 6);

	CHECKGL(glUseProgramObjectARB(*p));
	CHECKGL(glUniform4fvARB(glGetUniformLocationARB(*p, var), 1, i));
	CHECKGL(glUseProgramObjectARB(0));
	return 0;
}

static int program_set_uniform_texture(lua_State *L)
{
	GLuint *p = (GLuint*)auxiliar_checkclass(L, "gl{program}", 1);
	const char *var = luaL_checkstring(L, 2);
	GLint i = luaL_checknumber(L, 3);

	CHECKGL(glUseProgramObjectARB(*p));
	CHECKGL(glUniform1ivARB(glGetUniformLocationARB(*p, var), 1, &i));
	CHECKGL(glUseProgramObjectARB(0));
	return 0;
}

static int shader_is_active(lua_State *L)
{
	lua_pushboolean(L, shaders_active);
	return 1;
}

static const struct luaL_reg shaderlib[] =
{
	{"newShader", shader_new},
	{"newProgram", program_new},
	{"active", shader_is_active},
	{NULL, NULL},
};

static const struct luaL_reg program_reg[] =
{
	{"__gc", program_free},
	{"compile", program_compile},
	{"attach", program_attach},
	{"detach", program_detach},
	{"paramNumber", program_set_uniform_number},
	{"paramNumber2", program_set_uniform_number2},
	{"paramNumber3", program_set_uniform_number3},
	{"paramNumber4", program_set_uniform_number4},
	{"paramTexture", program_set_uniform_texture},
	{NULL, NULL},
};

static const struct luaL_reg shader_reg[] =
{
	{"__gc", shader_free},
	{NULL, NULL},
};

int luaopen_shaders(lua_State *L)
{
	auxiliar_newclass(L, "gl{shader}", shader_reg);
	auxiliar_newclass(L, "gl{program}", program_reg);
	luaL_openlib(L, "core.shader", shaderlib, 0);

	return 1;
}
