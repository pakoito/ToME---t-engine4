#include "SDL.h"
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

inline void sdlDrawImage(SDL_Surface *dest, SDL_Surface *image, int x, int y)
{
	SDL_Rect r;
	r.w=image->w;
	r.h=image->h;
	r.x=x;
	r.y=y;
	SDL_BlitSurface(image, NULL, dest, &r);
}
