#ifndef __USESHADER_H__
#define __USESHADER_H__

typedef struct {
	GLuint shader;
	GLint p_tick, p_color, p_mapcoord, p_texsize;
	int params_ref;
} shader_type;

extern bool shaders_active;
extern void useShader(shader_type *p, int x, int y, int w, int h, float r, float g, float b, float a);

#endif
