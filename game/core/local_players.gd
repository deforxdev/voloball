extends Node


















signal roster_changed


signal bindings_changed(slot: LocalPlayerSlot)


signal slot_connection_changed(slot: LocalPlayerSlot, connected: bool)




signal devices_changed




const MAX_LOCAL: = 4

var slots: Array[LocalPlayerSlot] = []




var watch_joins: = false


var primary_device: = DeviceInput.KBM



const UI_ACTIONS: PackedStringArray = ["menu_start", "ui_cancel", "ui_accept", 
	"ui_up", "ui_down", "ui_left", "ui_right", 
	"menu_zone_next", "menu_zone_prev"]





var ui_owner: = DeviceInput.MERGED



var locker_device: = DeviceInput.MERGED
var locker_return: = -1
var _ui_input: = DeviceInput.new()
var _start_prev: = {}


var _next_ls: = 1
var _enter_prev: = false

func _ready() -> void :
	_ensure_primary()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	ProfileStore.changed.connect(_on_profile_changed)






func _on_profile_changed() -> void :
	if locker_return >= 0 or slots.is_empty():
		return
	var p: = ProfileStore.active()
	if p != null:
		slots[0].profile = p

var _watch_prev: = false

func _process(_dt: float) -> void :


	if watch_joins:




		if not _watch_prev:
			for pad in Input.get_connected_joypads():
				_start_prev[pad] = Input.is_joy_button_pressed(pad, JOY_BUTTON_A)
			_enter_prev = Input.is_physical_key_pressed(KEY_ENTER)


		_watch_for_joins()
		_track_primary_device()
	else:



		_track_primary_device()
	_watch_prev = watch_joins
	if ui_owner == DeviceInput.MERGED:
		_ui_input.device = DeviceInput.MERGED



		_ui_input.exclude_pads = p1_exclude_pads()
		_ui_input.exclude_kbm = kbm_taken()
	else:
		_ui_input.device = ui_owner
		_ui_input.exclude_pads = PackedInt32Array()
		_ui_input.exclude_kbm = false
	_ui_input.poll(UI_ACTIONS)





func ui_just_pressed(action: String) -> bool:
	return _ui_input.just_pressed(action)

func ui_pressed(action: String) -> bool:
	return _ui_input.pressed(action)



func primary_just_pressed(action: String) -> bool:
	return ui_owner == DeviceInput.MERGED and _ui_input.just_pressed(action)

func primary_pressed(action: String) -> bool:
	return ui_owner == DeviceInput.MERGED and _ui_input.pressed(action)


func take_ui(device: int) -> void :
	ui_owner = device

func release_ui() -> void :
	ui_owner = DeviceInput.MERGED






func consume_foreign_ui(event: InputEvent) -> bool:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if ui_owner >= 0:
			return event.device != ui_owner
		return event.device in claimed_pads()
	if event is InputEventKey or event is InputEventMouse:
		if ui_owner >= 0:
			return true
		return kbm_taken()
	return false






func is_leader(slot: LocalPlayerSlot) -> bool:
	return slot != null and slot.index == 0

func leader_holds_ui() -> bool:
	return ui_owner == DeviceInput.MERGED




func claimed_pads() -> PackedInt32Array:
	var out: = PackedInt32Array()
	for s in slots:
		if s.device >= 0:
			out.append(s.device)
	return out







func p1_exclude_pads() -> PackedInt32Array:
	var out: = claimed_pads()
	for pad in Input.get_connected_joypads():
		if pad == primary_device:
			continue
		if pad not in out:
			out.append(pad)
	return out


func kbm_taken() -> bool:
	for s in slots:
		if s.index > 0 and s.device == DeviceInput.KBM:
			return true
	return false

func slot_for_device(device: int) -> LocalPlayerSlot:
	for s in slots:
		if s.device == device:
			return s
	return null










func _on_joy_connection_changed(device: int, connected: bool) -> void :


	devices_changed.emit()
	if not connected:
		var gone: = slot_for_device(device)
		if gone == null or gone.index == 0:
			return
		gone.connected = false
		slot_connection_changed.emit(gone, false)
		return
	var guid: = Input.get_joy_guid(device)
	var back: = _lost_slot_for(device, guid)
	if back == null:
		return
	back.device = device
	back.guid = guid
	back.connected = true
	if back.collector != null:
		back.collector.set_device(device)
	refresh_bindings(back)
	slot_connection_changed.emit(back, true)

func _lost_slot_for(device: int, guid: String) -> LocalPlayerSlot:
	for s in slots:
		if not s.connected and s.device == device:
			return s
	for s in slots:
		if not s.connected and guid != "" and s.guid == guid:
			return s
	return null

func _track_primary_device() -> void :



	if not kbm_taken() and not InputPrompts.using_gamepad():
		primary_device = DeviceInput.KBM
		return

	for pad in Input.get_connected_joypads():
		if slot_for_device(pad) != null:
			continue
		if _pad_active(pad):
			primary_device = pad
			return




var can_join: = Callable()
signal join_refused(reason: String)

func _join_allowed() -> bool:
	if can_join.is_valid() and not bool(can_join.call()):
		join_refused.emit("party is full")
		return false
	return true

