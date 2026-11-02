extends Control
























signal closed
signal shop_pressed(shelf: String)

const TITLES: = preload("res://game/titles/title_catalog.gd")
const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")
const NAME_PILL: = preload("res://game/ui/title_name_pill.gd")

const CARD_W: = 820.0
const LIST_H: = 300.0
const TITLE_COLS: = 3
const TITLE_SORTS: = ["a to z", "z to a", "newest first"]
const COURT: = Color("7fb4e6")
const TABS: Array[String] = ["title", "look", "effect"]
const SAMPLE: = "your title"

var changed: = false

var _id: = ""
var _look: = {}
var _plate_on: = true
var _tab: = "title"
var _closing: = false

var _pill: NAME_PILL
var _tab_btns: = {}
var _pages: = {}
var _title_btns: = {}
var _case_btns: Array = []
var _fx_btns: = {}
var _props: VBoxContainer
var _plate_check: CheckBox
var _thick: HSlider
var _thick_read: Label
var _first: Control
var _held: Control
var _search: LineEdit
var _sort: = 0
var _none_lbl: Label
var _title_bar: VBoxContainer

func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	var worn: Dictionary = TITLES.equipped()
	_id = str(worn.get("id", ""))
	_look = TITLES.saved_look()
	_plate_on = Color(str(_look["bg"])).a > 0.0
	_build()
	_show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.16)
	_drop_hover.call_deferred()
	get_viewport().gui_focus_changed.connect(_keep_focus)

	if not InputPrompts._pointer and _first != null:
		_first.grab_focus.call_deferred()

func _exit_tree() -> void :
	if get_viewport().gui_focus_changed.is_connected(_keep_focus):
		get_viewport().gui_focus_changed.disconnect(_keep_focus)







func _keep_focus(to: Control) -> void :
	if _closing:
		return
	if to == self or is_ancestor_of(to):
		_held = to
		return


	if InputPrompts._pointer:
		to.release_focus.call_deferred()
		return
	var back: Control = _held if is_instance_valid(_held) and _held.is_inside_tree()\
	and _held.is_visible_in_tree() else _first
	if is_instance_valid(back) and back.is_inside_tree():
		back.grab_focus.call_deferred()




func _drop_hover() -> void :
	var ev: = InputEventMouseMotion.new()
	ev.position = get_viewport().get_mouse_position()
	ev.global_position = ev.position
	get_viewport().push_input(ev, true)



func _build() -> void :
	var veil: = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(UiStyle.INK, 0.62)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card: = PanelContainer.new()
	card.name = "Card"
	card.custom_minimum_size.x = CARD_W
	var fsb: = UiStyle.field_box()
	fsb.set_content_margin_all(20)
	card.add_theme_stylebox_override("panel", fsb)
	center.add_child(card)
	UiStyle.field_doodles(card)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	var st: = UiStyle.sticker("medal2", UiStyle.SECONDARY, 50, -0.08)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(st)
	var word: = Label.new()
	word.text = "title"
	word.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	word.add_theme_font_size_override("font_size", 32)
	word.add_theme_color_override("font_color", UiStyle.text() if UiStyle.dark else UiStyle.INK)
	word.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(word)
	var x: = UiStyle.icon_button("cross", "exit", 40)
	x.name = "Close"
	x.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	x.pressed.connect(close)
	head.add_child(x)
	v.add_child(head)


	var band: = PanelContainer.new()
	band.add_theme_stylebox_override("panel", UiStyle.flat_box(COURT, 22))
	band.custom_minimum_size.y = 104
	var bc: = CenterContainer.new()
	band.add_child(bc)
	_pill = NAME_PILL.new()
	_pill.name = "Preview"
	bc.add_child(_pill)
	v.add_child(band)


	var tabs: = HBoxContainer.new()
	tabs.name = "Tabs"
	tabs.add_theme_constant_override("separation", 8)
	for tab in TABS:
		var b: = Button.new()
		b.name = "Tab_" + tab
		b.text = tab
		b.custom_minimum_size = Vector2(120, 40)
		b.pressed.connect( func(): _open_tab(tab))
		_tab_btns[tab] = b
		tabs.add_child(b)
	v.add_child(tabs)

	var sheet: = PanelContainer.new()
	var ssb: = UiStyle.card_box(UiStyle._AUTO, 22)
	ssb.set_content_margin_all(14)
	sheet.add_theme_stylebox_override("panel", ssb)
	v.add_child(sheet)
	var pages: = VBoxContainer.new()
	pages.add_theme_constant_override("separation", 10)
	sheet.add_child(pages)


	_title_bar = VBoxContainer.new()
	_title_bar.name = "TitleBar"
	_title_bar.add_theme_constant_override("separation", 10)
	pages.add_child(_title_bar)
	for tab in TABS:
		var scroll: = ScrollContainer.new()
		scroll.name = "Page_" + tab
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.custom_minimum_size.y = LIST_H
		scroll.follow_focus = true
		UiStyle.style_scroll(scroll.get_v_scroll_bar())
		var inner: = MarginContainer.new()
		inner.add_theme_constant_override("margin_right", 16)
		inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var body: = VBoxContainer.new()
		body.add_theme_constant_override("separation", 12)
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.add_child(body)
		scroll.add_child(inner)
		_pages[tab] = scroll
		pages.add_child(scroll)
		match tab:
			"title":
				_build_titles(body)
			"look":
				_build_look(body)
			"effect":
				_build_effects(body)


	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	var reset: = Button.new()
	reset.name = "Reset"
	reset.text = "reset look"
	UiStyle.style_button(reset, "secondary", 15)
	reset.pressed.connect( func():
		_look = TITLES.default_look()
		_plate_on = true
		_save()
		_rebuild.call_deferred())
	foot.add_child(reset)
	var gap: = Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(gap)
	var done: = Button.new()
	done.name = "Done"
	done.text = "done"
	UiStyle.style_button(done, "blue", 18)
	done.custom_minimum_size.x = 150
	done.pressed.connect(close)
	foot.add_child(done)
	v.add_child(foot)


	done.focus_neighbor_left = done.get_path_to(reset)
	reset.focus_neighbor_right = reset.get_path_to(done)
	_open_tab(_tab)



