class_name TeamBot
extends RefCounted









enum {MODE_IDLE, MODE_RECEIVE, MODE_SUPPORT, MODE_BLOCK, MODE_DEFEND}

const THINK_INTERVAL: = 0.18
const AIM_ERROR: = 0.9
const ARRIVE_RADIUS: = 0.25


var _rally_live: = false
const TOUCH_PRESS_DIST: = 2.6
const TOUCH_RELEASE_DIST: = 1.35
const TOUCH_COOLDOWN: = 0.5
const JUMP_HOLD_ATTACK: = 0.72
const JUMP_HOLD_SERVE: = 0.62
const JUMP_HOLD_BLOCK: = 0.62







const BLOCK_WALL_GAP: = 1.0

const BLOCK_JUMP_LEAD: = 0.22



const BLOCK_READ_H: = 2.95



const SERVE_STAND_BACK: = 0.35
const ATTACK_LEAD_SLACK: = 0.08
const SERVE_STAND_PRESS_DIST: = 2.0
const SERVE_TOSS_JUMP: = 11.5
const SERVE_TOSS_STAND: = 7.0









const SERVE_RUN_BACK: = 4.0


const SERVE_RUN_MIN_HOLD: = 0.45
const SERVE_RUN_TAKEOFF: = 0.55

const SERVE_RUN_HIT_H: = 3.3

const SERVE_RUN_RISE: = 0.38








const SERVE_RUN_AHEAD: = 0.45
const SERVE_LINE_GUARD: = 0.15

const APPROACH_PLANT_TIME: = 0.18








const POWER_RUN_IN: = 0.6

const POWER_RUN_NET_MAX: = 3.2
const POWER_RUN_WALL_X: = 2.5
const POWER_RUN_WALL_Z: = 2.2
const POWER_RUN_START_TOL: = 0.7
const POWER_RUN_ALIGN: = 0.75
const POWER_RUN_MIN_RUN: = 0.45
const POWER_RUN_MIN_HOLD: = 0.3
static var POWER_RUN_ENABLED: = true
const ATTACK_PLANT_NEAR: = 0.6


const ATTACK_ASCENT_RESERVE: = 0.32
const ATTACK_ASCENT_FLOAT: = 0.55

const ATTACK_RETIME_SLACK: = 0.25

static var RETIME_ENABLED: = true




const SET_FLOAT_APEX: = 3.0
const MIN_SPIKE_CHARGE: = 0.2
const ATTACK_MEET_H: = 2.45
const NET_MEET_MIN: = 0.25







const LAST_TOUCH_ATTACK_DEPTH: = 4.5
const SET_APPROACH_H: = 2.0


const NET_PLAY_Z: = 1.4
const SPIKE_JUMP_DIST: = 1.1
const HUMAN_PRIORITY: = 0.8



const SET_REACH_RUN: = 6.5


const OWN_FAULT_APRON: = 7.5
const HUMAN_SET_BIAS: = 3.0


const SOLO_READ_WEIGHT: = 0.7
const SOLO_BALL_WEIGHT: = 0.3




const QUICK_CALL_CHANCE: = 0.28
const CPU_QUICK_SET_ENABLED: = true
const DUMP_CHANCE: = 0.09



const SECOND_BALL_CHANCE: = 0.3
const RARE_COUNTER_CHANCE: = 0.08



const OVERPASS_ATTACK_MARGIN: = 0.45






const MINUS_TEMPO_TAP_DIST: = 0.7
const SET_SPREAD: = 0.8
const SET_DEPTH_VARY: = 0.4

var aggression: = 0.0
var aim_error_mult: = 1.0
var think_mult: = 1.0
var _mode: = MODE_IDLE
var _react_delay: = 0.0
var _think_timer: = 0.0
var _move_target: = Vector3.ZERO
var _aim: = Vector3.ZERO
var _holding: = false
var _letgo_line: = -1
var _set_holding: = false
var _set_hold_time: = 0.0
var _set_quick: = false
var _set_target_distance: = 0.0
var _touch_cooldown: = 0.0
var _jump_hold: = 0.0
var _attacking: = false
var _threat: Player = null
var _raw_touch_count: = 0
var _awaiting_serve: = true
var _serve_flight: = -1

func _opp_serve_in_flight(ball: Ball) -> bool:
	return ball != null and _serve_flight >= 0 and ball.strike_seq == _serve_flight
var _team_serving: = false
var _block_jump: = false
var _hop_straight: = false

var _braking: = false



var _serve_crouch: = false


var _press_dist: = TOUCH_PRESS_DIST
var _half_w: = 4.5
var _half_l: = 9.0
var _slot_frac: = 0.5
var _front_row: = false
var _solo: = false
var _cover: = Vector2.ZERO
var _rebound_z: = 0.0
var _cx: = 0.0
var _wander: = Vector2.ZERO
var _wander_timer: = 0.0
var _parked: = false
const PARK_HYSTERESIS: = 0.85
var _human_front: = false
var _pair: = false

var _solo_shade_x: = 0.0
var _solo_shade_w: = 0.3
var _foe_loading: = false
var _attack_read_err: = 0.0
var _prev_ball_dist: = INF
var _release_seq: = -1
var _serving: = false
var _serve_jump: = true
var _serve_run: = false
var _serve_go: = false
var _serve_float: = false
var _ball_float: = false




var _float_chase: = false
var _was_float: = false
var _ball: Ball = null
var float_chase_chance: = 0.4
var _serve_rolled: = false
var _tempo_float: = false
var _power_run: = false
var _run_go: = false
var _run_meet: = Vector3.ZERO
var _run_dir: = Vector3.ZERO
var _run_fly: = 0.0
var power_run_chance: = 0.55
var _dive_err: = 0.0
var _dive_err_seq: = -1
var _dive_skip: = false
var _dive_skip_seq: = -1



func serve_toss_speed() -> float:
	return SERVE_TOSS_JUMP if _serve_jump else SERVE_TOSS_STAND




func serve_ready(me: Player) -> bool:
	if not (_serve_jump and _serve_run):
		return true
	var start_z: = float(me.team_side) * (_half_l + SERVE_RUN_BACK)
	return absf(me.global_position.z - start_z) < 0.7\
	and Vector2(me.velocity.x, me.velocity.z).length() < 1.0






func serve_toss_horiz(me: Player, up_speed: float) -> Vector3:
	if not (_serve_jump and _serve_run):
		return Vector3.ZERO
	var side: = float(me.team_side)
	var from: = me.serve_cradle_point(true)


	var meet_z: = side * (_half_l + SERVE_RUN_TAKEOFF - serve_run_fly() - SERVE_RUN_AHEAD)
	var g: = Ball.PHYS.gravity
	var disc: = up_speed * up_speed + 2.0 * g * (from.y - SERVE_RUN_HIT_H)
	if disc < 0.0 or g <= 0.0:
		return Vector3.ZERO
	var t: = (up_speed + sqrt(disc)) / g
	var cap: = Ball.serve_toss_charge(up_speed)\
	* Ball.PHYS.serve_toss_horiz_max
	return Vector3(0.0, 0.0, clampf((meet_z - from.z) / t, - cap, cap))



static func serve_run_fly() -> float:
	return Player.FEEL.jump_carry * Player.FEEL.move_speed * SERVE_RUN_RISE




static func run_time(dist: float, speed: float, top: = -1.0) -> float:
	if top <= 0.0:
		top = Player.FEEL.move_speed
	var a: = maxf(Player.FEEL.accel_start, 0.1)
	speed = clampf(speed, 0.0, top)
	var t_acc: = (top - speed) / a
	var d_acc: = (speed + top) * 0.5 * t_acc
	if dist <= d_acc:

		return ( - speed + sqrt(speed * speed + 2.0 * a * dist)) / a
	return t_acc + (dist - d_acc) / top
var _quick_armed: = false
var _quick_jump: = false
var _quick_seq: = -1


var _second_ball_roll: = false
var _rare_counter_roll: = false
var _last_touch_count: = -1





const SERVE_BOOK_MAX: = 6
const SERVE_SAME_DIST: = 2.6
var _serve_book: Array = []
var _serve_read: = false
var _serve_logged: = false







enum Persona{BALANCED, AGGRESSIVE, WALL}
var persona: = Persona.BALANCED
var quick_chance: = QUICK_CALL_CHANCE
var dump_chance: = DUMP_CHANCE
var serve_jump_chance: = 0.7
var serve_float_chance: = 0.3
var serve_run_chance: = 0.8
var dive_bias: = 1.0
var power_bias: = 1.0
var jump_charge_scale: = 1.0
var difficulty_level: = 1
var _dive_aim_err: = 1.2
var jump_server_trait: = false
var float_server_trait: = false
var jump_server_forced: = false
var _block_deflect_aim: = Vector3.ZERO


enum HitterStyle{PLANTED, MIXED, RUNNER}
var hitter_style: = HitterStyle.MIXED

func _roll_persona(slot: int) -> void :



	quick_chance = QUICK_CALL_CHANCE
	dump_chance = DUMP_CHANCE
	serve_jump_chance = 0.7
	serve_float_chance = 0.3
	serve_run_chance = 0.8
	float_server_trait = false
	dive_bias = 1.0
	power_bias = 1.0
	var rng: = RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(GameConfig.match_seed, slot))
	persona = [Persona.BALANCED, Persona.AGGRESSIVE, Persona.WALL][
		rng.randi_range(0, 2)] as Persona
	match persona:
		Persona.AGGRESSIVE:
			quick_chance = QUICK_CALL_CHANCE * 1.5
			dump_chance = DUMP_CHANCE * 1.4
			serve_jump_chance = 0.9
			dive_bias = 1.15
			power_bias = 1.12
			aim_error_mult *= 1.15
		Persona.WALL:
			quick_chance = QUICK_CALL_CHANCE * 0.4
			dump_chance = DUMP_CHANCE * 0.5
			serve_jump_chance = 0.45
			dive_bias = 1.5
			power_bias = 0.85
			aim_error_mult *= 0.8







	var serve_style: = rng.randf()
	jump_server_trait = jump_server_forced or serve_style > 0.68
	if jump_server_forced or serve_style > 0.84:
		serve_jump_chance = 1.0
		serve_float_chance = 0.0
		serve_run_chance = 1.0
		power_bias = maxf(power_bias, 1.06)
	elif jump_server_trait:
		float_server_trait = true
		serve_jump_chance = 1.0
		serve_float_chance = 1.0
	elif serve_style < 0.22:
		serve_jump_chance = minf(serve_jump_chance, 0.18)



	if GameConfig.simple_bot_serves:
		float_server_trait = false
		serve_float_chance = 0.0
		jump_server_trait = false
		serve_jump_chance = 0.0
		serve_run_chance = 0.0
		power_bias = minf(power_bias, 1.0)





	var hit_style: = rng.randf()
	if hit_style < 0.35:
		hitter_style = HitterStyle.PLANTED
	elif hit_style > 0.72:
		hitter_style = HitterStyle.RUNNER
	else:
		hitter_style = HitterStyle.MIXED

func ensure_jump_server() -> void :
	jump_server_forced = true
	jump_server_trait = true
	float_server_trait = false
	serve_jump_chance = 1.0
	serve_float_chance = 0.0
	serve_run_chance = 1.0

