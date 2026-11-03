class_name Stage
extends RefCounted




















const SUNSET_SKY: = "res://game/court/anime_sky_sunset.gdshader"



const SPACE_SKY: = "res://game/court/space_sky.gdshader"

const NIGHT_SKY: = "res://game/court/anime_sky_night.gdshader"



const NIGHT_SKY_MAT: = "res://game/court/night_sky_mat.tres"

const ARENA_SKY_MAT: = preload("res://game/court/arena_haze_sky_mat.tres")

const EVENING_SKY: = "res://game/court/anime_sky_evening.gdshader"

const SLATE_SKY: = "res://game/court/slate_sky.gdshader"







const SKY_RADIANCE: = Sky.RADIANCE_SIZE_32










const TOD_EVENING: = {
	"sky_material": null, "sky_shader": EVENING_SKY, 
	"fog_color": Color(0.93, 0.66, 0.52), "sun": 0.85, 
	"world_tint": Vector3(1.0, 0.62, 0.42), 
	"body_tint": Vector3(1.0, 0.8, 0.66), 
	"lake_sky": {"top_color": Color(0.62, 0.42, 0.58), "horizon_color": Color(1.0, 0.7, 0.42), 
		"cloud_color": Color(1.0, 0.84, 0.74), "cloud_shade": Color(0.8, 0.5, 0.64)}, 
}
const TOD_NIGHT: = {
	"sky_material": NIGHT_SKY_MAT, "sky_shader": NIGHT_SKY, 
	"fog_color": Color(0.1, 0.14, 0.27), "sun": 0.3, 
	"world_tint": Vector3(0.11, 0.15, 0.3), 
	"body_tint": Vector3(0.36, 0.44, 0.74), 
	"body_rim": 0.5, 
	"lake_sky": {"top_color": Color(0.03, 0.05, 0.16), "horizon_color": Color(0.16, 0.24, 0.46), 
		"cloud_color": Color(0.34, 0.4, 0.62), "cloud_shade": Color(0.16, 0.2, 0.36), 
		"cloud_cover": 0.42}, 
}


const TOD_EVENING_LAKE: = {
	"sky_material": null, "sky_shader": EVENING_SKY, 
	"fog_color": Color(0.93, 0.66, 0.52), "sun": 0.85, 
	"world_tint": Vector3(1.0, 0.78, 0.62), 
	"body_tint": Vector3(1.0, 0.8, 0.66), 
	"lake_sky": {"top_color": Color(0.62, 0.42, 0.58), "horizon_color": Color(1.0, 0.7, 0.42), 
		"cloud_color": Color(1.0, 0.84, 0.74), "cloud_shade": Color(0.8, 0.5, 0.64)}, 
}
const TOD_NIGHT_LAKE: = {
	"sky_material": NIGHT_SKY_MAT, "sky_shader": NIGHT_SKY, 
	"fog_color": Color(0.1, 0.14, 0.27), "sun": 0.3, 
	"world_tint": Vector3(0.16, 0.21, 0.42), 
	"body_tint": Vector3(0.4, 0.48, 0.78), 
	"body_rim": 0.5, 
	"lake_sky": {"top_color": Color(0.03, 0.05, 0.16), "horizon_color": Color(0.16, 0.24, 0.46), 
		"cloud_color": Color(0.34, 0.4, 0.62), "cloud_shade": Color(0.16, 0.2, 0.36), 
		"cloud_cover": 0.42}, 
}



const DREAM_SKY: = preload("res://game/court/dream_sky.gdshader")



const DREAM_SKY_MAT: = preload("res://game/court/dream_sky.tres")



const SHIELD_BLUE: = Color(0.25, 0.6, 1.0)

