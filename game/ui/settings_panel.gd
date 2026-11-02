class_name SettingsPanel
extends VBoxContainer




















signal retheme_requested(dark: bool)


signal economy_poked

signal profile_settings_requested

const TITLES: = preload("res://game/titles/title_catalog.gd")
const PAD_NAV: = preload("res://game/ui/style/pad_nav.gd")
const WINDOW_NAMES: = ["windowed", "borderless fullscreen", "fullscreen"]
const DEBUG_COINS: = 1000

const RES_STEPS: = [Vector2i(1280, 720), Vector2i(1600, 900), 
	Vector2i(1920, 1080), Vector2i(2560, 1440)]
const MSAA_NAMES: = ["off", "2x", "4x", "8x"]


const CAMERA_NAMES: = ["action", "dynamic", "broadcast", "static"]
const SHAKE_PRESET_NAMES: = ["high", "medium", "small"]

const SPLIT_PREF_NAMES: = ["vertical when possible", "shared when possible"]


const AUDIO_DEFAULTS: = {"master": 1.0, "music": 0.2, "ambient": 0.7, 
	"sfx": 1.0, "crowd": 1.0}



const LATENCY_MS: = [0, 60, 120, 250]
const LATENCY_NAMES: = ["off", "60 ms", "120 ms", "250 ms"]



const ViewClear: = preload("res://game/fx/view_clear.gd")
const DEFAULTS: = {
	"crowd_enabled": true, "voice_enabled": true, "quick_chat_voices": true, 


	"window_mode": 0, "window_size": Vector2i(1600, 900), 
	"resolution_3d": 100, "msaa": 0, "vsync": true, "max_fps": 60, "background_fps": 10, 
	"split_pref": 0, "shadows": 2, 
	"reflections": true, "bloom": true, "grass": true, 
	"hair_physics": true, "floor_sunlight": true, "court_dome": true, 
	"camera_occlusion": true, "show_fps": false, 
	"fade_scoreboard": false, "chat_filter": true, "replay_capture": true, 
	"pad_when_unfocused": false, 
	"default_camera": 1, "touch_highlight": true, "reach_marker": true, 
	"show_control_hints": true, "chat_enabled": true, "chat_bubbles": true, 
	"show_own_name": false, "hide_names_in_rally": false, 
	"hide_titles_in_rally": false, "hardware_cursor": false, 
	"mouse_sensitivity": 1.0, "stick_sensitivity": 1.0, "sprint_toggle": false, 
	"sprint_double_tap": true, 
	"invert_cam_x": false, "invert_cam_y": false, 
	"aim_assist": false, "set_assist": false, "camera_shake": true, 
	"camera_fov_fx": true, "camera_shake_preset": 2, "rumble": true, 
	"aim_color_cue": true, 
	"crosshair_shape": "line_cross", "crosshair_custom": false, 
	"crosshair_color": Color(1, 1, 1), "crosshair_outline": Color(0.05, 0.05, 0.08), 
	"crosshair_size": 4.0, "crosshair_ring": true, 
}


const CATEGORY_KEYS: = {
	"audio": ["crowd_enabled", "voice_enabled", "quick_chat_voices"], 
	"video": ["window_mode", "window_size", "resolution_3d", "msaa", "vsync", 
		"max_fps", "background_fps", "split_pref", "shadows", "reflections", 
		"bloom", "grass", "hair_physics", "floor_sunlight", "court_dome", "camera_occlusion", 
		"show_fps"], 
	"general": ["fade_scoreboard", "chat_filter", "replay_capture", "pad_when_unfocused"], 
	"gameplay": ["default_camera", "touch_highlight", "reach_marker", 
		"show_control_hints", "chat_enabled", "chat_bubbles", "show_own_name", 
		"hide_names_in_rally", "hide_titles_in_rally", "hardware_cursor", 
		"mouse_sensitivity", "stick_sensitivity", "invert_cam_x", "invert_cam_y", "sprint_toggle", 
		"sprint_double_tap"], 
	"accessibility": ["aim_assist", "set_assist", "camera_shake", "camera_fov_fx", 
		"camera_shake_preset", "rumble", "aim_color_cue"], 
	"crosshair": ["crosshair_shape", "crosshair_custom", "crosshair_color", 
		"crosshair_outline", "crosshair_size", "crosshair_ring"], 
}







enum Scope{SYSTEM, PROFILE, ALL}
var scope: int = Scope.SYSTEM

static var _open_tab_by_scope: = {Scope.SYSTEM: 0, Scope.PROFILE: 0, Scope.ALL: 0}
var _tabs: TabContainer = null


var on_field: = false

func set_scope(s: int) -> void :




	scope = s
	rebuild()




func _is_dev_build() -> bool:
	if LaunchGate.public_beta():
		return false
	return OS.has_feature("editor")



const QUALITY_NAMES: = ["low", "medium", "high", "custom"]
const QUALITY: = GameConfig.QUALITY
var _quality_sel: UiSelect = null
var _last_select: UiSelect = null


func _quality_now() -> int:
	for i in QUALITY.size():
		var same: = true
		for key in QUALITY[i]:
			if GameConfig.get(key) != QUALITY[i][key]:
				same = false
		if same:
			return i
	return QUALITY.size()

func _sync_quality() -> void :
	if _quality_sel != null and is_instance_valid(_quality_sel):
		_quality_sel.selected = _quality_now()


func _requality() -> void :
	var ringed: = get_viewport().gui_get_focus_owner() != null
	rebuild()
	if ringed and _quality_sel != null:
		_quality_sel.grab_focus()
		PAD_NAV.follow(_quality_sel)


func cycle_tab(step: int) -> void :
	if _tabs == null or _tabs.get_tab_count() == 0:
		return
	var n: = _tabs.get_tab_count()
	_tabs.current_tab = (_tabs.current_tab + step + n) % n

func _ready() -> void :

	process_mode = Node.PROCESS_MODE_ALWAYS
	add_theme_constant_override("separation", 12)
	visibility_changed.connect( func():
		if _unbuilt and is_visible_in_tree():
			_build_now())
	rebuild()





var _unbuilt: = false




func rebuild() -> void :
	if is_inside_tree() and not is_visible_in_tree():
		_unbuilt = true
		return
	_build_now()

