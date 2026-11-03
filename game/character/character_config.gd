class_name CharacterConfig
extends RefCounted











const SKIN_TONES: Array[Color] = [
	Color(1.0, 0.98, 0.97), 
	Color(0.99, 0.95, 0.9), Color(0.98, 0.92, 0.84), Color(1.0, 0.87, 0.73), 
	Color(0.96, 0.8, 0.63), Color(0.9, 0.71, 0.52), Color(0.8, 0.6, 0.42), 
	Color(0.66, 0.47, 0.32), Color(0.52, 0.36, 0.24), Color(0.4, 0.27, 0.18), 
	Color(0.28, 0.19, 0.13), 
	Color(0.18, 0.12, 0.09), 
]
const HAIR_COLORS: Array[Color] = [
	Color(0.13, 0.1, 0.08), Color(0.28, 0.19, 0.11), Color(0.48, 0.32, 0.15), 
	Color(0.72, 0.55, 0.26), Color(0.87, 0.79, 0.55), Color(0.55, 0.09, 0.06), 
	Color(0.35, 0.35, 0.38), Color(0.88, 0.88, 0.9), Color(0.24, 0.35, 0.65), 
	Color(0.55, 0.25, 0.6), Color(0.85, 0.45, 0.65), Color(0.2, 0.55, 0.4), 
]







const HAIR_DIR: = "res://game/character/hair"
static var _hair_cache: Array[String] = []
















static func hair_style_from_file(file_name: String) -> String:
	var base: = file_name
	for wrapper in [".remap", ".import"]:
		if base.ends_with(wrapper):
			base = base.trim_suffix(wrapper)
			break
	if not base.ends_with(".glb"):
		return ""
	return base.trim_suffix(".glb")

static func hair_meshes() -> Array[String]:


	if not _hair_cache.is_empty():
		return _hair_cache
	var found: Array[String] = []
	var dir: = DirAccess.open(HAIR_DIR)
	if dir != null:
		for f in dir.get_files():
			var style: = hair_style_from_file(String(f))
			if style != "" and not found.has(style):
				found.append(style)
		found.sort()
	_hair_cache = ([""] as Array[String]) + found
	return _hair_cache

static func hair_names() -> Array[String]:

	var out: Array[String] = ["bald"]
	var list: = hair_meshes()
	for i in range(1, list.size()):
		out.append(list[i].replace("_", " "))
	return out








const FACIAL_HAIR_DIR: = "res://game/character/facial_hair"
const FACIAL_HAIR_ROLL_CHANCE: = 0.12
static var _facial_cache: Array[String] = []

static func facial_hair_meshes() -> Array[String]:
	if not _facial_cache.is_empty():
		return _facial_cache
	var found: Array[String] = []
	var dir: = DirAccess.open(FACIAL_HAIR_DIR)
	if dir != null:
		for f in dir.get_files():
			var style: = hair_style_from_file(String(f))
			if style != "" and not found.has(style):
				found.append(style)
		found.sort()
	_facial_cache = ([""] as Array[String]) + found
	return _facial_cache

static func facial_hair_names() -> Array[String]:
	var out: Array[String] = ["none"]
	var list: = facial_hair_meshes()
	for i in range(1, list.size()):
		out.append(list[i].replace("_", " "))
	return out



static func facial_hair_index_of(value: Variant) -> int:
	var list: = facial_hair_meshes()
	if value is String:
		var i: = list.find(String(value))
		return i if i >= 0 else 0
	if value is int or value is float:
		return clampi(int(value), 0, list.size() - 1)
	return 0

func facial_hair_style_name() -> String:
	var list: = facial_hair_meshes()
	return list[clampi(facial_hair, 0, list.size() - 1)]

static var _facial_slot_cache: = {}



static func facial_hair_slot_defaults(style: int) -> Array:
	if _facial_slot_cache.has(style):
		return _facial_slot_cache[style]
	var out: Array = []
	var list: = facial_hair_meshes()
	if style > 0 and style < list.size():
		var path: = "%s/%s.glb" % [FACIAL_HAIR_DIR, list[style]]
		if ResourceLoader.exists(path):
			var root: Node = (load(path) as PackedScene).instantiate()
			for g in AccessoryItem.build_groups(root):
				out.append(AccessoryItem._albedo_of(g["src"]))
			root.free()
	_facial_slot_cache[style] = out
	return out



func facial_hair_color_at(i: int) -> Color:
	if i >= 0 and i < facial_hair_cols.size() and String(facial_hair_cols[i]) != "":
		return Color.html(str(facial_hair_cols[i]))
	return hair_color()

func set_facial_hair_color_at(i: int, color: Color) -> void :
	while facial_hair_cols.size() <= i:
		facial_hair_cols.append("")
	facial_hair_cols[i] = color.to_html(false)


func match_facial_hair_to_hair() -> void :
	facial_hair_cols = []

func facial_hair_custom() -> bool:
	for v in facial_hair_cols:
		if String(v) != "":
			return true
	return false




static func hair_styles() -> int:
	return hair_meshes().size()
const EYE_SHAPES: = 4
const BROW_SHAPES: = 3
const MOUTH_SHAPES: = 5
const NOSE_SHAPES: = 3

const FACE_TYPES: = 2



const HEAD_SHAPES: Array[String] = ["", "sharp", "square", "round"]
const HEAD_SHAPE_NAMES: Array[String] = ["default", "sharp", "square", "round"]








static var EAR_SHAPES: Array[String] = []


static func ear_names() -> Array[String]:
	var out: Array[String] = ["default"]
	for nm in EAR_SHAPES:
		out.append(String(nm).replace("_", " ").to_lower())
	return out


func ear_index() -> int:
	var at: = EAR_SHAPES.find(ear_shape)
	return at + 1 if at >= 0 else 0

func set_ear_index(i: int) -> void :
	ear_shape = EAR_SHAPES[i - 1] if i >= 1 and i <= EAR_SHAPES.size() else ""


const SHORTS_SHAPES: Array[String] = ["", "short", "long", "supershort"]
const SHORTS_SHAPE_NAMES: Array[String] = ["regular", "short", "long", "super short"]


const SOCKS_SHAPES: Array[String] = ["Short", ""]
const SOCKS_SHAPE_NAMES: Array[String] = ["short", "long"]



const SHIRT_SHAPES: Array[String] = ["", "tanktop", "sports bra"]




const SHIRT_SHAPE_NAMES: Array[String] = ["tee", "tank top", "sports bra", "hoodie"]
const HOODIE_SHIRT: = 3



const KNEEPAD_STYLE_NAMES: Array[String] = ["short", "long"]



const KNEEPAD_SIDE_NAMES: Array[String] = ["both", "right", "left"]











const BLUSH_DIR: = "res://game/character/faces/blush"
const BLUSH_BUILT_IN: Array[String] = ["circle", "dashes", "band", "freckles"]
static var _blush_list: Array[String] = []

