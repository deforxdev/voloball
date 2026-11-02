extends RefCounted



























const REVISION: = 0

enum {BOOL, INT, INTN, UNIT, COLOR, NAME, COLORS, GRADS, KIT, GEAR, ACC}

const HAIRS: = ["", "2twists", "afro", "brother", "buzz", "cornrow", "curves", "dai", 
	"dreadfull", "dreadlong", "fall", "hae", "hightop", "hue", "jasmine", "jeremy", "kage", 
	"kai", "kasa", "longhair", "mamii", "mao", "may", "meku", "mob", "momhair", "oody", 
	"ponytail", "ps68", "shrimpy", "spiky", "swirls", "swirlyhair", "teto", "topfade", 
	"topknot", "twisttie", "van", "veritas", "wynd", "yumee"]
const BEARDS: = ["", "fullbeard", "goatee", "goatee_stache", "stache"]
const BLUSHES: = ["circle", "dashes", "band", "freckles", "aublush", "blushwhisk", "swirl"]
const EARS: = [""]
const ACC_IDS: = ["achromatic", "adventurebackpack", "adventurehat", "antennae", "aubade", 
	"backscythe", "bandana", "batwings", "beanie", "bow", "bunnyears", "bunnyheadband", "cape", 
	"catears", "crown", "devilhorns", "eyepatch", "facemask", "halo", "headband", "headphones", 
	"headscrew", "horns", "key", "knight", "mouseear", "nose_bandage", "punk_glasses", 
	"roundglasses", "scarf", "sleekvisor", "spinny_hat", "sprout", "square_glasses", 
	"swirlglasses", "visor", "wings", "witch_hat", "tophat", "partyhat"]
const ACC_SLOTS: = ["head", "head2", "head3", "face", "face2", "face3", "extra", "extra2", "extra3"]
const ACC_MOVES: = ["px", "py", "pz", "rx", "ry", "rz", "sc", "sx", "sy", "sz"]
const NAME_TABLES: = {"hair": HAIRS, "fh": BEARDS, "blk": BLUSHES, "ear": EARS}


const PALETTE: = ["000000", "ffffff", "17171c", "4d8cf2", "618fd6", "f58585", 
	"211a14", "47301c", "7a5226", "b88c42", "dec98c", "8c170f", "595961", "e0e0e6", "3d59a6", 
	"8c4099", "d973a6", "338c66", 
	"fffaf7", "fcf2e6", "faebd6", "ffdeba", "f5cca1", "e6b585", "cc996b", "a87852", "855c3d", 
	"66452e", "473021", "2e1f17", 
	"edebe3", "d1d1d6", "40424d", "4d73cc", "bf4742", "528c61", "e0bf59", "8c61a6", 
	"33363d", "5c6b85", "9ec7e0", "6b4d42", 
	"121217", "f7f7ff"]

const ALPHA: = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"




const GEAR_FIELDS: = [
	["sl", INT, 0, 3], ["skl", INT, 0, 2], ["gso", BOOL, true, 0], ["sk", COLOR, "17171c", 0], 
	["gkp", BOOL, true, 0], ["kps", INT, 0, 2], ["kpsl", INT, 0, 2], ["kpw", INT, 0, 2], 
	["kpm", BOOL, true, 0], ["kp", COLOR, "17171c", 0], ["kpl", COLOR, "17171c", 0], 
	["sh", COLOR, "17171c", 0]]
