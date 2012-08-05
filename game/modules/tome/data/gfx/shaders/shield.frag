uniform sampler2D tex;
uniform float tick;
uniform float aadjust;
uniform vec3 color;
uniform float time_factor;

uniform vec3 impact_color;
uniform vec2 impact;
uniform float impact_tick;
uniform float impact_time;

void main(void)
{
	vec2 uv = vec2(0.5, 0.5) - gl_TexCoord[0].xy;
	float l = length(uv) * 2.0;
	float ll = l * l;

	vec4 c1 = texture2D(tex, (uv * ll / 1.3 + vec2(tick / time_factor, 0.0)));
	vec4 c2 = texture2D(tex, (uv * ll / 1.3 + vec2(0.0, tick / time_factor)));
	vec4 c = c1 * c2;

	float dist = max(min(1.0, 1.0 - l), 0.0) * 3.0;
	c.a *= c.a * dist;

	float z = l;
	c.a *= z;

	if (l > 1.0) c.a = 0.0;
	if (l < 0.5) {
		c.a *= ll * 4.0;
	}

	// Impact
	float it = tick - impact_tick;
	if (it < impact_time) {
		float v = (impact_time - it) / impact_time;
		float il = distance(impact / ll, (vec2(0.5) - gl_TexCoord[0].xy) / ll);
		if (il < 0.5 * (1.0 - v)) {
			v *= v * v;
			float ic = (1.0 - length(uv - impact)) * v * 3.0;
			c.rgb = mix(c.rgb, impact_color, ic);
			aadjust *= 1.0 + v * 3.0;
		}
	}

	c.a *= aadjust;

	if (l <= 1.0) c.a = max(0.15, c.a);

	c.rgb *= color;
	gl_FragColor = c;
}
