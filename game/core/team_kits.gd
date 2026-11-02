class_name TeamKits
extends RefCounted


















const DEFAULT_KIT: Array = [Color(0.3, 0.55, 0.95), Color(0.09, 0.09, 0.11), 
	Color.WHITE, Color.WHITE]



const INK_DARK: = Color(0.07, 0.07, 0.09)
const INK_LIGHT: = Color(0.97, 0.97, 1.0)





const NUMBER_MIN_RATIO: = 1.6





const CLASH_DE: = 30.0


const ALT_MARGIN: = 1.25



static func _lin(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)

static func _gam(v: float) -> float:
	v = clampf(v, 0.0, 1.0)
	return v * 12.92 if v <= 0.0031308 else 1.055 * pow(v, 1.0 / 2.4) - 0.055


static func luminance(c: Color) -> float:
	return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b)

static func contrast_ratio(a: Color, b: Color) -> float:
	var la: = luminance(a)
	var lb: = luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)

static func _lab(c: Color) -> Vector3:
	var r: = _lin(c.r)
	var g: = _lin(c.g)
	var b: = _lin(c.b)

	var x: = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
	var y: = 0.2126 * r + 0.7152 * g + 0.0722 * b
	var z: = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
	var fx: = _lab_f(x)
	var fy: = _lab_f(y)
	var fz: = _lab_f(z)
	return Vector3(116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))

static func _lab_f(t: float) -> float:
	return pow(t, 1.0 / 3.0) if t > 0.008856 else 7.787 * t + 16.0 / 116.0

static func delta_e(a: Color, b: Color) -> float:
	return _lab(a).distance_to(_lab(b))


const PROTAN: = [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], 
	[-0.003882, -0.048116, 1.051998]]
const DEUTAN: = [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], 
	[-0.01182, 0.04294, 0.968881]]

static func _seen(c: Color, m: Array) -> Color:
	var r: = _lin(c.r)
	var g: = _lin(c.g)
	var b: = _lin(c.b)
	return Color(_gam(m[0][0] * r + m[0][1] * g + m[0][2] * b), 
		_gam(m[1][0] * r + m[1][1] * g + m[1][2] * b), 
		_gam(m[2][0] * r + m[2][1] * g + m[2][2] * b))




static func jersey_distance(a: Color, b: Color) -> float:
	var d: = delta_e(a, b)
	d = minf(d, delta_e(_seen(a, PROTAN), _seen(b, PROTAN)))
	d = minf(d, delta_e(_seen(a, DEUTAN), _seen(b, DEUTAN)))
	return d






static func number_ink(jersey: Color) -> Color:
	var luma: = jersey.r * 0.299 + jersey.g * 0.587 + jersey.b * 0.114
	return INK_DARK if luma > 0.5 else INK_LIGHT

static func number_reads(jersey: Color, number: Color) -> bool:
	return contrast_ratio(jersey, number) >= NUMBER_MIN_RATIO



static func number_color(kit: Array) -> Color:
	if kit.size() < 1:
		return INK_LIGHT
	var jersey: Color = kit[0]
	if kit.size() >= 4 and number_reads(jersey, kit[3]):
		return kit[3]
	return number_ink(jersey)




static func normalize(kit: Array) -> Array:
	if kit.size() < 3:
		return DEFAULT_KIT.duplicate()
	var out: Array = [kit[0], kit[1], kit[2]]
	out.append(kit[3] if kit.size() >= 4 else number_ink(kit[0]))
	return out

static func to_html(kit: Array) -> Array:
	return kit.map( func(c): return (c as Color).to_html(false))

static func from_html(arr: Array) -> Array:
	return arr.map( func(s): return Color.html(str(s)))

static func kit_distance(a: Array, b: Array) -> float:
	if a.is_empty() or b.is_empty():
		return 0.0

	var d: = jersey_distance(a[0], b[0])
	if a.size() >= 2 and b.size() >= 2:
		d += 0.1 * jersey_distance(a[1], b[1])
	return d

static func clashes(a: Array, b: Array) -> bool:
	if a.is_empty() or b.is_empty():
		return false
	return jersey_distance(a[0], b[0]) < CLASH_DE



