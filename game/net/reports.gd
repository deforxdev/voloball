class_name Reports
extends RefCounted








const CATEGORIES: = [
	["harassment", "harassment / toxic"], 
	["inappropriate", "inappropriate content"], 
	["spam", "spam / chat flooding"], 
	["griefing", "griefing"], 
	["cheating", "cheating / exploits"], 
	["other", "other"], 
]


const BLOB_MAX: = 5500000

const CHAT_MAX: = 6000



const DOWN_MSG: = "the report system is down for maintenance right now, please try again later!"
const FAILED_MSG: = "your report couldn't be sent right now, please try again later!"

static func is_down_reply(code: int, json: Variant) -> bool:
	return code == 503 and json is Dictionary\
	and String((json as Dictionary).get("error", "")) == "reports_disabled"



static func _went_down(reported_sid: int) -> void :
	_sent.erase(reported_sid)
	UiStyle.flash_pill(DOWN_MSG, UiStyle.SECONDARY, "information", 5.0)


static var _sent: = {}



static var match_replay = null








static var last_match: = {}

static func keep_last_match(replay, sids: Array, token: String, started_ms: int) -> void :
	if replay == null or replay.frame_count() < 30:
		return
	var who: = {}
	for s in sids:
		if int(s) != 0:
			who[int(s)] = true
	last_match = {"replay": replay, "sids": who, "token": token, 
		"started_ms": started_ms, "ended": int(Time.get_unix_time_from_system())}


static func _last_match_with(sid: int) -> Dictionary:
	if last_match.is_empty() or not (last_match.sids as Dictionary).has(sid):
		return {}
	return last_match




static var match_shot: Image = null





const SYNTH_BASE: = 76561190000000000

static func local_sid() -> int:
	var s: = Net.my_steam_id()
	return s if s != 0 else SYNTH_BASE + Net.multiplayer.get_unique_id()

static func peer_sid(pid: int) -> int:
	var s: = int((Net.players.get(pid, {}) as Dictionary).get("sid", 0))



	if s == 0 or s == Net.my_steam_id():
		return SYNTH_BASE + pid
	return s

static func can_report(reported_sid: int) -> bool:
	return Backend.configured() and reported_sid != 0\
	and reported_sid != local_sid() and not _sent.has(reported_sid)

static func label_for(category: String) -> String:
	for c in CATEGORIES:
		if c[0] == category:
			return c[1]
	return category






