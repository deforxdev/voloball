class_name UiSfxPack
extends Resource






@export var press: Array[AudioStream] = []
@export var confirm: Array[AudioStream] = []
@export var back: Array[AudioStream] = []
@export var toggle_on: Array[AudioStream] = []
@export var toggle_off: Array[AudioStream] = []
@export var open: Array[AudioStream] = []
@export var close: Array[AudioStream] = []
@export var celebrate: Array[AudioStream] = []
@export var wipe_in: Array[AudioStream] = []
@export var wipe_out: Array[AudioStream] = []
@export var tick: Array[AudioStream] = []
@export var slide: Array[AudioStream] = []
@export var hover: Array[AudioStream] = []


@export var coin: Array[AudioStream] = []




@export var claim: Array[AudioStream] = []
@export var claim_all: Array[AudioStream] = []

@export var level_up: Array[AudioStream] = []



@export var pause: Array[AudioStream] = []
@export var unpause: Array[AudioStream] = []
@export var purchase: Array[AudioStream] = []
@export var error: Array[AudioStream] = []
@export var warning: Array[AudioStream] = []
@export var lock: Array[AudioStream] = []
@export var unlock: Array[AudioStream] = []


@export var scrub: Array[AudioStream] = []

@export var volumes: = {
	"press": -10.0, "confirm": -8.0, "back": -12.0, 
	"toggle_on": -10.0, "toggle_off": -12.0, 
	"open": -12.0, "close": -14.0, "celebrate": -8.0, 
	"wipe_in": -10.0, "wipe_out": -12.0, 
	"tick": -14.0, "slide": -18.0, "hover": -15.0, 


	"coin": -11.0, "claim": 0.0, "claim_all": 0.0, "level_up": -6.0, 
	"pause": -9.0, "unpause": -10.0, "purchase": -7.0, "error": -10.0, 
	"warning": -8.0, "lock": -10.0, "unlock": -9.0, "scrub": -12.0, 
}

func streams(role: String) -> Array:
	var v: Variant = get(role)
	return v if v is Array else []

func volume(role: String) -> float:
	return float(volumes.get(role, -10.0))
