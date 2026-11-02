class_name BeachTown

















const GROUND: = preload("res://game/court/beach_town_ground.gdshader")
const PLANKS: = preload("res://game/court/beach_boardwalk.gdshader")
const AWNING: = "res://game/assets/kn_city_commercial/GLB format/detail-awning-wide.glb"

const PASTELS: = [Color(1.0, 0.66, 0.58), Color(0.58, 0.92, 0.74), Color(1.0, 0.88, 0.48), 
	Color(0.62, 0.8, 1.0), Color(1.0, 0.92, 0.8), Color(0.84, 0.7, 0.98), 
	Color(1.0, 0.76, 0.5), Color(0.6, 0.9, 0.92)]
const AWNINGS: = [Color(0.95, 0.35, 0.33), Color(0.2, 0.62, 0.7), Color(0.98, 0.72, 0.2), 
	Color(0.36, 0.56, 0.9), Color(0.94, 0.46, 0.66), Color(0.3, 0.7, 0.45)]


const RAIL_X: = -24.3
const DECK_TOP: = 0.22
const DECK_Z: = 160.0
const STEPS_Z: = [-128.0, -92.0, -56.0, 36.0, 76.0, 116.0]
const STEP_GAP: = 1.8
const KIOSKS: = [[-21.6, -60.0], [-21.6, -24.0], [-21.6, 32.0], [-21.6, 72.0]]
const TOWER: = Vector3(7.5, 0.0, -36.0)

static func build(shell: Node3D, half_w: float, half_l: float) -> Array:
	var spots: Array = []
	if shell == null:
		return spots
	var rng: = RandomNumberGenerator.new()
	rng.seed = 7413
	var root: = Node3D.new()
	root.name = "BeachTown"
	shell.add_child(root)
	root.global_transform = Transform3D.IDENTITY








	_boardwalk(shell, root)
	_string_lights(shell, root)
	return spots


static func _ground(shell: Node3D) -> void :
	var pav: = shell.get_node_or_null(^"TownGround/Pavement") as MeshInstance3D
	var roads: = shell.get_node_or_null(^"City/Roads")
	if pav == null:
		return
	var rects: Array = []
	if roads != null:
		for r in roads.get_children():
			var mi: = r as MeshInstance3D
			if mi == null or mi.mesh == null:
				continue
			var b: AABB = mi.global_transform * mi.get_aabb()
			rects.append(Vector4(b.position.x, b.position.z, b.end.x, b.end.z))
			mi.visible = false
	var mat: = ShaderMaterial.new()
	mat.shader = GROUND
	mat.set_shader_parameter("roads", rects)
	mat.set_shader_parameter("road_count", rects.size())
	pav.material_override = mat

	pav.position.y = maxf(pav.position.y, 0.03)


static func _boardwalk(shell: Node3D, root: Node3D) -> void :
	var bw: = shell.get_node_or_null(^"Boardwalk")
	if bw == null:
		return

	var deck: = bw.get_node_or_null(^"Deck") as MeshInstance3D
	var planks: Material = deck.material_override if deck != null else null


	var white: Material = planks
	if planks is StandardMaterial3D:
		var w: = (planks as StandardMaterial3D).duplicate() as StandardMaterial3D
		w.albedo_color = w.albedo_color.darkened(0.18)
		white = w

	for c in bw.get_children():
		var mi: = c as MeshInstance3D
		if mi == null:
			continue
		if String(mi.name).begins_with("Post"):
			mi.material_override = white
			for sz in STEPS_Z:
				if absf(mi.global_position.z - float(sz)) < STEP_GAP * 0.5 + 0.2:
					mi.visible = false
		elif String(mi.name) == "RailTop":
			mi.visible = false

	var cuts: Array = [ - DECK_Z]
	for sz in STEPS_Z:
		cuts.append(float(sz) - STEP_GAP * 0.5)
		cuts.append(float(sz) + STEP_GAP * 0.5)
	cuts.append(DECK_Z)
	var bar: = BoxMesh.new()
	bar.size = Vector3(1, 1, 1)
	var rails: Array = []
	for i in range(0, cuts.size(), 2):
		var z0: float = cuts[i]
		var z1: float = cuts[i + 1]
		for h in [[0.95, 0.1], [0.58, 0.07]]:
			rails.append(Transform3D(Basis().scaled(Vector3(float(h[1]), float(h[1]), z1 - z0)), 
				Vector3(RAIL_X, float(h[0]), (z0 + z1) * 0.5)))
	root.add_child(_multi("Rails", bar, white, rails))
	_rail_shadows(bw, root, cuts)

	var treads: Array = []
	for sz in STEPS_Z:
		for t in [[RAIL_X + 0.32, 0.15], [RAIL_X + 0.76, 0.08]]:
			treads.append(Transform3D(Basis().scaled(Vector3(0.44, float(t[1]), STEP_GAP)), 
				Vector3(float(t[0]), float(t[1]) * 0.5, float(sz))))
	root.add_child(_multi("Steps", bar, planks, treads))





