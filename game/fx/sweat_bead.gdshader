// SWEAT BEAD. the anime sweat droplet: a clear little oval with a crisp ink-blue
// rim, a white highlight crescent along its upper edge and a tiny glint -- a bead
// you read by its outline, not a soft blob. Camera-facing quad from Fx's bead pool;
// `fade` runs it out, `tint` carries the rim colour.
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec3 rim_color : source_color = vec3(0.16, 0.36, 0.72);
uniform vec3 body_color : source_color = vec3(0.78, 0.9, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;
uniform float stretch = 1.18;   // taller than wide: a falling bead

void vertex() {
	// billboard that keeps the instance scale
	vec3 s = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * s.x, INV_VIEW_MATRIX[1] * s.y,
		INV_VIEW_MATRIX[2] * s.z, MODEL_MATRIX[3]);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= stretch;
	float r = length(p);
	float aa = fwidth(r) * 1.2;
	float inside = 1.0 - smoothstep(0.86 - aa, 0.86 + aa, r);
	if (inside <= 0.001) {
		discard;
	}
	// the rim: a crisp ring at the edge
	float rim = smoothstep(0.55 - aa, 0.55 + aa, r) * inside;
	// highlight crescent: an arc hugging the upper-left inside of the rim
	vec2 hc = p - vec2(-0.12, 0.14);
	float cres = (1.0 - smoothstep(0.5 - aa, 0.5 + aa, length(hc)))
		* smoothstep(0.32 - aa, 0.32 + aa, length(p - vec2(-0.02, 0.0)))
		* step(0.0, -p.x + p.y + 0.2);
	// the glint: a tiny bright dot low-right
	float glint = 1.0 - smoothstep(0.1 - aa, 0.1 + aa, length(p - vec2(0.26, -0.3)));
	vec3 col = jv_in(body_color);
	float a = 0.28;
	col = mix(col, jv_in(rim_color), rim);
	a = mix(a, 0.95, rim);
	col = mix(col, vec3(1.0), max(cres * 0.95, glint));
	a = max(a, max(cres, glint) * 0.95);
	ALBEDO = jv_out(col);
	ALPHA = jv_alpha(a * inside * fade);
}
