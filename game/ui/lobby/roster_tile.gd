class_name RosterTile
extends Control



























signal cpu_pressed(id: String)
signal diff_step(id: String, dir: int)
signal reroll(id: String)


signal human_pressed(id: String)

signal captain_pressed(seat: String)



const MASK_SHADER: = "\nshader_type canvas_item;\nuniform float zoom = 1.12;\nuniform vec2 shift = vec2(0.0, -0.03);\nvoid fragment() {\n\tvec2 d = UV - vec2(0.5);\n\tif (dot(d, d) > 0.25) { discard; }\n\tvec2 uv = d / zoom + vec2(0.5) + shift;\n\tCOLOR = texture(TEXTURE, uv);\n}\n"










static var _mask: Shader = null

var data: Dictionary = {}
var ring_color: = Color("2ea86b")
var _disc: Panel
var _face: TextureRect
var _ring: Panel
var _empty: EmptyDisc
var _crown: Control
var _flag: Control
var _hit: Button
var _plate: Label
var _lv_chip: Label
var _status: Label
var _step: HBoxContainer
var _minus: Button
var _diff: Label
var _plus: Button
var _reroll: Button
var _cap: Button
var _cap_mark: CaptainMark
var _worn: TITLE_CHIP
var _cfg_key: = 0



class StepGlyph extends Control:
	var plus: = false
	var col: = Color("232b3b")
	func _draw() -> void :
		var c: = size * 0.5
		var k: = minf(size.x, size.y) * 0.24
		draw_line(c - Vector2(k, 0), c + Vector2(k, 0), col, 2.0)
		if plus:
			draw_line(c - Vector2(0, k), c + Vector2(0, k), col, 2.0)


class ShuffleGlyph extends Control:
	var col: = Color("232b3b")
	func _draw() -> void :
		var c: = size * 0.5
		var r: = minf(size.x, size.y) * 0.19
		draw_arc(c, r, deg_to_rad(-30.0), deg_to_rad(230.0), 16, col, 1.6, true)
		var tip: = c + Vector2(cos(deg_to_rad(-30.0)), sin(deg_to_rad(-30.0))) * r
		var k: = r * 0.6
		draw_colored_polygon(PackedVector2Array([tip + Vector2( - k * 0.2, - k), 
			tip + Vector2(k * 0.75, k * 0.1), tip + Vector2( - k * 0.55, k * 0.35)]), col)



class HostMark extends Control:
	var col: = Color("ffcf3f")
	func _draw() -> void :
		draw_circle(size * 0.5, minf(size.x, size.y) * 0.5, col)





class CaptainMark extends Control:
	var on: = false
	var _c: Label
	func _init() -> void :
		_c = Label.new()
		_c.text = "C"
		_c.set_anchors_preset(Control.PRESET_FULL_RECT)


		_c.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_c.grow_vertical = Control.GROW_DIRECTION_BOTH
		_c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_c.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_c.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		add_child(_c)
	func _draw() -> void :
		var h: = minf(size.x, size.y)
		var c: = size * 0.5
		draw_circle(c, h * 0.5, Color("ffcf3f") if on else Color(1, 1, 1, 0.82))
		draw_arc(c, h * 0.5 - 1.0, 0.0, TAU, 24, Color(UiStyle.INK, 0.3 if on else 0.18), 1.2, true)
		_c.add_theme_color_override("font_color", UiStyle.INK if on else Color(UiStyle.INK, 0.45))
	func _notification(what: int) -> void :
		if what == NOTIFICATION_RESIZED and _c != null:
			var h: = minf(size.x, size.y)
			_c.add_theme_font_size_override("font_size", maxi(int(roundf(h * 0.72)), 8))

			_c.offset_top = - roundf(h * 0.06)
			_c.offset_bottom = _c.offset_top



