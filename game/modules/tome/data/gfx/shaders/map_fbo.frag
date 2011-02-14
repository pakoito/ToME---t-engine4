uniform vec2 texSize;
uniform sampler2D tex;
uniform sampler2D seens;
uniform vec4 seensinfo;

void main(void)
{
	/*
	 * Few lines to do some tricky things
	 * The game provides use with a "seens" texture that is the computed FOV
	 * We use this to lookup the current tile and shadow it as needed
	 * seenscoords is arranged as this: (tile_w, tile_h, view_scene_w, view_scene_h)
	 * We offset by 1x1.25 tiles .. dont ask why, it just works :/
	 */
	float v = -0.75;
	if (seensinfo.g == 32.0) v = -0.50;
	if (seensinfo.g == 16.0) v = -0.15;
	vec2 seenscoord = vec2((((gl_TexCoord[0].x) / seensinfo.r)) * texSize.x / seensinfo.b, (((gl_TexCoord[0].y + (seensinfo.g * v) / texSize.y) / seensinfo.g)) * texSize.y / seensinfo.a);
	vec4 seen = texture2D(seens, seenscoord);
	gl_FragColor = texture2D(tex, gl_TexCoord[0].xy);
	gl_FragColor.r *= seen.r;
	gl_FragColor.g *= seen.g;
	gl_FragColor.b *= seen.b;
}
