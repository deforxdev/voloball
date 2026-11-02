@tool
extends WorldEnvironment






func _ready() -> void :
	if not Engine.is_editor_hint():
		queue_free()
