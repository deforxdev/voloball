// THE CROWD'S SHARED BODY: uniforms, varyings and the billboard vertex(), used by
// crowd.gdshader (the fans) and crowd_glow.gdshader (the glow sticks' additive
// glare, a next_pass on the same MultiMesh). The glare pass defines
// CROWD_GLOW_PASS before including this: its quads widen so a glare near the
// fan's edge isn't cut off, and fans with no stick collapse to nothing.
uniform sampler2DArray fans : filter_linear_mipmap, source_color;
uniform float foot_lift = 1.0;      // half the quad height: lifts feet to the seat
uniform float bob_amp = 0.02;
uniform float bob_speed = 1.6;
// reactions (driven by CrowdField each frame)
uniform float cheer_elapsed = 999.0;
uniform float cheer_intensity = 0.0;
uniform float shock_elapsed = 999.0;
uniform float shock_intensity = 0.0;
uniform float react_delay = 0.22;   // slowest fan's reaction time (s); fastest ~0.04
uniform float hop_rate = 2.4;       // bounces per second (each fan +/- ~30%)
uniform float hop_height = 0.55;
uniform float cheer_dur = 2.2;      // how long a FULL cheer keeps them bouncing (s)
uniform float shake_amp = 0.13;     // metres of side-to-side jitter on a gasp
uniform float shake_dur = 1.3;
// SHADING (depth + mood): tint multiplies every fan (darken/cool the crowd to sit
// in a moody arena); shade_var darkens each fan a random amount for variation so
// they don't read as one flat sheet; depth_dim darkens the UPPER rows (world Y) so
// the stands recede into shadow instead of staying uniformly bright.
uniform vec3 tint : source_color = vec3(1.0);
uniform float shade_var = 0.0;
uniform float depth_dim = 0.0;
uniform float depth_hi = 30.0;
// DISTANCE HAZE: fade far fans toward haze_color by camera distance, so the crowd
// recedes from court to back rows (atmospheric depth) instead of one crisp wall.
uniform vec3 haze_color : source_color = vec3(0.83, 0.87, 0.93);
uniform float haze_start = 12.0;   // stands sit ~15-50m from the play camera, so the
uniform float haze_end = 48.0;     // haze must ramp across THAT range, not 25-90
uniform float haze_amt : hint_range(0.0, 1.0) = 0.0;
// MUTE: the baked portraits are bright + saturated + high-contrast, so a packed
// crowd reads as a field of shiny distracting speckles. desat pulls colour out and
// crowd_contrast (<1) softens the bright/dark spread, so it settles into a calm mass.
uniform float desat : hint_range(0.0, 1.0) = 0.0;
uniform float crowd_contrast : hint_range(0.5, 1.5) = 1.0;
// FAR MUTE: fans farther from the camera lose extra saturation and contrast, so
// the back of the stands recedes behind the action (depth, not removal).
uniform float far_start = 14.0;
uniform float far_end = 40.0;
uniform float far_desat : hint_range(0.0, 1.0) = 0.0;
uniform float far_contrast : hint_range(0.0, 1.0) = 0.0;   // how much contrast drops

// GLOW STICKS (Owen 2026-10-14, ref: a VNL crowd waving lights in a dark bowl):
// this share of fans holds up a small glowing stick that sways on its own beat.
// Drawn inside the fan's own quad, so it hops and sways with them; full-bright,
// never tinted or hazed with the crowd, so it glows in a lights-down bowl.
uniform float glow_sticks : hint_range(0.0, 1.0) = 0.0;
uniform float glow_energy = 1.5;
// the crowd's own clock (CrowdField advances it): stops when the game pauses,
// unlike TIME, so the idle bob and the glow sticks freeze with everything else
uniform float crowd_time = 0.0;

varying flat float layer;
varying flat vec3 vrand;
varying vec2 uv;
varying flat float vshade;
varying flat float vhaze;
varying flat float vfar;
varying flat float vsun;

// THE GLOW STICK (Owen 2026-10-14): held in the fan's floating hand (the baked
// portraits put the hands at 14% / 86% across, 72% down), standing up from it
// and leaning in toward the head, swaying on the fan's own beat. Worked in fan
// heights (the quad is FAN_ASPECT as wide as it is tall) so it never squashes.
const float FAN_ASPECT = 288.0 / 560.0;
const float STICK_LEN = 0.24;
const float STICK_HALF = 0.013;

bool jv_has_stick(vec3 r) {
	return glow_sticks > 0.0 && fract(r.x * 7.31 + r.z * 3.7) < glow_sticks;
}

// saturated primaries (Owen: "more saturated primary colors")
vec3 jv_stick_color(vec3 r) {
	float pick = fract(r.y * 13.7 + r.z * 5.1);
	return pick < 0.3 ? vec3(1.0, 0.05, 0.05)
		: (pick < 0.6 ? vec3(0.05, 0.3, 1.0)
		: (pick < 0.85 ? vec3(1.0, 0.85, 0.0) : vec3(0.05, 1.0, 0.15)));
}

