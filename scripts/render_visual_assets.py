#!/usr/bin/env python3
"""Generate deterministic Nodesktop visual adapters from tokens.json."""

from __future__ import annotations

import argparse
import json
import math
import pathlib
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
TOKENS = ROOT / "assets/design/tokens.json"
OUTPUT = ROOT / "config/generated"


def rgb(value: str) -> tuple[int, int, int]:
    if len(value) != 7 or not value.startswith("#"):
        raise ValueError(f"invalid color: {value}")
    return tuple(int(value[index:index + 2], 16) for index in (1, 3, 5))


def luminance(value: str) -> float:
    channels = []
    for channel in rgb(value):
        normalized = channel / 255
        channels.append(normalized / 12.92 if normalized <= 0.04045 else ((normalized + 0.055) / 1.055) ** 2.4)
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def contrast(left: str, right: str) -> float:
    high, low = sorted((luminance(left), luminance(right)), reverse=True)
    return (high + 0.05) / (low + 0.05)


def validate(data: dict) -> None:
    required = {"ink", "carbon", "surface", "forest", "olive", "sage", "warm_white", "body", "muted", "rule", "gold", "danger", "danger_fill", "warning", "warning_fill", "success", "success_fill", "information"}
    palette = data["palette"]
    missing = required - palette.keys()
    if missing:
        raise ValueError(f"missing palette tokens: {sorted(missing)}")
    for value in palette.values():
        rgb(value)
    for foreground, background, minimum in (
        ("warm_white", "ink", 4.5), ("body", "surface", 4.5),
        ("muted", "ink", 4.5), ("olive", "ink", 3.0),
        ("warm_white", "danger_fill", 4.5), ("warm_white", "warning_fill", 4.5),
        ("warm_white", "success_fill", 4.5),
    ):
        ratio = contrast(palette[foreground], palette[background])
        if ratio < minimum:
            raise ValueError(f"contrast {foreground}/{background}={ratio:.2f} below {minimum}")
    if set(data["scale_profiles"]) != {"100", "125"}:
        raise ValueError("scale profiles must be exactly 100 and 125")


def render(data: dict, destination: pathlib.Path) -> None:
    palette = data["palette"]
    destination.mkdir(parents=True, exist_ok=True)
    terminal_template = """# Nodesktop managed
[Configuration]
FontName={terminal_font}
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_UNDERLINE
MiscDefaultGeometry=80x24
MiscMenubarDefault=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscHighlightUrls=TRUE
MiscCopyOnSelect=FALSE
MiscRewrapOnResize=TRUE
ColorCursor={sage}
ColorPalette=#0B0F0C;#A85F5A;#5F986C;#B79A61;#73875A;#8B7652;#82B88A;#D7DBD2;#657066;#EF8B86;#82B88A;#E0B35E;#98A193;#B79A61;#AFC39D;#F2F0E6
ColorBoldUseDefault=FALSE
ColorForeground={body}
ColorBackground={carbon}
ColorBold={warm_white}
ColorSelection={forest}
"""
    for scale, profile in data["scale_profiles"].items():
        terminal = terminal_template.format(terminal_font=profile["terminal_font"], **palette)
        (destination / f"terminalrc-{scale}").write_text(terminal, encoding="utf-8")
    btop = f"""theme[main_bg]=\"{palette['ink']}\"
theme[main_fg]=\"{palette['body']}\"
theme[title]=\"{palette['warm_white']}\"
theme[hi_fg]=\"{palette['sage']}\"
theme[selected_bg]=\"{palette['forest']}\"
theme[selected_fg]=\"{palette['warm_white']}\"
theme[inactive_fg]=\"{palette['muted']}\"
theme[graph_text]=\"{palette['olive']}\"
theme[proc_misc]=\"{palette['gold']}\"
theme[cpu_box]=\"{palette['olive']}\"
theme[mem_box]=\"{palette['olive']}\"
theme[net_box]=\"{palette['olive']}\"
theme[proc_box]=\"{palette['olive']}\"
theme[div_line]=\"{palette['rule']}\"
theme[temp_start]=\"{palette['olive']}\"
theme[temp_mid]=\"{palette['gold']}\"
theme[temp_end]=\"{palette['danger']}\"
theme[cpu_start]=\"{palette['forest']}\"
theme[cpu_mid]=\"{palette['sage']}\"
theme[cpu_end]=\"{palette['gold']}\"
theme[free_start]=\"{palette['forest']}\"
theme[free_mid]=\"{palette['olive']}\"
theme[free_end]=\"{palette['sage']}\"
theme[cached_start]=\"{palette['forest']}\"
theme[cached_mid]=\"{palette['olive']}\"
theme[cached_end]=\"{palette['sage']}\"
theme[available_start]=\"{palette['forest']}\"
theme[available_mid]=\"{palette['olive']}\"
theme[available_end]=\"{palette['sage']}\"
theme[used_start]=\"{palette['gold']}\"
theme[used_mid]=\"{palette['warning']}\"
theme[used_end]=\"{palette['danger']}\"
theme[download_start]=\"{palette['forest']}\"
theme[download_mid]=\"{palette['olive']}\"
theme[download_end]=\"{palette['sage']}\"
theme[upload_start]=\"{palette['olive']}\"
theme[upload_mid]=\"{palette['sage']}\"
theme[upload_end]=\"{palette['warm_white']}\"
"""
    (destination / "nodesktop-btop.theme").write_text(btop, encoding="utf-8")
    css_vars = ":root {\n" + "".join(f"  --nodesktop-{key.replace('_', '-')}: {value};\n" for key, value in palette.items()) + "}\n"
    (destination / "nodesktop-web-tokens.css").write_text(css_vars, encoding="utf-8")
    gtk = f"""/* Generated from assets/design/tokens.json. */
@define-color nodesktop_ink {palette['ink']};
@define-color nodesktop_surface {palette['surface']};
@define-color nodesktop_forest {palette['forest']};
@define-color nodesktop_olive {palette['olive']};
@define-color nodesktop_sage {palette['sage']};
@define-color nodesktop_warm_white {palette['warm_white']};
@define-color nodesktop_rule {palette['rule']};
*:focus {{ outline-color: @nodesktop_sage; outline-width: 2px; outline-style: solid; outline-offset: 1px; }}
tooltip {{ border: 1px solid @nodesktop_rule; border-radius: 3px; }}
selection {{ background-color: @nodesktop_forest; color: @nodesktop_warm_white; }}
"""
    (destination / "gtk-nodesktop.css").write_text(gtk, encoding="utf-8")
    for name, profile in data["scale_profiles"].items():
        (destination / f"scale-{name}.json").write_text(json.dumps(profile, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    data = json.loads(TOKENS.read_text(encoding="utf-8"))
    validate(data)
    if args.check:
        with tempfile.TemporaryDirectory() as temporary:
            candidate = pathlib.Path(temporary)
            render(data, candidate)
            expected = {path.name: path.read_bytes() for path in OUTPUT.glob("*") if path.is_file()}
            actual = {path.name: path.read_bytes() for path in candidate.glob("*") if path.is_file()}
            if expected != actual:
                missing = sorted(set(actual) - set(expected))
                stale = sorted(name for name in set(actual) & set(expected) if actual[name] != expected[name])
                extra = sorted(set(expected) - set(actual))
                raise SystemExit(f"generated visual assets are stale (missing={missing}, stale={stale}, extra={extra})")
    else:
        render(data, OUTPUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
