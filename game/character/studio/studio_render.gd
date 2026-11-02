class_name StudioRender
extends Node
















const POSES: = [
	["idle", "idle", "idle", 0.0], ["ready", "ready", "idle_alt", 0.0], 
	["cool", "cool", "intro_cool", 0.5], ["sass", "sass", "intro_sass", 0.5], 
	["nice", "nice", "nice1", 0.0], ["igot", "i got it", "igot_r", 0.8], 
	["run", "run", "jog", 0.5], ["sprint", "sprint", "sprint", 0.5], 
	["shuffle", "shuffle", "strafe_left", 0.5], ["backpedal", "backpedal", "run_back", 0.5], 
	["skid", "skid", "stop", 0.25], ["jump", "jump", "jump_rise", 0.5], 
	["fall", "fall", "jump_fall", 0.5], ["land", "land", "land", 0.25], 
	["approach", "approach", "approach", 0.5], ["crouch", "crouch", "charge", 0.75], 
	["spike", "spike", "spike", 0.05], ["tip", "tip", "spike_light", 0.05], 
	["serve", "serve", "serve", 0.75], ["set", "set", "set", 0.25], 
	["jump_set", "jump set", "set_air", 0.25], ["low_set", "low set", "set_low", 0.5], 
	["dig", "dig", "recieve", 0.25], ["dig_left", "dig left", "recieve_l", 0.25], 
	["dig_right", "dig right", "recieve_r", 0.25], ["dig_back", "dig back", "recieve_back", 0.25], 
	["block", "block", "block", 0.5], ["blocked", "blocked", "block_hit", 0.25], 
	["dive", "dive", "dive", 0.5], 
	["dive_left", "dive left", "dive_l", 0.25], ["dive_right", "dive right", "dive_r", 0.25], 
	["tired", "tired", "dive_burnout", 0.5], ["getup", "get up", "getup_front", 0.25], 
	["getup_back", "get up back", "getup_back", 0.0], 
	["backset", "back set", "backset", 0.43], ["backset_air", "jump back set", "backset_air", 0.5], 
]


const FLOOR_POSES: = ["low_set", "dive", "dive_left", "dive_right", "tired", "getup", 
	"getup_back"]
const FLOOR_TURN: = 60.0
const LEFT_TWINS: = {"spike": "spike_l", "spike_light": "spike_light_l", 
	"jump_rise": "jump_rise_l", "igot_r": "igot_l"}


static func has_twin(id: String) -> bool:
	return LEFT_TWINS.has(pose_clip(id))


const OUTFITS: = ["uniform", "alternate", "gym", "pinny"]

const FOV: = 12.0
const DRESS_FRAMES: = 4
const POSE_FRAMES: = 2
const IDLE_SHRINK: = 2.0

var _vp: SubViewport
var _cam: Camera3D
var _avatar: PresentationCharacter
var _look: = 0
var _busy: = false
var _last_use: = 0.0

static func pose_ids() -> Array:
	var out: Array = []
	for p in POSES:
		out.append(p[0])
	return out

static func pose_label(id: String) -> String:
	for p in POSES:
		if p[0] == id:
			return p[1]
	return id

static func pose_frame(id: String) -> float:
	for p in POSES:
		if p[0] == id:
			return float(p[3])
	return 0.0

static func pose_clip(id: String) -> String:
	for p in POSES:
		if p[0] == id:
			return p[2]
	return "idle"


static func outfit_look(base: CharacterConfig, idx: int) -> Dictionary:
	match idx:
		1:
			var away: = base.clone()
			away.casual = false
			return {"cfg": away, "kit": TeamKits.alternate(away.captain_kit, away.captain_kit)}
		2:
			var gym: = base.gym_look()
			return {"cfg": gym, "kit": gym.gym_kit()}
		3:


			var captain: = TeamKits.normalize(base.captain_kit)
			var pin: = base.gym_look()
			pin.wear_pinny = true
			pin.pinny_color = captain[0]
			pin.pinny_accent = TeamKits.number_ink(captain[0])
			return {"cfg": pin, "kit": pin.gym_kit()}
	var home: = base.clone()
	home.casual = false
	return {"cfg": home, "kit": TeamKits.normalize(home.captain_kit)}

static func can_render() -> bool:


	return DisplayServer.get_name() != "headless"



func _ensure() -> void :
	if _vp != null:
		return
	_vp = SubViewport.new()
	_vp.transparent_bg = true
	_vp.own_world_3d = true
	_vp.msaa_3d = Viewport.MSAA_4X
	_vp.size = Vector2i(4, 4)
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_vp)
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.25
	env.environment = e
	_vp.add_child(env)

	var key: = OmniLight3D.new()
	key.position = Vector3(1.8, 3.4, 2.6)
	key.light_color = Color(1, 0.94, 0.85)
	key.light_energy = 1.3
	key.omni_range = 16.0
	_vp.add_child(key)
	_cam = Camera3D.new()
	_cam.fov = FOV
	_cam.keep_aspect = Camera3D.KEEP_HEIGHT
	var dist: = (StudioLayer.FRAME_M * 0.5) / tan(deg_to_rad(FOV * 0.5))
	_cam.position = Vector3(0.0, StudioLayer.FOCUS_Y, dist)
	_cam.far = dist + 20.0
	_vp.add_child(_cam)
	_cam.current = true
	_avatar = PresentationCharacter.new()
	_vp.add_child(_avatar)
	_avatar.setup(CharacterConfig.new(), [])
	_avatar.set_process(false)
	_look = 0

