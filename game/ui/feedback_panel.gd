class_name FeedbackPanel
extends Control












const MAX_CHARS: = 1000
const TYPES: = ["gameplay", "ui", "settings", "cpu", "audio", "online", "other"]
const SEVERITIES: = [["minor", "minor"], ["moderate", "moderate"], ["urgent", "URGENT"]]
const MAX_FILES: = 5
const FILE_LIMIT: = 10 * 1024 * 1024
const TOTAL_LIMIT: = 30 * 1024 * 1024
const THUMB: = 76
const IMAGE_EXTS: = ["png", "jpg", "jpeg", "gif", "webp", "bmp"]
const COOLDOWN_MS: = 30000

static var _cooldown_until: = 0

signal closed

var _kind: = "bug"
var _type: = "gameplay"
var _severity: = ""
var _sev_row: HBoxContainer
var _sev_btns: Array = []
var _text: TextEdit
var _char_label: Label
var _status: Label
var _send_btn: Button
var _kind_bug: Button
var _kind_fb: Button
var _sending: = false
var _ticket_id: = ""
var _uploaded: = 0

var _files: Array = []
var _thumbs: HFlowContainer
var _add_btn: Button
var _file_dialog: FileDialog

func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.82)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.gui_input.connect( func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed:
			_close())
	add_child(scrim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	card.custom_minimum_size = Vector2(560, 0)
	center.add_child(card)
	var pad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % s, 20)
	card.add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pad.add_child(v)

	var title: = Label.new()
	title.text = "feedback & bug reports"
	UiStyle.style_label(title, "title")
	v.add_child(title)


	var krow: = HBoxContainer.new()
	krow.add_theme_constant_override("separation", 8)
	_kind_bug = Button.new()
	_kind_bug.text = "bug"
	_kind_bug.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_kind_bug.pressed.connect( func(): _set_kind("bug"))
	_kind_fb = Button.new()
	_kind_fb.text = "feedback"
	_kind_fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_kind_fb.pressed.connect( func(): _set_kind("feedback"))
	krow.add_child(_kind_bug)
	krow.add_child(_kind_fb)
	v.add_child(krow)


	var trow: = HBoxContainer.new()
	trow.add_theme_constant_override("separation", 10)
	var tlabel: = Label.new()
	tlabel.text = "type"
	UiStyle.style_label(tlabel, "small")
	tlabel.custom_minimum_size.x = 60
	tlabel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	trow.add_child(tlabel)
	var picker: = UiSelect.new(TYPES)
	picker.selected = 0
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.picked.connect( func(i: int): _type = TYPES[i])
	trow.add_child(picker)
	v.add_child(trow)


	_sev_row = HBoxContainer.new()
	_sev_row.add_theme_constant_override("separation", 8)
	var slabel: = Label.new()
	slabel.text = "how bad"
	UiStyle.style_label(slabel, "small")
	slabel.custom_minimum_size.x = 60
	slabel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sev_row.add_child(slabel)
	for sv in SEVERITIES:
		var b: = Button.new()
		b.text = sv[1]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key: String = sv[0]
		b.pressed.connect( func(): _set_severity(key))
		_sev_row.add_child(b)
		_sev_btns.append(b)
	v.add_child(_sev_row)


	_text = TextEdit.new()
	_text.placeholder_text = "describe the bug or feedback in detail"
	_text.custom_minimum_size = Vector2(0, 130)
	_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text.add_theme_color_override("font_color", UiStyle.text())
	_text.add_theme_color_override("font_placeholder_color", UiStyle.muted())
	var tsb: = StyleBoxFlat.new()
	tsb.bg_color = UiStyle.bg()
	tsb.set_corner_radius_all(UiStyle.RADIUS)
	tsb.set_content_margin_all(8)
	_text.add_theme_stylebox_override("normal", tsb)
	_text.add_theme_stylebox_override("focus", tsb)
	_text.text_changed.connect(_on_text_changed)
	v.add_child(_text)
	_char_label = Label.new()
	UiStyle.style_label(_char_label, "small")
	_char_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(_char_label)


	var arow: = HBoxContainer.new()
	arow.add_theme_constant_override("separation", 10)
	var albl: = Label.new()
	albl.text = "attachments"
	UiStyle.style_label(albl, "small")
	albl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	arow.add_child(albl)
	var aspring: = Control.new()
	aspring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arow.add_child(aspring)
	_add_btn = Button.new()
	_add_btn.text = "attach a file"
	UiStyle.style_button(_add_btn, "secondary", 14)
	_add_btn.pressed.connect(_pick_files)
	arow.add_child(_add_btn)
	v.add_child(arow)

	_thumbs = HFlowContainer.new()
	_thumbs.add_theme_constant_override("h_separation", 8)
	_thumbs.add_theme_constant_override("v_separation", 8)
	v.add_child(_thumbs)
	var note: = Label.new()
	note.text = "up to 5 screenshots or clips, 10mb each"
	UiStyle.style_label(note, "small", UiStyle.muted())
	v.add_child(note)


	_status = Label.new()
	UiStyle.style_label(_status, "small")
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_status)
	var actions: = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	actions.alignment = BoxContainer.ALIGNMENT_END
	var cancel: = Button.new()
	cancel.text = "close"
	UiStyle.style_button(cancel, "tertiary", 15)
	cancel.pressed.connect(_close)
	_send_btn = Button.new()
	_send_btn.text = "send"
	UiStyle.style_button(_send_btn, "primary", 15)
	_send_btn.pressed.connect(_send)
	actions.add_child(cancel)
	actions.add_child(_send_btn)
	v.add_child(actions)

	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.filters = PackedStringArray([
		"*.png,*.jpg,*.jpeg,*.gif,*.webp ; images", 
		"*.mp4,*.mov,*.webm,*.gif ; clips"])
	_file_dialog.use_native_dialog = true
	_file_dialog.files_selected.connect(_on_files_selected)
	_file_dialog.file_selected.connect( func(p: String): _on_files_selected(
		PackedStringArray([p])))
	add_child(_file_dialog)

	_set_kind("bug")
	_on_text_changed()
	_rebuild_thumbs()
	_text.grab_focus.call_deferred()

