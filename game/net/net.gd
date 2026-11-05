extends Node








signal lobby_changed
signal steam_lobbies(rows: Array)
signal session_ended(reason: String)
signal match_started(roster: Array)
signal input_received(peer_id: int, ls: int, data: Dictionary)
signal snapshot_received(data: Dictionary)
signal event_received(kind: String, args: Dictionary)
signal up_event_received(peer_id: int, kind: String, args: Dictionary)
signal peer_left_match(peer_id: int)
signal peer_match_ready(peer_id: int)
signal cloud_ready

const PhotonPeer := preload("res://game/net/photon_peer.gd")
const CLOUD_STAGE := "grass"
var cloud_code := ""
var _cloud_error := ""

func cloud_session() -> bool:
	return active and multiplayer.multiplayer_peer is PhotonPeer

static func valid_cloud_code(code: String) -> bool:
	if code.length() != 8:
		return false
	for letter in code:
		if not letter in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789":
			return false
	return true

func host_cloud(player_name: String, capacity := PhotonPeer.Cloud.MAX_PLAYERS) -> Error:
	var alphabet := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code := ""
	for value in Crypto.new().generate_random_bytes(8):
		code += alphabet[int(value) % alphabet.length()]
	return _connect_cloud(true, code, player_name, capacity)

func join_cloud(code: String, player_name: String) -> Error:
	code = code.strip_edges().to_upper().replace(" ", "").replace("-", "")
	if not valid_cloud_code(code):
		return ERR_INVALID_PARAMETER
	return _connect_cloud(false, code, player_name)

func _connect_cloud(hosting: bool, code: String, player_name: String, capacity := PhotonPeer.Cloud.MAX_PLAYERS) -> Error:
	if active:
		_teardown("restart")
	var peer := PhotonPeer.new()
	peer.cloud.capacity = clampi(capacity, 2, PhotonPeer.Cloud.MAX_PLAYERS)
	peer.cloud.app_version = "voloball-%d-cloud-1" % wire_proto()
	peer.cloud_error.connect(func(message: String): _cloud_error = message)
	peer.room_ready.connect(_on_cloud_ready.bind(peer))
	var err := peer.connect_room(hosting, code, player_name)
	if err != OK:
		return err
	active = true
	is_host = hosting
	my_name = DevBadge.guard_name(sanitize_name(player_name), my_steam_id())
	cloud_code = code
	_cloud_error = ""
	players = {}
	party = false
	custom_lobby = true
	privacy = Priv.PUBLIC
	password = ""
	max_humans = peer.cloud.capacity
	stage = CLOUD_STAGE
	GameConfig.quick_match = false
	init_rules_from_config()
	multiplayer.multiplayer_peer = peer
	return OK

func _on_cloud_ready(peer: MultiplayerPeer) -> void:
	if multiplayer.multiplayer_peer != peer or not active:
		return
	if is_host:
		players = {1: {"name": my_name, "cfg": local_character_dict(), "wr": Career.winrate(), "sid": my_steam_id(), "side": 1}}
		hide_imposter_level(my_name, players[1]["cfg"])
		_seat_host_locals(my_name)
		session_token = randi()
		hosted_sid = int(Time.get_unix_time_from_system() * 1000.0) * 1000 + randi() % 1000
	cloud_ready.emit()
	if is_host:
		lobby_changed.emit()

signal votekick_opened(target_peer: int, target_name: String, yes: int, needed: int, secs: int)
signal votekick_updated(yes: int, needed: int, secs: int)
signal votekick_closed(passed: bool, target_name: String)

const PORT: = 28960
const TITLES: = preload("res://game/titles/title_catalog.gd")




const MAX_PLAYERS: = 14









const PROTO: = 61









const DEMO_PROTO: = 100000


static func wire_proto() -> int:
	return PROTO + (DEMO_PROTO if LaunchGate.is_demo() else 0)

static func proto_ok(v: int) -> bool:
	return v == wire_proto()



static func proto_other_kind(v: int) -> bool:
	return (v >= DEMO_PROTO) != LaunchGate.is_demo()

var active: = false
var is_host: = false
var in_match: = false





var custom_lobby: = false



var party_lan: = false
var my_name: = "player"
var team_size: = 2





var max_humans: = 0
var stage: = Stage.home()
var cpu_difficulty: = 1



var cpu_slots: Dictionary = {}






var captains: Dictionary = {}



var rule_points: = 7
var rule_sets: = 2
var rule_wbt: = true
var rule_sweat: = false
var rule_rate: = 1.0


var rule_replays: = true
var rule_collide: = true
var rule_serve: = 15
var rule_hints: = true
var rule_lock: = false
var rule_rotate: = false
var rule_intro: = true





var practice: = false
var practice_collide: = true

var practice_call_all: = true


var practice_size: = 6




var practice_live: = false
var rule_tod: = 0
var rule_outfit: = 0

const RULE_DEFAULTS: = {"pts": 7, "sets": 2, "wbt": true, "sweat": false, 
	"rate": 1.0, "replays": true, "collide": true, "serve": 15, "hints": true, 
	"lock": false, "rotate": false, "intro": true}



func set_rules(pts: int, sets: int, wbt: bool, sweat: bool, rate: float, 
		replays: = true, collide: = true, serve: = 15, hints: = true, 
		lock: = false, rotate: = false, intro: = true) -> void :
	if not is_host:
		return
	rule_points = clampi(pts, 3, 25)
	rule_sets = clampi(sets, 1, 3)
	rule_wbt = wbt
	rule_sweat = sweat
	rule_rate = rate
	rule_replays = replays
	rule_collide = collide
	rule_serve = clampi(serve, 5, 60)
	rule_hints = hints
	rule_lock = lock
	rule_rotate = rotate
	rule_intro = intro
	if not GameConfig.modifiers_allowed():
		_standard_modifiers()
	_broadcast_lobby()
	lobby_changed.emit()



func init_rules_from_config() -> void :
	rule_points = GameConfig.set_points
	rule_sets = GameConfig.sets_to_win
	rule_wbt = GameConfig.win_by_two
	rule_sweat = GameConfig.sweat_enabled
	rule_rate = GameConfig.sweat_rate
	rule_replays = GameConfig.instant_replays
	rule_collide = GameConfig.team_collision
	rule_serve = clampi(GameConfig.serve_seconds, 5, 60)
	rule_hints = GameConfig.ball_hints
	rule_lock = GameConfig.lock_teams
	rule_rotate = GameConfig.rotate_every_point
	rule_intro = GameConfig.match_intro
	rule_tod = GameConfig.time_of_day

	rule_outfit = DressCode.clamp_rule(GameConfig.outfit_rule)
	if not GameConfig.modifiers_allowed():
		_standard_modifiers()


func _standard_modifiers() -> void :
	rule_sweat = bool(RULE_DEFAULTS.sweat)
	rule_rate = float(RULE_DEFAULTS.rate)
	rule_replays = bool(RULE_DEFAULTS.replays)
	rule_collide = bool(RULE_DEFAULTS.collide)
	rule_serve = int(RULE_DEFAULTS.serve)
	rule_hints = bool(RULE_DEFAULTS.hints)
	rule_lock = bool(RULE_DEFAULTS.lock)
	rule_rotate = bool(RULE_DEFAULTS.rotate)
	rule_intro = bool(RULE_DEFAULTS.intro)



func apply_rules_to_config() -> void :
	GameConfig.set_points = rule_points
	GameConfig.sets_to_win = rule_sets
	GameConfig.win_by_two = rule_wbt
	GameConfig.sweat_enabled = rule_sweat
	GameConfig.sweat_rate = rule_rate
	GameConfig.instant_replays = rule_replays
	GameConfig.team_collision = rule_collide
	GameConfig.serve_seconds = clampi(rule_serve, 5, 60)
	GameConfig.ball_hints = rule_hints
	GameConfig.lock_teams = rule_lock
	GameConfig.rotate_every_point = rule_rotate
	GameConfig.match_intro = rule_intro
	GameConfig.time_of_day = rule_tod
	GameConfig.outfit_rule = rule_outfit
	if not GameConfig.modifiers_allowed():
		GameConfig.force_standard_modifiers()


var players: = {}



var session_token: = 0



var last_players: = {}



var last_chat: Array = []


var last_lobby_bans: Array = []

func restore_chat() -> void :
	if chat_log.is_empty() and not last_chat.is_empty():
		chat_log = last_chat.duplicate(true)
		last_chat = []
		for entry in chat_log:
			chat.emit(entry)



func restore_lobby_bans() -> void :
	if not last_lobby_bans.is_empty():
		Mod.lobby_bans_import(last_lobby_bans)
		last_lobby_bans = []
var fake_latency_ms: = 0
var fake_jitter_ms: = 0









var fake_loss_pct: = 0







const PING_EVERY_MS: = 200
var _rtt_ms: = 0.0
var _ping_next: = 0


var _peer_rtt: = {}

var _out_queue: Array = []
var _in_queue: Array = []













signal chat(entry: Dictionary)

const CHAT_MAX_LEN: = 100
const CHAT_LOG_MAX: = 500
const CHAT_MIN_INTERVAL_MS: = 350
const CHAT_BURST: = 4
const CHAT_BURST_WINDOW_MS: = 5000

var chat_log: Array = []
var _chat_burst: = {}



var chat_filter: = Callable()





signal typing_changed(names: Array)

const TYPING_TTL_MS: = 4000

var _typing_until: = {}
var _typing_names: Array = []
var _typing_sent: = false

func set_typing(on: bool) -> void :
	if not active:
		return
	if is_host:
		_host_typing(1, on)
	elif on != _typing_sent or on:
		_c_typing.rpc_id(1, on)
	_typing_sent = on

@rpc("any_peer", "call_remote", "reliable")
func _c_typing(on: bool) -> void :
	var id: = multiplayer.get_remote_sender_id()
	_recv( func(): _host_typing(id, on))

var _typing_flip_t: = {}

func _host_typing(peer: int, on: bool) -> void :
	if not is_host:
		return
	if not _rate_ok(_typing_flip_t, peer, 4, 1000):
		return
	if on:
		_typing_until[peer] = Time.get_ticks_msec() + TYPING_TTL_MS
	else:
		_typing_until.erase(peer)
	_typing_broadcast()

func _typing_sweep() -> void :
	if _typing_until.is_empty():
		return
	var now: = Time.get_ticks_msec()
	var expired: = []
	for pid in _typing_until:
		if int(_typing_until[pid]) <= now:
			expired.append(pid)
	if expired.is_empty():
		return
	for pid in expired:
		_typing_until.erase(pid)
	_typing_broadcast()

func _typing_broadcast() -> void :
	var names: = []
	for pid in _typing_until:
		names.append(String((players.get(pid, {}) as Dictionary)\
		.get("name", "player")))
	names.sort()
	if names == _typing_names:
		return
	_typing_names = names

	typing_changed.emit(names)
	_s_typing.rpc(names)

@rpc("authority", "call_remote", "reliable")
func _s_typing(names: Array) -> void :
	_recv( func():
		_typing_names = names
		typing_changed.emit(names))



var team_of: = Callable()




var room_of: = Callable()
var _chat_last_ms: = {}



static func _chat_identity(court_side: int) -> int:
	return - court_side if Rules.set_swapped else court_side

func side_of(peer_id: int) -> int:
	if team_of.is_valid():
		var s: Variant = team_of.call(peer_id)
		if s != null:
			return int(s)
	return int((players.get(peer_id, {}) as Dictionary).get("side", 0))

func _room(peer_id: int) -> int:
	if room_of.is_valid():
		var r: Variant = room_of.call(peer_id)
		if r != null:
			return int(r)
	return side_of(peer_id)








func ev_v3(a: Dictionary, k: String, d: = Vector3.ZERO) -> Vector3:
	var v: Variant = a.get(k)
	return v if v is Vector3 and is_finite(v.x) and is_finite(v.y) and is_finite(v.z) else d

func ev_f(a: Dictionary, k: String, d: = 0.0) -> float:
	var v: Variant = a.get(k)
	if v is float or v is int:
		var f: = float(v)
		return f if is_finite(f) else d
	return d

func ev_i(a: Dictionary, k: String, d: = 0) -> int:
	var v: Variant = a.get(k)
	if v is int:
		return v
	if v is float and is_finite(v):
		return int(v)
	return d

func ev_s(a: Dictionary, k: String, d: = "", max_len: = 256) -> String:
	var v: Variant = a.get(k)
	return (v as String).substr(0, max_len) if v is String else d

func ev_b(a: Dictionary, k: String, d: = false) -> bool:
	var v: Variant = a.get(k)
	return v if v is bool else d

func ev_arr(a: Dictionary, k: String, max_size: = 64) -> Array:
	var v: Variant = a.get(k)
	return (v as Array).slice(0, max_size) if v is Array else []



static func ni(v: Variant, def: = 0) -> int:
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_BOOL]\
	else def

static func sanitize_chat(text: String) -> String:
	var t: = text.replace("[", "(").replace("]", ")").strip_edges()
	return t.substr(0, CHAT_MAX_LEN)






const NAME_MAX_LEN: = 24

func sanitize_name(text: String) -> String:
	var t: = text.replace("[", "(").replace("]", ")")\
	.replace("\n", " ").replace("\r", " ").strip_edges()
	if t == "":
		t = "player"
	return t.substr(0, NAME_MAX_LEN)

func send_chat(channel: String, text: String) -> void :
	var t: = sanitize_chat(text)
	if t == "" or not active:
		return
	if is_host:
		_host_route_chat(1, channel, t)
	else:
		_c_chat.rpc_id(1, channel, t)





func system_message(text: String) -> void :
	if not is_host or not active:
		return
	var m: = sanitize_chat(text)
	if m == "":
		return
	var entry: = {"t": Time.get_unix_time_from_system(), 
		"n": "", "s": 0, "ch": "all", "m": m, "sys": 1}
	_s_chat.rpc(entry)
	_take_chat(entry)

@rpc("any_peer", "call_remote", "reliable")
func _c_chat(channel: String, text: String) -> void :
	var id: = multiplayer.get_remote_sender_id()
	_recv( func(): _host_route_chat(id, channel, text))

func _host_route_chat(from_peer: int, channel: String, text: String) -> void :
	if not is_host:
		return
	var t: = sanitize_chat(text)
	if t == "":
		return



	if Mod.is_chat_banned(int((players.get(from_peer, {}) as Dictionary).get("sid", 0))):
		return
	var now: = Time.get_ticks_msec()
	if now - int(_chat_last_ms.get(from_peer, - CHAT_MIN_INTERVAL_MS))\
	< CHAT_MIN_INTERVAL_MS:
		return

	var burst: Array = _chat_burst.get(from_peer, [])
	burst = burst.filter( func(t): return now - int(t) < CHAT_BURST_WINDOW_MS)
	if burst.size() >= CHAT_BURST:
		return
	burst.append(now)
	_chat_burst[from_peer] = burst
	_chat_last_ms[from_peer] = now
	if chat_filter.is_valid():
		t = String(chat_filter.call(t))
		if t == "":
			return
	var ch: = "team" if channel == "team" else "all"
	var entry: = {
		"t": Time.get_unix_time_from_system(), 
		"p": from_peer, 
		"n": String((players.get(from_peer, {}) as Dictionary)\
		.get("name", "player")), 




		"s": _chat_identity(side_of(from_peer)), 
		"ch": ch, 
		"m": t, 



		"d": DevBadge.peer_tier(from_peer), 
	}
	if ch == "team":
		var room: = _room(from_peer)
		for pid in players:
			if pid != 1 and _room(int(pid)) == room:
				_s_chat.rpc_id(int(pid), entry)
		if _room(1) == room:
			_take_chat(entry)
	else:
		_s_chat.rpc(entry)
		_take_chat(entry)

@rpc("authority", "call_remote", "reliable")
func _s_chat(entry: Dictionary) -> void :
	_recv( func(): _take_chat(entry))

