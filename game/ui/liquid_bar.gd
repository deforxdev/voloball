class_name LiquidBar
extends Control






const SHADER: = preload("res://game/ui/liquid_bar.gdshader")

var fill: = 0.0:
	set(v):
		var nv: = clampf(v, 0.0, 1.0)
		if nv > fill + 0.0005:

			_slosh = clampf(_slosh + (nv - fill) * 6.0 + 0.15, 0.0, 1.0)
		fill = nv
		_push()

var _mat: ShaderMaterial
var _slosh: = 0.0
var _flash: = 0.0



func _init(track: = Color(0, 0, 0, 0.32), height: = 22.0) -> void :
	custom_minimum_size = Vector2(0, height)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.set_shader_parameter("track", track)
	material = _mat
	resized.connect(_push)

func set_track(c: Color) -> void :
	_mat.set_shader_parameter("track", c)

func flash() -> void :
	_flash = 1.0
	_slosh = 1.0

func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)

func _process(delta: float) -> void :
	if _slosh > 0.0 or _flash > 0.0:
		_slosh = maxf(0.0, _slosh - delta * 1.1)
		_flash = maxf(0.0, _flash - delta * 2.4)
		_push()

func _push() -> void :
	if _mat == null:
		return
	_mat.set_shader_parameter("fill", fill)
	_mat.set_shader_parameter("rect_px", size)
	_mat.set_shader_parameter("slosh", _slosh)
	_mat.set_shader_parameter("flash", _flash)
	queue_redraw()
