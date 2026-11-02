// character cel shader: flat albedo split by exactly one hard shade band.
// the key light is FAKE and camera-relative -- it rides the viewer's shoulder
// instead of living in the world, so a character is lit identically from
// every angle and the band always falls the same way on screen. that's the
// whole point: readability is art direction here, not lighting (design doc:
// flat-color cel art, no textures on characters).
shader_type spatial;

uniform float hidden : hint_range(0.0, 1.0) = 0.0;
render_mode unshaded, cull_back;
// marks the body/ball in the stencil so drop shadows never draw over it (feet sunk
// in sand or grass used to clip through their own shadow). see GameConfig.SHADOW_STENCIL
stencil_mode write, compare_always, 1;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// TIME OF DAY: a body standing in the stage world takes the stage's light (night
// cools and dims it, evening warms it) so it sits in the scene. world_lit is set by
// GameConfig.world_light only on in-world bodies; previews/portraits stay untinted.
uniform float world_lit = 0.0;
global uniform vec3 jv_body_tint;
#include "res://game/fx/body_arena_light.gdshaderinc"
#include "res://game/fx/toon_rim.gdshaderinc"

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// LONG-SLEEVE SPLIT (hands only): the floating hand spheres fake a sleeve by
// painting everything above a WORLD-UP line (relative to the hand's own centre)
// in sleeve_color. World-space so the split stays put as the hand rotates --
// sleeve always on top, skin below. sleeve_cut defaults sky-high so every other
// surface is untouched; Player sets a real cut, band and colour for the hands.
uniform vec4 sleeve_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float sleeve_cut = 1000.0;   // world-Y above the hand centre where the sleeve starts
uniform float sleeve_band = 0.0;     // half-width of the dark outline at the colour seam
varying float world_y;
varying float center_y;
// WHOLE-BODY FLASH (universal): mix the final colour toward flash_color by `flash`.
// drives two reads -- a red burnout pulse, and a team-colour blip on a ball touch --
// so a character says what's happening without relying on the thin outline alone.
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;
// view-space key: -x left, +y up, +z toward the camera
uniform vec3 key_dir = vec3(-0.45, 0.62, 0.65);
// how much the key is anchored to the world instead of the camera. 0 keeps
// characters perfectly readable from any angle; nudge up for a little
// form-following shading at the cost of dark backsides
uniform float world_mix = 0.0;
uniform vec3 world_key = vec3(-0.45, 0.78, 0.44);
uniform float band_edge = 0.12;    // where the single band splits
uniform float shade = 0.42;        // how much darker the shaded half is
uniform float band_softness = 0.02; // a hair of AA on the terminator
// unshaded means albedo goes straight to screen, so the lit half needs
// pulling down to sit in the court's exposure instead of glowing
uniform float level = 0.8;

void vertex() {
	// world height of this fragment and of the hand's own centre, so the sleeve
	// split is a horizontal plane in the WORLD -- it doesn't tumble with the hand
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
	center_y = MODEL_MATRIX[3].y;
}

void fragment() {
	// gear left at home (gym socks/kneepads off) simply is not there. discard
	// also removes it from the screen-space ink pass: no fragments, no
	// silhouette. the grown-shell outline is handled per surface in ModelRig.
	if (hidden > 0.5) {
		discard;
	}
	vec3 n = normalize(NORMAL);
	vec3 view_key = normalize(key_dir);
	vec3 l = view_key;
	if (world_mix > 0.001) {
		// NORMAL is view space, so a world-anchored key has to come along
		vec3 wk = normalize((VIEW_MATRIX * vec4(normalize(world_key), 0.0)).xyz);
		l = normalize(mix(view_key, wk, world_mix));
	}
	// the terminator's AA is ~1 pixel wherever it lands (Owen: the face band should
	// be "as sharp as it is on the hands"): a fixed softness in n.l is sub-pixel on
	// a hand but smears across many pixels on a big, gently curved face
	float ndl = dot(n, l);
	float aa = clamp(fwidth(ndl) * 0.75, 0.0005, band_softness);
	float lit = smoothstep(band_edge - aa, band_edge + aa, ndl);
	float seam = world_y - center_y - sleeve_cut;   // >0 = above the sleeve line
	vec3 base = jv_in(seam > 0.0 ? sleeve_color.rgb : albedo.rgb);
	ALBEDO = base * level * mix(1.0 - shade, 1.0, lit);
	// a dark ink line right at the skin/sleeve seam (hands only: sleeve_cut is
	// sky-high elsewhere, so this never triggers on the body)
	if (sleeve_cut < 900.0 && abs(seam) < sleeve_band) {
		ALBEDO = mix(ALBEDO, vec3(0.0), 0.8);
	}
	ALBEDO = jv_toon_rim(ALBEDO, n, VIEW, 1.0, l, world_lit);
	ALBEDO *= mix(vec3(1.0), jv_body_tint, world_lit);
	ALBEDO = jv_arena_light(ALBEDO, n, VIEW, VERTEX, INV_VIEW_MATRIX, world_lit);
	ALBEDO = mix(ALBEDO, jv_in(flash_color.rgb), flash);
	ALBEDO = jv_out(ALBEDO);
}
