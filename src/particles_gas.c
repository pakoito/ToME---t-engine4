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
#include "particles_gas.h"
#include "script.h"
#include <math.h>
#include "SFMT.h"

#define rng(x, y) (x + rand_div(1 + y - x))

static void getparticulefield(lua_State *L, const char *k, float *v)
{
	lua_pushstring(L, k);
	lua_gettable(L, -2);
	*v = (float)lua_tonumber(L, -1);
//	printf("emit %s :: %f\n", k, *v);
	lua_pop(L, 1);
}

static int gas_new(lua_State *L)
{
	int w = luaL_checknumber(L, 1);
	int h = luaL_checknumber(L, 2);
//	int density = luaL_checknumber(L, 3);
	GLuint *t = (GLuint*)auxiliar_checkclass(L, "gl{texture}", 5);
	int t_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	int p_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	gaszone_type *gz = (gaszone_type*)lua_newuserdata(L, sizeof(gaszone_type));
	auxiliar_setclass(L, "core{gas}", -1);

	gz->last_tick = -1;
	gz->w = w;
	gz->h = h;
	gz->n = (w*2 > h*2) ? w*2 : h*2;
	gz->size = (gz->n + 2) * (gz->n + 2);

	gz->visc = 1E-4f;
	gz->diff = 1E-5f;
	gz->force = 20.0f;
	gz->source = 3000.0f;
	gz->stepDelay  = 0.0f;

	gz->texture = *t;
	gz->texture_ref = t_ref;

	gz->u = calloc(gz->size, sizeof(float));
	gz->v = calloc(gz->size, sizeof(float));
	gz->dens = calloc(gz->size, sizeof(float));
	gz->u_prev = calloc(gz->size, sizeof(float));
	gz->v_prev = calloc(gz->size, sizeof(float));
	gz->dens_prev = calloc(gz->size, sizeof(float));

	int i;
	for (i=0; i < gz->size; i++)
	{
		gz->u[i] = 0.0f;
		gz->u_prev[i] = 0.0f;
		gz->v[i] = 0.0f;
		gz->v_prev[i] = 0.0f;
		gz->dens[i] = 0.0f;
		gz->dens_prev[i] = 0.0f;
	}

	printf("Making gas emitter with size %dx%d\n", w, h);

	// Grab all parameters
	lua_rawgeti(L, LUA_REGISTRYINDEX, p_ref);

	lua_pushstring(L, "generator");
	lua_gettable(L, -2);
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		gz->generator_ref = LUA_NOREF;
	}
	else
		gz->generator_ref = luaL_ref(L, LUA_REGISTRYINDEX);

	if (gz->generator_ref == LUA_NOREF)
	{
		lua_pushstring(L, "Gas cloud created without a lua generator!");
		lua_error(L);
	}
	lua_pop(L, 1);

	luaL_unref(L, LUA_REGISTRYINDEX, p_ref);

	return 1;
}

static int gas_free(lua_State *L)
{
	gaszone_type *gz = (gaszone_type*)auxiliar_checkclass(L, "core{gas}", 1);

	free(gz->u);
	free(gz->v);
	free(gz->dens);
	free(gz->u_prev);
	free(gz->v_prev);
	free(gz->dens_prev);

	luaL_unref(L, LUA_REGISTRYINDEX, gz->texture_ref);
	if (gz->generator_ref) luaL_unref(L, LUA_REGISTRYINDEX, gz->generator_ref);

	lua_pushnumber(L, 1);
	return 1;
}

#define IX(i,j) ((i)+(gz->n+2)*(j))
#define SWAP(x0,x) {float *tmp=x0;x0=x;x=tmp;}

