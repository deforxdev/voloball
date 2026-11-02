@tool
extends Node3D















const LED_SHADER: = preload("res://game/stage/kits/led_board.gdshader")
const SCREEN_SHADER: = preload("res://game/stage/kits/arena_screen.gdshader")
const LOGO: = preload("res://game/logo/jvlogo_sd.png")
const HALO_SHADER: = preload("res://game/stage/kits/light_halo.gdshader")
const BEAM_SHADER: = preload("res://game/stage/kits/light_beam.gdshader")
const HALO_SIZE: = 3.2
const BEAM_LEN: = 16.0
const GLARE_SHADER: = preload("res://game/stage/kits/screen_glare.gdshader")
const MIST_SHADER: = preload("res://game/stage/kits/edge_mist.gdshader")
const CORNER_FOG_SHADER: = preload("res://game/stage/kits/corner_fog.gdshader")



const SCREEN_GLARE: = Color(0.25, 1.0, 0.55, 0.2)
const BOARD_GLARE: = Color(0.25, 1.0, 0.55, 0.11)
const RIBBON_GLARE: = Color(0.25, 1.0, 0.55, 0.07)


const RIG_LIGHT: = Color(1.0, 1.0, 1.0)


const SCREEN_TOP: = Color(0.1, 0.4, 0.26)
const SCREEN_BOTTOM: = Color(0.02, 0.11, 0.07)
const MIST_PUFFS: = 46


const CROWD_MIN_Y: = 0.3


const CORNER_LINE: = 33.2
const CORNER_INSET: = 0.7

var _mats: Array[ShaderMaterial] = []
var _screens: Array[ShaderMaterial] = []
var _clock: = 0.0








const SCREEN_LAYER: = 12




const FEED_HIDE_LAYER: = LocalViews.FEED_HIDE_LAYER
const HUD_CLASSES: = ["AimMarker", "ReachMarker", "Crosshair", "ServeZoneMarker", 
	"TrajectoryPreview", "LandingCall"]
const PLAYER_KEEP: = ["Visual", "DropShadow", "AirTrail", "ShadowCaster"]
const BALL_KEEP: = ["Mesh", "Trail", "Shadow"]

const BALL_HUD: = ["Outline"]
var _hud_nodes: Array[VisualInstance3D] = []
var _hud_found: = false
const FEED_SIZE: = Vector2i(512, 288)
const FEED_EVERY: = 3
const FEED_HOLD: = 14.0
const LOGO_HOLD: = 5.0
const FEED_FADE: = 0.5
var _feed_vp: SubViewport = null
var _watch: WatchCamera = null
var _feed_frame: = 0

func show_live_feed(ball: Node3D, half_w: float, half_l: float, viewer: Camera3D, 
		room_box: AABB) -> void :
	if Engine.is_editor_hint() or _screens.is_empty():
		return
	if _feed_vp == null:
		_feed_vp = SubViewport.new()
		_feed_vp.name = "LiveFeed"
		_feed_vp.size = FEED_SIZE
		_feed_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_feed_vp.positional_shadow_atlas_size = 0
		add_child(_feed_vp)
		var cam: = Camera3D.new()
		cam.fov = 52.0
		cam.current = true
		_feed_vp.add_child(cam)
		_watch = WatchCamera.new()
		_watch.setup(cam)
		for m in _screens:
			m.set_shader_parameter("feed", _feed_vp.get_texture())
			m.set_shader_parameter("feed_aspect", float(FEED_SIZE.x) / float(FEED_SIZE.y))
	var cam: = _feed_vp.get_camera_3d()


	var mask: = viewer.cull_mask if viewer != null else LocalViews.ALL_LAYERS
	mask &= ~ (1 << (SCREEN_LAYER - 1)) & ~ FloorReflector.REFLECT_MASK\
	& ~ (1 << (FEED_HIDE_LAYER - 1))
	for i in LocalViews.PRIVATE_COUNT:
		mask &= ~ LocalViews.private_mask(i)
	cam.cull_mask = mask
	_watch.ball = ball
	_watch.half_w = half_w
	_watch.half_l = half_l
	_watch.room_box = room_box





const STAR_HOLD: = 5.0
var _star: Node3D = null
var _star_t: = 0.0

func show_point_player(body: Node3D) -> void :
	if _watch == null or body == null:
		return
	_star = body
	_star_t = STAR_HOLD

