class_name GuideStore
extends RefCounted




















const BOOK_PATH: = "res://game/guide/book.json"
const PAGE_DIR: = "res://game/guide/pages"
const SPREAD: = Vector2i(1600, 1000)
const PAPER: = Color("fbf6ea")

const PAPER_LOOK: = {"pattern": "dots", "pattern_alpha": 0.55, "pattern_scale": 0.18}
const LIVE: = ["contents", "index"]
const INDEX_PER_COL: = 21
const PALETTE: = [Color("e5484d"), Color("ff8a3d"), Color("ffd23f"), Color("4ccb7a"), 
	Color("2fb5a6"), Color("2e78ff"), Color("7a5cff"), Color("ff7ea8"), Color("8a6a4f")]

static var _book: Dictionary = {}
static var _pages: = {}

static var overrides: = {}
static var _sections: Array = []
static var _sections_ok: = false



static func reset_cache() -> void :
	_book = {}
	_pages = {}
	_sections_ok = false
	_index_ok = false







static func available() -> bool:
	return not LaunchGate.is_demo() and FileAccess.file_exists(BOOK_PATH)





const PLAYERS_CAN_OPEN: = true

static func open_to_players() -> bool:
	return PLAYERS_CAN_OPEN and available()


static func closed_text() -> String:
	return "not in the demo" if LaunchGate.is_demo() else "coming soon"

static func book() -> Dictionary:
	if _book.is_empty():
		var d: Variant = _read_json(BOOK_PATH) if available() else null
		_book = d if d is Dictionary else {}
		if not _book.has("chapters"):
			_book["chapters"] = []
	return _book

static func chapters() -> Array:
	return book()["chapters"]

static func chapter_color(ci: int) -> Color:
	var chs: = chapters()
	if ci < 0 or ci >= chs.size():
		return Color("8a8f9c")
	return StudioLayer._col((chs[ci] as Dictionary).get("color"), PALETTE[ci % PALETTE.size()])


static func order() -> Array:
	var out: = _core_order()
	for i in index_spreads():
		out.append(["index" if i == 0 else "index_%d" % (i + 1), -1])
	return out


static func _core_order() -> Array:
	var out: Array = []
	for id in book().get("front", ["contents"]):
		out.append([String(id), -1])
	var chs: = chapters()
	for ci in chs.size():
		for id in (chs[ci] as Dictionary).get("spreads", []):
			out.append([String(id), ci])
	return out

static func ids() -> Array:
	var out: Array = []
	for e in order():
		out.append(e[0])
	return out

static func chapter_of(id: String) -> int:
	for e in order():
		if e[0] == id:
			return int(e[1])
	return -1

static func first_of_chapter(ci: int) -> String:
	var spreads: Array = (chapters()[ci] as Dictionary).get("spreads", []) if ci >= 0 and ci < chapters().size() else []
	return String(spreads[0]) if not spreads.is_empty() else ""


static func page_of(spread_index: int, right: bool) -> int:
	return spread_index * 2 + (2 if right else 1)

static func is_live(id: String) -> bool:
	return id == "contents" or id.begins_with("index")



static func spread_path(id: String) -> String:
	return "%s/%s.json" % [PAGE_DIR, id]

static func spread(id: String) -> Dictionary:
	if overrides.has(id):
		return overrides[id]
	if id == "contents":
		return _contents()
	if id.begins_with("index"):
		return _index_spread(0 if id == "index" else int(id.get_slice("_", 1)) - 1)
	if not _pages.has(id):
		var d: Variant = _read_json(spread_path(id)) if available() else null
		_pages[id] = d if d is Dictionary else {"id": id, "layers": []}
	return _pages[id]

static func paper(d: Dictionary) -> Color:
	return StudioLayer._col(d.get("bg"), PAPER)


static func apply_pattern(d: Dictionary, onto: Object) -> void :
	onto.set("pattern", String(d.get("pattern", "none")))
	var c: Variant = d.get("pattern_color")
	onto.set("pattern_auto", c == null)
	if c != null:
		onto.set("pattern_color", StudioLayer._col(c, Color.WHITE))
	onto.set("pattern_alpha", float(d.get("pattern_alpha", 1.0)))
	onto.set("pattern_scale", float(d.get("pattern_scale", 0.38)))


