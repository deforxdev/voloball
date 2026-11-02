class_name HowToPlay
extends Control























signal closed



signal freeplay_requested(spread: String)

const PREP_WAIT: = 0.4
const ASPECT: = 1.6
const TAB_W: = 96.0
const TOP_H: = 50.0
const NAV_H: = 46.0
const EDITOR_SCENE: = "res://game/guide/editor/page_editor.tscn"



var show_close: = false

var cancel_closes: = true
var start_spread: = ""

var _render: StudioRender
var _a: GuideSheet
var _b: GuideSheet
var _cover: Panel
var _view: TextureRect
var _mat: ShaderMaterial
var _links: Control
var _tabs: Control
var _page_l: Label
var _page_r: Label
var _search: LineEdit
var _results: PanelContainer
var _results_box: VBoxContainer
var _prev: Button
var _next: Button
var _chapter_label: Label
var _lb: TextureRect
var _rb: TextureRect
var _close_btn: Button
var _edit_btn: Button
var _flash: Panel
var _rings: Control
var _stage: Control
var _intro_done: = false
var _freeplay_btn: Button



class _Rings extends Control:
	func _draw() -> void :
		var n: = int(size.y / 34.0)
		if n < 2:
			return
		var step: = size.y / n
		var mid: = size.x * 0.5
		var r: = minf(9.0, step * 0.26)
		var wire: = Color("c9a24a")
		var ink: = Color("4a3a24")
		for i in n:
			var y: = step * (i + 0.5)
			for side in [-1.0, 1.0]:
				draw_circle(Vector2(mid + side * r * 2.2, y), r * 0.72, Color(0.12, 0.1, 0.08, 0.75))
			var a: = Vector2(mid - r * 2.2, y + r * 0.2)
			var b: = Vector2(mid + r * 2.2, y - r * 0.2)
			var ctrl: = Vector2(mid, y - r * 1.6)
			var pts: = PackedVector2Array()
			for k in 13:
				var u: = k / 12.0
				pts.append(a.lerp(ctrl, u).lerp(ctrl.lerp(b, u), u))
			draw_polyline(pts, ink, r * 0.95, true)
			draw_polyline(pts, wire, r * 0.6, true)
			draw_polyline(pts, Color(1, 1, 1, 0.45), r * 0.18, true)

var _ids: Array = []
var _at: = 0
var _book: = Rect2()
var _state: = ""
var _to: = -1
var _queued: = -1
var _t: = 0.0
var _dir: = 1.0
var _flash_sid: = ""

func _ready() -> void :

	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = false
	custom_minimum_size = Vector2(760, 520)


	if not GuideStore.available():
		set_process(false)
		set_process_input(false)
		return
	GuideStore.reset_cache()
	_ids = GuideStore.ids()
	_build()
	var start: = maxi(0, _ids.find(start_spread)) if start_spread != "" else 0
	_at = start
	resized.connect(_layout)
	visibility_changed.connect( func():
		if is_visible_in_tree():
			_layout())
	var ip: = get_node_or_null("/root/InputPrompts")
	if ip != null:
		ip.connect("changed", _on_prompts_changed)
	_layout.call_deferred()

func _on_prompts_changed() -> void :
	GuideTokens.gen += 1
	if _a != null:
		_a.refresh()
	_paint_nav()



