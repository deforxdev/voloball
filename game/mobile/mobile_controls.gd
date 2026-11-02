extends CanvasLayer

# Multi-touch controls share the existing actions and PlayerInput pipeline.
# --mobile-preview enables the same controls on a desktop for testing.
class TouchSurface extends Control:
	var controls: Node
	func _draw() -> void:
		controls.draw_controls(self)

var _surface: TouchSurface
var _touches: Dictionary = {}
var _strengths: Dictionary = {}
var _buttons: Array = []
var _move_center := Vector2.ZERO
var _aim_center := Vector2.ZERO
var _move_value := Vector2.ZERO
var _aim_value := Vector2.ZERO
var _stick_radius := 82.0
var _scale := 1.0
var _playing := false
var _has_player := false
var _player: Node
var _layout_size := Vector2.ZERO
var _safe := Rect2()

func enabled() -> bool:
	return OS.has_feature("ios") or OS.has_feature("android") \
		or OS.get_cmdline_user_args().has("--mobile-preview")

func action_strength(action: String) -> float:
	return float(_strengths.get(action, 0.0)) if enabled() else 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not enabled():
		set_process(false)
		set_process_input(false)
		return
	layer = 75
	_surface = TouchSurface.new()
	_surface.controls = self
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_surface)
	get_tree().root.size_changed.connect(_rebuild_layout)
	_rebuild_layout()
	if OS.get_environment("VOLOBALL_BOOT_SMOKE") == "1":
		var smoke: Node = (load("res://game/mobile/mobile_boot_smoke.gd") as GDScript).new()
		get_tree().root.add_child.call_deferred(smoke)

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	var game := game_scene()
	_player = game.get("player") if game != null else null
	if _player == null:
		_player = GameConfig._active_power_player()
	var freeplay: bool = scene != null and scene.get("_freeplay") == true
	_has_player = _player != null and (not GameConfig.menu_open or GameConfig.menu_practice or freeplay)
	var blocked: bool = GameConfig.menu_open and not GameConfig.menu_practice and not freeplay
	var focus := get_viewport().gui_get_focus_owner()
	blocked = blocked or focus is LineEdit or focus is TextEdit
	if game != null:
		var hud: Node = game.get("hud")
		if hud != null and hud.has_method("pause_is_open"):
			blocked = blocked or hud.pause_is_open()
		for child in game.get_children():
			if child is ServeMinigame:
				blocked = true
	var playing: bool = _has_player and not blocked
	if _playing and not playing:
		release_all()
	_playing = playing
	if get_viewport().get_visible_rect().size != _layout_size:
		_rebuild_layout()
	_surface.queue_redraw()

func game_scene() -> Node:
	var scene := get_tree().current_scene
	if scene != null and GameConfig.menu_practice:
		var court: Node = scene.get("_practice_court")
		if court != null and court.get("active") == true:
			var main: Node = court.get("main")
			if main != null:
				return main
	return scene

func action_label(action: String) -> String:
	const LABELS := {"move": "РУХ", "@mouse": "ПРИЦІЛ", "contact": "УДАР", "jump": "СТРИБОК",
		"set": "ПАС", "dive": "НИРОК", "block": "БЛОК", "serve": "ПОДАЧА", "ball_spawn": "М'ЯЧ",
		"strafe": "СТІЙКА", "sprint": "БІГ", "camera_toggle": "КАМЕРА"}
	return LABELS.get(action, action)

