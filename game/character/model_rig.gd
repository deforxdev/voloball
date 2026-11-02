class_name ModelRig
extends Node3D














const MODEL_PATHS: = [
	"res://game/character/models/player_char.blend", 
	"res://game/character/models/player.glb", 
]
const TOON: = preload("res://game/fx/toon.gdshader")
const WII: = preload("res://game/fx/wii.gdshader")
const TOON_NUMBER: = preload("res://game/fx/toon_number.gdshader")

const TOON_HAIR: = preload("res://game/fx/toon_hair.gdshader")
const ACC_SPINNER: = preload("res://game/character/acc_spinner.gd")
const ACC_FLAPPER: = preload("res://game/character/acc_flapper.gd")
const BLEND: = 0.1





const BLEND_SNAP: = 0.0
const SNAP_ACTIONS: = ["spike", "spike_L", "spike_light", "spike_light_L", "dive", "dive_r", "dive_l", 
	"block", "block_hit", "block_hit_ot", "kick_r", "kick_l", "approach", "receive", "set", 
	"set_air", "land", "receive_l", "receive_r", "receive_back", "set_low", 
	"set_back", "set_back_air"]


const TARGET_HEIGHT: = 1.8


const HEIGHT_RANGE: = 0.06
const BLUSH_COLOR: = Color(0.96, 0.52, 0.52, 1.0)
const NUMBER_FONT: = "res://game/fonts/VarsityTeam-Bold.otf"
const HAIR_DIR: = "res://game/character/hair/%s.blend"













const TAIL_PREFIX: = "tail"








const JIGGLE_STIFF: = 3.0
const JIGGLE_DRAG: = 0.25
const JIGGLE_GRAVITY: = 2.0





const JIGGLE_MAX_ANGLE: = 1.2


const JIGGLE_TIP_STIFF: = 0.45





const JIGGLE_LOCKS_MIN: = 6
const JIGGLE_LOCK_ROOT_STIFF: = 4.0
const JIGGLE_LOCK_ROOT_ANGLE: = 0.45



const JIGGLE_SPRUNG_MIN_GRAV: = 0.15
const JIGGLE_SPRUNG_STIFF: = 2.2



const JIGGLE_SPIKE_STIFF: = 1.1
const JIGGLE_SPIKE_DRAG: = 0.12
const JIGGLE_SPIKE_GRAVITY: = 0.25



const JIGGLE_MASS_STIFF: = 5.0
const JIGGLE_MASS_DRAG: = 0.15
const JIGGLE_MASS_GRAVITY: = 0.1
const JIGGLE_MASS_MAX_ANGLE: = 0.1


const JIGGLE_SPIKE_MAX_ANGLE: = 0.9


const JIGGLE_HUG_MAX_ANGLE: = 0.06



const JIGGLE_HEAD_MARGIN: = 0.05




const JIGGLE_SAFE_CAPS: = false




const JIGGLE_SKIN_POINTS: = 8
const JIGGLE_SKIN_BUDGET: = 96
const JIGGLE_SKIN_SPACING: = 0.1









const HAIR_FIT_MARGIN: = 0.035
const HAIR_FIT_SPREAD: = 0.45
const HAIR_FIT_DEEP: = 0.25


const HOOD_TUCK_GAP: = 0.05

const HAT_SHELL: = 0.08


const HOOD_OPEN_SLACK: = 0.12

const JIGGLE_JOINT_R: = 0.2



const JIGGLE_HEAD_SHRINK: = 0.97
const JIGGLE_TORSO_R: = 0.38



const JIGGLE_TORSO_H: = 0.9
const JIGGLE_TORSO_AT: = 0.24





const JIGGLE_BODY_R: = 0.41
const JIGGLE_BODY_LO: = -0.6
const JIGGLE_BODY_HI: = 0.29
const JIGGLE_SHOULDER_R: = 0.17
const JIGGLE_SHOULDER_W: = 0.95
const JIGGLE_SHOULDER_AT: = 0.62


const JIGGLE_TELEPORT: = 1.2



const JIGGLE_CARRY: = 1.0
const JIGGLE_CARRY_MAX_V: = 16.0


const JIGGLE_CARRY_MAX_A: = 45.0

static var jiggle_carry_on: = true

static var still_settle_on: = true
var _carry_tick: = -1
var _carry_vy: = 0.0
var _carry_dv: = 0.0

const JIGGLE_STILL_FORCE: = 0.06



const JIGGLE_SETTLE_STEPS: = 60
const SHAPE_HEAVY: = "heavy"
const SHAPE_SLIM: = "slim"
const MODEL_YAW: = 0.0


const OUTLINE_WIDTH: = 0.026
const OUTLINE_COLOR: = Color(0.05, 0.05, 0.08)
var _left_handed: = false
var hold_frame: = false
var spike_light: = false
var jump_variant: = 0


const JUMP_RISE_TAKES: = ["jump_rise", "jump_rise2"]
var gait_fatigue: = 1.0

const ANIM_FPS: = 30.0
const SPIKE_STRIKE_FRAME: = 2.0
const CLIP_START_FRAME: = 1.0

const CLIP_ALIASES: = {
	"idle": ["idle"], 


	"igot_r": ["igot_r", "igot"], 
	"igot_l": ["igot_l", "igot"], 
	"run": ["run", "jog"], 



	"sprint": ["sprint", "run_fast", "sprint_loop", "run", "jog"], 
	"sprint_start": ["sprint_start", "sprint_begin", "run_start", "sprint", 
		"run", "jog"], 



	"sprint_left": ["sprint_left", "sprint_turn_l", "sprint_bank_l", "sprint", 
		"run", "jog"], 
	"sprint_right": ["sprint_right", "sprint_turn_r", "sprint_bank_r", "sprint", 
		"run", "jog"], 
	"sprint_stop": ["sprint_stop", "sprint_brake", "sprint_skid", "skid", 
		"stop", "sprint", "run"], 
	"jump_rise": ["jump_rise", "jump", "idle"], 
	"jump_fall": ["jump_fall", "fall", "idle"], 
	"charge": ["charge", "jump_charge", "crouch"], 



	"approach": ["approach", "spike_approach", "charge", "run"], 
	"dive": ["dive"], 


	"dive_burnout": ["dive_burnout", "dive_tired", "getup_front", "dive"], 


	"dive_r": ["dive_r", "dive_R", "dive_right", "dive"], 
	"dive_l": ["dive_l", "dive_L", "dive_left", "dive"], 
	"serve": ["serve", "serve_toss"], 
	"block": ["block"], 


	"block_hit": ["block_hit", "blockhit", "block_fall", "block", "jump_fall"], 


	"block_hit_ot": ["block_hit_ot", "blockhitout", "block_hit_out"], 


	"kick_r": ["kick_r", "kick_R", "kick_right", "receive", "recieve"], 
	"kick_l": ["kick_l", "kick_L", "kick_left", "receive", "recieve"], 
	"spike": ["spike", "attack", "hit"], 



	"spike_L": ["spike_L", "spike_l", "spike"], 


	"spike_light": ["spike_light", "spikelight", "spike_soft", "spike", "attack", "hit"], 
	"spike_light_L": ["spike_light_L", "spike_light_l", "spike_light", "spike_L", "spike"], 
	"jump_rise_L": ["jump_rise_L", "jump_rise_l", "jump_L", "jump_rise", "jump", "idle"], 


	"jump_rise2": ["jump_rise2", "jump_rise_2"], 
	"jump_rise2_L": ["jump_rise2_L", "jump_rise2_l", "jump_rise_2_L", "jump_rise_2_l", "jump_rise2"], 


	"set_air": ["set_air", "air_set", "jump_set", "jumpset", "set", "setting", 
		"overhand", "receive", "recieve"], 


	"getup_front": ["getup_front", "getup", "dive"], 
	"getup_back": ["getup_back", "getup", "dive"], 
	"strafe_left": ["strafe_left", "strafe_l", "shuffle_left", "run"], 
	"strafe_right": ["strafe_right", "strafe_r", "shuffle_right", "run"], 
	"run_back": ["run_back", "backpedal", "run"], 



	"strafe_fwd": ["strafe_fwd", "strafe_forward", "shuffle_forward", "run"], 




	"receive": ["receive", "recieve", "dig", "bump"], 




	"receive_l": ["recieve_l", "receive_l", "receive_L", "receive_left", "dig_l", "receive", "recieve"], 
	"receive_r": ["recieve_r", "receive_r", "receive_R", "receive_right", "dig_r", "receive", "recieve"], 
	"receive_back": ["recieve_back", "receive_back", "receive_behind", "dig_back", "receive", "recieve"], 




	"set": ["set", "setting", "overhand", "receive", "recieve"], 



	"set_back": ["backset", "set_back", "back_set", "setback", "set", "setting", 
		"overhand", "receive", "recieve"], 
	"set_back_air": ["backset_air", "set_back_air", "back_set_air", "backset", 
		"set_air", "air_set", "jump_set", "set", "setting"], 


	"set_low": ["set_low", "set_lo", "low_set", "set", "setting", "receive"], 

	"land": ["land", "landing"], 


	"stop": ["stop", "skid", "brake"], 



	"idle_alt": ["idle_alt", "idle"], 
}



func _jump_rise_take() -> String:
	var takes: Array = []
	for t in JUMP_RISE_TAKES:
		if _clip_map.has(t):
			takes.append(t)
	if takes.is_empty():
		return "jump_rise"
	return takes[jump_variant % takes.size()]

func has_action(name: String) -> bool:
	return _clip_map.has(name)




const LOCO_HOOKS: = ["run", "strafe_left", "strafe_right", "strafe_fwd", 
	"run_back", "sprint", "sprint_left", "sprint_right"]






func set_head_visible(on: bool) -> void :
	_scrub_shell_maps()
	if _face_root != null and is_instance_valid(_face_root):
		_face_root.visible = on
	if _hair_root != null and is_instance_valid(_hair_root):
		_hair_root.visible = on
	if _facial_root != null and is_instance_valid(_facial_root):
		_facial_root.visible = on


	for m in find_children("*", "MeshInstance3D", true, false):
		var mi: = m as MeshInstance3D
		if not String(mi.name).to_lower().contains("head"):
			continue
		mi.visible = on
		var shell: MeshInstance3D = _shells.get(mi)
		if shell != null and is_instance_valid(shell):
			shell.visible = on
		var aura: MeshInstance3D = _hl_shells.get(mi)
		if aura != null and is_instance_valid(aura) and not on:
			aura.visible = false






var _shell_lod_hidden: = false

func set_outline_lod(hidden: bool) -> void :
	if hidden == _shell_lod_hidden:
		return
	_shell_lod_hidden = hidden
	for mi in _shells:
		var s: MeshInstance3D = _shells[mi]
		if is_instance_valid(s) and is_instance_valid(mi):
			s.visible = not hidden and (mi as MeshInstance3D).visible

	_refresh_hair_outline()

func stride_phase() -> float:
	if _anim == null or _current == "":
		return -1.0
	var is_loco: = false
	for hook in LOCO_HOOKS:
		if _clip_map.get(hook, "") == _current:
			is_loco = true
			break
	if not is_loco:
		return -1.0
	var length: = _anim.current_animation_length
	if length <= 0.0:
		return -1.0
	return fposmod(_anim.current_animation_position, length) / length

func anim_normalized() -> float:



	if _anim == null or _anim.current_animation == "":
		return 0.0
	var length: = _anim.current_animation_length
	if length <= 0.0:
		return 0.0
	return clampf(_anim.current_animation_position / length, 0.0, 1.0)


const ACTION_LOOP: = {"charge": false, "dive": false, "serve": false, 
	"dive_burnout": true, 
	"getup_front": false, "getup_back": false, "receive": false, 
	"receive_l": false, "receive_r": false, "receive_back": false, "set_low": false, 
	"set": false, "land": false, "stop": false, "set_back": false, "set_back_air": false, 



	"idle_alt": true, 
	"strafe_left": true, "strafe_right": true, "run_back": true, 
	"strafe_fwd": true, 

	"sprint": true, "sprint_start": false, 
	"sprint_left": true, "sprint_right": true, "sprint_stop": false}







func clip_name(want: String) -> String:
	return _clip_map.get(want, "")




func action_length(name: String) -> float:
	if not _clip_map.has(name):
		return 0.0
	var anim: Animation = _anim.get_animation(_clip_map[name])
	return anim.length if anim != null else 0.0

const SLOT_ALIASES: = {
	"pants": "shorts", 
	"cleets": "shoes", 
	"cleats": "shoes", 
	"shoe": "shoes", 
	"sock": "socks", 
	"shirt": "jersey", 
	"body": "skin", 




	"jerseyaccent": "accent", 
	"pantsaccent": "pants_accent", 
	"kneepad": "kneepad", 
}

const HAND_BONES: = {"l": ["hand.l", "hand_l", "hand.L"], 
	"r": ["hand.r", "hand_r", "hand.R"]}

var hand_radius: = 0.0
var hand_rest: = Vector3.ZERO

var _anim: AnimationPlayer
var _mats: = {}





var _surface_slots: = {}
var _shells: = {}
var _outline_mat: Material = null





var _hl_mat: StandardMaterial3D = null
var _hl_shells: = {}
static var _invisible_shell: ShaderMaterial = null



var _pick_targets: = {}
const PICK_GROUPS: = {
	"head": CharacterConfig.HEAD_SHAPES, 
	"shorts": CharacterConfig.SHORTS_SHAPES, 
	"socks": CharacterConfig.SOCKS_SHAPES, 
	"shirt": CharacterConfig.SHIRT_SHAPES, 
}




const EAR_MESH_PREFIX: = "ear"
var _ear_names: Array[String] = []
var _ear_targets: Array = []


static var model_hook: = Callable()
static var _dev_hook_looked: = false
const DEV_EARS: = "res://game/dev/ear_keys_stand_in.gd"
var _fallback_mat: ShaderMaterial = null
var _current: = ""
var block_out: = false
var _last_want: = ""
const SPRINT_OUT_BLEND: = 0.3
var _clip_map: = {}
var _skel: Skeleton3D = null
var _bone: = {"l": -1, "r": -1}
var _bone_offset: = {"l": Vector3.ZERO, "r": Vector3.ZERO}
var _scene: Node3D = null
var _base_scale: = 1.0
var _shape_targets: Array = []








const CLOTH_KEYS: = ["shirt_lift", "shirt_flare", "shirt_drop", "shirt_billow_l", "shirt_billow_r"]



const PINNY_NUMBER_FRONT: = 1.5
const PINNY_NUMBER_BACK: = 2.5
var _cloth_targets: Array = []
var _cloth_on: = true
var _pinny_worn: = false

var _cloth: = [0.0, 0.0, 0.0, 0.0, 0.0]
var _cloth_was_air: = false
var _cloth_land: = 0.0
const CLOTH_ATTACK: = 0.05
const CLOTH_RELEASE: = 0.14
var _number_label: Label3D = null
var _number_vp: SubViewport = null
var _number_text: Label = null
var _number_mat: ShaderMaterial = null
var _face_root: Node3D = null
var _face_vp: SubViewport = null
var _face_canvas: Control = null
var _face_parts: Array = []
var _face_radius: = 0.65
var _head_mesh: ArrayMesh = null
var _head_centre: = Vector3.ZERO



var playback_scale: = 1.0







var _overlay: CalloutOverlay = null
var _callout_anim: Animation = null
var _callout_name: = ""
var _callout_t: = 0.0
var _callout_len: = 0.0
var _callout_inf: = 0.0
var _callout_playing: = false
var _mask_loco: PackedInt32Array = PackedInt32Array()
var _callout_loco_anim: Animation = null
var _leg_t: = 0.0
var _last_planar: = 0.0




const CALLOUT_LOCO_BONES: = ["spine", "spine1", 
	"heelik.l", "foot.l", "toe.l", "heelik.r", "foot.r", "toe.r", 
	"kneeik.l", "kneeik.r", "hip.l", "thigh.l", "calf.l", "hip.r", "thigh.r", "calf.r"]
const CALLOUT_FADE: = 0.1
var _hair_root: Node3D = null




var _hair_mats: Array = []
var _hair_defaults: Array = []
var _hair_yrange: = Vector2(0.0, 1.0)
var _hair_grad_active: = false
var _hair_style: = -1
var _hair_flipped: = false
var _hair_shell_meshes: Array = []
var _hair_outline_off: = false



var _hair_base_meshes: = {}
var _hair_tuck_key: = ""


var _facial_root: Node3D = null
var _facial_style: = -1
var _facial_mats: Array = []
var _facial_meshes: Array = []
var _facial_pivot: = Vector3.ZERO



const FACIAL_POS_RANGE: = Vector3(0.25, 0.3, 0.25)
const FACIAL_ROT_RANGE: = Vector3(25.0, 25.0, 25.0)
const FACIAL_SCALE: = Vector2(0.6, 1.6)


var _acc_roots: = {}
var _acc_ids: = {}
var _acc_flipped: = {}
var _acc_mats: = {}
var _acc_pivot: = {}
var _acc_fit: = {}
var _acc_lift: = {}

var _jiggles: Array = []
var _jiggle_reset: = true



var _acc_yrange: = {}
var _acc_grad_active: = false





var _acc_shell_meshes: = {}
var _acc_groups: = {}
var _prev_head_pos: = Vector3.ZERO
var _head_mount: BoneAttachment3D = null
var _head_bone: = -1



var _hood_mesh: MeshInstance3D = null
var _hood_mount: BoneAttachment3D = null


var _chest_mount: BoneAttachment3D = null



var _kneepad_meshes: = {}
var _kneepad_l_mat: ShaderMaterial = null
const SPINE_BONES: = ["spine_1", "spine.001", "spine_001", "spine1", "Spine_1", "spine"]








const GAZE_YAW_LIMIT_DEG: = 72.0
const GAZE_PITCH_LIMIT_DEG: = 86.0
const GAZE_DAMP: = 0.55
const GAZE_BLEND: = 7.0





const GAZE_VERTICAL_GUARD_DEG: = 15.0





const GAZE_FADE_PITCH_START: = 58.0
const GAZE_FADE_PITCH_FULL: = 74.0
const GAZE_MIN_DIST: = 0.35






const GAZE_AIM_DIST: = 3.0

const GAZE_SAFE_MARGIN: = 0.08





const GAZE_TURN_RATE: = 7.0
var _gaze_dir: = Vector3.ZERO
var _look: LookAtModifier3D = null
var _gaze: Node3D = null
var _gaze_weight: = 0.0
var _head_rest: = Vector3(0.0, 1.5, 0.0)
var _head_radii: = Vector3(0.65, 0.68, 0.65)

static func model_path() -> String:
	for path in MODEL_PATHS:
		if ResourceLoader.exists(path):
			return path
	return ""

static func available() -> bool:
	return model_path() != ""

var _reflection: = false

func setup(is_reflection: = false) -> bool:



	_reflection = is_reflection
	var packed: PackedScene = load(model_path())
	if packed == null:
		return false
	var scene: = packed.instantiate()


	if not _dev_hook_looked:
		_dev_hook_looked = true
		if not model_hook.is_valid() and "--fake-ears" in LaunchGate.dev_args()\
		and ResourceLoader.exists(DEV_EARS):
			model_hook = Callable(load(DEV_EARS), "dress")
	if model_hook.is_valid():
		model_hook.call(scene)
	add_child(scene)
	_find_ear_names(scene)
	_anim = _find_anim(scene)
	if _anim != null:



		for want in CLIP_ALIASES:
			for candidate in CLIP_ALIASES[want]:
				if _anim.has_animation(candidate)\
				and _anim.get_animation(candidate).length > 0.02:
					_clip_map[want] = candidate
					break

		_anim.playback_default_blend_time = BLEND



		var loop_clips: = {}
		for want in ["idle", "run"]:
			if _clip_map.has(want):
				loop_clips[_clip_map[want]] = true




		for want in ACTION_LOOP:
			if ACTION_LOOP[want] and _clip_map.has(want):
				loop_clips[_clip_map[want]] = true
		for want in _clip_map:
			var anim: Animation = _anim.get_animation(_clip_map[want])
			if anim != null:
				anim.loop_mode = Animation.LOOP_LINEAR if loop_clips.has(_clip_map[want])\
				else Animation.LOOP_NONE
	var meshes: Array = []
	_collect_meshes(scene, meshes)

	var top: = 0.01
	for m in meshes:
		top = maxf(top, (m as MeshInstance3D).mesh.get_aabb().end.y)
	var k: = TARGET_HEIGHT / top
	_scene = scene
	_base_scale = k
	scene.scale = Vector3.ONE * k
	scene.rotation.y = MODEL_YAW


	for m in meshes:
		var mi: = m as MeshInstance3D
		if not String(mi.name).to_lower().contains("hand"):
			continue
		var box: = mi.mesh.get_aabb()

		hand_radius = box.size.z * 0.5 * k
		hand_rest = Vector3(box.end.x - box.size.z * 0.5, 
			box.get_center().y, box.get_center().z) * k
		mi.visible = false
	_apply_toon_materials(scene)
	_skel = _find_skeleton(scene)
	_setup_worn_meshes(meshes)
	_cloth_targets = []
	if _reflection:
		_collect_shape_targets(scene)
		return true
	_ink(meshes, OUTLINE_WIDTH / k)


	_collect_shape_targets(scene)
	_calibrate_hands()
	_build_number_patch(meshes)
	_build_face(meshes)
	_setup_callout_overlay()
	return true




func _setup_worn_meshes(meshes: Array) -> void :
	_hood_mesh = null
	_kneepad_meshes = {}
	for m in meshes:
		var mi: = m as MeshInstance3D
		if mi == null:
			continue
		var nm: = String(mi.name).to_lower()
		if nm.contains("hood"):
			_hood_mesh = mi
		elif _mesh_has_slot(mi, "kneepad"):





			var leg: = "l" if nm.ends_with("_l") else ("r" if nm.ends_with("_r") else "")
			var length: = "short" if nm.contains("short")\
			else ("long" if nm.contains("long") or leg != "" else "short")
			if not _kneepad_meshes.has(length):
				_kneepad_meshes[length] = {}
			_kneepad_meshes[length][leg if leg != "" else "both"] = mi
	_split_kneepads(meshes)
	if _hood_mesh != null:
		var spine: = -1
		if _skel != null:
			for cand in SPINE_BONES:
				spine = _skel.find_bone(cand)
				if spine >= 0:
					break
		if spine >= 0:
			var mount: = BoneAttachment3D.new()
			mount.bone_idx = spine
			_skel.add_child(mount)


			_hood_mesh.reparent(mount)
			_hood_mount = mount




func anim_state() -> Dictionary:
	if _anim == null:
		return {}
	return {"clip": _current, "pos": _anim.current_animation_position, 
		"speed": _anim.speed_scale}







func seek_normalized(value: float, hard: = true) -> void :
	if _anim == null or _anim.current_animation == "":
		return
	var length: = _anim.current_animation_length
	if length > 0.0001:
		_anim.seek(clampf(value, 0.0, 1.0) * length, hard)








var replay_clip: = ""
var _replay_clip_frame: = -10
var _clip_wants: = {}

func replay_force(clip: String) -> void :
	replay_clip = clip if _anim != null and _anim.has_animation(clip) else ""
	_replay_clip_frame = Engine.get_physics_frames()

func replay_clip_active() -> bool:
	return replay_clip != "" and Engine.get_physics_frames() - _replay_clip_frame <= 1




func _want_for_clip(clip: String, fallback: String) -> String:
	if _clip_map.get(fallback, "") == clip:
		return fallback
	if _clip_map.get(clip, "") == clip:
		return clip
	if _clip_wants.is_empty():
		for w in _clip_map:
			if not _clip_wants.has(_clip_map[w]):
				_clip_wants[_clip_map[w]] = w
	return String(_clip_wants.get(clip, fallback))

func clip_length(clip: String) -> float:
	if _anim == null or not _anim.has_animation(clip):
		return 0.0
	return _anim.get_animation(clip).length

func clip_loops(clip: String) -> bool:
	if _anim == null or not _anim.has_animation(clip):
		return false
	return _anim.get_animation(clip).loop_mode != Animation.LOOP_NONE

func apply_anim_state(s: Dictionary) -> void :

	if _anim == null or s.is_empty() or String(s.clip) == "":
		return
	if _anim.current_animation != s.clip:
		_anim.play(s.clip)
	_anim.speed_scale = s.speed
	_anim.seek(s.pos, true)





func play_clip(name: String, loop: = true) -> String:
	if _anim == null or name == "":
		return ""
	var found: = ""
	if _anim.has_animation(name):
		found = name
	else:
		var want: = name.to_lower()
		for a in _anim.get_animation_list():
			var sl: = String(a).to_lower()
			if sl == want or sl.ends_with("/" + want) or sl.ends_with("|" + want)\
			or sl.ends_with(want) or sl.contains(want):
				found = String(a)
				break
	if found == "":
		return ""
	var anim: = _anim.get_animation(found)
	if anim != null:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	_anim.play(found)
	_current = found
	return found


func clip_finished() -> bool:
	return _anim == null or not _anim.is_playing()



func clip_names() -> PackedStringArray:
	return _anim.get_animation_list() if _anim != null else PackedStringArray()

func _build_face(meshes: Array) -> void :



	if _skel == null:
		return
	var head_bone: = _skel.find_bone("head")
	if head_bone < 0:
		return
	var head_box: = AABB()
	for m in meshes:
		var mi: = m as MeshInstance3D
		if String(mi.name).to_lower().contains("head"):
			head_box = mi.mesh.get_aabb()
			_head_mesh = mi.mesh as ArrayMesh
			break
	if head_box.size.y <= 0.0:
		return
	var centre: = head_box.get_center()
	_head_centre = centre


	_head_radii = head_box.size * 0.5
	var r: float = _head_radii.x
	var mount: = BoneAttachment3D.new()
	mount.bone_idx = head_bone
	_head_bone = head_bone
	_skel.add_child(mount)
	_face_root = Node3D.new()

	var rest: = _skel.get_bone_global_rest(head_bone)
	_face_root.transform = rest.affine_inverse() * Transform3D(Basis(), centre)
	mount.add_child(_face_root)
	_head_mount = mount
	_face_radius = r
	_setup_gaze(head_bone)



func head_centre_global() -> Vector3:
	if _face_root != null and is_instance_valid(_face_root) and _face_root.is_inside_tree():
		return _face_root.global_position
	return global_position + global_transform.basis.y * 1.45