func _take_chat(raw: Dictionary) -> void :




	var entry: = {
		"n": sanitize_name(ev_s(raw, "n", "player", 64)), 
		"m": sanitize_chat(ev_s(raw, "m", "", CHAT_MAX_LEN * 2)), 
		"s": clampi(ev_i(raw, "s", 0), -1, 1), 
		"ch": "team" if ev_s(raw, "ch", "all") == "team" else "all", 
	}
	for k in raw:
		if not entry.has(k) and k is String and (raw[k] is int or raw[k] is float or raw[k] is bool):
			entry[k] = raw[k]
	if entry.m == "":
		return


	if int(entry.get("d", 0)) == DevBadge.Tier.GOLD and ( not entry.has("p")\
	or DevBadge.peer_tier(int(entry.p)) != DevBadge.Tier.GOLD):
		entry["d"] = DevBadge.Tier.NONE




	chat_log.append(entry)
	while chat_log.size() > CHAT_LOG_MAX:
		chat_log.pop_front()
	chat.emit(entry)



func recent_chat_log(seconds: = 300.0) -> String:
	var now: = Time.get_unix_time_from_system()
	var lines: PackedStringArray = []
	for e in chat_log:
		var t: = float(e.get("t", 0.0))
		if t > 0.0 and now - t > seconds:
			continue
		var stamp: = "?"
		if t > 0.0:
			var ago: = int(now - t)
			stamp = "%dm %ds ago" % [ago / 60, ago % 60]
		var ch: = "T" if String(e.get("ch", "all")) == "team" else "A"
		lines.append("[%s] [%s] %s: %s" % [stamp, ch, String(e.get("n", "?")), String(e.get("m", ""))])
	return "\n".join(lines)










const STEAM_APP_ID_MAIN: = 5037200
const STEAM_APP_ID_PLAYTEST: = 5037230


const STEAM_APP_ID_DEMO: = 5401090




const STEAM_APP_ID_SPACEWAR: = 480

static func steam_app_id() -> int:







	if not OS.has_feature("spacewar"):
		var launched: = OS.get_environment("SteamAppId")








		if launched.is_valid_int() and int(launched) in [STEAM_APP_ID_MAIN, 
				STEAM_APP_ID_PLAYTEST, STEAM_APP_ID_DEMO]:
			return int(launched)

	if OS.has_feature("spacewar"):
		return STEAM_APP_ID_SPACEWAR
	if OS.has_feature("demo"):
		return STEAM_APP_ID_DEMO
	return STEAM_APP_ID_PLAYTEST if OS.has_feature("playtest") else STEAM_APP_ID_MAIN
const STEAM_GAME_KEY: = "volleyball-arcade"
const STEAM_GAME_KEY_DEMO: = "volleyball-arcade-demo"


static func steam_game_key() -> String:
	return STEAM_GAME_KEY_DEMO if LaunchGate.is_demo() else STEAM_GAME_KEY
var steam_lobby_id: = 0
var _ploc_published: = false
var _ploc_next: = 0
var _steam: Object = null
var _steam_tried: = false



var _steam_peer: MultiplayerPeer = null
var _steam_hosting: = false


func _ready() -> void :


	process_mode = Node.PROCESS_MODE_ALWAYS



	multiplayer.server_relay = false
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect( func(): _teardown(_cloud_error if _cloud_error != "" else "connection failed"))
	multiplayer.server_disconnected.connect( func(): _teardown(_cloud_error if _cloud_error != "" else "host left"))



	LocalPlayers.roster_changed.connect(push_local_roster)

	lobby_changed.connect(_dev_check_roster)













var quick_ad_open: = 0
var _quick_udp: PacketPeerUDP = null

func quick_backfill_ad(open: int) -> void :
	if not is_host:
		return
	quick_ad_open = maxi(open, 0)
	if _steam != null and steam_lobby_id != 0:







		var resting: = not in_match
		var rest_kind: = "locked" if GameConfig.quick_match else _lobby_kind
		_steam.setLobbyData(steam_lobby_id, "kind", rest_kind if resting
			else ("quick" if quick_ad_open > 0 else "locked"))
		_steam.setLobbyData(steam_lobby_id, "in_progress", "0" if resting else "1")
		_steam.setLobbyData(steam_lobby_id, "modes", str(team_size))
		_steam.setLobbyData(steam_lobby_id, "members", str(human_count()))
		_steam.setLobbyData(steam_lobby_id, "open", str(quick_ad_open))
	_ensure_quick_udp(_want_quick_udp())




var migrate_open: = false

func migrate_advertise(on: bool) -> void :
	migrate_open = on
	_ensure_quick_udp(_want_quick_udp())

func _want_quick_udp() -> bool:


	return quick_ad_open > 0 or migrate_open

func _ensure_quick_udp(want: bool) -> void :
	if want and _quick_udp == null:
		_quick_udp = PacketPeerUDP.new()
		var bound: = false
		for i in QuickPlay.LAN_PORTS:
			if _quick_udp.bind(QuickPlay.LAN_PORT_BASE + i) == OK:
				bound = true
				break
		if not bound:
			_quick_udp = null
	elif not want and _quick_udp != null:
		_quick_udp.close()
		_quick_udp = null

var _ad_reply_t: = {}
var _ad_global_t: = {}

func _quick_ad_answer() -> void :
	while _quick_udp != null and _quick_udp.get_available_packet_count() > 0:
		var pkt: = _quick_udp.get_packet()
		if pkt.get_string_from_utf8() != "QUICK?":
			continue
		var src: = _quick_udp.get_packet_ip()
		var now: = Time.get_ticks_msec()
		if now - int(_ad_reply_t.get(src, -100000)) < 250:
			continue
		if not _rate_ok(_ad_global_t, 0, 40, 1000):
			continue
		_ad_reply_t[src] = now
		if _ad_reply_t.size() > 256:
			_ad_reply_t.clear()
		var reply: = {
			"sid": steam_lobby_id if steam_lobby_id != 0 else 1, 
			"proto": wire_proto(), 
			"modes": [team_size], 
			"members": human_count(), 
			"in_progress": true, 
			"open": quick_ad_open, 
			"migrate": session_token if migrate_open else 0, 


			"steam_host": my_steam_id() if _steam_hosting else 0, 

			"port": host_port(), 

			"priv": privacy, 
		}
		_quick_udp.set_dest_address(_quick_udp.get_packet_ip(), 
			_quick_udp.get_packet_port())
		_quick_udp.put_packet(JSON.stringify(reply).to_utf8_buffer())

func _process(_delta: float) -> void :
	if OS.get_environment("NET_NO_PROC") == "1":
		return
	_flush_locals()
	if is_host:
		_typing_sweep()
		if (in_match and quick_ad_open > 0) or migrate_open:
			_quick_ad_answer()
	if _steam != null:
		_steam.run_callbacks()
	var now: = Time.get_ticks_msec()



	if is_host and steam_lobby_id != 0 and not _ploc_published and now >= _ploc_next:
		_ploc_next = now + 1500
		_ploc_published = _publish_ping_location(steam_lobby_id)

	if active and not is_host and now >= _ping_next:
		_ping_next = now + PING_EVERY_MS
		ping_host()







	if not _out_queue.is_empty():
		var still_out: Array = []
		for out in _out_queue:
			if int(out.at) <= now and _can_send():
				(out.fn as Callable).call()
			elif int(out.at) > now:
				still_out.append(out)
		_out_queue = still_out
	if not _in_queue.is_empty():
		var still_in: Array = []
		for inp in _in_queue:
			if int(inp.at) <= now:
				(inp.fn as Callable).call()
			else:
				still_in.append(inp)
		_in_queue = still_in





signal steam_ready



var _steam_last_status: = 0
var _steam_last_verbal: = ""

func steam_init_error() -> String:
	return _steam_last_verbal






func steam_build_id() -> int:
	if _steam == null or not _steam.has_method("getAppBuildId"):
		return 0
	return int(_steam.getAppBuildId())










func steam_status_text() -> String:
	if _steam != null:
		return "steam authenticated"
	var code: = " (code %d)" % _steam_last_status if _steam_last_status != 0 else ""
	if running_under_proton():
		return "cannot connect to steam on this proton version%s\n" % code\
		+ "in steam, open this game's properties, set compatibility to proton experimental, then restart the game"
	match _steam_last_status:
		3:
			return "steam is out of date%s\n" % code\
			+ "fully quit steam from the system tray (right click the steam icon, exit), open steam again, then restart the game"
		2:
			return "steam isn't running%s\nopen steam, then restart the game" % code
		0:
			return "cannot connect to steam\nopen steam, then restart the game"
		_:
			return "cannot connect to steam%s\n" % code\
			+ "fully quit steam from the system tray (right click the steam icon, exit), open steam again, then restart the game"




static func running_under_proton() -> bool:
	return OS.get_environment("STEAM_COMPAT_DATA_PATH") != ""\
	or OS.get_environment("WINEPREFIX") != ""\
	or OS.get_environment("SteamDeck") == "1"

func steam_init() -> bool:
	if _steam != null:
		return true






	if _steam_tried:
		return false
	_steam_tried = true
	if not Engine.has_singleton("Steam"):
		return false
	var s: Object = Engine.get_singleton("Steam")
	var app_id: = steam_app_id()
	OS.set_environment("SteamAppId", str(app_id))
	OS.set_environment("SteamGameId", str(app_id))
	var res: Variant = s.steamInitEx(app_id, true)
	if typeof(res) == TYPE_DICTIONARY and int(res.get("status", 1)) != 0:
		_steam_last_status = int(res.get("status", 1))
		_steam_last_verbal = String(res.get("verbal", ""))

		print("[steam] init failed: status %d (%s) app %d"\
		%[_steam_last_status, _steam_last_verbal, app_id])
		return false
	_steam_last_status = 0
	_steam = s




	TITLES.stamp(GameConfig.character)




	if _steam.has_method("initRelayNetworkAccess"):
		_steam.initRelayNetworkAccess()
	_steam_fake_net()
	_steam.lobby_created.connect(_on_steam_lobby_created)
	_steam.lobby_match_list.connect(_on_steam_lobby_list)



	if _steam.has_signal("join_requested"):
		_steam.join_requested.connect(_on_steam_join_requested)
	if _steam.has_signal("lobby_joined"):
		_steam.lobby_joined.connect(_on_steam_lobby_joined)


	if _steam.has_signal("join_game_requested"):
		_steam.join_game_requested.connect(_on_steam_game_join_requested)
	if _steam.has_signal("lobby_chat_update"):
		_steam.lobby_chat_update.connect(_on_steam_lobby_chat_update)



	if _steam.has_signal("persona_state_change"):
		_steam.persona_state_change.connect( func(_sid, _flags): friends_changed.emit())
	if _steam.has_signal("friend_rich_presence_update"):
		_steam.friend_rich_presence_update.connect( func(_sid, _app): friends_changed.emit())


	_check_launch_invite.call_deferred()
	return true






func steam_achievements_available() -> bool:
	if not steam_init():
		return false
	return _steam.has_method("setAchievement") and _steam.has_method("getAchievement")\
	and _steam.has_method("storeStats")

func steam_set_achievement(api_name: String) -> bool:
	if api_name == "" or not steam_achievements_available():
		return false
	_steam.setAchievement(api_name)
	_steam.storeStats()
	return true

func steam_has_achievement(api_name: String) -> bool:
	if api_name == "" or not steam_achievements_available():
		return false
	var st: Variant = _steam.getAchievement(api_name)
	if st is Dictionary:
		return bool(st.get("achieved", false))
	return false




signal invite_join_failed(reason: String)

signal invite_accepting

func steam_invite_overlay() -> bool:





	if _steam == null or steam_lobby_id == 0\
	or not _steam.has_method("activateGameOverlayInviteDialog"):
		return false
	if _steam.has_method("isOverlayEnabled") and not bool(_steam.call("isOverlayEnabled")):
		return false
	_steam.activateGameOverlayInviteDialog(steam_lobby_id)
	return true

func _on_steam_join_requested(lobby_id: int, _friend_id: int) -> void :


	if _steam != null and lobby_id != 0:
		_pending_invite_lobby = lobby_id
		_steam.joinLobby(lobby_id)

var _pending_invite_lobby: = 0
var _abandoned_lobby: = 0






static func _lobby_refusal_text(response: int) -> String:
	match response:
		2:
			return "couldn't join: that lobby is gone"
		3:
			return "couldn't join: that lobby is private (friends or invite only)"
		4:
			return "couldn't join: that lobby is full"
		6:
			return "couldn't join: you're banned from that lobby"
		7:
			return "couldn't join: steam blocks lobbies for limited accounts (no purchase on this account yet)"
		9:
			return "couldn't join: steam community ban on this account"
		10, 11:
			return "couldn't join: someone in that lobby has blocked you (or you them)"
		12:
			return "couldn't join: too many tries, wait a moment"
	return "couldn't join that lobby (steam code %d)" % response






const CODE_KEY_CHARS: = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const CODE_KEY_LEN: = 4
var code_key: = ""

static func _roll_code_key() -> String:
	var out: = ""
	for i in CODE_KEY_LEN:
		out += CODE_KEY_CHARS[randi() % CODE_KEY_CHARS.length()]
	return out

func _on_steam_lobby_joined(lobby_id: int, _perm: int, _locked: bool, 
		response: = 1) -> void :





	if lobby_id != 0 and lobby_id == _abandoned_lobby:
		_abandoned_lobby = 0
		if response == 1:
			_steam.leaveLobby(lobby_id)
		return
	if lobby_id != _pending_invite_lobby:
		return
	_pending_invite_lobby = 0
	if response != 1:
		invite_join_failed.emit(_lobby_refusal_text(response))
		return
	var host_id: = int(String(_steam.getLobbyData(lobby_id, "host_id")))
	_steam.leaveLobby(lobby_id)
	if host_id != 0 and host_id != my_steam_id():



		var hid: = host_id




		var lc: = str(lobby_id)
		var do_join: = func():
			invite_accepting.emit()



			if party and is_host and players.size() > 1:
				party_travel_to.emit(hid, lc)
				return
			join_game_steam(hid, local_display_name())
			remote_lobby_code = lc
		if OnlineTerms.require(do_join):
			do_join.call()

func _check_launch_invite() -> void :
	var args: = OS.get_cmdline_args()
	var i: = args.find("+connect_lobby")
	if i != -1 and i + 1 < args.size() and String(args[i + 1]).is_valid_int()\
	and _steam != null:
		_pending_invite_lobby = int(args[i + 1])
		_steam.joinLobby(_pending_invite_lobby)
		return

	var j: = args.find("+connect_party")
	if j != -1 and j + 1 < args.size() and _steam != null:

		var pass_arg: = (" " + String(args[j + 2])) if j + 2 < args.size()\
		and not String(args[j + 2]).begins_with("+") else ""
		_dial_connect_string("+connect_party %s%s" % [String(args[j + 1]), pass_arg])


signal friends_changed





func steam_friends() -> Array:
	var out: Array = []
	if _steam == null or not _steam.has_method("getFriendCount"):
		return out
	var flag: = 4
	var count: = int(_steam.getFriendCount(flag))
	for i in count:
		var fid: = int(_steam.getFriendByIndex(i, flag))


		var st: = int(_steam.getFriendPersonaState(fid))\
		if _steam.has_method("getFriendPersonaState") else 1
		if st == 0:
			continue
		var same_game: = false
		var other_game: = false
		var lobby: = 0
		if _steam.has_method("getFriendGamePlayed"):
			var g: Variant = _steam.getFriendGamePlayed(fid)
			if typeof(g) == TYPE_DICTIONARY:
				var gid: = int(g.get("id", 0))
				same_game = gid == steam_app_id()
				other_game = gid != 0 and not same_game
				lobby = int(g.get("lobby", 0)) if same_game else 0
		var status: = ""
		if same_game and _steam.has_method("getFriendRichPresence"):
			status = String(_steam.getFriendRichPresence(fid, "status"))
		out.append({"id": fid, "name": String(_steam.getFriendPersonaName(fid)), 
			"in_game": same_game, "status": status, "lobby": lobby, 
			"state": st, "other_game": other_game})

	out.sort_custom( func(a, b):
		if bool(a.in_game) != bool(b.in_game):
			return bool(a.in_game)
		return String(a.name).naturalnocasecmp_to(String(b.name)) < 0)
	return out

func steam_invite_friend(friend_id: int) -> void :
	if _steam != null and steam_lobby_id != 0\
	and _steam.has_method("inviteUserToLobby"):
		_steam.inviteUserToLobby(steam_lobby_id, friend_id)
		party_invited[friend_id] = 1


func steam_can_add_friend() -> bool:
	return _steam != null and _steam.has_method("activateGameOverlayToUser")


