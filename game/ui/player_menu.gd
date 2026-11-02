class_name PlayerMenu
extends RefCounted






static func open(peer_id: int, on_dismiss: = Callable()) -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	if peer_id == 0 or peer_id == Net.multiplayer.get_unique_id()\
	or not Net.players.has(peer_id):
		if on_dismiss.is_valid():
			on_dismiss.call()
		return
	var pname: = String((Net.players[peer_id] as Dictionary).get("name", "player"))
	var sid: = Reports.peer_sid(peer_id)


	var dismiss: = func():
		if on_dismiss.is_valid():
			on_dismiss.call()

	var layer: = CanvasLayer.new()
	layer.layer = 99
	layer.add_child(MouseHold.new())
	var scrim: = ColorRect.new()
	scrim.color = Color(0, 0, 0, 0.5)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.gui_input.connect( func(e):
		if e is InputEventMouseButton and e.pressed:
			layer.queue_free()
			dismiss.call())
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
	v.add_theme_constant_override("separation", 8)
	v.custom_minimum_size.x = 300
	pad.add_child(v)


	var cfg: Dictionary = Mod.shown_cfg(peer_id, (Net.players[peer_id] as Dictionary).get("cfg", {}))
	var port: TextureRect = null
	if cfg is Dictionary and not cfg.is_empty():
		port = TextureRect.new()
		port.custom_minimum_size = Vector2(88, 88)
		port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		port.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(port)
	var title: = Label.new()
	title.text = pname
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.style_label(title, "title")
	v.add_child(title)



	var mkbtn: = func(text: String, kind: String, cb: Callable) -> void :
		var b: = Button.new()
		b.text = text
		b.custom_minimum_size = Vector2(0, 40)
		UiStyle.style_button(b, kind, 16)
		b.pressed.connect( func():
			layer.queue_free()
			cb.call()
			dismiss.call())
		v.add_child(b)


	var pside: = int((Net.players[peer_id] as Dictionary).get("side", 0))


	var team_colours: = DressCode.team_colours(Net.stage, Net.rule_outfit)
	if Net.custom_lobby and Net.is_host and not Net.in_match and pside != 0 and team_colours:
		var seat: = TeamKits.seat_key(peer_id, 0)
		if String(Net.captains.get(pside, "")) == seat:
			mkbtn.call("remove captain", "secondary", func(): Net.set_captain(pside, ""))
		else:
			mkbtn.call("make captain", "primary", func(): Net.set_captain(pside, seat))

	if not DevBadge.is_owner_peer(peer_id):
		if Net.custom_lobby:

			if Net.is_host:
				mkbtn.call("kick", "secondary", func(): Net.host_kick(peer_id))
				mkbtn.call("ban from lobby", "exit", func(): Net.host_lobby_ban(peer_id))
		elif Net.can_votekick():


			mkbtn.call("vote to kick", "exit", func(): Net.request_votekick(peer_id))
	if Reports.can_report(sid):
		var rb: = Button.new()
		rb.text = "report"
		rb.custom_minimum_size = Vector2(0, 40)
		UiStyle.style_button(rb, "tertiary", 16)
		rb.pressed.connect( func():
			layer.queue_free()
			ReportPopup.open(sid, pname, null, on_dismiss))
		v.add_child(rb)



	mkbtn.call("unmute" if Mod.is_muted(peer_id) else "mute", "secondary", 
		func():
			var now_muted: = Mod.toggle_mute(peer_id)
			UiStyle.flash_pill(("%s has been muted" if now_muted else "%s has been unmuted") % pname, 
				UiStyle.SECONDARY, "information", 3.0))




	if sid != 0 and Mod.BLOCKING:
		if Mod.blocked_here(sid):
			mkbtn.call("unblock", "secondary", func():
				Mod.unblock_sid(sid)
				UiStyle.flash_pill("%s has been unblocked" % pname, UiStyle.SECONDARY, "information", 3.0))
		elif not Mod.steam_blocked(sid):
			mkbtn.call("block", "exit", func():
				Mod.block_sid(sid)
				UiStyle.flash_pill("%s has been blocked" % pname, UiStyle.RED, "information", 3.0)
				Net.open_steam_profile(sid))
	if sid != 0 and Net.can_open_steam_profile():
		mkbtn.call("steam profile", "tertiary", func(): Net.open_steam_profile(sid))

	var cancel: = Button.new()
	cancel.text = "cancel"
	cancel.custom_minimum_size = Vector2(0, 36)
	UiStyle.style_button(cancel, "tertiary", 14)
	cancel.pressed.connect( func():
		layer.queue_free()
		dismiss.call())
	v.add_child(cancel)


	(tree.current_scene if tree.current_scene != null else tree.root).add_child(layer)
	UiStyle.sfx("open")

	if port != null:
		var tex = await CharacterPortrait.head_cached(cfg, layer, "head")
		if is_instance_valid(port):
			port.texture = tex
