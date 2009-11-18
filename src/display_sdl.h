/**
 * \mainpage SDL Display Library
 *
 * \section copyright Copyright
 *
 * Copyright (C) 2006, Greg McIntyre
 * All rights reserved. See the file named COPYING in the distribution
 * for more details.
 *
 *
\verbatim
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License as
 published by the Free Software Foundation; either version 2 of the
 License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 USA
\endverbatim
 */

/**
 * \file   display_sdl.h
 * SDL Display library header
 */

#ifndef DISPLAY_SDL_H
#define DISPLAY_SDL_H

#include <SDL.h>

#ifdef __cplusplus
extern "C" {
#endif

void display_put_char(SDL_Surface *surface, char c, int x, int y, int r, int g, int b);
void display_put_string(SDL_Surface *surface, const char *s, int x, int y, int r, int g, int b);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
