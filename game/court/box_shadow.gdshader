shader_type spatial;
// a soft-edged RECTANGULAR ground shadow for boxy buildings --
// the radial shadow_blob read as an oval that didn't match a building's footprint.
// UV 0..1 across a flat FACE_Y quad; scale the quad to the footprint and this fills
// it as a rectangle with a feathered edge.
// ALPHA-BLENDED toward the shadow colour, in every renderer. it was blend_mul, but
// (1) on Compatibility multiply goes near-black whenever the stage has glow
// (measured, game/dev/color_chart.tscn --mulquad --glow: the black strip under the
// net), and (2) a multiply decal can't take fog: Forward+ fogs the MULTIPLIER toward
// the fog colour and tints the ground blue in the distance, and with fog off a far
// shadow stays a dark speck. alpha blending fades with the fog like everything else
// and reads the same as multiply on a bright floor. jv_alpha keeps the darkness equal
// on Compatibility (it blends in sRGB there).
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec3 shadow_color : source_color = vec3(0.15, 0.15, 0.19);
uniform float strength : hint_range(0.0, 1.0) = 0.85;
uniform float softness : hint_range(0.0, 1.0) = 0.28;   // edge feather (fraction)
uniform float corner : hint_range(0.0, 0.5) = 0.12;     // round the corners a touch

void fragment() {
	// distance from centre toward the edges, 0..1 per axis
	vec2 p = abs(UV - 0.5) * 2.0;
	// rounded-box distance: square core, slightly rounded corners so it isn't a
	// hard-cornered rectangle (reads softer/more natural under a building)
	vec2 q = max(p - (1.0 - corner), vec2(0.0));
	float m = max(max(p.x, p.y) - corner, length(q));
	float a = (1.0 - smoothstep(1.0 - softness, 1.0, m)) * strength;
	ALBEDO = jv_out(jv_in(shadow_color));
	ALPHA = jv_alpha(a);
}