func steam_add_friend(sid: int) -> void :
	if sid != 0 and steam_can_add_friend():
		_steam.call("activateGameOverlayToUser", "friendadd", sid)




func steam_open_store(app_id: int) -> bool:
	if _steam == null or not _steam.has_method("activateGameOverlayToStore"):
		return false
	if _steam.has_method("isOverlayEnabled") and not bool(_steam.call("isOverlayEnabled")):
		return false
	_steam.call("activateGameOverlayToStore", app_id, 0)
	return true


func steam_join_friend_lobby(lobby_id: int) -> void :
	if _steam != null and lobby_id != 0:



		_pending_invite_lobby = lobby_id
		_steam.joinLobby(lobby_id)





signal presence_changed(text: String)
var presence_text: = "In the menu"

func set_presence(text: String, group: = "", group_size: = 0, 
		group_max: = 6) -> void :
	_refresh_connect()
	if text == presence_text and group == _presence_group:
		return
	presence_text = text
	_presence_group = group
	if _steam != null and _steam.has_method("setRichPresence"):
		_steam.setRichPresence("status", text)

		_steam.setRichPresence("steam_player_group", group)
		if group != "" and group_size > 0:
			_steam.setRichPresence("steam_player_group_size", str(group_size))
	presence_changed.emit(text)

var _presence_group: = ""

func steam_persona() -> String:
	return String(_steam.getPersonaName()) if _steam != null else ""

func steam_transport_available() -> bool:
	return steam_init() and ClassDB.class_exists("SteamMultiplayerPeer")





var remote_lobby_code: = ""
func lobby_code() -> String:
	if cloud_session():
		return cloud_code







	if GameConfig.quick_match or quick_queue:
		return ""
	if steam_lobby_id != 0:
		return "" if GameConfig.quick_match or code_key == ""\
		else "%d-%s" % [steam_lobby_id, code_key]
	return remote_lobby_code








func shared_lobby_code() -> String:
	return "" if privacy == Priv.PASSWORD else lobby_code()







func join_by_code(code_text: String) -> bool:



	var parts: = code_text.strip_edges().to_upper().split("-", false)
	if parts.is_empty() or not String(parts[0]).is_valid_int():
		return false
	var lobby: = int(parts[0])
	if lobby == 0 or not steam_init():
		return false
	join_password = String(parts[1]) if parts.size() > 1 else ""
	if _abandoned_lobby == lobby:
		_abandoned_lobby = 0
	_pending_invite_lobby = lobby
	_steam.joinLobby(lobby)
	return true



func cancel_code_join() -> void :
	if _pending_invite_lobby != 0:
		_abandoned_lobby = _pending_invite_lobby
		_pending_invite_lobby = 0

func host_game_steam(player_name: String) -> Error:


	if not steam_transport_available():
		return ERR_UNAVAILABLE
	if active:
		_teardown("restart")
	_steam_hosting = true
	active = true
	is_host = true
	player_name = DevBadge.guard_name(player_name, my_steam_id())
	my_name = player_name
	players = {1: {"name": player_name, "cfg": local_character_dict(), 
		"wr": Career.winrate(), "sid": my_steam_id(), "side": 1}}
	hide_imposter_level(player_name, players[1]["cfg"])
	_seat_host_locals(player_name)
	session_token = randi()
	code_key = _roll_code_key()
	_steam.createLobby(2, MAX_PLAYERS)
	lobby_changed.emit()
	return OK






func _steam_fake_net() -> void :
	if not OS.has_feature("editor") or _steam == null\
	or not _steam.has_method("setGlobalConfigValueInt32"):
		return
	var a: = LaunchGate.dev_args()
	var i: = a.find("--steam-fake")
	if i == -1 or i + 1 >= a.size():
		return
	var opt: = {}
	for part in String(a[i + 1]).split(",", false):
		var kv: = part.split("=")
		if kv.size() == 2 and kv[1].is_valid_float():
			opt[kv[0].strip_edges()] = float(kv[1])
	var lag: = int(opt.get("lag", 0.0))
	var loss: = float(opt.get("loss", 0.0))
	var jitter: = int(opt.get("jitter", 0.0))
	var reorder: = float(opt.get("reorder", 0.0))
	var dup: = float(opt.get("dup", 0.0))

	_steam.setGlobalConfigValueInt32(4, lag)
	_steam.setGlobalConfigValueInt32(5, lag)
	_steam.setGlobalConfigValueFloat(2, loss)
	_steam.setGlobalConfigValueFloat(3, loss)
	_steam.setGlobalConfigValueInt32(53, jitter)
	_steam.setGlobalConfigValueInt32(54, jitter * 3)
	_steam.setGlobalConfigValueFloat(55, 100.0 if jitter > 0 else 0.0)
	_steam.setGlobalConfigValueFloat(6, reorder)
	_steam.setGlobalConfigValueFloat(7, reorder)
	_steam.setGlobalConfigValueInt32(8, 50 if reorder > 0.0 else 0)
	_steam.setGlobalConfigValueFloat(26, dup)
	_steam.setGlobalConfigValueFloat(27, dup)
	_steam.setGlobalConfigValueInt32(28, 40 if dup > 0.0 else 0)
	print("[net] steam fake network: lag %d ms, loss %.1f%%, jitter %d ms, reorder %.1f%%, dup %.1f%%"
		%[lag, loss, jitter, reorder, dup])



static var _steam_peer_debug: = OS.has_feature("editor") and "--steam-peer-debug" in LaunchGate.dev_args()



const STEAM_REDIAL_GAP: = 0.5
var _steam_link_closed_ms: = -100000


func _steam_settle_left() -> float:
	return maxf(0.0, STEAM_REDIAL_GAP - (Time.get_ticks_msec() - _steam_link_closed_ms) / 1000.0)

func _new_steam_peer() -> MultiplayerPeer:
	var peer: MultiplayerPeer = ClassDB.instantiate("SteamMultiplayerPeer")
	if peer != null and _steam_peer_debug:
		peer.set("debug_level", 2)
	return peer

func join_game_steam(host_steam_id: int, player_name: String) -> Error:


	if not steam_transport_available() or host_steam_id == 0:
		return ERR_UNAVAILABLE
	if active:
		_teardown("restart")
	var peer: MultiplayerPeer = _new_steam_peer()
	if peer == null:
		return ERR_UNAVAILABLE
	_steam_peer = peer
	active = true
	is_host = false
	my_name = player_name
	players = {}


	var wait: = _steam_settle_left()
	if wait > 0.0:













		var tree: = Engine.get_main_loop() as SceneTree
		if tree != null:
			tree.create_timer(wait, true, false, true).timeout.connect( func():
				if _steam_peer == peer and active:
					peer.call("create_client", host_steam_id, 0)
					multiplayer.multiplayer_peer = peer)
			return OK
	peer.call("create_client", host_steam_id, 0)
	multiplayer.multiplayer_peer = peer
	return OK

func local_display_name() -> String:





	return _own_name(true)

func _own_name(start_steam: bool) -> String:
	if AppData.is_harness():
		var a: = LaunchGate.dev_args()
		var at: = a.find("--net-name")
		if at != -1 and at + 1 < a.size():
			return DevBadge.guard_name(String(a[at + 1]), my_steam_id())
	var up: = steam_init() if start_steam else _steam != null
	if up and steam_persona() != "":
		return DevBadge.guard_name(steam_persona(), my_steam_id())
	return "you"





func local_imposter() -> bool:
	return is_inside_tree() and DevBadge.is_imposter_name(_own_name(false))





static func hide_imposter_level(name: String, cfg: Variant) -> void :
	if cfg is Dictionary and DevBadge.is_imposter_name(name):
		(cfg as Dictionary).erase("lvl")








func display_name_for_slot(slot: int) -> String:
	var base: = local_display_name()
	if slot <= 0:
		return base


	return "%s[%d]" % [base, slot + 1]












static func seat_key(peer: int, ls: int) -> String:
	return "%d:%d" % [peer, ls]


func locals_of(peer: int) -> Array:
	if not players.has(peer):
		return []
	var l: Variant = (players[peer] as Dictionary).get("locals", [])
	return l if l is Array else []





func human_count() -> int:
	var n: = 0
	for id in players:
		n += 1 + locals_of(int(id)).size()
	return n





func seated_humans() -> int:
	var counts: = {1: 0, -1: 0}
	for id in players:
		var row: Dictionary = players[id]
		var sides: Array = [int(row.get("side", 0))]
		for g in locals_of(int(id)):
			sides.append(int((g as Dictionary).get("side", row.get("side", 0))))
		for sd in sides:
			if counts.has(sd):
				counts[sd] += 1
	return mini(counts[1], team_size) + mini(counts[-1], team_size)




func local_guest_payload() -> Array:
	var out: Array = []
	for s in LocalPlayers.slots:
		if s.index <= 0:
			continue
		var cfg: Dictionary = {}
		if s.profile != null and s.profile.character is Dictionary:
			cfg = (s.profile.character as Dictionary).duplicate()

			var lv: = Progression.shown_level(s.profile)
			if lv > 0:
				cfg["lvl"] = lv
			else:
				cfg.erase("lvl")
		out.append({"side": int(s.team_side), "cfg": cfg})
	return out






func _seat_host_locals(player_name: String) -> void :
	if not players.has(1):
		return
	var mine: = _derive_locals(player_name, int(players[1].side), 
		local_guest_payload())
	if not mine.is_empty():
		players[1]["locals"] = mine





func participants() -> Array:
	var ids: = players.keys()
	ids.sort()
	var out: Array = []
	for id in ids:
		out.append({"peer": int(id), "ls": 0, "owner": true})
		var i: = 1
		for _g in locals_of(int(id)):
			out.append({"peer": int(id), "ls": i, "owner": false})
			i += 1
	return out

func _lan_ip() -> String:

	for addr in IP.get_local_addresses():
		var a: = String(addr)
		if a.begins_with("192.168.") or a.begins_with("10."):
			return a
		if a.begins_with("172."):
			var second: = int(a.split(".")[1])
			if second >= 16 and second <= 31:
				return a
	return "127.0.0.1"

func _steam_open_lobby() -> void :
	if _steam == null or steam_lobby_id != 0:
		return

	_steam.createLobby(2, MAX_PLAYERS)



func _start_steam_host(lobby_id: int) -> void :
	var peer: MultiplayerPeer = _new_steam_peer()
	peer.call("create_host", 0)
	multiplayer.multiplayer_peer = peer
	_steam_peer = peer
	_steam.setLobbyData(lobby_id, "steam", "1")
	_steam.setLobbyData(lobby_id, "host_id", str(_steam.getSteamID()))

func _on_steam_lobby_created(result: int, lobby_id: int) -> void :
	if result != 1:



		print("[net] steam lobby create failed: result %d" % result)
	if result != 1 or not active or not is_host:
		return
	steam_lobby_id = lobby_id
	_steam.setLobbyData(lobby_id, "game", steam_game_key())
	_steam.setLobbyData(lobby_id, "name", "%s's court" % my_name)
	_steam.setLobbyData(lobby_id, "proto", str(wire_proto()))
	_steam.setLobbyData(lobby_id, "humans", str(human_count()))


	_steam.setLobbyData(lobby_id, "cap", 
		str(max_humans if max_humans > 0 else MAX_PLAYERS))
	_publish_court_slots(lobby_id)





	_ploc_published = _publish_ping_location(lobby_id)



	_steam.setLobbyData(lobby_id, "kind", _lobby_kind)


	_steam.setLobbyData(lobby_id, "locked", 
		"1" if privacy == Priv.PASSWORD else "0")
	_steam.setLobbyData(lobby_id, "priv", 
		["public", "friends", "password"][privacy])

	if party:
		_apply_party_lobby_type()
	if _steam_hosting:




		var wait: = _steam_settle_left()
		var tree: = Engine.get_main_loop() as SceneTree
		if wait > 0.0 and tree != null:
			tree.create_timer(wait, true, false, true).timeout.connect( func():
				if active and is_host and _steam_hosting and _steam_peer == null\
				and steam_lobby_id == lobby_id:
					_start_steam_host(lobby_id))
		else:
			_start_steam_host(lobby_id)
	elif OS.has_feature("editor") and not LaunchGate.public_beta():





		_steam.setLobbyData(lobby_id, "ip", _lan_ip())




	lobby_changed.emit()




func steam_quick_meta(modes_csv: String, members: int, locked: bool, 
		lock_at: = 0, forming: = false, invite: = 0, askable: = false, humans: = 0, 
		band: = 0, band_open: = false, member_hashes: = "", accepted: = 0, 
		reserved: = "") -> void :
	if _steam == null or steam_lobby_id == 0:
		return



	_steam.setLobbyData(steam_lobby_id, "acc", str(accepted))
	_steam.setLobbyData(steam_lobby_id, "rsv", reserved)


	_steam.setLobbyData(steam_lobby_id, "bh", member_hashes)


	_steam.setLobbyData(steam_lobby_id, "lb", str(band))
	_steam.setLobbyData(steam_lobby_id, "lw", "1" if band_open else "0")
	_steam.setLobbyData(steam_lobby_id, "kind", "locked" if locked else "quick")
	_steam.setLobbyData(steam_lobby_id, "modes", modes_csv)
	_steam.setLobbyData(steam_lobby_id, "members", str(members))



	_steam.setLobbyData(steam_lobby_id, "lock_at", str(lock_at))

	_steam.setLobbyData(steam_lobby_id, "fm", "1" if forming else "0")


	_steam.setLobbyData(steam_lobby_id, "inv", str(invite))

	_steam.setLobbyData(steam_lobby_id, "pq", "1" if askable else "0")
	_steam.setLobbyData(steam_lobby_id, "hum", str(humans))



func steam_server_time() -> int:
	if _steam == null or not _steam.has_method("getServerRealTime"):
		return 0
	return int(_steam.getServerRealTime())

func _steam_close_lobby() -> void :
	if _steam != null and steam_lobby_id != 0:
		_steam.leaveLobby(steam_lobby_id)
	steam_lobby_id = 0
	_ploc_published = false




func _publish_ping_location(lobby_id: int) -> bool:
	if lobby_id == 0 or _steam == null or not _steam.has_method("getLocalPingLocation"):
		return false
	var loc: Variant = _steam.getLocalPingLocation()



	var bytes: = PackedByteArray()
	if typeof(loc) == TYPE_DICTIONARY:
		var v: Variant = (loc as Dictionary).get("location", null)
		if typeof(v) == TYPE_PACKED_BYTE_ARRAY:
			bytes = v
	elif typeof(loc) == TYPE_PACKED_BYTE_ARRAY:
		bytes = loc
	if bytes.size() > 0:
		_steam.setLobbyData(lobby_id, "ploc", Marshalls.raw_to_base64(bytes))
		return true
	return false


func _estimate_ping(ploc: String) -> int:
	if ploc == "" or _steam == null\
	or not _steam.has_method("estimatePingTimeFromLocalHost"):
		return -1

	var bytes: = Marshalls.base64_to_raw(ploc)
	if bytes.size() == 0:
		return -1
	var est: Variant = _steam.estimatePingTimeFromLocalHost(bytes)
	return int(est) if typeof(est) in [TYPE_INT, TYPE_FLOAT] and int(est) >= 0\
	else -1






var _lobby_req_kind: = ""
var lobby_list_kind: = ""





var _lobby_req_at: = 0
var _lobby_req_queue: Array = []
const LOBBY_REQ_STALE_MS: = 5000








func steam_request_lobbies(kind: = "") -> void :
	if _steam == null:
		return
	if _lobby_req_at > 0 and Time.get_ticks_msec() - _lobby_req_at < LOBBY_REQ_STALE_MS:
		if not _lobby_req_queue.has(kind):
			_lobby_req_queue.append(kind)
		return
	_lobby_req_at = Time.get_ticks_msec()

	_steam.addRequestLobbyListStringFilter("game", steam_game_key(), 0)






	var base_kind: = "quick" if kind.begins_with("quick") else kind
	if base_kind != "":
		_steam.addRequestLobbyListStringFilter("kind", base_kind, 0)
	if kind.begins_with("quick_inv:"):
		_steam.addRequestLobbyListStringFilter("inv", kind.get_slice(":", 1), 0)
	elif kind.begins_with("quick_host:"):


		_steam.addRequestLobbyListStringFilter("host_id", kind.get_slice(":", 1), 0)
	elif kind == "quick_pq":
		_steam.addRequestLobbyListStringFilter("pq", "1", 0)



	if base_kind == "quick" and _steam.has_method("addRequestLobbyListNumericalFilter"):
		_steam.addRequestLobbyListNumericalFilter("proto", wire_proto(), 0)


	if base_kind == "quick" and not kind.begins_with("quick_inv:")\
	and not kind.begins_with("quick_host:") and quick_band > 0\
	and _steam.has_method("addRequestLobbyListNearValueFilter"):
		_steam.addRequestLobbyListNearValueFilter("lb", quick_band)
	_lobby_req_kind = kind




	_steam.addRequestLobbyListDistanceFilter(3)




	_steam.addRequestLobbyListResultCountFilter(250)
	_steam.requestLobbyList()

