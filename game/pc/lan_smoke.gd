extends Node

# Explicit opt-in for testing the exported Windows executable; normal play is unaffected.
var _role := ""
var _started := 0
var _menu_frames := 0
var _match_frames := 0
var _inputs := 0
var _snapshots := 0
var _joined := false
var _matched := false
var _finished := false

func _ready() -> void:
	_role = OS.get_environment("VOLOBALL_LAN_SMOKE")
	if _role not in ["host", "client"]:
		set_process(false)
		return
	_started = Time.get_ticks_msec()
	GameConfig.free_mouse_harness = true
	GameConfig.background_fps = 0
	Net.input_received.connect(func(_peer, _ls, _data): _inputs += 1)
	Net.snapshot_received.connect(func(_data): _snapshots += 1)
	printerr("WINDOWS LAN SMOKE START: " + _role)

func _process(_delta: float) -> void:
	if _finished:
		return
	if Time.get_ticks_msec() - _started > 90000:
		push_error("WINDOWS LAN TEST FAILED: timeout, role=" + _role)
		get_tree().quit(1)
		return
	var scene := get_tree().current_scene
	if scene == null or not scene.is_node_ready():
		return
	if scene.scene_file_path == "res://game/mobile/mobile_menu.tscn":
		_menu_frames += 1
		if not _joined and _menu_frames > 30:
			_joined = true
			scene._name.text = "PC Host" if _role == "host" else "PC Client"
			if _role == "host":
				scene._host()
				if not Net.active:
					push_error("WINDOWS LAN TEST FAILED: host creation failed")
					get_tree().quit(1)
					return
				printerr("WINDOWS LAN HOST CREATED: UDP %d" % Net.host_port())
			else:
				var address := OS.get_environment("VOLOBALL_LAN_SMOKE_ADDRESS")
				scene._address.text = address if address != "" else "127.0.0.1"
				scene._join()
		if _role == "host" and not _matched and Net.human_count() == 2:
			_matched = true
			scene._start_match()
	elif scene.scene_file_path == "res://game/main/main.tscn":
		_match_frames += 1
		var packets := _inputs if _role == "host" else _snapshots
		if _match_frames >= 180 and packets >= 10:
			if scene.get("player") == null or scene._all_players.size() != 2 or MobileControls.enabled():
				push_error("WINDOWS LAN TEST FAILED: wrong player count or touch mode")
				get_tree().quit(1)
				return
			printerr("WINDOWS LAN GAME PASS: role=%s players=2 inputs=%d snapshots=%d" % [_role, _inputs, _snapshots])
			if DisplayServer.get_name() != "headless":
				get_viewport().get_texture().get_image().save_png("user://windows-lan-" + _role + ".png")
			_finished = true
			set_process(false)
