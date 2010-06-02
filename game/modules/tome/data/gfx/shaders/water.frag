/*
uniform float tick;
uniform float alpha;
uniform sampler3D noisevol;

void main(void)
{
	float fTime0_X = tick / 10000;
	vec4 noisy = texture3D(noisevol,vec3(gl_TexCoord[0].xy,fTime0_X));
	vec3 bump = 2.0 * noisy.xyz - 1.1;
	gl_FragColor.xyz = (1.0-bump.xyz)*vec3(0.3,0.3,1.0)+(bump.xyz)*vec3(0.0,0.0,0.0);
	gl_FragColor.a = 1;
}
*/
uniform float tick;
uniform sampler3D noisevol;
uniform ivec2 mapCoord;

void main(void)
{
	float fTime0_X = tick / 10000;
	vec4 noisy = texture3D(noisevol,vec3(gl_TexCoord[0].xy*0.3,fTime0_X));
	vec4 noisy2 = texture3D(noisevol,vec3((mapCoord/50.0),fTime0_X));
	vec3 bump = 2.0 * (noisy.xyz+noisy2.xyz)/2.0 - 1.1;
	gl_FragColor.xyz = (1.0-bump.xyz)*vec3(0.3,0.3,1.0)+(bump.xyz)*vec3(0.0,0.0,0.0);
	gl_FragColor.a = 1;
}
