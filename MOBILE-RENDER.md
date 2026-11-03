# Mobile renderer audit — 0.2.0

The `mobile` branch in `E:\VOLLBALL\mobile` is the phone project. The independent
`windows-desktop` branch in `E:\VOLLBALL\pc` produces the existing Windows
release. Do not copy project.godot or export_presets.cfg between them.

The phone project has a separate title, settings directory, export profiles, boot,
menu, match, court, player and ball scenes. Match rules, physics and AI remain
shared scripts. Its menu starts an offline 1 vs 1 match; it has no LAN room UI.

iPhone uses Godot Mobile through native Metal. Android uses Compatibility/GLES3.
The desktop preview defaults to Compatibility; `--rendering-method mobile
--rendering-driver vulkan` exercises the Mobile renderer on a Windows GPU.
The iOS simulator uses an explicit GLES override because Godot's simulator
template does not support the device Metal renderer.

Problems found and changes:

- Random bot accessories scanned the entire catalog, eagerly loading 40 model
  resources. Mobile bots now omit extra accessories; saved player accessories
  load individually by ID. Desktop customization keeps its complete catalog.
- Accessory code bypassed `_ink()` and allocated outline/highlight meshes even
  when the phone disabled contours. The allocation entry points now reject mobile.
- FX instantiated 270 meshes/materials at every match load. Mobile pools now total
  34. Sweat/swirl pools and procedural spike shards are omitted; empty-pool callers
  are guarded. Player feedback, the ball, score, and touch controls remain.
- The initial desktop court/player/ball materials were still referenced by the
  match scene. Phone scenes use mobile shaders from the start, simpler primitive
  meshes, an unlit court/net, linear tonemapping, and no active arena lights.
- High-density phone screens used a native-sized root target. Mobile now bounds
  the viewport to a 720-high logical target, retaining screen aspect ratio, and
  separately applies 50–75% 3D scaling. Both MSAA modes, HDR 2D and positional
  shadow atlases are disabled. Desktop graphics settings cannot turn these back on
  through `apply_msaa()`.
- Cloth deformation, screen-sized burnout prewarming, GPU trails, reflection
  viewports, contour passes and hair springs are disabled on phones.
- The quality buttons now apply the FPS limit immediately and preserve 30/60 FPS.
- Desktop recovery could relaunch a mobile preview in OpenGL and drop its arguments.
  The mobile project bypasses desktop boot recovery and clears the startup marker.
- Menu/camera touch buttons no longer cover the serve prompt.

Diagnostics record renderer, driver, GPU name, frame rate and memory counters.
Release builds may report zero for counters unsupported by the engine/platform.
These counters are not a measurement of total iOS process memory.

Validation: ball controls, touch controls, menu quality settings, rendered offline
match, return to menu and a second match; both Compatibility and Mobile rendering
paths are checked on the Windows GPU. CI checks profile isolation and builds the
actual IPA/APK. Simulator checks use GLES and cannot establish physical iPhone
Metal stability. The earlier 0.1.4 simulator log reached the match without a crash
but timed out with Apple's software renderer; it is not proof of an iPhone GPU bug.

Physical iPhone 11 testing is still required. If it exits, relaunch and copy the
startup journal from the phone menu; the last phase distinguishes loading,
scene construction and rendering. An iOS crash report can identify a native driver
fault or an operating-system memory termination that GDScript cannot catch.

Additional validation result (0.2.0 build 6, before catalog lazy loading): the
unchanged device pack reached `match_smoke_passed` in native iOS Simulator,
returned to the menu and constructed the second match. The complete repeated-match
test timed out at 609 seconds with Apple Software Renderer around 1 FPS. No native
crash report was produced. This does not validate the physical iPhone Metal path.
Build 7 includes the catalog change and passes the Windows GPU and CI checks.
Its macOS headless match test also reports 21 ObjectDB objects / 3 resources still
held during process shutdown; no script or shader error occurs during gameplay.
Android 0.2.0 uses the mobile branch's test signing key, different from Android
0.1.4, so installing it over that older APK is unsupported. Preserve local data
before removing any existing installation.

## 0.2.1 — desktop appearance on phones

The phone menu now instantiates the same `game/ui/menu.gd` UI as Windows, with
its player preview and familiar play/locker/shop/profile controls. Phone FPS/log
shortcuts sit in the footer. Mobile renderer, resolution limits and FX budgets
remain active. Solo practice uses the menu's existing freeplay court, avoiding
an additional embedded 12-player desktop practice viewport on a phone.

Mobile Grass uses the original PC landscape, tree cards, hills, textures and
court colors. The grass-clump generator and secondary sky environment are omitted;
the sky uses the original blue color. Body cel shading and volleyball panel
shading share the desktop shader logic with stencil writes removed. No reflection,
secondary hair simulation or desktop contour passes are re-enabled.

G and the phone's ball button now release the ball 5.2m above the player instead
of 2.6m, both in menu freeplay and match practice. The same change is applied to
the independent Windows branch and covered by the ball regression test.

## 0.2.2 — iPhone launcher crash recovery

The user reported an exit at loading the menu in 0.2.1. That build loaded the
entire desktop menu script, all hidden desktop pages and a live 3D world before
showing the menu. No physical-device crash report is available to establish the
exact native cause.

The iPhone launcher now uses `phone_menu.gd`, a small Control-only scene with a
baked PNG of the same court/avatar and PC-style 2D cards. It does not load the
desktop Menu, HUD, locker scene or player scene, and disables root 3D rendering
until leaving the menu. The match stays 3D and keeps its grass court and 5.2m G
spawn. Local matches and practice load only after tapping their buttons. Locker,
shop and online tabs are temporarily disabled; profile naming, settings, journal,
local play and practice work through lightweight pages. Practice uses two bodies
without allocating the desktop interactive court-size pads.

Android push builds are disabled. This iteration builds only the iPhone IPA.
Native simulator verification can now run the 2D menu/settings path separately
from the software-rendered 3D match, including two launches and saved profile
persistence. Physical iPhone validation still follows installation of the IPA.
