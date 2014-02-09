uniform float hp_warning;
uniform float air_warning;
uniform float death_warning;
uniform float solipsism_warning;
uniform float wobbling;
uniform float motionblur;
uniform float underwater;
uniform float blur;
uniform float tick;
uniform sampler2D noisevol;
uniform vec2 texSize;
uniform sampler2D tex;
uniform vec4 colorize;
uniform vec4 intensify;

// Simple Water shader. (c) Victor Korsun, bitekas@gmail.com; 2012.
//
// Attribution-ShareAlike CC License.

#ifdef GL_ES
precision highp float;
#endif

uniform vec2 mapCoord;

const float PI = 3.1415926535897932;

// play with these parameters to custimize the effect
// ===================================================

//speed
const float speed = 0.05;
const float speed_x = 0.3;
const float speed_y = 0.3;

// refraction
const float emboss = 0.05;
const float intensity = 0.4;
const int steps = 6;
const float frequency = 100.0;
const int angle = 7; // better when a prime

// reflection
const float delta = 60.;
const float intence = 700.;

const float reflectionCutOff = 0.012;
const float reflectionIntence = 200000.;

// ===================================================

float time = tick / 30000.0;

float col(vec2 coord)
{
	float delta_theta = 2.0 * PI / float(angle);
	float col = 0.0;
	float theta = 0.0;
	for (int i = 0; i < steps; i++)
	{
		vec2 adjc = coord;
		theta = delta_theta*float(i);
		adjc.x += cos(theta)*time*speed + time * speed_x;
		adjc.y -= sin(theta)*time*speed - time * speed_y;
		col = col + cos( (adjc.x*cos(theta) - adjc.y*sin(theta))*frequency)*intensity;
	}

	return cos(col);
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


vec2 snoise2(vec3 pos)
{
	return vec2(snoise(pos), snoise(pos + vec3(0.0, 0.0, 1.0)));
}

void main(void)
{
	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);

	/*vec2 offset = 
	vec4 offsetColor = texture2D(tex, gl_TexCoord[0].xy);*/

	if (wobbling > 0.0)
	{
		float scaledTime = tick / 5000.0;
		vec2 coord = gl_TexCoord[0].xy;
		coord.x *= texSize.x / texSize.y;
		vec2 offset =
			snoise2(vec3(coord / 2.0,  scaledTime / 0.25)) * 0.33 * 3.0 + 
			snoise2(vec3(coord / 2.0, scaledTime / 2.0)) * 0.0 + 
			snoise2(vec3(coord / 4.0, scaledTime / 4.0)) * 0.0;

		offset.x *= texSize.x / texSize.y;

		float ratio = clamp(1.5 * pow(length(vec2(0.5, 0.5) - gl_TexCoord[0].xy) / (0.7071), 2.0), 0.0, 1.0); //sqrt(2) / 2 = 0.7071
		ratio *= (1.0 + snoise2(vec3(coord / 2.0, scaledTime / 0.25 + 10.0))) * 0.5;

		gl_FragColor = 
			texture2D(tex, gl_TexCoord[0].xy) * (1.0 - ratio) + 
			texture2D(tex, gl_TexCoord[0].xy + offset * 0.01 * wobbling) * ratio;
	}
	else if (motionblur > 0.0)
	{
		int blursize = int(motionblur);
		vec2 offset = 0.8/texSize;

		float fTime0_X = tick / 20000.0;
		float coord = gl_TexCoord[0].x + gl_TexCoord[0].y * texSize[0];
		float noisy1 = texture2D(noisevol,vec2(coord,fTime0_X)).r;
		float noisy2 = texture2D(noisevol,vec2(coord/5.0,fTime0_X/1.5)).r;
		float noisy3 = texture2D(noisevol,vec2(coord/7.0,fTime0_X/2.0)).r;
		float noisy = (noisy1+noisy2+noisy3)/3.0;

		// Center Pixel
		vec4 sample = vec4(0.0,0.0,0.0,0.0);
		float factor = ((float(blursize)*2.0)+1.0);
		factor = factor*factor;

		if (noisy < 0.25)
		{
			for(int i = -blursize; i <= 0; i++)
			{
				for(int j = -blursize; j <= 0; j++)
				{
					sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
				}
			}
		}
		else if (noisy < 0.50)
		{
			for(int i = 0; i <= blursize; i++)
			{
				for(int j = 0; j <= blursize; j++)
				{
					sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
				}
			}
		}
		else if (noisy < 0.75)
		{
			for(int i = 0; i <= blursize; i++)
			{
				for(int j = -blursize; j <= 0; j++)
				{
					sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
				}
			}
		}
		else
		{
			for(int i = -blursize; i <= 0; i++)
			{
				for(int j = 0; j <= blursize; j++)
				{
					sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
				}
			}
		}
		sample /= float((motionblur*1.5) * (motionblur*0.5));
//		gl_FragColor = sample * (0.3 + noise * 0.7);
		gl_FragColor = sample;
	}
	else if (blur > 0.0)
	{
		int blursize = int(blur);
		vec2 offset = 1.0/texSize;

		// Center Pixel
		vec4 sample = vec4(0.0,0.0,0.0,0.0);
		float factor = ((float(blursize)*2.0)+1.0);
		factor = factor*factor;

		for(int i = -blursize; i <= blursize; i++)
		{
			for(int j = -blursize; j <= blursize; j++)
			{
				sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
			}
		}
		sample /= (blur*2.0) * (blur*2.0);
		gl_FragColor = sample;
	}
	else if (underwater > 0.0)
	{
		vec2 p = (vec2(gl_FragCoord.x - mapCoord.x, texSize.y - gl_FragCoord.y - mapCoord.y)) / texSize.xy, c1 = p, c2 = p;
		float cc1 = col(c1);

		c2.x += texSize.x/delta;
		float dx = emboss*(cc1-col(c2))/delta;

		c2.x = p.x;
		c2.y += texSize.y/delta;
		float dy = emboss*(cc1-col(c2))/delta;

		c1.x += dx*2.;
		c1.y = -(c1.y+dy*2.);

		float alpha = 1.+dot(dx,dy)*intence;
			
		float ddx = dx - reflectionCutOff;
		float ddy = dy - reflectionCutOff;
		if (ddx > 0. && ddy > 0.) alpha = pow(alpha, ddx*ddy*reflectionIntence);
			
		vec4 col = texture2D(tex,c1)*(alpha);
		gl_FragColor = col;
	}

	if (colorize.r > 0.0 || colorize.g > 0.0 || colorize.b > 0.0)
	{
		float grey = (gl_FragColor.r*0.3+gl_FragColor.g*0.59+gl_FragColor.b*0.11) * colorize.a;
		gl_FragColor = gl_FragColor * (1.0 - colorize.a) + (vec4(colorize.r, colorize.g, colorize.b, 1.0) * grey);
	}

	if (intensify.r > 0.0 || intensify.g > 0.0 || intensify.b > 0.0)
	{
/*
		float grey = gl_FragColor.r*0.3+gl_FragColor.g*0.59+gl_FragColor.b*0.11;
		vec4 vgrey = vec4(grey, grey, grey, gl_FragColor.a);
		gl_FragColor = max(gl_FragColor * intensify, vgrey);
*/
		float grey = gl_FragColor.r*0.3+gl_FragColor.g*0.59+gl_FragColor.b*0.11;
		vec4 vgrey = vec4(grey, grey, grey, gl_FragColor.a);
		gl_FragColor = gl_FragColor * intensify;
	}

	if (hp_warning > 0.0)
	{
		vec4 hp_warning_color = vec4(hp_warning / 1.9, 0.0, 0.0, hp_warning / 1.5);
		float dist = length(gl_TexCoord[0].xy - vec2(0.5)) / 2.0;
		gl_FragColor = mix(gl_FragColor, hp_warning_color, dist);
	}

	if (air_warning > 0.0)
	{
		vec4 air_warning_color = vec4(0.0, air_warning / 3.0, air_warning / 1.0, air_warning / 1.3);
		float dist = length(gl_TexCoord[0].xy - vec2(0.5)) / 2.0;
		gl_FragColor = mix(gl_FragColor, air_warning_color, dist);
	}
	
	if (solipsism_warning > 0.0)
	{
		vec4 solipsism_warning_color = vec4(solipsism_warning / 2.0, 0.0, solipsism_warning / 2.0, solipsism_warning / 1.3);
		float dist = length(gl_TexCoord[0].xy - vec2(0.5)) / 2.0;
		gl_FragColor = mix(gl_FragColor, solipsism_warning_color, dist);
	}
}

