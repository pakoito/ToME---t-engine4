/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2014 Nicolas Casalini

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

#include "tgl.h"

typedef struct {
	GLuint texture;
	int texture_ref;
	int generator_ref;

	float last_tick;

	int w, h;
	int size;
	int n;

	// 2D velocity maps (current and previous)
	float *u, *v, *u_prev, *v_prev;

	// density maps (current and previous)
	float *dens, *dens_prev;

	float visc;
	float diff;
	float force;
	float source;
	float stepDelay;
} gaszone_type;

#endif