static func _rail_shadows(bw: Node, root: Node3D, cuts: Array) -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = load("res://game/court/box_shadow.gdshader")
	mat.set_shader_parameter("shadow_color", Color(0.16, 0.09, 0.05))
	mat.set_shader_parameter("strength", 0.8)
	mat.set_shader_parameter("softness", 0.8)
	mat.set_shader_parameter("corner", 0.0)
	var quad: = QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	quad.size = Vector2(1, 1)
	var y: = DECK_TOP + 0.006
	var strips: Array = []
	for i in range(0, cuts.size(), 2):
		var z0: float = cuts[i]
		var z1: float = cuts[i + 1]
		strips.append(Transform3D(Basis().scaled(Vector3(1.1, 1.0, z1 - z0)), 
			Vector3(RAIL_X - 0.4, y, (z0 + z1) * 0.5)))
	for c in bw.get_children():
		var mi: = c as MeshInstance3D
		if mi != null and mi.visible and String(mi.name).begins_with("Post"):
			strips.append(Transform3D(Basis().scaled(Vector3(0.6, 1.0, 0.6)), 
				Vector3(mi.global_position.x - 0.15, y + 0.001, mi.global_position.z)))
	root.add_child(_multi("RailShadows", quad, mat, strips))


static func _buildings(shell: Node3D, rng: RandomNumberGenerator) -> void :
	var houses: = shell.get_node_or_null(^"City/Houses")
	if houses == null:
		return
	var awning_scene: = load(AWNING) as PackedScene
	for h in houses.get_children():
		if not String(h.name).begins_with("Bld"):
			continue
		var body: = h as Node3D
		var tint: Color = PASTELS[rng.randi() % PASTELS.size()]
		var box: = AABB()
		var first: = true
		for m in body.find_children("*", "MeshInstance3D", true, false):
			var mi: = m as MeshInstance3D
			var src: = mi.get_active_material(0) as BaseMaterial3D
			if src != null:
				var mat: = src.duplicate() as BaseMaterial3D
				mat.albedo_color = src.albedo_color * tint
				mi.material_override = mat
			var b: AABB = mi.global_transform * mi.get_aabb()
			box = b if first else box.merge(b)
			first = false


		var faces_sea: = (body.global_transform.basis.z.normalized()).x > 0.9
		if faces_sea and box.end.x > -45.0 and box.end.x < -30.0 and awning_scene != null:
			var aw: = awning_scene.instantiate() as Node3D
			body.add_child(aw)
			var local_front: = _local_front_z(body)
			aw.position = Vector3(0.0, 0.16, local_front - 0.1)
			var acol: Color = AWNINGS[rng.randi() % AWNINGS.size()]
			for m in aw.find_children("*", "MeshInstance3D", true, false):
				var mi: = m as MeshInstance3D
				var src: = mi.get_active_material(0) as BaseMaterial3D
				if src != null:
					var mat: = src.duplicate() as BaseMaterial3D
					mat.albedo_color = acol
					mi.material_override = mat


static func _local_front_z(body: Node3D) -> float:
	var z: = 0.0
	for m in body.find_children("*", "MeshInstance3D", true, false):
		var mi: = m as MeshInstance3D
		var to_body: = body.global_transform.affine_inverse() * mi.global_transform
		var b: AABB = to_body * mi.get_aabb()
		z = maxf(z, b.end.z)
	return z


static func _kiosk(root: Node3D, at: Vector3, rng: RandomNumberGenerator) -> void :
	var k: = Node3D.new()
	k.name = "Kiosk"
	k.position = at
	root.add_child(k)
	var col: Color = AWNINGS[rng.randi() % AWNINGS.size()]
	var wall: Color = PASTELS[rng.randi() % PASTELS.size()]
	_box(k, Vector3(1.6, 1.1, 2.4), Vector3(-0.2, 0.55, 0), wall)
	_box(k, Vector3(0.3, 2.3, 2.4), Vector3(-0.85, 1.15, 0), wall)
	_box(k, Vector3(0.12, 1.2, 0.12), Vector3(0.55, 1.7, 1.1), Color(0.95, 0.95, 0.93))
	_box(k, Vector3(0.12, 1.2, 0.12), Vector3(0.55, 1.7, -1.1), Color(0.95, 0.95, 0.93))
	_box(k, Vector3(1.8, 0.14, 2.7), Vector3(-0.1, 2.35, 0), col)
	_box(k, Vector3(0.1, 0.45, 2.7), Vector3(0.82, 2.18, 0), col.lightened(0.35))
	_box(k, Vector3(0.12, 0.6, 1.8), Vector3(-0.9, 2.75, 0), Color(0.98, 0.97, 0.9))
	_box(k, Vector3(0.14, 0.42, 1.5), Vector3(-0.84, 2.75, 0), col.darkened(0.2))

	_box(k, Vector3(0.05, 1.4, 0.05), Vector3(-0.9, 3.4, 1.2), Color(0.9, 0.9, 0.9))
	_box(k, Vector3(0.02, 0.32, 0.55), Vector3(-0.9, 3.9, 0.92), AWNINGS[rng.randi() % AWNINGS.size()])


