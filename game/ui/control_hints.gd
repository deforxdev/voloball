class_name ControlHints
extends Control















const FLASH_TIME: = 0.11
const FLASH_GREY: = 0.58

const MARGIN_X: = 16.0
const MARGIN_Y: = 14.0


const ROWS: = [
	["Action", "touch", "contact"], 
	["Set", "set", "set"], 
	["Dive", "dive", "dive"], 
	["Jump", "jump", "jump"], 
	["Strafe", "strafe", "strafe"], 
	["Sprint", "sprint", "sprint"], 
]

const FLASH_ACTIONS: = {
	"Action": "contact", 
	"Set": "set", 
	"Dive": "dive", 
	"Jump": "jump", 
	"Strafe": "strafe", 
	"Sprint": "sprint", 
}

var ui_scale: = 1.0:
	set(value):
		ui_scale = value
		if _column != null:
			_column.scale = Vector2(value, value)
			_column.pivot_offset = _column.size

var _column: VBoxContainer = null
var _rows: = {}
var _icons: = {}
var _icon_shadows: = {}
var _actions: = {}
var _gamepad_only: Array = []
var _flash_left: = {}
var _dive_count: Label = null
var _dive_icon: Control = null
var _dive_tile_rest: = Vector2.ZERO
var _dive_deny_tween: Tween = null


var _dev: = DeviceInput.new()
var _profile: SavedProfile = null
var _kind: = InputPrompts.Kind.KBM
var _style: = InputPrompts.Style.XBOX
var _follow_device: = true
var _table: = {}
var _hidden: = false
var _freeplay_rows: Array = []

func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _ready() -> void :
	_build()
	if not InputPrompts.changed.is_connected(_refresh_glyphs):
		InputPrompts.changed.connect(_refresh_glyphs)

	LocalPlayers.bindings_changed.connect( func(slot: LocalPlayerSlot):
		if not _follow_device and slot.device == _dev.device:
			bind(_dev.device, slot.profile))
	_refresh_glyphs()





func bind(device: int, profile: SavedProfile) -> void :
	_profile = profile
	_dev.device = device
	_follow_device = device == DeviceInput.MERGED

	_table = InputBinds.resolve(profile.bindings)\
	if (profile != null and not _follow_device) else {}
	_dev.set_bindings(_table)
	if _follow_device:
		_dev.exclude_pads = LocalPlayers.claimed_pads()
		_dev.exclude_kbm = LocalPlayers.kbm_taken()
	else:
		_dev.exclude_pads = PackedInt32Array()
		_dev.exclude_kbm = false
	_sync_kind()
	_refresh_glyphs()

func _sync_kind() -> void :
	if _follow_device:





		if LocalPlayers.has_guests():
			var pd: = LocalPlayers.primary_device
			if pd == DeviceInput.KBM:
				_kind = InputPrompts.Kind.KBM
				_style = InputPrompts.Style.XBOX
			else:
				_kind = InputPrompts.Kind.GAMEPAD
				_style = InputPrompts.style_for_device(pd)
		else:
			_kind = InputPrompts.device_kind()
			_style = InputPrompts.active_style()
	elif _dev.device == DeviceInput.KBM:
		_kind = InputPrompts.Kind.KBM
		_style = InputPrompts.Style.XBOX
	else:
		_kind = InputPrompts.Kind.GAMEPAD
		_style = InputPrompts.style_for_device(_dev.device)

func is_gamepad() -> bool:
	return _kind == InputPrompts.Kind.GAMEPAD




func set_hidden(on: bool) -> void :
	_hidden = on


func set_freeplay(on: bool) -> void :
	for row in _freeplay_rows:
		if is_instance_valid(row):
			(row as Control).visible = on




func set_practice(on: bool) -> void :
	set_freeplay(false)
	if _rows.has("BallSpawn") and is_instance_valid(_rows["BallSpawn"]):
		(_rows["BallSpawn"] as Control).visible = on
		var nm: = _label("BallSpawn")
		if nm != null:
			nm.text = "call ball" if on else "spawn ball"

		_set_row_action("BallSpawn", "serve" if on else "ball_spawn")

func enabled() -> bool:
	if _profile != null:
		return _profile.show_control_hints
	return GameConfig.show_control_hints



