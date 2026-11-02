class_name UiStyle




















const PRIMARY: = Color("ffd23f")
const SECONDARY: = Color("2e78ff")
const INK: = Color("232b3b")
const NEUTRAL: = Color("f2f4fb")
const CARD: = Color("ffffff")
const SUCCESS: = Color("3fd46a")
const HIGHLIGHT: = Color("ff7ea8")
const MUTED: = Color("8b93a7")

const RADIUS: = 14
const RADIUS_SOFT: = 22
const EDGE: = 4

const FONT_BLACK: = "res://game/fonts/Nunito/Nunito-Black.ttf"
const FONT_XBOLD: = "res://game/fonts/Nunito/Nunito-ExtraBold.ttf"
const FONT_SEMI: = "res://game/fonts/Nunito/Nunito-SemiBold.ttf"

static func font(path: String) -> FontFile:
	return load(path) as FontFile






static var dark: = false

static func bg() -> Color:
	return Color("0c0c0e") if dark else NEUTRAL

static func card() -> Color:
	return Color("1a1a1d") if dark else CARD

static func text() -> Color:
	return Color("f4f4f6") if dark else INK

static func muted() -> Color:
	return Color("9b9ba3") if dark else MUTED



static func hairline() -> Color:
	return Color("2c2c33") if dark else Color("dde3ee")


static func sunk() -> Color:
	return Color("2a2a30") if dark else Color("e4e8f2")


const PRIMARY_PALE: = Color("ffe9a3")


static func flat_box(fill: Color, radius: = RADIUS, hair: = false) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	b.set_corner_radius_all(radius)
	b.corner_detail = 12
	if hair:
		b.set_border_width_all(2)
		b.border_color = hairline()
	return b

const _AUTO: = Color(0, 0, 0, 0)
const STAGGER_ON: = false





static func card_box(fill: = _AUTO, radius: = RADIUS) -> StyleBoxFlat:
	var f: = card() if fill == _AUTO else fill
	var b: = flat_box(f, radius, fill == _AUTO)
	b.set_content_margin_all(14)
	return b

static func style_panel(p: Control, fill: = _AUTO, radius: = RADIUS) -> void :
	p.add_theme_stylebox_override("panel", card_box(fill, radius))






const CAPSULE: = 99

static func _slab(fill: Color, edge: Color, _pressed: bool, 
		radius: = CAPSULE) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	b.set_corner_radius_all(radius)
	b.corner_detail = 12
	if edge.a > 0.0:
		b.set_border_width_all(2)
		b.border_color = edge
	b.content_margin_left = 20.0
	b.content_margin_right = 20.0
	b.content_margin_top = 8.0
	b.content_margin_bottom = 9.0
	return b

const RED: = Color("e5484d")





static func style_button(btn: Button, kind: = "primary", 
		font_size: = 20) -> void :
	var fill: = PRIMARY
	var text_c: = INK
	match kind:
		"secondary":
			fill = card()
			text_c = SECONDARY.lightened(0.25) if dark else SECONDARY
		"tertiary":
			fill = Color(0, 0, 0, 0)
			text_c = muted()
		"danger":
			fill = RED
			text_c = Color.WHITE
		"exit":
			fill = RED
			text_c = Color.WHITE
		"chip":
			fill = CHIP
			text_c = Color.WHITE
		"blue":
			fill = SECONDARY
			text_c = Color.WHITE

	var edge: = hairline() if kind == "secondary" else Color(0, 0, 0, 0)
	var hover_fill: = fill.lightened(0.08) if kind != "secondary"\
	else fill.lerp(SECONDARY, 0.08)
	btn.add_theme_stylebox_override("normal", _slab(fill, edge, false))
	btn.add_theme_stylebox_override("hover", _slab(hover_fill, edge, false))
	btn.add_theme_stylebox_override("pressed", 
		_slab(fill.darkened(0.08), edge, true))


	var focus: = _slab(hover_fill, edge, false)
	focus.set_border_width_all(4)
	focus.border_color = SECONDARY
	btn.add_theme_stylebox_override("focus", focus)

	var dis: = _slab(Color(muted(), 0.22), Color(0, 0, 0, 0), true)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_disabled_color", Color(muted(), 0.85))
	if kind == "tertiary":
		btn.add_theme_stylebox_override("hover", _slab(
			Color(text(), 0.06), Color(0, 0, 0, 0), false))
	btn.add_theme_font_override("font", font(FONT_XBOLD))
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", text_c)
	btn.add_theme_color_override("font_hover_color", text_c)
	btn.add_theme_color_override("font_pressed_color", text_c.darkened(0.1))
	btn.add_theme_color_override("font_hover_pressed_color", text_c)
	btn.add_theme_color_override("font_focus_color", text_c)
	var bounce: = press_bounce.bind(btn)
	if not btn.pressed.is_connected(bounce):
		btn.pressed.connect(bounce)

	if kind == "primary" or kind == "danger" or kind == "exit" or kind == "chip":
		var burst: = _burst_self.bind(btn, fill.lightened(0.25))
		if not btn.pressed.is_connected(burst):
			btn.pressed.connect(burst)


	var role: = "confirm" if (kind == "primary" or kind == "chip")\
	else ("back" if kind in ["danger", "exit"] else "press")


	for r in ["press", "confirm", "back"]:
		var old: = sfx.bind(r)
		if r != role and btn.pressed.is_connected(old):
			btn.pressed.disconnect(old)
	var snd: = sfx.bind(role)
	if not btn.pressed.is_connected(snd):
		btn.pressed.connect(snd)
	hover_sound(btn)

static func _burst_self(btn: Button, color: Color) -> void :
	click_burst(btn, color)




static func style_pill(l: Label, bg_c: = PRIMARY, text_c: = _AUTO, 
		font_size: = 14) -> void :
	var b: = StyleBoxFlat.new()
	b.bg_color = bg_c
	b.set_corner_radius_all(99)
	b.content_margin_left = 12.0
	b.content_margin_right = 12.0
	b.content_margin_top = 3.0
	b.content_margin_bottom = 3.0
	l.add_theme_stylebox_override("normal", b)
	l.add_theme_font_override("font", font(FONT_XBOLD))
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", 
		INK if text_c == _AUTO else text_c)




static func style_label(l: Label, role: = "body", color: = _AUTO) -> void :
	var c: = color
	match role:
		"shout":
			l.add_theme_font_override("font", font(FONT_BLACK))
			l.add_theme_font_size_override("font_size", 34)
		"title":
			l.add_theme_font_override("font", font(FONT_XBOLD))
			l.add_theme_font_size_override("font_size", 24)
		"small":
			l.add_theme_font_override("font", font(FONT_SEMI))
			l.add_theme_font_size_override("font_size", 13)
			if c == _AUTO:
				c = muted()
		_:
			l.add_theme_font_override("font", font(FONT_SEMI))
			l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", text() if c == _AUTO else c)





static func icon(name: String, force_white: = false, force_black: = false) -> Texture2D:
	var shade: = "Black" if force_black else ("White" if (force_white or dark) else "Black")
	return load("res://game/ui_icon/Game Icons/PNG/%s/2x/%s.png"
		%[shade, name]) as Texture2D




static func icon_board(name: String) -> Texture2D:
	return load("res://game/ui_icon/BoardGame/PNG/Double (128px)/%s.png"
		%name) as Texture2D










static var _disc_cache: = {}