static func _tower(root: Node3D, at: Vector3) -> void :
	var t: = Node3D.new()
	t.name = "LifeguardTower"
	t.position = at
	root.add_child(t)
	var white: = Color(0.96, 0.95, 0.92)
	var red: = Color(0.86, 0.22, 0.2)
	for c in [Vector2(-0.8, -0.8), Vector2(0.8, -0.8), Vector2(-0.8, 0.8), Vector2(0.8, 0.8)]:
		_box(t, Vector3(0.14, 2.2, 0.14), Vector3(c.x, 1.1, c.y), white)
	_box(t, Vector3(2.0, 0.14, 2.0), Vector3(0, 2.2, 0), white)
	_box(t, Vector3(1.6, 1.3, 1.6), Vector3(0, 2.95, 0), red)
	_box(t, Vector3(0.06, 0.6, 1.2), Vector3(0.81, 3.05, 0), Color(0.55, 0.78, 0.95))
	_box(t, Vector3(2.1, 0.12, 2.1), Vector3(0, 3.7, 0), white)
	for i in 5:
		_box(t, Vector3(0.06, 0.06, 0.8), Vector3(1.25 - i * 0.05, 0.3 + i * 0.42, 0), white)
	_box(t, Vector3(0.05, 1.6, 0.05), Vector3(-0.7, 4.5, -0.7), white)
	_box(t, Vector3(0.6, 0.4, 0.02), Vector3(-0.38, 5.05, -0.7), red)


static func _string_lights(shell: Node3D, root: Node3D) -> void :
	var lamps: = shell.get_node_or_null(^"Lamps")
	if lamps == null:
		return
	var tops: Array = []
	for l in lamps.get_children():
		if l is Node3D:
			tops.append((l as Node3D).global_position + Vector3(0, 3.3, 0))
	tops.sort_custom( func(a, b): return a.z < b.z)
	var bulb: = SphereMesh.new()
	bulb.radius = 0.12
	bulb.height = 0.24
	bulb.radial_segments = 6
	bulb.rings = 3
	var bulb_mat: = StandardMaterial3D.new()
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bulb_mat.vertex_color_use_as_albedo = true
	var wire: = ImmediateMesh.new()
	var wire_mat: = StandardMaterial3D.new()
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wire_mat.albedo_color = Color(0.15, 0.15, 0.17)
	var bulbs: Array = []
	var colors: Array = []



	var warm: = [Color(1.0, 0.55, 0.0), Color(1.0, 0.1, 0.1), Color(0.0, 0.65, 1.0), 
		Color(1.0, 0.1, 0.6), Color(0.2, 1.0, 0.2), Color(1.0, 0.9, 0.0)]
	wire.surface_begin(Mesh.PRIMITIVE_LINES, wire_mat)
	for i in tops.size() - 1:
		var a: Vector3 = tops[i]
		var b: Vector3 = tops[i + 1]
		if a.distance_to(b) > 40.0:
			continue
		var n: = 24
		var prev: = a
		for s in range(1, n + 1):
			var f: = float(s) / float(n)
			var p: = a.lerp(b, f) - Vector3(0, sin(f * PI) * 0.9, 0)
			wire.surface_add_vertex(prev)
			wire.surface_add_vertex(p)
			prev = p
			if s % 2 == 0 and s < n:
				bulbs.append(Transform3D(Basis(), p - Vector3(0, 0.08, 0)))
				colors.append(warm[(s / 2) % warm.size()])
	wire.surface_end()
	var wi: = MeshInstance3D.new()
	wi.name = "LightWire"
	wi.mesh = wire
	wi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(wi)
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = bulb
	mm.instance_count = bulbs.size()
	for i in bulbs.size():
		mm.set_instance_transform(i, bulbs[i])
		mm.set_instance_color(i, colors[i])
	var bi: = MultiMeshInstance3D.new()
	bi.name = "LightBulbs"
	bi.multimesh = mm
	bi.material_override = bulb_mat
	bi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(bi)


static var _box_mesh: BoxMesh = null
static var _mat_cache: = {}

static func _box(parent: Node3D, size: Vector3, pos: Vector3, col: Color) -> void :
	if _box_mesh == null:
		_box_mesh = BoxMesh.new()
	var mi: = MeshInstance3D.new()
	mi.mesh = _box_mesh
	mi.scale = size
	mi.position = pos
	var key: = col.to_html()
	if not _mat_cache.has(key):
		var m: = StandardMaterial3D.new()
		m.albedo_color = col
		m.roughness = 0.85
		_mat_cache[key] = m
	mi.material_override = _mat_cache[key]
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)

static func _multi(nm: String, mesh: Mesh, mat: Material, xforms: Array) -> MultiMeshInstance3D:
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
	var mi: = MultiMeshInstance3D.new()
	mi.name = nm
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi
