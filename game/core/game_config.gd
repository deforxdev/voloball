extends Node






var _settings_path: = "user://settings.json"



signal settings_saved

var master_volume: = 1.0
var sfx_volume: = 1.0
var crowd_volume: = 1.0
var music_volume: = 0.2
var ambient_volume: = 0.7

var language: = "en"

var character: CharacterConfig = null








var free_mouse_harness: = false


var capture_wanted: = false
var capture_wanted_ms: = -1000000

func capture_mouse(on: bool) -> void :
	capture_wanted = on
	if on:
		capture_wanted_ms = Time.get_ticks_msec()
	if on and free_mouse_harness:
		on = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE

func may_warp_mouse() -> bool:
	return not free_mouse_harness

func _ready() -> void :






	if not ProjectSettings.has_setting("shader_globals/jv_night_rim"):
		RenderingServer.global_shader_parameter_add(&"jv_night_rim", 
			RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.0)


	if "--rtl" in LaunchGate.dev_args():
		TranslationServer.set_locale("ar")





	apply_language()

	get_tree().node_added.connect(_ui_mips)
	free_mouse_harness = AppData.is_harness()\
	and not ("--grab-mouse" in LaunchGate.dev_args())


	if free_mouse_harness and DisplayServer.get_name() != "headless"\
	and not ("--take-focus" in LaunchGate.dev_args()):
		get_window().set_flag(Window.FLAG_NO_FOCUS, true)




	if AppData.decide_safe_boot():
		AppData.relaunch_compatibility()
		get_tree().quit.call_deferred()
		return



	AppData.init_appdata()
	_settings_path = AppData.migrate("user://settings.json", "settings.json")
	_ensure_bus("sfx")



	_ensure_bus("feedback")
	_ensure_bus("crowd")


	_ensure_bus("music")
	_ensure_bus("ambient")
	_ensure_voice_bus()
	_ensure_announcer_bus()
	_load_settings()
	if OS.has_feature("mobile") or OS.get_cmdline_user_args().has("--mobile-preview"):
		apply_quality(QUALITY_LOW)
		resolution_3d = 75
		max_fps = 60
		msaa = 0
		aim_assist = true
		set_assist = true
	apply_language()
	apply_pad_focus()
	set_process(false)

	if OS.get_environment("NO_BAR") != "1" and not MobileControls.enabled():
		_build_power_bar()
		get_tree().process_frame.connect(_update_power_bar)



	if AppData.safe_mode:
		reflections = false
		msaa = 0
		shadows = 0
	_apply_volumes()


	apply_display.call_deferred()
	apply_render_scale.call_deferred()
	apply_msaa.call_deferred()
	_hook_window_resize.call_deferred()
	character = CharacterConfig.load_local()





func _hook_window_resize() -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	if not tree.root.size_changed.is_connected(_on_window_size_changed):
		tree.root.size_changed.connect(_on_window_size_changed)





var _last_applied_size: = Vector2i.ZERO
var _resize_save_pending: = false

func _on_window_size_changed() -> void :


	if window_mode != WindowMode.WINDOWED:
		return
	var now: = DisplayServer.window_get_size()
	if now == _last_applied_size:
		return
	if now.x <= 0 or now.y <= 0:
		return
	window_size = now
	window_user_sized = true

	if _resize_save_pending:
		return
	_resize_save_pending = true
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		_resize_save_pending = false
		_save_settings()
		return
	tree.create_timer(0.4, true, false, true).timeout.connect( func():
		_resize_save_pending = false
		_save_settings())

var match_seed: = 0


func new_match_seed() -> void :
	match_seed = randi()

func bot_character(side: int, slot: int, salt: = 0) -> CharacterConfig:





	var rng: = RandomNumberGenerator.new()
	rng.seed = hash("cpu:%d:%d:%d:%d" % [side, slot, match_seed, salt])
	return CharacterConfig.random(rng)

func team_gear(is_home: bool) -> Dictionary:



	var cfg: = character if character != null else CharacterConfig.new()
	if is_home:
		return {"socks": cfg.socks, "kneepad": cfg.kneepad, "kneepad_l": cfg.kneepad_left_color()}



	var rng: = RandomNumberGenerator.new()
	rng.seed = hash("gear:%d" % match_seed)
	var gear: = Color.from_hsv(rng.randf(), rng.randf_range(0.4, 0.7), 
		rng.randf_range(0.4, 0.6))
	return {"socks": gear, "kneepad": gear, "kneepad_l": gear}

func dress_in_team_gear(cfg: CharacterConfig, is_home: bool) -> CharacterConfig:

	var gear: = team_gear(is_home)
	cfg.socks = gear["socks"]
	cfg.kneepad = gear["kneepad"]
	cfg.kneepad_l = gear.get("kneepad_l", gear["kneepad"])
	return cfg

func team_kit(is_home: bool) -> Array:



	var cfg: = character if character != null else CharacterConfig.new()
	if is_home:
		return TeamKits.normalize(cfg.captain_kit)
	return opponent_kit()



func opponent_kit() -> Array:
	return TeamKits.generated_kit(team_kit(true), match_seed)






var local_kits: = {}

func side_kit(side: int) -> Array:
	if local_kits.has(side):
		return local_kits[side]
	return team_kit(side == (1 if local_side >= 0 else -1))






const VOICE_LINE_LIFT_DB: = 6.0

func _ensure_voice_bus() -> void :
	_build_voice_bus("voice", 0.0)


	_build_voice_bus("voice_line", VOICE_LINE_LIFT_DB)

func _build_voice_bus(bus_name: String, lift_db: float) -> void :



	_ensure_bus(bus_name)
	var idx: = AudioServer.get_bus_index(bus_name)
	if idx == -1 or AudioServer.get_bus_effect_count(idx) > 0:
		return
	var comp: = AudioEffectCompressor.new()
	comp.threshold = -22.0
	comp.ratio = 8.0
	comp.attack_us = 20.0
	comp.release_ms = 90.0
	comp.gain = 7.0
	AudioServer.add_bus_effect(idx, comp)
	var drive: = AudioEffectDistortion.new()
	drive.mode = AudioEffectDistortion.MODE_CLIP
	drive.drive = 0.22
	drive.pre_gain = 2.0
	drive.post_gain = -4.0 + lift_db
	AudioServer.add_bus_effect(idx, drive)







