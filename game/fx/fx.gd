class_name Fx
extends Node3D




var FLASH_POOL: int = 2 if MobileRender.enabled() else 8
var RING_POOL: int = 4 if MobileRender.enabled() else 10
var PUFF_POOL: int = 12 if MobileRender.enabled() else 96






var SPARK_POOL: int = 8 if MobileRender.enabled() else 48
var LINE_POOL: int = 8 if MobileRender.enabled() else 32
var SWIRL_POOL: int = 0 if MobileRender.enabled() else 4
const PUFF_SHADER: = preload("res://game/fx/puff.gdshader")
const BEAD_SHADER: = preload("res://game/fx/sweat_bead.gdshader")
var BEAD_POOL: int = 0 if MobileRender.enabled() else 72
const SWIRL_SHADER: = preload("res://game/fx/bam_swirl.gdshader")
const HITSTOP_SCALE: = 0.05
const FLASH_SHADER: = preload("res://game/fx/flash.gdshader")
const RING_SHADER: = preload("res://game/fx/impact_ring.gdshader")
const LINE_SHADER: = preload("res://game/fx/speed_line.gdshader")




const RING_NEUTRAL: = Color(0.86, 0.92, 1.0, 1.0)
const RING_TINT_BY_COMBO: = false

var _flashes: Array[MeshInstance3D] = []
var _rings: Array[MeshInstance3D] = []
var _puffs: Array[MeshInstance3D] = []
var _beads: Array[MeshInstance3D] = []
var _next_bead: = 0
var _sparks: Array[MeshInstance3D] = []
var _lines: Array[MeshInstance3D] = []
var _swirls: Array[MeshInstance3D] = []
var _swirl_follow: = {}
var _swirl_floor_y: = {}
var _swirl_half_h: = {}
var _next_swirl: = 0
var _next_flash: = 0
var _next_ring: = 0
var _next_puff: = 0
var _next_spark: = 0
var _next_line: = 0
var _tweens: = {}
var _camera_rig: CameraRig
var _camera: Camera3D

func _ready() -> void :
	for i in FLASH_POOL:
		var quad: = QuadMesh.new()
		quad.size = Vector2(1.0, 1.0)
		var mat: = ShaderMaterial.new()
		mat.shader = FLASH_SHADER
		mat.set_shader_parameter("tint", Color(1, 1, 1, 0))
		quad.material = mat
		var flash: = MeshInstance3D.new()
		flash.mesh = quad
		flash.visible = false
		flash.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(flash)
		_flashes.append(flash)
	for i in PUFF_POOL:
		var quad: = QuadMesh.new()
		quad.size = Vector2(0.5, 0.5)
		var mat: = ShaderMaterial.new()
		mat.shader = PUFF_SHADER
		mat.set_shader_parameter("tint", Color(0.96, 0.97, 1.0, 0))
		quad.material = mat
		var puff_disc: = MeshInstance3D.new()
		puff_disc.mesh = quad
		puff_disc.visible = false
		puff_disc.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(puff_disc)
		_puffs.append(puff_disc)
	for i in BEAD_POOL:
		var bq: = QuadMesh.new()
		bq.size = Vector2(1.0, 1.0)
		var bm: = ShaderMaterial.new()
		bm.shader = BEAD_SHADER
		bq.material = bm
		var bead: = MeshInstance3D.new()
		bead.mesh = bq
		bead.visible = false
		bead.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		bead.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(bead)
		_beads.append(bead)
	for i in SPARK_POOL:
		var quad: = QuadMesh.new()
		quad.size = Vector2(0.16, 0.16)
		var mat: = ShaderMaterial.new()
		mat.shader = PUFF_SHADER
		mat.set_shader_parameter("tint", Color(1, 1, 1, 0))
		mat.set_shader_parameter("lobes", 0.0)
		quad.material = mat
		var spark: = MeshInstance3D.new()
		spark.mesh = quad
		spark.visible = false
		spark.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(spark)
		_sparks.append(spark)
	for i in RING_POOL:


		var quad: = QuadMesh.new()
		quad.size = Vector2(2.0, 2.0)
		var mat: = ShaderMaterial.new()
		mat.shader = RING_SHADER
		mat.set_shader_parameter("alpha", 0.0)
		quad.material = mat
		var ring_mesh: = MeshInstance3D.new()
		ring_mesh.mesh = quad
		ring_mesh.visible = false
		ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring_mesh.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(ring_mesh)
		_rings.append(ring_mesh)
	for i in LINE_POOL:
		var quad: = QuadMesh.new()
		quad.size = Vector2(1.0, 1.0)
		var mat: = ShaderMaterial.new()
		mat.shader = LINE_SHADER
		mat.set_shader_parameter("tint", Color(1, 1, 1, 0))
		quad.material = mat
		var line: = MeshInstance3D.new()
		line.mesh = quad
		line.visible = false
		line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		line.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(line)
		_lines.append(line)
	for i in SWIRL_POOL:


		var cone: = CylinderMesh.new()
		cone.top_radius = 1.0
		cone.bottom_radius = 0.55
		cone.height = 1.0
		cone.radial_segments = 28
		cone.rings = 10
		cone.cap_top = false
		cone.cap_bottom = false
		var mat: = ShaderMaterial.new()
		mat.shader = SWIRL_SHADER
		mat.set_shader_parameter("progress", 0.0)
		cone.material = mat
		var swirl: = MeshInstance3D.new()
		swirl.mesh = cone
		swirl.visible = false
		swirl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		swirl.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(swirl)
		_swirls.append(swirl)

