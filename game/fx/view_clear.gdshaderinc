// SEE YOUR PLAYER THROUGH THE SCENERY. include in any VENUE shader (walls,
// stands, props, floating decor), never in the court, the net, bodies or the
// ball. two jobs, both a screen-door cut (discard on a 4x4 ordered dither), so
// the surface stays in the opaque pass: no sorting, no transparency, the same
// on Forward+ and Compatibility:
//   * a big soft HOLE around your player and the ball: anything standing between
//     the eye and them, inside a circle on screen, is cut away. only what is IN
//     FRONT of the target, so the wall behind you stays put.
//   * a NEAR FADE: anything close to the lens (the camera pushed into a wall or
//     through a floating cube) dissolves instead of filling the screen.
//
// cheap on purpose (integrated GPUs): game/fx/view_clear.gd works out each hole
// on the CPU once a frame, in the main camera's own view space, so a pixel only
// does a divide, a subtract and a length. any other view (the sun's shadow pass,
// the jumbotron feed, a portrait) sees a different eye and skips the lot.
//
// usage, first line of fragment() (big scenery: walls, stands, banners):
//   if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }
// small props that should vanish WHOLE use jv_view_cleared_object (see below).

global uniform vec4 jv_clear_eye;   // xyz the main camera (world), w = 1 on / 0 off
global uniform vec4 jv_clear_a;     // your player: xy its spot on screen (view x/depth, y/depth),
									// z its depth, w the hole radius in the same units (0 = none)
global uniform vec4 jv_clear_b;     // the ball, the same way
global uniform vec4 jv_clear_cfg;   // x near: gone inside (m), y near: whole past (m),
									// z floor guard (world y; nothing lower is cut), w hole edge (0..1 of the radius)

// is this the view the holes were worked out for?
bool jv_clear_live(mat4 inv_view) {
	if (jv_clear_eye.w <= 0.0) {
		return false;
	}
	vec3 d = inv_view[3].xyz - jv_clear_eye.xyz;
	return dot(d, d) < 0.0625;   // within 25 cm
}

// how much of one hole a point at screen spot s, depth d sits in (0..1)
float jv_clear_hole(vec2 s, float d, float ext, vec4 h) {
	if (h.w <= 0.0) {
		return 0.0;
	}
	// only what stands in front of the target, with a metre of ramp so a prop
	// sliding past the player's depth fades rather than pops
	float front = 1.0 - smoothstep(h.z - 1.8, h.z - 0.8, d - ext);
	float r = h.w + ext / d;
	float inside = 1.0 - smoothstep(r * (1.0 - jv_clear_cfg.w), r, length(s - h.xy));
	return front * inside;
}

// 4x4 ordered (Bayer) threshold: a fixed fine pattern, no shimmer frame to frame
bool jv_clear_dither(float amt, vec2 frag) {
	if (amt <= 0.0) {
		return false;
	}
	ivec2 p = ivec2(mod(frag, 4.0));
	int b = (p.x & 1) * 2 + (p.y & 1) * 3 - ((p.x & 1) & (p.y & 1)) * 4;
	b = b * 4 + ((p.x >> 1) & 1) * 2 + ((p.y >> 1) & 1) * 3 - (((p.x >> 1) & 1) & ((p.y >> 1) & 1)) * 4;
	return amt > (float(b) + 0.5) / 16.0;
}

// v = the fragment, view space (fragment VERTEX)
bool jv_view_cleared(vec3 v, mat4 inv_view, vec2 frag) {
	if (!jv_clear_live(inv_view)) {
		return false;
	}
	// world height of the fragment, one row of the matrix: floors stay solid
	float wy = inv_view[0].y * v.x + inv_view[1].y * v.y + inv_view[2].y * v.z + inv_view[3].y;
	if (wy < jv_clear_cfg.z) {
		return false;
	}
	float d = max(-v.z, 0.01);
	vec2 s = v.xy / d;
	float amt = 1.0 - smoothstep(jv_clear_cfg.x, jv_clear_cfg.y, d);
	amt = max(amt, jv_clear_hole(s, d, 0.0, jv_clear_a));
	amt = max(amt, jv_clear_hole(s, d, 0.0, jv_clear_b));
	return jv_clear_dither(amt, frag);
}

// whole-object version: obj = the object's bounding sphere, world xyz + radius
// in w, worked out in vertex() (MODEL_MATRIX there includes a MultiMesh
// instance's own transform). any part of it in the way and the whole thing
// goes, so a prop never shows up as a cube with a bite out of it:
//   if (jv_view_cleared_object(obj, VIEW_MATRIX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }
bool jv_view_cleared_object(vec4 obj, mat4 view, mat4 inv_view, vec2 frag) {
	if (!jv_clear_live(inv_view)) {
		return false;
	}
	vec3 c = (view * vec4(obj.xyz, 1.0)).xyz;
	float d = max(-c.z, 0.05);
	vec2 s = c.xy / d;
	// the near fade by the object's nearest point, so it goes before the lens reaches it
	float amt = 1.0 - smoothstep(jv_clear_cfg.x, jv_clear_cfg.y, -c.z - obj.w);
	amt = max(amt, jv_clear_hole(s, d, obj.w, jv_clear_a));
	amt = max(amt, jv_clear_hole(s, d, obj.w, jv_clear_b));
	return jv_clear_dither(amt, frag);
}
