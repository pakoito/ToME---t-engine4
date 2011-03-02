/*
 * Copyright (C) 2006, Greg McIntyre
 * All rights reserved. See the file named COPYING in the distribution
 * for more details.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define __USE_ISOC99 1
#include <math.h>
#include <float.h>
#include <assert.h>
#include "fov.h"

/*
+---++---++---++---+
|   ||   ||   ||   |
|   ||   ||   ||   |
|   ||   ||   ||   |
+---++---++---++---+    2
+---++---++---+#####
|   ||   ||   |#####
|   ||   ||   |#####
|   ||   ||   |#####
+---++---++---+#####X 1 <-- y
+---++---++---++---+
|   ||   ||   ||   |
| @ ||   ||   ||   |       <-- srcy centre     -> dy = 0.5 = y - 0.5
|   ||   ||   ||   |
+---++---++---++---+    0
0       1       2       3       4
    ^                       ^
    |                       |
 srcx                   x            -> dx = 3.5 = x + 0.5
centre

Slope from @ to X.

+---++---++---++---+
|   ||   ||   ||   |
|   ||   ||   ||   |
|   ||   ||   ||   |
+---++---++---++---+ 2
+---++---++---++---+
|   ||   ||   ||   |
|   ||   ||   ||   |
|   ||   ||   ||   |
+---++---++---+X---+ 1   <-- y
+---++---++---+#####
|   ||   ||   |#####
| @ ||   ||   |#####      <-- srcy centre     -> dy = 0.5 = y - 0.5
|   ||   ||   |#####
+---++---++---+##### 0
0       1       2       3
    ^                       ^
    |                       |
 srcx                   x            -> dx = 2.5 = x - 0.5
centre

Slope from @ to X
*/


/* Types ---------------------------------------------------------- */

/** \cond INTERNAL */
typedef struct {
    /*@observer@*/ fov_settings_type *settings;
    /*@observer@*/ void *map;
    /*@observer@*/ void *source;
    int source_x;
    int source_y;
    unsigned radius;
} fov_private_data_type;
/** \endcond */

/* Options -------------------------------------------------------- */

void fov_settings_init(fov_settings_type *settings) {
    settings->shape = FOV_SHAPE_CIRCLE_PRECALCULATE;
    settings->corner_peek = FOV_CORNER_NOPEEK;
    settings->opaque_apply = FOV_OPAQUE_APPLY;
    settings->opaque = NULL;
    settings->apply = NULL;
    settings->heights = NULL;
    settings->numheights = 0;
}

void fov_settings_set_shape(fov_settings_type *settings,
                            fov_shape_type value) {
    settings->shape = value;
}

void fov_settings_set_corner_peek(fov_settings_type *settings,
                           fov_corner_peek_type value) {
    settings->corner_peek = value;
}

void fov_settings_set_opaque_apply(fov_settings_type *settings,
                                   fov_opaque_apply_type value) {
    settings->opaque_apply = value;
}

void fov_settings_set_opacity_test_function(fov_settings_type *settings,
                                            bool (*f)(void *map,
                                                      int x, int y)) {
    settings->opaque = f;
}

void fov_settings_set_apply_lighting_function(fov_settings_type *settings,
                                              void (*f)(void *map,
                                                        int x, int y,
                                                        int dx, int dy, int radius,
                                                        void *src)) {
    settings->apply = f;
}

/* Circular FOV --------------------------------------------------- */

/*@null@*/ static unsigned *precalculate_heights(unsigned maxdist) {
    unsigned i;
    unsigned *result = (unsigned *)malloc((maxdist+2)*sizeof(unsigned));
    if (result) {
        for (i = 0; i <= maxdist; ++i) {
            result[i] = (unsigned)sqrtf((float)(maxdist*maxdist - i*i));
        }
        result[maxdist+1] = 0;
    }
    return result;
}

static unsigned height(fov_settings_type *settings, int x,
                unsigned maxdist) {
    unsigned **newheights;

    if (maxdist > settings->numheights) {
        newheights = (unsigned **)calloc((size_t)maxdist, sizeof(unsigned*));
        if (newheights != NULL) {
            if (settings->heights != NULL && settings->numheights > 0) {
                /* Copy the pointers to the heights arrays we've already
                 * calculated. Once copied out, we can free the old
                 * array of pointers. */
                memcpy(newheights, settings->heights,
                       settings->numheights*sizeof(unsigned*));
                free(settings->heights);
            }
            settings->heights = newheights;
            settings->numheights = maxdist;
        }
    }
    if (settings->heights) {
        if (settings->heights[maxdist-1] == NULL) {
            settings->heights[maxdist-1] = precalculate_heights(maxdist);
        }
        if (settings->heights[maxdist-1] != NULL) {
            return settings->heights[maxdist-1][abs(x)];
        }
    }
    return 0;
}

