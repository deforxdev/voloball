class_name Rally
extends RefCounted




































signal whistle_fault(reason: String, pos: Vector3)



signal verdict(pos: Vector3, text: String, winner: int)
signal serve_prepared(server: Player)
signal tossed(server: Player)
signal serve_minigame_requested(server: Player)



signal touch_flair(kind: String, who: Player)



signal auto_callout(who: Player, idx: int)

signal point(winner_side: int, reason: String, scorer: Player, 
	kill_power: float, winners_ball: bool)

signal set_won(winner_side: int)




signal received(who: Player, overhand: bool)



signal ball_dead

const SERVE_FOUL_TIME: = 15.0
const TOUCH_LOCK: = 0.25








const QUICK_TEMPO_WINDOW: = 0.95
const QUICK_COLOR: = Color(1.0, 0.45, 0.78)



const PERFECT_COLOR: = Color(0.5, 1.0, 1.0)
const GOOD_COLOR: = Color(0.5, 1.0, 0.55)
const BAD_COLOR: = Color(0.85, 0.55, 0.5)



var court: Court
var team_size: = 2
var set_points: = 7
var win_by_two: = false
var endless: = false





var practice: = false




var dead: = false


var serve_seconds: = SERVE_FOUL_TIME


var rotate_every_point: = false


var players: Array = []
var slots: = {}
var bots: = {}
var stats: = {}



var scores: = {1: 0, -1: 0}
var ball: Ball = null


var input_for: = Callable()



var server: Player = null
var serve_side: = 1
var serve_done: = true
var serve_clock: = 0.0



var serve_locked: = false
var serve_launch_z: = 0.0
var serve_crossed: = true
var serve_received: = false
var serve_attack_window: = false
var bot_toss_delay: = 0.0
const BOT_READY_GRACE: = 2.0
var rot: = {1: 0, -1: 0}
var last_serve_side: = 0
var live: = false
var rally_time: = 0.0



var sweat_touches: = 0
var touch_count: = 0
var touch_side: = 0
var last_toucher: Player = null


var _pending_set: Player = null



var _assist_feed: Player = null
var _assist_helper: Player = null
var _assist_spiker: Player = null
var last_touch_side: = 0


var last_touch_kind: = Player.TouchKind.NONE
var team_last_toucher: = {1: null, -1: null}
var touch_lock: = 0.0
var touch_lock_side: = 0
var quick_set_side: = 0
var _quick_set_at: = - INF
var _quick_setter: Player = null
var prev_ball_side: = 0.0
var _ended: = true
var _carom_seen: = -1


var _ball_prev: = Vector3.INF
var _ball_prev_seq: = -1
var _body_hit_by: Player = null






const CONTACT_DISTANCE_TIE: = 0.05

func setup(lines: Court, size: int, the_ball: Ball, the_players: Array, 
		the_slots: Dictionary, the_bots: Dictionary, 
		the_stats: Dictionary) -> Rally:
	court = lines
	team_size = size
	ball = the_ball
	players = the_players
	slots = the_slots
	bots = the_bots
	stats = the_stats









	for i in players.size():
		var a: Player = players[i]
		if a != null:
			a.roster = players
		for j in range(i + 1, players.size()):
			var b: Player = players[j]
			if a != null and b != null:
				a.add_collision_exception_with(b)
				b.add_collision_exception_with(a)
	return self

func queued_contact_has_priority(candidate: Player) -> bool:
	if candidate == null or not candidate.queued_contact_eligible():
		return false
	var winner: = candidate
	for p in players:
		var member: Player = p
		if member == candidate or member.team_side != candidate.team_side\
		or not member.queued_contact_eligible():
			continue
		if _queued_contact_precedes(member, winner):
			winner = member
	return winner == candidate

