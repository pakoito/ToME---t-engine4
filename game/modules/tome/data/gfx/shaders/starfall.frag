uniform sampler2D tex;
uniform float tick;
uniform float tick_start;
uniform float time_factor;

float antialiasingRadius = 0.99; //1.0 is no antialiasing, 0.0 - fully smoothed(looks worse)

float snoise( vec3 v );

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
	float shieldIntensity = 0.1; //physically affects shield layer thickness
	//radius.x *= ellispoidalFactor; //for simple ellipsoid
	//comment next line for regular spherical shield
	//radius.x *= (1.0 + ellipsoidalFactor) * 0.5 + (ellipsoidalFactor - 1.0) * 0.5 * pow(cos(tick / time_factor * oscillationSpeed), 2.0);
	
	//on-hit wobbling effect
	float coreTime = 0.3;
	float outerSphereTime = 0.38;
	/*float coreTime = 0.1;
	float outerSphereTime = 0.9;*/

	float outerSphereIntensity = 1.5;

	float radiusLen = length(radius);
	
	float antialiasingCoef = 1.0;
	
	vec4 sphereColor = vec4(0.0, 0.0, 0.0, 0.0);

	float phase = clamp((tick - tick_start) / time_factor, 0.0, 1.0);

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
		float fractureShininess = 0.2 + clamp((fractureColor.a - phaseSubstraction) / (1.0 - phaseSubstraction + 0.1), 0.0, 1.0) * (0.5 + fracturePhase * 40.0);

		float resultShininess = fractureShininess * shieldIntensity / cos(alpha);
		sphereColor = blackColor + vec4(color * resultShininess, 0.0);
		sphereColor.a *= min(1.0, sphereColor.a) * antialiasingCoef;
		gl_FragColor = vec4(0.0, 0.0, texCoord.x, 1.0);
	}

	float rayPhase = clamp(innerSpherePhase * 1.1, 0.0, 1.0);
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

			outerSphereColor = vec4(color, 	1.0 - exp(-100.0 * texture2D(tex, texCoord).a * shieldIntensity / cos(alpha)));
			outerSphereColor.a *= antialiasingCoef;
			outerSphereColor.a *= 1.0 - pow(outerSpherePhase, 5.0);
		}

		float coreTransperency = pow(1.0 - outerSpherePhase, 2.0);
		explosionColor = Uberblend(vec4(coreColor.rgb, coreColor.a * coreTransperency), outerSphereColor);
	}
	float debrisPhase = clamp((phase - outerSphereTime) / (1.0 - outerSphereTime), 0.0, 1.0);
	if(debrisPhase > 0)
	{
		vec2 debrisTexPos = (clamp(radius + vec2(0.5, 0.5), 0.01, 0.99)) * vec2(0.5, 0.5) + vec2(0.0, 0.5);
		vec4 debrisColor = texture2D(tex, debrisTexPos);
		debrisColor.rgb *= color;
		float debrisIntensity = (1.0 - pow(debrisPhase, 2.0)) * 0.5;
		float debrisSubtraction = debrisPhase;

		debrisColor.a = clamp((debrisColor.a - debrisSubtraction) / (1.0 - debrisSubtraction) * debrisIntensity * 5.0, 0.0, 1.0);
		explosionColor = Uberblend(debrisColor, explosionColor);
	}
	gl_FragColor = explosionColor;
	gl_FragColor.a *= gl_Color.a;
}


vec4 permute( vec4 x ) {

	return mod( ( ( x * 34.0 ) + 1.0 ) * x, 289.0 );

} 

vec4 taylorInvSqrt( vec4 r ) {

	return 1.79284291400159 - 0.85373472095314 * r;

}

float snoise( vec3 v ) {

	const vec2 C = vec2( 1.0 / 6.0, 1.0 / 3.0 );
	const vec4 D = vec4( 0.0, 0.5, 1.0, 2.0 );

	// First corner

	vec3 i  = floor( v + dot( v, C.yyy ) );
	vec3 x0 = v - i + dot( i, C.xxx );

	// Other corners

	vec3 g = step( x0.yzx, x0.xyz );
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	vec3 x1 = x0 - i1 + 1.0 * C.xxx;
	vec3 x2 = x0 - i2 + 2.0 * C.xxx;
	vec3 x3 = x0 - 1. + 3.0 * C.xxx;

	// Permutations

	i = mod( i, 289.0 );
	vec4 p = permute( permute( permute(
		i.z + vec4( 0.0, i1.z, i2.z, 1.0 ) )
		+ i.y + vec4( 0.0, i1.y, i2.y, 1.0 ) )
		+ i.x + vec4( 0.0, i1.x, i2.x, 1.0 ) );

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)

	float n_ = 1.0 / 7.0; // N=7

	vec3 ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor( p * ns.z *ns.z );  //  mod(p,N*N)

	vec4 x_ = floor( j * ns.z );
	vec4 y_ = floor( j - 7.0 * x_ );    // mod(j,N)

	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs( x ) - abs( y );

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );


	vec4 s0 = floor( b0 ) * 2.0 + 1.0;
	vec4 s1 = floor( b1 ) * 2.0 + 1.0;
	vec4 sh = -step( h, vec4( 0.0 ) );

	vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

	vec3 p0 = vec3( a0.xy, h.x );
	vec3 p1 = vec3( a0.zw, h.y );
	vec3 p2 = vec3( a1.xy, h.z );
	vec3 p3 = vec3( a1.zw, h.w );

	// Normalise gradients

	vec4 norm = taylorInvSqrt( vec4( dot( p0, p0 ), dot( p1, p1 ), dot( p2, p2 ), dot( p3, p3 ) ) );
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value

	vec4 m = max( 0.6 - vec4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
	m = m * m;
	return 42.0 * dot( m*m, vec4( dot( p0, x0 ), dot( p1, x1 ),
		dot( p2, x2 ), dot( p3, x3 ) ) );

}  

