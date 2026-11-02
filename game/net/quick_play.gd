class_name QuickPlay
extends Node















signal status(text: String)
signal failed(reason: String)
signal locked


signal moving







var search_max: = 600.0





const BACKFILL: = false



var soft_fill_after: = 15.0



var form_max: = 90.0
const SEAT_WAIT: = 4.0


const GROWTH_FLOOR: = 8.0
const SCAN_WINDOW: = 0.8
const SCAN_EVERY: = 4.0
const BACKFILL_AFTER: = 6.0

const LAN_PORT_BASE: = 28970
const LAN_PORTS: = 8







const REGION_TIERS: = [
	{"t": 0.0, "ceil": 39, "name": "near"}, 
	{"t": 18.0, "ceil": 70, "name": "medium"}, 
	{"t": 45.0, "ceil": 90, "name": "far"}, 
]











const LEVEL_MATCH: = true
const ROOKIE_MAX: = 9
const LEVEL_OPEN_AT: = 0.5
const BAND_ROOKIE: = 1
const BAND_OPEN: = 2



enum State{IDLE, SEARCHING, FORMING, LOCKED, REGROUPING}



static var trace: = "--quick-log" in LaunchGate.dev_args()



static var steamlike_sid: = "--steamlike-sid" in LaunchGate.dev_args()




static var scan_cap: = _dev_int("--scan-cap")
var _capped_rows: = {}
var _steam_lists_pending: = {}


static var dev_level: = _dev_int("--quick-level")

static var dev_open_at: = _dev_int("--quick-open-at")
static var dev_set_points: = _dev_int("--quick-set-points")



static var dev_any_ping: = "--quick-any-ping" in LaunchGate.dev_args()

static func band_of(level: int) -> int:
	if level <= 0:
		return 0
	return BAND_ROOKIE if level <= ROOKIE_MAX else BAND_OPEN



static func my_band() -> int:
	if dev_level > 0:
		return band_of(dev_level)
	var lv: = 0
	for p in ProfileStore.profiles + ProfileStore.recently_deleted:
		if p != null:
			lv = maxi(lv, int(p.level))
	return band_of(lv)






static func bands_meet(a: int, a_open: bool, b: int, b_open: bool) -> bool:
	if not LEVEL_MATCH or a <= 0 or b <= 0 or a == b:
		return true
	return a_open and b_open

static func _dev_int(flag: String) -> int:
	var a: = LaunchGate.dev_args()
	var i: = a.find(flag)
	if i == -1 or i + 1 >= a.size() or not String(a[i + 1]).is_valid_int():
		return 0
	return int(a[i + 1])

static func qlog(msg: String) -> void :
	if trace:


		print("[quick %d] %s @%.3f" % [Time.get_ticks_msec(), msg, Time.get_unix_time_from_system()])

var state: = State.IDLE
var modes: Array = []
var fresh_only: = false














var party_block: Array = []



var _seeker_base: = 1







var _pending_fold: = {}
var _fold_delay: = 0.0
var _fold_resend: = 0.0
const FOLD_HANDOFF_MIN: = 0.35
const FOLD_HANDOFF_MAX: = 6.0
const FOLD_RESEND: = 0.5








const FOLD_GRACE: = 12.0
const FOLD_UNKNOWN_HOLD: = 2.0












const INVITE_TTL_STEAM: = 20.0
const INVITE_TTL_LAN: = 12.0
const INVITE_GONE_STEAM: = 9.0
const INVITE_GONE_LAN: = 6.0
const INVITE_RETRY_MS: = 30000











const RESERVED_SCAN_STEAM: = 1.5
const RESERVED_SCAN_LAN: = 1.0
const CALL_TTL_STEAM: = 15.0
const CALL_TTL_LAN: = 8.0
var _reserved: = {}


var _reserved_in: = {}
var _calling: = false
var _res_promoted: = false



const REGROUP_WAIT: = 20.0

const FAILED_TARGET_MS: = 60000




const EMPTY_FOLD_GIVEUP: = 10.0




const HOST_LINE_STALE: = 25.0
var _seen_members: = {}
var _fold_seen: = {}
var _sent_back: = {}
var _block_humans: = 1
var _block_size: = 0
var _folded_leader: = false
var _fold_target_sid: = 0
var _failed_targets: = {}
var _regroup_t: = 0.0
var _requeue: = true
var _seek_vis_done: = false
var _lock_at: = 0

var _invite: = {}
var _invite_failed: = {}
var _invited_tokens: = {}


var _scan_rows: = {}
var _party_rows: Array = []
var _invites_in: Array = []
var _band_checked: = {}
var _joined_sid: = 0

var _t: = 0.0
var _scan_t: = 0.0
var _scan_open: = 0.0
var _sid: = 0
var _best_reply: = {}
var _best_backfill: = {}
var _listener: PacketPeerUDP = null
var _query: PacketPeerUDP = null
var _am_seeker: = false






var _use_steam: = false



var force_lan: = false





var _isect: Array = []
var _lock_t: = 0.0
var _form_t: = 0.0
var _last_humans: = 0
var _peak_humans: = 0
var _pushed: = ""
var _empty_t: = 0.0
var _stale_t: = 0.0
var _locked_t: = 0.0





const LOCKED_GIVEUP: = 20.0



func can_search() -> bool:
	return force_lan or Net.steam_transport_available()

func begin(want_modes: Array, fresh: = false, seeker: = false) -> void :
	if state != State.IDLE or want_modes.is_empty():
		return
	if not can_search():
		failed.emit(Net.steam_status_text())
		return
	modes = want_modes.filter( func(m): return int(m) in GameConfig.team_sizes())
	if modes.is_empty():
		return
	fresh_only = fresh
	_sid = randi()
	_t = 0.0
	Net.quick_queue = true
	_use_steam = Net.steam_transport_available() and not force_lan
	qlog("begin modes=%s seeker=%s steam=%s players=%d sid=%d" % [str(modes), 
		str(seeker), str(_use_steam), Net.players.size(), _sid])
	if not Net.quick_status.is_connected(_on_quick_status):
		Net.quick_status.connect(_on_quick_status)
	if _use_steam and not Net.steam_lobbies.is_connected(_on_steam_rows):
		Net.steam_lobbies.connect(_on_steam_rows)
	if seeker:




		_am_seeker = true
		_isect = modes.duplicate()
		_last_humans = Net.players.size()
		_peak_humans = Net.players.size()
		_seeker_base = Net.players.size()
		_block_humans = maxi(1, PartySeats.queue_floor())


		var missing: = maxi(0, 2 * best_mode(_last_humans) - _last_humans)
		_lock_t = soft_fill_after + SEAT_WAIT * missing
		if _use_steam:
			Net.steam_quick_meta(_csv(_isect), Net.players.size(), false, 0, false, 0, false, 0, 
				_lobby_band(), _level_open(), _member_hashes())






			Net.quick_seek_visible(true)
			_seek_vis_done = Net.steam_lobby_id != 0
		else:
			_advertise_start()
			_query = PacketPeerUDP.new()
			_query.set_broadcast_enabled(true)
		_scan_t = SCAN_EVERY
		state = State.SEARCHING
		return
	_scan_t = SCAN_EVERY
	state = State.SEARCHING
	if not _use_steam:
		_query = PacketPeerUDP.new()
		_query.set_broadcast_enabled(true)

func cancel() -> void :
	qlog("cancel state=%d party=%d" % [state, party_block.size()])
	if state == State.REGROUPING:


		_requeue = false
		return
	if _folded_leader or not _pending_fold.is_empty():




		_pending_fold = {}
		_regroup(false)
		return


	if state == State.LOCKED:
		return
	if not party_block.is_empty():



		_stop_advertise()
		Net.quick_seek_visible(false)
		Net.quick_status_push("")



		Net.drop_folds("search cancelled")
		party_block = []


		_reserved = {}
		_reserved_in = {}
		_invite = {}
		_calling = false
		_res_promoted = false
		Net.quick_queue = false
		_am_seeker = false
		state = State.IDLE
		status.emit("")
		return
	if Net.active:
		Net.leave()
	_cleanup()
	state = State.IDLE
	status.emit("")





func _time_out() -> void :
	qlog("no match after %.0fs: stopping" % _t)
	cancel()
	failed.emit("no matches found, try again or host a custom lobby")

func _exit_tree() -> void :
	_cleanup()

