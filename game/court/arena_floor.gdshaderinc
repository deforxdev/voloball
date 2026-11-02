// GLOSSY ARENA FLOOR (fake, no reflection probe): a polished sports floor shows
// each light overhead as a soft streak on the boards. A true mirror is wrong
// here: lamps 26 m up reflect a few metres from the camera, under lights the
// player can't see (Owen: "the light placement seems off"). So, art-directed
// like lights on a wet road: each lamp's streak starts on the floor right under
// it and stretches toward the camera, so it sits under the rig you're looking at
// and swings round as the camera moves. Set per stage by Stage.apply_sun_windows
// from the stage's "floor_gloss" entry; strength 0 (every other stage) switches
// it off. World metres.
//   jv_rig_a  x = streak length, y = the side rows' |x|, z = their half run
//             along z, w = strength
//   jv_rig_b  x = the end rows' |z|, y = their half run along x, z = lamp spacing
//             in the side rows, w = lamp spacing in the end rows
global uniform vec4 jv_rig_a;
global uniform vec4 jv_rig_b;

// one lamp's streak at floor point p (xz), the camera standing over cam
float _jv_streak(vec2 p, vec2 cam, vec2 lamp) {
	vec2 to_cam = cam - lamp;
	float dl = length(to_cam);
	if (dl < 0.01) {
		return 0.0;
	}
	vec2 d = to_cam / dl;
	vec2 q = p - lamp;
	float along = dot(q, d);
	float across = dot(q, vec2(-d.y, d.x));
	float w = 0.32 + max(along, 0.0) * 0.07;   // widens toward the viewer (broad, soft)
	float body = smoothstep(-0.5, 0.8, along) * exp(-max(along, 0.0) / jv_rig_a.x)
		* (1.0 - smoothstep(dl * 0.7, dl, along));   // never reaches the camera's feet
	return body * exp(-across * across / (w * w));
}

// a row of lamps at origin + axis * k * step (|k * step| <= half_run): only the
// lamps whose streak can pass through p, found where the line from the camera
// through p meets the row
float _jv_row(vec2 p, vec2 cam, vec2 origin, vec2 axis, float step, float half_run) {
	vec2 r = p - cam;
	float den = r.x * axis.y - r.y * axis.x;
	if (abs(den) < 0.0001) {
		return 0.0;
	}
	vec2 oc = origin - cam;
	float u = (oc.x * axis.y - oc.y * axis.x) / den;   // how far along cam -> p the row is
	if (u < 0.9) {
		return 0.0;   // the row is behind the camera, or p is past it
	}
	float s = (oc.x * r.y - oc.y * r.x) / den;
	float n = floor(half_run / step + 0.01);
	float k = clamp(floor(s / step + 0.5), -n, n);
	float g = 0.0;
	for (float i = -1.0; i <= 1.0; i += 1.0) {
		float kk = k + i;
		if (abs(kk) <= n) {
			g += _jv_streak(p, cam, origin + axis * kk * step);
		}
	}
	return g;
}

// added brightness at floor point p seen from cam_pos (view_dir = p -> camera)
float jv_rig_glow(vec3 p, vec3 view_dir, vec3 cam_pos) {
	if (jv_rig_a.w <= 0.0) {
		return 0.0;
	}
	vec2 cam = cam_pos.xz;
	vec2 q = p.xz;
	float g = 0.0;
	g += _jv_row(q, cam, vec2(jv_rig_a.y, 0.0), vec2(0.0, 1.0), jv_rig_b.z, jv_rig_a.z);
	g += _jv_row(q, cam, vec2(-jv_rig_a.y, 0.0), vec2(0.0, 1.0), jv_rig_b.z, jv_rig_a.z);
	g += _jv_row(q, cam, vec2(0.0, jv_rig_b.x), vec2(1.0, 0.0), jv_rig_b.w, jv_rig_b.y);
	g += _jv_row(q, cam, vec2(0.0, -jv_rig_b.x), vec2(1.0, 0.0), jv_rig_b.w, jv_rig_b.y);
	// stronger the lower the camera looks across the floor (a gloss is a grazing thing)
	return g * jv_rig_a.w * mix(0.45, 1.0, pow(1.0 - clamp(view_dir.y, 0.0, 1.0), 2.0));
}
