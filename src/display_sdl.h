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

#define KEY_DOWN         SDLK_DOWN
#define KEY_DOWN         SDLK_DOWN
#define KEY_EQUALS       SDLK_EQUALS
#define KEY_ESCAPE       SDLK_ESCAPE
#define KEY_ESCAPE       SDLK_ESCAPE
#define KEY_KP1          SDLK_KP1
#define KEY_KP2          SDLK_KP2
#define KEY_KP3          SDLK_KP3
#define KEY_KP4          SDLK_KP4
#define KEY_KP6          SDLK_KP6
#define KEY_KP7          SDLK_KP7
#define KEY_KP8          SDLK_KP8
#define KEY_KP9          SDLK_KP9
#define KEY_LEFT         SDLK_LEFT
#define KEY_LEFT         SDLK_LEFT
#define KEY_LEFTBRACKET  SDLK_LEFTBRACKET
#define KEY_MINUS        SDLK_MINUS
#define KEY_RIGHT        SDLK_RIGHT
#define KEY_RIGHT        SDLK_RIGHT
#define KEY_RIGHTBRACKET SDLK_RIGHTBRACKET
#define KEY_SLASH        SDLK_SLASH
#define KEY_UP           SDLK_UP
#define KEY_a            SDLK_a
#define KEY_b            SDLK_b
#define KEY_c            SDLK_c
#define KEY_d            SDLK_d
#define KEY_e            SDLK_e
#define KEY_f            SDLK_f
#define KEY_g            SDLK_g
#define KEY_h            SDLK_h
#define KEY_i            SDLK_i
#define KEY_j            SDLK_j
#define KEY_k            SDLK_k
#define KEY_l            SDLK_l
#define KEY_m            SDLK_m
#define KEY_n            SDLK_n
#define KEY_o            SDLK_o
#define KEY_p            SDLK_p
#define KEY_q            SDLK_q
#define KEY_r            SDLK_r
#define KEY_s            SDLK_s
#define KEY_t            SDLK_t
#define KEY_u            SDLK_u
#define KEY_v            SDLK_v
#define KEY_w            SDLK_w
#define KEY_x            SDLK_x
#define KEY_y            SDLK_y
#define KEY_z            SDLK_z

void display_init();
void display_exit();
void display_clear();
void display_event_loop(void (*keypress_callback)(int key, int shift));
void display_refresh();
void display_put_char(char c, int x, int y, int r, int g, int b);
void display_put_string(const char *s, int x, int y, int r, int g, int b);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