static func blush_shapes() -> Array[String]:
	if _blush_list.is_empty():
		_blush_list.assign(BLUSH_BUILT_IN)
		var more: Array[String] = []

		for f in DirAccess.get_files_at(BLUSH_DIR):
			var file: = String(f).trim_suffix(".import").trim_suffix(".remap")
			if file.get_extension().to_lower() != "png":
				continue
			var key: = file.get_basename()
			if not key in _blush_list and not key in more and _plain_name(key, EAR_NAME_MAX):
				more.append(key)
		more.sort()
		_blush_list.append_array(more)
	return _blush_list

static func blush_shape_key(i: int) -> String:
	var list: = blush_shapes()
	return list[clampi(i, 0, list.size() - 1)]


static func blush_shape_name(i: int) -> String:
	return blush_shape_key(i).replace("_", " ").to_lower()


const VOICE_PITCH: Array[float] = [0.78, 0.92, 1.0, 1.12, 1.3]
const VOICE_NAMES: Array[String] = ["rough", "low", "regular", "high", "squeaky"]

var display_name: = ""
var face: = 0
var skin: = 0



var skin_custom: = false
var skin_col: = SKIN_TONES[3]
var height: = 0.5
var weight: = 0.5
var hair: = 1:
	set(v):
		hair = v
		hair_missing = ""





var hair_missing: = ""
const HAIR_NAME_MAX: = 32
var hair_flip: = false
var hair_color_idx: = 0
var hair_col: = HAIR_COLORS[0]






var hair_cols: Array = []



var hair_grads: Array = []



var facial_hair: = 0
var facial_hair_cols: Array = []



var fh_px: = 0.5
var fh_py: = 0.5
var fh_pz: = 0.5
var fh_rx: = 0.5
var fh_ry: = 0.5
var fh_rz: = 0.5
var fh_sc: = 0.5
var fh_sx: = 0.5
var fh_sy: = 0.5
var fh_sz: = 0.5

const FACIAL_XF: = {"fpx": "fh_px", "fpy": "fh_py", "fpz": "fh_pz", 
	"frx": "fh_rx", "fry": "fh_ry", "frz": "fh_rz", 
	"fsc": "fh_sc", "fsx": "fh_sx", "fsy": "fh_sy", "fsz": "fh_sz"}

func reset_facial_transform() -> void :
	for key in FACIAL_XF:
		set(FACIAL_XF[key], 0.5)
var eye_shape: = 0





var eye_color: = Color.BLACK
var lash_color: = Color.BLACK

var brow_color: = Color.BLACK
var eye_size: = 0.5
var eye_width: = 0.5
var eye_size_y: = 0.5
var eye_height: = 0.5
var eye_spacing: = 0.5
var eye_rot: = 0.5
var eye_x: = 0.5
var brow_shape: = 0
var brow_height: = 0.5
var brow_rot: = 0.5
var brow_spacing: = 0.5
var brow_size: = 0.5
var brow_width: = 0.5
var brow_size_y: = 0.5
var brow_x: = 0.5
var mouth_shape: = 0
var mouth_size: = 0.5
var mouth_width: = 0.5
var mouth_size_y: = 0.5
var mouth_height: = 0.5
var mouth_rot: = 0.5
var mouth_x: = 0.5
var nose_shape: = 0
var nose_size: = 0.5
var nose_width: = 0.5
var nose_size_y: = 0.5
var nose_height: = 0.5
var nose_x: = 0.5
var nose_flip: = false
var blush: = false


var blush_shape: = 0
var blush_color: = Color(0.96, 0.52, 0.52)
var blush_size: = 0.5
var blush_width: = 0.5
var blush_height: = 0.5
var blush_spacing: = 0.5
var blush_opacity: = 0.5
var head_shape: = 0
var ear_shape: = ""




var title: = {}



var level: = 0
var gym_shirt: = 0





var hoodie_color: = Color(0.3, 0.55, 0.95)
var hoodie_custom: = false
var voice: = 2



var v_pitch: = 0.5
var v_speed: = 0.5



var voice_pack: = 1




const VOICE_PACK_COUNT: = 1


var left_handed: = false
const KIT_BLACK: = Color(0.09, 0.09, 0.11)






var captain_kit: Array = [Color(0.3, 0.55, 0.95), KIT_BLACK, Color.WHITE, Color.WHITE]

var kit_home: Array:
	get:
		return captain_kit
	set(v):
		captain_kit = v
var number: = 1






const ACC_CATEGORIES: = ["head", "face", "extra"]
const ACC_PER_CATEGORY: = 3
const ACC_SLOTS: = ["head", "head2", "head3", "face", "face2", "face3", 
	"extra", "extra2", "extra3"]






var accessories: Dictionary = {}







var gym_tee: = Color(0.93, 0.92, 0.89)
var gym_shorts: = Color(0.38, 0.56, 0.84)



var casual: = false





var wear_pinny: = false
var pinny_color: = Color(0.55, 0.85, 0.72)


var pinny_accent: = Color(0.1, 0.11, 0.14)


const GYM_TEE_COLORS: Array[Color] = [
	Color(0.93, 0.92, 0.89), Color(0.82, 0.82, 0.84), Color(0.25, 0.26, 0.3), 
	Color(0.3, 0.45, 0.8), Color(0.75, 0.28, 0.26), Color(0.32, 0.55, 0.38), 
	Color(0.88, 0.75, 0.35), Color(0.55, 0.38, 0.65), 
]
const GYM_SHORT_COLORS: Array[Color] = [
	Color(0.2, 0.21, 0.24), Color(0.93, 0.92, 0.89), Color(0.36, 0.42, 0.52), 
	Color(0.62, 0.78, 0.88), Color(0.42, 0.3, 0.26), Color(0.3, 0.45, 0.8), 
]












static func outfit_fit(cfg: CharacterConfig, outfit: String) -> Array:
	match outfit:
		"captain", "home", "away":
			return [cfg, TeamKits.normalize(cfg.captain_kit)]
		"pinny":
			var look: = cfg.gym_look()
			var kit: Array = TeamKits.normalize(cfg.captain_kit)
			look.wear_pinny = true
			look.pinny_color = kit[0]
			look.pinny_accent = TeamKits.number_ink(kit[0])
			return [look, look.gym_kit()]
		_:
			return [cfg.gym_look(), cfg.gym_kit()]

func gym_kit() -> Array:
	return [gym_tee, gym_shorts, gym_tee]



func wears_hoodie() -> bool:
	return gym_shirt == HOODIE_SHIRT



func hoodie_tint(shirt_primary: Color) -> Color:
	return hoodie_color if hoodie_custom else shirt_primary



func gym_look() -> CharacterConfig:
	var c: = CharacterConfig.from_dict(to_dict())
	c.casual = true
	return c











