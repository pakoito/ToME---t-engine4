/*
 * Copyright (C) 2006-2007, Greg McIntyre. All rights reserved. See the file
 * named COPYING in the distribution for more details.
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
#define GRID_EPSILON 4.0e-6f

#ifdef __cplusplus
extern "C" {
#endif

/** Eight-way directions. */
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

/* The following aren't implemented and, hence, aren't used. If the the original library implements it later, we may want to copy it */
/** Values for the corner peek setting. */
/*
typedef enum {
    FOV_CORNER_NOPEEK,
    FOV_CORNER_PEEK
} fov_corner_peek_type;
*/
/** Values for the opaque apply setting. */
/*
typedef enum {
    FOV_OPAQUE_APPLY,
    FOV_OPAQUE_NOAPPLY
} fov_opaque_apply_type;
*/

/** @cond INTERNAL */
typedef /*@null@*/ unsigned *height_array_t;
/** @endcond */

typedef struct {
    /** Opacity test callback. */
    /*@null@*/ bool (*opaque)(void *map, int x, int y);

    /** Lighting callback to set lighting on a map tile. */
    /*@null@*/ void (*apply)(void *map, int x, int y, int dx, int dy, int radius, void *src);

    /** Shape setting. */
    fov_shape_type shape;

    /** Whether to peek around corners. */
    /* fov_corner_peek_type corner_peek; */

    /** Whether to call apply on opaque tiles. */
    /* fov_opaque_apply_type opaque_apply; */

    /** \cond INTERNAL */

    /** Pre-calculated data. \internal */
    /*@null@*/ height_array_t *heights;

    /** Size of pre-calculated data. \internal */
    unsigned numheights;

    /** A measure of how much an opaque tile blocks a tile.  0 for square, 0.5 for diamond shape.  Shapes extend to the edge of the tile. */
    float permissiveness;

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

    /** Size of single step in x direction, so for t'th step, delta_x = t*step_x */
    float step_x;

    /** Size of single step in y direction, so for t'th step, delta_y = t*step_y */
    float step_y;

    /** Epsilon used to round toward or away from cardinal directions based on adjacent obstructed grids */
    float eps;

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

/** The opposite direction to that given. */
#define fov_direction_opposite(direction) ((fov_direction_type)(((direction)+4)&0x7))

/**
 * Set all the default options. You must call this option when you
 * create a new settings data structure.
 *
 * These settings are the defaults used:
 *
 * - shape: FOV_SHAPE_CIRCLE_PRECALCULATE
 * - corner_peek: FOV_CORNER_NOPEEK
 * - opaque_apply: FOV_OPAQUE_APPLY
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
void fov_settings_set_shape(fov_settings_type *settings, fov_shape_type value);

/**
 * <em>NOT YET IMPLEMENTED</em>.
 *
 * Set whether sources will peek around corners.
 *
 * \param settings Pointer to data structure containing settings.
 * \param value One of the following values:
 *
 * - FOV_CORNER_PEEK \b (default): Renders:
\verbatim
  ........
  ........
  ........
  ..@#
  ...#
\endverbatim
 * - FOV_CORNER_NOPEEK: Renders:
\verbatim
  ......
  .....
  ....
  ..@#
  ...#
\endverbatim
 */
/* void fov_settings_set_corner_peek(fov_settings_type *settings, fov_corner_peek_type value); */

/**
 * Whether to call the apply callback on opaque tiles.
 *
 * \param settings Pointer to data structure containing settings.
 * \param value One of the following values:
 *
 * - FOV_OPAQUE_APPLY \b (default): Call apply callback on opaque tiles.
 * - FOV_OPAQUE_NOAPPLY: Do not call the apply callback on opaque tiles.
 */
/* void fov_settings_set_opaque_apply(fov_settings_type *settings, fov_opaque_apply_type value); */

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
 * Free any memory that may have been cached in the settings
 * structure.
 *
 * \param settings Pointer to data structure containing settings.
 */
void fov_settings_free(fov_settings_type *settings);

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
                int source_x, int source_y, unsigned radius
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
              int source_x, int source_y, unsigned radius,
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
                        int source_x, int source_y, unsigned radius, int sx, int sy,
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

