class_name MatchRewards
extends PanelContainer








signal finished

const GREEN: = UiStyle.CHIP
const GREEN_DEEP: = UiStyle.CHIP_DEEP
const GREEN_LIGHT: = Color("a6f7b4")
const FLASH: = Color("c8ffb0")

var _s: = {}
var _disc: PanelContainer
var _disc_box: StyleBoxFlat
var _disc_num: Label
var _gain: Label
var _count: Label
var _bar: LiquidBar
var _levelup: Label
var _coin_gain: Label
var _purse: HBoxContainer

var _tween: Tween
var _shown_level: = 1
var _shown_coins: = 0
var _coins_target: = 0
var _last_tick: = -1
var _done: = false

func _init() -> void :
	set_meta("no_wash", true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.42)
	box.set_corner_radius_all(18)
	box.set_content_margin_all(12.0)
	box.content_margin_left = 16.0
	box.content_margin_right = 22.0
	add_theme_stylebox_override("panel", box)
	tooltip_text = "click to skip"

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)


	_disc = PanelContainer.new()
	_disc.custom_minimum_size = Vector2(62, 62)
	_disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ds: = StyleBoxFlat.new()
	ds.bg_color = GREEN
	ds.set_corner_radius_all(99)
	ds.border_color = UiStyle.INK
	ds.set_border_width_all(3)
	_disc.add_theme_stylebox_override("panel", ds)
	_disc_box = ds
	ds.shadow_color = Color(FLASH, 0.0)
	ds.shadow_size = 14
	var dv: = VBoxContainer.new()
	dv.alignment = BoxContainer.ALIGNMENT_CENTER
	dv.add_theme_constant_override("separation", -9)
	dv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disc.add_child(dv)
	var cap: = _label("lv", 13, Color.WHITE, UiStyle.FONT_XBOLD, 3, GREEN_DEEP)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dv.add_child(cap)
	_disc_num = _label("1", 26, Color.WHITE, UiStyle.FONT_BLACK, 5, GREEN_DEEP)
	_disc_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dv.add_child(_disc_num)
	row.add_child(_disc)


	var xcol: = VBoxContainer.new()
	xcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xcol.alignment = BoxContainer.ALIGNMENT_CENTER
	xcol.add_theme_constant_override("separation", 6)
	xcol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(xcol)


	var over: = MarginContainer.new()
	over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xcol.add_child(over)
	var top: = HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	over.add_child(top)
	_gain = _label("+0 xp", 24, GREEN_LIGHT, UiStyle.FONT_BLACK, 6, Color.BLACK)
	_gain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_gain)
	_count = _label("", 15, Color(1, 1, 1, 0.85), UiStyle.FONT_XBOLD, 4, Color.BLACK)
	_count.size_flags_vertical = Control.SIZE_SHRINK_END
	top.add_child(_count)
	_levelup = _label("level up!", 26, GREEN_LIGHT, UiStyle.FONT_BLACK, 7, Color.BLACK)
	_levelup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_levelup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_levelup.modulate.a = 0.0
	over.add_child(_levelup)
	_bar = LiquidBar.new(Color(0, 0, 0, 0.35), 26.0)
	xcol.add_child(_bar)


	var ccol: = VBoxContainer.new()
	ccol.custom_minimum_size.x = 140
	ccol.alignment = BoxContainer.ALIGNMENT_CENTER
	ccol.add_theme_constant_override("separation", 2)
	ccol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ccol)

	_coin_gain = _label("+0", 24, GREEN, UiStyle.FONT_BLACK, 6, Color.BLACK)
	_coin_gain.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ccol.add_child(_coin_gain)
	_purse = UiStyle.currency_chip(0, "title", 24)
	_purse.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var purse_lbl: Label = _purse.get_meta("value")
	purse_lbl.add_theme_color_override("font_color", Color.WHITE)
	purse_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	purse_lbl.add_theme_constant_override("outline_size", 6)
	ccol.add_child(_purse)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed\
	and event.button_index == MOUSE_BUTTON_LEFT:
		skip()


func play(summary: Dictionary, delay: = 0.6) -> void :
	_s = summary
	var start_level: = int(_s.get("start_level", _s.get("level", 1)))
	_shown_level = start_level
	_shown_coins = int(_s.get("coins_before", 0))
	_coins_target = int(_s.get("coins_total", _shown_coins))
	_disc_num.text = str(start_level)
	_count_text(start_level, int(_s.get("start_xp", 0)))
	_bar.fill = _fill_of(start_level, int(_s.get("start_xp", 0)))
	UiStyle.set_currency(_purse, _shown_coins)
	_coin_gain.text = "+0"
	_tween = create_tween()
	_tween.tween_interval(delay)
	var gain: = _gain_xp()
	var levels: = int(_s.get("levels_gained", 0))
	var dur: = clampf(1.0 + levels * 0.45 + gain / 500.0, 1.1, 3.2)
	_tween.tween_method(_set_xp, 0.0, gain, dur)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(_pay_match_chips)


