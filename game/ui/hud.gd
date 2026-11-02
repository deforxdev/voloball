class_name Hud
extends Control




const TOUCH_NAMES: = {
	Player.TouchKind.NONE: "--", 
	Player.TouchKind.BUMP: "bump", 
	Player.TouchKind.SET: "set", 
	Player.TouchKind.SPIKE: "spike", 
	Player.TouchKind.DUMP: "dump", 
	Player.TouchKind.BLOCK: "block", 
}
const STATS_DRAWER: = preload("res://game/ui/stats_drawer.gd")




var _hints: ControlHints = null

@onready var action_label: Label = $Readout / Box / ActionLabel
@onready var power_bar: ProgressBar = $Readout / Box / PowerBar
@onready var crosshair: Label = $Crosshair
@onready var touch_label: Label = $Readout / Box / TouchLabel
@onready var dive_label: Label = $Readout / Box / DiveLabel




var you_score: Label
var opp_score: Label
var _you_chip: Control
var _opp_chip: Control
var _you_name: Label
var _opp_name: Label
var _sb_set_you: Label
var _sb_set_opp: Label
var _sb_sub: Label
var _sb_target: Label
var _set_dots_you: Array = []
var _set_dots_opp: Array = []
var _sets_you: = 0
var _sets_opp: = 0
var _touch_pips: Array = []
var _touch_row: HBoxContainer
var _touch_box: Panel
var _touch_fade: Tween
var _touch_above: = false
var _point_tag: Label
var _roll_lock_you: = false
var _roll_lock_opp: = false
@onready var serve_label: Label = $ServeLabel
@onready var banner_label: Label = $BannerLabel
@onready var stats_panel: PanelContainer = $StatsPanel
@onready var chat: ChatPanel = get_node_or_null("Chat")
@onready var stats_grid: GridContainer = $StatsPanel / Box / Grid
var _stats_drawer: StatsDrawer
var _post_stats_board: ScoreTable
var _post_scroll: ScrollContainer
var _rewards: MatchRewards
var _stats_dark: = false







func set_hints_hidden(on: bool) -> void :
	if _hints != null:
		_hints.set_hidden(on)


func set_freeplay_controls(on: bool) -> void :
	if _hints != null:
		_hints.set_freeplay(on)

func set_practice_controls(on: bool) -> void :
	if _hints != null:
		_hints.set_practice(on)

func refresh_controls(p: Player, serving: bool) -> void :
	if _hints != null:
		_hints.refresh(p, serving)

func update_state(_player: Player) -> void :


	power_bar.visible = false
	action_label.visible = false

var _sight: TextureRect

func set_crosshair_visible(value: bool) -> void :
	crosshair.visible = value






func set_crosshair_side(point_z: float, in_bounds: = true) -> void :



	var c: = Color.WHITE
	if GameConfig.aim_color_cue and in_bounds:

		c = Rules.half_color(point_z)
	if _sight != null:
		_sight.modulate = c
	if _aim_cursor != null:
		_aim_cursor.modulate = c



var _ball_marker: OffscreenBall = null

func track_ball_marker(camera: Camera3D, ball: Node3D, active: bool, 
		near_to: Node3D = null) -> void :
	if _ball_marker == null:
		if not active:
			return
		_ball_marker = OffscreenBall.new()
		add_child(_ball_marker)



	if ball != null:
		var skin: = ""
		if "stage_ball" in ball:
			skin = String(ball.stage_ball)
		_ball_marker.ball_tex = PointWipe.ball_image_for(skin)
	var dist: = -1.0
	if ball != null and near_to != null:
		dist = ball.global_position.distance_to(near_to.global_position)
	_ball_marker.track(camera, 
		ball.global_position if ball != null else Vector3.ZERO, 
		active and ball != null, dist)






var _aim_cursor: TextureRect = null

const CROSSHAIR_PX: = 10.0
const OUTLINE_GROW: = 1.28
var _aim_shape: = ""
var _aim_outline: TextureRect = null

func set_aim_cursor(on: bool, pos: Vector2, color: = Color.WHITE, shape: = "", size: = 1.0, 
		outline: = Color(0, 0, 0, 0)) -> void :
	if not on:
		if _aim_cursor != null:
			_aim_cursor.visible = false
		if _aim_outline != null:
			_aim_outline.visible = false
		return
	if _aim_cursor == null:
		_aim_outline = TextureRect.new()
		_aim_cursor = TextureRect.new()
		for tr in [_aim_outline, _aim_cursor]:
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(tr)
		_aim_outline.z_index = 99
		_aim_cursor.z_index = 100
	if shape != _aim_shape:
		_aim_shape = shape
		var tex: Texture2D = Crosshair.tex(shape) if shape != ""\
		else GameConfig.aim_cursor_texture()
		_aim_cursor.texture = tex
		_aim_outline.texture = tex
	_aim_cursor.visible = _aim_cursor.texture != null
	_aim_cursor.modulate = color



	var k: = _pixel_scale()



	var box: = CROSSHAIR_PX * size if shape != ""\
	else float(_aim_cursor.texture.get_size().x) * k if _aim_cursor.texture != null else 0.0
	_aim_cursor.size = Vector2(box, box)
	_aim_cursor.position = pos - Vector2(box, box) * 0.5
	var ob: = box * OUTLINE_GROW
	_aim_outline.visible = _aim_cursor.visible and outline.a > 0.0
	_aim_outline.modulate = outline
	_aim_outline.size = Vector2(ob, ob)
	_aim_outline.position = pos - Vector2(ob, ob) * 0.5





func _build_crosshair() -> void :
	var src: Texture2D = load(GameConfig.CURSOR_AIM)
	if src == null:
		return
	var img: = src.get_image()
	var s: = GameConfig.CURSOR_SIZE
	img.resize(s, s, Image.INTERPOLATE_NEAREST)
	var rect: = TextureRect.new()
	rect.name = "Sight"
	rect.texture = ImageTexture.create_from_image(img)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	rect.anchor_left = 0.5
	rect.anchor_top = 0.5
	rect.anchor_right = 0.5
	rect.anchor_bottom = 0.5
	rect.offset_left = - s * 0.5
	rect.offset_top = - s * 0.5
	rect.offset_right = s * 0.5
	rect.offset_bottom = s * 0.5
	crosshair.add_child(rect)
	_sight = rect
	crosshair.text = ""



	rect.pivot_offset = Vector2(s, s) * 0.5
	_fit_sight(rect)
	get_viewport().size_changed.connect(_fit_sight.bind(rect))

func _fit_sight(rect: TextureRect) -> void :



	var k: = _pixel_scale() if _sight_shape == "" else 1.0
	rect.scale = Vector2(k, k)







var _sight_shape: = ""
var _sight_builtin: Texture2D = null
var _sight_outline: TextureRect = null

func set_sight_style(color: Color, shape: = "", size: = 1.0, 
		outline: = Color(0, 0, 0, 0)) -> void :
	if _sight == null:
		return
	if _sight_outline == null:
		_sight_builtin = _sight.texture
		_sight_outline = TextureRect.new()
		_sight_outline.name = "SightOutline"
		for tr in [_sight_outline, _sight]:
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.anchor_left = 0.5
			tr.anchor_top = 0.5
			tr.anchor_right = 0.5
			tr.anchor_bottom = 0.5
		crosshair.add_child(_sight_outline)
		crosshair.move_child(_sight_outline, _sight.get_index())
		_sight_shape = "\n"
	if shape != _sight_shape:
		_sight_shape = shape
		var tex: Texture2D = Crosshair.tex(shape) if shape != "" else _sight_builtin
		_sight.texture = tex
		_sight_outline.texture = tex
	var box: = CROSSHAIR_PX * size if shape != "" else float(GameConfig.CURSOR_SIZE)
	_centre_sight(_sight, box)
	_centre_sight(_sight_outline, box * OUTLINE_GROW)
	_sight.modulate = color
	_sight_outline.modulate = outline
	_sight_outline.visible = outline.a > 0.0

func _centre_sight(rect: TextureRect, box: float) -> void :
	rect.offset_left = - box * 0.5
	rect.offset_top = - box * 0.5
	rect.offset_right = box * 0.5
	rect.offset_bottom = box * 0.5
	rect.pivot_offset = Vector2(box, box) * 0.5
	_fit_sight(rect)

func _pixel_scale() -> float:
	var st: = get_viewport().get_screen_transform().get_scale()
	return 1.0 / st.x if st.x > 0.001 else 1.0




func chat_typing() -> bool:
	return chat != null and chat.is_typing()

func set_scoreboard_visible(value: bool) -> void :
	$Scoreboard.visible = value






const RALLY_FADE_TIME: = 3.0
var _sb_fade: Control = null
var _sb_fade_tween: Tween = null
var _sb_faded: = false

func rally_fade(live: bool) -> void :
	if _sb_fade == null:
		return
	live = live and GameConfig.fade_scoreboard
	if live == _sb_faded:
		return
	_sb_faded = live
	if _sb_fade_tween != null and _sb_fade_tween.is_valid():
		_sb_fade_tween.kill()
	_sb_fade_tween = create_tween().set_ignore_time_scale(true)
	if live:
		_sb_fade_tween.tween_property(_sb_fade, "modulate:a", 0.0, RALLY_FADE_TIME)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		_sb_fade_tween.tween_property(_sb_fade, "modulate:a", 1.0, 0.25)




var _replay_ui_hidden: = false
func _set_match_ui_hidden(hidden: bool) -> void :
	if hidden == _replay_ui_hidden:
		return
	_replay_ui_hidden = hidden
	var to: = 0.0 if hidden else 1.0
	var t: = create_tween().set_ignore_time_scale(true).set_parallel(true)
	t.tween_property($Scoreboard, "modulate:a", to, 0.22)
	if has_node("SweatBox"):
		t.tween_property($SweatBox, "modulate:a", to, 0.22)



	t.tween_property($SpectateBar, "modulate:a", to, 0.22)
	if _seat_tell != null:
		t.tween_property(_seat_tell, "modulate:a", to, 0.22)




var _score_side: = 0

func set_score_colors(my_side: int) -> void :
	if my_side == _score_side or my_side == 0:
		return
	_score_side = my_side
	_refresh_set_dots()

func set_play_hud_visible(value: bool) -> void :

	$Readout.visible = value
	if _hints != null:
		_hints.set_hidden( not value)

var _sweat: = 0.0
var _sweat_base: = Vector2.ZERO
var _sweat_base_set: = false
var _sweat_ticks: Array = []
var _sweat_tick_boxes: Array = []
var _sweat_drop: Polygon2D

var pause_pauses_tree: = true
var _net_stat_rows: Array = []

func _ready() -> void :
	_build_crosshair()
	_build_presentation()
	_build_stats_boards()
	_build_beta_watermark()
	_wire_pause()
	_ready_post()





func _build_beta_watermark() -> void :
	if not LaunchGate.public_beta():
		return
	var wm: = Label.new()
	wm.name = "BetaWatermark"
	wm.text = "beta build - content nonfinal"
	wm.anchor_left = 0.0
	wm.anchor_right = 1.0
	wm.anchor_top = 1.0
	wm.anchor_bottom = 1.0
	wm.offset_top = -46.0
	wm.offset_bottom = -14.0
	wm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wm.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	wm.add_theme_font_size_override("font_size", 22)
	wm.add_theme_color_override("font_color", Color(0, 0, 0, 0.45))
	wm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wm)









func _wire_pause() -> void :


	apply_pause_mode()
	($PauseMenu as PauseMenu).seat_requested.connect(
		func(side: int): seat_requested.emit(side))
	($PauseMenu as PauseMenu).opened.connect( func():


		set_aim_cursor(false, Vector2.ZERO)
		pause_opened.emit())
	($PauseMenu as PauseMenu).closed.connect( func(): pause_closed.emit())
	($PauseMenu as PauseMenu).couch_changed.connect( func(): couch_changed.emit())










