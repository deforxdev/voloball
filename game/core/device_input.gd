class_name DeviceInput
extends RefCounted




















const MERGED: = -2
const KBM: = -1
const AXIS_DEADZONE: = 0.5

var device: = MERGED

var exclude_pads: PackedInt32Array = []

var exclude_kbm: = false



var bindings: = {}

func set_bindings(table: Dictionary) -> void :
	bindings = table

var _now: = {}
var _was: = {}






var _press_at: = {}
var _release_at: = {}
var _poll_physics: = false

func _init(dev: = MERGED) -> void :
	device = dev

func is_merged() -> bool:
	return device == MERGED


func _global() -> bool:
	if MobileControls.enabled():
		return false
	return device == MERGED and exclude_pads.is_empty() and not exclude_kbm


func poll(actions: PackedStringArray) -> void :
	if _global():
		return
	_was = _now
	_now = {}
	_poll_physics = Engine.is_in_physics_frame()
	var frame: = Engine.get_physics_frames() if _poll_physics else Engine.get_process_frames()
	for a in actions:
		var v: = _device_strength(a)
		_now[a] = v
		var down: = v > AXIS_DEADZONE
		var was: = float(_was.get(a, 0.0)) > AXIS_DEADZONE
		if down and not was:
			_press_at[a] = frame
		elif was and not down:
			_release_at[a] = frame

func pressed(action: String) -> bool:
	if _global():
		return Input.is_action_pressed(action)
	return float(_now.get(action, 0.0)) > AXIS_DEADZONE

func just_pressed(action: String) -> bool:
	if _global():
		return Input.is_action_just_pressed(action)
	return _edge_now(_press_at, action)

func just_released(action: String) -> bool:
	if _global():
		return Input.is_action_just_released(action)
	return _edge_now(_release_at, action)



func _edge_now(by: Dictionary, action: String) -> bool:
	var now: = Engine.get_physics_frames() if _poll_physics else Engine.get_process_frames()
	return int(by.get(action, -10)) == now

func strength(action: String) -> float:
	if _global():
		return Input.get_action_strength(action)
	return float(_now.get(action, 0.0))






func get_vector(neg_x: String, pos_x: String, neg_y: String, pos_y: String) -> Vector2:
	if _global():
		return Input.get_vector(neg_x, pos_x, neg_y, pos_y)
	var v: = Vector2(strength(pos_x) - strength(neg_x), strength(pos_y) - strength(neg_y))
	var dz: = 0.25 * (_deadzone(neg_x) + _deadzone(pos_x) + _deadzone(neg_y) + _deadzone(pos_y))
	var len: = v.length()
	if len < dz:
		return Vector2.ZERO
	if len > 1.0:
		return v / len
	return v * (inverse_lerp(dz, 1.0, len) / len)

func _deadzone(action: String) -> float:
	return InputMap.action_get_deadzone(action) if InputMap.has_action(action) else 0.5




var _now_override: = {}


static var test_pads: = PackedInt32Array()

func _device_strength(action: String) -> float:
	if not _now_override.is_empty():
		return float(_now_override.get(action, 0.0))
	var evs: Array
	if bindings.has(action):
		evs = bindings[action]
	elif InputMap.has_action(action):
		evs = InputMap.action_get_events(action)
	else:
		return 0.0
	var best: = MobileControls.action_strength(action) \
		if device < 0 and not exclude_kbm else 0.0
	for e in evs:
		best = maxf(best, _resolve_event(e))
	return best


func _resolve_event(e: InputEvent) -> float:
	if device == KBM:
		return _kbm_event_strength(e)
	if device >= 0:
		return _pad_event_strength(e, device)

	if e is InputEventKey or e is InputEventMouseButton:
		return 0.0 if exclude_kbm else _kbm_event_strength(e)
	var best: = 0.0
	var pads: = Input.get_connected_joypads()
	for t in test_pads:
		if t not in pads:
			pads.append(t)
	for pad in pads:
		if pad in exclude_pads:
			continue
		best = maxf(best, _pad_event_strength(e, pad))
	return best

func _pad_event_strength(e: InputEvent, pad: int) -> float:
	if e is InputEventJoypadButton:
		return 1.0 if Input.is_joy_button_pressed(
			pad, (e as InputEventJoypadButton).button_index) else 0.0
	if e is InputEventJoypadMotion:
		var m: = e as InputEventJoypadMotion
		var val: = Input.get_joy_axis(pad, m.axis)
		if signf(val) != signf(m.axis_value):
			return 0.0
		return clampf(absf(val), 0.0, 1.0)
	return 0.0

func _kbm_event_strength(e: InputEvent) -> float:
	if MobileControls.enabled() and e is InputEventMouseButton:
		return 0.0
	if e is InputEventKey:
		var k: = e as InputEventKey
		if k.physical_keycode != 0:
			return 1.0 if Input.is_physical_key_pressed(k.physical_keycode) else 0.0
		return 1.0 if Input.is_key_pressed(k.keycode) else 0.0
	if e is InputEventMouseButton:
		var mb: = e as InputEventMouseButton
		var mask: = Input.get_mouse_button_mask()
		return 1.0 if (mask & (1 << (mb.button_index - 1))) != 0 else 0.0
	return 0.0
