shader_type canvas_item;

// THE PAGE TURN, as a real fold. draws the open book from two spread pictures:
// `page_a`, the spread you are on, and `page_b`, the one under the page you are
// lifting. you hold the page's edge at `grab` and pull it to `hand`: the paper
// folds along the line half way between the two (the line that puts the edge
// under your hand), the part past the fold flips over and shows its back
// (page_b's page on that side), and page_b shows underneath where it lifted.
// let go far enough and the book finishes the turn; not far enough and the
// page falls back. the same fold animates button and bumper turns.
//
// worked in a "forward" space where the lifted page is always the right one: a
// backward turn (dir < 0) mirrors x in, and every texture read mirrors it back.
// geometry is in spread units with x scaled by `aspect`, so the fold is a true
// reflection (the spread is wider than tall).
//
// the gutter's shade is part of the PAPER: it is applied by where a pixel of
// paper sits, under the fold and on the flap alike, so the picture the turn ends
// on is exactly the picture the book then shows (no pop when it swaps).

uniform sampler2D page_a : source_color, filter_linear;
uniform sampler2D page_b : source_color, filter_linear;
uniform float dir = 1.0;
uniform float aspect = 1.6;
uniform bool active = false;
uniform vec2 grab = vec2(1.0, 0.8);   // forward space, 0..1 (x across the spread)
uniform vec2 hand = vec2(1.0, 0.8);
uniform float gutter = 0.2;
uniform float ring_band = 0.0;   // half the spiral's width, a fraction of the spread

vec4 read(sampler2D tex, vec2 q) {
	vec2 uv = vec2(dir < 0.0 ? 1.0 - q.x : q.x, q.y);
	return texture(tex, uv);
}

float gutter_shade(float x) {
	float d = abs(x - 0.5);
	return 1.0 - gutter * exp(-d * 55.0) - gutter * 0.35 * exp(-d * 9.0);
}

vec2 S(vec2 q) { return vec2(q.x * aspect, q.y); }
vec2 Q(vec2 s) { return vec2(s.x / aspect, s.y); }

void fragment() {
	vec2 q = vec2(dir < 0.0 ? 1.0 - UV.x : UV.x, UV.y);
	vec4 col = read(page_a, q);
	col.rgb *= gutter_shade(q.x);
	vec2 g = S(grab);
	vec2 h = S(hand);
	float span = length(g - h);
	if (active && span > 0.0005) {
		vec2 n = (g - h) / span;          // toward the edge you hold
		vec2 m = (g + h) * 0.5;           // the fold line goes through here
		vec2 x = S(q);
		float d = dot(x - m, n);          // > 0: this paper has folded away
		float done = clamp((grab.x - hand.x) / max(grab.x, 0.001), 0.0, 1.0);
		float lift = sin(done * 3.14159265);
		if (q.x >= 0.5 && d > 0.0) {
			// page_b under the lifted page, shadowed close to the fold
			col = read(page_b, q);
			col.rgb *= gutter_shade(q.x);
			col.rgb *= 1.0 - 0.4 * lift * exp(-d * 9.0);
		}
		// the flap: the paper that folded over lands here, back side up
		if (d < 0.0 && abs(q.x - 0.5) > ring_band) {
			vec2 y = Q(x - 2.0 * d * n);  // where this flap pixel came from
			if (y.x >= 0.5 && y.x <= 1.0 && y.y >= 0.0 && y.y <= 1.0) {
				vec4 back = read(page_b, vec2(1.0 - y.x, y.y));
				back.rgb *= gutter_shade(q.x);
				// lit by how far it stands off the page, a crease at the fold
				float crease = exp(d * 10.0);
				back.rgb *= 1.0 - 0.22 * lift * crease;
				back.rgb *= 1.0 - 0.08 * lift;
				col = back;
			}
		}
	}
	COLOR = col;
}
