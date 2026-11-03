class_name MobileRender
extends RefCounted

const MENU := "res://game/mobile/mobile_menu.tscn"
const MATCH := "res://game/mobile/mobile_main.tscn"
const PLAYER := "res://game/mobile/mobile_player.tscn"

static func enabled() -> bool:
	return bool(ProjectSettings.get_setting("application/config/mobile_build", false)) \
		or OS.has_feature("ios") or OS.has_feature("android") \
		or OS.get_cmdline_user_args().has("--mobile-preview")

static func apply() -> void:
	if not enabled():
		return
	GameConfig.apply_quality(GameConfig.QUALITY_LOW)
	GameConfig.max_fps = 60 if GameConfig.max_fps == 60 else 30
	GameConfig.resolution_3d = clampi(GameConfig.resolution_3d, 50, 75)
	GameConfig.msaa = 0
	GameConfig.root_ui_aa = false
	GameConfig.contour_outline = false
	GameConfig.crowd_enabled = false
	GameConfig.camera_occlusion = false
	GameConfig.net_see_through = false
	GameConfig.replay_capture = false
	GameConfig.match_intro = false
	GameConfig.aim_assist = true
	GameConfig.set_assist = true
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.msaa_2d = Viewport.MSAA_DISABLED
		tree.root.msaa_3d = Viewport.MSAA_DISABLED
		tree.root.use_hdr_2d = false
		tree.root.positional_shadow_atlas_size = 0
		# Bound the actual render target on Retina screens, including GLES.
		tree.root.content_scale_size = Vector2i(1280, 720)
		tree.root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		tree.root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
