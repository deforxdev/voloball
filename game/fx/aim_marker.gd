class_name AimMarker
extends Node3D
















const SHADER: = preload("res://game/fx/floor_ring_overlay.gdshader")
const SIZE: = 1.9
const RING_OUTER: = 0.59
const PULSE_HZ: = 1.5
const PULSE_DEPTH: = 0.035






const COLOR_OWN: = Rules.HOME_COLOR




const COLOR_OPP: = Rules.AWAY_COLOR
const COLOR: = COLOR_OWN
const TINT_BLEND: = 14.0





const NET_CUT_RADIUS: = 0.19
const NET_CUT_FEATHER: = 0.11
const NET_CUT_BLEND: = 11.0

var net_mat: ShaderMaterial = null



var ring_enabled: = true
var _mat: ShaderMaterial
var _mesh: MeshInstance3D
var _t: = 0.0
var _tint: = COLOR_OWN
var _tint_want: = COLOR_OWN
var _base_pos: = Vector3.ZERO
var _rig: Node = null



func set_rig(rig: Node) -> void :
	_rig = rig
	process_priority = 500

func _ready() -> void :
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.render_priority = 12



	_mat.set_shader_parameter("ring_radius", 0.62)




	_mat.set_shader_parameter("ring_width", 0.052)
	_mat.set_shader_parameter("outline", 0.045)
	_mat.set_shader_parameter("dot_radius", 0.0)

	_mat.set_shader_parameter("arrow_len", 0.0)
	_mat.set_shader_parameter("arrow_base", 0.6)
	_mat.set_shader_parameter("arrow_half", 0.17)
	_mat.set_shader_parameter("pulse", 0.0)
	set_tint(COLOR)
	var plane: = PlaneMesh.new()
	plane.size = Vector2(SIZE, SIZE)
	plane.material = _mat
	_mesh = MeshInstance3D.new()
	_mesh.mesh = plane
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)








	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	set_process(true)

func _process(delta: float) -> void :


	_t += delta
	if not _tint.is_equal_approx(_tint_want):
		_tint = _tint.lerp(_tint_want, 1.0 - exp( - TINT_BLEND * delta))
		set_tint(_tint)






	if _rig != null and visible:
		global_position = _base_pos + _rig.shake_offset


	if _mesh != null and _mesh.visible != (visible and ring_enabled):
		_mesh.visible = visible and ring_enabled
	if net_mat != null:
		_tick_net_cut(delta)
		_tick_body_cut(delta)




func _tick_net_cut(delta: float) -> void :
	var cv: Variant = net_mat.get_shader_parameter("cut_radius")
	var cur: = float(cv) if cv != null else 0.0
	var target: = 0.0
	var cam: = get_viewport().get_camera_3d() if is_inside_tree() else null
	if visible and _at_opponent and cam != null and GameConfig.net_see_through:
		var vs: = get_viewport().get_visible_rect().size
		if vs.x > 0.0 and vs.y > 0.0:
			var sp: = cam.unproject_position(_base_pos)
			net_mat.set_shader_parameter("cut_center", Vector2(sp.x / vs.x, sp.y / vs.y))
			net_mat.set_shader_parameter("cut_aspect", vs.x / vs.y)
			net_mat.set_shader_parameter("cut_feather", NET_CUT_FEATHER)
			target = NET_CUT_RADIUS
	cur = lerpf(cur, target, 1.0 - exp( - NET_CUT_BLEND * delta))
	if cur < 0.001:
		cur = 0.0
	net_mat.set_shader_parameter("cut_radius", cur)








var body_rig: Node = null
var net_node: MeshInstance3D = null
var body_cut_on: = true
const BODY_CUT_YSCALE: = 0.55
const BODY_CUT_FEATHER: = 0.07
const BODY_CUT_GROW: = 1.25

func _tick_body_cut(delta: float) -> void :
	var cv: Variant = net_mat.get_shader_parameter("cut2_radius")
	var cur: = float(cv) if cv != null else 0.0
	var target: = 0.0
	var body: Player = null
	var cam: Camera3D = null
	if body_cut_on and GameConfig.net_see_through and body_rig != null\
	and is_instance_valid(body_rig) and not bool(body_rig.cinematic):
		body = body_rig.player
		cam = body_rig.camera
	if body != null and cam != null and is_instance_valid(body)\
	and cam == get_viewport().get_camera_3d():
		var feet: = body.global_position
		var head: = feet + Vector3(0.0, 1.95, 0.0)
		var vs: = get_viewport().get_visible_rect().size
		if vs.y > 0.0 and not cam.is_position_behind(head)\
		and _net_between(cam.global_position, feet + Vector3(0.0, 1.0, 0.0)):
			var hp: = cam.unproject_position(head)
			var fp: = cam.unproject_position(feet)
			var half_h: = absf(fp.y - hp.y) * 0.5 / vs.y
			net_mat.set_shader_parameter("cut2_center", (hp + fp) * 0.5 / vs)
			net_mat.set_shader_parameter("cut_aspect", vs.x / vs.y)
			net_mat.set_shader_parameter("cut2_yscale", BODY_CUT_YSCALE)
			net_mat.set_shader_parameter("cut2_feather", BODY_CUT_FEATHER)
			target = clampf(half_h * BODY_CUT_GROW * BODY_CUT_YSCALE, 0.03, 0.4)
	cur = lerpf(cur, target, 1.0 - exp( - NET_CUT_BLEND * delta))
	if cur < 0.001:
		cur = 0.0
	net_mat.set_shader_parameter("cut2_radius", cur)




func _net_between(a: Vector3, b: Vector3) -> bool:
	var box: = AABB(Vector3(-5.0, 0.6, 0.0), Vector3(10.0, 2.6, 0.0))
	if net_node != null and is_instance_valid(net_node):
		box = net_node.global_transform * net_node.get_aabb()
	var zc: = box.get_center().z
	if signf(a.z - zc) == signf(b.z - zc):
		return false
	var t: = (a.z - zc) / (a.z - b.z)
	var p: = a.lerp(b, t)
	return p.x > box.position.x - 0.3 and p.x < box.end.x + 0.3\
	and p.y > box.position.y - 0.4 and p.y < box.end.y + 0.4




func follow_point(point: Vector3) -> void :
	_base_pos = Vector3(point.x, maxf(0.02, SandDeform.decal_y), point.z)



func aim_at(point: Vector3, own_side: float, in_bounds: = true, 
		shake: = Vector3.ZERO, force_color: = Color(0, 0, 0, 0)) -> void :



	_base_pos = Vector3(point.x, maxf(0.02, SandDeform.decal_y), point.z)
	global_position = _base_pos + (_rig.shake_offset if _rig != null else shake)





	if force_color.a > 0.0:


		_tint_want = force_color
	elif not in_bounds:
		_tint_want = Color.WHITE
	else:


		_tint_want = Rules.half_color(point.z)
	_at_opponent = signf(point.z) != signf(own_side) and point.z != 0.0

var _at_opponent: = false

func aiming_at_opponent() -> bool:
	return _at_opponent



func set_tint(c: Color) -> void :
	_mat.set_shader_parameter("tint", Color(c.r, c.g, c.b, 1.0))


	_mat.set_shader_parameter("edge", Color(c.r, c.g, c.b, 0.94).darkened(0.88))

func tint() -> Color:
	return _mat.get_shader_parameter("tint")