func _set_kind(k: String) -> void :
	_kind = k
	UiStyle.style_button(_kind_bug, "primary" if k == "bug" else "tertiary", 15)
	UiStyle.style_button(_kind_fb, "primary" if k == "feedback" else "tertiary", 15)
	_sev_row.visible = k == "bug"
	_set_severity(_severity)

func _set_severity(sv: String) -> void :
	_severity = sv
	for i in _sev_btns.size():
		var on: bool = SEVERITIES[i][0] == sv
		var style: = "primary" if on else "tertiary"
		if on and sv == "urgent":
			style = "danger"
		UiStyle.style_button(_sev_btns[i], style, 15)

func _on_text_changed() -> void :
	if _text.text.length() > MAX_CHARS:
		var caret: = _text.get_caret_column()
		_text.text = _text.text.substr(0, MAX_CHARS)
		_text.set_caret_column(mini(caret, MAX_CHARS))
	_char_label.text = "%d / %d" % [_text.text.length(), MAX_CHARS]



func _pick_files() -> void :
	_file_dialog.popup_centered_ratio(0.6)

func _on_files_selected(paths: PackedStringArray) -> void :
	for path in paths:
		if _files.size() >= MAX_FILES:
			_set_status("you can attach up to 5 files", UiStyle.RED)
			break
		var f: = FileAccess.open(path, FileAccess.READ)
		if f == null:
			_set_status("couldnt read %s" % path.get_file(), UiStyle.RED)
			continue
		var bytes: = f.get_buffer(f.get_length())
		f.close()
		var nm: = path.get_file()
		if bytes.size() > FILE_LIMIT:
			_set_status("%s is over 10mb, try a shorter clip" % nm, UiStyle.RED)
			continue
		if _total_bytes() + bytes.size() > TOTAL_LIMIT:
			_set_status("that puts the attachments over 30mb total", UiStyle.RED)
			continue
		_files.append({
			"name": nm, 
			"mime": _mime_for(nm), 
			"bytes": bytes, 
			"tex": _thumb_tex(nm, bytes), 
		})
		_set_status("", UiStyle.muted())
	_rebuild_thumbs()

