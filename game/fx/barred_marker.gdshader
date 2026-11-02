shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

// A single rounded X avoids seams where two outlined bars would intersect.
float cross_distance(vec2 p) {
	vec2 q = vec2(p.x + p.y, p.y - p.x) * 0.70710678;
	vec2 a = q - vec2(clamp(q.x, -0.53, 0.53), 0.0);
	vec2 b = q - vec2(0.0, clamp(q.y, -0.53, 0.53));
	return min(length(a), length(b)) - 0.115;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float d = cross_distance(p);
	float aa = max(fwidth(d), 0.002);
	float beat = 0.5 + 0.5 * sin(TIME * 3.2);
	float rim = 1.0 - smoothstep(0.12 - aa, 0.12 + aa, d);
	float white = 1.0 - smoothstep(0.075 - aa, 0.075 + aa, d);
	float fill = 1.0 - smoothstep(-aa, aa, d);
	vec3 coral = mix(vec3(0.96, 0.025, 0.055), vec3(1.0, 0.12, 0.16), UV.y);
	vec3 col = mix(vec3(0.015, 0.018, 0.03), vec3(1.0), white);
	float glow = (1.0 - smoothstep(0.078, 0.24 + beat * 0.035, d)) * (0.12 + beat * 0.2);
	ALBEDO = jv_out(mix(col, coral, fill) + coral * glow * 0.55);
	EMISSION = jv_out(coral * (0.08 + beat * 0.13) * fill);
	ALPHA = max(rim, glow);
}
