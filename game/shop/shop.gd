extends Control




















const CAM_FOV: = 12.0
const TURNTABLE: = 0.6



const ZOOM_STEP: = 0.76
const ZOOM_MIN: = 4.1
const ZOOM_MAX: = 16.6
const SHIFT_FRAC: = 0.093
const FOCUS_Y: = 1.05
const FOCUS_Y_NEAR: = 1.45
const FOCUS_NEAR_DIST: = 10.2
const PREVIEW_NAMES: = ["showing: captain uniform", "showing: gym"]


const TABS: = [
	{"id": "head", "label": "head", "cats": ["head"]}, 
	{"id": "face", "label": "face", "cats": ["face"]}, 
	{"id": "extra", "label": "extras", "cats": ["extra"]}, 
	{"id": "titles", "label": "titles", "cats": []}, 
]
const TITLES: = preload("res://game/titles/title_catalog.gd")
const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")
const NAME_PILL: = preload("res://game/ui/title_name_pill.gd")

var cfg: CharacterConfig
var _player: Player








var section_mode: = false
var profile: SavedProfile = null
var player_color: = Color.WHITE
var player_tag: = ""
var locker: Control = null
var _compact: = false
var _short: = false
var _panel_w: = 564.0
var _gutter: = 16.0
var _bottombar_h: = 72.0
var _zoom_max: = ZOOM_MAX
var _ready_btn: Button = null

func _who() -> SavedProfile:
	return profile if profile != null else ProfileStore.active()
var _tab: = String(TABS[0]["id"])
var _sel: = ""
var _thumb_cache: = {}
var _thumb_gen: = 0
var _dragging: = false
var _spin: = false
var _preview_kit: = 0
var _cam_dist: = 14.0
var _outfit_btn: Button
var _spin_btn: Button

var _coins_lbl: Label
var _purse: Control
var _grid: GridContainer
var _tab_btns: = {}
var _sel_name: Label
var _sel_thumb: TextureRect
var _sel_card: Control
var _buy_btn: Button
const RAIL_W: = 96.0
const TAB_ICONS: = {"head": "medal2", "face": "singleplayer", 
	"extra": "medal1", "titles": "menuList"}
var _rail_w: = 0.0
var _title_pill: NAME_PILL
var _shelf: = "titles"





const SORTS: = ["sort: default", "price: low", "price: high", "a to z", "z to a", "not owned"]
enum {SORT_DEFAULT, SORT_PRICE_UP, SORT_PRICE_DOWN, SORT_AZ, SORT_ZA, SORT_UNOWNED}




const FILTERS: = ["achievements"]
enum {FILTER_EARNED}
var _earned_only: = false
var _scroll: ScrollContainer
var _head: VBoxContainer
var _title_band: Control
var _shelf_row: HBoxContainer
var _shelf_btns: = {}
var _search: LineEdit
var _sort: UiSelect
var _sort_mode: = SORT_DEFAULT
var _none_lbl: Label



var _wares: Array = []





const BUILD_FIRST: = 12
const BUILD_USEC: = 5000
var _host: Node
var _built: = 0
var _build_gen: = 0

@onready var world: SubViewport = $Preview / SubViewport

func _ready() -> void :
	MobileRender.configure_preview(world)
	_rail_w = RAIL_W
	if not section_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MusicManager.set_muffled(true)
	else:

		world.own_world_3d = true
		_layout_for_size(get_viewport_rect().size)
	TITLES.warm()
	cfg = GameConfig.character if GameConfig.character != null else CharacterConfig.new()
	if section_mode and _who() != ProfileStore.active():
		cfg = CharacterConfig.from_dict(_who().character)\
		if not _who().character.is_empty() else CharacterConfig.new()
	_player = preload("res://game/mobile/mobile_player.tscn").instantiate()
	_player.enable_reflection = false
	world.add_child(_player)
	_player.charge_ui_enabled = false
	_player.drop_shadow.visible = false
	var cam: Camera3D = $Preview / SubViewport / Camera3D
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.fov = CAM_FOV
	_frame_cam()
	Ink.apply(cam)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Preview.mouse_filter = Control.MOUSE_FILTER_IGNORE


	var bd: = UiBackdrop.new("balls")
	bd.calm = true
	bd.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bd)
	move_child(bd, 0)
	_apply_preview("")
	_build_ui()

	var want: = str(Engine.get_meta("shop_tab", TABS[0]["id"]))
	_shelf = "effects" if str(Engine.get_meta("shop_shelf", "titles")) == "effects" else "titles"

	if not section_mode:
		for note in ["shop_tab", "shop_shelf"]:
			if Engine.has_meta(note):
				Engine.remove_meta(note)
	_select_tab(want if _tab_btns.has(want) else String(TABS[0]["id"]))

	get_viewport().gui_focus_changed.connect(_drop_stray_focus)
	if section_mode:
		locker.ready_changed.connect( func(_on: bool): _paint_ready())
		_paint_ready()
	else:
		_build_solo_pointer()
		_dev_shot()


func _layout_for_size(sz: Vector2) -> void :
	_compact = sz.x < 1000.0 or sz.y < 640.0
	_short = sz.y < 520.0
	if _compact:
		_panel_w = clampf(sz.x * (0.56 if sz.y > sz.x else (0.6 if _short else 0.56)), 
			320.0, 564.0)
		_rail_w = UiStyle.rail_width(_rail_size())
		_gutter = 8.0
		_bottombar_h = 46.0 if _short else 56.0


	if sz.x > 0.0 and sz.y > 0.0:
		var t: = 2.0 * tan(deg_to_rad(CAM_FOV) * 0.5)
		var open: = 1.0 - (_rail_w + _open_right()) / sz.x
		var need: = 1.75 / maxf(t * (sz.x / sz.y) * open, 0.001)
		var room: = sz.y * 0.5 - (_bottombar_h + 14.0)
		if room > 10.0:
			need = maxf(need, FOCUS_Y * sz.y / (t * room))


		var top_room: = sz.y * 0.5 - (124.0 if _compact else 176.0)
		if top_room > 10.0:
			need = maxf(need, (2.05 - FOCUS_Y) * sz.y / (t * top_room))
		_zoom_max = maxf(ZOOM_MAX, need)
		_cam_dist = clampf(need, ZOOM_MIN, _zoom_max)


func _rail_size() -> String:
	if not section_mode or not _compact:
		return ""
	if _short:
		return "short"
	return "tall" if get_viewport_rect().size.y >= 700.0 else "mid"


func _open_right() -> float:
	return 608.0 if not section_mode else _panel_w + _gutter * 2.0




