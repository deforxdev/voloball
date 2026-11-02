@tool
extends Node3D






















const TREE_SHADER: = preload("res://game/stage/kits/tree_card.gdshader")
const TREE_ATLAS: = preload("res://game/stage/kits/tree_impostor.png")
const SHAFT_SHADER: = preload("res://game/court/light_shaft.gdshader")
const POOL_SHADER: = preload("res://game/court/light_pool.gdshader")





const SIDE_WINDOWS_Z: = [-28.53, -18.9, -9.32, 0.26, 19.43]
const END_WINDOWS_X: = [-9.28, 9.28]
const SIDE_WALL_X: = 16.19
const END_WALL_Z: = 34.48



const HIDE: = ["Roof_019"]




const WALL_X: = 15.98
const WALL_Z: = 33.83


@export_group("Sand ground")
@export var sand_color: = Color(0.86, 0.74, 0.53):
	set(v):
		sand_color = v
		_dirty()
@export_group("Trees")
@export_range(0, 200) var tree_count: = 48:
	set(v):
		tree_count = v
		_dirty()
@export_range(2.0, 30.0) var tree_height: = 12.0:
	set(v):
		tree_height = v
		_dirty()
@export var tree_haze_color: = Color(0.8, 0.87, 0.96):
	set(v):
		tree_haze_color = v
		_dirty()
@export_range(0.0, 1.0) var tree_haze_amt: = 0.55:
	set(v):
		tree_haze_amt = v
		_dirty()
@export_group("Floor light (under the low windows)")
@export var pool_color: = Color(1.0, 0.95, 0.82):
	set(v):
		pool_color = v
		_dirty()
@export_range(0.0, 1.0) var pool_intensity: = 0.38:
	set(v):
		pool_intensity = v
		_dirty()
@export_range(0.5, 8.0) var pool_depth: = 3.2:
	set(v):
		pool_depth = v
		_dirty()
@export_group("Sun shafts")

@export var shafts_on: = false:
	set(v):
		shafts_on = v
		_dirty()
@export var shaft_color: = Color(1.0, 0.97, 0.88):
	set(v):
		shaft_color = v
		_dirty()
@export_range(0.0, 1.0) var shaft_intensity: = 0.3:
	set(v):
		shaft_intensity = v
		_dirty()
@export_range(0.0, 70.0) var shaft_tilt_deg: = 14.0:
	set(v):
		shaft_tilt_deg = v
		_dirty()
@export_range(1, 10) var shaft_rows_per_side: = 6:
	set(v):
		shaft_rows_per_side = v
		_dirty()
@export_range(1.0, 20.0) var shaft_height: = 6.4:
	set(v):
		shaft_height = v
		_dirty()

var _booted: = false

func _ready() -> void :
	var gym: = get_node_or_null("Gym")
	if gym != null:
		for nm in HIDE:
			var n: = gym.get_node_or_null(nm) as Node3D
			if n != null:
				n.visible = false
	_booted = true
	_build_exterior()



func _dirty() -> void :
	if _booted and is_inside_tree():
		_build_exterior.call_deferred()

func _build_exterior() -> void :
	var old: = get_node_or_null("_Exterior")
	if old != null:
		old.free()
	var root: = Node3D.new()
	root.name = "_Exterior"
	add_child(root)
	_build_ground(root)
	_build_trees(root)
	_build_floor_light(root)
	if shafts_on:
		_build_shafts(root)





func _build_ground(root: Node3D) -> void :
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = sand_color
	var mesh: = PlaneMesh.new()
	mesh.size = Vector2(300, 300)
	var mi: = MeshInstance3D.new()
	mi.name = "SandGround"
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(0, -0.3, 0)
	root.add_child(mi)



