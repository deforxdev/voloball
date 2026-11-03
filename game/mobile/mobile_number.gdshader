shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D number_tex;
uniform vec4 ink : source_color = vec4(0.05, 0.05, 0.05, 1.0);
void fragment() {
	if (texture(number_tex, UV).a < 0.5) { discard; }
	ALBEDO = ink.rgb;
}
