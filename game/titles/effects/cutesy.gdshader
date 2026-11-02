shader_type canvas_item;

// TITLE PLATE, CUTESY: a paler shade of the plate colour, little hearts drifting over it and a stitched line round the edge. (the bows on its ends are the effect's picture.)
// (see TitleEffect for what every title effect's shader is handed, and for the
// rule: keep it cheap. time is `now`, not TIME, so the letters keep step.)

uniform vec4 base : source_color = vec4(1.0);
uniform vec4 accent : source_color = vec4(1.0);
uniform vec2 size = vec2(120.0, 36.0);
uniform float radius = 18.0;
uniform vec4 knobs = vec4(0.5);
uniform float now = 0.0;

// how far past the rounded plate's edge this point is, in pixels (inside is negative)
float edge(vec2 uv) {
	vec2 q = abs((uv - 0.5) * size) - (size * 0.5 - vec2(radius));
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

// 1 inside the plate, 0 outside, one soft pixel between
float plate(vec2 uv) {
	return 1.0 - smoothstep(-0.75, 0.75, edge(uv));
}

// under zero inside a heart about one unit across
float heart(vec2 q) {
	q.y = 0.25 - q.y;
	q.y -= sqrt(abs(q.x)) * 0.55;
	return length(q) - 0.62;
}

void fragment() {
	vec3 soft = mix(base.rgb, vec3(1.0), 0.42);
	vec2 p = UV * size;
	float cell_px = mix(11.0, 20.0, knobs.x);
	vec2 g = (p + vec2(now, -now * 0.6) * mix(1.0, 9.0, knobs.y)) / cell_px;
	g.x += step(1.0, mod(floor(g.y), 2.0)) * 0.5;      // every other row sits between
	float h = 1.0 - smoothstep(-0.08, 0.08, heart((fract(g) - 0.5) * 2.6));
	vec3 c = mix(soft, accent.rgb, h * 0.55);
	float stitch = (1.0 - smoothstep(0.6, 1.4, abs(edge(UV) + 3.2))) * step(0.5, fract((p.x + p.y) / 7.0));
	c = mix(c, accent.rgb, stitch * 0.9);
	COLOR = vec4(c, plate(UV));
}
