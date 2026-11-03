class_name AppData
extends RefCounted








static var DIR: = "user://data"
const REAL_DIR: = "user://data"
const DEV_DIR: = "user://data_dev"
const CACHE: = "user://cache"
const MANIFEST: = "manifest.json"


const SAVE_VERSION: = 1





const WIPE_ID: = "beta1"






const RESET_ID: = "demo1"
const RESET_KEY: = "reset"
const RESET_AT_KEY: = "reset_at"



const DEMO_APP_ID: = 5401090




static var did_wipe: = false





const WIPE_FILES: = ["profiles.json", "character.json", "character_slots.json"]
const LEGACY_CAREER: = "user://career.cfg"


const JUNK: = ["probe_ready.png", "probe_reticle.png", "probe_taken.png", 
	"sand_test_out.png", 
	"portrait_full.png", "portrait_upper.png", "portrait_head.png"]

static func ensure() -> void :
	DirAccess.make_dir_recursive_absolute(DIR)
	DirAccess.make_dir_recursive_absolute(CACHE)

static func path(name: String) -> String:
	return "%s/%s" % [DIR, name]

static func cache_path(name: String) -> String:
	return "%s/%s" % [CACHE, name]




static func migrate(old_path: String, name: String) -> String:
	ensure()
	var new_path: = path(name)
	if not FileAccess.file_exists(new_path) and FileAccess.file_exists(old_path):
		DirAccess.rename_absolute(old_path, new_path)
	return new_path














const ASIDE_DIR: = "flagged"
const ASIDE_MAX: = 20

static func write_safely(file_path: String, text: String) -> bool:
	ensure()
	var tmp: = file_path + ".tmp"
	var f: = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("save: could not write %s (error %d)" % [tmp, FileAccess.get_open_error()])
		return false
	f.store_string(text)
	f.close()
	if FileAccess.get_file_as_string(tmp) != text:
		push_warning("save: %s did not read back whole; the old file is kept" % file_path.get_file())
		return false


	if _parse(file_path) != null:
		DirAccess.copy_absolute(file_path, file_path + ".bak")
	var err: = DirAccess.rename_absolute(tmp, file_path)
	if err != OK:
		push_warning("save: could not replace %s (error %d)" % [file_path.get_file(), err])
		return false
	return true



static func read_json(file_path: String, report: Array = []) -> Variant:
	var data: Variant = _parse(file_path)
	if data != null:
		return data
	for alt in [file_path + ".tmp", file_path + ".bak"]:
		data = _parse(alt)
		if data != null:
			report.append("%s loaded from %s" % [file_path.get_file(), String(alt).get_file()])
			break
	if FileAccess.file_exists(file_path):
		report.append("unreadable %s moved aside" % file_path.get_file())
		put_aside(file_path, "unreadable", true)
	for line in report:
		push_warning("save: " + str(line))
	return data

static func _parse(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path):
		return null
	var json: = JSON.new()
	if json.parse(FileAccess.get_file_as_string(file_path)) != OK:
		return null
	return json.data if (json.data is Dictionary or json.data is Array) else null



static func put_aside(file_path: String, why: String, move: bool) -> void :
	if not FileAccess.file_exists(file_path):
		return
	var dir: = path(ASIDE_DIR)
	DirAccess.make_dir_recursive_absolute(dir)
	var to: = "%s/%d-%06d-%s-%s" % [dir, int(Time.get_unix_time_from_system()), 
		Time.get_ticks_usec() % 1000000, why, file_path.get_file()]
	if move:
		DirAccess.rename_absolute(file_path, to)
	else:
		DirAccess.copy_absolute(file_path, to)
	var kept: = Array(DirAccess.get_files_at(dir))
	kept.sort()
	while kept.size() > ASIDE_MAX:
		DirAccess.remove_absolute(dir + "/" + String(kept.pop_front()))


