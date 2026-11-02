class_name PlayerCard
extends CanvasLayer















signal closed

const CARD: = Vector2i(1200, 760)
const SHOW: = 0.5
const SHOW_COMPACT: = 0.36
const RENDER_PX: = 1024
const PAD: = 0.05
const DEFAULT_POSE: = "idle"
const DEFAULT_BG: = Color.WHITE
const FRAME: = Rect2(56, 56, 440, 648)
const FRAME_INSET: = 24.0
const ZOOM_MIN: = 0.4
const ZOOM_MAX: = 3.0
const ZOOM_STEP: = 1.1
const TILT_MAX: = 45.0
const OUTFIT_CAPTAIN: = 0
const OUTFIT_GYM: = 2


const NAME_MAX: = 12
const NAME_PX: = 76
const NAME_MIN_PX: = 44
const NAME_W: = 600.0
const COL_AT: = Vector2(548, 140)
const QR_SIDE: = 212.0
const QR_AT: = Vector2(CARD.x - 40 - QR_SIDE, 704 - QR_SIDE)

var look: CharacterConfig
var shown_name: = ""
var compact: = false

var outfit: = OUTFIT_CAPTAIN
var zoom: = 1.0
var tilt: = 0.0
var turn: = 0.0

var nudge: = Vector2.ZERO
var bg: = DEFAULT_BG

var _code: = ""
var _vp: SubViewport
var _frame: Panel
var _portrait: TextureRect
var _name_l: Label
var _name_edit: LineEdit
var _pencil: TextureRect
var _pic: TextureRect
var _render: StudioRender
var _pose_i: = 0
var _pose_label: Label
var _outfit_btns: Array = []
var _size: HSlider
var _tilt: HSlider
var _turn: HSlider
var _gen: = 0
var _rendering: = false
var _saving: = false
var _dragging: = false

static func open(host: Node, cfg: CharacterConfig, name_shown: String, small: = false) -> PlayerCard:
	var c: = PlayerCard.new()
	c.look = cfg.clone()
	c.shown_name = name_shown.substr(0, NAME_MAX)
	c.compact = small
	host.add_child(c)
	return c

func _ready() -> void :
	layer = 95
	_code = LookShare.encode(look)
	_pose_i = maxi(StudioRender.pose_ids().find(DEFAULT_POSE), 0)
	_render = StudioRender.new()
	add_child(_render)
	_build_picture()
	_build_popup()
	_pose_changed()
	UiStyle.sfx("open")

func close() -> void :
	if is_queued_for_deletion():
		return
	UiStyle.sfx("close")
	closed.emit()
	queue_free()


func code() -> String:
	return _code

func _show_scale() -> float:
	return SHOW_COMPACT if compact else SHOW



