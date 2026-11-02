class_name PartyMark
extends RefCounted










const ENABLED: = true





const COLORS: = [Color(0.13, 0.53, 1.0), Color("4ec92a"), Color(0.58, 0.28, 1.0), 
	Color(1.0, 0.51, 0.05), Color("22d3ee"), Color(1.0, 0.16, 0.22)]




const ICON_PATH: = "res://game/ui/icons/party_mark.png"
static var _icon: Texture2D = null







static func of_person(roster: Array, peer: int, ls: int, who: String) -> int:
	var by_name: = 0
	for e in roster:
		var entry: Dictionary = e
		var epeer: = int(entry.get("peer", 0))
		if epeer == 0 or bool(entry.get("spec", false)):
			continue
		var pg: = int(entry.get("pg", 0))
		if epeer == peer and int(entry.get("ls", 0)) == ls:
			return pg
		if by_name == 0 and who != "" and String(entry.get("name", "")) == who:
			by_name = pg
	return by_name





static func party_sizes(roster: Array) -> Dictionary:
	var count: = {}
	for e in roster:
		var entry: Dictionary = e
		var pg: = int(entry.get("pg", 0))
		if pg > 0 and int(entry.get("peer", 0)) != 0 and not bool(entry.get("spec", false))\
		and not bool(entry.get("gone", false)):
			count[pg] = int(count.get(pg, 0)) + 1
	return count

static func drawn(entry: Dictionary, sizes: Dictionary) -> int:
	var pg: = int(entry.get("pg", 0))
	return pg if ENABLED and pg > 0 and int(sizes.get(pg, 0)) >= 2 else 0

static func color(group: int) -> Color:
	return COLORS[(maxi(group, 1) - 1) % COLORS.size()]

static func icon() -> Texture2D:
	if _icon == null:
		_icon = load(ICON_PATH) as Texture2D
	return _icon







static func tag_roster(roster: Array, players: Dictionary, own_party: Array) -> void :
	for e in roster:
		(e as Dictionary).erase("pg")
	if not ENABLED:
		return
	var own: = {}
	for pid in own_party:
		own[int(pid)] = true
	var unit_of: = {}
	var size: = {}
	for i in roster.size():
		var e: Dictionary = roster[i]
		var peer: = int(e.get("peer", 0))
		if peer == 0 or bool(e.get("spec", false)) or bool(e.get("gone", false)):
			continue
		var key: = ""
		if own.size() >= 2 and own.has(peer):
			key = "own"
		else:
			var tok: = int((players.get(peer, {}) as Dictionary).get("ptoken", 0))
			key = ("t%d" % tok) if tok != 0 else ("p%d" % peer)
		unit_of[i] = key
		size[key] = int(size.get(key, 0)) + 1
	var number: = {}
	var next: = 1
	for side in [1, -1]:
		var seats: Array = unit_of.keys().filter( func(i):
			return int((roster[i] as Dictionary).get("side", 0)) == side)
		seats.sort_custom( func(a, b):
			return int((roster[a] as Dictionary).get("slot", 0)) < int((roster[b] as Dictionary).get("slot", 0)))
		for i in seats:
			var key: String = unit_of[i]
			if int(size[key]) < 2:
				continue
			if not number.has(key):
				number[key] = next
				next += 1
			(roster[i] as Dictionary)["pg"] = number[key]
