class_name LoadingCover
extends Control





















const SILHOUETTE_SHADER: = preload("res://game/ui/loading_silhouette.gdshader")
const DOT_SHADER: = preload("res://game/ui/style/halftone_dots.gdshader")

const LOOK: = {

	"page": UiStyle.PRIMARY, 
	"shade": Color("e8b923"), 
	"dots": true, 

	"dots_band": 0.28, 
	"dots_step": 0.022, 
	"dots_alpha": 0.58, 
	"mid_y": 0.455, 


	"float_balls": false, 
	"float_count": 10, 
	"float_size": 168.0, 
	"float_speed": 35.0, 
	"float_spin": 1.95, 
	"float_color": Color("e8b923bf"), 

	"art": true, 
	"clip": "sprint", 
	"anim_speed": 0.65, 
	"yaw": 0.98, 
	"tint": Color.WHITE, 



	"hair_wind": 30.0, 



	"cam_fov": 37.6, 
	"cam_y": 1.2, 
	"body_scale": 1.01, 
	"body_x": -153.0, 
	"bob": 0.5, 
	"stride_speed": 0.0, 
	"shadow_w": 277.0, 
	"shadow_h": 38.0, 
	"shadow_alpha": 0.0, 

	"ball": true, 
	"ball_color": Color.WHITE, 
	"ball_r": 49.0, 
	"ball_x": 270.0, 
	"hop": 184.0, 
	"hop_speed": 5.9, 
	"squash": 0.3, 
	"stretch": 0.12, 
	"hold": 0.1, 

	"drop_runner": true, 
	"drop_ball": true, 
	"drop_x": 8.0, 
	"drop_y": 10.0, 
	"drop_color": Color(0.79, 0.58, 0.05, 0.85), 

	"text": "loading", 
	"ellipsis": true, 
	"font_size": 46, 
	"text_color": Color.WHITE, 
	"outline_color": UiStyle.INK, 
	"outline": 14, 
	"text_y": 46.0, 

	"bar": true, 
	"bar_w": 418.0, 
	"bar_h": 16.0, 
	"bar_y": 122.0, 
	"bar_border": 0, 
	"bar_track": Color("000000"), 
	"bar_edge": Color.WHITE, 
	"bar_fill": UiStyle.SECONDARY, 
	"sweep_w": 0.41, 
	"sweep_speed": 7.8, 
}


const BODY_SIZE: = Vector2(460, 560)
const CAM_DIST: = 4.6
const FEET_BELOW: = 165.0

var indeterminate: = true
var look: Dictionary = LOOK.duplicate()

var art: bool:
	get: return bool(look.art)
	set(v): look.art = v

var _progress: = 0.0
var _shown: = 0.0
var _t: = 0.0
var _vp: SubViewport = null
var _pc = null
var _cam: Camera3D = null
var _clip_now: = ""
var _body: TextureRect = null
var _body_drop: TextureRect = null
var _shadow: Panel = null
var _ball: Panel = null
var _ball_drop: Panel = null
var _ball_shadow: Panel = null
var _label: Label = null
var _track: Panel = null
var _fill: Panel = null
var _dots: ColorRect = null
var _page: ColorRect = null
var _field: Control = null
var _floats: Array = []

func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void :
	_build()
	restyle()

func _build() -> void :
	_page = ColorRect.new()
	_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page)


	_dots = ColorRect.new()
	_dots.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: = ShaderMaterial.new()
	mat.shader = DOT_SHADER
	mat.set_shader_parameter("r_max", 0.317)
	mat.set_shader_parameter("r_gamma", 1.52)
	mat.set_shader_parameter("fade_to", 0.532)
	_dots.material = mat
	_dots.color = Color.WHITE
	add_child(_dots)
	_field = Control.new()
	_field.set_anchors_preset(Control.PRESET_FULL_RECT)
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field.draw.connect(_draw_floats)
	add_child(_field)

	_shadow = _disc()
	add_child(_shadow)

	_body_drop = _silhouette()
	add_child(_body_drop)
	_body = _silhouette()
	add_child(_body)
	_ball_shadow = _disc()
	add_child(_ball_shadow)
	_ball_drop = _disc()
	add_child(_ball_drop)
	_ball = _disc()
	add_child(_ball)

	_label = Label.new()
	_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	_track = Panel.new()
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_track.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	add_child(_track)
	_fill = Panel.new()
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	_track.add_child(_fill)


