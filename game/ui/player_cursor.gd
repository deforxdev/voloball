class_name PlayerCursor
extends Control




























signal back_pressed
signal tab_prev
signal tab_next
signal turn(amount: float)
signal woke

const ACTIONS: PackedStringArray = ["move_left", "move_right", "move_forward", 
	"move_back", "aim_left", "aim_right", "aim_up", "aim_down", "ui_accept", 
	"ui_cancel", "menu_zone_prev", "menu_zone_next"]

const SPEED: = 1900.0

const RAMP_FROM: = 0.38
const RAMP_TIME: = 0.45
const STICK_DEAD: = 0.12
const OVER_CLICKABLE: = 0.55
const SNAP_RADIUS: = 34.0
const SNAP_RATE: = 14.0
const SNAP_MAX: = Vector2(520, 160)
const SCROLL_DEAD: = 0.3
const SNAP_AFTER_SCROLL: = 0.35
const SCROLL_RATE: = 16.0
const HAND_SIZE: = 48.0



const GHOSTS: = 7
const GHOST_KEEP_MS: = 160.0
const GHOST_SPACING: = 11.0
const GHOST_MIN_FRAC: = 0.5
const GHOST_FULL_FRAC: = 0.95
const GHOST_HEAD_ALPHA: = 0.55
const SCAN_EVERY: = 0.12

var target: Viewport = null
var source = null
var color: = Color(0.13, 0.53, 1.0)
var tag: = "P1"
var pos: = Vector2.ZERO
var active: = true


var sleeping: = false


var wake_stick_only: = false


var speed_mult: = 1.0

static func sens_mult(p: SavedProfile) -> float:

	var s: = GameConfig.stick_sensitivity if p == null or p == ProfileStore.active()\
	else p.stick_sensitivity
	return clampf(s, 1.0, 2.0)

var _held: = 0.0
var _down: = false
var _scroll_acc: = 0.0
var _scrolled_ago: = 9.0
var _scan_left: = 0.0
var _clickables: Array = []
var _press_k: = 0.0
var _snap_to: Control = null
var _popup_click: = false
var _unstick: = false
var _unstick_wait: = 0
var _trail: Array = []
var _ghost_k: = 0.0
var _last_trail: = Vector2.INF
static var _hand_cache: = {}

func setup(viewport: Viewport, input_source, player_color: Color, player_tag: String, 
		start: = Vector2(-1, -1)) -> void :
	target = viewport
	source = input_source
	color = player_color
	tag = player_tag
	pos = start if start.x >= 0.0 else viewport.get_visible_rect().size * 0.5
	queue_redraw()

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 4000
	_place()


static func _hand(path: String) -> Texture2D:
	var tex: Texture2D = _hand_cache.get(path)
	if tex == null:
		var src: Texture2D = load(path)
		if src == null:
			return null
		var img: = src.get_image()
		img.resize(int(HAND_SIZE), int(HAND_SIZE), Image.INTERPOLATE_BILINEAR)
		tex = ImageTexture.create_from_image(img)
		_hand_cache[path] = tex
	return tex

func _hand_tex() -> Texture2D:
	return _hand(GameConfig.CURSOR_GRAB if _down else GameConfig.CURSOR_POINT)


func _hot() -> Vector2:
	return GameConfig.HAND_TIP * HAND_SIZE

func _draw() -> void :
	var tex: = _hand_tex()
	if tex == null:
		return
	var hot: = _hot()
	var box: = Vector2.ONE * HAND_SIZE
	_draw_ghosts(tex, hot, box)

	var k: = 1.0 - 0.1 * _press_k
	draw_texture_rect(tex, Rect2(pos - hot * k, box * k), false, color)



