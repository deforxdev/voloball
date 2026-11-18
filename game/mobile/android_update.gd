extends RefCounted

const RELEASES := "https://api.github.com/repos/deforxdev/voloball/releases?per_page=50"
const DOWNLOADS := "https://github.com/deforxdev/voloball/releases/download/"
static var _checked := false
static var _available := ""

static func show_download_if_available(button: Button) -> void:
	if not OS.has_feature("android"):
		return
	if _checked:
		_show(button)
		return

	var request := HTTPRequest.new()
	request.timeout = 8.0
	request.body_size_limit = 2 * 1024 * 1024
	button.add_child(request)
	request.request_completed.connect(
		func(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray):
			request.queue_free()
			if result != HTTPRequest.RESULT_SUCCESS or status != 200:
				return
			var releases: Variant = JSON.parse_string(body.get_string_from_utf8())
			if releases is Array:
				_available = newest_version(releases, MobileDiagnostics.BUILD)
				_checked = true
				_show(button))
	if request.request(RELEASES, ["Accept: application/vnd.github+json"]) != OK:
		request.queue_free()

static func _show(button: Button) -> void:
	if _available.is_empty():
		return
	var version := _available
	button.text = ("Завантажити оновлення %s" if GameConfig.language == "uk" else "Download update %s") % version
	button.pressed.connect(func():
		if OS.shell_open(download_url(version)) != OK:
			UiStyle.flash_toast("VOLOBALL",
				"Не вдалося відкрити завантаження" if GameConfig.language == "uk" else "Could not open the download"))
	button.show()

static func download_url(version: String) -> String:
	return DOWNLOADS + "v%s-android/VOLOBALL-Android-%s-ARM64.apk" % [version, version]

static func newest_version(releases: Array, installed: String) -> String:
	var pattern := RegEx.create_from_string("^v([0-9]{1,6})[.]([0-9]{1,6})[.]([0-9]{1,6})-android$")
	var installed_match := pattern.search("v%s-android" % installed)
	if installed_match == null:
		return ""
	var best := _number(installed_match)
	var version := ""
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
				best = _number(parsed)
				version = candidate
				break
	return version

static func _number(parsed: RegExMatch) -> int:
	return int(parsed.get_string(1)) * 1000000000000 + int(parsed.get_string(2)) * 1000000 + int(parsed.get_string(3))
