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
#include "display.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "core_lua.h"
#include "auxiliar.h"
#include "types.h"
#include "particles.h"
#include "script.h"
#include <math.h>
#include "SFMT.h"
#include "tSDL.h"
#include "physfs.h"
#include "physfsrwops.h"

#define rng(x, y) (x + rand_div(1 + y - x))

#define PARTICLE_ETERNAL 999999
#define PARTICLES_PER_ARRAY 1000

int MAX_THREADS = 1;
extern int nb_cpus;
static particle_thread *threads = NULL;
static int textures_ref = LUA_NOREF;
static int nb_threads = 0;
static int cur_thread = 0;
void thread_add(particles_type *ps);

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

// Runs into main thread
static int particles_new(lua_State *L)
{
	const char *name_def = luaL_checkstring(L, 1);
	const char *args = luaL_checkstring(L, 2);
	// float zoom = luaL_checknumber(L, 3);
	int density = luaL_checknumber(L, 4);
	GLuint *texture = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 5);
	shader_type *s = NULL;
	if (lua_isuserdata(L, 6)) s = (shader_type*)auxiliar_checkclass(L, "gl{program}", 6);

	particles_type *ps = (particles_type*)lua_newuserdata(L, sizeof(particles_type));
	auxiliar_setclass(L, "core{particles}", -1);

	ps->lock = SDL_CreateMutex();
	ps->name_def = strdup(name_def);
	ps->args = strdup(args);
	ps->density = density;
	ps->alive = TRUE;
	ps->i_want_to_die = FALSE;
	ps->l = NULL;
	ps->texcoords = NULL;
	ps->vertices = NULL;
	ps->colors = NULL;
	ps->particles = NULL;
	ps->init = FALSE;
	ps->texture = *texture;
	ps->shader = s;

	thread_add(ps);
	return 1;
}

// Runs into main thread
static int particles_free(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	plist *l = ps->l;

//	printf("Deleting particle from main lua state %x :: %x\n", (int)ps->l, (int)ps);

	if (l && l->pt) SDL_mutexP(l->pt->lock);

	ps->alive = FALSE;
	if (l) l->ps = NULL;
	ps->l = NULL;
	SDL_DestroyMutex(ps->lock);

	if (ps->texcoords) { free(ps->texcoords); ps->texcoords = NULL; }
	if (ps->vertices) { free(ps->vertices); ps->vertices = NULL; }
	if (ps->colors) { free(ps->colors); ps->colors = NULL; }
	if (ps->particles) { free(ps->particles); ps->particles = NULL; }

	if (l && l->pt) SDL_mutexV(l->pt->lock);

	lua_pushnumber(L, 1);
	return 1;
}

// Runs into main thread
static int particles_is_alive(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);

	lua_pushboolean(L, ps->alive);
	return 1;
}

// Runs into main thread
static int particles_die(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);

	ps->i_want_to_die = TRUE;
	return 1;
}