func _build_now() -> void :
	_unbuilt = false





	for c in get_children():
		remove_child(c)
		c.queue_free()
	var tabs: = TabContainer.new()
	_tabs = tabs
	tabs.custom_minimum_size = Vector2(620, 380)
	tabs.tab_alignment = TabBar.ALIGNMENT_CENTER
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyle.style_tabs(tabs, on_field)
	if scope == Scope.PROFILE:
		_build_profile_tabs(tabs)
	elif scope == Scope.SYSTEM:
		_build_system_tabs(tabs)
	else:
		_build_system_tabs(tabs)
		_build_profile_tabs(tabs)
	var remembered: int = int(_open_tab_by_scope.get(scope, 0))
	if remembered >= 0 and remembered < tabs.get_tab_count():
		tabs.current_tab = remembered
	tabs.tab_changed.connect( func(i: int): _open_tab_by_scope[scope] = i)
	add_child(tabs)



func _build_system_tabs(tabs: TabContainer) -> void :
	var audio: = _tab(tabs, "audio")
	_subheader(audio, "levels")
	_slider(audio, "master", "master")
	_slider(audio, "music", "music")
	_slider(audio, "ambient", "ambient")
	_slider(audio, "sfx", "sfx")
	_slider(audio, "crowd", "crowd")
	_subheader(audio, "sources")
	_check(audio, "audience noises", "", 
		GameConfig.crowd_enabled, func(on: bool): GameConfig.crowd_enabled = on, "crowd_enabled")
	_check(audio, "player voices", "", 
		GameConfig.voice_enabled, func(on: bool): GameConfig.voice_enabled = on, "voice_enabled")
	_check(audio, "quick chat voices", "the voice lines on the quick chat calls", 
		GameConfig.quick_chat_voices, func(on: bool): GameConfig.quick_chat_voices = on, 
		"quick_chat_voices")
	_reset_btn(audio, "audio")

	var video: = _tab(tabs, "video")
	_subheader(video, "display")


	_select(video, "window", WINDOW_NAMES, int(GameConfig.window_mode), func(i: int):
		GameConfig.window_mode = i as GameConfig.WindowMode
		GameConfig.apply_display.call_deferred(), int(DEFAULTS.window_mode))
	_select(video, "resolution", _res_names(), _res_index(), func(i: int):
		GameConfig.window_size = _res_list()[i]
		GameConfig.apply_display.call_deferred(), _res_list().find(DEFAULTS.window_size))
	_check(video, "vsync", "", GameConfig.vsync, func(on: bool):
		GameConfig.vsync = on
		GameConfig.apply_display(), "vsync")
	var fps_vals: = [0, 25, 30, 60, 120, 144]
	var fps_names: = ["unlimited", "25", "30", "60", "120", "144"]
	_select(video, "frame rate cap", fps_names, 
		maxi(fps_vals.find(GameConfig.max_fps), 0), func(i: int):
			GameConfig.max_fps = int(fps_vals[i])
			GameConfig.apply_display(), fps_vals.find(DEFAULTS.max_fps))


	var bg_vals: = [0, 10, 30]
	_select(video, "frame rate when inactive (client only)", ["off", "10", "30"], 
		maxi(bg_vals.find(GameConfig.background_fps), 0), func(i: int):
			GameConfig.background_fps = int(bg_vals[i])
			GameConfig.apply_frame_cap(), bg_vals.find(DEFAULTS.background_fps))



	_resolution_slider(video)



	_select(video, "splitscreen", SPLIT_PREF_NAMES, 
		clampi(int(GameConfig.split_pref), 0, SPLIT_PREF_NAMES.size() - 1), 
		func(i: int): GameConfig.split_pref = i as GameConfig.SplitPref, int(DEFAULTS.split_pref))
	_subheader(video, "effects")

	_select(video, "quality", QUALITY_NAMES, _quality_now(), func(i: int):
		if i < QUALITY.size():
			GameConfig.apply_quality(i)
			_requality.call_deferred(), QUALITY.size() - 1)
	_quality_sel = _last_select


	_select(video, "shadows", ["low (drop shadows)", "medium", "high"], 
		clampi(GameConfig.shadows, 0, 2), func(i: int):
			GameConfig.shadows = i
			_sync_quality(), int(DEFAULTS.shadows))
	_check(video, "floor reflections", "", 
		GameConfig.reflections, func(on: bool):
			GameConfig.reflections = on
			_sync_quality(), "reflections")
	_check(video, "glow", "", 
		GameConfig.bloom, func(on: bool):
			GameConfig.bloom = on
			_sync_quality(), "bloom")
	_check(video, "grass", "", 
		GameConfig.grass, func(on: bool):
			GameConfig.grass = on
			_sync_quality(), "grass")
	_check(video, "hair physics", MenuCopy.sub("hair_physics"), 
		GameConfig.hair_physics, func(on: bool):
			GameConfig.hair_physics = on
			_sync_quality(), "hair_physics")


	if ViewClear.ON:
		_check(video, "camera occlusion shader", "", 
			GameConfig.camera_occlusion, func(on: bool):
				GameConfig.camera_occlusion = on, "camera_occlusion")
	_check(video, "show fps counter", "", 
		GameConfig.show_fps, func(on: bool): GameConfig.show_fps = on, "show_fps")
	_reset_btn(video, "video")

	var gen: = _tab(tabs, "general")
	_subheader(gen, "theme")





	if scope == Scope.ALL:
		var locked: = CheckBox.new()
		locked.text = "dark theme"
		locked.button_pressed = GameConfig.dark_theme
		locked.disabled = true
		UiStyle.style_check(locked)
		_check_row(gen, locked, null)
	else:
		_check(gen, "dark theme", "",
			GameConfig.dark_theme, func(on: bool):
				GameConfig.dark_theme = on
				UiStyle.dark = on
				GameConfig.save_settings()
				retheme_requested.emit(on))
	_subheader(gen, "language")
	_select(gen, "language", ["english", "українська"],
		1 if GameConfig.language == "uk" else 0, func(i: int):
			GameConfig.language = "uk" if i == 1 else "en"
			GameConfig.apply_language()
			GameConfig.save_settings(), 0)
	_subheader(gen, "controller")
	_check(gen, "controller inputs while game is unfocused", MenuCopy.sub("pad_when_unfocused"), 
		GameConfig.pad_when_unfocused, 
		func(on: bool): GameConfig.pad_when_unfocused = on, "pad_when_unfocused")
	_subheader(gen, "scoreboard")
	_check(gen, "fade scoreboard during rallies", MenuCopy.sub("fade_scoreboard"), 
		GameConfig.fade_scoreboard, 
		func(on: bool): GameConfig.fade_scoreboard = on, "fade_scoreboard")
	_subheader(gen, "chat")


	_check(gen, "profanity filter", MenuCopy.sub("chat_filter"), 
		GameConfig.chat_filter, func(on: bool): GameConfig.chat_filter = on, "chat_filter")

	if not LaunchGate.is_demo():
		_subheader(gen, "recording")
		_check(gen, "save match replays", "", 
			GameConfig.replay_capture, func(on: bool): GameConfig.replay_capture = on, 
			"replay_capture")
	_reset_btn(gen, "general")



	if scope == Scope.SYSTEM:
		var prof: = _tab(tabs, "profile")
		var go: = Button.new()
		go.text = "go to profile settings"
		UiStyle.style_button(go, "blue", 17)
		go.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		go.custom_minimum_size = Vector2(260, 46)
		go.pressed.connect( func(): profile_settings_requested.emit())
		prof.add_child(go)


	if _is_dev_build():
		_build_debug_tab(tabs)