const MUFFLE_BUSES: = ["sfx", "voice", "voice_line", "crowd"]
const MUFFLE_HZ: = 650.0
var _muffle: Dictionary = {}

func set_sfx_muffle(k: float) -> void :
	if k <= 0.001 and _muffle.is_empty():
		return
	for b in MUFFLE_BUSES:
		var idx: = AudioServer.get_bus_index(b)
		if idx == -1:
			continue
		if not _muffle.has(b):
			var lp: = AudioEffectLowPassFilter.new()
			_muffle[b] = [AudioServer.get_bus_effect_count(idx), lp]
			AudioServer.add_bus_effect(idx, lp)
		var e: Array = _muffle[b]
		var filt: AudioEffectLowPassFilter = e[1]
		filt.cutoff_hz = lerpf(20000.0, MUFFLE_HZ, clampf(k, 0.0, 1.0))
		AudioServer.set_bus_effect_enabled(idx, int(e[0]), k > 0.001)

func _ensure_announcer_bus() -> void :




	_ensure_bus("announcer")
	var idx: = AudioServer.get_bus_index("announcer")
	if idx == -1 or AudioServer.get_bus_effect_count(idx) > 0:
		return
	var comp: = AudioEffectCompressor.new()
	comp.threshold = -18.0
	comp.ratio = 4.0
	comp.attack_us = 15.0
	comp.release_ms = 120.0
	comp.gain = 4.0
	AudioServer.add_bus_effect(idx, comp)

func _ensure_bus(bus_name: String) -> void :
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	var idx: = AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")

func set_volume(which: String, value: float) -> void :
	match which:
		"master":
			master_volume = value
		"sfx":
			sfx_volume = value
		"crowd":
			crowd_volume = value
		"music":
			music_volume = value
		"ambient":
			ambient_volume = value
	_apply_volumes()
	_save_settings()

func get_volume(which: String) -> float:
	match which:
		"master":
			return master_volume
		"sfx":
			return sfx_volume
		"music":
			return music_volume
		"ambient":
			return ambient_volume
	return crowd_volume

func _apply_volumes() -> void :
	_set_bus("Master", master_volume)
	_set_bus("sfx", sfx_volume)
	_set_bus("feedback", sfx_volume)
	_set_bus("crowd", crowd_volume)
	_set_bus("music", music_volume)
	_set_bus("ambient", ambient_volume)

func _set_bus(bus_name: String, value: float) -> void :
	var idx: = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, value <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.001)))









const CURSOR_POINT: = "res://game/kny/cursorpack/PNG/Outline/Default/hand_point.png"
const CURSOR_GRAB: = "res://game/kny/cursorpack/PNG/Outline/Default/hand_closed.png"
const CURSOR_AIM: = "res://game/kny/cursorpack/PNG/Outline/Default/line_cross.png"
const CURSOR_SIZE: = 40


const HAND_TIP: = Vector2(0.3, 0.06)

var _cursor_cache: = {}
var _cursor_aiming: = -1
var _cursor_pressed: = false
var _cursor_path: = ""

func _input(event: InputEvent) -> void :

	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var down: = (event as InputEventMouseButton).pressed
		if down != _cursor_pressed:
			_cursor_pressed = down
			if _cursor_aiming == 0:
				_apply_cursor(false)

func use_cursor(aiming: bool) -> void :
	var want: = 1 if aiming else 0
	if _cursor_aiming == want:
		return
	_cursor_aiming = want
	_apply_cursor(aiming)

func _apply_cursor(aiming: bool) -> void :
	var path: = CURSOR_AIM if aiming else (CURSOR_GRAB if _cursor_pressed else CURSOR_POINT)
	if path == _cursor_path:
		return
	_cursor_path = path
	var tex: Texture2D = _cursor_cache.get(path)
	if tex == null:
		var src: Texture2D = load(path)
		if src == null:
			return
		var img: = src.get_image()
		img.resize(CURSOR_SIZE, CURSOR_SIZE, Image.INTERPOLATE_NEAREST)
		tex = ImageTexture.create_from_image(img)
		_cursor_cache[path] = tex

	var hotspot: = HAND_TIP * CURSOR_SIZE
	if aiming:
		hotspot = Vector2(CURSOR_SIZE * 0.5, CURSOR_SIZE * 0.5)
	Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, hotspot)



func cursor_texture() -> Texture2D:
	if _cursor_aiming == 1:
		return null
	return _cursor_cache.get(_cursor_path)

func cursor_hotspot() -> Vector2:
	return HAND_TIP * CURSOR_SIZE



func aim_cursor_texture() -> Texture2D:
	var tex: Texture2D = _cursor_cache.get(CURSOR_AIM)
	if tex == null:
		var src: Texture2D = load(CURSOR_AIM)
		if src == null:
			return null
		var img: = src.get_image()
		img.resize(CURSOR_SIZE, CURSOR_SIZE, Image.INTERPOLATE_NEAREST)
		tex = ImageTexture.create_from_image(img)
		_cursor_cache[CURSOR_AIM] = tex
	return tex


















enum ArtStyle{CEL_CLASSIC, CEL_INK, WII}




const INK_OUTLINES: = true







var contour_outline: = not ("--no-contour" in LaunchGate.dev_args())
var contour_inner_scale: = 0.6



var contour_inner_lines: = false
var art_style: = ArtStyle.CEL_CLASSIC



var default_camera: = 1



var ranked_match: = false


var quick_match: = false


var time_of_day: = 0



var outfit_rule: = 0


var tod_live: = false


var quick_backfill_side: = 0


var migrate_carry: = {}
const ART_STYLE_NAMES: = [
	"classic (cel bands + ink outline)", 
	"screen ink (cel bands + post-process outline)", 
	"wii (no outline, gloss + rim light)", 
]

func style_is(kind: int) -> bool:
	return art_style == kind










var _scene_pending: = ""







var _ts_token: = 0


var last_slow_time: Array = []