func setup(camera_rig: CameraRig) -> void :
	_camera_rig = camera_rig
	_camera = camera_rig.camera if camera_rig != null else null


func setup_camera(cam: Camera3D) -> void :
	_camera = cam





var recorder = null

func clear_transients() -> void :


	for tween in _tweens.values():
		if tween != null and (tween as Tween).is_valid():
			(tween as Tween).kill()
	_tweens.clear()
	for pool in [_flashes, _rings, _puffs, _beads, _sparks, _lines, _swirls]:
		for item in pool:
			(item as GeometryInstance3D).visible = false

func impact(pos: Vector3, strength: float, axis: = Vector3.UP, heavy: = false, 
		rim: = Color(0, 0, 0, 0)) -> void :






	if recorder != null:
		recorder.cue("fx_impact", {"p": pos, "s": strength, "a": axis, "hv": heavy, 
			"c": rim})
	_spawn_flash(pos, strength)
	ring(pos, axis, strength, rim)
	if not heavy:
		return


	speed_lines(pos, axis, strength, rim)
	if _camera_rig != null:
		_camera_rig.shake(0.18 * strength)
	if strength > 0.5:
		_hitstop(0.04 + 0.05 * strength)

func shield_crack(pos: Vector3) -> void :
	if recorder != null:
		recorder.cue("crack", {"p": pos})


	_spawn_flash(pos, 1.3)
	ring(pos, Vector3.FORWARD, 1.35)
	burst(pos, 1.0, Vector3.UP, 0.0)
	if _camera_rig != null:



		_camera_rig.shake(0.3)
	_hitstop(0.11)

func burst(pos: Vector3, strength: float, dir: = Vector3.ZERO, 
		wet: = 0.0) -> void :
	if recorder != null:
		recorder.cue("burst", {"p": pos, "s": strength, "d": dir, "w": wet})




	var count: = clampi(int(6.0 + strength * 12.0 + wet * 14.0), 6, 26)
	var tint: = Color(1.0, 0.97, 0.85, 1.0).lerp(
		Color(0.72, 0.88, 1.0, 1.0), clampf(wet, 0.0, 1.0))
	var along: = dir.normalized() if dir.length() > 0.01 else Vector3.ZERO
	for i in count:
		var s: = _sparks[_next_spark]
		_next_spark = (_next_spark + 1) % SPARK_POOL
		_kill_tween(s)
		var mat: ShaderMaterial = (s.mesh as QuadMesh).material
		s.global_position = pos
		var scale: = randf_range(0.6, 1.5) * (0.7 + strength * 0.6)
		s.scale = Vector3.ONE * scale
		s.visible = true
		mat.set_shader_parameter("tint", tint)


		var away: = Vector3(randf_range(-1.0, 1.0), randf_range(-0.5, 1.0), 
			randf_range(-1.0, 1.0)).normalized()
		var travel: = away * randf_range(0.5, 1.3) * (0.6 + strength) + along * randf_range(0.3, 1.0) * strength
		var life: = randf_range(0.22, 0.42)
		var tween: = create_tween()
		_tweens[s] = tween
		tween.set_ignore_time_scale(true)
		tween.set_parallel(true)
		tween.tween_property(s, "global_position", pos + travel, life).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(s, "scale", Vector3.ONE * scale * 0.15, life).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var faded: = tint
		faded.a = 0.0
		tween.tween_property(mat, "shader_parameter/tint", faded, life)
		tween.chain().tween_callback( func(): s.visible = false)

