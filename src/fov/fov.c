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

#define INV_SQRT_3 0.577350269189625764509
#define SQRT_3     1.73205080756887729353
#define SQRT_3_2   0.866025403784438646764
#define SQRT_3_4   0.433012701892219323382

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

/* Lookup table of heights (given r, x) for up to 32 radius for all fov shapes (except hex).
   We could, in principle, have a cache for radii up to 255 using char, but that would require 223 KB.
   32 seemed like a reasonable cutoff, and requires less than 4 KB (actually uses 3696 B).
   We may want to reconsider having tables for SQUARE, DIAMOND, and OCTAGON.
*/
static const char heights_tables[7][528] = {
/* FOV_SHAPE_CIRCLE_ROUND: sqrt(r^2 + r - x^2) */
    {
         1,
         2,  1,
         3,  2,  1,
         4,  4,  3,  2,
         5,  5,  4,  3,  2,
         6,  6,  5,  5,  4,  2,
         7,  7,  6,  6,  5,  4,  2,
         8,  8,  7,  7,  6,  6,  4,  2,
         9,  9,  9,  8,  8,  7,  6,  5,  3,
        10, 10, 10,  9,  9,  8,  7,  6,  5,  3,
        11, 11, 11, 10, 10,  9,  9,  8,  7,  5,  3,
        12, 12, 12, 11, 11, 10, 10,  9,  8,  7,  5,  3,
        13, 13, 13, 12, 12, 12, 11, 10, 10,  9,  7,  6,  3,
        14, 14, 14, 13, 13, 13, 12, 12, 11, 10,  9,  8,  6,  3,
        15, 15, 15, 14, 14, 14, 13, 13, 12, 11, 10,  9,  8,  6,  3,
        16, 16, 16, 16, 15, 15, 14, 14, 13, 13, 12, 11, 10,  8,  6,  4,
        17, 17, 17, 17, 16, 16, 16, 15, 15, 14, 13, 12, 11, 10,  9,  7,  4,
        18, 18, 18, 18, 17, 17, 17, 16, 16, 15, 14, 14, 13, 12, 10,  9,  7,  4,
        19, 19, 19, 19, 18, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 11,  9,  7,  4,
        20, 20, 20, 20, 19, 19, 19, 18, 18, 17, 17, 16, 15, 14, 13, 12, 11,  9,  7,  4,
        21, 21, 21, 21, 20, 20, 20, 19, 19, 19, 18, 17, 17, 16, 15, 14, 13, 11, 10,  7,  4,
        22, 22, 22, 22, 21, 21, 21, 21, 20, 20, 19, 19, 18, 17, 16, 15, 14, 13, 12, 10,  8,  4,
        23, 23, 23, 23, 22, 22, 22, 22, 21, 21, 20, 20, 19, 18, 18, 17, 16, 15, 13, 12, 10,  8,  4,
        24, 24, 24, 24, 23, 23, 23, 23, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 14, 12, 10,  8,  4,
        25, 25, 25, 25, 25, 24, 24, 24, 23, 23, 23, 22, 21, 21, 20, 19, 19, 18, 17, 15, 14, 12, 11,  8,  5,
        26, 26, 26, 26, 26, 25, 25, 25, 24, 24, 24, 23, 23, 22, 21, 21, 20, 19, 18, 17, 16, 14, 13, 11,  8,  5,
        27, 27, 27, 27, 27, 26, 26, 26, 25, 25, 25, 24, 24, 23, 23, 22, 21, 20, 19, 18, 17, 16, 15, 13, 11,  8,  5,
        28, 28, 28, 28, 28, 27, 27, 27, 27, 26, 26, 25, 25, 24, 24, 23, 22, 22, 21, 20, 19, 18, 16, 15, 13, 11,  9,  5,
        29, 29, 29, 29, 29, 28, 28, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 22, 21, 20, 19, 18, 17, 15, 13, 11,  9,  5,
        30, 30, 30, 30, 30, 29, 29, 29, 29, 28, 28, 28, 27, 27, 26, 25, 25, 24, 23, 23, 22, 21, 20, 18, 17, 15, 14, 12,  9,  5,
        31, 31, 31, 31, 31, 30, 30, 30, 30, 29, 29, 29, 28, 28, 27, 27, 26, 25, 25, 24, 23, 22, 21, 20, 19, 17, 16, 14, 12,  9,  5,
        32, 32, 32, 32, 32, 31, 31, 31, 31, 30, 30, 30, 29, 29, 28, 28, 27, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 16, 14, 12,  9,  5
    },
/* FOV_SHAPE_CIRCLE_FLOOR: sqrt(r^2 + 2*r - x^2) */
    {
         1,
         2,  2,
         3,  3,  2,
         4,  4,  3,  2,
         5,  5,  5,  4,  3,
         6,  6,  6,  5,  4,  3,
         7,  7,  7,  6,  6,  5,  3,
         8,  8,  8,  8,  7,  6,  5,  4,
         9,  9,  9,  9,  8,  7,  7,  5,  4,
        10, 10, 10, 10,  9,  9,  8,  7,  6,  4,
        11, 11, 11, 11, 10, 10,  9,  8,  7,  6,  4,
        12, 12, 12, 12, 11, 11, 10, 10,  9,  8,  6,  4,
        13, 13, 13, 13, 13, 12, 12, 11, 10,  9,  8,  7,  5,
        14, 14, 14, 14, 14, 13, 13, 12, 11, 11, 10,  8,  7,  5,
        15, 15, 15, 15, 15, 14, 14, 13, 13, 12, 11, 10,  9,  7,  5,
        16, 16, 16, 16, 16, 15, 15, 14, 14, 13, 12, 12, 10,  9,  7,  5,
        17, 17, 17, 17, 17, 16, 16, 16, 15, 14, 14, 13, 12, 11,  9,  8,  5,
        18, 18, 18, 18, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 11, 10,  8,  6,
        19, 19, 19, 19, 19, 19, 18, 18, 17, 17, 16, 15, 15, 14, 13, 11, 10,  8,  6,
        20, 20, 20, 20, 20, 20, 19, 19, 18, 18, 17, 17, 16, 15, 14, 13, 12, 10,  8,  6,
        21, 21, 21, 21, 21, 21, 20, 20, 20, 19, 19, 18, 17, 16, 16, 15, 13, 12, 11,  9,  6,
        22, 22, 22, 22, 22, 22, 21, 21, 21, 20, 20, 19, 18, 18, 17, 16, 15, 14, 12, 11,  9,  6,
        23, 23, 23, 23, 23, 23, 22, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 14, 13, 11,  9,  6,
        24, 24, 24, 24, 24, 24, 23, 23, 23, 22, 22, 21, 21, 20, 19, 19, 18, 17, 16, 14, 13, 11,  9,  6,
        25, 25, 25, 25, 25, 25, 25, 24, 24, 23, 23, 23, 22, 21, 21, 20, 19, 18, 17, 16, 15, 13, 12,  9,  7,
        26, 26, 26, 26, 26, 26, 26, 25, 25, 25, 24, 24, 23, 23, 22, 21, 20, 20, 19, 18, 16, 15, 14, 12, 10,  7,
        27, 27, 27, 27, 27, 27, 27, 26, 26, 26, 25, 25, 24, 24, 23, 22, 22, 21, 20, 19, 18, 17, 15, 14, 12, 10,  7,
        28, 28, 28, 28, 28, 28, 28, 27, 27, 27, 26, 26, 25, 25, 24, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 12, 10,  7,
        29, 29, 29, 29, 29, 29, 29, 28, 28, 28, 27, 27, 27, 26, 25, 25, 24, 23, 23, 22, 21, 20, 19, 17, 16, 14, 13, 10,  7,
        30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 28, 28, 28, 27, 27, 26, 25, 25, 24, 23, 22, 21, 20, 19, 18, 16, 15, 13, 10,  7,
        31, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 29, 29, 28, 28, 27, 27, 26, 25, 24, 24, 23, 22, 21, 19, 18, 17, 15, 13, 11,  7,
        32, 32, 32, 32, 32, 32, 32, 32, 31, 31, 31, 30, 30, 29, 29, 28, 28, 27, 26, 26, 25, 24, 23, 22, 21, 20, 18, 17, 15, 13, 11,  8
    },
/* FOV_SHAPE_CIRCLE_CEIL: sqrt(r^2 - x^2) */
    {
         0,
         1,  0,
         2,  2,  0,
         3,  3,  2,  0,
         4,  4,  4,  3,  0,
         5,  5,  5,  4,  3,  0,
         6,  6,  6,  5,  4,  3,  0,
         7,  7,  7,  6,  6,  5,  3,  0,
         8,  8,  8,  8,  7,  6,  5,  4,  0,
         9,  9,  9,  9,  8,  8,  7,  6,  4,  0,
        10, 10, 10, 10,  9,  9,  8,  7,  6,  4,  0,
        11, 11, 11, 11, 10, 10,  9,  8,  7,  6,  4,  0,
        12, 12, 12, 12, 12, 11, 10, 10,  9,  8,  6,  5,  0,
        13, 13, 13, 13, 13, 12, 12, 11, 10,  9,  8,  7,  5,  0,
        14, 14, 14, 14, 14, 13, 13, 12, 12, 11, 10,  9,  7,  5,  0,
        15, 15, 15, 15, 15, 14, 14, 13, 13, 12, 11, 10,  9,  7,  5,  0,
        16, 16, 16, 16, 16, 15, 15, 15, 14, 13, 12, 12, 10,  9,  8,  5,  0,
        17, 17, 17, 17, 17, 16, 16, 16, 15, 14, 14, 13, 12, 11,  9,  8,  5,  0,
        18, 18, 18, 18, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 11, 10,  8,  6,  0,
        19, 19, 19, 19, 19, 19, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 10,  8,  6,  0,
        20, 20, 20, 20, 20, 20, 19, 19, 18, 18, 17, 17, 16, 15, 14, 13, 12, 10,  8,  6,  0,
        21, 21, 21, 21, 21, 21, 20, 20, 20, 19, 19, 18, 17, 16, 16, 15, 13, 12, 11,  9,  6,  0,
        22, 22, 22, 22, 22, 22, 21, 21, 21, 20, 20, 19, 18, 18, 17, 16, 15, 14, 12, 11,  9,  6,  0,
        23, 23, 23, 23, 23, 23, 22, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 14, 13, 11,  9,  6,  0,
        24, 24, 24, 24, 24, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 13, 11,  9,  7,  0,
        25, 25, 25, 25, 25, 25, 25, 24, 24, 24, 23, 23, 22, 21, 21, 20, 19, 18, 17, 16, 15, 13, 12, 10,  7,  0,
        26, 26, 26, 26, 26, 26, 26, 25, 25, 25, 24, 24, 23, 23, 22, 21, 20, 20, 19, 18, 16, 15, 14, 12, 10,  7,  0,
        27, 27, 27, 27, 27, 27, 27, 26, 26, 26, 25, 25, 24, 24, 23, 22, 22, 21, 20, 19, 18, 17, 15, 14, 12, 10,  7,  0,
        28, 28, 28, 28, 28, 28, 28, 27, 27, 27, 26, 26, 25, 25, 24, 24, 23, 22, 21, 21, 20, 18, 17, 16, 14, 12, 10,  7,  0,
        29, 29, 29, 29, 29, 29, 29, 28, 28, 28, 27, 27, 27, 26, 25, 25, 24, 24, 23, 22, 21, 20, 19, 18, 16, 14, 13, 10,  7,  0,
        30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 28, 28, 28, 27, 27, 26, 25, 25, 24, 23, 22, 21, 20, 19, 18, 16, 15, 13, 10,  7,  0,
        31, 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 29, 29, 28, 28, 27, 27, 26, 25, 24, 24, 23, 22, 21, 19, 18, 17, 15, 13, 11,  7,  0
    },
/* FOV_SHAPE_CIRCLE_PLUS1: sqrt(r^2 + 1 - x^2) */
    {
         1,
         2,  1,
         3,  2,  1,
         4,  3,  2,  1,
         5,  4,  4,  3,  1,
         6,  5,  5,  4,  3,  1,
         7,  6,  6,  5,  5,  3,  1,
         8,  7,  7,  7,  6,  5,  4,  1,
         9,  8,  8,  8,  7,  6,  5,  4,  1,
        10,  9,  9,  9,  8,  8,  7,  6,  4,  1,
        11, 10, 10, 10,  9,  9,  8,  7,  6,  4,  1,
        12, 11, 11, 11, 10, 10,  9,  9,  8,  6,  4,  1,
        13, 12, 12, 12, 12, 11, 11, 10,  9,  8,  7,  5,  1,
        14, 13, 13, 13, 13, 12, 12, 11, 10,  9,  8,  7,  5,  1,
        15, 14, 14, 14, 14, 13, 13, 12, 12, 11, 10,  9,  7,  5,  1,
        16, 15, 15, 15, 15, 14, 14, 13, 13, 12, 11, 10,  9,  7,  5,  1,
        17, 16, 16, 16, 16, 15, 15, 15, 14, 13, 13, 12, 11,  9,  8,  5,  1,
        18, 17, 17, 17, 17, 17, 16, 16, 15, 15, 14, 13, 12, 11, 10,  8,  6,  1,
        19, 18, 18, 18, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 11, 10,  8,  6,  1,
        20, 19, 19, 19, 19, 19, 18, 18, 17, 17, 16, 16, 15, 14, 13, 12, 10,  8,  6,  1,
        21, 20, 20, 20, 20, 20, 19, 19, 19, 18, 17, 17, 16, 15, 14, 13, 12, 10,  9,  6,  1,
        22, 21, 21, 21, 21, 21, 20, 20, 20, 19, 19, 18, 17, 17, 16, 15, 14, 12, 11,  9,  6,  1,
        23, 22, 22, 22, 22, 22, 21, 21, 21, 20, 20, 19, 19, 18, 17, 16, 15, 14, 13, 11,  9,  6,  1,
        24, 23, 23, 23, 23, 23, 22, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 14, 13, 11,  9,  6,  1,
        25, 24, 24, 24, 24, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 18, 17, 16, 15, 13, 11,  9,  7,  1,
        26, 25, 25, 25, 25, 25, 25, 24, 24, 24, 23, 23, 22, 21, 21, 20, 19, 18, 17, 16, 15, 13, 12, 10,  7,  1,
        27, 26, 26, 26, 26, 26, 26, 25, 25, 25, 24, 24, 23, 23, 22, 21, 21, 20, 19, 18, 17, 15, 14, 12, 10,  7,  1,
        28, 27, 27, 27, 27, 27, 27, 26, 26, 26, 25, 25, 24, 24, 23, 23, 22, 21, 20, 19, 18, 17, 16, 14, 12, 10,  7,  1,
        29, 28, 28, 28, 28, 28, 28, 27, 27, 27, 26, 26, 25, 25, 24, 24, 23, 22, 21, 21, 20, 18, 17, 16, 14, 12, 10,  7,  1,
        30, 29, 29, 29, 29, 29, 29, 28, 28, 28, 27, 27, 27, 26, 26, 25, 24, 24, 23, 22, 21, 20, 19, 18, 16, 15, 13, 10,  7,  1,
        31, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 28, 28, 27, 27, 26, 25, 25, 24, 23, 22, 21, 20, 19, 18, 16, 15, 13, 11,  7,  1,
        32, 31, 31, 31, 31, 31, 31, 31, 30, 30, 30, 29, 29, 28, 28, 27, 27, 26, 25, 25, 24, 23, 22, 21, 20, 18, 17, 15, 13, 11,  8,  1
    },
/* FOV_SHAPE_OCTAGON: 2*(r - x) + 1 */
    {
         1,
         2,  1,
         3,  2,  1,
         4,  3,  3,  1,
         5,  4,  4,  3,  1,
         6,  5,  5,  4,  3,  1,
         7,  6,  6,  5,  5,  3,  1,
         8,  7,  7,  6,  6,  5,  3,  1,
         9,  8,  8,  7,  7,  6,  5,  3,  1,
        10,  9,  9,  8,  8,  7,  7,  5,  3,  1,
        11, 10, 10,  9,  9,  8,  8,  7,  5,  3,  1,
        12, 11, 11, 10, 10,  9,  9,  8,  7,  5,  3,  1,
        13, 12, 12, 11, 11, 10, 10,  9,  9,  7,  5,  3,  1,
        14, 13, 13, 12, 12, 11, 11, 10, 10,  9,  7,  5,  3,  1,
        15, 14, 14, 13, 13, 12, 12, 11, 11, 10,  9,  7,  5,  3,  1,
        16, 15, 15, 14, 14, 13, 13, 12, 12, 11, 11,  9,  7,  5,  3,  1,
        17, 16, 16, 15, 15, 14, 14, 13, 13, 12, 12, 11,  9,  7,  5,  3,  1,
        18, 17, 17, 16, 16, 15, 15, 14, 14, 13, 13, 12, 11,  9,  7,  5,  3,  1,
        19, 18, 18, 17, 17, 16, 16, 15, 15, 14, 14, 13, 13, 11,  9,  7,  5,  3,  1,
        20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15, 14, 14, 13, 11,  9,  7,  5,  3,  1,
        21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15, 14, 13, 11,  9,  7,  5,  3,  1,
        22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15, 13, 11,  9,  7,  5,  3,  1,
        23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 13, 11,  9,  7,  5,  3,  1,
        24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 15, 13, 11,  9,  7,  5,  3,  1,
        25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        29, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        30, 29, 29, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 19, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        31, 30, 30, 29, 29, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 19, 17, 15, 13, 11,  9,  7,  5,  3,  1,
        32, 31, 31, 30, 30, 29, 29, 28, 28, 27, 27, 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 19, 17, 15, 13, 11,  9,  7,  5,  3,  1
    },
/* FOV_SHAPE_DIAMOND: r - x */
    {
         0,
         1,  0,
         2,  1,  0,
         3,  2,  1,  0,
         4,  3,  2,  1,  0,
         5,  4,  3,  2,  1,  0,
         6,  5,  4,  3,  2,  1,  0,
         7,  6,  5,  4,  3,  2,  1,  0,
         8,  7,  6,  5,  4,  3,  2,  1,  0,
         9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0,
        31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
    },
/* FOV_SHAPE_SQUARE: r */
    {
         1,
         2,  2,
         3,  3,  3,
         4,  4,  4,  4,
         5,  5,  5,  5,  5,
         6,  6,  6,  6,  6,  6,
         7,  7,  7,  7,  7,  7,  7,
         8,  8,  8,  8,  8,  8,  8,  8,
         9,  9,  9,  9,  9,  9,  9,  9,  9,
        10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
        11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
        12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
        15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
        16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
        17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
        18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
        19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
        21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
        24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
        25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
        26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
        27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
        28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
        29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
        30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
        31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31,
        32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
    }
};


