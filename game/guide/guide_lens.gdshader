shader_type canvas_item;

// THE MAGNIFYING GLASS over the book: a round window onto the spread picture,
// `zoom` times closer, centred on what's under the glass. the spread is drawn
// at twice its size while the glass is out, so the close look stays sharp.

uniform sampler2D page : source_color, filter_linear;
uniform vec2 center = vec2(0.5);    // the spot under the glass, in the spread's uv
uniform float zoom = 2.0;
uniform vec2 span = vec2(0.1, 0.16); // the glass's size, in the spread's uv

void fragment() {
	vec2 d = UV - vec2(0.5);
	float r = length(d) * 2.0;
	if (r > 1.0) {
		discard;
	}
	vec2 uv = center + d * span / zoom;
	vec4 c = texture(page, uv);
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		c = vec4(0.0, 0.0, 0.0, 0.0);
	}
	// a little lens shine and a darker rim
	c.rgb *= 1.0 - 0.18 * smoothstep(0.75, 1.0, r);
	c.rgb += vec3(0.12) * smoothstep(0.35, 0.0, length(d - vec2(-0.18, -0.2)));
	c.a *= smoothstep(1.0, 0.97, r);
	COLOR = c;
}
