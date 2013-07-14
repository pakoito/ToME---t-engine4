uniform sampler2D tex;
uniform float tick;
uniform float aadjust;
uniform vec3 color;
uniform float time_factor;

uniform vec3 impact_color;
uniform vec2 impact;
uniform float impact_tick;
uniform float impact_time;
uniform float llpow;
uniform float ellipsoidalFactor; //1 is perfect circle, >1 is ellipsoidal
uniform float oscillationSpeed; //oscillation between ellipsoidal and spherical form
float antialiasingRadius = 0.98; //1.0 is no antialiasing, 0.0 - fully smoothed(looks worse)

void main(void)
{
	vec2 uv = vec2(0.5, 0.5) - gl_TexCoord[0].xy;
	//uv.x *= ellispoidalFactor; //for simple ellipsoid
	//comment next line for regular spherical shield
	uv.x *= (1.0 + ellipsoidalFactor) * 0.5 + (ellipsoidalFactor - 1.0) * 0.5 * pow(cos(tick / time_factor * oscillationSpeed), 2.0);
	float uvLen = length(uv);
	
	float antialiasingCoef = 1.0;
	
	float hordeLen = uvLen * 2.0;
	if(hordeLen > 1.0)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}else
	{
		if(hordeLen > antialiasingRadius)
		{
			antialiasingCoef = (1.0 - hordeLen) / (1.0 - antialiasingRadius);
		}
		hordeLen = asin(length(uv) * 2.0);
	}
	vec2 sphericalProjectedCoord = vec2(0.5, 0.5) + uv * (hordeLen / (3.141592 / 2.0)) / uvLen;
	
	vec4 c1 = texture2D(tex, (sphericalProjectedCoord + vec2(tick / time_factor, 0.0)));
	vec4 c2 = texture2D(tex, (sphericalProjectedCoord + vec2(0.0, tick / time_factor)));
	vec4 c = c1 * c2;

	float transperency = 1.0 - exp(-0.07f / cos(hordeLen));
	
	c.a = c.a * transperency;



	// Impact
	float it = tick - impact_tick;
	float vaadjust = aadjust;
	if (it < impact_time) {
		float l = uvLen * 2.0;
		float ll = pow(l, llpow);

		float v = (impact_time - it) / impact_time;
		float il = distance(impact / ll, (vec2(0.5) - gl_TexCoord[0].xy) / ll);
		if (il < 0.5 * (1.0 - v)) {
			v *= v * v;
			float ic = (1.0 - length(uv - impact)) * v * 3.0;
			c.rgb = mix(c.rgb, impact_color, ic);
			vaadjust *= 1.0 + v * 3.0;
		}
	}

	c.a *= vaadjust;
	c.rgb *= color;

	c.a *= min(1.0, c.a) * antialiasingCoef;

	gl_FragColor = c;
}
