#!/usr/bin/env python3
"""SDDM theme lifecycle. Dry-run by default. No sudo, service or PAM operations."""
import argparse
import configparser
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import stat
import sys
import tempfile

NAME = "federal-intelligence"
PROJECT = Path(__file__).resolve().parent.parent


def digest(data):
    return hashlib.sha256(data).hexdigest()


class Manager:
    def __init__(self, root, source=PROJECT / "src/theme"):
        self.root = Path(root).absolute()
        if self.root.is_symlink():
            raise ValueError("La raíz no puede ser un enlace simbólico")
        self.source = Path(source)
        self.target = self.path("usr/share/sddm/themes/" + NAME)
        self.state = self.path("var/lib/sddm-custom")
        self.conf = self.path("etc/sddm.conf")

    def path(self, relative):
        result = self.root / relative
        for part in (result, *result.parents):
            if part.is_symlink():
                raise ValueError(f"Se rechaza enlace simbólico: {part}")
        return result

    def read_json(self, name):
        p = self.path("var/lib/sddm-custom/" + name)
        return json.loads(p.read_text()) if p.exists() else None

    def write_json(self, name, data):
        self.state.mkdir(parents=True, exist_ok=True, mode=0o700)
        self.atomic(self.path("var/lib/sddm-custom/" + name),
                    (json.dumps(data, indent=2) + "\n").encode(), 0o600)

    @staticmethod
    def atomic(path, data, mode=0o644, uid=None, gid=None):
        path.parent.mkdir(parents=True, exist_ok=True)
        fd, temp = tempfile.mkstemp(prefix=".sddm-custom-", dir=path.parent)
        try:
            with os.fdopen(fd, "wb") as stream:
                stream.write(data)
                stream.flush()
                os.fsync(stream.fileno())
            os.chmod(temp, mode)
            if uid is not None and os.geteuid() == 0:
                os.chown(temp, uid, gid)
            os.replace(temp, path)
        finally:
            if os.path.exists(temp):
                os.unlink(temp)

    def config_files(self):
        files = []
        for directory in ("usr/lib/sddm/sddm.conf.d", "etc/sddm.conf.d"):
            folder = self.path(directory)
            for p in sorted(folder.glob("*.conf")):
                files.append(self.path(str(p.relative_to(self.root))))
        if self.conf.exists():
            files.append(self.conf)
        return files

    def effective_theme(self):
        current, directory = "", "/usr/share/sddm/themes"
        for p in self.config_files():
            parser = configparser.ConfigParser(interpolation=None, strict=False)
            parser.optionxform = str
            parser.read_string(p.read_text())
            if parser.has_section("Theme"):
                current = parser.get("Theme", "Current", fallback=current)
                directory = parser.get("Theme", "ThemeDir", fallback=directory)
        return current, directory

    @staticmethod
    def manifest(folder):
        result = {}
        for p in sorted(folder.rglob("*")):
            if p.is_symlink():
                raise ValueError(f"Recurso simbólico no permitido: {p}")
            if p.is_file():
                result[str(p.relative_to(folder))] = digest(p.read_bytes())
        return result

    def verify_owned(self, allow_user_config=False):
        state = self.read_json("installation.json")
        if not state or not self.target.is_dir():
            raise ValueError("No existe una instalación propia registrada")
        actual, expected = self.manifest(self.target), dict(state["files"])
        if allow_user_config:
            actual.pop("theme.conf.user", None)
            expected.pop("theme.conf.user", None)
        if actual != expected:
            raise ValueError("Archivos instalados cambiados o añadidos; conservarlos y revisar antes de continuar")
        return state

    def install(self):
        files = self.manifest(self.source)
        for required in ("Main.qml", "metadata.desktop", "theme.conf", "assets/reference.jpg"):
            if required not in files:
                raise ValueError(f"Tema incompleto: falta {required}")
        if self.target.exists():
            state = self.verify_owned()
            if files == state["files"]:
                print("Instalación idéntica ya presente; sin cambios")
                return
            raise ValueError("Existe otra versión: restaurar y desinstalar antes de actualizar")
        self.target.parent.mkdir(parents=True, exist_ok=True)
        stage = Path(tempfile.mkdtemp(prefix=".sddm-custom-", dir=self.target.parent))
        try:
            for rel in files:
                dst = stage / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(self.source / rel, dst)
                dst.chmod(0o644)
            for p in stage.rglob("*"):
                if p.is_dir():
                    p.chmod(0o755)
            stage.chmod(0o755)
            # Marker first: an interruption cannot authorize deletion of foreign files.
            self.write_json("installation.json", {"theme": NAME, "files": files})
            stage.rename(self.target)
        finally:
            if stage.exists():
                shutil.rmtree(stage)
        print(f"Instalado sin activar: {self.target}")

    def backup(self):
        self.state.mkdir(parents=True, exist_ok=True, mode=0o700)
        folder = Path(tempfile.mkdtemp(prefix=datetime.datetime.now().strftime("%Y%m%d-%H%M%S-"),
                                       dir=self.state))
        meta = {"files": {}, "main_exists": self.conf.exists()}
        for p in self.config_files():
            rel = str(p.relative_to(self.root))
            dst = folder / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(p, dst)
            info = p.stat()
            meta["files"][rel] = {"sha256": digest(p.read_bytes()), "mode": stat.S_IMODE(info.st_mode),
                                  "uid": info.st_uid, "gid": info.st_gid}
        (folder / "snapshot.json").write_text(json.dumps(meta, indent=2) + "\n")
        print(f"Copia de seguridad: {folder}")
        return folder, meta

    @staticmethod
    def activate_text(original):
        # Keep comments, unrelated groups, encoding and line endings intact.
        text = original.decode("utf-8")
        lines = text.splitlines(keepends=True)
        sections = [(i, re.match(r"^\s*\[([^]]+)\]\s*$", line)) for i, line in enumerate(lines)]
        sections = [(i, m[1]) for i, m in sections if m]
        themes = [i for i, name in sections if name == "Theme"]
        if len(themes) > 1:
            raise ValueError("Hay secciones Theme duplicadas; revisión manual necesaria")
        eol = "\r\n" if "\r\n" in text else "\n"
        if not themes:
            return (text + (eol if text and not text.endswith("\n") else "") +
                    f"[Theme]{eol}Current={NAME}{eol}").encode()
        start = themes[0]
        end = next((i for i, _ in sections if i > start), len(lines))
        keys = [i for i in range(start + 1, end) if re.match(r"^\s*Current\s*=", lines[i])]
        if len(keys) > 1:
            raise ValueError("Current duplicado; revisión manual necesaria")
        if keys:
            lines[keys[0]] = f"Current={NAME}{eol}"
        else:
            if lines[start] and not lines[start].endswith("\n"):
                lines[start] += eol
            lines.insert(start + 1, f"Current={NAME}{eol}")
        return "".join(lines).encode()

    def activate(self):
        self.verify_owned(allow_user_config=True)
        if self.read_json("active.json"):
            raise ValueError("Ya hay una activación pendiente de restauración")
        current, directory = self.effective_theme()
        if directory != "/usr/share/sddm/themes":
            raise ValueError("ThemeDir personalizado: revisar manualmente antes de activar")
        if current == NAME:
            raise ValueError("Tema ya activo sin transacción propia; revisar manualmente")
        # Recovery alternatives must remain installed.
        for alternative in ("elarun", "breeze"):
            if not self.path("usr/share/sddm/themes/" + alternative + "/Main.qml").is_file():
                raise ValueError(f"Falta la alternativa de recuperación {alternative}")
        original = self.conf.read_bytes() if self.conf.exists() else b""
        changed = self.activate_text(original)
        folder, meta = self.backup()
        self.write_json("active.json", {"backup": folder.name, "activated_sha256": digest(changed),
                                        "previous_theme": current})
        info = meta["files"].get("etc/sddm.conf", {"mode": 0o644, "uid": 0, "gid": 0})
        self.atomic(self.conf, changed, info["mode"], info["uid"], info["gid"])
        print("Activado para el siguiente inicio del greeter. No se reinicia ningún servicio.")

    def restore(self):
        state = self.read_json("active.json")
        if not state:
            raise ValueError("No existe una activación propia para restaurar")
        if Path(state["backup"]).name != state["backup"]:
            raise ValueError("Identificador de copia inválido")
        folder = self.path("var/lib/sddm-custom/" + state["backup"])
        meta_path = self.path(str((folder / "snapshot.json").relative_to(self.root)))
        meta = json.loads(meta_path.read_text())
        info = meta["files"].get("etc/sddm.conf")
        original_path = self.path(str((folder / "etc/sddm.conf").relative_to(self.root)))
        original = original_path.read_bytes() if info else None
        if info and digest(original) != info["sha256"]:
            raise ValueError("Copia de seguridad alterada; se rechaza restauración")
        current = self.conf.read_bytes() if self.conf.exists() else None
        if current == original:
            print("La configuración anterior ya está restaurada")
        elif current is None or digest(current) != state["activated_sha256"]:
            raise ValueError("sddm.conf cambió después de activar: no se sobrescribe. Revisar copia manualmente")
        elif original is not None:
            self.atomic(self.conf, original, info["mode"], info["uid"], info["gid"])
        else:
            self.conf.unlink()
        self.path("var/lib/sddm-custom/active.json").unlink()
        print("Configuración anterior restaurada. Copias conservadas; ningún servicio reiniciado.")

    def uninstall(self):
        if self.read_json("active.json") or self.effective_theme()[0] == NAME:
            raise ValueError("Restaurar el tema anterior antes de desinstalar")
        self.verify_owned()
        shutil.rmtree(self.target)
        self.path("var/lib/sddm-custom/installation.json").unlink()
        print("Eliminados sólo los archivos propios verificados. Copias conservadas.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["backup", "install", "activate", "restore", "uninstall"])
    parser.add_argument("--apply", action="store_true", help="Ejecutar las escrituras descritas")
    parser.add_argument("--root", default="/", help="Raíz alternativa exclusivamente para pruebas aisladas")
    parser.add_argument("--variant", choices=["original", "crt", "nuevo", "puntos", "focos"],
                        help="Instalar un preset de vista previa con sus ajustes exactos")
    args = parser.parse_args()
    if args.variant and args.action != "install":
        parser.error("--variant sólo se admite con install")
    try:
        manager = Manager(args.root)
        current, directory = manager.effective_theme()
        print(f"Acción: {args.action}; raíz: {manager.root}; tema efectivo: {current or '(vacío)'}; ThemeDir: {directory}")
        plans = {
            "install": f"Copiar tema autocontenido a {manager.target}; registrar manifiesto. No activar.",
            "backup": f"Copiar configuración SDDM a {manager.state}, sin modificar el original.",
            "activate": "Verificar instalación y alternativas; respaldar; cambiar sólo [Theme] Current en /etc/sddm.conf (prioridad máxima).",
            "restore": "Restaurar sólo /etc/sddm.conf de la transacción propia, si no se modificó después.",
            "uninstall": "Eliminar sólo el directorio propio si coincide con el manifiesto y no está activo."
        }
        print(plans[args.action])
        if args.variant:
            print(f"Preset seleccionado: {args.variant}; se incluye theme.conf.user sin modificar el tema fuente.")
        print("No se modifican PAM, Plasma Login Manager, autologin ni servicios.")
        if not args.apply:
            print("SIMULACIÓN. Para ejecutar, volver a invocar explícitamente con --apply y privilegios administrativos.")
            return 0
        if manager.root == Path("/") and os.geteuid() != 0:
            raise ValueError("Operación del sistema requiere root; este programa nunca invoca sudo")
        if args.variant:
            from preview import prepared_theme
            with prepared_theme(args.variant) as theme:
                manager.source = theme
                manager.install()
        else:
            getattr(manager, args.action)()
        return 0
    except (ValueError, OSError, KeyError, configparser.Error) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