// Runs into main thread
static int particles_to_screen(lua_State *L)
{
	particles_type *ps = (particles_type*)auxiliar_checkclass(L, "core{particles}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
	bool show = lua_toboolean(L, 4);
	float zoom = lua_isnumber(L, 5) ? lua_tonumber(L, 5) : 1;
	if (!show || !ps->init) return 0;
	GLfloat *vertices = ps->vertices;
	GLfloat *colors = ps->colors;
	GLshort *texcoords = ps->texcoords;

	if (x < -10000) x = -10000;
	if (x > 10000) x = 10000;
	if (y < -10000) y = -10000;
	if (y > 10000) y = 10000;

	// No texture? abord
	if (!ps->texture) return 0;

	SDL_mutexP(ps->lock);

	glBindTexture(GL_TEXTURE_2D, ps->texture);
	glTexCoordPointer(2, GL_SHORT, 0, texcoords);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(2, GL_FLOAT, 0, vertices);

	glTranslatef(x, y, 0);
	glPushMatrix();
	glScalef(ps->zoom * zoom, ps->zoom * zoom, ps->zoom * zoom);
	glRotatef(ps->rotate, 0, 0, 1);

	if (ps->shader) useShader(ps->shader, 1, 1, 1, 1, 1, 1, 1, 1);

	int remaining = ps->batch_nb;
	while (remaining >= PARTICLES_PER_ARRAY)
	{
		glDrawArrays(GL_QUADS, remaining - PARTICLES_PER_ARRAY, PARTICLES_PER_ARRAY);
		remaining -= PARTICLES_PER_ARRAY;
	}
	if (remaining) glDrawArrays(GL_QUADS, 0, remaining);

	if (ps->shader) glUseProgramObjectARB(0);

	glRotatef(-ps->rotate, 0, 0, 1);
	glPopMatrix();
	glTranslatef(-x, -y, 0);

	SDL_mutexV(ps->lock);

	return 0;
}

// Runs into particles thread
static void particles_update(lua_State *L, particles_type *ps, bool last)
{
	int w = 0;
	bool alive = FALSE;
	float zoom = 1;
	int vert_idx = 0, col_idx = 0;
	int i, j;

	if (!ps->init) return;

	if (last) SDL_mutexP(ps->lock);

	GLfloat *vertices = ps->vertices;
	GLfloat *colors = ps->colors;
	GLshort *texcoords = ps->texcoords;

	ps->rotate += ps->rotate_v;

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

			if (last)
			{
				if (!p->trail)
				{
					i = p->x * zoom - p->size / 2;
					j = p->y * zoom - p->size / 2;

					vertices[vert_idx] = i; vertices[vert_idx+1] = j;
					vertices[vert_idx+2] = p->size + i; vertices[vert_idx+3] = j;
					vertices[vert_idx+4] = p->size + i; vertices[vert_idx+5] = p->size + j;
					vertices[vert_idx+6] = i; vertices[vert_idx+7] = p->size + j;
				}
				else
				{
					if ((p->ox <= p->x) && (p->oy <= p->y))
					{
						vertices[vert_idx+0] = 0 +  p->ox * zoom; vertices[vert_idx+1] = 0 +  p->oy * zoom;
						vertices[vert_idx+2] = p->size +  p->x * zoom; vertices[vert_idx+3] = 0 +  p->y * zoom;
						vertices[vert_idx+4] = p->size +  p->x * zoom; vertices[vert_idx+5] = p->size +  p->y * zoom;
						vertices[vert_idx+6] = 0 +  p->x * zoom; vertices[vert_idx+7] = p->size +  p->y * zoom;
					}
					else if ((p->ox <= p->x) && (p->oy > p->y))
					{
						vertices[vert_idx+0] = 0 +  p->x * zoom; vertices[vert_idx+1] = 0 +  p->y * zoom;
						vertices[vert_idx+2] = p->size +  p->x * zoom; vertices[vert_idx+3] = 0 +  p->y * zoom;
						vertices[vert_idx+4] = p->size +  p->x * zoom; vertices[vert_idx+5] = p->size +  p->y * zoom;
						vertices[vert_idx+6] = 0 +  p->ox * zoom; vertices[vert_idx+7] = p->size +  p->oy * zoom;
					}
					else if ((p->ox > p->x) && (p->oy <= p->y))
					{
						vertices[vert_idx+0] = 0 +  p->x * zoom; vertices[vert_idx+1] = 0 +  p->y * zoom;
						vertices[vert_idx+2] = p->size +  p->ox * zoom; vertices[vert_idx+3] = 0 +  p->oy * zoom;
						vertices[vert_idx+4] = p->size +  p->x * zoom; vertices[vert_idx+5] = p->size +  p->y * zoom;
						vertices[vert_idx+6] = 0 +  p->x * zoom; vertices[vert_idx+7] = p->size +  p->y * zoom;
					}
					else if ((p->ox > p->x) && (p->oy > p->y))
					{
						vertices[vert_idx+0] = 0 +  p->x * zoom; vertices[vert_idx+1] = 0 +  p->y * zoom;
						vertices[vert_idx+2] = p->size +  p->x * zoom; vertices[vert_idx+3] = 0 +  p->y * zoom;
						vertices[vert_idx+4] = p->size +  p->ox * zoom; vertices[vert_idx+5] = p->size +  p->oy * zoom;
						vertices[vert_idx+6] = 0 +  p->x * zoom; vertices[vert_idx+7] = p->size +  p->y * zoom;
					}
				}

				/* Setup texture coords */
				texcoords[vert_idx] = 0; texcoords[vert_idx+1] = 0;
				texcoords[vert_idx+2] = 1; texcoords[vert_idx+3] = 0;
				texcoords[vert_idx+4] = 1; texcoords[vert_idx+5] = 1;
				texcoords[vert_idx+6] = 0; texcoords[vert_idx+7] = 1;

				/* Setup color */
				colors[col_idx] = p->r; colors[col_idx+1] = p->g; colors[col_idx+2] = p->b; colors[col_idx+3] = p->a;
				colors[col_idx+4] = p->r; colors[col_idx+5] = p->g; colors[col_idx+6] = p->b; colors[col_idx+7] = p->a;
				colors[col_idx+8] = p->r; colors[col_idx+9] = p->g; colors[col_idx+10] = p->b; colors[col_idx+11] = p->a;
				colors[col_idx+12] = p->r; colors[col_idx+13] = p->g; colors[col_idx+14] = p->b; colors[col_idx+15] = p->a;

				vert_idx += 8;
				col_idx += 16;
			}
		}
	}

	if (last)
	{
		ps->batch_nb = vert_idx / 2;
		ps->alive = alive || ps->no_stop;

		SDL_mutexV(ps->lock);
	}
}