func _dev_shot() -> void :
	var args: = LaunchGate.dev_args()
	var at: = args.find("--shop-shot")
	if at < 0 or at + 1 >= args.size():
		return
	var tab: = String(args[at + 1])
	get_tree().create_timer(12.0).timeout.connect( func(): get_tree().quit())
	await get_tree().create_timer(0.6).timeout
	if _tab_btns.has(tab):
		_select_tab(tab)
	var pick: = args.find("--shop-pick")
	if pick >= 0 and pick + 1 < args.size():
		var item: = TITLES.by_id(String(args[pick + 1]))
		if item != null:
			_select_title(item)
	var pick_fx: = args.find("--shop-fx")
	if pick_fx >= 0 and pick_fx + 1 < args.size():
		_open_shelf("effects")
		var fx: = TITLES.effect(String(args[pick_fx + 1]))
		if fx != null:
			_select_effect(fx)
	var pick_it: = args.find("--shop-item")
	if pick_it >= 0 and pick_it + 1 < args.size():
		var it: = AccessoryCatalog.by_id(String(args[pick_it + 1]))
		if it != null:
			_select(it)
	while _built < _wares.size():
		await get_tree().process_frame

	var find: = args.find("--shop-search")
	if find >= 0 and find + 1 < args.size():
		_search.text = String(args[find + 1])
		_arrange()
	if "--shop-earned" in args:
		_sort.set_on(FILTER_EARNED, true)
	var sort_at: = args.find("--shop-sort")
	if sort_at >= 0 and sort_at + 1 < args.size():
		_sort.selected = int(args[sort_at + 1])
		_set_sort(int(args[sort_at + 1]))
	var down: = args.find("--shop-scroll")
	if down >= 0 and down + 1 < args.size():
		await get_tree().process_frame
		_scroll.scroll_vertical = int(args[down + 1])
	await get_tree().create_timer(1.4).timeout
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://game/dev/shots/shop_%s.png" % tab))
	get_tree().quit()

func _process(delta: float) -> void :
	if _player == null or not visible:
		return
	if _spin and not _dragging:
		_player.visual.rotation.y += delta * TURNTABLE

	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3.ZERO
	_player.simulate(PlayerInput.new(), delta)
	_player.global_position = Vector3.ZERO
	_player.velocity = Vector3.ZERO

