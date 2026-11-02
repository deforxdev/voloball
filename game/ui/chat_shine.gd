@tool
extends RichTextEffect




var bbcode: = "shine"

const PERIOD: = 2.2
const WIDTH: = 2.5
const LIFT: = 0.9

func _process_custom_fx(fx: CharFXTransform) -> bool:
	var span: = float(fx.env.get("len", 12))
	var t: = fmod(fx.elapsed_time, PERIOD) / PERIOD
	var head: = t * (span + WIDTH * 2.0) - WIDTH
	var d: = absf(float(fx.relative_index) - head)
	var k: = clampf(1.0 - d / WIDTH, 0.0, 1.0)
	fx.color = fx.color.lerp(Color(1.0, 1.0, 0.92, fx.color.a), k * k * LIFT)
	return true
