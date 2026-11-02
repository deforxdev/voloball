extends RefCounted
























const ENABLED: = true

const ITEM_DIR: = "res://game/titles/items/"
const EFFECT_DIR: = "res://game/titles/effects/"
const TITLE_ITEM: = preload("res://game/titles/title_item.gd")
const TITLE_EFFECT: = preload("res://game/titles/title_effect.gd")

const OWN_PREFIX: = "title:"
const FX_PREFIX: = "titlefx:"







const THICK_MAX: = 16
const TEXT_MAX: = 20
const KNOB_MAX: = 4
const LOOK_KEYS: Array[String] = ["fg", "bg", "ol"]
const CASE_LOWER: = 0
const CASE_UPPER: = 1
const CASE_CAMEL: = 2
const CASE_NAMES: Array[String] = ["lowercase", "UPPERCASE", "Camel Case"]

static var _items: Array = []
static var _effects: Array = []
static var _item_of: = {}
static var _effect_of: = {}
static var _scanned: = false
static var _art: = {}
static var _fonts: = {}

static var tier_override: = -1









const DEMO_TITLE_PRICE: = 150





const DEMO_EFFECTS: = ["stage_grass", "stage_beach", "stage_clouds", 
	"camo", "bouncy", "wiggle", "pixel", "cutesy"]

static func in_demo(item: TITLE_ITEM) -> bool:
	return item != null and not item.exclusive and item.from_achievement == "" and item.price == DEMO_TITLE_PRICE


const DEMO_EFFECT_PREFIX: = "flag_"

static func fx_in_demo(fx: TITLE_EFFECT, id: = "") -> bool:
	var fid: = fx.id if fx != null and fx.id != "" else id
	return fx != null and (fid in DEMO_EFFECTS or fid.begins_with(DEMO_EFFECT_PREFIX))

static func _scan() -> void :
	if _scanned:
		return
	_scanned = true
	var demo: = LaunchGate.is_demo()
	for path in _files(ITEM_DIR):
		var item: = load(path) as TITLE_ITEM
		if item == null:
			continue
		if demo and not in_demo(item):
			continue
		if item.id == "":
			item.id = path.get_file().trim_suffix(".tres")
		if item.text.strip_edges() == "" or item.text.length() > TEXT_MAX or _item_of.has(item.id):
			push_warning("title skipped (no text, over %d letters, or a repeated id): %s" % [TEXT_MAX, path])
			continue
		_items.append(item)
		_item_of[item.id] = item

	_items.sort_custom( func(a, b):
		return a.text.naturalnocasecmp_to(b.text) < 0 if a.price == b.price else a.price < b.price)
	for path in _files(EFFECT_DIR):
		var fx: = load(path) as TITLE_EFFECT
		if fx == null:
			continue
		var in_demo_list: = demo and fx_in_demo(fx, path.get_file().trim_suffix(".tres"))
		if fx.stage != "" and not Stage.in_build(fx.stage) and not in_demo_list:
			continue
		if demo and not in_demo_list:
			continue
		if fx.id == "":
			fx.id = path.get_file().trim_suffix(".tres")
		_effects.append(fx)
		if not _effect_of.has(fx.id):
			_effect_of[fx.id] = fx
	_effects.sort_custom( func(a, b): return a.id < b.id if a.order == b.order else a.order < b.order)



static func _files(base: String) -> Array[String]:
	var out: Array[String] = []
	var seen: = {}
	for f in DirAccess.get_files_at(base):
		var path: = tres_path(base, String(f))
		if path != "" and not seen.has(path) and ResourceLoader.exists(path):
			seen[path] = true
			out.append(path)
	out.sort()
	return out


static func tres_path(base: String, listed: String) -> String:
	var file: = listed.trim_suffix(".remap")
	return base + file if file.get_extension() == "tres" else ""

static func all() -> Array:
	_scan()
	return _items






static func warm() -> void :
	if enabled():
		_scan()

static func by_id(id: String) -> TITLE_ITEM:
	if id == "":
		return null
	_scan()
	return _item_of.get(id) as TITLE_ITEM

static func effects() -> Array:
	_scan()
	return _effects

static func effect(id: String) -> TITLE_EFFECT:
	if id == "":
		return null
	_scan()
	return _effect_of.get(id) as TITLE_EFFECT





static func earned(item: TITLE_ITEM) -> bool:
	return item != null and item.from_achievement != ""


static func for_sale() -> Array:
	return all().filter( func(item): return not item.exclusive and item.price > 0\
	and not earned(item))



static func shelf() -> Array:
	return all().filter( func(item): return not item.exclusive\
	and (earned(item) or item.price > 0))

static func effects_for_sale() -> Array:
	return effects().filter( func(fx): return fx.price > 0)




