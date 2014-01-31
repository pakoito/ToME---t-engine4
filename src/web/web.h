/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways.
*/

#ifndef __TE4WEB_H__
#define __TE4WEB_H__

#ifdef __cplusplus
/* C++ compiler needs to make this a C API. */
#if defined( _WIN32 )
/* Windows needs this to be a DLL, so be sure to export. */
#define WEB_TE4_API extern "C" __declspec( dllexport ) 
#else
/* Non-windows platforms are fine linking statically. */
#define WEB_TE4_API extern "C"
#endif
#else
/* C compiler is using this header. */
#define WEB_TE4_API
#endif

WEB_TE4_API void te4_web_setup(int argc, char **argv);
WEB_TE4_API void te4_web_init(lua_State *L);
WEB_TE4_API void te4_web_update(lua_State *L);

#endif
