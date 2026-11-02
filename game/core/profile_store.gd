extends Node















signal changed

const FILE: = "profiles.json"
const TITLES: = preload("res://game/titles/title_catalog.gd")
const PROFILE_MAX: = 12







const FORMAT: = 2


const BACKUP: = FILE + ".bak"

var profiles: Array[SavedProfile] = []
var active_index: = 0









var seeded_fresh: = false
var recently_deleted: Array[SavedProfile] = []
const DELETED_MAX: = 10

const LEGACY_CAREER: = "user://career.cfg"

func _ready() -> void :
	_load()
	_migrate_legacy_career()
	_migrate_legacy_character()




	var p: = active()
	if p != null:
		_apply_profile(p)

	var paid: = false
	for sp in profiles:
		paid = Progression.spacewar_grant(sp) or paid
	if paid:
		_save()


	if GameConfig.has_signal("settings_saved"):
		GameConfig.settings_saved.connect(_on_settings_saved)

func active() -> SavedProfile:
	if profiles.is_empty():
		return null
	active_index = clampi(active_index, 0, profiles.size() - 1)
	return profiles[active_index]



func create_profile(display_name: String) -> SavedProfile:
	if profiles.size() >= PROFILE_MAX:
		return null
	var p: = SavedProfile.new()
	p.set_name(display_name)


	p.character = CharacterConfig.random(null, true, p).to_dict()
	Progression.spacewar_grant(p)
	profiles.append(p)
	_save()
	changed.emit()
	return p

func switch_to(index: int) -> void :
	if index < 0 or index >= profiles.size() or index == active_index:
		return
	active_index = index
	var p: = active()
	if p != null:
		_apply_profile(p)
	_save()
	changed.emit()

func rename_profile(index: int, display_name: String) -> void :
	if index < 0 or index >= profiles.size():
		return
	profiles[index].set_name(display_name)
	_save()
	changed.emit()

func delete_profile(index: int) -> void :



	if index <= 0 or index >= profiles.size() or profiles.size() <= 1:
		return

	var gone: = profiles[index]
	profiles.remove_at(index)
	recently_deleted.push_front(gone)
	while recently_deleted.size() > DELETED_MAX:
		recently_deleted.pop_back()
	if active_index >= profiles.size():
		active_index = profiles.size() - 1
	var p: = active()
	if p != null:
		_apply_profile(p)
	_save()
	changed.emit()


func restore_profile(deleted_index: int) -> void :
	if deleted_index < 0 or deleted_index >= recently_deleted.size():
		return
	if profiles.size() >= PROFILE_MAX:
		return
	var p: SavedProfile = recently_deleted[deleted_index]
	recently_deleted.remove_at(deleted_index)
	profiles.append(p)
	_save()
	changed.emit()


func purge_deleted(deleted_index: int) -> void :
	if deleted_index < 0 or deleted_index >= recently_deleted.size():
		return
	recently_deleted.remove_at(deleted_index)
	_save()
	changed.emit()

func purge_all_deleted() -> void :
	if recently_deleted.is_empty():
		return
	recently_deleted.clear()
	_save()
	changed.emit()






func _apply_profile(p: SavedProfile) -> void :
	p.apply_to_config(GameConfig)
	InputBinds.apply(p.bindings)
	_apply_character(p)




signal bindings_changed(p: SavedProfile)








func set_binding_on(p: SavedProfile, action: String, slot: String, data: Variant) -> void :
	if p == null or data == null:
		return


	var kind: = InputBinds.slot_kind(slot)
	for other in InputBinds.REBINDABLE:
		var oa: String = other.action
		if oa != action and InputBinds.may_share(action, oa):
			continue
		for os in InputBinds.SLOTS:
			if InputBinds.slot_kind(os) != kind or not other.get(os, false):
				continue
			if oa == action and os == slot:
				continue
			if _binding_data(p, oa, os) == data:
				var over: Dictionary = (p.bindings.get(oa, {}) as Dictionary).duplicate()
				over[os] = {"t": "none"}
				p.bindings[oa] = over
	var cur: Dictionary = (p.bindings.get(action, {}) as Dictionary).duplicate()
	cur[slot] = data
	p.bindings[action] = cur
	_after_bind_change(p)


func unbind_on(p: SavedProfile, action: String, slot: String) -> void :
	if p == null:
		return
	var cur: Dictionary = (p.bindings.get(action, {}) as Dictionary).duplicate()
	cur[slot] = {"t": "none"}
	p.bindings[action] = cur
	_after_bind_change(p)


