"""Restore missing Blender source paths from the recovered GLBs before import.

Run on a CI checkout, never on the preserved Windows branch. Existing source
assets are left alone; scene UIDs are preserved so serialized references resolve.
"""
from pathlib import Path
import re
import shutil
import sys

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
recovered = {p.relative_to(root / ".assets").as_posix().casefold(): p
             for p in (root / ".assets").rglob("*.glb")}
restored = 0
for metadata in list(root.rglob("*.blend.import")):
    if ".godot" in metadata.parts:
        continue
    source = metadata.read_text(encoding="utf-8")
    match = re.search(r'^source_file="res://(.+)"', source, re.M)
    if not match:
        raise RuntimeError(f"Missing source path: {metadata}")
    old = match[1]
    new = str(Path(old).with_suffix(".glb")).replace("\\", "/")
    asset = recovered.get(new.casefold())
    if asset is None:
        raise FileNotFoundError(f"No recovered GLB for {old}")
    target = root / new
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(asset, target)
    # The engine reimports from GLB using the original scene UID and settings.
    source = source.replace(f'res://{old}', f'res://{new}')
    target.with_suffix(".glb.import").write_text(source, encoding="utf-8")
    metadata.unlink()
    restored += 1

for folder in (root / "game", root / "addons"):
    for path in folder.rglob("*"):
        if path.suffix not in (".gd", ".tscn", ".tres", ".cfg"):
            continue
        source = path.read_text(encoding="utf-8")
        updated = re.sub(r"\.blend(?![a-zA-Z_])", ".glb", source)
        if updated != source:
            path.write_text(updated, encoding="utf-8")

# These two unused images have only obsolete metadata in the recovered build.
for name in ("ball_orig.png", "ball_sprite.png"):
    path = root / (name + ".import")
    if path.exists() and not (root / name).exists():
        path.unlink()
print(f"Restored {restored} portable GLB sources; Blender is not required.")