func _queued_contact_precedes(a: Player, b: Player) -> bool:








	var ar: = _attack_rank(a)
	var br: = _attack_rank(b)
	if ar != br:
		return ar > br
	var ab: = floorf(a.queued_contact_distance() / CONTACT_DISTANCE_TIE)
	var bb: = floorf(b.queued_contact_distance() / CONTACT_DISTANCE_TIE)
	if ab != bb:
		return ab < bb
	var at: = a.queued_contact_time()
	var bt: = b.queued_contact_time()
	if at != bt:
		return at < bt
	return players.find(a) < players.find(b)



func _attack_rank(p: Player) -> int:
	match p.queued_contact_kind():
		Player.TouchKind.SPIKE:
			return 2
		Player.TouchKind.DUMP:
			return 1
		_:
			return 0





func forget(member: Player) -> void :
	if last_toucher == member:
		last_toucher = null
	if _pending_set == member:
		_pending_set = null
	if _assist_feed == member:
		_assist_feed = null
	if _assist_helper == member:
		_assist_helper = null
	if _assist_spiker == member:
		_assist_spiker = null
	if _quick_setter == member:
		_quick_setter = null
	if _one_touch_by == member:
		_one_touch_by = null
	if server == member:
		server = null
	for side in team_last_toucher:
		if team_last_toucher[side] == member:
			team_last_toucher[side] = null



func court_slot(who: Player) -> int:

	return Rules.rotated_slot(int(slots.get(who, 0)), team_size, 
		int(rot.get(who.team_side, 0)))

func player_in_slot(side: int, slot: int) -> Player:
	for p in players:
		var member: Player = p
		if member.team_side == side and court_slot(member) == slot:
			return member

	for p in players:
		if (p as Player).team_side == side:
			return p
	return null





func reset_formation() -> void :
	for p in players:
		var member: Player = p
		member.global_position = court.formation_spot(court_slot(member), 
			team_size, member.team_side)
		if bots.has(member):
			(bots[member] as TeamBot).configure(court.half_w, court.half_l, 
				court_slot(member), team_size, court.center_x)
		member.velocity = Vector3.ZERO
		member.dive_cooldown = 0.0


		member.stamina = Player.FEEL.stamina_max
		member.stamina_locked = false
		member.sprinting = false
		member.clear_action_state()
		member.reset_physics_interpolation()



func prepare_serve() -> void :
	_minigame_armed = false



	if serve_side != last_serve_side:
		if last_serve_side != 0:
			rot[serve_side] = int(rot[serve_side]) + 1
		last_serve_side = serve_side
	reset_formation()
	server = player_in_slot(serve_side, Rules.server_slot(team_size))
	if server == null:
		return
	server.global_position = Vector3(
		court.center_x + 0.35 * court.half_w * serve_side, 0.0, 
		serve_side * (court.half_l + 0.8))
	server.velocity = Vector3.ZERO
	server.reset_physics_interpolation()
	serve_done = false
	serve_launch_z = absf(server.global_position.z)
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.global_position = server.chest_position() + Vector3(0.0, 0.2, 0.0)

func begin_serve(prepare: = true) -> void :


	if prepare:
		prepare_serve()
	serve_clock = serve_seconds
	bot_toss_delay = randf_range(1.0, 2.2)
	_ended = false

	_pending_toss_t = 0.0
	serve_prepared.emit(server)









func in_safe_serve_spot(p: Player) -> bool:
	return in_serve_zone(p)\
	and not Rules.serve_foot_fault(absf(p.global_position.z), court.half_l)

func in_serve_zone(p: Player, margin: = 0.0) -> bool:
	var side: = float(p.team_side)
	var depth: = p.global_position.z * side - court.half_l
	return depth > - Rules.SERVE_ZONE_FRONT - margin\
	and depth <= Rules.SERVE_ZONE_DEPTH\
	and absf(p.global_position.x - court.center_x)\
	< court.half_w + Rules.SERVE_ZONE_SIDE + margin


