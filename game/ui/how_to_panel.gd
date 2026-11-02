class_name HowToPanel
extends PanelContainer


















const TEXT_PATH: = "res://game/ui/how_to_text.json"
const LIST_W: = 220.0
const BODY_PX: = 18
const GLYPH_PX: = 28

var _cats: Array = []
var _at: = 0
var _list: VBoxContainer
var _scroll: ScrollContainer
var _pages: VBoxContainer
var _buttons: Array[Button] = []




static func available() -> bool:
	return FileAccess.file_exists(TEXT_PATH)


static func closed_text() -> String:
	return "not in the demo" if LaunchGate.is_demo() else "coming soon"

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	set_meta("no_wash", true)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(760, 400)
	_cats = _read()



	visibility_changed.connect( func():
		if is_visible_in_tree():
			_ensure_built())
	if is_visible_in_tree():
		_ensure_built()
	var ip: = get_node_or_null("/root/InputPrompts")
	if ip != null:
		ip.connect("changed", _on_prompts_changed)

var _built: = false

func _ensure_built() -> void :
	if _built:
		return
	_built = true
	_build()

func _read() -> Array:
	if not available():
		return []
	var f: = FileAccess.open(TEXT_PATH, FileAccess.READ)
	if f == null:
		return []
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary and (d as Dictionary).get("categories") is Array:
		return (d as Dictionary)["categories"]
	return []

func category_names() -> Array:
	return _cats.map( func(c): return String((c as Dictionary).get("name", "")))

func current() -> int:
	return _at

func cycle_tab(step: int) -> void :
	if _cats.is_empty():
		return
	_ensure_built()
	show_category((_at + step + _cats.size()) % _cats.size())
	if _at < _buttons.size():
		_buttons[_at].grab_focus()

func scroll_to(y: int) -> void :
	_ensure_built()
	_scroll.scroll_vertical = y

func show_category(i: int) -> void :
	if i < 0 or i >= _cats.size():
		return
	_ensure_built()
	_fill_page(i)
	var changed: = i != _at
	_at = i
	for k in _pages.get_child_count():
		(_pages.get_child(k) as Control).visible = k == i
	for k in _buttons.size():
		_style_cat(_buttons[k], k == i)
	if changed:
		_scroll.scroll_vertical = 0
	_link_focus()



func _build() -> void :
	add_theme_stylebox_override("panel", _box(UiStyle.card(), UiStyle.RADIUS_SOFT, 16))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	add_child(row)
	_list = VBoxContainer.new()
	_list.custom_minimum_size.x = LIST_W
	_list.add_theme_constant_override("separation", 4)
	row.add_child(_list)
	var rule: = Panel.new()
	rule.custom_minimum_size.x = 2
	rule.add_theme_stylebox_override("panel", UiStyle.flat_box(UiStyle.hairline(), 1))
	row.add_child(rule)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	UiStyle.style_scroll(_scroll.get_v_scroll_bar())
	row.add_child(_scroll)
	var pad: = MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_right", 14)
	pad.add_theme_constant_override("margin_bottom", 8)
	_scroll.add_child(pad)
	_pages = VBoxContainer.new()
	_pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(_pages)
	if _cats.is_empty():
		var none: = Label.new()
		none.text = closed_text()
		UiStyle.style_label(none, "body", UiStyle.muted())
		_pages.add_child(none)
		return
	for i in _cats.size():
		var cat: Dictionary = _cats[i]
		var b: = Button.new()
		b.text = String(cat.get("name", ""))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size.y = 34
		b.pressed.connect(show_category.bind(i))

		b.focus_entered.connect( func():
			if _at != i:
				show_category(i))
		_list.add_child(b)
		_buttons.append(b)
		_pages.add_child(_stub())
	show_category(_at)



func _stub() -> Control:
	var s: = VBoxContainer.new()
	s.set_meta("stub", true)
	return s

