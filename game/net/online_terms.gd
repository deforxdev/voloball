extends Node


















const DIM: = Color(0, 0, 0, 0.55)
const UNLOCK_GREEN: = Color(0.3, 0.72, 0.42)
const HINT_LOCKED: = "please read and scroll to the bottom to continue"
const HINT_UNLOCKED: = "after carefully reading, please accept or deny"

const TERMS_BODY: = "[b]voloball online agreement[/b]\r\n\r\nby playing online in voloball, you agree to the terms below, and confirm that you are at least 13 years of age, in accordance with the steam subscriber agreement. please read everything in detail, then choose whether or not you accept. if you disagree with these terms and are unable to play the game as a result, please contact steam support.\r\n\r\n[b]1. respect your fellow player[/b]\r\nno harassment, hate speech, or personal attacks of any kind, including those based on gender, sexual orientation, disability, appearance, ethnicity, or beliefs. sexually explicit, graphic, or otherwise inappropriate content is also not permitted. treat others with courtesy. use appropriate language, and respect people's boundaries and opinions. do not impersonate temkosoft, our staff, or other players in an attempt to mislead anyone. do not spam, advertise, or attempt to lead anyone off-platform for any reason. this applies everywhere online play reaches, including server and lobby names, the chat system, and anything you personalize, such as created characters and usernames.\r\n\r\n[b]2. fair play for all[/b]\r\ncheating, exploiting bugs, or doing anything to gain an unfair advantage or ruin the experience for others is strictly prohibited. this includes third-party tools, modifications, or scripts that interfere with normal play. play by the rules so everyone can have fun.\r\n\r\n[b]3. game modifications[/b]\r\nto avoid unexpected interference with online play, modifying the game is strictly prohibited while playing online. this keeps everyone on equal terms so the experience stays fair for all.\r\n\r\n[b]4. online connectivity[/b]\r\nthe quality and stability of online play depend on your internet connection and on the host staying online. sessions may end unexpectedly, freeze, or crash, and uninterrupted service is not guaranteed. a strong, stable connection is recommended, especially when hosting a server.\r\n\r\n[b]5. personal data[/b]\r\nduring online play, basic information such as your steam name, lobby activity, and in-game actions may be visible to other players and used to run multiplayer features and enforce these rules. chat logs are stored and recorded, and may be used to review reports and enforce any suitable punishment for behaviour that breaks these terms. if you have linked your discord account, the same applies to the information it shares.\r\n\r\n[b]6. change is good[/b]\r\nthese terms may be updated or changed at any time. when that happens, a notice will be issued and you will be asked to review this agreement again. continuing to play online after an update means you accept the updated terms.\r\n\r\n[b]7. enforcement & acceptance[/b]\r\nif you are found to be acting against this agreement, whether determined by temkosoft or by a party approved by temkosoft, you may face restrictions on online play. these restrictions may be temporary or permanent depending on the nature and severity of the breach. temkosoft, or any party approved by temkosoft, may also restrict or prohibit your access to online play for any reason deemed necessary, even if that reason is not explicitly stated in these terms. by pressing \"i accept these terms\", you confirm that you have read and agree to everything written above, and you acknowledge that you may lose access to online play as a result of your own actions.\r\n\r\nthank you for helping keep your fellow players safe. welcome to the voloball community!"


























var _popup: CanvasLayer = null
var _pending_accept: Callable = Callable()
var _card: PanelContainer = null
var _terms: RichTextLabel = null
var _hint: Label = null
var _accept_btn: Button = null
var _decline_btn: Button = null
var _unlocked: = false






var _ban_ok_ms: = -1000000
var _ban_checking: = false
var _checking_layer: CanvasLayer = null
var _ban_gen: = 0
const BAN_TTL_MS: = 60000



func has_accepted() -> bool:
	return GameConfig.has_accepted_online_terms()