class FlagMark extends Control:
	func _draw() -> void :
		var h: = minf(size.x, size.y)
		draw_circle(size * 0.5, h * 0.5, Color.WHITE)
		draw_circle(size * 0.5, h * 0.5, Color(0, 0, 0, 0.12))
		var pole: = Vector2(h * 0.34, h * 0.24)
		draw_line(pole, Vector2(h * 0.34, h * 0.76), Color("c23b3b"), maxf(h * 0.06, 1.5))
		draw_colored_polygon(PackedVector2Array([
			Vector2(h * 0.34, h * 0.26), Vector2(h * 0.72, h * 0.37), 
			Vector2(h * 0.34, h * 0.48)]), Color("e5484d"))

const TITLES: = preload("res://game/titles/title_catalog.gd")
const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")
const TITLE_PX_MIN: = 6
const TITLE_SPILL: = 2.0


const NAME_MAX_SMALL: = 9
const NAME_MAX_BIG: = 12


const CHIP_SPILL: = 8.0


class EmptyDisc extends Control:
	var col: = Color(0.55, 0.6, 0.7, 0.6)
	func _draw() -> void :
		var c: = size * 0.5
		var r: = minf(size.x, size.y) * 0.5 - 2.0
		var n: = 24
		for i in n:
			if i % 2 == 1:
				continue
			var a0: = TAU * float(i) / float(n)
			var a1: = TAU * float(i + 1) / float(n)
			draw_arc(c, r, a0, a1, 6, col, 2.5, true)
		var k: = r * 0.32
		draw_line(c - Vector2(k, 0), c + Vector2(k, 0), col, 3.0)
		draw_line(c - Vector2(0, k), c + Vector2(0, k), col, 3.0)

func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _mask == null:
		_mask = Shader.new()
		_mask.code = MASK_SHADER
	_disc = Panel.new()
	var db: = StyleBoxFlat.new()
	db.bg_color = Color("e9eefb")
	db.set_corner_radius_all(999)
	db.shadow_color = Color(0, 0, 0, 0.16)
	db.shadow_size = 6
	db.shadow_offset = Vector2(0, 3)
	_disc.add_theme_stylebox_override("panel", db)
	_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_disc)
	_face = TextureRect.new()
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_face.stretch_mode = TextureRect.STRETCH_SCALE
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: = ShaderMaterial.new()
	mat.shader = _mask
	_face.material = mat
	_disc.add_child(_face)
	_ring = Panel.new()
	_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disc.add_child(_ring)
	_empty = EmptyDisc.new()
	_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_empty.visible = false
	add_child(_empty)

	_hit = Button.new()
	_hit.flat = true
	_hit.focus_mode = Control.FOCUS_ALL
	for st in ["normal", "hover", "pressed", "disabled"]:
		_hit.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(0, 0, 0, 0)
	fb.set_corner_radius_all(999)
	fb.set_border_width_all(3)
	fb.border_color = UiStyle.PRIMARY
	_hit.add_theme_stylebox_override("focus", fb)
	_hit.pressed.connect( func(): _on_hit())

	_hit.mouse_entered.connect( func(): _set_hover(true))
	_hit.mouse_exited.connect( func(): _set_hover(false))
	add_child(_hit)
	_crown = HostMark.new()
	_crown.visible = false
	add_child(_crown)

	_flag = FlagMark.new()
	_flag.visible = false
	_flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flag)
	_reroll = Button.new()
	_reroll.tooltip_text = "shuffle appearance"
	_reroll.focus_mode = Control.FOCUS_ALL
	var sg: = ShuffleGlyph.new()
	sg.set_anchors_preset(Control.PRESET_FULL_RECT)
	sg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reroll.add_child(sg)
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color.WHITE if st != "hover" else Color("fff3c4")
		sb.set_corner_radius_all(999)
		sb.set_border_width_all(2)
		sb.border_color = Color(UiStyle.INK, 0.15) if st != "focus" else UiStyle.PRIMARY
		sb.shadow_color = Color(0, 0, 0, 0.15)
		sb.shadow_size = 3
		sb.shadow_offset = Vector2(0, 1)
		_reroll.add_theme_stylebox_override(st, sb)
	_reroll.pressed.connect( func():
		UiStyle.sfx("press")
		reroll.emit(String(data.get("id", ""))))
	_reroll.visible = false
	add_child(_reroll)
	_cap = Button.new()
	_cap.flat = true
	_cap.focus_mode = Control.FOCUS_ALL
	for st in ["normal", "hover", "pressed", "disabled"]:
		_cap.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	var cfb: = StyleBoxFlat.new()
	cfb.bg_color = Color(0, 0, 0, 0)
	cfb.set_corner_radius_all(999)
	cfb.set_border_width_all(2)
	cfb.border_color = UiStyle.PRIMARY
	_cap.add_theme_stylebox_override("focus", cfb)
	_cap_mark = CaptainMark.new()
	_cap_mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cap_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cap.add_child(_cap_mark)
	_cap.pressed.connect( func():
		UiStyle.sfx("press")
		captain_pressed.emit(String(data.get("seat", ""))))
	_cap.mouse_entered.connect( func(): _cap_mark.modulate = Color(1.12, 1.12, 1.12))
	_cap.mouse_exited.connect( func(): _cap_mark.modulate = Color.WHITE)
	_cap.visible = false
	add_child(_cap)
	_plate = Label.new()
	_plate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plate)
	_lv_chip = Label.new()
	_lv_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lv_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lv_chip.visible = false
	add_child(_lv_chip)
	_status = Label.new()
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status.visible = false
	add_child(_status)
	_step = HBoxContainer.new()
	_step.add_theme_constant_override("separation", 2)
	_step.alignment = BoxContainer.ALIGNMENT_CENTER
	_step.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_step.visible = false
	add_child(_step)
	_minus = _step_btn("minus", -1)
	_step.add_child(_minus)
	_diff = Label.new()
	_diff.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_diff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_step.add_child(_diff)
	_plus = _step_btn("plus", 1)
	_step.add_child(_plus)

