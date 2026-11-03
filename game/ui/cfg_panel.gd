class_name CfgPanel
extends PanelContainer
















enum State{EMPTY, JOINING, IDLE, SUBMENU, OFF}

const STAGE_MIN_H: = 220
const HEAD_H: = 36
const ROW_H: = 28
const LEAVE_HOLD: = 0.6
const JOIN_SETTLE: = 0.25
const NOTICE_S: = 1.5

const CAM_FOV: = 10.0
const CAM_DIST: = 12.4
const CAM_LOOK: = Vector3(0.0, 1.0, 0.0)

var index: = 0
var slot: LocalPlayerSlot = null
var slot_ls: = -1
var state: = State.EMPTY

var menu_hooks: = {}



var p1_locked: = false
const P1_LOCKED_SAYS: = "player 1's profile stays for this match"

func _p1_locked() -> bool:
	if index == 0 and p1_locked:
		notice(P1_LOCKED_SAYS)
		return true
	return false


var sub: SubViewport = null
var cam: Camera3D = null
var pc: PresentationCharacter = null
var _stage: TextureRect = null
var _look_key: = 0


var _head: PanelContainer = null
var _head_box: StyleBoxFlat = null
var _tag_box: StyleBoxFlat = null
var _tag: Label = null
var _status: Label = null
var _crown: Control = null
var _name_head: Label = null
var outfit: = "gym"
var _rows: = {}
var _row_vals: = {}
var _empty_box: VBoxContainer = null
var _empty_icon: TextureRect = null
var _empty_text: Label = null
var _empty_sub: Label = null
var _overlay: PanelContainer = null
var _overlay_kind: = ""
var _overlay_body: Control = null
var _rebind: SeatRebind = null
var _notice: Label = null
var _notice_left: = 0.0
var _notice_pinned: = false
var _remove_btn: Button = null
var _frame_box: StyleBoxFlat = null


var _reader: DeviceInput = null
var _cursor: = 0
var _held: = ""
var _repeat: = 0.0
var _cancel_held: = 0.0
var _join_t: = 0.0
var _list_cursor: = 0
var _list_rows: Array = []
var _list_actions: Array = []


var _pending: LocalPlayerSlot = null
var _has_pending: = false
var _want_live: = false

const ROW_KEYS: = ["profile", "device", "controls", "settings", "title"]
const TITLES: = preload("res://game/titles/title_catalog.gd")
var _list_steps: Array = []


func _row_keys() -> Array:
	return ROW_KEYS.filter( func(k): return k != "title" or TITLES.usable())
const OUTFITS: = ["gym", "captain"]

func _ready() -> void :
	clip_contents = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL



	custom_minimum_size = Vector2(220, 470)
	_frame_box = StyleBoxFlat.new()
	_frame_box.set_corner_radius_all(16)
	_frame_box.set_border_width_all(2)
	_frame_box.set_content_margin_all(0)
	add_theme_stylebox_override("panel", _frame_box)
	_build()



	if not MobileRender.enabled():
		_build_stage3d.call_deferred()
	bind(null)



func _build() -> void :
	var stack: = Control.new()
	stack.name = "Stack"
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)
	var body: = VBoxContainer.new()
	body.name = "Body"
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.add_theme_constant_override("separation", 0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(body)

	_head = PanelContainer.new()
	_head.custom_minimum_size.y = HEAD_H
	_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_head_box = StyleBoxFlat.new()
	_head_box.corner_radius_top_left = 13
	_head_box.corner_radius_top_right = 13
	_head_box.content_margin_left = 12.0
	_head_box.content_margin_right = 12.0
	_head_box.content_margin_top = 4.0
	_head_box.content_margin_bottom = 4.0
	_head.add_theme_stylebox_override("panel", _head_box)
	body.add_child(_head)
	var hrow: = HBoxContainer.new()
	hrow.add_theme_constant_override("separation", 8)
	hrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_head.add_child(hrow)
	_tag = Label.new()
	_tag.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_tag.add_theme_font_size_override("font_size", 22)
	_tag.add_theme_color_override("font_color", Color.WHITE)
	var tag_pill: = PanelContainer.new()
	_tag_box = StyleBoxFlat.new()
	_tag_box.bg_color = UiStyle.SECONDARY
	_tag_box.set_corner_radius_all(16)
	_tag_box.content_margin_left = 10.0
	_tag_box.content_margin_right = 10.0
	_tag_box.content_margin_top = 1.0
	_tag_box.content_margin_bottom = 1.0
	tag_pill.add_theme_stylebox_override("panel", _tag_box)
	tag_pill.add_child(_tag)
	hrow.add_child(tag_pill)
	_crown = RosterTile.HostMark.new()
	_crown.custom_minimum_size = Vector2(16, 16)
	_crown.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hrow.add_child(_crown)

	_name_head = Label.new()
	_name_head.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_name_head.add_theme_font_size_override("font_size", 15)
	_name_head.add_theme_color_override("font_color", UiStyle.INK)
	_name_head.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_name_head.visible = false


	hrow.add_child(_name_head)
	var spring: = Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hrow.add_child(spring)
	_status = Label.new()
	_status.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", UiStyle.muted())
	_status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hrow.add_child(_status)

	_stage = TextureRect.new()
	_stage.name = "Stage"
	_stage.custom_minimum_size.y = STAGE_MIN_H
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stage.stretch_mode = TextureRect.STRETCH_SCALE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(_stage)


	_stage.resized.connect(_sync_stage_size)

	_empty_box = VBoxContainer.new()
	_empty_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_empty_box.add_theme_constant_override("separation", 8)
	_empty_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_empty_box)
	_empty_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_empty_icon = TextureRect.new()
	_empty_icon.texture = UiStyle.icon("gamepad", false, true)
	_empty_icon.custom_minimum_size = Vector2(0, 92)
	_empty_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_empty_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_empty_box.add_child(_empty_icon)
	_empty_text = Label.new()
	_empty_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_text.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	_empty_text.add_theme_font_size_override("font_size", 18)
	_empty_text.add_theme_color_override("font_color", UiStyle.INK)
	_empty_box.add_child(_empty_text)
	_empty_sub = Label.new()
	_empty_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiStyle.style_label(_empty_sub, "small", UiStyle.muted())
	_empty_box.add_child(_empty_sub)



	var rows: = VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(rows)
	var pad: = MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 12)
	pad.add_theme_constant_override("margin_right", 12)
	pad.add_theme_constant_override("margin_top", 4)
	pad.add_theme_constant_override("margin_bottom", 4)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(pad)
	var rv: = VBoxContainer.new()
	rv.add_theme_constant_override("separation", 2)
	rv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(rv)




	for key in ["profile", "device"]:
		var group: = VBoxContainer.new()
		group.add_theme_constant_override("separation", 2)
		group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var r: = _make_row(String(key))
		group.add_child(r)
		rv.add_child(group)
		_rows[key] = r
		_rows["%s_group" % key] = group
		if key == "profile":
			var profile_link: = _make_quick_link("+  create profile", _create_profile)
			profile_link.name = "CreateProfile"
			profile_link.custom_minimum_size.y = 20
			rv.add_child(profile_link)
			_rows["create_profile"] = profile_link

	var action_row: = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)



	for key in ["controls", "settings", "title"]:
		var r: = _make_row(key)
		if key == "title":
			r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var tv: = _row_vals[key] as Label
			tv.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			tv.clip_text = false
			tv.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		else:
			r.size_flags_horizontal = Control.SIZE_FILL
			r.custom_minimum_size.x = 46
			r.tooltip_text = "edit controls" if key == "controls" else "your settings"
			(_row_vals[key] as Label).visible = false
			var hbox: = r.get_child(r.get_child_count() - 1) as HBoxContainer
			if hbox != null:
				hbox.alignment = BoxContainer.ALIGNMENT_CENTER
				hbox.offset_left = 0.0
				hbox.offset_right = 0.0
		action_row.add_child(r)
		_rows[key] = r
	if index > 0:
		var leave_hint: = HBoxContainer.new()
		leave_hint.add_theme_constant_override("separation", 4)
		leave_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var b_badge: = PanelContainer.new()
		var b_box: = StyleBoxFlat.new()
		b_box.bg_color = Color("e5484d")
		b_box.set_corner_radius_all(11)
		b_box.set_content_margin_all(4.0)
		b_badge.add_theme_stylebox_override("panel", b_box)
		var b_text: = Label.new()
		b_text.text = "B"
		UiStyle.style_label(b_text, "small", Color.WHITE)
		b_badge.add_child(b_text)
		leave_hint.add_child(b_badge)
		leave_hint.tooltip_text = "hold B to leave"
		action_row.add_child(leave_hint)
	rv.add_child(action_row)
	_rows["actions"] = action_row
	if index == 0:
		_wire_p1_focus()

	_remove_btn = Button.new()
	_remove_btn.text = "remove player"
	UiStyle.style_button(_remove_btn, "tertiary", 14)
	_remove_btn.add_theme_color_override("font_color", Color("e5484d"))
	_remove_btn.focus_mode = Control.FOCUS_NONE
	_remove_btn.visible = false
	_remove_btn.pressed.connect( func(): _leave())
	rv.add_child(_remove_btn)

	_overlay = PanelContainer.new()
	_overlay.name = "Overlay"
	_overlay.visible = false
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.anchor_left = 0.0
	_overlay.anchor_top = 0.0
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.offset_left = 8.0
	_overlay.offset_top = 120.0
	_overlay.offset_right = -8.0
	_overlay.offset_bottom = -8.0
	stack.add_child(_overlay)

	_notice = Label.new()
	UiStyle.style_pill(_notice, Color(0.0, 0.0, 0.0, 0.9), Color.WHITE, 14)
	_notice.visible = false
	_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_notice)

