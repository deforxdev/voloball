// BEACH PEOPLE: camera-facing billboards in one MultiMesh (see beach_crowd.gd /
// beach_crowd_field.gd). The quad turns to the camera, but the sprite it shows is
// the person baked from the angle the camera sees them at given the way they FACE
// (4 views: front, side, back, side), so someone facing the sea shows you
// their back. Walk into one and they topple over away from you, lie flat a moment
// and get back up. Runs on the crowd's own clock, so it all stops on pause.
// Atlas (beach_crowd_bake.gd): each person is a block of poses * angles cells in a
// row; per_row people side by side, then the next row of people.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha, fog_disabled;
// Compatibility parity: source colours in via jv_in, final colour out via jv_out (compat_color.gdshaderinc)
#include "res://game/fx/compat_color.gdshaderinc"
// scenery between the eye and your player cuts away (view_clear.gdshaderinc)
#include "res://game/fx/view_clear.gdshaderinc"
#include "res://game/court/beach_crowd_common.gdshaderinc"

uniform sampler2D atlas : filter_linear_mipmap, source_color;
uniform vec2 grid = vec2(320.0, 32.0); // atlas cells across, down
uniform float angles = 4.0;
uniform float poses = 5.0;
uniform float per_row = 16.0;
uniform float foot_lift = 1.0;
uniform float bob_amp = 0.02;
uniform float bob_speed = 1.0;
uniform float walk_fps = 5.0;          // jog frames a second
uniform vec3 haze_color : source_color = vec3(0.72, 0.82, 0.92);
uniform float haze_start = 40.0;
uniform float haze_end = 150.0;
uniform float haze_amt : hint_range(0.0, 1.0) = 0.0;
uniform float desat : hint_range(0.0, 1.0) = 0.0;

varying flat float vchar;
varying flat float vcol;
varying vec2 uv;
varying flat float vhaze;

void vertex() {
	vec3 origin = crowd_origin(MODEL_MATRIX, INSTANCE_CUSTOM);
	float kind = INSTANCE_CUSTOM.w;
	float face = INSTANCE_CUSTOM.z * 6.2831853;
	float down = crowd_down(MODEL_MATRIX);
	float block = kind < 1.5 ? kind : 2.0;
	float bob = sin(crowd_time * bob_speed + INSTANCE_CUSTOM.y * 6.2831) * bob_amp;
	if (kind > 1.5) {
		// a walker steps through the jog frames (standing still while knocked down)
		block = down > 0.0 ? 0.0 : 2.0 + floor(mod(crowd_time * walk_fps + INSTANCE_CUSTOM.y * 3.0, 3.0));
		bob = 0.0;
	} else if (kind > 0.5) {
		bob *= 0.4;  // a sitter barely moves
	}
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	// Y-axis billboard: faces the camera, stays upright, never edge-on
	vec3 look = normalize(vec3(cam.x - origin.x, 0.0, cam.z - origin.z));
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), look));
	vec3 off = right * VERTEX.x + vec3(0.0, 1.0, 0.0) * (VERTEX.y + foot_lift + bob * (1.0 - down));
	// KNOCKED: tip over about the feet, away from whoever pushed them
	if (down > 0.0) {
		vec3 push = normalize(vec3(MODEL_MATRIX[2].x, 0.0, MODEL_MATRIX[2].z) + vec3(1e-4, 0.0, 0.0));
		vec3 axis = normalize(cross(vec3(0.0, 1.0, 0.0), push));
		float a = -down * 1.45;
		// Rodrigues: rotate off about axis by a
		off = off * cos(a) + cross(axis, off) * sin(a) + axis * dot(axis, off) * (1.0 - cos(a));
		off.y = max(off.y, 0.03);   // never through the sand
	}
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(origin + off, 1.0);
	// which baked view = how this person's facing relates to where the camera is
	vec2 tocam = normalize(cam.xz - origin.xz);
	float cam_az = atan(tocam.x, tocam.y);
	float step = 6.2831853 / angles;
	float ai = floor(mod((face - cam_az) / step + 0.5, angles));
	float person = floor(INSTANCE_CUSTOM.x + 0.5);
	vcol = mod(person, per_row) * poses * angles + block * angles + ai;
	vchar = floor(person / per_row);
	uv = UV;
	vhaze = haze_amt * smoothstep(haze_start, haze_end, distance(cam, origin));
}

void fragment() {
	// VIEW_CLEAR_OFF if (jv_view_cleared(VERTEX, INV_VIEW_MATRIX, FRAGCOORD.xy)) { discard; }   // see the player through it
	vec2 cell = vec2(1.0) / grid;
	vec2 tuv = (vec2(vcol, floor(vchar)) + uv) * cell;
	vec4 t = texture(atlas, tuv);
	vec3 c = jv_in(t.rgb);
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(luma), desat);
	ALBEDO = jv_out(mix(c, jv_in(haze_color), vhaze));
	ALPHA = t.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