// set boundary conditions
void set_bnd (gaszone_type *gz, int b, float * x ) {
	int i;
	for ( i=1 ; i<=gz->n ; i++ ) {
		// west and east walls
		x[IX(0,i)] = b == 1 ? -x[IX(1,i)] : x[IX(1,i)];
		x[IX(gz->n+1,i)] = b == 1 ? -x[IX(gz->n,i)] : x[IX(gz->n,i)];
		// boundary doesn't work on north and south walls...
		// dunno why...
		x[IX(i,0)] = b == 1 ? -x[IX(i,1)] : x[IX(i,1)];
		x[IX(i,gz->n+1)] = b == 1 ? -x[IX(i,gz->n)] : x[IX(i,gz->n)];
	}
	// boundary conditions at corners
	x[IX(0  ,0  )] = 0.5*(x[IX(1,0  )]+x[IX(0  ,1)]);
	x[IX(0  ,gz->n+1)] = 0.5*(x[IX(1,gz->n+1)]+x[IX(0  ,gz->n )]);
	x[IX(gz->n+1,0  )] = 0.5*(x[IX(gz->n,0  )]+x[IX(gz->n+1,1)]);
	x[IX(gz->n+1,gz->n+1)] = 0.5*(x[IX(gz->n,gz->n+1)]+x[IX(gz->n+1,gz->n )]);
}


// update density map according to density sources
// x : density map
// s : density source map
// dt : elapsed time
void add_source(gaszone_type *gz, float *x, float *s, float dt) {
	int i;
	for (i=0; i < gz->size; i++) {
		x[i] += dt*s[i];
	}
}

// update density or velocity map for diffusion
// b : boundary width
// x : current density map
// x0 : previous density map
// diff : diffusion coef
// dt : elapsed time
void diffuse(gaszone_type *gz,  int b, float *x, float *x0, float diff, float dt) {
	float a = diff*dt*gz->n*gz->n;
	int i, j, k;
	for (k=0; k < 20; k++) {
		for (i=1; i <= gz->n; i++ ) {
			for (j=1; j<= gz->n; j++) {
				x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)]+x[IX(i+1,j)]
					+x[IX(i,j-1)]+x[IX(i,j+1)]))/(1+4*a);
			}
		}
		set_bnd(gz, b,x);
	}
}

// update density map according to velocity map
// b : boundary width
// d : current density map
// d0 : previous density map
// u,v : current velocity map
// dt : elapsed time
void advect (gaszone_type *gz,  int b, float * d, float * d0, float * u, float * v, float dt ) {
	int i0, j0, i1, j1;
	float x, y, s0, t0, s1, t1, dt0;

	dt0 = dt*gz->n;
	int i, j;
	for (i=1 ; i<=gz->n ; i++ ) {
		for (j=1 ; j<=gz->n ; j++ ) {
			x = i-dt0*u[IX(i,j)];
			y = j-dt0*v[IX(i,j)];
			if (x<0.5) x=0.5;
			if (x>gz->n+0.5) x=gz->n+ 0.5;
			i0=(int)x;
			i1=i0+1;
			if (y<0.5) y=0.5;
			if (y>gz->n+0.5) y=gz->n+ 0.5;
			j0=(int)y;
			j1=j0+1;
			s1 = x-i0;
			s0 = 1-s1;
			t1 = y-j0;
			t0 = 1-t1;
			d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
			s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
		}
	}
	set_bnd (gz, b, d );
}

void project (gaszone_type *gz,  float * u, float * v, float * p, float * div ) {
	int i, j, k;

	float h = 1.0/gz->n;
	for (i=1 ; i<=gz->n ; i++ ) {
		for (j=1 ; j<=gz->n ; j++ ) {
			div[IX(i,j)] = -0.5*h*(u[IX(i+1,j)]-u[IX(i-1,j)]+
				v[IX(i,j+1)]-v[IX(i,j-1)]);
			p[IX(i,j)] = 0;
		}
	}
	set_bnd (gz, 0, div ); set_bnd (gz, 0, p );

	for (k=0 ; k<19 ; k++ ) {
		for (i=1 ; i<=gz->n ; i++ ) {
			for (j=1 ; j<=gz->n ; j++ ) {
				p[IX(i,j)] = (div[IX(i,j)] + p[IX(i-1,j)] + p[IX(i+1,j)] + p[IX(i,j-1)] + p[IX(i,j+1)]) / 4;
			}
		}
		set_bnd (gz, 0, p );
	}

	for (i=1 ; i<=gz->n ; i++ ) {
		for (j=1 ; j<=gz->n ; j++ ) {
			u[IX(i,j)] -= 0.5*(p[IX(i+1,j)]-p[IX(i-1,j)])/h;
			v[IX(i,j)] -= 0.5*(p[IX(i,j+1)]-p[IX(i,j-1)])/h;
		}
	}
	set_bnd (gz, 1, u ); set_bnd (gz, 2, v );
}

