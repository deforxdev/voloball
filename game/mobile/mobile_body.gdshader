shader_type spatial;
render_mode unshaded, cull_back;
uniform vec4 albedo : source_color = vec4(1.0);
uniform float hidden = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash = 0.0;
uniform vec4 sleeve_color : source_color = vec4(1.0);
uniform float sleeve_cut = 1000.0;
varying float sleeve_y;
void vertex() {
	sleeve_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y - MODEL_MATRIX[3].y;
}
void fragment() {
	if (hidden > 0.5) { discard; }
	vec3 base = sleeve_y > sleeve_cut ? sleeve_color.rgb : albedo.rgb;
	float band = 0.72 + 0.28 * max(dot(normalize(NORMAL), normalize(vec3(-0.4, 0.7, 0.6))), 0.0);
	ALBEDO = mix(base * band, flash_color.rgb, flash);
}