void fov_settings_free(fov_settings_type *settings) {
    unsigned i;
    if (settings != NULL) {
        if (settings->heights != NULL && settings->numheights > 0) {
            /*@+forloopexec@*/
            for (i = 0; i < settings->numheights; ++i) {
                unsigned *h = settings->heights[i];
                if (h != NULL) {
                    free(h);
                }
                settings->heights[i] = NULL;
            }
            /*@=forloopexec@*/
            free(settings->heights);
            settings->heights = NULL;
            settings->numheights = 0;
        }
    }
}

/* Slope ---------------------------------------------------------- */

static float fov_slope(float dx, float dy) {
    if (dx <= -FLT_EPSILON || dx >= FLT_EPSILON) {
        return dy/dx;
    } else {
        return 0.0;
    }
}

/* Octants -------------------------------------------------------- */

#define FOV_DEFINE_OCTANT(signx, signy, rx, ry, nx, ny, nf)                                     \
    static void fov_octant_##nx##ny##nf(                                                        \
                                        fov_private_data_type *data,                            \
                                        int dx,                                                 \
                                        float start_slope,                                      \
                                        float end_slope,                                        \
                                        bool apply_edge,                                        \
                                        bool apply_diag) {                                      \
        int x, y, dy, dy0, dy1;                                                                 \
        unsigned h;                                                                             \
        int prev_blocked = -1;                                                                  \
        float end_slope_next;                                                                   \
        fov_settings_type *settings = data->settings;                                           \
                                                                                                \
        if (dx == 0) {                                                                          \
            fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope, apply_edge, apply_diag); \
            return;                                                                             \
        } else if ((unsigned)dx > data->radius) {                                               \
            return;                                                                             \
        }                                                                                       \
                                                                                                \
        dy0 = (int)(0.5f + ((float)dx)*start_slope);                                            \
        dy1 = (int)(0.5f + ((float)dx)*end_slope);                                              \
                                                                                                \
        rx = data->source_##rx signx dx;                                                        \
        ry = data->source_##ry signy dy0;                                                       \
                                                                                                \
        if (!apply_diag && dy1 == dx) {                                                         \
            /* We do diagonal lines on every second octant, so they don't get done twice. */    \
            --dy1;                                                                              \
                                                                                                \
            /* But, we still need to check if we can see past it if the slopes are similar */   \
            if (dy1 < dy0) {                                                                    \
                if (settings->opaque(data->map, x, y)) {                                        \
                    return;                                                                     \
                }                                                                               \
                prev_blocked = 0;                                                               \
            }                                                                                   \
        }                                                                                       \
                                                                                                \
        /* we also need to check if the previous spot is blocked */                             \
        if (dy0 > 0) {                                                                          \
            ry -= 1;                                                                            \
            if (settings->opaque(data->map, x, y)) {                                            \
                prev_blocked = 1;                                                               \
            }                                                                                   \
            ry += 1;                                                                            \
        }                                                                                       \
                                                                                                \
        switch (settings->shape) {                                                              \
        case FOV_SHAPE_CIRCLE_PRECALCULATE:                                                     \
            h = height(settings, dx, data->radius);                                             \
            break;                                                                              \
        case FOV_SHAPE_CIRCLE:                                                                  \
            h = (unsigned)(sqrt((data->radius)*(data->radius) + data->radius - dx*dx));         \
            break;                                                                              \
        case FOV_SHAPE_OCTAGON:                                                                 \
            h = (data->radius - dx)<<1;                                                         \
            break;                                                                              \
        default:                                                                                \
            h = data->radius;                                                                   \
            break;                                                                              \
        };                                                                                      \
        if ((unsigned)dy1 > h) {                                                                \
            if (h == 0) {                                                                       \
                return;                                                                         \
            }                                                                                   \
            dy1 = (int)h;                                                                       \
        }                                                                                       \
                                                                                                \
        /*fprintf(stderr, "(%2d) = [%2d .. %2d] (%f .. %f), h=%d,edge=%d\n",                    \
                dx, dy0, dy1, ((float)dx)*start_slope,                                          \
                0.5f + ((float)dx)*end_slope, h, apply_edge);*/                                 \
                                                                                                \
        for (dy = dy0; dy <= dy1; ++dy) {                                                       \
            ry = data->source_##ry signy dy;                                                    \
                                                                                                \
            if (settings->opaque(data->map, x, y)) {                                            \
                if (settings->opaque_apply == FOV_OPAQUE_APPLY && (apply_edge || dy > 0)) {     \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y, data->radius, data->source);         \
                }                                                                               \
                if (prev_blocked == 0) {                                                        \
                    end_slope_next = fov_slope((float)dx + 0.5f, (float)dy - 0.5f);             \
                    fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope_next, apply_edge, apply_diag);           \
                }                                                                               \
                prev_blocked = 1;                                                               \
            } else {                                                                            \
                if (apply_edge || dy > 0) {                                                     \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y, data->radius, data->source);         \
                }                                                                               \
                if (prev_blocked == 1) {                                                        \
                    start_slope = fov_slope((float)dx - 0.5f, (float)dy - 0.5f);                \
                }                                                                               \
                prev_blocked = 0;                                                               \
            }                                                                                   \
        }                                                                                       \
                                                                                                \
        if (prev_blocked == 0) {                                                                \
            fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope, apply_edge, apply_diag); \
        }                                                                                       \
    }

