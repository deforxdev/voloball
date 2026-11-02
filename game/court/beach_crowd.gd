class_name BeachCrowd


















const SHADER: = preload("res://game/court/beach_crowd.gdshader")
const SHADOW: = preload("res://game/court/beach_crowd_shadow.gdshader")
const FIELD: = preload("res://game/court/beach_crowd_field.gd")
const ATLAS: = "res://game/crowd/beach_crowd_atlas.png"
const PEOPLE: = 512
const SHOD: = 256
const ANGLES: = 4
const POSES: = 5
const PER_ROW: = 16
const CELL: = Vector2i(48, 96)
const CAPTURE_HEIGHT: = 2.5

const KIND_STAND: = 0.0
const KIND_SIT: = 1.0
const KIND_WALK: = 2.0

const SCALE: = 0.92


const DECK_X0: = -27.5
const DECK_X1: = -24.6
const DECK_Y: = 0.22
const DECK_Z: = 150.0
const DECK_LANES: = [-27.1, -26.1, -25.1]
const DECK_WALKERS: = 40
const DECK_GROUPS: = 34
const LEANERS: = 16
const BENCH_FILL: = 0.85

const SAND_X0: = -22.0
const SAND_X1: = 10.5
const SAND_Z: = 140.0
const SAND_LANES: = [-20.0, -16.5, 10.0]
const SAND_WALKERS: = 55
const SAND_GROUPS: = 190


const COURT_MARGIN: = 9.0
const COURT_FAR: = 30.0
const PROP_CLEAR: = 1.4


const SIT_HIP: = 0.22

const SEATS: = {"bench_01": 0.4, "bench_02": 0.45}