class Gear:
	const FIELDS: = ["shorts_len", "socks_len", "wear_socks", "socks", "wear_kneepads", 
		"kneepad_style", "kneepad_style_l", "kneepad_side", "kneepad_match", "kneepad", 
		"kneepad_l", "shoe_color"]
	var shorts_len: = 0
	var socks_len: = 0
	var wear_socks: = true
	var socks: = Color(0.09, 0.09, 0.11)
	var wear_kneepads: = true
	var kneepad_style: = 0
	var kneepad_style_l: = 0
	var kneepad_side: = 0



	var kneepad_match: = true
	var kneepad: = Color(0.09, 0.09, 0.11)
	var kneepad_l: = Color(0.09, 0.09, 0.11)
	var shoe_color: = Color(0.09, 0.09, 0.11)


	func kneepad_left_color() -> Color:
		return kneepad if kneepad_match else kneepad_l

	func copy() -> Gear:
		var g: = Gear.new()
		for f in FIELDS:
			g.set(f, get(f))
		return g

	func to_dict() -> Dictionary:
		return {"sl": shorts_len, "skl": socks_len, "gso": wear_socks, 
			"sk": socks.to_html(false), "gkp": wear_kneepads, "kps": kneepad_style, 
			"kpsl": kneepad_style_l, "kpw": kneepad_side, "kpm": kneepad_match, 
			"kp": kneepad.to_html(false), "kpl": kneepad_l.to_html(false), 
			"sh": shoe_color.to_html(false)}



	static func read(d: Dictionary, base: Gear = null) -> Gear:
		var g: Gear = base.copy() if base != null else Gear.new()
		if d.has("sl"): g.shorts_len = int(d["sl"])
		if d.has("skl"): g.socks_len = int(d["skl"])
		if d.has("gso"): g.wear_socks = bool(d["gso"])
		if d.has("sk"): g.socks = Color.html(str(d["sk"]))
		if d.has("gkp"): g.wear_kneepads = bool(d["gkp"])
		if d.has("kps"): g.kneepad_style = int(d["kps"])
		if d.has("kpw"): g.kneepad_side = clampi(int(d["kpw"]), 0, 2)
		if d.has("kpm"): g.kneepad_match = bool(d["kpm"])
		if d.has("kp"): g.kneepad = Color.html(str(d["kp"]))
		if d.has("sh"): g.shoe_color = Color.html(str(d["sh"]))


		if d.has("kpsl"):
			g.kneepad_style_l = int(d["kpsl"])
		elif base == null:
			g.kneepad_style_l = g.kneepad_style
		if d.has("kpl"):
			g.kneepad_l = Color.html(str(d["kpl"]))
		elif base == null:
			g.kneepad_l = g.kneepad
		return g

var uniform_gear: = Gear.new()
var gym_gear: = Gear.new()


func worn_gear() -> Gear:
	return gym_gear if casual else uniform_gear

func gear_of(gym: bool) -> Gear:
	return gym_gear if gym else uniform_gear




var shorts_len: int:
	get: return worn_gear().shorts_len
	set(v): worn_gear().shorts_len = v
var socks_len: int:
	get: return worn_gear().socks_len
	set(v): worn_gear().socks_len = v
var wear_socks: bool:
	get: return worn_gear().wear_socks
	set(v): worn_gear().wear_socks = v
var socks: Color:
	get: return worn_gear().socks
	set(v): worn_gear().socks = v
var wear_kneepads: bool:
	get: return worn_gear().wear_kneepads
	set(v): worn_gear().wear_kneepads = v
var kneepad_style: int:
	get: return worn_gear().kneepad_style
	set(v): worn_gear().kneepad_style = v
var kneepad_style_l: int:
	get: return worn_gear().kneepad_style_l
	set(v): worn_gear().kneepad_style_l = v
var kneepad_side: int:
	get: return worn_gear().kneepad_side
	set(v): worn_gear().kneepad_side = v
var kneepad_match: bool:
	get: return worn_gear().kneepad_match
	set(v): worn_gear().kneepad_match = v
var kneepad: Color:
	get: return worn_gear().kneepad
	set(v): worn_gear().kneepad = v
var kneepad_l: Color:
	get: return worn_gear().kneepad_l
	set(v): worn_gear().kneepad_l = v
var shoe_color: Color:
	get: return worn_gear().shoe_color
	set(v): worn_gear().shoe_color = v

func kneepad_left_color() -> Color:
	return worn_gear().kneepad_left_color()

func voice_pitch() -> float:

	var base: = lerpf(0.78, 1.3, clampf(v_pitch, 0.0, 1.0))
	var spd: = lerpf(0.85, 1.18, clampf(v_speed, 0.0, 1.0))
	var raw_rate: = base * spd




	if raw_rate < 1.0:
		var toward_natural: = clampf(inverse_lerp(0.78 * 0.85, 1.0, raw_rate), 0.0, 1.0)
		return lerpf(1.16, 1.0, toward_natural)
	return raw_rate

func skin_tone() -> Color:
	if skin_custom:
		return skin_col
	return SKIN_TONES[clampi(skin, 0, SKIN_TONES.size() - 1)]

func hair_style_name() -> String:
	var list: = hair_meshes()
	return list[clampi(hair, 0, list.size() - 1)]


func hair_saved_name() -> String:
	return hair_missing if hair == 0 and hair_missing != "" else hair_style_name()


static func hair_keepable(value: Variant) -> bool:
	return value is String and not hair_meshes().has(String(value)) and _plain_name(String(value), HAIR_NAME_MAX)



static func hair_index_of(value: Variant) -> int:
	var list: = hair_meshes()
	if value is String:
		var i: = list.find(String(value))
		return i if i >= 0 else 0
	return clampi(int(value), 0, list.size() - 1)

static var _hair_slot_cache: = {}





static func hair_slot_defaults(style: int) -> Array:
	if _hair_slot_cache.has(style):
		return _hair_slot_cache[style]
	var out: Array = []
	var list: = hair_meshes()
	if style > 0 and style < list.size():
		var path: = "%s/%s.glb" % [HAIR_DIR, list[style]]
		if ResourceLoader.exists(path):
			var root: Node = (load(path) as PackedScene).instantiate()
			for g in AccessoryItem.build_groups(root):
				out.append(AccessoryItem._albedo_of(g["src"]))
			root.free()
	_hair_slot_cache[style] = out
	return out

func hair_color() -> Color:

	return hair_color_at(0, hair_col)








func hair_color_at(i: int, _fallback: Color) -> Color:
	if i >= 0 and i < hair_cols.size() and String(hair_cols[i]) != "":
		return Color.html(str(hair_cols[i]))
	return hair_col

func set_hair_color_at(i: int, color: Color) -> void :
	while hair_cols.size() <= i:
		hair_cols.append("")
	hair_cols[i] = color.to_html(false)
	if i == 0:
		hair_col = color


func _hair_grad(i: int) -> Dictionary:
	if i >= 0 and i < hair_grads.size() and hair_grads[i] is Dictionary:
		return hair_grads[i]
	return {}