FOV_DEFINE_OCTANT(+,+,x,y,p,p,n)
FOV_DEFINE_OCTANT(+,+,y,x,p,p,y)
FOV_DEFINE_OCTANT(+,-,x,y,p,m,n)
FOV_DEFINE_OCTANT(+,-,y,x,p,m,y)
FOV_DEFINE_OCTANT(-,+,x,y,m,p,n)
FOV_DEFINE_OCTANT(-,+,y,x,m,p,y)
FOV_DEFINE_OCTANT(-,-,x,y,m,m,n)
FOV_DEFINE_OCTANT(-,-,y,x,m,m,y)


/* Circle --------------------------------------------------------- */

static void _fov_circle(fov_private_data_type *data) {
    /*
     * Octants are defined by (x,y,r) where:
     *  x = [p]ositive or [n]egative x increment
     *  y = [p]ositive or [n]egative y increment
     *  r = [y]es or [n]o for reflecting on axis x = y
     *
     *   \pmy|ppy/
     *    \  |  /
     *     \ | /
     *   mpn\|/ppn
     *   ----@----
     *   mmn/|\pmn
     *     / | \
     *    /  |  \
     *   /mmy|mpy\
     */
    fov_octant_ppn(data, 1, (float)0.0f, (float)1.0f, true, true);
    fov_octant_ppy(data, 1, (float)0.0f, (float)1.0f, true, false);
    fov_octant_pmy(data, 1, (float)0.0f, (float)1.0f, false, true);
    fov_octant_mpn(data, 1, (float)0.0f, (float)1.0f, true, false);
    fov_octant_mmn(data, 1, (float)0.0f, (float)1.0f, false, true);
    fov_octant_mmy(data, 1, (float)0.0f, (float)1.0f, true, false);
    fov_octant_mpy(data, 1, (float)0.0f, (float)1.0f, false, true);
    fov_octant_pmn(data, 1, (float)0.0f, (float)1.0f, false, false);
}

void fov_circle(fov_settings_type *settings,
                void *map,
                void *source,
                int source_x,
                int source_y,
                unsigned radius) {
    fov_private_data_type data;

    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;

    _fov_circle(&data);
}

/**
 * Limit x to the range [a, b].
 */
static float betweenf(float x, float a, float b) {
    if (x - a < FLT_EPSILON) { /* x < a */
        return a;
    } else if (x - b > FLT_EPSILON) { /* x > b */
        return b;
    } else {
        return x;
    }
}

