class_name SavedProfile
extends RefCounted














const NAME_MAX: = 10

var name: = "Player"


var aim_assist: = false
var set_assist: = false
var sprint_toggle: = false
var sprint_double_tap: = true
var hardware_cursor: = false
var mouse_sensitivity: = 1.0
var stick_sensitivity: = 1.0
var invert_cam_x: = false
var invert_cam_y: = false
var rumble: = true
var default_camera: = 1


var camera_shake: = true
var camera_fov_fx: = true
var camera_shake_preset: = 2
var aim_color_cue: = true
var touch_highlight: = true
var reach_marker: = true
var show_control_hints: = true
var show_own_name: = false
var hide_names_in_rally: = false
var hide_titles_in_rally: = false
var chat_enabled: = true
var chat_bubbles: = true

var crosshair_shape: = "line_cross"
var crosshair_custom: = false
var crosshair_color: = Color(1, 1, 1)
var crosshair_outline: = Color(0.05, 0.05, 0.08)
var crosshair_size: = 4.0
var crosshair_ring: = true


var menu_outfit: = "gym"
var menu_ball: = "nationals"





var stats: = {}





const MATCH_HISTORY_MAX: = 50
var match_history: Array = []





var xp: = 0
var level: = 1
var coins: = 0



var owned: = {}

var spacewar_coins: = false




var title: = {}








var character: = {}
var character_slots: Array = []





var achievements: = {}






var bindings: = {}




var uid: = ""

const SEALED: = ["xp", "level", "coins", "owned", "stats", "achievements"]





var unverified: = false

func _init() -> void :
	uid = Crypto.new().generate_random_bytes(8).hex_encode()


func sealed_values() -> Dictionary:
	var d: = to_dict()
	var out: = {}
	for k in SEALED:
		out[k] = d[k]
	if unverified:
		out["uv"] = true
	return out


static func clean_name(raw: String) -> String:
	var n: = raw.strip_edges()
	if n.length() > NAME_MAX:
		n = n.substr(0, NAME_MAX)
	return n if n != "" else "Player"

func set_name(raw: String) -> void :
	name = clean_name(raw)







func capture_from_config(cfg: Node) -> void :
	aim_assist = cfg.aim_assist
	set_assist = cfg.set_assist
	sprint_toggle = cfg.sprint_toggle
	sprint_double_tap = cfg.sprint_double_tap
	hardware_cursor = cfg.hardware_cursor
	mouse_sensitivity = cfg.mouse_sensitivity
	stick_sensitivity = cfg.stick_sensitivity
	invert_cam_x = cfg.invert_cam_x
	invert_cam_y = cfg.invert_cam_y
	rumble = cfg.rumble
	default_camera = cfg.default_camera
	camera_shake = cfg.camera_shake
	camera_fov_fx = cfg.camera_fov_fx
	camera_shake_preset = cfg.camera_shake_preset
	aim_color_cue = cfg.aim_color_cue
	touch_highlight = cfg.touch_highlight
	reach_marker = cfg.reach_marker
	show_control_hints = cfg.show_control_hints
	show_own_name = cfg.show_own_name
	hide_names_in_rally = cfg.hide_names_in_rally
	hide_titles_in_rally = cfg.hide_titles_in_rally
	chat_enabled = cfg.chat_enabled
	chat_bubbles = cfg.chat_bubbles
	crosshair_shape = cfg.crosshair_shape
	crosshair_custom = cfg.crosshair_custom
	crosshair_color = cfg.crosshair_color
	crosshair_outline = cfg.crosshair_outline
	crosshair_size = cfg.crosshair_size
	crosshair_ring = cfg.crosshair_ring
	menu_outfit = cfg.menu_outfit
	menu_ball = cfg.menu_ball

func apply_to_config(cfg: Node) -> void :
	cfg.aim_assist = aim_assist
	cfg.set_assist = set_assist
	cfg.sprint_toggle = sprint_toggle
	cfg.sprint_double_tap = sprint_double_tap
	cfg.hardware_cursor = hardware_cursor
	cfg.mouse_sensitivity = clampf(mouse_sensitivity, 0.25, 3.0)
	cfg.stick_sensitivity = clampf(stick_sensitivity, 0.25, 3.0)
	cfg.invert_cam_x = invert_cam_x
	cfg.invert_cam_y = invert_cam_y
	cfg.rumble = rumble
	cfg.default_camera = clampi(default_camera, 0, 3)
	cfg.camera_shake = camera_shake
	cfg.camera_fov_fx = camera_fov_fx
	cfg.camera_shake_preset = clampi(camera_shake_preset, 0, 2)
	cfg.aim_color_cue = aim_color_cue
	cfg.touch_highlight = touch_highlight
	cfg.reach_marker = reach_marker
	cfg.show_control_hints = show_control_hints
	cfg.show_own_name = show_own_name
	cfg.hide_names_in_rally = hide_names_in_rally
	cfg.hide_titles_in_rally = hide_titles_in_rally
	cfg.chat_enabled = chat_enabled
	cfg.chat_bubbles = chat_bubbles
	cfg.crosshair_shape = crosshair_shape
	cfg.crosshair_custom = crosshair_custom
	cfg.crosshair_color = crosshair_color
	cfg.crosshair_outline = crosshair_outline
	cfg.crosshair_size = crosshair_size
	cfg.crosshair_ring = crosshair_ring
	cfg.menu_outfit = menu_outfit
	cfg.menu_ball = menu_ball



