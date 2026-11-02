class_name SaveSeal
extends RefCounted























const _KEYS: = [
	"jv-pr0gress|7f3a91c2e8d4b605|sand+net+whistle|c41e9b07d2a8f356", 
]

static func _key(i: int) -> PackedByteArray:
	var raw: = String(_KEYS[i]).to_utf8_buffer()


	var out: = PackedByteArray()
	out.resize(raw.size())
	for j in raw.size():
		out[j] = raw[j] ^ ((j * 73 + 41) & 255)
	return out

static func _sign(data: String, key_index: int) -> String:
	return Crypto.new().hmac_digest(HashingContext.HASH_SHA256, _key(key_index), 
		data.to_utf8_buffer()).hex_encode()



static func seal(values: Dictionary, uid: String) -> Dictionary:
	var body: = {"u": uid, "v": values}
	var data: = Marshalls.utf8_to_base64(JSON.stringify(body))
	return {"d": data, "k": 0, "s": _sign(data, 0)}



static func open(s: Variant, uid: String) -> Variant:
	if not (s is Dictionary):
		return null
	var d: Dictionary = s
	var data: Variant = d.get("d")
	var sig: Variant = d.get("s")
	var k: = int(d.get("k", -1)) if (d.get("k") is int or d.get("k") is float) else -1
	if not (data is String) or not (sig is String) or k < 0 or k >= _KEYS.size():
		return null
	if _sign(data, k) != String(sig):
		return null
	var body: Variant = JSON.parse_string(Marshalls.base64_to_utf8(data))
	if not (body is Dictionary) or not ((body as Dictionary).get("v") is Dictionary):
		return null

	if String((body as Dictionary).get("u", "")) != uid:
		return null
	return (body as Dictionary)["v"]
