#!/usr/bin/env bash
set -Eeuo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo}"
scripts/build-visual-assets.sh --check

if rg -ni '#(5294e2|5677fc|4662cf|919caf|86aeff|4a90e2)' \
  assets/icons config/generated config/geany config/sublime assets/kasmvnc; then
  printf 'FAIL: a rejected legacy blue remains in a Nodesktop-owned visual asset.\n' >&2
  exit 1
fi

python3 - <<'PY'
import json
from pathlib import Path

data = json.loads(Path("assets/design/tokens.json").read_text())
palette = data["palette"]

def luminance(color):
    channels = []
    for i in (1, 3, 5):
        value = int(color[i:i+2], 16) / 255
        channels.append(value / 12.92 if value <= .04045 else ((value + .055) / 1.055) ** 2.4)
    return .2126 * channels[0] + .7152 * channels[1] + .0722 * channels[2]

def contrast(a, b):
    high, low = sorted((luminance(a), luminance(b)), reverse=True)
    return (high + .05) / (low + .05)

for foreground, background, minimum in (
    ("warm_white", "ink", 4.5),
    ("body", "surface", 4.5),
    ("muted", "ink", 4.5),
    ("olive", "ink", 3.0),
):
    measured = contrast(palette[foreground], palette[background])
    if measured < minimum:
        raise SystemExit(f"contrast failure: {foreground}/{background}={measured:.2f}")
PY

printf 'PASS: generated visual assets, contrast gates, and legacy-blue guard.\n'