func to_dict() -> Dictionary:
	return {
		"name": name, 
		"aim_assist": aim_assist, 
		"set_assist": set_assist, 
		"sprint_toggle": sprint_toggle, 
		"sprint_double_tap": sprint_double_tap, 
		"hardware_cursor": hardware_cursor, 
		"mouse_sensitivity": mouse_sensitivity, 
		"stick_sensitivity": stick_sensitivity, 
		"invert_cam_x": invert_cam_x, 
		"invert_cam_y": invert_cam_y, 
		"rumble": rumble, 
		"default_camera": default_camera, 
		"camera_shake": camera_shake, 
		"camera_fov_fx": camera_fov_fx, 
		"camera_shake_preset": camera_shake_preset, 
		"aim_color_cue": aim_color_cue, 
		"touch_highlight": touch_highlight, 
		"reach_marker": reach_marker, 
		"show_control_hints": show_control_hints, 
		"show_own_name": show_own_name, 
		"hide_names_in_rally": hide_names_in_rally, 
		"hide_titles_in_rally": hide_titles_in_rally, 
		"chat_enabled": chat_enabled, 
		"chat_bubbles": chat_bubbles, 
		"crosshair_shape": crosshair_shape, 
		"crosshair_custom": crosshair_custom, 
		"crosshair_color": crosshair_color.to_html(), 
		"crosshair_outline": crosshair_outline.to_html(), 
		"crosshair_size": crosshair_size, 
		"crosshair_ring": crosshair_ring, 
		"menu_outfit": menu_outfit, 
		"menu_ball": menu_ball, 
		"stats": stats, 
		"match_history": match_history, 
		"xp": xp, 
		"level": level, 
		"coins": coins, 
		"owned": owned, 
		"swc": spacewar_coins, 
		"title": title, 
		"character": character, 
		"character_slots": character_slots, 
		"achievements": achievements, 
		"bindings": bindings, 
		"uid": uid, 
	}

static func from_dict(d: Dictionary) -> SavedProfile:
	var p: = SavedProfile.new()
	p.name = SavedProfile.clean_name(String(d.get("name", "Player")))
	p.aim_assist = bool(d.get("aim_assist", false))
	p.set_assist = bool(d.get("set_assist", false))
	p.sprint_toggle = bool(d.get("sprint_toggle", false))
	p.sprint_double_tap = bool(d.get("sprint_double_tap", true))
	p.hardware_cursor = bool(d.get("hardware_cursor", false))
	p.mouse_sensitivity = clampf(float(d.get("mouse_sensitivity", 1.0)), 0.25, 3.0)
	p.stick_sensitivity = clampf(float(d.get("stick_sensitivity", 1.0)), 0.25, 3.0)
	p.invert_cam_x = bool(d.get("invert_cam_x", false))
	p.invert_cam_y = bool(d.get("invert_cam_y", false))
	p.rumble = bool(d.get("rumble", true))
	p.default_camera = clampi(int(d.get("default_camera", 1)), 0, 3)
	p.camera_shake = bool(d.get("camera_shake", true))
	p.camera_fov_fx = bool(d.get("camera_fov_fx", true))
	p.camera_shake_preset = clampi(int(d.get("camera_shake_preset", 2)), 0, 2)
	p.aim_color_cue = bool(d.get("aim_color_cue", true))
	p.touch_highlight = bool(d.get("touch_highlight", true))
	p.reach_marker = bool(d.get("reach_marker", true))
	p.show_control_hints = bool(d.get("show_control_hints", true))
	p.show_own_name = bool(d.get("show_own_name", false))
	p.hide_names_in_rally = bool(d.get("hide_names_in_rally", false))
	p.hide_titles_in_rally = bool(d.get("hide_titles_in_rally", false))
	p.chat_enabled = bool(d.get("chat_enabled", true))


	p.chat_bubbles = bool(d.get("chat_bubbles", true))
	p.crosshair_shape = String(d.get("crosshair_shape", "line_cross"))
	p.crosshair_custom = bool(d.get("crosshair_custom", false))
	p.crosshair_color = Color(String(d.get("crosshair_color", "ffffff")))
	p.crosshair_outline = Color(String(d.get("crosshair_outline", "0d0d14")))
	p.crosshair_size = clampf(float(d.get("crosshair_size", 4.0)), 1.0, 8.0)
	p.crosshair_ring = bool(d.get("crosshair_ring", true))
	p.menu_outfit = String(d.get("menu_outfit", "gym"))
	p.menu_ball = String(d.get("menu_ball", "nationals"))
	var st: Variant = d.get("stats", {})
	p.stats = st.duplicate() if st is Dictionary else {}
	var mh: Variant = d.get("match_history", [])
	p.match_history = mh.duplicate(true) if mh is Array else []
	p.xp = maxi(0, int(d.get("xp", 0)))
	p.level = clampi(int(d.get("level", 1)), 1, Progression.LEVEL_MAX)
	p.coins = maxi(0, int(d.get("coins", 0)))
	var ow: Variant = d.get("owned", {})
	p.owned = ow.duplicate() if ow is Dictionary else {}
	p.spacewar_coins = bool(d.get("swc", false))
	var tt: Variant = d.get("title", {})
	p.title = tt.duplicate() if tt is Dictionary else {}
	var ch: Variant = d.get("character", {})
	p.character = ch.duplicate() if ch is Dictionary else {}
	var sl: Variant = d.get("character_slots", [])
	p.character_slots = sl.duplicate() if sl is Array else []
	var ac: Variant = d.get("achievements", {})
	p.achievements = ac.duplicate(true) if ac is Dictionary else {}
	var bd: Variant = d.get("bindings", {})
	p.bindings = bd.duplicate(true) if bd is Dictionary else {}

	var id: Variant = d.get("uid", "")
	if id is String and String(id).length() >= 8:
		p.uid = id
	p.unverified = bool(d.get("uv", false))
	return p