static func art(path: String) -> Texture2D:
	if path == "":
		return null
	if not _art.has(path):
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		else:
			var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
			if img != null:
				tex = ImageTexture.create_from_image(img)
		_art[path] = tex
	return _art[path]

static func font(path: String) -> Font:
	if path == "":
		return null
	if not _fonts.has(path):
		var found: Font = null
		if ResourceLoader.exists(path):
			found = load(path) as Font
		else:
			var raw: = FontFile.new()
			if raw.load_dynamic_font(ProjectSettings.globalize_path(path)) == OK:
				found = raw
		_fonts[path] = found
	return _fonts[path]




static func default_look() -> Dictionary:
	return {"cs": CASE_LOWER, "fg": UiStyle.INK.to_html(false), "bg": UiStyle.PRIMARY.to_html(true), 
		"ol": "ffffff", "th": 0, "fx": ""}

static func _is_colour(v: Variant) -> bool:
	return v is String and (v as String).length() <= 9 and Color.html_is_valid(v)

static func _is_number(v: Variant) -> bool:
	return (v is int or v is float) and is_finite(float(v))






static func clean_look(raw: Variant) -> Dictionary:
	var out: = default_look()
	if not (raw is Dictionary):
		return out
	var d: = raw as Dictionary
	for k in LOOK_KEYS:
		if _is_colour(d.get(k)):
			out[k] = d[k]
	if _is_number(d.get("th")):
		out["th"] = clampi(int(d["th"]), 0, THICK_MAX)
	if _is_number(d.get("cs")):
		out["cs"] = clampi(int(d["cs"]), CASE_LOWER, CASE_CAMEL)
	var fx_id: Variant = d.get("fx")
	var fx: TITLE_EFFECT = effect(fx_id) if fx_id is String else null
	if fx != null:
		out["fx"] = fx.id
		var sliders: = mini(fx.knobs.size(), KNOB_MAX)
		if sliders > 0:
			var given: Variant = d.get("fp")
			var vals: Array = []
			for i in sliders:
				var v: Variant = (given as Array)[i] if given is Array and i < (given as Array).size() else null
				vals.append(clampi(roundi(float(v)), 0, 100) if _is_number(v) else roundi(fx.knob_default(i) * 100.0))
			out["fp"] = vals
		if fx.accent != "":
			out["ac"] = d["ac"] if _is_colour(d.get("ac")) else fx.accent_default.to_html(false)
	return out



static func sanitize(raw: Variant) -> Dictionary:
	if not ENABLED or not (raw is Dictionary):
		return {}
	var id: Variant = (raw as Dictionary).get("id", "")
	if not (id is String) or by_id(id) == null:
		return {}
	var out: = clean_look(raw)
	out["id"] = id
	return out




static func cased(text: String, how: int) -> String:
	match how:
		CASE_UPPER:
			return text.to_upper()
		CASE_CAMEL:
			if text != text.to_lower():
				return text
			var words: = text.split(" ")
			for i in words.size():
				if words[i].length() > 0:
					words[i] = words[i][0].to_upper() + words[i].substr(1)
			return " ".join(words)
	return text.to_lower()


static func text_of(style: Dictionary) -> String:
	var item: = by_id(str(style.get("id", "")))
	return cased(item.text, int(style.get("cs", CASE_LOWER))) if item != null else ""



static func knob(style: Dictionary, i: int) -> float:
	var given: Variant = style.get("fp")
	if given is Array and i < (given as Array).size() and _is_number((given as Array)[i]):
		return clampf(float((given as Array)[i]) / 100.0, 0.0, 1.0)
	var fx: = effect(str(style.get("fx", "")))
	return fx.knob_default(i) if fx != null else 0.5



static func suited(look: Dictionary, fx: TITLE_EFFECT) -> Dictionary:
	var out: = look.duplicate(true)
	out["fx"] = fx.id
	out.erase("fp")
	out.erase("ac")
	if fx.suit_fg != "":
		out["fg"] = fx.suit_fg
	if fx.suit_bg != "":
		out["bg"] = fx.suit_bg
	if fx.suit_ol != "":
		out["ol"] = fx.suit_ol
		out["th"] = fx.suit_th
	var id: Variant = out.get("id")
	out = clean_look(out)
	if id is String and id != "":
		out["id"] = id
	return out













static func enabled() -> bool:
	return ENABLED and ( not LaunchGate.public_beta() or LaunchGate.is_demo())


static func shop_open() -> bool:
	return enabled() and not LaunchGate.economy_off()




static func may_wear_exclusive(who: SavedProfile = null) -> bool:
	if not ENABLED:
		return false
	if who != null and who != ProfileStore.active():
		return false
	var tier: = tier_override if tier_override >= 0 else DevBadge.my_tier()
	return tier == DevBadge.Tier.GOLD

