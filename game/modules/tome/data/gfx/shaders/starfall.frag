uniform sampler2D tex;
uniform float tick;
uniform float tick_start;
uniform float time_factor;

float antialiasingRadius = 0.99; //1.0 is no antialiasing, 0.0 - fully smoothed(looks worse)

vec4 Uberblend(vec4 col0, vec4 col1)
{
//  return vec4((1.0 - col0.a) * (col1.rgb) + col0.a * (col1.rgb * col1.a + col0.rgb * (1.0 - col1.a)), min(1.0, col0.a + col1.a));
//  return vec4((1.0 - col1.a) * (col0.rgb) + col1.a * (col1.rgb * col1.a + col0.rgb * (1.0 - col1.a)), min(1.0, col0.a + col1.a));
  return vec4(
    (1.0 - col0.a) * (1.0 - col1.a) * (col0.rgb * col0.a + col1.rgb * col1.a) / (col0.a + col1.a + 1e-1) +
    (1.0 - col0.a) * (0.0 + col1.a) * (col1.rgb) +
    (0.0 + col0.a) * (1.0 - col1.a) * (col0.rgb * (1.0 - col1.a) + col1.rgb * col1.a) +
    (0.0 + col0.a) * (0.0 + col1.a) * (col1.rgb),
    min(1.0, col0.a + col1.a));
}