// Runs into particles thread
static int particles_emit(lua_State *L)
{
	plist *l = (plist*)lua_touserdata(L, lua_upvalueindex(1)); // The first upvalue, store in the closure, is the particle's plist
	particles_type *ps = l->ps;
	if (!ps || !ps->init) return 0;
	int nb = luaL_checknumber(L, 2);
	if (!nb) return 0;
//	printf("Emitting %d particles out of %d for system %x\n", nb, ps->nb, (int)ps);

	nb = (nb * ps->density) / 100;
	if (!nb) nb = 1;

	int i;
	for (i = 0; i < ps->nb; i++)
	{
		particle_type *p = &ps->particles[i];

		if (!p->life)
		{
			if (l->generator_ref == LUA_NOREF)
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
				lua_getglobal(L, "__fcts");
				lua_pushnumber(L, l->generator_ref);
				lua_rawget(L, -2);
				if (lua_pcall(L, 0, 1, 0))
				{
					printf("Particle emitter error %x (%d): %s\n", (int)l, l->generator_ref, lua_tostring(L, -1));
					lua_pop(L, 1);
				}
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
				lua_pop(L, 1);
				lua_pop(L, 1); // global table
			}
			p->ox = p->x;
			p->oy = p->y;

			nb--;
			if (!nb) break;
		}
	}
	return 0;
}

static const struct luaL_reg particleslib[] =
{
	{"newEmitter", particles_new},
	{NULL, NULL},
};

static const struct luaL_reg particles_reg[] =
{
	{"__gc", particles_free},
	{"toScreen", particles_to_screen},
	{"isAlive", particles_is_alive},
	{"die", particles_die},
	{NULL, NULL},
};

int luaopen_particles(lua_State *L)
{
	auxiliar_newclass(L, "core{particles}", particles_reg);
	luaL_openlib(L, "core.particles", particleslib, 0);
	lua_pushstring(L, "ETERNAL");
	lua_pushnumber(L, PARTICLE_ETERNAL);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	// Make a table to store all textures
	lua_newtable(L);
	textures_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	return 1;
}

/*********************************************************
 ** Multithread particle code
 *********************************************************/

// Runs on particles thread
void thread_particle_run(particle_thread *pt, plist *l)
{
	lua_State *L = pt->L;
	particles_type *ps = l->ps;
	if (!ps || !ps->l || !ps->init || !ps->alive || ps->i_want_to_die) return;

	// Update
	lua_getglobal(L, "__fcts");
	lua_pushnumber(L, l->updator_ref);
	lua_rawget(L, -2);
	lua_pushnumber(L, l->emit_ref);
	lua_rawget(L, -3);
	if (lua_pcall(L, 1, 0, 0))
	{
		printf("L(%x) Particle updater error %x (%d, %d): %s\n", (int)L, (int)l, l->updator_ref, l->emit_ref, lua_tostring(L, -1));
//		ps->i_want_to_die = TRUE;
		lua_pop(L, 1);
	}
	lua_pop(L, 1); // global table

	particles_update(L, ps, TRUE);
}

