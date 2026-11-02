shader_type spatial;
render_mode unshaded, cull_disabled;

// THE NET'S SHADOW (Owen 2026-10-14: real net and pole shadows on the high and
// medium shadows settings). The net itself draws with ALPHA (the aim cutout), and
// see-through surfaces cast nothing, so ShadowSun gives each net a twin that is
// only ever drawn into the shadow map (SHADOW_CASTING_SETTING_SHADOWS_ONLY): the
// same tape bands and the same cord grid as game/court/net.gdshader, solid.
// ShadowSun copies `grid` from the real net (the court's width changes it).

uniform vec2 grid = vec2(46.0, 7.0);
uniform float tape_top = 0.06;
uniform float tape_bottom = 0.04;
uniform float tape_side = 0.006;
uniform float side_inset = 0.0213;
uniform float aspect = 9.0;

void fragment() {
	float d_top = tape_top - UV.y;
	float d_bot = UV.y - (1.0 - tape_bottom);
	float lx = UV.x - side_inset;
	float rx = (1.0 - side_inset) - UV.x;
	float d_left = min(lx, tape_side - lx) * aspect;
	float d_right = min(rx, tape_side - rx) * aspect;
	bool in_tape = max(max(d_top, d_bot), max(d_left, d_right)) > 0.0;
	if (!in_tape) {
		vec2 cell = fract(UV * grid);
		if (cell.x > 0.10 && cell.y > 0.14) {
			discard;
		}
	}
	ALBEDO = vec3(0.0);
}