const STAGES: = {
	"mobile": {
		"title": "Mobile Court", "demo": true,
		"venue": "res://game/mobile/mobile_arena.tscn",
		"surface": "court", "reflect": false, "crowd": false,
		"use_sky_color": true, "sky_color": Color(0.16, 0.25, 0.32),
		"anime_sky": false, "fog": false, "bloom": false,
		"floor_color": Color(0.24, 0.48, 0.66),
		"lines": Color.WHITE, "tape": Color.WHITE,
		"cord": Color(0.04, 0.04, 0.04),
		"pole": Color(0.9, 0.3, 0.18), "pad": Color(0.9, 0.3, 0.18),
	},
	"nationals": {
		"reverb": {"room": 0.9, "damp": 0.5, "wet": 0.19, "predelay": 35.0, "hipass": 0.2}, 
		"title": "Nationals Arena", 









		"venue": "res://game/stage/kits/nationals.tscn", 
		"look": "res://game/stage/nationals_arena_look.tres", 




		"cam_box": AABB(Vector3(-15.5, 0.6, -33.0), Vector3(31.0, 14.4, 66.0)), 






		"sun_windows": {"dir": Vector3(0.57, 0.82, 0.0), "amount": 0.0, 
			"color": Color(1.0, 1.0, 1.0), "roof_y": 44.46, "roof_fall": 0.2416, 
			"glass_from": 39.4, "glass_to": 56.9, "step": 7.0, "width": 4.5, 
			"half_run": 51.5, "soft": 0.5}, 




		"floor_gloss": {"amount": 0.0, "streak": 9.0, "side_x": 11.4, "side_run": 32.5, 
			"side_step": 4.06, "end_z": 37.5, "end_run": 8.75, "end_step": 2.92}, 




		"body_light": {"overhead": 0.0, "rim": 0.0, "rim_width": 0.6, "pool_dim": 0.0, 
			"pool": Vector2(8.0, 14.0), "pool_fall": 7.0}, 


		"swoop_top": 12.6, 

		"force_wall": false, 


		"court_marks": true, 



		"crowd": true, 




		"crowd_haze": 0.45, 


		"crowd_haze_color": Color(0.12, 0.125, 0.135), 





		"crowd_shade": {"desat": 0.12, "contrast": 1.0, "depth_dim": 0.45, "depth_hi": 30.0, 
			"far_desat": 0.15, "far_contrast": 0.0, "far_start": 20.0, "far_end": 70.0, 
			"glow_sticks": 0.18, "haze_start": 14.0, "haze_end": 55.0}, 


		"sky_material": ARENA_SKY_MAT, 




		"fog": true, 
		"fog_color": Color(0.42, 0.44, 0.5), 
		"fog_begin": 400.0, 
		"fog_end": 800.0, 
		"fog_height": 27.0, 
		"fog_height_density": 0.05, 


		"freeplay_relight": false, 

		"pad": Color(0.2, 0.36, 0.82), 
		"pole": Color(0.78, 0.8, 0.85), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.0, 0.0, 0.0), 
		"lines": Color(0.95, 0.95, 0.95), 
		"floor_color": Color(0.93, 0.6, 0.36), 


		"pool_strength": 0.3, 
		"barefoot": false, 
		"ball": "res://game/ball/models/national_ball.glb",
		"ball_tex": "res://game/ball/textures/nationaldif_SD.png", 
	}, 
	"school": {
		"reverb": {"room": 0.72, "damp": 0.58, "wet": 0.15, "predelay": 20.0, "hipass": 0.15}, 
		"title": "School Gym", 
		"beta_hidden": true, 



		"demo": true, 



		"venue": "res://game/stage/kits/school.tscn", 




		"look": "res://game/stage/school_look.tres", 




		"force": {"exposure": 1.0}, 


		"owns_floor": true, 


		"court_marks": true, 
		"collision_box": Vector3(22, 14, 30), 
		"force_wall": true, 
		"force_wall_color": SHIELD_BLUE, 




		"fog": true, 


		"fog_color": Color(0.62, 0.61, 0.6), 
		"fog_begin": 30.0, 
		"fog_end": 110.0, 
		"fog_height": 14.5, 
		"fog_height_density": 0.4, 

		"crowd": true, 
		"crowd_lift": 0.1, 


		"crowd_tint": Color(1, 1, 1), 
		"crowd_haze": 0.0, 
		"crowd_shade": {"desat": 0.08, "contrast": 1.0, "depth_dim": 0.18, "depth_hi": 24.0, 
			"far_desat": 0.22, "far_contrast": 0.12, "far_start": 20.0, "far_end": 48.0}, 
		"accent_pads": true, 


		"mirror_overlay": true, 
		"pool_strength": 0.7, 
		"floor_vignette": 0.3, 
		"pad": Color(0.72, 0.15, 0.14), 
		"pole": Color(0.4, 0.36, 0.38), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.0, 0.0, 0.0), 
		"lines": Color(0.97, 0.97, 0.95), 
		"floor_color": Color(0.74, 0.54, 0.32), 
		"barefoot": false, 
		"ball": "res://game/ball/models/jv_ball.glb",
		"ball_tex": "res://game/ball/textures/jvball_diff_SD.png", 
	}, 





	"practice": {
		"base": "school", 
		"variant": true, 



		"quick": true, 
		"title": "School Gym (practice)", 


		"demo": true, 
		"force": {
			"casual": true, 
			"crowd": false, 
			"scrimmage_pinny": true, 
			"exposure": 1.0, 
		}, 
	}, 







	"jpgym": {
		"reverb": {"room": 0.75, "damp": 0.6, "wet": 0.16, "predelay": 22.0, "hipass": 0.15}, 
		"title": "Japanese Gym", 
		"venue": "res://game/stage/kits/jpgym.tscn", 
		"look": "res://game/stage/jpgym_look.tres", 





		"owns_floor": true, 









		"collision_box": Vector3(13, 18, 24), 




		"cam_box": AABB(Vector3(-12.5, 0.6, -30.5), Vector3(25.0, 10.8, 61.0)), 




		"force_wall": false, 




		"fog": true, 
		"fog_color": Color(0.93, 0.94, 0.93), 
		"fog_begin": 36.0, 
		"fog_end": 100.0, 
		"fog_height": 14.0, 
		"fog_height_density": 0.16, 

		"casual": true, 
		"scrimmage_pinny": true, 
		"crowd": false, 

		"mirror_overlay": true, 
		"pool_strength": 0.85, 
		"floor_vignette": 0.32, 

		"pad": Color(0.16, 0.16, 0.2), 
		"pole": Color(0.4, 0.36, 0.38), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.0, 0.0, 0.0), 
		"lines": Color(0.97, 0.97, 0.95), 
		"floor_color": Color(0.78, 0.58, 0.36), 
		"barefoot": false, 

		"ball": "res://game/ball/models/jv_ball.glb",
		"ball_tex": "res://game/ball/textures/jvball_diff_SD.png", 
	}, 




	"clouds": {
		"title": "Clouds", 
		"tod": ["day", "evening", "night"], 

		"tod_looks": {1: TOD_EVENING_LAKE, 2: TOD_NIGHT_LAKE}, 
		"bonus": true, 
		"venue": "res://game/stage/kits/clouds.tscn", 
		"owns_floor": true, 
		"mirror_overlay": true, 
		"sky_mirror": true, 
		"collision_box": Vector3(22, 14, 30), 
		"force_wall": true, 
		"force_wall_color": SHIELD_BLUE, 
		"anime_sky": true, 
		"sun": 1.1, 
		"reflect": true, 
		"crowd": false, 
		"casual": true, 
		"barefoot": false, 
		"surface": "court", 
		"water_x": -1000000000.0, 
		"water_side": 1.0, 



		"fog": false, 
		"pool_strength": 0.0, 
		"floor_vignette": 0.0, 
		"pad": Color(0.97, 0.97, 0.99), 
		"pole": Color(0.9, 0.93, 0.98), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.12, 0.14, 0.2), 
		"lines": Color(1.0, 1.0, 1.0), 
		"floor_color": Color(0.6, 0.75, 0.95), 
		"ball": "res://game/ball/models/outdoorball.glb",
		"ball_tex": "res://game/ball/textures/outdoor_dif_SD.png", 
	}, 








	"outer_space": {
		"title": "Outer Space", 
		"bonus": true, 
		"quick": true, 


		"reverb": {"room": 0.95, "damp": 0.4, "wet": 0.22, "predelay": 40.0, "hipass": 0.1}, 
		"venue": "res://game/stage/kits/outer_space.tscn", 
		"owns_floor": true, 
		"anime_sky": true, 
		"sky_shader": SPACE_SKY, 
		"collision_box": Vector3(22, 14, 30), 
		"force_wall": true, 
		"force_wall_color": SHIELD_BLUE, 
		"sun": 1.1, 
		"reflect": false, 
		"crowd": false, 
		"casual": true, 
		"barefoot": false, 


		"surface": "moon", 


		"fog": true, 
		"fog_color": Color(0.5, 0.62, 0.8), 
		"fog_begin": 55.0, 
		"fog_end": 210.0, 
		"pool_strength": 0.0, 
		"floor_vignette": 0.0, 

		"pad": Color(0.03, 0.03, 0.04), 
		"pole": Color(0.04, 0.04, 0.05), 
		"tape": Color(0.95, 0.97, 1.0), 
		"cord": Color(0.08, 0.1, 0.16), 
		"lines": Color(0.03, 0.03, 0.04), 
		"floor_color": Color(0.6, 0.61, 0.66), 
		"ball": "res://game/ball/models/outdoorball.glb",
		"ball_tex": "res://game/ball/textures/outdoor_dif_SD.png", 
	}, 







	"void": {
		"title": "Training Space", 
		"hidden": true, 
		"demo": true, 
		"venue": "res://game/stage/kits/void.tscn", 





		"anime_sky": true, 
		"sky_material": DREAM_SKY_MAT, 
		"sky_shader": DREAM_SKY, 
		"exposure": 0.92, 
		"owns_floor": true, 
		"fog": true, 
		"fog_color": Color(0.9, 0.94, 0.98), 
		"fog_begin": 40.0, 
		"fog_end": 135.0, 
		"reflect": false, 
		"crowd": false, 
		"casual": true, 
		"barefoot": false, 
		"surface": "court", 
		"collision_box": Vector3(24, 14, 32), 
		"force_wall": false, 
		"pool_strength": 0.0, 
		"floor_vignette": 0.0, 


		"floor_color": Color(0.94, 0.96, 0.98), 
		"lines": Color(0.4, 0.55, 0.82), 
		"pad": Color(0.7, 0.78, 0.95), 
		"pole": Color(0.66, 0.74, 0.94), 
		"tape": Color(0.9, 0.93, 1.0), 
		"cord": Color(0.3, 0.36, 0.52), 
	}, 







	"tutorial": {
		"base": "void", 



		"hidden": false, 
		"title": "Tutorial", 
		"tod": ["light", "dark"], 



		"tod_looks": {1: {"sky_material": null, "sky_shader": SLATE_SKY, 
			"fog_color": Color(0.18, 0.2, 0.3), 
			"world_tint": Vector3(0.035, 0.042, 0.07), 
			"body_tint": Vector3(0.62, 0.68, 0.86), 
			"lines": Color(0.45, 0.65, 1.0)}}, 


		"demo": true, 



		"surface": "training", 


		"force_wall": false, 

		"ball": "res://game/ball/models/national_ball.glb",
		"ball_tex": "res://game/ball/textures/nationaldif_SD.png", 
	}, 
	"training": {
		"reverb": {"room": 0.85, "damp": 0.55, "wet": 0.16, "predelay": 30.0, "hipass": 0.15}, 
		"title": "Training Centre", 
		"hidden": true, 
		"venue": "res://game/stage/kits/training.tscn", 
		"crowd": false, 
		"pad": Color(0.12, 0.56, 0.52), 
		"pole": Color(0.86, 0.87, 0.9), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.05, 0.05, 0.08), 
		"lines": Color(0.97, 0.97, 0.95), 
		"floor_color": Color(0.2, 0.34, 0.6), 
		"ball": "res://game/ball/models/national_ball.glb",
		"ball_tex": "res://game/ball/textures/nationaldif_SD.png", 
	}, 
	"beach": {
		"title": "Beach", 

		"venue": "res://game/stage/kits/beach.tscn", 
		"owns_floor": true, 
		"collision_box": Vector3(24, 14, 32), 
		"force_wall": true, 
		"force_wall_color": SHIELD_BLUE, 
		"fog": true, 
		"fog_color": Color(0.72, 0.82, 0.92), 
		"fog_begin": 42.0, 
		"fog_end": 120.0, 
		"anime_sky": true, 
		"sky": Color(0.5, 0.74, 0.95), 
		"sun": 1.25, 
		"reflect": false, 
		"surface": "sand", 


		"water_x": 13.0, 





		"sand_grade": true, 
		"sand_grade_near": Color(1.22, 1.02, 0.62), 
		"sand_grade_far": Color(0.58, 0.48, 0.36), 
		"sand_grade_dir": Vector2(1.0, 0.0), 
		"sand_grade_from": -26.0, 
		"sand_grade_to": 14.0, 
		"crowd": false, 
		"barefoot": true, 
		"casual": true, 


		"pad": Color(0.09, 0.11, 0.2), 
		"pole": Color(0.85, 0.85, 0.82), 
		"tape": Color(0.97, 0.97, 0.95), 
		"cord": Color(0.05, 0.05, 0.08), 
		"lines": Color(0.2, 0.4, 0.85), 
		"floor_color": Color(0.92, 0.85, 0.68), 
		"ball": "res://game/ball/models/outdoorball.glb",
		"ball_tex": "res://game/ball/textures/outdoor_dif_SD.png", 
	}, 
	"grass": {
		"title": "Grass Court", 
		"tod": ["day", "evening", "night"], 
		"tod_looks": {1: TOD_EVENING, 2: TOD_NIGHT}, 
		"demo": true, 
		"demo_day_only": true, 

		"venue": "res://game/stage/kits/grass.tscn", 
		"owns_floor": true, 
		"collision_box": Vector3(24, 14, 32), 
		"force_wall": true, 
		"force_wall_color": SHIELD_BLUE, 
		"fog": true, 
		"fog_color": Color(0.6, 0.75, 0.9), 
		"fog_begin": 30.0, 
		"fog_end": 95.0, 
		"anime_sky": true, 
		"sky": Color(0.55, 0.76, 0.95), 
		"sun": 1.2, 
		"reflect": false, 
		"surface": "grass", 
		"crowd": false, 
		"barefoot": false, 
		"casual": true, 
		"pad": Color(0.82, 0.16, 0.15), 
		"pole": Color(0.82, 0.16, 0.15), 
		"tape": Color(0.96, 0.96, 0.93), 
		"cord": Color(0.05, 0.05, 0.08), 
		"lines": Color(0.98, 0.84, 0.16), 
		"floor_color": Color(0.3, 0.5, 0.26), 
		"ball": "res://game/ball/models/outdoorball.glb",
		"ball_tex": "res://game/ball/textures/outdoor_dif_SD.png", 
	}, 



}