const GROUPS: = [

	[["face", INT, 0, 2], ["skin", INT, 0, 4], ["skx", BOOL, false, 0], ["skc", COLOR, "ffdeba", 0], 
		["hs", INT, 0, 3], ["ear", NAME, "", 2], ["lh", BOOL, false, 0], 
		[["h", UNIT, 0.5, 0], ["w", UNIT, 0.5, 0]]], 

	[["hair", NAME, "2twists", 6], ["hc", INT, 0, 4], ["hcol", COLOR, "211a14", 0], 
		["hfl", BOOL, false, 0], ["hcols", COLORS, [], 0], ["hgrad", GRADS, [], 0]], 

	[["es", INT, 0, 3], ["eyc", COLOR, "000000", 0], ["elc", COLOR, "000000", 0], 
		[["ez", UNIT, 0.5, 0], ["ew", UNIT, 0.5, 0], ["eyz", UNIT, 0.5, 0], ["eh", UNIT, 0.5, 0], 
		["ex", UNIT, 0.5, 0], ["er", UNIT, 0.5, 0], ["epx", UNIT, 0.5, 0]]], 

	[["bs", INTN, 0, 3], ["bwc", COLOR, "000000", 0], 
		[["bh", UNIT, 0.5, 0], ["br", UNIT, 0.5, 0], ["bsp", UNIT, 0.5, 0], ["bsz", UNIT, 0.5, 0], 
		["bwid", UNIT, 0.5, 0], ["bht", UNIT, 0.5, 0], ["bpx", UNIT, 0.5, 0]]], 

	[["ms", INT, 0, 3], 
		[["mz", UNIT, 0.5, 0], ["mw", UNIT, 0.5, 0], ["my", UNIT, 0.5, 0], ["mh", UNIT, 0.5, 0], 
		["mr", UNIT, 0.5, 0], ["mpx", UNIT, 0.5, 0]]], 

	[["ns", INTN, 0, 3], ["nfl", BOOL, false, 0], 
		[["nz", UNIT, 0.5, 0], ["nw", UNIT, 0.5, 0], ["ny", UNIT, 0.5, 0], ["nh", UNIT, 0.5, 0], 
		["nx", UNIT, 0.5, 0]]], 

	[["bl", BOOL, false, 0], ["blk", NAME, "circle", 4], ["blsh", INT, 0, 3], 
		["blc", COLOR, "f58585", 0], 
		[["bz", UNIT, 0.5, 0], ["bw", UNIT, 0.5, 0], ["bhy", UNIT, 0.5, 0], ["bx", UNIT, 0.5, 0], 
		["bo", UNIT, 0.5, 0]]], 

	[["fh", NAME, "", 3], ["fhcols", COLORS, [], 0], 
		[["fpx", UNIT, 0.5, 0], ["fpy", UNIT, 0.5, 0], ["fpz", UNIT, 0.5, 0], ["frx", UNIT, 0.5, 0], 
		["fry", UNIT, 0.5, 0], ["frz", UNIT, 0.5, 0], ["fsc", UNIT, 0.5, 0], ["fsx", UNIT, 0.5, 0], 
		["fsy", UNIT, 0.5, 0], ["fsz", UNIT, 0.5, 0]]], 

	[["vo", INT, 2, 3], ["vpk", INT, 1, 2], [["vp", UNIT, 0.5, 0], ["vs", UNIT, 0.5, 0]]], 

	[["num", INT, 1, 7], ["kh", KIT, ["4d8cf2", "17171c", "ffffff", "ffffff"], 0]], 

	GEAR_FIELDS, 

	[["gt", COLOR, "edebe3", 0], ["gs", COLOR, "618fd6", 0], ["gsh", INT, 0, 3], 
		["hdc", COLOR, "4d8cf2", 0], ["hdx", BOOL, false, 0], ["gg", GEAR, null, 0]], 

	[["acc", ACC, null, 0]], 
]

const MAX_LIST: = 16
const MAX_TEXT: = 64
const MAX_JSON: = 4096



static func pack(d: Dictionary) -> PackedByteArray:
	var o: = _Out.new()
	_pack(o, d)
	return o.bytes


static func extras_of(d: Dictionary) -> Dictionary:
	var o: = _Out.new()
	_pack(o, d)
	return o.extras

static func _pack(o: _Out, d: Dictionary) -> void :
	o.put_u(REVISION, 2)
	for g in GROUPS:
		_put_group(o, _items_at(g, REVISION), d)
	var known: = {"name": true}
	for f in _fields_of(GROUPS):
		known[f[0]] = true
	for k in d:
		if not known.has(k):
			o.extras[k] = d[k]
	o.bit( not o.extras.is_empty())
	if not o.extras.is_empty():
		_put_json(o, o.extras)


static func unpack(b: PackedByteArray) -> Dictionary:
	var r: = _In.new(b)
	var rev: = r.take_u(2)
	if r.bad or rev > REVISION:
		return {}
	var d: = base_dict()
	for g in GROUPS:
		_take_group(r, _items_at(g, rev), d)
		if r.bad:
			return {}
	if r.flag():
		var ex: Variant = _take_json(r)
		if not (ex is Dictionary):
			return {}
		for k in ex:
			if k == "gg" and ex[k] is Dictionary and d["gg"] is Dictionary:
				(d["gg"] as Dictionary).merge(ex[k])
			elif not d.has(k):
				d[k] = ex[k]
	return {} if r.bad else d