func _build_picture() -> void :
	_vp = SubViewport.new()
	_vp.disable_3d = true
	_vp.transparent_bg = true
	_vp.size = CARD
	_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)




	var card: = Control.new()
	card.size = Vector2(CARD)
	_vp.add_child(card)
	var face: = Panel.new()
	face.size = Vector2(CARD)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = UiStyle.PRIMARY
	sb.set_corner_radius_all(56)
	sb.anti_aliasing_size = 1.5
	face.add_theme_stylebox_override("panel", sb)
	face.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	card.add_child(face)

	var lines: = TextureRect.new()
	lines.texture = load("res://game/character/studio/ball_lines.png")
	lines.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lines.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	lines.modulate = Color(1, 1, 1, 0.32)
	lines.position = Vector2(720, 300)
	lines.size = Vector2(640, 640)
	face.add_child(lines)

	var logo: = TextureRect.new()
	logo.texture = load("res://game/logo/jvlogo_sd.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.size = Vector2(300, 96)
	logo.position = Vector2(CARD.x - 40 - logo.size.x, 28)
	card.add_child(logo)



	_frame = Panel.new()
	var fsb: = StyleBoxFlat.new()
	fsb.bg_color = bg
	fsb.set_corner_radius_all(36)
	_frame.add_theme_stylebox_override("panel", fsb)
	_frame.position = FRAME.position
	_frame.size = FRAME.size
	_frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	card.add_child(_frame)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_frame.add_child(_portrait)
	_place_portrait()
	var rim: = Panel.new()
	var rsb: = StyleBoxFlat.new()
	rsb.draw_center = false
	rsb.set_corner_radius_all(36)
	rsb.border_color = Color(UiStyle.INK, 0.12)
	rsb.set_border_width_all(4)
	rim.add_theme_stylebox_override("panel", rsb)
	rim.position = FRAME.position
	rim.size = FRAME.size
	card.add_child(rim)

	var col: = VBoxContainer.new()
	col.position = COL_AT
	col.size = Vector2(NAME_W, 560)
	col.add_theme_constant_override("separation", 12)
	card.add_child(col)
	_name_l = Label.new()
	_name_l.custom_minimum_size = Vector2(NAME_W, NAME_PX * 1.36)
	_name_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card_text(_name_l, UiStyle.FONT_BLACK, NAME_PX, UiStyle.INK)
	col.add_child(_name_l)
	set_card_name(shown_name)
	var rule: = ColorRect.new()
	rule.color = Color(UiStyle.INK, 0.18)
	rule.custom_minimum_size = Vector2(NAME_W, 4)
	col.add_child(rule)
	col.add_child(_field("number", "#%d" % look.number))
	col.add_child(_field("hand", "left" if look.left_handed else "right"))
	col.add_child(_field("height", _band(look.height, "short", "average", "tall")))
	col.add_child(_field("build", _band(look.weight, "slim", "average", "broad")))
	_add_qr(card)



func _add_qr(card: Control) -> void :
	var grid: = LookShare.qr_grid(_code)
	if grid.is_empty():
		return
	var px: = maxi(int(QR_SIDE / (grid.size() + 4.0)), 2)
	var panel: = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(24)
	panel.add_theme_stylebox_override("panel", sb)
	panel.position = QR_AT
	panel.size = Vector2(QR_SIDE, QR_SIDE)
	card.add_child(panel)
	var side: = float(px * grid.size())
	var qr: = TextureRect.new()
	qr.texture = ImageTexture.create_from_image(QrCode.image(grid, px, 0, UiStyle.INK, Color.WHITE))
	qr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	qr.position = (QR_AT + Vector2.ONE * (QR_SIDE - side) * 0.5).floor()
	qr.size = Vector2(side, side)
	card.add_child(qr)


static func _band(v: float, lo: String, mid: String, hi: String) -> String:
	return lo if v < 0.34 else (hi if v > 0.66 else mid)

func _field(label: String, value: String) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	var l: = Label.new()
	l.text = label
	l.custom_minimum_size.x = 170
	_card_text(l, UiStyle.FONT_XBOLD, 40, Color(UiStyle.INK, 0.55))
	row.add_child(l)
	var v: = Label.new()
	v.text = value
	_card_text(v, UiStyle.FONT_BLACK, 48, UiStyle.INK)
	row.add_child(v)
	return row

func _card_text(l: Label, font: String, size: int, color: Color) -> void :
	l.add_theme_font_override("font", UiStyle.font(font))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)


static func _name_px(text: String) -> int:
	var f: = UiStyle.font(UiStyle.FONT_BLACK)
	var px: = NAME_PX
	while px > NAME_MIN_PX and f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > NAME_W:
		px -= 2
	return px


func _name_rect() -> Rect2:
	return Rect2(COL_AT, _name_l.custom_minimum_size)




func _place_portrait() -> void :
	var base: = Rect2(Vector2(FRAME_INSET, FRAME_INSET), FRAME.size - Vector2(FRAME_INSET, FRAME_INSET) * 2.0)
	var sz: = base.size * zoom
	var reach: = (FRAME.size + sz) * 0.5 - Vector2(40, 40)
	nudge = nudge.clamp( - reach, reach)
	_portrait.size = sz
	_portrait.position = base.get_center() - sz * 0.5 + nudge
	_portrait.pivot_offset = sz * 0.5
	_portrait.rotation = deg_to_rad(tilt)

func set_zoom(z: float) -> void :
	zoom = clampf(z, ZOOM_MIN, ZOOM_MAX)
	_place_portrait()
	if _size != null and absf(_size.value - zoom) > 0.005:
		_size.set_value_no_signal(zoom)

func set_tilt(deg: float) -> void :
	tilt = clampf(deg, - TILT_MAX, TILT_MAX)
	_place_portrait()
	if _tilt != null and absf(_tilt.value - tilt) > 0.05:
		_tilt.set_value_no_signal(tilt)

