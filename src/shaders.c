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

int noise3DTexSize = 128;
GLuint noise3DTexName = 0;
GLubyte noise3DTexPtr[128][128][128][4];

void make3DNoiseTexture(void)
{
	int f, i, j, k, inc;
	TCOD_noise_t noise = TCOD_noise_new(3, TCOD_NOISE_DEFAULT_HURST, TCOD_NOISE_DEFAULT_LACUNARITY);
	float p[3];

	for (i = 0; i < noise3DTexSize; ++i)
	{
		for (j = 0; j < noise3DTexSize; ++j)
		{
			for (k = 0; k < noise3DTexSize; ++k)
			{
				p[0] = i;
				p[1] = j;
				p[2] = k;
				float v = ((TCOD_noise_simplex(noise, p) + 1) / 2) * 255;
				noise3DTexPtr[i][j][k][0] = v;
				noise3DTexPtr[i][j][k][1] = v;
				noise3DTexPtr[i][j][k][2] = v;
				noise3DTexPtr[i][j][k][3] = 255;
			}
		}
	}

	glGenTextures(1, &noise3DTexName);
	glBindTexture(GL_TEXTURE_3D, noise3DTexName);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA, 128, 128, 128, 0, GL_RGBA, GL_UNSIGNED_BYTE, noise3DTexPtr);
}

void useShader(GLuint p)
{
	CHECKGL(glUseProgramObjectARB(p));
	GLint i = SDL_GetTicks();
	CHECKGL(glUniform1ivARB(glGetUniformLocationARB(p, "tick"), 1, &i));

	i = 1;
	CHECKGL(glActiveTexture(GL_TEXTURE1));
	CHECKGL(glBindTexture(GL_TEXTURE_3D, noise3DTexName));
	CHECKGL(glUniform1ivARB(glGetUniformLocationARB(p, "noisevol"), 1, &i));
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

#if 0
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
	exit(1);
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

static const struct luaL_reg shaderlib[] =
{
	{"newShader", shader_new},
	{"newProgram", program_new},
	{NULL, NULL},
};

static const struct luaL_reg program_reg[] =
{
	{"__gc", program_free},
	{"compile", program_compile},
	{"attach", program_attach},
	{"detach", program_detach},
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

	make3DNoiseTexture();

	return 1;
}
