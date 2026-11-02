class_name SeatBadge
extends Sprite3D






var _sub: SubViewport = null
var _pill_box: StyleBoxFlat = null
var _label: Label = null
var _chevron: Label = null
var _marker: = false



var _chip: = false
var _last_text: = ""
var _last_color: = Color.TRANSPARENT

const VP_SIZE: = Vector2i(220, 150)

func _init(marker: = false, chip: = false) -> void :
	_marker = marker
	_chip = chip
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	shaded = false
	double_sided = true
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pixel_size = 0.0055
	render_priority = 24
	_build()
	if _marker:

		pixel_size = 0.00055
		extra_cull_margin = 8.0
		var mat: = ShaderMaterial.new()
		mat.shader = preload("res://game/player/head_label.gdshader")
		mat.render_priority = render_priority
		mat.set_shader_parameter("label_texture", texture)
		material_override = mat

func _build() -> void :
	_sub = SubViewport.new()
	_sub.transparent_bg = true
	_sub.disable_3d = true


	_sub.size = Vector2i(180, 184) if _marker else VP_SIZE
	_sub.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_sub)
	var col: = VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", -6)
	_sub.add_child(col)

	var center: = CenterContainer.new()
	col.add_child(center)
	var pill: = PanelContainer.new()
	_pill_box = StyleBoxFlat.new()
	_pill_box.set_corner_radius_all(22)
	_pill_box.set_border_width_all(7)
	_pill_box.border_color = Color(0.05, 0.05, 0.08, 1.0)
	_pill_box.content_margin_left = 24.0
	_pill_box.content_margin_right = 24.0
	_pill_box.content_margin_top = 2.0
	_pill_box.content_margin_bottom = 4.0
	pill.add_theme_stylebox_override("panel", _pill_box)
	if _marker:
		pill.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	if _chip:
		_pill_box.set_border_width_all(0)
		_pill_box.set_corner_radius_all(26)
		_pill_box.content_margin_left = 30.0
		_pill_box.content_margin_right = 30.0
		_pill_box.content_margin_top = 4.0
		_pill_box.content_margin_bottom = 6.0
	center.add_child(pill)
	_label = Label.new()
	_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_label.add_theme_font_size_override("font_size", 62 if _marker else 66)
	_label.add_theme_color_override("font_color", Color.WHITE)
	_label.add_theme_constant_override("outline_size", 28 if _marker else 12)
	_label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pill.add_child(_label)
	if _chip:
		_label.add_theme_font_size_override("font_size", 60)
		_label.add_theme_constant_override("outline_size", 0)
		_label.add_theme_color_override("font_color", UiStyle.INK)

	var cc: = CenterContainer.new()
	col.add_child(cc)
	_chevron = Label.new()
	_chevron.text = "▼"
	_chevron.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_chevron.add_theme_font_size_override("font_size", 38 if _marker else 44)
	_chevron.add_theme_constant_override("outline_size", 20 if _marker else 10)
	_chevron.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
	cc.add_child(_chevron)
	if _chip:
		cc.visible = false
	texture = _sub.get_texture()

func set_badge(text: String, color: Color) -> void :
	if _label == null or (text == _last_text and color == _last_color):
		return
	_last_text = text
	_last_color = color
	_label.text = text
	if _marker:
		_label.add_theme_color_override("font_color", color)
	_pill_box.bg_color = color
	_chevron.add_theme_color_override("font_color", color)
	_sub.render_target_update_mode = SubViewport.UPDATE_ONCE
