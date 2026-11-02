class_name Player
extends CharacterBody3D




enum ContactState{IDLE, WINDUP, BLOCK, RECOVER}



enum TouchKind{NONE, BUMP, SET, SPIKE, DUMP, BLOCK, CAROM}

const CAROM_COLOR: = Color(1.0, 0.45, 0.4)




static var FEEL: PlayerFeel = preload("res://game/player/player_feel.tres")

const NET_FLOATS: = 25




const COMBO_SPIKE_BONUS: = 1.2





const POSE_IDLE_L: = Vector3(-0.45, 0.65, 0.1)
const POSE_IDLE_R: = Vector3(0.45, 0.65, 0.1)
const POSE_BUMP_L: = Vector3(-0.12, 0.35, 0.5)
const POSE_BUMP_R: = Vector3(0.12, 0.35, 0.5)
const POSE_SET_L: = Vector3(-0.22, 1.65, 0.25)
const POSE_SET_R: = Vector3(0.22, 1.65, 0.25)



const POSE_SERVE_L: = Vector3(-0.3, 0.95, 0.62)
const POSE_SERVE_R: = Vector3(0.3, 0.95, 0.62)









const POSE_SPIKE_HIT: = Vector3(-0.42, 1.92, -0.48)
const POSE_SPIKE_GUIDE: = Vector3(0.34, 1.82, 0.42)



const POSE_CHEER_L: = Vector3(-0.5, 1.55, 0.12)
const POSE_CHEER_R: = Vector3(0.5, 1.55, 0.12)
const CEL_HF_REACH: = 0.32
const CEL_HF_RETURN: = 0.5



const POSE_FOLLOW: = {
	TouchKind.BUMP: [Vector3(-0.12, 1.15, 0.55), Vector3(0.12, 1.15, 0.55)], 
	TouchKind.SET: [Vector3(-0.26, 1.95, 0.2), Vector3(0.26, 1.95, 0.2)], 
	TouchKind.SPIKE: [Vector3(-0.34, 0.62, 0.6), Vector3(0.36, 0.5, -0.05)], 
	TouchKind.DUMP: [Vector3(-0.25, 1.6, 0.1), Vector3(0.3, 1.4, 0.5)], 
}



const RECOIL_DIR: = {
	TouchKind.BUMP: Vector3(0.0, -0.94, -0.34), 
	TouchKind.SET: Vector3(0.0, 0.95, -0.31), 
	TouchKind.BLOCK: Vector3(0.0, 0.2, -0.98), 
}















const COMBO_COLORS: Array[Color] = [
	Color(0.24, 0.68, 1.0, 1.0), 
	Color(0.32, 0.88, 0.52, 1.0), 
	Color(1.0, 0.82, 0.2, 1.0), 
]











const FAST_DIG_VOICE: = "v_dive"

static func dig_weight_of(kind: int, incoming_vel: Vector3) -> float:
	if kind != TouchKind.BUMP:
		return 0.0
	var incoming_h: = Vector2(incoming_vel.x, incoming_vel.z).length()
	return clampf(incoming_h / FEEL.receive_plant_speed, 0.0, 1.0)

static func is_fast_dig(kind: int, dig_weight: float) -> bool:
	return kind == TouchKind.BUMP and dig_weight >= FEEL.fast_dig_weight

static func combo_color(count: int) -> Color:
	return COMBO_COLORS[clampi(count - 1, 0, COMBO_COLORS.size() - 1)]

signal touched(kind: int)



signal swung(kind: int)


signal voiced(bank: String, pitch: float)
signal float_shown(text: String, color: Color, priority: bool)
signal combo_shown(count: int, fail: bool)



signal thumped(pos: Vector3, strength: float)




signal knock_started(pos: Vector3, strength: float)
signal touch_attempted
signal out_of_range
signal launched(pos: Vector3, charge: float)



signal jumped(bam: bool)
signal callout_made(idx: int)



signal high_fived(pos: Vector3)
signal block_broken(pos: Vector3)



signal dove_into_net











const CALLOUTS: = [
	{"t": "I got it!", "c": Color.WHITE, "v": "v_call_igot"}, 
	{"t": "Nice!", "c": Color.WHITE, "v": "v_call_nice"}, 
	{"t": "Sorry!", "c": Color.WHITE, "v": "v_call_sorry"}, 
	{"t": "Don't mind!", "c": Color.WHITE, "v": "v_call_dm"}, 
	{"t": "One touch!", "c": Color.WHITE, "v": "v_call_onetouch"}, 
	{"t": "Yeah!", "c": Color(1.0, 0.86, 0.32)}, 


	{"t": "Thanks!", "c": Color.WHITE, "v": "v_call_thanks"}, 
	{"t": "Quick!", "c": Color.WHITE, "v": "v_call_quick"}, 
	{"t": "High!", "c": Color.WHITE, "v": "v_call_high"}, 
]
const CALLOUT_ONE_TOUCH: = 4
const CALLOUT_YEAH: = 5


const QUICK_CHAT: = [0, 1, 2, 3, 6, 7, 8]
const QUICK_CHAT_ACTIONS: = ["callout_1", "callout_2", "callout_3", "callout_4", 
	"callout_5", "callout_6", "callout_7"]

static func is_quick_chat(idx: int) -> bool:
	return idx in QUICK_CHAT




const CALL_VARIANTS: = 60
var last_call_variant: = 0






const CALLOUT_GESTURES: = {
	0: {"clip": "igot", "handed": true}, 
	1: {"shuffle": "nice", "still": true}, 
}
const GESTURE_STILL_SPEED: = 0.6
const GESTURE_SHUFFLE_MAX: = 9






const CALLOUT_BURST: = 4
const CALLOUT_BURST_WINDOW_MS: = 8000
const CALLOUT_COOLDOWN_MS: = 5000


const CALL_SLACK_MS: = 300





const CALL_VOICE_DB: = -8.0
enum CallResult{OK, TALKING, COOLING, REFUSED}
var _call_talk_until: = 0
var _call_cool_until: = 0
var _call_stamps: Array = []

var ball: Ball
var is_bot: = false


var is_captain: = false
static var DEBUG_HIT: = false
static var _dbg_hit_file: FileAccess = null
var claiming: = false
var quick_check: = Callable()
var contact_priority_check: = Callable()
var last_touch_power: = 0.0



var last_touch_charge: = 0.0
var _release_charge: = 0.0


var last_receive_weight: = 0.0
var last_perfect: = false
var team_side: = 0
var roster: Array = []

var touch_barred: = false



var contact_enabled: = true





var free_actions: = false




var stamina_unlimited: = false





var touch_barred_self: = false


var touch_bar_reason: = 0





var rivals_can_play: = true








func contact_barred() -> bool:
	return touch_barred and not ( not is_bot and touch_bar_reason == Rules.Bar.THREE_TOUCH)



var serving: = false



var serve_squares: = true
var dive_cooldown: = 0.0





var stamina: = 0.0
var stamina_locked: = false

var sprinting: = false
var _sprint_ramp: = 0.0


var _dive_weak: = false
var _dive_span: = 0.0
var _dive_strength_cached: = 1.0


var _downed_hold: = false


var _sprint_anim_prev: = false
var _sprint_start_t: = 0.0
var _stam_idle: = 0.0
var _burnout_hold: = 0.0

const DIVE_DENY_TIME: = 0.35
const DIVE_DENY_COLOR: = Color(1.0, 0.28, 0.28, 1.0)
var _dive_deny_t: = 0.0

func dive_denied() -> void :
	_dive_deny_t = DIVE_DENY_TIME









const SPRINT_CHARGE_GRACE: = 0.5
func sprint_start_blocked() -> bool:
	if sprinting or _jump_charge <= 0.0:
		return false
	return _jump_charge > FEEL.jump_charge_time * SPRINT_CHARGE_GRACE\
	or _jump_full_time > 0.0



func _tick_stamina(input: PlayerInput, delta: float) -> void :










	if cinematic_hidden or stamina_unlimited:
		stamina = FEEL.stamina_max
		stamina_locked = false
		_burnout_hold = 0.0
		_stam_idle = 0.0
		sprinting = input.sprint_held and not sprint_start_blocked()\
		and _move_intent.length() > 0.2\
		and is_on_floor() and not diving() and not getting_up()\
		and _knock_time <= 0.0
		if sprinting:
			_sprint_ramp = minf(_sprint_ramp + FEEL.sprint_ramp_up * delta, 1.0)
		else:
			_sprint_ramp = maxf(_sprint_ramp - FEEL.sprint_ramp_down * delta, 0.0)
		return





	var wants: = input.sprint_held and not stamina_locked\
	and not sprint_start_blocked()\
	and _move_intent.length() > 0.2\
	and is_on_floor() and not diving() and not getting_up()\
	and _knock_time <= 0.0




	sprinting = wants and stamina > 0.0






	if sprinting and _receive_pose > 0.0 and not contact_intent_queued():
		_receive_pose = 0.0
		if contact_state == ContactState.RECOVER:
			contact_state = ContactState.IDLE


	if sprinting:
		_sprint_ramp = minf(_sprint_ramp + FEEL.sprint_ramp_up * delta, 1.0)
	else:
		_sprint_ramp = maxf(_sprint_ramp - FEEL.sprint_ramp_down * delta, 0.0)
	if sprinting:
		stamina = maxf(stamina - FEEL.stamina_sprint_drain * delta, 0.0)
		_stam_idle = 0.0
		if stamina <= 0.0:

			_begin_lockout()
			sprinting = false
		return










	if _sprint_ramp > 0.0 and not stamina_locked and is_on_floor() and _move_intent.length() > 0.2:
		stamina = maxf(stamina - FEEL.stamina_sprint_drain * _sprint_ramp * delta, 0.0)
		_stam_idle = 0.0
		if stamina <= 0.0:
			_begin_lockout()
		return


	if not is_on_floor():
		return



	_stam_idle += delta
	if stamina_locked:



		if _burnout_hold > 0.0:
			_burnout_hold = maxf(_burnout_hold - delta, 0.0)
			return


		var burn_rate: = FEEL.stamina_recover_regen
		if _move_intent.length() > 0.2:
			burn_rate *= FEEL.stamina_recover_moving
		stamina = minf(stamina + burn_rate * delta, FEEL.stamina_max)
		if stamina >= FEEL.stamina_max * FEEL.stamina_recover_to:
			stamina_locked = false
		return
	if _stam_idle >= FEEL.stamina_regen_delay:
		stamina = minf(stamina + FEEL.stamina_regen * delta, FEEL.stamina_max)







func reset_rally_local_state() -> void :
	dive_cooldown = 0.0
	stamina = FEEL.stamina_max
	stamina_locked = false
	_burnout_hold = 0.0
	_stam_idle = 0.0





func _pick_jump_take(charge: float, bam: bool) -> int:
	if bam:
		return 1
	if charge < FEEL.jump_big_take_charge:
		return 0
	if stamina_locked or stamina_frac() < FEEL.stamina_low_frac:
		return 0
	return 1

func stamina_frac() -> float:
	return clampf(stamina / maxf(FEEL.stamina_max, 0.001), 0.0, 1.0)



func dive_is_weak() -> bool:
	return stamina_locked or stamina < FEEL.stamina_dive_cost



func _dive_strength() -> float:
	if stamina_locked:
		return FEEL.dive_weak_speed
	var f: = clampf(stamina / FEEL.stamina_dive_cost, 0.0, 1.0)
	return lerpf(FEEL.dive_weak_speed, 1.0, f)






func can_side_dive() -> bool:
	if stamina_locked:
		return false
	var after: = stamina - FEEL.stamina_dive_cost
	return after >= FEEL.stamina_max * FEEL.stamina_low_frac



func _sprint_speed_mul() -> float:



	return maxf(1.0, lerpf(FEEL.sprint_speed_empty, FEEL.sprint_speed, 
		stamina_frac()))

func _spend_stamina(amount: float) -> void :
	stamina = maxf(stamina - amount, 0.0)
	_stam_idle = 0.0
	if stamina <= 0.0:
		_begin_lockout()



func _begin_lockout() -> void :
	stamina_locked = true
	_burnout_hold = FEEL.stamina_burnout_hold
var contact_state: = ContactState.IDLE
var hold_time: = 0.0
var _hold_real: = 0.0
const POWER_LEVELS: = 16
var power_level: int = 12
var serve_style: = {}
var _set_back: = false
var _prev_q: = false
var _prev_e: = false
var _prev_hotkeys: = {}

const SPIKE_POWER_MAX: = 1.45

func _spike_overdrive() -> float:
	if is_bot:
		return 0.0
	return clampf((float(power_level) - 12.0) / 4.0, 0.0, 1.0) * 0.45

func _contact_finesse(kind: TouchKind) -> bool:
	if not is_bot and kind == TouchKind.SPIKE:
		return false
	return _hold_real <= FEEL.tap_hold
var last_touch: = TouchKind.NONE
var last_touch_quick: = false
var aim_point: = Vector3.ZERO
var block_lane: = 0







const SPIKE_TURN_FREE: = 0.6
const SPIKE_TURN_FLOOR: = 0.12
var _charge_turn: = 0.0
var _charge_yaw: = 0.0
var _charge_yaw_frame: = -1

static func spike_turn_keep(turn: float) -> float:
	return lerpf(1.0, SPIKE_TURN_FLOOR, smoothstep(SPIKE_TURN_FREE, PI, turn))

var _block_ot: = false
var _block_broken_flag: = false






var _recoil: = 0.0
var _recoil_vel: = 0.0
var _recoil_kind: = TouchKind.NONE
var _recoil_tick: = false

var _recover_left: = 0.0
var _jump_charge: = 0.0






var _jump_canceled: = false
var _jump_cancel_fresh: = false
var _cancel_input_prev: = false


var _jump_held_prev: = false
var _air_jump_taps: = 0
var _move_intent: = Vector2.ZERO
var _block_time: = 0.0
var _block_shifted: = false
var _shift_from: = 0
var _shift_progress: = 1.0
var _block_hit_cooldown: = 0.0
var _dive_time: = 0.0
var _dive_dir: = Vector3.ZERO





var _dive_side: = 0


var _kick_foot: = 0
var _kick_was_spike: = false


var team_touches: = 0



var _receive_side: = 0


var _set_low: = false
var _serve_toss_lift: = 0.0



var _hitstop_hold: = 0.0
var _puppet_hitstop: = false
var _gait_phase: = 0.0
var _land_pulse: = 0.0
var _launch_pulse: = 0.0
var _launch_vel: = 0.0
var _squash_y: = 1.0


var _charge_buzz: = 0.0
var _pre_move_grounded: = true
var _pre_move_vy: = 0.0
var _knock_time: = 0.0
var _getup_time: = 0.0
var _plant_time: = 0.0
var _plant_cd: = 0.0
var _receive_pose: = 0.0



var _knock_roll: = 0.0




var _settle_time: = 0.0
var _land_time: = 0.0
var _was_knocked: = false
var _was_diving: = false
var _was_getting_up: = false
var _was_airborne: = false
var _air_boost: = 0.0
var _was_knocked_getup: = false
var _air_spent: = false

var _receive_hold_spent: = false


var _receive_window: = 0.0
var _ball_seen_pos: = Vector3.ZERO
var _ball_sweep_from: = Vector3.ZERO
var _ball_sweep_valid: = false
var _ball_seen_valid: = false
var _reach_left: = 0.0
var _armed_power: = 0.0
var _armed_finesse: = true
var _armed_quick: = false
var _armed_dump: = false


var _dump_rise: = -1.0
var _dump_push_left: = 0.0
var _queued_fill: = 0.0
var _armed_set_button: = false
var _armed_aim: = Vector3.ZERO
var _armed_influence: = Vector2.ZERO
var _armed_kind: = TouchKind.NONE
var _set_windup: = false
var _armed_from_ground: = false
var _armed_wait_for_release: = false
var _queue_swung: = false
var _contact_button_held: = false
var _intent_used_strike: = -1
var _intent_queued_at_usec: = 0


const JUMP_SPIKE_GRACE_US: = 140000




var _queue_reach_seen: = false
var _early_contact_from_ground: = false
var early_contact_seq: = 0
var _dive_touched: = false
var _dive_receive: = false
var dive_aim_error: = 0.0




var _spike_light: = false




var _jump_variant: = 0






var _touch_lock: = 0.0
var _strafe_held: = false
var charge_ui_enabled: = true
var serve_charge_ui: = false
var _serve_ui_was: = false
var _serve_hold_stale: = false
var sweat: = 0.0

const RING_COLORS: = {
	TouchKind.BUMP: Color(1.0, 0.6, 0.2, 1.0), 
	TouchKind.SET: Color(0.3, 0.85, 1.0, 1.0), 
	TouchKind.SPIKE: Color(1.0, 0.3, 0.25, 1.0), 
	TouchKind.DUMP: Color(0.8, 0.45, 1.0, 1.0), 
	TouchKind.NONE: Color(0.8, 0.8, 0.8, 1.0), 
	TouchKind.BLOCK: Color(0.8, 0.8, 0.8, 1.0), 
}

@onready var visual: Node3D = $Visual
@onready var body: MeshInstance3D = $Visual / Body
@onready var hand_l: Node3D = $Visual / HandL
@onready var hand_r: Node3D = $Visual / HandR
@onready var drop_shadow: MeshInstance3D = $DropShadow
@onready var indicator_ring: MeshInstance3D = $IndicatorRing
var _ind_mat: ShaderMaterial = null
var _dive_ring_fade: = 0.0
@onready var air_trail: PlayerTrail = $AirTrail

var indicator_enabled: = false
var cinematic_hidden: = false
@onready var charge_ui: Node3D = $ChargeUi
@onready var charge_ring: MeshInstance3D = $ChargeUi / Ring
@onready var float_label: Label3D = $FloatText
@onready var callout_label: Label3D = $Callout
@onready var combo_badge: Node3D = $ComboBadge
@onready var combo_disc: MeshInstance3D = $ComboBadge / Disc
@onready var combo_count: Label3D = $ComboBadge / Count

var _float_tween: Tween
var _combo_tween: Tween
var _callout_tween: Tween
var _float_priority: = false
var _float_shake_t: = 0.0
var _float_base_pos: = Vector3.INF
var _slip_grace: = 0.0



var _restless: = 0.0
var _restless_dir: = Vector2.ZERO


var mirror_off: = false




var sim_step_scale: = 1.0
var _far_overlays_hidden: = false
var _jump_full_time: = 0.0


var _trail_hand_l: HandTrail
var _trail_hand_r: HandTrail
var _hand_scale_base: = 1.0
var _hand_emph_l: = 1.0
var _hand_emph_r: = 1.0





var _cel_state: = 0
var _cel_t: = 0.0
var _cel_hf_t: = 0.0
var _cel_meet: = Vector3.ZERO
var _cel_hand: = -1
var _cel_slapped: = false





var sim_authority: = true
var net_puppet: = false


var touch_seq: = 0
var _puppet_grounded: = true

func grounded() -> bool:
	return _puppet_grounded if net_puppet else is_on_floor()


func is_strafing() -> bool:
	return _strafe_held

var _model: ModelRig = null


var _idle_l: = POSE_IDLE_L
var _idle_r: = POSE_IDLE_R




const REFLECT_FLIP: = Basis(Vector3(1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, 1))


var enable_reflection: = true





var far_lod: = false
var _reflect_root: Node3D = null
var _reflect_model: ModelRig = null
var _reflect_hands: Array = []
var _reflect_body: MeshInstance3D = null





func face_net() -> void :
	visual.rotation.y = PI if team_side > 0 else 0.0

func _ready() -> void :
	stamina = FEEL.stamina_max
	add_to_group(ShadowSun.CASTERS)

	add_to_group("power_bar_players")

	GameConfig.compat_dim(drop_shadow.get_active_material(0) as BaseMaterial3D)
	GameConfig.stencil_shadow(drop_shadow.get_active_material(0) as BaseMaterial3D)
	charge_ui.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


	_trail_hand_l = HandTrail.new()
	_trail_hand_l.life = 0.22
	_trail_hand_l.width = 0.11
	hand_l.add_child(_trail_hand_l)
	_trail_hand_r = HandTrail.new()
	_trail_hand_r.life = 0.15
	_trail_hand_r.width = 0.08
	hand_r.add_child(_trail_hand_r)

	float_label.render_priority = 20
	callout_label.render_priority = 21
	($NameTag as Label3D).render_priority = 20


	for over_head: Node3D in [float_label, callout_label, $NameTag]:
		over_head.position.y += HEAD_LIFT
	if team_side == 0:
		team_side = 1 if global_position.z > 0.0 else -1

	face_net()




	stencil_id = 1 + _next_stencil % GameConfig.BODY_STENCIL_IDS
	_next_stencil += 1
	if ModelRig.available():
		var rig: = ModelRig.new()
		rig.stencil_id = stencil_id

		visual.add_child(rig)
		if rig.setup():
			_model = rig
			body.visible = false


			if rig.hand_radius > 0.0:
				var s: = rig.hand_radius / FEEL.hand_mesh_radius
				_hand_scale_base = s
				hand_l.scale = Vector3.ONE * s
				hand_r.scale = Vector3.ONE * s
				_idle_r = rig.hand_rest
				_idle_l = Vector3( - rig.hand_rest.x, rig.hand_rest.y, 
					rig.hand_rest.z)
		else:
			rig.queue_free()
			_model = null

