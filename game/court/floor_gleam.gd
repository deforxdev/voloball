extends MeshInstance3D







func _ready() -> void :
	visible = GameConfig.floor_sunlight

func _process(_dt: float) -> void :
	if visible != GameConfig.floor_sunlight:
		visible = GameConfig.floor_sunlight