func _build() -> void :

	var backdrop: = ColorRect.new()
	backdrop.color = Color("111214") if UiStyle.dark else Color.WHITE
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_render = StudioRender.new()
	add_child(_render)
	_a = GuideSheet.new()
	_b = GuideSheet.new()
	for s in [_a, _b]:
		(s as GuideSheet).render = _render
		add_child(s)
	_a.settled.connect(_on_a_settled)

	_cover = Panel.new()
	var cb: = StyleBoxFlat.new()
	cb.bg_color = Color("b98a5c")
	cb.border_color = Color("8f6640")
	cb.set_border_width_all(3)
	cb.set_corner_radius_all(16)
	cb.shadow_color = Color(0, 0, 0, 0.35)
	cb.shadow_size = 18
	cb.shadow_offset = Vector2(0, 8)
	_cover.add_theme_stylebox_override("panel", cb)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cover)

	_tabs = Control.new()
	_tabs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tabs)

	_view = TextureRect.new()
	_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_view.stretch_mode = TextureRect.STRETCH_SCALE
	_view.texture = _a.get_texture()
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://game/guide/guide_flip.gdshader")
	_view.material = _mat
	_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_view.gui_input.connect(_on_view_input)
	add_child(_view)

	_flash = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(UiStyle.PRIMARY, 0.25)
	fb.border_color = UiStyle.PRIMARY
	fb.set_border_width_all(3)
	fb.set_corner_radius_all(8)
	_flash.add_theme_stylebox_override("panel", fb)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.visible = false
	add_child(_flash)

	_rings = _Rings.new()
	_rings.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rings)

	_links = Control.new()
	_links.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_links)

	_freeplay_btn = Button.new()
	_freeplay_btn.text = "go to freeplay"
	UiStyle.style_button(_freeplay_btn, "primary", 15)
	_freeplay_btn.pressed.connect( func(): freeplay_requested.emit(current()))
	add_child(_freeplay_btn)

	_page_l = _page_number()
	_page_r = _page_number()

	_search = LineEdit.new()
	_search.placeholder_text = "search"
	_search.clear_button_enabled = true
	UiStyle.style_line_edit(_search)
	_search.text_changed.connect(_run_search)
	_search.text_submitted.connect( func(_t: String):
		var first: = _results_box.get_child(0) if _results_box.get_child_count() > 0 else null
		if first is Button:
			(first as Button).pressed.emit())
	add_child(_search)

	_results = PanelContainer.new()
	UiStyle.style_panel(_results, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	_results.visible = false
	_results.z_index = 10
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(520, 0)
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	_results.add_child(scroll)
	_results_box = VBoxContainer.new()
	_results_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_results_box.add_theme_constant_override("separation", 4)
	scroll.add_child(_results_box)
	add_child(_results)

	_prev = UiStyle.icon_button("arrowLeft", "secondary", 40)
	_prev.tooltip_text = "previous page"
	_prev.pressed.connect( func(): turn(-1))
	add_child(_prev)
	_next = UiStyle.icon_button("arrowRight", "secondary", 40)
	_next.tooltip_text = "next page"
	_next.pressed.connect( func(): turn(1))
	add_child(_next)
	_lb = _glyph_rect()
	_rb = _glyph_rect()
	_chapter_label = Label.new()
	UiStyle.style_label(_chapter_label, "title", UiStyle.text())
	_chapter_label.add_theme_font_size_override("font_size", 18)
	_chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_chapter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_chapter_label)

	_close_btn = UiStyle.icon_button("cross", "tertiary", 40)
	_close_btn.tooltip_text = "close"
	_close_btn.pressed.connect( func(): closed.emit())
	add_child(_close_btn)


	_edit_btn = Button.new()
	_edit_btn.text = "edit page"
	UiStyle.style_button(_edit_btn, "tertiary", 13)
	_edit_btn.pressed.connect(_open_editor)
	add_child(_edit_btn)

	_build_tabs()


	_stage = Control.new()
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	move_child(_stage, 1)
	for n in [_cover, _tabs, _view, _flash, _rings, _links, _page_l, _page_r]:
		(n as Node).reparent(_stage, false)

func _page_number() -> Label:
	var l: = Label.new()
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(UiStyle.INK, 0.55))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _glyph_rect() -> TextureRect:
	var r: = TextureRect.new()
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(34, 34)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _build_tabs() -> void :
	for c in _tabs.get_children():
		c.queue_free()
	var entries: Array = [["contents", "contents", Color("d9d2c3")]]
	var chs: = GuideStore.chapters()
	for ci in chs.size():
		var ch: = chs[ci] as Dictionary
		var first: = GuideStore.first_of_chapter(ci)
		if first == "":
			continue
		var short: = String(ch.get("tab", ch.get("title", "")))
		entries.append([first, "%s  %s" % [str(int(ch.get("n", ci))), short], GuideStore.chapter_color(ci)])
	if _ids.has("index"):
		entries.append(["index", "index", Color("d9d2c3")])
	for e in entries:
		var b: = Button.new()
		var target: String = e[0]
		b.text = String(e[1])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.clip_text = true
		b.set_meta("spread", target)
		b.set_meta("color", e[2])
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		b.add_theme_font_size_override("font_size", 12)
		b.pressed.connect( func():
			UiStyle.sfx("press")
			go_to(target))
		b.mouse_entered.connect( func(): UiStyle.sfx("hover"))
		_tabs.add_child(b)

func _paint_tabs() -> void :
	var here: = _chapter_spread(_at)
	for c in _tabs.get_children():
		var b: = c as Button
		var col: Color = b.get_meta("color")
		var on: = String(b.get_meta("spread")) == here
		var ink: = UiStyle.INK if col.get_luminance() > 0.55 else Color.WHITE
		for st in ["normal", "hover", "pressed", "focus"]:
			var sb: = StyleBoxFlat.new()
			sb.bg_color = col.lightened(0.12) if st == "hover" else col
			sb.corner_radius_top_right = 9
			sb.corner_radius_bottom_right = 9
			sb.content_margin_left = 16.0
			sb.content_margin_right = 6.0
			sb.shadow_color = Color(0, 0, 0, 0.25)
			sb.shadow_size = 3
			if st == "focus":
				sb.set_border_width_all(3)
				sb.border_color = UiStyle.SECONDARY
			b.add_theme_stylebox_override(st, sb)
		for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(k, ink)
		b.position.x = _book.end.x - 8.0 + (10.0 if on else 0.0)


func _chapter_spread(i: int) -> String:
	if i < 0 or i >= _ids.size():
		return ""
	var id: = String(_ids[i])
	if id.begins_with("index"):
		return "index"
	var ci: = GuideStore.chapter_of(id)
	if ci < 0:
		return "contents"
	return GuideStore.first_of_chapter(ci)



