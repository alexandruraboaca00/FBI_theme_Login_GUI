#!/usr/bin/env python3
"""Independent previews; never rewrite the source theme or its user settings."""
import configparser
from contextlib import contextmanager
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

PROJECT = Path(__file__).resolve().parent.parent


@contextmanager
def prepared_theme(variant):
    if variant not in ("original", "crt", "nuevo", "puntos", "focos"):
        raise ValueError("Variante válida: original, crt, nuevo, puntos o focos")
    with tempfile.TemporaryDirectory(prefix="sddm-preview-" + variant + "-") as directory:
        theme = Path(directory) / "theme"
        shutil.copytree(PROJECT / "src/theme", theme)
        overrides = theme / "theme.conf.user"
        config = configparser.ConfigParser(interpolation=None)
        config.optionxform = str
        if overrides.exists():
            config.read(overrides)
        if not config.has_section("General"):
            config.add_section("General")
        config["General"]["CRT"] = "true" if variant != "original" else "false"
        config["General"]["AnimatedMap"] = "true" if variant != "original" else "false"
        # Freeze each comparison preset so later settings do not change older previews.
        config["General"]["ClockPosition"] = "header" if variant in ("nuevo", "puntos", "focos") else "footer"
        config["General"]["CRTStrength"] = "0.24" if variant in ("nuevo", "puntos", "focos") else "0.09"
        config["General"]["MapOpacity"] = "0.24" if variant in ("nuevo", "puntos", "focos") else "0.13"
        config["General"]["MapStyle"] = "threats" if variant == "focos" else "dots"
        config["General"]["MapDotSize"] = "2.7" if variant in ("puntos", "focos") else "2"
        if variant in ("puntos", "focos"):
            config["General"]["MapOpacity"] = "0.48" if variant == "puntos" else "0.56"
            config["General"]["Animations"] = "true"
        with overrides.open("w") as stream:
            config.write(stream)
        yield theme


def main():
    variant = sys.argv[1] if len(sys.argv) == 2 else "focos"
    if len(sys.argv) > 2 or variant not in ("original", "crt", "nuevo", "puntos", "focos"):
        print("Uso: preview.sh [original|crt|nuevo|puntos|focos]", file=sys.stderr)
        return 2
    print(f"Vista previa {variant}: TEST-MODE. Cierra la ventana para salir.", flush=True)
    try:
        with prepared_theme(variant) as theme:
            return subprocess.run(["sddm-greeter-qt6", "--test-mode", "--theme", str(theme)]).returncode
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
