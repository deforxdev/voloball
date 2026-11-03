# VOLOBALL — Windows desktop

Windows x64 build with the original desktop menu and keyboard/mouse controls.
Mobile-only UI and rendering remain restricted to mobile platforms.
No new LAN menu or server setup.

CI: `.github/workflows/windows.yml`, branch `windows-desktop`.
Exports an embedded-PCK executable with the Windows preset.
`tools/prepare_mobile_assets.py` restores recovered portable assets before import.

Optional exported-build verification: set `VOLOBALL_DESKTOP_SMOKE=1`; the game captures the desktop menu, starts a local match and returns to the desktop menu.
