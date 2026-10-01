#!/usr/bin/env python3
"""Focused gravity sweep for BIBO's spherical-angle convention."""

from __future__ import annotations

import math


def gvec(g: float, theta: float, phi):
    return (
        g * math.sin(phi) * math.cos(theta),
        g * math.sin(phi) * math.sin(theta),
        g * math.cos(phi),
    )


def main() -> int:
    g = 9.81
    worst = 0.0
    for theta_deg in range(0, 360, 15):
        for phi_deg in range(0, 121, 10):
            v = gvec(g, math.radians(theta_deg), math.radians(phi_deg))
            mag = math.sqrt(sum(x*x for x in v))
            worst = max(worst, abs(mag-g))
    print(f"worst magnitude error: {worst:.3e}")
    return 0 if worst < 1e-9 else 1


if __name__ == "__main__":
    raise SystemExit(main())
