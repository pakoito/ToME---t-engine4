#ifndef _PARTICLES_H_
#define _PARTICLES_H_

#include <gl.h>

typedef struct {
	float size, sizev, sizea;
	float x, y, xv, yv, xa, ya;
	float r, g, b, a, rv, gv, bv, av, ra, ga, ba, aa;
	int life;
} particle_type;

typedef struct {
	GLuint texture;
	particle_type *particles;
	int nb;
	int texture_ref;

	float base;

	float size_min, sizev_min, sizea_min;
	float x_min, y_min, xv_min, yv_min, xa_min, ya_min;
	float r_min, g_min, b_min, a_min, rv_min, gv_min, bv_min, av_min, ra_min, ga_min, ba_min, aa_min;

	float size_max, sizev_max, sizea_max;
	float x_max, y_max, xv_max, yv_max, xa_max, ya_max;
	float r_max, g_max, b_max, a_max, rv_max, gv_max, bv_max, av_max, ra_max, ga_max, ba_max, aa_max;

	float life_min, life_max;
} particles_type;

#endif
