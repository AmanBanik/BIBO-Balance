# Subagent: Benchmarking

## Mission

Design measurements that distinguish:

- simulation throughput,
- environment throughput,
- training throughput,
- physics-step latency,
- rendering FPS,
- policy inference latency,
- recovery time.

## Rule

Never report "GPU speedup" without stating the measured scope:

- kernel-only;
- GPU-resident;
- H2D + compute + D2H;
- full application;
- or batch training throughput.
