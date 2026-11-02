// SKYLIGHT SUN (fake, no lights): afternoon sun coming down through rows of
// skylights in a venue's two sloped side roofs, painted as warm skylight-shaped
// patches on whatever it would land on. Each point traces back toward the sun to
// each roof slope and asks "is this glass?". Set per stage by
// Stage.apply_sun_windows from the stage's "sun_windows" entry; jv_sun.w = 0
// (every other stage) switches it off. All in world metres.
//   jv_sun      xyz = direction TOWARD the sun, w = strength
//   jv_sun_win  the roof: y = x - y * |x| (x = height at |x| 0, y = drop per metre),
//               glass from |x| = z to |x| = w
//   jv_sun_grid x = skylight centre to centre along z, y = skylight width,
//               z = edge softness, w = half the run along z
//   jv_sun_col  the light's colour (sRGB)
global uniform vec4 jv_sun;
global uniform vec4 jv_sun_win;
global uniform vec4 jv_sun_grid;
global uniform vec3 jv_sun_col;

float _jv_sky_side(vec3 p, vec3 sd, float side) {
	float denom = sd.y + jv_sun_win.y * side * sd.x;
	if (denom <= 0.0001) {
		return 0.0;
	}
	float t = (jv_sun_win.x - jv_sun_win.y * side * p.x - p.y) / denom;
	if (t <= 0.0) {
		return 0.0;
	}
	vec3 q = p + sd * t;
	float soft = jv_sun_grid.z;
	float ax = q.x * side;
	float inx = smoothstep(jv_sun_win.z - soft, jv_sun_win.z + soft, ax)
		* (1.0 - smoothstep(jv_sun_win.w - soft, jv_sun_win.w + soft, ax));
	float cell = abs(fract(q.z / jv_sun_grid.x + 0.5) - 0.5) * jv_sun_grid.x;
	float inz = 1.0 - smoothstep(jv_sun_grid.y * 0.5 - soft, jv_sun_grid.y * 0.5 + soft, cell);
	inz *= 1.0 - smoothstep(jv_sun_grid.w - soft, jv_sun_grid.w + soft, abs(q.z));
	return inx * inz;
}

// 0..1: how much skylight sun reaches world point p, on a surface facing n
float jv_sun_light(vec3 p, vec3 n) {
	if (jv_sun.w <= 0.0) {
		return 0.0;
	}
	vec3 sd = normalize(jv_sun.xyz);
	float lit = max(_jv_sky_side(p, sd, 1.0), _jv_sky_side(p, sd, -1.0));
	// anything not facing down catches it: the step risers you see from the court
	// face away from the sun on one side, and a lit crowd on dark seats read wrong
	float face = clamp(n.y * 3.0 + 1.0, 0.0, 1.0);
	return lit * face * jv_sun.w;
}
