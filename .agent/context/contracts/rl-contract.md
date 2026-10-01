# RL Contract

## Action

Four bounded continuous actuator commands:

\[
a_t=[\Delta L_1,\Delta L_2,\Delta L_3,\Delta L_4]
\]

## Observation modes

### Baseline
Privileged low-dimensional state.

### Intermediate
Ball elevation + actuator phase + temporal information.

### Final vision experiment
Top + side-X + side-Y camera streams, plus explicitly approved state channels.

## Evaluation

A valid RL result must report more than reward.

At minimum consider:

- success rate;
- stable-window duration;
- recovery time;
- RMS tangential velocity;
- maximum displacement;
- actuator effort;
- failure rate.
