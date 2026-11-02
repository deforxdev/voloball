extends Node2D



var _outline: = PackedVector2Array()
var _board_size: = Vector2.ZERO
var _tab_size: = Vector2.ZERO

func fit(board_size: Vector2, tab_size: Vector2) -> void :
	if board_size == _board_size and tab_size == _tab_size:
		return
	_board_size = board_size
	_tab_size = tab_size
	if board_size.x <= 0:
		return
	_outline.clear()
	var half_tab: = maxf(82.0, (tab_size.x - 8.0) * 195.0 / board_size.x)
	var left: = 195.0 - half_tab
	var right: = 195.0 + half_tab
	_outline.append(Vector2(112, -20))
	_outline.append(Vector2(278, -20))
	_outline.append(Vector2(291, 14))
	_curve(Vector2(294, 20), Vector2(294, 20), Vector2(302, 20))
	_outline.append(Vector2(361, 20))
	_curve(Vector2(377, 20), Vector2(389, 31), Vector2(389, 46))
	_curve(Vector2(389, 61), Vector2(377, 72), Vector2(361, 72))
	_outline.append(Vector2(right + 24, 72))
	_curve(Vector2(right + 18, 72), Vector2(right + 18, 72), Vector2(right + 15, 79))
	_outline.append(Vector2(right + 10, 88))
	_curve(Vector2(right + 7, 94), Vector2(right + 7, 94), Vector2(right, 94))
	_outline.append(Vector2(left, 94))
	_curve(Vector2(left - 7, 94), Vector2(left - 7, 94), Vector2(left - 10, 88))
	_outline.append(Vector2(left - 15, 79))
	_curve(Vector2(left - 18, 72), Vector2(left - 18, 72), Vector2(left - 24, 72))
	_outline.append(Vector2(29, 72))
	_curve(Vector2(13, 72), Vector2(1, 61), Vector2(1, 46))
	_curve(Vector2(1, 31), Vector2(13, 20), Vector2(29, 20))
	_outline.append(Vector2(88, 20))
	_curve(Vector2(96, 20), Vector2(96, 20), Vector2(99, 14))
	_outline.append(Vector2(112, -20))
	for i in _outline.size():
		_outline[i] *= Vector2(board_size.x / 390.0, (board_size.y + 6.0) / 100.0)
	queue_redraw()

func _curve(control_a: Vector2, control_b: Vector2, end: Vector2) -> void :
	var start: = _outline[-1]
	for i in range(1, 13):
		_outline.append(start.bezier_interpolate(control_a, control_b, end, i / 12.0))

func _draw() -> void :
	if _outline.size() < 3:
		return
	draw_set_transform(Vector2(0, 5))
	draw_colored_polygon(_outline, Color(0.1, 0.17, 0.3, 0.16))
	draw_set_transform(Vector2(0, 3))
	draw_colored_polygon(_outline, Color(0.1, 0.17, 0.3, 0.12))
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(_outline, Color.WHITE)
	draw_polyline(_outline, Color("b9d0e4"), 1.5, true)