static func base_dict() -> Dictionary:
	var d: = {}
	for f in _fields_of(GROUPS):
		match f[1]:
			GEAR:
				d[f[0]] = _gear_base()
			ACC:
				d[f[0]] = {}
			_:
				d[f[0]] = f[2].duplicate() if f[2] is Array else f[2]
	return d


static func _fields_of(items: Array) -> Array:
	var out: Array = []
	for it in items:
		if it[0] is Array:
			out.append_array(_fields_of(it))
		else:
			out.append(it)
	return out



static func _items_at(items: Array, rev: int) -> Array:
	var out: Array = []
	for it in items:
		if it[0] is Array:
			var sub: = _items_at(it, rev)
			if not sub.is_empty():
				out.append(sub)
		elif (it[4] if it.size() > 4 else 0) <= rev:
			out.append(it)
	return out

static func _differs(it: Array, d: Dictionary) -> bool:
	if it[0] is Array:
		for sub in it:
			if _differs(sub, d):
				return true
		return false
	return not _same(it[1], d.get(it[0], it[2]), it[2])



static func _put_group(o: _Out, items: Array, d: Dictionary) -> void :
	if items.is_empty():
		return
	var diff: Array[bool] = []
	for it in items:
		diff.append(_differs(it, d))
	o.bit(diff.has(true))
	if not diff.has(true):
		return
	for i in items.size():
		var it: Array = items[i]
		if it[0] is Array:
			_put_group(o, it, d)
			continue
		if items.size() > 1:
			o.bit(diff[i])
		if diff[i]:
			_put_value(o, it, d.get(it[0]), d)

static func _take_group(r: _In, items: Array, d: Dictionary) -> void :
	if items.is_empty() or not r.flag():
		return
	for it in items:
		if it[0] is Array:
			_take_group(r, it, d)
		elif items.size() == 1 or r.flag():
			d[it[0]] = _take_value(r, it, it[2], d)

static func _gear_base() -> Dictionary:
	var g: = {}
	for f in GEAR_FIELDS:
		g[f[0]] = f[2]
	return g



static func _same(kind: int, v: Variant, base: Variant) -> bool:
	match kind:
		BOOL:
			return not (v is bool) or v == base
		INT, INTN:
			return not (v is int or v is float) or int(v) == int(base)
		UNIT:
			return _step(v) == _step(base)
		COLOR:
			var h: = _hex(v)
			return h == "" or h == base
		NAME:
			return not (v is String) or v == base
		COLORS:
			return _colors(v) == _colors(base)
		GRADS:
			return JSON.stringify(_grads(v)) == JSON.stringify(_grads(base))
		KIT:
			var k: = _kit(v)
			return k.is_empty() or k == base
		GEAR:
			if not (v is Dictionary):
				return true
			var gb: = _gear_base()
			for f in GEAR_FIELDS:
				if not _same(f[1], (v as Dictionary).get(f[0], gb[f[0]]), gb[f[0]]):
					return false
			for k in v:
				if not gb.has(k):
					return false
			return true
		ACC:
			return not (v is Dictionary) or (v as Dictionary).is_empty()
	return true

static func _put_value(o: _Out, f: Array, v: Variant, d: Dictionary) -> void :
	match f[1]:
		INT:
			o.put_u(maxi(int(v), 0), f[3])
		INTN:
			o.put_u(maxi(int(v) + 1, 0), f[3])
		UNIT:
			o.put(_step(v), 6)
		COLOR:
			_put_color(o, _hex(v))
		NAME:
			_put_name(o, String(v), NAME_TABLES[f[0]], f[3])
		COLORS:
			_put_colors(o, _colors(v))
		GRADS:
			_put_grads(o, _grads(v))
		KIT:
			_put_kit(o, _kit(v), f[2])
		GEAR:
			_put_gym_gear(o, v, d)
		ACC:
			_put_acc(o, v)


static func _take_value(r: _In, f: Array, base: Variant, d: Dictionary) -> Variant:
	match f[1]:
		BOOL:
			return not bool(base)
		INT:
			return r.take_u(f[3])
		INTN:
			return r.take_u(f[3]) - 1
		UNIT:
			return mini(r.take(6), 50) * 0.02
		COLOR:
			return _take_color(r)
		NAME:
			return _take_name(r, NAME_TABLES[f[0]], f[3])
		COLORS:
			return _take_colors(r)
		GRADS:
			return _take_grads(r)
		KIT:
			return _take_kit(r, f[2])
		GEAR:
			return _take_gym_gear(r, d)
		ACC:
			return _take_acc(r)
	return base