func _setup_gaze(head_bone: int) -> void :


	_gaze = Node3D.new()
	_gaze.top_level = true
	add_child(_gaze)
	_look = LookAtModifier3D.new()
	_look.bone_name = _skel.get_bone_name(head_bone)
	_look.forward_axis = _gaze_forward_axis(head_bone)
	_look.origin_from = LookAtModifier3D.ORIGIN_FROM_SELF


	_look.use_angle_limitation = true
	_look.symmetry_limitation = true
	_look.primary_limit_angle = deg_to_rad(GAZE_YAW_LIMIT_DEG)
	_look.secondary_limit_angle = deg_to_rad(GAZE_PITCH_LIMIT_DEG)
	_look.primary_damp_threshold = GAZE_DAMP
	_look.secondary_damp_threshold = GAZE_DAMP
	_look.origin_safe_margin = GAZE_SAFE_MARGIN
	_look.influence = 0.0
	_skel.add_child(_look)
	_look.target_node = _look.get_path_to(_gaze)




	_head_rest = _bone_to_local(_skel.get_bone_global_rest(head_bone)).origin

func _gaze_forward_axis(head_bone: int) -> int:




	var basis: = _bone_to_local(_skel.get_bone_global_rest(head_bone)).basis
	var forward: = Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, MODEL_YAW)
	var axes: = [basis.x, - basis.x, basis.y, - basis.y, basis.z, - basis.z]
	var best: = 4
	var best_dot: = -2.0
	for i in axes.size():
		var d: float = (axes[i] as Vector3).normalized().dot(forward)
		if d > best_dot:
			best_dot = d
			best = i
	return best


func gaze_release() -> void :
	_gaze_weight = 0.0
	if _look != null:
		_look.influence = 0.0
		_look.active = false

func gaze_at(world_pos: Vector3, want: float, delta: float) -> void :


	if _look == null or _gaze == null:
		return
	var head: = global_transform * _head_rest




	var to_ball: = world_pos - head
	var pitch: = absf(atan2(to_ball.y, Vector2(to_ball.x, to_ball.z).length()))
	want *= 1.0 - smoothstep(deg_to_rad(GAZE_FADE_PITCH_START), 
		deg_to_rad(GAZE_FADE_PITCH_FULL), pitch)
	var aim: = _stable_aim(head, world_pos)
	var want_dir: = aim - head
	want_dir = want_dir.normalized()
	if _gaze_dir.length_squared() < 0.5 or _gaze_weight <= 0.001:


		_gaze_dir = want_dir
	else:

		var ang: = _gaze_dir.angle_to(want_dir)
		if ang > 0.0001:
			var step: = minf(1.0, (GAZE_TURN_RATE * delta) / ang)
			var turned: = _gaze_dir.slerp(want_dir, step)


			_gaze_dir = turned.normalized() if turned.length_squared() > 0.001 else want_dir
	_gaze.global_position = head + _gaze_dir * GAZE_AIM_DIST
	_gaze_weight = lerpf(_gaze_weight, clampf(want, 0.0, 1.0), 
		1.0 - exp( - GAZE_BLEND * delta))
	_look.influence = _gaze_weight

	_look.active = _gaze_weight > 0.001

func _stable_aim(head: Vector3, world_pos: Vector3) -> Vector3:


	var to: = world_pos - head
	if to.length() < GAZE_MIN_DIST:
		var away: = to.normalized() if to.length() > 0.001 else global_basis.z
		to = away * GAZE_MIN_DIST
	var flat: = Vector2(to.x, to.z)
	var min_flat: float = absf(to.y) * tan(deg_to_rad(GAZE_VERTICAL_GUARD_DEG))
	if min_flat > 0.001 and flat.length() < min_flat:







		var fwd: = Vector2(global_basis.z.x, global_basis.z.z)
		var anchor: = (fwd.normalized() if fwd.length() > 0.001
			else Vector2(0.0, 1.0)) * min_flat
		var depth: = clampf(flat.length() / min_flat, 0.0, 1.0)
		flat = anchor.lerp(flat, depth)
		to = Vector3(flat.x, to.y, flat.y)
	return head + to

func _surface_point(x: float, y: float) -> Vector3:


	var nx: = x / maxf(_head_radii.x, 0.001)
	var ny: = y / maxf(_head_radii.y, 0.001)
	var inside: = clampf(1.0 - nx * nx - ny * ny, 0.0, 1.0)
	return Vector3(x, y, _head_radii.z * sqrt(inside) * 1.01)







func _surface_lifted(x: float, y: float, lift: float) -> Vector3:
	var p: = _surface_point(x, y)


	var n: = Vector3(
		p.x / maxf(_head_radii.x * _head_radii.x, 0.0001), 
		p.y / maxf(_head_radii.y * _head_radii.y, 0.0001), 
		p.z / maxf(_head_radii.z * _head_radii.z, 0.0001))
	if n.length_squared() < 1e-06:
		return p + Vector3(0.0, 0.0, lift)
	return p + n.normalized() * lift

func _face_mesh(mesh: Mesh, pos: Vector3, rot: Vector3, scale: Vector3, 
		color: Color) -> void :
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mesh.surface_set_material(0, mat) if mesh is ArrayMesh else null
	if mesh is PrimitiveMesh:
		(mesh as PrimitiveMesh).material = mat
	var mi: = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale
	_face_root.add_child(mi)



	Ink.untag([mi])
	_face_parts.append(mi)






const FACE_DIR: = "res://game/character/faces"







static var _face_paths: Dictionary = {}
static var _faces_scanned: = false

static func _scan_faces() -> void :
	_faces_scanned = true
	_face_paths.clear()
	var dir: = DirAccess.open(FACE_DIR)
	if dir == null:
		return
	var re: = RegEx.new()
	re.compile("^face[ _\\-]?([0-9]+)$")
	for entry in dir.get_files():
		var file: = entry


		if file.ends_with(".import"):
			file = file.substr(0, file.length() - 7)
		var m: = re.search(file.get_basename().to_lower())
		if m == null:
			continue
		var kind: = int(m.get_string(1)) - 1
		if kind < 0 or _face_paths.has(kind):
			continue
		_face_paths[kind] = "%s/%s" % [FACE_DIR, file]




static func face_count() -> int:
	if not _faces_scanned:
		_scan_faces()
	var n: = CharacterConfig.FACE_TYPES
	for kind in _face_paths:
		n = maxi(n, int(kind) + 1)
	return n

static func face_texture(kind: int) -> Texture2D:
	if not _faces_scanned:
		_scan_faces()
	if not _face_paths.has(kind):
		return null
	var path: String = _face_paths[kind]
	if not ResourceLoader.exists(path):


		push_warning("face art '%s' not imported yet, reimport the project"
			%path)
		return null
	return load(path) as Texture2D





const FACE_CANVAS: = 512
const FACE_PADDING: = 64
const FACE_TEXTURE_SIZE: = FACE_CANVAS + FACE_PADDING * 2
const FACE_DECAL_EXTENT: = 0.66 * FACE_TEXTURE_SIZE / FACE_CANVAS
const FACE_DECAL_STEPS: = 15




const FACE_DECAL_LIFT: = 0.055

func _build_face_decal(tex: Texture2D) -> void :




	var r: = _face_radius
	var half: = r * FACE_DECAL_EXTENT
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iy in range(FACE_DECAL_STEPS + 1):
		for ix in range(FACE_DECAL_STEPS + 1):
			var u: = float(ix) / float(FACE_DECAL_STEPS)
			var v: = float(iy) / float(FACE_DECAL_STEPS)
			st.set_uv(Vector2(u, v))

			st.add_vertex(_surface_lifted(
				lerpf( - half, half, u), lerpf(half, - half, v), 
				r * FACE_DECAL_LIFT))
	for iy in FACE_DECAL_STEPS:
		for ix in FACE_DECAL_STEPS:
			var i0: = iy * (FACE_DECAL_STEPS + 1) + ix
			var i1: = i0 + 1
			var i2: = i0 + FACE_DECAL_STEPS + 1
			var i3: = i2 + 1
			st.add_index(i0)
			st.add_index(i2)
			st.add_index(i1)
			st.add_index(i1)
			st.add_index(i2)
			st.add_index(i3)
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = tex
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = false
	var mi: = MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	_face_root.add_child(mi)


	Ink.untag([mi])
	_face_parts.append(mi)






func set_face(cfg: CharacterConfig) -> void :
	if _face_root == null:
		return
	for p in _face_parts:
		(p as Node).queue_free()
	_face_parts.clear()
	_ensure_face_vp()
	_rebuild_face_layers(cfg)



	_build_face_decal(_face_vp.get_texture())

func _ensure_face_vp() -> void :
	if _face_vp != null:
		return
	_face_vp = SubViewport.new()
	_face_vp.size = Vector2i(FACE_TEXTURE_SIZE, FACE_TEXTURE_SIZE)
	_face_vp.transparent_bg = true
	_face_vp.disable_3d = true



	_face_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_face_vp)
	_face_canvas = Control.new()
	_face_vp.add_child(_face_canvas)


	_face_canvas.position = Vector2(FACE_PADDING, FACE_PADDING)
	_face_canvas.size = Vector2(FACE_CANVAS, FACE_CANVAS)





func _kick_vp(vp: SubViewport) -> void :
	if vp == null:
		return
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var tree: = get_tree()
	if tree == null:
		return
	var vp_ref: WeakRef = weakref(vp)
	var kick: = func() -> void :
		var live_vp: SubViewport = vp_ref.get_ref()
		if live_vp != null:
			live_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	tree.process_frame.connect(kick, CONNECT_ONE_SHOT)

func _rebuild_face_layers(cfg: CharacterConfig) -> void :
	_kick_vp(_face_vp)
	for c in _face_canvas.get_children():
		c.queue_free()

	if cfg.blush:
		_add_blush(cfg)
	_add_brows(cfg)
	_add_eyes(cfg)
	_add_feature("nose", cfg.nose_shape, Color.WHITE, _feat_xform("nose", cfg))

	for slot in CharacterConfig.ACC_SLOTS:
		var item: = AccessoryCatalog.by_id(cfg.acc_id(slot))
		if item != null and item.hides_mouth:
			return
	_add_feature("mouth", cfg.mouth_shape, Color.WHITE, _feat_xform("mouth", cfg))



class _BlushLayer extends Control:
	var tex: Texture2D
	var patches: Array = []
	func _draw() -> void :
		for p in patches:
			var rw: float = p[1]
			var rh: float = p[2]
			draw_texture_rect(tex, Rect2(p[0] - Vector2(rw, rh), 
				Vector2(rw * 2.0, rh * 2.0)), false, p[3])

static var _blush_tex: Texture2D = null
static func _soft_disc() -> Texture2D:
	if _blush_tex != null:
		return _blush_tex


	var n: = 256
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c: = (n - 1) * 0.5
	for y in n:
		for x in n:
			var d: = Vector2((x - c) / c, (y - c) / c).length()
			var a: = 1.0 - smoothstep(0.93, 1.0, d)
			img.set_pixel(x, y, Color(1, 1, 1, a))
	_blush_tex = ImageTexture.create_from_image(img)
	return _blush_tex



func _add_blush(cfg: CharacterConfig) -> void :
	var shape: = CharacterConfig.blush_shape_key(cfg.blush_shape)
	if shape != "circle":
		var tex: = _blush_texture(shape)
		if tex != null:
			_add_blush_texture(cfg, tex, shape)
			return
	_add_blush_circle(cfg)

func _add_blush_circle(cfg: CharacterConfig) -> void :
	var k: = FACE_CANVAS / 512.0



	var scale_min: = 18.0 / 61.5
	var scale_max: = 105.0 / 61.5
	var rad: = 52.0 * lerpf(scale_min, scale_max, cfg.blush_size) * k
	var rw: = 52.0 * 1.6 * lerpf(scale_min, scale_max, cfg.blush_width) * k
	var gap: = lerpf(-40.0, 115.0, cfg.blush_spacing) * k


	var cheek_x: = FACE_CANVAS * 0.24 + gap
	var cheek_y: = FACE_CANVAS * 0.7 + (cfg.blush_height - 0.5) * 260.0 * k
	var cen: = FACE_CANVAS * 0.5
	var layer: = _BlushLayer.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.tex = _soft_disc()
	var col: = Color(cfg.blush_color, lerpf(0.12, 0.92, cfg.blush_opacity))
	layer.patches = [
		[Vector2(cen + cheek_x, cheek_y), rw, rad, col], 
		[Vector2(cen - cheek_x, cheek_y), rw, rad, col], 
	]
	_face_canvas.add_child(layer)





func _add_blush_texture(cfg: CharacterConfig, tex: Texture2D, key: String) -> void :
	var k: = FACE_CANVAS / 512.0
	var w: = float(tex.get_width())
	var h: = float(tex.get_height())
	var left: = AtlasTexture.new()
	left.atlas = tex
	left.region = Rect2(0.0, 0.0, w * 0.5, h)
	var right: = AtlasTexture.new()
	right.atlas = tex
	right.region = Rect2(w * 0.5, 0.0, w * 0.5, h)
	var col: = Color(cfg.blush_color, lerpf(0.12, 0.98, cfg.blush_opacity))

	var sz: = Vector2(1.0 + (cfg.blush_width - 0.5) * 0.9, 
		1.0 + (cfg.blush_size - 0.5) * 0.9)
	var gap: = (cfg.blush_spacing - 0.5) * 220.0 * k
	var dy: = (cfg.blush_height - 0.5) * 260.0 * k
	var half: = FACE_CANVAS * 0.5
	var lc: = _blush_half_center(key, false)
	var rc: = _blush_half_center(key, true)
	_face_canvas.add_child(_blush_half(right, 0.5, 1.0, 
		Vector2(rc.x * half, rc.y * FACE_CANVAS), Vector2(gap, dy), sz, col))
	_face_canvas.add_child(_blush_half(left, 0.0, 0.5, 
		Vector2(lc.x * half, lc.y * FACE_CANVAS), Vector2( - gap, dy), sz, col))



func _blush_half(tex: Texture2D, anchor_l: float, anchor_r: float, pivot: Vector2, 
		off: Vector2, sz: Vector2, col: Color) -> Control:
	var wrap: = Control.new()
	wrap.anchor_left = anchor_l
	wrap.anchor_right = anchor_r
	wrap.anchor_top = 0.0
	wrap.anchor_bottom = 1.0
	wrap.offset_left = off.x
	wrap.offset_right = off.x
	wrap.offset_top = off.y
	wrap.offset_bottom = off.y
	wrap.pivot_offset = pivot
	wrap.scale = sz
	wrap.modulate = col
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr: = TextureRect.new()
	tr.texture = tex
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(tr)
	return wrap

static var _blush_tex_cache: = {}
static func _blush_texture(key: String) -> Texture2D:
	if _blush_tex_cache.has(key):
		return _blush_tex_cache[key]
	var path: = "res://game/character/faces/blush/%s.png" % key
	var t: Texture2D = (load(path) as Texture2D) if ResourceLoader.exists(path) else null
	_blush_tex_cache[key] = t
	return t



static var _blush_center_cache: = {}
static func _blush_half_center(key: String, right: bool) -> Vector2:
	var ck: = "%s:%s" % [key, "r" if right else "l"]
	if _blush_center_cache.has(ck):
		return _blush_center_cache[ck]
	var c: = Vector2(0.5, 0.55)
	var tex: = _blush_texture(key)
	if tex != null:
		var img: = tex.get_image()
		img.convert(Image.FORMAT_RGBA8)
		var hw: = int(img.get_width() * 0.5)
		var x0: = hw if right else 0
		var ww: = img.get_width() - hw if right else hw
		var sub: = img.get_region(Rect2i(x0, 0, ww, img.get_height()))
		var u: = sub.get_used_rect()
		if u.size.x > 0 and u.size.y > 0:
			var ctr: = Vector2(u.position) + Vector2(u.size) * 0.5
			c = Vector2(ctr.x / sub.get_width(), ctr.y / sub.get_height())
	_blush_center_cache[ck] = c
	return c





const EYE_CX: = 0.115
const EYE_CY: = 0.45
func _add_eyes(cfg: CharacterConfig) -> void :
	var n: = FaceParts.count("eyes")
	if n <= 0 or cfg.eye_shape < 0:
		return
	var idx: = clampi(cfg.eye_shape, 0, n - 1)
	var tex: = FaceParts.texture("eyes", idx)
	if tex == null:
		return
	var w: = float(tex.get_width())
	var h: = float(tex.get_height())
	var right: = AtlasTexture.new()
	right.atlas = tex
	right.region = Rect2(w * 0.5, 0.0, w * 0.5, h)
	var sz: = Vector2(lerpf(0.6, 1.6, cfg.eye_width), 
		lerpf(0.6, 1.6, cfg.eye_size_y))
	var gap: = lerpf(-70.0, 120.0, cfg.eye_spacing) * (FACE_CANVAS / 512.0)
	var dy: = (cfg.eye_height - 0.5) * -390.0 * (FACE_CANVAS / 512.0)
	var pair_x: = (cfg.eye_x - 0.5) * 270.0 * (FACE_CANVAS / 512.0)
	var rot: = (cfg.eye_rot - 0.5) * PI


	var half: = FACE_CANVAS * 0.5
	var rc: = FaceParts.right_half_center("eyes", idx)
	var piv_r: = Vector2(rc.x * half, rc.y * FACE_CANVAS)
	var piv_l: = Vector2((1.0 - rc.x) * half, rc.y * FACE_CANVAS)


	var own_left: = FaceParts.keeps_both_halves("eyes", idx)
	var flip_l: = not own_left
	if own_left:
		var lc: = FaceParts.half_center("eyes", idx, false)
		piv_l = Vector2(lc.x * half, lc.y * FACE_CANVAS)
	var po_r: = Vector2(FACE_CANVAS * EYE_CX, FACE_CANVAS * EYE_CY)
	var po_l: = Vector2(half - FACE_CANVAS * EYE_CX, FACE_CANVAS * EYE_CY)
	var s0: = Vector2(1.1, 1.1)
	var off_r: = Vector2(gap + pair_x, dy) + _pivot_comp(po_r, piv_r, s0)
	var off_l: = Vector2( - gap + pair_x, dy) + _pivot_comp(po_l, piv_l, s0)




	var iris: = FaceParts.tint_texture("eyes", idx)



	var line: = FaceParts.layer_texture("eyes", idx, "line")
	if line != null:
		_add_eye_pair(line, Color.WHITE, piv_r, piv_l, off_r, off_l, sz, rot, own_left)
		if iris != null:
			_add_eye_pair(iris, cfg.eye_color, piv_r, piv_l, off_r, off_l, sz, rot, own_left)
		var lash: = FaceParts.layer_texture("eyes", idx, "lash")
		if lash != null:
			_add_eye_pair(lash, cfg.lash_color, piv_r, piv_l, off_r, off_l, sz, rot, own_left)
		return
	if iris != null:
		var iw: = float(iris.get_width())
		var ih: = float(iris.get_height())
		var iris_r: = AtlasTexture.new()
		iris_r.atlas = iris
		iris_r.region = Rect2(iw * 0.5, 0.0, iw * 0.5, ih)
		var t_r: = _eye_half(iris_r, false, piv_r, off_r, sz, rot, 0.5, 1.0)
		t_r.modulate = cfg.eye_color
		_face_canvas.add_child(t_r)
		var iris_l: = iris_r
		if own_left:
			iris_l = AtlasTexture.new()
			iris_l.atlas = iris
			iris_l.region = Rect2(0.0, 0.0, iw * 0.5, ih)
		var t_l: = _eye_half(iris_l, flip_l, piv_l, off_l, sz, - rot, 0.0, 0.5)
		t_l.modulate = cfg.eye_color
		_face_canvas.add_child(t_l)
	_face_canvas.add_child(_eye_half(right, false, piv_r, off_r, sz, rot, 0.5, 1.0))
	var left: = right
	if own_left:
		left = AtlasTexture.new()
		left.atlas = tex
		left.region = Rect2(0.0, 0.0, w * 0.5, h)
	_face_canvas.add_child(_eye_half(left, flip_l, piv_l, off_l, sz, - rot, 0.0, 0.5))



func _add_eye_pair(tex: Texture2D, tint: Color, piv_r: Vector2, piv_l: Vector2, 
		off_r: Vector2, off_l: Vector2, sz: Vector2, rot: float, own_left: bool) -> void :
	var w: = float(tex.get_width())
	var h: = float(tex.get_height())
	var right: = AtlasTexture.new()
	right.atlas = tex
	right.region = Rect2(w * 0.5, 0.0, w * 0.5, h)
	var t_r: = _eye_half(right, false, piv_r, off_r, sz, rot, 0.5, 1.0)
	t_r.modulate = tint
	_face_canvas.add_child(t_r)
	var left: = right
	if own_left:
		left = AtlasTexture.new()
		left.atlas = tex
		left.region = Rect2(0.0, 0.0, w * 0.5, h)
	var t_l: = _eye_half(left, not own_left, piv_l, off_l, sz, - rot, 0.0, 0.5)
	t_l.modulate = tint
	_face_canvas.add_child(t_l)




const BROW_CX: = 0.13
const BROW_CY: = 0.27
func _add_brows(cfg: CharacterConfig) -> void :
	if cfg.brow_shape < 0:
		return
	var n: = FaceParts.count("brows")
	if n <= 0:
		return
	var tex: = FaceParts.texture("brows", clampi(cfg.brow_shape, 0, n - 1))
	if tex == null:
		return
	var w: = float(tex.get_width())
	var h: = float(tex.get_height())
	var right: = AtlasTexture.new()
	right.atlas = tex
	right.region = Rect2(w * 0.5, 0.0, w * 0.5, h)
	var gap: = lerpf(-55.0, 105.0, cfg.brow_spacing) * (FACE_CANVAS / 512.0)
	var dy: = (cfg.brow_height - 0.5) * -360.0 * (FACE_CANVAS / 512.0)
	var sz: = Vector2(lerpf(0.65, 1.35, cfg.brow_width), 
		lerpf(0.65, 1.35, cfg.brow_size_y))
	var pair_x: = (cfg.brow_x - 0.5) * 270.0 * (FACE_CANVAS / 512.0)
	var rot: = (cfg.brow_rot - 0.5) * PI

	var half: = FACE_CANVAS * 0.5
	var rc: = FaceParts.right_half_center("brows", clampi(cfg.brow_shape, 0, n - 1))
	var piv_r: = Vector2(rc.x * half, rc.y * FACE_CANVAS)
	var piv_l: = Vector2((1.0 - rc.x) * half, rc.y * FACE_CANVAS)
	var po_r: = Vector2(FACE_CANVAS * BROW_CX, FACE_CANVAS * BROW_CY)
	var po_l: = Vector2(half - FACE_CANVAS * BROW_CX, FACE_CANVAS * BROW_CY)
	var s0: = Vector2(1.0, 1.0)
	var br: = _eye_half(right, false, piv_r, 
		Vector2(gap + pair_x, dy) + _pivot_comp(po_r, piv_r, s0), sz, rot, 0.5, 1.0)
	var bl: = _eye_half(right, true, piv_l, 
		Vector2( - gap + pair_x, dy) + _pivot_comp(po_l, piv_l, s0), sz, - rot, 0.0, 0.5)



	if cfg.brow_color != Color.BLACK:
		for half_w in [br, bl]:
			var tr: = (half_w as Control).get_child(0) as TextureRect
			var mat: = ShaderMaterial.new()
			mat.shader = _brow_fill_shader()
			mat.set_shader_parameter("fill", cfg.brow_color)
			tr.material = mat
	_face_canvas.add_child(br)
	_face_canvas.add_child(bl)

static var _brow_fill: Shader = null

static func _brow_fill_shader() -> Shader:
	if _brow_fill == null:
		_brow_fill = Shader.new()
		_brow_fill.code = "shader_type canvas_item;\nuniform vec4 fill = vec4(0.0, 0.0, 0.0, 1.0);\nvoid fragment() {\n\tCOLOR = vec4(fill.rgb, COLOR.a * fill.a);   // COLOR already holds texture x modulate\n}\n"





	return _brow_fill



func _eye_half(tex: Texture2D, flip: bool, pivot: Vector2, off: Vector2, 
		sz: Vector2, rot: float, anchor_l: float, anchor_r: float) -> Control:
	var wrap: = Control.new()
	wrap.anchor_left = anchor_l
	wrap.anchor_right = anchor_r
	wrap.anchor_top = 0.0
	wrap.anchor_bottom = 1.0
	wrap.offset_left = off.x
	wrap.offset_right = off.x
	wrap.offset_top = off.y
	wrap.offset_bottom = off.y
	wrap.pivot_offset = pivot
	wrap.scale = sz
	wrap.rotation = rot
	var tr: = TextureRect.new()
	tr.texture = tex
	tr.flip_h = flip
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(tr)
	return wrap

func _add_feature(feature: String, idx: int, tint: Color, xf: Dictionary) -> void :

	if idx < 0:
		return


	var n: = FaceParts.count(feature)
	if n <= 0:
		return
	idx = clampi(idx, 0, n - 1)
	var base: = FaceParts.texture(feature, idx)
	if base == null:
		return

	var tint_tex: = FaceParts.tint_texture(feature, idx)
	if tint_tex != null:
		var t: = _face_layer(tint_tex, xf)
		t.modulate = tint
		_face_canvas.add_child(t)
	_face_canvas.add_child(_face_layer(base, xf))

func _face_layer(tex: Texture2D, xf: Dictionary) -> TextureRect:
	var tr: = TextureRect.new()
	tr.texture = tex


	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.pivot_offset = xf["pivot"]
	tr.scale = xf["scale"]
	tr.position = xf["pos"]
	tr.rotation = xf.get("rot", 0.0)
	return tr



func _feat_pivot(feature: String, idx: int) -> Vector2:
	var n: = FaceParts.count(feature)
	if idx < 0 or n <= 0:
		return Vector2(FACE_CANVAS, FACE_CANVAS) * 0.5
	return FaceParts.used_center(feature, clampi(idx, 0, n - 1)) * FACE_CANVAS




func _pivot_comp(p_old: Vector2, p_new: Vector2, s0: Vector2) -> Vector2:
	return (p_old - p_new) * (Vector2.ONE - s0)



