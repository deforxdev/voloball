// BAM SWIRL: a single spiral ribbon that DRAWS ITSELF UPWARD from the floor as
// the jumper rises, following them up, then dissolves from the bottom so the
// coil wipes away shortly after -- the Haikyuu updraft, revealed over the jump
// rather than dumped all at once. drawn on an open cone shell so the coil wraps
// round and reads from any angle. additive so it glows like anime wind.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec4 tint : source_color = vec4(0.85, 0.95, 1.0, 0.95);
uniform float coils = 5.0;        // how many times the spiral wraps up the height
uniform float band = 0.17;        // ribbon thickness (fraction of a wrap)
uniform float spin = 0.5;         // slow rotation of the whole coil
uniform float rim_power = 1.5;    // rim emphasis (shell of air, not a solid tube)
uniform float body_alpha : hint_range(0.0, 1.0) = 0.5;
uniform float reveal_top = 0.55;  // progress at which the reveal reaches the top
uniform float tail_delay = 0.35;  // progress at which the bottom starts dissolving up
uniform float progress : hint_range(0.0, 1.0) = 0.0;   // 0..1 life of the effect

varying float vh;                 // 0 at the base, 1 at the top

void vertex() {
	vh = VERTEX.y + 0.5;          // CylinderMesh is centred (-0.5..0.5)
}

void fragment() {
	// one coil ribbon: a helix that wraps `coils` times up the shell and turns
	// slowly. the ribbon lives where the spiral phase crosses zero.
	float ph = fract(UV.x + vh * coils - TIME * spin);
	float edge = min(ph, 1.0 - ph);
	float ribbon = smoothstep(band, band * 0.35, edge);

	// the REVEAL: a head climbs from the floor to the top over 0..reveal_top so the
	// coil draws upward with the jump; a tail then chases it up (from tail_delay to
	// the end) so the spiral wipes away from the bottom -- draw up, then dissolve.
	float soft = 0.10;
	float head = clamp(progress / reveal_top, 0.0, 1.0);
	float tail = clamp((progress - tail_delay) / (1.0 - tail_delay), 0.0, 1.0);
	float below_head = 1.0 - smoothstep(head, head + soft, vh);
	float above_tail = smoothstep(tail - soft, tail, vh);
	float window = below_head * above_tail;

	// rim: strongest on the silhouette so it reads as a shell of swirling air.
	float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), rim_power);

	// OVERALL LIFE FADE: ease the whole gust IN at the start and OUT at the end so
	// it doesn't pop on or snap off (user: it appeared/ended abruptly). the coil
	// still draws up + wipes via `window`; this just softens the envelope, and it
	// pairs with the node scaling outward so the wind reads as billowing + dissipating.
	float life_fade = smoothstep(0.0, 0.12, progress)
		* (1.0 - smoothstep(0.68, 1.0, progress));

	float a = ribbon * window * mix(body_alpha, 1.0, rim);
	ALBEDO = jv_out(jv_in(tint.rgb));
	ALPHA = a * tint.a * life_fade;
}
