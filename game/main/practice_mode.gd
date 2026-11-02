class_name PracticeMode
extends RefCounted















const PARK: = Vector3(0.0, -40.0, 0.0)
const PARK_Y: = -20.0
const CROSS_DEADBAND: = 0.4

var main: Node = null
var _kicked_off: = false





const PAD_STAMINA: = "stamina"
const PAD_HINTS: = "hints"
const PAD_COLLIDE: = "collide"
const PAD_CALL: = "call"
const PAD_SIZE: = "size"
const SIZE_COLOR: = Color(0.62, 0.42, 1.0)
const TOGGLES: = [PAD_STAMINA, PAD_HINTS, PAD_COLLIDE, PAD_CALL]



const COL_X: = 4.0
const SIZE_COL_X: = 6.4
const ROW_Z0: = 1.8
const ROW_DZ: = 2.3
const SIZE_Z0: = 1.4
const SIZE_DZ: = 1.5
const SIZE_RADIUS: = 0.55
const CALL_COLOR: = Color(1.0, 0.5, 0.62)

const DEAD_OUTLINE: = Color(0.95, 0.18, 0.2)
const STAMINA_COLOR: = Color(0.1, 0.78, 1.0)
const COLLIDE_COLOR: = Color(0.2, 0.95, 0.35)
const HINTS_COLOR: = Color(1.0, 0.55, 0.05)
var pads: FreeplayPads = null
var _hints: = true

var _saved_collide: = true







static var solo_size: = 6
static var solo_collide: = true
static var solo_call_all: = true


func _solo() -> bool:
	return main._net_role == main.NetRole.OFFLINE

func court_size() -> int:
	return solo_size if _solo() else Net.practice_size

func collide_on() -> bool:
	return solo_collide if _solo() else Net.practice_collide

func call_all() -> bool:
	return solo_call_all if _solo() else Net.practice_call_all

func setup(m: Node) -> void :
	main = m
	_saved_collide = GameConfig.team_collision
	main._recorder.stop()
	var rally: Rally = main._rally
	rally.practice = true
	rally.endless = true
	main._replay_enabled = false
	if main._net_role != main.NetRole.CLIENT:
		rally.ball_dead.connect(_on_ball_dead)
	pads = FreeplayPads.new()
	main.add_child(pads)
	var colors: = {PAD_STAMINA: STAMINA_COLOR, PAD_HINTS: HINTS_COLOR, 
		PAD_COLLIDE: COLLIDE_COLOR, PAD_CALL: CALL_COLOR}
	var entries: Array = []
	for side in [1, -1]:
		var tag: = _side_tag(side)
		for i in TOGGLES.size():
			entries.append({"id": TOGGLES[i] + tag, "color": colors[TOGGLES[i]], 
				"pos": pad_pos(main._half_w, side, false, i)})
		for n in range(1, Net.PRACTICE_SIZE + 1):
			entries.append({"id": "%s%d%s" % [PAD_SIZE, n, tag], "color": SIZE_COLOR, 
				"radius": SIZE_RADIUS, "pos": pad_pos(main._half_w, side, true, n - 1)})
	pads.build_entries(entries)
	_size_applied = court_size()
	pads.stepped.connect(_on_pad)
	_refresh_pads()




	if not _solo():
		Net.party_look.connect(_on_party_look)


func place_pads() -> void :
	if pads == null:
		return
	for side in [1, -1]:
		var tag: = _side_tag(side)
		for i in TOGGLES.size():
			pads.move_pad(TOGGLES[i] + tag, pad_pos(main._half_w, side, false, i))
		for n in range(1, Net.PRACTICE_SIZE + 1):
			pads.move_pad("%s%d%s" % [PAD_SIZE, n, tag], pad_pos(main._half_w, side, true, n - 1))

var _size_applied: = 0


func _local_bodies() -> Array:
	var out: Array = []
	if main.player != null and not main._spectating:
		out.append(main.player)
	for seat in main._seats:
		if seat.body != null:
			out.append(seat.body)
	return out


