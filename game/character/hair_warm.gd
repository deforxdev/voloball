extends RefCounted




























const MAX_FITS: = 3

static var _scenes: = {}
static var _loading: = {}
static var _fitted: = {}
static var _fitting: = {}
static var _running: = 0
static var warm_on: = not ("--no-hair-warm" in LaunchGate.dev_args())
static var fits_done: = 0
static var last_fit_ms: = 0.0

static func hair_path(style: int) -> String:
	var list: = CharacterConfig.hair_meshes()
	if style <= 0 or style >= list.size():
		return ""
	return ModelRig.HAIR_DIR % list[style]

static func facial_path(style: int) -> String:
	var list: = CharacterConfig.facial_hair_meshes()
	if style <= 0 or style >= list.size():
		return ""
	return "%s/%s.blend" % [CharacterConfig.FACIAL_HAIR_DIR, list[style]]


static func scene(path: String) -> PackedScene:
	if path == "" or not ResourceLoader.exists(path):
		return null
	if _scenes.has(path):
		return _scenes[path]
	var tree: = Engine.get_main_loop() as SceneTree
	if not _loading.has(path):
		_loading[path] = true
		ResourceLoader.load_threaded_request(path, "PackedScene")
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await tree.process_frame
	if _scenes.has(path):
		return _scenes[path]
	var ps: = ResourceLoader.load_threaded_get(path) as PackedScene
	_loading.erase(path)
	if ps != null:
		_scenes[path] = ps
	return ps



static func prefit(style: int, flip: bool) -> void :
	if not warm_on or not ModelRig.hair_fit_on:
		return
	var id: = "%d/%d" % [style, int(flip)]
	if _fitted.has(id):
		return
	var tree: = Engine.get_main_loop() as SceneTree
	if _fitting.has(id):
		while _fitting.has(id):
			await tree.process_frame
		return
	var path: = hair_path(style)
	if path == "":
		_fitted[id] = true
		return
	_fitting[id] = true
	var ps: PackedScene = await scene(path)
	var rig: = await _fit_rig(tree)
	if ps == null or rig == null:
		_fitting.erase(id)
		return
	var inst: = ps.instantiate()
	if flip:
		rig._mirror_hair(inst)
	var parts: Array = []
	rig._fit_collect(inst, inst, parts)
	var hf: ModelRig.HeadField = rig._head_field()
	var key: = ModelRig.fit_key(parts, rig._head_mesh)\
	if hf != null and not parts.is_empty() else ""
	if key == "" or ModelRig._fit_meshes.has(key):
		inst.free()
		_fitting.erase(id)
		_fitted[id] = true
		return
	while _running >= MAX_FITS:
		await tree.process_frame
	_running += 1




	var t0: = Time.get_ticks_usec()
	for pass_i in 2:
		var g: Dictionary = ModelRig._fit_gather(parts)
		var task: = CharacterPortrait.run_job( func(): rig._fit_compute(g, hf))
		while CharacterPortrait.job_running(task):
			await tree.process_frame
		if not is_instance_valid(rig):
			_running -= 1
			inst.free()
			_fitting.erase(id)
			return
		var fitted: Array = ModelRig._fit_emit(g)
		for i in parts.size():
			(parts[i][0] as MeshInstance3D).mesh = fitted[i]
	last_fit_ms = (Time.get_ticks_usec() - t0) / 1000.0
	_running -= 1
	if not ModelRig._fit_meshes.has(key):
		var keep: Array = []
		for pt in parts:
			keep.append((pt[0] as MeshInstance3D).mesh)
		ModelRig._fit_meshes[key] = keep
	inst.free()
	fits_done += 1
	_fitting.erase(id)
	_fitted[id] = true



static var _warming: = {}

static func warm_all(flip: bool) -> void :
	if not warm_on or _warming.has(flip):
		return
	_warming[flip] = true
	for i in range(1, CharacterConfig.facial_hair_meshes().size()):
		scene(facial_path(i))
	var tree: = Engine.get_main_loop() as SceneTree
	for i in range(1, CharacterConfig.hair_meshes().size()):
		if _fitted.has("%d/%d" % [i, int(flip)]):
			continue
		while _running >= MAX_FITS:
			await tree.process_frame
		prefit(i, flip)
		await tree.process_frame
	_warming.erase(flip)

static func is_fitted(style: int, flip: bool) -> bool:
	return style <= 0 or _fitted.has("%d/%d" % [style, int(flip)])



static func _fit_rig(tree: SceneTree) -> ModelRig:
	var rig: Dictionary = CharacterPortrait._rig
	if not (rig.has("body") and is_instance_valid(rig["body"])):
		await tree.process_frame
		rig = CharacterPortrait._ensure_rig(tree)
	var body: Player = rig["body"]
	return body._model if body != null else null
