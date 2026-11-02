// Shared body of the flat floor markers. Two shaders include this and differ
// ONLY in whether they depth-test:
//
//   floor_ring.gdshader          -- tests depth. For markers that lie on the
//                                   floor under a body: your own "that's me"
//                                   ring, the ball's landing ring. The player
//                                   standing in the ring must OCCLUDE it. When
//                                   these drew on top of everything, the ring
//                                   painted over the legs of the body standing
//                                   in it, and the chevron behind a body
//                                   facing away drew over that body too -- so
//                                   it read as pointing forwards when it was
//                                   pointing back. That is what "the arrow is
//                                   backwards" actually was.
//   floor_ring_overlay.gdshader  -- ignores depth. For the aim reticle only:
//                                   half the time it sits past the net or
//                                   under a jumping player, and a reticle you
//                                   cannot see is worse than none.
//
// Everything is in QUAD-HALF units -- 1.0 is the edge of the mesh -- so a
// marker is resized by its PlaneMesh, not by re-tuning six uniforms. Keep
// (radius + width + outline) under 1.0 or the band clips off the quad edge at
// the four axis points.
//
// Compatibility parity: floor_ring_sample() returns LINEAR colour (the
// source_color uniforms go through jv_in here). The including shader must
// include compat_color.gdshaderinc BEFORE this file and jv_out the ALBEDO.

uniform vec4 tint : source_color = vec4(0.35, 1.0, 0.55, 1.0);
uniform vec4 edge : source_color = vec4(0.0, 0.06, 0.03, 0.92);
uniform float ring_radius = 0.62;
uniform float ring_width = 0.075;
uniform float outline = 0.05;
uniform float dot_radius = 0.115;   // 0 = no centre dot
uniform float arrow_len = 0.0;      // 0 = no facing chevron
uniform float arrow_base = 0.6;     // where the chevron starts, along forward
uniform float arrow_half = 0.17;    // half the chevron's width
uniform float pulse = 0.0;
// OUTER PROGRESS ARC -- the dive-cooldown wheel around the "that's me" ring.
// Fills clockwise from forward as `progress` climbs 0 -> 1. progress < 0 (the
// default) disables it entirely, so the ball's landing ring and the aim reticle
// -- which share this body -- are drawn exactly as before. Only the player's
// own indicator drives it.
uniform float progress = -1.0;
uniform vec4 progress_color : source_color = vec4(1.0, 0.82, 0.15, 1.0);
uniform float progress_radius = 0.76;   // sits just outside the player ring
uniform float progress_width = 0.11;    // a readable half-bar (bolder than the
										// old cooldown wheel, not a full collar)
// where the CENTRE of the visible half-arc sits, 0..1 around the ring (0 = the
// rig's forward, clockwise). the player faces every which way, so the game
// points this at the CAMERA each frame -- you always see the full half of the
// meter no matter which way the body is turned.
uniform float progress_center = 0.5;

// isosceles triangle SDF (iq). base centred on the origin spanning +/- q.x,
// apex at +q.y. negative inside, so one distance drives fill AND outline.
float sd_tri(vec2 p, vec2 q) {
	p.x = abs(p.x);
	vec2 a = p - q * clamp(dot(p, q) / dot(q, q), 0.0, 1.0);
	vec2 b = p - q * vec2(clamp(p.x / q.x, 0.0, 1.0), 1.0);
	float s = -sign(q.y);
	vec2 d = min(vec2(dot(a, a), s * (p.x * q.y - p.y * q.x)),
		vec2(dot(b, b), s * (p.y - q.y)));
	return -sqrt(d.x) * sign(d.y);
}

// returns rgb + alpha for a marker fragment
vec4 floor_ring_sample(vec2 raw_uv) {
	// PlaneMesh uv: u grows with +X, v grows with +Z. +v is therefore the
	// rig's FORWARD (this rig faces +Z, not Godot's usual -Z -- see
	// Player._turn), which is what points the chevron the right way.
	vec2 uv = raw_uv * 2.0 - 1.0;
	float r = length(uv);
	float rr = ring_radius + pulse;
	float aa = fwidth(r) + 0.004;

	// ONE signed distance for the whole marker -- the union of its parts,
	// negative inside -- and the outline comes off that. Outlining each part
	// separately and taking the max drew the chevron's own dark edge across
	// the ring where the two met, leaving a seam line through a shape that is
	// meant to read as a single object.
	float d = abs(r - rr) - ring_width;
	if (dot_radius > 0.0) {
		d = min(d, r - dot_radius);
	}
	if (arrow_len > 0.0) {
		// DO NOT "fix" this again. The orientation is settled and confirmed in
		// the running game: the chevron sits on the forward side of the ring
		// (+v is this rig's forward -- it faces +Z, see Player._turn) and is
		// flipped about its own span. It has been changed on the strength of a
		// bench render twice now and been wrong both times; the bench and the
		// match disagree about this shape, and the match is the authority.
		d = min(d, sd_tri(
			vec2(uv.x, (arrow_base + arrow_len) - uv.y),
			vec2(arrow_half, arrow_len)));
	}

	float core = 1.0 - smoothstep(-aa, aa, d);
	float shell = 1.0 - smoothstep(outline - aa, outline + aa, d);

	vec3 edge_rgb = jv_in(edge.rgb);
	vec4 col = vec4(mix(edge_rgb, jv_in(tint.rgb), core),
		shell * mix(edge.a, tint.a, core));
	// the STAMINA METER: a bold HALF-arc, centred on `progress_center` (pointed at
	// the camera each frame) so you always see the full half of it whichever way
	// the body faces. the half is a dim track, the bright fill sweeps across it.
	if (progress >= 0.0) {
		float ra = abs(r - progress_radius) - progress_width;
		// a soft dark halo just outside the band so the meter pops against the
		// court instead of washing into the grass/floor
		float halo = 1.0 - smoothstep(progress_width, progress_width + outline
			+ 0.02, abs(r - progress_radius));
		float arc = 1.0 - smoothstep(-aa, aa, ra);
		float outlined_ra = abs(r - progress_radius) - (progress_width + 0.035);
		float white_edge = (1.0 - smoothstep(-aa, aa, outlined_ra));
		if (halo > 0.001) {
			float ang = atan(uv.x, uv.y) / 6.2831853;
			if (ang < 0.0) ang += 1.0;
			// signed distance around the ring from the band centre, wrapped to
			// [-0.5, 0.5]; the visible half is within a quarter-turn each side.
			float da = ang - progress_center;
			da -= round(da);
			float in_band = step(abs(da), 0.25);
			float white_border = max(white_edge - arc, 0.0) * in_band;
			// fill sweeps across the half from one edge (da -0.25) to the other
			float filled = step((da + 0.25) / 0.5, progress);
			// dark rim under the visible half for contrast
			col.rgb = mix(col.rgb, edge_rgb, (halo - arc) * 0.85 * in_band);
			col.a = max(col.a, (halo - arc) * 0.7 * edge.a * in_band);
			col.rgb = mix(col.rgb, vec3(0.025, 0.035, 0.055), white_border);
			col.a = max(col.a, white_border);
			// BATTERY look: the drained part is near-black so "stamina gone" reads
			// at a glance; the filled part is the full bright colour. both solid.
			vec3 bar = mix(vec3(0.015, 0.02, 0.0), jv_in(progress_color.rgb), filled);
			float bar_a = mix(0.92, progress_color.a, filled);
			col.rgb = mix(col.rgb, bar, arc * in_band);
			col.a = max(col.a, arc * in_band * bar_a);
		}
	}
	return col;
}
