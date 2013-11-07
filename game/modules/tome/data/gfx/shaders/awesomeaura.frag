uniform sampler2D tex;
uniform sampler2D flames;

void main(void)
{
	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy) * texture2D(flames, gl_TexCoord[0].xy) + 0.2;
}