func _px_scale() -> float:
	var w: = get_window()
	if w == null:
		return 1.0
	var vis: = w.get_visible_rect().size
	return clampf(float(w.size.y) / maxf(1.0, vis.y), 0.5, 4.0)

func _layout() -> void :
	if not is_inside_tree() or size.x < 50.0:
		return
	_stage.size = size
	var top: = TOP_H + 8.0
	var avail: = Rect2(Vector2(8.0, top), size - Vector2(16.0 + TAB_W, top + NAV_H + 12.0))
	var bw: = minf(avail.size.x, avail.size.y * ASPECT)
	var bh: = bw / ASPECT
	_book = Rect2(Vector2(avail.position.x + (avail.size.x - bw) * 0.5 + TAB_W * 0.25, 
		avail.position.y + (avail.size.y - bh) * 0.5), Vector2(bw, bh)).abs()
	_book.position = _book.position.floor()
	_book.size = _book.size.floor()
	_cover.position = _book.position - Vector2(12, 10)
	_cover.size = _book.size + Vector2(24, 20)
	_view.position = _book.position
	_view.size = _book.size
	_links.position = _book.position
	_links.size = _book.size
	_rings.position = Vector2(_book.position.x + _book.size.x * 0.5 - 40.0, _book.position.y)
	_rings.size = Vector2(80.0, _book.size.y)
	_rings.queue_redraw()

	var n: = _tabs.get_child_count()
	var th: = minf(34.0, (_book.size.y - 8.0) / maxf(1.0, n))
	for i in n:
		var b: = _tabs.get_child(i) as Button
		b.size = Vector2(TAB_W + 8.0, th - 3.0)
		b.position = Vector2(_book.end.x - 8.0, _book.position.y + 4.0 + i * th)

	_search.position = Vector2(_book.position.x, 4.0)
	_search.custom_minimum_size = Vector2.ZERO
	_search.size = Vector2(minf(380.0, _book.size.x * 0.45), TOP_H - 10.0)
	_results.position = _search.position + Vector2(0.0, _search.size.y + 6.0)
	_results.size = Vector2(maxf(520.0, _search.size.x), 0.0)
	_close_btn.visible = show_close
	_freeplay_btn.visible = not freeplay_requested.get_connections().is_empty()
	_freeplay_btn.reset_size()
	_freeplay_btn.position = Vector2(_book.get_center().x - _freeplay_btn.size.x * 0.5, 6.0)
	_close_btn.position = Vector2(_book.end.x + TAB_W - 40.0, 4.0)
	_edit_btn.visible = GuideStore.can_save() and show_close and not AppData.is_harness()
	_edit_btn.position = Vector2(_book.end.x - 120.0, 8.0)

	var ny: = _book.end.y + 14.0
	_prev.position = Vector2(_book.position.x, ny)
	_next.position = Vector2(_book.end.x - _next.size.x, ny)
	_lb.position = _prev.position + Vector2(_prev.size.x + 6.0, 3.0)
	_lb.size = Vector2(34, 34)
	_rb.position = _next.position - Vector2(40.0, -3.0)
	_rb.size = Vector2(34, 34)
	_chapter_label.position = Vector2(_book.position.x + 90.0, ny)
	_chapter_label.size = Vector2(_book.size.x - 180.0, 40.0)
	if not _ids.is_empty() and _state == "":
		if _a.spread_id != String(_ids[_at]):
			_show_current()
		else:
			_a.resize_to(_sheet_px())
	_place_page_numbers()
	_paint_tabs()
	_paint_nav()
	_rebuild_links()
	if not _intro_done:
		_intro_done = true
		_intro.call_deferred()

func _sheet_px() -> Vector2i:
	return Vector2i((_book.size * _px_scale()).round())

func _show_current() -> void :
	if _ids.is_empty():
		return
	_a.show_spread(String(_ids[_at]), _sheet_px())
	_apply_peels(_a)
	_mat.set_shader_parameter("page_a", _a.get_texture())
	_mat.set_shader_parameter("page_b", _a.get_texture())
	_mat.set_shader_parameter("active", false)
	_view.texture = _a.get_texture()

func _place_page_numbers() -> void :
	_page_l.text = str(GuideStore.page_of(_at, false))
	_page_r.text = str(GuideStore.page_of(_at, true))
	_page_l.position = _book.position + Vector2(18.0, _book.size.y - 24.0)
	_page_r.reset_size()
	_page_r.position = Vector2(_book.end.x - 18.0 - _page_r.size.x, _book.end.y - 24.0)
	var turning: = _state == "flip"
	_page_l.visible = not turning
	_page_r.visible = not turning

