#!/usr/bin/env python3
"""Framework-free RL sanity checks.

This script checks structural properties rather than training a policy.
It can be run before TensorFlow/PyTorch is involved.
"""

from __future__ import annotations

import argparse
import math
import random


def validate_action(action: list[float], limit: float) -> None:
    if len(action) != 4:
        raise ValueError(f"expected 4 actions, got {len(action)}")
    if any(not math.isfinite(x) for x in action):
        raise ValueError("non-finite action")
    if any(abs(x) > limit + 1e-12 for x in action):
        raise ValueError("action outside configured bound")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--samples", type=int, default=1000)
    p.add_argument("--action-limit", type=float, default=1.0)
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()

    random.seed(args.seed)

    for _ in range(args.samples):
        action = [random.uniform(-args.action_limit, args.action_limit) for _ in range(4)]
        validate_action(action, args.action_limit)

    print(f"PASS: {args.samples} bounded 4-DOF action samples")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
