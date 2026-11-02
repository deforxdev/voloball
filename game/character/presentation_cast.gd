class_name PresentationCast
extends RefCounted



const POOLS: = {
	"lead": [["spike", 0.0], ["spike", 0.01]], 
	"air": [["jump_rise", 0.2], ["jump_fall", 0.3], ["set_air", 0.35], 
		["block", 0.9], ["jump_fall", 0.5], ["block", 0.2]], 
	"mid": [["approach", 0.4], ["set", 0.5], ["jump_fall", 0.3], ["receive", 0.3], 
		["set_air", 0.4], ["approach", 0.3], ["strafe_fwd", 0.1]], 
	"ground": [["approach", 0.5], ["receive", 0.3], ["serve", 0.3], 
		["approach", 0.3], ["receive", 0.5], ["strafe_fwd", 0.1]], 
}
const KEY_POSES: = [["jump_rise", 0.45], ["jump_rise", 0.35], ["block", 0.9], 
	["set_air", 0.35], ["jump_fall", 0.3]]
const PORTRAIT_POSES: = [["approach", 0.4], ["receive", 0.3], ["strafe_fwd", 0.1], 
	["approach", 0.3], ["receive", 0.5]]
const BACK_POSES: = [["jump_fall", 0.3], ["approach", 0.4], 
	["strafe_fwd", 0.1], ["jump_fall", 0.5], ["approach", 0.3]]
const CLOTH_MOTION: = {
	"spike": [true, 0.5], "spike_L": [true, 0.5], "set_air": [true, 0.4], 
	"block": [true, 0.8], "block_hit": [true, 0.3], 
	"jump_rise": [true, 4.0], "jump_fall": [true, -2.5], 
}
const HAIR_MOTION: = {
	"spike": [2.0, 15.0], "spike_L": [55.0, -15.0], "set_air": [25.0, 0.0], 
	"block": [35.0, 0.0], "block_hit": [40.0, 10.0], 
	"jump_rise": [-12.0, 0.0], "jump_fall": [60.0, 6.0], 
	"approach": [25.0, 0.0], "receive": [15.0, 0.0], "strafe_fwd": [10.0, 30.0], 
}

static func pick_pose(zone: String, rng: RandomNumberGenerator, used: Array, 
		prev_hook: String) -> Array:
	var pool: Array = PORTRAIT_POSES if zone == "portrait" else (
		BACK_POSES if zone == "back" else (
		KEY_POSES if zone == "key" else POOLS.get(zone, POOLS["ground"])))
	var fresh: Array = []
	var fresh_any: Array = []
	for pose in pool:
		var key: = "%s %.2f" % [String(pose[0]), float(pose[1])]
		if key in used:
			continue
		fresh_any.append(pose)
		if String(pose[0]) != prev_hook:
			fresh.append(pose)
	var choices: Array = fresh if not fresh.is_empty() else (
		fresh_any if not fresh_any.is_empty() else pool)
	var picked: Array = choices[rng.randi() % choices.size()]
	used.append("%s %.2f" % [String(picked[0]), float(picked[1])])
	return picked



static func freeze_pose(pc: PresentationCharacter, hook: String, frame: float, 
		fallback_hook: = "idle") -> Dictionary:
	if pc.rig == null:
		return {}



	var candidates: Array[String] = [hook]
	if fallback_hook != "idle" and fallback_hook != hook:
		candidates.append(fallback_hook)
	for active in ["approach", "receive", "strafe_fwd", "serve", "set", 
			"jump_fall", "block", "spike"]:
		if active not in candidates:
			candidates.append(active)
	var got: = ""
	for candidate in candidates:
		var want: String = pc.rig.clip_name(candidate)
		if want == "":
			want = candidate
		got = pc.play_clip(want, true)
		if got != "":
			hook = candidate
			break
	if got == "":
		push_warning("Presentation character has no active portrait clip; tried %s" % [candidates])
		return {"hook": hook}
	pc.rig.seek_normalized(frame)
	var ap: AnimationPlayer = pc.rig.get("_anim")
	if ap == null or ap.current_animation == "":
		return {"hook": hook}
	ap.pause()
	return {"hook": hook, "ap": ap, "at": ap.current_animation_position}

static func settle_cloth(pc: PresentationCharacter, hook: String, lead: bool) -> void :
	if pc.rig == null:
		return
	var motion: Array = CLOTH_MOTION.get(hook, [false, 0.0])
	var airborne: bool = motion[0]
	var boost: = 1.0 if lead else 0.7
	for i in 4:
		pc.rig.drive_cloth(1.0, float(motion[1]), not airborne, boost, 
			false, false, 0.0)

static func settle_hair(pc: PresentationCharacter, hook: String, lead: bool) -> void :
	if pc.rig == null:
		return
	var motion: Array = HAIR_MOTION.get(hook, [0.0, 0.0])
	var strength: = 1.25 if lead else 1.0
	pc.rig.tail_still(float(motion[0]) * strength, 
		float(motion[1]) * strength)



static func depth_scale(view_h: float, fov: float, z: float) -> float:
	var dist: = view_h / (2.0 * tan(deg_to_rad(fov * 0.5)))
	return (dist - z) / dist

static func at_depth(point: Vector2, look: Vector2, view_h: float, 
		fov: float, z: float) -> Vector3:
	var k: = depth_scale(view_h, fov, z)
	return Vector3(look.x + (point.x - look.x) * k, 
		look.y + (point.y - look.y) * k, z)