func _process(_delta: float) -> void :


	if _vp != null and not _busy and _vp.size.x > 4 and Time.get_ticks_msec() * 0.001 - _last_use > IDLE_SHRINK:
		_vp.size = Vector2i(4, 4)

func is_busy() -> bool:
	return _busy




func render(layer: StudioLayer, px: int) -> Dictionary:
	if not can_render() or layer == null:
		return {}
	while _busy:
		await get_tree().process_frame
		if not is_instance_valid(self):
			return {}
	_busy = true
	_ensure()
	var out: = await _render_impl(layer, px)
	_busy = false
	_last_use = Time.get_ticks_msec() * 0.001
	return out

func _render_impl(layer: StudioLayer, px: int) -> Dictionary:
	if layer.kind == StudioLayer.KIND_BALL:
		return await _render_ball(layer, px)
	_show_ball(false)
	var base: = layer.cfg if layer.cfg != null else CharacterConfig.new()
	var look_key: = layer.look_key()
	var frames: = POSE_FRAMES
	if look_key != _look:
		var look: = outfit_look(base, layer.outfit)
		var was_barefoot: = GameConfig.stage_barefoot
		GameConfig.stage_barefoot = layer.barefoot
		_avatar.player.set_character(look.cfg, look.kit)
		GameConfig.stage_barefoot = was_barefoot
		_avatar.rig = _avatar.player._model
		_avatar.set_process(false)
		_look = look_key
		frames = DRESS_FRAMES
	_pose(layer.pose, layer.frame, layer.turn, base.left_handed != layer.other_hand)
	var want: = Vector2i(px, px)
	if _vp.size != want:
		_vp.size = want
		frames = maxi(frames, POSE_FRAMES)
	return await _grab(px, frames)


func _grab(px: int, frames: int) -> Dictionary:
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	for _i in frames:
		await RenderingServer.frame_post_draw
		if not is_instance_valid(self):
			return {}
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var img: = _vp.get_texture().get_image()
	if img == null or img.is_empty():
		return {}
	var used: = img.get_used_rect()
	var used_n: = Rect2(0.3, 0.2, 0.4, 0.68)
	if used.size.x > 2 and used.size.y > 2:
		used_n = Rect2(Vector2(used.position) / float(px), Vector2(used.size) / float(px))
	return {"tex": ImageTexture.create_from_image(img), "used": used_n}


func _pose(pose_id: String, t: float, turn_deg: float, left_handed: bool) -> void :
	var rig: = _avatar.rig
	if rig == null:
		return
	var ap: = rig._anim
	if rig._look != null:
		rig._look.active = false
	for sk in rig.find_children("*", "Skeleton3D", true, false):
		(sk as Skeleton3D).reset_bone_poses()
	if ap != null:
		ap.stop()
		var clip: = pose_clip(pose_id)
		if left_handed and LEFT_TWINS.has(clip) and ap.has_animation(LEFT_TWINS[clip]):
			clip = LEFT_TWINS[clip]
		if not ap.has_animation(clip):
			clip = rig.clip_name("idle")
		if clip != "" and ap.has_animation(clip):


			ap.play(clip, 0.0)
			var length: = ap.current_animation_length
			ap.seek(clampf(t, 0.0, 1.0) * maxf(length, 0.0), true)
			ap.pause()
	if rig._skel != null:
		rig._skel.force_update_all_bone_transforms()
	if rig.hands_animated():
		_avatar.player.hand_l.position = rig.hand_local(false)
		_avatar.player.hand_r.position = rig.hand_local(true)
	elif rig.hand_rest != Vector3.ZERO:
		_avatar.player.hand_r.position = rig.hand_rest
		_avatar.player.hand_l.position = Vector3( - rig.hand_rest.x, rig.hand_rest.y, rig.hand_rest.z)
	rig.tick_hair_gradient()
	_avatar.face(deg_to_rad(turn_deg))



	_avatar.reset_physics_interpolation()


	rig.settle_still()







const BALL_INNER: = 0.315 / 0.26
const BALL_RIM: = 0.385 / 0.26
const BALL_FILL: = 0.9

var _ball_root: Node3D = null
var _ball_model: Node3D = null
var _ball_rim_mat: StandardMaterial3D = null
var _ball_rim_mesh: MeshInstance3D = null
var _ball_skin: = ""

func _show_ball(on: bool) -> void :
	if _ball_root != null:
		_ball_root.visible = on
	if _avatar != null:
		_avatar.visible = not on

