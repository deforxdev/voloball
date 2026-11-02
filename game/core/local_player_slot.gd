class_name LocalPlayerSlot
extends RefCounted












const COLORS: Array[Color] = [
	Color(0.13, 0.53, 1.0), 
	Color(0.58, 0.28, 1.0), 
	Color(1.0, 0.51, 0.05), 
	Color(1.0, 0.16, 0.22), 
]

var device: = DeviceInput.MERGED
var profile: SavedProfile = null
var is_temp: = false
var team_side: = 0
var collector: InputCollector = null



var guid: = ""
var connected: = true
var index: = 0




var ls: = 0




func make_collector() -> InputCollector:
	collector = InputCollector.new()
	collector.set_device(device)
	collector.set_bindings(binding_table())
	return collector




func binding_table() -> Dictionary:
	if device == DeviceInput.MERGED or profile == null:
		return {}
	return InputBinds.resolve(profile.bindings)

func display_name() -> String:
	if profile != null:
		return profile.name
	return "Guest"


func tag() -> String:
	return "p%d" % (index + 1)

func color() -> Color:
	return COLORS[index % COLORS.size()]

func is_primary() -> bool:
	return index == 0

func on_keyboard() -> bool:
	return device == DeviceInput.KBM
