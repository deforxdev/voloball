extends Control


















const TITLES: = preload("res://game/titles/title_catalog.gd")

const TALL: = 1.46
const SIDE: = 0.66
const THICK: = 0.052














const HOLES_SHUT_FROM: = 3
const CURVE_STEPS: = 4




const END_TALL: = 0.6
const END_SMALL: = 0.42
const END_BIG: = 0.86
const END_OUT: = 0.62
const END_TILT: = 0.22
const CLOCK_WRAP: = 3600.0



const CORNER_SMALL: = 0.55
const CORNER_BIG: = 1.0
const CORNER_IN: = 0.18
const CORNER_UP: = 0.1
const CORNER_TILT: = 0.42

static var _font: FontVariation

var hosted: = false

var _plate: Panel
var _moving: ColorRect
var _ends: Array[TextureRect] = []
var _corners: Array[TextureRect] = []
var _letters: _Letters
var _style: = {}
var _px: = 0
var _say: = ""
var _fx: Resource



class _Letters extends Control:
	var words: = ""
	var face: Font
	var px: = 16
	var fg: = Color.WHITE
	var ol: = Color.BLACK
	var thick: = 0
	var steps: = 0
	var lift: = 0.0
	var mode: = ""
	var k0: = 0.5
	var k1: = 0.5
	var now: = 0.0
	var _xs: = PackedFloat32Array()
	var _ws: = PackedFloat32Array()
	var _wide: = 0.0
	var _drawn: = -1
	var _shut: Array = []

	static var _holes: = {}

	func lay_out() -> void :
		_xs.resize(words.length())
		_ws.resize(words.length())
		for i in words.length():
			_xs[i] = face.get_string_size(words.substr(0, i), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			_ws[i] = face.get_string_size(words[i], HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		_wide = face.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x

		_shut.resize(words.length())
		for i in words.length():
			_shut[i] = _holes_of(face, px, words[i]) if thick > 0 and steps >= HOLES_SHUT_FROM else []
		_drawn = -1
		queue_redraw()



	static func _holes_of(font: Font, size: int, letter: String) -> Array:
		var rids: = font.get_rids()
		if rids.is_empty() or letter == "" or letter == " ":
			return []
		var rid: RID = rids[0]
		var key: = "%d:%d:%s" % [rid.get_id(), size, letter]
		if _holes.has(key):
			return _holes[key]
		var out: Array = []
		var ts: = TextServerManager.get_primary_interface()
		var glyph: = ts.font_get_glyph_index(rid, size, letter.unicode_at(0), 0)
		if glyph != 0:
			var shape: Dictionary = ts.font_get_glyph_contours(rid, size, glyph)
			var points: PackedVector3Array = shape.get("points", PackedVector3Array())
			var ends: PackedInt32Array = shape.get("contours", PackedInt32Array())
			var loops: Array = []
			var areas: Array = []
			var from: = 0
			for last in ends:
				var loop: = _loop(points, from, last)
				from = last + 1
				if loop.size() >= 3:
					loops.append(loop)
					areas.append(_area(loop))

			var big: = 0.0
			for a in areas:
				if absf(a) > absf(big):
					big = a
			for i in loops.size():
				if float(areas[i]) * big >= 0.0:
					continue
				var loop: PackedVector2Array = loops[i]
				if not Geometry2D.triangulate_polygon(loop).is_empty():
					out.append(loop)
		_holes[key] = out
		return out



	static func _loop(points: PackedVector3Array, from: int, last: int) -> PackedVector2Array:
		var n: = last - from + 1
		var out: = PackedVector2Array()
		if n < 3:
			return out



		var first: = -1
		for i in n:
			if int(points[from + i].z) == TextServer.CONTOUR_CURVE_TAG_ON:
				first = i
				break
		var at: = Vector2(points[from + first].x, points[from + first].y) if first >= 0\
		else (Vector2(points[last].x, points[last].y) + Vector2(points[from].x, points[from].y)) * 0.5
		out.append(at)
		var k: = 0
		while k < n:
			var a: = points[from + posmod(first + 1 + k, n)]
			var a_at: = Vector2(a.x, a.y)
			var tag: = int(a.z)
			if tag == TextServer.CONTOUR_CURVE_TAG_ON:
				out.append(a_at)
				at = a_at
				k += 1
			elif tag == TextServer.CONTOUR_CURVE_TAG_OFF_CONIC:
				var b: = points[from + posmod(first + 2 + k, n)]
				var to: = Vector2(b.x, b.y)
				if int(b.z) == TextServer.CONTOUR_CURVE_TAG_ON:
					k += 2
				else:
					to = (a_at + to) * 0.5
					k += 1
				for s in range(1, CURVE_STEPS + 1):
					var t: = float(s) / CURVE_STEPS
					out.append(at.lerp(a_at, t).lerp(a_at.lerp(to, t), t))
				at = to
			else:
				var b: = points[from + posmod(first + 2 + k, n)]
				var c: = points[from + posmod(first + 3 + k, n)]
				var b_at: = Vector2(b.x, b.y)
				var to: = Vector2(c.x, c.y)
				for s in range(1, CURVE_STEPS + 1):
					out.append(at.bezier_interpolate(a_at, b_at, to, float(s) / CURVE_STEPS))
				at = to
				k += 3

		if out.size() > 1 and out[out.size() - 1].distance_squared_to(out[0]) < 0.0001:
			out.remove_at(out.size() - 1)
		return out

	static func _area(loop: PackedVector2Array) -> float:
		var sum: = 0.0
		for i in loop.size():
			var a: = loop[i]
			var b: = loop[(i + 1) % loop.size()]
			sum += a.x * b.y - b.x * a.y
		return sum * 0.5



	func _fill_holes(i: int, at: Vector2) -> void :
		if i >= _shut.size():
			return
		for poly in _shut[i]:
			draw_colored_polygon(Transform2D(0.0, at) * (poly as PackedVector2Array), ol)


	func _typed() -> Vector2i:
		var each: = 1.0 / lerpf(3.0, 14.0, k0)
		var typing: = words.length() * each
		var rest: = lerpf(4.0, 16.0, k1)
		var t: = fmod(now, typing + rest)
		if t < typing:
			return Vector2i(int(t / each), 1)

		var since: = t - typing
		return Vector2i(words.length(), 1 if since < 1.6 and int(since / 0.4) % 2 == 0 else 0)


	func _burst() -> int:
		var every: = lerpf(3.4, 0.9, k0)
		var t: = fmod(now, every)
		return int(t * 24.0) + 1 if t < 0.24 else 0


	func step(time: float) -> bool:
		now = time
		var shows: = 0
		match mode:
			"bounce", "wiggle":
				shows = int(now * 60.0)
			"type":
				var typed: = _typed()
				shows = typed.x * 2 + typed.y
			"glitch":
				shows = _burst()
		if shows == _drawn:
			return false
		_drawn = shows
		queue_redraw()
		return true

	func _draw() -> void :
		if words == "" or face == null:
			return
		var ascent: = face.get_ascent(px)
		var origin: = Vector2((size.x - _wide) * 0.5, (size.y - ascent - face.get_descent(px)) * 0.5 + ascent - lift)
		match mode:
			"bounce":
				var pace: = lerpf(3.0, 9.0, k0)
				var hop: = px * lerpf(0.06, 0.22, k1)
				for pass_fill in [false, true]:
					for i in words.length():
						_letter(i, origin + Vector2(_xs[i], - absf(sin(now * pace - i * 0.55)) * hop), pass_fill, fg)
			"wiggle":
				var pace: = lerpf(2.0, 9.0, k0)
				var lean: = lerpf(0.05, 0.28, k1)
				var stray: = px * lerpf(0.02, 0.08, k1)
				var mid: = ascent * 0.36
				for pass_fill in [false, true]:
					for i in words.length():
						var at: = origin + Vector2(_xs[i] + _ws[i] * 0.5, - mid)\
						+ Vector2(sin(now * pace * 1.3 + i * 2.1), cos(now * pace * 0.9 + i * 1.3)) * stray
						draw_set_transform(at, sin(now * pace + i * 1.7) * lean)
						_letter(i, Vector2( - _ws[i] * 0.5, mid), pass_fill, fg)
				draw_set_transform(Vector2.ZERO, 0.0)
			"type":
				var typed: = _typed()
				var out: = words.substr(0, typed.x)
				_string(out, origin, fg)
				if typed.y == 1:
					var x: = _xs[typed.x] if typed.x < words.length() else _wide
					var bar: = Rect2(origin + Vector2(x + px * 0.06, - ascent * 0.74), Vector2(px * 0.12, ascent * 0.8))
					if thick > 0:
						draw_rect(bar.grow(thick * 0.25), ol)
					draw_rect(bar, fg)
			"glitch":
				var frame: = _burst()
				if frame == 0:
					_string(words, origin, fg)
				else:

					var tear: = px * lerpf(0.06, 0.22, k1)
					var jump: = Vector2(sin(frame * 12.9898) * tear, 0.0)
					if thick > 0:
						draw_string_outline(face, origin + jump, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, thick, ol)
						for i in words.length():
							_fill_holes(i, origin + jump + Vector2(_xs[i], 0.0))
					draw_string(face, origin + jump + Vector2( - tear * 0.6, 0.0), words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 
						Color(1.0, 0.2, 0.3, 0.75))
					draw_string(face, origin + jump + Vector2(tear * 0.6, 0.0), words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 
						Color(0.2, 0.95, 1.0, 0.75))
					draw_string(face, origin + jump, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, fg)
			_:
				_string(words, origin, fg)

	func _string(what: String, at: Vector2, colour: Color) -> void :
		if what == "":
			return
		if thick > 0:
			draw_string_outline(face, at, what, HORIZONTAL_ALIGNMENT_LEFT, -1, px, thick, ol)

			for i in what.length():
				_fill_holes(i, at + Vector2(_xs[i], 0.0))
		draw_string(face, at, what, HORIZONTAL_ALIGNMENT_LEFT, -1, px, colour)



	func _letter(i: int, at: Vector2, fill: bool, colour: Color) -> void :
		if fill:
			draw_char(face, at, words[i], px, colour)
		elif thick > 0:
			draw_char_outline(face, at, words[i], px, thick, ol)
			_fill_holes(i, at)

func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate = Panel.new()
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plate)
	_moving = ColorRect.new()
	_moving.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moving.visible = false
	add_child(_moving)
	_letters = _Letters.new()
	_letters.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_letters)
	visible = false
	set_process(false)


