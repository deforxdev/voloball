// BEACH PEOPLE'S SHADOWS: a soft dark blob on the ground under each person, drawn
// from the SAME MultiMesh as the people (beach_crowd_field.gd) with this material,
// so one extra draw call shades the whole crowd. Follows walkers along their lane
// and slides out from under someone who's been knocked over, then fades into the
// haze like they do. Alpha-blended (jv_alpha), never multiply (see box_shadow).
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
#include "res://game/court/beach_crowd_common.gdshaderinc"

uniform vec3 shadow_color : source_color = vec3(0.30, 0.25, 0.18);
uniform float strength : hint_range(0.0, 1.0) = 0.38;
uniform vec2 blob = vec2(0.42, 0.28);    // half-size in metres (across, along)
uniform float sit_strength = 0.0;        // sitters are on a bench: no blob of their own
uniform float fade_start = 25.0;
uniform float fade_end = 70.0;

varying vec2 v_uv;
varying flat float v_a;

void vertex() {
	vec3 origin = crowd_origin(MODEL_MATRIX, INSTANCE_CUSTOM);
	float down = crowd_down(MODEL_MATRIX);
	vec3 push = normalize(vec3(MODEL_MATRIX[2].x, 0.0, MODEL_MATRIX[2].z) + vec3(1e-4, 0.0, 0.0));
	vec3 side = vec3(-push.z, 0.0, push.x);
	// the quad's own corners (x -0.5..0.5 * width, y -0.5..0.5 * height) -> unit square
	vec2 q = vec2(sign(VERTEX.x), sign(VERTEX.y));
	// a fallen body lies along the push: the shadow stretches out that way
	vec2 half_size = vec2(blob.x, blob.y + down * 0.55);
	vec3 centre = origin + push * down * 0.6;
	vec3 world = centre + side * q.x * half_size.x + push * q.y * half_size.y;
	world.y = origin.y + 0.03;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
	v_uv = q;
	float dist = distance(INV_VIEW_MATRIX[3].xyz, origin);
	float kind_a = INSTANCE_CUSTOM.w > 0.5 && INSTANCE_CUSTOM.w < 1.5 ? sit_strength : 1.0;
	v_a = strength * kind_a * (1.0 - smoothstep(fade_start, fade_end, dist));
}

void fragment() {
	float r = length(v_uv);
	float a = (1.0 - smoothstep(0.35, 1.0, r)) * v_a;
	ALBEDO = jv_out(jv_in(shadow_color));
	ALPHA = jv_alpha(a);
}