static func file(reported_sid: int, reported_name: String, category: String, 
		description: String, replay = null, stage_override: = "", 
		mode_override: = "", match_record: = {}) -> void :
	var my_sid: = local_sid()
	if reported_sid == 0 or my_sid == reported_sid or not Backend.configured():
		return
	var career: = not match_record.is_empty()
	if replay == null and not career:
		replay = match_replay

	var after: = {} if career or replay != null else _last_match_with(reported_sid)
	if not after.is_empty():
		replay = after.replay
	_sent[reported_sid] = true
	var report_id: = _uuid()
	var fields: = {
		"report_id": report_id, 
		"reporter_sid": str(my_sid), 
		"reported_sid": str(reported_sid), 
		"reporter_name": Net.local_display_name(), 
		"reported_name": reported_name, 
		"category": category, 
		"description": description, 
		"stage": stage_override if stage_override != "" else Net.stage, 
		"mode": mode_override if mode_override != "" else "%dv%d" % [Net.team_size, Net.team_size], 
		"match_id": "", 
		"chat_log": (String(match_record.get("chat", "")) if career else Net.recent_chat_log(300.0)), 
		"source": ("career" if career else "live"), 



		"incident_t": (replay.duration() if replay != null and replay.has_method("duration") else 0.0), 


		"app_version": GameConfig.VERSION, 
		"platform": OS.get_name(), 
		"lobby_id": str(Net.steam_lobby_id), 
		"net_role": ("host" if Net.is_host else "client"), 
		"reported_cfg": _reported_cfg(reported_sid), 
	}
	if career:
		fields["lobby_id"] = String(match_record.get("lobby_id", ""))
		fields["net_role"] = String(match_record.get("net_role", ""))
		fields["reported_cfg"] = _record_cfg(match_record, reported_sid)
		fields["match_ts"] = int(match_record.get("ts", 0))
	elif not after.is_empty():


		fields["source"] = "lobby"
		fields["match_ts"] = int(after.ended)
		fields["incident_t"] = 0.0
		var secs: = float(Time.get_ticks_msec() - int(after.started_ms)) / 1000.0
		var chat: = Net.recent_chat_log(maxf(secs, 0.0) + 120.0)
		fields["chat_log"] = chat.right(CHAT_MAX) if chat.length() > CHAT_MAX else chat



	var parts: Array = []
	for pid in ([] if career else Net.players.keys()):
		var pp: Dictionary = Net.players[pid]
		var psid: = peer_sid(int(pid))
		var pcfg: Variant = pp.get("cfg", {})
		var side: = int(pp.get("side", 0))
		if psid == my_sid:
			fields["reporter_side"] = side
		if psid == reported_sid:
			fields["reported_side"] = side
		parts.append({
			"name": String(pp.get("name", "player")), 
			"sid": str(psid), 
			"side": side, 
			"winrate": float(pp.get("wr", 0.0)), 
			"badge": DevBadge.tier_of(int(pp.get("sid", 0))), 
			"cfg": pcfg if pcfg is Dictionary else {}, 
		})
	if career:
		parts = _record_participants(match_record, my_sid, reported_sid, fields)
	fields["participants"] = parts
	var uploads: Array = []

	var shot: = "" if career else _shot_b64()
	if shot != "":
		uploads.append(["shot", shot, "shots/%s.png" % report_id])
	var rep: = _file_b64(String(match_record.get("replay", ""))) if career else _replay_b64(replay)


	if career and rep == "" and not last_match.is_empty()\
	and String(match_record.get("match_token", "")) != ""\
	and String(match_record.get("match_token", "")) == String(last_match.token):
		rep = _replay_b64(last_match.replay)
	if rep != "":
		uploads.append(["replay", rep, "replays/%s.rply" % report_id])






	await _append_outfits(fields["reported_cfg"] if fields["reported_cfg"] is Dictionary else {}, 
		"outfit", report_id, uploads)
	await _append_outfits(Net.local_character_dict(), "reporter_outfit", report_id, uploads)
	_upload_then_submit(report_id, my_sid, uploads, 0, fields)


static func _record_row(rec: Dictionary, sid: int) -> Dictionary:
	for p in (rec.get("players", []) as Array):
		if p is Dictionary and int(str((p as Dictionary).get("sid", "0"))) == sid:
			return p
	return {}

static func _record_cfg(rec: Dictionary, sid: int) -> Dictionary:
	var c: Variant = _record_row(rec, sid).get("cfg", {})
	return c if c is Dictionary else {}



static func _record_participants(rec: Dictionary, my_sid: int, reported_sid: int, 
		fields: Dictionary) -> Array:
	var parts: Array = []
	var my_name: = String(rec.get("my_name", ""))
	for p in (rec.get("players", []) as Array):
		if not (p is Dictionary):
			continue
		var row: Dictionary = p
		var psid: = int(str(row.get("sid", "0")))
		var side: = int(row.get("side", 0))
		var is_me: = String(row.get("name", "")) == my_name
		if is_me:
			fields["reporter_side"] = side
		if psid == reported_sid:
			fields["reported_side"] = side
		if psid == 0 and not is_me:
			continue
		var pcfg: Variant = row.get("cfg", {})
		parts.append({
			"name": String(row.get("name", "player")), 
			"sid": str(my_sid if is_me else psid), 
			"side": side, 
			"winrate": 0.0, 
			"badge": DevBadge.tier_of(psid), 
			"cfg": pcfg if pcfg is Dictionary else {}, 
		})
	return parts










const OUTFIT_UPLOADS: = [["home", "captain"], ["away", "alternate"], ["gym", "gym"], 
	["pinny", "pinny"]]