func serve_tick(delta: float) -> void :
	if server == null:
		return

	ball.global_position = server.serve_cradle_point()


	if serve_locked:
		return
	if not practice:
		serve_clock -= delta
	if serve_clock <= 0.0 and not practice:

		ball.frozen = false
		whistle_fault.emit("serve foul", server.global_position)
		end_rally( - server.team_side, "serve foul")
		return
	if bots.has(server):
		bot_toss_delay -= delta



		if bot_toss_delay <= 0.0 and ((bots[server] as TeamBot).serve_ready(server)\
		or bot_toss_delay < - BOT_READY_GRACE):





			do_toss((bots[server] as TeamBot).serve_toss_speed())
		return


	var input: PlayerInput = input_for.call(server) if input_for.is_valid() else null
	if input == null:
		return

	var may_toss: = practice or in_serve_zone(server, 0.6)

	_call_grace = maxf(_call_grace - delta, 0.0)
	if input.serve_pressed != _dbg_sp:
		_dbg_sp = input.serve_pressed
		print("[serve] pressed=", input.serve_pressed, " may_toss=", may_toss,
			" grace=", _call_grace, " lvl=", int(server.get("power_level")),
			" practice=", practice)



	if input.serve_pressed and may_toss and _call_grace <= 0.0:
		var lvl: int = GameConfig.power_disp_of(int(server.get("power_level")))
		if lvl <= 3:
			if not _minigame_armed:
				_minigame_armed = true
				serve_minigame_requested.emit(server)
		else:
			_pending_toss_t = 0.0
			do_toss(Ball.PHYS.serve_toss_min, 2.2)
			_auto_serve_left = Ball.PHYS.serve_toss_min / Ball.PHYS.gravity
	elif _pending_toss_t > 0.0:







		_pending_toss_t -= delta
		if _pending_toss_t <= 0.0:


			if practice or in_serve_zone(server, 0.6):
				do_toss(_pending_toss_u)
			else:
				_pending_toss_t = 0.0




var _pending_toss_u: = 7.5
var _pending_toss_t: = 0.0
var _auto_serve_left: = -1.0
var _dbg_sp: = false
var _minigame_armed: = false

func request_toss(up_speed: float) -> void :
	if serve_done:
		return
	_pending_toss_u = up_speed
	_pending_toss_t = 0.35

func do_toss(up_speed: float, horiz_max: = -1.0) -> void :
	_pending_toss_t = 0.0
	_minigame_armed = false
	ball.frozen = false


	ball.serve_assist = not practice or in_serve_zone(server, 0.6)
	var plain_toss: = not ball.serve_assist







	var horiz: = Vector3.ZERO
	if bots.has(server):
		horiz = (bots[server] as TeamBot).serve_toss_horiz(server, up_speed)
	else:
		var charge: = Ball.serve_toss_charge(up_speed)
		horiz = Ball.serve_toss_horiz(server.global_position, server.aim_point, 
			charge, up_speed, 0.5, horiz_max)


	ball.toss(server.serve_cradle_point(), up_speed, horiz)
	touch_count = 0
	last_toucher = null
	_pending_set = null
	quick_set_side = 0
	_quick_set_at = - INF
	_quick_setter = null
	_assist_feed = null
	_assist_helper = null
	_assist_spiker = null
	_carom_seen = -1
	_ball_prev = Vector3.INF
	_body_hit_by = null
	touch_side = server.team_side
	last_touch_side = server.team_side
	last_touch_kind = Player.TouchKind.NONE
	team_last_toucher = {1: null, -1: null}
	prev_ball_side = signf(ball.global_position.z)
	serve_crossed = false
	serve_received = false
	if plain_toss:


		serve_crossed = true
		serve_received = true


	serve_attack_window = false
	_one_touch_by = null
	_block_action_side = 0








	_cross_seen = ball.cross_seq
	rally_time = 0.0
	sweat_touches = 0
	live = true
	tossed.emit(server)





