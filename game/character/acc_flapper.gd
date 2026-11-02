extends Node
















const STEPPED_TICKS: = 2

var flaps_per_s: = 2.0
var angle_deg: = 20.0
var axis: = Vector3.RIGHT
var _skel: Skeleton3D = null
var _bones: = PackedInt32Array()
var _rest: Array[Quaternion] = []
var _driven_tick: = -100

func setup(sk: Skeleton3D, names: PackedStringArray) -> bool:
	_skel = sk
	for n in names:
		var b: = sk.find_bone(n)
		if b >= 0:
			_bones.append(b)
			_rest.append(sk.get_bone_rest(b).basis.get_rotation_quaternion())
	return not _bones.is_empty()


func drive() -> void :
	_driven_tick = Engine.get_physics_frames()
	_turn()

func _process(_delta: float) -> void :
	if Engine.get_physics_frames() - _driven_tick > STEPPED_TICKS:
		_turn()

func _turn() -> void :
	if _skel == null or not is_instance_valid(_skel):
		return
	var a: = sin(Time.get_ticks_msec() / 1000.0 * flaps_per_s * TAU) * deg_to_rad(angle_deg)
	var turn: = Quaternion(axis.normalized(), a)
	for i in _bones.size():
		_skel.set_bone_pose_rotation(_bones[i], _rest[i] * turn)
