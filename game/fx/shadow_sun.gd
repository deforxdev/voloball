class_name ShadowSun
extends Node3D













const CATCH_LAYER: = 14
const CAST_LAYER: = 15
const CASTERS: = &"shadow_casters"
const NETS: = &"shadow_net"
const FALLBACKS: = &"shadow_fallback"
const NET_CASTER: = preload("res://game/fx/net_shadow_caster.gdshader")








const SUN_PITCH: = -60.0
const SUN_YAW: = -67.5

const ATLAS: = {2: 8192, 1: 4096}
const MAX_DISTANCE: = 32.0
const CATCHER_SIZE: = 160.0
const RETAG_EVERY: = 5.0


static var casting: = false






static var _casting_suns: Array[ShadowSun] = []

static func _recount() -> void :
	for s in _casting_suns.duplicate():
		if not is_instance_valid(s):
			_casting_suns.erase(s)
	casting = not _casting_suns.is_empty()

var _sun: DirectionalLight3D
var _catcher: MeshInstance3D
var _level: = -1
var _retag: = 0.0
var _dirty: = false
var _new_meshes: Array = []


var _lights: Array[Light3D] = []


static func ensure(parent: Node, floor_y: = 0.0) -> ShadowSun:
	var have: = parent.get_node_or_null(^"ShadowSun") as ShadowSun
	if have != null:
		return have
	var s: = ShadowSun.new()
	s.name = "ShadowSun"
	s.position.y = floor_y
	parent.add_child(s)
	return s

func _ready() -> void :
	_sun = DirectionalLight3D.new()
	_sun.name = "Sun"
	_sun.rotation_degrees = Vector3(SUN_PITCH, SUN_YAW, 0.0)
	_sun.light_cull_mask = 1 << (CATCH_LAYER - 1)
	_sun.shadow_caster_mask = 1 << (CAST_LAYER - 1)
	_sun.shadow_enabled = true





	_sun.directional_shadow_max_distance = MAX_DISTANCE
	_sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	_sun.directional_shadow_split_1 = 0.4
	_sun.shadow_bias = 0.03
	_sun.shadow_normal_bias = 1.0
	_sun.shadow_blur = 0.15
	_sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY

	_sun.light_color = Color(1.0, 0.0, 1.0)
	add_child(_sun)
	_catcher = MeshInstance3D.new()
	_catcher.name = "Catcher"
	var pm: = PlaneMesh.new()
	pm.size = Vector2(CATCHER_SIZE, CATCHER_SIZE)
	_catcher.mesh = pm
	_catcher.position.y = 0.012
	_catcher.layers = 1 << (CATCH_LAYER - 1)
	_catcher.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat: = ShaderMaterial.new()
	mat.shader = preload("res://game/fx/shadow_catcher.gdshader")
	_catcher.material_override = mat
	add_child(_catcher)

	top_level = true
	global_transform = Transform3D(Basis.IDENTITY, Vector3(0.0, position.y, 0.0))
	_apply()
	_tag_casters()
	for n in get_tree().root.find_children("*", "Light3D", true, false):
		_lights.append(n as Light3D)
	get_tree().node_added.connect(_light_added)
	get_tree().node_removed.connect(_light_removed)
	_clear_other_lights()

func _light_added(n: Node) -> void :
	if n is Light3D and not _lights.has(n):
		_lights.append(n as Light3D)
	elif n is MeshInstance3D:


		_new_meshes.append(n)


func _in_caster(n: Node) -> bool:
	while n != null:
		if n.is_in_group(CASTERS):
			return true
		n = n.get_parent()
	return false

func _light_removed(n: Node) -> void :
	if n is Light3D:
		_lights.erase(n)

func _exit_tree() -> void :
	_casting_suns.erase(self)
	_recount()
	if not casting:
		_show_fallbacks(true)

func _process(delta: float) -> void :
	if GameConfig.shadows != _level:
		_apply()



	_catcher.position.y = maxf(0.012, SandDeform.decal_y + 0.005)



	for m in _new_meshes:
		if is_instance_valid(m) and _in_caster(m):
			_dirty = true
			break
	_new_meshes.clear()
	_retag -= delta
	if (_dirty or _retag <= 0.0) and _level > 0:
		_dirty = false
		_retag = RETAG_EVERY
		_tag_casters()
		_clear_other_lights()

func _apply() -> void :
	_level = clampi(GameConfig.shadows, 0, 2)
	var on: = _level > 0
	_sun.visible = on
	_catcher.visible = on
	if on and not _casting_suns.has(self):
		_casting_suns.append(self)
	elif not on:
		_casting_suns.erase(self)
	_recount()
	_show_fallbacks( not casting)
	if on:
		RenderingServer.directional_shadow_atlas_set_size(int(ATLAS[_level]), true)
		_tag_casters()






func _tag_casters() -> void :
	var bit: = 1 << (CAST_LAYER - 1)
	for body in get_tree().get_nodes_in_group(CASTERS):
		var meshes: Array = (body as Node).find_children("*", "MeshInstance3D", true, false)
		if body is MeshInstance3D:
			meshes.append(body)
		for n in meshes:
			var mi: = n as MeshInstance3D
			if mi.layers & bit or not (mi.layers & 1):
				continue
			if mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
				continue
			if String(mi.name) in ["DropShadow", "Shadow"]:
				continue


			var low: = String(mi.name).to_lower()
			if "outline" in low or "hull" in low or "ink" in low:
				continue
			var m0: = mi.get_active_material(0) as BaseMaterial3D
			if m0 != null and m0.cull_mode == BaseMaterial3D.CULL_FRONT:
				continue
			mi.layers |= bit
	for net in get_tree().get_nodes_in_group(NETS):
		_net_caster(net as MeshInstance3D)
	_show_fallbacks(false)





func _net_caster(net: MeshInstance3D) -> void :
	if net == null or net.mesh == null:
		return
	var tw: = net.get_node_or_null(^"ShadowCaster") as MeshInstance3D
	if tw == null:
		tw = MeshInstance3D.new()
		tw.name = "ShadowCaster"
		tw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		tw.layers = 1 << (CAST_LAYER - 1)
		var m: = ShaderMaterial.new()
		m.shader = NET_CASTER
		tw.material_override = m
		net.add_child(tw)
	if tw.mesh != net.mesh:
		tw.mesh = net.mesh
	var src: = (net.mesh as PrimitiveMesh).material as ShaderMaterial\
	if net.mesh is PrimitiveMesh else null
	if src != null:
		var g: Variant = src.get_shader_parameter("grid")
		if g != null:
			(tw.material_override as ShaderMaterial).set_shader_parameter("grid", g)



func _show_fallbacks(show: bool) -> void :
	for n in get_tree().get_nodes_in_group(FALLBACKS):
		if (n as Node3D).visible != show:
			(n as Node3D).visible = show








func _clear_other_lights() -> void :
	var bit: = 1 << (CATCH_LAYER - 1)
	for l in _lights:
		if l != _sun and l.light_cull_mask & bit and not (l.get_parent() is ShadowSun):
			l.light_cull_mask &= ~ bit