// do all three density steps
void update_density (gaszone_type *gz,  float * x, float * x0,  float * u, float * v, float diff,  float dt ) {
	add_source (gz, x, x0, dt );
	SWAP ( x0, x ); diffuse (gz, 0, x, x0, diff, dt );
	SWAP ( x0, x ); advect (gz, 0, x, x0, u, v, dt );
}

void update_velocity(gaszone_type *gz, float * u, float * v, float * u0, float * v0,  float visc, float dt ) {
	add_source (gz, u, u0, dt );
	add_source (gz, v, v0, dt );
	SWAP ( u0, u ); diffuse (gz, 1, u, u0, visc, dt );
	SWAP ( v0, v ); diffuse (gz, 2, v, v0, visc, dt );
	project (gz, u, v, u0, v0 );
	SWAP ( u0, u ); SWAP ( v0, v );
	advect (gz, 1, u, u0, u0, v0, dt ); advect (gz, 2, v, v0, u0, v0, dt );
	project (gz, u, v, u0, v0 );
}

void add_data (lua_State *L, gaszone_type *gz, float * d, float * u, float * v, float elapsed)
{
	int i;
	for ( i=0 ; i < gz->size; i++ )
	{
		u[i] = v[i] = d[i] = 0.0f;
	}

	int px;
	int py;
	float dx;
	float dy;

	lua_rawgeti(L, LUA_REGISTRYINDEX, gz->generator_ref);
	lua_call(L, 0, 1);
	if (!lua_isnil(L, -1))
	{
		int len = lua_objlen(L, -1);
		for (i = 1; i <= len; i++)
		{
			lua_pushnumber(L, i);
			lua_gettable(L, -2);

			float tmp;
			getparticulefield(L, "sx", &tmp); px = tmp;
			getparticulefield(L, "sy", &tmp); py = tmp;
			getparticulefield(L, "dx", &dx);
			getparticulefield(L, "dy", &dy);
			float l = sqrt(dx*dx+dy*dy);
			if (l > 0.0f)
			{
				l = 1.0f / l;
				dx *= l;
				dy *= l;
				u[IX(px*2, py*2)] = gz->force * dx;
				v[IX(px*2, py*2)] = gz->force * dy;
				d[IX(px*2, py*2)] = gz->source;
			}

			lua_pop(L, 1);
		}
		lua_pop(L, 1);
	}
}

void update(lua_State *L, gaszone_type *gz, float elapsed) {
	add_data(L, gz, gz->dens_prev, gz->u_prev, gz->v_prev, elapsed);
	update_velocity(gz, gz->u, gz->v, gz->u_prev, gz->v_prev, gz->visc, elapsed);
	update_density(gz, gz->dens, gz->dens_prev, gz->u, gz->v, gz->diff, elapsed);
}

#define CLAMP(a, b, x) ((x) < (a) ? (a) : ((x) > (b) ? (b) : (x)))

static int gas_emit(lua_State *L)
{
//	gaszone_type *gz = (gaszone_type*)auxiliar_checkclass(L, "core{gas}", 1);

	return 0;
}