func _cleanup() -> void :
	if _listener != null:
		_listener.close()
		_listener = null
	if _query != null:
		_query.close()
		_query = null
	if Net.steam_lobbies.is_connected(_on_steam_rows):
		Net.steam_lobbies.disconnect(_on_steam_rows)
	if Net.quick_status.is_connected(_on_quick_status):
		Net.quick_status.disconnect(_on_quick_status)
	_pushed = ""
	_lock_t = 0.0
	_form_t = 0.0
	_last_humans = 0
	_peak_humans = 0
	if not Net.in_match:
		Net.quick_queue = false
	_am_seeker = false
	_isect = []
	_best_reply = {}
	_pending_fold = {}
	_seen_members = {}
	_fold_seen = {}
	_sent_back = {}
	_fold_delay = 0.0
	_seeker_base = 1
	_block_humans = 1
	_block_size = 0
	_folded_leader = false
	_fold_target_sid = 0
	_regroup_t = 0.0
	_requeue = true
	_seek_vis_done = false
	_lock_at = 0
	_invite = {}
	_invite_failed = {}
	_invited_tokens = {}
	_reserved = {}
	_reserved_in = {}
	_calling = false
	_res_promoted = false
	_scan_rows = {}
	_party_rows = []
	_invites_in = []
	_band_checked = {}
	_joined_sid = 0
	Net.quick_locked = false

func _process(delta: float) -> void :



	if not _pending_fold.is_empty():
		_fold_delay += delta
		var here: = _members_still_here()
		if _fold_delay >= FOLD_HANDOFF_MAX or (here.is_empty() and _fold_delay >= FOLD_HANDOFF_MIN):
			if not here.is_empty():
				qlog("fold handoff: %s never left for the winner" % str(here))
			_leader_join_fold()
			return
		_fold_resend -= delta
		if _fold_resend <= 0.0 and not here.is_empty() and _fold_delay >= FOLD_HANDOFF_MIN:
			_fold_resend = FOLD_RESEND
			qlog("fold handoff: rehome again to %s" % str(here))
			for id in here:
				Net.rehome_peer(int(id), int(_pending_fold.get("host_id", 0)), 
					String(_pending_fold.get("ip", "")), modes, int(_pending_fold.get("token", 0)), 
					int(_pending_fold.get("block", 0)))
		return




	if state != State.IDLE and state != State.REGROUPING and not Net.in_match:
		Net.quick_queue = true
	if state == State.LOCKED and not Net.in_match:
		_locked_t += delta
		if _locked_t >= LOCKED_GIVEUP:
			qlog("locked %.0fs and no match started: back to idle" % _locked_t)
			_locked_t = 0.0
			state = State.IDLE
			if Net.active and not Net.party:
				Net.leave()
			_cleanup()
			status.emit("")
			failed.emit("the match didn't start, try again")
			return
	else:
		_locked_t = 0.0
	match state:
		State.SEARCHING:
			_tick_search(delta)
		State.FORMING:
			_tick_forming(delta)
		State.REGROUPING:
			_tick_regroup(delta)
		_:
			pass





func _search_line(secs: float) -> String:
	return "searching for match%s   %d:%02d"\
	%[" (lan)" if force_lan else "", int(secs) / 60, int(secs) % 60]

func modes_label() -> String:
	if modes.size() >= GameConfig.team_sizes().size():
		return "any mode"
	var parts: = []
	var sorted: = modes.duplicate()
	sorted.sort()
	for m in sorted:
		parts.append("%dv%d" % [m, m])
	return ", ".join(parts)



func _tick_search(delta: float) -> void :
	_t += delta
	status.emit(_search_line(_t))
	if _t >= search_max:
		_time_out()
		return




	if _am_seeker:
		_tick_invite(delta)
		_advertise_tick()



		if not party_block.is_empty():
			party_block = party_block.filter( func(id): return Net.players.has(id))
			_seeker_base = mini(_seeker_base, maxi(1, Net.players.size()))
			_absorb_returning_members()
			if _use_steam and not _seek_vis_done and Net.steam_lobby_id != 0:
				Net.quick_seek_visible(true)
				_seek_vis_done = true
		_refuse_band_misfits()

		if Net.players.size() > _seeker_base:
			qlog("joiner arrived (%d > base %d): FORMING" % [Net.players.size(), _seeker_base])


			_unreserve("a joiner came to us")
			_res_promoted = false
			state = State.FORMING
			return



		if not _reserved_in.is_empty():


			if not _reserved.is_empty():
				_release_held_for_move()
			else:
				qlog("a party holds a seat here (%s): FORMING" % str(_reserved_in.keys()))
				_res_promoted = true
				state = State.FORMING
				return






		if not party_block.is_empty():


			var line: = _search_line(_t)
			if line != _pushed:
				_pushed = line
				Net.quick_status_push(line)
	_tick_scan(delta)


func _tick_scan(delta: float) -> void :
	_scan_t += delta
	if _scan_open > 0.0:
		_collect_replies()
		_scan_open -= delta
		if _use_steam and _steam_lists_pending.is_empty():
			_scan_open = 0.0
		if _scan_open <= 0.0:
			_take_capped_rows()
			_scan_done()

	elif _scan_t >= (SCAN_EVERY if _reserved.is_empty()\
	else (RESERVED_SCAN_STEAM if _use_steam else RESERVED_SCAN_LAN)):
		_scan_t = 0.0

		_scan_open = 2.0 if _use_steam else SCAN_WINDOW
		_best_reply = {}
		_best_backfill = {}
		_scan_rows = {}
		_party_rows = []
		_invites_in = []
		_capped_rows = {}
		_scan_send()


func _take_capped_rows() -> void :
	if _capped_rows.is_empty():
		return
	var me: = _my_sid()
	var sids: = _capped_rows.keys()
	sids.sort_custom( func(a, b): return _pseudo_dist(me, a) < _pseudo_dist(me, b))
	var kept: Array = sids.slice(0, scan_cap)


	for sid in sids:
		var row: Dictionary = _capped_rows[sid][0]
		var asks_us: = _wants_invites() and _ni(row.get("inv", 0)) == me
		var a_party: = _asks_parties() and bool(row.get("pq", false))
		if (asks_us or a_party) and not kept.has(sid):
			kept.append(sid)
	qlog("scan cap %d: kept %s of %s" % [scan_cap, str(kept), str(sids)])
	for sid in kept:
		var e: Array = _capped_rows[sid]
		_take_row(e[0], e[1], e[2])
	_capped_rows = {}

static func _pseudo_dist(a: int, b: int) -> int:
	return hash("%d:%d" % [mini(a, b), maxi(a, b)])



func _wants_invites() -> bool:
	return not party_block.is_empty() and state == State.SEARCHING and _my_sid() != 0\
	and ( not _use_steam or Net.steam_lobby_id != 0)



func _asks_parties() -> bool:
	return _am_seeker

func _scan_send() -> void :
	if _use_steam:





		var lists: Array = []
		if not _reserved.is_empty() and _ni(_reserved.get("host_id", 0)) != 0:

			lists.append("quick_host:%d" % _ni(_reserved.get("host_id", 0)))
		else:
			if _wants_invites():
				lists.append("quick_inv:%d" % _my_sid())
			if _asks_parties():
				lists.append("quick_pq")
			lists.append("quick")


		Net.quick_band = _lobby_band()
		_steam_lists_pending = {}
		for label in lists:
			_steam_lists_pending[label] = true
			Net.steam_request_lobbies(label)



		_scan_open += float(lists.size() - 1)
		return


	for i in LAN_PORTS:
		for ip in ["255.255.255.255", "127.0.0.1"]:
			_query.set_dest_address(ip, LAN_PORT_BASE + i)
			_query.put_packet(("QUICK?").to_utf8_buffer())
	qlog("probed udp %d..%d" % [LAN_PORT_BASE, LAN_PORT_BASE + LAN_PORTS - 1])

func _on_steam_rows(rows: Array) -> void :


	if not _use_steam or not (state == State.SEARCHING or (state == State.FORMING and _am_seeker)):
		return



	if not Net.lobby_list_kind.begins_with("quick"):
		return
	_steam_lists_pending.erase(Net.lobby_list_kind)
	for row in rows:
		if String(row.get("kind", "")) != "quick":
			continue
		if not bool(row.get("compatible", false)):
			continue
		if int(row.get("lobby_id", 0)) == Net.steam_lobby_id:
			continue
		var their_modes: Array = []
		for part in String(row.get("modes", "")).split(",", false):
			their_modes.append(int(part))
		var d: = {
			"sid": int(row.get("lobby_id", 0)), 
			"modes": their_modes, 
			"members": maxi(int(row.get("qmembers", 0)), 1), 
			"steam": true, 
			"host_id": int(row.get("host_id", 0)), 
			"ping": int(row.get("ping", -1)), 
			"fm": bool(row.get("fm", false)), 
			"inv": int(row.get("inv", 0)), 
			"pq": bool(row.get("pq", false)), 
			"hum": int(row.get("hum", 0)), 
			"acc": int(row.get("acc", 0)), 
			"rsv": String(row.get("rsv", "")), 
			"lb": int(row.get("lb", 0)), 
			"lw": bool(row.get("lw", false)), 
			"bh": String(row.get("bh", "")), 
		}
		_take_row(d, String(row.get("in_progress", "")) == "1", int(row.get("open", 0)))




