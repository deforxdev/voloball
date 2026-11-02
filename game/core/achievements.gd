extends Node






























signal unlocked(def: AchievementDef, scope: String)
signal progressed(def: AchievementDef, value: int, scope: String)
signal claimed(def: AchievementDef, amount: int)




const CATALOG: = "res://game/core/achievement_catalog.gd"
const FILE: = "achievements.json"
const SAVE_DELAY: = 1.5
const SAVE_DELAY_QUIET: = 30.0
const DAY: = 86400

var _catalog: Script = null
var _defs: Array = []
var _by_event: = {}
var _steam_done: = {}
var _dirty: = false
var _save_in: = 0.0
var _opened_for: = {}
var _by_id: = {}
var _picks_of: = {}



var test_active: Variant = null


signal claimable_changed(count: int)

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists(CATALOG):
		_catalog = load(CATALOG)
		_defs = _catalog.all()
	for def in _defs:
		_by_id[def.id] = def
		if not _by_event.has(def.event):
			_by_event[def.event] = []
		_by_event[def.event].append(def)
	_load_machine()
	if ProfileStore.has_signal("changed"):
		ProfileStore.changed.connect(_on_profile_changed)


	_boot.call_deferred()

func _boot() -> void :
	_reconcile_steam()
	_on_profile_changed()

func _process(delta: float) -> void :
	if _dirty:
		_save_in -= delta
		if _save_in <= 0.0 and not ProfileStore.hold_saves:
			_flush()

func _exit_tree() -> void :
	_flush()



func notify(event: String, data: = {}) -> void :
	notify_for(ProfileStore.active(), event, data)






func notify_for(p: SavedProfile, event: String, data: = {}) -> void :



	if LaunchGate.public_beta():
		return
	if p == null:
		return


	Career.tally(p, event, data)
	if not _by_event.has(event):
		return
	var active: = p == ProfileStore.active()
	var store: = _profile_store(p)
	_roll_periods(store, p)
	if event == "match_end":
		data = _match_story(store, data)
		_mark_dirty()
	elif event == "drill":
		data = _drill_story(store, data)
		_mark_dirty()
	var globals_finished: = false
	for def in _by_event[event]:
		var d: AchievementDef = def
		if not d.counts(data):
			continue
		if d.kind != "global" and not is_active(d):
			continue
		var amount: = maxi(1, int(data.get("amount", 1)))
		var bucket: Dictionary = _bucket(store, d.kind)
		var row: Dictionary = bucket.get(d.id, {"v": 0, "done": false, "at": 0})
		if bool(row.get("done", false)):
			continue
		if not d.split.is_empty():

			var parts: Dictionary = (row.get("parts", {}) as Dictionary).duplicate()
			var sum: = 0
			for k in d.split:
				var cap: = int(d.split[k])
				parts[k] = clampi(int(parts.get(k, 0)) + maxi(0, int(data.get(k, 0))), 0, cap)
				sum += int(parts[k])
			row["parts"] = parts
			row["v"] = mini(sum, d.target)
		elif d.track != "":


			var now: = maxi(0, int(data.get(d.track, 0)))
			row["v"] = clampi(maxi(int(row.get("v", 0)), now) if d.peak else now, 0, d.target)
		elif data.has("level"):


			row["v"] = clampi(maxi(int(row.get("v", 0)), int(data.get("level", 0))), 
				0, d.target)
		else:
			row["v"] = mini(int(row.get("v", 0)) + amount, d.target)
		var finished: = int(row["v"]) >= d.target
		if finished:
			row["done"] = true
			row["at"] = int(Time.get_unix_time_from_system())
			row["claimed"] = false
			_remember(store, d.id)
		bucket[d.id] = row
		_mark_dirty(bool(data.get("quiet", false)) and not finished)
		if not finished:
			if active:
				progressed.emit(d, int(row["v"]), d.kind if d.kind != "global" else "profile")
			continue
		match d.kind:
			"global":
				globals_finished = true
				if active:
					unlocked.emit(d, "profile")
					if not _steam_done.has(d.id):
						_earn_machine(d)
			_:
				if active:
					unlocked.emit(d, d.kind)
		if active:
			claimable_changed.emit(claimable_count())
	if globals_finished and event != "global_done":

		notify_for(p, "global_done", {"n": _globals_done(store)})




func _remember(store: Dictionary, id: String) -> void :
	if not (store.get("ever") is Dictionary):
		store["ever"] = {}
	if not (store["ever"] as Dictionary).has(id):
		store["ever"][id] = int(Time.get_unix_time_from_system())



