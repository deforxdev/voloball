class_name AccessoryCatalog
extends RefCounted










const DIRS: = [
	"res://game/character/accessories/", 
	"res://game/character/hats/", 
]

static var _cache: Array = []
static var _scanned: = false
static var _mobile_items: Dictionary = {}

static func all() -> Array:
	if not _scanned:
		_scanned = true
		_cache = _scan()
	return _cache

static func for_category(category: String) -> Array:
	var out: Array = []
	for it in all():
		if it.category == category:
			out.append(it)
	return out

static func by_id(id: String) -> AccessoryItem:
	if id == "":
		return null
	if MobileRender.enabled():
		if _mobile_items.has(id):
			return _mobile_items[id] as AccessoryItem
		var selected: AccessoryItem = null
		if id.is_valid_filename():
			for base in DIRS:
				var path: String = base + id + ".tres"
				if ResourceLoader.exists(path):
					selected = load(path) as AccessoryItem
					break
		if _mobile_items.size() >= 6:
			_mobile_items.erase(_mobile_items.keys()[0])
		_mobile_items[id] = selected
		return selected
	for it in all():
		if it.id == id:
			return it
	return null

static func _scan() -> Array:
	if MobileRender.enabled():
		var entries: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://game/mobile/accessory_index.json"))
		var lightweight: Array = []
		for entry in entries:
			var item := AccessoryItem.new()
			item.id = entry.id
			item.display_name = entry.display_name
			item.category = entry.category
			item.price = int(entry.price)
			item.portrait = entry.portrait
			item.worn_on_back = entry.worn_on_back
			lightweight.append(item)
		return lightweight
	var found: Array = []
	var seen: = {}
	for base in DIRS:
		var dir: = DirAccess.open(base)
		if dir == null:
			continue
		for f in dir.get_files():
			var path: = _res_path(base, String(f))
			if path == "" or seen.has(path):
				continue
			if not ResourceLoader.exists(path):
				continue
			var res: = load(path)
			if res is AccessoryItem:
				var item: = res as AccessoryItem
				if item.id == "":


					item.id = path.get_file().trim_suffix(".tres")
				seen[path] = true
				found.append(item)
	found.sort_custom( func(a, b): return a.id < b.id)
	return found


static func _res_path(base: String, file_name: String) -> String:
	var name: = file_name
	for wrapper in [".remap", ".import"]:
		if name.ends_with(wrapper):
			name = name.trim_suffix(wrapper)
			break
	if not name.ends_with(".tres"):
		return ""
	return base + name