static func ensure_team_jump_servers(brains: Dictionary) -> void :
	if GameConfig.simple_bot_serves:
		return
	for side in [-1, 1]:
		var team: Array = []
		var has_trait: = false
		for body in brains:
			var member: Player = body
			if member.team_side != side:
				continue
			var brain: TeamBot = brains[body]
			team.append(brain)
			has_trait = has_trait or brain.jump_server_trait
		if not has_trait and not team.is_empty():
			(team[0] as TeamBot).ensure_jump_server()

func apply_difficulty(level: int) -> void :
	var tier: = clampi(level, 0, 2)
	difficulty_level = tier
	aim_error_mult = GameConfig.difficulty_aim_mult(tier)
	if persona == Persona.AGGRESSIVE:
		aim_error_mult *= 1.15
	elif persona == Persona.WALL:
		aim_error_mult *= 0.8
	think_mult = GameConfig.difficulty_think_mult(tier)
	serve_jump_chance = clampf(serve_jump_chance + [-0.25, 0.0, 0.08][tier], 
		0.05, 1.0)


	jump_charge_scale = [0.82, 1.0, 1.04][tier]


	power_run_chance = [0.3, 0.55, 0.8][tier]




	_dive_aim_err = [2.1, 1.3, 0.7][tier]
	if persona == Persona.WALL:
		_dive_aim_err *= 0.7
	elif persona == Persona.AGGRESSIVE:
		_dive_aim_err *= 1.2

func configure(half_w: float, half_l: float, slot: int, team_n: int, 
		center_x: = 0.0) -> void :
	_half_w = half_w
	_half_l = half_l
	_cx = center_x
	_solo = team_n <= 1
	_pair = team_n == 2
	_roll_persona(slot)
	apply_difficulty(difficulty_level)
	if _solo:

		_front_row = false
		_slot_frac = 0.5
		return


	var front_count: = maxi(1, int(team_n / 2.0))
	_front_row = slot < front_count
	var group: = front_count if _front_row else team_n - front_count
	var idx: = slot if _front_row else slot - front_count
	_slot_frac = (float(idx) + 0.5) / float(group)

func think(me: Player, allies: Array, opponents: Array, ball: Ball, 
		touch_count: int, rally_live: bool, serving: bool, delta: float, 
		responsibility_side: = 0, team_serving: = false) -> PlayerInput:
	var input: = PlayerInput.new()
	_serving = serving
	_team_serving = team_serving
	_rally_live = rally_live
	_ball = ball
	_resp_side = responsibility_side
	if DEBUG_AI and _letgo_line >= 0:

		if ball != null and not ball.frozen and rally_live:
			print("[LETGO] %s line=%d mode=%d cs=%d d=%.2f reach=%s far=%s y=%.2f vy=%.2f tc=%d seq=%d" % [
				me.name, _letgo_line, _mode, me.contact_state, 
				ball.global_position.distance_to(me.chest_position()), 
				str(me._swing_reach_check()), str(me.ball_on_far_side()), 
				ball.global_position.y, ball.vel.y, touch_count, ball.strike_seq])
		_letgo_line = -1
	me.dive_aim_error = _dive_aim_err
	_ball_float = ball != null and ball.float_serve
	if _ball_float and not _was_float:
		var chance: = float_chase_chance * (1.0 if difficulty_level <= 0 else (0.7 if difficulty_level == 1 else 0.45))
		if persona == Persona.AGGRESSIVE:
			chance *= 1.3
		elif persona == Persona.WALL:
			chance *= 0.5
		_float_chase = randf() < chance
	_was_float = _ball_float
	if not rally_live:


		me.claiming = false
		_mode = MODE_IDLE

		_serve_read = false
		_serve_logged = false
		_awaiting_serve = true
		_serve_flight = -1








		_react_delay = 0.0
		_prev_ball_dist = INF
		input.jump_cancelled = true
		_jump_hold = 0.0
		_quick_jump = false
		_block_jump = false
		_serve_crouch = false
		_serve_go = false
		_hop_straight = false
		_power_run = false
		_run_go = false
		if serving:
			_move_target = me.global_position




			if not _serve_rolled:
				_serve_rolled = true
				_serve_jump = randf() < serve_jump_chance
				_serve_float = _serve_jump and randf() < serve_float_chance
				_serve_run = _serve_jump and randf() < serve_run_chance


			if _serve_run:
				_move_target = Vector3(me.global_position.x, 0.0, 
					float(me.team_side) * (_half_l + SERVE_RUN_BACK))
		else:





			_move_target = _serve_formation_spot(float(me.team_side))
		_steer(input, me, allies)
		if _holding:
			input.contact_released = true
			if DEBUG_AI: _letgo_line = get_stack()[0].line
			_holding = false
		if _set_holding:
			input.set_released = true
			_set_holding = false
			_set_hold_time = 0.0
		return input
	_serve_rolled = false












	_raw_touch_count = touch_count






	if _awaiting_serve and touch_count >= 1 and ball != null\
	and ball.strike_source != null and is_instance_valid(ball.strike_source):
		_awaiting_serve = false
		if ball.strike_source.team_side != me.team_side:
			_serve_flight = ball.strike_seq






	if responsibility_side != me.team_side\
	or (ball != null and ball.last_hit_kind == Player.TouchKind.BLOCK):
		touch_count = 0
	_touch_cooldown = maxf(_touch_cooldown - delta, 0.0)
	_react_delay = maxf(_react_delay - delta, 0.0)
	_wander_timer -= delta
	if _wander_timer <= 0.0:



		_wander_timer = randf_range(1.8, 3.0)
		_wander = Vector2(randf_range(-0.25, 0.25), randf_range(-0.16, 0.16))
	_think_timer -= delta


	if touch_count != _last_touch_count:
		_last_touch_count = touch_count
		_think_timer = 0.0











		if me.is_on_floor() and not _quick_jump and not _block_jump\
		and not _serve_crouch:
			if _jump_hold > 0.0:
				input.jump_cancelled = true
			_jump_hold = 0.0
			_hop_straight = false
			_run_go = false



		_prev_ball_dist = INF
		if _set_holding:
			input.set_released = true
			_set_holding = false
			_set_hold_time = 0.0



		_second_ball_roll = randf() < SECOND_BALL_CHANCE
		_rare_counter_roll = randf() < RARE_COUNTER_CHANCE
	if _think_timer <= 0.0:


		_think_timer = THINK_INTERVAL * think_mult * (0.35 if _serve_read else 1.0)
		_decide(me, allies, opponents, ball, touch_count, responsibility_side)








	if _block_jump and me.is_on_floor() and _jump_hold > 0.0\
	and _block_beaten(me, ball):
		input.jump_cancelled = true
		_jump_hold = 0.0
		_block_jump = false
		_mode = MODE_DEFEND
		_decide(me, allies, opponents, ball, touch_count, responsibility_side)















	if _serving and touch_count == 0:
		var side: = float(me.team_side)


		var back: = SERVE_RUN_TAKEOFF if _serve_run and _serve_jump\
		else SERVE_STAND_BACK
		if _move_target.z * side < _half_l + back:
			_move_target.z = side * (_half_l + back)
	_steer(input, me, allies)







	if not me.is_on_floor():
		input.move = Vector2.ZERO
	input.aim = _aim
	if _reflex_touch(input, me, allies, ball, touch_count):
		_run_jump(input, delta)
		return input
	if _quick_armed and _mode == MODE_SUPPORT and me.is_on_floor()\
	and _jump_hold <= 0.0:
		var near_spot: = Vector2(_move_target.x - me.global_position.x, 
			_move_target.z - me.global_position.z).length() < 0.9


		if near_spot and ball.global_position.y > 1.2\
		and ball.global_position.y < 2.8 and ball.vel.y < 3.0\
		and Vector2(me.velocity.x, me.velocity.z).length() < 3.0:
			_quick_armed = false
			_quick_jump = true
			_quick_seq = ball.strike_seq
			_jump_hold = JUMP_HOLD_ATTACK


	if _react_delay > 0.0 and not (_serving and touch_count == 0):

		_run_jump(input, delta)
		return input
	if _set_holding and not (_mode == MODE_RECEIVE and not _attacking):




		input.set_released = true
		_set_holding = false
		_set_hold_time = 0.0
	if _mode == MODE_RECEIVE and _attacking:
		_attack(input, me, ball, delta)



		if _serving and touch_count == 0 and _serve_float and not me.is_on_floor():
			input.move = Vector2(0.0, float(me.team_side))
	elif _mode == MODE_RECEIVE:
		_maybe_dive(input, me, ball)
		if not _dedicated_set(input, me, allies, ball, touch_count, delta):
			_ground_touch(input, me, ball)
	elif _mode == MODE_BLOCK:
		_block(input, me, ball, delta)
	elif _holding and not (_ball_coming_to_me(me, ball) and HOLD_KEEP_ENABLED):
		input.contact_released = true
		if DEBUG_AI: _letgo_line = get_stack()[0].line
		_holding = false
	_run_jump(input, delta)
	return input

func distract(duration: float) -> void :
	_react_delay = maxf(_react_delay, duration)

