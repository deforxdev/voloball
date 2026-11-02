extends Node











const SAVE_EVERY: = 120.0

var _save_t: = 0.0
var _orphan: = {}




var data: Dictionary:
	get:
		var p: = ProfileStore.active()
		return p.stats if p != null else _orphan

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void :
	var d: = data
	d["playtime"] = float(d.get("playtime", 0.0)) + delta
	_save_t += delta
	if _save_t >= SAVE_EVERY and not ProfileStore.hold_saves:
		save_now()

func _exit_tree() -> void :
	save_now()

func bump(key: String, n: = 1) -> void :
	var d: = data
	d[key] = int(d.get(key, 0)) + n









const EVENT_STATS: = {
	"jumps": ["jump", ""], 
	"bam_jumps": ["jump", "bam"], 
	"dive_receives": ["receive", "dive"], 
	"aces": ["point", "ace"], 
	"quick_chats": ["quick_chat", ""], 
	"collisions": ["dive_crash", ""], 
	"net_crashes": ["net_dive", ""], 
}
const COLLISION_EVENTS: = ["dive_crash", "air_bump", "stomp"]

func tally(p: SavedProfile, event: String, data: Dictionary) -> void :
	if p == null:
		return
	for key in EVENT_STATS:
		var rule: Array = EVENT_STATS[key]
		var hit: bool = String(rule[0]) == event or (key == "collisions" and event in COLLISION_EVENTS)
		if hit and (String(rule[1]) == "" or bool(data.get(rule[1], false))):
			p.stats[key] = int(p.stats.get(key, 0)) + 1



func record_match(row: Dictionary, won: bool) -> void :
	bump("matches")
	if won:
		bump("wins")
	bump("points", int(row.get("pts", 0)))
	bump("spikes", int(row.get("spk", 0)))
	bump("blocks", int(row.get("blk", 0)))
	bump("receives", int(row.get("rcv", 0)))
	bump("sets", int(row.get("set", 0)))
	bump("assists", int(row.get("ast", 0)))
	save_now()




func record_history(entry: Dictionary) -> void :
	var p: = ProfileStore.active()
	if p == null:
		return
	p.match_history.push_front(entry)
	while p.match_history.size() > SavedProfile.MATCH_HISTORY_MAX:
		p.match_history.pop_back()
	save_now()


func history() -> Array:
	var p: = ProfileStore.active()
	return p.match_history if p != null else []



func winrate() -> float:
	var d: = data
	var m: = int(d.get("matches", 0))
	if m == 0:
		return 0.5
	return float(d.get("wins", 0)) / float(m)

func save_now() -> void :
	_save_t = 0.0
	ProfileStore.save()