func _build_profile_tabs(tabs: TabContainer) -> void :
	var game: = _tab(tabs, "gameplay")
	_subheader(game, "view")


	_select(game, "camera", CAMERA_NAMES, 
		clampi(GameConfig.default_camera, 0, CAMERA_NAMES.size() - 1), 
		func(i: int): GameConfig.default_camera = i, int(DEFAULTS.default_camera))

	_subheader(game, "hud")
	_check(game, "last-touch outline", MenuCopy.sub("last_touch"), 
		GameConfig.touch_highlight, func(on: bool): GameConfig.touch_highlight = on, "touch_highlight")
	_check(game, "reach marker", MenuCopy.sub("reach_marker"), 
		GameConfig.reach_marker, func(on: bool): GameConfig.reach_marker = on, "reach_marker")
	_check(game, "control hints", MenuCopy.sub("control_hints"), 
		GameConfig.show_control_hints, 
		func(on: bool): GameConfig.show_control_hints = on, "show_control_hints")
	_check(game, "in-game chat", MenuCopy.sub("in_game_chat"), 
		GameConfig.chat_enabled, func(on: bool): GameConfig.chat_enabled = on, "chat_enabled")
	_check(game, "chat bubbles", MenuCopy.sub("chat_bubbles"), 
		GameConfig.chat_bubbles, func(on: bool): GameConfig.chat_bubbles = on, "chat_bubbles")
	_check(game, "show your own name", MenuCopy.sub("own_name"), 
		GameConfig.show_own_name, func(on: bool): GameConfig.show_own_name = on, "show_own_name")
	_check(game, "hide names during rallies", MenuCopy.sub("rally_names"), 
		GameConfig.hide_names_in_rally, func(on: bool): GameConfig.hide_names_in_rally = on, "hide_names_in_rally")

	if TITLES.enabled():
		_check(game, "hide titles during rallies", MenuCopy.sub("rally_titles"), 
			GameConfig.hide_titles_in_rally, func(on: bool): GameConfig.hide_titles_in_rally = on, "hide_titles_in_rally")
	_subheader(game, "input")
	_check(game, "hardware cursor", MenuCopy.sub("hardware_cursor"), 
		GameConfig.hardware_cursor, func(on: bool): GameConfig.hardware_cursor = on, "hardware_cursor")
	_range(game, "mouse sensitivity", 0.25, 3.0, 0.05, GameConfig.mouse_sensitivity, 
		func(v: float) -> String: return "%.2fx" % v, 
		func(v: float): GameConfig.mouse_sensitivity = v, DEFAULTS.mouse_sensitivity)
	_range(game, "controller sensitivity", 0.25, 3.0, 0.05, GameConfig.stick_sensitivity, 
		func(v: float) -> String: return "%.2fx" % v, 
		func(v: float): GameConfig.stick_sensitivity = v, DEFAULTS.stick_sensitivity)
	_check(game, "invert x axis", MenuCopy.sub("invert_cam_x"), 
		GameConfig.invert_cam_x, func(on: bool): GameConfig.invert_cam_x = on, "invert_cam_x")
	_check(game, "invert y axis", MenuCopy.sub("invert_cam_y"), 
		GameConfig.invert_cam_y, func(on: bool): GameConfig.invert_cam_y = on, "invert_cam_y")
	_check(game, "sprint toggle", MenuCopy.sub("sprint_toggle"), 
		GameConfig.sprint_toggle, func(on: bool): GameConfig.sprint_toggle = on, "sprint_toggle")
	_check(game, "double-tap sprint", MenuCopy.sub("sprint_double_tap"), 
		GameConfig.sprint_double_tap, func(on: bool): GameConfig.sprint_double_tap = on, 
		"sprint_double_tap")
	_reset_btn(game, "gameplay")

	var access: = _tab(tabs, "accessibility")
	_check(access, "cursor assist", MenuCopy.sub("aim_assist"), 
		GameConfig.aim_assist, func(on: bool): GameConfig.aim_assist = on, "aim_assist")
	_check(access, "set assist", MenuCopy.sub("set_assist"), 
		GameConfig.set_assist, func(on: bool): GameConfig.set_assist = on, "set_assist")
	_check(access, "camera shake", MenuCopy.sub("camera_shake"), 
		GameConfig.camera_shake, func(on: bool): GameConfig.camera_shake = on, "camera_shake")
	_check(access, "fov effects", MenuCopy.sub("camera_fov_fx"), 
		GameConfig.camera_fov_fx, func(on: bool): GameConfig.camera_fov_fx = on, "camera_fov_fx")
	_select(access, "shake intensity", SHAKE_PRESET_NAMES, 
		clampi(GameConfig.camera_shake_preset, 0, SHAKE_PRESET_NAMES.size() - 1), 
		func(i: int): GameConfig.camera_shake_preset = i, int(DEFAULTS.camera_shake_preset))
	_check(access, "rumble", "controller vibration on your hits and impacts", 
		GameConfig.rumble, func(on: bool): GameConfig.rumble = on, "rumble")


	_reset_btn(access, "accessibility")

	_build_crosshair_tab(tabs)
	_build_controls_tab(tabs)




