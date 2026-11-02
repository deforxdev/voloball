// ARENA LIGHT ON BODIES (fake, no lights). Owen 2026-10-14: in the dark arena
// with the rigs blazing overhead "everything is still lit the same". Players and
// the ball take three cues from the stage (Stage.apply_sun_windows, the stage's
// "body_light" entry; all 0 = every other stage, no change):
//   * overhead: tops of heads/shoulders catch the rigs, undersides fall off
//   * a hard cel RIM on the upper silhouette, the rig light wrapping round them
//   * the court POOL: full light inside the lit box round the court, dimming
//     out toward the dark boards, so walking off court reads as leaving the light
// Only bodies standing in the stage world (world_lit = 1) take it; locker and
// portrait previews stay untouched. Works on a linear colour (after jv_in).
//   jv_body_light  x = overhead amount, y = rim strength, z = dim outside the
//                  pool (0..1), w = rim width (0 = thin, 1 = wide)
//   jv_body_pool   x, y = the pool's half size along world x and z (metres),
//                  z = how far the light takes to fall off past it
global uniform vec4 jv_body_light;
global uniform vec4 jv_body_pool;

// c: the lit body colour (linear). n, v, vtx: view-space normal, view vector and
// position (NORMAL, VIEW, VERTEX in fragment()). inv_view: INV_VIEW_MATRIX.
vec3 jv_arena_light(vec3 c, vec3 n, vec3 v, vec3 vtx, mat4 inv_view, float on) {
	if (on <= 0.0 || jv_body_light.x + jv_body_light.y + jv_body_light.z <= 0.0) {
		return c;
	}
	vec3 nw = normalize(mat3(inv_view) * n);
	vec3 pw = (inv_view * vec4(vtx, 1.0)).xyz;
	vec2 past = max(abs(pw.xz) - jv_body_pool.xy, 0.0);
	float out_pool = clamp(length(past) / max(jv_body_pool.z, 0.01), 0.0, 1.0);
	float pool = 1.0 - jv_body_light.z * smoothstep(0.0, 1.0, out_pool);
	// overhead: a cel band -- anything facing down or away below the shoulders
	// falls into shadow -- plus a soft lift toward the tops of heads and shoulders
	float up = nw.y * 0.5 + 0.5;
	float under = 1.0 - smoothstep(-0.3, -0.2, nw.y);
	c *= mix(1.0, mix(0.92, 1.15, up) * (1.0 - 0.45 * under), jv_body_light.x);
	c *= pool;
	// cel rim: a hard band on the silhouette, only where it faces up toward the rigs
	float edge = 1.0 - clamp(dot(n, normalize(v)), 0.0, 1.0);
	float top = smoothstep(-0.05, 0.35, nw.y);
	float cut = mix(0.78, 0.6, jv_body_light.w);
	float rim = smoothstep(cut - 0.02, cut + 0.02, edge * mix(0.6, 1.0, top)) * top;
	c += vec3(rim * jv_body_light.y * pool);
	return c;
}
