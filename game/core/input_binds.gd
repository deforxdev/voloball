extends Node

















const SLOTS: = ["kb", "kb2", "pad"]





const REBINDABLE: = [
	{"action": "move_forward", "label": "move up", "kb": true, "pad": false}, 
	{"action": "move_back", "label": "move down", "kb": true, "pad": false}, 
	{"action": "move_left", "label": "move left", "kb": true, "pad": false}, 
	{"action": "move_right", "label": "move right", "kb": true, "pad": false}, 
	{"action": "jump", "label": "jump", "kb": true, "pad": true}, 
	{"action": "contact", "label": "hit / receive", "kb": true, "pad": true}, 
	{"action": "set", "label": "set", "kb": true, "pad": true}, 
	{"action": "dive", "label": "dive", "kb": true, "pad": true}, 
	{"action": "block", "label": "block", "kb": true, "pad": true}, 
	{"action": "serve", "label": "serve", "kb": true, "pad": true}, 


	{"action": "ball_spawn", "label": "spawn ball", "kb": true, "pad": true}, 
	{"action": "ball_despawn", "label": "despawn ball", "kb": true, "pad": true}, 
	{"action": "sprint", "label": "sprint", "kb": true, "pad": true}, 
	{"action": "strafe", "label": "strafe", "kb": true, "pad": true}, 
	{"action": "aim_recenter", "label": "aim assist / recenter", "kb": true, "pad": true}, 
	{"action": "camera_toggle", "label": "camera", "kb": true, "pad": true}, 


	{"action": "camera_dynamic", "label": "camera: dynamic", "kb": true, "pad": true, "unbound": true}, 
	{"action": "camera_broadcast", "label": "camera: broadcast", "kb": true, "pad": true, "unbound": true}, 
	{"action": "camera_static", "label": "camera: static", "kb": true, "pad": true, "unbound": true}, 
	{"action": "camera_action", "label": "camera: action", "kb": true, "pad": true, "unbound": true}, 
	{"action": "camera_zoom", "label": "zoom", "kb": true, "pad": true}, 
	{"action": "stats", "label": "scoreboard", "kb": true, "pad": true}, 
	{"action": "chat_toggle", "label": "chat", "kb": true, "pad": false}, 
	{"action": "free_mouse", "label": "free mouse", "kb": true, "pad": false}, 


	{"action": "callout_1", "label": "i got it!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_2", "label": "nice!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_3", "label": "sorry!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_4", "label": "don't mind!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_5", "label": "thanks!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_6", "label": "quick!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
	{"action": "callout_7", "label": "high!", "kb": true, "kb2": true, "pad": true, "chat": true}, 
]


func slot_kind(slot: String) -> String:
	return "pad" if slot == "pad" else "kb"













const CODE_ACTIONS: = [
	{"action": "callout_5", "kb": {"t": "key", "c": KEY_5}}, 
	{"action": "callout_6", "kb": {"t": "key", "c": KEY_6}}, 
	{"action": "callout_7", "kb": {"t": "key", "c": KEY_7}}, 
	{"action": "block", "kb": {"t": "mouse", "c": MOUSE_BUTTON_RIGHT}, "pad": {"t": "joyb", "c": JOY_BUTTON_B}}, 
	{"action": "ball_spawn", "kb": {"t": "key", "c": KEY_G}, "pad": {"t": "joyb", "c": JOY_BUTTON_Y}}, 
	{"action": "ball_despawn", "kb": {"t": "key", "c": KEY_X}, "pad": {"t": "joyb", "c": JOY_BUTTON_BACK}}, 
	{"action": "camera_dynamic"}, 
	{"action": "camera_broadcast"}, 
	{"action": "camera_static"}, 
	{"action": "camera_action"}, 
]




const MAY_SHARE: = [
	["dive", "block"], 
	["serve", "ball_spawn"], 
	["stats", "ball_despawn"], 
]


func listed(entry: Dictionary) -> bool:
	return not bool(entry.get("parked", false))

func may_share(a: String, b: String) -> bool:
	for pair in MAY_SHARE:
		if a in pair and b in pair:
			return true
	return false

func _register_code_actions() -> void :
	for entry in CODE_ACTIONS:
		var action: String = entry.action
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, 0.2)
		for slot in ["kb", "pad"]:
			if not entry.has(slot):
				continue
			var e: = event_from_data(entry[slot])
			e.device = -1
			InputMap.action_add_event(action, e)


var _defaults: = {}

func _ready() -> void :
	_capture_defaults()




func _capture_defaults() -> void :




	if not _defaults.is_empty():
		return
	_register_code_actions()
	for entry in REBINDABLE:
		var action: String = entry.action
		if not InputMap.has_action(action):
			continue
		var kb: InputEvent = null
		var kb2: InputEvent = null
		var pad: InputEvent = null
		for e in InputMap.action_get_events(action):
			if e is InputEventKey or e is InputEventMouseButton:
				if kb == null:
					kb = e
				elif kb2 == null and bool(entry.get("kb2", false)):
					kb2 = e
			elif (e is InputEventJoypadButton or e is InputEventJoypadMotion) and pad == null:
				pad = e
		_defaults[action] = {"kb": kb, "kb2": kb2, "pad": pad}



