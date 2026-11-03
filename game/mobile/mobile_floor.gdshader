shader_type spatial;
render_mode unshaded;
uniform vec4 base_color : source_color = vec4(0.24, 0.48, 0.66, 1.0);
void fragment() { ALBEDO = base_color.rgb; }