func simulate(input: PlayerInput, delta: float) -> void :



	var _was_contact_held: = _contact_button_held
	_contact_button_held = input.contact_pressed
	if not is_bot and input.contact_pressed and not _was_contact_held:
		_hold_real = FEEL.tap_hold + 0.1


	if not input.contact_pressed:
		_receive_hold_spent = false
	_poll_power_keys()
	_tick_serve_hold(input)
	aim_point = input.aim
	_capture_ball_step()
	_move_intent = input.move
	_strafe_held = input.strafe_held







	var ss_now: = input.set_pressed or input.strafe_held
	_jump_cancel_fresh = not is_bot and ss_now and not _cancel_input_prev
	_cancel_input_prev = ss_now
	dive_cooldown = maxf(dive_cooldown - delta, 0.0)
	_tick_stamina(input, delta)
	if GameConfig.no_cooldowns:

		dive_cooldown = 0.0
		_block_hit_cooldown = 0.0
		stamina = FEEL.stamina_max
		stamina_locked = false





	if stamina_locked and _getup_time > 0.0:
		pass
	else:
		_getup_time = maxf(_getup_time - delta, 0.0)



	_downed_hold = stamina_locked and _getup_time > 0.0 and not knocked()
	_plant_time = maxf(_plant_time - delta, 0.0)
	_plant_cd = maxf(_plant_cd - delta, 0.0)
	_receive_pose = maxf(_receive_pose - delta, 0.0)
	_touch_lock = maxf(_touch_lock - delta, 0.0)
	_land_time = maxf(_land_time - delta, 0.0)
	_settle_time = maxf(_settle_time - delta, 0.0)
	_slip_grace = maxf(_slip_grace - delta, 0.0)
	if _cel_state > 0:
		_cel_t += delta
		if _cel_state == 2:
			_cel_hf_t += delta

			if not _cel_slapped and _cel_hf_t >= CEL_HF_REACH:
				_cel_slapped = true
				high_fived.emit(_cel_meet)

			if _cel_hf_t >= CEL_HF_REACH + CEL_HF_RETURN:
				_cel_state = 1
				_cel_hf_t = 0.0
				_cel_slapped = false




	_restless = maxf(_restless - delta * 0.6, 0.0)
	var flat_run: = Vector2(velocity.x, velocity.z)
	if is_on_floor() and flat_run.length() > 2.0:
		var run_dir: = flat_run.normalized()
		if _restless_dir != Vector2.ZERO and run_dir.dot(_restless_dir) < -0.2:
			_restless = minf(_restless + 1.0, FEEL.restless_full)
			_restless_dir = run_dir
		else:
			_restless_dir = _restless_dir.lerp(run_dir, minf(delta * 6.0, 1.0))
			if _restless_dir.length() > 0.05:
				_restless_dir = _restless_dir.normalized()
	else:
		_restless_dir = Vector2.ZERO
	_puppet_action_t = maxf(_puppet_action_t - delta, 0.0)
	_reach_left = FEEL.reach_coyote\
	if contact_enabled and ball != null and not ball.frozen and _swing_reach_check()\
	else maxf(_reach_left - delta, 0.0)



	if _receive_window > 0.0 and _armed_from_ground and not grounded()\
	and not is_bot and _armed_kind == TouchKind.SET and _armed_set_button:






		_armed_from_ground = false
	elif _receive_window > 0.0 and _armed_from_ground and not grounded():








		if not is_bot:
			_intent_used_strike = -1
		_clear_contact_intent()
	if contact_enabled and _receive_window > 0.0:











		var held_in_reach: = _airborne_attack_armed()\
		or (_armed_wait_for_release\
		and contact_state == ContactState.WINDUP and _swing_reach_check())



		if _armed_kind != TouchKind.NONE and not _queue_reach_seen\
		and _swing_reach_check():
			_queue_reach_seen = true
		if not held_in_reach and not _queued_ball_incoming():
			_receive_window = maxf(_receive_window - delta, 0.0)
		if _receive_window > 0.0:
			_try_armed_receive()
		else:




















			if not is_bot:
				_intent_used_strike = -1
			elif TeamBot.DEBUG_AI and ball != null:
				print("[CLR %s] window-expired kind=%d y=%.2f flat=%.2f reach=%s" % [name, 
					_armed_kind, ball.global_position.y, 
					Vector2(ball.global_position.x - global_position.x, 
					ball.global_position.z - global_position.z).length(), 
					str(_swing_reach_check())])
			_clear_contact_intent()


			if contact_state == ContactState.WINDUP and _armed_kind == TouchKind.NONE:
				contact_state = ContactState.IDLE
				hold_time = 0.0
				_hold_real = 0.0






	if contact_enabled and not _dive_touched\
	and (_dive_time > 0.0 or (getting_up() and not _was_knocked_getup)):
		_try_dive_receive()



	if input.dive_pressed and is_on_floor()\
	and _dive_time <= 0.0 and _getup_time <= 0.0:
		_start_dive(input.aim, input.dive_dir, input.dive_side)
	elif input.block_pressed and not is_on_floor() and _knock_time <= 0.0\
	and _dive_time <= 0.0 and not net_puppet and not _air_spent\
	and contact_state == ContactState.IDLE:






		_start_block(input)



	var jump_edge: = input.jump_held and not _jump_held_prev
	_jump_held_prev = input.jump_held





	if not input.jump_held and not input.jump_released:
		_jump_canceled = false
	if is_on_floor():
		_air_jump_taps = 0
	elif jump_edge and _knock_time <= 0.0 and _dive_time <= 0.0 and not net_puppet:
		_air_jump_taps += 1
		if _air_jump_taps >= 3:
			knock(Vector3(velocity.x * 0.4, 1.5, velocity.z * 0.4))
			_air_jump_taps = 0
	_pre_move_grounded = is_on_floor()
	_pre_move_vy = velocity.y
	_move(input, delta)
	_separate_from_players(delta)
	if _was_diving and _dive_time <= 0.0 and _getup_time <= 0.0:



		_getup_time = 0.0 if _dive_side != 0 else FEEL.getup_time
		_was_knocked_getup = false
	_was_diving = _dive_time > 0.0
	if _was_knocked and _knock_time <= 0.0:


		visual.rotation.x = wrapf(visual.rotation.x, - PI, PI)
		visual.rotation.z = wrapf(visual.rotation.z, - PI, PI)
		_was_knocked_getup = lying_on_back()


		_getup_time = FEEL.getup_knock_time if _was_knocked_getup else FEEL.getup_time
	_was_knocked = _knock_time > 0.0
	if not _pre_move_grounded and is_on_floor():
		_land_pulse = clampf(absf(_pre_move_vy) * 0.08, 0.25, 1.0)




		if _dive_time <= 0.0 and _knock_time <= 0.0:
			_launch_pulse = - FEEL.land_pop\
			* clampf(absf(_pre_move_vy) / FEEL.jump_max_velocity, 0.35, 1.0)
			_launch_vel = 0.0



		if absf(_pre_move_vy) > FEEL.land_min_fall and _dive_time <= 0.0\
		and _knock_time <= 0.0 and _getup_time <= 0.0:
			_land_time = lerpf(FEEL.land_pose_min, FEEL.land_pose_max, _land_pulse)







	if _was_getting_up and _getup_time <= 0.0:
		settle(FEEL.settle_time_hard)
	_was_getting_up = _getup_time > 0.0
	_turn(delta)
	_set_contact(input, delta)
	_contact(input, delta)
	_drive_magnet_lean()
	_pose(delta)
	drop_shadow.global_position = Vector3(global_position.x, maxf(0.02, SandDeform.feet_y()), global_position.z)
	drop_shadow.visible = not ShadowSun.casting
	var shadow_scale: = clampf(1.0 - global_position.y * 0.08, 0.55, 1.0)
	drop_shadow.scale = Vector3(shadow_scale, 1.0, shadow_scale)
	_present_indicators(delta)





func _present_indicators(delta: float) -> void :


	indicator_ring.visible = indicator_enabled and not cinematic_hidden
	if indicator_ring.visible:
		indicator_ring.global_position = Vector3(
			global_position.x, maxf(0.045, SandDeform.feet_y()), global_position.z)
		indicator_ring.rotation.y = visual.rotation.y
		var ring_scale: = clampf(1.0 + global_position.y * 0.22, 1.0, 1.9)
		indicator_ring.scale = Vector3(ring_scale, 1.0, ring_scale)





		if _ind_mat == null:
			_ind_mat = indicator_ring.get_active_material(0) as ShaderMaterial





		if _dive_deny_t > 0.0:
			_dive_deny_t = maxf(_dive_deny_t - delta, 0.0)
			var k: = _dive_deny_t / DIVE_DENY_TIME
			indicator_ring.global_position += Vector3(
				sin(_dive_deny_t * 70.0) * 0.07 * k, 0.0, cos(_dive_deny_t * 55.0) * 0.04 * k)
		if _ind_mat != null:




			_ind_mat.set_shader_parameter("progress", stamina_frac())





			var _cam: = get_viewport().get_camera_3d()
			if _cam != null:
				var _to_cam: = _cam.global_position - indicator_ring.global_position
				var _loc: = indicator_ring.global_transform.basis.orthonormalized()\
				.inverse() * _to_cam
				_ind_mat.set_shader_parameter("progress_center", 
					fposmod(atan2(_loc.x, _loc.z) / TAU, 1.0))
			var wheel_col: Color = FEEL.dive_ring_color
			if stamina_locked:
				wheel_col = FEEL.stamina_empty_color
			else:


				var fuel: = stamina_frac()
				var amber: = Color(1.0, 0.52, 0.12, 1.0)
				if fuel >= 0.35:
					wheel_col = wheel_col.lerp(amber, 
						clampf((0.65 - fuel) / 0.3, 0.0, 1.0))
				else:
					wheel_col = amber.lerp(FEEL.stamina_empty_color, 
						clampf((0.35 - fuel) / 0.35, 0.0, 1.0))
			if _dive_deny_t > 0.0:
				wheel_col = wheel_col.lerp(DIVE_DENY_COLOR, 
					clampf(_dive_deny_t / DIVE_DENY_TIME * 1.5, 0.0, 1.0))



			if ring_tint.a > 0.0:
				wheel_col = wheel_col.lerp(ring_tint, 0.22)
			_ind_mat.set_shader_parameter("progress_color", wheel_col)


	var fill: = 0.0
	var ring_color: = FEEL.ring_jump
	if contact_state == ContactState.WINDUP:













		var spike_windup: = _windup_pose_kind() == TouchKind.SPIKE\
		or ( not is_on_floor() and not _armed_set_button\
		and _armed_kind != TouchKind.SET and _armed_kind != TouchKind.BUMP)
		var charged_action: = serve_charge_ui or _armed_set_button or spike_windup
		if charged_action:
			fill = hold_power()
			if serve_charge_ui:
				ring_color = FEEL.ring_serve
			elif _armed_set_button:



				ring_color = RING_COLORS[TouchKind.DUMP]\
				if set_dump_intent(_dump_push_left > 0.0)\
				else RING_COLORS.get(TouchKind.SET, FEEL.ring_jump)
			else:






				var live_kind: = _windup_pose_kind()
				if not is_on_floor() and (live_kind == TouchKind.SET or live_kind == TouchKind.DUMP):
					ring_color = RING_COLORS[live_kind]
				else:
					ring_color = RING_COLORS.get(TouchKind.SPIKE, FEEL.ring_jump)
	elif contact_intent_queued() and _armed_kind != TouchKind.BUMP and _queued_fill > 0.0:




		fill = _queued_fill
		var queued_kind: = _armed_kind
		if _armed_kind == TouchKind.SET and set_dump_intent(_armed_dump or _dump_push_left > 0.0):
			queued_kind = TouchKind.DUMP
		ring_color = RING_COLORS.get(queued_kind, FEEL.ring_jump)
	var jump_fill: = false
	if contact_state != ContactState.WINDUP and is_on_floor() and _jump_charge > 0.02:
		fill = _jump_charge / FEEL.jump_charge_time
		jump_fill = true
	charge_ui.visible = fill > 0.02 and charge_ui_enabled and not cinematic_hidden
	if charge_ui.visible:
		var cam: = get_viewport().get_camera_3d()
		var toward: = Vector3.ZERO
		var side_off: = Vector3.ZERO
		if cam != null:
			toward = cam.global_position - global_position
			toward.y = 0.0
			toward = toward.normalized() * 0.5
			side_off = cam.global_basis.x
			side_off.y = 0.0
			side_off = side_off.normalized() * 0.6
		charge_ui.global_position = global_position + Vector3(0.0, 0.5, 0.0)\
		+ toward + side_off
		var ring_mat: ShaderMaterial = (charge_ring.mesh as QuadMesh).material
		ring_mat.set_shader_parameter("fill", fill)
		ring_mat.set_shader_parameter("fill_color", ring_color)



		var ready: = fill >= 0.999
		ring_mat.set_shader_parameter("ready", 1.0 if ready else 0.0)



		var bam_shine: = jump_fill and not is_bot and ready\
		and _jump_full_time >= FEEL.bam_delay\
		and _jump_full_time <= FEEL.bam_delay + FEEL.bam_window
		ring_mat.set_shader_parameter("bam", 1.0 if bam_shine else 0.0)



		var lead: = 0.0
		if jump_fill and not is_bot and ready and not bam_shine\
		and _jump_full_time < FEEL.bam_delay:
			lead = clampf(1.0 - (FEEL.bam_delay - _jump_full_time)\
			/ maxf(FEEL.bam_lead_time, 0.001), 0.0, 1.0)
		ring_mat.set_shader_parameter("bam_lead", lead)



		var ring_scale: = 1.14 if ready else 1.0
		if bam_shine:
			var throb: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * 7.0)
			ring_scale = lerpf(1.22, 1.42, throb)
		charge_ui.scale = Vector3.ONE * ring_scale


func _poll_power_keys() -> void :
	if is_bot or net_puppet:
		return
	_poll_power_hotkeys()
	var q: = Input.is_key_pressed(KEY_Q)
	var e: = Input.is_key_pressed(KEY_E)
	if not q and not e:
		_prev_q = false
		_prev_e = false
		return
	var foc: = get_viewport().gui_get_focus_owner()
	if foc is LineEdit or foc is TextEdit or UiStyle.dialog_active():
		_prev_q = q
		_prev_e = e
		return
	if ball == null:
		_prev_q = q
		_prev_e = e
		return
	if q and not _prev_q:
		power_level = clampi(power_level - 1, 1, POWER_LEVELS)
	if e and not _prev_e:
		power_level = clampi(power_level + 1, 1, POWER_LEVELS)
	_prev_q = q
	_prev_e = e

func _poll_power_hotkeys() -> void :
	var keys: Array = GameConfig.power_keys
	if keys.is_empty():
		return
	var foc: = get_viewport().gui_get_focus_owner()
	if foc is LineEdit or foc is TextEdit or UiStyle.dialog_active():
		_prev_hotkeys.clear()
		return
	for ent in keys:
		if not (ent is Dictionary):
			continue
		var ident: = "%s:%d" % [String(ent.get("t", "key")), int(ent.get("c", 0))]
		if int(ent.get("c", 0)) == 0:
			continue
		var pressed: = false
		match String(ent.get("t", "key")):
			"key":
				pressed = Input.is_physical_key_pressed(int(ent.get("c", 0)))
			"mouse":
				pressed = Input.is_mouse_button_pressed(int(ent.get("c", 0)))
		var was: = bool(_prev_hotkeys.get(ident, false))
		if pressed:
			_prev_hotkeys[ident] = true
		else:
			_prev_hotkeys.erase(ident)
		if pressed and not was:
			power_level = GameConfig.power_disp_level(
				clampi(int(ent.get("pow", 0)), 1, GameConfig.power_cap))


func serve_auto_strike() -> void :
	if ball == null or is_bot or not ball.serve_assist:
		return
	if serve_style.size() > 0:
		return
	_do_touch(TouchKind.SPIKE, clampf(hold_power(), 0.05, 1.0), false, Vector2.ZERO, false)





var names_suppressed: = false

func suppress_names(on: bool) -> void :
	names_suppressed = on
	if on:
		show_seat_badge(false)



	($NameTag as Label3D).visible = not on



func set_name_visible(on: bool) -> void :
	($NameTag as Label3D).visible = on and not names_suppressed




var _highlight: = Color(0.0, 0.0, 0.0, 0.0)



var _hand_hl: Array = []
var _hand_hl_mat: StandardMaterial3D = null
var _hand_acc_proxies: Array = []






func _ensure_hand_acc_proxies() -> void :
	if not _hand_acc_proxies.is_empty():
		return
	for hand in [hand_l, hand_r]:
		var mi: = hand as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var proxy: = MeshInstance3D.new()
		proxy.name = "AccProxy"
		proxy.mesh = mi.mesh
		proxy.material_override = Ink.acc_proxy_material()
		proxy.layers = Ink.INK_ACC_MASK
		proxy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.add_child(proxy)
		_hand_acc_proxies.append(proxy)

func set_highlight(color: Color) -> void :





	_highlight = color
	if _model != null:
		_model.set_highlight(color)
	var on: = color.a > 0.01
	if GameConfig.contour_outline:


		for s in _hand_hl:
			if is_instance_valid(s):
				(s as MeshInstance3D).visible = false
		return
	if on:
		_ensure_hand_highlight()
		_hand_hl_mat.albedo_color = color
	for s in _hand_hl:
		if is_instance_valid(s):
			(s as MeshInstance3D).visible = on



const BURNOUT_FLASH_COLOR: = Color(1.0, 0.14, 0.12)
const BURNOUT_FLASH_HZ: = 1.5
const BURNOUT_FLASH_LO: = 0.1
const BURNOUT_FLASH_HI: = 0.38


const RECOVER_FLASH_COLOR: = Color(0.22, 0.62, 1.0)
const RECOVER_FLASH_TIME: = 0.4
const RECOVER_FLASH_PEAK: = 0.4
var _flash_recover: = 0.0
var _locked_prev: = false
const TOUCH_FLASH_TIME: = 0.32
const TOUCH_FLASH_PEAK: = 0.34
var _flash_touch: = 0.0
var _flash_touch_color: = Color.WHITE
var _flash_clock: = 0.0
var _flash_amt_prev: = 0.0



func set_contour_px_scale(k: float) -> void :
	if _model != null:
		_model.set_contour_px_scale(k)


func set_flash(color: Color, amount: float) -> void :
	if _model != null:
		_model.set_flash(color, amount)
	for hand in [hand_l, hand_r]:
		var hm: = (hand as MeshInstance3D).material_override as ShaderMaterial
		if hm != null:
			hm.set_shader_parameter("flash_color", color)
			hm.set_shader_parameter("flash", amount)



func flash_touch(color: Color) -> void :
	_flash_touch = TOUCH_FLASH_TIME
	_flash_touch_color = color



func _tick_flash(delta: float) -> void :


	if _locked_prev and not stamina_locked:
		_flash_recover = RECOVER_FLASH_TIME
	_locked_prev = stamina_locked
	var amt: = 0.0
	var col: = Color.WHITE
	if stamina_locked:

		_flash_clock += delta
		var w: = 0.5 + 0.5 * sin(_flash_clock * BURNOUT_FLASH_HZ * TAU)
		amt = lerpf(BURNOUT_FLASH_LO, BURNOUT_FLASH_HI, w)
		col = BURNOUT_FLASH_COLOR
	elif _flash_recover > 0.0:

		_flash_recover = maxf(_flash_recover - delta, 0.0)
		amt = RECOVER_FLASH_PEAK * sin(PI * (1.0 - _flash_recover / RECOVER_FLASH_TIME))
		col = RECOVER_FLASH_COLOR
	else:
		_flash_clock = 0.0
		if _flash_touch > 0.0:
			_flash_touch = maxf(_flash_touch - delta, 0.0)
			amt = TOUCH_FLASH_PEAK * (_flash_touch / TOUCH_FLASH_TIME)
			col = _flash_touch_color

	if amt > 0.0 or _flash_amt_prev > 0.0:
		set_flash(col, amt)
	_flash_amt_prev = amt





const HAND_RING_MATCH: = 0.4


static var _next_stencil: = 0
var stencil_id: = 1

func _ensure_hand_highlight() -> void :
	if _hand_hl_mat != null:
		return
	_hand_hl_mat = StandardMaterial3D.new()
	_hand_hl_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hand_hl_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	_hand_hl_mat.grow = true



	_hand_hl_mat.grow_amount = ModelRig.OUTLINE_WIDTH * 2.25
	for hand in [hand_l, hand_r]:
		var mi: = hand as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var shell: = MeshInstance3D.new()
		shell.mesh = mi.mesh
		shell.material_override = _hand_hl_mat
		shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shell.visible = false
		mi.add_child(shell)
		_hand_hl.append(shell)

func set_labels_visible(on: bool) -> void :
	($NameTag as Label3D).visible = on and not names_suppressed
	if not on and combo_badge != null:


		combo_badge.visible = false

func show_float_text(text: String, color: Color, priority: = false, 
		hold: = 1.1, broadcast: = true, shake: = false) -> void :


	if _float_priority and not priority:
		return
	if far_lod:


		if broadcast:
			float_shown.emit(text, color, priority)
		return
	if broadcast:
		float_shown.emit(text, color, priority)
	if hide_overlays:
		return

	_float_priority = priority
	if _float_tween != null and _float_tween.is_valid():
		_float_tween.kill()
	float_label.text = text
	float_label.modulate = color
	float_label.visible = true


	if _float_base_pos == Vector3.INF:
		_float_base_pos = float_label.position
	float_label.position = _float_base_pos
	if shake:
		_float_shake_t = 0.4
	elif _float_shake_t > 0.0:

		_float_shake_t = 0.0
	_float_tween = create_tween()
	_float_tween.set_ignore_time_scale(true)
	_float_tween.tween_interval(hold)
	_float_tween.tween_property(float_label, "modulate:a", 0.0, 0.4)
	_float_tween.tween_callback( func():
		float_label.visible = false
		float_label.modulate.a = 1.0
		_float_priority = false)




func hide_combo() -> void :
	if combo_badge != null:
		combo_badge.visible = false

const COMBO_MAX: = 9999

func show_combo(count: int, fail: = false) -> void :
	combo_shown.emit(count, fail)
	show_combo_local(count, fail)

func show_combo_local(count: int, fail: = false) -> void :


	if combo_badge == null or hide_overlays or far_lod:
		return


	if fail or count < 2:
		return
	_style_combo_badge()




	count = mini(count, COMBO_MAX)
	combo_count.text = "×%d" % count
	combo_count.font_size = 68 if count < 100 else (52 if count < 1000 else 42)


	var disc: = combo_color(count)
	var mat: = combo_disc.get_active_material(0) as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("fill", disc)




	_set_combo_fade(1.0)
	combo_badge.visible = true
	combo_badge.scale = Vector3.ONE * 0.4
	if _combo_tween != null and _combo_tween.is_valid():
		_combo_tween.kill()
	_combo_tween = create_tween()
	_combo_tween.set_ignore_time_scale(true)


	_combo_tween.tween_property(combo_badge, "scale", Vector3.ONE * 1.18, 0.11)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(combo_badge, "scale", Vector3.ONE, 0.09)
	_combo_tween.tween_interval(0.75)


	_combo_tween.tween_method(_set_combo_fade, 1.0, 0.0, 0.3)
	_combo_tween.tween_callback( func(): combo_badge.visible = false)




var _combo_styled: = false
func _style_combo_badge() -> void :
	if _combo_styled:
		return
	_combo_styled = true
	combo_count.font = UiStyle.font(UiStyle.FONT_BLACK)
	combo_count.font_size = 68
	combo_count.outline_size = 24







	var qm: = combo_disc.mesh
	if qm != null:
		qm = qm.duplicate()
		combo_disc.mesh = qm
		(qm as QuadMesh).size = Vector2(0.96, 0.96)
	var base_mat: = combo_disc.get_active_material(0)
	if base_mat != null:
		combo_disc.material_override = base_mat.duplicate()

func _set_combo_fade(a: float) -> void :
	var mat: = combo_disc.get_active_material(0) as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("alpha", a)
	combo_count.modulate.a = a
	combo_count.outline_modulate.a = a

func celebrate_hop() -> void :

	if is_on_floor() and _knock_time <= 0.0 and _dive_time <= 0.0:
		velocity.y = 6.5









func _can_gesture() -> bool:
	return grounded() and not knocked() and not diving() and not getting_up()\
	and not serving and not serve_charge_ui and contact_state == ContactState.IDLE\
	and not _set_windup and _getup_time <= 0.0



var gesture_count: = 0
var last_gesture_variant: = 0
var _last_shuffle_pick: = -1
var _gesture_still: = false


func _shuffle_clips(base: String) -> Array:
	var out: = []
	if _model == null:
		return out
	for i in range(1, GESTURE_SHUFFLE_MAX + 1):
		if _model.has_clip("%s%d" % [base, i]):
			out.append("%s%d" % [base, i])
	return out



func _roll_call_variant(idx: int) -> int:
	var v: = randi() % CALL_VARIANTS
	var spec: Dictionary = CALLOUT_GESTURES.get(idx, {})
	if spec.has("shuffle"):
		var n: = _shuffle_clips(String(spec.shuffle)).size()
		if n > 1 and v % n == _last_shuffle_pick:
			v = (v + 1) % CALL_VARIANTS
	return v

func _trigger_gesture(idx: int, variant: = -1) -> void :
	if muted_here or _model == null or not CALLOUT_GESTURES.has(idx) or not _can_gesture():
		return
	var spec: Dictionary = CALLOUT_GESTURES[idx]
	if bool(spec.get("still", false))\
	and Vector2(velocity.x, velocity.z).length() > GESTURE_STILL_SPEED:
		return
	if variant < 0:
		variant = _roll_call_variant(idx)
	last_gesture_variant = variant
	var clip: = ""
	if spec.has("shuffle"):
		var clips: = _shuffle_clips(String(spec.shuffle))
		if clips.is_empty():
			return
		_last_shuffle_pick = variant % clips.size()
		clip = clips[_last_shuffle_pick]
	else:
		clip = String(spec.clip)
		if bool(spec.get("handed", false)):
			var lefty: = character != null and character.left_handed
			clip += "_l" if lefty else "_r"
	gesture_count += 1
	_gesture_still = bool(spec.get("still", false))
	_model.play_callout(clip)




func gesture_call(idx: int, variant: = -1) -> void :
	_trigger_gesture(idx, variant)




func play_gesture_clip(clip: String) -> bool:
	if clip == "igot":
		clip += "_l" if character != null and character.left_handed else "_r"
	if _model == null or not _model.has_clip(clip) or not _can_gesture():
		return false
	_gesture_still = false
	_model.play_callout(clip)
	return true


