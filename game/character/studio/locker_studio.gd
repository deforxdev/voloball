class_name LockerStudio
extends Control





















signal exporting_changed(on: bool)
signal selection_changed


const SHAPES: = [
	["square", [Vector2i(512, 512), Vector2i(1024, 1024), Vector2i(2048, 2048)], 
		["512 x 512", "1024 x 1024", "2048 x 2048"]], 
	["wide", [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)], 
		["1280 x 720", "1920 x 1080", "2560 x 1440"]], 

	["tall", [Vector2i(1080, 1920)], ["phone screen (9:16) 1080 x 1920"]], 
]
const DEFAULT_SHAPE: = 0
const DEFAULT_RES: = 1
const DEFAULT_BG: = Color("ffd23f")





static func available() -> bool:
	return not LaunchGate.is_demo()
const DEFAULT_PATTERN: = "balls"
const BG_SWATCHES: = [Color("ffd23f"), Color("ffffff"), Color("f2f4fb"), 
	Color("8fd3ff"), Color("2e78ff"), Color("ff7ea8"), Color("4ccb7a"), 
	Color("ff8a3d"), Color("232b3b"), Color("141416")]
const TEXT_COLORS: = [Color.WHITE, Color("232b3b"), Color("ffd23f"), Color("2e78ff"), 
	Color("ff7ea8"), Color("4ccb7a"), Color("e5484d")]

const STICKERS: = ["res://game/logo/jvlogo_HD.png", 
	"res://game/images/gameballs/ball_nationals.png", 
	"res://game/images/gameballs/ball_outdoor.png", 
	"res://game/images/gameballs/ball_school.png"]


const SCRAP_DIR: = "res://game/character/studio/stickers/%s.png"
const SCRAP: = ["star_yellow", "star_pink", "star_blue", "heart_red", "heart_pink", 
	"sparkle_yellow", "sparkle_white", "smiley", "flower", "rainbow", "cloud", "lightning", 
	"music_note", "burst_red", "burst_yellow", "speech_bubble", "check", "cross", "pin_pink", 
	"confetti", "tape_mint", "tape_pink", "tape_yellow", "tape_blue", "paperclip", "polaroid"]
const STICKER_PICKS: = 12
const MAX_LAYERS: = 24

var layer_cap: = MAX_LAYERS
const MAX_CHARS: = 8
const HANDLE_R: = 9.0
const HINT_H: = 26.0
const SIZE_LIMITS: = {"char": Vector2(0.15, 3.2), "text": Vector2(0.02, 0.5), 
	"sticker": Vector2(0.04, 2.0), "ball": Vector2(0.05, 2.0), "pattern": Vector2(0.03, 2.0), 
	"box": Vector2(0.01, 0.2), "table": Vector2(0.01, 0.1), "callout": Vector2(0.02, 0.4), 
	"arrow": Vector2(0.03, 2.0), "panel": Vector2(0.02, 2.0)}

const PATTERN_PICKS: = 12

const DEFAULT_FOLDER: = "voloball"
const DEFAULT_FOLDER_SHOWN: = "pictures/voloball"

var host = null
var layers: Array = []

var selection: Array = []
var selected: StudioLayer:
	get:
		return selection[0] if selection.size() == 1 else null
var shape: = DEFAULT_SHAPE
var res_idx: = DEFAULT_RES
var bg: = DEFAULT_BG
var transparent: = false
var pattern: = DEFAULT_PATTERN
var pattern_auto: = true
var pattern_color: = Color.WHITE
var pattern_alpha: = 1.0
var pattern_scale: = 0.38
var last_export: = ""

var _render: StudioRender
var _canvas_vp: SubViewport
var _canvas: StudioCanvas
var _shadow: Panel
var _board: TextureRect
var _view: TextureRect
var _overlay: Control
var _size_label: Label
var _hint: Label
var _empty: Label
var _fr: = Rect2()
var _queue: Array = []
var _rendering: = false
var _exporting: = false
var _active: = false
var _draft: CharacterConfig = null
var _drag: = ""
var _drag_from: = Vector2.ZERO
var _drag_to: = Vector2.ZERO
var _drag_start: = {}
var _edit: = {}
var _pattern_chip: ColorPickerButton = null
var _pattern_match: Button = null
var _show_profiles: = false
var _show_patterns: = false
var _show_stickers: = false
var _folder_dialog: FileDialog = null
var _started: = false

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_CLICK

	clip_contents = true
	_render = StudioRender.new()
	add_child(_render)
	_canvas_vp = SubViewport.new()
	_canvas_vp.disable_3d = true
	_canvas_vp.transparent_bg = true
	_canvas_vp.size = Vector2i(64, 64)
	_canvas_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_canvas_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	add_child(_canvas_vp)
	_canvas = StudioCanvas.new()
	_canvas.layers = layers
	_canvas_vp.add_child(_canvas)
	_shadow = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.shadow_color = Color(0, 0, 0, 0.22)
	sb.shadow_size = 16
	sb.shadow_offset = Vector2(0, 6)
	_shadow.add_theme_stylebox_override("panel", sb)
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shadow)
	_board = TextureRect.new()
	_board.texture = _checker()
	_board.stretch_mode = TextureRect.STRETCH_TILE
	_board.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board)
	_view = TextureRect.new()
	_view.texture = _canvas_vp.get_texture()
	_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_view.stretch_mode = TextureRect.STRETCH_SCALE
	_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_view)
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	_size_label = _small_label()
	_hint = _small_label()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_hint.text = "move: lmb      resize: scroll      snap: ctrl"
	_empty = Label.new()
	_empty.text = "add something from the add tab"
	UiStyle.style_label(_empty, "body", UiStyle.muted())
	_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_empty)
	resized.connect(_sync_canvas)
	visibility_changed.connect( func():
		if not visible:
			_drag = "")

func _small_label() -> Label:
	var l: = Label.new()
	UiStyle.style_label(l, "small", UiStyle.muted())
	l.add_theme_font_size_override("font_size", 14)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l



func set_active(on: bool, draft: CharacterConfig) -> void :
	_active = on
	visible = on
	if not on:
		return
	_draft = draft
	if not _started:
		_started = true
		_start_fresh()
	look_changed(draft)
	_sync_canvas()


func look_changed(draft: CharacterConfig) -> void :
	_draft = draft
	if draft == null:
		return
	for l in layers:
		var layer: = l as StudioLayer
		if layer.from_you:
			layer.cfg = draft.clone()
			_queue_render(layer)

func canvas_size() -> Vector2i:
	var sizes: Array = SHAPES[shape][1]
	return sizes[clampi(res_idx, 0, sizes.size() - 1)]

func is_exporting() -> bool:
	return _exporting

func is_rendering() -> bool:
	return _rendering or not _queue.is_empty() or _render.is_busy()



func _start_fresh() -> void :
	_reset_canvas_settings()
	_reset_background()
	layers.clear()
	selection.clear()
	if _draft != null:
		var me: = add_character(_draft, "you", true, false)
		me.pos = Vector2(0.5, 0.44)
		me.size = 1.12
		me.base_size = 1.12

func _reset_canvas_settings() -> void :
	shape = DEFAULT_SHAPE
	res_idx = DEFAULT_RES

func _reset_background() -> void :
	bg = DEFAULT_BG
	transparent = false
	pattern = DEFAULT_PATTERN
	pattern_auto = true
	pattern_color = Color.WHITE
	pattern_alpha = 1.0
	pattern_scale = 0.38

func _sync_canvas() -> void :
	if not is_inside_tree():
		return
	_layout()
	_push_bg()
	if not _exporting:
		var want: = Vector2i((_fr.size * _px_scale()).round())
		want = Vector2i(maxi(16, want.x), maxi(16, want.y))
		if _canvas_vp.size != want:
			_canvas_vp.size = want
		_canvas.size = Vector2(_canvas_vp.size)
		for l in layers:
			if (l as StudioLayer).is_rendered():
				_queue_render(l)
	var cs: = canvas_size()
	_size_label.text = "%d x %d" % [cs.x, cs.y]
	_empty.visible = layers.is_empty()
	_dirty()



func _px_scale() -> float:
	var w: = get_window()
	if w == null:
		return 1.0
	var vis: = w.get_visible_rect().size
	return clampf(float(w.size.y) / maxf(1.0, vis.y), 0.5, 4.0)

func _layout() -> void :
	var area: = Rect2(Vector2(18, 10), size - Vector2(36, 10 + HINT_H + 8))
	var cs: = Vector2(canvas_size())
	if area.size.x < 8.0 or area.size.y < 8.0:
		return
	var k: = minf(area.size.x / cs.x, area.size.y / cs.y)
	var fs: = (cs * k).floor()
	_fr = Rect2((area.position + (area.size - fs) * 0.5).floor(), fs)
	for c in [_shadow, _board, _view]:
		(c as Control).position = _fr.position
		(c as Control).size = _fr.size
	_size_label.position = Vector2(_fr.position.x, _fr.end.y + 6)
	_size_label.size = Vector2(_fr.size.x * 0.4, HINT_H)
	_hint.position = Vector2(_fr.position.x + _fr.size.x * 0.4, _fr.end.y + 6)
	_hint.size = Vector2(_fr.size.x * 0.6, HINT_H)
	_empty.position = _fr.position
	_empty.size = _fr.size