func _draw_ghosts(tex: Texture2D, hot: Vector2, box: Vector2) -> void :
	if _ghost_k <= 0.02 or _trail.size() < 2:
		return
	var head: Vector2 = _trail[_trail.size() - 1].p
	var walked: = 0.0
	var next_at: = GHOST_SPACING
	var placed: = 0
	var prev: = head
	for i in range(_trail.size() - 2, -1, -1):
		var q: Vector2 = _trail[i].p
		var seg: = prev.distance_to(q)
		while walked + seg >= next_at and placed < GHOSTS:
			var at: = prev.lerp(q, (next_at - walked) / maxf(seg, 0.001))
			var fade: = 1.0 - float(placed) / float(GHOSTS)
			var col: = Color(color, GHOST_HEAD_ALPHA * fade * fade * _ghost_k)
			draw_texture_rect(tex, Rect2(at - hot, box), false, col)
			placed += 1
			next_at += GHOST_SPACING
		walked += seg
		prev = q
		if placed >= GHOSTS:
			break

func _place() -> void :
	queue_redraw()

func _track_trail(delta: float) -> void :
	var now: = float(Time.get_ticks_msec())
	var speed: = 0.0
	if _last_trail != Vector2.INF and delta > 0.0:
		speed = pos.distance_to(_last_trail) / delta
	_last_trail = pos

	var scale_k: = 1080.0 / maxf(target.get_visible_rect().size.y, 1.0) if target != null else 1.0
	var lo: = SPEED * GHOST_MIN_FRAC
	var hi: = SPEED * GHOST_FULL_FRAC
	var want: = clampf((speed * scale_k - lo) / (hi - lo), 0.0, 1.0)
	var k: = 1.0 - exp( - (22.0 if want > _ghost_k else 9.0) * delta)
	_ghost_k = lerpf(_ghost_k, want, k)
	_trail.append({"p": pos, "t": now})
	while not _trail.is_empty() and now - float(_trail[0].t) > GHOST_KEEP_MS:
		_trail.pop_front()
	if _ghost_k > 0.02:
		queue_redraw()

func _process(delta: float) -> void :
	_press_k = maxf(_press_k - delta * 6.0, 0.0)
	if not active or target == null or source == null:
		return





	if _unstick and not _down and not _popup_open():
		_unstick_wait -= 1
		if _unstick_wait <= 0:
			_unstick = false
			_push_release_only()
	elif _unstick:
		_unstick_wait = 2
	source.poll(ACTIONS)
	if sleeping:
		if _touched():
			_wake()
		return
	var view: = target.get_visible_rect().size
	_scan_left -= delta
	if _scan_left <= 0.0:
		_scan_left = SCAN_EVERY
		_rescan()
		_update_hover()

	var stick: Vector2 = source.get_vector("move_left", "move_right", "move_forward", 
		"move_back")
	var mag: = stick.length()
	var over: = _clickable_at(pos)
	var np: = pos
	if mag > STICK_DEAD:
		_snap_to = null
		_held += delta
		var ramp: = lerpf(RAMP_FROM, 1.0, clampf(_held / RAMP_TIME, 0.0, 1.0))


		var speed: = SPEED * speed_mult * (view.y / 1080.0) * ramp * mag
		if over != null:
			speed *= OVER_CLICKABLE
		np += stick.normalized() * speed * delta
	else:
		_held = 0.0








		var settle: = not _down and _scrolled_ago > SNAP_AFTER_SCROLL
		if settle and _snap_to == null and over == null:
			_snap_to = _snap_target(pos)
		if settle and _snap_to != null and is_instance_valid(_snap_to)\
		and _snap_to.is_visible_in_tree() and _unclipped(_snap_to)\
		and (over == null or over == _snap_to):
			var centre: = _snap_to.get_global_rect().get_center()
			np = np.lerp(centre, 1.0 - exp( - SNAP_RATE * delta))
		else:
			_snap_to = null
	np = np.clamp(Vector2.ZERO, view - Vector2.ONE)
	if np.distance_squared_to(pos) > 0.0001:
		var rel: = np - pos
		pos = np
		_push_motion(rel)
		_place()

	if source.just_pressed("ui_accept"):
		_push_button(true)
		_press_k = 1.0
	elif source.just_released("ui_accept") and _down:
		_push_button(false)
	if source.just_pressed("ui_cancel"):
		back_pressed.emit()
	if source.just_pressed("menu_zone_prev"):
		tab_prev.emit()
	if source.just_pressed("menu_zone_next"):
		tab_next.emit()
	var sx: float = source.strength("aim_right") - source.strength("aim_left")
	if absf(sx) > SCROLL_DEAD:
		turn.emit(sx * delta)

	var sy: float = source.strength("aim_down") - source.strength("aim_up")
	_scrolled_ago += delta
	if absf(sy) > SCROLL_DEAD:
		_scrolled_ago = 0.0
		_snap_to = null
		_scroll_acc += sy * SCROLL_RATE * delta
		while absf(_scroll_acc) >= 1.0:
			_push_wheel(_scroll_acc > 0.0)
			_scroll_acc -= signf(_scroll_acc)
		_update_hover()
	else:
		_scroll_acc = 0.0
	_track_trail(delta)
	if _press_k > 0.0:
		queue_redraw()