func _build_titles(v: VBoxContainer) -> void :
	var owned: Array = TITLES.owned()

	var cases: = HBoxContainer.new()
	cases.name = "Cases"
	cases.add_theme_constant_override("separation", 8)
	var cl: = _caption("written")
	cl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cl.custom_minimum_size.x = 70
	cases.add_child(cl)
	_case_btns.clear()
	for i in TITLES.CASE_NAMES.size():
		var b: = Button.new()
		b.name = "Case_%d" % i
		b.text = TITLES.CASE_NAMES[i]
		b.pressed.connect( func():
			_look["cs"] = i
			_save())
		_case_btns.append(b)
		cases.add_child(b)
	_title_bar.add_child(cases)

	var tools: = HBoxContainer.new()
	tools.name = "Tools"
	tools.add_theme_constant_override("separation", 8)
	_search = LineEdit.new()
	_search.name = "Search"
	_search.placeholder_text = "search your titles"
	_search.clear_button_enabled = true
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.custom_minimum_size.y = 38
	UiStyle.style_line_edit(_search)
	_search.text_changed.connect( func(_t: String): _filter_titles())
	tools.add_child(_search)
	var sort: = UiSelect.new(TITLE_SORTS)
	sort.name = "Sort"
	sort.selected = _sort
	sort.custom_minimum_size = Vector2(150, 38)
	sort.picked.connect( func(i: int):
		_sort = i
		_order_titles())
	tools.add_child(sort)
	_title_bar.add_child(tools)

	var grid: = GridContainer.new()
	grid.name = "Titles"
	grid.columns = TITLE_COLS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	grid.add_child(_title_button("", "none"))


	var prof: = ProfileStore.active()
	var book: Array = prof.owned.keys() if prof != null else []
	for item in owned:
		var b: = _title_button(item.id, item.text.to_lower())
		b.set_meta("at", book.find(TITLES.own_key(item.id)))
		grid.add_child(b)
	_none_lbl = Label.new()
	_none_lbl.name = "NoneFound"
	_none_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.style_label(_none_lbl, "body", UiStyle.muted())
	_none_lbl.visible = false
	v.add_child(_none_lbl)
	_order_titles()
	_first = _title_btns[_id] if _title_btns.has(_id) else _title_btns[""]



	if TITLES.shop_open():
		v.add_child(_more_row("Shop", "titles", "you don't own any titles yet" if owned.is_empty()
			else "%d of %d owned" % [owned.size(), TITLES.all().size() - _locked_away()]))


func _filter_titles() -> void :
	var needle: = _search.text.strip_edges().to_lower() if _search != null else ""
	var shown: = 0
	for id in _title_btns:
		var b: Button = _title_btns[id]
		var on: bool = id == "" or needle == "" or b.text.to_lower().contains(needle)
		b.visible = on
		if on and id != "":
			shown += 1
	if _none_lbl != null:
		_none_lbl.visible = needle != "" and shown == 0
		_none_lbl.text = "no title matches \"%s\"" % needle

