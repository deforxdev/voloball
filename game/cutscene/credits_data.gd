class_name CreditsData
extends RefCounted













const PEOPLE_DIR: = "res://game/images/credits/people"
const BACKGROUNDS_DIR: = "res://game/images/credits/backgrounds"



static func people() -> Array:
	return [
		{"name": "deforx", "role": "creator", 
			"icon": PEOPLE_DIR + "/deforx.png"}, 
		{"name": "Деструктивний критик", "role": "critic", 
			"icon": PEOPLE_DIR + "/deg.png"}, 
		{"name": "Кодова мавпа", "role": "code monkey", 
			"icon": PEOPLE_DIR + "/ai.png"}, 
	]





const THANK_YOU_TO: = "Haruichi Furudate"
const QUOTE: = "Volleyball is a sport where you're always looking up!"
const THANK_YOU_FOR: = "for making me fall in love with the sport of volleyball. if it wasn't for them, this game would never exist."



static func thanks() -> Array:
	return [
		{"for": "frequent alpha netcode testing", 
			"names": ["Avovet", "Somnus", "Ayudin", "Saguinee", "Maybesky"]}, 
		{"for": "certain hat and hair cosmetics", 
			"names": ["Avovet", "Somnus"]}, 
	]

const ASSETS_LINE: = "various 3d assets, 2d assets, sfx and ui assets in the form of cc0 were taken from the internet and used throughout the project."

const ENGINE_LINE: = "made with godot engine"


const FAREWELL: = "thank you for playing!"




const GODOT_SIGNOFF: = "-- Godot Engine <https://godotengine.org>"
const GODOT_LINK: = "https://godotengine.org"
const GODOT_LICENSE: = "Copyright (c) 2014-present Godot Engine contributors.\nCopyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."










static func picture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res: Resource = load(path)
		if res is Texture2D:
			return res

		if res is Image:
			return ImageTexture.create_from_image(res)
	if FileAccess.file_exists(path):
		var img: = Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null:
			return ImageTexture.create_from_image(img)
	return null



static func backgrounds() -> Array:
	var names: = {}
	for f in DirAccess.get_files_at(BACKGROUNDS_DIR):
		var n: = String(f).trim_suffix(".import").trim_suffix(".remap")
		if n.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
			names[n] = true
	var sorted: = names.keys()
	sorted.sort()
	var out: Array = []
	for n in sorted:
		var tex: = picture(BACKGROUNDS_DIR.path_join(String(n)))
		if tex != null:
			out.append(tex)
	return out




static func sections() -> Array:
	var out: Array = [
		{"gap": 60}, 
		{"title": "VOLOBALL"}, 
		{"line": "a deforx game"}, 
		{"gap": 50}, 
	]
	for p in people():
		out.append({"header": String(p.role)})
		out.append({"entries": [{"name": String(p.name)}]})
		out.append({"gap": 40})
	out.append({"gap": 40})
	if THANK_YOU_TO != "":
		out.append({"line": "\"%s\"" % QUOTE})
		out.append({"header": "Thank you to " + THANK_YOU_TO})
		out.append({"line": THANK_YOU_FOR})
		out.append({"gap": 40})
	out.append({"header": "Made with"})
	out.append({"line": "Godot Engine"})
	out.append({"gap": 30})
	out.append({"line": ASSETS_LINE})
	out.append({"gap": 60})
	out.append({"title": "Thanks for playing!"})
	out.append({"gap": 200})
	return out
