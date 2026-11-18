extends "res://game/ui/menu.gd"
## Exercises the actual mobile menu and freeplay over two real Photon clients.

var _test_elapsed := 0.0
var _test_started := false
var _test_done := false
var _test_poses := 0
var _test_balls := 0
var _test_remote_position := Vector3.ZERO
var _test_remote_ball := Vector3.ZERO
var _test_report := false
var _test_rejoined := false

func _ready() -> void:
	super._ready()
	Net.freeplay_pose.connect(func(_pid, pose):
		_test_poses += 1
		_test_remote_position = Vector3(pose[0], pose[1], pose[2]))
	Net.ball_pose.connect(func(_pid, pose, _bid):
		_test_balls += 1
		_test_remote_ball = Vector3(pose[0], pose[1], pose[2]))
	_test_open.call_deferred()

func _test_open() -> void:
	var code := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--cloud-code="):
			code = arg.trim_prefix("--cloud-code=")
	if code.is_empty():
		Net.cloud_ready.connect(func(): print("CLOUD CODE: ", Net.cloud_code))
		var create: Button = null
		for child in _party_strip.get_children():
			if child is Button and child.text == "create party":
				create = child
		if create == null:
			_test_fail("create party button missing")
			return
		create.pressed.emit()
	else:
		_open_cloud_party_join()
		_bw_code.text = code
		_join_cloud(_bw_code.text)

func _process(delta: float) -> void:
	super._process(delta)
	_test_elapsed += delta
	if _test_elapsed > 85 and not _test_done:
		_test_fail("timeout: party=%s peers=%d poses=%d balls=%d" % [Net.party, Net.players.size(), _test_poses, _test_balls])
	if Net.is_host and Net.party and Net.players.size() == 2 and not _test_started:
		_test_started = true
		_test_host_flow()

func _test_fail(message: String) -> void:
	push_error("CLOUD PARTY FAILED: " + message)
	get_tree().quit(1)

func _test_host_flow() -> void:
	await get_tree().create_timer(2).timeout
	if not _home.visible or Net.custom_lobby or Net.party_members().size() != 2:
		_test_fail("party did not stay in the original menu")
		return
	var peer := int(Net.party_members().filter(func(id): return int(id) != 1)[0])
	_try_freeplay()
	_test_enter.rpc_id(peer)
	player.global_position = Vector3(-3, 0, 8)
	ball.toss(Vector3(-3, 5, 8), 4.0)
	await get_tree().create_timer(5).timeout
	if not _test_check_world(peer, Vector3(3, 0, 8)):
		return
	_test_check_and_exit.rpc_id(peer)
	for _i in range(80):
		if _test_report:
			break
		await get_tree().create_timer(0.1).timeout
	if not _test_report:
		_test_fail("guest did not verify freeplay")
		return
	if int(_ball_driver.get(1, 1)) != peer or not ball.remote_driven:
		_test_fail("guest hit did not take control of the shared ball")
		return
	print("CLOUD SHARED BALL PASS: guest strike replicated to host")
	_test_exit.rpc_id(peer)
	await get_tree().create_timer(2).timeout
	if not _freeplay or not Net.party or bool(_party_in_freeplay.get(peer, true)):
		_test_fail("guest returning to menu interrupted host freeplay")
		return
	if ball.remote_driven or not _drives(1):
		_test_fail("shared ball froze after its driver returned to the menu")
		return
	_test_reenter.rpc_id(peer)
	for _i in range(60):
		if _test_rejoined and bool(_party_in_freeplay.get(peer, false)):
			break
		await get_tree().create_timer(0.1).timeout
	if not _test_rejoined or not bool(_party_in_freeplay.get(peer, false)):
		_test_fail("guest could not reenter online freeplay")
		return
	_exit_freeplay()
	_test_done = true
	# Opening a private match lobby must preserve both people and the same code.
	var code := Net.cloud_code
	_show(_host)
	_host_cloud()
	await get_tree().create_timer(1).timeout
	if Net.party or not Net.custom_lobby or Net.players.size() != 2 or Net.cloud_code != code:
		_test_fail("opening a lobby split the party")
		return
	_test_finish.rpc_id(peer)
	print("CLOUD HOST PARTY PASS: menu roster, player/ball synchronization, guest menu/reentry, party-to-lobby")
	await get_tree().create_timer(2).timeout
	_leave_party()
	get_tree().quit(0)

func _test_check_world(peer: int, expected: Vector3) -> bool:
	if not _freeplay or not Net.party or Net.in_match or _practice_court != null:
		_test_fail("freeplay allocated a desktop court or lost the party")
		return false
	if _test_poses < 20 or not _party_bodies.has(peer) or not _party_balls.has(peer):
		_test_fail("missing remote player or ball: poses=%d balls=%d" % [_test_poses, _test_balls])
		return false
	var body := _party_bodies[peer] as Player
	if not bool(_party_in_freeplay.get(peer, false)) or not body.visible or body.global_position.distance_to(expected) > 1.0:
		_test_fail("remote player position not applied: " + str(body.global_position))
		return false
	if not Net.is_host:
		var remote := _party_balls[peer] as Ball
		if _test_balls < 10 or not remote.visible or remote.global_position.distance_to(_test_remote_ball) > 2.0:
			_test_fail("shared ball position not applied")
			return false
	return true

@rpc("authority", "reliable")
func _test_enter() -> void:
	if not Net.party or not _home.visible:
		_test_fail("guest did not join a menu party")
		return
	_try_freeplay()
	player.global_position = Vector3(3, 0, 8)

@rpc("authority", "reliable")
func _test_check_and_exit() -> void:
	if not _test_check_world(1, Vector3(-3, 0, 8)):
		return
	var shared := _party_ball()
	if shared == null or player.ball != shared or shared.net_puppet:
		_test_fail("guest cannot interact with the host's shared ball")
		return
	shared.strike_source = player
	shared.hit(Vector3(0, 0, -6), Player.TouchKind.BUMP, 0.5, false)
	await get_tree().create_timer(0.8).timeout
	_test_client_report.rpc_id(1)

@rpc("authority", "reliable")
func _test_exit() -> void:
	_exit_freeplay()
	if not Net.party or not _home.visible:
		_test_fail("returning to menu left the party")
		return

@rpc("any_peer", "reliable")
func _test_client_report() -> void:
	if Net.is_host and multiplayer.get_remote_sender_id() > 1:
		_test_report = true

@rpc("authority", "reliable")
func _test_reenter() -> void:
	_try_freeplay()
	_test_client_reentered.rpc_id(1)

@rpc("any_peer", "reliable")
func _test_client_reentered() -> void:
	if Net.is_host and multiplayer.get_remote_sender_id() > 1:
		_test_rejoined = true

@rpc("authority", "reliable")
func _test_finish() -> void:
	if Net.party or not Net.custom_lobby or not _room.visible:
		_test_fail("guest did not travel with the party into its lobby")
		return
	_test_done = true
	print("CLOUD CLIENT PARTY PASS: menu, online freeplay, menu/reentry, party-to-lobby")
	await get_tree().create_timer(0.5).timeout
	Net.leave()
	get_tree().quit(0)
