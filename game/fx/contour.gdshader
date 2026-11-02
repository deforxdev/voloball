shader_type spatial;
// THE OUTER CONTOUR (prototype, GameConfig.contour_outline). a second hull over
// every character mesh, hung as the ink shell's next_pass so it rides the same
// skin, blend shapes, slot hiding and restyles. two things make it a contour
// rather than another grown shell:
//
// 1. it grows in SCREEN PIXELS, not metres (the push happens in clip space), so
//    the line keeps a readable width at match distance instead of thinning to
//    nothing. the width eases from far_px to near_px with how BIG the body is on
//    screen (pixels per metre at its depth, at a 1080-tall frame), not camera
//    distance: a long-lens portrait is a close-up even from far back, and a
//    small zoomed-out player gets the thin line (Owen 2026-10-17, both were
//    wrong on distance). it scales up with viewport heights over 1080 so 1440p
//    reads like 1080p, never down, so a 256 px portrait gets the full width.
// 2. it only draws where the stencil is NOT the body (every body/hair/ball surface
//    and the thin shell write 1, see GameConfig.SHADOW_STENCIL). so it is the
//    outside edge of the whole character only: no lines across the face, hair
//    over the forehead etc. -- the thin world-space shell still draws those.
//
// depth-tested like any mesh, so the net or another player in front hides it.
// transparent pass (ALPHA is written) so the bodies have marked the stencil first.
// depth_draw_always: the outline is part of the body, so see-through things
// BEHIND it (the player ring, floor decals, fx) must not paint over it. with no
// depth write they did, and the outline vanished wherever the ring crossed the
// feet (Owen 2026-10-17)
render_mode unshaded, cull_front, depth_draw_always, shadows_disabled, blend_mix;
stencil_mode read, compare_not_equal, 1;

#include "res://game/fx/compat_color.gdshaderinc"

uniform vec4 line_color : source_color = vec4(0.05, 0.05, 0.08, 1.0);
uniform float near_px = 7.0;      // width once a body is near_ppm big or bigger (1080p pixels)
uniform float far_px = 1.75;      // width at far_ppm and smaller (1.25 a touch thin zoomed out)
uniform float near_ppm = 350.0;   // pixels per metre (1080 tall) that count as a close-up
uniform float far_ppm = 40.0;     // ...and as zoomed right out (120 thinned the freeplay camera)
// THE THREE PER-BODY VALUES BELOW ARE PLAIN UNIFORMS ON EACH BODY'S OWN COPY of
// this material (ModelRig.own_contour), never `instance uniform`s. instance
// uniforms share one global buffer, which Compatibility caps at 4096 slots: the
// menu's bodies and portraits nearly filled it, a rebuilt practice court went
// over, and every new shell drew with no slot -- width 0, no outline at all
// (Owen 2026-10-18, "the outlines fail when rebuilding"; log: "Too many instances
// using shader instance variables").
// per body, on top of the shared widths: the portrait rig renders a 480x620
// frame the card then shows ~144 px tall, so it doubles its own line
// (CharacterPortrait, ModelRig.set_contour_px_scale)
uniform float contour_px_scale = 1.0;
// the 3D resolution of the view this body draws in (Viewport.scaling_3d_scale,
// ModelRig.sync_res_scale). VIEWPORT_SIZE is the reduced buffer there, so a width
// in its pixels came out twice as fat on screen at 50% (Owen 2026-10-21: "it
// gets entirely too fat", but some for clarity is good). RES_THICKEN is how much
// of that growth is kept: 0 = the same on-screen width at any resolution, 1 = all
// of it (2x at 50%). 0.5 = 1.4x at 50%, 2x at 25%
uniform float contour_res = 1.0;
const float RES_THICKEN = 0.5;
// metres toward the camera: the head group's contour (ModelRig.head_stencil_id)
// is pulled over the shirt collar so the jaw line isn't cut by it. safe: its own
// group's stencil mark still stops it anywhere on the head, hair or face
uniform float contour_pull = 0.0;
// THE LAST-TOUCHER HIGHLIGHT: the contour itself turns the team colour (alpha =
// how much) and widens by hl_width. replaced the old fat grown aura shell
// (ModelRig/Player.set_highlight), which drew inside the silhouette
uniform vec4 contour_tint : source_color = vec4(0.0);
uniform float hl_width = 1.6;     // the highlighted line's width, times the normal one

void vertex() {
	vec4 view = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	view.xyz += normalize(-view.xyz) * contour_pull;
	vec4 clip = PROJECTION_MATRIX * view;
	vec3 vn = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	// the normal's direction on screen, in pixels (so the push is round, not
	// stretched by the aspect ratio)
	vec2 dir = (PROJECTION_MATRIX * vec4(vn, 0.0)).xy * VIEWPORT_SIZE;
	float len = length(dir);
	dir = len > 1e-5 ? dir / len : vec2(0.0);
	// how many 1080p pixels one metre spans at this depth ([1][1] is the
	// vertical focal scale; perspective and orthographic alike). abs: the RD
	// renderers flip y in the projection, so it comes in negative there
	float ppm = abs(PROJECTION_MATRIX[1][1]) * 540.0 / max(clip.w, 1e-4);
	// linear, not smoothstep: smoothstep hugs far_px and left the everyday
	// freeplay / match camera (a mid-size body) a hairline. the 1440p step-up
	// reads the WINDOW's height (the buffer's over the 3D resolution), then the
	// width goes into buffer pixels keeping RES_THICKEN of the growth
	float rs = clamp(contour_res, 0.25, 1.0);
	float px = mix(far_px, near_px, clamp((ppm - far_ppm) / (near_ppm - far_ppm), 0.0, 1.0))
		* max(VIEWPORT_SIZE.y / rs, 1080.0) / 1080.0 * contour_px_scale
		* pow(rs, 1.0 - RES_THICKEN)
		* mix(1.0, hl_width, contour_tint.a);
	// only push where the normal really points sideways on screen. a normal aimed
	// at (or away from) the camera -- a shirt hem rim, a waistband -- projects to
	// a tiny, noisy 2D direction, and the full push along it made sharp black
	// spikes at the shirt / shorts edges (Owen 2026-10-17). silhouette vertices
	// have a sideways normal by definition, so the outline itself keeps its width
	px *= smoothstep(0.15, 0.45, length(vn.xy));
	// pixels -> NDC is 2/size; times w so the perspective divide undoes it
	clip.xy += dir * px * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = jv_out(mix(jv_in(line_color.rgb), jv_in(contour_tint.rgb), contour_tint.a));
	ALPHA = line_color.a;
}
