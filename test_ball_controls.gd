extends Node

class TestMain extends Node:
	enum Phase {DEAD, SERVE_PREP, LIVE}
	enum NetRole {OFFLINE}
	var _net_role = NetRole.OFFLINE
	var _phase = Phase.DEAD
	var _all_players: Array = []
	var _tick_inputs = {}
	var _seats: Array = []
	var _spectating = false
	var _rally: Rally
	var player: Player
	var ball: Ball
	func _close_serve_minigame(): pass
	func _hide_landing_call(): pass
	func _net_event(_kind, _args): pass

var requests = 0
var failures = 0

func check(ok: bool, message: String):
	if ok:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)

func _ready():
	run.call_deferred()

func run():
	var saved_power_cap: int = GameConfig.power_cap
	GameConfig.power_cap = 16
	var m = TestMain.new()
	add_child(m)
	m.ball = load("res://game/ball/ball.tscn").instantiate()
	m.add_child(m.ball)
	m.ball.set_physics_process(false)
	m.player = load("res://game/player/player.tscn").instantiate()
	m.add_child(m.player)
	m.player.global_position = Vector3(1, 0, 10)
	m.player.team_side = 1
	m.player.power_level = 2
	m._all_players = [m.player]
	var input = PlayerInput.new()
	m._tick_inputs[m.player] = input
	m._rally = Rally.new()
	m._rally.ball = m.ball
	m._rally.court = Court.new().configure(0.0, 4.5, 9.0)
	m._rally.players = [m.player]
	m._rally.practice = true
	m._rally.input_for = func(_p): return input
	m._rally.tossed.connect(func(_p): m._phase = m.Phase.LIVE)
	m._rally.serve_minigame_requested.connect(func(_p): requests += 1)
	m.ball.bounced.connect(m._rally.ball_bounced)
	var practice = PracticeMode.new()
	practice.main = m
	await get_tree().process_frame
	for cycle in 3:
		input.call_pressed = true
		input.serve_pressed = false
		practice._call_ball()
		input.call_pressed = false
		check(m.ball.global_position.is_equal_approx(m.player.global_position + Vector3(0, 7.5, 0)), "G spawns above player, cycle %d" % cycle)
		check(not m.ball.frozen and m._phase == m.Phase.LIVE and m._rally.serve_done, "G releases playable ball")
		input.serve_pressed = true
		practice._call_ball()
		m._rally.serve_tick(1.0 / 60.0)
		check(requests == cycle, "recall V is consumed once")
		check(m.ball.frozen and m._phase == m.Phase.SERVE_PREP, "V recalls ball into hands")
		input.serve_pressed = true
		m._rally.serve_tick(1.0 / 60.0)
		check(requests == cycle + 1, "next immediate V opens minigame")
		input.serve_pressed = false
		m.player.serve_style = {"type": "float", "power": 0.33, "charge": 1.0, "pattern": 7}
		m._rally.do_toss(Ball.PHYS.serve_toss_min, 1.2)
		check(is_equal_approx(m.ball.vel.y, 10.0), "minigame toss uses the match toss speed")
		for tick in 200:
			m.ball._physics_process(1.0 / 60.0)
		check(m._rally.dead, "dropped serve becomes dead")
		input.serve_pressed = true
		practice._call_ball()
		check(m.player.serve_style.is_empty(), "recalled serve clears previous minigame style")
		input.serve_pressed = false
	for repeat in 3:
		input.serve_pressed = true
		m._rally.serve_tick(1.0 / 60.0)
		check(requests == 4 + repeat, "repeated V minigame after dropped ball, attempt %d" % repeat)
		input.serve_pressed = false
		m._rally.do_toss(Ball.PHYS.serve_toss_min, 1.2)
		for tick in 200:
			m.ball._physics_process(1.0 / 60.0)
		input.serve_pressed = true
		practice._call_ball()
		m._rally.serve_tick(1.0 / 60.0)
		input.serve_pressed = false
	check(load("res://game/main/main.gd").can_instantiate(), "main scene script compiles")
	check(load("res://game/ui/menu.gd").can_instantiate(), "menu script compiles")
	m.player.power_level = 12
	practice.give_ball(m.player)
	input.serve_pressed = true
	m._rally.serve_tick(1.0 / 60.0)
	check(is_equal_approx(m.ball.vel.y, 10.0), "regular V toss uses increased upward speed")
	check(is_equal_approx(m._rally._auto_serve_left, Rally.POWER_SERVE_WINDUP), "automatic hit meets the rising ball")
	for cap in range(3, 17):
		GameConfig.power_cap = cap
		for displayed in range(1, cap + 1):
			m.player.power_level = GameConfig.power_disp_level(displayed)
			practice.give_ball(m.player)
			var before: int = requests
			input.serve_pressed = true
			m._rally.serve_tick(1.0 / 60.0)
			if displayed <= 3:
				check(requests == before + 1 and m.ball.frozen,
					"power %d/%d opens minigame" % [displayed, cap])
			else:
				check(requests == before and not m.ball.frozen and m._rally._auto_serve_left > 0.0,
					"power %d/%d starts automatic serve" % [displayed, cap])
			input.serve_pressed = false
	GameConfig.power_cap = 8
	var channel := NetSync.InputChannel.new()
	var edges := {"jr": 0, "cr": 0, "dv": 0, "sv": 0}
	var packet := channel.encode(input, GameConfig.power_disp_level(3))
	GameConfig.power_cap = 16
	var remote := NetSync.decode_input_fields(packet, edges)
	check(remote.power_cap == 8 and GameConfig.power_disp_of(remote.power_level, remote.power_cap) == 3,
		"the host reads the guest's power scale")
	var snapshot := StateCodec.decode_snapshot(StateCodec.encode_snapshot({"sc": 5.0, "sd": false, "sa": true}))
	check(snapshot.get("sa", false) and not snapshot.get("sd", true), "serve assist round-trips independently of serve done")
	var serve_from := Vector3(0.0, 3.8, 9.8)
	var serve_to := Vector3(0.0, 0.0, -8.0)
	var drive := Ball.solve_serve(serve_from, serve_to, 1.35)
	var soft := Ball.solve_serve(serve_from, serve_to, 0.35)
	check(absf(drive.z) > absf(soft.z) * 1.2, "power serve travels faster than a soft serve")
	check_flight(serve_from, serve_to, drive, "power serve")
	var spike_from := Vector3(0.0, 4.4, 0.45)
	for depth in [1.0, 2.0, 3.0]:
		var spike_to := Vector3(0.0, 0.0, -depth)
		var spike := Ball.solve_launch(spike_from, spike_to, Player.TouchKind.SPIKE, 1.0, false)
		check(spike.y < -18.0, "power spike drives down at %.0f m" % depth)
		check_flight(spike_from, spike_to, spike, "spike at %.0f m" % depth)
	GameConfig.power_cap = saved_power_cap
	print("BALL REGRESSION COMPLETE: failures=", failures)
	m.queue_free()
	await get_tree().process_frame
	get_tree().quit(failures)

func check_flight(start: Vector3, target: Vector3, velocity: Vector3, name: String) -> void:
	var dt := 1.0 / Engine.physics_ticks_per_second
	var position := start
	var over_net := false
	for _i in range(300):
		var last := position
		velocity.y -= Ball.PHYS.gravity * dt
		position += velocity * dt
		if last.z > 0.0 and position.z <= 0.0:
			var fraction := last.z / (last.z - position.z)
			over_net = lerpf(last.y, position.y, fraction) >= Ball.PHYS.net_height + Ball.PHYS.radius
		if position.y <= Ball.PHYS.radius:
			var fraction := (last.y - Ball.PHYS.radius) / (last.y - position.y)
			var landing := last.lerp(position, fraction)
			check(over_net and absf(landing.z - target.z) < 0.25, name + " clears the net and reaches its target")
			return
	check(false, name + " lands within 300 physics ticks")
