extends Node

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if Net.join_cloud("wrong", "Test") != ERR_INVALID_PARAMETER or Net.active:
		_fail("invalid room code started a connection")
		return
	if Net.host_cloud("Cancel test") != OK:
		_fail("could not begin host connection")
		return
	if not Net.valid_cloud_code(Net.cloud_code):
		_fail("host generated an invalid room code")
		return
	Net.leave()
	if Net.active or Net.cloud_code != "" or not Net.players.is_empty():
		_fail("cancel retained session state")
		return
	if Net.join_cloud("ABCDEFGH", "Cancel join test") != OK:
		_fail("could not begin join connection")
		return
	await get_tree().process_frame
	Net.leave()
	await get_tree().create_timer(0.3).timeout
	if Net.active or Net.is_host or Net.cloud_code != "":
		_fail("late connection callback revived a canceled room")
		return
	print("PHOTON CANCEL PASS: invalid code, cancel host, cancel join, no late revival")
	get_tree().quit(0)

func _fail(reason: String) -> void:
	push_error("PHOTON CANCEL FAILED: " + reason)
	Net.leave()
	get_tree().quit(1)
