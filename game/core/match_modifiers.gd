class_name MatchModifiers

























const KIND_TOGGLE: = "toggle"
const KIND_CHOICE: = "choice"



const SWEAT_OPTIONS: = ["off", "normal", "fast", "chaos"]



const SERVE_OPTIONS: = ["15s", "20s", "30s", "45s", "60s"]

const CATALOG: Array = [
	{
		"id": "replays", 
		"name": "instant replays", 
		"kind": KIND_TOGGLE, 
		"default": true, 
		"off_tag": "no instant replays", 
	}, 
	{
		"id": "collide", 
		"name": "team collision", 
		"kind": KIND_TOGGLE, 
		"default": true, 
		"off_tag": "no team collision", 
	}, 
	{
		"id": "rate", 
		"name": "sweat", 
		"kind": KIND_CHOICE, 
		"default": 0, 
		"options": SWEAT_OPTIONS, 
	}, 
	{
		"id": "serve", 
		"name": "serve timer", 
		"kind": KIND_CHOICE, 
		"default": 0, 
		"options": SERVE_OPTIONS, 
	}, 
	{
		"id": "hints", 
		"name": "ball indicators", 
		"kind": KIND_TOGGLE, 
		"default": true, 
		"off_tag": "no ball indicators", 
	}, 
	{





		"id": "lock", 
		"name": "lock teams", 
		"kind": KIND_TOGGLE, 
		"default": false, 
		"on_tag": "teams locked", 
		"online": true, 
	}, 
	{


		"id": "rotate", 
		"name": "rotate every point", 
		"kind": KIND_TOGGLE, 
		"default": false, 
		"on_tag": "rotate every point", 
	}, 
	{


		"id": "intro", 
		"name": "intro sequence", 
		"kind": KIND_TOGGLE, 
		"default": true, 
		"off_tag": "no intro", 
	}, 
]


const COPY: = "res://game/core/match_modifier_copy.gd"


static func desc(id: String) -> String:
	if not ResourceLoader.exists(COPY):
		return ""
	return String((load(COPY) as Script).get_script_constant_map().get("DESC", {}).get(id, ""))


static func entry(id: String) -> Dictionary:
	for e in CATALOG:
		if String((e as Dictionary).id) == id:
			return e
	return {}


static func ids() -> Array:
	var out: Array = []
	for e in CATALOG:
		out.append(String((e as Dictionary).id))
	return out


static func default_of(id: String) -> Variant:
	var e: = entry(id)
	return e.get("default", null) if not e.is_empty() else null




static func from_rules(r: Dictionary) -> Dictionary:
	var out: = {}
	for e in CATALOG:
		var row: Dictionary = e
		var id: = String(row.id)
		out[id] = r.get(id, row.get("default", null))
	return out






static func summary(values: Dictionary) -> Array:
	var out: Array = []
	for e in CATALOG:
		var row: Dictionary = e
		var id: = String(row.id)
		if not values.has(id):
			continue
		var v: Variant = values[id]
		if v == row.get("default", null):
			continue
		if String(row.kind) == KIND_CHOICE:
			var opts: Array = row.get("options", [])
			var i: = clampi(int(v), 0, opts.size() - 1)
			out.append("%s: %s" % [String(row.name), String(opts[i])])
		elif not bool(v):
			out.append(String(row.get("off_tag", "no %s" % String(row.name))))
		else:
			out.append(String(row.get("on_tag", String(row.name))))
	return out



static func changed_count(values: Dictionary) -> int:
	var n: = 0
	for e in CATALOG:
		var row: Dictionary = e
		var id: = String(row.id)
		if values.has(id) and values[id] != row.get("default", null):
			n += 1
	return n
