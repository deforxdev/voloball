class_name MobileDiagnostics
extends RefCounted

const PATH := "user://mobile-diagnostics.log"
const BUILD := "0.2.0"

static func record(phase: String) -> void:
	if not MobileRender.enabled():
		return
	var row := {"build": BUILD, "phase": phase, "time": Time.get_datetime_string_from_system(true),
		"renderer": RenderingServer.get_current_rendering_method(),
		"driver": RenderingServer.get_current_rendering_driver_name(),
		"device": RenderingServer.get_video_adapter_name(),
		"fps": Engine.get_frames_per_second(),
		"video_memory_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
		"memory_static_mb": snappedf(OS.get_static_memory_usage() / 1048576.0, 0.1)}
	var log := FileAccess.open(PATH, FileAccess.READ_WRITE if FileAccess.file_exists(PATH) else FileAccess.WRITE)
	if log != null:
		log.seek_end()
		log.store_line(JSON.stringify(row))
		log.close()
	print("[mobile diagnostics] " + JSON.stringify(row))

static func read_log() -> String:
	return FileAccess.get_file_as_string(PATH) if FileAccess.file_exists(PATH) else "Журнал ще порожній."