static func letters() -> FontVariation:
	if _font == null:
		_font = FontVariation.new()
		_font.base_font = UiStyle.font(UiStyle.FONT_BLACK)
		_font.spacing_glyph = 1
	return _font


static func face_of(style: Dictionary) -> Font:
	var fx: Resource = TITLES.effect(str(style.get("fx", "")))
	var own: Font = TITLES.font(fx.font_path) if fx != null and fx.font_path != "" else null


	if own is FontFile and fx.font_crisp and (own as FontFile).antialiasing != TextServer.FONT_ANTIALIASING_NONE:
		(own as FontFile).antialiasing = TextServer.FONT_ANTIALIASING_NONE
		(own as FontFile).hinting = TextServer.HINTING_NONE
		(own as FontFile).subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return own if own != null else letters()




static func letter_px(style: Dictionary, px: int) -> int:
	var fx: Resource = TITLES.effect(str(style.get("fx", "")))
	if fx == null or fx.font_path == "" or TITLES.font(fx.font_path) == null:
		return px
	return maxi(1, roundi(px * fx.font_scale))




func _ready() -> void :
	if _px > 0:
		show_style(_style, _px, _say)


static func _end_reach(style: Dictionary, px: int) -> float:
	var fx: Resource = TITLES.effect(str(style.get("fx", "")))
	if fx == null or not fx.ends:
		return 0.0
	var tex: Texture2D = TITLES.art(fx.art_path)
	if tex == null:
		return 0.0
	var tall: = ceilf(px * TALL) * _end_tall(style, fx)
	return ceilf(tall * tex.get_width() / float(tex.get_height()) * END_OUT)


