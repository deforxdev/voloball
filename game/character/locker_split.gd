class_name LockerSplit
extends CanvasLayer





















signal all_ready
signal player_dropped(index: int)
signal player_back(index: int)

const DIVIDER: = 4
const DROP_AFTER: = 8.0

const SCALE_HALF: = 1.25
const SCALE_QUARTER: = 1.0

var players: Array = []
var entries: Array = []
var _grid: GridContainer = null
var _fit_cb: = Callable()
var _done: = false
const LINEUP: = preload("res://game/character/locker_lineup.gd")
var lineup: Control = null
var start_page: = "locker"

func _ready() -> void :
	layer = 60
	var black: = ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(black)
	_grid = GridContainer.new()
	_grid.columns = 1 if players.size() <= 1 else 2
	_grid.add_theme_constant_override("h_separation", DIVIDER)
	_grid.add_theme_constant_override("v_separation", DIVIDER)
	add_child(_grid)
	_fit()
	var root: = get_viewport()
	_fit_cb = _fit
	root.size_changed.connect(_fit_cb)
	for i in players.size():
		entries.append(_make_box(i))



	if players.size() == 3:
		lineup = LINEUP.new()
		lineup.name = "Lineup"
		lineup.entries = entries
		lineup.players = players
		_grid.add_child(lineup)

	await get_tree().process_frame
	await get_tree().process_frame
	for i in players.size():
		_fill(i)

	for note in ["shop_tab", "shop_shelf"]:
		if Engine.has_meta(note):
			Engine.remove_meta(note)

func _exit_tree() -> void :
	var root: = get_viewport()
	if root != null and _fit_cb.is_valid() and root.size_changed.is_connected(_fit_cb):
		root.size_changed.disconnect(_fit_cb)


func _fit() -> void :
	var root: = get_viewport()
	if root == null or _grid == null:
		return
	var k: = root.get_screen_transform().get_scale().x
	if k <= 0.001:
		k = 1.0
	transform = Transform2D.IDENTITY.scaled(Vector2(1.0 / k, 1.0 / k))
	_grid.position = Vector2.ZERO
	_grid.size = root.get_visible_rect().size * k
	for c in get_children():
		if c is ColorRect:
			(c as ColorRect).size = _grid.size

func _make_box(i: int) -> Dictionary:
	var p: Dictionary = players[i]
	var box: = _Section.new()
	box.keys = bool(p.get("kbm", false))
	box.stretch = true
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL


	box.mouse_filter = Control.MOUSE_FILTER_STOP if bool(p.get("kbm", false))\
	else Control.MOUSE_FILTER_IGNORE
	_grid.add_child(box)
	var sub: = SubViewport.new()
	sub.gui_embed_subwindows = true
	sub.handle_input_locally = true
	box.add_child(sub)
	return {"box": box, "sub": sub, "locker": null, "cursor": null, "gone": 0.0, 
		"dropped": false, "connected": true}







class _Section extends SubViewportContainer:
	var keys: = false

	func _propagate_input_event(event: InputEvent) -> bool:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return false
		if event is InputEventKey or event is InputEventAction:
			return keys
		return true

func _ui_scale() -> float:
	return SCALE_QUARTER if players.size() >= 3 else (SCALE_HALF if players.size() == 2
		else get_viewport().get_screen_transform().get_scale().x)

func _fill(i: int) -> void :
	var p: Dictionary = players[i]
	var e: Dictionary = entries[i]
	var sub: SubViewport = e.sub

	var s: = _ui_scale()
	sub.size_2d_override = Vector2i((Vector2(sub.size) / s).round())
	sub.size_2d_override_stretch = true
	var locker: Control = (load("res://game/character/locker.tscn") as PackedScene).instantiate()
	locker.section_mode = true
	locker.profile = p.get("profile")
	locker.player_color = p.get("color", Color.WHITE)
	locker.player_tag = String(p.get("tag", ""))
	locker.ready_changed.connect( func(_on: bool): _check_ready())
	sub.add_child(locker)
	e["locker"] = locker
	if start_page == "shop":
		locker.open_shop()


	if p.get("source") != null:
		var ov: = CanvasLayer.new()
		ov.layer = 100
		sub.add_child(ov)
		var cur: = PlayerCursor.new()
		ov.add_child(cur)
		cur.setup(sub, p.get("source"), locker.player_color, locker.player_tag)
		cur.speed_mult = PlayerCursor.sens_mult(p.get("profile"))
		locker.wire_pointer(cur)
		e["cursor"] = cur



func is_all_ready() -> bool:
	var anyone: = false
	for e in entries:
		if bool(e.dropped):
			continue
		anyone = true
		var l = e.locker
		if l == null or not bool(l.is_ready):
			return false
	return anyone

func _check_ready() -> void :
	if _done or not is_all_ready():
		return
	_done = true
	all_ready.emit()



func set_connected(i: int, on: bool) -> void :
	if i < 0 or i >= entries.size():
		return
	var e: Dictionary = entries[i]
	e["connected"] = on
	e["gone"] = 0.0
	var cur: PlayerCursor = e.cursor
	if cur != null:
		if on:
			cur.active = true
			cur.visible = true
		else:
			cur.release()
	if on and bool(e.dropped):
		e["dropped"] = false
		_paint_gone(i, false)
		player_back.emit(i)
	elif not on:
		_paint_gone(i, true, false)

func _process(delta: float) -> void :
	for i in entries.size():
		var e: Dictionary = entries[i]
		if bool(e.connected) or bool(e.dropped):
			continue
		e["gone"] = float(e.gone) + delta
		if float(e.gone) >= DROP_AFTER:
			e["dropped"] = true
			var cur: PlayerCursor = e.cursor
			if cur != null:
				cur.deactivate()

			_paint_gone(i, true, true)
			player_dropped.emit(i)
			_check_ready()


func _paint_gone(i: int, on: bool, dropped: = false) -> void :
	var e: Dictionary = entries[i]
	var sub: SubViewport = e.sub
	var card: Node = sub.get_node_or_null("GoneCard")
	if not on:
		if card != null:
			card.queue_free()
		return
	if card == null:
		var holder: = CenterContainer.new()
		holder.name = "GoneCard"
		holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var shade: = ColorRect.new()
		shade.color = Color(0, 0, 0, 0.55)
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var layer_node: = CanvasLayer.new()
		layer_node.name = "GoneCard"
		layer_node.layer = 90
		layer_node.add_child(shade)
		layer_node.add_child(holder)
		var lbl: = Label.new()
		lbl.name = "Text"
		UiStyle.style_label(lbl, "title", Color.WHITE)
		lbl.add_theme_color_override("font_outline_color", UiStyle.INK)
		lbl.add_theme_constant_override("outline_size", 6)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		holder.add_child(lbl)
		sub.add_child(layer_node)
		card = layer_node
	var t: Label = card.find_child("Text", true, false)
	var tag: = String(players[i].get("tag", ""))
	t.text = ("%s left: not waiting for them" % tag) if dropped\
	else ("%s's controller is disconnected" % tag)
