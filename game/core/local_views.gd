class_name LocalViews
extends RefCounted





































enum Mode{SOLO, SPLIT2, QUAD, OMNI}

const MAX_SPLIT: = 2



const PRIVATE_FIRST: = 17
const PRIVATE_COUNT: = 4
const ALL_LAYERS: = (1 << 20) - 1




const FEED_HIDE_LAYER: = 13
const FEED_HIDE_MASK: = 1 << (FEED_HIDE_LAYER - 1)


class View extends RefCounted:
	var rig: CameraRig = null
	var viewport: Viewport = null
	var box: SubViewportContainer = null
	var overlay: Overlay = null
	var owners: Array = []
	var index: = 0
	var fullscreen: = true

	func owns(slot) -> bool:
		return slot in owners


	func size() -> Vector2:
		return viewport.get_visible_rect().size if viewport != null else Vector2.ZERO


	func private_mask() -> int:
		return LocalViews.private_mask(index)





class Overlay extends Control:
	var _sight: TextureRect = null


	var _cursors: = {}
	var _scale: = 1.0

	func _init(pixel_scale: float) -> void :
		_scale = pixel_scale
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var src: Texture2D = load(GameConfig.CURSOR_AIM)
		if src != null:
			var img: = src.get_image()
			var s: = GameConfig.CURSOR_SIZE
			img.resize(s, s, Image.INTERPOLATE_NEAREST)
			_sight = TextureRect.new()
			_sight.texture = ImageTexture.create_from_image(img)
			_sight.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_sight.anchor_left = 0.5
			_sight.anchor_top = 0.5
			_sight.anchor_right = 0.5
			_sight.anchor_bottom = 0.5
			_sight.offset_left = - s * 0.5
			_sight.offset_top = - s * 0.5
			_sight.offset_right = s * 0.5
			_sight.offset_bottom = s * 0.5
			_sight.pivot_offset = Vector2(s, s) * 0.5
			_sight.scale = Vector2(_scale, _scale)
			_sight.visible = false
			add_child(_sight)




	var _burnout: ColorRect = null

	func set_burnout(amount: float, pulse: = 0.0) -> void :
		if _burnout == null:
			if amount <= 0.001:
				return
			_burnout = ColorRect.new()
			_burnout.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_burnout.set_anchors_preset(Control.PRESET_FULL_RECT)
			var mat: = ShaderMaterial.new()
			mat.shader = Hud.BURNOUT_SHADER
			_burnout.material = mat
			add_child(_burnout)
			move_child(_burnout, 0)
		_burnout.visible = amount > 0.001
		var m: = _burnout.material as ShaderMaterial
		m.set_shader_parameter("amount", clampf(amount, 0.0, 1.0))
		m.set_shader_parameter("pulse", clampf(pulse, 0.0, 1.0))



	var _ball: OffscreenBall = null

	func track_ball(camera: Camera3D, ball: Node3D, active: bool, near_to: Node3D) -> void :
		if _ball == null:
			if not active:
				return
			_ball = OffscreenBall.new()
			add_child(_ball)
		if ball != null and "stage_ball" in ball:
			_ball.ball_tex = PointWipe.ball_image_for(String(ball.stage_ball))
		var dist: = -1.0
		if ball != null and near_to != null:
			dist = ball.global_position.distance_to(near_to.global_position)
		_ball.track(camera, ball.global_position if ball != null else Vector3.ZERO, 
			active and ball != null, dist)



	var _notice: PanelContainer = null
	var _notice_label: Label = null
	var _notice_left: = 0.0

	func set_notice(text: String, color: Color, seconds: = 0.0) -> void :
		if text == "":
			if _notice != null:
				_notice.visible = false
			return
		if _notice == null:
			_notice = PanelContainer.new()
			var b: = StyleBoxFlat.new()
			b.bg_color = Color(0.08, 0.08, 0.1, 0.92)
			b.set_corner_radius_all(14)
			b.border_width_top = 6
			b.content_margin_left = 26.0
			b.content_margin_right = 26.0
			b.content_margin_top = 18.0
			b.content_margin_bottom = 18.0
			_notice.add_theme_stylebox_override("panel", b)
			_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_notice_label = Label.new()
			_notice_label.add_theme_font_size_override("font_size", 22)
			_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_notice.add_child(_notice_label)
			add_child(_notice)
		(_notice.get_theme_stylebox("panel") as StyleBoxFlat).border_color = color
		_notice_label.text = text
		_notice.visible = true
		_notice.reset_size()
		_notice.position = (size - _notice.size) * 0.5
		_notice_left = seconds

	func _process(delta: float) -> void :
		if _notice != null and _notice.visible:
			_notice.position = (size - _notice.size) * 0.5
			if _notice_left > 0.0:
				_notice_left -= delta
				if _notice_left <= 0.0:
					_notice.visible = false




	var _sight_outline: TextureRect = null
	var _sight_shape: = "\n"
	var _sight_builtin: Texture2D = null

	func set_sight(on: bool, color: Color, shape: = "", size: = 1.0, 
			outline: = Color(0, 0, 0, 0)) -> void :
		if _sight == null:
			return
		_sight.visible = on
		_sight.modulate = color
		if _sight_outline == null:
			_sight_builtin = _sight.texture
			_sight_outline = TextureRect.new()
			for tr in [_sight_outline, _sight]:
				tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tr.anchor_left = 0.5
				tr.anchor_top = 0.5
				tr.anchor_right = 0.5
				tr.anchor_bottom = 0.5
			add_child(_sight_outline)
			move_child(_sight_outline, _sight.get_index())
		if shape != _sight_shape:
			_sight_shape = shape
			var tex: Texture2D = Crosshair.tex(shape) if shape != "" else _sight_builtin
			_sight.texture = tex
			_sight_outline.texture = tex

		var box: = CROSSHAIR_PX * size if shape != "" else float(GameConfig.CURSOR_SIZE)
		var k: = _scale if shape == "" else 1.0
		for pair in [[_sight, box], [_sight_outline, box * OUTLINE_GROW]]:
			var tr: TextureRect = pair[0]
			var b: float = pair[1]
			tr.offset_left = - b * 0.5
			tr.offset_top = - b * 0.5
			tr.offset_right = b * 0.5
			tr.offset_bottom = b * 0.5
			tr.pivot_offset = Vector2(b, b) * 0.5
			tr.scale = Vector2(k, k)
		_sight_outline.modulate = outline
		_sight_outline.visible = on and outline.a > 0.0





	const CROSSHAIR_PX: = 10.0
	const OUTLINE_GROW: = 1.28




	func set_cursor(key, on: bool, pos: Vector2, color: Color, shape: = "", size: = 1.0, 
			outline: = Color(0, 0, 0, 0)) -> void :
		var e: Dictionary = _cursors.get(key, {})
		if not on:
			if e.has("fill"):
				(e.fill as TextureRect).visible = false
				(e.outline as TextureRect).visible = false
			return
		if e.is_empty():
			var ol: = TextureRect.new()
			var r: = TextureRect.new()
			for tr in [ol, r]:
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(tr)
			ol.z_index = 99
			r.z_index = 100
			e = {"fill": r, "outline": ol, "shape": null}
			_cursors[key] = e
		var rect: = e.fill as TextureRect
		var orect: = e.outline as TextureRect
		if shape != e.shape:
			e.shape = shape
			var tex: Texture2D = Crosshair.tex(shape) if shape != ""\
			else GameConfig.aim_cursor_texture()
			rect.texture = tex
			orect.texture = tex


		var box: = CROSSHAIR_PX * size if shape != ""\
		else float(rect.texture.get_size().x) * _scale if rect.texture != null else 0.0
		rect.visible = rect.texture != null
		rect.modulate = color
		rect.size = Vector2(box, box)
		rect.position = pos - Vector2(box, box) * 0.5
		var ob: = box * OUTLINE_GROW
		orect.visible = rect.visible and outline.a > 0.0
		orect.modulate = outline
		orect.size = Vector2(ob, ob)
		orect.position = pos - Vector2(ob, ob) * 0.5