func slow_time(rate: float, duration: float) -> void :
	Engine.time_scale = rate
	last_slow_time = [rate, duration]
	_ts_token += 1
	var tok: = _ts_token
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		Engine.time_scale = 1.0
		return
	tree.create_timer(duration, true, false, true).timeout.connect( func():
		if _ts_token == tok:
			Engine.time_scale = 1.0)

func goto_scene(path: String) -> void :
	if _scene_pending != "":
		return
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		return







	if path == "res://game/ui/menu.tscn" and BootLoader.running and not BootLoader.own_change:
		return



	if path == "res://game/ui/menu.tscn" and BootLoader.enabled() and not BootLoader.running\
	and tree.current_scene != null\
	and tree.current_scene.scene_file_path == "res://game/main/main.tscn":
		BootLoader.begin(tree)
		return

	Engine.time_scale = 1.0


	SandDeform.decal_y = 0.0
	SandDeform.decal_y_feet = 0.0
	_scene_pending = path



	_do_scene_change.call_deferred(path)

func _do_scene_change(path: String) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree != null:
		_before_scene_change(tree, path)
		tree.change_scene_to_file(path)
	_scene_pending = ""


func goto_packed(ps: PackedScene) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or ps == null:
		return
	Engine.time_scale = 1.0
	SandDeform.decal_y = 0.0
	SandDeform.decal_y_feet = 0.0
	_before_scene_change(tree, ps.resource_path)
	tree.change_scene_to_packed(ps)



func _before_scene_change(tree: SceneTree, path: String) -> void :
	var cur: = tree.current_scene
	if cur != null and cur.has_method("before_scene_change"):
		cur.call("before_scene_change", path)

func save_settings() -> void :
	_save_settings()



func has_accepted_online_terms() -> bool:
	return online_terms_accepted and online_terms_version >= ONLINE_TERMS_VERSION

func accept_online_terms() -> void :
	online_terms_accepted = true
	online_terms_version = ONLINE_TERMS_VERSION
	_save_settings()




func flush_saves() -> void :
	_save_settings()
	if has_node("/root/ProfileStore"):
		get_node("/root/ProfileStore").capture_character()
	if has_node("/root/Career"):
		get_node("/root/Career").save_now()

func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		flush_saves()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_app_focused = what == NOTIFICATION_APPLICATION_FOCUS_IN
		apply_frame_cap()





func _save_settings() -> void :
	var data: = {
		"audio": {
			"master": master_volume, "sfx": sfx_volume, "crowd": crowd_volume, 
			"music": music_volume, "ambient": ambient_volume, 
		}, 
		"game": {
			"crowd_enabled": crowd_enabled, "voice_enabled": voice_enabled,
			"quick_chat_voices": quick_chat_voices,
			"dark_theme": dark_theme, "tutorial_seen": tutorial_seen,
			"language": language,
			"online_terms_accepted": online_terms_accepted,
			"online_terms_version": online_terms_version, 
			"aim_assist": aim_assist, "set_assist": set_assist, "set_preview": set_preview, 
			"hardware_cursor": hardware_cursor, 
			"sprint_toggle": sprint_toggle, 
			"sprint_double_tap": sprint_double_tap, 
			"show_own_name": show_own_name, "touch_highlight": touch_highlight, 
			"hide_names_in_rally": hide_names_in_rally, "hide_titles_in_rally": hide_titles_in_rally, 
			"split_pref": int(split_pref), 
			"camera_shake": camera_shake, "camera_fov_fx": camera_fov_fx, "rumble": rumble, 
			"aim_color_cue": aim_color_cue, 
			"crosshair_shape": crosshair_shape, 
			"crosshair_custom": crosshair_custom, 
			"crosshair_color": crosshair_color.to_html(), 
			"crosshair_outline": crosshair_outline.to_html(), 
			"crosshair_size": crosshair_size, 
			"crosshair_ring": crosshair_ring, 
			"mouse_sensitivity": mouse_sensitivity, 
			"stick_sensitivity": stick_sensitivity, "stage": stage, 
			"invert_cam_x": invert_cam_x, "invert_cam_y": invert_cam_y, 
			"chat_enabled": chat_enabled, "chat_w": chat_w, "chat_h": chat_h, 
			"chat_filter": chat_filter, "chat_bubbles": chat_bubbles, 
			"pad_when_unfocused": pad_when_unfocused, 
			"fade_scoreboard": fade_scoreboard, 
			"chat_collapsed": chat_collapsed, "reach_marker": reach_marker, 
			"show_control_hints": show_control_hints, 
			"power_cap": power_cap, "power_keys": power_keys, 
			"replay_capture": replay_capture, "art_style": int(art_style), 
			"default_camera": default_camera, "difficulty": difficulty, 
			"menu_outfit": menu_outfit, "menu_ball": menu_ball, 
			"freeplay_stage": freeplay_stage, "studio_dir": studio_dir, 
		}, 
		"video": {
			"window_mode": int(window_mode), "vsync": vsync, 
			"max_fps": max_fps, "background_fps": background_fps, 
			"show_fps": show_fps, "resolution_3d": resolution_3d, 
			"reflections": reflections, 
			"bloom": bloom, "grass": grass, "hair_physics": hair_physics, 
			"floor_sunlight": floor_sunlight, "court_dome": court_dome, 
			"camera_occlusion": camera_occlusion, 
			"window_w": window_size.x, "window_h": window_size.y, "msaa": msaa, 
			"shadows": shadows, 
			"window_user_sized": window_user_sized, 
		}, 
		"debug": {
			"menu": debug_menu, 


			"net_log": debug_net_log, "predict_contacts": predict_contacts, 
		}, 
	}
	AppData.write_safely(_settings_path, JSON.stringify(data, "\t"))
	settings_saved.emit()








const QUALITY: = [
	{"shadows": 0, "reflections": false, "bloom": false, "grass": false, "hair_physics": false, 
		"floor_sunlight": false, "court_dome": false}, 
	{"shadows": 1, "reflections": false, "bloom": false, "grass": true, "hair_physics": true, 
		"floor_sunlight": true, "court_dome": true}, 
	{"shadows": 2, "reflections": true, "bloom": true, "grass": true, "hair_physics": true, 
		"floor_sunlight": true, "court_dome": true}, 
]
const QUALITY_MEDIUM: = 1
const QUALITY_LOW: = 0