func _on_steam_lobby_list(lobbies: Array) -> void :


	var rows: Array = []
	for lobby_id in lobbies:
		var ip: = String(_steam.getLobbyData(lobby_id, "ip"))
		var via_steam: = String(_steam.getLobbyData(lobby_id, "steam")) == "1"
		var host_id: = int(String(_steam.getLobbyData(lobby_id, "host_id")))
		if ip == "" and not (via_steam and host_id != 0):
			continue



		var lobby_kind: = String(_steam.getLobbyData(lobby_id, "kind"))
		rows.append({
			"name": String(_steam.getLobbyData(lobby_id, "name")), 
			"ip": ip, 
			"steam": via_steam, 
			"host_id": host_id, 
			"lobby_id": int(lobby_id), 
			"players": int(_steam.getNumLobbyMembers(lobby_id)), 
			"kind": lobby_kind, 
			"modes": String(_steam.getLobbyData(lobby_id, "modes")), 
			"qmembers": int(String(_steam.getLobbyData(lobby_id, "members"))), 
			"lock_at": int(String(_steam.getLobbyData(lobby_id, "lock_at"))), 
			"fm": String(_steam.getLobbyData(lobby_id, "fm")) == "1", 
			"inv": int(String(_steam.getLobbyData(lobby_id, "inv"))), 
			"pq": String(_steam.getLobbyData(lobby_id, "pq")) == "1", 
			"hum": int(String(_steam.getLobbyData(lobby_id, "hum"))), 
			"acc": int(String(_steam.getLobbyData(lobby_id, "acc"))), 
			"rsv": String(_steam.getLobbyData(lobby_id, "rsv")), 
			"lb": int(String(_steam.getLobbyData(lobby_id, "lb"))), 
			"lw": String(_steam.getLobbyData(lobby_id, "lw")) == "1", 
			"bh": String(_steam.getLobbyData(lobby_id, "bh")), 
			"in_progress": String(_steam.getLobbyData(lobby_id, "in_progress")), 
			"open": int(String(_steam.getLobbyData(lobby_id, "open"))), 
			"state": String(_steam.getLobbyData(lobby_id, "state")), 
			"mode": String(_steam.getLobbyData(lobby_id, "mode")), 
			"map": String(_steam.getLobbyData(lobby_id, "map")), 
			"stage": String(_steam.getLobbyData(lobby_id, "stage")), 
			"humans": int(String(_steam.getLobbyData(lobby_id, "humans"))), 
			"cap": String(_steam.getLobbyData(lobby_id, "cap")), 


			"size": int(String(_steam.getLobbyData(lobby_id, "size"))), 
			"seated": int(String(_steam.getLobbyData(lobby_id, "seated"))), 
			"ping": _estimate_ping(String(_steam.getLobbyData(lobby_id, "ploc"))), 
			"locked": String(_steam.getLobbyData(lobby_id, "locked")) == "1", 
			"priv": String(_steam.getLobbyData(lobby_id, "priv")), 



			"compatible": proto_ok(int(String(_steam.getLobbyData(lobby_id, "proto")))), 
		})
	lobby_list_kind = _lobby_req_kind
	if GameConfig.debug_net_log or lobby_list_kind != "":


		print("[net] lobby list (%s): %d from steam, %d listed" % [
			lobby_list_kind if lobby_list_kind != "" else "all", lobbies.size(), rows.size()])
	steam_lobbies.emit(rows)

	_lobby_req_at = 0
	if not _lobby_req_queue.is_empty():
		steam_request_lobbies(String(_lobby_req_queue.pop_front()))



func host_game(player_name: String) -> Error:
	if active:

		_teardown("restart")
	var peer: = ENetMultiplayerPeer.new()
	var err: = peer.create_server(host_port(), MAX_PLAYERS)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	active = true
	is_host = true
	player_name = DevBadge.guard_name(player_name, my_steam_id())
	my_name = player_name
	players = {1: {"name": player_name, "cfg": local_character_dict(), 
		"wr": Career.winrate(), "sid": my_steam_id(), "side": 1}}
	hide_imposter_level(player_name, players[1]["cfg"])
	_seat_host_locals(player_name)
	session_token = randi()
	hosted_sid = int(Time.get_unix_time_from_system() * 1000.0) * 1000 + randi() % 1000
	_steam_open_lobby()
	lobby_changed.emit()
	return OK




func split_address(addr: String) -> Array:
	var s: = addr.strip_edges()
	var cut: = s.rfind(":")
	if cut > 0 and not s.ends_with("]") and s.substr(cut + 1).is_valid_int():
		var head: = s.substr(0, cut)
		if head.count(":") == 0 or head.ends_with("]"):
			return [head, int(s.substr(cut + 1))]
	return [s, PORT]




func host_port() -> int:
	var a: = LaunchGate.dev_args()
	var i: = a.find("--net-port")
	if i != -1 and i + 1 < a.size() and String(a[i + 1]).is_valid_int():
		return int(a[i + 1])
	return PORT

func join_game(ip: String, player_name: String) -> Error:
	if active:
		_teardown("restart")
	var peer: = ENetMultiplayerPeer.new()
	var hp: = split_address(ip)



	if _connect_delay() > 0.0:
		var err0: = peer.create_client("127.0.0.1", 9)
		if err0 != OK:
			return err0
		get_tree().create_timer(_connect_delay()).timeout.connect( func():
			if multiplayer.multiplayer_peer != peer:
				return
			var real: = ENetMultiplayerPeer.new()
			if real.create_client(String(hp[0]), int(hp[1])) != OK:
				_teardown("connection failed")
				return
			multiplayer.multiplayer_peer = real
			peer.close())
	else:
		var err: = peer.create_client(String(hp[0]), int(hp[1]))
		if err != OK:
			return err
	multiplayer.multiplayer_peer = peer
	active = true
	is_host = false
	my_name = player_name
	players = {}
	_last_join_ip = ip
	return OK

func _notification(what: int) -> void :






	if what == NOTIFICATION_WM_CLOSE_REQUEST and active:
		leave()

func leave() -> void :



	if is_host and active and _has_live_peer() and _can_send():
		_s_session_closing.rpc()
	elif active and not is_host and _has_live_peer()\
	and multiplayer.multiplayer_peer.get_connection_status()\
	== MultiplayerPeer.CONNECTION_CONNECTED:
		_c_bye.rpc_id(1)

		multiplayer.poll()
	_teardown("left")

@rpc("authority", "call_remote", "reliable")
func _s_session_closing() -> void :
	if not is_host:
		_teardown("host left")

func _teardown(reason: String) -> void :
	if not active:
		return
	QuickPlay.qlog("teardown: %s (host=%s players=%d)" % [reason, str(is_host), players.size()])
	_steam_close_lobby()
	if _steam_peer != null:
		_steam_link_closed_ms = Time.get_ticks_msec()
	_steam_peer = null
	_steam_hosting = false
	custom_lobby = false
	cpu_slots = {}
	captains = {}
	party_lan = false
	last_players = players.duplicate(true)
	last_chat = chat_log.duplicate(true)
	active = false
	cloud_code = ""
	_cloud_error = ""
	is_host = false
	_rtt_ms = 0.0
	practice_live = false
	practice = false
	practice_collide = true
	practice_call_all = true
	practice_size = 6
	_ping_next = 0
	_peer_rtt.clear()
	_peer_heard_ms.clear()
	_dev_proven.clear()
	_dev_asked.clear()
	last_lobby_bans = Mod.lobby_bans_export()
	Mod.session_reset()
	_vk_reset()
	_host_ban_checked = false
	in_match = false
	pending_start = []
	party = false
	quick_queue = false
	quick_locked = false
	quick_ad_open = 0
	migrate_open = false
	remote_lobby_code = ""
	code_key = ""
	_lobby_kind = "custom"



	privacy = Priv.PUBLIC
	password = ""
	max_humans = 0
	if _quick_udp != null:
		_quick_udp.close()
		_quick_udp = null
	players = {}

	chat_log.clear()
	_chat_last_ms.clear()
	_chat_burst.clear()
	_typing_until.clear()
	_typing_names = []
	_typing_sent = false
	team_of = Callable()
	room_of = Callable()
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	_refresh_connect()
	session_ended.emit(reason)

func peer_rtt_ms(peer_id: int) -> float:
	if cloud_session():
		return float(multiplayer.multiplayer_peer.cloud.rtt_ms) + float(fake_latency_ms)

	if _steam_peer != null:




		if is_host:
			return float(_peer_rtt.get(peer_id, fake_latency_ms))
		return _rtt_ms if _rtt_ms > 0.0 else float(fake_latency_ms)
	var enet: = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if enet == null:
		return float(fake_latency_ms)





	if not multiplayer.get_peers().has(peer_id):
		return float(fake_latency_ms)
	var p: = enet.get_peer(peer_id)
	if p == null:
		return float(fake_latency_ms)
	return p.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)\
	+ float(fake_latency_ms)



func _on_peer_connected(id: int) -> void :







	if not is_host:
		return
	if players.has(id):
		players.erase(id)
		_broadcast_lobby()
		lobby_changed.emit()
	_hello_peer_t.erase(id)






enum Priv{PUBLIC, FRIENDS, PASSWORD}
var privacy: int = Priv.PUBLIC
var password: = ""
var join_password: = ""




func _is_friend(sid: int) -> bool:
	if _steam == null or sid == 0:
		return false
	if not _steam.has_method("getFriendRelationship"):
		return true

	return int(_steam.getFriendRelationship(sid)) == 3




func can_open_steam_profile() -> bool:
	return _steam != null

func open_steam_profile(sid: int) -> void :
	if sid == 0 or _steam == null:
		return
	if _steam.has_method("isOverlayEnabled") and bool(_steam.isOverlayEnabled())\
	and _steam.has_method("activateGameOverlayToUser"):
		_steam.activateGameOverlayToUser("steamid", sid)
	else:
		OS.shell_open("https://steamcommunity.com/profiles/%d" % sid)

func local_character_dict() -> Dictionary:
	var cfg: CharacterConfig = GameConfig.character
	if cfg == null:
		return {}
	TITLES.stamp(cfg)
	var d: = cfg.to_dict()

	if QuickPlay.dev_level > 0:
		d["lvl"] = QuickPlay.dev_level
	return d

func _on_connected() -> void :
	_c_hello.rpc_id(1, my_name, local_character_dict(), wire_proto(), 
		Career.winrate(), quick_join_modes, my_steam_id(), join_password, 
		quick_party_token, local_guest_payload(), quick_party_block, 
		QuickPlay.my_band(), quick_join_open, ",".join(Mod.blocked_hashes().keys()).left(BLOCKS_MAX))
	quick_join_modes = []
	quick_join_open = false
	quick_party_token = 0
	quick_party_block = 0
	join_password = ""













func lan_session() -> bool:
	if OS.has_feature("editor") and ("--fix-probe" in LaunchGate.dev_args()
			or "--demo-online-probe" in LaunchGate.dev_args()):
		return false
	return active and not cloud_session() and _steam_peer == null and not _steam_hosting

func my_steam_id() -> int:
	if _dev_sid != 0:
		return _dev_sid
	return int(_steam.getSteamID()) if _steam != null else 0





var _dev_sid: = _read_dev_sid()

static func _read_dev_sid() -> int:
	if not OS.has_feature("editor"):
		return 0
	var a: = LaunchGate.dev_args()
	var i: = a.find("--dev-sid")
	if i != -1 and i + 1 < a.size() and String(a[i + 1]).is_valid_int():
		return int(a[i + 1])
	return 0

func _on_peer_disconnected(id: int) -> void :
	QuickPlay.qlog("peer %d disconnected (host=%s)" % [id, str(is_host)])
	if not is_host:
		return
	players.erase(id)
	_peer_heard_ms.erase(id)
	_vk_on_peer_gone(id)
	if in_match or practice_live:
		peer_left_match.emit(id)




	_broadcast_lobby()
	lobby_changed.emit()





signal quick_modes_requested(modes: Array)



signal quick_status(text: String)

func quick_status_push(text: String) -> void :
	if is_host and active:
		_s_quick_status.rpc(text)

@rpc("authority", "call_remote", "reliable")
func _s_quick_status(text: String) -> void :
	_recv( func(): quick_status.emit(text))
var quick_join_modes: Array = []


var quick_join_open: = false

var quick_band: = 0

const BLOCKS_MAX: = 4096



var quick_party_token: = 0


var quick_party_block: = 0




const REGROUP: = "regroup"



const QUEUE_FULL: = "the match filled up, searching again"


var quick_locked: = false




var party_home_tokens: = {}




var party_expect: = {}

func party_still_coming() -> bool:
	if party_expect.is_empty():
		return false
	if not party or Time.get_ticks_msec() > int(party_expect.get("until", 0))\
	or party_members().size() >= int(party_expect.get("count", 0)):
		party_expect = {}
		return false
	return true






var home_party: = {}
var _last_join_ip: = ""
var _dev_connect_delay: = -1.0


var hosted_sid: = 0

func _connect_delay() -> float:
	if _dev_connect_delay < 0.0:
		var a: = LaunchGate.dev_args()
		var i: = a.find("--connect-delay")
		_dev_connect_delay = maxf(0.0, float(a[i + 1])) if i >= 0 and i + 1 < a.size() else 0.0
	return _dev_connect_delay



var quick_queue: = false

@rpc("any_peer", "call_remote", "reliable")
func _c_hello(player_name: String, cfg: Dictionary, proto: = 0, 
	wr: = 0.5, quick_modes: Array = [], steam_id: = 0, pw: = "", 
	ptoken: = 0, locals: Array = [], pblock: = 0, band: = 0, band_open: = false, 
	blocks: = "") -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()



	if players.has(id):
		return
	if not _rate_ok(_hello_peer_t, id, 2, 10000):
		return


	_hello_admit(id, player_name, cfg, proto, wr, quick_modes, steam_id, pw, ptoken, 
		false, locals, pblock, band, band_open, blocks)