func _push_bg() -> void :
	_canvas.bg = bg
	_canvas.transparent = transparent
	_canvas.pattern = pattern
	_canvas.pattern_auto = pattern_auto
	_canvas.pattern_color = pattern_color
	_canvas.pattern_alpha = pattern_alpha
	_canvas.pattern_scale = pattern_scale
	_dirty()

	if pattern_auto and _pattern_chip != null and is_instance_valid(_pattern_chip):
		_set_chip(_pattern_chip, Color(_canvas.pattern_tint(), 1.0))



const HOT_FRAMES: = 3
var _hot: = 0

func _dirty() -> void :
	_canvas.sync()
	_canvas_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_hot = HOT_FRAMES
	_overlay.queue_redraw()

func _process(_delta: float) -> void :
	if _hot > 0:
		_hot -= 1
		if _hot == 0:
			_canvas_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED

static func _checker() -> Texture2D:
	var cell: = 12
	var img: = Image.create(cell * 2, cell * 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var dark: = Color(0.84, 0.85, 0.88)
	img.fill_rect(Rect2i(0, 0, cell, cell), dark)
	img.fill_rect(Rect2i(cell, cell, cell, cell), dark)
	return ImageTexture.create_from_image(img)



static func _set_chip(chip: ColorPickerButton, c: Color) -> void :
	chip.color = c
	for child in chip.get_children():
		if child is Panel:
			var sb: = (child as Panel).get_theme_stylebox("panel") as StyleBoxFlat
			if sb != null:
				sb.bg_color = c



func _queue_render(layer: StudioLayer) -> void :
	if layer == null or not layer.is_rendered():
		return
	if not _queue.has(layer):
		_queue.append(layer)
	if not _rendering and not _exporting:
		_drain()

func _drain() -> void :
	_rendering = true
	while not _queue.is_empty() and not _exporting:
		var layer: StudioLayer = _queue.pop_front()
		if not layers.has(layer):
			continue
		var px: = layer.render_px(float(_canvas_vp.size.y))
		var key: = layer.render_key(px)
		if key == layer.tex_key and layer.tex != null:
			continue
		var res: Dictionary = await _render.render(layer, px)
		if not is_instance_valid(self):
			return
		if res.is_empty() or _exporting:
			continue
		layer.tex = res["tex"]
		layer.used = res["used"]
		layer.tex_key = key

		if layer.render_key(layer.render_px(float(_canvas_vp.size.y))) != key and not _queue.has(layer):
			_queue.append(layer)
		_dirty()
	_rendering = false



func _chars() -> int:
	var n: = 0
	for l in layers:
		if (l as StudioLayer).kind == StudioLayer.KIND_CHAR:
			n += 1
	return n

func can_add(kind: String) -> bool:
	if layers.size() >= layer_cap:
		return false
	return kind != StudioLayer.KIND_CHAR or _chars() < MAX_CHARS


func add_character(cfg: CharacterConfig, who: String, from_you: = false, pick: = true) -> StudioLayer:
	if not can_add(StudioLayer.KIND_CHAR):
		return null
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_CHAR
	l.who = who
	l.from_you = from_you
	l.cfg = cfg.clone() if cfg != null else CharacterConfig.new()
	var n: = _chars()
	var cs: = Vector2(canvas_size())
	var aspect: = cs.x / cs.y
	l.size = 0.95 if aspect > 1.2 else 0.85
	l.base_size = l.size


	var step: = 0.34 * l.size / aspect
	var side: = 1.0 if n % 2 == 1 else -1.0
	l.pos = Vector2(clampf(0.5 + side * ceilf(n / 2.0) * step, 0.1, 0.9), 0.48)
	layers.append(l)
	if pick:
		select(l)
	_queue_render(l)
	_sync_canvas()
	return l

func add_text(text_in: = "nice!") -> StudioLayer:
	if not can_add(StudioLayer.KIND_TEXT):
		return null
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_TEXT
	l.text = text_in
	l.size = 0.12
	l.base_size = l.size
	l.pos = Vector2(0.5, 0.14)
	layers.append(l)
	select(l)
	_sync_canvas()
	return l

func add_sticker(path: String) -> StudioLayer:
	if not can_add(StudioLayer.KIND_STICKER) or not (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
		return null
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_STICKER
	l.sticker = path
	l.size = 0.22 if path.contains("logo") else 0.18
	l.base_size = l.size

	l.pos = Vector2(0.84, 0.88) if path.contains("logo") else Vector2(0.78, 0.22)
	layers.append(l)
	select(l)
	_sync_canvas()
	return l


func add_ball(skin: = "nationals") -> StudioLayer:
	if not can_add(StudioLayer.KIND_BALL):
		return null
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_BALL
	l.ball = skin
	l.size = 0.2
	l.base_size = l.size
	l.pos = Vector2(0.76, 0.24)
	l.used = Rect2(0.05, 0.05, 0.9, 0.9)
	return _add(l)


func add_pattern(id: = "k01") -> StudioLayer:
	if not can_add(StudioLayer.KIND_PATTERN):
		return null
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_PATTERN
	l.pattern = id
	l.color = Color(1, 1, 1, 0.85)
	l.size = 0.4
	l.base_size = l.size
	l.h = 0.4
	l.w = 0.4
	l.pos = Vector2(0.5, 0.5)
	return _add(l)

func _add(l: StudioLayer) -> StudioLayer:
	layers.append(l)
	select(l)
	_queue_render(l)
	_sync_canvas()
	return l

func remove_layers(ls: Array) -> void :
	for l in ls.duplicate():
		layers.erase(l)
		_queue.erase(l)
	select_many(selection.filter( func(s): return layers.has(s)))
	_sync_canvas()

func remove_layer(l: StudioLayer) -> void :
	remove_layers([l])

func duplicate_layers(ls: Array) -> void :
	var copies: Array = []
	for l in _in_order(ls):
		if not can_add((l as StudioLayer).kind):
			break
		var copy: = (l as StudioLayer).duplicate_layer()
		layers.insert(layers.find(l) + 1, copy)
		copies.append(copy)
		_queue_render(copy)
	if not copies.is_empty():
		select_many(copies)
	_sync_canvas()

func duplicate_layer(l: StudioLayer) -> void :
	duplicate_layers([l])


func _in_order(ls: Array) -> Array:
	return layers.filter( func(x): return ls.has(x))


func move_layer(l: StudioLayer, dir: int) -> void :
	var i: = layers.find(l)
	var j: = clampi(i + dir, 0, layers.size() - 1)
	if i < 0 or i == j:
		return
	layers.remove_at(i)
	layers.insert(j, l)
	_dirty()


func place_layer(l: StudioLayer, to: int) -> void :
	var i: = layers.find(l)
	if i < 0:
		return
	layers.remove_at(i)
	layers.insert(clampi(to, 0, layers.size()), l)
	_dirty()

func select(l: StudioLayer) -> void :
	select_many([] if l == null else [l])

func select_many(ls: Array) -> void :
	if ls == selection:
		return
	selection = ls.duplicate()
	_overlay.queue_redraw()
	selection_changed.emit()

func toggle_select(l: StudioLayer) -> void :
	var next: = selection.duplicate()
	if next.has(l):
		next.erase(l)
	else:
		next.append(l)
	select_many(next)

func clear_canvas() -> void :
	layers.clear()
	_queue.clear()
	select(null)
	_sync_canvas()

func _layer_changed(l: StudioLayer, rerender: = false) -> void :
	if rerender:
		_queue_render(l)
	_dirty()



func _hit(p: Vector2, cs: Vector2) -> StudioLayer:
	for i in range(layers.size() - 1, -1, -1):
		var l: StudioLayer = layers[i]
		if l.contains(p, cs):
			return l
	return null


func _sel_rect(cs: Vector2) -> Rect2:
	var r: = Rect2()
	var first: = true
	for l in selection:
		for c in (l as StudioLayer).corners(cs):
			if first:
				r = Rect2(c, Vector2.ZERO)
				first = false
			else:
				r = r.expand(c)
	return r




func _handles(cs: Vector2) -> Dictionary:
	if selection.size() == 1:
		var c: = (selection[0] as StudioLayer).corners(cs)
		var top: = (c[0] + c[1]) * 0.5
		var up: = (c[0] - c[3]).normalized()
		if up == Vector2.ZERO:
			up = Vector2.UP
		return {"scale": c[2], "rotate": top + up * 26.0, "top": top, 
			"center": (selection[0] as StudioLayer).pos * cs}
	var r: = _sel_rect(cs)
	var t: = Vector2(r.get_center().x, r.position.y)
	return {"scale": r.end, "rotate": t + Vector2.UP * 26.0, "top": t, "center": r.get_center()}

func _gui_input(event: InputEvent) -> void :
	if not _active or _exporting:
		return
	var cs: = _fr.size
	if event is InputEventMouseButton:
		var mb: = event as InputEventMouseButton
		var p: = mb.position - _fr.position
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				grab_focus()
				_begin_drag(p, cs, mb.shift_pressed)
			else:
				_end_drag(cs, mb.shift_pressed)
			accept_event()
		elif mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var f: = 1.07 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.07
			var over: = _hit(p, cs)
			if over != null and not selection.has(over):
				select(over)
			if not selection.is_empty():
				_scale_selection(f, cs)
			accept_event()
	elif event is InputEventMouseMotion and _drag != "":
		_drag_to_point((event as InputEventMouseMotion).position - _fr.position, cs, 
			(event as InputEventMouseMotion).shift_pressed, (event as InputEventMouseMotion).ctrl_pressed)
		accept_event()

func _begin_drag(p: Vector2, cs: Vector2, adding: bool) -> void :
	_drag = ""
	if not selection.is_empty() and not adding:
		var h: = _handles(cs)
		if p.distance_to(h["rotate"]) <= HANDLE_R * 1.6:
			_drag = "rotate"
		elif p.distance_to(h["scale"]) <= HANDLE_R * 1.6:
			_drag = "scale"
	if _drag == "":
		var hit: = _hit(p, cs)
		if hit == null:

			_drag = "box"
			_drag_from = p
			_drag_to = p
			if not adding:
				select(null)
			return
		if adding:
			toggle_select(hit)
		elif not selection.has(hit):
			select(hit)
		_drag = "move" if selection.has(hit) else ""
	_drag_from = p
	_drag_start = {"center": _handles(cs)["center"] if not selection.is_empty() else p}
	for l in selection:
		var layer: = l as StudioLayer
		_drag_start[layer] = [layer.pos * cs, layer.size, layer.rot, layer.w, layer.h]

func _drag_to_point(p: Vector2, cs: Vector2, shift: bool, ctrl: = false) -> void :
	_snap_lines.clear()
	if _drag == "box":
		_drag_to = p
		_overlay.queue_redraw()
		return
	if selection.is_empty():
		return
	var c: Vector2 = _drag_start["center"]
	match _drag:
		"move":
			for l in selection:
				var st: Array = _drag_start.get(l, [])
				if st.is_empty():
					continue
				var np: Vector2 = (st[0] + (p - _drag_from)) / cs
				(l as StudioLayer).pos = Vector2(clampf(np.x, -0.2, 1.2), clampf(np.y, -0.2, 1.2))
			if ctrl:
				_snap_selection(cs)
		"scale":
			var f: = p.distance_to(c) / maxf(4.0, _drag_from.distance_to(c))
			for l in selection:
				var st: Array = _drag_start.get(l, [])
				if st.is_empty():
					continue
				var layer: = l as StudioLayer
				_set_layer_size(layer, float(st[1]) * f, st)

				if selection.size() > 1:
					layer.pos = (c + (st[0] - c) * f) / cs
		"rotate":
			var a: = (p - c).angle() - (_drag_from - c).angle()
			if shift:
				a = snappedf(a, deg_to_rad(15.0))
			for l in selection:
				var st: Array = _drag_start.get(l, [])
				if st.is_empty():
					continue
				var layer: = l as StudioLayer
				var r: = wrapf(float(st[2]) + a, - PI, PI)
				if not shift and selection.size() == 1 and absf(r) < deg_to_rad(4.0):
					r = 0.0
				layer.rot = r
				if selection.size() > 1:
					layer.pos = (c + (st[0] - c).rotated(a)) / cs
	_dirty()

func _end_drag(cs: Vector2, adding: bool) -> void :
	_snap_lines.clear()
	if _drag == "box":
		var box: = Rect2(_drag_from, Vector2.ZERO).expand(_drag_to)
		_drag = ""
		if box.size.length() > 6.0:
			var picked: Array = selection.duplicate() if adding else []
			for l in layers:
				var layer: = l as StudioLayer
				var lr: = Rect2(layer.corners(cs)[0], Vector2.ZERO)
				for corner in layer.corners(cs):
					lr = lr.expand(corner)
				if box.intersects(lr) and not picked.has(layer):
					picked.append(layer)
			select_many(picked)
		_overlay.queue_redraw()
		return
	if _drag == "scale" or (_drag == "rotate" and selection.size() > 1):
		for l in selection:
			_queue_render(l)
	if _drag != "":
		_refresh_edit()
	_drag = ""

func _scale_selection(f: float, cs: Vector2) -> void :
	var c: Vector2 = _handles(cs)["center"]
	for l in selection:
		var layer: = l as StudioLayer
		var before: = layer.size
		_set_layer_size(layer, layer.size * f)
		if selection.size() > 1 and before > 0.0:
			var k: = layer.size / before
			layer.pos = (c + (layer.pos * cs - c) * k) / cs
		_queue_render(layer)
	_dirty()
	_refresh_edit()



func _set_layer_size(l: StudioLayer, v: float, from: Array = []) -> void :
	var lim: Vector2 = SIZE_LIMITS.get(l.kind, Vector2(0.05, 2.0))
	var before: = l.size
	l.size = clampf(v, lim.x, lim.y)
	if not l.is_boxed():
		return
	if from.size() >= 5 and float(from[1]) > 0.0:
		var k: = l.size / float(from[1])
		l.w = float(from[3]) * k
		l.h = float(from[4]) * k
	elif before > 0.0:
		l.w *= l.size / before
		l.h *= l.size / before

func _unhandled_key_input(event: InputEvent) -> void :
	if not _active or not visible or not (event is InputEventKey):
		return
	var k: = event as InputEventKey
	if not k.pressed or k.echo:
		return
	var focus: = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return
	if (k.keycode == KEY_DELETE or k.keycode == KEY_BACKSPACE) and not selection.is_empty():
		remove_layers(selection)
		get_viewport().set_input_as_handled()
	elif k.keycode == KEY_D and k.ctrl_pressed and not selection.is_empty():
		duplicate_layers(selection)
		get_viewport().set_input_as_handled()
	elif k.keycode == KEY_A and k.ctrl_pressed:
		select_many(layers)
		get_viewport().set_input_as_handled()



const SNAP_PX: = 9.0
var _snap_lines: Array = []




func align_area(_at: Vector2) -> Rect2:
	return Rect2(0.04, 0.04, 0.92, 0.92)



func snap_targets(at: Vector2) -> Dictionary:
	var a: = align_area(at)
	var xs: Array = [a.position.x, a.get_center().x, a.end.x]
	var ys: Array = [a.position.y, a.get_center().y, a.end.y]
	for l in layers:
		if selection.has(l):
			continue
		var b: = (l as StudioLayer).bounds(_fr.size)
		b = Rect2(b.position / _fr.size, b.size / _fr.size)
		xs.append_array([b.position.x, b.get_center().x, b.end.x])
		ys.append_array([b.position.y, b.get_center().y, b.end.y])
	return {"x": xs, "y": ys}

func _group_bounds(cs: Vector2) -> Rect2:
	var r: = _sel_rect(cs)
	return Rect2(r.position / cs, r.size / cs)

func _snap_selection(cs: Vector2) -> void :
	var g: = _group_bounds(cs)
	var t: = snap_targets(g.get_center())
	var best: = Vector2(INF, INF)
	var line: = Vector2(INF, INF)
	for x in t["x"]:
		for edge in [g.position.x, g.get_center().x, g.end.x]:
			var d: = float(x) - float(edge)
			if absf(d) * cs.x <= SNAP_PX and absf(d) < absf(best.x):
				best.x = d
				line.x = x
	for y in t["y"]:
		for edge in [g.position.y, g.get_center().y, g.end.y]:
			var d: = float(y) - float(edge)
			if absf(d) * cs.y <= SNAP_PX and absf(d) < absf(best.y):
				best.y = d
				line.y = y
	var shift: = Vector2(best.x if best.x != INF else 0.0, best.y if best.y != INF else 0.0)
	if shift != Vector2.ZERO:
		for l in selection:
			(l as StudioLayer).pos += shift
	if line.x != INF:
		_snap_lines.append([line.x, true])
	if line.y != INF:
		_snap_lines.append([line.y, false])



func align_selection(ax: int, ay: int) -> void :
	if selection.is_empty():
		return
	var cs: = _fr.size
	var g: = _group_bounds(cs)
	var a: = align_area(g.get_center())
	var shift: = Vector2.ZERO
	match ax:
		0: shift.x = a.position.x - g.position.x
		1: shift.x = a.get_center().x - g.get_center().x
		2: shift.x = a.end.x - g.end.x
	match ay:
		0: shift.y = a.position.y - g.position.y
		1: shift.y = a.get_center().y - g.get_center().y
		2: shift.y = a.end.y - g.end.y
	for l in selection:
		(l as StudioLayer).pos += shift
	_dirty()

const ALIGN_NAMES: = [["top left", "top", "top right"], ["left", "middle", "right"], 
	["bottom left", "bottom", "bottom right"]]

func _align_grid(box: VBoxContainer) -> void :
	var grid: = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	for ay in 3:
		for ax in 3:
			var x: = ax
			var y: = ay
			var b: = _small_btn(ALIGN_NAMES[ay][ax], "secondary", func(): align_selection(x, y))
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(b)
	box.add_child(grid)
	_note(box, "snap while dragging: hold ctrl")

func _draw_overlay() -> void :
	if not _active or _exporting:
		return
	var cs: = _fr.size
	if _drag == "box":
		var box: = Rect2(_drag_from, Vector2.ZERO).expand(_drag_to)
		box.position += _fr.position
		_overlay.draw_rect(box, Color(UiStyle.SECONDARY, 0.12))
		_overlay.draw_rect(box, Color(UiStyle.INK, 0.85), false, 3.0)
		_overlay.draw_rect(box, Color.WHITE, false, 1.5)
	if selection.is_empty():
		return
	for l in selection:
		var ring: = PackedVector2Array()
		for p in (l as StudioLayer).corners(cs):
			ring.append(p + _fr.position)
		ring.append(ring[0])

		_overlay.draw_polyline(ring, Color(UiStyle.INK, 0.85), 4.0, true)
		_overlay.draw_polyline(ring, Color.WHITE, 2.0, true)
	if selection.size() > 1:
		var r: = _sel_rect(cs)
		r.position += _fr.position
		_overlay.draw_rect(r, Color(UiStyle.INK, 0.6), false, 2.0)
	for sl in _snap_lines:
		if bool(sl[1]):
			var x: float = _fr.position.x + float(sl[0]) * cs.x
			_overlay.draw_line(Vector2(x, _fr.position.y), Vector2(x, _fr.end.y), Color(UiStyle.RED, 0.8), 1.5)
		else:
			var y: float = _fr.position.y + float(sl[0]) * cs.y
			_overlay.draw_line(Vector2(_fr.position.x, y), Vector2(_fr.end.x, y), Color(UiStyle.RED, 0.8), 1.5)
	var h: = _handles(cs)
	var top: Vector2 = h["top"] + _fr.position
	var rot_at: Vector2 = h["rotate"] + _fr.position
	_overlay.draw_line(top, rot_at, Color(UiStyle.INK, 0.85), 3.0, true)
	for at in [h["scale"] + _fr.position, rot_at]:
		_overlay.draw_circle(at, HANDLE_R + 2.0, UiStyle.INK)
		_overlay.draw_circle(at, HANDLE_R, Color.WHITE)



static func default_dir() -> String:
	var pics: = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	if pics == "":
		return ProjectSettings.globalize_path("user://studio")
	return pics.path_join(DEFAULT_FOLDER)


static func export_dir() -> String:
	var picked: = GameConfig.studio_dir
	if picked != "" and DirAccess.dir_exists_absolute(picked):
		return picked
	return default_dir()


static func folder_shown() -> String:
	var dir: = export_dir()
	if dir == default_dir():
		return DEFAULT_FOLDER_SHOWN
	return dir.replace("\\", "/")



func export_image(dir: = "") -> String:
	if _exporting or not StudioRender.can_render():
		return ""
	_exporting = true
	_drag = ""
	exporting_changed.emit(true)
	_overlay.queue_redraw()

	while _rendering or _render.is_busy():
		await get_tree().process_frame
		if not is_instance_valid(self):
			return ""
	var out: = canvas_size()
	var keep: = {}
	for l in layers:
		var layer: = l as StudioLayer
		if not layer.is_rendered():
			continue
		keep[layer] = [layer.tex, layer.tex_key, layer.used]
		var res: Dictionary = await _render.render(layer, layer.render_px(float(out.y)))
		if not is_instance_valid(self):
			return ""
		if not res.is_empty():
			layer.tex = res["tex"]
	_canvas_vp.size = out
	_canvas.size = Vector2(out)
	_dirty()
	for _i in HOT_FRAMES:
		await RenderingServer.frame_post_draw
		if not is_instance_valid(self):
			return ""
	var img: = _canvas_vp.get_texture().get_image()
	for layer in keep:
		var k: Array = keep[layer]
		(layer as StudioLayer).tex = k[0]
		(layer as StudioLayer).tex_key = k[1]
		(layer as StudioLayer).used = k[2]
	_exporting = false
	exporting_changed.emit(false)
	_sync_canvas()
	if img == null or img.is_empty():
		return ""
	var folder: = dir if dir != "" else export_dir()
	DirAccess.make_dir_recursive_absolute(folder)
	var stamp: = Time.get_datetime_string_from_system(false, true).replace(":", "").replace(" ", "_")
	var path: = folder.path_join("jv_studio_%s.png" % stamp)
	var n: = 2
	while FileAccess.file_exists(path):
		path = folder.path_join("jv_studio_%s_%d.png" % [stamp, n])
		n += 1
	if img.save_png(path) != OK:
		return ""
	last_export = path
	return path




func build_panel(sub: String, box: VBoxContainer) -> void :
	_edit.clear()
	_pattern_chip = null
	_pattern_match = null
	match sub:
		"background":
			_panel_background(box)
		"add":
			_panel_add(box)
		"layers":
			_panel_layers(box)
		"edit":
			_panel_edit(box)
		"options":
			_panel_options(box)
		_:
			_panel_canvas(box)

func _rebuild() -> void :
	if host != null:
		host._rebuild_content()
		host._studio_folder_changed()

func _goto(sub: String) -> void :
	if host != null:
		host._studio_goto(sub)



func _header(text: String, on_reset: = Callable()) -> Control:
	var h: Control = host._group_header(text)
	if not on_reset.is_valid():
		return h
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(h)
	var r: = UiStyle.reset_button( func():
		on_reset.call()
		_rebuild())
	r.tooltip_text = "reset"
	r.size_flags_vertical = Control.SIZE_SHRINK_END
	row.add_child(r)
	return row

func _note(box: VBoxContainer, text: String) -> Label:
	var l: = Label.new()
	l.text = text
	UiStyle.style_label(l, "small", UiStyle.muted())
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)
	return l

func _small_btn(text: String, kind: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.text = text
	UiStyle.style_button(b, kind, 13)
	b.pressed.connect(on_press)
	return b

func _panel_canvas(box: VBoxContainer) -> void :
	box.add_child(_header("shape", func():
		_reset_canvas_settings()
		_sync_canvas()))
	var names: Array = []
	for s in SHAPES:
		names.append(s[0])
	box.add_child(host._choice_grid(names, shape, func(i: int):
		shape = i
		res_idx = mini(DEFAULT_RES, (SHAPES[i][1] as Array).size() - 1)
		_sync_canvas()
		_rebuild()))
	box.add_child(host._group_header("resolution"))
	box.add_child(host._choice_grid(SHAPES[shape][2], res_idx, func(i: int):
		res_idx = i
		_sync_canvas()))
	_note(box, "pictures save to %s" % folder_shown())



func _wheel(color: Color, on_change: Callable) -> ColorPicker:
	var cp: = ColorPicker.new()
	cp.color = color
	cp.edit_alpha = false
	cp.picker_shape = ColorPicker.SHAPE_HSV_WHEEL
	cp.sampler_visible = false
	cp.color_modes_visible = false
	cp.sliders_visible = false
	cp.presets_visible = false
	cp.hex_visible = true
	cp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var last: = [0]
	cp.color_changed.connect( func(c: Color):
		var now: = Time.get_ticks_msec()
		if now - last[0] > 45:
			last[0] = now
			UiStyle.sfx("scrub")
		on_change.call(c))
	var dress: = func():
		for node in UiStyle._under(cp):
			if node is LineEdit:
				UiStyle.style_line_edit(node)
			elif node is Label:
				(node as Label).add_theme_color_override("font_color", UiStyle.text())
			elif node is Button:
				UiStyle.style_button(node, "secondary", 14)
	dress.call()
	dress.call_deferred()
	return cp

func _panel_background(box: VBoxContainer) -> void :
	box.add_child(_header("color", func():
		_reset_background()
		_push_bg()))
	var clear_bg: CheckBox = host._toggle_row("transparent", transparent, func(on: bool):
		transparent = on
		_push_bg())
	box.add_child(clear_bg)
	var opaque: = func():
		if transparent:
			transparent = false
			UiStyle.set_check(clear_bg, false)


	var wheel: = _wheel(bg, func(c: Color):
		bg = c
		opaque.call()
		_push_bg())
	box.add_child(host._swatch_grid(BG_SWATCHES, BG_SWATCHES.find(bg), func(i: int):
		bg = BG_SWATCHES[i]
		opaque.call()
		wheel.color = bg
		_push_bg(), Vector2(34, 34)))
	box.add_child(wheel)

	box.add_child(host._group_header("pattern"))
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	box.add_child(grid)
	var btns: = {}
	var repaint: = func(sel: String):
		for id in btns:
			host._paint_thumb_btn(btns[id], id == sel)
	for id in StudioCanvas.pattern_ids():
		var pid: String = id
		var b: = Button.new()
		b.focus_mode = Control.FOCUS_NONE
		var thumb: = "res://game/character/studio/patterns/thumbs/pattern_%s.png" % pid.substr(1)
		if pid.begins_with("k") and ResourceLoader.exists(thumb):
			b.custom_minimum_size = Vector2(46, 46)
			b.icon = load(thumb) as Texture2D
			b.expand_icon = true
			b.tooltip_text = "pattern %d" % int(pid.substr(1))
			for st in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
				b.add_theme_color_override("icon_%s_color" % st, UiStyle.text())
		else:
			b.text = pid
			b.custom_minimum_size = Vector2(0, 46)
			b.add_theme_font_size_override("font_size", 13)
			for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
				b.add_theme_color_override(st, UiStyle.text())
		b.pressed.connect( func():
			pattern = pid
			repaint.call(pid)
			UiStyle.sfx("press")
			_push_bg())
		grid.add_child(b)
		btns[pid] = b
	repaint.call(pattern)

	box.add_child(_header("pattern color", func():
		pattern_auto = true
		pattern_alpha = 1.0
		pattern_scale = 0.38
		_push_bg()))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)



	_pattern_chip = host._color_field(Color(_canvas.pattern_tint(), 1.0), func(c: Color):
		pattern_color = c
		pattern_auto = false
		if _pattern_match != null and is_instance_valid(_pattern_match):
			_pattern_match.disabled = false
		_push_bg())
	row.add_child(_pattern_chip)
	_pattern_match = _small_btn("match background", "secondary", func():
		pattern_auto = true
		_pattern_match.disabled = true
		_push_bg())
	_pattern_match.disabled = pattern_auto
	row.add_child(_pattern_match)
	row.add_child(_small_btn("swap", "secondary", func():
		var was_bg: = bg
		bg = Color(_canvas.pattern_tint(), 1.0)
		pattern_color = was_bg
		pattern_auto = false
		transparent = false
		_push_bg()
		_rebuild()))
	box.add_child(row)
	box.add_child(_slider("size", pattern_scale, 0.38, func(v: float):
		pattern_scale = v
		_push_bg()))
	box.add_child(_slider("strength", pattern_alpha, 1.0, func(v: float):
		pattern_alpha = maxf(v, 0.05)
		_push_bg()))

func _tile(label: String, tip: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.custom_minimum_size = Vector2(74, 74)
	b.expand_icon = true
	b.text = label
	b.tooltip_text = tip
	b.add_theme_font_size_override("font_size", 14)
	b.add_theme_color_override("font_color", UiStyle.text())
	b.add_theme_color_override("font_hover_color", UiStyle.text())
	host._paint_thumb_btn(b, false)
	b.pressed.connect(on_press)
	UiStyle.press_bounce(b)
	b.mouse_entered.connect( func(): UiStyle.sfx("hover"))
	return b

func _face_on(b: Button, cfg: CharacterConfig) -> void :
	var tex: ImageTexture = await CharacterPortrait.head_cached(cfg.to_dict(), self)
	if tex != null and is_instance_valid(b):
		b.icon = tex
		b.text = ""

func _flow() -> HFlowContainer:
	var f: = HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	return f


func _look_tiles(into: HFlowContainer, looks: Array, full: bool) -> void :
	for entry in looks:
		var cfg: CharacterConfig = entry[0]
		var who: String = entry[1]
		var t: = _tile("", who, func(): add_character(cfg, who))
		t.disabled = full
		into.add_child(t)
		_face_on(t, cfg)



func _change_look(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("look"))
	var flow: = _flow()
	box.add_child(flow)
	var looks: Array = []
	if _draft != null:
		looks.append([_draft, "you", true])
	var slots: Array = host._slots if host != null else []
	for i in slots.size():
		if slots[i] != null:
			looks.append([slots[i], "slot %d" % (i + 1), false])
	for p in ProfileStore.profiles:
		if p != ProfileStore.active():
			for e in _profile_looks(p):
				looks.append([e[0], e[1], false])
	for e in looks:
		var cfg: CharacterConfig = e[0]
		var who: String = e[1]
		var mine: bool = e[2]
		var t: = _tile("", who, func():
			l.cfg = cfg.clone()
			l.who = who
			l.from_you = mine and not book_mode
			_layer_changed(l, true))
		t.custom_minimum_size = Vector2(60, 60)
		flow.add_child(t)
		_face_on(t, cfg)
	var rand: = _tile("", "a random player", func():
		l.cfg = CharacterConfig.random(null, true)
		l.who = "random"
		l.from_you = false
		_layer_changed(l, true))
	rand.icon = UiStyle.icon("question")
	rand.custom_minimum_size = Vector2(60, 60)
	flow.add_child(rand)


static func _profile_looks(p: SavedProfile) -> Array:
	var out: Array = []
	if p.character is Dictionary and not (p.character as Dictionary).is_empty():
		out.append([CharacterConfig.from_dict(p.character), p.name])
	for i in p.character_slots.size():
		var d: Variant = p.character_slots[i]
		if d is Dictionary and not (d as Dictionary).is_empty():
			out.append([CharacterConfig.from_dict(d), "%s slot %d" % [p.name, i + 1]])
	return out

func _panel_add(box: VBoxContainer) -> void :
	var full: = not can_add(StudioLayer.KIND_CHAR)
	box.add_child(host._group_header("characters"))
	var who: = _flow()
	box.add_child(who)
	if _draft != null:
		var you: = _tile("you", "you, as you look right now", func():
			add_character(_draft, "you", true))
		you.disabled = full
		who.add_child(you)
		_face_on(you, _draft)
	var mine: Array = []
	var slots: Array = host._slots if host != null else []
	for i in slots.size():
		if slots[i] != null:
			mine.append([slots[i], "slot %d" % (i + 1)])
	_look_tiles(who, mine, full)
	var rand: = _tile("", "a random player", func():
		add_character(CharacterConfig.random(null, true), "random"))
	rand.icon = UiStyle.icon("question")
	rand.disabled = full
	who.add_child(rand)
	if full:
		_note(box, "that's as many characters as one picture can hold")


	var others: Array = []
	for p in ProfileStore.profiles:
		if p != ProfileStore.active():
			others.append(p)
	if not others.is_empty():
		box.add_child(_small_btn("hide other profiles" if _show_profiles else "show other profiles", 
			"secondary", func():
				_show_profiles = not _show_profiles
				_rebuild()))
		if _show_profiles:
			for p in others:
				box.add_child(host._group_header((p as SavedProfile).name))
				var f: = _flow()
				box.add_child(f)
				_look_tiles(f, _profile_looks(p), full)
	box.add_child(host._group_header("text"))
	var add_t: = _small_btn("add text", "secondary", func(): add_text())
	add_t.custom_minimum_size = Vector2(0, 38)
	add_t.disabled = not can_add(StudioLayer.KIND_TEXT)
	box.add_child(add_t)
	box.add_child(host._group_header("stickers"))
	var st: = _flow()
	box.add_child(st)
	var all: Array = STICKERS.duplicate()
	for n in SCRAP:
		all.append(SCRAP_DIR % n)
	var shown: = all if _show_stickers else all.slice(0, STICKERS.size() + STICKER_PICKS)
	for path in shown:
		if not ResourceLoader.exists(path):
			continue
		var p: String = path
		var b: = _tile("", "", func(): add_sticker(p))
		b.icon = load(p) as Texture2D
		b.custom_minimum_size = Vector2(110, 74) if p.contains("logo") or p.contains("tape") else Vector2(74, 74)
		b.disabled = not can_add(StudioLayer.KIND_STICKER)
		st.add_child(b)
	box.add_child(_small_btn("fewer stickers" if _show_stickers else "more stickers", "secondary", func():
		_show_stickers = not _show_stickers
		_rebuild()))
	_add_balls_and_patterns(box)


func _add_balls_and_patterns(box: VBoxContainer) -> void :
	box.add_child(host._group_header("balls"))
	var balls: = _flow()
	box.add_child(balls)
	for b in ball_skins():
		var skin: = String(b[0])
		var t: = _tile(String(b[1]) if not BALL_ICONS.has(skin) else "", String(b[1]), func(): add_ball(skin))
		if BALL_ICONS.has(skin) and ResourceLoader.exists(BALL_ICONS[skin]):
			t.icon = load(BALL_ICONS[skin]) as Texture2D
		t.disabled = not can_add(StudioLayer.KIND_BALL)
		balls.add_child(t)
	box.add_child(host._group_header("patterns"))
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	box.add_child(grid)
	var ids: = StudioCanvas.tile_ids()
	var shown: = ids if _show_patterns else ids.slice(0, PATTERN_PICKS)
	for id in shown:
		var pid: String = id
		var b: = _pattern_btn(pid, func(): add_pattern(pid))
		host._paint_thumb_btn(b, false)
		b.disabled = not can_add(StudioLayer.KIND_PATTERN)
		grid.add_child(b)
	if ids.size() > PATTERN_PICKS:
		box.add_child(_small_btn("fewer patterns" if _show_patterns else "more patterns", "secondary", func():
			_show_patterns = not _show_patterns
			_rebuild()))


func confirm_clear() -> void :
	UiStyle.confirm(host, "clear the canvas?", "everything on it will be removed", 
		func():
			clear_canvas()
			_rebuild(), "clear", "cancel", "danger", 0.0)





func _slider(text: String, v: float, default: Variant, on_change: Callable, key: = "") -> HBoxContainer:
	var row: HBoxContainer = host._slider_row(text, clampf(v, 0.0, 1.0), on_change)
	var s: = row.get_child(1) as Range
	var r: = UiStyle.reset_button( func():
		var d: float = float((default as Callable).call()) if default is Callable else float(default)
		s.set_value_no_signal(d)
		on_change.call(d))
	r.tooltip_text = "reset"
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(r)
	if key != "":
		_edit[key] = s
	return row

func _norm_size(l: StudioLayer) -> float:
	var lim: Vector2 = SIZE_LIMITS.get(l.kind, Vector2(0.05, 2.0))
	return inverse_lerp(lim.x, lim.y, l.size)


func _refresh_edit() -> void :
	var l: = selected
	if l == null:
		return
	if _edit.has("size") and is_instance_valid(_edit["size"]):
		(_edit["size"] as Range).set_value_no_signal(_norm_size(l))
	if _edit.has("tilt") and is_instance_valid(_edit["tilt"]):
		(_edit["tilt"] as Range).set_value_no_signal(rad_to_deg(l.rot) / 90.0 + 0.5)



func _panel_layers(box: VBoxContainer) -> void :
	if layers.is_empty():
		_note(box, "add something from the add tab")
		return
	box.add_child(host._group_header("layers"))
	_note(box, "move layers: drag\nmulti select: shift click")
	for i in range(layers.size() - 1, -1, -1):
		box.add_child(_layer_row(layers[i]))
	var acts: = HFlowContainer.new()
	acts.add_theme_constant_override("h_separation", 6)
	acts.add_theme_constant_override("v_separation", 6)
	box.add_child(acts)
	acts.add_child(_small_btn("select all", "secondary", func(): select_many(layers)))

func _layer_row(l: StudioLayer) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var grip: = TextureRect.new()
	grip.texture = UiStyle.icon("menuList")
	grip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	grip.custom_minimum_size = Vector2(22, 34)
	grip.modulate = Color(1, 1, 1, 0.55)
	grip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(grip)
	var b: = Button.new()
	b.text = l.label()
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	b.custom_minimum_size = Vector2(0, 36)
	UiStyle.style_button(b, "primary" if selection.has(l) else "secondary", 14)
	b.gui_input.connect( func(e: InputEvent):


		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed\
		and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			b.set_meta("adding", (e as InputEventMouseButton).shift_pressed\
			or (e as InputEventMouseButton).ctrl_pressed))

	b.pressed.connect( func():
		if bool(b.get_meta("adding", false)):
			toggle_select(l)
		else:
			select(l))

	b.set_drag_forwarding( func(_at: Vector2) -> Variant:
		var ghost: = Label.new()
		ghost.text = l.label()
		UiStyle.style_label(ghost, "body", UiStyle.text())
		var card: = PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiStyle.card_box())
		card.add_child(ghost)
		b.set_drag_preview(card)
		return {"studio_layer": l}, 
		func(_at: Vector2, data: Variant) -> bool:
			return data is Dictionary and (data as Dictionary).has("studio_layer"), 
		func(_at: Vector2, data: Variant) -> void :
			var moving: StudioLayer = (data as Dictionary)["studio_layer"]
			if moving == l:
				return
			place_layer(moving, layers.find(l))
			UiStyle.sfx("press")
			_rebuild())
	row.add_child(b)
	row.add_child(_icon_btn("arrowUp", "bring forward", func():
		move_layer(l, 1)
		_rebuild()))
	row.add_child(_icon_btn("arrowDown", "send back", func():
		move_layer(l, -1)
		_rebuild()))
	return row

func _icon_btn(icon: String, tip: String, on_press: Callable) -> Button:
	var b: = UiStyle.icon_button(icon, "tertiary", 34)
	b.tooltip_text = tip
	b.pressed.connect(on_press)
	return b



func _panel_edit(box: VBoxContainer) -> void :
	if selection.is_empty():
		_note(box, "click something on the canvas to change it, or drag a box around a few"\
		if not layers.is_empty() else "add something from the add tab")
		return
	if selection.size() > 1:
		_edit_many(box)
		return
	var l: = selected
	box.add_child(host._group_header("name"))
	var name_edit: = LineEdit.new()
	name_edit.text = l.name
	name_edit.placeholder_text = l.label() if l.name == "" else ""
	name_edit.max_length = 32
	name_edit.custom_minimum_size = Vector2(0, 36)
	UiStyle.style_line_edit(name_edit)
	name_edit.text_changed.connect( func(t: String): l.name = t)
	box.add_child(name_edit)
	match l.kind:
		StudioLayer.KIND_CHAR:
			_edit_character(box, l)
		StudioLayer.KIND_TEXT:
			_edit_text(box, l)
		StudioLayer.KIND_BALL:
			_edit_ball(box, l)
		StudioLayer.KIND_PATTERN:
			_edit_pattern(box, l)
		StudioLayer.KIND_BOX:
			_edit_box(box, l)
		StudioLayer.KIND_CALLOUT:
			_edit_callout(box, l)
		StudioLayer.KIND_ARROW:
			_edit_arrow(box, l)
		StudioLayer.KIND_TABLE:
			_edit_table(box, l)
		StudioLayer.KIND_PANEL:
			_edit_panel(box, l)
	if l.kind in [StudioLayer.KIND_CHAR, StudioLayer.KIND_TEXT, StudioLayer.KIND_STICKER, 
			StudioLayer.KIND_BALL, StudioLayer.KIND_PATTERN]:
		_book_fields(box, l)
	box.add_child(host._group_header("line up"))
	_align_grid(box)
	box.add_child(_header("place", func():
		l.reset_place()
		_layer_changed(l, l.kind == StudioLayer.KIND_CHAR)))
	var lim: Vector2 = SIZE_LIMITS.get(l.kind, Vector2(0.05, 2.0))
	box.add_child(_slider("size", _norm_size(l), func(): return inverse_lerp(lim.x, lim.y, l.base_size), 
		func(v: float):
			l.size = lerpf(lim.x, lim.y, v)
			_layer_changed(l, l.kind == StudioLayer.KIND_CHAR), "size"))
	box.add_child(_slider("tilt", rad_to_deg(l.rot) / 90.0 + 0.5, 0.5, func(v: float):
		l.rot = deg_to_rad((v - 0.5) * 90.0)
		_layer_changed(l), "tilt"))
	if l._mirrors():
		box.add_child(host._toggle_row("mirror", l.flip, func(on: bool):
			l.flip = on
			_layer_changed(l)))
	_edit_stick(box, [l])
	_edit_shadow(box, [l])
	_edit_actions(box, [l])

func _edit_many(box: VBoxContainer) -> void :
	box.add_child(host._group_header("%d picked" % selection.size()))
	_note(box, "drag any of them to move them all, scroll or pull the corner to resize them together")
	box.add_child(host._group_header("line up"))
	_align_grid(box)
	_edit_stick(box, selection)
	_edit_shadow(box, selection)
	_edit_actions(box, selection)

func _edit_actions(box: VBoxContainer, ls: Array) -> void :
	var acts: = HFlowContainer.new()
	acts.add_theme_constant_override("h_separation", 6)
	acts.add_theme_constant_override("v_separation", 6)
	box.add_child(acts)
	acts.add_child(_small_btn("bring forward", "secondary", func():
		var front_first: = _in_order(ls)
		front_first.reverse()
		for l in front_first:
			move_layer(l, 1)
		_rebuild()))
	acts.add_child(_small_btn("send back", "secondary", func():
		for l in _in_order(ls):
			move_layer(l, -1)
		_rebuild()))
	var dup: = _small_btn("duplicate", "secondary", func(): duplicate_layers(ls))
	dup.disabled = layers.size() + ls.size() > layer_cap
	acts.add_child(dup)
	acts.add_child(_small_btn("delete", "tertiary", func(): remove_layers(ls)))



func _edit_shadow(box: VBoxContainer, ls: Array) -> void :
	var l: StudioLayer = ls[0]
	box.add_child(_header("shadow", func():
		for x in ls:
			(x as StudioLayer).reset_shadow()
		_dirty()))
	var each: = func(apply: Callable):
		for x in ls:
			apply.call(x)
		_dirty()
	box.add_child(host._toggle_row("drop shadow", l.shadow, func(on: bool):
		each.call( func(x: StudioLayer): x.shadow = on)
		_rebuild()))
	if not l.shadow:
		return
	box.add_child(host._labeled("color", host._color_field(l.shadow_color, func(c: Color):
		each.call( func(x: StudioLayer): x.shadow_color = c))))
	var d: = StudioLayer.SHADOW_DEFAULTS
	box.add_child(_slider("strength", l.shadow_alpha, d["shadow_alpha"], func(v: float):
		each.call( func(x: StudioLayer): x.shadow_alpha = v)))
	box.add_child(_slider("distance", l.shadow_dist, d["shadow_dist"], func(v: float):
		each.call( func(x: StudioLayer): x.shadow_dist = v)))
	box.add_child(_slider("direction", fposmod(l.shadow_angle, 360.0) / 360.0, 
		float(d["shadow_angle"]) / 360.0, func(v: float):
			each.call( func(x: StudioLayer): x.shadow_angle = v * 360.0)))
	box.add_child(_slider("softness", l.shadow_soft, d["shadow_soft"], func(v: float):
		each.call( func(x: StudioLayer): x.shadow_soft = v)))

const SOURCES: = [["", "this look"], ["p1", "player 1"], ["p2", "player 2"], ["p3", "player 3"], ["p4", "player 4"]]

func _edit_character(box: VBoxContainer, l: StudioLayer) -> void :
	if book_mode:
		box.add_child(host._group_header("who wears it"))
		var names: Array = []
		var at: = 0
		for i in SOURCES.size():
			names.append(SOURCES[i][1])
			if SOURCES[i][0] == l.src:
				at = i
		box.add_child(host._choice_grid(names, at, func(i: int):
			l.src = String(SOURCES[i][0])
			l.from_you = false))
		_note(box, "a player who isn't here shows this look instead.")
	_change_look(box, l)
	box.add_child(_header("outfit and pose", func():
		l.reset_pose()
		_layer_changed(l, true)))
	box.add_child(host._choice_grid(StudioRender.OUTFITS, l.outfit, func(i: int):
		l.outfit = i
		_layer_changed(l, true)))
	var labels: Array = []
	var ids: = StudioRender.pose_ids()
	for id in ids:
		labels.append(StudioRender.pose_label(id))
	box.add_child(host._choice_grid(labels, maxi(0, ids.find(l.pose)), func(i: int):
		l.pose = ids[i]
		l.frame = StudioRender.pose_frame(l.pose)
		if StudioRender.FLOOR_POSES.has(l.pose) and absf(l.turn) < 1.0:
			l.turn = StudioRender.FLOOR_TURN
		if _edit.has("frame") and is_instance_valid(_edit["frame"]):
			(_edit["frame"] as Range).set_value_no_signal(l.frame)
		if _edit.has("turn") and is_instance_valid(_edit["turn"]):
			(_edit["turn"] as Range).set_value_no_signal(l.turn / 360.0 + 0.5)
		if _edit.has("other_hand") and is_instance_valid(_edit["other_hand"]):
			(_edit["other_hand"] as Control).visible = StudioRender.has_twin(l.pose)
		_layer_changed(l, true)))


	box.add_child(_slider("frame", l.frame, func(): return StudioRender.pose_frame(l.pose), 
		func(v: float):
			l.frame = v
			_layer_changed(l, true), "frame"))
	box.add_child(_slider("turn", l.turn / 360.0 + 0.5, 
		func(): return (StudioRender.FLOOR_TURN if StudioRender.FLOOR_POSES.has(l.pose) else 0.0) / 360.0 + 0.5, 
		func(v: float):
			l.turn = (v - 0.5) * 360.0
			_layer_changed(l, true), "turn"))
	box.add_child(host._toggle_row("barefoot", l.barefoot, func(on: bool):
		l.barefoot = on
		_layer_changed(l, true)))

	var other: CheckBox = host._toggle_row("other hand", l.other_hand, func(on: bool):
		l.other_hand = on
		_layer_changed(l, true))
	other.visible = StudioRender.has_twin(l.pose)
	_edit["other_hand"] = other
	box.add_child(other)

func _edit_text(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("text"))
	var le: = LineEdit.new()
	le.text = l.text
	le.max_length = 80
	le.placeholder_text = "type here"
	le.custom_minimum_size = Vector2(0, 38)
	UiStyle.style_line_edit(le)
	le.text_changed.connect( func(t: String):
		l.text = t
		_layer_changed(l))
	box.add_child(le)
	box.add_child(_header("style", func():
		l.reset_text_style()
		_layer_changed(l)))
	var fonts: Array = []
	for f in StudioLayer.FONTS:
		fonts.append(f[0])
	box.add_child(host._choice_grid(fonts, l.font, func(i: int):
		l.font = i
		_layer_changed(l)))
	box.add_child(host._swatch_grid(TEXT_COLORS, TEXT_COLORS.find(l.color), func(i: int):
		l.color = TEXT_COLORS[i]
		_layer_changed(l), Vector2(30, 30)))
	var colors: = HBoxContainer.new()
	colors.add_theme_constant_override("separation", 14)
	colors.add_child(host._labeled("fill", host._color_field(l.color, func(c: Color):
		l.color = c
		_layer_changed(l)), 40.0))
	colors.add_child(host._labeled("outline", host._color_field(l.outline_color, func(c: Color):
		l.outline_color = c
		_layer_changed(l)), 62.0))
	box.add_child(colors)
	box.add_child(_slider("outline", l.outline / 0.3, 0.14 / 0.3, func(v: float):
		l.outline = v * 0.3
		_layer_changed(l)))

	if l.text == "nice!" or l.text == "":
		le.call_deferred("grab_focus")
		le.call_deferred("select_all")



func _edit_stick(box: VBoxContainer, ls: Array) -> void :
	var l: StudioLayer = ls[0]
	box.add_child(_header("sticker outline", func():
		for x in ls:
			(x as StudioLayer).reset_stick()
		_dirty()))
	var each: = func(apply: Callable):
		for x in ls:
			apply.call(x)
		_dirty()
	box.add_child(host._toggle_row("sticker outline", l.stick, func(on: bool):
		each.call( func(x: StudioLayer): x.stick = on)
		_rebuild()))
	if not l.stick:
		return
	box.add_child(host._swatch_grid(TEXT_COLORS, TEXT_COLORS.find(l.stick_color), func(i: int):
		each.call( func(x: StudioLayer): x.stick_color = TEXT_COLORS[i]), Vector2(30, 30)))
	box.add_child(host._labeled("color", host._color_field(l.stick_color, func(c: Color):
		each.call( func(x: StudioLayer): x.stick_color = c))))
	box.add_child(_slider("thickness", l.stick_width, StudioLayer.STICK_DEFAULTS["stick_width"], func(v: float):
		each.call( func(x: StudioLayer): x.stick_width = maxf(v, 0.02))))



const BALL_ICONS: = {"nationals": "res://game/images/gameballs/ball_nationals.png", 
	"school": "res://game/images/gameballs/ball_school.png", 
	"beach": "res://game/images/gameballs/ball_outdoor.png"}
const RIM_COLORS: = [StudioLayer.BALL_RIM_DEFAULT, Color(1.0, 0.25, 0.72), Color(0.55, 0.9, 1.0), 
	Color.WHITE, Color("ffd23f"), Color("232b3b")]


static func ball_skins() -> Array:
	var out: Array = []
	for b in StudioLayer.BALLS:
		var path: = Stage.ball_model(String(b[0]))
		if path != "" and ResourceLoader.exists(path):
			out.append(b)
	return out

func _edit_ball(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(_header("ball", func():
		l.reset_ball()
		_layer_changed(l, true)))
	var skins: = ball_skins()
	var names: Array = []
	var at: = 0
	for i in skins.size():
		names.append(skins[i][1])
		if skins[i][0] == l.ball:
			at = i
	box.add_child(host._choice_grid(names, at, func(i: int):
		l.ball = String(skins[i][0])
		_layer_changed(l, true)))
	box.add_child(host._toggle_row("team outline", l.ball_rim, func(on: bool):
		l.ball_rim = on
		_layer_changed(l, true)
		_rebuild()))
	if l.ball_rim:
		box.add_child(host._swatch_grid(RIM_COLORS, RIM_COLORS.find(l.ball_rim_color), func(i: int):
			l.ball_rim_color = RIM_COLORS[i]
			_layer_changed(l, true), Vector2(30, 30)))
		box.add_child(host._labeled("outline", host._color_field(l.ball_rim_color, func(c: Color):
			l.ball_rim_color = c
			_layer_changed(l, true))))
	box.add_child(_slider("spin", l.turn / 360.0 + 0.5, 0.5, func(v: float):
		l.turn = (v - 0.5) * 360.0
		_layer_changed(l, true)))
	box.add_child(_slider("roll", l.frame, 0.0, func(v: float):
		l.frame = v
		_layer_changed(l, true)))



func _edit_pattern(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("pattern"))
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	box.add_child(grid)
	var btns: = {}
	for id in StudioCanvas.tile_ids():
		var pid: String = id
		var b: = _pattern_btn(pid, func():
			l.pattern = pid
			for k in btns:
				host._paint_thumb_btn(btns[k], k == pid)
			_layer_changed(l))
		host._paint_thumb_btn(b, pid == l.pattern)
		grid.add_child(b)
		btns[pid] = b
	box.add_child(host._labeled("color", host._color_field(Color(l.color, 1.0), func(c: Color):
		l.color = Color(c, l.color.a)
		_layer_changed(l))))
	box.add_child(_slider("strength", l.color.a, 0.85, func(v: float):
		l.color.a = maxf(v, 0.05)
		_layer_changed(l)))
	box.add_child(_slider("tile size", l.tile, 0.3, func(v: float):
		l.tile = v
		_layer_changed(l)))
	_size_sliders(box, l)

func _pattern_btn(pid: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(46, 46)
	var thumb: = "res://game/character/studio/patterns/thumbs/pattern_%s.png" % pid.substr(1)
	if ResourceLoader.exists(thumb):
		b.icon = load(thumb) as Texture2D
		b.expand_icon = true
	else:
		b.text = pid
	for st in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		b.add_theme_color_override("icon_%s_color" % st, UiStyle.text())
	b.pressed.connect( func():
		UiStyle.sfx("press")
		on_press.call())
	return b


func _size_sliders(box: VBoxContainer, l: StudioLayer, height: = true) -> void :
	box.add_child(_slider("width", clampf(l.w / 2.0, 0.0, 1.0), l.w / 2.0, func(v: float):
		l.w = maxf(0.02, v * 2.0)
		_layer_changed(l)))
	if height:
		box.add_child(_slider("height", clampf(l.h / 1.2, 0.0, 1.0), l.h / 1.2, func(v: float):
			l.h = maxf(0.02, v * 1.2)
			l.size = l.h
			_layer_changed(l)))




var book_mode: = false

const KEY_PICKS: = ["move", "aim", "jump", "contact", "set", "dive", "block", "strafe", 
	"sprint", "serve", "aim_recenter", "camera_toggle", "stats"]

func _text_editor(text_in: String, on_change: Callable, tall: = 120.0) -> TextEdit:
	var te: = TextEdit.new()
	te.text = text_in
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	te.custom_minimum_size = Vector2(0, tall)

	var probe: = LineEdit.new()
	UiStyle.style_line_edit(probe)
	for st in ["normal", "focus"]:
		te.add_theme_stylebox_override(st, probe.get_theme_stylebox(st))
	te.add_theme_font_override("font", probe.get_theme_font("font"))
	te.add_theme_color_override("font_color", UiStyle.text())
	probe.free()
	te.add_theme_font_size_override("font_size", 14)
	te.text_changed.connect( func(): on_change.call(te.text))
	return te


func _key_inserts(box: VBoxContainer, te: TextEdit) -> void :
	_note(box, "key prompts follow the player's binds and controller: {key:jump} shows the button they would press")
	var flow: = _flow()
	flow.add_theme_constant_override("h_separation", 4)
	flow.add_theme_constant_override("v_separation", 4)
	box.add_child(flow)
	for act in KEY_PICKS:
		var a: String = act
		flow.add_child(_small_btn(a, "tertiary", func():
			te.insert_text_at_caret("{key:%s}" % a)
			te.grab_focus()))

func _book_fields(box: VBoxContainer, l: StudioLayer) -> void :
	if not book_mode:
		return
	box.add_child(host._group_header("book"))
	if l.kind == StudioLayer.KIND_BOX:
		box.add_child(host._toggle_row("section header", l.role == "header", func(on: bool):
			l.role = "header" if on else ""
			_rebuild()))
		if l.role == "header":
			box.add_child(host._labeled("section id", _line(l.sid, "4.3", func(t: String): l.sid = t.strip_edges())))
			box.add_child(host._labeled("search words", _line(l.tags, "brake, stop", func(t: String): l.tags = t)))


	var pick: = OptionButton.new()
	pick.custom_minimum_size = Vector2(200, 34)
	pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pick.fit_to_longest_item = false
	var targets: Array = [""]
	pick.add_item("no link")
	for c in GuideStore.chapters():
		var cd: = c as Dictionary
		targets.append("ch:%s" % cd.get("id", ""))
		pick.add_item("chapter %s  %s" % [str(int(cd.get("n", 0))), String(cd.get("title", ""))])
	for sec in GuideStore.sections():
		if String(sec["sid"]) == "":
			continue
		targets.append(String(sec["sid"]))
		pick.add_item("   %s  %s" % [sec["sid"], String(sec["title"]).left(34)])
	pick.select(maxi(0, targets.find(l.link)))
	pick.item_selected.connect( func(i: int): l.link = String(targets[i]))
	box.add_child(host._labeled("link to", pick))

func _line(text_in: String, hint: String, on_change: Callable) -> LineEdit:
	var le: = LineEdit.new()
	le.text = text_in
	le.placeholder_text = hint
	le.custom_minimum_size = Vector2(170, 32)
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_line_edit(le)
	le.text_changed.connect(on_change)
	return le

func _font_and_color(box: VBoxContainer, l: StudioLayer) -> void :
	var fonts: Array = []
	for f in StudioLayer.FONTS:
		fonts.append(f[0])
	box.add_child(host._choice_grid(fonts, l.font, func(i: int):
		l.font = i
		_layer_changed(l)))
	box.add_child(host._swatch_grid(TEXT_COLORS, TEXT_COLORS.find(l.color), func(i: int):
		l.color = TEXT_COLORS[i]
		_layer_changed(l), Vector2(30, 30)))
	box.add_child(host._labeled("color", host._color_field(l.color, func(c: Color):
		l.color = c
		_layer_changed(l))))

func _edit_box(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("text"))
	var te: = _text_editor(l.text, func(t: String):

		var top: = l.pos.y - l.measured.y * 0.5
		l.text = t
		_layer_changed(l)
		if is_zero_approx(l.rot) and l.measured.y > 0.0:
			l.pos.y = top + l.measured.y * 0.5
			_dirty())
	box.add_child(te)
	_key_inserts(box, te)
	_note(box, "[b]bold[/b]  [i]italic[/i]  [color=#e5484d]colour[/color]")
	box.add_child(host._group_header("style"))
	_font_and_color(box, l)
	box.add_child(host._choice_grid(["left", "centre", "right"], l.align, func(i: int):
		l.align = i
		_layer_changed(l)))
	box.add_child(_slider("outline", l.outline / 0.3, 0.0, func(v: float):
		l.outline = v * 0.3
		_layer_changed(l)))
	box.add_child(host._toggle_row("card behind", l.fill.a > 0.003, func(on: bool):
		l.fill = Color(l.fill, 0.9 if on else 0.0) if l.fill.a > 0.003 or not on\
		else Color(1, 1, 1, 0.9)
		_layer_changed(l)
		_rebuild()))
	if l.fill.a > 0.003:
		box.add_child(host._labeled("card", host._color_field(Color(l.fill, 1.0), func(c: Color):
			l.fill = Color(c, l.fill.a)
			_layer_changed(l))))
		box.add_child(_slider("corners", l.radius, 0.25, func(v: float):
			l.radius = v
			_layer_changed(l)))
	_size_sliders(box, l, false)
	_book_fields(box, l)

func _edit_callout(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("callout"))
	box.add_child(host._labeled("number", _line(l.text, "1", func(t: String):
		l.text = t.left(3)
		_layer_changed(l))))
	box.add_child(host._swatch_grid(TEXT_COLORS, TEXT_COLORS.find(l.color), func(i: int):
		l.color = TEXT_COLORS[i]
		_layer_changed(l), Vector2(30, 30)))
	var colors: = HBoxContainer.new()
	colors.add_theme_constant_override("separation", 14)
	colors.add_child(host._labeled("fill", host._color_field(l.color, func(c: Color):
		l.color = c
		_layer_changed(l)), 40.0))
	colors.add_child(host._labeled("ring", host._color_field(l.outline_color, func(c: Color):
		l.outline_color = c
		_layer_changed(l)), 40.0))
	box.add_child(colors)
	_book_fields(box, l)

func _edit_arrow(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("arrow"))
	box.add_child(host._swatch_grid(TEXT_COLORS, TEXT_COLORS.find(l.color), func(i: int):
		l.color = TEXT_COLORS[i]
		_layer_changed(l), Vector2(30, 30)))
	var colors: = HBoxContainer.new()
	colors.add_theme_constant_override("separation", 14)
	colors.add_child(host._labeled("fill", host._color_field(l.color, func(c: Color):
		l.color = c
		_layer_changed(l)), 40.0))
	colors.add_child(host._labeled("edge", host._color_field(l.outline_color, func(c: Color):
		l.outline_color = c
		_layer_changed(l)), 40.0))
	box.add_child(colors)
	box.add_child(_slider("thickness", l.thick, 0.35, func(v: float):
		l.thick = v
		_layer_changed(l)))
	box.add_child(_slider("bend", l.bend * 0.5 + 0.5, 0.5, func(v: float):
		l.bend = (v - 0.5) * 2.0
		_layer_changed(l)))
	box.add_child(host._toggle_row("both ends", l.head2, func(on: bool):
		l.head2 = on
		_layer_changed(l)))
	_book_fields(box, l)

func _edit_table(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("table"))
	box.add_child(host._toggle_row("controls (reads the live binds)", l.live.begins_with("controls"), func(on: bool):
		l.live = "controls" if on else ""
		_layer_changed(l)
		_rebuild()))
	if l.live == "":
		_note(box, "one row a line, cells split with |. the first row is the header")
		var lines: Array = []
		for row in l.cells:
			lines.append(" | ".join(PackedStringArray((row as Array).map( func(c): return str(c)))))
		var te: = _text_editor("\n".join(PackedStringArray(lines)), func(t: String):
			var rows: Array = []
			for line in t.split("\n"):
				if line.strip_edges() == "":
					continue
				var cells: Array = []
				for c in line.split("|"):
					cells.append(c.strip_edges())
				rows.append(cells)
			l.cells = rows
			_layer_changed(l), 150.0)
		box.add_child(te)
		_key_inserts(box, te)
	box.add_child(host._group_header("style"))
	_font_and_color(box, l)
	var colors: = HBoxContainer.new()
	colors.add_theme_constant_override("separation", 14)
	colors.add_child(host._labeled("header", host._color_field(Color(l.fill, 1.0), func(c: Color):
		l.fill = Color(c, maxf(l.fill.a, 0.9))
		_layer_changed(l)), 62.0))
	colors.add_child(host._labeled("rules", host._color_field(l.outline_color, func(c: Color):
		l.outline_color = c
		_layer_changed(l)), 50.0))
	box.add_child(colors)
	_size_sliders(box, l, false)
	_book_fields(box, l)

func _edit_panel(box: VBoxContainer, l: StudioLayer) -> void :
	box.add_child(host._group_header("panel"))
	box.add_child(host._labeled("fill", host._color_field(Color(l.color, 1.0), func(c: Color):
		l.color = Color(c, l.color.a)
		_layer_changed(l))))
	box.add_child(_slider("strength", l.color.a, 1.0, func(v: float):
		l.color.a = v
		_layer_changed(l)))
	box.add_child(host._labeled("border", host._color_field(l.outline_color, func(c: Color):
		l.outline_color = c
		_layer_changed(l))))
	box.add_child(_slider("border", l.outline, 0.0, func(v: float):
		l.outline = v
		_layer_changed(l)))
	box.add_child(_slider("corners", l.radius, 0.25, func(v: float):
		l.radius = v
		_layer_changed(l)))
	_size_sliders(box, l)
	_book_fields(box, l)



func _panel_options(box: VBoxContainer) -> void :
	box.add_child(_header("save folder", func():
		GameConfig.studio_dir = ""
		GameConfig.save_settings()))
	_note(box, "pictures save to %s" % folder_shown())
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 6)
	row.add_theme_constant_override("v_separation", 6)
	box.add_child(row)
	row.add_child(_small_btn("change folder", "secondary", _pick_folder))
	var reset: = _small_btn("use %s" % DEFAULT_FOLDER_SHOWN, "tertiary", func():
		GameConfig.studio_dir = ""
		GameConfig.save_settings()
		_rebuild())
	reset.disabled = GameConfig.studio_dir == ""
	row.add_child(reset)
	row.add_child(_small_btn("open folder", "secondary", func():
		var dir: = export_dir()
		DirAccess.make_dir_recursive_absolute(dir)
		OS.shell_open(dir)))

func _pick_folder() -> void :
	if _folder_dialog == null:
		_folder_dialog = FileDialog.new()
		_folder_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		_folder_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_folder_dialog.use_native_dialog = true
		_folder_dialog.title = "pick a folder for your pictures"
		_folder_dialog.dir_selected.connect( func(dir: String):
			GameConfig.studio_dir = dir
			GameConfig.save_settings()
			_rebuild())
		add_child(_folder_dialog)
	var start: = export_dir()
	DirAccess.make_dir_recursive_absolute(start)
	_folder_dialog.current_dir = start
	_folder_dialog.popup_centered(Vector2i(860, 560))
