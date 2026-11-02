// the landing call on the floor, drawn as what the rule actually judged:
// - the ball's FOOTPRINT, a crisp ring exactly one ball radius wide (Rules.ball_in
//   calls a ball in the moment this circle touches the tape), filled with the
//   call red where it touched the floor
// - on a close call, the nearby stretch of boundary tape lit up at the RULE's
//   width, so the footprint visibly overlaps it (in) or misses it (out)
// - when it missed, a white measuring bar across the gap it missed by
// the quad is laid flat and centred on the touch point; everything is in local
// metres (LandingCall.apply feeds the line offsets), so every screen that gets
// the same spot draws the same picture.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec4 col : source_color = vec4(0.93, 0.08, 0.1, 1.0);
uniform float half_size = 1.4;    // the quad's half extent, metres
uniform float ring_r = 0.26;      // the ball's radius (Ball.PHYS.radius)
uniform float pop = 1.0;          // 0 -> 1 as the mark lands (ring shrinks onto the spot)
uniform float line_x = 0.0;       // local x of the nearest sideline's centre
uniform float tape_x = 0.025;     // its half width
uniform float show_x = 0.0;       // 1 = light that sideline up
uniform float line_z = 0.0;       // local z of the nearest endline's centre
uniform float tape_z = 0.025;
uniform float show_z = 0.0;
uniform vec2 out_dir = vec2(1.0, 1.0);   // court -> outside, per axis (x, z)

const float GLOW_W = 0.16;        // the lit tape's soft halo, metres past its edge

varying vec2 lp;

void vertex() {
	lp = VERTEX.xz;
}

// 1 inside a band of half width w around 0, crisp anti-aliased edge
float band(float d, float w, float aa) {
	return 1.0 - smoothstep(w - aa, w + aa, abs(d));
}

// the white measuring bar across a gap on one axis: `a` runs along the gap,
// `b` across it. from the footprint edge (s * ring) to the tape's near edge
// (edge), with short ticks at both ends
float gap_bar(float a, float b, float s, float edge, float aa) {
	float lo = min(s * ring_r, edge);
	float hi = max(s * ring_r, edge);
	if (hi - lo < 0.004) {
		return 0.0;
	}
	float along = step(lo, a) * step(a, hi);
	float bar = band(b, 0.012, aa) * along;
	float tick = (band(a - lo, 0.01, aa) + band(a - hi, 0.01, aa)) * band(b, 0.075, aa);
	return clamp(bar + tick, 0.0, 1.0);
}

void fragment() {
	float aa = fwidth(lp.x) * 1.2 + 1e-4;
	float r = length(lp);
	vec3 red = jv_in(col.rgb);
	vec3 rgb = vec3(0.0);
	float a = 0.0;

	// --- the lit tape stretches, fading out along their length ---
	// each line stops at the court's corner (the other line's outer edge), so
	// a corner call doesn't light tape running off into the run-off
	float corner_z = line_z + out_dir.y * tape_z;
	float corner_x = line_x + out_dir.x * tape_x;
	float keep_x = step((lp.y - corner_z) * out_dir.y, 0.0);
	float keep_z = step((lp.x - corner_x) * out_dir.x, 0.0);
	float fade_len = smoothstep(half_size, half_size * 0.55, abs(lp.y)) * keep_x;
	float tx = band(lp.x - line_x, tape_x, aa) * show_x * fade_len;
	// the halo sits on the COURT side only: the outside of the tape stays
	// clean so the footprint visibly touches it or misses it
	float glow_x = (1.0 - smoothstep(tape_x, tape_x + GLOW_W, abs(lp.x - line_x)))
		* step((lp.x - line_x) * out_dir.x, 0.0) * show_x * fade_len;
	float fade_wid = smoothstep(half_size, half_size * 0.55, abs(lp.x)) * keep_z;
	float tz = band(lp.y - line_z, tape_z, aa) * show_z * fade_wid;
	float glow_z = (1.0 - smoothstep(tape_z, tape_z + GLOW_W, abs(lp.y - line_z)))
		* step((lp.y - line_z) * out_dir.y, 0.0) * show_z * fade_wid;
	float tape = max(tx, tz) * pop;
	float glow = max(glow_x, glow_z) * pop;
	// lit YELLOW, not white: the painted line is already white, so a white
	// highlight on it would vanish. a soft yellow halo carries it at gameplay
	// distance (a 5cm tape is a hairline from the match cam); the crisp tape
	// inside it stays the rule's exact width
	vec3 lit = vec3(1.0, 0.7, 0.02);   // a linear constant: no jv_in
	a = max(a, glow * glow * 0.55);
	rgb = lit;
	// the tape itself: a hotter, paler yellow so its true edges read inside the halo
	rgb = mix(rgb, vec3(1.0, 0.92, 0.35), tape);
	a = max(a, tape);

	// --- the footprint: one ball radius, landing onto the spot ---
	float rr = ring_r * mix(1.7, 1.0, pop);
	float inside = 1.0 - smoothstep(rr - aa, rr + aa, r);
	// the touched floor: red, solid where it lies on the lit tape (THAT is the
	// part that touched the line), see-through elsewhere so the court shows
	float on_tape = tape;
	float fill_a = mix(0.7, 0.95, on_tape) * inside * pop;
	rgb = mix(rgb, red, fill_a / max(max(a, fill_a), 1e-4));
	a = max(a, fill_a);
	// crisp rim: a dark keyline outside a solid red ring, reads on any court
	float rim = band(r - rr, 0.022, aa);
	float key = band(r - rr - 0.03, 0.012, aa) * (1.0 - rim);
	rgb = mix(rgb, vec3(0.02, 0.02, 0.03), key);
	rgb = mix(rgb, red, rim);
	a = max(a, max(rim, key * 0.85) * min(pop * 2.0, 1.0));

	// --- the gap it missed by (only drawn when it missed that line) ---
	float sx = sign(line_x);
	float near_x = line_x - sx * tape_x;
	float gx = (abs(line_x) - tape_x > ring_r) ? gap_bar(lp.x, lp.y, sx, near_x, aa) * show_x : 0.0;
	float sz = sign(line_z);
	float near_z = line_z - sz * tape_z;
	float gz = (abs(line_z) - tape_z > ring_r) ? gap_bar(lp.y, lp.x, sz, near_z, aa) * show_z : 0.0;
	float gap = max(gx, gz) * pop;
	rgb = mix(rgb, vec3(1.0), gap);
	a = max(a, gap);

	ALBEDO = jv_out(rgb);
	ALPHA = clamp(a, 0.0, 1.0);
	EMISSION = jv_out(red * (rim * 0.4 + fill_a * 0.2) + lit * tape * 0.35 + vec3(1.0) * gap * 0.35);
}