func _feat_xform(feature: String, cfg: CharacterConfig) -> Dictionary:
	var k: = float(FACE_CANVAS) / 512.0
	match feature:
		"eyes":
			var sz: = lerpf(0.82, 1.22, cfg.eye_size)
			var spread: = lerpf(0.9, 1.16, cfg.eye_spacing)
			return {"pivot": Vector2(256, 235) * k, 
				"scale": Vector2(sz * spread, sz), 
				"pos": Vector2(0, (cfg.eye_height - 0.5) * -170.0 * k)}
		"brows":
			return {"pivot": Vector2(256, 200) * k, "scale": Vector2.ONE, 
				"pos": Vector2(0, (cfg.brow_height - 0.5) * -150.0 * k), 
				"rot": (cfg.brow_rot - 0.5) * PI}
		"nose":
			var nz: = Vector2(lerpf(0.55, 1.55, cfg.nose_width), 
				lerpf(0.55, 1.55, cfg.nose_size_y))
			if cfg.nose_flip:
				nz.x = - nz.x
			var np_old: = Vector2(256, 290) * k
			var np: = _feat_pivot("nose", cfg.nose_shape)
			return {"pivot": np, "scale": nz, 
				"pos": Vector2((cfg.nose_x - 0.5) * 240.0 * k, 
					(cfg.nose_height - 0.5) * -345.0 * k)
					+ _pivot_comp(np_old, np, Vector2(1.05, 1.05))}
		"mouth":
			var mz: = Vector2(lerpf(0.6, 1.6, cfg.mouth_width), 
				lerpf(0.6, 1.6, cfg.mouth_size_y))
			var mp_old: = Vector2(256, 345) * k
			var mp: = _feat_pivot("mouth", cfg.mouth_shape)
			return {"pivot": mp, "scale": mz, 
				"pos": Vector2((cfg.mouth_x - 0.5) * 270.0 * k, 
					(cfg.mouth_height - 0.5) * -300.0 * k)
					+ _pivot_comp(mp_old, mp, Vector2(1.1, 1.1)), 
				"rot": (cfg.mouth_rot - 0.5) * PI}
	return {"pivot": Vector2(256, 256) * k, "scale": Vector2.ONE, "pos": Vector2.ZERO}





func _build_blush(r: float, color: = BLUSH_COLOR) -> void :
	var cheek_y: = r * -0.27
	var cheek_x: = r * 0.4
	for side in [-1.0, 1.0]:
		var patch: = SphereMesh.new()
		patch.radius = r * 0.19
		patch.height = r * 0.38
		patch.radial_segments = 10
		patch.rings = 6



		var pos: = _surface_point(side * cheek_x, cheek_y)
		pos.z += r * 0.09
		_face_mesh(patch, pos, Vector3.ZERO, 
			Vector3(1.0, 0.62, 0.22), color)

func set_hair(style: int, cfg: CharacterConfig) -> void :





	if _head_mount == null:
		return


	if style != _hair_style or cfg.hair_flip != _hair_flipped:
		_hair_style = style
		_hair_flipped = cfg.hair_flip
		_drop_jiggle("")
		if _hair_root != null:
			_hair_root.queue_free()
			_hair_root = null




			_scrub_shell_maps()
		_hair_mats = []
		_hair_defaults = []
		_hair_shell_meshes = []
		_hair_base_meshes = {}
		_hair_tuck_key = ""
		var name: = ""
		if style > 0 and style < CharacterConfig.hair_meshes().size():
			name = CharacterConfig.hair_meshes()[style]
		if name != "":
			var path: String = HAIR_DIR % name
			if ResourceLoader.exists(path):
				_hair_root = (load(path) as PackedScene).instantiate()
				if cfg.hair_flip:
					_mirror_hair(_hair_root)
				_fit_hair(_hair_root)
				_head_mount.add_child(_hair_root)





				var groups: = AccessoryItem.build_groups(_hair_root)
				for g in groups:
					var mat: = _hair_material(AccessoryItem._albedo_of(g["src"]))
					for t in g["targets"]:
						var mi: MeshInstance3D = t[0]
						mi.set_surface_override_material(int(t[1]), mat)
					_hair_mats.append(mat)
					_hair_defaults.append(AccessoryItem._albedo_of(g["src"]))


				_hair_yrange = _measure_hair_yrange()
				_add_jiggle(_hair_root, "")





				var hair_meshes: Array = []
				_collect_meshes(_hair_root, hair_meshes)
				for m in hair_meshes:
					_hair_base_meshes[m] = (m as MeshInstance3D).mesh
				_ink(hair_meshes, OUTLINE_WIDTH / _base_scale, true)
				_hair_shell_meshes = hair_meshes
	_apply_hair_flip(cfg)
	_tint_hair(cfg)





func set_facial_hair(cfg: CharacterConfig) -> void :
	if _head_mount == null:
		return
	var style: = cfg.facial_hair
	if style != _facial_style:
		_facial_style = style
		if _facial_root != null:
			_facial_root.queue_free()
			_facial_root = null
			_scrub_shell_maps()
		_facial_mats = []
		_facial_meshes = []
		var list: = CharacterConfig.facial_hair_meshes()
		var name: = list[style] if style > 0 and style < list.size() else ""
		var path: = "%s/%s.blend" % [CharacterConfig.FACIAL_HAIR_DIR, name]
		if name != "" and ResourceLoader.exists(path):
			var scene: = load(path) as PackedScene
			if scene != null:
				_facial_root = scene.instantiate() as Node3D
		if _facial_root != null:
			_head_mount.add_child(_facial_root)


			_facial_root.transform = _skel.get_bone_global_rest(_head_bone).affine_inverse()
			_facial_pivot = _accessory_centre(_facial_root)
			for g in AccessoryItem.build_groups(_facial_root):
				var mat: = _hair_material(AccessoryItem._albedo_of(g["src"]))
				for t in g["targets"]:
					(t[0] as MeshInstance3D).set_surface_override_material(int(t[1]), mat)
				_facial_mats.append(mat)
			_collect_meshes(_facial_root, _facial_meshes)

			_ink(_facial_meshes, OUTLINE_WIDTH / _base_scale, true)
		elif name != "":
			push_warning("facial hair '%s' is listed but %s will not load" % [name, path])
	for i in _facial_mats.size():
		(_facial_mats[i] as ShaderMaterial).set_shader_parameter("albedo", 
			cfg.facial_hair_color_at(i))
	_fit_facial_to_head(cfg.head_shape)
	_pose_facial_hair(cfg)




func _pose_facial_hair(cfg: CharacterConfig) -> void :
	if _facial_root == null or not is_instance_valid(_facial_root):
		return
	var base: = _skel.get_bone_global_rest(_head_bone).affine_inverse()
	var rad: float = _head_radii.x
	var pos: = Vector3((cfg.fh_px - 0.5) * 2.0 * FACIAL_POS_RANGE.x, 
		(cfg.fh_py - 0.5) * 2.0 * FACIAL_POS_RANGE.y, 
		(cfg.fh_pz - 0.5) * 2.0 * FACIAL_POS_RANGE.z) * rad
	var deg: = Vector3((cfg.fh_rx - 0.5) * 2.0 * FACIAL_ROT_RANGE.x, 
		(cfg.fh_ry - 0.5) * 2.0 * FACIAL_ROT_RANGE.y, 
		(cfg.fh_rz - 0.5) * 2.0 * FACIAL_ROT_RANGE.z)
	var s: = cfg.fh_sc
	var size: = lerpf(FACIAL_SCALE.x, 1.0, clampf(s * 2.0, 0.0, 1.0)) if s <= 0.5\
	else lerpf(1.0, FACIAL_SCALE.y, clampf((s - 0.5) * 2.0, 0.0, 1.0))
	var scl: = Vector3(clampf(size * _acc_axis(cfg.fh_sx), 0.35, 2.2), 
		clampf(size * _acc_axis(cfg.fh_sy), 0.35, 2.2), 
		clampf(size * _acc_axis(cfg.fh_sz), 0.35, 2.2))
	var rs: = Basis.from_euler(deg * (PI / 180.0)) * Basis.from_scale(scl)
	_facial_root.transform = base * Transform3D(rs, pos + _facial_pivot - rs * _facial_pivot)





func _fit_facial_to_head(head_shape: int) -> void :
	_fit_to_head(_facial_meshes, head_shape)



func _fit_to_head(meshes: Array, head_shape: int) -> void :
	if meshes.is_empty():
		return
	var want: = ""
	if head_shape > 0 and head_shape < CharacterConfig.HEAD_SHAPES.size():
		want = CharacterConfig.HEAD_SHAPES[head_shape].to_lower()
	var targets: Array = []
	for m in meshes:
		if _dead(m):
			continue
		targets.append(m)
		for map in [_shells, _hl_shells]:
			var s = map.get(m)
			if s != null and not _dead(s):
				targets.append(s)
	for t in targets:
		var mi: = t as MeshInstance3D
		if mi.mesh == null:
			continue
		for b in mi.mesh.get_blend_shape_count():
			var key: = String(mi.mesh.get_blend_shape_name(b)).to_lower()
			if CharacterConfig.HEAD_SHAPES.has(key):
				mi.set_blend_shape_value(b, 1.0 if key == want else 0.0)


func facial_hair_state() -> Dictionary:
	var keys: = {}
	for m in _facial_meshes:
		if _dead(m) or (m as MeshInstance3D).mesh == null:
			continue
		var mi: = m as MeshInstance3D
		for b in mi.mesh.get_blend_shape_count():
			keys[String(mi.mesh.get_blend_shape_name(b))] = mi.get_blend_shape_value(b)
	return {"style": _facial_style, "mounted": _facial_root != null, 
		"slots": _facial_mats.size(), "keys": keys}






func _apply_hair_flip(_cfg: CharacterConfig) -> void :
	if _hair_root == null or not is_instance_valid(_hair_root):
		return
	var rest: = _skel.get_bone_global_rest(_head_bone)
	_hair_root.transform = rest.affine_inverse()





static var _fit_meshes: = {}
static var hair_fit_on: = true

func _fit_hair(root: Node) -> void :
	var hf: = _head_field()
	if hf == null or not hair_fit_on:
		return
	var parts: Array = []
	_fit_collect(root, root, parts)
	if parts.is_empty():
		return
	var key: = fit_key(parts, _head_mesh)
	if not _fit_meshes.has(key):

		for pass_i in 2:
			var fitted: = _fit_build(parts, hf)
			for i in parts.size():
				(parts[i][0] as MeshInstance3D).mesh = fitted[i]
		var keep: Array = []
		for pt in parts:
			keep.append((pt[0] as MeshInstance3D).mesh)
		_fit_meshes[key] = keep
		return
	var out: Array = _fit_meshes[key]
	for i in parts.size():
		(parts[i][0] as MeshInstance3D).mesh = out[i]




static func fit_key(parts: Array, head_mesh: Mesh) -> String:
	var key: = ""
	for pt in parts:
		var mi: MeshInstance3D = pt[0]
		key += "%d/%d," % [mi.mesh.get_instance_id(), mi.skin.get_instance_id() if mi.skin != null else 0]
	return key + str(head_mesh.get_instance_id())








static func _fit_deep(n: Node) -> float:
	var ex = n.get_meta(&"extras", null)
	if ex is Dictionary and (ex as Dictionary).has("hair_fit_deep"):
		return clampf(float(ex["hair_fit_deep"]), 0.0, HAIR_FIT_DEEP)
	return HAIR_FIT_DEEP

func _fit_collect(n: Node, root: Node, parts: Array) -> void :
	if n is MeshInstance3D and (n as MeshInstance3D).mesh is ArrayMesh:
		parts.append(_fit_part(n as MeshInstance3D, root))
	for c in n.get_children():
		_fit_collect(c, root, parts)


func _fit_part(mi: MeshInstance3D, root: Node) -> Array:
	var sk: Skeleton3D = mi.get_node_or_null(mi.skeleton) as Skeleton3D if mi.skin != null else null
	var binds: Array = []
	if sk != null:
		var to_sk: = _fit_rel(sk, root)
		for bi in mi.skin.get_bind_count():
			var b: = mi.skin.get_bind_bone(bi)
			if b < 0:
				b = sk.find_bone(mi.skin.get_bind_name(bi))
			binds.append(to_sk * (sk.get_bone_global_rest(b) if b >= 0 else Transform3D())\
			* mi.skin.get_bind_pose(bi))
	return [mi, binds, _fit_rel(mi, root)]


static func _fit_rel(n: Node, root: Node) -> Transform3D:
	var t: = Transform3D()
	var at: = n
	while at != null and at != root:
		if at is Node3D:
			t = (at as Node3D).transform * t
		at = at.get_parent()
	return t

func _fit_build(parts: Array, hf: HeadField) -> Array:
	return _fit_emit(_fit_compute(_fit_gather(parts), hf))





static func _fit_gather(parts: Array) -> Dictionary:
	var out: Array = []
	for pt in parts:
		var am: = (pt[0] as MeshInstance3D).mesh as ArrayMesh
		var arrays: Array = []
		var shapes: Array = []
		var info: Array = []
		for si in am.get_surface_count():
			arrays.append(am.surface_get_arrays(si))
			shapes.append(am.surface_get_blend_shape_arrays(si))
			info.append([am.surface_get_primitive_type(si), am.surface_get_material(si), 
				am.surface_get_name(si)])
		var names: Array = []
		for b in am.get_blend_shape_count():
			names.append(am.get_blend_shape_name(b))
		out.append({"mesh": am, "binds": pt[1], "xf": pt[2], "arrays": arrays, 
			"shapes": shapes, "info": info, "names": names, "mode": am.blend_shape_mode, 
			"deep": _fit_deep(pt[0])})
	return {"parts": out}


static func _fit_emit(g: Dictionary) -> Array:
	var out: Array = []
	for pt in g["parts"]:
		if bool(g.get("same", false)):
			out.append(pt["mesh"])
			continue
		var fitted: = ArrayMesh.new()
		fitted.blend_shape_mode = pt["mode"]
		for nm in pt["names"]:
			fitted.add_blend_shape(nm)
		for si in (pt["arrays"] as Array).size():
			var inf: Array = pt["info"][si]
			fitted.add_surface_from_arrays(inf[0], pt["arrays"][si], pt["shapes"][si])
			fitted.surface_set_material(si, inf[1])
			fitted.surface_set_name(si, inf[2])
		out.append(fitted)
	return out



func _fit_compute(g: Dictionary, hf: HeadField) -> Dictionary:
	var parts: Array = g["parts"]
	var spread: = HAIR_FIT_SPREAD * minf(_head_radii.x, _head_radii.z)
	var pts: = _fit_points(parts)
	var qs: Array = pts[0]
	var xfs: Array = pts[1]
	var src_arrays: Array = pts[2]


	var src_q: = PackedVector3Array()
	var src_n: = PackedFloat32Array()
	for pi in parts.size():
		var deep: float = parts[pi].get("deep", HAIR_FIT_DEEP)
		if deep <= 0.0:
			continue
		for si in (qs[pi] as Array).size():
			var q: PackedVector3Array = qs[pi][si]
			var idx = src_arrays[pi][si][Mesh.ARRAY_INDEX]
			if not (idx is PackedInt32Array) or (idx as PackedInt32Array).is_empty():
				idx = PackedInt32Array(range(q.size()))
			for t in range(0, (idx as PackedInt32Array).size() - 2, 3):
				var p0: = q[idx[t]]
				var p1: = q[idx[t + 1]]
				var p2: = q[idx[t + 2]]
				var c: = (p0 + p1 + p2) / 3.0
				var fn: = (p2 - p0).cross(p1 - p0)
				if fn.length_squared() < 1e-12 or c.length_squared() < 1e-12:
					continue
				if fn.normalized().dot(c.normalized()) <= 0.2 or hf.ratio(c) > 1.5:
					continue
				var best: = 0.0
				var best_q: = Vector3.ZERO
				var k: = 3
				for i in k + 1:
					for j in k + 1 - i:
						var sq: = p0 + (p1 - p0) * (float(i) / k) + (p2 - p0) * (float(j) / k)
						var l: = sq.length()
						if l < 1e-06:
							continue
						var u: = sq / l
						var rad: = hf.radius(u)
						if rad - l > deep * rad:
							continue



						if not hf.has_skin(u):
							continue
						var need: = rad * (1.0 + HAIR_FIT_MARGIN) - l
						if need > best:
							best = need
							best_q = sq
				if best > 0.0:
					src_q.append(best_q)
					src_n.append(best)
	if src_q.is_empty():
		g["same"] = true
		return g


	var grid: = {}
	for i in src_q.size():
		grid.get_or_add(Vector3i((src_q[i] / spread).floor()), []).append(i)
	for pi in parts.size():
		for si in (parts[pi]["arrays"] as Array).size():
			var q: PackedVector3Array = qs[pi][si]
			var bx: Array = xfs[pi][si]
			var delta: = PackedVector3Array()
			delta.resize(q.size())
			var moved: = false
			for i in q.size():
				var l: = q[i].length()
				if l < 1e-06:
					continue
				var cell: = Vector3i((q[i] / spread).floor())
				var d: = 0.0
				for dx in 3:
					for dy in 3:
						for dz in 3:
							for s_i in grid.get(cell + Vector3i(dx - 1, dy - 1, dz - 1), []):
								var x: float = q[i].distance_to(src_q[s_i]) / spread
								if x >= 1.0:
									continue


								var kx: = 1.0 if x < 0.4 else 1.0 - smoothstep(0.4, 1.0, x)
								d = maxf(d, src_n[s_i] * kx)
				if d <= 0.0:
					continue
				var basis: Basis = bx[i]
				if absf(basis.determinant()) < 1e-09:
					continue
				delta[i] = basis.inverse() * (q[i] / l * d)
				moved = true
			if moved:
				_fit_shift(src_arrays[pi][si], parts[pi]["shapes"][si], delta)
	return g


static func _fit_shift(a: Array, shapes: Array, delta: PackedVector3Array) -> void :
	var verts: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
	for i in verts.size():
		verts[i] += delta[i]
	a[Mesh.ARRAY_VERTEX] = verts

	for sh in shapes:
		var sv = sh[Mesh.ARRAY_VERTEX]
		if sv is PackedVector3Array and (sv as PackedVector3Array).size() == verts.size():
			for i in verts.size():
				sv[i] += delta[i]
			sh[Mesh.ARRAY_VERTEX] = sv




func _fit_points(parts: Array) -> Array:
	var qs: Array = []
	var xfs: Array = []
	var src_arrays: Array = []
	for pt in parts:
		var binds: Array = pt["binds"]
		var node_xf: Transform3D = pt["xf"]
		var pq: Array = []
		var px: Array = []
		var pa: Array = []
		for si in (pt["arrays"] as Array).size():
			var a: Array = pt["arrays"][si]
			pa.append(a)
			var verts: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var bones = a[Mesh.ARRAY_BONES]
			var wts = a[Mesh.ARRAY_WEIGHTS]
			var per: = 0
			if not binds.is_empty() and bones is PackedInt32Array and not (bones as PackedInt32Array).is_empty():
				per = (bones as PackedInt32Array).size() / verts.size()
			var q: = PackedVector3Array()
			q.resize(verts.size())
			var bx: Array = []
			bx.resize(verts.size())
			for i in verts.size():
				var xf: = node_xf
				if per > 0:
					var bs: = Basis(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
					var o: = Vector3.ZERO
					var tw: = 0.0
					for k in per:
						var w: float = wts[i * per + k]
						if w <= 0.0:
							continue
						var t: Transform3D = binds[bones[i * per + k]]
						bs = Basis(bs.x + t.basis.x * w, bs.y + t.basis.y * w, bs.z + t.basis.z * w)
						o += t.origin * w
						tw += w
					if tw > 0.0:
						xf = Transform3D(bs, o)
				q[i] = xf * verts[i] - _head_centre
				bx[i] = xf.basis
			pq.append(q)
			px.append(bx)
		qs.append(pq)
		xfs.append(px)
		src_arrays.append(pa)
	return [qs, xfs, src_arrays]











static var hood_tuck_on: = true
static var _tuck_meshes: = {}
static var _hat_fields: = {}



func _tuck_hair_under(item: AccessoryItem, openings: = true, slot: = "head") -> void :
	if _hair_root == null or not is_instance_valid(_hair_root):
		return
	var hat = _acc_roots.get(slot, null) if item != null and hood_tuck_on else null
	var key: = ""
	var hk: = ""
	var to_frame: = Transform3D()
	var grow: float = _acc_fit.get(slot, 1.0)
	if hat != null and is_instance_valid(hat):


		to_frame = _ungrow(grow) * _hair_root.transform.affine_inverse() * (hat as Node3D).transform
		hk = _hat_key(item, to_frame)
		key = "%s|%.4f%s" % [hk, grow, "|open" if openings else ""]
	if key == _hair_tuck_key:
		return
	_hair_tuck_key = key

	for mi in _hair_base_meshes:
		if is_instance_valid(mi):
			_swap_hair_mesh(mi, _hair_base_meshes[mi])




	_hold_hair_jiggle(key != "" and openings)
	if key == "":
		return
	var parts: Array = []
	for mi in _hair_base_meshes:
		if is_instance_valid(mi) and (mi as MeshInstance3D).mesh is ArrayMesh:
			parts.append(_fit_part(mi, _hair_root))
	if parts.is_empty():
		return
	var ck: = fit_key(parts, _head_mesh) + key
	if not _tuck_meshes.has(ck):
		if _tuck_meshes.size() > 48:
			_tuck_meshes.clear()
		var field: = _hat_field(hat, hk, to_frame)
		if grow != 1.0:
			var gk: = "%s|%.4f" % [hk, grow]
			if not _hat_fields.has(gk):
				_hat_fields[gk] = field.scaled(grow)
			field = _hat_fields[gk]
		var g: = _fit_gather(parts)
		for i in parts.size():
			g["parts"][i]["tails"] = _tail_binds(parts[i][0])
		g = _tuck_compute(g, field, openings)
		_tuck_meshes[ck] = _fit_emit(g)
	var out: Array = _tuck_meshes[ck]
	for i in parts.size():
		_swap_hair_mesh(parts[i][0], out[i])

func _hold_hair_jiggle(hold: bool) -> void :
	for j in _jiggles:
		if j["owner"] == "":
			j["held"] = hold
	_jiggle_park( not GameConfig.hair_physics)


static func _tail_binds(mi: MeshInstance3D) -> PackedByteArray:
	var out: = PackedByteArray()
	if mi.skin == null:
		return out
	out.resize(mi.skin.get_bind_count())
	for bi in out.size():
		out[bi] = 1 if String(mi.skin.get_bind_name(bi)).begins_with(TAIL_PREFIX) else 0
	return out


func _ungrow(grow: float) -> Transform3D:
	if grow == 1.0:
		return Transform3D()
	return Transform3D(Basis.from_scale(Vector3.ONE / grow), _head_centre - _head_centre / grow)



func _hat_key(item: AccessoryItem, to_frame: Transform3D) -> String:
	return "%s|%s|%s" % [item.id, str(to_frame), str(_head_centre)]

func _hat_field(hat: Node3D, hk: String, to_frame: Transform3D) -> HatField:
	if not _hat_fields.has(hk):
		if _hat_fields.size() > 16:
			_hat_fields.clear()
		_hat_fields[hk] = HatField.build(hat, to_frame, _head_centre)
	return _hat_fields[hk]







const HAT_FIT_SHARE: = 0.8
const HAT_FIT_SUNK: = 0.9
const HAT_FIT_THIN: = 1.06
const HAT_FIT_MARGIN: = 0.02
static var _hair_reach: = {}



func _fit_hat_to_hair(cfg: CharacterConfig, item: AccessoryItem, slot: = "head") -> void :
	var want: = 1.0
	var lift: = 0.0
	var hat = _acc_roots.get(slot, null)
	if hood_tuck_on and item != null and (item.fit_to_hair or item.sit_on_hair) and hat != null\
	and is_instance_valid(hat) and _hair_root != null and is_instance_valid(_hair_root):

		if _acc_fit.get(slot, 1.0) != 1.0 or _acc_lift.get(slot, 0.0) != 0.0:
			_acc_fit[slot] = 1.0
			_acc_lift[slot] = 0.0
			_pose_accessory(slot, cfg)
		if item.fit_to_hair:
			var to_frame: = _hair_root.transform.affine_inverse() * (hat as Node3D).transform
			var field: = _hat_field(hat, _hat_key(item, to_frame), to_frame)
			var reach: = _hair_reach_of()
			var hf: = _head_field()
			var need: Array = []
			var m: = HAT_FIT_MARGIN * minf(_head_radii.x, _head_radii.z)
			for b in reach.size():
				if reach[b] <= 0.0 or not field.covers(b):
					continue








				var hr: = hf.radius(field.dir(b)) if hf != null else 0.0
				if field.inner(b) < hr * HAT_FIT_SUNK or reach[b] < hr * HAT_FIT_THIN:
					need.append(1.0)
					continue
				need.append((reach[b] + m) / field.inner(b))
			if not need.is_empty():
				need.sort()
				want = clampf(need[int((need.size() - 1) * HAT_FIT_SHARE)], 1.0, item.fit_max)
			if want != 1.0:
				_acc_fit[slot] = want
				_pose_accessory(slot, cfg)
		if item.sit_on_hair:

			lift = _hat_lift(hat)
	if want != _acc_fit.get(slot, 1.0) or lift != _acc_lift.get(slot, 0.0):
		_acc_fit[slot] = want
		_acc_lift[slot] = lift
		_pose_accessory(slot, cfg)


func _hair_reach_of() -> PackedFloat32Array:
	var parts: Array = []
	for mi in _hair_base_meshes:
		if is_instance_valid(mi) and (mi as MeshInstance3D).mesh is ArrayMesh:
			parts.append(_fit_part(mi, _hair_root))
	var out: = PackedFloat32Array()
	out.resize(HatField.NU * HatField.NV)
	if parts.is_empty():
		return out
	var key: = fit_key(parts, _head_mesh)
	if _hair_reach.has(key):
		return _hair_reach[key]
	var probe: = HatField.new()
	var pts: = _fit_points(_fit_gather(parts)["parts"])
	for pq in pts[0]:
		for q in pq:
			for p in (q as PackedVector3Array):
				var l: = p.length()
				if l < 1e-06:
					continue
				var b: = probe.bin(p / l)
				out[b] = maxf(out[b], l)
	if _hair_reach.size() > 48:
		_hair_reach.clear()
	_hair_reach[key] = out
	return out










const HAT_SIT_SHARE: = 0.5
const HAT_CONTACT_SLACK: = 0.02

func _hat_lift(hat: Node3D) -> float:
	var tops: = _hair_tops_of()
	if tops.is_empty():
		return 0.0
	var to_frame: = _hair_root.transform.affine_inverse() * hat.transform
	var faces: = PackedVector3Array()
	var lo: = INF
	var mn: = Vector2(INF, INF)
	var mx: = Vector2( - INF, - INF)
	for mi in hat.find_children("*", "MeshInstance3D", true, false):
		var m: = mi as MeshInstance3D
		if m.mesh == null:
			continue
		var xf: = to_frame * _fit_rel(m, hat)
		for s in m.mesh.get_surface_count():
			var a: = m.mesh.surface_get_arrays(s)
			var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var pts: = PackedVector3Array()
			pts.resize(v.size())
			for i in v.size():
				var q: Vector3 = xf * v[i] - _head_centre
				pts[i] = q
				lo = minf(lo, q.y)
				mn = Vector2(minf(mn.x, q.x), minf(mn.y, q.z))
				mx = Vector2(maxf(mx.x, q.x), maxf(mx.y, q.z))
			var idx = a[Mesh.ARRAY_INDEX]
			if idx is PackedInt32Array and not (idx as PackedInt32Array).is_empty():
				for t in idx:
					faces.append(pts[t])
			else:
				faces.append_array(pts)
	var tm: = TriangleMesh.new()
	if faces.is_empty() or not tm.create_from_faces(faces):
		return 0.0
	var scalp: = _scalp_tops_of()
	var n: int = tops["n"]
	var ext: float = tops["ext"]
	var cell: = 2.0 * ext / n
	var h: PackedFloat32Array = tops["h"]
	var sh: PackedFloat32Array = scalp.get("h", PackedFloat32Array())
	var slack: = HAT_CONTACT_SLACK * minf(_head_radii.x, _head_radii.z)
	var thick: Array = []
	for iz in range(maxi(int((mn.y + ext) / cell), 0), mini(int((mx.y + ext) / cell) + 1, n)):
		for ix in range(maxi(int((mn.x + ext) / cell), 0), mini(int((mx.x + ext) / cell) + 1, n)):
			var k: = iz * n + ix
			if h[k] == - INF or k >= sh.size() or sh[k] == - INF:
				continue

			var from: = Vector3( - ext + (ix + 0.5) * cell, lo - 1.0, - ext + (iz + 0.5) * cell)
			var hit: = tm.intersect_ray(from, Vector3.UP)
			if hit.is_empty() or (hit["position"] as Vector3).y > sh[k] + slack:
				continue
			thick.append(maxf(h[k] - sh[k], 0.0))
	if thick.is_empty():
		return 0.0
	thick.sort()
	var lift: float = thick[int((thick.size() - 1) * HAT_SIT_SHARE)]
	return lift if lift > 0.0 else 0.0




static var _scalp_tops: = {}

func _scalp_tops_of() -> Dictionary:
	var hf: = _head_field()
	if hf == null:
		return {}
	var key: = "%s|%s" % [str(_head_mesh.get_instance_id()), str(_head_radii)]
	if _scalp_tops.has(key):
		return _scalp_tops[key]
	var n: = HAIR_TOPS_N
	var ext: = _hair_tops_ext()
	var cell: = 2.0 * ext / n
	var h: = PackedFloat32Array()
	h.resize(n * n)
	h.fill( - INF)
	var top: = _head_radii.y * 2.0
	for iz in n:
		for ix in n:
			var x: = - ext + (ix + 0.5) * cell
			var z: = - ext + (iz + 0.5) * cell

			if hf.ratio(Vector3(x, 0.0, z)) >= 1.0:
				continue
			var a: = 0.0
			var b: = top
			for _i in 14:
				var mid: = 0.5 * (a + b)
				if hf.ratio(Vector3(x, mid, z)) < 1.0:
					a = mid
				else:
					b = mid
			h[iz * n + ix] = a
	if _scalp_tops.size() > 16:
		_scalp_tops.clear()
	_scalp_tops[key] = {"n": n, "ext": ext, "h": h}
	return _scalp_tops[key]

func _hair_tops_ext() -> float:
	return 2.5 * maxf(_head_radii.x, _head_radii.z)







const HAIR_TOPS_N: = 48
static var _hair_tops: = {}

func _hair_tops_of() -> Dictionary:
	var parts: Array = []
	for mi in _hair_base_meshes:
		if is_instance_valid(mi) and (mi as MeshInstance3D).mesh is ArrayMesh:
			parts.append(_fit_part(mi, _hair_root))
	if parts.is_empty():
		return {}
	var key: = fit_key(parts, _head_mesh)
	if _hair_tops.has(key):
		return _hair_tops[key]
	var n: = HAIR_TOPS_N
	var ext: = _hair_tops_ext()
	var h: = PackedFloat32Array()
	h.resize(n * n)
	h.fill( - INF)
	var pts: = _fit_points(_fit_gather(parts)["parts"])
	var faces: = PackedVector3Array()
	var top: = - INF
	for part in (pts[0] as Array).size():
		for si in (pts[0][part] as Array).size():
			var q: PackedVector3Array = pts[0][part][si]
			for p: Vector3 in q:
				top = maxf(top, p.y)
			var idx = (pts[2][part][si] as Array)[Mesh.ARRAY_INDEX]
			if idx is PackedInt32Array and not (idx as PackedInt32Array).is_empty():
				for t in idx:
					faces.append(q[t])
			else:
				faces.append_array(q)
	var tm: = TriangleMesh.new()
	if not faces.is_empty() and tm.create_from_faces(faces):
		var cell: = 2.0 * ext / n
		for iz in n:
			for ix in n:
				var hit: = tm.intersect_ray(Vector3( - ext + (ix + 0.5) * cell, top + 1.0, 
					- ext + (iz + 0.5) * cell), Vector3.DOWN)
				if not hit.is_empty():
					h[iz * n + ix] = (hit["position"] as Vector3).y
	if _hair_tops.size() > 48:
		_hair_tops.clear()
	var out: = {"n": n, "ext": ext, "h": h}
	_hair_tops[key] = out
	return out



func _swap_hair_mesh(mi: MeshInstance3D, mesh: Mesh) -> void :
	var old: = mi.mesh
	if old == mesh:
		return
	for c in mi.get_parent().get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).mesh == old:
			(c as MeshInstance3D).mesh = mesh



