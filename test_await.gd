extends Node

func _ready() -> void :
	print("AWAIT TEST start")
	for i in 5:
		await get_tree().process_frame
		print("frame ", i)
	print("AWAIT TEST done")
	get_tree().quit()
