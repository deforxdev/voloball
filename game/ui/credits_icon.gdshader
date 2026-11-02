shader_type canvas_item;

// a square picture with rounded corners and a ring, for the credits page's two
// portraits. any square-ish image works; it is fitted to cover.

uniform vec2 size = vec2(190.0, 190.0);                     // the control's size (set by the page)
uniform float radius : hint_range(0.0, 0.5) = 0.2;          // corner radius, fraction of the side
uniform float ring : hint_range(0.0, 0.2) = 0.035;          // ring width, fraction of the side
uniform vec4 ring_color : source_color = vec4(1.0);

float rounded(vec2 p, float r) {
	// signed distance to a unit rounded square centred on 0 (half-size 0.5)
	vec2 q = abs(p) - vec2(0.5 - r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// where on the control this pixel is, 0..1 (UV is the picture's own, and a
// non-square picture fitted to cover does not span 0..1)
varying vec2 at;

void vertex() {
	at = VERTEX / size;
}

void fragment() {
	vec2 p = at - 0.5;
	float d = rounded(p, radius);
	float aa = fwidth(d) * 1.2;
	float inside = 1.0 - smoothstep(-aa, aa, d);
	float in_pic = 1.0 - smoothstep(-aa, aa, d + ring);
	vec4 pic = texture(TEXTURE, UV);
	vec3 c = mix(ring_color.rgb, pic.rgb, in_pic);
	COLOR = vec4(c, inside);
}
