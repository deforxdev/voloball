extends Control





































signal closed

const BG_SHADER: = "res://game/ui/credits_backdrop.gdshader"
const ICON_SHADER: = "res://game/ui/credits_icon.gdshader"
const LOGO: = "res://game/logo/jvlogo_sd.png"
const TITLE_SCRIPT: = "res://game/ui/title.gd"
const HOLD: = 6.0
const FADE: = 1.6
const PUSH: = 0.06
const VEIL: = Color(0.137, 0.169, 0.231, 0.52)
const LOGO_H: = 190.0
const PORTRAIT: = 170.0
const PORTRAIT_ROUND: = 0.36
const BAR_W: = 18.0
const BAR_INSET: = 12.0
const COLUMN_W: = 820.0
const BODY: = Vector2(330.0, 380.0)
const SCROLL_SPEED: = 700.0
const LINE: = Color(0.0, 0.0, 0.0)


const STIR_REACH: = 78.0
const STIR_PUSH: = 3.2
const STIR_SPIN: = 0.0016
const STIR_SPRING: = 135.0
const STIR_DAMP: = 7.5
const STIR_MAX: = 24.0
const STIR_TILT: = 0.32
const STIR_JUMP: = 260.0
const FACE_GROW: = 1.13
const THROW_SPEED: = 2200.0
const GRAB_SPEED: = 2600.0
const GRIP_PULL: = 0.6
const GRIP_SWING: = 1.3
const PLAY_DRAG: = 1.15
const PLAY_BOUNCE: = 0.58
const PLAY_GRAVITY: = 1.0
const PLAY_SPEED_MAX: = 2600.0
const PLAY_SPIN_MAX: = 16.0
const PLAY_ITERATIONS: = 64
const REST_DRIFT: = 4.0
const REST_TURN: = 0.08
const REST_TIME: = 0.3
const REST_TOUCH: = 0.12
const STAY_DRIFT: = 16.0
const STAY_TIME: = 1.5
const REST_OVERLAP: = 2.5
const WEDGE_OVERLAP: = 5.0
const WEDGE_TRIES: = 3
const WEDGE_EVERY: = 12
const WEDGE_LIVE: = 10
const RISE_SPEED: = 520.0
const RISE_DRIFT: = 90.0
const WAKE_SPEED: = 160.0
const LEFT_REACH: = 8.0
const KNOCK_STEP: = 12.0

var _bg: ColorRect
var _mat: ShaderMaterial
var _pics: Array = []
var _at: = 0
var _clock: = 0.0
var _fading: = false
var _fade_t: = 0.0
var _age_a: = 0.0
var _age_b: = 0.0
var _closing: = false
var _scroll: ScrollContainer = null
var _frames: = 0
var _reached_end: = false
var _pose: Array = []





const OUTFITS: = ["captain", "gym", "pinny"]
var outfit_pick: = ""
var _outfit: = ""
var _you_vp: SubViewport = null
var _you_vps: Array = []
var _lines: Array = []
var _stirred: Array = []
var _mouse_was: = Vector2.INF
var _faces: Array = []
var _pretend: = false
var _cursor_at: = Vector2.INF
var _pieces: Array[_Word] = []
var _loose: Array[_Word] = []
var _play_layer: Control
var _close_button: Control
var _focus_ring: Array = []
var _held: _Word = null
var _pending_link: _Word = null
var _press_at: = Vector2.ZERO
var _grab_offset: = Vector2.ZERO
var _last_scroll: = 0.0
var _last_play_size: = Vector2.ZERO
var _gravity: = false
var _play_tick: = 0
var _physics_view: SubViewport
var _walls: Array[StaticBody2D] = []
var _gravity_hint: Label



class _Word:
	var node: Control
	var run: _Run
	var off: = Vector2.ZERO
	var vel: = Vector2.ZERO
	var rot: = 0.0
	var spin: = 0.0
	var awake: = false
	var loose: = false
	var center: = Vector2.ZERO
	var half: = Vector2.ZERO
	var mass: = 1.0
	var slot: Control
	var body: _PlayBody
	var hit_rect: = Rect2()

class _PlayBody extends RigidBody2D:
	var dragging: = false
	var target: = Vector2.ZERO
	var grip: = Vector2.ZERO
	var quiet_time: = 0.0
	var settled: = false
	var rising: = false
	var floats: = 0
	var wedged: = 0
	var tangled: = 0
	var drift: = 0.0
	var rest_at: = Vector2.ZERO
	var rest_rot: = 0.0
	var untouched: = 0.0
	var stay_at: = Vector2.ZERO
	var stay_time: = 0.0
	var left_from: = Vector2.INF
	var left_box: = Rect2()
	var last_at: = Vector2.ZERO
	var last_speed: = 0.0

	func _integrate_forces(state: PhysicsDirectBodyState2D) -> void :
		if dragging:







			var held: = state.transform * grip
			var r: = held - (state.transform.origin + state.center_of_mass)
			var held_vel: = state.linear_velocity + Vector2( - r.y, r.x) * state.angular_velocity
			var want: = ((target - held) * (GRIP_PULL / state.step)).limit_length(GRAB_SPEED)
			var dv: = want - held_vel
			var im: = state.inverse_mass
			var ii: = state.inverse_inertia
			var k11: = im + ii * r.y * r.y
			var k12: = - ii * r.x * r.y
			var k22: = im + ii * r.x * r.x
			var det: = k11 * k22 - k12 * k12
			if det > 1e-12:
				var push: = Vector2((k22 * dv.x - k12 * dv.y) / det, (k11 * dv.y - k12 * dv.x) / det)
				state.linear_velocity += push * im
				state.angular_velocity += ii * r.cross(push)




		state.linear_velocity = state.linear_velocity.limit_length(PLAY_SPEED_MAX)
		state.angular_velocity = clampf(state.angular_velocity, - PLAY_SPIN_MAX, PLAY_SPIN_MAX)



class _Run:
	var box: Control
	var words: Array = []
	var moving: = 0
	var type: = false
	var heft: = 1.0

func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100

	MusicManager.set_muffled(true)
	_build_backdrop()
	_build_page()
	_build_pointer()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.22)
	_drop_hover.call_deferred()

	var args: = LaunchGate.dev_args()
	_pretend = args.has("--credits-stir")
	var at: = args.find("--credits-scroll")
	if at >= 0 and at + 1 < args.size():
		var px: = int(args[at + 1])
		get_tree().create_timer(0.5).timeout.connect( func(): _scroll.scroll_vertical = px)







func _drop_hover() -> void :
	var ev: = InputEventMouseMotion.new()
	ev.position = get_viewport().get_mouse_position()
	ev.global_position = ev.position
	get_viewport().push_input(ev, true)



