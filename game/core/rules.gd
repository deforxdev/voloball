class_name Rules
extends RefCounted










const TOUCHES_PER_SIDE: = 3






enum Bar{NONE, DEAD, CONSECUTIVE, THREE_TOUCH, SERVE, TEAM_LOCK}




const HOME_COLOR: = Color(0.35, 1.0, 0.55)
const AWAY_COLOR: = Color(1.0, 0.25, 0.72)

static func side_color(side: int) -> Color:
	return HOME_COLOR if side > 0 else AWAY_COLOR






static var set_swapped: = false



static func half_identity(point_z: float) -> int:
	var court_side: = 1 if point_z >= 0.0 else -1
	return - court_side if set_swapped else court_side


static func half_color(point_z: float) -> Color:
	return side_color(half_identity(point_z))

static func side_name(side: int) -> String:
	return "home" if side > 0 else "away"

static func bar_reason(member: Player, last_toucher: Player, team_size: int, 
		touch_count: int, owner_side: float, phase_dead: bool, 
		serve_crossed: bool, serve_side: int, server: Player, 
		team_lock_side: = 0) -> int:

	if phase_dead:
		return Bar.DEAD


	if member == last_toucher and team_size > 1:
		return Bar.CONSECUTIVE






	if touch_count >= TOUCHES_PER_SIDE and float(member.team_side) == owner_side:
		return Bar.THREE_TOUCH







	if not serve_crossed and member.team_side == serve_side\
	and (member != server or touch_count >= 1):
		return Bar.SERVE


	if team_lock_side != 0 and member.team_side == team_lock_side:
		return Bar.TEAM_LOCK
	return Bar.NONE

static func touch_barred(member: Player, last_toucher: Player, team_size: int, 
		touch_count: int, owner_side: float, phase_dead: bool, 
		serve_crossed: bool, serve_side: int, server: Player, 
		team_lock_side: = 0) -> bool:
	return bar_reason(member, last_toucher, team_size, touch_count, owner_side, 
		phase_dead, serve_crossed, serve_side, server, team_lock_side) != Bar.NONE






static func bar_shows_marker(reason: int) -> bool:
	return reason == Bar.CONSECUTIVE or reason == Bar.THREE_TOUCH


















static func carom_body(ball: Ball, bodies: Array, from: = Vector3.INF) -> Player:
	if ball == null or ball.frozen or ball.net_puppet:
		return null
	var p: = ball.global_position


	var floor_y: = Ball.PHYS.radius + 0.01
	if ball.vel.y >= 0.0 or p.y >= Ball.PHYS.carom_height:
		return null
	if (p.y if from == Vector3.INF else from.y) <= floor_y:
		return null
	var best: Player = null
	var best_d: = Ball.PHYS.carom_radius
	for b in bodies:
		var body: Player = b
		if body == null or not is_instance_valid(body) or not body.grounded()\
		or not body.in_play_height(p.y):
			continue
		if body.contact_state != Player.ContactState.IDLE\
		and body.contact_state != Player.ContactState.RECOVER:
			continue
		if body.contact_intent_queued():
			continue
		var d: = Vector2(body.global_position.x - p.x, 
			body.global_position.z - p.z).length()
		if from != Vector3.INF:
			d = minf(d, _band_sweep_dist(from, p, body.global_position))
		if d < best_d:
			best_d = d
			best = body
	return best





static func _band_sweep_dist(from: Vector3, to: Vector3, feet: Vector3) -> float:
	var lo: = Ball.PHYS.radius + 0.01
	var hi: = Ball.PHYS.carom_height
	var dy: = to.y - from.y
	var t0: = 0.0
	var t1: = 1.0
	if absf(dy) > 0.0001:
		var ta: = (lo - from.y) / dy
		var tb: = (hi - from.y) / dy
		t0 = maxf(0.0, minf(ta, tb))
		t1 = minf(1.0, maxf(ta, tb))
	elif from.y < lo or from.y >= hi:
		return INF
	if t0 > t1:
		return INF
	var a: = from.lerp(to, t0)
	var b: = from.lerp(to, t1)
	var c: = Geometry2D.get_closest_point_to_segment(Vector2(feet.x, feet.z), 
		Vector2(a.x, a.z), Vector2(b.x, b.z))
	return c.distance_to(Vector2(feet.x, feet.z))










