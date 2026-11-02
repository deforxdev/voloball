class_name StudioLayer
extends RefCounted
















const KIND_CHAR: = "char"
const KIND_TEXT: = "text"
const KIND_STICKER: = "sticker"
const KIND_BALL: = "ball"
const KIND_PATTERN: = "pattern"


const KIND_BOX: = "box"
const KIND_CALLOUT: = "callout"
const KIND_ARROW: = "arrow"
const KIND_TABLE: = "table"
const KIND_PANEL: = "panel"


const RENDERED: = [KIND_CHAR, KIND_BALL]

const BOXED: = [KIND_BOX, KIND_TABLE, KIND_PANEL, KIND_PATTERN]




const FRAME_M: = 3.2
const FOCUS_Y: = 1.2

const FONTS: = [
	["round", "res://game/fonts/Nunito/Nunito-Black.ttf"], 
	["varsity", "res://game/fonts/VarsityTeam-Bold.otf"], 
	["pixel", "res://game/fonts/PublicPixel/PublicPixel.ttf"], 
	["book", "res://game/fonts/Nunito/Nunito-SemiBold.ttf"], 
]
const FONT_BOOK: = 3

const BOLD_FONT: = "res://game/fonts/Nunito/Nunito-Black.ttf"
const ITALIC_FONT: = "res://game/fonts/Nunito/Nunito-SemiBoldItalic.ttf"


const BALLS: = [["nationals", "pro"], ["school", "school"], ["beach", "outdoor"]]

var kind: = KIND_CHAR
var name: = ""
var pos: = Vector2(0.5, 0.5)
var size: = 1.0
var base_size: = 1.0
var rot: = 0.0
var flip: = false



const SHADOW_DEFAULTS: = {"shadow": false, "shadow_color": Color("141416"), 
	"shadow_alpha": 0.45, "shadow_dist": 0.3, "shadow_angle": 45.0, "shadow_soft": 0.4}
var shadow: = false
var shadow_color: = Color("141416")
var shadow_alpha: = 0.45
var shadow_dist: = 0.3
var shadow_angle: = 45.0
var shadow_soft: = 0.4




const STICK_DEFAULTS: = {"stick": false, "stick_color": Color.WHITE, "stick_width": 0.3}
const STICK_MAX: = 0.03
var stick: = false
var stick_color: = Color.WHITE
var stick_width: = 0.3


var who: = "you"
var from_you: = false


var src: = ""
var cfg: CharacterConfig = null
var outfit: = 0
var pose: = "idle"
var frame: = 0.0
var turn: = 0.0
var barefoot: = false


var other_hand: = false
var tex: Texture2D = null
var tex_key: = 0
var used: = Rect2(0.3, 0.2, 0.4, 0.68)


const BALL_RIM_DEFAULT: = Color(0.35, 1.0, 0.55)
var ball: = "nationals"
var ball_rim: = true
var ball_rim_color: = BALL_RIM_DEFAULT


var text: = ""
var font: = 0
var color: = Color.WHITE
var outline_color: = Color("232b3b")
var outline: = 0.14


var sticker: = ""
var _sticker_tex: Texture2D = null


var pattern: = "k01"
var tile: = 0.3


var w: = 0.6
var h: = 0.3
var align: = 0
var fill: = Color(0, 0, 0, 0)
var radius: = 0.25
var cells: Array = []
var live: = ""
var thick: = 0.35
var bend: = 0.0
var head2: = false

var role: = ""
var sid: = ""
var tags: = ""
var link: = ""


var measured: = Vector2.ZERO

func label() -> String:
	if name.strip_edges() != "":
		return name.strip_edges()
	match kind:
		KIND_TEXT, KIND_BOX:
			var t: = GuideTokens.plain(text).strip_edges() if kind == KIND_BOX else text.strip_edges()
			var head: = "header" if role == "header" else "text"
			return "%s: %s" % [head, t.left(14) if t != "" else "empty"]
		KIND_STICKER:
			return "sticker"
		KIND_BALL:
			return "ball"
		KIND_PATTERN:
			return "pattern"
		KIND_CALLOUT:
			return "callout %s" % text
		KIND_ARROW:
			return "arrow"
		KIND_TABLE:
			return "controls table" if live.begins_with("controls") else "table"
		KIND_PANEL:
			return "panel"
	return who

