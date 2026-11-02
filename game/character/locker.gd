extends Control
















const PANEL_W: = 486.0
const RAIL_W: = 96.0
const PANEL_TOP: = 16.0
const TOPBAR_H: = 96.0
const BOTTOMBAR_H: = 64.0
const DRAG_SPEED: = 0.012




const CAM_FOV: = 12.0
const ZOOM_STEP: = 0.76
const ZOOM_MIN: = 4.1
const ZOOM_MAX: = 16.6





const CAM_SHIFT_FRAC: = 0.0514


const CAM_FOCUS_Y: = 1.05
const CAM_FOCUS_Y_NEAR: = 1.45
const CAM_FOCUS_NEAR_DIST: = 10.2
const BODY_SPAN: = 1.75
const HAIR_THUMB: = Vector2(72, 72)

const HairWarm: = preload("res://game/character/hair_warm.gd")

const PREVIEW_NAMES: = ["showing: captain uniform", "showing: gym"]
const PREVIEW_CAPTAIN: = 0
const PREVIEW_GYM: = 1

const VOICE_SAMPLES: = ["dive1", "dive2", "dive3", "jump1", "jump2", "jump3", 
	"recieve1", 

	"igot_1", "igot_2", "igot_3", "igot_4", "cheer_1", "cheer_2", "cheer_3", "cheer_4", 
	"sorry_1", "sorry_2", "sorry_3", "sorry_4", "dm_1", "dm_2", "dm_3", "dm_4", 
	"onetouch_1", "onetouch_2", "onetouch_3", 

	"thanks1", "thanks2", "thanks3", "thanks4", "quick1", "quick2", "quick3", "quick4", 
	"high1", "high2", "high3", "high4", 

	"atk_strong", "attk_strong_2"]






const PICK_ANIMS: = ["igot", "nice1", "dressup_1", "dressup_2", "dressup_3", "dressup_4"]

const SECTIONS: = [
	["face", "face"], ["body", "body"], ["voice", "voice"], ["hair", "hair"], 

	["accessories", "accessories"], ["uniforms", "outfits"], 
	["presets", "presets"], 

	["studio", "studio"], 
]
const FACE_SUBS: = [
	["look", "look"], ["eyes", "eyes"], ["brows", "brows"], 
	["nose", "nose"], ["mouth", "mouth"], 
]




const ACCESSORY_SUBS: = [
	["head", "head"], ["face", "face"], ["extra", "extra"], 
]



const HAIR_SUBS: = [
	["style", "hair"], ["facial", "facial hair"], 
]


const OUTFIT_SUBS: = [
	["uniform", "captain uniform"], ["gym", "gym outfit"], 
]
const STUDIO_SUBS: = [
	["canvas", "canvas"], ["background", "background"], ["add", "add"], 
	["layers", "layers"], ["edit", "edit"], ["options", "options"], 
]


const SECTION_ICONS: = {
	"face": "singleplayer", "body": "multiplayer", "voice": "audioOn", 
	"hair": "contrast", "accessories": "star", "uniforms": "medal1", 
	"presets": "save", "studio": "tablet", 
}
const SECTION_ICON_DIR: = "res://game/character/locker_icons/"
const SUBS: = {
	"face": FACE_SUBS, 
	"accessories": ACCESSORY_SUBS, 
	"hair": HAIR_SUBS, 
	"uniforms": OUTFIT_SUBS, 
	"studio": STUDIO_SUBS, 
}

var cfg: CharacterConfig
var _onboard_roll: CharacterConfig = null
var _slots: Array = []











signal ready_changed(on: bool)
var section_mode: = false
var profile: SavedProfile = null
var player_color: = Color.WHITE
var player_tag: = ""
var is_ready: = false
var _ready_btn: Button = null
var _compact: = false

var _panel_w: = PANEL_W
var _topbar_h: = TOPBAR_H
var _bottombar_h: = BOTTOMBAR_H
var _rail_w: = 0.0
var _gutter: = 16.0
var _short: = false
var _short_names: = false
var _zoom_max: = ZOOM_MAX

var _pick_panel: Control = null
var _pick: ColorPicker = null
var _pick_cb: = Callable()
var _pick_chip: Button = null


func _who() -> SavedProfile:
	return profile if profile != null else ProfileStore.active()

var _player: Player
var _dragging: = false
var _spin: = false
var _preview_kit: = 0
var _cam_dist: = 14.0

var _sub_box: HFlowContainer
var _content: VBoxContainer
var _rail_btns: = {}
var _sub_btns: = {}
var _section: = "face"


var _pick_armed: = false
var _pick_quiet: = false
var _last_pick_anim: = ""
var pick_anim_count: = 0
var _subsel: = {"face": "look", "accessories": "head", "hair": "style", 
	"uniforms": "uniform", "studio": "canvas"}


var _acc_pick: = {}
var _slot_box: HBoxContainer
var _slot_btns: Array = []
var _outfit_btn: Button
var _spin_btn: Button


var _studio: LockerStudio
var _studio_export: Button
var _studio_where: Label
var _turntable_btns: Array = []
var _studio_btns: Array = []

var _hair_buttons: Array = []
var _hair_thumb_cache: = {}
var _facial_buttons: Array = []
var _facial_thumb_cache: = {}
var _number_note: Label = null


const THUMB_DEBOUNCE: = 0.35
var _thumb_refresh_token: = 0


var _thumb_generation: = 0


var _slot_thumb_cache: = {}
var _slot_thumb_rects: = {}




var _acc_thumb_cache: = {}
var _acc_buttons: = {}

var _voice_preview: AudioStreamPlayer
var _voice_streams: Array = []

@onready var world: SubViewport = $Preview / SubViewport




func _enter_tree() -> void :
	ModelRig.pick_on_worker += 1

func _exit_tree() -> void :
	ModelRig.pick_on_worker -= 1

func _ready() -> void :



	_rail_w = RAIL_W
	_topbar_h = 70.0
	_bottombar_h = 72.0
	if not section_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MusicManager.set_muffled(true)
	else:


		world.own_world_3d = true
		_layout_for_size(get_viewport_rect().size)


	cfg = GameConfig.character.clone() if GameConfig.character != null\
	else CharacterConfig.new()




	if GameConfig.onboarding_active and not section_mode:
		cfg = CharacterConfig.random(null, true)
		_onboard_roll = cfg.clone()
	if section_mode and _who() != ProfileStore.active():

		cfg = CharacterConfig.from_dict(_who().character)\
		if not _who().character.is_empty() else CharacterConfig.new()
	_slots = ProfileStore.slots_of(_who())


	HairWarm.warm_all(cfg.hair_flip)
	_player = preload("res://game/player/player.tscn").instantiate()
	_player.enable_reflection = false
	world.add_child(_player)
	_player.charge_ui_enabled = false

	_player.drop_shadow.visible = false



	var cam: Camera3D = $Preview / SubViewport / Camera3D
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.fov = CAM_FOV
	_frame_cam()
	Ink.apply(cam)

	_voice_preview = AudioStreamPlayer.new()


	_voice_preview.bus = "voice"
	add_child(_voice_preview)
	_load_voice_streams()

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bd: = UiBackdrop.new("balls")


	bd.dark_page = Color("3a3a40")
	bd.calm = true
	bd.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bd)
	move_child(bd, 0)
	_build_rail()
	_build_preview_toolbar()
	if LockerStudio.available():
		_build_studio()
	_build_panel()
	if section_mode:
		_build_pick_panel()
	_select_section("face")
	_poof_prev = _poof_look()
	_refresh()




	get_viewport().gui_focus_changed.connect(_drop_stray_focus)
	if not section_mode:
		_build_solo_pointer()
		_dev_shot()




func _layout_for_size(sz: Vector2) -> void :
	_compact = sz.x < 1000.0 or sz.y < 640.0
	_short = sz.y < 520.0
	if _compact:

		_panel_w = clampf(sz.x * (0.52 if sz.y > sz.x else 0.6), 300.0, PANEL_W)

		_rail_w = UiStyle.rail_width(_rail_size())
		_topbar_h = 46.0 if _short else 58.0
		_bottombar_h = 46.0 if _short else 56.0
		_gutter = 8.0

	_short_names = sz.x - _panel_w - _rail_w - _gutter < 360.0




	if sz.x > 0.0 and sz.y > 0.0:
		var open: = 1.0 - (_panel_w + _rail_w + _gutter) / sz.x
		var per_unit: = 2.0 * tan(deg_to_rad(CAM_FOV) * 0.5) * (sz.x / sz.y) * open
		var need: = BODY_SPAN / maxf(per_unit, 0.001)


		var reserve: = _bottombar_h + (56.0 if _short_names else 0.0)
		var room: = sz.y * 0.5 - reserve
		if room > 10.0:
			need = maxf(need, CAM_FOCUS_Y * sz.y / (2.0 * tan(deg_to_rad(CAM_FOV) * 0.5) * room))
		_zoom_max = maxf(ZOOM_MAX, need)
		_cam_dist = clampf(maxf(_cam_dist, need), ZOOM_MIN, _zoom_max)




func _process(delta: float) -> void :
	if not visible:
		return
	if _section == "studio":
		return
	if _spin and not _dragging:
		_player.visual.rotation.y += delta * 0.6

func _physics_process(_delta: float) -> void :
	if not visible or _section == "studio":
		return
	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3.ZERO
	_player.simulate(PlayerInput.new(), _delta)
	_player.global_position = Vector3.ZERO
	_player.velocity = Vector3.ZERO

func _input(event: InputEvent) -> void :
	var mbe: = event as InputEventMouseButton
	if mbe != null and mbe.button_index == MOUSE_BUTTON_LEFT:
		_click_held = mbe.pressed
		if not mbe.pressed and _stray != null:
			_release_stray.call_deferred()
	if not visible:
		return
	if _section == "studio":
		return
	if _popup_open():
		_dragging = false
		return


	var key: = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_Z and key.is_command_or_control_pressed() and not (get_viewport().gui_get_focus_owner() is LineEdit):
		undo()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton:
		var click: = event as InputEventMouseButton

		if click.position.x >= size.x - _panel_w or click.position.y <= _topbar_h\
		or click.position.x <= _rail_w:
			return

		if _pick_panel != null and _pick_panel.visible:
			return
		if click.button_index == MOUSE_BUTTON_LEFT:
			_dragging = click.pressed
		elif click.button_index == MOUSE_BUTTON_WHEEL_UP and click.pressed:
			_zoom(-1.0)
		elif click.button_index == MOUSE_BUTTON_WHEEL_DOWN and click.pressed:
			_zoom(1.0)
	elif event is InputEventMouseMotion and _dragging:
		_player.visual.rotation.y += (event as InputEventMouseMotion).relative.x\
		* DRAG_SPEED

func _zoom(dir: float) -> void :
	_cam_dist = clampf(_cam_dist + dir * ZOOM_STEP, ZOOM_MIN, _zoom_max)
	_frame_cam()
	Ink.apply($Preview / SubViewport / Camera3D)





func _frame_cam() -> void :
	var cam: Camera3D = $Preview / SubViewport / Camera3D
	var t: = clampf(inverse_lerp(ZOOM_MIN, CAM_FOCUS_NEAR_DIST, _cam_dist), 0.0, 1.0)
	var focus_y: = lerpf(CAM_FOCUS_Y_NEAR, CAM_FOCUS_Y, t)
	var shift: = CAM_SHIFT_FRAC * _cam_dist


	var vr0: = get_viewport_rect().size
	if vr0.y > 0.0 and vr0.x > 0.0:
		shift = _cam_dist * tan(deg_to_rad(CAM_FOV) * 0.5) * (vr0.x / vr0.y)\
		* (_panel_w + _gutter - _rail_w) / vr0.x
	cam.position = Vector3(shift, focus_y, _cam_dist)
	cam.look_at(Vector3(shift, focus_y, 0.0))



func _load_voice_streams() -> void :
	_voice_streams.clear()
	var sub: = "" if cfg == null or cfg.voice_pack <= 1 else "%d/" % cfg.voice_pack
	for snd in VOICE_SAMPLES:
		var path: = "res://game/sfx/PlayerSfx/%s%s.wav" % [sub, snd]
		if not ResourceLoader.exists(path):


			path = "res://game/sfx/PlayerSfx/%s.wav" % snd
		if ResourceLoader.exists(path):
			_voice_streams.append(load(path))

func _preview_voice() -> void :
	if _voice_streams.is_empty():
		return
	_voice_preview.stream = _voice_streams[randi() % _voice_streams.size()]
	_voice_preview.pitch_scale = cfg.voice_pitch()

	_voice_preview.volume_db = (-11.0 if cfg.voice_pack >= 2 else -3.0)\
	+ Sfx.take_db(_voice_preview.stream)
	_voice_preview.play()



var _voice_soon: SceneTreeTimer = null

func _preview_voice_soon() -> void :
	if _voice_soon != null and _voice_soon.time_left > 0.0:
		_voice_soon.timeout.disconnect(_preview_voice)
	_voice_soon = get_tree().create_timer(0.22)
	_voice_soon.timeout.connect(_preview_voice)

func _refresh() -> void :
	if _preview_kit == PREVIEW_GYM:
		_player.set_character(cfg.gym_look(), cfg.gym_kit())
	else:
		_player.set_character(cfg, TeamKits.normalize(cfg.captain_kit))

func _changed() -> void :

	_refresh()
	_undo_track()
	if not _pick_quiet:
		_poof_part()
	else:
		_poof_prev = _poof_look()
	if _pick_armed and not _pick_quiet:
		_react_to_pick()


	if section_mode and is_ready:
		_set_ready(false)

	if _studio != null and _section == "studio":
		_studio.look_changed(cfg)



	_queue_thumb_refresh()




var _thumb_sigs: = {}
const _FACIAL_KEYS: = ["fh", "fpx", "fpy", "fpz", "frx", "fry", "frz", "fsc", 
	"fsx", "fsy", "fsz"]

func _thumb_sig(kind: String, slot: = "") -> int:
	var d: = cfg.look_dict()
	d.erase("name")
	match kind:
		"hair":
			d.erase("hair")
		"facial":
			for k in _FACIAL_KEYS:
				d.erase(k)
		"acc":


			var a: Dictionary = d.get("acc", {})
			for s in CharacterConfig.acc_slots_of(CharacterConfig.acc_category(slot)):
				a.erase(s)
	return hash(str(d))

func _thumbs_stale(kind: String, slot: = "") -> bool:
	var key: = kind if slot == "" else "%s:%s" % [kind, slot]
	return int(_thumb_sigs.get(key, -1)) != _thumb_sig(kind, slot)

