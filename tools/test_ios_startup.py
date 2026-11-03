"""Verify native iOS offline mobile match and preserve diagnostics on every result."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

def command(*args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()

build = Path('build')
build.mkdir(exist_ok=True)
devices = json.loads(command('xcrun', 'simctl', 'list', 'devices', 'available', '--json'))['devices']
candidates = [(runtime, d) for runtime, group in devices.items() if '.iOS-' in runtime
              for d in group if 'iPhone' in d['name'] and d.get('isAvailable', True)]
if not candidates:
    raise RuntimeError('No iPhone Simulator is installed')
preferred = [pair for pair in candidates if 'iOS-18-' in pair[0]]
_, device = sorted(preferred or candidates, key=lambda pair: pair[0])[0]
udid = device['udid']
print('Testing native iOS offline mobile match on', device['name'], udid, flush=True)
if device['state'] != 'Booted':
    subprocess.run(['xcrun', 'simctl', 'boot', udid], check=True)
subprocess.run(['xcrun', 'simctl', 'bootstatus', udid, '-b'], check=True, timeout=300)
bundle = 'com.deforxdev.voloball'
app = 'build/Simulator/Build/Products/Release-iphonesimulator/voloball.app'
subprocess.run(['xcrun', 'simctl', 'install', udid, app], check=True)
data = Path(command('xcrun', 'simctl', 'get_app_container', udid, bundle, 'data'))
environment = dict(os.environ, SIMCTL_CHILD_VOLOBALL_BOOT_SMOKE='match')
previous = None
results = []
for attempt in (1, 2):
    for stale in data.rglob('mobile-smoke.json'):
        stale.unlink()
    result = None
    pid = None
    try:
        launch = command('xcrun', 'simctl', 'launch', udid, bundle,
                         '--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', env=environment)
        print(launch, flush=True)
        pid = int(launch.rsplit(':', 1)[1].strip())
        deadline = time.monotonic() + 650
        next_status = 0.0
        while time.monotonic() < deadline:
            for path in data.rglob('mobile-smoke.json'):
                try:
                    result = json.loads(path.read_text())
                except (OSError, json.JSONDecodeError):
                    continue
                if result['phase'] == 'failed':
                    raise RuntimeError(result)
                if result['phase'] == 'passed':
                    break
            if result and result['phase'] == 'passed':
                break
            try:
                os.kill(pid, 0)
            except ProcessLookupError:
                raise RuntimeError(f'iOS app process exited: {result}')
            if time.monotonic() >= next_status:
                print('iOS progress:', result, flush=True)
                subprocess.run(['ps', '-p', str(pid), '-o', 'pid,etime,pcpu,rss,stat,comm'], check=False)
                next_status = time.monotonic() + 30
            time.sleep(2)
        else:
            raise RuntimeError(f'iOS match attempt {attempt} timed out: {result}')
        assert result['profile'], 'No active profile after startup'
        if previous:
            assert result['run_id'] != previous['run_id'], 'Stale startup result'
            assert result['profile'] == previous['profile'], 'Profile was lost on relaunch'
            assert not result['fresh'], 'Relaunch restarted first-run setup'
        results.append(result)
        print(f'PASS: native iOS offline match and restart, launch {attempt}', result, flush=True)
        previous = result
    except Exception as error:
        results.append({'attempt': attempt, 'error': str(error), 'last_result': result})
        raise
    finally:
        Path('build/ios-startup-results.json').write_text(json.dumps(results, indent=2))
        try:
            subprocess.run(['xcrun', 'simctl', 'io', udid, 'screenshot', f'build/ios-startup-{attempt}.png'], check=False, timeout=30)
        except Exception as error:
            print('Screenshot unavailable:', error, flush=True)
        for source in data.rglob('*'):
            if source.is_file() and (source.suffix == '.log' or source.name == 'mobile-smoke.json'):
                if source.stat().st_size < 5_000_000:
                    shutil.copyfile(source, build / f'ios-native-{attempt}-{source.name}')
        diagnostic_dir = Path.home() / 'Library/Logs/DiagnosticReports'
        for source in diagnostic_dir.glob('voloball*'):
            if source.is_file() and source.suffix in ('.ips', '.crash'):
                shutil.copyfile(source, build / f'ios-native-{attempt}-{source.name}')
        subprocess.run(['xcrun', 'simctl', 'terminate', udid, bundle], check=False, timeout=30)
print('IOS STARTUP SMOKE COMPLETE: failures=0', flush=True)