/* Types ---------------------------------------------------------- */

/** \cond INTERNAL */
typedef struct {
    /*@observer@*/ fov_settings_type *settings;
    /*@observer@*/ void *map;
    /*@observer@*/ void *source;
    const char *heights;
    int source_x;
    int source_y;
    int radius;
} fov_private_data_type;
/** \endcond */

/* Options -------------------------------------------------------- */

/* Only one thread of T-Engine ever interfaces with fov code, so let's use global static variables */
/* Even though we are using static variables, all algorithms can be THREAD SAFE and RE-ENTRANT */
static float global_permissiveness = 0.5f;
static float global_actor_vision_size = 0.5f;
static fov_algo_type global_algorithm = FOV_ALGO_RECURSIVE_SHADOW;
static fov_shape_type global_shape = FOV_SHAPE_CIRCLE_ROUND;
static fov_buffer_type global_buffer_data;

/* set global parameters */
void fov_set_permissiveness(float value) {
    global_permissiveness = value;
}

void fov_set_actor_vision_size(float value) {
    global_actor_vision_size = value;
}

void fov_set_algorithm(fov_algo_type value) {
    global_algorithm = value;
}

void fov_set_vision_shape(fov_shape_type value) {
    global_shape = value;
}

/* get global parameters */
float fov_get_permissiveness() {
    return global_permissiveness;
}

float fov_get_actor_vision_size() {
    return global_actor_vision_size;
}

fov_algo_type fov_get_algorithm() {
    return global_algorithm;
}

fov_shape_type fov_get_vision_shape() {
    return global_shape;
}

/* set settings struct with defaults */
void fov_settings_init(fov_settings_type *settings) {
    settings->opaque = NULL;
    settings->apply = NULL;
    settings->permissiveness = global_permissiveness;
    settings->actor_vision_size = global_actor_vision_size;
    settings->algorithm = global_algorithm;
    settings->shape = global_shape;
    settings->buffer_data = &global_buffer_data;
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

/* Octants -------------------------------------------------------- */

#define GET_HEIGHT(h, dx, data, settings)                                                         \
    /* use lookup table if available (i.e., when radius < 33) */                                  \
    if (data->heights) {                                                                          \
        h = (int)(data->heights[dx]);                                                             \
    } else {                                                                                      \
        switch (settings->shape) {                                                                \
        case FOV_SHAPE_CIRCLE_ROUND :                                                             \
            h = (int)(sqrt((data->radius)*(data->radius) + data->radius - dx*dx));                \
            break;                                                                                \
        case FOV_SHAPE_CIRCLE_FLOOR :                                                             \
            h = (int)(sqrt((data->radius)*(data->radius) + 2*data->radius - dx*dx));              \
            break;                                                                                \
        case FOV_SHAPE_CIRCLE_CEIL :                                                              \
            h = (int)(sqrt((data->radius)*(data->radius) - dx*dx));                               \
            break;                                                                                \
        case FOV_SHAPE_CIRCLE_PLUS1 :                                                             \
            h = (int)(sqrt((data->radius)*(data->radius) + 1 - dx*dx));                           \
            break;                                                                                \
        case FOV_SHAPE_OCTAGON :                                                                  \
            h = 2*(data->radius - dx) + 1;                                                        \
            break;                                                                                \
        case FOV_SHAPE_DIAMOND :                                                                  \
            h = data->radius - dx;                                                                \
            break;                                                                                \
        case FOV_SHAPE_SQUARE :                                                                   \
            h = data->radius;                                                                     \
            break;                                                                                \
        default :                                                                                 \
            h = (int)(sqrt((data->radius)*(data->radius) + data->radius - dx*dx));                \
            break;                                                                                \
        }                                                                                         \
    }                                                                                             \

#define FOV_DEFINE_OCTANT(signx, signy, rx, ry, nx, ny, nf)                                       \
    static void fov_octant_##nx##ny##nf(                                                          \
                                        fov_private_data_type *data,                              \
                                        int dx,                                                   \
                                        float start_slope,                                        \
                                        float end_slope,                                          \
                                        bool blocked_below,                                       \
                                        bool blocked_above,                                       \
                                        bool apply_edge,                                          \
                                        bool apply_diag) {                                        \
        int h, x, y, dy, dy0, dy1;                                                                \
        int prev_blocked = -1;                                                                    \
        float start_slope_next, end_slope_next;                                                   \
        float fdx = (float)dx;                                                                    \
        fov_settings_type *settings = data->settings;                                             \
                                                                                                  \
        if (dx > data->radius) {                                                                  \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        /* being "pinched" isn't blocked, but we need to handle it as a special case */           \
        if (blocked_below && blocked_above && end_slope - start_slope < GRID_EPSILON) {           \
            dy0 = (int)(0.5f + fdx*start_slope - GRID_EPSILON);                                   \
            dy1 = (int)(0.5f + fdx*end_slope - GRID_EPSILON);                                     \
        } else {                                                                                  \
            dy0 = (blocked_below) ? (int)(0.5f + fdx*start_slope + GRID_EPSILON)                  \
                                  : (int)(0.5f + fdx*start_slope - GRID_EPSILON);                 \
            dy1 = (blocked_above) ? (int)(0.5f + fdx*end_slope - GRID_EPSILON)                    \
                                  : (int)(0.5f + fdx*end_slope + GRID_EPSILON);                   \
        }                                                                                         \
                                                                                                  \
        rx = data->source_##rx signx dx;                                                          \
                                                                                                  \
        /* we need to check if the previous spot is blocked */                                    \
        if (dy0 > 0) {                                                                            \
            ry = data->source_##ry signy (dy0-1);                                                 \
            prev_blocked = (int)settings->opaque(data->map, x, y);                                \
        }                                                                                         \
                                                                                                  \
        GET_HEIGHT(h, dx, data, settings)                                                         \
                                                                                                  \
        if (dy1 > h) {                                                                            \
            dy1 = h;                                                                              \
        }                                                                                         \
                                                                                                  \
        for (dy = dy0; dy <= dy1; ++dy) {                                                         \
            ry = data->source_##ry signy dy;                                                      \
                                                                                                  \
            if (settings->opaque(data->map, x, y)) {                                              \
                if ((apply_edge || dy > 0) && (apply_diag || dy != dx)) {                         \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                if (prev_blocked == 0 && dy != dy0) {                                             \
                    end_slope_next = ((float)dy - 0.5f) /                                         \
                                     (fdx + settings->permissiveness);                            \
                    if (start_slope - end_slope_next < GRID_EPSILON) {                            \
                        fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope_next,          \
                                                blocked_below, true, apply_edge, apply_diag);     \
                    }                                                                             \
                }                                                                                 \
                prev_blocked = 1;                                                                 \
            } else {                                                                              \
                if (prev_blocked == 1) {                                                          \
                    start_slope_next = ((float)dy - 0.5f) /                                       \
                                       (fdx - settings->permissiveness);                          \
                    if (start_slope - start_slope_next < GRID_EPSILON) {                          \
                        start_slope = start_slope_next;                                           \
                        if (start_slope - end_slope > GRID_EPSILON) {                             \
                            return;                                                               \
                        }                                                                         \
                        blocked_below = true;                                                     \
                    }                                                                             \
                }                                                                                 \
                if ((apply_edge || dy > 0) && (apply_diag || dy != dx)) {                         \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }                                                                                     \
        }                                                                                         \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            /* We need to check if the next spot is blocked and change end_slope accordingly */   \
            if (dx != dy1) {                                                                      \
                ry = data->source_##ry signy (dy1+1);                                             \
                if (settings->opaque(data->map, x, y)) {                                          \
                    end_slope_next = ((float)dy1 + 0.5f) /                                        \
                                     (fdx + settings->permissiveness);                            \
                    if (end_slope_next - end_slope < GRID_EPSILON) {                              \
                        end_slope = end_slope_next;                                               \
                        if (start_slope - end_slope > GRID_EPSILON) {                             \
                            return;                                                               \
                        }                                                                         \
                        blocked_below = true;                                                     \
                    }                                                                             \
                }                                                                                 \
            }                                                                                     \
            fov_octant_##nx##ny##nf(data, dx+1, start_slope, end_slope,                           \
                                    blocked_below, blocked_above, apply_edge, apply_diag);        \
        }                                                                                         \
    }

FOV_DEFINE_OCTANT(+,+,x,y,p,p,n)
FOV_DEFINE_OCTANT(+,+,y,x,p,p,y)
FOV_DEFINE_OCTANT(+,-,x,y,p,m,n)
FOV_DEFINE_OCTANT(+,-,y,x,p,m,y)
FOV_DEFINE_OCTANT(-,+,x,y,m,p,n)
FOV_DEFINE_OCTANT(-,+,y,x,m,p,y)
FOV_DEFINE_OCTANT(-,-,x,y,m,m,n)
FOV_DEFINE_OCTANT(-,-,y,x,m,m,y)


/* Get a buffer that acts as a memory pool for small arrays of different lengths used for FoV.
   This is very simple and naive (and, hence, very fast, especially compared to malloc/free),
   yet it is large enough to prevent any overwriting of data resulting from round-robin access.
   Obviously, don't use the same buffer for multiple threads.
*/
#define GET_BUFFER(target, buffer_data, len)                                                      \
    /* hurray, no branching, modulus, or malloc! */                                               \
    {                                                                                             \
    int overrun = (buffer_data->index + buffer_data->prev_len + len) & (FOV_BUFFER_SIZE - 1);     \
    buffer_data->index = (buffer_data->index + buffer_data->prev_len) & (FOV_BUFFER_SIZE - 1);    \
    if (overrun < buffer_data->index)                                                             \
        buffer_data->index = 0;                                                                   \
    buffer_data->prev_len = len;                                                                  \
    target = buffer_data->buffer + buffer_data->index;                                            \
    }

/* Conveniences for code clarity */
#define X 0
#define Y 1
#define K 2