func _take_row(d: Dictionary, in_progress: bool, open: int) -> void :
	var sid: = _ni(d.get("sid", 0))
	if _scan_rows.has(sid):
		return
	_scan_rows[sid] = d
	_seen_members[sid] = _ni(d.get("members", 0))





	if Mod.is_blocked_sid(_ni(d.get("host_id", 0))) or Mod.lists_blocked(String(d.get("bh", ""))):
		return
	if not in_progress:
		_take_invite(d)
	if not _mode_overlap(d.get("modes", [])):
		return
	if not _ping_admissible(_ni(d.get("ping", -1), -1)):
		return
	if not _band_ok(d):
		return
	if in_progress:
		if _backfill_fits(open):
			_best_backfill = d
		return


	var acc: = _ni(d.get("acc", 0))
	if bool(d.get("pq", false)) and not bool(d.get("fm", false)) and _ni(d.get("members", 0)) >= 2\
	and (acc == 0 or acc == _my_sid()):
		_party_rows.append(d)

	if acc != 0:
		return
	if not _block_fits(d.get("modes", []), _ni(d.get("members", 0))):
		return
	if Time.get_ticks_msec() - int(_failed_targets.get(sid, - FAILED_TARGET_MS)) < FAILED_TARGET_MS:
		return
	if _better_reply(d):
		_best_reply = d





func _take_invite(d: Dictionary) -> void :
	if party_block.is_empty() or _my_sid() == 0 or _ni(d.get("inv", 0)) != _my_sid():
		return
	if not _mode_overlap(d.get("modes", [])):
		return
	var ping: = _ni(d.get("ping", -1), -1)
	if ping >= 0 and ping > int(REGION_TIERS.back()["ceil"]) and not dev_any_ping:
		return


	if not _band_ok(d):
		return
	_invites_in.append(d)




static func _ni(v: Variant, def: = 0) -> int:
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_BOOL]\
	else def

func _collect_replies() -> void :
	while _query != null and _query.get_available_packet_count() > 0:
		var pkt: = _query.get_packet()
		var ip: = _query.get_packet_ip()
		var d: Variant = JSON.parse_string(pkt.get_string_from_utf8())
		qlog("reply from %s: %s" % [ip, pkt.get_string_from_utf8()])
		if d == null or typeof(d) != TYPE_DICTIONARY:
			continue
		if not Net.proto_ok(_ni(d.get("proto", 0))):
			continue
		if _ni(d.get("sid", 0)) == _my_sid():
			continue



		var row: = {"sid": _ni(d.get("sid", 0)), "modes": d.get("modes", []), 
			"members": _ni(d.get("members", 0)), "ping": -1, "fm": _ni(d.get("fm", false)) != 0, 
			"inv": _ni(d.get("inv", 0)), "pq": _ni(d.get("pq", false)) != 0, 
			"hum": _ni(d.get("hum", 0)), "lb": _ni(d.get("lb", 0)), "lw": _ni(d.get("lw", false)) != 0, 
			"bh": str(d.get("bh", "")).left(256) if typeof(d.get("bh", "")) == TYPE_STRING else "", 
			"acc": _ni(d.get("acc", 0)), 
			"rsv": str(d.get("rsv", "")).left(512) if typeof(d.get("rsv", "")) == TYPE_STRING else "", 
			"ip": _dial_addr(ip, d)}
		if scan_cap > 0:
			_capped_rows[row.sid] = [row, _ni(d.get("in_progress", false)) != 0, _ni(d.get("open", 0))]
			continue
		_take_row(row, _ni(d.get("in_progress", false)) != 0, _ni(d.get("open", 0)))



static func _dial_addr(ip: String, d: Dictionary) -> String:
	var port: = _ni(d.get("port", 0))
	if port <= 0 or port > 65535 or port == Net.PORT:
		return ip
	return "%s:%d" % [ip, port]





func _backfill_fits(open: int) -> bool:
	if fresh_only or not BACKFILL:
		return false
	return open == maxi(1, PartySeats.human_count())





func _block_fits(their_modes: Variant, their_members: int) -> bool:
	if not (their_modes is Array):
		return false
	var side: = 0
	for x in (their_modes as Array):
		var m: = _ni(x, -999)
		if m in modes:
			side = maxi(side, m)
	return their_members < 2 * side

func _better_reply(d: Dictionary) -> bool:
	if _best_reply.is_empty():
		return true
	var a: = _ni(d.get("members", 0))
	var b: = _ni(_best_reply.get("members", 0))



	var na: = _need_in(d.get("modes", []), a)
	var nb: = _need_in(_best_reply.get("modes", []), b)
	if na != nb:
		return na < nb
	if a != b:
		return a > b


	var ba: = _ping_bucket(_ni(d.get("ping", -1), -1))
	var bb: = _ping_bucket(_ni(_best_reply.get("ping", -1), -1))
	if ba != bb:
		return ba < bb
	return _ni(d.get("sid", 0)) < _ni(_best_reply.get("sid", 0))



func _need_in(their_modes: Variant, their_members: int) -> int:
	if not (their_modes is Array):
		return 999
	var here: = maxi(0, their_members) + _my_humans()
	var best: = 999
	for x in (their_modes as Array):
		var m: = _ni(x, -999)
		if m in modes:
			best = mini(best, maxi(0, 2 * m - here))
	return best


func _own_need() -> int:
	var here: = Net.human_count() if _am_seeker else _my_humans()
	var best: = 999
	for m in modes:
		best = mini(best, maxi(0, 2 * int(m) - here))
	return best

func _my_humans() -> int:
	return maxi(_block_humans, PartySeats.human_count())



func _mode_overlap(theirs: Variant) -> bool:
	if not (theirs is Array):
		return false
	var their_ints: Array = (theirs as Array).map( func(x): return _ni(x, -999))
	for m in modes:
		if int(m) in their_ints:
			return true
	return false


func _current_tier() -> Dictionary:
	var tier: Dictionary = REGION_TIERS[0]
	for t in REGION_TIERS:
		if _t >= float(t["t"]):
			tier = t
	return tier

func _region_label() -> String:
	return String(_current_tier()["name"])



func _ping_admissible(ping: int) -> bool:
	return dev_any_ping or ping < 0 or ping <= int(_current_tier()["ceil"])



func _lobby_band() -> int:
	var b: = my_band()
	if _am_seeker:
		for pid in Net.players:
			b = maxi(b, _ni((Net.players[pid] as Dictionary).get("lb", 0)))
	return b


func _level_open() -> bool:
	return _t >= (float(dev_open_at) if dev_open_at > 0 else search_max * LEVEL_OPEN_AT)


func _band_ok(d: Dictionary) -> bool:
	return bands_meet(_lobby_band(), _level_open(), _ni(d.get("lb", 0)), _ni(d.get("lw", false)) != 0)





func _refuse_band_misfits() -> void :
	for pid in _band_misfits():
		qlog("joiner %d is another level band or blocked here: back to the queue" % int(pid))
		Net.refuse_peer(int(pid), Net.QUEUE_FULL)




func _band_misfits() -> Array:
	var out: Array = []
	var ours: = my_band()


	var in_hash: Array = []
	var in_blocks: Array = []
	if Net.my_steam_id() != 0:
		in_hash.append(Mod.sid_hash(Net.my_steam_id()))
	for pid in Net.players.keys():
		var row: Dictionary = Net.players[pid]
		var theirs: = _ni(row.get("lb", 0))
		var jsid: = _ni(row.get("sid", 0))
		var jbk: = String(row.get("bk", "")).split(",", false)
		if int(pid) == 1 or _band_checked.has(pid) or party_block.has(pid)\
		or not bool(row.get("qjoin", false)) or _ni(row.get("ptoken", 0)) != 0:
			ours = maxi(ours, theirs)
			if jsid != 0 and int(pid) != 1:
				in_hash.append(Mod.sid_hash(jsid))
			in_blocks.append(jbk)
			continue
		_band_checked[pid] = true


		var jh: = Mod.sid_hash(jsid) if jsid != 0 else ""
		var clash: = Mod.is_blocked_sid(jsid)
		for h in in_hash:
			clash = clash or jbk.has(h)
		for b in in_blocks:
			clash = clash or (jh != "" and (b as PackedStringArray).has(jh))
		if clash:
			out.append(pid)
		elif bands_meet(ours, _level_open(), theirs, bool(row.get("lw", false))):
			ours = maxi(ours, theirs)
			if jh != "":
				in_hash.append(jh)
			in_blocks.append(jbk)
		else:
			out.append(pid)
	return out


