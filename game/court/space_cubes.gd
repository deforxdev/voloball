@tool
class_name SpaceCubes
extends MultiMeshInstance3D







@export var drift: = 0.9
@export var drift_speed: = 0.35
@export var spin_speed: = 0.16
@export var top_color: Color = Color(0.97, 0.98, 1.0)
@export var bottom_color: Color = Color(0.78, 0.84, 0.93)

var _mat: ShaderMaterial = null
var _sig: = 0

var _origin: PackedVector3Array = []
var _axis: PackedVector3Array = []
var _scale: PackedFloat32Array = []
var _phase: PackedFloat32Array = []
var _rng: = RandomNumberGenerator.new()

func _ready() -> void :
	_build()

func _clear_pending() -> void :
	_origin = PackedVector3Array()
	_axis = PackedVector3Array()
	_scale = PackedFloat32Array()
	_phase = PackedFloat32Array()


func _central(p: Vector3) -> bool:
	return absf(p.x) < 9.0 and p.z > -8.0 and p.z < 18.0

func _add(p: Vector3, s: float) -> void :
	if _central(p):
		return
	_origin.append(p)
	_axis.append(Vector3(_rng.randf() * 2.0 - 1.0, _rng.randf() * 2.0 - 1.0, 
		_rng.randf() * 2.0 - 1.0).normalized())
	_scale.append(s)
	_phase.append(_rng.randf() * TAU)

func _trail(a: Vector3, ctrl: Vector3, b: Vector3, n: int, smin: float, smax: float) -> void :

	for i in n:
		var t: = float(i) / float(n - 1)
		var p: = a.lerp(ctrl, t).lerp(ctrl.lerp(b, t), t)
		p += Vector3(_rng.randf_range(-2.0, 2.0), _rng.randf_range(-2.0, 2.0), _rng.randf_range(-2.0, 2.0))

		_add(p, lerp(smax, smin, t) * _rng.randf_range(0.7, 1.1))

func _build() -> void :
	_rng.seed = 20260930
	_clear_pending()


	for p in [Vector3(-27, 17, -14), Vector3(29, 20, -24), Vector3(-22, 14, -30), 
			Vector3(26, 23, -8), Vector3(-32, 26, -44), Vector3(22, 15, -52)]:
		_add(p, _rng.randf_range(1.8, 2.9))


	for c in [Vector3(-17, 11, -3), Vector3(18, 12, -11), Vector3(-17, 13, -18), 
			Vector3(-15, 10, 8), Vector3(2, 13, -25)]:
		for _i in _rng.randi_range(4, 6):
			var off: = Vector3(_rng.randf_range(-4, 4), _rng.randf_range(-2, 3), _rng.randf_range(-4, 4))
			_add(c + off, _rng.randf_range(1.0, 1.8))


	_trail(Vector3(34, 20, -22), Vector3(28, 40, -52), Vector3(5, 38, -74), 16, 0.5, 1.2)
	_trail(Vector3(-30, 12, -10), Vector3(-34, 34, -46), Vector3(-9, 34, -66), 14, 0.5, 1.1)

	var mesh: = RoundedBox.make(Vector3.ONE, 0.16)
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://game/court/space_cube.gdshader")
	_mat.set_shader_parameter("top_color", top_color)
	_mat.set_shader_parameter("bottom_color", bottom_color)
	mesh.surface_set_material(0, _mat)

	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = _origin.size()
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in _origin.size():
		mm.set_instance_transform(i, Transform3D(
			Basis(_axis[i], _phase[i]).scaled(Vector3.ONE * _scale[i]), _origin[i]))
	multimesh = mm

func _process(_delta: float) -> void :

	if Engine.is_editor_hint():
		var s: = hash([drift, drift_speed, spin_speed, top_color, bottom_color])
		if s != _sig:
			_sig = s
			_build()
	if multimesh == null:
		return
	var t: = float(Time.get_ticks_msec()) * 0.001
	for i in _origin.size():
		var ph: = _phase[i]
		var bob: = Vector3(
			sin(t * drift_speed + ph) * drift, 
			cos(t * drift_speed * 0.8 + ph * 1.3) * drift, 
			sin(t * drift_speed * 0.6 + ph * 0.7) * drift * 0.6)
		var basis: = Basis(_axis[i], ph + t * spin_speed).scaled(Vector3.ONE * _scale[i])
		multimesh.set_instance_transform(i, Transform3D(basis, _origin[i] + bob))
