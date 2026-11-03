extends Control

var _status: Label
var _body: VBoxContainer

func _ready() -> void:
	AppData.boot_succeeded()
	GameConfig.menu_open = true
	GameConfig.menu_practice = false
	GameConfig.onboarding_active = false
	MobileRender.apply()
	GameConfig.apply_display()
	GameConfig.apply_frame_cap()
	GameConfig.apply_render_scale()
	get_tree().paused = false
	_build()
	MobileDiagnostics.record("mobile_menu_ready")

func _exit_tree() -> void:
	GameConfig.menu_open = false

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("101d2d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 36)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 18)
	scroll.add_child(_body)
	_label("VOLOBALL Mobile · " + MobileDiagnostics.BUILD, 34)
	_label("Волейбол проти бота · сенсорне керування", 22)
	_button("Грати · 1 × 1", _offline)
	_status = _label("", 20)
	_button("Економний режим · 30 FPS", func(): _quality(30, 60))
	_button("Плавний режим · 60 FPS", func(): _quality(60, 75))
	_button("Скопіювати журнал запуску", func():
		DisplayServer.clipboard_set(MobileDiagnostics.read_log())
		_status.text = "Журнал скопійовано — встав його в повідомлення.")

func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	_body.add_child(label)
	return label

func _button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 64
	button.pressed.connect(callback)
	_body.add_child(button)
	return button

func _offline() -> void:
	Net.leave()
	GameConfig.set_mode(1)
	GameConfig.stage = "mobile"
	GameConfig.net_roster = []
	GameConfig.quick_match = false
	GameConfig.ranked_match = false
	GameConfig.goto_scene(MobileRender.MATCH)

func _quality(fps: int, resolution: int) -> void:
	GameConfig.max_fps = fps
	GameConfig.resolution_3d = resolution
	MobileRender.apply()
	GameConfig.apply_render_scale()
	GameConfig.apply_display()
	GameConfig.apply_frame_cap()
	GameConfig.save_settings()
	_status.text = "Збережено: %d FPS" % fps