func _member_hashes() -> String:
	var out: Array = []
	var me: = Net.my_steam_id()
	if me != 0:
		out.append(Mod.sid_hash(me))
	for pid in Net.players:
		var sid: = _ni((Net.players[pid] as Dictionary).get("sid", 0))
		if sid != 0 and sid != me:
			out.append(Mod.sid_hash(sid))
	return ",".join(out)


func _blocked_here() -> bool:
	var me: = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 0
	for pid in Net.players:
		if int(pid) != me and Mod.is_blocked_sid(_ni((Net.players[pid] as Dictionary).get("sid", 0))):
			return true
	return false




func _ping_bucket(ping: int) -> int:
	if ping < 0:
		return 1
	if ping <= 39:
		return 0
	if ping <= 70:
		return 1
	if ping <= 90:
		return 2
	return 3




func _my_sid() -> int:
	if _use_steam:
		return Net.steam_lobby_id if Net.steam_lobby_id != 0\
		else 9223372036854775807
	if steamlike_sid and Net.is_host and Net.hosted_sid != 0:
		return Net.hosted_sid
	return _sid




func _party_askable() -> bool:
	return not party_block.is_empty() and (state == State.SEARCHING or _held_only())\
	and _invite.is_empty() and _pending_fold.is_empty()










func _held_only() -> bool:
	return state == State.FORMING and _res_promoted and not _calling\
	and Net.players.size() <= _seeker_base and not _block_landing()


func _listed_forming() -> bool:
	return state == State.FORMING and not _held_only()





func _release_held_for_move() -> void :
	for sid in _reserved_in.keys():
		_drop_held(int(sid), "we're moving to another lobby ourselves", false)
	if not _invite.is_empty():
		_invite_lapse("we're moving to another lobby ourselves", false)
	if _res_promoted:
		_res_promoted = false
		if state == State.FORMING:
			qlog("held seats let go, we move: searching again")
			state = State.SEARCHING



func _advertised_members() -> int:
	var n: = Net.players.size() + (int(_invite.get("block", 0)) if not _invite.is_empty() else 0)

	for sid in _reserved_in:
		n += int((_reserved_in[sid] as Dictionary).get("block", 0))
	return n







func _need_with_block(k: int, their_modes: Array) -> int:
	var theirs: Array = their_modes.map( func(x): return _ni(x, -999))
	var units: = _units()
	var best: = -1
	for x in _isect:
		var m: = int(x)
		if k > m or (k > 0 and not (m in theirs)):
			continue
		if units.is_empty() or not _unit_accepts(units[0], m):
			continue
		var sizes: Array = []
		var must: Array = []
		var blocked: = false
		for i in units.size():
			var u: Array = units[i]
			var keep: = i == 0 or _unit_must(u)
			if not _unit_accepts(u, m):
				blocked = blocked or keep
				continue
			sizes.append(_humans_in(u))
			must.append(keep)

		if not blocked and not _held_unit_sizes(m, sizes, must):
			blocked = true
		if blocked:
			continue
		if k > 0:
			sizes.append(k)
			must.append(true)
		var here: = 0
		for s in sizes:
			here += int(s)
		var need: = maxi(0, 2 * m - here)
		for j in need:
			sizes.append(1)
			must.append(false)
		if _pick_possible(sizes, must, 2 * m) and (best < 0 or need < best):
			best = need
	return best


func _pick_possible(sizes: Array, must: Array, seats: int) -> bool:
	var suffix: Array = []
	suffix.resize(sizes.size() + 1)
	suffix[sizes.size()] = 0
	for i in range(sizes.size() - 1, -1, -1):
		suffix[i] = int(suffix[i + 1]) + int(sizes[i])
	return _pick_units(0, 0, [], sizes, suffix, seats, must)



func _spread(sid: int) -> int:
	return hash("%d:%d" % [sid, _my_sid()])


func _block_landing() -> bool:
	var count: = {}
	var want: = {}
	for pid in Net.players:
		var row: Dictionary = Net.players[pid]
		var tok: = int(row.get("ptoken", 0))
		if tok == 0:
			continue
		count[tok] = int(count.get(tok, 0)) + 1
		want[tok] = maxi(int(want.get(tok, 0)), int(row.get("pblock", 0)))
	for tok in count:
		if int(count[tok]) < int(want[tok]):
			return true
	return false





func _consider_invite() -> void :
	if not _invite.is_empty() or state == State.LOCKED or _block_landing():
		return


	if _calling or not _reserved.is_empty():
		return


	if state == State.FORMING\
	and _form_t >= form_max - (INVITE_TTL_STEAM if _use_steam else INVITE_TTL_LAN):
		return
	var ours: = Net.players.size()


	var now_need: = _need_with_block(0, [])
	var taken: = _parties_asked_by_older()
	var pick: = {}
	var pick_key: = []
	for d in _party_rows:
		var sid: = _ni(d.get("sid", 0))
		if sid == 0 or Time.get_ticks_msec() - int(_invite_failed.get(sid, - INVITE_RETRY_MS)) < INVITE_RETRY_MS:
			continue
		if taken.has(sid):
			continue
		if _reserved_in.has(sid):
			continue
		var theirs: = _ni(d.get("members", 0))
		if state == State.SEARCHING and (theirs > ours or (theirs == ours and sid < _my_sid())):
			continue
		var k: = maxi(_ni(d.get("hum", 0)), theirs)
		var need: = _need_with_block(k, d.get("modes", []))
		if need < 0 or (now_need >= 0 and need > now_need):
			continue
		var key: = [need, - k, _spread(sid)]
		if pick.is_empty() or key < pick_key:
			pick = d
			pick_key = key
	if pick.is_empty():
		return
	_invite = {"sid": _ni(pick.get("sid", 0)), "block": _ni(pick.get("members", 0)), 
		"hum": maxi(_ni(pick.get("hum", 0)), _ni(pick.get("members", 0))), "age": 0.0, "seen": _t}
	qlog("invite party %d (%d people, %d short after)" % [int(_invite.sid), int(_invite.hum), int(pick_key[0])])





func _parties_asked_by_older() -> Dictionary:
	var me: = _my_sid()
	var out: = {}
	for sid in _scan_rows:
		var inv: = _ni((_scan_rows[sid] as Dictionary).get("inv", 0))
		if inv != 0 and int(sid) != me and int(sid) < me:
			out[inv] = true
	return out



func _watch_invite_row() -> void :
	_watch_held_rows()
	if _invite.is_empty():
		return





	var answered: Dictionary = _scan_rows.get(int(_invite.sid), {})
	if not answered.is_empty() and _ni(answered.get("acc", 0)) == _my_sid()\
	and not bool(answered.get("fm", false)):


		if not _reserved.is_empty():
			_invite_lapse("we hold a seat at another lobby ourselves", false)
			return
		_take_held(answered)
		return





	if _parties_asked_by_older().has(int(_invite.sid)):
		_invite_lapse("an older lobby asked it too", false)
		return
	var d: Dictionary = _scan_rows.get(int(_invite.sid), {})
	if d.is_empty():
		return
	_invite["seen"] = _t
	if bool(d.get("fm", false)) or not bool(d.get("pq", false)):
		_invite_lapse("it's no longer free", false)
		return
	if _ni(d.get("acc", 0)) != 0:
		_invite_lapse("it holds a seat at another lobby", false)



func _take_held(d: Dictionary) -> void :
	var modes_in: Array = []
	var their_modes: Variant = d.get("modes", [])
	if their_modes is Array:
		for x in (their_modes as Array):
			modes_in.append(_ni(x))
	_reserved_in[int(_invite.sid)] = {"block": maxi(1, _ni(d.get("members", 0))), 
		"hum": maxi(_ni(d.get("hum", 0)), _ni(d.get("members", 0))), "modes": modes_in, 
		"seen": _t, "called": false, "call_age": 0.0}
	qlog("party %d holds a seat here from home (%d people)" % [int(_invite.sid), 
		int((_reserved_in[int(_invite.sid)] as Dictionary).hum)])
	_invite = {}




