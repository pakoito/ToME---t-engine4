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

/**
 * \mainpage Field of View Library
 *
 * \section about About
 *
 * This is a C library which implements a course-grained lighting
 * algorithm suitable for tile-based games such as roguelikes.
 *
 * \section copyright Copyright
 *
 * \verbinclude COPYING
 *
 * \section thanks Thanks
 *
 * Thanks to Bj&ouml;rn Bergstr&ouml;m
 * <bjorn.bergstrom@hyperisland.se> for the algorithm.
 *
 */

/**
 * \file fov.h
 * Field-of-view algorithm for dynamically casting light/shadow on a
 * low resolution 2D raster.
 */
#ifndef LIBFOV_HEADER
#define LIBFOV_HEADER

#include <stdbool.h>
#include <stddef.h>

/* Floating point espsilon to guarantee smooth floating point transitions and behavior in an integer grid.
 * There were no, and are no, floating point precision guarantees for maps greater than 1024x1024.  Use double precision if desired.
 * Nevertheless, map sizes greater than 10000x10000 should still behave reasonably.
 */
#define GRID_EPSILON 1.0e-5f

#ifdef __cplusplus
extern "C" {
#endif

/** Eight-way directions. */
/* Note: this has pretty much been deprecated */
typedef enum {
    FOV_EAST = 0,
    FOV_NORTHEAST,
    FOV_NORTH,
    FOV_NORTHWEST,
    FOV_WEST,
    FOV_SOUTHWEST,
    FOV_SOUTH,
    FOV_SOUTHEAST
} fov_direction_type;

/** The opposite direction to that given. */
/* Note: this has pretty much been deprecated */
#define fov_direction_opposite(direction) ((fov_direction_type)(((direction)+4)&0x7))

/** Values for the shape setting.          Distance                       Y (given x, radius r)   Square distance check   */
typedef enum {
    FOV_SHAPE_CIRCLE_ROUND,             /* floor(sqrt(x^2 + y^2) + 0.5)   sqrt(r^2 + r - x^2)     x^2 + y^2 <= r^2 + r    */
    FOV_SHAPE_CIRCLE_FLOOR,             /* floor(sqrt(x^2 + y^2))         sqrt(r^2 + 2*r - x^2)   x^2 + y^2 <= r^2 + 2*r  */
    FOV_SHAPE_CIRCLE_CEIL,              /* ceil(sqrt(x^2 + y^2))          sqrt(r^2 - x^2)         x^2 + y^2 <= r^2        */
    FOV_SHAPE_CIRCLE_PLUS1,             /* floor(d + 1 - 1.0/d)           sqrt(r^2 + 1 - x^2)     x^2 + y^2 <= r^2 + 1    */
    FOV_SHAPE_OCTAGON,                  /* max(x, y) + min(x, y)/2        2*(r - x) + 1                                   */
    FOV_SHAPE_DIAMOND,                  /* x + y                          r - x                                           */
    FOV_SHAPE_SQUARE,                   /* max(x, y)                      r                                               */
    FOV_SHAPE_HEX
} fov_shape_type;

typedef enum {
    FOV_ALGO_RECURSIVE_SHADOW,  /* Recursive shadowcasting (standard algorithm) */
    FOV_ALGO_LARGE_ASS,         /* Large Actor recurSive Shadowcasting */
    /*FOV_ALGO_SAVVY,*/         /* Symmetric And Variable permissiveness */
    /*FOV_ALGO_THE_LAST*/       /* Tiger_eye's Heteromorphic Efficient Large Actor Symmetric Targeting */
} fov_algo_type;

/* FOV_BUFFER_SIZE must be a power of two.  Could probably get by with 1024,
   but certainly not with 512.  2048 is actually exceedingly conservative.
*/
#define FOV_BUFFER_SIZE 2048
typedef struct {
    int index;
    int prev_len;
    float buffer[FOV_BUFFER_SIZE];
} fov_buffer_type;

typedef struct {
    /** Opacity test callback. */
    /*@null@*/ bool (*opaque)(void *map, int x, int y);

    /** Lighting callback to set lighting on a map tile. */
    /*@null@*/ void (*apply)(void *map, int x, int y, int dx, int dy, int radius, void *src);

    /** A measure of how much an opaque tile blocks a tile.  0.5 for square, 0 for diamond shape.  Shapes extend to the edge of the tile. */
    float permissiveness;

    /** A measure of the size of the source actor.  0 for smallest, 0.5 for full-width diamond.  Not applicable to all algorithms. */
    float actor_vision_size;

    /** Algorithm setting. */
    fov_algo_type algorithm;

    /** Shape setting. */
    fov_shape_type shape;

    /** Data buffer */
    fov_buffer_type *buffer_data;

    /** \endcond */
} fov_settings_type;

/** struct of calculated data for field of vision lines */
typedef struct {
    /** x from which the line originates */
    int source_x;

    /** y from which the line originates */
    int source_y;

    /** Parametrization variable used to count the "steps" of the line */
    int t;

    /** Parametrization value of t for where line is blocked, if applicable */
    int block_t;

    /** Parametrization value of t for where line reaches destination tile */
    int dest_t;

    /** Position from within the tile that the line originates */
    float start_x;

    /** Position from within the tile that the line originates */
    float start_y;

    /** Size of single step in x direction, so for t'th step, delta_x = t*step_x */
    float step_x;

    /** Size of single step in y direction, so for t'th step, delta_y = t*step_y */
    float step_y;

    /** Epsilon used to round toward or away from cardinal directions based on adjacent obstructed grids */
    float eps_x;

    /** Epsilon used to round toward or away from cardinal directions based on adjacent obstructed grids */
    float eps_y;

    /** Whether or not the line is blocked */
    bool is_blocked;

    /** Whether the line should begin at the destination (and continue away from the source) */
    bool start_at_end;
} fov_line_data;

/** struct of calculated data for field of vision lines */
typedef struct {
    /** Parametrization variable used to count the "steps" of the line */
    int t;

    /** Parametrization value of t for where line is blocked, if applicable */
    int block_t;

    /** Parametrization value of t for where line reaches destination tile */
    int dest_t;

    /** "real" x from which the line originates */
    float source_x;

    /** "real" y from which the line originates */
    float source_y;

    /** Size of single step in x direction, so for t'th step, delta_x = t*step_x */
    float step_x;

    /** Size of single step in y direction, so for t'th step, delta_y = t*step_y */
    float step_y;

    /** Epsilon used to round toward the correct chirality or based on adjacent obstructed grids */
    float eps_x;

    /** Epsilon used to round toward the correct chirality or based on adjacent obstructed grids */
    float eps_y;

    /** Whether or not the line is blocked */
    bool is_blocked;

    /** Whether the line should begin at the destination (and continue away from the source) */
    bool start_at_end;
} hex_fov_line_data;

/* set global parameters */
void fov_set_permissiveness(float value);
void fov_set_actor_vision_size(float value);
void fov_set_algorithm(fov_algo_type value);
void fov_set_vision_shape(fov_shape_type value);

/* get global parameters */
float fov_get_permissiveness();
float fov_get_actor_vision_size();
fov_algo_type fov_get_algorithm();
fov_shape_type fov_get_vision_shape();

/**
 * Set all the default options. You must call this option when you
 * create a new settings data structure.
 *
 * These settings are the defaults used:
 *
 * - shape: FOV_SHAPE_CIRCLE_PRECALCULATE
 *
 * Callbacks still need to be set up after calling this function.
 *
 * \param settings Pointer to data structure containing settings.
 */
void fov_settings_init(fov_settings_type *settings);

/**
 * Set the shape of the field of view.
 *
 * \param settings Pointer to data structure containing settings.
 * \param value One of the following values, where R is the radius:
 *
 * - FOV_SHAPE_CIRCLE_PRECALCULATE \b (default): Limit the FOV to a
 * circle with radius R by precalculating, which consumes more memory
 * at the rate of 4*(R+2) bytes per R used in calls to fov_circle.
 * Each radius is only calculated once so that it can be used again.
 * Use fov_free() to free this precalculated data's memory.
 *
 * - FOV_SHAPE_CIRCLE: Limit the FOV to a circle with radius R by
 * calculating on-the-fly.
 *
 * - FOV_SHAPE_OCTOGON: Limit the FOV to an octogon with maximum radius R.
 *
 * - FOV_SHAPE_SQUARE: Limit the FOV to an R*R square.
 */
/* void fov_settings_set_shape(fov_settings_type *settings, fov_shape_type value); */

/**
 * Set the function used to test whether a map tile is opaque.
 *
 * \param settings Pointer to data structure containing settings.
 * \param f The function called to test whether a map tile is opaque.
 */
void fov_settings_set_opacity_test_function(fov_settings_type *settings, bool (*f)(void *map, int x, int y));

/**
 * Set the function used to apply lighting to a map tile.
 *
 * \param settings Pointer to data structure containing settings.
 * \param f The function called to apply lighting to a map tile.
 */
void fov_settings_set_apply_lighting_function(fov_settings_type *settings, void (*f)(void *map, int x, int y, int dx, int dy, int radius, void *src));

/**
 * Calculate a full circle field of view from a source at (x,y).
 *
 * \param settings Pointer to data structure containing settings.
 * \param map Pointer to map data structure to be passed to callbacks.
 * \param source Pointer to data structure holding source of light.
 * \param source_x x-axis coordinate from which to start.
 * \param source_y y-axis coordinate from which to start.
 * \param radius Euclidean distance from (x,y) after which to stop.
 */
void fov_circle(fov_settings_type *settings, void *map, void *source,
                int source_x, int source_y, int radius
);

/**
 * Calculate a field of view from source at (x,y), pointing
 * in the given direction and with the given angle. The larger
 * the angle, the wider, "less focused" the beam. Each side of the
 * line pointing in the direction from the source will be half the
 * angle given such that the angle specified will be represented on
 * the raster.
 *
 * \param settings Pointer to data structure containing settings.
 * \param map Pointer to map data structure to be passed to callbacks.
 * \param source Pointer to data structure holding source of light.
 * \param source_x x-axis coordinate from which to start.
 * \param source_y y-axis coordinate from which to start.
 * \param radius Euclidean distance from (x,y) after which to stop.
 * \param direction One of eight directions the beam of light can point.
 * \param angle The angle at the base of the beam of light, in degrees.
 */
void fov_beam(fov_settings_type *settings, void *map, void *source,
              int source_x, int source_y, int radius,
              fov_direction_type direction, float angle
);

/**
 * Calculate a field of view from source at (x,y), pointing
 * in the given direction (in dx, dy) and with the given angle. The larger
 * the angle, the wider, "less focused" the beam. Each side of the
 * line pointing in the direction from the source will be half the
 * angle given such that the angle specified will be represented on
 * the raster.
 *
 * \param settings Pointer to data structure containing settings.
 * \param map Pointer to map data structure to be passed to callbacks.
 * \param source Pointer to data structure holding source of light.
 * \param source_x x-axis coordinate from which to start.
 * \param source_y y-axis coordinate from which to start.
 * \param radius Euclidean distance from (x,y) after which to stop.
 * \param dx Beam direction, delta x
 * \param dy Beam direction, delta y
 * \param beam_angle The angle at the base of the beam of light, in degrees.
 */
void fov_beam_any_angle(fov_settings_type *settings, void *map, void *source,
                        int source_x, int source_y, int radius, int sx, int sy,
                        float dx, float dy, float beam_angle
);

/**
 * Calculate a line based on field of view (or whatever the "opaque" function)
 * from source to destination (x, y).  This will avoid opaque tiles if possible.
 * If an unobstructed line to destination tile isn't found, then default to a
 * bresenham line.
 *
 * \param settings Pointer to data structure containing settings.
 * \param map Pointer to map data structure to be passed to callbacks.
 * \param source Pointer to data structure holding source of light.
 * \param line Pointer to data structure to store line information.
 * \param source_x x-axis coordinate from which to start.
 * \param source_y y-axis coordinate from which to start.
 * \param dest_x x-axis coordinate from which to end.
 * \param dest_y y-axis coordinate from which to end.
 * \param start_at_end if true, the line will begin at the destination (x, y) and continue away from source (x, y)
 */
void fov_create_los_line(fov_settings_type *settings, void *map, void *source,
                         fov_line_data *line,
                         int source_x, int source_y,
                         int dest_x, int dest_y,
                         bool start_at_end
);

void hex_fov_create_los_line(fov_settings_type *settings, void *map, void *source,
                         hex_fov_line_data *line,
                         int source_x, int source_y,
                         int dest_x, int dest_y,
                         bool start_at_end
);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif

