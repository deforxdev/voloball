"""Publish the verified iPhone build as a directly downloadable release asset."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import urllib.error
import urllib.parse
import urllib.request
from zipfile import ZipFile

LANDSCAPE_ORIENTATIONS = {
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
}
RELEASE_BODY = """iPhone 0.2.7

Екран автоматично перевертається в обидва горизонтальні положення. Розкладка сенсорних кнопок підлаштовується під безпечну область екрана.

Чітка графіка та редактор керування з 0.2.6 включені. Налаштування керування → «Змінити керування» дозволяють перетягувати кнопки, джойстик та індикатор сили, змінювати розмір і прозорість та зберігати розкладку на пристрої.

Натисни на VOLOBALL-iPhone-0.2.7-SideStore.ipa і встанови через SideStore поверх наявної гри. Assets містить готовий IPA.

Автоматичні перевірки меню, матчу, сенсорного керування та редактора пройшли. Обидві орієнтації перевірені в Info.plist зібраного застосунку. На фізичному iPhone цю версію ще не перевірено.
"""


def inspect_package(path):
    with ZipFile(path) as package:
        assert package.testzip() is None, "IPA CRC check failed"
        info_path = next(name for name in package.namelist() if name.endswith(".app/Info.plist"))
        info = plistlib.loads(package.read(info_path))
        assert info["CFBundleIdentifier"] == "com.deforxdev.voloball"
        version = info["CFBundleShortVersionString"]
        assert re.fullmatch(r"\d+\.\d+\.\d+", version), "Unexpected app version"
        assert set(info["UISupportedInterfaceOrientations"]) == LANDSCAPE_ORIENTATIONS, info.get("UISupportedInterfaceOrientations")
        assert any(name.endswith(".pck") for name in package.namelist()), "Missing game pack"
    return version


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("ipa", type=Path)
    parser.add_argument("--validate-only", action="store_true")
    arguments = parser.parse_args()
    version = inspect_package(arguments.ipa)
    digest = "sha256:" + hashlib.sha256(arguments.ipa.read_bytes()).hexdigest()
    print("Validated iPhone IPA and both landscape orientations", version, flush=True)
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

    tag = "v" + version + "-ios"
    filename = "VOLOBALL-iPhone-" + version + "-SideStore.ipa"
    body = RELEASE_BODY.replace("0.2.7", version)
    description = {
        "tag_name": tag,
        "target_commitish": source,
        "name": "VOLOBALL iPhone " + version,
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
        asset = api(upload_url, "POST", data=arguments.ipa.read_bytes())
    assert asset["state"] == "uploaded"
    assert asset["size"] == arguments.ipa.stat().st_size
    assert asset["digest"] == digest, "Uploaded IPA checksum mismatch"

    release = api(base + "/releases/" + str(release["id"]), "PATCH", payload=dict(description, draft=False))
    ref = api(base + "/git/ref/tags/" + tag)
    assert ref["object"]["sha"] == source, "Published tag does not match the build"
    report = {
        "release": release["html_url"],
        "ipa": asset["browser_download_url"],
        "sha256": digest,
        "source": source,
        "version": version,
    }
    Path("build/ios-release.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as summary:
            summary.write("[Завантажити IPA](" + report["ipa"] + ")\n")
    print(json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
