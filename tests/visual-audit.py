#!/usr/bin/env python3
"""Audit lossless visual captures for legacy blue and palette drift."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

LEGACY_BLUE = ((82, 148, 226), (86, 119, 252), (70, 98, 207), (145, 156, 175), (134, 174, 255))


def near(left: tuple[int, int, int], right: tuple[int, int, int], radius: int = 8) -> bool:
    return sum((a - b) ** 2 for a, b in zip(left, right)) <= radius * radius


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("captures", type=Path, nargs="+")
    args = parser.parse_args()
    for capture in args.captures:
        image = Image.open(capture).convert("RGB")
        pixels = image.getdata()
        matches = sum(any(near(pixel, rejected) for rejected in LEGACY_BLUE) for pixel in pixels)
        ratio = matches / (image.width * image.height)
        if ratio > 0.002:
            raise SystemExit(f"{capture}: legacy-blue pixels {ratio:.3%} exceed 0.2%")
        if image.width < 1024 or image.height < 720:
            raise SystemExit(f"{capture}: capture is too small for approval")
        print(f"PASS: {capture} legacy_blue={ratio:.3%} size={image.width}x{image.height}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
