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

WEB_TE4_API void te4_web_setup(int argc, char **argv, void*(*mutex_create)(), void(*mutex_destroy)(void*), void(*mutex_lock)(void*), void(*mutex_unlock)(void*), unsigned int (*make_texture)(int, int), void (*texture_update)(unsigned int, int, int, const void*));
WEB_TE4_API void te4_web_initialize();
WEB_TE4_API void te4_web_do_update(void (*cb)(WebEvent*));
WEB_TE4_API void te4_web_new(web_view_type *view, const char *url, int w, int h);
WEB_TE4_API bool te4_web_close(web_view_type *view);
WEB_TE4_API bool te4_web_toscreen(web_view_type *view, int *w, int *h, unsigned int *tex);
WEB_TE4_API bool te4_web_loading(web_view_type *view);
WEB_TE4_API void te4_web_focus(web_view_type *view, bool focus);
WEB_TE4_API void te4_web_inject_mouse_move(web_view_type *view, int x, int y);
WEB_TE4_API void te4_web_inject_mouse_wheel(web_view_type *view, int x, int y);
WEB_TE4_API void te4_web_inject_mouse_button(web_view_type *view, int kind, bool up);
WEB_TE4_API void te4_web_inject_key(web_view_type *view, int scancode, bool up);
WEB_TE4_API void te4_web_download_action(web_view_type *view, long id, const char *path);

#endif
