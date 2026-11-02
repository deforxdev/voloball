class_name PlayerListOverlay
extends RefCounted





















const REFRESH: = 0.25
const SEAT_NONE: = 99

static func open(on_seat: = Callable(), on_close: = Callable(), 
		state_fn: = Callable()) -> CanvasLayer:
	var tree: = Engine.get_main_loop() as SceneTree


	if tree == null or tree.root == null or ( not Net.active and not state_fn.is_valid()):
		return null

	var layer: = CanvasLayer.new()
	layer.name = "TeamsScreen"
	layer.layer = 98


	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(MouseHold.new())
	var shut: = func():
		if is_instance_valid(layer):
			layer.queue_free()
		if on_close.is_valid():
			on_close.call()
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.55)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.gui_input.connect( func(e):
		if e is InputEventMouseButton and e.pressed:
			shut.call())
	layer.add_child(scrim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var card: = PanelContainer.new()
	UiStyle.style_panel(card, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	center.add_child(card)
	var pad: = MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + s, 18)
	card.add_child(pad)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	pad.add_child(v)

	var title: = Label.new()
	title.text = "teams & players"
	UiStyle.style_label(title, "title")
	v.add_child(title)


	var pair: = PanelContainer.new()
	var pb: = StyleBoxFlat.new()
	pb.bg_color = UiStyle.INK
	pb.set_corner_radius_all(TeamCard.RADIUS + 3)
	pb.set_content_margin_all(3.0)
	pair.add_theme_stylebox_override("panel", pb)
	v.add_child(pair)
	var teams: = HBoxContainer.new()
	teams.add_theme_constant_override("separation", 0)
	pair.add_child(teams)


	var on_player: = func(id: String):
		layer.visible = false
		PlayerMenu.open(int(id), func():
			if is_instance_valid(layer):
				layer.visible = true)
	var cards: = {}
	for team in [1, -1]:
		var tc: = TeamCard.new()
		tc.name = "Home" if team == 1 else "Away"
		tc.setup(team)
		tc.human_pressed.connect(on_player)
		if on_seat.is_valid():
			tc.join_pressed.connect( func():
				layer.queue_free()
				on_seat.call(team))
		teams.add_child(tc)
		cards[team] = tc
		if team == 1:
			var bar: = Panel.new()
			bar.custom_minimum_size.x = 4
			var bsb: = StyleBoxFlat.new()
			bsb.bg_color = UiStyle.INK
			bar.add_theme_stylebox_override("panel", bsb)
			teams.add_child(bar)


	var info: = Label.new()
	info.name = "Info"
	UiStyle.style_label(info, "small", UiStyle.muted())
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.visible = false
	v.add_child(info)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var spec: Button = null
	if on_seat.is_valid():
		spec = Button.new()
		spec.name = "Spectate"
		spec.text = "spectate"
		spec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spec.custom_minimum_size = Vector2(0, 40)
		UiStyle.style_button(spec, "tertiary", 15)
		spec.pressed.connect( func():
			layer.queue_free()
			on_seat.call(0))
		row.add_child(spec)
	var close: = Button.new()
	close.name = "Close"
	close.text = "close"
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.custom_minimum_size = Vector2(0, 40)
	UiStyle.style_button(close, "primary", 15)
	close.pressed.connect(shut)
	row.add_child(close)


	var seen: = {"key": 0}
	var paint: = func():
		var st: Dictionary = state_fn.call() if state_fn.is_valid() else _lobby_state()
		var key: = hash(st)
		if key == int(seen.key):
			return
		seen.key = key
		var asked: = int(st.get("asked", SEAT_NONE))
		for team in [1, -1]:
			var tc: TeamCard = cards[team]
			tc.set_roster((st.teams as Dictionary)[team], int(st.size), false)

			var why: = String((st.join as Dictionary).get(team, ""))
			if asked == team:
				why = "asked"
			var on_it: bool = int(st.mine) == int(team)


			var quick: = bool(st.get("quick", false))
			tc.set_selected(on_it, on_seat.is_valid() and not quick, 
				"" if why == "there" else why)
		if spec != null:
			spec.visible = not bool(st.get("quick", false))
			spec.disabled = not bool(st.get("can_watch", true)) or asked == 0
			spec.text = "spectating at the next serve" if asked == 0 else "spectate"
			spec.focus_mode = Control.FOCUS_NONE if spec.disabled else Control.FOCUS_ALL
		info.text = _info_line(st)
		info.visible = info.text != ""
		_wire_focus(cards, spec, close)
	paint.call()
	var tick: = Timer.new()
	tick.wait_time = REFRESH
	tick.autostart = true
	tick.process_mode = Node.PROCESS_MODE_ALWAYS
	tick.timeout.connect(paint)
	layer.add_child(tick)




	layer.set_meta("first_focus", func() -> Control:
		for team in [-1, 1]:
			var jb: Button = (cards[team] as TeamCard).join_button()
			if jb.is_visible_in_tree() and not jb.disabled:
				return jb
		if spec != null and not spec.disabled:
			return spec
		return close)



	(tree.current_scene if tree.current_scene != null else tree.root).add_child(layer)
	UiStyle.sfx("open")
	return layer








static func _wire_focus(cards: Dictionary, spec: Button, close: Button) -> void :
	var hj: Button = (cards[1] as TeamCard).join_button()
	var aj: Button = (cards[-1] as TeamCard).join_button()
	var h_ok: = hj.visible and not hj.disabled
	var a_ok: = aj.visible and not aj.disabled

	aj.focus_neighbor_left = aj.get_path_to(hj) if h_ok else NodePath(".")
	hj.focus_neighbor_right = hj.get_path_to(aj) if a_ok else NodePath(".")
	if spec != null:
		spec.focus_neighbor_right = spec.get_path_to(close)
		close.focus_neighbor_left = close.get_path_to(spec) if not spec.disabled else NodePath(".")
	close.focus_neighbor_right = NodePath(".")


static func _info_line(st: Dictionary) -> String:
	var parts: Array = []
	if bool(st.get("quick", false)):
		parts.append("teams are picked for you in quick match. you'll join at the start of the next rally"\
		if int(st.get("mine", 0)) == 0 else "teams are picked for you in quick match")
	if bool(st.get("locked", false)):
		var played: = int(st.get("played", 0))
		parts.append("teams are locked. you're on %s" % Rules.side_name(played) if played != 0
			else "teams are locked. the team you join is your team for this match")
	var watching: Array = st.get("watching", [])
	if not watching.is_empty():
		parts.append("spectating: %s" % ", ".join(watching))

	if bool(st.get("couch", false)):
		parts.append("couch players: left or right on your own controller to switch teams")
	return "\n".join(parts)


static func _lobby_state() -> Dictionary:
	var team_size: = Net.team_size
	var my_id: = Net.multiplayer.get_unique_id()
	var humans: = {1: 0, -1: 0}
	var entries: = {1: [], -1: []}
	var watching: Array = []
	var my_side: = 0
	var ids: = Net.players.keys()
	ids.sort()
	for pid in ids:
		var p: Dictionary = Net.players[pid]



		var locs: Array = Net.locals_of(int(pid))
		var seats: Array = [{"ls": 0, "side": int(p.get("side", 0)), 
			"name": String(p.get("name", "player")), "cfg": p.get("cfg", {})}]
		var li: = 1
		for g in locs:
			var gd: Dictionary = g
			seats.append({"ls": li, "side": int(gd.get("side", p.get("side", 0))), 
				"name": String(gd.get("name", "")), "cfg": gd.get("cfg", {})})
			li += 1
		for s in seats:
			var side: int = s.side
			var is_me_owner: bool = int(pid) == my_id and int(s.ls) == 0
			var on_team: bool = side != 0 and int(humans[side]) < team_size
			if is_me_owner and on_team:
				my_side = side
			if not on_team:
				if int(s.ls) == 0:
					watching.append(String(s.name))
				continue
			var cfg: Dictionary = s.cfg
			if is_me_owner and GameConfig.character != null:
				cfg = GameConfig.character.to_dict()


			var tile: = {"kind": "human", "name": String(s.name), 
				"cfg": cfg, "host": int(pid) == 1 and int(s.ls) == 0, "you": is_me_owner, 
				"dev": DevBadge.peer_tier(int(pid)), "id": str(pid), 
				"actionable": int(s.ls) == 0}

			if int(pid) == my_id and int(s.ls) >= 1 and int(s.ls) < LocalPlayers.slots.size():
				tile["local"] = LocalPlayers.slots[int(s.ls)].tag()
				tile["local_color"] = LocalPlayers.slots[int(s.ls)].color()
			entries[side].append(tile)
			humans[side] += 1
	for side in [1, -1]:
		for cpu in CpuSlots.ordered(Net.cpu_slots, side):
			entries[side].append({"kind": "cpu", "name": String(cpu.name), 
				"cfg": cpu.cfg, "diff": int(cpu.diff), 
				"id": CpuSlots.id_for(side, int(cpu.k))})
	return {"size": team_size, "teams": entries, "mine": my_side, "watching": watching, 
		"locked": false, "played": 0, "join": {1: "", -1: ""}, 
		"can_watch": my_side != 0, "asked": SEAT_NONE}
