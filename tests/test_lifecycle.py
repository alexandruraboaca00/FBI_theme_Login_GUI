"""Never targets the live system. Every mutation is confined to pytest tmp_path."""
import importlib.util
from pathlib import Path
import pytest
import subprocess
import configparser

spec = importlib.util.spec_from_file_location("theme_manager", Path(__file__).parents[1] / "scripts/manage.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


@pytest.fixture
def manager(tmp_path):
    root = tmp_path / "system"
    root.mkdir()
    m = module.Manager(root)
    m.conf.parent.mkdir()
    m.conf.write_bytes(b"# unchanged\n[General]\nDisplayServer=x11\n\n[Theme]\nCurrent=elarun\n")
    for name in ("elarun", "breeze"):
        p = m.path("usr/share/sddm/themes/" + name)
        p.mkdir(parents=True)
        (p / "Main.qml").write_text("// foreign theme\n")
    return m


def test_complete_lifecycle_and_priority(manager):
    m = manager
    original = m.conf.read_bytes()
    dropin = m.path("etc/sddm.conf.d/99-existing.conf")
    dropin.parent.mkdir()
    dropin.write_text("[Theme]\nCurrent=breeze\n")
    m.install()
    m.install()  # idempotent
    assert m.effective_theme()[0] == "elarun"
    m.activate()
    assert m.effective_theme()[0] == module.NAME
    assert b"DisplayServer=x11" in m.conf.read_bytes()
    with pytest.raises(ValueError):
        m.uninstall()
    m.restore()
    assert m.conf.read_bytes() == original
    m.uninstall()
    assert not m.target.exists()
    assert dropin.read_text() == "[Theme]\nCurrent=breeze\n"
    assert m.path("usr/share/sddm/themes/breeze/Main.qml").exists()


def test_refuse_foreign_target(manager):
    manager.target.mkdir()
    (manager.target / "foreign.txt").write_text("preserve")
    with pytest.raises(ValueError):
        manager.install()
    assert (manager.target / "foreign.txt").read_text() == "preserve"


def test_refuse_modified_config(manager):
    manager.install()
    manager.activate()
    manager.conf.write_text(manager.conf.read_text() + "# later change\n")
    with pytest.raises(ValueError):
        manager.restore()
    assert manager.conf.read_text().endswith("# later change\n")


def test_refuse_modified_theme(manager):
    manager.install()
    (manager.target / "theme.conf.user").write_text("[General]\nDim=0.2\n")
    with pytest.raises(ValueError):
        manager.uninstall()


def test_user_overrides_allowed_on_activation(manager):
    manager.install()
    (manager.target / "theme.conf.user").write_text("[General]\nDim=0.2\n")
    manager.activate()
    manager.restore()
    with pytest.raises(ValueError):
        manager.uninstall()


def test_missing_main_config(manager):
    manager.conf.unlink()
    manager.install()
    manager.activate()
    assert manager.conf.exists()
    manager.restore()
    assert not manager.conf.exists()


def test_symlinks_rejected(manager, tmp_path):
    manager.target.symlink_to(tmp_path, target_is_directory=True)
    with pytest.raises(ValueError):
        module.Manager(manager.root)


def test_duplicate_keys_rejected():
    with pytest.raises(ValueError):
        module.Manager.activate_text(b"[Theme]\nCurrent=elarun\nCurrent=breeze\n")
    with pytest.raises(ValueError):
        module.Manager.activate_text(b"[Theme]\nCurrent=elarun\n[Theme]\nCurrent=breeze\n")


def test_preserve_crlf_and_other_groups():
    result = module.Manager.activate_text(b"[General]\r\nDisplayServer=x11\r\n[Theme]\r\nCurrent=elarun\r\n")
    assert result == b"[General]\r\nDisplayServer=x11\r\n[Theme]\r\nCurrent=federal-intelligence\r\n"


def test_custom_themedir_rejected(manager):
    manager.conf.write_text("[Theme]\nCurrent=elarun\nThemeDir=/opt/themes\n")
    manager.install()
    with pytest.raises(ValueError):
        manager.activate()


def test_install_selected_focos_cli(manager):
    script = Path(__file__).parents[1] / "scripts/manage.py"
    subprocess.run(["python3", str(script), "install", "--root", str(manager.root),
                    "--variant", "focos", "--apply"], check=True, capture_output=True)
    config = configparser.ConfigParser()
    config.read(manager.target / "theme.conf.user")
    assert config["General"]["MapStyle"] == "threats"
    assert config["General"]["ClockPosition"] == "header"
    assert config["General"]["MapOpacity"] == "0.56"
    assert (manager.target / "components/SeaTraffic.qml").exists()
    assert "theme.conf.user" in manager.verify_owned()["files"]
    manager.activate()
    manager.restore()
    manager.uninstall()
