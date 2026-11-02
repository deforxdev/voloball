class_name StatsDrawer
extends Control







const SLIDE_IN: = 0.22
const SLIDE_OUT: = 0.18

const MIN_W: = 660.0
const MAX_W: = 900.0
const ROW_MIN: = 36.0

var _panel: PanelContainer
var _table: ScoreTable
var _row_h: = 46.0
var _avatar: = 34.0

var _open: = false
var _tween: Tween
var _hidden_x: = 0.0

func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

	_panel.offset_transform_enabled = true
	visible = false
	get_viewport().size_changed.connect(_apply_metrics)

	_apply_metrics()
	call_deferred("_park_closed")

func _park_closed() -> void :
	_hidden_x = _panel.size.x + 48.0
	if not _open:
		_panel.offset_transform_position.x = _hidden_x



func _resize_to_content() -> void :



	var vh: = get_viewport_rect().size.y
	var top_reserve: = 92.0
	var bot_reserve: = 168.0
	var room: = vh - top_reserve - 16.0
	var want: = _panel.get_combined_minimum_size().y





	var n: = _table.row_count()
	for i in 3:
		if n == 0:
			break
		var cur: = _table.row_height()
		var fit: = clampf(floorf(cur - (want - room) / n), ROW_MIN, _row_h)
		if fit == cur:
			break
		_table.set_metrics(fit, clampf(fit - 10.0, 26.0, _avatar))
		want = _panel.get_combined_minimum_size().y



	var k: = minf(1.0, room / want) if want > 0.0 else 1.0
	_panel.pivot_offset = Vector2(_panel.size.x, 0.0)
	_panel.scale = Vector2(k, k)
	var hgt: = want * k
	var band_top: = top_reserve
	var band_bot: = vh - bot_reserve
	var top: = (band_top + band_bot) * 0.5 - hgt * 0.5
	top = maxf(top, top_reserve)
	if top + hgt > vh - 16.0:
		top = vh - 16.0 - hgt
	_panel.offset_top = top
	_panel.offset_bottom = top + want
	_park_closed()



func _apply_metrics() -> void :
	var vp: = get_viewport_rect().size
	_row_h = clampf((vp.y - 240.0) / 12.0, 36.0, 46.0)
	_avatar = clampf(_row_h - 10.0, 26.0, 34.0)
	_panel.offset_left = - clampf(vp.x * 0.46, MIN_W, MAX_W)
	_table.set_metrics(_row_h, _avatar)
	call_deferred("_resize_to_content")

func _build() -> void :
	_panel = PanelContainer.new()
	_panel.name = "RightDrawer"


	_panel.anchor_left = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = - MIN_W
	_panel.offset_top = 90.0
	_panel.offset_right = -22.0


	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.offset_bottom = 490.0
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE



	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.22)
	box.set_corner_radius_all(UiStyle.RADIUS_SOFT)
	box.set_content_margin_all(0.0)
	_panel.add_theme_stylebox_override("panel", box)
	add_child(_panel)

	var margin: = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(margin)


	_table = ScoreTable.new()
	margin.add_child(_table)


func set_rows(rows: Array, local_peer: int, networked: bool, local_ping: = -1) -> void :
	_table.set_rows(rows, {"local_peer": local_peer, "networked": networked, 
		"local_ping": local_ping, "glass": true})
	call_deferred("_resize_to_content")


func open() -> void :
	if _open:
		return
	_open = true
	visible = true
	_slide(0.0, SLIDE_IN, Tween.EASE_OUT)

func close() -> void :
	if not _open:
		return
	_open = false
	_slide(_hidden_x, SLIDE_OUT, Tween.EASE_IN)

func _slide(to_x: float, dur: float, ease: Tween.EaseType) -> void :
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_panel, "offset_transform_position:x", to_x, dur)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(ease)
	if not _open:
		_tween.tween_callback( func(): visible = false)