func _hair_grad_slot(i: int) -> Dictionary:
	while hair_grads.size() <= i:
		hair_grads.append({})
	if not (hair_grads[i] is Dictionary):
		hair_grads[i] = {}
	return hair_grads[i]

func hair_gradient_on(i: int) -> bool:
	return bool(_hair_grad(i).get("on", false))

func set_hair_gradient_on(i: int, on: bool) -> void :
	_hair_grad_slot(i)["on"] = on

func hair_gradient_bottom(i: int, fallback: Color) -> Color:
	var b: = String(_hair_grad(i).get("b", ""))
	return Color.html(b) if b != "" else fallback

func set_hair_gradient_bottom(i: int, color: Color) -> void :
	_hair_grad_slot(i)["b"] = color.to_html(false)



func hair_gradient_fade(i: int) -> Vector2:
	var g: = _hair_grad(i)
	return Vector2(float(g.get("fs", 0.0)), float(g.get("fe", 1.0)))

func set_hair_gradient_fade(i: int, start: float, end: float) -> void :
	var g: = _hair_grad_slot(i)
	g["fs"] = clampf(start, 0.0, 1.0)
	g["fe"] = clampf(end, 0.0, 1.0)

const TITLES: = preload("res://game/titles/title_catalog.gd")

func to_dict() -> Dictionary:
	var d: = look_dict()
	if not title.is_empty():
		d["ttl"] = title.duplicate()
	if level > 0:
		d["lvl"] = level
	return d



func look_dict() -> Dictionary:
	var d: = {
		"name": display_name, "face": face, "skin": skin, "h": height, "w": weight, 
		"skx": skin_custom, "skc": skin_col.to_html(false), 



		"hair": hair_saved_name(), "hc": hair_color_idx, "hfl": hair_flip, 
		"hcol": hair_col.to_html(false), 
		"hcols": hair_cols.duplicate(), 
		"hgrad": hair_grads.duplicate(true), 
		"vp": v_pitch, "vs": v_speed, "lh": left_handed, 
		"es": eye_shape, "eyc": eye_color.to_html(false), 
		"elc": lash_color.to_html(false), "bwc": brow_color.to_html(false), "ez": eye_size, 
		"ew": eye_width, "eyz": eye_size_y, "eh": eye_height, 
		"ex": eye_spacing, "er": eye_rot, "epx": eye_x, 
		"bs": brow_shape, "bh": brow_height, "br": brow_rot, 
		"bsp": brow_spacing, "bsz": brow_size, "bwid": brow_width, 
		"bht": brow_size_y, "bpx": brow_x, 
		"ms": mouth_shape, "mz": mouth_size, "mw": mouth_width, 
		"my": mouth_size_y, "mh": mouth_height, "mr": mouth_rot, "mpx": mouth_x, 
		"ns": nose_shape, "nz": nose_size, "nw": nose_width, 
		"ny": nose_size_y, "nh": nose_height, "nx": nose_x, "nfl": nose_flip, 
		"bz": blush_size, "bw": blush_width, "bhy": blush_height, "bx": blush_spacing, 
		"bo": blush_opacity, "bl": blush, "blsh": blush_shape, 
		"blk": blush_shape_key(blush_shape), 
		"blc": blush_color.to_html(false), 
		"hs": head_shape, "ear": ear_shape, "vo": voice, 
		"vpk": voice_pack, 
		"num": number, 
		"kh": captain_kit.map( func(c): return (c as Color).to_html(false)), 


		"fh": facial_hair_style_name(), "fhcols": facial_hair_cols.duplicate(), 
		"fpx": fh_px, "fpy": fh_py, "fpz": fh_pz, "frx": fh_rx, "fry": fh_ry, 
		"frz": fh_rz, "fsc": fh_sc, "fsx": fh_sx, "fsy": fh_sy, "fsz": fh_sz, 


		"gt": gym_tee.to_html(false), "gs": gym_shorts.to_html(false), 
		"gsh": gym_shirt, 


		"hdc": hoodie_color.to_html(false), "hdx": hoodie_custom, 


		"acc": accessories.duplicate(true), 
	}


	d.merge(uniform_gear.to_dict())
	d["gg"] = gym_gear.to_dict()
	return d







static func _unit(d: Dictionary, key: String, def: float) -> float:
	var v: = float(d.get(key, def))
	return clampf(v, 0.0, 1.0) if is_finite(v) else def







const INT_BOUNDS: = {"face": 63, "skin": 15, "hc": 11, "es": EYE_SHAPES - 1, 
	"bs": BROW_SHAPES - 1, "ms": MOUTH_SHAPES - 1, "ns": NOSE_SHAPES - 1, 
	"blsh": 3, "hs": 3, "sl": 3, "skl": 1, "kps": 1, "kpw": 2, "kpsl": 1, 
	"vo": 4, "num": 99, "gsh": 15, "vpk": VOICE_PACK_COUNT, "lvl": 999}
const BOOL_KEYS: = ["nfl", "hfl", "bl", "lh", "gso", "gkp", "hdx", "kpm", "skx"]
const COLOR_KEYS: = ["hcol", "ec", "eyc", "elc", "bwc", "blc", "sk", "kp", "kpl", "sh", "gt", "gs", "hdc", "skc"]
const UNIT_KEYS: = ["h", "w", "ez", "ew", "eyz", "eh", "ex", "er", "epx", "bh", "br", 
	"bsp", "bsz", "bwid", "bht", "bpx", "mz", "mw", "my", "mh", "mr", "mpx", "nz", 
	"nw", "ny", "nh", "nx", "bz", "bw", "bhy", "bx", "bo", "vp", "vs", 

	"fpx", "fpy", "fpz", "frx", "fry", "frz", "fsc", "fsx", "fsy", "fsz"]



const GEAR_INT_KEYS: = ["sl", "skl", "kps", "kpw", "kpsl"]
const GEAR_BOOL_KEYS: = ["gso", "gkp", "kpm"]
const GEAR_COLOR_KEYS: = ["sk", "kp", "kpl", "sh"]
const ACC_MAX_SLOTS: = 12
const ACC_MAX_KEYS: = 16
const ACC_MAX_COLORS: = 8
const HAIR_MAX_SLOTS: = 8





const FACE_PART_KEYS: = {"es": "eyes", "bs": "brows", "ms": "mouth", "ns": "nose"}
static func _int_bound(k: String) -> int:
	var hi: = int(INT_BOUNDS[k])
	if FACE_PART_KEYS.has(k):
		hi = maxi(hi, FaceParts.count(FACE_PART_KEYS[k]) - 1)
	if k == "blsh":
		hi = maxi(hi, blush_shapes().size() - 1)
	return hi




const NONEABLE_INT_KEYS: = ["bs", "ns"]




static func _scalar_int(v: Variant, hi: int, lo: = 0) -> int:
	if v is int:
		return clampi(v, lo, hi)
	if v is float and is_finite(v):
		return clampi(int(v), lo, hi)
	return lo - 1