func _build_presentation() -> void :
	_build_scoreboard()
	_build_sweat()
	_build_control_cards()
	_build_banner_card()


	_announcer = ANNOUNCER_SCRIPT.new()
	_announcer.name = "Announcer"
	add_child(_announcer)
	_build_loading_bar()
	_style_transient_labels()



	move_child($Loading, get_child_count() - 1)




func _build_loading_bar() -> void :
	var loading: ColorRect = $Loading
	loading.color = Color(0, 0, 0, 0)
	(loading.get_node("LoadingLabel") as Label).visible = false
	loading_cover = LoadingCover.new()
	loading_cover.name = "Cover"
	loading.add_child(loading_cover)





func _build_control_cards() -> void :


	var old: = get_node_or_null("Controls") as Control
	if old != null:
		old.name = "ControlsRetired"
	_hints = ControlHints.new()
	_hints.bind(DeviceInput.MERGED, null)
	add_child(_hints)
	_hints.name = "Controls"
	if old != null:
		remove_child(old)
		old.queue_free()





var _banner_card: PanelContainer

func _build_banner_card() -> void :
	var parent: = banner_label.get_parent()
	_banner_card = PanelContainer.new()
	_banner_card.name = "BannerCard"
	_banner_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b: = StyleBoxFlat.new()
	b.bg_color = UiStyle.card()
	b.set_corner_radius_all(UiStyle.RADIUS_SOFT)
	b.content_margin_left = 26.0
	b.content_margin_right = 26.0
	b.content_margin_top = 8.0
	b.content_margin_bottom = 10.0
	b.shadow_color = Color(0, 0, 0, 0.35) if UiStyle.dark else Color(UiStyle.INK, 0.16)
	b.shadow_size = 9
	b.shadow_offset = Vector2(0, 4)
	_banner_card.add_theme_stylebox_override("panel", b)
	_banner_card.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_banner_card.anchor_left = 0.5
	_banner_card.anchor_right = 0.5
	_banner_card.offset_top = 150.0
	_banner_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner_card.visible = false


	banner_label.visible = false
	var lbl: = Label.new()
	lbl.name = "BannerText"
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.add_theme_color_override("font_color", UiStyle.text())
	_banner_card.add_child(lbl)
	banner_label = lbl
	parent.add_child(_banner_card)







const SB_HOME: = Rules.HOME_COLOR
const SB_AWAY: = Rules.AWAY_COLOR
const SB_NAVY: = Color(0, 0, 0, 1)
const SB_MUTED: = Color(0.4, 0.45, 0.58)


const SB_SCALE: = 0.7
var _sb_col: Control = null
var _sb_punch: Tween = null
const ANNOUNCER_SCRIPT: = preload("res://game/audio/announcer.gd")
var _announcer: Node = null

var _announce_tween: Tween = null
var _announced_state: = ""

var _big_board: Control = null
var _big_home_num: Label = null
var _big_away_num: Label = null
var _big_home_bar: Control = null
var _big_away_bar: Control = null
var _big_cine: Tween = null
var _cine_tweens: Array = []
var _big_home_sb: StyleBoxFlat = null
var _big_away_sb: StyleBoxFlat = null
const BIG_HOME_X: = 0.0
const BIG_AWAY_X: = 110.0
const BIG_W: = 200.0




var _kf_hero: Control = null
var _kf_hero_tex: TextureRect = null
var _kf_hero_ring: StyleBoxFlat = null
var _kf_name: Control = null

var _kf_tag: Label = null
var _kf_tag_box: Panel = null
var _kf_hero_home: = true
var _kf_tag_sb: StyleBoxFlat = null
var _kf_villain: Control = null
var _kf_villain_tex: TextureRect = null
var _kf_villain_ring: StyleBoxFlat = null
var _kf_villain_cap: Label = null




const KF_HERO_DIA: = 96.0
const KF_TAG_PX: = 24
const KF_TAG_H: = 36.0
const KF_NAME_PX: = 24
const KF_VILLAIN_DIA: = 44.0

const KF_TAGS: = {
	"spike": ["spike", Color(1.0, 0.55, 0.15)], 
	"dump": ["dump", Color(0.45, 0.7, 1.0)], 
	"ace": ["ace", Color(1.0, 0.82, 0.2)], 
	"block out": ["block out", Color(1.0, 0.35, 0.5)], 
	"kill": ["point", Color(0.5, 0.8, 0.45)], 

	"out": ["out", Color(0.95, 0.4, 0.4)], 
	"fault": ["fault", Color(0.9, 0.5, 0.35)], 
	"foot fault": ["foot fault", Color(0.9, 0.5, 0.35)], 
	"error": ["error", Color(0.6, 0.64, 0.75)], 
}

func _build_scoreboard() -> void :
	var host: Control = $Scoreboard
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE


	var col: = VBoxContainer.new()
	col.name = "CenterColumn"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 7)
	col.set_anchors_preset(Control.PRESET_CENTER_TOP)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH


	col.offset_top = -14.0


	_sb_fade = Control.new()
	_sb_fade.name = "RallyFade"
	_sb_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sb_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(_sb_fade)
	_sb_fade.add_child(col)


	_sb_col = col
	col.pivot_offset = Vector2(195, 0)
	col.scale = Vector2(SB_SCALE, SB_SCALE)





	var board: = VBoxContainer.new()
	board.name = "Board"
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_theme_constant_override("separation", 0)
	col.add_child(board)



	var backing = preload("res://game/ui/scoreboard_shell.gd").new()
	board.add_child(backing)



	var main: = PanelContainer.new()
	main.name = "MainScoreboard"
	main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.custom_minimum_size = Vector2(390, 56)
	var mb: = StyleBoxFlat.new()
	mb.bg_color = Color.TRANSPARENT
	mb.set_corner_radius_all(28)
	mb.content_margin_left = 3
	mb.content_margin_right = 3


	mb.content_margin_top = 22
	mb.content_margin_bottom = 0
	mb.shadow_color = Color(0.1, 0.13, 0.28, 0.3)
	mb.shadow_size = 0
	mb.shadow_offset = Vector2(0, 4)
	main.add_theme_stylebox_override("panel", mb)
	board.add_child(main)

	var row: = HBoxContainer.new()
	row.name = "ScoreRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 0)
	main.add_child(row)


	_you_name = _cap_label("home")
	_you_chip = _cap(SB_HOME, _you_name, true)
	row.add_child(_you_chip)


	you_score = _sb_num()
	you_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	you_score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(you_score)
	var dash: = Label.new()
	dash.name = "Divider"
	dash.text = "—"
	dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dash.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dash.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	dash.add_theme_font_size_override("font_size", 28)
	dash.add_theme_color_override("font_color", Color.WHITE)
	dash.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	dash.add_theme_constant_override("outline_size", 8)
	dash.custom_minimum_size = Vector2(56, 0)
	dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(dash)
	opp_score = _sb_num()
	opp_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	opp_score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(opp_score)
	_opp_name = _cap_label("away")
	_opp_chip = _cap(SB_AWAY, _opp_name, false)
	row.add_child(_opp_chip)





	var setcap: = PanelContainer.new()
	setcap.name = "SetTab"
	setcap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	setcap.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	setcap.custom_minimum_size = Vector2(0, 24)
	var sb: = StyleBoxFlat.new()


	sb.bg_color = Color.TRANSPARENT
	sb.corner_radius_bottom_left = 16
	sb.corner_radius_bottom_right = 16
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 1
	sb.content_margin_bottom = 3
	setcap.add_theme_stylebox_override("panel", sb)
	board.add_child(setcap)
	board.resized.connect( func(): backing.fit(board.size, setcap.size))
	setcap.resized.connect( func(): backing.fit(board.size, setcap.size))



	var setrow: = HBoxContainer.new()
	setrow.name = "SetRow"
	setrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	setrow.alignment = BoxContainer.ALIGNMENT_CENTER
	setrow.add_theme_constant_override("separation", 9)
	setcap.add_child(setrow)
	_sb_sub = _sub_label("set 1", HORIZONTAL_ALIGNMENT_LEFT)
	setrow.add_child(_sb_sub)
	var need: = maxi(1, GameConfig.sets_to_win)
	_set_dots_you = _set_dot_group(setrow, need)


	var bar: = Panel.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.custom_minimum_size = Vector2(2, 13)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bs: = StyleBoxFlat.new()
	bs.bg_color = SB_MUTED
	bs.set_corner_radius_all(1)
	bar.add_theme_stylebox_override("panel", bs)
	setrow.add_child(bar)
	_set_dots_opp = _set_dot_group(setrow, need)
	_refresh_set_dots()


	_sb_target = _sub_label("", HORIZONTAL_ALIGNMENT_RIGHT)
	_sb_target.add_theme_color_override("font_color", SB_MUTED)
	_sb_target.add_theme_constant_override("outline_size", 0)
	setrow.add_child(_sb_target)
	_refresh_target()



	_build_touch_counter(col)

	_point_tag = Label.new()
	_point_tag.name = "PointTag"
	_point_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_point_tag.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_point_tag.add_theme_font_size_override("font_size", 26)
	_point_tag.add_theme_constant_override("outline_size", 7)
	_point_tag.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	_point_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_point_tag.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_point_tag.custom_minimum_size = Vector2(200, 0)
	_point_tag.position = Vector2(-100, 100)
	_point_tag.visible = false
	add_child(_point_tag)
	_build_big_board()


func _cap(fill: Color, label: Label, home: bool) -> PanelContainer:
	var p: = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.custom_minimum_size = Vector2(84, 44)
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	if home:
		b.corner_radius_top_left = 25
		b.corner_radius_bottom_left = 25
		b.corner_radius_top_right = 5
		b.corner_radius_bottom_right = 5
	else:
		b.corner_radius_top_right = 25
		b.corner_radius_bottom_right = 25
		b.corner_radius_top_left = 5
		b.corner_radius_bottom_left = 5
	p.add_theme_stylebox_override("panel", b)
	p.add_child(label)
	return p

func _cap_label(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 7)
	return l


func _dot_solid(color: Color) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(99)
	b.corner_detail = 12
	return b

func _dot_ring() -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = UiStyle.card()
	b.set_corner_radius_all(99)
	b.corner_detail = 12
	b.set_border_width_all(2)
	b.border_color = SB_MUTED
	return b


func _set_dot_group(parent: HBoxContainer, n: int) -> Array:
	var group: = HBoxContainer.new()
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_theme_constant_override("separation", 5)
	parent.add_child(group)
	var out: Array = []
	for i in n:
		var dot: = Panel.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		group.add_child(dot)
		out.append(dot)
	return out



func _build_touch_counter(col: VBoxContainer) -> void :
	var box: = Panel.new()
	box.name = "TouchCounter"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size = Vector2(66, 24)
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bb: = StyleBoxFlat.new()

	bb.bg_color = UiStyle.card()
	bb.set_corner_radius_all(12)
	bb.shadow_color = Color(0.3, 0.34, 0.45, 0.22)
	bb.shadow_size = 3
	bb.shadow_offset = Vector2(0, 2)
	bb.content_margin_left = 10
	bb.content_margin_right = 10
	box.add_theme_stylebox_override("panel", bb)
	box.visible = false
	col.add_child(box)
	_touch_box = box
	var pips: = HBoxContainer.new()
	pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pips.set_anchors_preset(Control.PRESET_FULL_RECT)
	pips.alignment = BoxContainer.ALIGNMENT_CENTER
	pips.add_theme_constant_override("separation", 7)
	box.add_child(pips)
	_touch_row = pips
	_touch_pips = []
	for i in 3:
		var dot: = Panel.new()
		dot.custom_minimum_size = Vector2(9, 9)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pips.add_child(dot)
		_touch_pips.append(dot)
	_paint_touch(0)

func set_touch_placement(_above: bool) -> void :
	pass

