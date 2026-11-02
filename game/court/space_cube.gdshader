// FLOATING CUBE look for the void / Tutorial stage. The cubes drift in a bright
// void, so pure flat white reads harsh and hard to look at -- this gives each cube
// a soft vertical BLUE GRADIENT (light top, cooler blue base) plus fake top-down
// face shading, so it reads as a soft 3D pastel block. Unshaded + cull_disabled
// (the beveled mesh sets its own normals). One material drives the whole MultiMesh.
shader_type spatial;
render_mode unshaded, cull_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
// TIME OF DAY: the venue's light (Stage.apply_time_of_day sets it per match; white by
// day). players and the ball never read it, so they stay bright and readable at night.
global uniform vec3 jv_world_tint;

uniform vec3 light_dir = vec3(-0.4, 0.9, 0.35);
uniform vec3 top_color : source_color = vec3(0.97, 0.98, 1.0);     // soft white top
uniform vec3 bottom_color : source_color = vec3(0.78, 0.84, 0.93); // faint blue-grey base
uniform float side_shade : hint_range(0.0, 1.0) = 0.72;            // gentle face contrast (soft, airy)

varying vec3 world_normal;
varying float up_frac;   // 0 base, 1 top (local)
varying flat vec4 clear_obj;   // this cube's bounding sphere (world), for the see-through

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	// a unit box: half its diagonal (0.87) times the instance's largest scale
	clear_obj = vec4(MODEL_MATRIX[3].xyz, 0.87 * max(length(MODEL_MATRIX[0].xyz),
		max(length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz))));
	up_frac = clamp(VERTEX.y + 0.5, 0.0, 1.0);   // unit box local y -0.5..0.5
}

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared_object(clear_obj, VIEW_MATRIX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // in the way: the whole cube goes
	float d = clamp(dot(world_normal, normalize(light_dir)) * 0.5 + 0.5, 0.0, 1.0);
	vec3 grad = mix(jv_in(bottom_color), jv_in(top_color), up_frac);   // vertical blue gradient
	ALBEDO = jv_out(grad * mix(side_shade, 1.0, d) * jv_world_tint);             // + face shading
}
