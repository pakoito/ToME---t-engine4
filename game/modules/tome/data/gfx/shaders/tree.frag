uniform sampler2D tex;
uniform float tick;
uniform vec2 mapCoord;

void main(void)
{
	float time = tick / 1000.0;
	vec2 xy = gl_TexCoord[0].xy;
	if (xy.y <= 0.5) xy.x = xy.x + (0.5-xy.y) * sin(time + mapCoord.x / 40 + mapCoord.y) / 14.0;
	gl_FragColor = texture2D(tex, xy) * gl_Color;
}