static func _disc_tex(size_out: int, fill: Color, ring: = Color(0, 0, 0, 0), 
		ring_frac: = 0.0, hollow: = false, 
		glyph: Texture2D = null) -> Texture2D:
	var glyph_key: = ""
	if glyph != null:
		glyph_key = glyph.resource_path if glyph.resource_path != "" else str(glyph.get_instance_id())
	var key: = "%d|%s|%s|%s|%s|%s" % [size_out, fill.to_html(), ring.to_html(), 
		ring_frac, hollow, glyph_key]
	var kept: Variant = _disc_cache.get(key)
	if kept != null:
		return kept
	if _disc_cache.size() > 400:
		_disc_cache.clear()
	var made: = _bake_disc(size_out, fill, ring, ring_frac, hollow, glyph)
	_disc_cache[key] = made
	return made

static func _bake_disc(size_out: int, fill: Color, ring: Color, 
		ring_frac: float, hollow: bool, glyph: Texture2D) -> Texture2D:


	var size: = size_out * 3
	var img: = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c: = (size - 1) * 0.5
	var r_out: = size * 0.5 - 2.0
	var r_in: = r_out * (1.0 - ring_frac)
	for y in size:
		for x in size:
			var d: = Vector2(x - c, y - c).length()
			var a_out: = clampf(r_out - d + 0.5, 0.0, 1.0)
			if a_out <= 0.0:
				continue
			var col: Color
			if ring_frac > 0.0 and d >= r_in:
				col = ring
			elif hollow:
				continue
			else:
				col = fill
				if ring_frac > 0.0:

					var t_in: = clampf(d - r_in + 0.5, 0.0, 1.0)
					col = fill.lerp(ring, t_in)
			col.a *= a_out
			img.set_pixel(x, y, col)
	if glyph != null:
		var g: = glyph.get_image()
		g.convert(Image.FORMAT_RGBA8)
		var gs: = int(size * 0.58)
		g.resize(gs, gs, Image.INTERPOLATE_LANCZOS)
		img.blend_rect(g, Rect2i(0, 0, gs, gs), 
			Vector2i((size - gs) / 2, (size - gs) / 2))
	img.resize(size_out, size_out, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)

static func _dot(color: Color, size: = 26) -> Texture2D:
	return _disc_tex(size, color)



static func _knob(size: = 26) -> Texture2D:
	var core: = Color("e8e8ee") if dark else Color.WHITE
	return _rrect_tex(Vector2i(int(round(size * 0.76)), size), core, 
		hairline() if not dark else Color(0, 0, 0, 0), 0.34)



static var _rrect_cache: = {}

static func _rrect_tex(size_out: Vector2i, fill: Color, ring: = Color(0, 0, 0, 0), 
		radius_frac: = 0.5, ring_px: = 2.0) -> Texture2D:
	var key: = "%s|%s|%s|%s|%s" % [size_out, fill.to_html(), ring.to_html(), radius_frac, ring_px]
	var kept: Variant = _rrect_cache.get(key)
	if kept != null:
		return kept
	var ss: = 3
	var w: = size_out.x * ss
	var h: = size_out.y * ss
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var half: = Vector2(w, h) * 0.5 - Vector2(1.5, 1.5)
	var rad: = minf(half.x, half.y) * 2.0 * radius_frac
	rad = minf(rad, minf(half.x, half.y))
	var ring_w: = ring_px * ss if ring.a > 0.0 else 0.0
	for y in h:
		for x in w:
			var q: = Vector2(absf(x + 0.5 - w * 0.5), absf(y + 0.5 - h * 0.5)) - half + Vector2(rad, rad)
			var d: = Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - rad
			var a: = clampf(0.5 - d, 0.0, 1.0)
			if a <= 0.0:
				continue
			var col: = fill
			if ring_w > 0.0:
				col = fill.lerp(ring, clampf(d + ring_w + 0.5, 0.0, 1.0))
			col.a *= a
			img.set_pixel(x, y, col)
	img.resize(size_out.x, size_out.y, Image.INTERPOLATE_LANCZOS)
	var t: = ImageTexture.create_from_image(img)
	_rrect_cache[key] = t
	return t

static func _track(color: Color) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(99)
	return b

static func style_slider(s: Slider) -> void :



	s.scrollable = false



	s.mouse_filter = Control.MOUSE_FILTER_PASS
	var track: = _track(sunk())
	track.content_margin_top = 4.0
	track.content_margin_bottom = 4.0
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", _track(SECONDARY))
	s.add_theme_stylebox_override("grabber_area_highlight", 
		_track(SECONDARY.lightened(0.12)))
	s.add_theme_icon_override("grabber", _knob(34))
	s.add_theme_icon_override("grabber_highlight", _knob(38))
	s.add_theme_icon_override("grabber_disabled", 
		_dot(Color(muted(), 0.5)))
	var tick: = _drag_tick
	if not s.drag_ended.is_connected(tick):
		s.drag_ended.connect(tick)

	var slide: = _slide_sfx
	if not s.value_changed.is_connected(slide):
		s.value_changed.connect(slide)

static func _drag_tick(_changed: bool) -> void :
	sfx("tick")

static var _slide_ms: = 0

static func _slide_sfx(_v: float) -> void :
	var now: = Time.get_ticks_msec()
	if now - _slide_ms < 45:
		return
	_slide_ms = now
	sfx("scrub")

static func style_check(cb: CheckBox) -> void :




	var blank: = _disc_tex(2, Color(0, 0, 0, 0))


	for n in ["checked", "unchecked", "checked_disabled", 
		"unchecked_disabled", "radio_checked", "radio_unchecked", 
		"radio_checked_disabled", "radio_unchecked_disabled"]:
		cb.add_theme_icon_override(n, blank)
	cb.icon = _check_disc(cb.button_pressed)
	cb.add_theme_constant_override("icon_max_width", 46)
	cb.add_theme_font_override("font", font(FONT_SEMI))
	cb.add_theme_font_size_override("font_size", 16)



	for state in ["font_color", "font_hover_color", "font_pressed_color", 
		"font_hover_pressed_color", "font_focus_color"]:
		cb.add_theme_color_override(state, text())


	var focus: = StyleBoxFlat.new()
	focus.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	focus.set_border_width_all(2)
	focus.border_color = HIGHLIGHT
	focus.set_corner_radius_all(RADIUS_SOFT)
	focus.set_content_margin_all(4.0)
	cb.add_theme_stylebox_override("focus", focus)
	var bounce: = press_bounce.bind(cb)
	if not cb.pressed.is_connected(bounce):
		cb.pressed.connect(bounce)
	var ts: = _check_swap.bind(cb)
	if not cb.toggled.is_connected(ts):
		cb.toggled.connect(ts)

static func _check_swap(on: bool, cb: CheckBox) -> void :
	cb.icon = _check_disc(on)
	sfx("toggle_on" if on else "toggle_off")







static func set_check(cb: CheckBox, on: bool) -> void :
	cb.set_pressed_no_signal(on)
	cb.icon = _check_disc(on)

static var _toggle_cache: = {}

static func _check_disc(on: bool) -> Texture2D:

	var key: = "%s|%s" % [on, dark]
	var kept: Variant = _toggle_cache.get(key)
	if kept != null:
		return kept
	var w: = 138
	var h: = 78
	var track: Image = (_rrect_tex(Vector2i(w, h), SECONDARY if on else (Color("2c2c33") if dark else Color("d5dbe8")), Color(0, 0, 0, 0), 0.5)).get_image()
	var k: = h - 16
	var knob: Image = (_rrect_tex(Vector2i(k, k), Color.WHITE if (on or not dark) else Color("8b8b94"), Color(0, 0, 0, 0), 0.5)).get_image()
	track.convert(Image.FORMAT_RGBA8)
	knob.convert(Image.FORMAT_RGBA8)
	track.blend_rect(knob, Rect2i(0, 0, k, k), Vector2i((w - k - 8) if on else 8, 8))
	var t: = ImageTexture.create_from_image(track)
	_toggle_cache[key] = t
	return t