static func ids(with_variants: = true) -> Array:
	var out: = []
	for id in STAGES:
		if not _listed(id):
			continue
		if with_variants or not bool(STAGES[id].get("variant", false)):
			out.append(id)
	return out




static func freeplay_ids() -> Array:
	var out: = ids(false)
	for id in ids():
		if id in out:
			continue
		var base: = String(STAGES[id].get("base", ""))
		if base != "" and not base in out:
			out.append(id)
	return out



static func _listed(id: String) -> bool:
	var s: Dictionary = STAGES[id]
	if bool(s.get("hidden", false)):
		return false
	if LaunchGate.is_demo():


		if not bool(s.get("demo", false)) or bool(s.get("demo_hidden", false)):
			return false
	elif LaunchGate.public_beta() and bool(s.get("beta_hidden", false)):
		return false
	return in_build(id)






static func in_build(id: String) -> bool:
	if not STAGES.has(id):
		return false
	var s: = info(id)
	if LaunchGate.is_demo() and not bool(s.get("demo", false)):
		return false
	return ResourceLoader.exists(String(s.get("venue", "")))



static func resolve(id: String) -> String:
	return id if in_build(id) else home()




const DEMO_HOME: = "grass"
static func home() -> String:
	var mobile: bool = MobileRender.enabled()
	var preferred: String = "mobile" if mobile else DEMO_HOME if LaunchGate.is_demo() else "nationals"
	if ResourceLoader.exists(String(STAGES[preferred].get("venue", ""))):
		return preferred
	# Recovered projects can omit a venue. Never choose a missing default scene.
	for fallback in ["grass", "school", "void"]:
		if STAGES.has(fallback) and ResourceLoader.exists(String(STAGES[fallback].get("venue", ""))):
			return fallback
	return preferred