func require(on_accept: Callable) -> bool:
	if not has_accepted():
		_pending_accept = on_accept
		_show()
		return false




	if Time.get_ticks_msec() - _ban_ok_ms < BAN_TTL_MS:



		if Mod.has_pending_warning():
			_show_warning_notice(Mod.pending_warning(), on_accept)
			return false
		return true
	_pending_accept = on_accept
	_run_ban_gate()
	return false




func _run_ban_gate() -> void :
	if _ban_checking:
		return
	_ban_checking = true
	_ban_gen += 1
	var gen: = _ban_gen
	_checking_layer = _show_checking()
	Mod.check_self( func(allowed: bool, reason: String, expires: int, is_ban: bool):
		if gen != _ban_gen:


			if allowed:
				_ban_ok_ms = Time.get_ticks_msec()
			return
		_ban_checking = false
		if _checking_layer != null and is_instance_valid(_checking_layer):
			_checking_layer.queue_free()
		_checking_layer = null
		var cb: = _pending_accept
		_pending_accept = Callable()
		if allowed:
			_ban_ok_ms = Time.get_ticks_msec()

			if Mod.has_pending_warning():
				_show_warning_notice(Mod.pending_warning(), cb)
			elif cb.is_valid():
				cb.call_deferred()
		else:
			_show_ban_notice(reason, expires, is_ban))




func _show_checking() -> CanvasLayer:
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	var layer: = CanvasLayer.new()
	layer.layer = 97
	var scrim: = ColorRect.new()
	scrim.color = DIM
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
		pad.add_theme_constant_override("margin_" + s, 24)
	card.add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	pad.add_child(v)
	var ring: = SpinRing.new()
	ring.custom_minimum_size = Vector2(44, 44)
	ring.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(ring)
	var lbl: = Label.new()
	lbl.text = "connecting to online service…"
	lbl.custom_minimum_size.x = 260
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.style_label(lbl, "body")
	v.add_child(lbl)


	var cancel: = Button.new()
	cancel.name = "Cancel"
	cancel.text = "cancel"
	cancel.custom_minimum_size = Vector2(160, 44)
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UiStyle.style_button(cancel, "danger", 18)
	cancel.pressed.connect(cancel_check)
	v.add_child(cancel)
	tree.root.add_child(layer)


	( func():
		if is_instance_valid(cancel) and cancel.is_inside_tree():
			cancel.grab_focus()).call_deferred()
	return layer




func cancel_check() -> void :
	if not _ban_checking:
		return
	_ban_gen += 1
	_ban_checking = false
	_pending_accept = Callable()
	if _checking_layer != null and is_instance_valid(_checking_layer):
		_checking_layer.queue_free()
	_checking_layer = null


func is_checking() -> bool:
	return _ban_checking



class SpinRing extends Control:
	var _a: = 0.0
	func _process(delta: float) -> void :
		_a += delta * 4.2
		queue_redraw()
	func _draw() -> void :
		var c: = size * 0.5
		var r: = minf(size.x, size.y) * 0.5 - 3.0
		draw_arc(c, r, 0.0, TAU, 32, Color(UiStyle.SECONDARY, 0.22), 4.0, true)
		draw_arc(c, r, _a, _a + 1.9, 16, UiStyle.SECONDARY, 4.0, true)



func _fmt_countdown(expires_unix: int) -> String:
	var secs: = expires_unix - int(Time.get_unix_time_from_system())
	if secs <= 0:
		return ""
	var d: = secs / 86400
	var h: = (secs % 86400) / 3600
	var m: = (secs % 3600) / 60
	var s: = secs % 60
	if d > 0:
		return " (%dd %dh %dm left)" % [d, h, m]
	if h > 0:
		return " (%dh %dm %ds left)" % [h, m, s]
	if m > 0:
		return " (%dm %ds left)" % [m, s]
	return " (%ds left)" % s