func _rebuild_layout() -> void:
	release_all()
	_layout_size = get_viewport().get_visible_rect().size
	_safe = Rect2(Vector2.ZERO, _layout_size)
	if OS.has_feature("ios") or OS.has_feature("android"):
		var pixels := Rect2(DisplayServer.get_display_safe_area())
		if pixels.has_area():
			var inverse := get_viewport().get_screen_transform().affine_inverse()
			var safe_rect := Rect2(inverse * pixels.position, inverse.basis_xform(pixels.size))
			_safe = _safe.intersection(safe_rect)
	_scale = clampf(minf(_safe.size.y / 720.0, _safe.size.x / 1280.0), 0.65, 1.5)
	_stick_radius = 82.0 * _scale
	var left := _safe.position.x
	var right := _safe.end.x
	var top := _safe.position.y
	var bottom := _safe.end.y
	_move_center = Vector2(left + 135.0 * _scale, bottom - 140.0 * _scale)
	_aim_center = Vector2(right - 145.0 * _scale, bottom - 365.0 * _scale)
	_buttons.clear()
	_button("contact", "УДАР", Vector2(right - 65.0 * _scale, bottom - 165.0 * _scale))
	_button("jump", "СТРИБОК", Vector2(right - 165.0 * _scale, bottom - 65.0 * _scale))
	_button("set", "ПАС", Vector2(right - 165.0 * _scale, bottom - 165.0 * _scale))
	_button("dive", "НИРОК", Vector2(right - 265.0 * _scale, bottom - 65.0 * _scale))
	_button("block", "БЛОК", Vector2(right - 265.0 * _scale, bottom - 165.0 * _scale))
	_button("serve", "ПОДАЧА", Vector2(right - 65.0 * _scale, bottom - 65.0 * _scale))
	_button("ball_spawn", "М'ЯЧ", Vector2(left + 65.0 * _scale, top + 80.0 * _scale))
	_button("sprint", "БІГ", Vector2(left + 285.0 * _scale, bottom - 180.0 * _scale))
	_button("strafe", "СТІЙКА", Vector2(left + 285.0 * _scale, bottom - 80.0 * _scale))
	_button("power_down", "−", Vector2(_safe.get_center().x - 85.0 * _scale, bottom - 65.0 * _scale))
	_button("power_up", "+", Vector2(_safe.get_center().x + 85.0 * _scale, bottom - 65.0 * _scale))
	_button("camera", "КАМЕРА", Vector2(right - 170.0 * _scale, top + 80.0 * _scale))
	_button("pause", "МЕНЮ", Vector2(right - 65.0 * _scale, top + 80.0 * _scale))

func _button(action: String, label: String, center: Vector2) -> void:
	_buttons.append({"action": action, "label": label, "center": center, "radius": 42.0 * _scale})