/*uniform sampler2D tex;
uniform vec2 texSize;
int blursize = 5;

void main(void)
{
	vec2 offset = 1.0/texSize;

	// Center Pixel
	vec4 sample = vec4(0.0,0.0,0.0,0.0);
	float factor = ((float(blursize)*2.0)+1.0);
	factor = factor*factor;

	for(int i = -blursize; i <= blursize; i++)
	{
		for(int j = -blursize; j <= blursize; j++)
		{
			sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
		}
	}
	sample /= float((blursize*2) * (blursize*2));

	float grey = sample.r*0.3+sample.g*0.59+sample.b*0.11;
	vec3 color = vec3(1, 0, 0);
	gl_FragColor = vec4(vec3(color*grey),1.0);
}
*/
/*
uniform sampler2D tex;
uniform sampler3D noiseVol;
uniform float tick;
float do_blur = 3.0;
uniform vec2 texSize;

void main(void)
{
	if (do_blur > 0.0)
	{
		vec2 offset = 1.0/texSize;
		offset.y += texture3D(noiseVol, vec3(gl_TexCoord[0].xy, tick/100000))/30;

		// Center Pixel
		vec4 sample = vec4(0.0,0.0,0.0,0.0);
		float factor = ((float(do_blur)*2.0)+1.0);
		factor = factor*factor;

		for(int i = -do_blur; i <= do_blur; i++)
		{
			for(int j = -do_blur; j <= do_blur; j++)
			{
				sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
			}
		}
		sample /= float((do_blur*2) * (do_blur*2));

		gl_FragColor = sample;
	}

	float grey = gl_FragColor.r*0.3+gl_FragColor.g*0.59+gl_FragColor.b*0.11;
	vec3 color = vec3(1, 0, 0);
	gl_FragColor = vec4(vec3(color*grey),1.0);
}
*/
