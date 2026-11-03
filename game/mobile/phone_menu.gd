extends Control

# The launcher deliberately has no dependencies on the desktop Menu, HUD,
# character rigs, render viewports or shop scenes. Match loading is separate.
const BACKGROUND := preload("res://game/mobile/menu_background.png")
const LOGO := preload("res://game/logo/jvlogo_sd.png")
var player: Node = null
var _home: VBoxContainer
var _settings: VBoxContainer
var _settings_panel: Control
var _profile: VBoxContainer
var _card_local: Button
var _status: Label
var _name: LineEdit
var _column: Control
var _page_background: Panel

func _ready() -> void:
	AppData.boot_succeeded()
	Net.leave()
	GameConfig.menu_open = true
	GameConfig.menu_practice = false
	GameConfig.onboarding_active = false
	GameConfig.stage = "grass"
	MobileRender.apply()
	GameConfig.apply_render_scale()
	get_tree().paused = false
	get_viewport().disable_3d = true
	_build()
	resized.connect(_layout)
	_layout()
	MobileDiagnostics.record("mobile_menu_ready: 2d_launcher")

func _exit_tree() -> void:
	GameConfig.menu_open = false
	get_viewport().disable_3d = false

func _box(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(12)
	return style

func _label(text: String, size: int, color := UiStyle.INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK if size >= 24 else UiStyle.FONT_SEMI))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, callback: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(84, 44)
	button.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", UiStyle.INK if primary else UiStyle.MUTED)
	button.add_theme_color_override("font_hover_color", UiStyle.INK)
	button.add_theme_color_override("font_disabled_color", UiStyle.MUTED)
	button.add_theme_stylebox_override("normal", _box(UiStyle.PRIMARY if primary else Color.TRANSPARENT, 24))
	button.add_theme_stylebox_override("hover", _box(UiStyle.PRIMARY.lightened(0.2) if primary else Color("e6eaf4"), 24))
	button.add_theme_stylebox_override("pressed", _box(UiStyle.PRIMARY.darkened(0.1), 24))
	button.add_theme_stylebox_override("disabled", _box(Color.TRANSPARENT, 24))
	button.pressed.connect(callback)
	return button

