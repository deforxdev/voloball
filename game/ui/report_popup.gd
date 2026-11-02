class_name ReportPopup
extends RefCounted








static func open(reported_sid: int, reported_name: String, replay = null, 
		on_close: = Callable(), stage_override: = "", mode_override: = "", 
		match_record: = {}) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	if not Reports.can_report(reported_sid):
		if on_close.is_valid():
			on_close.call()
		return



	Backend.report_status( func(_code, json):
		if json is Dictionary and (json as Dictionary).has("reports_enabled") and not bool((json as Dictionary).get("reports_enabled", true)):
			_show_down(on_close)
		else:
			_open_form(reported_sid, reported_name, replay, on_close, stage_override, 
				mode_override, match_record))

static func _open_form(reported_sid: int, reported_name: String, replay, 
		on_close: Callable, stage_override: String, mode_override: String, 
		match_record: Dictionary) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 98
	layer.add_child(MouseHold.new())
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.55)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var pad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + s, 20)
	card.add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.custom_minimum_size.x = 390
	pad.add_child(v)

	var title: = Label.new()
	title.text = "report %s" % reported_name
	UiStyle.style_label(title, "title")
	v.add_child(title)
	var sub: = Label.new()
	sub.text = "pick a reason"
	UiStyle.style_label(sub, "small", UiStyle.muted())
	v.add_child(sub)

	var chosen: = {"cat": ""}
	var cat_btns: Array = []
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	for c in Reports.CATEGORIES:
		var b: = Button.new()
		b.text = String(c[1])
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(0, 34)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiStyle.style_button(b, "tertiary", 13)
		var key: = String(c[0])
		b.pressed.connect( func():
			chosen.cat = key

			for other in cat_btns:
				var sel: bool = other == b
				(other as Button).button_pressed = sel
				UiStyle.style_button(other as Button, "secondary" if sel else "tertiary", 13))
		cat_btns.append(b)
		grid.add_child(b)

	var desc: = LineEdit.new()
	desc.placeholder_text = "what happened? (optional)"
	desc.custom_minimum_size = Vector2(0, 40)
	v.add_child(desc)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var cancel: = Button.new()
	cancel.text = "cancel"
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(cancel, "tertiary", 15)
	cancel.pressed.connect( func():
		layer.queue_free()
		if on_close.is_valid():
			on_close.call())
	row.add_child(cancel)
	var send: = Button.new()
	send.text = "send report"
	send.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(send, "primary", 15)
	send.pressed.connect( func():
		if chosen.cat == "":
			sub.text = "pick a reason first"
			sub.add_theme_color_override("font_color", UiStyle.RED)
			return
		Reports.file(reported_sid, reported_name, chosen.cat, desc.text, replay, 
			stage_override, mode_override, match_record)
		layer.queue_free()
		_show_sent(reported_name, on_close))
	row.add_child(send)

	(tree.current_scene if tree.current_scene != null else tree.root).add_child(layer)
	UiStyle.sfx("open")



static func _show_down(on_close: = Callable()) -> void :
	_show_card("reports are offline", Reports.DOWN_MSG, "ok", "close", on_close)


static func _show_sent(reported_name: String, on_close: = Callable()) -> void :
	_show_card("report sent", "your report will be reviewed and processed as soon as possible", 
		"done", "confirm", on_close)

static func _show_card(title: String, body: String, button: String, sound: String, 
		on_close: = Callable()) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		if on_close.is_valid():
			on_close.call()
		return
	var layer: = CanvasLayer.new()
	layer.layer = 98
	layer.add_child(MouseHold.new())
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.55)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var pad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + s, 20)
	card.add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.custom_minimum_size.x = 320
	pad.add_child(v)
	var t: = Label.new()
	t.text = title
	UiStyle.style_label(t, "title")
	v.add_child(t)
	var s: = Label.new()
	s.text = body
	s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(s, "small", UiStyle.muted())
	v.add_child(s)
	var ok: = Button.new()
	ok.text = button
	ok.custom_minimum_size = Vector2(0, 40)
	UiStyle.style_button(ok, "primary", 15)
	ok.pressed.connect( func():
		layer.queue_free()
		if on_close.is_valid():
			on_close.call())
	v.add_child(ok)
	(tree.current_scene if tree.current_scene != null else tree.root).add_child(layer)
	UiStyle.sfx(sound)