static func saved_pick(id: String) -> String:
	return id if id in ids() else home()

static func info(id: String) -> Dictionary:
	var d: Dictionary = STAGES.get(id, STAGES[home()])
	if d.has("base") and STAGES.has(d["base"]):

		var merged: Dictionary = STAGES[d["base"]].duplicate()
		merged.merge(d, true)
		return merged
	return d

static func title(id: String) -> String:
	return String(info(id).get("title", id))











const REVERB_BUSES: = {"sfx": 1.0, "voice": 0.9, "voice_line": 0.9, "crowd": 0.55}

static func apply_reverb(id: String) -> void :
	var rv: Dictionary = val(id, "reverb", {})
	for bus_name in REVERB_BUSES:
		var bi: = AudioServer.get_bus_index(bus_name)
		if bi == -1:
			continue
		var fx: AudioEffectReverb = null
		var at: = -1
		for i in AudioServer.get_bus_effect_count(bi):
			var e: = AudioServer.get_bus_effect(bi, i)
			if e is AudioEffectReverb:
				fx = e
				at = i
				break
		if rv.is_empty():
			if fx != null:
				AudioServer.set_bus_effect_enabled(bi, at, false)
			continue
		if fx == null:
			fx = AudioEffectReverb.new()
			AudioServer.add_bus_effect(bi, fx)
			at = AudioServer.get_bus_effect_count(bi) - 1
		var scale: float = REVERB_BUSES[bus_name]
		fx.room_size = float(rv.get("room", 0.8))
		fx.damping = float(rv.get("damp", 0.5))
		fx.wet = float(rv.get("wet", 0.2)) * scale
		fx.dry = 1.0
		fx.predelay_msec = float(rv.get("predelay", 25.0))
		fx.predelay_feedback = 0.3
		fx.hipass = float(rv.get("hipass", 0.15))
		fx.spread = 1.0
		AudioServer.set_bus_effect_enabled(bi, at, true)

