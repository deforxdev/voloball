class_name ServeZoneMarker
extends MeshInstance3D





const ZONE_SIDE: = Rules.SERVE_ZONE_SIDE
const ZONE_FRONT: = Rules.SERVE_ZONE_FRONT
const ZONE_DEPTH: = Rules.SERVE_ZONE_DEPTH
const COLOR_IN: = Color(0.17, 0.96, 0.38, 1.0)
const COLOR_OUT: = Color(1.0, 0.19, 0.2, 1.0)
const GLOW_MARGIN: = 0.45

var _mat: ShaderMaterial
var _cx: = 0.0
var _half_l: = 9.0
var _size: = Vector2.ONE

func _init() -> void :
	var quad: = QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	mesh = quad
	_mat = ShaderMaterial.new()
	_mat.shader = preload("res://game/fx/serve_zone.gdshader")
	material_override = _mat
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visible = false

func setup(center_x: float, half_w: float, half_l: float) -> void :
	_cx = center_x
	_half_l = half_l
	_size = Vector2((half_w + ZONE_SIDE) * 2.0, ZONE_DEPTH)


	var quad_size: = _size + Vector2.ONE * GLOW_MARGIN * 2.0
	(mesh as QuadMesh).size = quad_size
	_mat.set_shader_parameter("size", _size)
	_mat.set_shader_parameter("quad_size", quad_size)



func tick(active: bool, side: float, inside: bool) -> void :
	if visible != active:
		visible = active
	if not active:
		return

	var center_z: = side * (_half_l - ZONE_FRONT + ZONE_DEPTH * 0.5)
	global_position = Vector3(_cx, 0.04, center_z)
	_mat.set_shader_parameter("tint", COLOR_IN if inside else COLOR_OUT)
