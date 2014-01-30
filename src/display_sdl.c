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
#include "display_sdl.h"
#include <stdlib.h>

#define DISPLAY_CHAR_SIZE  16
SDL_Surface *screen = NULL;

void display_put_char(SDL_Surface *surface, char c, int x, int y, int r, int g, int b)
{
	SDL_Rect rect;

	rect.x = x*DISPLAY_CHAR_SIZE;
	rect.y = y*DISPLAY_CHAR_SIZE;

	if (c == '.') {
		rect.x += DISPLAY_CHAR_SIZE*3/8;
		rect.y += DISPLAY_CHAR_SIZE*3/8;
		rect.w = rect.h = DISPLAY_CHAR_SIZE/4;
	} else {
		rect.w = rect.h = DISPLAY_CHAR_SIZE - 1;
	}

	SDL_FillRect(surface, &rect, SDL_MapRGB(screen->format, r, g, b));
}

void display_put_string(SDL_Surface *surface, const char *s, int x, int y, int r, int g, int b) {
	int i;
	for (i = 0; s[i] != '\0'; ++i) {
		display_put_char(surface, s[i], x + i, y, r, g, b);
	}
}

void sdlDrawImage(SDL_Surface *dest, SDL_Surface *image, int x, int y)
{
	SDL_Rect r;
	r.w=image->w;
	r.h=image->h;
	r.x=x;
	r.y=y;
	int errcode = SDL_BlitSurface(image, NULL, dest, &r);
        if (errcode)
          printf("ERROR! SDL_BlitSurface failed! (%d,%s)\n",errcode,SDL_GetError());
}


// Current gl color, to remove the need to call glColor4f when undeeded
float gl_c_r = 1;
float gl_c_g = 1;
float gl_c_b = 1;
float gl_c_a = 1;
float gl_c_cr = 0;
float gl_c_cg = 0;
float gl_c_cb = 0;
float gl_c_ca = 1;
GLuint gl_c_texture = 0;
GLenum gl_c_texture_unit = GL_TEXTURE0;
GLuint gl_c_fbo = 0;
GLuint gl_c_shader = 0;