// Runs on particles thread
extern int docall (lua_State *L, int narg, int nret);
void thread_particle_init(particle_thread *pt, plist *l)
{
	lua_State *L = pt->L;
	particles_type *ps = l->ps;
	int tile_w, tile_h;
	int base_size = 0;

	// Load the particle definition
	// Returns: generator_fct:1, update_fct:2, max:3, gl:4, no_stop:5
	if (!luaL_loadfile(L, ps->name_def))
	{
		// Make a new table to serve as environment for the function
		lua_newtable(L);
		if (!luaL_loadstring(L, ps->args))
		{
			lua_pushvalue(L, -2); // Copy the evn table
			lua_setfenv(L, -2); // Set it as the function env
			if (lua_pcall(L, 0, 0, 0))
			{
				printf("Particle args init error %x (%s): %s\n", (int)l, ps->args, lua_tostring(L, -1));
				lua_pop(L, 1);
			}
		}
		else
		{
			lua_pop(L, 1);
			printf("Loading particle arguments failed: %s\n", ps->args);
		}

		// Copy tile_w and tile_h for compatibility with old code
		lua_pushstring(L, "engine");
		lua_newtable(L);

		lua_pushstring(L, "Map");
		lua_newtable(L);

		lua_pushstring(L, "tile_w");
		lua_pushstring(L, "tile_w");
		lua_gettable(L, -7);
		tile_w = lua_tonumber(L, -1);
		lua_settable(L, -3);
		lua_pushstring(L, "tile_h");
		lua_pushstring(L, "tile_h");
		lua_gettable(L, -7);
		tile_h = lua_tonumber(L, -1);
		lua_settable(L, -3);

		lua_settable(L, -3);
		lua_settable(L, -3);

		// The metatable which references the global space
		lua_newtable(L);
		lua_pushstring(L, "__index");
		lua_pushvalue(L, LUA_GLOBALSINDEX);
		lua_settable(L, -3);

		// Set the environment metatable
		lua_setmetatable(L, -2);

		// Set the environment
		lua_pushvalue(L, -1);
		lua_setfenv(L, -3);
		lua_insert(L, -2);

		// Call the method
		if (lua_pcall(L, 0, 5, 0))
		{
			printf("Particle run error %x (%s): %s\n", (int)l, ps->args, lua_tostring(L, -1));
			lua_pop(L, 1);
		}

		// Check base size
		lua_pushstring(L, "base_size");
		lua_gettable(L, -7);
		base_size = lua_tonumber(L, -1);
		lua_pop(L, 1);
		lua_remove(L, -6);
	}
	else { lua_pop(L, 1); return; }

	int nb = lua_isnumber(L, 3) ? lua_tonumber(L, 3) : 1000;
	nb = (nb * ps->density) / 100;
	if (!nb) nb = 1;
	ps->nb = nb;
	ps->no_stop = lua_toboolean(L, 5);

	ps->zoom = 1;
	if (base_size)
	{
		ps->zoom = (((float)tile_w + (float)tile_h) / 2) / (float)base_size;
	}

	int batch = nb;
	ps->batch_nb = 0;
	ps->vertices = calloc(2*4*batch, sizeof(GLfloat)); // 2 coords, 4 vertices per particles
	ps->colors = calloc(4*4*batch, sizeof(GLfloat)); // 4 color data, 4 vertices per particles
	ps->texcoords = calloc(2*4*batch, sizeof(GLshort));
	ps->particles = calloc(nb, sizeof(particle_type));

	// Locate the updator
	lua_getglobal(L, "__fcts");
	l->updator_ref = lua_objlen(L, -1) + 1;
	lua_pushnumber(L, lua_objlen(L, -1) + 1);
	lua_pushvalue(L, 2);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	// Grab all parameters
	lua_pushvalue(L, 1);

	lua_pushstring(L, "system_rotation");
	lua_gettable(L, -2);
	ps->rotate = lua_tonumber(L, -1); lua_pop(L, 1);
	lua_pushstring(L, "system_rotationv");
	lua_gettable(L, -2);
	ps->rotate_v = lua_tonumber(L, -1); lua_pop(L, 1);

	lua_pushstring(L, "generator");
	lua_gettable(L, -2);
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		l->generator_ref = LUA_NOREF;
	}
	else
	{
		lua_getglobal(L, "__fcts");
		l->generator_ref = lua_objlen(L, -1) + 1;
		lua_pushnumber(L, lua_objlen(L, -1) + 1);
		lua_pushvalue(L, -3);
		lua_rawset(L, -3);
		lua_pop(L, 2);
	}

	if (l->generator_ref == LUA_NOREF)
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
//		printf("Particle emiter using default generator\n");
	}
	else
	{
//		printf("Particle emiter using custom generator\n");
	}
	lua_pop(L, 1);

	// Pop all returns
	lua_pop(L, 5);

	// Push a special emitter
	lua_newtable(L);
	lua_pushstring(L, "ps");
	lua_newtable(L);

	lua_pushstring(L, "emit");
	lua_pushlightuserdata(L, l);
	lua_pushcclosure(L, particles_emit, 1);
	lua_settable(L, -3);

	lua_settable(L, -3);

	lua_getglobal(L, "__fcts");
	l->emit_ref = lua_objlen(L, -1) + 1;
	lua_pushnumber(L, lua_objlen(L, -1) + 1);
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);
	lua_pop(L, 1);

	free((char*)ps->name_def);
	free((char*)ps->args);
	ps->name_def = ps->args = NULL;
	ps->init = TRUE;
}

