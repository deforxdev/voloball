shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, fog_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
// (a straight pass-through, so the pair cancels; kept so any colour math added later stays right)
#include "res://game/fx/compat_color.gdshaderinc"

uniform sampler2D label_texture : source_color, filter_linear;
uniform float full_size_distance = 12.0;

void vertex() {
	// THIS camera's depth: shared split-screen bodies must size per view.
	vec3 center = MODELVIEW_MATRIX[3].xyz;
	float depth = max(-center.z, 0.001);
	float shrink = clamp(pow(full_size_distance / max(depth, full_size_distance), 0.8), 0.38, 1.0);
	float fixed_scale = (PROJECTION_MATRIX[3][3] == 0.0) ? depth : 1.0 / PROJECTION_MATRIX[1][1];
	POSITION = PROJECTION_MATRIX * vec4(center + vec3(VERTEX.xy * fixed_scale * shrink, 0.0), 1.0);
}

void fragment() {
	vec4 col = texture(label_texture, UV);
	ALBEDO = jv_out(jv_in(col.rgb));
	ALPHA = col.a;
}
