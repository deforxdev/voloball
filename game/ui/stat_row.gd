class_name StatRow
extends PanelContainer







const TITLES: = preload("res://game/titles/title_catalog.gd")
const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")



const COLS: = [
	{"key": "pts", "head": "pts", "tip": "points"}, 
	{"key": "spk", "head": "spk", "tip": "spikes"}, 
	{"key": "blk", "head": "blk", "tip": "blocks"}, 
	{"key": "rcv", "head": "rec", "tip": "receives"}, 
	{"key": "set", "head": "set", "tip": "sets"}, 
	{"key": "ast", "head": "ast", "tip": "assists"}, 
	{"key": "ace", "head": "ace", "tip": "aces: serves the other team never touched"}, 
	{"key": "dig", "head": "dig", "tip": "digs: receives made with a dive"}, 
]
const CPU_SUFFIX: = " (CPU)"

const AVATAR: = 34.0
const ROW_H: = 46.0
const STAT_W: = 38.0
const NET_W: = 74.0
const SEP: = 5.0
const TITLE_PX: = 11





const NAME_FLOOR: = 78.0
const PARTY_SIZE: = Vector2(32, 16)


const PING_HOST: = -1
const PING_CPU: = -2



const MS_GOOD: = 50.0
const MS_OK: = 90.0

const GOLD: = Color("ffcf3f")
const HOST_TEXT: = Color("c98a00")
const BLUE: = Color("2e78ff")
const CPU_GREY: = Color("8b93a7")

static var _portrait_cache: = {}

var _side: = 1
var _glass: = false
var _cfg_hash: = 0
var _title_key: = ""
var _box: StyleBoxFlat
var _portrait: TextureRect
var _frame: PanelContainer
var _name: Label
var _title_slot: Control
var _crown: Crown
var _you: PanelContainer
var _cpu: PanelContainer
var _mvp: PanelContainer
var _lv: PanelContainer
var _party: TextureRect
var _stat_labels: Array[Label] = []
var _net: HBoxContainer
var _bars: SignalBars
var _net_text: Label
var _net_crown: Crown


var name_label: Label:
	get:
		return _name



class Crown extends Control:
	var col: = Color("ffcf3f")
	func _init() -> void :
		custom_minimum_size = Vector2(20, 18)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void :
		var w: = size.x
		var h: = size.y
		var pts: = PackedVector2Array([
			Vector2(w * 0.1, h * 0.88), Vector2(w * 0.1, h * 0.3), 
			Vector2(w * 0.32, h * 0.56), Vector2(w * 0.5, h * 0.12), 
			Vector2(w * 0.68, h * 0.56), Vector2(w * 0.9, h * 0.3), 
			Vector2(w * 0.9, h * 0.88)])
		draw_colored_polygon(pts, col)
		var outline: = pts.duplicate()
		outline.append(pts[0])
		draw_polyline(outline, Color(0.62, 0.44, 0.0, 0.9), 1.5, true)


class SignalBars extends Control:
	var lit: = 0
	var col: = UiStyle.SUCCESS
	func _init() -> void :
		custom_minimum_size = Vector2(24, 18)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func set_ms(ms: float) -> void :
		if ms <= 25.0:
			lit = 4;col = UiStyle.SUCCESS
		elif ms <= StatRow.MS_GOOD:
			lit = 3;col = UiStyle.SUCCESS
		elif ms <= StatRow.MS_OK:
			lit = 2;col = Color("f2b636")
		else:
			lit = 1;col = Color("e5484d")
		queue_redraw()
	func _draw() -> void :
		var n: = 4
		var bw: = 4.0
		var gap: = 2.0
		var total: = n * bw + (n - 1) * gap
		var x: = (size.x - total) * 0.5
		for i in n:
			var frac: = float(i + 1) / float(n)
			var bh: = size.y * (0.4 + 0.6 * frac)
			var r: = Rect2(x, size.y - bh, bw, bh)
			var on: = i < lit
			draw_rect(r, col if on else Color(0.55, 0.6, 0.7, 0.28))
			x += bw + gap

