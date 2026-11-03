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
		check(m.ball.global_position.is_equal_approx(m.player.global_position + Vector3(0, 5.2, 0)), "G spawns above player, cycle %d" % cycle)
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
		m._rally.do_toss(Ball.serve_toss_up(0.667), 2.2)
		check(m.ball.vel.y > 13.0, "minigame toss is higher")
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
		m._rally.do_toss(Ball.serve_toss_up(0.667), 2.2)
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
	check(m._rally._auto_serve_left > 0.9, "automatic hit waits for higher toss")
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
	GameConfig.power_cap = saved_power_cap
	print("BALL REGRESSION COMPLETE: failures=", failures)
	m.queue_free()
	await get_tree().process_frame
	get_tree().quit(failures)
