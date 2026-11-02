class_name FreeplayPads
extends Node3D











signal stepped(id: String, body: Player)

const PAD_RADIUS: = 0.75




const PAD_REARM: = 0.6
const PAD_RIM: = 0.13
const PAD_GAP: = 2.6
const LABEL_HEIGHT: = 0.75

var _pads: = {}
var _order: Array = []
var _standing: = {}
var _last_t: = 0.0


func build(ids: Array, first: Vector3, colors: Dictionary) -> void :
	var entries: Array = []
	for i in ids.size():
		entries.append({"id": String(ids[i]), "pos": first + Vector3(0.0, 0.0, PAD_GAP * i), 
			"color": colors.get(String(ids[i]), Color.WHITE)})
	build_entries(entries)





func build_entries(entries: Array) -> void :
	for e in entries:
		var id: = String(e.id)
		var radius: = float(e.get("radius", PAD_RADIUS))
		var col: = _saturate(e.get("color", Color.WHITE))
		var rim: = _ring(radius)
		rim.name = "Pad %s" % id
		rim.position = e.pos
		add_child(rim)
		var fill: = _disc(radius - PAD_RIM, 0.02, true)
		fill.position.y = -0.005
		rim.add_child(fill)
		var beam: = _beam(radius, col)
		rim.add_child(beam)
		var label: = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font = UiStyle.font(UiStyle.FONT_XBOLD)
		label.font_size = 40
		label.pixel_size = 0.0075
		label.outline_size = 12
		label.outline_modulate = UiStyle.INK
		label.position = Vector3(0.0, LABEL_HEIGHT, 0.0)
		label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		label.font_size = 40 if radius >= PAD_RADIUS else 34
		rim.add_child(label)
		_pads[id] = {"root": rim, "rim": rim.material_override, 
			"fill": fill.material_override, "beam": beam.material_override, 
			"label": label, "on": false, "color": col, "radius": radius, "press": 0.0}
		_order.append(id)
		set_state(id, false, id)


static func _saturate(c: Color) -> Color:
	return Color.from_hsv(c.h, clampf(c.s * 1.25 + 0.2, 0.0, 1.0), 1.0)


func _ring(radius: float) -> MeshInstance3D:
	var t: = TorusMesh.new()
	t.inner_radius = radius - 0.11
	t.outer_radius = radius
	t.rings = 48
	t.ring_segments = 8
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mi: = MeshInstance3D.new()
	mi.mesh = t
	mi.scale = Vector3(1.0, 0.35, 1.0)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func _beam(radius: float, col: Color) -> MeshInstance3D:
	var c: = CylinderMesh.new()
	c.top_radius = radius - 0.04
	c.bottom_radius = radius - 0.04
	c.height = 0.9
	c.cap_top = false
	c.cap_bottom = false
	c.radial_segments = 40
	var g: = Gradient.new()
	g.set_color(0, Color(1, 1, 1, 0.0))
	g.set_color(1, Color(1, 1, 1, 1.0))
	var tex: = GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 4
	tex.height = 64
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = tex
	mat.albedo_color = Color(col, 0.35)
	var mi: = MeshInstance3D.new()
	mi.mesh = c
	mi.position.y = 0.45
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

func _disc(radius: float, height: float, see_through: bool) -> MeshInstance3D:
	var disc: = CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = height
	disc.radial_segments = 48
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if see_through:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mi: = MeshInstance3D.new()
	mi.mesh = disc
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func set_state(id: String, on: bool, text: String) -> void :
	var pad: Dictionary = _pads.get(id, {})
	if pad.is_empty():
		return
	var label: Label3D = pad.label
	if bool(pad.on) == on and label.text == text and bool(pad.get("drawn", false)):
		return
	pad.drawn = true
	pad.on = on
	if label.text != text:
		label.text = text
	var col: Color = pad.color
	(pad.rim as StandardMaterial3D).albedo_color = col if on else col.darkened(0.3)
	label.modulate = col.lightened(0.25) if on else Color(0.96, 0.97, 1.0)

func move_pad(id: String, pos: Vector3) -> void :
	var pad: Dictionary = _pads.get(id, {})
	if not pad.is_empty():
		(pad.root as Node3D).position = pos

func set_pad_visible(id: String, on: bool) -> void :
	var pad: Dictionary = _pads.get(id, {})
	if not pad.is_empty():
		(pad.root as Node3D).visible = on

func is_on(id: String) -> bool:
	return bool((_pads.get(id, {}) as Dictionary).get("on", false))



func tick(bodies: Array) -> void :
	var t: = float(Time.get_ticks_msec()) / 1000.0
	var dt: = clampf(t - _last_t, 0.0, 0.1)
	_last_t = t
	var occupied: = {}
	for b in _standing:
		if String(_standing[b]) != "":
			occupied[String(_standing[b])] = true
	for id in _order:
		var pad: Dictionary = _pads[id]
		var fill: StandardMaterial3D = pad.fill
		var col: Color = pad.color

		var target: = 1.0 if occupied.has(id) else 0.0
		pad.press = lerpf(float(pad.press), target, 1.0 - exp(-10.0 * dt))
		var k: float = pad.press
		var breathe: = 0.5 + 0.5 * sin(t * 2.6 + float(id.hash() % 7))
		var a: = (0.72 if pad.on else 0.32 + 0.12 * breathe) + 0.25 * k
		fill.albedo_color = Color(col if pad.on else col.lightened(0.25), clampf(a, 0.0, 1.0))
		var beam: StandardMaterial3D = pad.beam
		beam.albedo_color = Color(col, (0.5 if pad.on else 0.22 + 0.08 * breathe) + 0.45 * k)
		(pad.root as Node3D).scale = Vector3.ONE * (1.0 + 0.14 * k)
	var seen: = {}
	for b in bodies:
		var body: Player = b
		if body == null or not is_instance_valid(body):
			continue
		seen[body] = true
		if not body.is_on_floor():
			continue
		var at: = Vector2(body.global_position.x, body.global_position.z)
		var on: = ""
		if body.is_on_floor():
			for id in _order:
				var root: Node3D = _pads[id].root
				if not root.visible:
					continue
				var p: = root.global_position
				if at.distance_to(Vector2(p.x, p.z)) <= float(_pads[id].radius):
					on = id
		var last: = String(_standing.get(body, ""))
		if on != "" and on != last:
			stepped.emit(on, body)
			_standing[body] = on
		elif on == "" and last != "":

			var lp: Vector3 = (_pads[last].root as Node3D).global_position
			if at.distance_to(Vector2(lp.x, lp.z)) > float(_pads[last].radius) + PAD_REARM:
				_standing[body] = ""
	for body in _standing.keys():
		if not seen.has(body):
			_standing.erase(body)


func reset() -> void :
	_standing.clear()