func _paint_nav() -> void :
	if _prev == null:
		return
	_prev.disabled = _at <= 0
	_next.disabled = _at >= _ids.size() - 1

	_prev.modulate.a = 0.0 if _prev.disabled else 1.0
	_next.modulate.a = 0.0 if _next.disabled else 1.0
	var id: = String(_ids[_at]) if _at < _ids.size() else ""
	var ci: = GuideStore.chapter_of(id)
	if ci >= 0:
		var ch: = GuideStore.chapters()[ci] as Dictionary
		_chapter_label.text = "%s  %s" % [str(int(ch.get("n", ci))), String(ch.get("title", ""))]
	else:
		_chapter_label.text = "index" if id.begins_with("index") else "contents" if id == "contents" else ""
	var pad: = false
	var ip: = get_node_or_null("/root/InputPrompts")
	if ip != null:
		pad = bool(ip.call("using_gamepad"))
		var style: = int(ip.call("active_style"))
		_lb.texture = ip.call("_load_glyph", 1, style, "lb") as Texture2D
		_rb.texture = ip.call("_load_glyph", 1, style, "rb") as Texture2D
	_lb.visible = pad
	_rb.visible = pad



func _rebuild_links() -> void :
	for c in _links.get_children():
		c.queue_free()
	if _state == "flip" or _a == null:
		return
	var cs: = Vector2(_a.size)
	var k: = _book.size / cs
	for l in _a.layers:
		var layer: = l as StudioLayer
		if layer.link == "":
			continue
		var r: = layer.bounds(cs)
		var b: = Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_ALL
		b.position = r.position * k - Vector2(4, 2)
		b.size = r.size * k + Vector2(8, 4)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.tooltip_text = ""
		var empty: = StyleBoxEmpty.new()
		var on: = StyleBoxFlat.new()
		on.bg_color = Color(UiStyle.SECONDARY, 0.12)
		on.border_color = UiStyle.SECONDARY
		on.set_border_width_all(2)
		on.set_corner_radius_all(6)
		b.add_theme_stylebox_override("normal", empty)
		b.add_theme_stylebox_override("pressed", on)
		b.add_theme_stylebox_override("hover", on)
		b.add_theme_stylebox_override("focus", on)
		var link: = layer.link
		b.pressed.connect( func():
			UiStyle.sfx("press")
			follow(link))
		_links.add_child(b)


func follow(link: String) -> void :
	if link.begins_with("ch:"):
		var cid: = link.substr(3)
		var chs: = GuideStore.chapters()
		for ci in chs.size():
			if String((chs[ci] as Dictionary).get("id", "")) == cid:
				go_to(GuideStore.first_of_chapter(ci))
				return
		return
	var sec: = GuideStore.find_section(link)
	if sec.is_empty():
		return
	_flash_sid = link
	go_to(String(sec["spread"]))
	if _state == "" and String(_ids[_at]) == String(sec["spread"]):
		_show_flash()











const RING_BAND: = 26.0
const EDGE: = 0.2
const DRAG_START: = 6.0
const ARC_TIME: = 0.6
const ARC_LIFT: = 0.22
const FALL: = 11.0

var _grab: = Vector2(1.0, 0.85)
var _hand: = Vector2(1.0, 0.85)
var _hand_to: = Vector2(1.0, 0.85)
var _completing: = false
var _press: = Vector2(-1, -1)
var _press_dir: = 0.0
var _vel_x: = 0.0
var _last_move: = 0

func current() -> String:
	return String(_ids[_at]) if _at < _ids.size() else ""

func is_turning() -> bool:
	return _state != ""

func turn(step: int) -> void :
	var from: = _queued if _queued >= 0 else (_to if _to >= 0 else _at)
	_goto_index(clampi(from + step, 0, _ids.size() - 1))

func go_to(id: String) -> void :
	var i: = _ids.find(id)
	if i >= 0:
		_goto_index(i)


func _lift_toward(i: int) -> void :
	_to = i
	_dir = 1.0 if i > _at else -1.0
	_b.show_spread(String(_ids[i]), _sheet_px())
	_apply_peels(_b)
	_set_zoom(1.0)
	_close_results()
	for c in _links.get_children():
		c.queue_free()
	_flash.visible = false
	_mat.set_shader_parameter("page_a", _a.get_texture())
	_mat.set_shader_parameter("page_b", _b.get_texture())
	_mat.set_shader_parameter("dir", _dir)

func _goto_index(i: int) -> void :
	if _state != "":
		if i != _to:
			_queued = i
		return
	if i == _at or i < 0 or i >= _ids.size():
		return
	_lift_toward(i)
	_grab = Vector2(1.0, 0.88)
	_hand = _grab
	_state = "prep"
	_t = 0.0

func _set_fold() -> void :
	_mat.set_shader_parameter("active", _state != "" and _state != "prep")

	_mat.set_shader_parameter("ring_band", RING_BAND / maxf(1.0, _book.size.x))
	_mat.set_shader_parameter("grab", _grab)
	_mat.set_shader_parameter("hand", _hand)
	_mat.set_shader_parameter("aspect", _book.size.x / maxf(1.0, _book.size.y))



func _clamp_hand(h: Vector2) -> Vector2:
	var aspect: = _book.size.x / maxf(1.0, _book.size.y)
	var spine: = Vector2(0.5 * aspect, _grab.y)
	var hs: = Vector2(h.x * aspect, clampf(h.y, -0.15, 1.15))
	var reach: = (_grab.x - 0.5) * aspect
	if hs.distance_to(spine) > reach:
		hs = spine + (hs - spine).normalized() * reach
	return Vector2(hs.x / aspect, hs.y)