func _build_stage3d() -> void :
	sub = SubViewport.new()
	sub.name = "Stage3D"
	sub.own_world_3d = true
	sub.transparent_bg = true
	sub.handle_input_locally = false
	sub.render_target_update_mode = SubViewport.UPDATE_DISABLED
	sub.positional_shadow_atlas_size = 0
	sub.msaa_3d = Viewport.MSAA_DISABLED if MobileRender.enabled() else Viewport.MSAA_2X
	_stage.add_child(sub)
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.5
	env.environment = e
	sub.add_child(env)
	var key: = OmniLight3D.new()
	key.name = "Key"
	key.position = Vector3(1.8, 3.4, 2.6)
	key.light_color = Color(1.0, 0.94, 0.85)
	key.light_energy = 1.3
	key.omni_range = 16.0
	key.shadow_enabled = false
	sub.add_child(key)
	cam = Camera3D.new()
	cam.fov = CAM_FOV
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	sub.add_child(cam)
	cam.position = CAM_LOOK + Vector3(0.0, 0.0, CAM_DIST)
	cam.look_at(CAM_LOOK)
	cam.current = true
	pc = PresentationCharacter.new()
	pc.name = "Body"
	sub.add_child(pc)
	pc.setup(CharacterConfig.random(), GameConfig.team_kit(true))
	pc.player.set_name_visible(false)
	pc.player.charge_ui_enabled = false
	pc.player.indicator_enabled = false
	pc.face(0.0)
	pc.gaze_at(cam.position)
	pc.set_process(false)
	_stage.texture = sub.get_texture()
	_sync_stage_size()

	if _has_pending:
		_has_pending = false
		bind(_pending)
	if _want_live:
		set_live(true)



func _sync_stage_size() -> void :
	if sub == null or _stage == null:
		return
	var k: = 1.0 if MobileRender.enabled() else (get_viewport().get_screen_transform().get_scale().x if is_inside_tree() else 1.0)
	if k <= 0.001:
		k = 1.0
	var want: = Vector2i((_stage.size * k).ceil())
	if want.x > 0 and want.y > 0 and sub.size != want:
		sub.size = want
	queue_redraw()




func _draw() -> void :
	if slot == null or state == State.OFF or cam == null or sub == null:
		return
	if not is_instance_valid(_stage) or sub.size.x <= 0 or sub.size.y <= 0:
		return
	if not (cam.is_inside_tree() and cam.current):
		return
	# A newly attached camera may not have its world transform on its first draw.
	var transform := cam.get_camera_transform()
	if absf(transform.basis.z.dot(-transform.origin)) < 0.0001:
		return
	var uv: = cam.unproject_position(Vector3.ZERO)
	var feet: = (_stage.global_position - global_position)\
	+ (uv / Vector2(sub.size)) * _stage.size
	var rx: float = _stage.size.x * 0.19
	var ry: float = rx * 0.24
	var pts: = PackedVector2Array()
	for i in 28:
		var a: = TAU * float(i) / 28.0
		pts.append(feet + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, Color(0, 0, 0, 0.2))

