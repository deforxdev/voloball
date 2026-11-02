shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

// Ball-only marker with an open centre for aiming a player's feet into the
// target. The ball shadow is hidden underneath this marker while it is active.
uniform vec4 tint : source_color = vec4(1.0, 0.81, 0.34, 1.0);
uniform vec4 ink : source_color = vec4(0.025, 0.032, 0.05, 1.0);
uniform vec4 centre : source_color = vec4(0.075, 0.085, 0.11, 1.0);

void fragment() {
	float r = length(UV * 2.0 - 1.0);
	float aa = max(fwidth(r), 0.002);
	vec3 ink_c = jv_in(ink.rgb);
	vec3 col = jv_in(centre.rgb);
	col = mix(col, ink_c, smoothstep(0.34 - aa, 0.35 + aa, r));
	col = mix(col, vec3(1.0), smoothstep(0.39 - aa, 0.40 + aa, r));
	col = mix(col, ink_c, smoothstep(0.51 - aa, 0.53 + aa, r));
	col = mix(col, jv_in(tint.rgb), smoothstep(0.56 - aa, 0.56 + aa, r));
	col = mix(col, ink_c, smoothstep(0.79 - aa, 0.79 + aa, r));
	ALBEDO = jv_out(col);
	// Let the court breathe through the pale centre and gold band; the fine
	// blue-grey keylines stay nearly solid so the target remains easy to read.
	float alpha = 0.0;
	alpha = mix(alpha, 0.92, smoothstep(0.34 - aa, 0.37 + aa, r));
	alpha = mix(alpha, 0.68, smoothstep(0.39 - aa, 0.42 + aa, r));
	alpha = mix(alpha, 0.92, smoothstep(0.50 - aa, 0.53 + aa, r));
	alpha = mix(alpha, tint.a * 0.84, smoothstep(0.56 - aa, 0.59 + aa, r));
	alpha = mix(alpha, 0.9, smoothstep(0.79 - aa, 0.81 + aa, r));
	ALPHA = alpha * (1.0 - smoothstep(0.83 - aa, 0.83 + aa, r));
}
