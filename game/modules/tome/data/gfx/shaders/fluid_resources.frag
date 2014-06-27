uniform sampler2D tex;
uniform sampler2D mainfbo;
float antialiasingRadius = 0.99; //1.0 is no antialiasing, 0.0 - fully smoothed(looks worse)
uniform float tick;

float snoise( vec3 v );

vec4 Uberblend(vec4 col0, vec4 col1)
{
//  return vec4((1.0 - col0.a) * (col1.rgb) + col0.a * (col1.rgb * col1.a + col0.rgb * (1.0 - col1.a)), min(1.0, col0.a + col1.a));
//  return vec4((1.0 - col1.a) * (col0.rgb) + col1.a * (col1.rgb * col1.a + col0.rgb * (1.0 - col1.a)), min(1.0, col0.a + col1.a));
  return vec4(
    (1.0 - col0.a) * (1.0 - col1.a) * (col0.rgb * col0.a + col1.rgb * col1.a) / (col0.a + col1.a + 1e-1) +
    (1.0 - col0.a) * (0.0 + col1.a) * (col1.rgb) +
    (0.0 + col0.a) * (1.0 - col1.a) * (col0.rgb * (1.0 - col1.a) + col1.rgb * col1.a) +
    (0.0 + col0.a) * (0.0 + col1.a) * (col1.rgb),
    min(1.0, col0.a + col1.a));
}


float sqr(float x)
{
	return x * x;
}

struct Intersection
{
	vec3 point;
	vec3 norm;
	vec3 tangent;
	vec3 binormal;
	vec2 texCoord;
	float isValid;
};

Intersection GetCapsuleIntersection(vec2 pos, float spherePos0, float spherePos1, float radius)
{
	Intersection res;
	res.isValid = 0.0;
	if(pos.x < spherePos0 || pos.x > spherePos1)
	{
		vec3 sphereCenter;
		float texOffset = 0.0;
		if(pos.x < spherePos0)
		{
			sphereCenter = vec3(spherePos0, 0.0, 0.0);
		}else
		{
			sphereCenter = vec3(spherePos1, 0.0, 0.0);
			texOffset = spherePos1 - spherePos0;
		}
		float planarDist = length(vec3(pos, 0.0) - sphereCenter);
		if(sqr(planarDist) > sqr(radius))
		{
			res.isValid = 0.0;
			return res;
		}
		res.point = vec3(pos.x, pos.y, -sqrt(sqr(radius) - sqr(planarDist)));
		res.norm = normalize(res.point - sphereCenter);

		vec2 texdr = normalize(pos - sphereCenter.xy);
		vec2 texda = vec2(-texdr.y, texdr.x);

		vec3 globalda = normalize(cross(vec3(0.0, 0.0, 1.0), res.norm));
		vec3 globaldr = cross(res.norm, globalda);

		res.tangent = globalda * texda.x + globaldr * texdr.x;
		res.binormal = globalda * texda.y + globaldr * texdr.y;

		float sinAlpha = planarDist / radius;
		float alpha = asin(sinAlpha);
		res.texCoord = vec2(0.5 + texOffset, 0.5) + normalize(pos - sphereCenter.xy) * alpha * radius;


		res.isValid = 1.0;
	}else
	{
		if(sqr(pos.y) > sqr(radius))
		{
			res.isValid = 0.0;
			return res;
		}
		res.point = vec3(pos.x, pos.y, -sqrt(sqr(radius) - sqr(pos.y)));
		res.norm = vec3(0.0, normalize(res.point.yz));

		float sinAlpha = pos.y / radius;
		float alpha = asin(sinAlpha);
		res.texCoord = vec2(0.5 + pos.x - spherePos0, 0.5) + vec2(0.0, alpha * radius);

		vec2 texdr = vec2(0.0, pos.y > 0.0 ? 1.0 : -1.0);
		vec2 texda = vec2(-texdr.y, texdr.x);

		vec3 globalda = normalize(cross(vec3(0.0, 0.0, 1.0), res.norm));
		vec3 globaldr = cross(res.norm, globalda);

		res.tangent = globalda * texda.x + globaldr * texdr.x;
		res.binormal = globalda * texda.y + globaldr * texdr.y;

		res.isValid = 1.0;
	}
	return res;
}