#define BEAM_DIRECTION(d, p1, p2, p3, p4, p5, p6, p7, p8)               \
    if (direction == d) {                                               \
        end_slope = betweenf(a, 0.0f, 1.0f);                            \
        fov_octant_##p1(&data, 1, 0.0f, end_slope, true, true);         \
        fov_octant_##p2(&data, 1, 0.0f, end_slope, false, true);        \
        if (a - 1.0f > FLT_EPSILON) { /* a > 1.0f */                    \
            start_slope = betweenf(2.0f - a, 0.0f, 1.0f);               \
            fov_octant_##p3(&data, 1, start_slope, 1.0f, true, false);  \
            fov_octant_##p4(&data, 1, start_slope, 1.0f, true, false);  \
        }                                                               \
        if (a - 2.0f > FLT_EPSILON) { /* a > 2.0f */                    \
            end_slope = betweenf(a - 2.0f, 0.0f, 1.0f);                 \
            fov_octant_##p5(&data, 1, 0.0f, end_slope, false, true);    \
            fov_octant_##p6(&data, 1, 0.0f, end_slope, false, true);    \
        }                                                               \
        if (a - 3.0f > FLT_EPSILON) { /* a > 3.0f */                    \
            start_slope = betweenf(4.0f - a, 0.0f, 1.0f);               \
            fov_octant_##p7(&data, 1, start_slope, 1.0f, true, false);  \
            fov_octant_##p8(&data, 1, start_slope, 1.0f, false, false); \
        }                                                               \
    }

#define BEAM_DIRECTION_DIAG(d, p1, p2, p3, p4, p5, p6, p7, p8)          \
    if (direction == d) {                                               \
        start_slope = betweenf(1.0f - a, 0.0f, 1.0f);                   \
        fov_octant_##p1(&data, 1, start_slope, 1.0f, true, true);       \
        fov_octant_##p2(&data, 1, start_slope, 1.0f, true, false);      \
        if (a - 1.0f > FLT_EPSILON) { /* a > 1.0f */                    \
            end_slope = betweenf(a - 1.0f, 0.0f, 1.0f);                 \
            fov_octant_##p3(&data, 1, 0.0f, end_slope, false, true);    \
            fov_octant_##p4(&data, 1, 0.0f, end_slope, false, true);    \
        }                                                               \
        if (a - 2.0f > FLT_EPSILON) { /* a > 2.0f */                    \
            start_slope = betweenf(3.0f - a, 0.0f, 1.0f);               \
            fov_octant_##p5(&data, 1, start_slope, 1.0f, true, false);  \
            fov_octant_##p6(&data, 1, start_slope, 1.0f, true, false);  \
        }                                                               \
        if (a - 3.0f > FLT_EPSILON) { /* a > 3.0f */                    \
            end_slope = betweenf(a - 3.0f, 0.0f, 1.0f);                 \
            fov_octant_##p7(&data, 1, 0.0f, end_slope, false, true);    \
            fov_octant_##p8(&data, 1, 0.0f, end_slope, false, false);   \
        }                                                               \
    }

void fov_beam(fov_settings_type *settings, void *map, void *source,
              int source_x, int source_y, unsigned radius,
              fov_direction_type direction, float angle) {

    fov_private_data_type data;
    float start_slope, end_slope, a;

    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;

    if (angle <= 0.0f) {
        return;
    } else if (angle >= 360.0f) {
        _fov_circle(&data);
        return;
    }

    /* Calculate the angle as a percentage of 45 degrees, halved (for
     * each side of the centre of the beam). e.g. angle = 180.0f means
     * half the beam is 90.0 which is 2x45, so the result is 2.0.
     */
    a = angle/90.0f;

    BEAM_DIRECTION(FOV_EAST, ppn, pmn, ppy, mpy, pmy, mmy, mpn, mmn);
    BEAM_DIRECTION(FOV_WEST, mpn, mmn, pmy, mmy, ppy, mpy, ppn, pmn);
    BEAM_DIRECTION(FOV_NORTH, mpy, mmy, pmn, mmn, ppn, mpn, ppy, pmy);
    BEAM_DIRECTION(FOV_SOUTH, pmy, ppy, mpn, ppn, mmn, pmn, mmy, mpy);
    BEAM_DIRECTION_DIAG(FOV_NORTHEAST, pmn, mpy, ppn, mmy, ppy, mmn, pmy, mpn);
    BEAM_DIRECTION_DIAG(FOV_NORTHWEST, mmn, mmy, mpn, mpy, pmy, pmn, ppy, ppn);
    BEAM_DIRECTION_DIAG(FOV_SOUTHEAST, ppy, ppn, pmy, pmn, mpn, mpy, mmn, mmy);
    BEAM_DIRECTION_DIAG(FOV_SOUTHWEST, pmy, mpn, ppy, mmn, ppn, mmy, pmn, mpy);
}

