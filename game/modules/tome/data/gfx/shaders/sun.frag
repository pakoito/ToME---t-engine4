uniform sampler2D tex;

void main(void)
{
//	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);

	int blursize = 3;
	float blur = 3.0;
	vec2 offset = 1.0 / vec2(512.0, 512.0);

	// Center Pixel
	vec4 sample = vec4(0.0,0.0,0.0,0.0);
	float factor = ((float(blursize)*2.0)+1.0);
	factor = factor * factor;

	for(int i = -blursize; i <= blursize; i++)
	{
		for(int j = -blursize; j <= blursize; j++)
		{
			sample += texture2D(tex, vec2(gl_TexCoord[0].xy+vec2(float(i)*offset.x, float(j)*offset.y)));
		}
	}
	sample /= (blur*2.0) * (blur*2.0);
	gl_FragColor = sample * 0.8;

//	gl_FragColor += vec4(0.3, 0.3, 0.3, 0);
}