vec2 Rotate(vec2 point, float ang)
{
	return vec2(
		point.x * cos(ang) - point.y * sin(ang),
		point.x * sin(ang) + point.y * cos(ang));
} 

float UnpackChannel(float m6, float m3, float m0, float p3)
{
	/*float diffm6 = abs(0.5 - m6);
	float diffm3 = abs(0.5 - m3);
	float diffm0 = abs(0.5 - m0);
	float diffp3 = abs(0.5 - p3);*/

	/*float diffm6 = 1.0 / (abs(0.5 - m6) + 1e-5);
	float diffm3 = 1.0 / (abs(0.5 - m3) + 1e-5);
	float diffm0 = 1.0 / (abs(0.5 - m0) + 1e-5);
	float diffp3 = 1.0 / (abs(0.5 - p3) + 1e-5);*/
	/*float diffm6 = pow((0.5 - abs(0.5 - m6)) * 2.0, 0.01);
	float diffm3 = pow((0.5 - abs(0.5 - m3)) * 2.0, 0.01);
	float diffm0 = pow((0.5 - abs(0.5 - m0)) * 2.0, 0.01);
	float diffp3 = pow((0.5 - abs(0.5 - p3)) * 2.0, 0.01);*/
	float diffm6 = clamp(m6 * (1.0 - m6), 0.0, 1.0);
	float diffm3 = clamp(m3 * (1.0 - m3), 0.0, 1.0);
	float diffm0 = clamp(m0 * (1.0 - m0), 0.0, 1.0);
	float diffp3 = clamp(p3 * (1.0 - p3), 0.0, 1.0);

	float sum = diffm6 + diffm3 + diffm0 + diffp3 + 1e-5;

	float hdrColorm6 = -log2(1.0 - m6 + 1e-3) / exp2(-6.0);
	float hdrColorm3 = -log2(1.0 - m3 + 1e-3) / exp2(-3.0);
	float hdrColorm0 = -log2(1.0 - m0 + 1e-3) / exp2( 0.0);
	float hdrColorp3 = -log2(1.0 - p3 + 1e-3) / exp2( 3.0);

	return 
		(hdrColorm6 * diffm6 / sum +
		 hdrColorm3 * diffm3 / sum +
		 hdrColorm0 * diffm0 / sum +
		 hdrColorp3 * diffp3 / sum);
}

vec4 UnpackHDR(vec2 planarPos)
{
	if(planarPos.y < 0.0 || planarPos.y > 1.0) return vec4(0.0, 0.0, 0.0, 0.0);

	float e = 0.005;
	vec4 texelm6 = texture2D(tex, (vec2(e, 0.0  + e) + planarPos  * vec2(1.0 - 2.0 * e, 0.25 - 2.0 * e)) * vec2(0.5, 0.5));
	vec4 texelm3 = texture2D(tex, (vec2(e, 0.25 + e)  + planarPos * vec2(1.0 - 2.0 * e, 0.25 - 2.0 * e)) * vec2(0.5, 0.5));
	vec4 texelm0 = texture2D(tex, (vec2(e, 0.5  + e) + planarPos  * vec2(1.0 - 2.0 * e, 0.25 - 2.0 * e)) * vec2(0.5, 0.5));
	vec4 texelp3 = texture2D(tex, (vec2(e, 0.75 + e)  + planarPos * vec2(1.0 - 2.0 * e, 0.25 - 2.0 * e)) * vec2(0.5, 0.5));	

	//return vec4(UnpackChannel(texelm6.r, texelm3.r, texelm0.r, texelp3.r), 1.0);
	return vec4(
		UnpackChannel(texelm6.r, texelm3.r, texelm0.r, texelp3.r),
		UnpackChannel(texelm6.g, texelm3.g, texelm0.g, texelp3.g),
		UnpackChannel(texelm6.b, texelm3.b, texelm0.b, texelp3.b),
		UnpackChannel(texelm6.a, texelm3.a, texelm0.a, texelp3.a));
}

