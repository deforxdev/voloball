class_name SeatRebind
extends Control
















signal closed

const ROW_H: = 32
const VISIBLE_ROWS: = 7
const LISTEN_SWALLOW_MS: = 180
const LISTEN_TIMEOUT_MS: = 5000



const LEADER_ONLY: = ["stats", "chat_toggle", "free_mouse"]

var slot: LocalPlayerSlot = null
var kind: = InputPrompts.Kind.GAMEPAD
var is_leader: = false

var _rows: Array = []
var _cursor: = 0
var _stop: = 0
var _listen_action: = ""
var _listen_since: = 0
var _held: = ""
var _repeat: = 0.0
var _swallow_next: = false
var _list: VBoxContainer
var _scroll: ScrollContainer
var _tint: = Color.WHITE

func _slot_key() -> String:
	return "kb" if kind == InputPrompts.Kind.KBM else "pad"

func _table() -> Dictionary:

	if is_leader or slot == null:
		return {}
	return slot.binding_table()

func _style() -> int:
	if slot != null and slot.device >= 0:
		return InputPrompts.style_for_device(slot.device)
	return InputPrompts.active_style()

func open(for_slot: LocalPlayerSlot, for_kind: int, tint: Color) -> void :
	slot = for_slot
	kind = for_kind
	is_leader = for_slot != null and for_slot.index == 0
	_tint = tint
	_cursor = 0
	_stop = 0
	_listen_action = ""
	for c in get_children():
		c.queue_free()
	_build()

func _build() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v: = VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 4)
	add_child(v)

	var title: = Label.new()
	title.text = "controls"
	title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiStyle.INK)
	v.add_child(title)
	var rule: = Panel.new()
	rule.custom_minimum_size = Vector2(36, 4)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var rb: = StyleBoxFlat.new()
	rb.bg_color = _tint
	rb.set_corner_radius_all(2)
	rule.add_theme_stylebox_override("panel", rb)
	v.add_child(rule)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER



	_scroll.custom_minimum_size.y = 0
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 2)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_list)
	_rows.clear()
	var want_slot: = _slot_key()
	for entry in InputBinds.REBINDABLE:
		if not bool(entry.get(want_slot, false)) or not InputBinds.listed(entry):
			continue
		if not is_leader and String(entry.action) in LEADER_ONLY:
			continue
		_add_row(String(entry.action), String(entry.label))
	if not is_leader:
		var note: = Label.new()
		note.text = "scoreboard, chat and free mouse follow player 1"
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.style_label(note, "small", UiStyle.muted())
		_list.add_child(note)

	var pinned: = VBoxContainer.new()
	pinned.add_theme_constant_override("separation", 4)
	v.add_child(pinned)
	if is_leader:
		pinned.add_child(_pinned_row("show keyboard" if kind == InputPrompts.Kind.GAMEPAD
			else "show controller", func(): _flip_kind()))
	pinned.add_child(_pinned_row("reset all controls", func(): _reset_all()))

	var hint: = HBoxContainer.new()
	hint.alignment = BoxContainer.ALIGNMENT_CENTER
	hint.add_theme_constant_override("separation", 8)
	v.add_child(hint)
	hint.add_child(_hint("ui_accept", "rebind"))
	hint.add_child(_hint("ui_cancel", "back"))
	_paint()

