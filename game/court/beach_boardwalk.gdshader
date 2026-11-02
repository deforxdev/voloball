// THE BOARDWALK DECK (beach_town.gd, Owen: "the boardwalk looks pretty terrible"):
// weathered planks laid ACROSS the walkway (they run along x, one every plank_w
// metres of z), dark gaps between them, each plank its own shade and its own grain
// streaks, ends staggered. The box's sides read as the deck's dark edge board.
shader_type spatial;
render_mode unshaded, cull_back;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

uniform vec3 wood : source_color = vec3(0.80, 0.66, 0.50);
uniform vec3 wood_alt : source_color = vec3(0.70, 0.56, 0.42);
uniform vec3 gap : source_color = vec3(0.30, 0.22, 0.16);
uniform vec3 edge : source_color = vec3(0.52, 0.40, 0.29);
uniform float plank_w = 0.24;      // metres of z per plank
uniform float plank_len = 2.4;     // metres along x before a butt joint

varying vec3 wpos;
varying vec3 wnrm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void fragment() {
	if (wnrm.y < 0.5) {
		ALBEDO = jv_out(jv_in(edge));
	} else {
		float row = floor(wpos.z / plank_w);
		float fz = fract(wpos.z / plank_w);
		// staggered butt joints along each plank
		float along = wpos.x / plank_len + hash(vec2(row, 3.0));
		float seg = floor(along);
		float fx = fract(along);
		float h = hash(vec2(row, seg));
		vec3 c = mix(jv_in(wood), jv_in(wood_alt), h);
		// grain: a few long streaks across the plank's width
		float grain = sin((fz + h) * 37.0 + sin(wpos.x * 1.7 + h * 9.0) * 1.5);
		c *= 0.95 + 0.05 * grain;
		float fwz = fwidth(fz) * 1.5 + 1e-4;
		float fwx = fwidth(fx) * 1.5 + 1e-4;
		float gz = 1.0 - smoothstep(0.0, 0.06 + fwz, min(fz, 1.0 - fz));
		float gx = 1.0 - smoothstep(0.0, 0.012 + fwx, min(fx, 1.0 - fx));
		c = mix(c, jv_in(gap), max(gz, gx * 0.8));
		ALBEDO = jv_out(c);
	}
}