func _step_btn(icon_name: String, dir: int) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_ALL
	var g: = StepGlyph.new()
	g.plus = icon_name == "plus"
	g.set_anchors_preset(Control.PRESET_FULL_RECT)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(g)
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1, 0.9) if st != "hover" else Color.WHITE
		sb.set_corner_radius_all(999)
		sb.set_content_margin_all(0.0)
		if st == "focus":
			sb.set_border_width_all(2)
			sb.border_color = UiStyle.PRIMARY
		b.add_theme_stylebox_override(st, sb)
	hold_repeat(b, func():
		UiStyle.sfx("tick")
		diff_step.emit(String(data.get("id", "")), dir))
	return b



static func hold_repeat(b: Button, fn: Callable) -> void :
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.pressed.connect(fn)
	var t: = Timer.new()
	t.one_shot = false
	b.add_child(t)
	var ticks: = [0]
	t.timeout.connect( func():
		ticks[0] += 1
		t.wait_time = maxf(0.16 - 0.02 * ticks[0], 0.05)
		fn.call())
	b.button_down.connect( func():
		ticks[0] = 0
		t.wait_time = 0.42
		t.start())
	b.button_up.connect( func(): t.stop())
	b.mouse_exited.connect( func():
		if not b.button_pressed:
			t.stop())







var _editable: = true

func _ready() -> void :
	if not data.is_empty():
		setup(data, custom_minimum_size, _editable, ring_color)

