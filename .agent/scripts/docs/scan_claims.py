#!/usr/bin/env python3
"""Scan Markdown for benchmark/claim phrases that deserve evidence review."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

PATTERNS = [
    r"\b\d+(?:\.\d+)?x\b",
    r"\b\d+(?:\.\d+)?\s*%\b",
    r"\b(?:proved|proves|guarantees|physically accurate|identical physics)\b",
    r"\b(?:PINN|physics-informed)\b",
]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()

    for path in args.paths:
        lines = path.read_text(encoding="utf-8").splitlines()
        for no, line in enumerate(lines, 1):
            if any(re.search(pattern, line, flags=re.I) for pattern in PATTERNS):
                print(f"{path}:{no}: REVIEW CLAIM -> {line.strip()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