func _tuck_compute(g: Dictionary, hat: HatField, openings: = true) -> Dictionary:
	var parts: Array = g["parts"]
	var pts: = _fit_points(parts)
	var rad: = minf(_head_radii.x, _head_radii.z)
	var gap: = HOOD_TUCK_GAP * rad
	var any: = false
	for pi in parts.size():
		for si in (pts[0][pi] as Array).size():
			var q: PackedVector3Array = pts[0][pi][si]
			var bx: Array = pts[1][pi][si]


			var tails: PackedByteArray = parts[pi].get("tails", PackedByteArray())
			var root_bind: = tails.find(0)
			var sa: Array = pts[2][pi][si]
			var bones = sa[Mesh.ARRAY_BONES]
			var wts = sa[Mesh.ARRAY_WEIGHTS]
			var per: = 0
			if not tails.is_empty() and bones is PackedInt32Array and not (bones as PackedInt32Array).is_empty():
				per = (bones as PackedInt32Array).size() / q.size()
			var delta: = PackedVector3Array()
			delta.resize(q.size())
			var moved: = false
			var pinned: = false
			for i in q.size():
				var l: = q[i].length()
				if l < 1e-06:
					continue
				var u: = q[i] / l
				var b: = hat.bin(u)
				var target: = l
				if hat.covers(b):




					if per > 0 and root_bind >= 0:
						var wt: = 0.0
						var root_k: = -1
						var free_k: = -1
						for k in per:
							var bi: int = bones[i * per + k]
							if bi == root_bind:
								root_k = k
							elif bi < tails.size() and tails[bi] == 1:
								wt += wts[i * per + k]
								wts[i * per + k] = 0.0
								if free_k < 0:
									free_k = k
						if wt > 0.0:
							if root_k < 0:
								root_k = free_k
								bones[i * per + root_k] = root_bind
							wts[i * per + root_k] += wt
							pinned = true











					var rim: = hat.depth(b) * HatField.EDGE_BINS < 1.5
					var keep: = minf(hat.outer(b), hat.inner(b) + HAT_SHELL * rad) if rim\
					else hat.inner(b) - gap * 0.2
					if l <= keep:
						continue
					target = hat.inner(b) - gap * hat.depth(b)
				elif openings:





					var lim: = hat.limit(b)
					if lim <= 0.0:
						continue
					lim += HOOD_OPEN_SLACK * rad if u.y > -0.5 else - gap
					if l <= lim:
						continue
					target = lim
				if l <= target:
					continue
				var basis: Basis = bx[i]
				if absf(basis.determinant()) < 1e-09:
					continue
				delta[i] = basis.inverse() * (u * (target - l))
				moved = true
			if moved:
				any = true
				_fit_shift(sa, parts[pi]["shapes"][si], delta)
			if pinned:
				any = true
				sa[Mesh.ARRAY_BONES] = bones
				sa[Mesh.ARRAY_WEIGHTS] = wts
	if not any:
		g["same"] = true
	return g




class HatField extends RefCounted:
	const NU: = 64
	const NV: = 32
	const EDGE_BINS: = 3
	const HAT_SWAY: = 0.18
	const RAYS: = 1
	var _in: = PackedFloat32Array()
	var _out: = PackedFloat32Array()
	var _lim: = PackedFloat32Array()
	var _edge: = PackedByteArray()





	static func build(hat: Node3D, to_frame: Transform3D, centre: Vector3) -> HatField:
		var f: = HatField.new()
		f._in.resize(NU * NV)
		f._in.fill(0.0)
		f._out.resize(NU * NV)
		f._out.fill(0.0)
		var faces: = PackedVector3Array()
		var far: = 0.0
		for mi in hat.find_children("*", "MeshInstance3D", true, false):
			var m: = mi as MeshInstance3D
			if m.mesh == null:
				continue
			var xf: = to_frame * ModelRig._fit_rel(m, hat)



			var tails: = ModelRig._tail_binds(m)
			for s in m.mesh.get_surface_count():
				var a: = m.mesh.surface_get_arrays(s)
				var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
				var pts: = PackedVector3Array()
				pts.resize(v.size())
				var bones = a[Mesh.ARRAY_BONES]
				var wts = a[Mesh.ARRAY_WEIGHTS]
				var per: = 0
				if tails.has(1) and bones is PackedInt32Array and not (bones as PackedInt32Array).is_empty():
					per = (bones as PackedInt32Array).size() / v.size()
				for i in v.size():
					var q: = xf * v[i] - centre
					var sway: = 0.0
					for k in per:
						var bi: int = bones[i * per + k]
						if bi < tails.size() and tails[bi] == 1:
							sway += wts[i * per + k]
					pts[i] = q * (1.0 - HAT_SWAY * sway)
					far = maxf(far, q.length())
				var idx = a[Mesh.ARRAY_INDEX]
				if idx is PackedInt32Array and not (idx as PackedInt32Array).is_empty():
					for t in idx:
						faces.append(pts[t])
				else:
					faces.append_array(pts)
		var tm: = TriangleMesh.new()
		if faces.is_empty() or not tm.create_from_faces(faces):
			f._measure_edge()
			f._measure_limit()
			return f
		far = far * 1.5 + 1.0
		for b in NU * NV:
			for su in RAYS:
				for sv in RAYS:
					var d: = f._dir_at(b, (su + 0.5) / RAYS, (sv + 0.5) / RAYS)
					var hit: = tm.intersect_ray(Vector3.ZERO, d)
					if hit.is_empty():
						continue
					var li: float = (hit["position"] as Vector3).length()
					if f._in[b] == 0.0 or li < f._in[b]:
						f._in[b] = li
					var back: = tm.intersect_segment(d * far, Vector3.ZERO)
					if not back.is_empty():
						f._out[b] = maxf(f._out[b], (back["position"] as Vector3).length())
		f._close()
		f._close()
		f._erode_inner()
		f._measure_edge()
		f._measure_limit()
		return f




	func _erode_inner() -> void :
		var src: = _in.duplicate()
		for b in NU * NV:
			if src[b] <= 0.0:
				continue
			for j in _around(b):
				if src[j] > 0.0 and src[j] < _in[b]:
					_in[b] = src[j]



	func scaled(s: float) -> HatField:
		var f: = HatField.new()
		f._in = _in.duplicate()
		f._out = _out.duplicate()
		f._lim = _lim.duplicate()
		f._edge = _edge
		for b in NU * NV:
			f._in[b] *= s
			f._out[b] *= s
			f._lim[b] *= s
		return f

	func bin(d: Vector3) -> int:
		var u: = int((atan2(d.x, d.z) + PI) / TAU * NU) % NU
		var v: = clampi(int(acos(clampf(d.y, -1.0, 1.0)) / PI * NV), 0, NV - 1)
		return v * NU + u

	func covers(b: int) -> bool:
		return _in[b] > 0.0


	func dir(b: int) -> Vector3:
		return _dir_at(b, 0.5, 0.5)


	func _dir_at(b: int, fu: float, fv: float) -> Vector3:
		var th: = (float(b / NU) + fv) / NV * PI
		var ph: = (float(b % NU) + fu) / NU * TAU - PI
		return Vector3(sin(th) * sin(ph), cos(th), sin(th) * cos(ph))

	func inner(b: int) -> float:
		return _in[b]

	func outer(b: int) -> float:
		return _out[b]


	func depth(b: int) -> float:
		return float(_edge[b]) / EDGE_BINS


	func limit(b: int) -> float:
		return _lim[b]




	static var _rings: Array[PackedInt32Array] = []

	static func _around(b: int) -> PackedInt32Array:
		if _rings.is_empty():
			for i in NU * NV:
				var out: = PackedInt32Array()
				var v: = i / NU
				var u: = i % NU
				for dv in [-1, 0, 1]:
					for du in [-1, 0, 1]:
						var vv: int = v + dv
						if (dv == 0 and du == 0) or vv < 0 or vv >= NV:
							continue
						out.append(vv * NU + (u + du + NU) % NU)
				_rings.append(out)
		return _rings[b]




	func _close() -> void :
		var src_in: = _in.duplicate()
		var src_out: = _out.duplicate()
		for b in NU * NV:
			if src_in[b] > 0.0:
				continue
			var n: = 0
			var lo: = 0.0
			var hi: = 0.0
			for j in _around(b):
				if src_in[j] > 0.0:
					n += 1
					lo = src_in[j] if lo == 0.0 else minf(lo, src_in[j])
					hi = maxf(hi, src_out[j])
			if n >= 5:
				_in[b] = lo
				_out[b] = hi

		for v in [0, NV - 1]:
			var n: = 0
			var lo: = 0.0
			var hi: = 0.0
			for u in NU:
				var b: int = v * NU + u
				if _in[b] > 0.0:
					n += 1
					lo = _in[b] if lo == 0.0 else minf(lo, _in[b])
					hi = maxf(hi, _out[b])
			if n * 4 >= NU * 3:
				for u in NU:
					if _in[v * NU + u] == 0.0:
						_in[v * NU + u] = lo
						_out[v * NU + u] = hi




	func _measure_edge() -> void :
		_edge.resize(NU * NV)
		_edge.fill(EDGE_BINS)
		for ring in range(1, EDGE_BINS):
			var src: = _edge.duplicate()
			for b in NU * NV:
				if _in[b] <= 0.0 or src[b] < EDGE_BINS:
					continue
				for j in _around(b):
					if (ring == 1 and _in[j] <= 0.0) or (ring > 1 and src[j] == ring - 1):
						_edge[b] = ring
						break



	func _measure_limit() -> void :
		_lim.resize(NU * NV)
		_lim.fill(0.0)
		var front: = PackedInt32Array()
		for b in NU * NV:
			if _in[b] > 0.0:
				_lim[b] = _out[b]
				front.append(b)
		while not front.is_empty():
			var next: = PackedInt32Array()
			for b in front:
				for j in _around(b):
					if _in[j] <= 0.0 and _lim[j] == 0.0:
						_lim[j] = _lim[b]
						next.append(j)
			front = next
		for b in NU * NV:
			if _in[b] > 0.0:
				_lim[b] = 0.0








static var _mirror_meshes: = {}
static var _mirror_skins: = {}

static func _mirror_xf(t: Transform3D) -> Transform3D:
	var m: = Transform3D(Basis.from_scale(Vector3(-1.0, 1.0, 1.0)), Vector3.ZERO)
	return m * t * m

func _mirror_hair(root: Node) -> void :
	for c in root.get_children():
		_mirror_node(c)

func _mirror_node(n: Node) -> void :
	if n is Node3D:
		(n as Node3D).transform = _mirror_xf((n as Node3D).transform)
	if n is Skeleton3D:
		var sk: = n as Skeleton3D
		for b in sk.get_bone_count():
			sk.set_bone_rest(b, _mirror_xf(sk.get_bone_rest(b)))
		sk.reset_bone_poses()
	if n is MeshInstance3D:
		var mi: = n as MeshInstance3D
		if mi.mesh != null:
			mi.mesh = _mirrored_mesh(mi.mesh)
		if mi.skin != null:
			mi.skin = _mirrored_skin(mi.skin)
	for c in n.get_children():
		_mirror_node(c)

static func _mirrored_skin(src: Skin) -> Skin:
	if _mirror_skins.has(src):
		return _mirror_skins[src]
	var out: = Skin.new()
	out.set_bind_count(src.get_bind_count())
	for i in src.get_bind_count():
		out.set_bind_bone(i, src.get_bind_bone(i))
		out.set_bind_name(i, src.get_bind_name(i))
		out.set_bind_pose(i, _mirror_xf(src.get_bind_pose(i)))
	_mirror_skins[src] = out
	return out

static func _mirrored_mesh(src: Mesh) -> Mesh:
	if _mirror_meshes.has(src):
		return _mirror_meshes[src]
	var am: = src as ArrayMesh
	if am == null:
		return src
	var out: = ArrayMesh.new()
	out.blend_shape_mode = am.blend_shape_mode
	for b in am.get_blend_shape_count():
		out.add_blend_shape(am.get_blend_shape_name(b))
	for i in am.get_surface_count():
		var prim: = am.surface_get_primitive_type(i)
		var arrays: = am.surface_get_arrays(i)
		_mirror_arrays(arrays, prim == Mesh.PRIMITIVE_TRIANGLES)
		var shapes: = am.surface_get_blend_shape_arrays(i)
		for sh in shapes:
			_mirror_arrays(sh, false)
		out.add_surface_from_arrays(prim, arrays, shapes)
		out.surface_set_material(i, am.surface_get_material(i))
		out.surface_set_name(i, am.surface_get_name(i))
	_mirror_meshes[src] = out
	return out

static func _mirror_arrays(a: Array, rewind: bool) -> void :
	var v = a[Mesh.ARRAY_VERTEX]
	if v is PackedVector3Array:
		for k in v.size():
			v[k].x = - v[k].x
		a[Mesh.ARRAY_VERTEX] = v
	var nrm = a[Mesh.ARRAY_NORMAL]
	if nrm is PackedVector3Array:
		for k in nrm.size():
			nrm[k].x = - nrm[k].x
		a[Mesh.ARRAY_NORMAL] = nrm

	var tan = a[Mesh.ARRAY_TANGENT]
	if tan is PackedFloat32Array:
		for k in range(0, tan.size(), 4):
			tan[k] = - tan[k]
			tan[k + 3] = - tan[k + 3]
		a[Mesh.ARRAY_TANGENT] = tan
	if not rewind:
		return

	var idx = a[Mesh.ARRAY_INDEX]
	if not (idx is PackedInt32Array) or (idx as PackedInt32Array).is_empty():
		idx = PackedInt32Array(range((v as PackedVector3Array).size()))
	for k in range(0, idx.size() - 2, 3):
		var t: int = idx[k + 1]
		idx[k + 1] = idx[k + 2]
		idx[k + 2] = t
	a[Mesh.ARRAY_INDEX] = idx





func _tint_hair(cfg: CharacterConfig) -> void :
	_hair_grad_active = false
	var all_dark: = _hair_mats.size() > 0
	for i in _hair_mats.size():
		var fallback: Color = _hair_defaults[i] if i < _hair_defaults.size() else Color.WHITE
		var mat: = _hair_mats[i] as ShaderMaterial
		var top: Color = cfg.hair_color_at(i, fallback)
		mat.set_shader_parameter("albedo", top)
		var on: = cfg.hair_gradient_on(i)
		mat.set_shader_parameter("grad_on", 1.0 if on else 0.0)
		if not _near_black(top):
			all_dark = false
		if on:
			_hair_grad_active = true
			var fade: Vector2 = cfg.hair_gradient_fade(i)
			var bottom: Color = cfg.hair_gradient_bottom(i, top.darkened(0.4))
			if not _near_black(bottom):
				all_dark = false
			mat.set_shader_parameter("top_color", top)
			mat.set_shader_parameter("bottom_color", bottom)
			mat.set_shader_parameter("grad_y_min", _hair_yrange.x)
			mat.set_shader_parameter("grad_y_max", _hair_yrange.y)
			mat.set_shader_parameter("grad_fade_start", fade.x)
			mat.set_shader_parameter("grad_fade_end", fade.y)


	_hair_outline_off = all_dark
	_refresh_hair_outline()


	if _hair_grad_active:
		_push_hair_anchor()




func _near_black(c: Color) -> bool:
	return maxf(maxf(c.r, c.g), c.b) <= 0.14





func _refresh_hair_outline() -> void :
	for mi in _hair_shell_meshes:
		if not is_instance_valid(mi):
			continue
		var s = _shells.get(mi)
		if s == null or not is_instance_valid(s):
			continue
		if GameConfig.contour_outline:


			(s as MeshInstance3D).visible = not _shell_lod_hidden\
			and (mi as MeshInstance3D).visible
			(s as MeshInstance3D).material_override = _contour_only(head_stencil_id())\
			if _hair_outline_off else (s as Node).get_meta(&"ink_mat", _outline_mat)
			continue
		(s as MeshInstance3D).visible = not _hair_outline_off\
		and not _shell_lod_hidden and (mi as MeshInstance3D).visible




func _measure_hair_yrange() -> Vector2:
	return _measure_yrange(_hair_root)




func _measure_yrange(root: Node3D) -> Vector2:
	if root == null or not is_instance_valid(root):
		return Vector2(0.0, 1.0)
	var root_inv: = root.global_transform.affine_inverse()
	var lo: = INF
	var hi: = - INF
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
			var mi: = n as MeshInstance3D
			var rel: = root_inv * mi.global_transform
			var box: = rel * mi.mesh.get_aabb()
			lo = minf(lo, box.position.y)
			hi = maxf(hi, box.position.y + box.size.y)
		for c in n.get_children():
			stack.append(c)
	if not is_finite(lo) or hi <= lo:
		return Vector2(0.0, 1.0)
	return Vector2(lo, hi)




func _push_hair_anchor() -> void :
	if _hair_root == null or not is_instance_valid(_hair_root):
		return
	var inv: = _hair_root.global_transform.affine_inverse()
	for m in _hair_mats:
		(m as ShaderMaterial).set_shader_parameter("grad_root_inv", inv)



func tick_hair_gradient() -> void :
	if _hair_grad_active:
		_push_hair_anchor()

	if _acc_grad_active:
		for slot in _acc_mats:
			_push_acc_anchor(slot)



func hair_slot_count() -> int:
	return _hair_mats.size()

func hair_slot_default(i: int) -> Color:
	return _hair_defaults[i] if i >= 0 and i < _hair_defaults.size() else Color.WHITE





static func _hat_slot(cfg: CharacterConfig) -> String:
	var fit: = ""
	for slot in CharacterConfig.acc_slots_of("head"):
		var item: = AccessoryCatalog.by_id(cfg.acc_id(slot))
		if item == null:
			continue
		if item.hair_mode == AccessoryItem.HAIR_FULL:
			return slot
		if fit == "" and item.fit_to_hair and not item.sit_on_hair:
			fit = slot
	return fit


static func _hat_hair_mode(cfg: CharacterConfig) -> String:
	var mode: = AccessoryItem.HAIR_NORMAL
	for slot in CharacterConfig.acc_slots_of("head"):
		var item: = AccessoryCatalog.by_id(cfg.acc_id(slot))
		if item == null:
			continue
		if item.hair_mode == AccessoryItem.HAIR_FULL:
			return AccessoryItem.HAIR_FULL
		if item.hair_mode == AccessoryItem.HAIR_TOP:
			mode = AccessoryItem.HAIR_TOP
	return mode

func set_accessories(cfg: CharacterConfig) -> void :




	if _head_mount == null:
		return
	_acc_grad_active = false
	for slot in CharacterConfig.ACC_SLOTS:
		var id: = cfg.acc_id(slot)


		var flip: = cfg.acc_flip(slot)
		if id != String(_acc_ids.get(slot, "")) or flip != bool(_acc_flipped.get(slot, false)):
			_mount_accessory(slot, id, flip)
		_pose_accessory(slot, cfg)
		_tint_accessory(slot, cfg)

		var root = _acc_roots.get(slot, null)
		if root != null and is_instance_valid(root):
			var meshes: Array = []
			_collect_meshes(root, meshes)
			_fit_to_head(meshes, cfg.head_shape)

	_apply_hair_hat_mode(_hat_hair_mode(cfg))



	for slot in CharacterConfig.acc_slots_of("head"):
		_fit_hat_to_hair(cfg, AccessoryCatalog.by_id(cfg.acc_id(slot)), slot)



	var hat_slot: = _hat_slot(cfg)
	var hat_item: = AccessoryCatalog.by_id(cfg.acc_id(hat_slot)) if hat_slot != "" else null
	var hood: = hat_item != null and hat_item.hair_mode == AccessoryItem.HAIR_FULL
	_tuck_hair_under(hat_item, hood, hat_slot if hat_slot != "" else "head")