func _make_row(key: String) -> Control:
	var profile_selector: = key == "profile"
	var row: Control = PanelContainer.new() if profile_selector\
	else (Button.new() if index == 0 else Control.new())
	row.name = key.capitalize()
	row.custom_minimum_size.y = 38 if key in ["profile", "device"] else 32
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(12 if key in ["profile", "device"] else 10)
	sb.set_border_width_all(2)
	sb.border_color = Color(UiStyle.INK, 0.11)
	sb.set_content_margin_all(0)
	if row is PanelContainer:
		row.add_theme_stylebox_override("panel", sb)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elif row is Button:
		var b: = row as Button
		b.flat = false
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_stylebox_override("focus", sb)
		b.pressed.connect( func(): _open_row(key))
	else:
		row.focus_mode = Control.FOCUS_NONE
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		var panel: = PanelContainer.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_theme_stylebox_override("panel", sb)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(panel)
		row.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_cursor = _row_keys().find(key)
				_open_row(key))
	row.set_meta("sb", sb)
	var h: = HBoxContainer.new()
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if row is PanelContainer:
		h.add_theme_constant_override("margin_left", 5)
		h.add_theme_constant_override("margin_right", 5)
	else:
		h.offset_left = 10.0
		h.offset_right = -10.0
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(h)
	if profile_selector:
		var prev: = _profile_arrow_button(-1)
		prev.name = "LeftArrow"
		h.add_child(prev)
		var selector: = Button.new()
		selector.name = "ProfileDropdown"
		selector.flat = true
		selector.focus_mode = Control.FOCUS_ALL if index == 0 else Control.FOCUS_NONE
		selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		selector.pressed.connect( func(): _open_row("profile"))
		var selector_label: = Label.new()
		selector_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		selector_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		selector_label.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		selector_label.add_theme_font_size_override("font_size", 15)
		selector_label.add_theme_color_override("font_color", UiStyle.INK)
		selector_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selector.add_child(selector_label)
		h.add_child(selector)
		_row_vals[key] = selector_label
		var next: = _profile_arrow_button(1)
		next.name = "RightArrow"
		h.add_child(next)
		return row
	elif key == "device":
		var ic: = TextureRect.new()
		ic.texture = UiStyle.icon("gamepad", false, true)
		ic.custom_minimum_size = Vector2(22, 22)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ic.modulate = UiStyle.INK
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(ic)
	else:
		var ic: = TextureRect.new()

		ic.texture = UiStyle.icon({"settings": "gear", "title": "star"}.get(key, "gamepad"), false, true)
		ic.custom_minimum_size = Vector2(20, 20)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ic.modulate = UiStyle.SECONDARY
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(ic)
	var val: = Label.new()
	val.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	val.add_theme_font_size_override("font_size", 15 if key in ["profile", "device"] else 13)
	val.add_theme_color_override("font_color", UiStyle.INK)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if key != "controls"\
	else HORIZONTAL_ALIGNMENT_LEFT
	val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	val.clip_text = true
	val.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(val)
	_row_vals[key] = val
	return row





func _wire_p1_focus() -> void :
	var prof: Control = _rows["profile"]
	var l: = prof.find_child("LeftArrow", true, false) as Control
	var sel: = prof.find_child("ProfileDropdown", true, false) as Control
	var r: = prof.find_child("RightArrow", true, false) as Control
	var dev: Control = _rows["device"]
	var acts: Array = [_rows["controls"], _rows["settings"], _rows["title"]]
	var top: Array = [l, sel, r]
	for row in [top, acts]:
		for i in row.size():
			var c: Control = row[i]
			c.focus_neighbor_left = c.get_path_to(row[maxi(i - 1, 0)])
			c.focus_neighbor_right = c.get_path_to(row[mini(i + 1, row.size() - 1)])
	for c in top:
		c.focus_neighbor_bottom = c.get_path_to(dev)
	dev.focus_neighbor_top = dev.get_path_to(sel)
	dev.focus_neighbor_bottom = dev.get_path_to(acts[0])
	for c in acts:
		c.focus_neighbor_top = c.get_path_to(dev)

func _profile_arrow_button(direction: int) -> Button:
	var arrow: = Button.new()
	arrow.flat = true
	arrow.focus_mode = Control.FOCUS_ALL if index == 0 else Control.FOCUS_NONE
	arrow.custom_minimum_size = Vector2(28, 30)
	arrow.text = "‹" if direction < 0 else "›"
	UiStyle.style_button(arrow, "tertiary", 22)


	for state_name in ["normal", "hover", "pressed", "focus"]:
		var style: = StyleBoxFlat.new()
		style.bg_color = Color(UiStyle.SECONDARY, 0.1) if state_name == "hover"\
		else Color(0, 0, 0, 0)
		style.set_corner_radius_all(8)
		style.set_content_margin_all(0)
		arrow.add_theme_stylebox_override(state_name, style)
	arrow.pressed.connect(_cycle_profile.bind(direction))
	return arrow

func _make_quick_link(text_in: String, action: Callable) -> Control:
	var link: Control = Button.new() if index == 0 else Control.new()
	link.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link.focus_mode = Control.FOCUS_NONE
	if link is Button:
		var button: = link as Button
		button.text = text_in
		UiStyle.style_button(button, "tertiary", 13)
		button.pressed.connect(action)
	else:
		link.mouse_filter = Control.MOUSE_FILTER_STOP
		link.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed\
			and ev.button_index == MOUSE_BUTTON_LEFT:
				action.call())
		var label: = Label.new()
		label.text = text_in
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiStyle.style_label(label, "small", UiStyle.SECONDARY)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		link.add_child(label)
	return link

func _create_profile() -> void :
	if slot == null or _p1_locked():
		return
	if index == 0:
		var made: = ProfileStore.create_profile("Player %d" % (ProfileStore.profiles.size() + 1))
		if made == null:
			notice("profile limit reached")
			return
		ProfileStore.switch_to(ProfileStore.profiles.find(made))
		slot.profile = ProfileStore.active()
		if menu_hooks.has("p1_switched"):
			(menu_hooks.p1_switched as Callable).call()
	else:
		if LocalPlayers.create_profile_for(slot) == null:
			notice("profile limit reached")
	_look_key = 0
	_dress()
	_paint()

func _cycle_profile(direction: int) -> void :
	if slot == null or state == State.OFF or direction == 0 or _p1_locked():
		return
	if index == 0:
		var available: Array[int] = []
		for i in ProfileStore.profiles.size():
			var candidate: SavedProfile = ProfileStore.profiles[i]
			var claimed: = false
			for other in LocalPlayers.slots:
				if other != slot and other.profile == candidate:
					claimed = true
					break
			if not claimed or i == ProfileStore.active_index:
				available.append(i)
		if available.size() <= 1:
			return
		var at: = available.find(ProfileStore.active_index)
		if at < 0:
			return
		ProfileStore.switch_to(available[posmod(at + direction, available.size())])
		slot.profile = ProfileStore.active()
		if menu_hooks.has("p1_switched"):
			(menu_hooks.p1_switched as Callable).call()
	else:
		var choices: = LocalPlayers.profile_choices(slot)
		if choices.size() <= 1:
			return
		var at: = 0
		for i in choices.size():
			var choice: Dictionary = choices[i]
			var is_guest: = bool(choice.get("guest", false))
			if (is_guest and slot.is_temp) or \
			( not is_guest and choice.get("profile") == slot.profile):
				at = i
				break
		LocalPlayers.apply_choice(slot, choices[posmod(at + direction, choices.size())])
	_look_key = 0
	_dress()
	_paint()
	UiStyle.sfx("tick")





