// Serve-zone floor marker. The bright edge and soft halo make the panel read
// against different courts without hiding the floor or relying on bloom.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec4 tint : source_color = vec4(0.35, 0.95, 0.42, 1.0);
uniform vec2 size = vec2(12.0, 7.0);       // legal border, in world metres
uniform vec2 quad_size = vec2(12.9, 7.9); // includes room for the outer halo
uniform float corner_radius = 0.7;     // rounded corner radius, metres
uniform float fill_alpha = 0.09;
uniform float glow_reach = 0.42;

void fragment() {
	vec2 half = size * 0.5;
	vec2 p = (UV - vec2(0.5)) * quad_size; // metres from centre
	vec2 q = abs(p) - (half - vec2(corner_radius));
	float sd = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - corner_radius;
	if (sd > glow_reach) {
		discard;
	}
	float aa = max(fwidth(sd), 0.005);
	float inside = 1.0 - smoothstep(-aa, aa, sd);
	float halo = (1.0 - inside) * (1.0 - smoothstep(0.0, glow_reach, sd));
	float inner_glow = inside * (1.0 - smoothstep(0.0, 0.8, -sd));
	float edge = 1.0 - smoothstep(0.04, 0.15 + aa, abs(sd));
	float bright_core = 1.0 - smoothstep(0.025, 0.075 + aa, abs(sd));
	float dark_keyline = 1.0 - smoothstep(0.025, 0.055 + aa, abs(sd + 0.19));
	vec3 color = mix(jv_in(tint.rgb), vec3(1.0), bright_core * 0.55);
	color = mix(color, vec3(0.015, 0.022, 0.02), dark_keyline * 0.88);
	ALBEDO = jv_out(color);
	ALPHA = max(max(inside * fill_alpha, inner_glow * 0.19),
		max(max(halo * 0.20, edge * 0.84), max(bright_core * 0.96, dark_keyline * 0.76)));
}