func _drive_star(delta: float) -> void :
	var cam: = _feed_vp.get_camera_3d()
	var focus: = _star.get_global_transform_interpolated().origin + Vector3(0.0, 1.0, 0.0)



	var side: = signf(focus.z)
	if side == 0.0:
		side = 1.0
	var out: = signf(focus.x) if absf(focus.x) > 0.3 else 1.0
	var eye: = Vector3(focus.x + out * 2.4, focus.y + 0.5, 
		side * maxf(absf(focus.z) - 2.8, 0.7))

	cam.global_position = eye if _star_t > STAR_HOLD - 0.05\
	else cam.global_position.lerp(eye, 1.0 - exp(-5.0 * delta))
	if cam.global_position.distance_to(focus) > 0.1:
		cam.look_at(focus, Vector3.UP)



func _process(delta: float) -> void :
	_clock += delta
	for m in _mats:
		m.set_shader_parameter("anim_time", _clock)
	if _watch == null:
		return
	if _star_t > 0.0 and is_instance_valid(_star):
		_drive_star(delta)
		_star_t -= delta
		for m in _screens:
			m.set_shader_parameter("feed_mix", 1.0)
		_feed_frame += 1
		if _feed_frame % FEED_EVERY == 0:
			_hide_hud(delta * FEED_EVERY)
			_feed_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		return

	var phase: = fmod(_clock, FEED_HOLD + LOGO_HOLD)
	var mix_: = 0.0
	if phase < FEED_HOLD:
		mix_ = clampf(phase / FEED_FADE, 0.0, 1.0) * clampf((FEED_HOLD - phase) / FEED_FADE, 0.0, 1.0)
	for m in _screens:
		m.set_shader_parameter("feed_mix", mix_)
	if mix_ <= 0.0:
		return
	_watch.time += delta
	_watch.drive(delta)
	_feed_frame += 1
	if _feed_frame % FEED_EVERY == 0:
		_hide_hud(delta * FEED_EVERY)
		_feed_vp.render_target_update_mode = SubViewport.UPDATE_ONCE

func _ready() -> void :
	var gym: = get_node_or_null("Gym") as Node3D
	if gym == null:
		return
	var s: = gym.scale.x
	var tiers: = gym.find_child("Seats", true, false) as MeshInstance3D
	if tiers != null:
		tiers.set_meta(&"crowd_faces", CROWD_MIN_Y)
	var n: = 0
	var ring: Array[MeshInstance3D] = []
	for node in gym.find_children("*", "MeshInstance3D", true, false):
		var mi: = node as MeshInstance3D
		if mi.mesh == null or mi.mesh.get_surface_count() == 0:
			continue
		var m: = mi.mesh.surface_get_material(0)
		var mname: = m.resource_name if m != null else ""
		var size: = mi.mesh.get_aabb().size * s
		if mname == "LedBoard":
			var sm: = ShaderMaterial.new()
			sm.shader = LED_SHADER
			sm.set_shader_parameter("logo", LOGO)
			sm.set_shader_parameter("length_m", maxf(size.x, size.z))
			sm.set_shader_parameter("height_m", size.y)
			sm.set_shader_parameter("offset_s", float(n) * 1.7)





			var courtside_ring: = String(mi.name).begins_with("Courtside Board")
			sm.set_shader_parameter("fixed_prog", 1.0 if courtside_ring else 0.0)
			sm.set_shader_parameter("speed", 0.35 if courtside_ring else 0.45)


			sm.set_shader_parameter("chevron_period", 3.2)
			sm.set_shader_parameter("chevron_fill", 0.3)
			sm.set_shader_parameter("col_b", Color(0.4, 0.76, 0.55))



			var courtside: = String(mi.name).begins_with("Courtside Board")
			sm.set_shader_parameter("energy", 0.8 if courtside else 0.5)
			sm.set_shader_parameter("col_bg", Color(0.12, 0.42, 0.28))
			if String(mi.name).begins_with("Courtside Board"):
				ring.append(mi)
			mi.material_override = sm
			_mats.append(sm)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			n += 1
		elif mname == "JumboScreen":
			var sc: = ShaderMaterial.new()
			sc.shader = SCREEN_SHADER
			sc.set_shader_parameter("logo", LOGO)
			sc.set_shader_parameter("aspect", maxf(size.x, size.z) / maxf(size.y, 0.01))
			sc.set_shader_parameter("border_width", 0.0)
			sc.set_shader_parameter("col_top", SCREEN_TOP)
			sc.set_shader_parameter("col_bottom", SCREEN_BOTTOM)

			sc.set_shader_parameter("sweep_col", Vector3.ZERO)
			mi.material_override = sc
			_mats.append(sc)
			_screens.append(sc)
			mi.layers = 1 << (SCREEN_LAYER - 1)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_join_board_ring(ring)
	_light_halos(gym)
	_screen_glare(gym)
	_corner_fog()



	if not Engine.is_editor_hint():
		_corner_walls(s)





