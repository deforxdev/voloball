extends RefCounted
















static func neighbor(foc: Control, dir: String, root: Node) -> Control:
	var np: = NodePath()
	var side: = SIDE_TOP
	match dir:
		"up": np = foc.focus_neighbor_top;side = SIDE_TOP
		"down": np = foc.focus_neighbor_bottom;side = SIDE_BOTTOM
		"left": np = foc.focus_neighbor_left;side = SIDE_LEFT
		"right": np = foc.focus_neighbor_right;side = SIDE_RIGHT
	var next: Control = null
	if not np.is_empty():
		next = foc.get_node_or_null(np) as Control
		if next != null and _takes(next):
			return next
	if dir == "up" or dir == "down":
		next = scroll_step(foc, dir == "down")


		if next == null and root != null and _scroll_of(foc) != null:
			next = column_step(foc, dir == "down", root)
	elif root != null:
		next = row_step(foc, dir == "right", root)
	if next != null:
		return next
	next = foc.find_valid_focus_neighbor(side)


	if next != null and root != null and not root.is_ancestor_of(next):
		if dir == "up" or dir == "down":
			return column_step(foc, dir == "down", root)
		return row_step(foc, dir == "right", root)
	return next if next != null and _takes(next) else null

static func _takes(c: Control) -> bool:
	if not c.is_visible_in_tree() or c.focus_mode == Control.FOCUS_NONE:
		return false
	return not (c is BaseButton and (c as BaseButton).disabled)

static func _scroll_of(c: Control) -> ScrollContainer:
	var p: = c.get_parent()
	while p != null:
		if p is ScrollContainer:
			return p
		p = p.get_parent()
	return null



static func scroll_step(foc: Control, down: bool) -> Control:
	var sc: = _scroll_of(foc)
	if sc == null:
		return null
	var fr: = foc.get_global_rect()
	var best: Control = null
	var best_d: = INF
	for n in sc.find_children("*", "Control", true, false):
		var c: = n as Control
		if c == foc or not _takes(c):
			continue
		var r: = c.get_global_rect()
		var dy: = (r.position.y - fr.end.y + 4.0) if down else (fr.position.y - r.end.y + 4.0)
		if dy < 0.0:
			continue

		var d: = dy * 4.0 + absf(r.position.x - fr.position.x)
		if d < best_d:
			best_d = d
			best = c
	return best



static func column_step(foc: Control, down: bool, root: Node) -> Control:
	var fr: = foc.get_global_rect()
	var best: Control = null
	var best_d: = INF
	for n in root.find_children("*", "Control", true, false):
		var c: = n as Control
		if c == foc or not _takes(c):
			continue
		var r: = c.get_global_rect()
		var dy: = (r.position.y - fr.end.y + 4.0) if down else (fr.position.y - r.end.y + 4.0)
		if dy < 0.0:
			continue
		var d: = dy * 4.0 + absf(r.get_center().x - fr.get_center().x)
		if d < best_d:
			best_d = d
			best = c
	return best



static func row_step(foc: Control, right: bool, root: Node) -> Control:
	var fr: = foc.get_global_rect()
	var mid: = fr.get_center().y
	var best: Control = null
	var best_d: = INF
	for n in root.find_children("*", "Control", true, false):
		var c: = n as Control
		if c == foc or not _takes(c):
			continue
		var r: = c.get_global_rect()
		if mid < r.position.y or mid > r.end.y:
			continue
		var dx: = (r.position.x - fr.end.x + 4.0) if right else (fr.position.x - r.end.x + 4.0)
		if dx < 0.0:
			continue
		if dx < best_d:
			best_d = dx
			best = c
	return best


static func follow(c: Control) -> void :
	var p: = c.get_parent()
	while p != null:
		if p is ScrollContainer:
			(p as ScrollContainer).ensure_control_visible(c)
			return
		p = p.get_parent()