func _fill_page(i: int) -> void :
	if i < 0 or i >= _pages.get_child_count() or i >= _cats.size():
		return
	var old: = _pages.get_child(i)
	if not old.has_meta("stub"):
		return
	var page: = _page(_cats[i] as Dictionary)
	page.visible = (old as Control).visible
	_pages.add_child(page)
	_pages.move_child(page, i)
	_pages.remove_child(old)
	old.queue_free()

func _style_cat(b: Button, on: bool) -> void :
	UiStyle.style_button(b, "blue" if on else "tertiary", 18)
	if not on:
		b.add_theme_color_override("font_color", UiStyle.text())
		b.add_theme_color_override("font_hover_color", UiStyle.text())
		b.add_theme_color_override("font_focus_color", UiStyle.text())

	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box: = b.get_theme_stylebox(st) as StyleBoxFlat
		if box != null:
			box.content_margin_top = 4.0
			box.content_margin_bottom = 5.0

func _page(cat: Dictionary) -> VBoxContainer:
	var v: = VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 12)
	for g in cat.get("groups", []):
		var group: Dictionary = g
		var head: = String(group.get("title", ""))

		if head != "" or can_edit():
			v.add_child(_heading(group, v.get_child_count() > 0))
		for s in group.get("sections", []):
			v.add_child(_card(s as Dictionary))
	return v

func _heading(group: Dictionary, gap: bool) -> Control:
	var text: = String(group.get("title", ""))
	var l: = Label.new()
	l.text = text if text != "" else "(no heading)"
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", UiStyle.text() if text != "" else UiStyle.muted())
	var out: Control = l
	if can_edit():


		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var e: = Button.new()
		e.text = "edit"
		e.focus_mode = Control.FOCUS_NONE
		e.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		UiStyle.style_button(e, "secondary", 14)
		e.pressed.connect(_edit_heading.bind(row, group))
		row.add_child(e)
		out = row
	if not gap:
		return out
	var m: = MarginContainer.new()
	m.add_theme_constant_override("margin_top", 10)
	m.add_child(out)
	return m



func _card(s: Dictionary) -> PanelContainer:
	var card: = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_ALL
	var idle: = _box(_well(), UiStyle.RADIUS, 16)
	var ring: = _box(_well(), UiStyle.RADIUS, 16)
	ring.set_border_width_all(3)
	ring.border_color = UiStyle.SECONDARY
	card.add_theme_stylebox_override("panel", idle)
	card.focus_entered.connect( func(): card.add_theme_stylebox_override("panel", ring))
	card.focus_exited.connect( func(): card.add_theme_stylebox_override("panel", idle))
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	card.add_child(v)
	var head: = HBoxContainer.new()
	v.add_child(head)
	var t: = Label.new()
	t.text = String(s.get("title", ""))
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", 
		UiStyle.SECONDARY.lightened(0.3) if UiStyle.dark else UiStyle.SECONDARY)
	head.add_child(t)
	if can_edit():
		var e: = Button.new()
		e.text = "edit"
		e.focus_mode = Control.FOCUS_NONE
		UiStyle.style_button(e, "secondary", 14)
		e.pressed.connect(_edit_card.bind(v, s))
		head.add_child(e)
	if String(s.get("image", "")) != "":
		var pic: = _picture(String(s["image"]))
		if pic != null:
			v.add_child(pic)
	for p in s.get("body", []):
		v.add_child(_text(String(p)))
	if s.get("table") is Array:
		v.add_child(_table(s["table"], false))
	if bool(s.get("controls", false)):
		v.add_child(_table(GuideTokens.controls_rows(), true))
	if String(s.get("tip", "")) != "":
		v.add_child(_text("[i]%s[/i]" % String(s["tip"]), UiStyle.muted()))
	return card




const PIC_MAX_H: = 420.0

static func load_picture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var abs: = ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs):
		return null
	var img: = Image.load_from_file(abs)
	return ImageTexture.create_from_image(img) if img != null else null

