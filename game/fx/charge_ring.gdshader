// radial charge indicator, botw sprint-wheel style: an annulus that fills
// clockwise from the top as the jump charges.
//
// This is the one round marker that is NOT flat on the floor -- it billboards
// over the player -- so it can't share floor_ring.gdshader. It wears the same
// dark shell for the same reason: a bright annulus over a bright court reads
// as a smear, and this one sits over a moving body as well as the floor.
shader_type spatial;
// depth_test_disabled: this is UI, not scenery. it used to lose the depth
// fight to the ball, the reticle and the player's own body, leaving the one
// meter that answers "how charged am I" half-buried mid-action.
render_mode unshaded, cull_disabled, depth_test_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform float fill = 0.0;
// 1 when the charge has actually maxed. A ring that only fills tells you how
// far along you are but never that you have ARRIVED -- so players let go early,
// never saw what a full charge does, and concluded charging was pointless.
// A wheel that visibly locks is the difference between a meter and a decision.
uniform float ready = 0.0;
// 1 while the BAM window is open: a full JUMP charge whose perfect release is
// still available. the whole ring goes SOLID WHITE with a pulsing white halo.
// white belongs to this state alone (`ready` keeps the ring's own colour) so
// the flash IS the "release now" cue, readable in peripheral vision while the
// player watches the ball, not the ring.
uniform float bam = 0.0;
// 0..1 run-up to the window: the outline warms toward white over the last beat
// BEFORE the flash so the eye is primed. outline only -- the band stays its
// colour so the moment it turns white is a clean, unmistakable edge.
uniform float bam_lead = 0.0;
uniform vec4 bam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fill_color : source_color = vec4(0.4, 0.95, 0.35, 0.95);
uniform vec4 bg_color : source_color = vec4(0.05, 0.05, 0.08, 0.5);
uniform vec4 edge_color : source_color = vec4(0.02, 0.02, 0.04, 0.95);
// the quad only reaches r=0.5 along its axes, so band + outline has to stay
// inside that or the ring gets flat-topped at four points
uniform float r_inner = 0.28;
uniform float r_outer = 0.46;
uniform float outline = 0.035;

void vertex() {
	mat4 mv = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	mv = mv * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = mv;
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float r = length(uv);
	float aa = fwidth(r) + 0.002;
	if (r > r_outer + outline + aa || r < r_inner - outline - aa) {
		discard;
	}
	float band = min(smoothstep(r_inner - aa, r_inner + aa, r),
		1.0 - smoothstep(r_outer - aa, r_outer + aa, r));
	float shell = min(
		smoothstep(r_inner - outline - aa, r_inner - outline + aa, r),
		1.0 - smoothstep(r_outer + outline - aa, r_outer + outline + aa, r));
	float angle = atan(uv.x, -uv.y);          // 0 at top, clockwise positive
	float t = (angle + PI) / (2.0 * PI);
	t = fract(t + 0.5);                        // start the fill at the top
	vec4 fill_c = jv_in4(fill_color);
	vec4 bam_c = jv_in4(bam_color);
	vec4 bg_c = jv_in4(bg_color);
	vec4 lit = fill_c;
	vec4 edge = jv_in4(edge_color);
	if (bam > 0.5) {
		// THE PERFECT WINDOW: the band is solid white for the whole window (no
		// dim phase -- a dip mid-window reads as "missed it"), and the dark
		// shell becomes a white halo that throbs, so the marker glows outward.
		float pulse = 0.5 + 0.5 * sin(TIME * 7.0);
		lit = bam_c;
		lit.a = 1.0;
		edge = vec4(bam_c.rgb, 0.8 + 0.2 * pulse);
	} else if (ready > 0.5) {
		// locked and breathing in its OWN colour: only a light lift toward
		// white, so the real white flash above never gets confused with it
		float pulse = 0.5 + 0.5 * sin(TIME * 12.0);
		lit = mix(fill_c, vec4(1.0), 0.08 + 0.12 * pulse);
		lit.a = 1.0;
		// the run-up: the outline warms toward white as the window approaches.
		// it primes; the band turning white announces.
		edge = mix(edge, vec4(bam_c.rgb * 0.6, 0.95), bam_lead * 0.7);
	}
	vec4 col = t < fill ? lit : bg_c;
	ALBEDO = jv_out(mix(edge.rgb, col.rgb, band));
	ALPHA = shell * mix(edge.a, col.a, band);
}
