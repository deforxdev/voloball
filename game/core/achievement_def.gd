class_name AchievementDef
extends RefCounted


















var id: = ""
var title: = ""
var desc: = ""
var kind: = "global"
var event: = ""
var target: = 1
var coins: = 0
var steam: = ""
var filter: = Callable()
var unit: = ""





var track: = ""
var peak: = true



var split: = {}

var split_words: = {}

func tracking(key: String, keep_peak: = true) -> AchievementDef:
	track = key
	peak = keep_peak
	return self

func split_into(caps: Dictionary, words: Dictionary) -> AchievementDef:
	split = caps
	split_words = words
	var sum: = 0
	for k in caps:
		sum += int(caps[k])
	target = maxi(1, sum)
	return self


func live_desc(parts: Dictionary) -> String:
	if split.is_empty() or parts.is_empty():
		return desc
	var bits: Array = []
	for k in split:
		bits.append("%s %d / %d" % [String(split_words.get(k, k)), mini(int(parts.get(k, 0)), 
			int(split[k])), int(split[k])])
	return "   ".join(bits)

func _init(id_in: String, title_in: String, desc_in: String, kind_in: String, 
		event_in: String, target_in: = 1, coins_in: = 0, steam_in: = "", 
		filter_in: = Callable()) -> void :
	id = id_in
	title = title_in
	desc = desc_in
	kind = kind_in
	event = event_in
	target = maxi(1, target_in)
	coins = coins_in
	steam = steam_in
	filter = filter_in


func progress_text(value: int) -> String:
	if unit == "sec":
		return "%dm / %dm" % [value / 60, target / 60]
	return "%d / %d" % [value, target]

func counts(data: Dictionary) -> bool:
	if not filter.is_valid():
		return true
	var r: Variant = filter.call(data)
	return r is bool and r