func quick_chat(idx: int, emit: = true, slack_ms: = 0, variant: = -1) -> CallResult:
	if not is_quick_chat(idx):
		return CallResult.REFUSED
	var now: = Time.get_ticks_msec() + slack_ms


	if variant < 0 or variant >= CALL_VARIANTS:
		variant = _roll_call_variant(idx)



	_trigger_gesture(idx, variant)
	if now < _call_cool_until:
		return CallResult.COOLING
	if now < _call_talk_until:
		return CallResult.TALKING
	var window: = CALLOUT_BURST_WINDOW_MS - slack_ms
	_call_stamps = _call_stamps.filter( func(t: int): return now - t < window)
	_call_stamps.append(now)
	if _call_stamps.size() >= CALLOUT_BURST:

		_call_cool_until = now + CALLOUT_COOLDOWN_MS
		_call_stamps.clear()
	show_callout(idx, emit, true, variant)
	return CallResult.OK







func _say_call(idx: int, variant: int) -> void :
	var bank: = String((CALLOUTS[idx] as Dictionary).get("v", ""))
	if bank == "":
		return
	var now: = Time.get_ticks_msec()
	if now < _call_talk_until:
		return


	_call_talk_until = now + int(Sfx.line_length(bank) * 1000.0)
	var s: Sfx = Sfx.current(get_tree()) if is_inside_tree() else null
	if s == null:
		return


	var wobble: = lerpf(0.96, 1.04, float(variant % 5) / 4.0)
	var pitch: = (character.voice_pitch() if character != null else 1.0) * wobble
	s.play(bank, global_position + Vector3(0.0, 1.4, 0.0), CALL_VOICE_DB, pitch, 
		false, false, variant)




func show_callout(idx: int, emit: = true, voice: = true, variant: = -1) -> void :


	if idx < 0 or idx >= CALLOUTS.size():
		return
	if variant < 0 or variant >= CALL_VARIANTS:
		variant = randi() % CALL_VARIANTS
	last_call_variant = variant
	if muted_here and is_quick_chat(idx):


		if emit:
			callout_made.emit(idx)
		return
	if voice:
		_say_call(idx, variant)




	_trigger_gesture(idx, variant)
	if hide_overlays:


		if emit:
			callout_made.emit(idx)
		return
	var call: Dictionary = CALLOUTS[idx]
	callout_label.text = call.t
	callout_label.modulate = call.c
	callout_label.visible = true
	if _callout_tween != null and _callout_tween.is_valid():
		_callout_tween.kill()
	callout_label.scale = Vector3.ONE
	_callout_tween = create_tween()
	_callout_tween.set_ignore_time_scale(true)

	callout_label.scale = Vector3.ONE * 0.6
	_callout_tween.tween_property(callout_label, "scale", Vector3.ONE, 0.14)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_callout_tween.tween_interval(1.5)
	_callout_tween.tween_property(callout_label, "modulate:a", 0.0, 0.35)
	_callout_tween.tween_callback( func():
		callout_label.visible = false
		callout_label.modulate.a = 1.0)
	if emit:
		callout_made.emit(idx)

func hide_callout() -> void :


	if _callout_tween != null and _callout_tween.is_valid():
		_callout_tween.kill()
	callout_label.visible = false
	callout_label.modulate.a = 1.0



func celebrating() -> bool:
	return _cel_state > 0

func celebrate_state() -> int:
	return _cel_state

func high_fiving() -> bool:
	return _cel_state == 2

func celebrate_hands_up() -> void :


	if _cel_state == 0:
		_cel_t = 0.0
	if _cel_state != 2:
		_cel_state = 1

func celebrate_stop() -> void :
	_cel_state = 0
	_cel_hf_t = 0.0
	_cel_slapped = false

func celebrate_high_five(meet_world: Vector3, reach_hand: = 0) -> void :



	_cel_state = 2
	_cel_hf_t = 0.0
	_cel_slapped = false
	_cel_meet = meet_world
	if reach_hand != 0:
		_cel_hand = reach_hand
	elif visual != null:


		_cel_hand = 1 if visual.to_local(meet_world).x < 0.0 else -1

const TOON_SHADER: = preload("res://game/fx/toon.gdshader")

var character: CharacterConfig = null
var replay_kit: Array = []

func set_character(cfg: CharacterConfig, kit: Array) -> void :


	character = cfg
	replay_kit = kit.duplicate()
	_refresh_title()
	if _model != null:
		_model.apply_config(cfg, kit)


	GameConfig.stencil_mark_body.call_deferred(self, stencil_id)
	if _model != null:
		_model.mark_head_group.call_deferred()
	GameConfig.world_light.call_deferred(self)


	var skin: = cfg.skin_tone()






	if Ink.active():
		_ensure_hand_acc_proxies()




	var hand_hulls: = GameConfig.INK_OUTLINES and (GameConfig.style_is(GameConfig.ArtStyle.CEL_CLASSIC)
		or (GameConfig.style_is(GameConfig.ArtStyle.CEL_INK) and not Ink.supported()))
	for hand in [hand_l, hand_r]:
		for shell in hand.get_children():


			if shell is MeshInstance3D and not String(shell.name).begins_with("AccProxy"):
				(shell as MeshInstance3D).visible = hand_hulls





				var hull: = shell as MeshInstance3D
				if GameConfig.contour_outline:
					var base: = hull.mesh.surface_get_material(0) as BaseMaterial3D\
					if hull.mesh != null else null
					if base != null:
						var own: = base.duplicate() as BaseMaterial3D
						own.next_pass = _model.own_contour(stencil_id) if _model != null\
						else ModelRig.contour_material(stencil_id)
						hull.material_override = own
				else:
					hull.material_override = null



				if GameConfig.contour_outline:
					var ring: = 0.026 * GameConfig.contour_inner_scale * HAND_RING_MATCH\
					/ maxf(_hand_scale_base, 0.01)
					if not GameConfig.contour_inner_lines:
						ring = 0.0
					(shell as Node3D).scale = Vector3.ONE * ((0.14 + ring) / 0.166)
				else:
					(shell as Node3D).scale = Vector3.ONE


	var sleeve: = _hand_sleeve(cfg, kit)
	var hand_mat: ShaderMaterial = null
	for hand in [hand_l, hand_r]:
		hand_mat = ShaderMaterial.new()
		hand_mat.shader = ModelRig.stencil_shader(ModelRig.body_shader(), stencil_id)
		hand_mat.set_shader_parameter("albedo", skin)
		hand_mat.set_shader_parameter("sleeve_cut", sleeve[0])
		hand_mat.set_shader_parameter("sleeve_color", sleeve[1])
		hand_mat.set_shader_parameter("sleeve_band", HAND_SLEEVE_BAND if sleeve[0] < 900.0 else 0.0)
		(hand as MeshInstance3D).material_override = hand_mat






	if _reflect_root != null:
		_dress_reflection()




func force_portrait_pose() -> void :
	force_update_transform()
	if _model != null:
		_model.force_static_pose()










const HAND_SLEEVE_CUT: = -1.0
const HAND_SLEEVE_BAND: = 0.0



func _hand_sleeve(_cfg: CharacterConfig, _kit) -> Array:
	return [1000.0, Color.WHITE]

func _dress_reflection() -> void :
	if character == null:
		return
	if _reflect_model != null:
		_reflect_model.apply_config(character, replay_kit)
	var skin: = character.skin_tone()
	var sleeve: = _hand_sleeve(character, replay_kit)
	for h in _reflect_hands:
		var hm: = ShaderMaterial.new()
		hm.shader = TOON_SHADER
		hm.set_shader_parameter("albedo", skin)
		hm.set_shader_parameter("sleeve_cut", sleeve[0])
		hm.set_shader_parameter("sleeve_color", sleeve[1])
		hm.set_shader_parameter("sleeve_band", HAND_SLEEVE_BAND if sleeve[0] < 900.0 else 0.0)
		(h as MeshInstance3D).material_override = hm

func _ensure_reflection() -> void :
	if _reflect_root != null or not enable_reflection:
		return
	_reflect_root = Node3D.new()
	_reflect_root.top_level = true
	add_child(_reflect_root)
	if _model != null:
		var rig: = ModelRig.new()
		_reflect_root.add_child(rig)
		if rig.setup(true):
			_reflect_model = rig
		else:
			rig.queue_free()
	for i in 2:
		var h: = MeshInstance3D.new()
		h.mesh = hand_l.mesh
		_reflect_root.add_child(h)
		_reflect_hands.append(h)
	if _model == null:
		_reflect_body = MeshInstance3D.new()
		_reflect_body.mesh = body.mesh
		_reflect_root.add_child(_reflect_body)


	_tag_reflection_layer(_reflect_root)

func _tag_reflection_layer(node: Node) -> void :
	if node is VisualInstance3D:
		(node as VisualInstance3D).layers = FloorReflector.REFLECT_MASK
	for child in node.get_children():
		_tag_reflection_layer(child)






const _ONE_SHOT_CLIPS: = ["spike", "set", "set_back", "receive", "receive_l", "receive_r", 
	"receive_back"]
const _MIN_ACTION_HOLD: = 0.34
const SPIKE_RECOVER: = 0.75
var _puppet_action: = ""
var _puppet_action_t: = 0.0

func _model_action() -> String:


	if _cel_state == 2:
		return "set"
	var raw: = _raw_model_action()




	if raw in ["dive", "dive_r", "dive_l", "dive_burnout", "getup_back", 
			"getup_front", "block", "block_hit", "kick_r", "kick_l", "set_low"]:
		_puppet_action = ""
		_puppet_action_t = 0.0
		return raw









	if _puppet_action == "spike"\
	and (knocked() or (grounded() and _receive_pose <= 0.0)):
		_puppet_action = ""
		_puppet_action_t = 0.0
	if raw in _ONE_SHOT_CLIPS:




		if raw in ["set", "set_back"] and _puppet_action in ["set", "set_back"]\
		and _puppet_action_t > 0.0:
			return _puppet_action
		if raw != _puppet_action:
			_latch_touch_action(raw)
		return raw


	if _puppet_action_t > 0.0:
		return _puppet_action
	_puppet_action = ""
	return raw

func _latch_touch_action(action: String) -> void :
	if action == _puppet_action and _puppet_action_t > 0.0:
		return
	_puppet_action = action
	var authored_length: = _model.action_length(action) if _model != null else 0.0
	if action == "spike":





		_puppet_action_t = FEEL.spike_air_hold + _hitstop_hold
		return
	_puppet_action_t = maxf(_MIN_ACTION_HOLD, authored_length)

func present_authoritative_touch(kind: TouchKind, hang: = 0.0, 
		out_vel: = Vector3.ZERO, set_dump: = false) -> void :




	if set_dump and kind == TouchKind.DUMP:
		kind = TouchKind.SET
	match kind:
		TouchKind.BUMP:
			_latch_touch_action("receive")
		TouchKind.SET:




			if _puppet_action in ["set", "set_back"] and _puppet_action_t > 0.0:
				return
			_latch_touch_action("set_back"
				if back_set_dir(visual.rotation.y, out_vel) else "set")
		TouchKind.SPIKE, TouchKind.DUMP:




			if hang > 0.0:
				_hitstop_hold = maxf(_hitstop_hold, hang)
			_latch_touch_action("spike")










var _local_touch_msec: = -100000

func confirm_own_touch(kind: TouchKind) -> void :
	if ball == null:
		return
	if _intent_used_strike == ball.strike_seq:
		_intent_used_strike = -1


	if kind == TouchKind.BUMP and contact_state == ContactState.WINDUP and not _set_windup\
	and Time.get_ticks_msec() - _local_touch_msec > 600:

		_clear_contact_intent()
		hold_time = 0.0
		_hold_real = 0.0
		_recover_left = FEEL.recover_time
		if grounded() and _contact_button_held:
			_receive_hold_spent = true
		contact_state = ContactState.RECOVER

func present_serve_toss(_restart: = false) -> void :




	_serve_toss_lift = 1.0

func _raw_model_action() -> String:








	if _downed_hold:


		return "dive_burnout"
	if getting_up():



		if _set_low:
			return "getup_back"
		return "getup_back" if _was_knocked_getup else "getup_front"



	if _set_low and (knocked() or _receive_pose > 0.0):
		return "set_low"
	if diving():


		return "dive_r" if _dive_side == 1\
		else ("dive_l" if _dive_side == 2 else "dive")
	if not grounded() and contact_state == ContactState.BLOCK:
		return "block"




	if _kick_foot != 0 and _receive_pose > 0.0 and last_touch != TouchKind.BLOCK:
		return "kick_r" if _kick_foot == 1 else "kick_l"



	if not grounded() and last_touch == TouchKind.BLOCK and _receive_pose > 0.0:
		return "block_hit"





	if not grounded() and contact_state == ContactState.WINDUP\
	and _windup_pose_kind() == TouchKind.SPIKE:
		return "jump_rise"






















	if set_dump_touch() and _receive_pose > 0.0 and _knock_time <= 0.0:
		return "set_back" if _receive_side == 3 else "set"
	if (last_touch == TouchKind.SPIKE or last_touch == TouchKind.DUMP)\
	and _receive_pose > 0.0 and _knock_time <= 0.0:
		return "spike"









	if _receive_pose > 0.0 and last_touch == TouchKind.SET:

		return "set_back" if _receive_side == 3 else "set"



	if grounded() and _receive_pose > 0.0 and last_touch == TouchKind.BUMP\
	and not _dive_receive:

		if _receive_side == 1:
			return "receive_r"
		if _receive_side == 2:
			return "receive_l"
		if _receive_side == 3:
			return "receive_back"
		return "receive"
	if grounded() and _jump_charge > 0.02:






		var planar: = Vector2(velocity.x, velocity.z).length()
		if planar > FEEL.approach_min_speed and _jump_charge < FEEL.approach_time:
			return "approach"
		return "charge"



	if sprinting and grounded():
		if _sprint_start_t > 0.0:
			return "sprint_start"


		var spd: = Vector2(velocity.x, velocity.z).length()
		if _plant_time > 0.0 and spd > FEEL.plant_speed:
			return "sprint_stop"
		if _move_intent.length() > 0.2:


			if spd > 1.5:
				var turn: = Vector2(velocity.x, velocity.z).normalized()\
				.cross(_move_intent.normalized())
				if absf(turn) > 0.4:
					return "sprint_right" if turn < 0.0 else "sprint_left"
			return "sprint"
		if spd > FEEL.stop_speed:
			return "sprint_stop"
		return "sprint"
	if grounded() and _strafe_held and _move_intent.length() > 0.2:
		var lane: = strafe_lane()
		if lane < 0:
			return "strafe_left"
		if lane > 0:
			return "strafe_right"
		if _moving_backward():
			return "run_back"


		return "strafe_fwd"




	var travelling: = Vector2(velocity.x, velocity.z).length()





	if grounded() and _move_intent.length() < 0.2 and travelling > FEEL.stop_speed:
		return "stop"



	if grounded() and _land_time > 0.0 and travelling < FEEL.land_still:
		return "land"





	if grounded() and _strafe_held and travelling < FEEL.idle_still:
		return "idle_alt"



	if grounded() and _settle_time > 0.0 and travelling < FEEL.idle_still:
		return "idle_alt"
	return ""

func gaze_allowed() -> bool:



	if _knock_time > 0.0 or diving() or getting_up():
		return false



	if sprinting:
		return false

	if serving:
		return false
	if contact_state == ContactState.BLOCK:
		return false


	if _block_hit_now():
		return false
	if contact_state == ContactState.WINDUP and _windup_pose_kind() == TouchKind.SPIKE:
		return false
	if contact_state == ContactState.RECOVER and last_touch == TouchKind.SPIKE:
		return false


	if _model != null and _model.callout_active():
		return false
	return true

func gaze_weight() -> float:


	if ball == null or not is_instance_valid(ball) or not gaze_allowed():
		return 0.0



	if not ball.visible or cinematic_hidden:
		return 0.0


	if ball.global_position.y < 0.1:
		return 0.0
	var d: = ball.global_position.distance_to(chest_position())
	return clampf(1.0 - (d - FEEL.gaze_near) / (FEEL.gaze_far - FEEL.gaze_near), 0.0, 1.0)






func _sprint_head_lean(delta: float) -> bool:
	if not sprinting or _model == null:
		return false
	var vel2: = Vector2(velocity.x, velocity.z)
	if vel2.length() < 1.5 or _move_intent.length() < 0.2:
		return false
	var turn: = vel2.normalized().cross(_move_intent.normalized())
	if absf(turn) < 0.3:
		return false
	var head: = chest_position() + Vector3(0.0, 0.45, 0.0)
	var fwd: = Vector3(velocity.x, 0.0, velocity.z).normalized()
	var right: = Vector3.UP.cross(fwd)
	var look: = head + fwd * 2.0 - right * signf(turn) * 1.4
	_model.gaze_at(look, FEEL.sprint_head_lean * clampf(absf(turn), 0.0, 1.0), delta)
	return true


func _block_hit_now() -> bool:
	return not grounded() and last_touch == TouchKind.BLOCK and _receive_pose > 0.0\
	and contact_state != ContactState.BLOCK

func _gaze_tick(delta: float) -> void :



	if contact_state == ContactState.BLOCK or _block_hit_now():
		_model.gaze_release()
		if _reflect_model != null:
			_reflect_model.gaze_release()
		return
	var want: = gaze_weight()
	var at: = ball.global_position if ball != null and is_instance_valid(ball) else global_position
	_model.gaze_at(at, want, delta)
	if _reflect_model != null and not far_lod and not mirror_off\
	and GameConfig.reflections_live(self):




		_reflect_model.gaze_at(Vector3(at.x, - at.y, at.z), want, delta)

func _update_reflection() -> void :






	var idle: = far_lod or mirror_off or not GameConfig.reflections_live(self)
	if _reflect_root == null:
		if idle:
			return

		_ensure_reflection()
		if _reflect_root == null:
			return
		_dress_reflection()
	if _reflect_root.visible != not idle:
		_reflect_root.visible = not idle
	if idle:
		return


	_reflect_root.global_transform = Transform3D(REFLECT_FLIP, Vector3.ZERO)\
	* visual.global_transform
	if _reflect_model != null:
		_reflect_model.apply_anim_state(_model.anim_state())
	if _reflect_hands.size() == 2:
		_reflect_hands[0].transform = hand_l.transform
		_reflect_hands[1].transform = hand_r.transform
	if _reflect_body != null:
		_reflect_body.transform = body.transform
		_reflect_body.material_override = body.material_override

func set_team_color(color: Color) -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = TOON_SHADER
	mat.set_shader_parameter("albedo", color)
	($Visual / Body as MeshInstance3D).material_override = mat









	var ring_mat: = indicator_ring.get_active_material(0) as ShaderMaterial
	if ring_mat == null:
		push_warning("indicator ring has no floor_ring material")
	else:


		_ind_mat = ring_mat
		ring_mat.set_shader_parameter("progress_color", FEEL.dive_ring_color)
		_paint_ring()
	set_tag_color(color)
	if _model != null:
		_model.set_slot_color("jersey", color)




var ring_tint: = Color(0, 0, 0, 0)

func set_ring_tint(c: Color) -> void :
	ring_tint = c



	if indicator_ring != null and indicator_ring.get_surface_override_material(0) == null:
		var base: = indicator_ring.get_active_material(0)
		if base != null:
			indicator_ring.set_surface_override_material(0, base.duplicate())
			_ind_mat = indicator_ring.get_surface_override_material(0) as ShaderMaterial
	_paint_ring()

func _ring_color() -> Color:
	return ring_tint if ring_tint.a > 0.0 else FEEL.indicator_color


func _paint_ring() -> void :
	if _ind_mat == null:
		return
	var tint: = _ring_color()
	_ind_mat.set_shader_parameter("tint", tint)


	_ind_mat.set_shader_parameter("edge", 
		Color(tint.r, tint.g, tint.b, 0.95).darkened(0.88))







func set_tag_color(_color: Color) -> void :




	($AirTrail as PlayerTrail).color = Color.WHITE

func display_name() -> String:
	return ($NameTag as Label3D).text





var dev_tag: int = DevBadge.Tier.NONE

func set_dev_tag(tier: int) -> void :
	if tier == dev_tag:
		return
	dev_tag = tier
	var tag: = get_node_or_null("DevTag") as DevTag
	if tag != null:
		tag.teardown()
	if tier != DevBadge.Tier.NONE:
		tag = DevTag.new()
		tag.name = "DevTag"
		add_child(tag)
		tag.setup($NameTag as Label3D, tier)

func set_display_name(display_name: String) -> void :

	($NameTag as Label3D).text = display_name









var rally_live: = false

func set_rally_live(on: bool) -> void :
	if on == rally_live:
		return
	rally_live = on
	var tag: = get_node_or_null("NameTag") as PlayerNameplate
	if tag != null:
		tag.rally_live = on






const HEAD_LIFT: = 0.09




func _refresh_title() -> void :
	var tag: = get_node_or_null("NameTag") as PlayerNameplate
	if tag != null:
		tag.set_title(character.title if character != null else {})
		tag.set_level(character.level if character != null else 0)
		tag.set_party(party_mark)



var party_mark: = 0

func set_party_mark(group: int) -> void :
	party_mark = group
	_refresh_title()






var _host_crown: Sprite3D = null
static var _crown_tex: ImageTexture = null

func set_host_crown(on: bool) -> void :
	if on == (_host_crown != null and _host_crown.visible):
		return
	if not on:
		if _host_crown != null:
			_host_crown.visible = false
		return
	if _host_crown == null:
		_host_crown = Sprite3D.new()
		_host_crown.name = "HostCrown"
		_host_crown.texture = _crown_texture()
		_host_crown.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_host_crown.no_depth_test = true
		_host_crown.shaded = false
		_host_crown.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		_host_crown.pixel_size = 0.0055
		_host_crown.render_priority = 25
		_host_crown.position = Vector3(0.0, 2.42 + HEAD_LIFT, 0.0)
		add_child(_host_crown)
	_host_crown.visible = true


static func _crown_texture() -> ImageTexture:
	if _crown_tex != null:
		return _crown_tex
	const W: = 64
	const H: = 48
	var img: = Image.create(W, H, false, Image.FORMAT_RGBA8)
	var gold: = Color(1.0, 0.82, 0.18)
	var edge: = Color(0.42, 0.28, 0.03)
	var gem: = Color(0.95, 0.3, 0.35)
	var spikes: = [0.16, 0.5, 0.84]
	var hw: = 0.2
	var band_top: = 0.6
	var band_bot: = 0.9
	var tip_v: = 0.06
	var valley_v: = 0.52
	for y in H:
		for x in W:
			var u: = (x + 0.5) / float(W)
			var v: = (y + 0.5) / float(H)
			if u < 0.05 or u > 0.95:
				continue


			var top: = valley_v
			for c in spikes:
				var d: float = absf(u - c)
				if d < hw:
					top = minf(top, valley_v - (valley_v - tip_v) * (1.0 - d / hw))
			var inside: = v >= top and v <= band_bot
			if not inside:
				continue

			var rim: = v <= top + 0.045 or v >= band_bot - 0.05 or u <= 0.075 or u >= 0.925
			var col: = edge if rim else gold
			for c in spikes:
				if Vector2(u - c, v - (tip_v + 0.1)).length() < 0.05:
					col = gem
			if absf(v - 0.75) < 0.05 and (absf(u - 0.33) < 0.035 or absf(u - 0.67) < 0.035):
				col = gem
			img.set_pixel(x, y, col)
	_crown_tex = ImageTexture.create_from_image(img)
	return _crown_tex



var _seat_badge: SeatBadge = null

func set_seat_badge(text: String, color: Color, on: bool) -> void :
	if _seat_badge == null and on:
		_seat_badge = SeatBadge.new(true)
		_seat_badge.position = Vector3(0.0, 2.15 + HEAD_LIFT, 0.0)
		add_child(_seat_badge)
	if _seat_badge != null:
		_seat_badge.set_badge(text.to_upper(), color)
		show_seat_badge(on)

func set_seat_badge_layers(mask: int) -> void :
	if _seat_badge != null and _seat_badge.layers != mask:
		_seat_badge.layers = mask



func show_seat_badge(on: bool) -> void :
	if _seat_badge != null:
		_seat_badge.visible = on and not _dc_shown and not names_suppressed


		callout_label.offset.y = 90.0 if _seat_badge.visible else 0.0





var _dc_badge: SeatBadge = null
var _dc_shown: = false




var _mvp_badge: SeatBadge = null