func _hello_admit(id: int, player_name: String, cfg: Dictionary, proto: int, 
		wr: float, quick_modes: Array, steam_id: int, pw: String, ptoken: int, 
		dup_settled: = false, locals: Array = [], pblock: = 0, band: = 0, 
		band_open: = false, blocks: = "") -> void :
	if not is_host or players.has(id):
		return
	if dup_settled and not multiplayer.get_peers().has(id):
		return




	var incoming: int = 1 + mini(locals.size(), LocalPlayers.MAX_LOCAL - 1)


	if human_count() + incoming > MAX_PLAYERS:
		refuse_peer(id, "lobby is full")
		return


	player_name = sanitize_name(player_name)




	if _steam_peer != null and _steam_peer.has_method("get_steam_id_for_peer_id"):
		steam_id = int(_steam_peer.call("get_steam_id_for_peer_id", id))


	player_name = DevBadge.guard_name(player_name, steam_id)

















	if steam_id != 0 and _steam_peer != null:
		var old: = _same_sid_peer(steam_id, id)
		if old != 0:
			var old_alive: bool = Time.get_ticks_msec()\
			- int(_peer_heard_ms.get(old, 0)) < DUP_LIVE_MS
			if old_alive and not dup_settled:
				var tree: = Engine.get_main_loop() as SceneTree
				if tree != null:
					tree.create_timer(DUP_SETTLE_S).timeout.connect(
						_hello_admit.bind(id, player_name, cfg, proto, wr, 
							quick_modes, steam_id, pw, ptoken, true, locals, pblock, band, band_open, blocks))
					return
			if old_alive:
				refuse_peer(id, "you're already in this lobby from another copy of the game")
				return
			_evict_ghost(steam_id, id)






	if steam_id != 0 and Mod.is_blocked(steam_id):
		refuse_peer(id, Mod.block_reason(steam_id))
		return





	var returning: bool = party and ptoken != 0 and quick_modes.is_empty()\
	and party_home_tokens.has(ptoken)





	if ptoken != 0 and not quick_modes.is_empty()\
	and (in_match or quick_locked or not quick_queue):
		refuse_peer(id, REGROUP)
		return






	if ptoken == 0 and not quick_modes.is_empty()\
	and (in_match or quick_locked) and quick_ad_open <= 0:
		refuse_peer(id, QUEUE_FULL)
		return



	if not quick_modes.is_empty() and not (quick_queue or quick_ad_open > 0 or migrate_open):
		quick_modes = []



	cfg = TITLES.gate(CharacterConfig.sanitize_dict(cfg), steam_id)
	hide_imposter_level(player_name, cfg)
	wr = clampf(wr, 0.0, 1.0) if is_finite(wr) else 0.5


	if not _rate_ok(_hello_t, 0, HELLO_BURST, 10000):
		refuse_peer(id, "busy, try again in a moment")
		return



	if not proto_ok(proto):
		refuse_peer(id, "the demo can't play with the full game" if proto_other_kind(proto)
			else "version mismatch, update the game")
		return





	var keyed: = privacy == Priv.PASSWORD and code_key != "" and pw == code_key
	if privacy == Priv.PASSWORD and pw != password and not keyed:
		_rate_ok(_pw_fail_t, 0, PW_TRIES, PW_WINDOW_MS)
		refuse_peer(id, "wrong password")
		return
	if privacy == Priv.PASSWORD and not keyed\
	and not _rate_ok(_pw_fail_t, 0, PW_TRIES, PW_WINDOW_MS, false):
		refuse_peer(id, "too many wrong passwords, wait a minute")
		return
	if privacy == Priv.FRIENDS and _steam != null\
	and not _is_friend(steam_id):
		refuse_peer(id, "friends only")
		return





	if quick_modes.is_empty():
		var shut: = _party_door_refusal(steam_id, pw)
		if shut != "":
			refuse_peer(id, shut)
			return







	if party and quick_modes.is_empty() and (returning or not quick_queue)\
	and _party_humans() + incoming > PARTY_MAX:
		refuse_peer(id, "party is full")
		return




	if not party and quick_modes.is_empty()\
	and max_humans > 0 and human_count() + incoming > max_humans:
		refuse_peer(id, "lobby is full")
		return






	var h1: = 0
	var h2: = 0
	for pid2 in players:
		var row: Dictionary = players[pid2]
		var os: = int(row.get("side", 0))
		if os == 1:
			h1 += 1
		elif os == -1:
			h2 += 1
		for g in locals_of(int(pid2)):
			var gs: = int((g as Dictionary).get("side", os))
			if gs == 1:
				h1 += 1
			elif gs == -1:
				h2 += 1
	players[id] = {"name": player_name, "cfg": cfg, "wr": wr, 
		"sid": steam_id, 












		"qjoin": not returning and ( not quick_modes.is_empty() or quick_queue\
		or (GameConfig.quick_match and in_match)), 


		"ptoken": 0 if returning else ptoken, 


		"pblock": clampi(pblock, 0, PARTY_MAX) if ptoken != 0 and not returning else 0, 




		"qm": quick_modes.slice(0, 6)\
		.filter( func(x): return typeof(x) in [TYPE_INT, TYPE_FLOAT])\
		.map( func(x): return int(x))\
		.filter( func(m): return m in GameConfig.team_sizes()), 



		"lb": clampi(band, 0, QuickPlay.BAND_OPEN), "lw": band_open, 


		"bk": blocks.left(BLOCKS_MAX), 
		"side": 1 if h1 <= h2 else -1}




	var stored_locals: = _derive_locals(player_name, int(players[id].side), locals)
	if not stored_locals.is_empty():
		players[id]["locals"] = stored_locals



	if party and quick_modes.is_empty() and steam_id != 0 and (returning or not quick_queue):
		party_invited[steam_id] = 1
	QuickPlay.qlog("hello ACCEPT peer %d '%s' modes=%s ptoken=%d pblock=%d qjoin=%s party=%s quick_queue=%s quick_match=%s"
		%[id, player_name, str(quick_modes), ptoken, int(players[id].pblock), str(players[id].qjoin), 
		str(party), str(quick_queue), str(GameConfig.quick_match)])
	if not quick_modes.is_empty():
		quick_modes_requested.emit(quick_modes)
















	if party and quick_modes.is_empty() and (returning or ( not quick_queue\
	and not (GameConfig.quick_match and in_match))):
		send_join_party(id)
	_broadcast_lobby()
	lobby_changed.emit()
	if in_match:


		late_joiner.emit(id)




	if steam_id != 0:
		Mod.enforce_peer(id, steam_id)




@rpc("authority", "call_remote", "reliable")
func _s_refused(reason: String) -> void :


	if reason != REGROUP and reason != QUEUE_FULL:
		Mod.on_refused()
	_teardown(reason)




@rpc("authority", "call_remote", "reliable")
func _s_chat_banned(reason: String, expires_unix: int) -> void :
	Mod.set_self_chat_ban(reason, expires_unix)







const HELLO_BURST: = 32
const PW_TRIES: = 3
const PW_WINDOW_MS: = 60000
var _hello_t: = {}
var _hello_peer_t: = {}
var _pw_fail_t: = {}
var _rpc_t: = {}



func _rpc_ok(peer: int, kind: String, limit: int, window_ms: = 1000) -> bool:
	return _rate_ok(_rpc_t, "%d:%s" % [peer, kind], limit, window_ms)

func _rate_ok(bucket: Dictionary, key: Variant, limit: int, window_ms: int, record: = true) -> bool:
	var now: = Time.get_ticks_msec()
	var arr: Array = bucket.get(key, [])
	while not arr.is_empty() and now - int(arr[0]) > window_ms:
		arr.pop_front()
	if arr.size() >= limit:
		bucket[key] = arr
		return false
	if record:
		arr.append(now)
	bucket[key] = arr
	return true

func refuse_peer(id: int, reason: String) -> void :
	if not is_host:
		return
	QuickPlay.qlog("REFUSE peer %d: %s" % [id, reason])
	_s_refused.rpc_id(id, reason)
	players.erase(id)
	_broadcast_lobby()
	lobby_changed.emit()
	var tree: = Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.create_timer(0.5).timeout.connect( func(): _kick_peer(id))
	else:
		_kick_peer(id)



var _peer_heard_ms: = {}
const DUP_LIVE_MS: = 1500
const DUP_SETTLE_S: = 1.6


func _same_sid_peer(sid: int, not_id: int) -> int:
	for pid in players:
		if pid != not_id and pid != 1 and int(players[pid].get("sid", 0)) == sid:
			return int(pid)
	return 0





func _evict_ghost(sid: int, keep_id: int) -> void :
	for old in players.keys():
		if old == keep_id or old == 1 or int(players[old].get("sid", 0)) != sid:
			continue
		players.erase(old)
		_hello_peer_t.erase(old)
		if in_match or practice_live:
			peer_left_match.emit(old)
		_kick_peer(old)





@rpc("any_peer", "call_remote", "reliable")
func _c_bye() -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()
	if players.has(id):
		_on_peer_disconnected(id)

func _kick_peer(id: int) -> void :
	var peer: = multiplayer.multiplayer_peer
	if peer == null or not peer.has_method("disconnect_peer"):
		return


	if not multiplayer.get_peers().has(id):
		return
	peer.disconnect_peer(id)







func host_kick(peer_id: int) -> void :
	if not is_host or peer_id == 1 or not players.has(peer_id):
		return
	if not custom_lobby:
		return
	if DevBadge.is_owner_peer(peer_id):
		return
	var pname: = String((players[peer_id] as Dictionary).get("name", "player"))
	system_message("%s has been kicked by the host" % pname)
	if in_match or practice_live:
		peer_left_match.emit(peer_id)
	refuse_peer(peer_id, "removed by host")

func host_lobby_ban(peer_id: int) -> void :
	if not is_host or peer_id == 1 or not players.has(peer_id):
		return
	if not custom_lobby:
		return
	if DevBadge.is_owner_peer(peer_id):
		return
	var pname: = String((players[peer_id] as Dictionary).get("name", "player"))
	var sid: = int((players[peer_id] as Dictionary).get("sid", 0))
	if sid != 0:
		Mod.lobby_ban(sid)
	system_message("%s has been banned from the lobby" % pname)
	if in_match or practice_live:
		peer_left_match.emit(peer_id)
	refuse_peer(peer_id, "you are banned from this lobby")









const VK_DURATION_MS: = 30000
const VK_COOLDOWN_MS: = 20000
const VK_START_COOLDOWN_MS: = 15000
const VK_MAX_STARTS_PER_SESSION: = 3
const VK_MIN_PEERS: = 3
var _vk_start_cooldown: = 0
var _vk_starts_by: = {}

var _vk_active: = false
var _vk_target: = 0
var _vk_target_sid: = 0
var _vk_target_name: = ""
var _vk_votes: = {}
var _vk_deadline: = 0
var _vk_cooldown: = {}
var _vk_timer: Timer = null

var _vk_open: = false
var _vk_voted: = false

func can_votekick() -> bool:




	return active and not custom_lobby\
	and ( not party or (GameConfig.quick_match and (in_match or quick_queue)))

func votekick_in_progress() -> bool:
	return _vk_open

func votekick_voted() -> bool:
	return _vk_voted


func request_votekick(target_peer: int) -> void :
	if not can_votekick():
		return
	if is_host:
		_host_vk_start(1, target_peer)
	else:
		send_up("vk_start", {"t": target_peer})


func cast_my_votekick(yes: bool) -> void :
	if not _vk_open or _vk_voted:
		return
	_vk_voted = true
	if is_host:
		_host_vk_cast(1, yes)
	else:
		send_up("vk_vote", {"v": yes})


func _host_vk_start(initiator: int, target: int) -> void :
	if not is_host or not can_votekick() or _vk_active:
		return
	if target == initiator or not players.has(target) or not players.has(initiator):
		return
	if DevBadge.is_owner_peer(target):
		return
	if players.size() < VK_MIN_PEERS:
		return
	if DevBadge.is_owner_peer(initiator):
		pass
	elif int(_vk_starts_by.get(initiator, 0)) >= VK_MAX_STARTS_PER_SESSION:
		return
	if Time.get_ticks_msec() < _vk_start_cooldown:
		return
	if Time.get_ticks_msec() < int(_vk_cooldown.get(target, 0)):
		return
	_vk_starts_by[initiator] = int(_vk_starts_by.get(initiator, 0)) + 1
	_vk_active = true
	_vk_target = target
	_vk_target_sid = int((players[target] as Dictionary).get("sid", 0))
	_vk_target_name = String((players[target] as Dictionary).get("name", "player"))
	_vk_votes = {initiator: true}
	_vk_deadline = Time.get_ticks_msec() + VK_DURATION_MS
	_vk_ensure_timer()
	_vk_timer.start(1.0)
	var needed: = _vk_needed()

	_s_vk_open.rpc(target, _vk_target_name, _vk_yes(), needed, VK_DURATION_MS / 1000)
	_vk_apply_open_local(target, _vk_target_name, _vk_yes(), needed, VK_DURATION_MS / 1000)
	system_message("vote to kick %s started -- type /vote yes or /vote no" % _vk_target_name)
	_host_vk_check()

func _host_vk_cast(voter: int, yes: bool) -> void :
	if not is_host or not _vk_active:
		return
	if voter == _vk_target or not players.has(voter):
		return
	if _vk_votes.has(voter):
		return
	_vk_votes[voter] = yes
	var secs: = maxi((_vk_deadline - Time.get_ticks_msec()) / 1000, 0)
	_s_vk_tally.rpc(_vk_yes(), _vk_needed(), secs)
	votekick_updated.emit(_vk_yes(), _vk_needed(), secs)
	_host_vk_check()


func _vk_needed() -> int:
	var others: = maxi(players.size() - 1, 1)
	return others / 2 + 1

func _vk_yes() -> int:
	var n: = 0
	for v in _vk_votes.values():
		if bool(v):
			n += 1
	return n

func _host_vk_check() -> void :
	if not _vk_active:
		return
	if _vk_yes() >= _vk_needed():
		_host_vk_finish(true)
		return

	if _vk_votes.size() >= maxi(players.size() - 1, 1):
		_host_vk_finish(false)

func _host_vk_tick() -> void :
	if not _vk_active:
		return
	var secs: = (_vk_deadline - Time.get_ticks_msec()) / 1000
	if secs <= 0:
		_host_vk_finish(false)
		return
	_s_vk_tally.rpc(_vk_yes(), _vk_needed(), secs)
	votekick_updated.emit(_vk_yes(), _vk_needed(), secs)

func _host_vk_finish(passed: bool) -> void :
	if not _vk_active:
		return
	var target: = _vk_target
	var tsid: = _vk_target_sid
	var tname: = _vk_target_name
	_vk_active = false
	if _vk_timer != null:
		_vk_timer.stop()
	_vk_start_cooldown = Time.get_ticks_msec() + VK_START_COOLDOWN_MS
	if not passed:
		_vk_cooldown[target] = Time.get_ticks_msec() + VK_COOLDOWN_MS

	_s_vk_close.rpc(passed, tname)
	_vk_apply_close_local(passed, tname)
	if not passed:
		system_message("not enough votes to kick %s" % tname)
		return

	if target == 1:


		system_message("%s was voted out -- migrating host" % tname)
		multiplayer.poll()
		var tree: = Engine.get_main_loop() as SceneTree
		if tree != null:
			tree.create_timer(0.25).timeout.connect( func(): leave())
		else:
			leave()
		return




	system_message("%s was voted out" % tname)
	if tsid != 0:
		Mod.lobby_ban(tsid)
	if in_match or practice_live:
		peer_left_match.emit(target)
	refuse_peer(target, "you have been vote kicked from the match")

func _vk_ensure_timer() -> void :
	if _vk_timer == null:
		_vk_timer = Timer.new()
		_vk_timer.one_shot = false
		_vk_timer.timeout.connect(_host_vk_tick)
		add_child(_vk_timer)



func _vk_on_peer_gone(id: int) -> void :
	if not is_host or not _vk_active:
		return
	if id == _vk_target:
		_host_vk_finish(false)
		return
	_vk_votes.erase(id)
	_host_vk_check()


func _vk_reset() -> void :
	_vk_active = false
	_vk_open = false
	_vk_voted = false
	_vk_target = 0
	_vk_votes = {}
	_vk_cooldown = {}
	_vk_start_cooldown = 0
	_vk_starts_by = {}
	if _vk_timer != null:
		_vk_timer.stop()


@rpc("authority", "call_remote", "reliable")
func _s_vk_open(target: int, tname: String, yes: int, needed: int, secs: int) -> void :
	_vk_apply_open_local(target, tname, yes, needed, secs)

@rpc("authority", "call_remote", "reliable")
func _s_vk_tally(yes: int, needed: int, secs: int) -> void :
	votekick_updated.emit(yes, needed, secs)

@rpc("authority", "call_remote", "reliable")
func _s_vk_close(passed: bool, tname: String) -> void :
	_vk_apply_close_local(passed, tname)

func _vk_apply_open_local(target: int, tname: String, yes: int, needed: int, secs: int) -> void :
	_vk_open = true


	_vk_voted = (multiplayer.get_unique_id() == target)
	votekick_opened.emit(target, tname, yes, needed, secs)

func _vk_apply_close_local(passed: bool, tname: String) -> void :
	_vk_open = false
	_vk_voted = false
	votekick_closed.emit(passed, tname)

@rpc("any_peer", "call_remote", "reliable")
func _c_pick_side(side: int) -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()
	if not _rpc_ok(id, "side", 2):
		return


	if players.has(id) and (side == 1 or side == -1 or side == 0):
		players[id].side = side
		_broadcast_lobby()
		lobby_changed.emit()

func pick_side(side: int) -> void :
	if is_host:
		players[1].side = side
		_broadcast_lobby()
		lobby_changed.emit()
	else:
		_c_pick_side.rpc_id(1, side)







func pick_local_side(ls: int, side: int) -> void :
	if is_host:
		_set_local_side(1, ls, side)
	else:
		_c_pick_local_side.rpc_id(1, ls, side)