func bind(for_slot: LocalPlayerSlot) -> void :
	if MobileRender.enabled() and pc == null:
		if for_slot == null:
			slot = null
			state = State.EMPTY
			_paint()
			return
		# Allocate only occupied slots, when their page is actually opened.
		_build_stage3d()

	if pc == null:
		_pending = for_slot
		_has_pending = true
		return
	var was: = slot_ls
	slot = for_slot
	slot_ls = for_slot.ls if for_slot != null else -1
	if for_slot == null:
		state = State.EMPTY
		_overlay_kind = ""
		_overlay.visible = false
		_notice_pinned = false
		_notice.visible = false
		_reader = null
		if pc != null:
			pc.visible = false
			pc.set_process(false)
		_paint()
		return
	if slot_ls != was:

		_cursor = 0
		_overlay_kind = ""
		_overlay.visible = false
		_notice_pinned = false
		_cancel_held = 0.0
		_join_t = 0.0
		state = State.JOINING
		_reader = DeviceInput.new(for_slot.device) if index > 0 else null
		UiStyle.pop_in(self)


		if index > 0:
			notice("player %d has joined!" % (for_slot.index + 1))
			UiStyle.sfx("confirm")
	elif state == State.EMPTY:
		state = State.IDLE
	if not for_slot.connected:
		state = State.OFF
	elif state == State.OFF:
		state = State.IDLE
		notice("player %d is back!" % (for_slot.index + 1))
	_dress()
	_paint()


func _dress() -> void :
	if pc == null or slot == null:
		return
	var look: Dictionary = menu_hooks.get("seat_look", Callable()).call(slot, outfit)\
	if menu_hooks.has("seat_look") else {}
	var cfg: CharacterConfig = look.get("cfg") if look.has("cfg") else null
	if cfg == null:
		cfg = CharacterConfig.from_dict(slot.profile.character)\
		if (slot.profile != null and not slot.profile.character.is_empty())\
		else CharacterConfig.random()
	var kit: Array = look.get("kit", GameConfig.team_kit(true))


	var framed: = cfg.clone()
	framed.height = 0.5



	framed.casual = cfg.casual
	framed.wear_pinny = cfg.wear_pinny
	framed.pinny_color = cfg.pinny_color
	framed.pinny_accent = cfg.pinny_accent
	var key: = hash([framed.to_dict(), kit, framed.casual])
	if key != _look_key:
		_look_key = key
		pc.player.set_character(framed, kit)
	pc.visible = true


func set_live(on: bool) -> void :
	_want_live = on
	if sub == null:
		return
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	if pc != null:
		pc.set_process(on and slot != null and state != State.OFF)
	if on:
		_sync_stage_size()



func _tint() -> Color:
	if slot == null:
		return Color(UiStyle.muted(), 0.55)


	return Color("f47721") if index == 1 else slot.color()

func _profile_choice_count() -> int:
	if slot == null:
		return 0
	if index > 0:
		return LocalPlayers.profile_choices(slot).size()
	var count: = 0
	for i in ProfileStore.profiles.size():
		var candidate: SavedProfile = ProfileStore.profiles[i]
		var claimed: = false
		for other in LocalPlayers.slots:
			if other != slot and other.profile == candidate:
				claimed = true
				break
		if not claimed or i == ProfileStore.active_index:
			count += 1
	return count

func _paint() -> void :
	var taken: = slot != null
	var tint: = _tint()
	_frame_box.bg_color = Color(UiStyle.card(), 0.98) if taken else Color(UiStyle.muted(), 0.045)
	_frame_box.border_color = Color(tint, 0.58) if taken else Color(UiStyle.muted(), 0.24)
	_head_box.bg_color = Color(tint, 0.18) if taken else Color(UiStyle.muted(), 0.12)
	_tag_box.bg_color = tint if taken else Color(UiStyle.muted(), 0.75)
	_tag.text = "P%d" % (index + 1)
	_tag.add_theme_color_override("font_color", Color.WHITE)
	_status.add_theme_color_override("font_color", tint if taken else UiStyle.muted())
	_crown.visible = taken and index == 0
	if not taken:
		_status.text = ""
	elif index == 0:
		_status.text = "party leader"
	elif state == State.OFF:
		_status.text = "powered off"
	else:
		_status.text = "joined"

	_empty_box.visible = not taken
	if not taken:
		var next: = index == LocalPlayers.count()
		_empty_icon.texture = UiStyle.icon("gamepad" if index == 2 else "plus", false, true)
		_empty_icon.modulate = Color(UiStyle.INK, 0.75 if next else 0.35)
		var kbd: = LocalPlayers.primary_device >= 0 and not LocalPlayers.kbm_taken()
		_empty_text.text = "press A to join" if next else "open slot"
		_empty_text.modulate = Color(1, 1, 1, 1.0 if next else 0.58)
		_empty_sub.text = "on another controller" if next else "press A to join on another controller"
		if next and kbd:
			_empty_sub.text += " / Enter on keyboard"

	if _name_head != null:
		_name_head.text = _trim(slot.display_name()) if taken else ""

	var off: = taken and state == State.OFF
	_rows["profile_group"].visible = taken
	_rows["device_group"].visible = taken
	_rows["actions"].visible = taken
	_rows["create_profile"].visible = taken and index > 0 and slot.is_temp
	var can_cycle: = taken and not off and _profile_choice_count() > 1
	var left_arrow: = _rows["profile"].find_child("LeftArrow", true, false) as Button
	var right_arrow: = _rows["profile"].find_child("RightArrow", true, false) as Button
	if left_arrow != null:
		left_arrow.disabled = not can_cycle
	if right_arrow != null:
		right_arrow.disabled = not can_cycle
	(_rows["title"] as Control).visible = TITLES.usable()
	var keys: = _row_keys()
	for i in keys.size():
		var key: = String(keys[i])
		var row: Control = _rows[key]
		var val: Label = _row_vals[key]
		row.modulate = Color(1, 1, 1, 0.25 if not taken else (0.55 if off else 1.0))
		var sb: StyleBoxFlat = row.get_meta("sb")
		var on: = taken and index > 0 and i == _cursor and state != State.OFF
		sb.bg_color = Color(tint, 0.16) if on else UiStyle.card()
		sb.set_border_width_all(3 if on else 2)
		sb.border_color = tint if on else Color(UiStyle.INK, 0.1)
		match key:
			"profile":
				val.text = _trim(slot.display_name() if taken and not slot.is_temp else ("guest" if taken else ""))
			"device":
				val.text = _device_text() if taken else ""
			"controls":
				val.text = "controls" if taken else ""
			"settings":
				val.text = "settings" if taken else ""
			"title":
				val.text = _title_text() if taken else ""
	_remove_btn.visible = off

	_stage.modulate = Color(1, 1, 1, 0.55) if (off or _overlay.visible) else Color.WHITE
	if off and not _notice_pinned:
		notice("turn the controller on", true)
	elif not off and _notice_pinned:
		_notice_pinned = false
		_notice.visible = false
	if pc != null:
		pc.set_process(taken and not off and sub.render_target_update_mode == SubViewport.UPDATE_ALWAYS)

