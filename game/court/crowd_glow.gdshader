// THE GLOW STICKS' GLARE (Owen 2026-10-14: "it'd be cool if they glared a bit
// like the lights"): a next_pass on the crowd MultiMesh (gym_crowd.gd), drawing
// only for fans holding a stick, a soft coloured glow round it. Additive, like
// the spotlights' glare (light_halo.gdshader), so it only ever brightens and
// shows through the arena haze.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
#define CROWD_GLOW_PASS
#include "res://game/fx/compat_color.gdshaderinc"
#include "res://game/court/sun_windows.gdshaderinc"
#include "res://game/court/crowd_body.gdshaderinc"

uniform float glare_strength = 0.8;
uniform float glare_size = 0.09;   // fan heights out from the stick where it's gone

void fragment() {
	float d = jv_stick_dist(uv, vrand);
	float a = pow(clamp(1.0 - d / glare_size, 0.0, 1.0), 2.2);
	// ADDITIVE: no jv_out (see light_halo.gdshader)
	ALBEDO = jv_in(jv_stick_color(vrand)) * a * glare_strength;
}
