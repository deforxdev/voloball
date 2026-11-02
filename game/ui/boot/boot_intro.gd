extends Control


















const NEXT_SCENE: = "res://game/ui/title.tscn"

const ONBOARD_SCENE: = "res://game/character/locker.tscn"

const SETTINGS_PANEL: = preload("res://game/ui/settings_panel.tscn")

const DEMO_NOTICE: = preload("res://game/ui/boot/demo_notice.gd")
const NOTICE_CARD: = preload("res://game/ui/boot/notice_card.gd")
const PAD_NAV: = preload("res://game/ui/style/pad_nav.gd")



const SPLASH_SIZE: = Vector2(1920.0, 1080.0)

const SHOT_AT: = 2.45

@onready var splash: VideoStreamPlayer = $Splash
@onready var fade_out_overlay: ColorRect = $FadeOutOverlay

var _shot_path: = ""
var _skipping: = false
var _left: = false
var _gating: = false
var _gate_settings: Control = null
var _gate_back: = Callable()



func _unhandled_input(event: InputEvent) -> void :
	if _skipping or _gating:
		return
	var pressed: = false
	if event is InputEventKey:
		pressed = event.pressed and not event.echo
	elif event is InputEventJoypadButton:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	_skip()

func _skip() -> void :
	_skipping = true
	splash.stop()
	var t: = create_tween()
	t.tween_property(fade_out_overlay, "color:a", 1.0, 0.25)
	t.tween_callback(_go)





const WHITE_COVER: = preload("res://game/ui/boot/white_cover.gd")

func _go() -> void :
	if _left:
		return
	_left = true
	UiStyle.dark = GameConfig.dark_theme
	get_tree().root.add_child(WHITE_COVER.new())
	GameConfig.goto_scene(NEXT_SCENE)


func _fit_splash() -> void :
	var win: = get_viewport_rect().size
	var k: = maxf(win.x / SPLASH_SIZE.x, win.y / SPLASH_SIZE.y)
	splash.size = SPLASH_SIZE * k
	splash.position = (win - splash.size) * 0.5

func _ready() -> void :
	UiStyle.dark = false




	var gate: = LaunchGate.check()
	if gate["verdict"] != LaunchGate.VERDICT_OK:
		_gating = true
		LaunchGate.show_block(self, gate)
		return


	var raw_args: = Array(LaunchGate.dev_args())
	var args: = raw_args.duplicate()
	args.erase("--boot-run")



	var force_onboard: = args.has("--onboard")
	args.erase("--onboard")
	args.erase("--beta")
	var shot: = args.find("--boot-shot")
	var notice_shot: = args.has("--notice-shot")
	if shot >= 0 and shot + 1 < args.size():
		_shot_path = String(args[shot + 1])
	elif not args.is_empty() and not notice_shot:
		GameConfig.goto_scene(NEXT_SCENE)
		return




	if notice_shot or (_shot_path == "" and DEMO_NOTICE.wanted()\
	and not DEMO_NOTICE.shown_this_session):
		DEMO_NOTICE.shown_this_session = true
		_gating = true
		var dn: = DEMO_NOTICE.new()
		add_child(dn)
		await dn.closed
		_gating = false
		if not is_inside_tree():
			return
		UiStyle.dark = false






	if (force_onboard or ProfileStore.seeded_fresh) and not GameConfig.onboarding_seen\
	and _shot_path == "" and not raw_args.has("--boot-run"):
		GameConfig.onboarding_seen = true
		GameConfig.onboarding_active = true



		await _first_run_settings_gate()
		UiStyle.dark = GameConfig.dark_theme
		GameConfig.goto_scene(ONBOARD_SCENE)
		return
	MusicManager.stop(0.0)
	if _shot_path != "":
		_shoot_after(SHOT_AT)
	else:
		_go()






func _input(event: InputEvent) -> void :

	if _gating and _gate_back.is_valid() and event.is_action_pressed("ui_cancel")\
	and UiSelect.active == null and not UiStyle.dialog_active():
		var foc0: = get_viewport().gui_get_focus_owner()
		if not (foc0 is LineEdit or foc0 is TextEdit):
			get_viewport().set_input_as_handled()
			_gate_back.call()
			_gate_back = Callable()
			UiStyle.sfx("back")
			return
	if _gate_settings == null or not is_instance_valid(_gate_settings)\
	or not _gate_settings.is_visible_in_tree():
		return
	var dir: = ""
	for d in ["up", "down", "left", "right"]:
		if event.is_action_pressed("ui_" + d, true):
			dir = d
	if dir == "":
		return
	var foc: = get_viewport().gui_get_focus_owner()
	if foc is LineEdit or foc is TextEdit or UiSelect.active != null:
		return
	get_viewport().set_input_as_handled()
	if foc == null or not _gate_settings.is_ancestor_of(foc):
		for c in _gate_settings.find_children("*", "BaseButton", true, false):
			if (c as Control).is_visible_in_tree() and (c as Control).focus_mode != Control.FOCUS_NONE:
				(c as Control).grab_focus()
				return
		return
	if foc is Range and (dir == "left" or dir == "right"):
		var rg: = foc as Range
		rg.value += maxf(rg.step, (rg.max_value - rg.min_value) / 10.0) * (1.0 if dir == "right" else -1.0)
		UiStyle.sfx("tick")
		return
	var next: = PAD_NAV.neighbor(foc, dir, _gate_settings)
	if next != null and _gate_settings.is_ancestor_of(next):
		next.grab_focus()
		PAD_NAV.follow(next)
		UiStyle.sfx("hover")