vec4 GetSurfaceColor(vec3 pos, vec3 normal, float absorb, float useReflections, float useRefractions)
{
	vec3 viewDir = vec3(0.0, 0.0, 1.0);
	vec3 color = vec3(12.0 / 255.0, 18.0 / 255.0, 22.0 / 255.0) * 5.0;

	vec3 lightPos[4];
	/*lightPos[0] = vec3(2.0, 4.0, -2.0);
	lightPos[1] = vec3(1.0, -0.5, -1.0);*/
	/*lightPos[0] = vec3(2.0, 4.0, -2.0);
	lightPos[1] = vec3(5.0, -0.5, -1.0);
	lightPos[2] = vec3(4.0, 4.0, -2.0);
	lightPos[3] = vec3(3.0, -0.5, -1.0);*/
	//lightPos[2] = vec3(2.0, 4.5,  2.5);
	lightPos[0] = vec3(4.0 * cos(tick / 1000.0), 4.0 * sin(tick / 1000.0), -4.0);
	lightPos[1] = vec3(-1.0, 4.5,  2.5);
	lightPos[2] = vec3(-2.6, 2.0, -2.0);
	lightPos[3] = vec3(-1.0, 4.0, 100.0);
	float intensities[4];
	intensities[0] = 1.5;
	intensities[1] = 1.5;
	intensities[2] = 1.5;
	intensities[3] = 10.5;


	vec3 worldx = vec3(1.0, 0.0, 0.0);
	vec3 worldy = vec3(0.0, 1.0, 0.0);
	vec3 worldz = vec3(0.0, 0.0, 1.0);

//	float ang = 1.0;
	float ang = 1.1;
	worldy.yz = Rotate(worldy.yz, ang);
	worldz.yz = Rotate(worldz.yz, ang);
	//reflectedPos;
	vec3 reflectedDir = viewDir - dot(viewDir, normal) * normal * 2.0;
	vec4 reflectedColor = vec4(0.0, 0.0, 0.0, 0.0);

	vec3 localReflectedDir = vec3(
		dot(worldx, reflectedDir),
		dot(worldy, reflectedDir),
		dot(worldz, reflectedDir));
	//reflectedColor = texture2D(mainfbo, (gl_FragCoord.xy + vec2(0.0, 200.0)) / vec2(1266.0, 748.0));
	if(useReflections > 0.5)
	{
		if(localReflectedDir.z > 0.39)
		{
			reflectedColor = texture2D(mainfbo, (gl_FragCoord.xy + localReflectedDir.xy * (-pos.z * 100.0 + 100.0) / localReflectedDir.z * 1.0) / vec2(textureSize(mainfbo, 0).xy));
		}else
		{
			vec2 planarPos;
			float pi = 3.141592;
			planarPos.x = (atan(localReflectedDir.y, localReflectedDir.x) + pi) / (2.0 * pi);
			planarPos.y = (atan(localReflectedDir.z, length(localReflectedDir.xy)) + pi / 2.0) / pi;
			/*if(planarPos.y > 0.6)
			{
				reflectedColor = texture2D(mainfbo, (gl_FragCoord.xy + reflectedDir.xy * (-pos.z * 100.0 + 70.0) / reflectedDir.z * 1.0) / vec2(textureSize(mainfbo, 0).xy));
			}else*/
			{
				//float ang = 1.0;
//				planarPos.y *= 1.6;
//				planarPos.x = mod(planarPos.x - 0.1, 1.0);
				/*planarPos.y *= 1.6;
				planarPos.x = mod(planarPos.x + 0.2, 1.0);*/
				planarPos.y *= 1.6;
				planarPos.x = mod(planarPos.x + 0.19, 1.0); //24

				reflectedColor = UnpackHDR(planarPos) * 1.0;
			}
		}

		//my lame reflection coefficient
		//reflectedColor.a = pow(reflectedDir.z, 1.0) * 0.3;
		//standard frensel approximation
		/*reflectedColor.a = pow(1.0 - clamp(abs(dot(viewDir, normal)), 0.0, 1.0), 4.0);*/


		//more advanced frensel approximation
		float fZero = pow( (1.0 - (1.0 / 1.31)) / (1.0 + (1.0 / 1.31)), 2.0);
		float base = max(0.0, 1.0 + dot(viewDir, normal)); // better do the max here. (According to the OptiX source code not a bad idea as there are cases which yield artifacts if omitted.)
		float e = pow(base, 5.0);
		reflectedColor.a = clamp((fZero + (1.0 - fZero) * e) * 3.0, 0.0, 1.0);
	}

	//http://en.wikipedia.org/wiki/Snell's_law#Vector_form	
	float n1 = 1.0;
	float n2 = 2.0;

	float r = n1 / n2;
	float c = -dot(viewDir, normal);

	vec3 refractedDir = r * viewDir + (r * c - sqrt(1.0 - r * r * (1.0 - c * c))) * normal;
	vec4 refractedColor = vec4(0.0, 0.0, 0.0, 0.0);

	vec3 localRefractedDir = vec3(
		dot(worldx, refractedDir),
		dot(worldy, refractedDir),
		dot(worldz, refractedDir));
	if(useRefractions > 0.5)
	{
		if(localRefractedDir.z > 0.38)
		{
			refractedColor = texture2D(mainfbo, (gl_FragCoord.xy + localReflectedDir.xy * (-pos.z * 100.0 + 10.0) / localReflectedDir.z * 1.0) / vec2(textureSize(mainfbo, 0).xy));
		}else
		{
			vec2 planarPos;
			float pi = 3.141592;
			planarPos.x = (atan(localRefractedDir.y, localRefractedDir.x) + pi) / (2.0 * pi);
			planarPos.y = (atan(localRefractedDir.z, length(localRefractedDir.xy)) + pi / 2.0) / pi;

			planarPos.y *= 1.6;
			planarPos.x = mod(planarPos.x + 0.19, 1.0); //24

			refractedColor = UnpackHDR(planarPos) * 1.0;
		}

		//my lame reflection coefficient
		//reflectedColor.a = pow(reflectedDir.z, 1.0) * 0.3;
		//standard frensel approximation
		/*reflectedColor.a = pow(1.0 - clamp(abs(dot(viewDir, normal)), 0.0, 1.0), 4.0);*/


		refractedColor.a = 1.0;//clamp((fZero + (1.0 - fZero) * e) * 3.0, 0.0, 1.0);
	}


	float diffuseMult = 0.0; 
	float specMult = 0.0;
	for(int i = 0; i < 1; i++)
	{
		vec3 normLightDir = normalize(pos - lightPos[i]);
		diffuseMult += max(0.0, -dot(normLightDir, normal));
		if(dot(normLightDir, normal) < 0.0)
		{
			vec3 reflectedDir = normLightDir - dot(normLightDir, normal) * normal * 2.0;
			if(dot(reflectedDir, viewDir) < 0.0)
			{
				specMult += pow(-dot(reflectedDir, viewDir), 40.0) * intensities[i] * 1.0;
			}
		}
	}
//	vec4 diffuseColor = vec4(vec3(1.0, 1.0, 1.0) * diffuseMult, 1.0);//vec4(color * (diffuseMult * 0.8 + 0.2), 1.0 - absorb);
	vec4 diffuseColor = vec4(color * (diffuseMult * 0.8 + 0.2), 1.0 - absorb);
	vec4 specularColor = vec4(vec3(1.0, 1.0, 1.0), clamp(specMult, 0.0, 1.0))*0.0;
//	return Uberblend(Uberblend(diffuseColor, reflectedColor), specularColor);
//	return diffuseColor + vec4(reflectedColor.rgb, 1.0);//Uberblend(diffuseColor, reflectedColor);
	return Uberblend(diffuseColor, reflectedColor);
//	return refractedColor;

	/*reflectedColor.a = 1.0;
	return reflectedColor;*/
}