func _queue_thumb_refresh() -> void :
	if _section != "hair" and _section != "accessories" and _section != "uniforms":
		return
	_thumb_refresh_token += 1
	var token: = _thumb_refresh_token
	await get_tree().create_timer(THUMB_DEBOUNCE).timeout

	if not is_instance_valid(self) or token != _thumb_refresh_token:
		return




	if _section == "hair" and _cur_sub() == "facial":
		if _thumbs_stale("facial"):
			_render_facial_thumbs.call_deferred()
	elif _section == "hair":
		if _thumbs_stale("hair"):
			_render_hair_thumbs.call_deferred()
	elif _section == "accessories":
		if _thumbs_stale("acc", _acc_page_slot()):
			_render_acc_thumbs.call_deferred(_acc_page_slot(), true)
	elif _section == "uniforms":
		_render_opt_thumbs.call_deferred()

func _outfit_name() -> String:
	if _short_names:
		return "showing: uniform" if _preview_kit == PREVIEW_CAPTAIN else PREVIEW_NAMES[_preview_kit]
	return PREVIEW_NAMES[_preview_kit]

func preview_is_gym() -> bool:
	return _preview_kit == PREVIEW_GYM

func _set_preview_kit(k: int) -> void :
	_preview_kit = k
	if _outfit_btn != null and is_instance_valid(_outfit_btn):
		_outfit_btn.text = _outfit_name()
	_refresh()





func _rail_size() -> String:
	if not _compact:
		return ""
	if _short:
		return "short"
	return "tall" if get_viewport_rect().size.y >= 700.0 else "mid"




func _build_rail() -> void :
	var col: = UiStyle.rail_panel(self, _rail_w)
	if _rail_size() != "":
		UiStyle.slim_rail(col, _rail_size())
	for entry in SECTIONS:
		var id: String = entry[0]


		if id == "studio" and (section_mode or not LockerStudio.available()):
			continue
		var b: = UiStyle.rail_tile(entry[1], _section_icon(id))
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if _rail_size() != "":
			UiStyle.slim_rail_tile(b, _rail_size())
		b.pressed.connect(_select_section.bind(id))
		col.add_child(b)
		_rail_btns[id] = b
	var title: = Label.new()
	title.name = "Title"
	title.text = "locker"
	title.position = Vector2(_rail_w + (14.0 if _compact else 28.0), 6.0 if _compact else 12.0)
	title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiStyle.text())
	if section_mode and player_tag != "":



		title.text = player_tag
		title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		title.add_theme_font_size_override("font_size", 30 if _compact else 44)
		title.add_theme_color_override("font_color", player_color)
		title.add_theme_color_override("font_outline_color", UiStyle.INK)
		title.add_theme_constant_override("outline_size", 12 if _compact else 16)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

func _section_icon(id: String) -> Texture2D:
	var own: = SECTION_ICON_DIR + id + ".png"
	if ResourceLoader.exists(own):
		return load(own) as Texture2D
	return UiStyle.icon(String(SECTION_ICONS.get(id, "star")), true)

func _build_panel() -> void :
	var panel: = PanelContainer.new()
	panel.name = "Editor"
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0

	panel.offset_left = - _panel_w - _gutter
	panel.offset_right = - _gutter
	panel.offset_top = _gutter if _compact else PANEL_TOP
	panel.offset_bottom = - _bottombar_h - 6.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	var fsb: = UiStyle.field_box()
	fsb.set_content_margin_all(6 if _compact else 10)
	panel.add_theme_stylebox_override("panel", fsb)
	add_child(panel)
	UiStyle.field_doodles(panel)

	var pad: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % side, 10 if _compact else 18)
	panel.add_child(pad)

	var root_v: = VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	pad.add_child(root_v)



	_sub_box = HFlowContainer.new()
	_sub_box.add_theme_constant_override("h_separation", 6)
	_sub_box.add_theme_constant_override("v_separation", 6)
	root_v.add_child(_sub_box)

	_slot_box = HBoxContainer.new()
	_slot_box.add_theme_constant_override("separation", 6)
	_slot_box.visible = false
	root_v.add_child(_slot_box)

	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_v.add_child(scroll)
	UiStyle.style_scroll(scroll.get_v_scroll_bar())

	var inset: = StyleBoxEmpty.new()
	inset.content_margin_left = 8.0
	inset.content_margin_top = 6.0
	inset.content_margin_bottom = 6.0
	scroll.add_theme_stylebox_override("panel", inset)
	scroll.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 9)


	_content.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_content.custom_minimum_size.x = _panel_w - (54.0 if _compact else 92.0)
	scroll.add_child(_content)




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
	if section_mode:
		_build_section_actions(row)
		return
	var leave: = Button.new()
	leave.text = "exit"
	leave.custom_minimum_size = Vector2(140, 0)
	UiStyle.style_button(leave, "exit", 20)
	leave.pressed.connect(_exit_without_saving)
	row.add_child(leave)
	var done: = Button.new()
	done.text = "save and exit"
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(done, "primary", 22)
	done.pressed.connect(_save_and_exit)
	row.add_child(done)




func _build_preview_toolbar() -> void :

	var bar: Container = HFlowContainer.new() if section_mode else HBoxContainer.new()
	var sep: = 6 if _compact else 10
	bar.add_theme_constant_override("separation", sep)
	bar.add_theme_constant_override("h_separation", sep)
	bar.add_theme_constant_override("v_separation", 6)



	bar.name = "BottomBar"
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left = _rail_w + (12.0 if _compact else 24.0)
	bar.offset_top = - _bottombar_h + (4.0 if _compact else 8.0)
	bar.offset_bottom = - _gutter if _compact else -12.0
	if section_mode:

		bar.anchor_right = 1.0
		bar.offset_right = - _panel_w - _gutter - 10.0
		bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
		(bar as HFlowContainer).alignment = FlowContainer.ALIGNMENT_BEGIN
	add_child(bar)

	var chips: BoxContainer = VBoxContainer.new() if section_mode else HBoxContainer.new()
	chips.name = "ViewerChips"
	chips.add_theme_constant_override("separation", 6 if _compact else 10)
	chips.anchor_left = 1.0
	chips.anchor_right = 1.0
	var right: = - _panel_w - _gutter - (12.0 if _compact else 24.0)
	chips.offset_left = right - 200.0
	chips.offset_right = right
	chips.offset_top = 10.0 if _compact else 20.0
	if _short and section_mode:
		chips.offset_top = 6.0
		chips.offset_left = right - 120.0
	chips.offset_bottom = chips.offset_top + 44.0
	chips.alignment = BoxContainer.ALIGNMENT_END
	chips.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(chips)
	var viewer: Container = chips
	_outfit_btn = _bar_btn(viewer, _outfit_name(), "secondary")
	_outfit_btn.pressed.connect( func():
		var k: = (_preview_kit + 1) % PREVIEW_NAMES.size()
		if _section == "uniforms":
			_select_sub("gym" if k == PREVIEW_GYM else "uniform")
		else:
			_set_preview_kit(k))
	_spin_btn = _bar_btn(viewer, "spin: off", "secondary")
	for chip in [_outfit_btn, _spin_btn]:
		UiStyle.paint_viewer_btn(chip, "singleplayer" if chip == _outfit_btn else "return", 
			11 if _short else (13 if _compact else 16))
		if _short:


			(chip as Button).custom_minimum_size.y = 26.0
			(chip as Button).add_theme_constant_override("icon_max_width", 14)
			for st in ["normal", "hover", "pressed", "focus", "disabled"]:
				var csb: StyleBox = (chip as Button).get_theme_stylebox(st)
				if csb != null:
					csb.content_margin_left = 8.0
					csb.content_margin_right = 10.0
	_spin_btn.pressed.connect( func():
		_spin = not _spin
		_spin_btn.text = "spin: on" if _spin else "spin: off")

	_studio_export = _bar_btn(bar, "export image", "primary")
	_studio_export.pressed.connect(_studio_export_image)
	var folder: = _bar_btn(bar, "open folder", "secondary")
	folder.pressed.connect( func():
		var dir: = LockerStudio.export_dir()
		DirAccess.make_dir_recursive_absolute(dir)
		OS.shell_open(dir))
	var wipe: = _bar_btn(bar, "clear canvas", "secondary")
	wipe.pressed.connect( func(): _studio.confirm_clear())

	_studio_where = Label.new()
	UiStyle.style_label(_studio_where, "small", UiStyle.muted())
	_studio_where.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_child(_studio_where)
	_studio_btns = [_studio_export, folder, wipe, _studio_where]
	for b in _studio_btns:
		(b as Control).visible = false




	_undo_btn = _bar_btn(bar, "undo", "secondary")
	_undo_btn.pressed.connect(undo)
	_undo_btn.disabled = true

	var surprise: = _bar_btn(bar, "randomize", "secondary")
	surprise.pressed.connect( func():
		cfg = CharacterConfig.random(null, true, _who())
		_quietly(_sync_controls))
	var reset: = _bar_btn(bar, "reset", "secondary")
	reset.pressed.connect( func():
		cfg = CharacterConfig.new()
		cfg.hair = 0
		_quietly(_sync_controls))


	_turntable_btns = [_outfit_btn, _spin_btn, surprise, reset, _undo_btn]

	_bar_glyph(_undo_btn, UiStyle.icon("return", true))
	_bar_glyph(surprise, UiStyle.icon_board("dice"))
	_bar_glyph(reset, UiStyle.icon("trashcan", true))
	if (GameConfig.dev_tools or OS.has_feature("editor")) and not section_mode:
		var export_draft: = _bar_btn(bar, "export draft", "secondary")
		export_draft.tooltip_text = "Open the exporter with this unsaved look"
		export_draft.pressed.connect(_export_draft_to_blender)
		_bar_glyph(export_draft, UiStyle.icon("export", true))






	if not GameConfig.onboarding_active and not LaunchGate.economy_off():
		var shop: = _bar_btn(bar, "shop", "secondary")
		shop.pressed.connect(open_shop if section_mode else _save_and_shop)
		_bar_glyph(shop, UiStyle.icon("shoppingCart", true))


func _bar_glyph(b: Button, tex: Texture2D) -> void :
	if b == null or tex == null:
		return
	b.icon = tex
	b.expand_icon = false
	b.add_theme_constant_override("icon_max_width", 16 if _compact else 20)
	b.add_theme_constant_override("h_separation", 6 if _compact else 8)
	b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var c: = UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY
	for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, c)
	b.add_theme_color_override("icon_disabled_color", Color(c, 0.35))




const UNDO_MAX: = 60
const UNDO_MERGE: = 0.6
var _undo: Array = []
var _undo_now: = {}
var _undo_at: = 0.0
var _undo_quiet: = false
var _undoing: = false
var _undo_btn: Button = null

func _undo_track() -> void :
	if _undoing:
		return
	var now: = cfg.to_dict()
	if _undo_now.is_empty():
		_undo_now = now
		return
	if now == _undo_now:
		return
	var t: = Time.get_ticks_msec() / 1000.0
	var merge: = _pick_quiet and _undo_quiet and t - _undo_at < UNDO_MERGE
	if not merge:
		_undo.append(_undo_now)
		if _undo.size() > UNDO_MAX:
			_undo.pop_front()
	_undo_at = t
	_undo_quiet = _pick_quiet
	_undo_now = now
	_paint_undo()

func undo() -> void :
	if _undo.is_empty():
		return
	var back: Dictionary = _undo.pop_back()
	_undoing = true
	cfg = CharacterConfig.from_dict(back)
	_undo_now = back
	_undo_quiet = false
	_quietly(_sync_controls)
	_undoing = false
	UiStyle.sfx("back")
	_paint_undo()

func _paint_undo() -> void :
	if _undo_btn != null and is_instance_valid(_undo_btn):
		_undo_btn.disabled = _undo.is_empty()


func _bar_btn(bar: Container, label: String, kind: String) -> Button:
	var b: = Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(0, 30 if _compact else 40)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_button(b, kind, 12 if _compact else 15)
	if _compact:


		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			var sb: = b.get_theme_stylebox(st)
			if sb != null:
				sb.content_margin_left = 10.0
				sb.content_margin_right = 12.0
	bar.add_child(b)
	return b





func _build_studio() -> void :
	_studio = LockerStudio.new()
	_studio.name = "Studio"
	_studio.host = self
	_studio.anchor_right = 1.0
	_studio.anchor_bottom = 1.0
	_studio.offset_top = _topbar_h + 6.0
	_studio.offset_bottom = - _bottombar_h - 6.0
	_studio.offset_right = - _panel_w - 6.0
	if not section_mode:
		_studio.offset_left = _rail_w + 12.0
		_studio.offset_right = - _panel_w - 28.0
	_studio.visible = false
	add_child(_studio)



	_studio.selection_changed.connect( func():
		if _section != "studio":
			return
		if _cur_sub() == "layers":
			_rebuild_content()
		elif not _studio.selection.is_empty():
			_studio_goto("edit")
		elif _cur_sub() == "edit":
			_rebuild_content())
	_studio.exporting_changed.connect( func(on: bool):
		_studio_export.disabled = on
		_studio_export.text = "exporting..." if on else "export image")

func _set_studio(on: bool) -> void :
	if _studio == null:
		return
	$Preview.visible = not on


	world.render_target_update_mode = SubViewport.UPDATE_DISABLED if on\
	else SubViewport.UPDATE_ALWAYS
	for b in _turntable_btns:
		(b as Control).visible = not on
	for b in _studio_btns:
		(b as Control).visible = on
	_studio_where.text = "saves to %s" % LockerStudio.folder_shown()
	if on:
		_dragging = false
		_studio.set_active(true, cfg)
	else:
		_studio.set_active(false, null)

func _studio_goto(sub: String) -> void :
	if _section != "studio":
		return
	_subsel["studio"] = sub
	_paint_rail()
	_rebuild_content()

func _studio_export_image() -> void :
	var path: = await _studio.export_image()
	if not is_instance_valid(self):
		return
	if path == "":
		UiStyle.flash_pill("could not save the image", UiStyle.RED, "warning")
		return
	UiStyle.sfx("celebrate")
	UiStyle.flash_pill("saved to %s" % LockerStudio.folder_shown(), UiStyle.SUCCESS, "checkmark")


func _studio_folder_changed() -> void :
	if _studio_where != null:
		_studio_where.text = "saves to %s" % LockerStudio.folder_shown()