func _shell(r: float, col: Color) -> MeshInstance3D:
	var m: = SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 48
	m.rings = 24
	var mat: = StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	m.material = mat
	var mi: = MeshInstance3D.new()
	mi.mesh = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

func _ensure_ball() -> void :
	if _ball_root != null:
		return
	var r: = float((load("res://game/ball/ball_physics.tres") as Resource).get("radius"))
	_ball_root = Node3D.new()
	_ball_root.position = Vector3(0.0, StudioLayer.FOCUS_Y, 0.0)
	_ball_root.scale = Vector3.ONE * (StudioLayer.FRAME_M * BALL_FILL * 0.5) / (r * BALL_RIM)
	_vp.add_child(_ball_root)
	_ball_root.add_child(_shell(r * BALL_INNER, Color(0.05, 0.05, 0.08)))
	_ball_rim_mesh = _shell(r * BALL_RIM, StudioLayer.BALL_RIM_DEFAULT)
	_ball_rim_mat = (_ball_rim_mesh.mesh as SphereMesh).material as StandardMaterial3D
	_ball_root.add_child(_ball_rim_mesh)
	_ball_model = Node3D.new()
	_ball_root.add_child(_ball_model)
	_ball_root.set_meta("radius", r)

func _dress_ball(skin: String) -> void :
	if skin == _ball_skin:
		return
	_ball_skin = skin
	for c in _ball_model.get_children():
		c.queue_free()
	var path: = Stage.ball_model(skin)
	if path == "" or not ResourceLoader.exists(path):
		return
	var scene: = load(path) as PackedScene
	if scene == null:
		return
	var tex: Texture2D = null
	var tex_path: = Stage.ball_texture(skin)
	if tex_path != "" and ResourceLoader.exists(tex_path):
		tex = load(tex_path)

	var tuned: ShaderMaterial = null
	var ball_scene: = load("res://game/ball/ball.tscn") as PackedScene
	if ball_scene != null:


		var st: = ball_scene.get_state()
		for i in st.get_node_count():
			if st.get_node_name(i) != "Mesh":
				continue
			for k in st.get_node_property_count(i):
				if st.get_node_property_name(i, k) == "mesh":
					var m: Variant = st.get_node_property_value(i, k)
					if m is PrimitiveMesh:
						tuned = (m as PrimitiveMesh).material as ShaderMaterial
	var body: = scene.instantiate() as Node3D
	_ball_model.add_child(body)
	var combined: = AABB()
	var first: = true
	for c in body.find_children("*", "MeshInstance3D", true, false):
		var mi: = c as MeshInstance3D
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for s in mi.mesh.get_surface_count():
			var mat: = mi.get_active_material(s)
			if mat is BaseMaterial3D:
				var src: BaseMaterial3D = mat
				var cel: = ShaderMaterial.new()
				cel.shader = load("res://game/ball/ball_cel.gdshader")
				if tuned != null:
					for p in ["key_dir", "band_edge", "shade", "band_softness"]:
						var v: Variant = tuned.get_shader_parameter(p)
						if v != null:
							cel.set_shader_parameter(p, v)
				var use_tex: = src.albedo_texture if src.albedo_texture != null else tex
				if use_tex != null:
					cel.set_shader_parameter("albedo_tex", use_tex)
					cel.set_shader_parameter("albedo_color", Color.WHITE)
				else:
					cel.set_shader_parameter("albedo_color", src.albedo_color)
				mi.set_surface_override_material(s, cel)
		var rel: = _ball_model.global_transform.affine_inverse() * mi.global_transform
		var box: = rel * mi.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	if not first and combined.get_longest_axis_size() > 0.001:
		var k: = (float(_ball_root.get_meta("radius")) * 2.0) / combined.get_longest_axis_size()
		body.scale = Vector3.ONE * k
		body.position = - combined.get_center() * k
	for c in body.find_children("*", "MeshInstance3D", true, false):
		var mi: = c as MeshInstance3D
		var centre: = mi.global_transform.affine_inverse() * _ball_model.global_transform.origin
		for s in mi.mesh.get_surface_count():
			var cel: = mi.get_surface_override_material(s) as ShaderMaterial
			if cel != null:
				cel.set_shader_parameter("local_center", centre)

func _render_ball(layer: StudioLayer, px: int) -> Dictionary:
	_ensure_ball()
	_show_ball(true)
	var frames: = POSE_FRAMES
	if layer.ball != _ball_skin:
		_dress_ball(layer.ball)
		frames = DRESS_FRAMES
	_ball_rim_mesh.visible = layer.ball_rim
	_ball_rim_mat.albedo_color = layer.ball_rim_color
	_ball_model.rotation = Vector3(deg_to_rad(layer.frame * 360.0), deg_to_rad(layer.turn), 0.0)
	var want: = Vector2i(px, px)
	if _vp.size != want:
		_vp.size = want
	var out: = await _grab(px, frames)
	if is_instance_valid(self):
		_show_ball(false)
	return out
