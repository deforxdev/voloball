// FAKE SHADOW. A flat soft-edged dark blob laid on the floor under a prop (bench,
// ref stand, net post, table) so it reads as grounded -- the cheap fake of a cast
// shadow, no real lights needed. it only ever DARKENS the surface under it (never
// lightens, never shows a hard quad edge). Drop it in the editor,
// scale/rotate to match the prop's footprint. Pairs with the env_paint look system.
shader_type spatial;
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

uniform vec3 shadow_color : source_color = vec3(0.26, 0.26, 0.3); // how dark at core
uniform float strength : hint_range(0.0, 1.0) = 0.8;
uniform float softness : hint_range(0.0, 1.0) = 0.55;            // edge feather

void fragment() {
	// radial falloff: 0 at centre, 1 at the quad edge (an ellipse if scaled non-uniform)
	float d = length((UV - 0.5) * 2.0);
	float mask = (1.0 - smoothstep(1.0 - softness, 1.0, d)) * strength;
	ALBEDO = jv_out(jv_in(shadow_color));
	ALPHA = jv_alpha(mask);
}
