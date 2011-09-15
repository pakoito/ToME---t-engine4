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

/* radians/degrees conversions */
#define DtoR 1.74532925199432957692e-02
#define RtoD 57.2957795130823208768

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
    settings->shape = FOV_SHAPE_CIRCLE_ROUND;
    settings->corner_peek = FOV_CORNER_NOPEEK;
    settings->opaque_apply = FOV_OPAQUE_APPLY;
    settings->opaque = NULL;
    settings->apply = NULL;
    settings->heights = NULL;
    settings->numheights = 0;
    settings->permissiveness = 0.0f;
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
            result[i] = (unsigned)sqrtf((float)(maxdist*maxdist + maxdist - i*i));
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
        float start_slope_next, end_slope_next;                                                 \
        fov_settings_type *settings = data->settings;                                           \
                                                                                                \
        if (start_slope - end_slope > 5.0f*SLOPE_EPSILON) {                                     \
            return;                                                                             \
        }                                                                                       \
                                                                                                \
        if (dx == 0) {                                                                          \
            fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope, apply_edge, apply_diag); \
            return;                                                                             \
        } else if ((unsigned)dx > data->radius) {                                               \
            return;                                                                             \
        }                                                                                       \
                                                                                                \
        dy0 = (int)(0.5f + (float)dx*start_slope + GRID_EPSILON);                               \
        dy1 = (int)(0.5f + (float)dx*end_slope - GRID_EPSILON);                                 \
                                                                                                \
        rx = data->source_##rx signx dx;                                                        \
                                                                                                \
        /* we need to check if the previous spot is blocked */                                  \
        if (dy0 > 0) {                                                                          \
            ry = data->source_##ry signy (dy0-1);                                               \
            if (settings->opaque(data->map, x, y)) {                                            \
                prev_blocked = 1;                                                               \
            } else {                                                                            \
                prev_blocked = 0;                                                               \
            }                                                                                   \
        }                                                                                       \
                                                                                                \
        switch (settings->shape) {                                                              \
        case FOV_SHAPE_CIRCLE_ROUND :                                                           \
            h = height(settings, dx, data->radius);                                             \
            break;                                                                              \
        case FOV_SHAPE_CIRCLE_FLOOR :                                                           \
            h = (unsigned)(sqrt((data->radius)*(data->radius) + 2*data->radius - dx*dx));       \
            break;                                                                              \
        case FOV_SHAPE_CIRCLE_CEIL :                                                            \
            h = (unsigned)(sqrt((data->radius)*(data->radius) - dx*dx));                        \
            break;                                                                              \
        case FOV_SHAPE_CIRCLE_PLUS1 :                                                           \
            h = (unsigned)(sqrt((data->radius)*(data->radius) + 1 - dx*dx));                    \
            break;                                                                              \
        case FOV_SHAPE_OCTAGON:                                                                 \
            h = 2u*(data->radius - (unsigned)dx) + 1u;                                          \
            break;                                                                              \
        case FOV_SHAPE_DIAMOND :                                                                \
            h = data->radius - (unsigned)dx;                                                    \
            break;                                                                              \
        case FOV_SHAPE_SQUARE :                                                                 \
            h = data->radius;                                                                   \
            break;                                                                              \
        default :                                                                               \
            h = (unsigned)(sqrt((data->radius)*(data->radius) + data->radius - dx*dx));         \
            break;                                                                              \
        };                                                                                      \
        if ((unsigned)dy1 > h) {                                                                \
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
                if (settings->opaque_apply == FOV_OPAQUE_APPLY && (apply_edge || dy > 0) && (apply_diag || dy != dx)) {    \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y, data->radius, data->source);  \
                }                                                                               \
                if (prev_blocked == 0) {                                                        \
                    end_slope_next = fov_slope((float)dx + 0.5f - settings->permissiveness + SLOPE_EPSILON, (float)dy - 0.5f) - GRID_EPSILON;   \
                    if (end_slope_next > end_slope) {                                           \
                        end_slope_next = end_slope;                                             \
                    }                                                                           \
                    if (dy != dy0) {                                                            \
                        fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope_next, apply_edge, apply_diag);          \
                    }                                                                           \
                }                                                                               \
                prev_blocked = 1;                                                               \
            } else {                                                                            \
                if (prev_blocked == 1) {                                                        \
                    start_slope_next = fov_slope((float)dx - 0.5f + settings->permissiveness - SLOPE_EPSILON, (float)dy - 0.5f) + GRID_EPSILON; \
                    if (start_slope_next > start_slope) {                                       \
                        start_slope = start_slope_next;                                         \
                        if (start_slope - end_slope > 5.0f*SLOPE_EPSILON) {                     \
                            return;                                                             \
                        }                                                                       \
                    }                                                                           \
                }                                                                               \
                if ((apply_edge || dy > 0) && (apply_diag || dy != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y, data->radius, data->source);  \
                }                                                                               \
                prev_blocked = 0;                                                               \
            }                                                                                   \
        }                                                                                       \
                                                                                                \
        if (prev_blocked == 0) {                                                                \
            /* We need to check if the next spot is blocked and change end_slope accordingly */ \
            if (dx != dy1) {                                                                    \
                ry = data->source_##ry signy (dy1+1);                                           \
                if (settings->opaque(data->map, x, y)) {                                        \
                    end_slope_next = fov_slope((float)dx + 0.5f - settings->permissiveness + SLOPE_EPSILON, (float)dy1 + 0.5f) - GRID_EPSILON;  \
                    if (end_slope_next < end_slope) {                                           \
                        end_slope = end_slope_next;                                             \
                    }                                                                           \
                }                                                                               \
            }                                                                                   \
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
        if (a - 2.0f > 2.0f * FLT_EPSILON) { /* a > 2.0f */             \
            end_slope = betweenf(a - 2.0f, 0.0f, 1.0f);                 \
            fov_octant_##p5(&data, 1, 0.0f, end_slope, false, true);    \
            fov_octant_##p6(&data, 1, 0.0f, end_slope, false, true);    \
        }                                                               \
        if (a - 3.0f > 3.0 * FLT_EPSILON) { /* a > 3.0f */              \
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
        if (a - 2.0f > 2.0f * FLT_EPSILON) { /* a > 2.0f */             \
            start_slope = betweenf(3.0f - a, 0.0f, 1.0f);               \
            fov_octant_##p5(&data, 1, start_slope, 1.0f, true, false);  \
            fov_octant_##p6(&data, 1, start_slope, 1.0f, true, false);  \
        }                                                               \
        if (a - 3.0f > 3.0f * FLT_EPSILON) { /* a > 3.0f */             \
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
    if (angle_end - 1.0f > FLT_EPSILON) {                                \
        start_slope = betweenf(2.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p2(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 2.0f, 0.0f, 1.0f);              \
        fov_octant_##p3(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(4.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p4(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 4.0f, 0.0f, 1.0f);              \
        fov_octant_##p5(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(6.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p6(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 6.0f, 0.0f, 1.0f);              \
        fov_octant_##p7(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(8.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p8(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 8.0f, 0.0f, 1.0f);              \
        start_slope = betweenf(angle_end - 8.0f, 0.0f, 1.0f);            \
        fov_octant_##p1(&data, 1, 0.0f, end_slope, false, false);        \
    }}}}}}}}