func _picture(path: String) -> Control:
	var t: = load_picture(path)
	if t == null:
		return null
	var ratio: = maxf(float(t.get_width()) / maxf(float(t.get_height()), 1.0), 0.3)
	var frame: = Panel.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", UiStyle.flat_box(Color.WHITE, UiStyle.RADIUS))
	frame.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.custom_minimum_size.y = 240.0


	frame.resized.connect( func():
		var h: = minf(frame.size.x / ratio, PIC_MAX_H)
		if absf(frame.custom_minimum_size.y - h) > 1.0:
			frame.custom_minimum_size.y = h)
	var tex: = TextureRect.new()
	tex.texture = t
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(tex)
	return frame

func _text(text: String, ink: = Color(0, 0, 0, 0), bold: = false, wrap: = true) -> RichTextLabel:
	var r: = RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.focus_mode = Control.FOCUS_NONE
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var c: = UiStyle.text() if ink.a == 0.0 else ink
	r.add_theme_font_override("normal_font", 
		UiStyle.font(UiStyle.FONT_BLACK if bold else UiStyle.FONT_SEMI))
	r.add_theme_font_override("bold_font", UiStyle.font(UiStyle.FONT_BLACK))
	r.add_theme_font_override("italics_font", UiStyle.font(UiStyle.FONT_SEMI))
	for k in ["normal_font_size", "bold_font_size", "italics_font_size"]:
		r.add_theme_font_size_override(k, BODY_PX)
	r.add_theme_color_override("default_color", c)
	GuideTokens.fill(r, text, GLYPH_PX, c)
	return r



func _table(rows: Array, controls: bool) -> GridContainer:
	var g: = GridContainer.new()
	var cols: = 1
	for r in rows:
		cols = maxi(cols, (r as Array).size())
	g.columns = cols
	g.add_theme_constant_override("h_separation", 22)
	g.add_theme_constant_override("v_separation", 8)
	for ri in rows.size():
		var cells: Array = rows[ri]
		for ci in cols:
			var txt: = String(cells[ci]) if ci < cells.size() else ""
			var head: = ri == 0
			var cell: = _text(txt, UiStyle.muted() if head else Color(0, 0, 0, 0), 
				head or (ci == 0 and not controls), not (controls and ci > 0))
			if controls and ci > 0:
				cell.size_flags_horizontal = Control.SIZE_FILL
				cell.custom_minimum_size.x = 150
			elif ci == 0:
				cell.size_flags_horizontal = Control.SIZE_FILL
				cell.custom_minimum_size.x = 210 if controls else 190
			g.add_child(cell)
	return g

func _well() -> Color:
	return Color(UiStyle.text(), 0.05)

func _box(fill: Color, radius: int, margin: float) -> StyleBoxFlat:
	var b: = UiStyle.flat_box(fill, radius)
	b.set_content_margin_all(margin)
	return b



func _link_focus() -> void :
	if _at >= _pages.get_child_count():
		return
	var page: = _pages.get_child(_at)
	var cards: = page.find_children("*", "PanelContainer", true, false)
	for b in _buttons:
		b.focus_neighbor_right = b.get_path_to(cards[0]) if not cards.is_empty() else NodePath()
	for c in cards:
		(c as Control).focus_neighbor_left = (c as Control).get_path_to(_buttons[_at])



func _on_prompts_changed() -> void :
	GuideTokens.gen += 1
	_rebuild()

func _rebuild() -> void :
	if _cats.is_empty() or not _built:
		return
	var y: = _scroll.scroll_vertical
	var had_focus: = get_viewport().gui_get_focus_owner()
	var on_list: = had_focus is Button and _buttons.has(had_focus as Button)
	for c in _pages.get_children():
		_pages.remove_child(c)
		c.queue_free()
	for cat in _cats:
		_pages.add_child(_stub())
	show_category(_at)
	if on_list:
		_buttons[_at].grab_focus()
	_scroll.set_deferred("scroll_vertical", y)






static func can_edit() -> bool:
	return OS.has_feature("editor") and not LaunchGate.public_beta()

const EDIT_HINT: = "a blank line starts a new paragraph.  keys: {kb:jump} = keyboard, {pad:jump} = controller, {key:jump} = whichever they're using.  [b]bold[/b]  [i]italic[/i]"