static func _end_tall(style: Dictionary, fx: Resource) -> float:
	if fx == null or fx.ends_knob < 0:
		return END_TALL
	return lerpf(END_SMALL, END_BIG, TITLES.knob(style, fx.ends_knob))



static func measure(style: Dictionary, px: int, say: = "") -> Vector2:
	var text: = say if say != "" else TITLES.text_of(style)
	if text == "":
		return Vector2.ZERO
	var wide: = face_of(style).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, letter_px(style, px)).x
	return Vector2(ceilf(wide + px * SIDE * 2.0) + _end_reach(style, px) * 2.0, ceilf(px * TALL))



func show_style(style: Dictionary, px: int, say: = "") -> Vector2:
	_style = style
	_px = px
	_say = say
	var box: = measure(style, px, say)
	_fx = TITLES.effect(str(style.get("fx", ""))) if box != Vector2.ZERO else null
	visible = box != Vector2.ZERO
	if not visible:
		custom_minimum_size = Vector2.ZERO
		set_process(false)
		return box
	custom_minimum_size = box
	size = box
	var bg: = Color(str(style.get("bg", "ffffff")))
	var reach: = _end_reach(style, px)
	var plate: = Rect2(reach, 0.0, box.x - reach * 2.0, box.y)
	var radius: = box.y * 0.5
	var filled: bool = _fx != null and _fx.shader != null
	_plate.visible = not filled
	_moving.visible = filled
	if not filled:
		var flat: = StyleBoxFlat.new()
		flat.bg_color = bg
		flat.set_corner_radius_all(int(radius))
		flat.anti_aliasing_size = 1.0
		_plate.add_theme_stylebox_override("panel", flat)
		_plate.position = plate.position
		_plate.size = plate.size
	else:
		var mat: = _moving.material as ShaderMaterial
		if mat == null:
			mat = ShaderMaterial.new()
			_moving.material = mat
		mat.shader = _fx.shader
		mat.set_shader_parameter("base", Color(bg, 1.0))
		mat.set_shader_parameter("accent", Color(str(style.get("ac", _fx.accent_default.to_html(false)))))
		mat.set_shader_parameter("size", plate.size)
		mat.set_shader_parameter("radius", radius)
		mat.set_shader_parameter("knobs", Vector4(TITLES.knob(style, 0), TITLES.knob(style, 1), 
			TITLES.knob(style, 2), TITLES.knob(style, 3)))
		mat.set_shader_parameter("now", _now())
		if _fx.picture() != "" and not _fx.ends and not _fx.corner:
			mat.set_shader_parameter("art", TITLES.art(_fx.picture()))
		_moving.color = Color.WHITE
		_moving.position = plate.position
		_moving.size = plate.size
	_dress_ends(plate, Color(bg, 1.0), style)
	_dress_corners(plate, style)
	_letters.words = say if say != "" else TITLES.text_of(style)
	_letters.face = face_of(style)
	_letters.px = letter_px(style, px)
	_letters.fg = Color(str(style.get("fg", "000000")))
	_letters.ol = Color(str(style.get("ol", "ffffff")))
	_letters.steps = int(style.get("th", 0))
	_letters.thick = roundi(_letters.steps * _letters.px * THICK)
	var own_font: bool = _fx != null and _fx.font_path != "" and _letters.face != letters()
	_letters.lift = roundf(_letters.px * _fx.font_lift) if own_font else 0.0
	_letters.mode = String(_fx.letters) if _fx != null else ""
	_letters.k0 = TITLES.knob(style, 0)
	_letters.k1 = TITLES.knob(style, 1)
	_letters.now = _now()
	_letters.position = plate.position
	_letters.size = plate.size
	_letters.lay_out()
	set_process( not hosted and rate() > 0.0)
	return box