static func style_line_edit(le: LineEdit) -> void :
	var box: = StyleBoxFlat.new()


	box.bg_color = Color("26262c") if dark else sunk()
	box.set_corner_radius_all(RADIUS)
	box.set_content_margin_all(10)
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	le.add_theme_stylebox_override("normal", box)
	var focused: StyleBoxFlat = box.duplicate()
	focused.border_width_bottom = 2
	focused.border_width_top = 2
	focused.border_width_left = 2
	focused.border_width_right = 2
	focused.border_color = SECONDARY
	le.add_theme_stylebox_override("focus", focused)
	le.add_theme_font_override("font", font(FONT_SEMI))
	le.add_theme_font_size_override("font_size", 16)
	le.add_theme_color_override("font_color", text())
	le.add_theme_color_override("font_placeholder_color", muted())
	le.add_theme_color_override("caret_color", SECONDARY)



static func style_option(ob: OptionButton) -> void :
	style_button(ob, "secondary", 16)
	var pop: = ob.get_popup()
	pop.transparent_bg = true
	pop.add_theme_stylebox_override("panel", card_box())
	var hover: = StyleBoxFlat.new()
	hover.bg_color = Color(SECONDARY, 0.3 if dark else 0.14)
	hover.set_corner_radius_all(10)
	hover.content_margin_left = 10.0
	hover.content_margin_right = 10.0
	pop.add_theme_stylebox_override("hover", hover)
	pop.add_theme_font_override("font", font(FONT_SEMI))
	pop.add_theme_font_size_override("font_size", 16)
	pop.add_theme_color_override("font_color", text())
	pop.add_theme_color_override("font_hover_color", text())
	pop.add_theme_constant_override("v_separation", 6)


	var blank: = _disc_tex(2, Color(0, 0, 0, 0))
	for n in ["radio_checked", "radio_unchecked", "checked", "unchecked"]:
		pop.add_theme_icon_override(n, blank)

static func style_spin(sb: SpinBox) -> void :
	style_line_edit(sb.get_line_edit())



	var arrow_up: = _sized_icon("arrowUp", 14, true)
	var arrow_down: = _sized_icon("arrowDown", 14, true)
	for st in ["up_icon_modulate", "down_icon_modulate"]:
		sb.add_theme_color_override(st, SECONDARY)
	for state in ["", "_hover", "_pressed", "_disabled"]:
		sb.add_theme_icon_override("up%s" % state, arrow_up)
		sb.add_theme_icon_override("down%s" % state, arrow_down)
	var quiet: = StyleBoxEmpty.new()
	var hov: = _track(Color(SECONDARY, 0.3 if dark else 0.14))
	hov.set_corner_radius_all(8)
	var prs: = _track(Color(SECONDARY, 0.45 if dark else 0.25))
	prs.set_corner_radius_all(8)
	for side in ["up", "down"]:
		sb.add_theme_stylebox_override("%s_background" % side, quiet)
		sb.add_theme_stylebox_override("%s_background_disabled" % side, quiet)
		sb.add_theme_stylebox_override("%s_background_hovered" % side, hov)
		sb.add_theme_stylebox_override("%s_background_pressed" % side, prs)


static func _sized_icon(name: String, px: int, white: = false) -> Texture2D:
	var img: = icon(name, white).get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.resize(px, px, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)

static func style_progress(pb: ProgressBar) -> void :
	pb.add_theme_stylebox_override("background", _track(sunk()))
	pb.add_theme_stylebox_override("fill", _track(PRIMARY))
	pb.show_percentage = false
	pb.custom_minimum_size.y = 14

static func style_scroll(sb: ScrollBar) -> void :
	var rail: = StyleBoxEmpty.new()
	sb.add_theme_stylebox_override("scroll", rail)


	sb.add_theme_stylebox_override("grabber", _track(Color(SECONDARY, 0.65)))
	sb.add_theme_stylebox_override("grabber_highlight", _track(SECONDARY))
	sb.add_theme_stylebox_override("grabber_pressed", _track(SECONDARY))
	sb.custom_minimum_size.x = 8









const DEFAULT_PACK: = "res://game/ui/style/default_ui_sfx.tres"
static var pack: UiSfxPack = null
static var _sfx_pool: Array = []
static var _sfx_next: = 0
static var _sfx_last: = {}




static func sfx(role: String, pitch: = 0.0, pick: = -1) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		return




	var now: = Time.get_ticks_msec()
	var min_gap: = 45 if role == "hover" else (18 if role == "coin" else 80)
	if now - int(_sfx_last.get(role, -9999)) < min_gap:
		return
	_sfx_last[role] = now
	if pack == null:
		if not ResourceLoader.exists(DEFAULT_PACK):
			return
		pack = load(DEFAULT_PACK) as UiSfxPack
		if pack == null:
			return
	var streams: = pack.streams(role)
	if streams.is_empty():
		return
	if _sfx_pool.is_empty() or not is_instance_valid(_sfx_pool[0]):
		_sfx_pool = []


		for i in 12:
			var p: = AudioStreamPlayer.new()
			p.bus = "Master"
			tree.root.add_child(p)
			_sfx_pool.append(p)
	var player: AudioStreamPlayer = _sfx_pool[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_pool.size()
	player.stream = streams[clampi(pick, 0, streams.size() - 1)] if pick >= 0 else streams[randi() % streams.size()]
	player.volume_db = pack.volume(role)
	player.pitch_scale = pitch if pitch > 0.0 else randf_range(0.97, 1.03)
	player.play()


static func hover_sound(c: Control) -> void :
	var h: = sfx.bind("hover")
	if not c.mouse_entered.is_connected(h):
		c.mouse_entered.connect(h)












static func style_tabs(tc: TabContainer, on_field: = false) -> void :
	tc.add_theme_stylebox_override("panel", card_box(_AUTO, RADIUS_SOFT))
	tc.add_theme_stylebox_override("tabbar_background", StyleBoxEmpty.new())
	var sel: = flat_box(SECONDARY, CAPSULE)
	sel.content_margin_left = 22.0
	sel.content_margin_right = 22.0
	sel.content_margin_top = 7.0
	sel.content_margin_bottom = 8.0
	tc.add_theme_stylebox_override("tab_selected", sel)
	tc.add_theme_stylebox_override("tab_focus", StyleBoxEmpty.new())
	var idle: = Color(1, 1, 1, 0.55) if on_field and not dark else\
	(Color(1, 1, 1, 0.06) if dark else Color(text(), 0.06))
	var uns: StyleBoxFlat = sel.duplicate()
	uns.bg_color = idle
	tc.add_theme_stylebox_override("tab_unselected", uns)
	var hov: StyleBoxFlat = sel.duplicate()
	hov.bg_color = Color(1, 1, 1, 0.8) if on_field and not dark else Color(SECONDARY, 0.18)
	tc.add_theme_stylebox_override("tab_hovered", hov)
	tc.add_theme_constant_override("tab_separation", 10)
	tc.add_theme_constant_override("side_margin", 0)
	tc.add_theme_font_override("font", font(FONT_BLACK))
	tc.add_theme_font_size_override("font_size", 17)
	var idle_txt: = Color("7a5a00") if on_field and not dark else muted()
	tc.add_theme_color_override("font_selected_color", Color.WHITE)
	tc.add_theme_color_override("font_unselected_color", idle_txt)
	tc.add_theme_color_override("font_hovered_color", idle_txt.darkened(0.2) if not dark else text())

static func wash(root: Node) -> void :
	for c in root.find_children("*", "Control", true, false):


		if _washless(c, root):
			continue
		if c is TabContainer:
			style_tabs(c)
		elif c is PanelContainer:
			style_panel(c)
		elif c is OptionButton:
			style_option(c)
		elif c is CheckBox:
			style_check(c)
		elif c is SpinBox:
			style_spin(c)
		elif c is Button:
			var b: = c as Button
			if b.has_meta("icon_button"):
				continue
			var size: = b.get_theme_font_size("font_size")
			style_button(b, "secondary", clampi(size, 14, 22))
		elif c is LineEdit:
			style_line_edit(c)
		elif c is HSlider or c is VSlider:
			style_slider(c)
		elif c is ProgressBar:
			style_progress(c)
		elif c is ScrollContainer:
			style_scroll((c as ScrollContainer).get_v_scroll_bar())
		elif c is Label:
			var l: = c as Label
			var keep: = l.get_theme_font_size("font_size")
			var col: Color = l.get_theme_color("font_color")
			l.add_theme_font_override("font", 
				font(FONT_XBOLD if keep >= 22 else FONT_SEMI))


			if col.is_equal_approx(Color.WHITE) or col.is_equal_approx(
				Color(0.875, 0.875, 0.875)):
				l.add_theme_color_override("font_color", text())

static func _washless(c: Node, root: Node) -> bool:
	var n: = c
	while n != null and n != root:
		if n.has_meta("no_wash"):
			return true
		n = n.get_parent()
	return false





static func pop_in(c: Control, delay: = 0.0) -> void :
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2.ONE * 0.85
	c.modulate.a = 0.0
	var t: = c.create_tween().set_parallel(true)
	t.tween_property(c, "scale", Vector2.ONE, 0.28)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	t.tween_property(c, "modulate:a", 1.0, 0.16).set_delay(delay)






static func stagger_reveal(box: Node, step: = 0.05, skip: = 0, ticks: = true) -> void :


	if not STAGGER_ON:
		return
	var i: = 0
	for child in box.get_children():
		var c: = child as Control
		if c == null:
			continue
		if i < skip:
			i += 1
			continue
		c.offset_transform_enabled = true
		c.offset_transform_position.y = 30.0
		c.modulate.a = 0.0
		var d: = step * float(i - skip)
		var t: = c.create_tween().set_parallel(true)
		t.tween_property(c, "modulate:a", 1.0, 0.16).set_delay(d)
		t.tween_property(c, "offset_transform_position:y", 0.0, 0.32)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(d)

		if ticks:
			t.tween_callback(sfx.bind("hover")).set_delay(d)
		i += 1

static func press_bounce(c: Control) -> void :



	c.offset_transform_enabled = true
	c.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	var t: = c.create_tween()
	t.tween_property(c, "offset_transform_scale", Vector2(0.9, 0.85), 0.06)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "offset_transform_scale", Vector2.ONE, 0.24)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)







