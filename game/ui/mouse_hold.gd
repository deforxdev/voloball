class_name MouseHold
extends Node







func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void :
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
