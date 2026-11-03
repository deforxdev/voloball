extends Node3D













const SETTINGS_PANEL: = preload("res://game/ui/settings_panel.tscn")
const PAD_KEYBOARD: = preload("res://game/ui/style/pad_keyboard.gd")
const PAD_NAV: = preload("res://game/ui/style/pad_nav.gd")
const SOLO_POINTER: = preload("res://game/ui/solo_pointer.gd")


const FEEDBACK_FORM_URL: = ""


const DISCORD_URL: = ""


const DISCORD_ICON: = "res://game/images/discord.png"
const DISCORD_BLURPLE: = Color("5865f2")

const WISHLIST_BLUE: = Color("1a9fff")
const HOW_TO_PLAY: = preload("res://game/ui/how_to_play.tscn")
const HUD_SCENE: = preload("res://game/ui/hud.tscn")
const PLAYER_SCENE: = preload("res://game/player/player.tscn")
const BALL_SCENE: = preload("res://game/ball/ball.tscn")
const COURT_SCENE: = preload("res://game/court/court.tscn")
const LOGO: = preload("res://game/logo/jvlogo_sd.png")


const SWEAT_RATES: = [0.0, 1.0, 3.0, 8.0]
const SWEAT_RATE_NAMES: = ["off", "normal", "fast", "chaos"]


const SERVE_TIMES: = [15, 20, 30, 45, 60]
const COURT_HW: = 7.6
const COURT_HL: = 13.6
const HALL_X: = 17.0
const HALL_Z: = 21.0
const HOME_SPOT: = Vector3(6.3, 0.0, 9.2)
const DIFF_NAMES: = ["cpu: easy", "cpu: normal", "cpu: hard"]


const OUTFITS: = ["gym", "captain", "pinny"]
const OUTFIT_LABELS: = {"gym": "gym", "captain": "captain uniform", "pinny": "pinny"}


const BALL_SKINS: = ["nationals", "school", "beach"]
const BALL_LABELS: = {"nationals": "pro", "school": "school", "beach": "outdoor"}



const PARTY_SPOTS: = [
	Vector3(0.0, 0.0, 0.0), 
	Vector3(-1.7, 0.0, 0.0), 
	Vector3(-3.2, 0.0, -0.3), 
	Vector3(-0.9, 0.0, -1.6), 
	Vector3(-2.4, 0.0, -1.8), 
	Vector3(-3.9, 0.0, -1.4), 
]

@onready var menu_cam: Camera3D = $MenuCam
@onready var camera_rig: CameraRig = $CameraRig
@onready var ui: CanvasLayer = $Ui

var player: Player = null
var ball: Ball = null
var fx: Fx = null
var sfx: Sfx = null
var hud: Hud = null
var _chat: ChatPanel = null
var aim_indicator: AimMarker = null
var _toss_preview: TrajectoryPreview = null
var _menu_net_node: MeshInstance3D = null
var _menu_net_mat: ShaderMaterial = null
var reach_marker: ReachMarker = null
var _floor_mat: ShaderMaterial = null
var _foley: = Foley.new()
var _input_collector: = InputCollector.new()

var _local_guests: Array = []



var _fp_views: Array = []
var _configs: Control = null
var _configs_row: HBoxContainer = null


var _cfg_panels: Array[CfgPanel] = []


var _cfg_left_cd: = 0.0
var _cfg_disconnect_all: Button = null
var _side_polls: = {}
var _quick_find_btn: Button = null
const LOCAL_COOP_DROPIN: = true
var _freeplay: = false
var _serving: = false
var _aim_at_cam: = Vector3.ZERO
var _base_yaw: = 0.0
var _spin: = 0.0
var _dragging: = false
var _outfit: = "gym"
var _ball_skin: = "nationals"
var _freeplay_stage: = Stage.home()
var _arena_nodes: Array[Node] = []
var _stage_btn: Button = null
var _reflector = null
var _sand_deform: SandDeform = null
var _swapping_stage: = false

var _root: Control = null
var _home: Control = null
var _online: Control = null
var _local: Control = null
var _practice: Control = null
var _profile: Control = null
var _career: Control = null
var _achievements: Control = null
var _awards_tab: Button = null
var _awards_badge: Label = null
var _awards: Control = null
var _profile_pfp: TextureRect = null
var _recent: Control = null
var _custom: Control = null
var _settings: Control = null
var _howto: Control = null


var _browse: Control = null
var _host: Control = null
var _room: Control = null
var _direct: Control = null



var _local_choose: Control = null


var _lan_mode: = false
var _fp_hint: Control = null
var _quick: Control = null
var _qp: QuickPlay = null





var _practice_court: PracticeCourt = null
var _practice_layer: CanvasLayer = null
var _practice_on: = false
var _practice_enter_on_start: = false
var _practice_check_t: = 3.0




const PRACTICE_PREWARM_IDLE: = 2.0
var _practice_prewarm: = false
var _practice_solo: = false





var _always_court: = false
var _menu_idle_t: = 0.0
var _mm_label: Label = null
var _mm_cancel: Button = null
var _quick_chips: = {}
var _quick_any: Button = null
var _quick_fresh: CheckBox = null
var _top_panel: Control = null
var _bottom_panel: PanelContainer = null
var _bar_normal: StyleBoxFlat = null
var _bar_green: StyleBoxFlat = null
var _top_normal: StyleBoxFlat = null
var _top_green: StyleBoxFlat = null
var _steam_pill: Label = null
var _mm_title: Label = null
var _mm_chip: PanelContainer = null
var _mm_chip_label: Label = null



var _pc_avatar: TextureRect = null
var _pc_name: Label = null
var _pc_level: Label = null
var _pc_xp: LiquidBar = null
var _pc_xp_text: Label = null
var _pc_seen_profile: SavedProfile = null
var _pc_seen_level: = 0
var _pc_coins: Label = null
var _pc_purse: Control = null
var _purse_air: = 0
var _pc_div: Panel = null
var _member_queuing: = false
var _friends_btn: Button = null
var _discord_btn: Button = null
var _wishlist_btn: Button = null
var _version_label: Label = null
var _friends_panel: PanelContainer = null
var _friends_list: VBoxContainer = null
var _friends_scrim: Control = null
var _invited_ids: = {}
var _shift_lan: = false
var _friends_poll: = 0.0



var _fake_friends: Variant = null
var _fake_friends_churn: = false
var _fake_rng: = RandomNumberGenerator.new()


var _tilt: Array = []


var _lean: Array = []
var _top_strip: Panel = null
var _bottom_strip: Panel = null
var _logo_rect: TextureRect = null
var _tilt_fake: = 0.0
var _cam_side_target: = 1.0
var _cam_look_now: = Vector3.ZERO

var _steam_up: = false
var _browse_hint: Label = null
var _browse_list: VBoxContainer = null

var _bw_search: LineEdit = null
var _bw_search_gen: = 0
var _bw_code: LineEdit = null
var _bw_join_btn: Button = null
var _bw_cancel: Button = null
var _bw_joining: = false
var _bw_quiet_leave: = false
var _join_gen: = 0
var _bw_region: UiSelect = null
var _bw_sort: UiSelect = null
var _bw_full: CheckBox = null
var _bw_friends: CheckBox = null
var _bw_auto: CheckBox = null
var _bw_rows: Array = []
var _bw_auto_t: = 0.0

const BW_REGIONS: = ["closest", "nearby", "far", "worldwide"]
const BW_REGION_MS: = [70, 140, 260, 1000000]
var _side_btns: Dictionary = {}
var _side_tell: Label = null
var _blue_list: VBoxContainer = null
var _red_list: VBoxContainer = null
var _spec_list: VBoxContainer = null
var _size_opt: UiSelect = null
var _diff_opt: UiSelect = null
var _stage_opt: UiSelect = null
var _start_btn: Button = null
var _room_hint: Label = null

var _room_sets: UiSelect = null
var _room_points: SpinBox = null
var _room_wbt: CheckBox = null
var _room_sweat: CheckBox = null
var _room_rate: UiSelect = null
var _priv_opt: UiSelect = null
var _max_players_opt: UiSelect = null



const MAX_PLAYER_CHOICES: = [2, 4, 6, 8, 10, 12, 14]
var _settings_panel: SettingsPanel = null
var _settings_title: Label = null
var _pw_edit: LineEdit = null
var _host_status: Label = null
var _host_steam_card: Control = null
var _host_party_card: Control = null
var _ip_edit: LineEdit = null
var _direct_pw: LineEdit = null
var _direct_status: Label = null
var _pw_panel: PanelContainer = null
var _joining_live: = false
var _online_ready: = false
var _party_strip: HBoxContainer = null
var _party_was_open: = false




var _top_bar: HBoxContainer = null
var _bottom_bar: HBoxContainer = null
var _zone_cd: = 0.0


var _card_local: Button = null
var _card_custom_lobby: Button = null
var _card_direct: Button = null
var _replays_tab: Button = null

var _party_bodies: = {}


var _party_guest_bodies: = {}
var _party_balls: = {}
var _carom_seen: = {}
var _fp_ball_prev: = {}
var _fp_hit_side: = {}




var _ball_driver: = {}
















const SHARED_BALL: = false
var _shared_ball_on: = SHARED_BALL or "--fp-shared-ball" in LaunchGate.dev_args()
const PARTY_BALL_OUTLINE: = Color(1.0, 0.82, 0.16)
const FX_BALL_AWAY: = -6
const BALL_ACTIONS: = ["ball_spawn", "ball_despawn"]
const BALL_PARK: = Vector3(0.0, -60.0, 0.0)
var _ball_out: = true






var _ball_gen: = {}
var _ball_away: = {}
var _ball_auto_until: = 0
var _no_party_ball_ms: = 0
var _p1_ball_input: = DeviceInput.new()




const CALLOUT_ACTIONS: = Player.QUICK_CHAT_ACTIONS


const FX_CALLOUT: = -5
var _p1_callout: = DeviceInput.new()
var _callout_polls: = {}
var _party_outfit: = {}
var _party_ball_skin: = {}
var _party_in_freeplay: = {}
var _fake_party_n: = 0
var _party_puppets: = NetSync.PuppetBuffer.new()
var _party_ball_buf: = NetSync.BallBuffer.new()
var _party_seen: = {}

var _reform_target: = {}
var _reform_left: = 0.0
var _reform_wait: = 0.0
var _fold_dial_t: = 0.0



const REGROUP_WINDOW: = 30.0
const REGROUP_FIRST_DIAL: = 1.5
const REFORM_RETRY_GAP: = 0.75




const REFORM_DIAL_GIVEUP: = 6.0
var _reform_dial_t: = 0.0


var _home_notice: = {}
var _notice_stack: Array[Control] = []

var _server_join: = {}
var _server_join_t: = 0.0



var _in_party_room: = false


const PARTY_RELAY_FLUSH: = 0.35
var _fp_send_tick: = 0
var _drill_runner: DrillRunner = null
var _drill_progress: = DrillProgress.new()
var _drill_active: = ""
var _drill_hud: PanelContainer = null
var _drill_title: Label = null
var _drill_instruction: Label = null
var _drill_count: Label = null
var _drill_timer: Label = null
var _drill_info: PanelContainer = null
var _drill_info_body: VBoxContainer = null
var _drill_results: PanelContainer = null
var _drill_result_time: Label = null
var _drill_next: Button = null



const GUIDED_PATH: = ["movement", "receiving_1", "setting_1", "spiking_1"]
var _guided: = false
var _tutorial = null
const TUTORIAL_DIRECTOR: = preload("res://game/drills/tutorial_director.gd")
const TUTORIAL_OVERLAY: = preload("res://game/ui/tutorial_overlay.gd")
const DRILL_DIRECTOR: = preload("res://game/drills/drill_director.gd")

var _drill_director = null
var _drill_overlay: Control = null
var _drill_return_stage: = ""

func _ready() -> void :
	if MobileRender.enabled():
		MobileRender.apply()
		GameConfig.stage = "grass"
		GameConfig.freeplay_stage = "grass"
		_freeplay_stage = "grass"

	set_meta(GameConfig.STAGE_WORLD, true)
	GameConfig.tod_live = false
	GameConfig.menu_open = true


	LocalPlayers.can_join = _couch_may_join
	if not LocalPlayers.join_refused.is_connected(_on_couch_refused):
		LocalPlayers.join_refused.connect(_on_couch_refused)





	if not Net.in_match:
		GameConfig.quick_match = false


	AppData.boot_succeeded()
	TITLES.warm()


	if not GameConfig.pre_tutorial_settings.is_empty():
		var r: Dictionary = GameConfig.pre_tutorial_settings
		GameConfig.stage = Stage.resolve(String(r.get("stage", GameConfig.stage)))
		GameConfig.difficulty = int(r.get("difficulty", GameConfig.difficulty))
		GameConfig.team_size = int(r.get("team_size", GameConfig.team_size))
		GameConfig.set_points = int(r.get("set_points", GameConfig.set_points))
		GameConfig.sets_to_win = int(r.get("sets_to_win", GameConfig.sets_to_win))
		GameConfig.win_by_two = bool(r.get("win_by_two", GameConfig.win_by_two))
		GameConfig.local_side = int(r.get("local_side", GameConfig.local_side))
		GameConfig.simple_bot_serves = false
		GameConfig.tutorial_finale = false
		GameConfig.pre_tutorial_settings = {}


	var bubbles: = ChatBubbles.new( func():
		var out: Array = _party_bodies.values()
		if player != null:
			out.append(player)
		return out, func(): return player, 
		func(): return _freeplay, 


		func(pid: int):
			if pid == _my_party_id():
				return player
			return _party_bodies.get(pid, null), 

		func(): return _practice_solo)
	add_child(bubbles)
	if "--bubble-demo" in LaunchGate.dev_args():
		_bubble_demo.call_deferred()
	GameConfig.use_cursor(false)
	Rules.set_swapped = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not InputPrompts.changed.is_connected(_on_input_device_changed):
		InputPrompts.changed.connect(_on_input_device_changed)
	GameConfig.net_roster = []
	GameConfig.local_kits = {}



	MusicManager.play("menu")
	MusicManager.set_muffled(false)
	MusicManager.unduck()
	if GameConfig.menu_outfit in OUTFITS:
		_outfit = GameConfig.menu_outfit
	elif GameConfig.menu_outfit in ["home", "away"]:
		_outfit = "captain"
	if GameConfig.menu_ball in BALL_SKINS:
		_ball_skin = GameConfig.menu_ball



	if GameConfig.freeplay_stage in Stage.freeplay_ids():
		_freeplay_stage = GameConfig.freeplay_stage

	var fps_at: = LaunchGate.dev_args().find("--fp-stage")
	if fps_at >= 0 and fps_at + 1 < LaunchGate.dev_args().size():
		_freeplay_stage = String(LaunchGate.dev_args()[fps_at + 1])
	_build_arena()
	MobileDiagnostics.record("menu_arena_ready")
	_build_player()
	MobileDiagnostics.record("menu_player_ready")
	_build_ui()
	MobileDiagnostics.record("mobile_menu_ready")
	_drill_progress.load_local()

	if GameConfig.lobby_notice != "":
		_flash_notice(GameConfig.lobby_notice)
		GameConfig.lobby_notice = ""



	Achievements.claimable_changed.connect( func(_n: int): _refresh_awards_badge())
	ProfileStore.changed.connect(_refresh_awards_badge)
	_refresh_awards_badge()


	if not Net.pending_start.is_empty() and Net.active and Net.in_match:
		var pending: Array = Net.pending_start
		Net.pending_start = []
		_menu_match_started.call_deferred(pending)





	_maybe_resume_home_party()



	if Net.active and Net.players.size() > 0 and not Net.party:
		_show_room()


	elif GameConfig.menu_return_local:
		GameConfig.menu_return_local = false
		_populate_local()
		_show(_local)



	if Net.active:
		Net.send_party_look(_outfit)
		Net.send_party_ball(_ball_skin)




		if LocalPlayers.has_guests():
			Net.push_local_roster()


	var uargs: = LaunchGate.dev_args()


	var cjm: = uargs.find("--net-couch")
	if cjm >= 0:
		var ngm: = 1
		if cjm + 1 < uargs.size() and String(uargs[cjm + 1]).is_valid_int():
			ngm = int(uargs[cjm + 1])
		for gm in mini(ngm, LocalPlayers.MAX_LOCAL - 1):
			LocalPlayers.join(gm)


	var pa: = uargs.find("--party-after")
	var party_wait: = float(uargs[pa + 1]) if pa != -1 and pa + 1 < uargs.size() else 0.0
	if "--party-host" in uargs:




		var host_now: = func():
			Net.host_party("host", true)
			_refresh_party_strip()
		if party_wait > 0.0:
			get_tree().create_timer(party_wait).timeout.connect(host_now)
		else:
			host_now.call_deferred()
	var pj: = uargs.find("--party-join")
	if pj != -1:
		var ip: = "127.0.0.1"
		if pj + 1 < uargs.size() and not String(uargs[pj + 1]).begins_with("--"):
			ip = String(uargs[pj + 1])
		var guest: = "guest %d" % (randi() % 100)
		if party_wait > 0.0:
			get_tree().create_timer(party_wait).timeout.connect(
				func(): Net.join_game(ip, guest))
		else:
			Net.join_game.call_deferred(ip, guest)


	if "--freeplay" in uargs and not ("--shot" in uargs):
		_enter_freeplay()






	if "--fp-ball" in uargs:
		_fp_ball_script()



	if "--fp-call-spam" in uargs:
		_fp_call_spam()
	var fpc: = uargs.find("--fp-call")
	if fpc != -1 and fpc + 1 < uargs.size():
		_fp_call_loop(int(uargs[fpc + 1]))
		if "--fp-offset" in uargs:
			player.global_position = HOME_SPOT + Vector3(3.2, 0.0, -2.5)
	var drill_arg: = uargs.find("--drill")
	if drill_arg != -1 and drill_arg + 1 < uargs.size():
		_start_drill(String(uargs[drill_arg + 1]))



	var bf: = uargs.find("--browse-fake")
	if bf != -1 and not Net.active:
		var n: = 50
		if bf + 1 < uargs.size() and String(uargs[bf + 1]).is_valid_int():
			n = int(uargs[bf + 1])
		_browse_fake.call_deferred(n)


	if "--quick-probe" in uargs:
		(load("res://game/dev/quick_probe.gd") as GDScript).maybe_spawn(get_tree())
	if "--party-probe" in uargs:
		(load("res://game/dev/party_probe.gd") as GDScript).maybe_spawn(get_tree())
	if "--migrate-probe" in uargs:


		(load("res://game/dev/migrate_probe.gd") as GDScript).maybe_spawn(get_tree())
	if "--travel-probe" in uargs:
		(load("res://game/dev/travel_probe.gd") as GDScript).maybe_spawn(get_tree())


	if "--pp-probe" in uargs:
		(load("res://game/dev/party_privacy_probe.gd") as GDScript).maybe_spawn(get_tree())

	if "--demo-online-probe" in uargs:
		(load("res://game/dev/demo_online_probe.gd") as GDScript).maybe_spawn(get_tree())


	var pp: = uargs.find("--party-practice")
	if pp != -1 and not Net.in_match:
		var wait: = 4.0
		if pp + 1 < uargs.size() and String(uargs[pp + 1]).is_valid_float():
			wait = float(uargs[pp + 1])
		get_tree().create_timer(wait).timeout.connect( func():
			if not Net.practice:
				_try_freeplay())


	var pdr: = uargs.find("--practice-drive")
	if pdr != -1 and pdr + 2 < uargs.size() and not Engine.has_meta("practice_driver"):
		Engine.set_meta("practice_driver", true)
		var drv: Node = (load("res://game/dev/practice_driver.gd") as GDScript).new()
		drv.set("dir", String(uargs[pdr + 1]))
		drv.set("role", String(uargs[pdr + 2]))
		get_tree().root.add_child.call_deferred(drv)
	var pl: = uargs.find("--party-launch")
	if pl != -1:
		var sz: = 2
		if pl + 1 < uargs.size() and uargs[pl + 1].is_valid_int():
			sz = int(uargs[pl + 1])


		var launch_after: = 3.5
		if pl + 2 < uargs.size() and String(uargs[pl + 2]).is_valid_float():
			launch_after = float(uargs[pl + 2])
		get_tree().create_timer(launch_after).timeout.connect( func(): _go_to_match(sz))


	if "--quick-fast" in uargs:
		_qp.soft_fill_after = 4.0
		_qp.form_max = 10.0
		_qp.search_max = 25.0


	var pqueue: = uargs.find("--party-queue")
	if pqueue != -1:
		var sz: = 2
		if pqueue + 1 < uargs.size() and uargs[pqueue + 1].is_valid_int():
			sz = int(uargs[pqueue + 1])
		_qp.force_lan = true
		_qp.soft_fill_after = 4.0




		_party_queue_when_formed(sz, 10.0)




	var fkf: = uargs.find("--fake-friends")
	if fkf != -1 and OS.has_feature("editor"):
		var nf: = 12
		if fkf + 1 < uargs.size() and uargs[fkf + 1].is_valid_int():
			nf = int(uargs[fkf + 1])
		_fake_friends = _make_fake_friends(nf)
		_fake_friends_churn = true
		if _friends_btn != null:
			_friends_btn.visible = true
	var fkp: = uargs.find("--fake-party")
	if fkp != -1:
		var n: = 6
		if fkp + 1 < uargs.size() and uargs[fkp + 1].is_valid_int():
			n = int(uargs[fkp + 1])
		_fake_party_n = n
		if _friends_btn != null:
			_friends_btn.visible = true


		if _party_strip != null:
			for c in _party_strip.get_children():
				c.queue_free()

			var me_cfg: Dictionary = GameConfig.character.to_dict() if GameConfig.character != null else {}
			_party_strip.add_child(_party_disc("singleplayer", UiStyle.SECONDARY, 
				"you", Callable(), true, me_cfg))
			for m in range(1, n):
				_party_strip.add_child(_party_disc("singleplayer", 
					[UiStyle.HIGHLIGHT, UiStyle.SUCCESS, UiStyle.SECONDARY][m % 3], "member", 
					func(): pass, 
					false, CharacterConfig.random().to_dict()))
			var db: = Button.new()
			db.text = "disband"
			UiStyle.style_button(db, "tertiary", 13)
			db.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			db.set_meta("bar_text", true)
			_party_strip.add_child(db)
		for slot in range(1, mini(n, PARTY_SPOTS.size())):
			var d: Player = PLAYER_SCENE.instantiate()
			add_child(d)
			d.net_puppet = true
			d.sim_authority = false
			d.collision_layer = 0
			d.collision_mask = 0
			d.charge_ui_enabled = false
			d.indicator_enabled = false
			d.set_character(GameConfig.character.gym_look(), 
				GameConfig.character.gym_kit())
			d.set_name_visible(false)
			d.global_position = HOME_SPOT + PARTY_SPOTS[slot]
			var db: Ball = BALL_SCENE.instantiate()
			db.stage_ball = "nationals"
			db.net_puppet = true
			db.show_landing_ring = false
			add_child(db)
			db.global_position = HOME_SPOT + PARTY_SPOTS[slot]\
			+ Vector3(-0.45, 0.4, 0.5)




	if "--onboard" in LaunchGate.dev_args():
		_offer_tutorial.call_deferred(true)
	elif not MobileControls.enabled() and LaunchGate.dev_args().is_empty() and not Net.active\
	and not GameConfig.tutorial_seen:
		_offer_tutorial.call_deferred()
	if "--menu-quick" in LaunchGate.dev_args():

		(load("res://game/dev/quick_probe.gd") as GDScript)\
		.maybe_spawn(get_tree())
		_qp.force_lan = true
		_quick_any.set_pressed_no_signal(true)
		_find_quick()






	if not MobileControls.enabled() and LaunchGate.dev_args().is_empty() and not Net.active:
		_prewarm_local_faces.call_deferred()


	if not MobileControls.enabled():
		PracticeCourt.preload_scene()
	_practice_prewarm = not MobileControls.enabled() and (LaunchGate.dev_args().is_empty()\
	or LaunchGate.dev_args().has("--practice-prewarm"))
	_always_court = BootLoader.enabled() or LaunchGate.dev_args().has("--always-court")
	_adopt_parked_court()


	var rvargs: = LaunchGate.dev_args()
	var rvi: = rvargs.find("--review")
	if rvi != -1 and rvi + 1 < rvargs.size() and not LaunchGate.is_demo():

		var rsi: = rvargs.find("--seek")
		GameConfig.review_seek_t = maxf(float(rvargs[rsi + 1]), 0.0)\
		if rsi != -1 and rsi + 1 < rvargs.size() else 0.0

		var rci: = rvargs.find("--review-chat")
		GameConfig.review_chat = FileAccess.get_file_as_string(String(rvargs[rci + 1]))\
		if rci != -1 and rci + 1 < rvargs.size() else ""
		_boot_review(String(rvargs[rvi + 1]))
		return

	if Engine.has_meta("guide_open"):
		var spread: = String(Engine.get_meta("guide_open"))
		Engine.remove_meta("guide_open")
		_open_guide.call_deferred(spread)
	var args: = LaunchGate.dev_args()
	if "--shot" in args:

		var page: = "home"
		var at: = args.find("--shot")
		if at + 1 < args.size() and not String(args[at + 1]).begins_with("--"):
			page = String(args[at + 1])
		match page:
			"home":


				if "--p2" in args or "--p4" in args:
					await get_tree().process_frame
					LocalPlayers.join(0)
					if "--p4" in args:
						LocalPlayers.join(1)
						LocalPlayers.join(2)
					await get_tree().process_frame
			"online": _show(_online)
			"local-choose": _show(_local_choose)
			"local":

				var sa: = args.find("--stage")
				if sa != -1 and sa + 1 < args.size():
					GameConfig.stage = String(args[sa + 1])
				var ta: = args.find("--tod")
				if ta != -1 and ta + 1 < args.size():
					GameConfig.time_of_day = int(args[ta + 1])
				_populate_local()
				_show(_local)
			"lobby1", "lobby2", "lobby3", "lobby4", "lobby5", "lobby6":
				_show(_local)
				_on_local_rule("size", int(page.substr(5)))
			"lobby-drop":
				_show(_local)
				_on_local_rule("size", 4)
				await get_tree().create_timer(0.4).timeout
				_local_panel.rules.open_select("size")
			"practice":
				_show(_practice)


				if "--p2" in args:
					await get_tree().process_frame
					LocalPlayers.join(0)
					await get_tree().process_frame
					if "--try-freeplay" in args:
						_try_freeplay()
						print("[couch gate] guests=%s freeplay=%s" % [
							LocalPlayers.has_guests(), _freeplay])

					if "--then-leave" in args:
						LocalPlayers.reset_to_primary()
						await get_tree().process_frame
						var veiled: = 0
						for c in _couch_gated:
							veiled += int(_couch_veil(c).visible)
						_try_freeplay()
						print("[couch gate] after leave: guests=%s veiled=%d freeplay=%s" % [
							LocalPlayers.has_guests(), veiled, _freeplay])
			"credits": _open_credits.call_deferred()
			"feedback", "feedback-fb":
				_open_feedback()
				_feedback._set_kind("feedback" if page == "feedback-fb" else "bug")
				_feedback._set_severity("urgent")
			"configs":



				_show(_configs)
				if "--p2" in args or "--p4" in args:
					await get_tree().process_frame
					LocalPlayers.join(0)
					if "--p4" in args:
						LocalPlayers.join(1)
						LocalPlayers.join(2)
					await get_tree().process_frame
					_refresh_configs()


				var ov: = args.find("--overlay")
				if ov >= 0 and ov + 1 < args.size() and not _cfg_panels.is_empty():
					await get_tree().process_frame
					var pi: int = 1 if LocalPlayers.count() > 1 else 0
					_cfg_panels[pi]._open_overlay(String(args[ov + 1]))
			"drillrun":

				_show(_practice)
				await get_tree().create_timer(0.1).timeout
				_start_drill("spiking_1")
			"quick": _show(_quick)
			"profile":
				if "--title-seed" in args:
					_shot_seed_titles()
					_refresh_profile()
				_show(_profile)
			"title":



				if "--title-seed" in args:
					_shot_seed_titles()
				_refresh_profile()
				_show(_profile)
				_open_title_editor.call_deferred()

				var tab_at: = args.find("--title-tab")
				if tab_at >= 0 and tab_at + 1 < args.size():
					var want_tab: = String(args[tab_at + 1])
					get_tree().create_timer(0.4).timeout.connect( func():
						if is_instance_valid(_title_editor):
							_title_editor.call("_open_tab", want_tab))
			"career", "career-detail":
				_shot_seed_career()
				_show(_career)
				if page == "career-detail":
					await get_tree().create_timer(0.3).timeout
					var cp: = _career.find_child("CareerPage", true, false)
					if cp != null:
						cp.call("_open_detail", Career.history()[0])
			"modwarn":

				OnlineTerms._show_warning_notice.call_deferred(
					{"reason": "chill with the spam in chat please", "id": "dev"}, Callable())
			"modappeal":
				OnlineTerms._show_appeal_form.call_deferred("online")
			"modban":
				OnlineTerms._show_ban_notice.call_deferred("being toxic in chat and griefing teammates", 
					int(Time.get_unix_time_from_system()) + 7200, true)
			"modtoast":
				UiStyle.flash_pill.call_deferred(
					"an action was taken on a player you reported", 
					UiStyle.SUCCESS, "information", 30.0)
			"modtoast2":
				UiStyle.flash_pill.call_deferred(
					"3 actions were taken on players you reported", 
					UiStyle.SUCCESS, "information", 30.0)
			"modvote":
				Net.votekick_opened.emit.call_deferred(999, "griefer99", 1, 3, 28)
			"modvote2":

				Net.votekick_opened.emit.call_deferred(999, "griefer99", 1, 3, 28)
				UiStyle.flash_pill.call_deferred(
					"an action was taken on a player you reported", 
					UiStyle.SUCCESS, "information", 30.0)
			"modvotechat":


				Net.host_game("host")
				Net.custom_lobby = true
				_show_room()
				if _chat != null:
					_chat.unfold()
				await get_tree().create_timer(0.4).timeout

				Net.system_message("vote to kick griefer99 started -- type /vote yes or /vote no")
				if _chat != null:
					_chat._system("vote cast")
				Net.votekick_opened.emit(999, "griefer99", 2, 3, 24)
			"modterms":
				OnlineTerms._show.call_deferred()
			"modchecking":
				OnlineTerms._show_checking.call_deferred()
			"modreport":
				ReportPopup.open.call_deferred(76561198000000042, "griefer99")
			"modplayer":


				Net.players[999] = {"name": "griefer99", "sid": 76561198000000042, 
					"side": 1, "cfg": Net.local_character_dict()}
				PlayerMenu.open.call_deferred(999)
			"achievements":



				if "--ach-seed" in args:
					_shot_seed_awards()
				_show_achievements()
				var press_at: = args.find("--ach-press")
				if press_at >= 0 and press_at + 1 < args.size():
					var which: = String(args[press_at + 1])
					get_tree().create_timer(1.0).timeout.connect( func():
						var b: = _awards.find_child("ClaimAll", true, false) as Button
						if which != "all":
							b = null
							for c in _awards.find_children("Claim", "Button", true, false):
								if (c as Button).is_visible_in_tree():
									b = c
									break
						if b != null:
							b.pressed.emit())
			"custom": _open_custom()
			"settings": _open_settings(SettingsPanel.Scope.SYSTEM)
			"settings-general":
				_open_settings(SettingsPanel.Scope.SYSTEM)
				await get_tree().create_timer(0.3).timeout
				for t in find_children("*", "TabContainer", true, false):
					for i in (t as TabContainer).get_tab_count():
						if (t as TabContainer).get_tab_title(i) == "general":
							(t as TabContainer).current_tab = i
			"profile-settings": _open_settings(SettingsPanel.Scope.PROFILE)
			"howto":

				_show(_howto)
				var ca: = args.find("--cat")
				if _howto_panel != null and ca != -1 and ca + 1 < args.size():

					await get_tree().create_timer(0.3).timeout
					_howto_panel.cycle_tab(int(args[ca + 1]))

					if "--edit" in args:
						for b in _howto_panel.find_children("*", "Button", true, false):
							if (b as Button).text == "edit" and (b as Button).is_visible_in_tree():
								(b as Button).pressed.emit()
								break
					var sa: = args.find("--scroll")
					if sa != -1 and sa + 1 < args.size():
						await get_tree().process_frame
						_howto_panel.scroll_to(int(args[sa + 1]))
			"guide-book": _open_guide.call_deferred()
			"browse": _show(_browse)
			"host": _show(_host)
			"direct": _show(_direct)
			"room":

				var titled: = "--title-seed" in args
				if titled:
					_shot_seed_titles()
				Net.host_game("host")
				Net.custom_lobby = true
				if "--big" in args:
					Net.set_team_size(6)

				var rs_at: = args.find("--room-size")
				if rs_at >= 0 and rs_at + 1 < args.size():
					Net.set_team_size(clampi(int(args[rs_at + 1]), 1, 6))



				if "--fill" in args or "--fill-all" in args:
					var worn: Array = [
						{"id": "its_just_volleyball", "fg": "ffffff", "bg": "ff7ab8", "ol": "d6397f", "th": 5, "fx": "cutesy"}, 
						{"id": "goat", "fx": "pixel", "fg": "10230c", "bg": "7be06a"}, 
						{"id": "nah_id_win", "cs": 2, "fg": "ffffff", "bg": "15171f", "fx": "confetti"}, 
						{"id": "the_ace"}, 
						{}, 
						{"id": "surpassing_limits", "cs": 1, "fg": "fff6d8", "bg": "e8491d", "ol": "5a1206", "th": 5, "fx": "lava"}, 
						{"id": "tmko", "fx": "rainbow"}, 
						{"id": "guardian_deity", "fx": "water", "fg": "ffffff", "bg": "2e78ff"}, 
						{"id": "platinum_goofy", "fx": "typewriter", "fg": "eaffea", "bg": "15171f"}, 
						{"id": "fly"}, 
						{"id": "who_youll_become", "fg": "ff5d8f", "bg": "00000000", "ol": "232b3b", "th": 6}, 
					]
					var sides: Array = [1, -1, 1, 0, -1] if not "--fill-all" in args\
					else [1, -1, 1, -1, 1, -1, 1, -1, 1, -1, -1]
					var frng: = RandomNumberGenerator.new()
					frng.seed = 11
					for i in range(2, 2 + sides.size()):
						var fcfg: Dictionary = Net.local_character_dict()
						if titled:
							fcfg = CharacterConfig.random(frng).to_dict()
							var ttl: Dictionary = TITLES.sanitize(worn[(i - 2) % worn.size()])
							if not ttl.is_empty():
								fcfg["ttl"] = ttl
						Net.players[i] = {"name": ["Somnus", "Avovet", "Ayudin", "Saguinee", "Maybesky", "october", 
							"reg", "Kirby", "Bronte", "Enzo", "Shaye"][(i - 2) % 11] if titled else "friend %d" % i, 
							"cfg": fcfg, 
							"side": sides[i - 2]}


				if titled:
					await get_tree().process_frame


				var st_at: = args.find("--room-stage")
				if st_at >= 0 and st_at + 1 < args.size():
					Net.set_stage(String(args[st_at + 1]))
				_show_room()
				if "--big" in args or "--fill" in args or "--fill-all" in args or rs_at >= 0:
					await get_tree().create_timer(0.3).timeout
					_refresh_room()

				var pm_at: = args.find("--player-menu")
				if pm_at >= 0 and pm_at + 1 < args.size():
					await get_tree().create_timer(0.4).timeout
					PlayerMenu.open(int(args[pm_at + 1]))
			"party":
				Net.host_party("host", true)
				_show(_home)


				_refresh_party_strip.call_deferred()
			"freeplay":


				_enter_freeplay()
		var wait: = 0.16 if "--early" in args else 1.4
		if page == "freeplay":
			wait = 2.2
		if page.begins_with("lobby") or page == "room" or page.begins_with("career"):
			wait = 3.5
		if page == "drillrun":
			wait = 6.0

		var wait_at: = args.find("--wait")
		if wait_at >= 0 and wait_at + 1 < args.size():
			wait = clampf(float(args[wait_at + 1]), 0.1, 11.0)

		get_tree().create_timer(12.0).timeout.connect( func(): get_tree().quit())
		await get_tree().create_timer(wait).timeout
		if "--trail" in args:

			var c: = get_viewport().get_visible_rect().size * 0.5
			for i in 18:
				var ang: = -1.6 + float(i) * 0.13
				Input.warp_mouse(c + Vector2(cos(ang), sin(ang)) * 260.0)
				await get_tree().process_frame
		get_viewport().get_texture().get_image()\
		.save_png("res://game/dev/shots/menu_%s.png" % page)
		get_tree().quit()



func _build_arena() -> void :

	_build_stage_arena()
	fx = Fx.new()
	add_child(fx)
	sfx = Sfx.new()
	add_child(sfx)



func _build_stage_arena() -> void :
	var id: = _freeplay_stage




	_foley.surface = String(Stage.val(id, "surface", "court"))
	Stage.apply_reverb(id)
	Stage.apply_time_of_day(id)

	_foley.water_x = float(Stage.val(id, "water_x", INF))
	_foley.water_side = float(Stage.val(id, "water_side", 1.0))
	_apply_freeplay_env(id)
	var shell: = (load(String(Stage.info(id).venue))\
	as PackedScene).instantiate()
	add_child(shell)
	_arena_nodes.append(shell)






	for piece in shell.get_children():
		if piece.has_method("configure"):
			piece.call("configure", COURT_HW, COURT_HL)



	var painted: = {}
	var gym: = shell.get_node_or_null("Gym")
	if bool(Stage.val(id, "hand_painted", false)) and gym != null:
		for node in gym.find_children("*", "MeshInstance3D", true, false):
			if String(node.name).to_lower().contains("cutter"):
				(node as Node3D).visible = false
		painted = (preload("res://game/court/env_paint.gd") as GDScript).apply(gym, 
			Stage.val(id, "emissive_mats", {}))
	var court: Node3D = COURT_SCENE.instantiate()
	add_child(court)
	_arena_nodes.append(court)
	court.scale = Vector3(COURT_HW / 4.5, 1.0, COURT_HL / 9.0)
	CourtDress.unique_net(court.get_node("Net"), court.scale.x)
	_floor_mat = CourtDress.unique_floor(court)




	if bool(Stage.val(id, "owns_floor", false)):
		var cf: = court.get_node_or_null("CourtFloor") as MeshInstance3D
		if cf != null:
			if bool(Stage.val(id, "mirror_overlay", false)):




				_floor_mat.shader = load("res://game/court/floor_overlay.gdshader")
				cf.position.y += 0.06
			else:
				cf.visible = false
	_floor_mat.set_shader_parameter("reflect_on", false)

	Stage.paint_court_floor(_floor_mat, id, COURT_HW, COURT_HL)
	Stage.dress_court(court, id)
	camera_rig.room_box = Stage.cam_box(id)



	var _net_node: = court.get_node_or_null("Net") as MeshInstance3D
	if _net_node != null:
		_menu_net_mat = (_net_node.mesh as PlaneMesh).material as ShaderMaterial
		_menu_net_node = _net_node
		if aim_indicator != null:
			aim_indicator.net_mat = _menu_net_mat
			aim_indicator.net_node = _menu_net_node






	_sand_deform = null
	SandDeform.decal_y = 0.0
	SandDeform.decal_y_feet = 0.0
	var sand: = SandDeform.build(self, id, shell, court, COURT_HW, COURT_HL, 
		func(): return [player] + _party_live_bodies(), 
		func(): return ball)
	if not sand.is_empty():
		_sand_deform = sand.get("deform")
		_arena_nodes.append(_sand_deform)
		_arena_nodes.append(sand.get("deck"))





	for piece in shell.find_children("*", "Node3D", true, false):
		if piece.has_method("set_feeds"):
			piece.set_feeds( func(): return [player] + _party_live_bodies(), 
				func(): return ball)
		if piece.has_method("wire_reflection") and _reflector != null:
			piece.wire_reflection(_reflector.texture())


			if piece.has_method("indicator_clearance_y"):
				SandDeform.decal_y = piece.indicator_clearance_y()
				SandDeform.decal_y_feet = piece.indicator_feet_y()




	var cbox: Vector3 = Stage.val(id, "collision_box", Vector3.ZERO)
	var has_dome: = cbox != Vector3.ZERO and bool(Stage.val(id, "force_wall", false))
	if cbox != Vector3.ZERO:
		var sc: = preload("res://game/stage/stage_collision.gd") as GDScript
		if has_dome:
			sc.build_ring(shell, cbox)
		else:
			sc.build_box(shell, cbox, Stage.cam_box(id).size == Vector3.ZERO)
	if has_dome:
		var dome: Node3D = (preload("res://game/court/force_dome.gd") as GDScript).new()
		add_child(dome)
		_arena_nodes.append(dome)
		dome.build(cbox, Stage.val(id, "force_wall_color", Color(0.28, 0.62, 1.0)))




	if not painted.is_empty():
		var look: = Stage.config(id)
		if look != null and look.has_method("apply"):
			look.apply(painted)




		for mats in (painted.values() if bool(Stage.val(id, "freeplay_relight", true)) else []):
			for m in mats:
				var sm: = m as ShaderMaterial
				if sm == null:
					continue
				sm.set_shader_parameter("ambient", 0.6)
				sm.set_shader_parameter("focus_dim", 0.32)
				sm.set_shader_parameter("haze_amt", 0.16)





		Stage.apply_recolors(painted, id, {
			"SeatShader": 0.12, "CourtSeatShader": 0.12, 
			"BlackCarpetShader": 0.12, "RedCarpetShader": 0.12, 
		})




		var accents: Array = Stage.val(id, "accents", [])
		if not accents.is_empty():
			var pick: = absi(hash("school_accent:%s:%d" % [id, GameConfig.match_seed]))
			var tapes: Array = Stage.val(id, "tape_by_accent", [])
			Stage.apply_school_accent(painted, court, id, accents[pick % accents.size()], 
				tapes[pick % tapes.size()] if not tapes.is_empty() else null, {})

	for z in [-5.0, 5.0]:
		var light: = OmniLight3D.new()
		light.position = Vector3(0.0, 7.0, z)
		light.light_energy = 1.3
		light.light_color = Color(1, 0.96, 0.88)
		light.omni_range = 24.0
		add_child(light)
		_arena_nodes.append(light)


	_wire_floor_reflection(id)




func _swap_stage(id: String, broadcast: = true, persist: = true, force: = false, 
		defer_arena: = false) -> void :






	if _swapping_stage or (Net.party and not force and broadcast and not Net.is_host)\
	or not Stage.in_build(id) or id == _freeplay_stage:
		return
	_swapping_stage = true
	_freeplay_stage = id
	if not defer_arena:
		_rebuild_stage_arena()
	if _stage_btn is UiSelect:

		var at: = Stage.freeplay_ids().find(id)
		if at >= 0:
			(_stage_btn as UiSelect).selected = at
		else:
			_stage_btn.text = tr("stage: ") + Stage.title(id).to_lower()
	elif _stage_btn != null:
		_stage_btn.text = tr("stage: ") + Stage.title(id).to_lower()
	if persist:
		GameConfig.freeplay_stage = id
		GameConfig.save_settings()
	if broadcast:
		Net.send_party_stage(id)
	_swapping_stage = false
	if not force:
		_practice_stage_changed()


func _rebuild_stage_arena() -> void :
	for n in _arena_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_arena_nodes.clear()
	_build_stage_arena()





func _practice_stage_changed() -> void :
	if Net.party and Net.is_host and Net.active:
		Net.set_stage(_freeplay_stage)
	if _practice_court == null or not _practice_court.running():
		return
	if _practice_court.main.has_method("restage"):
		_practice_court.main.restage(_freeplay_stage)
	else:
		_rebuild_court()

func _rebuild_court() -> void :
	if _practice_court == null or not _practice_court.running():
		return
	if _practice_solo:
		var was_solo_on: = _practice_on
		_stop_practice()
		_start_solo_practice(was_solo_on)
	elif Net.party and Net.is_host and Net.active:
		var was_on: = _practice_on
		_court_now( func():
			_stop_practice(false)
			_practice_enter_on_start = was_on
			_launch_party_practice())

func _on_party_stage(id: String) -> void :


	_swap_stage_live(id, false, false)









var _stage_wipe_busy: = false
var _stage_wipe_next: Array = []




func _stage_swap_covered(id: String, broadcast: bool, persist: bool) -> void :


	await get_tree().process_frame
	_swap_stage(id, broadcast, persist, false, true)
	if _practice_court != null and _practice_court.running()\
	and not _practice_court.active and _practice_court.viewport != null:
		_practice_court.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	for i in 2:
		await get_tree().process_frame
	if _freeplay_stage == id:
		_rebuild_stage_arena()


	get_viewport().disable_3d = false
	await get_tree().process_frame
	get_viewport().disable_3d = _practice_on
	await get_tree().process_frame

func _swap_stage_live(id: String, broadcast: = true, persist: = true) -> void :
	if (Net.party and broadcast and not Net.is_host) or not Stage.in_build(id):
		return
	if _stage_wipe_busy:
		_stage_wipe_next = [id, broadcast, persist]
		return
	if id == _freeplay_stage:
		return
	_stage_wipe_busy = true
	var path: = String(Stage.info(id).get("venue", ""))
	if path != "" and not ResourceLoader.has_cached(path)\
	and ResourceLoader.load_threaded_request(path) == OK:
		while ResourceLoader.load_threaded_get_status(path)\
		== ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
		ResourceLoader.load_threaded_get(path)
	if not is_inside_tree():
		_stage_wipe_busy = false
		return
	var done: = [false]
	UiWipe.wipe(get_tree(), func() -> void :
		await _stage_swap_covered(id, broadcast, persist)
		done[0] = true)
	while not done[0] and is_inside_tree():
		await get_tree().process_frame
	_stage_wipe_busy = false
	if not _stage_wipe_next.is_empty():
		var nxt: = _stage_wipe_next
		_stage_wipe_next = []
		_swap_stage_live(String(nxt[0]), bool(nxt[1]), bool(nxt[2]))




func _apply_freeplay_env(id: String) -> void :
	ShadowSun.ensure(self)
	var we: = $WorldEnvironment as WorldEnvironment
	if we == null:
		return
	var env: = we.environment.duplicate() as Environment
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
	elif bool(Stage.val(id, "use_sky_color", false)):
		env.background_mode = Environment.BG_COLOR
		env.background_color = Stage.val(id, "sky_color", Color(0.5, 0.74, 0.95))



		env.sky = null
	else:

		env.background_mode = Environment.BG_COLOR
		env.background_color = Stage.val(id, "fog_color", Color(0.03, 0.04, 0.06))
		env.sky = null
	env.glow_enabled = bool(Stage.val(id, "bloom", false)) and GameConfig.bloom
	env.fog_enabled = bool(Stage.val(id, "fog", false))
	if env.fog_enabled:
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_light_color = Stage.val(id, "fog_color", Color(0.02, 0.03, 0.05))
		env.fog_depth_begin = float(Stage.val(id, "fog_begin", 40.0))
		env.fog_depth_end = float(Stage.val(id, "fog_end", 90.0))
		env.fog_sky_affect = 0.0

		env.fog_height = float(Stage.val(id, "fog_height", 0.0))
		env.fog_height_density = - float(Stage.val(id, "fog_height_density", 0.0))
	env.tonemap_exposure = float(Stage.val(id, "exposure", 1.0))
	we.environment = env

func _refresh_stage_btn() -> void :

	if _stage_btn != null:
		_stage_btn.disabled = Net.party and not Net.is_host





func _wire_floor_reflection(id: String) -> void :
	if _reflector == null or _floor_mat == null:
		return
	var reflects: bool = bool(Stage.val(id, "reflect", true))\
	and ( not bool(Stage.val(id, "owns_floor", false))
		or bool(Stage.val(id, "mirror_overlay", false)))
	if reflects:
		CourtDress.wire_reflection(_floor_mat, _reflector.texture())
		_reflector.floor_mats = [_floor_mat]
	else:
		_floor_mat.set_shader_parameter("reflect_on", false)
		_reflector.floor_mats = []

func _build_player() -> void :
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = HOME_SPOT
	player.team_side = 1
	player.set_name_visible(false)
	player.charge_ui_enabled = false
	Haptics.wire(player)
	_apply_outfit()
	ball = BALL_SCENE.instantiate()
	ball.stage_ball = _ball_skin
	add_child(ball)
	ball.fx = fx
	ball.global_position = HOME_SPOT + Vector3(-0.45, 0.4, 0.5)
	ball.court_center_x = 0.0
	ball.court_half_w = COURT_HW
	ball.court_half_l = COURT_HL
	ball.net_half_width = Ball.PHYS.net_half_width * (COURT_HW / 4.5)
	ball.antenna_half_width = Ball.PHYS.antenna_half_width * (COURT_HW / 4.5)
	ball.wall_min = Vector3( - HALL_X, -1000000.0, - HALL_Z)
	ball.wall_max = Vector3(HALL_X, 30.0, HALL_Z)
	ball.struck.connect( func(pos: Vector3, power: float, kind: int):
		_play_contact_fx(pos, power, kind, ball.vel, ball.combo_tier, ball.dig_weight, 
			ball.strike_source == player)

		if Net.party and _freeplay:
			Net.send_freeplay_fx(kind, pos, power, ball.vel))
	ball.bounced.connect( func():
		var floor_pos: = Vector3(ball.global_position.x, 0.06, 
			ball.global_position.z)
		sfx.play("hit_soft", ball.global_position, -12.0, 0.75)
		fx.ring(floor_pos, Vector3.UP, clampf(ball.vel.y * 0.12, 0.3, 0.9))
		fx.puff(floor_pos))
	player.thumped.connect( func(pos: Vector3, strength: float):
		var at: = Vector3(pos.x, 0.08, pos.z)
		sfx.play("hit_soft", at, -2.0, 0.55)
		Rules.contact_fx(fx, at, strength, Vector3.UP, 0.0)
		fx.puff(at)

		if Net.party and _freeplay:
			Net.send_freeplay_fx(-2, at, strength, Vector3.UP))
	player.knock_started.connect( func(_pos: Vector3, strength: float):
		camera_rig.shake(0.22 * strength))
	player.launched.connect( func(pos: Vector3, charge: float):
		var at: = Vector3(pos.x, 0.06, pos.z)
		fx.ring(at, Vector3.UP, 1.15 * charge)
		fx.puff(at)
		if charge >= 1.5:
			fx.bam_swirl(at, charge, player)
		sfx.play("hit_soft", at, -4.0, 1.35)

		if Net.party and _freeplay:
			Net.send_freeplay_fx(-1, at, charge, Vector3.UP))


	player.jumped.connect( func(bam: bool):
		if _freeplay:
			Achievements.notify("jump", {"bam": bam}))
	player.swung.connect( func(_k: int):


		sfx.play("swing", player.global_position, -5.0, 1.0)
		if Net.party and _freeplay:
			Net.send_freeplay_fx(-3, player.global_position, 0.0, Vector3.UP))
	player.voiced.connect( func(bank: String, pitch: float):
		sfx.play(bank, player.global_position, -3.0, pitch))
	camera_rig.player = player
	camera_rig.ball = ball
	camera_rig.roam = false


	camera_rig.mode_changed.connect( func(name_in: String):
		if hud != null:
			hud.show_camera_name(name_in))
	camera_rig.tv_center_x = 0.0
	camera_rig.court_span = COURT_HL
	camera_rig.home_side = 1.0
	_configure_freeplay_aim_bounds()
	fx.setup(camera_rig)


	_reflector = FloorReflector.new()
	add_child(_reflector)
	_reflector.setup(camera_rig.camera)
	_reflector.feet_provider = func(): return [player, ball] + _party_live_bodies()
	_wire_floor_reflection(_freeplay_stage)

	menu_cam.fov = 50.0



	menu_cam.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	menu_cam.global_position = HOME_SPOT + Vector3(-0.78, 1.35, 3.7)
	_face_camera()
	_cam_look_now = player.global_position + Vector3(-1.15, 1.0, 0.0)
	menu_cam.current = true

func _configure_freeplay_aim_bounds() -> void :




	_input_collector.aim_min = Vector2( - COURT_HW - 1.5, - COURT_HL - 2.5)
	_input_collector.aim_max = Vector2(COURT_HW + 1.5, COURT_HL + 2.5)

func _face_camera() -> void :
	var to_cam: = menu_cam.global_position - player.global_position
	_base_yaw = atan2(to_cam.x, to_cam.z) - 0.38
	player.visual.rotation.y = _base_yaw + _spin
	_aim_at_cam = player.global_position\
	+ Vector3(to_cam.x, 0.0, to_cam.z).normalized() * 6.0
	player.aim_point = _aim_at_cam
	menu_cam.look_at(player.global_position + Vector3(-1.15, 1.0, 0.0))







func _guest_earn(slot: LocalPlayerSlot, event: String, data: = {}) -> void :
	var prof: SavedProfile = slot.profile if slot != null else null
	if prof != null and prof != ProfileStore.active() and ProfileStore.profiles.has(prof):
		Achievements.notify_for(prof, event, data)




const FP_TIME_TICK: = 10.0
var _fp_time_acc: = 0.0
var _fp_time_where: = ""

func _tick_freeplay_time(delta: float) -> void :
	if not _freeplay:
		_fp_time_acc = 0.0
		return
	if hud != null and hud.pause_is_open():
		return
	var where: = "drill" if (_drill_active != "" or _tutorial != null) else "freeplay"
	if where != _fp_time_where:
		_fp_time_acc = 0.0
		_fp_time_where = where
	_fp_time_acc += delta
	if _fp_time_acc < FP_TIME_TICK:
		return
	var whole: = int(_fp_time_acc)
	_fp_time_acc -= float(whole)
	var data: = {"amount": whole, "quiet": true, "where": where}
	Achievements.notify("play_time", data)
	if where == "freeplay":
		for g in _local_guests:
			_guest_earn(g.get("slot"), "play_time", data)

func _sync_local_guests() -> void :
	var want: = {}
	for i in range(1, LocalPlayers.slots.size()):
		want[LocalPlayers.slots[i].device] = LocalPlayers.slots[i]

	for g in _local_guests.duplicate():
		var dev: int = g["slot"].device
		if not want.has(dev):
			if is_instance_valid(g["player"]):
				g["player"].queue_free()
			_local_guests.erase(g)
	var have: = {}
	for g in _local_guests:
		have[g["slot"].device] = true
	for dev in want:
		if not have.has(dev):
			var gp: = _spawn_guest(want[dev])
			var bits: = _guest_collision_defaults(gp)
			_local_guests.append({"slot": want[dev], "player": gp, 
				"layer": bits.layer, "mask": bits.mask})


			var gslot: LocalPlayerSlot = want[dev]
			gp.jumped.connect( func(bam: bool):
				if _freeplay:
					_guest_earn(gslot, "jump", {"bam": bam}))



	for g in _local_guests:
		var gbody: Player = g["player"]
		if not is_instance_valid(gbody):
			continue
		var look: = _seat_look(g["slot"])
		if look.has("cfg"):
			var lkey: = hash([(look.cfg as CharacterConfig).to_dict(), look.kit])
			if int(g.get("look_key", 0)) != lkey:
				g["look_key"] = lkey
				gbody.set_character(look.cfg, look.kit)
				gbody.set_ring_tint((g["slot"] as LocalPlayerSlot).color())

	_place_local_guests()



	_input_collector.set_exclude_pads(LocalPlayers.p1_exclude_pads())
	_input_collector.set_exclude_kbm(LocalPlayers.kbm_taken())





func _motion_collector() -> InputCollector:
	for g in _local_guests:
		var slot: LocalPlayerSlot = g["slot"]
		if slot.device == DeviceInput.KBM and slot.collector != null:
			return slot.collector
	return _input_collector

func _place_local_guests() -> void :
	for g in _local_guests:
		var body: Player = g["player"]
		if not is_instance_valid(body):
			continue
		var slot: LocalPlayerSlot = g["slot"]
		if _freeplay:
			body.global_position = HOME_SPOT + Vector3(2.2 * float(slot.index), 0.0, 0.0)
			body.indicator_enabled = true
			body.charge_ui_enabled = true
			body.net_puppet = false
			body.sim_authority = true

			body.collision_layer = int(g.get("layer", 1))
			body.collision_mask = int(g.get("mask", 1))
		else:



			body.net_puppet = true
			body.sim_authority = false



			body.indicator_enabled = false
			body.charge_ui_enabled = false


			body.collision_layer = 0
			body.collision_mask = 0







func _body_for_fp_slot(slot) -> Player:
	if slot == LocalPlayers.primary():
		return player
	for g in _local_guests:
		if g["slot"] == slot:
			return g["player"]
	return null

func _fp_view_index_for(slot) -> int:
	for v in _fp_views:
		if v.owns(slot):
			return v.index
	return -1



func _fp_split() -> bool:
	return _fp_views.size() >= 2



func _setup_fp_view_camera(view) -> void :
	var rig: CameraRig = view.rig
	rig.ball = ball
	var lead: = _body_for_fp_slot(view.owners[0])
	if lead == null:
		return
	rig.player = lead
	rig.home_side = float(lead.team_side)
	rig.roam = false

	rig.camera_input_external = true
	rig.mode_locked = false
	if view.owners.size() > 1:
		rig.profile = null
		rig.mode = CameraRig.Mode.DYNAMIC
		rig.shared = true
		var group: Array = []
		for o in view.owners:
			var b: = _body_for_fp_slot(o)
			if b != null:
				group.append(b)
		rig.frame_group = group
	else:
		rig.profile = view.owners[0].profile
		rig.shared = false
		rig.frame_group = []
		rig.mode = clampi(GameConfig.default_camera, 0, 
			CameraRig.Mode.size() - 1) as CameraRig.Mode
	rig.face_net()
	rig.apply_mouse_mode()

func _build_freeplay_views() -> void :
	_teardown_freeplay_views()
	if not _freeplay:
		return


	LocalPlayers.primary().team_side = 1
	player.team_side = 1
	var slots: Array = [LocalPlayers.primary()]
	for i in range(1, LocalPlayers.slots.size()):
		var s = LocalPlayers.slots[i]
		s.team_side = 1 if i % 2 == 0 else -1
		var b: = _body_for_fp_slot(s)
		if b != null:
			b.team_side = s.team_side
		slots.append(s)
	_fp_views = LocalViews.build(self, slots, camera_rig)

	if _fp_views.size() == 1 and _fp_views[0].owners.size() <= 1:
		_fp_views = []
		return

	if _reflector != null:
		_reflector.visible = false

	LocalViews.privatize(aim_indicator, 0)
	LocalViews.privatize(reach_marker, 0)
	if _toss_preview != null:
		LocalViews.privatize(_toss_preview, 0)
	if player.indicator_ring != null:
		LocalViews.privatize(player.indicator_ring, 0)
	if player.charge_ui != null:
		LocalViews.privatize(player.charge_ui, 0)


	for g in _local_guests:
		var vi: = _fp_view_index_for(g["slot"])
		if vi < 0:
			continue
		g["view"] = _fp_views[vi]
		g["rig"] = _fp_views[vi].rig
		var body: Player = g["player"]
		if body.indicator_ring != null:
			LocalViews.privatize(body.indicator_ring, vi)
		if body.charge_ui != null:
			LocalViews.privatize(body.charge_ui, vi)
		var aim: = AimMarker.new()
		add_child(aim)
		aim.net_mat = _menu_net_mat
		aim.visible = false
		LocalViews.privatize(aim, vi)
		g["aim"] = aim
		var reach: = ReachMarker.new()
		add_child(reach)
		reach.setup(_fp_views[vi].rig.camera)
		LocalViews.privatize(reach, vi)
		g["reach"] = reach
	for vi in range(_fp_views.size()):
		_setup_fp_view_camera(_fp_views[vi])

func _teardown_freeplay_views() -> void :
	if _fp_views.is_empty():
		return

	for g in _local_guests:
		if g.get("aim") != null and is_instance_valid(g["aim"]):
			g["aim"].queue_free()
		if g.get("reach") != null and is_instance_valid(g["reach"]):
			g["reach"].queue_free()
		g["aim"] = null
		g["reach"] = null
		g["rig"] = null
		g["view"] = null
		var body = g.get("player")
		if body != null and is_instance_valid(body):
			LocalViews.unprivatize(body.indicator_ring)
			LocalViews.unprivatize(body.charge_ui)

	LocalViews.unprivatize(aim_indicator)
	LocalViews.unprivatize(reach_marker)
	LocalViews.unprivatize(_toss_preview)
	LocalViews.unprivatize(player.indicator_ring)
	LocalViews.unprivatize(player.charge_ui)

	LocalViews.teardown(self, _fp_views, camera_rig)
	_fp_views = []
	camera_rig.camera_input_external = false
	camera_rig.shared = false
	camera_rig.frame_group = []
	if _reflector != null:
		_reflector.visible = true



func _route_freeplay_camera(event: InputEvent) -> bool:
	for v in _fp_views:
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


func _couch_may_join() -> bool:
	return Net.couch_room() > 0

func _on_couch_refused(_reason: String) -> void :
	var now: = Time.get_ticks_msec()
	if now - _couch_notice_at > 1500:
		_couch_notice_at = now
		_flash_notice("party is full" if Net.party else "no room for another player")

func _on_local_roster() -> void :
	_sync_local_guests()



	if _practice_court != null and _practice_court.running() and _practice_solo:
		_rebuild_court.call_deferred()

	if _freeplay:
		_build_freeplay_views()


	_refresh_party_strip()
	_refresh_couch_gates()
	if _configs != null and _configs.visible:
		_refresh_configs()
	if _local != null and _local.visible:
		_refresh_local()



func _open_guest_locker(slot: LocalPlayerSlot) -> void :
	if slot == null:
		return


	if LocalPlayers.has_guests():
		_wipe_to(_locker_scene())
		return


	if slot != null and slot.index == 0:
		_wipe_to("res://game/character/locker.tscn")
		return
	var idx: = ProfileStore.profiles.find(slot.profile)
	if idx <= 0:

		_flash_notice("guest profiles cannot be edited")
		return
	LocalPlayers.locker_device = slot.device
	LocalPlayers.locker_return = ProfileStore.active_index
	LocalPlayers.take_ui(slot.device)
	ProfileStore.switch_to(idx)
	_wipe_to("res://game/character/locker.tscn")



func _shop_scene() -> String:
	if LocalPlayers.has_guests():
		Engine.set_meta("split_page", "shop")
		return "res://game/character/locker_split_host.tscn"
	return "res://game/shop/shop.tscn"



func _locker_scene() -> String:
	if LocalPlayers.has_guests():
		return "res://game/character/locker_split_host.tscn"
	return "res://game/character/locker.tscn"




func _resume_from_guest_locker() -> void :
	if LocalPlayers.locker_return < 0:
		return
	var back: int = LocalPlayers.locker_return
	var dev: int = LocalPlayers.locker_device
	LocalPlayers.locker_return = -1
	LocalPlayers.locker_device = DeviceInput.MERGED
	LocalPlayers.release_ui()

	ProfileStore.switch_to(back)



	LocalPlayers.primary().profile = ProfileStore.active()
	_apply_outfit()
	_refresh_player_card()
	if _pc_avatar != null:
		_load_card_pfp.call_deferred(_pc_avatar)
	if Net.active:
		_broadcast_menu_look()
	var slot: = LocalPlayers.slot_for_device(dev)
	if slot != null and slot.profile != null:

		_sync_local_guests()

func _spawn_guest(slot: LocalPlayerSlot) -> Player:
	var gp: = PLAYER_SCENE.instantiate() as Player
	add_child(gp)
	gp.global_position = HOME_SPOT + Vector3(2.2, 0.0, 0.0)




	gp.net_puppet = true
	gp.sim_authority = false
	gp.team_side = 1
	gp.set_name_visible(false)
	gp.charge_ui_enabled = false
	gp.indicator_enabled = false
	gp.ball = ball
	var cfg: CharacterConfig = CharacterConfig.from_dict(slot.profile.character)\
	if slot.profile != null and not slot.profile.character.is_empty()\
	else CharacterConfig.random()

	gp.set_character(cfg, TeamKits.normalize(cfg.captain_kit))
	gp.set_ring_tint(slot.color())
	if player != null:
		player.set_ring_tint(LocalPlayers.primary().color())
	var col: = slot.make_collector()
	col.aim_min = _input_collector.aim_min
	col.aim_max = _input_collector.aim_max
	col.profile = slot.profile
	Haptics.wire(gp, slot.device, slot.profile.rumble if slot.profile != null else true)
	return gp



func _guest_collision_defaults(gp: Player) -> Dictionary:
	return {"layer": gp.collision_layer, "mask": gp.collision_mask}

func _apply_outfit() -> void :
	if _outfit == "captain":
		player.set_character(GameConfig.character, GameConfig.team_kit(true))
		return
	var fit: = CharacterConfig.outfit_fit(GameConfig.character, _outfit)
	player.set_character(fit[0], fit[1])







func _own_name_rule() -> void :
	if player == null:
		return
	var on: bool = _freeplay and GameConfig.show_own_name and _drill_active == ""
	if on:


		var who: = Net.local_display_name() if Net.active else LocalPlayers.primary_name()
		if player.display_name() != who:
			player.set_display_name(who)
		player.set_dev_tag(DevBadge.my_tier())
	player.set_name_visible(on)






var _lobby_look_sig: = 0
var _look_repaint_queued: = false

func _resend_look_on_lobby() -> void :
	if not is_inside_tree():
		return
	var ids: = Net.players.keys()
	ids.sort()
	var sig: = [ids, Net.is_host, Net.session_token, Net.party, 
		multiplayer.has_multiplayer_peer(), _outfit, _ball_skin, 
		Net.local_character_dict()].hash()
	if sig == _lobby_look_sig:
		return
	_lobby_look_sig = sig
	Net.send_party_look(_outfit)
	Net.send_party_ball(_ball_skin)




func _broadcast_menu_look() -> void :
	Net.send_party_look(_outfit)
	_queue_party_strip()



	if _practice_court != null and _practice_court.running():
		var pm = _practice_court.main.get("_practice")
		if pm != null:
			pm.redress_self(_outfit)



func _build_ui() -> void :
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_root)


	hud = HUD_SCENE.instantiate()
	ui.add_child(hud)
	hud.visible = false
	hud.pause_enabled = false




	_chat = hud.get_node_or_null("Chat")
	if _chat != null:
		hud.remove_child(_chat)
		ui.add_child(_chat)
		_dock_chat(true)
	aim_indicator = AimMarker.new()
	add_child(aim_indicator)
	aim_indicator.visible = false
	_toss_preview = TrajectoryPreview.new()
	add_child(_toss_preview)



	aim_indicator.net_mat = _menu_net_mat
	aim_indicator.net_node = _menu_net_node
	aim_indicator.body_rig = camera_rig
	reach_marker = ReachMarker.new()
	add_child(reach_marker)
	reach_marker.setup(camera_rig.camera)
	reach_marker.entered_reach.connect( func():
		sfx.play("reach_in", player.global_position, -8.0))
	reach_marker.action_queued.connect( func():
		sfx.play("reach_queue", player.global_position, -2.0))
	reach_marker.took.connect( func():
		sfx.play("reach_take", player.global_position, -4.0, 1.15))
	reach_marker.missed.connect( func():
		sfx.play("reach_miss", player.global_position, -8.0))
	reach_marker.early.connect( func():
		sfx.play("reach_miss", player.global_position, -8.0))
	player.out_of_range.connect( func():
		sfx.play("reach_miss", player.global_position, -8.0))

	_input_collector.dive_denied.connect( func():
		if player == null:
			return
		sfx.play("reach_miss", player.global_position, -8.0)
		if hud != null:
			hud.dive_denied()
		player.dive_denied())
	_build_bars()
	_home = _page(false)
	_build_home()
	_online = _page(false)
	_build_online()
	_local = _page()
	_build_local()
	_local_choose = _page(false)
	_build_local_choose()
	_practice = _page(false)
	_build_practice()
	_configs = _page()
	_build_configs()
	_profile = _page()
	_build_profile()



	_career = _page()
	_career.visible = false
	_build_career()
	_achievements = _page()
	_build_achievements()
	_recent = _page()
	_build_recent()
	_quick = _page()
	_build_quick()


	_settings = _page()
	_settings.visible = false
	_build_settings()
	_howto = _page()
	_howto.visible = false
	_build_howto()


	_browse = _page()
	_build_browse()
	_host = _page()
	_build_host()
	_room = _page()
	_build_room()
	_direct = _page()
	_build_direct()
	_build_friends_panel()
	_setup_online()
	var hint: = Label.new()
	hint.text = "esc: back to the menu     c: camera"
	UiStyle.style_label(hint, "small", Color(1, 1, 1, 0.6))
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hint.position = Vector2(48, -40)
	hint.visible = false
	ui.add_child(hint)
	_fp_hint = hint
	_build_matchmaking()
	_build_drill_runtime()
	_watch_local_joins()
	_resume_from_guest_locker()




	if LocalPlayers.has_guests():
		_sync_local_guests()
	_show(_home)






func _exit_tree() -> void :
	LocalPlayers.watch_joins = false
	GameConfig.menu_open = false
	GameConfig.menu_practice = false



	if is_inside_tree():
		get_viewport().disable_3d = false
	if not GameConfig.root_ui_aa:
		GameConfig.root_ui_aa = true
		GameConfig.apply_msaa()

func _watch_local_joins() -> void :

	if not LocalPlayers.roster_changed.is_connected(_on_local_roster):
		LocalPlayers.roster_changed.connect(_on_local_roster)
	if not LocalPlayers.slot_connection_changed.is_connected(_on_slot_connection):
		LocalPlayers.slot_connection_changed.connect(_on_slot_connection)

func _on_slot_connection(_slot: LocalPlayerSlot, _connected: bool) -> void :
	_on_local_roster()

func _bar_box(top: bool) -> HBoxContainer:

	var bar: = PanelContainer.new()
	var b: = StyleBoxFlat.new()

	b.bg_color = UiStyle.bg()
	b.content_margin_left = 28.0
	b.content_margin_right = 28.0

	b.content_margin_top = 18.0 if top else 9.0
	b.content_margin_bottom = 18.0 if top else 9.0
	bar.add_theme_stylebox_override("panel", b)
	if top:
		bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		_top_panel = bar
		_top_normal = b
		_top_green = b.duplicate()
		_top_green.bg_color = Color(UiStyle.SUCCESS, 0.94)
	else:
		bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
		bar.offset_bottom = 0.0
		_bottom_panel = bar

		_bar_normal = b
		_bar_green = b.duplicate()
		_bar_green.bg_color = Color(UiStyle.SUCCESS, 0.94)


	ui.add_child(bar)


	var strip: = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = UiStyle.PRIMARY
	strip.add_theme_stylebox_override("panel", sb)
	strip.custom_minimum_size.y = 4
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_sibling(strip)
	if top:
		strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		_top_strip = strip
	else:
		strip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		strip.grow_vertical = Control.GROW_DIRECTION_BEGIN
		_bottom_strip = strip
	UiBackdrop.doodles(bar, Color(UiStyle.text(), 0.05), 0.0)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	bar.add_child(h)
	return h



func _place_strips() -> void :
	if _top_strip != null and _top_panel != null:
		_top_strip.offset_top = _top_panel.size.y
		_top_strip.offset_bottom = _top_panel.size.y + 4.0
	if _bottom_strip != null and _bottom_panel != null:
		_bottom_strip.offset_top = - _bottom_panel.size.y - 4.0
		_bottom_strip.offset_bottom = - _bottom_panel.size.y

func _tab(text: String, active: bool, on_press: Callable, 
		_icon_name: = "", _icon_w: = 20) -> Button:
	var b: = Button.new()
	b.text = text



	b.custom_minimum_size = Vector2(76, 52)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiStyle.style_button(b, "primary" if active else "tertiary", 17)

	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = b.get_theme_stylebox(st) as StyleBoxFlat
		if sb != null:
			sb.content_margin_left = 13.0
			sb.content_margin_right = 13.0
	if not active:
		b.add_theme_color_override("font_color", UiStyle.muted())
		b.add_theme_color_override("font_hover_color", UiStyle.text())
		b.set_meta("bar_text", true)
	if on_press.is_valid():
		b.pressed.connect(on_press)
	return b

func _build_bars() -> void :

	var top: = _bar_box(true)
	_top_bar = top


	var hole: = Control.new()
	hole.custom_minimum_size.x = 164
	top.add_child(hole)
	top.add_child(_tab("play", true, _on_play_tab, "right"))
	top.add_child(_tab("locker", false, func():
		_wipe_to(_locker_scene()), "star"))




	var beta: = LaunchGate.public_beta()
	if not LaunchGate.economy_off():
		top.add_child(_tab("shop", false, func():
			_wipe_to(_shop_scene()), "shoppingCart"))


	top.add_child(_tab("profile", false, func(): _show(_profile), "singleplayer"))


	if not LaunchGate.is_demo() and ResourceLoader.exists(CAREER_PAGE):
		top.add_child(_tab("career", false, func(): _show(_career), "medal1"))
	if not beta and ResourceLoader.exists(AWARDS_PAGE):
		_awards_tab = _tab("awards", false, func(): _show_achievements(), "medal1")
		top.add_child(_awards_tab)
	var spring: = Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spring)





	var dock: = PanelContainer.new()
	var dsb: = UiStyle.flat_box(UiStyle.sunk(), UiStyle.CAPSULE)
	dsb.content_margin_left = 8.0
	dsb.content_margin_right = 10.0
	dsb.content_margin_top = 13.0
	dsb.content_margin_bottom = 7.0
	dock.add_theme_stylebox_override("panel", dsb)
	dock.custom_minimum_size.x = PARTY_DOCK_W
	dock.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(dock)
	_party_strip = HBoxContainer.new()
	_party_strip.add_theme_constant_override("separation", 6)
	_party_strip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dock.add_child(_party_strip)
	var spring_b: = Control.new()
	spring_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spring_b)


	_friends_btn = UiStyle.icon_button("multiplayer", "secondary", 40)
	_friends_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_friends_btn.tooltip_text = "friends"
	_friends_btn.visible = Net.steam_transport_available()
	_friends_btn.pressed.connect(_toggle_friends_panel)
	top.add_child(_friends_btn)


	var settings: = UiStyle.icon_button("gear", "secondary", 40)
	settings.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	settings.tooltip_text = "settings"


	settings.pressed.connect( func(): _open_settings(SettingsPanel.Scope.SYSTEM))
	top.add_child(settings)
	var quit: = UiStyle.icon_button("power", "exit", 40)
	quit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	quit.tooltip_text = "quit"
	quit.pressed.connect( func():
		UiStyle.confirm(self, "quit the game?", "", 
			func():
				GameConfig.flush_saves()
				get_tree().quit(), "quit", "stay", "exit"))
	top.add_child(quit)
	var logo: = TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.size = Vector2(200, 62)
	logo.position = Vector2(14, 14)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(logo)
	_logo_rect = logo

	var bottom: = _bar_box(false)
	_bottom_bar = bottom


	bottom.add_theme_constant_override("separation", 10)
	_bar_normal.content_margin_right = 18.0
	_bar_green.content_margin_right = 18.0


	bottom.add_child(_build_player_card())





	if DISCORD_URL != "":
		var discord: = Button.new()
		discord.text = "discord"
		UiStyle.style_button(discord, "blue", 15)
		_tint_button(discord, DISCORD_BLURPLE)
		if ResourceLoader.exists(DISCORD_ICON):
			discord.icon = load(DISCORD_ICON)
		discord.add_theme_constant_override("icon_max_width", 24)
		discord.add_theme_constant_override("h_separation", 8)
		discord.custom_minimum_size = Vector2(0, 40)
		discord.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		discord.tooltip_text = "join the official discord"
		discord.pressed.connect( func(): OS.shell_open(DISCORD_URL))
		_snug(discord)
		bottom.add_child(discord)
		_discord_btn = discord




	var spring_mm_l: = Control.new()
	spring_mm_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(spring_mm_l)


	_mm_title = Label.new()
	_mm_title.text = "matchmaking..."
	UiStyle.style_label(_mm_title, "title", Color.WHITE)
	_mm_title.add_theme_font_size_override("font_size", 17)
	_mm_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mm_title.visible = false
	bottom.add_child(_mm_title)
	_mm_label = Label.new()
	_mm_label.text = ""
	UiStyle.style_label(_mm_label, "small", Color(1, 1, 1, 0.92))
	_mm_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mm_label.visible = false
	bottom.add_child(_mm_label)
	_mm_cancel = Button.new()
	_mm_cancel.text = "cancel"


	UiStyle.style_button(_mm_cancel, "danger", 15)
	_mm_cancel.custom_minimum_size = Vector2(108, 36)
	_mm_cancel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mm_cancel.visible = false
	_mm_cancel.pressed.connect(_cancel_search)
	bottom.add_child(_mm_cancel)
	var spring_mm_r: = Control.new()
	spring_mm_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(spring_mm_r)


	if SHOW_FEEDBACK_BUTTON:
		var report: = Button.new()
		report.text = "report a bug"
		UiStyle.style_button(report, "secondary", 14)
		report.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		report.pressed.connect(_open_feedback)
		bottom.add_child(report)

	var outfit: = Button.new()
	outfit.text = tr("outfit: ") + tr(OUTFIT_LABELS.get(_outfit, _outfit))
	UiStyle.style_button(outfit, "secondary", 15)
	outfit.pressed.connect( func():
		_outfit = OUTFITS[(OUTFITS.find(_outfit) + 1) % OUTFITS.size()]
		outfit.text = tr("outfit: ") + tr(OUTFIT_LABELS.get(_outfit, _outfit))
		_apply_outfit()
		Net.send_party_look(_outfit)
		if _practice_court != null and _practice_court.running()\
		and _practice_court.main.get("_practice") != null:
			_practice_court.main.get("_practice").redress_self(_outfit)

		GameConfig.menu_outfit = _outfit
		GameConfig.save_settings())
	_snug(outfit)
	bottom.add_child(outfit)
	var ballbtn: = Button.new()
	ballbtn.text = tr("ball: ") + tr(BALL_LABELS.get(_ball_skin, _ball_skin))
	UiStyle.style_button(ballbtn, "secondary", 15)
	ballbtn.pressed.connect( func():
		_ball_skin = BALL_SKINS[(BALL_SKINS.find(_ball_skin) + 1) % BALL_SKINS.size()]
		ballbtn.text = tr("ball: ") + tr(BALL_LABELS.get(_ball_skin, _ball_skin))
		if ball != null:
			ball.set_ball_skin(_ball_skin)
		Net.send_party_ball(_ball_skin)

		GameConfig.menu_ball = _ball_skin
		GameConfig.save_settings())
	_snug(ballbtn)
	bottom.add_child(ballbtn)



	var stage_ids: = Stage.freeplay_ids()
	var stagebtn: = UiSelect.new(stage_ids.map( func(s): return Stage.title(s).to_lower()))
	stagebtn.prefix = "stage: "
	stagebtn.open_up = true
	stagebtn.selected = maxi(stage_ids.find(_freeplay_stage), 0)
	UiStyle.style_button(stagebtn, "secondary", 15)
	stagebtn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	stagebtn.picked.connect( func(i: int):
		_swap_stage_live(stage_ids[i])

		stagebtn.selected = maxi(stage_ids.find(_freeplay_stage), 0))
	stagebtn.disabled = Net.party and not Net.is_host
	_stage_btn = stagebtn
	_snug(stagebtn)
	bottom.add_child(stagebtn)
	var fp: = Button.new()
	fp.text = "freeplay"
	UiStyle.style_button(fp, "primary", 18)
	fp.pressed.connect(_try_freeplay)
	bottom.add_child(fp)
	var version: = Label.new()
	version.text = "v%s" % GameConfig.VERSION
	UiStyle.style_label(version, "small")
	version.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	version.custom_minimum_size.x = 56


	if LaunchGate.public_beta():


		version.text = "beta build\ncontent nonfinal"
		version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		version.add_theme_constant_override("line_spacing", -3)
		version.custom_minimum_size.x = 0
		version.add_theme_color_override("font_color", Color(0, 0, 0, 0.45))
	bottom.add_child(version)
	_version_label = version
	_refresh_player_card()
	_refresh_couch_gates()







const BAR_PILL_PAD: = 12.0

func _snug(btn: Button) -> void :
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = btn.get_theme_stylebox(st)
		if not sb is StyleBoxFlat:
			continue
		var c: = (sb as StyleBoxFlat).duplicate() as StyleBoxFlat
		c.content_margin_left = BAR_PILL_PAD
		c.content_margin_right = BAR_PILL_PAD
		btn.add_theme_stylebox_override(st, c)


func _tint_button(btn: Button, fill: Color) -> void :
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb: = btn.get_theme_stylebox(st)
		if not sb is StyleBoxFlat:
			continue
		var c: = (sb as StyleBoxFlat).duplicate() as StyleBoxFlat
		c.bg_color = fill.lightened(0.08) if st == "hover" or st == "focus"\
		else (fill.darkened(0.08) if st == "pressed" else fill)
		btn.add_theme_stylebox_override(st, c)

func _build_player_card() -> Control:
	var card: = HBoxContainer.new()
	card.add_theme_constant_override("separation", 12)
	card.size_flags_vertical = Control.SIZE_SHRINK_CENTER






	var hole: = Control.new()
	hole.custom_minimum_size.x = 62
	card.add_child(hole)
	var pfp: = TextureRect.new()
	pfp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pfp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pfp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(pfp)
	pfp.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	pfp.offset_left = 20
	pfp.offset_right = 84
	pfp.offset_top = -64
	pfp.offset_bottom = 0
	_pc_avatar = pfp



	_load_card_pfp.call_deferred(pfp)


	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pc_name = Label.new()
	UiStyle.style_label(_pc_name, "body")
	_pc_name.add_theme_font_size_override("font_size", 15)
	col.add_child(_pc_name)
	var lvrow: = HBoxContainer.new()
	lvrow.add_theme_constant_override("separation", 8)
	_pc_level = Label.new()

	UiStyle.style_pill(_pc_level, UiStyle.CHIP, Color.WHITE, 12)
	var lv_box: = _pc_level.get_theme_stylebox("normal") as StyleBoxFlat
	lv_box.content_margin_left = 8.0
	lv_box.content_margin_right = 8.0
	lv_box.content_margin_top = 0.0
	lv_box.content_margin_bottom = 1.0
	_pc_level.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lvrow.add_child(_pc_level)



	_pc_xp = LiquidBar.new(UiStyle.sunk(), 15.0)
	_pc_xp.custom_minimum_size.x = 110
	_pc_xp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lvrow.add_child(_pc_xp)
	_pc_xp_text = Label.new()
	UiStyle.style_label(_pc_xp_text, "small", UiStyle.muted())
	_pc_xp_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lvrow.add_child(_pc_xp_text)
	col.add_child(lvrow)
	card.add_child(col)


	var coinbox: = HBoxContainer.new()
	coinbox.add_theme_constant_override("separation", 7)
	coinbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pc_purse = _coin_disc(20)
	coinbox.add_child(_pc_purse)
	_pc_coins = Label.new()
	UiStyle.style_label(_pc_coins, "body")
	_pc_coins.add_theme_font_size_override("font_size", 16)
	coinbox.add_child(_pc_coins)
	card.add_child(coinbox)




	if LaunchGate.economy_off():
		lvrow.visible = false
		coinbox.visible = false



	_pc_div = Panel.new()
	_pc_div.custom_minimum_size = Vector2(2, 34)
	var db: = StyleBoxFlat.new()
	db.bg_color = Color(UiStyle.muted(), 0.25)
	db.set_corner_radius_all(1)
	_pc_div.add_theme_stylebox_override("panel", db)
	_pc_div.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card.add_child(_pc_div)
	return card



func _tint_player_card(on_green: bool) -> void :
	if _pc_name == null:
		return
	var strong: = Color.WHITE if on_green else UiStyle.text()
	var soft: = Color(1.0, 1.0, 1.0, 0.85) if on_green else UiStyle.muted()
	_pc_name.add_theme_color_override("font_color", strong)
	_pc_coins.add_theme_color_override("font_color", strong)
	_pc_xp_text.add_theme_color_override("font_color", soft)



	_pc_xp.visible = not on_green
	_pc_xp_text.visible = not on_green
	if _pc_div != null:
		var sb: = _pc_div.get_theme_stylebox("panel") as StyleBoxFlat
		if sb != null:
			sb.bg_color = Color(1.0, 1.0, 1.0, 0.7) if on_green\
			else Color(UiStyle.muted(), 0.25)




func _tint_top_bar(on_green: bool) -> void :
	if _top_bar == null:
		return
	var texts: Array = _top_bar.get_children()
	if _party_strip != null:
		texts.append_array(_party_strip.get_children())
	for c in texts:
		if not (c is Button) or not c.has_meta("bar_text"):
			continue
		c.add_theme_color_override("font_color", 
			Color(1.0, 1.0, 1.0, 0.9) if on_green else UiStyle.muted())
		c.add_theme_color_override("font_hover_color", 
			Color.WHITE if on_green else UiStyle.text())



func _refresh_player_card() -> void :
	if _pc_name == null:
		return
	var p: = ProfileStore.active()
	if p == null:
		return
	_pc_name.text = p.name


	if p == _pc_seen_profile and p.level > _pc_seen_level:
		_pc_level_up()
	_pc_seen_profile = p
	_pc_seen_level = p.level
	_pc_level.text = "lv %d" % p.level
	var need: = Progression.xp_for_next(p.level)
	var maxed: = p.level >= Progression.LEVEL_MAX
	_pc_xp.fill = 1.0 if maxed else clampf(float(p.xp) / float(maxi(1, need)), 0.0, 1.0)
	_pc_xp_text.text = "max level" if maxed else "%s / %s xp" % [_comma(p.xp), _comma(need)]

	_pc_coins.text = _comma(maxi(0, p.coins - _purse_air))

func _pc_level_up() -> void :
	_pc_xp.flash()
	UiStyle.sfx("level_up")
	var box: = _pc_level.get_theme_stylebox("normal") as StyleBoxFlat
	var t: = create_tween()
	t.tween_method( func(k: float):
		box.bg_color = UiStyle.CHIP.lerp(MatchRewards.FLASH, k), 
		1.0, 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_pc_level.pivot_offset = _pc_level.size * 0.5
	_pc_level.scale = Vector2.ONE * 1.3
	create_tween().tween_property(_pc_level, "scale", Vector2.ONE, 0.35)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)





func _fly_chips(amount: int, from: Vector2) -> void :
	if amount <= 0:
		return
	if _pc_purse == null or not _pc_purse.is_visible_in_tree():
		_refresh_player_card()
		return
	_purse_air += amount
	_refresh_player_card()
	UiStyle.chip_fly(from, _pc_purse, amount, 
		func(share: int):
			_purse_air = maxi(0, _purse_air - share)
			_refresh_player_card(), 
		func(): _refresh_player_card())


func _load_card_pfp(rect: TextureRect) -> void :
	var tex: = await CharacterPortrait.render(GameConfig.character, "head", 
		Vector2i(140, 140), self)
	if is_instance_valid(rect):
		rect.texture = tex





func _coin_disc(px: = 20) -> Control:
	return UiStyle.coin_disc(px)


func _comma(n: int) -> String:
	return UiStyle.commafy(n)

func _page(carded: = true) -> Control:
	var holder: = MarginContainer.new()
	holder.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	holder.position.x = 96



	holder.add_theme_constant_override("margin_top", 100)
	holder.add_theme_constant_override("margin_bottom", 92)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(holder)
	var center: = VBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(center)
	var panel: = PanelContainer.new()
	panel.name = "Panel"
	center.add_child(panel)
	var v: = VBoxContainer.new()
	v.name = "Box"
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size.x = 340
	if not carded:
		panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		panel.add_child(v)
		return holder




	var fsb: = UiStyle.flat_box(Color("2a2a30") if UiStyle.dark else UiStyle.PRIMARY, 30)
	fsb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", fsb)
	UiBackdrop.doodles(panel, Color(1, 1, 1, 0.04) if UiStyle.dark else Color(1, 1, 1, 0.32))
	var outer: = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	panel.add_child(outer)
	var head: = VBoxContainer.new()
	head.name = "Head"
	outer.add_child(head)
	var card: = PanelContainer.new()
	card.name = "Card"
	var csb: = UiStyle.card_box(UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	csb.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", csb)
	outer.add_child(card)
	card.add_child(v)
	var foot: = HBoxContainer.new()
	foot.name = "Foot"
	foot.add_theme_constant_override("separation", 14)
	outer.add_child(foot)
	v.set_meta("head", head)
	v.set_meta("foot", foot)
	v.set_meta("card", card)
	return holder

func _box(page: Control) -> VBoxContainer:
	return page.find_child("Box", true, false) as VBoxContainer

func _menu_btn(text: String, kind: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.text = text
	b.custom_minimum_size.y = 62
	UiStyle.style_button(b, kind, 22)
	if on_press.is_valid():
		b.pressed.connect(on_press)
	return b

func _group(v: VBoxContainer, text: String) -> void :

	var p: = Label.new()
	p.text = text
	UiStyle.style_label(p, "title")
	v.add_child(p)
	var rule: = Panel.new()
	rule.custom_minimum_size = Vector2(56, 5)
	var rb: = StyleBoxFlat.new()
	rb.bg_color = UiStyle.PRIMARY
	rb.set_corner_radius_all(3)
	rule.add_theme_stylebox_override("panel", rb)
	v.add_child(rule)



func _quality(fps: int, resolution: int) -> void:
	GameConfig.max_fps = fps
	GameConfig.resolution_3d = resolution
	MobileRender.apply()
	GameConfig.apply_render_scale()
	GameConfig.apply_frame_cap()
	GameConfig.save_settings()

func _offline() -> void:
	GameConfig.stage = "grass"
	_go_to_match(1)

func _build_home() -> void :



	var v: = _box(_home)

	v.add_theme_constant_override("separation", 9)
	if MobileRender.enabled():
		var phone_options := HBoxContainer.new()
		_root.add_child(phone_options)
		phone_options.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		phone_options.offset_left = -170
		phone_options.offset_right = 70
		phone_options.offset_top = -47
		phone_options.offset_bottom = -9
		phone_options.z_index = 30
		for option in ["30 FPS", "60 FPS", "Журнал"]:
			var button := Button.new()
			button.text = option
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size.y = 36
			UiStyle.style_button(button, "tertiary", 14)
			phone_options.add_child(button)
			if option == "Журнал":
				button.pressed.connect(func():
					DisplayServer.clipboard_set(MobileDiagnostics.read_log())
					_flash_notice("Журнал скопійовано"))
			else:
				var fps: int = 30 if option == "30 FPS" else 60
				button.pressed.connect(func(): _quality(fps, 60 if fps == 30 else 75))
	var online_card: = _card_btn("massiveMultiplayer", "online", 
		MenuCopy.sub("online"), "primary", _open_online)
	var local_card: = _card_btn("singleplayer", "local", 
		MenuCopy.sub("local"), "info", _open_local)
	_card_local = local_card.get_child(0) as Button
	var practice_card: = _card_btn("target", "practice", 
		MenuCopy.sub("practice"), "info", func(): _show(_practice), false, UiStyle.SUCCESS)


	var coop_card: = _card_btn("gamepad", "controller config", 
		MenuCopy.sub("controllers"), "info", func():
			_show(_configs), false, UiStyle.HIGHLIGHT)



	var settings_card: = _card_btn("gear", "system settings", 
		"configure audio, video, display", "quiet", 
		func(): _open_settings(SettingsPanel.Scope.SYSTEM))
	var cards: = [online_card, local_card, practice_card, coop_card, settings_card]


	var feedback_card: = _card_btn("question", "feedback & bug reports", 
		"", "quiet", 
		func(): _open_feedback())
	cards.append(feedback_card)



	var credits_card: = _card_btn("movie", "credits", "", "primary", 
		func(): _open_credits(), true)
	cards.append(credits_card)
	for card in cards:
		v.add_child(card)


	var btns: Array = []
	for card in cards:
		btns.append((card as Control).get_child(0) as Button)
	for i in btns.size():
		var b: = btns[i] as Button
		if b == null:
			continue
		if i > 0:
			b.focus_neighbor_top = b.get_path_to(btns[i - 1] as Button)
		if i < btns.size() - 1:
			b.focus_neighbor_bottom = b.get_path_to(btns[i + 1] as Button)








func _tilt_cards(delta: float) -> void :
	if _freeplay or _tilt.is_empty():
		return
	var vp: = get_viewport().get_visible_rect().size
	if vp.x <= 0.0:
		return
	var off: = (ui.get_viewport().get_mouse_position() / vp)\
	- Vector2(0.5, 0.5)
	if _tilt_fake != 0.0:
		off.x = _tilt_fake
	var k: = clampf(delta * 9.0, 0.0, 1.0)
	var depth: = 0
	for c in _tilt:
		var card: = c as Button
		if not is_instance_valid(card):
			continue
		if not card.is_visible_in_tree():
			continue




		card.offset_transform_enabled = true
		card.offset_transform_pivot_ratio = Vector2(0.5, 0.5)


		var hovered: = card.has_focus() or card.get_global_rect().has_point(
			ui.get_viewport().get_mouse_position())




		var recede: = 1.0 - 0.026 * float(depth)
		var fan: = 0.028 - 0.016 * float(depth)
		var want_rot: = 0.0 if hovered else fan - off.x * 0.06
		var want_scale: = 1.07 if hovered else recede - absf(off.x) * 0.012
		var want_x: = (52.0 if hovered else 8.0 * float(depth))\
		- off.x * (26.0 + 8.0 * float(depth))
		card.offset_transform_rotation = lerpf(
			card.offset_transform_rotation, want_rot, k)
		card.offset_transform_scale = card.offset_transform_scale.lerp(
			Vector2.ONE * want_scale, k)
		card.offset_transform_position.x = lerpf(
			card.offset_transform_position.x, want_x, k)

		card.z_index = 2 if hovered else 0
		depth += 1



func _lean_tiles(delta: float) -> void :
	if _freeplay or _lean.is_empty():
		return
	var vp: = get_viewport().get_visible_rect().size
	if vp.x <= 0.0:
		return
	var mouse: = ui.get_viewport().get_mouse_position()
	var off: = (mouse / vp) - Vector2(0.5, 0.5)
	if _tilt_fake != 0.0:
		off.x = _tilt_fake
	var k: = clampf(delta * 9.0, 0.0, 1.0)
	for c in _lean:
		var t: = c as Control
		if not is_instance_valid(t) or not t.is_visible_in_tree():
			continue
		t.offset_transform_enabled = true
		t.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
		var hovered: = t.get_global_rect().has_point(mouse)
		var want_rot: = 0.0 if hovered else - off.x * 0.05
		var want_scale: = 1.08 if hovered else 1.0 - absf(off.x) * 0.01
		t.offset_transform_rotation = lerpf(t.offset_transform_rotation, want_rot, k)
		t.offset_transform_scale = t.offset_transform_scale.lerp(
			Vector2.ONE * want_scale, k)
		t.offset_transform_position.x = lerpf(
			t.offset_transform_position.x, - off.x * 14.0, k)
		t.z_index = 2 if hovered else 0







func _card_btn(icon_name: String, title: String, sub: String, 
		kind: String, on_press: Callable, slim: = false, 
		tint: = Color(0, 0, 0, 0)) -> Control:
	var yellow: = kind == "primary"
	var disc_c: = Color.WHITE if yellow\
	else (UiStyle.MUTED if kind == "quiet" else UiStyle.SECONDARY)
	if tint.a > 0.0 and not yellow:
		disc_c = tint
	var b: = Button.new()

	b.custom_minimum_size = Vector2(430, 46 if slim else 74)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var fill: = UiStyle.PRIMARY if yellow else UiStyle.card()
	var radius: = 18 if slim else 24
	for state in [["normal", fill], ["hover", fill.lightened(0.06) if yellow else fill.lerp(UiStyle.SECONDARY, 0.06)], 
		["pressed", fill.darkened(0.06)], 
		["disabled", Color(UiStyle.muted(), 0.3)]]:
		b.add_theme_stylebox_override(String(state[0]), UiStyle.flat_box(state[1], radius, 
			not yellow and String(state[0]) != "disabled"))



	var focus_ring: = UiStyle.flat_box(fill.lightened(0.06), radius)
	focus_ring.set_border_width_all(4)
	focus_ring.border_color = UiStyle.SECONDARY
	b.add_theme_stylebox_override("focus", focus_ring)
	if yellow and not slim:
		UiBackdrop.doodles(b, Color(1, 1, 1, 0.38))
	var pad: = MarginContainer.new()
	pad.set_anchors_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_%s" % side, 14)
	b.add_child(pad)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)


	var disc_px: = 34 if slim else 54
	var st: = UiStyle.sticker(icon_name, disc_c, disc_px, 
		-0.08 if _tilt.size() % 2 == 0 else 0.06, 
		UiStyle.INK if yellow else Color.WHITE)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(st)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var t: = Label.new()
	t.text = title
	UiStyle.style_label(t, "title", UiStyle.INK if yellow else UiStyle.text())
	t.add_theme_font_size_override("font_size", 20 if slim else 27)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(t)

	if sub != "":
		var s: = Label.new()
		s.text = sub
		UiStyle.style_label(s, "small", 
			Color(UiStyle.INK, 0.66) if yellow else UiStyle.muted())
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(s)
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	b.pressed.connect(UiStyle.sfx.bind("confirm" if yellow else "press"))
	UiStyle.hover_sound(b)
	if on_press.is_valid():
		b.pressed.connect(on_press)
	var card_wrap: = MarginContainer.new()
	card_wrap.add_theme_constant_override("margin_left", 30)
	card_wrap.add_child(b)
	_tilt.append(b)
	return card_wrap

func _ribbon_box(fill: Color) -> StyleBoxFlat:
	var rb: = StyleBoxFlat.new()
	rb.bg_color = fill
	rb.set_corner_radius_all(99)
	rb.content_margin_left = 30.0
	rb.content_margin_right = 56.0
	rb.content_margin_top = 8.0
	rb.content_margin_bottom = 10.0
	return rb

func _hero_btn(text_in: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.text = text_in
	b.add_theme_stylebox_override("normal", _ribbon_box(Color(UiStyle.INK, 0.45)))
	b.add_theme_stylebox_override("hover", _ribbon_box(Color(UiStyle.INK, 0.6)))
	b.add_theme_stylebox_override("pressed", _ribbon_box(Color(UiStyle.INK, 0.6)))
	b.add_theme_stylebox_override("focus", _ribbon_box(Color(UiStyle.INK, 0.6)))
	b.add_theme_stylebox_override("disabled", _ribbon_box(Color(UiStyle.INK, 0.3)))
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	b.add_theme_font_size_override("font_size", 46)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", UiStyle.PRIMARY)
	b.add_theme_color_override("font_pressed_color", 
		UiStyle.PRIMARY.darkened(0.1))
	b.add_theme_color_override("font_hover_pressed_color", UiStyle.PRIMARY)
	b.add_theme_color_override("font_focus_color", UiStyle.PRIMARY)
	b.add_theme_color_override("font_outline_color", UiStyle.INK)
	b.add_theme_constant_override("outline_size", 12)
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	b.pressed.connect(UiStyle.sfx.bind("press"))
	UiStyle.hover_sound(b)
	b.pressed.connect(on_press)
	return b




func _ribbon_btn(text_in: String, kind: String, on_press: Callable) -> Button:
	var b: = Button.new()
	b.text = text_in
	if kind == "back":
		for st in ["normal", "hover", "pressed", "disabled"]:
			b.add_theme_stylebox_override(st, StyleBoxEmpty.new())


		var back_focus: = StyleBoxFlat.new()
		back_focus.bg_color = Color(0, 0, 0, 0.3)
		back_focus.set_corner_radius_all(10)
		back_focus.set_border_width_all(3)
		back_focus.border_color = UiStyle.SECONDARY
		back_focus.set_content_margin_all(6)
		b.add_theme_stylebox_override("focus", back_focus)
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
		b.add_theme_font_size_override("font_size", 22)
		b.add_theme_color_override("font_outline_color", UiStyle.INK)
		b.add_theme_constant_override("outline_size", 8)
		b.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_pressed_color", Color.WHITE)
		b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
		b.add_theme_color_override("font_focus_color", Color.WHITE)
	else:
		var yellow: = kind == "primary"
		var fill: = Color(UiStyle.PRIMARY, 0.96) if yellow\
		else Color(UiStyle.INK, 0.45)
		var hov: = UiStyle.PRIMARY if yellow else Color(UiStyle.INK, 0.62)
		b.add_theme_stylebox_override("normal", _ribbon_box(fill))
		b.add_theme_stylebox_override("hover", _ribbon_box(hov))
		b.add_theme_stylebox_override("pressed", _ribbon_box(hov))
		b.add_theme_stylebox_override("focus", _ribbon_box(hov))
		b.add_theme_stylebox_override("disabled", 
			_ribbon_box(Color(UiStyle.INK, 0.25)))
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		b.add_theme_font_size_override("font_size", 26)
		var tc: = UiStyle.INK if yellow else Color.WHITE
		var th: = UiStyle.INK if yellow else UiStyle.PRIMARY
		b.add_theme_color_override("font_color", tc)
		b.add_theme_color_override("font_hover_color", th)
		b.add_theme_color_override("font_pressed_color", th)
		b.add_theme_color_override("font_hover_pressed_color", th)
		b.add_theme_color_override("font_focus_color", th)
		b.add_theme_color_override("font_outline_color", UiStyle.INK)
		b.add_theme_constant_override("outline_size", 0 if yellow else 6)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	b.pressed.connect(UiStyle.sfx.bind("confirm" if kind == "primary" else "press"))
	UiStyle.hover_sound(b)
	if on_press.is_valid():
		b.pressed.connect(on_press)
	return b



const HEAD_STICKERS: = {
	"online": ["massiveMultiplayer", "blue"], "local": ["singleplayer", "blue"], 
	"practice": ["target", "green"], "profile": ["singleplayer", "blue"], 
	"recently deleted": ["trashcan", "grey"], "quick match": ["massiveMultiplayer", "blue"], 
	"friends": ["multiplayer", "pink"], "custom match": ["plus", "pink"], 
	"how to play": ["question", "grey"], "server browser": ["menuList", "green"], 
	"custom lobby": ["plus", "pink"], "join lan": ["share1", "blue"], 
	"system settings": ["gear", "grey"], "profile settings": ["wrench", "blue"], 
}

func _head_sticker(text_in: String, px: = 50) -> Control:
	var pick: Array = HEAD_STICKERS.get(text_in, ["star", "grey"])
	var c: Color = {"blue": UiStyle.SECONDARY, "green": UiStyle.SUCCESS, 
		"pink": UiStyle.HIGHLIGHT}.get(String(pick[1]), UiStyle.MUTED)
	var st: = UiStyle.sticker(String(pick[0]), c, px, -0.08)
	st.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return st




func _hero_head(v: VBoxContainer, text_in: String, on_card: = false) -> Label:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(_head_sticker(text_in))
	var l: = Label.new()
	l.text = text_in
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", 
		UiStyle.text() if (UiStyle.dark or not on_card) else UiStyle.INK)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	if v.has_meta("head"):
		var slot: = v.get_meta("head") as Control
		for c in slot.get_children():
			slot.remove_child(c)
			c.queue_free()
		slot.add_child(row)
		return l
	if on_card:
		v.add_child(row)
		return l

	var cap: = PanelContainer.new()
	var csb: = UiStyle.flat_box(UiStyle.card(), UiStyle.CAPSULE, true)
	csb.content_margin_left = 10.0
	csb.content_margin_right = 30.0
	csb.content_margin_top = 8.0
	csb.content_margin_bottom = 8.0
	cap.add_theme_stylebox_override("panel", csb)
	cap.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cap.add_child(row)
	var hwrap: = MarginContainer.new()
	hwrap.add_theme_constant_override("margin_bottom", 6)
	hwrap.add_child(cap)
	v.add_child(hwrap)
	return l


func _back_btn(on_press: Callable, text_in: = "back") -> Button:
	var b: = _menu_btn(text_in, "secondary", on_press)
	b.icon = UiStyle.icon("arrowLeft", true)
	for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", 
			"icon_hover_pressed_color", "icon_focus_color"]:
		b.add_theme_color_override(st, 
			UiStyle.SECONDARY.lightened(0.25) if UiStyle.dark else UiStyle.SECONDARY)
	b.add_theme_constant_override("icon_max_width", 22)
	b.add_theme_constant_override("h_separation", 10)
	b.add_theme_font_size_override("font_size", 19)
	b.custom_minimum_size = Vector2(150, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.set_meta("page_back", true)
	return b




func _open_online() -> void :
	if MobileRender.enabled():
		_flash_notice("Онлайн ще не підключений")
		return
	if not OnlineTerms.require(_open_online):
		return
	_show(_online)

func _build_online() -> void :
	var v: = _box(_online)
	v.add_theme_constant_override("separation", 12)
	_hero_head(v, "online")
	v.add_child(_card_btn("massiveMultiplayer", "quick match", 
		MenuCopy.sub("quick_match"), "primary", func(): _show(_quick)))
	v.add_child(_card_btn("menuList", "server browser", 
		MenuCopy.sub("server_browser"), "info", func():
			_show(_browse)
			_refresh_browser()))
	var custom_card: = _card_btn("plus", "custom lobby", 
		MenuCopy.sub("custom_lobby"), "info", func(): _show(_host))
	_card_custom_lobby = custom_card.get_child(0) as Button
	v.add_child(custom_card)

	_back_row(v, func(): _show(_home))



func _open_local() -> void :
	if MobileRender.enabled() or LaunchGate.public_beta():
		_open_local_standard()
	else:
		_show(_local_choose)

func _open_local_standard() -> void :
	_populate_local()
	_show(_local)

func _build_local_choose() -> void :
	var v: = _box(_local_choose)
	v.add_theme_constant_override("separation", 12)
	_hero_head(v, "local")
	v.add_child(_card_btn("singleplayer", "standard", 
		MenuCopy.sub("local_standard"), "primary", _open_local_standard))
	v.add_child(_card_btn("multiplayer", "host lan", 
		MenuCopy.sub("host_lan"), "info", _on_host))
	var direct_card: = _card_btn("share1", "join lan", 
		MenuCopy.sub("join_lan"), "info", func(): _show(_direct))
	_card_direct = direct_card.get_child(0) as Button
	v.add_child(direct_card)
	_back_row(v, func(): _show(_home))





func _session_exit_page() -> Control:
	if _lan_mode:
		set_deferred("_lan_mode", false)
		return _local_choose if _local_choose != null else _online
	return _online





func _build_local() -> void :



	var v: = _box(_local)
	v.add_theme_constant_override("separation", 10)
	_local.add_theme_constant_override("margin_top", 88)
	_local.add_theme_constant_override("margin_bottom", 70)
	_local_panel = LobbyPanel.new()
	_local_panel.stage_changed.connect( func(id: String):
		GameConfig.stage = id
		GameConfig.save_settings()
		_refresh_local())
	_local_panel.rule_changed.connect(_on_local_rule)
	_local_panel.tod_changed.connect( func(i: int):
		GameConfig.time_of_day = i
		_refresh_local())
	_local_panel.outfit_changed.connect( func(i: int):
		GameConfig.outfit_rule = DressCode.clamp_rule(i)
		_refresh_local())
	_local_panel.modifiers_pressed.connect( func(): _open_modifiers(false))
	_local_panel.global_cpu_changed.connect( func(d: int):
		GameConfig.difficulty = clampi(d, 0, 2)
		CpuSlots.set_all_diff(GameConfig.local_cpus, GameConfig.difficulty)
		_refresh_local())
	_local_panel.cpu_diff_step.connect( func(id: String, dir: int):
		_cpu_step(GameConfig.local_cpus, id, dir, _refresh_local))
	_local_panel.cpu_reroll.connect( func(id: String):
		_cpu_reroll(GameConfig.local_cpus, id, _refresh_local))
	_local_panel.side_pressed.connect( func(side: int):
		if side != 0:
			GameConfig.local_side = side
			_refresh_local())
	_local_panel.start_pressed.connect(_start_local)
	_local_panel.captain_pressed.connect( func(side: int, seat: String):
		Net.set_captain(side, seat)
		_refresh_local())
	_local_panel.back_pressed.connect( func(): _show(_home))
	_local_panel.reset_pressed.connect( func():
		GameConfig.set_points = int(Net.RULE_DEFAULTS.pts)
		GameConfig.sets_to_win = int(Net.RULE_DEFAULTS.sets)
		GameConfig.win_by_two = bool(Net.RULE_DEFAULTS.wbt)
		GameConfig.sweat_enabled = bool(Net.RULE_DEFAULTS.sweat)
		GameConfig.sweat_rate = float(Net.RULE_DEFAULTS.rate)
		GameConfig.instant_replays = bool(Net.RULE_DEFAULTS.replays)
		GameConfig.team_collision = bool(Net.RULE_DEFAULTS.collide)
		GameConfig.serve_seconds = int(Net.RULE_DEFAULTS.serve)
		GameConfig.ball_hints = bool(Net.RULE_DEFAULTS.hints)
		GameConfig.lock_teams = bool(Net.RULE_DEFAULTS.lock)
		GameConfig.rotate_every_point = bool(Net.RULE_DEFAULTS.rotate)
		GameConfig.match_intro = bool(Net.RULE_DEFAULTS.intro)
		_refresh_local()
		_refresh_modifiers())
	v.add_child(_local_panel)

var _local_panel: LobbyPanel = null
var _local_size: = 2





var _modifiers: ModifiersPanel = null
var _mods_online: = false

func _open_modifiers(online: bool) -> void :
	if not GameConfig.modifiers_allowed():
		return
	_mods_online = online
	if _modifiers == null:
		_modifiers = ModifiersPanel.new()
		ui.add_child(_modifiers)
		_modifiers.changed.connect( func(key: String, value: Variant):


			if _mods_online:
				_on_room_rule(key, value)
			else:
				_on_local_rule(key, value))
		_modifiers.reset_pressed.connect(_reset_modifiers)
	_refresh_modifiers()
	_modifiers.open()




func _refresh_modifiers() -> void :




	if _modifiers == null:
		return
	if _mods_online:
		_modifiers.editable = Net.is_host
		_modifiers.set_values({
			"replays": Net.rule_replays, 
			"collide": Net.rule_collide, 
			"rate": _rate_index(Net.rule_rate, Net.rule_sweat), 
			"serve": _serve_index(Net.rule_serve), 
			"hints": Net.rule_hints, 
			"lock": Net.rule_lock, 
			"rotate": Net.rule_rotate, 
			"intro": Net.rule_intro})
	else:


		_modifiers.editable = true
		_modifiers.set_values({
			"replays": GameConfig.instant_replays, 
			"collide": GameConfig.team_collision, 
			"rate": _rate_index(GameConfig.sweat_rate, GameConfig.sweat_enabled), 
			"serve": _serve_index(GameConfig.serve_seconds), 
			"hints": GameConfig.ball_hints, 
			"rotate": GameConfig.rotate_every_point, 
			"intro": GameConfig.match_intro})

func _reset_modifiers() -> void :
	for id in MatchModifiers.ids():
		var def: Variant = MatchModifiers.default_of(String(id))
		if _mods_online:
			_on_room_rule(String(id), def)
		else:
			_on_local_rule(String(id), def)
	_refresh_modifiers()

func _on_local_rule(key: String, value: Variant) -> void :
	match key:
		"size":
			_local_size = GameConfig.legal_team_size(clampi(int(value), 1, 6))
		"sets":
			GameConfig.sets_to_win = clampi(int(value), 1, 3)
		"points":
			GameConfig.set_points = clampi(int(value), 3, 25)
		"rate":
			var ri: = clampi(int(value), 0, SWEAT_RATES.size() - 1)
			GameConfig.sweat_enabled = ri > 0
			if ri > 0:
				GameConfig.sweat_rate = SWEAT_RATES[ri]
		"serve":
			GameConfig.serve_seconds = SERVE_TIMES[clampi(int(value), 0, SERVE_TIMES.size() - 1)]
		"wbt":
			GameConfig.win_by_two = bool(value)
		"sweat":
			GameConfig.sweat_enabled = bool(value)
		"replays":
			GameConfig.instant_replays = bool(value)
		"collide":
			GameConfig.team_collision = bool(value)
		"hints":
			GameConfig.ball_hints = bool(value)
		"lock":
			GameConfig.lock_teams = bool(value)
		"rotate":
			GameConfig.rotate_every_point = bool(value)
		"intro":
			GameConfig.match_intro = bool(value)
	_refresh_local()
	_refresh_modifiers()


func _rate_index(rate: float, enabled: bool) -> int:
	if not enabled:
		return 0
	var nearest: = 1
	for i in range(1, SWEAT_RATES.size()):
		if absf(SWEAT_RATES[i] - rate) < absf(SWEAT_RATES[nearest] - rate):
			nearest = i
	return nearest


func _serve_index(seconds: int) -> int:
	var nearest: = 0
	for i in SERVE_TIMES.size():
		if absi(SERVE_TIMES[i] - seconds) < absi(SERVE_TIMES[nearest] - seconds):
			nearest = i
	return nearest


func _cpu_step(slots: Dictionary, id: String, dir: int, after: Callable) -> void :
	var cpu: Dictionary = slots.get(id, {})
	if cpu.is_empty():
		return
	CpuSlots.set_diff(slots, id, wrapi(int(cpu.diff) + dir, 0, CpuSlots.DIFF_NAMES.size()))
	after.call()

func _cpu_reroll(slots: Dictionary, id: String, after: Callable) -> void :
	CpuSlots.reroll(slots, id)
	after.call()




func _refresh_local() -> void :
	if _local_panel == null:
		return
	var my_side: = 1 if GameConfig.local_side >= 0 else -1
	var mine: Array = []
	if Net.party:
		var ids: = Net.players.keys()
		ids.sort()
		for id in ids:
			mine.append({"kind": "human", "name": String(Net.players[id].name), 
				"cfg": Mod.shown_cfg(id, Net.players[id].get("cfg", {})), "host": id == 1, 
				"you": id == _my_party_id(), "dev": DevBadge.peer_tier(id), 
				"seat": TeamKits.seat_key(id, 0)})
	else:


		mine.append({"kind": "human", "name": LocalPlayers.primary_name(), 
			"cfg": GameConfig.character.to_dict() if GameConfig.character != null else {}, 
			"you": true, "dev": DevBadge.my_tier(), 
			"local": LocalPlayers.primary().tag() if LocalPlayers.has_guests() else "", 
			"local_color": LocalPlayers.primary().color(), 
			"seat": TeamKits.seat_key(1, 0)})
	mine = mine.slice(0, _local_size)



	var guests: = {1: [], -1: []}
	for slot in LocalPlayers.slots:
		if slot.index == 0:
			continue
		var gside: int = slot.team_side if slot.team_side != 0 else my_side
		slot.team_side = gside
		guests[gside].append({"kind": "human", "name": slot.display_name(), 
			"cfg": slot.profile.character if slot.profile != null else {}, 
			"you": false, "local": slot.tag(), "local_color": slot.color(), 
			"seat": TeamKits.seat_key(1, slot.index)})
	var humans: = {my_side: mine.size(), - my_side: 0}
	for side in [1, -1]:
		humans[side] = int(humans[side]) + guests[side].size()
	_local_size = GameConfig.legal_team_size(maxi(_local_size, maxi(int(humans[1]), int(humans[-1]))))
	CpuSlots.reconcile(GameConfig.local_cpus, _local_size, humans, GameConfig.difficulty)
	var entries: = {1: [], -1: []}
	entries[my_side] = mine
	for side in [1, -1]:
		entries[side].append_array(guests[side])
	for side in [1, -1]:
		for cpu in CpuSlots.ordered(GameConfig.local_cpus, side):
			entries[side].append({"kind": "cpu", "name": String(cpu.name), 
				"cfg": cpu.cfg, "diff": int(cpu.diff), 
				"id": CpuSlots.id_for(side, int(cpu.k)), 
				"seat": TeamKits.cpu_key(side, int(cpu.k))})


	var kit_view: = _dress_lobby_tiles(entries, Net.captains, not Net.party or Net.is_host, 
		GameConfig.stage, true, GameConfig.outfit_rule)
	_local_panel.apply({"title": "local match", "stage_ids": Stage.ids(), 
		"stage": Stage.resolve(GameConfig.stage), "tod": GameConfig.time_of_day, 
		"outfit": GameConfig.outfit_rule, 
		"size": _local_size, "home": entries[1], "away": entries[-1], 
		"kits": kit_view.kits, "alt": kit_view.alt, "kit_mode": kit_view.mode, 
		"rules": {"sets": GameConfig.sets_to_win, "points": GameConfig.set_points, 
			"wbt": GameConfig.win_by_two, "sweat": GameConfig.sweat_enabled, 
			"rate": _rate_index(GameConfig.sweat_rate, GameConfig.sweat_enabled), 
			"replays": GameConfig.instant_replays, 
			"collide": GameConfig.team_collision, 
			"serve": _serve_index(GameConfig.serve_seconds), 
			"hints": GameConfig.ball_hints, 
			"rotate": GameConfig.rotate_every_point, 
			"intro": GameConfig.match_intro}, 
		"rate_names": SWEAT_RATE_NAMES, 
		"cpu": CpuSlots.global_diff(GameConfig.local_cpus), 
		"editable": true, "my_side": my_side, "side_mode": "local", 
		"side_editable": true, "can_start": true, "invite": false})



func _populate_local() -> void :
	_local_size = GameConfig.legal_team_size(clampi(GameConfig.team_size, 1, 6))
	_refresh_local()






var _faces_warmed: = false
func _prewarm_local_faces() -> void :
	if MobileControls.enabled():
		return
	if _faces_warmed:
		return
	_faces_warmed = true



	await get_tree().create_timer(1.5).timeout
	if not is_instance_valid(self):
		return





	if GameConfig.character != null:
		var mine: = GameConfig.character.hair_flip
		CharacterPortrait.HairWarm.warm_all(mine)
		CharacterPortrait.HairWarm.warm_all( not mine)
	if Net.active or _local == null:
		return
	if _local.visible:
		return
	_populate_local()



func _back_row(v: VBoxContainer, on_press: Callable) -> void :
	if v.has_meta("foot"):
		var foot: = v.get_meta("foot") as Control
		for c in foot.get_children():
			foot.remove_child(c)
			c.queue_free()
		foot.add_child(_back_btn(on_press))
		return
	var gap: = Control.new()
	gap.custom_minimum_size.y = 10
	v.add_child(gap)
	v.add_child(_back_btn(on_press))





func _build_configs() -> void :
	var v: = _box(_configs)
	v.add_theme_constant_override("separation", 10)

	_configs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_configs.position.x = 0
	_configs.add_theme_constant_override("margin_left", 126)
	_configs.add_theme_constant_override("margin_right", 126)
	_configs.add_theme_constant_override("margin_top", 62)


	_configs.add_theme_constant_override("margin_bottom", 18)
	var panel: = _configs.find_child("Panel", true, false) as Control
	if panel != null:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	v.add_child(head)
	var titles: = VBoxContainer.new()
	titles.add_theme_constant_override("separation", 0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(titles)
	var title: = Label.new()
	title.text = "controller configurations"
	UiStyle.style_label(title, "title")
	titles.add_child(title)
	var sub: = Label.new()
	sub.name = "Sub"
	sub.text = "configure controller and profile setup"
	UiStyle.style_label(sub, "small", UiStyle.muted())
	titles.add_child(sub)
	var count: = PanelContainer.new()
	count.name = "CountPill"
	count.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var cb: = StyleBoxFlat.new()
	cb.bg_color = Color(UiStyle.SECONDARY, 0.14)
	cb.set_corner_radius_all(18)
	cb.content_margin_left = 16.0
	cb.content_margin_right = 16.0
	cb.content_margin_top = 8.0
	cb.content_margin_bottom = 8.0
	count.add_theme_stylebox_override("panel", cb)
	var crow: = HBoxContainer.new()
	crow.add_theme_constant_override("separation", 8)
	count.add_child(crow)
	var cicon: = TextureRect.new()
	cicon.texture = UiStyle.icon("multiplayer", false, true)
	cicon.custom_minimum_size = Vector2(20, 20)
	cicon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cicon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cicon.modulate = UiStyle.SECONDARY
	crow.add_child(cicon)
	var clbl: = Label.new()
	clbl.name = "CountLabel"
	clbl.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	clbl.add_theme_font_size_override("font_size", 16)
	clbl.add_theme_color_override("font_color", UiStyle.SECONDARY)
	crow.add_child(clbl)
	head.add_child(count)


	_configs_row = HBoxContainer.new()
	_configs_row.add_theme_constant_override("separation", 14)
	_configs_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_configs_row)
	_cfg_panels.clear()
	var hooks: = {
		"open_locker": Callable(self, "_open_guest_locker"), 
		"flash": Callable(self, "_flash_notice"), 
		"seat_look": Callable(self, "_seat_look"), 
		"free_devices": Callable(self, "_free_devices"), 
		"sync_guests": Callable(self, "_sync_local_guests"), 


		"on_leave": func(): _cfg_left_cd = 0.45, 
		"p1_switched": func():
			var s: = LocalPlayers.primary()
			s.profile = ProfileStore.active()
			_apply_outfit()
			_refresh_player_card()


			if _pc_avatar != null:
				_load_card_pfp.call_deferred(_pc_avatar), 
	}
	for i in LocalPlayers.MAX_LOCAL:
		var p: = CfgPanel.new()
		p.index = i
		p.menu_hooks = hooks
		_configs_row.add_child(p)
		_cfg_panels.append(p)

	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	v.add_child(foot)
	foot.add_child(_cfg_key_badge("Esc", Color(UiStyle.muted(), 0.22), UiStyle.text(), false))
	var slash: = Label.new()
	slash.text = "/"
	slash.add_theme_color_override("font_color", UiStyle.muted())
	foot.add_child(slash)
	foot.add_child(_cfg_key_badge("B", Color("e5484d"), Color.WHITE, true))
	var back_lbl: = Button.new()
	back_lbl.text = "back"
	UiStyle.style_button(back_lbl, "tertiary", 17)
	_slim_button(back_lbl)
	back_lbl.pressed.connect( func(): _show(_home))
	foot.add_child(back_lbl)
	var spring: = Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spring)


	if LaunchGate.public_beta():
		var beta: = Label.new()
		beta.text = "beta build - content nonfinal"
		UiStyle.style_label(beta, "small")
		beta.add_theme_color_override("font_color", Color(UiStyle.text(), 0.45))
		beta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		foot.add_child(beta)
		var spring_b: = Control.new()
		spring_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		foot.add_child(spring_b)


	_cfg_disconnect_all = Button.new()
	_cfg_disconnect_all.text = "disconnect all"
	UiStyle.style_button(_cfg_disconnect_all, "tertiary", 15)
	_slim_button(_cfg_disconnect_all)
	_cfg_disconnect_all.add_theme_color_override("font_color", Color("e5484d"))
	_cfg_disconnect_all.pressed.connect( func():
		LocalPlayers.reset_to_primary()
		UiStyle.sfx("close"))
	foot.add_child(_cfg_disconnect_all)
	var spring_dc: = Control.new()
	spring_dc.custom_minimum_size.x = 12
	foot.add_child(spring_dc)




	var done: = Button.new()
	done.text = "done"
	UiStyle.style_button(done, "primary", 20)
	done.custom_minimum_size = Vector2(160, 46)
	done.pressed.connect( func(): _show(_home))
	foot.add_child(done)




func _drive_local_sides(delta: float) -> void :
	if _local == null or not _local.visible:
		return
	for slot in LocalPlayers.slots:
		if slot.index == 0 or not slot.connected:
			continue
		var reader: DeviceInput = _side_polls.get(slot.device)
		if reader == null:
			reader = DeviceInput.new(slot.device)
			_side_polls[slot.device] = reader
		reader.device = slot.device
		reader.poll(["ui_left", "ui_right"])
		var want: = 0
		if reader.just_pressed("ui_left"):
			want = 1
		elif reader.just_pressed("ui_right"):
			want = -1
		if want != 0 and want != slot.team_side:
			slot.team_side = want
			UiStyle.sfx("tick")
			_refresh_local()







func _drive_room_sides(_delta: float) -> void :
	if _room == null or not _room.visible or not Net.active:
		return
	if not LocalPlayers.has_guests():
		return
	var my_peer: = Net.multiplayer.get_unique_id()
	var locs: Array = Net.locals_of(my_peer)
	for slot in LocalPlayers.slots:
		if slot.index == 0 or not slot.connected:
			continue
		var reader: DeviceInput = _side_polls.get(slot.device)
		if reader == null:
			reader = DeviceInput.new(slot.device)
			_side_polls[slot.device] = reader
		reader.device = slot.device
		reader.poll(["ui_left", "ui_right"])
		var want: = 0
		if reader.just_pressed("ui_left"):
			want = 1
		elif reader.just_pressed("ui_right"):
			want = -1
		if want == 0:
			continue
		var i: = slot.ls - 1
		var cur: = int((locs[i] as Dictionary).get("side", 0))\
		if i >= 0 and i < locs.size() else 0
		if want != cur:
			Net.pick_local_side(slot.ls, want)



			slot.team_side = want
			UiStyle.sfx("tick")




func _refresh_configs() -> void :
	if _cfg_panels.is_empty():
		return
	var lbl: = _configs.find_child("CountLabel", true, false) as Label
	if lbl != null:
		lbl.text = "local party · %d player%s" % [LocalPlayers.count(), 
			"" if LocalPlayers.count() == 1 else "s"]
	for i in LocalPlayers.MAX_LOCAL:
		_cfg_panels[i].bind(LocalPlayers.slots[i] if i < LocalPlayers.count() else null)
	if _cfg_disconnect_all != null:
		_cfg_disconnect_all.visible = LocalPlayers.count() > 1
	if LaunchGate.dev_args().has("--measure"):
		_measure_configs.call_deferred()




func _seat_look(slot: LocalPlayerSlot, outfit: = "gym") -> Dictionary:
	if slot == null:
		return {}
	var cfg: CharacterConfig = GameConfig.character if slot.index == 0\
	else (CharacterConfig.from_dict(slot.profile.character)\
	if (slot.profile != null and not slot.profile.character.is_empty())\
	else CharacterConfig.random())


	var fit: = CharacterConfig.outfit_fit(cfg, outfit)
	return {"cfg": fit[0], "kit": fit[1]}



func _set_configs_live(on: bool) -> void :
	for p in _cfg_panels:
		p.set_live(on)



func _drive_config_panels(delta: float) -> void :
	if _configs == null or not _configs.visible or _freeplay:
		return
	for p in _cfg_panels:
		p.tick(delta)

func _measure_configs() -> void :
	await get_tree().process_frame
	await get_tree().process_frame
	var panel: = _configs.find_child("Panel", true, false) as Control
	print("MEASURE holder=", _configs.size, " panel=", panel.size, 
		" row=", _configs_row.size, " col0=", _configs_row.get_child(0).size, 
		" col1=", _configs_row.get_child(1).size, 
		" viewport=", get_viewport().get_visible_rect().size)


func _cfg_label(text_in: String) -> Label:
	var l: = Label.new()
	l.text = text_in
	UiStyle.style_label(l, "small", UiStyle.muted())
	return l



func _cfg_glyph_badge(action: String, force_gamepad: = false) -> Control:
	var kind: = InputPrompts.Kind.GAMEPAD if (force_gamepad or InputPrompts.using_gamepad())\
	else InputPrompts.Kind.KBM
	var tex: = InputPrompts.glyph_on(action, kind, InputPrompts.active_style())
	if tex == null:
		var fallback: = {"ui_accept": "A", "ui_cancel": "B", "menu_start": "Start"}
		return _cfg_key_badge(String(fallback.get(action, "?")), 
			Color(UiStyle.muted(), 0.22), UiStyle.text(), action != "menu_start")
	var p: = PanelContainer.new()
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var b: = StyleBoxFlat.new()
	b.bg_color = Color("141a26") if UiStyle.dark else UiStyle.INK
	b.set_corner_radius_all(8)
	b.set_content_margin_all(4.0)
	p.add_theme_stylebox_override("panel", b)
	var g: = TextureRect.new()
	g.texture = tex
	g.custom_minimum_size = Vector2(24, 18)
	g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p.add_child(g)
	return p


func _cfg_key_badge(text_in: String, fill: Color, ink: Color, 
		circle: bool) -> Control:
	var p: = PanelContainer.new()
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var b: = StyleBoxFlat.new()
	b.bg_color = fill
	b.set_corner_radius_all(20 if circle else 7)
	b.content_margin_left = 12.0 if circle else 9.0
	b.content_margin_right = 12.0 if circle else 9.0
	b.content_margin_top = 4.0
	b.content_margin_bottom = 4.0
	p.add_theme_stylebox_override("panel", b)
	var l: = Label.new()
	l.text = text_in
	l.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", ink)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	return p

func _device_label(slot: LocalPlayerSlot) -> String:
	if slot.device == DeviceInput.KBM:
		return "keyboard & mouse"
	if slot.device >= 0:
		return "controller %d" % (slot.device + 1)
	return "keyboard & mouse" if not LocalPlayers.kbm_taken() else "controller"


func _free_devices(slot: LocalPlayerSlot) -> Array:
	var out: Array = []
	if not LocalPlayers.kbm_taken() or slot.device == DeviceInput.KBM:
		out.append(DeviceInput.KBM)
	for pad in Input.get_connected_joypads():
		var holder: = LocalPlayers.slot_for_device(pad)
		if holder == null or holder == slot:
			out.append(pad)
	return out

func _build_practice() -> void :
	var v: = _box(_practice)
	v.add_theme_constant_override("separation", 12)
	_hero_head(v, "practice")
	var fp_card: = _card_btn("target", "freeplay", 
		MenuCopy.sub("freeplay"), "primary", _try_freeplay)
	v.add_child(fp_card)


	var tut_card: = _card_btn("star", "tutorial", 
		"learn the basics of the game", "info", _try_tutorial)
	v.add_child(tut_card)
	_couch_gated.append(tut_card)
	_refresh_couch_gates()




	var book_here: = HowToPanel.available()
	var howto: = _card_btn("question", "how to play", 
		MenuCopy.sub("how_to_play") if book_here else HowToPanel.closed_text(), 
		"info" if book_here else "quiet", func(): _show(_howto))
	if not book_here:
		var hb: = howto.get_child(0) as Button
		hb.disabled = true
		hb.focus_mode = Control.FOCUS_NONE
		hb.mouse_default_cursor_shape = Control.CURSOR_ARROW
	v.add_child(howto)
	_back_row(v, func(): _show(_home))




func _build_drill_runtime() -> void :
	_drill_runner = DrillRunner.new()
	add_child(_drill_runner)
	_drill_runner.setup(player, ball)
	_drill_runner.progress_changed.connect( func(done: int, required: int):
		_drill_count.text = "%d / %d" % [done, required])
	_drill_runner.instruction_changed.connect( func(text: String):
		_drill_instruction.text = text)
	_drill_runner.completed.connect(_on_drill_completed)
	_drill_hud = PanelContainer.new()
	UiStyle.style_panel(_drill_hud, Color(UiStyle.card(), 0.96), UiStyle.RADIUS)
	_drill_hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_drill_hud.position = Vector2(32, 32)
	_drill_hud.custom_minimum_size = Vector2(390, 130)
	var hv: = VBoxContainer.new()
	hv.add_theme_constant_override("separation", 5)
	_drill_hud.add_child(hv)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	hv.add_child(head)
	_drill_title = Label.new()
	UiStyle.style_label(_drill_title, "title")
	_drill_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_drill_title)
	_drill_count = Label.new()
	UiStyle.style_label(_drill_count, "title")
	head.add_child(_drill_count)
	_drill_instruction = Label.new()
	UiStyle.style_label(_drill_instruction, "body")
	hv.add_child(_drill_instruction)


	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	hv.add_child(foot)
	_drill_timer = Label.new()
	UiStyle.style_label(_drill_timer, "title", UiStyle.muted())
	_drill_timer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_drill_timer)
	_drill_hud.visible = false
	ui.add_child(_drill_hud)
	_build_drill_info()
	_drill_runner.countdown_changed.connect( func(text: String):



		var number: = int(text) if text.is_valid_int() else 0
		if number > 0:
			hud.show_countdown(number)
		else:
			hud.hide_countdown())
	_drill_results = PanelContainer.new()
	UiStyle.style_panel(_drill_results, Color(UiStyle.card(), 0.98), UiStyle.RADIUS)
	_drill_results.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_drill_results.position = Vector2(-220, -150)
	_drill_results.custom_minimum_size = Vector2(440, 300)
	var rv: = VBoxContainer.new()
	rv.alignment = BoxContainer.ALIGNMENT_CENTER
	rv.add_theme_constant_override("separation", 12)
	_drill_results.add_child(rv)


	var badge: = PanelContainer.new()
	badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bb: = StyleBoxFlat.new()
	bb.bg_color = UiStyle.SUCCESS
	bb.set_corner_radius_all(20)
	bb.content_margin_left = 20.0
	bb.content_margin_right = 20.0
	bb.content_margin_top = 7.0
	bb.content_margin_bottom = 7.0
	badge.add_theme_stylebox_override("panel", bb)
	var complete: = Label.new()
	complete.text = "drill complete"
	complete.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	complete.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	complete.add_theme_font_size_override("font_size", 17)
	complete.add_theme_color_override("font_color", Color.WHITE)
	badge.add_child(complete)
	rv.add_child(badge)
	_drill_result_time = Label.new()
	_drill_result_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiStyle.style_label(_drill_result_time, "title")
	rv.add_child(_drill_result_time)
	var actions: = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 8)
	rv.add_child(actions)
	actions.add_child(_menu_btn("retry", "secondary", _retry_drill))
	actions.add_child(_menu_btn("drills", "secondary", _leave_drill))
	_drill_next = _menu_btn("finish", "primary", _next_drill)
	actions.add_child(_drill_next)
	_drill_results.visible = false
	ui.add_child(_drill_results)




func _build_drill_info() -> void :
	_drill_info = PanelContainer.new()
	UiStyle.style_panel(_drill_info, Color(UiStyle.card(), 0.96), UiStyle.RADIUS)
	_drill_info.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_drill_info.position = Vector2(-32 - 360, 32)
	_drill_info.custom_minimum_size = Vector2(360, 0)
	_drill_info_body = VBoxContainer.new()
	_drill_info_body.add_theme_constant_override("separation", 8)
	_drill_info.add_child(_drill_info_body)
	_drill_info.visible = false
	ui.add_child(_drill_info)
	if not InputPrompts.changed.is_connected(_refresh_drill_glyphs):
		InputPrompts.changed.connect(_refresh_drill_glyphs)




func _populate_drill_info(id: String) -> void :
	for c in _drill_info_body.get_children():
		c.queue_free()
	var entry: = DrillCatalog.entry(id)
	var inputs: Array = entry.get("inputs", [])
	if not inputs.is_empty():
		var head: = Label.new()
		head.text = "controls"
		UiStyle.style_label(head, "small")
		_drill_info_body.add_child(head)
		for pair in inputs:

			var action: = "aim" if String(pair[0]) == "@mouse" else String(pair[0])
			_drill_info_body.add_child(_drill_glyph_row(String(pair[1]), action))
	var note: = String(entry.get("info", ""))
	if note != "":
		if not inputs.is_empty():
			var sep: = HSeparator.new()
			_drill_info_body.add_child(sep)
		var info: = Label.new()
		info.text = note
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.custom_minimum_size.x = 320
		UiStyle.style_label(info, "body")
		_drill_info_body.add_child(info)




func _drill_glyph_row(verb: String, action: String) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var lbl: = Label.new()
	lbl.text = verb
	UiStyle.style_label(lbl, "body")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	if action == "move":
		row.add_child(_drill_move_cluster())
	else:
		row.add_child(_glyph_plate(InputPrompts.glyph(action)))
	return row



func _drill_move_cluster() -> Control:
	if InputPrompts.using_gamepad():
		return _glyph_plate(InputPrompts.glyph("move"))
	var col: = VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 3)
	var top: = HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(_glyph_plate(_kbm_key("w"), Vector2(24, 20)))
	col.add_child(top)
	var bot: = HBoxContainer.new()
	bot.alignment = BoxContainer.ALIGNMENT_CENTER
	bot.add_theme_constant_override("separation", 3)
	for k in ["a", "s", "d"]:
		bot.add_child(_glyph_plate(_kbm_key(k), Vector2(24, 20)))
	col.add_child(bot)
	return col

func _kbm_key(name: String) -> Texture2D:
	var path: = "res://game/ui_icon/Keyboard & Mouse/Default/keyboard_%s.png" % name
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


func _glyph_plate(tex: Texture2D, min_size: = Vector2(30, 24)) -> PanelContainer:
	var plate: = PanelContainer.new()
	var pb: = StyleBoxFlat.new()
	pb.bg_color = Color("141a26") if UiStyle.dark else UiStyle.INK
	pb.set_corner_radius_all(8)
	pb.set_content_margin_all(5.0)
	pb.border_color = Color(1, 1, 1, 0.08)
	pb.set_border_width_all(1)
	plate.add_theme_stylebox_override("panel", pb)
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var icon: = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = min_size
	icon.texture = tex
	plate.add_child(icon)
	return plate



func _refresh_drill_glyphs() -> void :
	if _drill_info != null and _drill_info.visible and _drill_active != "":
		_populate_drill_info(_drill_active)

func _start_drill(id: String) -> void :
	if DrillCatalog.entry(id).is_empty() or not bool(DrillCatalog.entry(id).get("available", false)):
		return
	_drill_active = id
	_drill_progress.record_attempt(id)


	if _drill_return_stage == "":
		_drill_return_stage = _freeplay_stage
		_swap_stage("void", false, false, true)
	_enter_freeplay()
	_ball_auto_until = 0
	hud.set_freeplay_controls(false)
	_fp_hint.text = "esc: leave drill     c: camera"
	_fp_hint.visible = true
	hud.set_serve_prompt("")
	_drill_title.text = String(DrillCatalog.entry(id).name)
	_populate_drill_info(id)
	_drill_info.visible = _drill_info_body.get_child_count() > 0


	_drill_hud.visible = false
	_drill_results.visible = false
	_ensure_drill_overlay(DrillCatalog.entry(id))
	_drill_runner.start(id)


func _ensure_drill_overlay(entry: Dictionary) -> void :
	if _drill_director != null and is_instance_valid(_drill_overlay):
		_drill_director.arm(entry)
		return
	_drill_overlay = TUTORIAL_OVERLAY.new()
	ui.add_child(_drill_overlay)
	ui.move_child(_drill_overlay, hud.get_index())
	_drill_director = DRILL_DIRECTOR.new()
	add_child(_drill_director)
	_drill_director.sfx = sfx
	_drill_director.setup(_drill_runner, _drill_overlay, entry)

func _teardown_drill_overlay() -> void :
	if _drill_director != null:
		_drill_director.teardown()
		_drill_director.queue_free()
		_drill_director = null
	_drill_overlay = null

func _retry_drill() -> void :
	_drill_progress.record_attempt(_drill_active)
	_drill_results.visible = false
	_drill_hud.visible = false
	_drill_info.visible = _drill_info_body.get_child_count() > 0
	_ensure_drill_overlay(DrillCatalog.entry(_drill_active))
	camera_rig.apply_mouse_mode()
	_drill_runner.retry()

func _on_drill_completed(id: String, elapsed_ms: int) -> void :
	if _tutorial != null:
		return
	_drill_progress.record_complete(id, elapsed_ms)


	Achievements.notify("drill", {"id": id})
	_drill_hud.visible = false
	_drill_info.visible = false
	if _drill_director != null:
		_drill_director.hide()
	hud.hide_countdown()
	_drill_result_time.text = "%s\ntime %s" % [String(DrillCatalog.entry(id).name), 
		_drill_time(elapsed_ms)]


	if _guided:
		_drill_next.text = "next" if _guided_after(id) != "" else "play a rally!"
	else:
		var next: = DrillCatalog.next_available(id)
		_drill_next.text = "next" if next != "" else "finish"
	_drill_results.visible = true



	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameConfig.use_cursor(false)
	player.clear_action_state()

func _next_drill() -> void :
	if _guided:
		var nx: = _guided_after(_drill_active)
		if nx == "":
			_finish_tutorial()
		else:
			_start_drill(nx)
		return
	var next: = DrillCatalog.next_available(_drill_active)
	if next == "":
		_leave_drill()
	else:
		_start_drill(next)




func _offer_tutorial(preview: = false) -> void :
	if not is_inside_tree():
		return


	if LocalPlayers.has_guests():
		return
	if not preview:
		if GameConfig.tutorial_seen:
			return


		GameConfig.tutorial_seen = true
		GameConfig.save_settings()
	UiStyle.confirm(self, "welcome to voloball!", 
		"if it's your first time playing, it's heavily recommended that you learn properly first!", 
		func(): _start_tutorial(), 
		"learn the basics", "don't need to!", "primary")






var _couch_gated: Array[Control] = []
var _couch_notice_at: = -99999

func _couch_blocks(what: String) -> bool:
	if not LocalPlayers.has_guests():
		return false
	var now: = Time.get_ticks_msec()
	if now - _couch_notice_at > 1500:
		_couch_notice_at = now
		_flash_notice("disconnect local players to play %s" % what)
	return true

func _try_freeplay() -> void :







	if _practice_court != null and _practice_court.running()\
	and not (_practice_solo and Net.party and Net.active):
		_enter_practice()
		return
	if Net.party and Net.active:
		_practice_enter_on_start = true
		if Net.is_host:
			_court_now(_launch_party_practice)
		elif Net.practice:
			Net.send_up("jprac", {})
		else:
			_flash_notice("waiting for the party's practice court")
		return
	if Net.active:

		if _couch_blocks("freeplay"):
			return
		_enter_freeplay()
		return
	_court_now(_start_solo_practice)



func _start_solo_practice(enter: = true) -> void :
	if MobileRender.enabled():
		_enter_freeplay()
		_spawn_practice_ball()
		return
	_practice_solo = true
	_keep_menu_config()
	Net.practice = true
	PracticeMode.apply_court_size(PracticeMode.solo_size)
	GameConfig.stage = _freeplay_stage
	GameConfig.net_roster = []
	GameConfig.quick_match = false
	_practice_enter_on_start = enter
	_embed_practice()
	Net.practice = false





func _court_now(fn: Callable) -> void :
	fn.call()




var _join_cover: LoadingScreen = null

func _with_loading(fn: Callable) -> void :
	if not BootLoader.enabled() or BootLoader.running or not is_inside_tree()\
	or _join_cover != null:
		fn.call()
		return
	_join_cover = LoadingScreen.new()
	get_tree().root.add_child(_join_cover)
	await get_tree().create_timer(LoadingScreen.FADE_IN).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	if is_inside_tree():
		fn.call()
		await get_tree().process_frame
	var ls: = _join_cover
	_join_cover = null
	if is_instance_valid(ls):
		ls.fade_out( func(): ls.queue_free())









const MOVE_COVER_MAX: = 40.0
var _move_cover: LoadingScreen = null
var _move_cover_t: = 0.0
var _move_cover_away: = false

func _raise_move_cover() -> void :
	if _move_cover != null or not is_inside_tree() or Net.in_match:
		return
	QuickPlay.qlog("match found: the party moves under the loading screen")
	_move_cover = LoadingScreen.new()


	_move_cover.show_now()
	get_tree().root.add_child(_move_cover)
	_move_cover_t = 0.0
	_move_cover_away = false

func _drop_move_cover(why: String) -> void :
	if _move_cover == null:
		return
	QuickPlay.qlog("move cover down: %s" % why)
	var ls: = _move_cover
	_move_cover = null
	if is_instance_valid(ls):
		ls.fade_out( func(): ls.queue_free())




func _tick_move_cover(delta: float) -> void :
	if _move_cover == null:
		return
	if not is_instance_valid(_move_cover):
		_move_cover = null
		return
	_move_cover_t += delta
	if not Net.party:
		_move_cover_away = true
	if Net.in_match:
		return
	if _qp != null and _qp.state == QuickPlay.State.REGROUPING:
		_drop_move_cover("the move fell through, the party is coming home")
	elif _move_cover_away and Net.party and Net.active:
		_drop_move_cover("the party is home again")
	elif _move_cover_t >= MOVE_COVER_MAX:
		_drop_move_cover("no match after %.0fs" % _move_cover_t)



func boot_build_court() -> void :
	if _practice_court != null and _practice_court.running():
		return
	if not Net.active:


		if _party_reforming():
			return
		_start_solo_practice(false)
	elif Net.party and Net.is_host and not Net.in_match and not Net.practice_live:
		_launch_party_practice()






func boot_party_pending() -> bool:
	if Net.in_match:
		return false
	if _party_reforming():
		return true
	if Net.party and Net.active and not Net.is_host and Net.practice\
	and (_practice_court == null or not _practice_court.running() or _practice_solo):
		return true
	return Net.party and Net.is_host and not _home_notice.is_empty()\
	and Time.get_ticks_msec() < int(_home_notice.get("until", 0))\
	and Net.party_members().size() < int(_home_notice.get("count", 0))


func boot_revealed() -> void :
	if _last_shown != null and is_instance_valid(_last_shown):
		_stagger_reveal(_last_shown)





const _PARK_FOR: = ["res://game/character/locker.tscn", 
	"res://game/character/locker_split_host.tscn", "res://game/shop/shop.tscn", 
	"res://game/replay/replay_viewer.tscn", "res://game/ui/menu.tscn"]

func before_scene_change(path: String) -> void :
	if _practice_court == null or not _practice_court.running() or not _PARK_FOR.has(path):
		return
	if _practice_on:
		_leave_practice()
	PracticeCourt.park(_practice_layer, _practice_solo)
	_practice_court = null
	_practice_layer = null

func _adopt_parked_court() -> void :
	var solo: = PracticeCourt.parked_solo
	var layer: = PracticeCourt.unpark()
	if layer == null:
		return
	add_child(layer)
	for c in layer.get_children():
		if c is PracticeCourt:
			_practice_court = c
	if _practice_court == null or not _practice_court.running():
		_practice_court = null
		layer.queue_free()
		return
	_practice_layer = layer
	_practice_solo = solo
	_practice_court.closed.connect(_on_practice_closed)
	_practice_court.request_menu.connect(_leave_practice)
	_practice_court.rebuild_wanted.connect(_rebuild_court)




	var pm = _practice_court.main.get("_practice")
	if pm != null:
		pm.redress_self(_outfit)


	if Net.party and Net.practice and Net.stage != _freeplay_stage\
	and Stage.in_build(Net.stage):
		_swap_stage.call_deferred(Net.stage, false, false)



func _embed_practice() -> void :
	if _practice_court == null:
		_practice_layer = CanvasLayer.new()
		_practice_layer.layer = 0
		add_child(_practice_layer)
		_practice_court = PracticeCourt.new()
		_practice_layer.add_child(_practice_court)
		_practice_court.closed.connect(_on_practice_closed)
		_practice_court.request_menu.connect(_leave_practice)
		_practice_court.rebuild_wanted.connect(_rebuild_court)
	_practice_court.pause_when_idle = _practice_solo
	_practice_court.start()
	_restore_menu_config()
	if _practice_enter_on_start:
		_practice_enter_on_start = false
		_enter_practice()

func _set_menu_chrome(on: bool) -> void :
	_root.visible = on
	_top_panel.visible = on
	_bottom_panel.visible = on
	_top_strip.visible = on
	_bottom_strip.visible = on
	_logo_rect.visible = on
	if _pc_avatar != null:
		_pc_avatar.visible = on
	if not on:
		if _friends_panel != null:
			_friends_panel.visible = false
		if _friends_scrim != null:
			_friends_scrim.visible = false

	if on and _member_queuing:
		_set_matchmaking(true)

	_mm_chip.visible = not on and (_member_queuing\
	or (_qp != null and _qp.state != QuickPlay.State.IDLE))


func _enter_practice() -> void :
	if _practice_on or _practice_court == null or not _practice_court.running():
		return
	_practice_on = true
	GameConfig.menu_practice = true
	ui.get_viewport().gui_release_focus()
	_input_collector.swallow_held(["jump", "contact", "serve", "dive", "set", "ball_spawn"])
	_set_menu_chrome(false)
	if _chat != null:
		_chat.suppressed = true
	get_viewport().disable_3d = true
	_practice_court.set_active(true)


	GameConfig.root_ui_aa = false
	GameConfig.apply_msaa()
	_update_presence()


func _leave_practice() -> void :
	if not _practice_on:
		return
	_practice_on = false
	GameConfig.menu_practice = false


	_modal_closed()
	if _practice_court != null:
		_practice_court.set_active(false)
	if _chat != null:
		_chat.suppressed = false
	get_viewport().disable_3d = false
	GameConfig.root_ui_aa = true
	GameConfig.apply_msaa()
	_set_menu_chrome(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	call_deferred("_focus_current_page")
	_update_presence()



var _menu_cfg_keep: Array = []

const _KEPT_CONFIG: = ["team_size", "court_half_width", "court_half_length", "stage", 
	"quick_match", "set_points", "sets_to_win", "win_by_two", "sweat_enabled", 
	"sweat_rate", "instant_replays", "team_collision", "serve_seconds", "ball_hints", 
	"lock_teams", "rotate_every_point", "match_intro", "time_of_day", "outfit_rule"]

func _keep_menu_config() -> void :
	_menu_cfg_keep = _KEPT_CONFIG.map( func(k): return GameConfig.get(k))

func _restore_menu_config() -> void :
	if _menu_cfg_keep.is_empty():
		return
	for i in _KEPT_CONFIG.size():
		GameConfig.set(_KEPT_CONFIG[i], _menu_cfg_keep[i])
	_menu_cfg_keep = []



func _stop_practice(end_session: = true) -> void :
	var keep_enter: = _practice_enter_on_start
	if _practice_on:
		_leave_practice()
	_practice_enter_on_start = keep_enter
	if _practice_court != null:
		if _practice_court.running():
			GameConfig.net_roster = []
			if end_session and not _practice_solo and Net.active:
				Net.end_practice()
		_practice_court.stop()
	if _practice_solo:
		_practice_solo = false
		_menu_idle_t = 0.0
	elif not Net.active:
		Net.practice = false


func _on_practice_closed(_reason: String) -> void :
	_stop_practice()



func _tick_practice(delta: float) -> void :
	_menu_idle_t += delta
	_practice_check_t -= delta
	if _practice_check_t > 0.0:
		return
	_practice_check_t = 1.0
	var running: = _practice_court != null and _practice_court.running()



	if running and _practice_solo and Net.active and not PracticeCourt.solo_outlives_session():


		var was_on: = _practice_on
		_stop_practice()
		if was_on and Net.party:
			_practice_enter_on_start = true
		return



	if not running and not Net.active and _practice_prewarm\
	and _menu_idle_t >= PRACTICE_PREWARM_IDLE\
	and PracticeCourt.scene_ready()\
	and not _freeplay and _drill_active == "" and not _modal_up():
		_court_now( func():
			if not Net.active and (_practice_court == null or not _practice_court.running()):
				_start_solo_practice(false))
		return
	if Net.party and Net.active and not Net.in_match:
		if Net.is_host and not Net.practice_live and not running:
			_court_now( func():
				if Net.party and Net.is_host and not Net.practice_live and not Net.in_match:
					_launch_party_practice())
		elif not Net.is_host and Net.practice and not running:
			Net.send_up("jprac", {})
	elif running and not _practice_solo:
		_stop_practice()







func _launch_party_practice() -> void :
	var keep_size: = Net.team_size
	var keep_intro: = Net.rule_intro
	var keep_replays: = Net.rule_replays
	var keep_sides: = {}
	for id in Net.players:
		keep_sides[id] = int(Net.players[id].side)
	Net.set_team_size(Net.PRACTICE_SIZE)
	for id in Net.party_members():
		Net.players[id].side = 1
	var ids: = Net.players.keys()
	ids.sort()
	var roster: = Net.match_roster(ids, Net.players, Net.PRACTICE_SIZE, 
		GameConfig.local_cpus, Net.captains)

	for e in roster:
		var pid: = int((e as Dictionary).get("peer", 0))
		if pid != 0:
			e["outfit"] = _outfit if pid == _my_party_id()\
			else String((Net.players.get(pid, {}) as Dictionary).get("outfit", "gym"))
	GameConfig.ranked_match = false
	Net.rule_intro = false
	Net.rule_replays = false
	Net.practice = true
	Net.stage = _freeplay_stage
	Net.sync_lobby()
	Net.start_match(roster, randi(), true)

	for id in keep_sides:
		if Net.players.has(id):
			Net.players[id].side = keep_sides[id]
	Net.rule_intro = keep_intro
	Net.rule_replays = keep_replays
	Net.set_team_size(keep_size)

func _try_tutorial() -> void :
	if _couch_blocks("the tutorial"):
		return
	_start_tutorial()




func _refresh_couch_gates() -> void :
	var shut: = LocalPlayers.has_guests()
	for c in _couch_gated:
		if is_instance_valid(c):
			_couch_veil(c).visible = shut

func _couch_veil(c: Control) -> Panel:

	var b: Control = c if c is Button else c.get_child(0) as Control
	if b.has_meta("couch_veil"):
		return b.get_meta("couch_veil") as Panel
	var radius: = UiStyle.CAPSULE
	var sb: = b.get_theme_stylebox("normal") as StyleBoxFlat
	if sb != null:
		radius = sb.corner_radius_top_left
	var veil: = Panel.new()
	veil.name = "CouchVeil"
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.add_theme_stylebox_override("panel", 
		UiStyle.flat_box(Color(UiStyle.card(), 0.66), radius))
	veil.visible = false
	b.add_child(veil)
	b.set_meta("couch_veil", veil)
	return veil

func _start_tutorial() -> void :
	_guided = true


	if _drill_return_stage == "":
		_drill_return_stage = _freeplay_stage
		_swap_stage("void", false, false, true)
	_drill_active = "tutorial"
	_enter_freeplay()

	DrillObjective.practice_dress = true
	player.set_character(GameConfig.character.gym_look(), GameConfig.character.gym_kit())
	MusicManager.play("gym")
	_fp_hint.visible = false
	hud.set_serve_prompt("")
	_drill_hud.visible = false
	_drill_info.visible = false
	_drill_results.visible = false
	player.clear_action_state()
	player.global_position = Vector3(0.0, 0.0, 6.0)
	player.team_side = 1
	player.face_net()
	player.reset_physics_interpolation()
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.global_position = Vector3(0.0, -4.0, 0.0)
	var overlay: Control = TUTORIAL_OVERLAY.new()
	ui.add_child(overlay)

	ui.move_child(overlay, hud.get_index())
	_tutorial = TUTORIAL_DIRECTOR.new()
	add_child(_tutorial)
	_tutorial.setup(_drill_runner, overlay, _tutorial_section)
	_tutorial.cam_rig = camera_rig
	_drill_runner.cam_rig = camera_rig
	_tutorial.control_hud = hud.get_node_or_null("Controls")
	_tutorial.sfx = sfx
	_tutorial.finished.connect(_finish_tutorial)

	hud.pause_enabled = true
	(hud.get_node("PauseMenu") as PauseMenu).leave_override = _leave_drill


	(hud.get_node("PauseMenu") as PauseMenu).set_tutorial_skip( func():
		if _tutorial != null:
			_tutorial.skip_to_end())
	if not hud.pause_opened.is_connected(_on_tutorial_pause_opened):
		hud.pause_opened.connect(_on_tutorial_pause_opened)
		hud.pause_closed.connect(_on_tutorial_pause_closed)
	_tutorial.begin()



func _tutorial_section(objective_id: String) -> void :
	_drill_active = objective_id
	_drill_runner.start(objective_id, true)




func _on_tutorial_pause_opened() -> void :
	camera_rig.input_frozen = true
	_input_collector.swallow_held(["jump", "contact", "dive", "serve", "set", "ball_spawn"])
	_input_collector.clear_buffers()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_tutorial_pause_closed() -> void :


	camera_rig.input_frozen = _tutorial != null and _tutorial.blocking_input()
	_input_collector.swallow_held(["jump", "contact", "dive", "serve", "set", "ball_spawn"])
	_input_collector.clear_buffers()
	if _tutorial != null:
		camera_rig.apply_mouse_mode(false)

func _teardown_tutorial(back_to_menu: = true) -> void :
	if _tutorial == null:
		return
	_tutorial.teardown()
	_tutorial.queue_free()
	_tutorial = null
	hud.pause_enabled = false
	(hud.get_node("PauseMenu") as PauseMenu).leave_override = Callable()
	(hud.get_node("PauseMenu") as PauseMenu).set_tutorial_skip(Callable())
	if hud.pause_opened.is_connected(_on_tutorial_pause_opened):
		hud.pause_opened.disconnect(_on_tutorial_pause_opened)
		hud.pause_closed.disconnect(_on_tutorial_pause_closed)
	DrillObjective.practice_dress = false
	_apply_outfit()
	if back_to_menu:
		MusicManager.play("menu")


func _guided_after(id: String) -> String:
	var i: = GUIDED_PATH.find(id)
	if i == -1 or i + 1 >= GUIDED_PATH.size():
		return ""
	return String(GUIDED_PATH[i + 1])

func _finish_tutorial() -> void :
	_guided = false


	if _tutorial != null and not bool(_tutorial.get("skipped")):
		Achievements.notify("tutorial")
	_teardown_tutorial(false)



	if _drill_runner != null:
		_drill_runner.cancel()
	_drill_hud.visible = false
	_drill_info.visible = false
	_drill_results.visible = false
	_drill_active = ""
	_exit_freeplay()
	if _drill_return_stage != "":
		_drill_return_stage = ""


	GameConfig.pre_tutorial_settings = {
		"stage": GameConfig.stage, "difficulty": GameConfig.difficulty, 
		"team_size": GameConfig.team_size, "set_points": GameConfig.set_points, 
		"sets_to_win": GameConfig.sets_to_win, "win_by_two": GameConfig.win_by_two, 
		"local_side": GameConfig.local_side, 
	}
	GameConfig.set_points = 4
	GameConfig.sets_to_win = 1
	GameConfig.win_by_two = false
	GameConfig.difficulty = 0
	CpuSlots.set_all_diff(GameConfig.local_cpus, 0)
	GameConfig.simple_bot_serves = true
	GameConfig.tutorial_finale = true
	GameConfig.local_side = 1
	GameConfig.quick_match = false
	GameConfig.stage = Stage.resolve("practice")
	_go_to_match(2)

func _leave_drill() -> void :
	_teardown_tutorial()
	_teardown_drill_overlay()
	if _drill_runner != null:
		_drill_runner.cancel()
	_drill_hud.visible = false
	_drill_info.visible = false
	hud.hide_countdown()
	_drill_results.visible = false
	_drill_active = ""
	_exit_freeplay()
	if _drill_return_stage != "":
		var back: = _drill_return_stage
		_drill_return_stage = ""
		_swap_stage(back, false, false, true)


	if _guided:
		_guided = false
		_show(_home)
	else:
		_show(_practice)

func _drill_time(ms: int) -> String:
	return "%d:%02d.%02d" % [int(ms / 60000), int(ms / 1000) % 60, 
		int((ms % 1000) / 10)]






const CAREER_PAGE: = "res://game/ui/career_page.gd"
const AWARDS_PAGE: = "res://game/ui/awards_page.gd"

static func _page_script(path: String) -> Script:
	return load(path) as Script if ResourceLoader.exists(path) else null

func _build_career() -> void :
	var script: = _page_script(CAREER_PAGE)
	if script == null:
		return
	var cp: Control = script.new()
	cp.name = "CareerPage"
	cp.custom_minimum_size = Vector2(560, 460)
	_box(_career).add_child(cp)


func _shot_seed_titles() -> void :
	var prof: = ProfileStore.active()
	if prof == null:
		return
	for id in ["the_ace", "fly", "gym_rat", "court_king", "unpredictable", "nice_serve", "yapper", "cute", "tmko", 
			"nah_id_win", "last_boss", "goat", "kitty", "mad_dog", "game_over"]:
		prof.owned[TITLES.own_key(id)] = true

	if "--title-all" in LaunchGate.dev_args():
		for t in TITLES.all():
			prof.owned[TITLES.own_key(t.id)] = true

	var all_fx: = "--title-fx-all" in LaunchGate.dev_args()
	for fx in TITLES.effects():
		if all_fx or fx.id in ["water", "lava", "cutesy", "pixel", "typewriter", "polka", "rainbow"]:
			prof.owned[TITLES.fx_key(fx.id)] = true
	prof.title = {"id": "court_king", "cs": 1, "fg": "ffffff", "bg": "2e78ff", "ol": "17306b", "th": 3, "fx": "water"}
	TITLES.stamp(GameConfig.character)



func _shot_seed_career() -> void :
	var prof: = ProfileStore.active()
	if prof == null:
		return
	var base: = Net.local_character_dict()


	var hairs: = ["3a2a1a", "8a3b1b", "c9a24a", "2a2a2a", "5a2a6a", "b05a2a"]
	var skins: = [0, 1, 2, 0, 1, 2]
	var mk: = func(stage: String, mode: String, won: bool, hs: int, as_: int, 
			online: bool, ago: int) -> Dictionary:
		var players: Array = []
		var names: = ["you", "rin", "kaz", "mei", "sol", "juno"]
		for i in 6:
			var cfg: Dictionary = base.duplicate(true)
			cfg["hcol"] = hairs[i]
			cfg["skin"] = skins[i]
			players.append({"name": names[i], "ready_name": names[i], 
				"sid": "0", "side": 1 if i < 3 else -1, "cfg": cfg, 
				"pts": 18 - i * 2, "spk": 12 - i, "blk": 3, "rcv": 6 + i, 
				"set": i, "ast": 2})
		return {"ts": int(Time.get_unix_time_from_system()) - ago, 
			"stage": stage, "mode": mode, "online": online, "won": won, 
			"my_name": "you", "home_score": 25, "away_score": 20, 
			"home_sets": hs, "away_sets": as_, "replay": "", "players": players}
	var stages: = ["nationals", "beach", "school", "outer_space", "grass", "clouds"]
	var modes: = ["1v1", "2v2", "3v3", "4v4"]
	prof.match_history = []
	for i in 14:
		prof.match_history.append(mk.call(stages[i % stages.size()], 
			modes[i % modes.size()], i % 3 != 0, 2, i % 3, i % 2 == 0, 600 + i * 40000))

func _build_profile() -> void :
	var v: = _box(_profile)
	_hero_head(v, "profile", true)
	var prof: = ProfileStore.active()



	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(340, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	var body: = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)


	var body_pad: = MarginContainer.new()
	body_pad.add_theme_constant_override("margin_right", 18)
	body_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_pad.add_child(body)
	scroll.add_child(body_pad)




	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	var av: = PanelContainer.new()
	UiStyle.style_panel(av, UiStyle.bg(), UiStyle.RADIUS)
	av.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pfp: = TextureRect.new()
	pfp.custom_minimum_size = Vector2(96, 96)
	pfp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pfp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	av.add_child(pfp)
	header.add_child(av)
	_profile_pfp = pfp
	_load_profile_pfp.call_deferred(pfp)


	var idcol: = VBoxContainer.new()
	idcol.add_theme_constant_override("separation", 5)
	idcol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var name_l: = Label.new()



	name_l.text = prof.name if prof != null else Net.local_display_name()
	UiStyle.style_label(name_l, "title")
	idcol.add_child(name_l)
	var prog: = HBoxContainer.new()
	prog.add_theme_constant_override("separation", 16)
	var lvl: = Label.new()
	lvl.text = "lv. %d" % (prof.level if prof != null else 1)
	UiStyle.style_label(lvl, "body", UiStyle.muted())
	prog.add_child(lvl)
	var coinrow: = HBoxContainer.new()
	coinrow.add_theme_constant_override("separation", 6)
	coinrow.add_child(_coin_disc(18))
	var coins_l: = Label.new()
	coins_l.text = _comma(prof.coins if prof != null else 0)
	UiStyle.style_label(coins_l, "body")
	coinrow.add_child(coins_l)
	prog.add_child(coinrow)
	idcol.add_child(prog)

	if LaunchGate.economy_off():
		prog.visible = false



	if TITLES.usable():
		var trow: = HBoxContainer.new()
		trow.name = "TitleRow"
		trow.add_theme_constant_override("separation", 10)
		var worn: Dictionary = TITLES.equipped()
		if worn.is_empty():
			var none: = Label.new()
			none.text = "no title"
			UiStyle.style_label(none, "small", UiStyle.muted())
			none.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			trow.add_child(none)
		else:
			var chip: = TITLE_CHIP.new()
			chip.name = "WornTitle"
			chip.show_style(worn, 14)
			chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			trow.add_child(chip)
		var edit_b: = Button.new()
		edit_b.name = "EditTitle"
		edit_b.text = "edit title"
		UiStyle.style_button(edit_b, "secondary", 13)
		edit_b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		edit_b.pressed.connect(_open_title_editor)
		trow.add_child(edit_b)
		idcol.add_child(trow)
	header.add_child(idcol)




	var spring: = Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spring)
	var prof_settings: = UiStyle.icon_button("wrench", "secondary", 40)
	prof_settings.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prof_settings.tooltip_text = "profile settings"
	prof_settings.pressed.connect( func(): _open_settings(SettingsPanel.Scope.PROFILE))
	header.add_child(prof_settings)
	body.add_child(header)
	_build_profile_hub(body, prof)
	var m: = int(Career.data.get("matches", 0))
	var rows: = [
		["matches", str(m)], 
		["wins", str(int(Career.data.get("wins", 0)))], 
		["losses", str(m - int(Career.data.get("wins", 0)))], 
		["winrate", "%d%%" % int(roundf(Career.winrate() * 100.0))], 
		["points", str(int(Career.data.get("points", 0)))], 
		["spikes", str(int(Career.data.get("spikes", 0)))], 
		["blocks", str(int(Career.data.get("blocks", 0)))], 
		["receives", str(int(Career.data.get("receives", 0)))], 
		["sets", str(int(Career.data.get("sets", 0)))], 
		["assists", str(int(Career.data.get("assists", 0)))], 
		["playtime", "%.1f h" % (float(Career.data.get("playtime", 0.0))
			/ 3600.0)], 
	]


	if not LaunchGate.public_beta():
		for pair in [["jumps", "jumps"], ["bam jumps", "bam_jumps"], ["dive receives", "dive_receives"], 
				["aces", "aces"], ["quick chats", "quick_chats"], ["collisions", "collisions"], 
				["net crashes", "net_crashes"]]:
			rows.append([pair[0], str(int(Career.data.get(pair[1], 0)))])

	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 26)
	grid.add_theme_constant_override("v_separation", 7)
	for r in rows:
		var cell: = HBoxContainer.new()
		cell.custom_minimum_size.x = 195
		var k: = Label.new()
		k.text = r[0]
		UiStyle.style_label(k, "small")
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_child(k)
		var val: = Label.new()
		val.text = r[1]
		UiStyle.style_label(val, "body")
		cell.add_child(val)
		grid.add_child(cell)
	body.add_child(grid)
	v.add_child(scroll)



	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	var back_b: = _back_btn(_back_to_hub)
	bottom.add_child(back_b)
	var push: = Control.new()
	push.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(push)
	if not ProfileStore.recently_deleted.is_empty():
		var recent_b: = Button.new()
		recent_b.text = "recently deleted (%d)" % ProfileStore.recently_deleted.size()
		UiStyle.style_button(recent_b, "secondary", 14)
		recent_b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		recent_b.pressed.connect( func(): _show(_recent))
		bottom.add_child(recent_b)
	v.add_child(bottom)




func _build_profile_hub(v: VBoxContainer, prof: SavedProfile) -> void :
	if prof == null:
		return

	var srow: = HBoxContainer.new()
	srow.add_theme_constant_override("separation", 10)
	var names: Array = []
	for p in ProfileStore.profiles:
		names.append(p.name)
	var picker: = UiSelect.new(names)
	picker.selected = ProfileStore.active_index
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.picked.connect( func(idx: int):
		ProfileStore.switch_to(idx)
		_refresh_profile())
	srow.add_child(picker)
	var new_b: = Button.new()
	new_b.text = "new"
	UiStyle.style_button(new_b, "secondary", 16)
	new_b.disabled = ProfileStore.profiles.size() >= ProfileStore.PROFILE_MAX
	new_b.pressed.connect( func():
		if ProfileStore.create_profile("Profile %d"
				%(ProfileStore.profiles.size() + 1)) != null:
			ProfileStore.switch_to(ProfileStore.profiles.size() - 1)
		_refresh_profile())
	srow.add_child(new_b)
	v.add_child(srow)

	var rrow: = HBoxContainer.new()
	rrow.add_theme_constant_override("separation", 10)
	var rename_edit: = LineEdit.new()
	rename_edit.text = prof.name
	rename_edit.max_length = SavedProfile.NAME_MAX
	rename_edit.placeholder_text = "name"
	rename_edit.custom_minimum_size = Vector2(180, 44)
	rename_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_line_edit(rename_edit)
	var do_rename: = func():
		ProfileStore.rename_profile(ProfileStore.active_index, rename_edit.text)
		_refresh_profile()
	rename_edit.text_submitted.connect( func(_t: String): do_rename.call())
	rrow.add_child(rename_edit)
	var rename_b: = Button.new()
	rename_b.text = "rename"
	UiStyle.style_button(rename_b, "secondary", 16)
	rename_b.pressed.connect(do_rename)
	rrow.add_child(rename_b)
	var del_b: = Button.new()
	del_b.text = "delete"
	UiStyle.style_button(del_b, "tertiary", 16)

	del_b.disabled = ProfileStore.profiles.size() <= 1 or ProfileStore.active_index == 0
	del_b.pressed.connect( func():
		var nm: String = prof.name

		UiStyle.confirm(self, "delete %s?" % nm, 
			"this profile will be moved into recently deleted and is recoverable", 
			func():
				ProfileStore.delete_profile(ProfileStore.active_index)


				_refresh_recent(), 
			"delete", "cancel", "exit", 5.0)
	)
	rrow.add_child(del_b)
	v.add_child(rrow)








func _build_achievements() -> void :
	var v: = _box(_achievements)
	var script: = _page_script(AWARDS_PAGE)
	if script != null:
		_awards = script.new()
		_awards.name = "AwardsPage"
		_awards.connect("chips_claimed", _fly_chips)
		v.add_child(_awards)
	_back_row(v, _back_to_hub)

func _show_achievements() -> void :
	if is_instance_valid(_awards):
		_awards.call("open")
	_show(_achievements)



func _shot_seed_awards() -> void :
	Achievements.notify("match_end", {"won": true})
	for i in 4:
		Achievements.notify("match_end", {"won": false})
	for i in 37:
		Achievements.notify("jump", {"bam": i == 0})
	for i in 3:
		Achievements.notify("point", {"mine": true, "kind": "spike", "quick": i == 0})
	for i in 2:
		Achievements.notify("block", {"shifted": i == 0})
	Achievements.notify("avatar", {"changed": true, "tallest": true})

	Achievements.notify("match_stats", {"spk": 212, "rcv": 340, "blk": 57})
	for s in ["grass", "beach", "nationals"]:
		Achievements.notify("match_end", {"won": true, "stage": s})
	Achievements.claim(Achievements.def_of("eat_and_grow_stronger"))
	Achievements.claim(Achievements.def_of("d_avatar"))
	_refresh_player_card()



func _refresh_awards_badge() -> void :
	if not is_instance_valid(_awards_tab):
		return
	var n: = Achievements.claimable_count()
	if "--badge-demo" in LaunchGate.dev_args():
		n = 3
	if n <= 0:
		if is_instance_valid(_awards_badge):
			_awards_badge.queue_free()
			_awards_badge = null
		return
	if not is_instance_valid(_awards_badge):
		var b: = Label.new()
		b.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", Color.WHITE)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var sb: = StyleBoxFlat.new()
		sb.bg_color = UiStyle.RED
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		b.add_theme_stylebox_override("normal", sb)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.z_index = 2
		_awards_tab.add_child(b)
		_awards_badge = b
	_awards_badge.text = str(n) if n < 100 else "99+"
	_awards_badge.custom_minimum_size = Vector2(20, 20)
	_place_awards_badge.call_deferred()

func _place_awards_badge() -> void :
	if not is_instance_valid(_awards_badge) or not is_instance_valid(_awards_tab):
		return
	_awards_badge.reset_size()
	_awards_badge.position = Vector2(_awards_tab.size.x - _awards_badge.size.x + 6, -6)

func _refresh_profile() -> void :
	_rebuild_profile.call_deferred()

func _rebuild_profile() -> void :
	if not is_instance_valid(_profile):
		return
	var v: = _box(_profile)
	if v == null:
		return
	for c in v.get_children():
		v.remove_child(c)
		c.queue_free()
	_build_profile()



	if player != null and GameConfig.character != null:
		_apply_outfit()
		_broadcast_menu_look()
	if _profile_pfp != null:
		_load_profile_pfp.call_deferred(_profile_pfp)


	_refresh_player_card()
	if _pc_avatar != null:
		_load_card_pfp.call_deferred(_pc_avatar)
	_focus_current_page.call_deferred()



func _build_recent() -> void :
	var v: = _box(_recent)
	_hero_head(v, "recently deleted", true)
	if ProfileStore.recently_deleted.is_empty():
		var empty: = Label.new()
		empty.text = "no profiles"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.custom_minimum_size.x = 320
		UiStyle.style_label(empty, "small")
		v.add_child(empty)
	else:
		var full: = ProfileStore.profiles.size() >= ProfileStore.PROFILE_MAX
		for i in ProfileStore.recently_deleted.size():
			var p: SavedProfile = ProfileStore.recently_deleted[i]
			var idx: = i
			var row: = HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			var nm: = Label.new()
			nm.text = p.name
			UiStyle.style_label(nm, "body")
			nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(nm)
			var restore_b: = Button.new()
			restore_b.text = "restore"
			UiStyle.style_button(restore_b, "secondary", 16)
			restore_b.disabled = full
			restore_b.pressed.connect( func():
				ProfileStore.restore_profile(idx)
				_refresh_recent())
			row.add_child(restore_b)
			var purge_b: = Button.new()
			purge_b.text = "remove"
			UiStyle.style_button(purge_b, "tertiary", 16)
			purge_b.pressed.connect( func():
				UiStyle.confirm(self, "remove %s for good?" % p.name, 
					"this action cannot be undone", 
					func():
						ProfileStore.purge_deleted(idx)
						_refresh_recent(), 
					"remove", "cancel", "exit", 5.0))
			row.add_child(purge_b)
			v.add_child(row)
		var all_b: = _menu_btn("delete all", "exit", func():
			UiStyle.confirm(self, "remove every deleted profile for good?", 
				"this action cannot be undone", 
				func():
					ProfileStore.purge_all_deleted()
					_refresh_recent(), 
				"delete all", "cancel", "exit", 5.0))
		v.add_child(all_b)
	_back_row(v, func(): _show(_profile))

func _refresh_recent() -> void :
	_rebuild_recent.call_deferred()

func _rebuild_recent() -> void :
	if not is_instance_valid(_recent):
		return
	var v: = _box(_recent)
	if v == null:
		return
	for c in v.get_children():
		v.remove_child(c)
		c.queue_free()
	_build_recent()
	_refresh_profile()
	_focus_current_page.call_deferred()


func _load_profile_pfp(rect: TextureRect) -> void :
	var tex: = await CharacterPortrait.render(GameConfig.character, "head", 
		Vector2i(220, 220), self)
	if is_instance_valid(rect):
		rect.texture = tex




func _build_quick() -> void :
	var v: = _box(_quick)
	v.custom_minimum_size.x = 470
	v.add_theme_constant_override("separation", 14)
	_hero_head(v, "quick match", true)
	var pick: = Label.new()
	pick.text = "filter modes"
	UiStyle.style_label(pick, "small", UiStyle.muted())
	v.add_child(pick)



	var grid: = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for n in GameConfig.team_sizes():
		var tile: = Button.new()
		tile.text = "%dv%d" % [n, n]
		tile.toggle_mode = true
		tile.custom_minimum_size = Vector2(142, 66)
		UiStyle.style_button(tile, "secondary", 23)
		tile.toggled.connect( func(on: bool):
			UiStyle.style_button(tile, "primary" if on else "secondary", 23)
			if on and _quick_any.button_pressed:
				_quick_any.set_pressed_no_signal(false)
				UiStyle.style_button(_quick_any, "secondary", 20))
		_quick_chips[n] = tile
		_lean.append(tile)
		grid.add_child(tile)
	v.add_child(grid)
	_quick_any = Button.new()
	_quick_any.text = "any mode"
	_quick_any.toggle_mode = true
	_quick_any.custom_minimum_size = Vector2(0, 54)
	_quick_any.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_button(_quick_any, "secondary", 20)
	_quick_any.toggled.connect( func(on: bool):
		UiStyle.style_button(_quick_any, 
			"primary" if on else "secondary", 20)
		if on:
			for n in _quick_chips:
				(_quick_chips[n] as Button).set_pressed_no_signal(false)
				UiStyle.style_button(_quick_chips[n], "secondary", 23))
	_lean.append(_quick_any)
	v.add_child(_quick_any)
	_quick_fresh = CheckBox.new()
	_quick_fresh.text = "fresh matches only"
	UiStyle.style_check(_quick_fresh)

	_quick_fresh.visible = QuickPlay.BACKFILL
	v.add_child(_quick_fresh)



	if not _quick_fresh.visible:
		var gap: = Control.new()
		gap.custom_minimum_size = Vector2(0, 16)
		v.add_child(gap)
	var find_card: = _card_btn("massiveMultiplayer", "find match", 
		MenuCopy.sub("find_match"), "primary", _find_quick)
	_quick_find_btn = find_card.get_child(0) as Button
	v.add_child(find_card)
	_back_row(v, func(): _show(_online))

func _build_matchmaking() -> void :
	_qp = QuickPlay.new()
	add_child(_qp)
	_qp.status.connect( func(t: String):
		if _mm_label != null:
			_mm_label.text = t
		if _mm_chip_label != null:
			_mm_chip_label.text = t)
	_qp.failed.connect( func(r: String):
		if _mm_label != null:
			_mm_label.text = r
		var tree: = get_tree()
		if tree != null:
			await tree.create_timer(2.5).timeout
		if _qp.state == QuickPlay.State.IDLE:
			_set_matchmaking(false))
	_qp.locked.connect( func():
		if _mm_cancel != null:
			_mm_cancel.disabled = true
		if _mm_title != null:
			_mm_title.text = "match found!")

	_qp.moving.connect(_raise_move_cover)
	_qp.quick_start.connect(_quick_freeze_and_start)



	Net.quick_modes_requested.connect( func(m: Array): _qp.absorb_filter(m))
	Net.match_started.connect(_menu_match_started)




	_mm_chip = PanelContainer.new()
	var cb: = UiStyle.card_box(Color(UiStyle.card(), 0.96), 99)
	cb.content_margin_left = 10.0
	cb.content_margin_right = 18.0
	cb.content_margin_top = 6.0
	cb.content_margin_bottom = 6.0
	cb.shadow_size = 8
	cb.shadow_offset = Vector2(0, 3)
	_mm_chip.add_theme_stylebox_override("panel", cb)
	var chip_row: = HBoxContainer.new()
	chip_row.add_theme_constant_override("separation", 10)
	_mm_chip.add_child(chip_row)
	var ring: = SearchRing.new()
	ring.custom_minimum_size = Vector2(22, 22)
	ring.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip_row.add_child(ring)
	var chip_col: = VBoxContainer.new()
	chip_col.add_theme_constant_override("separation", -2)
	chip_row.add_child(chip_col)
	var chip_title: = Label.new()
	chip_title.text = "finding a match"
	chip_title.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	chip_title.add_theme_font_size_override("font_size", 15)
	chip_title.add_theme_color_override("font_color", UiStyle.text())
	chip_col.add_child(chip_title)
	_mm_chip_label = Label.new()
	_mm_chip_label.text = "matchmaking..."
	UiStyle.style_label(_mm_chip_label, "small", UiStyle.muted())
	chip_col.add_child(_mm_chip_label)
	_mm_chip.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_mm_chip.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_mm_chip.offset_top = 14.0
	_mm_chip.visible = false
	ui.add_child(_mm_chip)


class SearchRing extends Control:
	var _a: = 0.0
	func _process(delta: float) -> void :
		_a += delta * 4.2
		queue_redraw()
	func _draw() -> void :
		var c: = size * 0.5
		var r: = minf(size.x, size.y) * 0.5 - 2.0
		draw_arc(c, r, 0.0, TAU, 32, Color(UiStyle.SUCCESS, 0.25), 3.0, true)
		draw_arc(c, r, _a, _a + 1.9, 16, UiStyle.SUCCESS, 3.0, true)




func _set_matchmaking(on: bool) -> void :
	_bottom_panel.add_theme_stylebox_override("panel", 
		_bar_green if on else _bar_normal)
	_top_panel.add_theme_stylebox_override("panel", 
		_top_green if on else _top_normal)


	_tint_player_card(on)
	_tint_top_bar(on)
	_mm_title.visible = on
	_mm_label.visible = on
	_mm_cancel.visible = on
	_mm_cancel.disabled = false
	_mm_title.text = "matchmaking..."



	if _discord_btn != null:
		_discord_btn.visible = not on
	if _wishlist_btn != null:
		_wishlist_btn.visible = not on
	if _version_label != null:
		_version_label.visible = not on
	if _freeplay:
		_bottom_panel.visible = on or not _freeplay
		if _pc_avatar != null:
			_pc_avatar.visible = _bottom_panel.visible



func _party_queue_when_formed(sz: int, give_up: float) -> void :
	var waited: = 0.0
	while Net.party_members().size() < 2 and waited < give_up:
		await get_tree().create_timer(0.25).timeout
		waited += 0.25
	await get_tree().create_timer(0.5).timeout
	if _quick_chips.has(sz):
		(_quick_chips[sz] as Button).button_pressed = true
	_find_quick()

func _find_quick() -> void :

	if Net.party and not Net.is_host:
		_flash_notice("only the party leader can queue")
		return
	if not OnlineTerms.require(_find_quick):
		return

	if _qp.state != QuickPlay.State.IDLE:
		_qp.cancel()
	var modes: Array = []
	for n in _quick_chips:
		if (_quick_chips[n] as Button).button_pressed:
			modes.append(n)
	if modes.is_empty() or _quick_any.button_pressed:
		modes = GameConfig.team_sizes().duplicate()







	if Net.party or LocalPlayers.has_guests():
		var floor_size: = PartySeats.queue_floor()
		modes = modes.filter( func(m): return int(m) >= floor_size)
		if modes.is_empty():
			_flash_notice("your group of %d needs a bigger mode" % floor_size)
			return
	modes.sort()
	Net.my_name = Net.local_display_name()





	if (_dev_shortcuts() and Input.is_key_pressed(KEY_SHIFT)) or _harness_lan():
		_qp.force_lan = true
		_shift_lan = true
	elif _shift_lan:
		_qp.force_lan = false
		_shift_lan = false



	if not _qp.can_search():
		_flash_notice(Net.steam_status_text())
		return
	if Net.party:



		_qp.party_block = Net.party_members()
		_qp.begin(modes, _quick_fresh.button_pressed, true)
	else:
		_qp.begin(modes, _quick_fresh.button_pressed, false)
	_mm_label.text = "searching"
	_set_matchmaking(true)
	_update_presence()
	_show(_home)




func _dev_shortcuts() -> bool:
	return OS.has_feature("editor") and not LaunchGate.public_beta()




func _harness_lan() -> bool:
	return AppData.is_harness() and "--lan" in LaunchGate.dev_args()





func _build_friends_panel() -> void :
	_friends_panel = PanelContainer.new()
	UiStyle.style_panel(_friends_panel, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	_friends_panel.visible = false
	var pad: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % side, 14)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.custom_minimum_size.x = 300


	_hero_head(v, "friends", true)
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(300, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	_friends_list = VBoxContainer.new()
	_friends_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_friends_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_friends_list)
	v.add_child(scroll)
	pad.add_child(v)
	_friends_panel.add_child(pad)


	_friends_scrim = Control.new()
	_friends_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_friends_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_friends_scrim.visible = false
	_friends_scrim.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_close_friends_panel())
	ui.add_child(_friends_scrim)
	ui.add_child(_friends_panel)
	_friends_panel.anchor_left = 1.0
	_friends_panel.anchor_right = 1.0
	_friends_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_friends_panel.grow_vertical = Control.GROW_DIRECTION_END
	_friends_panel.offset_right = -24.0
	_friends_panel.offset_top = 96.0

	if not Net.friends_changed.is_connected(_on_friends_changed):
		Net.friends_changed.connect(_on_friends_changed)

func _toggle_friends_panel() -> void :
	if _friends_panel == null:
		return
	if _friends_panel.visible:
		_close_friends_panel()
		return
	_friends_panel.visible = true
	_friends_scrim.visible = true
	_friends_poll = FRIENDS_POLL
	_refresh_friends_panel()
	UiStyle.sfx("open")
	_focus_friends_first.call_deferred()



func _open_friends_for_invite() -> void :
	if _friends_panel == null:
		_flash_notice("couldn't open the steam overlay to invite")
		return
	if not _friends_panel.visible:
		_toggle_friends_panel()

func _close_friends_panel() -> void :
	if _friends_panel == null or not _friends_panel.visible:
		return
	_friends_panel.visible = false
	_friends_scrim.visible = false
	UiStyle.sfx("close")

	if InputPrompts.using_gamepad() and _friends_btn != null:
		_friends_btn.grab_focus()

func _focus_friends_first() -> void :
	var btns: = _panel_buttons(_friends_panel)
	if not btns.is_empty():
		(btns[0] as Control).grab_focus()


func _panel_buttons(root: Node) -> Array:
	var out: Array = []
	if root == null:
		return out
	for c in root.find_children("*", "BaseButton", true, false):
		var b: = c as BaseButton
		if b != null and b.is_visible_in_tree() and not b.disabled\
		and b.focus_mode != Control.FOCUS_NONE:
			out.append(b)
	return out



func _drive_friends(delta: float) -> void :
	_nav_cooldown = maxf(_nav_cooldown - delta, 0.0)
	_accept_cd = maxf(_accept_cd - delta, 0.0)
	if LocalPlayers.ui_just_pressed("ui_cancel"):
		_close_friends_panel()
		return
	if LocalPlayers.ui_just_pressed("ui_accept") and _accept_cd <= 0.0:
		_accept_cd = ACCEPT_DEBOUNCE
		var foc: = get_viewport().gui_get_focus_owner()
		if foc is BaseButton and not (foc as BaseButton).disabled:
			(foc as BaseButton).pressed.emit()
		return
	var dir: = ""
	if LocalPlayers.ui_pressed("ui_down"): dir = "down"
	elif LocalPlayers.ui_pressed("ui_up"): dir = "up"
	if dir == "":
		_nav_dir = ""
		return
	if dir != _nav_dir:
		_nav_dir = dir
		_nav_repeat = NAV_FIRST_DELAY
		if _nav_cooldown <= 0.0:
			_nav_cooldown = NAV_DEBOUNCE
			_friends_step(dir)
	elif _nav_repeat <= 0.0:
		_nav_repeat = NAV_REPEAT_RATE
		_friends_step(dir)
	else:
		_nav_repeat -= delta

func _friends_step(dir: String) -> void :
	var btns: = _panel_buttons(_friends_panel)
	if btns.is_empty():
		return
	var foc: = get_viewport().gui_get_focus_owner()
	var i: = btns.find(foc)
	if i == -1:
		(btns[0] as Control).grab_focus()
		UiStyle.sfx("hover")
		return
	var step: = 1 if dir == "down" else -1
	var nxt: = btns[(i + step + btns.size()) % btns.size()] as Control
	nxt.grab_focus()
	_scroll_follow(nxt)
	UiStyle.sfx("hover")









var _friend_rows: = {}
var _friends_empty: Label = null
var _friends_dirty_t: = -1.0
var _friends_held: = false
const FRIENDS_DEBOUNCE: = 0.25
const FRIENDS_POLL: = 3.0


func _on_friends_changed() -> void :
	_queue_friends_refresh()

func _queue_friends_refresh(delay: = FRIENDS_DEBOUNCE) -> void :
	if _friends_panel == null or not _friends_panel.visible:
		return
	if _friends_dirty_t < 0.0 or delay < _friends_dirty_t:
		_friends_dirty_t = delay






func _friends_hold_order() -> bool:
	if _friends_panel == null or not _friends_panel.visible or InputPrompts.using_gamepad():
		return false
	return _friends_panel.get_global_rect().has_point(_friends_panel.get_global_mouse_position())

func _refresh_friends_panel() -> void :
	if _friends_list == null or not _friends_panel.visible:
		return
	_friends_dirty_t = -1.0
	var friends: = _friends_source()

	var foc: = get_viewport().gui_get_focus_owner()
	var foc_fid: = 0
	var foc_act: = ""
	var foc_idx: = -1
	if foc != null and _friends_list.is_ancestor_of(foc):
		var r: Node = foc
		while r != null and r.get_parent() != _friends_list:
			r = r.get_parent()
		if r != null and r.has_meta("fid"):
			foc_fid = int(r.get_meta("fid"))
			foc_idx = r.get_index()
			foc_act = String(foc.get_meta("act", ""))
	if _friends_empty == null:
		_friends_empty = Label.new()
		UiStyle.style_label(_friends_empty, "small")
		_friends_empty.text = "no friends online"
		_friends_list.add_child(_friends_empty)
		_friends_list.move_child(_friends_empty, 0)

	var want: = {}
	for f in friends:
		want[int(f.get("id", 0))] = true


	for fid in _friend_rows.keys():
		if not want.has(fid):
			var gone: Node = (_friend_rows[fid] as Dictionary).row
			_friends_list.remove_child(gone)
			gone.queue_free()
			_friend_rows.erase(fid)
	_friends_empty.visible = friends.is_empty()
	var hold: = _friends_hold_order()
	for i in friends.size():
		var f: Dictionary = friends[i]
		var fid: = int(f.get("id", 0))
		var rec: Dictionary = _friend_rows.get(fid, {})
		if rec.is_empty():
			rec = _friend_row_new(fid)
			_friend_rows[fid] = rec
			_friends_list.add_child(rec.row)
		_friend_row_update(rec, f)

		if not hold and (rec.row as Node).get_index() != i + 1:
			_friends_list.move_child(rec.row, i + 1)
	_friends_held = hold



	if foc_fid != 0 and ( not is_instance_valid(foc) or not foc.is_inside_tree()
			or not _friends_list.is_ancestor_of(foc)
			or (foc is BaseButton and (foc as BaseButton).disabled)):
		_friends_refocus(foc_fid, foc_act, foc_idx)
	elif foc_fid != 0 and _friend_rows.has(foc_fid)\
	and ((_friend_rows[foc_fid] as Dictionary).row as Node).get_index() != foc_idx:
		_scroll_follow(foc)

func _friends_refocus(fid: int, act: String, idx: int) -> void :
	var rec: Dictionary = _friend_rows.get(fid, {})
	if not rec.is_empty():
		var any: BaseButton = null
		for b in (rec.act as Node).get_children():
			if b is BaseButton and not (b as BaseButton).disabled\
			and not b.is_queued_for_deletion():
				if String(b.get_meta("act", "")) == act:
					(b as Control).grab_focus()
					return
				if any == null:
					any = b
		if any != null:
			any.grab_focus()
			return
		idx = (rec.row as Node).get_index()

	var kids: = _friends_list.get_children()
	for d in range(1, kids.size() + 1):
		for j in [idx + d, idx - d]:
			if j < 0 or j >= kids.size():
				continue
			for b in (kids[j] as Node).find_children("*", "BaseButton", true, false):
				if not (b as BaseButton).disabled and not b.is_queued_for_deletion():
					(b as Control).grab_focus()
					_scroll_follow(b)
					return

func _friend_row_new(fid: int) -> Dictionary:
	var row: = HBoxContainer.new()
	row.set_meta("fid", fid)
	row.add_theme_constant_override("separation", 10)
	var col: = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 0)
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var nm: = Label.new()
	col.add_child(nm)
	var st: = Label.new()
	UiStyle.style_label(st, "small")
	col.add_child(st)
	row.add_child(col)
	var act: = HBoxContainer.new()
	act.add_theme_constant_override("separation", 6)
	act.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(act)
	return {"row": row, "nm": nm, "st": st, "act": act, "sig": "", "lobby": 0, 
		"in_game": null, "fid": fid}


func _friend_actions(f: Dictionary) -> Array:
	var fid: = int(f.get("id", 0))
	var in_game: bool = f.get("in_game", false)
	var mine: = _friend_in_my_party(fid)
	var out: Array = []


	if in_game and int(f.get("lobby", 0)) != 0 and not mine:
		out.append("join")





	var party_inv: = Net.party and Net.can_invite_to_party()
	var room_inv: = not Net.party and Net.is_host and Net.steam_lobby_id != 0
	if Net.party and not party_inv and not mine:
		out.append("leader")
	if party_inv or room_inv or (Net.party and mine):
		if mine:
			out.append("in party")
		elif _invite_pending(fid):
			out.append("invited")
		else:
			out.append("invite")
	return out

func _friend_row_update(rec: Dictionary, f: Dictionary) -> void :
	var fid: int = rec.fid
	var in_game: bool = f.get("in_game", false)
	var nm: Label = rec.nm
	var name_txt: = String(f.get("name", "friend"))
	if nm.text != name_txt:
		nm.text = name_txt
	if rec.in_game == null or bool(rec.in_game) != in_game:
		rec.in_game = in_game
		UiStyle.style_label(nm, "body", UiStyle.SUCCESS if in_game else UiStyle.text())
	var status: = String(f.get("status", ""))
	if not in_game:

		match int(f.get("state", 1)):
			2: status = "busy"
			3, 4: status = "away"
			_: status = "in another game" if bool(f.get("other_game", false)) else "online"
	elif status == "":
		status = "in voloball"
	var st: Label = rec.st
	if st.text != status:
		st.text = status
	rec.lobby = int(f.get("lobby", 0))
	var acts: = _friend_actions(f)
	var sig: = ",".join(acts)
	if sig == String(rec.sig):
		return
	rec.sig = sig
	var act: HBoxContainer = rec.act
	for c in act.get_children():
		act.remove_child(c)
		c.queue_free()
	for a in acts:
		match a:
			"join":
				var join: = Button.new()
				join.text = "join"
				join.set_meta("act", "join")
				UiStyle.style_button(join, "secondary", 13)
				join.pressed.connect( func():
					if int(rec.lobby) != 0:
						Net.steam_join_friend_lobby(int(rec.lobby)))
				act.add_child(join)
			"leader":
				var only: = Label.new()
				only.text = "leader invites"
				UiStyle.style_label(only, "small")
				only.tooltip_text = "private party: only the leader can invite"
				only.mouse_filter = Control.MOUSE_FILTER_PASS
				act.add_child(only)
			"in party":
				var tag: = Label.new()
				tag.text = "in party"
				UiStyle.style_label(tag, "small", UiStyle.SUCCESS)
				act.add_child(tag)
			"invited":
				var sent: = Button.new()
				sent.text = "invited"
				sent.set_meta("act", "invited")
				UiStyle.style_button(sent, "tertiary", 13)
				sent.disabled = true
				act.add_child(sent)
			"invite":
				var inv: = Button.new()
				inv.text = "invite"
				inv.set_meta("act", "invite")
				UiStyle.style_button(inv, "primary", 13)
				inv.pressed.connect( func():
					if Net.party:


						Net.request_party_invite(fid)
						return
					Net.steam_invite_friend(fid)
					_invited_ids[fid] = Time.get_ticks_msec()
					_refresh_friends_panel())
				act.add_child(inv)


func _friends_source() -> Array:
	if _fake_friends is Array and OS.has_feature("editor"):
		var out: Array = (_fake_friends as Array).duplicate(true)
		out.sort_custom( func(a, b):
			if bool(a.in_game) != bool(b.in_game):
				return bool(a.in_game)
			return String(a.name).naturalnocasecmp_to(String(b.name)) < 0)
		return out
	return Net.steam_friends()


func _make_fake_friends(n: int) -> Array:
	var names: = ["Somnus", "Avovet", "Ayudin", "Saguinee", "Maybesky", "october", 
		"reg", "Kirby", "Bronte", "Enzo", "Shaye", "tmko", "pixelpal", "Juno"]
	var out: Array = []
	for i in n:
		var nm: String = names[i % names.size()] + ("" if i < names.size() else str(i / names.size()))
		out.append({"id": 76561198000001000 + i, "name": nm, "in_game": i % 3 == 0, 
			"status": "in the menu" if i % 3 == 0 else "", "lobby": 0, "state": 1})
	return out


func _churn_fake_friends(rng: RandomNumberGenerator, flips: = 3) -> void :
	if not (_fake_friends is Array) or (_fake_friends as Array).is_empty():
		return
	var arr: Array = _fake_friends
	var lines: = ["in the menu", "in freeplay", "in a party of 3", "looking for a match", ""]
	for k in flips:
		var f: Dictionary = arr[rng.randi() % arr.size()]
		match rng.randi() % 3:
			0:
				f.in_game = not bool(f.in_game)
				f.status = lines[rng.randi() % lines.size()] if f.in_game else ""
				f.lobby = 0
			1:
				if bool(f.in_game):
					f.status = lines[rng.randi() % lines.size()]
			2:
				if bool(f.in_game):
					f.lobby = 0 if int(f.lobby) != 0 else 109775240000000000 + rng.randi() % 1000



const INVITE_PENDING_MS: = 30000
func _invite_pending(fid: int) -> bool:
	return _invited_ids.has(fid)\
	and Time.get_ticks_msec() - int(_invited_ids[fid]) < INVITE_PENDING_MS


func _friend_in_my_party(sid: int) -> bool:
	if not Net.party or sid == 0:
		return false
	for pid in Net.party_members():
		if int((Net.players[pid] as Dictionary).get("sid", 0)) == sid:
			return true
	return false



func _update_presence() -> void :
	var text: = "in the menu"
	var group: = ""
	var gsize: = 0
	var queuing: bool = _member_queuing\
	or (_qp != null and _qp.state != QuickPlay.State.IDLE)
	if Net.party:
		group = "party%d" % Net.session_token
		gsize = Net.party_members().size()
		if queuing:
			text = "looking for a match with friends"
		elif _freeplay:
			text = "warming up with a party"
		else:
			text = "in a party of %d" % gsize
	elif _freeplay:
		text = "in freeplay"
	elif queuing:
		text = "looking for a match"
	Net.set_presence(text, group, gsize)





func _reraise_own_search() -> void :
	if _qp == null or _qp.state == QuickPlay.State.IDLE:
		return
	if _freeplay or _practice_on:
		_mm_chip.visible = true
	else:
		_set_matchmaking(true)

func _on_member_quick_status(line: String) -> void :




	if Net.is_host or not (Net.party or Net.i_am_fold()):
		return
	if line == "":
		_member_queuing = false
		_set_matchmaking(false)
		_mm_chip.visible = false
		_reraise_own_search()
		return
	_member_queuing = true
	_mm_title.text = "matchmaking..."



	var hp_m: Dictionary = Net.home_party
	if line == "match found!" and (Net.party\
	or ( not hp_m.is_empty() and not bool(hp_m.get("room", false)))):
		_raise_move_cover()



	if _qp == null or _qp.state == QuickPlay.State.IDLE:
		_mm_label.text = line
		if _mm_chip_label != null:
			_mm_chip_label.text = line


	if _freeplay or _practice_on:
		_mm_chip.visible = true
		_set_matchmaking(false)
	else:
		_mm_chip.visible = false
		_set_matchmaking(true)



		var hp: Dictionary = Net.home_party
		var party_fold: = not hp.is_empty() and not bool(hp.get("is_leader", false))\
		and not bool(hp.get("room", false))
		_mm_cancel.visible = Net.i_am_fold() and not party_fold



func _quick_freeze_and_start() -> void :
	var ids: = Net.players.keys()
	ids.sort()


	var roster: = Net.match_roster(ids, Net.players, Net.team_size, {}, {}, true)

	PartyMark.tag_roster(roster, Net.players, Net.party_members())
	GameConfig.set_mode(Net.team_size)
	GameConfig.stage = Net.stage
	GameConfig.ranked_match = false

	GameConfig.quick_match = true
	Net.start_match(roster, randi())

func _menu_match_started(roster: Array) -> void :
	if not Net.practice:
		Net.pending_start = []
	if Net.practice:



		if Net.is_host:
			_embed_party_practice(roster)
		elif _practice_court == null or not _practice_court.running() or _practice_solo:


			_with_loading(_embed_party_practice.bind(roster))
		else:
			_court_now(_embed_party_practice.bind(roster))
		return
	_start_real_match(roster)




func _embed_party_practice(roster: Array) -> void :
	if not Net.practice or Net.in_match:
		return
	if _practice_court != null and _practice_court.running():
		if _practice_on:
			_practice_enter_on_start = true
		_stop_practice(false)

	if Net.stage != _freeplay_stage and Stage.in_build(Net.stage):
		_swap_stage(Net.stage, false, false)
	_keep_menu_config()
	PracticeMode.apply_court_size(Net.practice_size)
	GameConfig.stage = Net.stage
	Net.apply_rules_to_config()
	GameConfig.net_roster = roster
	GameConfig.quick_match = false
	_embed_practice()

func _start_real_match(roster: Array) -> void :

	_stop_practice()

	if _feedback != null and is_instance_valid(_feedback):
		_feedback.queue_free()
		_feedback = null
	if _credits_page != null and is_instance_valid(_credits_page):
		_credits_page.queue_free()
		_credits_page = null
	GameConfig.set_mode(Net.team_size)
	GameConfig.stage = Net.stage
	Net.apply_rules_to_config()
	GameConfig.net_roster = roster




	if Net.is_host:
		GameConfig.quick_match = _qp != null\
		and _qp.state != QuickPlay.State.IDLE


	if _move_cover != null and is_instance_valid(_move_cover):
		var ls: = _move_cover
		_move_cover = null
		ls.hold_through_scene_change()
		GameConfig.goto_scene("res://game/main/main.tscn")
		return
	UiWipe.wipe(get_tree(), func():
		GameConfig.goto_scene("res://game/main/main.tscn"))

var _c_size: UiSelect
var _c_sets: UiSelect
var _c_points: SpinBox
var _c_wbt: CheckBox
var _c_sweat: CheckBox
var _c_rate: UiSelect
var _c_stage: UiSelect
var _c_diff_local: UiSelect
var _c_side: UiSelect

func _build_custom() -> void :
	var v: = _box(_custom)
	_hero_head(v, "custom match", true)
	_c_size = UiSelect.new(["1v1", "2v2", "3v3", "4v4", "5v5", "6v6"])
	v.add_child(_labeled("teams", _c_size))
	_c_sets = UiSelect.new(["1 set", "best of 3", "best of 5"])
	v.add_child(_labeled("sets", _c_sets))
	_c_points = SpinBox.new()
	_c_points.min_value = 3
	_c_points.max_value = 25
	UiStyle.style_spin(_c_points)
	v.add_child(_labeled("points", _c_points))
	_c_wbt = CheckBox.new()
	_c_wbt.text = "win by two"
	UiStyle.style_check(_c_wbt)
	v.add_child(_c_wbt)
	_c_sweat = CheckBox.new()
	_c_sweat.text = "sweat builds up"
	UiStyle.style_check(_c_sweat)
	v.add_child(_c_sweat)
	_c_rate = UiSelect.new(SWEAT_RATE_NAMES)
	v.add_child(_labeled("sweat rate", _c_rate))
	var stage_titles: Array = []
	for id in Stage.ids():
		stage_titles.append(Stage.title(id))
	_c_stage = UiSelect.new(stage_titles)
	v.add_child(_labeled("stage", _c_stage))
	v.add_child(_menu_btn("start match", "primary", _start_custom))
	_back_row(v, func(): _show(_local))

func _labeled(text: String, control: Control) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var l: = Label.new()
	l.text = text
	UiStyle.style_label(l, "body")
	l.custom_minimum_size.x = 96
	row.add_child(l)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row










const SHOW_FEEDBACK_BUTTON: = false
var _feedback: FeedbackPanel = null




const CREDITS_PAGE: = preload("res://game/ui/credits_page.gd")
var _credits_page: Control = null

func _open_credits() -> void :
	if _credits_page != null and is_instance_valid(_credits_page):
		return
	_credits_page = CREDITS_PAGE.new()
	_credits_page.closed.connect( func():
		_credits_page = null
		_modal_closed())
	ui.add_child(_credits_page)
	get_viewport().gui_release_focus()
	_flatten_cards()




var _guide_page: Control = null

var _guide_return: = ""

func _open_guide(spread: = "") -> void :
	if _guide_page != null and is_instance_valid(_guide_page):
		return
	if not GuideStore.open_to_players():
		return
	var page: = Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.mouse_filter = Control.MOUSE_FILTER_STOP
	var veil: = ColorRect.new()
	veil.color = Color("111214") if UiStyle.dark else Color.WHITE
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_child(veil)
	var book: = HOW_TO_PLAY.instantiate() as HowToPlay
	book.show_close = true
	book.start_spread = spread

	book.freeplay_requested.connect( func(at: String):
		if _couch_blocks("freeplay"):
			return
		_guide_return = at
		page.queue_free()
		_guide_page = null
		_modal_closed()
		_enter_freeplay())
	book.set_anchors_preset(Control.PRESET_FULL_RECT)
	book.offset_left = 24
	book.offset_top = 14
	book.offset_right = -24
	book.offset_bottom = -14
	page.add_child(book)
	book.closed.connect( func():
		page.queue_free()
		_guide_page = null
		_modal_closed())
	_guide_page = page
	ui.add_child(page)
	get_viewport().gui_release_focus()
	_flatten_cards()





const TITLE_EDITOR: = preload("res://game/ui/title_editor.gd")
const TITLE_CHIP: = preload("res://game/ui/title_chip.gd")
const TITLES: = preload("res://game/titles/title_catalog.gd")
var _title_editor: Control = null

func _open_title_editor() -> void :
	if _title_editor != null and is_instance_valid(_title_editor):
		return
	var page: = TITLE_EDITOR.new()
	_title_editor = page
	page.shop_pressed.connect( func(shelf: String):
		Engine.set_meta("shop_tab", "titles")
		Engine.set_meta("shop_shelf", shelf)
		_wipe_to(_shop_scene()))
	page.closed.connect( func():
		_title_editor = null
		_modal_closed()
		if page.changed:
			_refresh_profile())
	ui.add_child(page)
	get_viewport().gui_release_focus()
	_flatten_cards()


func _modal_up() -> bool:
	return (_feedback != null and is_instance_valid(_feedback))\
	or (_credits_page != null and is_instance_valid(_credits_page))\
	or (_guide_page != null and is_instance_valid(_guide_page))\
	or (_title_editor != null and is_instance_valid(_title_editor)) or PAD_KEYBOARD.is_open()






func _modal_closed() -> void :
	_accept_cd = ACCEPT_DEBOUNCE
	_cancel_cd = ACCEPT_DEBOUNCE



func _flatten_cards() -> void :
	for c in _tilt:
		var card: = c as Button
		if is_instance_valid(card):
			card.offset_transform_enabled = false
			card.z_index = 0

func _open_feedback() -> void :
	if _feedback != null and is_instance_valid(_feedback):
		return
	_feedback = FeedbackPanel.new()
	_feedback.closed.connect( func():
		_feedback = null
		_modal_closed())
	ui.add_child(_feedback)
	get_viewport().gui_release_focus()
	_flatten_cards()

func _open_settings(settings_scope: int) -> void :
	if _settings_panel != null:
		_settings_panel.set_scope(settings_scope)

	if _settings_title != null:
		_settings_title = _hero_head(_box(_settings), "profile settings"\
		if settings_scope == SettingsPanel.Scope.PROFILE else "system settings", true)
	_show(_settings)




func _settings_back() -> void :
	if _settings_panel != null and _settings_panel.scope == SettingsPanel.Scope.PROFILE:
		_show(_profile)
	else:
		_back_to_hub()

func _build_settings() -> void :
	var v: = _box(_settings)

	for c in v.get_children():
		v.remove_child(c)
		c.free()
	v.add_theme_constant_override("separation", 12)


	if v.has_meta("card"):
		(v.get_meta("card") as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())


	_settings_title = _hero_head(v, "system settings", true)
	var panel: = SETTINGS_PANEL.instantiate() as SettingsPanel
	panel.on_field = true
	_settings_panel = panel


	panel.retheme_requested.connect( func(_dark: bool):
		UiWipe.wipe(get_tree(), func():
			GameConfig.goto_scene("res://game/ui/menu.tscn")))


	panel.economy_poked.connect(_refresh_player_card)


	panel.profile_settings_requested.connect( func():
		( func():
			_open_settings(SettingsPanel.Scope.PROFILE)
			if not InputPrompts._pointer:
				_focus_current_page()).call_deferred())


	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size.x = 860
	v.add_child(panel)

	_back_row(v, _settings_back)
	var reset_all: = _menu_btn("reset all", "exit", func(): panel.reset_all())
	reset_all.add_theme_font_size_override("font_size", 19)
	reset_all.custom_minimum_size = Vector2(150, 46)
	(v.get_meta("foot") as Control).add_child(reset_all)




var _howto_panel: HowToPanel = null

func _build_howto() -> void :
	var v: = _box(_howto)
	v.add_theme_constant_override("separation", 12)

	if v.has_meta("card"):
		(v.get_meta("card") as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_hero_head(v, "how to play", true)
	var panel: = HowToPanel.new()
	_howto_panel = panel
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = Vector2(1040, 480)
	v.add_child(panel)
	_back_row(v, func(): _show(_practice))

var _last_shown: Control = null

func _show(page: Control) -> void :
	for p in [_home, _online, _local, _practice, _configs, _profile, _quick, 
		_custom, _settings, _howto, _browse, _host, _room, _direct, _recent, 
		_achievements, _career, _local_choose]:
		if p != null:
			p.visible = p == page


	_refresh_player_card()


	_set_configs_live(page == _configs)

	LocalPlayers.watch_joins = page == _configs


	var hide_bar: = page == _configs
	if _bottom_panel != null:
		_bottom_panel.visible = not hide_bar
	if _bottom_strip != null:
		_bottom_strip.visible = not hide_bar
	if _bottom_bar != null:
		_bottom_bar.visible = not hide_bar
	if _pc_avatar != null:
		_pc_avatar.visible = not hide_bar
	if page == _configs:
		_refresh_configs()
	if page == null:
		return




	_stagger_reveal(page)
	var panel: = page.find_child("Panel", true, false) as Control
	if panel != null and page != _last_shown:
		panel.offset_transform_enabled = true
		panel.offset_transform_position.x = -36.0 if page == _home else 36.0
		panel.modulate.a = 0.0
		var t: = panel.create_tween().set_parallel(true)
		t.tween_property(panel, "offset_transform_position:x", 0.0, 0.26)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		t.tween_property(panel, "modulate:a", 1.0, 0.16)
	_last_shown = page





	call_deferred("_focus_first", page)




func _focus_first(page: Control) -> void :
	if page == null or not page.visible or _freeplay:
		return
	for b in page.find_children("*", "Button", true, false):
		var btn: = b as Button
		if btn != null and btn.is_visible_in_tree() and not btn.disabled\
		and btn.focus_mode != Control.FOCUS_NONE:
			btn.grab_focus()
			return

func _on_input_device_changed() -> void :

	if InputPrompts.using_gamepad() and not _freeplay\
	and get_viewport().gui_get_focus_owner() == null:
		for p in [_home, _online, _local, _practice, _configs, _profile, 
			_quick, _settings, _howto, _browse, _host, _room, _direct, _recent]:
			if p != null and p.visible:
				_focus_first(p)
				return




func _stagger_reveal(page: Control) -> void :
	var box: = _box(page)
	if box != null:
		UiStyle.stagger_reveal(box)



func _cancel_search() -> void :
	if _qp != null and _qp.state != QuickPlay.State.IDLE:
		_qp.cancel()


	if _member_queuing and Net.active and not Net.is_host and Net.i_am_fold():
		Net.leave()
	_member_queuing = false
	_mm_chip.visible = false
	_set_matchmaking(false)

func _wipe_to(path: String) -> void :


	_cancel_search()
	UiWipe.wipe(get_tree(), func(): GameConfig.goto_scene(path))

func _start_local() -> void :


	GameConfig.quick_match = false
	GameConfig.save_settings()
	_go_to_match(_local_size)




func _go_to_match(size: int) -> void :
	GameConfig.set_mode(size)
	if Net.party:
		if not Net.is_host:
			_flash_notice("only the party leader can start a match")
			return
		_launch_party_match(size)
	else:
		_wipe_to("res://game/main/main.tscn")

func _launch_party_match(size: int) -> void :
	Net.practice = false
	Net.set_team_size(size)
	for id in Net.party_members():
		Net.players[id].side = 1
	var ids: = Net.players.keys()
	ids.sort()




	var roster: = Net.match_roster(ids, Net.players, size, GameConfig.local_cpus, 
		Net.captains)
	GameConfig.ranked_match = false

	Net.init_rules_from_config()
	Net.sync_lobby()
	Net.start_match(roster, randi())



func _open_custom() -> void :
	_populate_local()
	_show(_local)

func _start_custom() -> void :
	GameConfig.sets_to_win = _c_sets.selected + 1
	GameConfig.set_points = int(_c_points.value)
	GameConfig.win_by_two = _c_wbt.button_pressed
	GameConfig.sweat_enabled = _c_sweat.button_pressed
	GameConfig.sweat_rate = SWEAT_RATES[maxi(_c_rate.selected, 0)]
	GameConfig.stage = Stage.ids()[maxi(_c_stage.selected, 0)]
	GameConfig.quick_match = false
	GameConfig.save_settings()
	_go_to_match(_c_size.selected + 1)











func _refresh_host_cards() -> void :
	var leader: = Net.party and Net.is_host
	if _host_party_card != null:
		_host_party_card.visible = leader
	if _host_steam_card != null:
		_host_steam_card.visible = Net.steam_transport_available() and not leader

func _setup_online() -> void :
	_steam_up = Net.steam_init()
	if _steam_pill != null:
		_steam_pill.text = "steam authenticated" if _steam_up\
		or Net.steam_transport_available() else "steam not authenticated"
	_refresh_host_cards()
	if not Net.active:
		Net.stage = GameConfig.stage
	if _online_ready:
		return
	_online_ready = true


	Net.steam_ready.connect( func():
		_steam_up = true
		if _steam_pill != null:
			_steam_pill.text = "steam authenticated"
		_refresh_host_cards()
		if _friends_btn != null:
			_friends_btn.visible = Net.steam_transport_available()
		if _browse.visible:
			_refresh_browser())
	Net.lobby_changed.connect(_refresh_room)


	Net.lobby_changed.connect(_refresh_modifiers)

	Net.lobby_changed.connect(_queue_party_strip)
	Net.lobby_changed.connect(_check_home_notice)
	Net.lobby_changed.connect(_reconcile_party_bodies)
	Net.lobby_changed.connect(_resend_look_on_lobby)

	Net.lobby_changed.connect(_refresh_stage_btn)
	Net.lobby_changed.connect( func():
		if Net.active and not Net.party\
		and bool(Net.home_party.get("room", false)):
			_in_party_room = true)

	Net.dev_badges_changed.connect( func():
		for pid in _party_bodies:
			if is_instance_valid(_party_bodies[pid]):
				(_party_bodies[pid] as Player).set_dev_tag(DevBadge.peer_tier(int(pid)))
		_refresh_room())


	Mod.presence_changed.connect( func(_pid: int):
		for pid in _party_bodies:
			if is_instance_valid(_party_bodies[pid]):
				_dress_party_body(_party_bodies[pid], int(pid))
		for key in _party_guest_bodies.keys():
			if is_instance_valid(_party_guest_bodies[key]):
				(_party_guest_bodies[key] as Node).queue_free()
		_party_guest_bodies.clear()
		_queue_party_strip()
		_refresh_room())
	Net.party_joined.connect(_on_party_joined)
	Net.party_invite_result.connect(_on_party_invite_result)
	Net.party_travel_to.connect(_on_party_travel_to)
	Net.party_became_room.connect(_on_party_became_room)


	Net.invite_accepting.connect(_cancel_search)
	Net.party_home_called.connect(_on_party_home_called)
	Net.freeplay_pose.connect(_on_freeplay_pose)
	Net.ball_pose.connect(_on_ball_pose)
	Net.freeplay_fx.connect(_on_freeplay_fx)
	Net.party_look.connect(_on_party_look)



	Net.party_look.connect( func(_p: int, _o: String):
		if _look_repaint_queued:
			return
		_look_repaint_queued = true
		( func():
			_look_repaint_queued = false
			if not is_inside_tree():
				return
			if _room != null and _room.visible:
				_refresh_room()
			if _local != null and _local.visible and Net.party:
				_refresh_local()).call_deferred())
	Net.party_ball.connect(_on_party_ball)
	Net.party_stage.connect(_on_party_stage)
	Net.quick_status.connect(_on_member_quick_status)



	_party_puppets.render_delay_ms = 110.0
	Net.session_ended.connect(_on_session_ended)



	Net.session_ended.connect( func(_r: String): _refresh_party_strip.call_deferred())

	Net.session_ended.connect( func(_r: String): _refresh_stage_btn())

	Net.session_ended.connect( func(_r: String):
		if _practice_court != null and _practice_court.running() and not _practice_solo:
			_stop_practice())






	Net.session_ended.connect( func(_r: String):
		if _tutorial != null or _drill_return_stage != "":
			return
		if _qp != null and _qp.state != QuickPlay.State.IDLE:
			return
		var mine: = GameConfig.freeplay_stage
		if mine in Stage.freeplay_ids() and mine != _freeplay_stage:
			_swap_stage_live(mine, false, false))
	Net.steam_lobbies.connect(_on_steam_lobbies)
	_refresh_party_strip()

func _online_name() -> String:
	return Net.local_display_name()










const PARTY_DOCK_W: = 392.0


func _party_empty_slot(on_press: Callable, tip: = "invite a friend") -> Button:
	var b: = Button.new()
	b.flat = true
	b.custom_minimum_size = Vector2(34, 34)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ring: = Color("3a3a42") if UiStyle.dark else Color("b9c1d1")
	b.icon = UiStyle._disc_tex(102, Color(0, 0, 0, 0), ring, 0.08, true)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 34)
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	var plus: = Label.new()
	plus.text = "+"
	plus.set_anchors_preset(Control.PRESET_FULL_RECT)
	plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plus.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_BLACK))
	plus.add_theme_font_size_override("font_size", 20)
	plus.add_theme_color_override("font_color", Color("4a4a52") if UiStyle.dark else Color("a8b1c3"))
	plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(plus)
	b.tooltip_text = tip
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	UiStyle.hover_sound(b)
	b.pressed.connect(on_press)
	return b

func _refresh_party_strip() -> void :
	_apply_party_gating()
	_update_presence()
	_queue_friends_refresh(0.0)
	if _party_strip == null:
		return
	for c in _party_strip.get_children():
		c.queue_free()



	var away: = _party_away_mates()

	var in_room: = false
	if away.is_empty():
		away = _party_room_mates()
		in_room = not away.is_empty()
	if not Net.party and not away.is_empty():
		for i in away.size():
			var m: Dictionary = away[i]
			var nm: = String(m.get("name", ""))
			var lead: = bool(m.get("leader", false))
			var d: = _party_disc("singleplayer", 
				UiStyle.SECONDARY if lead else [UiStyle.HIGHLIGHT, UiStyle.SUCCESS, UiStyle.SECONDARY][i % 3], 
				(nm + "  (leader)") if lead else nm, Callable(), lead, 
				m.get("cfg", {}) if m.get("cfg", {}) is Dictionary else {})
			d.set_meta("party_disc", true)
			_party_strip.add_child(d)

		var tag: = Button.new()
		tag.text = "in a lobby together" if in_room\
		else ("regrouping" if _party_reforming() else "matchmaking together")
		UiStyle.style_button(tag, "tertiary", 13)
		_slim_button(tag)
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag.focus_mode = Control.FOCUS_NONE
		tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_party_strip.add_child(tag)
		_tint_top_bar(_mm_title != null and _mm_title.visible)
		_party_was_open = true
		return




	if not (Net.party or PartySeats.in_party()):
		var make: = Button.new()
		make.text = "create party"
		make.icon = UiStyle.icon("multiplayer")
		make.expand_icon = true
		make.add_theme_constant_override("icon_max_width", 20)
		make.add_theme_constant_override("h_separation", 8)
		UiStyle.style_button(make, "secondary", 15)
		for st in ["normal", "hover", "pressed", "focus"]:
			var msb: = make.get_theme_stylebox(st) as StyleBoxFlat
			if msb != null:
				msb.content_margin_left = 14.0
				msb.content_margin_right = 14.0
		make.tooltip_text = "start a party with friends"
		make.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		make.pressed.connect(_start_party)
		_party_strip.add_child(make)

		for i in Net.PARTY_MAX - 1:
			_party_strip.add_child(_party_empty_slot(_start_party, "start a party with friends"))
		_party_was_open = false
		return



	var seats: = PartySeats.list()
	for seat in seats:
		var leader: = PartySeats.is_leader(seat)
		var local: bool = String(seat.kind) == "local"
		var nm: = String(seat.name)
		if local:
			nm = "%s  (%s)" % [nm, String(seat.slot.tag())]
		var press: = Callable()
		if local:
			press = func(): _party_member_menu_local(seat.slot)
		elif String(seat.kind) in ["remote", "remote_local"] and Net.is_host:


			press = func(): _party_member_menu(int(seat.peer))

		var member_c: Color = [UiStyle.HIGHLIGHT, UiStyle.SUCCESS, UiStyle.SECONDARY][
			_party_strip.get_child_count() % 3]
		var disc: = _party_disc("singleplayer", 
			UiStyle.SECONDARY if leader else (seat.slot.color() if local\
			else member_c), 
			(nm + "  (leader)") if leader else nm, press, leader, 
			Mod.shown_cfg(int(seat.get("peer", 0)), seat.get("cfg", {})) if not local\
			else (seat.get("cfg", {}) if seat.get("cfg", {}) is Dictionary else {}))
		disc.set_meta("party_disc", true)
		_party_strip.add_child(disc)



	var may_invite: = not Net.party or Net.can_invite_to_party()
	for i in range(seats.size(), Net.PARTY_MAX):
		if may_invite:
			_party_strip.add_child(_party_empty_slot(_party_add))
		else:
			var shut: = _party_empty_slot( func():
				_flash_notice("private party: only the leader can invite"), 
				"private party: only the leader can invite")
			shut.modulate.a = 0.4
			_party_strip.add_child(shut)
	var push: = Control.new()
	push.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_party_strip.add_child(push)


	if Net.party and Net.is_host:
		var priv: = Button.new()
		priv.text = Net.PARTY_PRIV_NAMES[Net.party_privacy]
		UiStyle.style_button(priv, "tertiary", 12)
		_slim_button(priv)
		priv.tooltip_text = ("open: anyone in the party can invite people"\
		if Net.party_privacy == Net.PartyPriv.OPEN\
		else "private: only you can invite people") + "\nclick to switch"
		priv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		priv.set_meta("bar_text", true)
		priv.pressed.connect(_toggle_party_privacy)
		_party_strip.add_child(priv)



	if not Net.party:
		var go: = Button.new()
		go.text = "go online"
		UiStyle.style_button(go, "tertiary", 13)
		_slim_button(go)
		go.tooltip_text = "take this party online so friends can join"
		go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		go.set_meta("bar_text", true)
		go.pressed.connect(_start_party)
		_party_strip.add_child(go)
	var out: = Button.new()
	out.text = "disband" if ( not Net.party or Net.is_host) else "leave"
	UiStyle.style_button(out, "tertiary", 13)
	_slim_button(out)
	out.pressed.connect(_leave_party)
	out.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	out.set_meta("bar_text", true)
	_party_strip.add_child(out)
	_tint_top_bar(_mm_title != null and _mm_title.visible)

	if not _party_was_open:
		_unfold_party()
	_party_was_open = true





func _apply_party_gating() -> void :



	var p: = PartySeats.has_remote()


	var leader: = Net.party and Net.is_host
	_refresh_host_cards()
	if _card_local != null:
		_card_local.disabled = p
	if _card_custom_lobby != null:
		_card_custom_lobby.disabled = p and not leader
	if _card_direct != null:
		_card_direct.disabled = p
	if _replays_tab != null:


		_replays_tab.disabled = Net.active
		_replays_tab.tooltip_text = "not while you're in a party or online"\
		if Net.active else ""


	var floor_size: int = PartySeats.human_count()
	for n in _quick_chips:
		var tile: = _quick_chips[n] as Button
		if tile == null:
			continue
		var too_small: = int(n) < floor_size
		tile.disabled = too_small
		if too_small and tile.button_pressed:
			tile.set_pressed_no_signal(false)
			UiStyle.style_button(tile, "secondary", 22)


	if p:
		for page in [_local, _custom, _host, _direct, _room]:
			if page == _host and leader:
				continue
			if page != null and page.visible:
				_show(_home)
				break


func _unfold_party() -> void :
	var i: = 0
	for c in _party_strip.get_children():
		var ctrl: = c as Control
		if ctrl == null:
			continue
		ctrl.offset_transform_enabled = true
		ctrl.offset_transform_pivot_ratio = Vector2(0.5, 0.5)
		ctrl.offset_transform_scale = Vector2.ZERO
		var t: = ctrl.create_tween()
		t.tween_interval(0.04 * float(i))
		t.tween_property(ctrl, "offset_transform_scale", Vector2.ONE, 0.26)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		i += 1
	UiStyle.sfx("confirm")





func _slim_button(b: Button) -> void :
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var sb: = b.get_theme_stylebox(state)
		if sb == null:
			continue
		sb = sb.duplicate()
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		b.add_theme_stylebox_override(state, sb)
	b.custom_minimum_size.x = 0

func _party_disc(icon_name: String, color: Color, tip: String, 
		on_press: Callable, crown: = false, cfg: = {}) -> Control:
	if not on_press.is_valid():
		var disc: = _portrait_plate(cfg, color, 34.0, icon_name)
		disc.mouse_filter = Control.MOUSE_FILTER_PASS
		disc.tooltip_text = tip
		if not crown:
			return disc

		var wrap_box: = Control.new()
		wrap_box.custom_minimum_size = Vector2(34, 34)
		wrap_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		wrap_box.tooltip_text = tip
		disc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wrap_box.add_child(disc)
		var cr: = TextureRect.new()
		cr.texture = _crown_texture()
		cr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cr.custom_minimum_size = Vector2(24, 20)
		cr.size = Vector2(24, 20)
		cr.position = Vector2(5, -14)
		cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap_box.add_child(cr)
		return wrap_box
	var b: = Button.new()
	b.flat = true
	b.custom_minimum_size = Vector2(36, 36)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER




	var face_plate: = _portrait_plate(cfg, color, 34.0, icon_name)
	face_plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	face_plate.offset_left = 1
	face_plate.offset_top = 1
	face_plate.offset_right = -1
	face_plate.offset_bottom = -1
	b.add_child(face_plate)
	b.tooltip_text = tip
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(UiStyle.press_bounce.bind(b))
	UiStyle.hover_sound(b)
	b.pressed.connect(on_press)
	return b






const PARTY_CROWN_PATH: = "res://game/titles/art/crown.png"

func _crown_texture() -> Texture2D:
	if ResourceLoader.exists(PARTY_CROWN_PATH):
		return load(PARTY_CROWN_PATH)
	return null






func _portrait_plate(cfg: Dictionary, color: Color, size: float, icon_name: String) -> Control:
	var plate: = Panel.new()
	plate.custom_minimum_size = Vector2(size, size)
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var sb: = StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(int(size * 0.5))
	sb.corner_detail = 16
	plate.add_theme_stylebox_override("panel", sb)
	var face: = TextureRect.new()
	face.texture = UiStyle.icon_disc(icon_name, color, int(size), true)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.add_child(face)
	if not cfg.is_empty():
		_fill_portrait(face, cfg)
	return plate

func _fill_portrait(face: TextureRect, cfg: Dictionary) -> void :
	var tex: ImageTexture = await CharacterPortrait.head_cached(cfg, self, "lobby")
	if tex != null and is_instance_valid(face):
		face.texture = tex


func _party_add() -> void :
	if not Net.party:


		_start_party(_invite_to_party)
		return
	_invite_to_party()



func _party_member_menu(id: int) -> void :
	if not Net.is_host or id == 1 or not Net.players.has(id):
		return
	var pop: = PopupPanel.new()
	var box: = StyleBoxFlat.new()
	box.bg_color = UiStyle.card()
	box.set_corner_radius_all(10)
	box.set_content_margin_all(10)
	box.shadow_color = Color(0, 0, 0, 0.28)
	box.shadow_size = 8
	pop.add_theme_stylebox_override("panel", box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	var who: = Label.new()
	who.text = String(Net.players[id].get("name", "player"))
	UiStyle.style_label(who, "body")
	col.add_child(who)
	var kick: = _menu_btn("kick", "exit", func():


		_invited_ids.erase(int((Net.players[id] as Dictionary).get("sid", 0)))
		Net.kick_from_party(id)
		pop.hide())
	kick.add_theme_font_size_override("font_size", 14)
	kick.custom_minimum_size = Vector2(120, 38)
	col.add_child(kick)
	pop.add_child(col)
	add_child(pop)
	pop.popup_hide.connect( func(): pop.queue_free())
	var mp: = get_viewport().get_mouse_position()
	pop.popup(Rect2i(Vector2i(mp) + Vector2i(-10, 20), Vector2i.ZERO))
















func _party_member_menu_local(slot: LocalPlayerSlot) -> void :
	var pop: = PopupPanel.new()
	var box: = StyleBoxFlat.new()
	box.bg_color = UiStyle.card()
	box.set_corner_radius_all(10)
	box.set_content_margin_all(10)
	box.shadow_color = Color(0, 0, 0, 0.28)
	box.shadow_size = 8
	pop.add_theme_stylebox_override("panel", box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	var who: = Label.new()
	who.text = "%s  (%s)" % [slot.display_name(), slot.tag()]
	UiStyle.style_label(who, "body")
	col.add_child(who)
	for row in [["controls", "gamepad", func():
				_refresh_configs()
				_show(_configs)], 
			["locker", "star", func(): _open_guest_locker(slot)], 
			["remove", "exit", func(): LocalPlayers.leave(slot.device)]]:
		var b: = _menu_btn(String(row[0]), String(row[1]), func():
			(row[2] as Callable).call()
			pop.hide())
		b.add_theme_font_size_override("font_size", 14)
		b.custom_minimum_size = Vector2(150, 38)
		col.add_child(b)
	pop.add_child(col)
	add_child(pop)
	pop.popup_hide.connect( func(): pop.queue_free())
	var mp: = get_viewport().get_mouse_position()
	pop.popup(Rect2i(Vector2i(mp) + Vector2i(-10, 20), Vector2i.ZERO))

func _dock_chat(right: bool) -> void :
	if _chat == null:
		return
	var w: float = _chat.custom_minimum_size.x
	if right:
		_chat.anchor_left = 1.0
		_chat.anchor_right = 1.0
		_chat.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_chat.offset_right = -24.0
		_chat.offset_left = -24.0 - w
		_chat.offset_top = -240.0
		_chat.offset_bottom = -80.0
	else:
		_chat.anchor_left = 0.0
		_chat.anchor_right = 0.0
		_chat.grow_horizontal = Control.GROW_DIRECTION_END
		_chat.offset_left = 12.0
		_chat.offset_right = 12.0 + w
		_chat.offset_top = -206.0
		_chat.offset_bottom = -46.0

func _my_party_id() -> int:
	if Net.is_host:
		return 1


	if multiplayer == null or multiplayer.multiplayer_peer == null:
		return 0
	return multiplayer.get_unique_id()

func _on_freeplay_pose(peer_id: int, st: PackedFloat32Array) -> void :


	if not is_inside_tree() or not Net.party\
	or peer_id == _my_party_id() or not _is_party_member(peer_id):
		return
	_ensure_party_body(peer_id)



	_party_in_freeplay[peer_id] = st.size() > Player.NET_FLOATS\
	and st[Player.NET_FLOATS] > 0.5
	var now: = float(Time.get_ticks_msec())
	_party_puppets.add(peer_id, st, now)
	_party_seen[peer_id] = now

func _ensure_party_body(peer_id: int) -> void :
	if _party_bodies.has(peer_id):
		return
	var body: Player = PLAYER_SCENE.instantiate()
	add_child(body)




	body.net_puppet = true
	body.sim_authority = false
	body.charge_ui_enabled = false
	body.indicator_enabled = false


	body.collision_layer = 0
	body.collision_mask = 0
	var info: Dictionary = Net.players.get(peer_id, {})
	body.set_display_name(String(info.get("name", "friend")))
	body.set_dev_tag(DevBadge.peer_tier(peer_id))
	body.set_name_visible(false)
	body.global_position = HOME_SPOT
	_party_bodies[peer_id] = body
	_dress_party_body(body, peer_id)


func _dress_party_body(body: Player, peer_id: int) -> void :
	var info: Dictionary = Net.players.get(peer_id, {})

	var cfg_d: Dictionary = Mod.shown_cfg(peer_id, info.get("cfg", {}))
	if cfg_d.is_empty():
		return
	body.muted_here = Mod.hides(peer_id)
	var cfg: = CharacterConfig.from_dict(cfg_d)
	var fit: = CharacterConfig.outfit_fit(cfg, String(_party_outfit.get(peer_id, "gym")))
	body.set_character(fit[0], fit[1])

func _on_party_look(peer_id: int, outfit: String) -> void :
	_party_outfit[peer_id] = outfit
	if _party_bodies.has(peer_id):
		_dress_party_body(_party_bodies[peer_id], peer_id)


	_queue_party_strip()



var _party_strip_queued: = false

func _queue_party_strip() -> void :
	if _party_strip_queued:
		return
	_party_strip_queued = true
	( func():
		_party_strip_queued = false
		if is_inside_tree():
			_refresh_party_strip()).call_deferred()

func _on_party_ball(peer_id: int, skin: String) -> void :
	_party_ball_skin[peer_id] = skin


	if _party_balls.has(peer_id):
		(_party_balls[peer_id] as Ball).set_ball_skin(skin)



func _reconcile_party_bodies() -> void :
	for pid in _party_bodies.keys():
		if not Net.party or not _is_party_member(int(pid)):
			_free_party_body(int(pid))
	_reconcile_party_guests()
	_trim_refused_couch()






func _trim_refused_couch() -> void :
	if not Net.active or Net.is_host or Net.in_match:
		return
	if Time.get_ticks_msec() - Net.locals_pushed_ms < 1500:
		return
	var me: = _my_party_id()
	if me == 0 or not Net.players.has(me):
		return
	var kept: = Net.locals_of(me).size()
	var trimmed: = false
	while LocalPlayers.count() - 1 > kept and LocalPlayers.slots.size() > 1:
		LocalPlayers.leave(LocalPlayers.slots[LocalPlayers.slots.size() - 1].device)
		trimmed = true
	if trimmed:
		_flash_notice("party is full")



func _is_party_member(pid: int) -> bool:
	return Net.players.has(pid)\
	and not bool((Net.players[pid] as Dictionary).get("qjoin", false))

func _free_party_body(peer_id: int) -> void :
	if _party_bodies.has(peer_id):
		(_party_bodies[peer_id] as Node).queue_free()
		_party_bodies.erase(peer_id)
	if _party_balls.has(peer_id):
		if player != null and player.ball == _party_balls[peer_id]:
			player.ball = ball
			camera_rig.ball = ball
		(_party_balls[peer_id] as Node).queue_free()
		_party_balls.erase(peer_id)
	_party_puppets.forget(peer_id)
	_party_ball_buf.forget(peer_id)
	_party_seen.erase(peer_id)
	_ball_away.erase(peer_id)
	_ball_gen.erase(peer_id)



	_ball_driver.erase(peer_id)
	for bid in _ball_driver.keys():
		if int(_ball_driver[bid]) == peer_id:
			_ball_driver.erase(bid)
			var b: = _party_ball_for(int(bid))
			if b != null and _drives(int(bid)):
				_party_ball_buf.forget(int(bid))
				b.remote_driven = false
				b.show_landing_ring = true

func _clear_party_bodies() -> void :
	for pid in _party_bodies.keys():
		_free_party_body(int(pid))
	for key in _party_guest_bodies.keys():
		if is_instance_valid(_party_guest_bodies[key]):
			(_party_guest_bodies[key] as Node).queue_free()
	_party_guest_bodies.clear()
	_ball_driver.clear()
	_ball_away.clear()
	_ball_gen.clear()
	ball.remote_driven = false
	ball.show_landing_ring = true
	ball.outline_override = Color(0, 0, 0, 0)
	if player != null:
		_restore_my_ball()
		player.ball = ball if player.ball != null else null
		camera_rig.ball = ball

	for pid in _party_balls.keys():
		_free_party_body(int(pid))





func _on_ball_pose(peer_id: int, st: PackedFloat32Array, bid: int) -> void :
	if not is_inside_tree() or not Net.party\
	or peer_id == _my_party_id():
		return
	if not _is_party_member(peer_id):
		return



	if peer_id != bid and not _ball_shared(bid):
		return
	if _ball_away.has(bid):


		if Time.get_ticks_msec() - int(_ball_away[bid]) < 500:
			return
		_ball_away.erase(bid)
	if bid == _my_party_id() and not _ball_out:
		return
	var gen: = int(st[7]) if st.size() > 7 else 0
	var known: = int(_ball_gen.get(bid, 0))
	if gen < known:
		return
	if gen == known and _drives(bid) and peer_id > _my_party_id():
		return
	_ball_gen[bid] = gen
	var b: = _party_ball_for(bid)
	if b == null:
		return
	if _drives(bid):


		b.remote_driven = true
		b.show_landing_ring = false
	_ball_driver[bid] = peer_id


	_party_ball_buf.add(int(bid), st, float(Time.get_ticks_msec()))
	_party_seen[peer_id] = Time.get_ticks_msec()


func _party_ball_for(bid: int) -> Ball:
	if bid == _my_party_id():
		return ball
	if not _is_party_member(bid):
		return null
	_ensure_party_ball(bid)
	return _party_balls[bid]


func _drives(bid: int) -> bool:
	return int(_ball_driver.get(bid, bid)) == _my_party_id()



func _driven_balls() -> Dictionary:
	var out: = {}
	if _drives(_my_party_id()) and _ball_out:
		out[_my_party_id()] = ball
	for bid in _party_balls:
		if _drives(int(bid)):
			out[int(bid)] = _party_balls[bid]
	return out





func _take_party_ball(bid: int) -> void :
	var b: = _party_ball_for(bid)
	if b == null or _drives(bid) or not _ball_shared(bid):
		return
	_ball_driver[bid] = _my_party_id()
	_ball_gen[bid] = int(_ball_gen.get(bid, 0)) + 1
	_party_ball_buf.forget(bid)
	b.remote_driven = false
	b.show_landing_ring = true
	b.reset_physics_interpolation()

func _ensure_party_ball(peer_id: int) -> void :
	if _party_balls.has(peer_id):
		return
	var b: Ball = BALL_SCENE.instantiate()
	b.stage_ball = String(_party_ball_skin.get(peer_id, "nationals"))
	b.remote_driven = true
	b.net_puppet = not _ball_shared(peer_id)
	b.show_landing_ring = false
	add_child(b)
	b.fx = fx
	b.court_center_x = 0.0
	b.court_half_w = COURT_HW
	b.court_half_l = COURT_HL
	b.net_half_width = ball.net_half_width
	b.antenna_half_width = ball.antenna_half_width
	b.wall_min = ball.wall_min
	b.wall_max = ball.wall_max


	b.struck.connect( func(pos: Vector3, power: float, kind: int):
		_take_party_ball(peer_id)
		_play_contact_fx(pos, power, kind, b.vel, b.combo_tier, b.dig_weight, 
			b.strike_source == player)
		if Net.party and _freeplay:
			Net.send_freeplay_fx(kind, pos, power, b.vel))
	b.bounced.connect( func():
		if not _drives(peer_id):
			return
		var floor_pos: = Vector3(b.global_position.x, 0.06, b.global_position.z)
		sfx.play("hit_soft", b.global_position, -12.0, 0.75)
		fx.ring(floor_pos, Vector3.UP, clampf(b.vel.y * 0.12, 0.3, 0.9))
		fx.puff(floor_pos))
	_party_balls[peer_id] = b


func _party_leader_id() -> int:
	return 1

func _ball_shared(bid: int) -> bool:
	return _shared_ball_on and Net.party and bid == _party_leader_id()


func _party_ball() -> Ball:
	if not Net.party:
		return null
	if Net.is_host:
		return ball if _ball_out else null
	var pb: Ball = _party_balls.get(_party_leader_id())
	if pb == null or not is_instance_valid(pb) or not pb.visible:
		return null
	return pb



func _played_ball() -> Ball:
	if _ball_out:
		return ball
	var pb: = _party_ball()
	return pb if pb != null else ball





func _crosshair_cam() -> bool:
	return camera_rig.mode == CameraRig.Mode.ACTION\
	or camera_rig.mode == CameraRig.Mode.FIRST_PERSON

func _toss_aim(input: PlayerInput) -> Vector3:
	if not _crosshair_cam() or (player.serving and ball.frozen):
		return input.aim
	return Ball.action_toss_aim(player.global_position, input.aim)

func _toss_deadzone() -> float:
	return 0.5 if _crosshair_cam() else 1.5

func _has_ball_to_play() -> bool:
	return _ball_out or _party_ball() != null



func _spawn_my_ball() -> void :
	_ball_out = true
	_ball_auto_until = 0
	ball.visible = true
	_serving = true
	if Net.party:
		_take_party_ball(_my_party_id())
	_ball_driver.erase(_my_party_id())
	ball.remote_driven = false
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.global_position = player.serve_cradle_point()
	ball.reset_physics_interpolation()




func _spawn_practice_ball() -> void :
	_ball_out = true
	_ball_auto_until = 0
	_serving = false
	player.serve_charge_ui = false
	camera_rig.serve_view = false
	ball.visible = true
	if Net.party:
		_take_party_ball(_my_party_id())
	ball.remote_driven = false
	ball.frozen = false
	ball.vel = Vector3.ZERO
	ball.curve = 0.0
	ball.stop_float()
	ball.global_position = player.global_position + Vector3(0.0, 5.2, 0.0)
	ball.reset_physics_interpolation()

func _despawn_my_ball(announce: = true) -> void :
	if not _ball_out:
		return
	_ball_out = false
	_serving = false
	player.serve_charge_ui = false
	camera_rig.serve_view = false
	if _toss_preview != null:
		_toss_preview.clear()
	_ball_driver.erase(_my_party_id())
	_ball_gen.erase(_my_party_id())
	ball.remote_driven = false
	ball.frozen = true
	ball.vel = Vector3.ZERO
	ball.visible = false
	ball.global_position = BALL_PARK
	ball.reset_physics_interpolation()
	if announce and Net.party:
		Net.send_freeplay_fx(FX_BALL_AWAY, Vector3.ZERO, 0.0, Vector3.ZERO)



func _restore_my_ball() -> void :
	if _ball_out:
		return
	_ball_out = true
	ball.visible = true
	ball.frozen = false
	ball.vel = Vector3.ZERO
	ball.global_position = player.global_position + Vector3(0.6, 1.2, 0.3)
	ball.reset_physics_interpolation()



func _tick_my_ball(input: PlayerInput) -> void :
	var typing: bool = _chat != null and _chat.is_typing()
	var blocked: bool = typing or hud.pause_is_open() or (_tutorial != null and _tutorial.blocking_input())
	_p1_ball_input.exclude_pads = LocalPlayers.claimed_pads()
	_p1_ball_input.exclude_kbm = LocalPlayers.kbm_taken()
	_p1_ball_input.poll(BALL_ACTIONS)
	if not _shared_ball_on:
		if not blocked and _p1_ball_input.just_pressed("ball_spawn"):
			_spawn_practice_ball()
		elif not blocked and _ball_out		and _p1_ball_input.just_pressed("ball_despawn"):
			_despawn_my_ball()
		elif input.serve_pressed and not _serving:
			_spawn_my_ball()
		return
	_p1_ball_input.exclude_pads = LocalPlayers.claimed_pads()
	_p1_ball_input.exclude_kbm = LocalPlayers.kbm_taken()
	_p1_ball_input.poll(BALL_ACTIONS)
	if not blocked:
		if _p1_ball_input.just_pressed("ball_despawn") and _ball_out:
			_ball_auto_until = 0
			_despawn_my_ball()
		elif _p1_ball_input.just_pressed("ball_spawn"):
			_spawn_practice_ball()
	var now: = Time.get_ticks_msec()
	var member: bool = Net.party and not Net.is_host

	if member and _ball_out and not _serving and now < _ball_auto_until and _party_ball() != null:
		_ball_auto_until = 0
		_despawn_my_ball()


	if not _ball_out and member and _party_ball() == null:
		if _no_party_ball_ms == 0:
			_no_party_ball_ms = now
		elif now - _no_party_ball_ms > 1500:
			_restore_my_ball()
	else:
		_no_party_ball_ms = 0

	var play: = _played_ball()
	if player.ball != play:
		player.ball = play
		camera_rig.ball = play


func _ball_prompt() -> String:
	if not _shared_ball_on:
		return "press %s to take the ball in hand" % HowToPlay.keys_for("serve")
	var key: = HowToPlay.keys_for("ball_spawn")
	if not _ball_out:
		if _party_ball() != null:
			return ""
		return "press %s to spawn your ball" % key
	return "press %s to take the ball in hand" % key


func _play_contact_fx(pos: Vector3, power: float, kind: int, vel: Vector3, 
		combo_tier: = 0, dig_weight: = 0.0, mine: = false) -> void :
	if fx == null or sfx == null:
		return
	var strength: = Rules.contact_strength(kind, power)
	var snd: = Rules.contact_sound(kind, power)




	var fast_dig: = Player.is_fast_dig(kind, dig_weight)
	if fast_dig:
		snd = {"n": "hit_hard", "db": lerpf(-2.0, 2.0, dig_weight), "pt": 0.96}
		strength = maxf(strength, 1.0) * 1.35
		fx.big_spike(pos, vel, Player.combo_color(1), 1)
		if mine and camera_rig != null:
			camera_rig.shake(minf(0.12 + dig_weight * 0.3, 0.4))
	sfx.play(String(snd["n"]), pos, float(snd["db"]), float(snd["pt"]))

	if combo_tier >= 1:
		sfx.play("spike_combo", pos, 0.0, 1.0 + 0.06 * float(combo_tier - 1))
	if kind == Player.TouchKind.SPIKE and power > 0.8:
		fx.big_spike(pos, vel)
	Rules.contact_fx(fx, pos, strength, vel, 0.0, true, kind, combo_tier)


func _poll_freeplay_callouts() -> void :

	if _chat != null and _chat.is_typing():
		return
	if hud.pause_is_open() or (_tutorial != null and _tutorial.blocking_input()):
		return


	for g in _local_guests:
		var gp: Player = g.get("player")
		var slot: LocalPlayerSlot = g.get("slot")
		if gp == null or not is_instance_valid(gp) or slot == null or not slot.connected:
			continue
		var r: DeviceInput = _callout_polls.get(slot.device)
		if r == null:
			r = DeviceInput.new(slot.device)
			_callout_polls[slot.device] = r
		r.device = slot.device
		r.poll(CALLOUT_ACTIONS)
		for i in CALLOUT_ACTIONS.size():
			if r.just_pressed(CALLOUT_ACTIONS[i]):

				if gp.quick_chat(Player.QUICK_CHAT[i], false) == Player.CallResult.OK:
					_guest_earn(slot, "quick_chat")
				break
	_p1_callout.exclude_pads = LocalPlayers.claimed_pads()
	_p1_callout.exclude_kbm = LocalPlayers.kbm_taken()
	_p1_callout.poll(CALLOUT_ACTIONS)
	for i in CALLOUT_ACTIONS.size():
		if _p1_callout.just_pressed(CALLOUT_ACTIONS[i]):
			_freeplay_call(Player.QUICK_CHAT[i])
			break




func _freeplay_call(idx: int) -> void :
	var said: = player.quick_chat(idx, false)
	if said == Player.CallResult.OK:
		Achievements.notify("quick_chat")
		Net.send_freeplay_fx(FX_CALLOUT, player.global_position, 0.0, 
			Vector3(float(idx), float(player.last_call_variant), 0.0))
	elif said != Player.CallResult.REFUSED and Player.CALLOUT_GESTURES.has(idx):

		Net.send_freeplay_fx(FX_CALLOUT, player.global_position, 0.0, 
			Vector3(float(idx), float(player.last_gesture_variant), 1.0))
	if said == Player.CallResult.COOLING and sfx != null:
		sfx.play("reach_miss", player.global_position, -8.0)

func _fp_ball_script() -> void :
	await get_tree().create_timer(7.0).timeout
	_despawn_my_ball()
	await get_tree().create_timer(2.5).timeout
	var pb: = _party_ball()
	if pb != null:

		pb.vel = Vector3(0.0, 7.0, 0.0)
		pb.struck.emit(pb.global_position, 0.5, Player.TouchKind.BUMP)
	await get_tree().create_timer(3.0).timeout
	_spawn_my_ball()
	_serving = false
	ball.frozen = false
	ball.toss(player.serve_cradle_point(), 6.0)
	await get_tree().create_timer(3.0).timeout
	_despawn_my_ball()

func _fp_call_spam() -> void :
	await get_tree().create_timer(9.0).timeout
	for i in 10:
		if _freeplay and player != null:
			_freeplay_call(0)
		await get_tree().create_timer(0.15).timeout

func _fp_call_loop(idx: int) -> void :
	for i in 6:
		await get_tree().create_timer(2.5).timeout
		if _freeplay and player != null:
			_freeplay_call(idx)

func _on_freeplay_fx(peer_id: int, kind: int, pos: Vector3, power: float, 
		vel: Vector3) -> void :
	if kind == FX_BALL_AWAY:



		if Net.party and peer_id != _my_party_id() and _is_party_member(peer_id):
			_ball_away[peer_id] = Time.get_ticks_msec()
			_ball_gen.erase(peer_id)
			_ball_driver.erase(peer_id)
			_party_ball_buf.forget(peer_id)
			var gone: Ball = _party_balls.get(peer_id)
			if gone != null and is_instance_valid(gone):
				gone.visible = false
				gone.remote_driven = true
				gone.show_landing_ring = false
		return


	if not is_inside_tree() or not Net.party or not _freeplay\
	or peer_id == _my_party_id():
		return
	if kind == FX_CALLOUT:



		var caller: = _party_bodies.get(peer_id) as Player
		if caller != null and is_instance_valid(caller) and caller.visible:
			if vel.z > 0.5:
				caller.gesture_call(roundi(vel.x), 
					clampi(roundi(vel.y), -1, Player.CALL_VARIANTS - 1))
			else:
				caller.quick_chat(roundi(vel.x), false, Player.CALL_SLACK_MS, 
					clampi(roundi(vel.y), 0, Player.CALL_VARIANTS - 1))
		return
	if kind == -1:

		if fx != null:
			fx.ring(pos, Vector3.UP, 1.15 * power)
			fx.puff(pos)
		if sfx != null:
			sfx.play("hit_soft", pos, -4.0, 1.35)
		return
	if kind == -2:

		if fx != null:
			Rules.contact_fx(fx, pos, power, Vector3.UP, 0.0)
			fx.puff(pos)
		if sfx != null:
			sfx.play("hit_soft", pos, -2.0, 0.55)
		return
	if kind == -3:

		if sfx != null:
			sfx.play("swing", pos, -5.0, 1.0)
		return
	if kind == -4:

		if fx != null:
			fx.land_poof(pos)
			fx.floor_gust(pos, true)
		if sfx != null:
			sfx.play("block_soft", pos, -1.0, 0.75)
			sfx.play("squash", pos, 0.0, 1.0)
		return
	if kind == Player.TouchKind.CAROM:




		var near: Player = null
		var near_d: = 1.2
		for b in [player] + _party_live_bodies():
			var body: Player = b
			if body == null or not is_instance_valid(body):
				continue
			var d: = Vector2(body.global_position.x - pos.x, 
				body.global_position.z - pos.z).length()
			if d < near_d:
				near_d = d
				near = body
		if near != null:
			near.show_float_text("missed", Player.CAROM_COLOR, true, 1.0, false, true)
			if near == player:
				camera_rig.shake(0.08 + 0.18 * power)

	_play_contact_fx(pos, power, kind, vel, 1 if kind == Player.TouchKind.SPIKE else 0)




func _drive_menu_camera(delta: float) -> void :
	if player == null:
		return
	var n: int = _fake_party_n if _fake_party_n > 0\
	else PartySeats.count()
	var t: = clampf(float(n - 1) / 5.0, 0.0, 1.0)
	var tgt_pos: Vector3 = HOME_SPOT + Vector3(-0.78, 1.35, 3.7).lerp(
		Vector3(-2.4, 2.5, 6.6), t)
	var tgt_look: Vector3 = HOME_SPOT + Vector3(-1.15, 1.0, 0.0).lerp(
		Vector3(-2.6, 1.1, -0.7), t)
	var tgt_fov: = lerpf(50.0, 55.0, t)
	var k: = clampf(delta * 3.5, 0.0, 1.0)
	menu_cam.global_position = menu_cam.global_position.lerp(tgt_pos, k)
	menu_cam.fov = lerpf(menu_cam.fov, tgt_fov, k)
	_cam_look_now = _cam_look_now.lerp(tgt_look, k)
	menu_cam.look_at(_cam_look_now)

	var to_cam: = menu_cam.global_position - player.global_position
	_base_yaw = atan2(to_cam.x, to_cam.z) - 0.38
	player.visual.rotation.y = _base_yaw + _spin








func _drive_lineup(delta: float) -> void :
	for seat in PartySeats.list():
		if int(seat.spot) == 0:
			continue
		var spot: Vector3 = HOME_SPOT\
		+ PARTY_SPOTS[mini(int(seat.spot), PARTY_SPOTS.size() - 1)]
		var to_cam: = menu_cam.global_position - spot
		var yaw: = atan2(to_cam.x, to_cam.z) - 0.38
		if String(seat.kind) == "remote":
			var pid: = int(seat.peer)
			_ensure_party_body(pid)
			_ensure_party_ball(pid)
			var body: = _party_bodies[pid] as Player
			body.visible = true
			body.set_name_visible(false)
			body.global_position = spot
			body.velocity = Vector3.ZERO
			body.visual.rotation.y = yaw
			body.puppet_tick(delta)
			var b: = _party_balls[pid] as Ball
			b.visible = true
			b.global_position = spot + Vector3(-0.45, 0.4, 0.5)
			continue
		if String(seat.kind) == "remote_local":
			_stand_guest_puppet(seat, spot, yaw, delta, false)
			continue
		var gp: = _guest_body(seat.slot)
		if gp == null:
			continue



		gp.global_position = spot
		gp.velocity = Vector3.ZERO
		gp.visual.rotation.y = yaw
		gp.aim_point = _aim_at_cam
		gp.puppet_tick(delta)



func _stand_guest_puppet(seat: Dictionary, spot: Vector3, yaw: float, delta: float, 
		named: bool) -> void :
	var body: = _ensure_party_guest_body(int(seat.peer), int(seat.ls), 
		seat.get("cfg", {}), String(seat.name))
	body.visible = _drill_active == ""
	body.set_name_visible(named)
	body.global_position = spot
	body.velocity = Vector3.ZERO
	body.visual.rotation.y = yaw
	body.puppet_tick(delta)

func _ensure_party_guest_body(peer: int, ls: int, cfg_d: Dictionary, nm: String) -> Player:
	var key: = Net.seat_key(peer, ls)
	if _party_guest_bodies.has(key) and is_instance_valid(_party_guest_bodies[key]):
		return _party_guest_bodies[key]
	var body: Player = PLAYER_SCENE.instantiate()
	add_child(body)

	body.net_puppet = true
	body.sim_authority = false
	body.charge_ui_enabled = false
	body.indicator_enabled = false
	body.collision_layer = 0
	body.collision_mask = 0
	body.set_display_name(nm)
	body.set_name_visible(false)
	body.global_position = HOME_SPOT

	cfg_d = Mod.shown_cfg(peer, cfg_d)
	body.muted_here = Mod.hides(peer)
	if not cfg_d.is_empty():
		var cfg: = CharacterConfig.from_dict(cfg_d)

		match String(_party_outfit.get(peer, "gym")):
			"captain", "home", "away":
				body.set_character(cfg, TeamKits.normalize(cfg.captain_kit))
			_:
				body.set_character(cfg.gym_look(), cfg.gym_kit())
	_party_guest_bodies[key] = body
	return body



func _reconcile_party_guests() -> void :
	var want: = {}
	if Net.party:
		for seat in PartySeats.list():
			if String(seat.kind) == "remote_local":
				want[Net.seat_key(int(seat.peer), int(seat.ls))] = true
	for key in _party_guest_bodies.keys():
		if not want.has(key):
			if is_instance_valid(_party_guest_bodies[key]):
				(_party_guest_bodies[key] as Node).queue_free()
			_party_guest_bodies.erase(key)


func _guest_body(slot: LocalPlayerSlot) -> Player:
	for g in _local_guests:
		if g["slot"] == slot and is_instance_valid(g["player"]):
			return g["player"]
	return null



func _drive_party_freeplay(delta: float) -> void :
	var now: = float(Time.get_ticks_msec())

	var spots: = {}
	for seat in PartySeats.list():
		var spot: Vector3 = HOME_SPOT\
		+ PARTY_SPOTS[mini(int(seat.spot), PARTY_SPOTS.size() - 1)]
		if String(seat.kind) == "remote":
			spots[int(seat.peer)] = spot
		elif String(seat.kind) == "remote_local":


			var to_cam: = (camera_rig.camera.global_position if camera_rig.camera != null\
			else spot + Vector3(0, 0, 4)) - spot
			_stand_guest_puppet(seat, spot, atan2(to_cam.x, to_cam.z), delta, true)
	for pid in _party_bodies.keys():







		var here: bool = _party_in_freeplay.get(pid, false)
		var show_body: bool = _drill_active == ""
		var body: = _party_bodies[pid] as Player
		body.visible = show_body


		body.set_name_visible(show_body)



		var mine: Ball = _party_balls.get(pid)
		if body.ball != mine:
			body.ball = mine
		if show_body and not here and spots.has(int(pid)):





			var spot: Vector3 = spots[int(pid)]
			var to_cam: = (camera_rig.camera.global_position if camera_rig.camera != null\
			else spot + Vector3(0, 0, 4)) - spot
			body.global_position = spot
			body.velocity = Vector3.ZERO
			body.visual.rotation.y = atan2(to_cam.x, to_cam.z)
			body.puppet_tick(delta)
		elif show_body:

			_party_puppets.drive(int(pid), body, now, delta)


			body.team_side = 1 if body.global_position.z >= 0.0 else -1
		if _party_balls.has(pid):
			var b: = _party_balls[pid] as Ball


			b.visible = (here or _drives(int(pid))) and not _ball_away.has(int(pid))
			var shared: = _ball_shared(int(pid))
			b.net_puppet = not shared
			b.outline_override = PARTY_BALL_OUTLINE if shared else Color(0, 0, 0, 0)
			if b.remote_driven and b.visible:

				_party_ball_buf.drive(int(pid), b, now, delta)

	if ball.remote_driven:
		_party_ball_buf.drive(_my_party_id(), ball, now, delta)

	ball.outline_override = PARTY_BALL_OUTLINE if _ball_shared(_my_party_id())\
	else Color(0, 0, 0, 0)



func _party_live_bodies() -> Array:
	var out: Array = []
	if Net.party and _freeplay:
		for pid in _party_bodies.keys():
			if _party_in_freeplay.get(pid, false):
				out.append(_party_bodies[pid])
	return out



func _local_guest_bodies() -> Array:
	var out: Array = []
	if not _freeplay:
		return out
	for g in _local_guests:
		var b = g.get("player")
		if b != null and is_instance_valid(b):
			out.append(b)
	return out




func _maybe_resume_home_party() -> void :
	if Net.home_party.is_empty():
		return





	if Net.in_match:
		return
	QuickPlay.qlog("resume home party: leader=%s active=%s party=%s room=%s" % [
		str(Net.home_party.get("is_leader", false)), str(Net.active), str(Net.party), 
		str(Net.home_party.get("room", false))])
	if Net.active:
		if Net.party:
			Net.home_party = {}
			return



		if bool(Net.home_party.get("room", false)):
			return




		Net.leave()
	var hp: Dictionary = Net.home_party
	Net.home_party = {}
	_in_party_room = false
	if bool(hp.get("is_leader", false)):






		Net.party_home_tokens[int(hp.get("token", 0))] = true
		var err: = Net.host_party(Net.local_display_name(), 
			bool(hp.get("lan", false)), true)

		if err == OK and int(hp.get("block", 0)) > 1:
			Net.party_expect = {"count": int(hp.get("block", 0)), 
				"until": Time.get_ticks_msec() + 25000}
		if err == OK:
			_refresh_party_strip()
			if int(hp.get("block", 0)) > 1:

				_home_notice = {"count": int(hp.get("block", 0)), 
					"until": Time.get_ticks_msec() + int((REGROUP_WINDOW + 5.0) * 1000.0)}
			else:
				_flash_notice("party back together")
		elif err == ERR_UNAVAILABLE:
			_flash_notice(Net.steam_status_text())
	else:




		_reform_target = hp
		_reform_left = REGROUP_WINDOW
		_reform_wait = 0.5
		_refresh_party_strip()
		QuickPlay.qlog("re-forming: dialling leader %s/%d for %.0fs" % [
			String(hp.get("leader_ip", "")), int(hp.get("leader_sid", 0)), REGROUP_WINDOW])


func _party_reforming() -> bool:
	return not Net.party and not _reform_target.is_empty()




func _party_away_mates() -> Array:



	if _party_reforming():
		var back: Variant = _reform_target.get("mates", [])
		return back if back is Array and (back as Array).size() > 1 else []
	var hp: Dictionary = Net.home_party
	if hp.is_empty() or bool(hp.get("room", false)) or not Net.active:
		return []
	var mates: Variant = hp.get("mates", [])
	return mates if mates is Array and (mates as Array).size() > 1 else []





func _party_room_mates() -> Array:
	var hp: Dictionary = Net.home_party
	if hp.is_empty() or not bool(hp.get("room", false)) or not Net.active or Net.party:
		return []
	var here: = {}
	for pid in Net.players:
		here[String((Net.players[pid] as Dictionary).get("name", ""))] = true
	var out: Array = []
	var mates: Variant = hp.get("mates", [])
	if mates is Array:
		for m in mates:
			if m is Dictionary and here.has(String((m as Dictionary).get("name", ""))):
				out.append(m)
	return out if out.size() > 1 else []





func _regroup_with_leader() -> bool:
	var hp: Dictionary = Net.home_party
	if hp.is_empty() or bool(hp.get("is_leader", false))\
	or bool(hp.get("room", false)) or Net.in_match:
		return false
	Net.home_party = {}
	_reform_target = hp
	_reform_left = REGROUP_WINDOW
	_reform_wait = REGROUP_FIRST_DIAL
	_fold_dial_t = 0.0
	_clear_party_bodies()
	_refresh_party_strip()
	_flash_notice("regrouping your party...")
	return true





func _watch_fold_dial(delta: float) -> void :
	var hp: Dictionary = Net.home_party
	if not Net.active or Net.is_host or not Net.players.is_empty() or hp.is_empty()\
	or bool(hp.get("is_leader", false)) or bool(hp.get("room", false)):
		_fold_dial_t = 0.0
		return
	_fold_dial_t += delta
	if _fold_dial_t >= QuickPlay.EMPTY_FOLD_GIVEUP:
		QuickPlay.qlog("member fold dial never landed (%.0fs): regrouping" % _fold_dial_t)
		_fold_dial_t = 0.0
		if _regroup_with_leader():
			Net.leave()


func _check_home_notice() -> void :
	if _home_notice.is_empty():
		return
	if not Net.party or Time.get_ticks_msec() > int(_home_notice.get("until", 0)):
		_home_notice = {}
		return
	if Net.party_members().size() >= int(_home_notice.get("count", 0)):
		_home_notice = {}
		_flash_notice("party back together")



func _drive_reform(delta: float) -> void :
	if Net.party:
		_reform_target = {}
		_refresh_party_strip()
		_flash_notice("party back together")
		return
	_reform_left -= delta
	if _reform_left <= 0.0:
		_reform_target = {}
		Net.quick_party_token = 0
		if Net.active:
			Net.leave()
		_refresh_party_strip()
		_flash_notice("couldn't rejoin your party")
		return
	if Net.active:


		if not Net.is_host and Net.players.is_empty():
			_reform_dial_t += delta
			if _reform_dial_t >= REFORM_DIAL_GIVEUP:
				QuickPlay.qlog("reform dial never landed (%.0fs): dialling again" % _reform_dial_t)
				_reform_dial_t = 0.0
				Net.leave()
		return
	_reform_dial_t = 0.0
	if _reform_wait > 0.0:
		_reform_wait -= delta
		return
	_reform_wait = REFORM_RETRY_GAP
	var sid: = int(_reform_target.get("leader_sid", 0))
	var ip: = String(_reform_target.get("leader_ip", ""))


	Net.quick_join_modes = []
	Net.quick_party_token = int(_reform_target.get("token", 0))
	Net.quick_party_block = 0
	QuickPlay.qlog("reform dial -> %s/%d (%.0fs left)" % [ip, sid, _reform_left])

	if bool(_reform_target.get("lan", false)) and ip != "":
		Net.join_game(ip, Net.local_display_name())
	elif sid != 0:


		if Net.steam_transport_available():
			Net.join_game_steam(sid, Net.local_display_name())
		else:
			_reform_target = {}
			_refresh_party_strip()
			_flash_notice(Net.steam_status_text())
	elif ip != "":
		Net.join_game(ip, Net.local_display_name())
	else:
		_reform_target = {}
		_refresh_party_strip()


func _start_party(then: = Callable()) -> void :
	if MobileRender.enabled():
		_flash_notice("Online is not connected yet")
		return
	if not OnlineTerms.require(_start_party.bind(then)):
		return

	_cancel_search()

	Net.home_party = {}
	_reform_target = {}
	Net.quick_party_token = 0
	_invited_ids = {}




	var lan: = (_dev_shortcuts() and Input.is_key_pressed(KEY_SHIFT)) or _harness_lan()
	if not lan and not Net.steam_transport_available():
		_flash_notice(Net.steam_status_text())
		return
	var err: = Net.host_party(Net.local_display_name(), lan)
	if err != OK:
		_flash_notice("couldn't start a party (error %d)" % err)
	else:


		_flash_notice("created lan party · direct join by ip" if lan\
		else "created new party · invite friends")
		if then.is_valid():
			then.call()
	_refresh_party_strip()

func _on_party_joined() -> void :


	if _freeplay or _practice_on:
		_leave_freeplay_for_session()
		_show(_home)


	var leader: = String((Net.players.get(1, {}) as Dictionary).get("name", ""))


	if _reform_target.is_empty():
		_flash_notice("joined %s's party" % leader if leader != "" else "joined the party")

	Net.send_party_look(_outfit)
	Net.send_party_ball(_ball_skin)



	_refresh_party_strip()

func _leave_party() -> void :
	_invited_ids = {}


	_cancel_search()
	if Net.party:
		Net.leave()
	else:
		LocalPlayers.reset_to_primary()
	_refresh_party_strip()


func _toggle_party_privacy() -> void :
	if not (Net.party and Net.is_host):
		return
	var nxt: int = Net.PartyPriv.PRIVATE\
	if Net.party_privacy == Net.PartyPriv.OPEN else Net.PartyPriv.OPEN
	Net.set_party_privacy(nxt)
	_flash_notice("party is open: anyone in it can invite"\
	if nxt == Net.PartyPriv.OPEN else "party is private: only you can invite")
	_refresh_party_strip()

func _invite_to_party() -> void :
	if not Net.party:
		_flash_notice("not in a party yet - press create party first")
		return
	if not Net.can_invite_to_party():
		_flash_notice("private party: only the leader can invite")
		return





	if not (multiplayer.multiplayer_peer is ENetMultiplayerPeer):
		if Net.is_host and Net.steam_lobby_id == 0:

			_flash_notice("your party is still opening, try again in a second")
		elif not (Net.is_host and Net.steam_invite_overlay()):

			_open_friends_for_invite()
		return

	if not Net.is_host:
		Net.request_party_invite(0)
		return
	_flash_notice(_lan_join_hint(_lan_ip()))


func _lan_join_hint(ip: String) -> String:
	return "friend joins: local > join lan > %s" % ip


func _on_party_invite_result(sid: int, ok: bool, reason: String) -> void :
	if not ok:
		_flash_notice(reason if reason != "" else "couldn't invite them")
		if sid != 0:
			_invited_ids.erase(sid)
		_refresh_friends_panel()
		return
	if sid == 0:

		var ip: String = Net._last_join_ip if not Net.is_host else _lan_ip()
		_flash_notice(_lan_join_hint(ip if ip != "" else "the leader's lan ip"))
		return
	_invited_ids[sid] = Time.get_ticks_msec()
	_flash_notice("invite sent")
	_refresh_friends_panel()

func _lan_ip() -> String:

	var best: = ""
	var alt: = ""
	for a in IP.get_local_addresses():
		if a.begins_with("192.168."):
			best = a
		elif (a.begins_with("10.") or a.begins_with("172.")) and alt == "":
			alt = a
	return best if best != "" else (alt if alt != "" else "your lan ip")


func _flash_notice(text_in: String) -> void :
	if AppData.is_harness():
		print("[notice %d] %s" % [Time.get_ticks_msec(), text_in])
	var t: = UiStyle.toast("heads up", text_in, UiStyle.SECONDARY, "information")
	ui.add_child(t)
	t.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)


	var y: = 108.0
	for o in _notice_stack:
		if is_instance_valid(o):
			y = maxf(y, o.position.y + maxf(o.size.y, o.get_combined_minimum_size().y) + 8.0)
	t.position.y = y
	_notice_stack.append(t)
	t.modulate.a = 0.0
	var tw: = t.create_tween()
	tw.tween_property(t, "modulate:a", 1.0, 0.2)
	tw.tween_interval(4.0)
	tw.tween_property(t, "modulate:a", 0.0, 0.4)
	tw.tween_callback( func():
		_notice_stack.erase(t)
		t.queue_free())
	UiStyle.sfx("open")




const WIDE_PAGE_X: = 16

func _build_browse() -> void :
	var v: = _box(_browse)


	_browse.position.x = WIDE_PAGE_X
	v.custom_minimum_size.x = 730
	v.add_theme_constant_override("separation", 10)
	_hero_head(v, "server browser", true)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	_bw_search = LineEdit.new()
	_bw_search.placeholder_text = "search by name or code..."
	_bw_search.custom_minimum_size = Vector2(0, 46)
	_bw_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bw_search.clear_button_enabled = true
	UiStyle.style_line_edit(_bw_search)

	_bw_search.text_changed.connect( func(_t):
		_bw_search_gen += 1
		var gen: = _bw_search_gen
		get_tree().create_timer(0.18).timeout.connect( func():
			if gen == _bw_search_gen and is_inside_tree():
				_apply_browse_filters()))
	_bw_search.text_submitted.connect( func(_t): _on_join_code(_t))
	top.add_child(_bw_search)


	var create: = Button.new()
	create.text = "create server"
	create.custom_minimum_size = Vector2(170, 46)
	UiStyle.style_button(create, "primary", 20)
	create.pressed.connect( func():
		_cancel_search()
		_show(_host))
	top.add_child(create)
	var refresh: = Button.new()
	refresh.text = "refresh"
	refresh.custom_minimum_size = Vector2(130, 46)
	UiStyle.style_button(refresh, "secondary", 20)
	refresh.pressed.connect(_refresh_browser)
	top.add_child(refresh)
	v.add_child(top)

	var body: = HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var scroll: = ScrollContainer.new()


	scroll.custom_minimum_size = Vector2(486, 250)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UiStyle.style_scroll(scroll.get_v_scroll_bar())
	_browse_list = VBoxContainer.new()
	_browse_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_browse_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_browse_list)
	body.add_child(scroll)
	body.add_child(_build_browse_filters())
	v.add_child(body)
	_browse_hint = _online_status()
	v.add_child(_browse_hint)




	_back_row(v, func():
		if _bw_joining:
			_cancel_browse_join()
		_show(_online))
	var join_row: = v.get_meta("foot") as HBoxContainer
	_bw_code = LineEdit.new()
	_bw_code.placeholder_text = "join by lobby code"
	_bw_code.custom_minimum_size = Vector2(0, 46)
	_bw_code.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_line_edit(_bw_code)
	_field_input(_bw_code)
	_bw_code.text_submitted.connect( func(t): _on_join_code(t))
	join_row.add_child(_bw_code)
	_bw_join_btn = Button.new()
	_bw_join_btn.text = "join"
	_bw_join_btn.custom_minimum_size = Vector2(150, 46)
	UiStyle.style_button(_bw_join_btn, "blue", 22)
	_bw_join_btn.pressed.connect( func(): _on_join_code(_bw_code.text))
	join_row.add_child(_bw_join_btn)


	_bw_cancel = Button.new()
	_bw_cancel.text = "cancel"
	_bw_cancel.custom_minimum_size = Vector2(150, 46)
	UiStyle.style_button(_bw_cancel, "danger", 22)
	_bw_cancel.visible = false
	_bw_cancel.pressed.connect( func(): _cancel_browse_join("join cancelled"))
	join_row.add_child(_bw_cancel)


	Net.invite_join_failed.connect( func(reason: String):
		if _bw_joining:
			_cancel_browse_join(reason)
		else:

			_flash_notice(reason))




func _set_browse_joining(on: bool) -> void :
	_bw_joining = on
	if _bw_cancel != null:
		_bw_cancel.visible = on
	if _bw_join_btn != null:
		_bw_join_btn.visible = not on

func _cancel_browse_join(why: = "") -> void :
	_join_gen += 1
	Net.cancel_code_join()


	if Net.active and not Net.in_match and not Net.party and Net.players.is_empty():
		_bw_quiet_leave = true
		Net.leave()
		_bw_quiet_leave = false
	_joining_live = false
	Net.join_password = ""
	_set_browse_joining(false)
	if _browse_hint != null:
		_browse_hint.text = why


func _field_input(le: LineEdit) -> void :
	for st in ["normal", "focus"]:
		var sb: = (le.get_theme_stylebox(st) as StyleBoxFlat).duplicate() as StyleBoxFlat
		sb.bg_color = UiStyle.card()
		sb.set_corner_radius_all(UiStyle.CAPSULE)
		sb.content_margin_left = 22.0
		le.add_theme_stylebox_override(st, sb)


func _build_browse_filters() -> Control:
	var card: = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiStyle.flat_box(UiStyle.sunk(), UiStyle.RADIUS_SOFT))
	card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var pad: = MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + m, 14)
	card.add_child(pad)
	var col: = VBoxContainer.new()
	col.custom_minimum_size.x = 196
	col.add_theme_constant_override("separation", 10)
	pad.add_child(col)
	var head: = Label.new()
	head.text = "filters"
	UiStyle.style_label(head, "body", UiStyle.SECONDARY)
	col.add_child(head)
	_bw_region = UiSelect.new(BW_REGIONS)




	_bw_region.selected = BW_REGIONS.size() - 1
	_bw_region.picked.connect( func(_i): _apply_browse_filters())
	col.add_child(_labeled("region", _bw_region))
	_bw_sort = UiSelect.new(["lowest ping", "most players", "fewest players"])
	_bw_sort.selected = 0
	_bw_sort.picked.connect( func(_i): _apply_browse_filters())
	col.add_child(_labeled("sort by", _bw_sort))
	_bw_full = _filter_check("show full matches", true)
	col.add_child(_bw_full)
	_bw_friends = _filter_check("friends only", false)
	col.add_child(_bw_friends)
	_bw_auto = _filter_check("auto refresh", false)
	col.add_child(_bw_auto)
	return card


func _filter_check(text: String, on: bool) -> CheckBox:
	var cb: = CheckBox.new()
	cb.text = text
	cb.button_pressed = on
	UiStyle.style_check(cb)
	cb.toggled.connect( func(_p): _apply_browse_filters())
	return cb

func _build_host() -> void :
	var v: = _box(_host)
	_hero_head(v, "custom lobby", true)


	_priv_opt = UiSelect.new(["public", "friends only", "private"])
	v.add_child(_labeled("who can join", _priv_opt))


	var player_labels: Array = []
	for n in MAX_PLAYER_CHOICES:
		player_labels.append("%d players" % n)
	_max_players_opt = UiSelect.new(player_labels)
	_max_players_opt.selected = MAX_PLAYER_CHOICES.find(Net.MAX_PLAYERS)
	v.add_child(_labeled("max players", _max_players_opt))
	_pw_edit = LineEdit.new()
	_pw_edit.secret = true
	_pw_edit.placeholder_text = "password"
	_pw_edit.custom_minimum_size = Vector2(0, 44)
	UiStyle.style_line_edit(_pw_edit)
	_pw_edit.visible = false
	_priv_opt.picked.connect( func(i: int):
		_pw_edit.visible = i == Net.Priv.PASSWORD)
	v.add_child(_pw_edit)
	_host_steam_card = _card_btn("massiveMultiplayer", "host on steam", 
		"", "primary", _on_host_steam)
	v.add_child(_host_steam_card)


	_host_party_card = _card_btn("multiplayer", "open lobby with party", 
		"", "primary", _on_host_steam)
	_host_party_card.visible = false
	v.add_child(_host_party_card)

	_host_status = _online_status()
	v.add_child(_host_status)
	_back_row(v, func(): _show(_online))

func _build_direct() -> void :
	var v: = _box(_direct)
	_hero_head(v, "join lan", true)
	var hint: = Label.new()
	hint.text = "join a lan host by address"
	UiStyle.style_label(hint, "small")
	v.add_child(hint)
	var join_row: = HBoxContainer.new()
	join_row.add_theme_constant_override("separation", 10)
	_ip_edit = LineEdit.new()
	_ip_edit.placeholder_text = "127.0.0.1"
	_ip_edit.custom_minimum_size = Vector2(0, 46)
	_ip_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_line_edit(_ip_edit)
	join_row.add_child(_ip_edit)
	var join_btn: = Button.new()
	join_btn.text = "join"
	join_btn.custom_minimum_size = Vector2(110, 46)
	UiStyle.style_button(join_btn, "primary", 22)
	join_btn.pressed.connect(_on_join)
	join_row.add_child(join_btn)
	v.add_child(join_row)
	_direct_pw = LineEdit.new()
	_direct_pw.secret = true
	_direct_pw.placeholder_text = "password (if the room has one)"
	_direct_pw.custom_minimum_size = Vector2(0, 44)
	UiStyle.style_line_edit(_direct_pw)
	v.add_child(_direct_pw)
	_direct_status = _online_status()
	v.add_child(_direct_status)
	_back_row(v, func(): _show(_local_choose))

func _build_room() -> void :




	var v: = _box(_room)
	v.add_theme_constant_override("separation", 10)
	_room.add_theme_constant_override("margin_top", 88)
	_room.add_theme_constant_override("margin_bottom", 70)
	_room.position.x = WIDE_PAGE_X
	_room_panel = LobbyPanel.new()
	_room_panel.stage_changed.connect( func(id: String):
		Net.set_stage(id)
		GameConfig.stage = id
		GameConfig.save_settings())
	_room_panel.rule_changed.connect(_on_room_rule)
	_room_panel.tod_changed.connect( func(i: int): Net.set_tod(i))
	_room_panel.outfit_changed.connect( func(i: int): Net.set_outfit(i))
	_room_panel.modifiers_pressed.connect( func(): _open_modifiers(true))
	_room_panel.global_cpu_changed.connect( func(d: int): Net.set_cpu_difficulty(d))
	_room_panel.cpu_diff_step.connect( func(id: String, dir: int):
		if Net.is_host:
			_cpu_step(Net.cpu_slots, id, dir, func(): Net.set_cpu_slots(Net.cpu_slots)))
	_room_panel.cpu_reroll.connect( func(id: String):
		if Net.is_host:
			_cpu_reroll(Net.cpu_slots, id, func(): Net.set_cpu_slots(Net.cpu_slots)))
	_room_panel.side_pressed.connect( func(side: int): Net.pick_side(side))
	_room_panel.start_pressed.connect(_on_start_online)
	_room_panel.shuffle_pressed.connect( func(): Net.shuffle_sides())
	_room_panel.invite_pressed.connect( func():
		if not Net.steam_invite_overlay():
			_open_friends_for_invite())
	_room_panel.human_pressed.connect(_on_room_player)

	_room_panel.captain_pressed.connect( func(side: int, seat: String):
		if Net.is_host and Net.custom_lobby:
			Net.set_captain(side, seat))
	_room_panel.back_btn.text = "leave"
	_room_panel.back_pressed.connect(_leave_online)
	_room_panel.reset_pressed.connect( func():
		Net.set_rules(Net.RULE_DEFAULTS.pts, Net.RULE_DEFAULTS.sets, 
			Net.RULE_DEFAULTS.wbt, Net.RULE_DEFAULTS.sweat, Net.RULE_DEFAULTS.rate, 
			Net.RULE_DEFAULTS.replays, Net.RULE_DEFAULTS.collide, Net.RULE_DEFAULTS.serve, 
			Net.RULE_DEFAULTS.hints, Net.RULE_DEFAULTS.lock, Net.RULE_DEFAULTS.rotate, 
			Net.RULE_DEFAULTS.intro)
		Net.set_stage(Stage.home())
		GameConfig.stage = Stage.home()
		_refresh_room()
		_refresh_modifiers())
	v.add_child(_room_panel)
	_start_btn = _room_panel.start_btn
var _room_panel: LobbyPanel = null



func _boot_review(report_id: String) -> void :
	var key: = "replays/%s.rply" % report_id
	Backend.get_evidence(key, func(code: int, bytes: PackedByteArray):
		if code == 200 and bytes.size() > 0:
			DirAccess.make_dir_recursive_absolute(ReplayData.DIR)
			var path: = "%s/review_%s.rply" % [ReplayData.DIR, report_id]
			var f: = FileAccess.open(path, FileAccess.WRITE)
			if f != null:
				f.store_buffer(bytes)
				f.close()
				GameConfig.review_replay_path = path
				GameConfig.goto_scene("res://game/replay/replay_viewer.tscn")
				return
		push_error("review: could not fetch replay for %s (code %d)" % [report_id, code]))

func _on_room_player(id_str: String) -> void :


	var pid: = int(id_str)
	if pid == Net.multiplayer.get_unique_id() or not Net.players.has(pid):
		return
	PlayerMenu.open(pid)


func _on_room_rule(key: String, value: Variant) -> void :
	if not Net.is_host:
		return
	if key == "size":
		Net.set_team_size(clampi(int(value), 1, 6))
		return
	var pts: = Net.rule_points
	var sets: = Net.rule_sets
	var wbt: = Net.rule_wbt
	var sweat: = Net.rule_sweat
	var rate: = Net.rule_rate
	var replays: = Net.rule_replays
	var collide: = Net.rule_collide
	var serve: = Net.rule_serve
	var hints: = Net.rule_hints
	var lock: = Net.rule_lock
	var rotate: = Net.rule_rotate
	var intro: = Net.rule_intro
	match key:
		"sets":
			sets = clampi(int(value), 1, 3)
		"points":
			pts = clampi(int(value), 3, 25)
		"wbt":
			wbt = bool(value)
		"sweat":
			sweat = bool(value)
		"rate":
			var ri: = clampi(int(value), 0, SWEAT_RATES.size() - 1)
			sweat = ri > 0
			if ri > 0:
				rate = SWEAT_RATES[ri]
		"serve":
			serve = SERVE_TIMES[clampi(int(value), 0, SERVE_TIMES.size() - 1)]
		"replays":
			replays = bool(value)
		"collide":
			collide = bool(value)
		"hints":
			hints = bool(value)
		"lock":
			lock = bool(value)
		"rotate":
			rotate = bool(value)
		"intro":
			intro = bool(value)


	Net.set_rules(pts, sets, wbt, sweat, rate, replays, collide, serve, hints, lock, rotate, 
		intro)
	_refresh_modifiers()

func _online_status() -> Label:
	var l: = Label.new()
	l.text = ""
	UiStyle.style_label(l, "small")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l



func _apply_privacy() -> void :
	Net.privacy = _priv_opt.selected if _priv_opt != null else Net.Priv.PUBLIC
	Net.password = _pw_edit.text.strip_edges()\
	if Net.privacy == Net.Priv.PASSWORD and _pw_edit != null else ""
	if Net.privacy == Net.Priv.PASSWORD and Net.password == "":
		Net.privacy = Net.Priv.PUBLIC




func _selected_max_humans() -> int:
	if _max_players_opt == null:
		return 0
	return int(MAX_PLAYER_CHOICES[clampi(_max_players_opt.selected, 0, 
		MAX_PLAYER_CHOICES.size() - 1)])




func _on_host() -> void :
	if LaunchGate.public_beta():
		return
	_cancel_search()
	Net.my_name = _online_name()
	Net.privacy = Net.Priv.PUBLIC
	Net.password = ""
	if Net.host_game(Net.my_name) == OK:
		_lan_mode = true
		Net.custom_lobby = true
		Net.max_humans = 0
		Net.init_rules_from_config()
		_show_room()
	else:
		_flash_notice("couldn't open the port, are you already hosting?")

func _on_host_steam() -> void :
	if not OnlineTerms.require(_on_host_steam):
		return

	_cancel_search()
	Net.my_name = _online_name()
	if Net.party and Net.is_host:
		_room_from_party()
		return
	if Net.host_game_steam(Net.my_name) == OK:


		_apply_privacy()
		Net.custom_lobby = true
		Net.max_humans = _selected_max_humans()
		Net.init_rules_from_config()
		_show_room()
	else:
		_host_status.text = Net.steam_status_text() if not Net.steam_transport_available()\
		else "steam hosting unavailable"


func _on_join() -> void :
	Net.my_name = _online_name()
	if _direct_pw != null:
		Net.join_password = _direct_pw.text
	var ip: = _ip_edit.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	if Net.join_game(ip, Net.my_name) == OK:
		_lan_mode = true
		Net.custom_lobby = true
		_direct_status.text = "connecting to %s..." % ip
		_watch_direct(ip)
	else:
		_direct_status.text = "bad address"

func _watch_direct(ip: String) -> void :

	await get_tree().create_timer(6.0).timeout
	if not Net.party and Net.players.is_empty() and _direct != null\
	and _direct.visible:
		_direct_status.text = \
		"couldn't join %s -- wrong ip, host left, or firewall" % ip






func _on_play_tab() -> void :
	if Net.active and Net.custom_lobby and not Net.party and Net.players.size() > 0 and _room != null:
		_show_room()
	else:
		_show(_home)

func _show_room() -> void :
	_leave_freeplay_for_session()
	_show(_room)
	_refresh_room()


	if _chat != null:
		_chat.unfold()




func _leave_freeplay_for_session() -> void :


	if _practice_on:
		_leave_practice()
		return
	if not _freeplay or _tutorial != null:
		return
	if _drill_active != "":
		_leave_drill()
	else:
		_exit_freeplay()



func _on_party_became_room() -> void :
	_refresh_party_strip()
	_show_room()

func _room_from_party() -> void :
	_apply_privacy()
	Net.max_humans = _selected_max_humans()
	Net.init_rules_from_config()
	Net.room_from_party()
	_flash_notice("your party is in the lobby")




func _back_to_hub() -> void :
	if Net.active and Net.custom_lobby and not Net.party and Net.players.size() > 0 and _room != null:
		_show_room()
	else:
		_show(_home)

func _leave_online() -> void :





	if Net.active and bool(Net.home_party.get("is_leader", false))\
	and bool(Net.home_party.get("room", false)):
		Net.send_party_home()
		_show(_session_exit_page())
		get_tree().create_timer(PARTY_RELAY_FLUSH).timeout.connect( func():
			Net.leave()
			_maybe_resume_home_party())
		return




	if bool(Net.home_party.get("room", false)) and not bool(Net.home_party.get("is_leader", false)):
		Net.home_party = {}
		_in_party_room = false
	Net.leave()


	_maybe_resume_home_party()
	_show(_session_exit_page())




func _on_party_home_called(leader_sid: int) -> void :
	var hp: Dictionary = Net.home_party
	if hp.is_empty() or bool(hp.get("is_leader", false)):
		return
	var mine: = int(hp.get("leader_sid", 0))
	if leader_sid != 0 and mine != 0 and mine != leader_sid:
		return





	_go_home_from_room.call_deferred()

func _go_home_from_room() -> void :
	Net.leave()
	_maybe_resume_home_party()
	if _room.visible or _browse.visible or _host.visible or _direct.visible:
		_show(_session_exit_page())



func _on_party_travel_to(host_id: int, code: String) -> void :
	_cancel_search()
	Net.my_name = _online_name()
	_party_join_server(host_id, "", code)
	if _browse_hint != null:
		_browse_hint.text = "taking the party to the lobby..."

func _on_session_ended(reason: String) -> void :




	if _member_queuing:
		_member_queuing = false
		_mm_chip.visible = false
		_set_matchmaking(false)
		_reraise_own_search()





	if reason != "restart" and reason != "left" and _regroup_with_leader():
		return
	if not _reform_target.is_empty():
		return


	if _qp != null and _qp.state != QuickPlay.State.IDLE:
		return



	if reason != "" and reason != "left" and reason != "restart":
		_flash_notice(reason)
	_joining_live = false

	if _bw_joining and not _bw_quiet_leave:
		_join_gen += 1
		_set_browse_joining(false)
	_clear_party_bodies()


	if _in_party_room:
		_in_party_room = false
		_maybe_resume_home_party()

	if (_room.visible or _browse.visible or _host.visible or _direct.visible)\
	and not _bw_quiet_leave:
		_show(_session_exit_page())
	if _browse.visible and _browse_hint != null:
		_browse_hint.text = reason



func _refresh_browser() -> void :
	for child in _browse_list.get_children():
		child.queue_free()
	if not _steam_up:
		_browse_hint.text = Net.steam_status_text()
		return
	_browse_hint.text = "searching..."
	Net.steam_request_lobbies("custom")



func _browse_fake(n: int) -> void :
	_show(_browse)
	var names: = ["reg's court", "spike city", "beach bums", "net ninjas", 
		"sunday league", "the pit", "grass stains", "block party", "dig deep", 
		"ace holes", "bump set spike", "sand castle", "the net returns", 
		"volley llamas", "court jesters", "pancake club", "rally cats", 
		"setters gonna set", "kill zone", "over the net"]
	var stages: Array = Stage.ids(false)
	if stages.is_empty():
		stages = [Stage.home()]
	var rng: = RandomNumberGenerator.new()
	rng.seed = 1234
	var rows: Array = []


	if "--browse-cases" in LaunchGate.dev_args():
		n = 0
		for c in [
			["open 2v2", "lobby", 2, 1, 1, 8, ""], 
			["half full 3v3", "lobby", 3, 4, 4, 12, ""], 
			["match full 2v2", "lobby", 2, 7, 4, 12, ""], 
			["match full in game", "game", 2, 9, 4, 12, ""], 
			["room full 4v4", "lobby", 4, 6, 5, 6, ""], 
			["room full 2v2", "game", 2, 4, 4, 4, ""], 
			["benched overflow 1v1", "lobby", 1, 5, 2, 8, ""], 
			["one spot left 2v2", "lobby", 2, 7, 3, 8, ""], 
			["older host", "lobby", 0, 3, 0, 8, "2v2"], 
		]:
			rows.append({"name": c[0], "steam": true, "host_id": 300000 + rows.size(), 
				"lobby_id": 400000 + rows.size(), "kind": "", "state": c[1], 
				"size": c[2], "humans": c[3], "players": c[3], "seated": c[4], 
				"cap": str(c[5]), "mode": c[6], "ping": 20 + rows.size() * 6, 
				"map": "nationals", "stage": "nationals", "compatible": true, 
				"priv": "public", "locked": false})



	var la: = LaunchGate.dev_args()
	var li: = la.find("--browse-lan")
	if li != -1 and li + 1 < la.size():
		rows.append({"name": "lan room", "steam": false, "ip": String(la[li + 1]), 
			"host_id": 0, "lobby_id": 0, "kind": "custom", "state": "lobby", 
			"size": 2, "humans": 1, "players": 1, "seated": 1, "cap": "8", 
			"mode": "2v2", "ping": 5, "map": "nationals", "stage": "nationals", 
			"compatible": true, "priv": "public", "locked": false})
	for i in n:
		var cap: int = [2, 4, 6, 8, 12][rng.randi() % 5]
		var per: int = [1, 2, 3, 4][rng.randi() % 4]
		var cur: = rng.randi_range(0, cap)
		var seated: = mini(rng.randi_range(0, cur), per * 2)
		var in_game: = rng.randf() < 0.35
		var st: String = String(stages[rng.randi() % stages.size()])


		var ping: int = [-1, rng.randi_range(8, 30), rng.randi_range(30, 70), 
			rng.randi_range(75, 130)][rng.randi() % 4]
		var nm: = String(names[i % names.size()])
		if i >= names.size():
			nm += " %d" % (i / names.size() + 1)
		rows.append({
			"name": nm, "steam": true, "host_id": 100000 + i, "lobby_id": 200000 + i, 
			"kind": "", "state": "game" if in_game else "lobby", 
			"mode": "%dv%d" % [per, per], "players": cur, "humans": cur, 
			"size": per, "seated": seated, 
			"cap": str(cap), "ping": ping, "map": st, "stage": st, 
			"compatible": true, "priv": "public", "locked": rng.randf() < 0.12, 
		})
	_bw_rows = rows

	if "--browse-hide-full" in LaunchGate.dev_args() and _bw_full != null:
		_bw_full.button_pressed = false
	_apply_browse_filters()

	if "--browse-scroll-end" in LaunchGate.dev_args():
		var sc: = _browse_list.get_parent() as ScrollContainer
		if sc != null:
			await get_tree().create_timer(0.5).timeout
			sc.scroll_vertical = 100000

func _on_steam_lobbies(rows: Array) -> void :
	if not _browse.visible:
		return



	if Net.lobby_list_kind.begins_with("quick"):
		return





	var kinds: = ["custom"]
	_bw_rows = rows.filter( func(r): return String(r.get("kind", "")) in kinds)
	_apply_browse_filters()


func _bw_cur(r: Dictionary) -> int:
	return maxi(int(r.get("humans", r.get("players", 0))), 0)

func _bw_cap(r: Dictionary) -> int:




	var c: = int(String(r.get("cap", "0")))
	return c if c > 0 else Net.MAX_PLAYERS


func _bw_size(r: Dictionary) -> int:
	return clampi(int(r.get("size", 0)), 0, 6)




func _bw_open(r: Dictionary) -> int:
	var per: = _bw_size(r)
	if per <= 0:
		return -1
	var seats: = maxi(per * 2 - maxi(int(r.get("seated", 0)), 0), 0)
	return mini(seats, maxi(_bw_cap(r) - _bw_cur(r), 0))


func _bw_match_full(r: Dictionary) -> bool:
	return _bw_cur(r) >= _bw_cap(r) or _bw_open(r) == 0


func _apply_browse_filters() -> void :
	if _browse_list == null:
		return
	var rows: Array = _bw_rows.duplicate()










	rows = rows.filter( func(r):
		if String(r.get("priv", "public")) != "friends":
			return true
		if not bool(r.get("steam", false)):
			return true
		var hid: = int(r.get("host_id", 0))
		return hid == Net.my_steam_id() or Net._is_friend(hid))
	var q: = _bw_search.text.strip_edges().to_lower() if _bw_search != null else ""
	if q != "":
		rows = rows.filter( func(r):
			return String(r.get("name", "")).to_lower().contains(q))
	if _bw_region != null:
		var ceil_ms: int = BW_REGION_MS[clampi(_bw_region.selected, 0, 3)]
		rows = rows.filter( func(r):
			var p: = int(r.get("ping", -1))
			return p < 0 or p <= ceil_ms)
	if _bw_friends != null and _bw_friends.button_pressed:
		rows = rows.filter( func(r): return bool(r.get("steam", false))\
		and Net._is_friend(int(r.get("host_id", 0))))
	if _bw_full != null and not _bw_full.button_pressed:
		rows = rows.filter( func(r): return not _bw_match_full(r))



	var sort_i: = _bw_sort.selected if _bw_sort != null else 0
	rows.sort_custom( func(a, b): return _bw_less(a, b, sort_i))
	_render_browse_rows(rows)



func _bw_less(a: Dictionary, b: Dictionary, sort_i: int) -> bool:
	if sort_i == 1:
		return _bw_cur(a) > _bw_cur(b)
	if sort_i == 2:
		return _bw_cur(a) < _bw_cur(b)
	var pa: = int(a.get("ping", -1))
	var pb: = int(b.get("ping", -1))
	if pa < 0:
		return false
	if pb < 0:
		return true
	return pa < pb




func _bw_signal_pill(row: Dictionary) -> Control:
	var pill: = PanelContainer.new()
	var box: = UiStyle.card_box(UiStyle.card(), 99)
	box.content_margin_left = 10.0
	box.content_margin_right = 12.0
	box.content_margin_top = 3.0
	box.content_margin_bottom = 3.0
	box.shadow_size = 3
	box.shadow_offset = Vector2(0, 2)
	pill.add_theme_stylebox_override("panel", box)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hb: = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(hb)
	var bars: = StatRow.SignalBars.new()
	bars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(bars)
	var txt: = Label.new()
	txt.add_theme_font_override("font", UiStyle.font(UiStyle.FONT_XBOLD))
	txt.add_theme_font_size_override("font_size", 13)
	txt.add_theme_color_override("font_color", UiStyle.muted())
	txt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(txt)
	var lan: = not bool(row.get("steam", false))
	var p: = int(row.get("ping", -1))
	if lan:
		bars.set_ms(0.0)
		txt.text = "lan"
	elif p < 0:
		bars.lit = 0
		txt.text = "?"
	else:
		bars.set_ms(float(p))
		txt.text = "%dms" % p
	return pill

const ROW_ART_SHADER: = "\nshader_type canvas_item;\nuniform float radius = 14.0;\nuniform float fade_from = 0.44;\nuniform float fade_to = 0.80;\nuniform vec2 rect = vec2(460.0, 78.0);   // the card's size, set from code\nvoid fragment() {\n\tvec2 px = UV * rect;\n\tvec2 sz = rect;\n\tvec2 q = abs(px - sz * 0.5) - (sz * 0.5 - vec2(radius));\n\tfloat d = length(max(q, 0.0)) - radius;\n\tfloat a = 1.0 - smoothstep(-1.0, 1.0, d);\n\tfloat f = smoothstep(fade_from, fade_to, UV.x);\n\tCOLOR = texture(TEXTURE, UV);\n\tCOLOR.a *= a * f;\n}\n"
















static var _row_art_shader: Shader = null



func _row_stage_art(r: Button, stage_id: String) -> void :
	if stage_id == "" or not Stage.STAGES.has(stage_id):
		return
	var tex: = Stage.thumb(stage_id)
	if tex == null:
		return
	if _row_art_shader == null:
		_row_art_shader = Shader.new()
		_row_art_shader.code = ROW_ART_SHADER
	var art: = TextureRect.new()
	art.texture = tex
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)



	art.offset_bottom = -8.0
	art.offset_right = -1.0
	art.offset_left = 1.0
	art.offset_top = 1.0
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.modulate = Color(1, 1, 1, 0.9)
	var mat: = ShaderMaterial.new()
	mat.shader = _row_art_shader
	mat.set_shader_parameter("radius", 15.0)
	art.material = mat
	art.resized.connect( func(): mat.set_shader_parameter("rect", art.size))
	r.add_child(art)
	r.move_child(art, 0)



func _render_browse_rows(rows: Array) -> void :
	for child in _browse_list.get_children():
		child.queue_free()
	if rows.is_empty():
		var q: = _bw_search.text.strip_edges() if _bw_search != null else ""
		_browse_hint.text = ("no courts matching \"%s\"" % q) if q != ""\
		else "no lobbies available"
		return


	_browse_hint.text = ""
	for row in rows:
		var cur: = _bw_cur(row)
		var cap: = _bw_cap(row)
		var full: = cur >= cap
		var kind: = String(row.get("kind", ""))
		var locked: = bool(row.get("locked", false))
		var compatible: = bool(row.get("compatible", true))
		var icon_name: = "menuList"
		var sub: = ""
		if String(row.get("state", "")) == "game":
			icon_name = "massiveMultiplayer"
			sub = "in game     %s" % String(row.get("map", "court"))
		else:
			icon_name = "multiplayer"
			sub = "in lobby     %s" % ("steam" if row.steam else "lan")


		if _bw_open(row) == 0 and not full:
			sub += "     join to watch"

		var trailing: = HBoxContainer.new()
		trailing.add_theme_constant_override("separation", 6)
		var per: = _bw_size(row)
		var mode: = ("%dv%d" % [per, per]) if per > 0 else String(row.get("mode", ""))
		if mode != "":


			var no_spot: = per > 0 and _bw_match_full(row)
			trailing.add_child(UiPage.tag(mode, UiStyle.RED if no_spot else UiStyle.SECONDARY))
		trailing.add_child(_bw_signal_pill(row))
		if not compatible:
			trailing.add_child(UiPage.tag("old version", UiStyle.muted()))
		elif locked:
			trailing.add_child(UiPage.tag("locked", UiStyle.INK))
		elif String(row.get("priv", "public")) == "friends":
			trailing.add_child(UiPage.tag("friends", UiStyle.SECONDARY))


		var open: = _bw_open(row)
		if open < 0:
			trailing.add_child(UiPage.tag("%d/%d" % [cur, cap], 
				UiStyle.muted() if full else UiStyle.SUCCESS))
		else:

			var lead: = "full" if full else ("match full" if open == 0\
			else "%d open" % open)
			trailing.add_child(UiPage.tag("%s · %d/%d" % [lead, cur, cap], 
				UiStyle.SUCCESS if open > 0 else UiStyle.muted()))
		var r: = UiPage.card_row(icon_name, String(row.name), sub, "info", 
			Callable(), trailing, 460.0, true)


		if String(row.get("state", "")) == "game":
			_row_stage_art(r, String(row.get("stage", "")))
		if not compatible or (full and not locked):
			r.disabled = true
		else:
			r.pressed.connect( func():
				if locked:
					_prompt_password(row)
				else:
					_dial_row(row))
		_browse_list.add_child(r)
	UiPage.reveal(_browse_list)



func _on_join_code(text: String) -> void :
	var s: = text.strip_edges()
	if s == "":
		return
	if not OnlineTerms.require(_on_join_code.bind(text)):
		return


	if Net.party and not Net.is_host:
		_flash_notice("only the party leader can move the party")
		return
	if _bw_joining:
		return
	Net.my_name = _online_name()





	var has_key: = s.contains("-")
	for row in _bw_rows:
		if not has_key and (str(row.get("lobby_id", "")) == s\
		or String(row.get("name", "")).to_lower() == s.to_lower()):
			_dial_row(row)
			return



	if Net.join_by_code(s):
		_cancel_search()
		_browse_hint.text = "joining lobby..."
		_watch_join("lobby")
		return
	_browse_hint.text = "no lobby with code \"%s\"" % s

func _dial_row(row: Dictionary) -> void :
	if not OnlineTerms.require(_dial_row.bind(row)):
		return


	_cancel_search()
	Net.my_name = _online_name()
	_joining_live = String(row.get("state", "")) == "game"\
	or String(row.get("kind", "")) == "gym"
	if bool(row.steam) and int(row.host_id) == Net.my_steam_id():
		return


	if Net.party:
		if not Net.is_host:
			_flash_notice("only the party leader can move the party")
			return


		var need: = PartySeats.human_count()
		if _bw_cap(row) - _bw_cur(row) < need:
			_flash_notice("not enough room there for your party of %d" % need)
			return
		_party_join_server(int(row.host_id) if bool(row.steam) else 0, 
			"" if bool(row.steam) else String(row.ip), 
			str(row.lobby_id) if bool(row.steam)\
			and int(row.get("lobby_id", 0)) != 0 else "")
		_browse_hint.text = "taking the party to %s..." % row.name
		return
	var ok: = false
	if row.steam:
		ok = Net.join_game_steam(row.host_id, Net.my_name) == OK
	else:
		ok = Net.join_game(row.ip, Net.my_name) == OK
	if ok:
		Net.custom_lobby = true



		if bool(row.steam) and int(row.get("lobby_id", 0)) != 0:
			Net.remote_lobby_code = str(row.lobby_id)
		_browse_hint.text = "joining %s..." % row.name
		_watch_join(row.name)




func _party_join_server(host_id: int, host_ip: String, code: = "") -> void :



	Net.rehome_party(host_id, host_ip, [], 0, Net.join_password)


	Net.home_party = {"is_leader": true, "token": Net.session_token, "room": true, 
		"lan": Net.party_lan, "block": Net.party_members().size(), 
		"mates": Net.party_mates()}
	_server_join = {"host_id": host_id, "ip": host_ip, "code": code}
	_server_join_t = 0.35

func _drive_server_join() -> void :
	var sj: = _server_join
	_server_join = {}
	var ok: = false
	if int(sj.get("host_id", 0)) != 0:
		ok = Net.join_game_steam(int(sj.host_id), Net.my_name) == OK
	elif String(sj.get("ip", "")) != "":
		ok = Net.join_game(String(sj.ip), Net.my_name) == OK
	if not ok:
		return



	Net.custom_lobby = true
	if String(sj.get("code", "")) != "":
		Net.remote_lobby_code = String(sj.code)

func _prompt_password(row: Dictionary) -> void :
	if _pw_panel != null:
		_pw_panel.queue_free()
	_pw_panel = PanelContainer.new()
	UiStyle.style_panel(_pw_panel, UiStyle._AUTO, UiStyle.RADIUS_SOFT)
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	var label: = Label.new()
	label.text = "password?"
	UiStyle.style_label(label, "title")
	box.add_child(label)
	var edit: = LineEdit.new()
	edit.secret = true
	edit.placeholder_text = "password"
	edit.custom_minimum_size = Vector2(260, 44)
	UiStyle.style_line_edit(edit)
	box.add_child(edit)
	var btns: = HBoxContainer.new()
	btns.add_theme_constant_override("separation", 10)
	btns.alignment = BoxContainer.ALIGNMENT_END
	var cancel: = Button.new()
	cancel.text = "cancel"
	UiStyle.style_button(cancel, "tertiary", 16)
	var go: = Button.new()
	go.text = "join"
	UiStyle.style_button(go, "primary", 16)
	btns.add_child(cancel)
	btns.add_child(go)
	box.add_child(btns)
	var pad: = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_%s" % side, 18)
	pad.add_child(box)
	_pw_panel.add_child(pad)
	ui.add_child(_pw_panel)
	_pw_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var submit: = func():
		Net.join_password = edit.text
		_pw_panel.queue_free()
		_pw_panel = null
		_dial_row(row)
	go.pressed.connect(submit)
	edit.text_submitted.connect( func(_t: String): submit.call())
	cancel.pressed.connect( func():
		_pw_panel.queue_free()
		_pw_panel = null)
	edit.grab_focus()

func _watch_join(court_name: String) -> void :
	_join_gen += 1
	var gen: = _join_gen
	_set_browse_joining(true)
	await get_tree().create_timer(10.0).timeout
	if gen != _join_gen or not _bw_joining:
		return


	if not Net.in_match and Net.players.is_empty():
		_cancel_browse_join("couldn't connect to %s" % court_name)
	else:
		_set_browse_joining(false)

func _refresh_room() -> void :
	if not Net.active:
		return

	if _bw_joining and not Net.players.is_empty():
		_join_gen += 1
		_set_browse_joining(false)






	if not _room.visible and not Net.is_host and Net.players.size() > 0\
	and (_qp == null or _qp.state == QuickPlay.State.IDLE)\
	and not _joining_live and not Net.party and _party_away_mates().is_empty():
		_show_room()
	if not _room.visible or _room_panel == null:
		return
	var me: = _my_party_id()
	var ids: = Net.players.keys()
	ids.sort()
	var humans: = {1: 0, -1: 0}
	var entries: = {1: [], -1: []}
	var specs: Array = []
	var my_side: = 0
	var benched: = false
	for id in ids:



		var locs: Array = Net.locals_of(id)
		var seats: Array = [{"ls": 0, "side": int(Net.players[id].side), 
			"name": String(Net.players[id].name), "cfg": Net.players[id].get("cfg", {})}]
		var li: = 1
		for g in locs:
			var gd: Dictionary = g
			seats.append({"ls": li, "side": int(gd.get("side", Net.players[id].side)), 
				"name": String(gd.get("name", "")), "cfg": gd.get("cfg", {})})
			li += 1
		for s in seats:
			var side: int = s.side
			var name: String = s.name
			var on_team: bool = side != 0 and int(humans[side]) < Net.team_size
			var is_me_owner: bool = id == me and int(s.ls) == 0
			if is_me_owner:
				my_side = side
				benched = side != 0 and not on_team
			if not on_team:
				specs.append(name)
				continue

			var cfg: Dictionary = Mod.shown_cfg(id, s.cfg) if id != me else s.cfg
			if is_me_owner and GameConfig.character != null:
				cfg = GameConfig.character.to_dict()


			var tile: = {"kind": "human", "name": name, "cfg": cfg, 
				"host": id == 1 and int(s.ls) == 0, "you": is_me_owner, 
				"dev": DevBadge.peer_tier(id), "id": str(id), 
				"seat": TeamKits.seat_key(id, int(s.ls)), 
				"actionable": int(s.ls) == 0}

			if id == me and int(s.ls) >= 1 and int(s.ls) < LocalPlayers.slots.size():
				tile["local"] = LocalPlayers.slots[int(s.ls)].tag()
				tile["local_color"] = LocalPlayers.slots[int(s.ls)].color()
			entries[side].append(tile)
			humans[side] += 1


	if Net.is_host and CpuSlots.reconcile(Net.cpu_slots, Net.team_size, humans, 
			Net.cpu_difficulty):
		Net.call_deferred("set_cpu_slots", Net.cpu_slots)
	for side in [1, -1]:
		for cpu in CpuSlots.ordered(Net.cpu_slots, side):
			entries[side].append({"kind": "cpu", "name": String(cpu.name), 
				"cfg": cpu.cfg, "diff": int(cpu.diff), 
				"id": CpuSlots.id_for(side, int(cpu.k)), 
				"seat": TeamKits.cpu_key(side, int(cpu.k))})


	var kit_view: = _dress_lobby_tiles(entries, Net.captains, 
		Net.is_host and Net.custom_lobby, Net.stage, Net.custom_lobby, Net.rule_outfit)
	var tell: = ""
	if benched:
		tell = "that side is full, join %s to play" % ("away" if my_side == 1 else "home")
	elif my_side == 0 and Net.players.has(me):
		tell = "join home or away to play"
	_room_panel.apply({"title": "lobby", "stage_ids": Stage.ids(), 
		"stage": Stage.resolve(Net.stage), "tod": Net.rule_tod, 

		"outfit": Net.rule_outfit, "outfit_edit": Net.is_host and Net.custom_lobby, 
		"outfit_show": Net.custom_lobby, 
		"size": Net.team_size, "home": entries[1], "away": entries[-1], 
		"kits": kit_view.kits, "alt": kit_view.alt, "kit_mode": kit_view.mode, 
		"rules": {"sets": Net.rule_sets, "points": Net.rule_points, 
			"wbt": Net.rule_wbt, "sweat": Net.rule_sweat, 
			"rate": _rate_index(Net.rule_rate, Net.rule_sweat), 
			"replays": Net.rule_replays, "collide": Net.rule_collide, 
			"serve": _serve_index(Net.rule_serve), "hints": Net.rule_hints, 
			"lock": Net.rule_lock, "rotate": Net.rule_rotate, 
			"intro": Net.rule_intro}, 
		"rate_names": SWEAT_RATE_NAMES, 
		"cpu": CpuSlots.global_diff(Net.cpu_slots), 
		"editable": Net.is_host, "my_side": my_side, "side_mode": "online", 
		"side_editable": true, 
		"can_start": Net.is_host, "invite": Net.steam_transport_available(), 

		"shuffle": Net.is_host and Net.players.size() >= 2, 
		"spectators": specs, 
		"hint": "empty seats are filled with cpus" if Net.is_host\
		else "waiting for the host to start...", "tell": tell})











func _dress_lobby_tiles(entries: Dictionary, wanted: Dictionary, can_pick: bool, 
		stage_id: String, decided_here: = true, outfit: = DressCode.CURRENT) -> Dictionary:


	var casual: = DressCode.casual(stage_id, outfit)
	var pinny: = DressCode.pinny(stage_id, outfit)
	var mode: = "pinny" if pinny else ("" if casual else "kit")
	if not decided_here:
		mode = ""
	if mode == "":
		for side in [1, -1]:
			for t in entries[side]:
				(t as Dictionary)["cap"] = false
				(t as Dictionary)["cap_edit"] = false
		return {"kits": {}, "alt": 0, "mode": ""}
	var seats: Array = []
	for side in [1, -1]:
		var slot: = 0
		for t in entries[side]:
			var tile: Dictionary = t
			var key: = String(tile.get("seat", ""))
			var e: = {"side": side, "slot": slot, "cfg": tile.get("cfg", {}), "peer": 0, "ls": 0}
			if String(tile.get("kind", "")) == "human" and key.contains(":"):
				e["peer"] = int(key.get_slice(":", 0))
				e["ls"] = int(key.get_slice(":", 1))
			seats.append(e)
			slot += 1
	var res: = TeamKits.pick_roster(seats, wanted)
	for side in [1, -1]:
		for t in entries[side]:
			var tile: Dictionary = t
			var key: = String(tile.get("seat", ""))
			tile["cap"] = key != "" and key == String(res.caps.get(side, ""))


			tile["cap_edit"] = can_pick and (String(tile.get("kind", "")) == "human"
				or (String(tile.get("kind", "")) == "cpu" and not (tile.get("cfg", {}) as Dictionary).is_empty()))
	return {"kits": {1: TeamKits.to_html(res.kits[1]), -1: TeamKits.to_html(res.kits[-1])}, 
		"alt": int(res.alt), "mode": mode}

func _on_start_online() -> void :



	Net.apply_rules_to_config()
	var ids: = Net.players.keys()
	ids.sort()
	var roster: = Net.match_roster(ids, Net.players, Net.team_size, Net.cpu_slots, 
		Net.captains)
	GameConfig.set_mode(Net.team_size)
	GameConfig.stage = Net.stage
	GameConfig.ranked_match = false
	Net.start_match(roster, randi())







var _fp_toggle_frame: = -1

func _enter_freeplay() -> void :
	_freeplay = true
	_fp_toggle_frame = Engine.get_process_frames()
	_dock_chat(false)
	_root.visible = false
	_top_panel.visible = false
	_bottom_panel.visible = false
	_top_strip.visible = false
	_bottom_strip.visible = false
	_logo_rect.visible = false
	if _pc_avatar != null:
		_pc_avatar.visible = false
	if _friends_panel != null:
		_friends_panel.visible = false
	if _friends_scrim != null:
		_friends_scrim.visible = false

	_mm_chip.visible = _member_queuing\
	or (_qp != null and _qp.state != QuickPlay.State.IDLE)

	ui.get_viewport().gui_release_focus()



	_input_collector.swallow_held(["jump", "contact", "serve", "dive", "set", "ball_spawn"])

	_fp_hint.visible = false
	hud.visible = true
	hud.set_scoreboard_visible(false)
	hud.set_freeplay_controls(_shared_ball_on)


	_restore_my_ball()
	ball.visible = true
	_ball_auto_until = Time.get_ticks_msec() + 2000
	hud.set_serve_prompt(_ball_prompt())
	player.ball = ball
	player.indicator_enabled = true
	player.charge_ui_enabled = true


	if _sand_deform != null:
		_sand_deform.reset()
	_floor_mat.set_shader_parameter("reflect_on", true)
	camera_rig.mode_locked = false
	camera_rig.mode = clampi(GameConfig.default_camera, 0, 
		CameraRig.Mode.size() - 1) as CameraRig.Mode
	camera_rig.camera.current = true
	camera_rig.apply_mouse_mode()


	_sync_local_guests()

	_build_freeplay_views()
	_update_presence()

func _exit_freeplay() -> void :
	_freeplay = false



	_teardown_freeplay_views()


	_on_local_roster()
	_fp_toggle_frame = Engine.get_process_frames()
	_dock_chat(true)
	_serving = false
	hud.set_freeplay_controls(false)
	_restore_my_ball()
	_clear_party_bodies()
	camera_rig.serve_view = false


	player.clear_action_state()
	player.serve_charge_ui = false
	_spin = 0.0
	reach_marker.reset()

	ball.frozen = false
	player.ball = null
	player.indicator_enabled = false
	player.charge_ui_enabled = false

	if _sand_deform != null:
		_sand_deform.reset()
	hud.visible = false
	aim_indicator.visible = false
	_floor_mat.set_shader_parameter("reflect_on", false)
	_root.visible = true
	_top_panel.visible = true
	_bottom_panel.visible = true
	_top_strip.visible = true
	_bottom_strip.visible = true
	_logo_rect.visible = true
	if _pc_avatar != null:
		_pc_avatar.visible = true
	_mm_chip.visible = false

	if _member_queuing:
		_set_matchmaking(true)
		_mm_cancel.visible = false
	_update_presence()
	_fp_hint.visible = false
	player.global_position = HOME_SPOT
	player.velocity = Vector3.ZERO
	player.team_side = 1
	player.reset_physics_interpolation()
	_face_camera()
	ball.global_position = HOME_SPOT + Vector3(-0.45, 0.4, 0.5)
	ball.vel = Vector3.ZERO
	ball.reset_physics_interpolation()
	menu_cam.current = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	UiStyle.sfx("close")

	call_deferred("_focus_current_page")

	if _guide_return != "":
		var spread: = _guide_return
		_guide_return = ""
		_open_guide.call_deferred(spread)



func _focus_current_page() -> void :
	for p in [_home, _online, _local, _practice, _configs, _profile, _quick, 
		_settings, _howto, _browse, _host, _room, _direct, _recent]:
		if p != null and p.visible:
			_focus_first(p)
			return



func _restore_focus() -> void :
	if _last_focus != null and is_instance_valid(_last_focus)\
	and _last_focus.is_visible_in_tree()\
	and _last_focus.focus_mode != Control.FOCUS_NONE\
	and not (_last_focus is BaseButton and (_last_focus as BaseButton).disabled):
		_last_focus.grab_focus()
		_scroll_follow(_last_focus)
		return
	_focus_current_page()





func _zone_step(step: int) -> void :
	if _tab_step(step):
		return
	var foc: = get_viewport().gui_get_focus_owner() as Control
	if foc == null:
		_focus_current_page()
		return
	var items: = _zone_buttons(_zone_of(foc))
	if items.is_empty():
		return
	var idx: = items.find(foc)
	if idx == -1:
		(items[0] as Control).grab_focus()
		return
	var nxt: = items[(idx + step + items.size()) % items.size()] as Control
	nxt.grab_focus()
	_scroll_follow(nxt)
	UiStyle.sfx("hover")






func _tab_step(step: int) -> bool:
	var page: = _visible_page()
	if page == null:
		return false
	for n in page.find_children("*", "Control", true, false):
		var tabbed: = n as Control
		if not tabbed.has_method("cycle_tab") or not tabbed.is_visible_in_tree():
			continue
		tabbed.call("cycle_tab", step)
		UiStyle.sfx("hover")
		var foc: = get_viewport().gui_get_focus_owner() as Control
		if foc == null or not foc.is_visible_in_tree():
			for c in tabbed.find_children("*", "Control", true, false):
				var ctl: = c as Control
				if ctl.focus_mode != Control.FOCUS_NONE and ctl.is_visible_in_tree():
					ctl.grab_focus()
					_scroll_follow(ctl)
					break
		return true
	return false



func _zone_buttons(zone: int) -> Array:
	var root: Node = _top_bar if zone == 0 else (_bottom_bar if zone == 2 else _visible_page())
	var out: Array = []
	if root == null:
		return out
	for c in root.find_children("*", "BaseButton", true, false):
		var b: = c as BaseButton
		if b != null and b.is_visible_in_tree() and not b.disabled\
		and b.focus_mode != Control.FOCUS_NONE:
			out.append(b)
	return out


func _zone_of(ctrl: Control) -> int:
	if ctrl != null:
		if _top_bar != null and _top_bar.is_ancestor_of(ctrl):
			return 0
		if _bottom_bar != null and _bottom_bar.is_ancestor_of(ctrl):
			return 2
	return 1





func _grab_zone(zone: int, bottom_edge: = false) -> bool:
	match zone:
		0:
			return _focus_edge_button(_zone_buttons(0), false)
		2:
			return _focus_edge_button(_zone_buttons(2), false)
		_:
			return _focus_edge_button(_zone_buttons(1), bottom_edge)


func _focus_edge_button(items: Array, last: bool) -> bool:
	if items.is_empty():
		return false
	var target: = items[items.size() - 1 if last else 0] as Control
	target.grab_focus()
	_scroll_follow(target)
	UiStyle.sfx("hover")
	return true


const NAV_FIRST_DELAY: = 0.42
const NAV_REPEAT_RATE: = 0.11
const NAV_DEBOUNCE: = 0.07
const ACCEPT_DEBOUNCE: = 0.22
var _nav_dir: = ""
var _nav_repeat: = 0.0
var _nav_cooldown: = 0.0
var _accept_cd: = 0.0
var _cancel_cd: = 0.0




var _last_focus: Control = null





func _menu_nav(delta: float) -> void :
	if _freeplay or _practice_on:
		_nav_dir = ""
		return
	_tick_room_pointer()


	if _room_solo != null and _room_solo.awake():
		if _dpad_down():
			_room_solo.mouse_took_over()
			_nav_dir = ""
			_restore_focus()
		return
	var typing: = get_viewport().gui_get_focus_owner()
	if typing is LineEdit or typing is TextEdit:
		return
	_nav_cooldown = maxf(_nav_cooldown - delta, 0.0)
	_accept_cd = maxf(_accept_cd - delta, 0.0)
	_cancel_cd = maxf(_cancel_cd - delta, 0.0)
	_zone_cd = maxf(_zone_cd - delta, 0.0)

	if UiStyle.dialog_active():
		UiStyle.drive_dialog(delta)
		return


	if _chat != null and _chat.is_visible_in_tree() and Input.is_action_just_pressed("stats")\
	and not PAD_KEYBOARD.is_open():
		_chat.open_pad(get_viewport().gui_get_focus_owner())
		return

	if _friends_panel != null and _friends_panel.visible:
		_drive_friends(delta)
		return





	if _configs != null and _configs.visible and not _cfg_panels.is_empty():
		if _cfg_panels[0].listening():
			_nav_dir = ""
			return


		if _cfg_left_cd > 0.0 and LocalPlayers.ui_just_pressed("ui_cancel"):
			return
		if _cfg_panels[0].submenu_open() and LocalPlayers.ui_just_pressed("ui_cancel")\
		and _cancel_cd <= 0.0\
		and Engine.get_process_frames() != _fp_toggle_frame:
			_cancel_cd = ACCEPT_DEBOUNCE
			_cfg_panels[0].close_submenu()
			return


	if UiSelect.active == null:
		var settled: = get_viewport().gui_get_focus_owner() as Control
		if settled != null:
			_last_focus = settled



	if _zone_cd <= 0.0 and UiSelect.active == null:
		if LocalPlayers.ui_just_pressed("menu_zone_next"):
			_zone_cd = ACCEPT_DEBOUNCE
			_zone_step(1)
			return
		elif LocalPlayers.ui_just_pressed("menu_zone_prev"):
			_zone_cd = ACCEPT_DEBOUNCE
			_zone_step(-1)
			return


	if LocalPlayers.ui_just_pressed("ui_accept") and _accept_cd <= 0.0:
		_accept_cd = ACCEPT_DEBOUNCE
		var foc: = get_viewport().gui_get_focus_owner()
		if foc is UiSelect and not (foc as UiSelect).is_open():
			(foc as UiSelect).open_and_focus()
		elif foc is BaseButton and not (foc as BaseButton).disabled:
			var bb: = foc as BaseButton
			if bb.toggle_mode:
				bb.button_pressed = not bb.button_pressed
				UiStyle.sfx("tick")
			else:
				bb.pressed.emit()
		elif foc == null:
			_restore_focus()




	if LocalPlayers.ui_just_pressed("ui_cancel") and _cancel_cd <= 0.0\
	and Engine.get_process_frames() != _fp_toggle_frame:
		_cancel_cd = ACCEPT_DEBOUNCE
		if UiSelect.active != null:
			UiSelect.active.close()
		else:
			_menu_cancel()
		return

	var dir: = ""
	if LocalPlayers.ui_pressed("ui_down"): dir = "down"
	elif LocalPlayers.ui_pressed("ui_up"): dir = "up"
	elif LocalPlayers.ui_pressed("ui_right"): dir = "right"
	elif LocalPlayers.ui_pressed("ui_left"): dir = "left"

	if dir != "" and _room_solo != null and not _dpad_down():
		dir = ""
	if dir == "":
		_nav_dir = ""
		return
	if dir != _nav_dir:
		_nav_dir = dir
		_nav_repeat = NAV_FIRST_DELAY
		if _nav_cooldown <= 0.0:
			_nav_cooldown = NAV_DEBOUNCE
			_nav_move(dir)
	elif _nav_repeat <= 0.0:
		_nav_repeat = NAV_REPEAT_RATE
		_nav_move(dir)
	else:
		_nav_repeat -= delta

func _nav_move(dir: String) -> void :


	if UiSelect.active != null:
		UiSelect.active.step_focus(dir)
		return
	var foc: = get_viewport().gui_get_focus_owner() as Control
	if foc == null:
		_restore_focus()
		return


	if foc is Range and (dir == "left" or dir == "right"):
		var r: = foc as Range


		var st: float = maxf(r.step, (r.max_value - r.min_value) / 10.0)
		r.value += st if dir == "right" else - st
		UiStyle.sfx("tick")
		return
	var zone: = _zone_of(foc)




	match dir:
		"down":
			if zone == 0:
				_grab_zone(1, false)
				return
			if zone == 1:
				if _try_neighbor(foc, "down"):
					return
				_grab_zone(2)
				return
			return
		"up":
			if zone == 2:
				_grab_zone(1, true)
				return
			if zone == 1:
				if _try_neighbor(foc, "up"):
					return
				_grab_zone(0)
				return
			return
		_:
			_try_neighbor(foc, dir)




func _try_neighbor(foc: Control, dir: String) -> bool:

	var root: Node = _top_bar if _zone_of(foc) == 0 else (_bottom_bar if _zone_of(foc) == 2 else _visible_page())

	if _configs != null and _configs.visible and not _cfg_panels.is_empty()\
	and _cfg_panels[0].nav_root() != null:
		root = _cfg_panels[0].nav_root()
	var next: = PAD_NAV.neighbor(foc, dir, root)
	if next != null and next != foc and _zone_of(next) == _zone_of(foc):
		next.grab_focus()
		_scroll_follow(next)
		UiStyle.sfx("hover")
		return true
	return false




func _scroll_follow(ctrl: Control) -> void :
	PAD_NAV.follow(ctrl)






var _room_solo: Node = null

func _tick_room_pointer() -> void :
	var want: = _room != null and _room.visible and not _modal_up()
	if want and _room_solo == null:
		_room_solo = SOLO_POINTER.new()
		add_child(_room_solo)
		_room_solo.cursor.wake_stick_only = true
		_room_solo.cursor.back_pressed.connect( func():
			_room_solo.mouse_took_over()
			_menu_cancel())
		_room_solo.woke.connect( func(): get_viewport().gui_release_focus())
	elif not want and _room_solo != null:
		_room_solo.mouse_took_over()
		_room_solo.queue_free()
		_room_solo = null


func _dpad_down() -> bool:
	for pad in Input.get_connected_joypads() + Array(DeviceInput.test_pads):
		for b in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]:
			if Input.is_joy_button_pressed(pad, b):
				return true
	for k in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		if Input.is_physical_key_pressed(k):
			return true
	return false


func _page_back_button() -> Button:
	var page: = _visible_page()
	if page == null:
		return null
	for b in page.find_children("*", "Button", true, false):
		if b.has_meta("page_back") and (b as Button).is_visible_in_tree()\
		and not (b as Button).disabled:
			return b
	return null

func _menu_cancel() -> void :


	if _room != null and _room.visible:
		_leave_online()
		UiStyle.sfx("back")
		return



	if _home != null and not _home.visible and _room != null\
	and Net.active and Net.custom_lobby and not Net.party\
	and Net.players.size() > 0:
		_back_to_hub()
		UiStyle.sfx("back")
		return
	if _home != null and not _home.visible:


		var back: = _page_back_button()
		if back != null:
			back.pressed.emit()
		else:
			_show(_home)
		UiStyle.sfx("back")
	elif _home != null and _home.visible:

		_try_freeplay()

func _bubble_demo() -> void :
	await get_tree().create_timer(0.6).timeout
	if player == null:
		return
	var b: = BubbleChat.attach(player)
	b.add_message("nice serve!")
	await get_tree().create_timer(0.9).timeout
	b.add_message("anyone up for a quick game after this one? i have like twenty minutes", true)
	await get_tree().create_timer(0.7).timeout
	b.show_typing()


func _visible_page() -> Control:
	for p in [_home, _online, _local, _practice, _configs, _profile, _quick, 
		_settings, _howto, _browse, _host, _room, _direct, _recent, _achievements, 
		_custom, _career, _local_choose]:
		if p != null and p.visible:
			return p
	return null

func _visible_scroll() -> ScrollContainer:
	var page: = _visible_page()
	if page == null:
		return null
	for s in page.find_children("*", "ScrollContainer", true, false):
		var sc: = s as ScrollContainer
		if sc != null and sc.is_visible_in_tree():
			return sc
	return null

func _input(event: InputEvent) -> void :
	if not (event is InputEventMouseMotion and (event as InputEventMouseMotion).relative.length() < 2.0):
		_menu_idle_t = 0.0






	if _modal_up():
		return



	if _practice_on and event is InputEventKey and event.is_action_pressed("ui_cancel")\
	and not event.is_echo():
		_leave_practice()
		get_viewport().set_input_as_handled()
		return




	if _freeplay or _practice_on:
		return



	if _configs != null and _configs.visible:
		for p in _cfg_panels:
			if p.capture(event):
				get_viewport().set_input_as_handled()
				return



	if LocalPlayers.consume_foreign_ui(event):
		get_viewport().set_input_as_handled()
		return
	var _fo: = get_viewport().gui_get_focus_owner()
	if _fo is LineEdit or _fo is TextEdit:
		return



	if event is InputEventMouseButton or (event is InputEventMouseMotion\
	and (event as InputEventMouseMotion).relative.length() > 6.0):






		var going_down: bool = event is InputEventMouseButton and (event as InputEventMouseButton).pressed
		if not going_down and get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_release_focus.call_deferred()
		return
	for a in ["ui_accept", "ui_up", "ui_down", "ui_left", "ui_right"]:
		if event.is_action_pressed(a):
			get_viewport().set_input_as_handled()
			return

func _unhandled_input(event: InputEvent) -> void :
	if _freeplay:
		_motion_collector().feed_motion(event)


		if _fp_views.size() >= 2 and not hud.pause_is_open()\
		and not (_chat != null and _chat.is_typing()):
			if _route_freeplay_camera(event):
				return
	else:

		if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
		elif event is InputEventMouseMotion and _dragging:
			_spin += event.relative.x * 0.012
			player.visual.rotation.y = _base_yaw + _spin






	if _practice_on and event is InputEventKey and event.is_action_pressed("ui_cancel"):
		_leave_practice()
		get_viewport().set_input_as_handled()
		return
	if _freeplay and event is InputEventKey and event.is_action_pressed("ui_cancel"):
		if _tutorial != null:
			return
		if _drill_active != "":
			_leave_drill()
		else:
			_exit_freeplay()

func _process(_delta: float) -> void :


	if not is_inside_tree():
		return
	_tick_practice(_delta)
	_tick_freeplay_time(_delta)




	if not _reform_target.is_empty():
		_drive_reform(_delta)
	_tick_move_cover(_delta)
	_watch_fold_dial(_delta)


	if _server_join_t > 0.0:
		_server_join_t -= _delta
		if _server_join_t <= 0.0:
			_drive_server_join()


	if _modal_up():
		return





	if LocalPlayers.primary_just_pressed("menu_start"):
		if _practice_on:
			_leave_practice()
		elif _freeplay:
			if _tutorial != null:
				pass
			elif _drill_active != "":
				_leave_drill()
			else:
				_exit_freeplay()
		elif not _home.visible:
			_show(_home)
		else:
			_try_freeplay()




	_menu_nav(_delta)




	if not _freeplay and _home != null and _home.visible and player != null:
		var rs: = Input.get_axis("aim_left", "aim_right")
		if absf(rs) > 0.2:
			_spin += rs * 2.6 * _delta
			player.visual.rotation.y = _base_yaw + _spin





	if not _freeplay and InputPrompts.using_gamepad():


		var rv: = Input.get_axis("aim_up", "aim_down")
		if absf(rv) > 0.2:
			var sc: = _visible_scroll()
			if sc != null:
				sc.scroll_vertical += int(rv * 1400.0 * _delta)


	if _friends_panel != null and _friends_panel.visible:



		if _friends_dirty_t >= 0.0:
			_friends_dirty_t -= _delta
			if _friends_dirty_t < 0.0:
				_refresh_friends_panel()
		elif _friends_held and not _friends_hold_order():
			_refresh_friends_panel()
		_friends_poll -= _delta
		if _friends_poll <= 0.0:
			_friends_poll = FRIENDS_POLL
			if _fake_friends_churn:
				_churn_fake_friends(_fake_rng)
			_refresh_friends_panel()

	if _browse != null and _browse.visible\
	and _bw_auto != null and _bw_auto.button_pressed:
		_bw_auto_t -= _delta
		if _bw_auto_t <= 0.0:
			_bw_auto_t = 4.0
			_refresh_browser()
	_place_strips()
	_tilt_cards(_delta)
	_lean_tiles(_delta)

	if not _freeplay:
		_drive_menu_camera(_delta)
	_drive_local_sides(_delta)
	_drive_room_sides(_delta)

	_drive_config_panels(_delta)
	_cfg_left_cd = maxf(_cfg_left_cd - _delta, 0.0)
	_own_name_rule()






	if Net.party and _freeplay:
		_drive_party_freeplay(_delta)
	elif PartySeats.in_party() and not _freeplay:
		_drive_lineup(_delta)
	if not Net.party and ( not _party_bodies.is_empty() or not _party_balls.is_empty()):


		_clear_party_bodies()


	if not _freeplay or hud == null:


		if aim_indicator != null and aim_indicator.visible:
			aim_indicator.visible = false
		return
	if _drill_results != null and _drill_results.visible:
		hud.set_aim_cursor(false, Vector2.ZERO)
		return
	_input_collector.follow_cursor(camera_rig, true)



	for g in _local_guests:
		var kslot: LocalPlayerSlot = g["slot"]
		if kslot.device == DeviceInput.KBM and kslot.collector != null:
			var krig: CameraRig = g.get("rig") if g.get("rig") != null else camera_rig
			kslot.collector.follow_cursor(krig, true)


	if _fp_split():
		hud.set_aim_cursor(false, Vector2.ZERO)
		return




	var ch_col: Color = GameConfig.crosshair_color if GameConfig.crosshair_custom\
	else aim_indicator.tint()
	hud.set_aim_cursor(_input_collector.soft_cursor_active(), 
		_input_collector.soft_cursor_pos(), ch_col, 
		GameConfig.crosshair_shape, GameConfig.crosshair_size, GameConfig.crosshair_outline)
	hud.track_ball_marker(camera_rig.camera, _played_ball(), true, player)

func _physics_process(delta: float) -> void :
	if player == null:
		return
	var input: = PlayerInput.new()
	if _freeplay:


		if _chat != null and _chat.is_typing():
			input = PlayerInput.new()
		elif _drill_results != null and _drill_results.visible:
			input = PlayerInput.new()
		elif _drill_runner != null and _drill_runner.counting_down():
			input = PlayerInput.new()
		elif _tutorial != null and _tutorial.blocking_input():
			input = PlayerInput.new()
		else:
			input = _input_collector.collect(camera_rig, player)
		if _tutorial != null:


			camera_rig.input_frozen = _tutorial.blocking_input() or hud.pause_is_open()
		_poll_freeplay_callouts()
		var side: = 1 if player.global_position.z >= 0.0 else -1
		if side != player.team_side:



			player.team_side = side
			_cam_side_target = float(side)


		camera_rig.home_side = lerpf(camera_rig.home_side, 
			_cam_side_target, clampf(delta * 2.2, 0.0, 1.0))
		ball.home_side = camera_rig.home_side




		if _drill_active != "":
			if _toss_preview != null and not _drill_runner.serve_wanted():
				_toss_preview.clear()


			_serving = _drill_runner.serve_wanted()
			player.touch_barred = not _drill_runner.touch_allowed() or _serving
			player.serve_charge_ui = _serving
			ball.serve_held = _serving
			camera_rig.serve_view = _serving
			hud.set_serve_prompt("")
			if _serving:


				ball.frozen = true
				ball.vel = Vector3.ZERO
				ball.global_position = player.serve_cradle_point()





				var dup: = Ball.serve_toss_up(player.hold_power())
				var dhoriz: = Ball.serve_toss_horiz(player.global_position, 
					_toss_aim(input), player.hold_power(), dup, _toss_deadzone())
				if input.contact_pressed and player.hold_power() > 0.0:
					_toss_preview.show_arc(player.serve_cradle_point(true), 
						Vector3(dhoriz.x, dup, dhoriz.z), Ball.PHYS.gravity, 0.0, 
						TrajectoryPreview.charge_color(player.hold_power()))
				else:
					_toss_preview.clear()
				if player.serve_release_counts(input):
					_serving = false
					_toss_preview.clear()
					player.serve_charge_ui = false
					ball.frozen = false
					ball.serve_assist = true
					ball.toss(player.serve_cradle_point(), dup, dhoriz)
					player.present_serve_toss()
					_drill_runner.serve_tossed()
			_drill_timer.text = _drill_time(int(_drill_runner.elapsed * 1000.0))
		else:


			_tick_my_ball(input)
			player.touch_barred = _serving or not _has_ball_to_play()
			player.serve_charge_ui = _serving
			camera_rig.serve_view = _serving
			ball.serve_held = _serving
			if _serving:
				player.serve_charge_ui = true
				ball.global_position = player.serve_cradle_point()
				hud.set_serve_prompt(
					"Утримуй УДАР і відпусти для підкидання; СТІЙКА — скасувати" if MobileControls.enabled()
					else "hold lmb to charge the toss, release to throw, tap strafe to cancel the charge")
				var up: = Ball.serve_toss_up(player.hold_power())



				var horiz: = Ball.serve_toss_horiz(player.global_position, 
					_toss_aim(input), player.hold_power(), up, _toss_deadzone())


				if player.serve_release_counts(input):
					_serving = false
					player.serve_charge_ui = false
					ball.frozen = false
					ball.serve_assist = true


					ball.toss(player.serve_cradle_point(), up, 
						Vector3(horiz.x, up, horiz.z))
					player.present_serve_toss()
					_toss_preview.clear()
				elif input.contact_pressed:



					_toss_preview.show_arc(player.serve_cradle_point(true), 
						Vector3(horiz.x, up, horiz.z), Ball.PHYS.gravity, 0.0, 
						TrajectoryPreview.charge_color(player.hold_power()))
				else:
					_toss_preview.clear()
			else:
				player.serve_charge_ui = false

				_toss_preview.show_set(player)

				hud.set_serve_prompt("" if _fp_split()\
				else _ball_prompt())


		_foley.tick([player] + _party_live_bodies() + _local_guest_bodies(), 
			delta, sfx, fx)

		var free_cam: = camera_rig.mode == CameraRig.Mode.ACTION\
		or camera_rig.mode == CameraRig.Mode.FIRST_PERSON


		aim_indicator.visible = not free_cam\
		and not (_tutorial != null and _tutorial.blocking_input())
		aim_indicator.ring_enabled = GameConfig.crosshair_ring
		var maim_ib: = absf(input.aim.x) <= COURT_HW and absf(input.aim.z) <= COURT_HL
		aim_indicator.aim_at(input.aim, float(player.team_side), maim_ib)
		hud.set_crosshair_side(input.aim.z, maim_ib)


		var sight_cue: = Rules.half_color(input.aim.z)\
		if GameConfig.aim_color_cue and maim_ib else Color.WHITE
		hud.set_sight_style(GameConfig.crosshair_color if GameConfig.crosshair_custom else sight_cue, 
			GameConfig.crosshair_shape, GameConfig.crosshair_size, GameConfig.crosshair_outline)
		hud.set_dive(player.dive_cooldown)
		hud.update_state(player)




		var split_up: bool = _fp_split()
		hud.set_crosshair_visible(free_cam and not split_up)
		hud.set_hints_hidden(split_up)
		if not split_up:
			hud.refresh_controls(player, _serving)
		var mark_ball: = _played_ball()
		reach_marker.drive(player, mark_ball, 
			GameConfig.reach_marker and not mark_ball.frozen)
	else:
		player.touch_barred = true
		input.aim = _aim_at_cam
		player.aim_point = _aim_at_cam



	player.free_actions = _freeplay
	player.simulate(input, delta)



	for g in _local_guests:
		var gp: Player = g["player"]
		if gp == null or not is_instance_valid(gp):
			continue
		var slot: LocalPlayerSlot = g["slot"]
		var gin: = PlayerInput.new()


		var grig: CameraRig = g.get("rig") if g.get("rig") != null else camera_rig
		if _freeplay and slot.connected and slot.collector != null:
			gin = slot.collector.collect(grig, gp)
		else:
			gp.touch_barred = true
			gin.aim = _aim_at_cam
			gp.aim_point = _aim_at_cam
		gp.free_actions = _freeplay
		gp.simulate(gin, delta)

		var gaim = g.get("aim")
		if gaim != null and is_instance_valid(gaim):
			var free_cam: bool = grig.mode == CameraRig.Mode.ACTION\
			or grig.mode == CameraRig.Mode.FIRST_PERSON
			gaim.visible = _freeplay and slot.connected and not free_cam
			gaim.ring_enabled = slot.profile.crosshair_ring if slot.profile != null\
			else GameConfig.crosshair_ring
			var gin_ib: = absf(gin.aim.x) <= COURT_HW and absf(gin.aim.z) <= COURT_HL
			gaim.aim_at(gin.aim, float(gp.team_side), gin_ib)
		var greach = g.get("reach")
		if greach != null and is_instance_valid(greach):
			greach.drive(gp, ball, 
				_freeplay and slot.connected and GameConfig.reach_marker and not ball.frozen)
	if _drill_active != "" and _drill_runner != null:
		_drill_runner.physics_tick(delta, 
			(_chat != null and _chat.is_typing())
			or (_tutorial != null and _tutorial.blocking_input()))
	player.global_position.x = clampf(player.global_position.x, 
		- HALL_X, HALL_X)
	player.global_position.z = clampf(player.global_position.z, 
		- HALL_Z, HALL_Z)



	if _freeplay and _drill_active == "":


		var driven: = _driven_balls() if Net.party else ({0: ball} if _ball_out else {})







		var bodies: Array = [player] + _party_live_bodies()
		for g in _local_guests:
			if g["player"] != null and is_instance_valid(g["player"]):
				bodies.append(g["player"])
		for bid in driven:
			var db: = driven[bid] as Ball

			var prev: Array = _fp_ball_prev.get(bid, [])
			var path_from: Vector3 = prev[0] if prev.size() == 2\
			and int(prev[1]) == db.strike_seq else Vector3.INF


			if int(_fp_hit_side.get(bid, [0, -1])[1]) != db.strike_seq:
				_fp_hit_side[bid] = [int(signf(db.global_position.z)), db.strike_seq]
			if db.strike_seq != int(_carom_seen.get(bid, -1)):




				var hit: = Rules.body_hit(db, path_from, bodies, 
					int(_fp_hit_side[bid][0]), true)
				if not hit.is_empty() and not (hit[0] as Player).held_receive_save():
					var hb: Player = hit[0]
					var blocking: = Rules.body_blocking(hb, db)
					var bvin: = db.vel
					var bkind: = db.last_hit_kind
					var bpw: = db.body_deflect(hb, hit[1], db.strike_seq, 
						Player.TouchKind.BLOCK if blocking else Player.TouchKind.CAROM)
					_carom_seen[bid] = db.strike_seq


					if Rules.body_knocks(hb, bkind, bpw):
						hb.knock_off_ball(bvin)
					hb.body_hit(bpw, blocking)
					if hb == player:
						camera_rig.shake(0.08 + 0.18 * bpw)
			if db.strike_seq != int(_carom_seen.get(bid, -1)):
				var who: = Rules.carom_body(db, bodies, path_from)
				if who != null:
					var vin: = db.vel
					var pw: = db.carom(who, db.strike_seq)
					_carom_seen[bid] = db.strike_seq
					if pw >= 1.0:
						who.knock_off_ball(vin)
					who.carom_hit(pw)
					if who == player:
						camera_rig.shake(0.08 + 0.18 * pw)
			_fp_ball_prev[bid] = [db.global_position, db.strike_seq]
			var bp: = db.global_position
			if absf(bp.x) > HALL_X + 2.0 or absf(bp.z) > HALL_Z + 2.0\
			or bp.y < -2.0:
				db.toss(Vector3(0.0, 1.0, 1.5), 4.0)



		for sq in Rules.stomps(bodies, GameConfig.team_collision):
			var vpos: Vector3 = sq.pos
			if fx != null:
				fx.land_poof(vpos)
				fx.floor_gust(vpos, true)
			if sfx != null:
				sfx.play("block_soft", vpos, -1.0, 0.75)
				sfx.play("squash", vpos, 0.0, 1.0)
			if sq.victim == player or sq.stomper == player:
				camera_rig.shake(0.3)
			if Net.party and _freeplay:
				Net.send_freeplay_fx(-4, vpos, 0.0, Vector3.UP)



	if Net.party and Net.active:
		_fp_send_tick += 1


		var st: = player.net_capture()
		st.append(1.0 if _freeplay else 0.0)
		Net.send_freeplay_pose(st)
		if _fp_send_tick % 3 == 0:

			var driven: = _driven_balls()
			for bid in driven:
				var db: = driven[bid] as Ball
				var pose: = db.net_capture()
				pose.append(float(int(_ball_gen.get(int(bid), 0))))


				pose.append(db.stop_clock)
				Net.send_ball_pose(pose, int(bid))