func _edit_card(v: VBoxContainer, s: Dictionary) -> void :
	for c in v.get_children():
		v.remove_child(c)
		c.queue_free()
	var title: = LineEdit.new()
	title.text = String(s.get("title", ""))
	UiStyle.style_line_edit(title)
	v.add_child(title)
	var body: = TextEdit.new()
	body.text = "\n\n".join(PackedStringArray(s.get("body", [])))
	body.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	body.custom_minimum_size.y = 260
	body.scroll_fit_content_height = true
	_style_edit(body)
	v.add_child(body)
	var table: TextEdit = null
	if s.get("table") is Array:
		var lines: PackedStringArray = []
		for r in s["table"]:
			lines.append(" | ".join(PackedStringArray(r)))
		table = TextEdit.new()
		table.text = "\n".join(lines)
		table.custom_minimum_size.y = 150
		table.scroll_fit_content_height = true
		_style_edit(table)
		var tl: = Label.new()
		tl.text = "table: one row a line, cells split by |, the first row is the header"
		UiStyle.style_label(tl, "small")
		v.add_child(tl)
		v.add_child(table)


	var pic: = {"path": String(s.get("image", ""))}
	var pic_row: = HBoxContainer.new()
	pic_row.add_theme_constant_override("separation", 10)
	var pic_name: = Label.new()
	pic_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pic_name.clip_text = true
	UiStyle.style_label(pic_name, "small")
	var pic_view: = VBoxContainer.new()
	var show_pic: = func():
		pic_name.text = "picture: " + (pic.path.get_file() if pic.path != "" else "none")
		for c in pic_view.get_children():
			pic_view.remove_child(c)
			c.queue_free()
		if pic.path != "":
			var shown: = _picture(pic.path)
			if shown != null:
				pic_view.add_child(shown)
	var pick: = Button.new()
	pick.text = "pick picture"
	UiStyle.style_button(pick, "secondary", 14)
	pick.pressed.connect( func():
		_pick_picture(String(s.get("sid", "pic")), func(res_path: String):
			pic.path = res_path
			show_pic.call()))
	var drop: = Button.new()
	drop.text = "no picture"
	UiStyle.style_button(drop, "tertiary", 14)
	drop.pressed.connect( func():
		pic.path = ""
		show_pic.call())
	pic_row.add_child(pic_name)
	pic_row.add_child(pick)
	pic_row.add_child(drop)
	v.add_child(pic_row)
	v.add_child(pic_view)
	show_pic.call()
	var hint: = Label.new()
	hint.text = EDIT_HINT
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(hint, "small")
	v.add_child(hint)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var save: = Button.new()
	save.text = "save"
	UiStyle.style_button(save, "primary", 16)
	var cancel: = Button.new()
	cancel.text = "cancel"
	UiStyle.style_button(cancel, "tertiary", 16)
	row.add_child(save)
	row.add_child(cancel)
	v.add_child(row)
	cancel.pressed.connect(_rebuild_keep_scroll)
	save.pressed.connect( func():
		s["title"] = title.text.strip_edges()
		var paras: Array = []

		var cur: PackedStringArray = []
		for line in body.text.split("\n"):
			if line.strip_edges() != "":
				cur.append(line.strip_edges())
			elif not cur.is_empty():
				paras.append(" ".join(cur))
				cur.clear()
		if not cur.is_empty():
			paras.append(" ".join(cur))
		s["body"] = paras
		if table != null:
			var rows: Array = []
			for line in table.text.split("\n"):
				if line.strip_edges() == "":
					continue
				var cells: Array = []
				for c in line.split("|"):
					cells.append(String(c).strip_edges())
				rows.append(cells)
			s["table"] = rows

		s["image"] = pic.path
		var ok: = save_words()
		print("how to play: saved %s (%s)" % [s.get("sid", s["title"]), "ok" if ok else "FAILED"])
		_rebuild_keep_scroll())
	body.grab_focus.call_deferred()


