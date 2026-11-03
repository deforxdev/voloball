class_name CharacterPortrait





















const CROPS: = ["full", "upper", "head"]







const PRESETS: = {
	"head": {"look": Vector3(0.0, 1.5, 0.0), "dist": 5.5, "vp": Vector2i(512, 512), "norm": true}, 


	"lobby": {"look": Vector3(0.0, 1.46, 0.0), "dist": 6.4, "vp": Vector2i(512, 512), "norm": true}, 
	"upper": {"look": Vector3(0.0, 1.24, 0.0), "dist": 7.8, "vp": Vector2i(512, 512), "norm": true}, 
	"extra": {"look": Vector3(0.0, 1.3, 0.0), "dist": 6.9, "vp": Vector2i(512, 512), "norm": true}, 

	"torso": {"look": Vector3(0.0, 1.05, 0.0), "dist": 8.6, "vp": Vector2i(512, 512), "norm": true}, 

	"legs": {"look": Vector3(0.0, 0.42, 0.0), "dist": 5.6, "vp": Vector2i(512, 512), "norm": true}, 
	"full": {"look": Vector3(0.0, 1.0, 0.0), "dist": 14.1, "vp": Vector2i(480, 620), "norm": false}, 


	"full_hd": {"look": Vector3(0.0, 1.0, 0.0), "dist": 14.1, "vp": Vector2i(960, 1240), "norm": false}, 
}




const FOV: = 10.0



const BACK: = "@back"
const HairWarm: = preload("res://game/character/hair_warm.gd")
const PORTRAIT_CONTOUR_SCALE: = 2.0



static var _busy: = false




static func _portrait_path(crop: String) -> String:
	return AppData.cache_path("portraits/%s.png" % crop)




static var _head_cache: = {}

static func head_cached(cfg_data: Dictionary, host: Node = null, 
		preset: = "head") -> ImageTexture:
	if MobileControls.enabled():
		return null
	if cfg_data.is_empty():
		return null
	var key: = hash([cfg_data, preset])
	if _head_cache.has(key):
		return _head_cache[key]
	var tex: ImageTexture = await render(CharacterConfig.from_dict(cfg_data), preset, 
		Vector2i(80, 80), host)
	if tex != null:
		_head_cache[key] = tex
	return tex




static var render_count: = 0


static var last_image: Image = null

static func render(cfg: CharacterConfig, preset: = "full", 
		size: = Vector2i(256, 340), host: Node = null, kit_override: Array = []) -> ImageTexture:
	render_count += 1
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	while _busy:
		await tree.process_frame
	_busy = true





	if host != null and not is_instance_valid(host):
		host = null
	var tex: ImageTexture = null

	tex = await _render_impl(cfg, preset, tree, host, kit_override)
	_busy = false
	return tex





static var _rig: = {}

static func _ensure_rig(tree: SceneTree) -> Dictionary:
	if _rig.has("body") and is_instance_valid(_rig["body"]):
		return _rig
	var vp: = SubViewport.new()
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	tree.root.add_child(vp)
	var cam: = Camera3D.new()
	cam.fov = FOV
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	vp.add_child(cam)
	Ink.apply(cam)
	var env: = WorldEnvironment.new()
	var e: = Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.5
	env.environment = e
	vp.add_child(env)
	var body: Player = (load("res://game/mobile/mobile_player.tscn") as PackedScene).instantiate()
	body.enable_reflection = false
	vp.add_child(body)

	body.drop_shadow.visible = false


	body.process_mode = Node.PROCESS_MODE_DISABLED
	_rig = {"vp": vp, "cam": cam, "body": body}
	return _rig




static func _render_impl(cfg: CharacterConfig, preset: String, 
		tree: SceneTree, _host = null, kit_override: Array = []) -> ImageTexture:
	if cfg == null:
		cfg = CharacterConfig.new()
	var from_back: = preset.ends_with(BACK)
	if from_back:
		preset = preset.trim_suffix(BACK)
	var p: Dictionary = PRESETS.get(preset, PRESETS["full"])
	if bool(p["norm"]):



		var casual: = cfg.casual
		cfg = cfg.clone()
		cfg.casual = casual
		cfg.height = 0.5





	if not (_rig.has("body") and is_instance_valid(_rig["body"])):
		await tree.process_frame
	var rig: = _ensure_rig(tree)
	var vp: SubViewport = rig["vp"]
	var cam: Camera3D = rig["cam"]
	var body: Player = rig["body"]


	vp.size = Vector2i(Vector2(p["vp"]) * 0.5) if MobileRender.enabled() else p["vp"]
	var look: Vector3 = p["look"]
	cam.global_position = look + Vector3(0.0, 0.0, float(p["dist"]))
	cam.look_at(look)

	body.global_position = Vector3.ZERO
	body.visual.rotation.y = PI if from_back else 0.0


	await HairWarm.prefit(cfg.hair, cfg.hair_flip)
	if not is_instance_valid(vp) or not is_instance_valid(body):
		_rig = {}
		return null
	body.set_character(cfg, kit_override if not kit_override.is_empty()\
	else TeamKits.normalize(cfg.captain_kit))



	body.force_portrait_pose()


	if GameConfig.contour_outline:
		body.set_contour_px_scale(PORTRAIT_CONTOUR_SCALE)




	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	for _i in 4:
		await RenderingServer.frame_post_draw
	if not is_instance_valid(vp):
		_rig = {}
		return null
	var img: = vp.get_texture().get_image()
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	if img == null:
		return null



	var used: = img.get_used_rect()
	if used.size.x < 8 or used.size.y < 8:
		return null


	last_image = img
	return ImageTexture.create_from_image(img)