#define BEAM_ANY_DIRECTION_DIAG(offset, p1, p2, p3, p4, p5, p6, p7, p8)  \
    angle_begin -= offset;                                               \
    angle_end -= offset;                                                 \
    start_slope = betweenf(1.0f - angle_end, 0.0f, 1.0f);                \
    end_slope = 1.0f - angle_begin;                                      \
    fov_octant_##p1(&data, 1, start_slope, end_slope, true, true);       \
                                                                         \
    if (angle_end - 1.0f > FLT_EPSILON) {                                \
        end_slope = betweenf(angle_end - 1.0f, 0.0f, 1.0f);              \
        fov_octant_##p2(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(3.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p3(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 3.0f, 0.0f, 1.0f);              \
        fov_octant_##p4(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(5.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p5(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 5.0f, 0.0f, 1.0f);              \
        fov_octant_##p6(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(7.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p7(&data, 1, start_slope, 1.0f, true, false);       \
                                                                         \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                         \
        end_slope = betweenf(angle_end - 7.0f, 0.0f, 1.0f);              \
        fov_octant_##p8(&data, 1, 0.0f, end_slope, false, true);         \
                                                                         \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                         \
        start_slope = betweenf(9.0f - angle_end, 0.0f, 1.0f);            \
        fov_octant_##p1(&data, 1, start_slope, 1.0f, false, false);      \
}}}}}}}}

