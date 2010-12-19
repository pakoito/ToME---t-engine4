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
#include "particles.h"
#include "script.h"
#include <math.h>
#include "SFMT.h"

#define rng(x, y) (x + rand_div(1 + y - x))

#define PARTICLE_ETERNAL 999999

static void getinitfield(lua_State *L, const char *key, int *min, int *max)
{
	lua_pushstring(L, key);
	lua_gettable(L, -2);

	lua_pushnumber(L, 1);
	lua_gettable(L, -2);
	*min = (int)lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushnumber(L, 2);
	lua_gettable(L, -2);
	*max = (int)lua_tonumber(L, -1);
	lua_pop(L, 1);

//	printf("%s :: %d %d\n", key, (int)*min, (int)*max);

	lua_pop(L, 1);
}

static void getparticulefield(lua_State *L, const char *k, float *v)
{
	lua_pushstring(L, k);
	lua_gettable(L, -2);
	*v = (float)lua_tonumber(L, -1);
//	printf("emit %s :: %f\n", k, *v);
	lua_pop(L, 1);
}

static int particles_new(lua_State *L)
{
	int nb = luaL_checknumber(L, 1);
	bool no_stop = lua_toboolean(L, 2);
	int density = luaL_checknumber(L, 3);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 5);
	int t_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int p_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	particles_type *ps = (particles_type*)lua_newuserdata(L, sizeof(particles_type));
	auxiliar_setclass(L, "core{particles}", -1);

	ps->density = density;
	nb = (nb * ps->density) / 100;
	if (!nb) nb = 1;
	ps->nb = nb;
	ps->texture = *t;
	ps->texture_ref = t_ref;
	ps->no_stop = no_stop;

	ps->particles = calloc(nb, sizeof(particle_type));

//	printf("Making particle emitter with %d particles\n", ps->nb);

	// Grab all parameters
	lua_rawgeti(L, LUA_REGISTRYINDEX, p_ref);

	lua_pushstring(L, "generator");
	lua_gettable(L, -2);
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		ps->generator_ref = LUA_NOREF;
	}
	else
		ps->generator_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	if (ps->generator_ref == LUA_NOREF)
	{
		lua_pushstring(L, "base");
		lua_gettable(L, -2);
		ps->base = (float)lua_tonumber(L, -1);
		lua_pop(L, 1);

		getinitfield(L, "life", &(ps->life_min), &(ps->life_max));

		getinitfield(L, "angle", &(ps->angle_min), &(ps->angle_max));
		getinitfield(L, "anglev", &(ps->anglev_min), &(ps->anglev_max));
		getinitfield(L, "anglea", &(ps->anglea_min), &(ps->anglea_max));

		getinitfield(L, "size", &(ps->size_min), &(ps->size_max));
		getinitfield(L, "sizev", &(ps->sizev_min), &(ps->sizev_max));
		getinitfield(L, "sizea", &(ps->sizea_min), &(ps->sizea_max));

		getinitfield(L, "r", &(ps->r_min), &(ps->r_max));
		getinitfield(L, "rv", &(ps->rv_min), &(ps->rv_max));
		getinitfield(L, "ra", &(ps->ra_min), &(ps->ra_max));

		getinitfield(L, "g", &(ps->g_min), &(ps->g_max));
		getinitfield(L, "gv", &(ps->gv_min), &(ps->gv_max));
		getinitfield(L, "ga", &(ps->ga_min), &(ps->ga_max));

		getinitfield(L, "b", &(ps->b_min), &(ps->b_max));
		getinitfield(L, "bv", &(ps->bv_min), &(ps->bv_max));
		getinitfield(L, "ba", &(ps->ba_min), &(ps->ba_max));

		getinitfield(L, "a", &(ps->a_min), &(ps->a_max));
		getinitfield(L, "av", &(ps->av_min), &(ps->av_max));
		getinitfield(L, "aa", &(ps->aa_min), &(ps->aa_max));
	}
	lua_pop(L, 1);

	luaL_unref(L, LUA_REGISTRYINDEX, p_ref);

	return 1;
}

static int particles_free(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);

	free(ps->particles);
	luaL_unref(L, LUA_REGISTRYINDEX, ps->texture_ref);
	if (ps->generator_ref) luaL_unref(L, LUA_REGISTRYINDEX, ps->generator_ref);

	lua_pushnumber(L, 1);
	return 1;
}