vec3 snoise3(vec2 pos, float seed)
{
	return vec3(snoise(vec3(pos, seed + 0.0)), snoise(vec3(pos, seed + 1.0)), snoise(vec3(pos, seed + 2.0)));
}

float reduce(float val, float reduction)
{
	if(abs(val) < reduction) return 0.0;
	if(val < 0.0) return val + reduction;
	return val - reduction;
}

vec3 reduce3(vec3 val, float reduction)
{
	return vec3(reduce(val.x, reduction), reduce(val.y, reduction), reduce(val.z, reduction));
}
vec3 GetNormalOffset(vec2 surfaceCoords, float seed)
{
	vec3 noise = snoise3(surfaceCoords * 10.0, seed) * 1.0;
	noise += snoise3(surfaceCoords * 20.0, seed) * 1.0;
	noise += snoise3(surfaceCoords * 30.0, seed) * 1.0;
	noise /= 3.0;
	return reduce3(noise, 0.3) * 0.3;
}

vec4 GetCheckboardColor(vec2 pos)
{
	vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
	//if(pos.x > 0.0 && pos.x < 1.0 && pos.y > 0.0 && pos.y < 1.0)
	{
		if(mod(pos.x, 0.1) < 0.05 ^^ mod(pos.y, 0.1) < 0.05)
			col = vec4(pos.x, pos.y, 0.0, 1.0);
		else
			col = vec4(0.0, 0.0, 0.0, 1.0);
	}
	return col;
}

