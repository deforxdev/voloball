"""Publish the verified Android build as a directly downloadable release asset."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import urllib.error
import urllib.parse
import urllib.request
from zipfile import ZipFile

RELEASE_BODY = """Android {version} (ARM64)

Меню Online має ті самі пункти, що на ПК. Створи кімнату через Online → Custom Lobby → Create Server. Друзі вводять восьмисимвольний код в Online → Server Browser → Join. До 10 гравців у кімнаті. Сумісний із iPhone {version}.

Власник кімнати обчислює матч і має залишатись у грі. Photon передає дані через інтернет. Збережено редактор сенсорного керування, чітку графіку та обидва горизонтальні положення екрана. Android використовує GLES Compatibility.

Завантаж VOLOBALL-Android-{version}-ARM64.apk безпосередньо з Assets. APK підписаний тестовим ключем.

Перевірки меню, матчу, сенсорного керування, редактора та реального Photon Cloud пройшли. Підпис і структура APK перевірені. На фізичному Android цю версію ще не перевірено.
"""


def inspect_package(path):
    with ZipFile(path) as package:
        assert package.testzip() is None, "APK CRC check failed"
        names = package.namelist()
        assert "AndroidManifest.xml" in names and "classes.dex" in names
        assert any(name.startswith("lib/arm64-v8a/") and name.endswith(".so") for name in names), "Missing ARM64 library"
        assert "assets/project.binary" in names, "Missing Godot game data"
        assert any("photon_cloud" in name for name in names), "Missing Photon transport"
    presets = Path("export_presets.cfg").read_text()
    match = re.search(r'version/name="([0-9]+\.[0-9]+\.[0-9]+)"', presets)
    assert match, "Missing Android version"
    return match[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("apk", type=Path)
    parser.add_argument("--validate-only", action="store_true")
    arguments = parser.parse_args()
    version = inspect_package(arguments.apk)
    digest = "sha256:" + hashlib.sha256(arguments.apk.read_bytes()).hexdigest()
    print("Validated signed Android ARM64 APK structure", version, flush=True)
    if arguments.validate_only:
        return

    repository = os.environ["GITHUB_REPOSITORY"]
    source = os.environ["GITHUB_SHA"]
    assert repository == "deforxdev/voloball"
    assert re.fullmatch(r"[0-9a-f]{40}", source)
    base = "https://api.github.com/repos/" + repository
    headers = {
        "Authorization": "Bearer " + os.environ["GITHUB_TOKEN"],
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    def api(url, method="GET", payload=None, data=None):
        request_headers = dict(headers)
        if payload is not None:
            data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            request_headers["Content-Type"] = "application/json"
        elif data is not None:
            request_headers["Content-Type"] = "application/octet-stream"
        request = urllib.request.Request(url, headers=request_headers, method=method, data=data)
        with urllib.request.urlopen(request, timeout=240) as response:
            return json.load(response) if response.status != 204 else None

    tag = "v" + version + "-android"
    filename = "VOLOBALL-Android-" + version + "-ARM64.apk"
    body = RELEASE_BODY.format(version=version)
    description = {
        "tag_name": tag,
        "target_commitish": source,
        "name": "VOLOBALL Android " + version,
        "body": body,
        "prerelease": True,
    }
    # Listing also finds draft releases, which may not yet have a public tag.
    releases = api(base + "/releases?per_page=100")
    release = next((entry for entry in releases if entry["tag_name"] == tag), None)
    if release is None:
        release = api(base + "/releases", "POST", payload=dict(description, draft=True))
    else:
        assert release["target_commitish"] == source, "Release belongs to another commit"

    asset = next((entry for entry in release["assets"] if entry["name"] == filename), None)
    if asset is not None and asset["state"] == "starter":
        assert release["draft"], "Cannot replace an incomplete asset on a published release"
        api(base + "/releases/assets/" + str(asset["id"]), "DELETE")
        asset = None
    if asset is None:
        upload_url = release["upload_url"].split("{", 1)[0]
        assert urllib.parse.urlparse(upload_url).hostname == "uploads.github.com"
        upload_url += "?" + urllib.parse.urlencode({"name": filename})
        print("Uploading", filename, flush=True)
        asset = api(upload_url, "POST", data=arguments.apk.read_bytes())
    assert asset["state"] == "uploaded"
    assert asset["size"] == arguments.apk.stat().st_size
    assert asset["digest"] == digest, "Uploaded IPA checksum mismatch"

    release = api(base + "/releases/" + str(release["id"]), "PATCH", payload=dict(description, draft=False))
    ref = api(base + "/git/ref/tags/" + tag)
    assert ref["object"]["sha"] == source, "Published tag does not match the build"
    release = api(base + "/releases/" + str(release["id"]))
    assert not release["draft"]
    asset = next(entry for entry in release["assets"] if entry["name"] == filename)
    assert asset["digest"] == digest
    report = {
        "release": release["html_url"],
        "apk": asset["browser_download_url"],
        "sha256": digest,
        "source": source,
        "version": version,
    }
    Path("build/android-release.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as summary:
            summary.write("[Завантажити APK](" + report["apk"] + ")\n")
    print(json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
