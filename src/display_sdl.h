#ifndef DISPLAY_SDL_H
#define DISPLAY_SDL_H

#include <SDL.h>
#include <SDL_framerate.h>
#include <gl.h>
#include <glu.h>

#ifdef __cplusplus
extern "C" {
#endif

#define sdlLock(surface) do {\
	if (SDL_MUSTLOCK(surface)) SDL_LockSurface(surface);\
	} while (0)

#define sdlUnlock(surface) do {\
		if (SDL_MUSTLOCK(surface)) SDL_UnlockSurface(surface);\
	} while (0)

extern SDL_Surface *screen;
void display_put_char(SDL_Surface *surface, char c, int x, int y, int r, int g, int b);
void display_put_string(SDL_Surface *surface, const char *s, int x, int y, int r, int g, int b);
inline void sdlDrawImage(SDL_Surface *dest, SDL_Surface *image, int x, int y);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