func _process(delta: float) -> void :
	match _state:
		"prep":
			_t += delta
			if _b.is_settled() or _t >= (0.05 if _queued >= 0 else PREP_WAIT):
				_state = "auto"
				_t = 0.0
				_place_page_numbers()
				UiStyle.sfx("slide")
		"auto":

			_t += delta / (ARC_TIME * (0.3 if _queued >= 0 else 1.0))
			var e: = clampf(_t, 0.0, 1.0)
			e = e * e * (3.0 - 2.0 * e)
			var end: = Vector2(1.0 - _grab.x, _grab.y)
			_hand = _grab.lerp(end, e) + Vector2(0.0, - ARC_LIFT * sin(e * PI))
			if _t >= 1.0:
				_hand = end
				_finish_turn()
				return
		"drag":
			_vel_x *= exp(-10.0 * delta)
		"settle":
			_hand = _hand.lerp(_hand_to, 1.0 - exp( - FALL * delta))
			if _hand.distance_to(_hand_to) < 0.004:
				if _completing:
					_hand = _hand_to
					_finish_turn()
				else:
					_cancel_turn()
				return
	if _state != "":
		_set_fold()

func _finish_turn() -> void :
	var was: = _a
	_a = _b
	_b = was
	if _a.settled.is_connected(_on_a_settled) == false:
		_a.settled.connect(_on_a_settled)
	if _b.settled.is_connected(_on_a_settled):
		_b.settled.disconnect(_on_a_settled)
	_at = _to
	_end_turn()
	_show_flash()
	if _queued >= 0:
		var q: = _queued
		_queued = -1
		_goto_index(q)


func _cancel_turn() -> void :
	_queued = -1
	_end_turn()

func _end_turn() -> void :
	_to = -1
	_state = ""
	_mat.set_shader_parameter("active", false)
	_mat.set_shader_parameter("page_a", _a.get_texture())
	_mat.set_shader_parameter("page_b", _a.get_texture())
	_view.texture = _a.get_texture()
	_place_page_numbers()
	_paint_tabs()
	_paint_nav()
	_rebuild_links()


func _forward(view_pos: Vector2, d: float) -> Vector2:
	var q: = view_pos / _view.size
	return Vector2(1.0 - q.x if d < 0.0 else q.x, q.y)

func _start_drag(view_pos: Vector2) -> void :
	var i: = _at + (1 if _press_dir > 0.0 else -1)
	if i < 0 or i >= _ids.size():
		return
	_lift_toward(i)
	var f: = _forward(view_pos, _dir)
	_grab = Vector2(1.0, clampf(f.y, 0.04, 0.96))
	_hand = _clamp_hand(f)
	_state = "drag"
	_vel_x = 0.0
	UiStyle.sfx("slide")
	_place_page_numbers()
	_set_fold()

func _release_drag() -> void :

	_completing = _hand.x < 0.5 or _vel_x < -2.5
	_hand_to = Vector2(0.0, _grab.y) if _completing else _grab
	_state = "settle"

func _on_a_settled() -> void :
	if _state == "":
		_rebuild_links()


func _show_flash() -> void :
	if _flash_sid == "":
		return
	var sid: = _flash_sid
	_flash_sid = ""
	var cs: = Vector2(_a.size)
	for l in _a.layers:
		var layer: = l as StudioLayer
		if layer.role == "header" and layer.sid == sid:
			var r: = layer.bounds(cs)
			var k: = _book.size / cs
			_flash.position = _book.position + r.position * k - Vector2(8, 6)
			_flash.size = r.size * k + Vector2(16, 12)
			_flash.visible = true
			_flash.modulate.a = 1.0
			var tw: = create_tween()
			tw.tween_interval(0.6)
			tw.tween_property(_flash, "modulate:a", 0.0, 0.8)
			tw.tween_callback( func(): _flash.visible = false)
			return



func _run_search(q: String) -> void :
	for c in _results_box.get_children():
		_results_box.remove_child(c)
		c.queue_free()
	var hits: = GuideStore.search(q) if q.strip_edges().length() >= 2 else []
	if q.strip_edges().length() < 2:
		_results.visible = false
		return
	if hits.is_empty():
		var none: = Label.new()
		none.text = "nothing found"
		UiStyle.style_label(none, "small", UiStyle.muted())
		_results_box.add_child(none)
	for h in hits:
		_results_box.add_child(_result_button(h))
	var scroll: = _results.get_child(0) as ScrollContainer
	scroll.custom_minimum_size.y = minf(360.0, 18.0 + maxf(1, hits.size()) * 62.0)
	_results.visible = true
	_results.reset_size()

