extends Node











signal woke

var tint: = Color.WHITE
var cursor: PlayerCursor = null
var _mouse_at: = Vector2i.ZERO
var _src: DeviceInput = null

func _ready() -> void :
	var src: = DeviceInput.new(DeviceInput.MERGED)
	_src = src
	src.exclude_kbm = true
	src.exclude_pads = LocalPlayers.p1_exclude_pads()
	var ov: = CanvasLayer.new()
	ov.name = "PadPointer"
	ov.layer = 120
	add_child(ov)
	cursor = PlayerCursor.new()
	ov.add_child(cursor)
	cursor.setup(get_viewport(), src, tint, "")
	cursor.speed_mult = PlayerCursor.sens_mult(null)
	cursor.sleep()
	cursor.woke.connect( func():
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_mouse_at = DisplayServer.mouse_get_position()
		woke.emit())

func awake() -> bool:
	return cursor != null and not cursor.sleeping

func _process(_delta: float) -> void :




	_src.exclude_pads = LocalPlayers.p1_exclude_pads()
	if awake() and PlayerCursor.real_mouse_moved(_mouse_at):
		mouse_took_over()



func mouse_took_over() -> void :
	if cursor != null:
		cursor.sleep()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _exit_tree() -> void :
	if awake():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
