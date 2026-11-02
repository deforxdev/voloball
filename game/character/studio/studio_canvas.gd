class_name StudioCanvas
extends Control























const PATTERNS: = ["none", "balls", "stripes", "dots", "burst"]
const KENNEY_COUNT: = 84
const KENNEY_PATH: = "res://game/character/studio/patterns/pattern_%02d.png"
const BALL_LINES: = preload("res://game/character/studio/ball_lines.png")


const _BALLS: = [
	[0.08, 0.14, 0.3, 0.3], [0.94, 0.84, 0.4, -0.6], [0.58, 1.02, 0.22, 1.2], 
	[0.3, 0.66, 0.1, 2.0], [0.8, 0.1, 0.13, 4.1], 
]

var layers: Array = []
var bg: = Color("ffd23f")
var transparent: = false
var pattern: = "balls"
var pattern_auto: = true
var pattern_color: = Color.WHITE
var pattern_alpha: = 1.0
var pattern_scale: = 0.38

static var _pattern_cache: = {}



static func pattern_ids() -> Array:
	var out: Array = PATTERNS.duplicate()
	out.append_array(tile_ids())
	return out


static func tile_ids() -> Array:
	var out: Array = []
	for i in range(1, KENNEY_COUNT + 1):
		if ResourceLoader.exists(KENNEY_PATH % i):
			out.append("k%02d" % i)
	return out

static func pattern_tex(id: String) -> Texture2D:
	if not id.begins_with("k"):
		return null
	if not _pattern_cache.has(id):
		var path: = KENNEY_PATH % int(id.substr(1))
		_pattern_cache[id] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _pattern_cache[id]

func _init() -> void :

	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


var _nodes: = {}

const SHADOW_SHADER: = preload("res://game/character/studio/studio_shadow.gdshader")
const STICK_SHADER: = preload("res://game/character/studio/studio_stick.gdshader")
const SHADOW_MAX_BLUR: = 0.07





class _Pic extends Control:
	var layer: StudioLayer
	var shade: = false
	func _draw() -> void :
		if layer == null:
			return
		if layer.kind == StudioLayer.KIND_PATTERN:
			_draw_tiles()
			return
		var t: Texture2D = layer.tex if layer.is_rendered() else layer.sticker_tex()
		if t == null:
			return
		var r: = layer.local_rect(size)
		if not shade:
			draw_set_transform_matrix(layer.xform(size))
			draw_texture_rect(t, r, false)
			return
		var reach: = layer.shadow_soft * SHADOW_MAX_BLUR
		var grow: = reach * maxf(absf(r.size.x), absf(r.size.y))
		var big: = r.grow(grow)
		var mat: = material as ShaderMaterial
		mat.set_shader_parameter("shade_color", Color(layer.shadow_color, layer.shadow_alpha))
		mat.set_shader_parameter("radius", reach)
		mat.set_shader_parameter("pad", Vector2(grow / maxf(1.0, big.size.x), grow / maxf(1.0, big.size.y)))
		draw_set_transform_matrix(Transform2D(0.0, layer.shadow_offset(size)) * layer.xform(size))
		draw_texture_rect(t, big, false)

	func _draw_tiles() -> void :
		var tile: = StudioCanvas.pattern_tex(layer.pattern)
		if tile == null:
			return
		var r: = layer.local_rect(size)
		var px: = size.y * lerpf(0.03, 0.3, layer.tile)
		var f: = px / maxf(1.0, tile.get_height())
		draw_set_transform_matrix(layer.xform(size) * Transform2D(0.0, Vector2(f, f), 0.0, Vector2.ZERO))
		draw_texture_rect(tile, Rect2(r.position / f, r.size / f), true, layer.color)