func apply_quality(i: int) -> void :
	for key in QUALITY[i]:
		set(key, QUALITY[i][key])





static func first_run_quality(deck: bool, opengl: bool) -> int:
	if deck:
		return QUALITY_MEDIUM
	if opengl:
		return QUALITY_LOW
	return -1



static func on_opengl() -> bool:
	return RenderingServer.get_current_rendering_driver_name().begins_with("opengl3")



func on_steam_deck() -> bool:
	if OS.get_environment("SteamDeck") == "1" or "--deck" in LaunchGate.dev_args():
		return true
	if not Engine.has_singleton("Steam"):
		return false
	var s: Object = Engine.get_singleton("Steam")
	return s.has_method("isSteamRunningOnSteamDeck") and bool(s.isSteamRunningOnSteamDeck())

func _load_settings() -> void :

	var parsed: Variant = AppData.read_json(_settings_path)
	if not (parsed is Dictionary):
		if not FileAccess.file_exists(_settings_path + ".bak"):
			var had_old: = FileAccess.file_exists("user://settings.cfg")
			_migrate_settings_cfg()



			var first: = first_run_quality(on_steam_deck(), on_opengl())
			if not had_old and first >= 0:
				apply_quality(first)
		return
	var data: Dictionary = parsed
	var audio: Dictionary = data.get("audio", {})
	var game: Dictionary = data.get("game", {})
	var video: Dictionary = data.get("video", {})
	var dbg: Dictionary = data.get("debug", {})
	master_volume = float(audio.get("master", 1.0))
	sfx_volume = float(audio.get("sfx", 1.0))
	crowd_volume = float(audio.get("crowd", 1.0))
	music_volume = float(audio.get("music", 0.2))
	ambient_volume = float(audio.get("ambient", 0.7))
	crowd_enabled = bool(game.get("crowd_enabled", true))
	voice_enabled = bool(game.get("voice_enabled", true))
	quick_chat_voices = bool(game.get("quick_chat_voices", true))
	dark_theme = bool(game.get("dark_theme", false))
	UiStyle.dark = dark_theme
	language = String(game.get("language", "en"))
	if "--dark" in LaunchGate.dev_args():
		UiStyle.dark = true
	tutorial_seen = bool(game.get("tutorial_seen", false))


	if AppData.did_wipe:
		tutorial_seen = false
	online_terms_accepted = bool(game.get("online_terms_accepted", false))
	online_terms_version = int(game.get("online_terms_version", 0))
	aim_assist = bool(game.get("aim_assist", false))
	set_assist = bool(game.get("set_assist", false))
	set_preview = bool(game.get("set_preview", false))
	sprint_toggle = bool(game.get("sprint_toggle", false))
	sprint_double_tap = bool(game.get("sprint_double_tap", true))
	hardware_cursor = bool(game.get("hardware_cursor", false))
	show_own_name = bool(game.get("show_own_name", false))
	hide_names_in_rally = bool(game.get("hide_names_in_rally", false))
	hide_titles_in_rally = bool(game.get("hide_titles_in_rally", false))
	split_pref = clampi(int(game.get("split_pref", SplitPref.VERTICAL_WHEN_POSSIBLE)), 
		0, 1) as SplitPref
	touch_highlight = bool(game.get("touch_highlight", true))
	camera_shake = bool(game.get("camera_shake", true))
	camera_fov_fx = bool(game.get("camera_fov_fx", true))
	rumble = bool(game.get("rumble", true))
	aim_color_cue = bool(game.get("aim_color_cue", true))
	crosshair_shape = String(game.get("crosshair_shape", "line_cross"))
	crosshair_custom = bool(game.get("crosshair_custom", false))
	crosshair_color = Color(String(game.get("crosshair_color", "ffffff")))
	crosshair_outline = Color(String(game.get("crosshair_outline", "0d0d14")))
	crosshair_size = clampf(float(game.get("crosshair_size", 4.0)), 1.0, 8.0)
	crosshair_ring = bool(game.get("crosshair_ring", true))
	mouse_sensitivity = clampf(float(game.get("mouse_sensitivity", 1.0)), 0.25, 3.0)
	stick_sensitivity = clampf(float(game.get("stick_sensitivity", 1.0)), 0.25, 3.0)
	invert_cam_x = bool(game.get("invert_cam_x", false))
	invert_cam_y = bool(game.get("invert_cam_y", false))
	stage = Stage.saved_pick(String(game.get("stage", Stage.home())))
	chat_enabled = bool(game.get("chat_enabled", true))
	chat_filter = bool(game.get("chat_filter", true))
	pad_when_unfocused = bool(game.get("pad_when_unfocused", false))
	fade_scoreboard = bool(game.get("fade_scoreboard", false))
	chat_bubbles = bool(game.get("chat_bubbles", true))
	chat_w = float(game.get("chat_w", 300.0))
	chat_h = float(game.get("chat_h", 160.0))
	chat_collapsed = bool(game.get("chat_collapsed", false))
	reach_marker = bool(game.get("reach_marker", true))
	show_control_hints = bool(game.get("show_control_hints", true))
	replay_capture = bool(game.get("replay_capture", true))
	art_style = int(game.get("art_style", ArtStyle.CEL_CLASSIC))


	default_camera = clampi(int(game.get("default_camera", 1)), 0, 3)
	difficulty = int(game.get("difficulty", 1))
	menu_outfit = String(game.get("menu_outfit", "gym"))
	menu_ball = String(game.get("menu_ball", "nationals"))
	freeplay_stage = String(game.get("freeplay_stage", Stage.home()))
	studio_dir = String(game.get("studio_dir", ""))

	power_cap = clampi(int(game.get("power_cap", POWER_MAX)), POWER_CAP_MIN, POWER_MAX)
	power_keys = []
	var pk: Variant = game.get("power_keys", [])
	if pk is Array:
		for ent in pk:
			if not (ent is Dictionary) or not ent.has("c"):
				continue
			power_keys.append({
				"t": String(ent.get("t", "key")), 
				"c": int(ent.get("c", 0)), 
				"pow": clampi(int(ent.get("pow", 0)), 1, POWER_MAX), 
			})
	ensure_power_keys()
	window_mode = int(video.get("window_mode", WindowMode.WINDOWED)) as WindowMode
	vsync = bool(video.get("vsync", true))
	max_fps = int(video.get("max_fps", 60))
	background_fps = maxi(int(video.get("background_fps", 10)), 0)
	show_fps = bool(video.get("show_fps", false))


	resolution_3d = int(video.get("resolution_3d", 100))
	reflections = bool(video.get("reflections", true))
	bloom = bool(video.get("bloom", true))
	camera_occlusion = bool(video.get("camera_occlusion", true))
	hair_physics = bool(video.get("hair_physics", true))
	grass = bool(video.get("grass", true))
	window_size = Vector2i(int(video.get("window_w", WINDOWED_SIZE.x)), 
		int(video.get("window_h", WINDOWED_SIZE.y)))
	window_user_sized = bool(video.get("window_user_sized", false))
	msaa = int(video.get("msaa", 0))
	shadows = clampi(int(video.get("shadows", 2)), 0, 2)



	var was_low: = shadows == 0 and not reflections and not bloom and not grass\
	and not hair_physics
	floor_sunlight = bool(video.get("floor_sunlight", not was_low))
	court_dome = bool(video.get("court_dome", not was_low))
	debug_menu = bool(dbg.get("menu", false))
	show_cam_debug = false
	debug_net_log = bool(dbg.get("net_log", false))
	predict_contacts = bool(dbg.get("predict_contacts", true))




	if LaunchGate.public_beta() or not OS.has_feature("editor"):
		debug_menu = false
		show_cam_debug = false
		debug_net_log = false



