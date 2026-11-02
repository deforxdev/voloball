extends Node3D









const STIFF: = 150.0
const DAMP: = 10.0
const PIVOT_Y: = 2.2

var _ang: = Vector2.ZERO
var _vel: = Vector2.ZERO
var _rest: = Vector3.ZERO

func _ready() -> void :
	_rest = position
	set_process(false)

func bob(dir: float, k: = 1.0) -> void :


	_vel += Vector2(6.5, -3.0 * signf(dir if dir != 0.0 else 1.0)) * k
	set_process(true)

func _process(delta: float) -> void :
	_vel += ( - STIFF * _ang - DAMP * _vel) * delta
	_ang += _vel * delta
	_apply(clampf(_ang.x, -0.5, 0.5), clampf(_ang.y, -0.5, 0.5))
	if _ang.length() < 0.001 and _vel.length() < 0.01:
		_ang = Vector2.ZERO
		_vel = Vector2.ZERO
		_apply(0.0, 0.0)
		set_process(false)



func _apply(ax: float, az: float) -> void :
	var b: = Basis.from_euler(Vector3(ax, 0.0, az))
	basis = b
	var p0: = Vector3(0.0, PIVOT_Y, 0.0)
	position = _rest + (p0 - b * p0)
