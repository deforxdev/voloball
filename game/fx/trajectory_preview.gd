class_name TrajectoryPreview
extends MultiMeshInstance3D







const MAX_DOTS: = 48
const DOT_SPACING: = 0.26
const STEP: = 0.016
const MAX_TIME: = 3.5



static func charge_color(charge: float) -> Color:
	charge = clampf(charge, 0.0, 1.0)
	if charge < 0.5:
		return Color(0.2, 0.9, 0.25).lerp(Color(1.0, 0.85, 0.1), charge * 2.0)
	return Color(1.0, 0.85, 0.1).lerp(Color(1.0, 0.2, 0.15), (charge - 0.5) * 2.0)

var _mat: StandardMaterial3D
var _ring_mat: StandardMaterial3D
var _landing: MeshInstance3D

func _ready() -> void :
	top_level = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	var dot: = SphereMesh.new()
	dot.radius = 0.055
	dot.height = 0.11
	dot.radial_segments = 8
	dot.rings = 4
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.9)
	dot.material = _mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = dot
	mm.instance_count = MAX_DOTS
	mm.visible_instance_count = 0
	multimesh = mm
	visible = false

	var ring: = TorusMesh.new()
	ring.inner_radius = 0.26
	ring.outer_radius = 0.34
	ring.rings = 24
	ring.ring_segments = 8
	_ring_mat = StandardMaterial3D.new()
	_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.9)
	_landing = MeshInstance3D.new()
	_landing.mesh = ring
	_landing.material_override = _ring_mat

	_landing.top_level = true
	_landing.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_landing.visible = false
	add_child(_landing)



func show_arc(launch: Vector3, vel: Vector3, gravity: float, floor_y: = 0.0, 
		color: = Color(1.0, 1.0, 1.0, 0.9), stop_after: = -1.0) -> void :



	_mat.albedo_color = color
	_ring_mat.albedo_color = Color(color.r, color.g, color.b, 0.85)



	var p: = launch
	var v: = vel
	var length: = 0.0
	var land: = launch
	var landed: = false
	var t: = 0.0
	while t < MAX_TIME:
		if stop_after > 0.0 and t >= stop_after:
			land = p
			landed = true
			break
		var np: = p + v * STEP
		v.y -= gravity * STEP
		length += p.distance_to(np)
		if np.y <= floor_y and v.y < 0.0:
			np.y = floor_y
			land = np
			landed = true
			break
		p = np
		t += STEP


	var spacing: = maxf(DOT_SPACING, length / float(MAX_DOTS))

	p = launch
	v = vel
	var placed: = 0
	var since: = spacing
	t = 0.0
	while placed < MAX_DOTS and t < MAX_TIME:
		if stop_after > 0.0 and t >= stop_after:
			break
		if since >= spacing:
			multimesh.set_instance_transform(placed, Transform3D(Basis(), p))
			placed += 1
			since = 0.0
		var np: = p + v * STEP
		v.y -= gravity * STEP
		since += p.distance_to(np)
		if np.y <= floor_y and v.y < 0.0:
			break
		p = np
		t += STEP
	if landed:
		_landing.global_position = land + Vector3(0.0, 0.02, 0.0)
	_landing.visible = landed
	multimesh.visible_instance_count = placed
	visible = placed > 0






func show_set(body: Player) -> void :
	if body == null or not GameConfig.ball_hints or not GameConfig.set_arc_on():
		clear()
		return
	var d: = body.set_preview()
	if d.is_empty():
		clear()
		return


	var col: Color = Player.RING_COLORS[Player.TouchKind.DUMP] if bool(d.get("dump", false))\
	else charge_color(float(d.power))
	show_arc(d.from, d.vel, Ball.PHYS.gravity, 0.0, col, float(d.stop))

func clear() -> void :
	visible = false
	multimesh.visible_instance_count = 0
	if _landing != null:
		_landing.visible = false
