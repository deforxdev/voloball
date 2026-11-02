class_name LoadingScreen
extends CanvasLayer













const FADE_IN: = 0.25
const FADE_OUT: = 0.35

var cover: LoadingCover = null
var indeterminate: bool:
	get: return cover.indeterminate if cover != null else true
	set(v):
		if cover != null:
			cover.indeterminate = v
var _instant: = false

func _init() -> void :
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	cover = LoadingCover.new()
	cover.modulate.a = 0.0
	add_child(cover)

func _ready() -> void :
	if not _instant:
		fade_in()



func show_now() -> void :
	_instant = true
	cover.modulate.a = 1.0

func set_progress(v: float) -> void :
	cover.set_progress(v)

func fade_in(dur: = FADE_IN) -> void :
	var t: = create_tween().set_ignore_time_scale(true)
	t.tween_property(cover, "modulate:a", 1.0, dur).set_trans(Tween.TRANS_SINE)

func fade_out(done: = Callable(), dur: = FADE_OUT) -> void :
	var t: = create_tween().set_ignore_time_scale(true)
	t.tween_property(cover, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE)
	if done.is_valid():
		t.tween_callback(done)





func hold_through_scene_change(max_hold: = 20.0) -> void :
	var tree: = get_tree()
	if tree == null:
		return
	var from_id: = tree.current_scene.get_instance_id() if tree.current_scene != null else 0
	var t: = 0.0
	while is_inside_tree() and t < max_hold:
		var cur: = tree.current_scene
		if cur != null and cur.get_instance_id() != from_id and cur.is_node_ready():
			break
		await tree.process_frame
		t += get_process_delta_time()

	for i in 3:
		if not is_inside_tree():
			return
		await tree.process_frame
	if is_inside_tree():
		fade_out( func(): queue_free())
