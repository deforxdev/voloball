extends Control

var _body: VBoxContainer
var _name: LineEdit
var _address: LineEdit
var _status: Label
var _players: Label
var _start: Button
var _joining_at := 0

func _ready() -> void:
	GameConfig.menu_open = true
	GameConfig.menu_practice = false
	GameConfig.onboarding_active = false
	GameConfig.apply_display()
	GameConfig.apply_frame_cap()
	GameConfig.apply_render_scale()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Net.lobby_changed.connect(_refresh)
	Net.session_ended.connect(_ended)
	Net.match_started.connect(_match_started)
	_build()
	_refresh()
	if not Net.pending_start.is_empty():
		_match_started.call_deferred(Net.pending_start.duplicate(true))
	print("[mobile menu] lightweight menu ready")

func _exit_tree() -> void:
	GameConfig.menu_open = false

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("101d2d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 32)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_body)
	_label("VOLOBALL · локальна мережа", 32)
	_label("Підключіть телефони до одного Wi-Fi або точки доступу. Хост створює кімнату, інші вводять його IP.", 20)
	_name = LineEdit.new()
	_name.placeholder_text = "Ім’я гравця"
	_name.text = Net.my_name
	_name.max_length = 24
	_name.custom_minimum_size.y = 54
	_body.add_child(_name)
	var row := HBoxContainer.new()
	_body.add_child(row)
	_button(row, "Створити кімнату", _host)
	_button(row, "Локальний матч 1 × 1", _offline)
	_address = LineEdit.new()
	_address.placeholder_text = "IP хоста, наприклад 192.168.1.5"
	_address.custom_minimum_size.y = 54
	_body.add_child(_address)
	_button(_body, "Підключитися", _join)
	_status = _label("", 20)
	_players = _label("", 20)
	_start = _button(_body, "Почати матч", _start_match)
	_button(_body, "Вийти з кімнати", func(): Net.leave())
	var settings := HBoxContainer.new()
	_body.add_child(settings)
	_button(settings, "Економний режим · 30 FPS", func(): _quality(30, 60))
	_button(settings, "Плавний режим · 60 FPS", func(): _quality(60, 75))
	_label("До 10 гравців. Хост має залишатися в грі. Без інтернет-сервера.", 18)

func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	_body.add_child(label)
	return label

func _button(parent: Node, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 54
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _player_name() -> String:
	return _name.text.strip_edges() if not _name.text.strip_edges().is_empty() else "Гравець"

func _host() -> void:
	Net.leave()
	Net.privacy = Net.Priv.PUBLIC
	Net.password = ""
	Net.max_humans = 10
	Net.team_size = 1
	Net.stage = Stage.home()
	Net.practice = false
	var error := Net.host_game(_player_name())
	if error != OK:
		_status.text = "Не вдалося створити кімнату: %d" % error
		return
	Net.custom_lobby = true
	Net.party_lan = true
	Net.set_rules(7, 1, true, false, 1.0, false, true, 15, true, false, false, false)
	_refresh()

func _join() -> void:
	if _address.text.strip_edges().is_empty():
		_status.text = "Введіть IP телефона, який створив кімнату."
		return
	Net.leave()
	Net.join_password = ""
	var error := Net.join_game(_address.text.strip_edges(), _player_name())
	if error == OK:
		_joining_at = Time.get_ticks_msec()
		_status.text = "Підключення… Дозвольте доступ до локальної мережі."
	else:
		_status.text = "Помилка підключення: %d" % error

func _process(_delta: float) -> void:
	if _joining_at > 0 and Time.get_ticks_msec() - _joining_at > 15000:
		_joining_at = 0
		Net.leave()
		_status.text = "Не вдалося підключитися. Перевірте IP, спільний Wi-Fi і дозвіл локальної мережі."

func _refresh() -> void:
	_start.visible = Net.active and Net.is_host
	_players.text = ""
	if not Net.active:
		_status.text = "Кімната ще не створена."
		return
	if not Net.players.is_empty():
		_joining_at = 0
	_status.text = "Кімната · %d / 10 гравців" % Net.human_count()
	if Net.is_host:
		var addresses: PackedStringArray = []
		for address in IP.get_local_addresses():
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.get_slice(".", 1)) >= 16 and int(address.get_slice(".", 1)) <= 31):
				addresses.append(address)
		_status.text += "\nIP хоста: " + ", ".join(addresses) + " · порт %d" % Net.host_port()
	for id in Net.players:
		_players.text += "%s%s\n" % [Net.players[id].get("name", "Гравець"), " (хост)" if id == 1 else ""]

func _ended(reason: String) -> void:
	_joining_at = 0
	_refresh()
	_status.text = "Кімнату закрито: " + reason

func _start_match() -> void:
	if not Net.active or not Net.is_host:
		return
	var size := 1
	for row in Net.players.values():
		var side_count := 0
		for other in Net.players.values():
			if other.get("side", 1) == row.get("side", 1):
				side_count += 1 + other.get("locals", []).size()
		size = maxi(size, side_count)
	Net.set_team_size(mini(size, 5))
	var ids := Net.players.keys()
	ids.sort()
	var roster := Net.match_roster(ids, Net.players, Net.team_size)
	Net.start_match(roster, randi())

func _match_started(roster: Array) -> void:
	Net.pending_start = []
	GameConfig.set_mode(Net.team_size)
	GameConfig.stage = Net.stage
	Net.apply_rules_to_config()
	GameConfig.net_roster = roster
	GameConfig.quick_match = false
	GameConfig.ranked_match = false
	GameConfig.goto_scene("res://game/main/main.tscn")

func _offline() -> void:
	Net.leave()
	GameConfig.set_mode(1)
	GameConfig.stage = Stage.home()
	GameConfig.net_roster = []
	GameConfig.quick_match = false
	GameConfig.ranked_match = false
	GameConfig.goto_scene("res://game/main/main.tscn")

func _quality(fps: int, resolution: int) -> void:
	GameConfig.apply_quality(GameConfig.QUALITY_LOW)
	GameConfig.max_fps = fps
	GameConfig.resolution_3d = resolution
	GameConfig.apply_render_scale()
	GameConfig.apply_display()
	GameConfig.save_settings()
	_status.text = "Збережено: %d FPS, масштаб 3D %d%%" % [fps, resolution]
