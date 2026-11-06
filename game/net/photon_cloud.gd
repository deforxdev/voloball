extends RefCounted
## Photon Realtime's JSON WebSocket transport, compatible with the official JS SDK.
## Native Godot TLS/WebSocket only: no embedded web view or native SDK required.

signal joined(actor: int, actors: Array, host: int)
signal actor_joined(actor: int)
signal actor_left(actor: int)
signal received(actor: int, code: int, content: Variant)
signal failed(message: String)

const APP_ID := "358a2750-d824-4049-ad0d-cb0b587d0bda"
const REGION := "eu"
const MAX_PLAYERS := 10
const QUICK_LOBBY := "voloball-quick-v1"
const MAX_FRAME := 262144
var app_version := "voloball-61-cloud-1"
var capacity := MAX_PLAYERS
var quick_modes: Array[int] = []
var quick_team_size := 0
var room := ""
var hosting := false
var actor_id := 0
var host_id := 0
var actors: Array = []
var rtt_ms := 0
var phase := "closed"
var _socket: WebSocketPeer
var _session := false
var _secret := ""
var _user := ""
var _nickname := ""
var _deadline := 0
var _last_received := 0
var _last_sent := 0
var _epoch := 0

func connect_room(create: bool, code: String, nickname: String) -> Error:
	close()
	hosting = create
	room = code
	_nickname = nickname.left(32)
	_user = Crypto.new().generate_random_bytes(16).hex_encode()
	_epoch = Time.get_ticks_msec()
	return _connect_server("wss://ns.photonengine.io:19093", "name")

func _connect_server(address: String, next_phase: String) -> Error:
	if _socket:
		_socket.close()
	# Authentication tickets must only go to Photon servers over TLS.
	var url := address if address.begins_with("wss://") else "wss://" + address
	var host := url.trim_prefix("wss://").get_slice("/", 0).get_slice(":", 0)
	if not (host.ends_with(".photonengine.io") or host.ends_with(".exitgames.com") or host.ends_with(".photonengine.com")):
		_fail("Photon повернув невідому адресу сервера.")
		return ERR_INVALID_DATA
	_socket = WebSocketPeer.new()
	_socket.supported_protocols = PackedStringArray(["Json"])
	_socket.inbound_buffer_size = 1048576
	_socket.outbound_buffer_size = 1048576
	_socket.max_queued_packets = 1024
	_session = false
	phase = next_phase
	_deadline = Time.get_ticks_msec() + 30000
	_last_received = Time.get_ticks_msec()
	var err := _socket.connect_to_url(url.trim_suffix("/") + "/" + APP_ID + "?libversion=4.4.0.0")
	if err != OK:
		_fail("Не вдалося підключитися до Photon (%d)." % err)
	return err

func poll() -> void:
	if not _socket or phase == "closed":
		return
	var current := _socket
	current.poll()
	var now := Time.get_ticks_msec()
	if now > _deadline and phase != "room":
		_fail("Час підключення до Photon вичерпано. Спробуй ще раз.")
		return
	if current.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		_fail("З'єднання з Photon втрачено. Перевір інтернет.")
		return
	for _i in range(mini(current.get_available_packet_count(), 512)):
		var packet := current.get_packet()
		if packet.size() > MAX_FRAME:
			_fail("Отримано завеликий пакет Photon.")
			return
		_last_received = now
		_decode(packet.get_string_from_utf8())
		if current != _socket or phase == "closed":
			return
	if _session and now - _last_sent > 3000:
		_send({"irq": 1, "vals": [1, now - _epoch]})
	if now - _last_received > 25000:
		_fail("Photon не відповідає. Повернися до меню та підключись знову.")

static func _utf16_length(value: String) -> int:
	return value.to_utf16_buffer().size() / 2

func _send(message: Dictionary) -> Error:
	if not _socket or _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return ERR_UNCONFIGURED
	var body := "~j~" + JSON.stringify(message)
	if body.to_utf8_buffer().size() > MAX_FRAME:
		return ERR_INVALID_DATA
	_last_sent = Time.get_ticks_msec()
	return _socket.send_text("~m~%d~m~%s" % [_utf16_length(body), body])

func _op(code: int, values: Array) -> Error:
	return _send({"req": code, "vals": values})

func _decode(text: String) -> void:
	var source := _socket
	# WebSocket messages may contain several length-prefixed Photon frames.
	while not text.is_empty():
		if not text.begins_with("~m~"):
			_fail("Некоректний пакет Photon.")
			return
		var marker := text.find("~m~", 3)
		if marker < 4 or marker > 12 or not text.substr(3, marker - 3).is_valid_int():
			_fail("Некоректна довжина пакета Photon.")
			return
		var length := int(text.substr(3, marker - 3))
		if length < 0 or length > MAX_FRAME:
			_fail("Некоректна довжина пакета Photon.")
			return
		text = text.substr(marker + 3)
		var count := 0
		var units := 0
		while count < text.length() and units < length:
			units += 2 if text.unicode_at(count) > 65535 else 1
			count += 1
		if units != length:
			_fail("Неповний пакет Photon.")
			return
		var frame := text.substr(0, count)
		text = text.substr(count)
		if not _session:
			_session = true
			_authenticate()
		elif frame.begins_with("~j~"):
			var data: Variant = JSON.parse_string(frame.substr(3))
			if data is Dictionary:
				_message(data)
		if phase == "closed" or source != _socket:
			return