class _Shape extends Control:
	var layer: StudioLayer
	func _draw() -> void :
		if layer == null:
			return
		draw_set_transform_matrix(layer.xform(size))
		if layer.kind == StudioLayer.KIND_PANEL:
			var r: = layer.local_rect(size)
			var sb: = StyleBoxFlat.new()
			sb.bg_color = layer.color
			sb.set_corner_radius_all(int(round(layer.radius * minf(r.size.x, r.size.y) * 0.5)))
			var bw: = int(round(layer.outline * 0.03 * size.y))
			sb.set_border_width_all(bw)
			sb.border_color = layer.outline_color
			sb.anti_aliasing = true
			draw_style_box(sb, r)
			return
		_draw_arrow()

	func _draw_arrow() -> void :
		var l: = layer.size * size.y
		var t: = layer.arrow_px(size)
		var head: = t * 3.2
		var bow: = layer.bend * l * 0.5
		var a: = Vector2( - l * 0.5, 0.0)
		var b: = Vector2(l * 0.5, 0.0)
		var ctrl: = Vector2(0.0, - bow * 2.0)
		var pts: = PackedVector2Array()
		var n: = 24 if absf(layer.bend) > 0.001 else 1
		for i in n + 1:
			var u: = float(i) / n
			pts.append(a.lerp(ctrl, u).lerp(ctrl.lerp(b, u), u))

		var end_dir: = (pts[n] - pts[n - 1]).normalized() if n > 0 else Vector2.RIGHT
		var start_dir: = (pts[1] - pts[0]).normalized() if n > 0 else Vector2.RIGHT
		var line: = pts.duplicate()
		line[line.size() - 1] = pts[n] - end_dir * head * 0.7
		if layer.head2:
			line[0] = pts[0] + start_dir * head * 0.7
		var ink: = layer.outline_color
		var edge: = t * 0.45 if ink.a > 0.01 else 0.0
		for pass_i in 2:
			var col: = ink if pass_i == 0 else layer.color
			var grow: = edge if pass_i == 0 else 0.0
			if pass_i == 0 and edge <= 0.0:
				continue
			draw_polyline(line, col, t + grow * 2.0, true)
			draw_circle(line[0], (t + grow * 2.0) * 0.5, col)
			_head(pts[n], end_dir, head, t, grow, col)
			if layer.head2:
				_head(pts[0], - start_dir, head, t, grow, col)

	func _head(tip: Vector2, dir: Vector2, head: float, t: float, grow: float, col: Color) -> void :
		var side: = dir.orthogonal()
		var back: = tip - dir * head
		var half: = maxf(head * 0.62, t * 1.6) + grow
		draw_colored_polygon(PackedVector2Array([tip + dir * grow * 1.6, 
			back + side * half - dir * grow, back - side * half - dir * grow]), col)



class _Callout extends Control:
	var layer: StudioLayer
	var label: Label
	func _init() -> void :
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		add_child(label)
	func _draw() -> void :
		if layer == null:
			return
		var r: = size.x * 0.5
		var ring: = maxf(1.0, r * 0.14)
		if layer.outline_color.a > 0.01:
			draw_circle(Vector2(r, r), r, layer.outline_color)
		draw_circle(Vector2(r, r), r - ring, layer.color)



class _TextBox extends Control:
	var layer: StudioLayer
	var rtl: RichTextLabel
	var pad: = 0.0
	func _init() -> void :
		rtl = StudioCanvas._rich()
		add_child(rtl)
	func _draw() -> void :
		if layer == null or layer.fill.a <= 0.003:
			return
		var sb: = StyleBoxFlat.new()
		sb.bg_color = layer.fill
		sb.set_corner_radius_all(int(round(layer.radius * minf(size.x, size.y) * 0.5)))
		sb.anti_aliasing = true
		draw_style_box(sb, Rect2(Vector2.ZERO, size))


class _Table extends Control:
	var layer: StudioLayer
	var rows_y: Array = []
	var cols_x: Array = []
	func _draw() -> void :
		if layer == null or rows_y.size() < 2:
			return
		var wd: = size.x


		draw_rect(Rect2(0.0, rows_y[0], wd, rows_y[-1] - rows_y[0]), Color(1, 1, 1, 0.94))
		for i in rows_y.size() - 1:
			var r: = Rect2(0.0, rows_y[i], wd, rows_y[i + 1] - rows_y[i])
			if i == 0 and layer.fill.a > 0.003:
				draw_rect(r, layer.fill)
			elif i % 2 == 0:
				draw_rect(r, Color(layer.color, 0.06))
		var ink: = layer.outline_color
		if ink.a <= 0.01:
			return
		var lw: = maxf(1.0, size.y * 0.004)
		for y in rows_y:
			draw_line(Vector2(0.0, y), Vector2(wd, y), ink, lw)
		for x in cols_x:
			draw_line(Vector2(x, rows_y[0]), Vector2(x, rows_y[-1]), ink, lw)

static func _rich() -> RichTextLabel:
	var r: = RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	r.threaded = false
	return r

