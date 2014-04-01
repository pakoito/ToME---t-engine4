// Taken from awesomium examples
#include "gl_texture_surface.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

GLRAMTextureSurface::GLRAMTextureSurface(int width, int height) : texture_id_(NULL),
	buffer_(0), bpp_(4), rowspan_(0), width_(width), height_(height) {
	rowspan_ = width_ * bpp_;
	buffer_ = new unsigned char[rowspan_ * height_];
	needs_update_ = false;

	texture_id_ = web_make_texture(width_, height_);
}

GLRAMTextureSurface::~GLRAMTextureSurface() {
	web_del_texture(texture_id_);
	delete[] buffer_;
}

void* GLRAMTextureSurface::GetTexture() const {
	const_cast<GLRAMTextureSurface*>(this)->UpdateTexture();

	return texture_id_;
}

void GLRAMTextureSurface::Paint(unsigned char* src_buffer,
										int src_row_span,
										const Awesomium::Rect& src_rect,
										const Awesomium::Rect& dest_rect) {
	for (int row = 0; row < dest_rect.height; row++)
		memcpy(buffer_ + (row + dest_rect.y) * rowspan_ + (dest_rect.x * 4),
			src_buffer + (row + src_rect.y) * src_row_span + (src_rect.x * 4),
			dest_rect.width * 4);

	needs_update_ = true;
}

void GLRAMTextureSurface::Scroll(int dx,
										int dy,
										const Awesomium::Rect& clip_rect) {
	if (abs(dx) >= clip_rect.width || abs(dy) >= clip_rect.height)
		return;

	if (dx < 0 && dy == 0) {
		// Area shifted left by dx
		unsigned char* tempBuffer = new unsigned char[(clip_rect.width + dx) * 4];

		for (int i = 0; i < clip_rect.height; i++) {
			memcpy(tempBuffer, buffer_ + (i + clip_rect.y) * rowspan_ +
				(clip_rect.x - dx) * 4, (clip_rect.width + dx) * 4);
			memcpy(buffer_ + (i + clip_rect.y) * rowspan_ + (clip_rect.x) * 4,
				tempBuffer, (clip_rect.width + dx) * 4);
		}

		delete[] tempBuffer;
	} else if (dx > 0 && dy == 0) {
		// Area shifted right by dx
		unsigned char* tempBuffer = new unsigned char[(clip_rect.width - dx) * 4];

		for (int i = 0; i < clip_rect.height; i++) {
			memcpy(tempBuffer, buffer_ + (i + clip_rect.y) * rowspan_ +
				(clip_rect.x) * 4, (clip_rect.width - dx) * 4);
			memcpy(buffer_ + (i + clip_rect.y) * rowspan_ + (clip_rect.x + dx) * 4,
				tempBuffer, (clip_rect.width - dx) * 4);
		}

		delete[] tempBuffer;
	} else if (dy < 0 && dx == 0) {
		// Area shifted down by dy
		for (int i = 0; i < clip_rect.height + dy ; i++)
			memcpy(buffer_ + (i + clip_rect.y) * rowspan_ + (clip_rect.x * 4),
			buffer_ + (i + clip_rect.y - dy) * rowspan_ + (clip_rect.x * 4),
			clip_rect.width * 4);
	} else if (dy > 0 && dx == 0) {
		// Area shifted up by dy
		for (int i = clip_rect.height - 1; i >= dy; i--)
			memcpy(buffer_ + (i + clip_rect.y) * rowspan_ + (clip_rect.x * 4),
			buffer_ + (i + clip_rect.y - dy) * rowspan_ + (clip_rect.x * 4),
			clip_rect.width * 4);
	}

	needs_update_ = true;
}

void GLRAMTextureSurface::UpdateTexture() {
	if (needs_update_) {
		web_texture_update(texture_id_, width_, height_, buffer_);
		needs_update_ = false;
	}
}


GLTextureSurfaceFactory::GLTextureSurfaceFactory() {
}

GLTextureSurfaceFactory::~GLTextureSurfaceFactory() {
}

Awesomium::Surface* GLTextureSurfaceFactory::CreateSurface(Awesomium::WebView* view, int width, int height) {
	return new GLRAMTextureSurface(width, height);
}

void GLTextureSurfaceFactory::DestroySurface(Awesomium::Surface* surface) {
	delete static_cast<GLRAMTextureSurface*>(surface);
}
