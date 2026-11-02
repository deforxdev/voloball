shader_type canvas_item;

// THE XP BAR: a pill of liquid. the fill's front edge is a sloshing wave (it
// slops harder right after a gain: `slosh`) with a bright meniscus, and bubbles
// rise through it. FLAT like the rest of the ui (the tomodachi pass, Owen
// 2026-10-18): one green, no ink outline, no gloss band, no inset shading; the
// motion is the whole show. `flash` whites it out for a level-up.
// driven by LiquidBar (game/ui/liquid_bar.gd).

uniform float fill : hint_range(0.0, 1.0) = 0.5;
uniform vec2 rect_px = vec2(400.0, 24.0);
uniform vec4 liquid : source_color = vec4(0.247, 0.831, 0.416, 1.0);   // UiStyle.CHIP #3fd46a
uniform vec4 track : source_color = vec4(0.0, 0.0, 0.0, 0.3);
uniform float slosh = 0.0;
uniform float flash = 0.0;

float sd_pill(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec2 px = UV * rect_px;
	vec2 c = rect_px * 0.5;
	float r = rect_px.y * 0.5;
	float d = sd_pill(px - c, c, r);
	float outer = clamp(0.5 - d, 0.0, 1.0);
	float t = TIME;

	// the track: the empty part of the pill, one flat colour
	vec3 col = track.rgb;
	float a = track.a;

	// the front edge sloshes: two sines up the bar's height, harder after a gain
	float full = rect_px.x * fill;
	// a gentle lean that rocks back and forth, sloshing harder after a gain:
	// the amplitude follows the bar's height so a thin bar never grows teeth
	float amp = rect_px.y * (0.06 + slosh * 0.16);
	float wave = sin(UV.y * 3.1416 + t * 4.0) * amp
		+ sin(UV.y * 6.2831 - t * 2.7) * amp * 0.3;
	float edge_on = step(0.002, fill) * (1.0 - step(0.998, fill));
	float front = full + wave * edge_on;
	float liq = clamp(front - px.x + 0.5, 0.0, 1.0) * step(0.002, fill);

	// liquid body: one flat green
	vec3 lc = liquid.rgb;
	// the meniscus: a bright lip on the moving front
	float lip = 1.0 - smoothstep(0.0, 3.5, abs(front - px.x));
	lc = mix(lc, vec3(1.0), lip * 0.5 * edge_on);

	// bubbles: flat white dots rising through the filled part, each its own pace
	float bub = 0.0;
	for (int i = 0; i < 18; i++) {
		float fi = float(i);
		float bx = hash(fi + 1.3) * max(full - 6.0, 0.0) + 3.0;
		float sp = 0.22 + hash(fi + 7.1) * 0.5;
		float by = 1.0 - fract(t * sp + hash(fi + 3.7));
		float rad = rect_px.y * (0.06 + hash(fi + 11.0) * 0.09);
		vec2 bp = vec2(bx + sin(t * 2.2 + fi * 1.7) * 2.5, by * rect_px.y);
		float bd = length(px - bp);
		bub = max(bub, 1.0 - smoothstep(rad - 0.7, rad + 0.5, bd));
	}
	lc = mix(lc, vec3(1.0), bub * 0.45);

	col = mix(col, lc, liq);
	a = mix(a, 1.0, liq);
	col = mix(col, vec3(1.0), clamp(flash, 0.0, 1.0) * 0.85);
	a = max(a, flash);
	COLOR = vec4(col, a * outer);
}
