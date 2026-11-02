class_name ReplayRecorder
extends RefCounted










const MAX_MINUTES: = 20.0
const TRIM_MINUTES: = 2.0

var data: = ReplayData.new()
var recording: = false

var _accum: = 0.0
var _clock: = 0.0
var _bodies: Array = []
var _ball: Node3D = null
var _max_frames: = 0

func begin(bodies: Array, slot_info: Array, ball: Node3D, meta: Dictionary) -> void :
	data = ReplayData.new()
	data.slots = slot_info
	data.meta = meta.duplicate()


	data.meta["clips"] = []
	_clip_codes = {}
	_bodies = bodies
	_ball = ball
	_accum = 0.0
	_clock = 0.0
	_max_frames = int(MAX_MINUTES * 60.0 * ReplayData.RATE)
	_seat_seen = []
	for b in bodies:
		_seat_seen.append((b as Player).display_name())
	recording = true

func stop() -> void :
	recording = false

func tick(delta: float) -> void :
	if not recording or _ball == null:
		return
	_clock += delta
	_accum += delta
	var step: = 1.0 / ReplayData.RATE
	if _accum < step:
		return
	_accum = fmod(_accum, step)
	if data.frame_count() >= _max_frames:
		_trim_oldest()
	_capture()

func _trim_oldest() -> void :
	var drop: = mini(int(TRIM_MINUTES * 60.0 * ReplayData.RATE), data.frame_count())
	if drop <= 0:
		return
	data.frames = data.frames.slice(drop * data.stride())

	var floor_t: = data.time_at(0)
	var keep: Array = []
	for e in data.events:
		if float(e["t"]) >= floor_t:
			keep.append(e)
	data.events = keep

var sweat: = 0.0




var replaying: = false

func cue(kind: String, payload: Dictionary) -> void :

	if not recording or replaying:
		return
	data.events.append({"t": _clock, "k": kind, "d": payload})

func _capture() -> void :
	var row: = PackedFloat32Array()
	row.push_back(_clock)
	row.push_back(sweat)
	row.push_back(_ball.global_position.x)
	row.push_back(_ball.global_position.y)
	row.push_back(_ball.global_position.z)
	row.push_back(_ball.vel.x)
	row.push_back(_ball.vel.y)
	row.push_back(_ball.vel.z)




	var bstate: = 1.0 if _ball.frozen else 0.0
	if _ball.float_serve:
		bstate = -1.0
	elif _ball.stop_live():
		bstate = -2.0 if _ball.stop_clock > 0.0 else -3.0
	row.push_back(bstate)
	row.push_back(_ball.curve)
	for b in _bodies:
		var cap: = (b as Player).replay_capture()


		var last: = cap.size() - 1
		cap[last] = float(_clip_code((b as Player).replay_clip_name())) * 2.0 + clampf(cap[last], 0.0, 1.0)
		row.append_array(cap)
	data.frames.append_array(row)
	_watch_seats()










var _seat_seen: Array = []

func _watch_seats() -> void :
	if replaying:
		return
	for i in mini(_bodies.size(), _seat_seen.size()):
		var p: = _bodies[i] as Player
		if not is_instance_valid(p):
			continue
		var nm: = p.display_name()
		if nm == String(_seat_seen[i]):
			continue
		_seat_seen[i] = nm
		var look: CharacterConfig = p.character
		cue("seat", {"s": i, "name": nm, "bot": p.is_bot, 
			"cfg": look.to_dict() if look != null else {}, 
			"kit": p.replay_kit.map( func(c): return (c as Color).to_html(false)), 
			"pinny": look.pinny_color.to_html(false) if look != null and look.wear_pinny else "", 
			"pinny_acc": look.pinny_accent.to_html(false) if look != null and look.wear_pinny else ""})

var _clip_codes: = {}

func _clip_code(clip: String) -> int:
	if clip == "":
		return 0
	if not _clip_codes.has(clip):
		(data.meta["clips"] as Array).append(clip)
		_clip_codes[clip] = (data.meta["clips"] as Array).size()
	return int(_clip_codes[clip])



func window_start_time(lead_in: float) -> float:


	return maxf(_clock - lead_in, data.time_at(0))

func now() -> float:
	return _clock