static func populate(shell: Node3D, id: String, half_w: float, half_l: float, 
		bodies_provider: = Callable(), obstacles: Array = [], crowd_seed: int = 0) -> Node:
	if shell == null or String(Stage.val(id, "surface", "court")) != "sand":
		return null
	var atlas: = ResourceLoader.load(ATLAS) as Texture2D
	if atlas == null:
		push_warning("beach crowd: no atlas (bake game/dev/beach_crowd_bake.tscn)")
		return null
	var rng: = RandomNumberGenerator.new()
	rng.seed = hash("beach_crowd:%d" % crowd_seed)
	var face_sea: = atan2(1.0, 0.0)

	var specs: Array = []
	var shod: = func() -> int: return rng.randi() % SHOD
	var bare: = func() -> int: return SHOD + rng.randi() % (PEOPLE - SHOD)


	for b in shell.find_children("bench_*", "MeshInstance3D", true, false):
		var bench: = b as MeshInstance3D
		var kind_name: = String(bench.name).substr(0, 8)
		if not SEATS.has(kind_name) or bench.mesh == null or rng.randf() > BENCH_FILL:
			continue
		var bz: = bench.global_transform.basis.z.normalized()
		var face: = atan2(bz.x, bz.z)
		var n: = 2 if rng.randf() < 0.45 else 1
		var slots: = [-0.45, 0.45] if n == 2 else [rng.randf_range(-0.35, 0.35)]
		for s in slots:

			var seat: = bench.global_transform * Vector3(float(s), float(SEATS[kind_name]), 0.2)
			specs.append([seat - Vector3(0.0, SIT_HIP * SCALE, 0.0), face, KIND_SIT, shod.call()])


	for g in DECK_GROUPS:
		var c: = Vector3(rng.randf_range(DECK_X0 + 0.4, DECK_X1 - 0.4), DECK_Y, 
			rng.randf_range( - DECK_Z, DECK_Z))
		_group(specs, rng, c, DECK_X0, DECK_X1, shod)
	for i in LEANERS:
		specs.append([Vector3(DECK_X1, DECK_Y, rng.randf_range( - DECK_Z, DECK_Z)), 
			face_sea + rng.randf_range(-0.35, 0.35), KIND_STAND, shod.call()])
	for i in DECK_WALKERS:
		var lane: float = DECK_LANES[i % DECK_LANES.size()] + rng.randf_range(-0.12, 0.12)
		specs.append([Vector3(lane, DECK_Y, 0.0), _walk_dir(rng), KIND_WALK, shod.call()])


	var props: Array = []
	var bp: = shell.get_node_or_null(^"BeachProps")
	if bp != null:
		for p in bp.get_children():
			if p is Node3D:
				var pp: = (p as Node3D).global_position
				props.append(Vector2(pp.x, pp.z))
	for o in obstacles:
		props.append(o)
		props.append((o as Vector2) + Vector2(0.0, 1.5))
		props.append((o as Vector2) - Vector2(0.0, 1.5))
	var sand_y: = maxf(SandDeform.decal_y, 0.02)
	var placed: = 0
	var tries: = 0
	while placed < SAND_GROUPS and tries < SAND_GROUPS * 30:
		tries += 1
		var x: = rng.randf_range(SAND_X0, SAND_X1)
		var z: = rng.randf_range( - SAND_Z, SAND_Z)


		var out_d: = maxf(absf(x) - half_w, absf(z) - half_l)
		if out_d < COURT_MARGIN:
			continue
		if rng.randf() > smoothstep(COURT_MARGIN, COURT_FAR, out_d) * 0.85 + 0.15:
			continue
		var blocked: = false
		for pp in props:
			if (pp as Vector2).distance_to(Vector2(x, z)) < PROP_CLEAR:
				blocked = true
				break
		if blocked:
			continue
		_group(specs, rng, Vector3(x, sand_y, z), SAND_X0, SAND_X1, bare)
		placed += 1
	for i in SAND_WALKERS:


		var want: float = SAND_LANES[i % SAND_LANES.size()] + rng.randf_range(-1.2, 1.2)
		var lane: = _clear_lane(want, props)
		if is_nan(lane):
			continue
		specs.append([Vector3(lane, sand_y, 0.0), _walk_dir(rng), KIND_WALK, bare.call()])
	if specs.is_empty():
		return null

	var qh: = CAPTURE_HEIGHT * SCALE
	var aspect: = float(CELL.x) / float(CELL.y)
	var qm: = QuadMesh.new()
	qm.size = Vector2(qh * aspect, qh)
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = qm
	mm.instance_count = specs.size()
	for i in specs.size():
		mm.set_instance_transform(i, Transform3D(Basis(), specs[i][0]))

		mm.set_instance_custom_data(i, Color(float(specs[i][3]), rng.randf(), 
			fposmod(float(specs[i][1]), TAU) / TAU, float(specs[i][2])))

	var mat: = ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("atlas", atlas)
	mat.set_shader_parameter("grid", Vector2(PER_ROW * POSES * ANGLES, ceil(float(PEOPLE) / PER_ROW)))
	mat.set_shader_parameter("angles", float(ANGLES))
	mat.set_shader_parameter("poses", float(POSES))
	mat.set_shader_parameter("per_row", float(PER_ROW))
	mat.set_shader_parameter("foot_lift", qh * 0.5)
	mat.set_shader_parameter("desat", 0.12)
	mat.set_shader_parameter("haze_color", Color(0.72, 0.82, 0.92))
	mat.set_shader_parameter("haze_start", 40.0)
	mat.set_shader_parameter("haze_end", 150.0)
	mat.set_shader_parameter("haze_amt", 0.7)
	var smat: = ShaderMaterial.new()
	smat.shader = SHADOW
	for m in [mat, smat]:
		m.set_shader_parameter("walk_z", Vector2( - DECK_Z, DECK_Z))
	var aabb: = AABB(Vector3(-40, -3, - DECK_Z - 10), Vector3(80, 10, DECK_Z * 2.0 + 20))
	var root: = Node3D.new()
	root.name = "BeachCrowd"
	root.transform = shell.global_transform.affine_inverse()
	for pair in [["People", mat], ["Shadows", smat]]:
		var mi: = MultiMeshInstance3D.new()
		mi.name = pair[0]
		mi.multimesh = mm
		mi.material_override = pair[1]
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.custom_aabb = aabb
		root.add_child(mi)
	var field: Node = FIELD.new()
	field.name = "Field"
	field.bodies_provider = bodies_provider
	field.walk_z = Vector2( - DECK_Z, DECK_Z)
	root.add_child(field)
	shell.add_child(root)
	field.setup(mm, [mat, smat])
	return field



static func _group(specs: Array, rng: RandomNumberGenerator, c: Vector3, 
		x0: float, x1: float, person: Callable) -> void :
	var r: = rng.randf()
	var k: = 1 if r < 0.25 else (2 if r < 0.65 else (3 if r < 0.9 else 4))
	for i in k:
		var pos: = c
		var face: = rng.randf_range(0.0, TAU)
		if k > 1:
			var ang: = TAU * float(i) / float(k) + rng.randf_range(-0.3, 0.3)
			var off: = Vector3(sin(ang), 0.0, cos(ang)) * rng.randf_range(0.5, 0.7)
			pos = c + off
			face = atan2( - off.x, - off.z)
		pos.x = clampf(pos.x, x0, x1)
		specs.append([pos, face, KIND_STAND, person.call()])



const WALK_CLEAR: = 1.3
static func _clear_lane(want: float, props: Array) -> float:
	for k in 41:
		var off: = (float(k + 1) / 2.0) * 0.2 * (1.0 if k % 2 == 0 else -1.0) if k > 0 else 0.0
		var x: = want + off
		var ok: = true
		for pp in props:
			if absf((pp as Vector2).x - x) < WALK_CLEAR:
				ok = false
				break
		if ok:
			return x
	return NAN

static func _walk_dir(rng: RandomNumberGenerator) -> float:
	return atan2(0.0, 1.0 if rng.randf() < 0.5 else -1.0)
