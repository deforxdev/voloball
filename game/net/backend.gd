extends Node

















const WORKER_URL: = ""




const CUSTOM_URL: = ""

const ADMIN_CFG: = "user://mod.cfg"



const TIMEOUT_S: = 10.0
const UPLOAD_TIMEOUT_S: = 90.0




var worker_url: = WORKER_URL

var _urls: PackedStringArray = []
var _good: = 0




var legacy: = false

func _ready() -> void :
	for u in [CUSTOM_URL, WORKER_URL]:
		if u != "":
			_urls.append(u)
	if OS.has_feature("editor"):
		var a: = LaunchGate.dev_args()
		var i: = a.find("--backend-url")
		if i != -1 and i + 1 < a.size():
			worker_url = String(a[i + 1])
			_urls = PackedStringArray([worker_url])
		legacy = a.has("--backend-legacy")
	if not _urls.is_empty():
		worker_url = _urls[0]

func configured() -> bool:
	return not _urls.is_empty()






func build_kind() -> String:
	if legacy:
		return ""
	return "demo" if LaunchGate.is_demo() else "full"


func base_url() -> String:
	return _urls[_good % _urls.size()] if not _urls.is_empty() else ""


func _admin_token() -> String:
	var cfg: = ConfigFile.new()
	if cfg.load(ADMIN_CFG) != OK:
		return ""
	return String(cfg.get_value("api", "token", ""))



func api_call(action: String, params: Dictionary, callback: Callable, admin: = false) -> void :
	if not configured():
		if callback.is_valid():
			callback.call(0, null)
		return
	var payload: = params.duplicate()
	payload["action"] = action
	var kind: = build_kind()
	if kind != "":
		payload["build"] = kind
	var headers: = PackedStringArray(["Content-Type: application/json"])
	if admin:
		var tok: = _admin_token()
		if tok != "":
			headers.append("X-Admin-Token: %s" % tok)
	var timeout: = UPLOAD_TIMEOUT_S if action.ends_with("-put") else TIMEOUT_S
	_post(base_url(), JSON.stringify(payload), headers, timeout, _good, 0, 
		func(code: int, body: PackedByteArray):
			var json: Variant = null
			if body.size() > 0:
				var raw: String = body.get_string_from_utf8()
				if code != 200:
					push_warning("[backend] %s -> %d: %s" % [action, code, raw])
				json = JSON.parse_string(raw)
			if callback.is_valid():
				callback.call(code, json))





func _post(url: String, body: String, headers: PackedStringArray, timeout: float, 
		idx: int, tries: int, done: Callable, path: = "") -> void :
	var http: = HTTPRequest.new()
	http.timeout = timeout
	add_child(http)
	var next: = func():
		if tries + 1 < _urls.size():
			var n: = (idx + 1) % _urls.size()
			_post(_urls[n] + path, body, headers, timeout, n, tries + 1, done, path)
		else:
			done.call(0, PackedByteArray())
	http.request_completed.connect( func(result, code, _h, resp):
		http.queue_free()
		if result != HTTPRequest.RESULT_SUCCESS or code == 0:
			push_warning("[backend] no answer from %s (result %d)" % [url, result])
			next.call()
			return
		_good = idx
		done.call(code, resp))
	if http.request(url, headers, HTTPClient.METHOD_POST, body) != OK:
		http.queue_free()
		next.call()



func check_bans(steam_id: int, callback: Callable) -> void :
	api_call("check-bans", {"steam_id": str(steam_id)}, callback)

func get_role(steam_id: int, callback: Callable) -> void :
	api_call("get-role", {"steam_id": str(steam_id)}, callback)



func ban(target_steam_id: int, ban_type: String, duration_seconds: int, 
		reason: String, callback: Callable) -> void :

	api_call("ban", {
		"target_steam_id": str(target_steam_id), 
		"ban_type": ban_type, 
		"duration_seconds": duration_seconds, 
		"reason": reason, 
		"banned_by": "panel", 
	}, callback, true)

func unban(target_steam_id: int, ban_type: String, callback: Callable) -> void :
	api_call("unban", {
		"target_steam_id": str(target_steam_id), 
		"ban_type": ban_type, 
	}, callback, true)




func get_evidence(key: String, callback: Callable) -> void :
	if not configured():
		callback.call(0, PackedByteArray())
		return
	var tok: = _admin_token()
	if tok == "":
		callback.call(401, PackedByteArray())
		return
	var headers: = PackedStringArray(["Content-Type: application/json", 
		"X-Admin-Token: %s" % tok])
	_post(base_url() + "admin/get-evidence", JSON.stringify({"key": key}), headers, 
		UPLOAD_TIMEOUT_S, _good, 0, callback, "admin/get-evidence")





func evidence_put(report_id: String, kind: String, data_base64: String, 
		uploader_sid: int, callback: Callable) -> void :


	api_call("evidence-put", {
		"report_id": report_id, 
		"kind": kind, 
		"data_base64": data_base64, 
		"uploader_sid": str(uploader_sid), 
	}, callback)




func submit_report(fields: Dictionary, callback: Callable) -> void :
	api_call("submit-report", fields, callback)



func report_status(callback: Callable) -> void :
	api_call("report-status", {}, callback)







func ack(steam_id: int, notification_ids: Array, warning_id: String, 
		callback: = Callable()) -> void :
	api_call("ack", {
		"sid": str(steam_id), 
		"notification_ids": notification_ids, 
		"warning_id": warning_id, 
	}, callback if callback.is_valid() else func(_c, _j): pass)






func level_seen(steam_id: int, name: String, levels: Array, callback: Callable) -> void :
	api_call("level-seen", {
		"steam_id": str(steam_id), 
		"name": name, 
		"levels": levels, 
		"app_version": GameConfig.VERSION, 
		"platform": OS.get_name(), 
	}, callback)



func file_appeal(steam_id: int, ban_type: String, message: String, 
		callback: Callable) -> void :
	api_call("appeal", {
		"sid": str(steam_id), 
		"ban_type": ban_type, 
		"message": message, 
	}, callback)