func _migrate_settings_cfg() -> void :
	var cfg: = ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	master_volume = cfg.get_value("audio", "master", 1.0)
	sfx_volume = cfg.get_value("audio", "sfx", 1.0)
	crowd_volume = cfg.get_value("audio", "crowd", 1.0)
	music_volume = cfg.get_value("audio", "music", 0.2)
	ambient_volume = cfg.get_value("audio", "ambient", 0.7)
	crowd_enabled = cfg.get_value("game", "crowd_enabled", true)
	voice_enabled = cfg.get_value("game", "voice_enabled", true)
	quick_chat_voices = cfg.get_value("game", "quick_chat_voices", true)
	tutorial_seen = bool(cfg.get_value("game", "tutorial_seen", false))
	aim_assist = cfg.get_value("game", "aim_assist", false)
	set_assist = bool(cfg.get_value("game", "set_assist", false))
	set_preview = bool(cfg.get_value("game", "set_preview", false))
	sprint_toggle = cfg.get_value("game", "sprint_toggle", false)
	sprint_double_tap = bool(cfg.get_value("game", "sprint_double_tap", true))
	hardware_cursor = cfg.get_value("game", "hardware_cursor", false)
	show_own_name = cfg.get_value("game", "show_own_name", false)
	touch_highlight = cfg.get_value("game", "touch_highlight", true)
	camera_shake = cfg.get_value("game", "camera_shake", true)
	camera_fov_fx = bool(cfg.get_value("game", "camera_fov_fx", true))
	invert_cam_x = bool(cfg.get_value("game", "invert_cam_x", false))
	invert_cam_y = bool(cfg.get_value("game", "invert_cam_y", false))
	aim_color_cue = bool(cfg.get_value("game", "aim_color_cue", true))
	stage = Stage.saved_pick(String(cfg.get_value("game", "stage", Stage.home())))
	chat_enabled = bool(cfg.get_value("game", "chat_enabled", true))
	chat_filter = bool(cfg.get_value("game", "chat_filter", true))
	fade_scoreboard = bool(cfg.get_value("game", "fade_scoreboard", false))
	chat_bubbles = bool(cfg.get_value("game", "chat_bubbles", true))
	chat_w = float(cfg.get_value("game", "chat_w", 300.0))
	chat_h = float(cfg.get_value("game", "chat_h", 160.0))
	chat_collapsed = bool(cfg.get_value("game", "chat_collapsed", false))
	reach_marker = cfg.get_value("game", "reach_marker", true)
	replay_capture = cfg.get_value("game", "replay_capture", true)
	art_style = cfg.get_value("game", "art_style", ArtStyle.CEL_CLASSIC)
	default_camera = clampi(int(cfg.get_value("game", "default_camera", 1)), 0, 3)
	difficulty = cfg.get_value("game", "difficulty", 1)
	window_mode = int(cfg.get_value("video", "window_mode", WindowMode.WINDOWED)) as WindowMode
	vsync = cfg.get_value("video", "vsync", true)
	show_fps = cfg.get_value("video", "show_fps", false)
	resolution_3d = 100
	reflections = cfg.get_value("video", "reflections", true)
	bloom = cfg.get_value("video", "bloom", true)
	hair_physics = cfg.get_value("video", "hair_physics", true)
	grass = bool(cfg.get_value("video", "grass", true))

	debug_menu = cfg.get_value("debug", "menu", false) and OS.has_feature("editor")
	show_cam_debug = false
	debug_net_log = cfg.get_value("debug", "net_log", false) and OS.has_feature("editor")
	predict_contacts = cfg.get_value("debug", "predict_contacts", true)
	_save_settings()
	DirAccess.remove_absolute("user://settings.cfg")

var team_size: = 2



var pre_tutorial_settings: = {}
var court_half_width: = 4.5
var court_half_length: = 9.0
var set_points: = 7
var sets_to_win: = 2
var win_by_two: = true





var sweat_enabled: = false
var sweat_rate: = 1.0




var instant_replays: = true


var team_collision: = true



var serve_seconds: = 15


const POWER_MAX: = 16
const POWER_CAP_MIN: = 3
const POWER_KEYS_DEFAULT: = [
	{"t": "key", "c": KEY_Z, "pow": 3}, 
	{"t": "key", "c": KEY_X, "pow": 10}, 
	{"t": "key", "c": KEY_C, "pow": 16}, 
]
var power_cap: = POWER_MAX
var power_keys: Array = []
var menu_open: = false
var menu_practice: = false

func ensure_power_keys() -> void :
	if power_keys.is_empty():
		power_keys = POWER_KEYS_DEFAULT.duplicate(true)