static var _toast_stack: Array = []


static var vote_pill_open: = false
static func flash_toast(title: String, body: String, accent: = SUCCESS, 
		icon_name: = "information", hold: = 5.0) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 130
	var panel: = toast(title, body, accent, icon_name)

	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.position.y = (156 if vote_pill_open else 100) + _toast_stack.size() * 86
	layer.add_child(panel)
	tree.root.add_child(layer)
	_toast_stack.append(layer)
	panel.modulate.a = 0.0
	var start_y: = panel.position.y
	panel.position.y -= 18
	var tw: = panel.create_tween().set_ease(Tween.EASE_OUT)
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.22)
	tw.tween_property(panel, "position:y", start_y, 0.28)
	tw.chain().tween_interval(hold)
	tw.chain().tween_property(panel, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback( func():
		_toast_stack.erase(layer)
		layer.queue_free())
	sfx("open")




static func flash_pill(text: String, accent: = SUCCESS, icon_name: = "information", 
		hold: = 4.0) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 130
	var pill: = PanelContainer.new()
	var cb: = card_box(Color(card(), 0.97), 99)
	cb.content_margin_left = 12.0
	cb.content_margin_right = 18.0
	cb.content_margin_top = 7.0
	cb.content_margin_bottom = 7.0
	pill.add_theme_stylebox_override("panel", cb)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	pill.add_child(row)
	var disc: = TextureRect.new()
	disc.texture = _disc_tex(56, accent, Color(0, 0, 0, 0), 0.0, false, icon(icon_name, true))
	disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	disc.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	disc.custom_minimum_size = Vector2(24, 24)
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(disc)
	var lbl: = Label.new()
	lbl.text = text
	style_label(lbl, "small")
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lbl)
	pill.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	pill.position.y = (148 if vote_pill_open else 92) + _toast_stack.size() * 52
	layer.add_child(pill)
	tree.root.add_child(layer)
	_toast_stack.append(layer)
	pill.modulate.a = 0.0
	var start_y: = pill.position.y
	pill.position.y -= 14
	var tw: = pill.create_tween().set_ease(Tween.EASE_OUT)
	tw.set_parallel(true)
	tw.tween_property(pill, "modulate:a", 1.0, 0.2)
	tw.tween_property(pill, "position:y", start_y, 0.26)
	tw.chain().tween_interval(hold)
	tw.chain().tween_property(pill, "modulate:a", 0.0, 0.35)
	tw.chain().tween_callback( func():
		_toast_stack.erase(layer)
		layer.queue_free())
	sfx("open")

static func toast(title: String, body: String, accent: = SUCCESS, 
		icon_name: = "information") -> Control:
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", card_box())
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var disc: = TextureRect.new()
	disc.texture = _disc_tex(88, accent, Color(0, 0, 0, 0), 0.0, 
		false, icon(icon_name, true))
	disc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	disc.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	disc.custom_minimum_size = Vector2(44, 44)
	h.add_child(disc)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 1)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var t: = Label.new()
	t.text = title
	style_label(t, "title")
	t.add_theme_font_size_override("font_size", 17)
	var d: = Label.new()
	d.text = body
	style_label(d, "small")
	v.add_child(t)
	v.add_child(d)
	h.add_child(v)
	panel.add_child(h)
	return panel







static var active_dialog: CanvasLayer = null
static var _dialog_btns: Array = []
static var _dialog_cd: = 0.0

static func dialog_active() -> bool:
	return active_dialog != null and is_instance_valid(active_dialog)



static func drive_dialog(delta: float) -> void :
	_dialog_cd = maxf(_dialog_cd - delta, 0.0)
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var vp: = tree.root
	if LocalPlayers.ui_just_pressed("ui_cancel"):
		sfx("close")
		active_dialog.queue_free()
		return
	if LocalPlayers.ui_just_pressed("ui_accept"):
		var foc: = vp.gui_get_focus_owner()
		if foc is BaseButton and not (foc as BaseButton).disabled:
			(foc as BaseButton).pressed.emit()
		return
	if _dialog_cd <= 0.0 and (LocalPlayers.ui_just_pressed("ui_left")\
	or LocalPlayers.ui_just_pressed("ui_right")):
		_dialog_cd = 0.18
		var foc: = vp.gui_get_focus_owner()
		var i: = _dialog_btns.find(foc)
		if i == -1:
			i = 0
		var other: Control = _dialog_btns[(i + 1) % _dialog_btns.size()]
		other.grab_focus()
		sfx("hover")

