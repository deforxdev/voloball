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
	_menu_smoke(menu)

func _menu_smoke(scene: Node) -> void:
	if scene == null or not scene.is_node_ready():
		return
	var expected := MENU
	if _phase == 5:
		expected = "res://game/character/locker.tscn"
	elif _phase == 7:
		expected = "res://game/shop/shop.tscn"
	if scene.scene_file_path != expected:
		return
	_frames += 1
	if _frames < 20:
		return
	_frames = 0
	match _phase:
		0:
			if not scene is Node3D or scene.get("_card_local") == null or scene.player == null:
				_fail("original desktop menu or live character missing")
				return
			if scene.player.scene_file_path != MobileRender.PLAYER:
				_fail("desktop player resource leaked into phone menu")
				return
			if scene._cfg_panels.size() != 0 or scene._settings_panel != null:
				_fail("hidden pages allocated at startup")
				return
			scene._open_settings(0)
			scene._quality(30, 60)
			_write("settings_opened")
		1:
			if scene._settings_panel == null or GameConfig.max_fps != 30:
				_fail("original settings did not open or apply")
				return
			scene._settings_back()
			scene._quality(60, 75)
		2:
			if get_tree().paused or not scene._home.visible:
				_fail("settings back did not restore menu")
				return
			scene._show(scene._configs)
		3:
			var bodies := 0
			for panel in scene._cfg_panels:
				if panel.pc != null:
					bodies += 1
			if bodies != LocalPlayers.count():
				_fail("controller page allocated unoccupied preview rigs")
				return
			scene._show(scene._profile)
		4:
			if scene._profile_pfp == null:
				_fail("full profile page was not built")
				return
			GameConfig.goto_scene(scene._locker_scene())
		5:
			if scene._player == null or scene.world.msaa_3d != Viewport.MSAA_DISABLED:
				_fail("locker preview is missing or uses desktop AA")
				return
			scene._save_and_exit()
		6:
			GameConfig.goto_scene(scene._shop_scene())
		7:
			if scene._player == null:
				_fail("shop preview missing")
				return
			GameConfig.goto_scene("res://game/ui/menu.tscn")
		8:
			if get_tree().paused or not scene._home.visible or GameConfig.onboarding_active:
				_fail("menu did not survive locker/shop round trip")
				return
			_write("passed")
			print("MOBILE BOOT SMOKE PASSED: original menu, settings/back, occupied previews, profile, locker/save/back, shop/back")
			set_process(false)
			if OS.get_environment("VOLOBALL_BOOT_SMOKE_QUIT") == "1":
				get_tree().quit()
	_phase += 1

func _match_smoke(scene: Node) -> void:
	if scene == null or not scene.is_node_ready():
		return
	if _phase in [0, 3, 4] and scene.scene_file_path != MENU:
		return
	if _phase in [1, 2] and scene.scene_file_path != MobileRender.MATCH:
		return
	_frames += 1
	if _phase == 0 and _frames >= 30:
		if not scene is Node3D or scene.player == null:
			_fail("original desktop menu missing")
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
		if scene.get("_freeplay") != true:
			_fail("original freeplay did not start")
			return
		scene._spawn_practice_ball()
		if not scene.ball.global_position.is_equal_approx(scene.player.global_position + Vector3(0, 5.2, 0)):
			_fail("G did not spawn at 5.2m")
			return
		_write("passed")
		printerr("MOBILE MATCH SMOKE PASSED: original menu -> match -> menu -> freeplay and G at 5.2m")
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
