extends Control

# Phone startup deliberately avoids the desktop title parade, first-run locker
# and eager portrait/court preparation. Existing profiles and settings are kept.
const MENU := "res://game/ui/menu.tscn"
const LOAD_TIMEOUT_MS := 60000
var _started := 0
var _opening := false
var _status: Label
var _progress: ProgressBar
var _retry: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Engine.time_scale = 1.0
	MobileControls.release_all()
	GameConfig.onboarding_active = false
	_build()
	start_loading()

func _build() -> void:
	var background := ColorRect.new()
	background.color = Color(0.04, 0.08, 0.13)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 560
	column.add_theme_constant_override("separation", 24)
	center.add_child(column)
	var title := Label.new()
	title.text = "VOLOBALL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	column.add_child(title)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 22)
	column.add_child(_status)
	_progress = ProgressBar.new()
	_progress.custom_minimum_size.y = 16
	_progress.show_percentage = false
	column.add_child(_progress)
	_retry = Button.new()
	_retry.text = "Спробувати знову"
	_retry.custom_minimum_size.y = 64
	_retry.pressed.connect(start_loading)
	column.add_child(_retry)

func start_loading() -> void:
	_started = Time.get_ticks_msec()
	_opening = false
	_retry.hide()
	_status.text = "Завантаження меню…"
	_progress.value = 0
	set_process(true)
	print("[mobile boot] loading menu; profile is preserved")
	var state := ResourceLoader.load_threaded_get_status(MENU)
	if state == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or state == ResourceLoader.THREAD_LOAD_FAILED:
		var error := ResourceLoader.load_threaded_request(MENU, "PackedScene")
		if error != OK:
			_fail("Не вдалося почати завантаження (%d)" % error)

func _process(_delta: float) -> void:
	if _opening:
		return
	var progress: Array = []
	var state := ResourceLoader.load_threaded_get_status(MENU, progress)
	if not progress.is_empty():
		_progress.value = float(progress[0]) * 100.0
	if state == ResourceLoader.THREAD_LOAD_LOADED:
		var scene := ResourceLoader.load_threaded_get(MENU) as PackedScene
		if scene == null:
			_fail("Не вдалося відкрити меню")
			return
		_opening = true
		_status.text = "Відкриваю меню…"
		_progress.value = 100
		_open_menu.call_deferred(scene)
	elif state == ResourceLoader.THREAD_LOAD_FAILED or state == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_fail("Помилка завантаження меню")
	elif Time.get_ticks_msec() - _started > LOAD_TIMEOUT_MS:
		_fail("Завантаження триває надто довго")

func _open_menu(scene: PackedScene) -> void:
	print("[mobile boot] menu resources loaded")
	GameConfig.goto_packed(scene)

func _fail(message: String) -> void:
	set_process(false)
	_status.text = message
	_retry.show()
	push_error("[mobile boot] " + message)
