extends CanvasLayer
















const SELF_PATH: = "res://game/ui/style/pad_keyboard.gd"
const ROWS: = ["1234567890", "qwertyuiop", "asdfghjkl-", "zxcvbnm_.@"]
const KEY: = 58.0
const STICK: = 0.6

static var _current: WeakRef = null

var field: Control = null
var back_to: Control = null
var _keys: Array = []
var _r: = 1
var _c: = 0
var _shift: = false
var _preview: Label = null
var _eat_accept: = true
var _stick: = Vector2i.ZERO

static func is_open() -> bool:
	return _current != null and _current.get_ref() != null

static func open(f: Control, return_to: Control = null) -> void :
	if is_open() or f == null or not f.is_inside_tree():
		return
	if f is LineEdit and not (f as LineEdit).editable:
		return
	if f is TextEdit and not (f as TextEdit).editable:
		return
	if not (f is LineEdit or f is TextEdit):
		return
	if _steam_keyboard(f):
		return
	var kb: CanvasLayer = load(SELF_PATH).new()
	kb.set("field", f)
	kb.set("back_to", return_to)

	f.release_focus()
	f.get_tree().root.add_child(kb)



static func _steam_keyboard(f: Control) -> bool:
	if not Engine.has_singleton("Steam"):
		return false
	var s: Object = Engine.get_singleton("Steam")
	if not s.has_method("showFloatingGamepadTextInput"):
		return false
	var on_deck: bool = s.has_method("isSteamRunningOnSteamDeck") and bool(s.isSteamRunningOnSteamDeck())
	var big: bool = s.has_method("isSteamInBigPictureMode") and bool(s.isSteamInBigPictureMode())
	if not (on_deck or big):
		return false
	var r: = f.get_global_rect()
	var xf: = f.get_viewport().get_final_transform()
	var p: = xf * r.position
	var size: = xf.basis_xform(r.size)
	var mode: = 1 if f is TextEdit else 0
	return bool(s.showFloatingGamepadTextInput(mode, int(p.x), int(p.y), int(size.x), int(size.y)))

func _ready() -> void :
	layer = 125
	_current = weakref(self)
	_build()
	_paint()
	_focus_key()
	UiStyle.sfx("open")

func _exit_tree() -> void :
	if _current != null and _current.get_ref() == self:
		_current = null



func _build() -> void :
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.35)
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)
	var root: = MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_bottom", 28)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var col: = VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_END
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(col)
	var center: = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(center)
	var panel: = PanelContainer.new()
	var fsb: = UiStyle.field_box(30)
	fsb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", fsb)
	center.add_child(panel)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)

	var cap: = PanelContainer.new()
	var csb: = UiStyle.card_box(UiStyle._AUTO, UiStyle.CAPSULE)
	csb.content_margin_left = 22.0
	csb.content_margin_right = 22.0
	csb.content_margin_top = 8.0
	csb.content_margin_bottom = 8.0
	cap.add_theme_stylebox_override("panel", csb)
	v.add_child(cap)
	_preview = Label.new()
	_preview.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_preview.add_theme_font_size_override("font_size", 24)
	_preview.add_theme_color_override("font_color", UiStyle.text())
	_preview.clip_text = true
	_preview.custom_minimum_size.x = KEY * 10 + 6 * 9
	cap.add_child(_preview)
	for row in ROWS:
		var h: = HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		h.alignment = BoxContainer.ALIGNMENT_CENTER
		v.add_child(h)
		var keys: Array = []
		for ch in row:
			keys.append(_key(h, ch, KEY, _type.bind(ch)))
		_keys.append(keys)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(h)
	_keys.append([
		_key(h, "shift", KEY * 2 + 6, _toggle_shift), 
		_key(h, "space", KEY * 4 + 18, _type.bind(" ")), 
		_key(h, "delete", KEY * 2 + 6, _delete), 
		_key(h, "done", KEY * 2 + 6, _done, "blue"), 
	])
	var hint: = Label.new()
	hint.text = "A type    X delete    Y space    start done    B close"
	hint.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", UiStyle.field_ink())
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(hint)
	UiStyle.pop_in(panel)

func _key(row: HBoxContainer, text: String, w: float, on_press: Callable, kind: = "secondary") -> Button:
	var b: = Button.new()
	b.text = text
	UiStyle.style_button(b, kind, 20)
	b.custom_minimum_size = Vector2(w, KEY)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(on_press)
	b.pressed.connect( func(): UiStyle.sfx("tick"))
	row.add_child(b)
	return b