func _dev_shot() -> void :
	var args: = LaunchGate.dev_args()
	var at: = args.find("--locker-shot")
	if at < 0 or at + 1 >= args.size():
		return
	var section: = String(args[at + 1])
	get_tree().create_timer(12.0).timeout.connect( func(): get_tree().quit())
	await get_tree().create_timer(0.8).timeout
	var ear_at: = args.find("--locker-ear")
	if ear_at >= 0 and ear_at + 1 < args.size():
		cfg.set_ear_index(int(args[ear_at + 1]))
	if "--locker-bald" in args:
		cfg.hair = 0

	var eye_at: = args.find("--locker-eye")
	if eye_at >= 0 and eye_at + 1 < args.size():
		cfg.eye_shape = int(args[eye_at + 1])
	var ec_at: = args.find("--locker-eye-color")
	if ec_at >= 0 and ec_at + 1 < args.size():
		cfg.eye_color = Color.html(String(args[ec_at + 1]))
	var lc_at: = args.find("--locker-lash-color")
	if lc_at >= 0 and lc_at + 1 < args.size():
		cfg.lash_color = Color.html(String(args[lc_at + 1]))
	var blush_at: = args.find("--locker-blush")
	if blush_at >= 0 and blush_at + 1 < args.size():
		cfg.blush = true
		cfg.blush_shape = clampi(int(args[blush_at + 1]), 0, CharacterConfig.blush_shapes().size() - 1)


	var sub_at: = args.find("--locker-sub")
	if sub_at >= 0 and sub_at + 1 < args.size():
		_subsel[section] = String(args[sub_at + 1])

	var fh_at: = args.find("--locker-facial")
	if fh_at >= 0 and fh_at + 1 < args.size():
		cfg.facial_hair = clampi(int(args[fh_at + 1]), 0, CharacterConfig.facial_hair_meshes().size() - 1)
	var num_at: = args.find("--locker-number")
	if num_at >= 0 and num_at + 1 < args.size():
		cfg.captain_kit = TeamKits.normalize(cfg.captain_kit)
		cfg.captain_kit[3] = Color.html(String(args[num_at + 1]))


	if "--locker-split" in args:
		cfg.uniform_gear.shorts_len = 2
		cfg.uniform_gear.wear_kneepads = true
		cfg.uniform_gear.kneepad_style = 1
		cfg.uniform_gear.kneepad_style_l = 1
		cfg.gym_gear.shorts_len = 3
		cfg.gym_gear.wear_kneepads = false
		cfg.gym_gear.shoe_color = Color(0.85, 0.16, 0.18)

	if "--locker-hoodie" in args:
		cfg.gym_shirt = CharacterConfig.HOODIE_SHIRT
		cfg.hoodie_custom = true
		cfg.hoodie_color = Color(0.85, 0.16, 0.18)
		_subsel["uniforms"] = "gym"
		_preview_kit = PREVIEW_GYM

	var skin_at: = args.find("--locker-skin")
	if skin_at >= 0 and skin_at + 1 < args.size():
		cfg.skin_custom = true
		cfg.skin_col = Color.html(String(args[skin_at + 1]))



	var acc_at: = args.find("--locker-acc")
	while acc_at >= 0 and acc_at + 2 < args.size():
		var acc_slot: = String(args[acc_at + 1])
		cfg.set_acc_id(acc_slot, String(args[acc_at + 2]))
		cfg.set_acc(acc_slot, "fl", "--locker-flip" in args)
		var acc_cat: = CharacterConfig.acc_category(acc_slot)
		_subsel["accessories"] = acc_cat
		_acc_pick[acc_cat] = maxi(0, CharacterConfig.acc_slots_of(acc_cat).find(acc_slot))
		acc_at = args.find("--locker-acc", acc_at + 3)
	_changed()
	_select_section(section)
	await get_tree().create_timer(1.6).timeout


	if "--locker-pick" in args:
		var tile: = _find_skin_tile(_content)
		if tile != null:

			var at_pt: = get_viewport().get_final_transform() * tile.get_global_rect().get_center()
			var move: = InputEventMouseMotion.new()
			move.position = at_pt
			Input.parse_input_event(move)
			await get_tree().process_frame
			for down in [true, false]:
				var ev: = InputEventMouseButton.new()
				ev.button_index = MOUSE_BUTTON_LEFT
				ev.pressed = down
				ev.position = at_pt
				ev.global_position = at_pt
				Input.parse_input_event(ev)
				await get_tree().process_frame
			await get_tree().create_timer(0.5).timeout


			var paste_at: = args.find("--locker-paste")
			if paste_at >= 0 and paste_at + 1 < args.size() and tile is ColorPickerButton:
				var paste: = _find_text_btn((tile as ColorPickerButton).get_picker(), "paste")
				print("paste button: ", paste != null)
				if paste != null:
					var keep: = DisplayServer.clipboard_get()
					DisplayServer.clipboard_set(String(args[paste_at + 1]))

					var pop_at: = Vector2((tile as ColorPickerButton).get_popup().position)
					var pp: = get_viewport().get_final_transform() * (pop_at + paste.get_global_rect().get_center())
					for down in [true, false]:
						var ev2: = InputEventMouseButton.new()
						ev2.button_index = MOUSE_BUTTON_LEFT
						ev2.pressed = down
						ev2.position = pp
						ev2.global_position = pp
						Input.parse_input_event(ev2)
						await get_tree().process_frame
					DisplayServer.clipboard_set(keep)
					await get_tree().create_timer(0.4).timeout
					print("skin after paste: ", cfg.skin_col.to_html(false), " custom=", cfg.skin_custom)

	var scroll_at: = args.find("--locker-scroll")
	if scroll_at >= 0 and scroll_at + 1 < args.size():
		(_content.get_parent() as ScrollContainer).scroll_vertical = int(args[scroll_at + 1])
		await get_tree().create_timer(0.2).timeout
	var img: = get_viewport().get_texture().get_image()

	var shot_name: = section if sub_at < 0 or sub_at + 1 >= args.size()\
	else "%s_%s" % [section, String(args[sub_at + 1])]
	img.save_png(ProjectSettings.globalize_path("res://game/dev/shots/locker_%s.png" % shot_name))
	get_tree().quit()

func _find_skin_tile(n: Node) -> Control:
	if n is Control and (n as Control).tooltip_text == "custom skin colour":
		return n
	for c in n.get_children():
		var hit: = _find_skin_tile(c)
		if hit != null:
			return hit
	return null

func _find_text_btn(n: Node, text_in: String) -> Button:
	if n is Button and (n as Button).text == text_in:
		return n
	for c in n.get_children(true):
		var hit: = _find_text_btn(c, text_in)
		if hit != null:
			return hit
	return null

func _select_section(id: String) -> void :
	if id == "studio" and _studio == null:
		id = "face"
	_section = id
	_pick_armed = id != "studio"
	_set_studio(id == "studio")
	if id == "uniforms":
		_set_preview_kit(_sub_kit(_cur_sub()))


	_rebuild_subs()
	_paint_rail()
	_rebuild_content()



func _rebuild_subs() -> void :
	for c in _sub_box.get_children():
		_sub_box.remove_child(c)
		c.queue_free()
	_sub_btns.clear()
	_sub_box.visible = SUBS.has(_section)
	if not _sub_box.visible:
		return
	for entry in SUBS[_section]:
		var id: String = entry[0]
		var b: = Button.new()
		b.text = entry[1]
		b.custom_minimum_size = Vector2(0, 36)
		b.pressed.connect(_select_sub.bind(id))
		_sub_box.add_child(b)
		_sub_btns[id] = b

func _select_sub(id: String) -> void :
	_subsel[_section] = id
	_pick_armed = _section != "studio"
	if _section == "uniforms":
		_set_preview_kit(_sub_kit(id))
	_paint_rail()
	_rebuild_content()

func _cur_sub() -> String:
	return String(_subsel.get(_section, ""))


func _acc_page_slot() -> String:
	var cat: = String(_subsel.get("accessories", "head"))
	return CharacterConfig.acc_slot_name(cat, int(_acc_pick.get(cat, 0)))

func _select_acc_slot(n: int) -> void :
	_acc_pick[String(_subsel.get("accessories", "head"))] = n
	_rebuild_content()



func _rebuild_slot_row() -> void :
	if _slot_box == null:
		return
	for c in _slot_box.get_children():
		_slot_box.remove_child(c)
		c.queue_free()
	_slot_btns.clear()
	_slot_box.visible = _section == "accessories"
	if not _slot_box.visible:
		return
	var cat: = _cur_sub()
	var cur: = _acc_page_slot()
	for n in CharacterConfig.ACC_PER_CATEGORY:
		var slot: = CharacterConfig.acc_slot_name(cat, n)
		var b: = Button.new()
		b.text = str(n + 1)
		b.custom_minimum_size = Vector2(64, 36)
		UiStyle.paint_field_tab(b, slot == cur, 16)
		b.add_theme_constant_override("icon_max_width", 26)
		b.set_meta("slot", slot)
		b.pressed.connect(_select_acc_slot.bind(n))
		_slot_box.add_child(b)
		_slot_btns.append(b)
		_slot_icon(b)



func _slot_icon(b: Button) -> void :
	var slot: = String(b.get_meta("slot", ""))
	var id: = cfg.acc_id(slot)
	var item: = AccessoryCatalog.by_id(id)
	if item == null:
		return
	var key: = "%s:%s" % [slot, id]
	if _acc_thumb_cache.has(key):
		b.icon = _acc_thumb_cache[key]
		return
	if slot == _acc_page_slot():
		return
	var tex: = await CharacterPortrait.tile(cfg.acc_alone(slot, id), item.portrait_preset())
	if tex == null or not is_instance_valid(self):
		return
	_acc_thumb_cache[key] = tex
	_slot_tab_icon(slot, id, tex)


func _slot_tab_icon(slot: String, id: String, tex: Texture2D) -> void :
	if cfg.acc_id(slot) != id:
		return
	for b in _slot_btns:
		if is_instance_valid(b) and String((b as Button).get_meta("slot", "")) == slot:
			(b as Button).icon = tex

func _paint_rail() -> void :
	for id in _rail_btns:
		var tb: Button = _rail_btns[id]
		UiStyle.paint_rail_tile(tb, id == _section)
		if _rail_size() != "":


			UiStyle.repaint_slim_tile(tb, _rail_size())
	var sub: = _cur_sub()


	var tight: = _sub_btns.size() > 5 or _compact
	for id in _sub_btns:
		var b: Button = _sub_btns[id]
		UiStyle.paint_field_tab(b, id == sub, 14 if tight else 16)
		if tight:
			for st in ["normal", "hover", "pressed", "focus", "disabled"]:
				var sb: = b.get_theme_stylebox(st) as StyleBoxFlat
				if sb != null:
					sb.content_margin_left = 9.0
					sb.content_margin_right = 9.0

func _rebuild_content() -> void :
	if section_mode:
		_close_picker()
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()
	_rebuild_slot_row()
	if _section == "face":
		match _cur_sub():
			"look": _build_face_look()
			"eyes": _build_face_eyes()
			"brows": _build_face_brows()
			"nose": _build_face_nose()
			"mouth": _build_face_mouth()
	elif _section == "accessories":
		_build_accessories(_acc_page_slot())
	elif _section == "hair":
		if _cur_sub() == "facial":
			_build_facial_hair()
		else:
			_build_hair()
	elif _section == "body":
		_build_body()
	elif _section == "uniforms":
		_build_uniforms()
	elif _section == "voice":
		_build_voice()
	elif _section == "presets":
		_build_presets()
	elif _section == "studio":
		_studio.build_panel(_cur_sub(), _content)
	if _section in ["face", "accessories"]:
		_tuck_sliders()



	var key: = _section + "/" + _cur_sub()
	if _section == "accessories":
		key = _section + "/" + _acc_page_slot()
	if key != _built_key:
		_built_key = key
		_content.offset_transform_enabled = true
		_content.offset_transform_position = Vector2(26.0, 0.0)
		_content.modulate.a = 0.0
		var t: = _content.create_tween().set_parallel(true)
		t.tween_property(_content, "offset_transform_position", Vector2.ZERO, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(_content, "modulate:a", 1.0, 0.12)






var _adjust_open: = {}
var _built_key: = ""

func _tuck_sliders() -> void :
	var key: = _section + "/" + _cur_sub()
	var kids: = _content.get_children()
	var i: = 0
	while i < kids.size():
		var run: Array = []
		var j: = i


		if j < kids.size() - 1 and _is_header(kids[j], "position") and _is_slider_row(kids[j + 1]):
			run.append(kids[j])
			j += 1
		var sliders: = 0
		while j < kids.size() and _is_slider_row(kids[j]):
			run.append(kids[j])
			sliders += 1
			j += 1
		if sliders >= 2:
			if j < kids.size() and kids[j] is Button and (kids[j] as Button).text == "reset":
				run.append(kids[j])
				j += 1
			_fold(run, key)
			i = j
		else:
			i = maxi(j, i + 1)

func _is_slider_row(n: Node) -> bool:
	if not (n is HBoxContainer):
		return false


	var real: = false
	for s in n.find_children("*", "HSlider", true, false):
		var p: Node = s.get_parent()
		while p != n and not (p is ColorPicker):
			p = p.get_parent()
		if p == n:
			real = true
			break
	if not real:
		return false
	var l: = (n as Node).get_child(0) as Label
	return l == null or not l.text.begins_with(" ")

func _is_header(n: Node, text: String) -> bool:
	for l in n.find_children("*", "Label", true, false):
		return (l as Label).text == text
	return false

func _fold(run: Array, key: String) -> void :
	var open: bool = _adjust_open.get(key, false)
	var b: = Button.new()
	b.name = "Adjust"
	b.toggle_mode = true
	b.button_pressed = open
	b.text = "adjust"
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	UiStyle.style_button(b, "secondary", 15)
	b.icon = UiStyle.icon("gear", true)
	b.add_theme_constant_override("icon_max_width", 18)
	var ic: = UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY
	for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, ic)
	var holder: = VBoxContainer.new()
	holder.add_theme_constant_override("separation", 9)
	holder.visible = open
	var first: Node = run[0]
	_content.add_child(b)
	_content.move_child(b, first.get_index())
	_content.add_child(holder)
	_content.move_child(holder, b.get_index() + 1)
	for n in run:
		n.reparent(holder)
	b.toggled.connect( func(on: bool):
		_adjust_open[key] = on
		holder.visible = on
		UiStyle.press_bounce(b)
		UiStyle.sfx("toggle_on" if on else "toggle_off")
		if on:

			holder.modulate.a = 0.0
			holder.create_tween().tween_property(holder, "modulate:a", 1.0, 0.14))







var poof_count: = 0
var poof_last_spot: = ""
var _poof_prev: = {}



const POOF_SPOTS: = {
	"head": [1.0, 0.45], "chest": [0.66, 0.5], "hips": [0.42, 0.42], 
	"knees": [0.24, 0.36], "shins": [0.12, 0.34], "feet": [0.03, 0.34], 
	"body": [0.5, 0.95], 
}
const POOF_FIELD_SPOT: = {
	"face": "head", "hair": "head", "hc": "head", "hfl": "head", "hcol": "head", 
	"hcols": "head", "hgrad": "head", "hs": "head", "ear": "head", "acc": "head", 
	"skin": "body", "skx": "body", "skc": "body", "h": "body", "w": "body", 
	"num": "chest", "kh": "chest", "gt": "chest", "gsh": "chest", "hdc": "chest", 
	"hdx": "chest", 
	"sl": "hips", "gs": "hips", 
	"kp": "knees", "kpl": "knees", "kps": "knees", "kpw": "knees", "kpsl": "knees", 
	"kpm": "knees", "gkp": "knees", 
	"sk": "shins", "skl": "shins", "gso": "shins", 
	"sh": "feet", 
	"name": "", 
}

