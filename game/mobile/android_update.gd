extends Node

signal finished
signal progress_changed(message: String, percent: float)

const RELEASES := "https://api.github.com/repos/deforxdev/voloball/releases?per_page=50"
const DOWNLOADS := "https://github.com/deforxdev/voloball/releases/download/"
const MAX_APK_BYTES := 512 * 1024 * 1024
const APK_PATH := "user://voloball-update.apk"
static var _checked := false
var _request: HTTPRequest
var _update: Dictionary = {}

static func should_check() -> bool:
	return OS.has_feature("android") and not _checked and Engine.has_singleton("AndroidRuntime")

func start() -> void:
	_checked = true
	DirAccess.remove_absolute(APK_PATH)
	set_process(false)
	_request = HTTPRequest.new()
	_request.timeout = 5.0
	_request.body_size_limit = 2 * 1024 * 1024
	add_child(_request)
	_request.request_completed.connect(_on_checked, CONNECT_ONE_SHOT)
	progress_changed.emit("Перевірка оновлень…" if GameConfig.language == "uk" else "Checking for updates…", 0.0)
	if _request.request(RELEASES, ["Accept: application/vnd.github+json"]) != OK:
		_finish()

func skip() -> void:
	_request.cancel_request()
	_finish()

func _on_checked(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and status == 200:
		var releases: Variant = JSON.parse_string(body.get_string_from_utf8())
		if releases is Array:
			_update = newest_release(releases, MobileDiagnostics.BUILD)
	if _update.is_empty():
		_finish()
		return
	_request.timeout = 180.0
	_request.body_size_limit = int(_update.size)
	_request.download_file = APK_PATH
	_request.request_completed.connect(_on_downloaded, CONNECT_ONE_SHOT)
	if _request.request(download_url(_update.version)) != OK:
		_finish()
		return
	set_process(true)
	_process(0.0)

func _process(_delta: float) -> void:
	var label := "Оновлення VOLOBALL %s…" if GameConfig.language == "uk" else "Updating VOLOBALL %s…"
	progress_changed.emit(label % _update.version,
		clampf(100.0 * _request.get_downloaded_bytes() / int(_update.size), 0.0, 100.0))

func _on_downloaded(result: int, status: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or status != 200 or FileAccess.get_sha256(APK_PATH) != _update.sha256:
		_finish()
		return
	_finish(_open_installer())

func _open_installer() -> bool:
	var runtime = Engine.get_singleton("AndroidRuntime")
	var activity = runtime.getActivity()
	if activity == null:
		return false
	var files = JavaClassWrapper.wrap("java.io.File")
	var provider = JavaClassWrapper.wrap("androidx.core.content.FileProvider")
	var intents = JavaClassWrapper.wrap("android.content.Intent")
	var apk = files.File(ProjectSettings.globalize_path(APK_PATH))
	var uri = provider.getUriForFile(activity, activity.getPackageName() + ".fileprovider", apk)
	if uri == null or JavaClassWrapper.get_exception() != null:
		return false
	var intent = intents.Intent("android.intent.action.VIEW")
	intent.setDataAndType(uri, "application/vnd.android.package-archive")
	intent.addFlags(intents.FLAG_GRANT_READ_URI_PERMISSION)
	activity.startActivity(intent)
	return JavaClassWrapper.get_exception() == null

func _finish(keep_package := false) -> void:
	set_process(false)
	if not keep_package:
		DirAccess.remove_absolute(APK_PATH)
	finished.emit()
	queue_free()

static func download_url(version: String) -> String:
	return DOWNLOADS + "v%s-android/VOLOBALL-Android-%s-ARM64.apk" % [version, version]

static func newest_release(releases: Array, installed: String) -> Dictionary:
	var pattern := RegEx.create_from_string("^v([0-9]{1,6})[.]([0-9]{1,6})[.]([0-9]{1,6})-android$")
	var sha256_pattern := RegEx.create_from_string("^sha256:[0-9a-f]{64}$")
	var installed_match := pattern.search("v%s-android" % installed)
	if installed_match == null:
		return {}
	var best := _number(installed_match)
	var update := {}
	for release in releases:
		if not release is Dictionary or release.get("draft", true) != false:
			continue
		var tag: Variant = release.get("tag_name")
		if not tag is String:
			continue
		var parsed := pattern.search(tag)
		if parsed == null or _number(parsed) <= best:
			continue
		var candidate: String = tag.trim_prefix("v").trim_suffix("-android")
		var assets: Variant = release.get("assets")
		if not assets is Array:
			continue
		for asset in assets:
			if asset is Dictionary and asset.get("state") == "uploaded"\
			and asset.get("name") == "VOLOBALL-Android-%s-ARM64.apk" % candidate\
			and asset.get("browser_download_url") == download_url(candidate):
				var digest: Variant = asset.get("digest", "")
				var size: Variant = asset.get("size", 0)
				if not digest is String or sha256_pattern.search(digest) == null:
					continue
				if not (size is int or size is float) or size <= 0 or size > MAX_APK_BYTES:
					continue
				best = _number(parsed)
				update = {"version": candidate, "sha256": digest.trim_prefix("sha256:"), "size": int(size)}
				break
	return update

static func _number(parsed: RegExMatch) -> int:
	return int(parsed.get_string(1)) * 1000000000000 + int(parsed.get_string(2)) * 1000000 + int(parsed.get_string(3))