static func layers_of(id: String) -> Array:
	var out: Array = []
	for ld in spread(id).get("layers", []):
		if not (ld is Dictionary):
			continue
		var l: = StudioLayer.from_dict(ld)
		if l.kind == StudioLayer.KIND_CHAR and l.src != "":
			var who: = look_for(l.src)
			if who != null:
				l.cfg = who
		out.append(l)
	return out




static func look_for(src: String) -> CharacterConfig:
	var n: = int(src.substr(1)) if src.begins_with("p") else 0
	if n <= 0:
		return null
	var lp: = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("LocalPlayers")
	if lp != null:
		var slots: Array = lp.get("slots")
		if n - 1 < slots.size():
			var slot = slots[n - 1]
			var prof = slot.get("profile") if slot != null else null
			if prof != null and prof.character is Dictionary and not (prof.character as Dictionary).is_empty():
				return CharacterConfig.from_dict(prof.character)
	return player_look() if n == 1 else null

static func player_look() -> CharacterConfig:
	var p = ProfileStore.active()
	if p != null and p.character is Dictionary and not (p.character as Dictionary).is_empty():
		return CharacterConfig.from_dict(p.character)
	return null



static func can_save() -> bool:
	return OS.has_feature("editor")


static func save_spread(id: String, layers: Array, bg: Color, look: = {}) -> bool:
	if not can_save() or is_live(id) or id.strip_edges() == "":
		return false
	var dicts: Array = []
	for l in layers:
		dicts.append((l as StudioLayer).to_dict())
	var d: = {"id": id, "bg": bg, "layers": dicts}
	d.merge(look)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PAGE_DIR))
	if not _write_json(spread_path(id), d):
		return false
	_pages[id] = _to_json(d)
	overrides.erase(id)
	_sections_ok = false
	return true

static func save_book() -> bool:
	if not can_save():
		return false
	_sections_ok = false
	return _write_json(BOOK_PATH, book())





const IMAGE_DIR: = "res://game/guide/images"

static func import_picture(from: String) -> String:
	if not can_save() or not FileAccess.file_exists(from):
		return ""
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(IMAGE_DIR))
	var base: = from.get_file().get_basename().to_lower().replace(" ", "_")
	var ext: = from.get_extension().to_lower()
	var name: = "%s.%s" % [base, ext]
	var n: = 2
	while FileAccess.file_exists("%s/%s" % [IMAGE_DIR, name]):
		name = "%s_%d.%s" % [base, n, ext]
		n += 1
	var to: = "%s/%s" % [IMAGE_DIR, name]
	if DirAccess.copy_absolute(from, ProjectSettings.globalize_path(to)) != OK:
		return ""
	return to



static func clean_pictures(keep: Array = []) -> int:
	var dir: = DirAccess.open(IMAGE_DIR)
	if dir == null or not can_save():
		return 0
	var used: = {}
	for l in keep:
		used[(l as StudioLayer).sticker] = true
	for f in DirAccess.get_files_at(PAGE_DIR):
		if f.ends_with(".json"):
			var text: = FileAccess.get_file_as_string("%s/%s" % [PAGE_DIR, f])
			for m in RegEx.create_from_string(IMAGE_DIR + "/[^\"]+").search_all(text):
				used[m.get_string()] = true
	var gone: = 0
	for f in dir.get_files():
		if f.ends_with(".import"):
			continue
		var path: = "%s/%s" % [IMAGE_DIR, f]
		if not used.has(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if FileAccess.file_exists(path + ".import"):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + ".import"))
			gone += 1
	return gone



static func _read_json(path: String) -> Variant:
	var text: = ""
	if FileAccess.file_exists(path):
		text = FileAccess.get_file_as_string(path)
	elif ResourceLoader.exists(path):
		var j: = load(path) as JSON
		return j.data if j != null else null
	if text == "":
		return null
	return JSON.parse_string(text)

static func _write_json(path: String, d: Variant) -> bool:
	var f: = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(_to_json(d), "\t", false) + "\n")
	f.close()
	return true



static func _to_json(v: Variant) -> Variant:
	if v is Color:
		return "#" + (v as Color).to_html(true)
	if v is Vector2:
		return [snappedf((v as Vector2).x, 0.0001), snappedf((v as Vector2).y, 0.0001)]
	if v is float:
		return snappedf(v, 0.0001)
	if v is Dictionary:
		var o: = {}
		for k in v:
			o[k] = _to_json(v[k])
		return o
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(_to_json(x))
		return a
	return v




static func sections() -> Array:
	if _sections_ok:
		return _sections
	_sections = []
	var ord: = _core_order()
	for i in ord.size():
		var id: = String(ord[i][0])
		if is_live(id):
			continue
		for l in layers_of(id):
			var layer: = l as StudioLayer
			if layer.kind == StudioLayer.KIND_BOX and layer.role == "header":
				_sections.append({"sid": layer.sid, "title": GuideTokens.plain(layer.text).strip_edges(), 
					"tags": layer.tags, "spread": id, "index": i, "chapter": int(ord[i][1]), 
					"right": layer.pos.x >= 0.5, "y": layer.pos.y})
	_sections_ok = true
	return _sections

static func find_section(sid: String) -> Dictionary:
	for s in sections():
		if String(s["sid"]) == sid:
			return s
	return {}



static func section_at(id: String, right: bool, y: float) -> Dictionary:
	var best: = {}
	var before: = {}
	for s in sections():
		if s["spread"] == id:
			if bool(s["right"]) == right and float(s["y"]) <= y + 0.01:
				if best.is_empty() or float(s["y"]) > float(best["y"]):
					best = s
			elif not bool(s["right"]) and right:
				if before.is_empty() or float(s["y"]) > float(before["y"]):
					before = s
		elif best.is_empty() and int(s["index"]) < _index_of(id):
			before = s
	return best if not best.is_empty() else before

static func _index_of(id: String) -> int:
	return ids().find(id)





static func search(query: String, limit: = 40) -> Array:
	var words: Array = []
	for w in query.to_lower().split(" ", false):
		if w.strip_edges().length() >= 2:
			words.append(w.strip_edges())
	if words.is_empty():
		return []
	var by_section: = {}
	for e in _search_index():
		var low: = String(e["low"])
		var hay: = String(e["hay"])
		var score: = 0.0
		var first: = -1
		for w in words:
			var at: = hay.find(w)
			if at < 0:
				score = -1.0
				break
			score += 3.0 if bool(e["head"]) else 1.0
			if at < low.length() and (first < 0 or at < first):
				first = at
		if score <= 0.0:
			continue
		var key: = String(e["key"])
		if by_section.has(key) and float(by_section[key]["score"]) >= score:
			continue
		by_section[key] = {"spread": e["spread"], "sid": e["sid"], "title": e["title"], 
			"chapter": e["chapter"], "snippet": _snippet(String(e["text"]), maxi(first, 0)), 
			"score": score, "order": e["order"]}
	var hits: Array = by_section.values()
	hits.sort_custom( func(a, b):
		if float(a["score"]) != float(b["score"]):
			return float(a["score"]) > float(b["score"])
		return int(a["order"]) < int(b["order"]))
	return hits.slice(0, limit)

static var _index: Array = []
static var _index_ok: = false


static func _search_index() -> Array:
	if _index_ok and _sections_ok:
		return _index
	sections()
	_index = []
	var ord: = _core_order()
	for i in ord.size():
		var id: = String(ord[i][0])
		if is_live(id):
			continue
		for l in layers_of(id):
			var layer: = l as StudioLayer
			var text: = _searchable(layer)
			if text.strip_edges() == "":
				continue
			var sec: = section_at(id, layer.pos.x >= 0.5, layer.pos.y)
			var head: = layer.role == "header"
			var low: = text.to_lower()
			_index.append({"text": text, "low": low, "head": head, 
				"hay": low + (" " + String(sec.get("tags", "")).to_lower() if head else ""), 
				"spread": id, "sid": String(sec.get("sid", "")), "title": String(sec.get("title", "")), 
				"chapter": int(ord[i][1]), "order": i, "key": String(sec.get("sid", id))})
	_index_ok = true
	return _index

static func _searchable(l: StudioLayer) -> String:
	match l.kind:
		StudioLayer.KIND_BOX:
			return GuideTokens.plain(l.text)
		StudioLayer.KIND_TEXT:
			return l.text
		StudioLayer.KIND_TABLE:
			var rows: Array = GuideTokens.live_rows(l.live) if l.live.begins_with("controls") else l.cells
			var parts: Array = []
			for row in rows:
				for c in row:
					parts.append(GuideTokens.plain(str(c)))
			return " ".join(PackedStringArray(parts))
	return ""

