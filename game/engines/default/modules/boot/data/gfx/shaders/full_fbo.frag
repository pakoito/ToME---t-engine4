uniform sampler2D sceneBuffer;
uniform float gamma;

void main(void)
{
	vec2 uv = gl_TexCoord[0].xy;
	vec3 color = texture2D(sceneBuffer, uv).rgb;
	gl_FragColor.rgb = pow(color, vec3(1.0 / gamma));
}