func is_rendered() -> bool:
	return kind in RENDERED

func is_boxed() -> bool:
	return kind in BOXED



func xform(cs: Vector2) -> Transform2D:
	var sx: = -1.0 if flip and _mirrors() else 1.0
	return Transform2D(rot, Vector2(sx, 1.0), 0.0, pos * cs)

func _mirrors() -> bool:
	return kind in [KIND_CHAR, KIND_STICKER, KIND_BALL, KIND_PATTERN, KIND_ARROW]


func arrow_px(cs: Vector2) -> float:
	return maxf(1.5, lerpf(0.002, 0.014, thick) * cs.y)


func local_rect(cs: Vector2) -> Rect2:
	match kind:
		KIND_TEXT:
			var sz: = text_size(cs)
			return Rect2( - sz * 0.5, sz)
		KIND_STICKER:
			var hh: = size * cs.y
			var t: = sticker_tex()
			var aspect: = 1.0 if t == null else float(t.get_width()) / maxf(1.0, t.get_height())
			return Rect2( - hh * aspect * 0.5, - hh * 0.5, hh * aspect, hh)
		KIND_BOX, KIND_TABLE:
			var bw: = w * cs.y
			var bh: = measured.y * cs.y if measured.y > 0.0 else size * cs.y * 1.4
			return Rect2( - bw * 0.5, - bh * 0.5, bw, bh)
		KIND_PANEL, KIND_PATTERN:
			return Rect2( - w * cs.y * 0.5, - h * cs.y * 0.5, w * cs.y, h * cs.y)
		KIND_CALLOUT:
			var d: = size * cs.y
			return Rect2( - d * 0.5, - d * 0.5, d, d)
		KIND_ARROW:
			var l: = size * cs.y
			var t: = arrow_px(cs)
			var bow: = absf(bend) * l * 0.5
			var hh: = maxf(t * 4.0, bow * 2.0 + t * 4.0)
			return Rect2( - l * 0.5, - hh * 0.5, l, hh)
	var side: = size * cs.y
	return Rect2( - side * 0.5, - side * 0.5, side, side)



func hit_rect(cs: Vector2) -> Rect2:
	if not is_rendered():
		return local_rect(cs)
	var frame_r: = local_rect(cs)
	var u: = used
	return Rect2(frame_r.position + u.position * frame_r.size, u.size * frame_r.size)

func contains(p: Vector2, cs: Vector2) -> bool:
	var local: = xform(cs).affine_inverse() * p
	return hit_rect(cs).grow(maxf(4.0, cs.y * 0.006)).has_point(local)


func corners(cs: Vector2) -> PackedVector2Array:
	var r: = hit_rect(cs)
	var x: = xform(cs)
	return PackedVector2Array([x * r.position, x * Vector2(r.end.x, r.position.y), 
		x * r.end, x * Vector2(r.position.x, r.end.y)])


func bounds(cs: Vector2) -> Rect2:
	var c: = corners(cs)
	var r: = Rect2(c[0], Vector2.ZERO)
	for p in c:
		r = r.expand(p)
	return r



func font_res() -> Font:
	var path: String = FONTS[clampi(font, 0, FONTS.size() - 1)][1]
	if not ResourceLoader.exists(path):
		path = FONTS[0][1]
	return UiStyle.font(path)

func font_px(cs: Vector2) -> int:
	return maxi(1, int(round(size * cs.y)))

func outline_px(cs: Vector2) -> int:
	return int(round(outline * font_px(cs)))

func text_size(cs: Vector2) -> Vector2:
	var f: = font_res()
	var shown: = text if text != "" else " "
	var sz: = f.get_multiline_string_size(shown, HORIZONTAL_ALIGNMENT_CENTER, -1, 
		font_px(cs))
	return sz + Vector2.ONE * outline_px(cs)



