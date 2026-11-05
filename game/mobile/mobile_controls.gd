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
var _move_value := Vector2.ZERO
var _look_position := Vector2.ZERO
var _stick_radius := 82.0
var _scale := 1.0
var _playing := false
var _has_player := false
var _player: Node
var _layout_size := Vector2.ZERO
var _safe := Rect2()
var _display_safe_area := Rect2i()
const LAYOUT_PATH := "user://touch_controls.cfg"
var _custom_layout: Dictionary = {}
var _editor: Control
var _power_center := Vector2.ZERO
var _move_opacity := 1.0
var _power_size := 1.0
var _power_opacity := 1.0

func enabled() -> bool:
	return MobileRender.enabled()

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
	load_layout()
	_rebuild_layout()
	if OS.get_environment("VOLOBALL_BOOT_SMOKE") in ["1", "match"]:
		var smoke: Node = (load("res://game/mobile/mobile_boot_smoke.gd") as GDScript).new()
		get_tree().root.add_child.call_deferred(smoke)

func _process(_delta: float) -> void:
	# A 180-degree flip can change the notch inset without changing window size.
	if OS.has_feature("ios") or OS.has_feature("android"):
		if DisplayServer.get_display_safe_area() != _display_safe_area:
			_rebuild_layout()
	if is_instance_valid(_editor):
		return
	var scene := get_tree().current_scene
	var game := game_scene()
	_player = game.get("player") if game != null else null
	if _player == null:
		_player = GameConfig._active_power_player()
	var freeplay: bool = scene != null and scene.get("_freeplay") == true
	_has_player = _player != null and (not GameConfig.menu_open or GameConfig.menu_practice or freeplay)
	var blocked: bool = get_tree().paused or (GameConfig.menu_open and not GameConfig.menu_practice and not freeplay)
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
	var previous_size := _layout_size
	var previous_safe := _safe
	release_all()
	_layout_size = get_viewport().get_visible_rect().size
	_safe = Rect2(Vector2.ZERO, _layout_size)
	if OS.has_feature("ios") or OS.has_feature("android"):
		_display_safe_area = DisplayServer.get_display_safe_area()
		var pixels := Rect2(_display_safe_area)
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
	_stick_radius *= control_scale("move")
	_move_center = control_position("move", Vector2(left + 135.0 * _scale, bottom - 140.0 * _scale), Vector2.ONE * _stick_radius)
	_move_opacity = control_opacity("move")
	_power_size = control_scale("power_display")
	_power_opacity = control_opacity("power_display")
	_power_center = control_position("power_display", Vector2(_safe.get_center().x, bottom - 65.0 * _scale), Vector2(55, 22) * _scale * _power_size)
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
	_button("camera", "КАМЕРА", Vector2(right - 170.0 * _scale, top + 155.0 * _scale))
	_button("pause", "МЕНЮ", Vector2(right - 65.0 * _scale, top + 155.0 * _scale))
	if is_instance_valid(_editor) and (previous_size != _layout_size or previous_safe != _safe):
		_editor.layout_changed()

func _button(action: String, label: String, center: Vector2) -> void:
	var radius := minf(42.0 * _scale * control_scale(action), _safe.size.y * 0.45)
	_buttons.append({"action": action, "label": label,
		"center": control_position(action, center, Vector2.ONE * radius), "radius": radius,
		"size": control_scale(action), "opacity": control_opacity(action)})

func _input(event: InputEvent) -> void:
	if is_instance_valid(_editor):
		return
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
	if not _safe.has_point(at):
		return false
	if at.distance_to(_move_center) <= _stick_radius * 1.35 and not _touches.values().has("move"):
		_touches[index] = "move"
		touch_move(index, at)
		return true
	if at.x >= _safe.get_center().x:
		if _touches.values().has("look"):
			return false
		_touches[index] = "look"
		_look_position = at
		return true
	return false

func touch_move(index: int, at: Vector2) -> void:
	var action: String = _touches.get(index, "")
	if action == "look":
		var relative := (at - _look_position) / _scale
		_look_position = at
		var scene := game_scene()
		var rig: Node = scene.get("camera_rig") if scene != null else null
		if _playing and rig != null and rig.has_method("apply_touch_look"):
			rig.apply_touch_look(relative)
	elif action == "move":
		var value := ((at - _move_center) / _stick_radius).limit_length(1.0)
		if value.length() < 0.12:
			value = Vector2.ZERO
		_move_value = value
		_set_move(value)

func touch_end(index: int) -> void:
	var action: String = _touches.get(index, "")
	_touches.erase(index)
	if action == "move":
		_set_move(Vector2.ZERO)
		_move_value = Vector2.ZERO
	elif action == "look":
		_look_position = Vector2.ZERO
	elif not _touches.values().has(action):
		_set_strength(action, 0.0)

