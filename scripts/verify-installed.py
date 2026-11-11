#!/usr/bin/env python3
"""Verify installed focos files and access as sddm; optionally select the theme."""
import argparse
import configparser
import json
import os
from pathlib import Path
import pwd
import subprocess
import sys
from manage import Manager, NAME


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--activate", action="store_true",
                        help="Tras verificar, respaldar y seleccionar el tema; no reiniciar servicios")
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error("La lectura del manifiesto protegido y la comprobación como sddm requieren root")
    manager = Manager("/")
    state = manager.verify_owned()
    settings = configparser.ConfigParser(interpolation=None)
    settings.read([manager.target / "theme.conf", manager.target / "theme.conf.user"])
    expected = {"MapStyle": "threats", "ClockPosition": "header", "MapOpacity": "0.56"}
    for key, value in expected.items():
        if settings.get("General", key) != value:
            raise ValueError(f"El preset instalado no coincide: {key}")
    if not settings.getboolean("General", "ShowShips", fallback=True):
        raise ValueError("ShowShips desactivado en el preset instalado")
    files = [str(manager.target / name) for name in state["files"]]
    account = pwd.getpwnam("sddm")
    # This child really drops privileges; it only opens installed files for reading.
    child = subprocess.run(["/usr/bin/python3", "-c",
                            "import json,sys; from pathlib import Path; "
                            "files=json.load(sys.stdin); "
                            "[Path(p).read_bytes() for p in files]; "
                            "print(str(len(files))+' recursos legibles como usuario sddm')"],
                           input=json.dumps(files), text=True, check=True, cwd="/",
                           user=account.pw_uid, group=account.pw_gid, extra_groups=[])
    print("Manifiesto íntegro y preset focos con barcos verificados.", flush=True)
    if args.activate:
        manager.activate()
        if manager.effective_theme()[0] != NAME:
            raise ValueError("La selección efectiva no coincide tras activar")
        active = manager.read_json("active.json")
        backup = manager.state / active["backup"]
        print(f"Copia de seguridad: {backup}")
        print(f"Tema anterior: {active['previous_theme']}")
        print("Seleccionado para el siguiente greeter. La sesión actual no se ha cerrado.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        sys.exit(1)