const POOF_HEAD_PREFIXES: = ["e", "b", "m", "n", "f"]

func _poof_spot_of(key: String) -> String:
	key = key.trim_prefix("gg/")
	if POOF_FIELD_SPOT.has(key):
		return POOF_FIELD_SPOT[key]
	for p in POOF_HEAD_PREFIXES:
		if key.begins_with(p):
			return "head"
	return ""



func _poof_look() -> Dictionary:
	var d: = cfg.look_dict()
	var gg: Variant = d.get("gg")
	d.erase("gg")
	if gg is Dictionary:
		for k in gg:
			d["gg/" + String(k)] = gg[k]
	return d

func _poof_part() -> void :
	var now: = _poof_look()
	var before: = _poof_prev
	_poof_prev = now
	if _player == null or not _player.is_inside_tree() or before.is_empty():
		return
	var spots: = {}
	for k in now:
		if str(now[k]) != str(before.get(k)):
			var spot: = _poof_spot_of(String(k))
			if spot != "":
				spots[spot] = true
	if spots.is_empty():
		return
	var spot: String = spots.keys()[0] if spots.size() == 1 else "body"
	var rig: ModelRig = _player._model
	var feet: = _player.global_position
	var head: = rig.head_centre_global() if rig != null else feet + Vector3(0.0, 1.45, 0.0)
	var s: Array = POOF_SPOTS[spot]
	LockerPoof.burst(world, feet.lerp(head, float(s[0])), float(s[1]))
	poof_count += 1
	poof_last_spot = spot





func _react_to_pick() -> void :
	var pool: = PICK_ANIMS.duplicate()
	if pool.size() > 1:
		pool.erase(_last_pick_anim)
	pool.shuffle()
	for clip in pool:
		if _player.play_gesture_clip(clip):
			_last_pick_anim = clip
			_pick_armed = false
			pick_anim_count += 1
			return


func _quietly(edit: Callable) -> void :
	_pick_quiet = true
	edit.call()
	_pick_quiet = false

func _sync_controls() -> void :
	_rebuild_content()
	_changed()




func _group_header(text_in: String) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var l: = Label.new()
	l.text = text_in
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", UiStyle.text() if UiStyle.dark else UiStyle.INK)
	row.add_child(l)
	var rule: = Panel.new()
	rule.custom_minimum_size.y = 2
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.add_theme_stylebox_override("panel", UiStyle.flat_box(
		Color(1, 1, 1, 0.12) if UiStyle.dark else Color(UiStyle.INK, 0.14), 1))
	row.add_child(rule)
	var wrap: = MarginContainer.new()
	wrap.add_theme_constant_override("margin_top", 6)
	wrap.add_child(row)
	return wrap

func _labeled(text_in: String, control: Control, label_w: = 92.0) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var l: = Label.new()
	l.text = text_in
	l.custom_minimum_size = Vector2(label_w, 0)
	UiStyle.style_label(l, "body", UiStyle.text())
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 15)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(control)
	return row



func _reset_btn(on_reset: Callable) -> Button:
	var b: = Button.new()
	b.text = "reset"
	b.size_flags_horizontal = Control.SIZE_SHRINK_END
	UiStyle.style_button(b, "tertiary", 13)
	b.pressed.connect( func():
		on_reset.call()
		_sync_controls())
	return b

func _randomize_face_btn(feature: String) -> Button:
	var b: = Button.new()
	b.text = "randomize %s" % feature
	b.size_flags_horizontal = Control.SIZE_SHRINK_END
	UiStyle.style_button(b, "secondary", 13)
	b.pressed.connect(_randomize_face_feature.bind(feature))
	return b

func _randomize_face_feature(feature: String) -> void :



	var rolled: = CharacterConfig.random()
	match feature:
		"look":
			cfg.skin = rolled.skin
			cfg.skin_custom = false
			cfg.blush = rolled.blush
			cfg.blush_color = rolled.blush_color
			cfg.blush_size = rolled.blush_size
			cfg.blush_width = rolled.blush_width
			cfg.blush_height = rolled.blush_height
			cfg.blush_spacing = rolled.blush_spacing
			cfg.blush_opacity = rolled.blush_opacity
		"eyes":
			cfg.eye_shape = rolled.eye_shape
			cfg.eye_color = rolled.eye_color
			cfg.eye_width = rolled.eye_width
			cfg.eye_size_y = rolled.eye_size_y
			cfg.eye_height = rolled.eye_height
			cfg.eye_spacing = rolled.eye_spacing
			cfg.eye_rot = rolled.eye_rot
			cfg.eye_x = rolled.eye_x
		"brows":
			cfg.brow_shape = rolled.brow_shape
			cfg.brow_height = rolled.brow_height
			cfg.brow_spacing = rolled.brow_spacing
			cfg.brow_width = rolled.brow_width
			cfg.brow_size_y = rolled.brow_size_y
			cfg.brow_rot = rolled.brow_rot
			cfg.brow_x = rolled.brow_x
		"nose":
			cfg.nose_shape = rolled.nose_shape
			cfg.nose_width = rolled.nose_width
			cfg.nose_size_y = rolled.nose_size_y
			cfg.nose_height = rolled.nose_height
			cfg.nose_x = rolled.nose_x
			cfg.nose_flip = rolled.nose_flip
		"mouth":
			cfg.mouth_shape = rolled.mouth_shape
			cfg.mouth_width = rolled.mouth_width
			cfg.mouth_size_y = rolled.mouth_size_y
			cfg.mouth_height = rolled.mouth_height
			cfg.mouth_rot = rolled.mouth_rot
			cfg.mouth_x = rolled.mouth_x
	_sync_controls()

func _slider_row(text_in: String, value: float, on_change: Callable) -> HBoxContainer:
	var s: = HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.02
	s.value = value
	s.custom_minimum_size = Vector2(160, 20)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_slider(s)
	s.value_changed.connect( func(v): _quietly(on_change.bind(v)))
	return _labeled(text_in, s)

func _toggle_row(text_in: String, on: bool, on_change: Callable) -> CheckBox:
	var cb: = CheckBox.new()
	cb.text = text_in
	cb.button_pressed = on
	UiStyle.style_check(cb)
	cb.toggled.connect(on_change)
	return cb




func _color_field(color: Color, on_change_in: Callable) -> Control:
	var on_change: = func(c: Color): _quietly(on_change_in.bind(c))
	if not section_mode:
		return UiStyle.color_field(color, on_change)

	var chip: = Button.new()
	chip.custom_minimum_size = Vector2(64, 30) if _compact else Vector2(80, 34)
	chip.set_meta("color", color)
	_paint_chip(chip, color)
	chip.pressed.connect( func(): _open_picker(chip, on_change))
	return chip



func _paint_chip(chip: Button, color: Color) -> void :
	var box: = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(10)
	box.set_border_width_all(3)
	box.border_color = UiStyle.card()
	for st in ["normal", "hover", "pressed", "focus"]:
		chip.add_theme_stylebox_override(st, box)



func _build_pick_panel() -> void :
	var holder: = CenterContainer.new()
	holder.name = "ColourPanel"
	holder.anchor_right = 1.0
	holder.anchor_bottom = 1.0
	holder.offset_top = _topbar_h + 6.0
	holder.offset_bottom = - _bottombar_h - 6.0
	holder.offset_left = _rail_w + 6.0
	holder.offset_right = - _panel_w - _gutter - 6.0
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.visible = false
	add_child(holder)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	holder.add_child(card)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	card.add_child(v)
	_pick = ColorPicker.new()
	_pick.edit_alpha = false
	_pick.sliders_visible = false
	_pick.color_modes_visible = false
	_pick.sampler_visible = false
	_pick.presets_visible = false
	_pick.hex_visible = not _compact
	_pick.picker_shape = ColorPicker.SHAPE_HSV_RECTANGLE
	_pick.custom_minimum_size = Vector2(180, 0) if _compact else Vector2(240, 0)
	_pick.color_changed.connect( func(c: Color):
		if _pick_chip != null and is_instance_valid(_pick_chip):
			_pick_chip.set_meta("color", c)
			if _pick_chip.has_meta("paint"):
				(_pick_chip.get_meta("paint") as Callable).call(c)
			else:
				_paint_chip(_pick_chip, c)
		if _pick_cb.is_valid():
			_pick_cb.call(c))
	v.add_child(_pick)
	var done: = Button.new()
	done.text = "done"
	done.custom_minimum_size = Vector2(0, 30 if _compact else 38)
	UiStyle.style_button(done, "primary", 13 if _compact else 16)
	done.pressed.connect(_close_picker)
	v.add_child(done)
	_pick_panel = holder

func _open_picker(chip: Button, on_change: Callable) -> void :
	if _pick_panel == null:
		return
	_pick_chip = chip
	_pick_cb = Callable()
	_pick.color = chip.get_meta("color", Color.WHITE)
	_pick_cb = on_change
	_pick_panel.visible = true
	( func(): UiStyle.add_hex_paste(_pick)).call_deferred()

func _close_picker() -> void :
	if _pick_panel != null:
		_pick_panel.visible = false
	_pick_chip = null
	_pick_cb = Callable()

func _paint_swatch(b: Button, color: Color, selected: bool) -> void :


	var box: = UiStyle.flat_box(color, 12)
	box.set_border_width_all(4)
	box.border_color = UiStyle.SECONDARY if selected else UiStyle.card()
	for s in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(s, box)
	UiStyle.hover_grow(b)
	_tile_voice(b)

func _swatch_grid(colors: Array, selected: int, on_pick: Callable, 
		swatch: = Vector2(40, 40)) -> HFlowContainer:
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	var btns: Array = []
	for i in colors.size():
		var b: = Button.new()
		b.custom_minimum_size = swatch
		_paint_swatch(b, colors[i], i == selected)
		var idx: = i
		b.pressed.connect( func():
			for j in btns.size():
				_paint_swatch(btns[j], colors[j], j == idx)
			on_pick.call(idx))
		row.add_child(b)
		btns.append(b)
	return row

const PALETTE_ICON: = preload("res://game/images/palette.png")




func _skin_grid() -> HFlowContainer:
	var tones: = CharacterConfig.SKIN_TONES
	var tile: Button
	var held: = [null]
	var splotch: = StyleBoxFlat.new()
	var row: = _swatch_grid(tones, -1 if cfg.skin_custom else cfg.skin, 
		func(i):
			cfg.skin = i
			cfg.skin_custom = false
			_paint_skin_tile(held[0], false)
			_changed())
	var swatch: Vector2 = (row.get_child(0) as Control).custom_minimum_size
	var pick: = func(c: Color):
		cfg.skin_col = c
		cfg.skin_custom = true
		_changed()
	var on_change: = func(c: Color): _quietly(pick.bind(c))
	if section_mode:
		tile = Button.new()
		tile.set_meta("color", cfg.skin_col)
		tile.set_meta("paint", func(c: Color): splotch.bg_color = c)
		tile.pressed.connect( func(): _open_picker(tile, on_change))
	else:
		var p: = UiStyle.color_field(cfg.skin_col, func(c: Color):
			splotch.bg_color = c
			on_change.call(c))

		for c in p.get_children():
			if c is Panel:
				c.visible = false
		tile = p
	held[0] = tile
	tile.custom_minimum_size = Vector2(swatch.x * 2.0 + 8.0, swatch.y)
	tile.tooltip_text = "custom skin colour"

	tile.pressed.connect( func():
		for j in tones.size():
			_paint_swatch(row.get_child(j), tones[j], false)
		_paint_skin_tile(tile, true)
		if not cfg.skin_custom:
			cfg.skin_custom = true
			_changed())
	var face: = Panel.new()
	face.name = "Face"
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(face)
	var box: = HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(box)
	var icon: = TextureRect.new()
	icon.texture = PALETTE_ICON
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2.ONE * swatch.y * 0.8
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)
	var dot: = Panel.new()
	dot.custom_minimum_size = Vector2.ONE * swatch.y * 0.62
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splotch.bg_color = cfg.skin_col
	splotch.set_corner_radius_all(int(swatch.y))
	splotch.set_border_width_all(2)
	splotch.border_color = Color(0, 0, 0, 0.18)
	dot.add_theme_stylebox_override("panel", splotch)
	box.add_child(dot)
	_paint_skin_tile(tile, cfg.skin_custom)
	row.add_child(tile)
	return row

func _paint_skin_tile(tile: Button, selected: bool) -> void :
	if tile == null or not is_instance_valid(tile):
		return

	var box: = UiStyle.flat_box(UiStyle.card(), 12)
	box.set_border_width_all(4)
	box.border_color = UiStyle.SECONDARY if selected else UiStyle.card()
	var face: = tile.get_node_or_null("Face") as Panel
	if face != null:
		face.add_theme_stylebox_override("panel", box)
	for s in ["normal", "hover", "pressed", "focus"]:
		tile.add_theme_stylebox_override(s, StyleBoxEmpty.new())
	UiStyle.hover_grow(tile)
	_tile_voice(tile)

func _choice_grid(labels: Array, selected: int, on_pick: Callable) -> HFlowContainer:
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 6)
	row.add_theme_constant_override("v_separation", 6)
	var btns: Array = []
	for i in labels.size():
		var b: = Button.new()
		b.text = str(labels[i])
		b.custom_minimum_size = Vector2(0, 32)

		UiStyle.style_button(b, "blue" if i == selected else "secondary", 14)
		var idx: = i
		b.pressed.connect( func():
			for j in btns.size():
				UiStyle.style_button(btns[j], 
					"blue" if j == idx else "secondary", 14)
			on_pick.call(idx))
		row.add_child(b)
		btns.append(b)
	return row

func _descendants(n: Node) -> Array:
	var out: Array = [n]
	for c in n.get_children():
		out.append_array(_descendants(c))
	return out

func _nearest(colors: Array, c: Color) -> int:
	var best: = 0
	var bd: = 1000000000.0
	for i in colors.size():
		var col: Color = colors[i]
		var d: = Vector3(col.r - c.r, col.g - c.g, col.b - c.b).length_squared()
		if d < bd:
			bd = d
			best = i
	return best



