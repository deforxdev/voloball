// the stage ball's cel material: the authored diffuse, flat and unlit, split
// by ONE hard camera-relative shade band -- the same fake-key language as the
// character shader (game/fx/toon.gdshader), so the ball reads like the anime
// ball from every angle: a crescent of shadow, not real lighting.
shader_type spatial;
render_mode unshaded, cull_back;
// marks the body/ball in the stencil so drop shadows never draw over it (feet sunk
// in sand or grass used to clip through their own shadow). see GameConfig.SHADOW_STENCIL
stencil_mode write, compare_always, 7;   // GameConfig.BALL_STENCIL (bodies are 1..6)
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// the same hairline toon rim as the characters (Owen: "the ball probably needs a rim too")
#include "res://game/fx/toon_rim.gdshaderinc"
// TIME OF DAY: a body standing in the stage world takes the stage's light (night
// cools and dims it, evening warms it) so it sits in the scene. world_lit is set by
// GameConfig.world_light only on in-world bodies; previews/portraits stay untinted.
uniform float world_lit = 0.0;
global uniform vec3 jv_body_tint;

uniform sampler2D albedo_tex : source_color, hint_default_white, filter_linear_mipmap;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// view-space key: -x left, +y up, +z toward the camera (same as characters)
uniform vec3 key_dir = vec3(-0.45, 0.62, 0.65);
uniform float band_edge = 0.12;     // where the single band splits
uniform float shade = 0.32;         // how much darker the shaded crescent is
uniform float band_softness = 0.02; // a hair of AA on the terminator
// the ball's centre in this mesh's local space (ball.gd fills it in). The band
// follows the SPHERE'S direction field, never the surface normal: authored
// panel geometry has seams and inner shells, and shading those normals drew a
// separate broken terminator per panel -- the "two balls inside" look.
uniform vec3 local_center = vec3(0.0, 0.0, 0.0);

varying vec3 sphere_n;

void vertex() {
	sphere_n = (MODELVIEW_MATRIX * vec4(normalize(VERTEX - local_center), 0.0)).xyz;
}

void fragment() {
	vec3 base = jv_in(texture(albedo_tex, UV).rgb) * jv_in(albedo_color.rgb);
	float lit = smoothstep(band_edge - band_softness, band_edge + band_softness,
		dot(normalize(sphere_n), normalize(key_dir)));
	vec3 c = base * mix(1.0 - shade, 1.0, lit);
	c = jv_toon_rim(c, normalize(sphere_n), VIEW, 1.0, normalize(key_dir), world_lit);
	ALBEDO = jv_out(c * mix(vec3(1.0), jv_body_tint, world_lit));
}