func ring(pos: Vector3, axis: Vector3, strength: float, rim: = Color(0, 0, 0, 0), 
		life: = 0.26, alpha: = 1.0) -> void :
	if recorder != null:
		recorder.cue("ring", {"p": pos, "a": axis, "s": strength, "c": rim, 
			"l": life, "al": alpha})





	var r: = _rings[_next_ring]
	_next_ring = (_next_ring + 1) % RING_POOL
	_kill_tween(r)
	var a: = axis.normalized() if axis.length() > 0.01 else Vector3.UP
	r.global_position = pos

	if absf(a.dot(Vector3.BACK)) > 0.999:
		r.global_basis = Basis.IDENTITY if a.z > 0.0\
		else Basis(Vector3.UP, PI)
	else:
		r.global_basis = Basis(Quaternion(Vector3.BACK, a))
	var mat: ShaderMaterial = (r.mesh as QuadMesh).material


	r.scale = Vector3.ONE * (0.45 + 0.55 * strength)
	r.visible = true
	var tint: = rim if (rim.a > 0.0 and RING_TINT_BY_COMBO) else RING_NEUTRAL
	mat.set_shader_parameter("rim", tint)
	mat.set_shader_parameter("rot", randf() * TAU)
	mat.set_shader_parameter("arcs", 3.0 if strength >= 0.7 else 2.0)
	mat.set_shader_parameter("thick", 0.09 + 0.05 * clampf(strength, 0.0, 1.5))
	mat.set_shader_parameter("spread", 0.0)
	mat.set_shader_parameter("alpha", alpha)
	var tween: = create_tween()
	_tweens[r] = tween
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(mat, "shader_parameter/spread", 1.0, life)\
	.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/alpha", 0.0, life)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback( func(): r.visible = false)






func bam_swirl(pos: Vector3, strength: = 1.0, follow: Node3D = null) -> void :
	if _swirls.is_empty():
		return
	if recorder != null:
		recorder.cue("swirl", {"p": pos, "s": strength})
	var s: = _swirls[_next_swirl]
	_next_swirl = (_next_swirl + 1) % SWIRL_POOL
	_kill_tween(s)
	var mat: ShaderMaterial = (s.mesh as CylinderMesh).material



	var h: = 3.2 + 0.6 * strength
	var rad: = 0.55 + 0.18 * strength




	var start_rad: = rad * 0.6
	var end_rad: = rad * 1.2
	s.scale = Vector3(start_rad, h, start_rad)
	_swirl_floor_y[s] = pos.y
	_swirl_half_h[s] = h * 0.5
	s.global_position = Vector3(pos.x, pos.y + h * 0.5, pos.z)
	_swirl_follow[s] = follow if follow != null and is_instance_valid(follow) else null
	s.rotation.y = randf() * TAU
	s.visible = true
	mat.set_shader_parameter("progress", 0.0)



	var life: = 1.05
	var tween: = create_tween()
	_tweens[s] = tween
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(mat, "shader_parameter/progress", 1.0, life)

	tween.tween_property(s, "scale", Vector3(end_rad, h, end_rad), life)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback( func():
		s.visible = false
		_swirl_follow.erase(s))