static func _fix_number(kit: Array) -> Array:
	var out: = kit.duplicate()
	if out.size() < 4:
		out = normalize(out)
	if not number_reads(out[0], out[3]):
		out[3] = number_ink(out[0])
	return out






const ALT_PALETTE: Array = [Color(0.96, 0.96, 0.95), Color(0.1, 0.1, 0.12), 
	Color(0.98, 0.78, 0.18), Color(0.18, 0.32, 0.85), Color(0.85, 0.16, 0.18), 
	Color(0.12, 0.6, 0.34), Color(0.95, 0.48, 0.1), Color(0.52, 0.24, 0.72)]

static func alternate(kit: Array, other: Array) -> Array:
	var k: = normalize(kit)
	var cands: Array = [
		[k[1], k[0], k[2], k[3]], 
		[k[2], k[1], k[0], k[3]], 
		[k[3], k[1], k[2], k[0]], 
	]
	var j: Color = k[0]
	for turn in [0.5, 0.33, 0.67]:
		cands.append([Color.from_hsv(fposmod(j.h + turn, 1.0), maxf(j.s, 0.55), 
			maxf(j.v, 0.6)), k[1], k[2], k[3]])
	cands.append([ALT_PALETTE[1] if number_ink(other[0]) == INK_DARK else ALT_PALETTE[0], 
		k[1], k[2], k[3]])
	for c in ALT_PALETTE:
		cands.append([c, k[1], k[2], k[3]])
	var best: Array = []
	var top: = -1.0
	for c in cands:
		var fixed: = _fix_number(c)
		var d: = jersey_distance(fixed[0], other[0])
		if d >= CLASH_DE * ALT_MARGIN:
			return fixed
		if d > top:
			top = d
			best = fixed
	return best




static func generated_kit(other: Array, salt: = 0) -> Array:
	var o: = normalize(other)
	var rng: = RandomNumberGenerator.new()
	rng.seed = hash("teamkit:%s:%d" % [str(to_html(o)), salt])
	for _try in 12:
		var hue: = fposmod((o[0] as Color).h + rng.randf_range(0.28, 0.72), 1.0)
		var jersey: = Color.from_hsv(hue, rng.randf_range(0.6, 0.85), 
			rng.randf_range(0.72, 0.95))
		var shorts: = Color.from_hsv(hue, rng.randf_range(0.35, 0.6), 
			rng.randf_range(0.32, 0.5))
		var kit: Array = [jersey, shorts, Color.WHITE, number_ink(jersey)]
		if jersey_distance(jersey, o[0]) >= CLASH_DE * ALT_MARGIN:
			return kit
	return alternate([o[0], Color(0.2, 0.2, 0.24), Color.WHITE, Color.WHITE], o)





static func seat_key(peer: int, ls: int) -> String:
	return "%d:%d" % [peer, ls]





static func cpu_key(side: int, ordinal: int) -> String:
	return "cpu:%d:%d" % [side, ordinal]

static func is_cpu_key(key: String) -> bool:
	return key.begins_with("cpu:")



static func _seated_humans(roster: Array) -> Dictionary:
	var n: = {1: 0, -1: 0}
	for e in roster:
		var entry: Dictionary = e
		var side: = int(entry.get("side", 0))
		if n.has(side) and not bool(entry.get("spec", false)) and int(entry.get("peer", 0)) != 0:
			n[side] = int(n[side]) + 1
	return n

static func _entry_key(entry: Dictionary, seated: Dictionary) -> String:
	var side: = int(entry.get("side", 0))
	if int(entry.get("peer", 0)) != 0:
		return seat_key(int(entry.get("peer", 0)), int(entry.get("ls", 0)))
	return cpu_key(side, int(entry.get("slot", 0)) - int(seated.get(side, 0)))


