func _decide(me: Player, allies: Array, opponents: Array, ball: Ball, 
		touch_count: int, responsibility_side: int) -> void :






	if touch_count > 0:
		_update_row(me, allies)
	if touch_count != 1:
		_quick_armed = false
	if not me.is_on_floor() and _mode == MODE_RECEIVE:


		_move_target = _predict_at_height(ball, ATTACK_MEET_H, float(me.team_side))\
		if _attacking else _predict_landing(ball, float(me.team_side))
		return
	var side: = float(me.team_side)
	var ball_side: = signf(ball.global_position.z)
	var incoming: = ball_side == side or ball.vel.z * side > 0.5
	if _solo:
		_read_solo_attack(opponents, ball, side)



	var committed_last_touch_attack: = _mode == MODE_RECEIVE and _attacking\
	and touch_count >= 2
	if not committed_last_touch_attack:
		_power_run = false
	_attacking = false
	_threat = null
	_our_ball = false
	if incoming:





		var our_fault: = responsibility_side == me.team_side
		_our_ball = our_fault
		var landing: = _predict_landing(ball, side, 
			OWN_FAULT_APRON if our_fault else 3.5)
		var eta: = _time_to_height(ball, 1.0)













		if _team_serving and not _serving and ball_side == side:
			_mode = MODE_IDLE
			_move_target = _defend_spot(me, side, ball)
			me.claiming = false
			return
		if _opp_serve_in_flight(ball) and not _serving and ball_side != side:
			_read_serve(landing)








		if touch_count == 0 and not _serving\
		and responsibility_side != me.team_side\
		and ball.vel.z * side > 0.5\
		and not _landing_in_bounds(landing, 0.5):
			if DEBUG_AI:
				print("[OUTIDLE] %s ballz=%.1f side=%d lastside=%d land=(%.1f,%.1f)" % [
					me.name, ball.global_position.z, me.team_side, responsibility_side, 
					landing.x, landing.z])
			_mode = MODE_IDLE
			_move_target = _defend_spot(me, side, ball)
			me.claiming = false
			return





		var overpass_ok: = ball_side == side or _predict_at_height(ball, 
			ATTACK_MEET_H, side).z * side >= OVERPASS_ATTACK_MARGIN
		var last_touch_attack: = _last_touch_attackable(ball, side) and overpass_ok
		var receive_spot: = landing
		var receive_eta: = eta
		if touch_count >= 2 and last_touch_attack:
			receive_spot = _predict_at_height(ball, ATTACK_MEET_H, side)
			receive_eta = _time_to_height(ball, ATTACK_MEET_H)







		var receiver: Player = me if (_serving and touch_count == 0)\
		else _pick_receiver(me, allies, receive_spot, receive_eta, touch_count)
		if DEBUG_AI and receiver != me and _mode == MODE_RECEIVE and ball.vel.y < 1.5:



			var my_d: = Vector2(receive_spot.x - me.global_position.x, 
				receive_spot.z - me.global_position.z).length()
			var rn: = ("NONE" if receiver == null else str(receiver.name))
			print("[ABANDON] %s d=%.1f -> %s | ballz=%.1f side=%d lastside=%d tc=%d inb=%s spot=(%.1f,%.1f)" % [
				me.name, my_d, rn, ball.global_position.z, me.team_side, 
				responsibility_side, touch_count, str(_landing_in_bounds(receive_spot)), 
				receive_spot.x, receive_spot.z])
		if receiver == me:
			_mode = MODE_RECEIVE














			var set_target: = _pick_attacker(me, allies)
			var has_set_target: = not _solo and set_target != null\
			and not set_target.knocked()
			var counter_spike: = touch_count == 1 and not _solo\
			and not has_set_target\
			and persona == Persona.AGGRESSIVE and difficulty_level >= 1\
			and _second_ball_roll and _attackable(ball, side)
			var rare_counter: = touch_count == 1 and has_set_target\
			and persona == Persona.AGGRESSIVE and difficulty_level >= 2\
			and _second_ball_roll and _rare_counter_roll\
			and _attackable(ball, side) and _airborne_ally(allies, side) == null
			var second_ball: = counter_spike or rare_counter


			var received_set: = touch_count >= 2 and overpass_ok\
			and ball.last_hit_kind == Player.TouchKind.SET








			var human_set_up: = touch_count == 1 and not _solo\
			and ball.last_hit_kind == Player.TouchKind.SET\
			and ball.strike_source != null and not ball.strike_source.is_bot\
			and _attackable(ball, side)
			_attacking = (touch_count >= 2\
			and (committed_last_touch_attack\
			or last_touch_attack or received_set))\
			or (_serving and touch_count == 0 and _serve_jump)\
			or second_ball or human_set_up



			if _attacking and not committed_last_touch_attack:
				_move_target = _predict_at_height(ball, ATTACK_MEET_H, side)





				var apex: = ball.global_position.y
				if ball.vel.y > 0.0:
					apex += (ball.vel.y * ball.vel.y) / (2.0 * Ball.PHYS.gravity)
				_tempo_float = apex > SET_FLOAT_APEX
			elif not _attacking:








				if touch_count == 1:
					_move_target = _predict_at_height(ball, SET_APPROACH_H, side)
				else:
					_move_target = landing
			_aim = _touch_aim(me, allies, opponents, ball, touch_count, side)
			if not _attacking:
				_power_run = false
			elif not committed_last_touch_attack:


				_power_run = _want_power_run(me, ball, allies, opponents, touch_count, side)
				_run_go = false




			_press_dist = SERVE_STAND_PRESS_DIST\
			if _serving and touch_count == 0 and not _serve_jump\
			else _power_press_dist(landing)
		elif _pick_support(me, allies, receiver, touch_count) == me:

			_mode = MODE_SUPPORT
			_move_target = _clear_of(_support_spot(me, ball, touch_count, side), landing)




			if CPU_QUICK_SET_ENABLED and touch_count == 1 and not _quick_armed:





				var human_setter: bool = receiver != null\
				and is_instance_valid(receiver) and not receiver.is_bot
				if (human_setter and randf() < 0.6)\
				or (persona == Persona.AGGRESSIVE and difficulty_level >= 1\
				and randf() < quick_chance):
					_quick_armed = true
		else:
			_mode = MODE_DEFEND



			_cover = Vector2.ZERO if _solo else _cover_shift(me, allies, side)
			_rebound_z = _rebound_dropback(opponents, ball) if _front_row else 0.0
			_move_target = _clear_of(_defend_spot(me, side, ball), landing)
	else:





		var serve_incoming: = (_raw_touch_count == 0 or _opp_serve_in_flight(ball))\
		and not _serving








		var their_ball: = responsibility_side != me.team_side
		var threats: = [] if (serve_incoming or _solo)\
		else _find_threats(opponents, ball, their_ball)
		_threat = _assign_block(me, allies, threats)
		if _threat != null:

			_mode = MODE_BLOCK





			var lane_x: = _threat.global_position.x
			var tz: = _threat.global_position.z
			var az: = _threat.aim_point.z
			if signf(az) != signf(tz) and absf(tz - az) > 0.1:
				lane_x = lerpf(_threat.global_position.x, _threat.aim_point.x, 
					tz / (tz - az))




			for p in allies:
				var mate: Player = p
				if mate.is_bot:
					continue
				var mz: = absf(mate.global_position.z)
				var m_blocking: bool = mz < 2.8 and ( not mate.is_on_floor()\
				or mate._jump_charge > 0.02 or mz < 1.6)
				if m_blocking and absf(lane_x - mate.global_position.x) < BLOCK_WALL_GAP:
					var dir: = signf(lane_x - mate.global_position.x)
					if dir == 0.0:
						dir = signf(_threat.global_position.x - mate.global_position.x)
					if dir == 0.0:
						dir = 1.0
					lane_x = mate.global_position.x + dir * BLOCK_WALL_GAP
			_move_target = Vector3(
				clampf(lane_x, _cx - _half_w + 0.5, _cx + _half_w - 0.5), 
				0.0, side * 1.1)

			_block_deflect_aim = _open_court_target(opponents, side, 1.5, 
				_half_l - 2.0)


			_aim = _threat.global_position
		elif threats.size() > 0:


			_mode = MODE_DEFEND
			_move_target = _defend_spot(me, side, ball)
		else:
			_mode = MODE_IDLE
			_move_target = _defend_spot(me, side, ball)
	me.claiming = _mode == MODE_RECEIVE






	if me.touch_barred_self and _mode != MODE_RECEIVE and incoming and me.is_on_floor():
		var drop: = _predict_landing(ball, side)
		var away: = Vector2(me.global_position.x - drop.x, 
			me.global_position.z - drop.z)
		if away.length() < 1.6:
			var dir: = away.normalized() if away.length() > 0.05 else Vector2(1.0, 0.0)
			_move_target = Vector3(me.global_position.x + dir.x * 2.0, 0.0, 
				me.global_position.z + dir.y * 2.0)








const SERVE_SHADE: = 0.2
const SERVE_SHADE_SOLO: = 0.35
const SERVE_SHADE_REPEAT: = 0.15
const SERVE_SHADE_MAX: = 0.45
const SERVE_SHADE_MAX_SOLO: = 0.8

func _serve_shade(spot: Vector3) -> Vector3:
	if _serve_book.is_empty():
		return spot
	var mean: = Vector3.ZERO
	for entry in _serve_book:
		mean += entry as Vector3
	mean /= float(_serve_book.size())
	var pull: = SERVE_SHADE_SOLO if _solo else SERVE_SHADE





	var repeats: = 0
	for entry in _serve_book:
		if (entry as Vector3).distance_to(mean) < SERVE_SAME_DIST:
			repeats += 1
	pull = minf(pull + SERVE_SHADE_REPEAT * maxf(float(repeats - 1), 0.0), 
		SERVE_SHADE_MAX_SOLO if _solo else SERVE_SHADE_MAX)
	return Vector3(lerpf(spot.x, mean.x, pull), 0.0, lerpf(spot.z, mean.z, pull))








func _serve_formation_spot(side: float) -> Vector3:
	var lane_x: = _cx + lerpf( - _half_w + 1.6, _half_w - 1.6, _slot_frac) * side
	var z: = (_half_l * 0.45) if _solo else (1.8 if _front_row else _half_l * 0.65)
	var spot: = _serve_shade(Vector3(lane_x, 0.0, side * z))
	spot.x += _wander.x * 0.4
	spot.z += side * _wander.y * 0.4
	return spot

func _read_serve(landing: Vector3) -> void :
	if _serve_logged:
		return
	_serve_logged = true
	for spot in _serve_book:
		if (spot as Vector3).distance_to(landing) < SERVE_SAME_DIST:
			_serve_read = true
			break
	_serve_book.push_back(landing)
	if _serve_book.size() > SERVE_BOOK_MAX:
		_serve_book.pop_front()





const SECOND_BALL_DEPTH: = 3.4
const SECOND_BALL_MEET_H: = 2.7

func _attackable(ball: Ball, side: float) -> bool:




	if not attack_apex_ok(ball):
		return false


	var meet: = _predict_at_height(ball, SECOND_BALL_MEET_H, side)
	return absf(meet.z) <= SECOND_BALL_DEPTH

static func attack_apex_ok(ball: Ball) -> bool:
	var apex: = ball.global_position.y
	if ball.vel.y > 0.0:
		apex += (ball.vel.y * ball.vel.y) / (2.0 * Ball.PHYS.gravity)
	return apex >= SECOND_BALL_MEET_H




static func set_attackable(ball: Ball, side: float) -> bool:
	if not attack_apex_ok(ball):
		return false
	var probe: = flight_point_at_height(ball, SECOND_BALL_MEET_H)
	if not bool(probe.found):
		return false
	var meet: Vector3 = probe.point
	return meet.z * side >= 0.0 and absf(meet.z) <= SECOND_BALL_DEPTH

func _last_touch_attackable(ball: Ball, side: float) -> bool:
	var apex: = ball.global_position.y
	if ball.vel.y > 0.0:
		apex += (ball.vel.y * ball.vel.y) / (2.0 * Ball.PHYS.gravity)
	if apex < ATTACK_MEET_H:
		return false
	var meet: = _predict_at_height(ball, ATTACK_MEET_H, side)
	return meet.z * side >= 0.0 and absf(meet.z) <= LAST_TOUCH_ATTACK_DEPTH

func _landing_in_bounds(landing: Vector3, margin: = 0.2) -> bool:




	return absf(landing.x - _cx) <= _half_w + margin\
	and absf(landing.z) <= _half_l + margin

func _power_press_dist(landing: Vector3) -> float:


	var aim_dist: = Vector2(_aim.x - landing.x, _aim.z - landing.z).length()


	var want: = clampf((aim_dist / 14.0 + 0.3 * aggression) * power_bias, 
		0.12, 0.95)
	return lerpf(1.9, 3.6, want)

