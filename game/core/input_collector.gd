class_name InputCollector
extends RefCounted








signal dive_denied

const STICK_AIM_RANGE: = 7.0
const STICK_DEADZONE: = 0.25
const LONG_AIM_RANGE: = 18.0









const HARD_AIM_MARGIN: = 8.0






const AIM_SPEED: = 21.0


const ASSIST_DELAY: = 2.0
const ASSIST_EASE: = 8.0
const DOUBLE_TAP_MS: = 300




var aim_min: = Vector2(-1000000.0, -1000000.0)
var aim_max: = Vector2(1000000.0, 1000000.0)






var profile = null

func _aim_assist() -> bool:
	return profile.aim_assist if profile != null else GameConfig.aim_assist






func _set_assist() -> bool:
	return profile.set_assist if profile != null else GameConfig.set_assist

func _sprint_is_toggle() -> bool:
	return profile.sprint_toggle if profile != null else GameConfig.sprint_toggle

func _sprint_double_tap() -> bool:
	return profile.sprint_double_tap if profile != null else GameConfig.sprint_double_tap

func _mouse_sens() -> float:
	return profile.mouse_sensitivity if profile != null else GameConfig.mouse_sensitivity

func _stick_sens() -> float:
	return profile.stick_sensitivity if profile != null else GameConfig.stick_sensitivity

var _last_aim: = Vector3.ZERO
var _aim_idle: = 0.0
var _auto_locked: = false
var _last_recenter_ms: = 0
var _was_attacking: = false
var _attack_manual: = false







const BUFFER_TIME: = 0.16

var _buf_dive: = 0.0
var _buf_block: = 0.0



const DTAP_WINDOW: = 0.28
const DTAP_MOVE_MIN: = 0.5
const MOVE_DIRS: = ["move_forward", "move_back", "move_left", "move_right"]
var _dtap_moving: = false
var _dtap_dir_t: = {}
var _dtap_sprint: = false
var _sprint_toggle: = false

var _buf_serve: = 0.0








var _swallow: = {}





var _dev: = DeviceInput.new()

var _set_snap_on: = false
var _set_snapped_aim: = Vector3.ZERO
var _set_release_left: = 0.0



var _proc_dev: = DeviceInput.new()





static var dev_assume_focus: = false:
	set(v):
		dev_assume_focus = v
		GameConfig.apply_pad_focus()

static var dev_cursor: = Vector2.INF

const TRACKED_ACTIONS: PackedStringArray = [
	"move_left", "move_right", "move_forward", "move_back", 
	"aim_left", "aim_right", "aim_up", "aim_down", 
	"jump", "contact", "set", "dive", "block", "serve", "strafe", "aim_recenter", 
	"back_pass", "sprint", "ball_spawn", "ball_despawn", 
]

func set_device(dev: int) -> void :
	_dev.device = dev
	_proc_dev.device = dev


func set_bindings(table: Dictionary) -> void :
	_dev.bindings = table
	_proc_dev.bindings = table

func device() -> int:
	return _dev.device



func set_exclude_pads(pads: PackedInt32Array) -> void :
	_dev.exclude_pads = pads



func set_exclude_kbm(value: bool) -> void :
	_dev.exclude_kbm = value





func _is_gamepad() -> bool:
	if _dev.device >= 0:
		return true
	if _dev.device == DeviceInput.KBM:
		return false
	if _dev.exclude_kbm:
		return true
	return InputPrompts.using_gamepad()

func swallow_held(actions: Array) -> void :
	for a in actions:
		if _dev.pressed(a):
			_swallow[a] = true


		if a == "dive" and _dev.pressed("block"):
			_swallow["block"] = true





func clear_buffers() -> void :
	_buf_dive = 0.0
	_buf_block = 0.0
	_buf_serve = 0.0

func _swallowed(action: String) -> bool:
	if not _swallow.has(action):
		return false
	if _dev.pressed(action):
		return true
	_swallow.erase(action)
	return true

