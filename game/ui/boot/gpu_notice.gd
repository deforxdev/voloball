extends Control
















const NEXT_SCENE: = "res://game/ui/boot/boot_intro.tscn"
const NOTICE_CARD: = preload("res://game/ui/boot/notice_card.gd")
const DRIVER_URLS: = {
	"amd": "https://www.amd.com/en/support", 
	"intel": "https://www.intel.com/content/www/us/en/download-center/home.html", 
	"nvidia": "https://www.nvidia.com/en-us/drivers/", 
}

var _dont_show: CheckBox = null
var _cont: Button = null
var _left: = false

func _ready() -> void :




	var shot: = LaunchGate.dev_args().has("--notice-shot")
	if GameConfig.notice_dismissed("gpu") and not AppData.safe_mode and not shot:
		GameConfig.goto_scene(NEXT_SCENE)
		return
	_build()

func _build() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	NOTICE_CARD.apply_theme()
	var parts: = NOTICE_CARD.build(self, "notice", "wrench", UiStyle.SECONDARY, 640.0)
	var card: Control = parts["field"]
	var v: VBoxContainer = parts["body"]
	var foot: HBoxContainer = parts["foot"]




	if AppData.safe_mode:
		var band: = PanelContainer.new()
		var bsb: = UiStyle.flat_box(UiStyle.RED, 18)
		bsb.content_margin_left = 16.0
		bsb.content_margin_right = 16.0
		bsb.content_margin_top = 10.0
		bsb.content_margin_bottom = 10.0
		band.add_theme_stylebox_override("panel", bsb)
		var safe: = Label.new()
		safe.text = "due to an early crash, the game has launched in safe mode.\nclose any heavy apps, or try one of the command lines below if this issue repeats itself."
		safe.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		safe.add_theme_font_size_override("font_size", 15)
		safe.add_theme_color_override("font_color", Color.WHITE)
		safe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		band.add_child(safe)
		v.add_child(band)

	v.add_child(NOTICE_CARD.words("if you're having trouble entering the game, right click the game on steam, go to properties, and try any of the following launch commands.", 16))




	var box: = PanelContainer.new()
	var wsb: = UiStyle.flat_box(UiStyle.sunk(), UiStyle.RADIUS_SOFT)
	wsb.set_content_margin_all(16)
	box.add_theme_stylebox_override("panel", wsb)
	box.custom_minimum_size = Vector2(640, 350)
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(box)

	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	UiStyle.style_scroll(scroll.get_v_scroll_bar())

	var gutter: = MarginContainer.new()
	gutter.add_theme_constant_override("margin_right", 12)
	gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(gutter)
	var bbox: = VBoxContainer.new()
	bbox.add_theme_constant_override("separation", 8)
	bbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gutter.add_child(bbox)

	var gpu: = _adapter_name()
	if gpu != "":
		var gl: = RichTextLabel.new()
		gl.bbcode_enabled = true
		gl.fit_content = true
		gl.scroll_active = false
		gl.add_theme_color_override("default_color", UiStyle.text())
		gl.add_theme_font_override("normal_font", UiStyle.font(UiStyle.FONT_SEMI))
		gl.add_theme_font_override("bold_font", UiStyle.font(UiStyle.FONT_XBOLD))
		gl.add_theme_font_size_override("normal_font_size", 15)
		gl.add_theme_font_size_override("bold_font_size", 15)
		gl.text = "[b]your GPU:[/b] %s" % gpu
		gl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bbox.add_child(gl)

	bbox.add_child(_subhead("amd gpu"))
	var c1: = _cmd_row("--rendering-driver vulkan")
	bbox.add_child(c1)
	bbox.add_child(_subhead("amd / integrated / intel gpu"))
	var c2: = _cmd_row("--rendering-driver opengl3")
	bbox.add_child(c2)
	bbox.add_child(_muted("this will cause the game to render incorrectly, but it will run"))

	var spc: = Control.new()
	spc.custom_minimum_size.y = 6
	bbox.add_child(spc)
	bbox.add_child(_subhead("alternative solutions"))
	var alt: = RichTextLabel.new()
	alt.bbcode_enabled = true
	alt.fit_content = true
	alt.scroll_active = false
	alt.add_theme_color_override("default_color", UiStyle.text())
	alt.add_theme_font_override("normal_font", UiStyle.font(UiStyle.FONT_SEMI))
	alt.add_theme_font_size_override("normal_font_size", 15)
	alt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var link: = _blue().to_html(false)
	alt.text = """if a launch command doesn't help, try updating (or rolling back) your graphics drivers:
""" + "[color=#%s][url=amd]amd drivers[/url][/color]     " % link\
	+ "[color=#%s][url=intel]intel drivers[/url][/color]     " % link\
	+ "[color=#%s][url=nvidia]nvidia drivers[/url][/color]" % link
	alt.meta_clicked.connect(_on_link)
	bbox.add_child(alt)


	_dont_show = NOTICE_CARD.dont_show()
	foot.add_child(_dont_show)
	foot.add_child(NOTICE_CARD.spacer())
	var cont: = NOTICE_CARD.continue_btn()
	_cont = cont
	cont.pressed.connect(_on_continue)
	foot.add_child(cont)


	var b1: = c1.get_child(1) as Button
	var b2: = c2.get_child(1) as Button
	NOTICE_CARD.chain([b1, b2, _dont_show, cont])
	_dont_show.focus_neighbor_right = _dont_show.get_path_to(cont)
	cont.focus_neighbor_left = cont.get_path_to(_dont_show)

	NOTICE_CARD.maybe_shot(self)



	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
	cont.grab_focus()
	UiStyle.sfx("open")
	UiStyle.pop_in(card)

