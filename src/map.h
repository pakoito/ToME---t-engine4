#ifndef _MAP_H_
#define _MAP_H_

#include <gl.h>

typedef struct {
	GLuint **grids_terrain;
	GLuint **grids_actor;
	GLuint **grids_object;
	GLuint **grids_trap;
	bool **grids_seens;
	bool **grids_remembers;
	bool **grids_lites;

	bool multidisplay;

	// Map size
	int w;
	int h;
	int tile_w, tile_h;

	// Scrolling
	int mx, my, mwidth, mheight;
} map_type;

#endif