func _input(event: InputEvent) -> void :

	if event is InputEventMouseButton:
		var mb: = event as InputEventMouseButton
		var open_x: = size.x - _open_right()
		if mb.position.x < _rail_w:
			open_x = -1.0
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_click_held = mb.pressed
			if not mb.pressed and _stray != null:
				_release_stray.call_deferred()
			if not visible:
				return
			if mb.pressed and mb.position.x < open_x:
				_dragging = true
			elif not mb.pressed:
				_dragging = false
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed\
		and mb.position.x < open_x and visible:
			_zoom(-1.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed\
		and mb.position.x < open_x and visible:
			_zoom(1.0)
	elif event is InputEventMouseMotion and _dragging and _player != null:
		_player.visual.rotation.y += (event as InputEventMouseMotion).relative.x * 0.012

func _zoom(dir: float) -> void :
	_cam_dist = clampf(_cam_dist + dir * ZOOM_STEP, ZOOM_MIN, _zoom_max)
	_frame_cam()



func _frame_cam() -> void :
	var cam: Camera3D = $Preview / SubViewport / Camera3D
	var t: = clampf(inverse_lerp(ZOOM_MIN, FOCUS_NEAR_DIST, _cam_dist), 0.0, 1.0)
	var focus_y: = lerpf(FOCUS_Y_NEAR, FOCUS_Y, t)
	var shift: = SHIFT_FRAC * _cam_dist


	var vr0: = get_viewport_rect().size
	if vr0.x > 0.0 and vr0.y > 0.0:
		shift = _cam_dist * tan(deg_to_rad(CAM_FOV) * 0.5) * (vr0.x / vr0.y)\
		* ((_open_right() - _rail_w) / vr0.x)
	cam.position = Vector3(shift, focus_y, _cam_dist)
	cam.look_at(Vector3(shift, focus_y, 0.0))






func _shot_with(id: String) -> CharacterConfig:
	var shot: = cfg.clone()
	var item: = AccessoryCatalog.by_id(id)
	if item != null:
		shot = cfg.acc_alone(item.category, id)
		shot.reset_acc_transform(item.category)
		var defs: = item.default_colors()
		for i in defs.size():
			shot.set_acc_color(item.category, i, defs[i])
	return shot



func _apply_preview(id: String) -> void :
	if _player == null:
		return
	var shot: = _shot_with(id)
	if _preview_kit == 1:
		_player.set_character(shot.gym_look(), shot.gym_kit())
	else:
		_player.set_character(shot, TeamKits.normalize(shot.captain_kit))



func _outfit_name() -> String:
	if section_mode and _compact and _preview_kit == 0:
		return "showing: uniform"
	return PREVIEW_NAMES[_preview_kit]

func _set_preview_kit(k: int) -> void :
	_preview_kit = k
	if _outfit_btn != null:
		_outfit_btn.text = _outfit_name()
	_apply_preview(_sel)



func _build_ui() -> void :
	_build_shell()
	_refresh_coins()






func _build_shell() -> void :
	var col: = UiStyle.rail_panel(self, _rail_w)
	if _rail_size() != "":
		UiStyle.slim_rail(col, _rail_size())
	for t in TABS:
		if String(t["id"]) == "titles" and not TITLES.enabled():
			continue
		var id: = String(t["id"])
		var b: = UiStyle.rail_tile(String(t["label"]), _tab_icon(id))
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if _rail_size() != "":
			UiStyle.slim_rail_tile(b, _rail_size())
		b.pressed.connect( func(): _select_tab(id))
		col.add_child(b)
		_tab_btns[id] = b

	var tail: = Control.new()
	tail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tail.size_flags_stretch_ratio = 2.0
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(tail)



	var head: = PanelContainer.new()
	head.name = "Header"
	var hsb: = UiStyle.flat_box(UiStyle.card(), 26, true)
	hsb.content_margin_left = 8.0 if _compact else 12.0
	hsb.content_margin_right = 16.0 if _compact else 26.0
	hsb.content_margin_top = 5.0 if _compact else 8.0
	hsb.content_margin_bottom = 5.0 if _compact else 8.0
	head.add_theme_stylebox_override("panel", hsb)
	var top_row: = HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 10)
	top_row.position = Vector2(_rail_w + (10.0 if _compact else 18.0), 8.0 if _compact else 12.0)
	add_child(top_row)
	if section_mode and player_tag != "":
		var tag: = Label.new()
		tag.text = player_tag
		tag.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		tag.add_theme_font_size_override("font_size", 30 if _compact else 44)
		tag.add_theme_color_override("font_color", player_color)
		tag.add_theme_color_override("font_outline_color", UiStyle.INK)
		tag.add_theme_constant_override("outline_size", 12 if _compact else 16)
		tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		top_row.add_child(tag)
	top_row.add_child(head)
	var hrow: = HBoxContainer.new()
	hrow.add_theme_constant_override("separation", 8 if _compact else 14)
	head.add_child(hrow)
	var st: = UiStyle.sticker("shoppingCart", UiStyle.PRIMARY, 34 if _compact else 52, 
		-0.08, UiStyle.INK)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hrow.add_child(st)
	var hv: = VBoxContainer.new()
	hv.add_theme_constant_override("separation", -4)
	hv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hrow.add_child(hv)
	var title: = Label.new()
	title.text = "shop"
	title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	title.add_theme_font_size_override("font_size", 22 if _compact else 32)
	title.add_theme_color_override("font_color", UiStyle.text())
	hv.add_child(title)
	var sub: = Label.new()
	sub.text = "new gear and cosmetics"
	UiStyle.style_label(sub, "small", UiStyle.muted())
	sub.add_theme_font_size_override("font_size", 14)
	sub.visible = not _compact
	hv.add_child(sub)


	var purse: = PanelContainer.new()
	purse.name = "Purse"
	var psb: = UiStyle.flat_box(UiStyle.card(), UiStyle.CAPSULE, true)
	psb.content_margin_left = 10.0 if _compact else 12.0
	psb.content_margin_right = 14.0 if _compact else 20.0
	psb.content_margin_top = 4.0 if _compact else 6.0
	psb.content_margin_bottom = 4.0 if _compact else 6.0
	purse.add_theme_stylebox_override("panel", psb)
	purse.anchor_left = 1.0
	purse.anchor_right = 1.0
	purse.offset_right = - _gutter
	purse.offset_top = 8.0 if _compact else 16.0
	purse.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(purse)
	_purse = purse
	var coinbox: = HBoxContainer.new()
	coinbox.add_theme_constant_override("separation", 8)
	purse.add_child(coinbox)
	var coin: = _coin_disc(18 if _compact else 22)
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	coinbox.add_child(coin)
	_coins_lbl = Label.new()
	_coins_lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_coins_lbl.add_theme_font_size_override("font_size", 18 if _compact else 22)
	_coins_lbl.add_theme_color_override("font_color", UiStyle.text())
	coinbox.add_child(_coins_lbl)


	var panel: = PanelContainer.new()
	panel.name = "Field"
	var fsb: = UiStyle.field_box()
	fsb.set_content_margin_all(8 if _compact else 14)
	panel.add_theme_stylebox_override("panel", fsb)
	panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)


	panel.offset_left = -592
	panel.offset_right = -16
	panel.offset_top = 76
	panel.offset_bottom = -16
	if section_mode:
		panel.offset_left = - _panel_w - _gutter
		panel.offset_right = - _gutter
		panel.offset_top = 48.0 if _compact else 76.0
		panel.offset_bottom = - _bottombar_h - 6.0
		panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(panel)
	UiStyle.field_doodles(panel)
	var pv: = VBoxContainer.new()
	pv.add_theme_constant_override("separation", 8 if _compact else 12)
	panel.add_child(pv)
	_build_head(pv)
	_build_shelf_scroll(pv)
	if section_mode:
		_build_section_actions()




	var chips: BoxContainer = VBoxContainer.new() if section_mode else HBoxContainer.new()
	chips.name = "ViewerChips"
	chips.add_theme_constant_override("separation", 6 if _compact else 10)
	chips.anchor_left = 1.0
	chips.anchor_right = 1.0
	chips.offset_right = -616.0
	chips.offset_left = -836.0
	chips.alignment = BoxContainer.ALIGNMENT_END
	chips.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(chips)
	_build_viewer_btns(chips, 15)
	if not section_mode:
		UiStyle.paint_viewer_btn(_outfit_btn, "singleplayer")
		UiStyle.paint_viewer_btn(_spin_btn, "return")
	else:
		var vfs: = 11 if _short else (13 if _compact else 16)
		UiStyle.paint_viewer_btn(_outfit_btn, "singleplayer", vfs)
		UiStyle.paint_viewer_btn(_spin_btn, "return", vfs)
		var right: = - _open_right() + _gutter - 4.0
		chips.offset_right = right
		chips.offset_left = right - 160.0
		var under: = func():
			if is_instance_valid(chips) and is_instance_valid(top_row):
				chips.offset_top = top_row.position.y + top_row.size.y + 8.0
				chips.offset_bottom = chips.offset_top + 40.0
		top_row.resized.connect(under)
		under.call_deferred()



	var place: = func():
		if not is_instance_valid(chips) or not is_instance_valid(head):
			return
		var need: = chips.get_combined_minimum_size().x
		var head_r: = top_row.position.x + top_row.size.x + 16.0


		var right: = -616.0
		if size.x + right - head_r < need:
			right = minf(-616.0 + (need - (size.x - 616.0 - head_r)), 
				- (16.0 + purse.size.x + 16.0))
		var under: = size.x + right - head_r < need
		if under:
			right = -616.0
		var top: = top_row.position.y + head.size.y + 12.0 if under else top_row.position.y + (head.size.y - 44.0) * 0.5
		chips.offset_right = right
		chips.offset_left = right - need
		chips.offset_top = top
		chips.offset_bottom = top + 44.0
	if not section_mode:
		resized.connect(place)
		head.resized.connect(place)
		purse.resized.connect(place)
		place.call_deferred()



	var lrow: = HBoxContainer.new()
	lrow.name = "BackRow"
	lrow.visible = not section_mode
	lrow.add_theme_constant_override("separation", 12)
	lrow.anchor_top = 1.0
	lrow.anchor_bottom = 1.0
	lrow.offset_left = _rail_w + 24.0
	lrow.offset_top = -64.0
	lrow.offset_bottom = -16.0
	add_child(lrow)
	var back: = Button.new()
	back.text = "back"
	UiStyle.style_button(back, "secondary", 18)
	back.icon = UiStyle.icon("arrowLeft", true)
	back.add_theme_constant_override("icon_max_width", 20)
	back.add_theme_constant_override("h_separation", 10)
	for stc in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		back.add_theme_color_override(stc, 
			UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY)
	back.custom_minimum_size = Vector2(120, 0)
	back.pressed.connect(_exit)
	lrow.add_child(back)
	var to_locker: = Button.new()
	to_locker.text = "locker"
	UiStyle.style_button(to_locker, "secondary", 18)
	to_locker.custom_minimum_size = Vector2(120, 0)
	to_locker.pressed.connect( func():
		UiWipe.wipe(get_tree(), func():
			GameConfig.goto_scene("res://game/character/locker.tscn")))
	lrow.add_child(to_locker)



	var card: = PanelContainer.new()
	card.name = "Selected"
	var csb: = UiStyle.flat_box(UiStyle.card(), 32)
	csb.set_border_width_all(4)
	csb.border_color = UiStyle.SECONDARY
	csb.content_margin_left = 10.0
	csb.content_margin_right = 8.0
	csb.content_margin_top = 6.0
	csb.content_margin_bottom = 6.0
	card.add_theme_stylebox_override("panel", csb)
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.anchor_right = 1.0
	card.offset_left = _rail_w + 300.0
	card.offset_right = -616.0
	card.offset_top = -72.0
	card.offset_bottom = -12.0
	if section_mode:

		card.offset_left = _rail_w + (10.0 if _compact else 24.0)
		card.offset_right = - _open_right() + _gutter - 4.0
		card.offset_top = - _bottombar_h + (2.0 if _compact else 0.0)
		card.offset_bottom = - _gutter
		csb.set_border_width_all(3 if _compact else 4)
		csb.content_margin_top = 2.0 if _compact else 6.0
		csb.content_margin_bottom = 2.0 if _compact else 6.0
	add_child(card)
	_sel_card = card
	var crow: = HBoxContainer.new()
	crow.add_theme_constant_override("separation", 12)
	card.add_child(crow)
	_sel_thumb = TextureRect.new()
	_sel_thumb.custom_minimum_size = Vector2(32, 32) if _compact else Vector2(44, 44)
	_sel_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sel_thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sel_thumb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	crow.add_child(_sel_thumb)
	var cv: = VBoxContainer.new()
	cv.add_theme_constant_override("separation", -4)
	cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	crow.add_child(cv)
	var small: = Label.new()
	small.text = "selected"
	UiStyle.style_label(small, "small", UiStyle.muted())
	small.visible = not _short
	if _compact:
		small.add_theme_font_size_override("font_size", 11)
	cv.add_child(small)
	_sel_name = Label.new()
	_sel_name.text = "pick an item"
	_sel_name.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	_sel_name.add_theme_font_size_override("font_size", SEL_NAME_FS)
	_sel_name.add_theme_color_override("font_color", UiStyle.text())
	_sel_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_sel_name.clip_text = true
	cv.add_child(_sel_name)
	_sel_name.resized.connect(_fit_sel_name)
	_buy_btn = Button.new()
	_buy_btn.text = "buy"
	UiStyle.style_button(_buy_btn, "primary", 15 if _compact else 19)
	_buy_btn.custom_minimum_size = Vector2(76 if _compact else 130, 0)
	_buy_btn.pressed.connect(_buy_selected)
	_buy_btn.disabled = true
	crow.add_child(_buy_btn)