func _blue() -> Color:
	return UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY


func _subhead(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", _blue())
	return l


func _muted(text: String) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", UiStyle.muted())
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l




func _cmd_row(cmd: String) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var chip: = PanelContainer.new()
	var csb: = UiStyle.flat_box(UiStyle.card(), UiStyle.CAPSULE)
	csb.content_margin_left = 16.0
	csb.content_margin_right = 16.0
	csb.content_margin_top = 6.0
	csb.content_margin_bottom = 6.0
	chip.add_theme_stylebox_override("panel", csb)
	chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var lbl: = Label.new()
	lbl.text = cmd
	lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", UiStyle.text())
	chip.add_child(lbl)
	row.add_child(chip)
	var btn: = Button.new()
	btn.text = "copy"
	UiStyle.style_button(btn, "blue", 14)
	btn.custom_minimum_size.x = 104
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(_on_copy.bind(cmd, btn))
	row.add_child(btn)
	return row

func _on_copy(cmd: String, btn: Button) -> void :
	DisplayServer.clipboard_set(cmd)
	UiStyle.sfx("confirm")
	btn.text = "copied!"
	var tw: = create_tween()
	tw.tween_interval(1.2)
	tw.tween_callback( func(): if is_instance_valid(btn): btn.text = "copy")



func _adapter_name() -> String:
	var n: = String(RenderingServer.get_video_adapter_name())
	if n.strip_edges() == "":
		var info: = OS.get_video_adapter_driver_info()
		if info.size() > 0:
			n = String(info[0])
	return n.strip_edges()

func _on_link(meta: Variant) -> void :
	var key: = String(meta)
	if DRIVER_URLS.has(key):
		OS.shell_open(DRIVER_URLS[key])

func _on_continue() -> void :
	if _left:
		return
	_left = true
	if _dont_show != null and _dont_show.button_pressed:
		GameConfig.dismiss_notice("gpu")
	UiStyle.sfx("close")
	GameConfig.goto_scene(NEXT_SCENE)

func _unhandled_input(event: InputEvent) -> void :


	if NOTICE_CARD.is_continue_event(event):
		get_viewport().set_input_as_handled()
		_on_continue()
	elif NOTICE_CARD.refocus(event, _cont):
		get_viewport().set_input_as_handled()
