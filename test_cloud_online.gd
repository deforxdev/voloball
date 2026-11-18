extends "res://game/ui/menu.gd"
## Real Photon Cloud integration test: original menu -> room -> playable match.
## Run host first, then client with --cloud-code=<printed code>.

class CloudProbe extends Node:
	const MatchScript = preload("res://game/main/main.gd")
	var elapsed := 0.0
	var frames := 0
	var inputs := 0
	var snapshots := 0
	var started := false
	var full_since := 0.0
	var finishing := false
	var guest_serves := 0
	var guest_tosses := 0
	var host_serves := 0
	var minigame_seen := false
	var power_serve_hit := false
	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		Net.input_received.connect(func(_peer, _ls, _data): inputs += 1)
		Net.snapshot_received.connect(func(_data): snapshots += 1)
		Net.event_received.connect(func(kind, _args):
			if kind == "toss":
				guest_tosses += 1)
		Net.session_ended.connect(func(reason):
			if not finishing:
				push_error("CLOUD GAME FAILED: " + reason)
				get_tree().quit(1))
	func _process(delta: float) -> void:
		elapsed += delta
		if elapsed > 90:
			push_error("CLOUD GAME TIMEOUT")
			get_tree().quit(1)
			return
		var scene := get_tree().current_scene
		if scene == null:
			return
		if not started and not Net.cloud_quick_session() and Net.is_host and Net.players.size() == 2:
			full_since += delta
			if full_since > 2.0:
				started = true
				Net.team_size = 1
				Net.rule_intro = false
				Net.cpu_slots = {}
				for id in Net.players:
					print("CLOUD SEAT ", id, " side=", Net.players[id].side, " locals=", Net.locals_of(id).size())
				scene.call("_on_start_online")
		if scene.scene_file_path == MobileRender.MATCH and scene.get("player") != null:
			frames += 1
			if frames == 1 and Net.cloud_quick_session() and not GameConfig.quick_match:
				push_error("CLOUD QUICK FAILED: quick rules were not enabled")
				get_tree().quit(1)
				return
			if Net.is_host:
				_drive_host_serve(scene)
			else:
				_drive_guest_serve(scene)
			if frames > 300 and not Net.is_host and snapshots > 10 and not finishing\
			and minigame_seen and guest_serves == 2 and guest_tosses >= 2:
				finishing = true
				print("CLOUD CLIENT MATCH PASS: snapshots=", snapshots)
				print("CLOUD CLIENT ROLE ", scene.get("_net_role"), " spectator=", scene.get("_spectating"), " peer=", multiplayer.get_unique_id())
				client_passed.rpc_id(1, snapshots)
	func _drive_host_serve(scene: Node) -> void:
		var rally: Rally = scene.get("_rally")
		var peer_players: Dictionary = scene.get("_peer_players")
		if peer_players.is_empty() or finishing:
			return
		var guest: Player = peer_players.values()[0]
		if host_serves == 0 and scene.get("_phase") == MatchScript.Phase.SERVE_PREP:
			host_serves = 1
			if rally.server != guest:
				rally.serve_side = guest.team_side
				scene.call("_begin_serve")
		elif host_serves == 1 and scene.get("_phase") == MatchScript.Phase.LIVE and rally.server == guest:
			if guest.input_power_cap() != 8 or GameConfig.power_disp_of(guest.power_level, 8) != 3:
				push_error("CLOUD SERVE FAILED: the host used a different power level")
				get_tree().quit(1)
				return
			host_serves = 2
			# Reset only the test fixture so the same guest can serve at full power.
			scene.call("_begin_serve")
		elif host_serves == 2 and rally.serve_done and rally.ball.hit_by == guest:
			power_serve_hit = true
		if scene.get("_serve_minigame") != null:
			push_error("CLOUD SERVE FAILED: the guest's minigame opened on the host")
			get_tree().quit(1)

	func _drive_guest_serve(scene: Node) -> void:
		var game: Dictionary = scene.get("_np")
		var player: Player = scene.get("player")
		var net_ids: Dictionary = scene.get("_net_ids")
		var minigame: ServeMinigame = scene.get("_serve_minigame")
		if minigame != null and not minigame_seen:
			minigame_seen = true
			var touch := InputEventScreenTouch.new()
			touch.pressed = true
			minigame._input(touch)
			minigame._input(touch)
		if guest_serves >= 2 or guest_serves != guest_tosses\
		or int(game.get("ph", -1)) != MatchScript.Phase.SERVE_PREP\
		or int(game.get("sv", 0)) != int(net_ids.get(player, -1)):
			return
		GameConfig.power_cap = 8
		player.power_level = GameConfig.power_disp_level(3 if guest_serves == 0 else 8)
		var collector: InputCollector = scene.get("_input_collector")
		collector.set("_buf_serve", 0.2)
		guest_serves += 1

	@rpc("any_peer", "reliable")
	func client_passed(count: int) -> void:
		if not Net.is_host or multiplayer.get_remote_sender_id() <= 1 or finishing:
			return
		if count < 10 or inputs < 10 or frames == 0:
			push_error("CLOUD GAME FAILED: inputs=%d frames=%d snapshots=%d" % [inputs, frames, count])
			get_tree().quit(1)
			return
		for _i in range(90):
			if power_serve_hit:
				break
			await get_tree().physics_frame
		if not power_serve_hit:
			push_error("CLOUD SERVE FAILED: full-power guest serve did not strike")
			get_tree().quit(1)
			return
		finishing = true
		print("CLOUD GUEST SERVES PASS: minigame and power serve")
		finish.rpc_id(multiplayer.get_remote_sender_id())
		print("CLOUD HOST MATCH PASS: inputs=", inputs, " client snapshots=", count)
		await get_tree().create_timer(3).timeout
		Net.leave()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(0)
	@rpc("authority", "reliable")
	func finish() -> void:
		await get_tree().create_timer(0.5).timeout
		Net.leave()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(0)

func _ready() -> void:
	super._ready()
	var probe := CloudProbe.new()
	probe.name = "CloudProbe"
	get_tree().root.add_child.call_deferred(probe)
	_open_cloud_test_menu.call_deferred()

func _open_cloud_test_menu() -> void:
	_show(_online)
	if _card_custom_lobby == null:
		push_error("CLOUD UI FAILED: desktop online menu missing")
		get_tree().quit(1)
		return
	if "--cloud-quick" in OS.get_cmdline_user_args():
		_show(_quick)
		Net.cloud_ready.connect(func():
			if Net.is_host:
				print("CLOUD CODE: ", Net.cloud_code))
		_begin_cloud_search([1, 2])
		# Each CI run has its own queue even when several platforms test at once.
		var test_queue := OS.get_environment("VOLOBALL_PHOTON_TEST_QUEUE")
		if Net.cloud_quick_session() and not test_queue.is_empty():
			(multiplayer.multiplayer_peer as Net.PhotonPeer).cloud.app_version += "-" + test_queue
		return
	var code := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--cloud-code="):
			code = arg.trim_prefix("--cloud-code=")
	if code.is_empty():
		Net.cloud_ready.connect(func(): print("CLOUD CODE: ", Net.cloud_code))
		_card_custom_lobby.pressed.emit()
		(_host_steam_card.get_child(0) as Button).pressed.emit()
	else:
		_show(_browse)
		_bw_code.text = code
		_join_cloud(_bw_code.text)

func leave_for_match() -> void:
	# The test inherits the menu scene under another resource path.
	# Let the ordinary match_started handler perform the one scene change.
	pass