#define BEAM_ANY_DIRECTION(offset, p1, p2, p3, p4, p5, p6, p7, p8)       \
angle_begin -= offset;                                               \
angle_end -= offset;                                                 \
start_slope = angle_begin;                                           \
end_slope = betweenf(angle_end, 0.0f, 1.0f);                         \
fov_octant_##p1(&data, 1, start_slope, end_slope, true, true);       \
\
if (angle_end - 1.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(2.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p2(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 2.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 2.0f, 0.0f, 1.0f);              \
fov_octant_##p3(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 3.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(4.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p4(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 4.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 4.0f, 0.0f, 1.0f);              \
fov_octant_##p5(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 5.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(6.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p6(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 6.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 6.0f, 0.0f, 1.0f);              \
fov_octant_##p7(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 7.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(8.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p8(&data, 1, start_slope, 1.0f, false, false);      \
}}}}}}}

#define BEAM_ANY_DIRECTION_DIAG(offset, p1, p2, p3, p4, p5, p6, p7, p8)  \
angle_begin -= offset;                                               \
angle_end -= offset;                                                 \
start_slope = betweenf(1.0 - angle_end, 0.0f, 1.0f);                 \
end_slope = 1.0 - angle_begin;                                       \
fov_octant_##p1(&data, 1, start_slope, end_slope, true, true);       \
\
if (angle_end - 1.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 1.0f, 0.0f, 1.0f);              \
fov_octant_##p2(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 2.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(3.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p3(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 3.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 3.0f, 0.0f, 1.0f);              \
fov_octant_##p4(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 4.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(5.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p5(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 5.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 5.0f, 0.0f, 1.0f);              \
fov_octant_##p6(&data, 1, 0.0f, end_slope, false, true);         \
\
if (angle_end - 6.0 > FLT_EPSILON) {                                 \
start_slope = betweenf(7.0f - angle_end, 0.0f, 1.0f);            \
fov_octant_##p7(&data, 1, start_slope, 1.0f, true, false);       \
\
if (angle_end - 7.0 > FLT_EPSILON) {                                 \
end_slope = betweenf(angle_end - 7.0f, 0.0f, 1.0f);              \
fov_octant_##p8(&data, 1, 0.0f, end_slope, false, false);        \
}}}}}}}

void fov_beam_any_angle(fov_settings_type *settings, void *map, void *source,
						int source_x, int source_y, unsigned radius,
						float dir_angle, float beam_angle) {
	
    fov_private_data_type data;
    float start_slope, end_slope, angle_begin, angle_end;
	
    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;
	
    if (beam_angle <= 0.0f) {
        return;
    } else if (beam_angle >= 360.0f) {
        _fov_circle(&data);
        return;
    }
	
    while (dir_angle >= 360.0f) {
		dir_angle -= 360.0f;
    }
	
    while (dir_angle < 0.0f) {
		dir_angle += 360.0f;
    }
	
    /* Calculate the angles as a percentage of 45 degrees */
    angle_begin = (dir_angle - 0.5*beam_angle) / 45.0f;
    angle_end = (dir_angle + 0.5*beam_angle) / 45.0f;
    if (angle_begin < 0.0f) {
        angle_begin += 8.0f;
        angle_end += 8.0f;
    }
	
    if (1.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION(0.0f, ppn, ppy, pmy, mpn, mmn, mmy, mpy, pmn);
    } else if (2.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(1.0f, ppy, pmy, mpn, mmn, mmy, mpy, pmn, ppn);
    } else if (3.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION(2.0f, pmy, mpn, mmn, mmy, mpy, pmn, ppn, ppy);
    } else if (4.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(3.0f, mpn, mmn, mmy, mpy, pmn, ppn, ppy, pmy);
    } else if (5.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION(4.0f, mmn, mmy, mpy, pmn, ppn, ppy, pmy, mpn);
    } else if (6.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(5.0f, mmy, mpy, pmn, ppn, ppy, pmy, mpn, mmn);
    } else if (7.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION(6.0f, mpy, pmn, ppn, ppy, pmy, mpn, mmn, mmy);
    } else if (8.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(7.0f, pmn, ppn, ppy, pmy, mpn, mmn, mmy, mpy);
    }
}
