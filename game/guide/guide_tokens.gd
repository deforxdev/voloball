class_name GuideTokens
extends RefCounted


















const _TOKEN: = "\\{(key|kb|pad|name):([a-z0-9_]+)\\}"

static var _re: RegEx = null

static var gen: = 0
static var _tags: RegEx = null

static func _token_re() -> RegEx:
	if _re == null:
		_re = RegEx.create_from_string(_TOKEN)
	return _re

static func _tag_re() -> RegEx:
	if _tags == null:
		_tags = RegEx.create_from_string("\\[/?[a-z_]+[^\\]]*\\]")
	return _tags

static func has_tokens(text: String) -> bool:
	return _token_re().search(text) != null




static func rich(text: String, px: int, tint: = Color.WHITE) -> String:
	var out: = ""
	var at: = 0
	for m in _token_re().search_all(text):
		out += text.substr(at, m.get_start() - at)
		out += _glyph_bb(m.get_string(1), m.get_string(2), px, tint)
		at = m.get_end()
	return out + text.substr(at)






static func fill(r: RichTextLabel, text: String, px: int, ink: Color, wrap: = "") -> void :
	r.clear()
	if wrap != "":
		r.append_text("[%s]" % wrap)
	var at: = 0
	for m in _token_re().search_all(text):
		r.append_text(text.substr(at, m.get_start() - at))
		var which: = m.get_string(1)
		var act: = m.get_string(2)
		at = m.get_end()
		if which == "name":
			r.append_text(kb_name(act) if not _on_pad() else pad_name(act))
			continue
		var pad: = which == "pad" or (which == "key" and _on_pad())
		var tex: = paper_glyph(_glyph(act, pad), ink)
		if tex == null:
			var words: = pad_name(act) if pad else kb_name(act)
			r.append_text("[b]%s[/b]" % (words if words != "" else act))
			continue
		r.add_image(tex, 0, maxi(8, px), Color.WHITE, INLINE_ALIGNMENT_CENTER)
	r.append_text(text.substr(at))
	if wrap != "":
		r.append_text("[/%s]" % wrap.get_slice("=", 0))

static var _paper: = {}

static func paper_glyph(tex: Texture2D, ink: Color) -> Texture2D:
	if tex == null:
		return null
	var path: = tex.resource_path
	var key: = "%s|%s" % [path, ink.to_html()]
	if _paper.has(key):
		return _paper[key]
	var big: = path.replace("/Default/", "/Double/")
	var src: Texture2D = load(big) as Texture2D if big != path and ResourceLoader.exists(big) else tex
	var img: = src.get_image()
	if img == null:
		_paper[key] = tex
		return tex
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c: = img.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var hi: = maxf(c.r, maxf(c.g, c.b))
			var lo: = minf(c.r, minf(c.g, c.b))
			if hi - lo < 0.2 and hi > 0.5:
				img.set_pixel(x, y, Color(ink, c.a))
	var out: = ImageTexture.create_from_image(img)
	_paper[key] = out
	return out


static func plain(text: String) -> String:
	var out: = ""
	var at: = 0
	for m in _token_re().search_all(text):
		out += text.substr(at, m.get_start() - at)
		var act: = m.get_string(2)
		out += pad_name(act) if m.get_string(1) == "pad" else kb_name(act)
		at = m.get_end()
	out += text.substr(at)
	return _tag_re().sub(out, "", true)

static func _glyph_bb(which: String, act: String, px: int, tint: = Color.WHITE) -> String:
	if which == "name":
		return kb_name(act) if not _on_pad() else pad_name(act)
	var pad: = which == "pad" or (which == "key" and _on_pad())
	var tex: = _glyph(act, pad)
	if tex == null or tex.resource_path == "":
		var words: = pad_name(act) if pad else kb_name(act)
		return "[b]%s[/b]" % (words if words != "" else act)
	var path: = tex.resource_path
	if path.contains("_color_"):
		return "[img height=%d]%s[/img]" % [maxi(8, px), path]
	return "[img height=%d color=#%s]%s[/img]" % [maxi(8, px), tint.to_html(false), path]

static func _prompts() -> Node:
	var loop: = Engine.get_main_loop() as SceneTree
	return loop.root.get_node_or_null("InputPrompts") if loop != null else null

static func _on_pad() -> bool:
	var ip: = _prompts()
	return ip != null and bool(ip.call("using_gamepad"))

static func _glyph(act: String, pad: bool) -> Texture2D:
	var ip: = _prompts()
	if ip == null:
		return null
	var kind: int = 1 if pad else 0
	return ip.call("glyph_on", act, kind, int(ip.call("active_style"))) as Texture2D


static func kb_name(act: String) -> String:
	if act == "aim":
		return "mouse"
	return HowToPlay.keys_for(act)


static func pad_name(act: String) -> String:
	match act:
		"move":
			return "left stick"
		"aim":
			return "right stick"
	if not InputMap.has_action(act):
		return ""
	var binds: = InputBinds
	for e in InputMap.action_get_events(act):
		if e is InputEventJoypadButton or e is InputEventJoypadMotion:
			return String(binds.label_for_data(binds.event_to_data(e)))
	return ""





const CONTROLS_HEAD: = ["action", "keyboard", "controller"]



static func live_rows(live: String) -> Array:
	var rows: = controls_rows()
	if not live.contains(":"):
		return rows
	var body: = rows.slice(1)
	var half: = ceili(body.size() / 2.0)
	var part: = body.slice(0, half) if live.ends_with(":0") else body.slice(half)
	return [rows[0]] + part



const CONTROLS_LABELS: = {"serve": "spawn ball (freeplay)"}

static func controls_rows() -> Array:
	var rows: Array = [CONTROLS_HEAD.duplicate()]
	rows.append(["move", "{kb:move_forward}{kb:move_left}{kb:move_back}{kb:move_right}", "{pad:move}"])
	rows.append(["aim", "{kb:aim}", "{pad:aim}"])
	for entry in InputBinds.REBINDABLE:
		var e: Dictionary = entry
		var act: = String(e["action"])


		if act.begins_with("move_") or not InputBinds.listed(e) or bool(e.get("unbound", false))\
		or bool(e.get("chat", false)):
			continue
		if not InputMap.has_action(act):
			continue
		rows.append([String(CONTROLS_LABELS.get(act, e["label"])), 
			"{kb:%s}" % act if bool(e.get("kb", false)) else "", 
			"{pad:%s}" % act if bool(e.get("pad", false)) else ""])
	return rows
