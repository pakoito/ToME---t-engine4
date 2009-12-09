#ifndef _MAP_H_
#define _MAP_H_

#include <GL/gl.h>

typedef struct {
	GLuint **grids;

	GLuint dlist;

	// Map size
	int w;
	int h;

	// Scrolling
	int mx, my, mwidth, mheight;
} map_type;

#endif
