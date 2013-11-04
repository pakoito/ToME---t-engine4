uniform float hp_warning;
uniform float air_warning;
uniform float death_warning;
uniform float solipsism_warning;
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

void main(void)
{
	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);

	if (motionblur > 0.0)
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