func set_turn(deg: float) -> void :
	turn = clampf(deg, -180.0, 180.0)
	if _turn != null and absf(_turn.value - turn) > 0.05:
		_turn.set_value_no_signal(turn)
	_render_pose(pose_id())

func set_bg(c: Color) -> void :
	bg = c
	(_frame.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = c

func set_card_name(text: String) -> void :
	_name_l.text = text.substr(0, NAME_MAX)
	_name_l.add_theme_font_size_override("font_size", _name_px(_name_l.text))
	if _name_edit != null:
		_fit_name_edit()
	_place_pencil()




func _place_pencil() -> void :
	if _pencil == null:
		return
	var k: = _show_scale()
	var px: = _name_px(_name_l.text)
	var w: = UiStyle.font(UiStyle.FONT_BLACK).get_string_size(_name_l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	var side: = px * 0.6
	var r: = _name_rect()
	_pencil.size = Vector2(side, side) * k
	_pencil.position = Vector2(r.position.x + w + px * 0.25, r.get_center().y - side * 0.5) * k

func set_outfit(idx: int) -> void :
	if idx == outfit:
		return
	outfit = idx
	_paint_outfit_btns()
	_render_pose(pose_id())






func edit_name() -> void :
	if _name_edit != null:
		return
	_name_edit = LineEdit.new()
	_name_edit.text = _name_l.text
	_name_edit.max_length = NAME_MAX
	_name_edit.flat = true
	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "focus", "read_only"]:
		_name_edit.add_theme_stylebox_override(st, empty)
	_name_edit.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_name_edit.add_theme_color_override("font_color", UiStyle.INK)
	_name_edit.add_theme_color_override("caret_color", UiStyle.INK)
	_name_edit.add_theme_color_override("selection_color", Color(UiStyle.SECONDARY, 0.35))
	_name_edit.add_theme_constant_override("minimum_character_width", 0)
	_name_edit.text_changed.connect(set_card_name)
	_name_edit.text_submitted.connect( func(_t: String): end_name_edit())
	_name_edit.focus_exited.connect(end_name_edit)
	_pic.add_child(_name_edit)
	_fit_name_edit()
	_name_l.modulate.a = 0.0
	_name_edit.grab_focus()
	_name_edit.caret_column = _name_edit.text.length()

func _fit_name_edit() -> void :
	var k: = _pic.size.x / float(CARD.x)
	var r: = _name_rect()
	_name_edit.position = r.position * k
	_name_edit.size = r.size * k
	_name_edit.add_theme_font_size_override("font_size", maxi(int(round(_name_px(_name_l.text) * k)), 8))

func end_name_edit() -> void :
	if _name_edit == null:
		return
	var e: = _name_edit
	_name_edit = null
	_name_l.modulate.a = 1.0
	if is_instance_valid(e):
		e.queue_free()

func editing_name() -> bool:
	return _name_edit != null





func _build_popup() -> void :
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.5)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and not _dragging:
			close())
	add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	center.add_child(v)

	var shown: = Vector2(CARD) * _show_scale()
	_pic = TextureRect.new()
	_pic.texture = _vp.get_texture()
	_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_pic.custom_minimum_size = shown
	_pic.mouse_filter = Control.MOUSE_FILTER_STOP
	_pic.gui_input.connect(_on_pic_input)
	v.add_child(_pic)



	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.custom_minimum_size.x = shown.x
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(body)
	_pencil = TextureRect.new()
	_pencil.texture = load("res://game/character/locker_icons/pencil.png")
	_pencil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pencil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_pencil.modulate = Color(1, 1, 1, 0.6)
	_pencil.mouse_filter = Control.MOUSE_FILTER_STOP
	_pencil.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_pencil.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and (ev as InputEventMouseButton).pressed\
		and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			edit_name()
			_pencil.accept_event())
	_pic.add_child(_pencil)
	_place_pencil()


	var row1: = _flow()
	body.add_child(row1)
	var poses: = HBoxContainer.new()
	poses.add_theme_constant_override("separation", 6)
	row1.add_child(poses)
	poses.add_child(_arrow("left", -1))
	_pose_label = Label.new()
	_pose_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pose_label.custom_minimum_size.x = 120
	_outlined(_pose_label, 20)
	poses.add_child(_pose_label)
	poses.add_child(_arrow("right", 1))
	var outfits: = HBoxContainer.new()
	outfits.add_theme_constant_override("separation", 4)
	row1.add_child(outfits)
	for pair in [[OUTFIT_CAPTAIN, "captain"], [OUTFIT_GYM, "gym"]]:
		var b: = Button.new()
		b.text = pair[1]
		b.set_meta("outfit", pair[0])
		b.pressed.connect(set_outfit.bind(pair[0]))
		outfits.add_child(b)
		_outfit_btns.append(b)
	_paint_outfit_btns()
	var bg_box: = HBoxContainer.new()
	bg_box.add_theme_constant_override("separation", 6)
	row1.add_child(bg_box)
	bg_box.add_child(_word("background"))
	var bg_chip: = UiStyle.color_field(bg, set_bg)
	bg_chip.custom_minimum_size = Vector2(48, 34)
	bg_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER


	for face in bg_chip.get_children():
		if face is Panel:
			var fsb: = (face as Panel).get_theme_stylebox("panel") as StyleBoxFlat
			if fsb != null:
				fsb.set_border_width_all(2)
				fsb.border_color = Color(UiStyle.muted(), 0.6)
	bg_box.add_child(bg_chip)


	var row2: = _flow()
	body.add_child(row2)
	_size = _slider(row2, "size", ZOOM_MIN, ZOOM_MAX, 0.01, zoom, set_zoom)
	_tilt = _slider(row2, "tilt", - TILT_MAX, TILT_MAX, 1.0, tilt, set_tilt)
	_turn = _slider(row2, "rotate", -180.0, 180.0, 1.0, turn, set_turn)
	row2.add_child(UiStyle.reset_button( func():
		nudge = Vector2.ZERO
		set_tilt(0.0)
		set_turn(0.0)
		set_zoom(1.0)))

	var hint: = Label.new()
	hint.text = "move: lmb      resize: scroll"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outlined(hint, 14)
	body.add_child(hint)

	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	body.add_child(row)
	var copy: = Button.new()
	copy.text = "copy code"
	UiStyle.style_button(copy, "secondary", 16)
	copy.pressed.connect(_copy_code)
	row.add_child(copy)
	var save: = Button.new()
	save.text = "save picture"
	UiStyle.style_button(save, "blue", 16)
	save.pressed.connect(_save_picture)
	row.add_child(save)
	var shut: = Button.new()
	shut.text = "close"
	UiStyle.style_button(shut, "secondary", 16)
	shut.pressed.connect(close)
	row.add_child(shut)

	(Engine.get_main_loop() as SceneTree).process_frame.connect( func():
		if is_instance_valid(v):
			UiStyle.pop_in(v), CONNECT_ONE_SHOT)