static func _snippet(text: String, at: int) -> String:
	var flat: = text.replace("\n", " ")
	var start: = maxi(0, at - 28)
	var cut: = flat.substr(start, 80).strip_edges()
	return ("..." if start > 0 else "") + cut + ("..." if start + 80 < flat.length() else "")




static func _box(text: String, pos: Vector2, w: float, px: float, col: Color, font: = StudioLayer.FONT_BOOK) -> StudioLayer:
	var l: = StudioLayer.new()
	l.kind = StudioLayer.KIND_BOX
	l.text = text
	l.pos = pos
	l.w = w
	l.size = px
	l.base_size = px
	l.font = font
	l.color = col
	l.outline = 0.0
	return l

static func _dicts(layers: Array) -> Array:
	var out: Array = []
	for l in layers:
		out.append((l as StudioLayer).to_dict())
	return out

static func _contents() -> Dictionary:
	var ink: = Color("232b3b")
	var layers: Array = []
	layers.append(_box("contents", Vector2(0.25, 0.1), 0.66, 0.06, ink, 0))
	var chs: = chapters()
	var ord: = ids()
	var per_page: = ceili(chs.size() / 2.0)
	for ci in chs.size():
		var right: = ci >= per_page
		var row: = ci - (per_page if right else 0)
		var y: = (0.2 if not right else 0.12) + row * 0.072
		var left: = 0.5 if right else 0.0
		var c: = chs[ci] as Dictionary
		var first: = first_of_chapter(ci)
		var page: = page_of(maxi(0, ord.find(first)), false) if first != "" else 0
		var chip: = StudioLayer.new()
		chip.kind = StudioLayer.KIND_CALLOUT
		chip.text = str(int(c.get("n", ci)))
		chip.size = 0.05
		chip.color = chapter_color(ci)
		chip.outline_color = ink
		chip.stick = true
		chip.stick_width = 0.25
		chip.pos = Vector2(left + 0.07, y)
		chip.link = "ch:%s" % c.get("id", "")
		layers.append(chip)
		var line: = _box("%s" % c.get("title", ""), Vector2(left + 0.24, y), 0.4, 0.032, ink)
		line.link = chip.link
		layers.append(line)
		var num: = _box(str(page), Vector2(left + (0.43 if right else 0.41), y), 0.08, 0.03, Color(ink, 0.6))
		num.align = 2
		num.link = chip.link
		layers.append(num)
	var d: = {"id": "contents", "bg": PAPER, "layers": _dicts(layers)}
	d.merge(PAPER_LOOK)
	return d


static func _index_entries() -> Array:
	var seen: = {}
	var out: Array = []
	for s in sections():
		var sid: = String(s["sid"])


		var names: Array = [String(s["title"])]
		for n in names:
			var key: = (n as String).to_lower()
			if key == "" or seen.has(key + sid):
				continue
			seen[key + sid] = true
			out.append([key, sid])
	out.sort_custom( func(a, b): return String(a[0]) < String(b[0]))
	return out

static func index_spreads() -> int:
	if chapters().is_empty():
		return 0
	return maxi(1, ceili(_index_entries().size() / float(INDEX_PER_COL * 4)))

static func _index_spread(n: int) -> Dictionary:
	var ink: = Color("232b3b")
	var layers: Array = []
	var entries: = _index_entries()
	var per: = INDEX_PER_COL * 4
	var mine: = entries.slice(n * per, (n + 1) * per)
	if n == 0:
		layers.append(_box("index", Vector2(0.25, 0.08), 0.66, 0.05, ink, 0))
	for i in mine.size():
		var col: = i / INDEX_PER_COL
		var row: = i % INDEX_PER_COL
		var x: float = [0.14, 0.36, 0.64, 0.86][col]
		var top: = 0.16 if n == 0 and col < 2 else 0.08
		var e: Array = mine[i]
		var sec: = find_section(String(e[1]))

		var shown: = String(e[0])
		if shown.length() > 30:
			shown = shown.left(28).strip_edges() + "..."
		var line: = _box("%s [color=#%s]%s[/color]" % [shown, Color(ink, 0.5).to_html(false), e[1]], 
			Vector2(x, top + row * 0.038), 0.34, 0.025, ink)
		line.link = String(e[1])
		if sec.is_empty():
			line.link = ""
		layers.append(line)
	var d: = {"id": "index", "bg": PAPER, "layers": _dicts(layers)}
	d.merge(PAPER_LOOK)
	return d