func _trim(s: String) -> String:
	return s if s.length() <= 14 else s.left(13) + "..."

func _device_text() -> String:
	if slot == null:
		return ""
	if index == 0:
		var d: = LocalPlayers.primary_device
		return "keyboard & mouse" if d < 0 else "controller %d" % (d + 1)
	if slot.device == DeviceInput.KBM:
		return "keyboard & mouse"
	return "controller %d" % (slot.device + 1)


func notice(text_in: String, pinned: = false) -> void :
	_notice.text = text_in
	_notice.visible = true
	_notice_pinned = pinned
	_notice_left = NOTICE_S
	_notice.reset_size()
	_place_notice()
	UiStyle.pop_in(_notice)

func _place_notice() -> void :
	if _notice == null or _stage == null:
		return
	_notice.position = Vector2((size.x - _notice.size.x) * 0.5, 
		_stage.position.y + 150.0 - _notice.size.y * 0.5)



func tick(delta: float) -> void :
	if _notice.visible and not _notice_pinned:
		_notice_left -= delta
		if _notice_left <= 0.0:
			_notice.visible = false
	_place_notice()
	if slot == null or index == 0 or _reader == null:
		return
	if state == State.OFF or not slot.connected:
		return
	_reader.device = slot.device
	_reader.poll(["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "ui_cancel", "menu_start"])
	if state == State.JOINING:

		_join_t += delta
		if _join_t >= JOIN_SETTLE and not _reader.pressed("ui_accept"):
			state = State.IDLE
		return
	if state == State.SUBMENU:
		_tick_overlay(delta)
		return


	var keys: = _row_keys()
	var trio: Array = ["controls", "settings", "title"].filter( func(k): return keys.has(k))
	var here: = String(keys[clampi(_cursor, 0, keys.size() - 1)])
	if here in trio and (_reader.just_pressed("ui_left") or _reader.just_pressed("ui_right")):
		var at: = clampi(trio.find(here) + (1 if _reader.just_pressed("ui_right") else -1), 0, trio.size() - 1)
		_cursor = keys.find(trio[at])
		UiStyle.sfx("hover")
		_paint()
		return
	if _cursor == 0:
		if _reader.just_pressed("ui_left"):
			_cycle_profile(-1)
			return
		if _reader.just_pressed("ui_right"):
			_cycle_profile(1)
			return
	if _reader.just_pressed("menu_start"):
		notice("you cannot perform this action")
		return
	var dir: = ""
	if _reader.pressed("ui_down"):
		dir = "down"
	elif _reader.pressed("ui_up"):
		dir = "up"
	var step: = 0
	if dir == "":
		_held = ""
	elif dir != _held:
		_held = dir
		_repeat = 0.42
		step = 1 if dir == "down" else -1
	else:
		_repeat -= delta
		if _repeat <= 0.0:
			_repeat = 0.11
			step = 1 if dir == "down" else -1
	if step != 0:

		if here in trio:
			if step < 0:
				_cursor = keys.find("device")
		else:
			_cursor = clampi(_cursor + step, 0, keys.find("controls"))
		UiStyle.sfx("hover")
		_paint()
	if _reader.just_pressed("ui_accept"):
		_open_row(String(_row_keys()[_cursor]))

	if _reader.pressed("ui_cancel"):
		_cancel_held += delta
		if _cancel_held >= LEAVE_HOLD:
			_cancel_held = -100.0
			_leave()
	else:
		if _cancel_held > 0.0 and _cancel_held < LEAVE_HOLD:
			notice("hold to leave")
		_cancel_held = 0.0





func _leave() -> void :
	if slot == null:
		return
	if menu_hooks.has("on_leave"):
		(menu_hooks.on_leave as Callable).call()
	LocalPlayers.leave(slot.device)

func submenu_open() -> bool:
	return _overlay.visible




func nav_root() -> Control:
	return _overlay if _overlay.visible else null

func listening() -> bool:
	return _rebind != null and is_instance_valid(_rebind) and _rebind.listening()

func _open_row(key: String) -> void :
	if slot == null or state == State.OFF:
		return
	if key == "device" and index == 0:
		notice("player 1 plays on any free device")
		return
	if key == "outfit":
		_cycle_outfit()
		return
	if key == "profile" and _p1_locked():
		return
	_open_overlay(key)

func _cycle_outfit() -> void :
	var at: = OUTFITS.find(outfit)
	outfit = String(OUTFITS[(at + 1) % OUTFITS.size()])
	_look_key = 0
	_dress()
	UiStyle.sfx("tick")
	_paint()

func _open_overlay(kind: String, animate: = true) -> void :
	for c in _overlay.get_children():
		c.queue_free()
	_overlay_kind = kind

	if not _notice_pinned:
		_notice.visible = false
	_list_rows.clear()
	_list_actions.clear()
	_list_steps.clear()
	_list_cursor = 0
	var box: = UiStyle.card_box(UiStyle.card(), 14)
	box.set_border_width_all(3)
	box.border_color = _tint()
	box.set_content_margin_all(10)
	_overlay.add_theme_stylebox_override("panel", box)
	match kind:
		"profile":
			_build_profile_list()
		"device":
			_build_device_list()
		"controls":
			_rebind = SeatRebind.new()
			_overlay.add_child(_rebind)
			var k: = InputPrompts.Kind.KBM if slot.device == DeviceInput.KBM else InputPrompts.Kind.GAMEPAD
			if index == 0:
				k = InputPrompts.Kind.KBM if LocalPlayers.primary_device < 0 else InputPrompts.Kind.GAMEPAD
			_rebind.open(slot, k, _tint())
			_rebind.closed.connect(close_submenu)
		"settings":
			_build_settings_list()
		"title":
			_build_title_list()
	_overlay.visible = true
	if not animate:
		return
	_overlay.modulate.a = 0.0
	_overlay.position.y += 24.0
	var t: = _overlay.create_tween().set_parallel(true)
	t.tween_property(_overlay, "modulate:a", 1.0, 0.16)
	t.tween_property(_overlay, "position:y", _overlay.position.y - 24.0, 0.22)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	state = State.SUBMENU if index > 0 else state
	UiStyle.sfx("confirm")
	_paint()
	if index == 0:

		var btns: = _overlay.find_children("*", "Button", true, false)
		if not btns.is_empty():
			(btns[0] as Button).grab_focus()

func close_submenu() -> void :
	if not _overlay.visible:
		return
	_overlay.visible = false
	_overlay_kind = ""
	_rebind = null
	if index > 0:
		state = State.IDLE
	else:
		var row: Control = _rows.get("profile")
		if row is Button and is_instance_valid(row):
			(row as Button).grab_focus()
	UiStyle.sfx("close")
	_paint()


func _list_shell(title_text: String) -> VBoxContainer:
	var v: = VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 4)
	_overlay.add_child(v)
	var title: = Label.new()
	title.text = title_text
	title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiStyle.INK)
	v.add_child(title)
	var rule: = Panel.new()
	rule.custom_minimum_size = Vector2(36, 4)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var rb: = StyleBoxFlat.new()
	rb.bg_color = _tint()
	rb.set_corner_radius_all(2)
	rule.add_theme_stylebox_override("panel", rb)
	v.add_child(rule)
	return v