static func pad_pos(half_w: float, side: int, size_col: bool, i: int) -> Vector3:
	if size_col:
		return Vector3( - (half_w + SIZE_COL_X), 0.03, float(side) * (SIZE_Z0 + SIZE_DZ * i))
	return Vector3( - (half_w + COL_X), 0.03, float(side) * (ROW_Z0 + ROW_DZ * i))

static func _side_tag(side: int) -> String:
	return "@h" if side > 0 else "@a"



func _is_court_host() -> bool:
	return main._net_role != main.NetRole.CLIENT

func _denied(body: Player, color: Color) -> void :
	UiStyle.sfx("error")
	body.show_float_text("host only", color, false, 1.1, false)

func _on_pad(pad_id: String, body: Player) -> void :
	var id: = pad_id.split("@")[0]
	if id.begins_with(PAD_SIZE):
		if not _is_court_host():
			_denied(body, SIZE_COLOR)
			return
		var n: = clampi(int(id.substr(PAD_SIZE.length())), 1, Net.PRACTICE_SIZE)
		if n == court_size():
			return




		if _solo():
			solo_size = n
		else:
			Net.practice_size = n
			Net.sync_lobby()
		UiStyle.sfx("toggle_on")
		_refresh_pads()
		return
	match id:
		PAD_STAMINA:
			set_stamina(body, not body.stamina_unlimited)
			if main._net_role == main.NetRole.CLIENT:
				Net.send_up("pstam", {"id": int(main._net_ids_of(body)), 
					"on": body.stamina_unlimited})
		PAD_HINTS:
			_hints = not _hints
			main.ball.hints = _hints and GameConfig.ball_hints
		PAD_COLLIDE:
			if not _is_court_host():
				_denied(body, COLLIDE_COLOR)
				return
			if _solo():
				solo_collide = not solo_collide
			else:
				Net.practice_collide = not Net.practice_collide
				Net.sync_lobby()
		PAD_CALL:
			if not _is_court_host():
				_denied(body, CALL_COLOR)
				return
			if _solo():
				solo_call_all = not solo_call_all
			else:
				Net.practice_call_all = not Net.practice_call_all
				Net.sync_lobby()
	_refresh_pads()


	var on_now: = pads.is_on(pad_id)
	UiStyle.sfx("toggle_on" if on_now else "toggle_off")

func set_stamina(body: Player, on: bool) -> void :
	body.stamina_unlimited = on
	body.show_float_text("infinite stamina on" if on else "infinite stamina off", 
		STAMINA_COLOR, false, 1.1, false)

func _refresh_pads() -> void :
	if pads == null:
		return
	var inf: bool = main.player != null and main.player.stamina_unlimited
	var col: = collide_on()
	var everyone: = call_all()
	for side in [1, -1]:
		var tag: = _side_tag(side)
		pads.set_state(PAD_STAMINA + tag, inf, "infinite stamina: on" if inf else "infinite stamina: off")
		pads.set_state(PAD_HINTS + tag, _hints, "ball hints: on" if _hints else "ball hints: off")
		pads.set_state(PAD_COLLIDE + tag, col, "collisions: on" if col else "collisions: off")
		pads.set_state(PAD_CALL + tag, everyone, "call ball: all" if everyone else "call ball: host")
		for n in range(1, Net.PRACTICE_SIZE + 1):
			pads.set_state("%s%d%s" % [PAD_SIZE, n, tag], n == court_size(), "%dv%d" % [n, n])




static func apply_court_size(n: int) -> void :
	GameConfig.set_mode(clampi(n, 1, Net.PRACTICE_SIZE))
	var hw: = GameConfig.court_half_width
	var hl: = GameConfig.court_half_length
	GameConfig.set_mode(Net.PRACTICE_SIZE)
	GameConfig.court_half_width = hw
	GameConfig.court_half_length = hl