static int particles_emit(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int nb = luaL_checknumber(L, 2);

	nb = (nb * ps->density) / 100;
	if (!nb) nb = 1;

	int i;
	for (i = 0; i < ps->nb; i++)
	{
		particle_type *p = &ps->particles[i];

		if (!p->life)
		{
			if (ps->generator_ref == LUA_NOREF)
			{
				p->life = rng(ps->life_min, ps->life_max);
				p->size = rng(ps->size_min, ps->size_max);
				p->sizev = rng(ps->sizev_min, ps->sizev_max);
				p->sizea = rng(ps->sizea_min, ps->sizea_max);

				p->x = p->y = 0;

				float angle = rng(ps->angle_min, ps->angle_max) * M_PI / 180;
				float v = rng(ps->anglev_min, ps->anglev_max) / ps->base;
				float a = rng(ps->anglea_min, ps->anglea_max) / ps->base;
				p->xa = cos(angle) * a;
				p->ya = sin(angle) * a;
				p->xv = cos(angle) * v;
				p->yv = sin(angle) * v;

				p->dir = 0;
				p->dirv = 0;
				p->dira = 0;
				p->vel = 0;
				p->velv = 0;
				p->vela = 0;

				p->r = rng(ps->r_min, ps->r_max) / 255.0f;
				p->g = rng(ps->g_min, ps->g_max) / 255.0f;
				p->b = rng(ps->b_min, ps->b_max) / 255.0f;
				p->a = rng(ps->a_min, ps->a_max) / 255.0f;

				p->rv = rng(ps->rv_min, ps->rv_max) / ps->base;
				p->gv = rng(ps->gv_min, ps->gv_max) / ps->base;
				p->bv = rng(ps->bv_min, ps->bv_max) / ps->base;
				p->av = rng(ps->av_min, ps->av_max) / ps->base;

				p->ra = rng(ps->ra_min, ps->ra_max) / ps->base;
				p->ga = rng(ps->ga_min, ps->ga_max) / ps->base;
				p->ba = rng(ps->ba_min, ps->ba_max) / ps->base;
				p->aa = rng(ps->aa_min, ps->aa_max) / ps->base;
				p->trail = FALSE;
			}
			else
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, ps->generator_ref);
				lua_call(L, 0, 1);
				if (!lua_isnil(L, -1))
				{
					float life;
					float trail;
					getparticulefield(L, "trail", &trail); p->trail = trail;

					getparticulefield(L, "life", &life); p->life = life;
					getparticulefield(L, "size", &(p->size));
					getparticulefield(L, "sizev", &(p->sizev));
					getparticulefield(L, "sizea", &(p->sizea));

					getparticulefield(L, "x", &(p->x));
					getparticulefield(L, "xv", &(p->xv));
					getparticulefield(L, "xa", &(p->xa));

					getparticulefield(L, "y", &(p->y));
					getparticulefield(L, "yv", &(p->yv));
					getparticulefield(L, "ya", &(p->ya));

					getparticulefield(L, "dir", &(p->dir));
					getparticulefield(L, "dirv", &(p->dirv));
					getparticulefield(L, "dira", &(p->dira));

					getparticulefield(L, "vel", &(p->vel));
					getparticulefield(L, "velv", &(p->velv));
					getparticulefield(L, "vela", &(p->vela));

					getparticulefield(L, "r", &(p->r));
					getparticulefield(L, "rv", &(p->rv));
					getparticulefield(L, "ra", &(p->ra));

					getparticulefield(L, "g", &(p->g));
					getparticulefield(L, "gv", &(p->gv));
					getparticulefield(L, "ga", &(p->ga));

					getparticulefield(L, "b", &(p->b));
					getparticulefield(L, "bv", &(p->bv));
					getparticulefield(L, "ba", &(p->ba));

					getparticulefield(L, "a", &(p->a));
					getparticulefield(L, "av", &(p->av));
					getparticulefield(L, "aa", &(p->aa));
				}
			}
			p->ox = p->x;
			p->oy = p->y;

			nb--;
			if (!nb) break;
		}
	}
	return 0;
}


