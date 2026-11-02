shader_type canvas_item;

// the studio's drop shadow: the layer's picture, as a flat colour, softened.
// the node draws the picture into a rect grown by `pad` (a fraction of that
// rect, per side) so the blur has room past the picture's edge; `radius` is the
// blur's reach in the PICTURE's uv. sampled in rings (49 taps, gaussian weighted):
// it runs only when the studio canvas re-renders, never per frame.
// samples outside the picture count as empty (no clamp-to-edge smear).

uniform vec4 shade_color : source_color = vec4(0.08, 0.08, 0.09, 0.45);
uniform float radius = 0.0;
uniform vec2 pad = vec2(0.0);

void fragment() {
	vec2 inner = (UV - pad) / (vec2(1.0) - 2.0 * pad);
	float a = 0.0;
	float wsum = 0.0;
	for (int r = 0; r <= 3; r++) {
		float rr = radius * float(r) / 3.0;
		int taps = r == 0 ? 1 : 8 * r;
		float w = exp(-2.0 * float(r * r) / 9.0);
		for (int i = 0; i < taps; i++) {
			float ang = 6.2831853 * float(i) / float(taps);
			vec2 uv = inner + vec2(cos(ang), sin(ang)) * rr;
			float inside = step(0.0, uv.x) * step(0.0, uv.y) * step(uv.x, 1.0) * step(uv.y, 1.0);
			a += texture(TEXTURE, uv).a * inside * w;
			wsum += w;
		}
	}
	COLOR = vec4(shade_color.rgb, shade_color.a * a / wsum);
}
