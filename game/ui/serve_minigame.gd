class_name ServeMinigame
extends CanvasLayer

signal finished(offset: Vector2)

const BALL_R: = 130.0
const TARGET_R: = 24.0
const POINT_R: = 9.0
const V_SPEED: = 430.0
const H_SPEED: = 540.0
const TOLERANCE: = 0.2

var phase: = 0
var py: = 0.0
var px: = 0.0
var vdir: = 1.0
var hdir: = 1.0
var _time_left: = 6.0
var _ball: = Vector2.ZERO
var _drawer: Control = null

func _finish() -> void :
	phase = 2
	var off: = Vector2(px / (BALL_R * 0.72), py / (BALL_R * 0.72))
	finished.emit(off)
	visible = false

func _ready() -> void :
	layer = 90
	_drawer = Control.new()
	_drawer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_drawer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drawer.draw.connect(_draw_ui)
	add_child(_drawer)

func _ball_center() -> Vector2:
	var vp: = _drawer.get_viewport_rect().size
	return Vector2(vp.x * 0.5, vp.y * 0.42)

func _process(delta: float) -> void :
	if phase >= 2:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_finish()
		return
	_ball = _ball_center()
	var lim: = BALL_R * 0.72
	if phase == 0:
		py += vdir * V_SPEED * delta
		if py > lim:
			py = lim
			vdir = - 1.0
		elif py < - lim:
			py = - lim
			vdir = 1.0
	elif phase == 1:
		px += hdir * H_SPEED * delta
		if px > lim:
			px = lim
			hdir = - 1.0
		elif px < - lim:
			px = - lim
			hdir = 1.0
	_drawer.queue_redraw()

func _input(event: InputEvent) -> void :
	if phase >= 2:
		return
	var clicked: bool = false
	var key_go: bool = false
	if event is InputEventScreenTouch and event.pressed:
		clicked = true
	elif event is InputEventMouseButton and event.pressed\
	and (not MobileControls.enabled() or event.device != -1)\
	and event.button_index == MOUSE_BUTTON_LEFT:
		clicked = true
	elif event is InputEventKey and event.pressed and not event.echo\
	and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		key_go = true
	if not clicked and not key_go:
		return
	get_viewport().set_input_as_handled()
	if phase == 0:
		phase = 1
	elif phase == 1:
		_finish()

func _draw_ui() -> void :
	if phase >= 2:
		return
	_drawer.draw_circle(_ball, BALL_R, Color(0.13, 0.13, 0.16, 0.92))
	_drawer.draw_arc(_ball, BALL_R, 0, TAU, 64, Color(0.95, 0.8, 0.15), 5.0)
	_drawer.draw_circle(_ball, BALL_R * 0.62, Color(0.16, 0.25, 0.85, 0.85))
	_drawer.draw_arc(_ball, TARGET_R, 0, TAU, 40, Color(0.95, 0.8, 0.15, 0.9), 3.0)
	_drawer.draw_circle(_ball, 4.0, Color(0.95, 0.8, 0.15, 0.9))
	var pt: = _ball + Vector2(px if phase >= 1 else 0.0, py)
	if phase == 1:
		pt = _ball + Vector2(px, py)
	elif phase == 0:
		pt = _ball + Vector2(0.0, py)
	_drawer.draw_circle(pt, POINT_R, Color(1.0, 0.3, 0.25))
	_drawer.draw_circle(pt, POINT_R * 0.5, Color(1.0, 1.0, 1.0))

func offset_now() -> Vector2:
	return Vector2(px / (BALL_R * 0.72), py / (BALL_R * 0.72))
