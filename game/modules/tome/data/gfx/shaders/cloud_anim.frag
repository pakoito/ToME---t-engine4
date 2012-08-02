#extension GL_EXT_gpu_shader4: enable

uniform sampler2D tex;
uniform float tick;
uniform vec2 mapCoord;
uniform vec2 texSize;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void)
{
	vec2 uv = gl_TexCoord[0].xy;
	vec2 r = rand(mapCoord / texSize);
	vec4 c = texture2D(tex, uv);
	c.a *= 0.3 + (((1 + r.x * sin(tick / 1000 + mapCoord.y)) / 2) * ((1 + r.y * cos(tick / 1000 + mapCoord.x)) / 2)) * 0.7;
	gl_FragColor = c;
}