func _build_backdrop() -> void :
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_bg.color = Color(VEIL.r, VEIL.g, VEIL.b, 1.0)
	add_child(_bg)
	_pics = CreditsData.backgrounds()
	if _pics.is_empty():
		return
	_mat = ShaderMaterial.new()
	_mat.shader = load(BG_SHADER)
	_mat.set_shader_parameter("veil", VEIL)
	_bg.material = _mat
	_at = 0
	_put("a", _pics[0])
	_put("b", _pics[1 % _pics.size()])
	_mat.set_shader_parameter("fade", 0.0)
	_frame_uniforms()

func _put(slot: String, tex: Texture2D) -> void :
	_mat.set_shader_parameter("tex_" + slot, tex)
	_mat.set_shader_parameter("size_" + slot, Vector2(tex.get_width(), tex.get_height()))

func _frame_uniforms() -> void :
	_mat.set_shader_parameter("rect_size", _bg.size if _bg.size.x > 0.0 else Vector2(1920, 1080))
	var span: = HOLD + FADE
	_mat.set_shader_parameter("zoom_a", 1.0 + PUSH * clampf(_age_a / span, 0.0, 1.0))
	_mat.set_shader_parameter("zoom_b", 1.0 + PUSH * clampf(_age_b / span, 0.0, 1.0))

func _process(delta: float) -> void :
	_frames += 1


	if _frames == 30:
		for stage in _you_vps:
			_hold_stage(stage)
	_pointer_tick()
	if _scroll != null and not _pointing():


		var dir: = 0.0
		if LocalPlayers.ui_pressed("ui_down"):
			dir = 1.0
		elif LocalPlayers.ui_pressed("ui_up"):
			dir = -1.0
		if dir != 0.0:
			_scroll.scroll_vertical += int(round(dir * SCROLL_SPEED * delta))


		elif InputPrompts.using_gamepad():
			var rv: = Input.get_axis("aim_up", "aim_down")
			if absf(rv) > 0.2:
				_scroll.scroll_vertical += int(round(rv * SCROLL_SPEED * 2.0 * delta))
	if _scroll != null:
		_check_end()
	var cursor: = _cursor()
	_stir(cursor, delta)
	_swell(cursor, delta)
	_playground(cursor, delta)
	if _mat == null:
		return
	_age_a += delta
	if _pics.size() > 1:
		if _fading:
			_age_b += delta
			_fade_t += delta
			_mat.set_shader_parameter("fade", clampf(_fade_t / FADE, 0.0, 1.0))
			if _fade_t >= FADE:

				_fading = false
				_at = (_at + 1) % _pics.size()
				_put("a", _pics[_at])
				_age_a = _age_b
				_put("b", _pics[(_at + 1) % _pics.size()])
				_age_b = 0.0
				_mat.set_shader_parameter("fade", 0.0)
				_clock = 0.0
		else:
			_clock += delta
			if _clock >= HOLD:
				_fading = true
				_fade_t = 0.0
				_age_b = 0.0
	_frame_uniforms()



func _hold_stage(vp: SubViewport) -> void :
	if vp == null or not is_instance_valid(vp):
		return
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	if DisplayServer.get_name() != "headless":
		var image: = vp.get_texture().get_image()
		if image != null:
			var pixels: = image.get_used_rect()
			if not pixels.has_area():
				pixels = Rect2i(Vector2i.ZERO, image.get_size())
			var ratio: = (vp.get_parent() as Control).custom_minimum_size\
			/ Vector2(image.get_size())
			vp.get_parent().set_meta("credits_hit_rect", 
				Rect2(Vector2(pixels.position) * ratio, Vector2(pixels.size) * ratio))
			for w in _pieces:
				if w.node == vp.get_parent():
					w.hit_rect = w.node.get_meta("credits_hit_rect")
					if w.body != null:
						var collider: CollisionShape2D = w.body.get_child(0)
						collider.shape.size = w.hit_rect.size.max(Vector2(2, 2))
						collider.position = w.hit_rect.get_center() - w.half


func scrolled() -> float:
	var bar: = _scroll.get_v_scroll_bar()
	var span: = bar.max_value - bar.page
	if span <= 1.0:
		return 1.0
	return clampf(bar.value / span, 0.0, 1.0)




func _check_end() -> void :
	if _reached_end or _frames < 12:
		return
	var bar: = _scroll.get_v_scroll_bar()
	if bar.value >= bar.max_value - bar.page - 3.0:
		_reached_end = true
		Achievements.notify("credits")



func _cursor() -> Vector2:
	if _pretend:


		var t: = Time.get_ticks_msec() / 1000.0
		var view: = get_viewport_rect().size
		return view * Vector2(0.5 + 0.24 * sin(t * 4.3), 0.42 + 0.3 * sin(t * 1.9))
	if _cursor_at != Vector2.INF:
		return _cursor_at
	if _pointing():
		return _pointer.pos
	return get_viewport().get_mouse_position()







var _pointer: PlayerCursor = null
var _real_mouse: = Vector2i.ZERO

func _build_pointer() -> void :
	var src: = DeviceInput.new(DeviceInput.MERGED)
	src.exclude_kbm = true
	src.exclude_pads = LocalPlayers.p1_exclude_pads()
	var ov: = CanvasLayer.new()
	ov.name = "PadPointer"
	ov.layer = 128
	add_child(ov)
	_pointer = PlayerCursor.new()
	ov.add_child(_pointer)

	_pointer.setup(get_viewport(), src, 
		LocalPlayerSlot.COLORS[0] if LocalPlayers.has_guests() else Color.WHITE, "")
	_pointer.speed_mult = PlayerCursor.sens_mult(null)
	_pointer.sleep()
	_pointer.woke.connect( func():
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_real_mouse = DisplayServer.mouse_get_position())

func mouse_took_over() -> void :
	if _pointer != null:
		_pointer.sleep()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _pointing() -> bool:
	return _pointer != null and not _pointer.sleeping

func _pointer_tick() -> void :
	if not _pointing():
		return
	if PlayerCursor.real_mouse_moved(_real_mouse):
		mouse_took_over()
		return


	if get_viewport().gui_get_focus_owner() != null:
		get_viewport().gui_release_focus()





func _stir(cursor: Vector2, delta: float) -> void :
	var step: = Vector2.ZERO
	if _mouse_was != Vector2.INF:
		step = cursor - _mouse_was
	_mouse_was = cursor
	var travelled: = step.length()
	if travelled > 0.5 and travelled < STIR_JUMP:
		for item in _lines:
			var run: _Run = item
			var at: = run.box.global_position
			if not Rect2(at, run.box.size).grow(STIR_REACH).has_point(cursor):
				continue
			for w: _Word in run.words:
				if w.loose:
					continue


				var spot: = at + w.node.position
				var far: = cursor.distance_to(cursor.clamp(spot, spot + w.node.size))
				if far >= STIR_REACH:
					continue
				var near: = 1.0 - far / STIR_REACH
				near *= near * run.heft
				w.vel += step * (STIR_PUSH * near)
				w.spin += (spot + w.node.size * 0.5 - cursor).cross(step) * (STIR_SPIN * near * run.heft)
				if not w.awake:
					_wake(w)
	var dt: = minf(delta, 1.0 / 30.0)
	var i: = _stirred.size() - 1
	while i >= 0:
		var w: _Word = _stirred[i]
		w.vel += (w.off * - STIR_SPRING - w.vel * STIR_DAMP) * dt
		w.off = (w.off + w.vel * dt).limit_length(STIR_MAX)
		w.spin += (w.rot * - STIR_SPRING - w.spin * STIR_DAMP) * dt
		w.rot = clampf(w.rot + w.spin * dt, - STIR_TILT, STIR_TILT)
		if w.off.length_squared() < 0.03 and w.vel.length_squared() < 3.0\
		and absf(w.rot) < 0.002 and absf(w.spin) < 0.03:
			_rest(w)
			_stirred.remove_at(i)
		else:
			w.node.offset_transform_position = w.off
			w.node.offset_transform_rotation = w.rot
		i -= 1

func _wake(w: _Word) -> void :
	w.awake = true
	w.node.offset_transform_enabled = true
	w.node.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	_stirred.append(w)
	w.run.moving += 1


func _rest(w: _Word) -> void :
	w.off = Vector2.ZERO
	w.vel = Vector2.ZERO
	w.rot = 0.0
	w.spin = 0.0
	w.awake = false
	w.node.offset_transform_position = Vector2.ZERO
	w.node.offset_transform_rotation = 0.0
	w.node.offset_transform_enabled = false
	w.run.moving -= 1
	if w.body != null:
		_layout_piece(w)
		w.body.position = w.center
		w.body.rotation = 0.0



func _wobbles(node: Control, heft: float) -> void :
	var run: = _Run.new()
	run.box = node.get_parent() as Control
	run.heft = heft
	var w: = _Word.new()
	w.node = node
	w.run = run
	run.words.append(w)
	_pieces.append(w)
	_lines.append(run)


func _swell(cursor: Vector2, delta: float) -> void :
	var dt: = minf(delta, 1.0 / 30.0)
	for face in _faces:
		var pic: Control = face[0]
		if pic.get_meta("credits_loose", false):
			continue
		var want: = FACE_GROW if Rect2(pic.global_position, pic.size).has_point(cursor) else 1.0
		var size: float = face[1]
		var speed: float = face[2]
		if want == 1.0 and size == 1.0 and speed == 0.0:
			continue
		speed += ((want - size) * 260.0 - speed * 15.0) * dt
		size += speed * dt
		if want == 1.0 and absf(size - 1.0) < 0.0015 and absf(speed) < 0.02:
			size = 1.0
			speed = 0.0
		face[1] = size
		face[2] = speed
		pic.offset_transform_enabled = true
		pic.offset_transform_scale = Vector2.ONE * size



