// Taken from awesomium examples

#ifndef __GL_TEXTURE_SURFACE_H__
#define __GL_TEXTURE_SURFACE_H__

#include <Awesomium/Surface.h>
extern "C" {
#include "tgl.h"
}

class GLTextureSurface : public Awesomium::Surface {
public:
	virtual void Paint(unsigned char* src_buffer,
										 int src_row_span,
										 const Awesomium::Rect& src_rect,
										 const Awesomium::Rect& dest_rect) = 0;

	virtual void Scroll(int dx,
											int dy,
											const Awesomium::Rect& clip_rect) = 0;

	virtual void* GetTexture() const = 0;
	virtual int width() const = 0;
	virtual int height() const = 0;
	virtual int size() const = 0;
};

class GLRAMTextureSurface : public GLTextureSurface {
	void *texture_id_;
	unsigned char* buffer_;
	int bpp_, rowspan_, width_, height_;
	bool needs_update_;

 public:
	GLRAMTextureSurface(int width, int height);
	virtual ~GLRAMTextureSurface();

	void* GetTexture() const;

	int width() const { return width_; }

	int height() const { return height_; }

	int size() const { return rowspan_ * height_; }

 protected:
	virtual void Paint(unsigned char* src_buffer,
										 int src_row_span,
										 const Awesomium::Rect& src_rect,
										 const Awesomium::Rect& dest_rect);

	virtual void Scroll(int dx,
											int dy,
											const Awesomium::Rect& clip_rect);

	void UpdateTexture();
};

class GLTextureSurfaceFactory : public Awesomium::SurfaceFactory {
public:
	GLTextureSurfaceFactory();

	virtual ~GLTextureSurfaceFactory();

	virtual Awesomium::Surface* CreateSurface(Awesomium::WebView* view,
																						int width,
																						int height);

	virtual void DestroySurface(Awesomium::Surface* surface);
};

extern void *(*web_mutex_create)();
extern void (*web_mutex_destroy)(void *mutex);
extern void (*web_mutex_lock)(void *mutex);
extern void (*web_mutex_unlock)(void *mutex);
extern void *(*web_make_texture)(int w, int h);
extern void (*web_del_texture)(void *tex);
extern void (*web_texture_update)(void *tex, int w, int h, const void* buffer);

#endif  // __GL_TEXTURE_SURFACE_H__