func _touch_aim(me: Player, allies: Array, opponents: Array, _ball: Ball, 
		touch_count: int, side: float) -> Vector3:
	var err: = Vector3(randf_range( - AIM_ERROR, AIM_ERROR), 0.0, 
		randf_range( - AIM_ERROR, AIM_ERROR))\
		* (1.0 - 0.6 * aggression) * aim_error_mult
	if _serving and touch_count == 0:




		return _safe_serve_target(_open_court_target(opponents, side, 3.0, 
			minf(_half_l - 2.5, 9.5)) + err, side)
	match touch_count:
		0:





			if _solo:
				return _self_feed(me, side)



			var mate: = _nearest_available_ally(me, allies)
			if mate == null and not allies.is_empty():
				return _open_court_target(opponents, side, 2.0, _half_l - 1.5) + err
			var x: = clampf(mate.global_position.x, _cx - _half_w + 1.5, 
				_cx + _half_w - 1.5) if mate != null else _cx
			return Vector3(x, 0.0, side * NET_PLAY_Z) + err * 0.5
		1:




			if _attacking:
				return _open_court_target(opponents, side, 2.0, _half_l - 1.5) + err

			if _solo:
				return _self_feed(me, side)


			if persona == Persona.AGGRESSIVE and difficulty_level >= 1\
			and randf() < dump_chance * 0.55:
				return _open_court_target(opponents, side, 1.8, 4.0) + err * 0.5


			var airborne: = _airborne_ally(allies, side)
			var attacker: = airborne if airborne != null else _pick_attacker(me, allies)
			if attacker == null and not allies.is_empty():



				return _open_court_target(opponents, side, 2.0, _half_l - 1.5) + err
			var x: = clampf(attacker.global_position.x, _cx - _half_w + 1.0, 
				_cx + _half_w - 1.0) if attacker != null else _cx



			var spread: = 0.0 if airborne != null else randf_range( - SET_SPREAD, SET_SPREAD)




			var depth: float
			if airborne != null:
				depth = side * clampf(absf(airborne.global_position.z), 0.9, 3.2)
			else:
				depth = side * (NET_PLAY_Z + randf_range(0.0, SET_DEPTH_VARY))
			var set_aim: = Vector3(clampf(x + spread, _cx - _half_w + 1.0, 
				_cx + _half_w - 1.0), 0.0, depth) + err * 0.5
			if airborne != null or me == null:
				return set_aim




			return me.set_pocket_point(set_aim)

	return _open_court_target(opponents, side, 2.2, _half_l - 1.5) + err

func _safe_serve_target(target: Vector3, side: float) -> Vector3:
	target.x = clampf(target.x, _cx - _half_w + 0.8, _cx + _half_w - 0.8)
	var far_z: = - side * (_half_l - 1.2)
	var short_z: = - side * 2.5
	target.z = clampf(target.z, minf(far_z, short_z), maxf(far_z, short_z))
	return target




const SELF_FEED_PULL: = 0.55
const SELF_FEED_MIN_Z: = 1.3

func _self_feed(me: Player, side: float) -> Vector3:
	var here: = me.global_position
	var z: = absf(here.z)
	var want_z: = maxf(lerpf(z, NET_PLAY_Z, SELF_FEED_PULL), SELF_FEED_MIN_Z)
	return Vector3(
		clampf(here.x, _cx - _half_w + 1.0, _cx + _half_w - 1.0), 
		0.0, side * want_z)

func _open_court_target(opponents: Array, side: float, min_depth: float, 
		max_depth: float) -> Vector3:



	var best: = Vector3(_cx, 0.0, - side * (min_depth + max_depth) * 0.5)
	var best_score: = - INF
	for i in 8:
		var candidate: = Vector3(
			_cx + randf_range( - _half_w + 1.2, _half_w - 1.2), 0.0, 
			- side * randf_range(min_depth, max_depth))
		var nearest: = INF
		for p in opponents:
			var opp: Player = p
			nearest = minf(nearest, Vector2(
				candidate.x - opp.global_position.x, 
				candidate.z - opp.global_position.z).length())
		var score: = nearest + absf(candidate.z) * 0.3
		if score > best_score:
			best_score = score
			best = candidate
	return best

func _support_spot(me: Player, ball: Ball, touch_count: int, side: float) -> Vector3:
	if touch_count == 0:

		return Vector3(
			_cx + clampf((ball.global_position.x - _cx) * 0.3, -2.0, 2.0), 
			0.0, side * NET_PLAY_Z)
	if touch_count == 1:







		var approach_x: = lerpf(me.global_position.x, _cx, 0.45)
		return Vector3(clampf(approach_x, _cx - _half_w + 1.2, 
			_cx + _half_w - 1.2), 0.0, side * (NET_PLAY_Z + 0.5))
	return _defend_spot(me, side, ball)

const ROWS_FOLLOW_HUMAN: = false

func _update_row(me: Player, allies: Array) -> void :



	var human: Player = null
	for p in allies:
		if not (p as Player).is_bot:
			human = p
	if human == null:
		return
	var hz: float = absf(human.global_position.z)
	if hz < _half_l * 0.4:
		_human_front = true
	elif hz > _half_l * 0.52:
		_human_front = false







	if _solo or not ROWS_FOLLOW_HUMAN:
		return
	var n: = allies.size() + 1
	var front_q: = maxi(1, int(n / 2.0))
	var front_needed: = front_q - (1 if _human_front else 0)
	var bots: Array = ([me] + allies).filter( func(o): return o.is_bot)
	bots.sort_custom( func(a, b): return a.get_instance_id() < b.get_instance_id())
	var my_idx: = bots.find(me)
	_front_row = my_idx < front_needed
	if _front_row:
		_slot_frac = (float(my_idx) + 0.5) / float(maxi(front_needed, 1))
	else:
		var back_idx: = my_idx - maxi(front_needed, 0)
		var back_count: = bots.size() - maxi(front_needed, 0)
		_slot_frac = (float(back_idx) + 0.5) / float(maxi(back_count, 1))




const COVER_GAP: = 1.6
const COVER_PULL: = 0.55

func _cover_shift(me: Player, allies: Array, side: float) -> Vector2:



	var front_edge: = _half_l * 0.4
	var mates_front: = 0
	var mates_back: = 0
	var hole_x: = _cx
	for a in allies:
		var mate: Player = a
		if mate == null or not is_instance_valid(mate):
			continue
		if absf(mate.global_position.z) < front_edge:
			mates_front += 1
		else:
			mates_back += 1
			hole_x = mate.global_position.x
	var shift: = Vector2.ZERO


	if _front_row and mates_back == 0 and mates_front > 0:
		shift.y = COVER_GAP
	elif not _front_row and mates_front == 0 and mates_back > 0:
		shift.y = - COVER_GAP

	if shift.y != 0.0:
		var lane: = _cx + lerpf( - _half_w + 1.6, _half_w - 1.6, _slot_frac) * side
		shift.x = (hole_x - lane) * COVER_PULL
	return shift




func _rebound_dropback(opponents: Array, ball: Ball) -> float:
	for o in opponents:
		var foe: Player = o
		if foe == null or not is_instance_valid(foe):
			continue
		if foe.contact_state == Player.ContactState.WINDUP and not foe.grounded() and absf(ball.global_position.z) < 5.0:
			return 1.15
	return 0.0










func _read_solo_attack(opponents: Array, ball: Ball, side: float) -> void :
	var lo: = _cx - _half_w + 1.6
	var hi: = _cx + _half_w - 1.6
	_solo_shade_x = clampf(ball.global_position.x, lo, hi)
	_solo_shade_w = SOLO_BALL_WEIGHT
	var loading: = false
	for o in opponents:
		var foe: Player = o
		if foe == null or not is_instance_valid(foe):
			continue
		var winding: = foe.contact_state == Player.ContactState.WINDUP
		if not (foe._jump_charge > 0.05 or not foe.grounded() or winding):
			continue
		if signf(ball.global_position.z) == side\
		or absf(foe.global_position.z) > _half_l * 0.6:
			continue
		loading = true
		if not _foe_loading:


			_attack_read_err = randf_range(-1.0, 1.0) * AIM_ERROR * aim_error_mult
		if foe.aim_point.z * side > 0.0:
			_solo_shade_x = clampf(foe.aim_point.x + _attack_read_err, lo, hi)
			_solo_shade_w = SOLO_READ_WEIGHT
		break
	_foe_loading = loading

func _defend_spot(_me: Player, side: float, ball: Ball) -> Vector3:




	var lane_x: = _cx + lerpf( - _half_w + 1.6, _half_w - 1.6, _slot_frac) * side
	var shade_x: = clampf(ball.global_position.x, _cx - _half_w + 1.6, 
		_cx + _half_w - 1.6)




	var x: = lerpf(lane_x, _solo_shade_x, _solo_shade_w) if _solo\
	else lerpf(lane_x, shade_x, 0.25)
	x += _wander.x
	var z: = (_half_l * 0.45) if _solo else (1.7 if _front_row else _half_l * 0.62)
	x += _cover.x
	z += _cover.y + _rebound_z
	return Vector3(x, 0.0, side * z + side * _wander.y)

func _pick_receiver(me: Player, allies: Array, landing: Vector3, 
		eta: float, touch_count: int) -> Player:



	var best: Player = null
	var best_d: = INF
	for p in [me] + allies:
		var member: Player = p









		if member.touch_barred_self or member.knocked():
			continue






		if not _can_get_there(member, Vector2(landing.x - member.global_position.x, 
				landing.z - member.global_position.z).length(), eta):
			continue








		if member.contact_state == Player.ContactState.RECOVER\
		and not member.contact_intent_queued():
			continue







		var air_play: = false
		if not member.is_bot and not member.is_on_floor():
			air_play = _human_air_play(member)
			if not air_play:
				continue
		var to_landing: = Vector2(landing.x - member.global_position.x, 
			landing.z - member.global_position.z)
		var d: = to_landing.length()
		if air_play:
			best_d = - INF
			best = member
			continue







		if _ball != null and _ball.global_position.y < 2.2 and _ball.vel.y < 1.5:
			var to_ball: = Vector2(_ball.global_position.x - member.global_position.x, 
				_ball.global_position.z - member.global_position.z).length()
			d = minf(d, to_ball)
		if not member.is_bot:








			var mv: = Vector2(member.velocity.x, member.velocity.z)
			var approaching: = mv.length() > 1.0 and d > 0.1 and mv.normalized().dot(to_landing.normalized()) > 0.3








			var committed: = approaching or member.contact_intent_queued()\
			or member._jump_charge > 0.05 or member.charging_set()
			var reach_range: = (6.0 * eta + 2.5) if committed else (3.0 * eta + 1.2)
			if approaching or d < reach_range:
				var pri: = HUMAN_PRIORITY * (2.0 if touch_count == 1 else 1.0)






				if not committed:
					pri *= 0.25
				d -= pri
		var speed: = Vector2(member.velocity.x, member.velocity.z)
		if speed.length() > 1.5 and d > 0.1:
			d -= maxf(speed.normalized().dot(to_landing.normalized()), 0.0)\
			* (2.0 if not member.is_bot else 1.0)





		if member.claiming and to_landing.length() < 6.0 * eta + 2.5:
			d -= 1.2
		if d < best_d:
			best_d = d
			best = member
	return best





const MATE_REACH_ARMS: = 1.1
func _can_get_there(member: Player, dist: float, eta: float) -> bool:

	var down: = member.getting_up()
	if not member.stamina_locked and not down:
		return true
	if member.stamina_locked and member.getting_up():
		return dist < MATE_REACH_ARMS * 0.6
	var t: = maxf(eta, 0.0)
	if down:
		t -= Player.FEEL.getup_time
	var walk: = Player.FEEL.move_speed * maxf(t - RUN_SETTLE, 0.0)
	return dist < walk + MATE_REACH_ARMS





const AIR_PLAY_FLAT: = 1.9
const AIR_PLAY_ABOVE: = 2.6
func _human_air_play(member: Player) -> bool:
	if _ball == null or not is_instance_valid(_ball) or _ball.frozen:
		return false
	if member.contact_state == Player.ContactState.BLOCK:
		return false
	var side: = float(member.team_side)
	if _ball.global_position.z * side < 0.0:
		return false
	var flat: = Vector2(_ball.global_position.x - member.global_position.x, 
		_ball.global_position.z - member.global_position.z).length()
	if flat < AIR_PLAY_FLAT\
	and _ball.global_position.y - member.global_position.y < AIR_PLAY_ABOVE:
		return true


	var probe: = flight_point_at_height(_ball, member.global_position.y + AIR_PLAY_ABOVE)
	if not bool(probe.found):
		return false
	var at: Vector3 = probe.point
	return Vector2(at.x - member.global_position.x, 
		at.z - member.global_position.z).length() < AIR_PLAY_FLAT