static func _step(v: Variant) -> int:
	if not (v is float or v is int) or not is_finite(float(v)):
		return 25
	return clampi(roundi(float(v) / 0.02), 0, 50)


static func _fade(v: Variant) -> int:
	if not (v is float or v is int) or not is_finite(float(v)):
		return 0
	return clampi(roundi(float(v) * 100.0), 0, 100)


static func _hex(v: Variant) -> String:
	if v is String and Color.html_is_valid(v):
		return Color.html(v).to_html(false)
	return ""





static func _put_color(o: _Out, hex: String) -> void :
	var i: = o.seen.find(hex)
	if i != -1:
		o.put(2, 2)
		o.put(i, _width(o.seen.size()))
		return
	i = PALETTE.find(hex)
	if i != -1:
		o.put(3, 2)
		o.put(i, 6)
		return
	o.put(0, 1)
	o.put(hex.hex_to_int(), 24)
	o.seen.append(hex)

static func _take_color(r: _In) -> String:
	if not r.flag():
		var hex: = "%06x" % r.take(24)
		r.seen.append(hex)
		return hex
	if not r.flag():
		var n: = r.seen.size()
		var i: = r.take(_width(n))
		if i >= n:
			r.bad = true
			return "000000"
		return r.seen[i]
	var p: = r.take(6)
	if p >= PALETTE.size():
		r.bad = true
		return "000000"
	return PALETTE[p]


static func _width(n: int) -> int:
	var w: = 0
	while (1 << w) < n:
		w += 1
	return w


static func _colors(v: Variant) -> Array:
	var out: Array = []
	if v is Array:
		for e in (v as Array).slice(0, MAX_LIST):
			out.append(_hex(e))
	return out

static func _put_colors(o: _Out, list: Array) -> void :
	o.put_u(list.size(), 4)
	for h in list:
		o.bit(h != "")
		if h != "":
			_put_color(o, h)

static func _take_colors(r: _In) -> Array:
	var n: = r.take_u(4)
	if n > MAX_LIST:
		r.bad = true
		return []
	var out: Array = []
	for _i in n:
		out.append(_take_color(r) if r.flag() else "")
	return out


static func _grads(v: Variant) -> Array:
	var out: Array = []
	if not (v is Array):
		return out
	for e in (v as Array).slice(0, MAX_LIST):
		var g: = {}
		if e is Dictionary:
			if e.get("on") is bool:
				g["on"] = e["on"]
			if _hex(e.get("b")) != "":
				g["b"] = _hex(e["b"])
			for k in ["fs", "fe"]:
				if e.get(k) is float or e.get(k) is int:
					g[k] = _fade(e[k])
		out.append(g)
	return out

static func _put_grads(o: _Out, list: Array) -> void :
	o.put_u(list.size(), 4)
	for g in list:
		o.bit( not g.is_empty())
		if g.is_empty():
			continue
		o.bit(g.has("on"))
		if g.has("on"):
			o.bit(g["on"])
		o.bit(g.has("b"))
		if g.has("b"):
			_put_color(o, g["b"])
		for k in ["fs", "fe"]:
			o.bit(g.has(k))
			if g.has(k):
				o.put(g[k], 7)

static func _take_grads(r: _In) -> Array:
	var n: = r.take_u(4)
	if n > MAX_LIST:
		r.bad = true
		return []
	var out: Array = []
	for _i in n:
		var g: = {}
		if r.flag():
			if r.flag():
				g["on"] = r.flag()
			if r.flag():
				g["b"] = _take_color(r)
			for k in ["fs", "fe"]:
				if r.flag():
					g[k] = mini(r.take(7), 100) * 0.01
		out.append(g)
	return out


static func _kit(v: Variant) -> Array:
	if not (v is Array) or not ((v as Array).size() == 3 or (v as Array).size() == 4):
		return []
	var out: Array = []
	for e in v:
		if _hex(e) == "":
			return []
		out.append(_hex(e))
	return out

static func _put_kit(o: _Out, kit: Array, base: Array) -> void :
	o.bit(kit.size() == 4)
	for i in kit.size():
		var same: bool = i < base.size() and kit[i] == base[i]
		o.bit(same)
		if not same:
			_put_color(o, kit[i])