func _thumb_choice_grid(feature: String, selected: int, on_pick: Callable, 
		allow_none: = false) -> HFlowContainer:
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	var entries: Array = []
	var repaint: = func(sel: int):
		for e in entries:
			_paint_thumb_btn(e[0], int(e[1]) == sel)
	if allow_none:
		var nb: = Button.new()
		nb.text = "none"
		nb.custom_minimum_size = Vector2(74, 62)
		nb.add_theme_font_size_override("font_size", 14)
		row.add_child(nb)
		entries.append([nb, -1])
		nb.pressed.connect( func():
			repaint.call(-1)
			on_pick.call(-1))
	for i in FaceParts.count(feature):
		var b: = Button.new()
		b.custom_minimum_size = Vector2(74, 62)
		b.expand_icon = true
		b.icon = FaceParts.thumb(feature, i)
		row.add_child(b)
		entries.append([b, i])
		var idx: = i
		b.pressed.connect( func():
			repaint.call(idx)
			on_pick.call(idx))
	repaint.call(selected)
	return row



func _tile_box(selected: bool) -> StyleBoxFlat:
	var box: = UiStyle.flat_box(UiStyle.card(), 14)
	if selected:
		box.set_border_width_all(4)
		box.border_color = UiStyle.SECONDARY
	box.set_content_margin_all(6)
	return box

func _paint_thumb_btn(b: Button, selected: bool) -> void :
	var box: = _tile_box(selected)
	for s in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(s, box)
	UiStyle.hover_grow(b)
	_tile_voice(b)


func _tile_voice(b: Button) -> void :
	if b.has_meta("tile_voice"):
		return
	b.set_meta("tile_voice", true)
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	b.pressed.connect(UiStyle.sfx.bind("toggle_on"))
	UiStyle.hover_sound(b)



func _blush_thumb_grid(selected: int, on_pick: Callable) -> HFlowContainer:
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	var btns: Array = []
	for i in CharacterConfig.blush_shapes().size():
		var b: = Button.new()
		b.custom_minimum_size = Vector2(74, 62)
		b.expand_icon = true
		b.set_meta("label", CharacterConfig.blush_shape_name(i))
		var tex: = _blush_thumb_tex(CharacterConfig.blush_shape_key(i))
		if tex != null:
			b.icon = tex

			for s in ["normal", "hover", "pressed", "focus", "disabled"]:
				b.add_theme_color_override("icon_%s_color" % s, cfg.blush_color)
		else:
			b.text = CharacterConfig.blush_shape_name(i)
		var idx: = i
		b.pressed.connect( func():
			for j in btns.size():
				_paint_thumb_btn(btns[j], j == idx)
			on_pick.call(idx))
		row.add_child(b)
		btns.append(b)
	for j in btns.size():
		_paint_thumb_btn(btns[j], j == selected)
	return row



static var _blush_thumb_cache: = {}
static func _blush_thumb_tex(key: String) -> Texture2D:
	if _blush_thumb_cache.has(key):
		return _blush_thumb_cache[key]
	var t: Texture2D = null


	var path: = "res://game/character/faces/blush/%s.png" % key
	if ResourceLoader.exists(path):
		var base: = load(path) as Texture2D
		if base != null:
			var img: = base.get_image()
			img.convert(Image.FORMAT_RGBA8)
			var u: = img.get_used_rect()
			if u.size.x > 0 and u.size.y > 0:
				img = img.get_region(u)
			t = ImageTexture.create_from_image(img)
	if t == null and key == "circle":
		t = _circle_thumb_tex()
	_blush_thumb_cache[key] = t
	return t

static func _circle_thumb_tex() -> Texture2D:


	var n: = 96
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rw: = n * 0.24
	var rh: = n * 0.17
	for cx in [n * 0.32, n * 0.68]:
		for y in n:
			for x in n:
				var d: = Vector2((x - cx) / rw, (y - n * 0.5) / rh).length()
				var a: = pow(1.0 - clampf(d, 0.0, 1.0), 1.4)
				if a > 0.0:
					var cur: = img.get_pixel(x, y)
					img.set_pixel(x, y, Color(1, 1, 1, maxf(cur.a, a)))
	return ImageTexture.create_from_image(img)



func _build_face_look() -> void :
	_content.add_child(_group_header("skin"))
	_content.add_child(_skin_grid())
	_content.add_child(_group_header("blush"))
	var brow: = HBoxContainer.new()
	brow.add_theme_constant_override("separation", 12)
	brow.add_child(_toggle_row("blush", cfg.blush, 
		func(on): cfg.blush = on;_changed()))
	brow.add_child(_color_field(cfg.blush_color, 
		func(c): cfg.blush_color = c;_changed()))
	_content.add_child(brow)


	_content.add_child(_blush_thumb_grid(cfg.blush_shape, 
		func(i): cfg.blush_shape = i;_changed()))
	_content.add_child(_slider_row("scale x", cfg.blush_width, 
		func(v): cfg.blush_width = v;_changed()))
	_content.add_child(_slider_row("scale y", cfg.blush_size, 
		func(v): cfg.blush_size = v;_changed()))
	_content.add_child(_slider_row("vertical", cfg.blush_height, 
		func(v): cfg.blush_height = v;_changed()))
	_content.add_child(_slider_row("spacing", cfg.blush_spacing, 
		func(v): cfg.blush_spacing = v;_changed()))
	_content.add_child(_slider_row("opacity", cfg.blush_opacity, 
		func(v): cfg.blush_opacity = v;_changed()))
	_content.add_child(_reset_btn( func():
		cfg.blush_size = 0.5
		cfg.blush_width = 0.5
		cfg.blush_height = 0.5
		cfg.blush_spacing = 0.5
		cfg.blush_opacity = 0.5))
	_content.add_child(_randomize_face_btn("look"))

func _build_face_eyes() -> void :


	var lash_row: = _labeled("lash color", _color_field(cfg.lash_color, 
		func(c): cfg.lash_color = c;_changed()))
	lash_row.visible = FaceParts.layer_texture("eyes", cfg.eye_shape, "lash") != null
	_content.add_child(_group_header("style"))
	_content.add_child(_thumb_choice_grid("eyes", cfg.eye_shape, 
		func(i):
			cfg.eye_shape = i
			lash_row.visible = FaceParts.layer_texture("eyes", i, "lash") != null
			_changed()))
	_content.add_child(_group_header("position"))
	_content.add_child(_slider_row("scale x", cfg.eye_width, 
		func(v): cfg.eye_width = v;_changed()))
	_content.add_child(_slider_row("scale y", cfg.eye_size_y, 
		func(v): cfg.eye_size_y = v;_changed()))
	_content.add_child(_slider_row("vertical", cfg.eye_height, 
		func(v): cfg.eye_height = v;_changed()))
	_content.add_child(_slider_row("horizontal", cfg.eye_x, 
		func(v): cfg.eye_x = v;_changed()))
	_content.add_child(_slider_row("spacing", cfg.eye_spacing, 
		func(v): cfg.eye_spacing = v;_changed()))
	_content.add_child(_slider_row("tilt", cfg.eye_rot, 
		func(v): cfg.eye_rot = v;_changed()))
	_content.add_child(_reset_btn( func():
		cfg.eye_width = 0.5
		cfg.eye_size_y = 0.5
		cfg.eye_height = 0.5
		cfg.eye_x = 0.5
		cfg.eye_spacing = 0.5
		cfg.eye_rot = 0.5))
	if FaceParts.has_tint("eyes"):

		_content.add_child(_group_header("color"))
		_content.add_child(_labeled("eye color", _color_field(cfg.eye_color, 
			func(c): cfg.eye_color = c;_changed())))
		_content.add_child(lash_row)
	_content.add_child(_randomize_face_btn("eyes"))

func _build_face_brows() -> void :
	_content.add_child(_group_header("style"))
	_content.add_child(_thumb_choice_grid("brows", cfg.brow_shape, 
		func(i): cfg.brow_shape = i;_changed(), true))
	_content.add_child(_group_header("position"))
	_content.add_child(_slider_row("scale x", cfg.brow_width, 
		func(v): cfg.brow_width = v;_changed()))
	_content.add_child(_slider_row("scale y", cfg.brow_size_y, 
		func(v): cfg.brow_size_y = v;_changed()))
	_content.add_child(_slider_row("vertical", cfg.brow_height, 
		func(v): cfg.brow_height = v;_changed()))
	_content.add_child(_slider_row("horizontal", cfg.brow_x, 
		func(v): cfg.brow_x = v;_changed()))
	_content.add_child(_slider_row("spacing", cfg.brow_spacing, 
		func(v): cfg.brow_spacing = v;_changed()))
	_content.add_child(_slider_row("tilt", cfg.brow_rot, 
		func(v): cfg.brow_rot = v;_changed()))
	_content.add_child(_reset_btn( func():
		cfg.brow_height = 0.5
		cfg.brow_spacing = 0.5
		cfg.brow_width = 0.5
		cfg.brow_size_y = 0.5
		cfg.brow_x = 0.5
		cfg.brow_rot = 0.5))
	_content.add_child(_group_header("color"))
	_content.add_child(_labeled("brow color", _color_field(cfg.brow_color, 
		func(c): cfg.brow_color = c;_changed())))
	_content.add_child(_randomize_face_btn("brows"))

func _build_face_nose() -> void :
	_content.add_child(_group_header("style"))
	_content.add_child(_thumb_choice_grid("nose", cfg.nose_shape, 
		func(i): cfg.nose_shape = i;_changed(), true))
	_content.add_child(_group_header("position"))
	_content.add_child(_slider_row("scale x", cfg.nose_width, 
		func(v): cfg.nose_width = v;_changed()))
	_content.add_child(_slider_row("scale y", cfg.nose_size_y, 
		func(v): cfg.nose_size_y = v;_changed()))
	_content.add_child(_slider_row("vertical", cfg.nose_height, 
		func(v): cfg.nose_height = v;_changed()))
	_content.add_child(_slider_row("horizontal", cfg.nose_x, 
		func(v): cfg.nose_x = v;_changed()))
	_content.add_child(_toggle_row("flip", cfg.nose_flip, 
		func(v): cfg.nose_flip = v;_changed()))
	_content.add_child(_reset_btn( func():
		cfg.nose_width = 0.5
		cfg.nose_size_y = 0.5
		cfg.nose_height = 0.5
		cfg.nose_x = 0.5
		cfg.nose_flip = false))
	_content.add_child(_randomize_face_btn("nose"))

func _build_face_mouth() -> void :
	_content.add_child(_group_header("style"))
	_content.add_child(_thumb_choice_grid("mouth", cfg.mouth_shape, 
		func(i): cfg.mouth_shape = i;_changed()))
	_content.add_child(_group_header("position"))
	_content.add_child(_slider_row("scale x", cfg.mouth_width, 
		func(v): cfg.mouth_width = v;_changed()))
	_content.add_child(_slider_row("scale y", cfg.mouth_size_y, 
		func(v): cfg.mouth_size_y = v;_changed()))
	_content.add_child(_slider_row("vertical", cfg.mouth_height, 
		func(v): cfg.mouth_height = v;_changed()))
	_content.add_child(_slider_row("horizontal", cfg.mouth_x, 
		func(v): cfg.mouth_x = v;_changed()))
	_content.add_child(_slider_row("tilt", cfg.mouth_rot, 
		func(v): cfg.mouth_rot = v;_changed()))
	_content.add_child(_reset_btn( func():
		cfg.mouth_width = 0.5
		cfg.mouth_size_y = 0.5
		cfg.mouth_height = 0.5
		cfg.mouth_x = 0.5
		cfg.mouth_rot = 0.5))
	_content.add_child(_randomize_face_btn("mouth"))

func _build_hair() -> void :
	_hair_buttons.clear()


	_content.add_child(_group_header("style"))
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for i in CharacterConfig.hair_meshes().size():
		var b: = Button.new()
		b.custom_minimum_size = HAIR_THUMB
		b.expand_icon = true
		if _hair_thumb_cache.has(i):
			b.icon = _hair_thumb_cache[i]
		else:
			_tile_placeholder(b, CharacterConfig.hair_names()[i])
		var idx: = i
		b.pressed.connect( func():
			var slots_before: = _hair_slot_count()
			cfg.hair = idx
			_mark_hair_selected()
			_changed()



			if _hair_slot_count() != slots_before:
				_rebuild_hair_colors.call_deferred())
		grid.add_child(b)
		_hair_buttons.append(b)
	_content.add_child(grid)

	_content.add_child(_toggle_row("flip", cfg.hair_flip, 
		func(v):
			cfg.hair_flip = v
			HairWarm.warm_all(v)
			_changed()))
	_hair_colors = VBoxContainer.new()
	_hair_colors.add_theme_constant_override("separation", 9)
	_content.add_child(_hair_colors)
	_fill_hair_colors()
	_mark_hair_selected()


	if _thumbs_stale("hair") or _hair_thumb_cache.size() < CharacterConfig.hair_meshes().size():
		_render_hair_thumbs.call_deferred()






var _hair_colors: VBoxContainer

func _hair_slot_count() -> int:
	return CharacterConfig.hair_slot_defaults(cfg.hair).size()

func _fill_hair_colors() -> void :



	var defaults: = CharacterConfig.hair_slot_defaults(cfg.hair)
	if defaults.is_empty():


		_hair_colors.add_child(_group_header("color"))
		_build_hair_slot(0, cfg.hair_color())
	else:
		_hair_colors.add_child(_group_header("color" if defaults.size() == 1 else "colors"))
		for si in defaults.size():
			_build_hair_slot(si, defaults[si])

func _rebuild_hair_colors() -> void :
	if not is_instance_valid(_hair_colors) or _section != "hair" or _cur_sub() == "facial":
		return
	if section_mode:
		_close_picker()
	for c in _hair_colors.get_children():
		_hair_colors.remove_child(c)
		c.queue_free()
	_fill_hair_colors()


func _tile_placeholder(b: Button, label: String) -> void :
	b.text = label
	b.clip_text = true
	b.add_theme_font_size_override("font_size", 11)
	b.add_theme_color_override("font_color", UiStyle.field_ink())

func _set_tile_icon(b: Button, tex: Texture2D) -> void :
	b.icon = tex
	b.text = ""

func _build_hair_slot(slot: int, fallback: Color) -> void :
	var label: = "color %d" % (slot + 1)
	var into: Container = _hair_colors if is_instance_valid(_hair_colors) else _content
	into.add_child(_labeled(label, _color_field(cfg.hair_color_at(slot, fallback), 
		func(c): cfg.set_hair_color_at(slot, c);_changed())))
	into.add_child(_toggle_row("gradient", cfg.hair_gradient_on(slot), 
		func(on):
			cfg.set_hair_gradient_on(slot, on)
			_changed()
			_rebuild_hair_colors.call_deferred()))
	if cfg.hair_gradient_on(slot):
		var top: Color = cfg.hair_color_at(slot, fallback)
		into.add_child(_labeled("  bottom", 
			_color_field(cfg.hair_gradient_bottom(slot, top.darkened(0.4)), 
				func(c): cfg.set_hair_gradient_bottom(slot, c);_changed())))

		var fade: Vector2 = cfg.hair_gradient_fade(slot)
		var mid: = (fade.x + fade.y) * 0.5
		var band: = maxf(fade.y - fade.x, 0.02)
		into.add_child(_slider_row("  position", mid, 
			func(v): _set_hair_fade(slot, v, band)))
		into.add_child(_slider_row("  softness", band, 
			func(v): _set_hair_fade(slot, (cfg.hair_gradient_fade(slot).x
				+ cfg.hair_gradient_fade(slot).y) * 0.5, v)))




