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