func _body_type(layer: StudioLayer) -> String:
	match layer.kind:
		StudioLayer.KIND_TEXT:
			return "label"
		StudioLayer.KIND_BOX:
			return "box"
		StudioLayer.KIND_TABLE:
			return "table"
		StudioLayer.KIND_CALLOUT:
			return "callout"
		StudioLayer.KIND_ARROW, StudioLayer.KIND_PANEL:
			return "shape"
	return "pic"

func _make_body(type: String) -> Control:
	var c: Control
	match type:
		"label":
			c = _make_label()
		"box":
			c = _TextBox.new()
		"table":
			c = _Table.new()
		"callout":
			c = _Callout.new()
		"shape":
			c = _Shape.new()
		_:
			c = _Pic.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	return c

func _place_body(c: Control, type: String, layer: StudioLayer, as_shade: bool) -> void :
	match type:
		"label":
			_place_label(c as Label, layer, not as_shade and not layer.stick)
		"box":
			_place_box(c as _TextBox, layer)
		"table":
			_place_table(c as _Table, layer)
		"callout":
			_place_callout(c as _Callout, layer)
		"shape":
			var s: = c as _Shape
			s.layer = layer
			s.position = Vector2.ZERO
			s.size = size
			s.queue_redraw()
		_:
			var p: = c as _Pic
			p.layer = layer
			p.position = Vector2.ZERO
			p.size = size
			p.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED\
			if layer.kind == StudioLayer.KIND_PATTERN else CanvasItem.TEXTURE_REPEAT_DISABLED
			p.queue_redraw()






class _Img extends Control:
	var vp: SubViewport
	var flat: = false
	func _draw() -> void :
		if vp != null:
			draw_texture(vp.get_texture(), Vector2.ZERO)

func _img(vp: SubViewport, flat: bool) -> _Img:
	var g: = _Img.new()
	g.vp = vp
	g.flat = flat
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	var m: = ShaderMaterial.new()
	m.shader = STICK_SHADER
	m.set_shader_parameter("solid", flat)
	g.material = m
	add_child(g)
	return g

func _set_img(g: _Img, at: Vector2, col: Color, width: float, soft: float) -> void :
	var m: = g.material as ShaderMaterial
	m.set_shader_parameter("line_color", col)
	m.set_shader_parameter("width", width)
	m.set_shader_parameter("soft", soft)
	g.position = at
	g.size = Vector2(g.vp.size)
	g.queue_redraw()





func _uses_img(layer: StudioLayer, type: String) -> bool:
	if layer.stick:
		return true
	if not layer.shadow:
		return false
	if type == "label":
		return false
	return not (type == "pic" and layer.kind != StudioLayer.KIND_PATTERN)

func _free_nodes(nodes: Dictionary) -> void :
	for k in ["vp", "body", "img", "shade"]:
		var n: Variant = nodes.get(k)
		if n != null and is_instance_valid(n):
			(n as Node).queue_free()

var _img_hot: = 0


