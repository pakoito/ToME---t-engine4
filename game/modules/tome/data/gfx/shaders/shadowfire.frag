uniform sampler2D tex;
uniform float tick;
uniform float aadjust;
uniform float time_factor = 25000.0;

uniform float ellipsoidalFactor = 1.5; //1 is perfect circle, >1 is ellipsoidal
uniform float oscillationSpeed = 20.0; //oscillation between ellipsoidal and spherical form

uniform float antialiasingRadius = 0.6; //1.0 is no antialiasing, 0.0 - fully smoothed(looks worse)
uniform float shieldIntensity = 0.15; //physically affects shield layer thickness

uniform vec4 leftColor1 = vec4(11.0  / 255.0, 8.0 / 255.0, 10.0 / 255.0, 1.0);
uniform vec4 leftColor2 = vec4(171.0 / 255.0, 4.0 / 255.0, 10.0 / 255.0, 1.0);

uniform vec4 rightColor1 = vec4(171.0 / 255.0, 4.0 / 255.0, 10.0 / 255.0, 1.0);
uniform vec4 rightColor2 = vec4(11.0  / 255.0, 8.0 / 255.0, 10.0 / 255.0, 1.0);
	
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

vec2 snoise2(vec3 pos)
{
	return vec2(snoise(pos), snoise(pos + vec3(0.0, 0.0, 1.0)));
}



vec2 GetFireDelta(float currTime, vec2 pos, float freqMult, float stretchMult)
{
	//firewall
	vec2 delta = vec2(0.0, 0.0);
//	pos.y += (1.0 - pos.y) * 0.5;
	//pos.y += 0.5;
	pos.y /= stretchMult;
	pos *= freqMult;
	pos.y -= currTime * 3.0;
//	pos.y -= currTime * 3.0;
	delta += vec2(0.0, snoise(vec3(pos * 1.0, currTime * 2.0)) * 0.8);
	delta += vec2(0.0, snoise(vec3(pos * 2.0, currTime * 4.0)) * 0.4);
	delta += vec2(0.0, snoise(vec3(pos * 8.0, currTime * 16.0)) * 0.8);
	delta += vec2(0.0, snoise(vec3(pos * 16.0, currTime * 32.0)) * 0.4);
	return delta;
}

vec4 GetFireColor(float currTime, vec2 pos, float freqMult, float stretchMult, float ampMult)
{
	vec2 delta = GetFireDelta(currTime, pos, freqMult, stretchMult);
	delta *= min(1.0, max(0.0, 1.0 * (1.0 - pos.y)));
	delta *= min(1.0, max(0.0, 1.0 * (0.0 + pos.y)));
	vec2 displacedPoint = pos + delta * ampMult;
	displacedPoint.y = min(0.99, displacedPoint.y);
	displacedPoint.y = max(0.01, displacedPoint.y);
	return texture2D(tex, displacedPoint);
}

void main(void)
{
	shieldIntensity = 0.2;
	vec2 radius = vec2(0.5, 0.5) - gl_TexCoord[0].xy;
	//radius.x *= ellispoidalFactor; //for simple ellipsoid
	//comment next line for regular spherical shield
	radius.x *= (1.0 + ellipsoidalFactor) * 0.5 + (ellipsoidalFactor - 1.0) * 0.5 * pow(cos(tick / time_factor * oscillationSpeed), 2.0);
	
	//on-hit wobbling effect
	float radiusLen = length(radius);
	
	float antialiasingCoef = 1.0;
	
	float sinAlpha = radiusLen * 2.0;
	float alpha = 0.0;
	if(sinAlpha > 1.0)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}else
	{
		if(sinAlpha > antialiasingRadius)
		{
			antialiasingCoef = (1.0 - sinAlpha) / (1.0 - antialiasingRadius);
		}
		alpha = asin(sinAlpha);
	}
	
	vec2 sphericalProjectedCoord = vec2(0.5, 0.5) + radius * (alpha / (3.141592 / 2.0)) / radiusLen;

	float verticalRatio = gl_TexCoord[0].y;
	if(verticalRatio < 0.5)
		verticalRatio = pow(verticalRatio * 2.0, 1.0) / 2.0;
	else
		verticalRatio = 1.0 - pow((1.0 - verticalRatio) * 2.0, 1.0) / 2.0;
	
	vec4 leftColor = leftColor1 * verticalRatio + leftColor2 * (1.0 - verticalRatio);
	vec4 rightColor = rightColor1 * verticalRatio + rightColor2 * (1.0 - verticalRatio);
	
	vec4 c1 = GetFireColor(tick / time_factor + 0.0 , vec2(sphericalProjectedCoord.y, (-0.3 + 0.0 + sphericalProjectedCoord.x) * 0.7), 1.0, 2.0, 1.0) * leftColor;
	vec4 c2 = GetFireColor(tick / time_factor + 10.0, vec2(sphericalProjectedCoord.y, (-0.3 + 1.0 - sphericalProjectedCoord.x) * 0.7), 1.0, 2.0, 1.0) * rightColor;
	vec4 c = c1 * c1.a + c2 * (1.0 - c1.a);
	
	c.a = 1.0 - exp(-c.a * shieldIntensity / cos(alpha));
	
	c.a *= aadjust;
	c.a *= min(1.0, c.a) * antialiasingCoef;

	gl_FragColor = c;
}
