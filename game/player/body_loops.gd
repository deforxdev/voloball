class_name BodyLoops
extends Node3D








const SPRINT: = preload("res://game/sfx/PlayerSfx/sprint.wav")
const TIRED: = preload("res://game/sfx/PlayerSfx/tired.wav")
const SPRINT_DB: = -7.0
const TIRED_DB: = -5.0
const SILENT_DB: = -40.0
const FADE: = 6.0
const MIN_SPEED: = 3.0

var _sprint: AudioStreamPlayer3D
var _tired: AudioStreamPlayer3D

func _ready() -> void :
	_sprint = _make(SPRINT)
	_tired = _make(TIRED)

func _make(stream: AudioStream) -> AudioStreamPlayer3D:
	var p: = AudioStreamPlayer3D.new()
	p.stream = stream
	p.bus = "voice"
	p.volume_db = SILENT_DB
	p.position = Vector3(0.0, 1.4, 0.0)
	p.unit_size = 6.0

	p.finished.connect( func():
		if p.volume_db > SILENT_DB + 1.0:
			p.play())
	add_child(p)
	return p


func tick(delta: float, body: Player) -> void :
	var paused: = delta <= 0.0
	_sprint.stream_paused = paused and _sprint.playing
	_tired.stream_paused = paused and _tired.playing
	if paused or body == null:
		return
	var pitch: = body.character.voice_pitch() if body.character != null else 1.0
	var speed: = Vector2(body.velocity.x, body.velocity.z).length()
	var sprinting: = body.sprinting and body.grounded() and speed > MIN_SPEED\
	and body.is_visible_in_tree()
	_drive(_sprint, sprinting, SPRINT_DB, pitch, delta)
	_drive(_tired, body.stamina_locked and body.is_visible_in_tree(), TIRED_DB, pitch, delta)

func _drive(p: AudioStreamPlayer3D, on: bool, loud_db: float, pitch: float, delta: float) -> void :
	var want: = loud_db if on else SILENT_DB
	p.volume_db = move_toward(p.volume_db, want, FADE * 10.0 * delta)
	p.pitch_scale = pitch
	if on and not p.playing:
		p.play()
	elif not on and p.playing and p.volume_db <= SILENT_DB + 0.5:
		p.stop()
