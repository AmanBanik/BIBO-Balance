# Workflow: Session Handoff

At the end of a non-trivial session:

1. summarize work;
2. list files changed;
3. list tests;
4. list failures;
5. list decisions;
6. list open blockers;
7. state exact next step.

Use:

```bash
python .agent/scripts/make_handoff.py
```

Then manually refine the generated handoff if needed.
