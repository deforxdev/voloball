shader_type spatial;
// Flat, unshaded cartoon ground for the grass court. GrassField reskins the venue's
// EnvFloor with this so the floor and the grass blades share ONE brightness/tint and
// are both lighting-independent -- otherwise the lit StandardMaterial floor renders
// darker in-game (lower ambient) than the shader-bright blades, and they stop matching.
// Samples the same ground texture in world space (the floor is flat, so world xz IS
// the triplanar top face), then applies the field's tint * brightness.

render_mode unshaded, cull_back;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// TIME OF DAY: the venue's light (Stage.apply_time_of_day sets it per match; white by
// day). players and the ball never read it, so they stay bright and readable at night.
global uniform vec3 jv_world_tint;

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float world_scale = 1.0;                 // tiles per metre (matches the old triplanar)
uniform vec3 tint : source_color = vec3(1.0);
uniform float brightness : hint_range(0.0, 3.0) = 1.0;

// brighter-green patches, IDENTICAL function/inputs to grass.gdshader so the ground and
// the blades share the same patches.
uniform vec3 patch_color : source_color = vec3(0.62, 0.92, 0.34);
uniform float patch_scale : hint_range(1.0, 40.0) = 8.0;
uniform float patch_strength : hint_range(0.0, 1.0) = 0.25;

// MOWING STRIPES in the floor texture, on the COURT only (Owen: the court is the
// maintained bit, the rest of the field and the blades stay as they were):
// alternating light/dark bands inside stripe_area (court half-extents, metres,
// fading out over stripe_edge). stripe_width = metres per band; stripe_strength =
// brightness swing (0 = off); stripe_axis 0 = bands run across the court (vary
// along z), 1 = along it (vary along x).
uniform float stripe_width : hint_range(0.25, 12.0) = 1.5;
uniform float stripe_strength : hint_range(0.0, 0.5) = 0.08;
uniform float stripe_axis : hint_range(0.0, 1.0) = 0.0;
uniform vec2 stripe_area = vec2(0.0);    // 0 = nowhere (GrassField sets the court)
uniform float stripe_edge = 0.6;

varying vec3 v_wpos;

float _hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float _vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(_hash(i), _hash(i + vec2(1.0, 0.0)), u.x),
		mix(_hash(i + vec2(0.0, 1.0)), _hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float _patch(vec2 w) {
	return smoothstep(0.5, 0.85, _vnoise(w / max(patch_scale, 0.001))) * patch_strength;
}

// +-1 band, soft-edged (a mower's pass blends at its seam, never a hard line)
float _stripe(vec2 w) {
	float t = mix(w.y, w.x, stripe_axis) / max(stripe_width, 0.001);
	vec2 inside = stripe_area - abs(w);
	float mask = smoothstep(-stripe_edge, 0.0, min(inside.x, inside.y));
	return (smoothstep(-0.35, 0.35, sin(t * 3.14159265)) * 2.0 - 1.0) * mask;
}

void vertex() {
	v_wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 col = jv_in(texture(tex, v_wpos.xz * world_scale).rgb) * jv_in(tint) * brightness;
	col = mix(col, jv_in(patch_color) * brightness, _patch(v_wpos.xz));
	col *= 1.0 + stripe_strength * _stripe(v_wpos.xz);
	ALBEDO = jv_out(col * jv_world_tint);
}