func ball_called(skin: = "") -> void :
	_ball_called = true
	main.ball.visible = true
	if skin != "" and Stage.STAGES.has(skin):
		main.ball.set_ball_skin(skin)

func ball_shown() -> bool:
	return _ball_called or main._net_role != main.NetRole.CLIENT


func _on_party_look(pid: int, outfit: String) -> void :
	var body: Player = main._body_of_peer(pid)
	var cfg: Dictionary = (Net.players.get(pid, {}) as Dictionary).get("cfg", {})
	if body == null or cfg.is_empty():
		return
	var fit: Array = main._stage_outfit(CharacterConfig.from_dict(Mod.shown_cfg(pid, cfg)), 
		main._team_kit_for(body.team_side), outfit)
	body.set_character(fit[0], fit[1])


func redress_self(outfit: String) -> void :
	if main.player == null or GameConfig.character == null:
		return
	var fit: Array = main._stage_outfit(GameConfig.character, 
		main._team_kit_for(main.player.team_side), outfit)
	main.player.set_character(fit[0], fit[1])


func teardown() -> void :
	if Net.party_look.is_connected(_on_party_look):
		Net.party_look.disconnect(_on_party_look)
	if not main.embedded:
		GameConfig.team_collision = _saved_collide

static func active() -> bool:
	return Net.practice










var _wish: = {}

func want_present(peer_id: int, on: bool) -> void :
	_wish[peer_id] = on



func wants_on(peer_id: int) -> bool:
	return bool(_wish.get(peer_id, false))





func anyone_present() -> bool:
	for pid in _wish:
		if bool(_wish[pid]):
			return true
	for b in main._all_players:
		if b != null and is_instance_valid(b) and not b.is_bot and not _away.has(b):
			return true
	return false

func host_tick(_delta: float) -> void :


	if main.player != null:
		var me_away: = _away.has(main.player)
		for b in _local_bodies():
			if b != main.player and _away.has(b) != me_away:
				apply_present(b, not me_away)
	for pid in _wish.keys():
		var on: = bool(_wish[pid])
		for wb in main._owner_bodies(int(pid)):


			if _away.has(wb) == on:
				apply_present(wb, on)
	_park_brains()
	for b in _away.keys():
		if is_instance_valid(b):
			_pin_away(b)
		else:
			_away.erase(b)
	_switch_teams()
	_apply_rules()






	if main._phase != main.Phase.LIVE or main._rally.dead:
		main._apply_seat_requests()
	if _kicked_off:
		_call_ball()
	var dead: = 1 if (main._rally.dead or main._phase == main.Phase.DEAD) else 0
	if dead != _dead_sent:
		_dead_sent = dead
		paint_dead(dead == 1)
		main._net_event("pdead", {"on": dead == 1})



func dead_tick(_delta: float) -> void :
	if not _kicked_off:
		_kicked_off = true
		main._did_intro = true
		main._intros_run += 1
		main._pre_intro = false
		main._loading_up = false
		main.hud.set_loading(0.0)
		main.camera_rig.cinematic = false
		main.ball.visible = false

func _park_brains() -> void :
	for b in main._bots.keys():
		park(b)

func park(body: Player) -> void :


	if body == main._rally.server and main._phase == main.Phase.SERVE_PREP:
		main.ball.frozen = false
		main._rally.server = null
		main._rally.kill_ball()
	main._bots.erase(body)
	body.is_bot = true
	body.clear_action_state()
	body.velocity = Vector3.ZERO
	body.global_position = PARK + Vector3(0.0, 0.0, 6.0 * float(body.team_side))
	body.reset_physics_interpolation()
	body.visible = false





var _away: = {}

func set_present(on: bool) -> void :
	var me: Player = main.player
	if me == null:
		return
	if main._net_role == main.NetRole.CLIENT:
		Net.send_up("pact", {"on": on})
	else:
		for b in _local_bodies():
			apply_present(b, on)