func _authenticate() -> void:
	var values: Array = [224, APP_ID, 220, app_version, 225, _user]
	if phase == "name":
		values.append_array([210, REGION])
	else:
		values.append_array([221, _secret])
	_op(230, values)

func _message(message: Dictionary) -> void:
	var values: Dictionary = {}
	var raw: Variant = message.get("vals", [])
	if not raw is Array or raw.size() % 2 != 0:
		_fail("Некоректні параметри Photon.")
		return
	for i in range(0, raw.size(), 2):
		values[str(int(raw[i]))] = raw[i + 1]
	if message.has("irs"):
		rtt_ms = maxi(0, Time.get_ticks_msec() - _epoch - int(values.get("1", 0)))
	elif message.has("res"):
		_response(int(message.res), int(message.get("err", 0)), values)
	elif message.has("evt"):
		_event(int(message.evt), values)

func _response(operation: int, error: int, values: Dictionary) -> void:
	if error != 0:
		var errors := {32766: "Такий код кімнати вже існує.", 32765: "Кімната заповнена.", 32764: "Матч уже почався або кімната закрита.", 32758: "Кімнату не знайдено. Перевір код.", 32757: "Тестовий сервер Photon заповнений. Спробуй пізніше.", 32767: "Photon відхилив App ID."}
		_fail(str(errors.get(error, "Помилка Photon (%d). Спробуй ще раз." % error)))
		return
	if values.has("221"):
		_secret = str(values["221"])
	if operation == 230:
		if phase == "name":
			_connect_server(str(values.get("230", "")), "master")
		else:
			_join_operation()
	elif operation in [225, 226, 227]:
		if phase == "master":
			room = str(values.get("255", room))
			_connect_server(str(values.get("230", "")), "game")
		elif phase == "game":
			actor_id = int(values.get("254", 0))
			if actor_id <= 0:
				_fail("Photon не надав номер гравця.")
				return
			actors = []
			for value in values.get("252", [actor_id]):
				var id := int(value)
				if id > 0 and not actors.has(id):
					actors.append(id)
			if not actors.has(actor_id):
				actors.append(actor_id)
			var properties: Dictionary = values.get("248", {})
			host_id = int(properties.get("248", 1))
			if not quick_modes.is_empty():
				hosting = actor_id == host_id
				quick_team_size = int(properties.get("C0", quick_modes[0]))
			phase = "room"
			joined.emit(actor_id, actors.duplicate(), host_id)

func _room_options(property_key: int) -> Array:
	var quick := not quick_modes.is_empty()
	var properties := {"255": capacity, "254": quick, "253": true}
	if quick:
		properties["C0"] = quick_modes[0]
		properties["250"] = ["C0"] # Properties exposed to matchmaking.
	return [property_key, properties, 241, true, 232, true, 239, true, 235, 0, 236, 0]

func _join_operation() -> void:
	var values: Array = [255, room, 250, true]
	var quick := not quick_modes.is_empty()
	if quick:
		# Named SQL lobby separates the queue from private rooms. Join-or-create
		# lets Photon pick a waiting room atomically when searches overlap.
		values.append_array([215, 1, 213, QUICK_LOBBY, 212, 2])
		if phase == "master":
			var modes := ",".join(PackedStringArray(quick_modes))
			values.append_array([245, "C0 IN (%s)" % modes])
			values.append_array(_room_options(251))
			_op(225, values)
			return
		values.append_array(_room_options(248))
	elif hosting:
		values.append_array(_room_options(248))
	if phase == "game":
		values.append_array([249, {"255": _nickname}])
	_op(227 if hosting and not quick else 226, values)

func _event(code: int, values: Dictionary) -> void:
	var sender := int(values.get("254", 0))
	match code:
		255:
			if sender > 0 and sender != actor_id and not actors.has(sender):
				actors.append(sender)
				actor_joined.emit(sender)
		254:
			actors.erase(sender)
			actor_left.emit(sender)
		252:
			_fail("Photon закрив з'єднання з кімнатою.")
		223:
			if values.has("221"):
				_secret = str(values["221"])
		_:
			if code < 200 and phase == "room" and sender > 0:
				received.emit(sender, code, values.get("245"))

func send_event(code: int, content: Variant, targets: Array = []) -> Error:
	if phase != "room":
		return ERR_UNCONFIGURED
	var values: Array = [244, code, 245, content]
	if not targets.is_empty():
		values.append_array([252, targets])
	return _op(253, values)

func set_open(open: bool) -> void:
	if phase == "room" and hosting:
		_op(252, [251, {"253": open}, 250, true])

func close() -> void:
	phase = "closed"
	if _socket:
		_socket.close()
	_socket = null
	_secret = ""
	_session = false
	actor_id = 0
	host_id = 0
	actors.clear()

func _fail(message: String) -> void:
	close()
	failed.emit(message)