static var spiker_pass_rule: = true
static var attacker_pass_rule: = true
static var hard_knock_rule: = true
static func body_hit(ball: Ball, from: Vector3, bodies: Array, hit_side: int, 
		by_half: = false) -> Array:
	if ball == null or ball.frozen or ball.net_puppet or hit_side == 0\
	or from == Vector3.INF:
		return []
	var to: = ball.global_position
	var reach: = Ball.PHYS.body_radius + Ball.PHYS.radius
	var best: Array = []
	var best_d: = reach
	for b in bodies:
		var body: Player = b
		if body == null or not is_instance_valid(body) or not body.in_play_height(to.y):
			continue
		var side: = int(signf(body.global_position.z)) if by_half else body.team_side
		if side == hit_side or side == 0:
			continue
		if body.knocked() or body.diving() or body.getting_up():
			continue




		if spiker_pass_rule and not body.grounded() and body == ball.hit_by\
		and ball.deflected():
			continue



		if attacker_pass_rule and body.attacking_in_air():
			continue
		var feet: = body.global_position



		if signf(to.z) != signf(feet.z) and not ball.net_contested():
			continue
		var lo: = feet + Vector3.UP * Ball.PHYS.body_radius
		var hi: = feet + Vector3.UP * (Ball.PHYS.body_height - Ball.PHYS.body_radius)
		var pts: = Geometry3D.get_closest_points_between_segments(from, to, lo, hi)
		var on_ball: Vector3 = pts[0]
		var on_body: Vector3 = pts[1]
		var d: = on_ball.distance_to(on_body)


		if d < best_d and ball.vel.dot(on_body - from) > 0.0:
			best_d = d
			best = [body, on_body]
	return best












static func body_knocks(who: Player, kind_in: int, power: float) -> bool:
	if who.contact_state == Player.ContactState.BLOCK:
		return false
	if not hard_knock_rule:
		return power >= 1.0 or not who.grounded()
	return power >= 1.0 and kind_in != Player.TouchKind.SET

const BODY_BLOCK_ZONE: = 1.5
static func body_blocking(who: Player, ball: Ball) -> bool:
	return (who.contact_state == Player.ContactState.BLOCK\
	or ( not who.grounded() and absf(who.global_position.z) <= BODY_BLOCK_ZONE))\
	and ball.global_position.y > Ball.PHYS.net_height



const SERVE_LINE_TOL: = 0.05







const SERVE_ZONE_SIDE: = 2.5
const SERVE_ZONE_FRONT: = 0.0


const OUT_OF_PLAY_BACK_MARGIN: = 9.0
const SERVE_ZONE_DEPTH: = OUT_OF_PLAY_BACK_MARGIN

static func serve_foot_fault(launch_z: float, half_l: float) -> bool:




	return launch_z < half_l - SERVE_LINE_TOL



const BASE_HALF_W: = 4.5
const BASE_HALF_L: = 9.0
const LINE_HALF_WIDTH: = 0.025

static func ball_in(pos: Vector3, half_w: float, half_l: float, 
		center_x: = 0.0) -> bool:



	var edge_x: = half_w + LINE_HALF_WIDTH * (half_w / BASE_HALF_W) + Ball.PHYS.radius
	var edge_z: = half_l + LINE_HALF_WIDTH * (half_l / BASE_HALF_L) + Ball.PHYS.radius
	return absf(pos.x - center_x) <= edge_x and absf(pos.z) <= edge_z


static func tape_half(half_w: float, half_l: float) -> Vector2:
	return Vector2(LINE_HALF_WIDTH * (half_w / BASE_HALF_W), 
		LINE_HALF_WIDTH * (half_l / BASE_HALF_L))






static func line_margins(pos: Vector3, half_w: float, half_l: float, 
		center_x: = 0.0) -> Vector2:
	var tape: = tape_half(half_w, half_l)
	return Vector2(half_w + tape.x + Ball.PHYS.radius - absf(pos.x - center_x), 
		half_l + tape.y + Ball.PHYS.radius - absf(pos.z))



static func on_line(pos: Vector3, half_w: float, half_l: float, center_x: = 0.0) -> bool:
	var m: = line_margins(pos, half_w, half_l, center_x)
	if m.x < 0.0 or m.y < 0.0:
		return false
	var tape: = tape_half(half_w, half_l)


	return m.x <= tape.x * 2.0 + Ball.PHYS.radius * 2.0\
	or m.y <= tape.y * 2.0 + Ball.PHYS.radius * 2.0








static func touch_clears_net(kind: int) -> bool:
	return kind == Player.TouchKind.BUMP or kind == Player.TouchKind.SET

