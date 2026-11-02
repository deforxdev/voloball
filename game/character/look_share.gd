class_name LookShare
extends RefCounted











const LookPack: = preload("res://game/character/look_pack.gd")

const TAG: = "JV2:"
const TAG_V1: = "JV1:"
const MAX_LOOK_BYTES: = 65536
const MAX_CODE_CHARS: = 16384
const MAX_PICTURE_BYTES: = 33554432
const PNG_KEY: = "jvlook"
const _PNG_SIG: = [137, 80, 78, 71, 13, 10, 26, 10]
const _B64: = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

const _B64URL: = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

static func encode(c: CharacterConfig) -> String:
	var d: = c.look_dict()
	d.erase("name")
	var packed: = LookPack.pack(d)
	var check: = crc32(packed) & 65535
	var body: = PackedByteArray([check >> 8, check & 255])
	body.append_array(packed)
	return TAG + _b64url(body)

static func _b64url(b: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(b).replace("+", "-").replace("/", "_").replace("=", "")


static func encode_v1(c: CharacterConfig) -> String:
	var d: = c.look_dict()
	d.erase("name")
	var packed: = JSON.stringify(d).to_utf8_buffer().compress(FileAccess.COMPRESSION_DEFLATE)
	var body: = _be32(crc32(packed))
	body.append_array(packed)
	return TAG_V1 + Marshalls.raw_to_base64(body)


static func has_code(text: String) -> bool:
	return text.containsn(TAG) or text.containsn(TAG_V1)





static func decode(text: String) -> CharacterConfig:
	var at: = text.findn(TAG)
	if at != -1:
		return _decode_v2(_run(text, at + TAG.length(), _B64URL))
	at = text.findn(TAG_V1)
	if at == -1:
		return null
	return _decode_v1(_run(text, at + TAG_V1.length(), _B64))




static func _run(text: String, start: int, chars: String) -> String:
	var end: = start
	var stop: = mini(text.length(), start + MAX_CODE_CHARS + 1)
	while end < stop and chars.contains(text[end]):
		end += 1
	if end - start > MAX_CODE_CHARS:
		return ""
	return text.substr(start, end - start)

static func _decode_v2(s: String) -> CharacterConfig:
	var body: = _v2_body(s)
	if body.size() < 3:
		return null
	var packed: = body.slice(2)
	if ((body[0] << 8) | body[1]) != (crc32(packed) & 65535):
		return null
	var d: = LookPack.unpack(packed)
	if d.is_empty():
		return null
	return CharacterConfig.from_dict(d)



static func _v2_body(s: String) -> PackedByteArray:
	if s.length() < 4 or s.length() % 4 == 1:
		return PackedByteArray()
	return Marshalls.base64_to_raw(s.replace("-", "+").replace("_", "/") + "=".repeat((4 - s.length() % 4) % 4))







const QR_MARK: = 74

static func qr_bytes(code: String) -> PackedByteArray:
	var at: = code.findn(TAG)
	if at == -1:
		return PackedByteArray()
	var body: = _v2_body(_run(code, at + TAG.length(), _B64URL))
	if body.size() < 3:
		return PackedByteArray()
	var out: = PackedByteArray([QR_MARK])
	out.append_array(body)
	return out


static func code_from_qr(b: PackedByteArray) -> String:
	if b.size() < 4 or b[0] != QR_MARK:
		return ""
	return TAG + _b64url(b.slice(1))


static func qr_grid(code: String) -> Array:
	var b: = qr_bytes(code)
	return [] if b.is_empty() else QrCode.make(b)



static func code_in_picture(path: String) -> String:
	var f: = FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() > MAX_PICTURE_BYTES:
		return ""
	var bytes: = f.get_buffer(f.get_length())
	f.close()
	var code: = code_in_png_bytes(bytes)
	return code if code != "" else code_in_image(_image_of(bytes))


static func code_in_image(img: Image) -> String:
	if img == null or img.is_empty():
		return ""
	return code_from_qr(QrCode.read(img))


static func _image_of(bytes: PackedByteArray) -> Image:
	var img: = Image.new()
	var err: = ERR_FILE_UNRECOGNIZED
	if bytes.size() >= 8 and bytes.slice(0, 8) == PackedByteArray(_PNG_SIG):
		err = img.load_png_from_buffer(bytes)
	elif bytes.size() >= 3 and bytes[0] == 255 and bytes[1] == 216 and bytes[2] == 255:
		err = img.load_jpg_from_buffer(bytes)
	elif bytes.size() >= 12 and bytes.slice(0, 4).get_string_from_ascii() == "RIFF"\
	and bytes.slice(8, 12).get_string_from_ascii() == "WEBP":
		err = img.load_webp_from_buffer(bytes)
	elif bytes.size() >= 2 and bytes[0] == 66 and bytes[1] == 77:
		err = img.load_bmp_from_buffer(bytes)
	return img if err == OK else null

static func _decode_v1(s: String) -> CharacterConfig:
	if s.length() < 12 or s.length() % 4 != 0 or s.trim_suffix("=").trim_suffix("=").contains("="):
		return null
	var body: = Marshalls.base64_to_raw(s)
	if body.size() < 5:
		return null
	var packed: = body.slice(4)
	if _read_be32(body, 0) != crc32(packed):
		return null
	var raw: = packed.decompress_dynamic(MAX_LOOK_BYTES, FileAccess.COMPRESSION_DEFLATE)
	if raw.is_empty():
		return null
	var json: = JSON.new()
	if json.parse(raw.get_string_from_utf8()) != OK or not (json.data is Dictionary):
		return null
	return CharacterConfig.from_dict(json.data)







static func png_with_code(img: Image, code: String) -> PackedByteArray:
	var png: = img.save_png_to_buffer()
	var end: = _iend_at(png)
	if end == -1:
		return png
	var typed: = "tEXt".to_ascii_buffer()
	typed.append_array(PNG_KEY.to_ascii_buffer())
	typed.append(0)
	typed.append_array(code.to_ascii_buffer())
	var out: = png.slice(0, end)
	out.append_array(_be32(typed.size() - 4))
	out.append_array(typed)
	out.append_array(_be32(crc32(typed)))
	out.append_array(png.slice(end))
	return out


static func code_in_png(path: String) -> String:
	var f: = FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() > MAX_PICTURE_BYTES:
		return ""
	var bytes: = f.get_buffer(f.get_length())
	f.close()
	return code_in_png_bytes(bytes)

static func code_in_png_bytes(bytes: PackedByteArray) -> String:
	if bytes.size() < 8:
		return ""
	for i in 8:
		if bytes[i] != _PNG_SIG[i]:
			return ""
	var pos: = 8
	while pos + 12 <= bytes.size():
		var n: = _read_be32(bytes, pos)
		var kind: = bytes.slice(pos + 4, pos + 8).get_string_from_ascii()
		if n < 0 or pos + 12 + n > bytes.size() or kind == "IEND":
			break
		if kind == "tEXt" and n <= PNG_KEY.length() + 1 + MAX_CODE_CHARS:
			var data: = bytes.slice(pos + 8, pos + 8 + n)
			var nul: = data.find(0)
			if nul != -1 and data.slice(0, nul).get_string_from_ascii() == PNG_KEY:
				return data.slice(nul + 1).get_string_from_ascii()
		pos += 12 + n
	return ""

static func _iend_at(png: PackedByteArray) -> int:
	var pos: = 8
	while pos + 12 <= png.size():
		var n: = _read_be32(png, pos)
		if png.slice(pos + 4, pos + 8).get_string_from_ascii() == "IEND":
			return pos
		pos += 12 + n
	return -1



static var _crc_table: = PackedInt64Array()


static func crc32(b: PackedByteArray) -> int:
	if _crc_table.is_empty():
		_crc_table.resize(256)
		for n in 256:
			var c: = n
			for _k in 8:
				c = (3988292384 ^ (c >> 1)) if (c & 1) else (c >> 1)
			_crc_table[n] = c
	var crc: = 4294967295
	for x in b:
		crc = _crc_table[(crc ^ x) & 255] ^ (crc >> 8)
	return crc ^ 4294967295

static func _be32(v: int) -> PackedByteArray:
	return PackedByteArray([(v >> 24) & 255, (v >> 16) & 255, (v >> 8) & 255, v & 255])

static func _read_be32(b: PackedByteArray, at: int) -> int:
	return (b[at] << 24) | (b[at + 1] << 16) | (b[at + 2] << 8) | b[at + 3]
