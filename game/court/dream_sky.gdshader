// DREAM SKY for the "void" / Tutorial training stage. A cozy cosmic backdrop --
// Mario Galaxy / Disney Universe "world select" vibe: a soft blue -> indigo
// gradient, a gentle dreamy glow low in the sky, and soft round twinkling stars.
// Deliberately NOT the moon stage's look (no nebula wisps, no earth, no harsh
// near-black space, softer round stars, not 4-point sparkles) -- this is the
// bright, friendly cousin. shader_type sky, drops into a stage's `sky_shader`.
shader_type sky;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

// DEEP NAVY / ULTRAMARINE space with a subtle cobalt haze -- the "world select"
// cosmos so the white court + cubes pop against the dark. (The moon stage's
// SPACE_SKY has its own nebula/earth; this one is cleaner, cube-platform themed.)
// BRIGHT, AIRY near-white with a faint blue tint (dreamy Wii/Paper-Mario "sky
// world"): a very light gradient so the scene reads soft + friendly, not dark.
uniform vec3 top_color : source_color = vec3(0.62, 0.76, 0.91);      // soft blue overhead
uniform vec3 mid_color : source_color = vec3(0.80, 0.88, 0.96);      // pale blue
uniform vec3 horizon_color : source_color = vec3(0.92, 0.95, 0.98);  // near-white at the horizon
uniform vec3 glow_color : source_color = vec3(0.9, 0.95, 1.0);       // faint white haze
uniform float glow_amount : hint_range(0.0, 2.0) = 0.1;
uniform float glow_falloff : hint_range(0.5, 8.0) = 3.5;

// stars off by default (the bright sky hides them); kept for optional use
uniform float star_density : hint_range(10.0, 200.0) = 60.0;
uniform float star_brightness : hint_range(0.0, 4.0) = 0.0;
uniform float star_size : hint_range(0.01, 0.2) = 0.02;
uniform float star_twinkle_speed : hint_range(0.0, 4.0) = 0.3;

// spiral galaxies OFF by default here -- they belong to the space map. Code kept
// so the void could opt back in with a nonzero amount.
uniform float galaxy_amount : hint_range(0.0, 2.0) = 0.0;
uniform vec3 galaxy_color : source_color = vec3(0.4, 0.62, 1.0);

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// cube-face projection so stars have stable cell sizes and no pole pinch
vec2 star_uv(vec3 d) {
	vec3 a = abs(d);
	if (a.x >= a.y && a.x >= a.z) {
		return d.yz / a.x + (d.x > 0.0 ? vec2(7.31, 3.97) : vec2(19.7, 11.3));
	} else if (a.y >= a.z) {
		return d.xz / a.y + (d.y > 0.0 ? vec2(31.9, 5.1) : vec2(13.7, 29.3));
	}
	return d.xy / a.z + (d.z > 0.0 ? vec2(23.1, 17.9) : vec2(3.3, 37.7));
}

// SOFT round stars (bokeh), gentle twinkle -- a core plus a wide soft halo on the
// brighter ones so they read as dreamy glowing dots, not hard points/sparkles.
float stars(vec3 dir, float time) {
	vec2 uv = star_uv(dir) * star_density * 0.06;
	vec2 cell = floor(uv);
	vec2 f = fract(uv);
	float h = hash12(cell);
	if (h < 0.62) {
		return 0.0;
	}
	vec2 star_pos = vec2(hash12(cell + 3.7), hash12(cell + 9.2)) * 0.8 + 0.1;
	float d = length(f - star_pos);
	float mag = pow(hash12(cell + 27.1), 1.6);          // brightness spread
	float core = smoothstep(star_size, 0.0, d);
	float halo = smoothstep(star_size * 4.0, 0.0, d) * 0.35;   // soft bokeh glow
	float tw = 0.6 + 0.4 * sin(time * star_twinkle_speed * (2.0 + h * 6.0) + h * 40.0);
	return (core + halo) * tw * mag;
}

// a soft spiral galaxy centred on eye-direction `gdir`: bright core, faint curved
// arms, and a thin orbital ring -- the Mario-Galaxy world-select motif.
float galaxy(vec3 dir, vec3 gdir, float size, float arms, float twist) {
	gdir = normalize(gdir);
	if (dot(dir, gdir) < 0.0) {
		return 0.0;   // other side of the sky
	}
	vec3 up = abs(gdir.y) < 0.9 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
	vec3 tx = normalize(cross(up, gdir));
	vec3 ty = cross(gdir, tx);
	vec2 p = vec2(dot(dir, tx), dot(dir, ty)) / size;
	float r = length(p);
	if (r > 1.2) {
		return 0.0;
	}
	float a = atan(p.y, p.x);
	float spiral = 0.5 + 0.5 * cos(arms * a + twist * r * 6.0);   // curved arms
	float disc = smoothstep(1.0, 0.12, r);
	float core = smoothstep(0.13, 0.0, r);                         // bright centre
	float ring = smoothstep(0.05, 0.0, abs(r - 0.72)) * 0.4;       // orbital ring
	return core * 1.4 + spiral * disc * disc * 0.6 + ring;
}

void sky() {
	vec3 dir = EYEDIR;
	float h = clamp(dir.y, 0.0, 1.0);

	// vertical gradient that goes DEEP blue quickly, so even the near-horizontal
	// gameplay view reads as cosmos (not a pale daytime sky): horizon -> cosmic
	// blue by h~0.2, easing to indigo overhead.
	vec3 col = mix(jv_in(horizon_color), jv_in(mid_color), smoothstep(0.0, 0.2, h));
	col = mix(col, jv_in(top_color), smoothstep(0.16, 0.72, h));

	// dreamy bloom hugging the low sky (tight, subtle -- not a bright wash)
	float glow = exp(-max(dir.y, 0.0) * glow_falloff);
	col += jv_in(glow_color) * glow * glow_amount;

	// soft stars, fading in just above the horizon so the whole sky is starry
	col += vec3(stars(dir, TIME)) * star_brightness * smoothstep(0.02, 0.16, dir.y);

	// a few distant spiral galaxies (subtle), placed around the upper-mid sky
	float g = galaxy(dir, vec3(-0.72, 0.34, -0.60), 0.22, 2.0, 1.0)
		+ galaxy(dir, vec3(0.76, 0.26, -0.52), 0.16, 3.0, -1.2) * 0.85
		+ galaxy(dir, vec3(0.15, 0.5, 0.85), 0.13, 2.0, 1.6) * 0.7;
	col += jv_in(galaxy_color) * g * galaxy_amount;

	COLOR = jv_out(col);
}
