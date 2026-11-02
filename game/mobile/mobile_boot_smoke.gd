extends Node

# Activated only by the CI simulator environment, never during normal play.
const MENU := "res://game/ui/menu.tscn"
var _phase := 0
var _frames := 0
var _started := 0
var _run_id := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_started = Time.get_ticks_msec()
	_run_id = "%s-%s" % [Time.get_unix_time_from_system(), _started]
	_write("starting")

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - _started > 180000:
		_fail("startup or settings timed out")
		return
	var menu := get_tree().current_scene
	if menu == null or menu.scene_file_path != MENU or not menu.is_node_ready():
		return
	_frames += 1
	if _phase == 0 and _frames >= 60:
		if menu.player == null or menu._arena_nodes.is_empty():
			_fail("menu did not build a player and arena")
			return
		menu._open_settings(SettingsPanel.Scope.SYSTEM)
		_phase = 1
		_frames = 0
		_write("settings_opened")
	elif _phase == 1 and _frames >= 30:
		if not menu._settings.is_visible_in_tree():
			_fail("settings did not open")
			return
		menu._settings_back()
		_phase = 2
		_frames = 0
		_write("settings_back")
	elif _phase == 2 and _frames >= 120:
		if menu._settings.is_visible_in_tree() or get_tree().paused:
			_fail("settings back did not restore an active menu")
			return
		if GameConfig.onboarding_active or menu._practice_prewarm:
			_fail("desktop startup prewarming is active on mobile")
			return
		_write("passed")
		print("MOBILE BOOT SMOKE PASSED: menu -> settings -> back")
		set_process(false)

func _write(phase: String, error := "") -> void:
	var profile := ProfileStore.active()
	var file := FileAccess.open("user://mobile-smoke.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"phase": phase, "error": error, "run_id": _run_id,
			"profile": profile.uid if profile != null else "", "fresh": ProfileStore.seeded_fresh,
			"elapsed_ms": Time.get_ticks_msec() - _started}))
		file.close()

func _fail(error: String) -> void:
	_write("failed", error)
	push_error("MOBILE BOOT SMOKE FAILED: " + error)
	set_process(false)