static int gas_to_screen(lua_State *L)
{
	gaszone_type *gz = (gaszone_type*)auxiliar_checkclass(L, "core{gas}", 1);
	int x = luaL_checknumber(L, 2);
	int y = luaL_checknumber(L, 3);
//	bool show = lua_toboolean(L, 4);
//	float zoom = luaL_checknumber(L, 5);
	int i, j, dx, dy;
	int vert_idx = 0, col_idx = 0;

	GLfloat vertices[2*4*1000];
	GLfloat colors[4*4*1000];
	GLshort texcoords[2*4*1000];

	glBindTexture(GL_TEXTURE_2D, gz->texture);
	glTexCoordPointer(2, GL_SHORT, 0, texcoords);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(2, GL_FLOAT, 0, vertices);

	for (dx=0; dx <= gz->n; dx++)
	{
		for (dy = 0; dy <= gz->n; dy++)
		{
			float coef = (float)(gz->dens[IX(dx, dy)] / 128.0f);
			coef = CLAMP(0.0f, 1.0f, coef);
			if (coef > 0.1)
			{
				i = x + dx * 4;
				j = y + dy * 4;

				vertices[vert_idx+0] = i; vertices[vert_idx+1] = j;
				vertices[vert_idx+2] = i + 10; vertices[vert_idx+3] = j;
				vertices[vert_idx+4] = i + 10; vertices[vert_idx+5] = j + 10;
				vertices[vert_idx+6] = i; vertices[vert_idx+7] = j + 10;

				/* Setup texture coords */
				texcoords[vert_idx] = 0; texcoords[vert_idx+1] = 0;
				texcoords[vert_idx+2] = 1; texcoords[vert_idx+3] = 0;
				texcoords[vert_idx+4] = 1; texcoords[vert_idx+5] = 1;
				texcoords[vert_idx+6] = 0; texcoords[vert_idx+7] = 1;

				/* Setup color */
				colors[col_idx] = coef; colors[col_idx+1] = 0; colors[col_idx+2] = 0; colors[col_idx+3] = coef;
				colors[col_idx+4] = coef; colors[col_idx+5] = 0; colors[col_idx+6] = 0; colors[col_idx+7] = coef;
				colors[col_idx+8] = coef; colors[col_idx+9] = 0; colors[col_idx+10] = 0; colors[col_idx+11] = coef;
				colors[col_idx+12] = coef; colors[col_idx+13] = 0; colors[col_idx+14] = 0; colors[col_idx+15] = coef;

				/* Draw if over PARTICLES_PER_ARRAY particles */
				vert_idx += 8;
				col_idx += 16;
				if (vert_idx >= 2*4*1000) {
					// Draw them all in one fell swoop
					glDrawArrays(GL_QUADS, 0, vert_idx / 2);
					vert_idx = 0;
					col_idx = 0;
				}
			}
		}
	}

	// Draw them all in one fell swoop
	if (vert_idx) glDrawArrays(GL_QUADS, 0, vert_idx / 2);

	lua_pushboolean(L, 1);
	return 1;
}

static int gas_update(lua_State *L)
{
	gaszone_type *gz = (gaszone_type*)auxiliar_checkclass(L, "core{gas}", 1);

	if (gz->last_tick == -1) gz->last_tick = ((float)SDL_GetTicks()) / 1000.0f - 1;

	float now = ((float)SDL_GetTicks()) / 1000.0f;
	update(L, gz, now - gz->last_tick);
	gz->last_tick = now;

	lua_pushboolean(L, 1);
	return 1;
}

static const struct luaL_Reg gaslib[] =
{
	{"newEmitter", gas_new},
	{NULL, NULL},
};

static const struct luaL_Reg gas_reg[] =
{
	{"__gc", gas_free},
	{"close", gas_free},
	{"emit", gas_emit},
	{"update", gas_update},
	{"toScreen", gas_to_screen},
	{NULL, NULL},
};

int luaopen_gas(lua_State *L)
{
	auxiliar_newclass(L, "core{gas}", gas_reg);
	luaL_openlib(L, "core.gas", gaslib, 0);
	lua_pop(L, 1);
	return 1;
}
