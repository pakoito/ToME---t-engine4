// some content:
//        Written by: Paul E. Martz
//        Copyright 1997 by Paul E. Martz, all right reserved
//        Non-commercial use by individuals is permitted.
// diamond square algorithm itself is public domain

/*
 Lua glue code itself is:

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

#include "display.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"
#include "types.h"
#include "SFMT.h"
#include <math.h>

/*
 * fractRand is a useful interface to randnum.
 */
static float fractRand(float v)
{
	float r = genrand_real(-v, v);
	return r;
}


/*
 * avgEndpoints - Given the i location and a stride to the data
 * values, return the average those data values. "i" can be thought of
 * as the data value in the center of two line endpoints. We use
 * "stride" to get the values of the endpoints. Averaging them yields
 * the midpoint of the line.
 *
 * Called by fill1DFractArray.
 */
static float avgEndpoints (int i, int stride, float *fa)
{
	return ((float) (fa[i-stride] +
		fa[i+stride]) * .5f);
}

/*
* avgDiamondVals - Given the i,j location as the center of a diamond,
* average the data values at the four corners of the diamond and
* return it. "Stride" represents the distance from the diamond center
* to a diamond corner.
*
* Called by fill2DFractArray.
*/
static float avgDiamondVals (int i, int j, int stride,
	int size, int subSize, float *fa)
{
	/* In this diagram, our input stride is 1, the i,j location is
	 indicated by "X", and the four value we want to average are
	 "*"s:
	 .   *   .

	 *   X   *

	 .   *   .
	 */

	/* In order to support tiled surfaces which meet seamless at the
	 edges (that is, they "wrap"), We need to be careful how we
	 calculate averages when the i,j diamond center lies on an edge
	 of the array. The first four 'if' clauses handle these
	 cases. The final 'else' clause handles the general case (in
	 which i,j is not on an edge).
	 */
	if (i == 0)
		return ((float) (fa[(i*size) + j-stride] +
			fa[(i*size) + j+stride] +
			fa[((subSize-stride)*size) + j] +
			fa[((i+stride)*size) + j]) * .25f);
	else if (i == size-1)
		return ((float) (fa[(i*size) + j-stride] +
			fa[(i*size) + j+stride] +
			fa[((i-stride)*size) + j] +
			fa[((0+stride)*size) + j]) * .25f);
	else if (j == 0)
		return ((float) (fa[((i-stride)*size) + j] +
			fa[((i+stride)*size) + j] +
			fa[(i*size) + j+stride] +
			fa[(i*size) + subSize-stride]) * .25f);
	else if (j == size-1)
		return ((float) (fa[((i-stride)*size) + j] +
			fa[((i+stride)*size) + j] +
			fa[(i*size) + j-stride] +
			fa[(i*size) + 0+stride]) * .25f);
	else
		return ((float) (fa[((i-stride)*size) + j] +
			fa[((i+stride)*size) + j] +
			fa[(i*size) + j-stride] +
			fa[(i*size) + j+stride]) * .25f);
}


/*
* avgSquareVals - Given the i,j location as the center of a square,
* average the data values at the four corners of the square and return
* it. "Stride" represents half the length of one side of the square.
*
* Called by fill2DFractArray.
*/
static float avgSquareVals (int i, int j, int stride, int size, float *fa)
{
	/* In this diagram, our input stride is 1, the i,j location is
	 indicated by "*", and the four value we want to average are
	 "X"s:
	 X   .   X

	 .   *   .

	 X   .   X
	 */
	return ((float) (fa[((i-stride)*size) + j-stride] +
		fa[((i-stride)*size) + j+stride] +
		fa[((i+stride)*size) + j-stride] +
		fa[((i+stride)*size) + j+stride]) * .25f);
}


// ifdef DEBUG
/*
* dump1DFractArray - Use for debugging.
	*/
	void dump1DFractArray (float *fa, int size)
{
	int	i;

	for (i=0; i<size; i++)
		printf ("(%.2f)   ", fa[i]);
	printf ("\n");
}

/*
* dump2DFractArray - Use for debugging.
	*/
	void dump2DFractArray (float *fa, int size)
{
	int	i, j;

	for (i=0; i<size; i++) {
		j=0;
		// printf ("[%d,%d]: ", i, j);
		for (; j<size; j++) {
			printf ("%.2f   ",
				fa[(i*size)+j]);
		}
		printf ("\n");
	}
}
// endif


/*
* powerOf2 - Returns 1 if size is a power of 2. Returns 0 if size is
	* not a power of 2, or is zero.
	*/
	static int powerOf2 (int size)
	{
		int i, bitcount = 0;

		/* Note this code assumes that (sizeof(int)*8) will yield the
		 number of bits in an int. Should be portable to most
		 platforms. */
		for (i=0; i<sizeof(int)*8; i++)
			if (size & (1<<i))
				bitcount++;
		if (bitcount == 1)
			/* One bit. Must be a power of 2. */
			return (1);
		else
			/* either size==0, or size not a power of 2. Sorry, Charlie. */
			return (0);
	}