func set_mvp_badge(on: bool) -> void :
	if _mvp_badge == null:
		if not on:
			return
		_mvp_badge = SeatBadge.new(false, true)
		_mvp_badge.pixel_size = MVP_CHIP_PX
		_mvp_badge.position = Vector3(0.0, 2.05 + HEAD_LIFT, 0.0)
		_mvp_badge.offset = Vector2(0.0, MVP_BADGE_RAISE)
		add_child(_mvp_badge)
		_mvp_badge.set_badge("MVP", MVP_GOLD)
	_mvp_badge.visible = on
	callout_label.offset.y = 90.0 if on else 0.0
	if on:
		_mvp_badge.offset = Vector2(0.0, MVP_BADGE_RAISE * _showcase_k)
		_mvp_badge.scale = Vector3.ONE * 0.3
		var t: = _mvp_badge.create_tween()
		t.tween_property(_mvp_badge, "scale", Vector3.ONE, 0.45)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)





const SHOWCASE_TAG_SCALE: = 1.6
var _showcase_k: = 1.0

func set_showcase_names(on: bool) -> void :
	_showcase_k = SHOWCASE_TAG_SCALE if on else 1.0
	var tag: = get_node_or_null("NameTag") as PlayerNameplate
	if tag != null:
		tag.set_size_k(_showcase_k)
	if _mvp_badge != null:
		_mvp_badge.offset = Vector2(0.0, MVP_BADGE_RAISE * _showcase_k)



const MVP_BADGE_RAISE: = 60.0
const MVP_CHIP_PX: = 0.004
const MVP_GOLD: = Color("ffcf3f")

func set_disconnected(on: bool, text: = "", color: = Color.WHITE) -> void :
	_dc_shown = on
	if on:
		show_seat_badge(false)
	if not on:
		if _dc_badge != null:
			_dc_badge.visible = false
		return
	if _dc_badge == null:
		_dc_badge = SeatBadge.new()
		_dc_badge.position = Vector3(0.0, 2.62 + HEAD_LIFT, 0.0)
		add_child(_dc_badge)
	_dc_badge.set_badge(text, color)
	_dc_badge.visible = true

func chest_position() -> Vector3:
	return global_position + Vector3(0.0, FEEL.chest_height, 0.0)

func serve_cradle_point(steady: = false) -> Vector3:



	var p: = visual.to_global(Vector3(0.0, 
		(POSE_SERVE_L.y + POSE_SERVE_R.y) * 0.5, POSE_SERVE_L.z))




	if serve_charge_ui and not steady:
		var amt: = hold_power()
		if amt > 0.02:
			p.y += cos(_charge_buzz * 1.7) * FEEL.charge_shake * (0.4 + amt) * 2.2
	return p


func stride_phase() -> float:
	return _model.stride_phase() if _model != null else -1.0








var _first_person: = false
var hide_overlays: = false



var muted_here: = false

func set_first_person(on: bool) -> void :
	if on == _first_person:
		return
	_first_person = on
	hide_overlays = on
	if _model != null:
		_model.set_head_visible( not on)




func _spike_turn_bleed() -> void :
	var yaw: = visual.rotation.y
	var frame: = Engine.get_physics_frames()
	if _charge_yaw_frame == frame - 1:
		var before: = spike_turn_keep(_charge_turn)


		var cap: = FEEL.turn_speed * 1.5 / float(Engine.physics_ticks_per_second)
		_charge_turn += minf(absf(angle_difference(_charge_yaw, yaw)), cap)
		var after: = spike_turn_keep(_charge_turn)
		if before > 0.0001:
			hold_time *= after / before
	else:
		_charge_turn = 0.0
	_charge_yaw = yaw
	_charge_yaw_frame = frame

func hold_power() -> float:
	if not is_bot:
		return (float(power_level) - 1.0) / float(POWER_LEVELS - 1)
	return clampf(hold_time / FEEL.max_hold, 0.0, 1.0)

func _moving_backward() -> bool:

	if _move_intent.length() < 0.2:
		return false
	var facing: = Vector2(sin(visual.rotation.y), cos(visual.rotation.y))
	return _move_intent.normalized().dot(facing) < -0.4

func gait_pace_speed() -> float:



	if sprinting:
		return FEEL.move_speed * FEEL.sprint_speed
	if not _strafe_held:
		return FEEL.move_speed
	return FEEL.move_speed * (FEEL.strafe_back_speed if _moving_backward()
		else FEEL.strafe_speed)

func strafe_lane() -> int:

	if not _strafe_held or _move_intent.length() < 0.2:
		return 0
	var facing: = Vector2(sin(visual.rotation.y), cos(visual.rotation.y))
	var right: = Vector2(facing.y, - facing.x)
	var side: = _move_intent.normalized().dot(right)
	return 0 if absf(side) < 0.45 else (1 if side > 0.0 else -1)

func diving() -> bool:
	return _dive_time > 0.0





const DIVE_HIT_SHARE: = 0.5
func dive_strikes() -> bool:
	return _dive_time > 0.0 and _dive_time > _dive_span * (1.0 - DIVE_HIT_SHARE)

func kicked() -> bool:



	return _kick_was_spike

func _holding_receive_stance() -> bool:



	return is_on_floor() and _contact_button_held and not _armed_set_button\
	and contact_state == ContactState.WINDUP

func planting() -> bool:

	return _plant_time > 0.0

func plant_strength() -> float:
	return clampf(_plant_time / FEEL.plant_time, 0.0, 1.0)

func getting_up() -> bool:

	return _getup_time > 0.0

func can_dive() -> bool:




	return is_on_floor() and _dive_time <= 0.0\
	and _knock_time <= 0.0

func _voice(bank: String) -> void :


	if not sim_authority or character == null:
		return
	var pitch: = character.voice_pitch() * randf_range(0.96, 1.04)





	var pack: = clampi(character.voice_pack, 1, CharacterConfig.VOICE_PACK_COUNT)
	if pack >= 2:
		bank = "v_%d_%s" % [pack, bank.substr(bank.find("_") + 1)]
	voiced.emit(bank, pitch)

func clear_action_state() -> void :




	_jump_charge = 0.0
	_jump_full_time = 0.0
	_reach_t = -1.0
	_jump_canceled = false
	_launch_pulse = 0.0
	_launch_vel = 0.0
	_squash_y = 1.0
	_kick_foot = 0
	_kick_was_spike = false
	_hitstop_hold = 0.0
	hold_time = 0.0
	contact_state = ContactState.IDLE
	_dive_time = 0.0
	_dive_touched = true
	_knock_time = 0.0
	_recover_left = 0.0
	_land_pulse = 0.0
	_receive_window = 0.0
	_armed_kind = TouchKind.NONE
	_set_windup = false
	_armed_set_button = false
	_armed_from_ground = false
	_armed_wait_for_release = false
	_armed_aim = Vector3.ZERO
	_armed_influence = Vector2.ZERO
	_armed_dump = false
	_dump_rise = -1.0
	_dump_push_left = 0.0
	_queued_fill = 0.0
	_intent_used_strike = -1
	_intent_queued_at_usec = 0
	_early_contact_from_ground = false
	_ball_seen_valid = false
	_ball_sweep_valid = false
	serve_charge_ui = false





	_air_spent = false
	_receive_hold_spent = false
	_block_hit_cooldown = 0.0
	_block_time = 0.0
	_block_shifted = false
	_shift_progress = 1.0
	_restless = 0.0
	_restless_dir = Vector2.ZERO




















func _tick_serve_hold(input: PlayerInput) -> void :
	if not serve_charge_ui:
		_serve_ui_was = false
		_serve_hold_stale = false
		return
	if not _serve_ui_was:
		_serve_ui_was = true
		_drop_serve_charge()
		_serve_hold_stale = input.contact_pressed
	elif input.strafe_held and not _strafe_held:
		_drop_serve_charge()
		_serve_hold_stale = input.contact_pressed or input.contact_released



	elif not input.contact_pressed and not input.contact_released:
		_serve_hold_stale = false

func _drop_serve_charge() -> void :
	if contact_state == ContactState.WINDUP:
		_clear_contact_intent()
		_set_windup = false
		_free_swing = false
		contact_state = ContactState.IDLE
	hold_time = 0.0
	_hold_real = 0.0


func serve_release_counts(input: PlayerInput) -> bool:
	return input.contact_released and not _serve_hold_stale









func jump_charging_on_floor() -> bool:
	return not is_bot and is_on_floor() and _jump_charge > 0.0 and not serve_charge_ui

func cancel_contact() -> void :
	_set_windup = false
	_clear_contact_intent()
	_reach_left = 0.0
	hold_time = 0.0
	_hold_real = 0.0
	contact_state = ContactState.IDLE
	_recover_left = 0.0
	_touch_lock = 0.0
	_dive_touched = true
	_ball_seen_valid = false
	_ball_sweep_valid = false
	clear_settle()

func dive_input_actionable() -> bool:



	if _knock_time > 0.0 or _dive_time > 0.0:
		return false



	return grounded()

func block_input_actionable() -> bool:



	if _knock_time > 0.0 or _dive_time > 0.0:
		return false


	return not grounded()

func knocked() -> bool:
	return _knock_time > 0.0









func lying_on_back() -> bool:
	return wrapf(visual.rotation.x, - PI, PI) < 0.0






func knock_off_ball(vin: Vector3) -> void :
	var push: = Vector3(vin.x, 0.0, vin.z).normalized()
	var facing: = Vector3(sin(visual.rotation.y), 0.0, cos(visual.rotation.y))
	knock(push * 3.0 + Vector3.UP * 2.0, 0.4, push.dot(facing) > 0.0)




func knock(push: Vector3, duration: = -1.0, forward: = false) -> void :


	if duration < 0.0:
		duration = FEEL.knock_time
	if _knock_time > 0.0:
		return
	knock_started.emit(global_position, clampf(push.length() / 6.0, 0.35, 1.0))
	_knock_time = duration

	_knock_roll = -0.01 if forward else 0.0
	velocity = push
	contact_state = ContactState.RECOVER
	_recover_left = FEEL.knock_time
	_drop_jump_charge()
	_dive_time = 0.0


	if _set_windup:
		_set_windup = false
		_clear_contact_intent()
		hold_time = 0.0
		_hold_real = 0.0






func _drop_jump_charge() -> void :
	_jump_charge = 0.0
	_jump_full_time = 0.0
	_jump_canceled = true

func _slide() -> void :

	if sim_step_scale == 1.0:
		move_and_slide()
		return
	velocity *= sim_step_scale
	move_and_slide()
	velocity /= sim_step_scale






const IN_PLAY_DY: = 2.0

func in_play_height(y: float) -> bool:
	return absf(global_position.y - y) <= IN_PLAY_DY

func _separate_from_players(delta: float) -> void :









	if not GameConfig.team_collision_for(self):
		return
	if net_puppet or roster.is_empty() or not is_on_floor():
		return

	if _knock_time > 0.0 or _dive_time > 0.0 or _getup_time > 0.0:
		return
	var here: = global_position
	var radius: = FEEL.push_radius
	var shove: = Vector3.ZERO
	for other in roster:
		var o: Player = other
		if o == null or o == self or not is_instance_valid(o):
			continue
		if not o.grounded():
			continue
		if not o.in_play_height(here.y):
			continue



		if not Rules.bodies_collide(self, o):
			continue
		var d: = o.global_position - here
		d.y = 0.0
		var dist: = d.length()
		if dist >= radius or dist < 0.0001:
			continue



		var depth: = (radius - dist) / radius
		shove -= (d / dist) * (0.5 + 0.5 * depth)
	if shove == Vector3.ZERO:
		return


	move_and_collide(shove.limit_length(1.0) * FEEL.push_speed * delta)

func _dive_intercept() -> Vector3:







	if ball == null or ball.frozen or not contact_enabled:
		return aim_point
	return ball.predict_point(0.35)






const SIDE_DIVE_DEG: = 70.0












const DIVE_NET_MARGIN: = 0.9
const DIVE_NET_STOP: = 0.7
func dive_plan(target: Vector3) -> Dictionary:
	var own_side: = float(team_side)
	var clamped: = false
	if own_side != 0.0 and target.z * own_side < 0.0:
		target.z = own_side * DIVE_NET_MARGIN
		clamped = true
	var dir: = target - global_position
	dir.y = 0.0
	if dir.length() < 0.5:
		dir = Vector3(sin(visual.rotation.y), 0.0, cos(visual.rotation.y))

		if clamped and dir.z * own_side < 0.0:
			dir.z = 0.0
			if dir.length() < 0.2:
				dir = Vector3(0.0, 0.0, own_side)
	dir = dir.normalized()







	var local: = dir.rotated(Vector3.UP, - visual.rotation.y)
	var side: = 0
	if absf(local.x) > absf(local.z) * tan(deg_to_rad(SIDE_DIVE_DEG)):
		side = 1 if local.x < 0.0 else 2
	return {"dir": Vector2(dir.x, dir.z), "side": side}

func _start_dive(aim: = Vector3.INF, dir2: = Vector2.ZERO, side: = -1) -> void :


	_drop_jump_charge()







	if dir2.length_squared() > 0.5 and side >= 0:

		_dive_dir = Vector3(dir2.x, 0.0, dir2.y).normalized()
		_dive_side = side
	else:
		var target: = aim if aim != Vector3.INF else _dive_intercept()
		var plan: = dive_plan(target)
		_dive_dir = Vector3(plan.dir.x, 0.0, plan.dir.y)
		_dive_side = int(plan.side)




	if _dive_side != 0 and not can_side_dive():
		_dive_side = 0








	_dive_strength_cached = _dive_strength()
	_dive_weak = _dive_strength_cached < 0.999

	var t: = clampf((_dive_strength_cached - FEEL.dive_weak_speed)\
	/ maxf(1.0 - FEEL.dive_weak_speed, 0.001), 0.0, 1.0)
	_dive_span = FEEL.dive_time * lerpf(FEEL.dive_weak_time, 1.0, t)
	_spend_stamina(FEEL.stamina_dive_cost)


	_dive_time = _dive_span
	_dive_touched = false
	_voice("v_dive")

func ball_on_far_side() -> bool:


	return ball != null and ball.global_position.z * float(team_side) < 0.0\
	and not ball.net_contested()






func ball_theirs() -> bool:


	return their_ball_rule and rivals_can_play and ball_on_far_side()\
	and not ball.spike_locked()


static var their_ball_rule: = true

var _puppet_resolved_touch: = TouchKind.NONE
var _puppet_hands_ready: = false





func _show_ready_hands() -> bool:
	if net_puppet:
		return _puppet_hands_ready
	return contact_intent_queued() and grounded() and not knocked()\
	and _dive_time <= 0.0 and contact_state != ContactState.BLOCK

func _ready_hands_kind() -> TouchKind:
	if net_puppet:
		return _puppet_resolved_touch
	return _armed_kind if _armed_kind != TouchKind.NONE else resolved_touch()

func resolved_touch() -> TouchKind:



	if net_puppet:
		return _puppet_resolved_touch




	if _armed_set_button and contact_state == ContactState.WINDUP:
		return TouchKind.SET




	if ball == null:
		return TouchKind.NONE
	return resolved_touch_at(ball.global_position)

func resolved_touch_at(ball_pos: Vector3, assume_same_side: = false) -> TouchKind:




	if not assume_same_side and ball_pos.z * float(team_side) < 0.0\
	and not (ball != null and ball.net_contested()):
		return TouchKind.BLOCK if not grounded() else TouchKind.NONE
	var ball_height: = ball_pos.y
	if not grounded():







		return TouchKind.SPIKE if ball_height >= FEEL.spike_min_ball_height\
		else TouchKind.DUMP




	return TouchKind.BUMP

func _move(input: PlayerInput, delta: float) -> void :



	if _hitstop_hold > 0.0 and not is_on_floor():
		return
	if _knock_time > 0.0:





		if stamina_locked and _knock_time <= FEEL.knock_burnout_hold:
			_knock_time = FEEL.knock_burnout_hold
		else:
			_knock_time -= delta




			if not is_on_floor():
				_knock_time = maxf(_knock_time, FEEL.tumble_settle + 0.05)
		velocity.x *= 0.96
		velocity.z *= 0.96
		var falling: = velocity.y
		if not is_on_floor():
			velocity.y -= FEEL.gravity * delta
		if _knock_time > FEEL.tumble_settle:


			var spin: = (FEEL.tumble_spin_base
				+ Vector2(velocity.x, velocity.z).length() * FEEL.tumble_spin_gain) * delta
			_knock_roll += - spin if _knock_roll < 0.0 else spin
		_slide()
		if is_on_floor() and falling < -3.0:
			velocity.y = - falling * 0.45



			thumped.emit(global_position, 
				clampf(absf(falling) / 9.0, 0.35, 1.0))
		return
	if _dive_time > 0.0:

		_dive_time -= delta


		var fade: = clampf(_dive_time / maxf(_dive_span, 0.001), 0.3, 1.0)
		var dspeed: = FEEL.dive_speed * _dive_strength_cached
		velocity.x = _dive_dir.x * dspeed * fade
		velocity.z = _dive_dir.z * dspeed * fade





		var net_side: = float(team_side)
		if net_side != 0.0 and velocity.z * net_side < 0.0 and global_position.z * net_side <= DIVE_NET_STOP:
			velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= FEEL.gravity * delta
		_slide()



		if _dive_hit_static_geometry():
			var into_net: = _dive_crashed_into_net
			knock(Vector3( - _dive_dir.x * FEEL.dive_speed * 0.35, 1.8, 
				- _dive_dir.z * FEEL.dive_speed * 0.35))
			if into_net:
				dove_into_net.emit()
		return
	if _getup_time > 0.0 and is_on_floor():



		velocity.x = move_toward(velocity.x, 0.0, FEEL.accel * 1.6 * delta)
		velocity.z = move_toward(velocity.z, 0.0, FEEL.accel * 1.6 * delta)
		_slide()
		return
	if is_on_floor():





		if sim_authority and sweat > FEEL.trip_sweat_min\
		and Vector2(velocity.x, velocity.z).length() > 4.0\
		and randf() < sweat * FEEL.trip_chance * delta\
		* lerpf(0.5, 1.0, _sloppiness()) * _slip_factor():
			_slip_grace = randf_range(3.0, 8.0)
			show_float_text("slip!", Color(0.6, 0.8, 1.0), true)
			knock(Vector3(velocity.x, 1.4, velocity.z), 0.7)
			_slide()
			return
		var speed: = FEEL.move_speed
		var accel: = FEEL.accel
		if _sprint_ramp > 0.01:




			speed *= lerpf(1.0, _sprint_speed_mul(), _sprint_ramp)
		if _strafe_held:


			speed *= FEEL.strafe_back_speed if _moving_backward() else FEEL.strafe_speed
			accel *= FEEL.strafe_accel
		if _holding_receive_stance():


			speed *= FEEL.receive_stance_speed
		var wish: = Vector3(input.move.x, 0.0, input.move.y) * speed





		if contact_state == ContactState.RECOVER and not contact_intent_queued():
			wish *= FEEL.windup_move_factor



		if input.jump_cancelled:
			_jump_charge = 0.0
			_jump_full_time = 0.0




		if _jump_charge > 0.0 and _jump_cancel_fresh:
			_jump_charge = 0.0
			_jump_full_time = 0.0
			_jump_canceled = true
		if input.jump_held and not _jump_canceled:

			if _jump_charge >= FEEL.jump_charge_time or _jump_full_time > 0.0:





				_jump_full_time += delta
				if _jump_full_time > FEEL.jump_hold_grace:
					_jump_charge = maxf(_jump_charge\
					- FEEL.jump_decay_rate * delta, 0.0)
					if _jump_charge <= 0.0:




						_jump_canceled = true
				else:
					_jump_charge = FEEL.jump_charge_time
			else:
				_jump_charge = minf(_jump_charge + delta, FEEL.jump_charge_time)

		var travel: = Vector2(velocity.x, velocity.z)
		var want: = Vector2(wish.x, wish.z)
		var rate: = accel * (FEEL.accel_start / FEEL.accel)
		if want.length() < 0.1:





			rate = FEEL.accel_stop * (FEEL.strafe_stop if _strafe_held else 1.0)
		elif travel.length() > 0.5:


			var agree: = travel.normalized().dot(want.normalized())
			rate = accel * lerpf(FEEL.accel_turn / FEEL.accel, FEEL.accel_start / FEEL.accel, 
				clampf((agree + 1.0) * 0.5, 0.0, 1.0))
			if _sprint_ramp > 0.01:




				var g: = lerpf(FEEL.sprint_grip, 1.0, clampf(agree, 0.0, 1.0))
				rate *= lerpf(1.0, g, _sprint_ramp)
			if _strafe_held:






				rate *= lerpf(FEEL.strafe_grip, 1.0, clampf(agree, 0.0, 1.0))
			elif agree < FEEL.plant_dot\
			and travel.length() > (FEEL.sprint_plant_speed if _sprint_ramp > 0.5\
			else FEEL.plant_speed)\
			and _plant_time <= 0.0 and _plant_cd <= 0.0:
				_plant_time = FEEL.plant_time
				_plant_cd = FEEL.plant_cooldown




		if _plant_time > 0.0 and not _strafe_held:
			rate *= FEEL.plant_grip
		velocity.x = move_toward(velocity.x, wish.x, rate * delta)
		velocity.z = move_toward(velocity.z, wish.z, rate * delta)
		if input.jump_released:
			if _jump_canceled:





				_jump_canceled = false
				_jump_charge = 0.0
				_jump_full_time = 0.0
			else:
				var charge: = _jump_charge / FEEL.jump_charge_time










				var bam: = not is_bot and not stamina_locked and charge >= 0.999\
				and _jump_full_time >= FEEL.bam_delay\
				and _jump_full_time <= FEEL.bam_delay + FEEL.bam_window
				velocity.y = lerpf(FEEL.jump_min_velocity, FEEL.jump_max_velocity, charge)
				_jump_variant = _pick_jump_take(charge, bam)
				if bam:
					velocity.y = FEEL.jump_max_velocity * FEEL.bam_jump_mult





					stamina = 0.0
					_begin_lockout()
				_voice("v_jump")
				jumped.emit(bam)
				if charge >= FEEL.jump_launch_charge:

					launched.emit(global_position, 1.6 if bam else charge)












				var sprint_carry: = lerpf(1.0, FEEL.jump_sprint_carry, charge)
				var carry: = lerpf(FEEL.jump_carry, sprint_carry, _sprint_ramp)
				velocity.x *= carry
				velocity.z *= carry
				_jump_charge = 0.0
				_jump_full_time = 0.0
	else:






		_jump_charge = 0.0
		_jump_full_time = 0.0
		var g: = FEEL.gravity
		if velocity.y > 0.0 and velocity.y < FEEL.apex_float_threshold:

			g *= FEEL.apex_float_factor
		elif velocity.y <= 0.0:


			g *= FEEL.fall_gravity_mult
		velocity.y -= g * delta
	_slide()

var _dive_crashed_into_net: = false

func _dive_hit_static_geometry() -> bool:
	_dive_crashed_into_net = false
	for i in get_slide_collision_count():
		var hit: = get_slide_collision(i)
		var collider: = hit.get_collider()



		if collider != null and not collider is Player\
		and absf(hit.get_normal().y) < 0.5:

			_dive_crashed_into_net = (collider as Node).name == &"NetBody"
			return true
	return false