func _build() -> void:
	var image := TextureRect.new()
	image.texture = BACKGROUND
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image)
	var header := PanelContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 94
	header.add_theme_stylebox_override("panel", _box(UiStyle.NEUTRAL, 0))
	add_child(header)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 15)
	header.add_child(nav)
	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(160, 58)
	nav.add_child(logo)
	nav.add_child(_button("play", _settings_back, true))
	for title in ["locker", "shop"]:
		var unavailable := _button(title, func(): pass)
		unavailable.disabled = true
		unavailable.tooltip_text = "Тимчасово недоступно на iPhone"
		nav.add_child(unavailable)
	nav.add_child(_button("profile", func(): _show(_profile)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(spacer)
	nav.add_child(_button("⚙", func(): _open_settings(0)))
	_line(94)
	_column = Control.new()
	add_child(_column)
	_page_background = Panel.new()
	_page_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_background.add_theme_stylebox_override("panel", _box(UiStyle.NEUTRAL, 24))
	_page_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_background.visible = false
	_column.add_child(_page_background)
	_home = _page()
	_card("massiveMultiplayer", "online", "play matches worldwide", UiStyle.PRIMARY, Callable(), true)
	_card_local = _card("singleplayer", "local", "play matches locally", Color.WHITE, _offline)
	_card("target", "practice", "freeplay and ball practice", Color.WHITE, _start_solo_practice)
	_card("gamepad", "controller config", "touch controls on iPhone", Color.WHITE, func(): _open_settings(0))
	_card("gear", "system settings", "configure display and sound", Color.WHITE, func(): _open_settings(0))
	_card("question", "feedback & bug reports", "copy the startup journal", Color.WHITE, _copy_log)
	_card("movie", "credits", "Godot Engine", UiStyle.PRIMARY, func(): _status.text = "VOLOBALL · Godot Engine")
	_settings = _page()
	_settings.visible = false
	_settings_panel = _settings
	_settings.add_child(_label("system settings", 32))
	_settings.add_child(_button("30 FPS · економний режим", func(): _quality(30, 60), true))
	_settings.add_child(_button("60 FPS · плавний режим", func(): _quality(60, 75)))
	_settings.add_child(_button("Скопіювати журнал запуску", _copy_log))
	var help := _label("У матчі: лівий джойстик — рух, правий — приціл.\nМ’ЯЧ / G: поява на висоті 5,2 м.", 20)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_settings.add_child(help)
	_settings.add_child(_button("← назад", _settings_back, true))
	_profile = _page()
	_profile.visible = false
	_profile.add_child(_label("profile", 32))
	_name = LineEdit.new()
	_name.text = ProfileStore.active().name
	_name.max_length = 10
	_name.custom_minimum_size.y = 54
	_profile.add_child(_name)
	_profile.add_child(_button("Зберегти ім’я", _save_name, true))
	_profile.add_child(_button("← назад", _settings_back))
	_status = _label("", 17, Color.WHITE)
	_status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_status.offset_top = -87
	_status.offset_bottom = -62
	_status.offset_left = 36
	add_child(_status)
	var footer := PanelContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -58
	footer.add_theme_stylebox_override("panel", _box(UiStyle.NEUTRAL, 0))
	add_child(footer)
	var foot := HBoxContainer.new()
	footer.add_child(foot)
	foot.add_child(_label(ProfileStore.active().name, 18))
	var space := Control.new()
	space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(space)
	foot.add_child(_button("30 FPS", func(): _quality(30, 60)))
	foot.add_child(_button("60 FPS", func(): _quality(60, 75)))
	foot.add_child(_button("Журнал", _copy_log))
	foot.add_child(_label("stage: grass court", 18, UiStyle.SECONDARY))
	foot.add_child(_button("freeplay", _start_solo_practice, true))
	foot.add_child(_label("v" + MobileDiagnostics.BUILD, 14, UiStyle.MUTED))

func _line(y: int) -> void:
	var line := ColorRect.new()
	line.color = UiStyle.PRIMARY
	line.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	line.offset_top = y
	line.offset_bottom = y + 4
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

func _page() -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_column.add_child(page)
	return page

func _card(icon: String, title: String, subtitle: String, color: Color, callback: Callable, disabled := false) -> Button:
	var button := _button("", callback if callback.is_valid() else func(): pass)
	button.custom_minimum_size.y = 64
	button.add_theme_stylebox_override("normal", _box(color, 24))
	button.add_theme_stylebox_override("disabled", _box(color, 24))
	button.disabled = disabled
	_home.add_child(button)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 18
	row.offset_right = -12
	row.add_theme_constant_override("separation", 16)
	button.add_child(row)
	var picture := TextureRect.new()
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.texture = UiStyle.icon(icon, false, true)
	picture.custom_minimum_size = Vector2(44, 44)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(picture)
	var words := VBoxContainer.new()
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.add_theme_constant_override("separation", 0)
	row.add_child(words)
	words.add_child(_label(title, 27))
	words.add_child(_label(subtitle, 14, UiStyle.MUTED if color == Color.WHITE else UiStyle.INK.lightened(0.2)))
	return button

func _layout() -> void:
	_column.position = Vector2(size.x * 0.105, 111)
	_column.size = Vector2(minf(size.x * 0.34, 530), size.y - 205)

func _show(page: Control) -> void:
	_page_background.visible = page != _home
	for item in [_home, _settings, _profile]:
		item.visible = item == page
	_status.text = ""

func _open_settings(_scope: int) -> void:
	_show(_settings)

func _settings_back() -> void:
	_show(_home)

func _quality(fps: int, resolution: int) -> void:
	GameConfig.max_fps = fps
	GameConfig.resolution_3d = resolution
	MobileRender.apply()
	GameConfig.apply_render_scale()
	GameConfig.save_settings()
	_status.text = "Збережено: %d FPS" % fps

func _copy_log() -> void:
	DisplayServer.clipboard_set(MobileDiagnostics.read_log())
	_status.text = "Журнал скопійовано"

func _save_name() -> void:
	var value := _name.text.strip_edges()
	if value != "":
		ProfileStore.active().name = value
		ProfileStore.save()
		_status.text = "Ім’я збережено"

func _offline() -> void:
	_open_match(false)

func _start_solo_practice() -> void:
	_open_match(true)

func _open_match(practice: bool) -> void:
	Net.leave()
	Net.practice = practice
	PracticeMode.solo_size = 1
	GameConfig.set_mode(1)
	GameConfig.stage = "grass"
	GameConfig.net_roster = []
	GameConfig.quick_match = false
	GameConfig.ranked_match = false
	GameConfig.goto_scene(MobileRender.MATCH)