static func has_crowd(id: String) -> bool:
	return bool(val(id, "crowd", true))






static func config(id: String, fresh: = false) -> Resource:
	var path: = String(info(id).get("look", ""))
	if path == "" or not ResourceLoader.exists(path):
		return null
	if fresh:
		return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	return load(path)







static func val(id: String, key: String, default: Variant) -> Variant:

	var tod: = tod_index(id)
	if tod > 0:
		var looks: Dictionary = info(id).get("tod_looks", {})
		var over: Dictionary = looks.get(tod, {})
		if over.has(key):
			var ov: Variant = over[key]
			if (key == "sky_shader" or key == "sky_material") and ov is String:
				return load(ov) if ResourceLoader.exists(ov) else default
			return ov


	var forced: Dictionary = info(id).get("force", {})
	if forced.has(key):
		return forced[key]
	var c: = config(id)
	if c != null:
		var v: Variant = c.get(key)
		if v != null:
			return v
	var out: Variant = info(id).get(key, default)

	if key == "sky_shader" and out is String:
		return load(out) if ResourceLoader.exists(out) else default
	return out


static func tod_labels(id: String) -> Array:
	if _day_only(id):
		return []
	return info(id).get("tod", [])


static func _day_only(id: String) -> bool:
	return LaunchGate.is_demo() and bool(info(id).get("demo_day_only", false))



