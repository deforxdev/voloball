extends Node

















const KNOCK_TOTAL: = 4.0
const HIT_R: = 0.55
const CELL: = 3.0
const ONLINE_WRAP: = 14400.0

var mm: MultiMesh
var mats: Array = []
var bodies_provider: = Callable()
var walk_z: = Vector2(-150, 150)
var walk_speed: = 1.3

var _clock: = 0.0
var _offset: = 0.0
var _knock_t: = PackedFloat32Array()
var _delay: = PackedFloat32Array()
var _origin: Array = []
var _custom: Array = []
var _grid: = {}
var _walkers: Array = []
var _ckpt: = {}

func setup(multimesh: MultiMesh, materials: Array) -> void :
	mm = multimesh
	mats = materials
	var n: = mm.instance_count
	_knock_t.resize(n)
	_delay.resize(n)
	for i in n:
		_knock_t[i] = -1000.0
		_delay[i] = 0.0
		_origin.append(mm.get_instance_transform(i).origin)
		var cd: = mm.get_instance_custom_data(i)
		_custom.append(cd)
		if cd.a > 1.5:
			_walkers.append(i)
		elif cd.a < 0.5:
			var o: Vector3 = _origin[i]
			var k: = Vector2i(floori(o.x / CELL), floori(o.z / CELL))
			if not _grid.has(k):
				_grid[k] = []
			(_grid[k] as Array).append(i)
		_write(i, Vector2.ZERO)

func _now() -> float:
	if Net.active:
		return fmod(Time.get_unix_time_from_system(), ONLINE_WRAP) - _offset
	return _clock

func _process(delta: float) -> void :
	_clock += delta
	var t: = _now()
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("crowd_time", t)
	if not bodies_provider.is_valid() or mm == null:
		return
	for b in bodies_provider.call():
		var body: = b as Node3D
		if body == null or not is_instance_valid(body):
			continue
		var p: = body.global_position
		var k: = Vector2i(floori(p.x / CELL), floori(p.z / CELL))
		for dx in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				for i in _grid.get(k + Vector2i(dx, dz), []):
					_try_knock(int(i), _origin[i], p, t)
		for i in _walkers:
			var o: Vector3 = _origin[i]
			if absf(o.x - p.x) > HIT_R:
				continue
			o.z = _walker_z(int(i), t)
			_try_knock(int(i), o, p, t)

func _try_knock(i: int, at: Vector3, body: Vector3, t: float) -> void :
	var d: = Vector2(at.x - body.x, at.z - body.z)
	if d.length() > HIT_R or absf(at.y - body.y) > 1.2:
		return
	if t - _knock_t[i] < KNOCK_TOTAL:
		return

	if _knock_t[i] > -999.0:
		_delay[i] += KNOCK_TOTAL
	_knock_t[i] = t
	_write(i, d.normalized() if d.length() > 0.01 else Vector2(1, 0))


func _walker_z(i: int, t: float) -> float:
	var cd: Color = _custom[i]
	var age: = t - _knock_t[i]
	var clock: = _knock_t[i] if age >= 0.0 and age < KNOCK_TOTAL else t
	var span: = walk_z.y - walk_z.x
	var dir: = 1.0 if cos(cd.b * TAU) >= 0.0 else -1.0
	return walk_z.x + fposmod(cd.g * span + (clock - _delay[i]) * walk_speed * dir, span)

func _write(i: int, push: Vector2) -> void :
	var b: = Basis(Vector3(_knock_t[i], _delay[i], 0.0), Vector3.UP, Vector3(push.x, 0.0, push.y))
	mm.set_instance_transform(i, Transform3D(b, _origin[i]))


func checkpoint() -> void :
	_offset = 0.0
	_ckpt = {"t": _now(), "k": _knock_t.duplicate(), "d": _delay.duplicate()}

func restore() -> void :
	if _ckpt.is_empty():
		return
	if Net.active:
		_offset = fmod(Time.get_unix_time_from_system(), ONLINE_WRAP) - float(_ckpt.t)
	else:
		_clock = float(_ckpt.t)
	_knock_t = (_ckpt.k as PackedFloat32Array).duplicate()
	_delay = (_ckpt.d as PackedFloat32Array).duplicate()
	for i in mm.instance_count:
		var b: = mm.get_instance_transform(i).basis
		_write(i, Vector2(b.z.x, b.z.z))
