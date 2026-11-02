extends Node










var _ban_cache: = {}
const CACHE_TTL_MS: = 60000




var _lobby_bans: = {}



var _chat_banned: = {}
var _self_chat_reason: = ""
var _self_chat_expires: = 0

signal self_chat_ban_changed()

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	_self_chat_expires = -1





const DEMO_ENDED_TEXT: = "online play for the demo has ended, thanks so much for playing! you can still play offline."



func _normalize(code: int, json: Variant, sid: int) -> Dictionary:
	if code != 200 or not (json is Dictionary):
		return {"ok": false, "online": false, "chat": false}
	var d: Dictionary = json
	var res: = {
		"ok": true, 
		"online": bool(d.get("online_banned", false)), 
		"online_reason": _s(d.get("online_reason")), 
		"online_expires": _to_unix(d.get("online_expires")), 
		"chat": bool(d.get("chat_banned", false)), 
		"chat_reason": _s(d.get("chat_reason")), 
		"chat_expires": _to_unix(d.get("chat_expires")), 


		"warning": (d.get("warning") if d.get("warning") is Dictionary else null), 
		"notifications": (d.get("notifications") if d.get("notifications") is Array else []), 



		"demo_ended": bool(d.get("demo_ended", false)) and not Backend.legacy, 
		"ts": Time.get_ticks_msec(), 
	}



	if res.demo_ended:
		res.online_reason = DEMO_ENDED_TEXT
	_ban_cache[sid] = res
	return res



func _to_unix(v) -> int:
	if v == null:
		return 0
	if v is int or v is float:
		return int(v)
	if v is String:
		if v == "":
			return 0
		return int(Time.get_unix_time_from_datetime_string(v))
	return 0

func _s(v) -> String:
	return String(v) if v != null else ""

func check_bans(sid: int, cb: Callable) -> void :
	if sid == 0 or not Backend.configured():
		cb.call({"ok": false, "online": false, "chat": false})
		return
	Backend.check_bans(sid, func(code, json): cb.call(_normalize(code, json, sid)))



func is_blocked(sid: int) -> bool:
	if sid == 0:
		return false
	if _lobby_bans.has(sid):
		return true
	if Net.lan_session():
		return false
	var c: Dictionary = _ban_cache.get(sid, {})
	return bool(c.get("online", false))

func block_reason(sid: int) -> String:
	if _lobby_bans.has(sid):
		return String(_lobby_bans[sid])
	var c: Dictionary = _ban_cache.get(sid, {})
	if bool(c.get("demo_ended", false)):
		return DEMO_ENDED_TEXT
	return online_ban_message(String(c.get("online_reason", "")), 
		int(c.get("online_expires", 0)))



func online_ban_message(reason: String, expires_unix: int) -> String:
	var m: = "you are banned from online play"
	if reason != "":
		m += ", " + reason
	return m + expiry_suffix(expires_unix)





func lobby_ban(sid: int, reason: = "you are banned from this lobby") -> void :
	if sid != 0:
		_lobby_bans[sid] = reason

func lobby_unban(sid: int) -> void :
	_lobby_bans.erase(sid)

func clear_lobby_bans() -> void :
	_lobby_bans.clear()

func lobby_bans_export() -> Array:
	return _lobby_bans.keys()

func lobby_bans_import(sids: Array) -> void :
	for s in sids:
		_lobby_bans[int(s)] = "you are banned from this lobby"



func lobby_bans_sync(sids: Array) -> void :
	_lobby_bans.clear()
	lobby_bans_import(sids)









func enforce_peer(peer_id: int, sid: int) -> void :
	if sid == 0 or not Backend.configured() or Net.lan_session():
		return



	check_bans(sid, func(res):
		if not Net.is_host or not Net.players.has(peer_id):
			return
		var pname: = String((Net.players.get(peer_id, {}) as Dictionary).get("name", "player"))
		if bool(res.get("online", false)):
			Net.system_message("online play for the demo has ended" if bool(res.get("demo_ended", false))
				else "%s has been banned from online play" % pname)
			Net.refuse_peer(peer_id, DEMO_ENDED_TEXT if bool(res.get("demo_ended", false))
				else online_ban_message(String(res.get("online_reason", "")), 
					int(res.get("online_expires", 0))))
			return
		if bool(res.get("chat", false)):
			var reason: = String(res.get("chat_reason", ""))
			var expires: = int(res.get("chat_expires", 0))
			var was: = _chat_banned.has(sid)
			_chat_banned[sid] = {"reason": reason, "expires": expires}
			if not was:
				Net.system_message("%s has been chat banned" % pname)
			if Net.multiplayer.get_peers().has(peer_id):
				Net._s_chat_banned.rpc_id(peer_id, reason, expires))



