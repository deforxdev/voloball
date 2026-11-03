"""Fail export if desktop startup or renderer settings leak into mobile builds."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
project = (root / 'project.godot').read_text(encoding='utf-8')
assert 'config/mobile_build=true' in project
assert 'config/custom_user_dir_name="VOLOBALL-Mobile"' in project
assert 'run/main_scene="res://game/mobile/mobile_boot.tscn"' in project
assert 'renderer/rendering_method.ios="mobile"' in project
assert 'rendering_device/driver.ios="metal"' in project
assert 'renderer/rendering_method.android="gl_compatibility"' in project
presets = (root / 'export_presets.cfg').read_text(encoding='utf-8')
assert presets.count('custom_features="mobile,mobile_build"') == 2
assert 'Windows Desktop' not in presets
for item in (root / 'game/character/accessories').glob('*.tres'):
    text = item.read_text(encoding='utf-8')
    identity = re.search(r'^id = "([^"]+)"', text, re.MULTILINE)
    assert identity is not None and identity[1] == item.stem, item
for name in ('mobile_main', 'mobile_player', 'mobile_ball', 'mobile_court'):
    scene = (root / 'game/mobile' / (name + '.tscn')).read_text(encoding='utf-8')
    # Shared script UIDs are fine; duplicated scene UIDs can redirect to desktop resources.
    assert not re.search(r'^\[gd_scene[^\n]* uid=', scene)
    assert 'res://game/fx/toon.gdshader' not in scene
    assert 'res://game/court/net.gdshader' not in scene
    assert 'res://game/player/player.tscn' not in scene
print('MOBILE PROFILE CHECK PASSED: isolated startup/scenes/settings; iOS Metal, Android GLES')

menu = (root / "game/mobile/mobile_menu.tscn").read_text(encoding="utf-8")
assert "res://game/mobile/phone_menu.gd" in menu
assert "res://game/ui/menu.gd" not in menu
venue = (root / "game/mobile/mobile_grass.tscn").read_text(encoding="utf-8")
assert "GrassField" not in venue

for name in ("mobile_body", "mobile_ball", "mobile_ball_cel"):
    shader = (root / "game/mobile" / (name + ".gdshader")).read_text(encoding="utf-8")
    assert not re.search(r"^stencil_mode", shader, re.MULTILINE)

launcher = (root / "game/mobile/phone_menu.gd").read_text(encoding="utf-8")
for forbidden in ("res://game/ui/menu.gd", "res://game/ui/hud.tscn", "res://game/player/player.tscn", "res://game/character/locker.tscn"):
    assert forbidden not in launcher