const LOGO_SPACING: = 4.0
func _join_board_ring(ring: Array[MeshInstance3D]) -> void :
	if ring.size() < 2:
		return
	var ends: = {}
	for mi in ring:
		var a: = mi.mesh.surface_get_arrays(0)
		var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var uvs: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
		var p0: = Vector3.ZERO
		var p1: = Vector3.ZERO
		var c0: = 0
		var c1: = 0
		for i in vs.size():
			if uvs[i].x < 0.5:
				p0 += vs[i]
				c0 += 1
			else:
				p1 += vs[i]
				c1 += 1
		if c0 == 0 or c1 == 0:
			return
		ends[mi] = [mi.global_transform * (p0 / c0), mi.global_transform * (p1 / c1)]
	var order: Array[MeshInstance3D] = [ring[0]]
	var left: = ring.slice(1)
	while not left.is_empty():
		var tail: Vector3 = ends[order[-1]][1]
		var best: MeshInstance3D = left[0]
		for mi in left:
			if (ends[mi][0] as Vector3).distance_to(tail) < (ends[best][0] as Vector3).distance_to(tail):
				best = mi
		order.append(best)
		left.erase(best)
	var at: = 0.0
	var starts: = []
	for mi in order:
		starts.append(at)
		at += (ends[mi][0] as Vector3).distance_to(ends[mi][1])
	var h: float = (order[0].material_override as ShaderMaterial).get_shader_parameter("height_m")
	var logo_w: = h * 2.9
	var cell: = at / maxf(1.0, roundf(at / (logo_w * LOGO_SPACING)))
	for i in order.size():
		var sm: = order[i].material_override as ShaderMaterial
		sm.set_shader_parameter("u_start", starts[i])

		sm.set_shader_parameter("length_m", (ends[order[i]][0] as Vector3).distance_to(ends[order[i]][1]))
		sm.set_shader_parameter("logo_cell", cell)
		sm.set_shader_parameter("logo_w", logo_w)
		sm.set_shader_parameter("offset_s", 0.0)





func _light_halos(gym: Node3D) -> void :
	var lights: = gym.find_child("Arena Lights", true, false) as MeshInstance3D
	if lights == null or lights.mesh == null:
		return
	var arrays: = lights.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var root: = range(verts.size())
	var find: = func(i: int) -> int:
		while root[i] != i:
			i = root[i]
		return i
	for t in range(0, idx.size(), 3):
		var r0: int = find.call(idx[t])
		for k in [1, 2]:
			var rk: int = find.call(idx[t + k])
			if rk != r0:
				root[rk] = r0
	var xf: = lights.global_transform
	var lens: = {}
	for i in verts.size():
		var r: int = find.call(i)
		var acc: Array = lens.get(r, [Vector3.ZERO, Vector3.ZERO, 0])
		lens[r] = [acc[0] + xf * verts[i], acc[1] + xf.basis * norms[i], acc[2] + 1]
	var glare: = MultiMesh.new()
	glare.transform_format = MultiMesh.TRANSFORM_3D
	var beams: = MultiMesh.new()
	beams.transform_format = MultiMesh.TRANSFORM_3D
	for mm in [glare, beams]:
		var quad: = QuadMesh.new()
		quad.size = Vector2.ONE
		mm.mesh = quad
		mm.instance_count = lens.size()
	var i: = 0
	for acc in lens.values():
		var c: Vector3 = acc[0] / float(acc[2])
		var aim: Vector3 = (acc[1] as Vector3).normalized()


		var up: = Vector3.FORWARD if absf(aim.y) > 0.99 else Vector3.UP
		glare.set_instance_transform(i, Transform3D(Basis.looking_at(aim, up).scaled(
			Vector3.ONE * HALO_SIZE), c + aim * 0.15))
		beams.set_instance_transform(i, Transform3D(Basis(Vector3(0.7, 0.0, 0.0), 
			aim * BEAM_LEN, Vector3(0.0, 0.0, 5.0)), c))
		i += 1
	for part in [["Light Glare", glare, HALO_SHADER], ["Light Beams", beams, BEAM_SHADER]]:
		var mmi: = MultiMeshInstance3D.new()
		mmi.name = part[0]
		mmi.multimesh = part[1]
		var mat: = ShaderMaterial.new()
		mat.shader = part[2]
		mat.set_shader_parameter("color", RIG_LIGHT)
		mmi.material_override = mat
		mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mmi.custom_aabb = AABB(Vector3(-80, -10, -90), Vector3(160, 60, 180))
		add_child(mmi)