static func _take_kit(r: _In, base: Array) -> Array:
	var out: Array = []
	for i in (4 if r.flag() else 3):
		out.append(base[i] if r.flag() else _take_color(r))
	return out





static func _put_gym_gear(o: _Out, v: Variant, d: Dictionary) -> void :
	var gg: Dictionary = v if v is Dictionary else {}
	var base: = _gear_base()
	var uni: = {}
	for f in GEAR_FIELDS:
		uni[f[0]] = d.get(f[0], f[2])
	var cost_base: = 0
	var cost_uni: = 0
	for f in GEAR_FIELDS:
		var val: Variant = gg.get(f[0], f[2])
		cost_base += 0 if _same(f[1], val, base[f[0]]) else 1
		cost_uni += 0 if _same(f[1], val, uni[f[0]]) else 1
	var ref: = uni if cost_uni < cost_base else base
	o.bit(cost_uni < cost_base)
	for f in GEAR_FIELDS:
		var val: Variant = gg.get(f[0], f[2])
		var diff: = not _same(f[1], val, ref[f[0]])
		o.bit(diff)
		if diff:
			_put_value(o, f, val, d)
	for k in gg:
		if not base.has(k):
			if not o.extras.has("gg"):
				o.extras["gg"] = {}
			o.extras["gg"][k] = gg[k]

static func _take_gym_gear(r: _In, d: Dictionary) -> Dictionary:
	var gg: = _gear_base()
	if r.flag():
		for f in GEAR_FIELDS:
			gg[f[0]] = d.get(f[0], f[2])
	for f in GEAR_FIELDS:
		if r.flag():
			gg[f[0]] = _take_value(r, f, gg[f[0]], d)
	return gg






static func _put_acc(o: _Out, v: Variant) -> void :
	var acc: Dictionary = v if v is Dictionary else {}
	for s in ACC_SLOTS:
		o.bit(acc.get(s) is Dictionary)
	var others: Array = []
	for s in acc:
		if s is String and not ACC_SLOTS.has(s) and acc[s] is Dictionary and others.size() < 4:
			others.append(s)
	o.bit( not others.is_empty())
	if not others.is_empty():
		o.put_u(others.size(), 2)
		for s in others:
			_put_text(o, s)
	for s in ACC_SLOTS:
		if acc.get(s) is Dictionary:
			_put_slot(o, acc[s])
	for s in others:
		_put_slot(o, acc[s])

static func _take_acc(r: _In) -> Dictionary:
	var worn: Array = []
	for s in ACC_SLOTS:
		if r.flag():
			worn.append(s)
	if r.flag():
		var n: = r.take_u(2)
		if n > 4:
			r.bad = true
			return {}
		for _i in n:
			worn.append(_take_text(r))
	var acc: = {}
	for s in worn:
		if r.bad:
			return {}
		acc[s] = _take_slot(r)
	return acc

const _SLOT_KEYS: = ["id", "fl", "cols", "grads"]

static func _put_slot(o: _Out, st: Dictionary) -> void :
	_put_name(o, String(st.get("id", "")), ACC_IDS, 6)
	var moved: = false
	for k in ACC_MOVES:
		moved = moved or not _same(UNIT, st.get(k, 0.5), 0.5)
	o.bit(moved)
	if moved:
		for k in ACC_MOVES:
			var diff: = not _same(UNIT, st.get(k, 0.5), 0.5)
			o.bit(diff)
			if diff:
				o.put(_step(st[k]), 6)
	o.bit(st.get("fl", false) == true)
	var cols: = _colors(st.get("cols"))
	o.bit( not cols.is_empty())
	if not cols.is_empty():
		_put_colors(o, cols)
	var grads: = _grads(st.get("grads"))
	o.bit( not grads.is_empty())
	if not grads.is_empty():
		_put_grads(o, grads)
	var ex: = {}
	for k in st:
		if not _SLOT_KEYS.has(k) and not ACC_MOVES.has(k):
			ex[k] = st[k]
	o.bit( not ex.is_empty())
	if not ex.is_empty():
		_put_json(o, ex)

static func _take_slot(r: _In) -> Dictionary:
	var st: = {}
	var id: = _take_name(r, ACC_IDS, 6)
	if id != "":
		st["id"] = id
	if r.flag():
		for k in ACC_MOVES:
			if r.flag():
				st[k] = mini(r.take(6), 50) * 0.02
	if r.flag():
		st["fl"] = true
	if r.flag():
		st["cols"] = _take_colors(r)
	if r.flag():
		st["grads"] = _take_grads(r)
	if r.flag():
		var ex: Variant = _take_json(r)
		if not (ex is Dictionary):
			r.bad = true
			return st
		for k in ex:
			if not st.has(k):
				st[k] = ex[k]
	return st




