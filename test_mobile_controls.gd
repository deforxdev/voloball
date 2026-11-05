extends Node

var failures := 0
var _freeplay := false
var player: Player
var camera_rig: CameraRig

func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	check(MobileControls.enabled(), "mobile preview enables touch input")
	check(ResourceLoader.exists(String(Stage.info(Stage.home()).venue)), "mobile default arena is present in the recovered project")
	check(not BootLoader.enabled(), "mobile startup does not warm the desktop locker")
	player = load("res://game/player/player.tscn").instantiate()
	add_child(player)
	var ball: Ball = load("res://game/ball/ball.tscn").instantiate()
	add_child(ball)
	player.ball = ball
	await get_tree().process_frame
	ball.toss(Vector3(0, 2, 0))
	ball.trail.set_active(true)
	check(not ball.trail.emitting and ball.trail.process_material == null,
		"toss and trail activation never restart GPU particles on mobile")
	var was_menu_open: bool = GameConfig.menu_open
	GameConfig.menu_open = true
	_freeplay = true
	MobileControls._process(0.0)
	check(MobileControls._playing, "touch controls stay visible in menu freeplay")
	_freeplay = false
	MobileControls._process(0.0)
	check(not MobileControls._playing, "touch controls hide while browsing the main menu")
	GameConfig.menu_open = was_menu_open
	MobileControls._player = player
	MobileControls._playing = true
	MobileControls._has_player = true
	MobileControls._rebuild_layout()
	var move: Vector2 = MobileControls._move_center
	camera_rig = CameraRig.new()
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera_rig.add_child(camera)
	add_child(camera_rig)
	var aim := Vector2(MobileControls._safe.get_center().x + MobileControls._safe.size.x * 0.15,
		MobileControls._safe.position.y + MobileControls._safe.size.y * 0.3)
	var radius: float = MobileControls._stick_radius
	check(MobileControls.touch_begin(0, move + Vector2(radius, 0)), "movement stick captures finger")
	var yaw_before := camera_rig._yaw
	check(MobileControls.touch_begin(1, aim), "right half captures camera finger while movement is held")
	check(is_equal_approx(camera_rig._yaw, yaw_before), "touch down does not jump camera")
	MobileControls.touch_move(1, aim + Vector2(80, -40))
	check(camera_rig.mode == CameraRig.Mode.ACTION, "right swipe enables free camera from default dynamic view")
	check(not is_equal_approx(camera_rig._yaw, yaw_before), "right swipe rotates camera without captured mouse")
	var yaw_after := camera_rig._yaw
	var pitch_after := camera_rig._pitch
	MobileControls.touch_move(1, aim + Vector2(80, -40))
	check(is_equal_approx(camera_rig._yaw, yaw_after) and is_equal_approx(camera_rig._pitch, pitch_after),
		"stationary finger does not keep rotating camera")
	check(not MobileControls.touch_begin(8, aim + Vector2(60, 0)), "second camera finger cannot take over gesture")
	check(not MobileControls.touch_begin(9, Vector2(MobileControls._safe.position.x + 20, aim.y)),
		"left half outside movement control cannot start camera look")
	var hit: Vector2
	var jump: Vector2
	for button in MobileControls._buttons:
		if button.action == "contact": hit = button.center
		if button.action == "jump": jump = button.center
	check(MobileControls.touch_begin(2, hit), "attack works while moving and swiping camera")
	check(MobileControls.touch_begin(3, jump), "jump works with three other touches held")
	var device := DeviceInput.new(DeviceInput.MERGED)
	device.poll(InputCollector.TRACKED_ACTIONS)
	check(device.strength("move_right") > 0.9, "movement reaches existing input pipeline")
	check(device.pressed("contact") and device.pressed("jump"), "simultaneous attack and jump reach input pipeline")
	check(device.strength("aim_up") == 0.0, "camera drag does not leave an aim joystick action held")
	var keyboard := DeviceInput.new(DeviceInput.KBM)
	keyboard.poll(InputCollector.TRACKED_ACTIONS)
	check(keyboard.pressed("contact"), "touch supports the keyboard/mouse local seat")
	var other_seat := DeviceInput.new(DeviceInput.MERGED)
	other_seat.exclude_kbm = true
	other_seat.poll(InputCollector.TRACKED_ACTIONS)
	check(not other_seat.pressed("contact"), "touch does not control a different local seat")
	MobileControls.touch_move(0, move + Vector2(radius * 5, 0))
	check(MobileControls.action_strength("move_right") <= 1.0, "stick clamps drag outside its circle")
	var before_button_drag := camera_rig._yaw
	MobileControls.touch_move(2, hit + Vector2(70, 0))
	check(is_equal_approx(camera_rig._yaw, before_button_drag), "dragging attack button does not move camera")
	MobileControls.touch_end(1)
	MobileControls.touch_move(1, aim + Vector2(200, 0))
	check(is_equal_approx(camera_rig._yaw, before_button_drag), "released camera finger stops rotating")
	MobileControls.touch_end(2)
	device.poll(InputCollector.TRACKED_ACTIONS)
	check(not device.pressed("contact") and device.pressed("jump"), "one finger releases without cancelling another")
	MobileControls.release_all()
	device.poll(InputCollector.TRACKED_ACTIONS)
	check(not device.pressed("jump") and device.strength("move_right") == 0.0, "focus loss and menus clear held actions")
	check(MobileControls._touches.is_empty(), "focus loss clears camera gesture ownership")
	camera_rig.input_frozen = true
	var frozen_yaw := camera_rig._yaw
	camera_rig.apply_touch_look(Vector2(100, 0))
	check(is_equal_approx(camera_rig._yaw, frozen_yaw), "frozen camera ignores touch look")
	camera_rig.input_frozen = false
	camera_rig.apply_touch_look(Vector2(0, -10000))
	check(camera_rig._pitch <= CameraRig.PITCH_MAX, "camera swipe clamps vertical rotation")
	var old_cap: int = GameConfig.power_cap
	GameConfig.power_cap = 9
	player.power_level = GameConfig.power_disp_level(3)
	MobileControls.change_power(1)
	check(GameConfig.power_disp_of(player.power_level) == 4, "power button uses displayed nine-step scale")
	MobileControls.change_power(-1)
	check(GameConfig.power_disp_of(player.power_level) == 3, "power decrement returns to minigame range")
	GameConfig.power_cap = old_cap
	var minigame := ServeMinigame.new()
	add_child(minigame)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	minigame._input(touch)
	check(minigame.phase == 1, "first touch locks minigame vertical aim")
	var mouse := InputEventMouseButton.new()
	mouse.device = -1
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	minigame._input(mouse)
	check(minigame.phase == 1, "emulated mouse does not double-confirm a touch")
	minigame._input(touch)
	check(minigame.phase == 2, "second touch finishes minigame")
	check(InputCollector.new()._is_gamepad(), "touch uses adaptive stick aiming")
	var hints := ControlHints.new()
	check(not hints.enabled(), "desktop keyboard hints stay hidden behind touch buttons")
	hints.free()
	print("MOBILE REGRESSION COMPLETE: failures=", failures)
	get_tree().quit(failures)