func _mount_accessory(slot: String, id: String, flip: = false) -> void :
	_acc_ids[slot] = id
	_acc_flipped[slot] = flip
	var old = _acc_roots.get(slot, null)
	if old != null and is_instance_valid(old):
		old.queue_free()


		_scrub_shell_maps()
	_acc_roots.erase(slot)
	_acc_mats[slot] = []
	_drop_jiggle(slot)
	_acc_yrange.erase(slot)
	_acc_shell_meshes.erase(slot)
	_acc_groups.erase(slot)
	var item: = AccessoryCatalog.by_id(id)
	if item == null or item.mesh == null:
		return
	var root: = item.mesh.instantiate() as Node3D
	if root == null:
		return
	if flip:
		_mirror_hair(root)
	_acc_mount(item).add_child(root)
	_acc_roots[slot] = root


	var groups: = AccessoryItem.build_groups(root)
	var mats: Array = []
	for i in groups.size():
		var g = groups[i]



		if item.is_color_locked(i):
			mats.append(null)
			continue


		var mat: = _hair_material(AccessoryItem._albedo_of(g["src"]))
		mat.set_shader_parameter("rim_scale", 1.0)
		for t in g["targets"]:
			var mi: MeshInstance3D = t[0]
			mi.set_surface_override_material(int(t[1]), mat)
		mats.append(mat)
	_acc_mats[slot] = mats
	_acc_groups[slot] = groups
	_acc_yrange[slot] = _measure_yrange(root)




	_add_jiggle(root, slot, maxf(item.jiggle_stiffness, 0.05), 
		maxf(item.jiggle_damping, 0.05), item.jiggle_gravity, item.jiggle_swing, 
		item.mount == "chest")



	if not item.flap_bones.is_empty():
		for sk in root.find_children("*", "Skeleton3D", true, false):
			var flapper: Node = ACC_FLAPPER.new()
			flapper.name = "Flap"
			flapper.flaps_per_s = item.flap_speed
			flapper.angle_deg = item.flap_angle
			flapper.axis = item.flap_axis
			if flapper.setup(sk as Skeleton3D, item.flap_bones):
				root.add_child(flapper)

				for j in _jiggles:
					if j["skel"] == sk:
						j["flap"] = flapper
			else:
				flapper.free()



	_acc_pivot[slot] = _accessory_centre(root)


	for part in item.spin_parts:
		var mi: = root.find_child(part, true, false) as Node3D
		if mi != null:
			var pivot: Node3D = ACC_SPINNER.new()
			pivot.name = part + " Spin"
			pivot.rev_per_s = item.spin_speed
			var at: = mi.transform
			mi.get_parent().add_child(pivot)
			pivot.transform = at
			mi.reparent(pivot, false)
			mi.transform = Transform3D.IDENTITY




	var meshes: Array = []
	_collect_meshes(root, meshes)
	if not _reflection:
		if Ink.active():
			_build_acc_proxies(meshes)
		elif not GameConfig.style_is(GameConfig.ArtStyle.WII):
			_queue_highlight(meshes)
			_build_outlines(meshes, OUTLINE_WIDTH / _base_scale)
			_acc_shell_meshes[slot] = meshes




func _acc_mount(item: AccessoryItem) -> BoneAttachment3D:
	if item.mount != "chest":
		return _head_mount
	if _chest_mount == null or not is_instance_valid(_chest_mount):
		var spine: = -1
		for cand in SPINE_BONES:
			spine = _skel.find_bone(cand)
			if spine >= 0:
				break
		if spine < 0:
			return _head_mount
		_chest_mount = BoneAttachment3D.new()
		_chest_mount.name = "Chest Mount"
		_chest_mount.bone_idx = spine
		_skel.add_child(_chest_mount)
	return _chest_mount




func _accessory_centre(root: Node3D) -> Vector3:
	var acc: = {"box": AABB(), "has": false}
	_collect_accessory_aabb(root, Transform3D.IDENTITY, acc, true)
	return (acc["box"] as AABB).get_center() if acc["has"] else Vector3.ZERO

func _collect_accessory_aabb(node: Node, parent_xform: Transform3D, 
		acc: Dictionary, is_root: bool) -> void :
	var xform: = parent_xform
	if node is Node3D and not is_root:
		xform = parent_xform * (node as Node3D).transform
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var b: = xform * (node as MeshInstance3D).mesh.get_aabb()
		acc["box"] = b if not acc["has"] else (acc["box"] as AABB).merge(b)
		acc["has"] = true
	for c in node.get_children():
		_collect_accessory_aabb(c, xform, acc, false)

func _pose_accessory(slot: String, cfg: CharacterConfig) -> void :
	var root = _acc_roots.get(slot, null)
	if root == null or not is_instance_valid(root):
		return
	var item: = AccessoryCatalog.by_id(cfg.acc_id(slot))
	if item == null:
		return


	var rest: = _skel.get_bone_global_rest(_acc_mount(item).bone_idx)
	var base: = rest.affine_inverse()


	var rad: float = _head_radii.x
	var pos: = item.anchor_offset * rad
	pos.x += (cfg.acc_val(slot, "px") - 0.5) * 2.0 * item.pos_range.x * rad
	pos.y += (cfg.acc_val(slot, "py") - 0.5) * 2.0 * item.pos_range.y * rad
	pos.z += (cfg.acc_val(slot, "pz") - 0.5) * 2.0 * item.pos_range.z * rad
	var deg: = Vector3(
		item.anchor_rotation.x + (cfg.acc_val(slot, "rx") - 0.5) * 2.0 * item.rot_range.x, 
		item.anchor_rotation.y + (cfg.acc_val(slot, "ry") - 0.5) * 2.0 * item.rot_range.y, 
		item.anchor_rotation.z + (cfg.acc_val(slot, "rz") - 0.5) * 2.0 * item.rot_range.z)




	var base_scl: = item.anchor_scale * _acc_scale(item, cfg.acc_val(slot, "sc"))
	var scl: = Vector3(
		clampf(base_scl * _acc_axis(cfg.acc_val(slot, "sx")), 0.35, 2.2), 
		clampf(base_scl * _acc_axis(cfg.acc_val(slot, "sy")), 0.35, 2.2), 
		clampf(base_scl * _acc_axis(cfg.acc_val(slot, "sz")), 0.35, 2.2))




	var rs: = Basis.from_euler(deg * (PI / 180.0)) * Basis.from_scale(scl)
	var pivot: Vector3 = _acc_pivot.get(slot, Vector3.ZERO)






	var flip: = bool(_acc_flipped.get(slot, false))
	if flip:
		pivot.x = - pivot.x
	var place: = Transform3D(rs, pos + pivot - rs * pivot)


	var fit: float = _acc_fit.get(slot, 1.0)
	if fit != 1.0:
		place = Transform3D(Basis.from_scale(Vector3.ONE * fit), 
			_head_centre - _head_centre * fit) * place

	var lift: float = _acc_lift.get(slot, 0.0)
	if lift != 0.0:
		place = Transform3D(Basis(), Vector3(0.0, lift, 0.0)) * place
	root.transform = base * (_mirror_xf(place) if flip else place)



func _acc_scale(item: AccessoryItem, s: float) -> float:
	if s <= 0.5:
		return lerpf(item.scale_min, 1.0, clampf(s * 2.0, 0.0, 1.0))
	return lerpf(1.0, item.scale_max, clampf((s - 0.5) * 2.0, 0.0, 1.0))




func _acc_axis(s: float) -> float:
	if s <= 0.5:
		return lerpf(0.6, 1.0, clampf(s * 2.0, 0.0, 1.0))
	return lerpf(1.0, 1.6, clampf((s - 0.5) * 2.0, 0.0, 1.0))

func _tint_accessory(slot: String, cfg: CharacterConfig) -> void :
	var mats: Array = _acc_mats.get(slot, [])
	var item: = AccessoryCatalog.by_id(cfg.acc_id(slot))
	var yr: Vector2 = _acc_yrange.get(slot, Vector2(0.0, 1.0))
	for i in mats.size():
		if mats[i] == null:
			continue
		var fallback: Color = item.default_color(i) if item != null else Color.WHITE
		var mat: = mats[i] as ShaderMaterial
		var top: Color = cfg.acc_color(slot, i, fallback)
		mat.set_shader_parameter("albedo", top)


		var on: = cfg.acc_gradient_on(slot, i)
		mat.set_shader_parameter("grad_on", 1.0 if on else 0.0)
		if on:
			_acc_grad_active = true
			var fade: Vector2 = cfg.acc_gradient_fade(slot, i)
			mat.set_shader_parameter("top_color", top)
			mat.set_shader_parameter("bottom_color", 
				cfg.acc_gradient_bottom(slot, i, top.darkened(0.4)))
			mat.set_shader_parameter("grad_y_min", yr.x)
			mat.set_shader_parameter("grad_y_max", yr.y)
			mat.set_shader_parameter("grad_fade_start", fade.x)
			mat.set_shader_parameter("grad_fade_end", fade.y)
	if _acc_grad_active:
		_push_acc_anchor(slot)





	var groups: Array = _acc_groups.get(slot, [])
	for i in mini(groups.size(), mats.size()):
		var dark: = false
		if mats[i] != null:
			var fb: Color = item.default_color(i) if item != null else Color.WHITE
			var c: Color = cfg.acc_color(slot, i, fb)
			dark = _near_black(c) and ( not cfg.acc_gradient_on(slot, i)
				or _near_black(cfg.acc_gradient_bottom(slot, i, c.darkened(0.4))))

		if item != null and item.no_outline.has(i):
			dark = true
		for t in groups[i]["targets"]:
			var mi = t[0]
			var shell = _shells.get(mi) if is_instance_valid(mi) else null
			if shell == null or not is_instance_valid(shell):
				continue
			var sh: = shell as MeshInstance3D
			if sh.material_override != null:

				var base: = sh.material_override
				sh.material_override = null
				for si in sh.mesh.get_surface_count():
					sh.set_surface_override_material(si, base)

			var off_mat: Material = _contour_only(head_stencil_id())\
			if GameConfig.contour_outline else _invisible()
			sh.set_surface_override_material(int(t[1]), 
				off_mat if dark else sh.get_meta(&"ink_mat", _outline_mat))



func acc_outline_shown(slot: String, i: = -1) -> bool:
	var groups: Array = _acc_groups.get(slot, [])
	for gi in groups.size():
		if i >= 0 and gi != i:
			continue
		for t in groups[gi]["targets"]:
			var mi = t[0]
			var s = _shells.get(mi) if is_instance_valid(mi) else null
			if s == null or not is_instance_valid(s) or not (s as MeshInstance3D).visible:
				continue
			var m: Material = (s as MeshInstance3D).get_surface_override_material(int(t[1]))
			if (s as MeshInstance3D).material_override != null or m != _invisible():
				return true
	return false



func _push_acc_anchor(slot: String) -> void :
	var root = _acc_roots.get(slot, null)
	if root == null or not is_instance_valid(root):
		return
	var inv: = (root as Node3D).global_transform.affine_inverse()
	for m in _acc_mats.get(slot, []):
		if m != null:
			(m as ShaderMaterial).set_shader_parameter("grad_root_inv", inv)

func _apply_hair_hat_mode(mode: String) -> void :





	if _hair_root == null or not is_instance_valid(_hair_root):
		return
	var top: = 1.0 if mode == AccessoryItem.HAIR_TOP else 0.0
	var full: = 1.0 if mode == AccessoryItem.HAIR_FULL else 0.0
	var hidden: = {}
	if mode == AccessoryItem.HAIR_TOP:
		hidden = {"Hair_Top": true, "Hair_Bangs": true}
	elif mode == AccessoryItem.HAIR_FULL:
		hidden = {"Hair_Top": true, "Hair_Bangs": true, 
			"Hair_Sides": true, "Hair_Back": true}
	_drive_hair_hat(_hair_root, top, full, hidden)







func drive_cloth(delta: float, vel_y: float, grounded: bool, air_boost: float, 
		diving: bool, knocked_down: bool, tilt_x: = 0.0) -> void :


	if _cloth_targets.is_empty() or ( not _cloth_on and not _pinny_worn):
		return






	var size: = clampf(lerpf(0.55, 1.2, air_boost), 0.55, 1.4)
	var rising: = clampf(vel_y / 5.0, 0.0, 1.0) if not grounded else 0.0
	var falling: = clampf( - vel_y / 4.0, 0.0, 1.0) if not grounded else 0.0
	var lift: = 0.0
	var flare: = 0.0
	var drop: = 0.0
	if not grounded:
		lift = (1.0 - falling * 0.85) * size
		flare = (0.6 + 0.4 * rising) * size
		drop = falling * 0.35
	if diving:
		drop = maxf(drop, 0.7)
		lift = 0.0
		flare = 0.0
	elif knocked_down:
		lift = maxf(lift, 0.3)

	if grounded and _cloth_was_air:
		_cloth_land = 1.0
	_cloth_was_air = not grounded
	_cloth_land = maxf(_cloth_land - delta / 0.22, 0.0)
	drop = maxf(drop, _cloth_land * 0.9)
	var bl: = clampf(tilt_x, 0.0, 1.0) * 0.6 if not grounded else 0.0
	var br: = clampf( - tilt_x, 0.0, 1.0) * 0.6 if not grounded else 0.0
	var targets: = [minf(lift, 1.35), minf(flare, 1.35), minf(drop, 1.0), bl, br]
	for i in 5:
		var t: float = targets[i]
		var cur: float = _cloth[i]
		var tau: = CLOTH_ATTACK if t > cur else CLOTH_RELEASE
		_cloth[i] = lerpf(cur, t, 1.0 - exp( - delta / maxf(tau, 0.005)))
	_push_cloth()



func _mesh_is_pinny(mi: MeshInstance3D) -> bool:
	if mi == null or mi.mesh == null:
		return false
	for si in mi.mesh.get_surface_count():
		var sm: = mi.mesh.surface_get_material(si)
		if sm != null and sm.resource_name.to_lower().begins_with("practice_jersey"):
			return true
	return false

func _push_cloth() -> void :
	for entry in _cloth_targets:
		var mi: MeshInstance3D = entry[0]
		var idxs: Array = entry[1]


		var is_pinny: bool = entry.size() > 2 and bool(entry[2])
		var active: = _pinny_worn if is_pinny else _cloth_on
		for i in idxs.size():
			if int(idxs[i]) >= 0:
				mi.set_blend_shape_value(int(idxs[i]), _cloth[i] if active else 0.0)

func _drive_hair_hat(node: Node, top: float, full: float, hidden: Dictionary) -> void :
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mi: = node as MeshInstance3D
		var ti: = mi.find_blend_shape_by_name("Hat_TopCovered")
		if ti >= 0:
			mi.set_blend_shape_value(ti, top)
		var fi: = mi.find_blend_shape_by_name("Hat_FullCovered")
		if fi >= 0:
			mi.set_blend_shape_value(fi, full)



		if String(mi.name).begins_with("Hair_"):
			var vis: = not hidden.has(String(mi.name))
			mi.visible = vis
			for map in [_shells, _hl_shells]:
				if map.has(mi) and is_instance_valid(map[mi]):
					(map[mi] as MeshInstance3D).visible = vis
	for c in node.get_children():
		_drive_hair_hat(c, top, full, hidden)




func _add_jiggle(root: Node, owner: String, stiff_mul: = 1.0, drag_mul: = 1.0, 
		grav_mul: = 1.0, swing: = 1.0, body: = false) -> void :
	var found: Array = []
	_scan_tails_into(root, found)
	for f in found:
		var sk: Skeleton3D = f["skel"]
		var chains: Array = f["chains"]

		sk.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL
		var sim: = SpringBoneSimulator3D.new()
		sim.name = "Jiggle"
		sk.add_child(sim)


		var cols: Array = [SpringBoneCollisionSphere3D.new(), 
			SpringBoneCollisionCapsule3D.new(), SpringBoneCollisionCapsule3D.new()]
		var col_names: = ["Head", "Torso", "Shoulders"]
		for ci in cols.size():
			cols[ci].name = col_names[ci]
			sim.add_child(cols[ci])



		for i in chains.size():
			var c0: Array = chains[i]
			if c0.size() >= 2 and _is_spike(sk, c0[0]):
				chains[i] = c0.slice(1)
		var limit: = JiggleLimit.new()
		limit.name = "JiggleLimit"
		var params: Array = []
		sim.setting_count = chains.size()





		var locks: = 0
		for c1 in chains:
			if (c1 as Array).size() >= 2 and not _is_spike(sk, c1[0]) and not _is_mass(sk, c1[0]):
				locks += 1
		var bundle: = locks >= JIGGLE_LOCKS_MIN
		for i in chains.size():
			var idx: Array = chains[i]
			var first: int = idx[0]
			var last: int = idx[idx.size() - 1]
			sim.set_root_bone(i, first)
			sim.set_end_bone(i, last)




			var seg: = (sk.get_bone_global_rest(last).origin
				- sk.get_bone_global_rest(sk.get_bone_parent(last)).origin).length()
			sim.set_extend_end_bone(i, true)
			sim.set_end_bone_direction(i, SkeletonModifier3D.BONE_DIRECTION_PLUS_Y)
			sim.set_end_bone_length(i, seg)

			var span: = sk.get_bone_global_rest(last).origin - sk.get_bone_global_rest(first).origin
			var hang: = clampf( - span.normalized().y, 0.0, 1.0) if span.length() > 0.0001 else 1.0
			var sprung: = lerpf(JIGGLE_SPRUNG_STIFF, 1.0, clampf(hang / 0.5, 0.0, 1.0))
			var spike: = _is_spike(sk, first)
			var mass: = _is_mass(sk, first)
			var lock: = bundle and not spike and not mass and idx.size() >= 2
			for b in idx:
				limit.add_bone(sk, b, JIGGLE_MASS_MAX_ANGLE if mass
					else JIGGLE_SPIKE_MAX_ANGLE if spike
					else JIGGLE_LOCK_ROOT_ANGLE if lock and b == first else JIGGLE_MAX_ANGLE)
			var stiff: = JIGGLE_MASS_STIFF if mass else JIGGLE_SPIKE_STIFF if spike else JIGGLE_STIFF * sprung
			var drag: = JIGGLE_MASS_DRAG if mass else JIGGLE_SPIKE_DRAG if spike else JIGGLE_DRAG
			var hang_grav: = JIGGLE_GRAVITY * maxf(JIGGLE_SPRUNG_MIN_GRAV, hang)
			var grav: = JIGGLE_MASS_GRAVITY if mass else JIGGLE_SPIKE_GRAVITY if spike else hang_grav
			sim.set_stiffness(i, stiff * stiff_mul / maxf(swing, 0.2))
			params.append([stiff * stiff_mul / maxf(swing, 0.2), 
				clampf(drag * drag_mul, 0.0, 1.0), grav * grav_mul, 
				JIGGLE_LOCK_ROOT_STIFF if lock else 1.0])





			if idx.size() >= 2:
				sim.set_stiffness_damping_curve(i, _jiggle_tip_curve())
			sim.set_drag(i, clampf(drag * drag_mul, 0.0, 1.0))
			sim.set_gravity(i, grav * grav_mul)
			sim.set_gravity_direction(i, Vector3.DOWN)

			sim.set_radius(i, minf(_head_radii.x, _head_radii.z) * JIGGLE_JOINT_R
				* sk.global_basis.get_scale().x)
			sim.set_rotation_axis(i, SkeletonModifier3D.ROTATION_AXIS_ALL)
			sim.set_enable_all_child_collisions(i, true)

		sk.add_child(limit)



		var meshes: Array = []
		_collect_meshes(root, meshes)
		meshes = meshes.filter( func(m): return (m as MeshInstance3D).skin != null\
		and (m as MeshInstance3D).get_node_or_null((m as MeshInstance3D).skeleton) == sk)
		_jiggles.append({"owner": owner, "skel": sk, "sim": sim, "chains": chains, "cols": cols, "meshes": meshes, 
			"head_r": -1.0, "limit": limit, "params": params, "body": body})
	_jiggle_reset = true

static func _is_spike(sk: Skeleton3D, b: int) -> bool:
	return String(sk.get_bone_name(b)).to_lower().begins_with("tail_spike")

static func _is_mass(sk: Skeleton3D, b: int) -> bool:
	return String(sk.get_bone_name(b)).to_lower().begins_with("tail_mass")






class HeadField extends RefCounted:
	const NU: = 64
	const NV: = 32
	const STEP: = 0.04
	const U_SCALE: = NU / TAU
	const V_SCALE: = NV / PI
	var _r: = PackedFloat32Array()
	var _skin: = PackedByteArray()

	static func build(mesh: ArrayMesh, centre: Vector3, radii: Vector3) -> HeadField:
		var f: = HeadField.new()
		f._r.resize(NU * NV)
		f._r.fill(0.0)
		for s in mesh.get_surface_count():
			var a: = mesh.surface_get_arrays(s)
			var idx: PackedInt32Array = a[Mesh.ARRAY_INDEX]
			var sets: Array = [a[Mesh.ARRAY_VERTEX]]

			for bs in mesh.surface_get_blend_shape_arrays(s):
				sets.append(bs[Mesh.ARRAY_VERTEX])
			for vs in sets:
				var v: PackedVector3Array = vs
				var n: = idx.size() if idx.size() > 0 else v.size()
				for t in range(0, n - 2, 3):
					var i0: = idx[t] if idx.size() > 0 else t
					var i1: = idx[t + 1] if idx.size() > 0 else t + 1
					var i2: = idx[t + 2] if idx.size() > 0 else t + 2
					f._splat(v[i0] - centre, v[i1] - centre, v[i2] - centre)
		f._skin.resize(NU * NV)
		for i in NU * NV:
			f._skin[i] = 1 if f._r[i] > 0.0 else 0
		f._fill(radii)
		return f


	func _splat(a: Vector3, b: Vector3, c: Vector3) -> void :
		var k: = maxi(1, ceili(maxf(a.distance_to(b), maxf(b.distance_to(c), c.distance_to(a))) / STEP))
		for i in k + 1:
			for j in k + 1 - i:
				var p: = a + (b - a) * (float(i) / k) + (c - a) * (float(j) / k)
				var l: = p.length()
				if l < 1e-06:
					continue
				var bi: = _bin(p / l)
				if l > _r[bi]:
					_r[bi] = l

	func _bin(d: Vector3) -> int:
		var u: = int((atan2(d.x, d.z) + PI) / TAU * NU) % NU
		var v: = clampi(int(acos(clampf(d.y, -1.0, 1.0)) / PI * NV), 0, NV - 1)
		return v * NU + u


	func _fill(radii: Vector3) -> void :
		var src: = _r.duplicate()
		for v in NV:
			for u in NU:
				if src[v * NU + u] > 0.0:
					continue
				var m: = 0.0
				for dv in [-1, 0, 1]:
					for du in [-1, 0, 1]:
						var vv: int = v + dv
						if vv >= 0 and vv < NV:
							m = maxf(m, src[vv * NU + (u + du + NU) % NU])
				_r[v * NU + u] = m
		for v in NV:
			for u in NU:
				if _r[v * NU + u] > 0.0:
					continue
				var th: = (float(v) + 0.5) / NV * PI
				var ph: = (float(u) + 0.5) / NU * TAU - PI
				var d: = Vector3(sin(th) * sin(ph), cos(th), sin(th) * cos(ph))
				_r[v * NU + u] = 1.0 / Vector3(d.x / radii.x, d.y / radii.y, d.z / radii.z).length()


	func radius(d: Vector3) -> float:
		var u: = (atan2(d.x, d.z) + PI) / TAU * NU - 0.5
		var v: = clampf(acos(clampf(d.y, -1.0, 1.0)) / PI * NV - 0.5, 0.0, NV - 1.0)
		var u0: = floori(u)
		var v0: = mini(int(v), NV - 2)
		var fu: = u - u0
		var fv: = v - v0
		var ua: = (u0 % NU + NU) % NU
		var ub: = (ua + 1) % NU
		var r0: = lerpf(_r[v0 * NU + ua], _r[v0 * NU + ub], fu)
		var r1: = lerpf(_r[(v0 + 1) * NU + ua], _r[(v0 + 1) * NU + ub], fu)
		return lerpf(r0, r1, clampf(fv, 0.0, 1.0))


	func has_skin(d: Vector3) -> bool:
		return _skin[_bin(d)] == 1



	func ratio(q: Vector3) -> float:
		var l: = q.length()
		if l < 1e-06:
			return 0.0
		return l / radius(q / l)

static var _head_fields: = {}

func _head_field() -> HeadField:
	if _head_mesh == null:
		return null
	if not _head_fields.has(_head_mesh):
		_head_fields[_head_mesh] = HeadField.build(_head_mesh, _head_centre, _head_radii)
	return _head_fields[_head_mesh]





