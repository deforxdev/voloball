class_name LandingCall
extends RefCounted













const PILL_SHADER: = preload("res://game/fx/landing_pill.gdshader")
const DISC_SHADER: = preload("res://game/fx/landing_disc.gdshader")
const PILL_W: = 1.5
const PILL_H: = 0.66
const TEXT_COL: = Color(0.13, 0.14, 0.18)


const CALL_RED: = Color(0.93, 0.08, 0.1)

const CALL_GREEN: = Color(0.1, 0.95, 0.25)


static func call_color(text: String) -> Color:
	return CALL_GREEN if text == "ball in" else CALL_RED
const MARK_HALF: = 1.4

const LINE_NEAR: = 0.9
const LABEL_Y: = 1.2
const PILL_INWARD: = 0.9





static func read(pos: Vector3, half_w: float, half_l: float, center_x: = 0.0) -> Dictionary:
	var m: = Rules.line_margins(pos, half_w, half_l, center_x)
	var dx: = pos.x - center_x
	return {"margin": minf(m.x, m.y), "m": m, 
		"out_x": 1.0 if dx >= 0.0 else -1.0, "out_z": 1.0 if pos.z >= 0.0 else -1.0}



static func short(text: String) -> String:
	return text.trim_prefix("ball ").strip_edges()



const PILL_END_PAD: = 0.78
const PILL_MIN_W: = 1.05







static func apply(marker: Node3D, label: Label3D, text: String, accent: = CALL_RED, 
		half_w: = 0.0, half_l: = 0.0, center_x: = 0.0) -> void :
	if marker == null:
		return
	var short_text: = short(text)
	var inward: = Vector2.ZERO
	var disc: = marker.get_node_or_null("Disc") as MeshInstance3D
	if disc != null and disc.material_override is ShaderMaterial:
		var dm: = disc.material_override as ShaderMaterial
		dm.set_shader_parameter("col", accent)
		var show_x: = 0.0
		var show_z: = 0.0
		var line_x: = 0.0
		var line_z: = 0.0
		var tape: = Vector2(Rules.LINE_HALF_WIDTH, Rules.LINE_HALF_WIDTH)
		var out_dir: = Vector2.ONE
		var footprint: = half_w > 0.0
		if footprint:
			var p: = marker.global_position
			var r: = read(p, half_w, half_l, center_x)
			var m: Vector2 = r.m
			tape = Rules.tape_half(half_w, half_l)
			line_x = center_x + float(r.out_x) * half_w - p.x
			line_z = float(r.out_z) * half_l - p.z
			show_x = 1.0 if m.x > - LINE_NEAR and m.x < LINE_NEAR else 0.0
			show_z = 1.0 if m.y > - LINE_NEAR and m.y < LINE_NEAR else 0.0
			inward = Vector2( - float(r.out_x) * show_x, - float(r.out_z) * show_z)
			out_dir = Vector2(float(r.out_x), float(r.out_z))
		dm.set_shader_parameter("out_dir", out_dir)
		dm.set_shader_parameter("ring_r", Ball.PHYS.radius if footprint else 0.0)
		dm.set_shader_parameter("line_x", line_x)
		dm.set_shader_parameter("line_z", line_z)
		dm.set_shader_parameter("tape_x", tape.x)
		dm.set_shader_parameter("tape_z", tape.y)
		dm.set_shader_parameter("show_x", show_x)
		dm.set_shader_parameter("show_z", show_z)


		if marker.has_meta("call_tw"):
			var old: Variant = marker.get_meta("call_tw")
			if old is Tween and (old as Tween).is_valid():
				(old as Tween).kill()
		dm.set_shader_parameter("pop", 0.0)
		var tw: = marker.create_tween()
		tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_method( func(v: float): dm.set_shader_parameter("pop", v), 0.0, 1.0, 0.3)
		marker.set_meta("call_tw", tw)


	if inward != Vector2.ZERO:
		inward = inward.normalized() * PILL_INWARD
	var pill_pos: = Vector3(inward.x, LABEL_Y, inward.y)
	if label != null:
		label.text = short_text
		label.position = pill_pos
	var pill_node: = marker.get_node_or_null("Pill") as Node3D
	if pill_node != null:
		pill_node.position = pill_pos


	var pill: = marker.get_node_or_null("Pill") as MeshInstance3D
	if pill != null:
		var w: = PILL_W
		if label != null and label.font != null:
			var px: = label.font.get_string_size(short_text, 
				HORIZONTAL_ALIGNMENT_CENTER, -1.0, label.font_size).x
			w = maxf(PILL_MIN_W, px * label.pixel_size + PILL_END_PAD)
		if pill.mesh is QuadMesh:
			(pill.mesh as QuadMesh).size = Vector2(w, PILL_H)
		if pill.material_override is ShaderMaterial:
			var mat: = pill.material_override as ShaderMaterial
			mat.set_shader_parameter("aspect", w / PILL_H)


			mat.set_shader_parameter("border", Color(accent.r, accent.g, accent.b, 0.85))

static func dress(marker: Node3D, label: Label3D, disc_col: = CALL_RED) -> void :
	if marker == null:
		return

	var disc: = marker.get_node_or_null("Disc") as MeshInstance3D
	if disc != null:
		var pm: = PlaneMesh.new()
		pm.size = Vector2(MARK_HALF * 2.0, MARK_HALF * 2.0)
		disc.mesh = pm
		disc.position.y = 0.0
		var dm: = ShaderMaterial.new()
		dm.shader = DISC_SHADER
		dm.set_shader_parameter("col", disc_col)
		disc.material_override = dm


	if marker.get_node_or_null("Pill") == null:
		var pill: = MeshInstance3D.new()
		pill.name = "Pill"
		var q: = QuadMesh.new()
		q.size = Vector2(PILL_W, PILL_H)
		pill.mesh = q
		var mat: = ShaderMaterial.new()
		mat.shader = PILL_SHADER
		mat.set_shader_parameter("aspect", PILL_W / PILL_H)
		mat.render_priority = 1
		pill.material_override = mat
		if label != null:
			pill.position = label.position
		marker.add_child(pill)






	if label != null:
		label.font = UiStyle.font(UiStyle.FONT_BLACK)
		label.modulate = TEXT_COL
		label.outline_modulate = TEXT_COL
		label.outline_size = 4
		label.font_size = 64
		label.no_depth_test = true
		label.render_priority = 3
		label.outline_render_priority = 2