func _page_point(cursor: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * cursor\
	+ Vector2(0, _scroll.scroll_vertical)

func _layout_piece(w: _Word) -> void :
	if w.loose:
		return
	var parent: = w.node.get_parent() as Control
	var transform: = get_global_transform_with_canvas().affine_inverse() * parent.get_global_transform_with_canvas()
	w.half = w.node.size * 0.5
	if not w.hit_rect.has_area():
		w.hit_rect = _word_hit_rect(w.node)
	w.center = transform * (w.node.position + w.half + w.off) + Vector2(0, _scroll.scroll_vertical)
	w.mass = clampf(sqrt(w.node.size.x * w.node.size.y) / 36.0, 1.0, 10.0)

func _piece_at(point: Vector2) -> _Word:

	for i in range(_loose.size() - 1, -1, -1):
		var w: = _loose[i]
		if w.hit_rect.has_point((point - w.center).rotated( - w.rot) + w.half):
			return w
	for i in range(_pieces.size() - 1, -1, -1):
		var w: = _pieces[i]
		if w.loose:
			continue
		_layout_piece(w)
		if w.hit_rect.has_point((point - w.center).rotated( - w.rot) + w.half):
			return w
	return null

func _loosen(w: _Word) -> void :
	if w.loose:
		return

	if not is_instance_valid(w.node) or not _pieces.has(w):
		return
	_ensure_physics()
	_layout_piece(w)
	if w.awake:
		_stirred.erase(w)
		w.awake = false
		w.run.moving -= 1
	w.loose = true
	var original: = w.node
	var parent: = original.get_parent()
	var order: = original.get_index()
	w.slot = Control.new()
	w.slot.custom_minimum_size = original.size
	w.slot.size_flags_horizontal = original.size_flags_horizontal
	w.slot.size_flags_vertical = original.size_flags_vertical
	w.slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(w.slot)
	parent.move_child(w.slot, order)
	var original_size: = original.size
	original.reparent(_play_layer, false)
	original.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	original.size = original_size
	original.scale = Vector2.ONE
	original.pivot_offset = original_size * 0.5
	original.position = Vector2.ZERO
	original.rotation = 0.0
	original.offset_transform_enabled = true
	original.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	original.offset_transform_position = Vector2.ZERO
	original.offset_transform_rotation = 0.0
	original.offset_transform_scale = Vector2.ONE
	original.set_meta("credits_loose", true)

	original.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w.body.position = w.center
	w.body.rotation = w.rot
	w.body.last_at = w.center
	w.body.settled = false
	w.body.quiet_time = 0.0
	w.body.freeze = false
	w.body.gravity_scale = PLAY_GRAVITY if _gravity else 0.0
	w.body.physics_material_override.bounce = 0.1 if _gravity else PLAY_BOUNCE
	w.body.angular_damp = 4.0 if _gravity else 2.0
	w.body.linear_velocity = w.vel
	w.body.sleeping = false
	_loose.append(w)
	_draw_piece(w)
	if original is BaseButton:
		_refresh_focus_ring()

func _grab(w: _Word, point: Vector2) -> void :
	_loosen(w)
	_held = w
	_pending_link = null
	_grab_offset = (point - w.center).rotated( - w.rot)
	w.vel = Vector2.ZERO
	w.spin = 0.0
	_play_layer.move_child(w.node, -1)


	if w.body.settled:
		_unsettle(w)
	if w.body.rising:
		_land(w)
	w.body.floats = 0


	w.body.dragging = true
	w.body.grip = _grab_offset
	w.body.target = point
	w.body.mass = maxf(w.mass, 1.0) * 4.0
	w.body.gravity_scale = PLAY_GRAVITY if _gravity else 0.0
	w.body.angular_damp = GRIP_SWING
	w.body.sleeping = false
	_loose.erase(w)
	_loose.append(w)

func _release_piece() -> void :
	if _held != null:
		_held.vel = _held.body.linear_velocity.limit_length(THROW_SPEED)
		_held.body.dragging = false
		_held.body.linear_velocity = _held.vel
		_held.body.mass = _held.mass
		_held.body.angular_damp = 4.0 if _gravity else 2.0
		_held.body.gravity_scale = PLAY_GRAVITY if _gravity else 0.0
		_held.body.quiet_time = 0.0
		_held = null

func _play_input(event: InputEvent) -> bool:
	if _frames < 3:
		return false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if _held != null:
				_release_piece()
				return true
			if _pending_link != null:
				var button: = _pending_link.node as BaseButton
				var hit: = _piece_at(_page_point(event.position))
				if hit == _pending_link:
					if button is LinkButton:
						OS.shell_open((button as LinkButton).uri)
					else:
						button.pressed.emit()
				_pending_link = null
				return true
			return false
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		if not Rect2(Vector2.ZERO, size).has_point(local):
			return false

		if _close_button.get_global_rect().has_point(event.position)\
		or _scroll.get_v_scroll_bar().get_global_rect().has_point(event.position):
			return false
		var point: = _page_point(event.position)
		var w: = _piece_at(point)
		if w == null:
			return false
		_press_at = event.position
		if w.node is BaseButton:
			_pending_link = w
		else:
			_grab(w, point)
		return true
	if event is InputEventMouseMotion:
		if _pending_link != null and event.position.distance_to(_press_at) > 6.0:
			_grab(_pending_link, _page_point(_press_at))
		return _held != null or _pending_link != null
	return false

func _draw_piece(w: _Word) -> void :
	var position: = w.center - w.half - Vector2(0, _scroll.scroll_vertical)
	if w.node.offset_transform_position != position:
		w.node.offset_transform_position = position
	if w.node.offset_transform_rotation != w.rot:
		w.node.offset_transform_rotation = w.rot


func _word_hit_rect(node: Control) -> Rect2:
	if node.has_meta("credits_hit_rect"):
		return node.get_meta("credits_hit_rect")
	if node is TextureRect and node.texture != null:
		var image: Image = node.texture.get_image()
		if image != null:
			var pixels: = image.get_used_rect()
			var ratio: = node.size / Vector2(image.get_size())
			return Rect2(Vector2(pixels.position) * ratio, Vector2(pixels.size) * ratio)
	if not node is Label:
		return Rect2(Vector2.ZERO, node.size)
	var label: = node as Label
	var font: = label.get_theme_font("font")
	var font_size: = label.get_theme_font_size("font_size")
	var line: = TextLine.new()
	line.add_string(label.text, font, font_size)
	var server: = TextServerManager.get_primary_interface()
	var pen: = Vector2(0, font.get_ascent(font_size))
	var bounds: = Rect2()
	for glyph in server.shaped_text_get_glyphs(line.get_rid()):
		if int(glyph.font_size) <= 0 or not glyph.font_rid.is_valid():
			continue
		var cache_size: = Vector2i(int(glyph.font_size), 0)
		var glyph_size: Vector2 = server.font_get_glyph_size(glyph.font_rid, cache_size, glyph.index)
		var offset: Vector2 = server.font_get_glyph_offset(glyph.font_rid, cache_size, glyph.index)
		for repeat in int(glyph.repeat):
			if glyph_size.x > 0 and glyph_size.y > 0:
				var ink: = Rect2(pen + Vector2(glyph.offset) + offset, glyph_size)
				bounds = bounds.merge(ink) if bounds.has_area() else ink
			pen.x += float(glyph.advance)
	return bounds.grow(1.5) if bounds.has_area() else Rect2(Vector2.ZERO, node.size)

func _ensure_physics() -> void :
	if _physics_view != null:
		return

	_physics_view = SubViewport.new()
	_physics_view.world_2d = World2D.new()
	_physics_view.size = Vector2i(2, 2)
	_physics_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_physics_view)


	PhysicsServer2D.space_set_param(_physics_view.world_2d.space, 
		PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS, PLAY_ITERATIONS)
	for index in _pieces.size():
		var w: = _pieces[index]
		_layout_piece(w)
		w.body = _PlayBody.new()
		w.body.freeze = true
		w.body.mass = w.mass
		w.body.gravity_scale = 0.0
		w.body.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
		w.body.linear_damp = PLAY_DRAG
		w.body.angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
		w.body.angular_damp = 2.0
		w.body.continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		w.body.max_contacts_reported = 16
		w.body.contact_monitor = true
		w.body.set_meta("credits_index", index)
		var material: = PhysicsMaterial.new()
		material.bounce = PLAY_BOUNCE
		material.friction = 0.65
		w.body.physics_material_override = material
		var collider: = CollisionShape2D.new()
		var rectangle: = RectangleShape2D.new()
		rectangle.size = w.hit_rect.size.max(Vector2(2, 2))
		collider.shape = rectangle
		collider.position = w.hit_rect.get_center() - w.half
		w.body.add_child(collider)
		w.body.position = w.center
		w.body.rotation = w.rot
		w.body.last_at = w.center
		_physics_view.add_child(w.body)
		w.body.body_entered.connect(_hit_piece.bind(w), CONNECT_DEFERRED)
	for i in 4:
		var wall: = StaticBody2D.new()
		var collider: = CollisionShape2D.new()
		collider.shape = RectangleShape2D.new()
		wall.add_child(collider)
		_physics_view.add_child(wall)
		_walls.append(wall)
	_update_walls()

func _update_walls() -> void :
	var area: = Vector2(size.x - BAR_INSET - BAR_W, maxf(size.y, _scroll.get_v_scroll_bar().max_value))
	var boxes: = [Rect2(-100, -100, 100, area.y + 200), Rect2(area.x, -100, 100, area.y + 200), 
		Rect2(-100, -100, area.x + 200, 100), Rect2(-100, area.y, area.x + 200, 100)]
	for i in 4:
		var rectangle: RectangleShape2D = _walls[i].get_child(0).shape
		rectangle.size = boxes[i].size
		_walls[i].position = boxes[i].get_center()

func _hit_piece(other: Node, source: _Word) -> void :
	if _closing or not source.loose or not is_instance_valid(other):
		return
	var index: = int(other.get_meta("credits_index", -1))
	if index >= 0:
		var hit: = _pieces[index]
		if not hit.loose:
			_loosen(hit)
		elif hit.body.settled and source.body.last_speed > WAKE_SPEED:

			_unsettle(hit)






