extends RefCounted
















static func build(host: Control, title: String, icon_name: String, 
		sticker_c: Color, width: = 640.0) -> Dictionary:
	var back: = UiBackdrop.new()
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(back)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(center)

	var field: = PanelContainer.new()
	var fsb: = UiStyle.field_box(30)
	fsb.set_content_margin_all(18)
	field.add_theme_stylebox_override("panel", fsb)
	UiStyle.field_doodles(field)
	center.add_child(field)

	var outer: = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	field.add_child(outer)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	var st: = UiStyle.sticker(icon_name, sticker_c, 50, -0.08)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(st)
	var t: = Label.new()
	t.text = title
	t.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	t.add_theme_font_size_override("font_size", 34)
	t.add_theme_color_override("font_color", UiStyle.text() if UiStyle.dark else UiStyle.INK)
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(t)
	outer.add_child(head)

	var card: = PanelContainer.new()
	var csb: = UiStyle.card_box(UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	csb.set_content_margin_all(20)
	card.add_theme_stylebox_override("panel", csb)
	outer.add_child(card)
	var cv: = VBoxContainer.new()
	cv.add_theme_constant_override("separation", 14)
	cv.custom_minimum_size.x = width
	card.add_child(cv)
	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cv.add_child(body)
	cv.add_child(rule())
	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	foot.custom_minimum_size.y = 52
	cv.add_child(foot)
	return {"field": field, "body": body, "foot": foot}



static func apply_theme() -> void :
	UiStyle.dark = GameConfig.dark_theme or LaunchGate.dev_args().has("--dark")


static func rule() -> Control:
	var r: = ColorRect.new()
	r.color = UiStyle.hairline()
	r.custom_minimum_size.y = 2
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func words(text_in: String, size: = 17) -> Label:
	var l: = Label.new()
	l.text = text_in
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", UiStyle.text())
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func dont_show() -> CheckBox:
	var cb: = CheckBox.new()
	cb.text = "don't show this again"
	UiStyle.style_check(cb)
	cb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return cb

static func spacer() -> Control:
	var s: = Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return s

static func continue_btn() -> Button:
	var b: = Button.new()
	b.text = "continue"
	UiStyle.style_button(b, "primary", 18)
	b.custom_minimum_size = Vector2(170, 48)
	b.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return b



static func chain(list: Array) -> void :
	for i in list.size():
		var c: Control = list[i]
		if i > 0:
			c.focus_neighbor_top = c.get_path_to(list[i - 1])
		if i + 1 < list.size():
			c.focus_neighbor_bottom = c.get_path_to(list[i + 1])



static func is_continue_event(event: InputEvent) -> bool:
	var k: = event as InputEventKey
	if k != null:
		return k.pressed and not k.echo\
		and k.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_SPACE]
	if event is InputEventJoypadButton:
		return event.is_action_pressed("ui_cancel")
	return false




static func refocus(event: InputEvent, cont: Control) -> bool:
	if cont == null or not cont.is_inside_tree()\
	or cont.get_viewport().gui_get_focus_owner() != null:
		return false
	if event is InputEventMouse or not event.is_pressed() or event.is_echo():
		return false
	for a in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept"]:
		if event.is_action_pressed(a):
			cont.grab_focus()
			return true
	return false



static func maybe_shot(host: Control) -> bool:
	var args: = LaunchGate.dev_args()
	var at: = args.find("--notice-shot")
	if at < 0 or at + 1 >= args.size():
		return false
	var path: = String(args[at + 1])
	var tree: = host.get_tree()
	await tree.create_timer(1.2).timeout
	if not is_instance_valid(host):
		return true
	var img: = host.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("[notice-shot] saved %s" % path)
	tree.quit()
	return true