func _build_facial_hair() -> void :
	_facial_buttons.clear()
	_content.add_child(_group_header("facial hair"))
	var styles: = CharacterConfig.facial_hair_meshes()
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for i in styles.size():
		var b: = Button.new()
		b.custom_minimum_size = HAIR_THUMB
		b.expand_icon = true
		if _facial_thumb_cache.has(i):
			b.icon = _facial_thumb_cache[i]
		else:
			_tile_placeholder(b, CharacterConfig.facial_hair_names()[i])
		var idx: = i
		b.pressed.connect( func():

			if cfg.facial_hair != idx:
				cfg.reset_facial_transform()
			cfg.facial_hair = idx
			_mark_facial_selected()
			_changed()
			_rebuild_content.call_deferred())
		grid.add_child(b)
		_facial_buttons.append(b)
	_content.add_child(grid)
	if styles.size() <= 1:
		var none: = Label.new()
		none.text = "no facial hair styles yet"
		UiStyle.style_label(none, "small", UiStyle.field_ink())
		_content.add_child(none)
	if cfg.facial_hair > 0:
		var defaults: = CharacterConfig.facial_hair_slot_defaults(cfg.facial_hair)
		var slots: = maxi(defaults.size(), 1)
		_content.add_child(_group_header("color" if slots == 1 else "colors"))
		for si in slots:
			var slot: = si
			_content.add_child(_labeled("color %d" % (si + 1), 
				_color_field(cfg.facial_hair_color_at(si), 
					func(c): cfg.set_facial_hair_color_at(slot, c);_changed())))
		var match_hair: = Button.new()
		match_hair.text = "match hair"
		match_hair.size_flags_horizontal = Control.SIZE_SHRINK_END
		match_hair.disabled = not cfg.facial_hair_custom()
		UiStyle.style_button(match_hair, "tertiary", 13)
		match_hair.pressed.connect( func():
			cfg.match_facial_hair_to_hair()
			_sync_controls())
		_content.add_child(match_hair)

		_content.add_child(_group_header("position"))
		_facial_slider("horizontal", "fh_px")
		_facial_slider("vertical", "fh_py")
		_facial_slider("depth", "fh_pz")
		_content.add_child(_group_header("rotation"))
		_facial_slider("tilt", "fh_rx")
		_facial_slider("turn", "fh_ry")
		_facial_slider("roll", "fh_rz")
		_content.add_child(_group_header("size"))
		_facial_slider("scale", "fh_sc")
		_facial_slider("scale x", "fh_sx")
		_facial_slider("scale y", "fh_sy")
		_facial_slider("scale z", "fh_sz")
		_content.add_child(_reset_btn( func(): cfg.reset_facial_transform()))
	_mark_facial_selected()
	if _thumbs_stale("facial") or _facial_thumb_cache.size() < styles.size():
		_render_facial_thumbs.call_deferred()

func _facial_slider(label: String, field: String) -> void :
	_content.add_child(_slider_row(label, float(cfg.get(field)), 
		func(v): cfg.set(field, v);_changed()))

func _mark_facial_selected() -> void :
	for i in _facial_buttons.size():
		var b: Button = _facial_buttons[i]
		_paint_thumb_btn(b, i == cfg.facial_hair)


func _set_hair_fade(slot: int, mid: float, band: float) -> void :
	var half: = maxf(band, 0.02) * 0.5
	cfg.set_hair_gradient_fade(slot, mid - half, mid + half)
	_changed()


func _set_acc_fade(slot: String, i: int, mid: float, band: float) -> void :
	var half: = maxf(band, 0.02) * 0.5
	cfg.set_acc_gradient_fade(slot, i, mid - half, mid + half)
	_changed()

func _mark_hair_selected() -> void :
	for i in _hair_buttons.size():
		var b: Button = _hair_buttons[i]
		_paint_thumb_btn(b, i == cfg.hair)





func _build_accessories(slot: String) -> void :
	var cat: = CharacterConfig.acc_category(slot)
	var items: = AccessoryCatalog.for_category(cat)
	_content.add_child(_group_header("%s item" % cat))
	if items.is_empty():
		var note: = Label.new()
		note.text = "no %s items yet" % cat
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.style_label(note, "body", UiStyle.field_ink())
		_content.add_child(note)
		return
	var cur: = cfg.acc_id(slot)


	_acc_buttons = {}
	var grid: = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.add_child(_acc_thumb_btn(slot, "", "none", cur == ""))
	for it in items:
		grid.add_child(_acc_thumb_btn(slot, it.id, it.name_or_id(), cur == it.id))
	_content.add_child(grid)
	_render_acc_thumbs.call_deferred(slot, _thumbs_stale("acc", slot))
	if cur == "":
		return
	var item: = AccessoryCatalog.by_id(cur)
	if item == null:
		return

	_content.add_child(_toggle_row("flip", cfg.acc_flip(slot), 
		func(v): cfg.set_acc(slot, "fl", v);_changed()))

	var count: = item.color_count()
	if count > 0:
		var header_added: = false
		var shown: = 0
		for i in count:
			if item.is_color_locked(i):
				continue
			if not header_added:
				_content.add_child(_group_header("colors"))
				header_added = true
			shown += 1
			var idx: = i
			_content.add_child(_labeled("color %d" % shown, 
				_color_field(cfg.acc_color(slot, i, item.default_color(i)), 
					func(c): cfg.set_acc_color(slot, idx, c);_changed())))

			_content.add_child(_toggle_row("  gradient", cfg.acc_gradient_on(slot, i), 
				func(on):
					cfg.set_acc_gradient_on(slot, idx, on)
					_changed()
					_rebuild_content.call_deferred()))
			if cfg.acc_gradient_on(slot, i):
				var top: Color = cfg.acc_color(slot, i, item.default_color(i))
				_content.add_child(_labeled("  bottom", 
					_color_field(cfg.acc_gradient_bottom(slot, i, top.darkened(0.4)), 
						func(c): cfg.set_acc_gradient_bottom(slot, idx, c);_changed())))
				var fade: Vector2 = cfg.acc_gradient_fade(slot, i)
				var mid: = (fade.x + fade.y) * 0.5
				var band: = maxf(fade.y - fade.x, 0.02)
				_content.add_child(_slider_row("  position", mid, 
					func(v): _set_acc_fade(slot, idx, v, band)))
				_content.add_child(_slider_row("  softness", band, 
					func(v): _set_acc_fade(slot, idx, 
						(cfg.acc_gradient_fade(slot, idx).x
							+ cfg.acc_gradient_fade(slot, idx).y) * 0.5, v)))

	_content.add_child(_group_header("position"))
	_content.add_child(_slider_row("horizontal", cfg.acc_val(slot, "px"), 
		func(v): cfg.set_acc(slot, "px", v);_changed()))
	_content.add_child(_slider_row("vertical", cfg.acc_val(slot, "py"), 
		func(v): cfg.set_acc(slot, "py", v);_changed()))
	_content.add_child(_slider_row("depth", cfg.acc_val(slot, "pz"), 
		func(v): cfg.set_acc(slot, "pz", v);_changed()))
	_content.add_child(_group_header("rotation"))
	_content.add_child(_slider_row("tilt", cfg.acc_val(slot, "rx"), 
		func(v): cfg.set_acc(slot, "rx", v);_changed()))
	_content.add_child(_slider_row("turn", cfg.acc_val(slot, "ry"), 
		func(v): cfg.set_acc(slot, "ry", v);_changed()))
	_content.add_child(_slider_row("roll", cfg.acc_val(slot, "rz"), 
		func(v): cfg.set_acc(slot, "rz", v);_changed()))
	_content.add_child(_group_header("size"))
	_content.add_child(_slider_row("scale", cfg.acc_val(slot, "sc"), 
		func(v): cfg.set_acc(slot, "sc", v);_changed()))

	_content.add_child(_slider_row("scale x", cfg.acc_val(slot, "sx"), 
		func(v): cfg.set_acc(slot, "sx", v);_changed()))
	_content.add_child(_slider_row("scale y", cfg.acc_val(slot, "sy"), 
		func(v): cfg.set_acc(slot, "sy", v);_changed()))
	_content.add_child(_slider_row("scale z", cfg.acc_val(slot, "sz"), 
		func(v): cfg.set_acc(slot, "sz", v);_changed()))
	_content.add_child(_reset_btn( func(): cfg.reset_acc_transform(slot)))

func _acc_thumb_btn(slot: String, id: String, label: String, 
		selected: bool) -> Button:
	var b: = Button.new()
	b.custom_minimum_size = Vector2(78, 78)
	b.expand_icon = true
	if id == "":
		b.text = "none"
	var key: = "%s:%s" % [slot, id]
	if _acc_thumb_cache.has(key):
		b.icon = _acc_thumb_cache[key]
		b.text = ""
	_paint_thumb_btn(b, selected)


	var item: = AccessoryCatalog.by_id(id)
	var locked: = id != "" and item != null and item.price > 0\
	and not Progression.owns(id, item.price, _who())
	b.pressed.connect( func():
		if locked:
			return
		cfg.set_acc_id(slot, id)
		_sync_controls())
	if locked:
		b.modulate = Color(1.0, 1.0, 1.0, 0.55)
		var tag: = Label.new()
		tag.text = str(item.price)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		tag.add_theme_font_size_override("font_size", 13)
		tag.add_theme_color_override("font_color", Color(0.82, 0.6, 0.04))
		tag.set_anchors_preset(Control.PRESET_FULL_RECT)
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(tag)
	_acc_buttons[id] = b
	return b

func _render_acc_thumbs(slot: String, redo: = false) -> void :



	_thumb_generation += 1
	var gen: = _thumb_generation
	_thumb_sigs["acc:" + slot] = _thumb_sig("acc", slot)
	var base: = cfg.clone()
	var ids: Array = [""]
	for it in AccessoryCatalog.for_category(CharacterConfig.acc_category(slot)):
		ids.append(it.id)
	var jobs: Array = []
	for id in ids:
		var key: = "%s:%s" % [slot, id]
		if _acc_thumb_cache.has(key) and not redo:
			continue


		var shot: = base.acc_alone(slot, id)


		var item: = AccessoryCatalog.by_id(id)
		var preset: = item.portrait_preset() if item != null else "head"
		var item_id: = String(id)
		jobs.append([shot, preset, [], func(tex: Texture2D):
			_acc_thumb_cache[key] = tex
			if _acc_buttons.has(item_id) and is_instance_valid(_acc_buttons[item_id]):
				_set_tile_icon(_acc_buttons[item_id], tex)
			_slot_tab_icon(slot, item_id, tex)])
	await _fill_tiles(jobs, gen)

func _build_body() -> void :
	_content.add_child(_group_header("size"))
	_content.add_child(_slider_row("height", cfg.height, 
		func(v): cfg.height = v;_changed()))
	_content.add_child(_slider_row("build", cfg.weight, 
		func(v): cfg.weight = v;_changed()))
	_content.add_child(_group_header("head shape"))
	_content.add_child(_choice_grid(CharacterConfig.HEAD_SHAPE_NAMES, cfg.head_shape, 
		func(i): cfg.head_shape = i;_changed()))



	if not CharacterConfig.EAR_SHAPES.is_empty():
		_content.add_child(_group_header("ears"))
		var ears: = _choice_grid(CharacterConfig.ear_names(), cfg.ear_index(), 
			func(i): cfg.set_ear_index(i);_changed())
		ears.name = "EarTypes"
		_content.add_child(ears)
	_content.add_child(_group_header("preferred hand"))
	_content.add_child(_choice_grid(["left handed", "right handed"], 
		0 if cfg.left_handed else 1, 
		func(i): cfg.left_handed = i == 0;_changed()))








func _build_uniforms() -> void :
	var gym: = _cur_sub() == "gym"
	if gym:
		_build_gym_top()
	else:
		_build_captain_top()
	_build_gear_groups(gym)

	_render_opt_thumbs.call_deferred()


func _sub_kit(sub: String) -> int:
	return PREVIEW_GYM if sub == "gym" else PREVIEW_CAPTAIN

func _gear(gym: bool) -> CharacterConfig.Gear:
	return cfg.gear_of(gym)




func _build_captain_top() -> void :
	_content.add_child(_group_header("number"))
	var sb: = SpinBox.new()
	sb.min_value = 0
	sb.max_value = 99
	sb.value = cfg.number
	UiStyle.style_spin(sb)
	sb.value_changed.connect( func(v): cfg.number = int(v);_outfit_edit(false))
	_content.add_child(_labeled("number", sb))
	_content.add_child(_group_header("colors"))
	_kit_pickers()


	_number_note = Label.new()
	UiStyle.style_label(_number_note, "small", UiStyle.field_ink())
	_number_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(_number_note)
	_refresh_number_note()


func _build_gym_top() -> void :
	_content.add_child(_group_header("shirt"))
	var shirt_grid: = _option_grid("shirt", true)
	_content.add_child(shirt_grid)
	_content.add_child(_labeled("color", _color_field(cfg.gym_tee, 
		func(c): cfg.gym_tee = c;_outfit_edit(true))))


	var hood_match: = Button.new()
	var hood_row: = _labeled("hoodie", _color_field(cfg.hoodie_tint(cfg.gym_tee), 
		func(c):
			cfg.hoodie_color = c
			cfg.hoodie_custom = true
			hood_match.disabled = false
			_outfit_edit(true)))



	hood_match.text = "match shirt"
	hood_match.size_flags_horizontal = Control.SIZE_SHRINK_END
	hood_match.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hood_match.disabled = not cfg.hoodie_custom
	UiStyle.style_button(hood_match, "secondary", 13)
	hood_match.pressed.connect( func():
		cfg.hoodie_custom = false
		_outfit_edit(true)
		_sync_controls())
	hood_row.add_child(hood_match)
	hood_row.visible = cfg.gym_shirt == CharacterConfig.HOODIE_SHIRT
	_content.add_child(hood_row)
	shirt_grid.set_meta("after_pick", func(i: int):
		hood_row.visible = i == CharacterConfig.HOODIE_SHIRT
		_outfit_edit(true))



