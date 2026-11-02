// see-through twin of venue_flat.gdshader (the void planets' orbit rings):
// albedo.a is the opacity, the colour follows the jv_world_tint time of day.
shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_never, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
global uniform vec3 jv_world_tint;

uniform vec4 albedo : source_color = vec4(1.0);

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // see the player through it
	ALBEDO = jv_out(jv_in(albedo.rgb) * jv_world_tint);
	ALPHA = jv_alpha(albedo.a);
}