func _order_titles() -> void :
	var grid: = find_child("Titles", true, false) as GridContainer
	if grid == null:
		return
	var tiles: Array = []
	for c in grid.get_children():
		if c != _title_btns.get("", null):
			tiles.append(c)
	match _sort:
		0:
			tiles.sort_custom( func(a, b): return String(a.text).naturalnocasecmp_to(String(b.text)) < 0)
		1:
			tiles.sort_custom( func(a, b): return String(a.text).naturalnocasecmp_to(String(b.text)) > 0)
		2:
			tiles.sort_custom( func(a, b): return int(a.get_meta("at", 0)) > int(b.get_meta("at", 0)))

	var worn: Variant = _title_btns.get(_id, null) if _id != "" else null
	if worn != null:
		tiles.erase(worn)
		tiles.push_front(worn)
	for i in tiles.size():
		grid.move_child(tiles[i], i + 1)
	_filter_titles()



func _build_look(v: VBoxContainer) -> void :
	var colours: = HBoxContainer.new()
	colours.add_theme_constant_override("separation", 22)
	colours.add_child(_colour("letters", "fg"))
	colours.add_child(_colour("plate", "bg"))
	colours.add_child(_colour("outline", "ol"))
	_plate_check = CheckBox.new()
	_plate_check.name = "PlateOn"
	_plate_check.text = "plate"
	_plate_check.button_pressed = _plate_on
	UiStyle.style_check(_plate_check)
	_plate_check.size_flags_vertical = Control.SIZE_SHRINK_END
	_plate_check.toggled.connect( func(on: bool):
		_plate_on = on
		_set_plate(Color(str(_look["bg"]))))
	colours.add_child(_plate_check)
	v.add_child(colours)
	var trow: = HBoxContainer.new()
	trow.add_theme_constant_override("separation", 12)
	var tl: = _caption("outline thickness")
	tl.custom_minimum_size.x = 150
	tl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	trow.add_child(tl)
	_thick = HSlider.new()
	_thick.name = "Thickness"
	_thick.min_value = 0
	_thick.max_value = TITLES.THICK_MAX
	_thick.step = 1
	_thick.value = int(_look["th"])
	_thick.custom_minimum_size = Vector2(220, 20)
	_thick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_thick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_slider(_thick)
	_thick.value_changed.connect( func(value: float):
		_look["th"] = int(value)
		_save())
	trow.add_child(_thick)
	_thick_read = Label.new()
	_thick_read.custom_minimum_size.x = 26
	_thick_read.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UiStyle.style_label(_thick_read, "body")
	trow.add_child(_thick_read)
	v.add_child(trow)



func _build_effects(v: VBoxContainer) -> void :
	v.add_child(_caption("your effects"))
	var owned: Array = TITLES.owned_effects()
	var grid: = GridContainer.new()
	grid.name = "Effects"
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	grid.add_child(_fx_tile(null))
	for fx in owned:
		grid.add_child(_fx_tile(fx))
	_props = VBoxContainer.new()
	_props.name = "EffectSettings"
	_props.add_theme_constant_override("separation", 10)
	v.add_child(_props)
	_build_props()
	if TITLES.shop_open():
		v.add_child(_more_row("ShopFx", "effects", "you don't own any effects yet" if owned.is_empty()
			else "%d of %d owned" % [owned.size(), TITLES.effects().size()]))


func _fx_tile(fx: Resource) -> Button:
	var id: String = fx.id if fx != null else ""
	var b: = Button.new()
	b.name = "Fx_" + (id if id != "" else "none")
	b.custom_minimum_size = Vector2(0, 58)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect( func():
		_look["fx"] = id
		_look.erase("fp")
		_look.erase("ac")
		_look = TITLES.clean_look(_look)
		_save()
		_build_props())
	var seat: = CenterContainer.new()
	seat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var chip: = TITLE_CHIP.new()
	chip.name = "Chip"
	seat.add_child(chip)
	b.add_child(seat)
	_fx_btns[id] = b
	return b


func _dress_tile(id: String) -> void :
	var chip: = (_fx_btns[id] as Button).find_child("Chip", true, false) as TITLE_CHIP
	var look: = _look.duplicate(true)
	look["fx"] = id
	look.erase("fp")
	look.erase("ac")
	look = TITLES.clean_look(look)
	if Color(str(look["bg"])).a <= 0.0 and id == "":
		look["bg"] = UiStyle.PRIMARY.to_html(true)
	var fx: Resource = TITLES.effect(id)
	chip.show_style(look, 15, String(fx.label) if fx != null else "none")


