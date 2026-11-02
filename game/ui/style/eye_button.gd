class_name EyeButton
extends Button






var shown: = false:
	set(v):
		shown = v
		tooltip_text = "hide" if v else "show"
		queue_redraw()

func _init() -> void :
	custom_minimum_size = Vector2(38, 30)
	focus_mode = Control.FOCUS_ALL
	tooltip_text = "show"
	UiStyle.style_button(self, "tertiary", 12)

func _draw() -> void :
	var c: = size * 0.5
	var w: = minf(size.x, size.y * 1.4) * 0.36
	var h: = w * 0.62
	var col: Color = UiStyle.text() if not is_hovered() else UiStyle.SECONDARY

	var top: = PackedVector2Array()
	var bottom: = PackedVector2Array()
	for i in 17:
		var t: = float(i) / 16.0
		var x: = lerpf( - w, w, t)
		var y: = h * sin(t * PI)
		top.append(c + Vector2(x, - y))
		bottom.append(c + Vector2(x, y))
	draw_polyline(top, col, 2.2, true)
	draw_polyline(bottom, col, 2.2, true)
	draw_circle(c, h * 0.52, col)
	if not shown:


		var a: = c + Vector2( - w * 0.95, h * 1.25)
		var b: = c + Vector2(w * 0.95, - h * 1.25)
		draw_line(a, b, Color(UiStyle.card(), 1.0), 5.0, true)
		draw_line(a, b, col, 2.2, true)
