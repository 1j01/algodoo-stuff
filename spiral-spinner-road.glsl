// This generates a spiral texture for a paper-craftable animated road
// It also simulates a static overlay on top of the spinning spiral disk.
//
// It was designed in Shadertoy, so it uses Shadertoy's uniforms and such.
// This shader can be viewed here: https://shadertoy.com/view/Ns33zB
//
// To see the paper craft in action, check the repo here: https://github.com/1j01/algodoo-stuff/
// You can at least play around with it in Algodoo, as a physics simulation,
// (along with some much less practical but also interesting conveyor belt based variations),
// but I may release a video of it and instructions later on,
// which I would post in that repo somewhere.
//
// 'E' toggles between exportable texture and preview
// 'R' reverses rotation

bool keyToggle(int ascii) {
	return (texture(iChannel0,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float spinnerTexture(vec2 m) {
	float r = length(m);
	if (r > 1.3) return 1.;
	float a = atan(m.y, m.x);
	//return smoothstep(0.6, 2., mod(r*a*50., 4.));
	//return smoothstep(0.15, 0.16, mod(a - pow(r, 8.)*0.9, 3.1415926/10.));
	//return smoothstep(0.15, 0.16, mod(a - pow(r-.2, 9.)*3., 3.1415926/10.));
	return smoothstep(0.15, 0.16, mod(a - pow(r, 8.)*0.9, 3.1415926/10.));
}
vec2 rotateUV(vec2 uv, float rotation, vec2 mid)
{
	return vec2(
	  cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
	  cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
	);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t = iTime;
	if (keyToggle(82)) t=-t; // 'R' for "Reverse"
	if (keyToggle(80)) t=0.; // 'P' for "Pause"
	bool showSpinnerTexture = keyToggle(69); // 'E' for "Export", as the product is the spinner texture
	bool showDebug = keyToggle(68); // 'D' for "Debug"

	vec2 uv = fragCoord.xy / iResolution.y;

	vec2 m = iMouse.xy / iResolution.y;
	if ((length(m)==0.) || (iMouse.z<0.)) m = vec2(1.2,-.7);
	if (showSpinnerTexture) m = vec2(0.5);

	float v = spinnerTexture(rotateUV(m-uv, t*2., vec2(0)) * (showSpinnerTexture ? 2.62 : 1.));

	uv = fragCoord.xy / iResolution.xy;
	vec3 col = vec3(v);

	float horizonY = 0.5;
	float roadCenterX = 0.5;//0.7-sin(uv.y)*0.2;
	float roadWidth = 0.5*(1.-uv.y*2.*0.96);//pow(10.7, uv.y);
	float stripWidth = 0.15;
	float xOnRoad = abs(uv.x - roadCenterX) / roadWidth; // x in pavement texture space
	float sideLineWidth = stripWidth; // doesn't make sense mathematically yet
	float sideLineOffsetX = 0.8;
	float grass = smoothstep(1., 1.006, xOnRoad);
	float strip = 1. - smoothstep(0.1, 0.2, xOnRoad / stripWidth);
	float sideLine = 1. - smoothstep(sideLineWidth, sideLineWidth * 1.2, abs((xOnRoad - sideLineOffsetX)) / sideLineWidth);

	// grass and asphalt
	vec3 overlayCol = grass * vec3(0.094,0.749,0.094);
	// side-line
	overlayCol = mix(overlayCol, vec3(1.), sideLine);
	// sky
	if (uv.y > horizonY) {
		overlayCol = vec3(0.600,0.992,1.000);
		strip = 0.;
	}

	col = mix(overlayCol, col, showSpinnerTexture ? 1. : (showDebug ? (0.5 + strip * 0.5) : strip));

	fragColor = vec4(col,1.);
}