func _process(_delta: float) -> void :
	if _swirl_follow.is_empty():
		return
	for s in _swirl_follow:
		var body: Node3D = _swirl_follow[s]
		if body == null or not is_instance_valid(body) or not (s as Node3D).visible:
			continue
		var half_h: float = _swirl_half_h.get(s, 0.0)
		var base_y: float = _swirl_floor_y.get(s, 0.0)
		(s as Node3D).global_position = Vector3(body.global_position.x, 
			base_y + half_h, body.global_position.z)




func speed_lines(pos: Vector3, dir: Vector3, strength: float, 
		rim: = Color(0, 0, 0, 0)) -> void :
	if recorder != null:
		recorder.cue("lines", {"p": pos, "d": dir, "s": strength, "c": rim})
	var along: = dir.normalized() if dir.length() > 0.01 else Vector3.UP
	var tint: = rim if (rim.a > 0.0 and RING_TINT_BY_COMBO) else Color.WHITE
	var count: = clampi(int(3.0 + strength * 3.0), 3, 9)
	var to_cam: = Vector3.UP
	if _camera != null:
		to_cam = _camera.global_position - pos


	var z: = to_cam - along * to_cam.dot(along)
	if z.length() < 0.05:
		z = Vector3.UP - along * Vector3.UP.dot(along)
	if z.length() < 0.05:
		z = Vector3.RIGHT
	z = z.normalized()
	var y: = z.cross(along).normalized()
	for i in count:

		var side: = y * randf_range(-0.35, 0.35) * (0.6 + strength * 0.5)\
		+ z * randf_range(-0.12, 0.12)
		var length: = randf_range(0.45, 0.9) * (0.7 + strength * 0.5)



		var start: = pos + side - along * randf_range(0.1, 0.35)
		_throw_line(start - along * length * 0.5, along, z, length, 
			randf_range(0.05, 0.09), 
			- along * randf_range(0.6, 1.3) * (0.6 + strength * 0.5), 
			randf_range(0.11, 0.16), tint, randf_range(0.55, 0.75))





func floor_gust(pos: Vector3, hard: float) -> void :
	if recorder != null:
		recorder.cue("gust", {"p": pos, "h": hard})
	var count: = clampi(int(5.0 + hard * 7.0), 5, 12)
	for i in count:
		var ang: = randf() * TAU
		var out: = Vector3(cos(ang), 0.0, sin(ang))
		var length: = randf_range(0.4, 0.8) * (0.7 + hard * 0.9)

		_throw_line(pos + out * (randf_range(0.15, 0.35) + length * 0.5), out, 
			Vector3.UP, length, 
			randf_range(0.05, 0.1) * (0.8 + hard * 0.5), 
			out * randf_range(0.8, 1.5) * (0.6 + hard * 0.7), 
			randf_range(0.16, 0.26), Color.WHITE, randf_range(0.2, 0.4))

	for i in clampi(int(2.0 + hard * 4.0), 2, 6):
		var ang: = randf() * TAU
		puff(pos + Vector3(cos(ang), 0.0, sin(ang)) * randf_range(0.15, 0.45) * (0.7 + hard))
	if hard > 0.6:
		_spawn_flash(pos + Vector3(0.0, 0.08, 0.0), 0.6 + hard * 0.6)




	if hard > 0.45:
		var linger: = (hard - 0.45) / 0.55
		var tween: = create_tween()
		tween.set_ignore_time_scale(true)
		tween.tween_interval(0.1)
		tween.tween_callback( func():
			ring(pos, Vector3.UP, 1.2 + 0.5 * linger, Color(0, 0, 0, 0), 
				0.7 + 0.3 * linger, 0.45)
			for i in clampi(int(3.0 + linger * 4.0), 3, 7):
				var ang: = randf() * TAU
				var out: = Vector3(cos(ang), 0.0, sin(ang))
				var length: = randf_range(0.5, 1.0) * (0.8 + linger * 0.6)
				_throw_line(pos + out * (randf_range(0.5, 0.9) + length * 0.5), out, 
					Vector3.UP, length, randf_range(0.03, 0.06), 
					out * randf_range(0.5, 1.0) * (0.7 + linger * 0.6), 
					randf_range(0.55, 0.85), Color.WHITE, randf_range(0.3, 0.5), 0.5))




