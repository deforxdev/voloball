// CROWD BILLBOARDS. One MultiMesh of camera-facing quads over the seats, each
// instance a seated fan. All fans share ONE Texture2DArray (the baked portrait
// library); per-instance custom data picks the layer + a bob phase, so the whole
// crowd is a single draw call -- cheap enough for low-end hardware.
//   INSTANCE_CUSTOM.x = portrait layer index
//   INSTANCE_CUSTOM.y = bob phase (0..1), also the fan's 1st random
//   INSTANCE_CUSTOM.z = 2nd per-fan random (0..1)
//   INSTANCE_CUSTOM.w = 3rd per-fan random (0..1)
// Y-axis billboard: fans always face the viewer but stay upright, so no matter
// where the broadcast camera swings they read correctly and never tilt.
//
// REACTIONS (Owen: no "waterfall" -- individual fans, right away). Two channels,
// each reset by CrowdField when the house reacts:
//   CHEER: each joining fan springs up within a fraction of a second, on its own
//     reaction time, and bounces a few times at its own rate and height. A louder
//     moment gets more of the crowd up and keeps them bouncing longer.
//   SHOCK (the gasp): joining fans jolt and shake in place, settling fast.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
#include "res://game/court/sun_windows.gdshaderinc"

#include "res://game/court/crowd_body.gdshaderinc"

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // see the player through it
	vec4 tex = texture(fans, vec3(uv, layer));
	// mute: desaturate + soften contrast so the crowd stops reading as bright shiny
	// speckles, THEN darken/cool (tint), THEN haze-fade the far rows.
	vec3 c = jv_in(tex.rgb);
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(luma), clamp(desat + far_desat * vfar, 0.0, 1.0));
	float k = crowd_contrast * (1.0 - far_contrast * vfar);
	c = clamp((c - vec3(0.5)) * k + vec3(0.5), 0.0, 1.0);
	c = c * jv_in(tint) * vshade;
	c += c * jv_in(jv_sun_col) * vsun * 0.7;   // a touch under the seats: fans are lighter already
	ALBEDO = jv_out(mix(c, jv_in(haze_color), vhaze));
	ALPHA = tex.a;
	// far away a stick is thinner than a pixel, so it blinked in and out as it
	// swayed (Owen 2026-10-14: "random flickering everywhere when the camera gets
	// zoomed out"): it never gets thinner than ~a pixel on screen, and a widened
	// one is drawn dimmer so a far stick isn't brighter than a near one
	float px = fwidth(uv.y);   // one screen pixel, in fan heights
	float half_w = max(STICK_HALF, 0.75 * px);
	float cover = STICK_HALF / half_w;
	if (jv_has_stick(vrand)) {
		float d = jv_stick_dist(uv, vrand);
		if (d < half_w) {
			// a hot, near-white core down the middle (crowd_glow.gdshader adds the glare)
			vec3 g = mix(jv_stick_color(vrand), vec3(1.0), 0.55 * (1.0 - d / half_w) * cover);
			ALBEDO = mix(ALBEDO, jv_out(jv_in(g) * glow_energy), clamp(0.35 + cover, 0.0, 1.0));
			ALPHA = 1.0;
		}
	}
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
