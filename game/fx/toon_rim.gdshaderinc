// UNIVERSAL TOON RIM (Owen 2026-10-14, ref: Tomodachi Life: Living the Dream;
// then "way sharper, like a second band of toon shading ... a noticeable white
// line"): every toon surface gets a hard-edged light band along its silhouette,
// a second cel band on top of the shade band, a bit stronger on the upper edges.
// Everywhere a character is drawn: match, menus, locker, portraits.
// EXPERIMENT (Owen may revert): rim_amount 0 = off.
// OFF (Owen 2026-10-14: outlines back, rim off, to compare). 0.5 = the rim he trialled
uniform float rim_amount : hint_range(0.0, 1.0) = 0.0;
// the band's share of the shape's on-screen width (Owen: "just slightly" thinner than 0.1)
uniform float rim_width : hint_range(0.0, 1.0) = 0.085;
// 1 = only on the side AWAY from the cel key light (reads as a back light, Owen
// 2026-10-14 trial), 0 = every edge alike
uniform float rim_side : hint_range(0.0, 1.0) = 1.0;
uniform float rim_softness = 0.03;   // a hair of AA on the band's edge, like band_softness
// NIGHT RIM (Owen 2026-10-17, once the outlines went contour-only: "lets try just
// night stages"): the stage's time-of-day look sets this global (look key
// "body_rim", Stage.apply_time_of_day; 0 by day and evening), and a body takes
// it only while it stands in a stage world (world_lit), so the locker, shop and
// portraits never do. the band goes through the night body tint after, so it
// reads as cool moonlight rather than flat white.
global uniform float jv_night_rim;

// c: the shaded colour (linear). n, v: view-space normal and view vector.
// l: the shader's view-space key light (its key_dir), so the rim sits opposite it.
// k scales it per shader: hair is flat-shaded spikes and cards whose whole face
// turns side-on to the camera and lit up solid ("it gets really strong on
// hairs"), so toon_hair passes a smaller k
// lit: the shader's world_lit (1 in a stage world), gating the night rim
vec3 jv_toon_rim(vec3 c, vec3 n, vec3 v, float k, vec3 l, float lit) {
	float amount = max(rim_amount, jv_night_rim * lit);
	if (amount <= 0.0) {
		return c;
	}
	// how far out toward the silhouette this point sits ON SCREEN (sin of the
	// view angle): 1 - n.v only reaches the outer ~1% of a round shape, which hid
	// the band on ball-ish pieces (antenna tips, hands) entirely
	float ndv = clamp(dot(n, normalize(v)), 0.0, 1.0);
	float edge = sqrt(1.0 - ndv * ndv);
	// thinner low on the body, full width on the upper edges
	float w = rim_width * k * mix(0.55, 1.0, clamp(n.y * 0.5 + 0.5, 0.0, 1.0));
	// ~1 pixel of AA, never wider than rim_softness (sharp on a face as on a hand)
	float aa = clamp(fwidth(edge) * 0.75, 0.0005, rim_softness);
	float r = smoothstep(1.0 - w - aa, 1.0 - w + aa, edge);
	// the screen-space side facing away from the key: a hard cut, like the cel band
	float away = dot(normalize(n.xy + vec2(0.0001)), -normalize(l.xy + vec2(0.0001)));
	r *= mix(1.0, smoothstep(-0.05, 0.05, away), rim_side);
	return mix(c, vec3(1.0), r * amount * k);
}