static func confirm(parent: Node, title: String, body: String, 
		on_yes: Callable, yes_text: = "yes", no_text: = "cancel", 
		yes_kind: = "danger", hold_seconds: = 0.0) -> void :



	var layer: = CanvasLayer.new()
	layer.layer = 95
	parent.add_child(layer)
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.45)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(scrim)
	var card: = PanelContainer.new()
	style_panel(card, _AUTO, RADIUS_SOFT)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	var t: = Label.new()
	t.text = title
	style_label(t, "title")
	v.add_child(t)
	if body != "":
		var d: = Label.new()
		d.text = body
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size.x = 300
		style_label(d, "body")
		v.add_child(d)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var no: = Button.new()
	no.text = no_text
	style_button(no, "tertiary", 16)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(layer.queue_free)
	row.add_child(no)
	var yes: = Button.new()
	yes.text = yes_text
	style_button(yes, yes_kind, 16)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.pressed.connect( func():
		layer.queue_free()
		on_yes.call())
	row.add_child(yes)
	if hold_seconds > 0.0:


		yes.disabled = true
		var start: = int(ceil(hold_seconds))
		yes.text = "%s (%d)" % [yes_text, start]
		var timer: = Timer.new()
		timer.wait_time = 1.0
		timer.set_meta("remain", start)
		layer.add_child(timer)
		timer.timeout.connect( func():
			var r: = int(timer.get_meta("remain")) - 1
			timer.set_meta("remain", r)
			if r <= 0:
				yes.disabled = false
				yes.text = yes_text
				timer.stop()
			else:
				yes.text = "%s (%d)" % [yes_text, r])
		timer.start()
	v.add_child(row)
	card.add_child(v)
	layer.add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	scrim.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			sfx("close")
			layer.queue_free())


	active_dialog = layer
	_dialog_btns = [no, yes]
	layer.tree_exiting.connect( func():
		if active_dialog == layer:
			active_dialog = null
			_dialog_btns = [])
	no.focus_neighbor_right = no.get_path_to(yes)
	yes.focus_neighbor_left = yes.get_path_to(no)
	no.grab_focus.call_deferred()
	sfx("open")

	(Engine.get_main_loop() as SceneTree).process_frame.connect(
		func(): pop_in(card), CONNECT_ONE_SHOT)



static func icon_disc(icon_name: String, fill: Color, px: = 52, 
		glyph_white: = true) -> Texture2D:
	return _disc_tex(px * 2, fill, Color(0, 0, 0, 0), 0.0, false, 
		icon(icon_name, glyph_white))




static func sticker(icon_name: String, fill: Color, px: = 52, rot: = -0.07, 
		glyph: = Color.WHITE) -> Control:
	var holder: = Control.new()
	holder.custom_minimum_size = Vector2(px, px)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sq: = Panel.new()
	var inset: = px * 0.06
	sq.position = Vector2(inset, inset)
	sq.size = Vector2(px, px) - Vector2(inset, inset) * 2.0
	sq.pivot_offset = sq.size * 0.5
	sq.rotation = rot
	sq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sq.add_theme_stylebox_override("panel", flat_box(fill, int(px * 0.28)))
	holder.add_child(sq)
	var g: = TextureRect.new()
	g.texture = icon(icon_name, true)
	g.modulate = glyph
	g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var gs: = sq.size.x * 0.56
	g.size = Vector2(gs, gs)
	g.position = (sq.size - g.size) * 0.5
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sq.add_child(g)
	return holder





static func rail_panel(host: Control, width: float) -> VBoxContainer:
	var rail: = Panel.new()
	rail.name = "Rail"
	rail.anchor_bottom = 1.0
	rail.offset_right = width
	rail.add_theme_stylebox_override("panel", flat_box(SECONDARY, 0))
	host.add_child(rail)
	UiBackdrop.doodles(rail, Color(1, 1, 1, 0.07), 0.0)
	var col: = VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 10.0
	col.offset_right = -10.0
	col.offset_top = 14.0
	col.offset_bottom = -14.0
	col.add_theme_constant_override("separation", 6)
	rail.add_child(col)
	return col

static func rail_tile(label: String, glyph: Texture2D) -> Button:
	var b: = Button.new()
	b.text = label
	b.icon = glyph
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	b.add_theme_constant_override("icon_max_width", 34)
	b.add_theme_constant_override("h_separation", 2)
	b.add_theme_font_override("font", font(FONT_BLACK))
	b.add_theme_font_size_override("font_size", 13)
	b.clip_text = true

	b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	b.pressed.connect(press_bounce.bind(b))
	b.pressed.connect(sfx.bind("press"))
	hover_sound(b)
	return b