func _show_ban_notice(reason: String, expires_unix: = 0, is_ban: = false) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 97
	var scrim: = ColorRect.new()
	scrim.color = DIM
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var margin: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + s, 22)
	card.add_child(margin)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(440, 0)
	margin.add_child(v)
	var title: = Label.new()
	title.text = "online play unavailable"
	UiStyle.style_label(title, "title")
	v.add_child(title)

	if is_ban:
		var base: = "you have been banned from online play"
		var headline: = Label.new()
		headline.text = base + (_fmt_countdown(expires_unix) if expires_unix > 0 else " (permanent)")
		headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.style_label(headline, "body")
		v.add_child(headline)

		if expires_unix > 0:
			var ct: = Timer.new()
			ct.wait_time = 1.0
			ct.autostart = true
			layer.add_child(ct)
			ct.timeout.connect( func():
				if is_instance_valid(headline):
					var c: = _fmt_countdown(expires_unix)
					headline.text = base + (c if c != "" else " (expired)"))

		var rlabel: = Label.new()
		rlabel.text = "reason"
		UiStyle.style_label(rlabel, "small", UiStyle.muted())
		v.add_child(rlabel)
		var box: = PanelContainer.new()
		UiStyle.style_panel(box, UiStyle.card().darkened(0.05) if not UiStyle.dark else UiStyle.card().lightened(0.06), UiStyle.RADIUS)
		v.add_child(box)
		var bpad: = MarginContainer.new()
		for s in ["left", "right", "top", "bottom"]:
			bpad.add_theme_constant_override("margin_" + s, 12)
		box.add_child(bpad)
		var rtext: = Label.new()
		rtext.text = reason if reason.strip_edges() != "" else "no reason given"
		rtext.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rtext.custom_minimum_size.x = 400
		UiStyle.style_label(rtext, "body")
		bpad.add_child(rtext)
	else:
		var msg: = Label.new()
		msg.text = reason if reason != "" else "you can't play online right now"
		msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UiStyle.style_label(msg, "body")
		v.add_child(msg)



	if is_ban:
		var appeal: = Button.new()
		appeal.text = "appeal this"
		appeal.custom_minimum_size.y = 42
		UiStyle.style_button(appeal, "secondary", 15)
		appeal.pressed.connect( func(): _show_appeal_form("online"))
		v.add_child(appeal)

	var ok: = Button.new()
	ok.text = "ok"
	ok.custom_minimum_size.y = 44
	UiStyle.style_button(ok, "primary", 16)
	ok.pressed.connect( func():
		UiStyle.sfx("close")
		layer.queue_free())
	v.add_child(ok)
	tree.root.add_child(layer)
	UiStyle.sfx("open")






func _show_warning_notice(warning: Dictionary, on_ack: Callable) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 97
	var scrim: = ColorRect.new()
	scrim.color = DIM
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.gui_input.connect( func(e):

		if e is InputEventMouseButton and e.pressed:
			UiStyle.sfx("close")
			layer.queue_free())
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var margin: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + s, 22)
	card.add_child(margin)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(440, 0)
	margin.add_child(v)
	var title: = Label.new()
	title.text = "this account has received an online warning"
	UiStyle.style_label(title, "title")
	v.add_child(title)

	var box: = PanelContainer.new()
	UiStyle.style_panel(box, UiStyle.card().darkened(0.05) if not UiStyle.dark else UiStyle.card().lightened(0.06), UiStyle.RADIUS)
	v.add_child(box)
	var bpad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		bpad.add_theme_constant_override("margin_" + s, 12)
	box.add_child(bpad)
	var rtext: = Label.new()
	rtext.text = String(warning.get("reason", "")).strip_edges()
	if rtext.text == "":
		rtext.text = "please keep it friendly out there"
	rtext.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rtext.custom_minimum_size.x = 400
	UiStyle.style_label(rtext, "body")
	bpad.add_child(rtext)
	var sub: = Label.new()
	sub.text = "read it and tap ok to keep playing online"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(sub, "small", UiStyle.muted())
	v.add_child(sub)
	var ok: = Button.new()
	ok.text = "ok got it"
	ok.custom_minimum_size.y = 44
	UiStyle.style_button(ok, "primary", 16)
	ok.pressed.connect( func():
		UiStyle.sfx("close")
		layer.queue_free()
		Mod.ack_warning()
		if on_ack.is_valid():
			on_ack.call_deferred())
	v.add_child(ok)
	tree.root.add_child(layer)
	UiStyle.sfx("warning")



