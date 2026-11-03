extends Node

# Opt-in exported-build check. Disabled during normal play.
var _started := 0
var _frames := 0
var _phase := 0

func _ready() -> void:
	if OS.get_environment("VOLOBALL_DESKTOP_SMOKE") != "1":
		set_process(false)
		return
	_started = Time.get_ticks_msec()
	GameConfig.tutorial_seen = true
	GameConfig.free_mouse_harness = true
	GameConfig.background_fps = 0

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - _started > 180000:
		push_error("DESKTOP TEST FAILED: timeout")
		get_tree().quit(1)
		return
	var scene := get_tree().current_scene
	if scene == null or not scene.is_node_ready():
		return
	_frames += 1
	if _phase == 0 and scene.scene_file_path == "res://game/ui/menu.tscn" and _frames >= 180:
		if MobileControls.enabled() or scene.get("player") == null or scene.get("_card_local") == null:
			push_error("DESKTOP TEST FAILED: desktop menu missing")
			get_tree().quit(1)
			return
		get_viewport().get_texture().get_image().save_png("user://desktop-menu.png")
		printerr("DESKTOP MENU PASS")
		_phase = 1
		_frames = 0
		GameConfig.stage = "grass"
		scene._go_to_match(1)
	elif _phase == 1 and scene.scene_file_path == "res://game/main/main.tscn" and _frames >= 600:
		if MobileControls.enabled() or scene.get("player") == null or Net.active:
			push_error("DESKTOP TEST FAILED: local match missing")
			get_tree().quit(1)
			return
		get_viewport().get_texture().get_image().save_png("user://desktop-match.png")
		printerr("DESKTOP LOCAL MATCH PASS")
		_phase = 2
		_frames = 0
		GameConfig.goto_scene("res://game/ui/menu.tscn")
	elif _phase == 2 and scene.scene_file_path == "res://game/ui/menu.tscn" and _frames >= 180:
		printerr("DESKTOP RETURN MENU PASS")
		get_tree().quit()