func pre_tick(delta: float, phase_dead: bool) -> void :
	touch_lock = maxf(touch_lock - delta, 0.0)
	if server != null and not serve_done and server.is_on_floor():
		serve_launch_z = absf(server.global_position.z)
	for p in players:
		var member: Player = p





		var reason: int = Rules.Bar.NONE if practice else Rules.bar_reason(member, last_toucher, team_size, 
			touch_count, float(touch_side), phase_dead, 
			serve_crossed or phase_dead, serve_side, server, 
			touch_lock_side if touch_lock > 0.0 else 0)
		member.touch_barred = reason != Rules.Bar.NONE


		member.touch_bar_reason = reason
		member.rivals_can_play = rivals_can_play(member.team_side)

		member.touch_barred_self = Rules.bar_shows_marker(reason)






func rivals_can_play(side: int) -> bool:
	var rival: = - side
	if practice:
		return true
	if serve_done and not serve_crossed and serve_side == rival:
		return false
	return not (touch_side == rival and touch_count >= Rules.TOUCHES_PER_SIDE)


func live_tick(delta: float) -> void :
	rally_time += delta
	if _auto_serve_left > 0.0 and not bots.has(server):
		_auto_serve_left -= delta
		if _auto_serve_left <= 0.0:
			server.serve_auto_strike()
	_check_crossing()
	if court.out_of_play(ball.global_position):
		end_rally( - last_touch_side, "ball out")
		return
	var offender: = court.line_fault_offender(players) if not practice else null
	if offender != null:
		whistle_fault.emit("line fault", offender.global_position)
		end_rally( - offender.team_side, "line fault")
		return


	var path_from: = _ball_prev if ball.strike_seq == _ball_prev_seq else Vector3.INF
	_check_body_hit(path_from)
	_check_carom(path_from)
	_ball_prev = ball.global_position
	_ball_prev_seq = ball.strike_seq
	_tick_one_touch(delta)

















func _check_carom(path_from: = Vector3.INF) -> void :






	if not live or dead or ball.strike_seq == _carom_seen:
		return
	var who: = Rules.carom_body(ball, players, path_from)
	if who == null:
		return







	if who == server and not serve_done:
		return
	var reason: int = Rules.Bar.NONE if practice else Rules.bar_reason(who, last_toucher, team_size, touch_count, 
		float(touch_side), false, serve_crossed, serve_side, server, 
		touch_lock_side if touch_lock > 0.0 else 0)
	if reason == Rules.Bar.CONSECUTIVE or reason == Rules.Bar.TEAM_LOCK:
		return



	if reason != Rules.Bar.SERVE and who.held_receive_save():
		return
	var vin: = ball.vel
	var power: = ball.carom(who, ball.strike_seq)
	_carom_seen = ball.strike_seq



	if power >= 1.0:
		who.knock_off_ball(vin)



	who.carom_hit(power)
	touch_flair.emit("carom", who)
	if reason == Rules.Bar.SERVE and not practice:
		whistle_fault.emit("serve foul", who.global_position)
		end_rally( - who.team_side, "serve foul")
















static var body_hit_rule: = true
func _check_body_hit(path_from: Vector3) -> void :
	if not body_hit_rule or not live or dead or ball.strike_seq == _carom_seen:
		return
	var hit: = Rules.body_hit(ball, path_from, players, last_touch_side)
	if hit.is_empty():
		return
	var who: Player = hit[0]
	if who.held_receive_save():
		return



	var blocking: = Rules.body_blocking(who, ball)
	var vin: = ball.vel
	var kind_in: = ball.last_hit_kind
	var power: = ball.body_deflect(who, hit[1], ball.strike_seq)
	_carom_seen = ball.strike_seq


	if Rules.body_knocks(who, kind_in, power):
		who.knock_off_ball(vin)
	_body_hit_by = who if blocking else null
	who.body_hit(power, blocking)
	_body_hit_by = null

	if not blocking:
		touch_flair.emit("carom", who)