func sticker_tex() -> Texture2D:
	if _sticker_tex == null and sticker != "":
		if ResourceLoader.exists(sticker):
			_sticker_tex = load(sticker) as Texture2D
		elif FileAccess.file_exists(sticker):

			var img: = Image.load_from_file(ProjectSettings.globalize_path(sticker))
			if img != null:
				_sticker_tex = ImageTexture.create_from_image(img)
	return _sticker_tex





func look_key() -> int:
	if kind == KIND_BALL:
		return hash(["ball", ball, ball_rim, ball_rim_color.to_html()])
	return hash([cfg.to_dict() if cfg != null else {}, outfit, barefoot])

func render_key(px: int) -> int:
	return hash([look_key(), pose, snappedf(frame, 0.001), snappedf(turn, 0.1), px, 
		other_hand])



func render_px(canvas_h: float) -> int:
	return clampi(int(round(size * canvas_h)), 96 if kind == KIND_CHAR else 48, 2048)


func shadow_offset(cs: Vector2) -> Vector2:
	return Vector2.from_angle(deg_to_rad(shadow_angle)) * shadow_dist * 0.08 * cs.y


func stick_px(cs: Vector2) -> float:
	return stick_width * STICK_MAX * cs.y if stick else 0.0



func reset_place() -> void :
	if is_boxed() and base_size > 0.0 and size > 0.0:
		var k: = base_size / size
		w *= k
		h *= k
	size = base_size
	rot = 0.0
	flip = false

func reset_pose() -> void :
	outfit = 0
	pose = "idle"
	frame = 0.0
	turn = 0.0
	barefoot = false
	other_hand = false

func reset_ball() -> void :
	ball = "nationals"
	ball_rim = true
	ball_rim_color = BALL_RIM_DEFAULT
	frame = 0.0
	turn = 0.0

func reset_text_style() -> void :
	font = 0
	color = Color.WHITE
	outline_color = Color("232b3b")
	outline = 0.14

func reset_shadow() -> void :
	for k in SHADOW_DEFAULTS:
		set(k, SHADOW_DEFAULTS[k])
	shadow = true

func reset_stick() -> void :
	for k in STICK_DEFAULTS:
		set(k, STICK_DEFAULTS[k])
	stick = true



func to_dict() -> Dictionary:
	var d: = {"kind": kind, "name": name, "pos": pos, "size": size, "base": base_size, 
		"rot": rot, "flip": flip}
	for k in SHADOW_DEFAULTS:
		d[k] = get(k)
	for k in STICK_DEFAULTS:
		d[k] = get(k)
	if link != "":
		d["link"] = link
	match kind:
		KIND_CHAR:
			d.merge({"who": who, "you": from_you, "cfg": cfg.to_dict() if cfg != null else {}, 
				"outfit": outfit, "pose": pose, "frame": frame, "turn": turn, 
				"barefoot": barefoot, "oh": other_hand, "src": src})
		KIND_BALL:
			d.merge({"ball": ball, "rim": ball_rim, "rim_color": ball_rim_color, 
				"frame": frame, "turn": turn})
		KIND_TEXT:
			d.merge({"text": text, "font": font, "color": color, 
				"outline_color": outline_color, "outline": outline})
		KIND_STICKER:
			d.merge({"sticker": sticker})
		KIND_PATTERN:
			d.merge({"pattern": pattern, "color": color, "tile": tile, "w": w, "h": h})
		KIND_BOX:
			d.merge({"text": text, "font": font, "color": color, "outline_color": outline_color, 
				"outline": outline, "w": w, "align": align, "fill": fill, "radius": radius, 
				"role": role, "sid": sid, "tags": tags})
		KIND_CALLOUT:
			d.merge({"text": text, "color": color, "outline_color": outline_color})
		KIND_ARROW:
			d.merge({"color": color, "outline_color": outline_color, "thick": thick, 
				"bend": bend, "head2": head2})
		KIND_TABLE:
			d.merge({"cells": cells.duplicate(true), "font": font, "color": color, 
				"outline_color": outline_color, "fill": fill, "w": w, "live": live})
		KIND_PANEL:
			d.merge({"color": color, "outline_color": outline_color, "outline": outline, 
				"w": w, "h": h, "radius": radius})
	return d