func _text() -> String:
	if field is LineEdit:
		return (field as LineEdit).text
	if field is TextEdit:
		return (field as TextEdit).text
	return ""

func _set_text(t: String) -> void :
	if not is_instance_valid(field):
		return
	if field is LineEdit:
		var le: = field as LineEdit
		if le.max_length > 0 and t.length() > le.max_length:
			return
		le.text = t
		le.caret_column = t.length()
		le.text_changed.emit(t)
	elif field is TextEdit:
		(field as TextEdit).text = t
		(field as TextEdit).text_changed.emit()
	_paint()

func _type(ch: String) -> void :
	var c: = ch.to_upper() if _shift else ch
	_set_text(_text() + c)
	if _shift:
		_shift = false
		_paint()

func _delete() -> void :
	var t: = _text()
	if t != "":
		_set_text(t.left(t.length() - 1))

func _toggle_shift() -> void :
	_shift = not _shift
	_paint()

func _done() -> void :
	var f: = field
	_close()
	if is_instance_valid(f) and f is LineEdit:
		(f as LineEdit).text_submitted.emit((f as LineEdit).text)

func _close() -> void :
	if back_to != null and is_instance_valid(back_to) and back_to.is_inside_tree():
		back_to.grab_focus()
	elif is_instance_valid(field) and field.is_inside_tree():
		field.grab_focus()
	UiStyle.sfx("close")
	queue_free()

func _paint() -> void :
	var t: = _text()
	if field is LineEdit and (field as LineEdit).secret:
		t = "•".repeat(t.length())
	if t == "" and field is LineEdit:
		_preview.text = (field as LineEdit).placeholder_text
		_preview.modulate.a = 0.45
	else:
		_preview.text = t + "|"
		_preview.modulate.a = 1.0
	for r in _keys.size() - 1:
		for k in _keys[r]:
			var b: = k as Button
			b.text = b.text.to_upper() if _shift else b.text.to_lower()
	(_keys[_keys.size() - 1][0] as Button).text = "SHIFT" if _shift else "shift"



func _focus_key() -> void :
	_r = clampi(_r, 0, _keys.size() - 1)
	_c = clampi(_c, 0, (_keys[_r] as Array).size() - 1)
	(_keys[_r][_c] as Button).grab_focus()

func _move(d: Vector2i) -> void :
	var from_w: = float(_c) / maxf((_keys[_r] as Array).size() - 1, 1)
	if d.y != 0:
		_r = wrapi(_r + d.y, 0, _keys.size())

		_c = roundi(from_w * ((_keys[_r] as Array).size() - 1))
	else:
		_c = wrapi(_c + d.x, 0, (_keys[_r] as Array).size())
	_focus_key()
	UiStyle.sfx("hover")

func _input(event: InputEvent) -> void :
	if event is InputEventJoypadButton:
		var j: = event as InputEventJoypadButton
		get_viewport().set_input_as_handled()
		if not j.pressed:
			if j.button_index == JOY_BUTTON_A:
				_eat_accept = false
			return
		match j.button_index:
			JOY_BUTTON_DPAD_UP: _move(Vector2i(0, -1))
			JOY_BUTTON_DPAD_DOWN: _move(Vector2i(0, 1))
			JOY_BUTTON_DPAD_LEFT: _move(Vector2i(-1, 0))
			JOY_BUTTON_DPAD_RIGHT: _move(Vector2i(1, 0))
			JOY_BUTTON_A:
				if not _eat_accept:
					(_keys[_r][_c] as Button).pressed.emit()
			JOY_BUTTON_X: _delete()
			JOY_BUTTON_Y: _type(" ")
			JOY_BUTTON_START: _done()
			JOY_BUTTON_B: _close()
	elif event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		var m: = event as InputEventJoypadMotion
		if m.axis != JOY_AXIS_LEFT_X and m.axis != JOY_AXIS_LEFT_Y:
			return
		var s: = Vector2i(
			0 if absf(Input.get_joy_axis(m.device, JOY_AXIS_LEFT_X)) < STICK else signi(int(signf(Input.get_joy_axis(m.device, JOY_AXIS_LEFT_X)))), 
			0 if absf(Input.get_joy_axis(m.device, JOY_AXIS_LEFT_Y)) < STICK else signi(int(signf(Input.get_joy_axis(m.device, JOY_AXIS_LEFT_Y)))))
		if s != _stick and s != Vector2i.ZERO:
			_move(Vector2i(s.x, 0) if s.x != 0 else Vector2i(0, s.y))
		_stick = s
	elif event is InputEventKey and (event as InputEventKey).pressed:

		_close()