func _build_crosshair_tab(tabs: TabContainer) -> void :
	var col: = _tab(tabs, "crosshair")
	_subheader(col, "shape")


	var shapes: = _row(col, "")
	shapes.alignment = BoxContainer.ALIGNMENT_BEGIN




	var preview_tint: Color = GameConfig.crosshair_color if GameConfig.crosshair_custom\
	else Rules.HOME_COLOR
	for s in Crosshair.SHAPES:
		var id: = String(s.id)
		var b: = Button.new()
		b.custom_minimum_size = Vector2(54, 54)
		b.icon = Crosshair.tex(id)
		b.expand_icon = true
		var sel: = id == GameConfig.crosshair_shape
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.16, 0.18, 0.24) if sel else Color(0.11, 0.12, 0.16)
		sb.set_corner_radius_all(10)
		sb.set_border_width_all(3 if sel else 1)
		sb.border_color = UiStyle.PRIMARY if sel else Color(UiStyle.INK, 0.18)
		sb.set_content_margin_all(6)
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		for state in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
				"icon_focus_color"]:
			b.add_theme_color_override(state, preview_tint)
		b.pressed.connect( func():
			GameConfig.crosshair_shape = id
			GameConfig.save_settings()
			rebuild())
		shapes.add_child(b)
	_subheader(col, "color")



	_check(col, "custom color", "otherwise it matches the side you're aiming at", 
		GameConfig.crosshair_custom, func(on: bool):
			GameConfig.crosshair_custom = on
			GameConfig.save_settings()
			rebuild.call_deferred(), "crosshair_custom")
	if GameConfig.crosshair_custom:
		_color_row(col, "fill", GameConfig.crosshair_color, func(c: Color):
			GameConfig.crosshair_color = c, DEFAULTS.crosshair_color)
	_color_row(col, "outline", GameConfig.crosshair_outline, func(c: Color):
		GameConfig.crosshair_outline = c, DEFAULTS.crosshair_outline)
	_subheader(col, "ring")
	_check(col, "floor ring", "the aiming circle on the floor (off = just the dot)", 
		GameConfig.crosshair_ring, func(on: bool):
			GameConfig.crosshair_ring = on
			GameConfig.save_settings(), "crosshair_ring")
	_subheader(col, "size")
	_range(col, "size", 1.0, 8.0, 0.5, GameConfig.crosshair_size, 
		func(v: float) -> String: return "%.1fx" % v, 
		func(v: float): GameConfig.crosshair_size = v, DEFAULTS.crosshair_size)
	_reset_btn(col, "crosshair")


func _color_row(col: VBoxContainer, label: String, value: Color, apply: Callable, 
		default: = Color(0, 0, 0, 0)) -> void :
	var row: = _row(col, label)


	var ref: = {"arrow": null, "cp": null}
	var arrow: Button = null
	if default.a > 0.0:
		arrow = _arrow( not value.is_equal_approx(default), func():
			var pk: = ref["cp"] as ColorPickerButton
			pk.color = default
			pk.color_changed.emit(default))
		ref["arrow"] = arrow
	var cp: = UiStyle.color_field(value, func(c: Color):
		apply.call(c)
		GameConfig.save_settings()
		var ar = ref["arrow"]
		if ar != null and is_instance_valid(ar):
			UiStyle.set_reset_lit(ar, not c.is_equal_approx(default)))
	ref["cp"] = cp
	cp.custom_minimum_size = Vector2(90, 30)
	cp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(cp)
	row.add_child(arrow if arrow != null else _arrow_gap())



func _build_controls_tab(tabs: TabContainer) -> void :
	var col: = _tab(tabs, "controls")
	_bind_buttons.clear()
	var binds: = _active_binds()


	_subheader(col, "rebind")
	var game: = _bind_grid(col, ["keyboard", "controller"])
	for entry in InputBinds.REBINDABLE:
		if not InputBinds.listed(entry) or bool(entry.get("chat", false)):
			continue
		_bind_label(game, String(entry.label))
		game.add_child(_bind_slot(String(entry.action), "kb", bool(entry.kb), binds))
		game.add_child(_bind_slot(String(entry.action), "pad", bool(entry.pad), binds))
	_subheader(col, "quick chat")
	var chat: = _bind_grid(col, ["keyboard", "alternative", "controller"])
	for entry in InputBinds.REBINDABLE:
		if not InputBinds.listed(entry) or not bool(entry.get("chat", false)):
			continue
		_bind_label(chat, String(entry.label))
		for slot in InputBinds.SLOTS:
			chat.add_child(_bind_slot(String(entry.action), slot, bool(entry.get(slot, false)), binds))

	_subheader(col, "power")
	_range(col, "max power", float(GameConfig.POWER_CAP_MIN), 16.0, 1.0, float(GameConfig.power_cap), 
		func(v: float) -> String: return "%d" % int(v), 
		func(v: float):
			GameConfig.power_cap = int(v)
			GameConfig.save_settings()
			_refresh_power_keys(), 16.0)
	_pk_grid = GridContainer.new()
	_pk_grid.columns = 3
	_pk_grid.add_theme_constant_override("h_separation", 12)
	_pk_grid.add_theme_constant_override("v_separation", 8)
	col.add_child(_pk_grid)
	_pk_add = Button.new()
	_pk_add.text = "+ add key"
	UiStyle.style_button(_pk_add, "secondary", 14)
	_pk_add.custom_minimum_size = Vector2(0, 34)
	_pk_add.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_pk_add.pressed.connect( func():
		if _pk_listen >= 0:
			_cancel_pk_listen()
		if GameConfig.power_keys.size() >= 8:
			return
		GameConfig.power_keys.append({"t": "key", "c": 0, "pow": GameConfig.power_cap})
		GameConfig.save_settings()
		_refresh_power_keys())
	col.add_child(_pk_add)
	_refresh_power_keys()
	var gap: = Control.new()
	gap.custom_minimum_size.y = 6
	col.add_child(gap)
	var reset: = Button.new()
	reset.text = "reset all controls"
	UiStyle.style_button(reset, "secondary", 14)
	reset.custom_minimum_size = Vector2(0, 40)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	reset.pressed.connect( func():
		_cancel_listen()
		_cancel_pk_listen()
		ProfileStore.reset_bindings()
		GameConfig.power_keys = GameConfig.POWER_KEYS_DEFAULT.duplicate(true)
		GameConfig.save_settings()
		_refresh_power_keys()
		_refresh_bind_labels())
	col.add_child(reset)

const BIND_BTN_W: = 96
const BIND_SLOT_W: = 156



func _bind_grid(col: VBoxContainer, names: Array) -> GridContainer:
	var grid: = GridContainer.new()
	grid.columns = names.size() + 1
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.add_child(Control.new())
	for name in names:
		var h: = Label.new()
		h.text = name
		UiStyle.style_label(h, "muted")
		grid.add_child(h)
	col.add_child(grid)
	return grid


func _bind_label(grid: GridContainer, text: String) -> void :
	var l: = Label.new()
	l.text = text
	UiStyle.style_label(l, "body")
	l.custom_minimum_size.x = 150
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	grid.add_child(l)

func _active_binds() -> Dictionary:
	var p: = ProfileStore.active()
	return p.bindings if p != null else {}




