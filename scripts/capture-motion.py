#!/usr/bin/env python3
"""Record actual test-mode frames of the focos preview and export a review GIF."""
import json
import os
from pathlib import Path
import subprocess
from preview import prepared_theme

project = Path(__file__).resolve().parent.parent
frames = project / 'tests/screenshots/focos-motion-frames'
frames.mkdir(parents=True, exist_ok=True)
config = project / 'tests/results/focos-motion-screen.json'
config.write_text(json.dumps({'windowFrameMargins': False, 'screens': [
    {'name': 'Primary', 'width': 1280, 'height': 720, 'dpr': 1, 'logicalDpi': 96, 'logicalBaseDpi': 96}]}))
env = os.environ.copy()
env.update(QT_QPA_PLATFORM='offscreen:configfile=' + str(config), QT_QUICK_BACKEND='software',
           QT_SCALE_FACTOR='1', LD_PRELOAD=str(project / 'build/libgreeter-capture.so'),
           SDDM_CAPTURE_PATH=str(frames / 'focos.png'), SDDM_CAPTURE_DEMO='1', SDDM_CAPTURE_FRAMES='50')
with prepared_theme('focos') as theme:
    with (project / 'tests/results/focos-motion.log').open('w') as log:
        subprocess.run(['sddm-greeter-qt6', '--test-mode', '--theme', str(theme)],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=25)
files = sorted(frames.glob('focos-frame-*.png'))
assert len(files) == 50, len(files)
assert len({file.read_bytes() for file in files}) > 40, 'Animation frames did not change'
subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-framerate', '10',
                '-i', str(frames / 'focos-frame-%03d.png'),
                '-filter_complex', 'scale=960:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse',
                '-loop', '0', str(project / 'tests/screenshots/focos-motion.gif')], check=True)
print('50 actual greeter frames captured; review GIF exported (10 fps, software).')
