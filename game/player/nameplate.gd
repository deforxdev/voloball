class_name PlayerNameplate
extends Label3D




const FONT_SIZE: = 44
const CHIP_SIZE: = 36
const HEIGHT: = 58
const PAD: = 14
const PIXEL_SIZE: = 0.00048
const SHELL_ALPHA: = 0.8
const CPU_COLOR: = Color("9298b5")



const LEVEL_COLOR: = Color("2f9e5a")



const DEV_COLOR: = Color("e3342b")
const DEV_TEXT: = "DEV"
const BILLBOARD: = preload("res://game/player/head_label.gdshader")








const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")
const TITLE_PX: = 24



const TITLE_TUCK: = -4






const TITLE_BEATS: = 3




const GOLD_FILL: = Color("ffcd45")
const GOLD_EDGE: = Color("b87900")
const GOLD_INK: = Color("4a2b00")
const SILVER_FILL: = Color("d7dde8")
const SILVER_EDGE: = Color("79849a")
const SILVER_INK: = Color("273043")

var _plate: Sprite3D
var _title: Label
var _chip: Label
var _surface: SubViewport
var _shell: Panel
var _inset: Panel
var _lv_inset: Panel
var _lv_chip: Label
var _level: = 0



var _party: = 0
var _party_icon: TextureRect
var _material: ShaderMaterial
var _last_text: = ""
var raster_updates: = 0
var _worn: TITLE_CHIP
var _title_style: = {}
var _title_stale: = false
var _title_clock: = 0.0
var _tier: = 0
var intro_mode: = false





var rally_live: = false
var _title_quiet: = false
var _gloss: Panel
static var _beat_frame: = -1
static var _beat_live: = 0
static var _beat_count: = 0

func _ready() -> void :
	font = UiStyle.font(UiStyle.FONT_XBOLD)
	font_size = FONT_SIZE
	pixel_size = PIXEL_SIZE
	fixed_size = true
	outline_size = 0
	modulate = Color(UiStyle.INK, 0.0)
	_surface = SubViewport.new()
	_surface.name = "CachedPlate"
	_surface.transparent_bg = true
	_surface.disable_3d = true
	_surface.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_surface)
	_shell = Panel.new()
	_surface.add_child(_shell)
	_inset = Panel.new()
	var inset: = StyleBoxFlat.new()
	inset.bg_color = CPU_COLOR
	inset.set_corner_radius_all((HEIGHT - 10) / 2)
	_inset.add_theme_stylebox_override("panel", inset)
	_surface.add_child(_inset)
	_lv_inset = Panel.new()
	var lv_box: = StyleBoxFlat.new()
	lv_box.bg_color = LEVEL_COLOR
	lv_box.set_corner_radius_all((HEIGHT - 10) / 2)
	_lv_inset.add_theme_stylebox_override("panel", lv_box)
	_lv_inset.visible = false
	_surface.add_child(_lv_inset)
	_gloss = Panel.new()
	var gloss: = StyleBoxFlat.new()
	gloss.bg_color = Color(1.0, 1.0, 1.0, 0.38)
	gloss.set_corner_radius_all(HEIGHT / 2)
	_gloss.add_theme_stylebox_override("panel", gloss)
	_gloss.visible = false
	_surface.add_child(_gloss)
	_title = _label(FONT_SIZE, UiStyle.INK)
	_chip = _label(CHIP_SIZE, Color.WHITE)
	_lv_chip = _label(CHIP_SIZE, Color.WHITE)


	_lv_chip.add_theme_color_override("font_outline_color", Color.BLACK)
	_lv_chip.add_theme_constant_override("outline_size", 9)
	_lv_chip.visible = false
	_party_icon = TextureRect.new()
	_party_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_party_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_party_icon.visible = false
	_surface.add_child(_party_icon)
	_plate = Sprite3D.new()
	_plate.name = "Plate"
	_plate.pixel_size = PIXEL_SIZE
	_plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	_plate.extra_cull_margin = 8.0
	_material = ShaderMaterial.new()
	_material.shader = BILLBOARD
	_plate.material_override = _material
	add_child(_plate)
	_dress_shell()
	_refresh()

func _label(point_size: int, color: Color) -> Label:
	var label: = Label.new()
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", point_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_surface.add_child(label)
	return label