const EAR_NAME_MAX: = 40



static func _plain_name(text: String, limit: int) -> bool:
	if text.is_empty() or text.length() > limit:
		return false
	for i in text.length():
		var ch: = text.unicode_at(i)
		var ok: = (ch >= 48 and ch <= 57) or (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122) or ch == 32 or ch == 95 or ch == 45 or ch == 46
		if not ok:
			return false
	return true




static func _sanitize_gear(src: Variant) -> Dictionary:
	var out: = {}
	if not (src is Dictionary):
		return out
	var d: = src as Dictionary
	for k in GEAR_INT_KEYS:
		if d.has(k):
			var iv: = _scalar_int(d[k], _int_bound(k))
			if iv >= 0:
				out[k] = iv
	for k in GEAR_BOOL_KEYS:
		if d.has(k) and d[k] is bool:
			out[k] = d[k]
	for k in GEAR_COLOR_KEYS:
		if d.has(k) and d[k] is String and Color.html_is_valid(d[k]):
			out[k] = d[k]
	return out

static func sanitize_dict(d: Dictionary) -> Dictionary:
	var out: = {}
	var name: Variant = d.get("name", "")
	if name is String:
		out["name"] = (name as String).substr(0, 24)
	for k in INT_BOUNDS:
		if d.has(k):
			var lo: = -1 if NONEABLE_INT_KEYS.has(k) else 0
			var iv: = _scalar_int(d[k], _int_bound(k), lo)
			if iv >= lo:
				out[k] = iv
	var hair: Variant = d.get("hair", 1)
	if hair_keepable(hair):
		out["hair"] = hair
	elif hair is int or hair is float or hair is String:
		out["hair"] = hair_index_of(hair)



	var ear: Variant = d.get("ear", "")
	if ear is String and _plain_name(ear, EAR_NAME_MAX):
		out["ear"] = ear

	var blk: Variant = d.get("blk", "")
	if blk is String and _plain_name(blk, EAR_NAME_MAX):
		out["blk"] = blk


	var ttl: = TITLES.sanitize(d.get("ttl"))
	if not ttl.is_empty():
		out["ttl"] = ttl
	for k in BOOL_KEYS:
		if d.has(k) and d[k] is bool:
			out[k] = d[k]
	for k in UNIT_KEYS:
		if d.has(k):
			var v: Variant = d[k]
			if v is float or v is int:
				var f: = float(v)
				if is_finite(f):
					out[k] = clampf(f, 0.0, 1.0)
	for k in COLOR_KEYS:
		if d.has(k) and d[k] is String and Color.html_is_valid(d[k]):
			out[k] = d[k]

	var hcols: Variant = d.get("hcols")
	if hcols is Array:
		var clean_h: Array = []
		for v in (hcols as Array):
			if clean_h.size() >= HAIR_MAX_SLOTS:
				break
			if v is String and (String(v) == "" or Color.html_is_valid(v)):
				clean_h.append(String(v))
			else:
				clean_h.append("")
		out["hcols"] = clean_h

	var hgrad: Variant = d.get("hgrad")
	if hgrad is Array:
		var clean_g: Array = []
		for v in (hgrad as Array):
			if clean_g.size() >= HAIR_MAX_SLOTS:
				break
			var g: = {}
			if v is Dictionary:
				var src: = v as Dictionary
				if src.get("on") is bool:
					g["on"] = src["on"]
				if src.get("b") is String and Color.html_is_valid(src["b"]):
					g["b"] = String(src["b"])
				for fk in ["fs", "fe"]:
					var fv: Variant = src.get(fk)
					if (fv is float or fv is int) and is_finite(float(fv)):
						g[fk] = clampf(float(fv), 0.0, 1.0)
			clean_g.append(g)
		out["hgrad"] = clean_g


	var kh: Variant = d.get("kh")
	if kh is Array and ((kh as Array).size() == 3 or (kh as Array).size() == 4):
		var ok: = true
		for c in kh:
			ok = ok and c is String and Color.html_is_valid(c)
		if ok:
			out["kh"] = (kh as Array).duplicate()




	var fh: Variant = d.get("fh", "")
	if fh is String and (fh == "" or _plain_name(fh, EAR_NAME_MAX)):
		out["fh"] = facial_hair_meshes()[facial_hair_index_of(fh)]
	elif fh is int or fh is float:
		out["fh"] = facial_hair_meshes()[facial_hair_index_of(fh)]
	var fhcols: Variant = d.get("fhcols")
	if fhcols is Array:
		var clean_f: Array = []
		for v in (fhcols as Array):
			if clean_f.size() >= HAIR_MAX_SLOTS:
				break
			if v is String and (String(v) == "" or Color.html_is_valid(v)):
				clean_f.append(String(v))
			else:
				clean_f.append("")
		out["fhcols"] = clean_f
	var acc: Variant = d.get("acc", {})
	if acc is Dictionary:
		var clean: = {}
		for slot in acc:
			if clean.size() >= ACC_MAX_SLOTS:
				break
			var st: Variant = acc[slot]
			if not (slot is String) or not (st is Dictionary) or (slot as String).length() > 24:
				continue
			var cs: = {}
			for key in st:
				if cs.size() >= ACC_MAX_KEYS:
					break
				var v: Variant = st[key]
				if not (key is String) or (key as String).length() > 24:
					continue

				if key == "cols" and v is Array:
					var cc: Array = []
					for e in (v as Array):
						if cc.size() >= ACC_MAX_COLORS:
							break
						if e is String and (String(e) == "" or Color.html_is_valid(e)):
							cc.append(String(e))
						else:
							cc.append("")
					cs["cols"] = cc
					continue

				if key == "grads" and v is Array:
					var gg: Array = []
					for e in (v as Array):
						if gg.size() >= ACC_MAX_COLORS:
							break
						var g: = {}
						if e is Dictionary:
							var src: = e as Dictionary
							if src.get("on") is bool:
								g["on"] = src["on"]
							if src.get("b") is String and Color.html_is_valid(src["b"]):
								g["b"] = String(src["b"])
							for fk in ["fs", "fe"]:
								var fv: Variant = src.get(fk)
								if (fv is float or fv is int) and is_finite(float(fv)):
									g[fk] = clampf(float(fv), 0.0, 1.0)
						gg.append(g)
					cs["grads"] = gg
					continue
				if v is String:
					cs[key] = (v as String).substr(0, 48)
				elif (v is float and is_finite(v)) or v is int or v is bool:
					cs[key] = v
			clean[slot] = cs
		out["acc"] = clean

	if d.has("gg"):
		out["gg"] = _sanitize_gear(d["gg"])
	return out