func setup(d: Dictionary, px: Vector2, editable: bool, ring: Color) -> void :
	data = d
	ring_color = ring
	_editable = editable
	custom_minimum_size = px
	size = px
	var small: = px.y < 100.0
	var narrow: = px.x < 90.0
	var disc: float = minf(px.y * (0.62 if small else 0.66), px.x * 0.9)
	var kind: = String(d.get("kind", "empty"))
	var you: = bool(d.get("you", false))
	var host: = bool(d.get("host", false))

	var dx: = (px.x - disc) * 0.5
	_disc.position = Vector2(dx, 0)
	_disc.size = Vector2(disc, disc)
	_empty.position = _disc.position
	_empty.size = _disc.size
	_hit.position = _disc.position
	_hit.size = _disc.size
	var rb: = StyleBoxFlat.new()
	rb.bg_color = Color(0, 0, 0, 0)
	rb.set_corner_radius_all(999)
	rb.set_border_width_all(4 if not small else 3)



	var local_col = d.get("local_color", null)
	if String(d.get("local", "")) != "" and local_col is Color:
		rb.border_color = local_col as Color
	else:
		rb.border_color = UiStyle.SECONDARY if you else Color.WHITE
	_ring.add_theme_stylebox_override("panel", rb)

	var plate_h: = 16.0 if (small or narrow) else 20.0
	var full_name: = String(d.get("name", "")) if kind != "empty" else "open"
	var limit: = NAME_MAX_SMALL if small else NAME_MAX_BIG
	_plate.text = full_name if full_name.length() <= limit else full_name.left(limit - 1) + "..."
	tooltip_text = full_name if full_name.length() > limit else ""

	var tier: = int(d.get("dev", 0)) if kind == "human" else 0
	var plate_bg: = Color.WHITE
	if tier == DevBadge.Tier.GOLD:
		plate_bg = DevTag.GOLD_DEEP
	elif tier == DevBadge.Tier.SILVER:
		plate_bg = DevTag.SILVER_DEEP
	UiStyle.style_pill(_plate, plate_bg, UiStyle.INK, 10 if (small or narrow) else 13)
	var psb: StyleBoxFlat = _plate.get_theme_stylebox("normal")
	psb.content_margin_left = 8.0
	psb.content_margin_right = 8.0
	psb.content_margin_top = 0.0
	psb.content_margin_bottom = 1.0
	psb.shadow_size = 3
	psb.shadow_offset = Vector2(0, 2)




	_plate.custom_minimum_size = Vector2(0, plate_h)
	var pw: = clampf(_plate.get_minimum_size().x, disc * 0.8, px.x + 6.0)
	_plate.size = Vector2(pw, plate_h)
	_plate.position = Vector2((px.x - _plate.size.x) * 0.5, disc - plate_h * 0.55)
	_plate.modulate.a = 0.75 if kind == "empty" else 1.0





	var look: Variant = d.get("cfg", {})
	var level: = int((look as Dictionary).get("lvl", 0)) if look is Dictionary and kind == "human" else 0
	var dev: = tier == DevBadge.Tier.GOLD
	_lv_chip.visible = dev or level > 0
	if _lv_chip.visible:
		_lv_chip.text = PlayerNameplate.DEV_TEXT if dev else str(level)
		UiStyle.style_pill(_lv_chip, PlayerNameplate.DEV_COLOR if dev else PlayerNameplate.LEVEL_COLOR, 
			Color.WHITE, 9 if (small or narrow) else 11)
		_lv_chip.add_theme_color_override("font_outline_color", Color.BLACK)
		_lv_chip.add_theme_constant_override("outline_size", 3)
		var lsb: StyleBoxFlat = _lv_chip.get_theme_stylebox("normal")
		lsb.content_margin_left = 5.0
		lsb.content_margin_right = 5.0
		lsb.content_margin_top = 0.0
		lsb.content_margin_bottom = 0.0
		lsb.border_color = UiStyle.INK
		lsb.set_border_width_all(1)
		_lv_chip.reset_size()





		var cw: = _lv_chip.size.x
		var tuck: = minf(cw * 0.45, psb.content_margin_left - 1.0)
		var past: = - CHIP_SPILL - (_plate.position.x - cw + tuck)
		if past > 0.0:
			_plate.position.x += clampf(px.x - _plate.position.x - _plate.size.x, 0.0, past)
		_lv_chip.position = Vector2(maxf(_plate.position.x - cw + tuck, - CHIP_SPILL), 
			_plate.position.y - _lv_chip.size.y * 0.45)

	var status_y: = _plate.position.y + plate_h + 2.0
	_status.visible = false
	_step.visible = false
	_reroll.visible = false
	_crown.visible = false
	_disc.visible = kind != "empty"
	_empty.visible = kind == "empty"





	var hit_on: = (kind == "cpu" and editable)\
	or (kind == "human" and not you and bool(d.get("actionable", false)))
	_hit.visible = hit_on
	_hit.mouse_filter = Control.MOUSE_FILTER_STOP if hit_on else Control.MOUSE_FILTER_IGNORE
	_hit.focus_mode = Control.FOCUS_ALL if hit_on else Control.FOCUS_NONE
	_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if hit_on else Control.CURSOR_ARROW

	_flag.visible = kind == "human" and not you and bool(d.get("actionable", false))
	if _flag.visible:
		var fsz: = 18.0 if small else 22.0
		_flag.size = Vector2(fsz, fsz)
		_flag.position = _disc.position + Vector2( - fsz * 0.28, - fsz * 0.28)
		_flag.queue_redraw()
	_set_hover(false)



	var is_cap: = bool(d.get("cap", false)) and kind != "empty"
	var cap_tap: = bool(d.get("cap_edit", false)) and (kind == "human" or kind == "cpu")
	_cap.visible = is_cap or cap_tap
	if _cap.visible:
		var csz: = 18.0 if small else 22.0
		_cap.size = Vector2(csz, csz)
		_cap.position = _disc.position + Vector2( - csz * 0.3, disc * 0.5 - csz * 0.5)
		_cap_mark.on = is_cap
		_cap_mark.queue_redraw()
		_cap.disabled = not cap_tap or is_cap
		_cap.mouse_filter = Control.MOUSE_FILTER_STOP if cap_tap else Control.MOUSE_FILTER_IGNORE
		_cap.focus_mode = Control.FOCUS_ALL if (cap_tap and not is_cap) else Control.FOCUS_NONE
		_cap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND\
		if (cap_tap and not is_cap) else Control.CURSOR_ARROW
		_cap.tooltip_text = "captain" if is_cap else "make captain"
	match kind:
		"human":



			var local_tag: = String(d.get("local", ""))
			if local_tag != "":
				_status.text = local_tag.to_upper()
				var lc: = UiStyle.SECONDARY
				var lcv = d.get("local_color", null)
				if lcv is Color:
					lc = lcv
				UiStyle.style_pill(_status, lc, Color.WHITE, 9 if small else 11)

				_status.add_theme_color_override("font_outline_color", UiStyle.INK)
				_status.add_theme_constant_override("outline_size", 4)
				_slim(_status)
				_status.visible = true
			elif you:
				_status.text = "you"
				UiStyle.style_pill(_status, UiStyle.SECONDARY, Color.WHITE, 9 if small else 11)
				_slim(_status)
				_status.visible = true
			if host:
				var cs: = 16.0 if small else 20.0
				_crown.size = Vector2(cs, cs)
				_crown.position = _disc.position + Vector2(disc - cs * 0.85, -2.0)
				_crown.visible = true
		"cpu":
			var lvl: = int(d.get("diff", 1))
			_diff.text = CpuSlots.diff_name(lvl)



			var pc: Color = [Color("3fb872"), Color("e9bd3a"), Color("d9534f")][clampi(lvl, 0, 2)]
			var compact: = small or narrow
			UiStyle.style_pill(_diff, pc, Color.WHITE, 9 if compact else 11)
			var dsb: StyleBoxFlat = _diff.get_theme_stylebox("normal")
			dsb.content_margin_top = 0.0
			dsb.content_margin_bottom = 0.0
			dsb.content_margin_left = 5.0 if compact else 8.0
			dsb.content_margin_right = 5.0 if compact else 8.0
			dsb.shadow_size = 0
			_diff.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
			_diff.add_theme_color_override("font_outline_color", UiStyle.INK)
			_diff.add_theme_constant_override("outline_size", 3 if compact else 5)
			var bs: = 14.0 if compact else 18.0


			_diff.custom_minimum_size.x = clampf(px.x - bs * 2.0 - 8.0, 34.0, 60.0)
			for b in [_minus, _plus]:
				(b as Control).custom_minimum_size = Vector2(bs, bs)
				(b as Button).visible = editable
				(b as Button).disabled = not editable
			_step.visible = true
			_step.size = Vector2(px.x, bs)
			_step.position = Vector2(0, status_y)
			if editable:
				var rs: = 16.0 if small else 20.0
				_reroll.custom_minimum_size = Vector2(rs, rs)
				_reroll.size = Vector2(rs, rs)
				_reroll.position = _disc.position + Vector2(-2.0, -2.0)
				_reroll.visible = true
		_:
			pass

	var worn: Dictionary = _title_of(d) if kind == "human" else {}
	var title_h: = 0.0
	if not worn.is_empty():
		if _worn == null:
			_worn = TITLE_CHIP.new()
			add_child(_worn)
		var box: Vector2 = _worn.show_style(worn, _title_px(worn, px, small, narrow))
		_worn.position = Vector2(roundf((px.x - box.x) * 0.5), status_y)
		title_h = box.y + 2.0
	elif _worn != null:
		_worn.show_style({}, TITLE_PX_MIN)
	if _status.visible:
		_status.size = _status.get_combined_minimum_size()
		if title_h > 0.0 and status_y + title_h + _status.size.y > px.y:


			_status.position = _disc.position + Vector2( - _status.size.x * 0.22, -3.0)
		else:
			_status.position = Vector2((px.x - _status.size.x) * 0.5, status_y + title_h)
	_load_face(d.get("cfg", {}))




