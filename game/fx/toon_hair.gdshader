// hair cel shader: the character toon shader (one hard shade band, fake
// camera-relative key) PLUS an optional top->bottom gradient per material slot.
// kept separate from toon.gdshader so the body/gear surfaces never pay the
// gradient's extra vertex work -- only hair uses this.
//
// the gradient runs along the hair's HEIGHT in the hair root's own space, not
// world space: grad_root_inv (the hair root's inverse world transform, pushed
// each frame by ModelRig.tick_hair_gradient while a gradient is on) times
// MODEL_MATRIX cancels the head bone's animation, so the band stays painted on
// the hair as the character jumps, dives or leans. this also unifies the hair's
// several mesh pieces (bangs, back, tuft), each authored in its own local frame,
// into one coherent vertical coordinate.
shader_type spatial;
// cull_disabled (not cull_back): the hair-flip mirror uses a negative scale, which
// reverses face winding -- with cull_back a flipped hairdo renders inside-out. the
// shader is unshaded, so drawing both sides is visually identical from outside (front
// faces occlude the back via depth) and just costs a little overdraw. also closes any
// gaps a thin hair mesh had.
render_mode unshaded, cull_disabled;
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
// the rim's share here: hair is flat spikes and cards that light up solid side-on,
// so it takes a fraction; accessories (same shader) are solid shapes and take the
// full rim (ModelRig._mount_accessory sets 1.0)
uniform float rim_scale = 0.3;

uniform float hidden : hint_range(0.0, 1.0) = 0.0;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3 key_dir = vec3(-0.45, 0.62, 0.65);
uniform float world_mix = 0.0;
uniform vec3 world_key = vec3(-0.45, 0.78, 0.44);
uniform float band_edge = 0.12;
uniform float shade = 0.42;
uniform float band_softness = 0.02;
uniform float level = 0.8;

// gradient: off by default, so a slot with no gradient renders exactly like the
// flat toon shader (base = albedo).
uniform float grad_on = 0.0;
uniform vec4 top_color : source_color = vec4(1.0);
uniform vec4 bottom_color : source_color = vec4(1.0);
uniform float grad_y_min = 0.0;      // hair's vertical extent in root space,
uniform float grad_y_max = 1.0;      // measured once at setup
uniform float grad_fade_start : hint_range(0.0, 1.0) = 0.0;
uniform float grad_fade_end : hint_range(0.0, 1.0) = 1.0;
uniform mat4 grad_root_inv;          // hair root inverse world xform (per frame)

varying float grad_local_y;

void vertex() {
	// height of this vertex in the hair root's local space -> stable under
	// animation and shared across every hair mesh piece
	grad_local_y = (grad_root_inv * MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

// whole-body flash (universal); see toon.gdshader
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (hidden > 0.5) {
		discard;
	}
	// the hair-flip mirror is a negative scale: it reverses winding (so the visible
	// faces arrive as back faces) and, in the Compatibility renderer, leaves the
	// normal pointing the wrong way. FRONT_FACING points the fake-lit normal back at
	// the camera side, so a mirrored hairdo shades the same as an unmirrored one
	// (also fixes shading on the back faces that cull_disabled now draws).
	vec3 n = normalize(NORMAL);
	if (!FRONT_FACING) {
		n = -n;
	}
	vec3 view_key = normalize(key_dir);
	vec3 l = view_key;
	if (world_mix > 0.001) {
		vec3 wk = normalize((VIEW_MATRIX * vec4(normalize(world_key), 0.0)).xyz);
		l = normalize(mix(view_key, wk, world_mix));
	}
	// the terminator's AA is ~1 pixel wherever it lands (Owen: the face band should
	// be "as sharp as it is on the hands"): a fixed softness in n.l is sub-pixel on
	// a hand but smears across many pixels on a big, gently curved face
	float ndl = dot(n, l);
	float aa = clamp(fwidth(ndl) * 0.75, 0.0005, band_softness);
	float lit = smoothstep(band_edge - aa, band_edge + aa, ndl);
	vec3 base = jv_in(albedo.rgb);
	if (grad_on > 0.5) {
		float range = max(grad_y_max - grad_y_min, 0.0001);
		float ny = (grad_local_y - grad_y_min) / range;
		float window = max(grad_fade_end - grad_fade_start, 0.0001);
		float t = clamp((ny - grad_fade_start) / window, 0.0, 1.0);
		base = mix(jv_in(bottom_color.rgb), jv_in(top_color.rgb), t);
	}
	ALBEDO = base * level * mix(1.0 - shade, 1.0, lit);
	ALBEDO = jv_toon_rim(ALBEDO, n, VIEW, rim_scale, l, world_lit);
	ALBEDO *= mix(vec3(1.0), jv_body_tint, world_lit);
	ALBEDO = jv_arena_light(ALBEDO, n, VIEW, VERTEX, INV_VIEW_MATRIX, world_lit);
	ALBEDO = mix(ALBEDO, jv_in(flash_color.rgb), flash);
	ALBEDO = jv_out(ALBEDO);
}
