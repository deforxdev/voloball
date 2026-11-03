extends "res://game/mobile/mobile_menu.gd"

var _host_test := false
var _count := 2
var _elapsed := 0.0
var _full_since := 0.0
var _matched := false
var _packets := 0

func _ready() -> void:
	super._ready()
	var args := OS.get_cmdline_user_args()
	_host_test = args.has("--lan-host")
	for arg in args:
		if arg.begins_with("--lan-count="):
			_count = int(arg.trim_prefix("--lan-count="))
	Net.ball_snapshot_received.connect(_ball_packet)
	_name.text = "Host" if _host_test else "Client-%d" % OS.get_process_id()
	if _host_test:
		_host()
	else:
		_address.text = "127.0.0.1:%d" % Net.host_port()
		_join()

func leave_for_match() -> void:
	pass

func _process(delta: float) -> void:
	super._process(delta)
	_elapsed += delta
	if _elapsed > 60:
		push_error("LAN TEST TIMEOUT")
		get_tree().quit(1)
	if not _host_test:
		return
	if Net.human_count() == _count and not _matched:
		_full_since += delta
		if _full_since > 2:
			_start_match()
	if _matched:
		Net.send_ball_snapshot(PackedFloat32Array([1, 2, 3, 4, 5, 6]))
		_packets += 1
		if _packets > 120:
			print("LAN HOST PASS: players=%d, roster and ball packets sent" % _count)
			get_tree().quit()

func _match_started(roster: Array) -> void:
	if roster.size() != maxi(2, _count + _count % 2):
		push_error("Wrong roster size: %d" % roster.size())
		get_tree().quit(1)
		return
	var humans := 0
	for slot in roster:
		if slot.get("peer", 0) != 0:
			humans += 1
	if humans != _count:
		push_error("Wrong human count in roster: %d" % humans)
		get_tree().quit(1)
		return
	_matched = true
	print("LAN MATCH PASS: %d humans, %d seats" % [humans, roster.size()])
	if OS.get_cmdline_user_args().has("--lan-play"):
		super._match_started(roster)

func _ball_packet(packet: PackedFloat32Array) -> void:
	if not _matched or packet.size() != 6 or packet[2] != 3:
		return
	_packets += 1
	if _packets == 5:
		print("LAN CLIENT PASS: roster received, ball replication received")

func _ended(reason: String) -> void:
	super._ended(reason)
	if _matched and not _host_test:
		get_tree().quit()