func _watch_held_rows() -> void :
	for sid in _reserved_in.keys():
		var r: Dictionary = _reserved_in[sid]
		if bool(r.get("called", false)):
			continue
		var d: Dictionary = _scan_rows.get(int(sid), {})
		if d.is_empty():
			continue
		r["seen"] = _t
		r["block"] = maxi(1, _ni(d.get("members", 0)))
		r["hum"] = maxi(_ni(d.get("hum", 0)), _ni(d.get("members", 0)))
		if _ni(d.get("acc", 0)) != _my_sid() or bool(d.get("fm", false))\
		or not bool(d.get("pq", false)):
			_drop_held(int(sid), "it no longer holds its seat here", false)

func _drop_held(sid: int, why: String, ignored: bool) -> void :
	qlog("held seats for party %d let go: %s" % [sid, why])
	_reserved_in.erase(sid)
	if ignored:
		_invite_failed[sid] = Time.get_ticks_msec()



func _tick_held(delta: float) -> void :
	if _reserved_in.is_empty():
		return
	var landing: = {}
	for pid in Net.players:
		var tok: = int((Net.players[pid] as Dictionary).get("ptoken", 0))
		if tok != 0 and _reserved_in.has(tok):
			landing[tok] = true
	for tok in landing:

		_invited_tokens[tok] = true
		_reserved_in.erase(tok)
		qlog("held party %d landing" % int(tok))
	var call_ttl: = CALL_TTL_STEAM if _use_steam else CALL_TTL_LAN
	var gone_max: = INVITE_GONE_STEAM if _use_steam else INVITE_GONE_LAN
	for sid in _reserved_in.keys():
		var r: Dictionary = _reserved_in[sid]
		if bool(r.get("called", false)):
			r["call_age"] = float(r.get("call_age", 0.0)) + delta
			if float(r.call_age) >= call_ttl:
				_drop_held(int(sid), "called in and never came", true)
		elif _t - float(r.get("seen", _t)) >= gone_max:
			_drop_held(int(sid), "its listing went", false)


func _held_humans() -> int:
	var n: = 0
	for sid in _reserved_in:
		var r: Dictionary = _reserved_in[sid]
		if not bool(r.get("called", false)):
			n += int(r.get("hum", 0))
	return n

func _any_called() -> bool:
	for sid in _reserved_in:
		if bool((_reserved_in[sid] as Dictionary).get("called", false)):
			return true
	return false




func _held_unit_sizes(m: int, sizes: Array, must: Array) -> bool:
	for sid in _reserved_in:
		var r: Dictionary = _reserved_in[sid]
		var rm: Array = r.get("modes", [])
		if not rm.is_empty() and not (m in rm):
			return false
		sizes.append(int(r.get("hum", 0)))
		must.append(true)
	return true



func _pick_held(seats: int) -> bool:
	if seats < 2 or seats % 2 != 0:
		return false
	var m: = seats / 2
	var units: = _units()
	if units.is_empty() or not _unit_accepts(units[0], m):
		return false
	var sizes: Array = []
	var must: Array = []
	for i in units.size():
		var u: Array = units[i]
		var keep: = _unit_must(u)
		if not _unit_accepts(u, m):
			if keep:
				return false
			continue
		sizes.append(_humans_in(u))
		must.append(keep)
	if not _held_unit_sizes(m, sizes, must):
		return false
	return _pick_possible(sizes, must, seats)


func _fill_held(humans: int) -> int:
	if humans < 2 or humans % 2 != 0:
		return 0
	var m: = humans / 2
	for x in _isect:
		if int(x) == m:
			return m if _pick_held(humans) else 0
	return 0

func _fit_held(humans: int) -> int:
	var sizes: = _isect.map( func(x): return int(x))
	sizes.sort()
	sizes.reverse()
	for m in sizes:
		if 2 * int(m) <= humans and _pick_held(2 * int(m)):
			return int(m)
	return 0



func _call_held() -> void :
	for sid in _reserved_in:
		var r: Dictionary = _reserved_in[sid]
		if not bool(r.get("called", false)):
			r["called"] = true
			r["call_age"] = 0.0
	_calling = true
	qlog("match found: calling %s in from home" % str(_reserved_in.keys()))


func _rsv_csv() -> String:
	var parts: Array = []
	for sid in _reserved_in:
		parts.append("%d%s" % [int(sid), "!" if bool((_reserved_in[sid] as Dictionary).get("called", false)) else ""])
	return ",".join(parts)


func _tick_invite(delta: float) -> void :
	_tick_held(delta)
	if _invite.is_empty():
		return
	var sid: = int(_invite.sid)
	for pid in Net.players:
		if int((Net.players[pid] as Dictionary).get("ptoken", 0)) == sid:

			_invited_tokens[sid] = true
			qlog("invited party %d landing" % sid)
			_invite = {}
			return
	_invite["age"] = float(_invite.age) + delta
	var ttl: = INVITE_TTL_STEAM if _use_steam else INVITE_TTL_LAN
	var gone_max: = INVITE_GONE_STEAM if _use_steam else INVITE_GONE_LAN
	if float(_invite.age) >= ttl:
		_invite_lapse("it never came", true)
	elif _t - float(_invite.seen) >= gone_max:
		_invite_lapse("its lobby went and nobody landed", false)




func _invite_lapse(why: String, ignored: bool) -> void :
	qlog("invite to %d lapsed: %s" % [int(_invite.sid), why])
	if ignored:
		_invite_failed[int(_invite.sid)] = Time.get_ticks_msec()
	_invite = {}



func _party_scan_done() -> void :

	if not _reserved.is_empty():
		_watch_reservation()
		return
	if not _invite.is_empty() or _invites_in.is_empty():
		return


	if Net.party_still_coming():
		qlog("fold held: party members still on their way home")
		return



	_best_reply = {}
	for d in _invites_in:
		var sid: = _ni(d.get("sid", 0))
		if Time.get_ticks_msec() - int(_failed_targets.get(sid, - FAILED_TARGET_MS)) < FAILED_TARGET_MS:
			continue
		if _best_reply.is_empty() or sid < _ni(_best_reply.get("sid", 0)):
			_best_reply = d
	if _best_reply.is_empty():
		return


	qlog("asked in by %d: holding the seat from home (%d asks)" % [_ni(_best_reply.get("sid", 0)), _invites_in.size()])
	_reserved = _best_reply.duplicate()
	_reserved["seen"] = _t
	_reserved["miss"] = 0
	_best_reply = {}
	_release_held_for_move()

func _unreserve(why: String) -> void :
	if _reserved.is_empty():
		return
	qlog("seat at %d let go: %s" % [_ni(_reserved.get("sid", 0)), why])
	_reserved = {}


func _rsv_state(d: Dictionary) -> int:
	var me: = _my_sid()
	for part in String(d.get("rsv", "")).split(",", false):
		if String(part).trim_suffix("!").to_int() == me:
			return 2 if String(part).ends_with("!") else 1
	return 0



func _watch_reservation() -> void :
	var sid: = _ni(_reserved.get("sid", 0))
	var d: Dictionary = _scan_rows.get(sid, {})
	if d.is_empty():
		if _t - float(_reserved.get("seen", _t)) >= (INVITE_GONE_STEAM if _use_steam else INVITE_GONE_LAN):
			_unreserve("its lobby went")
		return
	var st: = _rsv_state(d)
	if st == 2:
		qlog("called in by %d: match found, the party moves now" % sid)
		_reserved = {}
		_best_reply = d


		_pushed = "match found!"
		status.emit("match found!")
		Net.quick_status_push("match found!")
		moving.emit()
		_fold_party_block()
		return

	if st == 1 or _ni(d.get("inv", 0)) == _my_sid():
		_reserved["seen"] = _t
		_reserved["miss"] = 0
		return

	_reserved["miss"] = int(_reserved.get("miss", 0)) + 1
	if int(_reserved.miss) >= 2:
		_unreserve("it let our seat go")

