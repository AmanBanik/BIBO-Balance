#!/usr/bin/env python3
"""Check that four actuator actions map to four actuator state changes."""

from __future__ import annotations


def apply(lengths, actions, lo, hi):
    if len(lengths) != 4 or len(actions) != 4:
        raise ValueError("BIBO actuator interface requires exactly four values")
    return [max(lo, min(hi, x+a)) for x, a in zip(lengths, actions)]


def main() -> int:
    lengths = [1.0, 1.0, 1.0, 1.0]
    actions = [0.01, -0.02, 0.03, -0.04]
    updated = apply(lengths, actions, 0.5, 1.5)
    expected = [1.01, 0.98, 1.03, 0.96]
    if updated != expected:
        raise SystemExit(f"FAIL: {updated} != {expected}")
    print("PASS: four-action actuator mapping")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