func _list_row(parent: VBoxContainer, text_in: String, on_pick: Callable, 
		checked: = false, disc: Control = null, accent: = false) -> Control:
	var row: Control = Button.new() if index == 0 else Control.new()
	row.custom_minimum_size.y = 30
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if row is Button:
		(row as Button).flat = true
		(row as Button).pressed.connect(on_pick)
	else:
		row.focus_mode = Control.FOCUS_NONE
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				on_pick.call())
	var h: = HBoxContainer.new()
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(h)
	if disc != null:
		disc.custom_minimum_size = Vector2(24, 24)
		disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(disc)
	var l: = Label.new()
	l.text = text_in
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", UiStyle.SECONDARY if accent else UiStyle.INK)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(l)
	if checked:
		var ck: = TextureRect.new()
		ck.texture = UiStyle.icon_disc("checkmark", UiStyle.SUCCESS, 18, true)
		ck.custom_minimum_size = Vector2(18, 18)
		ck.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ck.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ck.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ck.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(ck)
	parent.add_child(row)
	_list_rows.append(row)
	_list_actions.append(on_pick)
	_list_steps.append(null)
	return row

func _list_hint(v: VBoxContainer, a_text: String) -> void :
	var spring: = Control.new()
	spring.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(spring)
	var hint: = HBoxContainer.new()
	hint.alignment = BoxContainer.ALIGNMENT_CENTER
	hint.add_theme_constant_override("separation", 10)
	v.add_child(hint)
	for pair in [["ui_accept", a_text], ["ui_cancel", "back"]]:
		var h: = HBoxContainer.new()
		h.add_theme_constant_override("separation", 4)
		var plate: = PanelContainer.new()
		var pb: = StyleBoxFlat.new()
		pb.bg_color = Color("141a26") if UiStyle.dark else UiStyle.INK
		pb.set_corner_radius_all(8)
		pb.set_content_margin_all(3.0)
		plate.add_theme_stylebox_override("panel", pb)
		var g: = TextureRect.new()
		var kind: = InputPrompts.Kind.KBM if (slot != null and slot.device == DeviceInput.KBM)\
		else InputPrompts.Kind.GAMEPAD
		var style: = InputPrompts.style_for_device(slot.device) if (slot != null and slot.device >= 0)\
		else InputPrompts.active_style()
		g.texture = InputPrompts.glyph_on(String(pair[0]), kind, style)
		g.custom_minimum_size = Vector2(22, 16)
		g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		plate.add_child(g)
		h.add_child(plate)
		var l: = Label.new()
		l.text = String(pair[1])
		UiStyle.style_label(l, "small", UiStyle.muted())
		h.add_child(l)
		hint.add_child(h)








const SENS_STEPS: = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
const SHAKE_NAMES: = ["off", "small", "medium", "high"]
const CROSS_SIZES: = [2.0, 3.0, 4.0, 5.0, 6.0, 8.0]
const CROSS_COLORS: = [Color("ffffff"), Color("ffd23f"), Color("3fd2ff"), Color("ff7ea8"), 
	Color("4ccb7a"), Color("ff8a3d"), Color("9b6bff")]
const CROSS_COLOR_NAMES: = ["white", "yellow", "cyan", "pink", "green", "orange", "purple"]

func _pget(field: String):
	return GameConfig.get(field) if index == 0 else slot.profile.get(field)

func _pset(field: String, value) -> void :
	if index == 0:
		GameConfig.set(field, value)
		GameConfig.save_settings()
	else:
		slot.profile.set(field, value)
		ProfileStore.save()

		if field == "rumble" and slot.device >= 0:
			Haptics.set_device_rumble(slot.device, bool(value))




func _value_row(parent: VBoxContainer, label: String, shown: Callable, step: Callable) -> void :
	var row: = _list_row(parent, "%s: %s" % [label, shown.call()], func():
		step.call(1)
		_refresh_values())
	_list_steps[_list_steps.size() - 1] = func(dir: int):
		step.call(dir)
		_refresh_values()
	row.set_meta("text_fn", func() -> String: return "%s: %s" % [label, shown.call()])

func _toggle_row(parent: VBoxContainer, label: String, field: String, on_text: = "on", 
		off_text: = "off") -> void :
	_value_row(parent, label, func(): return on_text if bool(_pget(field)) else off_text, 
		func(_dir: int): _pset(field, not bool(_pget(field))))


func _refresh_values() -> void :
	for row in _list_rows:
		if is_instance_valid(row) and (row as Control).has_meta("text_fn"):
			var labels: = (row as Control).find_children("*", "Label", true, false)
			if not labels.is_empty():
				(labels[0] as Label).text = String(((row as Control).get_meta("text_fn") as Callable).call())
	UiStyle.sfx("tick")

func _step_of(values: Array, current: float, dir: int) -> float:
	var at: = 0
	var best: = INF
	for i in values.size():
		var d: = absf(float(values[i]) - current)
		if d < best:
			best = d
			at = i
	return float(values[posmod(at + dir, values.size())])