class JiggleLimit extends SkeletonModifier3D:
	var push: = true
	var _bones: = PackedInt32Array()
	var _rest: Array[Quaternion] = []
	var _max: = PackedFloat32Array()




	var _len: = PackedFloat32Array()
	var _floor: = PackedFloat32Array()
	var _floor_mid: = PackedFloat32Array()
	var _head: = Transform3D()
	var _head_inv: = Transform3D()
	var _field: HeadField = null
	var _fr: = PackedFloat32Array()
	var _has_head: = false





	var _pts: Array[PackedVector3Array] = []
	var _ploc: Array[PackedVector3Array] = []
	var _pown: Array[PackedFloat32Array] = []
	var _pstill: Array[PackedVector3Array] = []
	var _pf: Array[PackedFloat32Array] = []
	var _pd: Array[PackedFloat32Array] = []
	var _pfor: Array[Dictionary] = []
	var _parent: = PackedInt32Array()





	var _proom: Array[PackedFloat32Array] = []
	var _rest_inv: Array[Transform3D] = []

	var _prev: Array[Transform3D] = []
	var _now: Array[Transform3D] = []
	var _dshift: = PackedFloat32Array()
	var _dturn: = PackedFloat32Array()


	var _lastpush: = PackedFloat32Array()


	var _torso_a: = Vector3.ZERO
	var _torso_b: = Vector3.ZERO
	var _torso_r: = 0.0

	const MAX_PUSH: = 1.2
	const PUSH_STEP: = 0.05


	const ROOM_SAFE: = 0.7

	var _torso_allow: = PackedFloat32Array()

	func set_torso(a: Vector3, b: Vector3, r: float) -> void :
		_torso_a = a
		_torso_b = b
		_torso_r = r

	func set_head(head_in_skel: Transform3D, field: HeadField) -> void :
		_head = head_in_skel
		_head_inv = head_in_skel.affine_inverse()
		_field = field
		_has_head = field != null
		if field != null:
			_fr = field._r

	func set_bone_head(b: int, length: float, floor_tail: float, floor_mid: float) -> void :
		var i: = _bones.find(b)
		if i >= 0:
			_len[i] = length
			_floor[i] = floor_tail
			_floor_mid[i] = floor_mid

	func _e(p: Vector3) -> float:
		return _ratio(_head_inv * p)

	func set_bone_points(b: int, pts: PackedVector3Array, floors: PackedFloat32Array, 
			infl: Array) -> void :
		var i: = _bones.find(b)
		if i < 0 or _field == null:
			return
		var loc: = PackedVector3Array()
		var own: = PackedFloat32Array()
		var still: = PackedVector3Array()
		var d: = PackedFloat32Array()
		var room: = PackedFloat32Array()
		var foreign: = {}
		for k in pts.size():
			var p0: = pts[k]
			var bs: PackedInt32Array = infl[k][0]
			var ws: PackedFloat32Array = infl[k][1]



			var ps: PackedVector3Array = infl[k][2] if (infl[k] as Array).size() > 2 else PackedVector3Array()
			var w_own: = 0.0
			var w_all: = 0.0
			var p_own: = p0
			var fb: = PackedInt32Array()
			var fw: = PackedFloat32Array()
			var fd: = PackedFloat32Array()
			var fp: = PackedVector3Array()
			var fc: = PackedByteArray()



			var undriven: = Vector3.ZERO
			for n in bs.size():
				w_all += ws[n]
				var pn: = ps[n] if not ps.is_empty() else p0
				if bs[n] == b:
					w_own += ws[n]
					p_own = pn
				else:
					var at: = _bones.find(bs[n])
					if at < 0:
						undriven += pn * ws[n]
						continue
					fb.append(at)
					fw.append(ws[n])
					fd.append((_rest_inv[at] * pn).length())
					fp.append(pn)
					fc.append(1 if _below(at, i) else 0)
			if not fb.is_empty():
				foreign[k] = [fb, fw, fd, fp, fc]
			loc.append(_rest_inv[i] * p_own)
			own.append(w_own)
			if (infl[k] as Array).size() > 3:
				still.append((infl[k][3] as Vector3) + undriven)
			else:
				still.append(p0 * maxf(1.0 - w_all, 0.0) + undriven)
			d.append(loc[k].length())





			var rebuilt: Vector3 = still[k] + _rest_inv[i].affine_inverse() * loc[k] * w_own
			for n in fb.size():
				rebuilt += fp[n] * fw[n]
			floors[k] = minf(floors[k], _field.ratio(_head_inv * rebuilt) - 0.003)

			var q: = _head_inv * p0
			var e: = _field.ratio(q)
			room.append(maxf(e - floors[k], 0.0) / maxf(e, 0.001) * q.length() * ROOM_SAFE)
		_pts[i] = pts
		_ploc[i] = loc
		_pown[i] = own
		_pstill[i] = still
		_pf[i] = floors
		_pd[i] = d
		_pfor[i] = foreign
		_proom[i] = room


	func _track(i: int, g: Transform3D) -> void :
		_now[i] = g
		var p: = _prev[i]
		_dshift[i] = g.origin.distance_to(p.origin)
		var dq: = (g.basis.orthonormalized() * p.basis.orthonormalized().inverse()).get_rotation_quaternion()
		if dq.w < 0.0:
			dq = - dq
		_dturn[i] = dq.get_angle()


	func _below(a: int, i: int) -> bool:
		var at: = _parent[a]
		while at >= 0:
			if at == i:
				return true
			at = _parent[at]
		return false





	func _base(i: int, k: int) -> Array:
		var q: = _pstill[i][k]
		var cq: = Vector3.ZERO
		var cw: = 0.0
		var fo: Dictionary = _pfor[i]
		if fo.has(k):
			var e: Array = fo[k]
			var bs: PackedInt32Array = e[0]
			var ws: PackedFloat32Array = e[1]
			var ps: PackedVector3Array = e[3]
			var fc: PackedByteArray = e[4]
			for n in bs.size():
				var at: = _now[bs[n]] * _rest_inv[bs[n]] * ps[n]
				if fc[n] == 1:
					cq += at * ws[n]
					cw += ws[n]
				else:
					q += at * ws[n]
		if cw > 0.0:
			cq = _now[i].affine_inverse() * (cq / cw)
		return [q, cq, cw]



	func _ratio(q: Vector3) -> float:
		var l: = q.length()
		if l < 1e-06:
			return 0.0
		var ux: = (atan2(q.x, q.z) + PI) * HeadField.U_SCALE - 0.5
		var vy: = clampf(acos(clampf(q.y / l, -1.0, 1.0)) * HeadField.V_SCALE - 0.5, 
			0.0, HeadField.NV - 1.0)
		var u0: = floori(ux)
		var v0: = mini(int(vy), HeadField.NV - 2)
		var fu: = ux - u0
		var fv: = minf(vy - v0, 1.0)
		var ua: = posmod(u0, HeadField.NU)
		var ub: = (ua + 1) % HeadField.NU
		var r0: = v0 * HeadField.NU
		var r1: = r0 + HeadField.NU
		return l / lerpf(lerpf(_fr[r0 + ua], _fr[r0 + ub], fu), 
			lerpf(_fr[r1 + ua], _fr[r1 + ub], fu), fv)






	var _bases: = {}

	func _slack(i: int, o: Vector3, basis: Basis, v: Vector3, extra: float) -> float:
		var worst: = minf(_e(o + v) - _floor[i], _e(o + v * 0.5) - _floor_mid[i])
		var loc: = _ploc[i]
		var own: = _pown[i]
		var f: = _pf[i]
		var d: = _pd[i]
		var room: = _proom[i]
		for k in loc.size():
			if own[k] * extra * d[k] < room[k]:
				continue
			if not _bases.has(k):
				_bases[k] = _base(i, k)
			var bk: Array = _bases[k]
			var at: Vector3 = bk[0] + (o + basis * loc[k]) * own[k]
			if bk[2] > 0.0:
				at += (o + basis * (bk[1] as Vector3)) * float(bk[2])
			var q: = _head_inv * at
			var e: = _ratio(q)
			var c: = e - f[k]
			worst = minf(worst, c)
			if extra == 0.0:
				room[k] = maxf(c, 0.0) / maxf(e, 0.001) * q.length() * ROOM_SAFE
		if extra == 0.0:
			_proom[i] = room
		return worst

	func _slack_at(i: int, g: Transform3D, v: Vector3, axis: Vector3, a: float) -> float:
		var r: = Basis(axis, - a)
		return _slack(i, g.origin, r * g.basis, r * v, a)

	func add_bone(sk: Skeleton3D, b: int, max_angle: float) -> void :
		_bones.append(b)
		_parent.append(_bones.find(sk.get_bone_parent(b)))
		_rest.append(sk.get_bone_pose_rotation(b))
		_max.append(max_angle)
		_len.append(0.0)
		_floor.append(0.0)
		_floor_mid.append(0.0)
		_pts.append(PackedVector3Array())
		_ploc.append(PackedVector3Array())
		_pown.append(PackedFloat32Array())
		_pstill.append(PackedVector3Array())
		_pf.append(PackedFloat32Array())
		_pd.append(PackedFloat32Array())
		_pfor.append({})
		_proom.append(PackedFloat32Array())
		_rest_inv.append(sk.get_bone_global_rest(b).affine_inverse())
		_prev.append(sk.get_bone_global_rest(b))
		_now.append(sk.get_bone_global_rest(b))
		_dshift.append(0.0)
		_dturn.append(0.0)
		_lastpush.append(0.0)


	func cap(bones: Array, max_angle: float) -> void :
		for i in _bones.size():
			if bones.has(_bones[i]):
				_max[i] = minf(_max[i], max_angle)

	func _process_modification() -> void :
		var sk: = get_skeleton()
		if sk == null:
			return
		for i in _bones.size():
			var b: = _bones[i]
			var rest: = _rest[i]
			var rel: = rest.inverse() * sk.get_bone_pose_rotation(b)


			if rel.w < 0.0:
				rel = - rel
			var ang: = rel.get_angle()
			if ang > _max[i] and ang > 0.0001:
				sk.set_bone_pose_rotation(b, rest * Quaternion.IDENTITY.slerp(rel, _max[i] / ang))




		if not push:
			return
		if _has_head:
			_push_out_of_head(sk)
		if _torso_r > 0.0:
			_push_out_of_torso(sk)

		for i in _bones.size():
			_prev[i] = sk.get_bone_global_pose(_bones[i])




	func _push_out_of_torso(sk: Skeleton3D) -> void :



		if _torso_allow.size() != _bones.size():
			_torso_allow.resize(_bones.size())
			for i in _bones.size():
				var rest: = sk.get_bone_global_rest(_bones[i])
				var rt: = rest.origin + rest.basis.y.normalized() * _len[i]
				var d: = rt.distance_to(Geometry3D.get_closest_point_to_segment(rt, _torso_a, _torso_b))
				_torso_allow[i] = maxf(_torso_r - d, 0.0) + (0.003 if d < _torso_r else 0.0)
		for i in _bones.size():
			if _len[i] <= 0.0:
				continue
			var b: = _bones[i]
			var g: = sk.get_bone_global_pose(b)
			var v: = g.basis.y.normalized() * _len[i]
			var tail: = g.origin + v
			var q: = Geometry3D.get_closest_point_to_segment(tail, _torso_a, _torso_b)
			var keep: = _torso_r - _torso_allow[i]
			if tail.distance_to(q) >= keep:
				continue
			var axis: = v.cross(q - g.origin)
			if axis.length() < 1e-06:
				continue
			axis = axis.normalized()




			var short0: = keep - tail.distance_to(q)
			var a: = 0.0
			var best_a: = 0.0
			var best_short: = short0
			while a < MAX_PUSH:
				a += PUSH_STEP
				var t: = g.origin + v.rotated(axis, - a)
				var sh: = keep - t.distance_to(Geometry3D.get_closest_point_to_segment(t, _torso_a, _torso_b))
				if sh < best_short:
					best_short = sh
					best_a = a
				if sh <= 0.0:
					break
			if best_short > 0.0 and short0 - best_short < short0 * 0.5:
				continue
			if best_a <= 0.0:
				continue
			var turned: = Basis(axis, - best_a) * g.basis
			var parent: = sk.get_bone_parent(b)
			var pg: = sk.get_bone_global_pose(parent) if parent >= 0 else Transform3D()
			sk.set_bone_pose_rotation(b, (pg.basis.inverse() * turned).get_rotation_quaternion())






	func _push_out_of_head(sk: Skeleton3D) -> void :
		var c: = _head.origin
		for i in _bones.size():
			_track(i, sk.get_bone_global_pose(_bones[i]))
		var moved_any: = false
		for i in _bones.size():
			if _floor[i] <= 0.0 or _len[i] <= 0.0:
				continue
			var b: = _bones[i]

			if moved_any:
				_track(i, sk.get_bone_global_pose(b))
			var g: = _now[i]
			var v: = g.basis.y.normalized() * _len[i]


			var room: = _proom[i]
			var own: = _pown[i]
			var d: = _pd[i]
			var fo: Dictionary = _pfor[i]
			for k in room.size():
				var used: = own[k] * (_dshift[i] + _dturn[i] * d[k])
				if fo.has(k):
					var e: Array = fo[k]
					var bs: PackedInt32Array = e[0]
					var ws: PackedFloat32Array = e[1]
					var ds: PackedFloat32Array = e[2]
					for n in bs.size():
						used += ws[n] * (_dshift[bs[n]] + _dturn[bs[n]] * ds[n])
				room[k] -= used
			_proom[i] = room



			_bases.clear()
			var s0: = _slack(i, g.origin, g.basis, v, 0.0)
			if s0 >= 0.0:
				_lastpush[i] = 0.0
				continue
			var axis: = v.cross(c - g.origin)
			if axis.length() < 1e-06:
				continue
			axis = axis.normalized()




			var a: = clampf(snappedf(_lastpush[i], PUSH_STEP), PUSH_STEP, MAX_PUSH)
			var best_a: = 0.0
			var best_s: = s0
			var sa: = _slack_at(i, g, v, axis, a)
			if sa >= 0.0:

				best_a = a
				while a - PUSH_STEP > 0.001:
					var sb: = _slack_at(i, g, v, axis, a - PUSH_STEP)
					if sb < 0.0:
						break
					a -= PUSH_STEP
					best_a = a
			else:
				if sa > best_s:
					best_s = sa
					best_a = a
				while a < MAX_PUSH:
					a += PUSH_STEP
					sa = _slack_at(i, g, v, axis, a)
					if sa > best_s:
						best_s = sa
						best_a = a
					if sa >= 0.0:
						break




				if best_s < 0.0 and best_s - s0 < - s0 * 0.5:
					best_a = 0.0
			_lastpush[i] = best_a
			if best_a <= 0.0:
				continue
			var turned: = Basis(axis, - best_a) * g.basis
			var parent: = sk.get_bone_parent(b)
			var pg: = sk.get_bone_global_pose(parent) if parent >= 0 else Transform3D()
			sk.set_bone_pose_rotation(b, (pg.basis.inverse() * turned).get_rotation_quaternion())

			room = _proom[i]
			for k in room.size():
				room[k] -= own[k] * best_a * d[k]
			_proom[i] = room
			_now[i] = Transform3D(turned, g.origin)
			moved_any = true

func _drop_jiggle(owner: String) -> void :

	for i in range(_jiggles.size() - 1, -1, -1):
		if _jiggles[i]["owner"] == owner:
			_jiggles.remove_at(i)

static var _tip_curve: Curve = null

static func _jiggle_tip_curve() -> Curve:
	if _tip_curve == null:
		_tip_curve = Curve.new()
		_tip_curve.add_point(Vector2(0.0, 1.0))
		_tip_curve.add_point(Vector2(1.0, JIGGLE_TIP_STIFF))
	return _tip_curve





func _jiggle_fit_heads(j: Dictionary) -> bool:
	var sk: Skeleton3D = j["skel"]
	if _face_root == null or not is_instance_valid(_face_root) or not sk.is_inside_tree():
		return false
	j["head_r"] = _jiggle_head_radius() * JIGGLE_HEAD_SHRINK
	return true



static func _jiggle_tip_rest(sk: Skeleton3D, bone: int) -> Vector3:
	var rest: = sk.get_bone_global_rest(bone)
	var seg: = (rest.origin - sk.get_bone_global_rest(sk.get_bone_parent(bone)).origin).length()
	return rest.origin + rest.basis.y.normalized() * seg









func _jiggle_fit_joints(j: Dictionary, ci: int, c: Vector3, fat: float) -> void :
	var sk: Skeleton3D = j["skel"]
	var sim: = j["sim"] as SpringBoneSimulator3D
	var idx: Array = j["chains"][ci]
	var pr: Array = j["params"][ci]
	var head_r: float = j["head_r"]
	var jc: = sim.get_joint_count(ci)
	if jc <= 0:
		return
	sim.set_individual_config(ci, true)
	for jk in jc:
		var bone: = sim.get_joint_bone(ci, jk)
		var k: = idx.find(bone)
		var tail: Vector3
		if k >= 0 and k + 1 < idx.size():
			tail = sk.global_transform * sk.get_bone_global_rest(idx[k + 1]).origin
		else:
			tail = sk.global_transform * _jiggle_tip_rest(sk, bone)
		var room: = tail.distance_to(c) - head_r - 0.005


		for col in [j["cols"][1], j["cols"][2]]:
			var cap: = col as SpringBoneCollisionCapsule3D
			if cap.radius <= 0.0:
				continue
			var ax: = cap.global_basis.y.normalized() * maxf(cap.height * 0.5 - cap.radius, 0.0)
			var q: = Geometry3D.get_closest_point_to_segment(tail, cap.global_position - ax, 
				cap.global_position + ax)
			room = minf(room, tail.distance_to(q) - cap.radius - 0.005)
		sim.set_joint_radius(ci, jk, clampf(room, - head_r, fat))
		var t: = 0.0 if jc < 2 else float(jk) / float(jc - 1)
		var root_x: = float(pr[3]) if jk == 0 and pr.size() > 3 else 1.0
		sim.set_joint_stiffness(ci, jk, float(pr[0]) * lerpf(1.0, JIGGLE_TIP_STIFF, t) * root_x)
		sim.set_joint_drag(ci, jk, float(pr[1]))
		sim.set_joint_gravity(ci, jk, float(pr[2]))
		sim.set_joint_gravity_direction(ci, jk, Vector3.DOWN)
		sim.set_joint_rotation_axis(ci, jk, SkeletonModifier3D.ROTATION_AXIS_ALL)











func _jiggle_hug_caps(j: Dictionary) -> void :
	var sk: Skeleton3D = j["skel"]
	j["vy"] = 0.0
	j["dv"] = 0.0
	var c: = _face_root.global_position
	var fat: = minf(_head_radii.x, _head_radii.z) * JIGGLE_JOINT_R * sk.global_basis.get_scale().x
	var limit: = j["limit"] as JiggleLimit
	var inv: = _face_root.global_transform.affine_inverse()


	limit.set_head(sk.global_transform.affine_inverse() * _face_root.global_transform, _head_field())
	for ci in (j["chains"] as Array).size():
		var idx: Array = j["chains"][ci]
		var n: = idx.size()
		_jiggle_fit_joints(j, ci, c, fat)

		var tails: Array = []
		for k in n:
			if k + 1 < n:
				tails.append(sk.global_transform * sk.get_bone_global_rest(idx[k + 1]).origin)
			else:
				tails.append(sk.global_transform * _jiggle_tip_rest(sk, idx[k]))
		var roots: Array = []
		for k in n:
			roots.append(sk.global_transform * sk.get_bone_global_rest(idx[k]).origin)
		for k in n:
			var root: Vector3 = roots[k]
			var cap: = JIGGLE_MAX_ANGLE
			if JIGGLE_SAFE_CAPS:
				for m in range(k, n):

					for p in [tails[m], ((roots[m] as Vector3) + (tails[m] as Vector3)) * 0.5]:
						cap = minf(cap, _jiggle_safe_angle(root, p, c, inv, _jiggle_floor(inv, p)))
				cap = maxf(cap, JIGGLE_HUG_MAX_ANGLE)
			if _is_spike(sk, idx[0]):
				cap = minf(cap, JIGGLE_SPIKE_MAX_ANGLE)
			limit.cap([idx[k]], cap)

			var tail_p: Vector3 = tails[k]
			limit.set_bone_head(idx[k], root.distance_to(tail_p) / sk.global_basis.get_scale().x, 
				_jiggle_floor(inv, tail_p), _jiggle_floor(inv, (root + tail_p) * 0.5))
	_jiggle_skin_points(j, inv)





static var _skin_pts_cache: = {}

static var _skin_pts_jobs: = {}


static var pick_on_worker: = 0

func _jiggle_skin_points(j: Dictionary, inv: Transform3D) -> void :
	var bones: = {}
	for ch in j["chains"]:
		for b in ch:
			bones[b] = true
	var key: = ""
	for mi in j.get("meshes", []):
		if is_instance_valid(mi):
			key += "%d," % (mi as MeshInstance3D).mesh.get_instance_id()
	if key == "":
		return







	if not _skin_pts_cache.has(key):
		if lod_views.is_empty() and pick_on_worker <= 0:
			_skin_pts_cache[key] = _jiggle_pick_points(j, bones, inv)
		else:
			if not _skin_pts_jobs.has(key):
				var g: = _jiggle_pick_gather(j, bones, inv)
				var out: = [null]
				_skin_pts_jobs[key] = [CharacterPortrait.run_job( func():
					out[0] = _jiggle_pick_compute(g)), out]
			j["pts_key"] = key
			return
	_jiggle_apply_points(j, key)

func _jiggle_apply_points(j: Dictionary, key: String) -> void :
	var limit: = j["limit"] as JiggleLimit
	var per: Dictionary = _skin_pts_cache[key]
	for b in per:
		var e: Array = per[b]
		limit.set_bone_points(b, e[0], e[1], e[2])



func _jiggle_poll_points() -> void :
	for j in _jiggles:
		if not j.has("pts_key"):
			continue
		var key: String = j["pts_key"]
		if not _skin_pts_cache.has(key):
			var job: Array = _skin_pts_jobs.get(key, [])
			if job.is_empty() or CharacterPortrait.job_running(int(job[0])):
				continue
			_skin_pts_jobs.erase(key)
			if job[1][0] == null:
				j.erase("pts_key")
				continue
			_skin_pts_cache[key] = job[1][0]
		j.erase("pts_key")
		if is_instance_valid(j["limit"]):
			_jiggle_apply_points(j, key)

func _jiggle_pick_points(j: Dictionary, bones: Dictionary, inv: Transform3D) -> Dictionary:
	return _jiggle_pick_compute(_jiggle_pick_gather(j, bones, inv))






func _jiggle_pick_gather(j: Dictionary, bones: Dictionary, inv: Transform3D) -> Dictionary:
	var sk: Skeleton3D = j["skel"]
	var seen: = {}
	var meshes: Array = []
	for mi in j.get("meshes", []):
		if not is_instance_valid(mi) or seen.has((mi as MeshInstance3D).mesh):
			continue
		seen[(mi as MeshInstance3D).mesh] = true
		var skin: Skin = (mi as MeshInstance3D).skin
		var binds: Array = []
		for bi in skin.get_bind_count():
			var b: = skin.get_bind_bone(bi)
			if b < 0:
				b = sk.find_bone(skin.get_bind_name(bi))
			binds.append([b, sk.get_bone_global_rest(b) * skin.get_bind_pose(bi)])
		var mesh: Mesh = (mi as MeshInstance3D).mesh
		var arrays: Array = []
		for si in mesh.get_surface_count():
			arrays.append(mesh.surface_get_arrays(si))
		meshes.append({"binds": binds, "arrays": arrays})
	return {"to_world": sk.global_transform, "inv": inv, "bones": bones, 
		"hf": _head_field(), "meshes": meshes}

static func _jiggle_pick_compute(g: Dictionary) -> Dictionary:
	var to_world: Transform3D = g["to_world"]
	var inv: Transform3D = g["inv"]
	var bones: Dictionary = g["bones"]
	var hf: HeadField = g["hf"]
	var cand: = {}
	var surfs: Array = []
	var shell: = _JiggleShell.new()
	for gm in g["meshes"]:
		var binds: Array = gm["binds"]
		for a in gm["arrays"]:
			var verts: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var bw: PackedInt32Array = a[Mesh.ARRAY_BONES]
			var ww: PackedFloat32Array = a[Mesh.ARRAY_WEIGHTS]
			if bw.is_empty() or verts.is_empty():
				continue
			var per: = bw.size() / verts.size()

			var vp: = PackedVector3Array()
			vp.resize(verts.size())
			var vb: Array = []
			vb.resize(verts.size())
			for i in verts.size():
				var p: = Vector3.ZERO
				var wb: = {}
				for k in per:
					var w: = ww[i * per + k]
					if w <= 0.0:
						continue
					var bd: Array = binds[bw[i * per + k]]
					var b: int = bd[0]
					p += ((bd[1] as Transform3D) * verts[i]) * w
					if bones.has(b):
						wb[b] = float(wb.get(b, 0.0)) + w
				vp[i] = p
				vb[i] = wb
			var idx = a[Mesh.ARRAY_INDEX]
			if not (idx is PackedInt32Array):
				idx = PackedInt32Array()
			surfs.append([vp, vb, idx])
			for i in verts.size():
				shell.add(inv * (to_world * vp[i]))
			for t in range(0, (idx as PackedInt32Array).size() - 2, 3):
				for bary in JIGGLE_FACE_SAMPLES:
					shell.add(inv * (to_world * (vp[idx[t]] * bary[0] + vp[idx[t + 1]] * bary[1] + vp[idx[t + 2]] * bary[2])))
	for sf in surfs:
		var vp: PackedVector3Array = sf[0]
		var vb: Array = sf[1]
		var idx: PackedInt32Array = sf[2]
		var near_head: = PackedByteArray()
		near_head.resize(vp.size())
		for i in vp.size():
			near_head[i] = 1 if _head_e(hf, inv, to_world * vp[i]) < JIGGLE_FACE_NEAR else 0
			_jiggle_pick_cand(cand, hf, inv, to_world, [vp[i]], [vb[i]], PackedFloat32Array([1.0]))





		for t in range(0, idx.size() - 2, 3):
			var c: = [idx[t], idx[t + 1], idx[t + 2]]

			if near_head[c[0]] + near_head[c[1]] + near_head[c[2]] == 0:
				continue
			if (vb[c[0]] as Dictionary).is_empty() and (vb[c[1]] as Dictionary).is_empty()\
			and (vb[c[2]] as Dictionary).is_empty():
				continue
			var cw: = [vb[c[0]], vb[c[1]], vb[c[2]]]



			if not _jiggle_hinged(cw):
				continue
			var cp: = [vp[c[0]], vp[c[1]], vp[c[2]]]
			for bary in JIGGLE_FACE_SAMPLES:
				var fp: Vector3 = cp[0] * bary[0] + cp[1] * bary[1] + cp[2] * bary[2]




				if not shell.outer(inv * (to_world * fp), hf):
					continue
				_jiggle_pick_cand(cand, hf, inv, to_world, cp, cw, PackedFloat32Array(bary))
	var out: = {}




	var cap: = clampi(JIGGLE_SKIN_BUDGET / maxi(bones.size(), 1), 1, JIGGLE_SKIN_POINTS)
	for b in cand:
		var list: Array = cand[b]
		list.sort_custom( func(x, y): return x[0] < y[0])
		var pts: = PackedVector3Array()
		var f: = PackedFloat32Array()
		var inf: Array = []
		for c in list:
			if pts.size() >= cap:
				break
			var near: = false
			for q in pts:
				if q.distance_to(c[1]) < JIGGLE_SKIN_SPACING:
					near = true
					break
			if near:
				continue
			pts.append(c[1])
			f.append(minf(1.0 + JIGGLE_HEAD_MARGIN * 0.5, float(c[3]) - 0.003))
			inf.append(c[2])
		out[b] = [pts, f, inf]
	return out


const JIGGLE_HINGE: = 0.0

static func _jiggle_hinged(cw: Array) -> bool:
	var all: = {}
	for wb in cw:
		for b in wb:
			all[b] = true
	for b in all:
		var lo: = 1.0
		var hi: = 0.0
		for wb in cw:
			var w: float = (wb as Dictionary).get(b, 0.0)
			lo = minf(lo, w)
			hi = maxf(hi, w)
		if hi - lo >= JIGGLE_HINGE:
			return true
	return false


const JIGGLE_FACE_NEAR: = 1.3


const JIGGLE_SHELL: = 0.06


