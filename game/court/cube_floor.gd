@tool
class_name CubeFloor
extends MultiMeshInstance3D







@export_group("footprint")


@export var half_x: = 26.0
@export var half_z: = 34.0
@export_group("tile")
@export var tile: = 1.8
@export var gap: = 0.07
@export var height: = 0.3
@export var bevel: = 0.05
@export var color_a: Color = Color(0.94, 0.96, 0.98)
@export var color_b: Color = Color(0.9, 0.93, 0.97)
@export_group("shading")
@export var side_shade: = 0.82
@export var underside_color: Color = Color(0.5, 0.62, 0.85)
@export_group("break-apart edge")
@export var edge_rows: = 6
@export var step_drop: = 0.9
@export_group("footstep effect")
@export var stride: = 1.4
@export var step_strength: = 0.5
@export var land_strength: = 0.7
@export var min_gap: = 0.18
@export var per_body: = 2
@export_group("playable-area tint")
@export var court_tint: Color = Color(0.3, 0.55, 1.0)
@export var court_fill: = 0.24
@export var court_edge: = 0.9

const MAX_RIPPLES: = 24



var _court_hw: = 0.0
var _court_hl: = 0.0

var _mat: ShaderMaterial = null
var _sig: = 0

var _bodies_provider: = Callable()
var _ball_provider: = Callable()
var _rings: Array = []
var _last_pos: = {}
var _last_t: = {}
var _was_grounded: = {}
var _ball_low: = false

func _ready() -> void :
	_build()

func _process(_delta: float) -> void :
	if Engine.is_editor_hint():

		var s: = hash([half_x, half_z, tile, gap, height, bevel, color_a, color_b, 
			side_shade, underside_color, edge_rows, step_drop, 
			court_tint, court_fill, court_edge])
		if s != _sig:
			_sig = s
			_build()
		return
	_update_ripples()





func set_feeds(bodies_provider: Callable, ball_provider: Callable) -> void :
	_bodies_provider = bodies_provider
	_ball_provider = ball_provider



func configure(half_w: float, half_l: float) -> void :
	_court_hw = half_w
	_court_hl = half_l
	if _mat != null:
		_mat.set_shader_parameter("court_hw", half_w)
		_mat.set_shader_parameter("court_hl", half_l)


func court_resized(half_w: float, half_l: float) -> void :
	configure(half_w, half_l)

func _now() -> float:
	return float(Time.get_ticks_msec()) * 0.001

func _stamp(pos: Vector3, strength: float, owner: Variant) -> void :


	var mine: Array = _rings.filter( func(r): return r["o"] == owner)
	while mine.size() >= per_body:
		_rings.erase(mine.pop_front())
	_rings.append({"pos": Vector2(pos.x, pos.z), "t0": _now(), "s": strength, "o": owner})
	while _rings.size() > MAX_RIPPLES:
		_rings.pop_front()

func _update_ripples() -> void :
	if _mat == null:
		return
	var now: = _now()
	_poll_bodies(now)

	var packed: = PackedVector4Array()
	var keep: Array = []
	for r in _rings:
		var age: float = now - float(r["t0"])
		if age > rip_life():
			continue
		keep.append(r)
		if packed.size() < MAX_RIPPLES:
			packed.append(Vector4(r["pos"].x, r["pos"].y, age, float(r["s"])))
	_rings = keep
	_mat.set_shader_parameter("ripple_count", packed.size())
	while packed.size() < MAX_RIPPLES:
		packed.append(Vector4.ZERO)
	_mat.set_shader_parameter("ripples", packed)

	var feet: = PackedVector4Array()
	if _bodies_provider.is_valid():
		for b in _bodies_provider.call():
			if feet.size() >= 8:
				break
			if b == null or not is_instance_valid(b):
				continue
			var grounded: = true
			if b.has_method("grounded"):
				grounded = b.grounded()
			var fp: Vector3 = b.global_position
			feet.append(Vector4(fp.x, fp.y, fp.z, 1.0 if grounded else 0.0))
	_mat.set_shader_parameter("feet_count", feet.size())
	while feet.size() < 8:
		feet.append(Vector4.ZERO)
	_mat.set_shader_parameter("feet", feet)

func rip_life() -> float:
	var v: Variant = _mat.get_shader_parameter("rip_life")
	return float(v) if v != null else 1.1

func _poll_bodies(now: float) -> void :
	if not _bodies_provider.is_valid():
		return
	for b in _bodies_provider.call():
		if b == null or not is_instance_valid(b) or not b.has_method("grounded"):
			continue
		var grounded: bool = b.grounded()
		var pos: Vector3 = b.global_position
		var was: bool = _was_grounded.get(b, true)
		_was_grounded[b] = grounded
		if not grounded:
			continue
		var last_t: float = _last_t.get(b, -10.0)
		if not was:
			if now - last_t >= min_gap:
				_stamp(pos, land_strength, b)
				_last_pos[b] = pos
				_last_t[b] = now
			continue
		if not _last_pos.has(b):
			_last_pos[b] = pos
			continue
		var last: Vector3 = _last_pos[b]
		var moved: = Vector2(pos.x - last.x, pos.z - last.z).length()
		if moved >= stride and now - last_t >= min_gap:
			_stamp(pos, step_strength, b)
			_last_pos[b] = pos
			_last_t[b] = now

func _build() -> void :
	var pitch: = tile + gap
	var nx: = int(half_x * 2.0 / pitch)
	var nz: = int(half_z * 2.0 / pitch)
	var x0: = - float(nx - 1) * pitch * 0.5
	var z0: = - float(nz - 1) * pitch * 0.5
	var base_y: = - height * 0.5
	var rng: = RandomNumberGenerator.new()
	rng.seed = 777

	var xforms: Array[Transform3D] = []
	var cols: PackedColorArray = PackedColorArray()

	for ix in range( - edge_rows, nx + edge_rows):
		for iz in range( - edge_rows, nz + edge_rows):
			var ox: = 0.0
			if ix < 0: ox = float( - ix)
			elif ix > nx - 1: ox = float(ix - (nx - 1))
			var oz: = 0.0
			if iz < 0: oz = float( - iz)
			elif iz > nz - 1: oz = float(iz - (nz - 1))
			var out_rows: float = max(ox, oz)

			var x: = x0 + float(ix) * pitch
			var z: = z0 + float(iz) * pitch
			var y: = base_y

			if out_rows > 0.0:
				var keep: float = clamp(1.0 - out_rows * 0.2, 0.05, 1.0)
				if rng.randf() > keep:
					continue
				y -= out_rows * step_drop + rng.randf_range(0.0, 0.6)
				x += rng.randf_range(-0.3, 0.3)
				z += rng.randf_range(-0.3, 0.3)

			xforms.append(Transform3D(Basis(), Vector3(x, y, z)))
			cols.append(color_a if (ix + iz) % 2 == 0 else color_b)

	var mesh: = RoundedBox.make(Vector3(tile, height, tile), bevel)
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://game/court/cube_floor.gdshader")
	_mat.set_shader_parameter("tile_height", height)
	_mat.set_shader_parameter("side_shade", side_shade)
	_mat.set_shader_parameter("underside", underside_color)
	_mat.set_shader_parameter("court_hw", _court_hw)
	_mat.set_shader_parameter("court_hl", _court_hl)
	_mat.set_shader_parameter("court_tint", court_tint)
	_mat.set_shader_parameter("court_fill", court_fill)
	_mat.set_shader_parameter("court_edge", court_edge)
	mesh.surface_set_material(0, _mat)

	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
		mm.set_instance_color(i, cols[i])
	multimesh = mm