void main(void)
{
	vec2 radius = vec2(0.5, 0.5) - gl_TexCoord[0].xy;
	//radius.x *= ellispoidalFactor; //for simple ellipsoid
	//comment next line for regular spherical shield
	//radius.x *= (1.0 + ellipsoidalFactor) * 0.5 + (ellipsoidalFactor - 1.0) * 0.5 * pow(cos(tick / time_factor * oscillationSpeed), 2.0);
	
	//on-hit wobbling effect
	float coreTime = 0.4;
	float outerSphereTime = 0.55 + 0.1;
	float debrisStartTime = 0.52;
	/*float coreTime = 0.1;
	float outerSphereTime = 0.9;*/

	float outerSphereIntensity = 1.5;

	float radiusLen = length(radius);
	
	float antialiasingCoef = 1.0;
	
	vec4 sphereColor = vec4(0.0, 0.0, 0.0, 0.0);

	float phase = clamp((tick - tick_start) / time_factor, 0.0, 1.0);
	//float phase = mod((tick - tick_start) / time_factor, 1.0);

	float innerSpherePhase = clamp(phase / coreTime, 0.0, 1.0);
	vec3 color = clamp(gl_Color.rgb * (1.0 + pow(innerSpherePhase, 2.0) * 10.0), 0.0, 1.0);

	float radiusScale = (1.0 - pow(1.0 - innerSpherePhase, 5.0));
	float innerSphereRadius = 0.3 * radiusScale;
	float sinAlpha = radiusLen / innerSphereRadius;
	float alpha = 0.0;
	if(sinAlpha > 1.0)
	{
		sphereColor = vec4(0.0, 0.0, 0.0, 0.0);
	}else
	{
		if(sinAlpha > antialiasingRadius)
		{
			antialiasingCoef = (1.0 - sinAlpha) / (1.0 - antialiasingRadius);
		}
		alpha = asin(sinAlpha);

		vec2 sphericalProjectedCoord = vec2(0.5, 0.5) + radius * (alpha / (3.141592 / 2.0)) / radiusLen;

		vec4 blackColor = vec4(0.0, 0.0, 0.0, 1.0);

		float fracturePhase = innerSpherePhase;
		vec2 texCoord = sphericalProjectedCoord * 0.6;
		texCoord.x = mod(texCoord.x, 0.995) * 0.5;
		texCoord.y = mod(texCoord.y, 0.995) * 0.5;
		vec4 fractureColor = texture2D(tex, texCoord);
		float phaseSubstraction = (1.0 - fracturePhase) * 0.5;
		float fractureShininess = 0.02 + clamp((fractureColor.a - phaseSubstraction) / (1.0 - phaseSubstraction + 0.1), 0.0, 1.0) * (0.05 + fracturePhase * 4.0);

		float resultShininess = fractureShininess / cos(alpha);
		sphereColor = blackColor + vec4(color * resultShininess, 0.0);
		sphereColor.a *= min(1.0, sphereColor.a) * antialiasingCoef;
		gl_FragColor = vec4(0.0, 0.0, texCoord.x, 1.0);
	}

	float rayPhase = clamp(innerSpherePhase * 0.9 + 0.1, 0.0, 1.0);
	vec2 raysTexPos = (clamp(radius / (radiusScale + 1e-5) + vec2(0.5, 0.5), 0.01, 0.99)) * vec2(0.5, 0.5) + vec2(0.5, 0.0);
	vec4 raysTexColor = texture2D(tex, raysTexPos);
	float raysSubtraction = (1.0 - rayPhase) * 1.0;
	vec4 raysColor = vec4(clamp(color * 1.7, 0.0, 1.0), clamp((raysTexColor.a - raysSubtraction) / (1.0 - raysSubtraction) * (0.5 + rayPhase * 2.0), 0.0, 1.0));


	vec4 coreColor = Uberblend(sphereColor, raysColor);
	vec4 explosionColor = coreColor;


	float outerSpherePhase = clamp((phase - coreTime) / (outerSphereTime - coreTime), 0.0, 1.0);
	vec4 outerSphereColor = vec4(0.0, 0.0, 0.0, 0.0);
	if(outerSpherePhase > 0)
	{
		float outerSphereRadius = innerSphereRadius + (0.5 - innerSphereRadius) * outerSpherePhase;
		float sinAlpha = radiusLen / outerSphereRadius;
		float alpha = 0.0;
		if(sinAlpha < 1.0)
		{
			antialiasingCoef = 1.0;
			if(sinAlpha > antialiasingRadius)
			{
				antialiasingCoef = (1.0 - sinAlpha) / (1.0 - antialiasingRadius);
			}
			alpha = asin(sinAlpha);

			vec2 sphericalProjectedCoord = vec2(0.5, 0.5) + radius * (alpha / (3.141592 / 2.0)) / radiusLen;
			vec2 texCoord = sphericalProjectedCoord * 0.6;
			texCoord.x = mod(texCoord.x, 0.995) * 0.5;// + 0.505;
			texCoord.y = mod(texCoord.y, 0.995) * 0.5;// + 0.505;

			outerSphereColor = vec4(color, 	1.0 - exp(-55.0 * (pow(1.0 - outerSpherePhase, 3.0)) * texture2D(tex, texCoord).a / cos(alpha)));
			outerSphereColor.a *= antialiasingCoef;
		}

		float coreTransperency = pow(1.0 - outerSpherePhase, 2.0);
		explosionColor = Uberblend(vec4(coreColor.rgb, coreColor.a * coreTransperency), outerSphereColor);
	}
	float debrisPhase = clamp((phase - debrisStartTime) / (1.0 - debrisStartTime), 0.0, 1.0);
	if(debrisPhase > 0)
	{
		vec2 debrisTexPos = (clamp(radius + vec2(0.5, 0.5), 0.01, 0.99)) * vec2(0.5, 0.5) + vec2(0.0, 0.5);
		vec4 debrisColor = texture2D(tex, debrisTexPos);
		debrisColor.rgb *= color;
		float debrisIntensity = (1.0 - pow(debrisPhase, 1.0)) * 0.5 * (1.0 - pow(1.0 - debrisPhase, 12.0));
		float debrisSubtraction = pow(debrisPhase, 5.0);

		debrisColor.a = clamp((debrisColor.a - debrisSubtraction) / (1.0 - debrisSubtraction) * debrisIntensity * 5.0, 0.0, 1.0);
		explosionColor = Uberblend(debrisColor, explosionColor);
	}
	gl_FragColor = explosionColor;
}