const CORNER_FOG_FROM: = Vector2(19.0, 26.0)
const CORNER_FOG_TO: = Vector2(25.0, 44.0)
const CORNER_FOG_SIZE: = Vector2(9.0, 9.0)

func _corner_fog() -> void :
	var mat: = ShaderMaterial.new()
	mat.shader = CORNER_FOG_SHADER
	mat.set_shader_parameter("color", Color(0.11, 0.115, 0.125))
	var box: = BoxMesh.new()
	box.size = Vector3.ONE
	for sx in [1.0, -1.0]:
		for sz in [1.0, -1.0]:
			var a: = CORNER_FOG_FROM * Vector2(sx, sz)
			var b: = CORNER_FOG_TO * Vector2(sx, sz)
			var along: = Vector3(b.x - a.x, 0.0, b.y - a.y)
			var mi: = MeshInstance3D.new()
			mi.name = "Corner Fog"
			mi.mesh = box
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var basis: = Basis(Vector3.UP, atan2(along.x, along.z)).scaled_local(
				Vector3(CORNER_FOG_SIZE.x, CORNER_FOG_SIZE.y, along.length()))
			mi.transform = Transform3D(basis, Vector3((a.x + b.x) * 0.5, 
				CORNER_FOG_SIZE.y * 0.5 - 0.3, (a.y + b.y) * 0.5))
			add_child(mi)




func _corner_walls(s: float) -> void :
	var line: = (CORNER_LINE - CORNER_INSET * sqrt(2.0)) * s
	var body: = StaticBody3D.new()
	body.name = "CornerBarrier"
	body.collision_layer = 1
	add_child(body)
	for sx in [1.0, -1.0]:
		for sz in [1.0, -1.0]:
			var cs: = CollisionShape3D.new()
			var box: = BoxShape3D.new()
			box.size = Vector3(0.5, 14.0, line)
			cs.shape = box
			var mid: = line * 0.5 + 0.25 * 0.7071
			cs.position = Vector3(sx * mid, 7.0, sz * mid)
			cs.rotation.y = - sx * sz * PI * 0.25
			body.add_child(cs)






func _screen_glare(gym: Node3D) -> void :
	var to_me: = global_transform.affine_inverse()
	var verts: = PackedVector3Array()
	var uvs: = PackedVector2Array()
	var uv2s: = PackedVector2Array()
	var cols: = PackedColorArray()
	var norms: = PackedVector3Array()
	for node in gym.find_children("*", "MeshInstance3D", true, false):
		var mi: = node as MeshInstance3D
		if mi.mesh == null or mi.mesh.get_surface_count() == 0:
			continue
		var m: = mi.mesh.surface_get_material(0)
		var mname: = m.resource_name if m != null else ""
		var col: Color
		if mname == "JumboScreen":
			col = SCREEN_GLARE
		elif mname == "LedBoard":
			col = BOARD_GLARE if String(mi.name).begins_with("Courtside Board") else RIBBON_GLARE
		else:
			continue
		var a: = mi.mesh.surface_get_arrays(0)
		var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var ns: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
		if vs.size() != 4:
			continue
		var xf: = to_me * mi.global_transform
		var c: = Vector3.ZERO
		var nrm: = Vector3.ZERO
		for i in 4:
			c += xf * vs[i]
			nrm += xf.basis * ns[i]
		c /= 4.0
		nrm = nrm.normalized()

		var up: = Vector3.UP - nrm * nrm.dot(Vector3.UP)
		if up.length() < 0.01:
			continue
		up = up.normalized()
		var across: = up.cross(nrm).normalized()
		var hw: = 0.0
		var hh: = 0.0
		for i in 4:
			var d: = xf * vs[i] - c
			hw = maxf(hw, absf(d.dot(across)))
			hh = maxf(hh, absf(d.dot(up)))
		var reach: = hh * 0.9
		var o: = c + nrm * 0.03
		for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), 
				Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			var off: = Vector2((hw + reach) * corner.x, (hh + reach) * corner.y)
			verts.append(o + across * off.x + up * off.y)
			uvs.append(off)
			uv2s.append(Vector2(hw, hh))
			cols.append(col)
			norms.append(nrm)
	if verts.is_empty():
		return
	var arr: = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_TEX_UV2] = uv2s
	arr[Mesh.ARRAY_COLOR] = cols
	var mesh: = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mat: = ShaderMaterial.new()
	mat.shader = GLARE_SHADER
	var gi: = MeshInstance3D.new()
	gi.name = "Screen Glare"
	gi.mesh = mesh
	gi.material_override = mat
	gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gi.layers = 1 << (SCREEN_LAYER - 1)
	add_child(gi)




