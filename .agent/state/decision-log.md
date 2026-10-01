# BIBO Balance — Decision Log

Format:

```text
ID
Date
Decision
Reason
Supersedes
Impact
Revisit condition
```

## DEC-000

Date: 2026-10-01

Decision: BIBO Balance uses a simulation-first architecture.

Reason: Explicit project scope.

Supersedes: none.

Impact: Hardware integration is deferred.

Revisit condition: User explicitly changes project scope.

## DEC-001

Date: 2026-10-01

Decision: The controller's action interface is four independent rod-length changes.

Reason: Core project concept.

Impact: RL action dimensionality is four.

Revisit condition: User explicitly changes actuator model.

## DEC-002

Date: 2026-10-01

Decision: Local and public visualizations are separate front ends over a common simulation state.

Reason: Local needs laboratory telemetry; public needs polished interaction.

Impact: Rendering code must not own physics.

Revisit condition: Architecture is deliberately consolidated later.