float GetFireDelta(float currTime, vec2 pos, float freqMult, float stretchMult, float scrollSpeed, float evolutionSpeed)
{
	//firewall
	float delta = 0.0;
//	pos.y += (1.0 - pos.y) * 0.5;
	//pos.y += 0.5;
	pos.y /= stretchMult;
	pos *= freqMult;
	pos.y += currTime * scrollSpeed;

//	pos.y -= currTime * 3.0;
	delta += snoise(vec3(pos * 1.0, currTime * 1.0 * evolutionSpeed)) * 1.5;
	delta += snoise(vec3(pos * 2.0, currTime * 2.0 * evolutionSpeed)) * 1.5;
	delta += snoise(vec3(pos * 4.0, currTime * 4.0 * evolutionSpeed)) * 1.5;	
	delta += snoise(vec3(pos * 8.0, currTime * 8.0 * evolutionSpeed)) * 1.5;
	delta += snoise(vec3(pos * 16.0, currTime * 16.0 * evolutionSpeed)) * 0.5;

	return delta;
}

void main(void)
{
	float sideRatio = 7.0;
//	float sideRatio = 1.0;
	float radius = 1.0 / sideRatio / 2.0;
	float innerRadius = radius - 0.007;//0.05 * 0.9;

	float progress = sin(tick / 2000.0) * 0.5 + 0.5;
	float flameWidth = 0.05;

	vec2 pos;
	pos.x = gl_TexCoord[0].x;
	pos.y = (1.0 - gl_TexCoord[0].y - 0.5) * sideRatio + 0.5;
	pos.y = (pos.y - 0.5) * 2.0 * radius;
	//gl_FragColor = vec4(pos, 0.0, 1.0);	 return;

	if(pos.x > 1.0 || pos.x < 0.0 || pos.y < -radius || pos.y > radius)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}

	float currPos = (pos.x - (radius - innerRadius)) / (1.0 - 2.0 * (radius - innerRadius));

	Intersection outerIntersection = GetCapsuleIntersection(pos, radius, 1.0 - radius, radius);
	Intersection innerIntersection = GetCapsuleIntersection(pos, radius, 1.0 - radius, innerRadius);

	vec2 normalCoord = (outerIntersection.texCoord - vec2(0.0, 0.5)) * vec2(1.0, 2.0) + vec2(0.0, 0.5);