func _relist() -> void :
	var keep: = _list_cursor
	var sc_before: = 0
	for n in _overlay.find_children("*", "ScrollContainer", true, false):
		sc_before = (n as ScrollContainer).scroll_vertical
	_open_overlay(_overlay_kind, false)
	_list_cursor = clampi(keep, 0, maxi(_list_rows.size() - 1, 0))
	UiStyle.sfx("tick")
	await get_tree().process_frame
	if not is_instance_valid(self):
		return
	for n in _overlay.find_children("*", "ScrollContainer", true, false):
		(n as ScrollContainer).scroll_vertical = sc_before
	_paint_list()
	if index == 0 and _list_cursor < _list_rows.size() and _list_rows[_list_cursor] is Button:
		(_list_rows[_list_cursor] as Button).grab_focus()

const SHAKE_STEPS: = 4

func _shake_now() -> int:
	return 0 if not bool(_pget("camera_shake")) else 3 - clampi(int(_pget("camera_shake_preset")), 0, 2)

func _cross_shape_at() -> int:
	var shapes: Array = Crosshair.SHAPES
	for i in shapes.size():
		if String(shapes[i].id) == String(_pget("crosshair_shape")):
			return i
	return 0

func _cross_color_at() -> int:
	if not bool(_pget("crosshair_custom")):
		return -1
	for i in CROSS_COLORS.size():
		if (CROSS_COLORS[i] as Color).is_equal_approx(_pget("crosshair_color")):
			return i
	return -1

func _build_settings_list() -> void :
	var v: = _list_shell("your settings")
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_stretch_ratio = 20.0
	v.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var kbm: = index == 0 or slot.device == DeviceInput.KBM
	_value_row(list, "stick sens", func(): return "%.2fx" % float(_pget("stick_sensitivity")), 
		func(dir: int): _pset("stick_sensitivity", 
			_step_of(SENS_STEPS, float(_pget("stick_sensitivity")), dir)))
	if kbm:
		_value_row(list, "mouse sens", func(): return "%.2fx" % float(_pget("mouse_sensitivity")), 
			func(dir: int): _pset("mouse_sensitivity", 
				_step_of(SENS_STEPS, float(_pget("mouse_sensitivity")), dir)))
	_toggle_row(list, "invert x axis", "invert_cam_x")
	_toggle_row(list, "invert y axis", "invert_cam_y")
	_toggle_row(list, "aim assist", "aim_assist")
	_toggle_row(list, "set assist", "set_assist")
	_toggle_row(list, "sprint", "sprint_toggle", "tap", "hold")
	if kbm:
		_toggle_row(list, "double-tap sprint", "sprint_double_tap")
	if index == 0 or slot.device != DeviceInput.KBM:
		_toggle_row(list, "rumble", "rumble")

	_value_row(list, "camera shake", func(): return String(SHAKE_NAMES[_shake_now()]), 
		func(dir: int):
			var next: = posmod(_shake_now() + dir, SHAKE_STEPS)
			_pset("camera_shake", next > 0)
			if next > 0:
				_pset("camera_shake_preset", 3 - next))
	_toggle_row(list, "fov effects", "camera_fov_fx")
	_toggle_row(list, "reach marker", "reach_marker")
	_toggle_row(list, "control hints", "show_control_hints")
	_toggle_row(list, "your own name", "show_own_name", "shown", "hidden")
	_toggle_row(list, "names in rallies", "hide_names_in_rally", "hidden", "shown")
	if TITLES.enabled():
		_toggle_row(list, "titles in rallies", "hide_titles_in_rally", "hidden", "shown")

	var shapes: Array = Crosshair.SHAPES
	if not shapes.is_empty():
		_value_row(list, "crosshair", func(): return String(shapes[_cross_shape_at()].label), 
			func(dir: int): _pset("crosshair_shape", 
				String(shapes[posmod(_cross_shape_at() + dir, shapes.size())].id)))
	_value_row(list, "crosshair colour", func():
			var at: = _cross_color_at()
			return "team colours" if at < 0 else String(CROSS_COLOR_NAMES[at]), 
		func(dir: int):
			var next: = posmod(_cross_color_at() + 1 + dir, CROSS_COLORS.size() + 1) - 1
			_pset("crosshair_custom", next >= 0)
			if next >= 0:
				_pset("crosshair_color", CROSS_COLORS[next]))
	_value_row(list, "crosshair size", func(): return "%.0fx" % float(_pget("crosshair_size")), 
		func(dir: int): _pset("crosshair_size", 
			_step_of(CROSS_SIZES, float(_pget("crosshair_size")), dir)))
	_toggle_row(list, "floor ring", "crosshair_ring")
	_list_hint(v, "change")





func _who() -> SavedProfile:
	return null if index == 0 else slot.profile

func _title_text() -> String:
	var worn: = str(TITLES.equipped(_who()).get("id", ""))
	if worn == "":
		return "no title"
	var item = TITLES.by_id(worn)
	return String(item.text).to_lower() if item != null else "title"

func _build_title_list() -> void :
	var v: = _list_shell("your title")
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_stretch_ratio = 20.0
	v.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var who: = _who()
	var worn: = str(TITLES.equipped(who).get("id", ""))
	_list_row(list, "no title", func():
		TITLES.equip("", TITLES.saved_look(who), who)
		_relist(), worn == "")
	var owned: Array = TITLES.owned(who)
	for item in owned:
		var id: = String(item.id)
		_list_row(list, String(item.text).to_lower(), func():
			TITLES.equip(id, TITLES.saved_look(who), who)
			_relist(), worn == id)
	var effects: Array = TITLES.owned_effects(who)
	if not effects.is_empty():
		var using: = str(TITLES.saved_look(who).get("fx", ""))
		_list_row(list, "effect: none", func():
			var look: Dictionary = TITLES.saved_look(who)
			look["fx"] = ""
			look.erase("fp")
			look.erase("ac")
			TITLES.equip(str(TITLES.equipped(who).get("id", "")), look, who)
			_relist(), using == "", null, true)
		for fx in effects:
			var fid: = String(fx.id)
			_list_row(list, "effect: %s" % String(fx.label).to_lower(), func():
				var look: Dictionary = TITLES.saved_look(who)
				look["fx"] = fid
				look.erase("fp")
				look.erase("ac")
				TITLES.equip(str(TITLES.equipped(who).get("id", "")), look, who)
				_relist(), using == fid, null, true)
	if owned.is_empty():
		var none: = Label.new()
		none.text = "no titles yet: the shop sells them"
		UiStyle.style_label(none, "small", UiStyle.muted())
		list.add_child(none)
	_list_hint(v, "wear")