func _turn(delta: float) -> void :



	if _knock_time > 0.0:



		return
	if getting_up():



		return
	if _dive_time > 0.0:



		if _dive_side == 0:
			var dive_yaw: = atan2(_dive_dir.x, _dive_dir.z)
			visual.rotation.y = rotate_toward(visual.rotation.y, dive_yaw, FEEL.turn_speed * delta)
		return
	if _first_person:


		var to_look: = aim_point - global_position
		to_look.y = 0.0
		if to_look.length() > 0.3:
			visual.rotation.y = rotate_toward(visual.rotation.y, 
				atan2(to_look.x, to_look.z), FEEL.turn_speed * 1.6 * delta)
		return
	if (serving or serve_charge_ui) and serve_squares:






		var serve_aim: = aim_point - global_position
		serve_aim.y = 0.0
		if serve_aim.length() > 0.3:
			visual.rotation.y = rotate_toward(visual.rotation.y, 
				atan2(serve_aim.x, serve_aim.z), FEEL.turn_speed * delta)
		return











	if contact_state == ContactState.WINDUP and resolved_touch() != TouchKind.SET\
	and not is_on_floor():
		var to_aim: = aim_point - global_position
		to_aim.y = 0.0
		if to_aim.length() > 0.5:
			var aim_yaw: = atan2(to_aim.x, to_aim.z)
			visual.rotation.y = rotate_toward(visual.rotation.y, aim_yaw, FEEL.turn_speed * delta)
		return


	if _jump_charge > 0.0 and not _set_windup and is_bot:




		var jump_aim: = aim_point - global_position
		jump_aim.y = 0.0
		if jump_aim.length() > 0.5:
			visual.rotation.y = rotate_toward(visual.rotation.y, 
				atan2(jump_aim.x, jump_aim.z), FEEL.turn_speed * delta)
		return
	if not is_on_floor():
		return






	if _strafe_held:
		var strafe_aim: = aim_point - global_position
		strafe_aim.y = 0.0
		if strafe_aim.length() > 0.5:
			visual.rotation.y = rotate_toward(visual.rotation.y, 
				atan2(strafe_aim.x, strafe_aim.z), FEEL.turn_speed * delta)
		return
	if _move_intent.length() > 0.2:
		var target_yaw: = atan2(_move_intent.x, _move_intent.y)
		visual.rotation.y = rotate_toward(visual.rotation.y, target_yaw, FEEL.turn_speed * delta)

func _set_contact(input: PlayerInput, delta: float) -> void :









	if grounded():
		_dump_push_left = 0.0
	elif dump_push(input):
		_dump_push_left = DUMP_PUSH_BUFFER
	else:
		_dump_push_left = maxf(_dump_push_left - delta, 0.0)
	if getting_up():
		return
	if not _set_windup:
		var back: = input.back_pass_pressed and not input.set_pressed
		if contact_state != ContactState.IDLE or not (input.set_pressed or back)\
		or not set_opportunity_available():
			return
		_set_windup = true
		_set_back = back
		contact_state = ContactState.WINDUP
		hold_time = 0.0
		_hold_real = 0.0
		_armed_kind = TouchKind.SET
		_armed_from_ground = grounded()
		_armed_aim = input.aim
		_armed_influence = _air_influence(input)
		_armed_wait_for_release = true


		_intent_used_strike = ball.strike_seq
		_intent_queued_at_usec = Time.get_ticks_usec()
		_armed_set_button = true
		return


	hold_time = minf(hold_time + delta, FEEL.max_hold)
	_hold_real += delta
	_armed_aim = input.aim
	_armed_influence = _air_influence(input)
	if not input.set_released:
		return
	_set_windup = false
	_armed_wait_for_release = false


	if not contact_enabled or knocked() or _dive_time > 0.0:
		_clear_contact_intent()
		contact_state = ContactState.IDLE
		hold_time = 0.0
		_hold_real = 0.0
		return
	var rel_aim: = input.aim
	if _set_back:
		var yaw: = visual.rotation.y
		rel_aim = global_position - Vector3(sin(yaw), 0.0, cos(yaw)) * 2.4
	var plan: = set_release_plan(rel_aim, hold_power(), _dump_push_left > 0.0)
	var power: float = plan[0]
	var quick: bool = plan[1]
	var target: Vector3 = plan[2]
	var set_kind: TouchKind = plan[3]
	var live_aim: = aim_point
	aim_point = target
	var in_reach: = ball != null and not ball.frozen and _swing_reach_check()
	if in_reach and not contact_barred() and _touch_lock <= 0.0:
		_armed_aim = target
		_armed_power = power
		_armed_finesse = _contact_finesse(set_kind)
		if _set_back:
			_receive_side = 3
		_dump_rise = set_dump_rise(power) if set_kind == TouchKind.DUMP else -1.0
		_do_touch(set_kind, power, _armed_finesse, 
			_armed_influence, quick)
		_dump_rise = -1.0
	elif ball_theirs():

		_recover_left = FEEL.whiff_recover_time
		contact_state = ContactState.RECOVER
	else:





		_armed_kind = TouchKind.SET
		_armed_power = power
		_armed_finesse = _hold_real <= FEEL.tap_hold
		_armed_aim = target
		_armed_quick = quick
		_queued_fill = hold_power()


		_armed_dump = set_kind == TouchKind.DUMP


		_receive_window = FEEL.set_release_queue_window
		_recover_left = FEEL.whiff_recover_time
		contact_state = ContactState.RECOVER
	aim_point = live_aim
	hold_time = 0.0
	_hold_real = 0.0






func set_release_plan(aim: Vector3, power: float, pushed: = false) -> Array:
	if set_dump_intent(pushed):
		return [power, false, set_dump_target(aim), TouchKind.DUMP]









	var quick: = power >= (0.8 if is_bot else FEEL.set_quick_charge)
	if is_bot and not quick:
		power = Ball.bot_set_power(power)
	if is_bot and TeamBot.QUICK_TO_AIRBORNE and not quick and quick_check.is_valid()\
	and bool(quick_check.call(aim, self)):
		quick = true






	if Vector2(aim.x - global_position.x, aim.z - global_position.z).length()\
	< (Ball.PHYS.set_near_dist if is_bot else SET_SELF_ZONE):
		quick = false
	return [power, quick, set_target_point(aim, quick), TouchKind.SET]










func set_dump_intent(pushed: bool) -> bool:
	return not is_bot and pushed and not grounded() and in_front_zone()






func dump_push(input: PlayerInput) -> bool:
	if team_side == 0:
		return false
	return input.move.y * - float(team_side) > FEEL.dump_tilt

const DUMP_PUSH_BUFFER: = 0.3



func in_front_zone() -> bool:
	var half_l: = maxf(ball.court_half_l, 2.0) if ball != null else 9.0
	return global_position.z * float(team_side) <= half_l / 3.0 + FRONT_ZONE_GRACE




func set_dump_target(raw_aim: Vector3) -> Vector3:
	var half_w: = maxf(ball.court_half_w, 1.0) if ball != null else 4.5
	var half_l: = maxf(ball.court_half_l, 2.0) if ball != null else 9.0
	var ccx: = ball.court_center_x if ball != null else 0.0
	var their: = - float(team_side)
	var depth: = raw_aim.z * their
	if depth <= 0.0:
		return Vector3(clampf(global_position.x, ccx - half_w, ccx + half_w), 0.0, 
			their * SET_DUMP_SHORT)
	var x: = clampf(raw_aim.x, ccx - half_w - SET_APRON, ccx + half_w + SET_APRON)
	return Vector3(x, 0.0, their * clampf(depth, SET_DUMP_MIN_DEPTH, half_l + SET_APRON))







func set_dump_rise(power: float) -> float:
	return lerpf(SET_DUMP_RISE_TAP, SET_DUMP_RISE_FULL, clampf(power, 0.0, 1.0))

const FRONT_ZONE_GRACE: = 0.3
const SET_DUMP_SHORT: = 1.2
const SET_DUMP_MIN_DEPTH: = 0.6
const SET_DUMP_RISE_TAP: = 2.8
const SET_DUMP_RISE_FULL: = 0.2

func set_target_point(raw_aim: Vector3, quick: = false) -> Vector3:










	var half_w: = maxf(ball.court_half_w, 1.0) if ball != null else 4.5
	var half_l: = maxf(ball.court_half_l, 2.0) if ball != null else 9.0
	var ccx: = ball.court_center_x if ball != null else 0.0




	var x: = clampf(raw_aim.x, ccx - half_w - SET_APRON, ccx + half_w + SET_APRON)
	var own_depth: = raw_aim.z * float(team_side)
	return Vector3(x, 0.0, float(team_side) * clampf(own_depth, SET_MIN_DEPTH, half_l + SET_APRON))

const SET_POCKET_DEPTH: = 1.75



const SET_SELF_ZONE: = 1.0

func set_is_tower(aim: Vector3) -> bool:
	return not is_bot and Vector2(aim.x - global_position.x, 
		aim.z - global_position.z).length() < SET_SELF_ZONE






func set_preview() -> Dictionary:
	if not _set_windup or ball == null:
		return {}
	var aim: = _armed_aim
	var power: = hold_power()
	var tap: = _hold_real <= FEEL.tap_hold
	var quick: = power >= FEEL.set_quick_charge and not is_bot
	if set_is_tower(aim):
		quick = false
	var from: = _set_meet_guess()
	if set_dump_intent(_dump_push_left > 0.0):



		var dt: = set_dump_target(aim)
		var vy: = sqrt(2.0 * Ball.PHYS.gravity
			* Ball.tip_rise_over_tape(from, dt, set_dump_rise(power)))
		var g: = Ball.PHYS.gravity
		var t: = (vy + sqrt(maxf(vy * vy + 2.0 * g * (from.y - dt.y), 0.0))) / g
		var flat: = Vector3(dt.x - from.x, 0.0, dt.z - from.z) / maxf(t, 0.05)
		return {"from": from, "vel": Vector3(flat.x, vy, flat.z), "stop": -1.0, 
			"power": power, "dump": true}
	var target: = set_target_point(aim, quick)
	if quick and Ball.stop_sets:
		var st: = Ball.solve_stop(from, target)
		return {"from": from, "vel": st[0], "stop": float(st[1]), "power": power}
	var v: = Ball.solve_launch(from, target, TouchKind.SET, power, tap, Vector2.ZERO, 
		Rules.touch_clears_net(TouchKind.SET), quick, false, set_is_tower(aim))
	return {"from": from, "vel": v, "stop": -1.0, "power": power}



func _set_meet_guess() -> Vector3:
	var chest: = chest_position()
	if ball.frozen or ball.global_position.distance_to(chest) < FEEL.reach + 0.3:
		return ball.global_position
	var p: = ball.global_position
	var v: = ball.vel
	var c: = ball.curve
	var sc: = ball.stop_clock
	var best: = p
	var best_d: = p.distance_to(chest)
	for _i in 90:
		var st: = Ball.step_flight(p, v, c, 1.0 / 30.0, ball.net_half_width, 
			ball.court_center_x, ball.wall_min, ball.wall_max, sc)
		p = st[0]
		v = st[1]
		c = st[2]
		sc = st[3]
		var d: = p.distance_to(chest)
		if d < best_d:
			best_d = d
			best = p
		if p.y <= Ball.PHYS.radius + 0.01:
			break
	return best



const SET_MIN_DEPTH: = 0.35
const SET_APRON: = 1.0


const BACK_SET_DOT: = -0.35



static func back_set_dir(yaw: float, dir_flat: Vector3) -> bool:
	var d: = Vector3(dir_flat.x, 0.0, dir_flat.z)
	if d.length() < 0.5:
		return false
	return Vector3(sin(yaw), 0.0, cos(yaw)).dot(d.normalized()) < BACK_SET_DOT

func set_pocket_point(raw_aim: Vector3, quick: = false) -> Vector3:









	var half_w: = maxf(ball.court_half_w, 1.0) if ball != null else 4.5
	var ccx: = ball.court_center_x if ball != null else 0.0
	var x: = clampf(raw_aim.x, ccx - half_w + 0.7, ccx + half_w - 0.7)
	if quick:




		return Vector3(x, 0.0, float(team_side) * clampf(absf(raw_aim.z), 0.9, 3.2))





	if Vector2(raw_aim.x - global_position.x, 
			raw_aim.z - global_position.z).length() < Ball.PHYS.set_near_dist:
		return Vector3(x, 0.0, float(team_side) * maxf(absf(raw_aim.z), 0.9))
	return Vector3(x, 0.0, float(team_side) * SET_POCKET_DEPTH)

func set_opportunity_available() -> bool:
	if not contact_enabled or ball == null or ball.frozen or contact_barred()\
	or knocked() or contact_state == ContactState.RECOVER\
	or contact_state == ContactState.BLOCK or ball_on_far_side():
		return false
	if _intent_used_strike == ball.strike_seq:
		return false



	if ball.global_position.z * float(team_side) >= -0.25\
	and ball.global_position.y > FEEL.set_min_ball_height:
		return true
	if _swing_reach_check():


		return ball.global_position.z * float(team_side) >= -0.25\
		and ball.global_position.y > FEEL.set_min_ball_height
	var chest: = chest_position()
	var horizon: = FEEL.set_queue_horizon
	for i in range(1, FEEL.contact_queue_steps + 1):
		var t: = horizon * float(i) / float(FEEL.contact_queue_steps)
		var ball_at: = ball.global_position + ball.vel * t\
		+ Vector3(0.0, -0.5 * Ball.PHYS.gravity * t * t, 0.0)
		var chest_at: = chest + velocity * t
		var same_side: = ball_at.z * float(team_side) >= -0.25
		var overhead: = ball_at.y > FEEL.set_min_ball_height
		if same_side and overhead and ball_at.distance_to(chest_at) <= FEEL.set_precharge_reach:
			return true
	return false







func _whiff_swing(power: float) -> void :



	last_touch = TouchKind.SPIKE
	_spike_light = power < FEEL.spike_charge_cap * 0.5
	_receive_pose = FEEL.spike_air_hold
	contact_state = ContactState.RECOVER

	_recover_left = maxf(FEEL.whiff_recover_time, FEEL.spike_air_hold)








var _free_swing: = false











func _far_side_is_cosmetic() -> bool:
	if is_bot:
		return true
	match contact_state:
		ContactState.WINDUP:
			return _free_swing
		ContactState.IDLE:
			return not grounded() and contact_opportunity_kind() == TouchKind.NONE
	return true

func _free_charge(input: PlayerInput, delta: float) -> void :
	if contact_state == ContactState.IDLE:
		if input.contact_pressed and not is_on_floor() and _knock_time <= 0.0\
		and _dive_time <= 0.0 and not _air_spent:
			_free_swing = true
			contact_state = ContactState.WINDUP
			_armed_kind = TouchKind.SPIKE
			_armed_set_button = false
			_armed_from_ground = false
			_armed_aim = input.aim
			hold_time = 0.0
			_hold_real = 0.0
	elif contact_state == ContactState.WINDUP:



		var rate: = FEEL.air_charge_rate if not is_on_floor() else 1.0
		hold_time = minf(hold_time + delta * rate, FEEL.max_hold)
		_hold_real += delta
		_armed_aim = input.aim
		if not input.contact_pressed:


			swung.emit(TouchKind.SPIKE)
			_whiff_swing(hold_power())
		elif is_on_floor():
			cancel_contact()
	elif contact_state == ContactState.RECOVER:

		_recover_left = maxf(_recover_left - delta, 0.0)
		if _recover_left <= 0.0:
			contact_state = ContactState.IDLE

func _contact(input: PlayerInput, delta: float) -> void :
	_block_hit_cooldown = maxf(_block_hit_cooldown - delta, 0.0)






	if contact_state == ContactState.BLOCK and is_on_floor():
		contact_state = ContactState.RECOVER
		_recover_left = 0.25




	if is_on_floor():
		_air_spent = false


		if contact_state != ContactState.WINDUP:
			_release_charge = 0.0







	var free_block: = false
	if contact_state != ContactState.WINDUP:
		_free_swing = false
	if free_actions and not serving and not serve_charge_ui:





		if contact_state == ContactState.BLOCK:






			free_block = true
		elif ball == null or ball.frozen or not contact_enabled\
		or (ball_on_far_side() and _far_side_is_cosmetic()):






			_free_charge(input, delta)
			return
	if _free_swing and contact_state == ContactState.WINDUP:







		_free_swing = false
		_armed_kind = TouchKind.NONE
		_early_contact_from_ground = grounded()
		_armed_from_ground = grounded()
	if not contact_enabled and not free_block:
		if contact_state != ContactState.IDLE or _receive_window > 0.0:
			cancel_contact()
		return
	if getting_up():




		if contact_state != ContactState.IDLE or _receive_window > 0.0:


			var keep_dig: = _dive_touched
			cancel_contact()
			if not _was_knocked_getup:
				_dive_touched = keep_dig
		return
	if _set_windup:
		return
	match contact_state:
		ContactState.IDLE:


			if jump_charging_on_floor():
				return
			var opportunity_kind: = contact_opportunity_kind()
			if input.contact_pressed and not _air_spent and not _receive_hold_spent\
			and not (serve_charge_ui and _serve_hold_stale):
				if ball != null and _intent_used_strike == ball.strike_seq:
					return








				if not serve_charge_ui and opportunity_kind == TouchKind.NONE\
				and input.contact_pressed\
				and ball != null and not ball.frozen\
				and not contact_barred() and _touch_lock <= 0.0\
				and (grounded() or not ball_on_far_side() or _aim_across_net()):








					contact_state = ContactState.WINDUP
					hold_time = 0.0
					_hold_real = 0.0























					_armed_kind = TouchKind.NONE
					if is_bot:






						_early_contact_from_ground = grounded() and _jump_charge <= 0.0
						_armed_from_ground = grounded()
					else:










						var air_commit: = not grounded() or _jump_charge > 0.0\
						or velocity.y > 0.0
						_early_contact_from_ground = not air_commit
						_armed_from_ground = not air_commit
					_armed_aim = aim_point
					_armed_influence = _air_influence(input)
					return
				var opportunity_open: = opportunity_kind != TouchKind.NONE\
				and ball != null and _intent_used_strike != ball.strike_seq



				if opportunity_kind != TouchKind.NONE and not opportunity_open:
					return
				if not is_on_floor() and ball_on_far_side() and not _aim_across_net():





					return
				else:
					_early_contact_from_ground = false






					if not is_bot and opportunity_kind == TouchKind.NONE:
						_early_contact_from_ground = grounded() and _jump_charge <= 0.0\
						and velocity.y <= 0.0
					contact_state = ContactState.WINDUP
					hold_time = 0.0
					_hold_real = 0.0
					_armed_kind = opportunity_kind
					_armed_set_button = false
					_armed_from_ground = grounded()
					_armed_aim = aim_point
					_armed_influence = _air_influence(input)









					_armed_wait_for_release = opportunity_open and not grounded()
					if opportunity_open:
						_intent_used_strike = ball.strike_seq
						_intent_queued_at_usec = Time.get_ticks_usec()



					if grounded() and opportunity_open:
						_armed_power = 0.0
						_armed_finesse = true
						_receive_window = FEEL.press_receive_window
					elif opportunity_open:
						_armed_power = 0.0
						_armed_finesse = true
						_receive_window = FEEL.air_arm_window
		ContactState.WINDUP:












			if not is_bot and _armed_kind == TouchKind.NONE\
			and _early_contact_from_ground and not grounded():
				_early_contact_from_ground = false
				_armed_from_ground = false






				hold_time = 0.0
				_hold_real = 0.0
				_charge_turn = 0.0






			if not serve_charge_ui and _armed_kind == TouchKind.NONE\
			and _early_contact_from_ground == grounded()\
			and not jump_charging_on_floor():
				var promoted_kind: = contact_opportunity_kind()
				if promoted_kind != TouchKind.NONE and ball != null\
				and _intent_used_strike != ball.strike_seq:
					_armed_kind = promoted_kind
					_intent_used_strike = ball.strike_seq
					_intent_queued_at_usec = Time.get_ticks_usec()
					_receive_window = FEEL.press_receive_window if grounded()\
					else FEEL.air_arm_window







					_armed_wait_for_release = promoted_kind != TouchKind.BUMP

			if not is_bot and not grounded() and resolved_touch() != TouchKind.SET:
				_spike_turn_bleed()


			var rate: = FEEL.air_charge_rate if not is_on_floor() else 1.0












			var floor_hold: = not is_bot and is_on_floor() and not serve_charge_ui



			var let_go: = not is_bot and not input.contact_pressed
			if not floor_hold and not let_go:
				hold_time = minf(hold_time + delta * rate, FEEL.max_hold)
				_hold_real += delta
			if _receive_window > 0.0:
				_armed_power = hold_power()
				_armed_finesse = _contact_finesse(_armed_kind)
				_armed_aim = aim_point
				_armed_influence = _air_influence(input)
			if input.contact_released and jump_charging_on_floor():



				if not _armed_set_button:
					_clear_contact_intent()
					_intent_used_strike = -1
				contact_state = ContactState.IDLE
				hold_time = 0.0
				_hold_real = 0.0
				_early_contact_from_ground = false
				return
			if input.contact_released:



				_armed_power = hold_power()
				_armed_finesse = _contact_finesse(_armed_kind)


				_release_charge = hold_power()


				_queued_fill = hold_power()
				if not serve_charge_ui and not is_bot\
				and _armed_kind == TouchKind.NONE:







					var fading_kind: = contact_opportunity_kind()
					var fading_reach: = ball != null and not ball.frozen\
					and (_swing_reach_check() or _reach_left > 0.0)
					if fading_kind != TouchKind.NONE and fading_reach\
					and not contact_barred()\
					and not (contact_priority_check.is_valid()\
					and contact_intent_queued()\
					and not bool(contact_priority_check.call(self))):
						var fading_power: = hold_power()
						if fading_kind == TouchKind.BUMP:
							fading_power = _receive_quality()
						elif fading_kind == TouchKind.SPIKE:
							fading_power = minf(hold_power() + _spike_overdrive(), SPIKE_POWER_MAX)
						var fading_quick: = fading_kind == TouchKind.SET\
						and fading_power >= 0.8
						_armed_aim = aim_point
						_do_touch(fading_kind, fading_power, _hold_real <= FEEL.tap_hold, 
							_air_influence(input), fading_quick)
						contact_state = ContactState.IDLE
						hold_time = 0.0
						_hold_real = 0.0
						_early_contact_from_ground = false
						return









					if not is_on_floor() and not is_bot and _aim_across_net()\
					and ball != null and not ball.frozen and not contact_barred()\
					and ball_on_far_side() and not ball_theirs()\
					and _intent_used_strike != ball.strike_seq:
						_armed_kind = TouchKind.SPIKE
						_armed_from_ground = false
						_armed_wait_for_release = false
						_armed_power = minf(hold_power() + _spike_overdrive(), SPIKE_POWER_MAX)
						_armed_finesse = _contact_finesse(TouchKind.SPIKE)
						_armed_aim = aim_point
						_armed_influence = _air_influence(input)
						_intent_used_strike = ball.strike_seq
						_intent_queued_at_usec = Time.get_ticks_usec()
						_receive_window = FEEL.press_receive_window
						contact_state = ContactState.IDLE
						hold_time = 0.0
						_hold_real = 0.0
						_early_contact_from_ground = false
						return


					if grounded() and contact_opportunity_available():
						early_contact_seq += 1
						show_float_text("early", Color(0.72, 0.76, 0.84), false, 
							0.28, false)
					elif not is_on_floor() and _windup_pose_kind() == TouchKind.SPIKE:






						swung.emit(TouchKind.SPIKE)
						_whiff_swing(hold_power())
						hold_time = 0.0
						_hold_real = 0.0
						_early_contact_from_ground = false
						return
					else:




						out_of_range.emit()
					contact_state = ContactState.IDLE
					hold_time = 0.0
					_hold_real = 0.0
					_early_contact_from_ground = false
					return
				if serve_charge_ui:




					contact_state = ContactState.IDLE
					_recover_left = 0.0
					_receive_window = 0.0
				elif _airborne_attack_armed() and _hold_real <= FEEL.tap_hold:






					_armed_wait_for_release = false
				elif BOT_QUIET_LETGO and is_bot and grounded() and _armed_kind == TouchKind.NONE and not (ball != null and not ball.frozen and (_swing_reach_check() or _reach_left > 0.0)):









					contact_state = ContactState.IDLE
					hold_time = 0.0
					_hold_real = 0.0
					_early_contact_from_ground = false
				else:



					_armed_wait_for_release = false
					_swing(input)
		ContactState.BLOCK:
			_block_time += delta
			_update_block_shift(input, delta)



			if is_on_floor():
				contact_state = ContactState.RECOVER
				_recover_left = 0.25
			elif contact_enabled:


				_try_block_deflect()
		ContactState.RECOVER:
			_recover_left -= delta
			if _recover_left <= 0.0:
				contact_state = ContactState.IDLE