func collect(rig: CameraRig, player: Player) -> PlayerInput:
	var dt: = get_physics_step()

	_dev.poll(TRACKED_ACTIONS)






	if not DisplayServer.window_is_focused() and DisplayServer.get_name() != "headless" and not dev_assume_focus and not GameConfig.pad_when_unfocused:
		_release_cursor()
		return PlayerInput.new()
	_buf_dive = maxf(_buf_dive - dt, 0.0)
	_buf_block = maxf(_buf_block - dt, 0.0)
	_buf_serve = maxf(_buf_serve - dt, 0.0)















	var ui_click: = mouse_freed and _over_ui(rig)
	var dive_dead: = _swallowed("dive") or ui_click
	var block_dead: = _swallowed("block") or ui_click
	var serve_dead: = _swallowed("serve")



	var want_dive: = _dev.just_pressed("dive") and not dive_dead
	var want_block: = _dev.just_pressed("block") and not block_dead
	if want_dive and want_block:



		if player != null and not player.is_on_floor():
			want_dive = false
		else:
			want_block = false
	if want_block:
		_buf_block = BUFFER_TIME
	if want_dive:
		_buf_dive = BUFFER_TIME


		if player != null and player.is_on_floor() and player.dive_cooldown > 0.0\
		and not player.diving() and not player.knocked():
			dive_denied.emit()





	if _is_gamepad() and player != null and not player.is_on_floor()\
	and _dev.just_pressed("strafe") and not block_dead:
		_buf_block = BUFFER_TIME
	if _dev.just_pressed("serve") and not serve_dead:
		_buf_serve = BUFFER_TIME

	var input: = PlayerInput.new()



	var raw_move: = _dev.get_vector("move_left", "move_right", "move_forward", "move_back")
	input.move_raw = _hitter_frame_stick(rig.camera, player, raw_move)
	input.move = _camera_relative_move(rig.camera, raw_move)

	var jump_dead: = _swallowed("jump")
	var contact_dead: = _swallowed("contact") or ui_click
	input.jump_held = not jump_dead and _dev.pressed("jump")
	input.jump_released = not jump_dead and _dev.just_released("jump")
	input.contact_pressed = not contact_dead and _dev.pressed("contact")
	input.contact_released = not contact_dead and _dev.just_released("contact")
	input.set_pressed = _dev.pressed("set")
	input.set_released = _dev.just_released("set")
	input.back_pass_pressed = _dev.pressed("back_pass")


	input.dive_pressed = _buf_dive > 0.0 and player != null\
	and player.dive_input_actionable()
	if input.dive_pressed:
		_buf_dive = 0.0
	input.block_pressed = _buf_block > 0.0 and player != null and player.block_input_actionable()
	if input.block_pressed:
		_buf_block = 0.0
	input.serve_pressed = _buf_serve > 0.0
	if input.serve_pressed:
		_buf_serve = 0.0
	input.call_pressed = _dev.just_pressed("ball_spawn")
	input.strafe_held = _dev.pressed("strafe")
	var now: = Time.get_ticks_msec() / 1000.0
	var moving: = input.move.length() > DTAP_MOVE_MIN



	var interrupted: = input.strafe_held\
	or (_dtap_moving and not moving)\
	or (player != null and (player.stamina_locked\
	or player.diving() or player.getting_up() or player.knocked()))



	if _sprint_is_toggle():
		if _dev.just_pressed("sprint"):
			_sprint_toggle = not _sprint_toggle
	else:
		_sprint_toggle = _dev.pressed("sprint")




	if not _is_gamepad() and _sprint_double_tap():
		for d in MOVE_DIRS:
			if _dev.just_pressed(d):
				if now - float(_dtap_dir_t.get(d, -9.0)) <= DTAP_WINDOW:
					_dtap_sprint = true
				_dtap_dir_t[d] = now
	if interrupted:
		_sprint_toggle = false
		_dtap_sprint = false



	if player != null and player.sprint_start_blocked():
		_sprint_toggle = false
		_dtap_sprint = false
	_dtap_moving = moving

	input.sprint_held = (_sprint_toggle or _dtap_sprint) and not input.strafe_held
	input.aim = _resolve_aim(rig, player)









	if player != null and player.serving and player.ball != null and player.ball.frozen\
	and (rig.mode == CameraRig.Mode.ACTION or rig.mode == CameraRig.Mode.FIRST_PERSON):
		input.aim = Ball.action_toss_aim(player.global_position, input.aim)
	_set_snap_on = false
	if player != null and _set_assist():
		if _dev.just_released("set"):
			_set_release_left = Player.FEEL.set_release_queue_window
		elif input.contact_pressed or _dev.just_pressed("set"):
			_set_release_left = 0.0
		_set_release_left = maxf(_set_release_left - get_physics_step(), 0.0)
		if _set_snap_active(player):
			input.aim = player.set_pocket_point(input.aim, player.pending_set_quick())
			_set_snapped_aim = input.aim
			_set_snap_on = true







	if input.dive_pressed and player != null and player.is_on_floor():
		input.aim = player._dive_intercept()



		var plan: = player.dive_plan(input.aim)
		input.dive_dir = plan.dir
		input.dive_side = int(plan.side)
	return input






