extends Node









const MENU: = "res://game/ui/menu.tscn"

var _split: LockerSplit = null
var _leaving: = false

func _ready() -> void :
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	MusicManager.set_muffled(true)
	var plist: Array = []
	for slot in LocalPlayers.slots:
		plist.append(_player_for(slot))
	_split = LockerSplit.new()
	_split.players = plist

	_split.start_page = String(Engine.get_meta("split_page", "locker"))
	if Engine.has_meta("split_page"):
		Engine.remove_meta("split_page")
	_split.all_ready.connect(_on_all_ready)
	add_child(_split)
	LocalPlayers.slot_connection_changed.connect(_on_slot_connection)

func _player_for(slot: LocalPlayerSlot) -> Dictionary:
	var dev: int = slot.device
	var prof: SavedProfile = slot.profile
	if slot.index == 0:

		dev = LocalPlayers.primary_device
		prof = ProfileStore.active()
	var kbm: = dev == DeviceInput.KBM or dev == DeviceInput.MERGED
	var source: DeviceInput = null
	if dev >= 0:
		source = DeviceInput.new(dev)
	elif dev == DeviceInput.MERGED:


		source = DeviceInput.new(DeviceInput.MERGED)
		source.exclude_pads = LocalPlayers.p1_exclude_pads()
	if slot.index > 0 and source != null:
		source.bindings = slot.binding_table()
	return {"profile": prof, "color": slot.color(), "tag": "P%d" % (slot.index + 1), 
		"source": source, "kbm": kbm}

func _on_slot_connection(slot: LocalPlayerSlot, connected: bool) -> void :
	if _split != null and slot != null:
		_split.set_connected(slot.index, connected)

func _on_all_ready() -> void :
	if _leaving:
		return
	_leaving = true
	UiStyle.sfx("celebrate")

	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self):
		return
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene(MENU))

func _exit_tree() -> void :
	if LocalPlayers.slot_connection_changed.is_connected(_on_slot_connection):
		LocalPlayers.slot_connection_changed.disconnect(_on_slot_connection)
