# VOLOBALL Mobile

Phone-only development branch: `mobile`. Windows stays on `windows-desktop`.
Open this project for iPhone/Android work; do not replace Windows project settings
with this branch's files.

- iPhone: Mobile renderer + Metal, unsigned IPA for SideStore.
- Android ARM64: Compatibility + GLES3, APK.
- Separate phone boot/menu/match/court/player/ball scenes and settings directory.
- Offline 1 vs 1 against a bot, touch controls. No LAN room menu.

See [MOBILE-RENDER.md](MOBILE-RENDER.md) for the renderer audit and validation limits.

CI restores recovered GLB sources with `tools/prepare_mobile_assets.py`, verifies
profile isolation with `tools/check_mobile_profile.py`, then runs the ball, touch,
menu and repeated-match checks before export.