func _scan_done() -> void :
	_watch_invite_row()
	if _am_seeker and _pending_fold.is_empty():
		_consider_invite()


	if state != State.SEARCHING and not _held_only():
		return
	if not party_block.is_empty():
		_party_scan_done()
		return
	if not _invite.is_empty():
		return
	if not _best_reply.is_empty():





		var their_members: = clampi(_ni(_best_reply.get("members", 1), 1), 0, Net.MAX_PLAYERS)


		var ours: = (_advertised_members() if _held_only() else Net.players.size()) if _am_seeker else 0




		var their_forming: = bool(_best_reply.get("fm", false))
		var fold: = their_members > ours\
		or (their_members == ours\
		and (their_forming or int(_best_reply.get("sid", 0)) < _my_sid()))



		var need_there: = _need_in(_best_reply.get("modes", []), their_members)
		if fold and need_there > _own_need():
			qlog("no fold: %d short there, %d here" % [need_there, _own_need()])
			fold = false
		qlog("scan: best=%s theirs=%d ours=%d fold=%s" % [str(_best_reply), 
			their_members, ours, str(fold)])
		if fold:
			_release_held_for_move()
			if _am_seeker:
				Net.leave()
				_stop_advertise()
			var joined: bool
			if bool(_best_reply.get("steam", false)):
				joined = Net.join_game_steam(int(_best_reply.host_id), 
					Net.my_name) == OK
			else:
				joined = Net.join_game(String(_best_reply.ip), Net.my_name) == OK
			qlog("fold join ok=%s" % str(joined))
			if joined:


				Net.quick_join_modes = _hello_modes()
				Net.quick_join_open = _level_open()
				_joined_sid = int(_best_reply.get("sid", 0))
				state = State.FORMING
				_am_seeker = false
				return


	if _best_reply.is_empty() and not _best_backfill.is_empty()\
	and _t >= BACKFILL_AFTER and party_block.is_empty():
		if _am_seeker:
			Net.leave()
			_stop_advertise()
			_am_seeker = false
		var bf_ok: bool
		if bool(_best_backfill.get("steam", false)):
			bf_ok = Net.join_game_steam(int(_best_backfill.host_id), 
				Net.my_name) == OK
		else:
			bf_ok = Net.join_game(String(_best_backfill.ip), Net.my_name) == OK
		if bf_ok:
			Net.quick_join_modes = _hello_modes()
			Net.quick_join_open = _level_open()
			state = State.FORMING
			status.emit("joining a match in progress...")
			return
	if not _am_seeker:

		if _use_steam:
			if Net.host_game_steam(Net.my_name) == OK:


				Net.mark_lobby_hidden()
				_am_seeker = true
				_isect = modes.duplicate()


			return





		var probe: = PacketPeerUDP.new()
		var port_free: = probe.bind(Net.host_port()) == OK
		probe.close()
		qlog("no lobby found; port_free=%s -> hosting" % str(port_free))
		if port_free and Net.host_game(Net.my_name) == OK:



			Net.mark_lobby_hidden()
			_am_seeker = true
			_isect = modes.duplicate()
			_advertise_start()






func _fold_party_block() -> void :
	qlog("party FOLDS into %s" % str(_best_reply))
	_stop_advertise()
	var steam: = bool(_best_reply.get("steam", false))
	var host_id: = int(_best_reply.get("host_id", 0)) if steam else 0
	var host_ip: = String(_best_reply.get("ip", "")) if not steam else ""
	var token: = _my_sid()


	_block_size = maxi(1, party_block.size())
	_fold_target_sid = int(_best_reply.get("sid", 0))
	Net.rehome_party(host_id, host_ip, modes, token, "", _block_size)





	Net.home_party = {"is_leader": true, "token": token, "lan": Net.party_lan, 
		"block": _block_size, "mates": Net.party_mates()}
	_pending_fold = {"host_id": host_id, "ip": host_ip, "token": token, "block": _block_size}
	_fold_delay = 0.0
	_fold_resend = 0.0


func _members_still_here() -> Array:
	return party_block.filter( func(id): return int(id) != 1 and Net.players.has(id)\
	and multiplayer.get_peers().has(int(id)))

func _leader_join_fold() -> void :
	var pf: = _pending_fold
	_pending_fold = {}
	Net.quick_join_modes = _hello_modes()
	Net.quick_join_open = _level_open()
	Net.quick_party_token = int(pf.get("token", 0))
	Net.quick_party_block = int(pf.get("block", 0))
	var ok: = false
	if int(pf.get("host_id", 0)) != 0:
		ok = Net.join_game_steam(int(pf.host_id), Net.my_name) == OK
	elif String(pf.get("ip", "")) != "":
		ok = Net.join_game(String(pf.ip), Net.my_name) == OK
	qlog("leader fold join ok=%s" % str(ok))
	if ok:


		party_block = []
		_am_seeker = false
		_folded_leader = true
		state = State.FORMING
	else:


		_regroup()








func _regroup(requeue: = true) -> void :
	_folded_leader = false
	_failed_targets[_fold_target_sid] = Time.get_ticks_msec()
	var hp: Dictionary = Net.home_party
	Net.home_party = {}
	if Net.active:
		Net.leave()


	Net.party_home_tokens[int(hp.get("token", 0))] = true
	qlog("party fold fell through: regrouping (block %d, requeue %s)" % [_block_size, str(requeue)])
	var err: = Net.host_party(Net.my_name, bool(hp.get("lan", false)), true)
	if err != OK:
		state = State.IDLE
		_cleanup()
		status.emit("")
		failed.emit("couldn't regroup your party, make a new one")
		return
	party_block = []
	_am_seeker = false
	_requeue = requeue
	_regroup_t = 0.0
	_pushed = ""
	state = State.REGROUPING
	status.emit(_search_line(_t))

func _tick_regroup(delta: float) -> void :
	_regroup_t += delta
	var back: = Net.party_members().size()
	var want: = maxi(1, _block_size)


	var line: = _search_line(_t + _regroup_t)
	status.emit(line)
	if line != _pushed:
		_pushed = line
		Net.quick_status_push(line)
	if back < want and _regroup_t < REGROUP_WAIT:
		return
	qlog("regrouped %d/%d in %.1fs (requeue %s)" % [back, want, _regroup_t, str(_requeue)])
	state = State.IDLE
	_block_size = 0
	if back < want and _requeue:



		Net.quick_queue = false
		Net.quick_status_push("")
		status.emit("")
		failed.emit("couldn't get your whole party back, search stopped")
		return
	if not _requeue:
		Net.quick_queue = false
		Net.quick_status_push("")
		status.emit("")
		_requeue = true
		return



	party_block = Net.party_members()
	var carry: = _t + _regroup_t
	begin(modes.duplicate(), fresh_only, true)
	_t = carry


func _hello_modes() -> Array:
	return modes.duplicate()








func absorb_filter(_theirs: Array) -> void :
	pass



func _unit_accepts(unit: Array, m: int) -> bool:
	for pid in unit:
		var qm: Variant = (Net.players.get(pid, {}) as Dictionary).get("qm", [])
		if qm is Array and not (qm as Array).is_empty() and not (m in (qm as Array)):
			return false
	return true





func best_mode(humans: int) -> int:
	var sorted: = _isect.map( func(x): return int(x))
	sorted.sort()
	for m in sorted:
		if int(m) * 2 >= humans:
			return int(m)
	return int(sorted.back()) if not sorted.is_empty() else Net.team_size





func human_fill(humans: int) -> int:
	if humans < 2 or humans % 2 != 0:
		return 0
	var m: = humans / 2
	for x in _isect:
		if int(x) == m:
			return m if not _keepers(humans).is_empty() else 0
	return 0






func human_fit(humans: int) -> int:
	var sizes: = _isect.map( func(x): return int(x))
	sizes.sort()
	sizes.reverse()
	for m in sizes:
		if 2 * int(m) <= humans and not _keepers(2 * int(m)).is_empty():
			return int(m)
	return 0









func _keepers(seats: int) -> Array:
	if seats < 2 or seats % 2 != 0:
		return []
	var all_units: = _units()
	if all_units.is_empty() or not _unit_accepts(all_units[0], seats / 2):
		return []

	for u in all_units:
		if _unit_must(u) and not _unit_accepts(u, seats / 2):
			return []


	var units: = all_units.filter( func(u): return _unit_accepts(u, seats / 2))
	var sizes: Array = units.map( func(u): return _humans_in(u))
	var must: Array = units.map( func(u): return _unit_must(u))
	var suffix: Array = []
	suffix.resize(sizes.size() + 1)
	suffix[sizes.size()] = 0
	for i in range(sizes.size() - 1, -1, -1):
		suffix[i] = int(suffix[i + 1]) + int(sizes[i])
	var chosen: Array = []
	if not _pick_units(0, 0, chosen, sizes, suffix, seats, must):
		return []
	var keep: Array = []
	for i in chosen:
		keep.append_array(units[i])
	return keep