const SEL_NAME_FS: = 18
func _fit_sel_name() -> void :
	if _sel_name == null or not is_instance_valid(_sel_name) or _sel_name.size.x <= 0.0:
		return
	var f: = _sel_name.get_theme_font("font")
	var fs: = SEL_NAME_FS
	while fs > 12 and f.get_string_size(_sel_name.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > _sel_name.size.x:
		fs -= 1
	if _sel_name.get_theme_font_size("font_size") != fs:
		_sel_name.add_theme_font_size_override("font_size", fs)



const TAB_RENDERS: = {"face": "face", "head": "hair", "extra": "accessories"}

func _tab_icon(id: String) -> Texture2D:
	var own: = "res://game/character/locker_icons/%s.png" % String(TAB_RENDERS.get(id, ""))
	if TAB_RENDERS.has(id) and ResourceLoader.exists(own):
		return load(own) as Texture2D
	return UiStyle.icon(String(TAB_ICONS.get(id, "star")), true)


func _build_viewer_btns(into: Container, fs: int) -> void :
	_outfit_btn = Button.new()
	_outfit_btn.text = _outfit_name()
	UiStyle.style_button(_outfit_btn, "secondary", fs)
	_outfit_btn.pressed.connect( func(): _set_preview_kit((_preview_kit + 1) % PREVIEW_NAMES.size()))
	into.add_child(_outfit_btn)
	_spin_btn = Button.new()
	_spin_btn.text = "spin: off"
	UiStyle.style_button(_spin_btn, "secondary", fs)
	_spin_btn.pressed.connect( func():
		_spin = not _spin
		_spin_btn.text = "spin: on" if _spin else "spin: off")
	into.add_child(_spin_btn)


func _build_shelf_scroll(pv: VBoxContainer) -> void :
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	pv.add_child(scroll)
	_scroll = scroll

	var pad: = MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 6)
	scroll.add_child(pad)
	_grid = GridContainer.new()
	_grid.columns = _item_columns()
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(_grid)


func _build_head(pv: VBoxContainer) -> void :
	_head = VBoxContainer.new()
	_head.name = "Head"
	_head.add_theme_constant_override("separation", 10)
	pv.add_child(_head)
	if TITLES.enabled():
		var band: = PanelContainer.new()
		band.name = "TitleBand"
		band.add_theme_stylebox_override("panel", UiStyle.flat_box(Color("8fbcf0"), 22))
		band.custom_minimum_size = Vector2(0, 64 if _compact else 100)
		band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var seat: = CenterContainer.new()
		band.add_child(seat)
		_title_pill = NAME_PILL.new()
		_title_pill.name = "TitlePreview"
		seat.add_child(_title_pill)
		_head.add_child(band)
		_title_band = band
	var tools: = HBoxContainer.new()
	tools.name = "Tools"
	tools.add_theme_constant_override("separation", 8)
	_head.add_child(tools)
	if TITLES.enabled():

		_shelf_row = HBoxContainer.new()
		_shelf_row.name = "Shelves"
		_shelf_row.add_theme_constant_override("separation", 6)
		for which in ["titles", "effects"]:
			var b: = Button.new()
			b.name = "Shelf_" + which
			b.text = which
			b.custom_minimum_size = Vector2(0 if _compact else 82, 32 if _compact else 40)
			_paint_shelf_tab(b, false)
			b.pressed.connect( func(): _open_shelf(which))
			_shelf_row.add_child(b)
			_shelf_btns[which] = b
		tools.add_child(_shelf_row)


	var box: = PanelContainer.new()
	box.name = "SearchBox"
	box.custom_minimum_size = Vector2(80 if _compact else 100, 32 if _compact else 40)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var look: = UiStyle.flat_box(UiStyle.card(), UiStyle.CAPSULE)
	look.border_color = Color(0, 0, 0, 0)
	look.content_margin_left = 16.0
	look.content_margin_right = 4.0
	box.add_theme_stylebox_override("panel", look)
	var inner: = HBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	box.add_child(inner)
	var glass: = TextureRect.new()
	glass.texture = UiStyle.icon("zoom")
	glass.custom_minimum_size = Vector2(16, 16)
	glass.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glass.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glass.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	glass.modulate = Color(1, 1, 1, 0.55)
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(glass)
	_search = LineEdit.new()
	_search.name = "Search"
	_search.placeholder_text = "search"
	_search.clear_button_enabled = true
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.max_length = 40
	_search.flat = true
	for state in ["normal", "focus", "read_only"]:
		_search.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_search.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	_search.add_theme_font_size_override("font_size", 15)
	_search.add_theme_color_override("font_color", UiStyle.text())
	_search.add_theme_color_override("font_placeholder_color", UiStyle.muted())
	_search.text_changed.connect( func(_t: String):
		_arrange(false)
		_scroll.scroll_vertical = 0)
	_search.focus_entered.connect( func():
		look.border_color = UiStyle.SECONDARY
		look.set_border_width_all(2))
	_search.focus_exited.connect( func():
		look.set_border_width_all(0))
	_search.text_submitted.connect( func(_t: String): _search.release_focus())
	inner.add_child(_search)
	tools.add_child(box)
	_sort = UiSelect.new(SORTS)
	_sort.name = "Sort"
	UiStyle.style_button(_sort, "secondary", 14)
	_sort.custom_minimum_size = Vector2(110 if _compact else 146, 32 if _compact else 40)
	_sort.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sort.picked.connect(_set_sort)
	_sort.flipped.connect( func(i: int, on: bool):
		if i == FILTER_EARNED:
			_earned_only = on
		_arrange(false)
		_scroll.scroll_vertical = 0)
	tools.add_child(_sort)

	_none_lbl = Label.new()
	_none_lbl.name = "NoneFound"
	_none_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_none_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(_none_lbl, "body", UiStyle.muted())
	_none_lbl.visible = false
	pv.add_child(_none_lbl)



