class_name ModifiersPanel
extends Control













signal changed(key: String, value: Variant)
signal reset_pressed
signal closed

const CARD_W: = 560.0


const LIST_MAX_H: = 430.0

const HINT_EDIT: = "customize match properties & settings"
const HINT_READ: = "the host picks these. this is what you are about to play."

var editable: = true:
	set(v):
		editable = v
		_apply_enabled()

var _rows: = {}
var _row_parts: = {}
var _values: = {}
var _card: PanelContainer
var _reset: Button
var _hint: Label
var _quiet: = false

func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var dim: = ColorRect.new()
	dim.color = Color(UiStyle.INK, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect( func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed\
		and e.button_index == MOUSE_BUTTON_LEFT:
			close())
	add_child(dim)

	var centre: = CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	_card = PanelContainer.new()
	_card.custom_minimum_size.x = CARD_W
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	var box: = UiStyle.card_box()
	box.set_corner_radius_all(UiStyle.RADIUS_SOFT)
	box.content_margin_left = 22.0
	box.content_margin_right = 22.0
	box.content_margin_top = 18.0
	box.content_margin_bottom = 16.0
	_card.add_theme_stylebox_override("panel", box)
	centre.add_child(_card)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_card.add_child(v)

	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	v.add_child(head)
	var title: = Label.new()
	title.text = "modifiers"
	UiStyle.style_label(title, "title", UiStyle.text())
	head.add_child(title)
	var hsp: = Control.new()
	hsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(hsp)
	var close_btn: = Button.new()
	close_btn.text = "done"
	UiStyle.style_button(close_btn, "secondary", 15)
	close_btn.pressed.connect(close)
	head.add_child(close_btn)

	_hint = Label.new()
	_hint.text = HINT_EDIT
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(_hint, "small", UiStyle.muted())
	v.add_child(_hint)
	v.add_child(_rule())


	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 0.0
	v.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)



	for e in MatchModifiers.CATALOG:
		var parts: Array = []
		if e != MatchModifiers.CATALOG[0]:
			var line: = _rule()
			list.add_child(line)
			parts.append(line)
		var row: = _entry_row(e as Dictionary)
		list.add_child(row)
		parts.append(row)
		_row_parts[String((e as Dictionary).id)] = parts

	list.resized.connect( func():
		scroll.custom_minimum_size.y = minf(list.get_combined_minimum_size().y, 
			LIST_MAX_H))
	scroll.custom_minimum_size.y = minf(list.get_combined_minimum_size().y, LIST_MAX_H)

	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	v.add_child(foot)
	_reset = Button.new()
	_reset.text = "reset to default"
	UiStyle.style_button(_reset, "tertiary", 13)
	_reset.add_theme_color_override("font_color", UiStyle.muted())
	_reset.pressed.connect( func():
		UiStyle.sfx("tick")
		reset_pressed.emit())
	foot.add_child(_reset)


func _rule() -> Control:
	var d: = Panel.new()
	d.custom_minimum_size = Vector2(0, 2)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(UiStyle.INK, 0.07)
	d.add_theme_stylebox_override("panel", sb)
	return d


func _entry_row(e: Dictionary) -> Control:
	var id: = String(e.id)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var name_lbl: = Label.new()
	name_lbl.text = String(e.name)
	name_lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	name_lbl.add_theme_font_size_override("font_size", 17)
	name_lbl.add_theme_color_override("font_color", UiStyle.text())
	col.add_child(name_lbl)
	var desc: = Label.new()
	desc.text = MatchModifiers.desc(String(e.id))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = CARD_W - 190.0
	UiStyle.style_label(desc, "small", UiStyle.muted())
	col.add_child(desc)
	var ctl: = _control_for(e)
	ctl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ctl)
	_rows[id] = ctl
	return row

func _control_for(e: Dictionary) -> Control:
	var id: = String(e.id)
	if String(e.kind) == MatchModifiers.KIND_CHOICE:
		var sel: = UiSelect.new((e.options as Array).duplicate())
		sel.custom_minimum_size.x = 120.0
		sel.picked.connect( func(i: int): _emit(id, i))
		return sel
	var cb: = CheckBox.new()
	cb.text = ""
	UiStyle.style_check(cb)
	cb.add_theme_constant_override("icon_max_width", 24)
	cb.toggled.connect( func(on: bool): _emit(id, on))
	return cb

func _emit(key: String, value: Variant) -> void :
	if _quiet or not editable:
		return
	UiStyle.sfx("tick")
	_values[key] = value
	changed.emit(key, value)


func set_values(vals: Dictionary) -> void :
	_quiet = true
	for id in vals:
		_values[id] = vals[id]
		var ctl: Control = _rows.get(id)
		if ctl == null:
			continue
		if ctl is CheckBox:
			UiStyle.set_check(ctl as CheckBox, bool(vals[id]))
		elif ctl is UiSelect:
			var sel: = ctl as UiSelect
			sel.selected = clampi(int(vals[id]), 0, sel.options.size() - 1)


	for id in _row_parts:
		for part in _row_parts[id]:
			(part as Control).visible = vals.has(id)
	_quiet = false
	_apply_enabled()

func _apply_enabled() -> void :
	if _reset == null:
		return
	for id in _rows:
		var c: Control = _rows[id]
		if c is BaseButton:
			(c as BaseButton).disabled = not editable
	_reset.visible = editable
	_hint.text = HINT_EDIT if editable else HINT_READ

func open() -> void :
	visible = true
	UiStyle.sfx("open")
	_apply_enabled()

func close() -> void :
	if not visible:
		return
	visible = false
	UiStyle.sfx("back")
	closed.emit()


func _unhandled_input(event: InputEvent) -> void :
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
