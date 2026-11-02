shader_type canvas_item;

// THE STICKER OUTLINE: one pass for every kind of studio layer. a stickered
// layer is drawn first into a little viewport of its own (StudioCanvas: the
// layer's IMAGE), so whatever it is (a posed character, a ball render, a
// pattern, a line of text, a table) arrives here as plain pixels, and the
// outline is an ALPHA DILATION of them: every pixel within `width` of something
// drawn becomes `line_color`, and the layer sits on top. samples in rings out to
// the width (rings x taps below), so thin parts like fingers and letter strokes
// keep a full line.
//
// the same pass makes the layer's drop shadow when `solid` is on: everything one
// colour, the dilation past `width` feathering off over `soft` pixels.
//
// (a CanvasGroup would have handed the shader the layer's pixels without the
// extra viewport, but its clear wiped every layer under it, in both renderers.)
//
// it runs only while the studio canvas (or a book page) re-renders, never per
// frame. widths are in the image's own pixels.

uniform vec4 line_color : source_color = vec4(1.0);
uniform float width = 0.0;
uniform float soft = 0.0;
uniform bool solid = false;

const int RINGS = 6;
const int TAPS = 24;

float alpha_at(sampler2D tex, vec2 uv) {
	float inside = step(0.0, uv.x) * step(0.0, uv.y) * step(uv.x, 1.0) * step(uv.y, 1.0);
	return texture(tex, uv).a * inside;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float reach = width + soft;
	float a = c.a;
	if (reach > 0.0) {
		for (int r = 1; r <= RINGS; r++) {
			float rr = reach * float(r) / float(RINGS);
			float wgt = 1.0;
			if (rr > width) {
				float t = (rr - width) / max(soft, 0.001);
				wgt = exp(-3.0 * t * t);
			}
			for (int i = 0; i < TAPS; i++) {
				float ang = 6.2831853 * (float(i) + 0.5 * float(r % 2)) / float(TAPS);
				vec2 off = vec2(cos(ang), sin(ang)) * rr * TEXTURE_PIXEL_SIZE;
				a = max(a, alpha_at(TEXTURE, UV + off) * wgt);
			}
		}
	}
	if (solid) {
		COLOR = vec4(line_color.rgb, line_color.a * a);
	} else {
		// the layer over its outline. the line is solid even round a see-through
		// layer (a pattern at 85%): half drawn counts as drawn
		float ao = clamp(a * 2.0, 0.0, 1.0) * line_color.a;
		float oa = c.a + ao * (1.0 - c.a);
		vec3 rgb = oa > 0.0001 ? (c.rgb * c.a + line_color.rgb * ao * (1.0 - c.a)) / oa : c.rgb;
		COLOR = vec4(rgb, oa);
	}
}
