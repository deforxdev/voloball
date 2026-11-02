class_name GuideSheet
extends SubViewport







signal settled

var canvas: StudioCanvas
var render: StudioRender
var spread_id: = ""
var layers: Array = []
var _queue: Array = []
var _draining: = false
var _hot: = 0
var _gen: = 0

func _init() -> void :
	disable_3d = true
	transparent_bg = false
	size = Vector2i(64, 40)
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	canvas = StudioCanvas.new()
	canvas.pattern = "none"
	canvas.layers = layers
	add_child(canvas)

func is_settled() -> bool:
	return _queue.is_empty() and not _draining and _hot <= 0


func show_spread(id: String, px: Vector2i) -> void :
	_gen += 1
	spread_id = id
	_queue.clear()
	layers.clear()
	layers.append_array(GuideStore.layers_of(id))
	canvas.bg = GuideStore.paper(GuideStore.spread(id))
	GuideStore.apply_pattern(GuideStore.spread(id), canvas)
	resize_to(px)
	for l in layers:
		if (l as StudioLayer).is_rendered():
			_queue.append(l)
	_kick()

func resize_to(px: Vector2i) -> void :
	var want: = Vector2i(maxi(64, px.x), maxi(40, px.y))
	if size != want:
		size = want
		for l in layers:
			if (l as StudioLayer).is_rendered() and not _queue.has(l):
				_queue.append(l)
	canvas.size = Vector2(size)
	refresh()


func refresh() -> void :
	canvas.sync()
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_hot = 3
	_kick()

func _kick() -> void :
	if not _draining and not _queue.is_empty() and render != null:
		_drain()

func _drain() -> void :
	_draining = true
	var gen: = _gen
	while not _queue.is_empty():
		var layer: StudioLayer = _queue.pop_front()
		if not layers.has(layer):
			continue
		var px: = layer.render_px(float(size.y))
		var key: = layer.render_key(px)
		if key == layer.tex_key and layer.tex != null:
			continue
		var res: Dictionary = await render.render(layer, px)
		if not is_instance_valid(self):
			return
		if gen != _gen:
			break
		if res.is_empty():
			continue
		layer.tex = res["tex"]
		layer.used = res["used"]
		layer.tex_key = key
		canvas.sync()
		render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_hot = 3
	_draining = false
	if gen != _gen:
		_kick()

func _process(_delta: float) -> void :
	if _hot > 0:
		_hot -= 1
		if _hot == 0:
			render_target_update_mode = SubViewport.UPDATE_DISABLED
			if is_settled():
				settled.emit()
