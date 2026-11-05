extends Node

var failures := 0
var _original_layout: Dictionary
var _original_file := PackedByteArray()
var _had_file := false
var _settings: Control

func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	if OS.get_environment("TOUCH_EDITOR_PHONE_SIZE") == "1":
		get_window().size = Vector2i(1792, 828)
		await get_tree().process_frame
		await get_tree().process_frame
		MobileControls._rebuild_layout()
	_original_layout = MobileControls._custom_layout.duplicate(true)
	_had_file = FileAccess.file_exists(MobileControls.LAYOUT_PATH)
	if _had_file:
		_original_file = FileAccess.get_file_as_bytes(MobileControls.LAYOUT_PATH)
	check(get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS,
		"phone UI renders at screen resolution instead of upscaling a 720p viewport")
	check(GameConfig.resolution_3d == 100, "new mobile render profile defaults to full 3D resolution")
	GameConfig.resolution_3d = 65
	MobileRender.apply()
	check(GameConfig.resolution_3d == 65, "explicit resolution choice survives render profile application")
	GameConfig.resolution_3d = 100
	GameConfig.apply_render_scale()
	check(is_equal_approx(get_window().scaling_3d_scale, 1.0), "3D render target uses full resolution")

	MobileControls._custom_layout.clear()
	MobileControls._rebuild_layout()
	_settings = load("res://game/ui/settings_panel.tscn").instantiate()
	add_child(_settings)
	await get_tree().process_frame
	var button := _settings.find_child("EditTouchControls", true, false) as Button
	check(button != null, "system settings expose the touch editor entry point")
	check(_settings._bind_buttons.is_empty(), "phone settings skip PC binding buttons")
	if button == null:
		finish()
		return
	button.pressed.emit()
	var editor: Control = MobileControls._editor
	check(editor != null and get_tree().paused, "edit control opens editor and pauses gameplay")
	if editor == null:
		finish()
		return
	var before := item("contact")
	var desired: Vector2 = MobileControls._safe.position + MobileControls._safe.size * Vector2(0.72, 0.45)
	if DisplayServer.get_name() == "headless":
		editor.begin_drag(7, before.center)
		editor.drag_to(7, desired)
	else:
		var touch := InputEventScreenTouch.new()
		touch.index = 7
		touch.position = get_viewport().get_final_transform() * before.center
		touch.pressed = true
		Input.parse_input_event(touch)
		await get_tree().process_frame
		var drag := InputEventScreenDrag.new()
		drag.index = 7
		drag.position = get_viewport().get_final_transform() * desired
		drag.relative = get_viewport().get_final_transform().basis_xform(desired - before.center)
		Input.parse_input_event(drag)
		await get_tree().process_frame
		touch.position = get_viewport().get_final_transform() * desired
		touch.pressed = false
		Input.parse_input_event(touch)
		await get_tree().process_frame
	# Layout edits must keep the same finger captured across multiple drag events.
	editor.layout_changed()
	editor.begin_drag(21, item("contact").center)
	editor.drag_to(21, desired + Vector2(20, 0))
	check(item("contact").center.distance_to(desired + Vector2(20, 0)) < 1.0, "first drag update moves the selected control")
	editor.drag_to(21, desired)
	check(item("contact").center.distance_to(desired) < 1.0, "continuous dragging keeps the selected finger")
	editor.layout_changed()
	check(editor._drag_pointer == -1, "orientation layout refresh cancels the active drag")
	editor._size_slider.value = 130
	editor._opacity_slider.value = 40
	if DisplayServer.get_name() != "headless":
		var slider_rect: Rect2 = editor._opacity_slider.get_global_rect()
		var slider_touch := InputEventScreenTouch.new()
		slider_touch.index = 0
		slider_touch.position = get_viewport().get_final_transform() * (slider_rect.position + slider_rect.size * Vector2(0.75, 0.5))
		slider_touch.pressed = true
		Input.parse_input_event(slider_touch)
		await get_tree().process_frame
		slider_touch.pressed = false
		Input.parse_input_event(slider_touch)
		await get_tree().process_frame
		check(editor._opacity_slider.value > 55, "native screen touch can operate the transparency slider")
		editor._opacity_slider.value = 40
	var changed := item("contact")
	check(changed.center.distance_to(desired) < 1.0, "drag updates the real control position")
	check(is_equal_approx(changed.radius, 42.0 * MobileControls._scale * 1.3), "resizing updates the touch hit target")
	check(is_equal_approx(changed.opacity, 0.6), "transparency updates the gameplay control")
	check(MobileControls._strengths.is_empty(), "editing never presses gameplay actions")
	if OS.get_environment("TOUCH_EDITOR_CAPTURE") == "1":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://touch-editor-preview.png")
	editor._save()
	check(MobileControls._editor == null and not get_tree().paused, "save closes editor and restores pause state")
	MobileControls._playing = true
	MobileControls._has_player = true
	var hit_touch := InputEventScreenTouch.new()
	hit_touch.index = 12
	hit_touch.position = get_viewport().get_final_transform() * item("contact").center
	hit_touch.pressed = true
	Input.parse_input_event(hit_touch)
	Input.flush_buffered_events()
	check(MobileControls.action_strength("contact") == 1.0, "physical screen touches hit custom buttons at native resolution")
	hit_touch.pressed = false
	Input.parse_input_event(hit_touch)
	Input.flush_buffered_events()
	check(MobileControls.action_strength("contact") == 0.0, "physical release clears the custom button")
	var saved: Dictionary = MobileControls._custom_layout.duplicate(true)
	MobileControls._custom_layout.clear()
	MobileControls.load_layout()
	MobileControls._rebuild_layout()
	check(MobileControls._custom_layout == saved, "position, size and transparency survive disk reload")

	var old_window_size := get_window().size
	get_window().size = Vector2i(1050, 650)
	await get_tree().process_frame
	MobileControls._rebuild_layout()
	var normalized: Vector2 = (item("contact").center - MobileControls._safe.position) / MobileControls._safe.size
	check(normalized.distance_to(Vector2(0.72, 0.45)) < 0.01, "saved positions adapt to a different screen size")
	get_window().size = old_window_size
	await get_tree().process_frame
	MobileControls._rebuild_layout()

	MobileControls.open_editor()
	editor = MobileControls._editor
	editor._size_slider.value = 180
	editor._reset()
	editor._cancel()
	check(MobileControls._custom_layout == saved, "reset and cancel restore the previous layout")
	MobileControls.open_editor()
	editor = MobileControls._editor
	editor._selected = "contact"
	editor._sync()
	editor._opacity_slider.value = 25
	editor._save()
	MobileControls.load_layout()
	MobileControls._rebuild_layout()
	check(is_equal_approx(item("contact").opacity, 0.75), "save can atomically replace an existing layout")

	# A moved joystick owns its circle even when placed on the right half.
	var right: Vector2 = MobileControls._safe.position + MobileControls._safe.size * Vector2(0.6, 0.6)
	MobileControls.update_control("move", right, 1.4, 0.5)
	MobileControls._playing = true
	check(MobileControls.touch_begin(11, MobileControls._move_center), "custom joystick location accepts a touch")
	check(MobileControls._touches.get(11) == "move", "custom joystick takes priority over right-half camera swipe")
	MobileControls.release_all()
	finish()

func item(id: String) -> Dictionary:
	for entry in MobileControls.control_items():
		if entry.action == id:
			return entry
	return {}

func finish() -> void:
	if is_instance_valid(MobileControls._editor):
		MobileControls._editor._cancel()
	get_tree().paused = false
	if _had_file:
		var file := FileAccess.open(MobileControls.LAYOUT_PATH, FileAccess.WRITE)
		file.store_buffer(_original_file)
		file.close()
	elif FileAccess.file_exists(MobileControls.LAYOUT_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(MobileControls.LAYOUT_PATH))
	MobileControls._custom_layout = _original_layout
	MobileControls._rebuild_layout()
	print("TOUCH LAYOUT REGRESSION COMPLETE: failures=", failures)
	get_tree().quit(failures)