static func contact_strength(kind: int, power: float) -> float:
	match kind:
		Player.TouchKind.SPIKE:
			return 0.6 + 0.4 * power
		Player.TouchKind.DUMP:
			return 0.5
		Player.TouchKind.BLOCK:
			return 0.8





		Player.TouchKind.BUMP:
			return 0.25 + 0.5 * power
		Player.TouchKind.SET:
			return 0.25 + 0.45 * power


		Player.TouchKind.CAROM:
			return 0.3 + 0.5 * power
	return 0.25



static func contact_sound(kind: int, power: float, quiet: = 0.0) -> Dictionary:
	match kind:
		Player.TouchKind.SPIKE:
			return {"n": "spike", "db": lerpf(-6.0, 0.0, power) + quiet, "pt": 1.0}
		Player.TouchKind.DUMP:
			return {"n": "hit_medium", "db": -3.0 + quiet, "pt": 1.0}
		Player.TouchKind.BLOCK:
			return {"n": "block_hard" if power > 0.6 else "block_medium", 
				"db": quiet, "pt": 1.0}





		Player.TouchKind.BUMP:
			return {"n": "hit_soft", "db": lerpf(-5.0, 0.5, power) + quiet, 
				"pt": lerpf(1.06, 0.94, power)}
		Player.TouchKind.SET:
			return {"n": "hit_soft", "db": lerpf(-7.0, -1.0, power) + quiet, 
				"pt": lerpf(1.16, 1.0, power)}


		Player.TouchKind.CAROM:
			return {"n": "hit_soft", "db": lerpf(-6.0, 0.0, power) + quiet, 
				"pt": lerpf(0.9, 0.78, power)}
	return {"n": "hit_soft", "db": -4.0 + quiet, "pt": 1.0}



static func contact_fx(fx: Fx, pos: Vector3, strength: float, dir: Vector3, 
		wet: = 0.0, full: = true, kind: = -1, combo_tier: = 0) -> void :



	var heavy: = kind == Player.TouchKind.SPIKE or kind == Player.TouchKind.BLOCK





	var control: = kind == Player.TouchKind.BUMP or kind == Player.TouchKind.SET


	var rim: = Player.combo_color(combo_tier)\
	if combo_tier >= 1 and kind == Player.TouchKind.SPIKE else Color(0, 0, 0, 0)

	if kind == Player.TouchKind.SPIKE and combo_tier >= 3:
		strength *= 1.3
	if full:
		if not control:
			fx.impact(pos, strength, dir, heavy, rim)
	elif not control:

		fx.ring(pos, dir, strength * 0.5, rim)
	fx.burst(pos, strength, dir, wet)
	sweat_spray(fx, pos, strength, wet)





	if full and (kind == Player.TouchKind.SPIKE or control):
		var burst_tier: = combo_tier
		if control and burst_tier < 1:
			burst_tier = 1
		if burst_tier >= 1:
			fx.combo_burst(pos, dir, burst_tier)

static func sweat_spray(fx: Fx, pos: Vector3, strength: float, wet: float) -> void :


	if wet <= 0.05:
		return
	var count: = int(round(wet * (2.0 + strength * 5.0)))
	for i in count:
		fx.sweat(pos + Vector3(randf_range(-0.22, 0.22), 
			randf_range(-0.15, 0.25), randf_range(-0.22, 0.22)))














static func rotation_ring(n: int) -> Array:
	if n <= 1:
		return [0]
	var front_count: = maxi(1, int(n / 2.0))
	var ring: Array = [front_count - 1]
	for i in range(n - 1, front_count - 1, -1):
		ring.append(i)
	for i in range(0, front_count - 1):
		ring.append(i)
	return ring

static func rotated_slot(base_slot: int, n: int, steps: int) -> int:

	if n <= 1 or steps == 0:
		return base_slot
	var ring: = rotation_ring(n)
	var idx: = ring.find(base_slot)
	if idx < 0:
		return base_slot
	return int(ring[(idx + steps) % ring.size()])

static func server_slot(n: int) -> int:


	return 0 if n <= 1 else n - 1























static func bodies_collide(a: Player, b: Player) -> bool:


	return a.team_side == b.team_side\
	and signf(a.global_position.z) * signf(b.global_position.z) >= 0.0