func _edit_heading(row: HBoxContainer, group: Dictionary) -> void :
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()
	var title: = LineEdit.new()
	title.text = String(group.get("title", ""))
	title.placeholder_text = "heading (leave empty for none)"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_line_edit(title)
	row.add_child(title)
	var save: = Button.new()
	save.text = "save"
	UiStyle.style_button(save, "primary", 16)
	var cancel: = Button.new()
	cancel.text = "cancel"
	UiStyle.style_button(cancel, "tertiary", 16)
	row.add_child(save)
	row.add_child(cancel)
	var commit: = func(_t: = ""):
		group["title"] = title.text.strip_edges()
		var ok: = save_words()
		print("how to play: saved heading '%s' (%s)" % [group["title"], "ok" if ok else "FAILED"])
		_rebuild_keep_scroll()
	save.pressed.connect(commit)
	title.text_submitted.connect(commit)
	cancel.pressed.connect(_rebuild_keep_scroll)
	title.grab_focus.call_deferred()

func _style_edit(te: TextEdit) -> void :
	te.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_SEMI))
	te.add_theme_font_size_override("font_size", 16)
	te.add_theme_color_override("font_color", UiStyle.text())
	te.add_theme_stylebox_override("normal", _box(UiStyle.card(), UiStyle.RADIUS, 10))
	te.add_theme_stylebox_override("focus", _box(UiStyle.card(), UiStyle.RADIUS, 10))

func _rebuild_keep_scroll() -> void :
	var y: = _scroll.scroll_vertical
	_rebuild()
	_scroll.set_deferred("scroll_vertical", y)


func save_words() -> bool:
	var f: = FileAccess.open(TEXT_PATH, FileAccess.WRITE)
	if f == null:
		push_error("how to play: can't write %s" % TEXT_PATH)
		return false
	f.store_string(JSON.stringify({"categories": _cats}, " ", false) + "\n")
	f.close()
	return true





const PICK_START: = "E:/3D Models 3.0/volleyballgame/howtoplay"
const SHOTS_DIR: = "res://game/ui/how_to_shots"
static var _last_dir: = ""


var pick_override: = Callable()

func _pick_picture(sid: String, done: Callable) -> void :
	if pick_override.is_valid():
		var res0: = import_picture(String(pick_override.call(sid)), sid)
		if res0 != "":
			done.call(res0)
		return
	var dlg: = FileDialog.new()
	dlg.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dlg.access = FileDialog.ACCESS_FILESYSTEM
	dlg.use_native_dialog = true
	dlg.title = "pick a picture"
	dlg.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; pictures"])
	var start: = _last_dir if _last_dir != "" else PICK_START
	if DirAccess.dir_exists_absolute(start):
		dlg.current_dir = start
	dlg.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(dlg)
	dlg.file_selected.connect( func(path: String):
		_last_dir = path.get_base_dir()
		var res: = import_picture(path, sid)
		if res != "":
			done.call(res)
		dlg.queue_free())
	dlg.canceled.connect(dlg.queue_free)
	dlg.popup_centered_ratio(0.6)




static func import_picture(src: String, sid: String) -> String:
	if not FileAccess.file_exists(src):
		return ""
	var ext: = src.get_extension().to_lower()
	var base: = src.get_file().get_basename().to_lower().replace(" ", "_")
	var dir_abs: = ProjectSettings.globalize_path(SHOTS_DIR)
	DirAccess.make_dir_recursive_absolute(dir_abs)
	var name: = "%s.%s" % [base, ext]
	var dest_abs: = dir_abs.path_join(name)
	if FileAccess.file_exists(dest_abs) and FileAccess.get_md5(dest_abs) != FileAccess.get_md5(src):
		name = "%s_%s.%s" % [sid.replace(".", "_"), base, ext]
		dest_abs = dir_abs.path_join(name)
	if not FileAccess.file_exists(dest_abs) or FileAccess.get_md5(dest_abs) != FileAccess.get_md5(src):
		if DirAccess.copy_absolute(src, dest_abs) != OK:
			push_error("how to play: couldn't copy %s" % src)
			return ""
	return SHOTS_DIR.path_join(name)