func _bind_slot(action: String, slot: String, applies: bool, binds: Dictionary) -> Control:
	if not applies:
		var dash: = Label.new()
		dash.text = "—"
		dash.custom_minimum_size.x = BIND_SLOT_W
		dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiStyle.style_label(dash, "muted")
		return dash
	var cell: = HBoxContainer.new()
	cell.add_theme_constant_override("separation", 4)
	cell.custom_minimum_size.x = BIND_SLOT_W
	var b: = Button.new()
	b.text = InputBinds.label_for(action, slot, binds)
	UiStyle.style_button(b, "secondary", 14)
	b.custom_minimum_size = Vector2(BIND_BTN_W, 34)
	b.pressed.connect( func(): _begin_listen(action, slot, b))
	_bind_buttons["%s|%s" % [action, slot]] = b
	cell.add_child(b)
	var rst: = Button.new()
	rst.text = "↺"
	UiStyle.style_button(rst, "secondary", 14)
	rst.custom_minimum_size = Vector2(26, 34)
	rst.pressed.connect( func():
		if _listen_action == action and _listen_slot == slot:
			_cancel_listen()
		ProfileStore.reset_binding(action, slot)
		_refresh_bind_labels())
	cell.add_child(rst)
	var clear: = Button.new()
	clear.text = "✕"
	clear.tooltip_text = "unbind"
	UiStyle.style_button(clear, "secondary", 14)
	clear.custom_minimum_size = Vector2(26, 34)
	clear.pressed.connect( func():
		if _listen_action == action and _listen_slot == slot:
			_cancel_listen()
		ProfileStore.unbind(action, slot)
		_refresh_bind_labels())
	cell.add_child(clear)
	return cell




func _refresh_bind_labels() -> void :
	var binds: = _active_binds()
	for key in _bind_buttons:
		var b: = _bind_buttons[key] as Button
		if b == null or not is_instance_valid(b):
			continue
		var parts: = String(key).split("|")
		b.text = InputBinds.label_for(parts[0], parts[1], binds)

var _bind_buttons: = {}

var _pk_grid: GridContainer = null
var _pk_add: Button = null
var _pk_listen: = - 1
var _pk_btn: Button = null
var _pk_since: = 0

func _pk_label(ent: Dictionary) -> String:
	if int(ent.get("c", 0)) == 0:
		return "—"
	return InputBinds.label_for_data({"t": ent.get("t", "key"), "c": ent.get("c", 0)})

func _refresh_power_keys() -> void :
	if _pk_listen >= 0:
		_pk_listen = - 1
	if _pk_btn != null:
		_pk_btn = null
	if _pk_grid == null or not is_instance_valid(_pk_grid):
		return
	for c in _pk_grid.get_children():
		c.queue_free()
	var hgap: = Control.new()
	_pk_grid.add_child(hgap)
	var hkey: = Label.new()
	hkey.text = "key"
	UiStyle.style_label(hkey, "muted")
	_pk_grid.add_child(hkey)
	var hpow: = Label.new()
	hpow.text = "power"
	UiStyle.style_label(hpow, "muted")
	_pk_grid.add_child(hpow)
	for i in GameConfig.power_keys.size():
		if not (GameConfig.power_keys[i] is Dictionary):
			continue
		var ent: Dictionary = GameConfig.power_keys[i]
		var kb: = Button.new()
		kb.custom_minimum_size = Vector2(BIND_BTN_W, 34)
		UiStyle.style_button(kb, "secondary", 14)
		kb.text = _pk_label(ent)
		kb.pressed.connect( func(): _begin_pk_listen(i, kb))
		_pk_grid.add_child(kb)
		var cell: = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var lb: = Label.new()
		lb.custom_minimum_size.x = 44
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		UiStyle.style_label(lb, "body")
		var step: = func(d: int):
			var lvl: int = clampi(int(ent.get("pow", 1)) + d, 1, GameConfig.power_cap)
			ent["pow"] = lvl
			lb.text = str(lvl)
			GameConfig.save_settings()
		var mn: = Button.new()
		mn.text = "-"
		UiStyle.style_button(mn, "secondary", 14)
		mn.custom_minimum_size = Vector2(26, 34)
		mn.pressed.connect( func(): step.call(- 1))
		var pl: = Button.new()
		pl.text = "+"
		UiStyle.style_button(pl, "secondary", 14)
		pl.custom_minimum_size = Vector2(26, 34)
		pl.pressed.connect( func(): step.call(1))
		lb.text = str(clampi(int(ent.get("pow", 1)), 1, GameConfig.power_cap))
		cell.add_child(mn)
		cell.add_child(lb)
		cell.add_child(pl)
		_pk_grid.add_child(cell)
		var rm: = Button.new()
		rm.text = "✕"
		rm.tooltip_text = "remove"
		UiStyle.style_button(rm, "secondary", 14)
		rm.custom_minimum_size = Vector2(26, 34)
		var idx: = i
		rm.pressed.connect( func():
			GameConfig.power_keys.remove_at(idx)
			GameConfig.save_settings()
			_refresh_power_keys())
		_pk_grid.add_child(rm)
	if _pk_add != null and is_instance_valid(_pk_add):
		_pk_add.disabled = GameConfig.power_keys.size() >= 8

func _begin_pk_listen(idx: int, btn: Button) -> void :
	_cancel_listen()
	_pk_listen = idx
	_pk_btn = btn
	_pk_since = Time.get_ticks_msec()
	btn.text = "press a key…"

func _cancel_pk_listen() -> void :
	if _pk_btn != null and is_instance_valid(_pk_btn):
		if _pk_listen >= 0 and _pk_listen < GameConfig.power_keys.size()\
		and GameConfig.power_keys[_pk_listen] is Dictionary:
			_pk_btn.text = _pk_label(GameConfig.power_keys[_pk_listen])
	_pk_listen = - 1
	_pk_btn = null

var _listen_action: = ""
var _listen_slot: = ""
var _listen_btn: Button = null
var _listen_since: = 0

func _begin_listen(action: String, slot: String, btn: Button) -> void :
	_cancel_listen()
	_listen_action = action
	_listen_slot = slot
	_listen_btn = btn
	_listen_since = Time.get_ticks_msec()
	btn.text = "press a %s…" % ("key" if InputBinds.slot_kind(slot) == "kb" else "button")

func _cancel_listen() -> void :
	if _listen_btn != null and is_instance_valid(_listen_btn):
		_listen_btn.text = InputBinds.label_for(_listen_action, _listen_slot, _active_binds())
	_listen_action = ""
	_listen_slot = ""
	_listen_btn = null