func _build_floor_light(root: Node3D) -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = POOL_SHADER
	mat.set_shader_parameter("beam", pool_color)
	mat.set_shader_parameter("intensity", pool_intensity)
	mat.set_shader_parameter("softness", 0.6)
	var holder: = Node3D.new()
	holder.name = "FloorLight"
	root.add_child(holder)
	var inset: = pool_depth * 0.5 + 0.35
	for side in [-1.0, 1.0]:
		for z in SIDE_WINDOWS_Z:
			_pool(holder, mat, Vector3(side * (SIDE_WALL_X - inset), 0.006, z), 
				Vector2(pool_depth, 6.4))
		for x in END_WINDOWS_X:
			_pool(holder, mat, Vector3(x, 0.006, side * (END_WALL_Z - inset)), 
				Vector2(6.8, pool_depth))

func _pool(holder: Node3D, mat: Material, at: Vector3, size: Vector2) -> void :
	var q: = QuadMesh.new()
	q.orientation = PlaneMesh.FACE_Y
	q.size = size
	var mi: = MeshInstance3D.new()
	mi.mesh = q
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	holder.add_child(mi)




func _build_trees(root: Node3D) -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = TREE_SHADER
	mat.set_shader_parameter("atlas", TREE_ATLAS)
	mat.set_shader_parameter("grid", Vector2(2, 1))
	mat.set_shader_parameter("card_h", tree_height)
	mat.set_shader_parameter("wind_amp", 0.3)
	mat.set_shader_parameter("wind_speed", 0.7)
	mat.set_shader_parameter("haze_color", tree_haze_color)
	mat.set_shader_parameter("haze_start", 40.0)
	mat.set_shader_parameter("haze_end", 120.0)
	mat.set_shader_parameter("haze_amt", tree_haze_amt)
	mat.set_shader_parameter("shade_top", 1.15)
	mat.set_shader_parameter("shade_bottom", 0.5)
	var quad: = QuadMesh.new()
	quad.size = Vector2(tree_height * 0.94, tree_height)
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = quad
	var rng: = RandomNumberGenerator.new()
	rng.seed = 90307
	var placed: Array[Transform3D] = []
	var customs: Array[Color] = []
	var tries: = 0
	while placed.size() < tree_count and tries < 4000:
		tries += 1
		var x: = rng.randf_range(-100.0, 100.0)
		var z: = rng.randf_range(-100.0, 100.0)

		if absf(x) < WALL_X + 5.0 and absf(z) < WALL_Z + 5.0:
			continue
		var s: = rng.randf_range(0.8, 1.4)
		var t: = Transform3D(Basis().scaled(Vector3(s, s, s)), Vector3(x, 0.0, z))
		placed.append(t)
		customs.append(Color(float(rng.randi_range(0, 1)), rng.randf(), 0.0, 0.0))
	mm.instance_count = placed.size()
	for i in placed.size():
		mm.set_instance_transform(i, placed[i])
		mm.set_instance_custom_data(i, customs[i])
	var mmi: = MultiMeshInstance3D.new()
	mmi.name = "Trees"
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mmi)



func _build_shafts(root: Node3D) -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = SHAFT_SHADER
	mat.set_shader_parameter("beam", shaft_color)
	mat.set_shader_parameter("intensity", shaft_intensity)
	var holder: = Node3D.new()
	holder.name = "SunShafts"
	root.add_child(holder)

	var rows: = maxi(shaft_rows_per_side, 1)
	for side in [-1.0, 1.0]:
		for i in rows:
			var frac: = (float(i) + 0.5) / float(rows)
			var z: = lerpf( - WALL_Z * 0.82, WALL_Z * 0.82, frac)
			var q: = QuadMesh.new()
			q.size = Vector2(3.0, 19.8)
			var mi: = MeshInstance3D.new()
			mi.mesh = q
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.custom_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
			var b: = Basis()
			b = b.rotated(Vector3(0, 1, 0), ( - PI / 2.0) if side > 0.0 else (PI / 2.0))
			b = b.rotated(Vector3(0, 0, 1), deg_to_rad(shaft_tilt_deg) * side)
			mi.transform = Transform3D(b, Vector3(side * (WALL_X - 1.0), shaft_height, z))
			holder.add_child(mi)