var _cross_seen: = 0

func _check_crossing() -> void :





	if live and ball.cross_seq != _cross_seen:
		_cross_seen = ball.cross_seq






		if ball.cross_outside and last_touch_side != 0 and not practice:
			whistle_fault.emit("outside the antenna", ball.global_position)
			end_rally( - last_touch_side, "outside the antenna")
			return
	var c: = Rules.net_crossing(ball.global_position.z, prev_ball_side)
	prev_ball_side = c.side
	if not c.crossed:
		return
	last_toucher = null
	_settle_set()
	quick_set_side = 0
	_quick_set_at = - INF
	_quick_setter = null





	if not serve_crossed:

		serve_attack_window = true
	serve_crossed = true











const SWEAT_TIME_START: = 22.0
const SWEAT_TIME_FULL: = 70.0
const SWEAT_TOUCH_GATE: = 6

func sweat_target() -> float:





	if not live or not GameConfig.sweat_enabled:
		return 0.0



	var rate: = maxf(GameConfig.sweat_rate, 0.01)
	var gate: = SWEAT_TOUCH_GATE if rate <= 1.0 else maxi(1, int(float(SWEAT_TOUCH_GATE) / rate))
	if sweat_touches < gate:
		return 0.0
	var start: = SWEAT_TIME_START / rate
	var full: = SWEAT_TIME_FULL / rate
	return clampf((rally_time - start) / (full - start), 0.0, 1.0)

func bot_aggression() -> float:


	return clampf((rally_time - 8.0) / 15.0, 0.0, 1.0)









func _counts_as_receive(who: Player) -> bool:
	return live and not (who == server and not serve_done)




func _settle_set() -> void :
	var was: = _pending_set
	_pending_set = null
	if was != null and is_instance_valid(was):
		received.emit(was, true)








const ONE_TOUCH_DELAY: = 0.3
var _one_touch_by: Player = null
var _one_touch_left: = 0.0









const BLOCK_ACTION_WINDOW: = 0.3
static var block_action_rule: = true
var _block_action_side: = 0
var _block_action_until: = - INF

func _tick_one_touch(delta: float) -> void :
	if _one_touch_by == null:
		return
	if not live or dead or not is_instance_valid(_one_touch_by):
		_one_touch_by = null
		return
	_one_touch_left -= delta
	if _one_touch_left > 0.0:
		return
	var who: = _one_touch_by
	_one_touch_by = null
	who.show_callout(Player.CALLOUT_ONE_TOUCH)
	auto_callout.emit(who, Player.CALLOUT_ONE_TOUCH)

