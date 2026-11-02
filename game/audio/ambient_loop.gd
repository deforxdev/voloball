extends AudioStreamPlayer







func _ready() -> void :



	bus = &"ambient"
	finished.connect(_replay)
	if autoplay and not playing:
		play()

func _replay() -> void :
	play()