func _paint_shelf_tab(b: Button, lit: bool) -> void :
	UiStyle.paint_field_tab(b, lit, 13 if _compact else 15)
	if _compact:
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			var sb: = b.get_theme_stylebox(st)
			if sb != null:
				sb.content_margin_left = 10.0
				sb.content_margin_right = 10.0



func _sync_filters() -> void :
	var want: Array = FILTERS if _tab == "titles" and _shelf == "titles" else []
	if _sort.toggles == want:
		return
	_sort.set_toggles(want)
	if not want.is_empty() and _earned_only:
		_sort.set_on(FILTER_EARNED, true, true)



func _shows(w: Dictionary, needle: String) -> bool:
	if needle != "" and not String(w["hay"]).contains(needle):
		return false
	if _earned_only and String(w["kind"]) == "title" and _shelf == "titles" and not TITLES.earned(w["item"]):
		return false
	return true

func _set_sort(mode: int) -> void :
	_sort_mode = clampi(mode, 0, SORTS.size() - 1)
	_arrange()
	_scroll.scroll_vertical = 0



func _stock(kind: String, item: Resource, ware_name: String, price: int) -> void :
	var ware: = {"kind": kind, "item": item, "name": ware_name, "hay": ware_name.to_lower(), 
		"price": price, "at": _wares.size(), "node": null}
	ware["state"] = _state_of(ware)
	ware["owned"] = String(ware["state"]) != ""
	_wares.append(ware)



func _state_of(ware: Dictionary) -> String:
	var item: Resource = ware["item"]
	match String(ware["kind"]):
		"title":
			if not TITLES.owns(item, _who()):
				return ""
			return "wearing" if str(TITLES.equipped(_who()).get("id", "")) == item.id else "owned"
		"effect":
			if not TITLES.owns_effect(item, _who()):
				return ""
			return "using" if str(TITLES.saved_look(_who()).get("fx", "")) == item.id else "owned"
	return "owned" if Progression.owns(item.id, item.price, _who()) else ""

func _make_card(ware: Dictionary) -> Control:
	match String(ware["kind"]):
		"title":
			return _title_card(ware["item"])
		"effect":
			return _effect_card(ware["item"])
	return _item_card(ware["item"] as AccessoryItem)


func _build_some(at_least: int, usec: int) -> void :
	var t0: = Time.get_ticks_usec()
	var needle: = _search.text.strip_edges().to_lower()
	var made: = 0
	while _built < _wares.size() and (made < at_least or Time.get_ticks_usec() - t0 < usec):
		var ware: Dictionary = _wares[_built]
		var card: = _make_card(ware)
		card.visible = _shows(ware, needle)
		_host.add_child(card)
		ware["node"] = card
		_built += 1
		made += 1


func _fill(gen: int) -> void :
	_wares.sort_custom(_ware_before)
	_build_some(BUILD_FIRST, 0)
	_arrange(false)
	while _built < _wares.size():
		await get_tree().process_frame
		if gen != _build_gen or not is_inside_tree():
			return
		_build_some(4, BUILD_USEC)




func _refresh_shelf() -> void :
	for ware in _wares:
		var state: = _state_of(ware)
		if state == String(ware["state"]):
			continue
		ware["state"] = state
		ware["owned"] = state != ""
		var old: Control = ware["node"]
		if old == null:
			continue
		var at: = old.get_index()
		_host.remove_child(old)
		old.queue_free()
		var card: = _make_card(ware)
		card.visible = old.visible
		_host.add_child(card)
		_host.move_child(card, at)
		ware["node"] = card
		_paint_card(card, _ware_key(ware) == _sel)
	if _sort_mode == SORT_UNOWNED:
		_arrange()
	if _tab == "titles":
		_show_title_preview()

func _ware_before(a: Dictionary, b: Dictionary) -> bool:


	if _sort_mode in [SORT_PRICE_UP, SORT_PRICE_DOWN] and (int(a["price"]) < 0) != (int(b["price"]) < 0):
		return int(b["price"]) < 0
	match _sort_mode:
		SORT_PRICE_UP:
			if int(a["price"]) != int(b["price"]):
				return int(a["price"]) < int(b["price"])
		SORT_PRICE_DOWN:
			if int(a["price"]) != int(b["price"]):
				return int(a["price"]) > int(b["price"])
		SORT_AZ, SORT_ZA:
			var c: = String(a["name"]).naturalnocasecmp_to(String(b["name"]))
			if c != 0:
				return (c < 0) == (_sort_mode == SORT_AZ)
		SORT_UNOWNED:
			if bool(a["owned"]) != bool(b["owned"]):
				return not bool(a["owned"])
	return int(a["at"]) < int(b["at"])



func _arrange(reorder: = true) -> void :
	var needle: = _search.text.strip_edges().to_lower()
	var found: = 0
	for w in _wares:
		var on: bool = _shows(w, needle)
		if w["node"] != null:
			(w["node"] as Control).visible = on
		if on:
			found += 1
	if reorder and not _wares.is_empty():
		if _built < _wares.size():
			_rebuild_panel()
			return
		_wares.sort_custom(_ware_before)
		for i in _wares.size():
			_host.move_child(_wares[i]["node"], i)
	_none_lbl.visible = found == 0 and not _wares.is_empty()
	if _none_lbl.visible:
		_none_lbl.text = "nothing here matches \"%s\"" % needle if needle != "" else "nothing here matches the filter"

