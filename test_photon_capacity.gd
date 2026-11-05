extends SceneTree
## Optional live cloud check; creates only short-lived, invisible test rooms.
const Cloud := preload("res://game/net/photon_cloud.gd")
var host := Cloud.new()
var clients: Array = []
var overflow := Cloud.new()
var closed := Cloud.new()
var room := ""
var phase := 0
var elapsed := 0.0
var stage_time := 0.0
var joined_count := 0
var deliveries := 0
var replies := {}
var host_left_count := 0
var overflow_refused := false
var closed_refused := false

func _initialize() -> void:
	room = "CAP" + Crypto.new().generate_random_bytes(8).hex_encode()
	host.failed.connect(_fail)
	host.joined.connect(func(_id, _actors, _owner): phase = 1)
	host.received.connect(func(sender, code, content):
		if code == 82 and content == "reply":
			replies[sender] = true)
	overflow.joined.connect(func(_id, _actors, _owner): _fail("eleventh client admitted"))
	overflow.failed.connect(func(reason):
		if "заповнена" not in reason:
			_fail("unexpected capacity refusal: " + reason)
		overflow_refused = true)
	closed.joined.connect(func(_id, _actors, _owner): _fail("closed room admitted a client"))
	closed.failed.connect(func(reason):
		if "закрита" not in reason:
			_fail("unexpected closed-room refusal: " + reason)
		closed_refused = true)
	host.connect_room(true, room, "Capacity host")

func _process(delta: float) -> bool:
	elapsed += delta
	stage_time += delta
	if elapsed > 90:
		_fail("timeout in phase %d, joined=%d deliveries=%d replies=%d" % [phase, joined_count, deliveries, replies.size()])
		return false
	host.poll()
	for client in clients:
		client.poll()
	overflow.poll()
	closed.poll()
	match phase:
		1:
			phase = 2
			for i in range(9):
				var client := Cloud.new()
				clients.append(client)
				client.failed.connect(_fail)
				client.joined.connect(func(_id, _actors, owner):
					if owner != 1:
						_fail("wrong room owner")
					joined_count += 1)
				client.received.connect(_client_event.bind(client))
				client.actor_left.connect(func(id):
					if id == 1:
						host_left_count += 1)
				client.connect_room(false, room, "Client %d" % i)
		2:
			if joined_count == 9 and host.actors.size() == 10:
				print("PHOTON CAPACITY: 10 clients joined")
				phase = 3
				host.send_event(81, "broadcast 🏐")
		3:
			if deliveries == 9 and replies.size() == 9:
				phase = 4
				overflow.connect_room(false, room, "Overflow")
		4:
			if overflow_refused:
				print("PHOTON CAPACITY: eleventh refused; broadcast and targeted replies passed")
				phase = 5
				clients[8].close()
				host.set_open(false)
				stage_time = 0.0
		5:
			if host.actors.size() == 9 and stage_time > 1:
				phase = 6
				closed.connect_room(false, room, "Closed room check")
		6:
			if closed_refused:
				print("PHOTON CAPACITY: closed room refused join")
				phase = 7
				host.close()
		7:
			if host_left_count == 8:
				print("PHOTON CAPACITY PASS: ten players, overflow, broadcast, targeted delivery, closed room, host departure")
				_cleanup()
				quit(0)
	return false

func _client_event(sender: int, code: int, content: Variant, client: RefCounted) -> void:
	if sender == 1 and code == 81 and content == "broadcast 🏐":
		deliveries += 1
		client.send_event(82, "reply", [1])

func _cleanup() -> void:
	host.close()
	for client in clients:
		client.close()
	overflow.close()
	closed.close()

func _fail(reason: String) -> void:
	push_error("PHOTON CAPACITY FAILED: " + reason)
	_cleanup()
	quit(1)