static func _append_outfits(cfg_dict: Dictionary, prefix: String, report_id: String, 
		uploads: Array) -> void :
	if cfg_dict.is_empty():
		return



	if DisplayServer.get_name() == "headless":
		return
	var cc: = CharacterConfig.from_dict(cfg_dict)
	var captain: = TeamKits.normalize(cc.captain_kit)
	var gym: = cc.gym_look()
	var pinny: = cc.gym_look()
	pinny.wear_pinny = true
	pinny.pinny_color = captain[0]
	pinny.pinny_accent = TeamKits.number_ink(captain[0])
	var variants: = [[OUTFIT_UPLOADS[0][0], cc, captain], 
		[OUTFIT_UPLOADS[1][0], cc, TeamKits.alternate(cc.captain_kit, cc.captain_kit)], 
		[OUTFIT_UPLOADS[2][0], gym, gym.gym_kit()], 
		[OUTFIT_UPLOADS[3][0], pinny, pinny.gym_kit()]]
	for variant in variants:
		var tex = await CharacterPortrait.render(variant[1], "full", Vector2i(480, 620), 
			null, variant[2])
		var b64: = _img_b64(tex)
		if b64 != "":
			var kind: = "%s_%s" % [prefix, String(variant[0])]
			uploads.append([kind, b64, "outfits/%s_%s.png" % [report_id, kind]])


static func _reported_cfg(reported_sid: int) -> Dictionary:
	for pid in Net.players:
		if peer_sid(int(pid)) == reported_sid:
			var c: Variant = (Net.players[pid] as Dictionary).get("cfg", {})
			return c if c is Dictionary else {}
	return {}


static func _img_b64(tex) -> String:
	if tex == null:
		return ""
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		return ""
	if img.get_width() > 640:
		img.resize(640, int(640.0 * img.get_height() / maxi(img.get_width(), 1)), 
			Image.INTERPOLATE_BILINEAR)
	var png: = img.save_png_to_buffer()
	if png.is_empty() or png.size() > BLOB_MAX:
		return ""
	return Marshalls.raw_to_base64(png)



static func _upload_then_submit(report_id: String, my_sid: int, uploads: Array, 
		i: int, fields: Dictionary) -> void :
	var target: = int(str(fields.get("reported_sid", "0")))
	if i >= uploads.size():
		Backend.submit_report(fields, func(code, json):
			if is_down_reply(int(code), json):
				_went_down(target)
			elif int(code) != 200:


				_sent.erase(target)
				UiStyle.flash_pill(FAILED_MSG, UiStyle.SECONDARY, "information", 5.0))
		return
	var u: Array = uploads[i]
	Backend.evidence_put(report_id, String(u[0]), String(u[1]), my_sid, func(code, json):
		if is_down_reply(int(code), json):
			_went_down(target)
			return
		if json is Dictionary and bool((json as Dictionary).get("stored", false)):
			fields[String(u[0]) + "_r2"] = String(u[2])
		_upload_then_submit(report_id, my_sid, uploads, i + 1, fields))

static func _shot_b64() -> String:


	var img: Image = match_shot
	if img == null:
		var tree: = Engine.get_main_loop() as SceneTree
		if tree != null and tree.root != null:
			var vp: = tree.root.get_viewport()
			if vp != null:
				var tex: = vp.get_texture()
				if tex != null:
					img = tex.get_image()
	if img == null or img.is_empty():
		return ""
	img = img.duplicate()
	if img.get_width() > 1280:
		img.resize(1280, int(1280.0 * img.get_height() / maxi(img.get_width(), 1)), 
			Image.INTERPOLATE_BILINEAR)
	var png: = img.save_png_to_buffer()
	if png.is_empty() or png.size() > BLOB_MAX:
		return ""
	return Marshalls.raw_to_base64(png)


static func _file_b64(path: String) -> String:
	if path == "" or not FileAccess.file_exists(path):
		return ""
	var bytes: = FileAccess.get_file_as_bytes(path)
	if bytes.is_empty() or bytes.size() > BLOB_MAX:
		return ""
	return Marshalls.raw_to_base64(bytes)

static func _replay_b64(replay) -> String:
	if replay == null:
		return ""
	var path: = "user://report_replay_tmp.rply"
	if not replay.save_to(path):
		return ""
	var f: = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var bytes: = f.get_buffer(f.get_length())
	f.close()
	DirAccess.remove_absolute(path)
	if bytes.is_empty() or bytes.size() > BLOB_MAX:
		return ""
	return Marshalls.raw_to_base64(bytes)


static func _uuid() -> String:
	var b: = PackedByteArray()
	b.resize(16)
	for i in 16:
		b[i] = randi() % 256
	b[6] = (b[6] & 15) | 64
	b[8] = (b[8] & 63) | 128
	var h: = b.hex_encode()
	return "%s-%s-%s-%s-%s" % [h.substr(0, 8), h.substr(8, 4), h.substr(12, 4), 
		h.substr(16, 4), h.substr(20, 12)]