func _select_tab(id: String) -> void :
	_tab = id
	for tid in _tab_btns:
		var b: Button = _tab_btns[tid]
		UiStyle.paint_rail_tile(b, tid == id)
		if _rail_size() != "":
			UiStyle.repaint_slim_tile(b, _rail_size())
	_rebuild_panel()

func _tab_items() -> Array:
	var cats: Array = []
	for t in TABS:
		if String(t["id"]) == _tab:
			cats = t["cats"]
			break
	var out: Array = []
	var seen: = {}
	for c in cats:
		for it in AccessoryCatalog.for_category(c):
			if it == null or it.price <= 0 or seen.has(it.id):
				continue
			seen[it.id] = true
			out.append(it)
	return out

func _rebuild_panel() -> void :
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	_wares.clear()
	_build_gen += 1
	_built = 0
	_host = _grid
	_none_lbl.visible = false

	if _title_band != null:
		_title_band.visible = _tab == "titles"
		_shelf_row.visible = _tab == "titles"
	_sync_filters()
	if _tab == "titles":
		_build_titles()
		_fill(_build_gen)
		return
	_grid.columns = _item_columns()
	var items: = _tab_items()
	if items.is_empty():
		var none: = Label.new()
		none.text = "nothing here yet"
		UiStyle.style_label(none, "body", UiStyle.muted())
		_grid.add_child(none)
		return
	_thumb_gen += 1
	for it in items:
		_stock("acc", it, it.name_or_id(), it.price)
	_fill(_build_gen)
	_render_thumbs(items, _thumb_gen)



func _paint_card(card: Control, picked: bool) -> void :
	var b: = card as Button
	if b == null:
		return
	var box: = UiStyle.flat_box(UiStyle.card(), 22)
	if picked:
		box.set_border_width_all(4)
		box.border_color = UiStyle.SECONDARY
	var hov: = box.duplicate() as StyleBoxFlat
	if not picked:
		hov.bg_color = UiStyle.card().lerp(UiStyle.SECONDARY, 0.05)
	for st in ["normal", "focus", "disabled"]:
		b.add_theme_stylebox_override(st, box)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	UiStyle.hover_grow(b, 1.05)


func _ware_key(ware: Dictionary) -> String:
	var item: Resource = ware["item"]
	match String(ware["kind"]):
		"title":
			return TITLES.own_key(item.id)
		"effect":
			return TITLES.fx_key(item.id)
	return String(item.id)


func _paint_picked() -> void :
	for ware in _wares:
		if ware["node"] != null:
			_paint_card(ware["node"], _ware_key(ware) == _sel)

func _item_card(it: AccessoryItem) -> Control:
	var owned: = Progression.owns(it.id, it.price, _who())
	var card: = Button.new()
	card.custom_minimum_size = Vector2(128, 132) if _compact else Vector2(164, 176)
	card.toggle_mode = false
	UiStyle.style_button(card, "secondary", 14)
	_paint_card(card, it.id == _sel)
	card.pressed.connect( func(): _select(it))
	var v: = VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var thumb: = TextureRect.new()
	thumb.custom_minimum_size = Vector2(90, 76) if _compact else Vector2(120, 108)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	thumb.name = "Thumb_" + it.id
	if _thumb_cache.has(it.id):
		thumb.texture = _thumb_cache[it.id]
	v.add_child(thumb)
	var nm: = Label.new()
	nm.text = it.name_or_id()
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	nm.add_theme_font_size_override("font_size", 13 if _compact else 16)
	nm.add_theme_color_override("font_color", UiStyle.text())
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(nm)
	if owned:
		var o: = Label.new()
		o.text = "owned"
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiStyle.style_label(o, "small", UiStyle.SUCCESS)
		v.add_child(o)
	else:
		var pr: = HBoxContainer.new()
		pr.alignment = BoxContainer.ALIGNMENT_CENTER
		pr.add_theme_constant_override("separation", 5)
		pr.add_child(_coin_disc(15))
		var pl: = Label.new()
		pl.text = _comma(it.price)
		UiStyle.style_label(pl, "small")
		pr.add_child(pl)
		v.add_child(pr)
	return card

func _render_thumbs(items: Array, gen: int) -> void :

	for raw in items:
		var it: = raw as AccessoryItem
		if it == null or _thumb_cache.has(it.id):
			continue
		var shot: = _shot_with(it.id)
		var preset: = it.portrait_preset()
		var tex: = await CharacterPortrait.render(shot, preset, Vector2i.ZERO, self)
		if not is_instance_valid(self) or gen != _thumb_gen:
			return
		if tex == null:
			continue
		_thumb_cache[it.id] = tex
		var t: = _grid.find_child("Thumb_" + it.id, true, false) as TextureRect
		if t != null:
			t.texture = tex
		if it.id == _sel and _sel_thumb != null:
			_sel_thumb.texture = tex
			_sel_thumb.visible = true

var poof_count: = 0

func _select(it: AccessoryItem) -> void :
	var fresh: = _sel != it.id
	_sel = it.id
	_apply_preview(it.id)


	if fresh and _player != null and _player.is_inside_tree():
		var rig: ModelRig = _player._model
		var head: = rig.head_centre_global() if rig != null else _player.global_position + Vector3(0.0, 1.45, 0.0)
		LockerPoof.burst(world, head + Vector3(0.0, 0.08, 0.0), 0.55)
		poof_count += 1
	_paint_picked()
	_refresh_buy()





func _ware(id: String) -> Dictionary:
	if id.begins_with(TITLES.OWN_PREFIX):
		var title: = TITLES.by_id(id.trim_prefix(TITLES.OWN_PREFIX))
		if title == null or title.exclusive:
			return {}


		return {"id": id, "name": title.text.to_lower(), "price": title.price, 
			"owned": TITLES.owns(title, _who()), "title": title, "earn": TITLES.earned(title)}
	if id.begins_with(TITLES.FX_PREFIX):
		var fx: = TITLES.effect(id.trim_prefix(TITLES.FX_PREFIX))
		if fx == null:
			return {}
		return {"id": id, "name": "%s effect" % fx.label, "price": fx.price, 
			"owned": TITLES.owns_effect(fx, _who()), "effect": fx}
	var it: = AccessoryCatalog.by_id(id)
	if it == null:
		return {}
	return {"id": id, "name": it.name_or_id(), "price": it.price, 
		"owned": Progression.owns(it.id, it.price, _who())}