func _throw_line(centre: Vector3, along: Vector3, normal: Vector3, length: float, 
		thin: float, travel: Vector3, life: float, tint: Color, head: float, 
		alpha: = 0.95) -> void :
	var l: = _lines[_next_line]
	_next_line = (_next_line + 1) % LINE_POOL
	_kill_tween(l)
	var mat: ShaderMaterial = (l.mesh as QuadMesh).material
	var z: = normal.normalized()
	var y: = z.cross(along).normalized()
	l.global_basis = Basis(along, y, z)
	l.scale = Vector3(length, thin, 1.0)
	l.global_position = centre
	l.visible = true
	var c: = tint
	c.a = alpha
	mat.set_shader_parameter("tint", c)
	mat.set_shader_parameter("head", head)
	var tween: = create_tween()
	_tweens[l] = tween
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(l, "global_position", l.global_position + travel, life)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(l, "scale", Vector3(length * 1.4, thin * 0.3, 1.0), life)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var faded: = c
	faded.a = 0.0
	tween.tween_property(mat, "shader_parameter/tint", faded, life)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback( func(): l.visible = false)

func _kill_tween(node: Node) -> void :


	if _tweens.has(node) and _tweens[node].is_valid():
		_tweens[node].kill()

func _spawn_flash(pos: Vector3, strength: float) -> void :
	var flash: = _flashes[_next_flash]
	_next_flash = (_next_flash + 1) % FLASH_POOL
	_kill_tween(flash)
	var mat: ShaderMaterial = (flash.mesh as QuadMesh).material
	flash.global_position = pos
	flash.scale = Vector3.ONE * (0.3 + 0.3 * strength)
	flash.visible = true
	mat.set_shader_parameter("tint", Color(1, 1, 1, 0.9))
	var tween: = create_tween()
	_tweens[flash] = tween
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", 
		Vector3.ONE * (1.0 + 1.4 * strength), 0.18)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/tint", Color(1, 1, 1, 0), 0.18)
	tween.chain().tween_callback( func(): flash.visible = false)

