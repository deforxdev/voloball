extends Node













const KEY_YES: = KEY_Y
const KEY_NO: = KEY_N

var _layer: CanvasLayer = null
var _title: Label = null
var _tally: Label = null
var _time: Label = null
var _yes: Button = null
var _no: Button = null
var _can_vote: = false

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	Net.votekick_opened.connect(_on_opened)
	Net.votekick_updated.connect(_on_updated)
	Net.votekick_closed.connect(_on_closed)
	Net.session_ended.connect( func(_r): _close())




func _unhandled_key_input(event: InputEvent) -> void :
	if not _can_vote or _layer == null or not is_instance_valid(_layer):
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var kc: int = (event as InputEventKey).physical_keycode
	if kc == KEY_YES:
		_cast(true)
		get_viewport().set_input_as_handled()
	elif kc == KEY_NO:
		_cast(false)
		get_viewport().set_input_as_handled()

func _on_opened(target_peer: int, tname: String, yes: int, needed: int, secs: int) -> void :
	_close()
	var tree: = get_tree()
	if tree == null or tree.root == null:
		return


	_can_vote = multiplayer.get_unique_id() != target_peer and not Net.votekick_voted()
	_layer = CanvasLayer.new()
	_layer.layer = 129


	var center: = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 40
	center.offset_bottom = 92
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pill: = PanelContainer.new()


	var cb: = UiStyle.card_box(Color(UiStyle.card(), 0.98), 99)
	cb.content_margin_left = 13.0
	cb.content_margin_right = 13.0
	cb.content_margin_top = 5.0
	cb.content_margin_bottom = 5.0
	cb.shadow_size = 6
	cb.shadow_offset = Vector2(0, 2)
	pill.add_theme_stylebox_override("panel", cb)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	pill.add_child(row)

	_title = _lbl("kick %s?" % tname, UiStyle.text(), 12)
	row.add_child(_title)
	_tally = _lbl("", UiStyle.muted(), 11)
	row.add_child(_tally)
	_time = _lbl("", UiStyle.muted(), 11)
	row.add_child(_time)

	if _can_vote:
		_yes = _mk_btn("[y] yes", "primary", func(): _cast(true))
		row.add_child(_yes)
		_no = _mk_btn("[n] no", "tertiary", func(): _cast(false))
		row.add_child(_no)
	else:

		row.add_child(_lbl("voted" if Net.votekick_voted() else "watching", 
			UiStyle.muted(), 11))

	center.add_child(pill)
	_layer.add_child(center)
	tree.root.add_child(_layer)
	UiStyle.vote_pill_open = true
	_update(yes, needed, secs)
	UiStyle.sfx("open")

func _lbl(text: String, color: Color, size: int) -> Label:
	var l: = Label.new()
	l.text = text
	UiStyle.style_label(l, "small", color)
	l.add_theme_font_size_override("font_size", size)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l

func _mk_btn(text: String, kind: String, cb: Callable) -> Button:
	var b: = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(58, 26)
	UiStyle.style_button(b, kind, 12)
	b.pressed.connect(cb)
	return b

func _cast(yes: bool) -> void :
	if not _can_vote:
		return
	_can_vote = false
	Net.cast_my_votekick(yes)

	if is_instance_valid(_yes):
		_yes.queue_free()
		_yes = null
	if is_instance_valid(_no):
		_no.queue_free()
		_no = null

func _on_updated(yes: int, needed: int, secs: int) -> void :
	_update(yes, needed, secs)

func _update(yes: int, needed: int, secs: int) -> void :
	if is_instance_valid(_tally):
		_tally.text = "%d/%d" % [yes, needed]
	if is_instance_valid(_time):
		_time.text = "%ds" % maxi(secs, 0)

func _on_closed(passed: bool, tname: String) -> void :
	_close()

	if passed:
		UiStyle.flash_pill("%s was voted out" % tname, UiStyle.RED, "information", 4.0)
	else:
		UiStyle.flash_pill("not enough votes to kick %s" % tname, UiStyle.SECONDARY, "information", 4.0)

func _close() -> void :
	UiStyle.vote_pill_open = false
	_can_vote = false
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null
	_title = null
	_tally = null
	_time = null
	_yes = null
	_no = null
