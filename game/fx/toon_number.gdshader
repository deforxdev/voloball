// jersey back patch. only the digits draw -- every other pixel is discarded
// so the shirt underneath shows through untouched. a shaded patch would cut
// its own band across the body and read as a panel stitched on.
shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;
// marks the body/ball in the stencil so drop shadows never draw over it (feet sunk
// in sand or grass used to clip through their own shadow). see GameConfig.SHADOW_STENCIL
stencil_mode write, compare_always, 1;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
// (`number_tex` is only read for its alpha, so it is NOT converted)
#include "res://game/fx/compat_color.gdshaderinc"
// TIME OF DAY: a body standing in the stage world takes the stage's light (night
// cools and dims it, evening warms it) so it sits in the scene. world_lit is set by
// GameConfig.world_light only on in-world bodies; previews/portraits stay untinted.
uniform float world_lit = 0.0;
global uniform vec3 jv_body_tint;
#include "res://game/fx/body_arena_light.gdshaderinc"

uniform vec4 ink : source_color = vec4(0.07, 0.07, 0.09, 1.0);
uniform sampler2D number_tex : source_color, filter_linear;
uniform float level = 0.8;
uniform bool flip_u = false;
uniform float lift = 0.004;   // stand off the shirt so it can't z-fight

void vertex() {
	VERTEX += NORMAL * lift;
}

void fragment() {
	vec2 uv = UV;
	if (flip_u) {
		uv.x = 1.0 - uv.x;
	}
	if (texture(number_tex, uv).a < 0.5) {
		discard;
	}
	ALBEDO = jv_out(jv_arena_light(jv_in(ink.rgb) * level * mix(vec3(1.0), jv_body_tint, world_lit),
		normalize(NORMAL), VIEW, VERTEX, INV_VIEW_MATRIX, world_lit));
}