func _set_move(value: Vector2) -> void:
	_set_strength("move_left", maxf(-value.x, 0.0))
	_set_strength("move_right", maxf(value.x, 0.0))
	_set_strength("move_forward", maxf(-value.y, 0.0))
	_set_strength("move_back", maxf(value.y, 0.0))

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
	_look_position = Vector2.ZERO

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
	if is_instance_valid(_editor):
		return
	if not _has_player:
		return
	if _playing:
		_draw_stick(surface, _move_center, _move_value, "РУХ")
	for button in _buttons:
		if not _playing and button.action != "pause":
			continue
		var held := _touches.values().has(button.action)
		var fill := Color(0.13, 0.3, 0.47, 0.85 * button.opacity) if held else Color(0.04, 0.09, 0.16, 0.65 * button.opacity)
		surface.draw_circle(button.center, button.radius, fill)
		surface.draw_arc(button.center, button.radius, 0, TAU, 40, Color(1, 1, 1, 0.65 * button.opacity), 2.0 * _scale, true)
		_text(surface, button.center, button.label, roundi(14 * button.size), button.opacity)
	if _playing and _player != null:
		var level := GameConfig.power_disp_of(int(_player.get("power_level")))
		_text(surface, _power_center, "%d / %d" % [level, GameConfig.power_cap], roundi(22 * _power_size), _power_opacity)

func _draw_stick(surface: Control, center: Vector2, value: Vector2, label: String) -> void:
	surface.draw_circle(center, _stick_radius, Color(0.04, 0.09, 0.16, 0.4 * _move_opacity))
	surface.draw_arc(center, _stick_radius, 0, TAU, 48, Color(1, 1, 1, 0.5 * _move_opacity), 2.0 * _scale, true)
	surface.draw_circle(center + value * _stick_radius * 0.65, _stick_radius * 0.36, Color(1, 1, 1, 0.45 * _move_opacity))
	_text(surface, center - Vector2(0, _stick_radius + 18.0 * _scale), label, roundi(15 * control_scale("move")), _move_opacity)

func _text(surface: Control, at: Vector2, text: String, size: int, opacity := 1.0) -> void:
	var font := ThemeDB.fallback_font
	var pixels := maxi(10, roundi(size * _scale))
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels).x
	surface.draw_string(font, at + Vector2(-width * 0.5, pixels * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels, Color(1, 1, 1, opacity))

func control_scale(id: String) -> float:
	return float(_custom_layout.get(id, {}).get("size", 1.0))

func control_opacity(id: String) -> float:
	return float(_custom_layout.get(id, {}).get("opacity", 1.0))

func control_position(id: String, fallback: Vector2, extent: Vector2) -> Vector2:
	var position: Vector2 = _custom_layout.get(id, {}).get("position", (_safe.get_center() - _safe.position) / _safe.size)
	var center := _safe.position + position * _safe.size if _custom_layout.has(id) else fallback
	var margin := extent.min(_safe.size * 0.45)
	return center.clamp(_safe.position + margin, _safe.end - margin)

func control_items() -> Array:
	var items: Array = _buttons.duplicate(true)
	items.append({"action": "move", "label": "РУХ", "center": _move_center, "radius": _stick_radius,
		"size": control_scale("move"), "opacity": _move_opacity})
	items.append({"action": "power_display", "label": "3 / %d" % GameConfig.power_cap, "center": _power_center,
		"radius": 35.0 * _scale * _power_size, "size": _power_size, "opacity": _power_opacity})
	return items

func update_control(id: String, center: Vector2, size_factor: float, opacity: float) -> void:
	if not center.is_finite() or not is_finite(size_factor) or not is_finite(opacity) or not _safe.has_area():
		return
	_custom_layout[id] = {
		"position": ((center - _safe.position) / _safe.size).clamp(Vector2.ZERO, Vector2.ONE),
		"size": clampf(size_factor, 0.5, 2.0), "opacity": clampf(opacity, 0.0, 1.0)}
	_rebuild_layout()

func load_layout() -> void:
	_custom_layout.clear()
	var config := ConfigFile.new()
	if config.load(LAYOUT_PATH) != OK or config.get_value("layout", "version", 0) != 1:
		return
	var saved: Variant = config.get_value("layout", "controls", {})
	if not saved is Dictionary:
		return
	for item in control_items():
		var record: Variant = saved.get(item.action)
		if not record is Dictionary:
			continue
		var position: Variant = record.get("position")
		var factor: Variant = record.get("size")
		var opacity: Variant = record.get("opacity")
		if not position is Vector2 or not (factor is float or factor is int) or not (opacity is float or opacity is int):
			continue
		if not position.is_finite() or not is_finite(float(factor)) or not is_finite(float(opacity)):
			continue
		_custom_layout[item.action] = {"position": position.clamp(Vector2.ZERO, Vector2.ONE),
			"size": clampf(float(factor), 0.5, 2.0), "opacity": clampf(float(opacity), 0, 1)}

func save_layout() -> Error:
	var config := ConfigFile.new()
	config.set_value("layout", "version", 1)
	config.set_value("layout", "controls", _custom_layout)
	var error := config.save(LAYOUT_PATH + ".tmp")
	if error != OK:
		return error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(LAYOUT_PATH + ".tmp"),
		ProjectSettings.globalize_path(LAYOUT_PATH))

func open_editor() -> void:
	if is_instance_valid(_editor):
		return
	release_all()
	_editor = (load("res://game/mobile/touch_layout_editor.gd") as GDScript).new()
	_editor.controls = self
	add_child(_editor)