func _settle(w: _Word) -> void :
	w.body.settled = true
	w.body.left_from = Vector2.INF
	w.body.quiet_time = 0.0
	w.body.stay_time = 0.0
	w.body.linear_velocity = Vector2.ZERO
	w.body.angular_velocity = 0.0
	w.body.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	w.body.freeze = true







func _unsettle(w: _Word) -> void :
	w.body.settled = false
	w.body.quiet_time = 0.0
	w.body.stay_time = 0.0
	w.body.stay_at = w.body.position
	w.body.last_at = w.body.position
	w.body.left_from = w.body.position
	w.body.left_box = _box_of(w)
	w.body.freeze = false
	w.body.sleeping = false




func _wake_above(box: Rect2, top_of: float) -> void :
	var reach: = box.grow(6.0)
	for w in _loose:
		if w.body.settled and w.body.position.y <= top_of + 2.0 and reach.intersects(_box_of(w)):
			_unsettle(w)



func _float_out(w: _Word) -> void :
	w.body.rising = true
	w.body.floats += 1
	w.body.drift = randf_range( - RISE_DRIFT, RISE_DRIFT)
	w.body.quiet_time = 0.0
	w.body.collision_layer = 0
	w.body.collision_mask = 0
	w.body.gravity_scale = 0.0

func _land(w: _Word) -> void :
	w.body.rising = false
	w.body.collision_layer = 1
	w.body.collision_mask = 1
	w.body.gravity_scale = PLAY_GRAVITY if _gravity else 0.0
	w.body.linear_velocity = Vector2.ZERO
	w.body.last_at = w.body.position



func _sunk_depth(w: _Word, at_rest: = false) -> float:
	var deepest: = 0.0
	var mine: = _corners_of(w)
	var near: = _box_of(w)
	for other in _loose:
		if other == w or other.body.rising or (at_rest and not other.body.settled)\
		or not near.intersects(_box_of(other)):
			continue
		deepest = maxf(deepest, _overlap(mine, _corners_of(other)))
	return deepest


func _corners_of(w: _Word) -> PackedVector2Array:
	var collider: CollisionShape2D = w.body.get_child(0)
	var half: Vector2 = (collider.shape as RectangleShape2D).size * 0.5
	var xf: Transform2D = w.body.transform * Transform2D(0.0, collider.position)
	return PackedVector2Array([xf * Vector2( - half.x, - half.y), xf * Vector2(half.x, - half.y), 
		xf * Vector2(half.x, half.y), xf * Vector2( - half.x, half.y)])



func _overlap(a: PackedVector2Array, b: PackedVector2Array) -> float:
	var least: = INF
	for poly: PackedVector2Array in [a, b]:
		for i in 2:
			var axis: Vector2 = (poly[i + 1] - poly[i]).orthogonal().normalized()
			var a0: = INF
			var a1: = - INF
			var b0: = INF
			var b1: = - INF
			for p in a:
				a0 = minf(a0, p.dot(axis))
				a1 = maxf(a1, p.dot(axis))
			for p in b:
				b0 = minf(b0, p.dot(axis))
				b1 = maxf(b1, p.dot(axis))
			var over: = minf(a1, b1) - maxf(a0, b0)
			if over <= 0.0:
				return 0.0
			least = minf(least, over)
	return least


func _box_of(w: _Word) -> Rect2:
	var collider: CollisionShape2D = w.body.get_child(0)
	var half: Vector2 = (collider.shape as RectangleShape2D).size * 0.5
	var turn: = w.body.rotation
	var reach: = Vector2(absf(cos(turn)) * half.x + absf(sin(turn)) * half.y, 
		absf(sin(turn)) * half.x + absf(cos(turn)) * half.y)
	var middle: = w.body.position + collider.position.rotated(turn)
	return Rect2(middle - reach, reach * 2.0)

func _physics_process(delta: float) -> void :
	if _physics_view == null or _closing:
		return

	for w: _Word in _stirred:
		_layout_piece(w)
		w.body.position = w.center
		w.body.rotation = w.rot
	var width: = size.x - BAR_INSET - BAR_W
	var floor_y: = maxf(size.y, _scroll.get_v_scroll_bar().max_value)

	var stride: = PLAY_SPEED_MAX * delta * 1.5 + 2.0
	_play_tick += 1
	var turn: = 0
	for w in _loose:
		var body: = w.body
		turn += 1
		if body.settled:
			continue
		var at: = body.position







		var moved: = at - body.last_at
		var wild: = not (is_finite(at.x) and is_finite(at.y)) or moved.length() > stride


		var thick: = minf(w.hit_rect.size.x, w.hit_rect.size.y) * 0.5
		var inside: = Vector2(clampf(at.x, thick, width - thick), clampf(at.y, thick, floor_y - thick))\
		if not wild else body.last_at
		if wild or inside != at:
			var vel: = body.linear_velocity
			if not (is_finite(vel.x) and is_finite(vel.y)) or wild:
				vel = Vector2.ZERO

			if inside.x != at.x and not wild:
				vel.x = 0.0
			if inside.y != at.y and not wild:
				vel.y = 0.0
			body.position = inside
			body.linear_velocity = vel
			if wild:
				body.angular_velocity = 0.0
				if not is_finite(body.rotation):
					body.rotation = 0.0
			at = inside



		if moved.length() > KNOCK_STEP and not wild:
			_knock_along(w, body.last_at, at)
		body.last_at = at
		body.last_speed = body.linear_velocity.length()

		if body.left_from != Vector2.INF and at.distance_to(body.left_from) > LEFT_REACH:
			_wake_above(body.left_box, body.left_from.y)
			body.left_from = Vector2.INF


		if body.rising:

			body.linear_velocity = Vector2(body.drift, - RISE_SPEED)
			body.angular_velocity = 0.0
			if _sunk_depth(w) <= REST_OVERLAP or at.y <= w.half.length():
				_land(w)
			continue





		if _gravity and w != _held and (_play_tick + turn) % WEDGE_EVERY == 0:
			body.wedged = body.wedged + 1 if _sunk_depth(w, true) > WEDGE_OVERLAP else 0


			body.tangled = body.tangled + 1 if _sunk_depth(w) > WEDGE_OVERLAP else 0
			if body.wedged >= 2 or body.tangled >= WEDGE_LIVE:
				body.wedged = 0
				body.tangled = 0
				if body.floats < WEDGE_TRIES:
					_float_out(w)
				else:
					_settle(w)
				continue





		body.untouched = 0.0 if body.get_contact_count() > 0 or body.sleeping else body.untouched + delta
		if at.distance_to(body.stay_at) < STAY_DRIFT:
			body.stay_time += delta
		else:
			body.stay_at = at
			body.stay_time = 0.0
		if _gravity and w != _held and body.untouched < REST_TOUCH and body.stay_time >= STAY_TIME\
		and _sunk_depth(w) <= WEDGE_OVERLAP:
			_settle(w)
			continue
		if _gravity and w != _held and body.untouched < REST_TOUCH\
		and at.distance_to(body.rest_at) < REST_DRIFT\
		and absf(angle_difference(body.rotation, body.rest_rot)) < REST_TURN:
			body.quiet_time += delta
			if body.quiet_time >= REST_TIME:







				var sunk: = _sunk_depth(w)
				if sunk <= REST_OVERLAP or body.floats >= WEDGE_TRIES\
				or (sunk <= WEDGE_OVERLAP and body.quiet_time >= REST_TIME * 5.0):
					_settle(w)
				elif sunk > WEDGE_OVERLAP and body.quiet_time >= REST_TIME * 2.0:
					_float_out(w)
		else:
			body.quiet_time = 0.0
			body.rest_at = at
			body.rest_rot = body.rotation