func poll_all() -> void :
	if not Net.is_host or not Net.active:
		return
	for pid in Net.players.keys():
		if int(pid) == 1:
			continue
		var sid: = int((Net.players[pid] as Dictionary).get("sid", 0))
		if sid != 0:
			enforce_peer(int(pid), sid)


func is_chat_banned(sid: int) -> bool:
	if sid == 0 or not _chat_banned.has(sid):
		return false
	var b: Dictionary = _chat_banned[sid]
	var exp: = int(b.get("expires", 0))
	if exp > 0 and Time.get_unix_time_from_system() >= exp:
		_chat_banned.erase(sid)
		return false
	return true





















const BLOCKING: = false
var _muted: = {}
var _blocked: = {}
var _blocked_loaded: = false
var _stand_ins: = {}



signal presence_changed(pid: int)

func mute_peer(pid: int) -> void :
	if pid != 0 and not _muted.has(pid):
		_muted[pid] = true
		presence_changed.emit(pid)

func unmute_peer(pid: int) -> void :
	if _muted.erase(pid):
		presence_changed.emit(pid)

func is_muted(pid: int) -> bool:
	return _muted.has(pid)


func toggle_mute(pid: int) -> bool:
	if is_muted(pid):
		unmute_peer(pid)
		return false
	mute_peer(pid)
	return true



func hides(pid: int) -> bool:
	return pid != 0 and (is_muted(pid) or is_blocked_sid(peer_sid(pid)))

static func peer_sid(pid: int) -> int:
	return int((Net.players.get(pid, {}) as Dictionary).get("sid", 0))

func is_blocked_sid(sid: int) -> bool:
	if sid == 0 or not BLOCKING:
		return false
	_load_blocked()
	return _blocked.has(sid) or steam_blocked(sid)


func steam_blocked(sid: int) -> bool:
	var s: Variant = Net.get("_steam")
	if sid == 0 or s == null or not (s as Object).has_method("getFriendRelationship"):
		return false

	var rel: = int((s as Object).call("getFriendRelationship", sid))
	return rel == 5 or rel == 6



func blocked_here(sid: int) -> bool:
	_load_blocked()
	return _blocked.has(sid)

func block_sid(sid: int) -> void :
	if sid == 0:
		return
	_load_blocked()
	_blocked[sid] = true
	_save_blocked()
	_bh_at = -100000
	presence_changed.emit(0)

func unblock_sid(sid: int) -> void :
	_load_blocked()
	if _blocked.erase(sid):
		_save_blocked()
		_bh_at = -100000
		presence_changed.emit(0)

func blocked_count() -> int:
	_load_blocked()
	return _blocked.size()




static func sid_hash(sid: int) -> String:
	return str(sid).sha256_text().substr(0, 8)



var _bh_cache: = {}
var _bh_at: = -100000
func blocked_hashes() -> Dictionary:
	if not BLOCKING:
		return {}
	if Time.get_ticks_msec() - _bh_at < 5000:
		return _bh_cache
	_bh_at = Time.get_ticks_msec()
	_load_blocked()
	var out: = {}
	for sid in _blocked:
		out[sid_hash(int(sid))] = true
	var s: Variant = Net.get("_steam")
	if s != null and (s as Object).has_method("getFriendCount")\
	and (s as Object).has_method("getFriendByIndex"):

		var flags: = 512 | 1024
		for i in int((s as Object).call("getFriendCount", flags)):
			var fsid: = int((s as Object).call("getFriendByIndex", i, flags))
			if fsid != 0:
				out[sid_hash(fsid)] = true
	_bh_cache = out
	return out


func lists_blocked(bh: String) -> bool:
	if bh == "":
		return false
	var mine: = blocked_hashes()
	if mine.is_empty():
		return false
	for h in bh.split(",", false):
		if mine.has(h):
			return true
	return false