static func real_mouse_moved(since: Vector2i) -> bool:
	if GameConfig.free_mouse_harness:
		return false
	return DisplayServer.mouse_get_position() != since


func sleep() -> void :
	release()
	_clear_hover()
	sleeping = true
	visible = false

func _touched() -> bool:
	if source.get_vector("move_left", "move_right", "move_forward", "move_back").length()\
	> STICK_DEAD:
		return true
	if wake_stick_only:
		return false
	for a in ["ui_accept", "ui_cancel", "menu_zone_prev", "menu_zone_next"]:
		if source.just_pressed(a):
			return true
	return absf(source.strength("aim_down") - source.strength("aim_up")) > SCROLL_DEAD\
	or absf(source.strength("aim_right") - source.strength("aim_left")) > SCROLL_DEAD

func _wake() -> void :
	sleeping = false
	visible = true

	if not _manages_hover():
		var view: = target.get_visible_rect().size
		pos = target.get_mouse_position().clamp(Vector2.ZERO, view - Vector2.ONE)
	_trail.clear()
	_last_trail = Vector2.INF
	_place()
	woke.emit()



func release() -> void :
	if _down:
		_push_button(false)



func deactivate() -> void :
	release()
	_clear_hover()
	active = false
	visible = false

func is_down() -> bool:
	return _down



func _push_motion(rel: Vector2) -> void :
	var ev: = InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	ev.relative = rel
	ev.button_mask = MOUSE_BUTTON_MASK_LEFT if _down else 0
	target.push_input(ev, true)
	_update_hover()










var _hovered: Array = []

func _manages_hover() -> bool:
	return target is SubViewport

func _update_hover() -> void :
	if not _manages_hover():
		return
	var hit: = _hover_target(pos)
	var chain: Array = []
	var n: Node = hit
	while n != null and n is Control:
		chain.append(n)
		n = n.get_parent()
	for c in _hovered:
		if is_instance_valid(c) and not c in chain:
			_hover_note(c, false, c == (_hovered[0] if not _hovered.is_empty() else null))
	for c in chain:
		if not c in _hovered:
			_hover_note(c, true, c == hit)
	_hovered = chain

func _hover_note(c: Control, entered: bool, is_self: bool) -> void :
	c.notification(Control.NOTIFICATION_MOUSE_ENTER if entered else Control.NOTIFICATION_MOUSE_EXIT)
	if is_self and ClassDB.class_has_integer_constant("Control", "NOTIFICATION_MOUSE_ENTER_SELF"):
		c.notification(ClassDB.class_get_integer_constant("Control", 
			"NOTIFICATION_MOUSE_ENTER_SELF" if entered else "NOTIFICATION_MOUSE_EXIT_SELF"))
	c.emit_signal("mouse_entered" if entered else "mouse_exited")

