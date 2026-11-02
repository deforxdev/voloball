class_name TitleEffect
extends Resource




























@export var id: = ""
@export var label: = ""
@export var order: = 0



@export var price: = 400

@export var shader: Shader

@export var letters: = ""
@export var font_path: = ""



@export var font_scale: = 1.0


@export var font_crisp: = false


@export var font_lift: = 0.0
@export var art_path: = ""
@export var ends: = false
@export var ends_knob: = -1



@export var stage: = ""



@export var corner: = false
@export var corner_knob: = -1
@export var corner_size_knob: = -1


@export var plate_follows_letters: = false


@export var hz: = 30.0




@export var knobs: PackedStringArray = []
@export var knob_defaults: PackedFloat32Array = []
@export var accent: = ""
@export var accent_default: = Color.WHITE



@export var choices: = {}



@export var suit_fg: = ""
@export var suit_bg: = ""
@export var suit_ol: = ""
@export var suit_th: = 0


func knob_default(i: int) -> float:
	return clampf(knob_defaults[i], 0.0, 1.0) if i < knob_defaults.size() else 0.5


func options(i: int) -> PackedStringArray:
	if i < 0 or i >= knobs.size():
		return PackedStringArray()
	return PackedStringArray(choices.get(knobs[i], []))


func option_at(i: int, value: float) -> int:
	var n: = options(i).size()
	return clampi(roundi(clampf(value, 0.0, 1.0) * (n - 1)), 0, maxi(n - 1, 0))


func option_value(i: int, k: int) -> int:
	var n: = options(i).size()
	return roundi(100.0 * k / (n - 1)) if n > 1 else 0


func picture() -> String:
	return Stage.thumb_path(stage) if stage != "" else art_path