//	vec4 normalMap = texture2D(tex, vec2(0.01, 0.51) + mod(normalCoord, 1.0) * vec2(0.98, 0.48));
	vec4 normalMap = texture2D(tex, vec2(0.0, 0.51) + mod(normalCoord, 1.0) * vec2(1.0, 0.48));
	vec3 localNormal = normalMap.rgb - vec3(0.5, 0.5, 0.5);
	localNormal = normalize(localNormal);

	vec3 xBasis = outerIntersection.tangent;
	vec3 yBasis = outerIntersection.binormal;
	vec3 zBasis = outerIntersection.norm;

	vec3 globalNormal = localNormal.x * xBasis + localNormal.y * yBasis + localNormal.z * zBasis;

	float ratio = 1.0 - pow(1.0 - abs(outerIntersection.norm.z), 1.0);
	//float ratio =pow(abs(outerIntersection.norm.z), 3.0);
	outerIntersection.norm = globalNormal * ratio + (1.0 - ratio) * outerIntersection.norm;
	outerIntersection.norm = normalize(outerIntersection.norm);

	if(outerIntersection.isValid < 0.5)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}

	float pathLen = 0.0;
	float fluidThickness = 0.0;

	if(innerIntersection.isValid > 0.5)
	{
		pathLen = abs(innerIntersection.point.z - outerIntersection.point.z);
		fluidThickness = 2.0 * abs(innerIntersection.point.z);
	}
	else
	{
		pathLen = abs(2.0 * outerIntersection.point.z);
	}
	float capsuleAbsorb = exp(-pathLen * 25.0);

	vec3 resultShininess = vec3(0.0, 0.0, 0.0);
	vec4 resultColor = vec4(0.0, 0.0, 0.0, 0.0);
	if(outerIntersection.isValid > 0.5)
		resultColor = GetSurfaceColor(outerIntersection.point, outerIntersection.norm, capsuleAbsorb, 1.0, 1.0);
	if(innerIntersection.isValid > 0.5)
	{
		vec3 internalIntersectionPoint = innerIntersection.point;
		internalIntersectionPoint.z *= -1.0;
		vec3 innerIntersectionNormal = innerIntersection.norm;
		innerIntersectionNormal.z *= -1.0;
		innerIntersectionNormal *= -1.0;

		vec4 fluidColor = vec4(0.0, 0.0, 0.0, 0.0);
		if(currPos < progress + flameWidth)
		{
			float fluidOffset = GetFireDelta(tick / 2000.0, innerIntersection.texCoord + vec2(-tick / 6000.0, 0), 1.0, 1.0, 0.0, 1.0);


			float texPos = clamp(sqr(fluidOffset) * 0.1, 0.0, 1.0);

			vec4 texColorLow  = texture2D(tex, vec2(0.5 + 0.00 + 0.125, 0.49) - vec2(0.0, 0.48) * texPos);
			vec4 texColorHigh = texture2D(tex, vec2(0.5 + 0.25 + 0.125, 0.49) - vec2(0.0, 0.48) * texPos);
			vec4 texColor = progress * texColorHigh + (1.0 - progress) * texColorLow;

			fluidColor.rgb = texColor;
			fluidColor.a = 1.0;
			resultShininess = texColor.rgb * texColor.a * capsuleAbsorb * sqr(fluidOffset) * 0.1;


			if(currPos > progress && currPos < progress + flameWidth)
			{
				float flameMult = (currPos - progress) * ((progress + flameWidth) - currPos) / sqr(flameWidth / 2.0);
				float flameVerticalPos = (currPos - progress) / flameWidth;
				float flameDelta = GetFireDelta(tick / 2000.0, innerIntersection.texCoord + vec2(-tick / 6000.0, 0), 1.0, 1.0, 0.0, 1.0) * 0.1;
				float alphaMult = clamp(1.0 - flameVerticalPos + flameDelta * pow(flameMult, 3.0), 0.0, 1.0);
				fluidColor.a *= alphaMult;
				resultShininess *= alphaMult;
				resultShininess *= (flameVerticalPos) * (1.0 - flameVerticalPos) * 100.0 + 1.0;
			}
		}
		vec4 backColor = Uberblend(
			GetSurfaceColor(internalIntersectionPoint, innerIntersectionNormal, capsuleAbsorb, 1.0, 0.0),
			fluidColor);
		resultColor = Uberblend(backColor, resultColor);
//		resultColor = fluidColor;
	}
	gl_FragColor = vec4(resultColor.rgb * resultColor.a + resultShininess, resultColor.a);
