class_name Haptics
extends RefCounted










enum Kind{BUMP, SET, SPIKE, SERVE, BLOCK, DIVE_LAND, KNOCKDOWN}



const _PULSE: = {
	Kind.BUMP: [0.46, 0.1, 0.11], 
	Kind.SET: [0.32, 0.05, 0.09], 
	Kind.SPIKE: [0.55, 0.75, 0.16], 
	Kind.SERVE: [0.45, 0.35, 0.13], 
	Kind.BLOCK: [0.5, 0.65, 0.15], 
	Kind.DIVE_LAND: [0.4, 0.55, 0.2], 
	Kind.KNOCKDOWN: [0.7, 0.95, 0.28], 
}



static var _rumble_by_device: = {}


static func set_device_rumble(device: int, on: bool) -> void :
	_rumble_by_device[device] = on





static func wire(player: Node, device: = -1, rumble: = true) -> void :
	if device >= 0:
		_rumble_by_device[device] = rumble
	unwire(player)
	var cbs: = [
		["touched", func(kind: int): _touch(kind, device)], 
		["thumped", func(_p: Vector3, strength: float):
			pulse(Kind.DIVE_LAND, device, strength)], 
		["knock_started", func(_p: Vector3, strength: float):
			pulse(Kind.KNOCKDOWN, device, strength)], 
		["block_broken", func(_p: Vector3): pulse(Kind.BLOCK, device)], 
	]
	for c in cbs:
		player.connect(c[0], c[1])
	player.set_meta("haptics_cbs", cbs)



static func unwire(player: Node) -> void :
	if not player.has_meta("haptics_cbs"):
		return
	for c in player.get_meta("haptics_cbs"):
		if player.is_connected(c[0], c[1]):
			player.disconnect(c[0], c[1])
	player.remove_meta("haptics_cbs")

static func _touch(kind: int, device: int) -> void :
	match kind:
		Player.TouchKind.SPIKE, Player.TouchKind.DUMP:
			pulse(Kind.SPIKE, device)
		Player.TouchKind.BUMP:
			pulse(Kind.BUMP, device)
		Player.TouchKind.SET:
			pulse(Kind.SET, device)
		Player.TouchKind.BLOCK:
			pulse(Kind.BLOCK, device)
		Player.TouchKind.CAROM:



			pulse(Kind.BUMP, device, 0.7)


static func pulse(kind: int, device: = -1, scale: = 1.0) -> void :

	var allow: bool = bool(_rumble_by_device.get(device, GameConfig.rumble))\
	if device >= 0 else GameConfig.rumble
	if not allow:
		return
	var dev: = device if device >= 0 else _active_device()
	if dev < 0:
		return
	var p: Array = _PULSE.get(kind, [])
	if p.is_empty():
		return
	var s: = clampf(scale, 0.4, 1.0)

	Input.start_joy_vibration(dev, float(p[0]) * s, float(p[1]) * s, float(p[2]))



static func stop(device: = -1) -> void :
	var dev: = device if device >= 0 else _active_device()
	if dev >= 0:
		Input.stop_joy_vibration(dev)

static func _active_device() -> int:
	if not InputPrompts.using_gamepad():
		return -1
	return InputPrompts.device_id()
