// FLAT VENUE COLOUR that follows the time of day: an unshaded StandardMaterial
// can't read the jv_world_tint global, so venue pieces that must dim with the
// stage (the void's under-floor ground, seen through the tile cracks) use this.
// Same colour as an unshaded StandardMaterial with that albedo at day (tint 1).
shader_type spatial;
render_mode unshaded, cull_back;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
global uniform vec3 jv_world_tint;

uniform vec4 albedo : source_color = vec4(1.0);

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // see the player through it
	ALBEDO = jv_out(jv_in(albedo.rgb) * jv_world_tint);
}
