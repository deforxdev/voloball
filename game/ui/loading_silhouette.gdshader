shader_type canvas_item;

// the loading screen's runner: a render of the character, drawn as one flat
// colour wherever it covers (pure white by default). only its alpha is used.
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float a = texture(TEXTURE, UV).a;
	COLOR = vec4(tint.rgb, tint.a * a * COLOR.a);
}