func _silhouette() -> TextureRect:
	var r: = TextureRect.new()
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm: = ShaderMaterial.new()
	sm.shader = SILHOUETTE_SHADER
	r.material = sm
	return r


func _disc() -> Panel:
	var p: = Panel.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	sb.set_corner_radius_all(999)
	sb.anti_aliasing = true
	p.add_theme_stylebox_override("panel", sb)
	return p

func _disc_color(p: Panel, c: Color) -> void :
	(p.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = c



func restyle() -> void :
	if _page == null:
		return
	var shade: Color = look.shade
	_page.color = look.page
	var mat: = _dots.material as ShaderMaterial
	mat.set_shader_parameter("page", Color(look.page, 0.0))
	mat.set_shader_parameter("dot", Color(shade, float(look.dots_alpha)))
	mat.set_shader_parameter("band", float(look.dots_band))
	_dots.visible = bool(look.dots)
	_disc_color(_shadow, Color(shade, float(look.shadow_alpha)))
	_disc_color(_ball_shadow, Color(shade, float(look.shadow_alpha)))
	_disc_color(_ball, look.ball_color)
	_disc_color(_ball_drop, look.drop_color)
	(_body.material as ShaderMaterial).set_shader_parameter("tint", look.tint)
	(_body_drop.material as ShaderMaterial).set_shader_parameter("tint", look.drop_color)
	_label.add_theme_font_size_override("font_size", int(look.font_size))
	_label.add_theme_color_override("font_color", look.text_color)
	_label.add_theme_color_override("font_outline_color", look.outline_color)
	_label.add_theme_constant_override("outline_size", int(look.outline))
	var bar_h: = float(look.bar_h)
	var border: = int(look.bar_border)
	var tb: = _track.get_theme_stylebox("panel") as StyleBoxFlat
	tb.bg_color = look.bar_track
	tb.border_color = look.bar_edge
	tb.set_border_width_all(border)
	tb.set_corner_radius_all(int(bar_h * 0.5))
	var fb: = _fill.get_theme_stylebox("panel") as StyleBoxFlat
	fb.bg_color = look.bar_fill
	fb.set_corner_radius_all(maxi(int(bar_h * 0.5) - border, 0))
	_frame_cam()
	_field.visible = bool(look.float_balls)
	if _floats.size() != int(look.float_count):
		_seed_floats()
	if _pc != null:
		_pc.face(float(look.yaw))
		_pc.live_hair(float(look.hair_wind))
		if String(look.clip) != _clip_now:
			_clip_now = String(look.clip)
			_pc.play_clip(_clip_now, true)
		_pc.set_clip_speed(float(look.anim_speed))




func _bounce(t: float) -> Array:
	var period: = PI / maxf(float(look.hop_speed), 0.01)
	var hold: = clampf(float(look.hold), 0.0, 0.6)
	var p: = fposmod(t, period) / period
	if p < hold:
		var c: = sin(PI * p / hold)
		var sq: = clampf(float(look.squash), 0.0, 0.9) * c
		return [0.0, 1.0 + sq * 0.7, 1.0 - sq]
	var u: = (p - hold) / (1.0 - hold)
	var speed: = absf(1.0 - 2.0 * u)
	var st: = float(look.stretch) * speed * speed
	return [4.0 * u * (1.0 - u), 1.0 - st * 0.5, 1.0 + st]



func _seed_floats() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.seed = 4242
	_floats = []
	var n: = int(look.float_count)
	for i in n:

		var x: = (float(i) + rng.randf_range(0.15, 0.85)) / maxf(float(n), 1.0)
		_floats.append([x, rng.randf(), rng.randf_range(0.6, 1.4), 
			rng.randf_range(-1.0, 1.0), rng.randf() * TAU, rng.randf_range(0.6, 1.3)])

func _draw_floats() -> void :
	var tex: = UiBackdrop._ball_texture()
	if tex == null:
		return
	var sz: = _field.size
	var col: Color = look.float_color
	var base: = float(look.float_size)
	for f in _floats:
		var r: = base * float(f[2]) * 0.5

		var span: = sz.y + r * 4.0
		var y: = fposmod(float(f[1]) * span - _t * float(look.float_speed) * float(f[5]), span) - r * 2.0
		var x: = float(f[0]) * sz.x + sin(_t * 0.6 + float(f[4])) * 18.0
		_field.draw_set_transform(Vector2(x, y), _t * float(look.float_spin) * float(f[3]) + float(f[4]), Vector2.ONE)
		_field.draw_texture_rect(tex, Rect2( - r, - r, r * 2.0, r * 2.0), false, col)
	_field.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)