func _watch_for_joins() -> void :
	for pad in Input.get_connected_joypads():
		var down: bool = Input.is_joy_button_pressed(pad, JOY_BUTTON_A)
		var was: bool = _start_prev.get(pad, false)
		_start_prev[pad] = down
		if not down or was:
			continue
		if pad == primary_device:
			continue
		if slot_for_device(pad) != null:
			continue
		join(pad)


	var enter: = Input.is_physical_key_pressed(KEY_ENTER)
	var was_enter: = _enter_prev
	_enter_prev = enter
	if enter and not was_enter and primary_device >= 0 and not kbm_taken()\
	and not _typing():
		join(DeviceInput.KBM)



func _typing() -> bool:
	var vp: = get_viewport()
	if vp == null:
		return false
	var foc: = vp.gui_get_focus_owner()
	return foc is LineEdit or foc is TextEdit




func _pad_active(pad: int) -> bool:
	if absf(Input.get_joy_axis(pad, JOY_AXIS_LEFT_X)) > 0.5:
		return true
	if absf(Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y)) > 0.5:
		return true
	for b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, 
			JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, 
			JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_START]:
		if Input.is_joy_button_pressed(pad, b):
			return true
	return false

func _ensure_primary() -> void :
	if not slots.is_empty():
		return
	var s: = LocalPlayerSlot.new()
	s.device = DeviceInput.MERGED
	s.profile = ProfileStore.active()
	s.index = 0
	s.ls = 0
	slots.append(s)

func primary() -> LocalPlayerSlot:
	_ensure_primary()
	return slots[0]




func primary_name() -> String:
	var p: = primary()
	if p != null and p.profile != null and p.profile.name.strip_edges() != "":
		return p.profile.name
	return Net.local_display_name()

func count() -> int:
	return slots.size()



func has_guests() -> bool:
	return slots.size() > 1



func join(device: int) -> LocalPlayerSlot:
	if device == DeviceInput.MERGED:
		return null
	if slots.size() >= MAX_LOCAL:
		return null
	if slot_for_device(device) != null:
		return null
	if not _join_allowed():
		return null
	var slot: = LocalPlayerSlot.new()
	slot.device = device
	slot.guid = Input.get_joy_guid(device) if device >= 0 else ""
	slot.index = slots.size()
	slot.ls = _next_ls
	_next_ls += 1




	slot.profile = temp_guest()
	slot.is_temp = true
	slots.append(slot)
	_stamp_guest_name(slot)
	roster_changed.emit()
	return slot



func leave(device: int) -> void :
	for i in range(slots.size() - 1, 0, -1):
		if slots[i].device == device:
			slots.remove_at(i)
			_reindex()
			roster_changed.emit()
			return


func reset_to_primary() -> void :
	if slots.size() <= 1:
		return
	slots.resize(1)
	release_ui()
	roster_changed.emit()

func _reindex() -> void :
	for i in slots.size():
		slots[i].index = i
		_stamp_guest_name(slots[i])



func _host_name() -> String:
	var p: = primary()
	if p != null and p.profile != null and p.profile.name != "":
		return p.profile.name
	return "player"

func _stamp_guest_name(slot: LocalPlayerSlot) -> void :
	if slot != null and slot.is_temp and slot.profile != null:
		slot.profile.name = "%s[%d]" % [_host_name(), slot.index + 1]




func set_device(slot: LocalPlayerSlot, device: int) -> bool:
	if slot == null or device == DeviceInput.MERGED:
		return false
	if device >= 0 and not (device in Input.get_connected_joypads()):
		return false
	var holder: = slot_for_device(device)
	if holder != null and holder != slot:
		return false
	slot.device = device
	slot.guid = Input.get_joy_guid(device) if device >= 0 else ""
	slot.connected = true
	if slot.collector != null:
		slot.collector.set_device(device)
	refresh_bindings(slot)
	roster_changed.emit()
	return true







func refresh_bindings(slot: LocalPlayerSlot) -> void :
	if slot == null:
		return
	if slot.collector != null:
		slot.collector.set_bindings(slot.binding_table())
	bindings_changed.emit(slot)

func profile_choices(slot: LocalPlayerSlot) -> Array:
	var out: Array = []
	for i in range(1, ProfileStore.profiles.size()):
		var p: SavedProfile = ProfileStore.profiles[i]
		var taken: = false
		for s in slots:
			if s != slot and s.profile == p:
				taken = true
				break
		if not taken:
			out.append({"label": p.name, "profile": p})

	out.append({"label": "guest", "profile": null, "guest": true})
	return out





func create_profile_for(slot: LocalPlayerSlot) -> SavedProfile:
	if slot == null:
		return null
	var made: = ProfileStore.create_profile("Player %d" % (slot.index + 1))
	if made == null:
		return null
	slot.profile = made
	slot.is_temp = false
	refresh_bindings(slot)
	roster_changed.emit()
	return made



func apply_choice(slot: LocalPlayerSlot, choice: Dictionary) -> void :
	if slot == null or choice.is_empty():
		return
	if bool(choice.get("guest", false)):
		slot.profile = temp_guest()
		slot.is_temp = true
		_stamp_guest_name(slot)
	else:
		slot.profile = choice.get("profile")
		slot.is_temp = false
	refresh_bindings(slot)
	roster_changed.emit()



func temp_guest() -> SavedProfile:
	var g: = SavedProfile.new()
	g.name = "Guest"
	g.character = CharacterConfig.random(null, true, g).to_dict()
	return g