func _flow() -> HFlowContainer:
	var f: = HFlowContainer.new()
	f.alignment = FlowContainer.ALIGNMENT_CENTER
	f.add_theme_constant_override("h_separation", 14)
	f.add_theme_constant_override("v_separation", 8)
	return f

func _word(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	_outlined(l, 16)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


func _outlined(l: Label, size: int) -> void :
	UiStyle.style_label(l, "title", Color.WHITE)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", UiStyle.INK)
	l.add_theme_constant_override("outline_size", 8)

func _slider(row: Container, label: String, lo: float, hi: float, step: float, 
		value: float, on_change: Callable) -> HSlider:
	var box: = HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	row.add_child(box)
	box.add_child(_word(label))
	var s: = HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(80 if compact else 120, 30)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_slider(s)
	s.value_changed.connect(on_change)
	box.add_child(s)
	return s

func _paint_outfit_btns() -> void :
	for b in _outfit_btns:
		UiStyle.style_button(b, "blue" if int(b.get_meta("outfit")) == outfit else "secondary", 15)

func _arrow(icon_name: String, step: int) -> Button:
	var b: = UiStyle.icon_button(icon_name, "secondary", 38)
	b.pressed.connect( func(): cycle_pose(step))
	return b


func _card_at(local: Vector2) -> Vector2:
	return local * (Vector2(CARD) / _pic.size)

func _on_pic_input(ev: InputEvent) -> void :
	var mb: = ev as InputEventMouseButton
	if mb != null:
		var at: = _card_at(mb.position)
		var over: = FRAME.has_point(at)
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and _name_rect().has_point(at):
				edit_name()
			elif mb.pressed:
				end_name_edit()
			_dragging = mb.pressed and over
		elif mb.pressed and over and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_zoom(zoom * ZOOM_STEP)
		elif mb.pressed and over and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_zoom(zoom / ZOOM_STEP)
		_pic.accept_event()
		return
	var mm: = ev as InputEventMouseMotion
	if mm != null:

		_pic.mouse_default_cursor_shape = Control.CURSOR_IBEAM\
		if _name_rect().has_point(_card_at(mm.position)) else Control.CURSOR_ARROW
		if _dragging:
			nudge += mm.relative * (Vector2(CARD) / _pic.size)
			_place_portrait()
			_pic.accept_event()

func cycle_pose(step: int) -> void :
	var ids: = StudioRender.pose_ids()
	_pose_i = posmod(_pose_i + step, ids.size())
	_pose_changed()

func pose_id() -> String:
	return StudioRender.pose_ids()[_pose_i]

func _pose_changed() -> void :
	var id: = pose_id()
	_pose_label.text = StudioRender.pose_label(id)
	_render_pose(id)



func _render_pose(id: String) -> void :
	if not StudioRender.can_render():
		return
	_gen += 1
	var gen: = _gen
	_rendering = true


	while _render.is_busy():
		await get_tree().process_frame
		if not is_instance_valid(self) or gen != _gen:
			return
	var layer: = StudioLayer.new()
	layer.cfg = look
	layer.outfit = outfit
	layer.pose = id
	layer.frame = StudioRender.pose_frame(id)
	layer.turn = turn + (StudioRender.FLOOR_TURN if StudioRender.FLOOR_POSES.has(id) else 0.0)
	var res: Dictionary = await _render.render(layer, RENDER_PX)
	if not is_instance_valid(self) or gen != _gen:
		return
	_rendering = false
	if res.is_empty():
		return
	var used: Rect2 = res["used"]
	used = used.grow_individual(used.size.x * PAD, used.size.y * PAD, used.size.x * PAD, used.size.y * PAD)
	used = used.intersection(Rect2(0, 0, 1, 1))
	var at: = AtlasTexture.new()
	at.atlas = res["tex"]
	at.region = Rect2(used.position * RENDER_PX, used.size * RENDER_PX)
	_portrait.texture = at





func _copy_code() -> void :
	for _i in 4:
		DisplayServer.clipboard_set(_code)
		if DisplayServer.clipboard_get() == _code:
			UiStyle.flash_pill("code copied", UiStyle.SUCCESS, "checkmark")
			return
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self):
			return
	UiStyle.flash_pill("could not copy the code", UiStyle.RED, "warning")