func _load_blocked() -> void :
	if _blocked_loaded:
		return
	_blocked_loaded = true


	if OS.has_feature("editor"):
		var a: = LaunchGate.dev_args()
		for i in a.size() - 1:
			if a[i] == "--block-sid" and String(a[i + 1]).is_valid_int():
				_blocked[int(a[i + 1])] = true
	var f: = FileAccess.open(AppData.path("blocked.json"), FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary and (d as Dictionary).get("sids") is Array:
		for s in (d as Dictionary)["sids"]:
			if str(s).is_valid_int() and int(str(s)) != 0:
				_blocked[int(str(s))] = true

func _save_blocked() -> void :

	var f: = FileAccess.open(AppData.path("blocked.json"), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"sids": _blocked.keys().map( func(s): return str(s))}))


func shown_cfg(pid: int, cfg: Variant) -> Dictionary:
	var d: Dictionary = cfg if cfg is Dictionary else {}
	if d.is_empty() or not hides(pid):
		return d
	return stand_in(pid)


func shown_look(pid: int, look: CharacterConfig) -> CharacterConfig:
	if look == null or not hides(pid):
		return look
	return CharacterConfig.from_dict(stand_in(pid))




func stand_in(pid: int) -> Dictionary:
	var sid: = peer_sid(pid)
	var seed: = sid if sid != 0 else pid
	if not _stand_ins.has(seed):
		var rng: = RandomNumberGenerator.new()
		rng.seed = hash("stand-in:%d" % seed)
		_stand_ins[seed] = CharacterConfig.random(rng).to_dict()
	return _stand_ins[seed]
















func check_self(cb: Callable, retry: = true) -> void :
	var sid: = Net.my_steam_id()
	if sid == 0 or not Backend.configured():
		cb.call(true, "", 0, false)
		return




	Backend.check_bans(sid, func(code, json):
		if code != 200 or not (json is Dictionary):
			var tree: = Engine.get_main_loop() as SceneTree
			if retry and tree != null:
				tree.create_timer(1.5).timeout.connect( func(): check_self(cb, false))
				return
			push_warning("[mod] ban check got no answer (%d), using the last ban we saw" % code)
			var seen: = _seen_self_ban(sid)
			if not seen.is_empty():
				cb.call(false, String(seen.get("reason", "")), int(seen.get("expires", 0)), 
					not bool(seen.get("demo_ended", false)))
			else:
				cb.call(true, "", 0, false)
			return
		var res: = _normalize(code, json, sid)
		_remember_self_ban(sid, res)
		_arm_self_chat(res)
		_capture_warning(res)
		_handle_feedback(res)
		report_levels()
		if bool(res.get("online", false)):

			cb.call(false, String(res.get("online_reason", "")), 
				int(res.get("online_expires", 0)), not bool(res.get("demo_ended", false)))
		else:
			cb.call(true, "", 0, false))



const SEEN_BAN_CFG: = "user://ban_seen.cfg"






func _seen_key(sid: int) -> String:
	var kind: = Backend.build_kind()
	return str(sid) if kind == "" else "%s:%d" % [kind, sid]

func _remember_self_ban(sid: int, res: Dictionary) -> void :
	var cfg: = ConfigFile.new()
	cfg.load(SEEN_BAN_CFG)
	var key: = _seen_key(sid)
	if bool(res.get("online", false)):
		cfg.set_value(key, "reason", String(res.get("online_reason", "")))
		cfg.set_value(key, "expires", int(res.get("online_expires", 0)))
		if bool(res.get("demo_ended", false)):
			cfg.set_value(key, "demo_ended", true)
	elif cfg.has_section(key):
		cfg.erase_section(key)
	else:
		return
	cfg.save(SEEN_BAN_CFG)


func _seen_self_ban(sid: int) -> Dictionary:
	var cfg: = ConfigFile.new()
	var key: = _seen_key(sid)
	if cfg.load(SEEN_BAN_CFG) != OK or not cfg.has_section(key):
		return {}
	var exp: = int(cfg.get_value(key, "expires", 0))
	if exp > 0 and Time.get_unix_time_from_system() >= exp:
		return {}
	return {"reason": String(cfg.get_value(key, "reason", "")), "expires": exp, 
		"demo_ended": bool(cfg.get_value(key, "demo_ended", false))}






