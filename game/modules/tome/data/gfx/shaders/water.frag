uniform float tick;
uniform sampler3D noisevol;
uniform vec2 mapCoord;
uniform sampler2D tex;
uniform int mapx;
uniform int mapy;

void main(void)
{
	float fTime0_X = tick / 10000;
	vec2 coord = mapCoord+gl_TexCoord[0].xy;
	float noisy = texture3D(noisevol,vec3(coord*0.11,fTime0_X)).r;
	float noisy2 = texture3D(noisevol,vec3(coord*0.47,fTime0_X)).r;
	float noisy3 = texture3D(noisevol,vec3(coord*0.67,fTime0_X)).r;
	float noise = (noisy+noisy2+noisy3)/3.0;

	float bump = abs((1.0 * noise)-1.3);
	gl_FragColor = mix(gl_Color, texture2D(tex, gl_TexCoord[0].xy), bump);
}
