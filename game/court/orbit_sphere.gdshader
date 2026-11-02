// Pale TILED SPHERE for the void / Tutorial background (the Death-Star-ish
// "world select" planets). A soft pale sphere with a faint panel grid + fake
// top-light so it reads as a distant 3D body. Unshaded (the game fakes lighting).
shader_type spatial;
render_mode unshaded, cull_back;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
global uniform vec3 jv_world_tint;   // the stage's time of day (tutorial dark)

uniform vec3 light_dir = vec3(-0.4, 0.8, 0.4);
// faint pale WIREFRAME globe: the body nearly matches the bright sky so mostly the
// thin grid lines read, like the reference's ghostly ringed spheres.
uniform vec3 base_color : source_color = vec3(0.93, 0.95, 0.98);
uniform vec3 seam_color : source_color = vec3(0.6, 0.68, 0.84);
uniform float tiles = 13.0;
uniform float seam_w : hint_range(0.0, 0.3) = 0.03;
uniform float ambient : hint_range(0.0, 1.0) = 0.88;

varying vec3 world_normal;
varying vec3 local_pos;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	local_pos = VERTEX;
}

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // see the player through it
	vec3 n = normalize(local_pos);
	// panel grid in spherical coords
	float u = atan(n.z, n.x) / 6.2831853 + 0.5;
	float v = asin(clamp(n.y, -1.0, 1.0)) / 3.1415927 + 0.5;
	vec2 g = fract(vec2(u, v) * tiles);
	float line = 0.0;
	line = max(line, step(g.x, seam_w));
	line = max(line, step(1.0 - seam_w, g.x));
	line = max(line, step(g.y, seam_w));
	line = max(line, step(1.0 - seam_w, g.y));
	vec3 col = mix(jv_in(base_color), jv_in(seam_color), line * 0.6);
	float d = clamp(dot(world_normal, normalize(light_dir)) * 0.5 + 0.5, 0.0, 1.0);
	ALBEDO = jv_out(col * mix(ambient, 1.0, d) * jv_world_tint);
}