static func _put_name(o: _Out, s: String, table: Array, width: int) -> void :
	var i: = table.find(s)
	o.put_u(i + 1 if i != -1 else 0, width)
	if i == -1:
		_put_text(o, s)

static func _take_name(r: _In, table: Array, width: int) -> String:
	var i: = r.take_u(width)
	if i == 0:
		return _take_text(r)
	if i - 1 < table.size():
		return table[i - 1]
	r.bad = true
	return ""

static func _put_text(o: _Out, s: String) -> void :
	s = s.left(MAX_TEXT)
	var six: = true
	for ch in s:
		six = six and ALPHA.contains(ch)
	o.bit( not six)
	o.put_u(s.length(), 5 if six else 6)
	for ch in s:
		var code: = ch.unicode_at(0)
		if six:
			o.put(ALPHA.find(ch), 6)
		else:
			o.put(code if code >= 32 and code < 127 else 63, 7)

static func _take_text(r: _In) -> String:
	var seven: = r.flag()
	var n: = r.take_u(6 if seven else 5)
	if n > MAX_TEXT:
		r.bad = true
		return ""
	var s: = ""
	for _i in n:
		if seven:
			var code: = r.take(7)
			if code < 32:
				r.bad = true
				return ""
			s += char(code)
		else:
			s += ALPHA[r.take(6)]
	return s



static func _put_json(o: _Out, v: Variant) -> void :
	var s: = ""
	for ch in JSON.stringify(v):
		var code: = ch.unicode_at(0)
		if code < 128:
			s += ch
		elif code < 65536:
			s += "\\u%04x" % code
		else:
			code -= 65536
			s += "\\u%04x\\u%04x" % [55296 + (code >> 10), 56320 + (code & 1023)]
	var b: = s.to_ascii_buffer()
	if b.size() > MAX_JSON:
		b = "{}".to_ascii_buffer()
	o.put_u(b.size(), 8)
	for x in b:
		o.put(x, 8)

static func _take_json(r: _In) -> Variant:
	var n: = r.take_u(8)
	if n > MAX_JSON or r.bad:
		r.bad = true
		return null
	var b: = PackedByteArray()
	b.resize(n)
	for i in n:
		b[i] = r.take(8)
		if b[i] >= 128:
			r.bad = true
	if r.bad:
		return null
	var json: = JSON.new()
	if json.parse(b.get_string_from_ascii()) != OK:
		return null
	return json.data



class _Out:
	var bytes: = PackedByteArray()
	var nbits: = 0
	var seen: Array[String] = []
	var extras: = {}

	func bit(on: bool) -> void :
		put(1 if on else 0, 1)


	func put(v: int, n: int) -> void :
		for i in range(n - 1, -1, -1):
			if nbits % 8 == 0:
				bytes.append(0)
			if (v >> i) & 1:
				bytes[nbits >> 3] = bytes[nbits >> 3] | (128 >> (nbits & 7))
			nbits += 1



	func put_u(v: int, w: int) -> void :
		var cap: = (1 << w) - 1
		if v < cap:
			put(v, w)
			return
		put(cap, w)
		v -= cap
		while true:
			var more: = v > 15
			bit(more)
			put(v & 15, 4)
			v >>= 4
			if not more:
				break

class _In:
	var bytes: PackedByteArray
	var pos: = 0
	var bad: = false
	var seen: Array[String] = []

	func _init(b: PackedByteArray) -> void :
		bytes = b

	func take(n: int) -> int:
		if pos + n > bytes.size() * 8:
			bad = true
			pos = bytes.size() * 8
			return 0
		var v: = 0
		for _i in n:
			v = (v << 1) | ((bytes[pos >> 3] >> (7 - (pos & 7))) & 1)
			pos += 1
		return v

	func flag() -> bool:
		return take(1) == 1

	func take_u(w: int) -> int:
		var v: = take(w)
		if v < (1 << w) - 1:
			return v
		var shift: = 0
		while not bad:
			var more: = flag()
			v += take(4) << shift
			shift += 4
			if not more:
				break
			if shift >= 32:
				bad = true
		return v
