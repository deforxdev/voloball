extends CanvasLayer















signal closed

const NOTICE_CARD: = preload("res://game/ui/boot/notice_card.gd")
const BODY: = "you are currently playing a DEMO of a beta version of voloball, to ensure a smoother release, please report issues using the form in the main menu, additionally, please make sure to report any players who attempt to ruin your experience online."

static var shown_this_session: = false

var _dont_show: CheckBox = null
var _cont: Button = null
var _done: = false


static func wanted() -> bool:
	return LaunchGate.is_demo() and not GameConfig.notice_dismissed("demo")

func _ready() -> void :
	layer = 125
	NOTICE_CARD.apply_theme()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var root: = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	var parts: = NOTICE_CARD.build(root, "demo", "information", UiStyle.RED, 560.0)
	var field: Control = parts["field"]
	var body: VBoxContainer = parts["body"]
	var foot: HBoxContainer = parts["foot"]
	body.add_child(NOTICE_CARD.words(BODY, 18))
	_dont_show = NOTICE_CARD.dont_show()
	foot.add_child(_dont_show)
	foot.add_child(NOTICE_CARD.spacer())
	var cont: = NOTICE_CARD.continue_btn()
	_cont = cont
	cont.pressed.connect(_on_continue)
	foot.add_child(cont)

	_dont_show.focus_neighbor_right = _dont_show.get_path_to(cont)
	cont.focus_neighbor_left = cont.get_path_to(_dont_show)
	_dont_show.focus_neighbor_left = _dont_show.get_path_to(_dont_show)
	cont.focus_neighbor_right = cont.get_path_to(cont)
	NOTICE_CARD.maybe_shot(root)

	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
	cont.grab_focus()
	UiStyle.sfx("open")
	UiStyle.pop_in(field)

func _on_continue() -> void :
	if _done:
		return
	_done = true
	if _dont_show != null and _dont_show.button_pressed:
		GameConfig.dismiss_notice("demo")
	UiStyle.sfx("close")
	closed.emit()
	queue_free()

func _unhandled_input(event: InputEvent) -> void :
	if NOTICE_CARD.is_continue_event(event):
		get_viewport().set_input_as_handled()
		_on_continue()
	elif NOTICE_CARD.refocus(event, _cont):
		get_viewport().set_input_as_handled()
