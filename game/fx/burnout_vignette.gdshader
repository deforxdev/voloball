shader_type canvas_item;

// BURNOUT: a soft red vignette closing in while the local player is burnt out
// (stamina locked). `amount` fades it in and out, `pulse` (0..1) swells it on
// each beat. ROUND: the falloff is radial from the centre of whatever it covers
// (the full screen, or one split view). The edge WOBBLES with a few sine waves
// around the angle -- no grid noise, which showed straight seams and triangles
// at the edges (Owen 2026-10-07). Integer wave counts keep it seamless at +-PI.

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform float pulse : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 c = (UV - 0.5) * 2.0;           // 0 centre, 1 mid-edge, ~1.41 corner
	float r = length(c);
	float a = atan(c.y, c.x);
	float wob = sin(a * 5.0 + TIME * 0.6) * 0.5
		+ sin(a * 9.0 - TIME * 0.9) * 0.3
		+ sin(a * 17.0 + TIME * 1.4) * 0.2;   // -1..1, smooth all the way round
	float inner = 0.84 - 0.012 * pulse + wob * 0.04;   // a breath, not a throb
	float v = smoothstep(inner, inner + 0.5, r);
	// a muted red, a touch deeper toward the very edge
	vec3 col = mix(vec3(0.62, 0.08, 0.10), vec3(0.50, 0.03, 0.06), smoothstep(inner + 0.2, inner + 0.6, r));
	COLOR = vec4(col, v * amount * (0.5 + 0.03 * pulse));
}
