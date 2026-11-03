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
		if menu.get("_card_local") == null:
			_fail("mobile menu controls are missing")
			return
		if not menu is Control or not menu.find_children("*", "Node3D", true, false).is_empty():
			_fail("phone menu loaded a desktop 3D scene")
			return
		menu._open_settings(0)
		menu._quality(30, 60)
		_phase = 1
		_frames = 0
		_write("settings_opened")
	elif _phase == 1 and _frames >= 30:
		if GameConfig.max_fps != 30 or GameConfig.resolution_3d != 60:
			_fail("economy settings did not apply")
			return
		menu._settings_back()
		menu._quality(60, 75)
		_phase = 2
		_frames = 0
		_write("settings_back")
	elif _phase == 2 and _frames >= 120:
		if get_tree().paused or GameConfig.max_fps != 60 or not menu._home.visible:
			_fail("settings did not preserve an active menu")
			return
		if GameConfig.onboarding_active:
			_fail("desktop startup prewarming is active on mobile")
			return
		_write("passed")
		print("MOBILE BOOT SMOKE PASSED: separate phone menu and quality settings")
		set_process(false)
		if OS.get_environment("VOLOBALL_BOOT_SMOKE_QUIT") == "1":
			get_tree().quit()

func _match_smoke(scene: Node) -> void:
	if scene == null or not scene.is_node_ready():
		return
	if _phase in [0, 3] and scene.scene_file_path != MENU:
		return
	if _phase in [1, 2, 4] and scene.scene_file_path != MobileRender.MATCH:
		return
	_frames += 1
	if _phase == 0 and _frames >= 30:
		if not scene is Control or not scene.find_children("*", "Node3D", true, false).is_empty():
			_fail("launcher allocated a 3D scene")
			return
		if DisplayServer.get_name() != "headless" and not OS.has_feature("ios"):
			get_viewport().get_texture().get_image().save_png("user://mobile-desktop-menu-" + RenderingServer.get_current_rendering_method() + ".png")
		_phase = 1
		_frames = 0
		scene._offline()
	elif _phase == 1 and _frames >= 30:
		if scene.get("player") == null or Net.active or get_viewport().disable_3d:
			_fail("offline match or 3D rendering did not start")
			return
		_phase = 2
		_frames = 0
		_write("match_running")
	elif _phase == 2 and scene.get("_did_intro") == true and _frames > 180:
		if GameConfig.stage != "grass" or scene._all_players.size() != 2:
			_fail("wrong stage or player count")
			return
		for particles in scene.find_children("*", "GPUParticles3D", true, false):
			if particles.process_material != null or particles.emitting:
				_fail("desktop GPU particles are active")
				return
		if get_viewport().positional_shadow_atlas_size != 0 or GameConfig.contour_outline:
			_fail("desktop render features are active")
			return
		MobileDiagnostics.record("match_smoke_passed")
		if DisplayServer.get_name() != "headless" and not OS.has_feature("ios"):
			get_viewport().get_texture().get_image().save_png("user://mobile-match-" + RenderingServer.get_current_rendering_method() + ".png")
		_phase = 3
		_frames = 0
		GameConfig.goto_scene("res://game/ui/menu.tscn")
	elif _phase == 3 and _frames >= 30:
		_phase = 4
		_frames = 0
		scene._start_solo_practice()
	elif _phase == 4 and _frames >= 60:
		var practice = scene.get("_practice")
		if practice == null:
			_fail("mobile practice mode is missing")
			return
		practice.spawn_ball(scene.player)
		if not scene.ball.global_position.is_equal_approx(scene.player.global_position + Vector3(0, 5.2, 0)):
			_fail("G did not spawn at 5.2m")
			return
		_write("passed")
		printerr("MOBILE MATCH SMOKE PASSED: 2D menu -> 3D match -> menu -> practice and G at 5.2m")
		set_process(false)
		if OS.get_environment("VOLOBALL_BOOT_SMOKE_QUIT") == "1":
			get_tree().quit()
	elif _frames % 30 == 0:
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