func _pick_support(me: Player, allies: Array, receiver: Player, 
		touch_count: = 0) -> Player:


	var best: Player = null
	var best_d: = INF
	var net_spot: = Vector3(0.0, 0.0, float(me.team_side) * NET_PLAY_Z)
	for p in [me] + allies:
		var member: Player = p
		if member == receiver or member.knocked():
			continue





		if not member.is_bot and not member.is_on_floor() and touch_count == 1:
			continue






		if member.touch_barred and not (_pair and touch_count == 1):
			continue



		var eta_spot: = _time_to_height(_ball, SET_APPROACH_H)\
		if _ball != null and is_instance_valid(_ball) else 1.5
		if eta_spot == INF:
			eta_spot = 1.5
		if not _can_get_there(member, Vector2(net_spot.x - member.global_position.x, 
				net_spot.z - member.global_position.z).length(), eta_spot):
			continue
		var d: = member.global_position.distance_to(net_spot)
		if not member.is_bot:
			d -= 0.8
		if d < best_d:
			best_d = d
			best = member
	return best

func _clear_of(spot: Vector3, landing: Vector3) -> Vector3:

	var away: = Vector2(spot.x - landing.x, spot.z - landing.z)
	if away.length() < 1.6:
		spot.x += 1.8 * (signf(away.x) if away.x != 0.0 else 1.0)
	return spot

func _nearest_ally(me: Player, allies: Array) -> Player:
	var best: Player = null
	var best_d: = INF
	for p in allies:
		var member: Player = p
		var d: = member.global_position.distance_to(me.global_position)
		if d < best_d:
			best_d = d
			best = member
	return best






func _nearest_available_ally(me: Player, allies: Array) -> Player:
	var best: Player = null
	var best_d: = INF
	for p in allies:
		var member: Player = p
		if member == null or not is_instance_valid(member):
			continue
		if member.stamina_locked or member.diving() or member.getting_up()\
		or member.knocked():
			continue
		var d: = member.global_position.distance_to(me.global_position)
		if d < best_d:
			best_d = d
			best = member
	return best

func _pick_attacker(me: Player, allies: Array) -> Player:



	if allies.is_empty():
		return null
	var best: Player = null
	var best_z: = INF
	for p in allies:
		var member: Player = p
		if member == null or not is_instance_valid(member)\
		or member.knocked() or member.contact_state == Player.ContactState.RECOVER:
			continue





		if member.diving() or member.getting_up():
			continue





		if member.stamina_locked:
			continue
		var pocket: = Vector3(clampf(member.global_position.x, 
			_cx - _half_w + 1.0, _cx + _half_w - 1.0), 0.0, 
			signf(member.global_position.z) * NET_PLAY_Z)
		var run: = Vector2(pocket.x - member.global_position.x, 
			pocket.z - member.global_position.z).length()
		var off_court: = absf(member.global_position.x - _cx) > _half_w + 1.0\
		or absf(member.global_position.z) > _half_l + 1.0
		if run > SET_REACH_RUN or off_court:
			continue
		var z: = absf(member.global_position.z)




		if not member.is_bot:
			var mv: = member.velocity
			var to_net: = - signf(member.global_position.z) * mv.z > 1.0
			var in_range: = z < _half_l * 0.7
			if (in_range or to_net) and member.is_on_floor():
				z -= HUMAN_SET_BIAS
		if z < best_z:
			best_z = z
			best = member
	return best

func _hitter_rising(allies: Array, side: float) -> bool:





	for p in allies:
		var m: Player = p
		if m == null or not is_instance_valid(m) or m.knocked():
			continue
		if m.is_on_floor() or m.velocity.y <= 0.1:
			continue
		if m.global_position.y >= 0.45 or m.global_position.y < 0.12:
			continue
		if m.global_position.z * side < -0.25:
			continue
		return true
	return false

func _airborne_ally(allies: Array, side: float) -> Player:



	var best: Player = null
	var best_d: = INF
	for p in allies:
		var member: Player = p
		if member == null or not is_instance_valid(member) or member.knocked():
			continue



		if member.is_on_floor() or member.global_position.y < 0.45\
		or member.global_position.z * side < -0.25\
		or member.contact_state == Player.ContactState.RECOVER\
		or member.contact_state == Player.ContactState.BLOCK:
			continue
		var d: = absf(member.global_position.z)
		if d < best_d:
			best_d = d
			best = member
	return best

func _find_threats(opponents: Array, ball: Ball, grounded_ok: = true) -> Array:







	var threats: Array = []
	var meet: = Vector3.INF
	if not opponents.is_empty():
		meet = _predict_at_height(ball, ATTACK_MEET_H, 
			float((opponents[0] as Player).team_side))
	for p in opponents:
		var opp: Player = p
		if absf(opp.global_position.z) > 4.0:
			continue
		if ball.global_position.z * float(opp.team_side) < 0.0:
			continue
		if ball.global_position.y < 1.6:
			continue
		if opp.is_on_floor():


			if not grounded_ok or meet == Vector3.INF:
				continue
			var away: = Vector2(meet.x - opp.global_position.x, 
				meet.z - opp.global_position.z).length()
			if away > 2.4:
				continue
		threats.append(opp)
	return threats

func _assign_block(me: Player, allies: Array, threats: Array) -> Player:




	if threats.is_empty():
		return null
	var n: = allies.size() + 1
	var defenders: Array = []
	var human_committed: = false
	for p in [me] + allies:
		var member: Player = p
		if member.is_bot:
			continue






		var z: = absf(member.global_position.z)
		var committed: = z < 2.8 and ( not member.is_on_floor()
			or member._jump_charge > 0.02 or z < 1.6)
		if committed:
			defenders.append(member)
			human_committed = true


	if n <= 3 and human_committed:
		return null



	var bots: Array = ([me] + allies).filter( func(o):
		return o.is_bot and absf(o.global_position.z) < 4.5)
	bots.sort_custom( func(a, b): return a.get_instance_id() < b.get_instance_id())
	defenders.append_array(bots)
	var claims: = {}
	var mine: Player = null
	for d in defenders:
		var defender: Player = d
		var best: Player = null
		var best_dx: = INF
		for t in threats:
			var threat: Player = t
			var dx: = absf(threat.global_position.x - defender.global_position.x)
			var on_it: = int(claims.get(threat, 0))
			if on_it >= 1:



				if not (defender.is_bot and n >= 6 and threats.size() == 1
						and on_it < 2 and dx < 2.0):
					continue



			if not defender.is_bot and dx > 2.2:
				continue
			if dx < best_dx:
				best_dx = dx
				best = threat
		if best == null:
			continue
		claims[best] = int(claims.get(best, 0)) + 1
		if defender == me:
			mine = best
	return mine

func _steer(input: PlayerInput, me: Player, allies: Array) -> void :


	var arrive: = ARRIVE_RADIUS
	if _mode == MODE_SUPPORT:
		arrive = 0.4
	elif _mode == MODE_DEFEND or _mode == MODE_IDLE:
		arrive = 0.6
	var desired: = Vector3.ZERO
	var to_target: = _move_target - me.global_position
	to_target.y = 0.0






	var dist: = to_target.length()
	var can_park: = _mode == MODE_IDLE or _mode == MODE_DEFEND or _mode == MODE_SUPPORT
	if can_park:
		if _parked:
			if dist > arrive + PARK_HYSTERESIS:
				_parked = false
		elif dist <= arrive:
			_parked = true
	else:
		_parked = false
	if not _parked and dist > arrive:
		desired = to_target.normalized()

	var sep: = Vector3.ZERO
	for p in allies:
		var member: Player = p




		if _mode == MODE_RECEIVE:
			var mate_on_spot: = Vector2(_move_target.x - member.global_position.x, 
				_move_target.z - member.global_position.z).length() < 1.5
			if member.touch_barred or mate_on_spot:
				continue
		var away: = me.global_position - member.global_position
		away.y = 0.0
		var d: = away.length()
		if d > 0.05 and d < 1.3:
			sep += away.normalized() * (1.3 - d)
	desired += sep * (0.4 if _mode == MODE_RECEIVE else 1.0)
	if desired.length() > 0.05:
		desired = desired.limit_length(1.0)
		input.move = Vector2(desired.x, desired.z)
	var attack_approach: = _mode == MODE_RECEIVE and _attacking\
	and _last_touch_count >= 2




















	var brake_speed: = Vector2(me.velocity.x, me.velocity.z).length()
	var decel: float = Player.FEEL.accel_stop * Player.FEEL.strafe_stop
	var stop_dist: = brake_speed * brake_speed / maxf(2.0 * decel, 0.1)
	if _jump_hold > 0.0:
		_braking = false
	elif _braking:
		if brake_speed < 0.4 or dist > stop_dist + arrive + 0.5:
			_braking = false
	elif desired.length() > 0.05 and brake_speed > 1.2\
	and dist <= stop_dist + arrive:
		_braking = true
	if _braking:
		input.move = Vector2.ZERO
		input.strafe_held = true











	var chase_gap: float = [4.5, 3.4, 2.6][difficulty_level]








	var attack_run: = false




	var need_chase: = to_target.length() > chase_gap
	if _ball != null and is_instance_valid(_ball):
		var budget: = _time_to_height(_ball, 0.9)
		if budget > 0.05 and budget < INF:

			need_chase = to_target.length() > Player.FEEL.move_speed * budget * 0.9
	var want_sprint: = need_chase or attack_run








	var all_out: = _mode == MODE_RECEIVE and _our_ball and need_chase
	var stam_ok: = not me.stamina_locked and (attack_run\
	or me.stamina > Player.FEEL.stamina_dive_cost + STAMINA_RESERVE\
	or (all_out and me.stamina > ALL_OUT_FLOOR))
	input.sprint_held = want_sprint and stam_ok




	if _mode == MODE_RECEIVE and _ball_float and _ball != null:
		if _float_chase:
			var chase: = Vector3(_ball.global_position.x - me.global_position.x, 0.0, to_target.z)
			if chase.length() > 0.15:
				input.move = Vector2(chase.normalized().x, chase.normalized().z)
		elif to_target.length() < 0.9:
			input.move = Vector2.ZERO

	var to_meet: = Vector2(_move_target.x - me.global_position.x, 
		_move_target.z - me.global_position.z).length() if attack_approach else 0.0










	var plant_now: = _hop_straight\
	or (_jump_hold <= APPROACH_PLANT_TIME and to_meet < ATTACK_PLANT_NEAR)







	var serve_run_up: = _mode == MODE_RECEIVE and _attacking and _serving\
	and _serve_jump and _serve_run and _last_touch_count == 0
	if serve_run_up and _jump_hold > 0.0 and me.is_on_floor():








		if not _serve_go and run_time(dist, brake_speed) >= _jump_hold - 0.02:
			_serve_go = true








		var side_z: = float(me.team_side)
		var toward: = - Vector2(me.velocity.x, me.velocity.z).y * side_z
		var takeoff_z: = me.global_position.z * side_z - maxf(toward, 0.0) * _jump_hold
		var overshoot: = takeoff_z < _half_l + SERVE_LINE_GUARD
		plant_now = overshoot
		if not _serve_go and not overshoot:
			input.move = Vector2.ZERO
			input.strafe_held = false
		elif _serve_go and not overshoot:




			var drive: = Vector2(_move_target.x - me.global_position.x, - side_z * 2.0)
			input.move = drive.normalized()
			input.strafe_held = false
	elif serve_run_up:
		plant_now = false





	if _power_run and attack_approach and _jump_hold > 0.0 and me.is_on_floor():
		var takeoff: = _run_meet - _run_dir * _run_fly
		var to_off: = Vector2(takeoff.x - me.global_position.x, 
			takeoff.z - me.global_position.z).length()
		if not _run_go and run_time(to_off, brake_speed) >= _jump_hold - 0.02:
			_run_go = true
		if _run_go:
			var drive: = Vector2(_run_meet.x - me.global_position.x, 
				_run_meet.z - me.global_position.z)
			input.move = drive.normalized() if drive.length() > 0.05\
			else Vector2(_run_dir.x, _run_dir.z)
		else:
			input.move = Vector2.ZERO
		input.strafe_held = false
		input.sprint_held = false
		plant_now = false
	if _jump_hold > 0.0 and me.is_on_floor()\
	and ( not (attack_approach or serve_run_up) or plant_now):
		input.move = Vector2.ZERO
		input.strafe_held = true







	if me.is_on_floor() and _jump_hold <= 0.0:
		var dodge: = _jumper_dodge(me, allies)
		if dodge != Vector2.ZERO:
			_braking = false
			input.move = (input.move + dodge).limit_length(1.0)









	if me.is_on_floor() and _jump_hold <= 0.0\
	and me.contact_state == Player.ContactState.IDLE\
	and not input.strafe_held and input.move.length() < 0.05:
		input.strafe_held = true
		var track_ball: bool = _rally_live and _ball != null and not _ball.frozen\
		and _ball.global_position.y > 0.6
		var look_at: Vector3
		if track_ball:
			look_at = _ball.global_position
		else:


			look_at = me.global_position + Vector3(0.0, 0.0, -3.0 * float(me.team_side))
		input.aim = Vector3(look_at.x, 0.0, look_at.z)