func ever_done(id: String, p: SavedProfile = null) -> bool:
	if p == null:
		p = ProfileStore.active()
	var d: AchievementDef = _by_id.get(id)
	if p == null or d == null:
		return false
	var store: = _profile_store(p)
	if store.get("ever") is Dictionary and (store["ever"] as Dictionary).has(id):
		return true
	var row: Variant = _bucket(store, d.kind).get(id)
	return row is Dictionary and bool(row.get("done", false))



func _drill_story(store: Dictionary, data: Dictionary) -> Dictionary:
	data = data.duplicate()
	var id: = String(data.get("id", ""))
	var cat: = String(DrillCatalog.entry(id).get("category", ""))
	data["category"] = cat
	if not (store.get("drills") is Dictionary):
		store["drills"] = {}
	var done: Dictionary = store["drills"]
	if cat != "":
		done[id] = true
	var n: = 0
	for item in DrillCatalog.DRILLS:
		if String(item.get("category", "")) == cat and done.has(String(item.get("id", ""))):
			n += 1
	data["cat_done"] = n
	return data


func _globals_done(store: Dictionary) -> int:
	var n: = 0
	var g: Dictionary = store["global"]
	for d in _defs:
		if d.kind == "global" and d.event != "global_done"\
		and g.get(d.id) is Dictionary and bool(g[d.id].get("done", false)):
			n += 1
	return n







func _match_story(store: Dictionary, data: Dictionary) -> Dictionary:
	data = data.duplicate()
	var won: = bool(data.get("won", false))
	data["after_loss"] = bool(store.get("last_lost", false))
	store["last_lost"] = not won
	store["win_streak"] = (int(store.get("win_streak", 0)) + 1) if won else 0
	store["loss_streak"] = 0 if won else (int(store.get("loss_streak", 0)) + 1)
	data["win_streak"] = int(store["win_streak"])
	data["loss_streak"] = int(store["loss_streak"])


	var map: String = _catalog.map_of(String(data.get("stage", "")))
	if not (store.get("stages") is Dictionary):
		store["stages"] = {}
	var stages: Dictionary = store["stages"]
	if map != "":
		stages[map] = int(stages.get(map, 0)) + 1
	data["stage_plays"] = int(stages.get(map, 0))
	var seen: = 0
	var maps: Array = _catalog.match_stages()
	for s in stages:
		if String(s) in maps:
			seen += 1
	data["stages_seen"] = seen
	return data









func debug_award_all() -> int:
	if LaunchGate.public_beta():
		return 0
	var p: SavedProfile = ProfileStore.active()
	if p == null:
		return 0
	var store: = _profile_store(p)
	_roll_periods(store)
	var now: = int(Time.get_unix_time_from_system())
	var done: = 0
	for def in _defs:
		var d: AchievementDef = def
		if not is_active(d):
			continue
		var bucket: Dictionary = _bucket(store, d.kind)
		var row: Dictionary = bucket.get(d.id, {"v": 0, "done": false, "at": 0})
		if bool(row.get("done", false)):
			continue
		row["v"] = d.target
		row["done"] = true
		row["at"] = now
		row["claimed"] = false
		bucket[d.id] = row
		_remember(store, d.id)
		done += 1

		progressed.emit(d, d.target, d.kind if d.kind != "global" else "profile")
	if done > 0:
		_mark_dirty()
		claimable_changed.emit(claimable_count())
	return done






func _is_claimed(row: Dictionary, kind: String) -> bool:
	if row.has("claimed"):
		return bool(row["claimed"])
	return kind != "global"





func claim(def: AchievementDef) -> int:
	if def == null or LaunchGate.public_beta():
		return 0
	var p: SavedProfile = ProfileStore.active()
	if p == null:
		return 0
	var store: = _profile_store(p)
	_roll_periods(store)
	var bucket: Dictionary = _bucket(store, def.kind)
	if not bucket.has(def.id):
		return 0
	var row: Dictionary = bucket[def.id]
	if not bool(row.get("done", false)) or _is_claimed(row, def.kind):
		return 0
	row["claimed"] = true
	bucket[def.id] = row
	if def.coins > 0:
		Progression.add_coins(def.coins)
	var levelup: = Progression.add_xp(Progression.claim_xp(def.coins))
	_mark_dirty()
	claimed.emit(def, def.coins)
	claimable_changed.emit(claimable_count())
	return def.coins + levelup


func claimable_ids(kind: = "") -> Array:
	var out: Array = []
	var p: SavedProfile = ProfileStore.active()
	if p == null or LaunchGate.public_beta():
		return out
	var store: = _profile_store(p)
	_roll_periods(store)
	for d in _defs:
		if kind != "" and d.kind != kind:
			continue
		var row: Variant = _bucket(store, d.kind).get(d.id)
		if row is Dictionary and bool(row.get("done", false)) and not _is_claimed(row, d.kind):
			out.append(d.id)
	return out

