shader_type canvas_item;

// TITLE PLATE, PIXEL: the plate colour broken into chunky cells that flicker like an old screen, the odd one flashing white. even the corners are cut in steps.
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

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float cell_px = mix(4.0, 10.0, knobs.y);
	// cells counted from the middle, so the pattern is the same on both ends
	vec2 cell = floor((UV - 0.5) * size / cell_px);
	float beat = floor(now * mix(2.0, 12.0, knobs.x));
	float flicker = hash(cell + beat * 0.37);
	float spark = hash(cell * 1.7 + floor(beat * 0.35) * 0.61);
	vec3 c = base.rgb * mix(0.70, 1.0, flicker);
	c = mix(c, vec3(1.0), step(0.94, spark) * 0.6);
	// the mask is read at the middle of each cell: stepped corners
	vec2 mid = (cell + 0.5) * cell_px / size + 0.5;
	COLOR = vec4(c, 1.0 - step(0.0, edge(mid)));
}