static func paint_rail_tile(b: Button, lit: bool) -> void :
	var on: = flat_box(card(), 18)
	var hov: = flat_box(Color(1, 1, 1, 0.14), 18)
	var off: = StyleBoxEmpty.new()
	for sb in [on, hov, off]:
		sb.content_margin_top = 10.0
		sb.content_margin_bottom = 8.0
	b.add_theme_stylebox_override("normal", on if lit else off)
	b.add_theme_stylebox_override("hover", on if lit else hov)
	b.add_theme_stylebox_override("pressed", on)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


	var dot: = b.get_node_or_null(^"LitDot") as Panel
	if dot == null:
		dot = Panel.new()
		dot.name = "LitDot"
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var dsb: = flat_box(PRIMARY, CAPSULE)
		dsb.set_border_width_all(3)
		dsb.border_color = card()
		dot.add_theme_stylebox_override("panel", dsb)
		dot.anchor_left = 1.0
		dot.anchor_right = 1.0
		dot.offset_left = -21.0
		dot.offset_right = -3.0
		dot.offset_top = 3.0
		dot.offset_bottom = 21.0
		b.add_child(dot)
	dot.visible = lit
	var c: = SECONDARY if lit else Color.WHITE
	if lit and dark:
		c = SECONDARY.lightened(0.3)
	for st in ["font_color", "font_hover_color", "font_pressed_color", 
			"font_hover_pressed_color", "font_focus_color", 
			"icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, c)






static func rail_width(size: String) -> float:
	return 74.0 if size == "short" else 78.0

static func slim_rail(col: Control, size: String) -> void :
	var side: = 3.0 if size == "short" else 6.0
	col.offset_left = side
	col.offset_right = - side
	col.offset_top = 8.0
	col.offset_bottom = -8.0
	col.add_theme_constant_override("separation", 4)

static func slim_rail_tile(b: Button, size: String) -> void :
	b.add_theme_constant_override("icon_max_width", 
		22 if size == "short" else (34 if size == "tall" else 28))
	b.add_theme_font_size_override("font_size", 10 if size == "short" else 11)

static func repaint_slim_tile(b: Button, size: String) -> void :
	for st in ["normal", "hover", "pressed"]:
		var sb: = b.get_theme_stylebox(st)
		if sb != null:
			sb.content_margin_top = 4.0 if size == "short" else 6.0
			sb.content_margin_bottom = 3.0 if size == "short" else 4.0
			sb.content_margin_left = 1.0
			sb.content_margin_right = 1.0
	var dot: = b.get_node_or_null(^"LitDot") as Control
	if dot != null:
		dot.offset_left = -15.0
		dot.offset_right = -2.0
		dot.offset_top = 2.0
		dot.offset_bottom = 15.0


static func paint_field_tab(b: Button, lit: bool, fs: = 15) -> void :
	style_button(b, "blue" if lit else "secondary", fs)
	if lit:
		return
	var idle: = Color(1, 1, 1, 0.06) if dark else Color(1, 1, 1, 0.55)
	var hov: = Color(1, 1, 1, 0.12) if dark else Color(1, 1, 1, 0.85)
	for st in ["normal", "hover", "pressed"]:
		var sb: = _slab(hov if st != "normal" else idle, Color(0, 0, 0, 0), false)
		sb.content_margin_left = 16.0
		sb.content_margin_right = 16.0
		b.add_theme_stylebox_override(st, sb)
	var t: = Color(1, 1, 1, 0.65) if dark else Color("7a5a00")
	for st in ["font_color", "font_hover_color", "font_pressed_color", 
			"font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(st, t)


static func paint_sunk_chip(b: Button, glyph: String) -> void :
	for st in ["normal", "hover", "pressed"]:
		b.add_theme_stylebox_override(st, _slab(sunk() if st == "normal"
			else sunk().darkened(0.06), Color(0, 0, 0, 0), false))
	b.icon = icon(glyph, true)
	b.add_theme_constant_override("icon_max_width", 18)
	b.add_theme_constant_override("h_separation", 8)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for st in ["font_color", "font_hover_color", "font_pressed_color", 
			"font_hover_pressed_color", "font_focus_color", 
			"icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, muted())




static func paint_viewer_btn(b: Button, glyph: String, fs: = 16) -> void :
	style_button(b, "secondary", fs)
	b.icon = icon(glyph, true)
	b.add_theme_constant_override("icon_max_width", 20)
	b.add_theme_constant_override("h_separation", 8)
	var c: = SECONDARY.lightened(0.25) if dark else SECONDARY
	for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, c)


static func field_box(radius: = 30) -> StyleBoxFlat:
	return flat_box(Color("2a2a30") if dark else PRIMARY, radius)



static func field_ink() -> Color:
	return Color("c3c3cc") if dark else Color("7a5a00")

static func field_doodles(host: Control) -> void :
	UiBackdrop.doodles(host, Color(1, 1, 1, 0.04) if dark else Color(1, 1, 1, 0.3))




static func hover_grow(c: Control, amt: = 1.08) -> void :
	if c.has_meta("hover_grow"):
		return
	c.set_meta("hover_grow", true)
	c.offset_transform_enabled = true
	c.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	c.mouse_entered.connect(_grow_to.bind(c, amt, 1))
	c.mouse_exited.connect(_grow_to.bind(c, 1.0, 0))

static func _grow_to(c: Control, s: float, z: int) -> void :
	if not is_instance_valid(c):
		return
	c.z_index = z
	var tw: = c.create_tween()
	tw.tween_property(c, "offset_transform_scale", Vector2.ONE * s, 0.14)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)





const COIN: = Color(0.96, 0.78, 0.16)
const COIN_EDGE: = Color(0.74, 0.55, 0.05)







const CHIP: = Color("3fd46a")
const CHIP_DEEP: = Color("1d8a43")





const CHIP_ICON: = "res://game/images/currency/chip.png"
static var _chip_icon: Texture2D = null
static var _chip_icon_looked: = false

static func coin_tex(px: = 24) -> Texture2D:
	if not _chip_icon_looked:
		_chip_icon_looked = true
		if ResourceLoader.exists(CHIP_ICON):
			var res: Resource = load(CHIP_ICON)
			if res is Texture2D:
				_chip_icon = res
			elif res is Image:
				_chip_icon = ImageTexture.create_from_image(res)
		elif FileAccess.file_exists(CHIP_ICON):

			var img: = Image.load_from_file(ProjectSettings.globalize_path(CHIP_ICON))
			if img != null:
				_chip_icon = ImageTexture.create_from_image(img)
	if _chip_icon != null:
		return _chip_icon
	return _gem_tex(px * 3)























const KIT_ICON_DIR: = "res://game/images/kits/"
const KIT_ICON_LAYERS: = {
	"kit": ["kit_jersey", "kit_shorts", "kit_trim", "kit_number", "kit_shade", "kit_ink"], 
	"pinny": ["pinny_tee", "pinny_bib", "pinny_edge", "pinny_number", "pinny_shade", "pinny_ink"], 
}
const KIT_PINNY_TEE: = Color(0.82, 0.83, 0.86)
static var _kit_layers: = {}



static func kit_layers(set_name: = "kit") -> Array:
	if _kit_layers.has(set_name):
		return _kit_layers[set_name]
	var out: Array = []
	for stem in KIT_ICON_LAYERS.get(set_name, []):
		var path: String = KIT_ICON_DIR + String(stem) + ".png"
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			var res: Resource = load(path)
			if res is Texture2D:
				tex = res
		elif FileAccess.file_exists(path):

			var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
			if img != null:
				img.generate_mipmaps()
				tex = ImageTexture.create_from_image(img)
		if tex == null:
			out = []
			break
		out.append(tex)
	_kit_layers[set_name] = out
	return out





const GEM_RIM: = Color("145c2e")
const GEM_LIGHT: = Color("a6f7b4")
const GEM_MID: = Color("3fd46a")
const GEM_SIDE: = Color("2bb456")
const GEM_DARK: = Color("1d8a43")
static var _gem_cache: = {}

static func _gem_tex(size_out: int) -> Texture2D:
	var kept: Variant = _gem_cache.get(size_out)
	if kept != null:
		return kept
	var size: = maxi(size_out, 8) * 3
	var img: = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c: = (size - 1) * 0.5
	var hw: = size * 0.5 - 2.0
	var hh: = hw
	var apothem: = hw * hh / sqrt(hw * hw + hh * hh)
	var rim_px: = apothem * 0.2
	var table: = 0.42
	for y in size:
		for x in size:
			var dx: = (x - c) / hw
			var dy: = (y - c) / hh
			var d: = absf(dx) + absf(dy)
			var edge_px: = (1.0 - d) * apothem
			var a: = clampf(edge_px + 0.5, 0.0, 1.0)
			if a <= 0.0:
				continue
			var col: Color
			if d <= table:
				col = GEM_MID
			elif dx <= 0.0 and dy <= 0.0:
				col = GEM_LIGHT
			elif dx > 0.0 and dy > 0.0:
				col = GEM_DARK
			else:
				col = GEM_SIDE

			col = col.lerp(GEM_RIM, clampf(rim_px - edge_px + 0.5, 0.0, 1.0))
			col.a = a
			img.set_pixel(x, y, col)

	var gx: = c - hw * 0.34
	var gy: = c - hh * 0.3
	var gr: = size * 0.07
	for y in range(int(gy - gr) - 1, int(gy + gr) + 2):
		for x in range(int(gx - gr) - 1, int(gx + gr) + 2):
			if x < 0 or y < 0 or x >= size or y >= size:
				continue
			var k: = clampf(gr - Vector2(x - gx, y - gy).length() + 0.5, 0.0, 1.0)
			if k <= 0.0:
				continue
			var base: = img.get_pixel(x, y)
			if base.a <= 0.0:
				continue
			img.set_pixel(x, y, Color(base.lerp(Color.WHITE, k * 0.9), base.a))
	img.resize(size_out, size_out, Image.INTERPOLATE_LANCZOS)
	var tex: = ImageTexture.create_from_image(img)
	_gem_cache[size_out] = tex
	return tex

static func coin_disc(px: = 20) -> TextureRect:



	var tr: = TextureRect.new()
	tr.texture = coin_tex(px)
	tr.custom_minimum_size = Vector2(px, px)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


static func commafy(n: int) -> String:
	var s: = str(absi(n))
	var out: = ""
	var c: = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if n < 0 else "") + out



static func currency_chip(amount: = 0, tier: = "body", px: = 20) -> HBoxContainer:
	var box: = HBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(coin_disc(px))
	var lbl: = Label.new()
	style_label(lbl, tier)
	lbl.text = commafy(amount)
	box.add_child(lbl)
	box.set_meta("value", lbl)
	return box


static func set_currency(chip: HBoxContainer, amount: int) -> void :
	var lbl: = (chip.get_meta("value") if chip.has_meta("value") else null) as Label
	if lbl != null:
		lbl.text = commafy(amount)
















const CHIP_COINS_MIN: = 3
const CHIP_COINS_MAX: = 40