func _ready() -> void :
	if _name == null:
		_build()

func _build() -> void :
	_box = UiStyle.card_box(Color(UiStyle.card(), 0.98), 14)
	_box.set_content_margin_all(3.0)
	_box.content_margin_left = 8.0
	_box.content_margin_right = 10.0
	add_theme_stylebox_override("panel", _box)
	custom_minimum_size.y = ROW_H
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var hb: = HBoxContainer.new()
	hb.add_theme_constant_override("separation", int(SEP))
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hb)



	var identity: = HBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_theme_constant_override("separation", int(SEP) + 2)
	identity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(identity)

	_frame = PanelContainer.new()
	_frame.custom_minimum_size = Vector2(AVATAR, AVATAR)
	_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(_frame)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_portrait)



	_lv = _make_badge("1", PlayerNameplate.LEVEL_COLOR, Color.WHITE)
	var lv_box: = _lv.get_theme_stylebox("panel") as StyleBoxFlat
	lv_box.content_margin_left = 4.0
	lv_box.content_margin_right = 4.0
	lv_box.content_margin_top = 0.0
	lv_box.content_margin_bottom = 0.0
	lv_box.border_color = UiStyle.INK
	lv_box.set_border_width_all(1)
	var lv_text: = _lv.get_child(0) as Label
	lv_text.add_theme_font_size_override("font_size", 11)
	lv_text.add_theme_color_override("font_outline_color", Color.BLACK)
	lv_text.add_theme_constant_override("outline_size", 3)
	_lv.tooltip_text = "level"
	_portrait.add_child(_lv)
	_lv.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE)

	_lv.position -= Vector2(8, 5)


	var who: = VBoxContainer.new()
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.add_theme_constant_override("separation", -3)
	who.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(who)
	var line: = HBoxContainer.new()
	line.add_theme_constant_override("separation", 6)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	who.add_child(line)
	_name = _mk_label("player", 16, UiStyle.text(), UiStyle.FONT_XBOLD)
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_add_name_shadow(_name)
	line.add_child(_name)
	_title_slot = Control.new()
	_title_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_slot.visible = false
	who.add_child(_title_slot)




	_party = TextureRect.new()
	_party.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_party.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_party.custom_minimum_size = PARTY_SIZE
	_party.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_party.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_party.visible = false
	identity.add_child(_party)


	_crown = Crown.new()
	_crown.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_crown.visible = false
	_crown.tooltip_text = "host"
	identity.add_child(_crown)
	_mvp = _make_badge("mvp", GOLD, UiStyle.INK)
	identity.add_child(_mvp)
	_you = _make_badge("you", BLUE, Color.WHITE)
	identity.add_child(_you)
	_cpu = _make_badge("cpu", Color(CPU_GREY, 0.22), CPU_GREY.darkened(0.25))
	identity.add_child(_cpu)

	for col in COLS:
		var l: = _mk_label("0", 17, UiStyle.text(), UiStyle.FONT_XBOLD)
		l.custom_minimum_size.x = STAT_W
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hb.add_child(l)
		_stat_labels.append(l)



	_net = HBoxContainer.new()
	_net.custom_minimum_size.x = NET_W
	_net.alignment = BoxContainer.ALIGNMENT_END
	_net.add_theme_constant_override("separation", 5)
	_net.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(_net)
	_bars = SignalBars.new()
	_bars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_net.add_child(_bars)
	_net_crown = Crown.new()
	_net_crown.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_net_crown.visible = false
	_net.add_child(_net_crown)
	_net_text = _mk_label("", 15, UiStyle.muted(), UiStyle.FONT_XBOLD)
	_net_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_net.add_child(_net_text)



func set_metrics(row_h: float, avatar: float, stat_w: = STAT_W) -> void :
	if _name == null:
		_build()
	custom_minimum_size.y = row_h
	_frame.custom_minimum_size = Vector2(avatar, avatar)
	for l in _stat_labels:
		l.custom_minimum_size.x = stat_w