func _start_block(input: PlayerInput) -> void :
	contact_state = ContactState.BLOCK
	_block_time = 0.0
	_block_shifted = false
	_shift_progress = 1.0
	block_lane = _lane_from_input(input)
	_shift_from = block_lane

func _lane_from_input(input: PlayerInput) -> int:
	if input.move.x > 0.4:
		return 1
	if input.move.x < -0.4:
		return -1
	return 0

func _update_block_shift(input: PlayerInput, delta: float) -> void :
	if _shift_progress < 1.0:
		_shift_progress = minf(_shift_progress + delta / FEEL.block_shift_time, 1.0)
		return
	if _block_shifted:

		return
	var want: = _lane_from_input(input)
	if want != 0 and want != block_lane:
		_shift_from = block_lane
		block_lane = want
		_block_shifted = true
		_shift_progress = 0.0

func block_live() -> bool:

	return contact_state == ContactState.BLOCK\
	and _block_time >= FEEL.block_windup\
	and _shift_progress >= 1.0





func _block_broken_by(b: Ball) -> bool:
	if b.last_hit_kind != TouchKind.SPIKE:
		return false
	var since_live: = _block_time - FEEL.block_windup
	var travel: = Vector3(b.vel.x, 0.0, b.vel.z).normalized()
	var facing: = Vector3(sin(visual.rotation.y), 0.0, cos(visual.rotation.y))
	return break_decides(b.last_hit_power, travel.dot( - facing), since_live, 
		b.last_hit_momentum)












static func break_decides(power: float, align: float, since_live: float, 
		momentum: float) -> bool:



	if align < FEEL.block_back_align:
		return true

	if since_live <= FEEL.block_perfect_window:
		return false

	if power < FEEL.block_break_power:
		return false
	var offline: = clampf(1.0 - align, 0.0, 1.0)
	var late: = clampf((since_live - FEEL.block_perfect_window) / FEEL.block_break_late_span, 
		0.0, 1.0)
	var run: = lerpf(FEEL.block_break_still_mult, 1.0, clampf(momentum, 0.0, 1.0))
	return (late + FEEL.block_angle_weight * offline) * run >= FEEL.block_break_at





static func break_momentum(toward_speed: float) -> float:
	var lo: = FEEL.block_break_momentum_from
	return clampf((toward_speed - lo) / maxf(FEEL.approach_ref_speed - lo, 0.01), 0.0, 1.0)

func block_was_broken() -> bool:
	return _block_broken_flag


func block_shifted() -> bool:
	return _block_shifted

func block_center() -> Vector3:
	var lane_x: = lerpf(float(_shift_from), float(block_lane), _shift_progress)\
	* FEEL.block_lane_offset
	var toward_net: = - signf(global_position.z)
	return global_position + Vector3(lane_x, FEEL.block_height, toward_net * 0.35)

const BLOCK_TAPE_SLACK: = 0.05


static var block_cross_rule: = true

func _try_block_deflect() -> void :
	if not sim_authority:
		return
	if not block_live() or _block_hit_cooldown > 0.0:
		return


	if ball == null or ball.frozen:
		return







	if contact_barred():
		return

	if signf(ball.vel.z) != signf(global_position.z):
		return






	if block_cross_rule and signf(ball.global_position.z) != signf(global_position.z)\
	and not ball.net_contested():
		return





	if ball.global_position.y - Ball.PHYS.radius < Ball.PHYS.net_height - BLOCK_TAPE_SLACK:
		return
	var center: = block_center()
	if ball.global_position.distance_to(center) <= FEEL.block_radius + Ball.PHYS.radius:
		if _block_broken_by(ball):
			block_broken.emit(center)

			ball.strike_source = self
			ball.power_through()
			knock(Vector3( - ball.vel.x * 0.15, 2.2, 
				signf(global_position.z) * 2.4))
			_block_hit_cooldown = FEEL.block_cooldown
			last_touch = TouchKind.BLOCK
			_kick_foot = 0
			_block_broken_flag = true
			_block_ot = false
			touched.emit(TouchKind.BLOCK)
			_kick_recoil(TouchKind.BLOCK)
			return
		ball.strike_source = self





		var since_live: = _block_time - FEEL.block_windup
		var late: = clampf((since_live - FEEL.block_perfect_window)
			/ FEEL.block_break_late_span, 0.0, 1.0)
		var deflect_aim: = aim_point
		if late > 0.0:
			var ang: = randf() * TAU
			var r: = late * FEEL.block_late_scatter
			deflect_aim += Vector3(cos(ang) * r, 0.0, sin(ang) * r)


		ball.block_deflect(center, deflect_aim, late)



		_block_ot = signf(ball.vel.z) == signf(team_side)
		_block_hit_cooldown = FEEL.block_cooldown


		_air_spent = true
		last_touch = TouchKind.BLOCK
		_kick_foot = 0





		_receive_pose = 1.2
		settle()
		_block_broken_flag = false
		touched.emit(TouchKind.BLOCK)
		_kick_recoil(TouchKind.BLOCK)





		contact_state = ContactState.RECOVER
		_recover_left = 0.25

func _swing(input: PlayerInput) -> void :
	var kind: = resolved_touch()


	var was_spike_swing: = _windup_pose_kind() == TouchKind.SPIKE
	var swing_charge: = hold_power()



	if was_spike_swing:
		swung.emit(TouchKind.SPIKE)


	var in_reach: = ball != null and not ball.frozen\
	and (_swing_reach_check() or _reach_left > 0.0)
	if kind != TouchKind.NONE and in_reach and not contact_barred():
		var finesse: = _contact_finesse(kind)
		var influence: = _air_influence(input)










		last_perfect = kind == TouchKind.SPIKE and not is_on_floor()\
		and absf(velocity.y) < 0.7 and not is_bot



		var power: float
		if kind == TouchKind.BUMP:
			power = _receive_quality()
		elif kind == TouchKind.SPIKE:
			if ball != null and ball.serve_assist and serve_style.size() > 0:
				power = float(serve_style.get("power", 0.5))
			else:
				power = 1.0 if last_perfect else minf(hold_power() + _spike_overdrive(), SPIKE_POWER_MAX)






			if not is_bot:
				power *= _approach_factor()





			if _float_serve_intent(influence):
				power = minf(power, FEEL.float_power_cap)
			elif not is_bot and influence.y > FEEL.drive_tilt:
				power = minf(power + FEEL.drive_power_bonus, 1.0)
		else:
			power = hold_power()


		var quick: = kind == TouchKind.SET and is_bot and quick_check.is_valid()\
		and bool(quick_check.call(aim_point, self))
		_armed_power = power
		_armed_finesse = finesse
		_armed_aim = aim_point
		_armed_influence = influence
		_armed_wait_for_release = false
		if contact_priority_check.is_valid() and contact_intent_queued()\
		and not bool(contact_priority_check.call(self)):
			_receive_window = FEEL.receive_window if is_on_floor() else FEEL.air_arm_window
		else:
			_do_touch(kind, power, finesse, influence, quick)
	else:
		_recover_left = FEEL.whiff_recover_time






		var can_arrive: = true
		if was_spike_swing and not is_on_floor() and not is_bot and ball != null:
			var gap: = ball.global_position.distance_to(chest_position())\
			- (FEEL.reach + FEEL.spike_air_reach_bonus)
			var closing: = (ball.vel - velocity).length()
			can_arrive = gap <= closing * FEEL.air_arm_window + 0.3



		if can_arrive and not contact_barred() and _armed_kind != TouchKind.NONE\
		and _armed_kind != TouchKind.BLOCK and ball != null\
		and _intent_used_strike == ball.strike_seq:
			_receive_window = FEEL.receive_window if is_on_floor() else FEEL.air_arm_window
			_armed_power = hold_power()
			_queue_swung = was_spike_swing
			_armed_finesse = _contact_finesse(_armed_kind)
			_armed_aim = aim_point
			_armed_influence = _air_influence(input)
		else:












			if is_bot and TeamBot.DEBUG_AI and ball != null:
				print("[CLR %s] release-whiff (refunded) y=%.2f flat=%.2f" % [name, 
					ball.global_position.y, 
					Vector2(ball.global_position.x - global_position.x, 
					ball.global_position.z - global_position.z).length()])
			_intent_used_strike = -1




		if was_spike_swing and _receive_window <= 0.0:
			_whiff_swing(swing_charge)
	contact_state = ContactState.RECOVER







func _approach_factor() -> float:
	var t: = clampf(approach_speed() / FEEL.approach_ref_speed, 0.0, 1.0)
	if ball != null and ball.serve_assist:


		var ts: = clampf((approach_speed() - FEEL.serve_approach_min)
			/ (FEEL.serve_approach_full - FEEL.serve_approach_min), 0.0, 1.0)
		ts = pow(ts, FEEL.serve_approach_curve)
		return lerpf(FEEL.serve_approach_floor, FEEL.serve_approach_ceiling, ts)
	return lerpf(FEEL.approach_power_floor, FEEL.approach_power_ceiling, t)





func approach_speed() -> float:
	var to_aim: = aim_point - global_position
	to_aim.y = 0.0
	if to_aim.length_squared() < 0.0001:
		return 0.0
	return maxf(Vector3(velocity.x, 0.0, velocity.z).dot(to_aim.normalized()), 0.0)

func _do_touch(kind: TouchKind, power: float, finesse: bool, 
		influence: Vector2, quick: bool) -> void :
	_local_touch_msec = Time.get_ticks_msec()
	var _dbg_kind0: = kind
	var _dbg_locked: = ball != null and ball.spike_locked()





	if kind == TouchKind.SET or _dump_rise > 0.0:
		influence = Vector2.ZERO








	if not grounded() and not _armed_set_button and _dump_rise < 0.0 and ball != null\
	and (kind == TouchKind.DUMP or kind == TouchKind.SPIKE):
		kind = TouchKind.SPIKE if ball.global_position.y >= FEEL.spike_min_ball_height\
		else TouchKind.DUMP



	if ball != null and ball.spike_locked():







		if not grounded():
			return


		if kind == TouchKind.SPIKE or kind == TouchKind.DUMP or kind == TouchKind.SET:
			kind = TouchKind.BUMP
			power = _receive_quality()
			finesse = true



	var incoming: = ball.vel.length() if ball != null else 0.0
	var incoming_vel: = ball.vel if ball != null else Vector3.ZERO






	var was_spike: = kind == TouchKind.SPIKE
	_kick_foot = 0
	_kick_was_spike = false
	_receive_side = 0
	_set_low = false
	_dive_receive = false
	var spike_flat: = 0.0
	if was_spike:
		spike_flat = Vector2(aim_point.x - global_position.x, aim_point.z - global_position.z).length()




	_spike_light = kind == TouchKind.DUMP\
	or (was_spike and (power < FEEL.spike_light_power\
	or spike_flat < FEEL.spike_light_dist\
	or (influence.y < - FEEL.float_tilt and power < FEEL.spike_charge_cap)))
	var kick_clear: = false




	if ball != null and not grounded() and was_spike\
	and ball.global_position.y - global_position.y < FEEL.kick_height:
		kind = TouchKind.BUMP
		power = FEEL.kick_power
		finesse = true
		kick_clear = true

	if DEBUG_HIT and not is_bot and ball != null:
		var across: = signf(aim_point.z) != signf(global_position.z)
		var hl: = "[HIT] kind0=%d final_kind=%d was_spike=%s kick=%s spike_locked=%s | ball_y=%.2f feet_y=%.2f d=%.2f grounded=%s across=%s power=%.2f" % [
			_dbg_kind0, kind, str(was_spike), str(kick_clear), str(_dbg_locked), 
			ball.global_position.y, global_position.y, 
			ball.global_position.y - global_position.y, 
			str(grounded()), str(across), power]
		print(hl)
		if _dbg_hit_file == null:
			_dbg_hit_file = FileAccess.open("user://human_hit.log", FileAccess.WRITE)
		if _dbg_hit_file != null:
			_dbg_hit_file.store_line(hl)
			_dbg_hit_file.flush()









	var will_hit: = ball != null\
	and (sim_authority or ( not net_puppet and not ball.net_puppet))
	if kind == TouchKind.SPIKE and GameConfig.spike_hitstop and not finesse\
	and will_hit:
		ball._pending_hitstop = maxf(
			lerpf(0.05, 0.12, clampf(power, 0.0, 1.0)), 
			0.11 if last_perfect else 0.0)




	if will_hit:
		ball._pending_momentum = break_momentum(approach_speed())\
		if kind == TouchKind.SPIKE else 0.0

		ball._pending_tip_rise = _dump_rise if kind == TouchKind.DUMP else -1.0







	var slipped: = sim_authority and sweat > 0.0 and kind != TouchKind.SPIKE\
	and randf() < sweat * FEEL.slip_chance_max\
	* lerpf(FEEL.slip_planted_factor, 1.0, _sloppiness()) * _slip_factor()




	var float_in: = ball.float_serve and kind != TouchKind.SPIKE
	var speed_frac: = Vector2(velocity.x, velocity.z).length() / FEEL.move_speed
	var float_flub: = sim_authority and float_in and speed_frac >= FEEL.float_slip_speed
	var target: = aim_point
	if sim_authority and float_in and not float_flub and speed_frac > FEEL.float_shake_speed:
		var t: = clampf(inverse_lerp(FEEL.float_shake_speed, FEEL.float_slip_speed, speed_frac), 0.0, 1.0)
		var to_aim: = aim_point - global_position
		to_aim.y = 0.0
		var rot: = randf_range(-1.0, 1.0) * FEEL.float_shake_angle * t
		var stretch: = 1.0 + randf_range(-1.0, 1.0) * FEEL.float_shake_dist * t
		target = global_position + to_aim.rotated(Vector3.UP, rot) * stretch
		target.y = aim_point.y
		power *= 1.0 - 0.5 * t
		show_float_text("shaky", Color(0.95, 0.85, 0.5), false)
		if not slipped:
			show_combo(0, true)


	var float_seed: = 0
	if kind == TouchKind.SPIKE and ball.serve_assist and serve_style.size() > 0\
	and String(serve_style.get("type", "")) == "float":
		float_seed = Ball.float_seed_for(int(serve_style.get("pattern", 7)),
			float(serve_style.get("charge", 1.0)))
	elif kind == TouchKind.SPIKE and ball.serve_assist and _float_serve_intent(influence):



		var charge: = 1.0 if is_bot else (0.0 if finesse else clampf(inverse_lerp(
			FEEL.float_shake_from, FEEL.float_power_cap, power), 0.0, 1.0))
		float_seed = Ball.float_seed_for(
			(randi() % 999983 + 1) if sim_authority else 7, charge)















	var serve_hit: = ball != null and ball.serve_assist and not finesse\
	and kind != TouchKind.BUMP
	var combo_tier: = 0
	if serve_hit:
		combo_tier = 3
		power *= COMBO_SPIKE_BONUS
	elif kind == TouchKind.SPIKE and not finesse:
		combo_tier = clampi(team_touches + 1, 1, 3)
		if combo_tier == 3:
			power *= COMBO_SPIKE_BONUS
	if ball != null:
		ball.combo_tier = combo_tier





		ball.dig_weight = dig_weight_of(kind, incoming_vel)








	if kind == TouchKind.SPIKE and not finesse and (power > 0.8 or combo_tier == 3):
		_voice("v_dive")
	elif ball != null and is_fast_dig(kind, ball.dig_weight):


		_voice(FAST_DIG_VOICE)
	var applied: = false
	if slipped or float_flub:
		ball.strike_source = self
		_slip_grace = randf_range(3.0, 8.0)
		show_float_text("shanked!" if float_flub else "slip!", Color(0.6, 0.8, 1.0), true)
		ball.shank()
		show_combo(0, true)
		applied = true
	elif sim_authority:














		var clears: = kick_clear or is_bot or Rules.touch_clears_net(kind)
		ball.strike_source = self
		ball.hit(target, kind, power, finesse, influence, clears, quick, float_seed, 
			kind == TouchKind.SET and set_is_tower(aim_point))
		applied = true
		if ball.serve_assist and serve_style.size() > 0:
			if String(serve_style.get("type", "")) == "spin":
				ball.curve = float(serve_style.get("curve", 0.0))
			serve_style = {}
	elif not net_puppet and not ball.net_puppet:








		var clears2: = kick_clear or Rules.touch_clears_net(kind)
		ball.strike_source = self
		ball.hit(target, kind, power, finesse, influence, clears2, quick, float_seed, 
			kind == TouchKind.SET and set_is_tower(aim_point))
		applied = true
		if ball.serve_assist and serve_style.size() > 0:
			if String(serve_style.get("type", "")) == "spin":
				ball.curve = float(serve_style.get("curve", 0.0))
			serve_style = {}
	elif not net_puppet:



		touch_attempted.emit()










		if kind == TouchKind.SPIKE and GameConfig.spike_hitstop and not finesse:
			_hitstop_hold = maxf(_hitstop_hold, maxf(
				lerpf(0.05, 0.12, clampf(power, 0.0, 1.0)), 
				0.11 if last_perfect else 0.0))
	_touch_lock = FEEL.touch_lock
	last_touch_power = power
	last_touch = kind

	last_touch_charge = _release_charge
	_release_charge = 0.0







	if applied:
		touch_seq += 1







		if kind == TouchKind.SPIKE and ball.hitstop_left > 0.0:
			_hitstop_hold = ball.hitstop_left





	settle()
	if TeamBot.DEBUG_SET and kind == TouchKind.SET:
		var st: = get_stack()
		var caller: = "?"
		if st.size() >= 2:
			caller = "%s:%d" % [str(st[1].get("function", "?")), int(st[1].get("line", 0))]
		print("[SETTOUCH %s] quick=%s power=%.2f aim=(%.1f,%.1f) via=%s" % [
			name, str(quick), power, aim_point.x, aim_point.z, caller])
	last_touch_quick = quick
	_receive_window = 0.0
	_armed_kind = TouchKind.NONE




	_armed_set_button = false
	_clear_contact_intent()
	if not grounded():

		_air_spent = true
	if sim_authority:
		touched.emit(kind)






	if kind == TouchKind.BUMP:
		var weight: = clampf(incoming / FEEL.receive_plant_speed, 0.0, 1.0)
		last_receive_weight = weight
		var plant: = 1.0 - FEEL.receive_plant * weight
		velocity.x *= plant
		velocity.z *= plant
		_land_pulse = maxf(_land_pulse, weight)



		var anim_weight: = clampf(incoming / FEEL.receive_anim_speed, 0.0, 1.0)
		_receive_pose = lerpf(FEEL.receive_pose_min, FEEL.receive_pose_max, anim_weight)









		if ball != null:
			var lc: = (ball.global_position - global_position)\
			.rotated(Vector3.UP, - visual.rotation.y)
			var lv: = incoming_vel.rotated(Vector3.UP, - visual.rotation.y)
			var from_behind: = incoming > 0.5 and lv.z > 0.35 * incoming
			if lc.z < - FEEL.receive_back_z or from_behind:
				_receive_side = 3
			elif absf(lc.x) > FEEL.receive_side_x:
				_receive_side = 1 if lc.x < 0.0 else 2
	elif kind == TouchKind.SET:







		_receive_pose = FEEL.set_pose




		if ball != null and grounded()\
		and ball.global_position.y - global_position.y < FEEL.set_low_height:
			_set_low = true
			var fwd: = Vector3(sin(visual.rotation.y), 0.0, cos(visual.rotation.y))
			knock( - fwd * FEEL.set_low_push + Vector3.UP * FEEL.set_low_lift, 
				FEEL.set_low_knock)






		elif ball != null and back_set_dir(visual.rotation.y, ball.vel):
			_receive_side = 3
	elif kind == TouchKind.DUMP and _dump_rise > 0.0:





		_receive_pose = FEEL.set_pose
		_receive_side = 3 if ball != null and back_set_dir(visual.rotation.y, ball.vel) else 1
	elif kind == TouchKind.SPIKE or kind == TouchKind.DUMP:





		_receive_pose = FEEL.spike_air_hold\
		+ (ball.hitstop_left if ball != null else 0.0)





	var pose_kind: = TouchKind.SET if set_dump_touch() else kind
	if POSE_FOLLOW.has(pose_kind) and not (pose_kind == TouchKind.SPIKE\
	and _model != null and _model.hands_animated()):
		if character != null and character.left_handed\
		and (pose_kind == TouchKind.SPIKE or pose_kind == TouchKind.DUMP):


			var p0: Vector3 = POSE_FOLLOW[pose_kind][0]
			var p1: Vector3 = POSE_FOLLOW[pose_kind][1]
			hand_l.position = Vector3( - p1.x, p1.y, p1.z)
			hand_r.position = Vector3( - p0.x, p0.y, p0.z)
		else:
			hand_l.position = POSE_FOLLOW[pose_kind][0]
			hand_r.position = POSE_FOLLOW[pose_kind][1]

	_recover_left = FEEL.recover_time
	if pose_kind == TouchKind.SPIKE or pose_kind == TouchKind.DUMP:
		_recover_left = SPIKE_RECOVER
	if slipped:
		_recover_left = 0.85




	if not is_bot and kind == TouchKind.BUMP and grounded() and _contact_button_held:
		_receive_hold_spent = true
	contact_state = ContactState.RECOVER
	_kick_recoil(pose_kind)



func set_dump_touch() -> bool:
	return last_touch == TouchKind.DUMP and _receive_side != 0

func _kick_recoil(kind: int) -> void :




	_recoil_tick = not _recoil_tick
	_arm_reach(kind)
	if not RECOIL_DIR.has(kind):
		return
	_recoil_vel = FEEL.recoil_kick
	_recoil_kind = kind

















const REACH_MIN: = 0.3
const REACH_MAX: = 1.7
const REACH_IN: = 0.06
const REACH_HOLD: = 0.06
const REACH_BACK: = 0.2
const REACH_SNAP: = 0.08
const REACH_IN_STEPS: = 4.0
var _reach_froze: = false
var _reach_t: = -1.0
var _reach_hand_l: = false
var _reach_hand_r: = false
var _reach_on_l: = Vector3.ZERO
var _reach_on_r: = Vector3.ZERO

var _reach_rel: = Vector3.ZERO
var _reach_kind: = 0





func _arm_reach(kind: int) -> void :
	if ball == null or far_lod or visual == null or not is_inside_tree() or kind == TouchKind.NONE or kind == TouchKind.CAROM or _kick_foot != 0:
		_reach_t = -1.0
		return
	var lefty: = character != null and character.left_handed
	if kind == TouchKind.SPIKE or kind == TouchKind.DUMP:
		_reach_kind = 2 if lefty else 1
	else:
		_reach_kind = 3
	_reach_rel = ball.global_position - global_position
	_reach_hand_l = false
	_reach_hand_r = false
	_reach_t = -2.0



func _measure_reach() -> bool:




	if (last_touch == TouchKind.SET or set_dump_touch()) and (_receive_side == 3\
	or (_puppet_action == "set_back" and _puppet_action_t > 0.0)):
		return false
	var target: = visual.to_local(global_position + _reach_rel)
	if _reach_kind == 3:
		if minf(hand_l.position.distance_to(target), hand_r.position.distance_to(target)) < REACH_MIN:
			return false
		_reach_hand_l = true
		_reach_hand_r = true
	else:
		var hp: = hand_l.position if _reach_kind == 1 else hand_r.position
		if hp.distance_to(target) < REACH_MIN:
			return false
		_reach_hand_l = _reach_kind == 1
		_reach_hand_r = _reach_kind == 2
	return true

const REACH_SIDE: = Vector3(0.12, 0.0, 0.0)



func _reach_gap(left: bool) -> Vector3:
	var target: = visual.to_local(global_position + _reach_rel)
	if _reach_kind == 3:
		target += - REACH_SIDE if left else REACH_SIDE
	var hp: = hand_l.position if left else hand_r.position
	return (target - hp).limit_length(REACH_MAX)



func _clear_reach() -> void :
	hand_l.position -= _reach_on_l
	hand_r.position -= _reach_on_r
	_reach_on_l = Vector3.ZERO
	_reach_on_r = Vector3.ZERO








