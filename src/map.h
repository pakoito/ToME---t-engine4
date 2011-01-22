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
#ifndef _MAP_H_
#define _MAP_H_

#include "tgl.h"
#include "useshader.h"

typedef struct {
	int nb_textures;
	int *textures_ref;
	GLuint *textures;
	bool *textures_is3d;
	shader_type *shader;
	float dx, dy, scale;
	float tint_r;
	float tint_g;
	float tint_b;
	float mm_r;
	float mm_g;
	float mm_b;
	bool on_seen;
	bool on_remember;
	bool on_unknown;
	bool valid;
	float oldx, oldy;
	int move_step, move_max, move_blur;
	enum {DL_NONE, DL_TRUE_LAST, DL_TRUE} display_last;
	long uid;
} map_object;

typedef struct {
	map_object* ***grids;
	float **grids_seens;
	bool **grids_remembers;
	bool **grids_lites;
	unsigned char **minimap;

	GLfloat *vertices;
	GLfloat *colors;
	GLfloat *texcoords;

	int mo_list_ref;

	int minimap_gridsize;

	// Map parameters
	float obscure_r, obscure_g, obscure_b, obscure_a;
	float shown_r, shown_g, shown_b, shown_a;

	// Map size
	int w;
	int h;
	int zdepth;
	int tile_w, tile_h;
	GLfloat tex_tile_w, tex_tile_h;

	// Scrolling
	int mx, my, mwidth, mheight;
	float oldmx, oldmy;
	int move_step, move_max;
} map_type;

#endif