func set_size_k(k: float) -> void :
	if _plate != null:
		_plate.pixel_size = PIXEL_SIZE * k

func set_title(style: Dictionary) -> void :
	if style == _title_style:
		return
	_title_style = style.duplicate()
	_title_stale = true

func title_style() -> Dictionary:
	return _title_style


func set_level(lv: int) -> void :
	if lv == _level:
		return
	_level = lv
	_title_stale = true

func level_shown() -> bool:
	return _lv_inset != null and _lv_inset.visible and _plate.visible



func set_party(group: int) -> void :
	if group == _party:
		return
	_party = group
	_title_stale = true

func party_shown() -> int:
	return _party if _party_icon != null and _party_icon.visible and _plate.visible else 0



func set_tier(tier: int) -> void :
	if tier == _tier:
		return
	_tier = tier
	_dress_shell()
	_title_stale = true
	_redraw()

func tier() -> int:
	return _tier

func set_intro_mode(enabled: bool) -> void :
	if intro_mode == enabled:
		return
	intro_mode = enabled
	_dress_shell()
	_redraw()

func _dress_shell() -> void :
	if _shell == null:
		return
	var flat: = StyleBoxFlat.new()
	flat.set_corner_radius_all(HEIGHT / 2)
	flat.shadow_color = Color(UiStyle.INK, 0.28)
	flat.shadow_size = 8
	flat.shadow_offset = Vector2(0, 5)
	if _tier == 0:
		flat.bg_color = Color.WHITE if intro_mode else Color(1.0, 1.0, 1.0, SHELL_ALPHA)
		if intro_mode:
			flat.border_color = Color(UiStyle.INK, 0.16)
			flat.set_border_width_all(2)
	else:
		flat.bg_color = GOLD_FILL if _tier == 1 else SILVER_FILL
		flat.border_color = GOLD_EDGE if _tier == 1 else SILVER_EDGE
		flat.set_border_width_all(3)
		flat.border_width_bottom = 6
	_shell.add_theme_stylebox_override("panel", flat)
	_gloss.visible = _tier != 0



func _name_ink() -> Color:
	if _tier == 1:
		return GOLD_INK
	if _tier == 2:
		return SILVER_INK
	return Color(modulate, 1.0)


func title_shown() -> bool:
	return _worn != null and _worn.visible and _plate.visible



func name_shown() -> bool:
	return _plate != null and _plate.visible and is_visible_in_tree()

func _name_quiet() -> bool:
	return rally_live and GameConfig.hide_names_in_rally

func _process(delta: float) -> void :
	_plate.visible = text != "" and not _name_quiet()



	var title_quiet: = rally_live and GameConfig.hide_titles_in_rally
	if title_quiet != _title_quiet and _plate.visible and is_visible_in_tree():
		_title_quiet = title_quiet
		_title_stale = true


	if text != "" and (text != _last_text or _title_stale):
		_refresh()




	if _worn != null and _worn.rate() > 0.0 and _plate.visible and is_visible_in_tree():
		var frame: = Engine.get_process_frames()
		if frame != _beat_frame:
			_beat_frame = frame
			_beat_count = _beat_live
			_beat_live = 0
		var mine: = _beat_live
		_beat_live += 1
		_title_clock += delta
		var turns: = maxi(1, ceili(float(_beat_count) / TITLE_BEATS))
		if _title_clock >= 1.0 / _worn.rate() and (frame + mine) % turns == 0:
			_title_clock = 0.0
			if _worn.tick():
				_redraw()
	if _plate.layers != layers:
		_plate.layers = layers
	if _material.render_priority != render_priority:
		_material.render_priority = render_priority


	var title_color: = _name_ink()
	if _title.get_theme_color("font_color") != title_color:
		_title.add_theme_color_override("font_color", title_color)
		_title.add_theme_constant_override("outline_size", 5 if _tier == 0 and title_color != UiStyle.INK else 0)
		_title.add_theme_color_override("font_outline_color", outline_modulate)
		_redraw()

func _redraw() -> void :
	_surface.render_target_update_mode = SubViewport.UPDATE_ONCE
	raster_updates += 1

