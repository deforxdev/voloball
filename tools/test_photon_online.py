"""Run two actual Godot clients through Photon Cloud and a complete mobile match."""
import argparse
import os
import uuid
from pathlib import Path
import re
import subprocess
import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    parser.add_argument("--output", type=Path, default=Path("build/cloud-tests"))
    parser.add_argument("--rendered", action="store_true")
    parser.add_argument("--quick", action="store_true")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    startup = None
    if hasattr(subprocess, "STARTUPINFO"):
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 0
    command = [args.godot, "--path", str(Path(__file__).resolve().parents[1]),
               "--scene", "res://test_cloud_online.tscn"]
    if not args.rendered:
        command.append("--headless")
    env = dict(os.environ, VOLOBALL_PHOTON_TEST_QUEUE=uuid.uuid4().hex[:12])
    processes = []
    files = []
    paths = [args.output / (role + ".log") for role in ("host", "client")]
    try:
        def launch(role, extra):
            output = paths[len(processes)].open("w", encoding="utf-8")
            files.append(output)
            process = subprocess.Popen(command + ["--", "--drive-role", "photon_" + role] + extra,
                                       stdout=output, stderr=subprocess.STDOUT, startupinfo=startup, env=env)
            processes.append(process)
            return process

        host = launch("host", ["--cloud-quick"] if args.quick else [])
        deadline = time.monotonic() + 55
        code = None
        while time.monotonic() < deadline:
            output = paths[0].read_text(encoding="utf-8", errors="replace")
            match = re.search(r"CLOUD CODE: ([A-Z2-9]{8})", output)
            if match:
                code = match[1]
                break
            if host.poll() is not None or "SCRIPT ERROR" in output or "Parse Error" in output:
                break
            time.sleep(0.2)
        assert code, "Cloud host did not create a room:\n" + output[-9000:]
        launch("client", ["--cloud-quick"] if args.quick else ["--cloud-code=" + code])
        print("Two mobile game clients connected to the real Photon Cloud", flush=True)
        deadline = time.monotonic() + 100
        for process in processes:
            process.wait(timeout=max(1, deadline - time.monotonic()))
        for role, process, path in zip(("HOST", "CLIENT"), processes, paths):
            output = path.read_text(encoding="utf-8", errors="replace")
            assert process.returncode == 0, output[-12000:]
            assert "CLOUD " + role + " MATCH PASS" in output, output[-12000:]
            assert not any(error in output for error in ("ERROR:", "SCRIPT ERROR", "Shader Error")), output[-12000:]
        print("PHOTON ONLINE PASS: original menu, room creation/join, full match, client inputs, host snapshots, clean departure", flush=True)
    finally:
        for process in processes:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=10)
        for output in files:
            output.close()


if __name__ == "__main__":
    main()
