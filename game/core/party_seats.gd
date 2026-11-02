class_name PartySeats
extends RefCounted























static func list() -> Array:
	var out: Array = []
	var me: = LocalPlayers.primary()
	out.append({"kind": "me", "slot": me, "ls": 0, "peer": _my_peer(), 
		"name": Net.local_display_name(), 
		"cfg": me.profile.character if me.profile != null else {}})
	for slot in LocalPlayers.slots:
		if slot.index == 0:
			continue
		out.append({"kind": "local", "slot": slot, "ls": slot.ls, "peer": _my_peer(), 
			"name": slot.display_name(), 
			"cfg": slot.profile.character if slot.profile != null else {}})
	if Net.party:
		var ids: = Net.party_members()
		ids.sort()
		var mine: = _my_peer()
		for pid in ids:
			if int(pid) == mine:
				continue
			var row: Dictionary = Net.players.get(pid, {})
			out.append({"kind": "remote", "slot": null, "ls": 0, "peer": int(pid), 
				"name": String(row.get("name", "player")), 
				"cfg": row.get("cfg", {})})



			for g in Net.locals_of(int(pid)):
				var gd: Dictionary = g if g is Dictionary else {}
				out.append({"kind": "remote_local", "slot": null, 
					"ls": int(gd.get("ls", 1)), "peer": int(pid), 
					"name": String(gd.get("name", "player")), 
					"cfg": gd.get("cfg", {})})
	for i in out.size():
		out[i]["spot"] = i
	return out

static func count() -> int:
	return list().size()






static func is_leader(seat: Dictionary) -> bool:
	var kind: = String(seat.get("kind", ""))
	if not Net.party:
		return kind == "me"
	if kind == "me":
		return Net.is_host
	return kind == "remote" and int(seat.get("peer", 0)) == 1






static func human_count() -> int:
	var n: = local_count()
	if Net.party:
		var mine: = _my_peer()
		for pid in Net.party_members():
			if int(pid) == mine:
				continue
			n += 1 + Net.locals_of(int(pid)).size()
	return n






static func queue_floor() -> int:
	var n: = human_count()
	if Net.party_still_coming():
		n = maxi(n, int(Net.party_expect.get("count", 0)))
	return n



static func in_party() -> bool:
	return count() > 1



static func has_remote() -> bool:
	return Net.party and Net.party_members().size() > 1

static func local_count() -> int:
	return LocalPlayers.count()



static func _my_peer() -> int:
	if Net.is_host:
		return 1
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.get_multiplayer() == null\
	or tree.get_multiplayer().multiplayer_peer == null:
		return 0
	return tree.get_multiplayer().get_unique_id()
