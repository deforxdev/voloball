extends "res://game/ui/menu.gd"
## Real Photon Cloud integration test: original menu -> room -> playable match.
## Run host first, then client with --cloud-code=<printed code>.

class CloudProbe extends Node:
	var elapsed := 0.0
	var frames := 0
	var inputs := 0
	var snapshots := 0
	var started := false
	var full_since := 0.0
	var finishing := false
	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		Net.input_received.connect(func(_peer, _ls, _data): inputs += 1)
		Net.snapshot_received.connect(func(_data): snapshots += 1)
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
		if not started and Net.is_host and Net.players.size() == 2:
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
			if frames > 300 and not Net.is_host and snapshots > 10 and not finishing:
				finishing = true
				print("CLOUD CLIENT MATCH PASS: snapshots=", snapshots)
				print("CLOUD CLIENT ROLE ", scene.get("_net_role"), " spectator=", scene.get("_spectating"), " peer=", multiplayer.get_unique_id())
				client_passed.rpc_id(1, snapshots)
	@rpc("any_peer", "reliable")
	func client_passed(count: int) -> void:
		if not Net.is_host or multiplayer.get_remote_sender_id() <= 1 or finishing:
			return
		if count < 10 or inputs < 10 or frames < 100:
			push_error("CLOUD GAME FAILED: inputs=%d frames=%d snapshots=%d" % [inputs, frames, count])
			get_tree().quit(1)
			return
		finishing = true
		finish.rpc_id(multiplayer.get_remote_sender_id())
		print("CLOUD HOST MATCH PASS: inputs=", inputs, " client snapshots=", count)
		await get_tree().create_timer(3).timeout
		Net.leave()
		get_tree().quit(0)
	@rpc("authority", "reliable")
	func finish() -> void:
		await get_tree().create_timer(0.5).timeout
		Net.leave()
		get_tree().quit(0)

func _ready() -> void:
	super._ready()
	var probe := CloudProbe.new()
	probe.name = "CloudProbe"
	get_tree().root.add_child.call_deferred(probe)
	_show(_online)
	if _cloud_code_edit == null:
		push_error("CLOUD UI FAILED: original menu cloud controls missing")
		get_tree().quit(1)
		return
	var code := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--cloud-code="):
			code = arg.trim_prefix("--cloud-code=")
	if code.is_empty():
		Net.cloud_ready.connect(func(): print("CLOUD CODE: ", Net.cloud_code))
		_host_cloud()
	else:
		_cloud_code_edit.text = code
		_join_cloud()

func leave_for_match() -> void:
	# The test inherits the menu scene under another resource path.
	# Let the ordinary match_started handler perform the one scene change.
	pass
