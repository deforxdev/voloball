class_name Crosshair
extends RefCounted










const PACK: = "res://game/kny/cursorpack/PNG/Basic/Default/%s.png"


const SHAPES: = [
	{"id": "cross_small", "label": "cross", "file": "cross_small"}, 
	{"id": "cross_large", "label": "bold cross", "file": "cross_large"}, 
	{"id": "line_cross", "label": "thin cross", "file": "line_cross"}, 
	{"id": "dot_small", "label": "dot", "file": "dot_small"}, 
	{"id": "dot_large", "label": "big dot", "file": "dot_large"}, 
]

const DEFAULT_SHAPE: = "line_cross"


const DEFAULT_COLORS: = [
	Color(1, 1, 1), 
	Color(0.72, 0.53, 0.95), 
	Color(0.99, 0.64, 0.25), 
	Color(0.92, 0.28, 0.29), 
]

static var _cache: = {}

static func _entry(id: String) -> Dictionary:
	for s in SHAPES:
		if String(s.id) == id:
			return s
	return SHAPES[0]


static func tex(id: String) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var path: String = PACK % String(_entry(id).file)
	var t: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[id] = t
	return t

static func label(id: String) -> String:
	return String(_entry(id).label)

static func default_color(index: int) -> Color:
	return DEFAULT_COLORS[index % DEFAULT_COLORS.size()]

static func is_valid(id: String) -> bool:
	for s in SHAPES:
		if String(s.id) == id:
			return true
	return false