func power_disp_level(disp: int) -> int:
	var d: int = clampi(disp, 1, power_cap)
	if power_cap >= POWER_MAX:
		return d
	return clampi(1 + roundi(float(d - 1) * float(POWER_MAX - 1) / float(power_cap - 1)), 
		1, POWER_MAX)

func power_disp_of(internal: int) -> int:
	var lvl: int = clampi(internal, 1, POWER_MAX)
	if power_cap >= POWER_MAX:
		return lvl
	return clampi(1 + roundi((float(lvl) - 1.0) / float(POWER_MAX - 1) * float(power_cap - 1)), 
		1, power_cap)



var ball_hints: = true


var match_intro: = true




var lock_teams: = false



var rotate_every_point: = false


var local_side: = 1
var crowd_enabled: = true
var voice_enabled: = true



var quick_chat_voices: = true


var dark_theme: = false




var debug_menu: = false




var dev_tools: = OS.has_feature("editor")


var review_replay_path: = ""



var review_seek_t: = 0.0



var review_chat: = ""


var debug_net_log: = false


var predict_contacts: = true


var lobby_notice: = ""



var menu_return_local: = false


var lobby_page: = ""



var menu_outfit: = "gym"



var studio_dir: = ""


var menu_ball: = "nationals"
var freeplay_stage: = Stage.home()


const VERSION: = "0.9.6"


var show_cam_debug: = false



var no_cooldowns: = false


var spike_hitstop: = true



var simple_bot_serves: = false


var tutorial_finale: = false



var debug_serve_zones: = false








var onboarding_active: = false
var onboarding_seen: = false



var tutorial_seen: = false




const ONLINE_TERMS_VERSION: = 3
var online_terms_accepted: = false
var online_terms_version: = 0





const NOTICES_FILE: = "notices.json"
var _notices: Variant = null

func notice_dismissed(id: String) -> bool:
	return bool(_notices_dict().get(id, false))

func dismiss_notice(id: String) -> void :
	_notices_dict()[id] = true
	AppData.write_safely(AppData.path(NOTICES_FILE), JSON.stringify(_notices, "\t"))

func _notices_dict() -> Dictionary:
	if not (_notices is Dictionary):
		var d: Variant = AppData.read_json(AppData.path(NOTICES_FILE))
		_notices = d if d is Dictionary else {}
	return _notices
var aim_assist: = false






var set_assist: = false


var set_preview: = false





func set_arc_on() -> bool:
	return set_preview and not LaunchGate.public_beta()



var sprint_toggle: = false



var sprint_double_tap: = true




var hardware_cursor: = false


var show_own_name: = false





var hide_names_in_rally: = false
var hide_titles_in_rally: = false







enum SplitPref{VERTICAL_WHEN_POSSIBLE, SHARED_WHEN_POSSIBLE}
var split_pref: = SplitPref.VERTICAL_WHEN_POSSIBLE



var touch_highlight: = true
var camera_shake: = true


var camera_fov_fx: = true

var camera_shake_preset: = 2
func camera_shake_multiplier(preset: = -1) -> float:
	var choice: int = camera_shake_preset if preset < 0 else preset
	return [1.0, 0.5, 0.25][clampi(choice, 0, 2)]
var rumble: = true
var aim_color_cue: = true



var crosshair_shape: = "line_cross"
var crosshair_custom: = false
var crosshair_color: = Color(1, 1, 1)
var crosshair_outline: = Color(0.05, 0.05, 0.08)
var crosshair_size: = 4.0
var crosshair_ring: = true


var mouse_sensitivity: = 1.0
var stick_sensitivity: = 1.0


var invert_cam_x: = false
var invert_cam_y: = false

var chat_enabled: = true
var chat_filter: = true


var pad_when_unfocused: = false:
	set(v):
		pad_when_unfocused = v
		apply_pad_focus()




func apply_pad_focus() -> void :
	Input.set_ignore_joypad_on_unfocused_application(
		not (pad_when_unfocused or InputCollector.dev_assume_focus))

var fade_scoreboard: = false
var chat_bubbles: = true
var chat_w: = 300.0
var chat_h: = 160.0
var chat_collapsed: = false


var stage: = Stage.home()



var stage_barefoot: = false



var stage_reflections: = true

func reflections_live(n: Node = null) -> bool:
	return reflections and world_flag(n, "stage_reflections", stage_reflections)












func view_idle(n: Node) -> bool:
	if n == null or not n.is_inside_tree():
		return false
	var vp: = n.get_viewport()
	if vp == null:
		return false
	if vp.disable_3d:
		return true
	return vp is SubViewport\
	and (vp as SubViewport).render_target_update_mode == SubViewport.UPDATE_DISABLED

func world_flag(n: Node, key: String, fallback: bool) -> bool:
	if n != null and n.is_inside_tree():
		var vp: = n.get_viewport()
		if vp != null and vp.has_meta(key):
			return bool(vp.get_meta(key))
	return fallback

func barefoot_for(n: Node) -> bool:
	return world_flag(n, "stage_barefoot", stage_barefoot)

func team_collision_for(n: Node) -> bool:
	return world_flag(n, "team_collision", team_collision)




var reach_marker: = true


var show_control_hints: = true
var replay_capture: = true







enum WindowMode{WINDOWED, BORDERLESS, FULLSCREEN}
var window_mode: = WindowMode.WINDOWED
var vsync: = true
var bloom: = true



var hair_physics: = true



const ViewClear: = preload("res://game/fx/view_clear.gd")
var camera_occlusion: = true:
	set(v):
		camera_occlusion = v
		ViewClear.set_shaders(v)
var net_see_through: = true


var grass: = true
var max_fps: = 60


var background_fps: = 10
var _app_focused: = true
var show_fps: = false






const RESOLUTION_3D_MIN: = 25
var resolution_3d: = 100:
	set(v):
		resolution_3d = clampi(v, RESOLUTION_3D_MIN, 100)
		render_scale = resolution_3d / 100.0
var render_scale: = 1.0
var reflections: = true




var floor_sunlight: = true
var court_dome: = true



var msaa: = 0



var shadows: = 2


const MSAA_2D: = Viewport.MSAA_4X






const WINDOWED_SIZE: = Vector2i(1600, 900)



var window_size: = WINDOWED_SIZE




var window_user_sized: = false

