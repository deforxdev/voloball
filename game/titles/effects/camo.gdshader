shader_type canvas_item;

// TITLE PLATE, CAMO: camouflage in four tones: the plate colour, a dark and a light shade of it, and the second colour. it does not move.
// (see TitleEffect for what every title effect's shader is handed, and for the
// rule: keep it cheap. time is `now`, not TIME, so the letters keep step.)

uniform vec4 base : source_color = vec4(1.0);
uniform vec4 accent : source_color = vec4(1.0);
uniform vec2 size = vec2(120.0, 36.0);
uniform float radius = 18.0;
uniform vec4 knobs = vec4(0.5);
uniform float now = 0.0;
uniform sampler2D art : repeat_enable, filter_nearest;   // the blob pattern: four grey levels

// how far past the rounded plate's edge this point is, in pixels (inside is negative)
float edge(vec2 uv) {
	vec2 q = abs((uv - 0.5) * size) - (size * 0.5 - vec2(radius));
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

// 1 inside the plate, 0 outside, one soft pixel between
float plate(vec2 uv) {
	return 1.0 - smoothstep(-0.75, 0.75, edge(uv));
}

void fragment() {
	// one tile of the pattern is this many pixels wide (and half as tall)
	vec2 p = UV * size / mix(60.0, 180.0, knobs.x);
	p.y *= 2.0;
	float level = texture(art, p).r;
	vec3 c = base.rgb;
	c = mix(c, mix(base.rgb, vec3(0.86, 0.82, 0.6), 0.5), step(0.83, level));
	c = mix(c, accent.rgb, 1.0 - step(0.5, level));
	c = mix(c, base.rgb * 0.4, 1.0 - step(0.17, level));
	COLOR = vec4(c, plate(UV));
}
