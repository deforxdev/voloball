class_name Progression
extends RefCounted





















const XP_PER_RALLY: = 3
const XP_PER_SET: = 5
const WIN_BONUS_XP: = 15








const LEVEL_COST: = 400
const LEVEL_MAX: = 999









const COINS_PER_RALLY: = 3
const COINS_PER_SET: = 5
const WIN_BONUS_COINS: = 10
const MVP_BONUS_COINS: = 15


const FLOOR_RALLIES: = 14
const MATCH_FLOOR_COINS: = 75
const LEVELUP_COINS: = 150






const CLAIM_XP_PER_COIN: = 0.8

static func claim_xp(coins: int) -> int:
	return int(round(coins * CLAIM_XP_PER_COIN))

static func xp_for_next(_level: int) -> int:
	return LEVEL_COST




static func debug_set_level(lv: int, who: SavedProfile = null) -> int:
	var p: = who if who != null else ProfileStore.active()
	if p == null:
		return 0
	p.level = clampi(lv, 1, LEVEL_MAX)
	p.xp = 0
	if p == ProfileStore.active() and GameConfig.character != null:
		GameConfig.character.level = shown_level(p)
	ProfileStore.save()
	return p.level






static func shown_level(who: SavedProfile = null) -> int:
	if Net.local_imposter():
		return 0
	return verified_level(who)



static func verified_level(who: SavedProfile = null) -> int:
	if LaunchGate.economy_off():
		return 0
	var p: = who if who != null else ProfileStore.active()


	if p == null or p.unverified:
		return 0
	return clampi(p.level, 1, LEVEL_MAX)







static func grant_match(won: bool, sets_played: int, rallies: int, mvp: = false, 
		who: SavedProfile = null) -> Dictionary:
	var p: = who if who != null else ProfileStore.active()
	if p == null:
		return {}
	var s: = maxi(1, sets_played)
	var r: = maxi(0, rallies)
	var xp_gain: = XP_PER_RALLY * r + XP_PER_SET * s + (WIN_BONUS_XP if won else 0)
	var coin_gain: = COINS_PER_RALLY * r + COINS_PER_SET * s\
	+ (WIN_BONUS_COINS if won else 0) + (MVP_BONUS_COINS if mvp else 0)
	if r >= FLOOR_RALLIES:
		coin_gain = maxi(coin_gain, MATCH_FLOOR_COINS)
	var start_level: = p.level
	var start_xp: = p.xp
	var coins_before: = p.coins
	var levelup_coins: = _bank_xp(p, xp_gain)
	p.coins += coin_gain + levelup_coins
	_banked(p)
	return {
		"xp_gain": xp_gain, 
		"coins_gain": coin_gain + levelup_coins, 
		"levels_gained": p.level - start_level, 
		"level": p.level, 
		"xp_into_level": p.xp, 
		"xp_needed": xp_for_next(p.level), 
		"coins_total": p.coins, 

		"start_level": start_level, "start_xp": start_xp, 
		"coins_before": coins_before, 
		"coins_match": coin_gain, "coins_levelup": levelup_coins, 
		"rallies": r, "sets": s, "won": won, "mvp": mvp, 
		"max_level": p.level >= LEVEL_MAX, 
	}



static func add_xp(n: int, to: SavedProfile = null) -> int:
	var p: = to if to != null else ProfileStore.active()
	if p == null or n <= 0:
		return 0
	var levelup_coins: = _bank_xp(p, n)
	p.coins += levelup_coins
	_banked(p)
	return levelup_coins




static func _bank_xp(p: SavedProfile, n: int) -> int:
	var levelup_coins: = 0
	if p.level < LEVEL_MAX:
		p.xp += n
	while p.level < LEVEL_MAX and p.xp >= xp_for_next(p.level):
		p.xp -= xp_for_next(p.level)
		p.level += 1
		levelup_coins += LEVELUP_COINS
	if p.level >= LEVEL_MAX:
		p.level = LEVEL_MAX
		p.xp = 0
	return levelup_coins

static func _banked(p: SavedProfile) -> void :


	if p == ProfileStore.active() and GameConfig.character != null:
		GameConfig.character.level = shown_level(p)
	ProfileStore.save()
	_purse_moved(p)











const SPACEWAR_COINS: = 10000

static func spacewar_grant(p: SavedProfile) -> bool:
	if p == null or p.spacewar_coins or not LaunchGate.is_spacewar():
		return false
	p.spacewar_coins = true
	p.coins += SPACEWAR_COINS
	return true

static func add_coins(n: int, to: SavedProfile = null) -> void :
	var p: = to if to != null else ProfileStore.active()
	if p == null or n <= 0:
		return
	p.coins += n
	ProfileStore.save()
	_purse_moved(p)



static func _purse_moved(p: SavedProfile) -> void :
	Achievements.notify_for(p, "purse", {"coins": p.coins})

static func is_free(price: int) -> bool:
	return price <= 0





static func owns(id: String, price: = 0, who: SavedProfile = null) -> bool:
	if is_free(price):
		return true



	if LaunchGate.economy_off():
		return true
	var p: = who if who != null else ProfileStore.active()
	return p != null and p.owned.has(id)

static func can_afford(price: int, who: SavedProfile = null) -> bool:
	var p: = who if who != null else ProfileStore.active()
	return p != null and p.coins >= price



static func purchase(id: String, price: int, who: SavedProfile = null) -> bool:
	if is_free(price) or owns(id, price, who) or not can_afford(price, who):
		return false
	var p: = who if who != null else ProfileStore.active()
	if p == null:
		return false
	p.coins -= price
	p.owned[id] = true
	ProfileStore.save()
	return true