func _gain_xp() -> float:
	if int(_s.get("start_level", 1)) >= Progression.LEVEL_MAX:
		return 0.0
	return float(_s.get("xp_gain", 0))


func skip() -> void :
	if _done or _s.is_empty():
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_set_xp(_gain_xp(), true)
	_shown_coins = _coins_target
	UiStyle.set_currency(_purse, _shown_coins)
	_coin_gain.text = "+%s" % UiStyle.commafy(int(_s.get("coins_match", 0)))
	_finish()

func _fill_of(level: int, into: int) -> float:
	if level >= Progression.LEVEL_MAX:
		return 1.0
	return float(into) / float(maxi(1, Progression.xp_for_next(level)))

func _count_text(level: int, into: int) -> void :
	_count.text = "max level" if level >= Progression.LEVEL_MAX\
	else "%s / %s xp" % [UiStyle.commafy(into), UiStyle.commafy(Progression.xp_for_next(level))]


func _set_xp(v: float, quiet: = false) -> void :
	var start_level: = int(_s.get("start_level", 1))
	var cost: = float(Progression.LEVEL_COST)
	var total: = float(_s.get("start_xp", 0)) + v
	var level: = mini(start_level + int(floor(total / cost)), Progression.LEVEL_MAX)
	var into: = int(total - float(level - start_level) * cost)
	if level >= Progression.LEVEL_MAX:
		into = 0
	while _shown_level < level:
		_shown_level += 1
		_level_up(_shown_level, quiet)
	_disc_num.text = str(_shown_level)
	_gain.text = "+%s xp" % UiStyle.commafy(int(round(v)))
	_count_text(level, into)
	_bar.fill = _fill_of(level, into)

	var step: = int(v / maxf(1.0, _gain_xp()) * 14.0)
	if not quiet and step != _last_tick:
		_last_tick = step
		UiStyle.sfx("tick", 0.9 + 0.05 * step)

func _level_up(level: int, quiet: bool) -> void :


	_bar.flash()
	_disc.pivot_offset = _disc.size * 0.5
	_disc.scale = Vector2.ONE * 1.35
	create_tween().tween_property(_disc, "scale", Vector2.ONE, 0.35)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash_disc()
	_levelup.text = "max level!" if level >= Progression.LEVEL_MAX else "level up!"
	_levelup.modulate.a = 1.0
	_levelup.pivot_offset = _levelup.size * 0.5
	_levelup.scale = Vector2.ONE * 0.6
	var lt: = create_tween()
	lt.tween_property(_levelup, "scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	lt.tween_interval(0.9)
	lt.tween_property(_levelup, "modulate:a", 0.0, 0.4)
	if quiet:
		return
	UiStyle.sfx("level_up")
	UiStyle.click_burst(_disc, GREEN)
	UiStyle.chip_fly(_disc.get_global_rect().get_center(), _purse, 
		Progression.LEVELUP_COINS, _land)


func _flash_disc() -> void :
	var t: = create_tween()
	for i in 2:
		t.tween_method(_disc_lit, 1.0, 0.0, 0.32 if i == 0 else 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _disc_lit(k: float) -> void :
	_disc_box.bg_color = GREEN.lerp(FLASH, k)
	_disc_box.shadow_color = Color(FLASH, 0.85 * k)

func _pay_match_chips() -> void :
	var paid: = int(_s.get("coins_match", 0))
	if paid <= 0:
		_finish()
		return
	_coin_gain.text = "+%s" % UiStyle.commafy(paid)
	_coin_gain.pivot_offset = _coin_gain.size * 0.5
	_coin_gain.scale = Vector2.ONE * 1.3
	create_tween().tween_property(_coin_gain, "scale", Vector2.ONE, 0.25)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	UiStyle.chip_fly(_coin_gain.get_global_rect().get_center(), _purse, paid, 
		_land, _finish)



func _land(share: int) -> void :
	_shown_coins = mini(_shown_coins + share, _coins_target)
	UiStyle.set_currency(_purse, _shown_coins)

func _finish() -> void :
	if _done:
		return
	_done = true
	UiStyle.set_currency(_purse, _coins_target)
	finished.emit()

func _label(text: String, sz: int, col: Color, font_path: String, 
		outline: = 0, outline_col: = Color.BLACK) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", UiStyle.font(font_path))
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	if outline > 0:
		l.add_theme_color_override("font_outline_color", outline_col)
		l.add_theme_constant_override("outline_size", outline)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
