// cartoon smoke puff: a billboarded white CLOUD with rounded lobes (a scalloped
// "poof"), not a plain disc. clusters of these read as classic platformer dust.
shader_type spatial;
render_mode unshaded, cull_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec4 tint : source_color = vec4(0.96, 0.97, 1.0, 0.85);
uniform float rot = 0.0;          // per-instance spin so stacked puffs don't align
uniform float lobes = 7.0;        // number of rounded bumps around the rim
uniform float dissolve = 0.0;     // 0 = whole cloud, 1 = broken into round puffs

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

// one round circle's coverage: 1 inside, 0 outside, soft rim. the cloud is the
// UNION (max) of several of these, so each circle stays a distinct rounded bump
// instead of the additive bulge a metaball makes -- "stacked circles" cloud.
float _circle(vec2 p, vec2 c, float r) {
	return 1.0 - smoothstep(r - 0.07, r + 0.07, distance(p, c));
}

void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;           // -1..1
	float a;
	if (lobes < 0.5) {
		// plain disc: the burst SHARDS share this shader and want a circle
		a = 1.0 - smoothstep(0.82, 1.0, length(p));
	} else {
		// cloud = several overlapping round circles stacked into one lumpy puff.
		// similar radii, packed tight so they heavily overlap; each pokes out as a
		// rounded lobe on the rim. rot spins the whole arrangement so stacked
		// puffs differ. dissolve shrinks every circle so they separate and break
		// into individual round puffs that fade -- no square-grid crumble.
		float si = sin(rot);
		float co = cos(rot);
		mat2 rm = mat2(vec2(co, -si), vec2(si, co));
		float k = 1.0 - dissolve * 0.92;   // radius shrink as it breaks up
		a = _circle(p, rm * vec2(0.00, 0.06), 0.46 * k);
		a = max(a, _circle(p, rm * vec2(-0.40, 0.04), 0.40 * k));
		a = max(a, _circle(p, rm * vec2(0.40, 0.06), 0.40 * k));
		a = max(a, _circle(p, rm * vec2(-0.20, 0.34), 0.38 * k));
		a = max(a, _circle(p, rm * vec2(0.24, 0.32), 0.38 * k));
		a = max(a, _circle(p, rm * vec2(0.02, -0.30), 0.40 * k));
	}
	// flat full white -- the stacked-circle silhouette already reads as a puff, so
	// no underside shading (the user's call: solid white, not a lit gradient).
	ALBEDO = jv_out(jv_in(tint.rgb));
	ALPHA = a * tint.a;
}
