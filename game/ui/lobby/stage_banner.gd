class_name StageBanner
extends PanelContainer








signal changed(id: String)
signal tod_changed(index: int)
signal outfit_changed(index: int)

const HEIGHT: = 96.0

var ids: Array = []
var current: = ""
var editable: = true:
	set(v):
		editable = v
		if _left != null:
			_left.visible = v
			_right.visible = v
		if _tod_row != null:
			_paint_tod()

var _thumb: TextureRect
var _ph: ColorRect
var _art: Control
var _tween: Tween = null
var _ribbon: PanelContainer
var _title: Label
var _sub: Label
var _left: Button
var _right: Button
var _tod_row: HBoxContainer
var _tod: = 0




var _outfit_btn: UiSelect
var _outfit: = 0
var _outfit_edit: = true
static var _warned: = {}

func _init() -> void :
	custom_minimum_size = Vector2(0, HEIGHT)
	clip_contents = true
	var box: = StyleBoxFlat.new()
	box.bg_color = Color("6fb7ff")
	box.set_corner_radius_all(16)
	add_theme_stylebox_override("panel", box)
	var stack: = Control.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)
	_art = Control.new()
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_art)


	_ph = ColorRect.new()
	_ph.color = Color.WHITE
	_ph.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.add_child(_ph)
	_thumb = TextureRect.new()
	_thumb.set_anchors_preset(Control.PRESET_FULL_RECT)
	_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.add_child(_thumb)

	var wash: = ColorRect.new()
	wash.color = Color(0, 0, 0, 0.1)
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(wash)
	var centre: = CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(centre)
	var col: = VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centre.add_child(col)

	_ribbon = PanelContainer.new()
	_ribbon.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_ribbon.rotation = deg_to_rad(-3.0)

	_ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ribbon.resized.connect( func(): _ribbon.pivot_offset = _ribbon.size * 0.5)
	col.add_child(_ribbon)
	_title = Label.new()
	_title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_title.add_theme_font_size_override("font_size", 34)
	_title.add_theme_color_override("font_color", Color.WHITE)
	_title.add_theme_color_override("font_outline_color", UiStyle.INK)
	_title.add_theme_constant_override("outline_size", 9)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	_title.add_theme_constant_override("shadow_offset_x", 2)
	_title.add_theme_constant_override("shadow_offset_y", 4)
	_title.add_theme_constant_override("shadow_outline_size", 9)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ribbon.add_child(_title)
	var subwrap: = CenterContainer.new()
	subwrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(subwrap)
	_sub = Label.new()
	UiStyle.style_pill(_sub, Color(1, 1, 1, 0.92), UiStyle.INK, 10)
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subwrap.add_child(_sub)

	var todwrap: = CenterContainer.new()
	todwrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(todwrap)
	_tod_row = HBoxContainer.new()
	_tod_row.add_theme_constant_override("separation", 6)
	_tod_row.visible = false
	todwrap.add_child(_tod_row)
	_left = _arrow("arrowLeft")
	_left.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	_left.grow_vertical = Control.GROW_DIRECTION_BOTH
	_left.offset_left = 8.0
	_left.pressed.connect( func(): step(-1))
	stack.add_child(_left)
	_right = _arrow("arrowRight")
	_right.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_right.grow_vertical = Control.GROW_DIRECTION_BOTH
	_right.offset_right = -8.0
	_right.pressed.connect( func(): step(1))
	stack.add_child(_right)


	_outfit_btn = UiSelect.new(DressCode.LABELS)
	_outfit_btn.name = "OutfitsPill"
	_outfit_btn.prefix = "outfits: "
	_outfit_btn.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_outfit_btn.add_theme_font_size_override("font_size", 13)
	_outfit_btn.custom_minimum_size = Vector2(0, 24)
	_outfit_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_outfit_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_outfit_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_outfit_btn.offset_right = -14.0
	_outfit_btn.offset_bottom = -10.0
	_outfit_btn.picked.connect( func(i: int):
		if not _outfit_edit or i == _outfit:
			return
		_outfit = DressCode.clamp_rule(i)
		_paint_outfit()
		outfit_changed.emit(_outfit))
	stack.add_child(_outfit_btn)
	_paint_outfit()




	var frame: = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(0, 0, 0, 0)
	fb.set_corner_radius_all(24)
	fb.set_border_width_all(8)
	fb.border_color = UiStyle.card()
	fb.set_expand_margin_all(8.0)
	frame.add_theme_stylebox_override("panel", fb)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(frame)
	var edge: = Panel.new()
	var eb: = StyleBoxFlat.new()
	eb.bg_color = Color(0, 0, 0, 0)
	eb.set_corner_radius_all(16)
	eb.set_border_width_all(3)
	eb.border_color = Color(UiStyle.INK, 0.18)
	edge.add_theme_stylebox_override("panel", eb)
	edge.set_anchors_preset(Control.PRESET_FULL_RECT)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(edge)