static func air_bumps(players: Array, enabled: = true) -> Array:
	var hits: Array = []




	if not enabled:
		return hits
	for i in players.size():
		var a: Player = players[i]
		if a == null or a.knocked():
			continue
		for j in range(i + 1, players.size()):
			var b: Player = players[j]
			if b == null or b.knocked() or not bodies_collide(a, b):
				continue

			var a_dive: = a.dive_strikes()
			var b_dive: = b.dive_strikes()

			var reach: = 1.05 if (a_dive or b_dive) else 0.85
			if a.global_position.distance_to(b.global_position) > reach:
				continue
			if not a_dive and not b_dive\
			and (a.is_on_floor() or b.is_on_floor()):
				continue
			var dir: = a.global_position - b.global_position
			dir.y = 0.0
			dir = dir.normalized() if dir.length() > 0.01 else Vector3.RIGHT


			var a_momentum: = Vector3(b.velocity.x, 0.0, b.velocity.z)
			var b_momentum: = Vector3(a.velocity.x, 0.0, a.velocity.z)
			if a_dive and not b_dive:
				b.knock(b_momentum * 0.8 - dir * 2.0 + Vector3(0, 2.0, 0))
			elif b_dive and not a_dive:
				a.knock(a_momentum * 0.8 + dir * 2.0 + Vector3(0, 2.0, 0))
			else:
				a.knock(a_momentum * 0.8 + dir * 2.0 + Vector3(0, 2.0, 0))
				b.knock(b_momentum * 0.8 - dir * 2.0 + Vector3(0, 2.0, 0))
			hits.append({
				"pos": (a.global_position + b.global_position) * 0.5, 
				"dir": dir, 


				"a": a, "b": b, "a_dive": a_dive, "b_dive": b_dive, 
			})
	return hits








const STOMP_REACH: = 0.68
const STOMP_FOOT_MIN: = 0.45
const STOMP_FOOT_MAX: = 1.45
const STOMP_SHOVE: = 3.0
const STOMP_POP: = 1.6
const STOMP_KNOCK: = 0.5
const STOMP_BOUNCE: = 5.5
const STOMP_HOP_OUT: = 4.0
static func stomps(players: Array, enabled: = true) -> Array:
	var hits: Array = []
	if not enabled:
		return hits
	for a in players:
		var stomper: Player = a


		if stomper == null or stomper.knocked() or stomper.diving() or stomper.getting_up():
			continue
		if stomper.grounded() or stomper.velocity.y >= 0.0:
			continue
		for b in players:
			var victim: Player = b




			if victim == null or victim == stomper or victim.knocked() or victim.getting_up():
				continue
			if not victim.grounded():
				continue
			if not bodies_collide(stomper, victim):
				continue
			var flat: = stomper.global_position - victim.global_position
			flat.y = 0.0
			if flat.length() > STOMP_REACH:
				continue


			var rise: = stomper.global_position.y - victim.global_position.y
			if rise < STOMP_FOOT_MIN or rise > STOMP_FOOT_MAX:
				continue



			var sep: = flat
			if sep.length() < 0.3:
				sep = Vector3(stomper.velocity.x, 0.0, stomper.velocity.z)
			if sep.length() < 0.3:
				sep = Vector3(randf() - 0.5, 0.0, randf() - 0.5)
			sep = sep.normalized()

			victim.knock( - sep * STOMP_SHOVE + Vector3(0.0, STOMP_POP, 0.0), STOMP_KNOCK)


			stomper.velocity = sep * STOMP_HOP_OUT + Vector3(0.0, STOMP_BOUNCE, 0.0)
			hits.append({"stomper": stomper, "victim": victim, 
				"pos": victim.global_position})
			break
	return hits






const NET_GRAZE: = 0.5





static func net_crossing(ball_z: float, prev_side: float) -> Dictionary:
	if absf(ball_z) < NET_GRAZE:
		return {"side": prev_side, "crossed": false}
	var side: = signf(ball_z)
	return {
		"side": side, 
		"crossed": side != 0.0 and prev_side != 0.0 and side != prev_side, 
	}













const MVP_WEIGHTS: = {"pts": 3, "ace": 2, "blk": 2, "ast": 2, "dig": 2, "set": 1, "rcv": 1}

static func mvp_score(row: Dictionary) -> int:
	var score: = 0
	for k in MVP_WEIGHTS:
		score += int(MVP_WEIGHTS[k]) * int(row.get(k, 0))
	return score



static func stat_row_key(row: Dictionary) -> String:
	return "%d:%s" % [int(row.get("side", 1)), String(row.get("name", ""))]



static func team_mvps(rows: Array) -> Dictionary:
	var out: = {}
	for side in [1, -1]:
		var best: = ""
		var best_key: = Vector2i(0, 0)
		var tied: = false
		for r in rows:
			var d: Dictionary = r
			if int(d.get("side", 1)) != side:
				continue
			var key: = Vector2i(mvp_score(d), int(d.get("pts", 0)))
			if key.x <= 0:
				continue
			if key > best_key:
				best_key = key
				best = stat_row_key(d)
				tied = false
			elif key == best_key:
				tied = true
		if best != "" and not tied:
			out[side] = best
	return out