func _clear_hover() -> void :
	for c in _hovered:
		if is_instance_valid(c):
			_hover_note(c, false, c == _hovered[0])
	_hovered = []




func _hover_target(p: Vector2) -> Control:
	var best: Array = [null]
	for c in target.get_children():
		_hover_walk(c, p, best)
	return best[0]

func _hover_walk(n: Node, p: Vector2, best: Array) -> void :
	if n == self or n is Window:
		return
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	if n is Control:
		var c: = n as Control


		var r: = c.get_global_rect()
		var inside: = r.size.x > 0.0 and r.size.y > 0.0 and r.has_point(p)
		if c.clip_contents and not inside:
			return
		if inside and c.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			best[0] = c
	for k in n.get_children(true):
		_hover_walk(k, p, best)

func _push_button(down: bool) -> void :
	_down = down
	queue_redraw()
	if down:
		_popup_click = _popup_open()
	var ev: = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = down
	ev.position = pos
	ev.global_position = pos
	ev.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
	target.push_input(ev, true)





	if not down and (_popup_click or _popup_open()):
		_unstick = true
		_unstick_wait = 2
		_popup_click = false

var unsticks: = 0

func _push_release_only() -> void :
	unsticks += 1
	var ev: = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	ev.position = pos
	ev.global_position = pos
	ev.button_mask = 0
	target.push_input(ev, true)


func _popup_open() -> bool:
	return _visible_window_in(target)



func _visible_window_in(n: Node) -> bool:
	for k in n.get_children(true):
		if k is Window and (k as Window).visible:
			return true
		if _visible_window_in(k):
			return true
	return false

var wheels: = 0

func _push_wheel(down: bool) -> void :
	wheels += 1
	for pressed in [true, false]:
		var ev: = InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_WHEEL_DOWN if down else MOUSE_BUTTON_WHEEL_UP
		ev.pressed = pressed
		ev.factor = 1.0
		ev.position = pos
		ev.global_position = pos
		target.push_input(ev, true)



static func is_clickable(c: Control) -> bool:
	return c is BaseButton or c is Range or c is LineEdit or c is ItemList\
	or c is TabBar or c is TextEdit

func _rescan() -> void :
	_clickables.clear()
	var root: Node = target
	for c in root.get_children():
		_collect(c)

func _collect(n: Node) -> void :
	if n == self:
		return
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	if n is Control:
		var c: = n as Control
		if is_clickable(c) and c.mouse_filter != Control.MOUSE_FILTER_IGNORE\
		and not (c is BaseButton and (c as BaseButton).disabled):
			_clickables.append(c)
	for k in n.get_children(true):
		_collect(k)


func _clickable_at(p: Vector2) -> Control:
	var hit: Control = null


	for e in _clickables:
		if not is_instance_valid(e):
			continue
		var c: Control = e
		var r: = c.get_global_rect()
		if c.is_visible_in_tree() and r.size.x > 0.0 and r.size.y > 0.0 and r.has_point(p):
			hit = c
	return hit


func _unclipped(c: Control) -> bool:
	var mid: = c.get_global_rect().get_center()
	var n: = c.get_parent()
	while n is Control:
		var k: = n as Control
		if k.clip_contents and not k.get_global_rect().has_point(mid):
			return false
		n = n.get_parent()
	return true


func _snap_target(p: Vector2) -> Control:
	var best: Control = null
	var best_d: = SNAP_RADIUS
	for e in _clickables:
		if not is_instance_valid(e):
			continue
		var c: Control = e
		if not c.is_visible_in_tree():
			continue


		if not (c is BaseButton or c is TabBar) or not _unclipped(c):
			continue
		var r: Rect2 = (c as Control).get_global_rect()
		if r.size.x <= 0.0 or r.size.y <= 0.0 or r.size.x > SNAP_MAX.x or r.size.y > SNAP_MAX.y:
			continue

		var q: = p.clamp(r.position, r.end)
		var d: = p.distance_to(q)
		if d <= best_d:
			best_d = d
			best = c
	return best