static func chip_fly(from: Vector2, purse: Control, amount: int, 
		on_land: = Callable(), on_done: = Callable()) -> float:
	var tree: = Engine.get_main_loop() as SceneTree
	if amount <= 0 or tree == null or tree.root == null:
		if on_done.is_valid():
			on_done.call()
		return 0.0
	var count: = clampi(int(round(sqrt(float(amount)) * 1.5)), CHIP_COINS_MIN, CHIP_COINS_MAX)
	count = mini(count, amount)
	var pace: = clampf(float(count - CHIP_COINS_MIN) / float(CHIP_COINS_MAX - CHIP_COINS_MIN), 0.0, 1.0)
	var gap: = lerpf(0.085, 0.02, pace)
	var flight: = lerpf(0.62, 0.32, pace)
	var hang: = lerpf(0.2, 0.07, pace)
	const POP: = 0.24
	var layer: = CanvasLayer.new()
	layer.layer = 131
	var host: = Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(host)
	tree.root.add_child(layer)

	var tag: = Label.new()
	tag.text = "+%s" % commafy(amount)
	tag.add_theme_font_override("font", font(FONT_BLACK))
	tag.add_theme_font_size_override("font_size", 24)
	tag.add_theme_color_override("font_color", CHIP)
	tag.add_theme_color_override("font_outline_color", Color.WHITE)
	tag.add_theme_constant_override("outline_size", 8)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tag)
	tag.reset_size()
	tag.position = from - tag.size * 0.5 + Vector2(0.0, -18.0)
	var tt: = host.create_tween().set_parallel(true)
	tt.tween_property(tag, "position:y", tag.position.y - 54.0, 0.9)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tt.tween_property(tag, "modulate:a", 0.0, 0.3).set_delay(0.6)
	var tex: = coin_tex(24)
	var left: = [count]
	var base: = amount / count
	var extra: = amount % count
	for i in count:
		var share: = base + (1 if i < extra else 0)
		var px: = randf_range(20.0, 27.0)
		var coin: = TextureRect.new()
		coin.texture = tex
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.size = Vector2(px, px)
		coin.pivot_offset = coin.size * 0.5
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coin.position = from - coin.size * 0.5
		coin.scale = Vector2.ZERO


		coin.rotation = randf_range( - PI, PI)
		var spin: = randf_range(-7.0, 7.0)
		host.add_child(coin)

		var out: = Vector2.from_angle(randf_range( - PI, 0.0) + randf_range(-0.5, 0.5))\
		* randf_range(34.0, 104.0)
		var rest: = from + out - coin.size * 0.5
		var leave: = float(i) * gap
		var t: = host.create_tween()
		t.tween_interval(leave)
		t.tween_property(coin, "scale", Vector2.ONE, 0.1)
		t.parallel().tween_property(coin, "position", rest, POP)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(coin, "rotation", coin.rotation + spin * (POP + hang), POP + hang)
		t.tween_interval(hang)

		var pitch: = lerpf(0.92, 1.36, float(i) / float(maxi(1, count - 1)))
		t.tween_method(_chip_pull.bind(coin, rest, purse, randf_range(-0.34, 0.34), 
			coin.rotation + spin * (POP + hang), spin * flight), 0.0, 1.0, flight)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_callback(_chip_land.bind(coin, purse, share, pitch, on_land, on_done, left, layer))
	return POP + hang + flight + float(count - 1) * gap



static func _chip_pull(k: float, coin_in: Variant, start: Vector2, purse_in: Variant, bow: float, 
		turn0: = 0.0, turn: = 0.0) -> void :
	if not is_instance_valid(coin_in):
		return
	var coin: Control = coin_in
	var to: = start
	if is_instance_valid(purse_in) and (purse_in as Control).is_inside_tree():
		var purse: Control = purse_in
		to = purse.global_position + purse.size * 0.5 - coin.size * 0.5
	var mid: = start.lerp(to, 0.5) + (to - start).orthogonal() * bow
	coin.position = start.lerp(mid, k).lerp(mid.lerp(to, k), k)
	coin.scale = Vector2.ONE * lerpf(1.0, 0.62, k)
	coin.rotation = turn0 + turn * k

static func _chip_land(coin_in: Variant, purse_in: Variant, share: int, pitch: float, 
		on_land: Callable, on_done: Callable, left: Array, layer_in: Variant) -> void :
	if is_instance_valid(coin_in):
		(coin_in as Node).queue_free()
	sfx("coin", pitch)
	if on_land.is_valid():
		on_land.call(share)
	var purse: Control = purse_in if is_instance_valid(purse_in) else null
	var layer: Node = layer_in if is_instance_valid(layer_in) else null
	if is_instance_valid(purse) and purse.is_inside_tree():

		purse.offset_transform_enabled = true
		purse.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
		purse.offset_transform_scale = Vector2.ONE * 1.32
		var old: Variant = purse.get_meta("chip_bump") if purse.has_meta("chip_bump") else null
		if old is Tween and (old as Tween).is_valid():
			(old as Tween).kill()
		var b: = purse.create_tween()
		b.tween_property(purse, "offset_transform_scale", Vector2.ONE, 0.16)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		purse.set_meta("chip_bump", b)
	left[0] = int(left[0]) - 1
	if int(left[0]) > 0:
		return

	if is_instance_valid(purse) and purse.is_inside_tree():
		click_burst(purse, COIN)
	if on_done.is_valid():
		on_done.call()
	if is_instance_valid(layer):

		var tree: = layer.get_tree()
		if tree != null:
			tree.create_timer(0.6).timeout.connect(layer.queue_free)
		else:
			layer.queue_free()







static func chip_spend(purse: Control, amount: int, readout: Label = null, 
		from_coins: = 0, to_coins: = 0) -> float:
	var tree: = Engine.get_main_loop() as SceneTree
	if amount <= 0 or tree == null or tree.root == null or purse == null\
	or not purse.is_inside_tree():
		if readout != null:
			readout.text = commafy(to_coins)
		return 0.0
	var count: = clampi(int(round(sqrt(float(amount)) * 1.5)), CHIP_COINS_MIN, CHIP_COINS_MAX)
	count = mini(count, amount)
	var pace: = clampf(float(count - CHIP_COINS_MIN) / float(CHIP_COINS_MAX - CHIP_COINS_MIN), 0.0, 1.0)
	var gap: = lerpf(0.075, 0.018, pace)
	var drain: = float(count - 1) * gap + 0.12
	var layer: = CanvasLayer.new()
	layer.layer = 131
	var host: = Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(host)
	tree.root.add_child(layer)
	var from: = purse.global_position + purse.size * 0.5
	var screen_h: = host.get_viewport_rect().size.y

	if readout != null:
		var rt: = readout.create_tween()
		rt.tween_method( func(v: float): readout.text = commafy(int(round(v))), 
			float(from_coins), float(to_coins), drain).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	purse.offset_transform_enabled = true
	purse.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	var sh: = purse.create_tween()
	var steps: = maxi(4, int(drain / 0.045))
	for i in steps:
		var k: = 1.0 - float(i) / float(steps)
		sh.tween_property(purse, "offset_transform_position", 
			Vector2(randf_range(-5.0, 5.0), randf_range(-2.5, 2.5)) * (0.4 + 0.6 * k), 0.045)
	sh.tween_property(purse, "offset_transform_position", Vector2.ZERO, 0.06)

	var tag: = Label.new()
	tag.text = "-%s" % commafy(amount)
	tag.add_theme_font_override("font", font(FONT_BLACK))
	tag.add_theme_font_size_override("font_size", 22)
	tag.add_theme_color_override("font_color", CHIP)
	tag.add_theme_color_override("font_outline_color", Color.WHITE)
	tag.add_theme_constant_override("outline_size", 8)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tag)
	tag.reset_size()
	tag.position = from - tag.size * 0.5 + Vector2(0.0, purse.size.y * 0.5 + 6.0)
	var tt: = host.create_tween().set_parallel(true)
	tt.tween_property(tag, "position:y", tag.position.y + 40.0, 0.9)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tt.tween_property(tag, "modulate:a", 0.0, 0.3).set_delay(0.7)

	var tex: = coin_tex(24)
	var longest: = 0.0
	for i in count:
		var px: = randf_range(20.0, 28.0)
		var chip: = TextureRect.new()
		chip.texture = tex
		chip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		chip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		chip.size = Vector2(px, px)
		chip.pivot_offset = chip.size * 0.5
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.position = from - chip.size * 0.5
		chip.scale = Vector2.ZERO
		host.add_child(chip)
		var v: = Vector2(randf_range(-320.0, 220.0), randf_range(-520.0, -200.0))
		const G: = 1700.0

		var drop: = screen_h + px - chip.position.y
		var fall: = ( - v.y + sqrt(v.y * v.y + 2.0 * G * drop)) / G
		var leave: = float(i) * gap
		longest = maxf(longest, leave + fall)
		var spin: = randf_range(-9.0, 9.0)
		var pitch: = lerpf(1.3, 0.8, float(i) / float(maxi(1, count - 1)))
		var t: = host.create_tween()
		t.tween_interval(leave)
		t.tween_callback( func(): sfx("coin", pitch))
		t.tween_property(chip, "scale", Vector2.ONE, 0.08)
		t.parallel().tween_method(_chip_drop.bind(chip, chip.position, v, G, spin), 0.0, fall, fall)
		t.tween_callback(chip.queue_free)
	tree.create_timer(longest + 0.2).timeout.connect( func():
		if is_instance_valid(layer):
			layer.queue_free())
	return drain

