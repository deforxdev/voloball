// THE BEACH TOWN'S GROUND (beach_town.gd puts it on TownGround/Pavement, Owen: "the
// city just being a big asphalt texture looks pretty bad"). One plane, one draw:
//   paved promenade everywhere -- warm stone pavers on a running-bond grid with a
//     little per-stone tint, so it reads as a sidewalk and not a carpet
//   ROADS inside the rectangles in `roads` (the strand + the cross streets, read
//     off the old road slabs): asphalt, a pale curb along each edge, a dashed
//     centre line along the road's length, zebra crossings where roads meet
// Unshaded, like every floor here (the stage fakes its lighting).
shader_type spatial;
render_mode unshaded, cull_back;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"

const int MAX_ROADS = 12;
uniform vec4 roads[MAX_ROADS];       // xz min, xz max of each road
uniform int road_count = 0;
uniform vec3 paver : source_color = vec3(0.86, 0.80, 0.70);
uniform vec3 paver_alt : source_color = vec3(0.80, 0.72, 0.62);
uniform vec3 grout : source_color = vec3(0.62, 0.57, 0.50);
uniform float paver_size = 0.9;      // metres
uniform vec3 asphalt : source_color = vec3(0.30, 0.31, 0.34);
uniform vec3 curb : source_color = vec3(0.80, 0.80, 0.78);
uniform vec3 paint : source_color = vec3(0.96, 0.92, 0.70);
uniform vec3 zebra : source_color = vec3(0.94, 0.94, 0.92);
uniform float curb_w = 0.35;
uniform float brightness = 1.0;

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

// how much of a line (0..1) sits at coordinate t, width w in metres, antialiased
float line(float t, float w) {
	float fw = fwidth(t) * 1.2 + 1e-4;
	return 1.0 - smoothstep(w * 0.5 - fw, w * 0.5 + fw, abs(t));
}

void fragment() {
	vec2 p = wpos.xz;
	// --- the pavers (running bond: every other row shifted half a stone) ---
	vec2 g = p / paver_size;
	g.x += mod(floor(g.y), 2.0) * 0.5;
	vec2 cell = floor(g);
	vec2 f = fract(g) - 0.5;
	float joint = smoothstep(0.44, 0.48, max(abs(f.x), abs(f.y)));
	vec3 stone = mix(jv_in(paver), jv_in(paver_alt), hash(cell) * 0.8);
	vec3 col = mix(stone, jv_in(grout), joint * 0.85);
	// --- the roads ---
	for (int i = 0; i < road_count; i++) {
		vec4 r = roads[i];
		if (p.x < r.x || p.x > r.z || p.y < r.y || p.y > r.w) {
			continue;
		}
		vec2 size = r.zw - r.xy;
		bool along_z = size.y > size.x;
		vec2 c = (r.xy + r.zw) * 0.5;
		float across = along_z ? p.x - c.x : p.y - c.y;   // from the centre line
		float along = along_z ? p.y : p.x;
		float half_w = (along_z ? size.x : size.y) * 0.5;
		vec3 road = jv_in(asphalt) * (0.94 + 0.12 * hash(floor(p * 3.0)));
		// a dashed centre line: 3 m paint, 3 m gap
		float dash = step(0.5, fract(along / 6.0));
		road = mix(road, jv_in(paint), line(across, 0.14) * dash);
		// the curbs
		road = mix(road, jv_in(curb), smoothstep(half_w - curb_w - 0.03, half_w - curb_w + 0.03, abs(across)));
		col = road;
		// zebra crossings: where this road runs through ANOTHER one's edge strip
		for (int j = 0; j < road_count; j++) {
			if (j == i) {
				continue;
			}
			vec4 o = roads[j];
			vec2 osize = o.zw - o.xy;
			bool o_along_z = osize.y > osize.x;
			if (o_along_z == along_z) {
				continue;
			}
			// a 3 m band just outside the other road, on this one
			float d = along_z ? max(o.y - p.y, p.y - o.w) : max(o.x - p.x, p.x - o.z);
			if (d > 0.4 && d < 3.4 && abs(across) < half_w - curb_w) {
				float stripe = step(0.5, fract(across / 0.9));
				col = mix(col, jv_in(zebra), stripe);
			}
		}
		break;
	}
	ALBEDO = jv_out(col * brightness);
}