/*
* fill1DFractArray - Tessalate an array of values into an
* approximation of fractal Brownian motion.
*/
void fill1DFractArray (float *fa, int size,
	float heightScale, float h)
{
	int	i;
	int	stride;
	int subSize;
	float ratio, scale;

	if (!powerOf2(size) || (size==1)) {
		/* We can't tesselate the array if it is not a power of 2. */
#ifdef DEBUG
		printf ("Error: fill1DFractArray: size %d is not a power of 2.\n");
#endif /* DEBUG */
		return;
	}

	/* subSize is the dimension of the array in terms of connected line
	 segments, while size is the dimension in terms of number of
	 vertices. */
	subSize = size;
	size++;

#ifdef DEBUG
	printf ("initialized\n");
	dump1DFractArray (fa, size);
#endif

	/* Set up our roughness constants.
	 Random numbers are always generated in the range 0.0 to 1.0.
	 'scale' is multiplied by the randum number.
	 'ratio' is multiplied by 'scale' after each iteration
	 to effectively reduce the randum number range.
	 */
	ratio = (float) pow (2.,-h);
	scale = heightScale * ratio;

	/* Seed the endpoints of the array. To enable seamless wrapping,
	 the endpoints need to be the same point. */
	stride = subSize / 2;
	fa[0] =
	fa[subSize] = 0.f;

#ifdef DEBUG
	printf ("seeded\n");
	dump1DFractArray (fa, size);
#endif

	while (stride) {
		for (i=stride; i<subSize; i+=stride) {
			fa[i] = scale * fractRand (.5f) +
			avgEndpoints (i, stride, fa);

			/* reduce random number range */
			scale *= ratio;

			i+=stride;
		}
		stride >>= 1;
	}

#ifdef DEBUG
	printf ("complete\n");
	dump1DFractArray (fa, size);
#endif
}


/*
* fill2DFractArray - Use the diamond-square algorithm to tessalate a
* grid of float values into a fractal height map.
*/
void fill2DFractArray (float *fa, int size,
	float heightScale, float h)
{
	int	i, j;
	int	stride;
	int	oddline;
	int subSize;
	float ratio, scale;

	if (!powerOf2(size) || (size==1)) {
		/* We can't tesselate the array if it is not a power of 2. */
#ifdef DEBUG
		printf ("Error: fill2DFractArray: size %d is not a power of 2.\n");
#endif /* DEBUG */
		return;
	}

	/* subSize is the dimension of the array in terms of connected line
	 segments, while size is the dimension in terms of number of
	 vertices. */
	subSize = size;
	size++;

#ifdef DEBUG
	printf ("initialized\n");
	dump2DFractArray (fa, size);
#endif

	/* Set up our roughness constants.
	 Random numbers are always generated in the range 0.0 to 1.0.
	 'scale' is multiplied by the randum number.
	 'ratio' is multiplied by 'scale' after each iteration
	 to effectively reduce the randum number range.
	 */
	ratio = (float) pow (2.,-h);
	scale = heightScale * ratio;

	/* Seed the first four values. For example, in a 4x4 array, we
	 would initialize the data points indicated by '*':

	 *   .   .   .   *

	 .   .   .   .   .

	 .   .   .   .   .

	 .   .   .   .   .

	 *   .   .   .   *

	 In terms of the "diamond-square" algorithm, this gives us
	 "squares".

	 We want the four corners of the array to have the same
	 point. This will allow us to tile the arrays next to each other
	 such that they join seemlessly. */

	stride = subSize / 2;
	fa[(0*size)+0] =
	fa[(subSize*size)+0] =
	fa[(subSize*size)+subSize] =
	fa[(0*size)+subSize] = 0.f;

#ifdef DEBUG
	printf ("seeded\n");
	dump2DFractArray (fa, size);
#endif

	/* Now we add ever-increasing detail based on the "diamond" seeded
	 values. We loop over stride, which gets cut in half at the
	 bottom of the loop. Since it's an int, eventually division by 2
	 will produce a zero result, terminating the loop. */
	while (stride) {
		/* Take the existing "square" data and produce "diamond"
		 data. On the first pass through with a 4x4 matrix, the
		 existing data is shown as "X"s, and we need to generate the
		 "*" now:

		 X   .   .   .   X

		 .   .   .   .   .

		 .   .   *   .   .

		 .   .   .   .   .

		 X   .   .   .   X

		 It doesn't look like diamonds. What it actually is, for the
		 first pass, is the corners of four diamonds meeting at the
		 center of the array. */
		for (i=stride; i<subSize; i+=stride) {
			for (j=stride; j<subSize; j+=stride) {
				fa[(i * size) + j] =
				scale * fractRand (.5f) +
				avgSquareVals (i, j, stride, size, fa);
				j += stride;
			}
			i += stride;
		}
#ifdef DEBUG
		printf ("Diamonds:\n");
		dump2DFractArray (fa, size);
#endif

		/* Take the existing "diamond" data and make it into
		 "squares". Back to our 4X4 example: The first time we
		 encounter this code, the existing values are represented by
		 "X"s, and the values we want to generate here are "*"s:

		 X   .   *   .   X

		 .   .   .   .   .

		 *   .   X   .   *

		 .   .   .   .   .

		 X   .   *   .   X

		 i and j represent our (x,y) position in the array. The
		 first value we want to generate is at (i=2,j=0), and we use
		 "oddline" and "stride" to increment j to the desired value.
		 */
		oddline = 0;
		for (i=0; i<subSize; i+=stride) {
			oddline = (oddline == 0);
			for (j=0; j<subSize; j+=stride) {
				if ((oddline) && !j) j+=stride;

				/* i and j are setup. Call avgDiamondVals with the
				 current position. It will return the average of the
				 surrounding diamond data points. */
				fa[(i * size) + j] =
				scale * fractRand (.5f) +
				avgDiamondVals (i, j, stride, size, subSize, fa);

				/* To wrap edges seamlessly, copy edge values around
				 to other side of array */
				if (i==0)
					fa[(subSize*size) + j] =
					fa[(i * size) + j];
				if (j==0)
					fa[(i*size) + subSize] =
					fa[(i * size) + j];

				j+=stride;
			}
		}
#ifdef DEBUG
		printf ("Squares:\n");
		dump2DFractArray (fa, size);
#endif

		/* reduce random number range. */
		scale *= ratio;
		stride >>= 1;
	}

#ifdef DEBUG
	printf ("complete\n");
	dump2DFractArray (fa, size);
#endif
}