func _refresh() -> void :
	_plate.visible = text != "" and not _name_quiet()
	if text == "":
		return
	_last_text = text
	var cpu: = text.ends_with(" (CPU)")
	var title: = text.trim_suffix(" (CPU)") if cpu else text
	title = title.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x > 320.0:
		title = title.trim_suffix("…").left(-1) + "…"
	_title.text = title
	_chip.text = "CPU" if cpu else ""
	var tw: = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var cw: = font.get_string_size("CPU", HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_SIZE).x + 30.0 if cpu else 0.0


	var dev: = not cpu and _tier == DevBadge.Tier.GOLD
	var leveled: = not cpu and (_level > 0 or dev)
	var lv_text: = DEV_TEXT if dev else str(_level)
	(_lv_inset.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = DEV_COLOR if dev else LEVEL_COLOR
	var lw: = font.get_string_size(lv_text, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_SIZE).x + 28.0 if leveled else 0.0

	var marked: = not cpu and _party > 0 and PartyMark.ENABLED and PartyMark.icon() != null
	var ph: = float(HEIGHT - 14)
	var pw: = 0.0
	if marked:
		var tex: = PartyMark.icon()
		pw = ph * float(tex.get_width()) / maxf(1.0, float(tex.get_height()))
	var pspace: = pw + 10.0 if marked else 0.0
	var width: = ceili(tw + 32.0 + (cw + 6.0 if cpu else 0.0) + (lw + 6.0 if leveled else 0.0) + pspace)


	_title_stale = false
	var worn: = Vector2.ZERO
	if not cpu and not _title_style.is_empty() and not _title_quiet:
		if _worn == null:
			_worn = TITLE_CHIP.new()
			_worn.hosted = true
			_surface.add_child(_worn)
		worn = _worn.show_style(_title_style, TITLE_PX)
	elif _worn != null:
		_worn.show_style({}, TITLE_PX)
	var titled: = worn != Vector2.ZERO




	var spill: = _worn.spill() if titled else 0
	var inner: = width
	var below: = 0
	if titled:
		inner = maxi(width, ceili(worn.x) + spill * 2)
		below = ceili(worn.y) - TITLE_TUCK + spill
	var left: = PAD + (inner - width) / 2
	_surface.size = Vector2i(inner + PAD * 2, HEIGHT + below + PAD * 2)
	_shell.position = Vector2(left, PAD)
	_shell.size = Vector2(width, HEIGHT)
	_gloss.position = Vector2(left + 7.0, PAD + 5.0)
	_gloss.size = Vector2(width - 14.0, HEIGHT * 0.36)
	var lead: = lw + 6.0 if leveled else 0.0
	_title.position = Vector2(left + lead, PAD)
	_title.size = Vector2(width - lead - cw - (6.0 if cpu else 0.0) - pspace, HEIGHT)
	_party_icon.visible = marked
	if marked:
		_party_icon.texture = PartyMark.icon()
		_party_icon.self_modulate = PartyMark.color(_party)
		_party_icon.position = Vector2(left + width - pw - 12.0, PAD + (HEIGHT - ph) * 0.5)
		_party_icon.size = Vector2(pw, ph)
	_lv_inset.visible = leveled
	_lv_chip.visible = leveled
	if leveled:
		_lv_chip.text = lv_text
		_lv_inset.position = Vector2(left + 5, PAD + 5)
		_lv_inset.size = Vector2(lw, HEIGHT - 10)
		_lv_chip.position = Vector2(left + 5, PAD)
		_lv_chip.size = Vector2(lw, HEIGHT)
	if titled:
		_worn.position = Vector2(PAD + (inner - worn.x) * 0.5, PAD + HEIGHT - TITLE_TUCK)
		_surface.move_child(_worn, -1)


	_plate.offset = Vector2(0.0, - below * 0.5)
	_inset.visible = cpu
	_chip.visible = cpu
	_inset.position = Vector2(left + width - cw - 5, PAD + 5)
	_inset.size = Vector2(cw, HEIGHT - 10)
	_chip.position = Vector2(left + width - cw - 5, PAD)
	_chip.size = Vector2(cw, HEIGHT)
	_plate.texture = _surface.get_texture()
	_material.set_shader_parameter("label_texture", _plate.texture)
	_redraw()