func sync() -> void :
	var keep: = {}
	var i: = 0
	for l in layers:
		var layer: = l as StudioLayer
		keep[layer] = true
		var type: = _body_type(layer)
		var use_img: = _uses_img(layer, type)
		var nodes: Dictionary = _nodes.get(layer, {})
		if not nodes.is_empty() and (nodes.get("type") != type or bool(nodes.get("img_mode")) != use_img):
			_free_nodes(nodes)
			nodes = {}
		if nodes.is_empty():
			nodes = {"type": type, "img_mode": use_img}
			var body: = _make_body(type)
			if use_img:
				var vp: = SubViewport.new()
				vp.disable_3d = true
				vp.transparent_bg = true
				vp.size = Vector2i(8, 8)
				vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
				vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
				add_child(vp)
				var holder: = Control.new()
				holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
				vp.add_child(holder)
				holder.add_child(body)
				nodes["vp"] = vp
				nodes["holder"] = holder
				nodes["shade"] = _img(vp, true)
				nodes["img"] = _img(vp, false)
			else:
				if type == "pic":
					var shade: = _Pic.new()
					shade.shade = true
					shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
					shade.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
					var m: = ShaderMaterial.new()
					m.shader = SHADOW_SHADER
					shade.material = m
					add_child(shade)
					nodes["shade"] = shade
				add_child(body)
			nodes["body"] = body
			_nodes[layer] = nodes
		var body: Control = nodes["body"]
		_place_body(body, type, layer, false)
		if use_img:
			var vp: SubViewport = nodes["vp"]
			var stick: = layer.stick_px(size)
			var soft: = _shadow_soft_px(layer) if layer.shadow else 0.0
			var off: = layer.shadow_offset(size) if layer.shadow else Vector2.ZERO
			var margin: = ceilf(stick + soft + 3.0)
			var r: = layer.bounds(size).grow(margin)
			r.position = r.position.floor()
			r.size = r.size.ceil() + Vector2.ONE
			var want: = Vector2i(clampi(int(r.size.x), 4, 4096), clampi(int(r.size.y), 4, 4096))
			if vp.size != want:
				vp.size = want
			(nodes["holder"] as Control).position = - r.position
			(nodes["holder"] as Control).size = size
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			var shade: _Img = nodes["shade"]
			shade.visible = layer.shadow
			_set_img(shade, r.position + off, Color(layer.shadow_color, layer.shadow_alpha), stick, soft)
			_set_img(nodes["img"], r.position, layer.stick_color, stick, 0.0)
			move_child(shade, i)
			i += 1
			move_child(nodes["img"], i)
			i += 1
			move_child(vp, i)
			i += 1
			continue
		var shade_node: Node = nodes.get("shade")
		if shade_node != null:
			var sp: = shade_node as _Pic
			sp.visible = layer.shadow
			sp.layer = layer
			sp.position = Vector2.ZERO
			sp.size = size
			sp.queue_redraw()
			move_child(sp, i)
			i += 1
		move_child(body, i)
		i += 1
	for layer in _nodes.keys():
		if not keep.has(layer):
			_free_nodes(_nodes[layer])
			_nodes.erase(layer)
	_img_hot = 3
	queue_redraw()



func _process(_delta: float) -> void :
	if _img_hot <= 0:
		return
	_img_hot -= 1
	for nodes in _nodes.values():
		var vp: Variant = (nodes as Dictionary).get("vp")
		if vp != null and is_instance_valid(vp):
			for g in [(nodes as Dictionary).get("img"), (nodes as Dictionary).get("shade")]:
				if g != null and is_instance_valid(g):
					(g as CanvasItem).queue_redraw()
			if _img_hot == 0:
				(vp as SubViewport).render_target_update_mode = SubViewport.UPDATE_DISABLED


func _shadow_soft_px(layer: StudioLayer) -> float:
	var r: = layer.local_rect(size)
	var span: = maxf(absf(r.size.x), absf(r.size.y))
	if layer.kind in [StudioLayer.KIND_TEXT, StudioLayer.KIND_BOX, StudioLayer.KIND_TABLE]:
		span = layer.font_px(size) * 4.0
	return layer.shadow_soft * SHADOW_MAX_BLUR * span

func _make_label() -> Label:
	var l: = Label.new()
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l

func _place_label(lbl: Label, layer: StudioLayer, own_shadow: = true) -> void :
	lbl.text = layer.text
	lbl.add_theme_font_override("font", layer.font_res())
	lbl.add_theme_font_size_override("font_size", layer.font_px(size))
	lbl.add_theme_color_override("font_color", layer.color)
	lbl.add_theme_color_override("font_outline_color", layer.outline_color)
	lbl.add_theme_constant_override("outline_size", layer.outline_px(size))
	lbl.add_theme_constant_override("line_spacing", 0)



	if layer.shadow and own_shadow:
		var off: = layer.shadow_offset(size)
		lbl.add_theme_color_override("font_shadow_color", Color(layer.shadow_color, layer.shadow_alpha))
		lbl.add_theme_constant_override("shadow_offset_x", int(round(off.x)))
		lbl.add_theme_constant_override("shadow_offset_y", int(round(off.y)))
		lbl.add_theme_constant_override("shadow_outline_size", 
			layer.outline_px(size) + int(round(layer.shadow_soft * layer.font_px(size) * 0.25)))
	else:
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		lbl.add_theme_constant_override("shadow_outline_size", 0)
	lbl.size = Vector2.ZERO
	lbl.reset_size()
	var box: = lbl.get_combined_minimum_size()
	lbl.size = box
	lbl.pivot_offset = box * 0.5
	lbl.position = layer.pos * size - box * 0.5
	lbl.rotation = layer.rot


