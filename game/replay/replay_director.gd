class_name ReplayDirector
extends RefCounted








var data: ReplayData = null
var bodies: Array = []
var ball: Node3D = null

var time: = 0.0
var speed: = 1.0
var playing: = true
var sweat: = 0.0



var clip_start: = 0.0

func setup(d: ReplayData, body_list: Array, ball_node: Node3D) -> void :
	data = d
	bodies = body_list
	ball = ball_node
	time = d.time_at(0) if d != null else 0.0
	clip_start = time

func seek_clip(from: float) -> void :
	seek(from)
	clip_start = time

func elapsed() -> float:
	return time - clip_start

func duration() -> float:
	return data.duration() if data != null else 0.0

func start_time() -> float:
	return data.time_at(0) if data != null else 0.0

func end_time() -> float:
	if data == null or data.frame_count() == 0:
		return 0.0
	return data.time_at(data.frame_count() - 1)

func advance(delta: float) -> void :
	if playing:
		time = minf(time + delta * speed, end_time())

func finished() -> bool:
	return time >= end_time() - 0.0001

func seek(t: float) -> void :
	time = clampf(t, start_time(), end_time())

func apply(snap: = false) -> void :

	if data == null or data.frame_count() == 0:
		return
	var i: = data.index_before(time)
	if i < 0:
		return
	var j: int = mini(i + 1, data.frame_count() - 1)
	var t0: = data.time_at(i)
	var t1: = data.time_at(j)
	var f: = 0.0 if j == i or t1 <= t0 else clampf((time - t0) / (t1 - t0), 0.0, 1.0)

	sweat = lerpf(data.sweat_at(i), data.sweat_at(j), f)

	var b0: = data.ball_at(i)
	var b1: = data.ball_at(j)
	if ball != null:
		ball.global_position = Vector3(
			lerpf(b0[0], b1[0], f), lerpf(b0[1], b1[1], f), lerpf(b0[2], b1[2], f))
		ball.vel = Vector3(b0[3], b0[4], b0[5])




		ball.net_puppet = true
		ball.frozen = b0[6] > 0.5



		var look: = roundi(b0[6])
		ball.float_serve = look == -1



		ball.stop_clock = 1.0 if look == -2 else (-0.2 if look == -3 else Ball.STOP_NONE)
		ball._stop_seen = ball.stop_clock
		ball.curve = b0[7]
		ball.visible = true

	for slot in mini(bodies.size(), data.slots.size()):
		var body: Player = bodies[slot]
		if body == null:
			continue
		var a0: = data.player_at(i, slot)
		var a1: = data.player_at(j, slot)
		var pos: = Vector3(
			lerpf(a0[0], a1[0], f), lerpf(a0[1], a1[1], f), lerpf(a0[2], a1[2], f))

		var rot: = a0[6] + wrapf(a1[6] - a0[6], - PI, PI) * f
		var blended: = a0.duplicate()
		blended[6] = rot



		var anim_i: = ReplayData.NET_PLAYER_FLOATS
		var an: = _anim_at(body, a0[anim_i], a1[anim_i], t0, t1, time, f)
		body.replay_clip(an[0])
		blended[anim_i] = an[1]
		body.replay_apply(blended, pos, snap)

func pose_tick(delta: float) -> void :

	for b in bodies:
		if b != null:
			(b as Player).puppet_tick(delta)

func seek_anims(at: float) -> void :






	if data == null or data.frame_count() == 0:
		return
	var i: = data.index_before(at)
	if i < 0:
		return
	var j: int = mini(i + 1, data.frame_count() - 1)
	var t0: = data.time_at(i)
	var t1: = data.time_at(j)
	var f: = 0.0 if j == i or t1 <= t0 else clampf((at - t0) / (t1 - t0), 0.0, 1.0)
	var anim_i: = ReplayData.NET_PLAYER_FLOATS
	for slot in mini(bodies.size(), data.slots.size()):
		var body: Player = bodies[slot]
		if body == null:
			continue
		var a0: = data.player_at(i, slot)
		var a1: = data.player_at(j, slot)
		if a0.size() <= anim_i:
			continue
		var an: = _anim_at(body, a0[anim_i], a1[anim_i], t0, t1, at, f)


		if an[0] != "" and an[0] != body.replay_clip_name():
			continue
		body.seek_replay_anim(an[1])









func _anim_at(body: Player, v0: float, v1: float, t0: float, t1: float, 
		at: float, f: float) -> Array:
	var c0: = ReplayData.anim_code(v0)
	var c1: = ReplayData.anim_code(v1)
	if c0 == 0:
		return ["", clampf(v0 + wrapf(v1 - v0, -0.5, 0.5) * f, 0.0, 1.0)]
	var rig: ModelRig = body._model
	var p0: = ReplayData.anim_pos(v0)
	var p1: = ReplayData.anim_pos(v1)
	var n0: = data.clip_name(c0)
	var loops0: = rig != null and rig.clip_loops(n0)


	var restarted: = c1 == c0 and not loops0 and p1 < p0 - 0.02
	if (c1 == c0 or c1 == 0) and not restarted:
		if loops0:
			return [n0, fposmod(p0 + wrapf(p1 - p0, -0.5, 0.5) * f, 1.0)]
		return [n0, lerpf(p0, p1, f)]
	var n1: = data.clip_name(c1)
	var len1: = rig.clip_length(n1) if rig != null else 0.0
	var start: = clampf(t1 - p1 * len1, t0, t1)
	if at >= start:
		return [n1, clampf((at - start) / len1, 0.0, 1.0) if len1 > 0.0001 else p1]
	var len0: = rig.clip_length(n0) if rig != null else 0.0
	var on: = p0 + ((at - t0) / len0 if len0 > 0.0001 else 0.0)
	return [n0, fposmod(on, 1.0) if loops0 else clampf(on, 0.0, 1.0)]
