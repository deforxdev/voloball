// SLATE SKY for the tutorial's dark theme: a plain deep-navy gradient, no stars or
// clouds (the training space stays clean). A sky shader, not a flat background
// colour: the flat colour came out pitch black on Forward+ (the filmic toe) and
// pale on Compatibility; through jv_in/jv_out a sky matches on both.
shader_type sky;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec3 top_color : source_color = vec3(0.07, 0.08, 0.16);
uniform vec3 horizon_color : source_color = vec3(0.18, 0.2, 0.3);

void sky() {
	float t = clamp(EYEDIR.y, 0.0, 1.0);
	COLOR = jv_out(mix(jv_in(horizon_color), jv_in(top_color), pow(t, 0.6)));
}
