/*

 audio.c, part of the Pipmak Game Engine
 Copyright (c) 2006-2007 Christian Walther

 Modified for:
 TE4 - T-Engine 4
 Copyright (C) 2009 - 2014 Nicolas Casalini

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

 */

#include "music.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "tSDL.h"
#include "physfs.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "auxiliar.h"


static ALCdevice *audioDevice;
static ALCcontext *audioContext;


static size_t physfsOvRead(void *ptr, size_t size, size_t nmemb, void *datasource) {
	PHYSFS_sint64 result = PHYSFS_read((PHYSFS_file *)datasource, ptr, (PHYSFS_uint32)size, (PHYSFS_uint32)nmemb);
	if (result < 0) return 0;
	else return (size_t)result;
}

static int physfsOvSeek(void *datasource, ogg_int64_t offset, int whence) {
	PHYSFS_uint64 start = 0;
	if (whence == SEEK_CUR) start = PHYSFS_tell((PHYSFS_file *)datasource);
	else if (whence == SEEK_END) start = PHYSFS_fileLength((PHYSFS_file *)datasource);
	return (PHYSFS_seek((PHYSFS_file *)datasource, start + offset)) ? 0 : -1;
}

static int physfsOvClose(void *datasource) {
	PHYSFS_close((PHYSFS_file *)datasource);
	return 0;
}

static long physfsOvTell(void *datasource) {
	return (long)PHYSFS_tell((PHYSFS_file *)datasource);
}

static ov_callbacks physfsOvCallbacks = {
	physfsOvRead,
	physfsOvSeek,
	physfsOvClose,
	physfsOvTell
};

void openal_get_devices()
{
	char deviceName[256];
	char *defaultDevice=NULL;
	char *deviceList=NULL;

	if (alcIsExtensionPresent(NULL, (const ALCchar*)"ALC_ENUMERATION_EXT") == AL_TRUE)
	{ // try out enumeration extension
		deviceList = (char *)alcGetString(NULL, ALC_DEVICE_SPECIFIER);

		if (strlen(deviceList))
		{
			defaultDevice = (char *)alcGetString(NULL, ALC_DEFAULT_DEVICE_SPECIFIER);
			int numDevices;

			for (numDevices = 0; numDevices < 16; numDevices++)
			{
				if (defaultDevice && strcmp(deviceList, defaultDevice) == 0)
				{
//					devList.numDefaultDevice = numDevices;
				}
				printf("OpenAL device available: %s (default %s)\n", deviceList, defaultDevice);

				deviceList += strlen(deviceList);
				if (deviceList[0] == 0)
				{
					if (deviceList[1] == 0)
					{
						break;
					}
					else
					{
						deviceList++;
					}
				}
			}
		}
	}
}

int init_openal() {
	openal_get_devices();
	audioDevice = alcOpenDevice(NULL);
	if (audioDevice == NULL) return 0;
	audioContext = alcCreateContext(audioDevice, NULL);
	if (audioContext == NULL) {
		alcCloseDevice(audioDevice);
		return 0;
	}
	alcMakeContextCurrent(audioContext);
	alDistanceModel(AL_NONE);
	return 1;
}

void deinit_openal() {
	alcMakeContextCurrent(NULL);
	alcDestroyContext(audioContext);
	alcCloseDevice(audioDevice);
}

static int readSoundData(Sound *sound, ALvoid *data, ALsizei size) {
	int section, readBytes, result;
	readBytes = 0;
	while ((ALsizei)readBytes < size) {
		result = ov_read(sound->vorbisFile, (char *)data + readBytes, size - readBytes, (SDL_BYTEORDER == SDL_BIG_ENDIAN) ? 1 : 0, 2, 1, &section);
		if (result == 0) {
			if (sound->loop) ov_raw_seek_lap(sound->vorbisFile, 0);
			else break;
		}
		if (result < 0 && result != OV_HOLE) break;
		readBytes += result;
	}
	return readBytes;
}