/*
* alloc1DFractArray - Allocate float-sized data points for a 1D strip
	* containing size line segments.
	*/
	float *alloc1DFractArray (int size)
{
	/* Increment size (see comment in alloc2DFractArray, below, for an
	 explanation). */
	size++;

	return ((float *) malloc (sizeof(float) * size));
}

/*
* alloc2DFractArray - Allocate float-sized data points for a sizeXsize
	* mesh.
	*/
	float *alloc2DFractArray (int size)
{
	/* For a sizeXsize array, we need (size+1)X(size+1) space. For
	 example, a 2x2 mesh needs 3x3=9 data points:

	 *   *   *

	 *   *   *

	 *   *   *

	 To account for this, increment 'size'. */
	size++;

	return ((float *) malloc (sizeof(float) * size * size));
}



/*
* freeFractArray - Takes a pointer to float and frees it. Can be used
* to free data that was allocated by either alloc1DFractArray or
* alloc2DFractArray.
*/
void freeFractArray (float *fa)
{
	free (fa);
}


static int dmnd_2d(lua_State *L)
{
	int size = luaL_checknumber(L, 1);
	float heightScale = luaL_checknumber(L, 2);
	float h = luaL_checknumber(L, 3);

	float *fa = alloc2DFractArray(size);
	fill2DFractArray(fa, size, heightScale, h);

	int j, i;
	lua_createtable(L, size, 0);
	for (j = 0; j < size; j++)
	{
		lua_createtable(L, size, 0);
		for (i = 0; i < size; i++)
		{
			lua_pushnumber(L, fa[j * size + i]);
			lua_rawseti(L, -2, i + 1);
		}
		lua_rawseti(L, -2, j + 1);
	}

	freeFractArray(fa);
	return 1;
}

static int dmnd_1d(lua_State *L)
{
	int size = luaL_checknumber(L, 1);
	float heightScale = luaL_checknumber(L, 2);
	float h = luaL_checknumber(L, 3);

	float *fa = alloc1DFractArray(size);
	fill1DFractArray(fa, size, heightScale, h);

	int i;
	lua_createtable(L, size, 0);
	for (i = 0; i < size; i++)
	{
		lua_pushnumber(L, fa[i]);
		lua_rawseti(L, -2, i + 1);
	}

	freeFractArray(fa);
	return 1;
}

static const struct luaL_Reg dmndlib[] =
{
	{"get1D", dmnd_1d},
	{"get2D", dmnd_2d},
	{NULL, NULL},
};

int luaopen_diamond_square(lua_State *L)
{
	luaL_openlib(L, "core.diamond_square", dmndlib, 0);
	lua_pop(L, 1);
	return 1;
}
