#ifndef _MAP_H_
#define _MAP_H_

#include <GL/gl.h>

typedef struct {
	GLuint **grids_terrain;
	GLuint **grids_actor;
	GLuint **grids_object;
	bool **grids_seens;
	bool **grids_remembers;
	bool **grids_lites;

	bool multidisplay;

	// Map size
	int w;
	int h;

	// Scrolling
	int mx, my, mwidth, mheight;
} map_type;

#endif