@rpc("any_peer", "call_remote", "reliable")
func _c_pick_local_side(ls: int, side: int) -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()
	if not _rpc_ok(id, "lside", 3):
		return
	_set_local_side(id, ls, side)







func _derive_locals(owner_name: String, owner_side: int, locals: Array) -> Array:
	var out: Array = []
	for gi in mini(locals.size(), LocalPlayers.MAX_LOCAL - 1):
		var g: Dictionary = locals[gi] if locals[gi] is Dictionary else {}
		var gside: int = int(g.get("side", owner_side))
		if gside != 1 and gside != -1:
			gside = owner_side
		var gname: = "%s[%d]" % [owner_name, gi + 2]

		var gcfg: = TITLES.gate(CharacterConfig.sanitize_dict(g.get("cfg", {})), 0)
		hide_imposter_level(gname, gcfg)
		out.append({
			"ls": gi + 1, 
			"name": gname, 
			"side": gside, 
			"cfg": gcfg, 
		})
	return out











const LOCALS_PUSH_GAP: = 400
var _locals_dirty: = false
var _locals_next_ms: = 0
var locals_pushed_ms: = 0

func push_local_roster() -> void :
	if not active or in_match:
		return
	_locals_dirty = true

func _flush_locals() -> void :
	if not _locals_dirty or Time.get_ticks_msec() < _locals_next_ms:
		return
	_locals_dirty = false
	if not active or in_match or not _has_live_peer():
		return
	_locals_next_ms = Time.get_ticks_msec() + LOCALS_PUSH_GAP
	locals_pushed_ms = Time.get_ticks_msec()
	if is_host:
		_set_locals(1, local_guest_payload())
	else:
		_c_locals_changed.rpc_id(1, local_guest_payload())




func couch_room() -> int:
	if not active:
		return LocalPlayers.MAX_LOCAL - LocalPlayers.count()
	if in_match:
		return 0
	var cap: = MAX_PLAYERS
	if max_humans > 0:
		cap = mini(cap, max_humans)
	if party:
		cap = mini(cap, PARTY_MAX)
	return mini(maxi(cap - human_count(), 0), LocalPlayers.MAX_LOCAL - LocalPlayers.count())

@rpc("any_peer", "call_remote", "reliable")
func _c_locals_changed(locals: Array) -> void :
	if not is_host or in_match:
		return
	var id: = multiplayer.get_remote_sender_id()
	if not players.has(id):
		return
	if not _rpc_ok(id, "locals", 3):
		return
	if not (locals is Array):
		return
	_set_locals(id, locals)





func _set_locals(id: int, locals: Array) -> void :
	if not players.has(id):
		return
	var derived: Array = _derive_locals(String(players[id].name), 
		int(players[id].side), locals)

	var others: = human_count() - (1 + locals_of(id).size())
	var cap: = MAX_PLAYERS
	if max_humans > 0:
		cap = mini(cap, max_humans)
	if party:
		cap = mini(cap, PARTY_MAX)
	var room: = maxi(cap - others - 1, 0)
	if derived.size() > room:
		derived = derived.slice(0, room)
	if derived.is_empty():
		(players[id] as Dictionary).erase("locals")
	else:
		players[id]["locals"] = derived
	_broadcast_lobby()
	lobby_changed.emit()


func _set_local_side(id: int, ls: int, side: int) -> void :
	if not (side == 1 or side == -1 or side == 0):
		return
	if not players.has(id):
		return
	var locs: Array = (players[id] as Dictionary).get("locals", [])
	var i: = ls - 1
	if i < 0 or i >= locs.size():
		return
	(locs[i] as Dictionary).side = side
	_broadcast_lobby()
	lobby_changed.emit()








func shuffle_sides() -> void :
	if not is_host:
		return
	var ids: = players.keys()
	var before: = {}
	for id in ids:
		before[id] = int(players[id].side)
	var dealt: = {}
	for _attempt in 12:
		ids.shuffle()
		dealt = {}
		var count: = {1: 0, -1: 0}
		for id in ids:
			var open: Array = []
			if count[1] < team_size:
				open.append(1)
			if count[-1] < team_size:
				open.append(-1)
			var side: int = 0 if open.is_empty() else int(open[randi() % open.size()])
			dealt[id] = side
			if side != 0:
				count[side] += 1
		if dealt != before:
			break
	for id in ids:
		players[id].side = dealt[id]
	_broadcast_lobby()
	lobby_changed.emit()

func set_team_size(size: int) -> void :
	if is_host:
		team_size = GameConfig.legal_team_size(size)
		_broadcast_lobby()
		lobby_changed.emit()






func build_roster(ids: Array, players: Dictionary, team_size: int, 
		kits: Dictionary, cpus: Dictionary = {}) -> Array:
	var roster: Array = []
	var counts: = {1: 0, -1: 0}
	var watching: Array = []
	for id in ids:




		var seats: Array = [{"ls": 0, "side": int(players[id].side), 
			"name": players[id].name, "cfg": players[id].get("cfg", {})}]
		var locs: Array = (players[id] as Dictionary).get("locals", [])
		var li: = 1
		for g in locs:
			var gd: Dictionary = g
			seats.append({"ls": li, "side": int(gd.get("side", players[id].side)), 
				"name": String(gd.get("name", "")), "cfg": gd.get("cfg", {})})
			li += 1
		for s in seats:
			var side: int = s.side



			if side == 0:


				watching.append({"peer": id, "ls": s.ls, "name": s.name, 
					"side": 0, "slot": -1, "spec": true, 
					"cfg": s.cfg, "kit": kits.get(1, [])})
				continue
			if counts[side] >= team_size:
				watching.append({"peer": id, "ls": s.ls, "name": s.name, 
					"side": side, "slot": -1, "spec": true, 
					"cfg": s.cfg, "kit": kits.get(side, [])})
				continue
			roster.append({"peer": id, "ls": s.ls, "name": s.name, 
				"side": side, "slot": counts[side], 
				"cfg": s.cfg, "kit": kits.get(side, [])})
			counts[side] += 1
	for side in [1, -1]:
		for i in range(counts[side], team_size):
			var e: = {"peer": 0, "ls": 0, "name": "cpu %d" % (i + 1), 
				"side": side, "slot": i, "cfg": {}, "kit": kits.get(side, [])}




			var cpu: = CpuSlots.lookup(cpus, side, i - counts[side])
			if not cpu.is_empty():
				e["cfg"] = cpu.cfg
				e["cname"] = cpu.name
				e["diff"] = cpu.diff
			roster.append(e)



	roster.append_array(watching)
	return roster








func match_roster(ids: Array, players_in: Dictionary, size: int, 
		cpus: Dictionary = {}, wanted: Dictionary = {}, quick: = false) -> Array:
	var roster: = build_roster(ids, players_in, size, {}, cpus)
	TeamKits.dress_roster(roster, {} if quick else wanted, randi() if quick else -1)
	return roster



func preview_captains(size: int, cpus: Dictionary = {}, wanted: Dictionary = {}) -> Dictionary:
	var ids: = players.keys()
	ids.sort()
	return TeamKits.pick_roster(build_roster(ids, players, size, {}, cpus), wanted)



func captain_kits(players_in: Dictionary) -> Dictionary:
	var ids: = players_in.keys()
	ids.sort()
	var res: = TeamKits.pick_roster(build_roster(ids, players_in, team_size, {}), {}, randi())
	return {1: TeamKits.to_html(res.kits[1]), -1: TeamKits.to_html(res.kits[-1])}



func set_captain(side: int, key: String) -> void :
	if (active and not is_host) or not (side == 1 or side == -1):
		return
	if key == "":
		captains.erase(side)
	else:
		captains[side] = key

		if String(captains.get( - side, "")) == key:
			captains.erase( - side)
	_broadcast_lobby()
	lobby_changed.emit()


static func sanitize_captains(raw: Variant) -> Dictionary:
	var out: = {}
	if not (raw is Dictionary):
		return out
	for side in [1, -1]:
		var v: Variant = (raw as Dictionary).get(side, "")
		if v is String and (v as String).length() <= 32 and v != "":
			out[side] = v
	return out

func set_cpu_difficulty(level: int) -> void :
	if is_host:
		cpu_difficulty = clampi(level, 0, 2)

		CpuSlots.set_all_diff(cpu_slots, cpu_difficulty)
		_broadcast_lobby()
		lobby_changed.emit()


func set_cpu_slots(slots: Dictionary) -> void :
	if is_host:
		cpu_slots = slots
		_broadcast_lobby()
		lobby_changed.emit()




func sync_lobby() -> void :
	if is_host:
		_broadcast_lobby()
		lobby_changed.emit()



func set_tod(index: int) -> void :
	if is_host:
		rule_tod = clampi(index, 0, 3)
		_broadcast_lobby()
		lobby_changed.emit()



func set_outfit(index: int) -> void :
	if is_host:
		rule_outfit = DressCode.clamp_rule(index)
		_broadcast_lobby()
		lobby_changed.emit()

func set_stage(id: String) -> void :
	if is_host:
		stage = CLOUD_STAGE if cloud_session() else Stage.resolve(id)
		_broadcast_lobby()
		lobby_changed.emit()




func _has_live_peer() -> bool:
	var p: = multiplayer.multiplayer_peer
	return p != null and not (p is OfflineMultiplayerPeer)

func _broadcast_lobby() -> void :
	if not _has_live_peer():
		return



	var shared: = {}
	for pid in players:
		var row: Dictionary = (players[pid] as Dictionary).duplicate()
		row.erase("wr")
		row.erase("ptoken")
		row.erase("lb")
		row.erase("lw")
		row.erase("bk")
		shared[pid] = row



	_s_lobby.rpc(shared, team_size, cpu_difficulty, stage, session_token, 
		{"pts": rule_points, "sets": rule_sets, "wbt": rule_wbt, 
		"sweat": rule_sweat, "rate": rule_rate, 
		"replays": rule_replays, "collide": rule_collide, 
		"serve": rule_serve, "hints": rule_hints, "lock": rule_lock, 
		"rotate": rule_rotate, "intro": rule_intro, "tod": rule_tod, "outfit": rule_outfit, 
		"prac": practice, "pcol": practice_collide, "pcall": practice_call_all, 
		"psize": practice_size, 
		"code": shared_lobby_code(), 



		"blocked": Mod.lobby_bans_export(), 


		"caps": {1: String(captains.get(1, "")), -1: String(captains.get(-1, ""))}, 

		"ppriv": party_privacy, 




		"room": custom_lobby}, 
		cpu_slots)



	if _steam != null and steam_lobby_id != 0:
		_steam.setLobbyData(steam_lobby_id, "humans", str(human_count()))
		_steam.setLobbyData(steam_lobby_id, "cap", 
			str(max_humans if max_humans > 0 else MAX_PLAYERS))
		_publish_court_slots(steam_lobby_id)






func _publish_court_slots(lobby_id: int) -> void :
	_steam.setLobbyData(lobby_id, "size", str(team_size))
	_steam.setLobbyData(lobby_id, "seated", str(seated_humans()))

@rpc("authority", "call_remote", "reliable")
func _s_lobby(lobby_players: Dictionary, size: int, cpu_diff: int, 
		stage_id: = "nationals", token: = 0, rules: = {}, cpus: = {}) -> void :


	if lobby_players.size() > MAX_PLAYERS * 2:
		return
	for k in lobby_players:
		if not (k is int) or not (lobby_players[k] is Dictionary):
			return
	if size < 1 or size > 6:
		return
	players = lobby_players
	_gate_roster_titles()
	team_size = GameConfig.legal_team_size(size)
	cpu_difficulty = cpu_diff
	stage = Stage.resolve(stage_id)
	if token != 0:
		session_token = token
	if not rules.is_empty():
		rule_points = int(rules.get("pts", rule_points))
		rule_sets = int(rules.get("sets", rule_sets))
		rule_wbt = bool(rules.get("wbt", rule_wbt))
		rule_sweat = bool(rules.get("sweat", rule_sweat))
		rule_rate = float(rules.get("rate", rule_rate))



		rule_replays = bool(rules.get("replays", rule_replays))
		rule_collide = bool(rules.get("collide", rule_collide))
		rule_serve = clampi(int(rules.get("serve", rule_serve)), 5, 60)
		rule_hints = bool(rules.get("hints", rule_hints))
		rule_lock = bool(rules.get("lock", rule_lock))
		rule_rotate = bool(rules.get("rotate", rule_rotate))
		rule_intro = bool(rules.get("intro", rule_intro))
		rule_tod = clampi(int(rules.get("tod", rule_tod)), 0, 3)
		rule_outfit = DressCode.clamp_rule(int(rules.get("outfit", 0)))
		practice = bool(rules.get("prac", false))
		practice_collide = bool(rules.get("pcol", true))
		practice_call_all = bool(rules.get("pcall", true))
		practice_size = clampi(int(rules.get("psize", 6)), 1, PRACTICE_SIZE)






		if rules.has("code"):
			remote_lobby_code = String(rules.get("code", ""))


		if rules.has("blocked") and rules["blocked"] is Array:
			Mod.lobby_bans_sync(rules["blocked"])
		if rules.has("caps"):
			captains = sanitize_captains(rules["caps"])
		if rules.has("room"):
			custom_lobby = bool(rules["room"])


		if party and rules.has("ppriv"):
			party_privacy = clampi(int(rules.get("ppriv", party_privacy)), 0, 
				PartyPriv.size() - 1)
	cpu_slots = CpuSlots.sanitize(cpus)
	_client_check_host_ban()
	_refresh_connect()
	lobby_changed.emit()







var _host_ban_checked: = false

func _client_check_host_ban() -> void :
	if is_host or _host_ban_checked or not active:
		return
	var hsid: = int((players.get(1, {}) as Dictionary).get("sid", 0))
	if hsid == 0:
		return
	_host_ban_checked = true
	Mod.check_bans(hsid, func(res):
		if active and not is_host and bool(res.get("online", false)):
			_teardown(Mod.DEMO_ENDED_TEXT if bool(res.get("demo_ended", false))
				else "this lobby's host is banned from online play"))



var match_ready_peers: = {}

func start_match(roster: Array, seed: int, is_practice: = false) -> void :
	if cloud_session() and is_host:
		multiplayer.multiplayer_peer.refuse_new_connections = true






	practice = is_practice
	_begin_session(practice)
	match_ready_peers = {}
	GameConfig.match_seed = seed


	if _steam != null and steam_lobby_id != 0 and not practice:
		_steam.setLobbyData(steam_lobby_id, "state", "game")
		_steam.setLobbyData(steam_lobby_id, "mode", 
			"%dv%d" % [team_size, team_size])
		_steam.setLobbyData(steam_lobby_id, "map", Stage.title(stage))
		_steam.setLobbyData(steam_lobby_id, "stage", stage)





	if _has_live_peer():
		_s_start.rpc(roster, seed, stage, GameConfig.quick_match, is_practice)
	match_started.emit(roster)

func notify_match_ready() -> void :

	_c_match_ready.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func _c_match_ready() -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()
	if match_ready_peers.get(id, false) or not _rpc_ok(id, "ready", 2):
		return
	match_ready_peers[id] = true
	peer_match_ready.emit(id)

@rpc("authority", "call_remote", "reliable")
func _s_start(roster: Array, seed: int, stage_id: = "", quick: = false, 
		prac: = false) -> void :
	if not roster_ok(roster):
		return
	_gate_match_titles(roster)
	practice = prac
	_begin_session(practice)
	GameConfig.match_seed = seed
	if stage_id != "":
		stage = Stage.resolve(stage_id)







	GameConfig.quick_match = quick






	if not prac:
		pending_start = roster
		_pull_into_match()
	match_started.emit(roster)



var pending_start: Array = []
const _MATCH_START_SCENES: = ["res://game/mobile/mobile_main.tscn", "res://game/mobile/mobile_match_loader.tscn", "res://game/mobile/mobile_menu.tscn", "res://game/ui/menu.tscn", "res://game/main/main.tscn",
	"res://game/net/lobby.tscn"]

func _pull_into_match() -> void :
	var sc: = get_tree().current_scene
	if sc == null or sc.scene_file_path in _MATCH_START_SCENES:
		return
	QuickPlay.qlog("match started while on %s: back through the menu" % sc.scene_file_path)

	if sc.has_method("leave_for_match"):
		sc.call("leave_for_match")
	else:
		GameConfig.goto_scene("res://game/ui/menu.tscn")