func _refresh_buy() -> void :
	var ware: = _ware(_sel)
	if ware.is_empty():
		return
	_sel_name.text = String(ware["name"])
	_fit_sel_name()
	if _sel_thumb != null:
		_sel_thumb.texture = _thumb_cache.get(_sel, null)
		_sel_thumb.visible = _sel_thumb.texture != null
	var owned: = bool(ware["owned"])
	var price: = int(ware["price"])
	if owned and ware.has("title"):

		var worn: bool = str(TITLES.equipped(_who()).get("id", "")) == ware["title"].id
		_buy_btn.text = "worn" if worn else "wear"
		_buy_btn.disabled = worn
	elif owned and ware.has("effect"):

		var using: bool = str(TITLES.saved_look(_who()).get("fx", "")) == ware["effect"].id
		_buy_btn.text = "using" if using else "use"
		_buy_btn.disabled = using
	elif bool(ware.get("earn", false)):

		_buy_btn.text = "earn it"
		_buy_btn.disabled = true
	else:
		_buy_btn.text = "owned" if owned else ("buy  " + _comma(price))

		_buy_btn.disabled = owned or not Progression.can_afford(price, _who())
	_paint_buy( not owned and not bool(ware.get("earn", false)))



var _buy_kind: = "primary"

func _paint_buy(spends: bool) -> void :
	var kind: = "chip" if spends else "primary"
	if kind == _buy_kind:
		return
	_buy_kind = kind
	UiStyle.style_button(_buy_btn, kind, 15 if _compact else 19)

func _buy_selected() -> void :
	var ware: = _ware(_sel)
	if ware.is_empty():
		return
	if ware.has("title") and bool(ware["owned"]):

		TITLES.equip(ware["title"].id, TITLES.saved_look(_who()), _who())
		_refresh_shelf()
		_refresh_buy()
		return
	if ware.has("effect") and bool(ware["owned"]):


		var look: Dictionary = TITLES.saved_look(_who())
		look["fx"] = ware["effect"].id
		look.erase("fp")
		look.erase("ac")
		TITLES.equip(str(TITLES.equipped(_who()).get("id", "")), look, _who())
		_refresh_shelf()
		_refresh_buy()
		return
	if bool(ware.get("earn", false)):
		return

	var p: = _who()
	var before: int = p.coins if p != null else 0
	if Progression.purchase(_sel, int(ware["price"]), _who()):
		UiStyle.sfx("purchase")


		var after: int = p.coins if p != null else 0
		if is_instance_valid(_purse):
			UiStyle.chip_spend(_purse, before - after, _coins_lbl, before, after)
		else:
			_refresh_coins()
		_cheer()
		_refresh_shelf()
		_refresh_buy()
	else:
		UiStyle.sfx("error")




var _cheer_voice: AudioStreamPlayer = null

func _cheer() -> void :
	if _player == null or not is_instance_valid(_player):
		return
	var clips: Array = _player._shuffle_clips("nice")
	if not clips.is_empty():
		_player.play_gesture_clip(String(clips[randi() % clips.size()]))
	if not GameConfig.voice_enabled:
		return
	var c: CharacterConfig = _player.character
	var sub: = "" if c == null or c.voice_pack <= 1 else "%d/" % c.voice_pack
	var take: = "cheer_%d" % (1 + randi() % 3)
	var path: = "res://game/sfx/PlayerSfx/%s%s.wav" % [sub, take]
	if not ResourceLoader.exists(path):
		path = "res://game/sfx/PlayerSfx/%s.wav" % take
	if not ResourceLoader.exists(path):
		return
	if _cheer_voice == null:
		_cheer_voice = AudioStreamPlayer.new()
		_cheer_voice.bus = "voice"
		add_child(_cheer_voice)
	_cheer_voice.stream = load(path)
	_cheer_voice.pitch_scale = c.voice_pitch() if c != null else 1.0
	_cheer_voice.volume_db = -11.0 if c != null and c.voice_pack >= 2 else -3.0
	_cheer_voice.play()






func _build_titles() -> void :
	_grid.columns = 1
	for which in _shelf_btns:
		_paint_shelf_tab(_shelf_btns[which], which == _shelf)
	var shelf: = GridContainer.new()
	shelf.name = "TitleShelf" if _shelf == "titles" else "EffectShelf"
	shelf.columns = 2
	shelf.add_theme_constant_override("h_separation", 12)
	shelf.add_theme_constant_override("v_separation", 12)
	shelf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _shelf == "titles":


		for item in TITLES.shelf():
			_stock("title", item, String(item.text), -1 if TITLES.earned(item) else item.price)
	else:
		for fx in TITLES.effects_for_sale():
			_stock("effect", fx, String(fx.label), fx.price)
	_grid.add_child(shelf)
	_host = shelf
	_show_title_preview()

func _open_shelf(which: String) -> void :
	_shelf = which
	_rebuild_panel()
	_scroll.scroll_vertical = 0




func _effect_card(fx: Resource) -> Control:
	var owned: = TITLES.owns_effect(fx, _who())
	var card: = Button.new()
	card.name = "EffectCard_" + String(fx.id)
	card.custom_minimum_size = Vector2(0, 62 if _compact else 84)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(card, "secondary", 14)
	_paint_card(card, TITLES.fx_key(fx.id) == _sel)
	card.pressed.connect( func(): _select_effect(fx))
	var v: = VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 7)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var chip: = TITLE_CHIP.new()
	chip.show_style(TITLES.suited(TITLES.default_look(), fx), 16, String(fx.label))
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(chip)
	if owned:
		var using: bool = str(TITLES.saved_look(_who()).get("fx", "")) == fx.id
		var o: = Label.new()
		o.text = "using" if using else "owned"
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiStyle.style_label(o, "small", UiStyle.SUCCESS)
		v.add_child(o)
	else:
		var pr: = HBoxContainer.new()
		pr.alignment = BoxContainer.ALIGNMENT_CENTER
		pr.add_theme_constant_override("separation", 5)
		pr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pr.add_child(_coin_disc(15))
		var pl: = Label.new()
		pl.text = _comma(fx.price)
		UiStyle.style_label(pl, "small")
		pr.add_child(pl)
		v.add_child(pr)
	return card

func _select_effect(fx: Resource) -> void :
	_sel = TITLES.fx_key(fx.id)
	_paint_picked()
	_refresh_buy()
	_show_title_preview()