void thread_particle_die(particle_thread *pt, plist *l)
{
	lua_State *L = pt->L;
	particles_type *ps = l->ps;

//	printf("Deleting particle from list %x :: %x\n", (int)l, (int)ps);
	lua_getglobal(L, "__fcts");
	if (l->emit_ref != LUA_NOREF)
	{
		lua_pushnumber(L, l->emit_ref);
		lua_pushnil(L);
		lua_rawset(L, -3);
	}
	if (l->updator_ref != LUA_NOREF)
	{
		lua_pushnumber(L, l->updator_ref);
		lua_pushnil(L);
		lua_rawset(L, -3);
	}
	if (l->generator_ref != LUA_NOREF)
	{
		lua_pushnumber(L, l->generator_ref);
		lua_pushnil(L);
		lua_rawset(L, -3);
	}
	lua_pop(L, 1);
	l->emit_ref = LUA_NOREF;
	l->updator_ref = LUA_NOREF;
	l->generator_ref = LUA_NOREF;

	if (ps)
	{
		if (ps->texcoords) { free(ps->texcoords); ps->texcoords = NULL; }
		if (ps->vertices) { free(ps->vertices); ps->vertices = NULL; }
		if (ps->colors) { free(ps->colors); ps->colors = NULL; }
		if (ps->particles) { free(ps->particles); ps->particles = NULL; }
		ps->init = FALSE;
		ps->alive = FALSE;
	}
}