func _knock_along(w: _Word, from: Vector2, to: Vector2) -> void :
	var collider: CollisionShape2D = w.body.get_child(0)
	var query: = PhysicsShapeQueryParameters2D.new()
	query.shape = collider.shape
	query.exclude = [w.body.get_rid()]
	var space: = _physics_view.world_2d.direct_space_state
	var steps: = mini(int(from.distance_to(to) / KNOCK_STEP), 6)
	for i in range(1, steps + 1):
		var at: = from.lerp(to, float(i) / float(steps + 1))
		query.transform = Transform2D(w.body.rotation, at + collider.position.rotated(w.body.rotation))
		for found in space.intersect_shape(query, 8):
			var other: = found.get("collider") as Node
			if other == null:
				continue
			var index: = int(other.get_meta("credits_index", -1))
			if index >= 0 and not _pieces[index].loose:
				_loosen.call_deferred(_pieces[index])

func _toggle_gravity() -> void :
	_gravity = not _gravity
	for w in _loose:


		if w.body.settled:
			_unsettle(w)
		if w.body.rising:
			_land(w)
		w.body.floats = 0
		w.body.gravity_scale = PLAY_GRAVITY if _gravity else 0.0
		w.body.physics_material_override.bounce = 0.1 if _gravity else PLAY_BOUNCE
		w.body.angular_damp = GRIP_SWING if w == _held else (4.0 if _gravity else 2.0)
		w.body.sleeping = false
	_gravity_hint.text = "G: gravity on" if _gravity else "G: gravity off"

func _playground(cursor: Vector2, delta: float) -> void :
	if _loose.is_empty() or _closing:
		return
	var local: = get_global_transform_with_canvas().affine_inverse() * cursor
	if _held != null:
		var edge: = 64.0
		var scroll_dir: = clampf((local.y - (size.y - edge)) / edge, 0.0, 1.0)\
		- clampf((edge - local.y) / edge, 0.0, 1.0)
		_scroll.get_v_scroll_bar().value += scroll_dir * SCROLL_SPEED * minf(delta, 0.05)
		_held.body.target = _page_point(cursor)
	if _last_play_size != size:
		_update_walls()
		for w in _pieces:
			if not w.loose:
				_layout_piece(w)
				w.body.position = w.center
	for w in _loose:
		w.center = w.body.position
		w.rot = w.body.rotation
		w.vel = w.body.linear_velocity
		w.spin = w.body.angular_velocity
		_draw_piece(w)
	_last_scroll = _scroll.scroll_vertical
	_last_play_size = size






func _reset_playground() -> void :
	if _closing or (_loose.is_empty() and not _gravity):
		return
	var was: = _scroll.scroll_vertical
	_release_piece()
	_held = null
	_pending_link = null
	for old: Node in [_scroll, _play_layer, _gravity_hint, _close_button, _physics_view]:
		if is_instance_valid(old):
			remove_child(old)
			old.queue_free()

	for w in _pieces:
		w.loose = false
	for run: _Run in _lines:
		run.words.clear()
	_lines.clear()
	_stirred.clear()
	_pieces.clear()
	_loose.clear()
	_faces.clear()
	_walls.clear()
	_focus_ring.clear()
	_physics_view = null
	_you_vp = null
	_you_vps.clear()
	_gravity = false
	_mouse_was = Vector2.INF
	_last_play_size = Vector2.ZERO
	_frames = 0
	_build_page()

	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(_scroll):
		_scroll.scroll_vertical = was

func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_release_piece()
		_pending_link = null

func _exit_tree() -> void :

	MusicManager.set_muffled(false)

	_held = null
	_pending_link = null
	for run: _Run in _lines:
		run.words.clear()
	_lines.clear()
	_stirred.clear()
	_pieces.clear()
	_loose.clear()





func _type(text: String, size: int, font_path: String, outline: = -1) -> Control:
	return _words(text, size, font_path, outline if outline >= 0 else maxi(6, size / 3), 0.0)



func _para(text: String, size: int, font_path: String, outline: = -1) -> Control:
	var line: = outline if outline >= 0 else maxi(6, size / 3)
	var wide: = minf(COLUMN_W, get_viewport_rect().size.x - 80.0)
	if not text.contains("\n"):
		return _words(text, size, font_path, line, wide)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for piece in text.split("\n"):
		if piece.strip_edges() == "":
			col.add_child(_gap(UiStyle.font(font_path).get_height(size)))
		else:
			col.add_child(_words(piece, size, font_path, line, wide))
	return col





func _words(text: String, size: int, font_path: String, outline: int, wide: float) -> Control:
	var font: = UiStyle.font(font_path)

	var space: = maxi(1, int(round(font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)) - 1)
	var box: Container
	if wide > 0.0:
		var flow: = HFlowContainer.new()
		flow.alignment = FlowContainer.ALIGNMENT_CENTER
		flow.add_theme_constant_override("h_separation", space)
		flow.add_theme_constant_override("v_separation", 3)
		flow.custom_minimum_size = Vector2(wide, 0)
		box = flow
	else:
		var row: = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", space)
		box = row
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var run: = _Run.new()
	run.box = box
	run.type = true
	for part in text.split(" ", false):
		var l: = Label.new()
		l.text = part
		l.add_theme_font_override("font", font)
		l.add_theme_font_size_override("font_size", size)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.add_theme_color_override("font_outline_color", LINE)
		l.add_theme_constant_override("outline_size", outline)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(l)
		var w: = _Word.new()
		w.node = l
		w.run = run
		run.words.append(w)
		_pieces.append(w)
	_lines.append(run)
	return box



func _link(text: String, url: String, size: int) -> LinkButton:
	var l: = LinkButton.new()
	l.text = text
	l.uri = url
	l.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	l.focus_mode = Control.FOCUS_ALL
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color.WHITE)
	for state in ["font_hover_color", "font_focus_color", "font_pressed_color", 
			"font_hover_pressed_color"]:
		l.add_theme_color_override(state, UiStyle.PRIMARY)
	l.add_theme_color_override("font_outline_color", LINE)
	l.add_theme_constant_override("outline_size", maxi(6, size / 3))
	l.add_theme_constant_override("underline_spacing", 4)
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.pressed.connect(UiStyle.sfx.bind("press"))
	UiStyle.hover_sound(l)
	return l

