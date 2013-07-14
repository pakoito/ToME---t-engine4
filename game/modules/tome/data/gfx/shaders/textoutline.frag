uniform sampler2D tex;
uniform vec4 outlineColor;

void main(void)
{
	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);
}