func _build_profile_list() -> void :
	var v: = _list_shell("select your profile")
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.custom_minimum_size.y = 6 * 32
	v.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if index == 0:
		for i in ProfileStore.profiles.size():
			var p: SavedProfile = ProfileStore.profiles[i]
			var claimed: = false
			for other in LocalPlayers.slots:
				if other != slot and other.profile == p:
					claimed = true
					break
			if claimed and i != ProfileStore.active_index:
				continue
			var idx: = i
			_list_row(list, p.name, func():
				ProfileStore.switch_to(idx)
				slot.profile = ProfileStore.active()
				if menu_hooks.has("p1_switched"):
					(menu_hooks.p1_switched as Callable).call()
				_look_key = 0
				_dress()
				close_submenu(), 
				i == ProfileStore.active_index, _face_disc(p.character))
	else:
		for c in LocalPlayers.profile_choices(slot):
			var choice: Dictionary = c
			var is_guest: = bool(choice.get("guest", false))
			var current: bool = (is_guest and slot.is_temp) or ( not is_guest and choice.get("profile") == slot.profile)
			var disc: Control = RosterTile.EmptyDisc.new() if is_guest\
			else _face_disc((choice.profile as SavedProfile).character)
			_list_row(list, "guest profile" if is_guest else String(choice.label), func():
				LocalPlayers.apply_choice(slot, choice)
				_look_key = 0
				_dress()
				close_submenu(), 
			current, disc)


	_list_row(v, "preview outfit: %s" % ("captain uniform" if outfit == "captain" else outfit), func():
		_cycle_outfit()
		close_submenu())

	var plus: = TextureRect.new()
	plus.texture = UiStyle.icon_disc("plus", UiStyle.SECONDARY, 24, true)
	plus.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_list_row(v, "make a new profile", func():
		if index == 0:
			var made: = ProfileStore.create_profile("Player %d" % (index + 1))
			if made != null:
				ProfileStore.switch_to(ProfileStore.profiles.find(made))
				slot.profile = ProfileStore.active()
				if menu_hooks.has("p1_switched"):
					(menu_hooks.p1_switched as Callable).call()
		else:
			LocalPlayers.create_profile_for(slot)
		_look_key = 0
		_dress()
		close_submenu(), false, plus, true)

	if menu_hooks.has("open_locker"):
		var star: = TextureRect.new()
		star.texture = UiStyle.icon_disc("star", UiStyle.SECONDARY, 24, true)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_list_row(v, "edit look", func():
			(menu_hooks.open_locker as Callable).call(slot), false, star, true)
	_list_hint(v, "select")
	_paint_list()

func _face_disc(character: Dictionary) -> Control:
	var face: = TextureRect.new()
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if RosterTile._mask == null:
		RosterTile._mask = Shader.new()
		RosterTile._mask.code = RosterTile.MASK_SHADER
	var m: = ShaderMaterial.new()
	m.shader = RosterTile._mask
	face.material = m
	_load_disc_face(face, character)
	return face

func _load_disc_face(rect: TextureRect, character: Dictionary) -> void :
	if character.is_empty():
		return
	var key: = hash(character)
	var tex: ImageTexture = await CharacterPortrait.head_cached(character, self, "lobby")
	if is_instance_valid(rect) and tex != null and hash(character) == key:
		rect.texture = tex

func _build_device_list() -> void :
	var v: = _list_shell("pick your device")
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	v.add_child(list)
	var free: Array = (menu_hooks.free_devices as Callable).call(slot)\
	if menu_hooks.has("free_devices") else []
	if free.size() < 2:
		var none: = Label.new()
		none.text = "no free devices"
		UiStyle.style_label(none, "small", UiStyle.muted())
		list.add_child(none)
	else:
		for d in free:
			var dev: = int(d)
			var ic: = TextureRect.new()
			ic.texture = UiStyle.icon("mouse" if dev < 0 else "gamepad", false, true)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.modulate = UiStyle.INK
			var name: = "keyboard & mouse" if dev < 0 else "controller %d" % (dev + 1)
			_list_row(list, name, func():
				if LocalPlayers.set_device(slot, dev):
					if menu_hooks.has("sync_guests"):
						(menu_hooks.sync_guests as Callable).call()
				close_submenu(), 
				dev == slot.device, ic)
	_list_hint(v, "select")
	_paint_list()

func _paint_list() -> void :
	if index == 0:
		return
	for i in _list_rows.size():
		var row: = _list_rows[i] as Control
		if not is_instance_valid(row):
			continue
		var on: = i == _list_cursor
		if on:
			var sc: = row.get_parent()
			while sc != null and not sc is ScrollContainer:
				sc = sc.get_parent()
			if sc != null:
				(sc as ScrollContainer).ensure_control_visible(row)
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(_tint(), 0.16) if on else Color(0, 0, 0, 0)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(2 if on else 0)
		sb.border_color = _tint()
		if row.get_child_count() > 0 and row.get_child(0) is PanelContainer:
			(row.get_child(0) as PanelContainer).add_theme_stylebox_override("panel", sb)
		else:
			var bg: = PanelContainer.new()
			bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bg.add_theme_stylebox_override("panel", sb)
			row.add_child(bg)
			row.move_child(bg, 0)

func _tick_overlay(delta: float) -> void :
	if _overlay_kind == "controls" and _rebind != null and is_instance_valid(_rebind):
		_rebind.tick(_reader, delta)
		return
	var dir: = ""
	if _reader.pressed("ui_down"):
		dir = "down"
	elif _reader.pressed("ui_up"):
		dir = "up"
	var step: = 0
	if dir == "":
		_held = ""
	elif dir != _held:
		_held = dir
		_repeat = 0.42
		step = 1 if dir == "down" else -1
	else:
		_repeat -= delta
		if _repeat <= 0.0:
			_repeat = 0.11
			step = 1 if dir == "down" else -1
	if step != 0 and not _list_rows.is_empty():
		_list_cursor = clampi(_list_cursor + step, 0, _list_rows.size() - 1)
		UiStyle.sfx("hover")
		_paint_list()
	if _list_cursor < _list_steps.size() and _list_steps[_list_cursor] is Callable:
		if _reader.just_pressed("ui_left"):
			(_list_steps[_list_cursor] as Callable).call(-1)
			return
		if _reader.just_pressed("ui_right"):
			(_list_steps[_list_cursor] as Callable).call(1)
			return
	if _reader.just_pressed("ui_accept") and _list_cursor < _list_actions.size():
		(_list_actions[_list_cursor] as Callable).call()
	elif _reader.just_pressed("ui_cancel"):
		close_submenu()


func capture(event: InputEvent) -> bool:
	if _rebind != null and is_instance_valid(_rebind) and _overlay.visible:
		return _rebind.capture(event)
	return false