func reset_bindings_on(p: SavedProfile) -> void :
	if p == null:
		return
	p.bindings = {}
	_after_bind_change(p)


func reset_binding_on(p: SavedProfile, action: String, slot: String) -> void :
	if p == null:
		return
	if p.bindings.has(action):
		var over: Dictionary = (p.bindings[action] as Dictionary).duplicate()
		over.erase(slot)
		if over.is_empty():
			p.bindings.erase(action)
		else:
			p.bindings[action] = over
	_after_bind_change(p)

func _after_bind_change(p: SavedProfile) -> void :
	if p == active():
		InputBinds.apply(p.bindings)
	if profiles.has(p):
		_save()
	bindings_changed.emit(p)


func set_binding(action: String, slot: String, data: Variant) -> void :
	set_binding_on(active(), action, slot, data)

func reset_bindings() -> void :
	reset_bindings_on(active())

func reset_binding(action: String, slot: String) -> void :
	reset_binding_on(active(), action, slot)

func unbind(action: String, slot: String) -> void :
	unbind_on(active(), action, slot)


func _binding_data(p: SavedProfile, action: String, slot: String) -> Variant:
	var over: Dictionary = p.bindings.get(action, {})
	if over.has(slot):
		return over[slot]
	return InputBinds.default_data(action, slot)

func _apply_character(p: SavedProfile) -> void :



	CharacterConfig.save_slots(_slots_from_data(p.character_slots))
	if p.character.is_empty():
		TITLES.stamp(GameConfig.character)
		return
	var c: = CharacterConfig.from_dict(p.character)
	GameConfig.character = c
	TITLES.stamp(c)
	c.save_local()







func capture_character() -> void :
	var p: = active()
	if p == null:
		return
	if GameConfig.character != null:


		TITLES.stamp(GameConfig.character)
		p.character = GameConfig.character.to_dict()
	_save()






func capture_character_for(p: SavedProfile, cfg: CharacterConfig) -> void :
	if p == null or cfg == null:
		return
	if p == active():
		GameConfig.character = cfg
		capture_character()
		return
	TITLES.stamp(cfg, p)
	p.character = cfg.to_dict()
	_save()



func slots_of(p: SavedProfile) -> Array:
	if p == null or p == active():
		return active_slots()
	var out: Array = _slots_from_data(p.character_slots)
	while out.size() < CharacterConfig.SLOT_COUNT:
		out.append(null)
	return out

func set_slots_for(p: SavedProfile, slots: Array) -> void :
	if p == null or p == active():
		set_slots(slots)
		return
	p.character_slots = _slots_to_data(slots)
	_save()



func active_slots() -> Array:
	var p: = active()
	var out: Array = _slots_from_data(p.character_slots) if p != null else CharacterConfig.load_slots()
	while out.size() < CharacterConfig.SLOT_COUNT:
		out.append(null)
	return out




func set_slots(slots: Array) -> void :
	CharacterConfig.save_slots(slots)
	var p: = active()
	if p == null:
		return
	p.character_slots = _slots_to_data(slots)
	_save()


func capture_slots() -> void :
	set_slots(CharacterConfig.load_slots())

func _slots_from_data(arr: Array) -> Array:
	var out: Array = []
	for e in arr:
		out.append(CharacterConfig.from_dict(e) if e is Dictionary else null)
	return out

func _slots_to_data(arr: Array) -> Array:
	var out: Array = []
	for e in arr:
		out.append((e as CharacterConfig).to_dict() if e is CharacterConfig else null)
	return out









var hold_saves: = false

func save() -> void :
	_save()

func _on_settings_saved() -> void :
	var p: = active()
	if p == null:
		return
	p.capture_from_config(GameConfig)
	_save()



var seal_report: Array[String] = []
var _backup_seals: Variant = null
var _aside_done: = false

