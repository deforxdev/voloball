extends MultiplayerPeerExtension
## Preserves the game's existing Godot RPC wire protocol and host authority.
signal room_ready
signal cloud_error(message: String)

const Cloud := preload("res://game/net/photon_cloud.gd")
const PACKETS := 71
const KICK := 72
const MAX_PACKET := 60000
const MAX_QUEUE := 512
var cloud := Cloud.new()
var last_error := ""
var _status := MultiplayerPeer.CONNECTION_DISCONNECTED
var _id := 0
var _hosting := false
var _target := 0
var _channel := 0
var _mode := MultiplayerPeer.TRANSFER_MODE_RELIABLE
var _refusing := false
var _peers: Dictionary = {}
var _blocked: Dictionary = {}
var _departures: Array[int] = []
var _incoming: Array = []
var _outgoing: Array = []

func _init() -> void:
	cloud.joined.connect(_joined)
	cloud.actor_joined.connect(_actor_joined)
	cloud.actor_left.connect(_actor_left)
	cloud.received.connect(_received)
	cloud.failed.connect(_failed)

func connect_room(hosting: bool, code: String, nickname: String) -> Error:
	_hosting = hosting
	_status = MultiplayerPeer.CONNECTION_CONNECTING
	return cloud.connect_room(hosting, code, nickname)

func _joined(id: int, actors: Array, host: int) -> void:
	if host != 1 or not actors.has(1) or (_hosting and id != 1):
		_failed("Власник цієї кімнати вже вийшов. Створи нову кімнату.")
		return
	_id = id
	_status = MultiplayerPeer.CONNECTION_CONNECTED
	room_ready.emit()
	actors.sort()
	for actor in actors:
		_actor_joined(int(actor))

func _actor_joined(id: int) -> void:
	if id == _id or _peers.has(id) or _blocked.has(id):
		return
	if _hosting and _refusing:
		_disconnect_peer(id, true)
		return
	_peers[id] = true
	peer_connected.emit(id)

func _actor_left(id: int) -> void:
	# Deliver RPCs that precede the leave event before removing the peer from
	# SceneMultiplayer. Emitting now invalidates packets already in this poll.
	if not _departures.has(id):
		_departures.append(id)

func _finish_departure(id: int) -> void:
	if id == 1:
		_failed("Власник кімнати вийшов.")
		return
	_incoming = _incoming.filter(func(packet: Dictionary): return int(packet.sender) != id)
	_outgoing = _outgoing.filter(func(packet: Dictionary): return int(packet.target) != id)
	if _peers.erase(id):
		peer_disconnected.emit(id)
	_blocked.erase(id)

func _received(sender: int, code: int, content: Variant) -> void:
	if _blocked.has(sender):
		return
	if code == KICK:
		if sender == 1:
			_failed("Власник закрив для тебе доступ до кімнати.")
		return
	if code != PACKETS or not content is Array or content.size() > 64 or not _peers.has(sender):
		return
	for record in content:
		if not record is Array or record.size() != 3 or not record[2] is String:
			continue
		var mode := int(record[0])
		var channel := int(record[1])
		if mode < 0 or mode > 2 or channel < 0 or channel > 255 or record[2].length() > 80000:
			continue
		var bytes := Marshalls.base64_to_raw(record[2])
		if bytes.is_empty() or bytes.size() > MAX_PACKET:
			continue
		if _incoming.size() >= MAX_QUEUE:
			_failed("Перевантаження мережі. Підключись до кімнати знову.")
			return
		_incoming.append({"sender": sender, "mode": mode, "channel": channel, "data": bytes})

func _failed(message: String) -> void:
	last_error = message
	_close()
	cloud_error.emit(message)

func _poll() -> void:
	var departures := _departures.duplicate()
	_departures.clear()
	for id in departures:
		_finish_departure(id)
		if _status == MultiplayerPeer.CONNECTION_DISCONNECTED:
			return
	cloud.poll()
	_flush()

