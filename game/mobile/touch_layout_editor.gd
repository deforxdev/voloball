extends Control

var controls: Node
var _original: Dictionary
var _was_paused := false
var _selected := "contact"
var _drag_pointer := -1
var _drag_offset := Vector2.ZERO
var _inspector: PanelContainer
var _title: Label
var _size_slider: HSlider
var _opacity_slider: HSlider
var _status: Label
var _syncing := false
var _finished := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_original = controls._custom_layout.duplicate(true)
	_was_paused = get_tree().paused
	get_tree().paused = true
	_build()
	_sync()
	queue_redraw()

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(110, 44)
	UiStyle.style_button(button, "secondary", 16)
	button.pressed.connect(callback)
	return button

func _build() -> void:
	var toolbar := HBoxContainer.new()
	toolbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	toolbar.offset_left = 20
	toolbar.offset_right = -20
	toolbar.offset_top = 8
	toolbar.add_theme_constant_override("separation", 12)
	add_child(toolbar)
	toolbar.add_child(_button("Зберегти", _save))
	toolbar.add_child(_button("Скасувати", _cancel))
	toolbar.add_child(_button("Скинути", _reset))
	toolbar.add_child(_button("Панель ↕", func(): _inspector.visible = not _inspector.visible))
	_status = Label.new()
	_status.text = "Обери кнопку й перетягни її"
	_status.add_theme_font_size_override("font_size", 17)
	toolbar.add_child(_status)
	_inspector = PanelContainer.new()
	_inspector.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_inspector.offset_left = -250
	_inspector.offset_right = 250
	_inspector.offset_top = 65
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.12, 0.95)
	style.set_content_margin_all(12)
	style.set_corner_radius_all(12)
	_inspector.add_theme_stylebox_override("panel", style)
	add_child(_inspector)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	_inspector.add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 20)
	column.add_child(_title)
	_size_slider = _slider(column, "Розмір", 50, 200)
	_opacity_slider = _slider(column, "Прозорість", 0, 100)
	_size_slider.value_changed.connect(_change_size)
	_opacity_slider.value_changed.connect(_change_opacity)

func _slider(parent: Control, text: String, low: float, high: float) -> HSlider:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = low
	slider.max_value = high
	slider.step = 1
	slider.custom_minimum_size = Vector2(300, 36)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	return slider

func selected_item() -> Dictionary:
	for item in controls.control_items():
		if item.action == _selected:
			return item
	return {}

func _sync() -> void:
	var item := selected_item()
	if item.is_empty():
		return
	_syncing = true
	_title.text = "%s · %d%% · прозорість %d%%" % [item.label, roundi(item.size * 100), roundi((1.0 - item.opacity) * 100)]
	_size_slider.value = item.size * 100
	_opacity_slider.value = (1.0 - item.opacity) * 100
	_syncing = false
	queue_redraw()

func _change_size(value: float) -> void:
	if _syncing:
		return
	var item := selected_item()
	controls.update_control(_selected, item.center, value / 100.0, item.opacity)
	_sync()

func _change_opacity(value: float) -> void:
	if _syncing:
		return
	var item := selected_item()
	controls.update_control(_selected, item.center, item.size, 1.0 - value / 100.0)
	_sync()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			begin_drag(event.index, event.position)
		elif event.index == _drag_pointer:
			_drag_pointer = -1
		accept_event()
	elif event is InputEventScreenDrag:
		drag_to(event.index, event.position)
		accept_event()
	elif event is InputEventMouseButton and event.device != -1 and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			begin_drag(-2, event.position)
		else:
			_drag_pointer = -1
		accept_event()
	elif event is InputEventMouseMotion and event.device != -1:
		drag_to(-2, event.position)
		accept_event()

func begin_drag(pointer: int, at: Vector2) -> void:
	if _drag_pointer != -1:
		return
	var items: Array = controls.control_items()
	items.reverse()
	for item in items:
		if at.distance_to(item.center) <= item.radius:
			_selected = item.action
			_drag_pointer = pointer
			_drag_offset = item.center - at
			_sync()
			return

func drag_to(pointer: int, at: Vector2) -> void:
	if pointer != _drag_pointer or _drag_pointer == -1:
		return
	var item := selected_item()
	controls.update_control(_selected, at + _drag_offset, item.size, item.opacity)
	queue_redraw()

func _reset() -> void:
	_drag_pointer = -1
	controls._custom_layout.clear()
	controls._rebuild_layout()
	_sync()

func _save() -> void:
	var result: int = controls.save_layout()
	if result != OK:
		_status.text = "Не вдалося зберегти (%d). Спробуй ще раз." % result
		return
	_finish()

func _cancel() -> void:
	controls._custom_layout = _original.duplicate(true)
	controls._rebuild_layout()
	_finish()

func _finish() -> void:
	if _finished:
		return
	_finished = true
	controls.release_all()
	get_tree().paused = _was_paused
	controls._editor = null
	queue_free()

func _exit_tree() -> void:
	if not _finished and is_instance_valid(controls):
		controls._custom_layout = _original.duplicate(true)
		controls._rebuild_layout()
		if is_inside_tree():
			get_tree().paused = _was_paused
		controls._editor = null

func layout_changed() -> void:
	_drag_pointer = -1
	queue_redraw()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_RESIZED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		layout_changed()

func _draw() -> void:
	if controls == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.08, 0.92))
	var middle: float = controls._safe.get_center().x
	draw_line(Vector2(middle, 0), Vector2(middle, size.y), Color(1, 1, 1, 0.1), 2)
	for item in controls.control_items():
		var alpha: float = maxf(item.opacity, 0.2)
		var selected: bool = item.action == _selected
		var color := Color(1.0, 0.83, 0.18) if selected else Color(0.75, 0.84, 1.0)
		draw_circle(item.center, item.radius, Color(0.12, 0.22, 0.35, alpha * 0.8))
		draw_arc(item.center, item.radius, 0, TAU, 48, Color(color, 1.0 if selected else 0.6), 3 if selected else 2, true)
		controls._text(self, item.center, item.label, roundi(14 * item.size), alpha)
