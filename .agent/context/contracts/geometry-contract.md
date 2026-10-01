# Geometry Contract

## Current guaranteed facts

- Platform is rigid and planar.
- Four corner actuator lengths are independently controllable.
- Platform has a nominal 3:1 length-to-width ratio.
- Actuator angles are not directly controlled by the RL action vector.

## Required equations

For an actuator joining base anchor \(B_i\) to platform corner \(P_i\):

\[
L_i=\|\mathbf P_i-\mathbf B_i\|
\]

The exact inverse problem:

\[
(L_1,L_2,L_3,L_4)\rightarrow \text{platform pose}
\]

depends on the frozen mechanical constraints.

## Prohibition

Do not silently introduce a platform pose mapping of the form:

```text
four lengths → arbitrary corner heights → warped plane
```

A rigid plane must remain rigid.

## Required test classes

- neutral pose;
- pure tilt;
- asymmetric actuator change;
- near-limit actuator lengths;
- infeasible actuator configuration;
- degeneracy;
- round-trip length/pose consistency where applicable.