func _add_row(action: String, label_text: String) -> void :



	var row: = Control.new()
	row.custom_minimum_size.y = ROW_H
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var h: = HBoxContainer.new()
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(h)

	var bind_btn: Control = Button.new() if is_leader else Control.new()
	bind_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bind_btn.custom_minimum_size.y = ROW_H
	if bind_btn is Button:
		(bind_btn as Button).flat = true
		(bind_btn as Button).focus_mode = Control.FOCUS_ALL
		(bind_btn as Button).pressed.connect( func():
			_cursor = _index_of(action)
			_stop = 0
			_begin_listen())
	else:
		bind_btn.focus_mode = Control.FOCUS_NONE
		bind_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		bind_btn.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_cursor = _index_of(action)
				_stop = 0
				_begin_listen())
	var bh: = HBoxContainer.new()
	bh.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bh.add_theme_constant_override("separation", 6)
	bh.offset_left = 4.0
	bh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bind_btn.add_child(bh)
	var lbl: = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", UiStyle.INK)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.clip_text = true
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bh.add_child(lbl)
	var plate: = PanelContainer.new()
	plate.custom_minimum_size = Vector2(38, 24)
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pb: = StyleBoxFlat.new()
	pb.bg_color = Color("141a26") if UiStyle.dark else UiStyle.INK
	pb.set_corner_radius_all(8)
	pb.set_content_margin_all(3.0)
	plate.add_theme_stylebox_override("panel", pb)
	bh.add_child(plate)
	var glyph: = TextureRect.new()
	glyph.custom_minimum_size = Vector2(26, 18)
	glyph.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glyph.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(glyph)
	var text: = Label.new()
	text.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	text.add_theme_font_size_override("font_size", 11)
	text.add_theme_color_override("font_color", Color.WHITE)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(text)
	h.add_child(bind_btn)

	var reset: Control = Button.new() if is_leader else Control.new()
	reset.custom_minimum_size = Vector2(28, 24)
	reset.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if reset is Button:
		(reset as Button).flat = true
		(reset as Button).focus_mode = Control.FOCUS_ALL
		(reset as Button).pressed.connect( func(): _reset_one(action))
	else:
		reset.focus_mode = Control.FOCUS_NONE
		reset.mouse_filter = Control.MOUSE_FILTER_STOP
		reset.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_reset_one(action))
	var reset_ic: = TextureRect.new()
	reset_ic.texture = UiStyle.icon("return", false, true)
	reset_ic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	reset_ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reset_ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reset_ic.modulate = UiStyle.SECONDARY
	reset_ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reset.add_child(reset_ic)
	h.add_child(reset)
	_list.add_child(row)
	_rows.append({"action": action, "row": row, "bind_btn": bind_btn, "plate": plate, 
		"glyph": glyph, "text": text, "reset": reset, "reset_ic": reset_ic, "pb": pb})

func _pinned_row(text_in: String, on_press: Callable) -> Control:
	var b: = Button.new()
	b.text = text_in
	UiStyle.style_button(b, "secondary", 14)
	b.custom_minimum_size.y = 28
	if not is_leader:
		b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(on_press)
	return b

func _hint(action: String, text_in: String) -> Control:
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 4)
	var plate: = PanelContainer.new()
	var pb: = StyleBoxFlat.new()
	pb.bg_color = Color("141a26") if UiStyle.dark else UiStyle.INK
	pb.set_corner_radius_all(8)
	pb.set_content_margin_all(3.0)
	plate.add_theme_stylebox_override("panel", pb)
	var g: = TextureRect.new()
	g.texture = InputPrompts.glyph_on(action, kind, _style())
	g.custom_minimum_size = Vector2(22, 16)
	g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	plate.add_child(g)
	h.add_child(plate)
	var l: = Label.new()
	l.text = text_in
	UiStyle.style_label(l, "small", UiStyle.muted())
	h.add_child(l)
	return h

func _index_of(action: String) -> int:
	for i in _rows.size():
		if String(_rows[i].action) == action:
			return i
	return 0



func _paint() -> void :
	var table: = _table()
	var binds: Dictionary = slot.profile.bindings if (slot != null and slot.profile != null) else {}
	for i in _rows.size():
		var r: Dictionary = _rows[i]
		var action: = String(r.action)
		var listening: = action == _listen_action
		var pb: StyleBoxFlat = r.pb
		pb.bg_color = UiStyle.PRIMARY if listening\
		else (Color("141a26") if UiStyle.dark else UiStyle.INK)
		if listening:
			(r.glyph as TextureRect).visible = false
			(r.text as Label).visible = true
			(r.text as Label).text = "press a key" if kind == InputPrompts.Kind.KBM else "press a button"
			(r.text as Label).add_theme_color_override("font_color", UiStyle.INK)
		else:
			var tex: = InputPrompts.glyph_on(action, kind, _style(), table)
			(r.glyph as TextureRect).texture = tex
			(r.glyph as TextureRect).visible = tex != null
			(r.text as Label).visible = tex == null
			(r.text as Label).text = InputBinds.label_for(action, _slot_key(), binds)
			(r.text as Label).add_theme_color_override("font_color", Color.WHITE)

		var on: = i == _cursor and not is_leader
		(r.reset_ic as TextureRect).modulate = _tint if (on and _stop == 1) else UiStyle.SECONDARY
	queue_redraw()

func _draw() -> void :


	if is_leader or _rows.is_empty() or _cursor >= _rows.size():
		return
	var r: Dictionary = _rows[_cursor]
	var target: Control = (r.reset if _stop == 1 else r.bind_btn) as Control
	if not is_instance_valid(target):
		return
	var rect: = Rect2(target.global_position - global_position, target.size)
	draw_rect(rect, Color(_tint, 0.16), true)
	draw_rect(rect, _tint, false, 2.0)