void fov_beam_any_angle(fov_settings_type *settings, void *map, void *source,
                        int source_x, int source_y, unsigned radius,
                        float dx, float dy, float beam_angle) {

    /* Note: angle_begin and angle_end are misnomers, since FoV calculation uses slopes, not angles.
     * We previously used a tan(x) ~ 4/pi*x approximation * for x in range (0, pi/4) radians, or 45 degrees.
     * We no longer use this approximation.  Angles and slopes are calculated precisely,
     * so this function can be used for numerically precise purposes if desired.
     */

    fov_private_data_type data;
    float start_slope, end_slope, angle_begin, angle_end, x_start, y_start, x_end, y_end;

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

    beam_angle = 0.5f * DtoR * beam_angle;
    x_start = cos(beam_angle)*dx + sin(beam_angle)*dy;
    y_start = cos(beam_angle)*dy - sin(beam_angle)*dx;
    x_end   = cos(beam_angle)*dx - sin(beam_angle)*dy;
    y_end   = cos(beam_angle)*dy + sin(beam_angle)*dx;

    if (y_start > 0.0f) {
        if (x_start > 0.0f) {                      /* octant 1 */               /* octant 2 */
            angle_begin = ( y_start <  x_start) ? (y_start / x_start)        : (2.0f - x_start / y_start);
        }
        else {                                     /* octant 3 */               /* octant 4 */
            angle_begin = (-x_start <  y_start) ? (2.0f - x_start / y_start) : (4.0f + y_start / x_start);
        }
    } else {
        if (x_start < 0.0f) {                      /* octant 5 */               /* octant 6 */
            angle_begin = (-y_start < -x_start) ? (4.0f + y_start / x_start) : (6.0f - x_start / y_start);
        }
        else {                                     /* octant 7 */               /* octant 8 */
            angle_begin = ( x_start < -y_start) ? (6.0f - x_start / y_start) : (8.0f + y_start / x_start);
        }
    }

    if (y_end > 0.0f) {
        if (x_end > 0.0f) {                  /* octant 1 */           /* octant 2 */
            angle_end = ( y_end <  x_end) ? (y_end / x_end)        : (2.0f - x_end / y_end);
        }
        else {                               /* octant 3 */           /* octant 4 */
            angle_end = (-x_end <  y_end) ? (2.0f - x_end / y_end) : (4.0f + y_end / x_end);
        }
    } else {
        if (x_end < 0.0f) {                  /* octant 5 */           /* octant 6 */
            angle_end = (-y_end < -x_end) ? (4.0f + y_end / x_end) : (6.0f - x_end / y_end);
        }
        else {                               /* octant 7 */           /* octant 8 */
            angle_end = ( x_end < -y_end) ? (6.0f - x_end / y_end) : (8.0f + y_end / x_end);
        }
    }

    if (angle_end < angle_begin) {
        angle_end += 8.0f;
    }

    if (1.0f - angle_begin > FLT_EPSILON) {
        BEAM_ANY_DIRECTION(0.0f, ppn, ppy, pmy, mpn, mmn, mmy, mpy, pmn);
    } else if (2.0f - angle_begin > 2.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(1.0f, ppy, pmy, mpn, mmn, mmy, mpy, pmn, ppn);
    } else if (3.0f - angle_begin > 3.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION(2.0f, pmy, mpn, mmn, mmy, mpy, pmn, ppn, ppy);
    } else if (4.0f - angle_begin > 4.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(3.0f, mpn, mmn, mmy, mpy, pmn, ppn, ppy, pmy);
    } else if (5.0f - angle_begin > 5.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION(4.0f, mmn, mmy, mpy, pmn, ppn, ppy, pmy, mpn);
    } else if (6.0f - angle_begin > 6.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(5.0f, mmy, mpy, pmn, ppn, ppy, pmy, mpn, mmn);
    } else if (7.0f - angle_begin > 7.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION(6.0f, mpy, pmn, ppn, ppy, pmy, mpn, mmn, mmy);
    } else if (8.0f - angle_begin > 8.0f * FLT_EPSILON) {
        BEAM_ANY_DIRECTION_DIAG(7.0f, pmn, ppn, ppy, pmy, mpn, mmn, mmy, mpy);
    }
}