func _arm_self_chat(res: Dictionary) -> void :
	var sid: = Net.my_steam_id()
	if bool(res.get("chat", false)):
		var reason: = String(res.get("chat_reason", ""))
		var exp: = int(res.get("chat_expires", 0))
		set_self_chat_ban(reason, exp)
		if sid != 0:
			_chat_banned[sid] = {"reason": reason, "expires": exp}
	else:
		if self_chat_banned():
			set_self_chat_ban("", -1)
		if sid != 0:
			_chat_banned.erase(sid)








var _pending_warning: = {}
signal warning_changed()

func _capture_warning(res: Dictionary) -> void :
	var w = res.get("warning")
	if w is Dictionary and String((w as Dictionary).get("reason", "")) != "":
		_pending_warning = {"reason": String(w.get("reason", "")), 
			"id": String(w.get("id", ""))}
	else:
		_pending_warning = {}
	warning_changed.emit()

func pending_warning() -> Dictionary:
	return _pending_warning.duplicate()

func has_pending_warning() -> bool:
	return not _pending_warning.is_empty()


func ack_warning() -> void :
	var id: = String(_pending_warning.get("id", ""))
	_pending_warning = {}
	warning_changed.emit()
	var sid: = Net.my_steam_id()
	if sid != 0 and Backend.configured() and id != "":
		Backend.ack(sid, [], id)


var _seen_feedback: = {}
func _handle_feedback(res: Dictionary) -> void :
	var notes = res.get("notifications")
	if not (notes is Array) or (notes as Array).is_empty():
		return
	var ack_ids: Array = []
	var action_count: = 0
	var others: Array = []
	for n in notes:
		if not (n is Dictionary):
			continue
		var id: = String((n as Dictionary).get("id", ""))
		if id == "" or _seen_feedback.has(id):
			continue
		_seen_feedback[id] = true
		ack_ids.append(id)
		var action: = String((n as Dictionary).get("action", ""))
		var detail: = String((n as Dictionary).get("detail", ""))
		if action == "online" or action == "chat" or action == "warned":
			action_count += 1
		elif feedback_line(action, detail, res) == "":
			pass
		else:
			others.append({"action": action, "detail": detail})
	if ack_ids.is_empty():
		return

	if action_count == 1:
		UiStyle.flash_pill("an action was taken on a player you reported", 
			UiStyle.SUCCESS, "information", 5.0)
	elif action_count > 1:
		UiStyle.flash_pill("%d actions were taken on players you reported" % action_count, 
			UiStyle.SUCCESS, "information", 5.0)

	for o in others:
		_show_feedback_pill(String(o["action"]), String(o["detail"]))
	var sid: = Net.my_steam_id()
	if sid != 0 and Backend.configured():
		Backend.ack(sid, ack_ids, "")



func _show_feedback_pill(action: String, detail: = "") -> void :
	var line: = feedback_line(action, detail)
	if line == "":
		return
	var good: = line == APPEAL_APPROVED
	UiStyle.flash_pill(line, UiStyle.SUCCESS if good else UiStyle.SECONDARY, "information", 5.0)

const APPEAL_APPROVED: = "your ban appeal has been approved"
const APPEAL_DENIED: = "your ban appeal has been denied"





func feedback_line(action: String, detail: String, res: = {}) -> String:
	if action == "appeal_result" or action.begins_with("appeal"):
		if detail == "overturn" or action.contains("overturn"):
			return APPEAL_APPROVED
		if not res.is_empty() and not bool(res.get("online", false))\
		and not bool(res.get("chat", false)):
			return ""
		return APPEAL_DENIED
	if action == "reviewed":
		return "thanks for reporting, we looked into it"
	return ""




func poll_self() -> void :
	if not Net.active or Net.lan_session():
		return
	var sid: = Net.my_steam_id()
	if sid == 0 or not Backend.configured():
		return
	Backend.check_bans(sid, func(code, json):
		if code == 200 and json is Dictionary:
			var res: = _normalize(code, json, sid)
			_remember_self_ban(sid, res)
			_arm_self_chat(res)
			_capture_warning(res)
			_handle_feedback(res)

			if bool(res.get("online", false)):
				_self_banned_mid_session(res))