func claimable_count(kind: = "") -> int:
	return claimable_ids(kind).size()


func claimable_chips(kind: = "") -> int:
	var total: = 0
	for id in claimable_ids(kind):
		total += (_by_id[id] as AchievementDef).coins
	return total

func def_of(id: String) -> AchievementDef:
	return _by_id.get(id)



func defs(kind: = "") -> Array:
	if kind == "":
		return _defs.duplicate()
	var out: Array = []
	for d in _defs:
		if d.kind == kind:
			out.append(d)
	return out




func active(kind: String, now: = -1) -> Array:
	return _out(kind, now).duplicate()

func is_active(d: AchievementDef) -> bool:
	return d != null and (d.kind == "global" or _out(d.kind).has(d))


func _out(kind: String, now: = -1) -> Array:
	if kind == "global":
		return defs("global")
	if test_active is Array:
		return defs(kind).filter( func(d): return (test_active as Array).has(d.id))
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	return _picks(kind, _day_number(now) if kind == "daily" else _week_number(now))



func listed(kind: String) -> Array:
	var out: = active(kind)
	if kind == "global":
		return out
	for id in claimable_ids(kind):
		var d: AchievementDef = _by_id.get(id)
		if d != null and not out.has(d):
			out.append(d)
	return out





func _picks(kind: String, index: int) -> Array:
	var key: = "%s:%d" % [kind, index]
	if _picks_of.has(key):
		return _picks_of[key]
	var pool: = defs(kind)
	var out: Array = []
	if not pool.is_empty():
		var n: = clampi(int(_catalog.shown(kind)), 0, pool.size())
		var size: = pool.size()
		var slot: = index * n
		var guard: = 0
		while out.size() < n and guard < size * 3:
			var d: AchievementDef = _round(pool, kind, floori(float(slot) / size), n)[posmod(slot, size)]
			if not out.has(d):
				out.append(d)
			slot += 1
			guard += 1
	_picks_of[key] = out
	return out



func _round(pool: Array, kind: String, r: int, n: int) -> Array:
	var order: = _shuffled(pool, kind, r)
	if order.size() > n * 2:
		var just_out: = _shuffled(pool, kind, r - 1).slice(order.size() - n)
		for i in n:
			if not just_out.has(order[i]):
				continue
			for j in range(n, order.size()):
				if not just_out.has(order[j]):
					var t: Variant = order[i]
					order[i] = order[j]
					order[j] = t
					break
	return order

func _shuffled(pool: Array, kind: String, r: int) -> Array:
	var rng: = RandomNumberGenerator.new()
	rng.seed = hash("%s/%d" % [kind, r])
	var out: = pool.duplicate()
	for i in range(out.size() - 1, 0, -1):
		var j: = rng.randi_range(0, i)
		var t: Variant = out[i]
		out[i] = out[j]
		out[j] = t
	return out


func _day_number(now: int) -> int:
	return floori(float(now + _tz_offset()) / DAY)

func _week_number(now: int) -> int:
	return floori(float(_week_start(now) + _tz_offset()) / DAY / 7.0)



func progress(def: AchievementDef) -> Dictionary:
	var p: SavedProfile = ProfileStore.active()
	if p == null:
		return {"v": 0, "done": false, "at": 0, "target": def.target, "claimed": false}
	var store: = _profile_store(p)
	_roll_periods(store)
	var row: Dictionary = _bucket(store, def.kind).get(def.id, {"v": 0, "done": false, "at": 0})
	var done: = bool(row.get("done", false))
	return {"v": int(row.get("v", 0)), "done": done, 
		"at": int(row.get("at", 0)), "target": def.target, 
		"claimed": done and _is_claimed(row, def.kind), 
		"parts": (row.get("parts", {}) as Dictionary).duplicate()}


func progress_of(p: SavedProfile, def: AchievementDef) -> Dictionary:
	if p == null or def == null:
		return {"v": 0, "done": false}
	var store: = _profile_store(p)
	_roll_periods(store, p)
	var row: Variant = _bucket(store, def.kind).get(def.id)
	if not (row is Dictionary):
		return {"v": 0, "done": false}
	return {"v": int(row.get("v", 0)), "done": bool(row.get("done", false))}


func machine_done(def: AchievementDef) -> bool:
	return _steam_done.has(def.id)

func machine_done_at(def: AchievementDef) -> int:
	return int(_steam_done.get(def.id, 0))


func period_left(kind: String) -> int:
	var now: = int(Time.get_unix_time_from_system())
	match kind:
		"daily":
			return _day_end(now) - now
		"weekly":
			return _week_end(now) - now
	return 0

func is_steam_live() -> bool:
	return Net.steam_achievements_available()