static func tod_index(id: String) -> int:
	if GameConfig.quick_match or not GameConfig.tod_live:
		return 0
	if _day_only(id):
		return 0
	var n: = (info(id).get("tod", []) as Array).size()
	if n <= 1:
		return 0
	return clampi(GameConfig.time_of_day, 0, n - 1)




static func cam_box(id: String) -> AABB:
	var b: Variant = val(id, "cam_box", null)
	return b if b is AABB else AABB()


static func in_cam_box(pos: Vector3, box: AABB) -> Vector3:
	if box.size == Vector3.ZERO:
		return pos
	return pos.clamp(box.position, box.end)




static func apply_sun_windows(id: String) -> void :
	var w: Dictionary = val(id, "sun_windows", {})
	var d: Vector3 = w.get("dir", Vector3.UP)
	var c: Color = w.get("color", Color.WHITE)
	RenderingServer.global_shader_parameter_set("jv_sun", 
		Vector4(d.x, d.y, d.z, float(w.get("amount", 0.0))))
	RenderingServer.global_shader_parameter_set("jv_sun_win", Vector4(float(w.get("roof_y", 0.0)), 
		float(w.get("roof_fall", 0.0)), float(w.get("glass_from", 0.0)), float(w.get("glass_to", 0.0))))
	RenderingServer.global_shader_parameter_set("jv_sun_grid", Vector4(float(w.get("step", 1.0)), 
		float(w.get("width", 0.0)), float(w.get("soft", 0.1)), float(w.get("half_run", 0.0))))
	RenderingServer.global_shader_parameter_set("jv_sun_col", Vector3(c.r, c.g, c.b))

	var g: Dictionary = val(id, "floor_gloss", {})
	RenderingServer.global_shader_parameter_set("jv_rig_a", Vector4(float(g.get("streak", 1.0)), 
		float(g.get("side_x", 0.0)), float(g.get("side_run", 0.0)), float(g.get("amount", 0.0))))
	RenderingServer.global_shader_parameter_set("jv_rig_b", Vector4(float(g.get("end_z", 0.0)), 
		float(g.get("end_run", 0.0)), float(g.get("side_step", 1.0)), float(g.get("end_step", 1.0))))

	var bl: Dictionary = val(id, "body_light", {})
	RenderingServer.global_shader_parameter_set("jv_body_light", Vector4(float(bl.get("overhead", 0.0)), 
		float(bl.get("rim", 0.0)), float(bl.get("pool_dim", 0.0)), float(bl.get("rim_width", 0.0))))
	var pool: Vector2 = bl.get("pool", Vector2(100.0, 100.0))
	RenderingServer.global_shader_parameter_set("jv_body_pool", Vector4(pool.x, pool.y, 
		float(bl.get("pool_fall", 1.0)), 0.0))