func _build_props() -> void :
	for c in _props.get_children():
		_props.remove_child(c)
		c.queue_free()
	var fx: Resource = TITLES.effect(str(_look.get("fx", "")))
	if fx == null:
		return
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	var name_l: = _caption("%s settings" % fx.label)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(name_l)
	if fx.suit_bg != "" or fx.suit_fg != "":
		var suit: = Button.new()
		suit.name = "ItsColours"
		suit.text = "its colors"
		UiStyle.style_button(suit, "secondary", 13)
		suit.pressed.connect( func():
			_look = TITLES.suited(_look, fx)
			_plate_on = Color(str(_look["bg"])).a > 0.0
			_save()
			_rebuild.call_deferred())
		head.add_child(suit)
	_props.add_child(head)
	var given: Array = _look.get("fp", [])
	for i in mini(fx.knobs.size(), TITLES.KNOB_MAX):
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var l: = _caption(fx.knobs[i])
		l.custom_minimum_size.x = 150
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(l)
		var opts: PackedStringArray = fx.options(i)
		if not opts.is_empty():

			var now_v: = int(given[i]) if i < given.size() else roundi(fx.knob_default(i) * 100.0)
			var picked: int = fx.option_at(i, now_v / 100.0)
			for k in opts.size():
				var b: = Button.new()
				b.name = "Knob_%d_%d" % [i, k]
				b.text = opts[k]
				UiStyle.style_button(b, "primary" if k == picked else "secondary", 13)
				b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				b.pressed.connect( func():
					var vals: Array = (_look.get("fp", []) as Array).duplicate()
					while vals.size() <= i:
						vals.append(roundi(fx.knob_default(vals.size()) * 100.0))
					vals[i] = fx.option_value(i, k)
					_look["fp"] = vals
					_save()
					_build_props.call_deferred())
				row.add_child(b)
			_props.add_child(row)
			continue
		var s: = HSlider.new()
		s.name = "Knob_%d" % i
		s.min_value = 0
		s.max_value = 100
		s.step = 5
		s.value = int(given[i]) if i < given.size() else roundi(fx.knob_default(i) * 100.0)
		s.custom_minimum_size = Vector2(220, 20)
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		UiStyle.style_slider(s)
		s.value_changed.connect( func(value: float):
			var vals: Array = (_look.get("fp", []) as Array).duplicate()
			while vals.size() <= i:
				vals.append(roundi(fx.knob_default(vals.size()) * 100.0))
			vals[i] = int(value)
			_look["fp"] = vals
			_save())
		row.add_child(s)
		_props.add_child(row)
	if fx.accent != "":
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var l: = _caption(fx.accent)
		l.custom_minimum_size.x = 150
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(l)
		var field: = UiStyle.color_field(Color(str(_look.get("ac", fx.accent_default.to_html(false)))), func(c: Color):
			_look["ac"] = c.to_html(false)
			_save())
		field.name = "Colour_ac"
		row.add_child(field)
		_props.add_child(row)



func _locked_away() -> int:
	var n: = 0
	for item in TITLES.all():
		if item.exclusive and not TITLES.owns(item):
			n += 1
	return n


func _more_row(button_name: String, shelf: String, says: String) -> Control:
	var more: = HBoxContainer.new()
	more.add_theme_constant_override("separation", 10)
	var hint: = Label.new()
	hint.text = says
	UiStyle.style_label(hint, "small", UiStyle.muted())
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	more.add_child(hint)
	var shop: = Button.new()
	shop.name = button_name
	shop.text = "get more"
	UiStyle.style_button(shop, "secondary", 14)
	shop.pressed.connect( func():
		shop_pressed.emit(shelf)
		close())
	more.add_child(shop)
	return more



func _rebuild() -> void :
	var ringed: = get_viewport().gui_get_focus_owner() != null
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_title_btns.clear()
	_title_bar = null
	_fx_btns.clear()
	_tab_btns.clear()
	_pages.clear()
	_build()
	_show()

	_held = null
	if ringed and not InputPrompts._pointer:
		(_tab_btns[_tab] as Control).grab_focus.call_deferred()

func _open_tab(tab: String) -> void :
	_tab = tab
	for name_ in _pages:
		(_pages[name_] as Control).visible = name_ == tab
	if _title_bar != null:
		_title_bar.visible = tab == "title"
	for name_ in _tab_btns:
		UiStyle.paint_field_tab(_tab_btns[name_], name_ == tab, 16)

func _caption(text_in: String) -> Label:
	var l: = Label.new()
	l.text = text_in
	UiStyle.style_label(l, "small", UiStyle.muted())
	return l

