# BIBO Balance — Current Contracts

This file lists the interfaces that should remain conceptually stable.

## Physics state contract

A simulation state should expose at least:

- simulation time,
- fixed step,
- ball position,
- ball velocity,
- ball angular state when modeled,
- contact state,
- platform position,
- platform rotation,
- platform normal,
- four actuator lengths,
- four actuator length changes/rates,
- gravity vector,
- energy diagnostics,
- stability status.

## Action contract

```text
a_t = [ΔL1, ΔL2, ΔL3, ΔL4]
```

Actions must be bounded.

## State ownership

Physics engine owns authoritative state.

Renderers consume snapshots.

RL environment consumes controlled observations.

Telemetry is derived data.

## Boundary rule

Never let:

```text
renderer → physics state
```

become an implicit control path.

The intended direction is:

```text
physics → state snapshot → renderer
```

except for explicit user control messages which are routed through the simulation interface.

## Versioning

When changing a cross-module state schema:

1. increment schema version;
2. update the JSON schema under `.agent/schemas/`;
3. update consumers;
4. add/update compatibility tests;
5. record the decision.