func _gap(h: float) -> Control:
	var c: = Control.new()
	c.custom_minimum_size = Vector2(0, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

func _build_page() -> void :
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_scroll.offset_right = - BAR_INSET
	_scroll.offset_top = 8.0
	_scroll.offset_bottom = -8.0
	_style_bar(_scroll.get_v_scroll_bar())
	add_child(_scroll)
	var margin: = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE



	margin.add_theme_constant_override("margin_left", 22 + int(BAR_INSET))
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 26)
	_scroll.add_child(margin)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(v)

	var logo: = TextureRect.new()
	logo.texture = CreditsData.picture(LOGO)


	var logo_w: = LOGO_H * 2.0
	if logo.texture != null and logo.texture.get_height() > 0:
		logo_w = LOGO_H * float(logo.texture.get_width()) / float(logo.texture.get_height())
	logo.custom_minimum_size = Vector2(logo_w, LOGO_H)
	logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(logo)
	_wobbles(logo, 0.4)
	v.add_child(_gap(14))


	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 170)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(row)
	var links: Array = []
	var delay: = 0.05
	for p in CreditsData.people():
		var col: = VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", -4)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var face: = _portrait(String(p.get("icon", "")))
		col.add_child(face)
		_wobbles(face, 0.4)
		col.add_child(_gap(8))
		col.add_child(_type(String(p.name), 44, UiStyle.FONT_BLACK))
		col.add_child(_type(String(p.role), 22, UiStyle.FONT_XBOLD, 10))
		var url: = String(p.get("link", ""))
		if url != "":
			col.add_child(_gap(10))
			var link: = Button.new()
			link.text = String(p.get("link_label", url))
			UiStyle.style_button(link, "secondary", 15)
			link.size_flags_horizontal = Control.SIZE_SHRINK_CENTER



			link.pressed.connect( func(): OS.shell_open(url))
			col.add_child(link)
			links.append(link)
			_wobbles(link, 0.55)
		row.add_child(col)
		UiStyle.pop_in.call_deferred(face, delay)
		delay += 0.09
	v.add_child(_gap(64))


	if CreditsData.THANK_YOU_TO != "":


		if CreditsData.QUOTE != "":
			v.add_child(_para("“%s”" % CreditsData.QUOTE, 22, UiStyle.FONT_XBOLD, 8))
			v.add_child(_gap(4))
		v.add_child(_para("thank you to " + CreditsData.THANK_YOU_TO, 30, UiStyle.FONT_BLACK))
		v.add_child(_gap(4))
		v.add_child(_para(CreditsData.THANK_YOU_FOR, 19, UiStyle.FONT_SEMI, 7))
		v.add_child(_gap(56))

	v.add_child(_para(CreditsData.ASSETS_LINE, 19, UiStyle.FONT_SEMI, 7))
	v.add_child(_gap(56))

	v.add_child(_type(CreditsData.ENGINE_LINE, 30, UiStyle.FONT_BLACK))
	v.add_child(_gap(8))
	var notice: = _para(CreditsData.GODOT_LICENSE, 15, UiStyle.FONT_SEMI, 6)
	notice.name = "License"
	v.add_child(notice)
	v.add_child(_gap(18))

	var engine: = _link(CreditsData.GODOT_SIGNOFF, CreditsData.GODOT_LINK, 17)
	engine.name = "EngineLink"
	v.add_child(engine)
	links.append(engine)
	_wobbles(engine, 0.8)
	v.add_child(_gap(70))


	v.add_child(_type(CreditsData.FAREWELL, 44, UiStyle.FONT_BLACK))
	v.add_child(_gap(4))





	_pick_outfit()
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var looks: = _couch_looks()
	var couch_row: = HBoxContainer.new()
	couch_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	couch_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	couch_row.add_theme_constant_override("separation", - int(BODY.x * 0.34) if looks.size() > 1 else 0)
	v.add_child(couch_row)
	for i in looks.size():

		var you: = Control.new()
		you.name = "You" if i == 0 else "Couch%d" % (i + 1)
		you.custom_minimum_size = BODY
		you.mouse_filter = Control.MOUSE_FILTER_IGNORE
		couch_row.add_child(you)
		_stage_you(you, looks[i], rng, i == 0)
		_wobbles(you, 0.5)



	_play_layer = Control.new()
	_play_layer.name = "Playground"
	_play_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_play_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_layer.clip_contents = true
	add_child(_play_layer)



	_gravity_hint = Label.new()
	_gravity_hint.text = "G: gravity off"
	UiStyle.style_label(_gravity_hint, "small", Color.WHITE)
	_gravity_hint.position = Vector2(24, 24)
	_gravity_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gravity_hint.visible = false
	add_child(_gravity_hint)


	var x: = UiStyle.icon_button("cross", "exit", 46)
	x.icon = UiStyle.icon("cross", true)
	x.name = "Close"
	x.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	x.offset_left = -104.0
	x.offset_right = -58.0
	x.offset_top = 24.0
	x.offset_bottom = 70.0
	x.pressed.connect(close)
	add_child(x)
	_close_button = x





	_focus_ring = links + [x]
	_refresh_focus_ring()

	(_focus_ring[0] as Control).grab_focus.call_deferred()

func _refresh_focus_ring() -> void :
	for i in _focus_ring.size():
		var b: = _focus_ring[i] as Control
		var prev: = b.get_path_to(_focus_ring[(i - 1 + _focus_ring.size()) % _focus_ring.size()])
		var next: = b.get_path_to(_focus_ring[(i + 1) % _focus_ring.size()])
		b.focus_neighbor_left = prev
		b.focus_previous = prev
		b.focus_neighbor_right = next
		b.focus_next = next
		b.focus_neighbor_top = NodePath(".")
		b.focus_neighbor_bottom = NodePath(".")




func _style_bar(bar: ScrollBar) -> void :
	var rail: = StyleBoxFlat.new()
	rail.bg_color = Color(0.0, 0.0, 0.0, 0.42)
	rail.set_corner_radius_all(int(BAR_W * 0.5))
	bar.add_theme_stylebox_override("scroll", rail)
	bar.add_theme_stylebox_override("scroll_focus", rail)
	for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
		var grab: = StyleBoxFlat.new()
		grab.bg_color = Color.WHITE if state == "grabber" else UiStyle.PRIMARY
		grab.set_corner_radius_all(int(BAR_W * 0.5))
		grab.set_border_width_all(3)
		grab.border_color = LINE
		bar.add_theme_stylebox_override(state, grab)
	bar.custom_minimum_size.x = BAR_W