func _units() -> Array:
	var units: Array = []
	var used: = {}
	var mine: Array = party_block.filter( func(id): return Net.players.has(id))\
	if not party_block.is_empty() else ([1] if Net.players.has(1) else [])
	if not mine.is_empty():
		units.append(mine)
		for id in mine:
			used[id] = true
	for pid in Net.players.keys():
		if used.has(pid):
			continue
		var tok: = int((Net.players[pid] as Dictionary).get("ptoken", 0))
		var unit: Array = [pid]
		if tok != 0:
			unit = Net.players.keys().filter( func(q):
				return int((Net.players[q] as Dictionary).get("ptoken", 0)) == tok)
		for id in unit:
			used[id] = true
		units.append(unit)
	return units



func _unit_must(unit: Array) -> bool:
	if unit.is_empty() or _invited_tokens.is_empty():
		return false
	return _invited_tokens.has(int((Net.players.get(unit[0], {}) as Dictionary).get("ptoken", 0)))




func _pick_units(i: int, total: int, chosen: Array, sizes: Array, suffix: Array, 
		seats: int, must: Array = []) -> bool:
	if total == seats:
		if must.slice(i).has(true):
			return false
		var parts: Array = chosen.map( func(k): return int(sizes[k]))
		return not _side_of(parts, seats / 2).is_empty()
	if i >= sizes.size() or total + int(suffix[i]) < seats:
		return false
	var s: = int(sizes[i])
	if s <= seats / 2 and total + s <= seats:
		chosen.append(i)
		if _pick_units(i + 1, total + s, chosen, sizes, suffix, seats, must):
			return true
		chosen.pop_back()
	if i == 0 or (i < must.size() and bool(must[i])):
		return false
	return _pick_units(i + 1, total, chosen, sizes, suffix, seats, must)



static func _side_of(parts: Array, team: int) -> Array:
	var pick: Array = []
	return pick if _side_pick(parts, 0, 0, team, pick) else []

static func _side_pick(parts: Array, i: int, total: int, team: int, pick: Array) -> bool:
	if total == team:
		return true
	if i >= parts.size():
		return false
	var s: = int(parts[i])
	if total + s <= team:
		pick.append(i)
		if _side_pick(parts, i + 1, total + s, team, pick):
			return true
		pick.pop_back()
	if i == 0:
		return false
	return _side_pick(parts, i + 1, total, team, pick)



func _release_extras(keep: Array) -> void :
	for pid in Net.players.keys():
		if keep.has(pid):
			continue
		var tok: = int((Net.players[pid] as Dictionary).get("ptoken", 0))
		qlog("match is full: sending %d back to the queue" % int(pid))
		Net.refuse_peer(int(pid), Net.REGROUP if tok != 0 else Net.QUEUE_FULL)

func _on_quick_status(text: String) -> void :

	if not _am_seeker and state == State.FORMING:
		if text != _pushed:
			_stale_t = 0.0
		_pushed = text





func _absorb_returning_members() -> void :
	var members: = Net.party_members()
	if members.size() > party_block.size():
		party_block = members
		_seeker_base = maxi(_seeker_base, members.size())
		_block_humans = maxi(_block_humans, PartySeats.human_count())



func _tick_forming(delta: float) -> void :
	_t += delta
	if not Net.active:



		if _folded_leader:
			_regroup()
			return




		if _joined_sid != 0:
			_failed_targets[_joined_sid] = Time.get_ticks_msec()
			_joined_sid = 0
		state = State.SEARCHING
		_am_seeker = false
		return
	var humans: = Net.human_count()





	if not _am_seeker and humans == 0:
		_empty_t += delta
		if _empty_t >= EMPTY_FOLD_GIVEUP:
			qlog("fold never landed (%.0fs with no roster): back to searching"
				%_empty_t)
			_empty_t = 0.0
			_pushed = ""
			Net.leave()
			if _folded_leader:
				_regroup()
				return
			state = State.SEARCHING
			_am_seeker = false
			return
	else:
		_empty_t = 0.0







	if not _am_seeker:
		_stale_t += delta
		if _stale_t >= HOST_LINE_STALE + (CALL_TTL_STEAM + FOLD_GRACE\
		if _pushed == "match found!" else 0.0):
			qlog("host line frozen %.0fs (%s): leaving" % [_stale_t, _pushed])
			_stale_t = 0.0
			_pushed = ""
			Net.leave()
			if _folded_leader:
				_regroup()
				return
			state = State.SEARCHING
			_am_seeker = false
			return






	if not _am_seeker and not _folded_leader and party_block.is_empty()\
	and _pushed != "match found!" and _blocked_here():
		qlog("someone this machine blocked is in the lobby: leaving it")
		if _joined_sid != 0:
			_failed_targets[_joined_sid] = Time.get_ticks_msec()
			_joined_sid = 0
		_pushed = ""
		Net.leave()
		state = State.SEARCHING
		return
	if not _am_seeker:



		status.emit(_pushed if _pushed == "match found!" else _search_line(_t))
		return
	_refuse_band_misfits()
	if Net.human_count() != humans:
		return
	_tick_invite(delta)
	_advertise_tick()

	_tick_scan(delta)



	if _res_promoted and _reserved_in.is_empty() and _invite.is_empty() and not _calling\
	and Net.players.size() <= _seeker_base and not _block_landing():
		qlog("the party holding a seat here let it go: searching again")
		_res_promoted = false
		_last_humans = humans
		state = State.SEARCHING
		return


	var held: = _held_humans()
	var eff: = humans + held
	if eff > _last_humans:













		if eff > _peak_humans:
			_lock_t = maxf(_lock_t, GROWTH_FLOOR)
	_peak_humans = maxi(_peak_humans, eff)
	_last_humans = eff

	var fill: = human_fill(humans) if held == 0 else _fill_held(eff)
	var fit: = 0
	if fill == 0:
		fit = human_fit(humans) if held == 0 else _fit_held(eff)
	if fill > 0 or fit > 0:




		_lock_t -= delta
		_form_t += delta

	var line: = "match found!" if _calling else _search_line(_t)
	status.emit(line)
	if line != _pushed:
		_pushed = line
		Net.quick_status_push(line)
	var full: = eff >= 2 * int(best_mode(999))
	if not party_block.is_empty():
		_absorb_returning_members()






	if _fold_incomplete() or ( not party_block.is_empty() and Net.party_still_coming())\
	or not _invite.is_empty() or _any_called():
		_lock_t = maxf(_lock_t, 2.0)
		return





	if Net.human_count() != humans:
		return


	_calling = false




	if held > 0 and (fill > 0 or fit > 0) and (full or _lock_t <= 0.0 or _form_t >= form_max):
		_call_held()
		return
	if fill > 0 and (full or _lock_t <= 0.0 or _form_t >= form_max):
		_lock(fill)
	elif fit > 0 and (full or _lock_t <= 0.0 or _form_t >= form_max):




		var keep: = _keepers(2 * fit)
		if keep.is_empty():
			return
		_release_extras(keep)
		_lock(fit)
	elif _t >= search_max:


		_time_out()








func _fold_incomplete() -> bool:
	var blocks: = {}
	for pid in Net.players:
		var row: Dictionary = Net.players[pid]
		var tok: = int(row.get("ptoken", 0))
		if tok == 0:
			continue
		if not blocks.has(tok):
			blocks[tok] = {"ids": [], "want": 0}
		(blocks[tok]["ids"] as Array).append(pid)
		blocks[tok]["want"] = maxi(int(blocks[tok]["want"]), int(row.get("pblock", 0)))
	var holding: = false
	for tok in blocks:
		var ids: Array = blocks[tok]["ids"]
		var want: = int(blocks[tok]["want"])
		if _sent_back.has(tok):
			_send_block_back(tok, ids, "a straggler of a block already sent back")
			continue
		if not _fold_seen.has(tok):
			_fold_seen[tok] = _t
		var since: float = _t - float(_fold_seen[tok])
		if want <= 0:

			if since < FOLD_UNKNOWN_HOLD:
				holding = true
			continue
		if ids.size() < want:
			if since >= FOLD_GRACE:
				_send_block_back(tok, ids, "only %d of %d landed" % [ids.size(), want])
				continue
			holding = true
			continue






		if Net.human_count() > 2 * best_mode(999) and not _seats_block(ids):
			_send_block_back(tok, ids, "no room for the whole party")
	return holding



