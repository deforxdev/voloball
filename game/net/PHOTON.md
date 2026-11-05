# VOLOBALL Photon Realtime test service

The iPhone online menu uses an invisible room identified by an 8-character code.
Godot's built-in `WebSocketPeer` connects to Photon over TLS. `photon_peer.gd`
adapts Photon events to `MultiplayerPeerExtension`, preserving the existing
Godot RPC protocol, host simulation, game rules, rosters and snapshot codec.
No native Fusion preview extension or web view is included.

The transport follows Photon Realtime's JSON WebSocket framing and operation
workflow documented by the official Exit Games JavaScript SDK 4.4.0, available
as `photon-realtime` on npm. No JavaScript SDK files are bundled with the game.
See https://doc.photonengine.com/realtime/v5/realtime-intro and
https://www.npmjs.com/package/photon-realtime .

Application: `VOLOBALL Realtime`, App ID `358a2750-d824-4049-ad0d-cb0b587d0bda`.
This identifier belongs in the client and is not an administrator credential.
No account password, session cookie or administration token belongs in the repo.
Region: EU. Current account plan: free development, 20 total concurrent users,
60 GB/month. Room limit: 10 connections. No paid plan was selected.

One player hosts the simulation and must keep the app running. Host departure
ends the session; automatic host migration is intentionally unsupported.
Room admission closes during a match and reopens after returning to the lobby.
Reconnect after a failure creates a fresh transport; stale RPC queues are cleared.
TCP/WebSocket may have higher delay on poor connections than a UDP transport.
The current free development service is intended for testing.

Validation:

- `python3 tools/test_photon_online.py --godot <Godot executable>` starts two
  real clients from the original mobile menu through a complete network match.
- Add `--rendered` for a rendered run on desktop.
- `Godot --headless --path . --script res://test_photon_capacity.gd` verifies
  10 users, eleventh-user rejection, broadcast/targeted events, closing a room
  and notifying clients when the host leaves.
- These tests use temporary unlisted rooms and no account credentials.

Android builds remain paused. The PC worktree is separate and has not been
updated to this transport.