func _total_bytes() -> int:
	var t: = 0
	for a in _files:
		t += (a["bytes"] as PackedByteArray).size()
	return t

func _thumb_tex(name: String, bytes: PackedByteArray) -> Texture2D:
	var ext: = name.get_extension().to_lower()



	var order: = ["png", "jpg", "webp", "bmp"]
	if ext == "jpeg":
		ext = "jpg"
	if order.has(ext):
		order.erase(ext)
		order.push_front(ext)
	var img: = Image.new()
	for dec in order:
		var err: = ERR_UNAVAILABLE
		match dec:
			"png": err = img.load_png_from_buffer(bytes)
			"jpg": err = img.load_jpg_from_buffer(bytes)
			"webp": err = img.load_webp_from_buffer(bytes)
			"bmp": err = img.load_bmp_from_buffer(bytes)
		if err == OK and img.get_width() > 0:
			return ImageTexture.create_from_image(img)
	return null

func _rebuild_thumbs() -> void :
	for c in _thumbs.get_children():
		c.queue_free()
	for i in _files.size():
		_thumbs.add_child(_make_tile(i))
	_add_btn.disabled = _files.size() >= MAX_FILES

func _make_tile(idx: int) -> Control:
	var a: Dictionary = _files[idx]
	var tile: = VBoxContainer.new()
	tile.add_theme_constant_override("separation", 2)
	var top: = Control.new()
	top.custom_minimum_size = Vector2(THUMB, THUMB)
	if a["tex"] != null:
		var tr: = TextureRect.new()
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.texture = a["tex"]
		tr.clip_contents = true
		top.add_child(tr)
	else:

		var box: = PanelContainer.new()
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var sb: = StyleBoxFlat.new()
		sb.bg_color = UiStyle.bg()
		sb.set_corner_radius_all(UiStyle.RADIUS)
		box.add_theme_stylebox_override("panel", sb)
		var ext: = Label.new()
		ext.text = String(a["name"]).get_extension().to_upper()
		ext.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ext.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		UiStyle.style_label(ext, "small", UiStyle.muted())
		box.add_child(ext)
		top.add_child(box)
	var rm: = Button.new()
	rm.text = "x"
	UiStyle.style_button(rm, "tertiary", 12)
	rm.custom_minimum_size = Vector2(22, 22)
	rm.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	rm.pressed.connect( func(): _remove_file(idx))
	top.add_child(rm)
	tile.add_child(top)
	var nm: = Label.new()
	nm.text = _short(String(a["name"]), 12)
	UiStyle.style_label(nm, "small", UiStyle.muted())
	nm.custom_minimum_size.x = THUMB
	nm.clip_text = true
	tile.add_child(nm)
	return tile

func _remove_file(idx: int) -> void :
	if idx >= 0 and idx < _files.size():
		_files.remove_at(idx)
	_rebuild_thumbs()

func _short(s: String, n: int) -> String:
	return s if s.length() <= n else s.substr(0, n - 1) + "…"

func _mime_for(name: String) -> String:
	match name.get_extension().to_lower():
		"png": return "image/png"
		"jpg", "jpeg": return "image/jpeg"
		"gif": return "image/gif"
		"webp": return "image/webp"
		"bmp": return "image/bmp"
		"mp4": return "video/mp4"
		"mov": return "video/quicktime"
		"webm": return "video/webm"
		_: return "application/octet-stream"



func _process(_dt: float) -> void :

	if _sending:
		return
	var remain: = _cooldown_until - Time.get_ticks_msec()
	if remain > 0:
		_send_btn.disabled = true
		_send_btn.text = "wait %ds" % int(ceil(remain / 1000.0))
	elif _send_btn.text != "send":
		_send_btn.text = "send"
		_send_btn.disabled = false