/* A macro to calculate the next slopes and boundaries due to a blocked tile.
   This is written from the perspective of finding the next upper slope, but this
   will also find the lower slope if min/max and low/upp are switched and sign is -.
*/
#define GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, sign, do_command)                             \
    if (do_command) next_blen = 3;                                                                \
    next_slope = (fdy - y_##min) / fdx;                                                           \
    if (do_command) next_start_y = y_##min;                                                       \
    /* we may revise blen upper later, but request max possible anyway */                         \
    GET_BUFFER(next_boundaries, buffer_data, upp##er_blen + 3)                                    \
    boundary = next_boundaries;                                                                   \
                                                                                                  \
    /* set next_boundaries */                                                                     \
    if (upp##er_blen == 0) {                                                                      \
        boundary[X] = fdx;                                                                        \
        boundary[Y] = fdy;                                                                        \
        boundary[K] = (fdy - y_##max) / fdx;                                                      \
/* printf("UPP1\t%f\t%f\t%f\n", boundary[X], boundary[Y], boundary[K]); */                        \
    } else {                                                                                      \
        /* Three conditions must be met: */                                                       \
        /* 1. Y_i < Y_{i+1}       -- increasing Y */                                              \
        /* 2. K_i < K_{i+1}       -- concave curve */                                             \
        /*  (a) K_i < slope to current */                                                         \
        /* 3. Y - K_i*X_i < y_max -- intersects with source actor */                              \
                                                                                                  \
        /* For calculations of lower data, the conditions are: */                                 \
        /* 1. Y_i < Y_{i+1}       -- increasing Y */                                              \
        /* 2. K_i > K_{i+1}       -- convex curve */                                              \
        /*  (a) K_i > slope to current */                                                         \
        /* 3. Y - K_i*X_i > y_min -- intersects with source actor */                              \
        prev_boundary = upp##er_boundaries;                                                       \
        ptr_end = upp##er_boundaries + upp##er_blen;                                              \
        is_first = true;                                                                          \
        do {                                                                                      \
            /* The previous boundary may have been rejected, so */                                \
            /* recalculate the slope. */                                                          \
            prev_slope = (is_first) ? (prev_boundary[Y] - y_##max) /                              \
                                      prev_boundary[X]                                            \
                                    : (prev_boundary[Y] - boundary[Y-3]) /                        \
                                      (prev_boundary[X] - boundary[X-3]);                         \
            slope = (fdy - prev_boundary[Y]) /                                                    \
                    (fdx - prev_boundary[X]);                                                     \
            if (/*fdy - prev_boundary[Y] > GRID_EPSILON && */               /* (1) */             \
                sign (slope - prev_slope) > GRID_EPSILON                    /* (2) */             \
                && sign (prev_boundary[Y] - slope*prev_boundary[X]                                \
                                          - y_##max) < GRID_EPSILON) {      /* (3) */             \
                boundary[X] = prev_boundary[X];                                                   \
                boundary[Y] = prev_boundary[Y];                                                   \
                boundary[K] = prev_slope;                                                         \
/* printf("UPP2\t%f\t%f\t%f\n", boundary[X], boundary[Y], boundary[K]); */                        \
                boundary += 3;                                                                    \
                if (do_command) next_blen += 3;                                                   \
                is_first = false;                                                                 \
            }                                                                                     \
            prev_boundary += 3;                                                                   \
        } while (prev_boundary != ptr_end);                                                       \
                                                                                                  \
        /* now add the current opaque tile */                                                     \
        boundary[X] = fdx;                                                                        \
        boundary[Y] = fdy;                                                                        \
        /* it's possible nothing was set */                                                       \
        boundary[K] = (is_first) ? (boundary[Y] - y_##max) /                                      \
                                   boundary[X]                                                    \
                                 : (boundary[Y] - boundary[Y-3]) /                                \
                                   (boundary[X] - boundary[X-3]);                                 \
/* printf("UPP3\t%f\t%f\t%f\n", boundary[X], boundary[Y], boundary[K]); */                        \
    }                                                                                             \
                                                                                                  \
    /* set next_slope, checking lower_boundaries */                                               \
    if (low##er_blen > 0) {                                                                       \
        prev_boundary = low##er_boundaries;                                                       \
        ptr_end = low##er_boundaries + low##er_blen;                                              \
        while (prev_boundary != ptr_end) {                                                        \
            if (sign (prev_boundary[K] - next_slope) > GRID_EPSILON) {                            \
                next_slope = (boundary[Y] - prev_boundary[Y]) /                                   \
                             (boundary[X] - prev_boundary[X]);                                    \
                prev_boundary += 3;                                                               \
            } else {                                                                              \
                break;                                                                            \
            }                                                                                     \
        }                                                                                         \
        if (do_command) next_start_y = boundary[Y] - next_slope*boundary[X];                      \
   }                                                                                              \
                                                                                                  \
   if (sign (upp##er_slope - next_slope) < GRID_EPSILON) {                                        \
       next_slope = upp##er_slope;                                                                \
       if (do_command) next_start_y = boundary[Y] - next_slope*boundary[X];                       \
   }                                                                                              \
   /* clean up noisy calculations to avoid precision errors */                                    \
   if (do_command) {                                                                              \
       if (next_start_y - y_min < GRID_EPSILON) {                                                 \
           next_start_y = y_min;                                                                  \
       }                                                                                          \
   }


#define LARGE_ASS_FOV_DEFINE_OCTANT(signx, signy, rx, ry, nx, ny, nf)                             \
    static void large_ass_fov_octant_##nx##ny##nf(                                                \
                                        fov_private_data_type *data,                              \
                                        int dx,                                                   \
                                        int lower_blen,                                           \
                                        int upper_blen,                                           \
                                        float lower_slope,  /* >= 0 */                            \
                                        float upper_slope,  /* <= 2 */                            \
                                        float lower_start_y,                                      \
                                        float upper_start_y,                                      \
                                        float y_min,  /* store in data? */                        \
                                        float y_max,  /* store in data? */                        \
                                        float *lower_boundaries,                                  \
                                        float *upper_boundaries,                                  \
                                        bool apply_edge,                                          \
                                        bool apply_diag) {                                        \
        int h, x, y, dy, dy0, dy1, cy0, cy1, next_blen;                                           \
        int prev_blocked = -1;                                                                    \
        fov_settings_type *settings = data->settings;                                             \
        float fdy, next_slope, prev_slope, slope, next_start_y;                                   \
        float fdx = (float)dx;                                                                    \
        float pms = settings->permissiveness;                                                     \
        float *boundary, *next_boundaries, *prev_boundary, *ptr_end;                              \
        fov_buffer_type *buffer_data = settings->buffer_data;                                     \
        bool is_first;                                                                            \
                                                                                                  \
        if (dx > data->radius) {                                                                  \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        rx = data->source_##rx signx dx;                                                          \
                                                                                                  \
        dy0 = (int)(lower_start_y + (fdx - pms)*lower_slope + GRID_EPSILON);  /* lower left */    \
        dy1 = (int)(upper_start_y + (fdx + pms)*upper_slope - GRID_EPSILON);  /* upper right */   \
        cy0 = (int)(lower_start_y + fdx*lower_slope + GRID_EPSILON) - 1;      /* lower center */  \
        cy1 = (int)(upper_start_y + fdx*upper_slope - GRID_EPSILON) + 1;      /* upper center */  \
        if (dy1 > dx+1) dy1 = dx+1;                                                               \
        if (cy1 > dx+1) cy1 = dx+1;                                                               \
                                                                                                  \
        GET_HEIGHT(h, dx, data, settings)                                                         \
                                                                                                  \
        if (dy1 > h) {                                                                            \
            dy1 = h;                                                                              \
        }                                                                                         \
                                                                                                  \
        for (dy = dy0; dy <= dy1; ++dy) {                                                         \
            ry = data->source_##ry signy dy;                                                      \
            /* if blocked, then shadowcast below the blocked tile if necessary */                 \
            if (settings->opaque(data->map, x, y)) {                                              \
                fdy = (float)dy;                                                                  \
                if (prev_blocked == 0) {                                                          \
                    fdx = (float)dx + pms;                                                        \
                    /* don't double-apply edges or diags, apply only if seen (cy0 < dy < cy1) */  \
                    if ((apply_edge || dy > 0) && (apply_diag || dy != dx) && (dy > cy0)          \
                                                                           && (dy < cy1)) {       \
                        settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,  \
                                        data->radius, data->source);                              \
                    }                                                                             \
                    /* if lower line blocked by tile, then no recursive call is needed */         \
                    if (fdy - lower_start_y - fdx*lower_slope < GRID_EPSILON) {                   \
                        goto skip_recurse_below;                                                  \
                    }                                                                             \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                           \
                                                                                                  \
                    large_ass_fov_octant_##nx##ny##nf(data,             dx + 1,                   \
                                                      lower_blen,       next_blen,                \
                                                      lower_slope,      next_slope,               \
                                                      lower_start_y,    next_start_y,             \
                                                      y_min,            y_max,                    \
                                                      lower_boundaries, next_boundaries,          \
                                                      apply_edge,       apply_diag);              \
                } else {  /* prev_blocked != 0 */                                                 \
                    /* We need to calculate slopes to see if the tile is visible. */              \
                    /* Recall that the previous tile and current tile are blocked, so the */      \
                    /* previous tile may block the current tile. */                               \
                    fdx = (float)dx - pms;                                                        \
                                                                                                  \
                    /* if upper line is blocked by previous tile, then we are done */             \
                    if (fdy - upper_start_y - fdx*upper_slope > GRID_EPSILON) {                   \
                        goto skip_recurse_below;                                                  \
                    }                                                                             \
                    if (lower_start_y + fdx*lower_slope - fdy < GRID_EPSILON) {                   \
                                                                                                  \
                        GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, false)                     \
                                                                                                  \
                        if (upper_slope - next_slope < GRID_EPSILON) {                            \
                            goto skip_recurse_below;                                              \
                        }                                                                         \
                    }                                                                             \
                    /* don't double-apply edges or diags, apply only if seen (cy0 < dy < cy1) */  \
                    if ((apply_edge || dy > 0) && (apply_diag || dy != dx) && (dy > cy0)          \
                                                                           && (dy < cy1)) {       \
                        settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,  \
                                        data->radius, data->source);                              \
                    }                                                                             \
                }                                                                                 \
                skip_recurse_below:                                                               \
                prev_blocked = 1;                                                                 \
            } else {  /* not opaque */                                                            \
                if (prev_blocked == 1) {                                                          \
                    fdy = (float)dy;                                                              \
                    fdx = (float)dx - pms;                                                        \
                                                                                                  \
                    /* if upper line is blocked by previous tile, then we are done */             \
                    if (fdy - upper_start_y - fdx*upper_slope > GRID_EPSILON) {                   \
                        return;                                                                   \
                    }                                                                             \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, true)                          \
                                                                                                  \
                    if (upper_slope - next_slope < GRID_EPSILON) {                                \
                        return;                                                                   \
                    }                                                                             \
                    lower_blen = next_blen;                                                       \
                    lower_slope = next_slope;                                                     \
                    lower_start_y = next_start_y;                                                 \
                    lower_boundaries = next_boundaries;                                           \
                }  /* end prev_blocked */                                                         \
                if ((apply_edge || dy > 0) && (apply_diag || dy != dx) && (dy > cy0)              \
                                                                       && (dy < cy1)) {           \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }  /* end if not opaque */                                                            \
        }  /* end for */                                                                          \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            large_ass_fov_octant_##nx##ny##nf(data,             dx + 1,                           \
                                              lower_blen,       upper_blen,                       \
                                              lower_slope,      upper_slope,                      \
                                              lower_start_y,    upper_start_y,                    \
                                              y_min,            y_max,                            \
                                              lower_boundaries, upper_boundaries,                 \
                                              apply_edge,       apply_diag);                      \
        }                                                                                         \
    } /* DONE! */

LARGE_ASS_FOV_DEFINE_OCTANT(+,+,x,y,p,p,n)
LARGE_ASS_FOV_DEFINE_OCTANT(+,+,y,x,p,p,y)
LARGE_ASS_FOV_DEFINE_OCTANT(+,-,x,y,p,m,n)
LARGE_ASS_FOV_DEFINE_OCTANT(+,-,y,x,p,m,y)
LARGE_ASS_FOV_DEFINE_OCTANT(-,+,x,y,m,p,n)
LARGE_ASS_FOV_DEFINE_OCTANT(-,+,y,x,m,p,y)
LARGE_ASS_FOV_DEFINE_OCTANT(-,-,x,y,m,m,n)
LARGE_ASS_FOV_DEFINE_OCTANT(-,-,y,x,m,m,y)


#define LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(signx, signy, rx, ry, nx, ny, nf)                        \
    static void large_ass_fov_octant_zero_##nx##ny##nf(                                           \
                                        fov_private_data_type *data,                              \
                                        float lower_slope,  /* >= 0 */                            \
                                        float upper_slope,  /* <= 2 */                            \
                                        bool apply_edge,                                          \
                                        bool apply_diag) {                                        \
        int x, y;                                                                                 \
        fov_settings_type *settings = data->settings;                                             \
        float slope, upper_start_y;                                                               \
        float *upper_boundaries;                                                                  \
        float pms = settings->permissiveness;                                                     \
        float y_min = 0.5f - settings->actor_vision_size;                                         \
        float y_max = 0.5f + settings->actor_vision_size;                                         \
                                                                                                  \
        if (y_max + upper_slope * pms - 1.0f > GRID_EPSILON) {                                    \
            rx = data->source_##rx;                                                               \
            ry = data->source_##ry signy 1;                                                       \
            if (settings->opaque(data->map, x, y)) {                                              \
                slope = (1.0f - y_min) / pms;                                                     \
                if (slope - upper_slope < GRID_EPSILON) {                                         \
                    upper_slope = slope;                                                          \
                }                                                                                 \
                GET_BUFFER(upper_boundaries, settings->buffer_data, 3)                            \
                upper_boundaries[X] = pms;                                                        \
                upper_boundaries[Y] = 1.0f;                                                       \
                upper_boundaries[K] = (1.0f - y_max) / pms;                                       \
/* printf("UPP\t%f\t%f\t%f\n", upper_boundaries[X], upper_boundaries[Y], upper_boundaries[K]); */ \
                upper_start_y = 1.0f - upper_slope * pms;                                         \
                large_ass_fov_octant_##nx##ny##nf(data,             1,                            \
                                                  0,                3,                            \
                                                  lower_slope,      upper_slope,                  \
                                                  y_min,            upper_start_y,                \
                                                  y_min,            y_max,                        \
                                                  NULL,             upper_boundaries,             \
                                                  apply_edge,       apply_diag);                  \
                return;                                                                           \
            }                                                                                     \
        }                                                                                         \
        large_ass_fov_octant_##nx##ny##nf(data,             1,                                    \
                                          0,                0,                                    \
                                          lower_slope,      upper_slope,                          \
                                          y_min,            y_max,                                \
                                          y_min,            y_max,                                \
                                          NULL,             NULL,                                 \
                                          apply_edge,       apply_diag);                          \
    }

LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(+,+,x,y,p,p,n)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(+,+,y,x,p,p,y)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(+,-,x,y,p,m,n)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(+,-,y,x,p,m,y)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(-,+,x,y,m,p,n)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(-,+,y,x,m,p,y)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(-,-,x,y,m,m,n)
LARGE_ASS_FOV_DEFINE_OCTANT_ZERO(-,-,y,x,m,m,y)


#define HEX_FOV_DEFINE_SEXTANT(signx, signy, nx, ny, one)                                         \
    static void hex_fov_sextant_##nx##ny(                                                         \
                                        fov_private_data_type *data,                              \
                                        int dy,                                                   \
                                        float start_slope,                                        \
                                        float end_slope,                                          \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        int x, y, x0, x1, p;                                                                      \
        int prev_blocked = -1;                                                                    \
        float fdy, end_slope_next;                                                                \
        fov_settings_type *settings = data->settings;                                             \
                                                                                                  \
        if (start_slope - end_slope > GRID_EPSILON) {                                             \
            return;                                                                               \
        } else if (dy > data->radius) {                                                           \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        fdy = (float)dy;                                                                          \
        x0 = (int)(0.5f + fdy*start_slope / (SQRT_3_2 + 0.5f*start_slope) + GRID_EPSILON);        \
        x1 = (int)(0.5f + fdy*end_slope / (SQRT_3_2 + 0.5f*end_slope) - GRID_EPSILON);            \
        if (x1 < x0) return;                                                                      \
                                                                                                  \
        x = data->source_x signx x0;                                                              \
        p = ((x & 1) + one) & 1;                                                                  \
        fdy += 0.25f;                                                                             \
        y = data->source_y signy (dy - (x0 + 1 - p)/2);                                           \
                                                                                                  \
        for (; x0 <= x1; ++x0) {                                                                  \
            if (settings->opaque(data->map, x, y)) {                                              \
                if ((apply_edge1 || x0 > 0) && (apply_edge2 || x0 != dy)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                if (prev_blocked == 0) {                                                          \
                    end_slope_next = (-SQRT_3_4 + SQRT_3_2*(float)x0) / (fdy - 0.5f*(float)x0);   \
                    hex_fov_sextant_##nx##ny(data, dy+1, start_slope, end_slope_next,             \
                                             apply_edge1, apply_edge2);                           \
                }                                                                                 \
                prev_blocked = 1;                                                                 \
            } else {                                                                              \
                if (prev_blocked == 1) {                                                          \
                    start_slope = (-SQRT_3_4 + SQRT_3_2*(float)x0) / (fdy - 0.5f*(float)x0);      \
                }                                                                                 \
                if ((apply_edge1 || x0 > 0) && (apply_edge2 || x0 != dy)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }                                                                                     \
            y = y signy (-p);                                                                     \
            x = x signx 1;                                                                        \
            p = !p;                                                                               \
        }                                                                                         \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            hex_fov_sextant_##nx##ny(data, dy+1, start_slope, end_slope,                          \
                                     apply_edge1, apply_edge2);                                   \
        }                                                                                         \
    }