func _seen() -> bool:
	if not is_visible_in_tree() or modulate.a <= 0.0:
		return false
	var vp: = get_viewport()
	if vp is SubViewport and (vp as SubViewport).render_target_update_mode\
	== SubViewport.UPDATE_DISABLED:
		return false
	return true

func _build_runner(cfg: CharacterConfig = null) -> void :
	if _vp != null:
		_vp.queue_free()
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.transparent_bg = true
	_vp.msaa_3d = Viewport.MSAA_4X
	_vp.size = Vector2i(BODY_SIZE)
	_vp.positional_shadow_atlas_size = 0
	add_child(_vp)
	_cam = Camera3D.new()
	_vp.add_child(_cam)
	_frame_cam()
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	env.environment = e
	_vp.add_child(env)
	_pc = load("res://game/character/presentation_character.gd").new()
	_vp.add_child(_pc)
	if cfg == null:
		cfg = _profile_config()
	_pc.setup(cfg, TeamKits.normalize(cfg.captain_kit))
	_pc.face(float(look.yaw))
	_pc.live_hair(float(look.hair_wind))
	_clip_now = String(look.clip)
	var got: String = _pc.play_clip(_clip_now, true)
	_pc.set_clip_speed(float(look.anim_speed))
	if LaunchGate.dev_args().has("--load-clips"):
		print("loading cover clip: '%s' of %s" % [got, _pc.clip_names()])
	_body.texture = _vp.get_texture()
	_body_drop.texture = _body.texture

func _frame_cam() -> void :
	if _cam == null:
		return
	var y: = float(look.cam_y)
	_cam.fov = float(look.cam_fov)
	_cam.position = Vector3(0.0, y, 4.6)
	_cam.look_at(Vector3(0.0, y - 0.05, 0.0))


func rebuild_runner(cfg: CharacterConfig) -> void :
	_build_runner(cfg)


func clip_names() -> PackedStringArray:
	return _pc.clip_names() if _pc != null else PackedStringArray()

func _profile_config() -> CharacterConfig:
	if GameConfig.character != null:
		return GameConfig.character
	var p: SavedProfile = ProfileStore.active()
	if p != null and p.character is Dictionary and not (p.character as Dictionary).is_empty():
		return CharacterConfig.from_dict(p.character)
	return CharacterConfig.new()



func set_progress(v: float) -> void :
	indeterminate = false
	_progress = clampf(v, 0.0, 1.0)

func progress() -> float:
	return _progress



