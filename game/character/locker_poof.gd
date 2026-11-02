class_name LockerPoof
extends Node3D








const PUFF_SHADER: = preload("res://game/fx/puff.gdshader")
const COUNT: = 9
const LIFE: = 0.55

static func burst(world: Node, centre: Vector3, radius: float) -> void :
	if world == null or not world.is_inside_tree():
		return
	var poof: = LockerPoof.new()
	world.add_child(poof)
	poof._go(centre, radius)

func _go(centre: Vector3, radius: float) -> void :
	var base: = randf() * TAU


	var cam: = get_viewport().get_camera_3d()
	if cam != null:
		var toward: = cam.global_position - centre
		toward.y = 0.0
		if toward.length() > 0.01:
			centre += toward.normalized() * radius * 0.5
	var tween: = create_tween()
	tween.set_parallel(true)
	for i in COUNT:
		var p: = MeshInstance3D.new()
		var quad: = QuadMesh.new()
		quad.size = Vector2.ONE
		var mat: = ShaderMaterial.new()
		mat.shader = PUFF_SHADER
		mat.set_shader_parameter("rot", randf() * TAU)
		mat.set_shader_parameter("tint", Color(0.97, 0.97, 1.0, 0.95))
		mat.set_shader_parameter("dissolve", 0.0)
		quad.material = mat
		p.mesh = quad
		p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(p)



		var a: = base + TAU * float(i) / float(COUNT) + randf_range(-0.2, 0.2)
		var out: = Vector3(cos(a), randf_range(-0.55, 0.55), sin(a) * 0.6)
		var start: = centre + out * radius * 0.55
		var end: = centre + out * radius * 1.15 + Vector3(0.0, randf_range(0.08, 0.2), 0.0)
		p.global_position = start
		var size: = radius * randf_range(0.55, 0.8)
		p.scale = Vector3.ONE * size * 0.2
		var delay: = randf_range(0.0, 0.05)
		tween.tween_property(p, "scale", Vector3.ONE * size, LIFE * 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
		tween.tween_property(p, "global_position", end, LIFE)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(delay)
		tween.tween_property(mat, "shader_parameter/dissolve", 0.95, LIFE * 0.5)\
		.set_delay(delay + LIFE * 0.5)
		tween.tween_property(mat, "shader_parameter/tint", 
			Color(0.97, 0.97, 1.0, 0.0), LIFE * 0.4).set_delay(delay + LIFE * 0.6)
	tween.chain().tween_callback(queue_free)
