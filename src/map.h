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
#ifndef _MAP_H_
#define _MAP_H_

#include "tgl.h"
#include "useshader.h"

struct s_map_object {
	int nb_textures;
	int *textures_ref;
	GLuint *textures;
	GLfloat *tex_x, *tex_y, *tex_factorx, *tex_factory;
	bool *textures_is3d;
	shader_type *shader;
	int cur_x, cur_y;
	float dx, dy, scale;
	float animdx, animdy;
	float dw, dh;
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
	int move_step, move_max, move_blur, move_twitch_dir;
	float move_twitch;
	int anim_max, anim_loop;
	float anim_step, anim_speed;
	enum {DL_NONE, DL_TRUE_LAST, DL_TRUE} display_last;
	long uid;

	int cb_ref;

	struct s_map_object *next;
	int next_ref;
};
typedef struct s_map_object map_object;

typedef struct {
	map_object* ***grids;
	int ***grids_ref;
	float *grids_seens;
	bool **grids_remembers;
	bool **grids_lites;
	bool **grids_important;

	GLubyte *minimap;
	GLuint mm_texture;
	int mm_w, mm_h;
	int mm_rw, mm_rh;

	GLfloat *vertices;
	GLfloat *colors;
	GLfloat *texcoords;
	GLubyte *seens_map;
	int seens_map_w, seens_map_h;

	int *z_callbacks;

	GLuint seens_texture;

	int mo_list_ref;

	int minimap_gridsize;

	int is_hex;

	// Map parameters
	float obscure_r, obscure_g, obscure_b, obscure_a;
	float shown_r, shown_g, shown_b, shown_a;

	// Map size
	int w;
	int h;
	int zdepth;
	int tile_w, tile_h;
	GLfloat tex_tile_w[3], tex_tile_h[3];

	// Scrolling
	int mx, my, mwidth, mheight;
	float oldmx, oldmy;
	int move_step, move_max;
	float used_mx, used_my;
	float used_animdx, used_animdy;
	int seensinfo_w;
	int seensinfo_h;
	bool seen_changed;
} map_type;

#endif