func judge_touch(kind: int, who: Player) -> void :


	var receive_ok: = _counts_as_receive(who)










	var block_follow: = kind == Player.TouchKind.BLOCK and block_action_rule\
	and _block_action_side == who.team_side\
	and rally_time <= _block_action_until
	var real_block: = kind == Player.TouchKind.BLOCK\
	and (practice or block_follow or last_touch_side != who.team_side)

	var body_block: = kind == Player.TouchKind.CAROM and who == _body_hit_by

	if not block_follow and not body_block:
		_block_action_side = 0

	_one_touch_by = null


	if _assist_spiker != null:
		_assist_helper = null
		_assist_spiker = null
	if who == server and not serve_done:
		serve_done = true



		if Rules.serve_foot_fault(serve_launch_z, court.half_l) and not practice:
			whistle_fault.emit("foot fault", who.global_position)
			end_rally( - server.team_side, "foot fault")





	if who.team_side != serve_side:
		serve_received = true




	if not serve_crossed and who.team_side != serve_side:
		serve_crossed = true
		serve_attack_window = true




		prev_ball_side = float(who.team_side)
	if serve_attack_window:
		serve_attack_window = false





		var attacking: = kind == Player.TouchKind.SPIKE\
		or kind == Player.TouchKind.DUMP
		var high_block: = kind == Player.TouchKind.BLOCK\
		and ball.global_position.y > Ball.PHYS.net_height
		if (attacking or high_block) and not practice:
			whistle_fault.emit("illegal attack on serve", who.global_position)
			end_rally( - who.team_side, "illegal attack on serve")









	if not real_block and not body_block and touch_count >= Rules.TOUCHES_PER_SIDE\
	and who.team_side == touch_side and not practice:
		whistle_fault.emit("four touches", who.global_position)
		end_rally( - who.team_side, "four touches")
		return
	var blocked_kind: = last_touch_kind
	last_touch_side = who.team_side
	last_touch_kind = kind
	team_last_toucher[who.team_side] = who


	sweat_touches += 1





	touch_lock_side = who.team_side
	touch_lock = TOUCH_LOCK
	for p in players:
		var mate: Player = p
		if mate != who and mate.team_side == who.team_side:


			mate.touch_barred = true
			mate.touch_bar_reason = Rules.Bar.TEAM_LOCK




	if kind == Player.TouchKind.SET:
		quick_set_side = who.team_side
		_quick_set_at = rally_time
		_quick_setter = who
	else:
		var quick_attack: = (kind == Player.TouchKind.SPIKE\
		or kind == Player.TouchKind.DUMP)\
		and quick_set_side == who.team_side\
		and _quick_setter != null and _quick_setter != who\
		and rally_time - _quick_set_at <= QUICK_TEMPO_WINDOW
		if quick_attack:
			who.show_float_text("quick!", QUICK_COLOR)
			touch_flair.emit("quick", who)

		quick_set_side = 0
		_quick_set_at = - INF
		_quick_setter = null



	if kind == Player.TouchKind.SPIKE and who.last_perfect:
		touch_flair.emit("perfect", who)

	if who.diving() and kind != Player.TouchKind.CAROM:
		touch_flair.emit("dive", who)




	if (kind == Player.TouchKind.SPIKE or kind == Player.TouchKind.DUMP)\
	and _pending_set != null and is_instance_valid(_pending_set)\
	and _pending_set != who and _pending_set.team_side == who.team_side:
		if stats.has(_pending_set):
			stats[_pending_set].rcv -= 1
			stats[_pending_set].set += 1
		_pending_set = null
	if kind == Player.TouchKind.SPIKE\
	and _assist_feed != null and is_instance_valid(_assist_feed)\
	and _assist_feed != who and _assist_feed.team_side == who.team_side:
		_assist_helper = _assist_feed
		_assist_spiker = who
	_assist_feed = null
	_settle_set()
	if body_block:




		touch_count = 0
		last_toucher = null
		touch_side = 0
		touch_lock = 0.0
		touch_lock_side = 0
		_block_action_side = who.team_side
		_block_action_until = rally_time + BLOCK_ACTION_WINDOW

		last_touch_kind = Player.TouchKind.BLOCK

		if signf(ball.vel.z) == signf(who.team_side):
			_one_touch_by = who
			_one_touch_left = ONE_TOUCH_DELAY
		return
	match kind:
		Player.TouchKind.BLOCK:



			if real_block:




				var broken: bool = who.block_was_broken()


				if not block_follow:
					_block_action_side = who.team_side
					_block_action_until = rally_time + BLOCK_ACTION_WINDOW
				if not broken and not block_follow and stats.has(who):
					stats[who].blk += 1



				if not broken and signf(ball.vel.z) == signf(who.team_side):
					_one_touch_by = who
					_one_touch_left = ONE_TOUCH_DELAY


				touch_count = 0
				last_toucher = null
				touch_side = 0






				touch_lock = 0.0
				touch_lock_side = 0
				for brain in bots.values():
					(brain as TeamBot).distract(randf_range(0.25, 0.5))
				if not broken and not block_follow:
					touch_flair.emit("stuff", who)




				if not broken and blocked_kind == Player.TouchKind.SPIKE:
					who.show_combo(0, true)
				return
		Player.TouchKind.BUMP:


			if receive_ok and not who.kicked():
				if stats.has(who):
					stats[who].rcv += 1


					if who.diving():
						stats[who].dig = int(stats[who].get("dig", 0)) + 1
				received.emit(who, false)
			_assist_feed = who
		Player.TouchKind.SPIKE:


			if stats.has(who):
				stats[who].spk = int(stats[who].get("spk", 0)) + 1
		Player.TouchKind.SET:
			if receive_ok:


				if stats.has(who):
					stats[who].rcv += 1
				_pending_set = who
			_assist_feed = who



	if who.team_side != touch_side:
		touch_count = 0
		last_toucher = null
		touch_side = who.team_side
	touch_count += 1
	last_toucher = who
	if practice:
		dead = false




	var combo_fail: = touch_count == 3 and not practice\
	and (kind == Player.TouchKind.BUMP or kind == Player.TouchKind.SET)


	if kind != Player.TouchKind.CAROM:
		who.show_combo(touch_count, combo_fail)