func apply_present(body: Player, on: bool) -> void :
	_dead_sent = -1
	if on:
		if _away.has(body):
			_away.erase(body)
			var side: = float(body.team_side if body.team_side != 0 else 1)
			var spot: = Vector3(randf_range(-2.0, 2.0), 0.0, side * 8.0)
			unpark(body, spot)
	else:
		if body == main._rally.server and main._phase == main.Phase.SERVE_PREP:
			main.ball.frozen = false
			main._rally.server = null
			main._rally.kill_ball()
		_away[body] = true
		body.clear_action_state()
		_pin_away(body)

func _pin_away(body: Player) -> void :
	body.velocity = Vector3.ZERO
	body.global_position = PARK + Vector3(3.0, 0.0, 0.0)
	body.visible = false

static func is_parked(body: Player) -> bool:
	return body.global_position.y < PARK_Y


func unpark(body: Player, at: Vector3) -> void :
	body.visible = true
	body.global_position = at
	body.velocity = Vector3.ZERO
	body.reset_physics_interpolation()






func _switch_teams() -> void :
	var changes: Array = []
	for p in main._all_players:
		var body: Player = p
		if is_parked(body) or body.is_bot:
			continue
		var z: = body.global_position.z
		var half: = 1 if z > CROSS_DEADBAND else (-1 if z < - CROSS_DEADBAND else 0)
		if half == 0 or half == body.team_side:
			continue



		if not body.is_on_floor():
			continue
		var swap: Player = _parked_on(half)
		if swap == null:
			continue
		body.team_side = half
		changes.append([int(main._net_ids.get(body, 0)), half])
		swap.team_side = - half
		changes.append([int(main._net_ids.get(swap, 0)), - half])

		var sa: int = int(main._slots.get(body, 0))
		main._slots[body] = int(main._slots.get(swap, 0))
		main._slots[swap] = sa
		if body == main._rally.server:
			main._rally.serve_side = half
		_local_moved = _local_moved or _local_bodies().has(body)
	if not changes.is_empty():
		main._net_event("pside", {"l": changes})
	if _local_moved:
		_local_moved = false
		local_sides_changed()

var _local_moved: = false




func local_sides_changed() -> void :
	if main.player != null:
		main.camera_rig.home_side = float(main.player.team_side)
		main.ball.home_side = float(main.player.team_side)
	if main._seats.is_empty():
		return
	for seat in main._seats:
		if seat.rig != null and seat.body != null:
			(seat.rig as CameraRig).home_side = float((seat.body as Player).team_side)
	var sig: = ""
	for b in _local_bodies():
		sig += str((b as Player).team_side)
	if sig != _sides_sig:
		_sides_sig = sig
		main._rebuild_local_views()

var _sides_sig: = ""

func _parked_on(side: int) -> Player:
	for p in main._all_players:
		var body: Player = p
		if body.is_bot and body.team_side == side:
			return body
	return null


func _apply_rules() -> void :
	shared_tick()





func _call_ball() -> void :
	for p in main._all_players:
		var body: Player = p
		if body.is_bot or is_parked(body):
			continue
		if not call_all() and not _local_bodies().has(body):
			continue
		var input: PlayerInput = main._tick_inputs.get(body)
		if input == null:
			continue
		if input.call_pressed:
			spawn_ball(body)
			input.serve_pressed = false
			return
		if body == main._rally.server and main._phase == main.Phase.SERVE_PREP:
			continue
		if input.serve_pressed:
			give_ball(body)
			input.serve_pressed = false
			return

func spawn_ball(holder: Player) -> void :
	give_ball(holder)
	main._rally.do_toss(0.0)
	main._rally.serve_done = true
	main._rally.serve_crossed = true
	main._rally.serve_received = true
	main.ball.serve_assist = false
	main.ball.serve_held = false
	main.ball.toss(holder.global_position + Vector3(0.0, 2.6, 0.0), 0.0)

func give_ball(holder: Player) -> void :
	main._close_serve_minigame()
	main._hide_landing_call()
	main.ball.visible = true


	var skin: = _ball_of(holder)
	if skin != "":
		main.ball.set_ball_skin(skin)
	main._rally.practice_serve(holder)
	main._phase = main.Phase.SERVE_PREP
	main._net_event("serve", {"sk": skin})



