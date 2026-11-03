# VOLOBALL Mobile

Phone-only development branch: `mobile`. Windows stays on `windows-desktop`.
Open this project for iPhone/Android work; do not replace Windows project settings
with this branch's files.

- iPhone: Mobile renderer + Metal, unsigned IPA for SideStore.
- Android ARM64: Compatibility + GLES3, APK.
- Separate phone boot/match/court/player/ball scenes and settings directory.
- Shared desktop menu UI and original PC grass landscape with mobile-safe rendering.
- Local matches, freeplay and touch controls. G/ball button spawns at 5.2m. No new LAN.

See [MOBILE-RENDER.md](MOBILE-RENDER.md) for the renderer audit and validation limits.

CI restores recovered GLB sources with `tools/prepare_mobile_assets.py`, verifies
profile isolation with `tools/check_mobile_profile.py`, then runs the ball, touch,
menu and repeated-match checks before export.

0.2.3 iPhone: original desktop menu and live avatar restored, with full settings, profile, locker/save, shop, controller config and practice. Heavy pages load on first open, empty controller seats allocate no 3D rigs, all menu/preview bodies use mobile-safe resources. Accessory catalog lists use metadata; selected models load on demand with a bounded cache. Android push builds remain paused. Online services still require a supported backend/transport; restoring the page does not provide a new server.
