extends CanvasLayer




















signal closed

const LEAVE_GUARD: = 0.45

var free_bodies: = Callable()
var seated_fn: = Callable()

var _panels: Array = []
var _note: Label = null
var _done: Button = null
var _left_cd: = 0.0
var _was_watch: = false
var _was_mode: = Node.PROCESS_MODE_INHERIT
var _closing: = false

func _ready() -> void :
	layer = 97
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim: = ColorRect.new()
	dim.color = Color(UiStyle.INK, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var pad: = MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 90)
	pad.add_theme_constant_override("margin_top", 54)
	pad.add_theme_constant_override("margin_bottom", 40)
	add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pad.add_child(v)
	var title: = Label.new()
	title.text = "controllers"
	UiStyle.style_label(title, "title", Color.WHITE)
	title.add_theme_color_override("font_outline_color", UiStyle.INK)
	title.add_theme_constant_override("outline_size", 8)
	v.add_child(title)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(row)
	var hooks: = {
		"seat_look": seat_look, 
		"free_devices": _free_devices, 
		"on_leave": func(): _left_cd = LEAVE_GUARD, 
	}
	for i in LocalPlayers.MAX_LOCAL:
		var p: = CfgPanel.new()
		p.index = i
		p.menu_hooks = hooks
		p.p1_locked = true
		row.add_child(p)
		_panels.append(p)
	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	v.add_child(foot)
	_note = Label.new()
	_note.name = "Note"
	UiStyle.style_label(_note, "body", Color.WHITE)
	_note.add_theme_color_override("font_outline_color", UiStyle.INK)
	_note.add_theme_constant_override("outline_size", 6)
	_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(_note)
	_done = Button.new()
	_done.name = "Done"
	_done.text = "done"
	_done.custom_minimum_size = Vector2(180, 48)
	UiStyle.style_button(_done, "primary", 20)
	_done.pressed.connect(close)
	foot.add_child(_done)


	_was_watch = LocalPlayers.watch_joins
	_was_mode = LocalPlayers.process_mode
	LocalPlayers.process_mode = Node.PROCESS_MODE_ALWAYS
	LocalPlayers.watch_joins = true
	LocalPlayers.roster_changed.connect(_refresh)
	_refresh()
	for p in _panels:
		p.set_live(true)
	if InputPrompts.using_gamepad():
		_done.grab_focus.call_deferred()

func _exit_tree() -> void :
	_restore()

func _restore() -> void :
	if LocalPlayers.roster_changed.is_connected(_refresh):
		LocalPlayers.roster_changed.disconnect(_refresh)
	LocalPlayers.watch_joins = _was_watch
	LocalPlayers.process_mode = _was_mode

func _refresh() -> void :
	for i in _panels.size():
		_panels[i].bind(LocalPlayers.slots[i] if i < LocalPlayers.count() else null)
	if _note == null:
		return


	var room: = int(free_bodies.call()) if free_bodies.is_valid() else 99
	var waiting: = 0
	for slot in LocalPlayers.slots:
		if slot.index > 0 and seated_fn.is_valid() and not bool(seated_fn.call(slot)):
			waiting += 1
	_note.text = "no cpu left to take over: new players play next match"\
	if waiting > room else ""

func _process(delta: float) -> void :
	_left_cd = maxf(_left_cd - delta, 0.0)
	for p in _panels:
		p.tick(delta)



func back() -> void :
	if _left_cd > 0.0 or _panels[0].listening():
		return
	if _panels[0].submenu_open():
		_panels[0].close_submenu()
		return
	close()


func nav_root() -> Node:
	var sub: Control = _panels[0].nav_root()
	return sub if sub != null else self


func swallows_nav() -> bool:
	return _panels[0].listening()

func _input(event: InputEvent) -> void :

	for p in _panels:
		if p.capture(event):
			get_viewport().set_input_as_handled()
			return

	if LocalPlayers.consume_foreign_ui(event):
		get_viewport().set_input_as_handled()

func close() -> void :
	if _closing:
		return
	_closing = true
	for p in _panels:
		p.set_live(false)
	_restore()
	closed.emit()
	queue_free()





static func seat_look(slot: LocalPlayerSlot, outfit: = "gym") -> Dictionary:
	if slot == null:
		return {}
	var cfg: CharacterConfig = GameConfig.character if slot.index == 0\
	else (CharacterConfig.from_dict(slot.profile.character)\
	if (slot.profile != null and not slot.profile.character.is_empty())\
	else CharacterConfig.random())
	if outfit in ["captain", "home", "away"]:
		return {"cfg": cfg, "kit": TeamKits.normalize(cfg.captain_kit)}
	return {"cfg": cfg.gym_look(), "kit": cfg.gym_kit()}

func _free_devices(slot: LocalPlayerSlot) -> Array:
	var out: Array = []
	if not LocalPlayers.kbm_taken() or slot.device == DeviceInput.KBM:
		out.append(DeviceInput.KBM)
	for pad in Input.get_connected_joypads():
		var holder: = LocalPlayers.slot_for_device(pad)
		if holder == null or holder == slot:
			out.append(pad)
	return out
