shader_type spatial;
// Forward+ MULTIPLIES the floor by the shadow (a shadow is the floor's own colour,
// darker). Compatibility can't: a multiply goes near-black there whenever the
// stage has glow (CLAUDE.md), so it SUBTRACTS an even grey instead -- it blends
// in sRGB, where an even step darkens a colour without turning its hue.
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
render_mode blend_sub, depth_draw_never, cull_back, specular_disabled, ambient_light_disabled, fog_disabled;
#else
render_mode blend_mul, depth_draw_never, cull_back, specular_disabled, ambient_light_disabled, fog_disabled;
#endif

// THE CAST-SHADOW CATCHER (Owen 2026-10-14: real player shadows, the round drop
// shadow kept as the low setting). The game draws everything unshaded, so no
// surface can take a real shadow; ShadowSun lays this sheet over the floor and
// its sun lights ONLY this sheet (its own layer, and the pure magenta colour
// below). Everything comes from the sun's light() (ATTENUATION: 1 in the sun,
// 0 in shadow); no EMISSION, which on Compatibility swallowed the light's part.
// (shadow_to_opacity drew nothing here; a screen-texture read of the floor came
// back empty on some stages.)

// Forward+: what each channel keeps in full shadow, a touch more blue so it reads cool
uniform vec3 shade = vec3(0.34, 0.36, 0.48);
// Compatibility: how much is taken off each channel (sRGB, as seen on screen)
// in full shadow. Less off blue/green than red so the orange court darkens to
// brown instead of going red
uniform vec3 shade_sub = vec3(0.26, 0.2, 0.13);

void fragment() {
	ALBEDO = vec3(1.0);
}

void light() {
	// only ShadowSun's sun counts: it's pure magenta (no other light in the game
	// is), so a stage's own lamps reaching this layer change nothing
	if (LIGHT_IS_DIRECTIONAL && LIGHT_COLOR.g < LIGHT_COLOR.r * 0.01 && LIGHT_COLOR.r > 0.0) {
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
		// the output is turned linear -> sRGB before it's subtracted, which boosted
		// these ~2.5x (the court went red): hand it the linear value instead
		DIFFUSE_LIGHT += pow(shade_sub, vec3(2.2)) * (1.0 - ATTENUATION);
#else
		DIFFUSE_LIGHT += mix(shade, vec3(1.0), ATTENUATION);
#endif
	}
}