func _input(event: InputEvent) -> void :
	if _pk_btn != null and not is_instance_valid(_pk_btn):
		_pk_listen = - 1
		_pk_btn = null
	if _pk_btn != null:
		if event is InputEventKey and event.pressed\
		and (event as InputEventKey).keycode == KEY_ESCAPE:
			accept_event()
			_cancel_pk_listen()
			return
		if (event is InputEventKey or event is InputEventMouseButton)\
		and LocalPlayers.kbm_taken():
			return
		if Time.get_ticks_msec() - _pk_since < 180:
			return
		var pk_cap: InputEvent = null
		if event is InputEventKey and event.pressed and not (event as InputEventKey).echo:
			pk_cap = event
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			pk_cap = event
		if pk_cap == null:
			return
		var data: Variant = InputBinds.event_to_data(pk_cap)
		accept_event()
		var idx: = _pk_listen
		_pk_listen = - 1
		_pk_btn = null
		if data is Dictionary and idx >= 0 and idx < GameConfig.power_keys.size()\
		and GameConfig.power_keys[idx] is Dictionary:
			var ent: Dictionary = GameConfig.power_keys[idx]
			ent["t"] = String(data.get("t", "key"))
			ent["c"] = int(data.get("c", 0))
			GameConfig.save_settings()
			_refresh_power_keys()
		return

	if _listen_btn == null:
		return




	if (event is InputEventJoypadButton or event is InputEventJoypadMotion)\
	and event.device in LocalPlayers.claimed_pads():
		return
	if (event is InputEventKey or event is InputEventMouseButton) and LocalPlayers.kbm_taken():
		return


	if Time.get_ticks_msec() - _listen_since < 180:
		return

	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		accept_event()
		_cancel_listen()
		return
	var captured: InputEvent = null
	if InputBinds.slot_kind(_listen_slot) == "kb":
		if event is InputEventKey and event.pressed and not (event as InputEventKey).echo:
			captured = event
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			captured = event
	else:
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
			captured = event
		elif event is InputEventJoypadMotion\
		and absf((event as InputEventJoypadMotion).axis_value) > 0.7:
			captured = event
	if captured == null:
		return
	accept_event()
	var a: = _listen_action
	var s: = _listen_slot
	_listen_action = ""
	_listen_slot = ""
	_listen_btn = null
	ProfileStore.set_binding(a, s, InputBinds.event_to_data(captured))


	_refresh_bind_labels()



func _subheader(col: VBoxContainer, text: String) -> void :
	if col.get_child_count() > 0:
		var gap: = Control.new()
		gap.custom_minimum_size.y = 8
		col.add_child(gap)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", 
		UiStyle.SECONDARY.lightened(0.3) if UiStyle.dark else UiStyle.SECONDARY)
	row.add_child(l)
	var rule: = Panel.new()
	rule.custom_minimum_size.y = 2
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.add_theme_stylebox_override("panel", UiStyle.flat_box(Color(UiStyle.text(), 0.1), 1))
	row.add_child(rule)
	col.add_child(row)




func reset_all() -> void :
	if scope != Scope.PROFILE:
		_reset_category("audio", false)
		_reset_category("video", false)
		_reset_category("general", false)
	if scope != Scope.SYSTEM:
		_reset_category("gameplay", false)
		_reset_category("accessibility", false)


		_cancel_listen()
		ProfileStore.reset_bindings()
	GameConfig.save_settings()
	rebuild()





