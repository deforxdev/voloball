class_name BootLoader
extends Node

















const MENU: = "res://game/ui/menu.tscn"
const LOCKER: = "res://game/character/locker.tscn"
const LOCKER_GD: = preload("res://game/character/locker.gd")
const TILE_BUDGET_S: = 10.0
const PARTY_WAIT_MAX: = 12.0

static var running: = false
static var own_change: = false
static var locker_scene: PackedScene = null

var screen: LoadingScreen = null
var _from_title: = false

static func enabled() -> bool:
	var a: = LaunchGate.dev_args()
	return a.is_empty() or a.has("--boot-loader")



static func begin(tree: SceneTree, from_title: = false) -> void :
	if running:
		return
	running = true
	var b: = BootLoader.new()
	b._from_title = from_title
	tree.root.add_child(b)

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	screen = LoadingScreen.new()
	if _from_title:
		screen.show_now()
	get_tree().root.add_child(screen)
	screen.set_progress(0.0)
	_run()

var _t0: = 0


func _mark(what: String) -> void :
	if LaunchGate.dev_args().has("--boot-probe"):
		print("[BOOT] loader: %s at %.2f s" % [what, (Time.get_ticks_msec() - _t0) / 1000.0])

func _run() -> void :
	var tree: = get_tree()
	_t0 = Time.get_ticks_msec()
	if not _from_title:
		await get_tree().create_timer(LoadingScreen.FADE_IN).timeout



	ResourceLoader.load_threaded_request(MENU)

	var prog: Array = []
	while true:
		var st: = ResourceLoader.load_threaded_get_status(MENU, prog)
		if st != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			break
		screen.set_progress(0.3 * float(prog[0]) if not prog.is_empty() else 0.0)
		await tree.process_frame
	var menu_ps: = ResourceLoader.load_threaded_get(MENU) as PackedScene
	screen.set_progress(0.3)
	_mark("menu scene read")


	await get_tree().process_frame
	await get_tree().process_frame

	if menu_ps != null:
		GameConfig.goto_packed(menu_ps)
	else:

		own_change = true
		GameConfig.goto_scene(MENU)
		own_change = false
	var menu: Node = null
	while true:
		await tree.process_frame
		var cur: = tree.current_scene
		if cur != null and cur.scene_file_path == MENU and cur.is_node_ready():
			menu = cur
			break
	screen.set_progress(0.45)
	_mark("menu built")

	PracticeCourt.preload_scene()
	while not PracticeCourt.scene_ready():
		screen.set_progress(minf(screen.cover.progress() + 0.002, 0.6))
		await tree.process_frame
	screen.set_progress(0.6)


	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(menu) and menu.has_method("boot_build_court"):
		menu.call("boot_build_court")
	_mark("court built")





	if is_instance_valid(menu) and menu.has_method("boot_party_pending"):
		var waited: = 0.0
		while waited < PARTY_WAIT_MAX and is_instance_valid(menu)\
		and bool(menu.call("boot_party_pending")):
			screen.set_progress(minf(screen.cover.progress() + 0.001, 0.71))
			await tree.process_frame
			waited += get_process_delta_time()
		if waited > 0.0:
			_mark("party home (%.1f s)" % waited)
	screen.set_progress(0.72)
	await tree.process_frame

	if locker_scene == null:
		ResourceLoader.load_threaded_request(LOCKER)
		while ResourceLoader.load_threaded_get_status(LOCKER)\
		== ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await tree.process_frame
		locker_scene = ResourceLoader.load_threaded_get(LOCKER) as PackedScene
	await _warm_tiles(0.72, 1.0)
	_mark("locker tiles warm (%s)" % str(CharacterPortrait.tile_stats))
	screen.set_progress(1.0)
	await tree.create_timer(0.3).timeout


	UiWipe.wipe(tree, func():
		if is_instance_valid(screen):
			screen.queue_free()
		if is_instance_valid(menu) and menu.has_method("boot_revealed"):
			menu.call("boot_revealed")
		running = false
		BootLoader._read_ahead(_first_page)
		queue_free())




var _first_page: Array = []

static func _read_ahead(page: Array) -> void :
	for p in page:
		CharacterPortrait.tile_prefetch(p[1])
	for p in page:
		var j: Array = p[0]
		await CharacterPortrait.tile(j[0], j[1], j[2], p[1])







func _warm_tiles(from: float, to: float) -> void :
	var tree: = get_tree()
	var c: CharacterConfig = GameConfig.character
	if c == null:
		return
	var todo: Array = []
	var jobs: Array = LOCKER_GD.tile_jobs(c)
	_first_page.clear()
	for i in jobs.size():
		var j: Array = jobs[i]
		var key: = CharacterPortrait.tile_key(j[0], j[1], j[2])
		if not CharacterPortrait.tile_stored(key):
			todo.append([j, key])
		elif i < CharacterConfig.hair_meshes().size():
			_first_page.append([j, key])
	_mark("%d tiles to render" % todo.size())
	if todo.is_empty():
		return
	CharacterPortrait.HairWarm.warm_all(c.hair_flip)
	var t0: = Time.get_ticks_msec()
	for i in todo.size():
		if (Time.get_ticks_msec() - t0) / 1000.0 > TILE_BUDGET_S:
			break
		var j: Array = todo[i][0]
		await CharacterPortrait.tile(j[0], j[1], j[2], todo[i][1])
		screen.set_progress(lerpf(from, to, float(i + 1) / float(todo.size())))
	await tree.process_frame
