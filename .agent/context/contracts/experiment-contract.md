# Experiment Contract

An experiment is reproducible only when the following can be reconstructed:

```text
code revision
config
seed(s)
physics version
policy version
hardware/toolchain
evaluation distribution
```

Do not compare two RL results if their physics/configuration changed silently.