func _build() -> void :
	_column = VBoxContainer.new()
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE





	_column.anchor_left = 1.0
	_column.anchor_top = 1.0
	_column.anchor_right = 1.0
	_column.anchor_bottom = 1.0
	_column.offset_left = - MARGIN_X
	_column.offset_right = - MARGIN_X
	_column.offset_top = - MARGIN_Y
	_column.offset_bottom = - MARGIN_Y
	_column.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_column.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_column.alignment = BoxContainer.ALIGNMENT_END
	_column.scale = Vector2(ui_scale, ui_scale)
	_column.add_theme_constant_override("separation", 5)


	_column.resized.connect( func(): _column.pivot_offset = _column.size)
	add_child(_column)

	_add_row("Camera", "camera", "camera_toggle", false, "")
	_add_row("Zoom", "zoom", "camera_zoom", true, "")
	_add_row("AimAssist", "aim assist", "aim_recenter", true, "x2")

	_add_row("BallSpawn", "spawn ball", "ball_spawn", false, "")
	_add_row("BallDespawn", "despawn ball", "ball_despawn", false, "")
	_freeplay_rows = [_rows["BallSpawn"], _rows["BallDespawn"]]
	set_freeplay(false)
	for r in ROWS:
		_add_row(String(r[0]), String(r[1]), String(r[2]), false, "")


func _add_row(id: String, label_text: String, action: String, 
		gamepad_only: bool, badge: String) -> void :
	var row: = HBoxContainer.new()
	row.name = id
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 7)
	var lbl: = Label.new()
	lbl.name = "Name"
	lbl.text = label_text
	lbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	lbl.add_theme_font_size_override("font_size", 11)


	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_constant_override("outline_size", 5)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)


	var wrap: = Control.new()
	wrap.custom_minimum_size = Vector2(26, 20)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shadow: = TextureRect.new()
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shadow.offset_left = 1.5
	shadow.offset_top = 1.5
	shadow.offset_right = 1.5
	shadow.offset_bottom = 1.5
	shadow.modulate = Color(0, 0, 0, 0.55)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(shadow)
	var icon: = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(icon)
	row.add_child(wrap)
	_icon_shadows[id] = shadow
	if badge != "":
		var b: = Label.new()
		b.text = badge
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		b.add_theme_font_size_override("font_size", 11)
		b.add_theme_color_override("font_color", Color.WHITE)
		b.add_theme_constant_override("outline_size", 4)
		b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
		b.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(b)
	_column.add_child(row)
	_rows[id] = row
	_icons[id] = icon
	_actions[id] = action
	if gamepad_only:
		_gamepad_only.append(row)



func _refresh_glyphs() -> void :
	_sync_kind()
	for id in _icons:
		var icon: = _icons[id] as TextureRect
		if icon == null or not is_instance_valid(icon):
			continue
		var tex: = InputPrompts.glyph_on(String(_actions.get(id, "")), _kind, _style, _table)
		if tex != null:
			icon.texture = tex
			var sh = _icon_shadows.get(id)
			if sh != null and is_instance_valid(sh):
				(sh as TextureRect).texture = tex

	for row in _gamepad_only:
		if is_instance_valid(row):
			(row as Control).visible = is_gamepad()



func _process(delta: float) -> void :
	visible = enabled() and not _hidden
	if not visible:
		return
	if _follow_device:

		_dev.exclude_pads = LocalPlayers.claimed_pads()
		_dev.exclude_kbm = LocalPlayers.kbm_taken()
	_tick_flash(delta)



func _tick_flash(delta: float) -> void :
	_dev.poll(PackedStringArray(FLASH_ACTIONS.values() + ["block"]))
	for id in FLASH_ACTIONS:
		if _dev.just_pressed(String(FLASH_ACTIONS[id])):
			_flash_left[id] = FLASH_TIME

	if _dev.just_pressed("block"):
		_flash_left["Dive"] = FLASH_TIME
	for id in _flash_left.keys():
		var left: = float(_flash_left[id]) - delta
		var row: = _rows.get(id) as Control
		if row == null or not is_instance_valid(row):
			_flash_left.erase(id)
			continue
		if left <= 0.0:
			row.self_modulate = Color.WHITE
			_flash_left.erase(id)
			continue
		_flash_left[id] = left


		var amount: = clampf(left / FLASH_TIME, 0.0, 1.0)
		var shade: = lerpf(FLASH_GREY, 1.0, amount)
		row.self_modulate = Color(shade, shade, shade, 1.0)