func puff(pos: Vector3, dir: = Vector3.ZERO, size: = 1.0) -> void :
	if recorder != null:
		recorder.cue("puff", {"p": pos, "d": dir, "s": size})





	var back: = Vector3(dir.x, 0.0, dir.z)
	var moving: = back.length() > 0.05
	if moving:
		back = back.normalized()
	for i in 3:






		var p: = _claim_puff()
		if p == null:
			return
		_kill_tween(p)
		var mat: ShaderMaterial = (p.mesh as QuadMesh).material



		var tail: = float(i)
		var spot: = pos + Vector3(randf_range(-0.12, 0.12), randf_range(0.0, 0.1), 
			randf_range(-0.12, 0.12))
		if moving:
			spot -= back * (tail * 0.16)
		else:
			spot += Vector3(randf_range(-0.06, 0.06), 0.0, randf_range(-0.06, 0.06))
		var grow: = randf_range(0.9, 1.15) * (1.0 - 0.16 * tail) * size
		var life: = 0.62 - 0.06 * tail
		p.global_position = spot
		p.scale = Vector3.ONE * randf_range(0.24, 0.34) * (1.0 - 0.1 * tail) * size
		p.visible = true
		mat.set_shader_parameter("tint", Color(0.96, 0.97, 1.0, 0.9))
		mat.set_shader_parameter("rot", randf() * TAU)
		mat.set_shader_parameter("dissolve", 0.0)
		var tween: = create_tween()
		_tweens[p] = tween
		tween.set_ignore_time_scale(true)
		tween.set_parallel(true)


		tween.tween_property(p, "scale", Vector3.ONE * grow, life * 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(p, "global_position", spot + Vector3(
			randf_range(-0.18, 0.18), randf_range(0.28, 0.45), 
			randf_range(-0.18, 0.18)), life)
		tween.tween_property(mat, "shader_parameter/tint", 
			Color(0.96, 0.97, 1.0, 0.0), life * 0.45)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(life * 0.55)


		tween.tween_property(mat, "shader_parameter/dissolve", 0.95, life * 0.45)\
		.set_delay(life * 0.55)
		tween.chain().tween_callback( func(): p.visible = false)

func land_poof(pos: Vector3) -> void :


	if recorder != null:
		recorder.cue("land_poof", {"p": pos})
	var count: = 6
	var base: = randf() * TAU
	for i in count:
		var p: = _claim_puff()
		if p == null:
			return
		_kill_tween(p)
		var mat: ShaderMaterial = (p.mesh as QuadMesh).material
		var ang: = base + TAU * float(i) / float(count) + randf_range(-0.2, 0.2)
		var out: = Vector3(cos(ang), 0.0, sin(ang))
		var spot: = pos + out * 0.12
		var life: = randf_range(0.5, 0.62)
		p.global_position = spot
		p.scale = Vector3.ONE * randf_range(0.28, 0.38)
		p.visible = true
		mat.set_shader_parameter("tint", Color(0.96, 0.97, 1.0, 0.9))
		mat.set_shader_parameter("rot", randf() * TAU)
		mat.set_shader_parameter("dissolve", 0.0)
		var tween: = create_tween()
		_tweens[p] = tween
		tween.set_ignore_time_scale(true)
		tween.set_parallel(true)

		tween.tween_property(p, "scale", Vector3.ONE * randf_range(0.7, 0.95), life * 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(p, "global_position", spot + out * randf_range(0.55, 0.8)
			+ Vector3(0.0, randf_range(0.12, 0.25), 0.0), life)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(mat, "shader_parameter/tint", 
			Color(0.96, 0.97, 1.0, 0.0), life * 0.45)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(life * 0.55)
		tween.tween_property(mat, "shader_parameter/dissolve", 0.95, life * 0.45)\
		.set_delay(life * 0.55)
		tween.chain().tween_callback( func(): p.visible = false)



func _claim_puff() -> MeshInstance3D:
	for i in PUFF_POOL:
		var p: = _puffs[_next_puff]
		_next_puff = (_next_puff + 1) % PUFF_POOL
		if not p.visible:


			((p.mesh as QuadMesh).material as ShaderMaterial)\
			.set_shader_parameter("dissolve", 0.0)
			return p
	return null

func sweat(pos: Vector3) -> void :
	if _beads.is_empty():
		return




	var p: = _beads[_next_bead]
	_next_bead = (_next_bead + 1) % BEAD_POOL
	_kill_tween(p)
	var mat: ShaderMaterial = (p.mesh as QuadMesh).material
	var size: = randf_range(0.09, 0.15)
	p.global_position = pos
	p.scale = Vector3.ONE * size * 0.4
	p.visible = true
	mat.set_shader_parameter("fade", 1.0)
	var tween: = create_tween()
	_tweens[p] = tween
	tween.set_ignore_time_scale(true)
	if randf() < 0.2:

		mat.set_shader_parameter("stretch", 1.0)
		var top: = pos + Vector3(randf_range(-0.25, 0.25), randf_range(0.25, 0.45), 
			randf_range(-0.25, 0.25))
		tween.tween_property(p, "scale", Vector3.ONE * size * 1.15, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(p, "global_position", top, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(p, "scale", Vector3.ONE * size * 1.5, 0.08)
		tween.parallel().tween_property(mat, "shader_parameter/fade", 0.0, 0.08)
	else:

		mat.set_shader_parameter("stretch", 1.22)
		var out: = pos + Vector3(randf_range(-0.3, 0.3), randf_range(0.04, 0.14), 
			randf_range(-0.3, 0.3))
		var land: = Vector3(out.x * 1.0 + randf_range(-0.1, 0.1), pos.y - 0.9, 
			out.z + randf_range(-0.1, 0.1))
		tween.tween_property(p, "scale", Vector3.ONE * size, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(p, "global_position", out, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(p, "global_position", land, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(mat, "shader_parameter/fade", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback( func(): p.visible = false)

func splash(pos: Vector3) -> void :


	if recorder != null:
		recorder.cue("splash", {"p": pos})
	for i in 4:
		var p: = _claim_puff()
		if p == null:
			return
		_kill_tween(p)
		var mat: ShaderMaterial = (p.mesh as QuadMesh).material
		var spot: = pos + Vector3(randf_range(-0.12, 0.12), 0.02, 
			randf_range(-0.12, 0.12))
		p.global_position = spot
		p.scale = Vector3.ONE * randf_range(0.08, 0.14)
		p.visible = true
		mat.set_shader_parameter("tint", Color(0.85, 0.95, 1.0, 0.95))

		var up: = spot + Vector3(randf_range(-0.35, 0.35), randf_range(0.4, 0.7), 
			randf_range(-0.35, 0.35))
		var down: = Vector3(up.x, spot.y - 0.05, up.z)
		var tween: = create_tween()
		_tweens[p] = tween
		tween.set_ignore_time_scale(true)
		tween.set_parallel(true)
		tween.tween_property(p, "scale", Vector3.ONE * randf_range(0.16, 0.24), 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		tween.tween_property(p, "global_position", up, 0.22)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(p, "global_position", down, 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(mat, "shader_parameter/tint", 
			Color(0.85, 0.95, 1.0, 0.0), 0.52)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback( func(): p.visible = false)

func big_spike(pos: Vector3, dir: Vector3, rim: = Color(0, 0, 0, 0), tier: = 0) -> void :
	if MobileRender.enabled():
		return
	if recorder != null:
		recorder.cue("bigspike", {"p": pos, "d": dir, "c": rim, "t": tier})







	var top: = tier >= 3
	_spawn_flash(pos, 1.6 if top else 1.3)
	ring(pos, dir, 1.7 if top else 1.3, rim)
	speed_lines(pos, dir, 2.0 if top else 1.4, rim)
	var tween: = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_interval(0.08)
	tween.tween_callback( func(): ring(pos, dir, 1.0 if top else 0.75, rim))
	if top:
		tween.tween_interval(0.07)
		tween.tween_callback( func():
			ring(pos, dir, 0.6, rim)
			speed_lines(pos, dir, 1.2, rim))









func combo_burst(pos: Vector3, dir: Vector3, tier: = 3) -> void :
	if MobileRender.enabled():
		return
	tier = clampi(tier, 1, 3)
	if recorder != null:
		recorder.cue("combo_burst", {"p": pos, "d": dir, "t": tier})
	_spawn_flash(pos, 0.4 + 0.14 * float(tier))
	var col: Color = Player.combo_color(tier)
	var count: int = [9, 11, 13][tier - 1]
	var rad: float = [0.058, 0.067, 0.078][tier - 1]
	var reach: float = [0.95, 1.2, 1.5][tier - 1]
	var along: = dir.normalized() if dir.length() > 0.01 else Vector3.UP
	for i in count:
		var m: = MeshInstance3D.new()
		var cap: = CapsuleMesh.new()
		cap.radius = rad
		cap.height = rad * 6.0
		m.mesh = cap
		var mat: = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = col
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.material_override = mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(m)
		m.global_position = pos
		var away: = Vector3(randf_range(-1.0, 1.0), randf_range(-0.2, 1.0), 
			randf_range(-1.0, 1.0)).normalized()
		var travel: = (away + along * 0.7).normalized()
		if absf(travel.dot(Vector3.UP)) < 0.99:
			m.global_basis = Basis(Quaternion(Vector3.UP, travel))
		var s: = randf_range(0.85, 1.3)
		m.scale = Vector3.ONE * s
		var life: = randf_range(0.5, 0.72)

		var tw: = create_tween().set_ignore_time_scale(true).set_parallel(true)
		tw.tween_property(m, "global_position", 
			pos + travel * reach * randf_range(0.7, 1.05), life)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(m, "scale", Vector3.ONE * s * 0.26, life)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(m.queue_free)

		var fade: = create_tween().set_ignore_time_scale(true)
		fade.tween_interval(life * 0.5)
		fade.tween_property(mat, "albedo_color:a", 0.0, life * 0.5)

func slowmo(rate: float, duration: float) -> void :
	if recorder != null:
		recorder.cue("slowmo", {"r": rate, "d": duration})



	if Engine.time_scale < 1.0:
		return
	GameConfig.slow_time(rate, duration)

func _hitstop(duration: float) -> void :

	if Engine.time_scale < 1.0:
		return
	GameConfig.slow_time(HITSTOP_SCALE, duration)