func apply(bindings: Dictionary) -> void :



	if _defaults.is_empty():
		_capture_defaults()
	for entry in REBINDABLE:
		var action: String = entry.action
		if not InputMap.has_action(action):
			continue
		var over: Dictionary = bindings.get(action, {})
		var evs: Array = [_event_for(action, "kb", over), _event_for(action, "pad", over)]
		if bool(entry.get("kb2", false)):
			evs.append(_event_for(action, "kb2", over))
		InputMap.action_erase_events(action)
		for e in evs:
			if e != null:
				InputMap.action_add_event(action, e)



	if InputPrompts != null:
		InputPrompts.refresh()



func _event_for(action: String, slot: String, over: Dictionary) -> InputEvent:
	if over.has(slot):
		return event_from_data(over[slot])
	var d: Dictionary = _defaults.get(action, {})
	return d.get(slot, null)









func resolve(bindings: Dictionary) -> Dictionary:
	if _defaults.is_empty():
		_capture_defaults()
	var out: = {}
	for entry in REBINDABLE:
		var action: String = entry.action
		if not bindings.has(action):
			continue
		var over: Dictionary = bindings.get(action, {})
		var evs: Array = []
		for slot in SLOTS:
			if not bool(entry.get(slot, false)):
				continue
			var e: = _event_for(action, slot, over)
			if e != null:
				evs.append(e)
		out[action] = evs
	return out

func default_data(action: String, slot: String) -> Variant:
	var d: Dictionary = _defaults.get(action, {})
	var e: InputEvent = d.get(slot, null)
	return event_to_data(e) if e != null else null



func event_to_data(e: InputEvent) -> Variant:
	if e is InputEventKey:
		var k: = e as InputEventKey
		return {"t": "key", "c": int(k.physical_keycode if k.physical_keycode != 0 else k.keycode)}
	if e is InputEventMouseButton:
		return {"t": "mouse", "c": int((e as InputEventMouseButton).button_index)}
	if e is InputEventJoypadButton:
		return {"t": "joyb", "c": int((e as InputEventJoypadButton).button_index)}
	if e is InputEventJoypadMotion:
		var m: = e as InputEventJoypadMotion
		return {"t": "joym", "a": int(m.axis), "d": signf(m.axis_value)}
	return null

func event_from_data(d: Variant) -> InputEvent:
	if not (d is Dictionary):
		return null
	match String(d.get("t", "")):
		"key":
			var k: = InputEventKey.new()
			k.physical_keycode = int(d.get("c", 0))
			return k
		"mouse":
			var mb: = InputEventMouseButton.new()
			mb.button_index = int(d.get("c", 0))
			return mb
		"joyb":
			var jb: = InputEventJoypadButton.new()
			jb.button_index = int(d.get("c", 0))
			return jb
		"joym":
			var jm: = InputEventJoypadMotion.new()
			jm.axis = int(d.get("a", 0))
			jm.axis_value = float(d.get("d", 1.0))
			return jm
	return null



func event_matches_slot(e: InputEvent, slot: String) -> bool:
	if slot_kind(slot) == "kb":
		return e is InputEventKey or e is InputEventMouseButton
	return e is InputEventJoypadButton or e is InputEventJoypadMotion



func label_for(action: String, slot: String, bindings: Dictionary) -> String:
	var over: Dictionary = bindings.get(action, {})
	var data: Variant = over[slot] if over.has(slot) else default_data(action, slot)
	return label_for_data(data)

func label_for_data(d: Variant) -> String:
	if not (d is Dictionary):
		return "—"
	match String(d.get("t", "")):
		"key":
			return OS.get_keycode_string(int(d.get("c", 0)))
		"mouse":
			match int(d.get("c", 0)):
				MOUSE_BUTTON_LEFT: return "LMB"
				MOUSE_BUTTON_RIGHT: return "RMB"
				MOUSE_BUTTON_MIDDLE: return "MMB"
				_: return "mouse %d" % int(d.get("c", 0))
		"joyb":
			return _JOY_BTN.get(int(d.get("c", 0)), "button %d" % int(d.get("c", 0)))
		"joym":
			var axis: = int(d.get("a", 0))
			var pos: bool = float(d.get("d", 1.0)) >= 0.0
			if axis == JOY_AXIS_TRIGGER_LEFT:
				return "LT"
			if axis == JOY_AXIS_TRIGGER_RIGHT:
				return "RT"
			return "%s %s" % [_AXIS.get(axis, "axis %d" % axis), "+" if pos else "-"]
	return "—"


const _JOY_BTN: = {
	JOY_BUTTON_A: "A / cross", 
	JOY_BUTTON_B: "B / circle", 
	JOY_BUTTON_X: "X / square", 
	JOY_BUTTON_Y: "Y / triangle", 
	JOY_BUTTON_LEFT_SHOULDER: "LB", 
	JOY_BUTTON_RIGHT_SHOULDER: "RB", 
	JOY_BUTTON_BACK: "select", 
	JOY_BUTTON_START: "start", 
	JOY_BUTTON_LEFT_STICK: "L3", 
	JOY_BUTTON_RIGHT_STICK: "R3", 
	JOY_BUTTON_DPAD_UP: "dpad up", 
	JOY_BUTTON_DPAD_DOWN: "dpad down", 
	JOY_BUTTON_DPAD_LEFT: "dpad left", 
	JOY_BUTTON_DPAD_RIGHT: "dpad right", 
}
const _AXIS: = {
	JOY_AXIS_LEFT_X: "L-stick x", 
	JOY_AXIS_LEFT_Y: "L-stick y", 
	JOY_AXIS_RIGHT_X: "R-stick x", 
	JOY_AXIS_RIGHT_Y: "R-stick y", 
}
