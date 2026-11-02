extends Control









const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")

var _shell: Panel
var _name: Label
var _chip: TITLE_CHIP
var _lv_box: Panel
var _lv: Label
var _gloss: Panel
var _sparks: Array[TextureRect] = []
var _phase: Array[float] = []
var _speed: Array[float] = []
var _t: = 0.0
var _asked: Array = []



var tier: = 0



var party: = 0
var _party_icon: TextureRect

func set_tier(t: int) -> void :
	if t == tier:
		return
	tier = t
	if not _asked.is_empty():
		show_name(_asked[0], _asked[1], _asked[2], _asked[3], _asked[4], _asked[5])

func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shell = Panel.new()
	_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shell)
	_lv_box = Panel.new()
	_lv_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lv_box.visible = false
	add_child(_lv_box)

	_gloss = Panel.new()
	_gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gloss.visible = false
	add_child(_gloss)
	_name = Label.new()
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_name.add_theme_color_override("font_color", UiStyle.INK)
	add_child(_name)
	_lv = Label.new()
	_lv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lv.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lv.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_lv.add_theme_color_override("font_color", Color.WHITE)
	_lv.add_theme_color_override("font_outline_color", Color.BLACK)
	_lv.visible = false
	add_child(_lv)
	_party_icon = TextureRect.new()
	_party_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_party_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_party_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_party_icon.visible = false
	add_child(_party_icon)
	_chip = TITLE_CHIP.new()
	add_child(_chip)


func _ready() -> void :
	set_process(false)
	if not _asked.is_empty():
		show_name(_asked[0], _asked[1], _asked[2], _asked[3], _asked[4], _asked[5])









func show_name(player_name: String, style: Dictionary, name_px: = 30, hold_room: = true, say: = "", level: = 0) -> void :
	_asked = [player_name, style, name_px, hold_room, say, level]
	var k: = name_px / float(PlayerNameplate.FONT_SIZE)
	var font: = UiStyle.font(UiStyle.FONT_XBOLD)

	var dev: = tier == DevBadge.Tier.GOLD
	var leveled: = level > 0 or dev
	var lv_text: = PlayerNameplate.DEV_TEXT if dev else str(level)
	var lv_px: = roundi(PlayerNameplate.CHIP_SIZE * k)
	var lw: = ceilf(font.get_string_size(lv_text, HORIZONTAL_ALIGNMENT_LEFT, -1, lv_px).x + 28.0 * k) if leveled else 0.0
	var lead: = lw + 6.0 * k if leveled else 0.0

	var marked: = party > 0 and PartyMark.ENABLED and PartyMark.icon() != null
	var ph: = ceilf(PlayerNameplate.HEIGHT * k) - 14.0 * k
	var pw: = 0.0
	if marked:
		var tex: = PartyMark.icon()
		pw = ph * float(tex.get_width()) / maxf(1.0, float(tex.get_height()))
	var pspace: = pw + 10.0 * k if marked else 0.0
	var name_w: = ceilf(font.get_string_size(player_name, HORIZONTAL_ALIGNMENT_LEFT, -1, name_px).x + 32.0 * k + lead + pspace)
	var title_px: = roundi(PlayerNameplate.TITLE_PX * k)
	var worn: = _chip.show_style(style, title_px, say)
	var titled: = worn != Vector2.ZERO
	var pill_h: = ceilf(PlayerNameplate.HEIGHT * k)
	var tuck: = ceilf(PlayerNameplate.TITLE_TUCK * k)
	var under: = ceilf(title_px * TITLE_CHIP.TALL) - tuck
	var spill: = float(_chip.spill()) if titled else 0.0
	var wide: = maxf(name_w, worn.x + spill * 2.0) if titled else name_w
	var tall: = pill_h + ((worn.y - tuck + spill) if titled else 0.0)
	custom_minimum_size = Vector2(wide, maxf(tall, pill_h + under) if hold_room else tall)
	size = custom_minimum_size
	var flat: = StyleBoxFlat.new()
	flat.bg_color = Color(1.0, 1.0, 1.0, 0.94)
	flat.set_corner_radius_all(int(pill_h * 0.5))
	flat.shadow_color = Color(UiStyle.INK, 0.28)
	flat.shadow_size = int(8.0 * k)
	flat.shadow_offset = Vector2(0, 5.0 * k)
	var ink: = UiStyle.INK
	if tier == DevBadge.Tier.GOLD or tier == DevBadge.Tier.SILVER:
		var gold: = tier == DevBadge.Tier.GOLD
		flat.bg_color = PlayerNameplate.GOLD_FILL if gold else PlayerNameplate.SILVER_FILL
		flat.border_color = PlayerNameplate.GOLD_EDGE if gold else PlayerNameplate.SILVER_EDGE
		flat.set_border_width_all(maxi(1, roundi(3.0 * k)))
		flat.border_width_bottom = maxi(2, roundi(6.0 * k))
		ink = PlayerNameplate.GOLD_INK if gold else PlayerNameplate.SILVER_INK
	_name.add_theme_color_override("font_color", ink)
	_shell.add_theme_stylebox_override("panel", flat)
	_shell.position = Vector2((wide - name_w) * 0.5, 0)
	_shell.size = Vector2(name_w, pill_h)
	_name.text = player_name
	_name.add_theme_font_size_override("font_size", name_px)
	_name.position = _shell.position + Vector2(lead, 0.0)
	_name.size = _shell.size - Vector2(lead + pspace, 0.0)
	_party_icon.visible = marked
	if marked:
		_party_icon.texture = PartyMark.icon()
		_party_icon.self_modulate = PartyMark.color(party)
		_party_icon.position = _shell.position + Vector2(name_w - pw - 12.0 * k, (pill_h - ph) * 0.5)
		_party_icon.size = Vector2(pw, ph)
	_lv_box.visible = leveled
	_lv.visible = leveled
	if leveled:
		var box: = StyleBoxFlat.new()
		box.bg_color = PlayerNameplate.DEV_COLOR if dev else PlayerNameplate.LEVEL_COLOR
		box.set_corner_radius_all(int((pill_h - 10.0 * k) * 0.5))
		_lv_box.add_theme_stylebox_override("panel", box)
		_lv_box.position = _shell.position + Vector2(5.0, 5.0) * k
		_lv_box.size = Vector2(lw, pill_h - 10.0 * k)
		_lv.text = lv_text
		_lv.add_theme_font_size_override("font_size", lv_px)
		_lv.add_theme_constant_override("outline_size", maxi(1, roundi(9.0 * k)))
		_lv.position = Vector2(_lv_box.position.x, _shell.position.y)
		_lv.size = Vector2(lw, pill_h)
	if titled:
		_chip.position = Vector2((wide - worn.x) * 0.5, pill_h - tuck)
		move_child(_chip, -1)



	var badge: = tier == DevBadge.Tier.GOLD or tier == DevBadge.Tier.SILVER
	_gloss.visible = badge
	if badge:
		var g: = StyleBoxFlat.new()
		g.bg_color = Color(1.0, 1.0, 1.0, 0.38)
		g.set_corner_radius_all(int(pill_h * 0.5))
		_gloss.add_theme_stylebox_override("panel", g)
		_gloss.position = _shell.position + Vector2(7.0, 5.0) * k
		_gloss.size = Vector2(name_w - 14.0 * k, pill_h * 0.36)
	_dress_sparks(badge, pill_h)