const JUMPER_CLEAR: = 1.15
const JUMPER_LOAD_CLEAR: = 0.95
func _jumper_dodge(me: Player, allies: Array) -> Vector2:
	var here: = Vector2(me.global_position.x, me.global_position.z)
	var push: = Vector2.ZERO
	for p in allies:
		var mate: Player = p
		if mate == null or not is_instance_valid(mate) or mate.knocked()\
		or mate.diving():
			continue
		var at: = Vector2(mate.global_position.x, mate.global_position.z)
		var vel: = Vector2(mate.velocity.x, mate.velocity.z)
		var seg_end: = at
		var radius: = JUMPER_CLEAR
		if not mate.is_on_floor():


			var g: = maxf(Player.FEEL.gravity, 0.1)
			var y: = maxf(mate.global_position.y, 0.0)
			var vy: = mate.velocity.y
			var t: = clampf((vy + sqrt(maxf(vy * vy + 2.0 * g * y, 0.0))) / g, 0.0, 1.2)
			seg_end = at + vel * t
		elif mate._jump_charge > 0.05:

			seg_end = at + vel * Player.FEEL.jump_carry * 0.6
			radius = JUMPER_LOAD_CLEAR
		else:
			continue

		var seg: = seg_end - at
		var k: = 0.0
		if seg.length_squared() > 0.0001:
			k = clampf((here - at).dot(seg) / seg.length_squared(), 0.0, 1.0)
		var near: = at + seg * k
		var off: = here - near
		var d: = off.length()
		if d >= radius:
			continue

		var dir: = off / d if d > 0.05 else (Vector2( - seg.y, seg.x).normalized()\
		if seg.length() > 0.05 else Vector2(1.0, 0.0))
		push += dir * (0.6 + 1.4 * (1.0 - d / radius))
	return push

func _reflex_touch(input: PlayerInput, me: Player, allies: Array, ball: Ball, 
		touch_count: = -1) -> bool:





	if not me.is_on_floor() or me.touch_barred:
		return false






	if _jump_hold > 0.0:
		return false





	if ball.frozen:
		return false





	if _set_holding:
		return false
	if touch_count == 1 and _mode == MODE_RECEIVE and not _attacking\
	and not _solo and me.set_opportunity_available():
		return false






	if _touch_cooldown > 0.0:
		return false


	if ball.global_position.z * float(me.team_side) < -0.35:
		return false

	if ball.vel.y > 1.0:
		return false




	var last_chance: = _last_touch_count >= 2
	if _time_to_height(ball, 0.9) > (1.15 if last_chance else 0.7):
		return false
	var flat: = Vector2(ball.global_position.x - me.global_position.x, 
		ball.global_position.z - me.global_position.z).length()
	if flat > (3.0 if last_chance else 1.9):
		return false



	for p in allies:
		var member: Player = p
		if member.touch_barred or member.knocked():
			continue
		var their_flat: = Vector2(ball.global_position.x - member.global_position.x, 
			ball.global_position.z - member.global_position.z).length()


		if not _can_get_there(member, their_flat, _time_to_height(ball, 0.9))\
		or (member.contact_state == Player.ContactState.RECOVER\
		and not member.contact_intent_queued()):
			continue
		if their_flat < flat - 0.2:






			if member.is_bot:
				return false
			var to_ball: = Vector2(
				ball.global_position.x - member.global_position.x, 
				ball.global_position.z - member.global_position.z)
			var their_mv: = Vector2(member.velocity.x, member.velocity.z)
			var toward: = (their_mv.length() > 1.0 and their_flat > 0.1
				and their_mv.normalized().dot(to_ball.normalized()) > 0.2)

			var jumping_for_it: = not member.is_on_floor() and _human_air_play(member)
			if member.contact_intent_queued() or toward or jumping_for_it:
				return false
	var dist: = ball.global_position.distance_to(me.chest_position())









	var can_release: = not me.ball_on_far_side() and me._swing_reach_check()
	if _holding and can_release:
		input.contact_released = true
		if DEBUG_AI: _letgo_line = get_stack()[0].line
		_holding = false
		_touch_cooldown = 0.4
	elif _holding:
		pass
	elif not _holding and dist < 2.4:
		input.contact_pressed = true
		_holding = true
	return true

func _maybe_dive(input: PlayerInput, me: Player, ball: Ball) -> void :


	if not me.is_on_floor() or me.diving():
		return



	if _dive_skip_seq != ball.strike_seq:
		_dive_skip_seq = ball.strike_seq
		_dive_skip = randf() < [0.5, 0.12, 0.0][difficulty_level]
	if _dive_skip:
		return






	if me.stamina_locked or me.stamina <= Player.FEEL.stamina_dive_cost:
		return
	var to_landing: = Vector2(_move_target.x - me.global_position.x, 
		_move_target.z - me.global_position.z)
	var gap: = to_landing.length()


	var reach_scale: float = [0.68, 0.88, 1.0][difficulty_level]


	var time_left: = _time_to_height(ball, 0.9)









	var dive_travel: = _dive_arrival_time(gap)
	var contact_lead: = 0.06 + (0.08 if _last_touch_count >= 2 else 0.0)



	if _dive_err_seq != ball.strike_seq:
		_dive_err_seq = ball.strike_seq
		_dive_err = randf_range(-0.04, 0.18) * aim_error_mult\
		if randf() < DIVE_MISTIME_CHANCE else 0.0









	var dive_reach: = dive_full_dist() * reach_scale + DIVE_TOUCH_REACH
	var sprint_ok: = not me.stamina_locked\
	and me.stamina > Player.FEEL.stamina_dive_cost + STAMINA_RESERVE
	var top: float = Player.FEEL.move_speed\
	* (Player.FEEL.sprint_speed if sprint_ok else 1.0)
	var closing: = 0.0
	if gap > 0.05:
		closing = maxf(Vector2(me.velocity.x, me.velocity.z).dot(to_landing / gap), 0.0)
	var run_makes_it: = run_time(maxf(gap - STAND_TOUCH_REACH, 0.0), closing, top)\
	+ RUN_SETTLE < time_left





	var reach_cap: = dive_reach * minf(dive_bias, 1.1)
	if _our_ball:
		reach_cap += LAST_DITCH_STRETCH
	if time_left <= dive_travel + contact_lead + maxf(_dive_err, 0.0)\
	and time_left >= - minf(_dive_err, 0.0)\
	and gap > DIVE_MIN_GAP and gap < reach_cap\
	and not run_makes_it:

		input.aim = _move_target
		input.dive_pressed = true







const DIVE_MIN_GAP: = 1.25

const DIVE_MISTIME_CHANCE: = 0.35
const DIVE_TOUCH_REACH: = 0.9
const STAMINA_RESERVE: = 8.0
const ALL_OUT_FLOOR: = 6.0
const LAST_DITCH_STRETCH: = 1.5
var _our_ball: = false
const STAND_TOUCH_REACH: = 1.0
const RUN_SETTLE: = 0.12




static func dive_full_dist() -> float:
	var T: = Player.FEEL.dive_time
	var v: = Player.FEEL.dive_speed
	var knee: = 0.7 * T
	return v * (knee - knee * knee / (2.0 * T)) + v * 0.3 * (T - knee)




func _dive_arrival_time(gap: float) -> float:
	var T: = Player.FEEL.dive_time
	var v: = Player.FEEL.dive_speed
	var knee: = 0.7 * T
	var d_knee: = v * (knee - knee * knee / (2.0 * T))
	if gap <= d_knee:
		return T * (1.0 - sqrt(maxf(1.0 - 2.0 * gap / (v * T), 0.0)))
	return knee + (gap - d_knee) / (v * 0.3)

func _ground_touch(input: PlayerInput, me: Player, ball: Ball) -> void :





	var whiffed: = _release_seq == ball.strike_seq\
	and me.contact_state == Player.ContactState.IDLE
	if _touch_cooldown > 0.0 and not whiffed:
		if _holding:
			input.contact_released = true
			if DEBUG_AI: _letgo_line = get_stack()[0].line
			_holding = false
		return
	if ball.frozen:





		if _holding:
			input.contact_released = true
			if DEBUG_AI: _letgo_line = get_stack()[0].line
			_holding = false
		return
	if ball.vel.y > 1.0:


		return
	var dist: = ball.global_position.distance_to(me.chest_position())


	var receding: = dist > _prev_ball_dist and dist < 2.2
	_prev_ball_dist = dist



















	var chance: = ( not me.ball_on_far_side() and me._swing_reach_check())\
	or me.contact_intent_queued()










	var queued_bump: = me.is_on_floor() and me.contact_intent_queued()\
	and me._armed_kind == Player.TouchKind.BUMP
	if _holding and (dist < TOUCH_RELEASE_DIST or receding) and chance\
	and not queued_bump:
		input.contact_released = true
		if DEBUG_AI: _letgo_line = get_stack()[0].line
		_holding = false
		_touch_cooldown = TOUCH_COOLDOWN
		_release_seq = ball.strike_seq
	elif _holding and (dist < TOUCH_RELEASE_DIST or receding):
		pass
	elif dist < _press_dist and (_spot_gap(me) < PRESS_SPOT_GAP or dist < PRESS_NEAR)\
	and me.is_on_floor():









		input.contact_pressed = true
		_holding = true
	elif _holding and not (_ball_coming_to_me(me, ball) and HOLD_KEEP_ENABLED):
		input.contact_released = true
		if DEBUG_AI: _letgo_line = get_stack()[0].line
		_holding = false









