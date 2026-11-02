extends Node

var rally
var server
var ball
var inp
var mg: = 0
var tosses: = 0

func _ready() -> void :
	print("TEST ready start")
	print("s1")
	var court = load("res://game/core/court.gd").new().configure(0.0, 4.5, 9.0)
	print("s2")
	ball = load("res://game/ball/ball.tscn").instantiate()
	add_child(ball)
	print("s3")
	print("s4")
	server = load("res://game/player/player.tscn").instantiate()
	add_child(server)
	print("s5")
	server.set("team_side", 1)
	server.set("power_level", 2)
	server.set("global_position", Vector3(0.0, 0.1, 9.8))
	inp = load("res://game/core/player_input.gd").new()
	print("s6")
	rally = load("res://game/core/rally.gd").new()
	rally.court = court
	print("s7")
	rally.ball = ball
	rally.players = [server]
	rally.bots = {}
	rally.practice = true
	rally.input_for = func(_p): return inp
	rally.serve_minigame_requested.connect(func(_s): mg += 1)
	rally.tossed.connect(func(_s): tosses += 1)
	_run.call_deferred()

func _run() -> void :
	for i in 5:
		await get_tree().process_frame
	print("TEST --- SERVE1 (bar 2) ---")
	print("A: practice_serve start")
	rally.practice_serve(server)
	print("A2: practice_serve done")
	for i in 30:
		inp.serve_pressed = false
		rally.serve_tick(1.0 / 60.0)
		if i % 10 == 0:
			print("tick ", i)
	inp.serve_pressed = true
	rally.serve_tick(1.0 / 60.0)
	inp.serve_pressed = false
	rally.serve_tick(1.0 / 60.0)
	print("TEST after V: mg=", mg, " (ochik 1)")
	server.set("serve_style", {"type": "float", "power": 0.33, "charge": 1.0, "pattern": 7})
	rally.do_toss(Ball.serve_toss_up(0.667), 2.2)
	print("TEST after mg: tosses=", tosses, " live=", rally.live, " vy=", "%.1f" % ball.vel.y)
	for i in 130:
		inp.serve_pressed = false
		ball._physics_process(1.0 / 60.0)
		rally.live_tick(1.0 / 60.0)
	print("TEST ball pos y: ", "%.1f" % ball.global_position.y)
	print("TEST --- SERVE2 (povtorno) ---")
	rally.practice_serve(server)
	for i in 30:
		inp.serve_pressed = false
		rally.serve_tick(1.0 / 60.0)
	inp.serve_pressed = true
	rally.serve_tick(1.0 / 60.0)
	inp.serve_pressed = false
	rally.serve_tick(1.0 / 60.0)
	print("TEST after V2: mg=", mg, " (2 = ok / 1 = BUG)")
	server.set("serve_style", {"type": "float", "power": 0.45, "charge": 0.8, "pattern": 5})
	rally.do_toss(Ball.serve_toss_up(0.667), 2.2)
	print("TEST serve2 toss: tosses=", tosses, " live=", rally.live)
	get_tree().quit()