// distance (in fan heights) from quad point p to the stick
float jv_stick_dist(vec2 p, vec3 r) {
	float side = r.z < 0.5 ? -1.0 : 1.0;
	vec2 hand = vec2(0.5 + side * 0.36, 0.72);
	float a = -side * 0.2 + sin(crowd_time * (2.2 + 1.6 * r.y) + r.x * 6.2831) * 0.35;
	vec2 dir = vec2(sin(a), -cos(a));
	vec2 d = (p - hand) * vec2(FAN_ASPECT, 1.0);
	float t = clamp(dot(d, dir), 0.0, STICK_LEN);
	return length(d - dir * t);
}

#ifdef CROWD_GLOW_PASS
const float GLOW_WIDEN = 1.6;   // the glare quad is this much bigger than the fan
#endif

void vertex() {
	vec3 wpos = MODEL_MATRIX[3].xyz;               // this instance's seat point
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	vec3 look = normalize(vec3(cam.x - wpos.x, 0.0, cam.z - wpos.z));
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), look));
	float bob = sin(crowd_time * bob_speed + INSTANCE_CUSTOM.y * 6.2831) * bob_amp;

	float r1 = INSTANCE_CUSTOM.y;
	float r2 = INSTANCE_CUSTOM.z;
	float r3 = INSTANCE_CUSTOM.w;
	float hop = 0.0;
	float sway = 0.0;
	// CHEER: excited individual bouncing. only some fans get up for a small moment.
	if (cheer_intensity > 0.001 && r2 < clamp((cheer_intensity - 0.15) * 2.2, 0.0, 1.0)) {
		float lt = cheer_elapsed - (0.04 + r3 * react_delay);
		float dur = cheer_dur * mix(0.6, 1.0, cheer_intensity) * (0.75 + 0.5 * r1);
		if (lt > 0.0 && lt < dur) {
			float rate = hop_rate * (0.7 + 0.6 * r2);
			// abs(sin) from 0: every bounce starts and lands on the seat
			float bounce = abs(sin(lt * 3.14159 * rate));
			float env = 1.0 - smoothstep(dur * 0.55, dur, lt);
			float h = hop_height * (0.6 + 0.7 * r3) * mix(0.55, 1.0, cheer_intensity);
			hop = bounce * h * env;
			sway = sin(lt * 3.14159 * rate * 0.5 + r1 * 6.2831) * 0.045 * env
				* cheer_intensity;
		}
	}
	// SHOCK: a jolt and a quick shake that settles (the gasp), no jumping.
	if (shock_intensity > 0.001 && r3 < clamp(shock_intensity * 1.1, 0.0, 1.0)) {
		float lt = shock_elapsed - (0.02 + r2 * react_delay * 0.5);
		float dur = shake_dur * (0.8 + 0.4 * r1);
		if (lt > 0.0 && lt < dur) {
			float env = exp(-lt * 4.0 / dur);
			sway += sin(lt * (34.0 + 10.0 * r2) + r1 * 6.2831) * shake_amp
				* env * shock_intensity;
			hop += 0.16 * exp(-lt * 7.0) * shock_intensity;   // the jolt
		}
	}

	// QuadMesh is centred in XY; lift by foot_lift so the fan's feet sit at wpos
	vec2 qv = VERTEX.xy;
	uv = UV;
#ifdef CROWD_GLOW_PASS
	// grow round the fan's centre so the glare has room, and sit a hair toward
	// the camera so the fan's own depth never hides it; no stick = no quad
	qv *= GLOW_WIDEN;
	uv = (UV - 0.5) * GLOW_WIDEN + 0.5;
	if (!jv_has_stick(INSTANCE_CUSTOM.yzw)) {
		qv = vec2(0.0);
	}
#endif
	vec3 world = wpos
		+ right * (qv.x + sway)
		+ vec3(0.0, 1.0, 0.0) * (qv.y + foot_lift + bob + hop);
#ifdef CROWD_GLOW_PASS
	world += look * 0.08;
#endif
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
	layer = INSTANCE_CUSTOM.x;
	vrand = INSTANCE_CUSTOM.yzw;
	// per-fan brightness: a random dim (reusing the bob-phase random) + a fade for
	// the upper rows, so the crowd has variation and depth instead of one flat tone.
	float vary = 1.0 - shade_var * INSTANCE_CUSTOM.y;
	float depth = 1.0 - depth_dim * clamp(wpos.y / max(depth_hi, 0.01), 0.0, 1.0);
	vshade = vary * depth;
	float cd = distance(cam, wpos);
	vhaze = haze_amt * smoothstep(haze_start, haze_end, cd);
	vfar = smoothstep(far_start, far_end, cd);
	// the skylight sun on this fan's seat
	vsun = jv_sun_light(wpos + vec3(0.0, 0.8, 0.0), vec3(0.0, 1.0, 0.0));
}