func _title_button(id: String, text_in: String) -> Button:
	var b: = Button.new()
	b.name = "Title_" + (id if id != "" else "none")
	b.text = text_in
	b.tooltip_text = text_in

	b.custom_minimum_size = Vector2(0, 44)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	b.clip_text = true
	b.pressed.connect( func():
		_id = id
		_save())
	_title_btns[id] = b
	return b


func _colour(text_in: String, key: String) -> Control:
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	box.add_child(_caption(text_in))
	var start: = Color(str(_look[key]))
	var field: = UiStyle.color_field(Color(start, 1.0), func(c: Color):
		if key == "bg":
			_set_plate(c)
		else:
			_look[key] = c.to_html(false)
			_save())
	field.name = "Colour_" + key
	box.add_child(field)
	return box


func _set_plate(c: Color) -> void :
	_look["bg"] = Color(c, 1.0 if _plate_on else 0.0).to_html(true)
	_save()



func _save() -> void :
	TITLES.equip(_id, _look)
	_look = TITLES.saved_look()
	changed = true
	_show()


func _show() -> void :
	var prof: = ProfileStore.active()
	var who: String = prof.name if prof != null else Net.local_display_name()
	var style: = _look.duplicate(true)
	style["id"] = _id

	_pill.show_name(who, style, 32, true, "" if _id != "" else TITLES.cased(SAMPLE, int(_look.get("cs", 0))))
	_pill.modulate.a = 1.0 if _id != "" else 0.55
	for id in _title_btns:
		_paint_tile(_title_btns[id], id == _id, 15)
	for i in _case_btns.size():
		UiStyle.style_button(_case_btns[i], "blue" if i == int(_look.get("cs", 0)) else "secondary", 14)
	var worn_fx: = str(_look.get("fx", ""))
	for id in _fx_btns:
		_paint_tile(_fx_btns[id], id == worn_fx, 15)
		_dress_tile(id)
	_thick_read.text = str(int(_look["th"]))

	var fx: Resource = TITLES.effect(worn_fx)
	_plate_check.disabled = fx != null and fx.shader != null



func _paint_tile(b: Button, lit: bool, fs: int) -> void :
	UiStyle.style_button(b, "secondary", fs)
	var box: = UiStyle.flat_box(UiStyle.card() if lit else UiStyle.sunk(), 14)
	if lit:
		box.set_border_width_all(3)
		box.border_color = UiStyle.SECONDARY
	box.content_margin_left = 10.0
	box.content_margin_right = 10.0
	var hov: = box.duplicate() as StyleBoxFlat
	hov.bg_color = box.bg_color.lerp(UiStyle.SECONDARY, 0.1)
	for st in ["normal", "disabled"]:
		b.add_theme_stylebox_override(st, box)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	var ring: = box.duplicate() as StyleBoxFlat
	ring.set_border_width_all(3)
	ring.border_color = UiStyle.SECONDARY
	b.add_theme_stylebox_override("focus", ring)
	var c: = (UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY) if lit else UiStyle.text()
	for st in ["font_color", "font_hover_color", "font_pressed_color", 
			"font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(st, c)
	UiStyle.hover_grow(b, 1.05)



func close() -> void :
	if _closing:
		return
	_closing = true
	closed.emit()
	var t: = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.12)
	t.tween_callback(queue_free)

func _input(event: InputEvent) -> void :

	if LocalPlayers.consume_foreign_ui(event):
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel") and not _picker_open():
		get_viewport().set_input_as_handled()
		close()
		return

	for pair in [["menu_zone_next", 1], ["menu_zone_prev", -1]]:
		if event.is_action_pressed(pair[0]) and not _picker_open():
			get_viewport().set_input_as_handled()
			_open_tab(TABS[posmod(TABS.find(_tab) + int(pair[1]), TABS.size())])
			(_tab_btns[_tab] as Control).grab_focus()
			UiStyle.sfx("hover")
			return






	if _picker_open():
		return
	for action in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_focus_next", "ui_focus_prev", "ui_accept"]:
		if event.is_action_pressed(action):
			var at: = get_viewport().gui_get_focus_owner()
			if at == null or not (at == self or is_ancestor_of(at)):
				var stand: Control = _held if is_instance_valid(_held) and _held.is_inside_tree()\
				and _held.is_visible_in_tree() else (_tab_btns[_tab] as Control)
				if is_instance_valid(stand):
					stand.grab_focus.call_deferred()
			return

func _picker_open() -> bool:
	for key in ["fg", "bg", "ol", "ac"]:
		var field: = find_child("Colour_" + key, true, false) as ColorPickerButton
		if field != null and field.get_popup().visible:
			return true
	return false
