extends Node

# Activated only by the CI simulator environment, never during normal play.
const MENU := "res://game/mobile/mobile_menu.tscn"
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
		if menu._address == null or menu._name == null:
			_fail("LAN menu controls are missing")
			return
		menu._quality(30, 60)
		_phase = 1
		_frames = 0
		_write("settings_opened")
	elif _phase == 1 and _frames >= 30:
		if GameConfig.max_fps != 30 or GameConfig.resolution_3d != 60:
			_fail("economy settings did not apply")
			return
		menu._quality(60, 75)
		_phase = 2
		_frames = 0
		_write("settings_back")
	elif _phase == 2 and _frames >= 120:
		if get_tree().paused or GameConfig.max_fps != 60:
			_fail("settings did not preserve an active menu")
			return
		if GameConfig.onboarding_active:
			_fail("desktop startup prewarming is active on mobile")
			return
		_write("passed")
		print("MOBILE BOOT SMOKE PASSED: lightweight LAN menu and quality settings")
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