func _result_button(h: Dictionary) -> Button:
	var b: = Button.new()
	var ci: = int(h["chapter"])
	var where: = ""
	if ci >= 0:
		var ch: = GuideStore.chapters()[ci] as Dictionary
		where = "%s  %s" % [str(int(ch.get("n", ci))), String(ch.get("title", ""))]
	var title: = String(h["title"])
	b.text = "%s\n%s" % [(where + ",  " + title) if title != "" and where != "" else (title + where), h["snippet"]]
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	b.custom_minimum_size = Vector2(0, 56)
	UiStyle.style_button(b, "secondary", 14)
	var col: = GuideStore.chapter_color(ci)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb: = b.get_theme_stylebox(st)
		if sb is StyleBoxFlat:
			var c2: = (sb as StyleBoxFlat).duplicate() as StyleBoxFlat
			c2.border_width_left = 8
			c2.border_color = col if st != "focus" else UiStyle.SECONDARY
			b.add_theme_stylebox_override(st, c2)
	var spread: = String(h["spread"])
	var sid: = String(h["sid"])
	b.pressed.connect( func():
		UiStyle.sfx("press")
		_flash_sid = sid
		_close_results()
		if current() == spread and _state == "":
			_show_flash()
		else:
			go_to(spread))
	return b

func _close_results() -> void :
	if _results != null:
		_results.visible = false

func search_for(q: String) -> Array:
	_search.text = q
	_run_search(q)
	return GuideStore.search(q)



func _on_view_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and _state == "":
		var wb: = event as InputEventMouseButton
		if wb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(maxf(1.8, _zoom * 1.3))
			_move_lens(wb.position)
			accept_event()
			return
		if wb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(_zoom / 1.3 if _zoom / 1.3 >= 1.5 else 1.0)
			_move_lens(wb.position)
			accept_event()
			return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb: = event as InputEventMouseButton
		if not mb.pressed and _peel != null:
			_drop_peel(mb.position)
			accept_event()
			return
		if mb.pressed:
			_close_results()
			if _state != "":
				accept_event()
				return
			if _pick_sticker(mb.position):
				accept_event()
				return
			var x: = mb.position.x / _view.size.x
			_press = mb.position
			_press_dir = 1.0 if x >= 0.5 else -1.0
		else:
			if _state == "drag":
				_release_drag()
			elif _press.x >= 0.0 and _state == "":
				turn(1 if _press_dir > 0.0 else -1)
			_press = Vector2(-1, -1)
		accept_event()
	elif event is InputEventMouseMotion:
		var mm: = event as InputEventMouseMotion
		if _zoom > 1.0:
			_move_lens(mm.position)
		if _peel != null:
			_move_peel(mm.position, mm.relative)
			accept_event()
			return
		if _state == "drag":
			var before: = _hand.x
			_hand = _clamp_hand(_forward(mm.position, _dir))
			var now: = Time.get_ticks_usec()
			var dt: = clampf((now - _last_move) / 1000000.0, 0.004, 0.2)
			_last_move = now
			_vel_x = lerpf(_vel_x, (_hand.x - before) / dt, 0.5)
			_set_fold()
			accept_event()
		elif _press.x >= 0.0 and _state == "" and mm.position.distance_to(_press) > DRAG_START:

			var x: = _press.x / _view.size.x
			var edge: = x >= 1.0 - EDGE if _press_dir > 0.0 else x <= EDGE
			if edge:
				_start_drag(mm.position)
			accept_event()






const INTRO_SLIDE: = 0.38
const INTRO_OPEN: = 0.55

