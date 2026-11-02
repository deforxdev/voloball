shader_type spatial;
// depth TEST stays on: a body standing in this marker occludes it. See the
// header of floor_ring_core.gdshaderinc for why that matters.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled,
	shadows_disabled;

// core rev 12: Compatibility colour parity (core reads its source colours through
// jv_in; this file jv_outs the result).
// core rev 11: tighten the stamina arc and give its green track an ink keyline.
// core rev 9: stamina has a broader white keyline for distance readability.
// core rev 8: stamina uses a bright white keyline and green fill for separation.
// core rev 7: drained part of the meter is now near-black (battery look), not a
// dim tint. core rev 6: bolder half-arc (thicker, brighter track). core rev 5: stamina
// meter is a bold HALF-arc centred on `progress_center`
// (pointed at the camera each frame) + a dark contrast halo. (rev4 tried a full
// collar -- too big/distracting; back to a half bar, now always camera-facing.)
// Bump this comment whenever the include changes -- Godot's shader disk cache
// keys on THIS file's hash and not its includes, so an unchanged .gdshader keeps
// serving the old compile no matter what the include says.
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
#include "res://game/fx/floor_ring_core.gdshaderinc"

void fragment() {
	vec4 c = floor_ring_sample(UV);
	ALBEDO = jv_out(c.rgb);
	ALPHA = c.a;
}