static var HOLD_KEEP_ENABLED: = true
const HOLD_KEEP_RADIUS: = 1.4
const HOLD_KEEP_ETA: = 1.6

func _ball_coming_to_me(me: Player, ball: Ball) -> bool:


	if ball == null or ball.frozen or not me.is_on_floor() or _resp_side == 0 or _resp_side == me.team_side:
		return false
	var g: = Ball.PHYS.gravity
	var dy: = ball.global_position.y - 1.0
	var disc: = ball.vel.y * ball.vel.y + 2.0 * g * dy
	if disc <= 0.0:
		return false
	var t: = (ball.vel.y + sqrt(disc)) / g
	if t > HOLD_KEEP_ETA:
		return false


	var land: = ball.global_position + Vector3(ball.vel.x, 0.0, ball.vel.z) * t
	if land.z * float(me.team_side) <= 0.0:
		return false
	var keep: = Vector2(land.x - me.global_position.x, 
		land.z - me.global_position.z).length() < HOLD_KEEP_RADIUS
	if keep and DEBUG_AI and _keep_seq != ball.strike_seq:
		_keep_seq = ball.strike_seq
		print("[KEEP] %s mode=%d cs=%d t=%.2f d=%.2f seq=%d" % [me.name, _mode, 
			me.contact_state, t, ball.global_position.distance_to(me.chest_position()), 
			ball.strike_seq])
	return keep
var _keep_seq: = -1
var _resp_side: = 0

const PRESS_SPOT_GAP: = 1.0
const PRESS_NEAR: = 1.8


func _spot_gap(me: Player) -> float:
	return Vector2(_move_target.x - me.global_position.x, 
		_move_target.z - me.global_position.z).length()

func _dedicated_set(input: PlayerInput, me: Player, allies: Array, ball: Ball, 
		touch_count: int, delta: float) -> bool:












	var aim_over: = _aim.z * float(me.team_side) < 0.0
	if touch_count != 1 or _attacking or _solo or aim_over\
	or not me.set_opportunity_available():
		if DEBUG_SET and touch_count == 1:
			print("[SET %s] GUARD-FAIL atk=%s solo=%s opp=%s | cs=%d barred=%s far=%s frozen=%s ce=%s bally=%.2f mode=%d" % [
				me.name, str(_attacking), str(_solo), str(me.set_opportunity_available()), 
				me.contact_state, str(me.touch_barred), str(me.ball_on_far_side()), 
				str(ball.frozen), str(me.contact_enabled), ball.global_position.y, _mode])
		if _set_holding:
			input.set_released = true
			_set_holding = false
			_set_hold_time = 0.0
		return false
	var dist: = ball.global_position.distance_to(me.chest_position())
	var receding: = dist > _prev_ball_dist and dist < 2.3
	_prev_ball_dist = dist
	if DEBUG_SET and touch_count == 1:
		var ab: = _airborne_ally(allies, float(me.team_side))
		print("[SET %s] hold=%s qk=%s ht=%.2f | ab=%s abd=%.2f rise=%s | dist=%.2f eta=%.2f recede=%s opp=%s bally=%.2f" % [
			me.name, str(_set_holding), str(_set_quick), _set_hold_time, 
			("null" if ab == null else str(ab.name)), 
			(0.0 if ab == null else me.global_position.distance_to(ab.global_position)), 
			str(_hitter_rising(allies, float(me.team_side))), 
			dist, _time_to_height(ball, SET_APPROACH_H), str(receding), 
			str(me.set_opportunity_available()), ball.global_position.y])
	if _set_holding:
		_set_hold_time += delta





		if _set_quick:
			var live_hitter: = _airborne_ally(allies, float(me.team_side))
			if live_hitter != null and me.global_position.distance_to(
					live_hitter.global_position) < MINUS_TEMPO_TAP_DIST:
				_set_quick = false
		else:






			var late_hitter: = _airborne_ally(allies, float(me.team_side))
			if late_hitter != null:
				var lh_dist: = me.global_position.distance_to(late_hitter.global_position)
				if lh_dist >= MINUS_TEMPO_TAP_DIST:
					_set_quick = true
					_set_target_distance = lh_dist






		var regular_ready: = _set_hold_time >= 0.12\
		and (_set_hold_time >= 0.5 or not _hitter_rising(allies, float(me.team_side)))
		var quick_hold: = clampf(0.58 + _set_target_distance * 0.025, 0.64, 0.8)
		var quick_ready: = _set_hold_time >= quick_hold\
		and (dist < 1.65 or receding)
		if (_set_quick and quick_ready) or ( not _set_quick and regular_ready):
			input.set_released = true
			_set_holding = false
			_set_hold_time = 0.0
		else:
			input.set_pressed = true
		return true



	var airborne: = _airborne_ally(allies, float(me.team_side))
	_set_target_distance = me.global_position.distance_to(airborne.global_position)\
	if airborne != null else 0.0



	_set_quick = CPU_QUICK_SET_ENABLED and airborne != null\
	and _set_target_distance >= MINUS_TEMPO_TAP_DIST







	var eta: = _time_to_height(ball, SET_APPROACH_H)
	if not _set_quick and eta > 0.35 and not receding:
		return true
	_set_holding = true
	_set_hold_time = 0.0
	input.set_pressed = true
	return true

static var QUICK_TO_AIRBORNE: = true
static var DEBUG_AI: = false
static var DEBUG_SET: = false
static var DEBUG_ATTACK: = false
static var _dbg_atk_file: FileAccess = null



static func power_run_fly(reserve: float) -> float:
	return Player.FEEL.jump_carry * Player.FEEL.move_speed * reserve





func _want_power_run(me: Player, ball: Ball, allies: Array, opponents: Array, 
		touch_count: int, side: float) -> bool:
	if not POWER_RUN_ENABLED or _serving or touch_count < 2 or not me.is_on_floor():
		return false
	var meet: = _move_target
	if absf(meet.z) > POWER_RUN_NET_MAX or meet.z * side <= 0.0:
		return false
	var wall: = false
	for o in opponents:
		var p: Player = o
		if is_instance_valid(p) and not p.knocked()\
		and absf(p.global_position.z) < POWER_RUN_WALL_Z\
		and absf(p.global_position.x - meet.x) < POWER_RUN_WALL_X:
			wall = true
			break
	if not wall:
		return false
	var dir: = Vector3(_aim.x - meet.x, 0.0, _aim.z - meet.z)
	if dir.length() < 1.0 or dir.normalized().z * side > -0.5:
		return false
	dir = dir.normalized()







	var from: = Vector3(me.global_position.x, 0.0, me.global_position.z)
	var to_meet: = Vector3(meet.x, 0.0, meet.z) - from
	var run_dir: = to_meet.normalized() if to_meet.length() > 0.3 else dir
	if run_dir.dot(dir) < POWER_RUN_ALIGN:
		return false
	var reserve: = ATTACK_ASCENT_FLOAT if _tempo_float else ATTACK_ASCENT_RESERVE
	var fly: = power_run_fly(reserve)
	if to_meet.length() < fly + POWER_RUN_MIN_RUN and _tempo_float:
		reserve = ATTACK_ASCENT_RESERVE
		fly = power_run_fly(reserve)
	if to_meet.length() < fly + POWER_RUN_MIN_RUN:
		return false

	var start: = meet - run_dir * minf(fly + POWER_RUN_IN, to_meet.length())
	start.y = 0.0


	for a in allies:
		var m: Player = a
		if m == me or not is_instance_valid(m) or m.touch_barred_self or m.knocked():
			continue
		var d_mate: = Vector2(m.global_position.x - meet.x, m.global_position.z - meet.z)
		if d_mate.length() < fly + POWER_RUN_IN - 0.7:
			return false


	var eta: = _time_to_height(ball, ATTACK_MEET_H)
	if eta == INF or eta < POWER_RUN_MIN_HOLD + reserve:
		return false
	dir = run_dir
	if hitter_style == HitterStyle.PLANTED:
		return false
	var chance: = power_run_chance
	if persona == Persona.AGGRESSIVE:
		chance *= 1.25
	elif persona == Persona.WALL:
		chance *= 0.6
	if hitter_style == HitterStyle.RUNNER:
		chance = maxf(chance * 1.6, 0.85)
	if randf() >= chance:
		return false
	_tempo_float = reserve == ATTACK_ASCENT_FLOAT
	_run_meet = meet
	_run_dir = dir
	_run_fly = fly
	_move_target = start
	return true