func _begin_session(is_practice: bool) -> void :
	if is_practice:
		practice_live = true
	else:
		practice_live = false
		in_match = true
		quick_queue = false




func end_practice() -> void :
	practice_live = false
	if is_host and practice:
		practice = false
		_broadcast_lobby()

func end_match() -> void :
	if cloud_session() and is_host:
		multiplayer.multiplayer_peer.refuse_new_connections = false
	in_match = false
	practice_live = false
	if is_host and practice:
		practice = false
		_broadcast_lobby()
	quick_backfill_ad(0)
	if is_host:






		if party:
			for pid in players.keys():

				if pid != 1 and bool(players[pid].get("qjoin", false)):
					refuse_peer(pid, "the host left the match")

		_broadcast_lobby()





	quick_seek_visible(false)
	if _steam != null and steam_lobby_id != 0:
		_steam.setLobbyData(steam_lobby_id, "state", "lobby")



var _lobby_kind: = "custom"





func mark_lobby_hidden() -> void :
	_lobby_kind = "locked"









signal party_joined

var party: = false
const PARTY_MAX: = 6










enum PartyPriv{OPEN, PRIVATE}
const PARTY_PRIV_NAMES: = ["open", "private"]
var party_privacy: int = PartyPriv.OPEN



var party_invited: = {}

signal party_invite_result(sid: int, ok: bool, reason: String)

func set_party_privacy(level: int) -> void :
	if not is_host:
		return
	party_privacy = clampi(level, 0, PartyPriv.size() - 1)
	if party_privacy == PartyPriv.PRIVATE:


		var here: = {}
		for pid in players:
			here[int((players[pid] as Dictionary).get("sid", 0))] = true
		for sid in party_invited.keys():
			if int(party_invited[sid]) != 1 and not here.has(sid):
				party_invited.erase(sid)
	_apply_party_lobby_type()
	_broadcast_lobby()
	lobby_changed.emit()



func can_invite_to_party() -> bool:
	if not party or not active or i_am_fold():
		return false
	return is_host or party_privacy == PartyPriv.OPEN



func _party_invite_refusal(from_id: int, sid: int) -> String:
	if not party or not is_host:
		return "you're not in a party"
	if from_id != 1:
		if not players.has(from_id) or bool((players[from_id] as Dictionary).get("qjoin", false)):
			return "you're not in this party"
		if party_privacy != PartyPriv.OPEN:
			return "private party: only the leader can invite"

	if quick_queue or (GameConfig.quick_match and in_match):
		return "can't invite while the party is matchmaking"
	if human_count() >= PARTY_MAX:
		return "party is full"
	if sid != 0:
		if sid == my_steam_id():
			return "that's you"
		for pid in players:
			if int((players[pid] as Dictionary).get("sid", 0)) == sid:
				return "already in the party"
	return ""



func request_party_invite(sid: int) -> void :
	if not party or not active:
		party_invite_result.emit(sid, false, "you're not in a party")
		return
	if is_host:
		var why: = _party_invite_refusal(1, sid)
		if why == "" and sid != 0:
			party_invited[sid] = 1
			if _steam != null and steam_lobby_id != 0\
			and _steam.has_method("inviteUserToLobby"):
				_steam.inviteUserToLobby(steam_lobby_id, sid)
		party_invite_result.emit(sid, why == "", why)
		return
	send_up("pinv", {"s": sid})


func _host_party_invite(from_id: int, sid: int) -> void :
	var why: = _party_invite_refusal(from_id, sid)
	if why == "" and sid != 0:
		party_invited[sid] = from_id
	QuickPlay.qlog("party invite from %d for %d: %s" % [from_id, sid, 
		"ok" if why == "" else why])
	if _has_live_peer() and multiplayer.get_peers().has(from_id):
		_s_party_invite_r.rpc_id(from_id, sid, why == "", why)





@rpc("authority", "call_remote", "reliable")
func _s_party_invite_r(sid: int, ok: bool, reason: String) -> void :
	_recv( func():
		if ok and sid != 0:
			_steam_send_party_invite(sid)
		party_invite_result.emit(sid, ok, reason.substr(0, 96)))

func _steam_send_party_invite(sid: int) -> void :
	var hsid: = int((players.get(1, {}) as Dictionary).get("sid", 0))
	if _steam == null or hsid == 0 or not _steam.has_method("inviteUserToGame"):
		return
	_steam.inviteUserToGame(sid, "+connect_party %d" % hsid)



func _on_steam_game_join_requested(_user_id: = 0, connect: = "") -> void :
	_dial_connect_string(String(connect))

func _dial_connect_string(connect: String) -> void :
	var parts: = connect.strip_edges().split(" ", false)
	if parts.size() < 2 or not String(parts[1]).is_valid_int():
		return
	var target: = int(parts[1])
	if parts[0] == "+connect_lobby":
		_on_steam_join_requested(target, 0)
	elif parts[0] == "+connect_party" and target != 0 and target != my_steam_id():

		var pass_word: = String(parts[2]) if parts.size() > 2 else ""
		var do_join: = func():
			invite_accepting.emit()
			join_game_steam(target, local_display_name())
			join_password = pass_word
		if OnlineTerms.require(do_join):
			do_join.call()







func _on_steam_lobby_chat_update(lobby_id: = 0, changed_id: = 0, 
		_making_change_id: = 0, chat_state: = 0) -> void :
	if not party or not is_host or quick_queue or lobby_id != steam_lobby_id:
		return
	if (int(chat_state) & 1) != 0 and int(changed_id) != 0\
	and int(changed_id) != my_steam_id():
		party_invited[int(changed_id)] = 1




func _party_door_refusal(steam_id: int, pw: = "") -> String:
	if not party:
		return ""
	var enforce: = (_steam != null and not party_lan) or _party_door_test()
	if not enforce:
		return ""



	if party_privacy == PartyPriv.OPEN and pw != "" and pw == party_open_pass():
		return ""
	if steam_id == 0 or not party_invited.has(steam_id):
		return "this party is invite-only"
	return ""








func party_open_pass() -> String:
	return "P%06X" % (session_token & 16777215) if session_token != 0 else ""

func party_connect_string() -> String:
	if not active or not party or party_privacy != PartyPriv.OPEN\
	or quick_queue or i_am_fold() or party_lan:
		return ""
	var hsid: = my_steam_id() if is_host\
	else int((players.get(1, {}) as Dictionary).get("sid", 0))
	if hsid == 0 or party_open_pass() == "":
		return ""
	return "+connect_party %d %s" % [hsid, party_open_pass()]

var _presence_connect: = ""
func _refresh_connect() -> void :
	if _steam == null or not _steam.has_method("setRichPresence"):
		return
	var c: = party_connect_string()
	if c == _presence_connect:
		return
	_presence_connect = c
	_steam.setRichPresence("connect", c)

static func _party_door_test() -> bool:
	return OS.has_feature("editor") and "--party-door" in LaunchGate.dev_args()





func _apply_party_lobby_type() -> void :
	if not party or _steam == null or steam_lobby_id == 0:
		return
	if _steam.has_method("setLobbyType"):
		_steam.setLobbyType(steam_lobby_id, 
			1 if party_privacy == PartyPriv.OPEN else 0)
	if _steam.has_method("setLobbyJoinable"):
		_steam.setLobbyJoinable(steam_lobby_id, true)
	_refresh_connect()








func quick_seek_visible(on: bool) -> void :
	if not party or _steam == null or steam_lobby_id == 0:
		return
	if on:
		if _steam.has_method("setLobbyType"):
			_steam.setLobbyType(steam_lobby_id, 2)
	else:
		_apply_party_lobby_type()


		_steam.setLobbyData(steam_lobby_id, "kind", _lobby_kind)





func host_party(player_name: String, force_lan: = false, resume: = false) -> Error:
	var keep_invited: = party_invited.duplicate() if resume else {}
	var keep_priv: int = party_privacy if resume else PartyPriv.OPEN
	if not resume:
		party_home_tokens = {}
		party_expect = {}



	if not force_lan and not steam_transport_available():
		return ERR_UNAVAILABLE
	var err: = host_game(player_name) if force_lan else host_game_steam(player_name)
	if err == OK:
		party = true





		privacy = Priv.PUBLIC
		password = ""
		party_privacy = keep_priv
		party_invited = keep_invited
		_lobby_kind = "party"
		party_lan = force_lan
	return err








func i_am_fold() -> bool:
	if not active or is_host:
		return false
	var me: Dictionary = players.get(multiplayer.get_unique_id(), {})
	return bool(me.get("qjoin", false))




func drop_folds(reason: String) -> void :
	if not is_host or not party:
		return
	for pid in players.keys():
		if pid != 1 and bool(players[pid].get("qjoin", false)):
			refuse_peer(pid, reason)

func party_members() -> Array:
	if not party:
		return []
	var out: Array = []
	for pid in players:
		if not bool(players[pid].get("qjoin", false)):
			out.append(pid)
	return out





func party_mates() -> Array:
	var out: Array = []
	for pid in party_members():
		var row: Dictionary = players[pid]
		var mate: = {"name": String(row.get("name", "")), "leader": int(pid) == 1, 
			"cfg": row.get("cfg", {}) if row.get("cfg", {}) is Dictionary else {}}
		if int(pid) == 1:
			out.push_front(mate)
		else:
			out.append(mate)
	return out



func _party_humans() -> int:
	var n: = 0
	for pid in party_members():
		n += 1 + locals_of(int(pid)).size()
	return n

func send_join_party(id: int) -> void :
	if is_host:
		_s_join_party.rpc_id(id)








signal party_became_room
func room_from_party() -> void :
	if not (party and is_host):
		return
	drop_folds("the party opened a room")






	home_party = {"is_leader": true, "token": session_token, "room": true, 
		"lan": party_lan, "block": party_members().size(), "mates": party_mates()}
	party = false
	custom_lobby = true
	_lobby_kind = "custom"
	if _steam != null and steam_lobby_id != 0:

		if _steam.has_method("setLobbyType"):
			_steam.setLobbyType(steam_lobby_id, 2)
		if _steam.has_method("setLobbyJoinable"):
			_steam.setLobbyJoinable(steam_lobby_id, true)
		_steam.setLobbyData(steam_lobby_id, "kind", _lobby_kind)
		_steam.setLobbyData(steam_lobby_id, "locked", 
			"1" if privacy == Priv.PASSWORD else "0")
		_steam.setLobbyData(steam_lobby_id, "priv", 
			["public", "friends", "password"][privacy])
		_steam.setLobbyData(steam_lobby_id, "cap", 
			str(max_humans if max_humans > 0 else MAX_PLAYERS))
	_refresh_connect()
	if _has_live_peer():
		_s_room_from_party.rpc()
	_broadcast_lobby()
	lobby_changed.emit()
	party_became_room.emit()

@rpc("authority", "call_remote", "reliable")
func _s_room_from_party() -> void :
	_recv( func():


		if not i_am_fold():
			home_party = {"is_leader": false, 
				"leader_sid": int((players.get(1, {}) as Dictionary).get("sid", 0)), 
				"leader_ip": _last_join_ip, "token": 0, "room": true, 
				"mates": party_mates(), "lan": lan_session()}
		party = false
		custom_lobby = true
		party_became_room.emit())



func kick_from_party(id: int) -> void :
	if is_host and id != 1 and players.has(id):


		party_invited.erase(int((players[id] as Dictionary).get("sid", 0)))
		refuse_peer(id, "removed from the party")










signal party_travel_to(host_id: int, code: String)

signal party_home_called(leader_sid: int)





func send_party_home() -> void :
	if not active:
		return
	var sid: = my_steam_id()
	if is_host:
		_s_party_home.rpc(sid)
	else:
		_c_party_home.rpc_id(1, sid)



	multiplayer.poll()

@rpc("any_peer", "call_remote", "reliable")
func _c_party_home(leader_sid: int) -> void :
	if not is_host:
		return
	_s_party_home.rpc(leader_sid)

@rpc("authority", "call_remote", "reliable")
func _s_party_home(leader_sid: int) -> void :
	party_home_called.emit(leader_sid)





func rehome_party(host_id: int, host_ip: String, modes: Array, token: int, 
		pw: = "", block: = 0) -> void :
	if is_host:
		_s_rehome.rpc(host_id, host_ip, modes, token, pw.substr(0, 64), block)



func rehome_peer(id: int, host_id: int, host_ip: String, modes: Array, token: int, 
		block: = 0) -> void :
	if is_host and _has_live_peer() and multiplayer.get_peers().has(id):
		_s_rehome.rpc_id(id, host_id, host_ip, modes, token, "", block)

@rpc("authority", "call_remote", "reliable")
func _s_rehome(host_id: int, host_ip: String, modes: Array, token: int, 
		pw: = "", block: = 0) -> void :
	_recv( func(): _do_rehome(host_id, host_ip, modes, token, pw, block))

func _do_rehome(host_id: int, host_ip: String, modes: Array, token: int, 
		pw: = "", block: = 0) -> void :




	home_party = {
		"is_leader": false, 
		"leader_sid": int((players.get(1, {}) as Dictionary).get("sid", 0)), 
		"leader_ip": _last_join_ip, 
		"token": token, 



		"room": modes.is_empty() and token == 0, 
		"mates": party_mates(), 



		"lan": lan_session(), 
	}


	quick_join_modes = modes.duplicate()
	quick_party_token = token
	quick_party_block = block if token != 0 else 0
	join_password = pw
	var ok: = false
	if host_id != 0:
		ok = join_game_steam(host_id, my_name) == OK
	elif host_ip != "":
		ok = join_game(host_ip, my_name) == OK
	QuickPlay.qlog("rehome -> %s/%d token=%d ok=%s" % [host_ip, host_id, token, str(ok)])
	if not ok:


		home_party = {}
		_teardown("couldn't join the match")

@rpc("authority", "call_remote", "reliable")
func _s_join_party() -> void :

	party = true
	custom_lobby = false
	quick_queue = false
	_refresh_connect()
	party_joined.emit()






signal freeplay_pose(peer_id: int, st: PackedFloat32Array)

func send_freeplay_pose(st: PackedFloat32Array) -> void :



	if not active or not party or multiplayer.multiplayer_peer == null:
		return
	if is_host:
		_s_freeplay_pose.rpc(1, st)
	else:
		_c_freeplay_pose.rpc_id(1, st)





@rpc("any_peer", "call_remote", "unreliable")
func _c_freeplay_pose(st: PackedFloat32Array) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()
	if not party or not players.has(sid) or not _rpc_ok(sid, "pose", 100)\
	or bool(players[sid].get("qjoin", false)):
		return
	if not pose_ok(st, Player.NET_FLOATS):
		return
	freeplay_pose.emit(sid, st)
	_s_freeplay_pose.rpc(sid, st)

@rpc("authority", "call_remote", "unreliable")
func _s_freeplay_pose(peer_id: int, st: PackedFloat32Array) -> void :
	if pose_ok(st, Player.NET_FLOATS):
		freeplay_pose.emit(peer_id, st)


static func pose_ok(st: PackedFloat32Array, need: int) -> bool:
	if st.size() < need or st.size() > 96:
		return false
	for v in st:
		if not is_finite(v):
			return false
	return true






signal ball_pose(peer_id: int, st: PackedFloat32Array, bid: int)

func send_ball_pose(st: PackedFloat32Array, bid: int) -> void :
	if not active or not party or multiplayer.multiplayer_peer == null:
		return
	if is_host:
		_s_ball_pose.rpc(1, st, bid)
	else:
		_c_ball_pose.rpc_id(1, st, bid)

@rpc("any_peer", "call_remote", "unreliable")
func _c_ball_pose(st: PackedFloat32Array, bid: int) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()
	if not party or not players.has(sid) or not _rpc_ok(sid, "bpose", 100)\
	or bool(players[sid].get("qjoin", false)):
		return
	if not pose_ok(st, 7) or not players.has(bid):
		return
	ball_pose.emit(sid, st, bid)
	_s_ball_pose.rpc(sid, st, bid)

@rpc("authority", "call_remote", "unreliable")
func _s_ball_pose(peer_id: int, st: PackedFloat32Array, bid: int) -> void :
	if pose_ok(st, 7) and players.has(bid):
		ball_pose.emit(peer_id, st, bid)