func _set_snap_active(player: Player) -> bool:
	if _dev.pressed("set"):
		return true
	if not player.net_puppet:
		return player.contact_intent_queued()\
		and player.queued_contact_kind() == Player.TouchKind.SET
	return _set_release_left > 0.0

func get_physics_step() -> float:
	return 1.0 / float(maxi(Engine.physics_ticks_per_second, 1))









func _hitter_frame_stick(camera: Camera3D, player: Player, raw: Vector2) -> Vector2:
	if camera == null or player == null or player.team_side == 0:
		return raw
	var look: = - camera.global_basis.z
	look.y = 0.0
	if look.length_squared() < 0.0001:
		return raw
	var net_dir: = Vector3(0.0, 0.0, - float(player.team_side))
	var net_right: = net_dir.cross(Vector3.UP)

	var cam_fwd: = net_dir
	for axis in [ - net_dir, net_right, - net_right]:
		if (axis as Vector3).dot(look) > cam_fwd.dot(look):
			cam_fwd = axis
	var cam_right: = cam_fwd.cross(Vector3.UP)
	var world: = cam_right * raw.x - cam_fwd * raw.y
	return Vector2(world.dot(net_right), - world.dot(net_dir))

func _camera_relative_move(camera: Camera3D, raw: = Vector2.INF) -> Vector2:
	if raw == Vector2.INF:
		raw = _dev.get_vector("move_left", "move_right", "move_forward", "move_back")
	var fwd: = - camera.global_basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var right: = camera.global_basis.x
	right.y = 0.0
	right = right.normalized()
	var world: = right * raw.x + fwd * - raw.y
	return Vector2(world.x, world.z)

func _resolve_aim(rig: CameraRig, player: Player) -> Vector3:



	var camera: = rig.camera


	_aim_unshake = rig.shake_offset
	var gamepad: bool = _is_gamepad()



	var action_mode: = rig.mode == CameraRig.Mode.ACTION\
	or rig.mode == CameraRig.Mode.FIRST_PERSON

	if action_mode:
		var center: = camera.get_viewport().get_visible_rect().size * 0.5
		_ray_to_floor(camera, center)


		if rig.mode == CameraRig.Mode.FIRST_PERSON:
			_soft_aim_teammate(camera, center)
	elif gamepad:
		_adaptive_aim(rig, player)
	else:


		if player != null and _dev.just_pressed("aim_recenter"):
			_recenter_mouse(rig, player)
		else:
			_mouse_aim(camera)
	_clamp_aim(_aim_assist())
	return _last_aim






func _adaptive_aim(rig: CameraRig, player: Player) -> void :
	var dt: = get_physics_step()
	var attacking: = _assist_wants_control(player)





	var serving: = player != null and player.serve_charge_ui


	if attacking and not _was_attacking:
		_attack_manual = false
	_was_attacking = attacking



	if player != null and _dev.just_pressed("aim_recenter"):
		var now: = Time.get_ticks_msec()
		if now - _last_recenter_ms <= DOUBLE_TAP_MS:
			_auto_locked = true
			_last_recenter_ms = 0
		else:
			_last_recenter_ms = now


	if player != null and _dev.pressed("aim_recenter"):
		_last_aim = Vector3(player.global_position.x, 0.0, player.global_position.z)
		_aim_idle = 0.0
		return
	var stick: = _dev.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick.length() > STICK_DEADZONE:

		_auto_locked = false
		if attacking:
			_attack_manual = true
		_aim_idle = 0.0
		var cam: = rig.camera
		var fwd: = - cam.global_basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		var right: = cam.global_basis.x
		right.y = 0.0
		right = right.normalized()
		var dir: = right * stick.x + fwd * ( - stick.y)
		_last_aim += dir * AIM_SPEED * _stick_sens()\
		* minf(stick.length(), 1.0) * dt
	elif _auto_locked:


		_last_aim = _last_aim.lerp(_assist_target(player), 1.0 - exp( - ASSIST_EASE * dt))
	elif _aim_assist() and attacking and not serving:






		if not _attack_manual:
			_last_aim = _last_aim.lerp(_assist_target(player), 1.0 - exp( - ASSIST_EASE * dt))
	elif _controller_active(player):



		_aim_idle = 0.0
	elif _aim_assist() and not serving:



		_aim_idle += dt
		if _aim_idle >= ASSIST_DELAY:
			_last_aim = _last_aim.lerp(_assist_target(player), 1.0 - exp( - ASSIST_EASE * dt))