func _sb_num() -> Label:
	var l: = Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.text = "00"
	l.custom_minimum_size = Vector2(40, 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 33)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 8)
	return l



func _sb_set_num() -> Label:
	var l: = Label.new()
	l.text = "0"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 16)
	return l

func _sb_name(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", UiStyle.text())
	return l



func _score_row(name: Label, score: Label) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size = Vector2(134, 0)
	row.add_theme_constant_override("separation", 9)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	row.add_child(score)
	return row


func _stripe(fill: Color, top: bool) -> Panel:
	var p: = Panel.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size = Vector2(7, 38)
	p.set_meta("top_tab", top)
	_paint_stripe(p, fill)
	return p

func _paint_stripe(p: Panel, fill: Color) -> void :
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	if bool(p.get_meta("top_tab", true)):
		b.corner_radius_top_left = 2
	else:
		b.corner_radius_bottom_left = 2
	p.add_theme_stylebox_override("panel", b)

func _pip_box(fill: Color) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	b.set_corner_radius_all(99)
	return b

func _score_info_muted() -> Color:


	return Color(1.0, 1.0, 1.0, 0.62)




const _TOUCH_LIGHT: = [UiStyle.SUCCESS, UiStyle.PRIMARY, UiStyle.RED]

func _paint_touch(count: int) -> void :
	for i in _touch_pips.size():
		var dot: Panel = _touch_pips[i]
		if i < count:
			dot.add_theme_stylebox_override("panel", _dot_solid(_TOUCH_LIGHT[i]))
		else:
			dot.add_theme_stylebox_override("panel", _dot_ring())



func _paint_set_score_colors() -> void :
	_refresh_set_dots()



func _sub_label(text: String, align: int) -> Label:
	var l: = Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_color", Color.WHITE)
	return l



func _refresh_target() -> void :
	if _sb_target == null:
		return
	_sb_target.text = "to %d" % maxi(1, GameConfig.set_points)


func _refresh_set_dots() -> void :
	for i in _set_dots_you.size():
		(_set_dots_you[i] as Panel).add_theme_stylebox_override("panel", 
			_dot_solid(SB_HOME) if i < _sets_you else _dot_ring())
	for i in _set_dots_opp.size():
		(_set_dots_opp[i] as Panel).add_theme_stylebox_override("panel", 
			_dot_solid(SB_AWAY) if i < _sets_opp else _dot_ring())






const SWEAT_TICKS: = 7

func _build_sweat() -> void :
	var box: Control = $SweatBox
	box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: = HBoxContainer.new()
	row.name = "Ticks"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 3)
	box.add_child(row)


	var drop_host: = Control.new()
	drop_host.custom_minimum_size = Vector2(11, 11)
	drop_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sweat_drop = Polygon2D.new()
	var pts: = PackedVector2Array()
	pts.append(Vector2(7.5, 0.0))
	for i in 13:

		var a: = deg_to_rad(-50.0 + 260.0 * float(i) / 12.0)
		pts.append(Vector2(7.5, 9.2) + Vector2(cos(a), sin(a)) * 5.4)
	_sweat_drop.polygon = pts
	_sweat_drop.color = Color(0.35, 0.7, 1.0)
	drop_host.add_child(_sweat_drop)
	row.add_child(drop_host)
	for i in SWEAT_TICKS:
		var tick: = Panel.new()
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.custom_minimum_size = Vector2(9, 8)
		var b: = StyleBoxFlat.new()
		b.set_corner_radius_all(4)
		b.bg_color = Color(0.08, 0.1, 0.16, 0.38)
		tick.add_theme_stylebox_override("panel", b)
		row.add_child(tick)
		_sweat_ticks.append(tick)
		_sweat_tick_boxes.append(b)



func _place_sweat() -> void :
	var box: Control = $SweatBox
	var row: = box.get_node_or_null("Ticks") as Control
	var w: = row.size.x if row != null and row.size.x > 1.0 else 150.0
	box.size.x = w
	_sweat_base = Vector2($Scoreboard.size.x * 0.5 - w * 0.5, 122.0)
	_sweat_base_set = true
	box.position = _sweat_base

func _style_transient_labels() -> void :



	serve_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	serve_label.add_theme_font_size_override("font_size", 17)
	serve_label.add_theme_constant_override("outline_size", 6)
	serve_label.add_theme_color_override("font_color", Color.WHITE)
	serve_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))

	banner_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))










func _big_center_x() -> float:
	return $Scoreboard.size.x * 0.5 - BIG_W * 0.5

func _build_big_board() -> void :
	var b: = Control.new()
	b.name = "BigBoard"
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.set_anchors_preset(Control.PRESET_TOP_LEFT)
	b.custom_minimum_size = Vector2(BIG_W, 72)
	b.size = b.custom_minimum_size
	b.pivot_offset = Vector2(BIG_W * 0.5, 0)
	b.position = Vector2(_big_center_x(), 44)
	b.modulate.a = 0.0
	b.visible = false
	$Scoreboard.add_child(b)
	_big_board = b

	_big_home_bar = _big_bar(SB_HOME, true)
	_big_home_bar.position = Vector2(BIG_HOME_X, 4)
	b.add_child(_big_home_bar)
	_big_away_bar = _big_bar(SB_AWAY, false)
	_big_away_bar.position = Vector2(BIG_AWAY_X, 4)
	b.add_child(_big_away_bar)


	var dash: = Panel.new()
	dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dash.size = Vector2(18, 8)
	dash.position = Vector2(BIG_W * 0.5 - 9, 30)
	var db: = StyleBoxFlat.new()
	db.bg_color = UiStyle.card()
	db.set_corner_radius_all(4)
	dash.add_theme_stylebox_override("panel", db)
	b.add_child(dash)
	_build_kill_feed(b)




func _build_kill_feed(b: Control) -> void :
	var hero: = _make_badge(KF_HERO_DIA, SB_HOME)
	_kf_hero = hero[0]
	_kf_hero_tex = hero[1]
	_kf_hero_ring = hero[2]
	b.add_child(_kf_hero)
	_kf_name = Control.new()
	_kf_name.name = "KfName"
	_kf_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(_kf_name)


	_kf_tag_box = Panel.new()
	_kf_tag_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_kf_tag_sb = StyleBoxFlat.new()
	_kf_tag_sb.bg_color = KF_TAGS["spike"][1]
	_kf_tag_sb.set_corner_radius_all(16)
	_kf_tag_sb.corner_detail = 10
	_kf_tag_sb.border_width_bottom = UiStyle.EDGE
	_kf_tag_sb.shadow_color = Color(0.1, 0.13, 0.28, 0.3)
	_kf_tag_sb.shadow_size = 5
	_kf_tag_sb.shadow_offset = Vector2(0, 3)
	_kf_tag_box.add_theme_stylebox_override("panel", _kf_tag_sb)
	b.add_child(_kf_tag_box)
	_kf_tag = _kf_label(KF_TAG_PX)
	_kf_tag.add_theme_color_override("font_outline_color", UiStyle.INK)
	_kf_tag.add_theme_constant_override("outline_size", 10)
	_kf_tag.set_anchors_preset(Control.PRESET_FULL_RECT)
	_kf_tag.offset_bottom = -3.0
	_kf_tag_box.add_child(_kf_tag)

	var vil: = _make_badge(KF_VILLAIN_DIA, SB_AWAY)
	_kf_villain = vil[0]
	_kf_villain_tex = vil[1]
	_kf_villain_ring = vil[2]
	b.add_child(_kf_villain)
	_kf_villain_cap = _kf_label(12)
	_kf_villain_cap.custom_minimum_size = Vector2(160, 0)
	b.add_child(_kf_villain_cap)
	for n in [_kf_hero, _kf_name, _kf_tag_box, _kf_villain, _kf_villain_cap]:
		(n as CanvasItem).visible = false



func _make_badge(dia: float, ring: Color) -> Array:
	var root: = Panel.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.custom_minimum_size = Vector2(dia, dia)
	root.size = Vector2(dia, dia)
	root.pivot_offset = Vector2(dia * 0.5, dia * 0.5)
	root.clip_contents = true
	var pb: = StyleBoxFlat.new()
	pb.bg_color = ring
	pb.set_corner_radius_all(int(dia * 0.5))
	pb.corner_detail = 12
	pb.set_border_width_all(4)
	pb.border_color = Color.WHITE
	pb.shadow_color = Color(0.1, 0.13, 0.28, 0.35)
	pb.shadow_size = 6
	pb.shadow_offset = Vector2(0, 3)
	root.add_theme_stylebox_override("panel", pb)
	var tex: = TextureRect.new()
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex.offset_left = 4
	tex.offset_top = 6
	tex.offset_right = -4
	tex.offset_bottom = -2
	root.add_child(tex)
	return [root, tex, pb]

func _kf_label(size: int) -> Label:
	var l: = Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 5)
	return l



func _kf_load_portrait(tex: TextureRect, cfg: Dictionary) -> void :



	tex.texture = null
	var gen: = int(tex.get_meta("kf_gen", 0)) + 1
	tex.set_meta("kf_gen", gen)
	if cfg.is_empty():
		return
	var t: ImageTexture = await CharacterPortrait.head_cached(cfg, self, "lobby")
	if is_instance_valid(tex) and int(tex.get_meta("kf_gen", 0)) == gen:
		tex.texture = t



func _big_bar(fill: Color, home: bool) -> Control:
	var bar: = Control.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.custom_minimum_size = Vector2(90, 60)
	bar.size = bar.custom_minimum_size
	bar.pivot_offset = Vector2(45, 30)
	var cap: = Panel.new()
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.size = Vector2(90, 60)
	var cb: = StyleBoxFlat.new()
	cb.bg_color = fill
	cb.set_corner_radius_all(30)
	cb.shadow_color = Color(0.1, 0.13, 0.28, 0.3)
	cb.shadow_size = 6
	cb.shadow_offset = Vector2(0, 3)
	cap.add_theme_stylebox_override("panel", cb)
	bar.add_child(cap)
	if home:
		_big_home_sb = cb
	else:
		_big_away_sb = cb

	var num: = Label.new()
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num.text = "0"
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	num.add_theme_font_size_override("font_size", 50)
	num.add_theme_color_override("font_color", Color.WHITE)
	num.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	num.add_theme_constant_override("outline_size", 12)
	num.size = Vector2(90, 60)
	num.pivot_offset = Vector2(45, 30)
	num.position = Vector2(0, 0)
	bar.add_child(num)
	if home:
		_big_home_num = num
	else:
		_big_away_num = num
	return bar







func _cine_reset() -> void :
	for t in _cine_tweens:
		if t != null and t.is_valid():
			t.kill()
	_cine_tweens.clear()
	if _big_board == null:
		return
	_big_board.scale = Vector2.ONE
	_big_home_bar.scale = Vector2.ONE
	_big_away_bar.scale = Vector2.ONE
	_big_home_bar.modulate = Color.WHITE
	_big_away_bar.modulate = Color.WHITE
	_big_home_num.scale = Vector2.ONE
	_big_away_num.scale = Vector2.ONE
	if _big_home_sb != null:
		_big_home_sb.bg_color = SB_HOME
		_big_away_sb.bg_color = SB_AWAY


	for n in [_kf_hero, _kf_name, _kf_tag_box, _kf_villain, _kf_villain_cap]:
		if n != null:
			(n as CanvasItem).visible = false
			(n as CanvasItem).scale = Vector2.ONE
			(n as CanvasItem).modulate.a = 1.0
	$SweatBox.modulate.a = 1.0
	for c in _big_board.get_children():
		if String(c.name).begins_with("clashfx"):
			c.queue_free()