static func _chip_drop(t: float, chip_in: Variant, start: Vector2, v: Vector2, g: float, spin: float) -> void :
	if not is_instance_valid(chip_in):
		return
	var chip: Control = chip_in
	chip.position = start + v * t + Vector2(0.0, 0.5 * g * t * t)
	chip.rotation = spin * t




static func stat_row(caption: String, value: String, value_tier: = "title") -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var cap: = Label.new()
	style_label(cap, "small", muted())
	cap.text = caption
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(cap)
	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	var val: = Label.new()
	style_label(val, value_tier)
	val.text = value
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	row.set_meta("value", val)
	return row




static func icon_button(icon_name: String, kind: = "secondary", 
		px: = 42) -> Button:
	var b: = Button.new()
	style_button(b, kind, 16)
	b.icon = icon(icon_name, kind == "danger")
	b.expand_icon = true
	b.custom_minimum_size = Vector2(px, px)



	b.set_meta("icon_button", true)

	for state in ["normal", "hover", "pressed", "focus"]:
		var sb: = b.get_theme_stylebox(state) as StyleBoxFlat
		if sb != null:
			sb.content_margin_left = 9.0
			sb.content_margin_right = 9.0
	return b





static func reset_button(on_reset: Callable) -> Button:
	var b: = icon_button("return", "tertiary", 36)
	b.icon = icon("return", true)
	b.pressed.connect( func():
		click_burst(b, SECONDARY)
		on_reset.call())
	set_reset_lit(b, true)
	return b

static func set_reset_lit(b: Button, lit: bool) -> void :
	var soft: = flat_box(Color(SECONDARY, 0.22 if dark else 0.12), CAPSULE)
	var hov: = flat_box(Color(SECONDARY, 0.32 if dark else 0.2), CAPSULE)
	for sb in [soft, hov]:
		sb.set_content_margin_all(8.0)
	b.add_theme_stylebox_override("normal", soft)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	var calm: = StyleBoxEmpty.new()
	calm.set_content_margin_all(8.0)
	b.add_theme_stylebox_override("disabled", calm)
	var blue: = SECONDARY.lightened(0.25) if dark else SECONDARY
	for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, blue)
	b.add_theme_color_override("icon_disabled_color", 
		Color("3a3a42") if dark else Color("c3cad8"))
	b.disabled = not lit
	b.focus_mode = Control.FOCUS_ALL if lit else Control.FOCUS_NONE





static func click_burst(c: Control, color: = PRIMARY) -> void :
	var p: = CPUParticles2D.new()
	p.one_shot = true
	p.amount = 9
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.spread = 180.0
	p.direction = Vector2(0, -1)
	p.gravity = Vector2(0, 640)
	p.initial_velocity_min = 130.0
	p.initial_velocity_max = 240.0
	p.texture = _disc_tex(10, Color.WHITE)
	p.color = color
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.1
	c.add_child(p)
	p.position = c.get_local_mouse_position()\
	if Rect2(Vector2.ZERO, c.size).has_point(c.get_local_mouse_position())\
	else c.size * 0.5
	p.emitting = true
	p.finished.connect(p.queue_free)







static func color_field(color: Color, on_change: Callable) -> ColorPickerButton:
	var p: = ColorPickerButton.new()
	p.custom_minimum_size = Vector2(80, 34)
	p.edit_alpha = false
	p.color = color
	var cp: = p.get_picker()
	cp.edit_alpha = false
	cp.sliders_visible = false
	cp.color_modes_visible = false
	cp.sampler_visible = false
	cp.hex_visible = true
	cp.presets_visible = false
	cp.picker_shape = ColorPicker.SHAPE_HSV_RECTANGLE



	var pop: = p.get_popup()
	var dress: = func():
		if pop != null:
			pop.add_theme_stylebox_override("panel", 
				card_box(_AUTO, RADIUS))
		cp.add_theme_color_override("font_color", text())
		for node in _under(cp):
			if node is LineEdit:
				style_line_edit(node)
			elif node is Label:
				node.add_theme_color_override("font_color", text())
			elif node is Button:
				style_button(node, "secondary", 14)
		add_hex_paste(cp)
		( func(): add_hex_paste(cp)).call_deferred()
	dress.call()
	if pop != null:
		pop.about_to_popup.connect(dress)

	var last: = [0]
	cp.color_changed.connect( func(_c):
		var now: = Time.get_ticks_msec()
		if now - last[0] > 45:
			last[0] = now
			sfx("scrub"))


	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		p.add_theme_stylebox_override(st, StyleBoxEmpty.new())


	p.self_modulate = Color(1, 1, 1, 0)
	var face: = Panel.new()
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fsb: = StyleBoxFlat.new()
	fsb.bg_color = color
	fsb.set_corner_radius_all(10)

	fsb.set_border_width_all(3)
	fsb.border_color = card()
	face.add_theme_stylebox_override("panel", fsb)
	p.add_child(face)
	p.color_changed.connect( func(c):
		fsb.bg_color = c
		on_change.call(c))
	return p




static func add_hex_paste(cp: ColorPicker) -> void :
	if cp == null or cp.has_meta("jv_paste"):
		return

	var hex: = _find_hex_edit(cp)
	if hex == null:
		return
	cp.set_meta("jv_paste", true)
	var paste: = Button.new()
	paste.text = "paste"
	paste.tooltip_text = "paste a hex colour"
	paste.focus_mode = Control.FOCUS_NONE
	style_button(paste, "secondary", 14)
	paste.pressed.connect( func():
		var t: = DisplayServer.clipboard_get().strip_edges().trim_prefix("#")
		if t.length() in [3, 6] and Color.html_is_valid(t):
			var c: = Color.html(t)
			cp.color = c
			cp.color_changed.emit(c)
			sfx("confirm")
		else:
			sfx("error"))
	hex.get_parent().add_child(paste)

static func _find_hex_edit(n: Node) -> LineEdit:
	if n is LineEdit and not (n.get_parent() is SpinBox) and n.get_parent() is HBoxContainer:
		return n
	for c in n.get_children(true):
		var hit: = _find_hex_edit(c)
		if hit != null:
			return hit
	return null

static func _under(n: Node) -> Array:
	var out: Array = [n]
	for c in n.get_children():
		out.append_array(_under(c))
	return out