func _save_picture() -> void :
	var path: = await save_picture()
	if not is_instance_valid(self):
		return
	if path == "":
		UiStyle.flash_pill("could not save the picture", UiStyle.RED, "warning")
		return
	UiStyle.sfx("celebrate")
	UiStyle.flash_pill("saved to %s" % LockerStudio.folder_shown(), UiStyle.SUCCESS, "checkmark")



func save_picture(dir: = "") -> String:
	if _saving or not StudioRender.can_render():
		return ""
	_saving = true
	end_name_edit()

	while _rendering:
		await get_tree().process_frame
		if not is_instance_valid(self):
			return ""
	for _i in 2:
		await RenderingServer.frame_post_draw
		if not is_instance_valid(self):
			return ""
	var img: = _vp.get_texture().get_image()
	_saving = false
	if img == null or img.is_empty():
		return ""
	var folder: = dir if dir != "" else LockerStudio.export_dir()
	DirAccess.make_dir_recursive_absolute(folder)
	var stamp: = Time.get_datetime_string_from_system(false, true).replace(":", "").replace(" ", "_")
	var path: = folder.path_join("jv_card_%s.png" % stamp)
	var n: = 2
	while FileAccess.file_exists(path):
		path = folder.path_join("jv_card_%s_%d.png" % [stamp, n])
		n += 1
	var f: = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_buffer(LookShare.png_with_code(img, _code))
	f.close()
	return path
