shader_type canvas_item;

// TITLE PLATE, BACKDROP: a map's lobby thumbnail behind the words. it does not move. (one shader for every map: the effect's picture is the map's, TitleEffect.stage.)
// (see TitleEffect for what every title effect's shader is handed, and for the
// rule: keep it cheap.)

uniform vec4 base : source_color = vec4(1.0);
uniform vec2 size = vec2(120.0, 36.0);
uniform float radius = 18.0;
uniform vec4 knobs = vec4(0.5);
uniform sampler2D art : repeat_disable, filter_linear;   // the map's thumbnail

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
	// THE PICTURE COVERS THE PLATE, in its own shape: a thumbnail is a long strip
	// (1400 x 200), so the plate shows a stretch of it. the first slider picks
	// which stretch (left .. right), the second zooms in on it.
	vec2 tex = vec2(textureSize(art, 0));
	float plate_aspect = size.x / size.y;
	float pic_aspect = tex.x / tex.y;
	vec2 seen = pic_aspect > plate_aspect ? vec2(plate_aspect / pic_aspect, 1.0)
		: vec2(1.0, pic_aspect / plate_aspect);
	seen /= mix(1.0, 2.0, knobs.y);
	vec2 at = vec2(knobs.x, 0.5) * (1.0 - seen) + UV * seen;
	// the strip is several of its pixels to one of the plate's: four looks inside
	// that plate pixel, so it reads as a picture and not as glitter
	vec2 px = seen / size * 0.35;
	vec3 c = (texture(art, at + vec2(-px.x, -px.y)).rgb + texture(art, at + vec2(px.x, -px.y)).rgb
		+ texture(art, at + vec2(-px.x, px.y)).rgb + texture(art, at + vec2(px.x, px.y)).rgb) * 0.25;
	// the third washes it toward white, for letters that want a paler ground
	c = mix(c, vec3(1.0), knobs.z * 0.7);
	COLOR = vec4(c, plate(UV));
}
