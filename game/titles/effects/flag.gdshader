shader_type canvas_item;

// TITLE PLATE, FLAG: a country's flag behind the words. it does not move. (one shader for every flag: the effect's picture is the flag.)
// (see TitleEffect for what every title effect's shader is handed, and for the
// rule: keep it cheap. time is `now`, not TIME, so the letters keep step.)

uniform vec4 base : source_color = vec4(1.0);
uniform vec4 accent : source_color = vec4(1.0);
uniform vec2 size = vec2(120.0, 36.0);
uniform float radius = 18.0;
uniform vec4 knobs = vec4(0.5);
uniform float now = 0.0;
uniform sampler2D art : repeat_disable, filter_linear;   // the flag

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
	// THE FLAG KEEPS ITS SHAPE: its whole height on the plate, in the middle, and
	// its own edge colours carried on out to the plate's ends (a red disc stays a
	// disc, three bands stay three bands; stretched to the plate it would be
	// neither). the first slider grows it from there until it covers the width.
	vec2 tex = vec2(textureSize(art, 0));
	float flag_w = size.y * tex.x / tex.y;
	float grow = mix(1.0, max(1.0, size.x / flag_w), knobs.x);
	vec2 p = (UV - 0.5) * size / (vec2(flag_w, size.y) * grow) + 0.5;
	// (half a texel in from its edge: what is carried on is the flag's own colour)
	vec2 inset = 0.5 / tex;
	vec3 c = texture(art, clamp(p, inset, 1.0 - inset)).rgb;
	// the second slider washes it toward white, for letters that want a paler ground
	c = mix(c, vec3(1.0), knobs.y * 0.7);
	COLOR = vec4(c, plate(UV));
}