func _load() -> void :
	seal_report.clear()
	_backup_seals = null
	_aside_done = false
	var path: = AppData.path(FILE)




	var data: Variant = AppData.read_json(path, seal_report)
	if not (data is Dictionary):
		_migrate_from_config()
		return
	var raw: Variant = (data as Dictionary).get("profiles", [])
	profiles.clear()
	for entry in (raw if raw is Array else []):
		if typeof(entry) == TYPE_DICTIONARY:
			profiles.append(_open_profile(entry))
	if profiles.is_empty():
		_migrate_from_config()
		return
	recently_deleted.clear()
	var gone: Variant = (data as Dictionary).get("recently_deleted", [])
	for entry in (gone if gone is Array else []):
		if typeof(entry) == TYPE_DICTIONARY:
			recently_deleted.append(_open_profile(entry))
	active_index = clampi(int((data as Dictionary).get("active", 0)), 0, profiles.size() - 1)
	for line in seal_report:
		push_warning("profiles: " + line)



func _open_profile(entry: Dictionary) -> SavedProfile:
	var p: = SavedProfile.from_dict(entry)
	var sealed: Variant = SaveSeal.open(entry.get("seal"), p.uid)
	if sealed != null:


		for k in SavedProfile.SEALED:
			if JSON.stringify(entry.get(k)) != JSON.stringify((sealed as Dictionary).get(k)):
				_report("%s: edited %s put back" % [p.uid, k])
		return _with_sealed(entry, sealed)




	if not _aside_done:
		_aside_done = true
		AppData.put_aside(AppData.path(FILE), "flagged", false)
	var b: Variant = _backup_seal(p.uid)
	if b != null:
		_report("%s: seal broken, numbers from the backup" % p.uid)
		return _with_sealed(entry, b)
	_report("%s: seal broken, no good backup: numbers kept, marked unverified" % p.uid)
	p.unverified = true
	return p

func _with_sealed(entry: Dictionary, sealed: Dictionary) -> SavedProfile:
	var d: = entry.duplicate()
	for k in SavedProfile.SEALED:
		if sealed.has(k):
			d[k] = sealed[k]
	d["uv"] = bool(sealed.get("uv", false))
	return SavedProfile.from_dict(d)


func _backup_seal(uid: String) -> Variant:
	if _backup_seals == null:
		_backup_seals = {}
		var bak: Variant = AppData._parse(AppData.path(BACKUP))
		if bak is Dictionary:
			for key in ["profiles", "recently_deleted"]:
				var arr: Variant = (bak as Dictionary).get(key, [])
				for e in (arr if arr is Array else []):
					if e is Dictionary and (e as Dictionary).get("uid") is String:
						_backup_seals[String(e["uid"])] = (e as Dictionary).get("seal")
	return SaveSeal.open((_backup_seals as Dictionary).get(uid), uid)

func _report(line: String) -> void :
	seal_report.append(line)




func _migrate_from_config() -> void :
	seeded_fresh = true
	var p: = SavedProfile.new()
	p.name = "Profile 1"
	p.capture_from_config(GameConfig)
	if GameConfig.character != null:
		p.character = GameConfig.character.to_dict()
	p.character_slots = _slots_to_data(CharacterConfig.load_slots())
	profiles = [p]
	active_index = 0
	_save()




func _migrate_legacy_character() -> void :
	if profiles.is_empty() or not profiles[0].character.is_empty():
		return
	if GameConfig.character != null:
		profiles[0].character = GameConfig.character.to_dict()
	profiles[0].character_slots = _slots_to_data(CharacterConfig.load_slots())
	_save()






func _migrate_legacy_career() -> void :
	if profiles.is_empty():
		return
	if not FileAccess.file_exists(LEGACY_CAREER):
		return
	for p in profiles:
		if not p.stats.is_empty():
			return
	var cfg: = ConfigFile.new()
	if cfg.load(LEGACY_CAREER) != OK or not cfg.has_section("career"):
		return
	var seeded: = {}
	for key in cfg.get_section_keys("career"):
		seeded[key] = cfg.get_value("career", key)
	if seeded.is_empty():
		return
	profiles[0].stats = seeded
	_save()

func _save() -> void :
	AppData.ensure()
	var out: Array = []
	for p in profiles:
		out.append(_sealed_entry(p))
	var gone: Array = []
	for p in recently_deleted:
		gone.append(_sealed_entry(p))
	var data: = {
		"version": FORMAT, 
		"active": active_index, 
		"profiles": out, 
		"recently_deleted": gone, 

		AppData.RESET_KEY: AppData.RESET_ID, 
	}
	AppData.write_safely(AppData.path(FILE), JSON.stringify(data, "\t"))

func _sealed_entry(p: SavedProfile) -> Dictionary:
	var d: = p.to_dict()
	d["seal"] = SaveSeal.seal(p.sealed_values(), p.uid)
	return d