static func from_dict(raw: Dictionary) -> CharacterConfig:
	var d: = sanitize_dict(raw)
	var c: = CharacterConfig.new()
	c.display_name = d.get("name", "")
	c.face = int(d.get("face", 0))
	c.skin = int(d.get("skin", 0))
	c.skin_custom = bool(d.get("skx", false))
	if d.has("skc"):
		c.skin_col = Color.html(str(d["skc"]))
	c.height = _unit(d, "h", 0.5)
	c.weight = _unit(d, "w", 0.5)
	c.hair = hair_index_of(d.get("hair", 1))
	if hair_keepable(d.get("hair", 1)):
		c.hair_missing = String(d["hair"])
	c.hair_flip = bool(d.get("hfl", false))
	c.hair_color_idx = int(d.get("hc", 0))

	if d.has("hcol"):
		c.hair_col = Color.html(str(d["hcol"]))
	else:
		c.hair_col = HAIR_COLORS[clampi(c.hair_color_idx, 0, HAIR_COLORS.size() - 1)]


	if d.has("hcols") and d["hcols"] is Array:
		c.hair_cols = (d["hcols"] as Array).duplicate()
	if d.has("hgrad") and d["hgrad"] is Array:
		c.hair_grads = (d["hgrad"] as Array).duplicate(true)
	c.eye_shape = int(d.get("es", 0))
	c.eye_color = Color.html(str(d.get("eyc", "000000")))
	c.lash_color = Color.html(str(d.get("elc", "000000")))
	c.brow_color = Color.html(str(d.get("bwc", "000000")))
	c.eye_size = _unit(d, "ez", 0.5)
	c.eye_width = _unit(d, "ew", c.eye_size)
	c.eye_size_y = _unit(d, "eyz", c.eye_size)
	c.eye_height = _unit(d, "eh", 0.5)
	c.eye_spacing = _unit(d, "ex", 0.5)
	c.eye_rot = _unit(d, "er", 0.5)
	c.eye_x = _unit(d, "epx", 0.5)
	c.brow_shape = int(d.get("bs", 0))
	c.brow_height = _unit(d, "bh", 0.5)
	c.brow_rot = _unit(d, "br", 0.5)
	c.brow_spacing = _unit(d, "bsp", 0.5)
	c.brow_size = _unit(d, "bsz", 0.5)
	c.brow_width = _unit(d, "bwid", c.brow_size)
	c.brow_size_y = _unit(d, "bht", c.brow_size)
	c.brow_x = _unit(d, "bpx", 0.5)
	c.mouth_shape = int(d.get("ms", 0))
	c.mouth_size = _unit(d, "mz", 0.5)
	c.mouth_width = _unit(d, "mw", c.mouth_size)
	c.mouth_size_y = _unit(d, "my", c.mouth_size)
	c.mouth_height = _unit(d, "mh", 0.5)
	c.mouth_rot = _unit(d, "mr", 0.5)
	c.mouth_x = _unit(d, "mpx", 0.5)
	c.nose_shape = int(d.get("ns", 0))
	c.nose_size = _unit(d, "nz", 0.5)
	c.nose_width = _unit(d, "nw", c.nose_size)
	c.nose_size_y = _unit(d, "ny", c.nose_size)
	c.nose_height = _unit(d, "nh", 0.5)
	c.nose_x = _unit(d, "nx", 0.5)
	c.nose_flip = bool(d.get("nfl", false))
	c.blush_size = _unit(d, "bz", 0.5)
	c.blush_width = _unit(d, "bw", 0.5)
	c.blush_height = _unit(d, "bhy", 0.5)
	c.blush_spacing = _unit(d, "bx", 0.5)
	c.blush_opacity = _unit(d, "bo", 0.5)
	c.blush = bool(d.get("bl", false))
	c.blush_shape = int(d.get("blsh", 0))

	var blush_at: = blush_shapes().find(str(d.get("blk", "")))
	if blush_at >= 0:
		c.blush_shape = blush_at
	c.blush_color = Color.html(str(d.get("blc", "f58585")))
	c.head_shape = int(d.get("hs", 0))


	c.ear_shape = str(d.get("ear", ""))
	c.title = (d.get("ttl", {}) as Dictionary).duplicate()
	c.level = clampi(int(d.get("lvl", 0)), 0, 999)
	c.voice = int(d.get("vo", 2))

	if d.has("vp"):
		c.v_pitch = _unit(d, "vp", 0.5)
	else:
		var preset: = VOICE_PITCH[clampi(c.voice, 0, VOICE_PITCH.size() - 1)]
		c.v_pitch = clampf(inverse_lerp(0.78, 1.3, preset), 0.0, 1.0)
	c.v_speed = _unit(d, "vs", 0.5)


	c.voice_pack = clampi(int(d.get("vpk", 1)), 1, VOICE_PACK_COUNT)
	c.left_handed = bool(d.get("lh", false))
	c.number = int(d.get("num", 1))


	c.uniform_gear = Gear.read(d)
	c.gym_gear = Gear.read(d.get("gg", {}), c.uniform_gear)
	var kh: Array = d.get("kh", [])
	if kh.size() >= 3:

		c.captain_kit = TeamKits.normalize(kh.map( func(s): return Color.html(str(s))))
	c.facial_hair = facial_hair_index_of(d.get("fh", ""))
	if d.has("fhcols") and d["fhcols"] is Array:
		c.facial_hair_cols = (d["fhcols"] as Array).duplicate()
	for key in FACIAL_XF:
		c.set(FACIAL_XF[key], _unit(d, key, 0.5))
	c.gym_tee = Color.html(str(d.get("gt", "ecebe3")))
	c.gym_shorts = Color.html(str(d.get("gs", "618fd6")))
	c.gym_shirt = int(d.get("gsh", 0))
	c.hoodie_color = Color.html(str(d.get("hdc", "4d8cf2")))
	c.hoodie_custom = bool(d.get("hdx", false))
	var acc = d.get("acc", {})
	if acc is Dictionary:


		c.accessories = (acc as Dictionary).duplicate(true)
	return c




func acc_slot(slot: String) -> Dictionary:
	if not accessories.has(slot):
		accessories[slot] = {}
	return accessories[slot]

func acc_id(slot: String) -> String:
	return String((accessories.get(slot, {}) as Dictionary).get("id", ""))


static func acc_slot_name(category: String, n: int) -> String:
	return category if n <= 0 else "%s%d" % [category, n + 1]


static func acc_category(slot: String) -> String:
	var cat: = slot
	while cat.length() > 0 and cat.right(1).is_valid_int():
		cat = cat.left(-1)
	return cat


static func acc_slots_of(category: String) -> Array:
	var out: Array = []
	for n in ACC_PER_CATEGORY:
		out.append(acc_slot_name(category, n))
	return out







func acc_alone(slot: String, id: String) -> CharacterConfig:
	var shot: = clone()
	var cat: = acc_category(slot)
	var own: = {}
	if slot != cat and id != "" and acc_id(slot) == id:
		own = (accessories[slot] as Dictionary).duplicate(true)
	for s in acc_slots_of(cat):
		if s != cat:
			shot.accessories.erase(s)
	if own.is_empty():
		shot.set_acc_id(cat, id)
	else:
		shot.accessories[cat] = own
	return shot