func _dress_sparks(on: bool, pill_h: float) -> void :
	if on and _sparks.is_empty():
		for i in DevTag.SPARKS:
			var s: = TextureRect.new()
			s.texture = DevTag._star()
			s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			s.stretch_mode = TextureRect.STRETCH_SCALE
			s.mouse_filter = Control.MOUSE_FILTER_IGNORE
			s.visible = false
			add_child(s)
			_sparks.append(s)
			_phase.append(randf() * TAU)
			_speed.append(0.35 + randf() * 0.5)
		_t = randf() * 20.0
	for s in _sparks:
		s.size = Vector2.ONE * pill_h * 1.55
		s.pivot_offset = s.size * 0.5
		s.visible = s.visible and on
	set_process(on)

func _process(delta: float) -> void :
	if _sparks.is_empty():
		return
	_t += delta
	var h: = _shell.size.y
	var half_w: = _shell.size.x * 0.5
	var centre: = _shell.position + _shell.size * 0.5
	var tint: = DevTag.GOLD_SPARK if tier == DevBadge.Tier.GOLD else DevTag.SILVER_SPARK
	for i in _sparks.size():
		var s: = _sparks[i]
		var a: = _phase[i] + _t * _speed[i]

		var tw: = pow(maxf(0.0, sin(_t * 3.0 + _phase[i] * 3.1)), 3.5)
		s.visible = tw > 0.02
		if not s.visible:
			continue
		var at: = centre + Vector2(cos(a) * half_w * 1.2, - (sin(a * 1.7 + _phase[i]) * h * 0.9 + h * 0.25))
		var kk: = 0.35 + 0.9 * tw
		s.scale = Vector2(kk, kk)
		s.position = at - s.size * 0.5
		s.modulate = Color(tint, 0.35 + 0.65 * tw)
