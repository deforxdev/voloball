class_name MobileDiagnostics
extends RefCounted

const PATH := "user://mobile-diagnostics.log"
const BUILD := "0.1.4"

static func record(phase: String) -> void:
	if not (OS.has_feature("mobile") or OS.get_cmdline_user_args().has("--mobile-preview") or bool(ProjectSettings.get_setting("application/config/lan_desktop", false))):
		return
	var row := {"build": BUILD, "phase": phase, "time": Time.get_datetime_string_from_system(true),
		"renderer": RenderingServer.get_current_rendering_method(),
		"memory_static_mb": snappedf(OS.get_static_memory_usage() / 1048576.0, 0.1)}
	var log := FileAccess.open(PATH, FileAccess.READ_WRITE if FileAccess.file_exists(PATH) else FileAccess.WRITE)
	if log != null:
		log.seek_end()
		log.store_line(JSON.stringify(row))
		log.close()
	print("[mobile diagnostics] " + JSON.stringify(row))

static func read_log() -> String:
	return FileAccess.get_file_as_string(PATH) if FileAccess.file_exists(PATH) else "Журнал ще порожній."
