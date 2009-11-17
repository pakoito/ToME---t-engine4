#include "display_sdl.h"
#include <stdlib.h>

#define DISPLAY_CHAR_SIZE  16

static SDL_Surface *screen;

void display_init() {
	SDL_Init(SDL_INIT_VIDEO);
	SDL_EnableKeyRepeat(100, 10);
	screen = SDL_SetVideoMode(800, 600, 0, SDL_DOUBLEBUF);
	atexit(SDL_Quit);
}

void display_exit() {
	SDL_Quit();
}

void display_clear() {
	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0x00, 0x00, 0x00));
}

void display_refresh() {
	SDL_Flip(screen);
}

void display_put_char(char c, int x, int y, int r, int g, int b) {
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

	SDL_FillRect(screen, &rect, SDL_MapRGB(screen->format, r, g, b));
}

void display_put_string(const char *s, int x, int y, int r, int g, int b) {
	int i;
	for (i = 0; s[i] != '\0'; ++i) {
		display_put_char(s[i], x + i, y, r, g, b);
	}
}

/**
 * Main game loop. Each keypress triggers the keypress_callback
 * function passed.
 */
void display_event_loop(void (*keypress_callback)(int key, int shift)) {
	SDL_Event event;
	while (SDL_WaitEvent(&event) >= 0) {

		/* Throw away pending keyboard events, or SDL seems to crash(?).
		 This seems to be a nice input loop. */
		SDL_PeepEvents(NULL, 1000, SDL_GETEVENT, SDL_KEYUP | SDL_KEYDOWN);

		switch (event.type) {

		case SDL_KEYDOWN: /* Handle keypresses. */
			if (event.key.keysym.sym != SDLK_RSHIFT &&
				event.key.keysym.sym != SDLK_LSHIFT) {
				if (keypress_callback != NULL)
					keypress_callback(event.key.keysym.sym, event.key.keysym.mod & KMOD_SHIFT);
			}
			break;
		case SDL_QUIT:
			exit(0);
			break;
		default:
			break;
		}
	}
}