func _dress_rich(r: RichTextLabel, layer: StudioLayer, bbcode: String, width: float, bold: = false, glyph: = 1.9) -> float:
	var px: = layer.font_px(size)
	var face: = layer.font_res()
	var bold_face: = UiStyle.font(StudioLayer.BOLD_FONT) if layer.font == StudioLayer.FONT_BOOK else face
	r.add_theme_font_override("normal_font", bold_face if bold else face)
	r.add_theme_font_override("bold_font", bold_face)
	if layer.font == StudioLayer.FONT_BOOK and ResourceLoader.exists(StudioLayer.ITALIC_FONT):
		r.add_theme_font_override("italics_font", UiStyle.font(StudioLayer.ITALIC_FONT))
	for k in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		r.add_theme_font_size_override(k, px)
	r.add_theme_color_override("default_color", layer.color)
	r.add_theme_color_override("font_outline_color", layer.outline_color)
	r.add_theme_constant_override("outline_size", layer.outline_px(size))
	r.add_theme_constant_override("line_separation", int(round(px * 0.12)))
	var wrap: String = ["", "center", "right"][clampi(layer.align, 0, 2)]
	r.position = Vector2.ZERO
	r.size = Vector2(maxf(8.0, width), 0.0)
	r.custom_minimum_size = Vector2(maxf(8.0, width), 0.0)


	var key: = "%s|%d|%s|%s|%d|%.2f" % [bbcode, px, layer.color.to_html(), wrap, GuideTokens.gen, glyph]
	if String(r.get_meta("fill_key", "")) != key:
		r.set_meta("fill_key", key)
		GuideTokens.fill(r, bbcode, int(round(px * glyph)), layer.color, wrap)
	return r.get_content_height()

func _place_box(b: _TextBox, layer: StudioLayer) -> void :
	b.layer = layer
	var wd: = layer.w * size.y
	var px: = layer.font_px(size)
	b.pad = px * 0.6 if layer.fill.a > 0.003 else 0.0
	var th: = _dress_rich(b.rtl, layer, layer.text, wd - b.pad * 2.0)
	var bh: = th + b.pad * 2.0
	b.rtl.position = Vector2(b.pad, b.pad)
	b.rtl.size = Vector2(wd - b.pad * 2.0, th)
	b.size = Vector2(wd, bh)
	b.pivot_offset = b.size * 0.5
	b.position = layer.pos * size - b.size * 0.5
	b.rotation = layer.rot
	layer.measured = Vector2(wd, bh) / maxf(1.0, size.y)
	b.queue_redraw()

func _place_callout(c: _Callout, layer: StudioLayer) -> void :
	c.layer = layer
	var d: = layer.size * size.y
	c.size = Vector2(d, d)
	c.pivot_offset = c.size * 0.5
	c.position = layer.pos * size - c.size * 0.5
	c.rotation = layer.rot
	var lbl: = c.label
	lbl.text = layer.text
	var face: = UiStyle.font(StudioLayer.BOLD_FONT)
	lbl.add_theme_font_override("font", face)

	var fs: = d * 0.6
	var wide: = face.get_string_size(layer.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 100).x / 100.0
	if wide > 0.0:
		fs = minf(fs, d * 0.7 / wide)
	lbl.add_theme_font_size_override("font_size", maxi(1, int(fs)))
	var ink: = Color("232b3b") if layer.color.get_luminance() > 0.62 else Color.WHITE
	lbl.add_theme_color_override("font_color", ink)
	lbl.position = Vector2.ZERO
	lbl.size = c.size
	c.queue_redraw()