func _show_appeal_form(ban_type: String) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 98
	var scrim: = ColorRect.new()
	scrim.color = DIM
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var margin: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + s, 22)
	card.add_child(margin)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(440, 0)
	margin.add_child(v)
	var title: = Label.new()
	title.text = "appeal your ban"
	UiStyle.style_label(title, "title")
	v.add_child(title)
	var appeal_max: = 400
	var field: = TextEdit.new()
	field.placeholder_text = "tell us what happened"
	field.custom_minimum_size = Vector2(400, 120)
	field.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	field.add_theme_color_override("font_color", UiStyle.text())

	field.add_theme_color_override("font_placeholder_color", Color(UiStyle.text(), 0.55))
	field.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	field.add_theme_font_size_override("font_size", 15)
	var fbox: = StyleBoxFlat.new()
	fbox.bg_color = UiStyle.card().darkened(0.05) if not UiStyle.dark else UiStyle.card().lightened(0.06)
	fbox.set_corner_radius_all(UiStyle.RADIUS)
	fbox.set_content_margin_all(10.0)
	field.add_theme_stylebox_override("normal", fbox)
	field.add_theme_stylebox_override("focus", fbox)
	v.add_child(field)

	var meta: = HBoxContainer.new()
	v.add_child(meta)
	var status: = Label.new()
	status.text = ""
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_label(status, "small", UiStyle.muted())
	meta.add_child(status)
	var counter: = Label.new()
	counter.text = "0/%d" % appeal_max
	UiStyle.style_label(counter, "small", UiStyle.muted())
	meta.add_child(counter)

	field.text_changed.connect( func():
		if field.text.length() > appeal_max:
			field.text = field.text.substr(0, appeal_max)
			field.set_caret_line(field.get_line_count() - 1)
			field.set_caret_column(field.get_line(field.get_line_count() - 1).length())
		counter.text = "%d/%d" % [field.text.length(), appeal_max])
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.custom_minimum_size.y = 48
	var cancel: = Button.new()
	cancel.text = "cancel"
	UiStyle.style_button(cancel, "tertiary", 15)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel.pressed.connect( func():
		UiStyle.sfx("close")
		layer.queue_free())
	row.add_child(cancel)
	var send: = Button.new()
	send.text = "send appeal"
	UiStyle.style_button(send, "primary", 15)
	send.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	send.pressed.connect( func():
		var msg: = field.text.strip_edges()
		if msg == "":
			status.text = "type something first"
			return
		send.disabled = true
		status.text = "sending…"
		var sid: = Net.my_steam_id()
		Backend.file_appeal(sid, ban_type, msg, func(code, _json):
			if not is_instance_valid(status):
				return
			if code == 200:
				status.text = "appeal sent we will take a look"
				send.text = "sent"
				if is_instance_valid(cancel):
					cancel.text = "close"
			else:
				send.disabled = false
				status.text = "couldnt send that try again in a bit"))
	row.add_child(send)
	v.add_child(row)
	tree.root.add_child(layer)
	UiStyle.sfx("open")


func is_open() -> bool:
	return _popup != null and is_instance_valid(_popup)


