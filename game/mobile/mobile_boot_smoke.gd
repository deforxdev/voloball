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
	var timeout_ms := 600000 if OS.has_feature("ios") else 180000
	if Time.get_ticks_msec() - _started > timeout_ms:
		_fail("startup or settings timed out")
		return
	var menu := get_tree().current_scene
	if OS.get_environment("VOLOBALL_BOOT_SMOKE") == "match":
		_match_smoke(menu)
		return
	if menu == null or menu.scene_file_path != MENU or not menu.is_node_ready():
		return
	_frames += 1
	if _phase == 0 and _frames >= 60:
		if menu._body == null:
			_fail("mobile menu controls are missing")
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
		print("MOBILE BOOT SMOKE PASSED: separate phone menu and quality settings")
		set_process(false)

func _match_smoke(scene: Node) -> void:
	if scene == null or not scene.is_node_ready():
		return
	_frames += 1
	if _phase == 0 and scene.scene_file_path == MENU and _frames >= 30:
		_phase = 1
		_frames = 0
		_write("match_requested")
		scene._offline()
	elif _phase == 1 and scene.scene_file_path == MobileRender.MATCH:
		if scene.get("player") == null or Net.active:
			_fail("offline match did not create the player")
			return
		_phase = 2
		_frames = 0
		_write("match_running")
	elif _phase == 2 and scene.get("_did_intro") == true and _frames > (60 if OS.has_feature("ios") else 450):
		if scene.scene_file_path != MobileRender.MATCH or GameConfig.stage != "mobile":
			_fail("mobile match did not stay active")
			return
		for particles in scene.find_children("*", "GPUParticles3D", true, false):
			if particles.process_material != null or particles.emitting:
				_fail("desktop GPU particles are active: " + String(particles.get_path()))
				return
		var reflector := scene.get("_reflector") as FloorReflector
		if reflector != null and reflector.get_child_count() > 0:
			_fail("reflection viewport was allocated on mobile")
			return
		if GameConfig.contour_outline:
			_fail("desktop contour rendering is active")
			return
		if not scene.find_children("*", "SpringBoneSimulator3D", true, false).is_empty():
			_fail("desktop secondary hair simulation was allocated")
			return
		if (scene.get("fx") as Node).get_child_count() > 40:
			_fail("desktop FX pools are allocated")
			return
		if get_viewport().positional_shadow_atlas_size != 0 or get_viewport().msaa_3d != Viewport.MSAA_DISABLED:
			_fail("mobile render budget was overridden")
			return
		if scene._all_players.size() != 2:
			_fail("offline opponent is missing")
			return
		if DisplayServer.get_name() != "headless" and not OS.has_feature("ios"):
			get_viewport().get_texture().get_image().save_png("user://mobile-match-" + RenderingServer.get_current_rendering_method() + ".png")
		MobileDiagnostics.record("match_smoke_passed")
		_phase = 3
		_frames = 0
		GameConfig.goto_scene("res://game/ui/menu.tscn")
	elif _phase == 3 and scene.scene_file_path == MENU and _frames >= 30:
		_phase = 4
		_frames = 0
		scene._offline()
	elif _phase == 4 and scene.scene_file_path == MobileRender.MATCH and _frames >= (30 if OS.has_feature("ios") else 120):
		_write("passed")
		printerr("MOBILE MATCH SMOKE PASSED: phone menu -> offline match -> menu -> second match; bounded effects and render targets")
		set_process(false)
		if OS.get_environment("VOLOBALL_BOOT_SMOKE_QUIT") == "1":
			get_tree().quit()
	elif _phase == 2 and _frames % 30 == 0:
		_write("match_running")

func _write(phase: String, error := "") -> void:
	var profile := ProfileStore.active()
	var file := FileAccess.open("user://mobile-smoke.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"phase": phase, "error": error, "run_id": _run_id,
			"profile": profile.uid if profile != null else "", "fresh": ProfileStore.seeded_fresh,
			"elapsed_ms": Time.get_ticks_msec() - _started, "frames": _frames,
			"fps": Engine.get_frames_per_second()}))
		file.close()

func _fail(error: String) -> void:
	_write("failed", error)
	push_error("MOBILE BOOT SMOKE FAILED: " + error)
	set_process(false)