func ball_bounced() -> void :



	_one_touch_by = null
	_block_action_side = 0
	if not live:
		return
	if practice:




		if not dead and serve_done:
			verdict.emit(ball.global_position, landing_call(ball.global_position), 0)
		ball_down()
		return



	if server != null and not serve_done:
		whistle_fault.emit("serve foul", server.global_position)
		end_rally( - server.team_side, "serve foul")
		return
	var p: = ball.global_position


	var in_court: = Rules.ball_in(p, court.half_w, court.half_l, court.center_x)
	var winner: = - int(signf(p.z)) if in_court else - last_touch_side
	if TeamBot.DEBUG_AI:
		var loser: = int(signf(p.z))
		var info: = ""
		var avoidable: = false
		for pl in players:
			var m: Player = pl
			if m == null or not is_instance_valid(m) or m.team_side != loser:
				continue
			var d: = Vector2(m.global_position.x - p.x, m.global_position.z - p.z).length()
			var br: TeamBot = bots.get(m)
			var md: = (-1 if br == null else br._mode)


			if d < 2.2 and m.is_on_floor() and m.contact_state == 0:
				avoidable = true
			info += " [%s d=%.1f cs=%d mode=%d %s]" % [m.name, d, m.contact_state, md, 
				("BOT" if br != null else "HUMANBODY")]




			if d < 1.5:
				info += " {bar=%s/%d arm=%d win=%.2f stamp=%d/%d opp=%d" % [
					str(m.touch_barred), m.touch_bar_reason, m._armed_kind, 
					m._receive_window, m._intent_used_strike, ball.strike_seq, 
					m.contact_opportunity_kind()]
				if br != null:
					info += " hold=%s sethold=%s cd=%.2f atk=%s jh=%.2f" % [
						str(br._holding), str(br._set_holding), br._touch_cooldown, 
						str(br._attacking), br._jump_hold]


				info += " | tl=%.2f reach=%s elig=%s pri=%s wfr=%s afg=%s spent=%s floor=%s en=%s held=%s" % [
					m._touch_lock, str(m._swing_reach_check()), 
					str(m.queued_contact_eligible()), 
					str(bool(m.contact_priority_check.call(m))\
					if m.contact_priority_check.is_valid() else "n/a"), 
					str(m._armed_wait_for_release), str(m._armed_from_ground), 
					str(m._air_spent), str(m.is_on_floor()), str(m.contact_enabled), 
					str(m._contact_button_held)]
				info += "}"

		print("[DROP]%s%s %s at (%.1f,%.1f) loser=%d last=%d lastkind=%d bspd=%.1f%s" % [
			(" AVOIDABLE" if avoidable and in_court else ""), 
			(" ACE" if serve_crossed and not serve_received else ""), 
			("IN" if in_court else "OUT"), p.x, p.z, loser, last_touch_side, 
			ball.last_hit_kind, Vector2(ball.vel.x, ball.vel.z).length(), info])
	verdict.emit(p, landing_call(p), winner)
	end_rally(winner, "" if in_court else "ball out")





