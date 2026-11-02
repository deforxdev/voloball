extends Control












const CLIPS: = ["intro_cool_loop", "sass", "idle_alt", "run", "receive", "set"]
const SWAP_EVERY: = 5.5
const SPACING: = 1.2
const POLL: = 0.25

var entries: Array = []
var players: Array = []

var _vp: SubViewport
var _cam: Camera3D
var _cast: Array = []
var _poll: = 0.0
var _clock: = 0.0

func _ready() -> void :
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true



	var bd: = _Backdrop.new()
	bd.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bd)
	var box: = SubViewportContainer.new()
	box.stretch = true
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(box)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.transparent_bg = true
	_vp.msaa_3d = Viewport.MSAA_2X
	_vp.handle_input_locally = true
	_vp.gui_disable_input = true
	box.add_child(_vp)
	_cam = Camera3D.new()
	_cam.keep_aspect = Camera3D.KEEP_HEIGHT
	_cam.fov = 30.0
	_vp.add_child(_cam)
	Ink.apply(_cam)
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.4
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	_vp.add_child(env)
	var sun: = DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-45.0), deg_to_rad(35.0), 0.0)
	sun.light_energy = 0.5
	_vp.add_child(sun)
	for i in players.size():
		var tag: = Label.new()
		tag.text = String(players[i].get("tag", ""))
		UiStyle.style_label(tag, "title", players[i].get("color", Color.WHITE))
		tag.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		tag.add_theme_font_size_override("font_size", 30)
		tag.add_theme_color_override("font_outline_color", UiStyle.INK)
		tag.add_theme_constant_override("outline_size", 12)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag.size = Vector2(120, 44)
		add_child(tag)
		_cast.append({"pc": null, "sig": "", "phase": float(i) * 2.1, "clip": i % CLIPS.size(), 
			"t": float(i) * 1.7, "tag": tag})
	_frame()


func _frame() -> void :
	var n: = maxi(players.size(), 1)
	var span: = float(n - 1) * SPACING + 1.2
	var aspect: = size.x / maxf(size.y, 1.0) if size.y > 0.0 else 16.0 / 9.0
	var half_v: = tan(deg_to_rad(_cam.fov) * 0.5)
	var dist: = maxf(1.45 / half_v, (span * 0.5) / (half_v * maxf(aspect, 0.3)))
	_cam.position = Vector3(0.0, 1.05, dist)
	_cam.look_at(Vector3(0.0, 1.0, 0.0))

func _process(delta: float) -> void :
	_clock += delta
	_poll -= delta
	if _poll <= 0.0:
		_poll = POLL
		_frame()
		_redress()
	var n: = _cast.size()
	for i in n:
		var c: Dictionary = _cast[i]
		var pc: PresentationCharacter = c.pc
		if pc == null:
			continue
		var ph: float = c.phase

		pc.position = Vector3((float(i) - float(n - 1) * 0.5) * SPACING, 
			0.12 + 0.09 * sin(_clock * 1.4 + ph), 0.0)
		pc.face(0.45 * sin(_clock * 0.55 + ph))
		c["t"] = float(c.t) + delta
		if float(c.t) >= SWAP_EVERY:
			c["t"] = 0.0
			c["clip"] = (int(c.clip) + n) % CLIPS.size()
			_play(pc, int(c.clip))

		var tag: Label = c.tag
		var at: = _cam.unproject_position(pc.global_position + Vector3(0, -0.05, 0))
		tag.position = at - Vector2(tag.size.x * 0.5, 0.0)
		tag.visible = not _cam.is_position_behind(pc.global_position)



func _redress() -> void :
	for i in _cast.size():
		if i >= entries.size():
			break
		var locker = entries[i].get("locker")
		if locker == null or not is_instance_valid(locker) or locker.cfg == null:
			continue
		var cfg: CharacterConfig = locker.cfg
		var gym: bool = locker.preview_is_gym()
		var sig: = "%d|%s" % [int(gym), str(cfg.to_dict().hash())]
		var c: Dictionary = _cast[i]
		if sig == String(c.sig):
			continue
		c["sig"] = sig
		var look: CharacterConfig = cfg.gym_look() if gym else cfg.clone()
		var kit: Array = cfg.gym_kit() if gym else TeamKits.normalize(cfg.captain_kit)
		var pc: PresentationCharacter = c.pc
		if pc == null:
			pc = PresentationCharacter.new()
			_vp.add_child(pc)
			pc.setup(look, kit)
			c["pc"] = pc
			_play(pc, int(c.clip))
		else:
			pc.player.set_character(look, kit)

func _play(pc: PresentationCharacter, k: int) -> void :
	var hook: String = CLIPS[k % CLIPS.size()]
	var want: = pc.rig.clip_name(hook) if pc.rig != null else ""
	if pc.play_clip(want if want != "" else hook, true) == "":
		pc.play_clip("", true)



class _Backdrop extends Control:
	const BG: = LockerStudio.DEFAULT_BG
	var _t: = 0.0

	func _init() -> void :
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void :
		_t += delta
		queue_redraw()

	func _draw() -> void :
		draw_rect(Rect2(Vector2.ZERO, size), BG)
		var tint: = BG.darkened(0.09)
		for b in StudioCanvas._BALLS:
			var c: = Vector2(float(b[0]) * size.x, float(b[1]) * size.y)
			var r: = float(b[2]) * size.y
			draw_set_transform(c, float(b[3]) + _t * 0.05, Vector2.ONE)
			draw_texture_rect(StudioCanvas.BALL_LINES, Rect2( - r, - r, r * 2.0, r * 2.0), false, tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
