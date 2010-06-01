uniform int tick;
uniform sampler3D noisevol;

void main(void)
{
	float fTime0_X = (float)tick;
	vec4 noisy = texture3D(noisevol,vec3(gl_TexCoord[0].xy,fTime0_X));
	vec3 bump = 2.0 * noisy.xyz - 1.1;
	gl_FragColor.xyz = (1.0-bump.xyz)*vec3(0.3,0.3,1.0)+(bump.xyz)*vec3(0.0,0.0,0.0);
}
