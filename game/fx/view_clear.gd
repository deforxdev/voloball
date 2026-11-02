
















const PLAYER_METRES: = 6.0
const PLAYER_SCREEN: = 1.0
const BALL_METRES: = 3.0
const BALL_SCREEN: = 0.5
const CHEST: = 1.0
const NEAR_GONE: = 1.5
const NEAR_WHOLE: = 3.5
const FLOOR_GUARD: = 0.15
const EDGE: = 0.35





const ON: = false

static var enabled: = true
static var _frame: = -1





const SHADERS: = [
	"res://game/court/env_paint.gdshader", "res://game/court/venue_flat.gdshader", 
	"res://game/court/venue_flat_alpha.gdshader", "res://game/court/space_cube.gdshader", 
	"res://game/court/orbit_sphere.gdshader", "res://game/court/crowd.gdshader", 
	"res://game/court/beach_crowd.gdshader", "res://game/court/banner.gdshader", 
	"res://game/stage/kits/tree_card.gdshader", "res://game/stage/kits/palm_card.gdshader", 
	"res://game/stage/kits/prop_recolor.gdshader", "res://game/stage/kits/led_board.gdshader", 
	"res://game/stage/kits/arena_screen.gdshader", 
]


static var _cut_code: = {}


static func strip(code: String) -> String:
	var keep: PackedStringArray = []
	for l in code.split("\n"):
		if not (l.contains("jv_view_cleared") and l.contains("discard")):
			keep.append(l)
	return "\n".join(keep)

static var _setting: = true


static func set_shaders(on: bool) -> void :
	_setting = on
	if Engine.is_editor_hint() or not ON:
		return
	for path in SHADERS:
		var sh: = load(path) as Shader
		if sh == null:
			continue
		if not _cut_code.has(sh):
			_cut_code[sh] = sh.code
		var want: String = _cut_code[sh] if on else strip(_cut_code[sh])
		if sh.code != want:
			sh.code = want

static func track(cam: Camera3D, player: Node3D, ball: Node3D, show_player: = true) -> void :
	if not ON:
		return
	var f: = Engine.get_frames_drawn()
	if f == _frame:
		return
	_frame = f
	if not enabled or not _setting or cam == null:
		off()
		return
	var view: = cam.global_transform.affine_inverse()


	var half_h: = tan(deg_to_rad(cam.fov) * 0.5)
	var a: = Vector4.ZERO
	if player != null and show_player:
		a = _hole(view, player.get_global_transform_interpolated().origin + Vector3(0.0, CHEST, 0.0), 
			PLAYER_METRES, PLAYER_SCREEN * half_h)
	var b: = Vector4.ZERO
	if ball != null and ball.visible:
		b = _hole(view, ball.get_global_transform_interpolated().origin, BALL_METRES, BALL_SCREEN * half_h)
	var eye: = cam.global_position
	RenderingServer.global_shader_parameter_set("jv_clear_eye", Vector4(eye.x, eye.y, eye.z, 1.0))
	RenderingServer.global_shader_parameter_set("jv_clear_a", a)
	RenderingServer.global_shader_parameter_set("jv_clear_b", b)
	RenderingServer.global_shader_parameter_set("jv_clear_cfg", 
		Vector4(NEAR_GONE, NEAR_WHOLE, FLOOR_GUARD, EDGE))



static func _hole(view: Transform3D, world: Vector3, metres: float, screen: float) -> Vector4:
	var t: = view * world
	var depth: = - t.z
	if depth < 0.5:
		return Vector4.ZERO
	return Vector4(t.x / depth, t.y / depth, depth, maxf(metres / depth, screen))

static func off() -> void :
	RenderingServer.global_shader_parameter_set("jv_clear_eye", Vector4.ZERO)
	RenderingServer.global_shader_parameter_set("jv_clear_a", Vector4.ZERO)
	RenderingServer.global_shader_parameter_set("jv_clear_b", Vector4.ZERO)
	RenderingServer.global_shader_parameter_set("jv_clear_cfg", Vector4.ZERO)
