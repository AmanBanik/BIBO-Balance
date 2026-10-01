#!/usr/bin/env python3
"""Framework-free BIBO physics math sanity checks."""

from __future__ import annotations

import argparse
import math
import random


def gravity(g: float, theta: float, phi: float) -> tuple[float, float, float]:
    return (
        g * math.sin(phi) * math.cos(theta),
        g * math.sin(phi) * math.sin(theta),
        g * math.cos(phi),
    )


def norm(v: tuple[float, float, float]) -> float:
    return math.sqrt(sum(x*x for x in v))


def dot(a, b) -> float:
    return sum(x*y for x, y in zip(a, b))


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--samples", type=int, default=1000)
    p.add_argument("--g", type=float, default=9.81)
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()

    random.seed(args.seed)
    worst = 0.0

    for _ in range(args.samples):
        theta = random.uniform(0.0, 2.0*math.pi)
        phi = random.uniform(0.0, math.radians(120.0))
        g = gravity(args.g, theta, phi)
        err = abs(norm(g) - args.g)
        worst = max(worst, err)

        # Flat horizontal plane normal.
        n = (0.0, 0.0, 1.0)
        gn = dot(g, n)
        tangent = tuple(g[i] - gn*n[i] for i in range(3))
        # Tangential and normal gravity are orthogonal.
        ortho = abs(dot(tangent, tuple(gn*n[i] for i in range(3))))
        if ortho > 1e-9:
            raise RuntimeError("gravity decomposition orthogonality failed")

    print(f"PASS: {args.samples} gravity/decomposition samples")
    print(f"Worst | |g| - target | = {worst:.3e}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