static func cache_migrate(old_path: String, name: String) -> String:
	ensure()
	var new_path: = cache_path(name)
	DirAccess.make_dir_recursive_absolute(new_path.get_base_dir())
	if not FileAccess.file_exists(new_path) and FileAccess.file_exists(old_path):
		DirAccess.rename_absolute(old_path, new_path)
	return new_path















const BOOT_SENTINEL: = "user://.boot_pending"
static var safe_mode: = false

static func _boot_fail_count() -> int:
	if not FileAccess.file_exists(BOOT_SENTINEL):
		return 0
	var f: = FileAccess.open(BOOT_SENTINEL, FileAccess.READ)
	if f == null:
		return 0
	var n: = int(f.get_as_text().strip_edges())
	f.close()
	return n

static func _arm_boot(count: int) -> void :
	var f: = FileAccess.open(BOOT_SENTINEL, FileAccess.WRITE)
	if f != null:
		f.store_string(str(count));f.close()



static func decide_safe_boot() -> bool:
	if MobileRender.enabled():
		return false
	if is_harness():
		return false
	var fails: = _boot_fail_count()
	_arm_boot(fails + 1)
	safe_mode = fails >= 1


	return fails >= 2 and RenderingServer.get_rendering_device() != null

static func relaunch_compatibility() -> void :
	OS.create_instance(PackedStringArray(["--rendering-driver", "opengl3"]))


static func boot_succeeded() -> void :
	if FileAccess.file_exists(BOOT_SENTINEL):
		DirAccess.remove_absolute(BOOT_SENTINEL)



static func init_appdata() -> void :
	_sandbox_for_harness()
	ensure()
	_cleanup_junk()


	cache_migrate("user://crowd_fan_array.res", "crowd_fan_array.res")
	import_demo_save()
	_check_wipe()







static func is_harness() -> bool:


	if not OS.has_feature("editor"):
		return false
	if not LaunchGate.dev_args().is_empty():
		return true
	for a in OS.get_cmdline_args():
		var s: = String(a).replace("\\", "/")
		if s.contains("game/dev/") or s == "--script" or s == "-s":
			return true
	return false

static func _sandbox_for_harness() -> void :
	if not is_harness():
		return
	DIR = DEV_DIR + _sandbox_suffix()
	_remove_dir_recursive(DIR)
	DirAccess.make_dir_recursive_absolute(DIR)
	var d: = DirAccess.open(REAL_DIR)
	if d == null:
		return
	d.list_dir_begin()
	var name: = d.get_next()
	while name != "":
		if not d.current_is_dir():
			DirAccess.copy_absolute(REAL_DIR + "/" + name, DIR + "/" + name)
		name = d.get_next()
	d.list_dir_end()





static func _sandbox_suffix() -> String:
	var a: = LaunchGate.dev_args()
	var i: = a.find("--drive-role")
	if i != -1 and i + 1 < a.size():
		return "_" + String(a[i + 1]).validate_filename()
	return ""



static func _cleanup_junk() -> void :
	for j in JUNK:
		if FileAccess.file_exists("user://" + j):
			DirAccess.remove_absolute("user://" + j)
	_remove_dir_recursive("user://chat")

static func _check_wipe() -> void :
	var manifest: Variant = _parse(path(MANIFEST))
	var m: Dictionary = manifest if manifest is Dictionary else {}
	var stored: = str(m.get("wipe_id", ""))

	var wipe: = stored != "" and stored != WIPE_ID


	if not reset_marked(m) and _has_saves():
		wipe = true
	if wipe:
		_wipe_saved_data()
		did_wipe = true
	var at: = int(m.get(RESET_AT_KEY, 0))
	if wipe or stored != WIPE_ID or str(m.get(RESET_KEY, "")) != RESET_ID or at <= 0:

		_write_manifest(at if at > 0 and not wipe else int(Time.get_unix_time_from_system()))



