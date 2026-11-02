extends Node3D







var rev_per_s: = 2.0

func _process(_delta: float) -> void :
	var a: = fmod(Time.get_ticks_msec() / 1000.0 * rev_per_s, 1.0) * TAU
	transform.basis = Basis(Vector3.UP, a)