func _build_gear_groups(gym: bool) -> void :


	_content.add_child(_group_header("shorts"))
	if gym:
		_content.add_child(_labeled("color", _color_field(cfg.gym_shorts, 
			func(c): cfg.gym_shorts = c;_outfit_edit(true))))
	_content.add_child(_option_grid("shorts", gym))


	_content.add_child(_group_header("socks"))
	var socks_grid: = _option_grid("socks", gym)
	var socks_color: = _labeled("color", _color_field(_gear(gym).socks, 
		func(c): _gear(gym).socks = c;_outfit_edit(gym)))
	var socks_rows: Array = [socks_grid, socks_color]
	_content.add_child(_toggle_row("wear socks", _gear(gym).wear_socks, 
		func(on):
			_gear(gym).wear_socks = on
			for r in socks_rows:
				(r as Control).visible = on
			_outfit_edit(gym)))
	_content.add_child(socks_grid)
	_content.add_child(socks_color)
	for r in socks_rows:
		(r as Control).visible = _gear(gym).wear_socks


	_content.add_child(_group_header("kneepads"))


	var kp_right: = _labeled("right color", _color_field(_gear(gym).kneepad, 
		func(c): _gear(gym).kneepad = c;_outfit_edit(gym)))
	var kp_left: = _labeled("left color", _color_field(_gear(gym).kneepad_l, 
		func(c): _gear(gym).kneepad_l = c;_outfit_edit(gym)))
	var kp_label: Label = null
	for ch in kp_right.find_children("*", "Label", true, false):
		kp_label = ch
		break
	var sync_kp_rows: = func():
		var g: = _gear(gym)
		kp_left.visible = g.wear_kneepads and not g.kneepad_match
		if kp_label != null:
			kp_label.text = "color" if g.kneepad_match else "right color"
	var side_label: = _sub_label("which knees")
	var side_grid: = _option_grid("pad_side", gym)
	var r_label: = _sub_label("right pad")
	var r_grid: = _option_grid("pad_r", gym)
	var l_label: = _sub_label("left pad")
	var l_grid: = _option_grid("pad_l", gym)
	var kp_same: = _toggle_row("same color on both", _gear(gym).kneepad_match, 
		func(on):
			_gear(gym).kneepad_match = on
			sync_kp_rows.call()
			_outfit_edit(gym))
	var pad_rows: Array = [side_label, side_grid, r_label, r_grid, l_label, l_grid, 
		kp_same, kp_right, kp_left]
	var sync_pads: = func():
		for r in pad_rows:
			(r as Control).visible = _gear(gym).wear_kneepads
		sync_kp_rows.call()
	_content.add_child(_toggle_row("wear kneepads", _gear(gym).wear_kneepads, 
		func(on):
			_gear(gym).wear_kneepads = on
			sync_pads.call()
			_outfit_edit(gym)))
	for n in pad_rows:
		_content.add_child(n)
	sync_pads.call()


	_content.add_child(_group_header("shoes"))
	_content.add_child(_labeled("color", _color_field(_gear(gym).shoe_color, 
		func(c): _gear(gym).shoe_color = c;_outfit_edit(gym))))




func _outfit_edit(gym: bool) -> void :
	_preview_kit = PREVIEW_GYM if gym else PREVIEW_CAPTAIN
	if _outfit_btn != null and is_instance_valid(_outfit_btn):
		_outfit_btn.text = _outfit_name()
	_changed()

func _kit_pickers() -> void :
	cfg.captain_kit = TeamKits.normalize(cfg.captain_kit)
	var names: = ["jersey", "shorts", "trim", "number"]
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	for i in names.size():
		var col: = VBoxContainer.new()
		col.add_theme_constant_override("separation", 3)
		var l: = Label.new()
		l.text = names[i]
		UiStyle.style_label(l, "small", UiStyle.field_ink())
		l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		l.add_theme_font_size_override("font_size", 14)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(l)
		var idx: = i
		var p: = _color_field(cfg.captain_kit[i], 
			func(c):
				cfg.captain_kit[idx] = c
				_refresh_number_note()
				_outfit_edit(false))
		col.add_child(p)
		row.add_child(col)
	_content.add_child(row)



func _refresh_number_note() -> void :
	if _number_note == null or not is_instance_valid(_number_note):
		return
	var kit: = TeamKits.normalize(cfg.captain_kit)
	var reads: = TeamKits.number_reads(kit[0], kit[3])

	var bright: = TeamKits.number_ink(kit[0]) == TeamKits.INK_DARK
	_number_note.text = "" if reads else ("your jersey is too bright for this number color, using fallback"\
	if bright else "your jersey is too dark for this number color, using fallback")
	_number_note.visible = not reads

func _build_voice() -> void :
	_content.add_child(_group_header("voice"))



	if CharacterConfig.VOICE_PACK_COUNT > 1:
		var vlabels: Array = []
		for i in CharacterConfig.VOICE_PACK_COUNT:
			vlabels.append("voice %d" % (i + 1))
		_content.add_child(_choice_grid(vlabels, 
			clampi(cfg.voice_pack - 1, 0, CharacterConfig.VOICE_PACK_COUNT - 1), 
			func(i):
				cfg.voice_pack = i + 1
				_load_voice_streams()
				_preview_voice()))


	_content.add_child(_slider_row("pitch", cfg.v_pitch, 
		func(v): cfg.v_pitch = v;_preview_voice_soon()))
	_content.add_child(_slider_row("speed", cfg.v_speed, 
		func(v): cfg.v_speed = v;_preview_voice_soon()))
	var play: = Button.new()
	play.text = "hear it"
	play.custom_minimum_size = Vector2(0, 34)
	UiStyle.style_button(play, "secondary", 15)
	play.pressed.connect(_preview_voice)
	_content.add_child(play)

func _build_presets() -> void :
	_content.add_child(_group_header("save slots"))
	var hint: = Label.new()
	hint.text = "load & save custom characters"
	UiStyle.style_label(hint, "body", UiStyle.field_ink())
	hint.add_theme_font_size_override("font_size", 14)
	_content.add_child(hint)


	var imp: = Button.new()
	imp.text = "import"
	imp.icon = UiStyle.icon("import")
	imp.expand_icon = false
	imp.add_theme_constant_override("icon_max_width", 18)
	imp.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	UiStyle.style_button(imp, "secondary", 14)
	imp.pressed.connect(_open_import)
	_content.add_child(imp)
	_slot_thumb_rects.clear()
	for i in CharacterConfig.SLOT_COUNT:
		_content.add_child(_slot_card(i))
	_render_slot_thumbs.call_deferred()