static func mode_for(count: int) -> Mode:
	if count <= 1:
		return Mode.SOLO
	if count == 2:
		return Mode.SPLIT2
	return Mode.OMNI











static var two_always_split: = false

static func view_groups(slots: Array) -> Array:
	if slots.size() <= 1:
		return [slots.duplicate()]
	if slots.size() == 2:
		var same: bool = slots[0].team_side == slots[1].team_side
		if same and GameConfig.split_pref == GameConfig.SplitPref.SHARED_WHEN_POSSIBLE\
		and not two_always_split:
			return [slots.duplicate()]
		return [[slots[0]], [slots[1]]]

	var home: Array = []
	var away: Array = []
	for s in slots:
		if s.team_side < 0:
			away.append(s)
		else:
			home.append(s)
	var p1_away: bool = slots[0].team_side < 0
	var groups: Array = []

	if p1_away:
		if not away.is_empty(): groups.append(away)
		if not home.is_empty(): groups.append(home)
	else:
		if not home.is_empty(): groups.append(home)
		if not away.is_empty(): groups.append(away)
	return groups

static func private_mask(index: int) -> int:
	return 1 << (PRIVATE_FIRST - 1 + clampi(index, 0, PRIVATE_COUNT - 1))

static func _all_private() -> int:
	var m: = 0
	for i in PRIVATE_COUNT:
		m |= private_mask(i)
	return m