signal freeplay_fx(peer_id: int, kind: int, pos: Vector3, power: float, vel: Vector3)

func send_freeplay_fx(kind: int, pos: Vector3, power: float, vel: Vector3) -> void :
	if not active or not party:
		return
	if is_host:
		_s_freeplay_fx.rpc(1, kind, pos, power, vel)
	else:
		_c_freeplay_fx.rpc_id(1, kind, pos, power, vel)

@rpc("any_peer", "call_remote", "reliable")
func _c_freeplay_fx(kind: int, pos: Vector3, power: float, vel: Vector3) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()


	if not party or not players.has(sid) or not _rpc_ok(sid, "fx", 10)\
	or bool(players[sid].get("qjoin", false)):
		return
	if not (pos.is_finite() and vel.is_finite() and is_finite(power)):
		return


	freeplay_fx.emit(sid, kind, pos, clampf(power, 0.0, 2.0), vel)
	_s_freeplay_fx.rpc(sid, kind, pos, clampf(power, 0.0, 2.0), vel)

@rpc("authority", "call_remote", "reliable")
func _s_freeplay_fx(peer_id: int, kind: int, pos: Vector3, power: float, 
		vel: Vector3) -> void :
	freeplay_fx.emit(peer_id, kind, pos, power, vel)



signal party_look(peer_id: int, outfit: String)

func send_party_look(outfit: String) -> void :




	if not active:
		return



	var cfg: = local_character_dict()
	if is_host:
		if players.has(1):
			players[1]["cfg"] = cfg
			hide_imposter_level(String(players[1].get("name", "")), players[1]["cfg"])
			players[1]["outfit"] = outfit






		if multiplayer.has_multiplayer_peer():
			_s_party_look.rpc(1, outfit, cfg)
	elif multiplayer.has_multiplayer_peer():
		_c_party_look.rpc_id(1, outfit, cfg)

@rpc("any_peer", "call_remote", "reliable")
func _c_party_look(outfit: String, cfg: Dictionary) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()
	cfg = TITLES.gate(CharacterConfig.sanitize_dict(cfg), _roster_sid(sid))
	hide_imposter_level(String((players.get(sid, {}) as Dictionary).get("name", "")), cfg)
	if not _rate_ok(_look_t, sid, 4, 2000):
		return
	if players.has(sid):
		players[sid]["cfg"] = cfg
		if outfit in ["gym", "captain", "pinny"]:
			players[sid]["outfit"] = outfit
	party_look.emit(sid, outfit)
	_s_party_look.rpc(sid, outfit, cfg)

@rpc("authority", "call_remote", "reliable")
func _s_party_look(peer_id: int, outfit: String, cfg: Dictionary) -> void :
	if players.has(peer_id):
		players[peer_id]["cfg"] = TITLES.gate(cfg, _roster_sid(peer_id))
		hide_imposter_level(String(players[peer_id].get("name", "")), players[peer_id]["cfg"])
		if outfit in ["gym", "captain", "pinny"]:
			players[peer_id]["outfit"] = outfit
	party_look.emit(peer_id, outfit)



func _roster_sid(peer_id: int) -> int:
	return int((players.get(peer_id, {}) as Dictionary).get("sid", 0))





func _gate_roster_titles() -> void :
	for id in players:
		var entry: = players[id] as Dictionary
		if entry.get("cfg") is Dictionary:
			TITLES.gate(entry["cfg"], int(entry.get("sid", 0)))

		hide_imposter_level(String(entry.get("name", "")), entry.get("cfg"))
		for g in locals_of(int(id)):
			if g is Dictionary:
				hide_imposter_level(String((g as Dictionary).get("name", "")), (g as Dictionary).get("cfg"))




signal party_ball(peer_id: int, skin: String)

func send_party_ball(skin: String) -> void :


	if not active or not party or not multiplayer.has_multiplayer_peer():
		return
	if is_host:
		if players.has(1):
			players[1]["ball"] = skin
		_s_party_ball.rpc(1, skin)
	else:
		_c_party_ball.rpc_id(1, skin)

@rpc("any_peer", "call_remote", "reliable")
func _c_party_ball(skin: String) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()
	if not party or not players.has(sid) or not _rpc_ok(sid, "ball", 2, 2000):
		return
	if skin.length() > 32 or not Stage.STAGES.has(skin):
		return
	players[sid]["ball"] = skin
	party_ball.emit(sid, skin)
	_s_party_ball.rpc(sid, skin)

@rpc("authority", "call_remote", "reliable")
func _s_party_ball(peer_id: int, skin: String) -> void :
	if players.has(peer_id):
		players[peer_id]["ball"] = skin
	party_ball.emit(peer_id, skin)




signal party_stage(stage_id: String)

func send_party_stage(stage_id: String) -> void :
	if not active or not party:
		return
	if is_host:
		_s_party_stage.rpc(stage_id)
	else:
		_c_party_stage.rpc_id(1, stage_id)

@rpc("any_peer", "call_remote", "reliable")
func _c_party_stage(stage_id: String) -> void :
	if not is_host:
		return
	var sid: = multiplayer.get_remote_sender_id()


	if not party or not players.has(sid) or not _rpc_ok(sid, "stage", 1, 2000):
		return
	if not Stage.in_build(stage_id) or bool(Stage.info(stage_id).get("hidden", false)):
		return
	party_stage.emit(stage_id)
	_s_party_stage.rpc(stage_id)

@rpc("authority", "call_remote", "reliable")
func _s_party_stage(stage_id: String) -> void :


	if not party:
		return
	party_stage.emit(stage_id)







signal late_joiner(id: int)



const PRACTICE_SIZE: = 6

func send_late_join(id: int, roster: Array, auto_side: int) -> void :
	if is_host:
		var prac: = practice_live and practice
		_s_join_match.rpc_id(id, roster, stage, 
			PRACTICE_SIZE if prac else team_size, auto_side, 
			GameConfig.match_seed, GameConfig.quick_match, prac)

@rpc("authority", "call_remote", "reliable")
func _s_join_match(roster: Array, stage_id: String, size: int, 
	auto_side: = 0, seed: = 0, quick: = false, prac: = false) -> void :
	if not roster_ok(roster) or size < 1 or size > 6:
		return
	_gate_match_titles(roster)
	practice = prac
	_begin_session(practice)
	if not prac:
		team_size = GameConfig.legal_team_size(size)
	if stage_id != "":
		stage = Stage.resolve(stage_id)


	if seed != 0:
		GameConfig.match_seed = seed
	GameConfig.quick_backfill_side = auto_side


	GameConfig.quick_match = quick
	match_started.emit(roster)



func _gate_match_titles(roster: Array) -> void :
	for e in roster:
		var entry: = e as Dictionary
		if entry.get("cfg") is Dictionary:
			var seat_owner: = int(entry.get("ls", 0)) == 0
			TITLES.gate(entry["cfg"], _roster_sid(int(entry.get("peer", 0))) if seat_owner else 0)
			hide_imposter_level(String(entry.get("name", "")), entry["cfg"])



const ROSTER_MAX: = MAX_PLAYERS * 2
static func roster_ok(roster: Array) -> bool:
	if roster.size() > ROSTER_MAX:
		return false
	for e in roster:
		if not (e is Dictionary):
			return false
		if not ((e as Dictionary).get("peer", 0) is int) or not ((e as Dictionary).get("side", 0) is int):
			return false
	return true



func _delay_half() -> int:
	return int(fake_latency_ms / 2.0)




func _delay_one() -> int:
	var d: = int(fake_latency_ms / 2.0)
	if fake_jitter_ms > 0:
		d += randi() % (fake_jitter_ms + 1)
	return d

func _send(fn: Callable) -> void :





	if not _can_send():
		return
	if fake_latency_ms <= 0 and fake_jitter_ms <= 0:
		fn.call()
	else:
		_out_queue.append({"at": Time.get_ticks_msec() + _delay_one(), "fn": fn})

func _can_send() -> bool:
	return active and multiplayer.multiplayer_peer != null\
	and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer)\
	and multiplayer.multiplayer_peer.get_connection_status()\
	== MultiplayerPeer.CONNECTION_CONNECTED

func _recv(fn: Callable) -> void :
	if fake_latency_ms <= 0 and fake_jitter_ms <= 0:
		fn.call()
	else:
		_in_queue.append({"at": Time.get_ticks_msec() + _delay_one(), "fn": fn})





func ping_host() -> void :
	if is_host or not active:
		return
	_send( func(): _c_ping.rpc_id(1, Time.get_ticks_msec()))

@rpc("any_peer", "call_remote", "unreliable")
func _c_ping(t: int) -> void :
	if not is_host:
		return
	var who: = multiplayer.get_remote_sender_id()
	if not _rpc_ok(who, "ping", 8):
		return
	_peer_heard_ms[who] = Time.get_ticks_msec()
	_recv( func(): _send( func(): _s_pong.rpc_id(who, t)))

@rpc("authority", "call_remote", "unreliable")
func _s_pong(t: int) -> void :
	_recv( func():
		var sample: = float(Time.get_ticks_msec() - t)

		_rtt_ms = sample if _rtt_ms <= 0.0 else lerpf(_rtt_ms, sample, 0.2)


		_send( func(): _c_rtt.rpc_id(1, _rtt_ms)))

@rpc("any_peer", "call_remote", "unreliable")
func _c_rtt(ms: float) -> void :
	var who: = multiplayer.get_remote_sender_id()

	var safe: = clampf(ms, 0.0, 600.0) if is_finite(ms) else 0.0
	_recv( func(): _peer_rtt[who] = safe)

func send_input(data: Dictionary, ls: = 0) -> void :



	if is_host or not active:
		return
	if fake_loss_pct > 0 and randi() % 100 < fake_loss_pct:
		return


	_send( func(): _c_input.rpc_id(1, data, ls))

@rpc("any_peer", "call_remote", "unreliable_ordered")
func _c_input(data: Dictionary, ls: = 0) -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()


	if not _rpc_ok(id, "input", 100 * LocalPlayers.MAX_LOCAL):
		return
	ls = clampi(ls, 0, LocalPlayers.MAX_LOCAL - 1)
	_recv( func(): input_received.emit(id, ls, data))

func send_snapshot(data: Dictionary) -> void :
	if fake_loss_pct > 0 and randi() % 100 < fake_loss_pct:
		return


	var bytes: = StateCodec.encode_snapshot(data)
	_send( func(): _s_snapshot.rpc(bytes))




signal ball_snapshot_received(b: PackedFloat32Array)

func send_ball_snapshot(b: PackedFloat32Array) -> void :
	if fake_loss_pct > 0 and randi() % 100 < fake_loss_pct:
		return
	_send( func(): _s_ball_snapshot.rpc(b))

@rpc("authority", "call_remote", "unreliable_ordered")
func _s_ball_snapshot(b: PackedFloat32Array) -> void :
	_recv( func(): ball_snapshot_received.emit(b))

@rpc("authority", "call_remote", "unreliable_ordered")
func _s_snapshot(bytes: PackedByteArray) -> void :
	var data: = StateCodec.decode_snapshot(bytes)
	if data.is_empty():
		return
	_recv( func(): snapshot_received.emit(data))

func send_event(kind: String, args: Dictionary) -> void :
	_send( func(): _s_event.rpc(kind, args))

@rpc("authority", "call_remote", "reliable")
func _s_event(kind: String, args: Dictionary) -> void :
	if kind == "dev?" or kind == "dev!":
		_recv( func(): _dev_down(kind, args))
		return
	_recv( func(): event_received.emit(kind, args))








signal dev_badges_changed
var _dev_proven: = {}
var _dev_asked: = {}

func dev_trusted(peer_id: int, sid: int) -> bool:
	if sid == 0:
		return false
	if int(_dev_proven.get(peer_id, 0)) == sid:
		return true

	if _steam_peer != null and (is_host or peer_id == 1)\
	and _steam_peer.has_method("get_steam_id_for_peer_id"):
		return int(_steam_peer.call("get_steam_id_for_peer_id", peer_id)) == sid
	return false


func _dev_check_roster() -> void :
	if not active:
		return
	var me: = multiplayer.get_unique_id()
	for pid in players:
		var id: = int(pid)
		var sid: = int((players[pid] as Dictionary).get("sid", 0))
		if id == me or _dev_asked.has(id) or DevBadge.tier_of(sid) != DevBadge.Tier.GOLD\
		or dev_trusted(id, sid):
			continue
		var nonce: = Crypto.new().generate_random_bytes(16).hex_encode()
		_dev_asked[id] = nonce
		if is_host:
			_send( func(): _s_event.rpc_id(id, "dev?", {"a": 1, "n": nonce}))
		else:
			send_up("dev?", {"t": id, "n": nonce})


func _dev_relay(from: int, kind: String, args: Dictionary) -> void :
	var n: = ev_s(args, "n", "", 64)
	if n == "":
		return
	if kind == "dev?":
		var t: = ev_i(args, "t")
		if t == from or not players.has(t):
			return
		if t == 1:
			_dev_answer(from, n)
		else:
			_send( func(): _s_event.rpc_id(t, "dev?", {"a": from, "n": n}))
		return
	var a: = ev_i(args, "a")
	var g: Variant = args.get("g")
	if not (g is PackedByteArray) or (g as PackedByteArray).size() > 512:
		return
	if a == 1:
		_dev_take(from, n, g)
	elif players.has(a):
		_send( func(): _s_event.rpc_id(a, "dev!", {"t": from, "n": n, "g": g}))

func _dev_down(kind: String, args: Dictionary) -> void :
	var n: = ev_s(args, "n", "", 64)
	if kind == "dev?":
		_dev_answer(ev_i(args, "a"), n)
	elif args.get("g") is PackedByteArray:
		_dev_take(ev_i(args, "t"), n, args["g"])


func _dev_answer(asker: int, nonce: String) -> void :
	if nonce == "":
		return
	var sig: = DevBadge.proof_sign(multiplayer.get_unique_id(), nonce)
	if sig.is_empty():
		return
	if is_host:
		_send( func(): _s_event.rpc_id(asker, "dev!", {"t": 1, "n": nonce, "g": sig}))
	else:
		send_up("dev!", {"a": asker, "n": nonce, "g": sig})

func _dev_take(target: int, nonce: String, sig: PackedByteArray) -> void :
	if nonce == "" or String(_dev_asked.get(target, "")) != nonce:
		return
	var sid: = int((players.get(target, {}) as Dictionary).get("sid", 0))
	if DevBadge.proof_ok(sid, target, nonce, sig):
		_dev_proven[target] = sid
		dev_badges_changed.emit()



func send_up(kind: String, args: Dictionary) -> void :
	_send( func(): _c_up.rpc_id(1, kind, args))



const UP_BUDGET: = {"gcast?": [1, 2000], "gstats?": [2, 1000], "skip_vote": [2, 1000], 
	"pa": [2, 1000], "callout": [3, 1000], "cgest": [8, 1000], "gco": [8, 1000], "seat": [2, 1000], 
	"toss": [6, 1000], "touch_try": [24, 1000], "gleave": [2, 2000], 
	"vk_start": [2, 10000], "vk_vote": [3, 10000], "pinv": [8, 4000], 
	"jprac": [1, 3000], "pstam": [4, 1000], "pact": [6, 1000], 
	"dev?": [8, 4000], "dev!": [8, 4000]}
const UP_DEFAULT_BUDGET: = [20, 1000]
var _up_t: = {}
var _look_t: = {}

@rpc("any_peer", "call_remote", "reliable")
func _c_up(kind: String, args: Dictionary) -> void :
	if not is_host:
		return
	var id: = multiplayer.get_remote_sender_id()
	var budget: Array = UP_BUDGET.get(kind, UP_DEFAULT_BUDGET)
	if not _rate_ok(_up_t, "%d:%s" % [id, kind], int(budget[0]), int(budget[1])):
		return


	if kind == "vk_start":
		_recv( func(): _host_vk_start(id, ev_i(args, "t")))
		return
	if kind == "vk_vote":
		_recv( func(): _host_vk_cast(id, bool(args.get("v", false))))
		return

	if kind == "pinv":
		_recv( func(): _host_party_invite(id, ev_i(args, "s")))
		return

	if kind == "dev?" or kind == "dev!":
		_recv( func(): _dev_relay(id, kind, args))
		return
	_recv( func(): up_event_received.emit(id, kind, args))
