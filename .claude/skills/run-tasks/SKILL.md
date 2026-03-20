---
name: run-tasks
description: Execute all TODO tasks in BLUEPRINT.md autonomously until a PRINCIPAL_BREAK or failure. Use when the Principal runs /run-tasks.
disable-model-invocation: true
---

# Run Tasks

## Purpose

Execute TODO tasks in order, autonomously, until hitting a PRINCIPAL_BREAK, a FAIL, or the end of the list.
Mirrors the existing autonomous 80% workflow but triggered explicitly by the Principal.

## Instructions

1. Read BLUEPRINT.md in full.
2. Collect all tasks with status `TODO` in order.
3. If none: report "No pending tasks." and stop.
4. For each TODO task in sequence:

   **If PRINCIPAL_BREAK:**
   - Mark it DONE in BLUEPRINT.md.
   - Report stop summary (see Output format).
   - Stop. Do not execute the task after it.

   **Otherwise:**
   - Mark task IN PROGRESS in BLUEPRINT.md.
   - Execute using the standard CLAUDE.md orchestration pattern:
     - Extract WHY, WHAT, constraints from BLUEPRINT.
     - Invoke implementing agent with full context.
     - Invoke reviewer with identical context.
     - On PASS: mark DONE, continue to next task.
     - On FAIL (after 2 correction cycles): mark FAIL, report, stop immediately.

5. On natural end (all tasks done): report completion summary.

## Output format — stop on PRINCIPAL_BREAK
```
## Run complete — PRINCIPAL_BREAK reached

Completed: X tasks
  [x] DONE — [task]
  [x] DONE — [task]

Stopped at: PRINCIPAL_BREAK — [description]

Awaiting review and decision.
```

## Output format — stop on FAIL
```
## Run stopped — task failed

Completed before failure: X tasks
Failed: [ ] FAIL — [task description]
Reviewer findings: [summary]

Correction cycles exhausted. Awaiting Principal decision.
```

## Constraints

- All existing hooks fire normally throughout the run.
- Never skip a PRINCIPAL_BREAK.
- Never continue past a FAIL without Principal instruction.
- Never modify WHY, WHAT, HOW, AGENTS, SKILLS, DECISIONS, or OPEN QUESTIONS in BLUEPRINT.
