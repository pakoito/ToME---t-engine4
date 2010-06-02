uniform int tick;
uniform sampler3D noisevol;
uniform sampler2D noise2d;
uniform float red;

void main(void)
{
//	float fTime0_X = (float)tick;
//	vec4 noisy = texture3D(noisevol,vec3(gl_TexCoord[0].xy,fTime0_X));
//	vec3 bump = 2.0 * noisy.xyz - 1.1;
//	gl_FragColor.xyz = (1.0-bump.xyz)*vec3(0.3,0.3,1.0)+(bump.xyz)*vec3(0.0,0.0,0.0);

//	vec4 noisy = texture2D(noise2d,gl_TexCoord[0].xy);
//	vec4 bump = 2.0 * noisy - 1.1;
//	gl_FragColor.xyz = (1.0-bump.xyz)*vec3(0.3,0.3,1.0)+(bump.xyz)*vec3(0.0,0.0,0.0);
//	gl_FragColor = bump;

	vec4 n = texture2D(noise2d, gl_TexCoord[0].xy);
	n.x = 1;
	gl_FragColor = n;

//	int i = (tick / 30) % 255;
//	float t = (float)i;
//	t = t / 255;
//	gl_FragColor = vec4(red, 0, t, 1);
}
