/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011 Nicolas Casalini

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
#ifndef _MUSIC_H_
#define _MUSIC_H_

#if defined(MACOSX)
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#include <Vorbis/vorbisfile.h>
#elif defined(WIN32)
#include <al.h>
#include <alc.h>
#include <vorbis/vorbisfile.h>
#else
#include <AL/al.h>
#include <AL/alc.h>
#include <vorbis/vorbisfile.h>
#endif

#include "SDL.h"
#include "SDL_thread.h"
#include "lua.h"
#include "lauxlib.h"
#include "types.h"


typedef struct Sound {
	enum { SOUND_STATIC, SOUND_STREAMING } type;
	char *path;
	ALuint static_source;
	ALuint buffers[2];
	unsigned loop:1, loaderShouldExit:1;
	SDL_Thread *loaderThread;
	SDL_mutex *mutex; /*used by cond, held by the loader thread while it is working*/
	SDL_cond *cond; /*used by the main thread to wake up the loader thread, and by the loader thread to signal the main thread that it is done*/
	OggVorbis_File *vorbisFile;
} Sound;

typedef struct SoundSource {
	int sound_ref;
	Sound *sound;
	ALuint source;
	bool is_static_source;
} SoundSource;

int init_openal();
void deinit_openal();

#endif

