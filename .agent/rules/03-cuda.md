# CUDA Rules

- CPU reference first.
- Batch before optimizing tiny single-environment workloads.
- Benchmark before/after every major CUDA move.
- Check launch/runtime errors.
- Check CPU/GPU numerical parity.
- Keep transfers explicit.
- Prefer persistent or batched device state.
- Never use GPU speedup as a reason to tolerate an incorrect algorithm.