static func cull_mask_for(index: int) -> int:
	return (ALL_LAYERS & ~ _all_private()) | private_mask(index)



static func privatize(node: Node, index: int) -> void :
	if node == null:
		return
	var bit: = private_mask(index)
	if node is VisualInstance3D:
		(node as VisualInstance3D).layers = bit
	for c in node.get_children():
		privatize(c, index)





static func unprivatize(node: Node) -> void :
	if node == null:
		return
	if node is VisualInstance3D:
		(node as VisualInstance3D).layers = 1
	for c in node.get_children():
		unprivatize(c)




static func build(host: Node, slots: Array, base_rig: CameraRig) -> Array:
	var views: Array = []
	var root: = host.get_viewport()



	var groups: = view_groups(slots)



	var converge: bool = groups.size() == 1 and (groups[0] as Array).size() > 1
	if groups.size() <= 1 and not converge:
		var solo: = View.new()
		solo.rig = base_rig
		solo.viewport = root
		solo.owners = (groups[0] if not groups.is_empty() else slots).duplicate()
		solo.index = 0
		views.append(solo)
		return views
	var layer: = CanvasLayer.new()
	layer.name = "SplitLayer"
	layer.layer = 0
	host.add_child(layer)
	var row: = HBoxContainer.new()
	row.name = "SplitRow"
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(row)


	_fit_native(layer, row, root)



	var fit_cb: = func(): _fit_native(layer, row, root)
	layer.set_meta("fit_cb", fit_cb)
	root.size_changed.connect(fit_cb)
	var world: = root.world_3d
	var pixel_scale: = 1.0 / maxf(root.get_screen_transform().get_scale().x, 0.001)
	for i in groups.size():
		var group: Array = groups[i]
		var box: = SubViewportContainer.new()
		box.name = "View%d" % i
		box.stretch = true
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.mouse_filter = Control.MOUSE_FILTER_PASS
		box.material = opaque_material()
		row.add_child(box)
		var sub: = SubViewport.new()
		sub.handle_input_locally = false
		sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		sub.world_3d = world
		_configure_like(sub, root)

		sub.audio_listener_enable_3d = i == 0
		box.add_child(sub)
		var view: = View.new()
		view.index = i
		view.fullscreen = false
		view.viewport = sub
		view.box = box
		view.owners = group.duplicate()
		if i == 0:


			base_rig.reparent(sub)
			view.rig = base_rig
		else:
			view.rig = make_rig(sub, base_rig)



		var lead = group[0]
		view.rig.device = lead.device
		view.rig.bindings = lead.binding_table()
		view.rig.camera.current = true
		view.rig.camera.cull_mask = cull_mask_for(i)

		var ov_layer: = CanvasLayer.new()
		ov_layer.name = "Overlay"
		sub.add_child(ov_layer)
		view.overlay = Overlay.new(pixel_scale)
		ov_layer.add_child(view.overlay)
		views.append(view)


	if groups.size() >= 2:
		var seam: = Panel.new()
		seam.name = "Seam"
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.04, 0.05)
		seam.add_theme_stylebox_override("panel", sb)
		seam.custom_minimum_size.x = 3
		seam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(seam)
		row.move_child(seam, 1)
	return views