func _assist_wants_control(player: Player) -> bool:
	if player == null:
		return false
	if player.serve_charge_ui:
		return true
	if team_touches >= 2:
		return true
	return _is_attack(player.resolved_touch()) or _is_attack(player.queued_contact_kind())

func _is_attack(k: int) -> bool:
	return k == Player.TouchKind.SPIKE or k == Player.TouchKind.DUMP\
	or k == Player.TouchKind.BLOCK





func _controller_active(player: Player) -> bool:
	if player != null and player.is_charging():
		return true
	if _dev.get_vector("move_left", "move_right", "move_forward", "move_back").length() > STICK_DEADZONE:
		return true
	for a in ["jump", "contact", "set", "dive", "serve", "strafe"]:
		if _dev.pressed(a):
			return true
	return false



func _assist_target(player: Player) -> Vector3:
	var side: = float(player.team_side)




	if _assist_wants_control(player):
		return _open_space_target(player, side, 
			player.resolved_touch() == Player.TouchKind.BLOCK)
	match player.resolved_touch():
		Player.TouchKind.SET:

			var hitter: = _front_teammate(side)
			var lane: float = hitter.global_position.x if hitter != null else _last_aim.x
			return player.set_pocket_point(Vector3(lane, 0.0, 0.0))
		Player.TouchKind.BUMP:

			return _dig_target(player, side)
		Player.TouchKind.BLOCK:

			return _open_space_target(player, side, true)
		Player.TouchKind.SPIKE, Player.TouchKind.DUMP:

			return _open_space_target(player, side, false)
		_:




			if _ball_incoming_to_us(player, side):
				return _dig_target(player, side)
			return _open_space_target(player, side, false)




func _court_half(player: Player) -> Vector2:
	var b = player.ball
	if b == null:
		return Vector2(4.5, 9.0)
	return Vector2(float(b.court_half_w), float(b.court_half_l))


func _dig_target(player: Player, side: float) -> Vector3:
	var setter: = _front_teammate(side)
	if setter != null:
		return Vector3(setter.global_position.x, 0.0, setter.global_position.z)
	return Vector3(0.0, 0.0, side * _court_half(player).y * 0.3)




func _ball_incoming_to_us(player: Player, side: float) -> bool:
	var b = player.ball
	if b == null or b.frozen:
		return false
	if b.predicted_landing_valid:
		return b.predicted_landing.z * side >= -0.1
	return b.global_position.z * side >= -0.1



func _front_teammate(side: float) -> Node3D:
	var best: Node3D = null
	var best_z: = INF
	for t in snap_targets:
		var tb: = t as Node3D
		if tb == null or not is_instance_valid(tb):
			continue
		var z: = tb.global_position.z * side
		if z < best_z:
			best_z = z
			best = tb
	return best



func _open_space_target(player: Player, side: float, block: bool) -> Vector3:
	var dims: = _court_half(player)
	var hl: = dims.y
	var xw: = maxf(dims.x - 0.6, 0.5)


	var depths: Array = [1.5, 2.6, 3.8] if block else [2.4, hl * 0.55, hl - 1.0]
	if foe_targets.is_empty():
		return Vector3(0.0, 0.0, - side * (depths[0] if block else depths[depths.size() - 1]))
	var best: = Vector3(0.0, 0.0, - side * depths[0])
	var best_open: = -1.0
	for zd in depths:
		for xx in [ - xw, 0.0, xw]:
			var c: = Vector3(xx, 0.0, - side * zd)
			var nearest: = INF
			for f in foe_targets:
				var fb: = f as Node3D
				if fb == null or not is_instance_valid(fb):
					continue
				nearest = minf(nearest, Vector2(c.x - fb.global_position.x, 
					c.z - fb.global_position.z).length())
			if nearest > best_open:
				best_open = nearest
				best = c
	return best

func _clamp_aim(assisted: bool) -> void :
	if assisted:
		_last_aim.x = clampf(_last_aim.x, aim_min.x, aim_max.x)
		_last_aim.z = clampf(_last_aim.z, aim_min.y, aim_max.y)
	else:






		_last_aim.x = clampf(_last_aim.x, 
			aim_min.x - HARD_AIM_MARGIN, aim_max.x + HARD_AIM_MARGIN)
		_last_aim.z = clampf(_last_aim.z, 
			aim_min.y - HARD_AIM_MARGIN, aim_max.y + HARD_AIM_MARGIN)