func _title_of(d: Dictionary) -> Dictionary:
	var cfg: Variant = d.get("cfg", {})
	if not (cfg is Dictionary):
		return {}
	if bool(d.get("you", false)) or String(d.get("local", "")) != "":
		return TITLES.sanitize((cfg as Dictionary).get("ttl"))
	return TITLES.of_row({"name": String(d.get("name", "")), "cfg": cfg, 
		"peer": int(str(d.get("id", "0")))})


func _title_px(worn: Dictionary, px: Vector2, small: bool, narrow: bool) -> int:


	var most: = 8 if small else (10 if narrow else 12)
	for tpx in range(most, TITLE_PX_MIN - 1, -1):
		if TITLE_CHIP.measure(worn, tpx).x <= px.x + TITLE_SPILL:
			return tpx
	return TITLE_PX_MIN

func _slim(l: Label) -> void :
	var sb: StyleBoxFlat = l.get_theme_stylebox("normal")
	sb.content_margin_left = 7.0
	sb.content_margin_right = 7.0
	sb.content_margin_top = 0.0
	sb.content_margin_bottom = 0.0
	sb.shadow_size = 0

func _set_hover(on: bool) -> void :
	if _disc != null:
		_disc.modulate = Color(1.14, 1.14, 1.14) if on else Color.WHITE

func _on_hit() -> void :
	match String(data.get("kind", "")):
		"cpu":
			cpu_pressed.emit(String(data.get("id", "")))
		"human":
			human_pressed.emit(String(data.get("id", "")))

func focus_target() -> Control:
	if _hit.visible and _hit.focus_mode != Control.FOCUS_NONE:
		return _hit
	return null

func _load_face(cfg: Variant) -> void :
	if not (cfg is Dictionary) or (cfg as Dictionary).is_empty():
		_face.texture = null
		_cfg_key = 0
		return
	var key: = hash(cfg)
	if key == _cfg_key and _face.texture != null:
		return
	_cfg_key = key
	var tex: ImageTexture = await CharacterPortrait.head_cached(cfg, self, "lobby")

	if not is_instance_valid(self) or key != _cfg_key:
		return
	_face.texture = tex