func _ball_of(body: Player) -> String:
	var skin: = ""
	if _local_bodies().has(body):
		skin = GameConfig.menu_ball
	else:
		var pid: = int(main._seat_owner.get(body, 0))
		skin = String((Net.players.get(pid, {}) as Dictionary).get("ball", ""))
	return skin if Stage.STAGES.has(skin) else ""



var _call_denied_at: = -10000

func call_pressed() -> void :
	if call_all() or main.player == null:
		return
	var now: = Time.get_ticks_msec()
	if now - _call_denied_at < 1000:
		return
	_call_denied_at = now
	UiStyle.sfx("error")





func _on_ball_dead() -> void :
	if main._rally.live:
		return
	main._phase = main.Phase.DEAD
	main.crowd.serve_stop()



var _dead_sent: = -1

func paint_dead(on: bool) -> void :
	main.ball.outline_override = DEAD_OUTLINE if on else Color(0, 0, 0, 0)





var _hidden: = {}

var _hints_set: = false



var _ball_called: = false











var _warm_left: = -1
var _warm_ghost: Node3D = null
const WARM_TICKS: = 8

func _prewarm_tick() -> void :
	if _warm_left == 0:
		return
	if _warm_left > 0:
		_warm_left -= 1
		if _warm_left == 0 and is_instance_valid(_warm_ghost):
			_warm_ghost.queue_free()
			_warm_ghost = null
		return
	if not main.embedded_active or main.camera_rig == null:
		return
	var cam: Camera3D = main.camera_rig.camera
	if cam == null:
		return
	var fwd: = - cam.global_basis.z
	fwd.y = 0.0
	fwd = fwd.normalized() if fwd.length() > 0.01 else Vector3.FORWARD
	var at: = cam.global_position + fwd * 30.0
	at.y = -2.0
	_warm_ghost = Node3D.new()
	main.add_child(_warm_ghost)
	_warm_ghost.global_position = at
	var ball: Node3D = main.ball
	var inv: = ball.global_transform.affine_inverse()
	for n in ball.find_children("*", "GeometryInstance3D", true, false):
		var gi: = n as GeometryInstance3D
		if gi is GPUParticles3D or gi.get_script() != null:
			continue
		var dup: = gi.duplicate(0) as GeometryInstance3D
		for c in dup.get_children():
			c.free()
		dup.transform = inv * gi.global_transform
		dup.visible = true
		_warm_ghost.add_child(dup)
	var fx: Fx = main.fx
	fx.impact(at, 0.6)
	fx.burst(at, 0.6, Vector3.UP)
	fx.ring(at, Vector3.UP, 0.6)
	fx.puff(at)
	fx.land_poof(at)
	fx.speed_lines(at, Vector3.FORWARD, 0.6)
	fx.combo_burst(at, Vector3.FORWARD, 2)
	_warm_left = WARM_TICKS

func shared_tick() -> void :
	_prewarm_tick()

	if court_size() != _size_applied and pads != null:
		_size_applied = court_size()
		var d: = GameConfig.court_dims(_size_applied)
		main.resize_court(d.x, d.y)
		_refresh_pads()



	if main._net_role == main.NetRole.CLIENT and not _ball_called:
		main.ball.visible = false
	if not _hints_set:
		_hints_set = true
		main.hud.set_practice_controls(true)
	if pads != null:
		pads.tick(_local_bodies())
		_refresh_pads()
	main.hud.set_scoreboard_visible(false)



	if main.embedded:
		main.get_viewport().set_meta("team_collision", collide_on())
	else:
		GameConfig.team_collision = collide_on()
	for p in main._all_players:
		var body: Player = p
		if is_parked(body):
			if body.visible:
				body.visible = false
				_hidden[body] = true
		elif _hidden.has(body):
			_hidden.erase(body)
			body.visible = true