func _attack(input: PlayerInput, me: Player, ball: Ball, delta: float) -> void :



	var dbg_near: = ball.global_position.distance_to(me.chest_position()) < 3.0
	if DEBUG_ATTACK and ( not me.is_on_floor() or _jump_hold > 0.0 or dbg_near):
		var rel: = ball.global_position - me.chest_position()
		var b: = me.visual.global_basis
		var line: = "[ATK %s] f=%d air=%s jh=%.2f cs=%d hold=%s rt=%d reach=%s | ball_local(x=%.2f y=%.2f z=%.2f) meet=(%.2f,%.2f) bot=(%.2f,%.2f) ballw=(%.2f,%.2f,%.2f)" % [
			str(me.name), Engine.get_physics_frames(), str( not me.is_on_floor()), 
			_jump_hold, me.contact_state, str(_holding), me.resolved_touch(), 
			str(me._swing_reach_check()), 
			rel.dot(b.x.normalized()), rel.y, rel.dot(( - b.z).normalized()), 
			_move_target.x, _move_target.z, me.global_position.x, me.global_position.z, 
			ball.global_position.x, ball.global_position.y, ball.global_position.z]


		line += " | q=%s elig=%s pri=%s stamp=%d/%d bar=%s win=%.2f cd=%.2f press=%.2f" % [str(me.contact_intent_queued()), 
			str(me.queued_contact_eligible()), 
			str(bool(me.contact_priority_check.call(me)) if me.contact_priority_check.is_valid() else true), 
			me._intent_used_strike, ball.strike_seq, str(me.touch_barred), me._receive_window, 
			_touch_cooldown, _press_dist]
		print(line)
		if _dbg_atk_file == null:
			_dbg_atk_file = FileAccess.open("user://cpu_atk.log", FileAccess.WRITE)
		if _dbg_atk_file != null:
			_dbg_atk_file.store_line(line)
			_dbg_atk_file.flush()

	if me.is_on_floor():



		var flat: = Vector2(_move_target.x - me.global_position.x, 
			_move_target.z - me.global_position.z)


		var last_chance: = _last_touch_count >= 2
		var serving_jump: = _serving and _last_touch_count == 0
		var serve_run: = serving_jump and _serve_jump and _serve_run
		if serve_run and _jump_hold <= 0.0 and not _serve_crouch:









			var hit_eta: = _time_to_height(ball, SERVE_RUN_HIT_H)
			if hit_eta == INF:
				hit_eta = _time_to_height(ball, ATTACK_MEET_H)
			var hold: = clampf(run_time(flat.length(), Vector2(me.velocity.x, 
				me.velocity.z).length()), SERVE_RUN_MIN_HOLD, JUMP_HOLD_ATTACK)
			if hit_eta > hold + SERVE_RUN_RISE:
				input.move = Vector2.ZERO
				input.sprint_held = false
			else:
				_jump_hold = clampf(hit_eta - SERVE_RUN_RISE, MIN_SPIKE_CHARGE, hold)
				_serve_crouch = true
				_serve_go = true







		var reserve: = ATTACK_ASCENT_FLOAT if _tempo_float else ATTACK_ASCENT_RESERVE
		var hold_max: = JUMP_HOLD_ATTACK * jump_charge_scale
		var jump_lead: = (JUMP_HOLD_SERVE * jump_charge_scale + SERVE_RUN_RISE)\
		if serving_jump else hold_max + reserve + ATTACK_LEAD_SLACK
		var meet_eta: = _time_to_height(ball, ATTACK_MEET_H)





		if serving_jump:
			var serve_eta: = _time_to_height(ball, SERVE_RUN_HIT_H)
			if serve_eta != INF:
				meet_eta = serve_eta






		var run: = Vector2(me.velocity.x, me.velocity.z)
		var closing: = flat.length() < 0.8\
		or (run.length() > 1.5 and flat.length() > 0.05\
		and run.normalized().dot(flat.normalized()) > 0.5)















		if RETIME_ENABLED and _jump_hold > 0.0 and not serving_jump and not serve_run\
		and not _power_run\
		and not _block_jump and meet_eta != INF\
		and ( not _quick_jump or ball.strike_seq != _quick_seq)\
		and meet_eta - reserve > _jump_hold + ATTACK_RETIME_SLACK:



			input.jump_cancelled = true
			_jump_hold = 0.0
			_hop_straight = false
			_quick_jump = false
		var hold_est: = clampf(meet_eta - reserve, MIN_SPIKE_CHARGE, hold_max)
		var cover: = run.length() * maxf(hold_est - APPROACH_PLANT_TIME, 0.0) + 0.8













		var short_charge: = hold_est < 0.45
		var under_it: = flat.length() < 0.5 and meet_eta >= MIN_SPIKE_CHARGE\
		and run.length() < 1.6



		var wide_run: = last_chance and not short_charge
		if _power_run and not serving_jump and _jump_hold <= 0.0:








			var takeoff: = _run_meet - _run_dir * _run_fly
			var rel: = me.global_position - takeoff
			rel.y = 0.0
			var behind: = - rel.dot(_run_dir)
			var off_line: = (rel + _run_dir * behind).length()
			var at_start: = flat.length() < POWER_RUN_START_TOL\
			or (behind >= POWER_RUN_MIN_RUN and off_line < POWER_RUN_START_TOL)
			var hold_p: = meet_eta - reserve
			if meet_eta == INF or hold_p < POWER_RUN_MIN_HOLD\
			or (meet_eta < jump_lead and not at_start):
				_power_run = false
				_move_target = _run_meet
				flat = Vector2(_move_target.x - me.global_position.x, 
					_move_target.z - me.global_position.z)
			elif meet_eta < jump_lead:
				_jump_hold = clampf(hold_p, POWER_RUN_MIN_HOLD, hold_max)
				_run_go = false
		if not serve_run and not _power_run and meet_eta < jump_lead\
		and (serving_jump or under_it\
		or meet_eta >= MIN_SPIKE_CHARGE + ATTACK_ASCENT_RESERVE)\
		and (serving_jump or last_chance\
		or ball.vel.y < (3.0 if last_chance else 2.0))\
		and flat.length() < (minf(2.8, cover) if wide_run else 0.8)\
		and (serving_jump or closing)\
		and _jump_hold <= 0.0\
		and run.length() < (6.5 if wide_run else 2.5):
			if serving_jump:
				_jump_hold = JUMP_HOLD_SERVE * jump_charge_scale
				_serve_crouch = true
			else:





				if meet_eta < MIN_SPIKE_CHARGE + reserve:
					reserve = ATTACK_ASCENT_RESERVE



				_jump_hold = clampf(meet_eta - reserve, 
					MIN_SPIKE_CHARGE, JUMP_HOLD_ATTACK * jump_charge_scale)

				_hop_straight = not wide_run
	if not me.is_on_floor():


		input.move = Vector2.ZERO
	if _touch_cooldown <= 0.0:
		var dist: = ball.global_position.distance_to(me.chest_position())
		var high_ball: = ball.global_position.y > maxf(me.chest_position().y, 2.25)


		var meeting_now: = me._swing_reach_check()
		if _holding and not me.is_on_floor() and meeting_now:














			input.contact_released = true
			if DEBUG_AI: _letgo_line = get_stack()[0].line
			_holding = false
			_touch_cooldown = 0.3
		elif _holding and me.is_on_floor() and _jump_hold <= 0.0 and meeting_now:

			input.contact_released = true
			if DEBUG_AI: _letgo_line = get_stack()[0].line
			_holding = false
			_touch_cooldown = TOUCH_COOLDOWN
		elif _holding or (((_jump_hold > 0.0 and not meeting_now and not _power_run)\
		or not me.is_on_floor()) and (dist < 4.0\
		or (_serve_crouch and not _serve_run))):













			input.contact_pressed = true
			_holding = true
		elif me.is_on_floor() and ball.global_position.y < 2.6 and _jump_hold <= 0.0:


			_maybe_dive(input, me, ball)
			_ground_touch(input, me, ball)

func _block(input: PlayerInput, me: Player, ball: Ball, delta: float) -> void :


	var threat_live: = _threat != null and is_instance_valid(_threat)\
	and not _threat.is_on_floor()






	var threat_committed: = threat_live\
	and (_threat.contact_state == Player.ContactState.WINDUP\
	or (_threat.global_position.y > 1.0 and _threat.velocity.y > -1.0))
	var in_position: = absf(me.global_position.x - _move_target.x) < 0.9\
	and absf(me.global_position.z - _move_target.z) < 0.9









	var contact_eta: = _time_to_height(ball, BLOCK_READ_H)
	if contact_eta == INF:
		contact_eta = _time_to_height(ball, ATTACK_MEET_H)
	var ball_read: = ball.global_position.z * float(me.team_side) < 0.0\
	and contact_eta < JUMP_HOLD_BLOCK * jump_charge_scale + BLOCK_JUMP_LEAD


	var already_hit: = ball.vel.z * float(me.team_side) > 3.0





	var threat_charging: = _threat != null and is_instance_valid(_threat)\
	and _threat.is_on_floor() and _threat._jump_charge > 0.05\
	and absf(_threat.global_position.z) < 4.0





	if me.is_on_floor() and in_position and _jump_hold <= 0.0\
	and not already_hit\
	and (threat_committed or ball_read or threat_charging)\
	and absf(ball.global_position.z) < 3.5:
		_jump_hold = JUMP_HOLD_BLOCK * jump_charge_scale
		_block_jump = true
	if not me.is_on_floor():





		if me.contact_state == Player.ContactState.IDLE and me.velocity.y > 0.5:
			input.block_pressed = true
		input.aim = _block_deflect_aim
		var to_ball: = ball.global_position.x - me.global_position.x
		if absf(to_ball) > 0.4:
			input.move.x = signf(to_ball)




const BLOCK_HANDS_RISE: = 0.16
func _block_beaten(me: Player, ball: Ball) -> bool:
	if ball == null or ball.frozen:
		return false
	if ball.last_hit_kind != Player.TouchKind.SPIKE\
	and ball.last_hit_kind != Player.TouchKind.DUMP:
		return false
	var side: = float(me.team_side)
	var toward: = ball.vel.z * side
	if toward <= 3.0:
		return false
	if ball.global_position.z * side > -0.1:
		return true
	var t_net: = absf(ball.global_position.z) / toward + ball.hitstop_left
	return t_net < _jump_hold + BLOCK_HANDS_RISE

func _run_jump(input: PlayerInput, delta: float) -> void :
	if _jump_hold > 0.0:
		input.jump_held = true
		_jump_hold -= delta
		if _jump_hold <= 0.0:
			input.jump_released = true
			_quick_jump = false
			_block_jump = false
			_serve_crouch = false
			_serve_go = false

func _time_to_height(ball: Ball, h: float) -> float:



	var g: = Ball.PHYS.gravity
	var disc: = ball.vel.y * ball.vel.y + 2.0 * g * (ball.global_position.y - h)
	if disc < 0.0:
		return INF
	return maxf((ball.vel.y + sqrt(disc)) / g, 0.0) + ball.hitstop_left










static var _flight_cache: = {}



static func _flight_pts(ball: Ball) -> PackedVector3Array:
	var key: = ball.get_instance_id()
	var now: = Engine.get_physics_frames()
	var entry = _flight_cache.get(key)
	var stale: bool = entry == null or int(entry["seq"]) != ball.strike_seq\
	or now - int(entry["at"]) > 6
	if not stale:



		var pts0: PackedVector3Array = entry["pts"]
		var k: = mini(now - int(entry["at"]), pts0.size() - 1)
		stale = k < 0 or pts0[k].distance_to(ball.global_position) > 0.35
	if stale:
		if _flight_cache.size() > 32:
			_flight_cache.clear()
		var pts: = PackedVector3Array()
		var pos: = ball.global_position
		var vel: = ball.vel
		var curve: = ball.curve
		var sc: = ball.stop_clock
		var fc: = ball.flight_float_charge()
		pts.push_back(pos)
		for _step in 240:
			var state: = Ball.step_flight(pos, vel, curve, 1.0 / 60.0, 
				ball.net_half_width, ball.court_center_x, ball.wall_min, ball.wall_max, sc, fc)
			pos = state[0]
			vel = state[1]
			curve = float(state[2])
			sc = float(state[3])
			fc = float(state[4])
			pts.push_back(pos)
			if pos.y <= Ball.PHYS.radius + 0.01 and vel.y <= 0.0:
				break
		entry = {"seq": ball.strike_seq, "at": now, "pts": pts}
		_flight_cache[key] = entry
	return entry["pts"]

static func flight_point_at_height(ball: Ball, h: float) -> Dictionary:
	var pts2: = _flight_pts(ball)
	for i in range(1, pts2.size()):

		if pts2[i - 1].y >= h and pts2[i].y <= h and pts2[i].y < pts2[i - 1].y:
			return {"found": true, "point": pts2[i]}
	return {"found": false, "point": pts2[pts2.size() - 1]}




static func flight_apex(ball: Ball) -> Vector3:
	var pts: = _flight_pts(ball)
	var best: = ball.global_position
	for p in pts:
		if p.y > best.y:
			best = p
	return best

func _predict_at_height(ball: Ball, h: float, side: float) -> Vector3:
	var probe: = flight_point_at_height(ball, h)
	var spot: Vector3
	if bool(probe.found):
		spot = probe.point
	else:




		spot = flight_apex(ball)


	spot.x = clampf(spot.x, _cx - _half_w - 3.5, _cx + _half_w + 3.5)
	var deep: = side * (_half_l + 4.0)







	spot.z = clampf(spot.z, minf(deep, side * NET_MEET_MIN), maxf(deep, side * NET_MEET_MIN))
	spot.y = 0.0
	return spot

func _predict_landing(ball: Ball, side: float, apron: = 3.5) -> Vector3:


	var g: = Ball.PHYS.gravity
	var dy: = ball.global_position.y - 1.0
	var disc: = ball.vel.y * ball.vel.y + 2.0 * g * dy
	var t: = 0.0
	if disc > 0.0:
		t = (ball.vel.y + sqrt(disc)) / g
	var landing: = ball.global_position + Vector3(ball.vel.x, 0.0, ball.vel.z) * t




	landing.x = clampf(landing.x, _cx - _half_w - apron, _cx + _half_w + apron)
	var deep: = side * (_half_l + apron + 0.5)
	landing.z = clampf(landing.z, minf(deep, side * 0.8), maxf(deep, side * 0.8))
	landing.y = 0.0
	return landing
