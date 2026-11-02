class_name CalloutOverlay
extends SkeletonModifier3D












var _anim: Animation = null
var _time: = 0.0
var _inf: = 0.0
var _mask: PackedInt32Array = PackedInt32Array()

var _track_cache: = {}



func set_pose(anim: Animation, time: float, inf: float, mask: PackedInt32Array) -> void :
	_anim = anim
	_time = time
	_inf = inf
	_mask = mask

func _process_modification() -> void :
	if _anim == null or _inf <= 0.001 or _mask.is_empty():
		return
	var sk: = get_skeleton()
	if sk == null:
		return
	var tracks: Dictionary = _track_cache.get(_anim, {})
	if tracks.is_empty():
		tracks = _index(sk, _anim)
		_track_cache[_anim] = tracks
	for bone in _mask:
		var info = tracks.get(bone)
		if info == null:
			continue



		if info.rot >= 0:
			var q: Quaternion = _anim.rotation_track_interpolate(info.rot, _time)
			sk.set_bone_pose_rotation(bone, sk.get_bone_pose_rotation(bone).slerp(q, _inf))
		if info.pos >= 0:
			var p: Vector3 = _anim.position_track_interpolate(info.pos, _time)
			sk.set_bone_pose_position(bone, sk.get_bone_pose_position(bone).lerp(p, _inf))



func _index(sk: Skeleton3D, anim: Animation) -> Dictionary:
	var out: = {}
	for t in anim.get_track_count():
		var typ: = anim.track_get_type(t)
		if typ != Animation.TYPE_ROTATION_3D and typ != Animation.TYPE_POSITION_3D:
			continue
		var bname: = String(anim.track_get_path(t).get_concatenated_subnames())
		var b: = sk.find_bone(bname)
		if b < 0:
			continue
		if not out.has(b):
			out[b] = {"rot": -1, "pos": -1}
		if typ == Animation.TYPE_ROTATION_3D:
			out[b]["rot"] = t
		else:
			out[b]["pos"] = t
	return out