func _slot_card(i: int) -> PanelContainer:
	var card: = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiStyle.flat_box(UiStyle.card(), 18))
	var pad: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % side, 10)
	card.add_child(pad)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	pad.add_child(row)

	var slot: CharacterConfig = _slots[i] if i < _slots.size() else null


	var thumb: = Panel.new()
	thumb.custom_minimum_size = Vector2(96, 122) if _compact else Vector2(120, 152)
	var tsb: = StyleBoxFlat.new()
	tsb.bg_color = UiStyle.card()
	tsb.set_corner_radius_all(9)
	tsb.set_border_width_all(1)
	tsb.border_color = Color(UiStyle.muted(), 0.4)
	thumb.add_theme_stylebox_override("panel", tsb)
	row.add_child(thumb)
	if slot != null:
		var tr: = TextureRect.new()
		tr.set_anchors_preset(Control.PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _slot_thumb_cache.has(i):
			tr.texture = _slot_thumb_cache[i]
		thumb.add_child(tr)
		_slot_thumb_rects[i] = tr

	var name_col: = VBoxContainer.new()
	name_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_col.add_theme_constant_override("separation", 0)
	row.add_child(name_col)
	var title: = Label.new()
	title.text = "slot %d" % (i + 1)
	UiStyle.style_label(title, "body", UiStyle.text())
	title.add_theme_font_size_override("font_size", 16)
	name_col.add_child(title)
	var sub: = Label.new()
	sub.text = "empty" if slot == null else ""
	UiStyle.style_label(sub, "small", UiStyle.muted())
	name_col.add_child(sub)



	var btns: Container = HFlowContainer.new() if _compact else HBoxContainer.new()
	btns.add_theme_constant_override("separation", 5)
	btns.add_theme_constant_override("h_separation", 5)
	btns.add_theme_constant_override("v_separation", 5)
	btns.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if _compact:
		name_col.add_theme_constant_override("separation", 4)
		name_col.add_child(btns)
	else:
		row.add_child(btns)
	if slot == null:
		var save: = Button.new()
		save.text = "save here"
		UiStyle.style_button(save, "secondary", 14)
		save.pressed.connect(_save_to_slot.bind(i))
		btns.add_child(save)
	else:
		var wear: = Button.new()
		wear.text = "wear"
		UiStyle.style_button(wear, "blue", 14)
		wear.pressed.connect(_wear.bind(slot))
		btns.add_child(wear)
		var over: = Button.new()
		over.text = "save"
		UiStyle.style_button(over, "secondary", 14)
		over.pressed.connect(_save_to_slot.bind(i))
		btns.add_child(over)
		var share: = Button.new()
		share.text = "share"
		UiStyle.style_button(share, "secondary", 14)
		share.pressed.connect(_share_slot.bind(i))
		btns.add_child(share)
		var clear: = Button.new()
		clear.text = "clear"
		UiStyle.style_button(clear, "tertiary", 14)
		clear.pressed.connect( func():
			_slots[i] = null
			_slot_thumb_cache.erase(i)
			ProfileStore.set_slots_for(_who(), _slots)
			_rebuild_content())
		btns.add_child(clear)
	return card

func _save_to_slot(i: int) -> void :
	_slots[i] = cfg.clone()
	_slot_thumb_cache.erase(i)
	ProfileStore.set_slots_for(_who(), _slots)


	var filled: = 0
	for s in _slots:
		if s != null:
			filled += 1
	Achievements.notify_for(_who(), "preset", {"level": filled})
	_rebuild_content()




func _wear(look: CharacterConfig) -> bool:
	cfg = look.clone()
	var dropped: = cfg.drop_unowned(_who())
	_sync_controls()
	if dropped:
		UiStyle.flash_pill("this profile is missing items in this preset", UiStyle.RED, "warning")
	return dropped



var _popup: CanvasLayer = null

func _popup_open() -> bool:
	return _popup != null and is_instance_valid(_popup) and not _popup.is_queued_for_deletion()

func _share_slot(i: int) -> void :
	var slot: CharacterConfig = _slots[i] if i < _slots.size() else null
	if slot == null or _popup_open():
		return
	var who: = _who()
	var shown: = slot.display_name
	if shown == "":
		shown = who.name if who != null else "player"
	_popup = PlayerCard.open(self, slot, shown, _compact)

func _open_import() -> void :
	if _popup_open():
		return
	var d: = LookImport.open(self)
	d.picked.connect(_import_look)
	_popup = d


func _import_look(look: CharacterConfig) -> void :
	look.display_name = cfg.display_name
	look.title = cfg.title.duplicate()
	look.level = cfg.level
	if not _wear(look):
		UiStyle.flash_pill("look imported", UiStyle.SUCCESS, "checkmark")

func _export_draft_to_blender() -> void :


	var window: = Window.new()
	window.set_script(load("res://game/dev/asset_export/avatar_export_window.gd"))
	window.set("temporary_config", cfg.clone())
	window.set("temporary_label", "Locker draft (unsaved)")
	add_child(window)



func _render_hair_thumbs() -> void :




	_thumb_generation += 1
	var gen: = _thumb_generation
	_thumb_sigs["hair"] = _thumb_sig("hair")


	var base: = cfg.clone()
	HairWarm.warm_all(base.hair_flip)
	var jobs: Array = []
	for i in CharacterConfig.hair_meshes().size():
		var shot: = base.clone()
		shot.hair = i
		var idx: = i
		jobs.append([shot, "head", [], func(tex: Texture2D):
			_hair_thumb_cache[idx] = tex
			if idx < _hair_buttons.size() and is_instance_valid(_hair_buttons[idx]):
				_set_tile_icon(_hair_buttons[idx], tex)])
	await _fill_tiles(jobs, gen)






static func tile_jobs(c: CharacterConfig) -> Array:
	var base: = c.clone()
	var out: Array = []
	for i in CharacterConfig.hair_meshes().size():
		var shot: = base.clone()
		shot.hair = i
		out.append([shot, "head", []])
	for i in CharacterConfig.facial_hair_meshes().size():
		var shot: = base.clone()
		shot.facial_hair = i
		out.append([shot, "head", []])


	for slot in CharacterConfig.ACC_CATEGORIES:
		var ids: Array = [""]
		for it in AccessoryCatalog.for_category(slot):
			ids.append(it.id)
		for id in ids:
			var shot: = base.acc_alone(slot, id)
			var item: = AccessoryCatalog.by_id(id)
			out.append([shot, item.portrait_preset() if item != null else "head", []])
	for gym in [false, true]:
		for kind in OPT_THUMBS:
			var spec: Dictionary = OPT_THUMBS[kind]
			if not gym and bool(spec.get("gym_only", false)):
				continue
			for i in (spec["names"] as Array).size():
				var shot: = base.clone()
				var target: = _opt_target(shot, kind, gym)
				target.set(String(spec["field"]), i)
				var force: Dictionary = spec.get("force", {})
				for f in force:
					target.set(f, force[f])
				if gym:
					out.append([shot.gym_look(), String(spec["preset"]), shot.gym_kit()])
				else:
					out.append([shot, String(spec["preset"]), TeamKits.normalize(shot.captain_kit)])
	return out






func _fill_tiles(jobs: Array, gen: int) -> void :
	var keys: Array = []
	var todo: Array = []
	for j in jobs:
		var key: = CharacterPortrait.tile_key(j[0], j[1], j[2])
		var hit: = CharacterPortrait.tile_peek(key)
		if hit != null:
			(j[3] as Callable).call(hit)
			continue
		CharacterPortrait.tile_prefetch(key)
		keys.append(key)
		todo.append(j)
	for k in todo.size():
		var j: Array = todo[k]
		var tex: = await CharacterPortrait.tile(j[0], j[1], j[2], keys[k])
		if not is_instance_valid(self) or gen != _thumb_generation:
			return
		if tex != null:
			(j[3] as Callable).call(tex)








const OPT_THUMBS: = {
	"shirt": {"field": "gym_shirt", "names": CharacterConfig.SHIRT_SHAPE_NAMES, 
		"preset": "torso", "gym_only": true}, 
	"shorts": {"field": "shorts_len", "names": CharacterConfig.SHORTS_SHAPE_NAMES, 
		"preset": "legs", "gear": true}, 
	"socks": {"field": "socks_len", "names": CharacterConfig.SOCKS_SHAPE_NAMES, 
		"preset": "legs", "gear": true, "force": {"wear_socks": true}}, 
	"pad_side": {"field": "kneepad_side", "names": CharacterConfig.KNEEPAD_SIDE_NAMES, 
		"preset": "legs", "gear": true, "force": {"wear_kneepads": true}}, 
	"pad_r": {"field": "kneepad_style", "names": CharacterConfig.KNEEPAD_STYLE_NAMES, 
		"preset": "legs", "gear": true, 
		"force": {"wear_kneepads": true, "kneepad_side": 1}}, 
	"pad_l": {"field": "kneepad_style_l", "names": CharacterConfig.KNEEPAD_STYLE_NAMES, 
		"preset": "legs", "gear": true, 
		"force": {"wear_kneepads": true, "kneepad_side": 2}}, 
}
var _opt_buttons: = {}
var _opt_thumb_cache: = {}


func _sub_label(text_in: String) -> Label:
	var l: = Label.new()
	l.text = text_in
	UiStyle.style_label(l, "body", UiStyle.text() if UiStyle.dark else UiStyle.INK)
	l.add_theme_font_size_override("font_size", 15)
	return l


static func _opt_target(c: CharacterConfig, kind: String, gym: bool) -> Object:
	return c.gear_of(gym) if bool(OPT_THUMBS[kind].get("gear", false)) else c

static func _opt_key(kind: String, gym: bool, i: int) -> String:
	return "%s/%s:%d" % ["gym" if gym else "uniform", kind, i]

func _option_grid(kind: String, gym: bool) -> HFlowContainer:
	var spec: Dictionary = OPT_THUMBS[kind]
	var field: = String(spec["field"])
	var names: Array = spec["names"]
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	var btns: Array = []
	var picked: = int(_opt_target(cfg, kind, gym).get(field))
	for i in names.size():
		var b: = Button.new()
		b.custom_minimum_size = Vector2(92, 112)
		b.text = String(names[i])
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		b.add_theme_font_size_override("font_size", 13)
		for st in ["font_color", "font_hover_color", "font_pressed_color", 
				"font_hover_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(st, UiStyle.INK if not UiStyle.dark else UiStyle.text())
		var key: = _opt_key(kind, gym, i)
		if _opt_thumb_cache.has(key):
			b.icon = _opt_thumb_cache[key]
		var idx: = i
		b.pressed.connect( func():
			_opt_target(cfg, kind, gym).set(field, idx)
			for j in btns.size():
				_paint_thumb_btn(btns[j], j == idx)
			var after: Variant = row.get_meta("after_pick") if row.has_meta("after_pick") else null
			if after is Callable and (after as Callable).is_valid():
				(after as Callable).call(idx)
			else:
				_outfit_edit(gym))
		row.add_child(b)
		btns.append(b)
		_paint_thumb_btn(b, i == picked)
	_opt_buttons[kind] = btns
	return row


func _opt_kinds(gym: bool) -> Array:
	var out: Array = []
	for kind in OPT_THUMBS:
		if gym or not bool(OPT_THUMBS[kind].get("gym_only", false)):
			out.append(kind)
	return out


func _opt_sig(kind: String, gym: bool) -> int:
	var c: = cfg.clone()
	_opt_target(c, kind, gym).set(String(OPT_THUMBS[kind]["field"]), 0)
	var d: = c.look_dict()
	d.erase("name")
	return hash(str(d))

func _render_opt_thumbs() -> void :
	if _section != "uniforms":
		return
	_thumb_generation += 1
	var gen: = _thumb_generation
	var gym: = _cur_sub() == "gym"
	var base: = cfg.clone()
	var jobs: Array = []
	for kind in _opt_kinds(gym):
		var spec: Dictionary = OPT_THUMBS[kind]
		var sig: = _opt_sig(kind, gym)
		var names: Array = spec["names"]
		var have_all: = true
		for i in names.size():
			have_all = have_all and _opt_thumb_cache.has(_opt_key(kind, gym, i))
		var sig_key: = "opt:%s:%s" % ["gym" if gym else "uniform", kind]
		if have_all and int(_thumb_sigs.get(sig_key, -1)) == sig:
			continue
		_thumb_sigs[sig_key] = sig
		for i in names.size():
			var shot: = base.clone()
			var target: = _opt_target(shot, kind, gym)
			target.set(String(spec["field"]), i)
			var force: Dictionary = spec.get("force", {})
			for f in force:
				target.set(f, force[f])
			var k: = String(kind)
			var idx: = i
			var on_tex: = func(tex: Texture2D):
				_opt_thumb_cache[_opt_key(k, gym, idx)] = tex
				var btns: Array = _opt_buttons.get(k, [])
				if idx < btns.size() and is_instance_valid(btns[idx]):
					(btns[idx] as Button).icon = tex
			if gym:
				jobs.append([shot.gym_look(), String(spec["preset"]), shot.gym_kit(), on_tex])
			else:
				jobs.append([shot, String(spec["preset"]), TeamKits.normalize(shot.captain_kit), on_tex])
	await _fill_tiles(jobs, gen)



func _render_facial_thumbs() -> void :
	_thumb_generation += 1
	var gen: = _thumb_generation
	_thumb_sigs["facial"] = _thumb_sig("facial")
	var base: = cfg.clone()
	var jobs: Array = []
	for i in CharacterConfig.facial_hair_meshes().size():
		var shot: = base.clone()
		shot.facial_hair = i
		var idx: = i
		jobs.append([shot, "head", [], func(tex: Texture2D):
			_facial_thumb_cache[idx] = tex
			if idx < _facial_buttons.size() and is_instance_valid(_facial_buttons[idx]):
				_set_tile_icon(_facial_buttons[idx], tex)])
	await _fill_tiles(jobs, gen)



func _render_slot_thumbs() -> void :


	for i in _slots.size():
		if _slots[i] == null or _slot_thumb_cache.has(i):
			continue
		var tex: = await CharacterPortrait.render(_slots[i], "full", 
			Vector2i(240, 300), self)
		if not is_instance_valid(self):
			return
		if tex == null:
			continue
		_slot_thumb_cache[i] = tex
		if _slot_thumb_rects.has(i) and is_instance_valid(_slot_thumb_rects[i]):
			(_slot_thumb_rects[i] as TextureRect).texture = tex

func _visual_bounds(n: Node) -> AABB:
	var out: = AABB()
	var first: = true
	for m in _meshes_of(n):
		var mi: = m as MeshInstance3D
		if not mi.visible or mi.mesh == null:
			continue
		var world_aabb: = mi.global_transform * mi.mesh.get_aabb()
		if first:
			out = world_aabb
			first = false
		else:
			out = out.merge(world_aabb)
	return out

func _meshes_of(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes_of(c))
	return out







func _build_section_actions(row: HBoxContainer) -> void :
	var undo: = Button.new()
	undo.text = "undo changes"
	undo.custom_minimum_size = Vector2(0 if _compact else 140, 0)
	UiStyle.style_button(undo, "secondary", 13 if _compact else 18)
	_bar_glyph(undo, UiStyle.icon("return", true))
	undo.pressed.connect( func():
		cfg = _saved_look()
		_sync_controls())
	row.add_child(undo)
	_ready_btn = Button.new()
	_ready_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ready_btn.pressed.connect( func(): _set_ready( not is_ready))
	row.add_child(_ready_btn)
	_paint_ready()

func _saved_look() -> CharacterConfig:
	var who: = _who()
	if who == ProfileStore.active() and GameConfig.character != null:
		return GameConfig.character.clone()
	return CharacterConfig.from_dict(who.character) if not who.character.is_empty()\
	else CharacterConfig.new()

func set_ready(on: bool) -> void :
	_set_ready(on)

func _set_ready(on: bool) -> void :
	if on == is_ready:
		return
	is_ready = on
	if on:
		_close_picker()
		_save_section_look()
	_paint_ready()
	ready_changed.emit(on)

func _paint_ready() -> void :
	if _ready_btn != null:
		paint_ready_button(_ready_btn, is_ready, 16 if _compact else 22)
	_paint_ready_tint()




static func paint_ready_button(btn: Button, on: bool, font_size: int) -> void :
	btn.text = "ready!" if on else "ready"
	UiStyle.style_button(btn, "blue", font_size)
	if on:
		for st in ["normal", "hover", "pressed", "focus"]:
			var sb: = btn.get_theme_stylebox(st)
			if sb is StyleBoxFlat:
				var g: = (sb as StyleBoxFlat).duplicate() as StyleBoxFlat
				g.bg_color = UiStyle.SUCCESS.lightened(0.08) if st == "hover"\
				else (UiStyle.SUCCESS.darkened(0.06) if st == "pressed" else UiStyle.SUCCESS)
				if st != "focus":
					g.border_color = UiStyle.SUCCESS.darkened(0.22)
				btn.add_theme_stylebox_override(st, g)
		for c in ["font_color", "font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
			btn.add_theme_color_override(c, Color.WHITE)
		btn.add_theme_color_override("font_outline_color", UiStyle.SUCCESS.darkened(0.45))
		btn.add_theme_constant_override("outline_size", 4)
	else:
		btn.remove_theme_constant_override("outline_size")



var _ready_tint: CanvasLayer = null

func _paint_ready_tint() -> void :
	if not section_mode:
		return
	if _ready_tint == null:
		_ready_tint = CanvasLayer.new()
		_ready_tint.name = "ReadyTint"
		_ready_tint.layer = 50
		var wash: = ColorRect.new()
		wash.color = Color(UiStyle.SUCCESS, 0.2)
		wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ready_tint.add_child(wash)
		var frame: = Panel.new()
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var edge: = StyleBoxFlat.new()
		edge.draw_center = false
		edge.border_color = UiStyle.SUCCESS
		edge.set_border_width_all(10 if _compact else 14)
		frame.add_theme_stylebox_override("panel", edge)
		_ready_tint.add_child(frame)
		add_child(_ready_tint)
	_ready_tint.visible = is_ready
	if is_ready:
		for c in _ready_tint.get_children():
			(c as CanvasItem).modulate.a = 0.0
			create_tween().tween_property(c, "modulate:a", 1.0, 0.18)




func _save_section_look() -> void :
	var who: = _who()
	if who == ProfileStore.active():
		_save_look()
		return
	var before: = _saved_look()
	var changed: = before.look_dict() != cfg.look_dict()
	ProfileStore.capture_character_for(who, cfg.clone())
	Achievements.notify_for(who, "avatar", {"changed": changed, 
		"tallest": cfg.height >= 0.999, "shortest": cfg.height <= 0.001, 
		"number": cfg.number})







const SHOP_SCENE: = "res://game/shop/shop.tscn"
var _shop: Control = null

func shop_open() -> bool:
	return _shop != null and is_instance_valid(_shop) and _shop.visible

func open_shop() -> void :
	if not section_mode or shop_open():
		return
	_close_picker()
	if _shop == null or not is_instance_valid(_shop):
		_shop = (load(SHOP_SCENE) as PackedScene).instantiate()
		_shop.section_mode = true
		_shop.profile = profile
		_shop.player_color = player_color
		_shop.player_tag = player_tag
		_shop.locker = self
		get_parent().add_child(_shop)
		get_parent().move_child(_shop, get_index() + 1)
	else:
		_shop.visible = true
		_shop.reshow()
	visible = false
	world.render_target_update_mode = SubViewport.UPDATE_DISABLED

func close_shop() -> void :
	if not shop_open():
		return
	_shop.visible = false
	_shop.hidden_now()
	visible = true
	world.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	_rebuild_content()
	_refresh()






const PAD_TURN: = 3.2

func turn_preview(amount: float) -> void :
	if shop_open():
		_shop.turn_preview(amount)
		return
	if _section == "studio" or _player == null:
		return
	_player.visual.rotation.y += amount * PAD_TURN

func cycle_section(dir: int) -> void :
	if shop_open():
		_shop.cycle_tab(dir)
		return
	var ids: Array = _rail_btns.keys()
	if ids.is_empty():
		return
	var i: = ids.find(_section)
	_select_section(ids[posmod(i + dir, ids.size())])
	UiStyle.sfx("hover")

func pad_back() -> void :
	if shop_open():
		_shop.pad_back()
		return
	if _popup_open():


		if _close_popups(_popup):
			return
		if _popup.has_method("editing_name") and _popup.call("editing_name"):
			_popup.call("end_name_edit")
			return
		_popup.call("close")
		return
	if _pick_panel != null and _pick_panel.visible:
		_close_picker()
		return

	if section_mode and is_ready:
		_set_ready(false)
		UiStyle.sfx("back")
		return
	if _close_popups(get_viewport()):
		return
	if section_mode:
		return



	if UiStyle.dialog_active():
		UiStyle.active_dialog.queue_free()
		UiStyle.sfx("close")
		return
	_exit_without_saving()


func _close_popups(n: Node) -> bool:
	var closed: = false
	for k in n.get_children(true):
		if k is Popup and (k as Popup).visible:
			(k as Popup).hide()
			closed = true
		elif _close_popups(k):
			closed = true
	return closed

func wire_pointer(cur: PlayerCursor) -> void :
	cur.turn.connect(turn_preview)
	cur.tab_prev.connect(cycle_section.bind(-1))
	cur.tab_next.connect(cycle_section.bind(1))
	cur.back_pressed.connect(pad_back)




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



const SOLO_POINTER: = preload("res://game/ui/solo_pointer.gd")
var _solo: Node = null
var _pointer: PlayerCursor = null

func _build_solo_pointer() -> void :
	_solo = SOLO_POINTER.new()
	add_child(_solo)
	_pointer = _solo.cursor
	wire_pointer(_pointer)

func mouse_took_over() -> void :
	if _solo != null:
		_solo.mouse_took_over()





func _exit_without_saving() -> void :

	var live: CharacterConfig = _onboard_roll if _onboard_roll != null else GameConfig.character
	var go: = _leave_onboarding if _onboard_roll != null else _leave
	var dirty: = live == null or live.to_dict() != cfg.to_dict()
	if not dirty:
		go.call()
		return
	UiStyle.confirm(self, "exit without saving?", 
		"your changes to this look will be lost", 
		go, "exit", "cancel", "exit", 0.0)


func _leave_onboarding() -> void :
	cfg = _onboard_roll
	_save_and_exit()

func _leave() -> void :
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene(_leave_destination()))



func leave_for_match() -> void :
	_save_and_exit()

func _save_and_exit() -> void :
	await _save_look()
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene(_leave_destination()))


func _save_and_shop() -> void :
	await _save_look()
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene("res://game/shop/shop.tscn"))

func _save_look() -> void :

	var live: = GameConfig.character


	var changed: = live == null or live.look_dict() != cfg.look_dict()
	cfg.save_local()
	GameConfig.character = cfg
	ProfileStore.capture_character()


	Achievements.notify("avatar", {"changed": changed, "tallest": cfg.height >= 0.999, 
		"shortest": cfg.height <= 0.001, "number": cfg.number})


	await CharacterPortrait.generate_and_save(cfg, self)





func _leave_destination() -> String:
	if GameConfig.onboarding_active:
		GameConfig.onboarding_active = false




		ProfileStore.seeded_fresh = false




		MusicManager.set_muffled(false)
		return "res://game/ui/boot/boot_intro.tscn"
	return "res://game/ui/menu.tscn"