class _JiggleShell extends RefCounted:
	const NU: = 128
	const NV: = 64
	var _r: = PackedFloat32Array()

	func _init() -> void :
		_r.resize(NU * NV)
		_r.fill(0.0)

	func _bin(d: Vector3) -> int:
		var u: = int((atan2(d.x, d.z) + PI) / TAU * NU) % NU
		var v: = clampi(int(acos(clampf(d.y, -1.0, 1.0)) / PI * NV), 0, NV - 1)
		return v * NU + u

	func add(q: Vector3) -> void :
		var l: = q.length()
		if l < 1e-06:
			return
		var b: = _bin(q / l)
		if l > _r[b]:
			_r[b] = l

	func outer(q: Vector3, hf: HeadField) -> bool:
		var l: = q.length()
		if l < 1e-06:
			return false
		var u: = q / l
		return l >= _r[_bin(u)] - JIGGLE_SHELL * (hf.radius(u) if hf != null else l)

const JIGGLE_FACE_SAMPLES: = [
	[1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0], 
	[0.5, 0.5, 0.0], 
	[0.0, 0.5, 0.5], 
	[0.5, 0.0, 0.5], 
]






static func _jiggle_pick_cand(cand: Dictionary, hf: HeadField, inv: Transform3D, 
		to_world: Transform3D, cp: Array, cw: Array, bary: PackedFloat32Array) -> void :
	var p: = Vector3.ZERO
	var wsum: = {}
	var psum: = {}
	var still: = Vector3.ZERO
	for n in cp.size():
		if bary[n] <= 0.0:
			continue
		var pn: Vector3 = cp[n]
		p += pn * bary[n]
		var w_all: = 0.0
		var wb: Dictionary = cw[n]
		for b in wb:
			var w: float = wb[b] * bary[n]
			w_all += wb[b]
			wsum[b] = float(wsum.get(b, 0.0)) + w
			psum[b] = (psum.get(b, Vector3.ZERO) as Vector3) + pn * w
		still += pn * (maxf(1.0 - w_all, 0.0) * bary[n])
	var best: = -1
	var best_w: = 0.0
	for b in wsum:
		if wsum[b] > best_w:
			best_w = wsum[b]
			best = b
	if best < 0 or best_w < 0.2:
		return
	var e: = _head_e(hf, inv, to_world * p)
	if e < 1.0:
		return
	var ib: = PackedInt32Array()
	var iw: = PackedFloat32Array()
	var ip: = PackedVector3Array()
	for b in wsum:
		ib.append(b)
		iw.append(wsum[b])
		ip.append((psum[b] as Vector3) / wsum[b])
	cand.get_or_add(best, []).append([e, p, [ib, iw, ip, still], e])



func _jiggle_head_e(inv: Transform3D, p: Vector3) -> float:
	return _head_e(_head_field(), inv, p)

static func _head_e(hf: HeadField, inv: Transform3D, p: Vector3) -> float:
	if hf == null:
		return 2.0
	return hf.ratio(inv * p)



func _jiggle_floor(inv: Transform3D, p: Vector3) -> float:
	return minf(1.0 + JIGGLE_HEAD_MARGIN, _jiggle_head_e(inv, p) - 0.003)



func _jiggle_safe_angle(root: Vector3, p: Vector3, c: Vector3, inv: Transform3D, 
		floor_e: float) -> float:
	var v: = p - root
	var axis: = v.cross(c - root)
	if axis.length() < 1e-06 or v.length() < 1e-06:
		return PI
	axis = axis.normalized()
	var step: = 0.03
	var a: = step
	while a <= PI:
		if _jiggle_head_e(inv, root + v.rotated(axis, a)) < floor_e:
			return a - step
		a += step
	return PI


func jiggle_head_depth(p: Vector3) -> float:
	var hf: = _head_field()
	if _face_root == null or not is_instance_valid(_face_root) or hf == null:
		return 0.0
	var q: = _face_root.global_transform.affine_inverse() * p
	var l: = q.length()
	if l < 1e-06:
		return 0.0
	return (hf.radius(q / l) - l) * _face_root.global_basis.get_scale().x

func _jiggle_head_radius() -> float:

	var s: = 1.0
	if _face_root != null and is_instance_valid(_face_root) and _face_root.is_inside_tree():
		s = _face_root.global_basis.get_scale().x
	return minf(_head_radii.x, _head_radii.z) * s


func jiggle_chains() -> Array:
	return _jiggles.filter( func(j): return is_instance_valid(j["skel"]))



func _scan_tails_into(n: Node, out: Array) -> void :
	if n is Skeleton3D:
		var sk: = n as Skeleton3D
		var chains: Array = []
		var claimed: = {}
		for b in sk.get_bone_count():
			if not _is_tail_bone(sk, b):
				continue
			var parent: = sk.get_bone_parent(b)
			if parent >= 0 and _is_tail_bone(sk, parent):
				continue
			_walk_tail_chain(sk, b, [], claimed, chains)
		if not chains.is_empty():
			out.append({"skel": sk, "chains": chains})
	for c in n.get_children():
		_scan_tails_into(c, out)

static func _is_tail_bone(sk: Skeleton3D, b: int) -> bool:
	return sk.get_bone_name(b).to_lower().begins_with(TAIL_PREFIX)

func _walk_tail_chain(sk: Skeleton3D, b: int, chain: Array, claimed: Dictionary, 
		chains: Array) -> void :
	if claimed.has(b):
		return
	claimed[b] = true
	chain.append(b)
	var kids: Array = []
	for c in sk.get_bone_children(b):
		if _is_tail_bone(sk, c):
			kids.append(c)
	if kids.is_empty():
		if chain.size() >= 1:
			chains.append(chain)
		return



	_walk_tail_chain(sk, kids[0], chain, claimed, chains)
	for i in range(1, kids.size()):
		_walk_tail_chain(sk, kids[i], [], claimed, chains)




func _jiggle_place_colliders() -> void :
	if _face_root == null or not is_instance_valid(_face_root):
		return
	var head_c: = _face_root.global_position
	var chest: = _skel.find_bone("spine1") if _skel != null else -1
	var chest_xf: = Transform3D()
	var s: = 1.0
	if chest >= 0:
		chest_xf = _skel.global_transform * _skel.get_bone_global_pose(chest)
		s = _skel.global_basis.get_scale().x
	for j in _jiggles:
		var cols: Array = j["cols"]



		var head: = cols[0] as SpringBoneCollisionSphere3D
		head.global_transform = Transform3D(Basis(), head_c)


		var fit_now: = float(j["head_r"]) < 0.0
		var torso: = cols[1] as SpringBoneCollisionCapsule3D
		var shoulders: = cols[2] as SpringBoneCollisionCapsule3D
		if chest < 0:
			torso.radius = 0.0
			shoulders.radius = 0.0
			if fit_now and _jiggle_fit_heads(j):
				_jiggle_hug_caps(j)
			head.radius = maxf(float(j["head_r"]), 0.0)
			continue
		var b: = chest_xf.basis.orthonormalized()

		if j.get("body", false):
			torso.global_transform = Transform3D(b, 
				chest_xf * Vector3(0, (JIGGLE_BODY_LO + JIGGLE_BODY_HI) * 0.5, 0))
			torso.radius = JIGGLE_BODY_R * s
			torso.height = (JIGGLE_BODY_HI - JIGGLE_BODY_LO + 2.0 * JIGGLE_BODY_R) * s
		else:
			torso.global_transform = Transform3D(b, chest_xf * Vector3(0, JIGGLE_TORSO_AT, 0))
			torso.radius = JIGGLE_TORSO_R * s
			torso.height = JIGGLE_TORSO_H * s

		shoulders.global_transform = Transform3D(b * Basis(Vector3.FORWARD, PI * 0.5), 
			chest_xf * Vector3(0, JIGGLE_SHOULDER_AT, 0))
		shoulders.radius = JIGGLE_SHOULDER_R * s
		shoulders.height = JIGGLE_SHOULDER_W * s
		if fit_now and _jiggle_fit_heads(j):
			_jiggle_hug_caps(j)
		head.radius = maxf(float(j["head_r"]), 0.0)


		var sk: Skeleton3D = j["skel"]
		if is_instance_valid(sk) and j.has("limit"):
			var to_sk: = sk.global_transform.affine_inverse()
			var ax: = torso.global_basis.y.normalized() * maxf(torso.height * 0.5 - torso.radius, 0.0)
			(j["limit"] as JiggleLimit).set_torso(to_sk * (torso.global_position - ax), 
				to_sk * (torso.global_position + ax), torso.radius / sk.global_basis.get_scale().x)







static var lod_views: Array = []
const JIGGLE_PUSH_MIN_PX: = 56.0
const LOD_HEAD_M: = 0.5
var push_lod: = true

func _push_wanted() -> bool:
	if lod_views.is_empty() or _head_mount == null:
		return true
	var at: = _head_mount.global_position
	for vp in lod_views:
		if not is_instance_valid(vp):
			return true
		var cam: = (vp as Viewport).get_camera_3d()
		if cam == null:
			return true
		if not cam.is_position_in_frustum(at):
			continue
		var dist: = maxf(cam.global_position.distance_to(at), 0.01)
		var px: = LOD_HEAD_M / (dist * 2.0 * tan(deg_to_rad(cam.fov) * 0.5))\
		* (vp as Viewport).get_visible_rect().size.y
		if px >= JIGGLE_PUSH_MIN_PX:
			return true
	return false

func tail_tick(delta: float) -> void :



	if _head_mount == null or delta <= 0.0 or _jiggles.is_empty():
		return


	if not GameConfig.hair_physics:
		_jiggle_park(true)
		_drive_flaps()
		return
	_jiggle_park(false)
	var here: = _head_mount.global_position
	if _prev_head_pos.distance_to(here) > JIGGLE_TELEPORT:
		_jiggle_reset = true



	var tick: = Engine.get_physics_frames()
	if tick != _carry_tick:
		_carry_tick = tick
		var was: = _carry_vy
		_carry_vy = 0.0 if _jiggle_reset else clampf((here.y - _prev_head_pos.y) / delta, 
			- JIGGLE_CARRY_MAX_V, JIGGLE_CARRY_MAX_V)



		var dv: = _carry_vy - was
		_carry_dv = dv if absf(dv) <= JIGGLE_CARRY_MAX_A * delta else 0.0
	var vy: = 0.0 if _jiggle_reset else _carry_vy
	_prev_head_pos = here
	if jiggle_carry_on:
		_jiggle_carry(vy, 0.0 if _jiggle_reset else _carry_dv)
	else:
		_jiggle_carry(0.0, 0.0)
	push_lod = _push_wanted()
	_jiggle_step(delta)












func _jiggle_carry(vy: float, dv: = 0.0) -> void :
	for j in _jiggles:
		var sim: = j["sim"] as SpringBoneSimulator3D
		if not is_instance_valid(sim):
			continue
		if absf(float(j.get("vy", 0.0)) - vy) < 0.05 and absf(float(j.get("dv", 0.0)) - dv) < 0.02:
			continue
		j["vy"] = vy
		j["dv"] = dv
		var params: Array = j["params"]
		for ci in mini(params.size(), sim.setting_count):



			var g: = Vector3.DOWN * float(params[ci][2]) + Vector3.UP * ((vy * float(params[ci][1]) + dv) * JIGGLE_CARRY)
			var gl: = g.length()
			var gd: = g / gl if gl > 0.0001 else Vector3.DOWN


			if sim.is_config_individual(ci):
				for jk in sim.get_joint_count(ci):
					sim.set_joint_gravity(ci, jk, gl)
					sim.set_joint_gravity_direction(ci, jk, gd)
			else:
				sim.set_gravity(ci, gl)
				sim.set_gravity_direction(ci, gd)




func _jiggle_park(park_all: bool) -> void :
	for j in _jiggles:
		var sim: = j["sim"] as SpringBoneSimulator3D
		var sk: Skeleton3D = j["skel"]

		var park: bool = park_all or j.get("held", false)
		if not is_instance_valid(sim) or sim.active == ( not park):
			continue
		sim.active = not park
		if j.has("limit") and is_instance_valid(j["limit"]):
			(j["limit"] as SkeletonModifier3D).active = not park
		if park and is_instance_valid(sk) and sk.is_inside_tree():
			sk.advance(0.0)
			sk.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)
		if not park:
			_jiggle_reset = true

func _jiggle_step(delta: float) -> void :
	_jiggle_place_colliders()
	_jiggle_poll_points()
	_drive_flaps()
	if _jiggle_reset:


		for j in _jiggles:
			if is_instance_valid(j["skel"]):
				(j["sim"] as SpringBoneSimulator3D).reset()
		_jiggle_reset = false




		_jiggle_push(false)
		for i in JIGGLE_SETTLE_STEPS:
			if i == JIGGLE_SETTLE_STEPS - 1:
				_jiggle_push(true)
			_jiggle_step_now(1.0 / 60.0)
	_jiggle_push(push_lod)
	for j in _jiggles:
		var sk: Skeleton3D = j["skel"]
		if is_instance_valid(sk) and sk.is_inside_tree():
			sk.advance(delta)



func _drive_flaps() -> void :
	for j in _jiggles:
		if j.has("flap") and is_instance_valid(j["flap"]):
			j["flap"].drive()


func _jiggle_push(on: bool) -> void :
	for j in _jiggles:
		if j.has("limit") and is_instance_valid(j["limit"]):
			(j["limit"] as JiggleLimit).push = on




func _jiggle_step_now(delta: float) -> void :
	for j in _jiggles:
		var sk: Skeleton3D = j["skel"]
		if is_instance_valid(sk) and sk.is_inside_tree():
			sk.advance(delta)
			sk.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)











func tail_wind(back: float, side: = 0.0) -> void :
	var face: = global_basis.z
	face = Vector3(face.x, 0.0, face.z).normalized()
	var right: = face.cross(Vector3.UP).normalized()
	var push: = ( - face * back - right * side) * JIGGLE_STILL_FORCE
	for j in _jiggles:
		if is_instance_valid(j["sim"]):
			(j["sim"] as SpringBoneSimulator3D).external_force = push

func tail_still(back: float, side: float, seconds: = 0.6) -> void :
	if _jiggles.is_empty() or _head_mount == null:
		return


	_jiggle_park(false)


	var face: = global_basis.z
	face = Vector3(face.x, 0.0, face.z).normalized()
	var right: = face.cross(Vector3.UP).normalized()
	var push: = ( - face * back - right * side) * JIGGLE_STILL_FORCE
	_jiggle_carry(0.0, 0.0)
	_jiggle_place_colliders()
	if _jiggle_reset:
		_jiggle_step(0.0)
	for j in _jiggles:
		(j["sim"] as SpringBoneSimulator3D).external_force = push
	var n: = int(ceilf(seconds * 60.0))


	_jiggle_push(false)
	for i in n:
		if i == n - 1:
			_jiggle_push(true)
		_jiggle_step_now(1.0 / 60.0)
	for j in _jiggles:
		(j["sim"] as SpringBoneSimulator3D).external_force = Vector3.ZERO
	_prev_head_pos = _head_mount.global_position










func settle_still(seconds: = 0.6) -> void :
	if _jiggles.is_empty() or _head_mount == null or _skel == null or not still_settle_on:
		return

	_skel.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)

	reset_physics_interpolation()
	_jiggle_reset = true
	tail_still(0.0, 0.0, seconds)




func _find_ear_names(node: Node) -> void :
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null\
	and String(node.name).to_lower().begins_with(EAR_MESH_PREFIX):
		var mi: = node as MeshInstance3D
		for i in mi.get_blend_shape_count():
			var nm: = String(mi.mesh.get_blend_shape_name(i))
			if nm in [SHAPE_HEAVY, SHAPE_SLIM, "Hat_TopCovered", "Hat_FullCovered", "pinnyoffset"]\
			or nm in CLOTH_KEYS or nm in _ear_names:
				continue
			_ear_names.append(nm)
			if not nm in CharacterConfig.EAR_SHAPES:
				CharacterConfig.EAR_SHAPES.append(nm)
	for child in node.get_children():
		_find_ear_names(child)



func _apply_ears(pick: String) -> void :
	for entry in _ear_targets:
		var mi: MeshInstance3D = entry[0]
		if is_instance_valid(mi):
			mi.set_blend_shape_value(int(entry[2]), 1.0 if String(entry[1]) == pick else 0.0)

func _collect_shape_targets(node: Node) -> void :


	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mi: = node as MeshInstance3D





		var heavy: = mi.find_blend_shape_by_name(SHAPE_HEAVY)
		var slim: = mi.find_blend_shape_by_name(SHAPE_SLIM)
		if heavy >= 0 or slim >= 0:
			_shape_targets.append([mi, heavy, slim])

		var cloth_idx: Array = []
		var cloth_any: = false
		for key in CLOTH_KEYS:
			var ci: = mi.find_blend_shape_by_name(key)
			cloth_idx.append(ci)
			cloth_any = cloth_any or ci >= 0
		if cloth_any:
			_cloth_targets.append([mi, cloth_idx, _mesh_is_pinny(mi)])

		for nm in _ear_names:
			var ei: = mi.find_blend_shape_by_name(nm)
			if ei >= 0:
				_ear_targets.append([mi, nm, ei])

		for group in PICK_GROUPS:
			var options: Array = PICK_GROUPS[group]
			var idxs: Array = []
			var any: = false
			for name in options:
				if String(name) == "":
					idxs.append(-1)
					continue
				var idx: = mi.find_blend_shape_by_name(String(name))
				idxs.append(idx)
				if idx >= 0:
					any = true
			if any:
				if not _pick_targets.has(group):
					_pick_targets[group] = []
				_pick_targets[group].append([mi, idxs])
	for child in node.get_children():
		_collect_shape_targets(child)

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found: = _find_skeleton(child)
		if found != null:
			return found
	return null

func _calibrate_hands() -> void :



	if _skel == null or hand_radius <= 0.0:
		return
	var found: Array = []
	for key in ["l", "r"]:
		for candidate in HAND_BONES[key]:
			var idx: = _skel.find_bone(candidate)
			if idx >= 0:
				found.append(idx)
				break
	if found.size() < 2:
		return


	var first_x: = _bone_to_local(_skel.get_bone_global_rest(found[0])).origin.x
	var second_x: = _bone_to_local(_skel.get_bone_global_rest(found[1])).origin.x
	var right_first: = first_x > second_x
	_bone["r"] = found[0] if right_first else found[1]
	_bone["l"] = found[1] if right_first else found[0]
	for side in ["l", "r"]:
		var rest: = _bone_to_local(_skel.get_bone_global_rest(_bone[side]))
		var want: = Vector3(hand_rest.x * (1.0 if side == "r" else -1.0), 
			hand_rest.y, hand_rest.z)



		_bone_offset[side] = want - rest.origin

func _bone_to_local(bone_xf: Transform3D) -> Transform3D:

	return global_transform.affine_inverse() * (_skel.global_transform * bone_xf)

func hands_animated() -> bool:
	return _skel != null and _bone["l"] >= 0 and _bone["r"] >= 0


func _setup_callout_overlay() -> void :
	if _skel == null:
		return
	_mask_loco = PackedInt32Array()
	for bn in CALLOUT_LOCO_BONES:
		var b: = _skel.find_bone(bn)
		if b >= 0:
			_mask_loco.append(b)
	_overlay = CalloutOverlay.new()
	_overlay.name = "CalloutOverlay"
	_overlay.active = false
	_skel.add_child(_overlay)


func has_clip(clip_name: String) -> bool:
	return _anim != null and _anim.has_animation(clip_name)



func play_callout(clip_name: String) -> void :
	if _anim == null or not _anim.has_animation(clip_name) or _overlay == null:
		return
	_callout_anim = _anim.get_animation(clip_name)
	_callout_name = clip_name




	if not _clip_map.has(clip_name):
		_clip_map[clip_name] = clip_name
	_callout_t = 0.0
	_callout_len = maxf(_callout_anim.length, 0.05)
	_callout_playing = true



	if _current == _clip_map.get(clip_name, clip_name):
		_anim.play(_current)
		_anim.seek(0.0, true)



func cancel_callout() -> void :
	_callout_playing = false

func callout_active() -> bool:
	return _callout_playing or _callout_inf > 0.01




func callout_full_action() -> String:
	return _callout_name





func tick_callout(delta: float, interrupt: bool) -> void :
	if _overlay == null or _callout_anim == null:
		return
	var step: = delta * maxf(playback_scale, 0.0)
	if _callout_playing:
		_callout_t += step
		if _callout_t >= _callout_len or interrupt:
			_callout_playing = false
			_callout_name = ""


	var moving: = _callout_loco_anim != null
	if _callout_playing and moving:
		_callout_inf = minf(_callout_inf + step / CALLOUT_FADE, 1.0)
	else:
		_callout_inf = maxf(_callout_inf - step / CALLOUT_FADE, 0.0)
	if not _callout_playing and _callout_inf <= 0.0:
		_callout_anim = null
		_overlay.active = false
		return
	if _callout_inf <= 0.001 or _callout_loco_anim == null:
		_overlay.active = false
		return

	var pace: = clampf(_last_planar / PACE_REF, PACE_MIN, PACE_MAX) if _last_planar > 0.01 else 1.0
	_leg_t = fposmod(_leg_t + step * pace, maxf(_callout_loco_anim.length, 0.05))
	_overlay.set_pose(_callout_loco_anim, _leg_t, _callout_inf, _mask_loco)
	_overlay.active = true

func hand_local(right: bool) -> Vector3:

	var side: = "r" if right else "l"
	var pose: = _bone_to_local(_skel.get_bone_global_pose(_bone[side]))
	return pose.origin + _bone_offset[side]

func _collect_meshes(node: Node, out: Array) -> void :
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		out.append(node)
	for child in node.get_children():
		_collect_meshes(child, out)







func force_static_pose() -> void :
	if _look != null:
		_look.active = false
	if _skel != null:
		_skel.force_update_all_bone_transforms()

