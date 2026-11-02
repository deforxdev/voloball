class_name DevBadge
extends RefCounted










enum Tier{NONE, GOLD, SILVER}

const GOLD_SIDS: Array[int] = [
	76561198743870148, 
]


const SILVER_SIDS: Array[int] = [




]

static func tier_of(sid: int) -> int:
	if sid == 0:
		return Tier.NONE
	if GOLD_SIDS.has(sid):
		return Tier.GOLD
	if SILVER_SIDS.has(sid):
		return Tier.SILVER
	return Tier.NONE

static func is_sid(sid: int) -> bool:
	return tier_of(sid) != Tier.NONE







const IMPOSTER: = "Imposter"

static func guard_name(name: String, sid: int) -> String:
	if tier_of(sid) == Tier.GOLD or not claims_dev(name):
		return name
	return IMPOSTER



static func is_imposter_name(name: String) -> bool:
	return name == IMPOSTER or name.begins_with(IMPOSTER + "[")







static func claims_dev(name: String) -> bool:
	var squashed: = ""
	var words: Array[String] = [""]
	for i in name.length():
		var ch: = name[i]
		var c: = _plain(ch.to_lower())
		if c == "":
			if words[-1] != "":
				words.append("")
			continue


		if i > 0 and words[-1] != "" and _upper(ch):
			var next: = name[i + 1] if i + 1 < name.length() else ""
			if not _upper(name[i - 1]) or (next != "" and next != next.to_upper()):
				words.append("")
		squashed += c
		words[-1] += c
	squashed = _undouble(squashed.replace("rn", "m").replace("ph", "f"))
	if squashed.contains("temkosoft"):
		return true
	for w in words:
		if _undouble(w.replace("rn", "m")) == "temko":
			return true
	return false

static func _upper(ch: String) -> bool:
	return ch != ch.to_lower()


static func _undouble(s: String) -> String:
	var out: = ""
	for ch in s:
		if out == "" or out[-1] != ch:
			out += ch
	return out



static func _plain(c: String) -> String:
	var code: = c.unicode_at(0)
	if code >= 65281 and code <= 65374:
		c = String.chr(code - 65248).to_lower()
	if _LOOKALIKE.has(c):
		return _LOOKALIKE[c]
	return c if c >= "a" and c <= "z" and c.length() == 1 else ""

const _LOOKALIKE: = {
	"0": "o", "1": "l", "3": "e", "4": "a", "5": "s", "7": "t", "8": "b", 
	"$": "s", "@": "a", "|": "l", "!": "l", "+": "t", 
	"à": "a", "á": "a", "â": "a", "ä": "a", "ã": "a", "å": "a", "ā": "a", 
	"è": "e", "é": "e", "ê": "e", "ë": "e", "ē": "e", "ė": "e", "ę": "e", 
	"ì": "i", "í": "i", "î": "i", "ï": "i", "ò": "o", "ó": "o", "ô": "o", 
	"ö": "o", "õ": "o", "ø": "o", "ō": "o", "ù": "u", "ú": "u", "û": "u", 
	"ü": "u", "ñ": "n", "ç": "c", "ś": "s", "š": "s", "ť": "t", "ţ": "t", 
	"ķ": "k", "ḱ": "k", "ḿ": "m", "ď": "d", "ŕ": "r", "ř": "r", "ł": "l", 
	"ľ": "l", "ŧ": "t", "ƒ": "f", "ν": "v", "ѵ": "v", 

	"а": "a", "е": "e", "о": "o", "р": "p", "с": "c", "т": "t", "к": "k", 
	"м": "m", "ѕ": "s", "і": "i", "ј": "j", "в": "b", "д": "d", "ԁ": "d", 
	"ο": "o", "κ": "k", "τ": "t", "ε": "e", "α": "a", "ρ": "p", "ι": "i", 
	"ѐ": "e", "ё": "e", "ќ": "k", 
}



static func is_owner(sid: int) -> bool:
	return tier_of(sid) == Tier.GOLD

static func is_owner_peer(peer_id: int) -> bool:
	return peer_tier(peer_id) == Tier.GOLD


static func my_tier() -> int:
	return tier_of(Net.my_steam_id())






static func peer_tier(peer_id: int) -> int:
	if peer_id <= 0:
		return Tier.NONE
	if peer_id == Net.get_multiplayer().get_unique_id():
		return my_tier()
	var sid: = int((Net.players.get(peer_id, {}) as Dictionary).get("sid", 0))
	var t: = tier_of(sid)
	if t == Tier.GOLD and not Net.dev_trusted(peer_id, sid):
		return Tier.NONE
	return t











const PROOF_PUBLIC: = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7CObu0hXzYPE0iCIQx/P\nHhdqjFdh/x6YbF7KSmsQZE3ObtccVXFtMJ7vkgSyxtvd10+GUaQ/Tv53mTyBV6nQ\nWSLmKseFA+9nLL+uiknmvqLvt0Ghnjh8Q7Z6vYRhHlom4VdJ91lvdZFIGh21O/3z\n7BNwTg/XP5Wdhhd1TwYyshPawbli8ySqCBiDSDnsrLoF+IaqZSuNLe1OcVAbuYrA\nOFfl4D+RFbwV4WA8u8ut9CtjGQs9uSjjF03bZuumOGk4TtrHNMrHR6qXgcxysFXy\nGk4qJrMu6TEw2X2bW4aFq2EpL9k+6SkpI1z340TuovAsbPB4/nLbsb4W4/UlehQJ\n8QIDAQAB\n-----END PUBLIC KEY-----\n"









static var _proof_pub: CryptoKey
static var _proof_priv: CryptoKey
static var _proof_priv_read: = false


static func proof_key_file() -> String:
	var base: = OS.get_environment("APPDATA")
	if base == "":
		base = OS.get_environment("HOME").path_join(".config")
	return base.path_join("temkosoft").path_join("jv_dev_badge.key")

static func _proof_message(sid: int, peer_id: int, nonce: String) -> PackedByteArray:
	return ("JVDEV1|%d|%d|%s" % [sid, peer_id, nonce]).sha256_buffer()



static func proof_sign(peer_id: int, nonce: String) -> PackedByteArray:
	if my_tier() != Tier.GOLD:
		return PackedByteArray()


	if "--no-dev-key" in LaunchGate.dev_args():
		return PackedByteArray()
	if not _proof_priv_read:
		_proof_priv_read = true
		if FileAccess.file_exists(proof_key_file()):
			var k: = CryptoKey.new()
			if k.load(proof_key_file()) == OK:
				_proof_priv = k
	if _proof_priv == null:
		return PackedByteArray()
	return Crypto.new().sign(HashingContext.HASH_SHA256, 
		_proof_message(Net.my_steam_id(), peer_id, nonce), _proof_priv)

static func proof_ok(sid: int, peer_id: int, nonce: String, sig: PackedByteArray) -> bool:
	if tier_of(sid) != Tier.GOLD or nonce == "" or sig.size() != 256:
		return false
	if _proof_pub == null:
		_proof_pub = CryptoKey.new()
		if _proof_pub.load_from_string(PROOF_PUBLIC, true) != OK:
			_proof_pub = null
			return false
	return Crypto.new().verify(HashingContext.HASH_SHA256, 
		_proof_message(sid, peer_id, nonce), sig, _proof_pub)