func _title_card(item: Resource) -> Control:
	var owned: = TITLES.owns(item, _who())
	var card: = Button.new()
	card.name = "TitleCard_" + String(item.id)
	card.custom_minimum_size = Vector2(0, 62 if _compact else 84)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(card, "secondary", 14)
	_paint_card(card, TITLES.own_key(item.id) == _sel)
	card.pressed.connect( func(): _select_title(item))
	var v: = VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 7)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)

	var chip: = TITLE_CHIP.new()
	chip.show_style(TITLES.sanitize({"id": item.id}), 15)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(chip)
	if owned:
		var worn: bool = str(TITLES.equipped(_who()).get("id", "")) == item.id
		var o: = Label.new()
		o.text = "wearing" if worn else "owned"
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiStyle.style_label(o, "small", UiStyle.SUCCESS)
		v.add_child(o)
	elif TITLES.earned(item):

		var ach: AchievementDef = Achievements.def_of(String(item.from_achievement))

		var pad: = MarginContainer.new()
		pad.add_theme_constant_override("margin_left", 12)
		pad.add_theme_constant_override("margin_right", 12)
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var e: = Label.new()
		e.name = "EarnLine"
		e.text = ach.desc if ach != null else "an achievement"
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		e.max_lines_visible = 2
		e.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		e.tooltip_text = e.text
		e.mouse_filter = Control.MOUSE_FILTER_PASS
		UiStyle.style_label(e, "small", UiStyle.muted())
		pad.add_child(e)
		v.add_child(pad)
	else:
		var pr: = HBoxContainer.new()
		pr.alignment = BoxContainer.ALIGNMENT_CENTER
		pr.add_theme_constant_override("separation", 5)
		pr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pr.add_child(_coin_disc(15))
		var pl: = Label.new()
		pl.text = _comma(item.price)
		UiStyle.style_label(pl, "small")
		pr.add_child(pl)
		v.add_child(pr)
	return card

func _select_title(item: Resource) -> void :
	_sel = TITLES.own_key(item.id)
	_paint_picked()
	_refresh_buy()
	_show_title_preview()




func _show_title_preview() -> void :
	if not is_instance_valid(_title_pill):
		return
	var prof: = _who()
	var who: String = prof.name if prof != null else Net.local_display_name()
	var style: Dictionary = TITLES.equipped(_who())
	var say: = ""
	if _sel.begins_with(TITLES.OWN_PREFIX):
		var picked: = _sel.trim_prefix(TITLES.OWN_PREFIX)
		if picked != str(style.get("id", "")):
			style = TITLES.sanitize({"id": picked})
	elif _sel.begins_with(TITLES.FX_PREFIX):


		var fx: = TITLES.effect(_sel.trim_prefix(TITLES.FX_PREFIX))
		var worn_id: = str(style.get("id", ""))
		style = TITLES.suited(TITLES.default_look(), fx)
		style["id"] = worn_id
		if worn_id == "":
			say = "your title"
	_title_pill.show_name(who, style, 22 if _compact else 30, true, say)

func _refresh_coins() -> void :
	var p: = _who()
	_coins_lbl.text = _comma(p.coins if p != null else 0)

func _exit() -> void :
	if section_mode:
		locker.close_shop()
		return
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene("res://game/ui/menu.tscn"))


func _item_columns() -> int:
	if not section_mode:
		return 3
	var card: = 128.0 if _compact else 164.0
	return clampi(int((_panel_w - 20.0) / (card + 12.0)), 2, 3)






func _build_section_actions() -> void :
	var row: = HBoxContainer.new()
	row.name = "SaveRow"
	row.add_theme_constant_override("separation", 8 if _compact else 12)
	row.anchor_left = 1.0
	row.anchor_right = 1.0
	row.anchor_top = 1.0
	row.anchor_bottom = 1.0
	row.offset_left = - _panel_w - _gutter
	row.offset_right = - _gutter
	row.offset_top = - _bottombar_h + (4.0 if _compact else 8.0)
	row.offset_bottom = - _gutter if _compact else -12.0
	add_child(row)
	var back: = Button.new()
	back.name = "BackToLocker"
	back.text = "back to locker"
	back.custom_minimum_size = Vector2(0 if _compact else 140, 0)
	UiStyle.style_button(back, "secondary", 13 if _compact else 18)
	back.icon = UiStyle.icon("arrowLeft", true)
	back.add_theme_constant_override("icon_max_width", 16 if _compact else 20)
	back.add_theme_constant_override("h_separation", 6 if _compact else 10)
	for stc in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		back.add_theme_color_override(stc, 
			UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY)
	back.pressed.connect(_exit)
	row.add_child(back)
	_ready_btn = Button.new()
	_ready_btn.name = "Ready"
	_ready_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ready_btn.pressed.connect( func(): locker.set_ready( not bool(locker.is_ready)))
	row.add_child(_ready_btn)

func _paint_ready() -> void :
	if _ready_btn != null and locker != null:
		locker.paint_ready_button(_ready_btn, bool(locker.is_ready), 16 if _compact else 22)



func reshow() -> void :
	world.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_refresh_coins()
	_refresh_shelf()
	_paint_ready()

func hidden_now() -> void :
	world.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_dragging = false

const PAD_TURN: = 3.2

func turn_preview(amount: float) -> void :
	if _player != null:
		_player.visual.rotation.y += amount * PAD_TURN


func cycle_tab(dir: int) -> void :
	var ids: Array = _tab_btns.keys()
	if ids.is_empty():
		return
	_select_tab(ids[posmod(ids.find(_tab) + dir, ids.size())])
	UiStyle.sfx("hover")



func pad_back() -> void :
	if not section_mode:


		if UiStyle.dialog_active():
			UiStyle.active_dialog.queue_free()
			UiStyle.sfx("close")
			return
		_exit()
		return
	if bool(locker.is_ready):
		locker.set_ready(false)
		UiStyle.sfx("back")
		return
	_exit()


const SOLO_POINTER: = preload("res://game/ui/solo_pointer.gd")
var _solo: Node = null
var _pointer: PlayerCursor = null

func _build_solo_pointer() -> void :
	_solo = SOLO_POINTER.new()
	add_child(_solo)
	_pointer = _solo.cursor
	_pointer.turn.connect(turn_preview)
	_pointer.tab_prev.connect(cycle_tab.bind(-1))
	_pointer.tab_next.connect(cycle_tab.bind(1))
	_pointer.back_pressed.connect(pad_back)

func mouse_took_over() -> void :
	if _solo != null:
		_solo.mouse_took_over()



var _stray: Control = null
var _click_held: = false

func _drop_stray_focus(c: Control) -> void :
	if c == null or c is LineEdit or c is TextEdit or UiSelect.active != null:
		_stray = null
		return
	_stray = c
	if not _click_held:
		_release_stray.call_deferred()

func _release_stray() -> void :
	var c: = _stray
	_stray = null
	if c != null and is_instance_valid(c) and c.has_focus() and UiSelect.active == null:
		c.release_focus()





func _coin_disc(px: = 20) -> Control:
	return UiStyle.coin_disc(px)

func _comma(n: int) -> String:
	return UiStyle.commafy(n)