func _apply_reach(delta: float, frozen: bool) -> void :
	if _reach_t == -2.0:
		_reach_t = 0.0 if _measure_reach() else -1.0
		_reach_froze = false
	if _reach_t < 0.0:
		return






	var slow: = Engine.time_scale < 0.9
	if frozen or slow:
		_reach_froze = true
		if delta > 0.0:
			_reach_t = minf(_reach_t + REACH_IN / REACH_IN_STEPS, REACH_IN)
	elif delta > 0.0:
		if _reach_froze and _reach_t < REACH_IN + REACH_HOLD:
			_reach_t = REACH_IN + REACH_HOLD
		_reach_t += delta
	var back: = REACH_SNAP if _reach_froze else REACH_BACK
	var k: = 0.0
	if _reach_t < REACH_IN:
		k = smoothstep(0.0, REACH_IN, _reach_t)
	elif _reach_t < REACH_IN + REACH_HOLD:
		k = 1.0
	else:
		k = 1.0 - smoothstep(0.0, back, _reach_t - REACH_IN - REACH_HOLD)
		if k <= 0.0:
			_reach_t = -1.0
			return
	_reach_on_l = _reach_gap(true) * k if _reach_hand_l else Vector3.ZERO
	_reach_on_r = _reach_gap(false) * k if _reach_hand_r else Vector3.ZERO
	hand_l.position += _reach_on_l
	hand_r.position += _reach_on_r








func carom_hit(power: float) -> void :
	last_touch_power = power
	last_touch = TouchKind.CAROM
	last_touch_quick = false
	show_float_text("missed", CAROM_COLOR, true, 1.0, true, true)
	if sim_authority:
		touched.emit(TouchKind.CAROM)






func body_hit(power: float, blocking: = false) -> void :
	last_touch_power = power
	last_touch = TouchKind.CAROM
	last_touch_quick = false
	if not blocking:
		show_float_text("missed", CAROM_COLOR, true, 1.0, true, true)
	if sim_authority:
		touched.emit(TouchKind.CAROM)











static var HELD_CAROM_SAVE: = true
static var BOT_QUIET_LETGO: = true
func held_receive_save() -> bool:
	if not HELD_CAROM_SAVE or not sim_authority or net_puppet or ball == null\
	or ball.frozen or not contact_enabled or knocked() or not is_on_floor():
		return false


	if jump_charging_on_floor():
		return false
	var holding: = (contact_state == ContactState.WINDUP and _contact_button_held)\
	or (_armed_kind == TouchKind.BUMP and _armed_from_ground)
	if not holding:
		return false
	var seq: = ball.strike_seq
	_clear_contact_intent()
	_do_touch(TouchKind.BUMP, _receive_quality(), false, Vector2.ZERO, false)
	if ball.strike_seq == seq:
		return false
	contact_state = ContactState.IDLE
	hold_time = 0.0
	_hold_real = 0.0
	_early_contact_from_ground = false
	return true

func _airborne_attack_armed() -> bool:








	return not is_bot and not is_on_floor() and not _air_spent\
	and (_armed_kind == TouchKind.SPIKE or _armed_kind == TouchKind.DUMP)







func _airborne_attack_unreachable() -> bool:
	if ball == null or ball.frozen or grounded():
		return false
	var chest: = chest_position()
	var body_v: = velocity
	var ball_p: = ball.global_position
	var ball_v: = ball.vel


	var lost_reach: = FEEL.reach + (FEEL.spike_air_reach_bonus if not is_bot else 0.0)
	for i in range(FEEL.contact_queue_steps + 1):
		var t: = FEEL.air_lost_horizon * float(i) / float(FEEL.contact_queue_steps)
		var chest_at: = chest + body_v * t - Vector3(0.0, 0.5 * FEEL.gravity * t * t, 0.0)
		var ball_at: = ball_p + ball_v * t\
		- Vector3(0.0, 0.5 * Ball.PHYS.gravity * t * t, 0.0)
		if chest_at.distance_to(ball_at) <= lost_reach:
			return false
	return true

func _try_armed_receive() -> void :








	if TeamBot.DEBUG_AI and ball != null and ball.global_position.y < 1.2\
	and _armed_kind == TouchKind.BUMP and Engine.get_physics_frames() % 4 == 0:
		print("[TAR %s] y=%.2f d=%.2f en=%s frz=%s bar=%s tl=%.2f auth=%s pup=%s kn=%s held=%s afg=%s gr=%s floor=%s spent=%s reach=%s wfr=%s stamp=%d/%d pri=%s win=%.2f cs=%d" % [
			name, ball.global_position.y, 
			ball.global_position.distance_to(chest_position()), 
			str(contact_enabled), str(ball.frozen), str(contact_barred()), _touch_lock, 
			str(sim_authority), str(net_puppet), str(knocked()), 
			str(_contact_button_held), str(_armed_from_ground), str(grounded()), 
			str(is_on_floor()), str(_air_spent), str(_swing_reach_check()), 
			str(_armed_wait_for_release), _intent_used_strike, ball.strike_seq, 
			str(bool(contact_priority_check.call(self)) if contact_priority_check.is_valid() else "n/a"), 
			_receive_window, contact_state])
	if not contact_enabled or ball == null or ball.frozen\
	or contact_barred() or _touch_lock > 0.0:
		return
	if not sim_authority and net_puppet:
		return
	if knocked():
		return







	if not is_bot and _armed_kind in [TouchKind.SPIKE, TouchKind.DUMP]\
	and not _contact_button_held and not _armed_from_ground\
	and (is_on_floor() or _airborne_attack_unreachable()):
		_queued_whiff()
		return





	if is_on_floor() and (_armed_kind == TouchKind.SPIKE or _armed_kind == TouchKind.DUMP):








		if not is_bot:
			_intent_used_strike = -1
		elif TeamBot.DEBUG_AI and ball != null:
			print("[CLR %s] grounded-spike-spent kind=%d y=%.2f flat=%.2f" % [name, _armed_kind, 
				ball.global_position.y, Vector2(ball.global_position.x - global_position.x, 
				ball.global_position.z - global_position.z).length()])
		_clear_contact_intent()
		return




	if _contact_button_held and _armed_kind != TouchKind.BUMP:
		return
	if _armed_from_ground and not grounded():
		_clear_contact_intent()
		return

	if not is_on_floor() and _air_spent:
		return
	var kind: = _armed_kind
	if kind == TouchKind.NONE or kind == TouchKind.BLOCK:
		return


	if kind == TouchKind.BUMP and jump_charging_on_floor():
		return




	if (kind == TouchKind.SPIKE or kind == TouchKind.DUMP) and ball_on_far_side():
		return
	if not _swing_reach_check():
		return
	if _armed_wait_for_release:
		return








	if is_on_floor() and not is_bot and kind == TouchKind.BUMP and ball != null\
	and signf(aim_point.z) != signf(global_position.z)\
	and ball.global_position.y > FEEL.bump_max_ball_height\
	and Time.get_ticks_usec() - _intent_queued_at_usec < JUMP_SPIKE_GRACE_US:
		return








	if _intent_used_strike != ball.strike_seq:
		_clear_contact_intent()










		if contact_state == ContactState.WINDUP:
			_early_contact_from_ground = grounded()
		return
	if contact_priority_check.is_valid()\
	and not bool(contact_priority_check.call(self)):
		return
	last_perfect = false
	var live_aim: = aim_point









	var dump_rise: = -1.0
	if is_bot:
		aim_point = _armed_aim
	elif kind == TouchKind.SET and set_dump_intent(_armed_dump or _dump_push_left > 0.0):




		kind = TouchKind.DUMP
		aim_point = set_dump_target(live_aim)
		dump_rise = set_dump_rise(_armed_power)
	elif kind == TouchKind.SET:
		aim_point = set_target_point(live_aim, _armed_quick)

	var p: = _armed_power
	if kind == TouchKind.BUMP:
		p = _receive_quality()
	elif kind == TouchKind.SPIKE:




		p = minf(_armed_power, SPIKE_POWER_MAX)
		if not is_bot:
			p *= _approach_factor()






	var q: = _armed_quick


	if is_bot and TeamBot.QUICK_TO_AIRBORNE and kind == TouchKind.SET and not q\
	and quick_check.is_valid() and bool(quick_check.call(aim_point, self)):
		q = true
		aim_point = set_target_point(aim_point, true)
	if TeamBot.DEBUG_AI and is_bot:
		print("[TAR %s] FIRE kind=%d y=%.2f" % [name, kind, ball.global_position.y])
	_dump_rise = dump_rise
	_do_touch(kind, p, _armed_finesse, _armed_influence, q)
	_dump_rise = -1.0
	aim_point = live_aim






func _queued_whiff() -> void :
	if not _queue_swung:
		swung.emit(TouchKind.SPIKE)
	_whiff_swing(_armed_power)
	if not is_bot:
		_intent_used_strike = -1
	_clear_contact_intent()

func _clear_contact_intent() -> void :
	_receive_window = 0.0
	_queue_reach_seen = false
	_armed_kind = TouchKind.NONE
	_armed_from_ground = false
	_armed_wait_for_release = false
	_queue_swung = false
	_armed_aim = Vector3.ZERO
	_armed_influence = Vector2.ZERO
	_armed_quick = false
	_armed_dump = false
	_queued_fill = 0.0
	_intent_queued_at_usec = 0






	if _armed_set_button:
		_armed_set_button = false
		_intent_used_strike = -1

func contact_opportunity_kind() -> TouchKind:
	if not contact_enabled or ball == null or ball.frozen or contact_barred()\
	or knocked() or contact_state == ContactState.RECOVER\
	or contact_state == ContactState.BLOCK\
	or ( not grounded() and _air_spent):
		return TouchKind.NONE
	if _intent_used_strike == ball.strike_seq:
		return TouchKind.NONE


	if ball_theirs():
		return TouchKind.NONE


	if not ball_on_far_side() and _swing_reach_check():
		return resolved_touch()







	var spot: Variant = _receive_spot()
	if spot != null:
		var s: Vector3 = spot
		if s.z * float(team_side) >= -0.1 and _in_landing_zone():





			return resolved_touch_at(ball.global_position, true)








	var human_overpass: = not is_bot
	if not grounded() and (human_overpass or not ball_on_far_side()):
		var chest: = chest_position()
		var prev_ball: = ball.global_position
		for i in range(1, FEEL.contact_queue_steps + 1):
			var t: = FEEL.air_queue_horizon * float(i) / float(FEEL.contact_queue_steps)
			var ball_at: = ball.global_position + ball.vel * t\
			+ Vector3(0.0, -0.5 * Ball.PHYS.gravity * t * t, 0.0)
			if human_overpass and ball_at.z * float(team_side) < 0.0:


				prev_ball = ball_at
				continue
			var k: = resolved_touch_at(ball_at)




			var assisted: = k == TouchKind.SPIKE and not is_bot
			var reach: = FEEL.reach + FEEL.spike_air_reach_bonus if assisted else FEEL.reach
			if k != TouchKind.NONE\
			and _segment_distance(prev_ball, ball_at, chest, chest) <= reach:
				return k
			prev_ball = ball_at
	return TouchKind.NONE




func _in_landing_zone() -> bool:
	var spot: Variant = _receive_spot()
	if spot == null:
		return false
	var s: Vector3 = spot
	var here: = Vector2(global_position.x, global_position.z)
	return here.distance_to(Vector2(s.x, s.z)) <= FEEL.landing_zone_radius



















static var BOT_QUEUE_FREEZE: = true
func _queued_ball_incoming() -> bool:
	if (is_bot and not BOT_QUEUE_FREEZE) or ball == null or ball.frozen or not grounded():
		return false






	if ball.global_position.y < 0.6 and ball.vel.length() < 2.0:
		return false
	if _armed_kind == TouchKind.NONE or _armed_kind == TouchKind.BLOCK:
		return false
	if not ball.predicted_landing_valid:
		return false
	if ball.predicted_landing.z * float(team_side) < -0.1:
		return false
	return _in_landing_zone()



func queued_ball_abandoned() -> bool:
	if ball == null or ball.frozen:
		return false






	if not grounded()\
	and (_armed_kind == TouchKind.SPIKE or _armed_kind == TouchKind.DUMP)\
	and _airborne_attack_unreachable():
		return true




	if not _queue_reach_seen:
		return false



	if not grounded():
		return chest_position().distance_to(ball.global_position)\
		> FEEL.reach + FEEL.airborne_lost_margin
	var spot: Variant = _receive_spot()
	if spot == null:
		return false
	var s: Vector3 = spot
	var here: = Vector2(global_position.x, global_position.z)
	return here.distance_to(Vector2(s.x, s.z)) > FEEL.queue_lost_dist





func _receive_spot() -> Variant:
	if ball == null or ball.frozen:
		return null
	if ball.predicted_landing_valid:
		return ball.predicted_landing
	return ball.predict_point(FEEL.chest_height)

func contact_opportunity_available() -> bool:
	return contact_opportunity_kind() != TouchKind.NONE

func contact_intent_queued() -> bool:
	return _receive_window > 0.0 and _armed_kind != TouchKind.NONE






func attacking_in_air() -> bool:
	return not grounded() and (contact_state == ContactState.WINDUP or contact_intent_queued())





func is_charging() -> bool:
	return contact_state == ContactState.WINDUP or _jump_charge > 0.02











func pending_set_quick() -> bool:
	if _set_windup and hold_power() >= FEEL.set_quick_charge:
		return true
	return _armed_kind == TouchKind.SET and _armed_quick and contact_intent_queued()

func charging_set() -> bool:
	return _set_windup

func queued_contact_eligible() -> bool:
	if not contact_intent_queued() or not contact_enabled or ball == null\
	or ball.frozen or contact_barred() or _touch_lock > 0.0 or knocked():
		return false
	if _armed_from_ground and not grounded():
		return false



	if is_on_floor() and (_armed_kind == TouchKind.SPIKE or _armed_kind == TouchKind.DUMP):
		return false
	if not grounded() and _air_spent:
		return false
	return _swing_reach_check()

func queued_contact_distance() -> float:
	if ball == null:
		return INF
	return ball.global_position.distance_to(chest_position())

func queued_contact_time() -> int:
	return _intent_queued_at_usec




func queued_contact_kind() -> TouchKind:
	return _armed_kind

func _try_dive_receive() -> void :


	if not contact_enabled or ball == null or ball.frozen\
	or contact_barred() or _touch_lock > 0.0:
		return
	if not sim_authority and net_puppet:
		return
	var kind: = resolved_touch()
	if kind != TouchKind.BUMP and kind != TouchKind.SET:
		return
	if not _swing_reach_check():
		return
	_dive_touched = true
	last_perfect = false






	var dive_target: = aim_point
	if sim_authority and dive_aim_error > 0.0:
		dive_target += Vector3(randf_range(-1.0, 1.0), 0.0, 
			randf_range(-1.0, 1.0)) * dive_aim_error

		if team_side != 0:
			dive_target.z = float(team_side) * clampf(dive_target.z * float(team_side), 
				0.8, ball.court_half_l if ball != null else 8.0)
	var live_aim: = aim_point
	aim_point = dive_target


	_do_touch(TouchKind.BUMP, _receive_quality(), true, Vector2.ZERO, false)
	aim_point = live_aim



	_dive_receive = true

func _slip_factor() -> float:


	return 0.15 if _slip_grace > 0.0 else 1.0





func _sloppiness() -> float:
	var speed_frac: = clampf(
		Vector2(velocity.x, velocity.z).length() / FEEL.move_speed, 0.0, 1.0)
	return maxf(speed_frac, clampf(_restless / FEEL.restless_full, 0.0, 1.0))





func ball_in_reach() -> bool:
	if not contact_enabled or ball == null or ball.frozen:
		return false






	if not can_swing_now():
		return false
	return _swing_reach_check()




func can_swing_now() -> bool:
	if _knock_time > 0.0 or getting_up():
		return false


	if _receive_window > 0.0:
		return true

	if contact_state == ContactState.RECOVER or contact_state == ContactState.BLOCK:
		return false
	if not is_on_floor() and _air_spent:
		return false
	return resolved_touch() != TouchKind.NONE







func _receive_quality() -> float:
	if ball == null:
		return 0.7







	var q: = 1.0







	q -= 0.45 * clampf(Vector2(velocity.x, velocity.z).length() / FEEL.move_speed, 0.0, 1.0)


	var heat: = (ball.vel.length() - FEEL.receive_plant_speed * 0.5) / FEEL.receive_plant_speed
	var heat_pen: = 0.35 * clampf(heat, 0.0, 1.0)



	if _strafe_held and grounded():
		heat_pen *= FEEL.strafe_receive_heat
	q -= heat_pen

	if _dive_time > 0.0 or knocked():
		q = minf(q, 0.35)
	return clampf(q, 0.0, 1.0)

func _swing_reach_check() -> bool:











	if not sim_authority and ball != null and ball.vel.y < 0.0\
	and ball.global_position.y < Ball.PHYS.radius + 0.12:
		return false



	if ball_position_in_reach(ball.global_position):
		return true
	return _ball_sweep_valid\
	and ball_path_in_reach(_ball_sweep_from, ball.global_position)



func ball_position_in_reach(ball_pos: Vector3) -> bool:
	return ball_path_in_reach(ball_pos, ball_pos)











func _spike_magnet_active(ball_height: float) -> bool:


	return not is_bot\
	and ball_height >= FEEL.spike_min_ball_height\
	and not _set_windup and not _armed_set_button



func _aim_across_net() -> bool:
	return signf(aim_point.z) != signf(global_position.z)





func _windup_pose_kind() -> TouchKind:


	if not net_puppet:
		if not grounded() and _aim_across_net() and ball_on_far_side():
			return TouchKind.SPIKE
		if _armed_kind == TouchKind.SPIKE:
			return TouchKind.SPIKE
	return resolved_touch()






func _jump_set_active() -> bool:
	return not is_bot and not grounded() and ball != null\
	and not ball_on_far_side() and (_set_windup or _armed_set_button)







func _drive_magnet_lean() -> void :
	if ball == null or ball.frozen or grounded():
		return
	if not _spike_magnet_active(ball.global_position.y):
		return
	var charging_spike: = contact_state == ContactState.WINDUP\
	and _windup_pose_kind() == TouchKind.SPIKE
	if not charging_spike:
		return
	var chest: = chest_position()
	var reach: = FEEL.reach + FEEL.spike_air_reach_bonus
	var d: = chest.distance_to(ball.global_position)
	if d > reach:
		return

	ball.magnet_lean(chest, clampf(1.0 - d / reach, 0.2, 1.0))

func ball_path_in_reach(from: Vector3, to: Vector3) -> bool:
	if from.distance_to(to) > FEEL.receive_sweep_max:
		return false
	var chest: = chest_position()
	if _dive_time > 0.0:
		var dive_tip: = chest + _dive_dir * FEEL.dive_body_length
		return _segment_distance(from, to, chest, dive_tip) <= FEEL.dive_reach



	var reach: = FEEL.reach
	if not grounded() and _spike_magnet_active(minf(from.y, to.y)):
		reach += FEEL.spike_air_reach_bonus
	if _segment_distance(from, to, chest, chest) <= reach:
		return true




	if not grounded() and _jump_set_active():
		var below: = chest + Vector3(0.0, - FEEL.jump_set_down_reach, 0.0)
		if _segment_distance(from, to, chest, below) <= FEEL.reach:
			return true
	if not grounded():
		return false
	var low_limit: = FEEL.bump_max_ball_height + 0.4
	if minf(from.y, to.y) > low_limit:
		return false
	var forward: = aim_point - global_position
	forward.y = 0.0
	if forward.length_squared() < 0.01:
		forward = visual.global_basis.z
		forward.y = 0.0
	forward = forward.normalized()
	var forearms: = chest + forward * FEEL.receive_forward
	return _segment_distance(from, to, chest, forearms)\
	<= FEEL.reach + FEEL.receive_reach_bonus

static func _segment_distance(a0: Vector3, a1: Vector3, 
		b0: Vector3, b1: Vector3) -> float:
	if a0.is_equal_approx(a1) and b0.is_equal_approx(b1):
		return a0.distance_to(b0)
	if a0.is_equal_approx(a1):
		return a0.distance_to(Geometry3D.get_closest_point_to_segment(a0, b0, b1))
	if b0.is_equal_approx(b1):
		return b0.distance_to(Geometry3D.get_closest_point_to_segment(b0, a0, a1))
	var closest: = Geometry3D.get_closest_points_between_segments(a0, a1, b0, b1)
	if closest.size() < 2:
		return a0.distance_to(b0)
	return closest[0].distance_to(closest[1])

func _capture_ball_step() -> void :
	_ball_sweep_valid = false
	if ball == null or ball.frozen:




		_clear_contact_intent()
		_intent_used_strike = -1
		_ball_seen_valid = false
		return
	var here: = ball.global_position
	if _ball_seen_valid:
		if _ball_seen_pos.distance_to(here) <= FEEL.receive_sweep_max:
			_ball_sweep_from = _ball_seen_pos
			_ball_sweep_valid = true
		else:





			if not contact_intent_queued():
				_clear_contact_intent()
				_intent_used_strike = -1
	_ball_seen_pos = here
	_ball_seen_valid = true



func float_receive_t() -> float:
	if ball == null or not ball.float_serve:
		return 0.0
	var speed_frac: = Vector2(velocity.x, velocity.z).length() / FEEL.move_speed
	return clampf(inverse_lerp(FEEL.float_shake_speed, FEEL.float_slip_speed, speed_frac), 0.0, 1.0)


func _float_serve_intent(influence: Vector2) -> bool:
	return not is_on_floor() and ball != null and ball.serve_assist\
	and influence.y < - FEEL.float_tilt

func _air_influence(input: PlayerInput) -> Vector2:


	if is_on_floor():
		return Vector2.ZERO
	if is_bot:


		var fwd: = Vector3(0.0, 0.0, - float(team_side)) if team_side != 0 else Vector3(0.0, 0.0, - signf(global_position.z + 0.0001))
		var right: = fwd.cross(Vector3.UP)
		var world_move: = Vector3(input.move.x, 0.0, input.move.y)
		return Vector2(world_move.dot(right), world_move.dot(fwd))








	return Vector2(input.move_raw.x, - input.move_raw.y)




func settle(seconds: = -1.0) -> void :

	if seconds < 0.0:
		seconds = FEEL.settle_time
	_settle_time = maxf(_settle_time, seconds)




func clear_settle() -> void :
	_settle_time = 0.0
	_land_time = 0.0

var _sprint_lines: SprintLines = null
var _body_loops: BodyLoops = null