static func _fit_native(layer: CanvasLayer, row: Control, root: Viewport) -> void :




	if not is_instance_valid(layer) or not is_instance_valid(row)\
	or not is_instance_valid(root):
		return
	var k: = root.get_screen_transform().get_scale().x
	if k <= 0.001:
		k = 1.0
	layer.transform = Transform2D.IDENTITY.scaled(Vector2(1.0 / k, 1.0 / k))
	row.position = Vector2.ZERO
	row.size = root.get_visible_rect().size * k










static var _opaque_mat: ShaderMaterial = null

static func opaque_material() -> ShaderMaterial:
	if _opaque_mat == null:
		var sh: = Shader.new()
		sh.code = "shader_type canvas_item;\nvoid fragment() {\n\tCOLOR = vec4(texture(TEXTURE, UV).rgb, 1.0);\n}\n"
		_opaque_mat = ShaderMaterial.new()
		_opaque_mat.shader = sh
	return _opaque_mat



static func _configure_like(sub: SubViewport, root: Viewport) -> void :
	sub.add_to_group(GameConfig.ROOT_LIKE_VIEWS)
	sub.msaa_3d = root.msaa_3d
	sub.msaa_2d = root.msaa_2d
	sub.screen_space_aa = root.screen_space_aa
	sub.use_taa = root.use_taa
	sub.use_debanding = root.use_debanding
	sub.scaling_3d_mode = root.scaling_3d_mode
	sub.scaling_3d_scale = root.scaling_3d_scale
	sub.fsr_sharpness = root.fsr_sharpness
	sub.texture_mipmap_bias = root.texture_mipmap_bias
	sub.anisotropic_filtering_level = root.anisotropic_filtering_level
	sub.positional_shadow_atlas_size = root.positional_shadow_atlas_size
	sub.positional_shadow_atlas_16_bits = root.positional_shadow_atlas_16_bits
	sub.mesh_lod_threshold = root.mesh_lod_threshold
	sub.use_occlusion_culling = root.use_occlusion_culling
	sub.use_hdr_2d = root.use_hdr_2d
	sub.canvas_item_default_texture_filter = root.canvas_item_default_texture_filter



static func make_rig(parent: Node, like: CameraRig) -> CameraRig:
	var rig: = CameraRig.new()
	rig.name = "CameraRig2"
	var cam: = Camera3D.new()
	cam.name = "Camera3D"
	cam.fov = like.camera.fov if like.camera != null else 72.0
	cam.near = like.camera.near if like.camera != null else 0.05
	cam.far = like.camera.far if like.camera != null else 4000.0
	if like.camera != null:
		cam.attributes = like.camera.attributes
		cam.environment = like.camera.environment
	rig.add_child(cam)
	parent.add_child(rig)
	rig.mode = like.mode
	rig.home_side = like.home_side
	rig.court_span = like.court_span
	rig.tv_center_x = like.tv_center_x
	return rig





static func set_collapsed(views: Array, on: bool) -> void :
	if views.size() < 2 or views[0].box == null:
		return
	var row: = views[0].box.get_parent() as Control
	if row == null:
		return
	var seam: = row.get_node_or_null("Seam") as Control
	if seam != null:
		seam.visible = not on
	for i in range(1, views.size()):
		var v = views[i]
		if v.box.visible == not on:
			continue
		v.box.visible = not on
		(v.viewport as SubViewport).render_target_update_mode = \
		SubViewport.UPDATE_DISABLED if on else SubViewport.UPDATE_ALWAYS

static func is_collapsed(views: Array) -> bool:
	return views.size() >= 2 and views[1].box != null and not views[1].box.visible



static func teardown(host: Node, views: Array, base_rig: CameraRig) -> void :
	if views.is_empty() or views[0].fullscreen:
		return
	base_rig.reparent(host)
	base_rig.device = DeviceInput.MERGED
	base_rig.camera.current = true
	base_rig.camera.cull_mask = ALL_LAYERS
	var layer: = host.get_node_or_null("SplitLayer")
	if layer != null:

		var root: = host.get_viewport()
		if layer.has_meta("fit_cb") and root != null:
			var cb: Callable = layer.get_meta("fit_cb")
			if root.size_changed.is_connected(cb):
				root.size_changed.disconnect(cb)




		host.remove_child(layer)
		layer.queue_free()