const DEV_WINDOW: = "res://game/dev/dev_window.gd"

const TRANSLATION_FILES: = ["res://game/translations/translations.en.translation", "res://game/translations/translations.uk.translation"]

func apply_language() -> void :
	var loc: = "uk" if language == "uk" else "en"
	TranslationServer.set_locale(loc)
	var d: = TranslationServer.get_or_add_domain("main")
	for p in TRANSLATION_FILES:
		if not ResourceLoader.exists(p):
			continue
		var t: = load(p)
		if t != null and not d.get_translations().has(t):
			d.add_translation(t)
	d.set_locale_override(loc)


const POWER_BAR_PLAYERS: = "power_bar_players"
const POWER_FILL: = Color(0.95, 0.8, 0.15, 0.95)
const POWER_FILL_MAX: = Color(0.25, 0.5, 1.0, 0.95)
const POWER_EMPTY: = Color(0.0, 0.0, 0.0, 0.4)

var _power_bar_layer: CanvasLayer = null
var _power_bar_cells: Array = []
var _power_bar_label: Label = null

func _build_power_bar() -> void :
	_power_bar_layer = CanvasLayer.new()
	_power_bar_layer.layer = 50
	_power_bar_layer.visible = false
	add_child(_power_bar_layer)
	var panel: = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.offset_bottom = - 24.0
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.0, 0.0, 0.0, 0.45)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", sb)
	_power_bar_layer.add_child(panel)
	var box: = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	_power_bar_label = Label.new()
	_power_bar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_power_bar_label.add_theme_font_size_override("font_size", 18)
	box.add_child(_power_bar_label)
	var row: = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 5)
	box.add_child(row)
	for i in 16:
		var cell: = ColorRect.new()
		cell.custom_minimum_size = Vector2(26, 38)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(cell)
		_power_bar_cells.append(cell)

func _active_power_player() -> Node:
	for p in get_tree().get_nodes_in_group(POWER_BAR_PLAYERS):
		if p == null or not is_instance_valid(p):
			continue
		if bool(p.get("is_bot")) or bool(p.get("net_puppet")):
			continue
		if p.get("ball") != null:
			return p
	return null

func _update_power_bar() -> void :
	if _power_bar_layer == null:
		return
	if menu_open and not menu_practice:
		_power_bar_layer.visible = false
		return
	var p: = _active_power_player()
	_power_bar_layer.visible = p != null
	if p == null:
		return
	var lvl: int = int(p.get("power_level"))
	var disp: = power_disp_of(lvl)
	var wheel: = 0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		wheel = 1
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		wheel = - 1
	if wheel != 0:
		disp = clampi(disp + wheel, 1, power_cap)
		lvl = power_disp_level(disp)
		p.set("power_level", lvl)
	for i in 16:
		var cell: ColorRect = _power_bar_cells[i]
		cell.visible = i < power_cap
		if not cell.visible:
			continue
		var on: = i < disp
		var col: = POWER_FILL_MAX if i == power_cap - 1 else POWER_FILL
		cell.color = col if on else POWER_EMPTY
	_power_bar_label.text = "power %d / %d" % [disp, power_cap]


func apply_display() -> void :
	if OS.has_feature("mobile"):
		DisplayServer.screen_set_keep_on(true)
		apply_frame_cap()
		return




	if AppData.is_harness() and not LaunchGate.dev_args().has("--window"):



		if not "--position" in OS.get_cmdline_args() and ResourceLoader.exists(DEV_WINDOW):
			(load(DEV_WINDOW) as GDScript).place()
		return


	var uargs: = LaunchGate.dev_args()
	var wat: = uargs.find("--window")
	if wat >= 0 and wat + 1 < uargs.size():
		var wh: = String(uargs[wat + 1]).split("x")
		if wh.size() == 2:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var forced: = Vector2i(int(wh[0]), int(wh[1]))
			_last_applied_size = forced
			DisplayServer.window_set_size(forced)
			return
	match window_mode:
		WindowMode.WINDOWED:






			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var screen: = DisplayServer.window_get_current_screen()
			var usable: = DisplayServer.screen_get_usable_rect(screen)



			var want: = window_size if window_user_sized else usable.size
			var size: = Vector2i(
				mini(want.x, usable.size.x - 80), 
				mini(want.y, usable.size.y - 80))



			_last_applied_size = size
			DisplayServer.window_set_size(size)
			DisplayServer.window_set_position(
				usable.position + (usable.size - size) / 2)


			window_size = size



			window_user_sized = true
		WindowMode.BORDERLESS:


			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var screen: = DisplayServer.window_get_current_screen()
			DisplayServer.window_set_position(
				DisplayServer.screen_get_position(screen))
			DisplayServer.window_set_size(DisplayServer.screen_get_size(screen))
		WindowMode.FULLSCREEN:








			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync
		else DisplayServer.VSYNC_DISABLED)


	apply_frame_cap()








func _frame_cap() -> int:
	var net: = get_node_or_null("/root/Net")
	if _app_focused or background_fps <= 0 or AppData.is_harness()\
	or (net != null and bool(net.active) and bool(net.is_host)):
		return max_fps
	return background_fps if max_fps == 0 else mini(max_fps, background_fps)

func apply_frame_cap() -> void :
	Engine.max_fps = _frame_cap()


	set_process( not _app_focused)

func _process(_delta: float) -> void :
	var cap: = _frame_cap()
	if Engine.max_fps != cap:
		Engine.max_fps = cap

const ROOT_LIKE_VIEWS: = &"root_like_view"

func apply_render_scale() -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return


	render_scale = resolution_3d / 100.0
	tree.root.scaling_3d_scale = render_scale
	tree.root.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR



	for vp in tree.get_nodes_in_group(ROOT_LIKE_VIEWS):
		(vp as Viewport).scaling_3d_scale = render_scale
		(vp as Viewport).scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR


	tree.call_group(&"contour_rigs", "sync_res_scale")





var _compat: = -1
func is_compatibility() -> bool:
	if _compat < 0:
		_compat = 1 if RenderingServer.get_rendering_device() == null else 0
	return _compat == 1






func compat_alpha(a: float) -> float:
	if not is_compatibility():
		return a
	return 1.0 - pow(1.0 - clampf(a, 0.0, 1.0), 1.0 / 2.4)









