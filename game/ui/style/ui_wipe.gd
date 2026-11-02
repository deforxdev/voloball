class_name UiWipe
extends CanvasLayer












const TILT: = 0.09
const SWEEP_IN: = 0.26
const SWEEP_OUT: = 0.3
const CHASE: = 0.05

static func wipe(tree: SceneTree, mid: = Callable()) -> void :
	var w: UiWipe = UiWipe.new()
	w.layer = 100




	w.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(w)
	w._run(mid)



func _slab(color: Color, vp: Vector2) -> Panel:
	var p: = Panel.new()
	var b: = StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(64)
	p.add_theme_stylebox_override("panel", b)

	p.size = vp * Vector2(1.6, 1.8)
	p.rotation = TILT
	p.pivot_offset = p.size * 0.5
	add_child(p)
	return p

func _park(p: Panel, vp: Vector2, side: float) -> void :
	p.position = Vector2(side * vp.x * 1.8 - p.size.x * 0.5 + vp.x * 0.5, 
		- p.size.y * 0.5 + vp.y * 0.5)

func _run(mid: Callable) -> void :




	var maker: = mid.get_object_id()
	var vp: = get_viewport().get_visible_rect().size
	UiStyle.sfx("wipe_in")
	var chase: = _slab(UiStyle.INK, vp)
	var lead: = _slab(UiStyle.PRIMARY, vp)
	_park(lead, vp, -1.0)
	_park(chase, vp, -1.0)
	var t: = create_tween().set_parallel(true).set_ignore_time_scale(true)
	t.tween_property(lead, "position:x", 
		vp.x * 0.5 - lead.size.x * 0.5, SWEEP_IN)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(chase, "position:x", 
		vp.x * 0.5 - chase.size.x * 0.5, SWEEP_IN)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)\
		.set_delay(CHASE)
	await t.finished












	if mid.is_valid() and (maker == 0 or is_instance_id_valid(maker)):
		await mid.call()

	await get_tree().process_frame
	await get_tree().process_frame
	UiStyle.sfx("wipe_out")
	var out: = create_tween().set_parallel(true).set_ignore_time_scale(true)
	out.tween_property(lead, "position:x", 
		vp.x * 0.5 + vp.x * 1.8 - lead.size.x * 0.5, SWEEP_OUT)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	out.tween_property(chase, "position:x", 
		vp.x * 0.5 + vp.x * 1.8 - chase.size.x * 0.5, SWEEP_OUT)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)\
		.set_delay(CHASE)
	await out.finished
	queue_free()