func _dress_ends(plate: Rect2, tint: Color, style: Dictionary) -> void :
	var tex: Texture2D = TITLES.art(_fx.art_path) if _fx != null and _fx.ends else null
	for old in _ends:
		old.visible = tex != null
	if tex == null:
		return
	while _ends.size() < 2:
		var pic: = TextureRect.new()
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(pic)
		_ends.append(pic)
	move_child(_letters, -1)
	var tall: = plate.size.y * _end_tall(style, _fx)
	var wide: = tall * tex.get_width() / float(tex.get_height())
	for i in 2:
		var pic: = _ends[i]
		pic.visible = true
		pic.texture = tex
		pic.size = Vector2(wide, tall)
		pic.pivot_offset = pic.size * 0.5
		var end_x: = plate.position.x if i == 0 else plate.end.x
		var out: = wide * (END_OUT - 0.5) * (-1.0 if i == 0 else 1.0)
		pic.position = Vector2(end_x + out - wide * 0.5, plate.position.y + (plate.size.y - tall) * 0.5)
		pic.rotation = - END_TILT if i == 0 else END_TILT
		pic.flip_h = i == 1
		pic.modulate = tint



func _dress_corners(plate: Rect2, style: Dictionary) -> void :
	var tex: Texture2D = TITLES.art(_fx.picture()) if _fx != null and _fx.corner else null
	for old in _corners:
		old.visible = false
	if tex == null:
		return
	while _corners.size() < 2:
		var pic: = TextureRect.new()
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_SCALE
		pic.visible = false
		add_child(pic)
		_corners.append(pic)
	move_child(_letters, -1)
	var tall: = plate.size.y * _corner_tall(style, _fx)
	var wide: = tall * tex.get_width() / float(tex.get_height())
	var which: int = _fx.option_at(_fx.corner_knob, TITLES.knob(style, _fx.corner_knob)) if _fx.corner_knob >= 0 else 0
	for i in 2:

		if not (which == 2 or which == i):
			continue
		var pic: = _corners[i]
		pic.visible = true
		pic.texture = tex
		pic.size = Vector2(wide, tall)
		pic.pivot_offset = pic.size * 0.5
		var mid_x: = plate.position.x + plate.size.y * CORNER_IN if i == 0 else plate.end.x - plate.size.y * CORNER_IN
		pic.position = Vector2(mid_x, plate.position.y - plate.size.y * CORNER_UP) - pic.size * 0.5
		pic.rotation = - CORNER_TILT if i == 0 else CORNER_TILT
		pic.flip_h = i == 1
		pic.modulate = Color.WHITE