func landing_call(p: Vector3) -> String:
	if Rules.ball_in(p, court.half_w, court.half_l, court.center_x):
		return "ball in"
	return "block out" if last_touch_kind == Player.TouchKind.BLOCK else "ball out"

func ball_hit_wall() -> void :

	if not live:
		return
	end_rally( - last_touch_side, "ball out")



func end_rally(winner_side: int, reason: = "") -> void :
	_minigame_armed = false
	if practice:
		ball_down()
		return
	if _ended:
		return
	_ended = true
	live = false
	_settle_set()
	touch_lock = 0.0
	quick_set_side = 0
	_quick_set_at = - INF
	_quick_setter = null

	for p in players:
		(p as Player).clear_settle()
	if winner_side == 0:
		winner_side = - serve_side



	if rotate_every_point and winner_side == serve_side and last_serve_side != 0:
		rot[winner_side] = int(rot.get(winner_side, 0)) + 1
	serve_side = winner_side
	scores[winner_side] = int(scores[winner_side]) + 1

	var scorer: Player = team_last_toucher.get(winner_side)
	if scorer != null and stats.has(scorer):
		stats[scorer].pts += 1



	if reason == "" and server != null and is_instance_valid(server)\
	and winner_side == server.team_side and serve_crossed\
	and not serve_received and stats.has(server):
		stats[server].ace = int(stats[server].get("ace", 0)) + 1
	if _assist_spiker == scorer and _assist_helper != null\
	and is_instance_valid(_assist_helper) and stats.has(_assist_helper):
		stats[_assist_helper].ast = int(stats[_assist_helper].get("ast", 0)) + 1


	var kill_power: = 0.0
	for p in players:
		var member: Player = p
		if member.team_side == winner_side\
		and member.last_touch == Player.TouchKind.SPIKE:
			kill_power = maxf(kill_power, member.last_touch_power)
	var winners_ball: = last_touch_side == winner_side
	point.emit(winner_side, reason, scorer, kill_power, winners_ball)
	var lead: int = int(scores[winner_side]) - int(scores[ - winner_side])
	if not endless and int(scores[winner_side]) >= set_points\
	and ( not win_by_two or lead >= 2):
		set_won.emit(winner_side)



func kill_ball() -> void :
	if _ended:
		return
	_ended = true
	live = false
	_settle_set()
	touch_lock = 0.0
	touch_lock_side = 0
	touch_count = 0
	touch_side = 0
	last_toucher = null
	quick_set_side = 0
	_quick_set_at = - INF
	_quick_setter = null
	for p in players:
		(p as Player).clear_settle()
	ball_dead.emit()



func ball_down() -> void :
	if dead:
		return
	dead = true
	_minigame_armed = false





	serve_done = true
	_settle_set()
	touch_count = 0
	touch_side = 0
	last_toucher = null
	quick_set_side = 0
	_quick_set_at = - INF
	_quick_setter = null
	ball_dead.emit()




var _call_grace: = 0.0

func practice_serve(holder: Player) -> void :
	_minigame_armed = false
	_call_grace = 0.0
	_auto_serve_left = -1.0
	holder.serve_style.clear()
	dead = false
	live = false
	server = holder
	serve_side = holder.team_side
	serve_done = false
	serve_launch_z = absf(holder.global_position.z)
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.global_position = holder.serve_cradle_point()
	ball.reset_physics_interpolation()
	begin_serve(false)


func reset_set(serving_side: = 0) -> void :
	scores[1] = 0
	scores[-1] = 0
	rot = {1: 0, -1: 0}
	last_serve_side = 0
	if serving_side != 0:
		serve_side = serving_side
	_ended = true
	live = false