func tick(reader: DeviceInput, delta: float) -> void :
	if _swallow_next:

		_swallow_next = false
		return
	if _listen_action != "":


		if Time.get_ticks_msec() - _listen_since >= LISTEN_TIMEOUT_MS:
			_listen_action = ""
			_paint()
		return
	var dir: = ""
	if reader.pressed("ui_down"):
		dir = "down"
	elif reader.pressed("ui_up"):
		dir = "up"
	var step: = 0
	if dir == "":
		_held = ""
	elif dir != _held:
		_held = dir
		_repeat = 0.42
		step = 1 if dir == "down" else -1
	else:
		_repeat -= delta
		if _repeat <= 0.0:
			_repeat = 0.11
			step = 1 if dir == "down" else -1
	if step != 0 and not _rows.is_empty():
		_cursor = clampi(_cursor + step, 0, _rows.size() - 1)
		_ensure_visible()
		UiStyle.sfx("hover")
		_paint()
	if reader.just_pressed("ui_left") or reader.just_pressed("ui_right"):
		_stop = 1 - _stop
		_paint()
	if reader.just_pressed("ui_accept") and not _rows.is_empty():
		if _stop == 0:
			_begin_listen()
		else:
			_reset_one(String(_rows[_cursor].action))
	elif reader.just_pressed("ui_cancel"):
		closed.emit()

func _ensure_visible() -> void :
	if _scroll == null:
		return
	var y: = _cursor * (ROW_H + 2)
	var top: = _scroll.scroll_vertical
	var bottom: = top + int(_scroll.size.y) - ROW_H
	if y < top:
		_scroll.scroll_vertical = y
	elif y > bottom:
		_scroll.scroll_vertical = y - int(_scroll.size.y) + ROW_H + 2

func _begin_listen() -> void :
	if _rows.is_empty():
		return
	_listen_action = String(_rows[_cursor].action)
	_listen_since = Time.get_ticks_msec()
	_swallow_next = true
	UiStyle.sfx("tick")
	_paint()

func listening() -> bool:
	return _listen_action != ""

func _past_swallow() -> bool:
	return Time.get_ticks_msec() - _listen_since >= LISTEN_SWALLOW_MS




func _owns(event: InputEvent) -> bool:
	if slot == null:
		return false
	if slot.device >= 0:
		return (event is InputEventJoypadButton or event is InputEventJoypadMotion)\
		and event.device == slot.device
	if slot.device == DeviceInput.KBM:
		return event is InputEventKey or event is InputEventMouseButton

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return not (event.device in LocalPlayers.claimed_pads())
	if event is InputEventKey or event is InputEventMouseButton:
		return not LocalPlayers.kbm_taken()
	return false



func capture(event: InputEvent) -> bool:
	if _listen_action == "" or not _past_swallow():
		return false
	if not _owns(event):
		return false



	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		_listen_action = ""
		_swallow_next = true
		_paint()
		return true
	var captured: InputEvent = null
	if kind == InputPrompts.Kind.KBM:
		if event is InputEventKey and event.pressed and not (event as InputEventKey).echo:
			captured = event
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			captured = event
	else:
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
			captured = event
		elif event is InputEventJoypadMotion\
		and absf((event as InputEventJoypadMotion).axis_value) > 0.7:
			captured = event
	if captured == null:
		return false
	var a: = _listen_action
	_listen_action = ""
	_swallow_next = true
	if slot.profile != null:
		ProfileStore.set_binding_on(slot.profile, a, _slot_key(), InputBinds.event_to_data(captured))
		LocalPlayers.refresh_bindings(slot)
	UiStyle.sfx("confirm")
	_paint()
	return true

func _reset_one(action: String) -> void :
	if slot == null or slot.profile == null:
		return
	ProfileStore.reset_binding_on(slot.profile, action, _slot_key())
	LocalPlayers.refresh_bindings(slot)
	UiStyle.sfx("tick")
	_paint()

func _reset_all() -> void :
	if slot == null or slot.profile == null:
		return
	ProfileStore.reset_bindings_on(slot.profile)
	LocalPlayers.refresh_bindings(slot)
	UiStyle.sfx("confirm")
	_paint()

func _flip_kind() -> void :
	kind = InputPrompts.Kind.KBM if kind == InputPrompts.Kind.GAMEPAD else InputPrompts.Kind.GAMEPAD
	open(slot, kind, _tint)
