class_name SprintLines
extends Node3D









const LINE_SHADER: = preload("res://game/fx/speed_line.gdshader")
const POOL: = 16
const EVERY: = 0.035
const MIN_SPEED: = 3.5
const LIFE: = 0.22

var _lines: Array[MeshInstance3D] = []
var _tweens: Dictionary = {}
var _next: = 0
var _accum: = 0.0

func _ready() -> void :
	top_level = true
	for i in POOL:
		var quad: = QuadMesh.new()
		quad.size = Vector2(1.0, 1.0)
		var mat: = ShaderMaterial.new()
		mat.shader = LINE_SHADER
		mat.set_shader_parameter("tint", Color(1, 1, 1, 0))
		quad.material = mat
		var l: = MeshInstance3D.new()
		l.mesh = quad
		l.visible = false
		l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		l.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(l)
		_lines.append(l)


func tick(delta: float, body: Player) -> void :
	if delta <= 0.0 or body == null or not body.is_visible_in_tree():
		return
	var vel: = Vector3(body.velocity.x, 0.0, body.velocity.z)
	var speed: = vel.length()
	if not body.sprinting or not body.grounded() or speed < MIN_SPEED:
		_accum = 0.0
		return
	_accum += delta
	while _accum >= EVERY:
		_accum -= EVERY
		_spawn(body, vel / speed)

func _spawn(body: Player, along: Vector3) -> void :
	var pos: = body.global_position + Vector3(0.0, randf_range(0.3, 1.45), 0.0)
	var cam: = get_viewport().get_camera_3d()
	var to_cam: = (cam.global_position - pos) if cam != null else Vector3.UP
	var z: = to_cam - along * to_cam.dot(along)
	if z.length() < 0.05:
		z = Vector3.UP
	z = z.normalized()
	var y: = z.cross(along).normalized()
	var length: = randf_range(0.5, 0.95)
	var start: = pos + y * randf_range(-0.6, 0.6) - along * randf_range(0.25, 0.65)
	var l: = _lines[_next]
	_next = (_next + 1) % POOL
	if _tweens.has(l) and (_tweens[l] as Tween).is_valid():
		(_tweens[l] as Tween).kill()
	var mat: ShaderMaterial = (l.mesh as QuadMesh).material
	l.global_basis = Basis(along, y, z)
	l.scale = Vector3(length, randf_range(0.06, 0.09), 1.0)
	l.global_position = start - along * length * 0.5
	l.visible = true
	var c: = Color(1, 1, 1, 0.85)
	mat.set_shader_parameter("tint", c)
	mat.set_shader_parameter("head", 0.75)
	var t: = create_tween().set_parallel(true)
	_tweens[l] = t
	t.tween_property(l, "global_position", l.global_position - along * 1.1, LIFE)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(l, "scale", Vector3(length * 1.3, 0.01, 1.0), LIFE)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(mat, "shader_parameter/tint", Color(1, 1, 1, 0), LIFE)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.chain().tween_callback( func(): l.visible = false)