static func own_key(id: String) -> String:
	return OWN_PREFIX + id

static func fx_key(id: String) -> String:
	return FX_PREFIX + id



static func owns(item: TITLE_ITEM, who: SavedProfile = null) -> bool:
	if item == null:
		return false
	if item.exclusive:
		return may_wear_exclusive(who)
	if earned(item):
		if not enabled():
			return false



		if LaunchGate.public_beta():
			return true
		var p: = who if who != null else ProfileStore.active()
		return p != null and (p.owned.has(own_key(item.id))\
		or Achievements.ever_done(item.from_achievement, p))
	return enabled() and Progression.owns(own_key(item.id), item.price, who)

static func buy(item: TITLE_ITEM, who: SavedProfile = null) -> bool:
	if item == null or item.exclusive or earned(item) or not enabled():
		return false
	return Progression.purchase(own_key(item.id), item.price, who)





static func owns_effect(fx: TITLE_EFFECT, who: SavedProfile = null) -> bool:
	if fx == null:
		return false
	if not enabled():
		return may_wear_exclusive(who)
	return Progression.owns(fx_key(fx.id), fx.price, who)

static func buy_effect(fx: TITLE_EFFECT, who: SavedProfile = null) -> bool:
	if fx == null or not enabled():
		return false
	return Progression.purchase(fx_key(fx.id), fx.price, who)


static func owned(who: SavedProfile = null) -> Array:
	return all().filter( func(item): return owns(item, who))

static func owned_effects(who: SavedProfile = null) -> Array:
	return effects().filter( func(fx): return owns_effect(fx, who))



static func usable() -> bool:
	return enabled() or may_wear_exclusive()




static func _owned_look(look: Dictionary, who: SavedProfile = null) -> Dictionary:
	if str(look.get("fx", "")) != "" and not owns_effect(effect(str(look["fx"])), who):
		look["fx"] = ""
		look.erase("fp")
		look.erase("ac")
	return look


static func saved_look(who: SavedProfile = null) -> Dictionary:
	var p: = who if who != null else ProfileStore.active()
	return _owned_look(clean_look(p.title if p != null else {}), who)


static func equipped(who: SavedProfile = null) -> Dictionary:
	var p: = who if who != null else ProfileStore.active()
	if p == null:
		return {}
	var style: = sanitize(p.title)
	if style.is_empty() or not owns(by_id(style["id"]), who):
		return {}
	return _owned_look(style, who)




static func equip(id: String, look: Dictionary, who: SavedProfile = null) -> void :
	var p: = who if who != null else ProfileStore.active()
	if p == null:
		return
	var style: = _owned_look(clean_look(look), who)
	style["id"] = id if owns(by_id(id), who) else ""
	p.title = style
	ProfileStore.save()
	if who == null or who == ProfileStore.active():
		stamp(GameConfig.character)
	else:
		stamp_dict(p.character, p)





static func of_row(row: Dictionary) -> Dictionary:
	var cfg: Variant = row.get("cfg")
	if not (cfg is Dictionary) or String(row.get("name", "")).ends_with(" (CPU)"):
		return {}
	var style: = sanitize((cfg as Dictionary).get("ttl"))
	if style.is_empty():
		return {}
	if by_id(style["id"]).exclusive:
		var sid: = int(str(row.get("sid", "0")))
		var peer: = int(row.get("peer", 0))
		var tier: = DevBadge.tier_of(sid) if sid != 0 else DevBadge.peer_tier(peer)
		if sid == 0 and tier_override >= 0 and peer == Net.get_multiplayer().get_unique_id():
			tier = tier_override
		if tier != DevBadge.Tier.GOLD:
			return {}
	return style



static func stamp(cfg: Object, who: SavedProfile = null) -> void :
	if cfg != null:
		cfg.set("title", equipped(who))

		cfg.set("level", Progression.shown_level(who))


static func stamp_dict(look: Dictionary, who: SavedProfile) -> void :
	var cfg: = CharacterConfig.from_dict(look)
	stamp(cfg, who)
	var d: = cfg.to_dict()
	look.clear()
	look.merge(d)





static func gate(cfg: Dictionary, sid: int) -> Dictionary:
	var raw: Variant = cfg.get("ttl")
	if raw == null:
		return cfg
	var item: TITLE_ITEM = by_id(str((raw as Dictionary).get("id", ""))) if raw is Dictionary else null
	if not ENABLED or item == null\
	or (item.exclusive and DevBadge.tier_of(sid) != DevBadge.Tier.GOLD):
		cfg.erase("ttl")
	return cfg