func _find_anim(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found: = _find_anim(child)
		if found != null:
			return found
	return null

func _ink(meshes: Array, width: float, front_part: = false, want_highlight: = true) -> void :











	if _reflection:
		return






	if want_highlight:
		_queue_highlight(meshes)
	match GameConfig.art_style:
		GameConfig.ArtStyle.WII:


			return
		GameConfig.ArtStyle.CEL_INK:
			if Ink.supported():



				if front_part:
					_build_acc_proxies(meshes)
				else:
					Ink.tag(meshes)
				return



			_build_outlines(meshes, width)
		_:
			_build_outlines(meshes, width)







func _build_acc_proxies(meshes: Array) -> void :
	for m in meshes:
		var mi: = m as MeshInstance3D
		if mi == null or mi.mesh == null or String(mi.name).to_lower().contains("number"):
			continue
		var proxy: = MeshInstance3D.new()
		proxy.mesh = mi.mesh
		proxy.material_override = Ink.acc_proxy_material()
		proxy.layers = Ink.INK_ACC_MASK
		proxy.skin = mi.skin
		proxy.transform = mi.transform
		mi.get_parent().add_child(proxy)
		proxy.skeleton = mi.skeleton

func _build_outlines(meshes: Array, width: float) -> void :


	if not GameConfig.INK_OUTLINES:
		return
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	mat.albedo_color = OUTLINE_COLOR
	mat.grow = true
	mat.grow_amount = width
	if GameConfig.contour_outline:


		mat.grow_amount = width * GameConfig.contour_inner_scale




	var by_id: = {}
	var shell_mat_for: = func(id: int) -> Material:
		if GameConfig.contour_outline and not GameConfig.contour_inner_lines:
			return _contour_only(id)
		if not by_id.has(id):
			var mm: = mat.duplicate() as StandardMaterial3D
			if GameConfig.contour_outline:
				mm.next_pass = own_contour(id)
			by_id[id] = mm
		return by_id[id]
	for m in meshes:
		var mi: = m as MeshInstance3D


		if not mi.visible or String(mi.name).to_lower().contains("number"):
			continue
		var shell: = MeshInstance3D.new()
		shell.mesh = mi.mesh
		var cid: = _contour_id(mi)
		var own: Material = shell_mat_for.call(cid)
		shell.material_override = own
		shell.set_meta(&"ink_mat", own)

		_shells[mi] = shell
		if cid == stencil_id:
			_outline_mat = own
		shell.skin = mi.skin
		shell.transform = mi.transform
		mi.get_parent().add_child(shell)

		shell.skeleton = mi.skeleton









var _hl_pending: Array = []

func _queue_highlight(meshes: Array) -> void :
	_hl_pending.append_array(meshes)

func _build_highlight(meshes: Array) -> void :
	if _hl_mat == null:
		_hl_mat = StandardMaterial3D.new()
		_hl_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_hl_mat.cull_mode = BaseMaterial3D.CULL_FRONT
		_hl_mat.grow = true
		_hl_mat.grow_amount = 0.135
		_hl_mat.albedo_color = Color.WHITE
	for m in meshes:





		if _dead(m):
			continue
		var mi: = m as MeshInstance3D

		if mi == null or _hl_shells.has(mi):
			continue
		if not mi.visible or String(mi.name).to_lower().contains("number"):
			continue
		var shell: = MeshInstance3D.new()
		shell.mesh = mi.mesh

		shell.material_override = _hl_mat
		shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shell.visible = false
		shell.skin = mi.skin
		shell.transform = mi.transform
		mi.get_parent().add_child(shell)
		shell.skeleton = mi.skeleton
		_hl_shells[mi] = shell


		for b in mi.get_blend_shape_count():
			shell.set_blend_shape_value(b, mi.get_blend_shape_value(b))
		var cloth_idx: Array = []
		var cloth_any: = false
		for key in CLOTH_KEYS:
			var ci: = shell.find_blend_shape_by_name(key)
			cloth_idx.append(ci)
			cloth_any = cloth_any or ci >= 0
		if cloth_any:
			_cloth_targets.append([shell, cloth_idx, _mesh_is_pinny(mi)])




func _scrub_shell_maps() -> void :


	for map in [_shells, _hl_shells]:
		var stale: = []
		for k in map:
			if _dead(k) or _dead(map[k]):
				stale.append(k)
		for k in stale:
			map.erase(k)
	var stale2: = []
	for k in _surface_slots:
		if _dead(k):
			stale2.append(k)
	for k in stale2:
		_surface_slots.erase(k)

static func _dead(n) -> bool:
	return not is_instance_valid(n)\
	or (n is Node and (n as Node).is_queued_for_deletion())

func set_highlight(color: Color) -> void :
	_scrub_shell_maps()
	var on: = color.a > 0.01
	if GameConfig.contour_outline:





		var tint: = Color(color.r, color.g, color.b, 1.0) if on else Color(0, 0, 0, 0)
		_contour_tint = tint
		for id in _own_contour:
			(_own_contour[id] as ShaderMaterial).set_shader_parameter("contour_tint", tint)
		for mi in _hl_shells:
			(_hl_shells[mi] as MeshInstance3D).visible = false
		return
	if on and not _hl_pending.is_empty():

		var pend: = _hl_pending
		_hl_pending = []
		_build_highlight(pend)
	if on and _hl_mat != null:
		_hl_mat.albedo_color = color
	for mi in _hl_shells:
		var shell: MeshInstance3D = _hl_shells[mi]
		shell.visible = on





func set_flash(color: Color, amount: float) -> void :
	for slot in _mats:
		for sm in _slot_mats(slot):
			var m: = sm as ShaderMaterial
			if m != null:
				m.set_shader_parameter("flash_color", color)
				m.set_shader_parameter("flash", amount)
	for hm in _hair_mats:
		var m2: = hm as ShaderMaterial
		if m2 != null:
			m2.set_shader_parameter("flash_color", color)
			m2.set_shader_parameter("flash", amount)
	for slot in _acc_mats:
		for am in _acc_mats[slot]:
			var m3: = am as ShaderMaterial
			if m3 != null:
				m3.set_shader_parameter("flash_color", color)
				m3.set_shader_parameter("flash", amount)



static func body_shader() -> Shader:
	return WII if GameConfig.style_is(GameConfig.ArtStyle.WII) else TOON





static var _two_sided: = {}
static func jersey_shader() -> Shader:
	var base: = body_shader()
	if not _two_sided.has(base):
		var sh: = Shader.new()
		sh.code = base.code.replace("cull_back", "cull_disabled")
		_two_sided[base] = sh
	return _two_sided[base]

var _head_mats: = {}


func _slot_mats(slot: String) -> Array:
	var out: Array = []
	for d in [_mats, _head_mats]:
		if d.has(slot):
			out.append(d[slot])
	return out

func _toon_material(color: Color) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = stencil_shader(body_shader(), stencil_id)
	mat.set_shader_parameter("albedo", color)
	return mat










const HEAD_STENCIL_OFFSET: = 8
const HEAD_CONTOUR_PULL: = 0.04

func head_stencil_id() -> int:
	return stencil_id + HEAD_STENCIL_OFFSET

func _in_head_group(n: Node) -> bool:
	if n == null or not is_instance_valid(n):
		return false
	var nm: = String(n.name).to_lower()
	if nm.begins_with("headmesh") or nm.begins_with("earsmesh"):
		return true
	var roots: Array = [_hair_root, _face_root, _facial_root]
	roots.append_array(_acc_roots.values())
	for r in roots:
		if r != null and is_instance_valid(r) and (r == n or (r as Node).is_ancestor_of(n)):
			return true
	return false


func _contour_id(mi: Node) -> int:
	return head_stencil_id() if _in_head_group(mi) else stencil_id




func mark_head_group() -> void :
	var roots: Array = [_hair_root, _face_root, _facial_root]
	roots.append_array(_acc_roots.values())
	for mi in _surface_slots:
		if is_instance_valid(mi) and _in_head_group(mi):
			roots.append(mi)
	for r in roots:
		if r != null and is_instance_valid(r):
			GameConfig.stencil_mark_body(r, head_stencil_id())




func _hair_material(color: Color) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = stencil_shader(WII if GameConfig.style_is(GameConfig.ArtStyle.WII) else TOON_HAIR, 
		head_stencil_id())
	mat.set_shader_parameter("albedo", color)
	return mat

func _apply_toon_materials(node: Node) -> void :


	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null\
	and (node as MeshInstance3D).visible:
		var mi: = node as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			var src: = mi.mesh.surface_get_material(s)
			var raw: = src.resource_name.to_lower() if src != null else ""
			var slot: String = SLOT_ALIASES.get(raw, raw)
			if not _surface_slots.has(mi):
				_surface_slots[mi] = {}
			_surface_slots[mi][s] = slot
			if not _mats.has(slot):
				var mat: = ShaderMaterial.new()
				mat.shader = stencil_shader(jersey_shader() if slot == "jersey" else body_shader(), 
					stencil_id)
				var fallback: = (src as BaseMaterial3D).albedo_color\
				if src is BaseMaterial3D else Color.WHITE
				mat.set_shader_parameter("albedo", _default_color(slot, fallback))
				_mats[slot] = mat
			if _in_head_group(mi):


				if not _head_mats.has(slot):
					var twin: = (_mats[slot] as ShaderMaterial).duplicate() as ShaderMaterial
					twin.shader = stencil_shader(jersey_shader() if slot == "jersey"\
					else body_shader(), head_stencil_id())
					_head_mats[slot] = twin
				mi.set_surface_override_material(s, _head_mats[slot])
				continue
			mi.set_surface_override_material(s, _mats[slot])


			if _fallback_mat == null and not _mats.has("jersey")\
			and String(mi.name).to_lower().contains("body"):
				_fallback_mat = _mats[slot]
	for child in node.get_children():
		_apply_toon_materials(child)

func _default_color(slot: String, imported: Color) -> Color:
	match slot:
		"skin":
			return Color(1.0, 0.87, 0.73)
		"jersey":
			return Color(0.3, 0.55, 0.95)
		"shorts":
			return Color(0.09, 0.09, 0.11)
		"socks":
			return Color(0.09, 0.09, 0.11)
		"shoes":
			return Color(0.09, 0.09, 0.11)
	return imported

func skin_color() -> Color:
	if _mats.has("skin"):
		return (_mats["skin"] as ShaderMaterial).get_shader_parameter("albedo")
	return Color(1.0, 0.87, 0.73)





func set_slot_hidden(slot: String, hide: bool) -> void :
	_scrub_shell_maps()
	for sm in _slot_mats(slot):
		(sm as ShaderMaterial).set_shader_parameter("hidden", 1.0 if hide else 0.0)
	for mi in _surface_slots:
		if not is_instance_valid(mi):
			continue
		var slots: Dictionary = _surface_slots[mi]
		var touches: = false
		for si in slots:
			if slots[si] == slot:
				touches = true
		if not touches:
			continue


		var shell: MeshInstance3D = _shells.get(mi)
		if shell != null and is_instance_valid(shell):
			_silence_shell_slot(shell, slots, slot, hide, _outline_mat)
		var aura: MeshInstance3D = _hl_shells.get(mi)
		if aura != null and is_instance_valid(aura):
			_silence_shell_slot(aura, slots, slot, hide, _hl_mat)

func _silence_shell_slot(shell: MeshInstance3D, slots: Dictionary, 
		slot: String, hide: bool, restore: Material) -> void :
	if shell.material_override != null:

		var base: = shell.material_override
		shell.material_override = null
		for si in shell.mesh.get_surface_count():
			shell.set_surface_override_material(si, base)
	for si in slots:
		if slots[si] == slot:
			shell.set_surface_override_material(si, 
				_invisible() if hide else restore)







var stencil_id: = 1

static var _stencil_variants: = {}
static func stencil_shader(base: Shader, id: int) -> Shader:
	if base == null or id <= 1:
		return base
	var key: = [base, id]
	if not _stencil_variants.has(key):
		var sh: = Shader.new()
		sh.code = base.code\
		.replace("stencil_mode write, compare_always, 1;", 
			"stencil_mode write, compare_always, %d;" % id)\
			.replace("stencil_mode read, compare_not_equal, 1;", 
			"stencil_mode read, compare_not_equal, %d;" % id)
		_stencil_variants[key] = sh
	return _stencil_variants[key]




const CONTOUR_SHADER: = preload("res://game/fx/contour.gdshader")
static var _contour_mats: = {}

static func contour_material(id: = 1) -> ShaderMaterial:
	if not _contour_mats.has(id):
		var m: = ShaderMaterial.new()
		m.shader = stencil_shader(CONTOUR_SHADER, id)
		if id == 1:

			m.set_shader_parameter("line_color", Color.RED\
			if "--contour-red" in LaunchGate.dev_args() else OUTLINE_COLOR)



			m.set_shader_parameter("near_px", 7.0)
			m.set_shader_parameter("far_px", 1.75)
			m.set_shader_parameter("near_ppm", 350.0)
			m.set_shader_parameter("far_ppm", 40.0)
		else:

			var src: = contour_material(1)
			for k in CONTOUR_PARAMS:
				m.set_shader_parameter(k, src.get_shader_parameter(k))
		_contour_mats[id] = m
	return _contour_mats[id]

const CONTOUR_PARAMS: = ["line_color", "near_px", "far_px", "near_ppm", "far_ppm"]

static func set_contour_param(param: String, value) -> void :
	contour_material(1)
	for id in _contour_mats:
		(_contour_mats[id] as ShaderMaterial).set_shader_parameter(param, value)

	var live: Array = []
	for w in _contour_copies:
		var m: = (w as WeakRef).get_ref() as ShaderMaterial
		if m != null:
			m.set_shader_parameter(param, value)
			live.append(w)
	_contour_copies = live








static var _contour_copies: Array = []
var _own_contour: = {}
var _contour_px: = 1.0
var _contour_tint: = Color(0, 0, 0, 0)
var _contour_res: = 1.0






const RES_GROUP: = &"contour_rigs"

func _enter_tree() -> void :
	add_to_group(RES_GROUP)
	sync_res_scale()

func sync_res_scale() -> void :
	var vp: = get_viewport()
	var rs: = vp.scaling_3d_scale if vp != null else 1.0
	if is_equal_approx(rs, _contour_res):
		return
	_contour_res = rs
	for id in _own_contour:
		(_own_contour[id] as ShaderMaterial).set_shader_parameter("contour_res", rs)

func own_contour(id: int) -> ShaderMaterial:
	if not _own_contour.has(id):
		var m: = contour_material(id).duplicate() as ShaderMaterial
		m.set_shader_parameter("contour_px_scale", _contour_px)
		m.set_shader_parameter("contour_res", _contour_res)
		m.set_shader_parameter("contour_tint", _contour_tint)

		m.set_shader_parameter("contour_pull", HEAD_CONTOUR_PULL if id != stencil_id else 0.0)
		_own_contour[id] = m
		_contour_copies.append(weakref(m))
	return _own_contour[id]


func set_contour_px_scale(k: float) -> void :
	_contour_px = k
	for id in _own_contour:
		(_own_contour[id] as ShaderMaterial).set_shader_parameter("contour_px_scale", k)






func use_contour_only() -> void :
	_scrub_shell_maps()
	for mi in _shells:
		var sh: = _shells[mi] as MeshInstance3D
		var only: = _contour_only(_contour_id(mi))
		if sh.material_override is BaseMaterial3D:
			sh.material_override = only
		for si in sh.get_surface_override_material_count():
			if sh.get_surface_override_material(si) is BaseMaterial3D:
				sh.set_surface_override_material(si, only)






func _contour_only(id: = 1) -> ShaderMaterial:
	return own_contour(id)

static func _invisible() -> ShaderMaterial:
	if _invisible_shell == null:
		var sh: = Shader.new()
		sh.code = "shader_type spatial;\nrender_mode unshaded;\nvoid fragment() { discard; }"
		_invisible_shell = ShaderMaterial.new()
		_invisible_shell.shader = sh
	return _invisible_shell



func _set_blend_shape_named(nm: String, value: float) -> void :
	for mi in _surface_slots.keys():
		if not is_instance_valid(mi) or mi.mesh == null:
			continue
		for s in mi.mesh.get_blend_shape_count():
			if String(mi.mesh.get_blend_shape_name(s)) == nm:
				mi.set_blend_shape_value(s, value)

func set_slot_color(slot: String, color: Color) -> void :
	if _mats.has(slot):
		for sm in _slot_mats(slot):
			(sm as ShaderMaterial).set_shader_parameter("albedo", color)
	elif slot == "jersey" and _fallback_mat != null:
		_fallback_mat.set_shader_parameter("albedo", color)

func set_kit(primary: Color, secondary: Color, accent: Color, 
		pants_accent: = Color.TRANSPARENT) -> void :




	set_slot_color("jersey", primary)
	set_slot_color("shorts", secondary)
	set_slot_color("accent", accent)
	set_slot_color("pants_accent", 
		accent if pants_accent.a == 0.0 else pants_accent)

func apply_config(cfg: CharacterConfig, kit: Array) -> void :


	_left_handed = cfg.left_handed
	set_slot_color("skin", cfg.skin_tone())



	var gear: = cfg.worn_gear()
	set_slot_color("kneepad", gear.kneepad)
	set_slot_color("socks", gear.socks)
	set_slot_color("shoes", gear.shoe_color)


	set_slot_hidden("kneepad", not gear.wear_kneepads)
	set_slot_hidden("socks", not gear.wear_socks)




	var barefoot: = GameConfig.barefoot_for(self)
	set_slot_hidden("shoes", barefoot)
	if barefoot:
		set_slot_hidden("socks", true)

	if kit.size() >= 3:

		set_kit(kit[0], kit[1], kit[2], 
			kit[1] if cfg.casual else Color.TRANSPARENT)





	var show_number: = ( not cfg.casual) or cfg.wear_pinny
	var ink: Color
	if cfg.wear_pinny:

		ink = TeamKits.number_ink(cfg.pinny_color)
	elif kit.size() >= 3:
		ink = TeamKits.number_color(kit)
	else:
		ink = TeamKits.number_ink(Color.BLACK)
	set_number(cfg.number if show_number else -1, ink)




	set_slot_hidden("practice_jersey", not cfg.wear_pinny)
	set_slot_hidden("practice_jersey_accent", not cfg.wear_pinny)
	_pinny_worn = cfg.wear_pinny
	if cfg.wear_pinny:
		set_slot_color("practice_jersey", cfg.pinny_color)

		set_slot_color("practice_jersey_accent", TeamKits.number_ink(cfg.pinny_color))





	_set_blend_shape_named("pinnyoffset", 1.0 if cfg.wear_pinny else 0.0)
	if cfg.wear_pinny:
		for mi in _surface_slots.keys():
			if not is_instance_valid(mi) or mi.mesh == null:
				continue
			var nm: = String(mi.name).to_lower()
			if not nm.begins_with("numbermesh"):
				continue
			var s: int = mi.find_blend_shape_by_name("pinnyoffset")
			if s >= 0:
				mi.set_blend_shape_value(s, PINNY_NUMBER_FRONT if nm.ends_with("_f") else PINNY_NUMBER_BACK)
	set_face(cfg)
	set_hair(cfg.hair, cfg)
	set_facial_hair(cfg)


	set_accessories(cfg)
	if _scene == null:
		return


	var h: = 1.0 + (cfg.height - 0.5) * 2.0 * HEIGHT_RANGE
	_scene.scale = Vector3.ONE * _base_scale * h
	var heavy: = clampf((cfg.weight - 0.5) * 2.0, 0.0, 1.0)
	var slim: = clampf((0.5 - cfg.weight) * 2.0, 0.0, 1.0)
	for entry in _shape_targets:
		var mi: MeshInstance3D = entry[0]
		if entry[1] >= 0:
			mi.set_blend_shape_value(entry[1], heavy)
		if entry[2] >= 0:
			mi.set_blend_shape_value(entry[2], slim)


	_apply_pick("head", cfg.head_shape, CharacterConfig.HEAD_SHAPES.size())
	_apply_ears(cfg.ear_shape)
	_apply_pick("shorts", gear.shorts_len, CharacterConfig.SHORTS_SHAPES.size())
	_apply_pick("socks", gear.socks_len, CharacterConfig.SOCKS_SHAPES.size())


	var shirt_idx: = cfg.gym_shirt if cfg.casual else 0
	var hood: = cfg.casual and cfg.wears_hoodie()
	if hood:
		shirt_idx = 0
	_apply_pick("shirt", shirt_idx, CharacterConfig.SHIRT_SHAPES.size())


	var shirt_primary: Color = kit[0] if (cfg.casual and kit.size() >= 3) else cfg.gym_tee
	set_slot_color("hoodie", cfg.hoodie_tint(shirt_primary))
	_set_mesh_shown(_hood_mesh, hood)

	_apply_kneepad_style(gear.kneepad_style, gear.wear_kneepads, gear.kneepad_side, 
		gear.kneepad_style_l)
	_apply_kneepad_colors(gear.kneepad, gear.kneepad_left_color(), gear.wear_kneepads)

	_cloth_on = shirt_idx == 0 and not hood
	if not _cloth_on:
		_cloth = [0.0, 0.0, 0.0, 0.0, 0.0]
		_push_cloth()




func _set_mesh_shown(mi: MeshInstance3D, shown: bool) -> void :
	if mi == null or not is_instance_valid(mi):
		return
	mi.visible = shown
	for map in [_shells, _hl_shells]:
		if map.has(mi) and is_instance_valid(map[mi]):
			(map[mi] as MeshInstance3D).visible = shown







func _mesh_has_slot(mi: MeshInstance3D, slot: String) -> bool:
	var slots: Dictionary = _surface_slots.get(mi, {})
	for si in slots:
		if slots[si] == slot:
			return true
	return false







func _split_kneepads(meshes: Array) -> void :
	for length in _kneepad_meshes:
		var parts: Dictionary = _kneepad_meshes[length]
		if not parts.has("both") or (parts.has("l") and parts.has("r")):
			continue
		var src: MeshInstance3D = parts["both"]
		var halves: = _split_mesh_by_x(src.mesh)
		if halves.is_empty():
			continue
		for leg in ["l", "r"]:
			var mi: = src.duplicate() as MeshInstance3D
			mi.name = "%s_%s" % [src.name, leg]
			mi.mesh = halves[leg]
			for s in src.mesh.get_surface_count():
				mi.set_surface_override_material(s, src.get_surface_override_material(s))
			src.get_parent().add_child(mi)
			mi.owner = src.owner
			if _surface_slots.has(src):
				_surface_slots[mi] = (_surface_slots[src] as Dictionary).duplicate()
			meshes.append(mi)
			parts[leg] = mi
		parts.erase("both")
		src.visible = false
		meshes.erase(src)
		_surface_slots.erase(src)


func _split_mesh_by_x(mesh: Mesh) -> Dictionary:
	if mesh == null or mesh.get_surface_count() == 0:
		return {}
	var out: = {"l": ArrayMesh.new(), "r": ArrayMesh.new()}
	for s in mesh.get_surface_count():
		if mesh.surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES:
			return {}
		var arrays: = mesh.surface_get_arrays(s)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null\
		else PackedInt32Array(range(verts.size()))
		var keep: = {"l": PackedInt32Array(), "r": PackedInt32Array()}
		for t in range(0, idx.size() - 2, 3):
			var cx: = (verts[idx[t]].x + verts[idx[t + 1]].x + verts[idx[t + 2]].x) / 3.0
			var leg: = "l" if cx > 0.0 else "r"
			keep[leg].append(idx[t])
			keep[leg].append(idx[t + 1])
			keep[leg].append(idx[t + 2])
		var flags: int = mesh.surface_get_format(s) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS
		for leg in ["l", "r"]:
			var a: = arrays.duplicate()
			a[Mesh.ARRAY_INDEX] = keep[leg]
			(out[leg] as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, a, [], {}, flags)
			(out[leg] as ArrayMesh).surface_set_material(s, mesh.surface_get_material(s))
	return out





func _apply_kneepad_style(style: int, worn: bool, side: = 0, style_l: = -1) -> void :
	if _kneepad_meshes.is_empty():
		return
	if style_l < 0:
		style_l = style
	var want_r: = "long" if (style == 1 and _kneepad_meshes.has("long")) else "short"
	var want_l: = "long" if (style_l == 1 and _kneepad_meshes.has("long")) else "short"
	for length in _kneepad_meshes:
		var parts: Dictionary = _kneepad_meshes[length]
		for leg in parts:
			var on_leg: bool = side == 0 or leg == "both"\
			or (side == 1 and leg == "r") or (side == 2 and leg == "l")
			var want: String = want_l if leg == "l" else want_r
			_set_mesh_shown(parts[leg], worn and length == want and on_leg)



func _apply_kneepad_colors(right: Color, left: Color, worn: bool) -> void :
	if not _mats.has("kneepad"):
		return
	if _kneepad_l_mat == null:
		_kneepad_l_mat = (_mats["kneepad"] as ShaderMaterial).duplicate() as ShaderMaterial
		for length in _kneepad_meshes:
			var parts: Dictionary = _kneepad_meshes[length]
			if not parts.has("l"):
				continue
			var mi: MeshInstance3D = parts["l"]
			var slots: Dictionary = _surface_slots.get(mi, {})
			for si in slots:
				if slots[si] == "kneepad":
					mi.set_surface_override_material(si, _kneepad_l_mat)
	set_slot_color("kneepad", right)
	_kneepad_l_mat.set_shader_parameter("albedo", left)
	_kneepad_l_mat.set_shader_parameter("hidden", 0.0 if worn else 1.0)

func _apply_pick(group: String, choice: int, count: int) -> void :
	var pick: = clampi(choice, 0, count - 1)
	for entry in _pick_targets.get(group, []):
		var mi: MeshInstance3D = entry[0]
		var idxs: Array = entry[1]
		for i in idxs.size():
			if int(idxs[i]) >= 0:
				mi.set_blend_shape_value(int(idxs[i]), 1.0 if i == pick else 0.0)

func _build_number_patch(meshes: Array) -> void :





	for m in meshes:
		var mi: = m as MeshInstance3D
		if not String(mi.name).to_lower().contains("number"):
			continue
		if _number_mat != null:

			for s2 in mi.mesh.get_surface_count():
				mi.set_surface_override_material(s2, _number_mat)
			continue
		_number_vp = SubViewport.new()
		_number_vp.size = Vector2i(256, 256)
		_number_vp.transparent_bg = true
		_number_vp.disable_3d = true


		_number_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		add_child(_number_vp)




		_number_text = Label.new()
		_number_text.set_anchors_preset(Control.PRESET_FULL_RECT)
		_number_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_number_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


		if ResourceLoader.exists(NUMBER_FONT):
			_number_text.add_theme_font_override("font", load(NUMBER_FONT))
		_number_text.add_theme_font_size_override("font_size", 128)
		_number_text.add_theme_color_override("font_color", Color.WHITE)
		_number_vp.add_child(_number_text)
		_number_mat = ShaderMaterial.new()
		_number_mat.shader = stencil_shader(TOON_NUMBER, stencil_id)
		_number_mat.set_shader_parameter("number_tex", _number_vp.get_texture())
		for s in mi.mesh.get_surface_count():
			mi.set_surface_override_material(s, _number_mat)

var _number_ink: = Color.TRANSPARENT



func set_number(number: int, ink: Color) -> void :
	if _number_text == null or _number_mat == null:
		return


	_number_text.text = "" if number < 0 else str(clampi(number, 0, 99))
	_kick_vp(_number_vp)
	_number_ink = ink
	_number_mat.set_shader_parameter("ink", ink)

func number_ink() -> Color:
	return _number_ink






const PACED_CLIPS: = ["run", "strafe_left", "strafe_right", "run_back", 
	"strafe_fwd", "sprint", "sprint_left", "sprint_right"]
const PACE_REF: = 6.0
const PACE_MIN: = 0.6
const PACE_MAX: = 1.4

func drive(planar_speed: float, grounded: bool, vel_y: float, 
		action: = "", pace_speed: = 0.0, charge_scrub: = -1.0) -> void :



	if _anim == null:
		return
	_last_planar = planar_speed
	var callout_act: = callout_full_action()



	var loco: = ""
	if action in LOCO_HOOKS:
		loco = action
	elif action == "" or action == "idle" or action == "idle_alt" or action == "stop":
		loco = "run" if (grounded and planar_speed > 1.2) else "idle"


	var gesturing: = callout_act != "" and grounded and loco != "" and _clip_map.has(callout_act)
	var want: = "idle"
	if gesturing:
		want = callout_act
	elif action != "" and _clip_map.has(action):
		want = action
	elif not grounded:
		want = "jump_rise" if vel_y > 0.5 else "jump_fall"
	elif planar_speed > 1.2:
		want = "run"

	if gesturing and loco != "" and loco != "idle" and _clip_map.has(loco):
		_callout_loco_anim = _anim.get_animation(_clip_map[loco])
	else:
		_callout_loco_anim = null


	if want == "set" and not grounded and _clip_map.has("set_air"):
		want = "set_air"
	elif want == "set_back" and not grounded and _clip_map.has("set_back_air"):
		want = "set_back_air"




	if want == "spike" and spike_light:
		want = "spike_light"
	if want == "block_hit" and block_out and _clip_map.has("block_hit_ot"):
		want = "block_hit_ot"
	if want == "jump_rise":
		want = _jump_rise_take()
	if _left_handed and _clip_map.has(want + "_L"):
		want += "_L"
	var clip: String = _clip_map.get(want, "")


	if replay_clip_active():
		clip = replay_clip
		want = _want_for_clip(clip, want)
	if clip == "":
		return
	if clip != _current:
		_current = clip







		var base_want: = want.trim_suffix("_L")
		var blend: = 0.0 if playback_scale <= 0.0\
		else (BLEND_SNAP if base_want in SNAP_ACTIONS else BLEND)



		if playback_scale > 0.0 and _last_want.begins_with("sprint")\
		and base_want in ["run", "idle"]:
			blend = SPRINT_OUT_BLEND
		_anim.play(clip, blend)




		if blend <= 0.0 and playback_scale > 0.0:



			if want.begins_with("spike"):
				_anim.seek((SPIKE_STRIKE_FRAME - CLIP_START_FRAME) / ANIM_FPS, true)
			else:
				_anim.advance(0.0)
	_last_want = want









	if charge_scrub >= 0.0 and want == "approach" and playback_scale > 0.0:
		var a: = _anim.get_animation(clip)
		if a != null:
			_anim.seek(clampf(charge_scrub, 0.0, 1.0) * a.length, true)
			_anim.speed_scale = 0.0
			return
	var pace: = 1.0
	if want in PACED_CLIPS:
		var nominal: = pace_speed if pace_speed > 0.01 else PACE_REF
		pace = clampf(planar_speed / nominal, PACE_MIN, PACE_MAX)


	_anim.speed_scale = 0.0 if hold_frame else playback_scale * pace * gait_fatigue