func _pose(delta: float) -> void :
	_clear_reach()


	_tick_flash(delta)


	if _sprint_lines == null and sprinting:
		_sprint_lines = SprintLines.new()
		add_child(_sprint_lines)
	if _sprint_lines != null:
		_sprint_lines.tick(delta, self)

	if _body_loops == null and (sprinting or stamina_locked):
		_body_loops = BodyLoops.new()
		add_child(_body_loops)
	if _body_loops != null:
		_body_loops.tick(delta, self)



	var planar: = Vector2(velocity.x, velocity.z).length()




	air_trail.set_active( not far_lod and not grounded() and _knock_time <= 0.0\
	and _dive_time <= 0.0)




	var airborne: = not grounded()
	if airborne and not _was_airborne:



		_air_boost = clampf(
			(velocity.y - FEEL.jump_min_velocity)
				/ maxf(FEEL.jump_max_velocity - FEEL.jump_min_velocity, 0.01), 
			0.0, 1.4)
		air_trail.set_boost(_air_boost)









		if velocity.y > 0.5 and contact_state != ContactState.BLOCK:
			_launch_pulse = FEEL.launch_stretch\
			* (1.0 + _air_boost * FEEL.launch_charge_gain)
			_launch_vel = 0.0
	elif not airborne and _was_airborne:
		_air_boost = 0.0
		air_trail.set_boost(0.0)
	_was_airborne = airborne


	if _float_shake_t > 0.0:
		_float_shake_t = maxf(_float_shake_t - delta, 0.0)
		var amp: = 0.09 * (_float_shake_t / 0.4)
		float_label.position = _float_base_pos + Vector3(
			randf_range( - amp, amp), randf_range( - amp, amp), 0.0)
		if _float_shake_t <= 0.0:
			float_label.position = _float_base_pos
	var gait: = clampf(planar / FEEL.move_speed, 0.0, 1.0) if grounded() else 0.0
	var action: = ""
	if _model != null:



		_hitstop_hold = maxf(_hitstop_hold - delta, 0.0)
		var in_hitstop: = _hitstop_hold > 0.0 or (net_puppet and _puppet_hitstop)


		_model.hold_frame = in_hitstop
		_model.spike_light = _spike_light
		_model.jump_variant = _jump_variant



		_model.gait_fatigue = lerpf(FEEL.sprint_anim_fatigue, 1.0, stamina_frac())\
		if sprinting else 1.0

		if sprinting and not _sprint_anim_prev:
			_sprint_start_t = _model.action_length("sprint_start")
		_sprint_anim_prev = sprinting
		_sprint_start_t = maxf(_sprint_start_t - delta, 0.0)
		action = _model_action()




		var scrub: = (_jump_charge / FEEL.approach_time) if action == "approach"\
		else -1.0
		_model.block_out = _block_ot
		_model.drive(planar, grounded(), velocity.y, action, gait_pace_speed(), scrub)









		var still_broken: = _gesture_still\
		and Vector2(velocity.x, velocity.z).length() > GESTURE_STILL_SPEED * 1.5
		var co_interrupt: = diving() or knocked() or not grounded()\
		or contact_state == ContactState.WINDUP or contact_state == ContactState.BLOCK\
		or still_broken
		_model.tick_callout(delta, co_interrupt)


		if not far_lod:
			_model.drive_cloth(delta, velocity.y, grounded(), _air_boost, 
				_dive_time > 0.0, knocked(), _armed_influence.x)

			_model.tick_hair_gradient()
		if in_hitstop:





			if _model.hands_animated():
				hand_l.position = _model.hand_local(false)
				hand_r.position = _model.hand_local(true)
			_apply_reach(delta, true)
			_update_reflection()
			return
		if not far_lod:
			_model.tail_tick(delta)


			if not serve_charge_ui:


				if not _sprint_head_lean(delta):
					_gaze_tick(delta)
	if far_lod:






		_trail_hand_l.set_active(false)
		_trail_hand_r.set_active(false)
		_land_pulse = move_toward(_land_pulse, 0.0, delta * 5.0)
		visual.scale = visual.scale.lerp(Vector3.ONE, minf(delta * 5.0, 1.0))


		if not _far_overlays_hidden:
			_far_overlays_hidden = true
			combo_badge.visible = false
			float_label.visible = false
			callout_label.visible = false
			($NameTag as Label3D).visible = false



		_update_reflection()
		return
	if _far_overlays_hidden:
		_far_overlays_hidden = false





		($NameTag as Label3D).visible = not names_suppressed
	_gait_phase += delta * (2.2 + planar * 1.9)
	var target_l: = _idle_l
	var target_r: = _idle_r
	var pose_speed: = FEEL.pose_speed
	if contact_state == ContactState.IDLE:
		if _model != null and _model.hands_animated():


			target_l = _model.hand_local(false)
			target_r = _model.hand_local(true)
			pose_speed = FEEL.pose_speed * 2.5
		else:
			var swing: = sin(_gait_phase) * 0.24 * gait
			target_l.z += swing
			target_r.z -= swing
			target_l.y += absf(cos(_gait_phase)) * 0.06 * gait
			target_r.y += absf(cos(_gait_phase + PI)) * 0.06 * gait
	if contact_state == ContactState.RECOVER and POSE_FOLLOW.has(last_touch):
		if last_touch == TouchKind.SPIKE and _model != null\
		and _model.hands_animated():



			target_l = _model.hand_local(false)
			target_r = _model.hand_local(true)
			pose_speed = FEEL.pose_speed * 2.5
		else:

			var follow: = TouchKind.SET if set_dump_touch() else last_touch
			target_l = POSE_FOLLOW[follow][0]
			target_r = POSE_FOLLOW[follow][1]
			pose_speed = FEEL.pose_speed * 0.25
	elif contact_state == ContactState.BLOCK:

		var lane_world_x: = lerpf(float(_shift_from), float(block_lane), _shift_progress)\
		* FEEL.block_lane_offset
		var local_off: = Vector3(lane_world_x, 0.0, 0.0)\
		.rotated(Vector3.UP, - visual.rotation.y)
		target_l = Vector3(local_off.x - 0.25, FEEL.block_height + 0.05, 0.4)
		target_r = Vector3(local_off.x + 0.25, FEEL.block_height + 0.05, 0.4)
	elif contact_state == ContactState.WINDUP:
		match _windup_pose_kind():
			TouchKind.SET:
				target_l = POSE_SET_L
				target_r = POSE_SET_R
			TouchKind.SPIKE:
				if _model != null and _model.hands_animated():



					target_l = _model.hand_local(false)
					target_r = _model.hand_local(true)
					pose_speed = FEEL.pose_speed * 2.5
				else:


					target_l = POSE_SPIKE_HIT
					target_r = POSE_SPIKE_GUIDE
			_:




				target_l = POSE_BUMP_L
				target_r = POSE_BUMP_R





	if _show_ready_hands() and contact_state != ContactState.WINDUP:
		if _ready_hands_kind() == TouchKind.SET:
			target_l = POSE_SET_L
			target_r = POSE_SET_R
		else:
			target_l = POSE_BUMP_L
			target_r = POSE_BUMP_R
		pose_speed = FEEL.pose_speed







	if not grounded() and absf(velocity.y) > 0.05\
	and contact_state != ContactState.BLOCK\
	and _model != null and _model.hands_animated():
		target_l = _model.hand_local(false)
		target_r = _model.hand_local(true)
		pose_speed = FEEL.pose_speed * 2.5



















	if _getup_time > 0.0 or knocked() or diving():
		if _model != null and _model.hands_animated():
			target_l = _model.hand_local(false)
			target_r = _model.hand_local(true)
			pose_speed = FEEL.pose_speed * 2.5
		else:


			target_l = _idle_l
			target_r = _idle_r





	if _receive_side != 0 and _receive_pose > 0.0 and last_touch == TouchKind.BUMP\
	and grounded() and _model != null and _model.hands_animated():
		target_l = _model.hand_local(false)
		target_r = _model.hand_local(true)
		pose_speed = FEEL.pose_speed * 2.5




	if _model != null and _model.hands_animated()\
	and (((last_touch == TouchKind.SET or set_dump_touch()) and _receive_side == 3
				and _receive_pose > 0.0)
			or (_puppet_action == "set_back" and _puppet_action_t > 0.0)):
		target_l = _model.hand_local(false)
		target_r = _model.hand_local(true)
		pose_speed = FEEL.pose_speed * 2.5





	if serve_charge_ui:
		target_l = POSE_SERVE_L
		target_r = POSE_SERVE_R
		pose_speed = FEEL.pose_speed * 2.0


	if _serve_toss_lift > 0.0:
		_serve_toss_lift = maxf(_serve_toss_lift - delta * 4.5, 0.0)
		var lift: = _serve_toss_lift * 0.35
		target_l = Vector3(target_l.x, target_l.y + lift, target_l.z)
		target_r = Vector3(target_r.x, target_r.y + lift, target_r.z)





	if _cel_state > 0:
		pose_speed = FEEL.pose_speed * 2.4
		var pump: = absf(sin(_cel_t * 8.0)) * 0.14
		var cheer_l: = POSE_CHEER_L + Vector3(0.0, pump, 0.0)
		var cheer_r: = POSE_CHEER_R + Vector3(0.0, pump, 0.0)
		target_l = cheer_l
		target_r = cheer_r
		if _cel_state == 2:

			var reach: = clampf(_cel_hf_t / CEL_HF_REACH, 0.0, 1.0)
			if _cel_hf_t > CEL_HF_REACH:
				reach = 1.0 - clampf(
					(_cel_hf_t - CEL_HF_REACH) / CEL_HF_RETURN, 0.0, 1.0)
			reach = ease(reach, 0.45)
			var meet_local: = visual.to_local(_cel_meet) if visual != null\
			else _cel_meet
			if _cel_hand > 0:
				target_l = cheer_l.lerp(meet_local, reach)
			else:
				target_r = cheer_r.lerp(meet_local, reach)
			pose_speed = FEEL.pose_speed * 4.0



	var hit_cut: = action == "block_hit" and _pose_last_action != "block_hit"
	_pose_last_action = action
	var w: = 1.0 if _pose_snap or hit_cut else 1.0 - exp( - pose_speed * delta)
	hand_l.position = hand_l.position.lerp(target_l, w)
	hand_r.position = hand_r.position.lerp(target_r, w)





	var spike_live: = action == "spike" and _knock_time <= 0.0
	var wall_up: = contact_state == ContactState.BLOCK




	var lefty: = character != null and character.left_handed
	_trail_hand_l.set_active( not far_lod\
	and ((spike_live and not lefty) or wall_up))
	_trail_hand_r.set_active( not far_lod\
	and ((spike_live and lefty) or wall_up))



	var emph_l: = 1.0
	var emph_r: = 1.0
	if wall_up:
		emph_l = 1.28
		emph_r = 1.28
	elif spike_live or (contact_state == ContactState.WINDUP\
	and _windup_pose_kind() == TouchKind.SPIKE):
		if lefty:
			emph_r = 1.35
		else:
			emph_l = 1.35
	var ew: = 1.0 if _pose_snap else 1.0 - exp(-10.0 * delta)
	_hand_emph_l = lerpf(_hand_emph_l, emph_l, ew)
	_hand_emph_r = lerpf(_hand_emph_r, emph_r, ew)
	hand_l.scale = Vector3.ONE * _hand_scale_base * _hand_emph_l
	hand_r.scale = Vector3.ONE * _hand_scale_base * _hand_emph_r








	var charge_shake_amt: = 0.0
	if contact_state == ContactState.WINDUP and resolved_touch() == TouchKind.SET:
		charge_shake_amt = hold_power()
	elif serve_charge_ui:
		charge_shake_amt = hold_power()





	if charge_shake_amt > 0.02 and delta > 0.0:
		_charge_buzz = fmod(_charge_buzz + delta * FEEL.charge_shake_hz * TAU, TAU * 10.0)
		var samp: = FEEL.charge_shake * (0.4 + charge_shake_amt) * 2.2
		var jl: = Vector3(sin(_charge_buzz), cos(_charge_buzz * 1.7), 0.0) * samp
		hand_l.position += jl
		hand_r.position += Vector3( - jl.x, jl.y, 0.0)







	if _recoil_kind != TouchKind.NONE and delta > 0.0:
		var rdt: = minf(delta, 0.033)
		_recoil_vel += - FEEL.recoil_stiff * _recoil * rdt
		_recoil_vel *= exp( - FEEL.recoil_damp * rdt)
		_recoil += _recoil_vel * rdt
		if absf(_recoil) < 0.001 and absf(_recoil_vel) < 0.02:
			_recoil = 0.0
			_recoil_vel = 0.0
			_recoil_kind = TouchKind.NONE
		else:
			var kick: Vector3 = RECOIL_DIR[_recoil_kind] * _recoil
			hand_l.position += kick
			hand_r.position += kick












	if _model != null and _model.hands_animated() and not serve_charge_ui\
	and action in ["spike", "spike_L", "approach", "kick_r", "kick_l", 
			"sprint", "sprint_start", "block_hit"]:


		hand_l.position = _model.hand_local(false)
		hand_r.position = _model.hand_local(true)



	if _model != null and _model.hands_animated() and _model.callout_active():
		hand_l.position = _model.hand_local(false)
		hand_r.position = _model.hand_local(true)


	var target_y: = 1.0 - FEEL.crouch_squash * (_jump_charge / FEEL.jump_charge_time)

	var block_owned: = action == "block" or action == "block_hit"
	if not grounded() and not block_owned:
		target_y *= 1.0 + clampf(absf(velocity.y) * 0.025, 0.0, 0.3)
	target_y *= 1.0 - 0.35 * _land_pulse
	_land_pulse = move_toward(_land_pulse, 0.0, delta * 5.0)













	var sdt: = minf(delta, 0.033)
	if _launch_pulse != 0.0 or _launch_vel != 0.0:
		_launch_vel += - FEEL.launch_spring * _launch_pulse * sdt
		_launch_vel *= exp( - FEEL.launch_damp * sdt)
		_launch_pulse += _launch_vel * sdt
		if absf(_launch_pulse) < 0.001 and absf(_launch_vel) < 0.01:
			_launch_pulse = 0.0
			_launch_vel = 0.0
	if action == "spike":




		target_y = 1.0





	_squash_y = lerpf(_squash_y, target_y, w)
	var sy: = _squash_y
	var sxz: = 1.0 / sqrt(maxf(_squash_y, 0.5))




	if _launch_pulse != 0.0 and action != "spike" and action != "spike_L"\
	and action != "block" and action != "block_hit":
		var s: = 1.0 + _launch_pulse
		sy *= s
		sxz *= 1.0 / sqrt(maxf(s, 0.2))
	visual.scale = Vector3(sxz, sy, sxz)


	var charge_frac: = (_jump_charge / FEEL.jump_charge_time) if grounded() else 0.0
	if charge_frac > 0.05:

		_charge_buzz = fmod(_charge_buzz + delta * FEEL.charge_shake_hz * TAU, TAU * 10.0)
		var amp: = FEEL.charge_shake * charge_frac * charge_frac
		visual.position.x = sin(_charge_buzz) * amp
		visual.position.z = cos(_charge_buzz * 1.73) * amp * 0.6
	elif absf(visual.position.x) > 0.0001 or absf(visual.position.z) > 0.0001:
		visual.position.x = lerpf(visual.position.x, 0.0, w)
		visual.position.z = lerpf(visual.position.z, 0.0, w)



	if _knock_time > 0.0 and not _set_low:




		var roll: = - _knock_roll - 1.2 if _knock_roll >= 0.0 else - _knock_roll + 1.2





		var side: = sin(roll) * FEEL.tumble_side
		if _knock_time < FEEL.tumble_settle:



			var k: = roundf((roll - PI * 0.5) / PI)
			var flat: = PI * 0.5 + k * PI




			var t: = clampf((FEEL.tumble_settle - _knock_time)\
			/ maxf(FEEL.tumble_settle - FEEL.knock_burnout_hold, 0.001), 0.0, 1.0)
			roll = lerpf(roll, flat, t)
			side = lerpf(side, 0.0, t)
		visual.rotation.x = roll
		visual.rotation.z = side




		var up_y: = cos(roll) * cos(side)
		var lat: = sqrt(maxf(1.0 - up_y * up_y, 0.0))






		var need: = maxf(0.0, - FEEL.tumble_clear * up_y) + FEEL.tumble_girth * lat
		visual.position.y = maxf(0.36 - 0.65 * up_y, need)
		_apply_reach(delta, false)
		_update_reflection()
		return
	var tilt_x: = 0.0
	var tilt_z: = 0.0


	var model_dives: = _model != null and _model.has_action("dive")
	if _dive_time > 0.0 and not model_dives:
		if _dive_side != 0:



			tilt_z = FEEL.dive_tilt if _dive_side == 1 else - FEEL.dive_tilt
		else:
			tilt_x = FEEL.dive_tilt
	elif contact_state == ContactState.RECOVER and last_touch == TouchKind.SPIKE:


		tilt_x = 0.22 if _spike_light else 0.45
	elif not grounded() and (action == "block" or action == "block_hit"):



		pass
	elif not grounded():
		var local_move: = Vector3(_move_intent.x, 0.0, _move_intent.y)\
		.rotated(Vector3.UP, - visual.rotation.y)
		tilt_x = local_move.z * FEEL.air_lean
		tilt_z = - local_move.x * FEEL.air_lean
		if contact_state == ContactState.WINDUP\
		and _windup_pose_kind() == TouchKind.SPIKE:




			var back: = clampf( - local_move.z, 0.0, 1.0)
			tilt_x = lerpf(-0.55, -0.22, back) + maxf(0.0, local_move.z) * 0.15
	elif sprinting and _model != null and _model.has_action("sprint"):





		var vel2: = Vector2(velocity.x, velocity.z)
		if vel2.length() > 1.5 and _move_intent.length() > 0.2:
			var turn: = vel2.normalized().cross(_move_intent.normalized())
			tilt_z = clampf(turn, -1.0, 1.0) * FEEL.sprint_bank
		if _plant_time > 0.0:


			var lv: = Vector3(velocity.x, 0.0, velocity.z)\
			.rotated(Vector3.UP, - visual.rotation.y)
			tilt_x = - clampf(lv.z * 0.05, -0.3, 0.3) * plant_strength()
	else:

		var local_vel: = Vector3(velocity.x, 0.0, velocity.z)\
		.rotated(Vector3.UP, - visual.rotation.y)
		tilt_x = clampf(local_vel.z * 0.045, -0.28, 0.28)
		tilt_z = clampf( - local_vel.x * 0.045, -0.28, 0.28)\
		+ sin(_gait_phase * 0.5) * 0.035 * gait
		if _plant_time > 0.0:


			var p: = plant_strength()
			tilt_x -= clampf(local_vel.z * 0.06, -0.3, 0.3) * p
			tilt_z += clampf( - local_vel.x * 0.06, -0.3, 0.3) * p
	visual.rotation.x = lerpf(visual.rotation.x, tilt_x, w)
	visual.rotation.z = lerpf(visual.rotation.z, tilt_z, w)
	visual.position.y = lerpf(visual.position.y, 0.0, w)

	var bob: = absf(sin(_gait_phase)) * 0.055 * gait\
	+ sin(_gait_phase * 0.9) * 0.012 * (1.0 - gait)
	body.position.y = 0.65 + bob




	_apply_reach(delta, false)
	_update_reflection()



func net_capture() -> PackedFloat32Array:








	var flags: = int(contact_state) | ((1 if grounded() else 0) << 2)\
	| (int(last_touch) << 3) | ((block_lane + 1) << 6)\
	| ((_shift_from + 1) << 8) | ((1 if touch_barred else 0) << 10)\
	| ((1 if serve_charge_ui else 0) << 11)\
	| ((1 if _strafe_held else 0) << 12)\
	| ((1 if _was_knocked_getup else 0) << 13)\
	| ((1 if touch_barred_self else 0) << 14)\
	| ((int(_windup_pose_kind() if contact_state == ContactState.WINDUP\
	else (_ready_hands_kind() if _show_ready_hands() else resolved_touch())) & 7) << 15)\
	| ((1 if _show_ready_hands() else 0) << 18)\
	| ((1 if _recoil_tick else 0) << 19)\
	| ((_dive_side & 3) << 20)\
	| ((1 if _hitstop_hold > 0.0 else 0) << 22)\
	| ((_kick_foot & 3) << 23)






	return PackedFloat32Array([global_position.x, global_position.y, 
		global_position.z, velocity.x, velocity.y, velocity.z, 
		wrapf(visual.rotation.y, - PI, PI), aim_point.x, aim_point.z, 
		_move_intent.x, _move_intent.y, flags, hold_time, 
		_knock_time, _knock_roll, _dive_time, _shift_progress, _jump_charge, 



		_recover_left, _land_pulse, 










		_getup_time, _receive_pose, _settle_time, _land_time, 


















		float((_receive_side & 3) | ((1 if _set_low else 0) << 2)\
		| ((1 if _dive_receive else 0) << 3)\
		| ((1 if sprinting else 0) << 4)\
		| ((1 if _downed_hold else 0) << 5)\
		| (int(round(stamina_frac() * 63.0)) << 6)\
		| ((1 if stamina_locked else 0) << 12)\
		| ((_jump_variant & 3) << 13)\
		| ((1 if _block_ot else 0) << 15)\
		| ((1 if rivals_can_play else 0) << 16))])

func replay_capture() -> PackedFloat32Array:



	var out: = net_capture()
	out.push_back(_model.anim_normalized() if _model != null else 0.0)
	return out







func replay_apply(a: PackedFloat32Array, pos: Vector3, snap: = false) -> void :
	net_apply(a, pos)
	if snap:
		_puppet_action = ""
		_puppet_action_t = 0.0



	_pose_snap = snap
	puppet_tick(0.0)
	_pose_snap = false
	if _model != null and a.size() > NET_FLOATS:


		_model.seek_normalized(a[NET_FLOATS], snap)

var _pose_snap: = false
var _pose_last_action: = ""

func net_apply(a: PackedFloat32Array, pos: Vector3) -> void :




	if a.size() < 25:
		return

	global_position = pos
	velocity = Vector3(a[3], a[4], a[5])
	visual.rotation.y = a[6]
	aim_point = Vector3(a[7], 0.0, a[8])
	_move_intent = Vector2(a[9], a[10])
	var flags: = int(a[11])
	contact_state = (flags & 3) as ContactState
	_puppet_grounded = ((flags >> 2) & 1) == 1
	last_touch = ((flags >> 3) & 7) as TouchKind
	block_lane = ((flags >> 6) & 3) - 1
	_shift_from = ((flags >> 8) & 3) - 1
	touch_barred = ((flags >> 10) & 1) == 1
	serve_charge_ui = ((flags >> 11) & 1) == 1
	_strafe_held = ((flags >> 12) & 1) == 1
	_was_knocked_getup = ((flags >> 13) & 1) == 1
	touch_barred_self = ((flags >> 14) & 1) == 1
	_puppet_resolved_touch = ((flags >> 15) & 7) as TouchKind
	_puppet_hands_ready = ((flags >> 18) & 1) == 1




	_dive_side = (flags >> 20) & 3
	_kick_foot = (flags >> 23) & 3


	_puppet_hitstop = ((flags >> 22) & 1) == 1
	var recoil_tick: = ((flags >> 19) & 1) == 1
	if recoil_tick != _recoil_tick:
		_recoil_tick = recoil_tick



		var rk: = last_touch
		if rk == TouchKind.DUMP and a.size() > 24 and (int(a[24]) & 3) != 0:
			rk = TouchKind.SET
		if RECOIL_DIR.has(rk):
			_recoil_vel = FEEL.recoil_kick
			_recoil_kind = rk
		_arm_reach(rk)
	hold_time = a[12]
	_knock_time = a[13]
	_knock_roll = a[14]
	_dive_time = a[15]
	_shift_progress = a[16]
	_jump_charge = a[17]
	_recover_left = a[18]
	_land_pulse = a[19]
	_getup_time = a[20]
	_receive_pose = a[21]
	_settle_time = a[22]
	_land_time = a[23]

	var flags2: = int(a[24])
	_receive_side = flags2 & 3
	_set_low = ((flags2 >> 2) & 1) == 1
	_dive_receive = ((flags2 >> 3) & 1) == 1
	sprinting = ((flags2 >> 4) & 1) == 1
	_downed_hold = ((flags2 >> 5) & 1) == 1
	_jump_variant = (flags2 >> 13) & 3
	_block_ot = ((flags2 >> 15) & 1) == 1
	rivals_can_play = ((flags2 >> 16) & 1) == 1



	if net_puppet:
		stamina = float((flags2 >> 6) & 63) / 63.0 * FEEL.stamina_max
		stamina_locked = ((flags2 >> 12) & 1) == 1

func net_force_state(a: PackedFloat32Array) -> void :


	if a.size() < 25:
		return
	net_apply(a, Vector3(a[0], a[1], a[2]))
	reset_physics_interpolation()



func replay_clip(clip: String) -> void :
	if _model != null and clip != "":
		_model.replay_force(clip)

func replay_clip_name() -> String:
	return String(_model._current) if _model != null else ""

func seek_replay_anim(normalized: float) -> void :



	if _model != null:
		_model.seek_normalized(normalized, false)

func set_anim_time_scale(scale: float) -> void :

	if _model != null:
		_model.playback_scale = scale

func puppet_tick(delta: float) -> void :


	if _puppet_action_t > 0.0:
		_puppet_action_t = maxf(_puppet_action_t - delta, 0.0)
	_pose(delta)
	drop_shadow.global_position = Vector3(global_position.x, maxf(0.02, SandDeform.feet_y()), global_position.z)
	drop_shadow.visible = not ShadowSun.casting
	var shadow_scale: = clampf(1.0 - global_position.y * 0.08, 0.55, 1.0)
	drop_shadow.scale = Vector3(shadow_scale, 1.0, shadow_scale)
	indicator_ring.visible = false
	charge_ui.visible = false
