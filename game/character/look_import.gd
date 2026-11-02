class_name LookImport
extends CanvasLayer








const PICTURE_TYPES: = ["png", "jpg", "jpeg", "webp", "bmp"]

signal picked(look: CharacterConfig)
signal closed

var _field: LineEdit
var _error: Label
var _files: FileDialog = null

static func open(host: Node) -> LookImport:
	var d: = LookImport.new()
	host.add_child(d)
	return d

func _ready() -> void :
	layer = 95
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.45)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			close())
	add_child(scrim)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle.card(), UiStyle.RADIUS_SOFT)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	card.add_child(v)
	var t: = Label.new()
	t.text = "import a look"
	UiStyle.style_label(t, "title")
	v.add_child(t)
	var note: = Label.new()
	note.text = "paste a code or open a player card picture"
	UiStyle.style_label(note, "body", UiStyle.muted())
	v.add_child(note)
	_field = LineEdit.new()
	_field.placeholder_text = "paste a code"
	_field.custom_minimum_size = Vector2(380, 40)
	UiStyle.style_line_edit(_field)
	_field.text_submitted.connect( func(_t: String): _try_code())
	_field.text_changed.connect( func(_t: String): _error.visible = false)
	v.add_child(_field)
	var clip: = DisplayServer.clipboard_get()
	if LookShare.has_code(clip) and clip.length() < 20000:
		_field.text = clip.strip_edges()
	_error = Label.new()
	UiStyle.style_label(_error, "small", UiStyle.RED)
	_error.visible = false
	v.add_child(_error)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var pic: = Button.new()
	pic.text = "open picture"
	UiStyle.style_button(pic, "secondary", 16)
	pic.pressed.connect(_pick_picture)
	row.add_child(pic)
	if DisplayServer.clipboard_has_image():
		var paste: = Button.new()
		paste.text = "paste picture"
		UiStyle.style_button(paste, "secondary", 16)
		paste.pressed.connect( func(): try_image(DisplayServer.clipboard_get_image()))
		row.add_child(paste)
	var no: = Button.new()
	no.text = "cancel"
	UiStyle.style_button(no, "tertiary", 16)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(close)
	row.add_child(no)
	var yes: = Button.new()
	yes.text = "import"
	UiStyle.style_button(yes, "primary", 16)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.pressed.connect(_try_code)
	row.add_child(yes)
	add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	get_window().files_dropped.connect(_on_files_dropped)
	UiStyle.sfx("open")
	(Engine.get_main_loop() as SceneTree).process_frame.connect( func():
		if is_instance_valid(card):
			UiStyle.pop_in(card), CONNECT_ONE_SHOT)

func _exit_tree() -> void :
	if get_window().files_dropped.is_connected(_on_files_dropped):
		get_window().files_dropped.disconnect(_on_files_dropped)

func close() -> void :
	if is_queued_for_deletion():
		return
	UiStyle.sfx("close")
	closed.emit()
	queue_free()


func try_text(text: String) -> bool:
	var look: = LookShare.decode(text)
	if look == null:
		_fail("that code did not work")
		return false
	_take(look)
	return true

func try_picture(path: String) -> bool:
	return _try_found(LookShare.code_in_picture(path))


func try_image(img: Image) -> bool:
	return _try_found(LookShare.code_in_image(img))

func _try_found(code: String) -> bool:
	var look: = LookShare.decode(code) if code != "" else null
	if look == null:
		_fail("no look found in that picture")
		return false
	_take(look)
	return true

func _try_code() -> void :
	try_text(_field.text)

func _take(look: CharacterConfig) -> void :
	picked.emit(look)
	if not is_queued_for_deletion():
		closed.emit()
		queue_free()

func _fail(msg: String) -> void :
	_error.text = msg
	_error.visible = true
	UiStyle.sfx("back")

func _on_files_dropped(files: PackedStringArray) -> void :
	for f in files:
		if PICTURE_TYPES.has(f.get_extension().to_lower()):
			try_picture(f)
			return

func _pick_picture() -> void :
	if _files == null:
		_files = FileDialog.new()
		_files.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		_files.access = FileDialog.ACCESS_FILESYSTEM
		_files.use_native_dialog = true
		_files.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp, *.bmp ; pictures"])
		_files.title = "open a player card"
		_files.file_selected.connect(try_picture)
		add_child(_files)
	var start: = LockerStudio.export_dir()
	if DirAccess.dir_exists_absolute(start):
		_files.current_dir = start
	_files.popup_centered(Vector2i(860, 560))