static func reset_marked(manifest: Dictionary) -> bool:
	var m_marked: = str(manifest.get(RESET_KEY, "")) == RESET_ID
	var p: = path("profiles.json")
	for f in [p, p + ".tmp", p + ".bak"]:
		var data: Variant = _parse(f)
		if data is Dictionary:
			if str((data as Dictionary).get(RESET_KEY, "")) == RESET_ID:
				return true

			return m_marked and FileAccess.get_modified_time(f)\
			>= int(manifest.get(RESET_AT_KEY, 0))
	return m_marked

static func _has_saves() -> bool:
	for name in WIPE_FILES:
		for ext in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path(name + ext)):
				return true
		if FileAccess.file_exists("user://" + name):
			return true
	return FileAccess.file_exists(LEGACY_CAREER)

static func _write_manifest(reset_at: int) -> void :
	ensure()
	var f: = FileAccess.open(path(MANIFEST), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"save_version": SAVE_VERSION, 
			"wipe_id": WIPE_ID, RESET_KEY: RESET_ID, RESET_AT_KEY: reset_at}, "\t"))
		f.close()



static func _wipe_saved_data() -> void :
	for name in WIPE_FILES:
		for ext in ["", ".tmp", ".bak"]:
			DirAccess.remove_absolute(path(name + ext))
		DirAccess.remove_absolute("user://" + name)
	DirAccess.remove_absolute(LEGACY_CAREER)
	push_warning("save data reset for the last reset (%s)" % RESET_ID)











const _PREFIX_DATA: = "pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/volleyball/data"
const _NO_COPY: = ["steam_autocloud.vdf"]
static var imported_demo_save: = ""

static func import_demo_save() -> bool:
	if LaunchGate.is_demo() or is_harness():
		return false
	return _import_from(demo_save_dirs(), DIR)



static func _import_from(candidates: Array, dest: String) -> bool:
	var p: = dest.path_join("profiles.json")
	for f in [p, p + ".tmp", p + ".bak"]:
		if FileAccess.file_exists(f):
			return false
	for src in candidates:
		if not FileAccess.file_exists(String(src).path_join("profiles.json")):
			continue
		DirAccess.make_dir_recursive_absolute(dest)
		for name in DirAccess.get_files_at(src):
			if not name in _NO_COPY:
				DirAccess.copy_absolute(String(src).path_join(name), dest.path_join(name))
		imported_demo_save = src
		push_warning("save: brought the demo's save over from %s" % src)
		return true
	return false


static func demo_save_dirs(env: = {}) -> Array:
	var own: = _env(env, "STEAM_COMPAT_DATA_PATH").trim_suffix("/")
	if own == "":
		return []
	var roots: Array = [own.get_base_dir()]
	for lib in _env(env, "STEAM_COMPAT_LIBRARY_PATHS").split(":", false):
		var l: = String(lib).trim_suffix("/")
		roots.append(l.path_join("compatdata") if l.ends_with("steamapps")
			else l.path_join("steamapps/compatdata"))
	var client: = _env(env, "STEAM_COMPAT_CLIENT_INSTALL_PATH").trim_suffix("/")
	if client != "":
		roots.append(client.path_join("steamapps/compatdata"))
	var out: Array = []
	for r in roots:
		var d: = _wine_path(String(r).path_join(str(DEMO_APP_ID)).path_join(_PREFIX_DATA))
		if not d in out:
			out.append(d)
	return out

static func _env(env: Dictionary, key: String) -> String:
	return str(env[key]) if env.has(key) else OS.get_environment(key)


static func _wine_path(p: String) -> String:
	return "Z:" + p if p.begins_with("/") else p

static func _remove_dir_recursive(dir_path: String) -> void :
	var d: = DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var name: = d.get_next()
	while name != "":
		var full: = dir_path + "/" + name
		if d.current_is_dir():
			_remove_dir_recursive(full)
		else:
			DirAccess.remove_absolute(full)
		name = d.get_next()
	d.list_dir_end()
	DirAccess.remove_absolute(dir_path)
