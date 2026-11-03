shader_type spatial;
render_mode unshaded;
uniform float hidden = 0.0;
uniform vec4 color_a : source_color = vec4(1.0, 0.87, 0.25, 1.0);
uniform vec4 color_b : source_color = vec4(0.16, 0.35, 0.85, 1.0);
uniform float spin = 0.0;
void fragment() {
	if (hidden > 0.5) { discard; }
	float stripe = step(0.5, fract(UV.x * 6.0 + spin * 0.01));
	ALBEDO = mix(color_a.rgb, color_b.rgb, stripe);
}