func set_acc_id(slot: String, id: String) -> void :
	if id == "":
		accessories.erase(slot)
		return
	var st: = acc_slot(slot)
	if String(st.get("id", "")) != id:


		st.clear()
		st["id"] = id

func set_acc(slot: String, key: String, value) -> void :
	acc_slot(slot)[key] = value

func acc_val(slot: String, key: String, default: = 0.5) -> float:
	return float((accessories.get(slot, {}) as Dictionary).get(key, default))


func acc_flip(slot: String) -> bool:
	return (accessories.get(slot, {}) as Dictionary).get("fl", false) == true

func set_acc_color(slot: String, i: int, color: Color) -> void :
	var st: = acc_slot(slot)
	var cols: Array = st.get("cols", [])
	while cols.size() <= i:
		cols.append("")
	cols[i] = color.to_html(false)
	st["cols"] = cols

func acc_color(slot: String, i: int, fallback: Color) -> Color:
	var cols: Array = (accessories.get(slot, {}) as Dictionary).get("cols", [])
	if i >= 0 and i < cols.size() and String(cols[i]) != "":
		return Color.html(str(cols[i]))
	return fallback




func unowned_accessories(who: SavedProfile = null) -> Array:
	var out: Array = []
	for slot in ACC_SLOTS:
		var item: = AccessoryCatalog.by_id(acc_id(slot))
		if item != null and not Progression.owns(item.id, item.price, who)\
		and not out.has(item.id):
			out.append(item.id)
	return out


func drop_unowned(who: SavedProfile = null) -> bool:
	var dropped: = false
	for slot in ACC_SLOTS:
		var item: = AccessoryCatalog.by_id(acc_id(slot))
		if item != null and not Progression.owns(item.id, item.price, who):
			set_acc_id(slot, "")
			dropped = true
	return dropped




func _acc_grad(slot: String, i: int) -> Dictionary:
	var g: Array = (accessories.get(slot, {}) as Dictionary).get("grads", [])
	if i >= 0 and i < g.size() and g[i] is Dictionary:
		return g[i]
	return {}

func _acc_grad_slot(slot: String, i: int) -> Dictionary:
	var st: = acc_slot(slot)
	var g: Array = st.get("grads", [])
	while g.size() <= i:
		g.append({})
	if not (g[i] is Dictionary):
		g[i] = {}
	st["grads"] = g
	return g[i]

func acc_gradient_on(slot: String, i: int) -> bool:
	return bool(_acc_grad(slot, i).get("on", false))

func set_acc_gradient_on(slot: String, i: int, on: bool) -> void :
	_acc_grad_slot(slot, i)["on"] = on

func acc_gradient_bottom(slot: String, i: int, fallback: Color) -> Color:
	var b: = String(_acc_grad(slot, i).get("b", ""))
	return Color.html(b) if b != "" else fallback

func set_acc_gradient_bottom(slot: String, i: int, color: Color) -> void :
	_acc_grad_slot(slot, i)["b"] = color.to_html(false)

func acc_gradient_fade(slot: String, i: int) -> Vector2:
	var g: = _acc_grad(slot, i)
	return Vector2(float(g.get("fs", 0.0)), float(g.get("fe", 1.0)))

func set_acc_gradient_fade(slot: String, i: int, start: float, end: float) -> void :
	var g: = _acc_grad_slot(slot, i)
	g["fs"] = clampf(start, 0.0, 1.0)
	g["fe"] = clampf(end, 0.0, 1.0)

func reset_acc_transform(slot: String) -> void :
	var st: = acc_slot(slot)
	for k in ["px", "py", "pz", "rx", "ry", "rz", "sc", "sx", "sy", "sz"]:
		st.erase(k)

static func random(rng: RandomNumberGenerator = null, owned_only: = false, 
		who = null) -> CharacterConfig:




	var r: = rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		r.randomize()
	var c: = CharacterConfig.new()
	c.face = r.randi_range(0, FACE_TYPES - 1)
	c.skin = r.randi_range(0, SKIN_TONES.size() - 1)
	c.height = r.randf_range(0.15, 0.85)
	c.weight = r.randf_range(0.15, 0.85)
	c.hair = r.randi_range(0, hair_meshes().size() - 1)
	c.hair_flip = r.randf() < 0.5
	c.hair_color_idx = r.randi_range(0, HAIR_COLORS.size() - 1)
	c.hair_col = HAIR_COLORS[c.hair_color_idx]


	c.eye_shape = _rand_opt(r, "eyes")


	c.eye_color = Color.from_hsv(r.randf(), r.randf_range(0.35, 0.9), 
		r.randf_range(0.3, 0.85))
	c.lash_color = Color.BLACK
	c.eye_size = r.randf_range(0.35, 0.65)
	c.eye_width = r.randf_range(0.35, 0.65)
	c.eye_size_y = r.randf_range(0.35, 0.65)
	c.eye_height = r.randf_range(0.4, 0.6)
	c.eye_spacing = r.randf_range(0.4, 0.6)
	c.eye_rot = r.randf_range(0.42, 0.58)
	c.eye_x = r.randf_range(0.45, 0.55)

	c.brow_shape = -1 if r.randf() < 0.12 else _rand_opt(r, "brows")

	c.brow_color = Color.BLACK if r.randf() < 0.7 else c.hair_color()
	c.brow_height = r.randf_range(0.4, 0.6)
	c.brow_rot = r.randf_range(0.42, 0.58)
	c.brow_spacing = r.randf_range(0.4, 0.6)
	c.brow_size = r.randf_range(0.4, 0.6)
	c.brow_width = r.randf_range(0.4, 0.6)
	c.brow_size_y = r.randf_range(0.4, 0.6)
	c.brow_x = r.randf_range(0.45, 0.55)
	c.mouth_shape = _rand_opt(r, "mouth")
	c.mouth_size = r.randf_range(0.4, 0.6)
	c.mouth_width = r.randf_range(0.4, 0.6)
	c.mouth_size_y = r.randf_range(0.4, 0.6)
	c.mouth_height = r.randf_range(0.4, 0.6)
	c.mouth_rot = r.randf_range(0.44, 0.56)
	c.mouth_x = r.randf_range(0.45, 0.55)
	c.nose_shape = -1 if r.randf() < 0.1 else _rand_opt(r, "nose")
	c.nose_size = r.randf_range(0.35, 0.65)
	c.nose_width = r.randf_range(0.35, 0.65)
	c.nose_size_y = r.randf_range(0.35, 0.65)
	c.nose_height = r.randf_range(0.4, 0.6)
	c.nose_x = r.randf_range(0.44, 0.56)
	c.nose_flip = r.randf() < 0.5
	c.blush = r.randf() < 0.25
	c.blush_shape = r.randi_range(0, blush_shapes().size() - 1)
	c.blush_opacity = r.randf_range(0.35, 0.7)
	c.number = r.randi_range(1, 99)


	c.gym_tee = GYM_TEE_COLORS[r.randi_range(0, GYM_TEE_COLORS.size() - 1)]
	c.gym_shorts = GYM_SHORT_COLORS[r.randi_range(0, GYM_SHORT_COLORS.size() - 1)]



	c.gym_shirt = [0, 0, 0, 1, 2, HOODIE_SHIRT][r.randi_range(0, 5)]

	if c.gym_shirt == HOODIE_SHIRT and r.randf() < 0.5:
		c.hoodie_custom = true
		c.hoodie_color = GYM_TEE_COLORS[r.randi_range(0, GYM_TEE_COLORS.size() - 1)]



	var ug: = c.uniform_gear
	ug.wear_socks = r.randf() < 0.85
	ug.wear_kneepads = r.randf() < 0.6
	ug.kneepad_style = 1 if r.randf() < 0.25 else 0
	ug.kneepad_style_l = ug.kneepad_style


	c.head_shape = r.randi_range(0, HEAD_SHAPES.size() - 1)

	if not EAR_SHAPES.is_empty() and r.randf() < 0.3:
		c.ear_shape = EAR_SHAPES[r.randi_range(0, EAR_SHAPES.size() - 1)]
	ug.shorts_len = r.randi_range(0, SHORTS_SHAPES.size() - 1)
	ug.socks_len = r.randi_range(0, SOCKS_SHAPES.size() - 1)


	ug.socks = _gear_color(r)
	ug.kneepad = _gear_color(r)
	ug.kneepad_l = ug.kneepad
	ug.kneepad_match = true

	ug.kneepad_side = 0 if r.randf() < 0.85 else r.randi_range(1, 2)
	ug.shoe_color = _gear_color(r)
	c.voice = r.randi_range(0, VOICE_PITCH.size() - 1)
	c.v_pitch = r.randf()
	c.v_speed = r.randf_range(0.3, 0.7)
	c.voice_pack = r.randi_range(1, VOICE_PACK_COUNT)

	c.left_handed = r.randf() < 0.15


	var jersey: = _bold_color(r)
	var trim: = _bold_color(r)
	var num: = TeamKits.number_ink(jersey)
	if r.randf() < 0.35 and TeamKits.number_reads(jersey, trim):
		num = trim
	c.captain_kit = [jersey, _dark_color(r), trim, num]

	if facial_hair_meshes().size() > 1 and r.randf() < FACIAL_HAIR_ROLL_CHANCE:
		c.facial_hair = r.randi_range(1, facial_hair_meshes().size() - 1)




		c.mouth_size = 0.5
		c.mouth_width = 0.5
		c.mouth_size_y = 0.5
		c.mouth_height = 0.5
		c.mouth_rot = 0.5
		c.mouth_x = 0.5
	_random_accessories(c, r, owned_only, who)
	_random_gym_gear(c, r)
	return c