//	gl_FragColor = vec4(0.0, (outerIntersection.texCoord.y - 0.5)*1.0, 0.0, 1.0);
//	gl_FragColor = GetCheckboardColor(outerIntersection.texCoord * 2.0);//vec4(-(outerIntersection.texCoord.x - 0.6)*1.0, 0.0, 0.0, 1.0);
}


vec4 permute( vec4 x ) {

	return mod( ( ( x * 34.0 ) + 1.0 ) * x, 289.0 );

} 

vec4 taylorInvSqrt( vec4 r ) {

	return 1.79284291400159 - 0.85373472095314 * r;

}

float snoise( vec3 v ) {

	const vec2 C = vec2( 1.0 / 6.0, 1.0 / 3.0 );
	const vec4 D = vec4( 0.0, 0.5, 1.0, 2.0 );

	// First corner

	vec3 i  = floor( v + dot( v, C.yyy ) );
	vec3 x0 = v - i + dot( i, C.xxx );

	// Other corners

	vec3 g = step( x0.yzx, x0.xyz );
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	vec3 x1 = x0 - i1 + 1.0 * C.xxx;
	vec3 x2 = x0 - i2 + 2.0 * C.xxx;
	vec3 x3 = x0 - 1. + 3.0 * C.xxx;

	// Permutations

	i = mod( i, 289.0 );
	vec4 p = permute( permute( permute(
		i.z + vec4( 0.0, i1.z, i2.z, 1.0 ) )
		+ i.y + vec4( 0.0, i1.y, i2.y, 1.0 ) )
		+ i.x + vec4( 0.0, i1.x, i2.x, 1.0 ) );

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)

	float n_ = 1.0 / 7.0; // N=7

	vec3 ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor( p * ns.z *ns.z );  //  mod(p,N*N)

	vec4 x_ = floor( j * ns.z );
	vec4 y_ = floor( j - 7.0 * x_ );    // mod(j,N)

	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs( x ) - abs( y );

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );


	vec4 s0 = floor( b0 ) * 2.0 + 1.0;
	vec4 s1 = floor( b1 ) * 2.0 + 1.0;
	vec4 sh = -step( h, vec4( 0.0 ) );

	vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

	vec3 p0 = vec3( a0.xy, h.x );
	vec3 p1 = vec3( a0.zw, h.y );
	vec3 p2 = vec3( a1.xy, h.z );
	vec3 p3 = vec3( a1.zw, h.w );

	// Normalise gradients

	vec4 norm = taylorInvSqrt( vec4( dot( p0, p0 ), dot( p1, p1 ), dot( p2, p2 ), dot( p3, p3 ) ) );
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value

	vec4 m = max( 0.6 - vec4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
	m = m * m;
	return 42.0 * dot( m*m, vec4( dot( p0, x0 ), dot( p1, x1 ),
		dot( p2, x2 ), dot( p3, x3 ) ) );

}  