var _levels_sent: = {}
var report_levels_in_dev: = false

func report_levels() -> void :
	var sid: = Net.my_steam_id()
	if sid == 0 or not Backend.configured():
		return
	if (OS.has_feature("editor") or AppData.is_harness()) and not report_levels_in_dev:
		return
	var out: Array = []
	for row in level_rows():
		if int(_levels_sent.get(row["uid"], -1)) != int(row["lvl"]):
			out.append(row)
	if out.is_empty():
		return



	for row in out:
		_levels_sent[row["uid"]] = row["lvl"]
	Backend.level_seen(sid, Net.steam_persona(), out, func(_code, _json): pass)





func level_rows() -> Array:
	var rows: Array = []
	var seen: = {}
	var profiles: Array = [ProfileStore.active()]
	for s in LocalPlayers.slots:
		if s != null and s.index > 0 and not s.is_temp:
			profiles.append(s.profile)
	for p in profiles:
		if p == null or (p as SavedProfile).uid == "" or seen.has(p.uid):
			continue
		seen[p.uid] = true

		var lv: = Progression.verified_level(p)
		if lv > 0:
			rows.append({"uid": p.uid, "lvl": lv})
	return rows.slice(0, LocalPlayers.MAX_LOCAL)





func on_refused() -> void :
	var sid: = Net.my_steam_id()
	if sid == 0 or not Backend.configured() or Net.lan_session():
		return
	Backend.check_bans(sid, func(code, json):
		if code != 200 or not (json is Dictionary):
			return
		var res: = _normalize(code, json, sid)
		if bool(res.get("online", false)):
			OnlineTerms._ban_ok_ms = -1000000
			OnlineTerms._show_ban_notice(String(res.get("online_reason", "")), 
				int(res.get("online_expires", 0)), not bool(res.get("demo_ended", false))))





func _self_banned_mid_session(res: Dictionary) -> void :
	if not Net.active or not bool(res.get("online", false)):
		return
	var reason: = String(res.get("online_reason", ""))
	var expires: = int(res.get("online_expires", 0))
	var demo_ended: = bool(res.get("demo_ended", false))
	OnlineTerms._ban_ok_ms = -1000000
	if Net.is_host:
		Net.system_message("online play for the demo has ended" if demo_ended
			else "%s has been banned from online play" % Net.my_name)
		Net.multiplayer.poll()
		var tree: = Engine.get_main_loop() as SceneTree
		if tree != null:
			tree.create_timer(0.25).timeout.connect( func():
				if Net.active and Net.is_host:
					Net.leave())
		else:
			Net.leave()
	else:
		Net.leave()
	OnlineTerms._show_ban_notice.call_deferred(reason, expires, not demo_ended)


func set_self_chat_ban(reason: String, expires_unix: int) -> void :
	_self_chat_reason = reason
	_self_chat_expires = expires_unix
	self_chat_ban_changed.emit()

func self_chat_banned() -> bool:
	if _self_chat_expires == -1:
		return false
	if _self_chat_expires > 0 and Time.get_unix_time_from_system() >= _self_chat_expires:
		_self_chat_expires = -1
		return false
	return true

func self_chat_ban_label() -> String:
	if not self_chat_banned():
		return ""
	return "you are chat banned" + expiry_suffix(_self_chat_expires)


func session_reset() -> void :
	_chat_banned.clear()
	_lobby_bans.clear()
	if not _muted.is_empty():
		_muted.clear()
		presence_changed.emit(0)
	_self_chat_expires = -1
	_self_chat_reason = ""
	_seen_feedback.clear()
	self_chat_ban_changed.emit()






func expiry_suffix(expires_unix: int) -> String:
	if expires_unix <= 0:
		return " (permanent)"
	var secs: = expires_unix - int(Time.get_unix_time_from_system())
	if secs <= 0:
		return ""
	var d: = secs / 86400
	var h: = (secs % 86400) / 3600
	var m: = (secs % 3600) / 60
	if d > 0:
		return " (%dd %dh left)" % [d, h]
	if h > 0:
		return " (%dh %dm left)" % [h, m]
	return " (%dm left)" % [maxi(m, 1)]