func _process(delta: float) -> void :
	var seen: = _seen()
	if _vp != null:
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if seen\
		else SubViewport.UPDATE_DISABLED
	if _pc != null:
		_pc.set_process(seen)
	if not seen:
		return
	if art and _vp == null:
		_build_runner()
	_t += delta
	var sz: = size
	var mid: = Vector2(sz.x * 0.5, sz.y * float(look.mid_y))
	(_dots.material as ShaderMaterial).set_shader_parameter("t", _t)
	(_dots.material as ShaderMaterial).set_shader_parameter("size_px", sz)
	(_dots.material as ShaderMaterial).set_shader_parameter("step_px", sz.y * float(look.dots_step))
	if _field.visible:
		_field.queue_redraw()

	var sc: = float(look.body_scale)
	var body: = BODY_SIZE * sc
	var stride: = absf(sin(_t * float(look.stride_speed)))
	_body.visible = art and _vp != null
	_body.size = body



	var span: = 2.0 * CAM_DIST * tan(deg_to_rad(float(look.cam_fov)) * 0.5)
	var feet_in_box: = BODY_SIZE.y * 0.5 + (float(look.cam_y) - 0.05) * BODY_SIZE.y / span

	var feet: = Vector2(mid.x + float(look.body_x) + 60.0 * sc, mid.y + FEET_BELOW * sc)
	_body.position = Vector2(mid.x + float(look.body_x) - body.x * 0.5, 
		feet.y - feet_in_box * sc - stride * float(look.bob))
	var drop: = Vector2(float(look.drop_x), float(look.drop_y))
	_body_drop.visible = _body.visible and bool(look.drop_runner)
	_body_drop.size = body
	_body_drop.position = _body.position + drop
	var sw: = (float(look.shadow_w) - stride * 22.0) * sc
	var sh: = float(look.shadow_h) * sc
	_shadow.visible = art
	_shadow.size = Vector2(sw, sh)
	_shadow.position = feet - Vector2(sw * 0.5, sh * 0.5)




	var r: = float(look.ball_r)
	var b: = _bounce(_t)
	var h: float = b[0]
	var bx: = mid.x + float(look.ball_x)
	_ball.visible = bool(look.ball)
	_ball_shadow.visible = bool(look.ball)
	_ball.size = Vector2(r, r) * 2.0
	_ball.pivot_offset = Vector2(r, r * 2.0)
	_ball.scale = Vector2(b[1], b[2])
	_ball.position = Vector2(bx - r, feet.y - r * 2.0 - h * float(look.hop))
	_ball_drop.visible = _ball.visible and bool(look.drop_ball)
	_ball_drop.size = _ball.size
	_ball_drop.pivot_offset = _ball.pivot_offset
	_ball_drop.scale = _ball.scale
	_ball_drop.position = _ball.position + drop

	var bw: = (56.0 - h * 30.0) * r / 30.0 * float(b[1])
	_ball_shadow.size = Vector2(bw, 14.0 * r / 30.0)
	_ball_shadow.position = Vector2(bx - bw * 0.5, feet.y - 7.0 * r / 30.0)
	_ball_shadow.modulate.a = 1.0 - 0.45 * h

	_label.text = String(look.text) + (".".repeat(1 + int(_t * 2.5) % 3) if bool(look.ellipsis) else "")
	_label.size = Vector2(maxf(sz.x, 600.0), float(look.font_size) * 1.4)
	_label.position = Vector2(sz.x * 0.5 - _label.size.x * 0.5, feet.y + float(look.text_y))
	var bar_w: = float(look.bar_w)
	var bar_h: = float(look.bar_h)
	var border: = float(look.bar_border)
	_track.visible = bool(look.bar)
	_track.size = Vector2(bar_w, bar_h)
	_track.position = Vector2(sz.x * 0.5 - bar_w * 0.5, feet.y + float(look.bar_y))
	var inner: = bar_w - border * 2.0
	var fill_h: = maxf(bar_h - border * 2.0, 1.0)
	if indeterminate:
		var w: = inner * float(look.sweep_w)
		var k: = 0.5 + 0.5 * sin(_t * float(look.sweep_speed))
		_fill.position = Vector2(border + (inner - w) * k, border)
		_fill.size = Vector2(w, fill_h)
	else:
		_shown = lerpf(_shown, _progress, 1.0 - exp(-8.0 * delta))
		_fill.position = Vector2(border, border)
		_fill.size = Vector2(maxf(inner * _shown, fill_h), fill_h)