func _profile_store(p: SavedProfile) -> Dictionary:
	if not (p.achievements is Dictionary):
		p.achievements = {}
	var s: Dictionary = p.achievements
	if not s.has("global"):
		s["global"] = {}
	if not s.has("daily"):
		s["daily"] = {"key": "", "p": {}}
	if not s.has("weekly"):
		s["weekly"] = {"key": "", "p": {}}
	return s

func _bucket(store: Dictionary, kind: String) -> Dictionary:
	match kind:
		"daily":
			return store["daily"]["p"]
		"weekly":
			return store["weekly"]["p"]
	return store["global"]



func _roll_periods(store: Dictionary, owner: SavedProfile = null) -> void :
	if owner == null:
		owner = ProfileStore.active()
	var now: = int(Time.get_unix_time_from_system())
	var dk: = _day_key(now)
	var owed: = 0


	if String(store["daily"].get("key", "")) != dk:
		var old: Variant = store["daily"].get("p", {})
		store["daily"] = {"key": dk, "p": {}}
		owed += _owed(old, "daily")
		_mark_dirty()
	var wk: = _week_key(now)
	if String(store["weekly"].get("key", "")) != wk:
		var old_w: Variant = store["weekly"].get("p", {})
		store["weekly"] = {"key": wk, "p": {}}
		owed += _owed(old_w, "weekly")
		_mark_dirty()
	if owed > 0:



		Progression.add_coins(owed, owner)
		Progression.add_xp(Progression.claim_xp(owed), owner)
		if owner == ProfileStore.active():

			_ring.call_deferred()


func _owed(bucket: Variant, kind: String) -> int:
	if not (bucket is Dictionary):
		return 0
	var owed: = 0
	for id in (bucket as Dictionary).keys():
		var row: Variant = bucket[id]
		var d: AchievementDef = _by_id.get(String(id))
		if d != null and row is Dictionary and bool(row.get("done", false))\
		and not _is_claimed(row, kind):
			owed += d.coins
	return owed

func _ring() -> void :
	claimable_changed.emit(claimable_count())

func _mark_dirty(quiet: = false) -> void :

	if not _dirty:
		_save_in = SAVE_DELAY_QUIET if quiet else SAVE_DELAY
	elif not quiet:
		_save_in = minf(_save_in, SAVE_DELAY)
	_dirty = true

func _flush() -> void :
	if not _dirty:
		return
	_dirty = false
	ProfileStore.save()

func _on_profile_changed() -> void :



	var p: SavedProfile = ProfileStore.active()
	if p == null:
		return
	var key: = p.get_instance_id()
	if _opened_for.has(key):
		return
	_opened_for[key] = true
	notify("opened")



func _day_key(now: int) -> String:
	var d: = Time.get_datetime_dict_from_unix_time(now + _tz_offset())
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]

func _week_key(now: int) -> String:
	return _day_key(_week_start(now))

func _week_start(now: int) -> int:
	var local: = now + _tz_offset()
	var d: = Time.get_datetime_dict_from_unix_time(local)

	var since_monday: = (int(d.weekday) + 6) % 7
	var midnight: = local - (local % DAY)
	return midnight - since_monday * DAY - _tz_offset()

func _day_end(now: int) -> int:
	var local: = now + _tz_offset()
	var midnight: = local - (local % DAY)
	return midnight + DAY - _tz_offset()

func _week_end(now: int) -> int:
	return _week_start(now) + 7 * DAY

func _tz_offset() -> int:
	return int(Time.get_time_zone_from_system().get("bias", 0)) * 60



func _earn_machine(def: AchievementDef) -> void :
	_steam_done[def.id] = int(Time.get_unix_time_from_system())
	_save_machine()
	unlocked.emit(def, "global")
	Net.steam_set_achievement(def.steam)



func _reconcile_steam() -> void :
	if not Net.steam_achievements_available():
		return
	var changed: = false
	for def in _defs:
		var d: AchievementDef = def
		if d.kind != "global" or d.steam == "":
			continue
		var on_steam: = Net.steam_has_achievement(d.steam)
		if _steam_done.has(d.id) and not on_steam:
			Net.steam_set_achievement(d.steam)
		elif on_steam and not _steam_done.has(d.id):
			_steam_done[d.id] = int(Time.get_unix_time_from_system())
			changed = true
	if changed:
		_save_machine()

func _load_machine() -> void :
	var parsed: Variant = AppData.read_json(AppData.path(FILE))
	if not (parsed is Dictionary):
		return
	var done: Variant = parsed.get("steam", {})
	if done is Dictionary:
		for k in done:
			_steam_done[String(k)] = int(done[k])

func _save_machine() -> void :
	AppData.write_safely(AppData.path(FILE), JSON.stringify({"version": 1, "steam": _steam_done}))
