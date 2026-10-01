# Agent Tools

These are small deterministic helpers intended for agent use.

They are deliberately lightweight and dependency-minimal.

## Tools

- `gravity_vector.py` — inspect gravity vector from \(\theta,\phi\).
- `rod_geometry.py` — inspect a single rod distance constraint.
- `validate_json.py` — validate state/config JSON against a schema.

## Principle

Tools should expose small calculations the agent can verify, not replace the simulation engine.
