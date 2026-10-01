#!/usr/bin/env python3
"""Small BIBO geometry utility: gravity vector from spherical angles."""

from __future__ import annotations

import argparse
import math


def gravity_vector(g: float, theta: float, phi: float) -> tuple[float, float, float]:
    return (
        g * math.sin(phi) * math.cos(theta),
        g * math.sin(phi) * math.sin(theta),
        g * math.cos(phi),
    )


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--g", type=float, default=9.81)
    p.add_argument("--theta-deg", type=float, required=True)
    p.add_argument("--phi-deg", type=float, required=True)
    args = p.parse_args()

    theta = math.radians(args.theta_deg)
    phi = math.radians(args.phi_deg)

    gx, gy, gz = gravity_vector(args.g, theta, phi)
    print(f"gravity = [{gx:.8f}, {gy:.8f}, {gz:.8f}]")
    print(f"|g| = {math.sqrt(gx*gx + gy*gy + gz*gz):.8f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
