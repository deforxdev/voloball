class_name ScoreTable
extends VBoxContainer

















var name_labels: = {}

var _split: = false
var _halves: = {}
var _heads: Array[HBoxContainer] = []
var _blocks: = {}
var _row_h: = StatRow.ROW_H
var _avatar: = StatRow.AVATAR
var _stat_w: = StatRow.STAT_W
var _glass: = false
var _rows_hash: = 0

func _init(split: = false) -> void :
	set_meta("no_wash", true)
	_split = split
	add_theme_constant_override("separation", 6)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not split:
		add_child(_make_column_header())
		for side in [1, -1]:
			_halves[side] = self
			_add_block(side, self)
		return
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for side in [1, -1]:
		var half: = VBoxContainer.new()
		half.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		half.add_theme_constant_override("separation", 5)
		half.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(half)
		half.add_child(_make_column_header())
		_halves[side] = half
		_add_block(side, half)

func _add_block(side: int, parent: Control) -> void :
	var pill: = _make_section_header(side)
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pill)
	parent.add_child(box)
	_blocks[side] = {"pill": pill, "box": box, "pool": []}

func set_metrics(row_h: float, avatar: float, stat_w: = StatRow.STAT_W) -> void :
	_row_h = row_h
	_avatar = avatar
	_stat_w = stat_w
	for head in _heads:
		for i in StatRow.COLS.size():
			(head.get_child(i + 1) as Control).custom_minimum_size.x = stat_w
	for side in _blocks:
		for r in _blocks[side].pool:
			(r as StatRow).set_metrics(row_h, avatar, stat_w)

func row_height() -> float:
	return _row_h


func row_count() -> int:
	var n: = 0
	for side in _blocks:
		for r in _blocks[side].pool:
			if (r as StatRow).visible:
				n += 1
	return n

func set_rows(rows: Array, ctx: = {}) -> void :
	var h: = hash([rows, ctx])
	if h == _rows_hash:
		return
	_rows_hash = h
	var c: = ctx.duplicate()
	if bool(c.get("mvp", false)):
		c["mvp_keys"] = Rules.team_mvps(rows).values()
	var show_net: = bool(c.get("show_net", c.get("networked", false)))
	c["show_net"] = show_net
	if bool(c.get("glass", false)) != _glass:
		_set_glass(bool(c.get("glass", false)))
	for head in _heads:
		head.get_child(head.get_child_count() - 1).visible = show_net

	var first: = 1 if int(c.get("first_side", 1)) >= 0 else -1
	if _split:
		var row: Node = _halves[first].get_parent()
		row.move_child(_halves[first], 0)
	else:
		move_child(_blocks[first].pill, 1)
		move_child(_blocks[first].box, 2)
	name_labels.clear()
	for side in [1, -1]:



		var side_rows: = rows.filter( func(r): return int((r as Dictionary).get("side", 1)) == side)
		_fill(_blocks[side], side_rows, c)
		_blocks[side].pill.visible = not side_rows.is_empty() or _split

var row_by_key: = {}

func _fill(block: Dictionary, data: Array, ctx: Dictionary) -> void :
	var pool: Array = block.pool
	var box: VBoxContainer = block.box

	while pool.size() < data.size():
		var r: = StatRow.new()
		pool.append(r)
		box.add_child(r)
		r.set_metrics(_row_h, _avatar, _stat_w)
	for i in pool.size():
		var row: StatRow = pool[i]
		if i < data.size():
			row.visible = true
			var d: Dictionary = data[i]
			row.update(d, ctx)
			name_labels[String(d.get("ready_name", d.get("name", "")))] = row.name_label
			row_by_key[row_key(d)] = row
		else:
			row.visible = false


static func row_key(d: Dictionary) -> String:
	return Rules.stat_row_key(d)

func _set_glass(on: bool) -> void :
	_glass = on
	for head in _heads:
		for c in head.get_children():
			var l: = c as Label
			l.add_theme_color_override("font_color", 
				Color(1, 1, 1, 0.9) if on else Color(UiStyle.text(), 0.66))
			l.add_theme_color_override("font_outline_color", Color.BLACK)
			l.add_theme_constant_override("outline_size", 4 if on else 0)

func _make_column_header() -> Control:

	var mc: = MarginContainer.new()
	mc.add_theme_constant_override("margin_left", 8)
	mc.add_theme_constant_override("margin_right", 10)
	mc.add_theme_constant_override("margin_top", 2)
	mc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", int(StatRow.SEP))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mc.add_child(head)
	var player: = _head_label("player")
	player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.add_child(player)
	for col in StatRow.COLS:
		var l: = _head_label(col.head)
		l.custom_minimum_size.x = StatRow.STAT_W
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		l.tooltip_text = col.tip
		l.mouse_filter = Control.MOUSE_FILTER_PASS
		head.add_child(l)
	var net: = _head_label("net")
	net.custom_minimum_size.x = StatRow.NET_W
	net.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(net)
	_heads.append(head)
	return mc

func _head_label(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", Color(UiStyle.text(), 0.66))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _make_section_header(side: int) -> Control:
	var pill: = PanelContainer.new()
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var b: = UiStyle.flat_box(Rules.side_color(side), 14)
	b.content_margin_left = 16.0
	b.content_margin_right = 16.0
	b.content_margin_top = 3.0
	b.content_margin_bottom = 4.0
	pill.add_theme_stylebox_override("panel", b)
	var l: = Label.new()
	l.text = Rules.side_name(side)
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(l)
	return pill
