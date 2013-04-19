#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#else
#ifdef _WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#ifndef _WIN32
#include <GL/glext.h>
#endif
#endif

extern float gl_c_r;
extern float gl_c_g;
extern float gl_c_b;
extern float gl_c_a;

#define tglColor4f(r, g, b, a) \
	{ \
	if (((r) != gl_c_r) || ((g) != gl_c_g) || ((b) != gl_c_b) || ((a) != gl_c_a)) { glColor4f((r), (g), (b), (a)); gl_c_r=(r); gl_c_g=(g); gl_c_b=(b); gl_c_a=(a); } \
	}

extern float gl_c_cr;
extern float gl_c_cg;
extern float gl_c_cb;
extern float gl_c_ca;

#define tglClearColor(r, g, b, a) \
	{ \
	if (((r) != gl_c_cr) || ((g) != gl_c_cg) || ((b) != gl_c_cb) || ((a) != gl_c_ca)) { glClearColor((r), (g), (b), (a)); gl_c_cr=(r); gl_c_cg=(g); gl_c_cb=(b); gl_c_ca=(a); } \
	}

extern GLenum gl_c_texture_unit;
#define tglActiveTexture(tu) \
	{ \
	if ((tu) != gl_c_texture_unit) { glActiveTexture((tu)); gl_c_texture_unit=(tu); } \
	}

//printf("swithch texture %d : %d\n", t, glIsTexture(t));
extern GLuint gl_c_texture;
#define tglBindTexture(w, t) \
	{ \
	if ((t) != gl_c_texture) { glBindTexture((w), (t)); gl_c_texture=(t); } \
	}
#define tfglBindTexture(w, t) \
	{ \
	glBindTexture((w), (t)); gl_c_texture=(t); \
	}

extern GLuint gl_c_fbo;
#define tglBindFramebufferEXT(w, t) \
	{ \
	glBindFramebufferEXT((w), (t)); gl_c_fbo=(t); \
	}