func _build_debug_tab(tabs: TabContainer) -> void :
	var col: = _tab(tabs, "debug")
	var master: = _named_check("DebugCheck", 
		"developer optionsdev tools and readouts", GameConfig.debug_menu)
	col.add_child(master)
	var drawer: = VBoxContainer.new()
	drawer.name = "DebugBox"
	drawer.add_theme_constant_override("separation", 12)
	drawer.visible = GameConfig.debug_menu
	col.add_child(drawer)
	master.toggled.connect( func(on: bool):
		GameConfig.debug_menu = on
		drawer.visible = on


		if not on:
			Net.fake_latency_ms = 0
			Net.fake_jitter_ms = 0
			Net.fake_loss_pct = 0
		GameConfig.save_settings())
	var setarc: = _named_check("SetArcCheck", 
		"set arc (the dotted path of the set you're holding)", GameConfig.set_preview)
	setarc.toggled.connect( func(on: bool):
		GameConfig.set_preview = on
		GameConfig.save_settings())
	drawer.add_child(setarc)
	var cam: = _named_check("CamDebugCheck", 
		"camera readoutposition + mode overlay", GameConfig.show_cam_debug)
	cam.toggled.connect( func(on: bool):
		GameConfig.show_cam_debug = on
		GameConfig.save_settings())
	drawer.add_child(cam)

	var nocd: = _named_check("NoCooldownCheck", 
		"no cooldownsdive and block recover instantly", GameConfig.no_cooldowns)
	nocd.toggled.connect( func(on: bool):
		GameConfig.no_cooldowns = on)
	drawer.add_child(nocd)
	var hitstop: = _named_check("HitstopCheck", 
		"spike hitstopearned spikes hang for a beat at contact", 
		GameConfig.spike_hitstop)
	hitstop.toggled.connect( func(on: bool):
		GameConfig.spike_hitstop = on)
	drawer.add_child(hitstop)
	var zones: = _named_check("ServeZonesCheck", 
		"all serve zonespaint every server's zone, not just yours", 
		GameConfig.debug_serve_zones)
	zones.toggled.connect( func(on: bool):
		GameConfig.debug_serve_zones = on)
	drawer.add_child(zones)
	var netlog: = _named_check("NetLogCheck", 
		"net logprint the netcode trace", GameConfig.debug_net_log)
	netlog.toggled.connect( func(on: bool):
		GameConfig.debug_net_log = on
		GameConfig.save_settings())
	drawer.add_child(netlog)
	var predict: = _named_check("PredictCheck", 
		"predict contactsclient-side contact prediction", 
		GameConfig.predict_contacts)
	predict.toggled.connect( func(on: bool):
		GameConfig.predict_contacts = on
		GameConfig.save_settings())
	drawer.add_child(predict)
	var row: = _row(drawer, "simulated latency")
	var sel: = UiSelect.new(LATENCY_NAMES)
	sel.name = "LatencyOption"
	sel.selected = maxi(LATENCY_MS.find(Net.fake_latency_ms), 0)
	sel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sel.picked.connect( func(i: int): Net.fake_latency_ms = LATENCY_MS[i])
	row.add_child(sel)




	var econ: = HBoxContainer.new()
	econ.add_theme_constant_override("separation", 10)
	drawer.add_child(econ)
	var give: = Button.new()
	give.name = "GiveCoinsBtn"
	give.text = "give %d coins" % DEBUG_COINS
	UiStyle.style_button(give, "secondary", 14)
	give.custom_minimum_size = Vector2(0, 40)
	econ.add_child(give)
	var award: = Button.new()
	award.name = "AwardAllBtn"
	award.text = "award all achievements"
	award.tooltip_text = "finishes every achievement on this profile so you can claim them. never touches steam"
	UiStyle.style_button(award, "secondary", 14)
	award.custom_minimum_size = Vector2(0, 40)
	econ.add_child(award)
	var said: = Label.new()
	said.name = "EconomySaid"
	UiStyle.style_label(said, "small", UiStyle.muted())
	said.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	econ.add_child(said)
	give.pressed.connect( func():
		Progression.add_coins(DEBUG_COINS)
		var prof: = ProfileStore.active()
		said.text = "you have %d coins now" % (prof.coins if prof != null else 0)
		UiStyle.sfx("confirm")
		economy_poked.emit())


	var lv_row: = HBoxContainer.new()
	lv_row.name = "LevelTools"
	lv_row.add_theme_constant_override("separation", 8)
	drawer.add_child(lv_row)
	var lv_said: = Label.new()
	lv_said.name = "LevelSaid"
	UiStyle.style_label(lv_said, "body")
	lv_said.custom_minimum_size.x = 92
	var lv_edit: = LineEdit.new()
	lv_edit.name = "LevelEdit"
	lv_edit.placeholder_text = "level"
	lv_edit.custom_minimum_size = Vector2(90, 40)
	UiStyle.style_line_edit(lv_edit)
	var show_lv: = func():
		var prof: = ProfileStore.active()
		lv_said.text = "level %d" % (prof.level if prof != null else 1)
	var set_lv: = func(lv: int):
		Progression.debug_set_level(lv)
		show_lv.call()
		UiStyle.sfx("confirm")
		economy_poked.emit()
	lv_row.add_child(lv_said)
	for step in [-10, -1, 1, 10]:
		var b: = Button.new()
		b.name = "Level%+d" % step
		b.text = "%+d" % step
		UiStyle.style_button(b, "secondary", 14)
		b.custom_minimum_size = Vector2(52, 40)
		b.pressed.connect( func():
			var prof: = ProfileStore.active()
			set_lv.call((prof.level if prof != null else 1) + int(step)))
		lv_row.add_child(b)
	lv_row.add_child(lv_edit)
	var lv_go: = Button.new()
	lv_go.name = "LevelSetBtn"
	lv_go.text = "set"
	UiStyle.style_button(lv_go, "secondary", 14)
	lv_go.custom_minimum_size = Vector2(0, 40)
	lv_go.pressed.connect( func():
		if lv_edit.text.strip_edges().is_valid_int():
			set_lv.call(int(lv_edit.text.strip_edges())))
	lv_edit.text_submitted.connect( func(_t: String): lv_go.pressed.emit())
	lv_row.add_child(lv_go)
	var lv_max: = Button.new()
	lv_max.name = "LevelMaxBtn"
	lv_max.text = "max level"
	UiStyle.style_button(lv_max, "secondary", 14)
	lv_max.custom_minimum_size = Vector2(0, 40)
	lv_max.pressed.connect( func(): set_lv.call(Progression.LEVEL_MAX))
	lv_row.add_child(lv_max)
	var lv_reset: = Button.new()
	lv_reset.name = "LevelResetBtn"
	lv_reset.text = "reset to 1"
	UiStyle.style_button(lv_reset, "secondary", 14)
	lv_reset.custom_minimum_size = Vector2(0, 40)
	lv_reset.pressed.connect( func(): set_lv.call(1))
	lv_row.add_child(lv_reset)
	show_lv.call()
	award.pressed.connect( func():
		var n: = Achievements.debug_award_all()
		said.text = "%d finished. claim them on the awards page" % n if n > 0 else "they are all finished already"
		UiStyle.sfx("confirm")
		economy_poked.emit())



	if GameConfig.dev_tools:
		var gap: = Control.new()
		gap.custom_minimum_size.y = 6
		drawer.add_child(gap)
		var lab: = Button.new()
		lab.name = "StageLabBtn"
		lab.text = "stage lab"
		UiStyle.style_button(lab, "secondary", 14)
		lab.custom_minimum_size = Vector2(0, 40)
		lab.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		lab.pressed.connect( func():
			GameConfig.goto_scene.call_deferred("res://game/dev/stage_lab.tscn"))
		drawer.add_child(lab)

		var load_lab: = Button.new()
		load_lab.name = "LoadingLabBtn"
		load_lab.text = "loading lab"
		UiStyle.style_button(load_lab, "secondary", 14)
		load_lab.custom_minimum_size = Vector2(0, 40)
		load_lab.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		load_lab.pressed.connect( func():
			GameConfig.goto_scene.call_deferred("res://game/dev/loading_lab.tscn"))
		drawer.add_child(load_lab)
		var avatar_export: = Button.new()
		avatar_export.name = "AvatarExporterBtn"
		avatar_export.text = "avatar exporter"
		UiStyle.style_button(avatar_export, "secondary", 14)
		avatar_export.custom_minimum_size = Vector2(0, 40)
		avatar_export.pressed.connect( func():
			var window: = Window.new()
			window.set_script(load("res://game/dev/asset_export/avatar_export_window.gd"))
			add_child(window))
		drawer.add_child(avatar_export)
		var ball_export: = Button.new()
		ball_export.name = "BallExporterBtn"
		ball_export.text = "ball exporter"
		UiStyle.style_button(ball_export, "secondary", 14)
		ball_export.custom_minimum_size = Vector2(0, 40)
		ball_export.pressed.connect( func():
			var window: = Window.new()
			window.set_script(load("res://game/dev/asset_export/ball_export_window.gd"))
			add_child(window))
		drawer.add_child(ball_export)
		var fx_export: = Button.new()
		fx_export.name = "FxExporterBtn"
		fx_export.text = "fx exporter"
		UiStyle.style_button(fx_export, "secondary", 14)
		fx_export.custom_minimum_size = Vector2(0, 40)
		fx_export.pressed.connect( func():
			var window: = Window.new()
			window.set_script(load("res://game/dev/asset_export/fx_export_window.gd"))
			add_child(window))
		drawer.add_child(fx_export)

func _named_check(node_name: String, label: String, on: bool) -> CheckBox:
	var cb: = CheckBox.new()
	cb.name = node_name
	cb.text = label
	cb.button_pressed = on
	UiStyle.style_check(cb)
	return cb

func _reset_btn(col: VBoxContainer, cat: String) -> void :
	var gap: = Control.new()
	gap.custom_minimum_size.y = 6
	col.add_child(gap)
	var b: = Button.new()
	b.text = "reset %s" % cat
	UiStyle.style_button(b, "secondary", 14)
	b.custom_minimum_size = Vector2(0, 40)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect( func():
		_reset_category(cat, true)
		rebuild())
	col.add_child(b)

func _reset_category(cat: String, save: = true) -> void :
	if cat == "audio":
		for bus in AUDIO_DEFAULTS:
			GameConfig.set_volume(bus, float(AUDIO_DEFAULTS[bus]))
	for key in CATEGORY_KEYS.get(cat, []):
		GameConfig.set(key, DEFAULTS[key])
	if cat == "video":
		GameConfig.apply_display()
		GameConfig.apply_render_scale()
		GameConfig.apply_msaa()
	if save:
		GameConfig.save_settings()
		UiStyle.sfx("confirm")


