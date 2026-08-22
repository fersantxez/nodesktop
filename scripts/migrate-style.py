#!/usr/bin/env python3
"""Safely migrate a persistent Nodesktop home to the current visual contract."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile
import time
import xml.etree.ElementTree as ET

VERSION = "lookupdate-3"
PRIOR_DEFAULT = "forest-semantic-4"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def backup(home: Path, paths: list[Path], prior: str) -> tuple[Path | None, dict[str, str]]:
    present = [path for path in paths if path.exists()]
    if not present:
        return None, {}
    root = home / ".config/nodesktop/backups" / f"{time.strftime('%Y%m%dT%H%M%SZ', time.gmtime())}-{prior}"
    counter = 1
    while root.exists():
        root = root.with_name(f"{root.name}-{counter}")
        counter += 1
    checksums: dict[str, str] = {}
    for path in present:
        relative = path.relative_to(home)
        destination = root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, destination)
        checksums[str(relative)] = digest(path)
    (root / "manifest.json").write_text(json.dumps({"from": prior, "to": VERSION, "checksums": checksums}, indent=2) + "\n")
    return root, checksums


def record_migrated_checksums(home: Path, root: Path, old_checksums: dict[str, str], prior: str) -> None:
    """Record the exact post-migration state used by safe rollback."""
    migrated: dict[str, str] = {}
    for relative in old_checksums:
        current = home / relative
        if current.exists():
            migrated[relative] = digest(current)
    manifest = {
        "from": prior,
        "to": VERSION,
        "checksums": old_checksums,
        "migrated_checksums": migrated,
    }
    (root / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


def atomic_copy(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as handle:
        temporary = Path(handle.name)
        handle.write(source.read_bytes())
    os.chmod(temporary, source.stat().st_mode & 0o777)
    temporary.replace(destination)


def replace_known(path: Path, source: Path, replacements: dict[str, str]) -> bool:
    if not path.exists():
        atomic_copy(source, path)
        return True
    original = path.read_text(encoding="utf-8")
    updated = original
    for old, new in replacements.items():
        updated = updated.replace(old, new)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def set_xfce_property(path: Path, name: str, value: str, allowed: set[str]) -> None:
    tree = ET.parse(path)
    changed = False
    for element in tree.iter("property"):
        if element.get("name") == name and element.get("value") in allowed:
            element.set("value", value)
            changed = True
    if changed:
        tree.write(path, encoding="UTF-8", xml_declaration=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--home", type=Path, default=Path.home())
    parser.add_argument("--defaults", type=Path, default=Path("/usr/local/share/nodesktop"))
    parser.add_argument("--scale", choices=("100", "125"), default=os.environ.get("NODESKTOP_UI_SCALE", "100"))
    args = parser.parse_args()
    home = args.home.resolve()
    defaults = args.defaults.resolve()
    state = home / ".config/nodesktop"
    marker = state / "style-version"
    if marker.exists() and marker.read_text().strip() == VERSION:
        return 0
    prior = marker.read_text().strip() if marker.exists() and marker.read_text().strip() else PRIOR_DEFAULT

    xfce = home / ".config/xfce4"
    sources = defaults / "xfce4"
    managed = [
        xfce / "xfconf/xfce-perchannel-xml/xsettings.xml",
        xfce / "xfconf/xfce-perchannel-xml/xfwm4.xml",
        xfce / "xfconf/xfce-perchannel-xml/xfce4-desktop.xml",
        xfce / "xfconf/xfce-perchannel-xml/xfce4-panel.xml",
        xfce / "terminal/terminalrc",
        home / ".bashrc",
    ]
    backup_root, old_checksums = backup(home, managed, prior)

    if not xfce.exists():
        shutil.copytree(sources, xfce)
    else:
        for source in sources.rglob("*"):
            if source.is_file():
                destination = xfce / source.relative_to(sources)
                if not destination.exists():
                    atomic_copy(source, destination)

    replacements = {
        "Roobert Light 10": "Inter 10",
        "Inconsolata Medium 12": "JetBrains Mono 11",
        "Roobert Bold 11": "Newsreader SemiBold 11",
        "/usr/share/wallpapers/turrell.jpg": "/usr/share/wallpapers/nodesktop-grid.svg",
        'value="applicationsmenu"': 'value="whiskermenu"',
        'value="p=12;x=720;y=877"': 'value="p=12;x=0;y=0"',
        'name="size" type="uint" value="30"': 'name="size" type="uint" value="32"',
        'name="size" type="uint" value="38"': 'name="size" type="uint" value="40"',
    }
    for name in ("xsettings.xml", "xfwm4.xml", "xfce4-desktop.xml", "xfce4-panel.xml"):
        destination = xfce / "xfconf/xfce-perchannel-xml" / name
        replace_known(destination, sources / "xfconf/xfce-perchannel-xml" / name, replacements)
        ET.parse(destination)

    scale = json.loads((defaults / "generated" / f"scale-{args.scale}.json").read_text())
    xsettings = xfce / "xfconf/xfce-perchannel-xml/xsettings.xml"
    panel = xfce / "xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    set_xfce_property(xsettings, "DPI", str(scale["dpi"]), {"96", "120"})
    set_xfce_property(xsettings, "LastCustomDPI", str(scale["dpi"]), {"96", "120"})
    set_xfce_property(xsettings, "FontName", scale["font"], {"Inter 10", "Inter Variable 10", "Inter Variable 11"})
    # The original Nodesktop image selected Arc with the blue Moka icon set.
    # Upgrade only those known historical defaults so a persistent TrueNAS
    # profile receives the current olive visual contract without overwriting a
    # theme that the user selected explicitly.
    set_xfce_property(
        xsettings,
        "ThemeName",
        "Nodesktop-Orchis-Green-Dark-Compact",
        {"Arc", "Arc-Dark", "Nodesktop-Orchis-Green-Dark-Compact"},
    )
    set_xfce_property(
        xsettings,
        "IconThemeName",
        "Nodesktop-Forest",
        {"Moka", "Nodesktop-Forest"},
    )
    for current, target in (({"30", "32", "40"}, str(scale["top_panel"])), ({"38", "40", "50"}, str(scale["bottom_panel"]))):
        tree = ET.parse(panel)
        sizes = [element for element in tree.iter("property") if element.get("name") == "size"]
        index = 0 if target == str(scale["top_panel"]) else 1
        if len(sizes) > index and sizes[index].get("value") in current:
            sizes[index].set("value", target)
            tree.write(panel, encoding="UTF-8", xml_declaration=True)

    terminal = defaults / "generated" / f"terminalrc-{args.scale}"
    terminal_destination = xfce / "terminal/terminalrc"
    if not terminal_destination.exists() or "Inconsolata" in terminal_destination.read_text() or "Nodesktop managed" in terminal_destination.read_text():
        atomic_copy(terminal, terminal_destination)

    bashrc = home / ".bashrc"
    if not bashrc.exists():
        atomic_copy(defaults / "bashrc", bashrc)
    else:
        text = bashrc.read_text(encoding="utf-8")
        if "export BASH_IT_THEME=clean" in text:
            bashrc.write_text(text.replace("export BASH_IT_THEME=clean", "export BASH_IT_THEME=zork"), encoding="utf-8")

    adapters = {
        defaults / "sublime": home / ".config/sublime-text/Packages/User",
        defaults / "geany": home / ".config/geany",
        defaults / "btop": home / ".config/btop",
    }
    for source_root, destination_root in adapters.items():
        for source in source_root.rglob("*"):
            if source.is_file():
                destination = destination_root / source.relative_to(source_root)
                if not destination.exists() or destination.name.startswith("Nodesktop") or destination.name == "nodesktop.conf":
                    atomic_copy(source, destination)

    state.mkdir(parents=True, exist_ok=True)
    marker.write_text(VERSION + "\n")
    if backup_root:
        record_migrated_checksums(home, backup_root, old_checksums, prior)
        (state / "last-backup").write_text(str(backup_root) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