func _input(event: InputEvent) -> void:
	if not enabled() or not _has_player:
		return
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device == -1:
		var on_control := false
		for button in _buttons:
			if (_playing or button.action == "pause") and event.position.distance_to(button.center) <= button.radius:
				on_control = true
		if not _touches.is_empty() or on_control:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if not touch_begin(event.index, event.position):
				return
		else:
			if not _touches.has(event.index):
				return
			touch_end(event.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and _touches.has(event.index):
		touch_move(event.index, event.position)
		get_viewport().set_input_as_handled()

func touch_begin(index: int, at: Vector2) -> bool:
	if _touches.has(index):
		return false
	for button in _buttons:
		var action: String = button.action
		if not _playing and action != "pause":
			continue
		if at.distance_to(button.center) > button.radius:
			continue
		_touches[index] = action
		if action in ["power_down", "power_up"]:
			change_power(1 if action == "power_up" else -1)
		elif action == "pause":
			_key_pulse(KEY_ESCAPE)
		elif action == "camera":
			var scene := game_scene()
			var rig: Node = scene.get("camera_rig") if scene != null else null
			if rig != null and rig.has_method("apply_camera_toggle"):
				rig.apply_camera_toggle()
		else:
			_set_strength(action, 1.0)
		return true
	if not _playing:
		return false
	for stick in ["move", "aim"]:
		var center: Vector2 = _move_center if stick == "move" else _aim_center
		if at.distance_to(center) <= _stick_radius * 1.35 and not _touches.values().has(stick):
			_touches[index] = stick
			touch_move(index, at)
			return true
	return false

func touch_move(index: int, at: Vector2) -> void:
	var action: String = _touches.get(index, "")
	if action != "move" and action != "aim":
		return
	var center: Vector2 = _move_center if action == "move" else _aim_center
	var value := ((at - center) / _stick_radius).limit_length(1.0)
	if value.length() < 0.12:
		value = Vector2.ZERO
	if action == "move":
		_move_value = value
	else:
		_aim_value = value
	_set_stick(action, value)

func touch_end(index: int) -> void:
	var action: String = _touches.get(index, "")
	_touches.erase(index)
	if action == "move" or action == "aim":
		_set_stick(action, Vector2.ZERO)
		if action == "move":
			_move_value = Vector2.ZERO
		else:
			_aim_value = Vector2.ZERO
	elif not _touches.values().has(action):
		_set_strength(action, 0.0)

func _set_stick(stick: String, value: Vector2) -> void:
	_set_strength(stick + "_left", maxf(-value.x, 0.0))
	_set_strength(stick + "_right", maxf(value.x, 0.0))
	_set_strength("move_forward" if stick == "move" else "aim_up", maxf(-value.y, 0.0))
	_set_strength("move_back" if stick == "move" else "aim_down", maxf(value.y, 0.0))

func _set_strength(action: String, strength: float) -> void:
	if not InputMap.has_action(action):
		return
	if strength > 0.0:
		_strengths[action] = strength
		Input.action_press(action, strength)
	else:
		_strengths.erase(action)
		Input.action_release(action)

func change_power(step: int) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var current := GameConfig.power_disp_of(int(_player.get("power_level")))
	_player.set("power_level", GameConfig.power_disp_level(clampi(current + step, 1, GameConfig.power_cap)))

func release_all() -> void:
	for action in _strengths.keys():
		Input.action_release(action)
	_strengths.clear()
	_touches.clear()
	_move_value = Vector2.ZERO
	_aim_value = Vector2.ZERO

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		release_all()

func _key_pulse(code: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = code
	press.physical_keycode = code
	press.pressed = true
	Input.parse_input_event(press)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event.call_deferred(release)

func draw_controls(surface: Control) -> void:
	if not _has_player:
		return
	if _playing:
		_draw_stick(surface, _move_center, _move_value, "РУХ")
		_draw_stick(surface, _aim_center, _aim_value, "ПРИЦІЛ")
	for button in _buttons:
		if not _playing and button.action != "pause":
			continue
		var held := _touches.values().has(button.action)
		var fill := Color(0.13, 0.3, 0.47, 0.85) if held else Color(0.04, 0.09, 0.16, 0.65)
		surface.draw_circle(button.center, button.radius, fill)
		surface.draw_arc(button.center, button.radius, 0, TAU, 40, Color(1, 1, 1, 0.65), 2.0 * _scale, true)
		_text(surface, button.center, button.label, 14)
	if _playing and _player != null:
		var level := GameConfig.power_disp_of(int(_player.get("power_level")))
		_text(surface, Vector2(_safe.get_center().x, _safe.end.y - 65.0 * _scale), "%d / %d" % [level, GameConfig.power_cap], 22)

func _draw_stick(surface: Control, center: Vector2, value: Vector2, label: String) -> void:
	surface.draw_circle(center, _stick_radius, Color(0.04, 0.09, 0.16, 0.4))
	surface.draw_arc(center, _stick_radius, 0, TAU, 48, Color(1, 1, 1, 0.5), 2.0 * _scale, true)
	surface.draw_circle(center + value * _stick_radius * 0.65, _stick_radius * 0.36, Color(1, 1, 1, 0.45))
	_text(surface, center - Vector2(0, _stick_radius + 18.0 * _scale), label, 15)

func _text(surface: Control, at: Vector2, text: String, size: int) -> void:
	var font := ThemeDB.fallback_font
	var pixels := maxi(10, roundi(size * _scale))
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels).x
	surface.draw_string(font, at + Vector2(-width * 0.5, pixels * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels, Color.WHITE)