static func _corner_tall(style: Dictionary, fx: Resource) -> float:
	if fx == null or fx.corner_size_knob < 0:
		return lerpf(CORNER_SMALL, CORNER_BIG, 0.5)
	return lerpf(CORNER_SMALL, CORNER_BIG, TITLES.knob(style, fx.corner_size_knob))



func _corner_reach() -> int:
	if _fx == null or not _fx.corner or _px <= 0:
		return 0
	var tex: Texture2D = TITLES.art(_fx.picture())
	if tex == null:
		return 0
	var plate_h: = ceilf(_px * TALL)
	var tall: = plate_h * _corner_tall(_style, _fx)
	var wide: = tall * tex.get_width() / float(tex.get_height())
	var half: = 0.5 * (wide * cos(CORNER_TILT) + tall * sin(CORNER_TILT))
	return maxi(0, ceili(half - plate_h * CORNER_IN))

static func _now() -> float:
	return fmod(Time.get_ticks_msec() / 1000.0, CLOCK_WRAP)


func rate() -> float:
	return float(_fx.hz) if visible and _fx != null else 0.0


func animated() -> bool:
	return rate() > 0.0



func tick() -> bool:
	if rate() <= 0.0:
		return false
	var now: = _now()
	var changed: = false
	if _letters.mode != "" and _letters.step(now):
		changed = true


	if _moving.visible and (changed or not _fx.plate_follows_letters):
		(_moving.material as ShaderMaterial).set_shader_parameter("now", now)
		changed = true
	return changed

func _process(_delta: float) -> void :
	tick()




func spill() -> int:
	if not visible:
		return 0


	var reach: = roundi(int(_style.get("th", 0)) * _px * THICK * 0.5)



	var inside: = int(_px * (TALL - 0.7) * 0.5)
	var moves: = int(_px * 0.25) if _letters.mode == "bounce" or _letters.mode == "wiggle" else 0

	return maxi(maxi(0, reach - inside + moves), _corner_reach())
