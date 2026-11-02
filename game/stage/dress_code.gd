class_name DressCode
extends RefCounted









const CURRENT: = 0
const KITS: = 1
const PINNIES: = 2
const OWN: = 3
const LABELS: = ["stage default", "captain uniforms", "pinnies", "casual"]

static func clamp_rule(rule: int) -> int:
	return clampi(rule, CURRENT, OWN)


static func rule_now() -> int:
	return CURRENT if GameConfig.quick_match else clamp_rule(GameConfig.outfit_rule)


static func casual(stage_id: String, rule: int) -> bool:
	match clamp_rule(rule):
		KITS:
			return false
		PINNIES, OWN:
			return true
	return bool(Stage.val(stage_id, "casual", false))


static func pinny(stage_id: String, rule: int) -> bool:
	match clamp_rule(rule):
		KITS, OWN:
			return false
		PINNIES:
			return true
	return casual(stage_id, rule) and bool(Stage.val(stage_id, "scrimmage_pinny", false))


static func team_colours(stage_id: String, rule: int) -> bool:
	return not casual(stage_id, rule) or pinny(stage_id, rule)