func _send() -> void :
	if _sending:
		return
	if Time.get_ticks_msec() < _cooldown_until:
		return
	if _text.text.strip_edges() == "":
		_set_status("write something first", UiStyle.RED)
		return
	if _kind == "bug" and _severity == "":
		_set_status("pick how bad the bug is first", UiStyle.RED)
		return
	if not Backend.configured():
		_set_status("reports aren't set up in this build", UiStyle.RED)
		return
	_sending = true
	_send_btn.disabled = true

	_ticket_id = Reports._uuid()
	_uploaded = 0
	_upload_next()


func _upload_next() -> void :
	if _uploaded >= _files.size():
		_submit()
		return
	var a: Dictionary = _files[_uploaded]
	_set_status("sending %d of %d files" % [_uploaded + 1, _files.size()], UiStyle.muted())
	Backend.api_call("ticket-file-put", {
		"ticket_id": _ticket_id, 
		"index": _uploaded, 
		"name": a["name"], 
		"data_base64": Marshalls.raw_to_base64(a["bytes"]), 
		"uploader_sid": _my_sid(), 
	}, func(code: int, json: Variant):
		if not is_inside_tree():
			return
		if code != 200:
			_failed(code, json)
			return
		_uploaded += 1
		_upload_next())

func _submit() -> void :
	_set_status("sending", UiStyle.muted())
	var fields: = {
		"ticket_id": _ticket_id, 
		"kind": _kind, 
		"type": _type, 
		"text": _text.text.strip_edges().substr(0, MAX_CHARS), 
		"sid": _my_sid(), 
		"name": Net.local_display_name(), 
		"meta": _meta(), 
	}
	if _kind == "bug":
		fields["severity"] = _severity
	Backend.api_call("submit-ticket", fields, func(code: int, json: Variant):
		if not is_inside_tree():
			return
		if code != 200:
			_failed(code, json)
			return
		_sending = false
		_cooldown_until = Time.get_ticks_msec() + COOLDOWN_MS
		_set_status("sent, thank you!", UiStyle.SUCCESS)
		_text.text = ""
		_files.clear()
		_rebuild_thumbs()
		_on_text_changed()
		_set_severity(""))

func _failed(code: int, json: Variant) -> void :
	_sending = false
	_send_btn.disabled = false
	var err: = ""
	if json is Dictionary:
		err = String((json as Dictionary).get("error", ""))
	if err == "tickets_disabled":
		_set_status("bug reports are down for maintenance right now, please try again later!", 
			UiStyle.RED)
	elif code == 429:
		_set_status("you've sent a lot of reports, please try again in a bit", UiStyle.RED)
	elif code == 413:
		_set_status("one of the files is too big, try a smaller one", UiStyle.RED)
	elif code == 0:
		_set_status("couldn't reach the server, check your connection", UiStyle.RED)
	else:
		_set_status("couldn't send that right now, please try again later! (%d)" % code, 
			UiStyle.RED)

func _my_sid() -> String:
	var sid: = Net.my_steam_id()
	return str(sid) if sid != 0 else ""




func _meta() -> Dictionary:
	var scene: = get_tree().current_scene
	return {
		"version": str(GameConfig.VERSION), 
		"os": "%s %s" % [OS.get_name(), OS.get_version()], 
		"locale": OS.get_locale(), 
		"display": _display_size(), 
		"gpu": RenderingServer.get_video_adapter_name(), 
		"renderer": str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")), 
		"scene": scene.scene_file_path.get_file() if scene != null else "", 


		"steam": "%s, app %d, launched as \"%s\"%s" % [
			Net.steam_status_text().get_slice("\n", 0), Net.steam_app_id(), 
			OS.get_environment("SteamAppId"), 
			", proton" if Net.running_under_proton() else ""], 


		"steam_error": Net.steam_init_error(), 



		"build": Net.steam_build_id(), 
		"proto": Net.PROTO, 
		"exe_time": FileAccess.get_modified_time(OS.get_executable_path()), 
	}

func _display_size() -> String:
	var s: = DisplayServer.window_get_size()
	return "%dx%d" % [s.x, s.y]

func _set_status(msg: String, color: Color) -> void :
	_status.text = msg
	_status.add_theme_color_override("font_color", color)

func _close() -> void :
	closed.emit()
	queue_free()

func _unhandled_input(event: InputEvent) -> void :
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()