#define HEX_FOV_DEFINE_LR_SEXTANT(signx, nx)                                                      \
    static void hex_fov_sextant_##nx(                                                             \
                                        fov_private_data_type *data,                              \
                                        int dx,                                                   \
                                        float start_slope,                                        \
                                        float end_slope,                                          \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        int x, y, y0, y1, p;                                                                      \
        int prev_blocked = -1;                                                                    \
        float fdx, fdy, end_slope_next;                                                           \
        fov_settings_type *settings = data->settings;                                             \
                                                                                                  \
        if (start_slope - end_slope > GRID_EPSILON) {                                             \
            return;                                                                               \
        } else if (dx > data->radius) {                                                           \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        x = data->source_x signx dx;                                                              \
        fdx = (float)dx * SQRT_3_2;                                                               \
        fdy = -0.5f*(float)dx - 0.5f;                                                             \
                                                                                                  \
        p = -dx / 2 - (dx & 1)*(x & 1);                                                           \
        y0 = (int)(fdx*start_slope - fdy + GRID_EPSILON);                                         \
        y1 = (int)(fdx*end_slope - fdy - GRID_EPSILON);                                           \
        if (y1 < y0) return;                                                                      \
                                                                                                  \
        y = data->source_y + y0 + p;                                                              \
                                                                                                  \
        for (; y0 <= y1; ++y0) {                                                                  \
            if (settings->opaque(data->map, x, y)) {                                              \
                if ((apply_edge1 || y0 > 0) && (apply_edge2 || y0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                if (prev_blocked == 0) {                                                          \
                    end_slope_next = ((float)y0 + fdy) / fdx;                                     \
                    hex_fov_sextant_##nx(data, dx+1, start_slope, end_slope_next,                 \
                                         apply_edge1, apply_edge2);                               \
                }                                                                                 \
                prev_blocked = 1;                                                                 \
            } else {                                                                              \
                if (prev_blocked == 1) {                                                          \
                    start_slope = ((float)y0 + fdy) / fdx;                                        \
                }                                                                                 \
                if ((apply_edge1 || y0 > 0) && (apply_edge2 || y0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }                                                                                     \
            ++y;                                                                                  \
        }                                                                                         \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            hex_fov_sextant_##nx(data, dx+1, start_slope, end_slope, apply_edge1, apply_edge2);   \
        }                                                                                         \
    }

HEX_FOV_DEFINE_SEXTANT(+,+,n,e,1)
HEX_FOV_DEFINE_SEXTANT(-,+,n,w,1)
HEX_FOV_DEFINE_SEXTANT(+,-,s,e,0)
HEX_FOV_DEFINE_SEXTANT(-,-,s,w,0)
HEX_FOV_DEFINE_LR_SEXTANT(+,e)
HEX_FOV_DEFINE_LR_SEXTANT(-,w)


#define HEX_LARGE_ASS_FOV_DEFINE_SEXTANT(signx, signy, nx, ny, one)                               \
    static void hex_large_ass_fov_sextant_##nx##ny(                                               \
                                        fov_private_data_type *data,                              \
                                        int dx,                                                   \
                                        int lower_blen,                                           \
                                        int upper_blen,                                           \
                                        float lower_slope,                                        \
                                        float upper_slope,                                        \
                                        float lower_start_y,                                      \
                                        float upper_start_y,                                      \
                                        float y_min,                                              \
                                        float y_max,                                              \
                                        float *lower_boundaries,                                  \
                                        float *upper_boundaries,                                  \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        int x, y, x0, x1, p, next_blen;                                                           \
        int prev_blocked = -1;                                                                    \
        fov_settings_type *settings = data->settings;                                             \
        float fy, fdy, next_slope, prev_slope, slope, next_start_y;                               \
        float fdx = (float)dx * SQRT_3_2;                                                         \
        float *boundary, *next_boundaries, *prev_boundary, *ptr_end;                              \
        fov_buffer_type *buffer_data = settings->buffer_data;                                     \
        bool is_first;                                                                            \
                                                                                                  \
        if (dx > data->radius) {                                                                  \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        fy = -0.5f*(float)dx;                                                                     \
                                                                                                  \
        x0 = (int)(fdx*lower_slope - fy + lower_start_y + GRID_EPSILON);                          \
        x1 = (int)(fdx*upper_slope - fy + upper_start_y - GRID_EPSILON);                          \
        if (x1 < x0) return;                                                                      \
                                                                                                  \
        x = data->source_x signx x0;                                                              \
        p = ((x & 1) + one) & 1;                                                                  \
        y = data->source_y signy (dx - (x0 + 1 - p)/2);                                           \
                                                                                                  \
        for (; x0 <= x1; ++x0) {                                                                  \
            if (settings->opaque(data->map, x, y)) {                                              \
                if ((apply_edge1 || x0 > 0) && (apply_edge2 || x0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                if (prev_blocked == 0) {                                                          \
                    fdy = (float)x0 + fy;                                                         \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                           \
                                                                                                  \
                    hex_large_ass_fov_sextant_##nx##ny(data,             dx + 1,                  \
                                                       lower_blen,       next_blen,               \
                                                       lower_slope,      next_slope,              \
                                                       lower_start_y,    next_start_y,            \
                                                       y_min,            y_max,                   \
                                                       lower_boundaries, next_boundaries,         \
                                                       apply_edge1,      apply_edge2);            \
                }                                                                                 \
                prev_blocked = 1;                                                                 \
            } else {                                                                              \
                if (prev_blocked == 1) {                                                          \
                    fdy = (float)x0 + fy;                                                         \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, true)                          \
                                                                                                  \
                    lower_blen = next_blen;                                                       \
                    lower_slope = next_slope;                                                     \
                    lower_start_y = next_start_y;                                                 \
                    lower_boundaries = next_boundaries;                                           \
                }                                                                                 \
                if ((apply_edge1 || x0 > 0) && (apply_edge2 || x0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }                                                                                     \
            y = y signy (-p);                                                                     \
            x = x signx 1;                                                                        \
            p = !p;                                                                               \
        }                                                                                         \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            hex_large_ass_fov_sextant_##nx##ny(data,             dx + 1,                          \
                                               lower_blen,       upper_blen,                      \
                                               lower_slope,      upper_slope,                     \
                                               lower_start_y,    upper_start_y,                   \
                                               y_min,            y_max,                           \
                                               lower_boundaries, upper_boundaries,                \
                                               apply_edge1,      apply_edge2);                    \
        }                                                                                         \
    }

#define HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT(signx, nx)                                            \
    static void hex_large_ass_fov_sextant_##nx(                                                   \
                                        fov_private_data_type *data,                              \
                                        int dx,                                                   \
                                        int lower_blen,                                           \
                                        int upper_blen,                                           \
                                        float lower_slope,                                        \
                                        float upper_slope,                                        \
                                        float lower_start_y,                                      \
                                        float upper_start_y,                                      \
                                        float y_min,                                              \
                                        float y_max,                                              \
                                        float *lower_boundaries,                                  \
                                        float *upper_boundaries,                                  \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        int x, y, y0, y1, p, next_blen;                                                           \
        int prev_blocked = -1;                                                                    \
        fov_settings_type *settings = data->settings;                                             \
        float fy, fdy, next_slope, prev_slope, slope, next_start_y;                               \
        float fdx = (float)dx * SQRT_3_2;                                                         \
        float *boundary, *next_boundaries, *prev_boundary, *ptr_end;                              \
        fov_buffer_type *buffer_data = settings->buffer_data;                                     \
        bool is_first;                                                                            \
                                                                                                  \
        if (dx > data->radius) {                                                                  \
            return;                                                                               \
        }                                                                                         \
                                                                                                  \
        x = data->source_x signx dx;                                                              \
        fy = -0.5f*(float)dx;                                                                     \
                                                                                                  \
        p = -dx / 2 - (dx & 1)*(x & 1);                                                           \
        y0 = (int)(fdx*lower_slope - fy + lower_start_y + GRID_EPSILON);                          \
        y1 = (int)(fdx*upper_slope - fy + upper_start_y - GRID_EPSILON);                          \
                                                                                                  \
        if (y1 < y0) return;                                                                      \
                                                                                                  \
        y = data->source_y + y0 + p;                                                              \
                                                                                                  \
        for (; y0 <= y1; ++y0) {                                                                  \
            if (settings->opaque(data->map, x, y)) {                                              \
                if ((apply_edge1 || y0 > 0) && (apply_edge2 || y0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                if (prev_blocked == 0) {                                                          \
                    fdy = (float)y0 + fy;                                                         \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                           \
                                                                                                  \
                    hex_large_ass_fov_sextant_##nx(data,             dx + 1,                      \
                                                   lower_blen,       next_blen,                   \
                                                   lower_slope,      next_slope,                  \
                                                   lower_start_y,    next_start_y,                \
                                                   y_min,            y_max,                       \
                                                   lower_boundaries, next_boundaries,             \
                                                   apply_edge1,      apply_edge2);                \
                }                                                                                 \
                prev_blocked = 1;                                                                 \
            } else {                                                                              \
                if (prev_blocked == 1) {                                                          \
                    fdy = (float)y0 + fy;                                                         \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, true)                          \
                                                                                                  \
                    lower_blen = next_blen;                                                       \
                    lower_slope = next_slope;                                                     \
                    lower_start_y = next_start_y;                                                 \
                    lower_boundaries = next_boundaries;                                           \
                }                                                                                 \
                if ((apply_edge1 || y0 > 0) && (apply_edge2 || y0 != dx)) {                       \
                    settings->apply(data->map, x, y, x - data->source_x, y - data->source_y,      \
                                    data->radius, data->source);                                  \
                }                                                                                 \
                prev_blocked = 0;                                                                 \
            }                                                                                     \
            ++y;                                                                                  \
        }                                                                                         \
                                                                                                  \
        if (prev_blocked == 0) {                                                                  \
            hex_large_ass_fov_sextant_##nx(data,             dx + 1,                              \
                                           lower_blen,       upper_blen,                          \
                                           lower_slope,      upper_slope,                         \
                                           lower_start_y,    upper_start_y,                       \
                                           y_min,            y_max,                               \
                                           lower_boundaries, upper_boundaries,                    \
                                           apply_edge1,      apply_edge2);                        \
        }                                                                                         \
    }

HEX_LARGE_ASS_FOV_DEFINE_SEXTANT(+,+,n,e,1)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT(-,+,n,w,1)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT(+,-,s,e,0)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT(-,-,s,w,0)
HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT(+,e)
HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT(-,w)


#define HEX_LARGE_ASS_FOV_DEFINE_SEXTANT_ZERO(signx, signy, nx, ny, one)                          \
    static void hex_large_ass_fov_sextant_zero_##nx##ny(                                          \
                                        fov_private_data_type *data,                              \
                                        float lower_slope,  /* >= 0 */                            \
                                        float upper_slope,  /* <= SQRT_3 */                       \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        float y_min = 0.5f - data->settings->actor_vision_size;                                   \
        float y_max = 0.5f + data->settings->actor_vision_size;                                   \
                                                                                                  \
        /* rotate slopes -30 degrees so we can use GET_NEXT_LARGE_ASS_DATA */                     \
        /*float new_lower_slope = (SQRT_3*lower_slope - 1.0f) / (lower_slope + SQRT_3); */        \
        /*float new_lower_slope = (SQRT_3_2*lower_slope - 0.5f) / (0.5f*lower_slope + SQRT_3_2);*/\
        float new_lower_slope = (lower_slope - INV_SQRT_3) / (INV_SQRT_3*lower_slope + 1.0f);     \
        float new_upper_slope = (upper_slope - INV_SQRT_3) / (INV_SQRT_3*upper_slope + 1.0f);     \
                                                                                                  \
        hex_large_ass_fov_sextant_##nx##ny(data,            1,                                    \
                                          0,                0,                                    \
                                          new_lower_slope,  new_upper_slope,                      \
                                          y_min,            y_max,                                \
                                          y_min,            y_max,                                \
                                          NULL,             NULL,                                 \
                                          apply_edge1,      apply_edge2);                         \
    }

#define HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT_ZERO(signx, nx)                                       \
    static void hex_large_ass_fov_sextant_zero_##nx(                                              \
                                        fov_private_data_type *data,                              \
                                        float lower_slope,  /* >= -INV_SQRT_3 */                  \
                                        float upper_slope,  /* <= INV_SQRT_3 */                   \
                                        bool apply_edge1,                                         \
                                        bool apply_edge2) {                                       \
        float y_min = 0.5f - data->settings->actor_vision_size;                                   \
        float y_max = 0.5f + data->settings->actor_vision_size;                                   \
                                                                                                  \
        hex_large_ass_fov_sextant_##nx(data,             1,                                       \
                                       0,                0,                                       \
                                       lower_slope,      upper_slope,                             \
                                       y_min,            y_max,                                   \
                                       y_min,            y_max,                                   \
                                       NULL,             NULL,                                    \
                                       apply_edge1,      apply_edge2);                            \
    }

HEX_LARGE_ASS_FOV_DEFINE_SEXTANT_ZERO(+,+,n,e,1)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT_ZERO(-,+,n,w,1)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT_ZERO(+,-,s,e,0)
HEX_LARGE_ASS_FOV_DEFINE_SEXTANT_ZERO(-,-,s,w,0)
HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT_ZERO(+,e)
HEX_LARGE_ASS_FOV_DEFINE_LR_SEXTANT_ZERO(-,w)


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
    fov_octant_ppn(data, 1, 0.0f, 1.0f, false, false,  true,  true);
    fov_octant_ppy(data, 1, 0.0f, 1.0f, false, false,  true, false);
    fov_octant_pmy(data, 1, 0.0f, 1.0f, false, false, false,  true);
    fov_octant_mpn(data, 1, 0.0f, 1.0f, false, false,  true, false);
    fov_octant_mmn(data, 1, 0.0f, 1.0f, false, false, false,  true);
    fov_octant_mmy(data, 1, 0.0f, 1.0f, false, false,  true, false);
    fov_octant_mpy(data, 1, 0.0f, 1.0f, false, false, false,  true);
    fov_octant_pmn(data, 1, 0.0f, 1.0f, false, false, false, false);
}

static void _large_ass_fov_circle(fov_private_data_type *data) {
    large_ass_fov_octant_zero_ppn(data, 0.0f, 2.0f,  true,  true);
    large_ass_fov_octant_zero_ppy(data, 0.0f, 2.0f,  true, false);
    large_ass_fov_octant_zero_pmy(data, 0.0f, 2.0f, false,  true);
    large_ass_fov_octant_zero_mpn(data, 0.0f, 2.0f,  true, false);
    large_ass_fov_octant_zero_mmn(data, 0.0f, 2.0f, false,  true);
    large_ass_fov_octant_zero_mmy(data, 0.0f, 2.0f,  true, false);
    large_ass_fov_octant_zero_mpy(data, 0.0f, 2.0f, false,  true);
    large_ass_fov_octant_zero_pmn(data, 0.0f, 2.0f, false, false);
}

static void _hex_fov_circle(fov_private_data_type *data) {
/*
  _            |            _
   \___2   nw 1|1 ne   2___/
       \___    |    ___/
       2   \__ | __/   2
     w      __>&<__      e
       1___/   |   \___1
    ___/       |       \___
  _/   2   sw 1|1 se   2   \_
               |
*/
    hex_fov_sextant_ne(data, 1,        0.0f,     SQRT_3,  true,  true);
    hex_fov_sextant_nw(data, 1,        0.0f,     SQRT_3, false,  true);
    hex_fov_sextant_w( data, 1, -INV_SQRT_3, INV_SQRT_3,  true, false);
    hex_fov_sextant_sw(data, 1,        0.0f,     SQRT_3,  true, false);
    hex_fov_sextant_se(data, 1,        0.0f,     SQRT_3, false,  true);
    hex_fov_sextant_e( data, 1, -INV_SQRT_3, INV_SQRT_3, false, false);
}

static void _hex_large_ass_fov_circle(fov_private_data_type *data) {
    hex_large_ass_fov_sextant_zero_ne(data,        0.0f,     SQRT_3,  true,  true);
    hex_large_ass_fov_sextant_zero_nw(data,        0.0f,     SQRT_3, false,  true);
    hex_large_ass_fov_sextant_zero_w( data, -INV_SQRT_3, INV_SQRT_3,  true, false);
    hex_large_ass_fov_sextant_zero_sw(data,        0.0f,     SQRT_3,  true, false);
    hex_large_ass_fov_sextant_zero_se(data,        0.0f,     SQRT_3, false,  true);
    hex_large_ass_fov_sextant_zero_e( data, -INV_SQRT_3, INV_SQRT_3, false, false);
}