// Runs on particles thread
int thread_particles(void *data)
{
	particle_thread *pt = (particle_thread*)data;

	lua_State *L = lua_open();  /* create state */
	luaL_openlibs(L);  /* open libraries */
	luaopen_core(L);
	luaopen_particles(L);
	pt->L = L;
	lua_newtable(L);
	lua_setglobal(L, "__fcts");

	// Override "print" if requested
	if (no_debug)
	{
		lua_pushcfunction(L, noprint);
		lua_setglobal(L, "print");
	}

	// And run the lua engine pre init scripts
	if (!luaL_loadfile(L, "/loader/pre-init.lua")) docall(L, 0, 0);
	else lua_pop(L, 1);

	plist *prev;
	plist *l;
	while (pt->running)
	{
		// Wait for a keyframe
//		printf("Runing particle thread %d (waiting for sem)\n", pt->id);
		SDL_SemWait(pt->keyframes);
//		printf("Runing particle thread %d (waiting for mutex; running(%d))\n", pt->id, pt->running);
		if (!pt->running) break;

		SDL_mutexP(pt->lock);
		int nb = 0;
		l = pt->list;
		prev = NULL;
		while (l)
		{
			if (l->ps && l->ps->alive && !l->ps->i_want_to_die)
			{
				if (l->ps->init) thread_particle_run(pt, l);
				else thread_particle_init(pt, l);

				prev = l;
				l = l->next;
			}
			else
			{
				thread_particle_die(pt, l);

				// Remove dead ones
				if (!prev) pt->list = l->next;
				else prev->next = l->next;

				l = l->next;
			}
			nb++;
		}
//		printf("Particles thread %d has %d systems\n", pt->id, nb);
		SDL_mutexV(pt->lock);
	}

	printf("Cleaning up particle thread %d\n", pt->id);

	// Cleanup
	SDL_mutexP(pt->lock);
	l = pt->list;
	while (l)
	{
		thread_particle_die(pt, l);
		l = l->next;
	}
	SDL_mutexV(pt->lock);

	lua_close(L);

	SDL_DestroySemaphore(pt->keyframes);
	SDL_DestroyMutex(pt->lock);
	printf("Cleaned up particle thread %d\n", pt->id);

	return(0);
}

// Runs on main thread
// Signals all particles threads that some new keyframes have arrived
void thread_particle_new_keyframes(int nb_keyframes)
{
	int i, j;
	for (i = 0; i < MAX_THREADS; i++)
	{
		for (j = 0; j < nb_keyframes; j++) SDL_SemPost(threads[i].keyframes);
	}
}

// Runs on main thread
void thread_add(particles_type *ps)
{
	particle_thread *pt = &threads[cur_thread];

	// Insert it in the head of the list
	SDL_mutexP(pt->lock);
	plist *l = malloc(sizeof(plist));
	l->pt = pt;
	l->ps = ps;
	l->next = pt->list;
	pt->list = l;
	ps->l = l;
	SDL_mutexV(pt->lock);

//	printf("New particles registered on thread %d: %s\n", cur_thread, ps->name_def);

	cur_thread++;
	if (cur_thread >= MAX_THREADS) cur_thread = 0;
}

// Runs on main thread
void free_particles_thread()
{
	if (!threads) return;

	int i;
	for (i = 0; i < MAX_THREADS; i++)
	{
		int status;
		int sem_res;
		particle_thread *pt = &threads[i];

		printf("Destroying particle thread %d (waiting for mutex)\n", i);
		SDL_mutexP(pt->lock);
		pt->running = FALSE;
		SDL_mutexV(pt->lock);

		printf("Destroying particle thread %d\n", i);
		sem_res = SDL_SemPost(pt->keyframes);
		if (sem_res) printf("Error while waiting for particle thread to die: %s\n", SDL_GetError());
		printf("Destroying particle thread %d (waiting for thread %x)\n", i, (int)pt->thread);
		SDL_WaitThread(pt->thread, &status);
		printf("Destroyed particle thread %d (%d)\n", i, status);
	}
	nb_threads = 0;
	free(threads);
	threads = NULL;
}

// Runs on main thread
void create_particles_thread()
{
	int i;

	// Previous ones
	if (threads)
	{
		free_particles_thread();
	}

	MAX_THREADS = nb_cpus - 1;
	MAX_THREADS = (MAX_THREADS < 1) ? 1 : MAX_THREADS;
	MAX_THREADS = 1;
	threads = calloc(MAX_THREADS, sizeof(particle_thread));

	cur_thread = 0;
	for (i = 0; i < MAX_THREADS; i++)
	{
		SDL_Thread *thread;
		particle_thread *pt = &threads[i];

		pt->id = nb_threads++;
		pt->list = NULL;
		pt->lock = SDL_CreateMutex();
		pt->keyframes = SDL_CreateSemaphore(0);
		pt->running = TRUE;

		thread = SDL_CreateThread(thread_particles, "particles", pt);
		if (thread == NULL) {
			printf("Unable to create particle thread: %s\n", SDL_GetError());
			continue;
		}
		pt->thread = thread;

		printf("Creating particles thread %d\n", pt->id);
	}
}