func _arrow(icon_name: String) -> Button:
	var b: = Button.new()
	b.custom_minimum_size = Vector2(30, 30)
	b.icon = UiStyle.icon(icon_name, false, true)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 14)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1, 1.0 if st == "hover" else 0.9)
		sb.set_corner_radius_all(99)
		if st == "focus":
			sb.set_border_width_all(2)
			sb.border_color = UiStyle.PRIMARY
		b.add_theme_stylebox_override(st, sb)
	b.focus_mode = Control.FOCUS_ALL
	UiStyle.press_bounce(b)
	return b


func set_ids(list: Array) -> void :
	ids = list.duplicate()
	if current == "" and not ids.is_empty():
		set_stage(String(ids[0]))


func set_stage(id: String, dir: = 0) -> void :
	if not Stage.STAGES.has(id):
		return
	var changed: = id != current
	current = id
	if changed and dir != 0 and is_inside_tree():


		if _tween != null and _tween.is_valid():
			_tween.kill()
		_art.position.x = 46.0 * dir
		_art.modulate.a = 0.0
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(_art, "position:x", 0.0, 0.26)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_art, "modulate:a", 1.0, 0.18)
		UiStyle.pop_in(_ribbon)
	_title.text = Stage.title(id)


	if changed or _tod_row.get_child_count() == 0:
		_build_tod()
	else:
		_paint_tod()
	_sub.visible = false
	var tex: = Stage.thumb(id)
	_thumb.texture = tex
	_thumb.visible = tex != null
	_ph.visible = tex == null
	if tex == null:

		if not _warned.has(id):
			_warned[id] = true
			print("[stage] no thumbnail for '%s' (expected %s), using placeholder" % [id, Stage.thumb_path(id)])



func set_outfit(index: int, can_edit: bool, shown: = true) -> void :
	_outfit = DressCode.clamp_rule(index)
	_outfit_edit = can_edit
	_outfit_btn.visible = shown
	_paint_outfit()


func _paint_outfit() -> void :
	if _outfit_btn == null:
		return
	if _outfit_btn.selected != _outfit:
		_outfit_btn.selected = _outfit
	_outfit_btn.disabled = not _outfit_edit
	var on: = _outfit != DressCode.CURRENT
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = StyleBoxFlat.new()
		sb.set_corner_radius_all(12)
		sb.bg_color = Color.WHITE if on else Color(0.08, 0.1, 0.16, 0.55)
		if st == "hover" and _outfit_edit:
			sb.bg_color = Color(0.92, 0.94, 1.0) if on else Color(0.08, 0.1, 0.16, 0.72)
		if st == "focus":

			sb.set_border_width_all(2)
			sb.border_color = UiStyle.INK if on else Color.WHITE
		sb.content_margin_left = 10
		sb.content_margin_right = 8
		_outfit_btn.add_theme_stylebox_override(st, sb)
	var fc: = UiStyle.INK if on else Color.WHITE
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		_outfit_btn.add_theme_color_override(k, fc)
	_outfit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if _outfit_edit else Control.CURSOR_ARROW


func set_tod(index: int) -> void :
	_tod = index
	_paint_tod()

func _build_tod() -> void :


	for c in _tod_row.get_children():
		_tod_row.remove_child(c)
		c.queue_free()
	var labels: = Stage.tod_labels(current)
	_tod_row.visible = labels.size() > 1
	for i in labels.size():
		var b: = Button.new()
		b.text = String(labels[i])
		b.focus_mode = Control.FOCUS_ALL
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		b.add_theme_font_size_override("font_size", 14)
		b.custom_minimum_size = Vector2(74, 26)
		var idx: = i
		b.pressed.connect( func():
			if not editable or idx == _tod:
				return
			_tod = idx
			_paint_tod()
			UiStyle.sfx("tick")
			tod_changed.emit(idx))
		_tod_row.add_child(b)
	_paint_tod()



func _paint_tod() -> void :
	var n: = _tod_row.get_child_count()
	var pick: = clampi(_tod, 0, maxi(n - 1, 0))
	for i in n:
		var b: = _tod_row.get_child(i) as Button
		var on: = i == pick
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			var sb: = StyleBoxFlat.new()
			sb.set_corner_radius_all(13)
			sb.bg_color = Color.WHITE if on else Color(0.08, 0.1, 0.16, 0.55)
			if st == "hover" and not on:
				sb.bg_color = Color(0.08, 0.1, 0.16, 0.72)
			if st == "focus":
				sb.bg_color = Color(0, 0, 0, 0)
				sb.set_border_width_all(2)
				sb.border_color = Color.WHITE
			sb.content_margin_left = 10
			sb.content_margin_right = 10
			b.add_theme_stylebox_override(st, sb)
		var fc: = UiStyle.INK if on else Color.WHITE
		for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			b.add_theme_color_override(k, fc)
		b.disabled = not editable and not on
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if editable else Control.CURSOR_ARROW


func step(dir: int) -> void :
	if ids.is_empty() or not editable:
		return
	var i: = ids.find(current)
	i = (i + dir + ids.size()) % ids.size() if i >= 0 else 0
	set_stage(String(ids[i]), dir)
	UiStyle.sfx("tick")
	changed.emit(current)

func arrow_buttons() -> Array:
	return [_left, _right]