func _show() -> void :
	if is_open():
		return
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	_unlocked = false
	_popup = CanvasLayer.new()
	_popup.layer = 97

	var scrim: = ColorRect.new()
	scrim.color = DIM
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_popup.add_child(scrim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup.add_child(center)

	_card = PanelContainer.new()
	UiStyle.style_panel(_card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(_card)

	var margin: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + s, 22)
	_card.add_child(margin)

	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(560, 0)
	margin.add_child(v)

	var title: = Label.new()
	title.text = "online play agreement"
	UiStyle.style_label(title, "title")
	v.add_child(title)


	var panel: = PanelContainer.new()
	UiStyle.style_panel(panel, UiStyle.card().darkened(0.04), UiStyle.RADIUS)
	panel.custom_minimum_size = Vector2(560, 320)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(panel)

	var pad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + s, 12)
	panel.add_child(pad)

	_terms = RichTextLabel.new()
	_terms.bbcode_enabled = true
	_terms.fit_content = false
	_terms.scroll_active = true
	_terms.text = TERMS_BODY
	_terms.add_theme_color_override("default_color", UiStyle.text())
	_terms.add_theme_font_override("normal_font", UiStyle.font(UiStyle.FONT_SEMI))
	_terms.add_theme_font_override("bold_font", UiStyle.font(UiStyle.FONT_XBOLD))
	_terms.add_theme_font_size_override("normal_font_size", 15)
	_terms.add_theme_font_size_override("bold_font_size", 16)
	pad.add_child(_terms)
	var sb: = _terms.get_v_scroll_bar()
	if sb != null:
		UiStyle.style_scroll(sb)
		sb.value_changed.connect( func(_v): _check_bottom())

	_hint = Label.new()
	_hint.text = HINT_LOCKED
	UiStyle.style_label(_hint, "body")


	_hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	_hint.clip_text = true
	_hint.custom_minimum_size.y = 24
	v.add_child(_hint)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)




	row.custom_minimum_size.y = 56
	_decline_btn = Button.new()
	_decline_btn.text = "i do not accept"
	UiStyle.style_button(_decline_btn, "tertiary", 16)
	_decline_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decline_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_decline_btn.pressed.connect(_on_decline)
	row.add_child(_decline_btn)
	_accept_btn = Button.new()
	_accept_btn.text = "i accept these terms"
	UiStyle.style_button(_accept_btn, "primary", 16)
	_accept_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accept_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_accept_btn.pressed.connect(_on_accept)
	row.add_child(_accept_btn)
	v.add_child(row)

	tree.root.add_child(_popup)
	_set_unlocked(false)
	UiStyle.sfx("open")


	_check_bottom.call_deferred()
	await tree.process_frame
	await tree.process_frame
	if is_open():
		UiStyle.pop_in(_card)
		_check_bottom()


func _check_bottom() -> void :
	if _unlocked or not is_open() or _terms == null:
		return
	var sb: = _terms.get_v_scroll_bar()
	if sb == null:
		return
	var scrollable: bool = sb.max_value - sb.page > 1.0
	var at_bottom: bool = sb.value >= sb.max_value - sb.page - 4.0
	if not scrollable or at_bottom:
		_unlocked = true
		_set_unlocked(true)


func _set_unlocked(on: bool) -> void :
	if _accept_btn == null:
		return
	_accept_btn.disabled = not on
	_accept_btn.modulate.a = 1.0 if on else 0.45
	_accept_btn.mouse_default_cursor_shape = \
	Control.CURSOR_POINTING_HAND if on else Control.CURSOR_ARROW
	if _hint != null:
		if on:
			_hint.text = HINT_UNLOCKED
			_hint.add_theme_color_override("font_color", UNLOCK_GREEN)
		else:
			_hint.text = HINT_LOCKED
			_hint.add_theme_color_override("font_color", UiStyle.muted())


func _on_accept() -> void :
	if _accept_btn != null and _accept_btn.disabled:
		return
	var cb: = _pending_accept
	_close()
	GameConfig.accept_online_terms()
	if cb.is_valid():
		cb.call()


func _on_decline() -> void :

	_close()


func _close() -> void :
	UiStyle.sfx("close")
	_pending_accept = Callable()
	_unlocked = false
	_card = null
	_terms = null
	_hint = null
	_accept_btn = null
	_decline_btn = null
	if is_open():
		_popup.queue_free()
	_popup = null