static func generate_and_save(cfg: CharacterConfig, host: Node = null) -> void :
	if DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(AppData.cache_path("portraits"))
	for crop in CROPS:
		var tex: = await render(cfg, crop, Vector2i.ZERO, host)
		if tex != null:
			tex.get_image().save_png(_portrait_path(crop))
	if MobileRender.enabled() and _rig.has("vp"):
		_rig.vp.queue_free()
		_rig = {}


static func load_full() -> Texture2D:
	return _load(_portrait_path("full"))

static func load_upper() -> Texture2D:
	return _load(_portrait_path("upper"))

static func load_head() -> Texture2D:
	return _load(_portrait_path("head"))

static func _load(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var img: = Image.new()
	if img.load(path) != OK:
		return null
	return ImageTexture.create_from_image(img)














const TILE_VERSION: = 1
const TILE_MEM_MAX: = 160
const TILE_DISK_MAX: = 900
const TILE_UPLOAD_MS: = 4.0
static var tile_disk_on: = true
static var tile_stats: = {"mem": 0, "disk": 0, "render": 0}
static var _tiles: = {}
static var _tile_reads: = {}
static var _budget_frame: = -1
static var _budget_ms: = 0.0
static var _pruned: = false

static func _tile_dir() -> String:
	return AppData.cache_path("tiles")

static func _tile_path(key: String) -> String:
	return "%s/%s.png" % [_tile_dir(), key]



static var _stamps: = {}
static var _model_stamp: = -1

static func _stamp(path: String) -> int:
	if path == "":
		return 0
	if _stamps.has(path):
		return _stamps[path]
	var imp: = path + ".import"
	var t: = 0
	if FileAccess.file_exists(imp):
		t = FileAccess.get_modified_time(imp)
	elif FileAccess.file_exists(path):
		t = FileAccess.get_modified_time(path)
	if t == 0:
		t = _packed_size(path)
	_stamps[path] = t
	return t








static func _packed_size(path: String) -> int:
	var dest: = path
	for side in [path + ".import", path + ".remap"]:
		if not FileAccess.file_exists(side):
			continue
		var cf: = ConfigFile.new()
		if cf.load(side) != OK or not cf.has_section("remap"):
			continue
		dest = String(cf.get_value("remap", "path", ""))
		if dest == "":
			for k in cf.get_section_keys("remap"):
				if String(k).begins_with("path."):
					dest = String(cf.get_value("remap", k, ""))
					break
		break
	var f: = FileAccess.open(dest, FileAccess.READ) if dest != "" else null
	return f.get_length() if f != null else 0


static func tile_key(cfg: CharacterConfig, preset: String, kit: Array = []) -> String:
	var d: = cfg.look_dict()
	d.erase("name")
	if _model_stamp < 0:
		_model_stamp = _stamp(ModelRig.model_path())
	var art: Array = [_model_stamp, 
		_stamp(HairWarm.hair_path(cfg.hair)), _stamp(HairWarm.facial_path(cfg.facial_hair))]
	for slot in CharacterConfig.ACC_SLOTS:
		var id: = cfg.acc_id(slot)
		var item: AccessoryItem = AccessoryCatalog.by_id(id) if id != "" else null
		if item != null:
			art.append(_stamp(item.resource_path))
			art.append(_stamp(item.mesh.resource_path) if item.mesh != null else 0)
	var salt: = [TILE_VERSION, preset, cfg.casual, str(kit), 
		RenderingServer.get_current_rendering_method(), GameConfig.contour_outline, 
		GameConfig.contour_inner_lines, GameConfig.contour_inner_scale, 
		GameConfig.art_style, art]
	return str([salt, d]).md5_text()


static func tile_stored(key: String) -> bool:
	return _tiles.has(key) or (tile_disk_on and FileAccess.file_exists(_tile_path(key)))


static func tile_peek(key: String) -> ImageTexture:
	if not _tiles.has(key):
		return null
	var tex: ImageTexture = _tiles[key]
	_tiles.erase(key)
	_tiles[key] = tex
	return tex



static func tile_prefetch(key: String) -> void :
	if not tile_disk_on or _tiles.has(key) or _tile_reads.has(key):
		return
	var path: = _tile_path(key)
	if not FileAccess.file_exists(path):
		return
	var out: Array = [null]
	var abs_path: = ProjectSettings.globalize_path(path)
	var task: = run_job( func():
		out[0] = Image.load_from_file(abs_path))
	_tile_reads[key] = [task, out]



static func tile(cfg: CharacterConfig, preset: String, kit: Array = [], 
		key: = "") -> ImageTexture:
	if key == "":
		key = tile_key(cfg, preset, kit)
	var hit: = tile_peek(key)
	if hit != null:
		tile_stats["mem"] += 1
		return hit
	var tree: = Engine.get_main_loop() as SceneTree
	tile_prefetch(key)
	if _tile_reads.has(key):
		var read: Array = _tile_reads[key]
		while job_running(int(read[0])):
			await tree.process_frame
		if _tile_reads.get(key) == read:
			_tile_reads.erase(key)
			var img: Image = read[1][0]
			if img != null and not img.is_empty():
				await _upload_turn(tree)
				var t0: = Time.get_ticks_usec()
				var made: = ImageTexture.create_from_image(img)
				_budget_ms += (Time.get_ticks_usec() - t0) / 1000.0
				_keep(key, made)
				tile_stats["disk"] += 1
				return made
	if _tiles.has(key):
		return tile_peek(key)
	var tex: ImageTexture = await render(cfg, preset, Vector2i.ZERO, null, kit)
	if tex == null:
		return null
	tile_stats["render"] += 1
	_keep(key, tex)
	if tile_disk_on and last_image != null:
		_save(key, last_image)
	return tex

static func _keep(key: String, tex: ImageTexture) -> void :
	_tiles.erase(key)
	_tiles[key] = tex
	while _tiles.size() > TILE_MEM_MAX:
		_tiles.erase(_tiles.keys()[0])


static func _upload_turn(tree: SceneTree) -> void :
	while true:
		var f: = Engine.get_process_frames()
		if f != _budget_frame:
			_budget_frame = f
			_budget_ms = 0.0
		if _budget_ms < TILE_UPLOAD_MS:
			return
		await tree.process_frame




static func _save(key: String, img: Image) -> void :
	var dir: = ProjectSettings.globalize_path(_tile_dir())
	var path: = ProjectSettings.globalize_path(_tile_path(key))
	var prune: = not _pruned
	_pruned = true
	run_job( func():
		DirAccess.make_dir_recursive_absolute(dir)
		var tmp: = path + ".tmp"
		if img.save_png(tmp) == OK:
			DirAccess.rename_absolute(tmp, path)
		if prune:
			_prune(dir))





static var _jobs: Array = []
static var _reaping: = false
static var _exit_hooked: = false

static func run_job(c: Callable) -> int:
	var id: = WorkerThreadPool.add_task(c)
	_jobs.append(id)
	var tree: = Engine.get_main_loop() as SceneTree
	if not _exit_hooked and tree != null and tree.root != null:
		_exit_hooked = true
		tree.root.tree_exiting.connect(finish_jobs)
	if not _reaping:
		_reap()
	return id



static func job_running(id: int) -> bool:
	return _jobs.has(id)

static func _reap() -> void :
	_reaping = true
	var tree: = Engine.get_main_loop() as SceneTree
	while not _jobs.is_empty():
		await tree.process_frame
		for id in _jobs.duplicate():
			if WorkerThreadPool.is_task_completed(id):
				WorkerThreadPool.wait_for_task_completion(id)
				_jobs.erase(id)
	_reaping = false

static func finish_jobs() -> void :
	for id in _jobs:
		WorkerThreadPool.wait_for_task_completion(id)
	_jobs.clear()

static func _prune(dir: String) -> void :
	var files: = DirAccess.get_files_at(dir)
	if files.size() <= TILE_DISK_MAX:
		return
	var aged: Array = []
	for f in files:
		aged.append([FileAccess.get_modified_time(dir.path_join(f)), f])
	aged.sort_custom( func(a, b): return a[0] < b[0])
	for i in aged.size() - int(TILE_DISK_MAX * 0.75):
		DirAccess.remove_absolute(dir.path_join(String(aged[i][1])))
