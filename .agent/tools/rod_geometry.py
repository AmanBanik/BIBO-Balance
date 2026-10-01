#!/usr/bin/env python3
"""Distance-constraint utility for one actuator rod."""

from __future__ import annotations

import argparse
import math


def distance(a: list[float], b: list[float]) -> float:
    return math.sqrt(sum((x-y)**2 for x, y in zip(a, b)))


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--base", nargs=3, type=float, required=True)
    p.add_argument("--corner", nargs=3, type=float, required=True)
    args = p.parse_args()

    d = distance(args.base, args.corner)
    print(f"rod_length = {d:.10f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
