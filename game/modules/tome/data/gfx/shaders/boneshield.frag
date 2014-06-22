uniform sampler2D tex;
uniform float tick;
uniform float chargesCount;
uniform float scrollingSpeed;
uniform float side;
uniform vec2 ellipsoidalFactor;
uniform float aadjust;
uniform float verticalIntensityAdjust;

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

struct Intersection
{
	vec2 localPoint;
	vec3 worldPoint;
};

void main(void)
{
	vec2 pos = (vec2(0.5, 0.5) - gl_TexCoord[0].xy) * ellipsoidalFactor;
	if((side == 1.0) && (pos.y > 0.0))
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}else
	if((side == 2.0) && (pos.y <= 0.0))
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}
	vec2 dir = normalize(pos);
	float intensityAdjust = 0.0;
	if(verticalIntensityAdjust > 0.0)
	{
		intensityAdjust = (1.0 + dir.y) * abs(verticalIntensityAdjust);
	}else
	{
		intensityAdjust = (1.0 - dir.y) * abs(verticalIntensityAdjust);
	}
	intensityAdjust = 0.0;
	
	float baseRadius = 0.3;
	float spiralRadius = 0.1;
	float spiralWidth = 1.0;

	float ang = atan(pos.y, pos.x);
	float pi = 3.141592653;

	Intersection intersections[10];
	int spiralsCount = int(chargesCount);
	float phase = ang * 1.0; //3 spiral rotations each
	for(int spiralIndex = 0; spiralIndex < spiralsCount; spiralIndex++)
	{
		float spiralPhase = phase + 2.0 * 3.1415 / chargesCount * float(spiralIndex);
		intersections[spiralIndex].worldPoint.xy = pos;
		intersections[spiralIndex].worldPoint.z = sin(spiralPhase);
		intersections[spiralIndex].localPoint.y = clamp(0.5 + (length(pos) - baseRadius + spiralRadius * cos(spiralPhase) * (intensityAdjust * 0.2 + 1.0)) / spiralWidth, 0.0, 1.0);
		intersections[spiralIndex].localPoint.x = (ang + float(spiralIndex) * 2.0 * pi / spiralsCount - tick * scrollingSpeed) / (pi * 2.0);
	}

	int i, j;
	for(i = 0; i < spiralsCount; i++)
	{
		for(j = i + 1; j < spiralsCount; j++)
		{
			if(intersections[i].worldPoint.z < intersections[j].worldPoint.z)
			//if(ints[i].geomInt.point.z < ints[j].geomInt.point.z)
			{
				Intersection tmp = intersections[j];
				intersections[j] = intersections[i];
				intersections[i] = tmp;
			}
		}
	}

	vec4 resultColor = vec4(0.0, 0.0, 0.0, 0.0);
	for(i = 0; i < spiralsCount; i++)
	{
		vec4 spiralColor = texture2D(tex, intersections[i].localPoint);
		spiralColor.rgb *= clamp((1.0 - intersections[i].worldPoint.z) * 0.5, 0.0, 1.0) * 0.7 + 0.3;
		resultColor = Uberblend(resultColor, spiralColor);
		/*resultColor.r = ang / (pi * 2.0) + 0.5;
		resultColor.gba = vec3(0.0, 0.0, 1.0);*/
	}

	gl_FragColor = resultColor * gl_Color;
}
/*

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

*/