static func _v2(v: Variant, fallback: Vector2) -> Vector2:
	if v is Vector2:
		return v
	if v is Array and (v as Array).size() >= 2:
		return Vector2(float(v[0]), float(v[1]))
	return fallback

static func _col(v: Variant, fallback: Color) -> Color:
	if v is Color:
		return v
	if v is String and Color.html_is_valid(v):
		return Color.html(v)
	return fallback

static func from_dict(d: Dictionary) -> StudioLayer:
	var l: = StudioLayer.new()
	l.kind = String(d.get("kind", KIND_CHAR))
	l.name = String(d.get("name", ""))
	l.pos = _v2(d.get("pos"), l.pos)
	l.size = float(d.get("size", l.size))
	l.base_size = float(d.get("base", l.size))
	for k in SHADOW_DEFAULTS:
		if d.has(k):
			l.set(k, _col(d[k], l.shadow_color) if k == "shadow_color" else d[k])
	for k in STICK_DEFAULTS:
		if d.has(k):
			l.set(k, _col(d[k], l.stick_color) if k == "stick_color" else d[k])
	l.rot = float(d.get("rot", 0.0))
	l.flip = bool(d.get("flip", false))
	l.link = String(d.get("link", ""))
	l.who = String(d.get("who", "you"))
	l.from_you = bool(d.get("you", false))
	if l.kind == KIND_CHAR:
		var c: Variant = d.get("cfg", {})
		l.cfg = CharacterConfig.from_dict(c) if c is Dictionary and not (c as Dictionary).is_empty()\
		else CharacterConfig.new()
	l.outfit = int(d.get("outfit", 0))
	l.pose = String(d.get("pose", "idle"))
	l.frame = float(d.get("frame", 0.0))
	l.turn = float(d.get("turn", 0.0))
	l.barefoot = bool(d.get("barefoot", false))
	l.other_hand = bool(d.get("oh", false))
	l.src = String(d.get("src", "p1" if l.from_you else ""))
	l.ball = String(d.get("ball", "nationals"))
	l.ball_rim = bool(d.get("rim", true))
	l.ball_rim_color = _col(d.get("rim_color"), BALL_RIM_DEFAULT)
	l.text = String(d.get("text", ""))
	l.font = int(d.get("font", 0))
	l.color = _col(d.get("color"), l.color)
	l.outline_color = _col(d.get("outline_color"), l.outline_color)
	l.outline = float(d.get("outline", l.outline))
	l.sticker = String(d.get("sticker", ""))
	l.pattern = String(d.get("pattern", "k01"))
	l.tile = float(d.get("tile", l.tile))
	l.w = float(d.get("w", l.w))
	l.h = float(d.get("h", l.h))
	l.align = int(d.get("align", 0))
	l.fill = _col(d.get("fill"), l.fill)
	l.radius = float(d.get("radius", l.radius))
	var cl: Variant = d.get("cells", [])
	l.cells = (cl as Array).duplicate(true) if cl is Array else []
	l.live = String(d.get("live", ""))
	l.thick = float(d.get("thick", l.thick))
	l.bend = float(d.get("bend", 0.0))
	l.head2 = bool(d.get("head2", false))
	l.role = String(d.get("role", ""))
	l.sid = String(d.get("sid", ""))
	l.tags = String(d.get("tags", ""))
	return l

func duplicate_layer() -> StudioLayer:
	var l: = from_dict(to_dict())
	l.tex = tex
	l.tex_key = tex_key
	l.used = used
	l.measured = measured
	l.pos += Vector2(0.04, 0.03)

	l.sid = ""
	return l