void fov_create_los_line(fov_settings_type *settings, void *map, void *source, fov_line_data *line,
                         int source_x, int source_y,
                         int dest_x, int dest_y,
                         bool start_at_end) {

    line->source_x = source_x;
    line->source_y = source_y;
    line->dest_x = dest_x;
    line->dest_y = dest_y;
    line->t = 0;
    line->is_blocked = false;

    if (line->source_x == line->dest_x)
    {
        line->dest_t = abs(line->dest_y - line->source_y);

        if (line->source_y == line->dest_y) {
            return;
        }
        /* iterate through all y */
        int dy = (line->dest_y < line->source_y) ? -1 : 1;
        int y = line->source_y;
        do {
            y += dy;
            if (settings->opaque(map, line->source_x, y)) {
                line->is_blocked = true;
                line->block_t = dy*(y - line->source_y);
                break;
            }
        } while (y != line->dest_y);

        line->step_x = 0.0f;
        line->step_y = (float)dy;
        if (start_at_end) {
            line->t = line->dest_t;
        }
    }
    else if (line->source_y == line->dest_y)
    {
        line->dest_t = abs(line->dest_x - line->source_x);

        /* iterate through all x */
        int dx = (line->dest_x < line->source_x) ? -1 : 1;
        int x = line->source_x;
        do {
            x += dx;
            if (settings->opaque(map, x, line->source_y)) {
                line->is_blocked = true;
                line->block_t = dx*(x - line->source_x);
                break;
            }
        } while (x != line->dest_x);

        line->step_x = (float)dx;
        line->step_y = 0.0f;
        if (start_at_end) {
            line->t = line->dest_t;
        }
    }
    else
    {
        bool blocked_at_end = false;

        /* hurray for a plethora of short but similar variable names!  (yeah, I'm sorry... I blame all the poorly written legacy physics code I've had to work with) */
        bool b0;                       /* true if [xy]0 is blocked */
        bool b1;                       /* true if [xy]1 is blocked */
        bool mb0;                      /* true if m[xy]0 is blocked */
        bool mb1;                      /* true if m[xy]1 is blocked */
        int sx = line->source_x;       /* source x */
        int sy = line->source_y;       /* source y */
        int tx = line->dest_x;         /* target x */
        int ty = line->dest_y;         /* target y */
        int dx = (tx < sx) ? -1 : 1;   /* sign of x.  Useful for taking abs(x_val) */
        int dy = (ty < sy) ? -1 : 1;   /* sign of y.  Useful for taking abs(y_val) */

        float gx = (float)dx;          /* sign of x, float.  Useful for taking fabs(x_val) */
        float gy = (float)dy;          /* sign of y, float   Useful for taking fabs(y_val) */
        float gabs = (float)(dx*dy);   /* used in place of fabs(slope_val) */
        float val;

        /* Note that multiplying by dx, dy, gx, gy, or gabs are sometimes used in place of abs and fabs */
        /* I don't mind having a little (x2) code duplication--it's much better than debugging large macros :) */
        if (dx*(tx - sx) > dy*(ty - sy))
        {
            line->dest_t = dx*(tx - sx);

            int x = 0;
            int y0, y1;                /* lowest/highest possible y based on inner/outer edge of tiles and lower/upper slopes */
            int my0, my1;              /* low/high y based on the middle of tiles */
            float slope = fov_slope((float)(tx - sx), (float)(ty - sy));
            float lower_slope = fov_slope((float)(tx - sx), (float)(ty - sy) - gy*0.5f);
            float upper_slope = fov_slope((float)(tx - sx), (float)(ty - sy) + gy*0.5f);

            /* include both source and dest x in loop, but don't include (source_x, source_y) or (target_x, target_y) */
            val = gx*0.5f*upper_slope + gx*GRID_EPSILON;
            y1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val); 
            if (y1 != 0 && gabs * upper_slope > 1.0f && settings->permissiveness < 0.301f && settings->opaque(map, sx, sy + y1)) {
                val = fov_slope(gx*(0.5f - settings->permissiveness + SLOPE_EPSILON), gy*0.5f) - gabs*GRID_EPSILON;
                if (gabs * val < gabs * upper_slope) {
                    upper_slope = val;
                }
            }

            while (sx + x != tx) {
                x += dx;
                b0 = false;
                b1 = false;
                mb0 = false;
                mb1 = false;

                /* Just in case floating point precision errors do try to show up (i.e., really long line or very unlucky),
                 * let us calculate values in the same manner as done for FoV to make the errors consistent */
                val = (float)x*lower_slope - gy*GRID_EPSILON;
                my0 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val -= gx*0.5f*lower_slope;
                y0  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                val = (float)x*upper_slope + gy*GRID_EPSILON;
                my1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val += gx*0.5f*upper_slope;
                y1  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                /* check if lower_slope is blocked */
                if (settings->opaque(map, sx + x, sy + my0)) {
                    b0 = true;
                    mb0 = true;
                    if(sx + x != tx || sy + my0 != ty) {
                        lower_slope = fov_slope((float)x - gx*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)my0 + gy*0.5f) + gabs*GRID_EPSILON;
                    }
                }
                else if (y0 != my0 && settings->opaque(map, sx + x, sy + y0)) {
                    val = fov_slope((float)x - gx*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)y0 + gy*0.5f) + gabs*GRID_EPSILON;
                    if (gabs * val > gabs * lower_slope) {
                        lower_slope = val;
                        b0 = true;
                    }
                }

                /* check if upper_slope is blocked */
                if (settings->opaque(map, sx + x, sy + my1)) {
                    b1 = true;
                    mb1 = true;
                    if(sx + x != tx || sy + my1 != ty) {
                        upper_slope = fov_slope((float)x + gx*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)my1 - gy*0.5f) - gabs*GRID_EPSILON;
                    }
                }
                else if (y1 != my1 && settings->opaque(map, sx + x, sy + y1)) {
                    val = fov_slope((float)x + gx*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)y1 - gy*0.5f) - gabs*GRID_EPSILON;
                    if (gabs * val < gabs * upper_slope) {
                        upper_slope = val;
                        b1 = true;
                    }
                }

                /* being "pinched" isn't blocked, because one can still look diagonally */
                if (gabs * (lower_slope - upper_slope) > 5.0f * SLOPE_EPSILON ||
                        gy*((float)(sy - ty) + (float)(tx - sx)*lower_slope - gy*0.5f) > -GRID_EPSILON ||
                        gy*((float)(sy - ty) + (float)(tx - sx)*upper_slope + gy*0.5f) <  GRID_EPSILON)
                {
                    line->is_blocked = true;
                    line->block_t = dx*x;
                    break;
                }
                else if (mb0 && b1 || b0 && mb1) {
                    line->is_blocked = true;
                    line->block_t = dx*x;
                    if (sx + x == tx) {
                        blocked_at_end = true;
                    }
                    break;
                }
            }

            /* still try to target a blocked destination tile if it can be reached */
            line->step_x = gx;
            if (line->is_blocked && !blocked_at_end) {
                line->step_y = gx * slope;
            }
            else if (gabs * lower_slope > gabs * slope && 0.5f - fabs((float)(sy - ty) + (float)x*lower_slope) > GRID_EPSILON)  {
                line->step_y = gx * lower_slope;
            }
            else if (gabs * upper_slope < gabs * slope && 0.5f - fabs((float)(sy - ty) + (float)x*upper_slope) > GRID_EPSILON)  {
                line->step_y = gx * upper_slope;
            }
            else {
                line->step_y = gx * slope;
            }
            if (start_at_end) {
                line->t = dx*(tx - sx);
            }
        }
        else
        {
            line->dest_t = dy*(ty - sy);

            int y = 0;
            int x0, x1;                /* lowest/highest possible y based on inner/outer edge of tiles and lower/upper slopes */
            int mx0, mx1;              /* low/high y based on the middle of tiles */
            float slope = fov_slope((float)(ty - sy), (float)(tx - sx));
            float lower_slope = fov_slope((float)(ty - sy), (float)(tx - sx) - gx*0.5f);
            float upper_slope = fov_slope((float)(ty - sy), (float)(tx - sx) + gx*0.5f);

            /* include both source and dest y in loop, but don't include (source_x, source_y) or (target_x, target_y) */
            val = gy*0.5f*upper_slope + gy*GRID_EPSILON;
            x1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val); 
            if (x1 != 0 && gabs * upper_slope > 1.0f && settings->permissiveness < 0.301f && settings->opaque(map, sx + x1, sy)) {
                val = fov_slope(gy*(0.5f - settings->permissiveness + SLOPE_EPSILON), gx*0.5f) - gabs*GRID_EPSILON;
                if (gabs * val < gabs * upper_slope) {
                    upper_slope = val;
                }
            }

            while (sy + y != ty) {
                y += dy;
                b0 = false;
                b1 = false;
                mb0 = false;
                mb1 = false;

                /* Just in case floating point precision errors do try to show up (i.e., really long line or very unlucky),
                 * let us calculate values in the same manner as done for FoV to make the errors consistent */
                val = (float)y*lower_slope - gx*GRID_EPSILON;
                mx0 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val -= gy*0.5f*lower_slope;
                x0  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                val = (float)y*upper_slope + gx*GRID_EPSILON;
                mx1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val += gy*0.5f*upper_slope;
                x1  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                /* check if lower_slope is blocked */
                if (settings->opaque(map, sx + mx0, sy + y)) {
                    b0 = true;
                    mb0 = true;
                    if(sy + y != ty || sx + mx0 != tx) {
                        lower_slope = fov_slope((float)y - gy*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)mx0 + gx*0.5f) + gabs*GRID_EPSILON;
                    }
                }
                else if (x0 != mx0 && settings->opaque(map, sx + x0, sy + y)) {
                    val = fov_slope((float)y - gy*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)x0 + gx*0.5f) + gabs*GRID_EPSILON;
                    if (gabs * val > gabs * lower_slope) {
                        lower_slope = val;
                        b0 = true;
                    }
                }

                /* check if upper_slope is blocked */
                if (settings->opaque(map, sx + mx1, sy + y)) {
                    b1 = true;
                    mb1 = true;
                    if(sy + y != ty || sx + mx1 != tx) {
                        upper_slope = fov_slope((float)y + gy*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)mx1 - gx*0.5f) - gabs*GRID_EPSILON;
                    }
                }
                else if (x1 != mx1 && settings->opaque(map, sx + x1, sy + y)) {
                    val = fov_slope((float)y + gy*(0.5f - settings->permissiveness + SLOPE_EPSILON), (float)x1 - gx*0.5f) - gabs*GRID_EPSILON;
                    if (gabs * val < gabs * upper_slope) {
                        upper_slope = val;
                        b1 = true;
                    }
                }

                /* being "pinched" isn't blocked, because one can still look diagonally */
                if (gabs * (lower_slope - upper_slope) > 5.0f * SLOPE_EPSILON ||
                        gx*((float)(sx - tx) + (float)(ty - sy)*lower_slope - gx*0.5f) > -GRID_EPSILON ||
                        gx*((float)(sx - tx) + (float)(ty - sy)*upper_slope + gx*0.5f) <  GRID_EPSILON)
                {
                    line->is_blocked = true;
                    line->block_t = dy*y;
                    break;
                }
                else if (mb0 && b1 || b0 && mb1) {
                    line->is_blocked = true;
                    line->block_t = dy*y;
                    if (sy + y == ty) {
                        blocked_at_end = true;
                    }
                    break;
                }
            }

            /* still try to target a blocked destination tile if it can be reached */
            line->step_y = gy;
            if (line->is_blocked && !blocked_at_end) {
                line->step_x = gy * slope;
            }
            else if (gabs * lower_slope > gabs * slope && 0.5f - fabs((float)(sx - tx) + (float)y*lower_slope) > GRID_EPSILON)  {
                line->step_x = gy * lower_slope;
            }
            else if (gabs * upper_slope < gabs * slope && 0.5f - fabs((float)(sx - tx) + (float)y*upper_slope) > GRID_EPSILON)  {
                line->step_x = gy * upper_slope;
            }
            else {
                line->step_x = gy * slope;
            }
            if (start_at_end) {
                line->t = dy*(ty - sy);
            }
        }
    }

    if (start_at_end && line->is_blocked) {
        line->t = line->block_t;
    }
}

