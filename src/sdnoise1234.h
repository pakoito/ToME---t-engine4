/* sdnoise1234, Simplex noise with true analytic
 * derivative in 1D to 4D.
 *
 * Copyright © 2003-2008, Stefan Gustavson
 *
 * Contact: stefan.gustavson@gmail.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/** \file
 \brief C header file for Perlin simplex noise with analytic
 derivative over 1, 2, 3 and 4 dimensions.
 \author Stefan Gustavson (stefan.gustavson@gmail.com)
 \author Charl van Deventer (landon.skyfire@gmail.com)
 */

/*
 * This is an implementation of Perlin "simplex noise" over one
 * dimension (x), two dimensions (x,y), three dimensions (x,y,z)
 * and four dimensions (x,y,z,w). The analytic derivative is
 * returned, to make it possible to do lots of fun stuff like
 * flow animations, curl noise, analytic antialiasing and such.
 *
 * Visually, this noise is exactly the same as the plain version of
 * simplex noise provided in the file "snoise1234.c". It just returns
 * all partial derivatives in addition to the scalar noise value.
 *
 */

/*
 * 23 June 2010: Modified by Charl van Deventer to allow periodic arguments
 * Note: It doesn't check for bounds over 255 (wont work) and might fail with
 * negative coords.
 */

#include <math.h>

/** 1D simplex noise with derivative.
 * If the last argument is not null, the analytic derivative
 * is also calculated.
 */
float sdnoise1s( float x, float *dnoise_dx);
float sdnoise1( float x, int px, float *dnoise_dx);

/** 2D simplex noise with derivatives.
 * If the last two arguments are not null, the analytic derivative
 * (the 2D gradient of the scalar noise field) is also calculated.
 */
float sdnoise2s( float x, float y, float *dnoise_dx, float *dnoise_dy );
float sdnoise2( float x, float y, int px, int py, float *dnoise_dx, float *dnoise_dy );

/** 3D simplex noise with derivatives.
 * If the last tthree arguments are not null, the analytic derivative
 * (the 3D gradient of the scalar noise field) is also calculated.
 */
float sdnoise3s( float x, float y, float z,
	float *dnoise_dx, float *dnoise_dy, float *dnoise_dz );
float sdnoise3( float x, float y, float z, int px, int py, int pz,
	float *dnoise_dx, float *dnoise_dy, float *dnoise_dz );

/** 4D simplex noise with derivatives.
 * If the last four arguments are not null, the analytic derivative
 * (the 4D gradient of the scalar noise field) is also calculated.
 */
float sdnoise4s( float x, float y, float z, float w,
	float *dnoise_dx, float *dnoise_dy,
	float *dnoise_dz, float *dnoise_dw);
float sdnoise4( float x, float y, float z, float w,
	int px, int py, int pz, int pw,
	float *dnoise_dx, float *dnoise_dy,
	float *dnoise_dz, float *dnoise_dw);