func _portrait(path: String) -> Control:
	var holder: = Control.new()
	holder.custom_minimum_size = Vector2(PORTRAIT, PORTRAIT)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shadow: = Panel.new()
	shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 1)
	sb.set_corner_radius_all(int(PORTRAIT * PORTRAIT_ROUND))
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, 8)
	shadow.add_theme_stylebox_override("panel", sb)
	holder.add_child(shadow)
	var pic: = TextureRect.new()
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pic.texture = CreditsData.picture(path)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: = ShaderMaterial.new()
	mat.shader = load(ICON_SHADER)
	mat.set_shader_parameter("size", Vector2(PORTRAIT, PORTRAIT))
	mat.set_shader_parameter("radius", PORTRAIT_ROUND)
	pic.material = mat
	holder.add_child(pic)

	holder.offset_transform_enabled = true
	holder.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	_faces.append([holder, 1.0, 0.0])
	return holder






func _stage_you(holder: Control, cfg: CharacterConfig, rng: RandomNumberGenerator, 
		is_p1: bool) -> void :
	var vp: = SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_2X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.size = Vector2i(720, 830)
	holder.add_child(vp)
	_you_vps.append(vp)
	if is_p1:
		_you_vp = vp

	var cam: = Camera3D.new()
	cam.fov = 30.0
	cam.position = Vector3(0.0, 1.15, 5.2)
	vp.add_child(cam)
	cam.look_at(Vector3(0.0, 1.15, 0.0))
	Ink.apply(cam)
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.4
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	vp.add_child(env)
	var sun: = DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-45.0), deg_to_rad(35.0), 0.0)
	sun.light_energy = 0.5
	vp.add_child(sun)

	var pc: PresentationCharacter = load("res://game/character/presentation_character.gd").new()
	vp.add_child(pc)
	var dressed: = outfit_of(cfg, _outfit, rng.randf() < 0.5)
	pc.setup(dressed[0], dressed[1])
	var side: = 1.0 if rng.randf() < 0.5 else -1.0
	pc.face(side * rng.randf_range(0.15, 0.55))
	var pose: = _random_pose(rng)
	if is_p1:
		_pose = pose
	_strike(pc, String(pose[0]), float(pose[1]))


	for shade in [true, false]:
		var tr: = TextureRect.new()
		tr.texture = vp.get_texture()
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if shade:
			tr.modulate = Color(0, 0, 0, 0.35)
			tr.position += Vector2(5, 7)
		holder.add_child(tr)



func _pick_outfit() -> void :
	_outfit = OUTFITS[randi_range(0, OUTFITS.size() - 1)]
	var asked: = outfit_pick
	var args: = LaunchGate.dev_args()
	if asked == "" and args.has("--credits-outfit") and args.find("--credits-outfit") + 1 < args.size():
		asked = String(args[args.find("--credits-outfit") + 1])
	if asked in ["home", "away"]:
		asked = "captain"
	if OUTFITS.has(asked):
		_outfit = asked


func _couch_looks() -> Array:
	var out: Array = [_profile_look()]
	for slot in LocalPlayers.slots:
		if slot.index == 0:
			continue
		var look: = CharacterConfig.new()
		if slot.profile != null and slot.profile.character is Dictionary\
		and not (slot.profile.character as Dictionary).is_empty():
			look = CharacterConfig.from_dict(slot.profile.character)
		out.append(look)
	return out






static func outfit_of(cfg: CharacterConfig, which: String, _home_bib: = true) -> Array:
	var kit: = TeamKits.normalize(cfg.captain_kit)
	match which:
		"gym", "pinny":
			var look: = cfg.gym_look()
			if which == "pinny":
				look.wear_pinny = true
				look.pinny_color = kit[0]
				look.pinny_accent = TeamKits.number_ink(kit[0])
			return [look, look.gym_kit()]
	return [cfg, kit]

func _profile_look() -> CharacterConfig:
	if GameConfig.character != null:
		return GameConfig.character
	var p: SavedProfile = ProfileStore.active()
	if p != null and p.character is Dictionary and not (p.character as Dictionary).is_empty():
		return CharacterConfig.from_dict(p.character)
	return CharacterConfig.new()




func _random_pose(rng: RandomNumberGenerator) -> Array:
	var all: Array = []
	var title: GDScript = load(TITLE_SCRIPT)
	if title != null:
		var consts: = title.get_script_constant_map()
		var pools: Variant = consts.get("POOLS", {})
		if pools is Dictionary:
			for zone in pools:
				all.append_array(pools[zone])
		var key: Variant = consts.get("KEY_POSES", [])
		if key is Array:
			all.append_array(key)
	if all.is_empty():
		return ["idle_alt", 0.5]
	return all[rng.randi() % all.size()]



func _strike(pc: PresentationCharacter, hook: String, frame: float) -> void :
	if pc.rig == null:
		return
	var want: String = pc.rig.clip_name(hook)
	if want == "":
		want = hook
	if pc.play_clip(want, true) == "":
		pc.play_clip("idle", true)
	pc.rig.seek_normalized(frame)
	var ap: AnimationPlayer = pc.rig.get("_anim")
	if ap != null and ap.current_animation != "":
		ap.pause()



func close() -> void :
	if _closing:
		return
	_closing = true
	_held = null
	_pending_link = null
	if _pointing():
		_pointer.sleep()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	MusicManager.set_muffled(false)
	closed.emit()
	var t: = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.14)
	t.tween_callback(queue_free)

func _input(event: InputEvent) -> void :



	if LocalPlayers.consume_foreign_ui(event):
		get_viewport().set_input_as_handled()
		return



	var key: = event as InputEventKey
	var x_key: bool = key != null and key.pressed and not key.echo and key.keycode == KEY_X
	if event.is_action_pressed("ui_cancel") or x_key:
		get_viewport().set_input_as_handled()
		close()
		return

	var jb: = event as InputEventJoypadButton
	if jb != null and jb.pressed and not _closing:
		if jb.button_index == JOY_BUTTON_Y:
			_toggle_gravity()
			get_viewport().set_input_as_handled()
			return
		if jb.button_index == JOY_BUTTON_X:
			_reset_playground()
			get_viewport().set_input_as_handled()
			return
	if key != null and key.pressed and not key.echo and (key.keycode == KEY_G or key.physical_keycode == KEY_G):
		_toggle_gravity()
		get_viewport().set_input_as_handled()
		return

	if key != null and key.pressed and not key.echo and (key.keycode == KEY_R or key.physical_keycode == KEY_R):
		_reset_playground()
		get_viewport().set_input_as_handled()
		return
	if not _closing and _play_input(event):
		get_viewport().set_input_as_handled()