const CURSOR_MOVED: = 1.5
const CURSOR_SLACK: = 2.5
var _cursor_seen: = Vector2.INF
















var _soft_on: = false
var _virtual: = Vector2.INF




var mouse_freed: = false



var _was_freed: = false
var _cursor_was_aiming: = false

func soft_cursor_active() -> bool:
	return _soft_on

func soft_cursor_pos() -> Vector2:
	return _virtual



func feed_motion(event: InputEvent) -> void :
	if _soft_on and event is InputEventMouseMotion:




		_virtual += (event as InputEventMouseMotion).relative * _mouse_sens()

func _cursor_pos(vp: Viewport) -> Vector2:
	if dev_cursor != Vector2.INF:
		return dev_cursor
	if _soft_on:
		return _virtual
	var pos: = vp.get_mouse_position()


	if vp is SubViewport:
		pos = pos.clamp(Vector2.ZERO, vp.get_visible_rect().size)
	return pos

func _soft_start(vp: Viewport) -> void :
	_soft_on = true


	_virtual = vp.get_mouse_position()
	GameConfig.capture_mouse(true)

func _soft_stop(restore_visible: bool) -> void :
	if not _soft_on:
		return
	_soft_on = false
	_virtual = Vector2.INF

	if restore_visible and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE






var _tracking: = true

func _release_cursor() -> void :



	_tracking = false
	_cursor_seen = Vector2.INF


	_soft_stop(true)





func _recenter_mouse(rig: CameraRig, player: Player) -> void :
	var camera: = rig.camera
	if camera == null:
		return
	_last_aim = Vector3(player.global_position.x, 0.0, player.global_position.z)
	if camera.is_position_behind(_last_aim):
		return
	var vp: = camera.get_viewport()
	var want: = _unproject_steady(camera, _last_aim)
	if not vp.get_visible_rect().has_point(want):
		return
	_cursor_seen = want
	if _soft_on:
		_virtual = want
	else:
		if GameConfig.may_warp_mouse():
			Input.warp_mouse(vp.get_screen_transform() * want)

func _mouse_aim(camera: Camera3D) -> void :







	if not _tracking and dev_cursor == Vector2.INF:
		return
	var mouse: = _cursor_pos(camera.get_viewport())
	if _cursor_seen == Vector2.INF\
	or mouse.distance_to(_cursor_seen) > CURSOR_MOVED:

		_ray_to_floor(camera, mouse)
		_cursor_seen = mouse


















func _free_mouse_edge() -> bool:
	if _proc_dev._global():
		return Input.is_action_just_pressed("free_mouse")
	_proc_dev.exclude_pads = _dev.exclude_pads
	_proc_dev.exclude_kbm = _dev.exclude_kbm
	_proc_dev.poll(["free_mouse"])
	return _proc_dev.just_pressed("free_mouse")

func _over_ui(rig: CameraRig) -> bool:
	if rig == null or rig.camera == null:
		return false
	var vp: = rig.camera.get_viewport()
	return vp != null and vp.gui_get_hovered_control() != null

