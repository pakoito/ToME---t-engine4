//#version 150
uniform sampler2D fboTex;
uniform sampler2D targetSkin;
uniform vec2 mapCoord;
uniform vec2 tileSize;
uniform vec2 scrollOffset;

void main(void)
{
	vec2 offset = vec2(1.0, 1.0) / mapCoord * tileSize * 0.5;
	
	vec4 colorm0 = texture2D( fboTex, gl_TexCoord[0].xy + vec2(-offset.x, 0.0));
	vec4 colorp0 = texture2D( fboTex, gl_TexCoord[0].xy + vec2( offset.x, 0.0));

	vec4 color0m = texture2D( fboTex, gl_TexCoord[0].xy + vec2(0.0, -offset.y));
	vec4 color0p = texture2D( fboTex, gl_TexCoord[0].xy + vec2(0.0,  offset.y));
	
	vec4 colormm = texture2D( fboTex, gl_TexCoord[0].xy + vec2(-offset.x,-offset.y));
	vec4 colormp = texture2D( fboTex, gl_TexCoord[0].xy + vec2(-offset.x, offset.y));
	vec4 colorpm = texture2D( fboTex, gl_TexCoord[0].xy + vec2( offset.x,-offset.y));	
	vec4 colorpp = texture2D( fboTex, gl_TexCoord[0].xy + vec2( offset.x, offset.y));	

	vec4 color00 = texture2D( fboTex, gl_TexCoord[0].xy);
	
	vec4 resultColor = color00;
		
	bool loc1 = false;
	bool loc2 = false;
	bool loc3 = false;
	bool loc4 = false;
	bool loc5 = false;
	bool loc6 = false;
	bool loc7 = false;
	bool loc8 = false;
	bool loc9 = false;
	
	if(colormm.a > 0.1)
		loc1 = true;
	if(colormp.a > 0.1)
		loc7 = true;
	if(colorpm.a > 0.1)
		loc3 = true;
	if(colorpp.a > 0.1)
		loc9 = true;
		
	int location = 5;
	bool isInternal = false;
	
	if(loc1 && !loc9 && loc7 && !loc3)
		location = 6;
	if(loc1 && !loc9  && loc3 && !loc7)
		location = 8;
	if(loc3 && !loc7 && loc9 && !loc1)
		location = 4;
	if(loc7 && !loc3 && loc9 && !loc1)
		location = 2;
		
	if(loc1 && !loc7 && !loc3 && !loc9)
		location = 9;
	if(loc7 && !loc1 && !loc9 && !loc3)
		location = 3;
	if(loc9 && !loc7 && !loc3 && !loc1)
		location = 1;
	if(loc3 && !loc1 && !loc9 && !loc7)
		location = 7;

	if(loc1 && loc7 && loc3 && !loc9)
	{
		location = 1;
		isInternal = true;
	}
	if(loc7 && loc1 && loc9 && !loc3)
	{
		location = 7;
		isInternal = true;
	}
	if(loc9 && loc7 && loc3 && !loc1)
	{
		location = 9;
		isInternal = true;
	}
	if(loc3 && loc1 && loc9 && !loc7)
	{
		location = 3;
		isInternal = true;
	}
	
	vec2 fboCoord = gl_TexCoord[0].xy;
	fboCoord.y = 1.0 - fboCoord.y;
	vec2 texCoord = (fboCoord * mapCoord + scrollOffset) / tileSize + vec2(0.5, 0.5);
	texCoord.x = mod(texCoord.x, 1.0);
	texCoord.y = mod(texCoord.y, 1.0);

	vec4 borderColor = vec4(0.0, 0.0, 0.0, 0.0);
	if(location == 1)
	{
		if(isInternal)
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 0.0, 1.0 / 4.0 * 3.0));
		else
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 0.0, 1.0 / 4.0 * 1.0));
	}
			
	if(location == 2)
		borderColor += texture2D( targetSkin, texCoord / vec2(2.0, 4.0) + vec2(1.0 / 4.0 * 2.0, 1.0 / 4.0 * 1.0));

	if(location == 3)
	{
		if(isInternal)
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 1.0, 1.0 / 4.0 * 3.0));
		else
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 1.0, 1.0 / 4.0 * 1.0));
	}
	if(location == 6)
		borderColor += texture2D( targetSkin, texCoord / vec2(4.0, 2.0) + vec2(1.0 / 4.0 * 3.0, 1.0 / 4.0 * 2.0));
			
	if(location == 9)
	{
		if(isInternal)
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 1.0, 1.0 / 4.0 * 2.0));
		else
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 1.0, 1.0 / 4.0 * 0.0));
	}
	if(location == 8)
		borderColor += texture2D( targetSkin, texCoord / vec2(2.0, 4.0) + vec2(1.0 / 4.0 * 2.0, 1.0 / 4.0 * 0.0));

	if(location == 7)
	{
		if(isInternal)
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 0.0, 1.0 / 4.0 * 2.0));
		else
			borderColor += texture2D( targetSkin, texCoord / 4.0 + vec2(1.0 / 4.0 * 0.0, 1.0 / 4.0 * 0.0));
	}
	if(location == 4)
		borderColor += texture2D( targetSkin, texCoord / vec2(4.0, 2.0) + vec2(1.0 / 4.0 * 2.0, 1.0 / 4.0 * 2.0));

	borderColor.rgb *= borderColor.a;
	resultColor += borderColor;
	gl_FragColor = resultColor;
}