func refresh(p: Player, serving: bool) -> void :
	if p == null:
		return
	var action_text: = "touch"
	var action_on: = not p.touch_barred
	if serving:
		action_text = "toss"
		action_on = true
	else:
		match p.resolved_touch():
			Player.TouchKind.BUMP:
				action_text = "bump"
			Player.TouchKind.SET:
				action_text = "set"
			Player.TouchKind.SPIKE:
				action_text = "spike"
			Player.TouchKind.DUMP:
				action_text = "dump"
			Player.TouchKind.BLOCK:
				action_text = "block"
			_:
				action_on = false



	var airborne: = not p.is_on_floor()
	var m2_text: = "block" if airborne else "dive"
	_set_row_action("Dive", m2_text)


	var m2_on: = airborne or not p.dive_is_weak()
	update(action_text, action_on, m2_on, p.is_on_floor(), 
		p.set_opportunity_available(), m2_text)



	var strafe_nm: = _label("Strafe")
	if strafe_nm != null:
		strafe_nm.text = "block" if airborne and is_gamepad() else "strafe"

func update(action_text: String, action_on: bool, dive_on: bool, 
		jump_on: bool, set_on: bool = true, m2_text: String = "dive") -> void :
	var nm: = _label("Action")
	if nm != null:
		nm.text = action_text
	var dive_nm: = _label("Dive")
	if dive_nm != null:
		dive_nm.text = m2_text
	_dim("Action", action_on)
	_dim("Set", set_on)
	_dim("Dive", dive_on)
	_dim("Jump", jump_on)


func _set_row_action(id: String, action: String) -> void :
	if String(_actions.get(id, "")) == action:
		return
	_actions[id] = action
	_refresh_glyphs()

func _label(id: String) -> Label:
	var row: = _rows.get(id) as Control
	return row.get_node_or_null("Name") as Label if row != null else null

func _dim(id: String, on: bool) -> void :
	var row: = _rows.get(id) as Control
	if row != null:
		row.modulate.a = 1.0 if on else 0.35


func set_dive(cooldown: float) -> void :
	var tile: = _rows.get("Dive") as Control
	if tile == null:
		return
	if _dive_count == null:
		var host: = tile.find_child("Icon", true, false) as Control
		if host == null:
			host = tile
		_dive_count = Label.new()
		_dive_count.add_theme_font_size_override("font_size", 26)
		_dive_count.add_theme_color_override("font_color", Color(1, 1, 1))
		_dive_count.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		_dive_count.add_theme_constant_override("outline_size", 6)
		_dive_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_dive_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_dive_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(_dive_count)
		_dive_count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_dive_icon = host
	var charging: = cooldown > 0.0
	_dive_count.visible = charging
	if charging:
		_dive_count.text = "%d" % ceili(cooldown)


	if _dive_icon != null:
		_dive_icon.self_modulate.a = 0.4 if charging else 1.0



func dive_denied() -> void :
	var tile: = _rows.get("Dive") as Control
	if tile == null:
		return
	if _dive_deny_tween != null and _dive_deny_tween.is_valid():
		_dive_deny_tween.kill()
		tile.position = _dive_tile_rest
	else:
		_dive_tile_rest = tile.position
	var rest: = _dive_tile_rest
	var red: = Color(1.0, 0.3, 0.3)
	if _dive_count != null:
		_dive_count.add_theme_color_override("font_color", red)
	if _dive_icon != null:
		_dive_icon.self_modulate = Color(red, _dive_icon.self_modulate.a)
	_dive_deny_tween = create_tween()
	_dive_deny_tween.set_ignore_time_scale(true)
	for i in 5:
		var off: = Vector2((-1.0 if i % 2 == 0 else 1.0) * (7.0 - float(i)), 0.0)
		_dive_deny_tween.tween_property(tile, "position", rest + off, 0.035)
	_dive_deny_tween.tween_property(tile, "position", rest, 0.04)
	_dive_deny_tween.tween_callback( func():
		if _dive_count != null:
			_dive_count.add_theme_color_override("font_color", Color(1, 1, 1))
		if _dive_icon != null:
			_dive_icon.self_modulate = Color(1.0, 1.0, 1.0, _dive_icon.self_modulate.a))