func _seats_block(ids: Array) -> bool:
	var humans: = Net.human_count()
	var m: = human_fill(humans)
	if m == 0:
		m = human_fit(humans)
	if m == 0:
		return false
	var keep: = _keepers(2 * m)
	for id in ids:
		if not keep.has(id):
			return false
	return true

func _send_block_back(tok: int, ids: Array, why: String) -> void :
	qlog("block %d sent back (%s): %s" % [tok, why, str(ids)])
	_sent_back[tok] = true
	_fold_seen.erase(tok)
	for pid in ids:
		if Net.players.has(pid):
			Net.refuse_peer(int(pid), Net.REGROUP)





func _lock(m: int) -> void :
	var here: = Net.human_count()
	if m <= 0 or here != 2 * m or human_fill(here) != m:
		qlog("LOCK REFUSED: decided %dv%d but %d humans here fill %d" % [m, m, here, human_fill(here)])
		return
	qlog("LOCK players=%s" % str(Net.players))
	state = State.LOCKED
	_invite = {}
	_reserved_in = {}
	_calling = false
	_res_promoted = false

	Net.quick_locked = true
	_stop_advertise()





	Net.set_team_size(m)
	Net.quick_status_push("match found!")
	status.emit("match found!")
	locked.emit()





	var pts: = dev_set_points if dev_set_points > 0 else 7
	GameConfig.set_points = pts
	GameConfig.sets_to_win = 2
	GameConfig.win_by_two = true


	GameConfig.instant_replays = true
	GameConfig.team_collision = true
	GameConfig.serve_seconds = 15
	GameConfig.ball_hints = true
	GameConfig.lock_teams = false
	GameConfig.rotate_every_point = false
	GameConfig.match_intro = true
	Net.set_rules(pts, 2, true, false, 1.0, true, true, 15, true, false, false)
	Net.rule_outfit = DressCode.CURRENT
	Net.stage = Stage.random_id()
	_balance_sides()




	if not _sides_even(int(Net.team_size)):
		_seat_exact(int(Net.team_size))
	quick_start.emit()


func _sides_even(team: int) -> bool:
	var n: = {1: 0, -1: 0}
	for id in Net.players:
		var sd: = int((Net.players[id] as Dictionary).get("side", 0))
		if not n.has(sd):
			return false
		n[sd] = int(n[sd]) + 1 + Net.locals_of(int(id)).size()
	return int(n[1]) == team and int(n[-1]) == team


func _seat_exact(team: int) -> void :
	var units: = _units()
	var home: = _side_of(units.map( func(u): return _humans_in(u)), team)
	if home.is_empty():
		qlog("no even split for %s" % str(units))
		return
	for i in units.size():
		for id in units[i]:
			_seat_conn(int(id), 1 if home.has(i) else -1)


signal quick_start




func _balance_sides() -> void :
	if not party_block.is_empty():
		_balance_party()
		return





	var blocks: = {}
	var lone: = 0
	for id in Net.players.keys():
		var tok: = int((Net.players[id] as Dictionary).get("ptoken", 0))
		if tok == 0:
			lone -= 1
			tok = lone
		if not blocks.has(tok):
			blocks[tok] = []
		(blocks[tok] as Array).append(id)
	var groups: Array = blocks.values()


	groups.sort_custom( func(a, b): return _humans_in(a) > _humans_in(b))
	var count: = {1: 0, -1: 0}
	for grp in groups:
		var side: = 1 if int(count[1]) <= int(count[-1]) else -1
		for id in grp:
			count[side] = int(count[side]) + _seat_conn(id, side)




static func _seat_conn(id: int, side: int) -> int:
	Net.players[id].side = side
	var locs: Array = Net.locals_of(id)
	for g in locs:
		if g is Dictionary:
			(g as Dictionary)["side"] = side
	return 1 + locs.size()

static func _humans_in(ids: Array) -> int:
	var n: = 0
	for id in ids:
		n += 1 + Net.locals_of(int(id)).size()
	return n




func _balance_party() -> void :
	var team: = int(Net.team_size)
	var others: = Net.players.keys().filter( func(id): return not party_block.has(id))

	var blocks: = {}
	var loners: Array = []
	for id in others:
		var tok: = int((Net.players[id] as Dictionary).get("ptoken", 0))
		if tok != 0:
			if not blocks.has(tok):
				blocks[tok] = []
			blocks[tok].append(id)
		else:
			loners.append(id)
	loners.sort_custom( func(a, b):
		return float(Net.players[a].get("wr", 0.5))\
		> float(Net.players[b].get("wr", 0.5)))
	var home: = 0
	for id in party_block:
		if Net.players.has(id):
			home += _seat_conn(id, 1)

	var block_list: Array = blocks.values()
	block_list.sort_custom( func(a, b): return _humans_in(a) > _humans_in(b))
	for grp in block_list:
		for id in grp:
			_seat_conn(id, -1)

	for id in loners:
		var n: = 1 + Net.locals_of(int(id)).size()
		if home + n <= team:
			home += _seat_conn(id, 1)
		else:
			_seat_conn(id, -1)



func _advertise_tick() -> void :
	if _use_steam:





		var at: = 0
		var left: = _left_now()
		var now: = Net.steam_server_time()
		if left >= 0.0 and now > 0:
			at = now + ceili(left)
			if _lock_at != 0 and absi(at - _lock_at) <= 1:
				at = _lock_at
		_lock_at = at
		Net.steam_quick_meta(_csv(_isect), _advertised_members(), false, at, 
			_listed_forming(), int(_invite.get("sid", 0)), _party_askable(), Net.human_count(), 
			_lobby_band(), _level_open(), _member_hashes(), _ni(_reserved.get("sid", 0)), 
			_rsv_csv())
	else:
		_answer_probes()



func _left_now() -> float:
	if not _am_seeker or state != State.FORMING:
		return -1.0
	var humans: = Net.human_count()
	if human_fill(humans) == 0 and human_fit(humans) == 0:
		return -1.0
	return maxf(0.0, minf(_lock_t, form_max - _form_t))

func _csv(a: Array) -> String:
	return ",".join(a.map( func(x): return str(int(x))))

func _advertise_start() -> void :
	_listener = PacketPeerUDP.new()
	for i in LAN_PORTS:
		if _listener.bind(LAN_PORT_BASE + i) == OK:
			qlog("advertising on udp %d" % (LAN_PORT_BASE + i))
			return
	_listener = null

func _stop_advertise() -> void :
	if _use_steam and _am_seeker:

		Net.steam_quick_meta(_csv(_isect), Net.players.size(), true)
	if _listener != null:
		_listener.close()
		_listener = null

var _probe_reply_t: = {}
var _probe_global_t: Array = []

func _answer_probes() -> void :
	while _listener != null and _listener.get_available_packet_count() > 0:
		var pkt: = _listener.get_packet()
		if pkt.get_string_from_utf8() != "QUICK?":
			continue






		var src: = _listener.get_packet_ip()
		var key: = "%s:%d" % [src, _listener.get_packet_port()]
		var now: = Time.get_ticks_msec()
		if now - int(_probe_reply_t.get(key, -100000)) < 250:
			continue
		_probe_reply_t[key] = now
		if _probe_reply_t.size() > 256:
			_probe_reply_t.clear()
		while not _probe_global_t.is_empty() and now - int(_probe_global_t[0]) > 1000:
			_probe_global_t.pop_front()
		if _probe_global_t.size() >= 40:
			continue
		_probe_global_t.append(now)




		if _advertised_members() >= 2 * int(best_mode(999)) and _invite.is_empty()\
		and _reserved_in.is_empty():
			continue
		var reply: = {
			"sid": _my_sid(), 
			"proto": Net.wire_proto(), 

			"modes": _isect, 
			"members": _advertised_members(), 


			"port": Net.host_port(), 
			"in_progress": false, 
			"open": 2 * int(best_mode(999)) - _advertised_members(), 


			"inv": int(_invite.get("sid", 0)), 
			"pq": _party_askable(), 
			"hum": Net.human_count(), 


			"acc": _ni(_reserved.get("sid", 0)), 
			"rsv": _rsv_csv(), 


			"left": snappedf(_left_now(), 0.1), 

			"fm": _listed_forming(), 

			"lb": _lobby_band(), 
			"lw": _level_open(), 

			"bh": _member_hashes(), 
		}
		_listener.set_dest_address(_listener.get_packet_ip(), 
			_listener.get_packet_port())
		_listener.put_packet(JSON.stringify(reply).to_utf8_buffer())
		qlog("answered probe from %s:%d with %s" % [src, _listener.get_packet_port(), str(reply)])