static func _random_gym_gear(c: CharacterConfig, r: RandomNumberGenerator) -> void :
	var g: = c.uniform_gear.copy()
	g.shorts_len = r.randi_range(0, SHORTS_SHAPES.size() - 1)
	g.wear_kneepads = g.wear_kneepads and r.randf() < 0.5
	g.wear_socks = g.wear_socks and r.randf() < 0.85
	if r.randf() < 0.3:
		g.socks_len = r.randi_range(0, SOCKS_SHAPES.size() - 1)
	if r.randf() < 0.3:
		g.socks = _gear_color(r)
	c.gym_gear = g


static func _rand_opt(r: RandomNumberGenerator, feature: String) -> int:
	var n: = FaceParts.count(feature)
	return r.randi_range(0, n - 1) if n > 0 else 0







const ACC_ROLL_CHANCE: = {"head": 0.15, "face": 0.35, "extra": 0.2}
static func _random_accessories(c: CharacterConfig, r: RandomNumberGenerator, 
		owned_only: = false, who = null) -> void :
	if MobileRender.enabled():
		return
	for slot in ACC_CATEGORIES:
		var items: = AccessoryCatalog.for_category(slot)


		if owned_only:
			items = items.filter( func(it: AccessoryItem):
				return Progression.owns(it.id, it.price, who))
		if items.is_empty() or r.randf() >= float(ACC_ROLL_CHANCE.get(slot, 0.25)):
			continue
		var item: AccessoryItem = items[r.randi_range(0, items.size() - 1)]
		c.set_acc_id(slot, item.id)
		for i in item.color_count():
			c.set_acc_color(slot, i, _acc_random_color(r))

static func _acc_random_color(r: RandomNumberGenerator) -> Color:

	return Color.from_hsv(r.randf(), r.randf_range(0.45, 0.9), r.randf_range(0.55, 0.95))

static func _bold_color(r: RandomNumberGenerator) -> Color:
	return Color.from_hsv(r.randf(), r.randf_range(0.55, 0.9), 
		r.randf_range(0.7, 0.95))

static func _dark_color(r: RandomNumberGenerator) -> Color:
	return Color.from_hsv(r.randf(), r.randf_range(0.0, 0.4), 
		r.randf_range(0.08, 0.22))



static func _gear_color(r: RandomNumberGenerator) -> Color:
	return Color.from_hsv(r.randf(), r.randf_range(0.25, 0.7), 
		r.randf_range(0.3, 0.72))


static var _char_path: = ""
static var _slots_path: = ""

static func char_path() -> String:
	if _char_path == "":
		_char_path = AppData.migrate("user://character.json", "character.json")
	return _char_path

static func slots_path() -> String:
	if _slots_path == "":
		_slots_path = AppData.migrate("user://character_slots.json", "character_slots.json")
	return _slots_path

func save_local() -> void :
	AppData.write_safely(char_path(), JSON.stringify(to_dict()))

static func load_local() -> CharacterConfig:
	var parsed: Variant = AppData.read_json(char_path())
	if not (parsed is Dictionary):
		return CharacterConfig.new()
	return CharacterConfig.from_dict(parsed)



func clone() -> CharacterConfig:
	return CharacterConfig.from_dict(to_dict())







const SLOT_COUNT: = 30




static func load_slots() -> Array:
	var slots: Array = []
	for _i in SLOT_COUNT:
		slots.append(null)
	var parsed: Variant = AppData.read_json(slots_path())
	if parsed is Array:
		for i in mini(SLOT_COUNT, (parsed as Array).size()):
			var e: Variant = parsed[i]
			slots[i] = from_dict(e) if e is Dictionary else null
		return slots
	if FileAccess.file_exists(slots_path()):
		return slots

	if FileAccess.file_exists(char_path()):
		slots[0] = load_local()
	return slots

static func save_slots(slots: Array) -> void :
	var out: Array = []
	for i in SLOT_COUNT:
		var e: Variant = slots[i] if i < slots.size() else null
		out.append((e as CharacterConfig).to_dict() if e is CharacterConfig else null)
	AppData.write_safely(slots_path(), JSON.stringify(out))