static int staticLoader(void *sound) {
	int bufferSize;
	vorbis_info *info;
	ALvoid *data;

	info = ov_info(((Sound *)sound)->vorbisFile, -1);
	bufferSize = 2*info->channels*(int)ov_pcm_total(((Sound *)sound)->vorbisFile, -1);
	data = malloc(bufferSize);
	if (data == NULL) return 1;
	bufferSize = readSoundData((Sound *)sound, data, bufferSize);
	alBufferData(((Sound *)sound)->buffers[0], (info->channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16, data, bufferSize, info->rate);
//	printf("==statuic buffer : %s\n",  alGetString(alGetError()));
	free(data);
	ov_clear(((Sound *)sound)->vorbisFile);
	free(((Sound *)sound)->vorbisFile);
	((Sound *)sound)->vorbisFile = NULL;
	return 0;
}

static int streamingLoader(void *sound) {
#define STREAMING_BUFFER_SIZE (1*2*2*44100)
	ALint i;
	ALuint buffer;
	vorbis_info *info;
	ALvoid *data;
	int readBytes;
	int testRest; /*what to do after the job is done: 0 = go to sleep right away, 1 = rest for a while if playing, else sleep*/

	data = malloc(STREAMING_BUFFER_SIZE);
	if (data == NULL) return 1;
	SDL_LockMutex(((Sound *)sound)->mutex);
	info = ov_info(((Sound *)sound)->vorbisFile, -1);

	do {
		testRest = 1;
		alGetSourcei(((Sound *)sound)->static_source, AL_BUFFERS_QUEUED, &i);
//		printf("==1: %d\n", i);
		if (i == 0) { /*fill and queue initial buffers*/
			readBytes = readSoundData((Sound *)sound, data, STREAMING_BUFFER_SIZE);
			alBufferData(((Sound *)sound)->buffers[0], (info->channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16, data, readBytes, info->rate);
//			printf("==read: %d : %s\n", i, alGetString(alGetError()));
			readBytes = readSoundData((Sound *)sound, data, STREAMING_BUFFER_SIZE);
			alBufferData(((Sound *)sound)->buffers[1], (info->channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16, data, readBytes, info->rate);
//			printf("==read: %d : %s\n", i, alGetString(alGetError()));
			alSourceQueueBuffers(((Sound *)sound)->static_source, 2, ((Sound *)sound)->buffers);
//			printf("==read: %d : %s\n", i, alGetString(alGetError()));
		}
		else { /*refill processed buffers*/
			alGetSourcei(((Sound *)sound)->static_source, AL_BUFFERS_PROCESSED, &i);
			while (i-- != 0) {
				readBytes = readSoundData((Sound *)sound, data, STREAMING_BUFFER_SIZE);
				if (readBytes == 0) {
					testRest = 0;
					break;
				}
				else {
					alSourceUnqueueBuffers(((Sound *)sound)->static_source, 1, &buffer);
					alBufferData(buffer, (info->channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16, data, readBytes, info->rate);
					alSourceQueueBuffers(((Sound *)sound)->static_source, 1, &buffer);
				}
			}
		}
//		printf("==2: %d\n", i);
		SDL_CondSignal(((Sound *)sound)->cond); /*tell the main thread we're done, in case it's waiting for us*/
//		printf("==3: %d\n", i);
		if (testRest) {
			alGetSourcei(((Sound *)sound)->static_source, AL_SOURCE_STATE, &i);
			testRest = (i == AL_PLAYING);
		}
		if (testRest) {
//		printf("==4a: %d\n", i);
			SDL_CondWaitTimeout(((Sound *)sound)->cond, ((Sound *)sound)->mutex, 400);
		}
		else {
//		printf("==4b: %d\n", i);
//			SDL_CondWait(((Sound *)sound)->cond, ((Sound *)sound)->mutex);
			SDL_CondWaitTimeout(((Sound *)sound)->cond, ((Sound *)sound)->mutex, 400);
		}
//		printf("streamlooping read %d\n", ((Sound *)sound)->loaderShouldExit);
	} while (!(((Sound *)sound)->loaderShouldExit));
//		printf(">>streamlooping read %d\n", ((Sound *)sound)->loaderShouldExit);

	SDL_UnlockMutex(((Sound *)sound)->mutex);
	free(data);

	return 0;
}

static int loadsoundLua(lua_State *L) {
	PHYSFS_file *file;
	const char *s;

	luaL_checktype(L, 1, LUA_TSTRING);
	s = lua_tostring(L, 1);
	bool is_stream = lua_toboolean(L, 2);

	Sound *sound = (Sound*)lua_newuserdata(L, sizeof(Sound));
	auxiliar_setclass(L, "sound{buffer}", -1);
	sound->type = SOUND_STATIC;
	sound->loop = 0;
	sound->loaderShouldExit = 0;
	sound->loaderThread = NULL;
	sound->vorbisFile = NULL;
	sound->path = malloc(strlen(s) + 1);
	if (sound->path == NULL) luaL_error(L, "out of memory");
	strcpy(sound->path, s);
	alGenBuffers(2, sound->buffers);
	sound->vorbisFile = malloc(sizeof(OggVorbis_File));
	if (sound->vorbisFile == NULL) luaL_error(L, "out of memory");
	if ((file = PHYSFS_openRead(s)) == NULL) {
		free(sound->vorbisFile);
		sound->vorbisFile = NULL;
		luaL_error(L, "Error loading sound \"%s\": %s", s, PHYSFS_getLastError());
	}
	if (ov_open_callbacks(file, sound->vorbisFile, NULL, 0, physfsOvCallbacks) < 0) {
		free(sound->vorbisFile);
		sound->vorbisFile = NULL;
		PHYSFS_close(file);
		luaL_error(L, "Error loading sound \"%s\": not an Ogg Vorbis file", s);
	}

	if (ov_streams(sound->vorbisFile) > 1) luaL_error(L, "Error loading sound \"%s\": Ogg files containing multiple logical bitstreams are not supported", s);

	if (is_stream) {
		alGenSources(1, &sound->static_source);
		sound->type = SOUND_STREAMING;
		sound->mutex = SDL_CreateMutex();
		if (sound->mutex == NULL) luaL_error(L, "out of memory");
		sound->cond = SDL_CreateCond();
		if (sound->cond == NULL) luaL_error(L, "out of memory");
		sound->loaderThread = SDL_CreateThread(streamingLoader, "steamer", sound);
	}
	else {
		sound->static_source = 0;
		staticLoader(sound);
	}

	return 1;
}

static int audio_enable(lua_State *L) {
	bool v = lua_toboolean(L, 1);
	if (v)
		alListenerf(AL_GAIN, 1);
	else
		alListenerf(AL_GAIN, 0);
	alListener3f(AL_POSITION, 0, 0, 0);
	alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED);
	return 0;
}

const luaL_Reg soundlib[] = {
	{"load", loadsoundLua},
	{"enable", audio_enable},
	{NULL, NULL}
};

static int soundTostringLua(lua_State *L) {
	Sound *s;
	s = (Sound*)auxiliar_checkclass(L, "sound{buffer}", 1);
	lua_pushfstring(L, "sound \"%s\" : %s", s->path, (s->type == SOUND_STREAMING) ? "<stream>" : "<static>");
	return 1;
}

static int soundCollectLua(lua_State *L) {
	Sound *s;
	s = (Sound*)auxiliar_checkclass(L, "sound{buffer}", 1);

	if (s->type == SOUND_STREAMING) {
		s->loaderShouldExit = 1;
		SDL_CondSignal(s->cond);
		SDL_WaitThread(s->loaderThread, NULL);
		SDL_DestroyCond(s->cond);
		SDL_DestroyMutex(s->mutex);
	}
	else {
		if (s->loaderThread != NULL) SDL_WaitThread(s->loaderThread, NULL);
	}

	alDeleteBuffers(2, s->buffers);
	if (s->path != NULL) free(s->path);
	if (s->vorbisFile != NULL) {
		ov_clear(s->vorbisFile);
		free(s->vorbisFile);
	}
	return 0;
}

static int sourceCollectLua(lua_State *L) {
	SoundSource *s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);

	if (!s->is_static_source) alDeleteSources(1, &s->source);
	luaL_unref(L, LUA_REGISTRYINDEX, s->sound_ref);

	return 0;
}

static int soundNewSource(lua_State *L) {
	Sound *s = (Sound*)auxiliar_checkclass(L, "sound{buffer}", 1);
	int ref = luaL_ref(L, LUA_REGISTRYINDEX);

	SoundSource *source = (SoundSource*)lua_newuserdata(L, sizeof(SoundSource));
	auxiliar_setclass(L, "sound{source}", -1);

	source->sound_ref = ref;
	source->sound = s;
	if (s->static_source)
	{
		source->source = s->static_source;
		source->is_static_source = TRUE;
	}
	else
	{
		alGenSources(1, &source->source);
//	printf("==source : %s\n",  alGetString(alGetError()));
		source->is_static_source = FALSE;
		alSourcei(source->source, AL_BUFFER, s->buffers[0]);
//	printf("==source buffer assigned : %s\n",  alGetString(alGetError()));
	}

	return 1;
}

static int soundPlayLua(lua_State *L) {
	SoundSource *s;
	ALint i;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	if (s->sound->type == SOUND_STREAMING) {
		alGetSourcei(s->source, AL_SOURCE_STATE, &i);
//				printf("====>>play %d\n",i);
		switch (i) {
			case AL_PLAYING:
				alSourceStop(s->source);
			case AL_STOPPED:
				ov_raw_seek(s->sound->vorbisFile, 0);
				alSourcei(s->source, AL_BUFFER, AL_NONE); /*unqueue all buffers*/
			case AL_INITIAL:
			case AL_PAUSED:
				SDL_LockMutex(s->sound->mutex);
				SDL_CondSignal(s->sound->cond); /*wake up loader*/
				SDL_CondWait(s->sound->cond, s->sound->mutex); /*wait until loader has queued initial buffers (if necessary), it will have gone to sleep when this returns because the source isn't playing yet*/
				alSourcePlay(s->source);
				SDL_CondSignal(s->sound->cond); /*wake up loader again (it will stay awake this time since the source is playing now)*/
				SDL_UnlockMutex(s->sound->mutex);
				break;
		}
	}
	else {
		alSourcePlay(s->source);
	}
	return 0;
}

static int soundPauseLua(lua_State *L) {
	SoundSource *s;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	alSourcePause(s->source);
	return 0;
}

static int soundStopLua(lua_State *L) {
	SoundSource *s;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	alSourceStop(s->source);
	return 0;
}

static int soundLoopLua(lua_State *L) {
	SoundSource *s;
	ALint old;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	alGetSourcei(s->source, AL_LOOPING, &old);
	if (!lua_isnone(L, 2)) {
		if (s->sound->type == SOUND_STATIC) alSourcei(s->source, AL_LOOPING, lua_toboolean(L, 2));
		else s->sound->loop = lua_toboolean(L, 2);
	}
	lua_pushboolean(L, old);
	return 1;
}

static int soundVolumeLua(lua_State *L) {
	SoundSource *s;
	ALfloat old, new;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	new = (ALfloat)luaL_optnumber(L, 2, -2893.0);
	alGetSourcef(s->source, AL_GAIN, &old);
	if (new != -2893.0) {
		alSourcef(s->source, AL_GAIN, new);
	}
	lua_pushnumber(L, old);
	return 1;
}

static int soundPitchLua(lua_State *L) {
	SoundSource *s;
	ALfloat old, new;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	new = (ALfloat)luaL_optnumber(L, 2, -2893.0);
	alGetSourcef(s->source, AL_PITCH, &old);
	if (new != -2893.0) {
		alSourcef(s->source, AL_PITCH, new);
	}
	lua_pushnumber(L, old);
	return 1;
}

static int soundLocationLua(lua_State *L) {
	SoundSource *s;
	ALfloat x, y, z;
	ALfloat nx, ny, nz;
	float oldaz, oldel, newaz = 0, newel = 0;
	int choice;

	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	if (lua_isnoneornil(L, 2)) {
		choice = 0;
	}
	else if (lua_isboolean(L, 2) && !lua_toboolean(L, 2)) {
		choice = 1;
	}
	else if (!lua_isnumber(L, 4)) {
		newaz = (float)luaL_checknumber(L, 2)*M_PI/180;
		newel = (float)luaL_checknumber(L, 3)*M_PI/180;
		choice = 2;
	}
	else {
		nx = luaL_checknumber(L, 2);
		ny = luaL_checknumber(L, 3);
		nz = luaL_checknumber(L, 4);
		choice = 3;
	}

	alGetSource3f(s->source, AL_POSITION, &x, &y, &z);
	if (x == 0 && y == 0 && z == 0) {
		lua_pushboolean(L, 0);
		lua_pushnil(L);
	}
	else {
		oldaz = atan2(x, -z)/M_PI*180;
		if (oldaz < 0) oldaz += 360;
		oldel = atan2(y, sqrt(x*x+z*z))/M_PI*180;
		lua_pushnumber(L, oldaz);
		lua_pushnumber(L, oldel);
	}

	if (choice == 1) {
		alSource3f(s->source, AL_POSITION, 0, 0, 0);
	}
	else if (choice == 2) {
		alSource3f(s->source, AL_POSITION, cosf(newel)*sinf(newaz), sinf(newel), -cosf(newel)*cosf(newaz));
	}
	else if (choice == 3) {
		alSource3f(s->source, AL_POSITION, nx, ny, nz);
		if (lua_isnumber(L, 5)) alSourcef(s->source, AL_MAX_DISTANCE, lua_tonumber(L, 5));
		else alSourcef(s->source, AL_MAX_DISTANCE, 10.0);
	}
	return 2;
}

static int soundPlayingLua(lua_State *L) {
	SoundSource *s;
	ALint i;
	s = (SoundSource*)auxiliar_checkclass(L, "sound{source}", 1);
	alGetSourcei(s->source, AL_SOURCE_STATE, &i);
	lua_pushboolean(L, (i == AL_PLAYING));
	return 1;
}

const luaL_Reg soundFuncs[] = {
	{"__tostring", soundTostringLua},
	{"__gc", soundCollectLua},
	{"use", soundNewSource},
	{NULL, NULL}
};

const luaL_Reg sourceFuncs[] = {
	{"__gc", sourceCollectLua},
	{"play", soundPlayLua},
	{"pause", soundPauseLua},
	{"stop", soundStopLua},
	{"loop", soundLoopLua},
	{"volume", soundVolumeLua},
	{"pitch", soundPitchLua},
	{"location", soundLocationLua},
	{"playing", soundPlayingLua},
	{NULL, NULL}
};

int luaopen_sound(lua_State *L)
{
	auxiliar_newclass(L, "sound{buffer}", soundFuncs);
	auxiliar_newclass(L, "sound{source}", sourceFuncs);
	luaL_openlib(L, "core.sound", soundlib, 0);
	lua_pop(L, 1);
	return 1;
}
