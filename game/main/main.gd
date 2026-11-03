extends Node3D


















const PLAYER_SCENE: = preload("res://game/player/player.tscn")










const POINT_WIPE: = preload("res://game/ui/point_wipe.gd")
const MIGRATION_COVER: = preload("res://game/ui/migration_cover.gd")
const BASE_HALF_W: = 4.5
const BASE_HALF_L: = 9.0
const LINE_HALF_WIDTH: = 0.025
const SET_POINTS: = 7
const SETS_TO_WIN: = 2
const DEAD_TIME: = 2.3
const SET_BREAK_TIME: = 4.8
const SNAPSHOT_EVERY: = 2




const PSTATE_FLOATS: = ReplayData.NET_PLAYER_FLOATS







const INTERP_DELAY_MIN: = 40.0
const INTERP_DELAY_MAX: = 140.0






const INTERP_GAP_DECAY: = 0.97
const INTERP_GAP_MULT: = 1.15
const INTERP_GAP_MARGIN: = 25.0
const LAG_TOUCH_HISTORY_MS: = 280.0







const BALL_PRESENT_MAX_MS: = 100.0






const SNAP_MS: = 1000.0 / 30.0



const CLOCK_RELAX_MS: = 0.6
const CLOCK_WINDOW_SNAPS: = 90
const CLOCK_WARMUP_SNAPS: = 30








const CLOCK_JUMP_MS: = 250.0
const CLOCK_JUMP_SNAPS: = 6
const CLOCK_SLEW_FAST: = 400.0





const CLOCK_SLEW: = 25.0
const DELAY_SLEW: = 40.0



const EXTRAPOLATE_MAX: = 0.045
const HARD_SNAP_DIST: = 1.2




const BALL_DESYNC_SNAP: = 5.0







const BALL_LEASH_DEAD: = 1.0
const BALL_LEASH_MIN: = 1.0
const BALL_LEASH_MAX: = 24.0
const BALL_LEASH_FULL: = 2.5



const INTRO_FADE: = 0.9
const INTRO_HOLD: = 0.55








const INTRO_SWOOP: = 2.6
const INTRO_SLAB: = 0.45
const INTRO_WHIP: = 0.5


const INTRO_SPOT_MAX: = 1.15
const INTRO_SPOT_MIN: = 0.8
const INTRO_SPOT_TEAM: = 3.4
const INTRO_WALK_SPEED: = 0.85




const INTRO_WALK_BACK: = 1.8
const INTRO_STOP_EASE: = 1.6
const INTRO_STOP_DIST: = 0.18
const COUNTDOWN_TIME: = 3.0
const WIN_TIME: = 6.0




const WIN_GROUP_TIME: = 3.4
const WIN_MVP_AT: = 1.2
const WIN_MVP_WEIGHT: = 1.5
const WIN_FADE: = 0.9
const SWEAT_DRY_TIME: = 2.5



const SWAP_DELAY: = 1.5
const SWAP_HOLD: = 0.8
const SWAP_FADE: = 1.8
const LOAD_FADE: = 1.0
const QUICK_COLOR: = Color(1.0, 0.45, 0.78)
const BREAK_COLOR: = Color(0.95, 0.18, 0.18)

const CINE_BLUE: = Rules.HOME_COLOR
const CINE_RED: = Rules.AWAY_COLOR




const REPLAY_LEAD: = 8.0
const REPLAY_TAIL: = 2.0
const REPLAY_BEAT: = 2.6
const REPLAY_CUT: = 0.25


const REPLAY_OUT_HOLD: = 0.35
const REPLAY_OUT_FADE: = 0.75
const REPLAY_ANGLE_TIME: = 4.5


const REPLAY_LAND_WINDOW: = 1.5
const REPLAY_MIN_RALLY: = 12.0


const REPLAY_DIR: = ReplayData.DIR
const HOME_SIDE: = 1



enum Phase{INTRO, COUNTDOWN, DEAD, SERVE_PREP, LIVE, WIN, STATS, REPLAY}
enum NetRole{OFFLINE, HOST, CLIENT}





var _spectating: = false
var _spec_clean: = 0
var _spec_ui: = true

var _watch_cam: WatchCamera = null
var _spec_bar_wired: = false
var reach_marker: ReachMarker = null
@onready var player: Player = $Player
@onready var ball: Ball = $Ball
@onready var court: Node3D = $Court
@onready var camera_rig: CameraRig = $CameraRig
@onready var aim_indicator: AimMarker = $AimIndicator
@onready var barred_marker: Node3D = $BarredMarker
@onready var landing_marker: Node3D = $LandingMarker
@onready var verdict_label: Label3D = $LandingMarker / VerdictLabel
@onready var fx: Fx = $Fx
@onready var sfx: Sfx = $Sfx
@onready var crowd: CrowdAudio = $Crowd
@onready var net_visual: MeshInstance3D = $Court / Net
@onready var hud: Hud = $UiLayer / Hud

var _input_collector: = InputCollector.new()
var _toss_preview: TrajectoryPreview = null
var _bots: = {}
var _all_players: Array = []
var _slots: = {}
var _names: = {}
var _party_of: = {}
var _party_by_sid: = {}


var _cpu_name_pool: Array = []
var _cpu_name_i: = 0
var _stats: = {}
var _foley: = Foley.new()
var _half_w: = BASE_HALF_W
var _half_l: = BASE_HALF_L
var _lines: = Court.new()
var _serve_zone: ServeZoneMarker
var _rally: = Rally.new()


var _phase: = Phase.DEAD
var _dead_timer: = 0.8
var _cine_time: = 0.0
var _cine_t0_us: = 0
var _last_count_n: = 0
var _did_intro: = false




var _pre_intro: = true
var _cine_prev_phase: = Phase.DEAD
var _music_phase: = -1


const MUSIC_CLOSE_POINTS: = 2










const MUSIC_SAVE_SPIKE: = 0.8
const MUSIC_HEAT_HOLD: = 6.0
var _music_heat: = 0





var _music_opener: = false
var _music_build_stage: = -1
var _music_spike_power: = 0.0
var _music_heat_t: = 0.0
var _match_winner: = 0
var _stats_built: = false
var _grabbed_home: = false
var _diss_left: = 0.0
var _diss_fade: = 1.0
var _quick_set_side: int:
	get: return _rally.quick_set_side
	set(v): _rally.quick_set_side = v
var _sweat_shown: = 0.0




var _net_sweat: = 0.0
var _sweat_sent: = -1.0
const SWEAT_SEND_STEP: = 0.04
var _recorder: = ReplayRecorder.new()
var _director: = ReplayDirector.new()
var _replay_pending: = false
var _replay_starting: = false
var _replay_exiting: = false
var _replay_wait: = 0.0
var _skip_votes: = {}
var _voted_skip: = false
var _replay_saved: = false
var _last_replay_path: = ""


const WIN_TAIL: = 2.6
var _win_delay: = 0.0
var _win_pending: = 0



var _run_side: = 0
var _run_len: = 0
var _last_verdict_pos: = Vector3.ZERO
var _puppet_saved: Array = []




var _ball_puppet_saved: = false



var _replay_enabled: = true


var _practice: PracticeMode = null




var embedded: = false
var embedded_active: = false
var practice_court: Node = null
var _team_of_fn: = Callable()
var _practice_dress: = false
var _replay_shot: = -1
var replay_loops: = 0


var _replay_lead: = 0.0



var _replay_prev_t: = 0.0
var _replay_cur_t: = 0.0
var _replay_focus: = Vector3.ZERO
var _replay_on_land: = false
var _replay_cam_side: = 0.0


var _last_spike_power: = 0.0
var _touch_lock: float:
	get: return _rally.touch_lock
	set(v): _rally.touch_lock = v
var _touch_lock_side: int:
	get: return _rally.touch_lock_side
	set(v): _rally.touch_lock_side = v
var _replay_sfx_at: = 0
var _swap_delay: = 0.0
var _serve_prelaid: = false
var _cine_snap_phase: = -1
var _cine_want_snap: = false


var _intro_locked: = false
var _intro_shown_side: = 0
var _intro_swoop: = true
var _intros_run: = 0
var _intro_fired: = {}
var _intro_walk_w1: = {}
var _intro_walked: = {}
var _intro_names_hidden: = false
var _intro_walk_armed: = false
var _floor_mat: ShaderMaterial

var _sand_deform: SandDeform = null
var _sand_mat: ShaderMaterial = null
var _sand_surround_mat: ShaderMaterial = null
var _sand_deck: MeshInstance3D = null




var _stage_painted: = {}
var _stage_shell: Node = null
var _wall_base: = {}
var _last_accent: = Color(0.85, 0.85, 0.85)



var _last_tape: = Color(1, 1, 1)
var _has_tape: = false
var _sun_base_energy: = -1.0
var _net_wobble: = 0.0
var _tick_inputs: = {}








var _serve_clock: float:
	get: return _rally.serve_clock
	set(v): _rally.serve_clock = v
var _serve_side: int:
	get: return _rally.serve_side
	set(v): _rally.serve_side = v
var _server: Player:
	get: return _rally.server
	set(v): _rally.server = v
var _serve_done: bool:
	get: return _rally.serve_done
	set(v): _rally.serve_done = v
var _serve_launch_z: float:
	get: return _rally.serve_launch_z
	set(v): _rally.serve_launch_z = v
var _serve_crossed: bool:
	get: return _rally.serve_crossed
	set(v): _rally.serve_crossed = v
var _serve_attack_window: bool:
	get: return _rally.serve_attack_window
	set(v): _rally.serve_attack_window = v
var _bot_toss_delay: float:
	get: return _rally.bot_toss_delay
	set(v): _rally.bot_toss_delay = v
var _rally_live: bool:
	get: return _rally.live
	set(v): _rally.live = v
var _rally_time: float:
	get: return _rally.rally_time
	set(v): _rally.rally_time = v
var _touch_count: int:
	get: return _rally.touch_count
	set(v): _rally.touch_count = v
var _last_toucher: Player:
	get: return _rally.last_toucher
	set(v): _rally.last_toucher = v
var _last_touch_side: int:
	get: return _rally.last_touch_side
	set(v): _rally.last_touch_side = v
var _touch_side: int:
	get: return _rally.touch_side
	set(v): _rally.touch_side = v
var _team_last_toucher: Dictionary:
	get: return _rally.team_last_toucher
	set(v): _rally.team_last_toucher = v
var _prev_ball_side: float:
	get: return _rally.prev_ball_side
	set(v): _rally.prev_ball_side = v
var _rot: Dictionary:
	get: return _rally.rot
	set(v): _rally.rot = v
var _last_serve_side: int:
	get: return _rally.last_serve_side
	set(v): _rally.last_serve_side = v




var _scores: Dictionary:
	get: return _rally.scores
	set(v):
		_rally.scores.clear()
		for k in v:
			_rally.scores[k] = v[k]
var _set_wins: = {1: 0, -1: 0}
var _set_number: = 1



var _pending_set: = {}


var _net_role: = NetRole.OFFLINE
var _net_tick: = 0
const STATS_REBROADCAST_S: = 10.0
var _stats_bcast_accum: = 0.0
var _net_ids: = {}
var _by_net_id: = {}
var _peer_players: = {}
var _peer_applied: = {}



var _peer_touch_inputs: = {}


var _peer_queue: = {}
var _peer_seq_seen: = {}
var _peer_starved: = {}
var _peer_dropped: = {}
var _peer_starve_run: = {}


const STARVE_STAND_TICKS: = 12
var _peer_trimmed: = {}


const INPUT_QUEUE_MAX: = 6






const INPUT_QUEUE_TARGET: = 2
const INPUT_QUEUE_DEEP_TICKS: = 30
var _peer_deep: = {}





var _local_pid_cache: = 1

func _local_pid() -> int:



	if _net_role == NetRole.OFFLINE:
		return 1
	var mp: = get_multiplayer()
	if mp != null and mp.multiplayer_peer != null:
		_local_pid_cache = mp.get_unique_id()
	return _local_pid_cache






const _LS_MULT: = 8
func _pid_for(peer: int, ls: int) -> int:
	return peer if ls <= 0 else - (peer * _LS_MULT + ls)
func _pid_owner(pid: int) -> int:
	return pid if pid >= 0 else int(( - pid) / _LS_MULT)
func _pid_ls(pid: int) -> int:
	return 0 if pid >= 0 else int(( - pid) % _LS_MULT)

func _owner_bodies(peer: int) -> Array:
	var out: Array = []
	for pid in _peer_players:
		if int(pid) == peer or (int(pid) < 0 and _pid_owner(int(pid)) == peer):
			var b: Player = _peer_players[pid]
			if b != null and is_instance_valid(b):
				out.append(b)
	return out
var _peer_input: = {}
var _peer_edges: = {}
var _snap_buf: Array = []


var _snap_gap: = 33.0
var _snap_seq: = 0
var _snap_newest: = -1
var _clock_offset: = INF
var _clock_offset_min: = INF
var _off_win_min: = INF
var _off_win_n: = 0
var _clock_warm: = 0
var _clock_jump_n: = 0
var _clock_jump_min: = INF
var _delay_now: = INTERP_DELAY_MIN
var _snap_jitter: = 0.0
var _snap_gap_max: = 33.0
var _last_snap_at: = 0
var _np: = {}
var _interp_hard: = false




var _ball_dead: = false



var _client_in_serve_prep: = false



var _in_chan: = NetSync.InputChannel.new()




var _pred: = NetSync.Predictor.new()
var _ball_host_strikes: = -1.0
var _ball_err: = Vector3.ZERO
var _ball_60hz: = true
var _ball_interp: = false
var _ball_present: = true
var _ball_present_lead_ms: = 0.0





var _velsync: = false
const VELSYNC_VEL_WEIGHT: = 0.85
const VELSYNC_POS_WEIGHT: = 0.06
var _ball_handoff: = 0.0
var _ball_offset_armed: = false
var _ball_vis_offset: = Vector3.ZERO
const BALL_HANDOFF_RATE: = 9.0
const BALL_HANDOFF_MAX: = 6.0
var _ball_predicting: = false
var _ball_ballistic: = false
var _bm_prev: = {}






var _ball_grace: = 0.0
var _ball_grace_seq: = -1.0
var _pred_touch_seen: = 0
var _pred_strike_mutes: = 0
var _pred_thumps: Array = []
var _toss_pred: = 0.0

var _toss_visual_state: Array = []
var _toss_unfrozen_snaps: = 0



var _dbg_ball_err_sum: = 0.0
var _dbg_ball_err_max: = 0.0
var _dbg_ball_err_n: = 0
var _dbg_stale_drops: = 0
var _dbg_grace_skips: = 0
var _dbg_pred_err_sum: = 0.0
var _dbg_pred_err_max: = 0.0
var _dbg_pred_err_n: = 0
var _dbg_unfair_floor: = 0
var _dbg_rejected_touch: = 0
var _dbg_since: = 0.0
var _render_host_ms: = -1.0
var _lag_touch: = true



var _dev_match_point: = false
var _lag_history: Array = []
var _lag_touch_requests: Array = []




var _ball_event_flight: = {}
var _match_over: = false


var _last_match_reward: = {}


var _match_rallies: = 0




var _ach_touch: = {}
var _ach_bam: = {}
var _ach_roll: Player = null
var _ach_broke: Player = null
var _ach_chain: = {1: [], -1: []}
var _ach_combo: = {}
var _ach_dives: = {}
var _ach_burnt: = {}
var _ach_cord: Player = null
var _ach_serve: = {}
var _ach_sets: = {}
var _ach_tossed: = false


var _ach_no_rematch: Array = []
var _ach_time_acc: = 0.0
const ACH_TIME_TICK: = 10.0



const TOUCH_STATS_A_RALLY: = 6
var _wait_peers: = {}
var _wait_timeout: = 12.0




var _peer_heard: = {}
const PEER_SILENT_TIMEOUT: = 8.0
var _net_log: = false
var _snap_count: = 0

var _net_shot: = false
var _shot_count: = 0

func _ready() -> void :
	MobileDiagnostics.record("main_ready_entered")

	_practice_dress = PracticeMode.active()

	set_meta(GameConfig.STAGE_WORLD, true)
	if not embedded:



		var ls: = LaunchGate.dev_args().find("--load-stall")
		if OS.has_feature("editor") and ls != -1 and ls + 1 < LaunchGate.dev_args().size():
			OS.delay_msec(int(LaunchGate.dev_args()[ls + 1]))
		GameConfig.tod_live = true
		GameConfig.use_cursor(true)



		ModelRig.lod_views = [get_viewport()]


	Haptics.wire(player)
	_p1_haptic_body = player



	if not embedded:
		MusicManager.set_muffled(false)
		MusicManager.stop(0.6)


	_net_log = LaunchGate.dev_args().has("--net-log")\
	or GameConfig.debug_net_log
	_net_shot = LaunchGate.dev_args().has("--net-shot")
	_ball_60hz = not LaunchGate.dev_args().has("--no-ball60")





	_ball_interp = not LaunchGate.dev_args().has("--no-ball-interp")
	_ball_present = not LaunchGate.dev_args().has("--no-ball-present")



	_velsync = LaunchGate.dev_args().has("--ball-velsync")\
	and not LaunchGate.dev_args().has("--no-ball-velsync")
	_ball_ballistic = LaunchGate.dev_args().has("--ball-ballistic")
	_lag_touch = not LaunchGate.dev_args().has("--no-lag-touch")
	_dev_match_point = LaunchGate.dev_args().has("--match-point")
	_half_w = GameConfig.court_half_width
	_half_l = GameConfig.court_half_length
	_built_stage = GameConfig.stage
	_built_size = GameConfig.team_size


	_lines = Court.new().configure(0.0, _half_w, _half_l)

	_serve_zone = ServeZoneMarker.new()
	_serve_zone.setup(0.0, _half_w, _half_l)
	add_child(_serve_zone)
	if Net.active and (Net.in_match or Net.practice_live) and GameConfig.net_roster.size() > 0:
		_net_role = NetRole.HOST if Net.is_host else NetRole.CLIENT
	elif GameConfig.net_roster.size() > 0 and not Net.active:





		GameConfig.net_roster = []
		GameConfig.lobby_notice = "the session ended before the match loaded"
		set_process(false)
		set_physics_process(false)
		_go_menu.call_deferred()
		return
	if _net_role == NetRole.HOST:



		_team_of_fn = func(pid: int) -> Variant:
			if pid == 1:
				if _spectating or player == null:
					return 0
				return player.team_side
			var b: Player = _peer_players.get(pid)
			if b == null:



				return 0 if Net.players.has(pid) else null
			return b.team_side
		Net.team_of = _team_of_fn
	court.scale = Vector3(_half_w / BASE_HALF_W, 1.0, _half_l / BASE_HALF_L)



	CourtDress.unique_net(net_visual, court.scale.x)


	aim_indicator.net_mat = (net_visual.mesh as PlaneMesh).material as ShaderMaterial
	aim_indicator.net_node = net_visual
	_floor_mat = CourtDress.unique_floor(court)
	var reflector: = FloorReflector.new()
	add_child(reflector)
	reflector.setup(camera_rig.camera)
	CourtDress.wire_reflection(_floor_mat, reflector.texture())
	reflector.floor_mats = [_floor_mat]
	_reflector = reflector
	_apply_stage_tracked()
	MobileDiagnostics.record("match_stage_created")


	if _stage_shell != null:
		for n in _stage_shell.find_children("*", "Node3D", true, false):
			if n.has_method("wire_reflection"):
				n.wire_reflection(reflector.texture())


	reflector.feet_provider = func(): return _all_players + [ball]
	ball.net_half_width = Ball.PHYS.net_half_width * (_half_w / BASE_HALF_W)
	ball.antenna_half_width = Ball.PHYS.antenna_half_width * (_half_w / BASE_HALF_W)



	ball.court_half_w = _half_w
	ball.court_half_l = _half_l
	ball.wall_min = Vector3(-21.7, -1000000.0, -27.7)


	ball.wall_max = Vector3(21.7, 34.0, 27.7)

	_input_collector.aim_min = Vector2( - _half_w - 1.5, - _half_l - 2.5)
	_input_collector.aim_max = Vector2(_half_w + 1.5, _half_l + 2.5)
	if _net_role == NetRole.OFFLINE:
		_spawn_teams()
	else:
		_spawn_teams_net()
	MobileDiagnostics.record("match_players_created")
	if _net_role != NetRole.CLIENT:
		TeamBot.ensure_team_jump_servers(_bots)







	if not GameConfig.modifiers_allowed():
		GameConfig.force_standard_modifiers()
	_rally.setup(_lines, GameConfig.team_size, ball, _all_players, _slots, 
		_bots, _stats)
	_rally.set_points = GameConfig.set_points
	_rally.win_by_two = GameConfig.win_by_two
	_rally.serve_seconds = clampf(float(GameConfig.serve_seconds), 5.0, 60.0)
	_rally.rotate_every_point = GameConfig.rotate_every_point



	ball.hints = GameConfig.ball_hints
	_rally.input_for = func(p: Player): return _tick_inputs.get(p)
	_rally.point.connect(_on_rally_point)
	_rally.set_won.connect( func(w: int): _win_set(w))
	_rally.whistle_fault.connect(_on_rally_whistle)
	_rally.verdict.connect(_on_rally_verdict)

	LandingCall.dress(landing_marker, verdict_label)
	_rally.tossed.connect(_on_rally_tossed)
	_rally.serve_minigame_requested.connect(_spawn_serve_minigame)
	_rally.touch_flair.connect(_on_rally_flair)
	_rally.received.connect(_on_rally_received)
	if PracticeMode.active():
		_practice = PracticeMode.new()
		_practice.setup(self)



		add_child(ChatBubbles.new( func(): return _all_players, func(): return player, 
			Callable(), _body_of_peer, func(): return _net_role == NetRole.OFFLINE))
	for p in _all_players:
		var member: Player = p
		member.ball = ball
		member.quick_check = _quick_set_ready
		member.contact_priority_check = _rally.queued_contact_has_priority
		member.set_display_name(_cpu_tagged(_names[member])\
		if _gone_bodies.has(member) else _names[member])
		_stats[member] = {"pts": 0, "spk": 0, "blk": 0, "rcv": 0, "set": 0, "ast": 0}

		member.jumped.connect(_on_jumped.bind(member))
		if _net_role != NetRole.CLIENT:

			member.dove_into_net.connect( func(): _ach_emit(member, "net_dive", {}))
			member.touched.connect(_on_touched.bind(member))
			member.swung.connect(_on_swung.bind(member))
			member.float_shown.connect(_on_float_shown.bind(member))
			member.combo_shown.connect(_on_combo_shown.bind(member))
			member.thumped.connect(_on_thumped.bind(member))
			member.launched.connect(_on_launched.bind(member))
			member.voiced.connect(_on_voiced.bind(member))
			member.block_broken.connect(_on_block_broken.bind(member))
			member.callout_made.connect(_on_callout_made.bind(member))
	if _net_role == NetRole.CLIENT:
		player.touch_attempted.connect(_on_local_touch_attempted)
		player.thumped.connect(_on_predicted_thumped)
	player.knock_started.connect( func(pos: Vector3, strength: float):


		camera_rig.shake(0.22 * strength))




	_start_recording()
	camera_rig.player = player
	camera_rig.ball = ball

	camera_rig.mode = clampi(GameConfig.default_camera, 0, 
		CameraRig.Mode.size() - 1) as CameraRig.Mode
	camera_rig.mode_changed.connect(hud.show_camera_name)
	_court_mouse_mode()
	camera_rig.home_side = float(player.team_side)
	camera_rig.court_span = _half_l
	ball.home_side = float(player.team_side)
	fx.setup(camera_rig)

	reach_marker = ReachMarker.new()
	add_child(reach_marker)
	reach_marker.setup(camera_rig.camera)

	aim_indicator.set_rig(camera_rig)
	aim_indicator.body_rig = camera_rig
	_toss_preview = TrajectoryPreview.new()
	add_child(_toss_preview)


	reach_marker.entered_reach.connect( func():
		_play_local_reach("reach_in", -8.0))
	reach_marker.action_queued.connect( func():
		_play_local_reach("reach_queue", -2.0))
	reach_marker.took.connect( func():
		_play_local_reach("reach_take", -4.0, 1.15))
	reach_marker.missed.connect( func():
		_play_local_reach("reach_miss", -8.0))
	reach_marker.early.connect( func():
		_play_local_reach("reach_miss", -8.0))
	player.out_of_range.connect( func():
		_play_local_reach("reach_miss", -8.0))


	_input_collector.dive_denied.connect( func():
		if _spectating or _phase == Phase.REPLAY:
			return
		_play_local_reach("reach_miss", -8.0)
		var mine: = _hints_for_p1()
		if mine != null:
			mine.dive_denied()
		else:
			hud.dive_denied()
		player.dive_denied())
	Ink.apply(camera_rig.camera)
	_build_local_views()
	hud.prewarm_burnout()
	ball.fx = fx
	if _net_role != NetRole.CLIENT:
		ball.bounced.connect(_on_ball_bounced)
		ball.wall_hit.connect(_on_ball_wall_hit)
		ball.struck.connect(_on_ball_struck)
		ball.net_hit.connect(_on_net_hit)
		ball.antenna_hit.connect(_on_antenna_hit)
	else:




		ball.struck.connect(_on_predicted_strike)
	if _net_role != NetRole.OFFLINE:


		Net.match_started.connect(_on_net_match_started)


		Net.party_home_called.connect(_on_party_home_called)

		Net.dev_badges_changed.connect(_rebadge_seats)

		Mod.presence_changed.connect(_represence_seats)
		Net.pending_start = []
		_my_peer_id = _local_pid()


		_in_chan.gen = GameConfig.match_seed
		_match_gen = GameConfig.match_seed
	if _net_role == NetRole.HOST and not GameConfig.migrate_carry.is_empty():


		var carry: Dictionary = GameConfig.migrate_carry
		GameConfig.migrate_carry = {}
		_scores = {1: int(carry.s1), -1: int(carry.s2)}
		_set_wins = {1: int(carry.w1), -1: int(carry.w2)}
		_set_number = maxi(int(carry.n), 1)
		Rules.set_swapped = _set_number % 2 == 0
		_migrate_resume = true
	match _net_role:
		NetRole.HOST:
			Net.input_received.connect(_on_net_input)
			Net.up_event_received.connect(_on_up_event)
			Net.peer_left_match.connect(_on_peer_left)
			Net.late_joiner.connect(_on_late_joiner)


			Net.peer_match_ready.connect( func(id: int):
				_wait_peers.erase(id)



				_net_event("stats", {"r": _stat_rows()}))
			for peer_id in _peer_players:



				if peer_id < 0:
					continue
				if not Net.match_ready_peers.has(peer_id):
					_wait_peers[peer_id] = true
		NetRole.CLIENT:




			player.sim_authority = false
			ball.net_puppet = not _velsync_on()
			Net.snapshot_received.connect(_on_snapshot)
			Net.ball_snapshot_received.connect(_on_ball_snapshot)
			Net.event_received.connect(_on_net_event)
			Net.session_ended.connect(_on_session_ended)
			Net.notify_match_ready()
			if _practice_dress and GameConfig.quick_backfill_side != 0 and _spectating:




				Net.send_up("seat", {"s": GameConfig.quick_backfill_side})
			elif _quick() and _spectating:




				hud.notice("you will join at the start of the next rally"\
				if GameConfig.quick_backfill_side != 0\
				else "you will join when a seat opens", SEAT_NOTE_SECS * 2.0)
			GameConfig.quick_backfill_side = 0








	if _net_role == NetRole.HOST:
		call_deferred("_relay_pending_late_joiners")




	hud.set_teams_available((_net_role != NetRole.OFFLINE or not _seats.is_empty())
		and not GameConfig.ranked_match)


	hud.set_teams_source(teams_state)
	hud.seat_requested.connect(_on_seat_requested)


	hud.set_dropin_available(_net_role == NetRole.OFFLINE and not GameConfig.tutorial_finale, 
		dropin_room, func(slot: LocalPlayerSlot) -> bool: return not _seat_for_slot(slot).is_empty())
	hud.couch_changed.connect(_on_couch_changed)

	hud.pause_opened.connect( func():
		camera_rig.input_frozen = true




		_input_collector.swallow_held(["jump", "contact", "dive", "serve"])
		_input_collector.clear_buffers()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	hud.pause_closed.connect( func():
		camera_rig.input_frozen = false

		for seat in _seats:
			seat.erase("fresh")



		_input_collector.swallow_held(["jump", "contact", "dive", "serve"])
		_input_collector.clear_buffers()


		if hud.stats_open():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			camera_rig.apply_mouse_mode())
	hud.pause_pauses_tree = _net_role == NetRole.OFFLINE
	hud.apply_pause_mode()
	hud.play_again_pressed.connect(_on_play_again)
	hud.to_lobby_pressed.connect(_on_to_lobby)


	if embedded and hud.loading_cover != null:
		hud.loading_cover.art = false
	hud.set_loading(1.0)
	_park_ball()
	MobileDiagnostics.record("main_ready_completed")




func _court_mouse_mode() -> void :
	if hud.pause_is_open() or hud.stats_open() or (embedded and not embedded_active):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	camera_rig.apply_mouse_mode()

func _process(_delta: float) -> void :
	if embedded and not embedded_active:

		_audio_hold_t -= _delta
		if _audio_hold_t <= 0.0:
			_audio_hold_t = 0.5
			_pause_world_audio(true)
	_tick_burnout(_delta)

	var play_phase: = _effective_phase()
	ProfileStore.hold_saves = _practice == null\
	and (play_phase == Phase.LIVE or play_phase == Phase.SERVE_PREP)



	if embedded and not embedded_active:
		ModelRig.lod_views = []
	elif _views.is_empty():
		ModelRig.lod_views = [get_viewport()]
	else:
		ModelRig.lod_views = _views.map( func(v): return v.viewport)






	if (hud.pause_is_open() or hud.stats_open()) and not (embedded and not embedded_active)\
	and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



	_poll_stats_input()


	_gate_cinematic_hints()
	_tick_badges()



	_poll_skip_vote()




	if _phase == Phase.REPLAY and _director != null and not _replay_stand_off:
		_director.seek_anims(lerpf(_replay_prev_t, _replay_cur_t, 
			Engine.get_physics_interpolation_fraction()))
	_music_heat_decay(_delta)




	if player != null and not _match_over and _practice == null\
	and _effective_phase() in [Phase.DEAD, Phase.SERVE_PREP, Phase.LIVE]:
		var here: = _ach_locals()
		if not here.is_empty():
			_ach_time_acc += _delta
		if _ach_time_acc >= ACH_TIME_TICK:
			var whole: = int(_ach_time_acc)
			_ach_time_acc -= float(whole)
			for each in here:
				Achievements.notify_for(each[1], "play_time", 
					{"amount": whole, "quiet": true, "where": "match"})





		for each in here:
			var body: Player = each[0]
			if _net_role == NetRole.CLIENT and body != player:
				continue
			if body.stamina_locked and not bool(_ach_burnt.get(body, false)):
				Achievements.notify_for(each[1], "burnout")
			_ach_burnt[body] = body.stamina_locked
	if _migrating:
		return


	_ad_t += _delta
	if _ad_t >= 3.0:
		_ad_t = 0.0
		_quick_ad_refresh()




	if _loading_up:
		_cover_t += _delta
		_warm_feed_faces()
		if _effective_phase() == Phase.INTRO:
			if _net_role != NetRole.CLIENT:
				_loading_up = false
			else:







				_reveal_a = clampf(1.0 - _cine_time / LOAD_FADE, 0.0, _reveal_a)




				hud.set_loading(_reveal_a)
				if _reveal_a <= 0.0:
					_loading_up = false






		elif _net_role == NetRole.CLIENT and (_snap_count > 0\
		or _cover_t > REVEAL_TIMEOUT_S) and not _awaiting_first_intro():
			if _pre_intro:



				_pre_intro = false
				ball.frozen = false


				_interp_hard = true
			_reveal_a = maxf(_reveal_a - _delta * 1.5, 0.0)
			hud.set_loading(_reveal_a)
			if _reveal_a <= 0.0:
				_loading_up = false





	var phase: = _effective_phase()
	_music_tick(phase)



	aim_indicator.body_cut_on = phase != Phase.REPLAY\
	and (_views.is_empty() or LocalViews.is_collapsed(_views))
	var playable: bool = phase == Phase.LIVE or phase == Phase.SERVE_PREP\
	or phase == Phase.DEAD or phase == Phase.COUNTDOWN
	_apply_seat_markers()
	_sync_p1_split_body()
	_tick_reach_marker(phase)











	_input_collector.follow_cursor(camera_rig, 
		playable and not (_intro_locked and phase == Phase.INTRO)
		and not _spectating and not hud.pause_is_open()
		and not hud.chat_typing() and not (embedded and not embedded_active))
	_tick_seat_cursors(playable and not (_intro_locked and phase == Phase.INTRO))
	_tick_seat_ball_bubbles(playable and not (_intro_locked and phase == Phase.INTRO))
	_sync_split_views()
	_tick_seat_connections(_delta)

	_draw_p1_cursor(_input_collector.soft_cursor_active(), 
		_input_collector.soft_cursor_pos())


	if aim_indicator.visible:
		aim_indicator.follow_point(_input_collector.aim_point())

	_input_collector.snap_targets = []
	_input_collector.foe_targets = []
	if not _spectating and player != null:
		for sp in _all_players:
			var sb: Player = sp
			if sb == player:
				continue
			if sb.team_side == player.team_side:
				_input_collector.snap_targets.append(sb)
			else:
				_input_collector.foe_targets.append(sb)

		_input_collector.team_touches = _rally.touch_count\
		if _rally.touch_side == player.team_side else 0


	hud.track_ball_marker(camera_rig.camera, ball, 
		playable and not (_intro_locked and phase == Phase.INTRO)
		and not _spectating and not hud.pause_is_open(), player)

	if _spectating:
		_spec_tick(_delta)


	if _net_role != NetRole.OFFLINE and (hud.pause_is_open() or _spectating):
		_refresh_seat_menu()







func _apply_seat_markers() -> void :
	for p in _all_players:
		var body: Player = p





		var mine: = _is_own_body(body) or _is_seated_body(body)
		body.indicator_enabled = mine
		body.charge_ui_enabled = mine



func _motion_collector() -> InputCollector:
	for seat in _seats:
		if seat.slot.device == DeviceInput.KBM and seat.collector != null:
			return seat.collector
	return _input_collector








func _tick_seat_cursors(playable: bool) -> void :
	var live: = playable and not hud.pause_is_open() and not hud.chat_typing()
	for seat in _seats:
		if seat.view == null or seat.view.overlay == null or seat.rig == null:
			continue
		var free: bool = seat.rig.mode == CameraRig.Mode.ACTION\
		or seat.rig.mode == CameraRig.Mode.FIRST_PERSON
		var ch: = _seat_crosshair(seat.slot)



		var col: Color = Color(seat.cue) if (seat.view.owners.size() > 1)\
		else _crosshair_color(ch, Color(seat.cue))
		var ol: Color = ch.outline
		if free:
			seat.view.overlay.set_cursor(seat.slot, false, Vector2.ZERO, col)
		elif seat.slot.device == DeviceInput.KBM and seat.collector != null:
			seat.collector.follow_cursor(seat.rig, live)
			seat.view.overlay.set_cursor(seat.slot, seat.collector.soft_cursor_active(), 
				seat.collector.soft_cursor_pos(), col, ch.shape, ch.size, ol)
		else:

			var aim: AimMarker = seat.aim
			var show: bool = live and aim != null and aim.visible
			var pos: Vector2 = seat.rig.camera.unproject_position(aim.global_position)\
			if show else Vector2.ZERO
			seat.view.overlay.set_cursor(seat.slot, show, pos, col, ch.shape, ch.size, ol)



func _seat_crosshair(slot: LocalPlayerSlot) -> Dictionary:
	var p: SavedProfile = slot.profile if slot != null else null
	if p != null:
		return {"shape": p.crosshair_shape, "custom": p.crosshair_custom, 
			"color": p.crosshair_color, "outline": p.crosshair_outline, "size": p.crosshair_size}
	return {"shape": GameConfig.crosshair_shape, "custom": GameConfig.crosshair_custom, 
		"color": GameConfig.crosshair_color, "outline": GameConfig.crosshair_outline, 
		"size": GameConfig.crosshair_size}



func _crosshair_color(ch: Dictionary, cue: Color) -> Color:
	return ch.color if bool(ch.get("custom", false)) else cue




func _p1_shared() -> bool:
	return _views.size() >= 1 and _views[0].owners.size() > 1




func _mp_ring_cursor(slot: LocalPlayerSlot, team_side: int, aim_z: float, 
		in_bounds: bool) -> Color:
	var c: Color = slot.color()
	if in_bounds and aim_z != 0.0 and signf(aim_z) != signf(float(team_side)):
		c = c.darkened(0.32)
	return c



func _p1_reticle_force(aim_z: float, in_bounds: bool) -> Color:
	if not _p1_shared():
		return Color(0, 0, 0, 0)
	return _mp_ring_cursor(LocalPlayers.primary(), player.team_side, aim_z, in_bounds)



func _ring_on(profile) -> bool:
	return profile.crosshair_ring if profile != null else GameConfig.crosshair_ring


func _tick_seat_ball_bubbles(active: bool) -> void :
	for seat in _seats:
		if seat.view == null or seat.view.overlay == null or seat.rig == null:
			continue
		seat.view.overlay.track_ball(seat.rig.camera, ball, 
			active and not hud.pause_is_open() and not LocalViews.is_collapsed(_views), 
			seat.body)






func _p1_overlay():




	if not _views.is_empty() and _views[0].overlay != null and _views[0].box != null\
	and not LocalViews.is_collapsed(_views):
		return _views[0].overlay
	return null

var _p1_hints: ControlHints = null



func _hints_for_p1() -> ControlHints:
	if _p1_hints != null and _views.size() >= 2 and not LocalViews.is_collapsed(_views):
		return _p1_hints
	return null

var _p1_cue: = Color.WHITE

func _draw_p1_cursor(on: bool, pos: Vector2) -> void :
	var ch: = _seat_crosshair(LocalPlayers.primary())


	var col: Color = _p1_cue if _p1_shared() else _crosshair_color(ch, _p1_cue)
	var ov = _p1_overlay()
	if ov == null:
		hud.set_aim_cursor(on, pos, col, ch.shape, ch.size, ch.outline)
		return
	hud.set_aim_cursor(false, Vector2.ZERO)




	var show: bool = aim_indicator.visible
	var vpos: Vector2 = camera_rig.camera.unproject_position(aim_indicator.global_position)\
	if show else Vector2.ZERO
	ov.set_cursor(LocalPlayers.primary(), show, vpos, col, ch.shape, ch.size, ch.outline)

func _draw_p1_sight(on: bool, aim_z: float, in_bounds: bool) -> void :





	if _p1_shared():

		_p1_cue = _mp_ring_cursor(LocalPlayers.primary(), player.team_side, aim_z, in_bounds)
	elif GameConfig.aim_color_cue and in_bounds:

		_p1_cue = Rules.half_color(aim_z)
	else:
		_p1_cue = Color.WHITE



	var ch: = _seat_crosshair(LocalPlayers.primary())
	var col: Color = _p1_cue if _p1_shared() else _crosshair_color(ch, _p1_cue)
	var ov = _p1_overlay()
	if ov == null:
		hud.set_crosshair_visible(on)
		hud.set_crosshair_side(aim_z, in_bounds)
		hud.set_sight_style(col, ch.shape, ch.size, ch.outline)
		return
	hud.set_crosshair_visible(false)
	ov.set_sight(on, col, ch.shape, ch.size, ch.outline)


func _is_local_human(body: Player) -> bool:
	return body != null and (body == player or _is_seated_body(body))

func _is_seated_body(body: Player) -> bool:
	for seat in _seats:
		if seat.body == body:
			return true
	return false







func _tick_reach_marker(phase: int) -> void :
	if reach_marker == null:
		return



	var live: = (phase == Phase.LIVE or phase == Phase.SERVE_PREP) and not _ball_dead
	reach_marker.drive(player, ball, 
		GameConfig.reach_marker and live and not _spectating)
	for seat in _seats:
		if seat.get("reach") != null:

			var want: bool = seat.slot.profile.reach_marker if seat.slot.profile != null\
			else GameConfig.reach_marker
			seat.reach.drive(seat.body, ball, want and live)









const BURNOUT_BEEP_EVERY: = 0.95



const BURNOUT_BEEP_SOUND: = false
var _burn_beep_t: = {}
var _burn_k: = 0.0
var _burn_pulse: = {}
var _burn_view_k: = {}

func _tick_burnout(delta: float) -> void :
	if embedded and not embedded_active:
		return
	var replaying: = _effective_phase() == Phase.REPLAY
	for p in _all_players:
		var b: = p as Player
		if not is_instance_valid(b):
			continue
		var own: = b == player or _seat_body(b)
		if b.stamina_locked and not replaying:
			var left: float = float(_burn_beep_t.get(b, 0.0)) - delta
			if left <= 0.0:
				left = BURNOUT_BEEP_EVERY
				if own:
					if BURNOUT_BEEP_SOUND:
						sfx.play_2d("burnout_beep", -4.0)
					_burn_pulse[b] = 1.0
				elif BURNOUT_BEEP_SOUND:
					sfx.play("burnout_beep", b.global_position + Vector3(0.0, 1.2, 0.0), -2.0)
			_burn_beep_t[b] = left
		else:
			_burn_beep_t.erase(b)
	for b in _burn_pulse.keys():
		_burn_pulse[b] = maxf(float(_burn_pulse[b]) - delta * 2.2, 0.0)







	var split: bool = _views.size() >= 2 and not LocalViews.is_collapsed(_views)
	var solo: bool = _seats.is_empty() and (_views.is_empty() or _views[0].owners.size() <= 1)
	var mine: bool = solo and is_instance_valid(player) and player.stamina_locked and not replaying\
	and not (embedded and not embedded_active)
	_burn_k = lerpf(_burn_k, 1.0 if mine else 0.0, 1.0 - exp( - (5.0 if mine else 3.0) * delta))
	hud.set_burnout(_burn_k if not split else 0.0, float(_burn_pulse.get(player, 0.0)))
	GameConfig.set_sfx_muffle(_burn_k if solo else 0.0)
	MusicManager.set_burn_muffle(_burn_k if solo else 0.0)
	for v in _views:
		if v.rig != null:
			v.rig.sprint_fov_enabled = v.owners.size() <= 1
		if v.overlay == null:
			continue
		var owner_body: Player = v.rig.player if v.rig != null else null
		var on: bool = split and v.owners.size() == 1 and is_instance_valid(owner_body)\
		and owner_body.stamina_locked and not replaying
		var vk: float = lerpf(float(_burn_view_k.get(v.index, 0.0)), 1.0 if on else 0.0, 
			1.0 - exp( - (5.0 if on else 3.0) * delta))
		_burn_view_k[v.index] = vk
		v.overlay.set_burnout(vk, float(_burn_pulse.get(owner_body, 0.0)))


func _seat_body(b: Player) -> bool:
	for seat in _seats:
		if seat.body == b:
			return true
	return false

func _exit_tree() -> void :
	if _practice != null:
		_practice.teardown()
	GameConfig.set_sfx_muffle(0.0)
	ProfileStore.hold_saves = false
	ModelRig.lod_views = []
	MusicManager.set_burn_muffle(0.0)




	if not _ach_no_rematch.is_empty() and not _pa_opted:
		for prof in _ach_no_rematch:
			Achievements.notify_for(prof, "no_rematch")
		Achievements._flush()
	_ach_no_rematch.clear()



	_keep_match_for_reports()
	Reports.match_replay = null
	Reports.match_shot = null


	if not embedded:
		GameConfig.stage_barefoot = false
		GameConfig.stage_reflections = true


	if _team_of_fn.is_valid() and Net.team_of == _team_of_fn:
		Net.team_of = Callable()




	if embedded:



		if _net_role != NetRole.OFFLINE and practice_court != null:
			Net.end_practice()
	elif _net_role != NetRole.OFFLINE and not _rematch_reload:
		Net.end_match()

func _unhandled_input(event: InputEvent) -> void :
	if embedded and not embedded_active:
		return



	_motion_collector().feed_motion(event)





	if _views.size() >= 2 and not _spectating and not hud.pause_is_open()\
	and not hud.chat_typing():
		if _route_split_camera(event):
			return



	if _spectating and _watch_cam != null and not hud.pause_is_open():


		if event.is_action_pressed("camera_toggle"):
			_watch_cam.cycle_mode()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return



		if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_H:
			_spec_ui = not _spec_ui
			hud.set_watch_ui_visible(_spec_ui)
			return
		if _watch_cam.handle_input(event):
			return



	if _net_role == NetRole.OFFLINE:
		return



	if not GameConfig.debug_menu:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key: = event as InputEventKey
		if not key.ctrl_pressed:
			return



		match key.keycode:
			KEY_1:
				Net.fake_latency_ms = 0
				Net.fake_jitter_ms = 0
			KEY_2:
				Net.fake_latency_ms = 40
				Net.fake_jitter_ms = 12
			KEY_3:
				Net.fake_latency_ms = 80
				Net.fake_jitter_ms = 25
			KEY_4:
				Net.fake_latency_ms = 150
				Net.fake_jitter_ms = 45

func _net_info_tick() -> void :
	if _net_role == NetRole.OFFLINE or _net_tick % 20 != 0:
		return



	if not GameConfig.debug_menu:
		hud.set_net_info("")
		return
	var rtt: = 0.0
	if _net_role == NetRole.CLIENT:
		rtt = Net.peer_rtt_ms(1)
	else:
		for peer_id in _peer_players:
			rtt = maxf(rtt, Net.peer_rtt_ms(peer_id))
	var lag_note: = "  ·  fake lag +%dms (±%dj)" % [Net.fake_latency_ms, Net.fake_jitter_ms]\
	if Net.fake_latency_ms > 0 or Net.fake_jitter_ms > 0 else ""



	var buf_note: = ""
	if GameConfig.debug_menu and _net_role == NetRole.CLIENT:
		buf_note = "  ·  buffer %.0fms (gap %.0f, jitter %.0f)"\
		%[interp_delay(), _snap_gap, _snap_jitter]


	var presets: = "  ·  ctrl+1-4 lag presets" if GameConfig.debug_menu else ""
	hud.set_net_info("online  ·  rtt %.0fms%s%s%s"\
	%[rtt, lag_note, buf_note, presets] + _pos_debug())


	if _net_log:
		_net_line_t += get_process_delta_time()
		if _net_line_t >= 1.0:
			_net_line_t = 0.0
			print("[net] ", _net_line(rtt))










var _net_line_t: = 0.0

func _net_line(rtt: float) -> String:
	if _net_role == NetRole.CLIENT:
		var mine: = player.global_position
		var host: = mine
		var idx: = _all_players.find(player)
		if not _np.is_empty() and idx >= 0:
			var st: = _pstate(_np.get("p", PackedFloat32Array()), idx)
			if not st.is_empty():
				host = Vector3(st[0], st[1], st[2])
		var ack: = int(_np.get("ack", {}).get(_local_pid(), 0))
		return ("CLIENT rtt=%.0f buf=%.0f gap=%.0f jit=%.0f err=%.3f lead=%.3f "
			+ "ackLag=%d me=(%.2f,%.2f) host=(%.2f,%.2f)") % [
			rtt, interp_delay(), _snap_gap, _snap_jitter, _pred.err.length(), 
			mine.distance_to(host), _in_chan.seq - ack, mine.x, mine.z, host.x, host.z]
	var out: = "HOST rtt=%.0f" % rtt
	for peer_id in _peer_players:
		var body: Player = _peer_players[peer_id]
		if body == null or not is_instance_valid(body):
			continue
		out += " | peer%d pos=(%.2f,%.2f) q=%d applied=%d starve=%d drop=%d trim=%d" % [
			peer_id, body.global_position.x, body.global_position.z, 
			(_peer_queue.get(peer_id, []) as Array).size(), 
			int(_peer_applied.get(peer_id, 0)), 
			int(_peer_starved.get(peer_id, 0)), 
			int(_peer_dropped.get(peer_id, 0)), 
			int(_peer_trimmed.get(peer_id, 0))]
	out += " | touch ok=%d reach=%d kind=%d dead=%d expired=%d" % [
		_lag_reject.ok, _lag_reject.reach, _lag_reject.kind, 
		_lag_reject.dead, _lag_reject.expired]
	for k in _lag_reject:
		_lag_reject[k] = 0
	return out









func _awaiting_first_intro() -> bool:
	if _cover_t > REVEAL_TIMEOUT_S or _np.is_empty() or Net.practice:
		return false
	return _effective_phase() == Phase.DEAD\
	and int(_np.get("s1", 0)) == 0 and int(_np.get("s2", 0)) == 0\
	and int(_np.get("w1", 0)) == 0 and int(_np.get("w2", 0)) == 0\
	and int(_np.get("sn", 1)) <= 1







func _pos_debug() -> String:



	if not GameConfig.debug_menu:
		return ""
	if _net_role == NetRole.CLIENT:
		var mine: = player.global_position
		var host: = mine
		var idx: = _all_players.find(player)
		if not _np.is_empty() and idx >= 0:
			var st: = _pstate(_np.get("p", PackedFloat32Array()), idx)
			if not st.is_empty():
				host = Vector3(st[0], st[1], st[2])




		return """
ME (%.2f, %.2f)  ·  host (%.2f, %.2f)  ·  ERR %.2fm  ·  lead %.2fm""" %[mine.x, mine.z, host.x, host.z, _pred.err.length(), 
			mine.distance_to(host)]

	var out: = ""
	for peer_id in _peer_players:
		var body: Player = _peer_players[peer_id]
		if body == null or not is_instance_valid(body):
			continue
		out += """
CLIENT %d (%.2f, %.2f)  ·  ack %d  ·  q %d  ·  starve %d  ·  drop %d""" %[peer_id, body.global_position.x, body.global_position.z, 
			int(_peer_applied.get(peer_id, 0)), 
			(_peer_queue.get(peer_id, []) as Array).size(), 
			int(_peer_starved.get(peer_id, 0)), 
			int(_peer_dropped.get(peer_id, 0))]
	return out

func _on_session_ended(reason: String) -> void :
	if embedded:


		_go_menu()
		return














	var _real_survivors: = Net.last_players.keys()\
	.filter( func(id): return int(id) != 1).size()






	QuickPlay.qlog("match session ended: %s over=%s home=%s" % [reason, str(_match_over), str(Net.home_party)])
	if reason == "host left" and _match_over and not Net.home_party.is_empty()\
	and not bool(Net.home_party.get("room", false)):
		UiWipe.wipe(get_tree(), func():
			_go_menu())
		return



	if reason == PA_NO_REMATCH or (reason == "host left" and _match_over and _quick()):
		GameConfig.lobby_notice = PA_NO_REMATCH if reason == PA_NO_REMATCH\
		else "the host left the match"
		UiWipe.wipe(get_tree(), func():
			_go_menu())
		return
	if reason == "host left" and _real_survivors >= 1:
		_migrating = true



		MIGRATION_COVER.hold(get_tree())
		var surv: = Net.last_players.keys().filter( func(id): return int(id) != 1)
		surv.sort()
		var successor_sid: = int((Net.last_players[surv[0]] as Dictionary)\
		.get("sid", 0))
		(load("res://game/net/migrate.gd") as GDScript).begin(get_tree(), {
			"survivors": Net.last_players, 
			"my_id": _my_peer_id, 
			"my_name": Net.my_name, 
			"token": Net.session_token, 
			"steam": Net.steam_transport_available() and successor_sid != 0, 
			"roster": _live_cast(), 
			"carry": {"s1": int(_scores[1]), "s2": int(_scores[-1]), 
				"w1": int(_set_wins[1]), "w2": int(_set_wins[-1]), 
				"n": _set_number}, 
			"quick": _quick(), 

			"over": _match_over, 
			"solo": _real_survivors == 1, 
			"room": Net.custom_lobby, 
			"stage": GameConfig.stage, 
			"size": GameConfig.team_size, 
			"seed": GameConfig.match_seed, 
		})
		return

	UiWipe.wipe(get_tree(), func():
		_go_menu())















var _built_stage: = ""
var _built_size: = 0

func _cfg_stage() -> String:
	return _built_stage if embedded and _built_stage != "" else GameConfig.stage

func _cfg_size() -> int:
	return _built_size if embedded and _built_size > 0 else GameConfig.team_size



func _quick() -> bool:
	return GameConfig.quick_match and not _practice_dress

func _teamwear(cfg: CharacterConfig, home: bool) -> CharacterConfig:
	if DressCode.casual(_cfg_stage(), DressCode.rule_now()):
		return cfg
	return GameConfig.dress_in_team_gear(cfg, home)

func _stage_outfit(cfg: CharacterConfig, kit: Array, outfit: = "") -> Array:



	if _practice_dress:
		return CharacterConfig.outfit_fit(cfg, outfit)

	if not DressCode.casual(_cfg_stage(), DressCode.rule_now()):
		return [cfg, kit]








	var look: = cfg.gym_look()
	if DressCode.pinny(_cfg_stage(), DressCode.rule_now()):
		look.wear_pinny = true




		look.pinny_color = kit[0]
		look.pinny_accent = TeamKits.number_ink(kit[0])
	if _cfg_size() <= 1:





		return [look, cfg.gym_kit()]
	return [look, look.gym_kit()]

func _spawn_teams() -> void :


	GameConfig.new_match_seed()
	var n: = GameConfig.team_size
	var my_side: = 1 if GameConfig.local_side >= 0 else -1
	player.team_side = my_side
	_slots[player] = 0
	_names[player] = LocalPlayers.primary_name()
	_seat_owner[player] = _local_pid()
	player.global_position = _formation_spot(0, n, my_side)




	var used: = {my_side: 1, - my_side: 0}
	var plan: = _plan_local_guests(n, used)
	var humans: = {1: int(used[1]), -1: int(used[-1])}


	var cpus: Dictionary = GameConfig.local_cpus



	GameConfig.local_kits = _pick_local_kits(my_side, plan, humans, n, cpus)
	var own_fit: = _stage_outfit(GameConfig.character, GameConfig.side_kit(my_side), 
		GameConfig.menu_outfit)
	player.set_character(own_fit[0], own_fit[1])
	_all_players = [player]
	_reset_cpu_names()
	_seat_local_guests(n, plan)
	for side in [my_side, - my_side]:
		for i in range(int(humans[side]), n):
			var cc: = CpuSlots.lookup(cpus, side, i - int(humans[side]))
			var bot: = _spawn_bot(i, n, side, _team_color(side, i), cc)
			_names[bot] = ("%s (CPU)" % String(cc.name)) if not cc.is_empty()\
			else _next_cpu_name()
			_all_players.append(bot)
	_mark_local_captains()







var _seats: Array = []
var _views: Array = []
var _reflector: FloorReflector = null


const CALLOUT_ACTIONS: = Player.QUICK_CHAT_ACTIONS
var _p1_callout: = DeviceInput.new()
var _callout_polls: = {}



func _guest_slots() -> Array:
	if _net_role != NetRole.OFFLINE:
		return []
	var out: Array = []
	for s in LocalPlayers.slots:
		if s.index > 0 and s.connected:
			out.append(s)
	return out





func _plan_local_guests(n: int, used: Dictionary) -> Array:
	var plan: Array = []
	for slot in _guest_slots():
		var side: int = slot.team_side if slot.team_side != 0 else player.team_side
		if int(used[side]) >= n:
			side = - side
		if int(used[side]) >= n:
			continue
		plan.append([slot, side, int(used[side])])
		used[side] = int(used[side]) + 1
	return plan




func _pick_local_kits(my_side: int, plan: Array, humans: Dictionary, n: int, 
		cpus: Dictionary) -> Dictionary:
	var seats: Array = [{"peer": 1, "ls": 0, "side": my_side, 
		"cfg": GameConfig.character.to_dict() if GameConfig.character != null else {}}]
	for p in plan:
		var slot: LocalPlayerSlot = p[0]
		seats.append({"peer": 1, "ls": slot.index, "side": int(p[1]), "slot": int(p[2]), 
			"cfg": slot.profile.character if slot.profile != null else {}})
	for side in [1, -1]:
		for i in range(int(humans[side]), n):
			var cc: = CpuSlots.lookup(cpus, side, i - int(humans[side]))
			seats.append({"peer": 0, "ls": 0, "side": side, "slot": i, 
				"cfg": cc.cfg if not cc.is_empty() else {}})
	var res: = TeamKits.pick_roster(seats, Net.captains)
	_local_caps = res.caps
	return res.kits



var _local_caps: = {}

func _mark_local_captains() -> void :


	var humans: = {1: 0, -1: 0}
	for p in _all_players:
		var hb: = p as Player
		if not hb.is_bot and humans.has(hb.team_side):
			humans[hb.team_side] = int(humans[hb.team_side]) + 1
	for p in _all_players:
		var b: = p as Player
		var key: = ""
		if b == player:
			key = TeamKits.seat_key(1, 0)
		elif b.is_bot:
			key = TeamKits.cpu_key(b.team_side, 
				int(_slots.get(b, 0)) - int(humans.get(b.team_side, 0)))
		else:
			for seat in _seats:
				if seat.body == b:
					key = TeamKits.seat_key(1, int(seat.slot.index))
		b.is_captain = key != "" and String(_local_caps.get(b.team_side, "")) == key



func _seat_local_guests(n: int, plan: Array) -> void :
	for p in plan:
		var slot: LocalPlayerSlot = p[0]
		var side: int = p[1]
		var idx: int = p[2]
		var body: Player = PLAYER_SCENE.instantiate()
		add_child(body)
		body.team_side = side
		body.global_position = _formation_spot(idx, n, side)
		body.face_net()
		body.set_team_color(_team_color(side, idx))
		var look: CharacterConfig = CharacterConfig.from_dict(slot.profile.character)\
		if slot.profile != null and not slot.profile.character.is_empty()\
		else CharacterConfig.random()
		look.level = Progression.shown_level(slot.profile) if slot.profile != null else 0
		var fit: = _stage_outfit(look, GameConfig.side_kit(side))
		body.set_character(fit[0], fit[1])
		body.set_tag_color(_team_color(side, idx))
		body.charge_ui_enabled = true
		body.indicator_enabled = true
		_slots[body] = idx
		_names[body] = slot.display_name()
		_seat_owner[body] = _pid_for(_local_pid(), slot.index)
		_all_players.append(body)
		var col: InputCollector = slot.make_collector()
		col.aim_min = _input_collector.aim_min
		col.aim_max = _input_collector.aim_max
		col.profile = slot.profile
		Haptics.wire(body, slot.device, slot.profile.rumble if slot.profile != null else true)
		_seats.append({"slot": slot, "body": body, "collector": col, 
			"rig": null, "aim": null, "view": null, "cue": Color.WHITE, 
			"profile_ref": slot.profile, "title_ref": _title_sig(slot)})






func _add_online_seat(body: Player, ls: int) -> void :
	if ls < 0 or ls >= LocalPlayers.slots.size():
		return
	var slot: LocalPlayerSlot = LocalPlayers.slots[ls]
	slot.team_side = body.team_side
	body.charge_ui_enabled = true
	body.indicator_enabled = true
	body.set_ring_tint(slot.color())
	var col: InputCollector = slot.make_collector()
	col.aim_min = _input_collector.aim_min
	col.aim_max = _input_collector.aim_max
	col.profile = slot.profile
	Haptics.wire(body, slot.device, slot.profile.rumble if slot.profile != null else true)



	var chan = null
	var pred = null
	if _net_role == NetRole.CLIENT:
		chan = NetSync.InputChannel.new()
		chan.gen = GameConfig.match_seed


		pred = NetSync.Predictor.new()
		body.net_puppet = false
		body.sim_authority = false
	_seats.append({"slot": slot, "body": body, "collector": col, "ls": ls, "chan": chan, 
		"pred": pred, "rig": null, "aim": null, "view": null, "cue": Color.WHITE})



func _build_local_views() -> void :
	if _seats.is_empty():
		return






	_refresh_local_input()


	player.set_ring_tint(LocalPlayers.primary().color())
	for seat in _seats:
		seat.body.set_ring_tint(seat.slot.color())
		seat.body.indicator_enabled = true


	LocalPlayers.primary().team_side = player.team_side
	for seat in _seats:
		seat.slot.team_side = seat.body.team_side
	var slots: Array = [LocalPlayers.primary()]
	for seat in _seats:
		slots.append(seat.slot)
	LocalViews.two_always_split = _practice_dress
	_views = LocalViews.build(self, slots, camera_rig)



	if hud != null and hud.chat != null:
		hud.chat.set_compact(_views.size() > 1)


	if _views.size() == 1 and _views[0].owners.size() <= 1:
		return


	if _reflector != null:
		_reflector.visible = false





	if _views[0].overlay != null and _views[0].owners.size() <= 1:
		_p1_hints = ControlHints.new()
		_p1_hints.bind(DeviceInput.MERGED, LocalPlayers.primary().profile)
		_p1_hints.ui_scale = 1.0 / maxf(_views[0].overlay._scale, 0.001)
		_views[0].overlay.add_child(_p1_hints)


	LocalViews.privatize(aim_indicator, 0)
	LocalViews.privatize(reach_marker, 0)
	LocalViews.privatize(barred_marker, 0)
	LocalViews.privatize(_toss_preview, 0)





	if player.indicator_ring != null:
		LocalViews.privatize(player.indicator_ring, 0)
	if player.charge_ui != null:
		LocalViews.privatize(player.charge_ui, 0)



	for seat in _seats:
		var vi: = _view_index_for(seat.slot)
		if vi < 0:
			continue
		var view = _views[vi]
		seat["rig"] = view.rig
		seat["view"] = view


		var aim: = AimMarker.new()
		add_child(aim)
		aim.set_rig(view.rig)
		LocalViews.privatize(aim, vi)
		seat["aim"] = aim
		_wire_seat_presentation(seat, vi)


	for vi in range(_views.size()):
		_setup_view_camera(_views[vi])



	player.set_seat_badge("P1", LocalPlayers.primary().color(), true)
	for seat in _seats:
		seat.body.set_seat_badge("P%d" % (seat.slot.index + 1), 
			seat.slot.color(), true)
	_badges_shown = true
	_p1_wired_body = player
	_ensure_team_poller()








var _p1_wired_body: Player = null



var _p1_haptic_body: Player = null

func _sync_p1_split_body() -> void :
	var mine: Player = null if _spectating else player
	if mine != _p1_haptic_body:
		if _p1_haptic_body != null and is_instance_valid(_p1_haptic_body):
			Haptics.unwire(_p1_haptic_body)
		if mine != null:
			Haptics.wire(mine)
		_p1_haptic_body = mine
	if _views.is_empty() or _views[0].box == null:
		return
	var want: Player = mine
	if want == _p1_wired_body:
		return
	var old: = _p1_wired_body
	if is_instance_valid(old):
		_strip_local_wiring(old)
	_p1_wired_body = want
	if want == null or not is_instance_valid(want):
		return
	var slot: = LocalPlayers.primary()
	slot.team_side = want.team_side


	if _views_need_rebuild():
		_rebuild_local_views()
		return
	_wire_local_body(want, slot, 0, "P1")


	var vi: = _view_index_for(slot)
	if vi >= 0:
		_setup_view_camera(_views[vi])




func _wire_local_body(body: Player, slot: LocalPlayerSlot, view_index: int, 
		badge: String) -> void :
	body.set_ring_tint(slot.color())
	body.indicator_enabled = true
	if body.indicator_ring != null:
		LocalViews.privatize(body.indicator_ring, view_index)
	if body.charge_ui != null:
		LocalViews.privatize(body.charge_ui, view_index)
	body.set_seat_badge(badge, slot.color(), _badges_shown)


func _strip_local_wiring(body: Player) -> void :
	body.set_ring_tint(Color(0, 0, 0, 0))
	if body.indicator_ring != null:
		LocalViews.unprivatize(body.indicator_ring)
	if body.charge_ui != null:
		LocalViews.unprivatize(body.charge_ui)
	body.set_seat_badge("", Color.WHITE, false)



func _wire_seat_body_signals(seat: Dictionary) -> void :
	_unwire_seat_body_signals(seat)
	var body: Player = seat.body
	if not is_instance_valid(body):
		return
	var oor: = func(): (seat.cue_fn as Callable).call("reach_miss", -8.0)
	var knock: = func(_pos: Vector3, strength: float):
		var r: CameraRig = seat.get("rig")
		if r != null and is_instance_valid(r):
			r.shake(0.22 * strength)
	body.out_of_range.connect(oor)
	body.knock_started.connect(knock)
	seat["body_sigs"] = [body, oor, knock]

func _unwire_seat_body_signals(seat: Dictionary) -> void :
	var sigs: Array = seat.get("body_sigs", [])
	if sigs.size() == 3 and is_instance_valid(sigs[0]):
		var b: Player = sigs[0]
		if b.out_of_range.is_connected(sigs[1]):
			b.out_of_range.disconnect(sigs[1])
		if b.knock_started.is_connected(sigs[2]):
			b.knock_started.disconnect(sigs[2])
	seat.erase("body_sigs")







func _seat_ls(seat: Dictionary) -> int:
	return int(seat.get("ls", seat.slot.index))

func _seat_pid(seat: Dictionary) -> int:
	return _pid_for(_local_pid(), _seat_ls(seat))


func _local_seat_for_pid(pid: int) -> Dictionary:
	if pid >= 0 or _pid_owner(pid) != _local_pid():
		return {}
	var ls: = _pid_ls(pid)
	for seat in _seats:
		if _seat_ls(seat) == ls:
			return seat
	return {}

func _rebind_seat(seat: Dictionary, body: Player) -> void :
	var old: Player = seat.body
	if old == body:
		return
	if is_instance_valid(old):
		if _net_role == NetRole.CLIENT:
			old.net_puppet = true
		_strip_local_wiring(old)
		_unwire_seat_body_signals(seat)
		Haptics.unwire(old)
		old.set_disconnected(false)
	seat["body"] = body
	var slot: LocalPlayerSlot = seat.slot
	slot.team_side = body.team_side
	body.is_bot = false
	body.charge_ui_enabled = true
	body.indicator_enabled = true


	body.net_puppet = false
	if _net_role == NetRole.CLIENT:
		body.sim_authority = false
		body.velocity = Vector3.ZERO
		body.reset_physics_interpolation()
		if seat.get("pred") != null:
			seat.pred.reset()
	if _net_role != NetRole.CLIENT:
		_bots.erase(body)
	Haptics.wire(body, slot.device, slot.profile.rumble if slot.profile != null else true)
	_wire_seat_body_signals(seat)


	if _views_need_rebuild():
		_rebuild_local_views()
		return
	var vi: = _view_index_for(slot)
	if vi >= 0:
		_wire_local_body(body, slot, vi, "P%d" % (slot.index + 1))
		_setup_view_camera(_views[vi])






var _team_polls: = {}
var _team_poller: Node = null

class _AlwaysTick extends Node:
	var fn: = Callable()
	func _ready() -> void :
		process_mode = Node.PROCESS_MODE_ALWAYS
	func _process(delta: float) -> void :
		if fn.is_valid():
			fn.call(delta)

func _ensure_team_poller() -> void :
	if _team_poller != null or _seats.is_empty():
		return
	var t: = _AlwaysTick.new()
	t.name = "CouchTeamPoller"
	t.fn = _poll_couch_team_moves
	add_child(t)
	_team_poller = t

func _poll_couch_team_moves(_delta: float) -> void :
	var open: bool = hud != null and hud.teams_open()
	for seat in _seats:
		var slot: LocalPlayerSlot = seat.slot
		if not slot.connected or bool(seat.get("benched", false)):
			continue
		var r: DeviceInput = _team_polls.get(slot.device)
		if r == null:
			r = DeviceInput.new(slot.device)
			_team_polls[slot.device] = r
		r.device = slot.device


		r.poll(["ui_left", "ui_right"])
		if not open:
			continue
		var want: = 0
		if r.just_pressed("ui_left"):
			want = 1
		elif r.just_pressed("ui_right"):
			want = -1
		if want != 0:
			_request_couch_seat(seat, want)




func _request_couch_seat(seat: Dictionary, team: int) -> void :
	var pid: = _seat_pid(seat)
	var tag: = "P%d" % (seat.slot.index + 1)
	var no: = _seat_refusal(pid, team)
	if no == "there":
		return
	if no != "":
		var text: = _seat_no_text(no, team, int(_team_played.get(pid, 0)))
		if text != "":
			hud.notice("%s: %s" % [tag, text])
		return
	UiStyle.sfx("tick")
	if _net_role == NetRole.CLIENT:
		Net.send_up("seat", {"s": team, "ls": _seat_ls(seat)})
		var phase: = _effective_phase()
		if phase != Phase.DEAD and phase != Phase.SERVE_PREP:
			hud.notice("%s %s" % [tag, _seat_queued_text(team)], SEAT_NOTE_SECS)
		return
	_join_queue[pid] = team




	var fresh: bool = bool(seat.get("fresh", false)) and get_tree().paused\
	and not _replay_pending and _phase != Phase.REPLAY
	if _seat_boundary_safe() or fresh:
		_apply_seat_requests()
	else:
		hud.notice("%s %s" % [tag, _seat_queued_text(team)], SEAT_NOTE_SECS)



func _views_need_rebuild() -> bool:
	if _views.is_empty() or _seats.is_empty():
		return false
	if not _spectating and player != null:
		LocalPlayers.primary().team_side = player.team_side
	var slots: Array = [LocalPlayers.primary()]
	for seat in _seats:
		if is_instance_valid(seat.body):
			seat.slot.team_side = seat.body.team_side
		slots.append(seat.slot)
	var want: = LocalViews.view_groups(slots)
	if want.size() != _views.size():
		return true
	for i in want.size():
		var have: Array = _views[i].owners
		if (want[i] as Array).size() != have.size():
			return true
		for s in want[i]:
			if not s in have:
				return true
	return false



func _rebuild_local_views() -> void :
	_teardown_local_views()
	_build_local_views()

func _teardown_local_views() -> void :
	if _p1_hints != null and is_instance_valid(_p1_hints):
		_p1_hints.queue_free()
	_p1_hints = null
	for seat in _seats:
		for key in ["aim", "reach", "toss", "barred", "hints"]:
			var n = seat.get(key)
			if n != null and is_instance_valid(n):
				n.queue_free()
			seat[key] = null
		seat["rig"] = null
		seat["view"] = null
		if is_instance_valid(seat.body):
			_strip_local_wiring(seat.body)
		_unwire_seat_body_signals(seat)
	for n in [aim_indicator, reach_marker, barred_marker, _toss_preview]:
		LocalViews.unprivatize(n)
	if is_instance_valid(_p1_wired_body):
		_strip_local_wiring(_p1_wired_body)
	_p1_wired_body = null
	ball.set_hint_view_masks(0, 0)
	LocalViews.teardown(self, _views, camera_rig)
	_views = []


func _route_split_camera(event: InputEvent) -> bool:
	for v in _views:
		var r: CameraRig = v.rig
		if r == null or not r._owns_event(event):
			continue

		if r._matches(event, "camera_toggle"):
			r.apply_camera_toggle()
			get_viewport().set_input_as_handled()
			return true
		if r.apply_direct_camera(event):
			get_viewport().set_input_as_handled()
			return true
		if r._matches(event, "camera_zoom"):
			r.apply_zoom_preset()
			get_viewport().set_input_as_handled()
			return true
		if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			var mb: = event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				r.apply_wheel(-1.0)
				get_viewport().set_input_as_handled()
				return true
			if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				r.apply_wheel(1.0)
				get_viewport().set_input_as_handled()
				return true



		if event is InputEventMouseMotion\
		and (r.mode == CameraRig.Mode.ACTION or r.mode == CameraRig.Mode.FIRST_PERSON):
			r.apply_mouse_look((event as InputEventMouseMotion).relative)
			return false
		return false
	return false


func _body_for_slot(slot: LocalPlayerSlot) -> Player:
	if slot == LocalPlayers.primary():
		return player
	for seat in _seats:
		if seat.slot == slot:
			return seat.body
	return null


func _view_index_for(slot: LocalPlayerSlot) -> int:
	for v in _views:
		if v.owns(slot):
			return v.index
	return -1



func _setup_view_camera(view) -> void :
	var rig: CameraRig = view.rig
	rig.ball = ball
	rig.court_span = _half_l
	var lead: = _body_for_slot(view.owners[0])
	if lead == null:
		return
	rig.player = lead
	rig.home_side = float(lead.team_side)


	rig.camera_input_external = true
	if view.owners.size() > 1:




		rig.profile = null
		rig.mode = CameraRig.Mode.DYNAMIC
		rig.shared = true


		var group: Array = []
		for o in view.owners:
			var b: = _body_for_slot(o)
			if b != null:
				group.append(b)
		rig.frame_group = group
	else:
		rig.profile = view.owners[0].profile
		rig.frame_group = []
	rig.face_net()







func _wire_seat_presentation(seat: Dictionary, view_index: int) -> void :
	var body: Player = seat.body
	var rig: CameraRig = seat.rig



	if body.indicator_ring != null:
		LocalViews.privatize(body.indicator_ring, view_index)
	if body.charge_ui != null:
		LocalViews.privatize(body.charge_ui, view_index)
	var reach: = ReachMarker.new()
	add_child(reach)
	reach.setup(rig.camera)
	LocalViews.privatize(reach, view_index)
	seat["reach"] = reach


	var cue: = func(bank: String, volume_db: float, pitch: = 1.0):
		if _phase != Phase.REPLAY and is_instance_valid(seat.body):
			sfx.play(bank, (seat.body as Player).global_position, volume_db, pitch)
	seat["cue_fn"] = cue
	reach.entered_reach.connect( func(): cue.call("reach_in", -8.0))
	reach.action_queued.connect( func(): cue.call("reach_queue", -2.0))
	reach.took.connect( func(): cue.call("reach_take", -4.0, 1.15))
	reach.missed.connect( func(): cue.call("reach_miss", -8.0))
	reach.early.connect( func(): cue.call("reach_miss", -8.0))
	_wire_seat_body_signals(seat)





	var shared: bool = seat.view != null and seat.view.owners.size() > 1
	if seat.view != null and seat.view.overlay != null and not shared:
		var hints: = ControlHints.new()
		hints.bind(seat.slot.device, seat.slot.profile)
		hints.ui_scale = 1.0 / maxf(seat.view.overlay._scale, 0.001)
		seat.view.overlay.add_child(hints)
		seat["hints"] = hints

	if not seat.has("dive_cb"):
		var dive_cb: = func():
			if _phase == Phase.REPLAY or not is_instance_valid(seat.body):
				return
			(seat.cue_fn as Callable).call("reach_miss", -8.0)
			(seat.body as Player).dive_denied()
			var h = seat.get("hints")
			if h != null and is_instance_valid(h):
				h.dive_denied()
		seat.collector.dive_denied.connect(dive_cb)
		seat["dive_cb"] = dive_cb
	var toss: = TrajectoryPreview.new()
	add_child(toss)
	LocalViews.privatize(toss, view_index)
	seat["toss"] = toss
	var barred: = barred_marker.duplicate() as Node3D
	barred.visible = false
	add_child(barred)
	LocalViews.privatize(barred, view_index)
	seat["barred"] = barred


	if not seat.has("benched"):
		seat["lost"] = 0.0
		seat["benched"] = false
	if not LocalPlayers.slot_connection_changed.is_connected(_on_seat_connection):
		LocalPlayers.slot_connection_changed.connect(_on_seat_connection)


	if not LocalPlayers.roster_changed.is_connected(_refresh_local_input):
		LocalPlayers.roster_changed.connect(_refresh_local_input)

	if not LocalPlayers.devices_changed.is_connected(_refresh_local_input):
		LocalPlayers.devices_changed.connect(_refresh_local_input)





const BENCH_AFTER: = 20.0

func _seat_for_slot(slot: LocalPlayerSlot) -> Dictionary:
	for seat in _seats:
		if seat.slot == slot:
			return seat
	return {}



func _refresh_local_input() -> void :
	if LocalPlayers.has_guests():
		_input_collector.set_device(LocalPlayers.primary_device)
	else:
		_input_collector.set_device(DeviceInput.MERGED)


	_input_collector.set_exclude_pads(LocalPlayers.p1_exclude_pads())
	_input_collector.set_exclude_kbm(LocalPlayers.kbm_taken())

func _on_seat_connection(slot: LocalPlayerSlot, connected: bool) -> void :
	_refresh_local_input()
	var seat: = _seat_for_slot(slot)
	if seat.is_empty():
		return
	if not connected:
		seat["lost"] = 0.0


		if is_instance_valid(seat.body):
			seat.body.set_disconnected(true, "P%d ✕" % (slot.index + 1), slot.color())
		return
	seat["lost"] = 0.0
	if bool(seat.benched):
		_unbench_seat(seat)
	if is_instance_valid(seat.body):
		seat.body.set_disconnected(false)

func _tick_seat_connections(delta: float) -> void :
	for seat in _seats:
		if seat.slot.connected or bool(seat.get("benched", false)):
			continue
		seat["lost"] = float(seat.get("lost", 0.0)) + delta
		if float(seat.lost) >= BENCH_AFTER:
			_bench_seat(seat)

func _bench_seat(seat: Dictionary) -> void :
	var body: Player = seat.body
	seat["benched"] = true
	var brain: = TeamBot.new()
	brain.configure(_half_w, _half_l, int(_slots.get(body, 0)), GameConfig.team_size)
	brain.apply_difficulty(GameConfig.difficulty)
	_bots[body] = brain
	body.is_bot = true
	body.charge_ui_enabled = false













func dropin_room() -> int:
	var n: = 0
	for b in _all_players:
		var body: Player = b
		if body.is_bot and _seat_for_body(body).is_empty():
			n += 1
	return n

func _title_sig(slot: LocalPlayerSlot) -> String:
	return str(slot.profile.title) if slot != null and slot.profile != null else ""

func _seat_for_body(body: Player) -> Dictionary:
	for seat in _seats:
		if seat.body == body:
			return seat
	return {}

func _on_couch_changed() -> void :
	if apply_couch_roster() > 0:
		hud.open_teams()


func apply_couch_roster() -> int:
	if _net_role != NetRole.OFFLINE:
		return 0

	for seat in _seats.duplicate():
		if not LocalPlayers.slots.has(seat.slot):
			_drop_out_seat(seat)


	for seat in _seats:
		if is_instance_valid(seat.body):
			_seat_owner[seat.body] = _seat_pid(seat)


	for seat in _seats:
		if seat.get("profile_ref") != seat.slot.profile or seat.get("title_ref", "") != _title_sig(seat.slot):
			_redress_seat(seat)

	var joined: = 0
	for slot in LocalPlayers.slots:
		if slot.index == 0 or not slot.connected or not _seat_for_slot(slot).is_empty():
			continue
		if _drop_in_seat(slot):
			joined += 1


	_rebuild_local_views()
	_refresh_local_input()



	_update_controls(_phase == Phase.SERVE_PREP and _server == player)



	for seat in _seats:
		var rig: CameraRig = seat.get("rig")
		if rig != null and is_instance_valid(rig):
			rig._process(2.0)
	if _seats.is_empty() and hud != null and hud.chat != null:
		hud.chat.set_compact(false)

	hud.set_teams_available( not _seats.is_empty() and not GameConfig.ranked_match)
	return joined



func _drop_in_seat(slot: LocalPlayerSlot) -> bool:
	var counts: = {1: 0, -1: 0}
	for b in _all_players:
		var c: Player = b
		if c.is_bot and _seat_for_body(c).is_empty():
			counts[int(c.team_side)] = int(counts.get(int(c.team_side), 0)) + 1
	var mine: = int(player.team_side) if player != null else 1
	var side: = mine if int(counts.get(mine, 0)) >= int(counts.get( - mine, 0)) else - mine
	if int(counts.get(side, 0)) <= 0:
		return false
	var body: Player = null
	for b in _all_players:
		var c: Player = b
		if c.team_side == side and c.is_bot and _seat_for_body(c).is_empty():
			body = c
			break
	if body == null:
		return false
	_bots.erase(body)
	_cpu_diff.erase(body)
	_gone_bodies.erase(body)
	body.is_bot = false
	body.charge_ui_enabled = true
	body.indicator_enabled = true
	if not _stats.has(body):
		_stats[body] = {"pts": 0, "spk": 0, "blk": 0, "rcv": 0, "set": 0, "ast": 0}
	var col: InputCollector = slot.make_collector()
	col.aim_min = _input_collector.aim_min
	col.aim_max = _input_collector.aim_max
	col.profile = slot.profile
	var seat: = {"slot": slot, "body": body, "collector": col, 
		"rig": null, "aim": null, "view": null, "cue": Color.WHITE, 
		"profile_ref": slot.profile, "title_ref": _title_sig(slot), "fresh": true}
	_seats.append(seat)
	slot.team_side = body.team_side
	_seat_owner[body] = _seat_pid(seat)
	_dress_seat_body(seat)
	Haptics.wire(body, slot.device, slot.profile.rumble if slot.profile != null else true)
	var team: = _team_identity(body.team_side)
	_note_team(_seat_pid(seat), team)
	_announce_seat(slot.display_name(), team, body)
	return true


func _dress_seat_body(seat: Dictionary) -> void :
	var slot: LocalPlayerSlot = seat.slot
	var body: Player = seat.body
	var look: CharacterConfig = CharacterConfig.from_dict(slot.profile.character)\
	if slot.profile != null and not slot.profile.character.is_empty()\
	else CharacterConfig.random()
	look.level = Progression.shown_level(slot.profile) if slot.profile != null else 0
	var fit: = _stage_outfit(look, _team_kit_for(body.team_side))
	body.set_character(fit[0], fit[1])
	_names[body] = slot.display_name()
	body.set_display_name(_names[body])
	body.set_dev_tag(DevBadge.Tier.NONE)



func _redress_seat(seat: Dictionary) -> void :
	var slot: LocalPlayerSlot = seat.slot
	seat["profile_ref"] = slot.profile
	seat["title_ref"] = _title_sig(slot)
	_dress_seat_body(seat)
	var col: InputCollector = seat.collector
	if col != null:
		col.profile = slot.profile
	LocalPlayers.refresh_bindings(slot)
	Haptics.wire(seat.body, slot.device, slot.profile.rumble if slot.profile != null else true)



func _drop_out_seat(seat: Dictionary) -> void :
	var body: Player = seat.body
	_seats.erase(seat)
	if not is_instance_valid(body):
		return
	_strip_local_wiring(body)
	_unwire_seat_body_signals(seat)
	Haptics.unwire(body)
	body.set_disconnected(false)
	body.set_seat_badge("", Color.WHITE, false)
	var brain: = TeamBot.new()
	brain.configure(_half_w, _half_l, int(_slots.get(body, 0)), GameConfig.team_size)
	brain.apply_difficulty(GameConfig.difficulty)
	_bots[body] = brain
	_cpu_diff[body] = GameConfig.difficulty
	body.is_bot = true
	body.charge_ui_enabled = false


	var gone: = String(_names.get(body, "player"))
	_names[body] = _cpu_tagged(gone)
	body.set_display_name(_names[body])
	_seat_owner.erase(body)
	hud.notice("%s dropped out" % gone)

func _unbench_seat(seat: Dictionary) -> void :
	var body: Player = seat.body
	seat["benched"] = false
	_bots.erase(body)
	body.is_bot = false
	body.charge_ui_enabled = true







func _one_picture() -> bool:
	return camera_rig.cinematic or _phase == Phase.REPLAY\
	or _phase == Phase.WIN or _phase == Phase.STATS

func _sync_split_views() -> void :
	if _views.size() < 2:
		return
	var one_picture: = _one_picture()
	LocalViews.set_collapsed(_views, one_picture)
	for seat in _seats:
		var rig: CameraRig = seat.rig
		if rig == null:
			continue

		rig.input_frozen = camera_rig.input_frozen
		rig.watched = camera_rig.watched
		if one_picture and seat.aim != null:
			seat.aim.visible = false




func _tick_seats(delta: float) -> void :
	for seat in _seats:
		var body: Player = seat.body
		if not is_instance_valid(body):
			continue
		var slot: LocalPlayerSlot = seat.slot
		if bool(seat.get("benched", false)):
			continue
		var rig: CameraRig = seat.rig if seat.rig != null else camera_rig
		var gin: = PlayerInput.new()
		if slot.connected and not hud.pause_is_open() and not hud.chat_typing():
			gin = _gate_cinematics(seat.collector.collect(rig, body), body)
		_tick_inputs[body] = gin
		body.simulate(gin, delta)
		_tick_toss_preview_for(seat.get("toss"), body, gin)
		_seat_present(seat, gin)




func _tick_seats_client(delta: float) -> void :
	for seat in _seats:
		var body: Player = seat.body
		if not is_instance_valid(body):
			continue
		var slot: LocalPlayerSlot = seat.slot
		var rig: CameraRig = seat.rig if seat.rig != null else camera_rig
		var gin: = PlayerInput.new()
		if slot.connected and not hud.pause_is_open() and not hud.chat_typing():
			gin = _gate_cinematics(seat.collector.collect(rig, body), body)
		var chan = seat.get("chan")
		if chan != null:
			Net.send_input(chan.encode(gin), int(seat.get("ls", 0)))

		var input_phase: = int(_np.get("ph", Phase.DEAD))
		var server: Player = _by_net_id.get(int(_np.get("sv", 0)))
		body.serve_charge_ui = input_phase == Phase.SERVE_PREP and server == body
		body.serving = input_phase == Phase.SERVE_PREP and server == body
		body.contact_enabled = input_phase == Phase.LIVE\
		or (input_phase == Phase.SERVE_PREP and server == body)
		body.free_actions = true
		var pred = seat.get("pred")
		if pred != null and chan != null and not bool(seat.get("benched", false)):
			body.simulate(gin, delta)
			_tick_toss_preview_for(seat.get("toss"), body, gin)
			pred.hard_snap = HARD_SNAP_DIST
			pred.tick(body, chan.seq, delta)
		_seat_present(seat, gin)




func _seat_present(seat: Dictionary, gin: PlayerInput) -> void :
	var body: Player = seat.body
	var rig: CameraRig = seat.rig if seat.rig != null else camera_rig
	var free: bool = rig.mode == CameraRig.Mode.ACTION or rig.mode == CameraRig.Mode.FIRST_PERSON
	var ib: bool = absf(gin.aim.x) <= _half_w and absf(gin.aim.z) <= _half_l



	var mp: bool = seat.view != null and seat.view.owners.size() > 1
	var cue: = Color.WHITE
	if mp:
		cue = _mp_ring_cursor(seat.slot, body.team_side, gin.aim.z, ib)
	elif GameConfig.aim_color_cue and ib:
		cue = Rules.half_color(gin.aim.z)
	if seat.aim != null:
		seat.aim.visible = not free and not _one_picture()
		seat.aim.ring_enabled = _ring_on(seat.slot.profile)
		seat.aim.aim_at(gin.aim, float(body.team_side), ib, rig.shake_offset, 
			cue if mp else Color(0, 0, 0, 0))
	if seat.view != null and seat.view.overlay != null:


		var ch: = _seat_crosshair(seat.slot)
		seat.view.overlay.set_sight(free, cue if mp else _crosshair_color(ch, cue), 
			ch.shape, ch.size, ch.outline)
		seat["cue"] = cue
	if seat.rig != null:
		var ball_side: = signf(ball.global_position.z)
		if ball_side != 0.0:
			seat.rig.possession = ball_side
		seat.rig.home_side = float(body.team_side)
		seat.rig.serve_view = _server == body\
		and (_phase == Phase.SERVE_PREP\
		or (_phase == Phase.LIVE and not _serve_done))
		seat.rig.focus_boost = 1.0 if (_phase == Phase.SERVE_PREP\
		and _server != null and _server.team_side == body.team_side) else 0.0





func _present_couch_indicators(delta: float) -> void :
	if _net_role != NetRole.CLIENT:
		return
	for seat in _seats:
		var gb: Player = seat.body
		if is_instance_valid(gb) and gb.net_puppet:
			gb._present_indicators(delta)

func _team_color(side: int, slot: int) -> Color:

	return Rules.side_color(side).darkened(0.06 * slot)




func _reset_cpu_names() -> void :
	_cpu_name_pool = CpuNames.shuffled(GameConfig.match_seed)
	_cpu_name_i = 0



func _next_cpu_name() -> String:
	if _cpu_name_pool.is_empty():
		_reset_cpu_names()
	var raw: String = _cpu_name_pool[_cpu_name_i % _cpu_name_pool.size()]
	_cpu_name_i += 1
	return "%s (CPU)" % raw





func _cpu_tagged(base: String) -> String:
	return base if base.ends_with("(CPU)") else "%s (CPU)" % base

func _spawn_teams_net() -> void :



	var n: = GameConfig.team_size
	var my_peer: = _local_pid()






	var _net_my_side: = 1
	for entry in GameConfig.net_roster:
		if int(entry.peer) == my_peer and int(entry.get("ls", 0)) == 0:
			_net_my_side = int(entry.side)
			break

	for entry in GameConfig.net_roster:
		if int(entry.peer) == my_peer and int(entry.get("ls", 0)) == 0\
		and bool(entry.get("spec", false)):
			_spectating = true
			break



	for entry in GameConfig.net_roster:
		if int(entry.peer) == 0 or int(entry.get("ls", 0)) != 0:
			continue
		var played: = clampi(Net.ev_i(entry, "tm", 0), -1, 1)
		if played == 0 and not bool(entry.get("spec", false)):
			played = clampi(int(entry.side), -1, 1)
		if played != 0:
			_note_team(int(entry.peer), played)
	_all_players = []
	var net_id: = 0


	_reset_cpu_names()


	var party_sizes: = PartyMark.party_sizes(GameConfig.net_roster)
	_party_by_sid.clear()
	for entry in GameConfig.net_roster:


		if bool(entry.get("spec", false)):
			continue
		net_id += 1
		var e_peer: = int(entry.peer)
		var e_ls: = int(entry.get("ls", 0))



		var is_mine: = e_peer == my_peer and not _spectating
		var body: Player
		if is_mine and e_ls == 0:
			body = player
		else:
			body = PLAYER_SCENE.instantiate()
			add_child(body)
		body.team_side = int(entry.side)
		body.global_position = _formation_spot(int(entry.slot), n, int(entry.side))
		body.face_net()




		var e_team: = int(entry.get("team", entry.side))



		body.set_team_color(_team_color(e_team, int(entry.slot)))

		var entry_cfg: Dictionary = entry.get("cfg", {})



		var look: = CharacterConfig.from_dict(entry_cfg) if not entry_cfg.is_empty()\
		else GameConfig.bot_character(e_team, int(entry.slot))

		var epeer: = int(entry.get("peer", 0))
		if epeer != 0 and not entry_cfg.is_empty() and not _is_local_peer(epeer):
			look = Mod.shown_look(epeer, look)
			body.muted_here = Mod.hides(epeer)
		var kit: Array = (entry.get("kit", []) as Array).map(
			func(s): return Color.html(str(s)))
		var fit: = _stage_outfit(look, kit, _outfit_of(int(entry.peer)))
		body.set_character(fit[0], fit[1])


		body.set_tag_color(_team_color(e_team, int(entry.slot)))
		_slots[body] = int(entry.slot)
		body.is_captain = bool(entry.get("cap", false))




		if int(entry.peer) == 0:



			var cname: = String(entry.get("cname", ""))
			_names[body] = ("%s (CPU)" % cname) if cname != "" else _next_cpu_name()
		else:
			_names[body] = String(entry.name)
		body.set_dev_tag(DevBadge.peer_tier(int(entry.peer)))


		var pg: = PartyMark.drawn(entry, party_sizes)
		body.set_party_mark(pg)
		_party_of[body] = pg

		var e_sid: = int((Net.players.get(e_peer, {}) as Dictionary).get("sid", 0))
		if e_sid != 0 and e_ls == 0:
			_party_by_sid[e_sid] = pg
		if bool(entry.get("gone", false)):


			_gone_bodies[body] = true

		if e_peer != 0 and not bool(entry.get("gone", false)):
			_seat_owner[body] = _pid_for(e_peer, e_ls)
		else:
			_cpu_diff[body] = int(entry.get("diff", Net.cpu_difficulty))
		_net_ids[body] = net_id
		_by_net_id[net_id] = body
		_all_players.append(body)
		if body == player:
			continue
		if e_peer == 0:


			body.is_bot = true
			body.charge_ui_enabled = false
			if _net_role == NetRole.HOST:
				var brain: = TeamBot.new()
				brain.configure(_half_w, _half_l, int(entry.slot), n)

				brain.apply_difficulty(int(entry.get("diff", Net.cpu_difficulty)))
				_bots[body] = brain
			if _net_role == NetRole.CLIENT:
				body.net_puppet = true
		elif is_mine and e_ls >= 1:





			_add_online_seat(body, e_ls)
		else:


			body.charge_ui_enabled = false
			if _net_role == NetRole.HOST:
				var pid: = _pid_for(e_peer, e_ls)
				_peer_players[pid] = body
				_peer_edges[pid] = {"jr": 0, "cr": 0, "sr": 0, "dv": 0, "bk": 0, "sv": 0}
			if _net_role == NetRole.CLIENT:
				body.net_puppet = true
	if _spectating:




		player.visible = false
		player.process_mode = Node.PROCESS_MODE_DISABLED
		player.global_position = Vector3(0.0, -100.0, 0.0)
		_become_spectator(_net_my_side)












func _is_own_body(body: Player) -> bool:
	return body == player and not _spectating







func _is_local_body(body: Player) -> bool:
	if _is_own_body(body):
		return true
	return _net_role == NetRole.CLIENT and _is_seated_body(body)




func _refresh_seat_menu() -> void :



	hud.set_seat_options(free_seats(1), free_seats(-1), 
		not _spectating or GameConfig.quick_backfill_side != 0)



func _on_seat_requested(team: int) -> void :


	if _net_role != NetRole.CLIENT:
		request_seat(_local_pid(), team)
	elif _net_role == NetRole.CLIENT:



		var no: = _seat_refusal(_local_pid(), team)
		if no != "":
			_tell_seat_no(no, team, int(_team_played.get(_local_pid(), 0)))
			return
		_seat_asked = team
		Net.send_up("seat", {"s": team})
		var phase: = _effective_phase()
		if phase != Phase.DEAD and phase != Phase.SERVE_PREP:
			hud.notice(_seat_queued_text(team), SEAT_NOTE_SECS)

func _on_seat_event(args: Dictionary) -> void :
	var body: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
	if body == null:
		return
	var peer: = Net.ev_i(args, "p", 0)






	var was: = Net.ev_i(args, "was", 0)
	var me: = _local_pid()
	var mine: = peer == me or (peer == 0 and was == me)
	_names[body] = Net.ev_s(args, "n", "cpu", 64)
	body.set_display_name(_names[body])
	body.set_dev_tag(DevBadge.peer_tier(peer))
	body.is_bot = peer == 0


	if args.has("pg"):
		var pg: = clampi(Net.ev_i(args, "pg", 0), 0, 64) if PartyMark.ENABLED else 0
		body.set_party_mark(pg)
		_party_of[body] = pg

	if peer != 0:
		_seat_owner[body] = peer
		_note_team(peer, clampi(Net.ev_i(args, "tm", 0), -1, 1))
	else:
		_seat_owner.erase(body)
		_cpu_diff[body] = Net.cpu_difficulty


	var switching: = Net.ev_b(args, "sw")
	if mine and not switching:
		_seat_asked = SEAT_NONE





	if peer != 0:
		var look: = _roster_look(peer) if _is_local_peer(peer) else _shown_roster_look(peer)
		body.muted_here = not _is_local_peer(peer) and Mod.hides(_pid_owner(peer))
		if look != null:
			var fit: = _stage_outfit(look, _team_kit_for(body.team_side), _outfit_of(peer))
			body.set_character(fit[0], fit[1])
	else:
		body.muted_here = false


		var cslot: = int(_slots.get(body, 0))
		var cpu_fit: = _stage_outfit(GameConfig.bot_character(body.team_side, cslot), 
			_team_kit_for(body.team_side))
		body.set_character(cpu_fit[0], cpu_fit[1])




	if peer < 0 and _pid_owner(peer) == me:
		var couch: = _local_seat_for_pid(peer)
		if not couch.is_empty():
			_rebind_seat(couch, body)
		elif _pid_ls(peer) < LocalPlayers.slots.size():



			_add_online_seat(body, _pid_ls(peer))
			_rebuild_local_views()
		return
	if not mine:

		body.net_puppet = _net_role == NetRole.CLIENT
		return
	if peer == 0:
		if body == player:
			_leave_seat(switching)
	else:
		_take_seat(body)






func _take_seat(body: Player) -> void :
	_spectating = false
	_watch_cam = null
	camera_rig.watched = false
	player = body
	body.net_puppet = false
	body.sim_authority = false
	body.is_bot = false
	_gone_bodies.erase(body)
	if not _stats.has(body):
		_stats[body] = {"pts": 0, "spk": 0, "blk": 0, "rcv": 0, "set": 0, "ast": 0}



	body.velocity = Vector3.ZERO
	body.reset_physics_interpolation()
	_interp_hard = true
	body.charge_ui_enabled = true
	body.indicator_enabled = true
	_pred.reset()
	camera_rig.player = body
	camera_rig.home_side = float(body.team_side)
	ball.home_side = float(body.team_side)
	camera_rig.mode = clampi(GameConfig.default_camera, 0, 
		CameraRig.Mode.size() - 1) as CameraRig.Mode
	_court_mouse_mode()
	hud.set_spectating(false)
	hud.set_play_ui_visible(true)
	hud.set_scoreboard_visible(true)
	_spec_apply_clean_all(true)


	hud.hide_seat_tell()




func _leave_seat(quiet: = false) -> void :
	if _spectating:
		return
	player.indicator_enabled = false
	player.charge_ui_enabled = false
	player.net_puppet = _net_role == NetRole.CLIENT
	_spectating = true
	_become_spectator(int(player.team_side))
	if not quiet:
		hud.notice("you are watching")

func _spec_apply_clean_all(show: bool) -> void :
	for p in _all_players:
		(p as Player).set_labels_visible(show)

func _become_spectator(my_side: int) -> void :


	if player != null:
		player.set_name_visible(true)
	var watch: Player = null
	for p in _all_players:


		if p == player:
			continue

		if (p as Player).team_side == my_side:
			watch = p
			break
	if watch == null:
		for p in _all_players:
			if p != player:
				watch = p
				break
	var ours: = player
	player = watch








	if ours != null and ours != watch and not _all_players.has(ours):
		ours.queue_free()
	if player == null:
		return

	player.indicator_enabled = false
	player.charge_ui_enabled = false

	camera_rig.mode = CameraRig.Mode.BROADCAST
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE




	camera_rig.watched = true
	_watch_cam = WatchCamera.new()
	_watch_cam.room_box = camera_rig.room_box
	_watch_cam.setup(camera_rig.camera)
	_watch_cam.bodies = _all_players
	_watch_cam.ball = ball
	_watch_cam.half_w = _half_w
	_watch_cam.half_l = _half_l
	var bar: = hud.spectate_controls()
	hud.set_spectating(true)



	hud.set_play_ui_visible(false)



	if _spec_bar_wired:
		return
	_spec_bar_wired = true
	bar.cam_pressed.connect( func():
		_watch_cam.cycle_mode()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE)
	bar.follow_pressed.connect( func(): _watch_cam.cycle_follow())
	bar.clean_pressed.connect( func():
		_spec_clean = (_spec_clean + 1) % 3
		_spec_apply_clean())
	bar.ui_pressed.connect( func():
		_spec_ui = not _spec_ui
		hud.set_watch_ui_visible(_spec_ui))

func _spec_tick(delta: float) -> void :
	if _watch_cam == null:
		return




	hud.set_play_ui_visible(false)
	_watch_cam.time += delta
	_watch_cam.drive(delta)
	var names: Array = []
	for p in _all_players:
		names.append(_names.get(p, "player"))
	var clean: String = ["off", "no names", "on"][_spec_clean]
	hud.spectate_controls().set_labels(_watch_cam.mode_name(), 
		_watch_cam.follow_name(names), clean, not _spec_ui)

func _spec_apply_clean() -> void :
	for p in _all_players:
		(p as Player).set_labels_visible(_spec_clean == 0)

func _spawn_bot(slot: int, n: int, side: int, color: Color, cpu: Dictionary = {}) -> Player:
	var bot: Player = PLAYER_SCENE.instantiate()
	bot.team_side = side
	add_child(bot)
	bot.global_position = _formation_spot(slot, n, side)
	bot.is_bot = true
	bot.charge_ui_enabled = false
	bot.set_team_color(color)





	var bot_kit: Array = GameConfig.side_kit(_team_identity(side))

	var look: CharacterConfig = CharacterConfig.from_dict(cpu.cfg)\
	if not cpu.is_empty() else GameConfig.bot_character(side, slot)
	var bot_fit: = _stage_outfit(look, bot_kit)
	bot.set_character(bot_fit[0], bot_fit[1])
	_slots[bot] = slot
	var brain: = TeamBot.new()
	brain.configure(_half_w, _half_l, slot, n)




	brain.apply_difficulty(int(cpu.get("diff", GameConfig.difficulty)))
	_bots[bot] = brain
	return bot

func _formation_spot(slot: int, n: int, side: int) -> Vector3:
	return _lines.formation_spot(slot, n, side)

func _court_slot(who: Player) -> int:
	return _rally.court_slot(who)

func _player_in_slot(side: int, slot: int) -> Player:
	return _rally.player_in_slot(side, slot)

func _flush_motion_state() -> void :




	for peer_id in _peer_queue:
		(_peer_queue[peer_id] as Array).clear()
	_peer_touch_inputs.clear()




	_pred.reset()

func _reset_formation() -> void :
	_flush_motion_state()
	_rally.reset_formation()

func _quick_set_ready(aim: Vector3, hitter: Player) -> bool:
	return _lines.quick_set_ready(_all_players, aim, hitter)





func _tick_toss_preview(input: PlayerInput) -> void :
	if _spectating:
		if _toss_preview != null:
			_toss_preview.clear()
		return
	_tick_toss_preview_for(_toss_preview, player, input)

func _tick_toss_preview_for(preview: TrajectoryPreview, body: Player, input: PlayerInput) -> void :
	if preview == null:
		return


	if not GameConfig.ball_hints:
		preview.clear()
		return

	if body != null and body.charging_set():
		preview.show_set(body)
		return
	if body == null or not body.serve_charge_ui or not input.contact_pressed:
		preview.clear()
		return
	var up: = Ball.serve_toss_up(body.hold_power())






	var horiz: = Ball.serve_toss_horiz(body.global_position, body.aim_point, 
		body.hold_power(), up)
	preview.show_arc(body.serve_cradle_point(true), 
		Vector3(horiz.x, up, horiz.z), Ball.PHYS.gravity, 0.0, 
		TrajectoryPreview.charge_color(body.hold_power()))



func _physics_process(delta: float) -> void :





	if _migrating:
		return
	_poll_callouts()
	_poll_seat_skip_votes()
	_sync_home_side()

	if _phase != Phase.REPLAY and _practice == null:
		_recorder.tick(delta)
	_apply_serve_squares()
	if _net_role == NetRole.CLIENT:
		_client_tick(delta)
		return




	for _p in _all_players:
		(_p as Player).free_actions = true
	if _phase == Phase.REPLAY:
		_replay_tick(delta)
		_update_indicators(_input_collector.collect(camera_rig, player))





		_decay_net_wobble(delta)
		if _net_role == NetRole.HOST:
			_net_tick += 1
			_net_info_tick()
			if _net_tick % SNAPSHOT_EVERY == 0:
				_snap_seq += 1
				Net.send_snapshot(_build_replay_snapshot())
		return


	_rally.pre_tick(delta, _phase != Phase.LIVE)



	for phase_player in _all_players:
		var phase_body: Player = phase_player
		phase_body.contact_enabled = _phase == Phase.LIVE\
		or (_phase == Phase.SERVE_PREP and phase_body == _server)
		phase_body.serve_charge_ui = _phase == Phase.SERVE_PREP\
		and phase_body == _server


		phase_body.team_touches = _rally.touch_count\
		if _rally.touch_side == phase_body.team_side else 0


	ball.serve_held = _phase == Phase.SERVE_PREP and not _rally.serve_done
	if _dev_match_point:
		_dev_match_point_tick()
	_record_lag_history()
	_tick_inputs.clear()









	var input: = PlayerInput.new()
	if not _spectating:
		input = _gate_cinematics(_input_collector.collect(camera_rig, player))
		if hud.chat_typing() or hud.pause_is_open():




			input = PlayerInput.new()
		_tick_inputs[player] = input
		player.simulate(input, delta)
		_tick_toss_preview(input)

	_tick_seats(delta)
	for peer_id in _peer_players:
		var remote: Player = _peer_players[peer_id]
		var rin: = _decode_peer_input(peer_id)
		_tick_inputs[remote] = rin
		remote.simulate(rin, delta)
		_remember_peer_touch_input(peer_id, remote, rin)
	var cine: = _phase == Phase.INTRO or _phase == Phase.COUNTDOWN\
	or _phase == Phase.WIN or _phase == Phase.STATS
	for p in _all_players:
		(p as Player).cinematic_hidden = cine
	for p in _bots:
		var bot_player: Player = p







		if bot_player == player and not _spectating:
			continue
		var bot_input: PlayerInput
		if cine:

			var walk: PlayerInput = _intro_walk_input(bot_player)\
			if _phase == Phase.INTRO else null
			bot_input = walk if walk != null else PlayerInput.new()
		else:
			var bot: TeamBot = _bots[bot_player]






















			bot.aggression = _rally.bot_aggression()
			var serving: bool = bot_player == _server and not _serve_done



			var team_serving: bool = _server != null and not _serve_done\
			and _server.team_side == bot_player.team_side
			bot_input = bot.think(bot_player, _allies_of(bot_player), 
				_opponents_of(bot_player), ball, _touch_count, _rally_live, 
				serving, delta, _rally.last_touch_side, team_serving)
		bot_player.simulate(bot_input, delta)

	for jumper in _ach_bam:
		if _ach_bam[jumper] and is_instance_valid(jumper) and (jumper as Player).is_on_floor():
			_ach_bam[jumper] = false
	_process_lag_touch_requests()
	if _practice != null:
		_practice.host_tick(delta)
	match _phase:
		Phase.INTRO:
			_intro_tick(delta)
		Phase.COUNTDOWN:
			_countdown_tick(delta)
		Phase.WIN:
			_win_tick(delta)
		Phase.STATS:
			pass
		Phase.DEAD:
			if _wait_peers.size() > 0:
				_wait_timeout -= delta
				if _wait_timeout <= 0.0:



					for peer_id in _wait_peers.keys():
						if _peer_players.has(peer_id):
							_on_peer_left(peer_id)
					_wait_peers.clear()
				hud.set_serve_prompt("waiting for players to load")
			elif _practice != null:
				_practice.dead_tick(delta)
			elif _replay_pending:






				_replay_wait -= delta
				if _replay_wait <= 0.0 and not _replay_starting:
					_enter_replay()
			elif _win_delay > 0.0:


				_win_delay -= delta
				if _win_delay <= 0.0:
					_win_delay = 0.0
					_start_win(_win_pending)
			else:
				if _swap_delay > 0.0:
					_swap_delay -= delta
					if _swap_delay <= 0.0:
						_swap_delay = 0.0
						_switch_sides()




				if _serve_prelaid and _server != null:
					ball.global_position = _server.serve_cradle_point()
					ball.vel = Vector3.ZERO
				_dead_timer -= delta
				if _dead_timer <= 0.0:
					if _match_over:
						_leave_to_lobby()
					elif _migrate_resume:








						_migrate_resume = false
						_point_wipe( func():
							_loading_up = false
							hud.set_loading(0.0)


							MIGRATION_COVER.dismiss()
							hud.flash_banner("rally restarted")
							_start_countdown())
					elif not _did_intro and not _faces_warm and _cover_t < FACES_WAIT:
						pass
					elif not _did_intro:



						if GameConfig.match_intro and _intros_run == 0:
							_start_intro()
						else:
							_skip_intro()
					elif _serve_prelaid:



						_serve_prelaid = false
						_begin_serve(false)
					else:
						_begin_serve()
		Phase.SERVE_PREP:
			_serve_prep_tick(delta)
		Phase.LIVE:

			_rally.live_tick(delta)
	_check_air_bumps()
	_check_stomps()
	for p in _all_players:
		var member: Player = p
		if absf(member.global_position.z) < 0.45\
		and absf(member.global_position.x) < _half_w\
		and member.velocity.length() > 1.0:
			_net_wobble = maxf(_net_wobble, 0.45)
	_motion_foley(delta)
	_decay_net_wobble(delta)
	_update_indicators(input)
	if _net_role == NetRole.HOST:
		_tick_peer_liveness(delta)





		if not _peer_players.is_empty():
			_stats_bcast_accum += delta
			if _stats_bcast_accum >= STATS_REBROADCAST_S:
				_stats_bcast_accum = 0.0
				_net_event("stats", {"r": _stat_rows()})
		_net_tick += 1
		_net_info_tick()
		if _net_tick % SNAPSHOT_EVERY == 0:
			_snap_seq += 1
			Net.send_snapshot(_build_snapshot())
		elif _ball_60hz:


			Net.send_ball_snapshot(_ball_net_state())

func _ball_net_state() -> PackedFloat32Array:
	return PackedFloat32Array([ball.global_position.x, ball.global_position.y, 
		ball.global_position.z, ball.vel.x, ball.vel.y, ball.vel.z, 
		1.0 if ball.frozen else 0.0, ball.curve, float(ball.strike_seq), 
		ball.stop_clock])

func _decay_net_wobble(delta: float) -> void :
	if _net_wobble > 0.001:



		_net_wobble *= exp(-1.1 * delta)
		((net_visual.mesh as PlaneMesh).material as ShaderMaterial)\
		.set_shader_parameter("wobble", _net_wobble)



var _match_gen: = 0

func _on_net_input(peer_id: int, ls: int, data: Dictionary) -> void :



	_peer_heard[peer_id] = 0.0


	var pid: = _pid_for(peer_id, ls)



	if data.has("g") and Net.ni(data.get("g", 0)) != _match_gen:
		return


	for older in Net.ev_arr(data, "r", 8):
		if older is Dictionary:
			_ingest_peer_input(pid, older)
	_ingest_peer_input(pid, data)

func _ingest_peer_input(peer_id: int, data: Dictionary) -> void :
	var seq: = Net.ev_i(data, "s")
	if seq <= int(_peer_seq_seen.get(peer_id, 0)):
		return
	_peer_seq_seen[peer_id] = seq








	var q: Array = _peer_queue.get(peer_id, [])
	q.append(data)







	while q.size() > INPUT_QUEUE_MAX:
		q.pop_front()
		_peer_dropped[peer_id] = int(_peer_dropped.get(peer_id, 0)) + 1
	_peer_queue[peer_id] = q

func _tick_peer_liveness(delta: float) -> void :




	for peer_id in _peer_players.keys():




		if peer_id < 0:
			continue
		if _wait_peers.has(peer_id):





			_peer_heard[peer_id] = 0.0
			continue
		if _practice != null and not _practice.wants_on(peer_id):






			_peer_heard[peer_id] = 0.0
			continue
		_peer_heard[peer_id] = float(_peer_heard.get(peer_id, 0.0)) + delta
		if _peer_heard[peer_id] > PEER_SILENT_TIMEOUT:
			_peer_heard.erase(peer_id)
			_on_peer_left(peer_id)

func _decode_peer_input(peer_id: int) -> PlayerInput:


	var input: = PlayerInput.new()

	var q: Array = _peer_queue.get(peer_id, [])



	while q.size() > INPUT_QUEUE_MAX:
		q.pop_front()
		_peer_dropped[peer_id] = int(_peer_dropped.get(peer_id, 0)) + 1






	if q.size() > INPUT_QUEUE_TARGET:
		_peer_deep[peer_id] = int(_peer_deep.get(peer_id, 0)) + 1
		if int(_peer_deep[peer_id]) >= INPUT_QUEUE_DEEP_TICKS:
			_peer_deep[peer_id] = 0
			q.pop_front()
			_peer_trimmed[peer_id] = int(_peer_trimmed.get(peer_id, 0)) + 1
	else:
		_peer_deep[peer_id] = 0
	if q.size() > 0:
		_peer_input[peer_id] = q.pop_front()
		_peer_starve_run[peer_id] = 0
	else:




		_peer_starved[peer_id] = int(_peer_starved.get(peer_id, 0)) + 1






		var run: = int(_peer_starve_run.get(peer_id, 0)) + 1
		_peer_starve_run[peer_id] = run
		if run == STARVE_STAND_TICKS and _peer_input.has(peer_id):
			var still: Dictionary = (_peer_input[peer_id] as Dictionary).duplicate()
			still["m"] = Vector2.ZERO
			still["mr"] = Vector2.ZERO
			still["sp"] = false
			_peer_input[peer_id] = still
	_peer_queue[peer_id] = q
	var msg: Dictionary = _peer_input.get(peer_id, {})
	if msg.is_empty():
		return input









	_peer_applied[peer_id] = int(msg.get("s", 0))


	return NetSync.decode_input_fields(msg, _peer_edges[peer_id])

func _remember_peer_touch_input(peer_id: int, body: Player, 
		input: PlayerInput) -> void :
	var seq: = int(_peer_applied.get(peer_id, 0))
	if seq <= 0:
		return
	var history: Dictionary = _peer_touch_inputs.get(peer_id, {})



	if history.has(seq):
		return







	var power: = body.hold_power()
	var finesse: = body._hold_real <= Player.FEEL.tap_hold


	var charge: = 0.0
	if input.contact_released or input.set_released:
		power = maxf(power, body._armed_power)
		finesse = body._armed_finesse
		charge = body._release_charge
	history[seq] = {"input": input, "power": power, "finesse": finesse, "charge": charge}
	for old_seq in history.keys():
		if int(old_seq) < seq - 32:
			history.erase(old_seq)
	_peer_touch_inputs[peer_id] = history

func _on_peer_left(peer_id: int) -> void :





	if peer_id > 0:
		var couch: Array = []
		for pid in _peer_players.keys():
			if pid < 0 and _pid_owner(pid) == peer_id:
				couch.append(pid)
		for pid in couch:
			_on_peer_left(pid)


	_pa_opt.erase(peer_id)
	_pa_push_states()
	var body: Player = _peer_players.get(peer_id)
	if body == null:
		return
	_wait_peers.erase(peer_id)
	_peer_players.erase(peer_id)
	_peer_heard.erase(peer_id)
	_peer_input.erase(peer_id)
	_peer_queue.erase(peer_id)
	_peer_seq_seen.erase(peer_id)
	_peer_applied.erase(peer_id)
	_peer_touch_inputs.erase(peer_id)
	_peer_starved.erase(peer_id)
	_peer_dropped.erase(peer_id)
	_peer_trimmed.erase(peer_id)
	_peer_deep.erase(peer_id)
	_peer_edges.erase(peer_id)
	body.is_bot = true
	_seat_owner.erase(body)
	_cpu_diff[body] = Net.cpu_difficulty
	var brain: = TeamBot.new()
	brain.configure(_half_w, _half_l, _slots[body], GameConfig.team_size)
	brain.apply_difficulty(Net.cpu_difficulty if _net_role != NetRole.OFFLINE else 1)
	_bots[body] = brain
	var gone: = String(_names[body])


	_names[body] = _cpu_tagged(gone)
	body.set_display_name(_names[body])
	body.set_dev_tag(DevBadge.Tier.NONE)
	hud.notice("%s has left the game" % gone)
	_net_event("left", {"id": _net_ids.get(body, 0), "n": gone})














var _join_queue: = {}








var _seat_owner: = {}
var _cpu_diff: = {}




var _team_played: = {}

var _team_by_sid: = {}
const SEAT_NONE: = 99
var _seat_asked: = SEAT_NONE

func _note_team(peer_id: int, team: int) -> void :
	if peer_id == 0 or team == 0 or _team_played.has(peer_id):
		return
	_team_played[peer_id] = team
	if _net_role == NetRole.HOST:
		var sid: = int((Net.players.get(peer_id, {}) as Dictionary).get("sid", 0))
		if sid != 0:
			_team_by_sid[sid] = team



func _rebadge_seats() -> void :
	for body in _seat_owner:
		var pid: = int(_seat_owner[body])
		if pid != 0 and is_instance_valid(body):
			(body as Player).set_dev_tag(DevBadge.peer_tier(_pid_owner(pid)))



func _shown_roster_look(peer_id: int) -> CharacterConfig:
	return Mod.shown_look(_pid_owner(peer_id), _roster_look(peer_id))




func _represence_seats(_pid: = 0) -> void :
	for body in _seat_owner:
		var pid: = int(_seat_owner[body])
		if pid == 0 or not is_instance_valid(body) or _is_local_peer(pid):
			continue
		var b: = body as Player
		b.muted_here = Mod.hides(_pid_owner(pid))
		var look: = _shown_roster_look(pid)
		if look != null:
			var fit: = _stage_outfit(look, _team_kit_for(b.team_side), _outfit_of(pid))
			b.set_character(fit[0], fit[1])


func _seat_team(peer_id: int) -> int:
	for p in _all_players:
		var body: Player = p
		if int(_seat_owner.get(body, 0)) == peer_id and not body.is_bot:
			return _team_identity(body.team_side)
	return 0











func _seat_refusal(peer_id: int, team: int) -> String:




	if _quick_seats():
		return "there" if _seat_team(peer_id) == team else "quick"
	var seated: = _seat_team(peer_id)
	if team == 0:



		if _pid_ls(peer_id) >= 1 or _net_role == NetRole.OFFLINE:
			return "couch"
		return "" if seated != 0 else "watching"
	if seated == team:
		return "there"
	if _pid_ls(peer_id) >= 1 and seated == 0:
		return "couch"
	if GameConfig.ranked_match:
		return "ranked"

	if GameConfig.lock_teams and _net_role != NetRole.OFFLINE:
		var theirs: = int(_team_played.get(peer_id, 0))
		if theirs != 0 and theirs != team:
			return "locked"
	if free_seats(_team_identity(team)) <= 0:
		return "full"
	return ""


func _quick_seats() -> bool:
	return _quick() and _net_role != NetRole.OFFLINE

func _seat_no_text(why: String, team: int, theirs: int) -> String:
	match why:
		"quick":
			return "teams are set in quick match"
		"locked":
			return "teams are locked. you're on %s" % _side_name(theirs) if theirs != 0\
			else "teams are locked"
		"full":
			return "%s is full" % _side_name(team)
		"ranked":
			return "you can't switch teams in a ranked match"
	return ""





const SEAT_NOTE_SECS: = 5.0

func _seat_queued_text(team: int) -> String:
	return "spectating at the next serve" if team == 0\
	else "joining %s at the next serve" % _side_name(team)


func _tell_seat_no(why: String, team: int, theirs: int) -> void :
	var text: = _seat_no_text(why, team, theirs)
	if text != "":
		hud.notice(text)

func _refuse_seat(peer_id: int, team: int, why: String) -> void :
	var theirs: = int(_team_played.get(peer_id, 0))
	if _is_local_peer(peer_id):
		_tell_seat_no(why, team, theirs)
	elif why != "there" and why != "watching":
		_net_event("seat_no", {"p": peer_id, "why": why, "t": team, "mine": theirs})

func request_seat(peer_id: int, team: int) -> void :
	var no: = _seat_refusal(peer_id, team)
	if no != "":
		_refuse_seat(peer_id, team, no)
		return
	_join_queue[peer_id] = team
	if _seat_boundary_safe():
		_apply_seat_requests()
	elif _is_local_peer(peer_id):
		hud.notice(_seat_queued_text(team), SEAT_NOTE_SECS)






func teams_state() -> Dictionary:
	var me: = _local_pid()
	var teams: = {1: [], -1: []}
	var mine: = 0
	var seated: = {}
	var order: Array = _all_players.duplicate()
	order.sort_custom( func(a, b): return int(_slots.get(a, 0)) < int(_slots.get(b, 0)))
	for p in order:
		var body: Player = p
		var team: = _team_identity(body.team_side)
		var owner: = int(_seat_owner.get(body, 0))
		var look: Dictionary = body.character.to_dict() if body.character != null else {}
		if body.is_bot or owner == 0:
			(teams[team] as Array).append({"kind": "cpu", 
				"name": String(_names.get(body, "cpu")).trim_suffix(" (CPU)"), 
				"cfg": look, "diff": int(_cpu_diff.get(body, Net.cpu_difficulty)), 
				"id": "cpu%d" % int(_net_ids.get(body, 0))})
			continue
		var conn: = _pid_owner(owner)
		var guest: = owner < 0
		var is_me: = _is_own_body(body)
		if not guest:
			seated[conn] = true
		if is_me:
			mine = team
		var tile: = {"kind": "human", 
			"name": String(_names.get(body, "player")), "cfg": look, 
			"host": conn == 1 and not guest and _net_role != NetRole.OFFLINE, "you": is_me, 
			"dev": 0 if guest else DevBadge.peer_tier(conn), 
			"id": str(conn), "actionable": not guest and not is_me and _net_role != NetRole.OFFLINE}


		if not _seats.is_empty() and (is_me or _is_seated_body(body)):
			var lslot: LocalPlayerSlot = LocalPlayers.primary() if is_me else null
			for seat in _seats:
				if seat.body == body:
					lslot = seat.slot
			if lslot != null:
				tile["local"] = lslot.tag()
				tile["local_color"] = lslot.color()
		(teams[team] as Array).append(tile)
	var watching: Array = []
	for pid in Net.players:
		if not seated.has(int(pid)):
			watching.append(String((Net.players[pid] as Dictionary).get("name", "player")))
	var asked: = SEAT_NONE
	if _net_role == NetRole.HOST and _join_queue.has(me):
		asked = int(_join_queue[me])
	elif _net_role == NetRole.CLIENT:
		asked = _seat_asked
	return {"size": _cfg_size(), "teams": teams, "mine": mine, 
		"watching": watching, "couch": not _seats.is_empty(), 
		"locked": GameConfig.lock_teams and _net_role != NetRole.OFFLINE, 
		"quick": _quick_seats(), 
		"played": int(_team_played.get(me, 0)), 
		"join": {1: _seat_refusal(me, 1), -1: _seat_refusal(me, -1)}, 
		"can_watch": _seat_refusal(me, 0) == "", "asked": asked}















func _seat_boundary_safe() -> bool:
	if _rally_live:
		return false



	if _replay_pending:
		return false
	return _phase == Phase.DEAD or _phase == Phase.SERVE_PREP

func _apply_seat_requests() -> void :
	_quick_autoseat()
	_drain_join_queue()

	_seat_unseated_guests()

func _drain_join_queue() -> void :
	if _join_queue.is_empty():
		return
	var queued: = _join_queue.duplicate()
	_join_queue.clear()
	for peer_id in queued:
		var team: = int(queued[peer_id])
		if team == 0:
			_release_seat(int(peer_id))
			continue



		var no: = _seat_refusal(int(peer_id), team)
		if no != "":
			_refuse_seat(int(peer_id), team, no)
		elif not _claim_seat(int(peer_id), _team_identity(team)):
			_refuse_seat(int(peer_id), team, "full")





func _quick_autoseat() -> void :
	if _net_role != NetRole.HOST or not _quick() or _match_over:
		return
	for pid in Net.players.keys():
		var peer: = int(pid)
		if _seat_team(peer) != 0 or (peer == 1 and not _spectating):
			continue



		if peer != 1 and not Net.match_ready_peers.get(peer, false):
			continue
		var team: = int(_team_played.get(peer, 0))
		if team == 0 or free_seats(_team_identity(team)) <= 0:
			team = _team_identity(_backfill_side())
		if team == 0 or free_seats(_team_identity(team)) <= 0:
			continue
		_claim_seat(peer, _team_identity(team))






func _seat_unseated_guests() -> void :
	if _net_role != NetRole.HOST or _match_over:
		return
	for pid in Net.players.keys():
		var peer: = int(pid)



		var owner_team: = _seat_team(peer)
		if peer == _local_pid() and owner_team == 0 and player != null and not player.is_bot:
			owner_team = _team_identity(player.team_side)
		if owner_team == 0:
			continue
		for i in Net.locals_of(peer).size():
			var gpid: = _pid_for(peer, i + 1)
			if _seat_team(gpid) != 0:
				continue
			var team: = owner_team
			if free_seats(_team_identity(team)) <= 0:
				team = - owner_team
			if free_seats(_team_identity(team)) <= 0:
				continue
			_claim_seat(gpid, _team_identity(team))

func free_seats(side: int) -> int:
	var n: = 0
	for p in _all_players:
		var body: Player = p




		if body.team_side == side and body.is_bot:
			n += 1
	return n



func _roster_look(peer_id: int) -> CharacterConfig:


	var owner: = _pid_owner(peer_id)
	var ls: = _pid_ls(peer_id)

	if _net_role != NetRole.OFFLINE:
		for entry in GameConfig.net_roster:
			if int(entry.get("peer", 0)) != owner or int(entry.get("ls", 0)) != ls:
				continue
			var cfg: Dictionary = entry.get("cfg", {})
			if cfg.is_empty():
				return null
			return CharacterConfig.from_dict(cfg)
	if ls >= 1:


		var locs: Array = Net.locals_of(owner)
		if ls - 1 < locs.size():
			var gcfg: Dictionary = (locs[ls - 1] as Dictionary).get("cfg", {})
			if not gcfg.is_empty():
				return CharacterConfig.from_dict(gcfg)
		if owner == _local_pid() and ls < LocalPlayers.slots.size():
			var prof: SavedProfile = LocalPlayers.slots[ls].profile
			if prof != null and not prof.character.is_empty():
				return CharacterConfig.from_dict(prof.character)
		return null


	if _net_role == NetRole.OFFLINE:
		return GameConfig.character if _is_local_peer(peer_id) else null




	var pcfg: Dictionary = (Net.players.get(peer_id, {}) as Dictionary)\
	.get("cfg", {})
	if not pcfg.is_empty():
		return CharacterConfig.from_dict(pcfg)
	if _is_local_peer(peer_id):
		return GameConfig.character
	return null







func _net_ids_of(body: Player) -> int:
	return int(_net_ids.get(body, 0))

func redress_for_side(body: Player) -> void :
	if body.character != null:
		body.set_character(body.character, _team_kit_for(body.team_side))



func _go_menu() -> void :
	if embedded:
		if practice_court != null and is_instance_valid(practice_court):
			practice_court.call("court_closed", "left")
		return
	GameConfig.goto_scene("res://game/ui/menu.tscn")



func practice_anyone_present() -> bool:
	return _practice != null and _practice.anyone_present()


var _embedded_cam_default: = -1

func set_embedded_active(on: bool) -> void :
	embedded_active = on
	_pause_world_audio( not on)
	var ui: = get_node_or_null("UiLayer") as CanvasLayer
	if ui != null:
		ui.visible = on
	var pm: = hud.get_node_or_null("PauseMenu") as PauseMenu
	if pm != null:
		pm.leave_override = _embedded_leave
		if not on and pm.is_open():
			pm.set_open(false)


	hud.pause_enabled = false
	if on:
		GameConfig.tod_live = true
		GameConfig.use_cursor(true)
		camera_rig.camera.current = true





		if GameConfig.default_camera != _embedded_cam_default:
			_embedded_cam_default = GameConfig.default_camera
			camera_rig.mode = clampi(GameConfig.default_camera, 0, 
				CameraRig.Mode.size() - 1) as CameraRig.Mode
		_court_mouse_mode()
	else:
		GameConfig.tod_live = false
		GameConfig.use_cursor(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameConfig.set_sfx_muffle(0.0)
		MusicManager.set_burn_muffle(0.0)
		_burn_k = 0.0
	if _practice != null:
		_practice.set_present(on)
	if on:



		if _practice != null:
			_practice.shared_tick()
		camera_rig.player = player
		for i in 6:
			camera_rig._process(0.25)




func resize_court(hw: float, hl: float) -> void :
	if is_equal_approx(hw, _half_w) and is_equal_approx(hl, _half_l):
		return
	_half_w = hw
	_half_l = hl
	_lines.configure(0.0, hw, hl)
	_serve_zone.setup(0.0, hw, hl)
	court.scale = Vector3(hw / BASE_HALF_W, 1.0, hl / BASE_HALF_L)
	ball.net_half_width = Ball.PHYS.net_half_width * (hw / BASE_HALF_W)
	ball.antenna_half_width = Ball.PHYS.antenna_half_width * (hw / BASE_HALF_W)
	ball.court_half_w = hw
	ball.court_half_l = hl
	_input_collector.aim_min = Vector2( - hw - 1.5, - hl - 2.5)
	_input_collector.aim_max = Vector2(hw + 1.5, hl + 2.5)
	camera_rig.court_span = hl
	for seat in _seats:
		if seat.collector != null:
			seat.collector.aim_min = _input_collector.aim_min
			seat.collector.aim_max = _input_collector.aim_max
		if seat.rig != null:
			(seat.rig as CameraRig).court_span = hl
	Stage.paint_court_floor(_floor_mat, _cfg_stage(), hw, hl)



	((net_visual.mesh as PlaneMesh).material as ShaderMaterial)\
	.set_shader_parameter("grid", Vector2(46.0 * court.scale.x, 7.0))
	if _sand_mat != null:
		_sand_mat.set_shader_parameter("court_wear", Vector2(hw, hl))
	if _stage_shell != null:
		for n in _stage_shell.find_children("*", "Node3D", true, false):
			if n.has_method("court_resized"):
				n.call("court_resized", hw, hl)
	if _practice != null:
		_practice.place_pads()



func _practice_grow_to() -> Vector2:
	if _practice != null or PracticeMode.active():
		return GameConfig.court_dims(Net.PRACTICE_SIZE)
	return Vector2.ZERO










func restage(id: String) -> void :
	id = Stage.resolve(id)
	var old: = _cfg_stage()
	if not embedded or id == old:
		return
	var old_barefoot: = GameConfig.barefoot_for(self)
	if _stage_shell != null:
		remove_child(_stage_shell)
		_stage_shell.queue_free()
		_stage_shell = null
	for n in _stage_court_extras:
		if is_instance_valid(n):
			(n as Node).queue_free()
	_stage_court_extras = []


	if bool(Stage.val(old, "owns_floor", false)):
		_floor_mat.shader = _floor_base_shader
		var cf: = court.get_node_or_null("CourtFloor") as Node3D
		if cf != null:
			cf.position.y -= 0.06


	var keep: = GameConfig.stage
	var keep_ball: = ball.stage_ball
	GameConfig.stage = id
	_built_stage = id
	_apply_stage_tracked()
	GameConfig.stage = keep
	ball.stage_ball = keep_ball

	if _stage_shell != null and _reflector != null:
		for n in _stage_shell.find_children("*", "Node3D", true, false):
			if n.has_method("wire_reflection"):
				n.wire_reflection(_reflector.texture())


	if GameConfig.barefoot_for(self) != old_barefoot:
		for p in _all_players:
			var body: Player = p
			if is_instance_valid(body) and body.character != null:
				body.set_character(body.character, body.replay_kit)

	if not embedded_active:
		_pause_world_audio(true)



func _outfit_of(pid: int) -> String:
	if _net_role == NetRole.OFFLINE:
		return GameConfig.menu_outfit
	var live: = String((Net.players.get(pid, {}) as Dictionary).get("outfit", ""))
	if live != "":
		return live
	for e in GameConfig.net_roster:
		if int((e as Dictionary).get("peer", 0)) == pid:
			return String((e as Dictionary).get("outfit", "gym"))
	return GameConfig.menu_outfit if _net_role == NetRole.OFFLINE else "gym"





func _pause_world_audio(paused: bool) -> void :
	for n in find_children("*", "AudioStreamPlayer", true, false):
		(n as AudioStreamPlayer).stream_paused = paused
	if embedded and not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)



func _on_node_added(n: Node) -> void :
	if embedded_active or not (n is AudioStreamPlayer) or not is_ancestor_of(n):
		return
	(n as AudioStreamPlayer).stream_paused = true
	(n as AudioStreamPlayer).set_deferred("stream_paused", true)

var _audio_hold_t: = 0.0



func _body_of_peer(pid: int) -> Variant:
	for b in _seat_owner:
		if int(_seat_owner[b]) == pid and is_instance_valid(b):
			return b
	return null


func _embedded_leave() -> void :
	if practice_court != null and is_instance_valid(practice_court):
		practice_court.emit_signal("request_menu")

func _team_kit_for(side: int) -> Array:
	var team: = _team_identity(side)
	for entry in GameConfig.net_roster:
		if bool(entry.get("spec", false)):
			continue


		var entry_team: = int(entry.get("team", entry.get("side", 0)))
		if entry_team == team and not entry.get("kit", []).is_empty():
			return (entry.get("kit", []) as Array).map(
				func(c): return Color.html(str(c)))




	return GameConfig.side_kit(team)



func _announce_seat(who: String, side: int, _body: Player) -> void :
	if side == 0:
		hud.notice("%s is spectating" % who)
		return
	hud.notice("%s joined %s" % [who, _side_name(side)])

func _is_local_peer(peer_id: int) -> bool:




	return _net_role != NetRole.CLIENT and peer_id == _local_pid()




func _pid_name(pid: int) -> String:
	if pid >= 0:
		if _net_role == NetRole.OFFLINE and pid == _local_pid():
			return LocalPlayers.primary_name()
		return String((Net.players.get(pid, {}) as Dictionary).get("name", "player"))
	var owner: = _pid_owner(pid)
	var ls: = _pid_ls(pid)
	var locs: Array = Net.locals_of(owner)
	if ls - 1 >= 0 and ls - 1 < locs.size():
		var n: = String((locs[ls - 1] as Dictionary).get("name", ""))
		if n != "":
			return n
	if owner == _local_pid() and ls < LocalPlayers.slots.size():
		return LocalPlayers.slots[ls].display_name()
	return "player"

func _claim_seat(peer_id: int, side: int) -> bool:



	if free_seats(side) <= 0:
		return false


	var couch: = _local_seat_for_pid(peer_id)
	if _peer_players.has(peer_id) or (_is_local_peer(peer_id) and not _spectating) or not couch.is_empty():
		_release_seat(peer_id, true)
	var body: Player = null
	for p in _all_players:
		var candidate: Player = p
		if candidate.team_side == side and candidate.is_bot:
			body = candidate
			break
	if body == null:
		return false
	_bots.erase(body)
	body.is_bot = false
	_gone_bodies.erase(body)


	if not _stats.has(body):
		_stats[body] = {"pts": 0, "spk": 0, "blk": 0, "rcv": 0, "set": 0, "ast": 0}
	if _is_local_peer(peer_id):

		_spectating = false
		_watch_cam = null
		camera_rig.watched = false
		player = body
		body.charge_ui_enabled = true
		body.indicator_enabled = true
		camera_rig.player = body
		camera_rig.home_side = float(body.team_side)
		ball.home_side = float(body.team_side)




		camera_rig.mode = clampi(GameConfig.default_camera, 0, 
			CameraRig.Mode.size() - 1) as CameraRig.Mode
		_court_mouse_mode()
		hud.set_spectating(false)
		hud.set_play_ui_visible(true)





	elif not couch.is_empty():



		_rebind_seat(couch, body)
	elif peer_id < 0 and _pid_owner(peer_id) == _local_pid()\
	and _pid_ls(peer_id) < LocalPlayers.slots.size():





		_add_online_seat(body, _pid_ls(peer_id))
		body.net_puppet = false
		body.sim_authority = true
		_rebuild_local_views()
	else:
		body.charge_ui_enabled = false
		_peer_players[peer_id] = body
	if couch.is_empty():



		if not _peer_edges.has(peer_id):
			_peer_edges[peer_id] = {"jr": 0, "cr": 0, "sr": 0, "dv": 0, "bk": 0, "sv": 0}
		_peer_queue[peer_id] = []
		_peer_heard[peer_id] = 0.0
	var who: = _pid_name(peer_id)



	var look: = _roster_look(peer_id) if _is_local_peer(peer_id) else _shown_roster_look(peer_id)
	body.muted_here = not _is_local_peer(peer_id) and Mod.hides(_pid_owner(peer_id))
	if look != null:
		var fit: = _stage_outfit(look, _team_kit_for(body.team_side), _outfit_of(peer_id))
		body.set_character(fit[0], fit[1])
	_names[body] = who
	body.set_display_name(who)
	body.set_dev_tag(DevBadge.peer_tier(peer_id))



	var pg: = _party_for(peer_id)
	body.set_party_mark(pg)
	_party_of[body] = pg



	var team: = _team_identity(body.team_side)
	_seat_owner[body] = peer_id
	_note_team(peer_id, team)
	_announce_seat(who, team, body)
	if _practice != null and PracticeMode.is_parked(body):
		_practice.unpark(body, _lines.formation_spot(
			int(_slots.get(body, 0)), GameConfig.team_size, body.team_side))
	_net_event("seat", {"id": _net_ids.get(body, 0), "p": peer_id, "n": who, 
		"who": who, "side": team, "tm": int(_team_played.get(peer_id, team)), "pg": pg})
	return true




func _party_for(pid: int) -> int:
	if not PartyMark.ENABLED or not _quick():
		return 0
	var owner: = _pid_owner(pid)
	var ls: = _pid_ls(pid)

	var sizes: = PartyMark.party_sizes(GameConfig.net_roster)
	var pg: = PartyMark.of_person(GameConfig.net_roster, owner, ls, "")
	if pg > 0:
		return PartyMark.drawn({"pg": pg}, sizes)
	var sid: = int((Net.players.get(owner, {}) as Dictionary).get("sid", 0))
	if sid != 0:
		return int(_party_by_sid.get(sid, 0)) if ls == 0 else 0
	return PartyMark.drawn({"pg": PartyMark.of_person(GameConfig.net_roster, owner, ls, _pid_name(pid))}, sizes)




func _release_seat(peer_id: int, switching: = false) -> void :


	var body: Player = _peer_players.get(peer_id)
	if body == null and _is_local_peer(peer_id) and not _spectating:
		body = player
	if body == null:
		var couch: = _local_seat_for_pid(peer_id)
		if not couch.is_empty() and is_instance_valid(couch.body):
			body = couch.body
	if body == null:
		return
	_peer_players.erase(peer_id)
	_peer_input.erase(peer_id)
	_peer_queue.erase(peer_id)
	_peer_seq_seen.erase(peer_id)
	_peer_applied.erase(peer_id)
	_peer_touch_inputs.erase(peer_id)
	_peer_starved.erase(peer_id)
	_peer_dropped.erase(peer_id)
	_peer_trimmed.erase(peer_id)
	_peer_deep.erase(peer_id)

	body.is_bot = true
	var brain: = TeamBot.new()
	brain.configure(_half_w, _half_l, _slots[body], GameConfig.team_size)

	var diff: = Net.cpu_difficulty if _net_role != NetRole.OFFLINE else GameConfig.difficulty
	brain.apply_difficulty(diff)
	_bots[body] = brain




	var cslot: = int(_slots.get(body, 0))
	var cpu_fit: = _stage_outfit(GameConfig.bot_character(body.team_side, cslot), 
		_team_kit_for(body.team_side))
	body.set_character(cpu_fit[0], cpu_fit[1])
	var gone: = String(_names[body])


	_names[body] = _cpu_tagged(gone)
	body.set_display_name(_names[body])
	body.set_dev_tag(DevBadge.Tier.NONE)
	_seat_owner.erase(body)
	_cpu_diff[body] = diff
	if _is_local_peer(peer_id):
		_spectating = true
		_become_spectator(int(body.team_side))



	if switching:
		_net_event("seat", {"id": _net_ids.get(body, 0), "p": 0, "n": _cpu_tagged(gone), 
			"was": peer_id, "sw": true})
		return



	if _is_local_peer(peer_id):
		hud.notice("you are watching")
	else:
		_announce_seat(gone, 0, body)
	_net_event("seat", {"id": _net_ids.get(body, 0), "p": 0, "n": _cpu_tagged(gone), 
		"who": gone, "side": 0, "was": peer_id})



func _build_snapshot() -> Dictionary:





	var pstates: = PackedFloat32Array()
	for p in _all_players:
		pstates.append_array((p as Player).net_capture())
	var acks: = {}
	for peer_id in _peer_input:
		acks[peer_id] = _peer_applied.get(peer_id, 0)
	return {
		"ph": _phase, "sc": _serve_clock, "rt": _rally_time, 
		"tc": _touch_count, "sv": _net_ids.get(_server, 0), 
		"lt": _net_ids.get(_last_toucher, 0), 
		"sd": _serve_done, 
		"s1": _scores[1], "s2": _scores[-1], 
		"w1": _set_wins[1], "w2": _set_wins[-1], "sn": _set_number, 


		"b": _ball_net_state(), 
		"p": pstates, "ack": acks, 


		"sq": _snap_seq, 

		"g": _match_gen, 
	}

func _build_replay_snapshot() -> Dictionary:





	var acks: = {}
	for peer_id in _peer_input:
		acks[peer_id] = _peer_applied.get(peer_id, 0)
	return {
		"ph": Phase.REPLAY, 
		"s1": _scores[1], "s2": _scores[-1], 
		"w1": _set_wins[1], "w2": _set_wins[-1], "sn": _set_number, 
		"ack": acks, "sq": _snap_seq, "g": _match_gen, 
	}

func _pstate(flat: PackedFloat32Array, idx: int) -> PackedFloat32Array:

	var base: = idx * PSTATE_FLOATS
	if idx < 0 or base + PSTATE_FLOATS > flat.size():
		return PackedFloat32Array()
	return flat.slice(base, base + PSTATE_FLOATS)

func _net_event(kind: String, args: Dictionary) -> void :
	if _net_role == NetRole.HOST:
		Net.send_event(kind, args)






func _ach_emit(body: Player, event: String, data: Dictionary) -> void :
	if body == null or body.is_bot or _practice != null:
		return



	if LaunchGate.public_beta():
		return
	_ach_local(body, event, data)
	_net_event("ach", {"id": int(_net_ids.get(body, -1)), "e": event, "d": data})






func _ach_profile(body: Player) -> SavedProfile:
	if body == null or body.is_bot:
		return null
	if body == player:
		return null if _spectating else ProfileStore.active()
	for seat in _seats:
		if seat.body == body:
			var prof: SavedProfile = (seat.slot as LocalPlayerSlot).profile
			if prof != null and prof != ProfileStore.active()\
			and ProfileStore.profiles.has(prof):
				return prof
			return null
	return null


func _ach_locals() -> Array:
	var out: Array = []
	var bodies: Array = [player]
	for seat in _seats:
		bodies.append(seat.body)
	for b in bodies:
		var body: Player = b
		if not is_instance_valid(body):
			continue
		var prof: = _ach_profile(body)
		if prof != null:
			out.append([body, prof])
	return out

func _ach_local(body: Player, event: String, data: = {}) -> void :
	var prof: = _ach_profile(body)
	if prof != null:
		Achievements.notify_for(prof, event, data)



func _remote_guest(body: Player) -> bool:
	if _net_role != NetRole.HOST or body == player or body.is_bot\
	or not _seat_owner.has(body) or _peer_players.values().has(body):
		return false
	for seat in _seats:
		if seat.body == body:
			return false
	return true

func _ach_touched(kind: int, who: Player) -> void :
	if _net_role == NetRole.CLIENT or who == null:
		return

	if _ach_roll != null and _ach_roll != who:
		_ach_emit(_ach_roll, "roll_save", {})
		_ach_roll = null
	var name: = ""
	match kind:
		Player.TouchKind.SPIKE:
			name = "spike"
		Player.TouchKind.DUMP:
			name = "dump"
		Player.TouchKind.BLOCK:
			name = "block"
		Player.TouchKind.SET:
			name = "set"
		Player.TouchKind.BUMP:
			name = "bump"


	if who == _rally.server and not _rally.serve_done:
		name = "serve"


		_ach_serve = {"by": who, "float": kind == Player.TouchKind.SPIKE and ball.float_serve}

	_ach_cord = null




	var foot: = kind == Player.TouchKind.BUMP and int(who.get("_kick_foot")) != 0



	var bam: = bool(_ach_bam.get(who, false)) and not who.is_on_floor()
	_ach_bam[who] = false


	var high: = false
	if kind == Player.TouchKind.SET and ball != null:
		var low: = who.grounded()\
		and ball.global_position.y - who.global_position.y < Player.FEEL.set_low_height
		high = not low





	_ach_touch[who] = {"kind": name, "foot": foot, "bam": bam, "quick": false, "high": high, 
		"answered": false, "feed": {}, 
		"jump": kind == Player.TouchKind.SET and not who.grounded(), 
		"full": kind == Player.TouchKind.SPIKE and who.last_touch_charge >= 0.999, 
		"x": who.global_position.x}

	if kind == Player.TouchKind.BLOCK and who.block_was_broken():
		_ach_emit(who, "block_broken", {})

	if kind == Player.TouchKind.BLOCK and not who.block_was_broken():



		var hitter: Player = _rally.team_last_toucher.get( - who.team_side)
		var was_attack: bool = _rally.touch_side == - who.team_side\
		and _rally.last_touch_kind in [Player.TouchKind.SPIKE, Player.TouchKind.DUMP]\
		and not (hitter == _rally.server and not _rally.serve_received)
		_ach_emit(who, "block", {"shifted": who.block_shifted() and was_attack})
	_ach_read_touch(kind, who)






func _ach_read_touch(kind: int, who: Player) -> void :
	var side: = who.team_side

	if _ach_broke != null and _ach_broke.team_side == side:
		_ach_broke = null
	if not _ach_combo.is_empty() and int(_ach_combo.side) == side:
		_ach_combo = {}
	if kind == Player.TouchKind.BLOCK:


		if who.block_was_broken() and _rally.last_touch_kind == Player.TouchKind.SPIKE:
			_ach_broke = _rally.team_last_toucher.get( - side)

		_ach_chain = {1: [], -1: []}
		return

	if not _rally.live or (_rally.touch_side == side\
	and _rally.touch_count >= Rules.TOUCHES_PER_SIDE):
		return



	var serve: = who == _rally.server and not _rally.serve_done
	var opens: = _rally.touch_side != side or _rally.touch_count == 0
	if _rally.touch_side != side:
		_ach_chain[side] = []
	var chain: Array = _ach_chain[side]
	var attack: = kind == Player.TouchKind.SPIKE or kind == Player.TouchKind.DUMP



	if attack or (kind == Player.TouchKind.BUMP and who.kicked()):
		for other in _ach_touch:
			if (other as Player).team_side == - side:
				_ach_touch[other]["answered"] = true



	if attack and not serve and not chain.is_empty():
		var feeder: Player = chain.back()
		var fed: Dictionary = _ach_touch.get(feeder, {})
		if feeder != who and String(fed.get("kind", "")) in ["set", "bump"]:
			_ach_touch[who]["feed"] = {"by": feeder, 
				"set": String(fed.get("kind", "")) == "set", 
				"high": bool(fed.get("high", false)), 
				"jump": bool(fed.get("jump", false))}
	chain.append(who)
	if attack and _rally.touch_side == side\
	and _rally.touch_count == Rules.TOUCHES_PER_SIDE - 1:

		_ach_combo = {"side": side, "by": who, "team": chain.duplicate()}



	if kind == Player.TouchKind.SPIKE and opens and not serve\
	and _rally.serve_done and _rally.serve_received:
		_ach_emit(who, "first_touch_spike", {})







func _on_rally_received(who: Player, overhand: bool) -> void :
	if _net_role == NetRole.CLIENT or who == null:
		return
	if overhand:

		_ach_emit(who, "receive", {"dive": false, "dive_run": 0, "overhand": true})
		return
	var dive: = who.diving()
	var run: = (int(_ach_dives.get(who, 0)) + 1) if dive else 0
	_ach_dives[who] = run


	_ach_emit(who, "receive", {"dive": dive, "dive_run": run})

	if dive and int(who.get("_dive_side")) != 0:
		_ach_roll = who



func _on_jumped(bam: bool, who: Player) -> void :


	if _net_role != NetRole.CLIENT:
		_ach_bam[who] = bam
	if _remote_guest(who):

		_ach_emit(who, "jump", {"bam": bam})
		return
	_ach_local(who, "jump", {"bam": bam})

func _ach_point(winner_side: int, scorer: Player, reason: = "", 
		winners_ball: = false) -> void :
	if _net_role == NetRole.CLIENT:
		return

	if _ach_roll != null:
		if _ach_roll.team_side == winner_side:
			_ach_emit(_ach_roll, "roll_save", {})
		_ach_roll = null






	var srec: Dictionary = _ach_touch.get(scorer, {}) if scorer != null else {}
	var earned: = scorer != null and not bool(srec.get("answered", false))


	var feed: Dictionary = srec.get("feed", {}) if earned else {}
	var helper: Player = null
	if not feed.is_empty() and is_instance_valid(feed.get("by")):
		helper = feed.get("by")



	var was: = int(_scores[winner_side]) - 1
	var theirs: = int(_scores[ - winner_side])
	var target: = GameConfig.set_points



	var match_point_down: bool = theirs >= target - 1 and theirs > was\
	and int(_set_wins[ - winner_side]) + 1 >= GameConfig.sets_to_win


	var run_break: = winner_side != _run_side and _run_len >= 3\
	and not (_fault_tag(reason) in ["foot fault", "fault"])

	var line: = reason == "" and winners_ball and _landed_on_line()



	var ace: bool = reason == "" and scorer != null and scorer == _rally.server\
	and String(srec.get("kind", "")) == "serve"\
	and _rally.serve_crossed and not _rally.serve_received
	var combo_team: Array = []
	if earned and not _ach_combo.is_empty() and int(_ach_combo.side) == winner_side\
	and _ach_combo.by == scorer:
		combo_team = _ach_combo.team



	var cross: = reason == "" and winners_ball\
	and _crossed_court(float(srec.get("x", 0.0)), _last_verdict_pos.x)


	var net_cord: = reason == "" and scorer != null and _ach_cord == scorer

	var floater: Player = _ach_serve.get("by") if bool(_ach_serve.get("float", false)) else null



	for p in _all_players:
		var body: Player = p
		if body.team_side != winner_side or body.is_bot:
			continue
		var mine: = earned and body == scorer
		var assist: = helper != null and body == helper
		_ach_emit(body, "point", {
			"mine": mine, 
			"kind": String(srec.get("kind", "")) if mine else "", 
			"quick": mine and bool(srec.get("quick", false)), 
			"foot": mine and bool(srec.get("foot", false)), 
			"bam": mine and bool(srec.get("bam", false)), 
			"assist": assist, 
			"assist_high": assist and bool(feed.get("high", false)), 
			"assist_set": assist and bool(feed.get("set", false)), 
			"line": mine and line, 
			"ace": mine and ace, 
			"broke_block": mine and _ach_broke == body, 
			"match_point_down": match_point_down, 
			"run_break": run_break, 
			"combo3": body in combo_team, 
			"assist_jump": assist and bool(feed.get("jump", false)), 
			"full": mine and bool(srec.get("full", false)), 
			"cross": mine and String(srec.get("kind", "")) == "spike" and cross, 
			"net_cord": mine and net_cord, 
			"pinch": floater != null and body == floater, 
		})




	if _ach_tossed and _rally.rally_time > 60.0:
		for p in _all_players:
			_ach_emit(p, "long_rally", {"secs": _rally.rally_time})
	_ach_tossed = false
	_ach_touch.clear()
	_ach_bam.clear()
	_ach_broke = null
	_ach_combo = {}
	_ach_chain = {1: [], -1: []}
	_ach_cord = null
	_ach_serve = {}



func _crossed_court(hit_x: float, land_x: float) -> bool:
	var wing: = _half_w / 3.0
	return absf(hit_x) >= wing and absf(land_x) >= wing and signf(hit_x) != signf(land_x)




func _ach_set_end(won_for: Callable) -> void :
	var target: = GameConfig.set_points
	var deuce: bool = GameConfig.win_by_two\
	and mini(int(_scores[1]), int(_scores[-1])) >= target - 1
	for each in _ach_locals():
		var body: Player = each[0]
		var won: = bool(won_for.call(body))
		var tally: Dictionary = _ach_sets.get(body, {"won": 0, "lost": 0})
		tally["won" if won else "lost"] = int(tally["won" if won else "lost"]) + 1
		_ach_sets[body] = tally
		Achievements.notify_for(each[1], "set_end", {"won": won, "deuce": deuce})

func _on_float_shown(text: String, color: Color, priority: bool, who: Player) -> void :
	_net_event("float", {"id": _net_ids.get(who, 0), "t": text, 
		"c": color.to_html(), "pr": priority})


	_recorder.cue("float", {"s": _all_players.find(who), "t": text, 
		"c": color.to_html(), "pr": priority})

func _present_thump(pos: Vector3, strength: float) -> void :
	var at: = Vector3(pos.x, 0.08, pos.z)
	sfx.play("hit_soft", at, -2.0, 0.55)
	_contact_fx(at, strength, Vector3.UP)
	fx.puff(at)

func _on_predicted_thumped(pos: Vector3, strength: float) -> void :



	_pred_thumps.append({"t": Time.get_ticks_msec()})
	_present_thump(pos, strength)

func _on_thumped(pos: Vector3, strength: float, who: Player) -> void :



	var at: = Vector3(pos.x, 0.08, pos.z)
	_present_thump(at, strength)
	crowd.cheer(0.25 * strength)


	_net_event("thump", {"p": at, "s": strength, 
		"id": int(_net_ids.get(who, 0))})

func _on_launched(pos: Vector3, charge: float, _who: Player) -> void :



	var at: = Vector3(pos.x, 0.06, pos.z)
	fx.ring(at, Vector3.UP, 1.15 * charge)
	fx.puff(at)


	if charge >= 1.5:
		fx.bam_swirl(at, charge, _who)
	sfx.play("hit_soft", at, -4.0, 1.35)
	_net_event("launch", {"p": at, "c": charge, "id": int(_net_ids.get(_who, 0))})

func _on_combo_shown(count: int, fail: bool, who: Player) -> void :



	var home: = _team_identity(who.team_side) == 1
	_combo_sfx(count, fail, who.global_position, home)


	_net_event("combo", {"id": _net_ids.get(who, 0), "n": count, "f": fail, "h": home})
	_recorder.cue("combo", {"s": _all_players.find(who), "n": count, "f": fail})




const COMBO_DB: = -13.0
func _combo_sfx(count: int, fail: bool, pos: Vector3, home: bool) -> void :
	if _practice != null and not fail:



		var step: = clampi(count, 1, 8)
		var pitch: = pow(2.0, minf(float(maxi(count - 8, 0)), 24.0) / 12.0)
		sfx.play("combo_tut_%d" % step, pos, COMBO_DB, pitch, false, true)
		return
	var bank: = "combo_fail" if fail\
	else "combo_%s_%d" % ["home" if home else "away", clampi(count, 1, 3)]


	sfx.play(bank, pos, COMBO_DB, 1.0, false, true)

func _on_block_broken(pos: Vector3, who: Player) -> void :


	fx.shield_crack(pos)
	sfx.play("block_hard", pos, 2.0, 0.85)
	who.show_float_text("block broken!", BREAK_COLOR, true)
	crowd.shock(0.95)
	_net_event("blockbreak", {"p": pos, "id": _net_ids.get(who, 0)})

func _on_voiced(bank: String, pitch: float, who: Player) -> void :


	sfx.play(bank, who.global_position + Vector3(0.0, 1.4, 0.0), -3.0, pitch)
	_net_event("voice", {"b": bank, "p": pitch, 
		"id": _net_ids.get(who, 0)})

func _on_callout_made(idx: int, who: Player) -> void :


	_net_event("callout", {"id": _net_ids.get(who, 0), "i": idx, "v": who.last_call_variant})
	_recorder.cue("callout", {"s": _all_players.find(who), "i": idx, "v": who.last_call_variant})



func _relay_gesture(who: Player, idx: int) -> void :
	if not Player.CALLOUT_GESTURES.has(idx):
		return

	var gv: = who.last_gesture_variant
	_net_event("callout", {"id": _net_ids.get(who, 0), "i": idx, "g": 1, "v": gv})
	_recorder.cue("callout", {"s": _all_players.find(who), "i": idx, "g": 1, "v": gv})

var _prac_rejoin_at: = {}
const PRAC_REJOIN_MS: = 3000

func _on_up_event(peer_id: int, kind: String, args: Dictionary) -> void :



	if kind == "pact":





		if _practice != null:
			var on: = bool(args.get("on", false))
			_practice.want_present(peer_id, on)





			if on and not _peer_players.has(peer_id) and Net.party_members().has(peer_id):
				var now: = Time.get_ticks_msec()
				if now - int(_prac_rejoin_at.get(peer_id, -100000)) > PRAC_REJOIN_MS:
					_prac_rejoin_at[peer_id] = now
					_on_late_joiner(peer_id)
		return
	if kind == "pstam":


		var want: = Net.ev_i(args, "id", 0)
		var sb: Player = null
		for b in _net_ids:
			if int(_net_ids[b]) == want:
				sb = b
		var theirs: bool = sb != null and (_peer_players.get(peer_id) == sb\
		or _pid_owner(int(_seat_owner.get(sb, 0))) == peer_id)
		if _practice != null and theirs:
			_practice.set_stamina(sb, bool(args.get("on", false)))
		return
	if kind == "jprac":
		if _practice != null and Net.party_members().has(peer_id)\
		and not _peer_players.has(peer_id):
			_on_late_joiner(peer_id)
		return


	if kind == "skip_vote":
		_register_skip_vote(peer_id)
		return
	if kind == "pa":

		_pa_opt[peer_id] = true
		_pa_push_states()
		return
	if kind == "seat":



		var ls: = Net.ev_i(args, "ls", 0)
		var pid: = peer_id
		if ls >= 1:
			if ls >= LocalPlayers.MAX_LOCAL or ls - 1 >= Net.locals_of(peer_id).size():
				return
			pid = _pid_for(peer_id, ls)
		request_seat(pid, clampi(Net.ev_i(args, "s"), -1, 1))
		return
	if kind == "toss":





		if _phase == Phase.SERVE_PREP and _rally.server != null\
		and not _rally.serve_done and ball.frozen\
		and _peer_players.get(peer_id) == _rally.server\
		and (_practice != null or _rally.in_serve_zone(_rally.server, 0.8)):


			_rally.request_toss(clampf(Net.ev_f(args, "u", 7.5), Ball.PHYS.serve_toss_min, Ball.PHYS.serve_toss_max))
		return
	if kind == "touch_try":
		if not _lag_touch:
			return




		var mine: = 0
		for r in _lag_touch_requests:
			if int(r.peer) == peer_id:
				mine += 1
		if mine >= 4:
			return
		_lag_touch_requests.append({"peer": peer_id, 
			"seq": Net.ev_i(args, "s"), "view": Net.ev_f(args, "v", -1.0), 
			"delay": Net.ev_f(args, "d", INTERP_DELAY_MIN), 
			"until": Time.get_ticks_msec() + 250})
		return
	if kind == "callout":


		var body: Player = _peer_players.get(peer_id)
		if body != null and _phase != Phase.REPLAY and _intro_may_call(body):

			body.quick_chat(Net.ev_i(args, "i"), true, Player.CALL_SLACK_MS, 
				clampi(Net.ev_i(args, "v", 0), 0, Player.CALL_VARIANTS - 1))
		return
	if kind == "cgest":


		var gbody: Player = _peer_players.get(peer_id)
		var gi: = Net.ev_i(args, "i")
		if gbody != null and _phase != Phase.REPLAY and Player.is_quick_chat(gi):
			gbody.gesture_call(gi, clampi(Net.ev_i(args, "v", -1), -1, Player.CALL_VARIANTS - 1))
			_relay_gesture(gbody, gi)

func _poll_callouts() -> void :
	if hud.chat_typing():
		return
	if hud.pause_is_open():
		return






	if player == null or _phase == Phase.REPLAY or _spectating:
		return


	for seat in _seats:
		var sbody: Player = seat.body
		if not is_instance_valid(sbody) or not seat.slot.connected:
			continue
		if bool(seat.get("benched", false)):
			continue
		if not _intro_may_call(sbody):
			continue
		var r: DeviceInput = _callout_polls.get(seat.slot.device)
		if r == null:
			r = DeviceInput.new(seat.slot.device)
			_callout_polls[seat.slot.device] = r
		r.device = seat.slot.device
		r.poll(CALLOUT_ACTIONS)
		for i in CALLOUT_ACTIONS.size():
			if r.just_pressed(CALLOUT_ACTIONS[i]):

				var call: int = Player.QUICK_CHAT[i]
				if sbody.quick_chat(call) != Player.CallResult.OK:
					_relay_gesture(sbody, call)
				else:
					_ach_local(sbody, "quick_chat")
				break


	_p1_callout.exclude_pads = LocalPlayers.claimed_pads()
	_p1_callout.exclude_kbm = LocalPlayers.kbm_taken()
	_p1_callout.poll(CALLOUT_ACTIONS)
	var idx: = -1
	for i in CALLOUT_ACTIONS.size():
		if _p1_callout.just_pressed(CALLOUT_ACTIONS[i]):
			idx = Player.QUICK_CHAT[i]
			break
	if idx >= 0 and _intro_may_call(player):
		_p1_call(idx)



func _intro_may_call(body: Player) -> bool:
	return _effective_phase() != Phase.INTRO or body == null\
	or body.team_side == _intro_shown_side


func _p1_call(idx: int) -> void :


	var said: Player.CallResult
	if _net_role == NetRole.CLIENT:
		said = player.quick_chat(idx, false)
		if said == Player.CallResult.OK:
			Net.send_up("callout", {"i": idx, "v": player.last_call_variant})


			_recorder.cue("callout", {"s": _all_players.find(player), "i": idx, 
				"v": player.last_call_variant})
		elif said != Player.CallResult.REFUSED and Player.CALLOUT_GESTURES.has(idx):

			Net.send_up("cgest", {"i": idx, "v": player.last_gesture_variant})
			_recorder.cue("callout", {"s": _all_players.find(player), "i": idx, "g": 1, 
				"v": player.last_gesture_variant})
	else:
		said = player.quick_chat(idx)
		if said != Player.CallResult.OK and said != Player.CallResult.REFUSED:
			_relay_gesture(player, idx)
	if said == Player.CallResult.OK:
		_ach_local(player, "quick_chat")
	if said == Player.CallResult.COOLING:
		_play_local_reach("reach_miss", -8.0)

func _on_local_touch_attempted() -> void :
	if not _lag_touch or _net_role != NetRole.CLIENT\
	or _spectating or _render_host_ms < 0.0:
		return






	Net.send_up("touch_try", {"s": _in_chan.seq, "v": _render_host_ms, 
		"d": maxf(_delay_now - _ball_present_lead_ms, 0.0)})

func _record_lag_history() -> void :
	if not _lag_touch or _net_role != NetRole.HOST or not _rally.live:
		return
	var bodies: = {}
	for body in _all_players:
		var member: Player = body
		bodies[int(_net_ids.get(member, 0))] = member.global_position
	_lag_history.append({"t": float(_net_tick) * 1000.0 / 60.0, 
		"p": ball.global_position, "v": ball.vel, "c": ball.curve, 
		"b": bodies})
	var cutoff: = float(_net_tick) * 1000.0 / 60.0 - LAG_TOUCH_HISTORY_MS
	while not _lag_history.is_empty() and float(_lag_history[0].t) < cutoff:
		_lag_history.pop_front()

func _lag_sample(peer_id: int, client_delay: float) -> Dictionary:
	if _lag_history.is_empty():
		return {}
	var now_ms: = float(_net_tick) * 1000.0 / 60.0










	var buf: = clampf(client_delay, 0.0, INTERP_DELAY_MAX + 20.0)
	var expected_age: = Net.peer_rtt_ms(peer_id) * 0.5 + buf
	var target: = clampf(now_ms - expected_age, now_ms - LAG_TOUCH_HISTORY_MS, now_ms)



	var lo: Dictionary = _lag_history[0]
	var hi: Dictionary = _lag_history[_lag_history.size() - 1]
	for s in _lag_history:
		if float(s.t) <= target:
			lo = s
		if float(s.t) > target:
			hi = s
			break
	var pos: Vector3 = lo.p
	var span: = float(hi.t) - float(lo.t)
	if span > 1.0:
		var a: = clampf((target - float(lo.t)) / span, 0.0, 1.0)
		pos = (lo.p as Vector3).lerp(hi.p as Vector3, a)
	return {"p": pos, "t": target}






var _lag_reject: = {"expired": 0, "dead": 0, "reach": 0, "kind": 0, "ok": 0}

func _process_lag_touch_requests() -> void :
	if _net_role != NetRole.HOST or _lag_touch_requests.is_empty():
		return
	var keep: Array = []
	for request in _lag_touch_requests:
		var peer_id: = int(request.peer)
		if Time.get_ticks_msec() > int(request.until):
			_lag_reject.expired += 1
			continue
		if int(_peer_applied.get(peer_id, 0)) < int(request.seq):
			keep.append(request)
			continue
		var body: Player = _peer_players.get(peer_id)
		var sample: = _lag_sample(peer_id, float(request.get("delay", INTERP_DELAY_MIN)))
		var input_history: Dictionary = _peer_touch_inputs.get(peer_id, {})
		var touch_state: Dictionary = input_history.get(int(request.seq), {})
		if body == null or sample.is_empty() or not _rally.live\
		or touch_state.is_empty() or body.contact_barred()\
		or body._touch_lock > 0.0:
			_lag_reject.dead += 1
			continue
		var historic_ball: Vector3 = sample.p
		var applied_input: PlayerInput = touch_state.input



		var current_aim: = body.aim_point
		body.aim_point = applied_input.aim









		var influence: Vector2 = body._air_influence(applied_input)
		var pushed: = body._dump_push_left > 0.0 or body.dump_push(applied_input)
		var set_plan: Array = body.set_release_plan(applied_input.aim, float(touch_state.power), 
			pushed) if applied_input.set_released else []
		if not set_plan.is_empty():
			body.aim_point = set_plan[2]
		if not body.ball_position_in_reach(historic_ball):
			body.aim_point = current_aim
			_lag_reject.reach += 1
			continue
		var kind: Player.TouchKind = set_plan[3] if not set_plan.is_empty()\
		else body.resolved_touch_at(historic_ball)
		if kind == Player.TouchKind.NONE or kind == Player.TouchKind.BLOCK:
			body.aim_point = current_aim
			_lag_reject.kind += 1
			continue
		_lag_reject.ok += 1
		for member in _all_players:
			(member as Player).contact_enabled = true
		var quick: = bool(set_plan[1]) if not set_plan.is_empty()\
		else (kind == Player.TouchKind.SET and body.quick_check.is_valid()\
		and bool(body.quick_check.call(body.aim_point, body)))
		var power: = float(set_plan[0]) if not set_plan.is_empty() else float(touch_state.power)
		body._release_charge = float(touch_state.get("charge", 0.0))
		body._dump_rise = body.set_dump_rise(power)\
		if not set_plan.is_empty() and kind == Player.TouchKind.DUMP else -1.0
		body._do_touch(kind, power, bool(touch_state.finesse), 
			influence, quick)
		body._dump_rise = -1.0
		body.aim_point = current_aim
	_lag_touch_requests = keep



func _client_tick(delta: float) -> void :
	if _practice != null:
		_practice.shared_tick()



	if int(_np.get("ph", Phase.DEAD)) == Phase.REPLAY:
		if _replay_stand_off:
			return
		if _phase != Phase.REPLAY\
		and Time.get_ticks_msec() - _rec_started_ms\
		< int((REPLAY_LEAD + REPLAY_TAIL + 1.0) * 1000.0):




			_replay_stand_off = true
			hud.set_replay_banner(true, 0, _skips_needed())
			return
		if _phase != Phase.REPLAY:
			_phase = Phase.REPLAY
			_setup_director()
			_voted_skip = false
			_input_collector.clear_buffers()





			_begin_dissolve(0.0, REPLAY_CUT)
			hud.set_replay_banner(true, 0, _skips_needed())
		_replay_client_tick(delta)
		return
	if _replay_stand_off:

		_replay_stand_off = false
		hud.set_replay_banner(false, 0, 0)
		_interp_hard = true
		_snap_buf.clear()
	if _phase == Phase.REPLAY:
		_phase = Phase.DEAD
		hud.set_replay_banner(false, 0, 0)
		_replay_lead = 0.0





		_input_collector.swallow_held(["jump", "contact", "dive", "serve"])
		_input_collector.clear_buffers()
		CrowdField.calm()
		_begin_dissolve(REPLAY_OUT_HOLD, REPLAY_OUT_FADE)



		camera_rig.cinematic = false
		camera_rig.cine_snap = false
		ball.net_puppet = _ball_puppet_saved
		ball.show_landing_ring = true
		_interp_hard = true
		_snap_buf.clear()



		_reset_formation()
		for i in _all_players.size():
			var body: Player = _all_players[i]


			body.net_puppet = not _is_local_body(body)
			body.cinematic_hidden = false
			body.suppress_names(false)
			body.hide_callout()
			body.reset_physics_interpolation()
		_puppet_saved.clear()










	var input_phase: = int(_np.get("ph", Phase.DEAD))
	var input_server: Player = _by_net_id.get(int(_np.get("sv", 0)))
	player.serve_charge_ui = input_phase == Phase.SERVE_PREP\
	and input_server == player and not _spectating






	player.serving = input_phase == Phase.SERVE_PREP and input_server == player


	ball.serve_held = input_phase == Phase.SERVE_PREP and ball.frozen
	player.contact_enabled = input_phase == Phase.LIVE\
	or (input_phase == Phase.SERVE_PREP and input_server == player)
	var input: = PlayerInput.new()
	if not _spectating:
		input = _gate_cinematics(_input_collector.collect(camera_rig, player))
		if hud.chat_typing() or hud.pause_is_open():




			input = PlayerInput.new()
		_send_client_input(input)
		if _practice != null and input.serve_pressed and not (input_phase == Phase.SERVE_PREP and input_server == player):
			_practice.call_pressed()


		player.free_actions = true
		player.simulate(input, delta)
		_tick_toss_preview(input)



		_pred.hard_snap = HARD_SNAP_DIST
		_pred.tick(player, _in_chan.seq, delta)


	_tick_seats_client(delta)





	if _velsync_on() and not _spectating and player.touch_seq != _pred_touch_seen:
		_pred_touch_seen = player.touch_seq
		if not ball.frozen:
			_ball_grace = Net.peer_rtt_ms(1) * 0.001 + 0.25
			_ball_grace_seq = _ball_host_strikes
			_pred_strike_mutes += 1
	if _ball_grace > 0.0:
		_ball_grace = maxf(_ball_grace - delta, 0.0)
		if _ball_grace <= 0.0:
			_pred_strike_mutes = 0







	_toss_pred = maxf(_toss_pred - delta, 0.0)
	if _np.has("b"):
		var _b_arr: PackedFloat32Array = _np.b
		if _b_arr.size() > 6:
			var host_frozen: = _b_arr[6] > 0.5








			if _toss_visual_state.is_empty() or _toss_pred <= 0.0:
				ball.frozen = host_frozen
	if _toss_pred <= 0.0 and not _toss_visual_state.is_empty():
		_toss_visual_state.clear()
		_toss_unfrozen_snaps = 0



		_ball_offset_armed = true



	var velsync: = _velsync_on() and not ball.frozen
	ball.net_puppet = not ball.frozen and not velsync
	if ball.frozen:

		_ball_dead = false
		var holder: Player = _by_net_id.get(int(_np.get("sv", 0)))
		if holder != null:
			ball.global_position = holder.serve_cradle_point()
			ball.vel = Vector3.ZERO






		if not _spectating and holder == player\
		and ((input.serve_pressed and _practice == null)\
		or player.serve_release_counts(input))\
		and (_practice != null or _rally.in_serve_zone(player)):
			var up: = 7.5 if input.serve_pressed\
			else Ball.serve_toss_up(player.hold_power())
			ball.frozen = false

			ball.serve_assist = _practice == null or _rally.in_serve_zone(player, 0.6)


			var toss_charge: = Ball.serve_toss_charge(up)
			ball.toss(player.serve_cradle_point(), up, 
				Ball.serve_toss_horiz(player.global_position, player.aim_point, 
					toss_charge, up))
			player.present_serve_toss(true)





			Net.send_up("toss", {"u": up})
			if not _velsync_on():
				ball.net_puppet = true
				_toss_visual_state = [ball.global_position, ball.vel, ball.curve]
				_toss_unfrozen_snaps = 0





			_toss_pred = Net.peer_rtt_ms(1) * 0.001 + 1.1
	elif not velsync and not (_ball_interp and ball.net_puppet):





		var e: = _ball_err.length()
		if e > BALL_LEASH_DEAD:
			var rate: = lerpf(BALL_LEASH_MIN, BALL_LEASH_MAX, 
				clampf((e - BALL_LEASH_DEAD) / BALL_LEASH_FULL, 0.0, 1.0))
			var excess: = _ball_err * ((e - BALL_LEASH_DEAD) / e)
			var bfix: = excess * minf(1.0, delta * rate)
			ball.global_position += bfix
			_ball_err -= bfix
	if not _toss_visual_state.is_empty():


		_toss_visual_state = Ball.step_flight(_toss_visual_state[0], 
			_toss_visual_state[1], _toss_visual_state[2], delta, 
			ball.net_half_width, ball.court_center_x, ball.wall_min, ball.wall_max)
		ball.global_position = _toss_visual_state[0]
		ball.vel = _toss_visual_state[1]
		ball.curve = _toss_visual_state[2]
	_client_interp()
	for p in _all_players:
		var member: Player = p
		if not _is_local_body(member):
			member.puppet_tick(delta)





	_present_couch_indicators(delta)
	var _ph_now: int = _np.get("ph", Phase.DEAD)
	_rally_live = _ph_now == Phase.LIVE







	if _ph_now == Phase.SERVE_PREP:
		_ball_dead = false
		if player != null:
			player.contact_enabled = true

		if not _client_in_serve_prep:
			_client_in_serve_prep = true
			_client_new_rally()
	else:
		_client_in_serve_prep = false
	_rally_time = _np.get("rt", 0.0)
	_motion_foley(delta)
	_decay_net_wobble(delta)
	_update_indicators_client(input)
	_net_tick += 1
	_net_info_tick()
	_dbg_ball_report(delta)
	if _net_shot and _net_tick % 240 == 120 and _shot_count < 6:
		_shot_count += 1
		var img: = get_viewport().get_texture().get_image()
		img.save_png("res://game/dev/shots/net_%d.png" % _shot_count)

















var _client_rally_fresh: = false





var _sand_set: = -1
func _sand_new_rally() -> void :
	if _sand_deform == null:
		return
	if _set_number != _sand_set:
		_sand_set = _set_number
		_sand_deform.reset()
	_sand_deform.checkpoint()

func _client_new_rally() -> void :
	_ball_dead = false
	_client_rally_fresh = true
	if player != null:
		player.dive_cooldown = 0.0
		player.stamina = Player.FEEL.stamina_max
		player.stamina_locked = false
	_sand_new_rally()

func _send_client_input(input: PlayerInput) -> void :
	Net.send_input(_in_chan.encode(input))

func _velsync_on() -> bool:
	return _velsync












func _dbg_ball_report(delta: float) -> void :
	if not _net_log:
		return
	_dbg_since += delta
	if _dbg_since < 1.0:
		return
	print("[ball] err avg=%.3f max=%.3f n=%d | pred avg=%.3f max=%.3f n=%d | stale=%d grace=%d unfair=%d rejected=%d present=%.0fms" % [
		_dbg_ball_err_sum / maxf(_dbg_ball_err_n, 1), _dbg_ball_err_max, _dbg_ball_err_n, 
		_dbg_pred_err_sum / maxf(_dbg_pred_err_n, 1), _dbg_pred_err_max, _dbg_pred_err_n, 
		_dbg_stale_drops, _dbg_grace_skips, _dbg_unfair_floor, _dbg_rejected_touch, 
		_ball_present_lead_ms])
	_dbg_ball_err_sum = 0.0
	_dbg_ball_err_max = 0.0
	_dbg_ball_err_n = 0
	_dbg_pred_err_sum = 0.0
	_dbg_pred_err_max = 0.0
	_dbg_pred_err_n = 0
	_dbg_stale_drops = 0
	_dbg_grace_skips = 0
	_dbg_unfair_floor = 0
	_dbg_rejected_touch = 0
	_dbg_since = 0.0









func _on_ball_snapshot(b: PackedFloat32Array) -> void :
	if _net_role != NetRole.CLIENT or b.size() < 9 or not _velsync_on():
		return
	if ball.frozen or not ball.is_inside_tree():
		return
	if int(_np.get("ph", Phase.DEAD)) == Phase.REPLAY:
		return





	var n: = float(b[8])
	if n < _ball_host_strikes:
		if _net_log:
			_dbg_stale_drops += 1
		return
	_ball_host_strikes = n




	if _ball_grace > 0.0:
		if _ball_host_strikes > _ball_grace_seq:
			_ball_grace = 0.0
		else:
			if _net_log:
				_dbg_grace_skips += 1
			return
	if _net_log:


		var e: = ball.global_position.distance_to(Vector3(b[0], b[1], b[2]))
		_dbg_ball_err_sum += e
		_dbg_ball_err_max = maxf(_dbg_ball_err_max, e)
		_dbg_ball_err_n += 1
	ball.vel = ball.vel.lerp(Vector3(b[3], b[4], b[5]), VELSYNC_VEL_WEIGHT)
	ball.global_position = ball.global_position.lerp(
		Vector3(b[0], b[1], b[2]), VELSYNC_POS_WEIGHT)
	ball.curve = b[7]
	ball.stop_clock = b[9] if b.size() >= 10 else Ball.STOP_NONE

func _on_snapshot(data: Dictionary) -> void :









	if data.has("g") and (int(data.g) & 4294967295) != (_match_gen & 4294967295):
		return
	_snap_count += 1
	_np = data
	if int(data.get("ph", Phase.DEAD)) == Phase.REPLAY:










		_last_snap_at = Time.get_ticks_msec()
		return




	var now: = Time.get_ticks_msec()
	var seq: = int(data.get("sq", -1))
	if seq >= 0:



		if seq <= _snap_newest:
			return
		_snap_newest = seq



		var off: = float(now) - float(seq) * SNAP_MS











		var stalled: = get_process_delta_time() > 0.1 and _clock_offset != INF

		if not stalled and _clock_offset_min != INF\
		and off > _clock_offset_min + CLOCK_JUMP_MS:
			_clock_jump_n += 1
			_clock_jump_min = minf(_clock_jump_min, off)
			if _clock_jump_n >= CLOCK_JUMP_SNAPS:
				_clock_offset_min = _clock_jump_min
				_clock_offset = _clock_jump_min
				_off_win_min = INF
				_off_win_n = 0
				_clock_jump_n = 0
				_clock_jump_min = INF
				_interp_hard = true
		else:
			_clock_jump_n = 0
			_clock_jump_min = INF
		if not stalled:
			_off_win_min = minf(_off_win_min, off)
			_off_win_n += 1
			if _clock_offset_min == INF:
				_clock_offset_min = off
			elif _off_win_n >= CLOCK_WINDOW_SNAPS:
				_clock_offset_min = _off_win_min
				_off_win_min = INF
				_off_win_n = 0
			else:
				_clock_offset_min = minf(off, _clock_offset_min + CLOCK_RELAX_MS)






			_clock_warm += 1
			if _clock_warm <= CLOCK_WARMUP_SNAPS:
				_clock_offset = _clock_offset_min
		if _clock_offset == INF:
			_clock_offset = _clock_offset_min
			_delay_now = interp_delay()
	if _last_snap_at != 0:

		var gap: = float(now - _last_snap_at)
		_snap_jitter = lerpf(_snap_jitter, absf(gap - _snap_gap), 0.15)
		_snap_gap = lerpf(_snap_gap, gap, 0.15)
		_snap_gap_max = maxf(gap, _snap_gap_max * INTERP_GAP_DECAY)
	_last_snap_at = now
	_snap_buf.append({"at": now, "hm": float(seq) * SNAP_MS, "d": data})
	if not _toss_visual_state.is_empty() and data.b.size() > 6\
	and data.b[6] < 0.5:
		_toss_unfrozen_snaps += 1
	while _snap_buf.size() > 40:
		_snap_buf.pop_front()


	_reconcile_local(data)
	_reconcile_seats(data)







func _adopt_strike_flight(args: Dictionary, remote: = false) -> void :
	if _net_role != NetRole.CLIENT:
		return

	if not (args.get("bv") is Vector3 and args.get("bp") is Vector3):
		return
	if not ((args.bv as Vector3).is_finite() and (args.bp as Vector3).is_finite()):
		return
	if not ball.is_inside_tree():
		return

	if ball.frozen:
		return
	var n: = Net.ev_f(args, "n", -1.0)



	if n >= 0.0 and _ball_host_strikes >= n:
		return
	if n >= 0.0:



		_ball_host_strikes = n
		ball.strike_seq = int(n)




		if not _toss_visual_state.is_empty():
			_toss_visual_state.clear()
			_toss_unfrozen_snaps = 0
			_toss_pred = 0.0
			_ball_offset_armed = true






	ball.spike_lock = Ball.spike_lock_for(
		Net.ev_i(args, "k", Player.TouchKind.NONE), args.bv)

	var fs: = Net.ev_i(args, "fs", 0)
	if fs != 0:
		ball.start_float(fs)
	else:
		ball.stop_float()

	ball.tip_drop = Net.ev_b(args, "tp", false)
	ball.dive_g = clampf(Net.ev_f(args, "dg", 1.0), 1.0, Ball.PHYS.serve_dive_max)





	if ball.net_puppet:
		if args.has("ht"):
			_ball_event_flight = {
				"hm": Net.ev_f(args, "ht"), 
				"p": args.bp, 
				"v": args.bv, 
				"c": Net.ev_f(args, "c", 0.0), 
				"sc": Net.ev_f(args, "sc", Ball.STOP_NONE), 
				"n": n, 
			}
		return


	var age: = Net.peer_rtt_ms(1) * 0.0005
	var _st: = _ball_exact(args.bp, args.bv, Net.ev_f(args, "c", 0.0), age, 
		Net.ev_f(args, "sc", Ball.STOP_NONE))
	var pos: Vector3 = _st[0]
	var vel: Vector3 = _st[1]
	ball.curve = _st[2]
	ball.stop_clock = _st[3]
	var jump: = pos - ball.global_position





	ball.vel = vel
	ball.curve = _st[2]
	if jump.length() > BALL_DESYNC_SNAP:
		ball.global_position = pos
		ball.reset_physics_interpolation()
		_ball_err = Vector3.ZERO
	elif remote:





		if _velsync_on():
			ball.global_position = ball.global_position.lerp(pos, 0.5)
		else:
			_ball_err = jump





func _adopt_bounce_flight(args: Dictionary) -> void :
	if _net_role != NetRole.CLIENT or not args.has("p")\
	or not ball.is_inside_tree():
		return
	ball.global_position = Net.ev_v3(args, "p")
	ball.vel = Net.ev_v3(args, "bv")
	ball.curve = 0.0
	ball.stop_clock = Ball.STOP_NONE
	ball.reset_physics_interpolation()
	ball.trail.restart()
	_ball_err = Vector3.ZERO
	_ball_event_flight.clear()

func _tick_dead_ball_visual(delta: float) -> void :
	if not _ball_dead or ball.frozen or not ball.is_inside_tree():
		return
	var state: = Ball.step_flight(ball.global_position, ball.vel, ball.curve, delta, 
		ball.net_half_width, ball.court_center_x, ball.wall_min, ball.wall_max)
	ball.global_position = state[0]
	ball.vel = state[1]
	ball.curve = state[2]





func _ball_exact(pos: Vector3, vel: Vector3, curve: float, age: float, 
		stop: = Ball.STOP_NONE) -> Array:


	var dt: = get_physics_process_delta_time()
	if dt <= 0.0 or age <= 0.0:
		return [pos, vel, curve, stop]
	if _ball_ballistic:
		return [pos + vel * age + Vector3(0.0, -0.5 * Ball.PHYS.gravity * age * age, 0.0), 
			vel - Vector3(0.0, Ball.PHYS.gravity * age, 0.0), curve, 
			Ball.stop_clock_after(stop, age)]
	var st: Array = [pos, vel, curve, stop]
	var whole_ticks: = int(floor(age / dt))
	var fc: = ball.flight_float_charge()
	for _i in whole_ticks:
		st = Ball.step_flight(st[0], st[1], st[2], dt, 
			ball.net_half_width, ball.court_center_x, ball.wall_min, ball.wall_max, st[3], fc)
		fc = float(st[4])




	var remainder: = age - float(whole_ticks) * dt
	if remainder > 0.0001:
		st = Ball.step_flight(st[0], st[1], st[2], remainder, 
			ball.net_half_width, ball.court_center_x, ball.wall_min, ball.wall_max, st[3], fc)
	return st







func _measure_ball_model(data: Dictionary, age: float, corr: float) -> void :
	var b: PackedFloat32Array = data.b
	var seq: = int(data.get("sq", -1))
	if seq < 0 or b.size() < 9:
		return
	var cur: = Vector3(b[0], b[1], b[2])
	if not _bm_prev.is_empty():
		var pb: PackedFloat32Array = _bm_prev.b
		var pseq: = int(_bm_prev.seq)
		if seq > pseq and b[8] == pb[8] and b[6] < 0.5 and pb[6] < 0.5:
			var dt: = get_physics_process_delta_time()
			var ticks: = (seq - pseq) * SNAPSHOT_EVERY
			var t: = float(ticks) * dt
			var st: Array = [Vector3(pb[0], pb[1], pb[2]), 
				Vector3(pb[3], pb[4], pb[5]), pb[7]]
			for _i in ticks:
				st = Ball.step_flight(st[0], st[1], st[2], dt, 
					ball.net_half_width, ball.court_center_x, 
					ball.wall_min, ball.wall_max)
			var model_exact: float = (st[0] as Vector3).distance_to(cur)
			var bpos: = Vector3(pb[0], pb[1], pb[2])\
			+ Vector3(pb[3], pb[4], pb[5]) * t\
			+ Vector3(0.0, -0.5 * Ball.PHYS.gravity * t * t, 0.0)
			var model_ballistic: = bpos.distance_to(cur)
	_bm_prev = {"seq": seq, "b": b}



func _reckon_ball(st: PackedFloat32Array, dt: float) -> Vector3:
	var p: = Vector3(st[0], st[1], st[2])
	if st[6] > 0.5:
		return p
	var v: = Vector3(st[3], st[4], st[5])
	return p + v * dt + Vector3(0.0, -0.5 * Ball.PHYS.gravity * dt * dt, 0.0)








func _interp_ball(render_at: float) -> void :
	if _snap_buf.size() == 0 or not ball.is_inside_tree() or _ball_dead:
		return




	_ball_present_lead_ms = minf(_delay_now, BALL_PRESENT_MAX_MS)\
	if _ball_present else 0.0
	var ball_at: = render_at + _ball_present_lead_ms
	var a: Dictionary = _snap_buf[0]
	var b: Dictionary = _snap_buf[_snap_buf.size() - 1]
	for i in _snap_buf.size():
		if float(_snap_buf[i].hm) <= ball_at:
			a = _snap_buf[i]
			b = _snap_buf[mini(i + 1, _snap_buf.size() - 1)]
	var ba: PackedFloat32Array = a.d.b
	var bb: PackedFloat32Array = b.d.b
	if bb.size() < 9:
		return
	var target: Vector3
	var target_vel: = Vector3(bb[3], bb[4], bb[5])
	var target_curve: = float(bb[7])

	var sa: = float(ba[9]) if ba.size() >= 10 else Ball.STOP_NONE
	var sb: = float(bb[9]) if bb.size() >= 10 else Ball.STOP_NONE
	var target_stop: = sb
	var span: = float(b.hm) - float(a.hm)
	if span > 1.0:
		var alpha: = clampf((ball_at - float(a.hm)) / span, 0.0, 1.0)
		var ta: = (ball_at - float(a.hm)) / 1000.0
		var tb: = (ball_at - float(b.hm)) / 1000.0
		target_stop = Ball.stop_clock_after(sa, ta)
		if sa > Ball.STOP_NONE + 1.0 or sb > Ball.STOP_NONE + 1.0:



			target = Vector3(ba[0], ba[1], ba[2]).lerp(Vector3(bb[0], bb[1], bb[2]), alpha)
			target_vel = Vector3(ba[3], ba[4], ba[5]).lerp(Vector3(bb[3], bb[4], bb[5]), alpha)
		else:
			target = _reckon_ball(ba, ta).lerp(_reckon_ball(bb, tb), alpha)
			var va: = Vector3(ba[3], ba[4], ba[5])\
			- Vector3(0.0, Ball.PHYS.gravity * ta, 0.0)
			var vb: = Vector3(bb[3], bb[4], bb[5])\
			- Vector3(0.0, Ball.PHYS.gravity * tb, 0.0)
			target_vel = va.lerp(vb, alpha)
		target_curve = lerpf(ba[7], bb[7], alpha)
	else:



		var age: = maxf((ball_at - float(b.hm)) / 1000.0, 0.0)
		var state: = _ball_exact(Vector3(bb[0], bb[1], bb[2]), 
			Vector3(bb[3], bb[4], bb[5]), bb[7], age, sb)
		target = state[0]
		target_vel = state[1]
		target_curve = state[2]
		target_stop = state[3]



	if not _ball_event_flight.is_empty():
		var event_n: = float(_ball_event_flight.n)






		if ba[8] >= event_n and ball_at >= float(a.hm):
			_ball_event_flight.clear()
		elif ball_at >= float(_ball_event_flight.hm):
			var event_age: = (ball_at - float(_ball_event_flight.hm)) / 1000.0
			var event_state: = _ball_exact(_ball_event_flight.p, 
				_ball_event_flight.v, float(_ball_event_flight.c), event_age, 
				float(_ball_event_flight.get("sc", Ball.STOP_NONE)))
			target = event_state[0]
			target_vel = event_state[1]
			target_curve = event_state[2]
			target_stop = event_state[3]
	ball.vel = target_vel
	ball.curve = target_curve
	ball.stop_clock = target_stop








	if _ball_offset_armed:
		_ball_offset_armed = false
		_ball_vis_offset = ball.global_position - target
		if _ball_vis_offset.length() > BALL_HANDOFF_MAX:
			_ball_vis_offset = Vector3.ZERO
	if _ball_vis_offset != Vector3.ZERO:
		ball.global_position = target + _ball_vis_offset
		_ball_vis_offset *= exp( - get_physics_process_delta_time() * BALL_HANDOFF_RATE)
		if _ball_vis_offset.length() < 0.01:
			_ball_vis_offset = Vector3.ZERO
		_ball_handoff = 0.0
		return
	if ball.global_position.distance_to(target) > 3.0:

		ball.reset_physics_interpolation()
		ball.global_position = target
	elif _ball_handoff > 0.0:


		_ball_handoff = maxf(_ball_handoff - get_physics_process_delta_time(), 0.0)
		ball.global_position = ball.global_position.lerp(target, 
			minf(1.0, get_physics_process_delta_time() * 6.0))
	else:
		ball.global_position = target

func _reconcile_ball(data: Dictionary) -> void :
	if not ball.is_inside_tree():




		return




	var b: PackedFloat32Array = data.b








	if b.size() > 8:
		if b[8] < _ball_host_strikes:
			return
		_ball_host_strikes = b[8]
	var was_frozen: = ball.frozen
	ball.frozen = b[6] > 0.5
	if ball.frozen:
		ball.curve = b[7]
		return


	if _ball_grace > 0.0:
		if _ball_host_strikes != _ball_grace_seq:
			_ball_grace = 0.0
		else:
			return
	if _ball_interp:


		return
	var age: = Net.peer_rtt_ms(1) * 0.0005



	var _st: = _ball_exact(Vector3(b[0], b[1], b[2]), 
		Vector3(b[3], b[4], b[5]), b[7], age)
	var host_pos: Vector3 = _st[0]
	var host_vel: Vector3 = _st[1]
	var err: = host_pos - ball.global_position

	if _net_log and data.has("sq"):
		_measure_ball_model(data, age, err.length())







	if was_frozen or err.length() > BALL_DESYNC_SNAP:
		ball.global_position = host_pos
		ball.vel = host_vel
		ball.curve = _st[2]
		ball.reset_physics_interpolation()
		_ball_err = Vector3.ZERO
	else:
		_ball_err = err



func _reconcile_seats(data: Dictionary) -> void :
	if _net_role != NetRole.CLIENT:
		return
	for seat in _seats:
		var body: Player = seat.body
		var pred = seat.get("pred")
		if pred == null or not is_instance_valid(body):
			continue
		var state: = _pstate(data.p, _all_players.find(body))
		if state.is_empty():
			continue
		body.touch_barred = ((int(state[11]) >> 10) & 1) == 1
		body.touch_barred_self = ((int(state[11]) >> 14) & 1) == 1
		body.rivals_can_play = state.size() <= 24 or ((int(state[24]) >> 16) & 1) == 1
		var ack: = int(data.ack.get(_seat_pid(seat), 0))
		var err_v: Variant = pred.measure(ack, Vector3(state[0], state[1], state[2]))
		if err_v == null:
			continue
		var err: Vector3 = err_v
		if err.length() > HARD_SNAP_DIST or (state[13] > 0.0 and not body.knocked()):
			body.net_force_state(state)
			pred.reset()
		else:
			pred.commit(err, ack)

func _reconcile_local(data: Dictionary) -> void :

	if _spectating:
		return
	var state: = _pstate(data.p, _all_players.find(player))
	if state.is_empty():
		return



	player.touch_barred = ((int(state[11]) >> 10) & 1) == 1
	player.touch_barred_self = ((int(state[11]) >> 14) & 1) == 1


	player.rivals_can_play = state.size() <= 24 or ((int(state[24]) >> 16) & 1) == 1



	if state.size() > 22:
		player.set("_settle_time", float(state[22]))



	var ack: = int(data.ack.get(_local_pid(), 0))
	var host_pos: = Vector3(state[0], state[1], state[2])
	var err_v: Variant = _pred.measure(ack, host_pos)
	if err_v == null:
		return
	var err: Vector3 = err_v
	var host_knocked: bool = state[13] > 0.0
	if err.length() > HARD_SNAP_DIST or (host_knocked and not player.knocked()):

		player.net_force_state(state)
		_pred.reset()
	else:
		_pred.commit(err, ack)




func interp_delay() -> float:
	return clampf(_snap_gap_max * INTERP_GAP_MULT + INTERP_GAP_MARGIN, 
		INTERP_DELAY_MIN, INTERP_DELAY_MAX)

func _client_interp() -> void :


	var dt: = get_physics_process_delta_time()
	_tick_dead_ball_visual(dt)
	if _snap_buf.size() == 0:
		return



	if _clock_offset == INF:
		return






	var clock_err: = absf(_clock_offset - _clock_offset_min)
	var slew: = CLOCK_SLEW if clock_err < 40.0\
	else lerpf(CLOCK_SLEW, CLOCK_SLEW_FAST, clampf(clock_err / 300.0, 0.0, 1.0))
	_clock_offset = move_toward(_clock_offset, _clock_offset_min, slew * dt)
	_delay_now = move_toward(_delay_now, interp_delay(), DELAY_SLEW * dt)
	var render_at: = float(Time.get_ticks_msec()) - _clock_offset - _delay_now
	_render_host_ms = render_at



	NetSync.interp_world(_snap_buf, render_at, _all_players, PSTATE_FLOATS, 
		func(body: Player) -> bool: return _is_local_body(body), 
		EXTRAPOLATE_MAX, _interp_hard)


	if _ball_interp and ball.net_puppet and _toss_visual_state.is_empty():
		_interp_ball(render_at)
	if _interp_hard:
		ball.reset_physics_interpolation()
		player.reset_physics_interpolation()
	_interp_hard = false

func _on_net_event(kind: String, args: Dictionary) -> void :
	match kind:
		"strike":








			_music_heat_touch(Net.ev_i(args, "k", Player.TouchKind.NONE), 
				Net.ev_f(args, "w", 0.0), Net.ev_b(args, "sv", false))
			var own_confirmed: = Net.ev_i(args, "id", -1)\
			== int(_net_ids.get(player, -2))
			var accepted_body: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
			if accepted_body != null:
				accepted_body.present_authoritative_touch(
					Net.ev_i(args, "k", Player.TouchKind.NONE) as Player.TouchKind, 
					Net.ev_f(args, "hs", 0.0), Net.ev_v3(args, "bv"), Net.ev_b(args, "sd", false))




			if ball != null and ball.net_puppet:
				ball.hitstop_left = maxf(ball.hitstop_left, Net.ev_f(args, "hs", 0.0))


			if own_confirmed\
			and Net.ev_i(args, "k", -1) == Player.TouchKind.SPIKE\
			and Net.ev_f(args, "hs", 0.0) > 0.0:
				camera_rig.shake(minf(0.12 + Net.ev_f(args, "hs", 0.0) * 2.0, 0.4))


			if own_confirmed and Net.ev_i(args, "k", -1) == Player.TouchKind.CAROM:
				camera_rig.shake(0.08 + 0.18 * Net.ev_f(args, "w", 0.0))
			if own_confirmed and ball.net_puppet:



				player.touch_seq += 1
			elif not own_confirmed and reach_marker != null:



				reach_marker.authoritative_touch(false)
			if own_confirmed and _pred_strike_mutes > 0:



				_pred_strike_mutes -= 1
				_adopt_strike_flight(args, false)
			else:


				ball.combo_tier = Net.ev_i(args, "cb", 0)
				ball.dig_weight = Net.ev_f(args, "rw", 0.0)


				_on_ball_struck(Net.ev_v3(args, "p"), Net.ev_f(args, "w"), 
					Net.ev_i(args, "k"), Net.ev_v3(args, "bv"))
				ball.pulse()
				_adopt_strike_flight(args, not own_confirmed)


			if own_confirmed and player != null:
				player.confirm_own_touch(Net.ev_i(args, "k", Player.TouchKind.NONE) as Player.TouchKind)
		"bounce":
			if _practice != null:





				_adopt_bounce_flight(args)
				ball.stop_float()
				var p_impact: = Net.ev_f(args, "is", 
					Net.ev_v3(args, "bv").length() / maxf(Ball.PHYS.floor_bounce, 0.1))
				ball.floor_squash(p_impact)
				_bounce_fx(Net.ev_v3(args, "p"), p_impact)
				return
			if _ball_dead:
				return




			var marker_was_lit: = reach_marker != null\
			and (reach_marker.state() == ReachMarker.State.READY\
			or reach_marker.state() == ReachMarker.State.QUEUED)
			if _net_log and reach_marker != null\
			and reach_marker.state() == ReachMarker.State.READY:




				_dbg_unfair_floor += 1




			if marker_was_lit:
				reach_marker.authoritative_touch(false)



			if _net_log and _ball_grace > 0.0:
				_dbg_rejected_touch += 1
			_ball_dead = true
			_client_rally_fresh = false
			_ball_grace = 0.0
			_pred_strike_mutes = 0
			if player != null:
				player.contact_enabled = false
				player.cancel_contact()
			_adopt_bounce_flight(args)
			ball.stop_float()

			var impact: = Net.ev_f(args, "is", 
				Net.ev_v3(args, "bv").length() / maxf(Ball.PHYS.floor_bounce, 0.1))
			ball.floor_squash(impact)
			_bounce_fx(Net.ev_v3(args, "p"), impact)
		"toss":


			if _ball_dead or not _client_rally_fresh:
				_client_new_rally()
			var tossing_body: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
			if tossing_body != null:
				tossing_body.present_serve_toss()
			hud.rally_fade(true)
		"servestrike":


			if Net.ev_b(args, "j", false):
				crowd.serve_hit()
			else:
				crowd.serve_stop()
		"net":
			_net_hit_fx(Net.ev_f(args, "x"), Net.ev_f(args, "s", 1.0), 
				Net.ev_f(args, "y", 0.5))


			ball.stop_float()
			ball.curve = 0.0
		"antenna":
			_bob_antenna(Net.ev_i(args, "s", 0))
			_antenna_call(Net.ev_i(args, "s", 0))
		"whistle":
			sfx.play("whistle", Net.ev_v3(args, "p"))
		"intro":


			_intro_swoop = Net.ev_b(args, "sw", true)
			if not _intro_swoop:
				_intro_walk_armed = false
		"verdict":
			_show_verdict(Net.ev_v3(args, "p"), Net.ev_s(args, "t", "", 64), 
				Net.ev_i(args, "w", 0))
		"callout":
			var caller: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
			var call_idx: = Net.ev_i(args, "i", 0)



			var own_press: = caller == player and not _spectating\
			and Player.is_quick_chat(call_idx)
			if caller != null and not own_press:
				var cv: = Net.ev_i(args, "v", -1)
				if Net.ev_i(args, "g") == 1:

					caller.gesture_call(call_idx, cv)
					_recorder.cue("callout", 
						{"s": _all_players.find(caller), "i": call_idx, "g": 1, "v": cv})
				else:

					caller.show_callout(call_idx, false, true, cv)
					_recorder.cue("callout", 
						{"s": _all_players.find(caller), "i": call_idx, "v": cv})
		"pa_state":
			var marks: = {}
			for pair in Net.ev_arr(args, "l", 32):
				if pair is Array and (pair as Array).size() == 2:
					marks[pair[0]] = pair[1]
			hud.set_pa_marks(marks)

			if Net.ev_b(args, "off") and not _pa_off:
				_pa_off = true
				_pa_show_off()
		"rally_end":



			_ball_dead = true
			_client_rally_fresh = false
			_ball_grace = 0.0
			_pred_strike_mutes = 0


			crowd.serve_stop()
			if player != null:
				player.contact_enabled = false
				player.cancel_contact()
			_present_rally_end(args)
		"ach":


			if player != null:
				var aid: = Net.ev_i(args, "id")
				var d: Variant = args.get("d", {})
				for each in _ach_locals():
					if aid == int(_net_ids.get(each[0], -1)):
						Achievements.notify_for(each[1], Net.ev_s(args, "e", "", 32), 
							d if d is Dictionary else {})
						break
		"set_end":
			_present_set_end(Net.ev_i(args, "w"))



			_scores = {1: 0, -1: 0}
		"over":
			_present_match_over(Net.ev_i(args, "w"))
		"rematch":





			_stats_built = false
			_match_over = false
			_match_winner = 0
			_pa_off = false



			_intro_swoop = false
			_scores = {1: 0, -1: 0}
			_set_wins = {1: 0, -1: 0}
			_set_number = 1
			_sand_set = -1

			_match_rallies = 0
			_ach_sets.clear()
			_ach_no_rematch.clear()
			Rules.set_swapped = false
			_pending_set = {}
			_music_heat = 0
			_music_opener = false
			MusicManager.set_floor(0)
			MusicManager.set_intensity(0)
			hud.hide_match_stats()
			hud.hide_cine_name()
			hud.set_loading(1.0)
		"replay_go":
			_replay_focus = Net.ev_v3(args, "f")
			_replay_lead = Net.ev_f(args, "ld")
			if _phase == Phase.REPLAY:
				_setup_director()
		"sweat":

			_net_sweat = clampf(Net.ev_f(args, "v", 0.0), 0.0, 1.0)
		"blockbreak":
			fx.shield_crack(Net.ev_v3(args, "p"))
			crowd.shock(0.95)
			var bb: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
			if bb != null:
				bb.show_float_text("block broken!", BREAK_COLOR, true)
		"voice":
			var vb: Player = _by_net_id.get(Net.ev_i(args, "id", 0))
			if vb != null:
				sfx.play(Net.ev_s(args, "b", "", 32), 
					vb.global_position + Vector3(0.0, 1.4, 0.0), -3.0, 
					clampf(Net.ev_f(args, "p", 1.0), 0.5, 2.0))
		"skip_tally":
			hud.set_replay_banner(true, Net.ev_i(args, "n", 0), 
				Net.ev_i(args, "k", 1))
		"skip_done":
			hud.set_replay_banner(false, 0, 0)
		"to_lobby":

			var pa_off: = Net.ev_b(args, "pa")
			if pa_off:
				GameConfig.lobby_notice = PA_NO_REMATCH
			if Net.i_am_fold():




				Net.leave()

				GameConfig.lobby_notice = PA_NO_REMATCH if pa_off else "the host left the match"
				hud.hide_match_stats()
				UiWipe.wipe(get_tree(), func():
					_go_menu())
			else:
				_leave_to_lobby()
		"serve":
			if _practice != null:
				_practice.ball_called(Net.ev_s(args, "sk", "", 32))
			_hide_landing_call()
			_interp_hard = true
			_snap_buf.clear()
			crowd.serve_build()
		"reset":
			_interp_hard = true
			_snap_buf.clear()
			var rr: Array = args.get("r", [])
			if rr.size() == 2:
				_rot = {1: int(rr[0]), -1: int(rr[1])}
		"wipe":





			_play_wipe( func():
				if MIGRATION_COVER.dismiss():
					_loading_up = false
					hud.set_loading(0.0)
					hud.flash_banner("rally restarted"), 
				Net.ev_s(args, "v", "", 24))
		"pdead":

			if _practice != null:
				_practice.paint_dead(Net.ev_b(args, "on"))
		"pside":


			for pair in Net.ev_arr(args, "l", 32):
				if not (pair is Array) or (pair as Array).size() != 2:
					continue
				var body: Player = _by_net_id.get(Net.ni(pair[0]))
				if body != null:
					body.team_side = clampi(Net.ni(pair[1]), -1, 1)
			if _practice != null:
				_practice.local_sides_changed()
			elif player != null:
				camera_rig.home_side = float(player.team_side)
				ball.home_side = float(player.team_side)
		"sides":



			_begin_dissolve(SWAP_HOLD, SWAP_FADE)
			for pair in Net.ev_arr(args, "l", 32):
				if not (pair is Array) or (pair as Array).size() != 2:
					continue
				var body: Player = _by_net_id.get(Net.ni(pair[0]))
				if body != null:



					body.team_side = clampi(Net.ni(pair[1]), -1, 1)
			camera_rig.home_side = float(player.team_side)
			camera_rig.face_net()
			ball.home_side = float(player.team_side)
			_interp_hard = true
			_snap_buf.clear()



			_flush_motion_state()
		"arrive":
			hud.notice("%s joined as a spectator" % Net.ev_s(args, "who", "someone", 64))
		"seat":
			_on_seat_event(args)

			if args.has("who") and not (Net.ev_i(args, "p", 0) == 0
					and Net.ev_i(args, "was", 0) == _local_pid()):
				_announce_seat(Net.ev_s(args, "who", "", 64), 
					Net.ev_i(args, "side", 0), null)
		"float":
			var body: Player = _by_net_id.get(Net.ev_i(args, "id"))
			var ftext: = Net.ev_s(args, "t", "", 48)
			var fcol_s: = Net.ev_s(args, "c", "ffffff", 9)
			var fcol: = Color.html(fcol_s) if Color.html_is_valid(fcol_s) else Color.WHITE
			var fpr: = Net.ev_b(args, "pr")
			if body != null and body != player:
				body.show_float_text(ftext, fcol, fpr)
			elif body == player and fpr:

				body.show_float_text(ftext, fcol, fpr)
		"combo":
			var cbody: Player = _by_net_id.get(Net.ev_i(args, "id"))
			if cbody != null:
				var cfail: = Net.ev_b(args, "f")


				cbody.show_combo_local(Net.ev_i(args, "n"), cfail)
				_combo_sfx(Net.ev_i(args, "n"), cfail, cbody.global_position, Net.ev_b(args, "h"))






				_recorder.cue("combo", 
					{"s": _all_players.find(cbody), "n": Net.ev_i(args, "n"), "f": cfail})
		"thump":
			var own_thump: = Net.ev_i(args, "id", -1)\
			== int(_net_ids.get(player, -2))
			var now: = Time.get_ticks_msec()
			while not _pred_thumps.is_empty()\
			and now - int((_pred_thumps[0] as Dictionary).get("t", 0)) > 2000:
				_pred_thumps.pop_front()
			if own_thump and not _pred_thumps.is_empty():
				_pred_thumps.pop_front()
			else:
				_present_thump(Net.ev_v3(args, "p"), Net.ev_f(args, "s"))
		"launch":
			var lp: = Net.ev_v3(args, "p")
			var lc: = Net.ev_f(args, "c")
			fx.ring(lp, Vector3.UP, 1.15 * lc)
			fx.puff(lp)
			if lc >= 1.5:

				fx.bam_swirl(lp, lc, _by_net_id.get(Net.ev_i(args, "id", 0)))
			sfx.play("hit_soft", lp, -4.0, 1.35)
		"bump_fx":
			var bp: = Net.ev_v3(args, "p")
			sfx.play("block_soft", bp, -4.0)
			fx.impact(bp, 0.7, Vector3.UP)
			fx.puff(bp)
		"swing_fx":


			sfx.play("swing", Net.ev_v3(args, "p"), -5.0, 1.0)
		"squash_fx":


			_squash_fx(Net.ev_v3(args, "p"), _by_net_id.get(Net.ev_i(args, "v", 0)))


			if not _spectating and Net.ev_i(args, "v", 0) == _net_ids.get(player, -1):
				camera_rig.shake(0.5)
		"cheer":
			crowd.cheer(Net.ev_f(args, "a", 0.5))
		"shock":
			crowd.shock(Net.ev_f(args, "a", 0.8))
		"slowmo":
			fx.slowmo(0.35, 0.8)
		"stats":
			hud.store_stat_rows(Net.ev_arr(args, "r", 32))
		"left":
			var body: Player = _by_net_id.get(Net.ev_i(args, "id"))
			var lname: = Net.sanitize_name(Net.ev_s(args, "n", "player", 64))
			if body != null:
				_names[body] = _cpu_tagged(lname)
				body.set_display_name(_names[body])
				body.set_dev_tag(DevBadge.Tier.NONE)



				body.is_bot = true
				_seat_owner.erase(body)
				_cpu_diff[body] = Net.cpu_difficulty
			hud.notice("%s has left the game" % lname)
		"seat_no":


			var no_p: = Net.ev_i(args, "p", 0)
			if no_p < 0 and _pid_owner(no_p) == _local_pid():
				var text: = _seat_no_text(Net.ev_s(args, "why", "", 16), 
					clampi(Net.ev_i(args, "t", 0), -1, 1), clampi(Net.ev_i(args, "mine", 0), -1, 1))
				if text != "":
					hud.notice("P%d: %s" % [_pid_ls(no_p) + 1, text])
			if no_p == _local_pid():
				_seat_asked = SEAT_NONE
				var theirs: = clampi(Net.ev_i(args, "mine", 0), -1, 1)
				_note_team(_local_pid(), theirs)
				_tell_seat_no(Net.ev_s(args, "why", "", 16), 
					clampi(Net.ev_i(args, "t", 0), -1, 1), theirs)
		"tm":


			_note_team(Net.ev_i(args, "p", 0), clampi(Net.ev_i(args, "t", 0), -1, 1))

func _present_rally_end(args: Dictionary) -> void :


	if not (args.get("w") is int and args.get("s1") is int and args.get("s2") is int):
		return
	var winner: = clampi(int(args.w), -1, 1)
	_scores[1] = clampi(int(args.s1), 0, 999)
	_scores[-1] = clampi(int(args.s2), 0, 999)



	_match_rallies += 1




	var fhero: Player = _by_net_id.get(Net.ev_i(args, "sc", 0))
	var fvillain: Player = _by_net_id.get(Net.ev_i(args, "bl", 0))
	var feed: = _feed_data(fhero, fvillain, Net.ev_s(args, "kind", "", 24))
	hud.point_moment(winner, _team_identity(1), Net.ev_s(args, "r", "", 64), 
		int(_scores[1]), int(_scores[-1]), feed)
	_point_cam(fhero)


	var ann: = Net.ev_s(args, "ann", "", 32)
	if ann != "":
		hud.announce_moment(ann, clampi(Net.ev_i(args, "as", 0), -1, 1))


	_music_rally_end(Net.ev_b(args, "rp", false))

func _present_set_end(winner_id: int) -> void :
	if player != null:
		_ach_set_end( func(body: Player): return winner_id == _team_identity(body.team_side))





func _present_match_over(winner_side: int) -> void :







	if player != null and not _match_over:
		_ach_set_end( func(body: Player): return winner_side == body.team_side)
	_match_winner = winner_side
	_match_over = true





	_save_match_replay()

func _leave_to_lobby() -> void :



	Net.end_match()
	UiWipe.wipe(get_tree(), func():
		_go_menu())









func _park_ball() -> void :
	_pre_intro = true
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.visible = false

func _start_intro() -> void :
	_phase = Phase.INTRO
	_cine_time = 0.0
	_grabbed_home = false
	_park_ball()


	_intro_swoop = _intros_run == 0
	_intros_run += 1
	_net_event("intro", {"sw": _intro_swoop})
	_intro_reset()
	_intro_walk_armed = _intro_swoop
	if _intro_swoop:
		_layout_walk_on()
	else:
		_layout_showcase()
	camera_rig.cinematic = true
	camera_rig.cine_snap = true




var _intro_skipping: = false

func _skip_intro() -> void :
	if _intro_skipping:
		return
	_intro_skipping = true
	_park_ball()
	_point_wipe( func():
		_intro_skipping = false
		_loading_up = false
		hud.set_loading(0.0)
		_start_countdown())


func _intro_reset() -> void :
	_ensure_captains()
	_intro_fired.clear()
	_intro_follow.clear()
	_intro_walk_w1.clear()
	_intro_walked.clear()




func _intro_plan() -> Dictionary:
	var nh: = maxi(_team_players(HOME_SIDE).size(), 1)
	var na: = maxi(_team_players( - HOME_SIDE).size(), 1)
	var sw: = INTRO_SWOOP if _intro_swoop else 0.0
	var per_h: = clampf(INTRO_SPOT_TEAM / nh, INTRO_SPOT_MIN, INTRO_SPOT_MAX)
	var per_a: = clampf(INTRO_SPOT_TEAM / na, INTRO_SPOT_MIN, INTRO_SPOT_MAX)
	var t_whip: = sw + INTRO_SLAB + nh * per_h
	var t_away: = t_whip + INTRO_WHIP
	return {"sw": sw, "per_h": per_h, "per_a": per_a, "t_whip": t_whip, 
		"t_away": t_away, "end": t_away + INTRO_SLAB + na * per_a}







func _layout_walk_on() -> void :
	var n: = GameConfig.team_size
	for p in _all_players:
		var member: Player = p
		var s: = member.team_side
		var k: = _intro_index(member)
		var spot: = _showcase_spot(k, n, s)
		member.global_position = Vector3(spot.x, 0.0, 
			s * (_half_l + 1.8 + INTRO_WALK_BACK + (k % 2) * 0.9))

		member.velocity = Vector3(0.0, 0.0, - s * Player.FEEL.move_speed * INTRO_WALK_SPEED)
		member.visual.rotation.y = PI if s > 0 else 0.0
		member.reset_physics_interpolation()






func _intro_walk_input(body: Player) -> PlayerInput:
	if not _intro_walk_armed or not _intro_swoop or body == null or _intro_walked.get(body, false):
		return null
	var s: = body.team_side
	var spot: = _showcase_spot(_intro_index(body), GameConfig.team_size, s)
	var w1: = spot + Vector3(0.0, 0.0, s * 1.0)
	var at: = Vector3(body.global_position.x, 0.0, body.global_position.z)
	if not _intro_walk_w1.get(body, false) and at.distance_to(w1) < 0.45:
		_intro_walk_w1[body] = true
	var left: = 0.0
	var goal: = spot
	if _intro_walk_w1.get(body, false):
		left = at.distance_to(spot)
	else:
		goal = w1
		left = at.distance_to(w1) + w1.distance_to(spot)
	var deadline: = INTRO_SWOOP + 0.2
	var to_spot: = at.distance_to(spot)
	if to_spot < INTRO_STOP_DIST or _cine_time > deadline + 2.0:
		_intro_walked[body] = true
		return null
	var dir: = goal - at
	dir.y = 0.0
	var speed: = Player.FEEL.move_speed
	var mag: = clampf(left / (maxf(deadline - _cine_time, 0.25) * speed), 
		INTRO_WALK_SPEED, 1.0)

	mag *= clampf(to_spot / INTRO_STOP_EASE, 0.5, 1.0)
	var walk: = PlayerInput.new()
	var d: = dir.normalized() * mag



	if _cine_time < 0.25 and Vector2(body.velocity.x, body.velocity.z).length() < 0.5:
		body.velocity = Vector3(d.x, 0.0, d.z).normalized() * speed * INTRO_WALK_SPEED
	walk.move = Vector2(d.x, d.z)
	walk.aim = spot + Vector3(0.0, 0.0, - s * 4.0)
	return walk

func _layout_showcase() -> void :

	var n: = GameConfig.team_size
	for p in _all_players:
		var member: Player = p
		member.global_position = _showcase_spot(_intro_index(member), n, member.team_side)
		member.velocity = Vector3.ZERO

		member.visual.rotation.y = PI if member.team_side > 0 else 0.0
		member.reset_physics_interpolation()









func _showcase_spot(index: int, n: int, side: int) -> Vector3:
	var frac: = (float(index) + 0.5) / float(maxi(n, 1))
	var x: = float(side) * lerpf(_half_w - 1.4, - _half_w + 1.4, frac)
	return Vector3(x, 0.0, side * _half_l * 0.5)





func _intro_index(body: Player) -> int:
	return maxi(_captain_first(_team_players(body.team_side)).find(body), 0)

func _intro_tick(delta: float) -> void :
	_cine_time += delta
	if _cine_time >= float(_intro_plan().end):
		_start_countdown()

var _finale_tip_shown: = false

func _start_countdown() -> void :


	hud.grab_dissolve()
	_phase = Phase.COUNTDOWN


	if GameConfig.tutorial_finale and not _finale_tip_shown:
		_finale_tip_shown = true
		hud.notice("you can leave this match at any time by opening the pause menu!", 
			hud.NOTICE_SECS, true)


	_start_recording()
	_cine_time = 0.0
	camera_rig.cinematic = false
	_prepare_serve()
	_pre_intro = false
	ball.visible = true

func _countdown_tick(delta: float) -> void :
	_cine_time += delta



	if _server != null:
		ball.global_position = _server.serve_cradle_point()
		ball.vel = Vector3.ZERO
	if _cine_time >= COUNTDOWN_TIME:
		_did_intro = true
		_intro_locked = false
		hud.hide_cinematics()
		sfx.play("whistle", Vector3.ZERO)
		_net_event("whistle", {"p": Vector3.ZERO})
		_begin_serve(false)



func _start_win(winner_side: int, covered: = false) -> void :


	_replay_pending = false
	_save_match_replay()


	if not covered:
		hud.grab_dissolve()
	_match_winner = winner_side
	_match_over = true
	_stats_built = false
	_win_reset()
	_win_grabbed = not covered
	_phase = Phase.WIN
	_cine_time = 0.0
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.visible = false



	_hide_landing_call()
	ball.show_landing_ring = false


	var winners: = _team_players(winner_side)
	for i in winners.size():
		var m: Player = winners[i]
		m.global_position = _win_spot(i, winners.size(), winner_side)
		m.velocity = Vector3.ZERO
		m.visual.rotation.y = PI if winner_side > 0 else 0.0
		m.clear_action_state()
		m.reset_physics_interpolation()




	var losers: = _team_players( - winner_side)
	for i in losers.size():
		var m: Player = losers[i]


		m.global_position = _win_spot(i, losers.size(), - winner_side)
		m.velocity = Vector3.ZERO
		m.visual.rotation.y = PI if - winner_side > 0 else 0.0
		m.clear_action_state()
		m.reset_physics_interpolation()
	camera_rig.cinematic = true
	camera_rig.cine_snap = true

func _win_tick(delta: float) -> void :
	_cine_time += delta
	if _cine_time >= float(_win_plan().end):
		_phase = Phase.STATS

func _win_plan() -> Dictionary:
	return {"end": WIN_GROUP_TIME}

var _win_fired: = {}



var _win_grabbed: = false

func _win_reset() -> void :
	_win_fired.clear()
	for p in _all_players:
		(p as Player).set_mvp_badge(false)
	_intro_follow.clear()

func _win_once(key: String) -> bool:
	if _win_fired.has(key):
		return false
	_win_fired[key] = true
	return true



func _win_mvp() -> Player:
	var key: = _win_mvp_key()
	if key == "":
		return null
	for p in _team_players(_match_winner):
		var b: = p as Player
		if "%d:%s" % [_team_identity(b.team_side), String(_names.get(b, ""))] == key:
			return b
	return null

func _win_mvp_key() -> String:
	var rows: Array = _stat_rows() if _net_role != NetRole.CLIENT else hud.stored_stat_rows()
	return String(Rules.team_mvps(rows).get(_team_identity(_match_winner), ""))



func _play_local_reach(bank: String, volume_db: float, pitch: = 1.0) -> void :



	if _phase == Phase.REPLAY:
		return
	sfx.play(bank, player.global_position, volume_db, pitch)

func _start_recording() -> void :
	_keep_match_for_reports()
	_rec_started_ms = Time.get_ticks_msec()
	_match_token = "%d_%d" % [int(Time.get_unix_time_from_system()), randi()]
	_match_sids = _room_sids()
	var slot_info: Array = []
	for p in _all_players:
		var body: Player = p



		var look: CharacterConfig = body.character
		slot_info.append({
			"name": String(_names.get(body, "player")), 
			"side": body.team_side, 
			"slot": int(_slots.get(body, 0)), 
			"is_bot": body.is_bot, 
			"is_you": body == player, 
			"cfg": look.to_dict() if look != null else {}, 
			"kit": body.replay_kit.map(
				func(c): return (c as Color).to_html(false)), 
			"tint": _team_color(body.team_side, 
				int(_slots.get(body, 0))).to_html(false), 


			"pinny": look.pinny_color.to_html(false)\
			if look != null and look.wear_pinny else "", 
			"pinny_acc": look.pinny_accent.to_html(false)\
			if look != null and look.wear_pinny else "", 
		})
	_recorder.begin(_all_players, slot_info, ball, {
		"team_size": GameConfig.team_size, 
		"stage": GameConfig.stage, 


		"tod": Stage.tod_index(Stage.resolve(GameConfig.stage)), 

		"outfit": DressCode.rule_now(), 

		"half_w": _half_w, "half_l": _half_l, 
		"set_points": GameConfig.set_points, 
		"sets_to_win": GameConfig.sets_to_win, 
		"recorded_at": Time.get_datetime_string_from_system(), 
		"online": _net_role != NetRole.OFFLINE, 




		"match_seed": GameConfig.match_seed, 
		"school_accent": _last_accent, 
		"court_tape": _last_tape, 
		"has_tape": _has_tape, 
	})

	sfx.recorder = _recorder
	fx.recorder = _recorder
	crowd.recorder = _recorder
	ball.recorder = _recorder
	_replay_saved = false
	_last_replay_path = ""

	Reports.match_replay = _recorder.data if _net_role != NetRole.OFFLINE else null

func _contact_fx(pos: Vector3, strength: float, axis: Vector3, kind: = -1, 
		combo_tier: = 0) -> void :




	Rules.contact_fx(fx, pos, strength, axis, _sweat_shown, true, kind, combo_tier)

func _replay_fire(c: Dictionary) -> void :


	_recorder.replaying = true


	ReplayCues.play(c, sfx, fx, crowd, ball, _all_players, false)
	_recorder.replaying = false

func _replay_sfx_rewind() -> void :
	_replay_sfx_at = 0
	var evs: Array = _recorder.data.events
	while _replay_sfx_at < evs.size()\
	and float(evs[_replay_sfx_at]["t"]) < _director.time:
		_replay_sfx_at += 1

func _replay_sfx_tick() -> void :
	var evs: Array = _recorder.data.events
	while _replay_sfx_at < evs.size()\
	and float(evs[_replay_sfx_at]["t"]) <= _director.time:
		_replay_fire(evs[_replay_sfx_at])
		_replay_sfx_at += 1

func _replay_humans() -> int:


	if _net_role == NetRole.OFFLINE:
		return 1 + _seats.size()
	return _peer_players.size() + 1 + _seats.size()

func _skips_needed() -> int:
	return int(ceil(_replay_humans() / 2.0))





func _point_wipe(mid: = Callable(), variant: = "") -> void :
	if variant == "":
		variant = POINT_WIPE.variant_for_stage(GameConfig.stage)





	_net_event("wipe", {"v": variant})
	_play_wipe(mid, variant)



func _play_wipe(mid: = Callable(), variant: = "") -> void :
	if variant == "":
		variant = POINT_WIPE.variant_for_stage(GameConfig.stage)
	_rally.serve_locked = true
	POINT_WIPE.play(get_tree(), mid, 0.0, variant, 
		func(): _rally.serve_locked = false)

func _enter_replay() -> void :
	if _recorder.data.frame_count() < 4:
		_replay_pending = false
		return




	_replay_starting = true
	_point_wipe(_do_enter_replay)

func _do_enter_replay() -> void :
	_replay_pending = false
	_replay_starting = false
	_phase = Phase.REPLAY
	_skip_votes.clear()
	_voted_skip = false
	for seat in _seats:
		seat["voted"] = false
	_input_collector.clear_buffers()



	if aim_indicator.net_mat != null:
		aim_indicator.net_mat.set_shader_parameter("cut_radius", 0.0)
		aim_indicator.net_mat.set_shader_parameter("cut2_radius", 0.0)


	aim_indicator.visible = false
	for seat in _seats:
		if seat.get("aim") != null and is_instance_valid(seat.aim):
			seat.aim.visible = false
	_replay_lead = minf(REPLAY_LEAD, _rally_time + 1.0) + REPLAY_TAIL
	_setup_director()





	if _sand_deform != null:
		_sand_deform.restore()



	_net_event("replay_go", {"f": _replay_focus, "ld": _replay_lead})
	hud.set_replay_banner(true, 0, _skips_needed())

func _setup_director() -> void :
	_director.setup(_recorder.data, _all_players, ball)


	if _replay_lead <= 0.0:


		_replay_lead = minf(REPLAY_LEAD, _rally_time + 1.0) + REPLAY_TAIL
	_director.seek_clip(_recorder.window_start_time(_replay_lead))
	_director.playing = true
	_director.speed = 1.0
	_replay_shot = -1
	_replay_cam_side = 0.0
	_replay_on_land = false
	_replay_sfx_rewind()





	if _puppet_saved.is_empty():


		_ball_puppet_saved = ball.net_puppet
		for p in _all_players:
			_puppet_saved.append((p as Player).net_puppet)
	_replay_prev_t = _director.time
	_replay_cur_t = _director.time
	for p in _all_players:
		var body: Player = p
		body.net_puppet = true
		body.cinematic_hidden = true
		body.suppress_names(true)
		body.hide_combo()
		body.hide_callout()

func _replay_tick(delta: float) -> void :


	_director.advance(minf(delta, 0.05))
	_replay_prev_t = _replay_cur_t
	_replay_cur_t = _director.time



	if _director.finished():
		_exit_replay()

func _exit_replay() -> void :
	if _phase != Phase.REPLAY or _replay_exiting:
		return

	_replay_exiting = true
	_point_wipe(_do_exit_replay)

func _do_exit_replay() -> void :
	_replay_exiting = false
	_phase = Phase.DEAD







	_dead_timer = 0.12


	_input_collector.swallow_held(["jump", "contact", "dive", "serve"])



	_input_collector.clear_buffers()
	hud.set_replay_banner(false, 0, 0)
	_replay_lead = 0.0
	_replay_restore()


	CrowdField.calm()





	if _win_delay > 0.0:
		_win_delay = 0.0
		_start_win(_win_pending, true)
	elif not _pending_set.is_empty():
		_swap_delay = 0.0
		_do_switch_sides()

func _replay_client_tick(delta: float) -> void :









	if not _director.finished():
		_director.advance(minf(delta, 0.05))
	elif replay_loops == 0:
		replay_loops = 1
	_replay_prev_t = _replay_cur_t
	_replay_cur_t = _director.time





	if not _spectating:
		_send_client_input(PlayerInput.new())
	_present_replay(delta)
	hud.set_scoreboard_visible(true)
	_decay_net_wobble(delta)

func _replay_restore() -> void :

	ball.net_puppet = _ball_puppet_saved
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.show_landing_ring = true
	ball.reset_visuals()
	ball.reset_physics_interpolation()
	for i in _all_players.size():
		var body: Player = _all_players[i]





		body.net_puppet = _net_role == NetRole.CLIENT and not _is_local_body(body)
		body.cinematic_hidden = false
		body.suppress_names(false)
		body.hide_callout()
		body.reset_physics_interpolation()
	_puppet_saved.clear()
	_reset_formation()
	_floor_mat.set_shader_parameter("sweat", _sweat_shown)

func _present_replay(delta: float) -> void :

	_director.apply()
	_director.pose_tick(delta)
	_replay_sfx_tick()
	_tick_dissolve(delta)


	_floor_mat.set_shader_parameter("sweat", _director.sweat)


	if _director.sweat > 0.12:
		for p in _all_players:
			if randf() < _director.sweat * 0.22:
				fx.sweat((p as Player).global_position + Vector3(
					randf_range(-0.3, 0.3), randf_range(1.35, 1.7), 
					randf_range(-0.3, 0.3)))
	camera_rig.cinematic = true
	var focus: = ball.global_position
	var side: = signf(focus.z)
	if side == 0.0:
		side = 1.0





	if _replay_cam_side == 0.0:
		_replay_cam_side = 1.0 if side >= 0.0 else -1.0
	var sx: = _replay_cam_side
	var elapsed: = _director.elapsed()
	var shot: = int(elapsed / REPLAY_ANGLE_TIME)
	var snap: = shot != _replay_shot
	_replay_shot = shot



	var to_end: = _director.end_time() - _director.time
	var eye: = Vector3.ZERO
	if to_end < REPLAY_LAND_WINDOW and _replay_focus != Vector3.ZERO:
		focus = _replay_focus + Vector3(0.0, 0.35, 0.0)
		eye = _replay_focus + Vector3(sx * 3.2, 1.3, sx * 1.4)
		snap = snap or not _replay_on_land
		_replay_on_land = true
	else:
		_replay_on_land = false
		match shot % 3:
			0:
				eye = Vector3(sx * (_half_w + 8.0), 5.0, focus.z * 0.5)
			1:
				eye = focus + Vector3(sx * 5.0, 2.2, 0.0)
			_:
				eye = Vector3(sx * (_half_w + 11.0), 8.0, 0.0)
	camera_rig.cine_eye = eye
	camera_rig.cine_target = focus
	camera_rig.cine_snap = snap


	hud.set_play_hud_visible(false)
	hud.set_crosshair_visible(false)
	hud.set_serve_prompt("")
	aim_indicator.visible = false
	barred_marker.visible = false
	ball.landing_ring_muted = false
	_hide_landing_call()
	ball.show_landing_ring = false

func _poll_skip_vote() -> void :



	if _phase != Phase.REPLAY or _voted_skip or _spectating:
		return
	if hud.chat_typing():
		return


	if not LocalPlayers.ui_just_pressed("ui_accept"):
		return
	_voted_skip = true
	if _net_role == NetRole.CLIENT:
		Net.send_up("skip_vote", {})
	else:
		_register_skip_vote(0)



func _poll_seat_skip_votes() -> void :
	if _phase != Phase.REPLAY or _net_role == NetRole.CLIENT:
		return
	for i in _seats.size():
		var seat: Dictionary = _seats[i]
		if bool(seat.get("voted", false)) or not seat.slot.connected:
			continue
		var ui: DeviceInput = seat.get("ui")
		if ui == null:
			ui = DeviceInput.new(seat.slot.device)
			seat["ui"] = ui
		ui.device = seat.slot.device
		ui.poll(["ui_accept"])
		if ui.just_pressed("ui_accept"):
			seat["voted"] = true
			_register_skip_vote( - (i + 1))

func _register_skip_vote(voter: int) -> void :

	if _phase != Phase.REPLAY:
		return

	if voter > 0 and not _peer_players.has(voter):
		return
	_skip_votes[voter] = true
	var needed: = _skips_needed()
	hud.set_replay_banner(true, _skip_votes.size(), needed)
	_net_event("skip_tally", {"n": _skip_votes.size(), "k": needed})
	if _skip_votes.size() >= needed:
		_net_event("skip_done", {})
		_exit_replay()




func _keep_match_for_reports() -> void :
	if _recorder == null or Reports.match_replay == null\
	or Reports.match_replay != _recorder.data:
		return
	Reports.keep_last_match(_recorder.data, _match_sids + _room_sids(), _match_token, 
		_rec_started_ms)

func _room_sids() -> Array:
	var out: Array = []
	for pid in Net.players:
		out.append(Reports.peer_sid(int(pid)))
	return out

func _save_match_replay() -> void :



	if not GameConfig.replay_capture or LaunchGate.is_demo():
		return



	if _replay_saved or _recorder.data.frame_count() < 30:
		return
	_replay_saved = true
	_recorder.stop()
	var stamp: = Time.get_datetime_string_from_system().replace(":", "-")\
	.replace("T", "_")
	var name_part: = "%dv%d" % [GameConfig.team_size, GameConfig.team_size]
	var path: = "%s/%s_%s.vbr" % [REPLAY_DIR, stamp, name_part]
	_recorder.data.meta["duration"] = _recorder.data.duration()
	_recorder.data.meta["title"] = "%s %s" % [name_part, stamp]



	_recorder.data.meta["home_score"] = int(_scores[HOME_SIDE])
	_recorder.data.meta["away_score"] = int(_scores[ - HOME_SIDE])
	_recorder.data.meta["home_sets"] = int(_set_wins[HOME_SIDE])
	_recorder.data.meta["away_sets"] = int(_set_wins[ - HOME_SIDE])
	_recorder.data.save_to(path)

	_last_replay_path = path

func _begin_dissolve(hold: float, fade: float) -> void :





	hud.grab_dissolve()
	_diss_fade = maxf(fade, 0.01)
	_diss_left = hold + _diss_fade

func _tick_dissolve(delta: float) -> void :

	if _diss_left <= 0.0:
		return
	_diss_left -= delta

	hud.set_dissolve(clampf(_diss_left / _diss_fade, 0.0, 1.0))
	if _diss_left <= 0.0:
		_diss_left = 0.0
		hud.set_dissolve(0.0)

func _side_name(side: int) -> String:
	return Rules.side_name(side)










func _team_identity(side: int, set_number: = -1) -> int:
	var sn: = set_number if set_number > 0 else _set_number
	return side if sn % 2 == 1 else - side

const WIN_LINE: = 0.72

func _win_spot(i: int, n: int, side: int) -> Vector3:
	var frac: = (float(i) + 0.5) / float(n)
	var x: = lerpf( - _half_w + 1.4, _half_w - 1.4, frac)
	return Vector3(x, 0.0, side * _half_l * WIN_LINE)

func _present_win(ct: float) -> void :


	var w: = _match_winner
	var winners: = _team_players(w)
	hud.hide_cine_name()
	hud.set_cinema_bars(true)



	if not _intro_names_hidden:
		_intro_names_hidden = true
		for p in _all_players:
			(p as Player).suppress_names((p as Player).team_side != w)
			(p as Player).set_showcase_names((p as Player).team_side == w)


	var clear: = not _wipe_up()
	if ct > 0.15 and clear and _win_once("slab"):
		hud.show_team_slab(_side_name(w) + " wins!", _side_color(w), w != HOME_SIDE)
		crowd.cheer(1.0)
	if ct > WIN_MVP_AT and clear and _win_once("mvp"):


		var m: = _win_mvp()
		if m != null:
			m.set_mvp_badge(true)
			UiStyle.sfx(hud.INTRO_SFX_CARD)
	_win_group_cam(winners, w, clampf(ct / WIN_GROUP_TIME, 0.0, 1.0))
	camera_rig.cine_snap = true
	_cine_want_snap = false
	hud.set_dissolve(clampf(1.0 - ct / WIN_FADE, 0.0, 1.0) if _win_grabbed else 0.0)


func _wipe_up() -> bool:
	for c in get_tree().root.get_children():
		if c is PointWipe:
			return true
	return false





func _win_group_cam(winners: Array, w: int, f: float) -> void :
	if winners.is_empty():
		return
	var n: = winners.size()
	var c: = Vector3.ZERO
	var weight: = 0.0
	var lo: = INF
	var hi: = - INF
	var mvp: = _win_mvp()
	for i in n:
		var b: Player = winners[i]
		var at: = _follow_at(b, _win_spot(i, n, w))

		var k: = WIN_MVP_WEIGHT if b == mvp else 1.0
		c += at * k
		weight += k
		lo = minf(lo, at.x)
		hi = maxf(hi, at.x)
	c /= maxf(weight, 0.01)
	c.y = 0.0
	var spread: = maxf(hi - lo, 0.0) + 1.4
	var e: = f * f * (3.0 - 2.0 * f)
	var dist: = (3.4 + spread * 0.62) * lerpf(1.0, 0.86, e)
	var arc: = lerpf(-0.1, 0.1, e)
	camera_rig.cine_eye = _off_net(c + Vector3(sin(arc) * dist, lerpf(2.5, 2.2, e), 
		- w * cos(arc) * dist), w)
	camera_rig.cine_target = c + Vector3(0.0, 1.05, 0.0)


func _win_wrap_up() -> void :
	for p in _all_players:
		(p as Player).set_mvp_badge(false)
		(p as Player).set_showcase_names(false)
	hud.set_cinema_bars(false)
	hud.hide_team_slab()
	hud.hide_stage_card()
	if _intro_names_hidden:
		_intro_names_hidden = false
		for p in _all_players:
			(p as Player).suppress_names(false)
	if _intro_base_fov > 0.0 and camera_rig.camera != null:
		camera_rig.camera.fov = _intro_base_fov
	_intro_base_fov = 0.0











const PA_WINDOW: = 15.0
const PA_NO_REMATCH: = "not everyone pressed play again"
const PA_OFF_BEAT: = 2.5
var _pa_left: = 0.0
var _pa_grace: = 0.0
var _pa_opted: = false
var _pa_opt: = {}
var _pa_names: = {}
var _pa_off: = false
var _pa_off_t: = 0.0




func _pa_push_states() -> void :
	if _net_role != NetRole.HOST or _pa_names.is_empty():
		return
	var states: = {}
	for pid in _pa_names:


		var pa_name: String = _pa_names[pid]
		if pid == 1:
			pa_name += "  (host)"
		if not Net.players.has(pid):
			states[pa_name] = "out"
		elif _pa_opt.has(pid):
			states[pa_name] = "in"
		else:
			states[pa_name] = "wait"
	hud.set_pa_marks(states)
	var l: = []
	for pa_name in states:
		l.append([pa_name, states[pa_name]])
	_net_event("pa_state", {"l": l, "off": _pa_off})




func _ach_online() -> bool:
	return _net_role == NetRole.CLIENT\
	or (_net_role == NetRole.HOST and not _peer_players.is_empty())

func _quick_post() -> bool:
	return _quick() and _net_role != NetRole.OFFLINE





func _rematch_window() -> bool:
	return _net_role != NetRole.OFFLINE and (_quick() or Net.party)






static func everyone_opted_in(present: Array, opted: Dictionary) -> bool:
	if present.is_empty():
		return false
	for pid in present:
		if not opted.has(pid):
			return false
	return true



func _party_follower() -> bool:
	return Net.party and _net_role == NetRole.CLIENT




func _room_party_member() -> bool:
	var hp: Dictionary = Net.home_party
	return bool(hp.get("room", false)) and not bool(hp.get("is_leader", false))

func _tick_play_again() -> void :
	if not _rematch_window() or not Net.active:
		return


	var delta: = get_physics_process_delta_time()
	if _net_role == NetRole.HOST:


		if not _pa_off and (_pa_left > 0.0 or _pa_grace > 0.0) and _pa_someone_out():
			_pa_off = true
			_pa_off_t = PA_OFF_BEAT
			_pa_grace = 0.0
			_pa_show_off()
			_pa_push_states()
		if _pa_off:
			_pa_off_t -= delta
			if _pa_off_t <= 0.0:
				_pa_disband(true)
			return


		if _pa_left > 0.0 and everyone_opted_in(Net.players.keys(), _pa_opt):
			_pa_left = 0.0
			_pa_grace = 0.3
			hud.set_quick_wait("everyone's in!")
			return
	if _pa_left > 0.0:
		_pa_left -= delta


		var n: = ceili(maxf(_pa_left, 0.0))
		if not _pa_off:
			hud.set_quick_wait(("waiting for everyone else... %d"\
			%n) if _pa_opted else "window closes in %d" % n)
		if _pa_left <= 0.0:
			if _net_role == NetRole.HOST:






				_pa_disband(true)
			else:



				_pa_overdue += delta
				if not _pa_off:
					hud.set_quick_wait("waiting for the host...")
				if _pa_overdue > PA_OVERDUE_S:
					Net.leave()
					hud.hide_match_stats()
					UiWipe.wipe(get_tree(), func():
						_go_menu())
	elif _pa_grace > 0.0 and _net_role == NetRole.HOST:
		_pa_grace -= delta
		if _pa_grace <= 0.0:
			_quick_rematch()




func _pa_someone_out() -> bool:
	for pid in _pa_names:
		if not Net.players.has(pid):
			return true
	if _quick():
		for b in _all_players:
			if b != null and is_instance_valid(b) and bool(b.is_bot) and b.get("vacant") != true:
				return true
	return false


func _pa_show_off() -> void :
	hud.set_play_again("no rematch", true)
	hud.set_quick_wait("someone left, so no rematch")







func _pa_disband(tell_me: bool) -> void :
	_pa_off = false
	_pa_left = 0.0
	_pa_grace = 0.0
	QuickPlay.qlog("play again: no rematch, the lobby disbands (party=%s)" % str(Net.party))
	if tell_me:
		GameConfig.lobby_notice = PA_NO_REMATCH
	if Net.party:
		_net_event("to_lobby", {"pa": true})
		_leave_to_lobby()
		return
	for pid in Net.players.keys():
		if pid != 1:
			Net.refuse_peer(pid, PA_NO_REMATCH)


	get_tree().create_timer(0.5).timeout.connect( func():
		hud.hide_match_stats()
		UiWipe.wipe(get_tree(), func():
			Net.leave()
			_go_menu()))

func _quick_rematch() -> void :



	var ids: = Net.players.keys()
	ids.sort()


	var roster: = Net.match_roster(ids, Net.players, Net.team_size, Net.cpu_slots, 
		Net.captains, not Net.custom_lobby)

	if GameConfig.quick_match:
		PartyMark.tag_roster(roster, Net.players, Net.party_members())
	Net.sync_lobby()
	Net.start_match(roster, randi())

var _rematch_reload: = false
var _pa_overdue: = 0.0
const PA_OVERDUE_S: = 8.0
var _ad_t: = 0.0
var _my_peer_id: = 1
var _migrating: = false
var _migrate_resume: = false
var _gone_bodies: = {}
var _loading_up: = true
var _reveal_a: = 1.0
var _cover_t: = 0.0







const FACES_WAIT: = 4.0
var _faces_warm: = false
var _faces_busy: = false



const REVEAL_TIMEOUT_S: = 8.0
var _replay_stand_off: = false
var _rec_started_ms: = 0


var _match_token: = ""
var _match_sids: Array = []






func _quick_ad_refresh() -> void :
	if _net_role != NetRole.HOST or not _quick()\
	or not Net.in_match:
		return
	var open: = 0
	for p in _all_players:
		if (p as Player).is_bot:
			open += 1

	Net.quick_backfill_ad(0 if _near_end() or _match_over or not QuickPlay.BACKFILL\
	else open)

func _near_end() -> bool:


	for side in [1, -1]:
		if int(_set_wins[side]) == GameConfig.sets_to_win - 1\
		and int(_scores[side]) >= GameConfig.set_points - 3:
			return true
	return false

func _on_late_joiner(id: int) -> void :









	if _match_over:
		Net.refuse_peer(id, "that match just ended")
		return



	if _quick() and _near_end()\
	and bool((Net.players.get(id, {}) as Dictionary).get("qjoin", false)):
		Net.refuse_peer(id, "that match is about to end, still searching")
		return


	var back_sid: = int((Net.players.get(id, {}) as Dictionary).get("sid", 0))
	if back_sid != 0 and _team_by_sid.has(back_sid) and not _team_played.has(id):
		_team_played[id] = int(_team_by_sid[back_sid])
		_net_event("tm", {"p": id, "t": int(_team_played[id])})
	var entries: = _live_cast()
	if entries.is_empty():




		return



	var auto_side: = _team_identity(_backfill_side()) if _quick()\
	else (_team_identity(1) if _practice != null else 0)
	Net.send_late_join(id, entries, auto_side)




	if auto_side == 0 and not _arrival_told.has(id):
		_arrival_told[id] = true
		var who: = String((Net.players.get(id, {}) as Dictionary).get("name", "someone"))
		hud.notice("%s joined as a spectator" % who)
		_net_event("arrive", {"who": who})

var _arrival_told: = {}







func _relay_pending_late_joiners() -> void :
	if _net_role != NetRole.HOST or not Net.in_match:
		return
	var seated: = {}
	for e in GameConfig.net_roster:
		seated[int((e as Dictionary).get("peer", 0))] = true
	for pid in Net.players.keys():
		var p: = int(pid)
		if p == 1 or seated.has(p) or _peer_players.has(p)\
		or Net.match_ready_peers.has(p):
			continue
		_on_late_joiner(p)






func _live_cast() -> Array:
	var entries: = []
	var nids: = _by_net_id.keys()
	nids.sort()
	var playing: Array = GameConfig.net_roster.filter(
		func(e): return not bool(e.get("spec", false)))
	for i in nids.size():
		var body: Player = _by_net_id[nids[i]]
		var e: Dictionary = (playing[i] as Dictionary).duplicate()\
		if i < playing.size() else {"cfg": {}, "kit": []}
		var peer: = 0





		var ls: = int(e.get("ls", 0))
		if _is_own_body(body):
			peer = _my_peer_id
		else:
			for pid in _peer_players:
				if _peer_players[pid] == body:
					peer = pid
					break


			if peer == 0:
				for seat in _seats:
					if seat.body == body:
						peer = _my_peer_id
						ls = int(seat.get("ls", 0))
						break




		var owned: = int(_seat_owner.get(body, 0))
		if owned < 0 and not body.is_bot:
			ls = _pid_ls(owned)
		elif owned == 0 and body.is_bot and peer == 0 and not _gone_bodies.has(body):
			ls = 0




		if peer < 0:
			ls = _pid_ls(peer)
			peer = _pid_owner(peer)
		e["peer"] = peer
		e["ls"] = ls


		e["tm"] = int(_team_played.get(peer, _team_identity(body.team_side)))\
		if peer > 0 and ls == 0 else 0
		e["name"] = String(_names.get(body, e.get("name", "cpu")))
		e["side"] = body.team_side




		e["team"] = _team_identity(body.team_side)
		e["slot"] = int(_slots.get(body, int(e.get("slot", 0))))
		e["spec"] = false


		var seat_pg: = int(_party_of.get(body, 0))
		if seat_pg > 0:
			e["pg"] = seat_pg
		else:
			e.erase("pg")






		if peer > 0 and ls >= 1:
			var locs: Array = Net.locals_of(peer)
			if ls - 1 < locs.size():
				var gcfg: Dictionary = (locs[ls - 1] as Dictionary).get("cfg", {})
				if not gcfg.is_empty():
					e["cfg"] = gcfg
		elif peer > 0:
			var live_cfg: Dictionary = (Net.players.get(peer, {})\
			as Dictionary).get("cfg", {})
			if not live_cfg.is_empty():
				e["cfg"] = live_cfg
		entries.append(e)
	for pid in Net.players:
		var seated: bool = (pid == 1 and not _spectating)\
		or _peer_players.has(pid)
		if not seated:
			entries.append({"peer": pid, 
				"name": String(Net.players[pid].name), 
				"tm": int(_team_played.get(pid, 0)), 
				"side": 0, "slot": -1, "spec": true, 
				"cfg": Net.players[pid].get("cfg", {}), "kit": []})
	return entries

func _backfill_side() -> int:


	var best: = 0
	var best_humans: = 99
	for p in _all_players:
		var body: Player = p
		if not body.is_bot:
			continue
		var humans: = 0
		for q in _all_players:
			if (q as Player).team_side == body.team_side\
			and not (q as Player).is_bot:
				humans += 1
		if humans < best_humans:
			best_humans = humans
			best = body.team_side
	return best

func _on_net_match_started(roster: Array) -> void :
	if embedded:
		return
	if Net.practice:
		return


	_rematch_reload = true
	GameConfig.set_mode(Net.team_size)
	GameConfig.stage = Net.stage
	Net.apply_rules_to_config()
	GameConfig.net_roster = roster
	GameConfig.goto_scene("res://game/main/main.tscn")

func _present_stats() -> void :
	hud.hide_cine_name()
	hud.set_dissolve(0.0)
	_tick_play_again()
	if not _stats_built:
		_stats_built = true
		var rows: = _stat_rows() if _net_role != NetRole.CLIENT\
		else hud.stored_stat_rows()



		_win_wrap_up()
		hud.show_match_stats(rows, _team_identity(_match_winner), 
			_team_identity(player.team_side), _net_role != NetRole.CLIENT)
		var mvp_key: = _win_mvp_key()
		if mvp_key != "":
			hud.hand_off_mvp_card(mvp_key)
		else:
			hud.hide_intro_card()
		if _net_role == NetRole.CLIENT and not _rematch_window():


			hud.room_stats_mode(_room_party_member())
		if _rematch_window():
			hud.quick_stats_mode( not _party_follower())
			_pa_left = PA_WINDOW
			_pa_opted = false
			_pa_off = false
			_pa_off_t = 0.0
			_pa_opt = {}
			_pa_names = {}
			for pid in Net.players:
				_pa_names[pid] = String(Net.players[pid].name)
			_pa_push_states()









		var max_sets: = 2 * maxi(GameConfig.sets_to_win, 1) - 1


		var heard: = 0
		for t in _ach_sets.values():
			heard = maxi(heard, int(t.get("won", 0)) + int(t.get("lost", 0)))
		var sets_ok: = clampi(maxi(int(_set_wins[1]) + int(_set_wins[-1]), heard), 1, max_sets)
		var max_rallies: = sets_ok * (2 * maxi(GameConfig.set_points, 1) + 12)
		var rallies_ok: = clampi(_match_rallies, 0, max_rallies)





		var mvps: = Rules.team_mvps(rows)
		for each in _ach_locals():
			var body: Player = each[0]
			for row in rows:
				if String(row.get("name", "")) != String(_names.get(body, "")):
					continue
				var won: = _match_winner == body.team_side
				var safe: = {}
				for k in ["pts", "spk", "blk", "rcv", "set", "ast"]:
					var cap: = rallies_ok if k in ["pts", "ast"] else rallies_ok * TOUCH_STATS_A_RALLY
					safe[k] = clampi(Net.ev_i(row, k, 0), 0, cap)
				if body == player:
					Career.record_match(safe, won)
				var tally: Dictionary = _ach_sets.get(body, {})
				Achievements.notify_for(each[1], "match_end", {"won": won, 
					"online": _ach_online(), 
					"stage": GameConfig.stage, "team_size": GameConfig.team_size, 
					"sets_to_win": GameConfig.sets_to_win, 
					"sets_won": int(tally.get("won", 0)), "sets_lost": int(tally.get("lost", 0))})

				Achievements.notify_for(each[1], "match_stats", 
					{"spk": safe.spk, "rcv": safe.rcv, "blk": safe.blk})


				if _quick_post() and GameConfig.stage == "nationals"\
				and not _ach_no_rematch.has(each[1]):
					_ach_no_rematch.append(each[1])
				var mvp: = Rules.stat_row_key(row) in mvps.values()
				if body != player:



					Progression.grant_match(won, sets_ok, rallies_ok, mvp, each[1])
				if body == player:




					_last_match_reward = Progression.grant_match(won, sets_ok, 
						rallies_ok, mvp)



					if player.character != null:
						player.character.level = Progression.shown_level()
						player._refresh_title()
					if Net.active:
						Net.send_party_look(GameConfig.menu_outfit)
				break
		if not _spectating:
			_record_match_history(rows, _match_winner == player.team_side)


		hud.show_match_rewards(_last_match_reward)

func _record_match_history(rows: Array, won: bool) -> void :



	var mplayers: Array = []
	for r in rows:
		var rn: = String(r.get("name", ""))
		var rsid: = ""
		var rside: = int(r.get("side", 0))
		for pid in Net.players:
			if String(Net.players[pid].get("name", "")) == rn:
				rsid = str(int(Net.players[pid].get("sid", 0)))
				if rside == 0:
					rside = int(Net.players[pid].get("side", 0))
				break


		var rcfg: Variant = r.get("cfg", {})
		mplayers.append({"name": rn, "ready_name": String(r.get("ready_name", rn)), 
			"sid": rsid, "side": rside, 
			"cfg": rcfg if rcfg is Dictionary else {}, 
			"pts": Net.ev_i(r, "pts", 0), "spk": Net.ev_i(r, "spk", 0), 
			"blk": Net.ev_i(r, "blk", 0), "rcv": Net.ev_i(r, "rcv", 0), 
			"set": Net.ev_i(r, "set", 0), "ast": Net.ev_i(r, "ast", 0), 
			"ace": Net.ev_i(r, "ace", 0), "dig": Net.ev_i(r, "dig", 0)})




	var chat: = ""
	if _net_role != NetRole.OFFLINE:
		var match_secs: = float(Time.get_ticks_msec() - _rec_started_ms) / 1000.0
		chat = Net.recent_chat_log(maxf(match_secs, 0.0) + 120.0)
		if chat.length() > Reports.CHAT_MAX:
			chat = chat.right(Reports.CHAT_MAX)
	Career.record_history({
		"ts": int(Time.get_unix_time_from_system()), 
		"stage": GameConfig.stage, 
		"mode": "%dv%d" % [GameConfig.team_size, GameConfig.team_size], 
		"online": _net_role != NetRole.OFFLINE, 
		"won": won, 
		"my_name": String(_names.get(player, "")), 
		"home_score": int(_scores[1]), "away_score": int(_scores[-1]), 
		"home_sets": int(_set_wins[1]), "away_sets": int(_set_wins[-1]), 


		"replay": _last_replay_path, 

		"match_token": _match_token if _net_role != NetRole.OFFLINE else "", 
		"players": mplayers, 

		"chat": chat, 
		"lobby_id": str(Net.steam_lobby_id) if _net_role != NetRole.OFFLINE else "", 
		"net_role": ("host" if Net.is_host else "client") if _net_role != NetRole.OFFLINE else "", 
	})

func _restart_match() -> void :

	_stats_built = false
	_match_over = false
	_match_winner = 0
	_did_intro = false
	_scores = {1: 0, -1: 0}
	_set_wins = {1: 0, -1: 0}
	_run_side = 0
	_run_len = 0
	_music_heat = 0
	_music_opener = false
	MusicManager.set_floor(0)
	MusicManager.set_intensity(0)
	_match_rallies = 0
	_ach_touch.clear()
	_ach_bam.clear()
	_ach_dives.clear()
	_ach_roll = null
	_ach_broke = null
	_ach_combo = {}
	_ach_chain = {1: [], -1: []}
	_ach_cord = null
	_ach_serve = {}
	_ach_sets.clear()
	_ach_tossed = false
	_ach_no_rematch.clear()
	_last_match_reward = {}
	_set_number = 1
	_sand_set = -1
	Rules.set_swapped = false
	_rot = {1: 0, -1: 0}
	for p in _stats:
		_stats[p] = {"pts": 0, "spk": 0, "blk": 0, "rcv": 0, "set": 0, "ast": 0}
	hud.hide_match_stats()
	hud.hide_cinematics()
	_diss_left = 0.0
	_swap_delay = 0.0
	_serve_prelaid = false
	_rally.serve_locked = false
	_sweat_shown = 0.0
	_net_sweat = 0.0
	_sweat_sent = -1.0
	_replay_pending = false
	_start_recording()
	hud.set_loading(1.0)
	_park_ball()





	ball.show_landing_ring = true





	for p in _all_players:
		var body: Player = p
		body.clear_action_state()
		body.sprinting = false
		body._sprint_ramp = 0.0
		body.velocity = Vector3.ZERO
		body._move_intent = Vector2.ZERO
	_phase = Phase.DEAD
	_dead_timer = 0.6

func _on_play_again() -> void :

	if not LocalPlayers.leader_holds_ui():
		return
	if _rematch_window():

		if _pa_opted or _pa_left <= 0.0 or _pa_off:
			return
		_pa_opted = true
		hud.set_play_again("you're in!", true)
		if _net_role == NetRole.CLIENT:
			Net.send_up("pa", {})
		else:
			_pa_opt[1] = true
			_pa_push_states()
		return
	if _net_role == NetRole.CLIENT:
		return
	_net_event("rematch", {})
	_restart_match()

func _on_to_lobby() -> void :
	if not LocalPlayers.leader_holds_ui():
		return
	if _rematch_window():
		if Net.party:




			if _net_role != NetRole.CLIENT:
				_pa_disband(false)
			return






		if bool(Net.home_party.get("is_leader", false))\
		and not bool(Net.home_party.get("room", false)):
			QuickPlay.qlog("folded leader leaves the results: party home relay")
			Net.send_party_home()
			hud.hide_match_stats()
			UiWipe.wipe(get_tree(), func():
				Net.leave()
				_go_menu())
			return




		if _net_role == NetRole.HOST:
			_pa_disband(false)
			return
		Net.leave()
		hud.hide_match_stats()
		UiWipe.wipe(get_tree(), func():
			_go_menu())
		return
	if _net_role == NetRole.CLIENT:








		if bool(Net.home_party.get("is_leader", false))\
		and bool(Net.home_party.get("room", false)):



			Net.send_party_home()
			hud.hide_match_stats()
			UiWipe.wipe(get_tree(), func():
				Net.leave()
				_go_menu())
			return


		if _room_party_member():
			Net.home_party = {}
		Net.leave()
		hud.hide_match_stats()
		UiWipe.wipe(get_tree(), func():
			_go_menu())
		return
	if _net_role == NetRole.OFFLINE:
		hud.hide_match_stats()

		if not GameConfig.tutorial_finale:
			GameConfig.menu_return_local = true
		UiWipe.wipe(get_tree(), func():
			_go_menu())
	else:
		_net_event("to_lobby", {})
		_leave_to_lobby()






func _on_party_home_called(leader_sid: int) -> void :
	var hp: Dictionary = Net.home_party
	QuickPlay.qlog("party_home_called leader=%d home=%s over=%s" % [leader_sid, str(hp), str(_match_over)])
	if hp.is_empty() or bool(hp.get("is_leader", false)) or not _match_over:
		return
	var mine: = int(hp.get("leader_sid", 0))
	if leader_sid != 0 and mine != 0 and mine != leader_sid:
		return



	Net.leave.call_deferred()

func _side_color(side: int) -> Color:
	return CINE_BLUE if side > 0 else CINE_RED

func _team_players(side: int) -> Array:
	var list: = _all_players.filter( func(o): return o.team_side == side)
	list.sort_custom( func(a, b): return _slots[a] < _slots[b])
	return list

func _cine_focus(spot: Vector3, side: int) -> void :


	camera_rig.cine_eye = spot + Vector3(0.9, 1.7, - side * 3.2)
	camera_rig.cine_target = spot + Vector3(0.0, 1.1, 0.0)

func _subject_spot(subject: Player) -> Vector3:
	return _showcase_spot(_intro_index(subject), GameConfig.team_size, 
		subject.team_side)




func _effective_phase() -> int:
	if _net_role == NetRole.CLIENT:
		return int(_np.get("ph", _phase))
	return _phase



























func _music_tick(phase: int) -> void :
	if embedded:
		return
	if phase == _music_phase:
		return
	_music_phase = phase
	match phase:
		Phase.SERVE_PREP, Phase.LIVE:






			MusicManager.set_floor(_music_tier())
			MusicManager.set_intensity(_music_effective_tier())
			MusicManager.play("match", MusicManager.QUICK_FADE, false)
		Phase.REPLAY:
			MusicManager.play("replay", MusicManager.QUICK_FADE, true)
		Phase.WIN:

			MusicManager.stinger("win")
		Phase.INTRO:




			_music_build_stage = -1
			_music_build(0, MusicManager.CLIMAX_AT
				- (float(_intro_plan().end) + COUNTDOWN_TIME) + _cine_time)
		Phase.COUNTDOWN:






			if not _music_opener and GameConfig.match_intro and _set_number == 1\
			and int(_scores[1]) == 0 and int(_scores[-1]) == 0:
				_music_build_stage = -1
				_music_build(3, MusicManager.CLIMAX_AT - COUNTDOWN_TIME + _cine_time)
			if _music_opener:
				_music_build(3)
				_music_climax_sync()







func _music_build(stage: int, at: = 0.0) -> void :
	if embedded:
		return
	if stage <= _music_build_stage:
		return
	_music_build_stage = stage
	_music_opener = true
	MusicManager.play_build(stage, MusicManager.FULL_FADE, at)





const MUSIC_SYNC_SLACK: = 0.08

func _music_climax_sync() -> void :
	if embedded:
		return
	var want: = MusicManager.CLIMAX_AT - COUNTDOWN_TIME + _cine_time
	var at: = MusicManager.match_position()
	if at < 0.0 or absf(at - want) > MUSIC_SYNC_SLACK:
		MusicManager.seek_match(want)




func _music_build_at(ct: float) -> void :
	var plan: = _intro_plan()
	var sw: = float(plan.sw)
	if ct >= float(plan.t_away):
		_music_build(2)
	elif ct >= (sw if sw > 0.0 else float(plan.t_whip) * 0.33):
		_music_build(1)





func _music_rally_end(replay_incoming: bool) -> void :
	if embedded:
		return


	_music_heat = 0
	_music_spike_power = 0.0
	_music_heat_t = 0.0
	_music_opener = false



	if replay_incoming or _music_point_won_match():
		MusicManager.stop(MusicManager.QUICK_FADE)



		if replay_incoming:
			sfx.play_2d("replay_scratch", 2.0)
	elif _music_point_won_set():




		MusicManager.set_floor(0)
		MusicManager.set_intensity(0)
	else:



		MusicManager.set_floor(_music_tier())
		MusicManager.set_intensity(_music_effective_tier())






func _music_point_won_match() -> bool:
	var side: = _music_point_won_set()
	if side == 0:
		return false

	var key: = "w1" if side == 1 else "w2"
	var won: = int(_np.get(key, _set_wins[side])) if _np.has(key) else int(_set_wins[side])
	return won + 1 >= GameConfig.sets_to_win



func _music_point_won_set() -> int:
	var target: = maxi(GameConfig.set_points, 1)
	for side in [1, -1]:
		var mine: = int(_scores[side])
		var lead: = mine - int(_scores[ - side])
		if mine >= target and ( not GameConfig.win_by_two or lead >= 2):
			return side
	return 0


func _music_effective_tier() -> int:
	if _music_opener:
		return 2
	return clampi(_music_tier() + _music_heat, 0, 2)












func _music_heat_touch(kind: int, power: float, laid_out: bool) -> void :
	if embedded:
		return
	var before: = _music_heat
	match kind:
		Player.TouchKind.SPIKE, Player.TouchKind.DUMP:
			_music_spike_power = power if kind == Player.TouchKind.SPIKE else 0.0
		Player.TouchKind.BUMP, Player.TouchKind.SET, Player.TouchKind.BLOCK:
			if laid_out and _music_spike_power >= MUSIC_SAVE_SPIKE:
				_music_heat = mini(_music_heat + 1, 2)
				_music_heat_t = 0.0
			_music_spike_power = 0.0
	if _music_heat != before:
		MusicManager.set_intensity(_music_effective_tier())




func _music_heat_decay(delta: float) -> void :
	if embedded:
		return
	if _music_heat <= 0:
		return
	_music_heat_t += delta
	if _music_heat_t < MUSIC_HEAT_HOLD:
		return
	_music_heat_t = 0.0
	_music_heat -= 1
	MusicManager.set_intensity(_music_effective_tier(), 1.2)







func _music_tier() -> int:
	var target: = maxi(GameConfig.set_points, 1)
	var lead: = maxi(int(_scores[1]), int(_scores[-1]))
	var deuce: bool = GameConfig.win_by_two\
	and mini(int(_scores[1]), int(_scores[-1])) >= target - 1
	if deuce or lead >= target - MUSIC_CLOSE_POINTS:
		return 2
	if lead * 2 >= target:
		return 1
	return 0

func _gate_cinematics(input: PlayerInput, body: Player = player) -> PlayerInput:
	if embedded and not embedded_active:
		return PlayerInput.new()
	var phase: = _effective_phase()




	if phase == Phase.STATS:
		return PlayerInput.new()






	if phase == Phase.INTRO:
		var walk: = _intro_walk_input(body)
		if walk != null:
			return walk
	if phase != Phase.INTRO or body == null or body.team_side == _intro_shown_side:
		return input
	var held: = PlayerInput.new()
	held.aim = input.aim




	return held

func _present_intro(ct: float) -> void :
	_music_build_at(ct)





	var plan: = _intro_plan()
	var home: = _captain_first(_team_players(HOME_SIDE))
	var away: = _captain_first(_team_players( - HOME_SIDE))
	var sw: float = plan.sw
	var t_whip: float = plan.t_whip
	var t_away: float = plan.t_away
	var snap: = _cine_want_snap
	var dissolve: = 0.0
	hud.set_cinema_bars(true)
	hud.hide_cine_name()

	if not _intro_names_hidden:
		_intro_names_hidden = true
		for p in _all_players:
			(p as Player).suppress_names(true)


	_grabbed_home = not _loading_up
	if ct < sw:


		_intro_shown_side = 0
		_swoop_cam(ct / sw, home)
		snap = true
		if ct > 0.45 and _intro_once("stage"):
			hud.show_stage_card(Stage.title(GameConfig.stage).to_lower())
	elif ct < t_whip:
		if _intro_once("stage_out"):
			hud.hide_stage_card()
		_intro_shown_side = HOME_SIDE
		_team_beat(home, HOME_SIDE, ct - sw, float(plan.per_h))
		snap = true
	elif ct < t_away:


		_intro_shown_side = - HOME_SIDE
		if _intro_once("switch"):
			hud.hide_team_slab()
			hud.hide_intro_card()
			if not _loading_up:
				hud.grab_dissolve()
		if not away.is_empty():
			_spotlight(_follow_point(away[0]), - HOME_SIDE, 0.0)
		snap = true
		dissolve = 1.0 - (ct - t_whip) / INTRO_WHIP
	else:
		_intro_shown_side = - HOME_SIDE
		_team_beat(away, - HOME_SIDE, ct - t_away, float(plan.per_a))
		dissolve = 0.0
		snap = true
	_intro_locked = player.team_side != _intro_shown_side


	_intro_fov(ct >= sw)
	camera_rig.cine_snap = snap
	_cine_want_snap = false
	hud.set_dissolve(clampf(dissolve, 0.0, 1.0))


	var lf: = LOAD_FADE * (0.4 if _intro_swoop else 1.0)
	hud.set_loading(clampf(1.0 - ct / lf, 0.0, 1.0))



func _intro_once(key: String) -> bool:
	if _intro_fired.has(key):
		return false
	_intro_fired[key] = true
	return true




func _team_beat(team: Array, side: int, bt: float, per: float) -> void :
	if team.is_empty():
		return
	if _intro_once("slab%d" % side):
		hud.show_team_slab(_intro_label(side), _side_color(side), side != HOME_SIDE)
		crowd.cheer(0.45)
	var i: = clampi(floori(maxf(bt - INTRO_SLAB, 0.0) / per), 0, team.size() - 1)
	var into: = bt - INTRO_SLAB - i * per
	var who: Player = team[i]




	var glide: = per * SPOT_MOVE
	if bt >= INTRO_SLAB and i > 0 and into < glide:
		var f: = clampf(into / glide, 0.0, 1.0)
		var e: = f * f * f * (f * (f * 6.0 - 15.0) + 10.0)
		var a: = _follow_point(team[i - 1])
		var b: = _follow_point(who)
		camera_rig.cine_eye = _spot_eye(a, side, 1.0).lerp(_spot_eye(b, side, 0.0), e)
		camera_rig.cine_target = (a + Vector3(0.0, 1.1, 0.0)).lerp(b + Vector3(0.0, 1.1, 0.0), e)
	else:
		var settle: = glide if i > 0 else 0.0
		var held: = clampf((into - settle) / maxf(per - settle, 0.01), 0.0, 1.0)\
		if bt >= INTRO_SLAB else 0.0
		_spotlight(_follow_point(who), side, held)
	if bt >= INTRO_SLAB and _intro_once("card%d_%d" % [side, i]):
		var look: = who.character

		hud.show_intro_card(who.display_name().trim_suffix(" (CPU)"), 
			look.title if look != null and not _is_cpu(who) else {}, i, 
			"captain" if who.is_captain and _captain_shown() else "", _side_color(side), 
			look.level if look != null and not _is_cpu(who) else 0, 
			0 if _is_cpu(who) else who.dev_tag, 
			0 if _is_cpu(who) else who.party_mark)






func _warm_feed_faces() -> void :
	if _faces_busy or _faces_warm or _all_players.is_empty():
		return
	_faces_busy = true
	for p in _all_players.duplicate():
		if is_instance_valid(p) and (p as Player).character != null:
			await CharacterPortrait.head_cached((p as Player).character.to_dict(), self, "lobby")
	_faces_busy = false
	_faces_warm = true

func _ensure_captains() -> void :
	for side in [1, -1]:
		var team: = _team_players(side)
		if team.is_empty() or team.any( func(b): return (b as Player).is_captain):
			continue
		(team[0] as Player).is_captain = true






func _captain_shown() -> bool:
	if not _quick():
		return false
	return DressCode.team_colours(_cfg_stage(), DressCode.rule_now())



func _captain_first(team: Array) -> Array:
	var out: = team.duplicate()
	for b in team:
		if (b as Player).is_captain:
			out.erase(b)
			out.push_front(b)
			break
	return out

func _is_cpu(body: Player) -> bool:
	return _bots.has(body)







const INTRO_FOLLOW: = 0.75

const INTRO_FOLLOW_EASE: = 5.0
var _intro_follow: = {}

func _follow_point(body: Player) -> Vector3:
	return _follow_at(body, _subject_spot(body))



func _follow_at(body: Player, spot: Vector3) -> Vector3:
	if body == null or not is_instance_valid(body):
		return spot
	var at: = body.get_global_transform_interpolated().origin
	var want: = spot.lerp(at, INTRO_FOLLOW)



	var now: = Time.get_ticks_usec()
	if not _intro_follow.has(body):
		_intro_follow[body] = [want, now]
		return want

	var e: Array = _intro_follow[body]
	var dt: = clampf(float(now - int(e[1])) / 1000000.0, 0.0, 0.1)
	var eased: Vector3 = (e[0] as Vector3).lerp(want, 1.0 - exp( - INTRO_FOLLOW_EASE * dt))
	_intro_follow[body] = [eased, now]
	return eased


const SPOT_EYE: = Vector3(0.35, 1.7, 3.6)
const SPOT_PUSH: = 0.35
const SPOT_MOVE: = 0.45

func _spot_eye(spot: Vector3, side: int, push: float) -> Vector3:
	return _off_net(spot + Vector3(SPOT_EYE.x, SPOT_EYE.y, 
		- side * (SPOT_EYE.z - SPOT_PUSH * push)), side)







const NET_CLEAR: = 1.0

func _off_net(eye: Vector3, side: int) -> Vector3:
	var over: = NET_CLEAR - side * eye.z
	if over > 0.0:
		eye.z = side * NET_CLEAR
		eye.y += minf(over, 4.0) * 0.45
	return eye

func _spotlight(spot: Vector3, side: int, push: float) -> void :
	var p: = clampf(push, 0.0, 1.0)
	var e: = p * p * (3.0 - 2.0 * p)
	camera_rig.cine_eye = _spot_eye(spot, side, e)
	camera_rig.cine_target = spot + Vector3(0.0, 1.1, 0.0)




const INDOOR_SWOOP_TOP: = 20.0

func _swoop_top() -> float:
	var outdoor: = maxf(_half_l * 2.6, 22.0)








	var st: Variant = Stage.val(GameConfig.stage, "swoop_top", null)
	if st != null:
		return minf(float(st), outdoor)
	var fh: Variant = Stage.val(GameConfig.stage, "fog_height", null)
	if fh == null:



		return minf(outdoor, INDOOR_SWOOP_TOP) if Stage.kind(GameConfig.stage) == "indoor" else outdoor
	return clampf(float(fh) - 2.5, 6.0, outdoor)




func _swoop_cam(f: float, home: Array) -> void :
	var first: = _showcase_spot(0, GameConfig.team_size, HOME_SIDE)
	if not home.is_empty():
		first = _subject_spot(home[0])
	var end_eye: = _spot_eye(first, HOME_SIDE, 0.0)
	var end_look: = first + Vector3(0.0, 1.1, 0.0)
	var e: = f * f * f * (f * (f * 6.0 - 15.0) + 10.0)
	var a1: = atan2(end_eye.x, end_eye.z)
	var r1: = Vector2(end_eye.x, end_eye.z).length()
	var a: = lerpf(a1 + PI * 0.55, a1, e)
	var r: = lerpf(1.2, r1, e)
	var h: = lerpf(_swoop_top(), end_eye.y, e)
	camera_rig.cine_eye = Vector3(sin(a) * r, h, cos(a) * r)
	camera_rig.cine_target = Vector3.ZERO.lerp(end_look, e)



const INTRO_FOV_TIGHT: = 0.8
var _intro_base_fov: = 0.0

func _intro_fov(tight: bool) -> void :
	var cam: Camera3D = camera_rig.camera
	if cam == null:
		return
	if _intro_base_fov <= 0.0:
		_intro_base_fov = cam.fov
	var want: = _intro_base_fov * (INTRO_FOV_TIGHT if tight else 1.0)
	cam.fov = lerpf(cam.fov, want, 1.0 - exp(-6.0 * get_physics_process_delta_time()))




func _intro_wrap_up() -> void :
	if _intro_fired.has("wrapped"):
		return
	_intro_fired["wrapped"] = true
	_intro_walk_armed = false
	if _intro_base_fov > 0.0 and camera_rig.camera != null:
		camera_rig.camera.fov = _intro_base_fov
	_intro_base_fov = 0.0
	hud.set_cinema_bars(false)
	hud.hide_intro_ui()
	if _intro_names_hidden:
		_intro_names_hidden = false
		for p in _all_players:
			(p as Player).suppress_names(false)

func _intro_label(side: int) -> String:

	return Rules.side_name(side)

func _cine_present(phase: int, ct: float) -> void :







	if phase != _cine_snap_phase:
		_cine_snap_phase = phase
		_cine_want_snap = true
		hud.rally_fade(false)
	hud.set_scoreboard_visible(false)
	hud.set_crosshair_visible(false)
	hud.set_serve_prompt("")
	hud.set_play_hud_visible(false)
	aim_indicator.visible = false
	camera_rig.cinematic = phase == Phase.INTRO or phase == Phase.WIN\
	or phase == Phase.STATS
	if phase == Phase.WIN:
		_present_win(ct)
		return
	if phase == Phase.STATS:
		_present_stats()
		return
	if phase == Phase.INTRO:
		_present_intro(ct)
	elif phase == Phase.COUNTDOWN:
		hud.hide_cine_name()
		_intro_wrap_up()



		hud.set_dissolve(clampf(1.0 - ct / INTRO_FADE, 0.0, 1.0) if _grabbed_home else 0.0)
		var n: = ceili(COUNTDOWN_TIME - ct)
		if n >= 1:





			if n != _last_count_n:
				_last_count_n = n
				sfx.play_2d("count_tick", 1.0)




				if _music_opener:
					_music_climax_sync()
				camera_rig.shake(0.3 if n == 1 else 0.16)
			hud.show_countdown(n, _side_color(HOME_SIDE) if n == 3
				else (_side_color( - HOME_SIDE) if n == 2 else Color.WHITE))
		else:
			hud.hide_countdown()
			_last_count_n = 0

func _prepare_serve() -> void :



	_flush_motion_state()
	_lag_touch_requests.clear()
	_lag_history.clear()
	_ball_event_flight.clear()
	_toss_visual_state.clear()
	_toss_unfrozen_snaps = 0
	_ball_offset_armed = false
	_ball_vis_offset = Vector3.ZERO
	for member in _all_players:
		(member as Player).contact_enabled = true
	_rally.prepare_serve()

func _begin_serve(prepare: = true) -> void :





	if _net_role != NetRole.CLIENT:
		_apply_seat_requests()
	_hide_landing_call()
	ball.visible = true
	camera_rig.cinematic = false
	if prepare:
		_prepare_serve()
	_rally.begin_serve(false)
	_phase = Phase.SERVE_PREP

	_sand_new_rally()


	crowd.serve_build()


	sfx.play("whistle", Vector3.ZERO, -3.0)
	_net_event("whistle", {"p": Vector3.ZERO})
	_net_event("serve", {})

func _serve_prep_tick(delta: float) -> void :
	_rally.serve_tick(delta)

func _in_serve_zone(p: Player) -> bool:
	return _rally.in_serve_zone(p)







func _apply_serve_squares() -> void :
	if _rally == null:
		return
	for p in _all_players:
		var body: Player = p
		body.serve_squares = _practice == null or _rally.in_serve_zone(body)





func _view_index_for_body(body: Player) -> int:
	if body == null:
		return -1
	for v in _views:
		for o in v.owners:
			if _body_for_slot(o) == body:
				return v.index
	return -1

func _place_serve_zone_view(zsrv: Player) -> void :
	if _views.size() <= 1:
		return
	var vi: = _view_index_for_body(zsrv)
	if vi < 0:
		_serve_zone.layers = 0
	else:
		LocalViews.privatize(_serve_zone, vi)

func _do_toss(up_speed: float) -> void :
	_rally.do_toss(up_speed)

func _allies_of(p: Player) -> Array:
	return _lines.allies_of(_all_players, p)

func _opponents_of(p: Player) -> Array:
	return _lines.opponents_of(_all_players, p)

func _update_barred() -> void :
	_rally.pre_tick(0.0, _phase != Phase.LIVE)

func _on_ball_wall_hit() -> void :
	_rally.ball_hit_wall()





func _on_swung(_kind: int, who: Player) -> void :
	if not is_instance_valid(who):
		return
	var pos: = who.global_position
	sfx.play("swing", pos, -5.0, 1.0)
	_net_event("swing_fx", {"p": pos})

func _on_touched(kind: int, who: Player) -> void :




	if who == _rally.server and not _rally.serve_done:
		if not who.grounded():
			crowd.serve_hit()
			_net_event("servestrike", {"j": true})
		else:
			crowd.serve_stop()
			_net_event("servestrike", {"j": false})
	_ach_touched(kind, who)


	_rally.judge_touch(kind, who)




func _bounce_fx(pos: Vector3, impact: float) -> void :
	var hard: = clampf((impact - 6.0) / 12.0, 0.0, 1.0)
	sfx.play("hit_soft", pos, lerpf(-10.0, -3.0, hard), lerpf(0.75, 0.62, hard))
	ball.pulse()
	var floor_pos: = Vector3(pos.x, 0.06, pos.z)
	fx.ring(floor_pos, Vector3.UP, lerpf(0.35, 1.5, hard))
	fx.puff(floor_pos)

	if hard > 0.25:
		fx.floor_gust(floor_pos, hard)

func _on_ball_bounced() -> void :



	var impact: = ball.vel.length()
	if not _rally.live:
		_bounce_fx(ball.global_position, impact)
		return
	_replay_focus = ball.global_position




	var bounce_vel: = Vector3(ball.vel.x * Ball.PHYS.floor_friction, 
		- ball.vel.y * Ball.PHYS.floor_bounce, 
		ball.vel.z * Ball.PHYS.floor_friction)
	if bounce_vel.y < 1.2:
		bounce_vel.y = 0.0
	_commit_floor(ball.global_position, bounce_vel, impact)

func _commit_floor(pos: Vector3, bounce_vel: Vector3, impact: float) -> void :
	_bounce_fx(pos, impact)

	_net_event("bounce", {"p": pos, "bv": bounce_vel, "is": impact})


	_rally.ball_bounced()







func _dev_match_point_tick() -> void :
	if _phase != Phase.SERVE_PREP or _match_over or _practice != null or _rally.endless:
		return
	_dev_match_point = false
	QuickPlay.qlog("dev --match-point: home side scores the match point")
	_rally.scores[HOME_SIDE] = maxi(_rally.set_points - 1, 0)
	_rally.scores[ - HOME_SIDE] = 0
	_set_wins[HOME_SIDE] = maxi(GameConfig.sets_to_win - 1, 0)
	_end_rally(HOME_SIDE)

func _end_rally(winner_side: int) -> void :



	if _phase == Phase.DEAD:
		return
	_rally._ended = false
	_rally.end_rally(winner_side, "")






func _on_antenna_hit(side: int) -> void :
	_bob_antenna(side)
	if _practice != null:
		return
	_antenna_call(side)
	sfx.play("whistle", ball.global_position, -2.0)
	_net_event("antenna", {"s": side})

func _bob_antenna(side: int) -> void :
	var a: = court.get_node_or_null("AntennaEast" if side > 0 else "AntennaWest")
	if a != null and a.has_method("bob"):
		a.call("bob", float(side))



func _antenna_call(side: int) -> void :
	var a: = court.get_node_or_null("AntennaEast" if side > 0 else "AntennaWest") as Node3D
	var pos: = a.global_position if a != null else Vector3(side * _half_w, 0.0, 0.0)
	landing_marker.visible = true
	landing_marker.global_position = Vector3(pos.x, maxf(0.03, SandDeform.decal_y), pos.z)

	LandingCall.apply(landing_marker, verdict_label, "antenna")

func _on_rally_whistle(reason: String, pos: Vector3) -> void :
	_close_serve_minigame()


	sfx.play("whistle", pos)
	_net_event("whistle", {"p": pos, "t": reason})

func _on_rally_verdict(pos: Vector3, text: String, winner: int) -> void :
	_last_verdict_pos = pos
	_show_verdict(pos, text, winner)
	_net_event("verdict", {"p": pos, "t": text, "w": winner})

func _on_rally_tossed(server_body: Player) -> void :
	_phase = Phase.LIVE
	_ach_tossed = true
	server_body.present_serve_toss(true)
	hud.rally_fade(true)
	sfx.play("hit_soft", ball.global_position, -10.0, 1.1)



	_net_event("toss", {"id": int(_net_ids.get(server_body, 0))})

var _serve_minigame: ServeMinigame = null

func _spawn_serve_minigame(server_body: Player) -> void :
	if _serve_minigame != null:
		_serve_minigame.queue_free()
		_serve_minigame = null
	_serve_minigame = ServeMinigame.new()
	add_child(_serve_minigame)
	_serve_minigame.finished.connect( func(off: Vector2):
		_apply_serve_style(server_body, off))

func _apply_serve_style(server_body: Player, off: Vector2) -> void :
	_close_serve_minigame()
	if _phase != Phase.SERVE_PREP or _server != server_body:
		return
	var m: = maxf(absf(off.x), absf(off.y))
	var acc: = clampf(1.0 - m / 0.256, 0.0, 1.0)
	if m <= 0.256:
		server_body.set("serve_style", {"type": "float",
			"power": lerpf(0.53, 0.33, acc),
			"charge": lerpf(0.35, 1.0, acc),
			"pattern": randi() % 999983 + 1})
	else:
		server_body.set("serve_style", {"type": "spin",
			"power": 0.45 + 0.25 * clampf((m - 0.256) / 0.744, 0.0, 1.0)
			+ 0.1 * maxf(0.0, off.y), "curve": - off.x * 4.0})
	_rally.do_toss(Ball.serve_toss_up(0.667), 2.2)

func _close_serve_minigame() -> void :
	if _serve_minigame != null:
		_serve_minigame.queue_free()
		_serve_minigame = null

func _on_rally_flair(kind: String, who: Player) -> void :
	if kind == "quick" and _ach_touch.has(who):
		_ach_touch[who]["quick"] = true


	if kind == "carom" and not (who.team_side == _rally.serve_side\
	and not _rally.serve_crossed):
		_ach_emit(who, "carom", {})
	match kind:
		"quick":
			crowd.shock(0.7)
			_net_event("shock", {"a": 0.7})
		"perfect":
			sfx.play("hit_hard", who.chest_position(), -2.0, 1.1)
			fx.ring(ball.global_position, ball.vel, 1.1)
		"dive":
			crowd.shock(0.85)
			_net_event("shock", {"a": 0.85})
		"carom":



			if who == player:
				camera_rig.shake(0.08 + 0.18 * who.last_touch_power)




func _point_call(winner_side: int, reason: String, winners_ball: bool) -> Array:

	var broke: = winner_side != _run_side and _run_len >= 3
	if winner_side == _run_side:
		_run_len += 1
	else:
		_run_side = winner_side
		_run_len = 1
	var wsc: = int(_scores[winner_side])
	var lsc: = int(_scores[ - winner_side])
	var lead: = wsc - lsc

	if wsc >= GameConfig.set_points and ( not GameConfig.win_by_two or lead >= 2):
		var match_win: bool = int(_set_wins[winner_side]) + 1 >= GameConfig.sets_to_win
		return ["game" if match_win else "set", winner_side]


	var target: = GameConfig.set_points
	if maxi(wsc, lsc) == target - 1\
	or (GameConfig.win_by_two and mini(wsc, lsc) >= target - 1):
		return ["", winner_side]




	if reason == "foot fault" or reason == "line fault":
		return ["foot_fault", winner_side]


	if reason == "serve foul" or reason == "outside the antenna"\
	or reason == "illegal attack on serve" or reason == "four touches":
		return ["fault", winner_side]


	if broke:
		return ["break_point", winner_side]

	if reason == "":




		var serving_side: = _rally.server.team_side if _rally.server != null else 0
		if winner_side == serving_side and not _rally.serve_received:
			return ["ace", winner_side]
		if winners_ball and _landed_on_line():
			return ["line", winner_side]
		return ["", winner_side]
	if reason == "ball out":
		return ["out", winner_side]
	return ["", winner_side]




func _landed_on_line() -> bool:





	return Rules.on_line(_last_verdict_pos, _half_w, _half_l)

func _on_rally_point(winner_side: int, reason: String, _scorer: Player, 
		kill_power: float, winners_ball: bool) -> void :
	_phase = Phase.DEAD
	_close_serve_minigame()
	_dead_timer = DEAD_TIME
	_match_rallies += 1
	_ach_point(winner_side, _scorer, reason, winners_ball)



	crowd.serve_stop()






	if _rally.rally_time >= REPLAY_MIN_RALLY and not _match_over and _replay_enabled\
	and GameConfig.instant_replays:
		_replay_pending = true
		_replay_wait = REPLAY_BEAT
	_last_spike_power = 0.0
	sfx.play("whistle", ball.global_position)
	_net_event("whistle", {"p": ball.global_position})












	var moment: = _point_call(winner_side, reason, winners_ball)
	var call_side: = _team_identity(int(moment[1]))



	var roles: = _kill_roles(winner_side, reason, _scorer, winners_ball, String(moment[0]))
	var feed: = _feed_data(roles.hero, roles.villain, roles.tag)
	hud.point_moment(winner_side, _team_identity(1), reason, 
		_scores[1], _scores[-1], feed)
	_point_cam(roles.hero)



	var home_side: = 1 if _team_identity(1) == 1 else -1
	_recorder.cue("point", {"w": _team_identity(winner_side), 
		"h": int(_scores[home_side]), "a": int(_scores[ - home_side]), 
		"set": _set_number, "r": reason})
	if String(moment[0]) != "":
		hud.announce_moment(String(moment[0]), call_side)
	_net_event("rally_end", {"w": winner_side, "r": reason, 
		"s1": _scores[1], "s2": _scores[-1], "rp": _replay_pending, 
		"ann": moment[0], "as": call_side, 

		"sc": int(_net_ids.get(roles.hero, 0)), 
		"bl": int(_net_ids.get(roles.villain, 0)), "kind": roles.tag})




	_music_rally_end(_replay_pending)
	_net_event("stats", {"r": _stat_rows()})
	if winners_ball and kill_power > 0.65:
		fx.slowmo(0.35, 0.8)
		crowd.cheer(1.0)
		_net_event("slowmo", {})
		_net_event("cheer", {"a": 1.0})
	else:
		crowd.cheer(0.45)
		_net_event("cheer", {"a": 0.45})




func _point_cam(hero: Player) -> void :
	if hero != null and _stage_shell != null and _stage_shell.has_method("show_point_player"):
		_stage_shell.show_point_player(hero)






func _kill_roles(winner_side: int, reason: String, scorer: Player, 
		winners_ball: bool, ann_key: String) -> Dictionary:
	var loser_last: Player = _rally.team_last_toucher.get( - winner_side)


	if reason == "ball out" and loser_last != null\
	and loser_last.last_touch == Player.TouchKind.BLOCK:
		return {"hero": scorer, "villain": loser_last, "tag": "block out"}

	if winners_ball and scorer != null:
		var tag: = "kill"
		if ann_key == "ace":
			tag = "ace"
		elif scorer.last_touch == Player.TouchKind.SPIKE:
			tag = "spike"
		elif scorer.last_touch == Player.TouchKind.DUMP:
			tag = "dump"
		return {"hero": scorer, "villain": null, "tag": tag}


	return {"hero": loser_last, "villain": null, "tag": _fault_tag(reason)}

func _fault_tag(reason: String) -> String:
	match reason:
		"foot fault", "line fault":
			return "foot fault"
		"serve foul", "outside the antenna", "illegal attack on serve", "four touches":
			return "fault"
		"ball out":
			return "out"
		_:
			return "error"




func _feed_data(hero: Player, villain: Player, tag: String) -> Dictionary:
	var d: = {"tag": tag}
	if hero != null and hero.character != null:
		d["hero"] = {"cfg": hero.character.to_dict(), "name": _feed_name(hero), 
			"home": _team_identity(hero.team_side) == 1, "pg": hero.party_mark}
	if villain != null and villain.character != null:
		d["villain"] = {"cfg": villain.character.to_dict(), "name": _feed_name(villain), 
			"home": _team_identity(villain.team_side) == 1}
	return d

func _feed_name(p: Player) -> String:
	return String(_names.get(p, ""))

func _win_set(winner_side: int) -> void :
	if player != null:
		_ach_set_end( func(body: Player): return winner_side == body.team_side)
	if int(_set_wins[winner_side]) + 1 >= GameConfig.sets_to_win:

		_set_wins[winner_side] = int(_set_wins[winner_side]) + 1
		_net_event("over", {"w": winner_side})
		_net_event("stats", {"r": _stat_rows()})


		_win_delay = WIN_TAIL
		_win_pending = winner_side
		return


	var winner_id: = _team_identity(winner_side)
	_net_event("set_end", {"w": winner_id})

	_pending_set = {"w": winner_side, "n": _set_number + 1}


	_swap_delay = SWAP_DELAY

	_serve_side = - winner_side
	_dead_timer = SET_BREAK_TIME







func _sync_home_side() -> void :
	if player == null or _spectating or player.team_side == 0:
		return
	var hs: = float(player.team_side)
	if camera_rig.home_side != hs:
		camera_rig.home_side = hs
		ball.home_side = hs
		camera_rig.face_net()





func _switch_sides() -> void :
	_point_wipe(_do_switch_sides)

func _do_switch_sides() -> void :

	if not _pending_set.is_empty():
		var w: = int(_pending_set["w"])
		_set_wins[w] = int(_set_wins[w]) + 1
		_scores = {1: 0, -1: 0}
		_run_side = 0
		_run_len = 0
		_set_number = int(_pending_set["n"])
		Rules.set_swapped = _set_number % 2 == 0
		_pending_set = {}
	for p in _all_players:
		var member: Player = p
		member.team_side = - member.team_side






	_set_wins = {1: _set_wins[-1], -1: _set_wins[1]}

	_rot = {1: _rot[-1], -1: _rot[1]}




	_last_serve_side = - _last_serve_side
	camera_rig.home_side = float(player.team_side)
	camera_rig.face_net()
	ball.home_side = float(player.team_side)






	_prepare_serve()
	_serve_prelaid = true
	var sides: Array = []
	for p in _all_players:
		sides.append([_net_ids.get(p, 0), (p as Player).team_side])
	_net_event("sides", {"l": sides})



func _on_predicted_strike(pos: Vector3, power: float, kind: int) -> void :





	_on_ball_struck(pos, power, kind)

func _on_ball_struck(pos: Vector3, power: float, kind: int, 
		flight_vel: = Vector3.INF) -> void :







	var burst_vel: = flight_vel if flight_vel.is_finite()\
	and flight_vel.length_squared() > 0.01 else ball.vel




	var strength: = Rules.contact_strength(kind, power)
	var snd: = Rules.contact_sound(kind, power)





	var fast_dig: = Player.is_fast_dig(kind, ball.dig_weight)
	if fast_dig:


		snd = {"n": "hit_hard", "db": lerpf(-2.0, 2.0, ball.dig_weight), "pt": 0.96}
	sfx.play(String(snd["n"]), pos, float(snd["db"]), float(snd["pt"]))


	var laid_out: = kind == Player.TouchKind.BLOCK or (ball.strike_source != null and ball.strike_source.diving())
	_music_heat_touch(kind, power, laid_out)



	var tier: = ball.combo_tier if kind == Player.TouchKind.SPIKE else 0
	if tier == 3:
		strength = maxf(strength, 1.0) * 1.35
	if kind == Player.TouchKind.SPIKE:
		_last_spike_power = power
		if power > 0.8 or tier == 3:
			fx.big_spike(pos, burst_vel, 
				Player.combo_color(tier) if tier >= 1 else Color(0, 0, 0, 0), tier)





		if ball.strike_source == player and ball.hitstop_left > 0.0:
			camera_rig.shake(minf(0.12 + ball.hitstop_left * 2.0, 0.4))





	var burst_tier: = tier
	if kind == Player.TouchKind.BUMP or kind == Player.TouchKind.SET:





		var recv_side: = ball.strike_source.team_side if ball.strike_source != null else 0
		var post_count: = 1 if recv_side != _rally.touch_side else _rally.touch_count + 1
		burst_tier = clampi(post_count, 1, 3)




	if fast_dig:




		strength = maxf(strength, 1.0) * 1.35
		fx.big_spike(pos, burst_vel, Player.combo_color(burst_tier), burst_tier)



		if ball.strike_source == player:
			camera_rig.shake(minf(0.12 + ball.dig_weight * 0.3, 0.4))

	_contact_fx(pos, strength, burst_vel, kind, burst_tier)







	ball.pulse()






	_net_event("strike", {"p": pos, "w": power, "k": kind, 
		"bp": ball.global_position, "bv": ball.vel, "c": ball.curve, 
		"sc": ball.stop_clock, 
		"fs": ball.float_seed if ball.float_serve else 0, 
		"tp": ball.tip_drop, 


		"sd": ball.strike_source is Player and (ball.strike_source as Player)._dump_rise > 0.0, 
		"dg": ball.dive_g, 
		"n": float(ball.strike_seq), 
		"ht": float(_net_tick) * 1000.0 / 60.0, 


		"hs": ball.hitstop_left, 
		"sv": laid_out, 
		"cb": ball.combo_tier, 
		"rw": ball.dig_weight, 
		"id": int(_net_ids.get(ball.strike_source, 0))})

func _net_hit_fx(hit_x: float, strength: = 1.0, hit_y: = 0.5) -> void :



	sfx.play("hit_soft", Vector3(hit_x, Ball.PHYS.net_height, 0.0), -4.0 + 4.0 * strength, 
		0.6)
	_net_wobble = maxf(_net_wobble, strength)


	for side in [-1, 1]:
		var rod: = court.get_node_or_null("AntennaEast" if side > 0 else "AntennaWest")
		if rod != null and rod.has_method("bob"):
			rod.call("bob", float(side), clampf(strength * 0.45, 0.2, 0.8))
	var mat: ShaderMaterial = (net_visual.mesh as PlaneMesh).material
	mat.set_shader_parameter("hit_x", hit_x / court.scale.x)
	mat.set_shader_parameter("hit_y", hit_y)
	if strength > 1.1:

		fx.puff(Vector3(hit_x, Ball.PHYS.net_height * hit_y * 2.0, 0.0))

func _net_hit_strength() -> float:


	return clampf(ball.last_net_impact / 13.0, 0.35, 1.9)

func _net_hit_height() -> float:

	return clampf(ball.global_position.y / Ball.PHYS.net_height, 0.0, 1.0)

func _on_net_hit() -> void :


	if _net_role != NetRole.CLIENT and _rally.live:
		_ach_cord = ball.strike_source as Player if ball.last_net_over else null
	var strength: = _net_hit_strength()
	var at_y: = _net_hit_height()
	_net_hit_fx(ball.global_position.x, strength, at_y)
	_net_event("net", {"x": ball.global_position.x, "s": strength, "y": at_y})

func _show_verdict(pos: Vector3, text: String, _winner: int) -> void :






	landing_marker.visible = true
	landing_marker.global_position = Vector3(pos.x, maxf(0.03, SandDeform.decal_y), pos.z)
	LandingCall.apply(landing_marker, verdict_label, text, LandingCall.call_color(text), 
		_half_w, _half_l)

func _hide_landing_call() -> void :
	landing_marker.visible = false

func _check_air_bumps() -> void :


	for hit in Rules.air_bumps(_all_players, GameConfig.team_collision_for(self)):
		var mid: Vector3 = hit.pos
		sfx.play("block_soft", mid, -4.0)
		_contact_fx(mid, 0.7, hit.dir)
		fx.puff(mid)
		_net_event("bump_fx", {"p": mid})


		var a: Player = hit.get("a")
		var b: Player = hit.get("b")
		if a == null or b == null:
			continue
		if bool(hit.get("a_dive", false)) or bool(hit.get("b_dive", false)):
			_ach_emit(a, "dive_crash", {})
			_ach_emit(b, "dive_crash", {})
		else:
			var mates: = a.team_side == b.team_side
			_ach_emit(a, "air_bump", {"mate": mates})
			_ach_emit(b, "air_bump", {"mate": mates})





func _check_stomps() -> void :
	for hit in Rules.stomps(_all_players, GameConfig.team_collision_for(self)):
		var pos: Vector3 = hit.pos
		var victim: Player = hit.victim
		_squash_fx(pos, victim)


		_net_event("squash_fx", {"p": pos, "v": _net_ids.get(victim, 0)})

		_ach_emit(hit.stomper, "stomp", {})






func _squash_fx(pos: Vector3, victim: Player = null) -> void :
	fx.land_poof(pos)
	fx.floor_gust(pos, true)
	sfx.play("block_soft", pos, -1.0, 0.75)
	sfx.play("squash", pos, 0.0, 1.0)

	var pitch: = 1.0
	if victim != null and is_instance_valid(victim) and victim.character != null:
		pitch = victim.character.voice_pitch()
	sfx.play("squash_voice", pos + Vector3(0.0, 0.8, 0.0), 0.0, pitch, false)

func _motion_foley(delta: float) -> void :

	for p in _all_players:
		var member: Player = p
		member.serving = member == _server and not _serve_done






	var sweat_target: = _net_sweat if _net_role == NetRole.CLIENT else _rally.sweat_target()
	if _net_role == NetRole.HOST and (absf(sweat_target - _sweat_sent) >= SWEAT_SEND_STEP or (sweat_target == 0.0 and _sweat_sent != 0.0)):
		_sweat_sent = sweat_target
		_net_event("sweat", {"v": snappedf(sweat_target, 0.01)})
	if sweat_target >= _sweat_shown:
		_sweat_shown = sweat_target
	else:
		_sweat_shown = maxf(_sweat_shown - delta / SWEAT_DRY_TIME, sweat_target)
	var sweat_level: = _sweat_shown
	_floor_mat.set_shader_parameter("sweat", sweat_level)
	_recorder.sweat = sweat_level
	hud.set_sweat(sweat_level)
	for p in _all_players:
		var member: Player = p
		member.sweat = sweat_level

		if member.sweat > 0.12:
			for _d in range(2):
				if randf() < member.sweat * 0.22:
					fx.sweat(member.global_position + Vector3(
						randf_range(-0.3, 0.3), randf_range(1.35, 1.7), 
						randf_range(-0.3, 0.3)))


	_foley.tick(_all_players, delta, sfx, fx)















var _stage_court_extras: Array = []
func _apply_stage_tracked() -> void :
	var before: = court.get_children()
	_apply_stage()
	_stage_court_extras = court.get_children().filter( func(n): return not before.has(n))

var _floor_base_shader: Shader = null

func _apply_stage() -> void :
	var id: = Stage.resolve(GameConfig.stage)
	if _floor_base_shader == null:
		_floor_base_shader = _floor_mat.shader


	if embedded:


		get_viewport().set_meta("stage_barefoot", bool(Stage.val(id, "barefoot", false)))
		get_viewport().set_meta("stage_reflections", bool(Stage.val(id, "reflect", true)))
		ball.stage_ball = id
	else:
		GameConfig.stage_barefoot = bool(Stage.val(id, "barefoot", false))
		GameConfig.stage_reflections = bool(Stage.val(id, "reflect", true))

	_foley.surface = String(Stage.val(id, "surface", "court"))
	Stage.apply_reverb(id)
	Stage.apply_time_of_day(id)


	_foley.water_x = float(Stage.val(id, "water_x", INF))
	_foley.water_side = float(Stage.val(id, "water_side", 1.0))



	crowd.set_active(Stage.has_crowd(id) and not _practice_dress)
	_floor_mat.set_shader_parameter("reflect_on", GameConfig.reflections_live(self))





	if bool(Stage.val(id, "owns_floor", false)):
		_floor_mat.shader = load("res://game/court/floor_overlay.gdshader")
		var cf: = court.get_node_or_null("CourtFloor") as MeshInstance3D
		if cf != null:
			cf.position.y += 0.06


	var shell: = (load(String(Stage.info(id).venue)) as PackedScene).instantiate()
	_stage_shell = shell
	add_child(shell)





	var gym: = shell.get_node_or_null("Gym")
	_stage_painted = {}
	_wall_base = {}
	if bool(Stage.val(id, "hand_painted", false)) and gym != null:

		for node in gym.find_children("*", "MeshInstance3D", true, false):
			if String(node.name).to_lower().contains("cutter"):
				(node as Node3D).visible = false
		_stage_painted = \
		(preload("res://game/court/env_paint.gd") as GDScript).apply(gym, 
			Stage.val(id, "emissive_mats", {}))


	_paint_stage_look(id)

	if not _stage_painted.is_empty() and gym != null:
		(preload("res://game/court/gym_props.gd") as GDScript).dress(shell, court, _last_accent)




	if Stage.has_crowd(id) and not _practice_dress:
		(preload("res://game/court/gym_crowd.gd") as GDScript).fill(shell, GameConfig.match_seed, 
			Stage.val(id, "seat_mats", []), Stage.val(id, "crowd_spacing", 0.0), 
			int(Stage.val(id, "crowd_max", 0)), Stage.val(id, "crowd_fill", 0.0), 
			Stage.val(id, "crowd_lift", 0.15), Stage.val(id, "crowd_push", 0.0), 
			Stage.val(id, "crowd_tint", Color(1, 1, 1)), 
			Stage.val(id, "crowd_haze_color", 
				(Stage.val(id, "haze_color", Color(0.83, 0.87, 0.93)) as Color).darkened(0.62)), 
			float(Stage.val(id, "crowd_haze", float(Stage.val(id, "haze_amt", 0.0)) * 2.7)), 
			Stage.val(id, "crowd_shade", {}))



	var cbox: Vector3 = Stage.val(id, "collision_box", Vector3.ZERO)
	var has_dome: = cbox != Vector3.ZERO and bool(Stage.val(id, "force_wall", false))
	if cbox != Vector3.ZERO:


		if has_dome:
			(preload("res://game/stage/stage_collision.gd") as GDScript).build_ring(shell, cbox)
		else:

			(preload("res://game/stage/stage_collision.gd") as GDScript).build_box(shell, cbox, 
				Stage.cam_box(id).size == Vector3.ZERO)
	elif gym != null and not _stage_painted.is_empty():
		(preload("res://game/stage/stage_collision.gd") as GDScript).build(gym)



	if has_dome:
		var fw: Node3D = (preload("res://game/court/force_dome.gd") as GDScript).new()
		shell.add_child(fw)
		fw.build(cbox, Stage.val(id, "force_wall_color", Color(0.28, 0.62, 1.0)))




	var backdrop: Dictionary = Stage.val(id, "backdrop", {})
	if not backdrop.is_empty():
		(preload("res://game/stage/stage_backdrop.gd") as GDScript).build(shell, backdrop, _half_w, _half_l)






	var grow_to: = _practice_grow_to()
	for piece in shell.get_children():
		if grow_to != Vector2.ZERO and piece.has_method("set_grow_to"):
			piece.call("set_grow_to", grow_to)
		if piece.has_method("configure"):
			piece.call("configure", _half_w, _half_l)
	_setup_sand_deform(id)
	_setup_grass(id)






func _setup_grass(_id: String) -> void :
	if _stage_shell == null:
		return
	for n in _stage_shell.find_children("*", "Node3D", true, false):
		if n.has_method("set_feeds"):
			n.set_feeds( func(): return _all_players, func(): return ball)




			if n.has_method("indicator_clearance_y"):
				SandDeform.decal_y = n.indicator_clearance_y()
				SandDeform.decal_y_feet = n.indicator_feet_y()





func _setup_sand_deform(id: String) -> void :
	SandDeform.decal_y = 0.0
	SandDeform.decal_y_feet = 0.0
	if _sand_deform != null:
		_sand_deform.queue_free()
		_sand_deform = null
	if _sand_deck != null:
		_sand_deck.queue_free()
		_sand_deck = null
	_sand_mat = null
	_floor_mat.set_shader_parameter("sand_on", false)





	var court_floor: = court.get_node_or_null("CourtFloor") as MeshInstance3D
	if String(Stage.val(id, "surface", "court")) != "sand":
		if court_floor != null:
			court_floor.visible = true
		return
	if court_floor != null:
		court_floor.visible = false


	var r: = SandDeform.build(self, id, _stage_shell, court, _half_w, _half_l, 
		func(): return _all_players, func(): return ball, 
		_practice_grow_to())
	_sand_deform = r.get("deform")
	_sand_deck = r.get("deck")
	_sand_mat = r.get("mat")
	_sand_surround_mat = r.get("surround")



func _paint_sand_look(id: String) -> void :
	SandDeform.paint_look(_sand_mat, id)

	SandDeform.paint_grade(_sand_mat, id)
	SandDeform.paint_grade(_sand_surround_mat, id)





func _paint_stage_look(id: String) -> void :

	Stage.paint_court_floor(_floor_mat, id, _half_w, _half_l)
	_paint_sand_look(id)
	Stage.dress_court(court, id)
	camera_rig.room_box = Stage.cam_box(id)
	if _watch_cam != null:
		_watch_cam.room_box = camera_rig.room_box


	if _stage_shell != null and _stage_shell.has_method("show_live_feed"):
		_stage_shell.show_live_feed(ball, _half_w, _half_l, camera_rig.camera, 
			camera_rig.room_box)


	aim_indicator.net_mat = (net_visual.mesh as PlaneMesh).material as ShaderMaterial
	aim_indicator.net_node = net_visual
	_apply_stage_env(id)
	if _stage_painted.is_empty():
		return


	var look: = Stage.config(id)
	if look != null and look.has_method("apply"):
		look.apply(_stage_painted)



	Stage.apply_recolors(_stage_painted, id, {}, _wall_base)






	var accents: Array = Stage.val(id, "accents", [])
	_last_accent = Color(0.85, 0.85, 0.85)
	_has_tape = false
	if accents.is_empty():
		return
	var pick: = absi(hash("school_accent:%d" % GameConfig.match_seed))
	_last_accent = accents[pick % accents.size()]
	var tapes: Array = Stage.val(id, "tape_by_accent", [])
	if not tapes.is_empty():
		_last_tape = tapes[pick % tapes.size()]
		_has_tape = true
	Stage.apply_school_accent(_stage_painted, court, id, _last_accent, 
		_last_tape if _has_tape else null, _wall_base)




func _apply_stage_env(id: String) -> void :
	ShadowSun.ensure(self)
	var we: = $WorldEnvironment as WorldEnvironment
	var env: = we.environment.duplicate() as Environment
	if bool(Stage.val(id, "use_sky_color", false)):
		env.background_mode = Environment.BG_COLOR
		env.background_color = Stage.val(id, "sky_color", Color(0.5, 0.74, 0.95))


	if bool(Stage.val(id, "anime_sky", false)):
		env.background_mode = Environment.BG_SKY
		var sky: = Sky.new()



		var sky_res: Variant = Stage.val(id, "sky_material", null)
		if sky_res is Material:
			sky.sky_material = sky_res
		else:
			var sky_mat: = ShaderMaterial.new()
			var custom_sky: Variant = Stage.val(id, "sky_shader", null)
			sky_mat.shader = custom_sky if custom_sky is Shader\
			else preload("res://game/court/anime_sky.gdshader")
			sky.sky_material = sky_mat





		sky.radiance_size = Stage.SKY_RADIANCE
		env.sky = sky



	env.glow_enabled = bool(Stage.val(id, "bloom", false)) and GameConfig.bloom
	if env.glow_enabled:
		env.glow_intensity = 0.6
		env.glow_strength = 0.9



		env.glow_bloom = 0.0
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
		env.glow_hdr_threshold = 1.0




	env.fog_enabled = bool(Stage.val(id, "fog", false))
	if env.fog_enabled:
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_light_color = Stage.val(id, "fog_color", Color(0.02, 0.03, 0.05))
		env.fog_light_energy = 1.0
		env.fog_depth_begin = float(Stage.val(id, "fog_begin", 20.0))
		env.fog_depth_end = float(Stage.val(id, "fog_end", 65.0))
		env.fog_depth_curve = float(Stage.val(id, "fog_curve", 1.0))
		env.fog_density = 1.0
		env.fog_sky_affect = float(Stage.val(id, "fog_sky", 0.0))
		env.fog_aerial_perspective = 0.0





		var hd: = float(Stage.val(id, "fog_height_density", 0.0))
		env.fog_height = float(Stage.val(id, "fog_height", 0.0))
		env.fog_height_density = - hd


	env.tonemap_exposure = float(Stage.val(id, "exposure", 1.0))
	we.environment = env
	var sun: = $Sun as DirectionalLight3D
	if _sun_base_energy < 0.0:
		_sun_base_energy = sun.light_energy
	sun.light_energy = _sun_base_energy * float(Stage.val(id, "sun", 1.0))




func relight_stage() -> void :
	var id: = Stage.resolve(GameConfig.stage)
	Stage.config(id, true)
	_paint_stage_look(id)





func _own_name_visible(phase: int) -> bool:
	return GameConfig.show_own_name\
	or phase == Phase.INTRO or phase == Phase.COUNTDOWN\
	or phase == Phase.WIN or phase == Phase.STATS






var _hl_prev: Player = null
func _apply_touch_highlight(lt: Player) -> void :

	if not GameConfig.touch_highlight or _cfg_size() <= 1:
		lt = null

	for p in _all_players:
		var b: Player = p
		if b == lt:



			b.set_highlight(Rules.side_color(_team_identity(b.team_side)))
		else:
			b.set_highlight(Color(0.0, 0.0, 0.0, 0.0))




	if lt != null and lt != _hl_prev:
		lt.flash_touch(Rules.side_color(_team_identity(lt.team_side)))
	_hl_prev = lt








func _apply_nametags() -> void :
	var my_team: = 0
	if player != null and not _spectating:
		my_team = player.team_side



	var phase: = _effective_phase()



	var reveal: = _practice != null or phase == Phase.DEAD or phase == Phase.SERVE_PREP\
	or phase == Phase.COUNTDOWN or phase == Phase.INTRO\
	or phase == Phase.WIN or phase == Phase.STATS
	for p in _all_players:
		var body: Player = p
		var want: = String(_names.get(body, body.display_name()))
		var tag: PlayerNameplate = body.get_node("NameTag") as PlayerNameplate



		body.set_rally_live( not reveal)
		var local_slot: LocalPlayerSlot = LocalPlayers.primary() if _is_own_body(body) else null
		for seat in _seats:
			if seat.body == body:
				local_slot = seat.slot


		if not _views.is_empty() and not LocalViews.is_collapsed(_views) and not _spectating:
			var mask: = 0
			var badge_mask: = 0
			for view in _views:
				var own: = local_slot != null
				var ally: = false
				for owner in view.owners:
					var owner_body: = _body_for_slot(owner)
					ally = ally or (owner_body != null and owner_body.team_side == body.team_side)



				if local_slot != null:
					badge_mask |= view.private_mask()
				var local_visible: bool = _own_name_visible(phase) and not (
					_badges_shown and phase == Phase.COUNTDOWN and not GameConfig.show_own_name)
				if (reveal or ally) and ( not own or local_visible):
					mask |= view.private_mask()
			body.set_seat_badge_layers(badge_mask)
			tag.layers = mask
			tag.visible = mask != 0 and not body.names_suppressed
			if body.display_name() != want:
				body.set_display_name(want)
			continue





		var on_world: = tag.layers == 1 or tag.layers == LocalViews.FEED_HIDE_MASK
		if not on_world:
			tag.visible = not body.names_suppressed
			tag.layers = 1
		body.set_seat_badge_layers(1)
		if local_slot != null and _badges_shown and phase == Phase.COUNTDOWN and not GameConfig.show_own_name:
			tag.visible = false
		if my_team != 0 and body != player and body.team_side != my_team\
		and not reveal:
			want = ""
		if body.display_name() != want:
			body.set_display_name(want)

func _update_indicators(input: PlayerInput) -> void :
	if not _spectating and player != null:
		player.set_name_visible(_own_name_visible(_phase))
		player.set_first_person(
			camera_rig.mode == CameraRig.Mode.FIRST_PERSON)
	for seat in _seats:

		seat.body.set_name_visible(_own_name_visible(_phase))
		if seat.rig != null:
			seat.body.set_first_person(seat.rig.mode == CameraRig.Mode.FIRST_PERSON)
	_apply_touch_highlight(_last_toucher if _phase == Phase.LIVE else null)
	_apply_nametags()
	if _phase == Phase.REPLAY:



		hud.set_scoreboard_visible(( not _spectating or _spec_ui) and _practice == null)
		_present_replay(get_physics_process_delta_time())
		return
	if _phase != Phase.DEAD and _phase != Phase.SERVE_PREP and _phase != Phase.LIVE:
		_diss_left = 0.0
		_cine_present(_phase, _cine_time)
		if _phase == Phase.COUNTDOWN:
			_countdown_aim(input)
		return
	_tick_dissolve(get_physics_process_delta_time())







	hud.set_scoreboard_visible(( not _spectating or _spec_ui) and _practice == null)
	hud.set_play_hud_visible( not _spectating)
	var ball_side: = signf(ball.global_position.z)
	if ball_side != 0.0:
		camera_rig.possession = ball_side



	camera_rig.focus_boost = 0.0
	var ally_serving: = _server != null and _server.team_side == player.team_side
	if _phase == Phase.SERVE_PREP:
		camera_rig.focus_boost = 1.0 if ally_serving else 0.25
	elif _phase == Phase.LIVE and ally_serving and not _serve_crossed\
	and ball.global_position.z * player.team_side\
	> player.global_position.z * player.team_side:
		camera_rig.focus_boost = 1.0
	var free: = camera_rig.mode == CameraRig.Mode.ACTION or camera_rig.mode == CameraRig.Mode.FIRST_PERSON



	aim_indicator.visible = not free and not _spectating and not _one_picture()
	aim_indicator.ring_enabled = GameConfig.crosshair_ring
	var aim_ib: = absf(input.aim.x) <= _half_w and absf(input.aim.z) <= _half_l
	if not _spectating:
		aim_indicator.aim_at(input.aim, float(player.team_side), aim_ib, 
			camera_rig.shake_offset, _p1_reticle_force(input.aim.z, aim_ib))
	_update_barred_marker(_rally_live and not _spectating)
	player.serve_charge_ui = _phase == Phase.SERVE_PREP and _server == player\
	and not _spectating

	camera_rig.serve_view = _server == player and not _spectating\
	and (_phase == Phase.SERVE_PREP\
	or (_phase == Phase.LIVE and not _serve_done))
	_draw_p1_sight(free and not _spectating, input.aim.z, aim_ib)
	hud.set_touches(_touch_count)
	var p1h: = _hints_for_p1()
	if p1h != null:
		p1h.set_dive(player.dive_cooldown)
	else:
		hud.set_dive(player.dive_cooldown)








	var h: = _team_identity(1)
	hud.set_score_colors(1)
	hud.set_score(_scores[h], _scores[ - h], 
		_set_wins[h], _set_wins[ - h], _set_number)
	hud.set_serve_prompt(_serve_prompt(), 
		_phase == Phase.SERVE_PREP and _server == player, _serve_clock)



	var zsrv: Player = _server if GameConfig.debug_serve_zones\
	else (_server if _is_local_human(_server) and not _spectating else null)
	_serve_zone.tick(_phase == Phase.SERVE_PREP and zsrv != null, 
		float(zsrv.team_side) if zsrv != null else 1.0, 
		zsrv != null and _rally.in_safe_serve_spot(zsrv))
	_place_serve_zone_view(zsrv)
	if GameConfig.show_cam_debug:
		hud.set_net_info(camera_rig.debug_line())
	elif _net_role == NetRole.OFFLINE:
		hud.set_net_info("")
	_update_controls(_phase == Phase.SERVE_PREP and _server == player)

	hud.update_state(player)






func _countdown_aim(input: PlayerInput) -> void :
	if player == null:
		return
	var free: = camera_rig.mode == CameraRig.Mode.ACTION\
	or camera_rig.mode == CameraRig.Mode.FIRST_PERSON
	aim_indicator.visible = not free and not _spectating and not _one_picture()
	aim_indicator.ring_enabled = GameConfig.crosshair_ring
	if _spectating:
		return
	var ib: = absf(input.aim.x) <= _half_w and absf(input.aim.z) <= _half_l
	aim_indicator.aim_at(input.aim, float(player.team_side), ib, 
		camera_rig.shake_offset, _p1_reticle_force(input.aim.z, ib))
	_draw_p1_sight(free, input.aim.z, ib)

func _update_indicators_client(input: PlayerInput) -> void :

	var phase: = int(_np.get("ph", Phase.DEAD))



	_set_number = int(_np.get("sn", _set_number))
	Rules.set_swapped = _set_number % 2 == 0


	var srv_body: Player = _by_net_id.get(int(_np.get("sv", 0)))
	var zsrv: Player = srv_body if GameConfig.debug_serve_zones\
	else (srv_body if _is_local_human(srv_body) and not _spectating else null)
	_serve_zone.tick(phase == Phase.SERVE_PREP and zsrv != null, 
		float(zsrv.team_side) if zsrv != null else 1.0, 
		zsrv != null and _rally.in_safe_serve_spot(zsrv))
	_place_serve_zone_view(zsrv)
	if not _spectating and player != null:
		player.set_name_visible(_own_name_visible(phase))
		player.set_first_person(
			camera_rig.mode == CameraRig.Mode.FIRST_PERSON)



	for seat in _seats:
		seat.body.set_name_visible(_own_name_visible(phase))
		if seat.rig != null:
			seat.body.set_first_person(seat.rig.mode == CameraRig.Mode.FIRST_PERSON)



	_apply_nametags()
	_apply_touch_highlight(_by_net_id.get(int(_np.get("lt", 0)))\
	if phase == Phase.LIVE else null)
	if phase != Phase.DEAD and phase != Phase.SERVE_PREP and phase != Phase.LIVE:

		if phase != _cine_prev_phase:
			_cine_time = 0.0
			_cine_t0_us = Time.get_ticks_usec()
			if phase == Phase.INTRO:
				_grabbed_home = false
				_intro_reset()
				_intro_walk_armed = _intro_swoop
			elif phase == Phase.WIN:
				_win_reset()
			elif _cine_prev_phase == Phase.INTRO and not _loading_up:
				hud.set_loading(0.0)





			if (phase == Phase.COUNTDOWN or phase == Phase.WIN)\
			and not _loading_up and not MIGRATION_COVER.is_up():
				hud.grab_dissolve()
				_win_grabbed = phase == Phase.WIN
			else:
				hud.set_dissolve(0.0)
				_win_grabbed = false
			if phase != Phase.STATS:
				_stats_built = false





		_cine_time = float(Time.get_ticks_usec() - _cine_t0_us) / 1000000.0
		_cine_prev_phase = phase
		_diss_left = 0.0
		player.cinematic_hidden = true

		ball.visible = phase == Phase.COUNTDOWN
		if phase == Phase.COUNTDOWN:


			_pre_intro = false
		_cine_present(phase, _cine_time)
		if phase == Phase.COUNTDOWN:
			_countdown_aim(input)
		return
	if _cine_prev_phase == Phase.STATS or _cine_prev_phase == Phase.WIN:
		hud.hide_match_stats()
		hud.hide_cine_name()
	if _cine_prev_phase == Phase.COUNTDOWN or _cine_prev_phase == Phase.INTRO:



		hud.hide_countdown()
		hud.hide_cine_name()






		if _diss_left <= 0.0:
			hud.set_dissolve(0.0)
		if not _loading_up:
			hud.set_loading(0.0)
	_cine_prev_phase = phase
	_tick_dissolve(get_physics_process_delta_time())
	player.cinematic_hidden = false


	ball.visible = not _pre_intro and (_practice == null or _practice.ball_shown())



	hud.set_scoreboard_visible(( not _spectating or _spec_ui) and _practice == null)
	hud.set_play_hud_visible( not _spectating)
	var server: Player = _by_net_id.get(int(_np.get("sv", 0)))
	var ball_side: = signf(ball.global_position.z)
	if ball_side != 0.0:
		camera_rig.possession = ball_side
	camera_rig.focus_boost = 0.0
	var ally_serving: = server != null and server.team_side == player.team_side
	if phase == Phase.SERVE_PREP:
		camera_rig.focus_boost = 1.0 if ally_serving else 0.25
	elif phase == Phase.LIVE and ally_serving\
	and ball.global_position.z * player.team_side\
	> player.global_position.z * player.team_side:
		camera_rig.focus_boost = 1.0
	var free: = camera_rig.mode == CameraRig.Mode.ACTION or camera_rig.mode == CameraRig.Mode.FIRST_PERSON







	aim_indicator.visible = not free and not _spectating and not _ball_dead\
	and not _one_picture()
	aim_indicator.ring_enabled = GameConfig.crosshair_ring
	var caim_ib: = absf(input.aim.x) <= _half_w and absf(input.aim.z) <= _half_l
	if not _spectating:
		aim_indicator.aim_at(input.aim, float(player.team_side), caim_ib, 
			camera_rig.shake_offset, _p1_reticle_force(input.aim.z, caim_ib))
	_update_barred_marker(_rally_live and not _spectating)
	player.serve_charge_ui = phase == Phase.SERVE_PREP and server == player\
	and not _spectating
	camera_rig.serve_view = server == player and not _spectating\
	and (phase == Phase.SERVE_PREP\
	or (phase == Phase.LIVE and not bool(_np.get("sd", true))))
	_draw_p1_sight(free and not _spectating, input.aim.z, caim_ib)
	hud.set_touches(int(_np.get("tc", 0)))
	var p1h: = _hints_for_p1()
	if p1h != null:
		p1h.set_dive(player.dive_cooldown)
	else:
		hud.set_dive(player.dive_cooldown)
	var s1: = int(_np.get("s1", 0))
	var s2: = int(_np.get("s2", 0))
	var w1: = int(_np.get("w1", 0))
	var w2: = int(_np.get("w2", 0))
	var sn: = int(_np.get("sn", 1))




	var h: = _team_identity(1, sn)
	hud.set_score_colors(1)
	if h > 0:
		hud.set_score(s1, s2, w1, w2, sn)
	else:
		hud.set_score(s2, s1, w2, w1, sn)
	hud.set_serve_prompt("spectating: c changes camera" if _spectating\
	else _client_serve_prompt(phase, server), 
		phase == Phase.SERVE_PREP and server == player and not _spectating, 
		float(_np.get("sc", 0.0)))

	hud.update_state(player)
	_update_controls(phase == Phase.SERVE_PREP and server == player\
	and not _spectating)











func _update_barred_marker(live: bool) -> void :
	var barred: = live and player.touch_barred_self
	barred_marker.visible = barred
	ball.landing_ring_muted = barred
	if barred:



		barred_marker.global_position = Vector3(ball.global_position.x, 
			maxf(0.03, SandDeform.decal_y), ball.global_position.z)


	for seat in _seats:
		var sb: Node3D = seat.get("barred")
		if sb == null:
			continue
		sb.visible = live and seat.body.touch_barred_self
		if sb.visible:
			sb.global_position = Vector3(ball.global_position.x, 
				maxf(0.03, SandDeform.decal_y), ball.global_position.z)
	_split_landing_mute(live, barred)






func _split_landing_mute(live: bool, p1_barred: bool) -> void :
	if _views.size() < 1 or _views[0].box == null or LocalViews.is_collapsed(_views):
		ball.set_hint_view_masks(0, 0)
		return
	var ring_mask: = 0
	var shadow_mask: = 0
	for view in _views:
		var all_barred: = true
		for owner in view.owners:
			var b: = _body_for_slot(owner)
			var is_barred: bool = p1_barred if b == player\
			else (live and b != null and b.touch_barred_self)
			all_barred = all_barred and is_barred
		if all_barred:
			shadow_mask |= view.private_mask()
		else:
			ring_mask |= view.private_mask()
	if shadow_mask == 0:
		ball.landing_ring_muted = false
		ball.set_hint_view_masks(0, 0)
	elif ring_mask == 0:
		ball.landing_ring_muted = true
		ball.set_hint_view_masks(0, 0)
	else:
		ball.landing_ring_muted = false
		ball.set_hint_view_masks(ring_mask, shadow_mask)




func _hints_should_hide() -> bool:
	return _phase == Phase.INTRO or _phase == Phase.COUNTDOWN\
	or _phase == Phase.WIN or _phase == Phase.STATS or _phase == Phase.REPLAY\
	or _spectating



var _badges_shown: = false

func _tick_badges() -> void :
	if not _badges_shown:
		return


	var phase: = _effective_phase()
	var show: bool = phase == Phase.SERVE_PREP or phase == Phase.DEAD\
	or phase == Phase.COUNTDOWN or hud.pause_is_open()

	if not _spectating and player != null:
		player.show_seat_badge(show)
	for seat in _seats:
		if is_instance_valid(seat.body):
			seat.body.show_seat_badge(show)

func _gate_cinematic_hints() -> void :
	if not _hints_should_hide():
		return
	hud.set_hints_hidden(true)
	if _p1_hints != null:
		_p1_hints.set_hidden(true)
	for seat in _seats:
		var h = seat.get("hints")
		if h != null:
			h.set_hidden(true)

func _update_controls(serving: bool) -> void :


	var cine: = _hints_should_hide()
	var mine: = _hints_for_p1()



	var shared_any: = false
	for v in _views:
		if v.owners.size() > 1:
			shared_any = true
			break
	var split_up: bool = shared_any\
	or (_views.size() >= 2 and not LocalViews.is_collapsed(_views))
	hud.set_hints_hidden(cine or mine != null or split_up)
	if mine != null:
		mine.set_hidden(cine)
		mine.refresh(player, serving)
	elif not split_up:
		hud.refresh_controls(player, serving)

	for seat in _seats:
		if seat.get("hints") == null or not is_instance_valid(seat.body):
			continue
		seat.hints.set_hidden(cine)
		seat.hints.refresh(seat.body, _server == seat.body and (_phase == Phase.SERVE_PREP or (_phase == Phase.LIVE and not _serve_done)))
		seat.hints.set_dive(seat.body.dive_cooldown)

func _client_serve_prompt(phase: int, server: Player) -> String:
	if phase != Phase.SERVE_PREP or server == null or _practice != null:
		return ""
	var clock: = float(_np.get("sc", 0.0))
	if server != player:
		return "%s serving   %0.0f" % [_names[server], clock]
	if not _in_serve_zone(player):
		return "return to serve zone   %0.0f" % clock
	return "your serve   hold to toss   %0.0f" % clock

func _serve_prompt() -> String:
	if _phase != Phase.SERVE_PREP or _practice != null:
		return ""
	if _server != player:
		return "%s serving   %0.0f" % [_names[_server], _serve_clock]
	if not _in_serve_zone(player):
		return "return to serve zone   %0.0f" % _serve_clock
	return "your serve   hold to toss   %0.0f" % _serve_clock

func _poll_stats_input() -> void :



	if hud == null:
		return
	if _match_over or _migrating or hud.pause_is_open() or _practice != null:
		hud.hide_stats()
		return
	if Input.is_action_pressed("stats"):
		var rows: Array = _stat_rows() if _net_role != NetRole.CLIENT\
		else hud.stored_stat_rows()
		hud.show_stats(rows)
	elif Input.is_action_just_released("stats"):
		hud.hide_stats()

func _stat_rows() -> Array:



	var body_peer: = {}
	if not _spectating:
		body_peer[player] = 1
	for peer_id in _peer_players:
		body_peer[_peer_players[peer_id]] = peer_id
	var rows: Array = []
	for p in _all_players:
		var member: Player = p


		var s: Dictionary = _stats.get(member, {})
		var row_name: = String(_names.get(member, ""))
		var pgroup: = int(_party_of.get(member, 0)) if PartyMark.ENABLED else 0




		if _net_role == NetRole.HOST and _is_own_body(member):
			pass




		var mpeer: = int(body_peer.get(member, 0))
		var mping: = -2
		if mpeer == 1:
			mping = -1

		elif mpeer > 1:
			mping = int(round(Net.peer_rtt_ms(mpeer)))
		rows.append({
			"name": row_name, "ready_name": String(_names.get(member, "")), 
			"pts": int(s.get("pts", 0)), "spk": int(s.get("spk", 0)), 
			"blk": int(s.get("blk", 0)), 
			"rcv": int(s.get("rcv", 0)), "set": int(s.get("set", 0)), 
			"ast": int(s.get("ast", 0)), 
			"ace": int(s.get("ace", 0)), "dig": int(s.get("dig", 0)), 
			"side": _team_identity(member.team_side), 
			"party": pgroup, 
			"peer": mpeer, "ping": mping, 
			"cfg": member.character.to_dict() if member.character != null else {}, 
		})

	return rows