func _edge_mist(ring: Array[MeshInstance3D]) -> void :
	if ring.is_empty():
		return
	var to_me: = global_transform.affine_inverse()
	var box: = AABB()
	var first: = true
	for mi in ring:
		var bb: AABB = (to_me * mi.global_transform) * mi.get_aabb()
		box = bb if first else box.merge(bb)
		first = false
	var hx: = box.size.x * 0.5
	var hz: = box.size.z * 0.5
	var mid: = box.get_center()
	var floor_y: = box.position.y
	var rng: = RandomNumberGenerator.new()
	rng.seed = 7041
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE
	mm.mesh = quad
	mm.instance_count = MIST_PUFFS
	for i in MIST_PUFFS:

		var t: = rng.randf() * 4.0
		var side: = int(t)
		var f: = t - float(side)
		var inset: = pow(rng.randf(), 1.6) * 4.5 + 1.4
		var p: = Vector2.ZERO
		match side:
			0: p = Vector2(lerpf( - hx, hx, f), - hz + inset)
			1: p = Vector2(hx - inset, lerpf( - hz, hz, f))
			2: p = Vector2(lerpf(hx, - hx, f), hz - inset)
			_: p = Vector2( - hx + inset, lerpf(hz, - hz, f))


		var w: = rng.randf_range(5.0, 9.0)
		var h: = rng.randf_range(0.5, 0.95)
		mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(w, h, 1.0)), 
			Vector3(mid.x + p.x, floor_y, mid.z + p.y)))
		mm.set_instance_custom_data(i, Color(rng.randf(), 0.0, 0.0, 0.0))
	var mat: = ShaderMaterial.new()
	mat.shader = MIST_SHADER
	mat.set_shader_parameter("color", Color(0.8, 0.73, 0.6))


	mat.render_priority = 10
	var mmi: = MultiMeshInstance3D.new()
	mmi.name = "Edge Mist"
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.custom_aabb = AABB(Vector3(-80, -10, -90), Vector3(160, 30, 180))
	add_child(mmi)
	_mats.append(mat)








func _hide_hud(_dt: float) -> void :
	if not _hud_found:
		_hud_found = true
		_hud_nodes.clear()
		var root: = _match_root()
		if root != null:
			for c in root.get_children():
				if c != self:
					_collect_hud(c, false)
		get_tree().node_added.connect(_hud_added)
		get_tree().node_removed.connect(_hud_removed)
	var hide: = 1 << (FEED_HIDE_LAYER - 1)
	for vi in _hud_nodes:
		if vi.layers & 1:
			vi.layers = (vi.layers & ~ 1) | hide


func _hud_flag(n: Node, parent_hud: bool) -> bool:
	if parent_hud:
		return true
	var par: = n.get_parent()
	if par is Player and not (String(n.name) in PLAYER_KEEP):
		return true
	if par is Ball and not (String(n.name) in BALL_KEEP):
		return true
	if String(n.name) in BALL_HUD and par != null and par.get_parent() is Ball:
		return true
	var cls: String = n.get_script().get_global_name() if n.get_script() != null else ""
	return cls in HUD_CLASSES or n is Label3D or n is Sprite3D




func _match_root() -> Node:
	var p: Node = self
	while p.get_parent() != null and not (p.get_parent() is Viewport):
		p = p.get_parent()
	return p

func _collect_hud(n: Node, parent_hud: bool) -> void :
	var hud: = _hud_flag(n, parent_hud)
	if hud and n is VisualInstance3D:
		_hud_nodes.append(n as VisualInstance3D)
	for c in n.get_children():
		_collect_hud(c, hud)



func _hud_added(n: Node) -> void :


	if not (n is VisualInstance3D) or not is_inside_tree():
		return
	var root: = _match_root()
	var chain: Array[Node] = []
	var p: = n
	while p != null and p != root:
		if p == self:
			return
		chain.append(p)
		p = p.get_parent()
	if p == null:
		return
	var hud: = false
	for i in range(chain.size() - 1, -1, -1):
		hud = _hud_flag(chain[i], hud)
	if hud and not _hud_nodes.has(n):
		_hud_nodes.append(n as VisualInstance3D)

func _hud_removed(n: Node) -> void :
	if n is VisualInstance3D:
		_hud_nodes.erase(n)