func _flush() -> void:
	if _status != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	# Batch small Godot protocol/RPC packets without changing their order.
	while not _outgoing.is_empty():
		var target: int = _outgoing[0].target
		var records: Array = []
		var size := 0
		while not _outgoing.is_empty() and int(_outgoing[0].target) == target and records.size() < 64:
			if size > 0 and size + int(_outgoing[0].size) > 80000:
				break
			var packet: Dictionary = _outgoing.pop_front()
			records.append(packet.record)
			size += int(packet.size)
		var targets: Array = []
		if target > 0:
			targets = [target]
		elif target < 0:
			for id in _peers:
				if int(id) != -target:
					targets.append(id)
			if targets.is_empty():
				continue
		var error := cloud.send_event(PACKETS, records, targets)
		if error != OK:
			_failed("Не вдалося надіслати дані матчу (%d)." % error)
			return

func _put_packet_script(buffer: PackedByteArray) -> Error:
	if _status != MultiplayerPeer.CONNECTION_CONNECTED:
		return ERR_UNCONFIGURED
	if buffer.size() > MAX_PACKET:
		return ERR_INVALID_DATA
	if _target > 0 and not _peers.has(_target):
		return ERR_INVALID_PARAMETER
	if _outgoing.size() >= MAX_QUEUE:
		_failed("Черга мережі переповнена. Перевір інтернет.")
		return ERR_OUT_OF_MEMORY
	var encoded := Marshalls.raw_to_base64(buffer)
	_outgoing.append({"target": _target, "record": [_mode, _channel, encoded], "size": encoded.length()})
	return OK

func _get_packet_script() -> PackedByteArray:
	return _incoming.pop_front().data if not _incoming.is_empty() else PackedByteArray()
func _get_packet_peer() -> int:
	return int(_incoming[0].sender) if not _incoming.is_empty() else 0
func _get_packet_channel() -> int:
	return int(_incoming[0].channel) if not _incoming.is_empty() else 0
func _get_packet_mode() -> MultiplayerPeer.TransferMode:
	return int(_incoming[0].mode) as MultiplayerPeer.TransferMode if not _incoming.is_empty() else MultiplayerPeer.TRANSFER_MODE_RELIABLE
func _get_available_packet_count() -> int:
	return _incoming.size()
func _get_connection_status() -> MultiplayerPeer.ConnectionStatus:
	return _status as MultiplayerPeer.ConnectionStatus
func _get_max_packet_size() -> int:
	return MAX_PACKET
func _get_unique_id() -> int:
	return _id
func _is_server() -> bool:
	return _hosting
func _is_server_relay_supported() -> bool:
	return false
func _set_target_peer(peer: int) -> void:
	_target = peer
func _get_transfer_channel() -> int:
	return _channel
func _set_transfer_channel(channel: int) -> void:
	_channel = channel
func _get_transfer_mode() -> MultiplayerPeer.TransferMode:
	return _mode as MultiplayerPeer.TransferMode
func _set_transfer_mode(mode: MultiplayerPeer.TransferMode) -> void:
	_mode = mode
func _is_refusing_new_connections() -> bool:
	return _refusing
func _set_refuse_new_connections(enable: bool) -> void:
	_refusing = enable
	cloud.set_open(not enable)
func _disconnect_peer(peer: int, _force: bool) -> void:
	if not _hosting or peer == 1:
		return
	_flush()
	cloud.send_event(KICK, null, [peer])
	_blocked[peer] = true
	_incoming = _incoming.filter(func(packet: Dictionary): return int(packet.sender) != peer)
	_outgoing = _outgoing.filter(func(packet: Dictionary): return int(packet.target) != peer)
	if _peers.erase(peer):
		peer_disconnected.emit(peer)
func _close() -> void:
	_status = MultiplayerPeer.CONNECTION_DISCONNECTED
	cloud.close()
	_incoming.clear()
	_outgoing.clear()
	_peers.clear()
	_blocked.clear()
	_departures.clear()