static int particles_to_screen(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool show = lua_toboolean(L, 4);
	float zoom = luaL_checknumber(L, 5);
	int kf;
	int w = 0;
	int i, j;
	bool alive = FALSE;

	glBindTexture(GL_TEXTURE_2D, ps->texture);

	for (w = 0; w < ps->nb; w++)
	{
		particle_type *p = &ps->particles[w];

		if (p->life > 0)
		{
			alive = TRUE;

			if (show)
			{
				tglColor4f(p->r, p->g, p->b, p->a);
				glBegin(GL_QUADS);
				if (!p->trail)
				{
					i = x + p->x * zoom - p->size / 2;
					j = y + p->y * zoom - p->size / 2;
					glTexCoord2f(0,0); glVertex3f(0 + i,	0 + j,		-97);
					glTexCoord2f(1,0); glVertex3f(p->size + i,	0 + j,		-97);
					glTexCoord2f(1,1); glVertex3f(p->size + i,	p->size + j,	-97);
					glTexCoord2f(0,1); glVertex3f(0 + i,	p->size + j,	-97);
				}
				else
				{
					if ((p->ox <= p->x) && (p->oy <= p->y))
					{
						glTexCoord2f(0,0); glVertex3f(0 + x + p->ox * zoom,	0 + y + p->oy * zoom,		-97);
						glTexCoord2f(1,0); glVertex3f(p->size + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,1); glVertex3f(p->size + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
						glTexCoord2f(0,1); glVertex3f(0 + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
					}
					else if ((p->ox <= p->x) && (p->oy > p->y))
					{
						glTexCoord2f(0,0); glVertex3f(0 + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,0); glVertex3f(p->size + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,1); glVertex3f(p->size + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
						glTexCoord2f(0,1); glVertex3f(0 + x + p->ox * zoom,	p->size + y + p->oy * zoom,	-97);
					}
					else if ((p->ox > p->x) && (p->oy <= p->y))
					{
						glTexCoord2f(0,0); glVertex3f(0 + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,0); glVertex3f(p->size + x + p->ox * zoom,	0 + y + p->oy * zoom,		-97);
						glTexCoord2f(1,1); glVertex3f(p->size + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
						glTexCoord2f(0,1); glVertex3f(0 + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
					}
					else if ((p->ox > p->x) && (p->oy > p->y))
					{
						glTexCoord2f(0,0); glVertex3f(0 + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,0); glVertex3f(p->size + x + p->x * zoom,	0 + y + p->y * zoom,		-97);
						glTexCoord2f(1,1); glVertex3f(p->size + x + p->ox * zoom,	p->size + y + p->oy * zoom,	-97);
						glTexCoord2f(0,1); glVertex3f(0 + x + p->x * zoom,	p->size + y + p->y * zoom,	-97);
					}
				}
				glEnd();
			}
		}
	}

	// Restore normal display
	tglColor4f(1, 1, 1, 1);

	lua_pushboolean(L, alive || ps->no_stop);
	return 1;
}

static int particles_update(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int w = 0;
	int i, j;
	bool alive = FALSE;

	glBindTexture(GL_TEXTURE_2D, ps->texture);

	for (w = 0; w < ps->nb; w++)
	{
		particle_type *p = &ps->particles[w];

		if (p->life > 0)
		{
			alive = TRUE;

			if (p->life != PARTICLE_ETERNAL) p->life--;

			p->ox = p->x;
			p->oy = p->y;

			p->x += p->xv;
			p->y += p->yv;

			if (p->vel)
			{
				p->x += cos(p->dir) * p->vel;
				p->y += sin(p->dir) * p->vel;
			}

			p->dir += p->dirv;
			p->vel += p->velv;
			p->r += p->rv;
			p->g += p->gv;
			p->b += p->bv;
			p->a += p->av;
			p->size += p->sizev;

			p->xv += p->xa;
			p->yv += p->ya;
			p->dirv += p->dira;
			p->velv += p->vela;
			p->rv += p->ra;
			p->gv += p->ga;
			p->bv += p->ba;
			p->av += p->aa;
			p->sizev += p->sizea;
		}
	}

	// Restore normal display
	tglColor4f(1, 1, 1, 1);

	lua_pushboolean(L, alive || ps->no_stop);
	return 1;
}

static const struct luaL_reg particleslib[] =
{
	{"newEmitter", particles_new},
	{NULL, NULL},
};

static const struct luaL_reg particles_reg[] =
{
	{"__gc", particles_free},
	{"close", particles_free},
	{"emit", particles_emit},
	{"toScreen", particles_to_screen},
	{"update", particles_update},
	{NULL, NULL},
};

int luaopen_particles(lua_State *L)
{
	auxiliar_newclass(L, "core{particles}", particles_reg);
	luaL_openlib(L, "core.particles", particleslib, 0);
	lua_pushstring(L, "ETERNAL");
	lua_pushnumber(L, PARTICLE_ETERNAL);
	lua_settable(L, -3);
	return 1;
}