func _shoot_after(wait: float) -> void :
	await get_tree().create_timer(wait).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shot_path)
	print("boot shot -> ", _shot_path)
	get_tree().quit()





func _first_run_settings_gate() -> void :
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



	UiStyle.dark = GameConfig.dark_theme
	var overlay: = CanvasLayer.new()
	overlay.layer = 120
	add_child(overlay)
	var bg: = ColorRect.new()
	bg.color = UiStyle.bg()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(bg)
	var done: = {"v": false}

	_gating = true
	_settings_prompt(overlay, bg, done)


	while not done["v"] and is_inside_tree():
		await get_tree().process_frame
	_gating = false
	if is_instance_valid(overlay):
		overlay.queue_free()



func _settings_prompt(overlay: CanvasLayer, bg: ColorRect, done: Dictionary) -> void :
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)
	var parts: = NOTICE_CARD.build(root, "before you play", "gear", UiStyle.SECONDARY, 560.0)
	(parts["body"] as Control).add_child(NOTICE_CARD.words(
		"would you like to configure your settings first? (these may be changed at any time)"))
	var foot: HBoxContainer = parts["foot"]
	foot.add_child(NOTICE_CARD.spacer())
	var skip: = Button.new()
	skip.text = "don't need to!"
	UiStyle.style_button(skip, "secondary", 18)
	skip.custom_minimum_size = Vector2(170, 48)
	skip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	skip.pressed.connect( func(): done["v"] = true)
	foot.add_child(skip)
	_gate_back = func(): done["v"] = true
	var go: = Button.new()
	go.text = "configure settings"
	UiStyle.style_button(go, "primary", 18)
	go.custom_minimum_size = Vector2(200, 48)
	go.size_flags_vertical = Control.SIZE_EXPAND_FILL
	go.pressed.connect( func():
		root.queue_free()
		_settings_view(overlay, bg, done))
	foot.add_child(go)
	skip.focus_neighbor_right = skip.get_path_to(go)
	go.focus_neighbor_left = go.get_path_to(skip)

	go.grab_focus.call_deferred()
	UiStyle.pop_in(parts["field"])




func _settings_view(overlay: CanvasLayer, bg: ColorRect, done: Dictionary) -> void :
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)
	_gate_settings = root
	var back_drop: = UiBackdrop.new()
	back_drop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(back_drop)
	var m: = MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + s, 40)
	root.add_child(m)
	var center: = CenterContainer.new()
	m.add_child(center)
	var field: = PanelContainer.new()
	var fsb: = UiStyle.field_box(30)
	fsb.set_content_margin_all(18)
	field.add_theme_stylebox_override("panel", fsb)
	UiStyle.field_doodles(field)
	center.add_child(field)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	field.add_child(v)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	var st: = UiStyle.sticker("gear", UiStyle.MUTED, 50, -0.08)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(st)
	var t: = Label.new()
	t.text = "system settings"
	t.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	t.add_theme_font_size_override("font_size", 34)
	t.add_theme_color_override("font_color", UiStyle.text() if UiStyle.dark else UiStyle.INK)
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(t)
	v.add_child(head)
	var panel: = SETTINGS_PANEL.instantiate() as SettingsPanel
	panel.on_field = true
	panel.set_scope(SettingsPanel.Scope.SYSTEM)
	panel.custom_minimum_size.x = 860

	panel.custom_minimum_size.y = minf(560.0, get_viewport().get_visible_rect().size.y - 280.0)




	panel.retheme_requested.connect( func(_dark: bool):
		bg.color = UiStyle.bg()
		root.queue_free()
		_settings_view.call_deferred(overlay, bg, done))
	v.add_child(panel)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	v.add_child(row)
	var back: = Button.new()
	back.text = "back"
	UiStyle.style_button(back, "secondary", 19)
	back.icon = UiStyle.icon("arrowLeft", true)
	for k in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		back.add_theme_color_override(k, 
			UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY)
	back.add_theme_constant_override("icon_max_width", 22)
	back.add_theme_constant_override("h_separation", 10)
	back.custom_minimum_size = Vector2(150, 46)
	back.pressed.connect( func(): done["v"] = true)
	row.add_child(back)
	_gate_back = func(): done["v"] = true
	back.grab_focus.call_deferred()
	var reset: = Button.new()
	reset.text = "reset all"
	UiStyle.style_button(reset, "exit", 19)
	reset.custom_minimum_size = Vector2(150, 46)
	reset.pressed.connect( func(): panel.reset_all())
	row.add_child(reset)