func follow_cursor(rig: CameraRig, enabled: bool) -> void :
	if not enabled or rig == null:
		_release_cursor()
		return
	var camera: = rig.camera
	if camera == null:
		_release_cursor()
		return





	_aim_unshake = rig.shake_offset
	var vp: = camera.get_viewport()




	if vp != _last_cursor_vp:
		_last_cursor_vp = vp
		if _soft_on:
			_virtual = vp.get_mouse_position()






	var win: = vp.get_window()
	if win == null or not win.has_focus():
		_release_cursor()
		return








	var focus: = vp.gui_get_focus_owner()
	var typing: = focus is LineEdit or focus is TextEdit
	if _free_mouse_edge() and not typing:
		mouse_freed = not mouse_freed
	var looks: = rig.mode == CameraRig.Mode.ACTION\
	or rig.mode == CameraRig.Mode.FIRST_PERSON
	if mouse_freed:




		if not _was_freed:
			_was_freed = true
			_cursor_was_aiming = GameConfig._cursor_aiming == 1
		if _soft_on:
			_soft_stop(true)
		GameConfig.use_cursor(false)
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE




		if not looks:
			var fm: = vp.get_mouse_position()
			if _cursor_seen == Vector2.INF or fm.distance_to(_cursor_seen) > CURSOR_MOVED:
				_ray_to_floor(camera, fm)
				_cursor_seen = fm
			_tracking = true
		else:
			_tracking = false
			_cursor_seen = Vector2.INF
		return



	if _was_freed:
		_was_freed = false
		GameConfig.use_cursor(_cursor_was_aiming)




	var owns_capture: = looks








	if _is_gamepad() and not owns_capture:
		if GameConfig.hardware_cursor:
			_soft_stop(false)
		else:
			if not _soft_on:
				_soft_start(vp)
			if not camera.is_position_behind(_last_aim):
				var p: = _unproject_steady(camera, _last_aim)
				if vp.get_visible_rect().has_point(p):
					_virtual = p
					_cursor_seen = p
		return
	if _soft_on and (GameConfig.hardware_cursor or owns_capture):
		_soft_stop( not owns_capture)
	elif not _soft_on and not GameConfig.hardware_cursor and not owns_capture:
		_soft_start(vp)





	if owns_capture and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED\
	and not GameConfig.free_mouse_harness:
		GameConfig.capture_mouse(true)
	if _soft_on:


		_virtual = _virtual.clamp(Vector2.ZERO, vp.get_visible_rect().size)


		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED\
		and not GameConfig.free_mouse_harness:
			GameConfig.capture_mouse(true)
	var mouse: = _cursor_pos(vp)




	if not _tracking or _cursor_seen == Vector2.INF:
		_tracking = true
		_cursor_seen = mouse
		_ray_to_floor(camera, mouse)
		return











	var moved: = mouse != _cursor_seen if _soft_on\
	else mouse.distance_to(_cursor_seen) > CURSOR_MOVED
	if moved:
		_ray_to_floor(camera, mouse)
		_cursor_seen = mouse
		return


	if camera.is_position_behind(_last_aim):
		return
	var want: = _unproject_steady(camera, _last_aim)
	if not vp.get_visible_rect().has_point(want):
		return
	if _soft_on:






		_virtual = want
		_cursor_seen = want
		return


	if want.distance_to(mouse) <= CURSOR_SLACK:
		return


	if GameConfig.may_warp_mouse():
		Input.warp_mouse(vp.get_screen_transform() * want)
	_cursor_seen = want




var snap_targets: Array = []



var foe_targets: Array = []




var team_touches: = 0
const SNAP_RADIUS: = 1.3
const SNAP_RANGE: = 26.0

func _soft_aim_teammate(camera: Camera3D, screen_pos: Vector2) -> void :
	var origin: = camera.project_ray_origin(screen_pos)
	var dir: = camera.project_ray_normal(screen_pos)
	var best: Node3D = null
	var best_off: = SNAP_RADIUS
	for t in snap_targets:
		var body: = t as Node3D
		if body == null or not is_instance_valid(body):
			continue
		var chest: Vector3 = body.global_position + Vector3(0.0, 1.2, 0.0)
		var along: = (chest - origin).dot(dir)
		if along < 1.0 or along > SNAP_RANGE:
			continue
		var off: = (chest - origin - dir * along).length()
		if off < best_off:
			best_off = off
			best = body
	if best != null:
		_last_aim = Vector3(best.global_position.x, 0.0, best.global_position.z)

var _aim_unshake: = Vector3.ZERO
var _last_cursor_vp = null








func _unproject_steady(camera: Camera3D, world: Vector3) -> Vector2:
	var shake: = camera.position
	if shake == Vector3.ZERO:
		return camera.unproject_position(world)
	camera.position = Vector3.ZERO
	var s: = camera.unproject_position(world)
	camera.position = shake
	return s




func aim_point() -> Vector3:


	return _set_snapped_aim if _set_snap_on else _last_aim

func _ray_to_floor(camera: Camera3D, screen_pos: Vector2) -> void :



	var origin: = camera.project_ray_origin(screen_pos) - _aim_unshake
	var dir: = camera.project_ray_normal(screen_pos)
	if dir.y < -0.001:

		_last_aim = origin + dir * ( - origin.y / dir.y)
	else:

		var flat: = Vector3(dir.x, 0.0, dir.z).normalized()
		if flat != Vector3.ZERO:
			_last_aim = Vector3(origin.x, 0.0, origin.z) + flat * LONG_AIM_RANGE