static func pick(cands: Dictionary, wanted: = {}, quick_seed: = -1) -> Dictionary:
	var chosen: = {1: {}, -1: {}}
	if quick_seed >= 0:
		chosen = _pick_quick(cands, quick_seed)
	else:
		for side in [1, -1]:
			var list: Array = cands.get(side, [])
			var want: = String(wanted.get(side, ""))
			var fixed: Array = list.filter( func(c): return want != "" and String(c.get("key", "")) == want)
			if not fixed.is_empty():
				chosen[side] = fixed[0]
			elif not list.is_empty():
				chosen[side] = list[0]
	var kits: = {}
	for side in [1, -1]:
		if not (chosen[side] as Dictionary).is_empty():
			kits[side] = normalize(chosen[side].kit)
	if kits.is_empty():
		kits[1] = DEFAULT_KIT.duplicate()
	for side in [1, -1]:
		if not kits.has(side):
			kits[side] = generated_kit(kits[ - side], side)
	var alt: = 0
	if clashes(kits[1], kits[-1]):
		var cpu_side: = 0
		for side in [-1, 1]:
			if _cpu_led(chosen[side]):
				cpu_side = side
				break
		if cpu_side != 0:

			kits[cpu_side] = alternate(kits[cpu_side], kits[ - cpu_side])
			alt = cpu_side
		elif quick_seed >= 0:

			kits[-1] = alternate(kits[-1], kits[1])
			alt = -1
	return {"kits": kits, "alt": alt, 
		"caps": {1: String((chosen[1] as Dictionary).get("key", "")), 
			-1: String((chosen[-1] as Dictionary).get("key", ""))}}

static func _cpu_led(c: Dictionary) -> bool:
	return c.is_empty() or bool(c.get("cpu", false))




static func _pick_quick(cands: Dictionary, quick_seed: int) -> Dictionary:
	var rng: = RandomNumberGenerator.new()
	rng.seed = quick_seed
	var home: Array = cands.get(1, [])
	var away: Array = cands.get(-1, [])
	if home.is_empty() or away.is_empty():
		var out: = {1: {}, -1: {}}
		for side in [1, -1]:
			var list: Array = cands.get(side, [])
			if not list.is_empty():
				out[side] = list[rng.randi_range(0, list.size() - 1)]
		return out
	var pairs: Array = []
	for a in home:
		for b in away:
			pairs.append([a, b])

	for i in range(pairs.size() - 1, 0, -1):
		var j: = rng.randi_range(0, i)
		var t = pairs[i]
		pairs[i] = pairs[j]
		pairs[j] = t
	for p in pairs:
		if not clashes(normalize(p[0].kit), normalize(p[1].kit)):
			return {1: p[0], -1: p[1]}
	return {1: pairs[0][0], -1: pairs[0][1]}







static func pick_roster(roster: Array, wanted: = {}, quick_seed: = -1) -> Dictionary:
	var humans: = {1: [], -1: []}
	var cpus: = {1: [], -1: []}
	var seated: = _seated_humans(roster)
	for e in roster:
		var entry: Dictionary = e
		var side: = int(entry.get("side", 0))
		if bool(entry.get("spec", false)) or not humans.has(side):
			continue
		var cfg: Dictionary = entry.get("cfg", {})
		if cfg.is_empty():
			continue
		var peer: = int(entry.get("peer", 0))
		var cand: = {"kit": CharacterConfig.from_dict(cfg).captain_kit}
		if peer != 0:
			cand["key"] = seat_key(peer, int(entry.get("ls", 0)))
			humans[side].append(cand)
		else:
			cand["key"] = _entry_key(entry, seated)
			cand["cpu"] = true
			cpus[side].append(cand)
	var cands: = {}
	for side in [1, -1]:
		cands[side] = humans[side] if not (humans[side] as Array).is_empty() else cpus[side]

		var want: = String(wanted.get(side, ""))
		if quick_seed < 0 and is_cpu_key(want) and not (humans[side] as Array).is_empty():
			for c in cpus[side]:
				if String((c as Dictionary).key) == want:
					cands[side] = (cands[side] as Array) + [c]
					break
	return pick(cands, wanted, quick_seed)



static func dress_roster(roster: Array, wanted: = {}, quick_seed: = -1) -> Dictionary:
	var res: = pick_roster(roster, wanted, quick_seed)
	var html: = {1: to_html(res.kits[1]), -1: to_html(res.kits[-1])}
	var seated: = _seated_humans(roster)
	for e in roster:
		var entry: Dictionary = e
		var side: = int(entry.get("side", 0))
		entry["kit"] = (html[side] if html.has(side) else html[1]).duplicate()
		var key: = _entry_key(entry, seated)
		if html.has(side) and not bool(entry.get("spec", false))\
		and key == String(res.caps.get(side, "")):
			entry["cap"] = true
		else:
			entry.erase("cap")
	return res