func point_cinematic(winner_side: int, home_score: int, away_score: int, 
		feed: Dictionary = {}) -> void :
	if _big_board == null:
		return
	_cine_reset()
	var winner_home: = winner_side >= 0
	_big_home_num.text = str(home_score - (1 if winner_home else 0))
	_big_away_num.text = str(away_score - (0 if winner_home else 1))
	_big_board.pivot_offset = Vector2(BIG_W * 0.5, 36.0)

	_big_board.visible = true
	var bx: = _big_center_x()
	_big_board.position = Vector2(bx, 44)
	_big_home_bar.position.x = - (bx + 320.0)
	_big_away_bar.position.x = $Scoreboard.size.x - bx


	_big_cine = create_tween().set_ignore_time_scale(true).set_parallel(true)
	_cine_tweens.append(_big_cine)
	_big_cine.tween_property(_big_board, "modulate:a", 1.0, 0.12)
	if _sb_col != null:
		_big_cine.tween_property(_sb_col, "modulate:a", 0.0, 0.12)
	_big_cine.tween_property($SweatBox, "modulate:a", 0.0, 0.12)
	_big_cine.tween_property(_big_home_bar, "position:x", BIG_HOME_X, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_big_cine.tween_property(_big_away_bar, "position:x", BIG_AWAY_X, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	var wb: Control = _big_home_bar if winner_home else _big_away_bar
	var lb: Control = _big_away_bar if winner_home else _big_home_bar
	var wn: Label = _big_home_num if winner_home else _big_away_num
	var final_val: = home_score if winner_home else away_score

	wb.pivot_offset = Vector2(90.0 if winner_home else 0.0, 30.0)
	lb.pivot_offset = Vector2(0.0 if winner_home else 90.0, 30.0)


	_place_kill_feed(feed)


	var clash: = create_tween().set_ignore_time_scale(true)
	_cine_tweens.append(clash)
	clash.tween_interval(0.24)
	clash.tween_callback( func():
		_flash_caps()
		_shake_board()
		_clash_burst())
	clash.tween_property(_big_board, "scale", Vector2(0.78, 1.26), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	clash.tween_property(_big_board, "scale", Vector2(1.16, 0.86), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	clash.tween_property(_big_board, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)



	var grow: = create_tween().set_ignore_time_scale(true).set_parallel(true)
	_cine_tweens.append(grow)
	grow.tween_interval(0.3)
	grow.chain().tween_property(wb, "scale", Vector2(1.42, 1.42), 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	grow.parallel().tween_property(lb, "scale", Vector2(0.6, 0.6), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	grow.parallel().tween_property(lb, "modulate:a", 0.55, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if _kf_hero.visible:
		grow.parallel().tween_interval(0.3)
		var pop: = create_tween().set_ignore_time_scale(true).set_parallel(true)
		_cine_tweens.append(pop)
		pop.tween_interval(0.34)
		var hhome: = _kf_hero_home

		_kf_hero.modulate.a = 0.0
		_kf_hero.scale = Vector2(0.35, 0.35)
		_kf_hero.rotation = -0.6 if hhome else 0.6
		pop.parallel().tween_property(_kf_hero, "modulate:a", 1.0, 0.12)
		pop.parallel().tween_property(_kf_hero, "scale", Vector2.ONE, 0.55)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		pop.parallel().tween_property(_kf_hero, "rotation", 0.0, 0.45)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop.chain().tween_callback( func():
			if _kf_hero.visible:
				UiStyle.click_burst(_kf_hero, _kf_hero_ring.bg_color))

		var slab: = create_tween().set_ignore_time_scale(true).set_parallel(true)
		_cine_tweens.append(slab)
		var rest_x: = _kf_tag_box.position.x
		_kf_tag_box.modulate.a = 0.0
		_kf_tag_box.position.x = rest_x + (-70.0 if hhome else 70.0)
		_kf_tag_box.scale = Vector2(1.35, 1.35)
		slab.tween_interval(0.44)
		slab.chain().tween_property(_kf_tag_box, "modulate:a", 1.0, 0.08)
		slab.parallel().tween_property(_kf_tag_box, "position:x", rest_x, 0.26)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		slab.parallel().tween_property(_kf_tag_box, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		slab.chain().tween_callback( func(): UiStyle.sfx(INTRO_SFX_SLAB))

		var rest: = create_tween().set_ignore_time_scale(true).set_parallel(true)
		_cine_tweens.append(rest)
		rest.tween_interval(0.56)
		for n in [_kf_name, _kf_villain, _kf_villain_cap]:
			if n.visible:
				n.modulate.a = 0.0
				n.scale = Vector2(0.6, 0.6)
				rest.parallel().tween_property(n, "modulate:a", 1.0, 0.15)
				rest.parallel().tween_property(n, "scale", Vector2.ONE, 0.5)\
				.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


	var num: = create_tween().set_ignore_time_scale(true)
	_cine_tweens.append(num)
	num.tween_interval(0.3)
	num.tween_callback( func(): wn.text = str(final_val))
	num.tween_property(wn, "scale", Vector2(1.18, 1.18), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	num.tween_property(wn, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)






	var outro: = create_tween().set_ignore_time_scale(true)
	_cine_tweens.append(outro)
	outro.tween_interval(1.8)
	outro.tween_property(_big_board, "modulate:a", 0.0, 0.22)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	outro.parallel().tween_property(_big_board, "scale", Vector2(0.72, 0.72), 0.22)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	outro.chain().tween_callback( func(): _big_board.visible = false)
	if _sb_col != null:
		outro.tween_property(_sb_col, "modulate:a", 1.0, 0.2)
	outro.parallel().tween_property($SweatBox, "modulate:a", 1.0, 0.2)
	UiStyle.sfx("open")




func _place_kill_feed(feed: Dictionary) -> void :
	var tag_key: = String(feed.get("tag", ""))
	var hero: Dictionary = feed.get("hero", {})
	var villain: Dictionary = feed.get("villain", {})
	if tag_key == "":
		return
	var tag_info: Array = KF_TAGS.get(tag_key, [tag_key, Color(0.5, 0.8, 0.45)])
	var tag_col: Color = tag_info[1]

	var earned: = tag_key in ["spike", "dump", "ace", "block out", "kill"]
	_kf_tag.text = String(tag_info[0]) + ("!" if earned else "")
	_kf_tag_sb.bg_color = tag_col
	_kf_tag_sb.border_color = tag_col.darkened(0.28)
	var pill_w: = _kf_tag.get_theme_font("font").get_string_size(_kf_tag.text, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, KF_TAG_PX).x + 40.0
	_kf_tag_box.custom_minimum_size = Vector2(pill_w, KF_TAG_H)
	_kf_tag_box.size = Vector2(pill_w, KF_TAG_H)
	_kf_tag_box.pivot_offset = _kf_tag_box.size * 0.5
	_kf_tag_box.rotation = 0.0

	if hero.is_empty():

		_kf_hero.visible = false
		_kf_name.visible = false
		_kf_villain.visible = false
		_kf_villain_cap.visible = false
		_kf_tag_box.visible = true
		_kf_tag_box.position = Vector2(BIG_W * 0.5 - pill_w * 0.5, 82.0)
		_kf_tag_box.rotation = - SLAB_TILT * 0.6
		return



	var hhome: = bool(hero.get("home", true))
	_kf_hero_home = hhome
	_kf_hero_ring.bg_color = SB_HOME if hhome else SB_AWAY
	var hero_x: = (BIG_HOME_X - KF_HERO_DIA - 44.0) if hhome\
	else (BIG_AWAY_X + 90.0 + 44.0)
	_kf_hero.position = Vector2(hero_x, -12.0)
	_kf_hero.visible = true
	_kf_load_portrait(_kf_hero_tex, hero.get("cfg", {}))
	var hcx: = hero_x + KF_HERO_DIA * 0.5


	_kf_tag_box.position = Vector2(hcx - pill_w * 0.5, KF_HERO_DIA - 30.0)
	_kf_tag_box.rotation = SLAB_TILT if hhome else - SLAB_TILT
	_kf_tag_box.visible = true


	for c in _kf_name.get_children():
		c.queue_free()
	var nm: = String(hero.get("name", ""))
	var cfg: Dictionary = hero.get("cfg", {})
	var is_cpu: = nm.ends_with("(CPU)")
	var style: Dictionary = {} if is_cpu else (cfg.get("ttl", {}) as Dictionary)
	_kf_name.visible = nm != ""
	if _kf_name.visible:
		var pill: Control = NAME_PILL.new()
		pill.party = 0 if is_cpu else int(hero.get("pg", 0))
		_kf_name.add_child(pill)
		pill.show_name(nm.trim_suffix(" (CPU)"), style, KF_NAME_PX, false, "", 
			0 if is_cpu else int(cfg.get("lvl", 0)))
		var sz: Vector2 = pill.custom_minimum_size
		_kf_name.size = sz
		_kf_name.pivot_offset = Vector2(sz.x * 0.5, 0.0)
		_kf_name.position = Vector2(hcx - sz.x * 0.5, KF_HERO_DIA + 12.0)

	if villain.is_empty():
		_kf_villain.visible = false
		_kf_villain_cap.visible = false
	else:
		var vhome: = bool(villain.get("home", true))
		if _kf_villain_ring != null:
			_kf_villain_ring.bg_color = SB_HOME if vhome else SB_AWAY
		var vx: = (BIG_HOME_X - KF_VILLAIN_DIA - 12.0) if vhome\
		else (BIG_AWAY_X + 90.0 + 12.0)
		_kf_villain.position = Vector2(vx, 6.0)
		_kf_villain.visible = true
		_kf_load_portrait(_kf_villain_tex, villain.get("cfg", {}))
		var vcx: = vx + KF_VILLAIN_DIA * 0.5
		_kf_villain_cap.text = "blocked out\nby %s" % String(villain.get("name", "")).trim_suffix(" (CPU)")
		_kf_villain_cap.position = Vector2(vcx - 80.0, KF_VILLAIN_DIA + 8.0)
		_kf_villain_cap.visible = true


func _clash_burst() -> void :
	if _big_board == null:
		return
	UiStyle.click_burst(_big_board, Color.WHITE)


func _flash_caps() -> void :
	if _big_home_sb == null:
		return
	_big_home_sb.bg_color = Color.WHITE
	_big_away_sb.bg_color = Color.WHITE
	var t: = create_tween().set_ignore_time_scale(true).set_parallel(true)
	_cine_tweens.append(t)
	t.tween_property(_big_home_sb, "bg_color", SB_HOME, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(_big_away_sb, "bg_color", SB_AWAY, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _shake_board() -> void :
	if _big_board == null:
		return
	var base: = Vector2(_big_center_x(), 44)
	var sh: = _big_board.create_tween().set_ignore_time_scale(true)
	_cine_tweens.append(sh)
	for i in 6:
		var k: = 1.0 - float(i) / 6.0
		sh.tween_property(_big_board, "position", 
			base + Vector2(randf_range(-9, 9), randf_range(-5, 5)) * k, 0.04)
	sh.tween_property(_big_board, "position", base, 0.04)


func _spawn_flash(local_pos: Vector2) -> void :
	if _big_board == null:
		return
	var f: = Panel.new()
	f.name = "clashfx_flash"
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.size = Vector2(84, 84)
	f.position = local_pos - f.size * 0.5
	f.pivot_offset = f.size * 0.5
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(1, 1, 1, 0.9)
	fb.set_corner_radius_all(99)
	fb.corner_detail = 16
	f.add_theme_stylebox_override("panel", fb)
	f.scale = Vector2(0.3, 0.3)
	_big_board.add_child(f)
	var t: = f.create_tween().set_ignore_time_scale(true).set_parallel(true)
	t.tween_property(f, "scale", Vector2(3.0, 3.0), 0.34)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(f, "modulate:a", 0.0, 0.34)
	t.chain().tween_callback(f.queue_free)

	for i in 8:
		var ang: = TAU * float(i) / 8.0 + 0.2
		var line: = Panel.new()
		line.name = "clashfx_line"
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.size = Vector2(16, 5)
		line.pivot_offset = line.size * 0.5
		line.rotation = ang
		line.position = local_pos - line.size * 0.5
		var lb2: = StyleBoxFlat.new()
		lb2.bg_color = Color(1, 1, 1, 0.95)
		lb2.set_corner_radius_all(3)
		line.add_theme_stylebox_override("panel", lb2)
		_big_board.add_child(line)
		var dir: = Vector2(cos(ang), sin(ang))
		var lt: = line.create_tween().set_ignore_time_scale(true).set_parallel(true)
		lt.tween_property(line, "position", 
			local_pos - line.size * 0.5 + dir * 54.0, 0.34)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		lt.tween_property(line, "modulate:a", 0.0, 0.34)
		lt.chain().tween_callback(line.queue_free)

func point_moment(winner_side: int, my_side: int, _reason: String, 
		home_score: int, away_score: int, feed: Dictionary = {}) -> void :
	if you_score == null:
		return
	rally_fade(false)
	var mine: = winner_side == my_side
	var you: = home_score if my_side > 0 else away_score
	var opp: = away_score if my_side > 0 else home_score
	var new_val: = you if mine else opp
	var l: Label = you_score if mine else opp_score


	if mine:
		_roll_lock_you = true
	else:
		_roll_lock_opp = true
	l.text = "%d" % maxi(new_val - 1, 0)
	l.offset_transform_enabled = true
	l.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	var t: = l.create_tween()
	t.set_ignore_time_scale(true)
	t.tween_interval(0.12)
	t.tween_callback( func():
		l.text = "%d" % new_val


		UiStyle.click_burst(l, SB_HOME if mine else SB_AWAY))
	t.tween_property(l, "offset_transform_scale", Vector2(1.5, 1.5), 0.12)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(l, "offset_transform_scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_callback( func():
		_roll_lock_you = false
		_roll_lock_opp = false)





	point_cinematic(1 if mine else -1, you, opp, feed)

func _flash_point_tag(color: Color) -> void :
	if _point_tag == null:
		return
	_point_tag.text = "point!"
	_point_tag.add_theme_color_override("font_color", color)
	_point_tag.visible = true
	UiStyle.pop_in(_point_tag)
	var t: = create_tween()
	t.set_ignore_time_scale(true)
	t.tween_interval(1.4)
	t.tween_property(_point_tag, "modulate:a", 0.0, 0.4)
	t.tween_callback( func(): _point_tag.visible = false)

func hide_point_moment() -> void :
	if _point_tag != null:
		_point_tag.visible = false

func spectate_controls() -> ViewControls:
	return $SpectateBar / Controls as ViewControls

func set_spectating(on: bool) -> void :
	$SpectateBar.visible = on




func set_play_ui_visible(on: bool) -> void :
	$Readout.visible = on
	if _hints != null:
		_hints.set_hidden( not on)


func set_watch_ui_visible(on: bool) -> void :
	$SpectateBar.visible = on
	$Scoreboard.visible = on


	if has_node("SweatBox"):
		$SweatBox.visible = on


signal seat_requested(side: int)

signal pause_opened
signal pause_closed

func set_teams_available(on: bool) -> void :
	($PauseMenu as PauseMenu).set_teams_available(on)


signal couch_changed

func set_dropin_available(on: bool, room_fn: = Callable(), seated_fn: = Callable()) -> void :
	($PauseMenu as PauseMenu).set_dropin_available(on, room_fn, seated_fn)

func open_teams() -> void :
	($PauseMenu as PauseMenu).open_teams()



func teams_open() -> bool:
	return ($PauseMenu as PauseMenu)._teams_up()


func set_teams_source(state_fn: Callable) -> void :
	($PauseMenu as PauseMenu).teams_state = state_fn

func set_seat_options(blue_free: int, red_free: int, playing: bool) -> void :
	($PauseMenu as PauseMenu).set_seat_options(blue_free, red_free, playing)


	if _seat_tell == null:
		_seat_tell = Label.new()
		_seat_tell.name = "SeatTell"
		UiStyle.style_pill(_seat_tell, UiStyle.PRIMARY, UiStyle.INK, 15)
		_seat_tell.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		_seat_tell.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_seat_tell.grow_vertical = Control.GROW_DIRECTION_BEGIN
		_seat_tell.offset_bottom = -88.0
		_seat_tell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_seat_tell)
	var seat_open: = blue_free > 0 or red_free > 0
	var want: bool = ( not playing) and seat_open and $SpectateBar.visible
	if playing and _seat_tell.visible:

		_seat_tell.visible = false
	if want and not _seat_tell_shown:


		_seat_tell_shown = true


		_seat_tell.text = "you will join at the start of the next rally"\
		if GameConfig.quick_match and Net.active\
		else "to join the match, select a team from the pause menu"
		_seat_tell.modulate.a = 1.0
		_seat_tell.visible = true
		var t: = _seat_tell.create_tween()
		t.tween_interval(SEAT_TELL_SECS)
		t.tween_property(_seat_tell, "modulate:a", 0.0, 0.6)
		t.tween_callback( func(): _seat_tell.visible = false)
	elif not want and _seat_tell.visible and not _seat_tell_shown:
		_seat_tell.visible = false

const SEAT_TELL_SECS: = 30.0

func hide_seat_tell() -> void :
	if _seat_tell != null:
		_seat_tell.visible = false
var _seat_tell: Label = null
var _seat_tell_shown: = false

func pause_is_open() -> bool:
	return ($PauseMenu as PauseMenu).is_open()

func apply_pause_mode() -> void :
	$PauseMenu.pauses_tree = pause_pauses_tree
	if not pause_pauses_tree and is_inside_tree():

		get_tree().paused = false



var pause_enabled: = true
var _pause_toggle_frame: = -1

func _unhandled_input(event: InputEvent) -> void :
	if not pause_enabled:
		return



	if $PostStats.visible:
		return
	var pm: = $PauseMenu as PauseMenu




	var wants_toggle: bool
	if pm.is_open():
		wants_toggle = event.is_action_pressed("ui_cancel")\
		or event.is_action_pressed("menu_start")
	else:
		wants_toggle = event.is_action_pressed("menu_start")\
		or (event is InputEventKey and event.is_action_pressed("ui_cancel"))
	if not wants_toggle:
		return




	if LocalPlayers.consume_foreign_ui(event):
		return



	var f: = Engine.get_process_frames()
	if f != _pause_toggle_frame:
		_pause_toggle_frame = f
		if pm.is_open():
			pm.set_open(false)
		else:
			_open_pause_with_clean_shot(pm)
	get_viewport().set_input_as_handled()



func _open_pause_with_clean_shot(pm: PauseMenu) -> void :
	if not Net.active:
		pm.set_open(true)
		return


	var hidden: Array = []
	for c in get_children():
		if c == chat:
			continue
		if c is CanvasItem and (c as CanvasItem).visible:
			(c as CanvasItem).visible = false
			hidden.append(c)
	await RenderingServer.frame_post_draw
	if is_instance_valid(self):
		var tex: = get_viewport().get_texture()
		if tex != null:
			var img: = tex.get_image()
			if img != null and not img.is_empty():
				Reports.match_shot = img
		for c in hidden:
			if is_instance_valid(c):
				(c as CanvasItem).visible = true
	if is_instance_valid(pm):
		pm.set_open(true)

func pause_open() -> bool:
	return $PauseMenu.is_open()



func update_controls(action_text: String, action_on: bool, dive_on: bool, 
		jump_on: bool, set_on: bool = true, m2_text: String = "dive") -> void :
	if _hints != null:
		_hints.update(action_text, action_on, dive_on, jump_on, set_on, m2_text)

func set_net_info(text: String) -> void :
	$NetLabel.visible = text != ""
	$NetLabel.text = text

func store_stat_rows(rows: Array) -> void :
	_net_stat_rows = rows

func stored_stat_rows() -> Array:
	return _net_stat_rows

func set_sweat(value: float) -> void :
	_sweat = value
	var box: Control = $SweatBox
	box.visible = value > 0.01
	if not box.visible:
		return
	_place_sweat()
	var lit: = int(ceilf(value * float(SWEAT_TICKS) - 0.001))


	for i in _sweat_tick_boxes.size():
		var b: StyleBoxFlat = _sweat_tick_boxes[i]
		b.bg_color = _tier_color(i) if i < lit else Color(0.08, 0.1, 0.16, 0.38)
	if _sweat_drop != null:
		_sweat_drop.color = _tier_color(maxi(lit - 1, 0))


func _tier_color(i: int) -> Color:
	if i <= 2:
		return Color(0.28, 0.62, 1.0)
	elif i <= 4:
		return Color(1.0, 0.82, 0.15)
	return Color(1.0, 0.22, 0.16)

func _process(_delta: float) -> void :


	_tick_cam_label(_delta)
	if _sb_faded and not GameConfig.fade_scoreboard:
		rally_fade(false)
	if _stats_dark != UiStyle.dark:
		_style_stats_surfaces()
	if $PostStats.visible and not _pa_states.is_empty():
		_pa_spin += _delta
		_render_pa_marks()

	var box: Control = $SweatBox
	if not box.visible or not _sweat_base_set:
		return
	if _sweat > 0.55:
		var shake: = (_sweat - 0.55) / 0.45 * 3.0
		box.position = _sweat_base + Vector2(
			randf_range( - shake, shake), randf_range( - shake, shake))
	else:
		box.position = _sweat_base


func set_touches(count: int) -> void :




	_paint_touch(count)
	touch_label.text = ""
	if _touch_box == null:
		return
	if count > 0:
		if _touch_fade != null and _touch_fade.is_valid():
			_touch_fade.kill()
		_touch_box.visible = true
		_touch_box.modulate.a = 1.0
	elif _touch_box.visible and (_touch_fade == null or not _touch_fade.is_valid()):
		_touch_fade = create_tween()
		_touch_fade.set_ignore_time_scale(true)
		_touch_fade.tween_property(_touch_box, "modulate:a", 0.0, 0.22)
		_touch_fade.tween_callback( func(): _touch_box.visible = false)




const CAM_LABEL_HOLD: = 1.4
const CAM_LABEL_FADE: = 0.5
var _cam_label_left: = 0.0

func show_camera_name(name: String) -> void :
	($CamLabel as Label).text = "cam: " + name
	_cam_label_left = CAM_LABEL_HOLD + CAM_LABEL_FADE

func _tick_cam_label(delta: float) -> void :
	if _cam_label_left <= 0.0:
		return
	_cam_label_left -= delta
	($CamLabel as Label).modulate.a = clampf(
		_cam_label_left / CAM_LABEL_FADE, 0.0, 1.0)

func set_dive(cooldown: float) -> void :
	dive_label.visible = false
	if _hints != null:
		_hints.set_dive(cooldown)

func dive_denied() -> void :
	if _hints != null:
		_hints.dive_denied()

func set_score(you: int, opp: int, sets_you: int, sets_opp: int, set_number: int) -> void :

	if not _roll_lock_you:
		you_score.text = "%d" % you
	if not _roll_lock_opp:
		opp_score.text = "%d" % opp



	var target: = GameConfig.set_points






	var in_deuce_zone: bool = GameConfig.win_by_two and mini(you, opp) >= target - 1
	var deuce: bool = in_deuce_zone and you == opp
	var at_point: bool = ( not deuce) and \
	(maxi(you, opp) == target - 1 or (in_deuce_zone and absi(you - opp) == 1))
	var hot: = false
	var ctx: = "set %d" % set_number
	if deuce:
		hot = true
		ctx = "deuce"
	elif at_point:
		hot = true


		var lead_sets: = sets_you if you >= opp else sets_opp
		if lead_sets >= maxi(1, GameConfig.sets_to_win) - 1:
			ctx = "match point"
		else:
			ctx = "set point"
	_sets_you = sets_you
	_sets_opp = sets_opp
	_refresh_set_dots()
	_refresh_target()
	_sb_sub.text = ctx
	if hot:
		_sb_sub.add_theme_color_override("font_color", Color("b52a50"))
		_sb_sub.add_theme_constant_override("outline_size", 0)
	else:


		_sb_sub.add_theme_color_override("font_color", Color("315176"))
		_sb_sub.add_theme_constant_override("outline_size", 0)



	if hot and ctx != _announced_state:
		_announced_state = ctx
		announce_moment(ctx.replace(" ", "_"))
	elif not hot:
		_announced_state = ""






const MOMENTS: = {
	"ace": ["service ace!", true, true], 
	"break_point": ["break point!", true, true], 
	"line": ["on the line!", true, true], 
	"game": ["game!", true, true], 
	"set": ["set!", true, true], 


	"out": ["out!", true, false], 
	"foot_fault": ["foot fault", false, false], 
	"fault": ["fault", false, false], 


	"match_point": ["match point", false, false], 
	"set_point": ["set point", false, false], 
	"deuce": ["deuce", false, false], 
	"count_3": ["", true, false], 
	"count_2": ["", true, false], 
	"count_1": ["", true, false], 
}




func announce_moment(key: String, side: = 0) -> void :
	if _announcer != null:
		_announcer.say(key)
	var m: Array = MOMENTS.get(key, [])
	if m.is_empty():
		return
	var text: String = m[0]
	if text != "":
		var team: bool = m[2]
		announce_banner(text, Rules.side_color(side) if team else Color.WHITE, m[1])

	if key == "match_point" or key == "set_point" or key == "deuce":
		_pulse_caption()





func announce(key: String, text: = "", accent: = Color.WHITE, big: = true, 
		priority: = -1) -> void :
	if _announcer != null:
		_announcer.say(key, priority)
	if text != "":
		announce_banner(text, accent, big)
	else:

		_pulse_caption()




func announce_banner(text: String, accent: = Color.WHITE, big: = true) -> void :
	var box: CenterContainer = get_node_or_null("AnnounceBanner")
	var lbl: Label
	if box == null:
		box = CenterContainer.new()
		box.name = "AnnounceBanner"
		box.set_anchors_preset(Control.PRESET_TOP_WIDE)



		box.offset_top = 196.0
		box.offset_bottom = 266.0
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl = Label.new()
		lbl.name = "Text"
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.offset_transform_enabled = true
		lbl.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
		box.add_child(lbl)
		add_child(box)
	else:
		lbl = box.get_node("Text") as Label
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 58 if big else 34)
	lbl.add_theme_constant_override("outline_size", 16 if big else 9)
	lbl.add_theme_color_override("font_color", accent)
	box.visible = true
	box.modulate.a = 1.0
	lbl.offset_transform_scale = Vector2(0.55, 0.55)
	if _announce_tween != null and _announce_tween.is_valid():
		_announce_tween.kill()
	_announce_tween = create_tween().set_ignore_time_scale(true)
	_announce_tween.tween_property(lbl, "offset_transform_scale", 
		Vector2(1.12, 1.12), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_announce_tween.tween_property(lbl, "offset_transform_scale", 
		Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	_announce_tween.tween_interval(1.3 if big else 1.0)
	_announce_tween.tween_property(box, "modulate:a", 0.0, 0.3)
	_announce_tween.tween_callback( func(): box.visible = false)



func _pulse_caption() -> void :
	if _sb_sub == null:
		return
	_sb_sub.offset_transform_enabled = true
	_sb_sub.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	var t: = _sb_sub.create_tween().set_ignore_time_scale(true)
	t.tween_property(_sb_sub, "offset_transform_scale", Vector2(1.35, 1.35), 0.16)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_sb_sub, "offset_transform_scale", Vector2.ONE, 0.4)\
	.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

var _serve_urgent: = false
var _serve_pulse: Tween = null



func set_serve_prompt(text: String, mine: = false, clock: = -1.0) -> void :
	serve_label.text = text
	if text == "":
		mine = false
	var urgent: = mine and clock >= 0.0 and clock <= 5.0
	serve_label.add_theme_font_size_override("font_size", 
		(26 if urgent else 22) if mine else 17)
	serve_label.add_theme_color_override("font_color", 
		Color(1.0, 0.32, 0.32) if urgent else Color.WHITE)
	if urgent == _serve_urgent:
		return
	_serve_urgent = urgent
	if _serve_pulse != null and _serve_pulse.is_valid():
		_serve_pulse.kill()
	if urgent:


		serve_label.pivot_offset = Vector2(serve_label.size.x, serve_label.size.y * 0.5)
		_serve_pulse = serve_label.create_tween().set_loops().set_ignore_time_scale(true)
		_serve_pulse.tween_property(serve_label, "scale", Vector2(1.12, 1.12), 0.3)\
		.set_trans(Tween.TRANS_SINE)
		_serve_pulse.tween_property(serve_label, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_SINE)
	else:
		serve_label.scale = Vector2.ONE

var _banner_tween: Tween = null

func flash_banner(text: String) -> void :


	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	banner_label.text = text
	_banner_card.visible = true
	_banner_card.modulate.a = 1.0
	UiStyle.pop_in(_banner_card)
	_banner_tween = create_tween()
	_banner_tween.set_ignore_time_scale(true)
	_banner_tween.tween_interval(1.6)
	_banner_tween.tween_property(_banner_card, "modulate:a", 0.0, 0.5)
	_banner_tween.tween_callback( func(): _banner_card.visible = false)








const NOTICE_SECS: = 3.2
const NOTICE_TOP: = 68.0
const NOTICE_EDGE: = 20.0



const NOTICE_LEFT_EDGE: = 10.0
const NOTICE_LEFT_TOP: = 10.0
const NOTICE_LEFT_TOP_FPS: = 34.0
var _notice_box: VBoxContainer = null



var _notice_box_left: VBoxContainer = null

func notice(text: String, secs: = NOTICE_SECS, left: = false) -> void :
	if _notice_box == null:
		_notice_box = VBoxContainer.new()
		_notice_box.name = "Notices"
		_notice_box.add_theme_constant_override("separation", 6)
		_notice_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_notice_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_notice_box.offset_left = - NOTICE_EDGE
		_notice_box.offset_right = - NOTICE_EDGE
		_notice_box.offset_top = NOTICE_TOP
		_notice_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_notice_box)
	if left and _notice_box_left == null:
		_notice_box_left = VBoxContainer.new()
		_notice_box_left.name = "NoticesLeft"
		_notice_box_left.add_theme_constant_override("separation", 6)
		_notice_box_left.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_notice_box_left.offset_left = NOTICE_LEFT_EDGE
		_notice_box_left.offset_right = NOTICE_LEFT_EDGE
		_notice_box_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_notice_box_left)
	if left:
		_notice_box_left.offset_top = NOTICE_LEFT_TOP_FPS if GameConfig.show_fps else NOTICE_LEFT_TOP
	var pill: = Label.new()
	pill.text = text
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiStyle.style_pill(pill, Color(UiStyle.card(), 0.94), UiStyle.text(), 14)
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if left else Control.SIZE_SHRINK_END
	(_notice_box_left if left else _notice_box).add_child(pill)
	UiStyle.pop_in(pill)
	var t: = pill.create_tween()
	t.set_ignore_time_scale(true)
	t.tween_interval(secs)
	t.tween_property(pill, "modulate:a", 0.0, 0.4)
	t.tween_callback(pill.queue_free)

var _stats_hash: = 0

func show_stats(rows: Array) -> void :



	var networked: bool = Net.active
	var local_peer: = 1
	var local_ping: = -1
	if networked:
		var mp: = get_multiplayer()
		if mp != null and mp.multiplayer_peer != null:
			local_peer = mp.get_unique_id()




		local_ping = maxi(int(round(Net.peer_rtt_ms(1))), int(Net.fake_latency_ms))
	_stats_drawer.set_rows(rows, local_peer, networked, local_ping)
	_stats_drawer.open()


	if _hints != null:
		_hints.modulate.a = 0.0

func hide_stats() -> void :
	if _stats_drawer != null:
		_stats_drawer.close()
	if _hints != null:
		_hints.modulate.a = 1.0



func set_fade(alpha: float) -> void :
	$Fade.modulate.a = clampf(alpha, 0.0, 1.0)

func show_cine_name(text: String, color: Color, subtitle: = "") -> void :

	var name_label: Label = $CineName
	name_label.text = text
	name_label.add_theme_color_override("font_color", color)
	name_label.visible = true
	var sub: Label = $CineSub
	sub.text = subtitle
	sub.add_theme_color_override("font_color", color)
	sub.visible = subtitle != ""

func hide_cine_name() -> void :
	$CineName.visible = false
	$CineSub.visible = false






const NAME_PILL: = preload("res://game/ui/title_name_pill.gd")
const SLAB_TILT: = -0.06
const SLAB_RADIUS: = 28

const INTRO_SFX_STAGE: = "wipe_in"
const INTRO_SFX_SLAB: = "wipe_in"
const INTRO_SFX_CARD: = "tick"
var _slab: PanelContainer = null
var _slab_label: Label = null
var _stage_card: Label = null
var _intro_card: Control = null
var _intro_pill: Control = null



var _slab_right: = false

func show_team_slab(text: String, color: Color, right: = false) -> void :
	_slab_right = right
	if _slab == null:
		_slab = PanelContainer.new()
		_slab.name = "IntroSlab"
		_slab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_slab_label = Label.new()
		_slab.add_child(_slab_label)
		add_child(_slab)
	var box: = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = color.darkened(0.28)
	box.border_width_bottom = UiStyle.EDGE + 2
	box.set_corner_radius_all(SLAB_RADIUS)
	box.content_margin_left = 34.0
	box.content_margin_right = 40.0
	box.content_margin_top = 2.0
	box.content_margin_bottom = 6.0
	_slab.add_theme_stylebox_override("panel", box)
	_slab_label.text = text
	_slab_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_slab_label.add_theme_font_size_override("font_size", 64)
	_slab_label.add_theme_color_override("font_color", Color.WHITE)
	_slab_label.add_theme_color_override("font_outline_color", UiStyle.INK)
	_slab_label.add_theme_constant_override("outline_size", 14)
	_slab.reset_size()
	_slab.rotation = - SLAB_TILT if right else SLAB_TILT
	_slab.pivot_offset = Vector2(_slab.size.x if right else 0.0, _slab.size.y)
	var vp: = get_viewport_rect().size
	var top: = vp.y * REPLAY_BAR + 26.0
	_slab.position = Vector2(_slab_off_x(), top)
	_slab.visible = true
	var t: = create_tween().set_ignore_time_scale(true)
	t.tween_property(_slab, "position:x", 
		vp.x - _slab.size.x + 24.0 if right else -24.0, 0.42)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	UiStyle.sfx(INTRO_SFX_SLAB)

func hide_team_slab() -> void :
	if _slab == null or not _slab.visible:
		return
	var t: = create_tween().set_ignore_time_scale(true)
	t.tween_property(_slab, "position:x", _slab_off_x(), 0.22)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	t.tween_callback( func(): _slab.visible = false)


func _slab_off_x() -> float:
	return get_viewport_rect().size.x + 60.0 if _slab_right else - _slab.size.x - 60.0

var _stage_tween: Tween = null

func show_stage_card(text: String) -> void :
	if _stage_tween != null and _stage_tween.is_valid():
		_stage_tween.kill()
	if _stage_card == null:
		_stage_card = Label.new()
		_stage_card.name = "IntroStage"
		_stage_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_stage_card)
	_stage_card.text = text
	UiStyle.style_pill(_stage_card, Color.WHITE, UiStyle.INK, 44)
	_stage_card.reset_size()
	var vp: = get_viewport_rect().size

	var rest: = vp.y * REPLAY_BAR + 22.0
	_stage_card.position = Vector2((vp.x - _stage_card.size.x) * 0.5, 
		- _stage_card.size.y - 20.0)
	_stage_card.modulate.a = 1.0
	_stage_card.visible = true
	var t: = create_tween().set_ignore_time_scale(true)
	_stage_tween = t
	t.tween_property(_stage_card, "position:y", rest, 0.5)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	UiStyle.sfx(INTRO_SFX_STAGE)

func hide_stage_card() -> void :
	if _stage_card == null or not _stage_card.visible:
		return
	if _stage_tween != null and _stage_tween.is_valid():
		_stage_tween.kill()
	var t: = create_tween().set_ignore_time_scale(true)
	_stage_tween = t
	t.tween_property(_stage_card, "modulate:a", 0.0, 0.35)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback( func(): _stage_card.visible = false)



func show_intro_card(player_name: String, style: Dictionary, index: int, badge: = "", 
		badge_color: = UiStyle.COIN, level: = 0, tier: = 0, party: = 0) -> void :
	if _intro_card == null:
		_intro_card = Control.new()
		_intro_card.name = "IntroCard"
		_intro_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_intro_card)
	for c in _intro_card.get_children():
		c.queue_free()
	var pill: Control = NAME_PILL.new()
	pill.tier = tier
	pill.party = party
	_intro_card.add_child(pill)
	pill.show_name(player_name, style, 40, false, "", level)
	_intro_pill = pill
	var sz: Vector2 = pill.custom_minimum_size
	_intro_card.size = sz
	var vp: = get_viewport_rect().size
	_intro_card.position = Vector2(vp.x * 0.5 - sz.x * 0.5, 
		vp.y * (1.0 - REPLAY_BAR) - sz.y - 34.0)
	_intro_card.pivot_offset = sz * 0.5
	_intro_card.modulate.a = 1.0
	_intro_card.scale = Vector2.ONE
	_intro_card.visible = true

	if badge != "":
		var tag: = Label.new()
		tag.text = badge
		UiStyle.style_pill(tag, badge_color, Color.WHITE, 22)

		tag.add_theme_color_override("font_outline_color", UiStyle.INK)
		tag.add_theme_constant_override("outline_size", 8)
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_intro_card.add_child(tag)
		tag.reset_size()
		tag.position = Vector2((sz.x - tag.size.x) * 0.5, - tag.size.y - 6.0)
		tag.pivot_offset = tag.size * 0.5
		UiStyle.pop_in(tag, 0.12)
	UiStyle.pop_in(_intro_card)
	UiStyle.sfx(INTRO_SFX_CARD, 1.0 + 0.09 * index)




func hand_off_mvp_card(key: String) -> void :
	if _post_stats_board == null:
		return

	await get_tree().process_frame
	await get_tree().process_frame
	var row: Control = _post_stats_board.row_by_key.get(key)
	if row == null or not is_instance_valid(row) or not row.is_visible_in_tree():
		hide_intro_card()
		return


	if _intro_card == null or not _intro_card.visible:
		UiStyle.press_bounce(row)
		UiStyle.click_burst(row, UiStyle.COIN)
		UiStyle.sfx("confirm")
		return
	var to: = row.get_global_rect().get_center()
	var card: = _intro_card
	var t: = create_tween().set_ignore_time_scale(true).set_parallel(true)
	t.tween_property(card, "global_position", to - card.size * 0.5 * 0.45, 0.55)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(card, "scale", Vector2(0.45, 0.45), 0.55)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	t.chain().tween_property(card, "modulate:a", 0.0, 0.12)
	t.chain().tween_callback( func():
		card.visible = false
		UiStyle.press_bounce(row)
		UiStyle.click_burst(row, UiStyle.COIN)
		UiStyle.sfx("confirm"))

func hide_intro_card() -> void :
	if _intro_card != null:
		_intro_card.visible = false



const BURNOUT_SHADER: = preload("res://game/fx/burnout_vignette.gdshader")
var _burnout: ColorRect = null



var _burnout_warm_until: = -1

func prewarm_burnout() -> void :
	_burnout_warm_until = Engine.get_process_frames() + 3
	set_burnout(0.0)

func set_burnout(amount: float, pulse: = 0.0) -> void :


	if Engine.get_process_frames() < _burnout_warm_until:
		amount = maxf(amount, 0.002)
	if _burnout == null:
		if amount <= 0.001:
			return
		_burnout = ColorRect.new()
		_burnout.name = "Burnout"
		_burnout.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_burnout.set_anchors_preset(Control.PRESET_FULL_RECT)
		var mat: = ShaderMaterial.new()
		mat.shader = BURNOUT_SHADER
		_burnout.material = mat
		add_child(_burnout)
		move_child(_burnout, 0)
	_burnout.visible = amount > 0.001
	var m: = _burnout.material as ShaderMaterial
	m.set_shader_parameter("amount", clampf(amount, 0.0, 1.0))
	m.set_shader_parameter("pulse", clampf(pulse, 0.0, 1.0))

func hide_intro_ui() -> void :
	hide_team_slab()
	hide_stage_card()
	hide_intro_card()





var _count_tween: Tween = null
var _count_shake: Tween = null

func show_countdown(n: int, color: = Color.WHITE) -> void :
	var label: Label = $Countdown
	if not label.visible or label.text != str(n):

		if n >= 1 and n <= 3:
			announce_moment("count_%d" % n)
		for t in [_count_tween, _count_shake]:
			if t != null and t.is_valid():
				t.kill()
		label.offset_transform_enabled = true
		label.offset_transform_position = Vector2.ZERO
		label.text = str(n)
		label.visible = true
		label.add_theme_color_override("font_color", color)
		label.add_theme_color_override("font_outline_color", UiStyle.INK)
		label.add_theme_constant_override("outline_size", 26)
		label.pivot_offset = label.size * 0.5
		var big: = 1.18 if n == 1 else 1.0
		label.scale = Vector2(2.8, 2.8) * big
		label.rotation = 0.32 if n % 2 == 1 else -0.32
		label.modulate.a = 0.0
		var t: = create_tween().set_ignore_time_scale(true)
		_count_tween = t

		t.tween_property(label, "modulate:a", 1.0, 0.06)
		t.parallel().tween_property(label, "scale", Vector2(1.18, 0.82) * big, 0.13)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.parallel().tween_property(label, "rotation", 0.0, 0.13)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		t.tween_callback( func(): _shake_count(label, 16.0 if n == 1 else 11.0))

		t.tween_property(label, "scale", Vector2.ONE * big, 0.34)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		t.tween_property(label, "scale", Vector2.ONE * big * 1.07, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



func _shake_count(label: Label, px: float) -> void :
	var t: = create_tween().set_ignore_time_scale(true)
	_count_shake = t
	for i in 7:
		var k: = 1.0 - float(i) / 7.0
		t.tween_property(label, "offset_transform_position", 
			Vector2(randf_range( - px, px), randf_range( - px, px) * 0.6) * k, 0.03)
	t.tween_property(label, "offset_transform_position", Vector2.ZERO, 0.04)

func hide_countdown() -> void :
	$Countdown.visible = false

func grab_dissolve() -> void :


	var img: = get_viewport().get_texture().get_image()
	if img == null:
		return
	var d: TextureRect = $Dissolve
	d.texture = ImageTexture.create_from_image(img)
	d.modulate.a = 1.0
	d.visible = true

func set_dissolve(alpha: float) -> void :
	var d: TextureRect = $Dissolve
	d.modulate.a = clampf(alpha, 0.0, 1.0)
	d.visible = d.modulate.a > 0.01

var loading_cover: LoadingCover = null

func set_loading(alpha: float) -> void :


	var l: ColorRect = $Loading
	l.modulate.a = clampf(alpha, 0.0, 1.0)
	l.visible = l.modulate.a > 0.01

func hide_cinematics() -> void :
	hide_cine_name()
	hide_countdown()
	set_fade(0.0)
	set_dissolve(0.0)
	hide_intro_ui()
	set_replay_banner(false, 0, 0)

func set_replay_banner(shown: bool, votes: int, needed: int) -> void :




	_set_match_ui_hidden(shown)
	set_cinema_bars(shown)


	var box: Control = get_node_or_null("ReplayTag")
	if box == null:
		if not shown:
			return
		box = _build_replay_tag()
		add_child(box)
	box.visible = shown
	if shown:
		var sub: Label = box.find_child("Sub", true, false)
		sub.text = "space to skip    %d/%d" % [votes, needed] if needed > 1\
		else "space to skip"






const REPLAY_BAR: = 0.085
const REPLAY_BAR_IN: = 0.38
const REPLAY_BAR_OUT: = 0.3
var _replay_bars: Array = []
var _replay_bars_on: = false
var _replay_bars_tween: Tween = null

func set_cinema_bars(on: bool) -> void :
	if on == _replay_bars_on:
		return
	_replay_bars_on = on
	if _replay_bars.is_empty():
		if not on:
			return
		for top in [true, false]:
			var bar: = ColorRect.new()
			bar.name = "ReplayBarTop" if top else "ReplayBarBottom"
			bar.color = Color.BLACK
			bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bar.anchor_left = 0.0
			bar.anchor_right = 1.0

			bar.anchor_top = 0.0 if top else 1.0
			bar.anchor_bottom = 0.0 if top else 1.0
			add_child(bar)
			move_child(bar, 0)
			_replay_bars.append(bar)
	if _replay_bars_tween != null and _replay_bars_tween.is_valid():
		_replay_bars_tween.kill()
	var t: = create_tween().set_ignore_time_scale(true).set_parallel(true)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT if on else Tween.EASE_IN)
	var d: = REPLAY_BAR_IN if on else REPLAY_BAR_OUT
	t.tween_property(_replay_bars[0], "anchor_bottom", REPLAY_BAR if on else 0.0, d)
	t.tween_property(_replay_bars[1], "anchor_top", 1.0 - REPLAY_BAR if on else 1.0, d)
	_replay_bars_tween = t





func _build_replay_tag() -> Control:


	var box: = CenterContainer.new()
	box.name = "ReplayTag"


	box.anchor_left = 0.0
	box.anchor_right = 1.0
	box.anchor_top = 1.0 - REPLAY_BAR
	box.anchor_bottom = 1.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var col: = VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 1)
	box.add_child(col)


	var row: = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 9)
	col.add_child(row)

	var dot: = Panel.new()
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.custom_minimum_size = Vector2(12, 12)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ds: = StyleBoxFlat.new()
	ds.bg_color = Color(1.0, 0.28, 0.3)
	ds.set_corner_radius_all(6)
	ds.shadow_color = Color(0, 0, 0, 0.7)
	ds.shadow_size = 3
	dot.add_theme_stylebox_override("panel", ds)
	row.add_child(dot)

	var pt: = dot.create_tween().set_ignore_time_scale(true).set_loops()
	pt.tween_property(dot, "modulate:a", 0.25, 0.6).set_trans(Tween.TRANS_SINE)
	pt.tween_property(dot, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

	var tag: = Label.new()
	tag.name = "Tag"
	tag.text = "instant replay"
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tag.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	tag.add_theme_font_size_override("font_size", 25)
	tag.add_theme_color_override("font_color", Color.WHITE)
	tag.add_theme_color_override("font_outline_color", Color.BLACK)
	tag.add_theme_constant_override("outline_size", 6)
	row.add_child(tag)

	var sub: = Label.new()
	sub.name = "Sub"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	sub.add_theme_constant_override("outline_size", 4)
	col.add_child(sub)
	return box



signal play_again_pressed
signal to_lobby_pressed

const RESULTS_ZOOM: = 1.3

func _build_stats_boards() -> void :


	$StatsPanel / Box / Title.visible = false
	stats_grid.visible = false



	stats_panel.visible = false
	_stats_drawer = STATS_DRAWER.new()
	add_child(_stats_drawer)
	move_child(_stats_drawer, get_child_count() - 1)
	$PostStats / Box / Margin / Inner / Rows.visible = false



	_post_scroll = ScrollContainer.new()
	_post_scroll.name = "BoardScroll"
	_post_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_post_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyle.style_scroll(_post_scroll.get_v_scroll_bar())
	_post_stats_board = ScoreTable.new(true)





	var zoom: = Control.new()
	zoom.name = "BoardZoom"
	zoom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zoom.mouse_filter = Control.MOUSE_FILTER_PASS
	zoom.add_child(_post_stats_board)


	var fit: = func():
		var need: = _post_stats_board.get_combined_minimum_size()
		var h: = need.y
		var room: = _post_scroll.size.y
		var k: = RESULTS_ZOOM
		if h > 0.0 and room > 0.0:
			k = clampf(room / h, 1.0, RESULTS_ZOOM)





		if need.x > 0.0 and zoom.size.x > 0.0:
			k = minf(k, zoom.size.x / need.x)
		_post_stats_board.position = Vector2.ZERO
		_post_stats_board.size = Vector2(zoom.size.x / k, h)
		_post_stats_board.scale = Vector2.ONE * k
		zoom.custom_minimum_size.y = h * k
	zoom.resized.connect(fit)
	_post_scroll.resized.connect(fit)
	_post_stats_board.minimum_size_changed.connect(fit)
	_post_scroll.add_child(zoom)
	$PostStats / Box / Margin / Inner.add_child(_post_scroll)
	$PostStats / Box / Margin / Inner.move_child(_post_scroll, 1)
	_style_stats_surfaces()

func _style_stats_surfaces() -> void :
	_stats_dark = UiStyle.dark
	UiStyle.style_panel(stats_panel)


	$PostStats.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	($PostStats / Dim as ColorRect).color = Color(0.0, 0.0, 0.0, 0.5)
	for keep in [$PostStats / Box / Margin / Inner / Result, $PostStats / Box / Margin / Inner / WaitLabel]:
		(keep as Node).set_meta("no_wash", true)
	UiStyle.wash($PostStats)
	var wait: = $PostStats / Box / Margin / Inner / WaitLabel as Label
	wait.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	wait.add_theme_color_override("font_color", Color.WHITE)
	wait.add_theme_color_override("font_outline_color", Color.BLACK)
	wait.add_theme_constant_override("outline_size", 5)
	UiStyle.style_button($PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn, 
		"primary", 20)
	UiStyle.style_button($PostStats / Box / Margin / Inner / Buttons / LobbyBtn, 
		"secondary", 20)


func _ready_post() -> void :
	$PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn.pressed.connect(
		func(): play_again_pressed.emit())
	$PostStats / Box / Margin / Inner / Buttons / LobbyBtn.pressed.connect(
		func(): to_lobby_pressed.emit())

func show_match_stats(rows: Array, winner_side: int, my_side: int, 
		host_controls: bool) -> void :
	_pa_states = {}
	_pa_name_labels = {}



	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var result: Label = $PostStats / Box / Margin / Inner / Result
	var won: = winner_side == my_side
	result.text = "victory!" if won else "defeat"



	result.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	result.add_theme_font_size_override("font_size", 68)
	result.add_theme_color_override("font_color", Color.WHITE)
	result.add_theme_color_override("font_outline_color", 
		Rules.side_color(my_side).darkened(0.25) if won else UiStyle.INK)
	result.add_theme_constant_override("outline_size", 16)
	result.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	result.add_theme_constant_override("shadow_offset_y", 5)
	result.add_theme_constant_override("shadow_outline_size", 16)



	var networked: bool = Net.active or rows.any( func(r): return int(r.get("peer", 0)) > 1)
	var local_peer: = 1
	var local_ping: = -1
	if Net.active:
		var mp: = get_multiplayer()
		if mp != null and mp.multiplayer_peer != null:
			local_peer = mp.get_unique_id()
		local_ping = int(round(Net.peer_rtt_ms(1)))

	_fit_post_rows(rows)
	_post_stats_board.set_rows(rows, {"local_peer": local_peer, 
		"networked": networked, "local_ping": local_ping, "first_side": winner_side, 
		"mvp": true, "glass": true})
	_pa_name_labels = _post_stats_board.name_labels
	if _rewards != null:
		_rewards.queue_free()
		_rewards = null
	_size_post_stats()
	$PostStats / Box / Margin / Inner / Buttons.visible = host_controls
	$PostStats / Box / Margin / Inner / WaitLabel.visible = not host_controls
	$PostStats.visible = true





func quick_stats_mode(can_leave: = true) -> void :
	$PostStats / Box / Margin / Inner / Buttons.visible = true


	$PostStats / Box / Margin / Inner / WaitLabel.visible = true
	($PostStats / Box / Margin / Inner / WaitLabel as Label).text = ""
	($PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn as Button).text = "play again"


	($PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn as Button).visible = true
	var lobby_btn: = $PostStats / Box / Margin / Inner / Buttons / LobbyBtn as Button
	lobby_btn.text = "back to menu"
	lobby_btn.visible = can_leave






func room_stats_mode(party_member: = false) -> void :
	$PostStats / Box / Margin / Inner / Buttons.visible = true
	($PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn as Button).visible = false
	var lobby_btn: = $PostStats / Box / Margin / Inner / Buttons / LobbyBtn as Button





	lobby_btn.text = "leave party" if party_member else "back to menu"
	lobby_btn.visible = true
	$PostStats / Box / Margin / Inner / WaitLabel.visible = true
	($PostStats / Box / Margin / Inner / WaitLabel as Label).text = \
	"you can wait here for the host to start another match."

func set_play_again(text: String, disabled: bool) -> void :
	var btn: = $PostStats / Box / Margin / Inner / Buttons / PlayAgainBtn as Button
	btn.text = text
	btn.disabled = disabled

func set_quick_wait(text: String) -> void :
	($PostStats / Box / Margin / Inner / WaitLabel as Label).text = text




const PA_SPIN: = ["|", "/", "-", "\\"]
var _pa_states: = {}
var _pa_name_labels: = {}
var _pa_spin: = 0.0

func set_pa_marks(states: Dictionary) -> void :
	_pa_states = states
	_render_pa_marks()

func _render_pa_marks() -> void :
	for pa_name in _pa_name_labels:
		var label: Label = _pa_name_labels[pa_name]
		if not is_instance_valid(label):
			continue
		var mark: = ""
		match String(_pa_states.get(pa_name, "")):
			"in":
				mark = "  ✓"
			"out":
				mark = "  ✗"
			"wait":
				mark = "  " + PA_SPIN[int(_pa_spin * 8.0) % PA_SPIN.size()]
		label.text = String(pa_name) + mark

func _stat_header(box: VBoxContainer) -> void :
	var grid: = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 24)
	for h in ["player", "points", "blocks", "receives", "sets"]:
		var cell: = Label.new()
		cell.text = h
		cell.custom_minimum_size = Vector2(200 if h == "player" else 90, 0)
		cell.add_theme_font_size_override("font_size", 15)
		cell.add_theme_color_override("font_color", Color(0.6, 0.62, 0.68))
		grid.add_child(cell)
	box.add_child(grid)




const _PARTY_COLORS: = [Color("46b4ff"), Color("ffc93c"), 
	Color("b06cff"), Color("ff8a3d")]
var _link_cache: = {}

func _party_color(group: int) -> Color:
	return _PARTY_COLORS[(group - 1) % _PARTY_COLORS.size()]


func _link_tex(col: Color) -> Texture2D:
	var key: = col.to_html()
	if _link_cache.has(key):
		return _link_cache[key]
	var w: = 30
	var h: = 20
	var s: = 3
	var img: = Image.create(w * s, h * s, false, Image.FORMAT_RGBA8)
	var cy: = (h * s) * 0.5
	var ax: = (w * s) * 0.22
	var ay: = (h * s) * 0.34
	var th: = (w * s) * 0.09
	for y in h * s:
		for x in w * s:
			var a: = 0.0
			for cx: float in [(w * s) * 0.36, (w * s) * 0.64]:
				var dx: float = (x - cx) / ax
				var dy: float = (y - cy) / ay
				var ring: float = absf(sqrt(dx * dx + dy * dy) - 1.0) * ax
				a = maxf(a, clampf(th - ring, 0.0, 1.0))
			if a > 0.0:
				img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	img.resize(w, h, Image.INTERPOLATE_LANCZOS)
	var tex: = ImageTexture.create_from_image(img)
	_link_cache[key] = tex
	return tex

func _stat_line(box: VBoxContainer, r: Dictionary, side: int) -> void :
	var grid: = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 24)


	var tint: = Rules.side_color(side)
	var vals: = [str(r.name), str(r.pts), str(r.blk), str(r.rcv), str(r.set)]
	for i in vals.size():
		if i == 0:
			var name_lbl: = Label.new()
			name_lbl.text = vals[0]
			name_lbl.add_theme_font_size_override("font_size", 20)
			name_lbl.add_theme_color_override("font_color", tint)
			_pa_name_labels[str(r.name)] = name_lbl
			var pgroup: = int(r.get("party", 0))
			if pgroup > 0:

				var hb: = HBoxContainer.new()
				hb.add_theme_constant_override("separation", 6)
				hb.custom_minimum_size = Vector2(200, 0)
				var link: = TextureRect.new()
				link.texture = _link_tex(_party_color(pgroup))
				link.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				link.custom_minimum_size = Vector2(26, 0)
				link.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				link.tooltip_text = "queued as a party"
				hb.add_child(link)
				hb.add_child(name_lbl)
				grid.add_child(hb)
			else:
				name_lbl.custom_minimum_size = Vector2(200, 0)
				grid.add_child(name_lbl)
		else:
			var cell: = Label.new()
			cell.text = vals[i]
			cell.custom_minimum_size = Vector2(90, 0)
			cell.add_theme_font_size_override("font_size", 20)
			grid.add_child(cell)
	box.add_child(grid)

func hide_match_stats() -> void :
	$PostStats.visible = false



func _size_post_stats() -> void :

	var vp: = get_viewport().get_visible_rect().size
	var panel: = $PostStats as Control
	panel.offset_left = - vp.x * 0.5
	panel.offset_right = vp.x * 0.5
	panel.offset_top = - vp.y * 0.5
	panel.offset_bottom = vp.y * 0.5
	var w: = clampf(vp.x - 60.0, 760.0, 1400.0)
	var margin: = $PostStats / Box / Margin as MarginContainer
	margin.add_theme_constant_override("margin_left", int((vp.x - w) * 0.5))
	margin.add_theme_constant_override("margin_right", int((vp.x - w) * 0.5))
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 28)




	var inner: = $PostStats / Box / Margin / Inner as VBoxContainer
	inner.alignment = BoxContainer.ALIGNMENT_BEGIN
	inner.add_theme_constant_override("separation", 14)
	if _post_scroll != null:
		_post_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_post_scroll.custom_minimum_size.y = 120.0



func _fit_post_rows(rows: Array) -> void :
	var vp: = get_viewport().get_visible_rect().size
	var per_side: = 1
	for side in [1, -1]:
		per_side = maxi(per_side, rows.filter( func(r): return int(r.get("side", 1)) == side).size())
	var chrome: = 110.0 + 100.0 + 70.0 + 70.0 + 50.0
	var row_h: = clampf((vp.y - chrome) / float(per_side) - 3.0, 32.0, 46.0)
	_post_stats_board.set_metrics(row_h, clampf(row_h - 8.0, 24.0, 34.0), 33.0)




func show_match_rewards(summary: Dictionary) -> void :

	if summary.is_empty() or not $PostStats.visible or LaunchGate.economy_off():
		return
	if _rewards != null:
		_rewards.queue_free()
	_rewards = MatchRewards.new()
	_rewards.name = "Rewards"
	var inner: = $PostStats / Box / Margin / Inner
	inner.add_child(_rewards)
	inner.move_child(_rewards, $PostStats / Box / Margin / Inner / Buttons.get_index())
	_rewards.play(summary, 0.7)

func rewards_card() -> MatchRewards:
	return _rewards

func stats_open() -> bool:
	return $PostStats.visible
