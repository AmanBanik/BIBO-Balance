# BIBO Balance — Experiment Registry

Every meaningful experiment gets one compact record.

Recommended fields:

```text
Experiment ID
Date
Git revision
Config
Seed(s)
Physics version
Policy checkpoint
Environment distribution
Hardware
CUDA version
Simulation dt
Batch size
Training/evaluation split
Metrics
Failures
Conclusion
Next action
```

Use `experiments/` or repository-native experiment storage for large artifacts. This registry is the index, not the artifact store.
