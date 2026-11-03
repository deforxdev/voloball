"""Exercise actual iOS startup, Settings -> Back, and relaunch in Simulator."""
import json
import os
from pathlib import Path
import subprocess
import time

def command(*args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()

devices = json.loads(command("xcrun", "simctl", "list", "devices", "available", "--json"))["devices"]
candidates = [(runtime, d) for runtime, group in devices.items() if ".iOS-" in runtime
              for d in group if "iPhone" in d["name"] and d.get("isAvailable", True)]
if not candidates:
    raise RuntimeError("No iPhone Simulator is installed")
preferred = [pair for pair in candidates if "iOS-18-" in pair[0]]
_, device = sorted(preferred or candidates, key=lambda pair: pair[0])[0]
udid = device["udid"]
print("Testing iOS startup on", device["name"], udid, flush=True)
if device["state"] != "Booted":
    subprocess.run(["xcrun", "simctl", "boot", udid], check=True)
subprocess.run(["xcrun", "simctl", "bootstatus", udid, "-b"], check=True, timeout=300)
bundle = "com.deforxdev.voloball"
app = "build/Simulator/Build/Products/Release-iphonesimulator/voloball.app"
subprocess.run(["xcrun", "simctl", "install", udid, app], check=True)
data = Path(command("xcrun", "simctl", "get_app_container", udid, bundle, "data"))
environment = dict(os.environ, SIMCTL_CHILD_VOLOBALL_BOOT_SMOKE="match")
previous = None
results = []
for attempt in (1, 2):
    for stale in data.rglob("mobile-smoke.json"):
        stale.unlink()
    # Exercise the same Compatibility pipeline shipped on physical phones.
    subprocess.run(["xcrun", "simctl", "launch", udid, bundle,
                    "--rendering-method", "gl_compatibility", "--rendering-driver", "opengl3"],
                   env=environment, check=True)
    deadline = time.monotonic() + 210
    result = None
    while time.monotonic() < deadline:
        for path in data.rglob("mobile-smoke.json"):
            try:
                result = json.loads(path.read_text())
            except (OSError, json.JSONDecodeError):
                continue
            if result["phase"] == "failed":
                raise RuntimeError(result)
            if result["phase"] == "passed":
                break
        if result and result["phase"] == "passed":
            break
        time.sleep(2)
    else:
        raise RuntimeError(f"iOS startup attempt {attempt} did not finish: {result}")
    assert result["profile"], "No active profile after startup"
    if previous:
        assert result["run_id"] != previous["run_id"], "Stale startup result"
        assert result["profile"] == previous["profile"], "Profile was lost on relaunch"
        assert not result["fresh"], "Relaunch incorrectly restarted first-run setup"
    results.append(result)
    print(f"PASS: iOS launch {attempt}, Settings -> Back, responsive menu", result, flush=True)
    subprocess.run(["xcrun", "simctl", "io", udid, "screenshot", f"build/ios-startup-{attempt}.png"], check=True)
    subprocess.run(["xcrun", "simctl", "terminate", udid, bundle], check=True)
    previous = result
Path("build/ios-startup-results.json").write_text(json.dumps(results, indent=2))
print("IOS STARTUP SMOKE COMPLETE: failures=0", flush=True)