void fov_circle(fov_settings_type *settings,
                void *map,
                void *source,
                int source_x,
                int source_y,
                int radius) {
    fov_private_data_type data;

    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;

    if (settings->shape == FOV_SHAPE_HEX) {
        if (settings->algorithm == FOV_ALGO_LARGE_ASS) {
            _hex_large_ass_fov_circle(&data);
        } else {
            _hex_fov_circle(&data);
        }
    } else {
        data.heights = (radius < 33) ? heights_tables[settings->shape] + (radius*(radius-1) / 2 - 1) : NULL;
        if (settings->algorithm == FOV_ALGO_LARGE_ASS) {
            _large_ass_fov_circle(&data);
        } else {
            _fov_circle(&data);
        }
    }
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

#define BEAM_ANY_DIRECTION(offset, p1, p2, p3, p4, p5, p6, p7, p8)                                \
    angle_begin -= offset;                                                                        \
    angle_end -= offset;                                                                          \
    start_slope = angle_begin;                                                                    \
    end_slope = betweenf(angle_end, 0.0f, 1.0f);                                                  \
    fov_octant_##p1(&data, 1, start_slope, end_slope, false, false, true, true);                  \
                                                                                                  \
    if (angle_end - 1.0f > FLT_EPSILON) {                                                         \
        start_slope = betweenf(2.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p2(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 2.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p3(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(4.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p4(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 4.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p5(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(6.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p6(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 6.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p7(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(8.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p8(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 8.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p1(&data, 1, 0.0f, end_slope, false, false, false, false);                   \
    }}}}}}}}

#define BEAM_ANY_DIRECTION_DIAG(offset, p1, p2, p3, p4, p5, p6, p7, p8)                           \
    angle_begin -= offset;                                                                        \
    angle_end -= offset;                                                                          \
    start_slope = betweenf(1.0f - angle_end, 0.0f, 1.0f);                                         \
    end_slope = 1.0f - angle_begin;                                                               \
    fov_octant_##p1(&data, 1, start_slope, end_slope, false, false, true, true);                  \
                                                                                                  \
    if (angle_end - 1.0f > FLT_EPSILON) {                                                         \
        end_slope = betweenf(angle_end - 1.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p2(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(3.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p3(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 3.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p4(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(5.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p5(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 5.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p6(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(7.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p7(&data, 1, start_slope, 1.0f, false, false, true, false);                  \
                                                                                                  \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 7.0f, 0.0f, 1.0f);                                       \
        fov_octant_##p8(&data, 1, 0.0f, end_slope, false, false, false, true);                    \
                                                                                                  \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(9.0f - angle_end, 0.0f, 1.0f);                                     \
        fov_octant_##p1(&data, 1, start_slope, 1.0f, false, false, false, false);                 \
}}}}}}}}

#define LARGE_ASS_BEAM_ANY_DIRECTION(offset, p1, p2, p3, p4, p5, p6, p7, p8)                      \
    angle_begin -= offset;                                                                        \
    angle_end -= offset;                                                                          \
    start_slope = angle_begin;                                                                    \
    end_slope = betweenf(angle_end, 0.0f, 2.0f);                                                  \
    large_ass_fov_octant_zero_##p1(&data, start_slope, end_slope,  true,  true);                  \
                                                                                                  \
    if (angle_end - 1.0f > FLT_EPSILON) {                                                         \
        start_slope = betweenf(2.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p2(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 2.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p3(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(4.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p4(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 4.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p5(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(6.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p6(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p7(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(8.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p8(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 8.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p1(&data, 0.0f, end_slope,    false, false);                  \
    }}}}}}}}

#define LARGE_ASS_BEAM_ANY_DIRECTION_DIAG(offset, p1, p2, p3, p4, p5, p6, p7, p8)                 \
    angle_begin -= offset;                                                                        \
    angle_end -= offset;                                                                          \
    start_slope = betweenf(1.0f - angle_end, 0.0f, 1.0f);                                         \
    end_slope = 1.0f - angle_begin;                                                               \
    large_ass_fov_octant_zero_##p1(&data, start_slope, end_slope,  true,  true);                  \
                                                                                                  \
    if (angle_end - 1.0f > FLT_EPSILON) {                                                         \
        end_slope = betweenf(angle_end - 1.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p2(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 2.0f > 2.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(3.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p3(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 3.0f > 3.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 3.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p4(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 4.0f > 4.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(5.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p5(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 5.0f > 5.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 5.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p6(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 6.0f > 6.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(7.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p7(&data, start_slope, 2.0f,   true, false);                  \
                                                                                                  \
    if (angle_end - 7.0f > 7.0f * FLT_EPSILON) {                                                  \
        end_slope = betweenf(angle_end - 7.0f, 0.0f, 2.0f);                                       \
        large_ass_fov_octant_zero_##p8(&data, 0.0f, end_slope,    false,  true);                  \
                                                                                                  \
    if (angle_end - 8.0f > 8.0f * FLT_EPSILON) {                                                  \
        start_slope = betweenf(9.0f - angle_end, 0.0f, 1.0f);                                     \
        large_ass_fov_octant_zero_##p1(&data, start_slope, 2.0f,  false, false);                  \
}}}}}}}}

void fov_beam_any_angle(fov_settings_type *settings, void *map, void *source,
                        int source_x, int source_y, int radius, int sx, int sy,
                        float dx, float dy, float beam_angle) {

    /* Note: angle_begin and angle_end are misnomers, since FoV calculation uses slopes, not angles.
     * We previously used a tan(x) ~ 4/pi*x approximation * for x in range (0, pi/4) radians, or 45 degrees.
     * We no longer use this approximation.  Angles and slopes are calculated precisely,
     * so this function can be used for numerically precise purposes if desired.
     */

    fov_private_data_type data;
    float start_slope, end_slope, angle_begin, angle_end, x_start, y_start, x_end, y_end, y_min, y_max;

    if (beam_angle <= 0.0f) {
        return;
    } else if (beam_angle >= 360.0f) {
        fov_circle(settings, map, source, source_x, source_y, radius);
        return;
    }

    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;

    if (settings->shape == FOV_SHAPE_HEX) {
        /* time for some slightly odd conventions.  We're assuming that dx and dy are still in coordinate space so
         * that "source_x + dx" gives the target tile coordinate.  dx, dy are floats, so we have sub-tile resolution.
         * We will then calculate the "real space" x's and y's to allow beam-casting at any angle. */
        dy += (float)(((int)(abs(dx) + 0.5f)) & 1) * (0.5f - (float)(sx & 1));
        dx *= SQRT_3_2;
    } else {
        data.heights = (radius < 33) ? heights_tables[settings->shape] + (radius*(radius-1) / 2 - 1) : NULL;
    }

    beam_angle = 0.5f * DtoR * beam_angle;
    x_start = cos(beam_angle)*dx + sin(beam_angle)*dy;
    y_start = cos(beam_angle)*dy - sin(beam_angle)*dx;
    x_end   = cos(beam_angle)*dx - sin(beam_angle)*dy;
    y_end   = cos(beam_angle)*dy + sin(beam_angle)*dx;

    if (y_start > 0.0f) {
        if (x_start > 0.0f) {                      /* octant 1 */               /* octant 2 */
            angle_begin = ( y_start <  x_start) ? (y_start / x_start)        : (2.0f - x_start / y_start);
        } else {                                   /* octant 3 */               /* octant 4 */
            angle_begin = (-x_start <  y_start) ? (2.0f - x_start / y_start) : (4.0f + y_start / x_start);
        }
    } else {
        if (x_start < 0.0f) {                      /* octant 5 */               /* octant 6 */
            angle_begin = (-y_start < -x_start) ? (4.0f + y_start / x_start) : (6.0f - x_start / y_start);
        } else {                                   /* octant 7 */               /* octant 8 */
            angle_begin = ( x_start < -y_start) ? (6.0f - x_start / y_start) : (8.0f + y_start / x_start);
        }
    }

    if (y_end > 0.0f) {
        if (x_end > 0.0f) {                  /* octant 1 */           /* octant 2 */
            angle_end = ( y_end <  x_end) ? (y_end / x_end)        : (2.0f - x_end / y_end);
        } else {                             /* octant 3 */           /* octant 4 */
            angle_end = (-x_end <  y_end) ? (2.0f - x_end / y_end) : (4.0f + y_end / x_end);
        }
    } else {
        if (x_end < 0.0f) {                  /* octant 5 */           /* octant 6 */
            angle_end = (-y_end < -x_end) ? (4.0f + y_end / x_end) : (6.0f - x_end / y_end);
        } else {                             /* octant 7 */           /* octant 8 */
            angle_end = ( x_end < -y_end) ? (6.0f - x_end / y_end) : (8.0f + y_end / x_end);
        }
    }

    if (angle_end < angle_begin) {
        angle_end += 8.0f;
    }

    if (settings->shape == FOV_SHAPE_HEX) {
        if (angle_begin > 8.0f - INV_SQRT_3) {
            angle_begin -= 8.0f;
            angle_end -= 8.0f;
        }

        if(angle_begin < INV_SQRT_3) {
            /* east */
            start_slope = angle_begin;
            end_slope = betweenf(angle_end, -INV_SQRT_3, INV_SQRT_3);
            hex_fov_sextant_e(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - INV_SQRT_3 > FLT_EPSILON) {
                start_slope = betweenf(2.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, true, false);

                if (angle_end - 2.0f > 2.0f*FLT_EPSILON) {
                    end_slope = betweenf(angle_end - 2.0f, 0.0f, 2.0f - INV_SQRT_3);
                    if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                    hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, true);

                    if (angle_end - 4.0f + INV_SQRT_3 > 3.0f*FLT_EPSILON) {
                        start_slope = betweenf(4.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                        hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, true, false);

                        if (angle_end - 4.0f - INV_SQRT_3 > 5.0f*FLT_EPSILON) {
                            start_slope = betweenf(6.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                            hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, true, false);

                            if (angle_end - 6.0f > 6.0f*FLT_EPSILON) {
                                end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
                                if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                                hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, true);

                                if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                                    end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                                    hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, false);
            }   }   }   }   }   }
        } else if (angle_begin < 2.0f) {
            /* north-east */
            start_slope = betweenf(2.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
            end_slope = betweenf(2.0f - angle_begin, 0.0f, 2.0f - INV_SQRT_3);
            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
            hex_fov_sextant_ne(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - 2.0f > 2.0f*FLT_EPSILON) {
                end_slope = betweenf(angle_end - 2.0f, 0.0f, 2.0f - INV_SQRT_3);
                if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, true);

                if (angle_end - 4.0f + INV_SQRT_3 > 3.0f*FLT_EPSILON) {
                    start_slope = betweenf(4.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                    hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, true, false);

                    if (angle_end - 4.0f - INV_SQRT_3 > 5.0f*FLT_EPSILON) {
                        start_slope = betweenf(6.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                        if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                        hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, true, false);

                        if (angle_end - 6.0f > 6.0f*FLT_EPSILON) {
                            end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
                            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                            hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, true);

                            if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                                end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                                hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, true);

                                if (angle_end - 8.0f - INV_SQRT_3 > 8.0f*FLT_EPSILON) {
                                    start_slope = betweenf(10.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                                    if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                                    hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, false, false);
            }   }   }   }   }   }
        } else if (angle_begin < 4.0f - INV_SQRT_3) {
            /* north-west */
            start_slope = betweenf(angle_begin - 2.0f, 0.0f, 2.0f - INV_SQRT_3);
            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
            end_slope = betweenf(angle_end - 2.0f, 0.0f, 2.0f - INV_SQRT_3);
            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
            hex_fov_sextant_nw(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - 4.0f + INV_SQRT_3 > 3.0f*FLT_EPSILON) {
                start_slope = betweenf(4.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, true, false);

                if (angle_end - 4.0f - INV_SQRT_3 > 5.0f*FLT_EPSILON) {
                    start_slope = betweenf(6.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                    if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                    hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, true, false);

                    if (angle_end - 6.0f > 6.0f*FLT_EPSILON) {
                        end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
                        if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                        hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, true);

                        if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                            end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                            hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, true);

                            if (angle_end - 8.0f - INV_SQRT_3 > 8.0f*FLT_EPSILON) {
                                start_slope = betweenf(10.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                                if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                                hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, true, false);

                                if (angle_end - 10.0f > 10.0f*FLT_EPSILON) {
                                    end_slope = betweenf(angle_end - 10.0f, 0.0f, 2.0f - INV_SQRT_3);
                                    if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                                    hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, false);
            }   }   }   }   }   }
        } else if (angle_begin < 4.0f + INV_SQRT_3) {
            /* west */
            start_slope = betweenf(4.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
            end_slope = betweenf(4.0f - angle_begin, -INV_SQRT_3, INV_SQRT_3);
            hex_fov_sextant_w(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - 4.0f - INV_SQRT_3 > 5.0f*FLT_EPSILON) {
                start_slope = betweenf(6.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, true, false);

                if (angle_end - 6.0f > 6.0f*FLT_EPSILON) {
                    end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
                    if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                    hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, true);

                    if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                        end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                        hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, true);

                        if (angle_end - 8.0f - INV_SQRT_3 > 8.0f*FLT_EPSILON) {
                            start_slope = betweenf(10.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                            hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, true, false);

                            if (angle_end - 10.0f > 10.0f*FLT_EPSILON) {
                                end_slope = betweenf(angle_end - 10.0f, 0.0f, 2.0f - INV_SQRT_3);
                                if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                                hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, true);

                                if (angle_end - 12.0f + INV_SQRT_3 > 11.0f*FLT_EPSILON) {
                                    start_slope = betweenf(12.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                                    hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, false, false);
            }   }   }   }   }   }
        } else if (angle_begin < 6.0f) {
            /* south-west */
            start_slope = betweenf(6.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
            end_slope = betweenf(6.0f - angle_begin, 0.0f, 2.0f - INV_SQRT_3);
            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
            hex_fov_sextant_sw(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - 6.0f > 6.0f*FLT_EPSILON) {
                end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
                if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, true);

                if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                    end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                    hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, true);

                    if (angle_end - 8.0f - INV_SQRT_3 > 8.0f*FLT_EPSILON) {
                        start_slope = betweenf(10.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                        if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                        hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, true, false);

                        if (angle_end - 10.0f > 10.0f*FLT_EPSILON) {
                            end_slope = betweenf(angle_end - 10.0f, 0.0f, 2.0f - INV_SQRT_3);
                            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                            hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, true);

                            if (angle_end - 12.0f + INV_SQRT_3 > 11.0f*FLT_EPSILON) {
                                start_slope = betweenf(12.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                                hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, true, false);

                                if (angle_end - 12.0f - INV_SQRT_3 > 12.0f*FLT_EPSILON) {
                                    start_slope = betweenf(14.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                                    if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                                    hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, false, false);
            }   }   }   }   }   }
        } else if (angle_begin < 8.0f - INV_SQRT_3) {
            /* south-east */
            start_slope = betweenf(angle_begin - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
            if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
            end_slope = betweenf(angle_end - 6.0f, 0.0f, 2.0f - INV_SQRT_3);
            if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
            hex_fov_sextant_se(&data, 1, start_slope, end_slope, true, true);

            if (angle_end - 8.0f + INV_SQRT_3 > 7.0f*FLT_EPSILON) {
                end_slope = betweenf(angle_end - 8.0f, -INV_SQRT_3, INV_SQRT_3);
                hex_fov_sextant_e(&data, 1, -INV_SQRT_3, end_slope, false, true);

                if (angle_end - 8.0f - INV_SQRT_3 > 8.0f*FLT_EPSILON) {
                    start_slope = betweenf(10.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                    if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                    hex_fov_sextant_ne(&data, 1, start_slope, SQRT_3, true, false);

                    if (angle_end - 10.0f > 10.0f*FLT_EPSILON) {
                        end_slope = betweenf(angle_end - 10.0f, 0.0f, 2.0f - INV_SQRT_3);
                        if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                        hex_fov_sextant_nw(&data, 1, 0.0f, end_slope, false, true);

                        if (angle_end - 12.0f + INV_SQRT_3 > 11.0f*FLT_EPSILON) {
                            start_slope = betweenf(12.0f - angle_end, -INV_SQRT_3, INV_SQRT_3);
                            hex_fov_sextant_w(&data, 1, start_slope, INV_SQRT_3, true, false);

                            if (angle_end - 12.0f - INV_SQRT_3 > 12.0f*FLT_EPSILON) {
                                start_slope = betweenf(14.0f - angle_end, 0.0f, 2.0f - INV_SQRT_3);
                                if (start_slope > 1.0f) start_slope = 1.0f / (2.0f - start_slope);
                                hex_fov_sextant_sw(&data, 1, start_slope, SQRT_3, true, false);

                                if (angle_end - 14.0f > 14.0f*FLT_EPSILON) {
                                    end_slope = betweenf(angle_end - 14.0f, 0.0f, 2.0f - INV_SQRT_3);
                                    if (end_slope > 1.0f) end_slope = 1.0f / (2.0f - end_slope);
                                    hex_fov_sextant_se(&data, 1, 0.0f, end_slope, false, false);
            }   }   }   }   }   }
        }
    } else if (settings->algorithm == FOV_ALGO_LARGE_ASS) {
        if (1.0f - angle_begin > FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION(0.0f, ppn, ppy, pmy, mpn, mmn, mmy, mpy, pmn);
        } else if (2.0f - angle_begin > 2.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION_DIAG(1.0f, ppy, pmy, mpn, mmn, mmy, mpy, pmn, ppn);
        } else if (3.0f - angle_begin > 3.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION(2.0f, pmy, mpn, mmn, mmy, mpy, pmn, ppn, ppy);
        } else if (4.0f - angle_begin > 4.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION_DIAG(3.0f, mpn, mmn, mmy, mpy, pmn, ppn, ppy, pmy);
        } else if (5.0f - angle_begin > 5.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION(4.0f, mmn, mmy, mpy, pmn, ppn, ppy, pmy, mpn);
        } else if (6.0f - angle_begin > 6.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION_DIAG(5.0f, mmy, mpy, pmn, ppn, ppy, pmy, mpn, mmn);
        } else if (7.0f - angle_begin > 7.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION(6.0f, mpy, pmn, ppn, ppy, pmy, mpn, mmn, mmy);
        } else if (8.0f - angle_begin > 8.0f * FLT_EPSILON) {
            LARGE_ASS_BEAM_ANY_DIRECTION_DIAG(7.0f, pmn, ppn, ppy, pmy, mpn, mmn, mmy, mpy);
        }
    } else {
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
}


#define LARGE_ASS_LOS_FINISH(do_blocked, signy, rx, ry)                                           \
    fdx = (float)line->dest_t;                                                                    \
    fdy = (float)delta_y;                                                                         \
    rx = dest_##rx;                                                                               \
    ly0 = lower_blen;                                                                             \
    uy0 = upper_blen;                                                                             \
    if ((int)(lower_start_y + fdx*lower_slope + GRID_EPSILON) < delta_y) {                        \
        ry = dest_##ry;                                                                           \
                                                                                                  \
        GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, true)                                      \
                                                                                                  \
        /* now set lowers */                                                                      \
        ly0 = next_blen - 3;                                                                      \
        lower_blen = next_blen;                                                                   \
        lower_slope = next_slope;                                                                 \
        lower_start_y = next_start_y;                                                             \
        lower_boundaries = next_boundaries;                                                       \
    }                                                                                             \
    if ((int)(upper_start_y + fdx*upper_slope - GRID_EPSILON) > delta_y) {                        \
        ry = dest_##ry signy 1;                                                                   \
        fdy = (float)(delta_y + 1);                                                               \
                                                                                                  \
        GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                                       \
                                                                                                  \
        /* now set uppers */                                                                      \
        uy0 = next_blen - 3;                                                                      \
        upper_slope = next_slope;                                                                 \
        upper_start_y = next_start_y;                                                             \
        fdy = (float)delta_y;                                                                     \
    }                                                                                             \
                                                                                                  \
    /* Calculate the best line to target (a simple average can make weird lines at times). */     \
    /* This minimizes distance squared from the line to the center of source and target tile. */  \
    /* Let's hope I (and nobody else) ever needs to touch this again ;-) */                       \
    /* On the other hand, this would probably be done better if it were redone :-P */             \
    slope = upper_start_y + fdx*upper_slope;                                                      \
    next_slope = lower_start_y + fdx*lower_slope;                                                 \
    next_start_y = -2.0f*fdx*(upper_start_y*lower_slope +                                         \
                         lower_start_y*upper_slope +                                              \
                         fdx*lower_slope*upper_slope)                                             \
                   - 4.0f*lower_start_y*upper_start_y;                                            \
    slope = upper_start_y*upper_start_y + slope*slope;                                            \
    prev_slope = lower_start_y - upper_start_y + fdx*lower_slope - fdx*upper_slope;               \
                                                                                                  \
    next_slope = slope + next_start_y + next_slope*next_slope + lower_start_y*lower_start_y;      \
    prev_slope = 2.0f*slope + next_start_y + 2.0f*fdy*prev_slope + prev_slope + lower_start_y - upper_start_y; \
                                                                                                  \
    if (next_slope > GRID_EPSILON || next_slope < -GRID_EPSILON) {                                \
        slope = 0.5f * prev_slope / next_slope;                                                   \
        if (slope < 0.1f) {                                                                       \
            slope = 0.1f;                                                                         \
        } else if (slope > 0.9f) {                                                                \
            slope = 0.9f;                                                                         \
        }                                                                                         \
        line->step_##ry = signy (slope*lower_slope + (1.0f - slope)*upper_slope);                 \
        line->start_##ry = slope*lower_start_y + (1.0f - slope)*upper_start_y;                    \
    } else {                                                                                      \
        line->step_##ry = signy 0.5f*(lower_slope + upper_slope);                                 \
        line->start_##ry = 0.5f*(lower_start_y + upper_start_y);                                  \
    }                                                                                             \
    if (line->start_##ry > y_max) {                                                               \
        line->start_##ry = y_max;                                                                 \
    }                                                                                             \
    if (do_blocked) {                                                                             \
        line->is_blocked = true;                                                                  \
        line->block_t = line->dest_t - delta;                                                     \
                                                                                                  \
        if (ly0 > 0) {                                                                            \
            if (uy0 > 0) { /* gotta iterate over constraints and set eps to maximize line */      \
                slope = fabs(line->step_##ry / line->step_##rx);                                  \
                boundary = upper_boundaries;                                                      \
                ptr_end = upper_boundaries + uy0;                                                 \
                do {                                                                              \
                    if (boundary[Y] - line->start_##ry - slope*boundary[X] < GRID_EPSILON) {      \
                        fdt = boundary[X];                                                        \
                        break;                                                                    \
                    }                                                                             \
                    boundary += 3;                                                                \
                } while (boundary != ptr_end);                                                    \
                                                                                                  \
                boundary = lower_boundaries;                                                      \
                ptr_end = lower_boundaries + ly0;                                                 \
                do {                                                                              \
                    if (boundary[X] - fdt > GRID_EPSILON) {                                       \
                        break;                                                                    \
                    }                                                                             \
                    if (line->start_##ry + slope*boundary[X] - boundary[Y] < GRID_EPSILON) {      \
                        line->eps_##ry = signy 2.0f * GRID_EPSILON;                               \
                        break;                                                                    \
                    }                                                                             \
                    boundary += 3;                                                                \
                } while (boundary != ptr_end);                                                    \
                                                                                                  \
            } else {                                                                              \
                line->eps_##ry = signy 2.0f * GRID_EPSILON;                                       \
            }                                                                                     \
        }                                                                                         \
    } else if (ly0 > 0) {                                                                         \
        line->eps_##ry = signy (-0.5f * GRID_EPSILON);                                            \
        slope = fabs(line->step_##ry / line->step_##rx);                                          \
        if (uy0 > 0) { /* gotta iterate over constraints and set eps to maximize line */          \
            boundary = upper_boundaries;                                                          \
            ptr_end = upper_boundaries + uy0;                                                     \
            do {                                                                                  \
                if (boundary[Y] - line->start_##ry - slope*boundary[X] < GRID_EPSILON) {          \
                    fdt = boundary[X];                                                            \
                    break;                                                                        \
                }                                                                                 \
                boundary += 3;                                                                    \
            } while (boundary != ptr_end);                                                        \
        }                                                                                         \
        boundary = lower_boundaries;                                                              \
        ptr_end = lower_boundaries + ly0;                                                         \
        do {                                                                                      \
            if (boundary[X] - fdt > GRID_EPSILON) {                                               \
                break;                                                                            \
            }                                                                                     \
            if (line->start_##ry + slope*boundary[X] - boundary[Y] < GRID_EPSILON) {              \
                line->eps_##ry = signy 2.0f * GRID_EPSILON;                                       \
                break;                                                                            \
            }                                                                                     \
            boundary += 3;                                                                        \
        } while (boundary != ptr_end);                                                            \
    }                                                                                             \
                                                                                                  \
    if (signy line->step_##ry - 1.0f > GRID_EPSILON) { /* unblocked diagonal */                   \
        line->start_##ry = 0.5f;                                                                  \
        line->step_##ry = signy 1.0f;                                                             \
        line->eps_##ry = 0.0f;                                                                    \
    } else if ((int)(line->start_##ry signy fdx*line->step_##ry - GRID_EPSILON) < delta_y) {      \
        line->eps_##ry = signy 0.5f * GRID_EPSILON;  /* is this still necessary? */               \
    }                                                                                             \


#define LARGE_ASS_LOS_DEFINE_OCTANT(signx, signy, rx, ry, nx, ny, nf)                             \
    static void large_ass_los_octant_##nx##ny##nf(                                                \
                                        fov_settings_type *settings,                              \
                                        fov_line_data *line,                                      \
                                        void *map,                                                \
                                        int dest_x,                                               \
                                        int dest_y                                                \
        ) {                                                                                       \
        int x, y, ly0, ly1, uy0, uy1, lc0, lc1, uc0, uc1, next_blen;                              \
        int dx = 0, lower_blen = 0, upper_blen = 0;                                               \
        int delta = signx (dest_##rx - line->source_##rx);                                        \
        int delta_y = signy (dest_##ry - line->source_##ry);                                      \
        fov_buffer_type *buffer_data = settings->buffer_data;                                     \
        float next_slope, prev_slope, slope, next_start_y;                                        \
        float y_min = 0.5f - settings->actor_vision_size;                                         \
        float y_max = 0.5f + settings->actor_vision_size;                                         \
        float fdx = signx (float)(dest_##rx - line->source_##rx);                                 \
        float fdy = signy (float)(dest_##ry - line->source_##ry);                                 \
        float fdt = (float)delta;                                                                 \
        float lower_start_y = y_min;                                                              \
        float upper_start_y = y_max;                                                              \
        float pms = settings->permissiveness;                                                     \
        float lower_slope = 0.0f;                                                                 \
        float upper_slope = 2.0f;                                                                 \
        float slope_min = (fdy - y_min) / fdx;                                                    \
        float slope_max = (fdy + 1.0f - y_max) / fdx;                                             \
        float *boundary, *lower_boundaries, *upper_boundaries,                                    \
              *next_boundaries, *prev_boundary, *ptr_end;                                         \
        bool is_first;                                                                            \
                                                                                                  \
        rx = line->source_##rx;                                                                   \
        line->step_##rx = signx 1.0f;                                                             \
        line->start_##rx = 0.5f;                                                                  \
        line->eps_##rx = 0.0f;                                                                    \
        line->eps_##ry = signy (-2.0f * GRID_EPSILON);                                            \
        line->dest_t = delta;                                                                     \
                                                                                                  \
        /* check upper when dx == 0 */                                                            \
        if (y_max + upper_slope * pms - 1.0f > GRID_EPSILON) {                                    \
            ry = line->source_##ry signy 1;                                                       \
            if (settings->opaque(map, x, y)) {                                                    \
                slope = (1.0f - y_min) / pms;                                                     \
                if (slope - upper_slope < GRID_EPSILON) {                                         \
                    upper_slope = slope;                                                          \
                }                                                                                 \
                GET_BUFFER(upper_boundaries, buffer_data, 3)                                      \
                upper_boundaries[X] = pms;                                                        \
                upper_boundaries[Y] = 1.0f;                                                       \
                upper_boundaries[K] = (1.0f - y_max) / pms;                                       \
                upper_start_y = 1.0f - upper_slope * pms;                                         \
                upper_blen = 3;                                                                   \
            }                                                                                     \
        }                                                                                         \
                                                                                                  \
        for (;;) {                                                                                \
            if (--delta < 0) {                                                                    \
                LARGE_ASS_LOS_FINISH(false, signy, rx, ry)                                        \
                return;                                                                           \
            }                                                                                     \
            dx += 1;                                                                              \
            rx = rx signx 1;                                                                      \
            fdx = (float)dx;                                                                      \
                                                                                                  \
            ly0 = (int)(lower_start_y + (fdx - pms)*lower_slope + GRID_EPSILON); /* lower L */    \
            lc0 = (int)(y_min + (fdx - pms)*slope_min + GRID_EPSILON);     /* lower boundary */   \
            ly1 = (int)(lower_start_y + (fdx + pms)*lower_slope + GRID_EPSILON); /* lower R */    \
            lc1 = (int)(y_min + (fdx + pms)*slope_min + GRID_EPSILON); /* lower constraint */     \
                                                                                                  \
            uy0 = (int)(upper_start_y + (fdx - pms)*upper_slope - GRID_EPSILON); /* upper L */    \
            uc0 = (int)(y_max + (fdx - pms)*slope_max - GRID_EPSILON); /* upper constraint */     \
            uy1 = (int)(upper_start_y + (fdx + pms)*upper_slope - GRID_EPSILON); /* upper R */    \
            uc1 = (int)(y_max + (fdx + pms)*slope_max - GRID_EPSILON);     /* upper boundary */   \
                                                                                                  \
            if (ly0 < lc0) {                                                                      \
                ly0 = lc0;                                                                        \
            }                                                                                     \
            if (ly1 < lc1) {                                                                      \
                ly1 = lc1;                                                                        \
            }                                                                                     \
            if (uy0 > uc0) {                                                                      \
                uy0 = uc0;                                                                        \
            }                                                                                     \
            if (uy1 > uc1) {                                                                      \
                uy1 = uc1;                                                                        \
            }                                                                                     \
                                                                                                  \
            ry = line->source_##ry signy ly0;                                                     \
            if (settings->opaque(map, x, y)) {                                                    \
                if (ly0 == uy0 &&                                                                 \
                    (upper_blen == 0 || fdx - upper_boundaries[upper_blen - 3 + X] - 0.5f > GRID_EPSILON)) \
                {                                                                                 \
                    /* BLOCKED */                                                                 \
                    if (delta || ly0 != delta_y) {                                                \
                        LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                 \
                    } else {                                                                      \
                        LARGE_ASS_LOS_FINISH(false, signy, rx, ry)                                \
                    }                                                                             \
                    return;                                                                       \
                }                                                                                 \
                /* CALC LOWER SLOPE */                                                            \
                fdy = (float)(ly0 + 1);                                                           \
                fdx -= pms;                                                                       \
                                                                                                  \
                GET_NEXT_LARGE_ASS_DATA(max, min, upp, low, -, true)                              \
                                                                                                  \
                if ((int)(next_start_y + fdt*next_slope + GRID_EPSILON) > delta_y ||              \
                    upper_slope - next_slope < GRID_EPSILON)                                      \
                {                                                                                 \
                    LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                     \
                    return;                                                                       \
                }                                                                                 \
                                                                                                  \
                /* now set lowers */                                                              \
                lower_blen = next_blen;                                                           \
                lower_slope = next_slope;                                                         \
                lower_start_y = next_start_y;                                                     \
                lower_boundaries = next_boundaries;                                               \
                                                                                                  \
                ry = line->source_##ry signy uy0;                                                 \
                if (ly0 != uy0 && settings->opaque(map, x, y)) {                                  \
                    /* BLOCKED */                                                                 \
                    if (delta) {                                                                  \
                        LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                 \
                    } else {                                                                      \
                        LARGE_ASS_LOS_FINISH(false, signy, rx, ry)                                \
                    }                                                                             \
                    return;                                                                       \
                }                                                                                 \
                                                                                                  \
                /* done setting lower slope, now set upper slope if necessary */                  \
                ry = line->source_##ry signy uy1;                                                 \
                if (delta && uy0 != uy1 && settings->opaque(map, x, y)) {                         \
                    /* CALC UPPER SLOPE */                                                        \
                    fdy = (float)uy1;                                                             \
                    fdx += 2.0f * pms;                                                            \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                           \
                                                                                                  \
                    if ((int)(next_start_y + fdt*next_slope - GRID_EPSILON) < delta_y ||          \
                        next_slope - lower_slope < GRID_EPSILON)                                  \
                    {                                                                             \
                        LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                 \
                        return;                                                                   \
                    }                                                                             \
                                                                                                  \
                    /* now set uppers */                                                          \
                    upper_slope = next_slope;                                                     \
                    upper_start_y = next_start_y;                                                 \
                    upper_boundaries = next_boundaries;                                           \
                    upper_blen = next_blen;                                                       \
                }                                                                                 \
                continue;                                                                         \
            }                                                                                     \
            ry = line->source_##ry signy uy1;                                                     \
            if (ly0 != uy1 && settings->opaque(map, x, y)) {                                      \
                ry = line->source_##ry signy ly1;                                                 \
                if (uy1 == ly1 || ly0 != ly1 && settings->opaque(map, x, y)) {                    \
                    /* BLOCKED */                                                                 \
                    if (delta) {                                                                  \
                        LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                 \
                    } else {                                                                      \
                        LARGE_ASS_LOS_FINISH(false, signy, rx, ry)                                \
                    }                                                                             \
                    return;                                                                       \
                } else if(delta) {                                                                \
                    /* CALC UPPER SLOPE */                                                        \
                    fdy = (float)uy1;                                                             \
                    fdx += pms;                                                                   \
                                                                                                  \
                    GET_NEXT_LARGE_ASS_DATA(min, max, low, upp, , true)                           \
                                                                                                  \
                    if ((int)(next_start_y + fdt*next_slope - GRID_EPSILON) < delta_y) {          \
                        LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                 \
                        return;                                                                   \
                    }                                                                             \
                    /* now set uppers */                                                          \
                    upper_slope = next_slope;                                                     \
                    upper_start_y = next_start_y;                                                 \
                    upper_boundaries = next_boundaries;                                           \
                    upper_blen = next_blen;                                                       \
                }                                                                                 \
                continue;                                                                         \
            }                                                                                     \
            ry = line->source_##ry signy (ly0 + 1);                                               \
            if (ly0 + 2 == uy1 && settings->opaque(map, x, y)) {                                  \
                /* BLOCKED */                                                                     \
                if (delta) {                                                                      \
                    LARGE_ASS_LOS_FINISH(true, signy, rx, ry)                                     \
                } else {                                                                          \
                    LARGE_ASS_LOS_FINISH(false, signy, rx, ry)                                    \
                }                                                                                 \
                return;                                                                           \
            }                                                                                     \
        }                                                                                         \
    }

LARGE_ASS_LOS_DEFINE_OCTANT(+,+,x,y,p,p,n)
LARGE_ASS_LOS_DEFINE_OCTANT(+,+,y,x,p,p,y)
LARGE_ASS_LOS_DEFINE_OCTANT(+,-,x,y,p,m,n)
LARGE_ASS_LOS_DEFINE_OCTANT(+,-,y,x,p,m,y)
LARGE_ASS_LOS_DEFINE_OCTANT(-,+,x,y,m,p,n)
LARGE_ASS_LOS_DEFINE_OCTANT(-,+,y,x,m,p,y)
LARGE_ASS_LOS_DEFINE_OCTANT(-,-,x,y,m,m,n)
LARGE_ASS_LOS_DEFINE_OCTANT(-,-,y,x,m,m,y)

#define HEX_LOS_DEFINE_SEXTANT(signx, signy, nx, ny, one)                                         \
    static void hex_los_sextant_##nx##ny(                                                         \
                                        fov_private_data_type *data,                              \
                                        hex_fov_line_data *line,                                  \
                                        float start_slope,                                        \
                                        float target_slope,                                       \
                                        float end_slope) {                                        \
        int x, y, x0, x1, p;                                                                      \
        int dy = 1;                                                                               \
        int delta = line->dest_t - 1;                                                             \
        bool prev_blocked;                                                                        \
        float fx0, fx1, fdx0, fdx1;                                                               \
        float fdy = 1.0f;                                                                         \
        fov_settings_type *settings = data->settings;                                             \
                                                                                                  \
        fdx0 = start_slope / (SQRT_3_2 + 0.5f*start_slope);                                       \
        fdx1 = end_slope / (SQRT_3_2 + 0.5f*end_slope);                                           \
                                                                                                  \
        fx0 = 0.5f + fdx0 + GRID_EPSILON;                                                         \
        fx1 = 0.5f + fdx1 - GRID_EPSILON;                                                         \
        x0 = (int)fx0;                                                                            \
        x1 = (int)fx1;                                                                            \
        x = data->source_x signx x0;                                                              \
        p = ((x & 1) + one) & 1;                                                                  \
        y = data->source_y signy (1 - (x0 + 1 - p)/2);                                            \
                                                                                                  \
        for (;;) {                                                                                \
            if (--delta < 0) {                                                                    \
                line->step_x = signx target_slope / (INV_SQRT_3*target_slope + 1.0f);             \
                line->step_y = signy 1.0f / (INV_SQRT_3*target_slope + 1.0f);                     \
                return;                                                                           \
            }                                                                                     \
            prev_blocked = settings->opaque(data->map, x, y);                                     \
            ++x0;                                                                                 \
            y = y signy (-p);                                                                     \
            x = x signx 1;                                                                        \
            if (x0 == x1) {                                                                       \
                if (settings->opaque(data->map, x, y)) {                                          \
                    if (prev_blocked) {                                                           \
                        line->step_x = signx target_slope / (INV_SQRT_3*target_slope + 1.0f);     \
                        line->step_y = signy 1.0f / (INV_SQRT_3*target_slope + 1.0f);             \
                        line->is_blocked = true;                                                  \
                        line->block_t = line->dest_t - delta - 1;                                 \
                        return;                                                                   \
                    } else {                                                                      \
                        end_slope = (-SQRT_3_4 + SQRT_3_2*(float)x0) /                            \
                                    (fdy + 0.25f - 0.5f*(float)x0);                               \
                        fdx1 = end_slope / (SQRT_3_2 + 0.5f*end_slope);                           \
                        target_slope = end_slope;                                                 \
                        fx1 = 0.5f + fdy*fdx1 - GRID_EPSILON;                                     \
                        line->eps_x = signx (-GRID_EPSILON);                                      \
                        line->eps_y = signy GRID_EPSILON;                                         \
                    }                                                                             \
                } else if (prev_blocked) {                                                        \
                    start_slope = (-SQRT_3_4 + SQRT_3_2*(float)x0) /                              \
                                  (fdy + 0.25f - 0.5f*(float)x0);                                 \
                    fdx0 = start_slope / (SQRT_3_2 + 0.5f*start_slope);                           \
                    target_slope = start_slope;                                                   \
                    fx0 = 0.5f + fdy*fdx0 + GRID_EPSILON;                                         \
                    line->eps_x = signx GRID_EPSILON;                                             \
                    line->eps_y = signy (-GRID_EPSILON);                                          \
                }                                                                                 \
            } else if (prev_blocked) {                                                            \
                line->step_x = signx target_slope / (INV_SQRT_3*target_slope + 1.0f);             \
                line->step_y = signy 1.0f / (INV_SQRT_3*target_slope + 1.0f);                     \
                line->is_blocked = true;                                                          \
                line->block_t = line->dest_t - delta - 1;                                         \
                return;                                                                           \
            }                                                                                     \
            fx0 += fdx0;                                                                          \
            fx1 += fdx1;                                                                          \
            x0 = (int)fx0;                                                                        \
            x1 = (int)fx1;                                                                        \
            x = data->source_x signx x0;                                                          \
            ++dy;                                                                                 \
            fdy += 1.0f;                                                                          \
            p = ((x & 1) + one) & 1;                                                              \
            y = data->source_y signy (dy - (x0 + 1 - p)/2);                                       \
        }                                                                                         \
    }

#define HEX_LOS_DEFINE_LR_SEXTANT(signx, nx)                                                      \
    static void hex_los_sextant_##nx(                                                             \
                                        fov_private_data_type *data,                              \
                                        hex_fov_line_data *line,                                  \
                                        float start_slope,                                        \
                                        float target_slope,                                       \
                                        float end_slope) {                                        \
        int x, y, y0, y1, p;                                                                      \
        int dx = 1;                                                                               \
        int delta = line->dest_t - 1;                                                             \
        bool prev_blocked;                                                                        \
        float fy0, fy1;                                                                           \
        float fdx = SQRT_3_2;                                                                     \
        float fdy = -1.0f;                                                                        \
        fov_settings_type *settings = data->settings;                                             \
                                                                                                  \
        x = data->source_x signx 1;                                                               \
        p = -(x & 1);                                                                             \
        fy0 = SQRT_3_2 * start_slope + 1.0f + GRID_EPSILON;                                       \
        fy1 = SQRT_3_2 * end_slope + 1.0f - GRID_EPSILON;                                         \
        y0 = (int)fy0;                                                                            \
        y1 = (int)fy1;                                                                            \
        y = data->source_y + y0 + p;                                                              \
                                                                                                  \
        for (;;) {                                                                                \
            if (--delta < 0) {                                                                    \
                line->step_y = SQRT_3_2 * target_slope;                                           \
                return;                                                                           \
            }                                                                                     \
            prev_blocked = settings->opaque(data->map, x, y);                                     \
            ++y0;                                                                                 \
            ++y;                                                                                  \
            if (y0 == y1) {                                                                       \
                if (settings->opaque(data->map, x, y)) {                                          \
                    if (prev_blocked) {                                                           \
                        line->step_y = SQRT_3_2 * target_slope;                                   \
                        line->is_blocked = true;                                                  \
                        line->block_t = line->dest_t - delta - 1;                                 \
                        return;                                                                   \
                    } else {                                                                      \
                        end_slope = ((float)y0 + fdy) / fdx;                                      \
                        fy1 = fdx*end_slope - fdy - GRID_EPSILON;                                 \
                        target_slope = end_slope;                                                 \
                        line->eps_y = -GRID_EPSILON;                                              \
                    }                                                                             \
                } else if (prev_blocked) {                                                        \
                    start_slope = ((float)y0 + fdy) / fdx;                                        \
                    fy0 = fdx*start_slope - fdy + GRID_EPSILON;                                   \
                    target_slope = start_slope;                                                   \
                    line->eps_y = GRID_EPSILON;                                                   \
                }                                                                                 \
            } else if (prev_blocked) {                                                            \
                line->step_y = SQRT_3_2 * target_slope;                                           \
                line->is_blocked = true;                                                          \
                line->block_t = line->dest_t - delta - 1;                                         \
                return;                                                                           \
            }                                                                                     \
            x = x signx 1;                                                                        \
            fdx += SQRT_3_2;                                                                      \
            fdy -= 0.5f;                                                                          \
            fy0 += SQRT_3_2*start_slope + 0.5f;                                                   \
            fy1 += SQRT_3_2*end_slope + 0.5f;                                                     \
            ++dx;                                                                                 \
            p = -dx / 2 - (dx & 1)*(x & 1);                                                       \
            y0 = (int)fy0;                                                                        \
            y1 = (int)fy1;                                                                        \
            y = data->source_y + y0 + p;                                                          \
        }                                                                                         \
    }

HEX_LOS_DEFINE_SEXTANT(+,+,n,e,1)
HEX_LOS_DEFINE_SEXTANT(-,+,n,w,1)
HEX_LOS_DEFINE_SEXTANT(+,-,s,e,0)
HEX_LOS_DEFINE_SEXTANT(-,-,s,w,0)
HEX_LOS_DEFINE_LR_SEXTANT(+,e)
HEX_LOS_DEFINE_LR_SEXTANT(-,w)

void hex_fov_create_los_line(fov_settings_type *settings, void *map, void *source, hex_fov_line_data *line,
                         int source_x, int source_y,
                         int dest_x, int dest_y,
                         bool start_at_end) {

    fov_private_data_type data;
    data.settings = settings;
    data.map = map;
    data.source_x = source_x;
    data.source_y = source_y;

    line->t = 0;
    line->is_blocked = false;
    line->start_at_end = start_at_end;
    line->source_x = SQRT_3_2 * (float)source_x + SQRT_3_4;
    line->source_y = 0.5f + (float)source_y + 0.5f*(float)(source_x & 1);

    float dx = SQRT_3_2 * (float)(dest_x - source_x);
    float dy = (float)(dest_y - source_y) + (float)((dest_x - source_x) & 1) * (0.5f - (float)(source_x & 1));
    float adx = fabs(dx);
    float ady = fabs(dy);
    float start_slope, target_slope, end_slope;

    if (dest_x == source_x && dest_y == source_y) {
        line->dest_t = 0;
        line->eps_x = 0.0f;
        line->eps_y = 0.0f;
        line->step_x = 0.0f;
        line->step_y = 0.0f;
        return;
    }

    if (SQRT_3*ady - adx < GRID_EPSILON) {
        line->eps_x = 0.0f;
        start_slope = (dy - 0.5f) / adx;
        target_slope = dy / adx;
        end_slope = (dy + 0.5f) / adx;

        if (dx > GRID_EPSILON) {
            line->eps_y = GRID_EPSILON;
            line->step_x = SQRT_3_2;
            line->dest_t = dest_x - source_x;
            hex_los_sextant_e(&data, line, start_slope, target_slope, end_slope);
        } else {
            line->eps_y = -GRID_EPSILON;
            line->step_x = -SQRT_3_2;
            line->dest_t = source_x - dest_x;
            hex_los_sextant_w(&data, line, start_slope, target_slope, end_slope);
        }
    } else {
        line->dest_t = (int)(ady + INV_SQRT_3 * adx + 0.25f);
        start_slope = (adx - SQRT_3_4) / (ady + 0.25f);
        target_slope = adx / ady;
        end_slope = (adx + SQRT_3_4) / (ady - 0.25f);

        if (dx > GRID_EPSILON) {
            line->eps_y = GRID_EPSILON;
            if (dy > 0.0f) {
                line->eps_x = -GRID_EPSILON;
                hex_los_sextant_ne(&data, line, start_slope, target_slope, end_slope);
            } else {
                line->eps_x = GRID_EPSILON;
                hex_los_sextant_se(&data, line, start_slope, target_slope, end_slope);
            }
        } else {
            line->eps_y = -GRID_EPSILON;
            if (dy > 0.0f) {
                line->eps_x = -GRID_EPSILON;
                hex_los_sextant_nw(&data, line, start_slope, target_slope, end_slope);
            } else {
                line->eps_x = GRID_EPSILON;
                hex_los_sextant_sw(&data, line, start_slope, target_slope, end_slope);
            }

        }
    }

/* simple line */
/*  if (SQRT_3*ady < adx) {
        if (dest_x > source_x) {
            line->step_x = SQRT_3_2;
            line->dest_t = dest_x - source_x;
            line->eps_y = GRID_EPSILON;
        } else {
            line->step_x = -SQRT_3_2;
            line->dest_t = source_x - dest_x;
            line->eps_y = -GRID_EPSILON;
        }
        line->eps_x = 0.0f;
        line->step_y = dy * line->step_x / dx;
    } else {
        line->dest_t = (int)(ady + INV_SQRT_3 * adx + 0.25f);
        line->step_x = dx / (float)line->dest_t;
        line->step_y = dy / (float)line->dest_t;
        line->eps_x = (dy < 0.0f) ? GRID_EPSILON : -GRID_EPSILON;
        line->eps_y = (dx > 0.0f) ? GRID_EPSILON : -GRID_EPSILON;
    }
*/
    if (start_at_end) {
        line->t = (line->is_blocked) ? line->block_t : line->dest_t;
    }
}

void fov_create_los_line(fov_settings_type *settings, void *map, void *source, fov_line_data *line,
                          int source_x, int source_y,
                          int dest_x, int dest_y,
                          bool start_at_end) {

    line->start_x = 0.5f;
    line->start_y = 0.5f;
    line->source_x = source_x;
    line->source_y = source_y;
    line->t = 0;
    line->is_blocked = false;
    line->start_at_end = start_at_end;

    if (source_x == dest_x)
    {
        line->dest_t = abs(dest_y - source_y);
        line->eps_x = 0.0f;
        line->eps_y = 0.0f;

        if (source_y == dest_y) {
            line->step_x = 0.0f;
            line->step_y = 0.0f;
            return;
        }
        /* iterate through all y */
        int dy = (dest_y < source_y) ? -1 : 1;
        int y = source_y;
        do {
            y += dy;
            if (settings->opaque(map, source_x, y)) {
                line->is_blocked = (y != dest_y);
                line->block_t = dy*(y - source_y);
                break;
            }
        } while (y != dest_y);

        line->step_x = 0.0f;
        line->step_y = (float)dy;
        if (start_at_end) {
            line->t = line->dest_t;
        }
    }
    else if (source_y == dest_y)
    {
        line->dest_t = abs(dest_x - source_x);
        line->eps_x = 0.0f;
        line->eps_y = 0.0f;

        /* iterate through all x */
        int dx = (dest_x < source_x) ? -1 : 1;
        int x = source_x;
        do {
            x += dx;
            if (settings->opaque(map, x, source_y)) {
                line->is_blocked = (x != dest_x);
                line->block_t = dx*(x - source_x);
                break;
            }
        } while (x != dest_x);

        line->step_x = (float)dx;
        line->step_y = 0.0f;
        if (start_at_end) {
            line->t = line->dest_t;
        }
    }
    else if (settings->algorithm == FOV_ALGO_LARGE_ASS)
    {
        if (dest_x > source_x) {
            if (dest_y > source_y) {
                if (dest_x - source_x > dest_y - source_y) {
                    large_ass_los_octant_ppn(settings, line, map, dest_x, dest_y);
                } else {
                    large_ass_los_octant_ppy(settings, line, map, dest_x, dest_y);
                }
            }
            else {
                if (dest_x - source_x > source_y - dest_y) {
                    large_ass_los_octant_pmn(settings, line, map, dest_x, dest_y);
                } else {
                    large_ass_los_octant_mpy(settings, line, map, dest_x, dest_y);
                }
            }
        } else {
            if (dest_y > source_y) {
                if (source_x - dest_x > dest_y - source_y) {
                    large_ass_los_octant_mpn(settings, line, map, dest_x, dest_y);
                } else {
                    large_ass_los_octant_pmy(settings, line, map, dest_x, dest_y);
                }
            } else {
                if (source_x - dest_x > source_y - dest_y) {
                    large_ass_los_octant_mmn(settings, line, map, dest_x, dest_y);
                } else {
                    large_ass_los_octant_mmy(settings, line, map, dest_x, dest_y);
                }
            }
        }
        if (start_at_end) {
            line->t = line->dest_t;
        }
    }
    else
    {
        /* hurray for a plethora of short but similar variable names!  (yeah, I'm sorry... I blame all the poorly written legacy physics code I've had to work with) */
        bool b0;                       /* true if [xy]0 is blocked */
        bool b1;                       /* true if [xy]1 is blocked */
        bool mb0;                      /* true if m[xy]0 is blocked */
        bool mb1;                      /* true if m[xy]1 is blocked */
        bool blocked_below = false;    /* true if lower_slope is bounded by an obstruction */
        bool blocked_above = false;    /* true if upper_slope is bounded by an obstruction */
        int sx = source_x;             /* source x */
        int sy = source_y;             /* source y */
        int tx = dest_x;               /* target x */
        int ty = dest_y;               /* target y */
        int dx = (tx < sx) ? -1 : 1;   /* sign of x.  Useful for taking abs(x_val) */
        int dy = (ty < sy) ? -1 : 1;   /* sign of y.  Useful for taking abs(y_val) */

        float gx = (float)dx;          /* sign of x, float.  Useful for taking fabs(x_val) */
        float gy = (float)dy;          /* sign of y, float   Useful for taking fabs(y_val) */
        float gabs = (float)(dx*dy);   /* used in place of fabs(slope_val) */
        float val, val2;

        /* Note that multiplying by dx, dy, gx, gy, or gabs are sometimes used in place of abs and fabs */
        /* I don't mind having a little (x2) code duplication--it's much better than debugging large macros :) */
        if (dx*(tx - sx) > dy*(ty - sy))
        {
            line->dest_t = dx*(tx - sx);

            int x = 0;
            int y0, y1;                /* lowest/highest possible y based on inner/outer edge of tiles and lower/upper slopes */
            int my0, my1;              /* low/high y based on the middle of tiles */
            float slope = ((float)(ty - sy)) / ((float)(tx - sx));
            float lower_slope = ((float)(ty - sy) - gy*0.5f) / ((float)(tx - sx));
            float upper_slope = ((float)(ty - sy) + gy*0.5f) / ((float)(tx - sx));
            float lower_slope_prev = lower_slope;
            float upper_slope_prev = upper_slope;

            /* include both source and dest x in loop, but don't include (source_x, source_y) or (target_x, target_y) */
            val = gx*0.5f*upper_slope + gx*GRID_EPSILON;
            y1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
            if (y1 != 0 && gabs * upper_slope > 1.0f && settings->permissiveness > 0.199f && settings->opaque(map, sx, sy + y1)) {
                val = (gy*0.5f) / (gx*settings->permissiveness);
                if (gabs * val < gabs * upper_slope) {
                    upper_slope_prev = upper_slope;
                    upper_slope = val;
                    blocked_above = true;
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
                if (blocked_below && blocked_above && gabs*(upper_slope - lower_slope) < GRID_EPSILON) {
                    val  = (float)x*lower_slope - gy*GRID_EPSILON;
                    val2 = (float)x*upper_slope - gy*GRID_EPSILON;
                } else {
                    val  = (blocked_below) ? (float)x*lower_slope + gy*GRID_EPSILON : (float)x*lower_slope - gy*GRID_EPSILON;
                    val2 = (blocked_above) ? (float)x*upper_slope - gy*GRID_EPSILON : (float)x*upper_slope + gy*GRID_EPSILON;
                }
                my0 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val -= gx*0.5f*lower_slope;
                y0  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                my1 = (val2 < 0.0f) ? -(int)(0.5f - val2) : (int)(0.5f + val2);
                val2 += gx*0.5f*upper_slope;
                y1  = (val2 < 0.0f) ? -(int)(0.5f - val2) : (int)(0.5f + val2);

                /* check if lower_slope is blocked */
                if (settings->opaque(map, sx + x, sy + my0)) {
                    b0 = true;
                    mb0 = true;
                    lower_slope_prev = lower_slope;
                    lower_slope = ((float)my0 + gy*0.5f) / ((float)x - gx*settings->permissiveness);
                    blocked_below = true;
                }
                else if (y0 != my0 && settings->opaque(map, sx + x, sy + y0)) {
                    val = ((float)y0 + gy*0.5f) / ((float)x - gx*settings->permissiveness);
                    if (gabs * val > gabs * lower_slope) {
                        b0 = true;
                        lower_slope_prev = lower_slope;
                        lower_slope = val;
                        blocked_below = true;
                    }
                }

                /* check if upper_slope is blocked */
                if (sx + x != tx) {
                    if (settings->opaque(map, sx + x, sy + my1)) {
                        b1 = true;
                        mb1 = true;
                        upper_slope_prev = upper_slope;
                        upper_slope = ((float)my1 - gy*0.5f) / ((float)x + gx*settings->permissiveness);
                        blocked_above = true;
                    }
                    else if (y1 != my1 && settings->opaque(map, sx + x, sy + y1)) {
                        val = ((float)y1 - gy*0.5f) / ((float)x + gx*settings->permissiveness);
                        if (gabs * val < gabs * upper_slope) {
                            b1 = true;
                            upper_slope_prev = upper_slope;
                            upper_slope = val;
                            blocked_above = true;
                        }
                    }
                }

                /* being "pinched" isn't blocked, because one can still look diagonally */
                if (mb0 && b1 || b0 && mb1 ||
                        gabs * (lower_slope - upper_slope) > GRID_EPSILON ||
                        gy*((float)(sy - ty) + (float)(tx - sx)*lower_slope - gy*0.5f) > -GRID_EPSILON ||
                        gy*((float)(sy - ty) + (float)(tx - sx)*upper_slope + gy*0.5f) <  GRID_EPSILON)
                {
                    line->is_blocked = true;
                    line->block_t = dx*x;
                    break;
                }
            }

            /* if blocked, still try to make a "smartest line" that goes the farthest before becoming blocked */
            line->step_x = gx;
            line->eps_x = 0.0f;
            line->eps_y = -gy * 2.0f * GRID_EPSILON;
            if (line->is_blocked) {
                lower_slope = lower_slope_prev;
                upper_slope = upper_slope_prev;
            }
            if (fabs(upper_slope - lower_slope) < GRID_EPSILON) {
                line->step_y = 0.5f * gx * (lower_slope + upper_slope);
            } else if (gabs * (slope - lower_slope) < GRID_EPSILON && 0.5f - fabs((float)(sy - ty) + (float)x*lower_slope) > GRID_EPSILON) {
                line->step_y = gx * lower_slope;
                line->eps_y = gy * 2.0f * GRID_EPSILON;
            } else if (gabs * (upper_slope - slope) < GRID_EPSILON && 0.5f - fabs((float)(sy - ty) + (float)x*upper_slope) > GRID_EPSILON) {
                line->step_y = gx * upper_slope;
            } else {
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
            int x0, x1;                /* lowest/highest possible x based on inner/outer edge of tiles and lower/upper slopes */
            int mx0, mx1;              /* low/high x based on the middle of tiles */
            float slope = ((float)(tx - sx)) / ((float)(ty - sy));
            float lower_slope = ((float)(tx - sx) - gx*0.5f) / ((float)(ty - sy));
            float upper_slope = ((float)(tx - sx) + gx*0.5f) / ((float)(ty - sy));
            float lower_slope_prev = lower_slope;
            float upper_slope_prev = upper_slope;

            /* include both source and dest y in loop, but don't include (source_x, source_y) or (target_x, target_y) */
            val = gy*0.5f*upper_slope + gy*GRID_EPSILON;
            x1 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
            if (x1 != 0 && gabs * upper_slope > 1.0f && settings->permissiveness > 0.199f && settings->opaque(map, sx + x1, sy)) {
                val = (gx*0.5f) / (gy*settings->permissiveness);
                if (gabs * val < gabs * upper_slope) {
                    upper_slope_prev = upper_slope;
                    upper_slope = val;
                    blocked_above = true;
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
                if (blocked_below && blocked_above && gabs*(upper_slope - lower_slope) < GRID_EPSILON) {
                    val  = (float)y*lower_slope - gx*GRID_EPSILON;
                    val2 = (float)y*upper_slope - gx*GRID_EPSILON;
                } else {
                    val  = (blocked_below) ? (float)y*lower_slope + gx*GRID_EPSILON : (float)y*lower_slope - gx*GRID_EPSILON;
                    val2 = (blocked_above) ? (float)y*upper_slope - gx*GRID_EPSILON : (float)y*upper_slope + gx*GRID_EPSILON;
                }
                mx0 = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);
                val -= gy*0.5f*lower_slope;
                x0  = (val < 0.0f) ? -(int)(0.5f - val) : (int)(0.5f + val);

                mx1 = (val2 < 0.0f) ? -(int)(0.5f - val2) : (int)(0.5f + val2);
                val2 += gy*0.5f*upper_slope;
                x1  = (val2 < 0.0f) ? -(int)(0.5f - val2) : (int)(0.5f + val2);

                /* check if lower_slope is blocked */
                if (settings->opaque(map, sx + mx0, sy + y)) {
                    b0 = true;
                    mb0 = true;
                    lower_slope_prev = lower_slope;
                    lower_slope = ((float)mx0 + gx*0.5f) / ((float)y - gy*settings->permissiveness);
                    blocked_below = true;
                }
                else if (x0 != mx0 && settings->opaque(map, sx + x0, sy + y)) {
                    val = ((float)x0 + gx*0.5f) / ((float)y - gy*settings->permissiveness);
                    if (gabs * val > gabs * lower_slope) {
                        b0 = true;
                        lower_slope_prev = lower_slope;
                        lower_slope = val;
                        blocked_below = true;
                    }
                }

                /* check if upper_slope is blocked */
                if (sy + y != ty) {
                    if (settings->opaque(map, sx + mx1, sy + y)) {
                        b1 = true;
                        mb1 = true;
                        upper_slope_prev = upper_slope;
                        upper_slope = ((float)mx1 - gx*0.5f) / ((float)y + gy*settings->permissiveness);
                        blocked_above = true;
                    }
                    else if (x1 != mx1 && settings->opaque(map, sx + x1, sy + y)) {
                        val = ((float)x1 - gx*0.5f) / ((float)y + gy*settings->permissiveness);
                        if (gabs * val < gabs * upper_slope) {
                            b1 = true;
                            upper_slope_prev = upper_slope;
                            upper_slope = val;
                            blocked_above = true;
                        }
                    }
                }

                /* being "pinched" isn't blocked, because one can still look diagonally */
                if (mb0 && b1 || b0 && mb1 ||
                        gabs * (lower_slope - upper_slope) > GRID_EPSILON ||
                        gx*((float)(sx - tx) + (float)(ty - sy)*lower_slope - gx*0.5f) > -GRID_EPSILON ||
                        gx*((float)(sx - tx) + (float)(ty - sy)*upper_slope + gx*0.5f) <  GRID_EPSILON)
                {
                    line->is_blocked = true;
                    line->block_t = dy*y;
                    break;
                }
            }

            /* if blocked, still try to make a "smartest line" that goes the farthest before becoming blocked */
            line->step_y = gy;
            line->eps_y = 0.0f;
            line->eps_x = -gx * 2.0f * GRID_EPSILON;
            if (line->is_blocked) {
                lower_slope = lower_slope_prev;
                upper_slope = upper_slope_prev;
            }
            if (fabs(upper_slope - lower_slope) < GRID_EPSILON) {
                line->step_x = 0.5f * gy * (lower_slope + upper_slope);
            } else if (gabs * (slope - lower_slope) < GRID_EPSILON && 0.5f - fabs((float)(sx - tx) + (float)y*lower_slope) > GRID_EPSILON) {
                line->step_x = gy * lower_slope;
                line->eps_x = gx * 2.0f * GRID_EPSILON;
            } else if (gabs * (upper_slope - slope) < GRID_EPSILON && 0.5f - fabs((float)(sx - tx) + (float)y*upper_slope) > GRID_EPSILON) {
                line->step_x = gy * upper_slope;
            } else {
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

/* This has pretty much been deprecated (use "fov_beam_any_angle" instead of "fov_beam") */
#define BEAM_DIRECTION(d, p1, p2, p3, p4, p5, p6, p7, p8)                             \
    if (direction == d) {                                                             \
        end_slope = betweenf(a, 0.0f, 1.0f);                                          \
        fov_octant_##p1(&data, 1, 0.0f, end_slope, false, false, true, true);         \
        fov_octant_##p2(&data, 1, 0.0f, end_slope, false, false, false, true);        \
        if (a - 1.0f > FLT_EPSILON) { /* a > 1.0f */                                  \
            start_slope = betweenf(2.0f - a, 0.0f, 1.0f);                             \
            fov_octant_##p3(&data, 1, start_slope, 1.0f, false, false, true, false);  \
            fov_octant_##p4(&data, 1, start_slope, 1.0f, false, false, true, false);  \
                                                                                      \
        if (a - 2.0f > 2.0f * FLT_EPSILON) { /* a > 2.0f */                           \
            end_slope = betweenf(a - 2.0f, 0.0f, 1.0f);                               \
            fov_octant_##p5(&data, 1, 0.0f, end_slope, false, false, false, true);    \
            fov_octant_##p6(&data, 1, 0.0f, end_slope, false, false, false, true);    \
                                                                                      \
        if (a - 3.0f > 3.0f * FLT_EPSILON) { /* a > 3.0f */                           \
            start_slope = betweenf(4.0f - a, 0.0f, 1.0f);                             \
            fov_octant_##p7(&data, 1, start_slope, 1.0f, false, false, true, false);  \
            fov_octant_##p8(&data, 1, start_slope, 1.0f, false, false, false, false); \
        }}}}

#define BEAM_DIRECTION_DIAG(d, p1, p2, p3, p4, p5, p6, p7, p8)                        \
    if (direction == d) {                                                             \
        start_slope = betweenf(1.0f - a, 0.0f, 1.0f);                                 \
        fov_octant_##p1(&data, 1, start_slope, 1.0f, false, false, true, true);       \
        fov_octant_##p2(&data, 1, start_slope, 1.0f, false, false, true, false);      \
        if (a - 1.0f > FLT_EPSILON) { /* a > 1.0f */                                  \
            end_slope = betweenf(a - 1.0f, 0.0f, 1.0f);                               \
            fov_octant_##p3(&data, 1, 0.0f, end_slope, false, false, false, true);    \
            fov_octant_##p4(&data, 1, 0.0f, end_slope, false, false, false, true);    \
                                                                                      \
        if (a - 2.0f > 2.0f * FLT_EPSILON) { /* a > 2.0f */                           \
            start_slope = betweenf(3.0f - a, 0.0f, 1.0f);                             \
            fov_octant_##p5(&data, 1, start_slope, 1.0f, false, false, true, false);  \
            fov_octant_##p6(&data, 1, start_slope, 1.0f, false, false, true, false);  \
                                                                                      \
        if (a - 3.0f > 3.0f * FLT_EPSILON) { /* a > 3.0f */                           \
            end_slope = betweenf(a - 3.0f, 0.0f, 1.0f);                               \
            fov_octant_##p7(&data, 1, 0.0f, end_slope, false, false, false, true);    \
            fov_octant_##p8(&data, 1, 0.0f, end_slope, false, false, false, false);   \
        }}}}

void fov_beam(fov_settings_type *settings, void *map, void *source,
              int source_x, int source_y, int radius,
              fov_direction_type direction, float angle) {

    fov_private_data_type data;
    float start_slope, end_slope, a;

    if (angle <= 0.0f) {
        return;
    } else if (angle >= 360.0f) {
        fov_circle(settings, map, source, source_x, source_y, radius);
        return;
    }

    data.settings = settings;
    data.map = map;
    data.source = source;
    data.source_x = source_x;
    data.source_y = source_y;
    data.radius = radius;
    data.heights = (radius < 33) ? heights_tables[settings->shape] + (radius*(radius-1) / 2 - 1) : NULL;

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

