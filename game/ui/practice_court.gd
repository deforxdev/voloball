class_name PracticeCourt
extends SubViewportContainer















signal closed(reason: String)
signal request_menu
signal rebuild_wanted

static var MAIN_SCENE: String = MobileRender.MATCH if MobileRender.enabled() else "res://game/main/main.tscn"



static var _scene: PackedScene = null


var pause_when_idle: = false






static var parked: CanvasLayer = null
static var parked_solo: = false

static func park(layer: CanvasLayer, solo: bool) -> void :
	var tree: = layer.get_tree()
	layer.get_parent().remove_child(layer)
	tree.root.add_child(layer)
	parked = layer
	parked_solo = solo

static func unpark() -> CanvasLayer:
	var l: = parked
	parked = null
	if l != null and is_instance_valid(l):
		l.get_parent().remove_child(l)
		return l
	return null
var viewport: SubViewport = null
var main: Node = null
var active: = false

func _init() -> void :




	stretch = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


	material = LocalViews.opaque_material()



static func preload_scene() -> void :
	if _scene == null and ResourceLoader.load_threaded_get_status(MAIN_SCENE)\
	== ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(MAIN_SCENE)

static func scene_ready() -> bool:
	return _scene != null or ResourceLoader.load_threaded_get_status(MAIN_SCENE)\
	!= ResourceLoader.THREAD_LOAD_IN_PROGRESS

func running() -> bool:
	return main != null and is_instance_valid(main)

func start() -> void :
	if running():
		return
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.audio_listener_enable_3d = false
	LocalViews._configure_like(viewport, get_tree().root)
	add_child(viewport)
	_fit()
	if _scene == null and ResourceLoader.load_threaded_get_status(MAIN_SCENE)\
	!= ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_scene = ResourceLoader.load_threaded_get(MAIN_SCENE) as PackedScene
	if _scene == null:
		_scene = load(MAIN_SCENE) as PackedScene
	main = _scene.instantiate()
	main.set("embedded", true)
	main.set("practice_court", self)
	viewport.add_child(main)
	set_active(false)

func set_active(on: bool) -> void :
	active = on
	visible = on
	if viewport != null:

		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on\
		else SubViewport.UPDATE_DISABLED


		viewport.audio_listener_enable_3d = on
		if on:
			viewport.process_mode = Node.PROCESS_MODE_INHERIT
			LocalViews._configure_like(viewport, get_tree().root)
			_fit()
	_idle_t = 0.0
	if running():
		if main != null and main.has_method("set_embedded_active"):
			main.call("set_embedded_active", on)
	if on:
		grab_focus()






func _propagate_input_event(_event: InputEvent) -> bool:
	return active



var _idle_t: = 0.0



func _fit() -> void :
	if viewport == null or not is_inside_tree():
		return
	var root: = get_tree().root
	var k: = root.get_screen_transform().get_scale().x
	if k <= 0.001:
		k = 1.0
	var logical: = root.get_visible_rect().size
	var px: = Vector2i(maxi(int(round(logical.x * k)), 2), maxi(int(round(logical.y * k)), 2))
	if viewport.size != px:
		viewport.size = px
	var two_d: = Vector2i(int(round(logical.x)), int(round(logical.y)))
	if viewport.size_2d_override != two_d:
		viewport.size_2d_override = two_d
		viewport.size_2d_override_stretch = true
	position = Vector2.ZERO
	scale = Vector2(1.0 / k, 1.0 / k)
	size = Vector2(px)

func _process(delta: float) -> void :
	if parked != null and get_parent() == parked:
		_parked_tick()
	if active:
		_fit()
	if viewport == null or active:
		return
	if viewport.process_mode == Node.PROCESS_MODE_DISABLED:

		if not _may_rest():
			viewport.process_mode = Node.PROCESS_MODE_INHERIT
			_idle_t = 0.0
		return
	if not _may_rest():
		_idle_t = 0.0
		return
	_idle_t += delta
	if _idle_t > 1.0:
		viewport.process_mode = Node.PROCESS_MODE_DISABLED







func _may_rest() -> bool:
	if pause_when_idle or not Net.active or not Net.is_host:
		return true
	return running() and not bool(main.call("practice_anyone_present"))








static func solo_outlives_session() -> bool:
	return Net.quick_queue and not Net.party and not Net.in_match



func _parked_tick() -> void :
	var gone: = Net.in_match or ( not pause_when_idle and not (Net.party and Net.active))\
	or (pause_when_idle and Net.active and not solo_outlives_session())
	if not gone:
		return
	var layer: = parked
	parked = null
	if running():
		if not pause_when_idle and Net.active and not Net.in_match:
			Net.end_practice()
		stop()
	layer.queue_free()

func stop() -> void :
	if not running():
		return
	main.set("practice_court", null)
	viewport.queue_free()
	viewport = null
	main = null
	active = false
	visible = false



func court_closed(reason: String) -> void :
	closed.emit(reason)