func _place_table(t: _Table, layer: StudioLayer) -> void :
	t.layer = layer
	var rows: Array = GuideTokens.live_rows(layer.live) if layer.live.begins_with("controls") else layer.cells
	var ncols: = 0
	for row in rows:
		ncols = maxi(ncols, (row as Array).size())
	var cells: Array = []
	for c in t.get_children():
		cells.append(c)
	var want: = rows.size() * ncols
	while cells.size() < want:
		var r: = _rich()
		t.add_child(r)
		cells.append(r)
	while cells.size() > want:
		(cells.pop_back() as Node).queue_free()
	var wd: = layer.w * size.y
	var px: = layer.font_px(size)
	var pad: = px * 0.45

	var weights: Array = []
	for ci in ncols:
		var most: = 3.0
		for row in rows:
			var cell: = String((row as Array)[ci]) if ci < (row as Array).size() else ""
			var n: = float(GuideTokens.plain(cell).length())
			if GuideTokens.has_tokens(cell):
				n = maxf(n, 5.0)
			most = maxf(most, minf(n, 28.0))
		weights.append(most)
	var total: = 0.0
	for x in weights:
		total += float(x)
	t.cols_x = []
	var col_w: Array = []
	var x_at: = 0.0
	for ci in ncols:
		var cw: = wd * float(weights[ci]) / maxf(1.0, total)
		col_w.append(cw)
		if ci > 0:
			t.cols_x.append(x_at)
		x_at += cw
	t.rows_y = [0.0]
	var y: = 0.0
	for ri in rows.size():
		var row: Array = rows[ri]
		var tallest: = 0.0
		var x: = 0.0
		for ci in ncols:
			var r: = cells[ri * ncols + ci] as RichTextLabel
			var cell: = String(row[ci]) if ci < row.size() else ""
			var ch: = _dress_rich(r, layer, cell, float(col_w[ci]) - pad * 2.0, ri == 0, 1.45)
			r.position = Vector2(x + pad, y + pad)
			tallest = maxf(tallest, ch)
			x += float(col_w[ci])
		y += tallest + pad * 2.0
		t.rows_y.append(y)
	t.size = Vector2(wd, y)
	t.pivot_offset = t.size * 0.5
	t.position = layer.pos * size - t.size * 0.5
	t.rotation = layer.rot
	layer.measured = Vector2(wd, y) / maxf(1.0, size.y)
	t.queue_redraw()

func _draw() -> void :
	var cs: = size
	if cs.x < 2.0 or cs.y < 2.0 or transparent:
		return
	draw_rect(Rect2(Vector2.ZERO, cs), bg)
	_draw_pattern(cs)


func _shade(amount: = 0.09) -> Color:
	return bg.darkened(amount) if bg.get_luminance() > 0.35 else bg.lightened(amount * 1.4)

func pattern_tint() -> Color:
	var c: = _shade() if pattern_auto else pattern_color
	return Color(c, c.a * pattern_alpha)

func _draw_pattern(cs: Vector2) -> void :
	var tint: = pattern_tint()

	var k: = lerpf(0.45, 1.0, pattern_scale / 0.38) if pattern_scale < 0.38\
	else lerpf(1.0, 2.2, (pattern_scale - 0.38) / 0.62)
	var tile: = pattern_tex(pattern)
	if tile != null:
		var px: = cs.y * lerpf(0.05, 0.45, pattern_scale)
		var f: = px / maxf(1.0, tile.get_height())
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, f))
		draw_texture_rect(tile, Rect2(Vector2.ZERO, cs / f), true, tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	match pattern:
		"balls":
			for b in _BALLS:
				var c: = Vector2(float(b[0]) * cs.x, float(b[1]) * cs.y)
				var r: = float(b[2]) * cs.y * k
				draw_set_transform(c, float(b[3]), Vector2.ONE)
				draw_texture_rect(BALL_LINES, Rect2( - r, - r, r * 2.0, r * 2.0), false, tint)
			draw_set_transform_matrix(Transform2D.IDENTITY)
		"stripes":
			var w: = cs.y * 0.12 * k
			var x: = - cs.y
			while x < cs.x + cs.y:
				draw_colored_polygon(PackedVector2Array([Vector2(x, cs.y), 
					Vector2(x + w, cs.y), Vector2(x + w + cs.y, 0.0), 
					Vector2(x + cs.y, 0.0)]), tint)
				x += w * 2.0
		"dots":
			var step: = cs.y * 0.09 * k
			var r: = step * 0.2
			var row: = 0
			var y: = step * 0.5
			while y < cs.y + step:
				var x: = step * (0.5 if row % 2 == 0 else 1.0)
				while x < cs.x + step:
					draw_circle(Vector2(x, y), r, tint)
					x += step
				y += step * 0.866
				row += 1
		"burst":

			var c: = Vector2(cs.x * 0.5, cs.y * 0.42)
			var reach: = cs.length()
			var rays: = clampi(int(round(18.0 / k)), 6, 40)
			for i in rays:
				var a0: = TAU * float(i) / rays
				var a1: = a0 + TAU / rays * 0.5
				draw_colored_polygon(PackedVector2Array([c, 
					c + Vector2.from_angle(a0) * reach, 
					c + Vector2.from_angle(a1) * reach]), tint)