static func apply_time_of_day(id: String) -> void :
	var t: Variant = val(id, "world_tint", Vector3.ONE)
	RenderingServer.global_shader_parameter_set("jv_world_tint", 
		t if t is Vector3 else Vector3.ONE)


	var b: Variant = val(id, "body_tint", Vector3.ONE)
	GameConfig.body_tint = b if b is Vector3 else Vector3.ONE
	RenderingServer.global_shader_parameter_set("jv_body_tint", GameConfig.body_tint)

	RenderingServer.global_shader_parameter_set("jv_night_rim", float(val(id, "body_rim", 0.0)))
	apply_sun_windows(id)
	var tree: = Engine.get_main_loop() as SceneTree
	if tree != null:
		for n in tree.get_nodes_in_group(GameConfig.STAGE_WORLD):
			GameConfig.world_light(n)






const THUMB_DIR: = "res://game/stages/thumbs"

static func thumb_path(id: String) -> String:
	return String(val(id, "thumb", "%s/%s.png" % [THUMB_DIR, id]))

static func thumb(id: String) -> Texture2D:
	var path: = thumb_path(id)
	if path == "" or not ResourceLoader.exists(path):
		return null
	var res: = load(path)
	return res if res is Texture2D else null



static func kind(id: String) -> String:
	var k: = String(val(id, "kind", ""))
	if k != "":
		return k
	if bool(val(id, "anime_sky", false)) or val(id, "sun", null) != null:
		return "outdoor"
	return "indoor"

static func random_id() -> String:



	var pool: = ids(false)
	for id in STAGES:
		if id in pool or not bool(STAGES[id].get("quick", false)):
			continue
		if _listed(id):
			pool.append(id)
	return pool[randi() % pool.size()]



static func ball_model(id: String) -> String:
	return String(info(id).get("ball", ""))





static func ball_texture(id: String) -> String:
	return String(info(id).get("ball_tex", ""))







static func tint_court_lines(court: Node3D, color: Color) -> void :
	_tint(court, ["SideLineWest", "SideLineEast", "EndLineNorth", 
		"EndLineSouth", "CenterLine"], color)



















static func apply_recolors(painted: Dictionary, id: String, lift: = {}, 
		wall_base: = {}) -> void :
	var recolors: Dictionary = val(id, "recolors", {})
	for mname in recolors:
		var col: Color = recolors[mname]
		if lift.has(mname):
			col = col.lightened(float(lift[mname]))
		for mat in painted.get(mname, []):
			var sm: = mat as ShaderMaterial
			wall_base.erase(sm)
			sm.set_shader_parameter("albedo", col)


			sm.set_shader_parameter("use_tex", false)

static func apply_school_accent(painted: Dictionary, court: Node3D, id: String, 
		accent: Color, tape: Variant = null, wall_base: = {}) -> void :
	for mname in val(id, "accent_mats", []):
		for mat in painted.get(mname, []):
			(mat as ShaderMaterial).set_shader_parameter("albedo", accent)
	if tape != null:
		tint_court_lines(court, tape)



	if court != null and bool(val(id, "accent_pads", false)):
		_tint_gradient(court, ["PostWestPad", "PostEastPad"], accent)
	var wash: float = val(id, "wall_wash", 0.11)
	for mname in val(id, "wall_mats", []):
		for mat in painted.get(mname, []):
			var sm: = mat as ShaderMaterial
			if not wall_base.has(sm):
				wall_base[sm] = sm.get_shader_parameter("albedo")
			sm.set_shader_parameter("albedo", 
				(wall_base[sm] as Color).lerp(accent, wash))












static func paint_court_floor(mat: ShaderMaterial, id: String, half_w: float, half_l: float) -> void :
	if mat == null:
		return
	mat.set_shader_parameter("base_color", val(id, "floor_color", Color(0.85, 0.5, 0.25)))
	mat.set_shader_parameter("pool_strength", float(val(id, "pool_strength", 0.0)))
	mat.set_shader_parameter("floor_vignette", float(val(id, "floor_vignette", 0.0)))
	mat.set_shader_parameter("pool_warm", Color(1.0, 0.9, 0.72))
	mat.set_shader_parameter("pool_radius", maxf(half_w, half_l) * 1.25)
	mat.set_shader_parameter("checker_size", float(val(id, "checker_size", 0.0)))
	mat.set_shader_parameter("checker_color", val(id, "checker_color", Color(0.66, 0.67, 0.69)))