func _apply_skin(glass: bool) -> void :
	_glass = glass
	if glass:
		_box.bg_color = Color(0.0, 0.0, 0.0, 0.42)
		for l in _stat_labels:
			l.add_theme_color_override("font_outline_color", Color.BLACK)
			l.add_theme_constant_override("outline_size", 5)
		_name.add_theme_constant_override("outline_size", 5)
		_name.add_theme_color_override("font_outline_color", Color.BLACK)
		_net_text.add_theme_color_override("font_outline_color", Color.BLACK)
		_net_text.add_theme_constant_override("outline_size", 4)

		var cb: = _cpu.get_theme_stylebox("panel") as StyleBoxFlat
		cb.bg_color = Color(1, 1, 1, 0.2)
		(_cpu.get_child(0) as Label).add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	else:
		_box.bg_color = Color(UiStyle.card(), 0.98)

static func is_cpu_row(row: Dictionary) -> bool:
	return String(row.get("name", "")).ends_with(CPU_SUFFIX)









func update(row: Dictionary, ctx: Dictionary) -> void :
	if _name == null:
		_build()
	if bool(ctx.get("glass", false)) != _glass:
		_apply_skin(bool(ctx.get("glass", false)))
	_side = int(row.get("side", 1))
	var team: = Rules.side_color(_side)
	var peer: = int(row.get("peer", 0))
	var networked: = bool(ctx.get("networked", false))
	var local_peer: = int(ctx.get("local_peer", -1))
	var full_name: = String(row.get("name", "player"))
	var is_cpu: = is_cpu_row(row)
	var is_host: = networked and peer == 1 and not is_cpu
	var you_name: = String(ctx.get("you_name", ""))
	var is_you: = not is_cpu and ((peer > 0 and peer == local_peer)
		or (you_name != "" and full_name == you_name))

	_name.text = full_name.trim_suffix(CPU_SUFFIX)
	var name_font: = _name.get_theme_font("font")
	var name_w: = name_font.get_string_size(_name.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 
		_name.get_theme_font_size("font_size")).x + 6.0
	_name.custom_minimum_size.x = minf(ceilf(name_w), NAME_FLOOR)


	var name_col: = team.lightened(0.25) if _glass\
	else (team.darkened(0.28) if not UiStyle.dark else team.lightened(0.15))
	_name.add_theme_color_override("font_color", name_col)
	var frame: = StyleBoxFlat.new()
	frame.bg_color = Color(UiStyle.muted(), 0.12)
	frame.border_color = Color(team, 0.75)
	frame.set_border_width_all(2)
	frame.set_corner_radius_all(99)
	frame.set_content_margin_all(2.0)
	_frame.add_theme_stylebox_override("panel", frame)

	_box.border_color = BLUE
	_box.set_border_width_all(2 if is_you else 0)

	_you.visible = is_you
	_cpu.visible = is_cpu

	var pg: = int(row.get("party", 0))
	_party.visible = pg > 0 and not is_cpu and PartyMark.ENABLED and PartyMark.icon() != null
	if _party.visible:
		_party.texture = PartyMark.icon()
		_party.self_modulate = PartyMark.color(pg)
	_mvp.visible = Rules.stat_row_key(row) in (ctx.get("mvp_keys", []) as Array)
	_apply_title(row)


	var cfg: Variant = row.get("cfg", {})
	var lvl: = int((cfg as Dictionary).get("lvl", 0)) if cfg is Dictionary else 0



	var dev: = not is_cpu and peer > 0 and DevBadge.peer_tier(peer) == DevBadge.Tier.GOLD
	_lv.visible = (lvl > 0 or dev) and not is_cpu
	(_lv.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = \
	PlayerNameplate.DEV_COLOR if dev else PlayerNameplate.LEVEL_COLOR
	if _lv.visible:
		(_lv.get_child(0) as Label).text = PlayerNameplate.DEV_TEXT if dev else str(lvl)

	for i in COLS.size():
		var v: = int(row.get(COLS[i].key, 0))
		_stat_labels[i].text = str(v)

		var lit: = Color.WHITE if _glass else UiStyle.text()
		var dim: = Color(1, 1, 1, 0.38) if _glass else Color(UiStyle.muted(), 0.6)
		_stat_labels[i].add_theme_color_override("font_color", lit if v > 0 else dim)

	_net.visible = bool(ctx.get("show_net", networked))
	if _net.visible:
		_apply_net(row, is_cpu, is_host, is_you, networked, int(ctx.get("local_ping", -1)))


	_crown.visible = is_host and not (_net.visible and _net_crown.visible)

	_apply_portrait(row.get("cfg", {}))

func _apply_net(row: Dictionary, is_cpu: bool, is_host: bool, is_you: bool, 
		networked: bool, local_ping: int) -> void :


	var ping: = local_ping if (networked and is_you) else int(row.get("ping", PING_CPU))
	if is_cpu:

		_bars.visible = false
		_net_crown.visible = false
		_net_text.text = "—"
		_net_text.add_theme_color_override("font_color", UiStyle.muted())
	elif is_host and ping <= 0:

		_bars.visible = false
		_net_crown.visible = true
		_net_text.text = "host"
		_net_text.add_theme_color_override("font_color", HOST_TEXT)
	elif ping <= 0:

		_bars.visible = false
		_net_crown.visible = false
		_net_text.text = "—"
		_net_text.add_theme_color_override("font_color", UiStyle.muted())
	else:


		_bars.visible = true
		_net_crown.visible = false
		_bars.set_ms(float(ping))
		_net_text.text = "%dms" % ping
		_net_text.add_theme_color_override("font_color", _bars.col.darkened(0.28))



func _apply_title(row: Dictionary) -> void :
	var worn: Dictionary = TITLES.of_row(row)
	var key: = str(worn)
	if key == _title_key:
		return
	_title_key = key
	for c in _title_slot.get_children():
		c.queue_free()
	_title_slot.visible = not worn.is_empty()
	if worn.is_empty():
		return
	var chip: Control = TITLE_CHIP.new()
	chip.name = "Title"
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sz: Vector2 = chip.show_style(worn, TITLE_PX)
	_title_slot.custom_minimum_size = sz
	_title_slot.add_child(chip)

func _apply_portrait(cfg_data: Variant) -> void :
	if not (cfg_data is Dictionary) or (cfg_data as Dictionary).is_empty():
		return
	var key: = hash(cfg_data)
	if key == _cfg_hash:
		return
	_cfg_hash = key
	if _portrait_cache.has(key):
		_portrait.texture = _portrait_cache[key]
		return
	_load_portrait(cfg_data, key)

func _load_portrait(cfg_data: Dictionary, key: int) -> void :



	if not is_inside_tree():
		_cfg_hash = 0
		return
	var tex: = await CharacterPortrait.render(
		CharacterConfig.from_dict(cfg_data), "head", Vector2i(80, 80), 
		get_tree().root)
	if tex == null:
		if key == _cfg_hash:
			_cfg_hash = 0
		return
	_portrait_cache[key] = tex
	if is_instance_valid(_portrait) and key == _cfg_hash:
		_portrait.texture = tex

func _make_badge(text: String, bg: Color, fg: Color) -> PanelContainer:
	var p: = PanelContainer.new()
	p.visible = false
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b: = StyleBoxFlat.new()
	b.bg_color = bg
	b.set_corner_radius_all(99)
	b.content_margin_left = 7.0
	b.content_margin_right = 7.0
	b.content_margin_top = 1.0
	b.content_margin_bottom = 1.0
	p.add_theme_stylebox_override("panel", b)
	var l: = _mk_label(text, 11, fg, UiStyle.FONT_XBOLD)
	p.add_child(l)
	return p

func _mk_label(text: String, sz: int, col: Color, font_path: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(font_path))
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _add_name_shadow(label: Label) -> void :
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.06, 0.09, 0.9))
	label.add_theme_constant_override("outline_size", 2)
