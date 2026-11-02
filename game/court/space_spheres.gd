@tool
class_name SpaceSpheres
extends Node3D





@export var ring_color: Color = Color(0.55, 0.68, 0.9)
@export var ring_alpha: = 0.75


@export var spheres: Array[Dictionary] = [
	{"pos": Vector3(-72.0, 44.0, -52.0), "r": 13.0, "rings": 2, "tilt": 0.5}, 
	{"pos": Vector3(80.0, 46.0, -56.0), "r": 12.0, "rings": 2, "tilt": -0.45}, 
]

var _sig: = 0

func _ready() -> void :
	_build()


func _process(_delta: float) -> void :
	if not Engine.is_editor_hint():
		set_process(false)
		return
	var s: = hash([ring_color, ring_alpha, str(spheres)])
	if s != _sig:
		_sig = s
		_build()

func _build() -> void :
	for c in get_children():
		c.queue_free()
	for d in spheres:
		_sphere(d.get("pos", Vector3.ZERO), d.get("r", 12.0), int(d.get("rings", 2)), d.get("tilt", 0.4))

func _sphere(pos: Vector3, r: float, rings: int, tilt: float) -> void :
	var sm: = SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 28
	sm.rings = 14
	var mat: = ShaderMaterial.new()
	mat.shader = load("res://game/court/orbit_sphere.gdshader")
	var body: = MeshInstance3D.new()
	body.mesh = sm
	body.material_override = mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.position = pos
	add_child(body)

	for i in rings:
		var torus: = TorusMesh.new()
		var rr: = r * (1.45 + float(i) * 0.4)
		torus.inner_radius = rr
		torus.outer_radius = rr + r * 0.04
		torus.rings = 64
		torus.ring_segments = 6

		var rmat: = ShaderMaterial.new()
		rmat.shader = load("res://game/court/venue_flat_alpha.gdshader")
		rmat.set_shader_parameter("albedo", 
			Color(ring_color.r, ring_color.g, ring_color.b, ring_alpha))
		var ring: = MeshInstance3D.new()
		ring.mesh = torus
		ring.material_override = rmat
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.position = pos
		ring.rotation = Vector3(tilt + float(i) * 0.3, float(i) * 0.5, tilt * 0.4)
		add_child(ring)