static func dress_court(court: Node3D, id: String) -> void :
	var s: = info(id)


	for n in court.find_children("*Ink", "MeshInstance3D", true, false):


		var nm: = String(n.name)
		var parent_nm: = String(n.get_parent().name) if n.get_parent() != null else ""
		(n as MeshInstance3D).visible = nm == "NetBandInk" or nm == "NetBandBottomInk" or (nm == "Ink" and parent_nm.begins_with("Antenna"))




	var old_marks: = court.get_node_or_null("CourtMarkings")
	if old_marks != null:
		court.remove_child(old_marks)
		old_marks.queue_free()
	if bool(s.get("court_marks", false)):
		_add_court_markings(court, val(id, "lines", s.lines))


	_tint_gradient(court, ["PostWest", "PostEast"], val(id, "pole", s.pole), 0.18)
	_tint_gradient(court, ["PostWestPad", "PostEastPad"], val(id, "pad", s.pad), 0.04)




	_tint(court, ["SideLineWest", "SideLineEast", "EndLineNorth", 
		"EndLineSouth", "CenterLine"], val(id, "lines", s.lines))
	var tape_col: Color = val(id, "tape", s.tape)
	_tint(court, ["NetBand", "NetBandBottom"], tape_col)

	_tint(court, ["CordTopWest", "CordBottomWest", "CordTopEast", "CordBottomEast"], 
		val(id, "cord", s.cord))
	var net: = court.get_node_or_null("Net") as MeshInstance3D
	if net != null:



		net.mesh = net.mesh.duplicate(true)
		var mat: = (net.mesh as PlaneMesh).material as ShaderMaterial
		mat.set_shader_parameter("tape_color", tape_col)
		mat.set_shader_parameter("cord_color", val(id, "cord", s.cord))


	GameConfig.world_light.call_deferred(court, true)

static func _add_court_markings(court: Node3D, color: Color) -> void :



	var mat: = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.75


	const mark_y: = 0.006
	const mark_thickness: = 0.012
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)


	for z: float in [-3.0, 3.0]:
		_mark_box(st, Vector3(0.0, mark_y, z), 
			Vector3(9.0, mark_thickness, 0.055))


		for side_x: float in [-1.0, 1.0]:
			for dash in 4:
				var x: float = side_x * (4.72 + float(dash) * 0.38)
				_mark_box(st, Vector3(x, mark_y, z), 
					Vector3(0.22, mark_thickness, 0.055))

	for end_z: float in [-1.0, 1.0]:
		for side_x: float in [-1.0, 1.0]:
			for dash in 4:
				var z: float = end_z * (9.22 + float(dash) * 0.38)
				_mark_box(st, Vector3(side_x * 4.5, mark_y, z), 
					Vector3(0.055, mark_thickness, 0.22))
	var mesh: = st.commit()
	mesh.surface_set_material(0, mat)
	var marks: = MeshInstance3D.new()
	marks.name = "CourtMarkings"
	marks.mesh = mesh
	marks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	court.add_child(marks)

static func _mark_box(st: SurfaceTool, at: Vector3, size: Vector3) -> void :
	var box: = BoxMesh.new()
	box.size = size
	st.append_from(box, 0, Transform3D(Basis.IDENTITY, at))

const NET_GRADIENT: = preload("res://game/court/net_gradient.gdshader")






static func _tint_gradient(court: Node3D, names: Array, color: Color, shine: = 0.6) -> void :
	for n in names:
		var mi: = court.get_node_or_null(n) as MeshInstance3D
		if mi == null:
			continue
		var m: = ShaderMaterial.new()
		m.shader = NET_GRADIENT
		m.set_shader_parameter("base_color", color)
		m.set_shader_parameter("shine", shine)
		m.set_shader_parameter("rim_dark", 0.35 if shine > 0.3 else 0.22)
		mi.material_override = m

static func _tint(court: Node3D, names: Array, color: Color) -> void :



	var dups: = {}
	for n in names:
		var mi: = court.get_node_or_null(n) as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		if not dups.has(mi.mesh):
			var d: Mesh = mi.mesh.duplicate(true)
			var m: Material = (d as PrimitiveMesh).material\
			if d is PrimitiveMesh else d.surface_get_material(0)
			if m is StandardMaterial3D:
				(m as StandardMaterial3D).albedo_color = color


				m.remove_meta("jv_albedo")
			dups[mi.mesh] = d
		mi.mesh = dups[mi.mesh]
