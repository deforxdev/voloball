// CUBE-TILE FLOOR for the void / Tutorial stage: the ground is built out of
// actual beveled 3D tile-blocks (a MultiMesh grid), not a flat checker texture.
// Fakes a top-down light per face (bright tops, dark sides) AND darkens each tile
// toward its base, so the gaps between tiles read as real dark seams / depth.
// Reads the per-instance COLOR for the checker tint. Unshaded + cull_disabled (the
// beveled mesh sets its own normals, so winding never matters).
shader_type spatial;
render_mode unshaded, cull_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// TIME OF DAY: the venue's light (Stage.apply_time_of_day sets it per match; white by
// day). players and the ball never read it, so they stay bright and readable at night.
global uniform vec3 jv_world_tint;

uniform vec3 light_dir = vec3(-0.4, 0.9, 0.35);
uniform float side_shade : hint_range(0.0, 1.0) = 0.58;   // more top/side contrast -> tiles read as 3D, not flat
uniform vec3 underside : source_color = vec3(0.16, 0.42, 0.95);   // BLUE-LIT undersides / lower edges
uniform float tile_height = 0.35;                          // set by cube_floor.gd

// --- FOOTSTEP SEAM PULSE (cheap, GPU-only; driven by synced body positions in
// cube_floor.gd, so it auto-syncs offline/online) ---
// Instead of a geometric dip (read as harsh/poppy), the SEAMS between tiles glow
// blue in a soft wave that radiates from each footstep, easing in and out so it
// never starts/ends abruptly. A faint standing glow sits under grounded feet.
uniform vec4 feet[8];        // xyz = world pos, w = weight (grounded)
uniform int feet_count = 0;
uniform float foot_glow : hint_range(0.0, 2.0) = 0.35;   // soft seam glow under a standing body
uniform float foot_radius = 2.3;
uniform vec4 ripples[24];    // xy = world xz, z = age (s), w = strength
uniform int ripple_count = 0;
uniform float rip_speed = 6.5;    // ring expansion (m/s)
uniform float rip_width = 2.4;    // ring thickness (m) -- wider = softer
uniform float rip_life = 1.4;     // seconds (must match cube_floor.gd)
uniform vec3 pulse_color : source_color = vec3(0.25, 0.55, 1.0);   // the blue that pulses the seams
uniform float pulse_gain : hint_range(0.0, 3.0) = 0.9;

// --- PLAYABLE-AREA TINT: the court region reads distinctly from the decorative
// floor (a soft blue fill + a brighter edge glow at the boundary). court_hw/hl are
// the court half-extents, set by cube_floor.gd's configure() (match + freeplay). ---
uniform float court_hw = 0.0;   // 0 = no tint until configured
uniform float court_hl = 0.0;
uniform vec3 court_tint : source_color = vec3(0.3, 0.55, 1.0);
uniform float court_fill : hint_range(0.0, 1.0) = 0.24;   // subtle blue over the whole court
uniform float court_edge : hint_range(0.0, 2.0) = 0.9;    // brighter glow at the boundary
uniform float court_edge_w = 2.2;                          // edge band width (m)

varying vec3 world_normal;
varying vec3 tint;
varying float up_frac;   // 0 at the tile base, 1 at the top
varying vec3 world_pos;  // per-pixel world position (the court tint cuts on it)
varying vec2 tile_xz;    // tile centre (for the per-tile pulse)

// 0..1 pulse at a tile: expanding rings from footsteps (eased in/out so it's
// smooth, not poppy) + a soft standing glow under grounded feet.
float _pulse(vec2 p) {
	float v = 0.0;
	for (int i = 0; i < ripple_count; i++) {
		float d = distance(p, ripples[i].xy);
		float r = ripples[i].z * rip_speed;                 // current ring radius
		float band = exp(-pow((d - r) / rip_width, 2.0));   // gaussian ring
		float lt = ripples[i].z / rip_life;                 // 0..1 life
		float env = smoothstep(0.0, 0.18, lt) * (1.0 - smoothstep(0.55, 1.0, lt));
		v += ripples[i].w * band * env;
	}
	for (int i = 0; i < feet_count; i++) {
		float d = distance(p, feet[i].xz);
		v += foot_glow * feet[i].w * exp(-(d * d) / (foot_radius * foot_radius));
	}
	return clamp(v, 0.0, 1.0);
}

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	tint = COLOR.rgb;   // per-tile checker colour (MultiMesh instance colour)
	up_frac = clamp(VERTEX.y / max(tile_height, 0.0001) + 0.5, 0.0, 1.0);
	tile_xz = MODEL_MATRIX[3].xz;   // instance centre
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float d = clamp(dot(world_normal, normalize(light_dir)) * 0.5 + 0.5, 0.0, 1.0);
	// blue-lit toward the base, pearl tint toward the top (undersides glow blue,
	// and the thin seams between flush tiles read as restrained blue light)
	vec3 base = mix(jv_in(underside), tint, smoothstep(0.0, 0.85, up_frac));
	vec3 col = base * mix(side_shade, 1.0, d);
	// SEAM PULSE: brighten the tile edges/base (the seams) blue where a wave passes
	float seam = 1.0 - smoothstep(0.0, 0.45, up_frac);   // strong at the base/edges
	col += jv_in(pulse_color) * (_pulse(tile_xz) * pulse_gain * seam);
	// PLAYABLE-AREA TINT: mark the court region so it stands out from the floor
	if (court_hw > 0.001) {
		// PER PIXEL, not per tile: deciding by the tile CENTRE tinted whole tiles that
		// straddle the boundary, so the blue stair-stepped past the court lines.
		// Now it cuts exactly on the line (anti-aliased by the pixel footprint).
		vec2 a = abs(world_pos.xz);
		vec2 aa = max(fwidth(world_pos.xz), vec2(0.001));
		float inside = (1.0 - smoothstep(court_hw - aa.x, court_hw + aa.x, a.x))
			* (1.0 - smoothstep(court_hl - aa.y, court_hl + aa.y, a.y));
		col = mix(col, jv_in(court_tint), court_fill * inside);
		float edge = max(smoothstep(court_hw - court_edge_w, court_hw, a.x),
			smoothstep(court_hl - court_edge_w, court_hl, a.y)) * inside;
		col += jv_in(court_tint) * edge * court_edge;
	}
	ALBEDO = jv_out(col * jv_world_tint);
}