func _tab(tabs: TabContainer, tab_name: String) -> VBoxContainer:
	var scroll: = ScrollContainer.new()
	scroll.name = tab_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	var col: = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 12)
	var pad: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % side, 14)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(col)
	scroll.add_child(pad)
	tabs.add_child(scroll)
	return col

func _row(col: VBoxContainer, label: String) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var l: = Label.new()
	l.text = label
	UiStyle.style_label(l, "body")
	l.custom_minimum_size.x = 150
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	col.add_child(row)
	return row



const ARROW_W: = 36

func _arrow(lit: bool, on_reset: Callable) -> Button:
	var b: = UiStyle.reset_button(on_reset)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.set_reset_lit(b, lit)
	return b


func _arrow_gap() -> Control:
	var gap: = Control.new()
	gap.custom_minimum_size.x = ARROW_W
	return gap

func _slider(col: VBoxContainer, label: String, bus: String) -> void :
	var row: = _row(col, label)
	var s: = HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.01
	s.value = GameConfig.get_volume(bus)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_slider(s)
	s.value_changed.connect( func(vv: float): GameConfig.set_volume(bus, vv))
	row.add_child(s)

	var readout: = Label.new()
	readout.custom_minimum_size.x = 52
	readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	readout.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_label(readout, "body")
	readout.text = "%d%%" % int(round(s.value * 100.0))
	s.value_changed.connect( func(vv: float): readout.text = "%d%%" % int(round(vv * 100.0)))
	row.add_child(readout)

	if AUDIO_DEFAULTS.has(bus):
		row.add_child(_slider_reset(s, float(AUDIO_DEFAULTS[bus])))




func _resolution_slider(col: VBoxContainer) -> HSlider:
	var row: = _row(col, "3d resolution")
	var s: = HSlider.new()
	s.min_value = GameConfig.RESOLUTION_3D_MIN
	s.max_value = 100
	s.step = 5
	s.value = GameConfig.resolution_3d
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_slider(s)
	var readout: = Label.new()
	readout.custom_minimum_size.x = 52
	readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	readout.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_label(readout, "body")
	readout.text = "%d%%" % int(s.value)
	var dragging: = [false]
	var commit: = func():
		if int(s.value) != GameConfig.resolution_3d:
			GameConfig.resolution_3d = int(s.value)
			GameConfig.apply_render_scale()
			GameConfig.save_settings()
	s.drag_started.connect( func(): dragging[0] = true)
	s.drag_ended.connect( func(_changed: bool):
		dragging[0] = false
		commit.call())
	s.value_changed.connect( func(vv: float):
		readout.text = "%d%%" % int(vv)
		if not dragging[0]:
			commit.call())
	row.add_child(s)
	row.add_child(readout)
	row.add_child(_slider_reset(s, float(DEFAULTS.resolution_3d)))
	return s



func _slider_reset(s: HSlider, default: float) -> Button:
	var b: = _arrow( not is_equal_approx(s.value, default), func(): s.value = default)
	s.value_changed.connect( func(vv: float):
		UiStyle.set_reset_lit(b, not is_equal_approx(vv, default)))
	return b


func _check(col: VBoxContainer, label: String, desc: String, 
		on: bool, apply: Callable, key: = "") -> void :
	var cb: = CheckBox.new()



	cb.text = label
	cb.button_pressed = on
	UiStyle.style_check(cb)
	var arrow: Button = null
	if DEFAULTS.has(key):
		var want: = bool(DEFAULTS[key])
		arrow = _arrow(on != want, func(): cb.button_pressed = want)
	cb.toggled.connect( func(v: bool):
		apply.call(v)
		GameConfig.save_settings()
		if arrow != null and is_instance_valid(arrow):
			UiStyle.set_reset_lit(arrow, v != bool(DEFAULTS[key])))
	_check_row(col, cb, arrow)



func _check_row(col: VBoxContainer, cb: CheckBox, arrow: Button) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	cb.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL


	for st in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		cb.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	cb.add_theme_constant_override("check_v_offset", 0)
	cb.add_theme_constant_override("h_separation", 0)
	row.add_child(cb)
	row.add_child(arrow if arrow != null else _arrow_gap())
	col.add_child(row)


func _select(col: VBoxContainer, label: String, options: Array, 
		current: int, apply: Callable, default: = -1) -> void :
	var row: = _row(col, label)
	var sel: = UiSelect.new(options)
	sel.selected = current
	sel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var arrow: Button = null
	if default >= 0:
		arrow = _arrow(current != default, func():
			if sel.selected != default:
				sel.selected = default
				sel.picked.emit(default))
	_last_select = sel
	sel.picked.connect( func(i: int):
		apply.call(i)
		GameConfig.save_settings()
		if arrow != null and is_instance_valid(arrow):
			UiStyle.set_reset_lit(arrow, i != default))
	row.add_child(sel)
	row.add_child(arrow if arrow != null else _arrow_gap())




func _range(col: VBoxContainer, label: String, mn: float, mx: float, 
		step: float, val: float, fmt: Callable, apply: Callable, 
		default: = NAN) -> void :
	var row: = _row(col, label)
	var s: = HSlider.new()
	s.min_value = mn
	s.max_value = mx
	s.step = step
	s.value = val
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_slider(s)
	var readout: = Label.new()
	readout.custom_minimum_size.x = 52
	readout.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_label(readout, "body")
	readout.text = fmt.call(val)
	s.value_changed.connect( func(vv: float):
		readout.text = fmt.call(vv)
		apply.call(vv)
		GameConfig.save_settings())
	row.add_child(s)
	row.add_child(readout)
	if not is_nan(default):
		row.add_child(_slider_reset(s, default))
	else:
		row.add_child(_arrow_gap())



func _res_list() -> Array:
	var native: = DisplayServer.screen_get_size(
		DisplayServer.window_get_current_screen())
	var out: Array = []
	for r in RES_STEPS:
		if r.x <= native.x and r.y <= native.y:
			out.append(r)
	if not out.has(native):
		out.append(native)
	return out

func _res_names() -> Array:
	var native: = DisplayServer.screen_get_size(
		DisplayServer.window_get_current_screen())
	var names: Array = []
	for r in _res_list():
		names.append("%d x %d%s" % [r.x, r.y, 
			"   native" if r == native else ""])
	return names

func _res_index() -> int:
	var list: = _res_list()
	for i in list.size():
		if list[i] == GameConfig.window_size:
			return i
	return list.size() - 1
