// THE COMPATIBILITY COLOUR FIX (include in any spatial / sky shader that does
// colour math). Forward+ shades in LINEAR space. Compatibility (OpenGL) shades
// in sRGB space (Godot's OUTPUT_IS_SRGB is true there), so the same shader math gives a
// different picture there: a source_color input arrives as its raw sRGB value,
// a scale like `* 0.8` darkens by far more than 0.8, and a colour written as a
// number (a constant, a plain vec3 uniform) is read as sRGB and comes out dark
// and oversaturated (measured: game/dev/color_chart.tscn).
//
// the rule, so both renderers draw the same frame:
//   jv_in(c)   on every source_color value (uniform or texture) as it's read
//   ...do the colour math in linear, exactly as Forward+ always has...
//   jv_out(c)  on the final ALBEDO / EMISSION / COLOR written
// numbers already authored in linear (constants, plain uniforms) need nothing.
// on Forward+ both are a no-op.

vec3 jv_srgb_to_linear(vec3 c) {
	return mix(pow((c + vec3(0.055)) / 1.055, vec3(2.4)), c / 12.92,
		vec3(lessThan(c, vec3(0.04045))));
}

vec3 jv_linear_to_srgb(vec3 c) {
	c = max(c, vec3(0.0));
	return mix(1.055 * pow(c, vec3(1.0 / 2.4)) - vec3(0.055), c * 12.92,
		vec3(lessThan(c, vec3(0.0031308))));
}

// decided at COMPILE time (the preprocessor's CURRENT_RENDERER), not with the
// OUTPUT_IS_SRGB built-in: sky shaders don't have that one, and this way Forward+
// compiles the helpers down to nothing
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
// a DARK see-through overlay (a shadow) blends in sRGB here, so the same alpha
// prints far darker than on Forward+; this alpha darkens by the same amount
// (GameConfig.compat_alpha is the same math for plain materials)
float jv_alpha(float a) {
	return 1.0 - pow(1.0 - clamp(a, 0.0, 1.0), 1.0 / 2.4);
}

vec3 jv_in(vec3 c) {
	return jv_srgb_to_linear(c);
}

vec3 jv_out(vec3 c) {
	return jv_linear_to_srgb(c);
}
#else
float jv_alpha(float a) {
	return a;
}

vec3 jv_in(vec3 c) {
	return c;
}

vec3 jv_out(vec3 c) {
	return c;
}
#endif

vec4 jv_in4(vec4 c) {
	return vec4(jv_in(c.rgb), c.a);
}
