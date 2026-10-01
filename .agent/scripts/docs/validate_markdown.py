#!/usr/bin/env python3
"""Detect a few common Markdown math mistakes in project documentation."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def check(path: Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    errors: list[str] = []
    in_fence = False
    dollar_count = 0

    for i, line in enumerate(lines, start=1):
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue

        if not in_fence:
            if r"\[" in line or r"\]" in line or r"\(" in line or r"\)" in line:
                errors.append(f"{path}:{i}: unsupported \\[...\\] or \\(...\\) delimiter")
            dollar_count += line.count("$$")

            # Common literal-diagnostic failure pattern.
            if r"\text{" in line and "$" not in line:
                errors.append(f"{path}:{i}: LaTeX command outside math delimiters")

    if dollar_count % 2:
        errors.append(f"{path}: odd number of $$ delimiters")

    return errors


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("paths", nargs="+", type=Path)
    args = p.parse_args()

    errors = []
    for path in args.paths:
        errors.extend(check(path))

    if errors:
        print("FAIL")
        print("\n".join(errors))
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
