#!/usr/bin/env python3
"""Capture the actual greeter in explicit test-mode; software/offscreen only."""
import json
import os
from pathlib import Path
import subprocess
import sys
from contextlib import nullcontext
from preview import prepared_theme

project = Path(__file__).resolve().parent.parent
results = project / "tests/results"
screenshots = project / "tests/screenshots"
results.mkdir(parents=True, exist_ok=True)
screenshots.mkdir(parents=True, exist_ok=True)
subprocess.run(["cmake", "-S", str(project / "tools"), "-B", str(project / "build"), "-G", "Ninja"], check=True)
subprocess.run(["cmake", "--build", str(project / "build")], check=True)
cases = [("1600x900", 1600, 900, 1, False), ("1920x1080", 1920, 1080, 1, False),
         ("1366x768", 1366, 768, 1, False), ("2560x1440", 2560, 1440, 1, False),
         ("fractional-1.25", 1920, 1080, 1.25, False), ("dual-monitor", 1920, 1080, 1, True)]
variant = sys.argv[1] if len(sys.argv) > 1 else None
context = prepared_theme(variant) if variant else nullcontext(project / "src/theme")
with context as theme:
    for name, width, height, dpr, dual in cases:
        name = variant + "-" + name if variant else name
        screens = [{"name": "Primary", "width": width, "height": height,
                    "logicalDpi": 96, "logicalBaseDpi": 96, "dpr": 1}]
        if dual:
            screens.append({"name": "Secondary", "x": width, "width": 1366, "height": 768,
                            "logicalDpi": 96, "logicalBaseDpi": 96, "dpr": 1})
        config = results / (name + ".json")
        config.write_text(json.dumps({"windowFrameMargins": False, "screens": screens}))
        env = os.environ.copy()
        env.update(QT_QPA_PLATFORM="offscreen:configfile=" + str(config), QT_QUICK_BACKEND="software",
                   QT_SCALE_FACTOR=str(dpr), QT_SCALE_FACTOR_ROUNDING_POLICY="PassThrough",
                   LD_PRELOAD=str(project / "build/libgreeter-capture.so"),
                   SDDM_CAPTURE_PATH=str(screenshots / (name + ".png")), SDDM_CAPTURE_DEMO="1")
        with (results / (name + "-greeter.log")).open("w") as log:
            subprocess.run(["sddm-greeter-qt6", "--test-mode", "--theme", str(theme)],
                           env=env, stdout=log, stderr=subprocess.STDOUT, timeout=15, check=True)
        report = json.loads((screenshots / (name + ".png.json")).read_text())
        assert len(report) == (2 if dual else 1), report
        assert sum(item["interactive"] for item in report) == 1, report
        primary = next(item for item in report if item["interactive"])
        assert primary["devicePixelRatio"] == dpr, report
        assert primary["width"] == width and primary["height"] == height, report
        print(name, "OK", [(r["width"], r["height"], r["sessions"]) for r in report])
