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
#ifndef _PARTICLES_H_
#define _PARTICLES_H_

#include <gl.h>

typedef struct {
	float size, sizev, sizea;
	float x, y, xv, yv, xa, ya;
	float dir, dirv, dira, vel, velv, vela;
	float r, g, b, a, rv, gv, bv, av, ra, ga, ba, aa;
	int life;
} particle_type;

typedef struct {
	GLuint texture;
	particle_type *particles;
	int nb;
	int texture_ref;
	int generator_ref;

	int base;

	int angle_min, anglev_min, anglea_min;
	int angle_max, anglev_max, anglea_max;

	int size_min, sizev_min, sizea_min;
	int x_min, y_min, xv_min, yv_min, xa_min, ya_min;
	int r_min, g_min, b_min, a_min, rv_min, gv_min, bv_min, av_min, ra_min, ga_min, ba_min, aa_min;

	int size_max, sizev_max, sizea_max;
	int x_max, y_max, xv_max, yv_max, xa_max, ya_max;
	int r_max, g_max, b_max, a_max, rv_max, gv_max, bv_max, av_max, ra_max, ga_max, ba_max, aa_max;

	int life_min, life_max;
} particles_type;

#endif