const SHADOW_STENCIL: = 1



const BODY_STENCIL_IDS: = 6
const BALL_STENCIL: = 7

func stencil_mark_body(root: Node, ref: = SHADOW_STENCIL) -> void :
	if root == null:
		return
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var gi: = n as GeometryInstance3D
		var mats: Array = [gi.material_override, gi.material_overlay]
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
			var mi: = gi as MeshInstance3D
			for s in mi.mesh.get_surface_count():
				mats.append(mi.get_active_material(s))
		for m in mats:
			var bm: = m as BaseMaterial3D

			if bm == null or bm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				continue
			bm.stencil_mode = BaseMaterial3D.STENCIL_MODE_CUSTOM
			bm.stencil_flags = BaseMaterial3D.STENCIL_FLAG_WRITE
			bm.stencil_compare = BaseMaterial3D.STENCIL_COMPARE_ALWAYS
			bm.stencil_reference = ref

func stencil_shadow(mat: BaseMaterial3D) -> void :
	if mat == null:
		return
	mat.stencil_mode = BaseMaterial3D.STENCIL_MODE_CUSTOM
	mat.stencil_flags = BaseMaterial3D.STENCIL_FLAG_READ
	mat.stencil_compare = BaseMaterial3D.STENCIL_COMPARE_EQUAL
	mat.stencil_reference = 0









const STAGE_WORLD: = "jv_stage_world"
var body_tint: = Vector3.ONE

func in_stage_world(n: Node) -> bool:
	var p: = n.get_parent() if n != null else null
	while p != null:
		if p is Viewport:
			return false
		if p.has_meta(STAGE_WORLD):
			return true
		p = p.get_parent()
	return false





func world_light(root: Node, props: = false) -> void :
	if root == null or not root.is_inside_tree() or not in_stage_world(root):
		return
	root.add_to_group(STAGE_WORLD)
	if props:
		root.set_meta("jv_light_props", true)
	props = props or root.has_meta("jv_light_props")
	var t: = Color(body_tint.x, body_tint.y, body_tint.z).linear_to_srgb()
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var gi: = n as GeometryInstance3D
		var mats: Array = [gi.material_override, gi.material_overlay]
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null:
			var mi: = gi as MeshInstance3D
			for s in mi.mesh.get_surface_count():
				mats.append(mi.get_active_material(s))
		for m in mats:



			if m == null or ((m as Material).resource_path != "" and not props):
				continue
			if m is ShaderMaterial:
				(m as ShaderMaterial).set_shader_parameter("world_lit", 1.0)
			elif m is StandardMaterial3D:
				var sm: = m as StandardMaterial3D


				if (sm.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED and not props) or \
				(sm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED\
				and sm.albedo_texture == null):
					continue
				if not sm.has_meta("jv_albedo"):
					sm.set_meta("jv_albedo", sm.albedo_color)
				var base: Color = sm.get_meta("jv_albedo")
				sm.albedo_color = Color(base.r * t.r, base.g * t.g, base.b * t.b, base.a)



func compat_dim(mat: BaseMaterial3D) -> void :
	if mat == null or not is_compatibility() or mat.has_meta("compat_dimmed"):
		return
	mat.albedo_color.a = compat_alpha(mat.albedo_color.a)
	mat.set_meta("compat_dimmed", true)









func _ui_mips(node: Node) -> void :
	if node is TextureRect or node is TextureButton:
		var ci: = node as CanvasItem
		if ci.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE:
			ci.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			ci.set_meta("ui_mips", true)
	elif node is Label or node is RichTextLabel or node is Button:
		var ci: = node as CanvasItem
		if ci.texture_filter != CanvasItem.TEXTURE_FILTER_PARENT_NODE:
			return
		var up: = node.get_parent()
		while up is CanvasItem:
			if up.has_meta("ui_mips"):
				ci.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				return
			if (up as CanvasItem).texture_filter != CanvasItem.TEXTURE_FILTER_PARENT_NODE:
				return
			up = up.get_parent()

func apply_msaa() -> void :


	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	tree.root.msaa_3d = clampi(msaa, 0, 3) as Viewport.MSAA




	tree.root.msaa_2d = MSAA_2D if root_ui_aa else Viewport.MSAA_DISABLED






var root_ui_aa: = true
var difficulty: = 1


var local_cpus: Dictionary = {}
var net_roster: Array = []

func difficulty_aim_mult(level: = -1) -> float:
	return [1.7, 1.0, 0.55][difficulty if level < 0 else level]

func difficulty_think_mult(level: = -1) -> float:
	return [1.5, 1.0, 0.7][difficulty if level < 0 else level]










const DEMO_TEAM_SIZES: = [1, 2, 3, 4, 5, 6]
const ALL_TEAM_SIZES: = [1, 2, 3, 4, 5, 6]

func team_sizes() -> Array:
	return DEMO_TEAM_SIZES if LaunchGate.is_demo() else ALL_TEAM_SIZES


func legal_team_size(n: int) -> int:
	for s in team_sizes():
		if int(s) >= n:
			return int(s)
	return int(team_sizes().back())


func step_team_size(n: int, dir: int) -> int:
	var list: = team_sizes()
	var at: = list.find(legal_team_size(n))
	return int(list[clampi(at + dir, 0, list.size() - 1)])





func modifiers_allowed() -> bool:
	return not LaunchGate.is_demo()

func force_standard_modifiers() -> void :
	sweat_enabled = false
	sweat_rate = 1.0
	instant_replays = true
	team_collision = true
	serve_seconds = 15
	ball_hints = true
	lock_teams = false
	rotate_every_point = false
	match_intro = true

func set_mode(size: int) -> void :
	size = legal_team_size(size)











	team_size = size
	var d: = court_dims(size)
	court_half_width = d.x
	court_half_length = d.y



static func court_dims(size: int) -> Vector2:
	if size >= 6:

		return Vector2(7.6, 13.6)
	elif size >= 4:
		return Vector2(7.0, 12.8)
	elif size <= 1:



		return Vector2(4.0, 8.4)
	elif size == 3:




		return Vector2(5.6, 11.0)
	else:
		return Vector2(5.1, 10.2)