func _intro() -> void :
	_state = "intro"
	var piv: = _book.get_center()
	_stage.pivot_offset = piv
	_stage.scale = Vector2.ONE * 0.45


	_stage.position = Vector2(0.0, size.y * 1.2)
	_stage.rotation = -0.12

	var t0: = Time.get_ticks_msec()


	while is_inside_tree() and not _a.is_settled() and Time.get_ticks_msec() - t0 < 400:
		await get_tree().process_frame
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var half: = Vector2(_book.size.x * 0.5, _book.size.y)
	var inside: = ColorRect.new()
	inside.color = Color("a77b50")
	inside.position = _book.position
	inside.size = half
	inside.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(inside)
	_stage.move_child(inside, _view.get_index() + 1)
	var lid: = TextureRect.new()
	var at: = AtlasTexture.new()
	at.atlas = _a.get_texture()
	at.region = Rect2(Vector2.ZERO, Vector2(_a.size.x * 0.5, _a.size.y))
	lid.texture = at
	lid.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lid.stretch_mode = TextureRect.STRETCH_SCALE
	lid.position = _book.position + Vector2(half.x, 0.0)
	lid.size = half
	lid.pivot_offset = Vector2(0.0, half.y * 0.5)
	lid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(lid)
	_stage.move_child(lid, _rings.get_index())
	var tw: = create_tween()
	tw.set_parallel(true)
	tw.tween_property(_stage, "scale", Vector2.ONE, INTRO_SLIDE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_stage, "position", Vector2.ZERO, INTRO_SLIDE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_stage, "rotation", 0.0, INTRO_SLIDE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_method( func(u: float):
		var e: = u * u * (3.0 - 2.0 * u)
		var c: = cos(e * PI)
		lid.scale.x = c

		lid.flip_h = c < 0.0
		lid.modulate = Color(1, 1, 1).darkened(0.25 * sin(e * PI))
		if c < 0.0:
			lid.position.x = _book.position.x + half.x
		, 0.0, 1.0, INTRO_OPEN)
	tw.chain().tween_callback( func():
		inside.queue_free()
		lid.queue_free()
		_state = ""
		_rebuild_links()
		if _queued >= 0:
			var q: = _queued
			_queued = -1
			_goto_index(q))
	UiStyle.sfx("slide")






const LENS: = 270.0
var _zoom: = 1.0
var _lens: TextureRect = null
var _lens_frame: Control = null

class _LensFrame extends Control:
	func _draw() -> void :
		var r: = size.x * 0.5
		var c: = Vector2(r, r)
		var a: = c + Vector2(r * 0.72, r * 0.72)
		var b: = c + Vector2(r * 1.25, r * 1.25)
		draw_line(a, b, Color("232b3b"), r * 0.2, true)
		draw_line(a, b, Color("8a6a4f"), r * 0.13, true)
		draw_arc(c, r - 3.0, 0.0, TAU, 72, Color("232b3b"), 9.0, true)
		draw_arc(c, r - 3.0, 0.0, TAU, 72, Color("c9a24a"), 5.0, true)

func _ensure_lens() -> void :
	if _lens != null:
		return
	_lens = TextureRect.new()
	_lens.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lens.texture = _a.get_texture()
	var m: = ShaderMaterial.new()
	m.shader = load("res://game/guide/guide_lens.gdshader")
	_lens.material = m
	_lens.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lens.z_index = 5
	add_child(_lens)
	_lens_frame = _LensFrame.new()
	_lens_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lens_frame.z_index = 5
	add_child(_lens_frame)



var _lens_sheet: GuideSheet = null

func _set_zoom(z: float) -> void :
	var was: = _zoom
	_zoom = clampf(z, 1.0, 4.0)
	if _zoom <= 1.0:
		if _lens != null:
			_lens.visible = false
			_lens_frame.visible = false
		return
	_ensure_lens()
	_lens.visible = true
	_lens_frame.visible = true
	if was <= 1.0:
		if _lens_sheet == null:
			_lens_sheet = GuideSheet.new()
			_lens_sheet.render = _render
			add_child(_lens_sheet)
		if _lens_sheet.spread_id != _a.spread_id or _lens_sheet.size != _sheet_px() * 2:
			_lens_sheet.show_spread(_a.spread_id, _sheet_px() * 2)

		_lens_sheet.layers.clear()
		for l in _a.layers:

			_lens_sheet.layers.append(StudioLayer.from_dict((l as StudioLayer).to_dict()))
		for l in _lens_sheet.layers:
			if (l as StudioLayer).is_rendered():
				_lens_sheet._queue.append(l)
		_lens_sheet.refresh()

func _move_lens(view_pos: Vector2) -> void :
	if _lens == null or _zoom <= 1.0:
		return
	var at: = _view.position + view_pos
	_lens.size = Vector2(LENS, LENS)
	_lens.position = at - _lens.size * 0.5
	_lens_frame.size = _lens.size
	_lens_frame.position = _lens.position
	_lens_frame.queue_redraw()
	var m: = _lens.material as ShaderMaterial
	var ready: = _lens_sheet != null and _lens_sheet.spread_id == _a.spread_id
	m.set_shader_parameter("page", _lens_sheet.get_texture() if ready else _a.get_texture())
	m.set_shader_parameter("center", view_pos / _view.size)
	m.set_shader_parameter("zoom", _zoom)
	m.set_shader_parameter("span", Vector2(LENS, LENS) / _view.size)






var _peels: = {}
var _peel: StudioLayer = null
var _peel_img: TextureRect = null
var _peel_off: = Vector2.ZERO
var _peel_index: = -1
var _peel_base_rot: = 0.0

func _pick_sticker(view_pos: Vector2) -> bool:
	var cs: = Vector2(_a.size)
	var p: = view_pos / _view.size * cs
	for i in range(_a.layers.size() - 1, -1, -1):
		var l: = _a.layers[i] as StudioLayer
		var peelable: = l.kind in [StudioLayer.KIND_STICKER, StudioLayer.KIND_CHAR, StudioLayer.KIND_BALL]
		if not peelable or l.sticker.contains("/logo/"):
			continue
		if not l.contains(p, cs):
			continue
		_peel = l
		_peel_index = int(l.get_meta("book_index", i))
		var r: = l.bounds(cs)
		var k: = _view.size / cs
		_peel_img = TextureRect.new()
		_peel_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_peel_img.stretch_mode = TextureRect.STRETCH_SCALE


		var nodes: Dictionary = _a.canvas._nodes.get(l, {})
		var vp: SubViewport = nodes.get("vp")
		if vp != null and is_instance_valid(vp):
			_peel_img.texture = ImageTexture.create_from_image(vp.get_texture().get_image())
			var img_node: = nodes["img"] as Control
			_peel_img.size = img_node.size * k
			_peel_img.pivot_offset = (l.pos * cs - img_node.position) * k
			_peel_img.position = _view.position + img_node.position * k
		else:
			_peel_img.texture = l.tex if l.is_rendered() else l.sticker_tex()
			var lr: = l.local_rect(cs)
			_peel_img.size = lr.size.abs() * k
			_peel_img.pivot_offset = _peel_img.size * 0.5
			_peel_img.rotation = l.rot
			_peel_img.flip_h = l.flip
			_peel_img.position = _view.position + l.pos * _view.size - _peel_img.size * 0.5
		_peel_base_rot = _peel_img.rotation
		_peel_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_peel_img.z_index = 4
		add_child(_peel_img)
		_peel_off = l.pos * _view.size - view_pos

		var tw: = create_tween()
		tw.tween_property(_peel_img, "scale", Vector2.ONE * 1.12, 0.12)
		_peel_img.modulate = Color(1, 1, 1, 1)
		_a.layers.erase(l)
		_a.refresh()
		UiStyle.sfx("press")
		var _unused: = r
		return true
	return false

func _move_peel(view_pos: Vector2, rel: Vector2) -> void :
	if _peel_img == null:
		return

	_peel_img.position = _view.position + view_pos + _peel_off - _peel_img.pivot_offset

	_peel_img.rotation = lerpf(_peel_img.rotation, _peel_base_rot + clampf(rel.x * 0.01, -0.25, 0.25), 0.3)

func _drop_peel(view_pos: Vector2) -> void :
	var l: = _peel
	var at: = ((view_pos + _peel_off) / _view.size).clamp(Vector2(0.02, 0.02), Vector2(0.98, 0.98))
	l.pos = at
	l.rot += _peel_img.rotation - _peel_base_rot
	_a.layers.append(l)
	_a.refresh()
	var map: Dictionary = _peels.get(_a.spread_id, {})
	map[_peel_index] = [l.pos, l.rot]
	_peels[_a.spread_id] = map
	_peel_img.queue_free()
	_peel_img = null
	_peel = null
	UiStyle.sfx("tick")


func _apply_peels(sheet: GuideSheet) -> void :
	for i in sheet.layers.size():
		(sheet.layers[i] as StudioLayer).set_meta("book_index", i)
	var map: Dictionary = _peels.get(sheet.spread_id, {})
	if map.is_empty():
		return
	var moved: Array = []
	for i in map:
		if int(i) < sheet.layers.size():
			var l: = sheet.layers[int(i)] as StudioLayer
			l.pos = map[i][0]
			l.rot = map[i][1]
			moved.append(l)
	for l in moved:
		sheet.layers.erase(l)
		sheet.layers.append(l)
	sheet.refresh()


func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_MOUSE_EXIT and _state == "drag":
		_release_drag()

func _input(event: InputEvent) -> void :
	if not is_visible_in_tree():
		return
	if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		match (event as InputEventJoypadButton).button_index:
			JOY_BUTTON_LEFT_SHOULDER:
				turn(-1)
				get_viewport().set_input_as_handled()
				return
			JOY_BUTTON_RIGHT_SHOULDER:
				turn(1)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventKey and (event as InputEventKey).pressed:
		var k: = event as InputEventKey

		var typing: = get_viewport().gui_get_focus_owner() is LineEdit
		var code: = k.physical_keycode if k.physical_keycode != 0 else k.keycode
		if not typing and (code == KEY_RIGHT or code == KEY_D) and ( not k.echo or _queued < 0):
			turn(1)
			get_viewport().set_input_as_handled()
			return
		if not typing and (code == KEY_LEFT or code == KEY_A) and ( not k.echo or _queued < 0):
			turn(-1)
			get_viewport().set_input_as_handled()
			return
		if k.echo:
			return
		if k.keycode == KEY_PAGEDOWN:
			turn(1)
			get_viewport().set_input_as_handled()
			return
		if k.keycode == KEY_PAGEUP:
			turn(-1)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_cancel"):
		if _results.visible:
			_close_results()
			get_viewport().set_input_as_handled()
		elif show_close and cancel_closes:
			closed.emit()
			get_viewport().set_input_as_handled()

func _open_editor() -> void :
	Engine.set_meta("guide_edit", current())
	get_tree().paused = false
	get_tree().change_scene_to_file(EDITOR_SCENE)




const MOVE_ACTIONS: = ["move_forward", "move_left", "move_back", "move_right"]



static func keys_for(action: String) -> String:
	if MobileControls.enabled():
		return MobileControls.action_label(action)
	if action == "move":
		return _keys_for_all(MOVE_ACTIONS)
	if action == "@mouse":
		return "mouse"
	return _keys_for(action)

static func _keys_for_all(actions: Array) -> String:
	var out: Array[String] = []
	for a in actions:
		var k: = _keys_for(String(a))
		if k != "":
			out.append(k)
	return " ".join(out)



static func _keys_for(action: String) -> String:
	if not InputMap.has_action(action):
		return ""
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key: = event as InputEventKey
			var code: = key.physical_keycode if key.physical_keycode != 0\
			else key.keycode
			return OS.get_keycode_string(code).to_lower()
		if event is InputEventMouseButton:
			match (event as InputEventMouseButton).button_index:
				MOUSE_BUTTON_LEFT:
					return "lmb"
				MOUSE_BUTTON_RIGHT:
					return "rmb"
				MOUSE_BUTTON_MIDDLE:
					return "mmb"
	return ""
